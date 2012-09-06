function [u c NumIter EnerVal ResiVal IncPEN] = OptimalControlPenalize(f,l,t,MaxK,MaxI,tolK,tolI,uStep,cStep,cInit,uInit)
    %Algorithm for the optimisation of the considered framework.
    
    % Copyright 2012 Laurent Hoeltgen <laurent.hoeltgen@gmail.com>
    %
    % This program is free software; you can redistribute it and/or modify it
    % under the terms of the GNU General Public License as published by the Free
    % Software Foundation; either version 3 of the License, or (at your option)
    % any later version.
    %
    % This program is distributed in the hope that it will be useful, but
    % WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY
    % or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public License
    % for more details.
    %
    % You should have received a copy of the GNU General Public License along
    % with this program; if not, write to the Free Software Foundation, Inc., 51
    % Franklin Street, Fifth Floor, Boston, MA 02110-1301, USA.
    
    % Last revision on: 16.08.2012 17:30
    
    % Solves
    % min 0.5*||u-f||_2^2 + l*||c||_1 + t*||c*(u-f)-(1-c)*D*u||_2^2
    % by alternating the minimization w.r.t to u and c. (+ penalizing update
    % distance)
    
    narginchk(9,11)
    
    % Initialize Data.
    if nargin == 9
        c = rand(size(f(:)));
        u = SolvePde(f,c);
    elseif nargin == 11
        c = cInit(:);
        u = uInit(:);
    else
        error('OPTCONT:BadArg','Bad Number of Arguments.');
    end
    
    k = 1;
    
    NumIter = 0;
    EnerVal = [];
    ResiVal = [];
    IncPEN = [];
    
    while k <= MaxK
        %% Outer loop increases the penalization of deviations in the constraint.
        
        i = 1;
        
        uOldK = u;
        cOldK = c;
        
        while i <= MaxI
            %% Inner loop minimizes alternatively with respect to u and c.
            
            % Minimization w.r.t. to u is an lsq problem.
            % Minimization w.r.t. to c can be done through an extended variant of
            % soft shrinkage.
            
            uOldI = u;
            cOldI = c;
            
            % Find optimal u.
            
            coeffs = [ 1 t uStep ];
            A = cell(3,1);
            b = cell(3,1);
            
            A{1} = speye(length(f(:)),length(f(:)));
            b{1} = f(:);
            
            A{2} = ConstructMat4u(cOldI);
            b{2} = cOldI(:).*f(:);
            
            A{3} = speye(length(f(:)),length(f(:)));
            b{3} = uOldI(:);
            
            u = Optimization.MinQuadraticEnergy(coeffs,A,b);
            
            % Find optimal c.
            
            lambda = l*ones(length(c(:)),1);
            theta = [ t cStep ];
            A = [ u(:) - f(:) + D2(length(u(:)))*u(:) cOldI(:) ];
            b = [ D2(length(u(:)))*u cOldI ];
            c = Optimization.SoftShrinkage(lambda,theta,A,b);
            
            EnerVal = [ EnerVal Energy(u,c,f,l) ];
            ResiVal = [ ResiVal Residual(u,c,f) ];
            NumIter = NumIter + 1;
            
            changeI = max([norm(uOldI-u,Inf) norm(cOldI-c,Inf)]);
            
            if changeI < tolI
                break;
            else
                i = i + 1;
            end
            
        end
        
        changeK = max([norm(uOldK-u,Inf) norm(cOldK-c,Inf)]);
        
        if changeK < tolK
            break;
        else
            t = t*1.5;
            uStep = uStep*1.5;
            cStep = cStep*1.5;
            k = k + 1;
            IncPEN = [IncPEN NumIter];
        end
        
    end
    
    u = SolvePde(f,c);
    
end


function out = ConstructMat4u(c)
    out = spdiags(c(:),0,length(c(:)),length(c(:))) - ...
        spdiags(1-c(:),0,length(c(:)),length(c(:)))*D2(length(c(:)));
end
