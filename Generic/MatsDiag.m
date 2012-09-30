function B = MatsDiag(A,o)
% B = MatsDiag(A,o);
% Creates a large and sparse matrix B containing the matrices in A on the o-th
% diagonal. A is supposed to be l times c times m matrix, where l and c are the
% dimensions of each matrix and m is the total number of matrices. o represents
% the offset. Positive values correspond to the upper diagonals while negative
% values place the matrices on the lower diagonal.
%
% Usage: B = MatsDiag(A,o)
% A : an array of matrices.
% o : the desired offset.
% B : a sparse matrix with the matrices from A on the o-th diagonal.
%
% See also kron, reshape, repmat, spdiags, sparse

% Copyright (c) 2011 Laurent Hoeltgen <hoeltgen@mia.uni-saarland.de>
%
% This program is free software; you can redistribute it and/or modify
% it under the terms of the GNU General Public License as published by
% the Free Software Foundation; either version 3 of the License, or
% (at your option) any later version.
%
% This program is distributed in the hope that it will be useful,
% but WITHOUT ANY WARRANTY; without even the implied warranty of
% MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
% GNU General Public License for more details.
%
% You should have received a copy of the GNU General Public License
% along with this program; if not, write to the Free Software
% Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston,
% MA 02110-1301, USA.

error(nargchk(1,2,nargin));
if nargin == 1
    o = 0;
end

[ l c m ] = size(A);

if o > 0
    B = sparse( ...
        reshape(repmat(reshape(1:m*l,l,[]),c,1),[],1), ...
        kron(o*c+(1:m*c),ones(1,l))', ...
        reshape(A(:,:),[],1), ...
        (m+o)*l,(m+o)*c);
elseif o < 0
    B = sparse( ...
        reshape(repmat(reshape((1:m*l)-o*l,l,[]),c,1),[],1), ...
        kron(1:m*c,ones(1,l))', ...
        reshape(A(:,:),[],1), ...
        (m-o)*l,(m-o)*c);
else
    B = sparse( ...
        reshape(repmat(reshape(1:m*l,l,[]),c,1),[],1), ...
        kron(1:m*c,ones(1,l))', ...
        reshape(A(:,:),[],1), ...
        m*l,m*c);
end
end