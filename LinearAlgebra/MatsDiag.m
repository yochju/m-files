function B = MatsDiag(A,o)
%% Creates a matrix by placing the input matrices on a diagonal.
%
% B = MatsDiag(A,o);
%
% Input parameters (required):
%
% A : Input matrices (l x c x m array).
% o : offset of the diagonal. positive values for above the main diagonal and
%     negative values for below. 0 indicates the main diagonal. (scalar)
%
% Input parameters (parameters):
%
% Parameters are either struct with the following fields and corresponding
% values or option/value pairs, where the option is specified as a string.
%
% -
%
% Input parameters (optional):
%
% The number of optional parameters is always at most one. If a function takes
% an optional parameter, it does not take any other parameters.
%
% -
%
% Output parameters:
%
% B : sparse Matrix containing the matrices of A on its o-th diagonal.
%
% Output parameters (optional):
%
% -
%
% Description:
%
% Creates a large and sparse matrix B containing the matrices in A on the o-th
% diagonal. A is supposed to be l times c times m matrix, where l and c are the
% dimensions of each matrix and m is the total number of matrices. o represents
% the offset. Positive values correspond to the upper diagonals while negative
% values place the matrices on the lower diagonal.
%
% Example
%
% See also kron, reshape, repmat, spdiags, sparse

% Copyright (c) 2011-2013 Laurent Hoeltgen <laurent.hoeltgen@gmail.com>
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

% Last revision on: 10.02.2013 20:48

%% Notes

% TODO: Generalize such that the matrices don't have to have the same size.
% TODO: Check that A has correct size.

%% Parse input and output.

narginchk(2,2);

parser = inputParser;
parser.FunctionName = mfilename;
parser.CaseSensitive = false;
parser.KeepUnmatched = true;
parser.StructExpand = true;

parser.addRequired('A', @(x) validateattributes( x, {'numeric'}, ...
    {'finite', 'nonempty', 'nonnan', 'nonsparse'}, mfilename, 'A', 1) );

parser.addRequired('o', @(x) validateattributes( x, {'numeric'}, ...
    {'finite', 'integer', 'scalar'}, mfilename, 'o', 2));

parser.parse(A, o);

%% Run code.

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
