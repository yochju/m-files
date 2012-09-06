function out = EvalPde(f,u,c,s)
    %Evaluates Poisson equation with mixed boundary conditions.
    
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
    
    narginchk(3, 4);
    nargoutchk(0, 1);
    
    if nargin == 3
        out = c(:).*(u(:)-f(:)) - (1 - c(:)).*(D2(length(c(:)))*u(:));
    elseif nargin == 4
        out = c(:).*(u(:)-f(:)) - (1 - c(:)).*(D2(length(c(:),s))*u(:));
    else
        error('OPTCONT:BadP','Wrong number of parameters passed.');
    end
end