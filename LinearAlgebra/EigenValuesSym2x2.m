function out = EigenValuesSym2x2(M)
%% Returns the eigenvalues of a symmetric 2 times 2 matrix.

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

% Last revision on: 27.11.2012 14:20

a = M(1,1);
b = M(2,1);
c = M(2,2);

ExcM = ExceptionMessage('Input');
assert(IsSymmetric(M), ExcM.id, ExcM.message);

out = [ nan nan ];
out(1) = 0.5*(a+c-sqrt(4*b^2+(a-c)^2));
out(2) = 0.5*(a+c+sqrt(4*b^2+(a-c)^2));

end
