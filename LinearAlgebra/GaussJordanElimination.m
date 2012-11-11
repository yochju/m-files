function out = GaussJordanElimination(A,b)

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

% See also rref

n = size(A,2);
D = [ A b ];

for k = 1:n
    r = (k-1) + find(abs(A(k:end,k))==max(abs(A(k:end,k))), 1, 'first');
    tempA = A(k,k:n);
    tempb = b(k);
    A(k,k:n) = A(r,k:n);
    b(k) = b(r);
    A(r,k:n) = tempA;
    b(r) = tempb;
    row_ind = [1:(k-1) , (k+1):n];
    m = A(row_ind,k)/A(k,k);
    A(row_ind,k:n) = A(row_ind, k:n) - m*A(k,k:n);
    b(row_ind) = b(row_ind) - m*b(k);
end
out = b./diag(A,0);
end
