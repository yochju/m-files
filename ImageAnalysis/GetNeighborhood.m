function out = GetNeighborhood(in,r,c)
%% Returns (2r+1)x(2c+1) window around every pixel.

% Copyright 2012 Laurent Hoeltgen <laurent.hoeltgen@gmail.com>
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

% Last revision on: 17.10.2012 07:48

temp = MirrorEdges(in,[r c]);
[nr nc] = size(in);
[jj kk] = meshgrid(1:nr,1:nc);
out = transpose( ...
    arrayfun( ...
    @(rr,cc) temp(rr+(-r:r),cc+(-c:c)), ...
    r+jj, c+kk, 'UniformOutput', false) );
end
