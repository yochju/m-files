function [g, u] = IterativeGVO(f,c,Its)

% Copyright 2012, 2015 Laurent Hoeltgen <laurent.hoeltgen@gmail.com>
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

u = SolvePde(f,c);
g = f;
K = find(c);
for k = 1:Its
    for i = K(randperm(numel(K)))'
        ei = zeros(size(u));
        ei(i) = 1;
        ui = SolvePde(ei,c);
        a = (ui(:)'*(f(:)-u(:)))/(ui(:)'*ui(:));
        uold = u; % used for while loop.
        u = u + a*ui;
        g(i) = g(i) + a;
    end
end
end
