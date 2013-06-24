function [u, c, eArr] = OptContDenoise(f, g, lambda, mu, theta, its, V, W)
%
% Solves: argmin_{u,c} lambda/2||u-f||^2 + mu/2||c-g||^2
%         such that (c-V).*(u-f) - (W-c).*Du = 0
%
% Note that we can get to common cases by setting the parameters as follows.
%
% g=0, V=1, W=0:
%                argmin_{u,c} lambda/2||u-f||^2 + mu/2||c||^2
%                such that (1-c).*(u-f) - c.*Du = 0
%
% Enforces c to be close to 0 and thus u close to f.
%
% g=1, V=0, W=1:
%                argmin_{u,c} lambda/2||u-f||^2 + mu/2||c-1||^2
%                such that c.*(u-f) - (1-c).*Du = 0
%
% Enforces c to be close to 1 and thus u close to f.

% Copyright 2013 Laurent Hoeltgen <laurent.hoeltgen@gmail.com>
%
% This program is free software; you can redistribute it and/or modify it under
% the terms of the GNU General Public License as published by the Free Software
% Foundation; either version 3 of the License, or (at your option) any later
% version.
%
% This program is distributed in the hope that it will be useful, but WITHOUT
% ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS
% FOR A PARTICULAR PURPOSE.  See the GNU General Public License for more
% details.
%
% You should have received a copy of the GNU General Public License along with
% this program; if not, write to the Free Software Foundation, Inc., 51 Franklin
% Street, Fifth Floor, Boston, MA 02110-1301, USA.

% Image Size and Number or pixels.
[nr nc] = size(f);
N = nr*nc;

% Initialise Mask and Signal somewhere in the middle.
% Unsure if this is ok or not.
c = 0.5*ones(size(f));
u = mean(f(:))*ones(size(f));
% Set up some necessary linear operators.
D = LaplaceM(nr, nc);
I = speye(N,N);
% Vectorise given data.
c = Mat2Vec(c,'row');
u = Mat2Vec(u,'row');
f = Mat2Vec(f,'row');
g = Mat2Vec(g,'row');
V = Mat2Vec(V,'row');
W = Mat2Vec(W,'row');
% Array for storing energy values.
eArr = inf(4,its);
% Perform iterates.
for i = 1:its
    % Save old position for Taylor expansion.
    cbar = c;
    ubar = u;
    % Perform Taylor expansion
    A = spdiags( cbar - V , 0, N, N) - spdiags( W - cbar , 0, N, N)*D;
    B = spdiags( ubar - f + D * ubar , 0, N, N);
    gk = cbar.*((I+D)*ubar) - V.*f;
    % Set up the linear system to obtain the dual variable.
    LHS = (1/(lambda+theta))*(A*(A')) + (1/(mu+theta))*(B*(B'));
    RHS = (1/(lambda+theta))*A*(lambda*f+theta*ubar) + ...
        (1/(mu+theta))*B*(mu*g+theta*cbar) - gk;
    % Compute dual variable.
    p = LHS\RHS;
    % Compute primal variables.
    u = (1/(lambda+theta))*(lambda*f+theta*ubar-(A')*p);
    c = (1/(mu+theta))*(mu*g + theta*cbar - (B')*p);
    % Compute energy.
    eArr(1,i) = EneR(u,c,f,g,lambda,mu);
    eArr(2,i) = ErrConstr(u,c,f,V,W,D);
    eArr(3,i) = norm(u-f,2)^2;
    eArr(4,i) = norm(c-g,2)^2;
    if abs(eArr(2,i))< 1e-10
        eArr = eArr(:,1:i);
        break;
    end
end
u = Vec2Mat(u,nr,nc,'row');
c = Vec2Mat(c,nr,nc,'row');
end

function e = EneR(u,c,f,g,lambda,mu)
e = 0.5*lambda*norm(u-f,2)^2 + 0.5*mu*norm(g-c,2)^2;
end

function e = ErrConstr(u,c,f,V,W,D)
e = norm((c-V).*(u-f) - (W-c).*(D*u),2);
end
