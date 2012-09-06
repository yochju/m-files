function [u c NumIter EnerVal ResiVal IncPEN] = MultiScaleOptimalControlPenalize(f,l,t,MaxK,MaxI,tolK,tolI,uStep,cStep,scaling,NSamples)
    %Solves Optimal Control framework through a multiscale approach.
    
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
    Scales = CoarseToFine(f(:),scaling,NSamples);
    
    fprintf('Solving on 1 / %d\n',length(Scales));
    [u c NumIter EnerVal ResiVal IncPEN] = OptimalControlPenalize( ...
        Scales{1}, ...
        l, t, MaxK, MaxI, tolK, tolI, uStep, cStep);
    for i = 2:length(Scales)
        fprintf('Solving on %d / %d\n',i,length(Scales));
        u = interp1(linspace(0,1,length(u(:))),u,linspace(0,1,length(Scales{i})));
        c = interp1(linspace(0,1,length(c(:))),c,linspace(0,1,length(Scales{i})));
        [u c NumIter EnerVal ResiVal IncPEN] = OptimalControlPenalize( ...
            Scales{i}, ...
            l, t, MaxK, MaxI, tolK, tolI, uStep, cStep, u, c);
    end
end