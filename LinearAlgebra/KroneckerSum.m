function M = KroneckerSum (A, B)
%% Computes Kronecker sum of two square matrices
%
% M = KroneckerSum (A, B)
%
% Computes the Kronecker sum of two square matrices. The returned matrix is
% sparse.
%
% Input Parameters (required):
%
% A : first matrix.
% B : second matrix.
%
% Output Parameters
%
% M : kronecker sum of A and B. (sparse matrix)
%
% Example
%
% A = [1 2 ; 3 4];
% B = [5 6 ; 7 8];
% M = KroneckerSum (A, B)
%
% Remarks
%
% The implementation assumes that the points are number row-wise. This is in
% conflict with the standard numbering scheme in MATLAB, which runs column-wise
% over a matrix.
%
% See also kron.

% Copyright 2012-2014 Laurent Hoeltgen <laurent.hoeltgen@gmail.com>
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

% Last revision: 28.12.2014 17:00

%% Comments and Remarks.
%

%% Check input parameters

narginchk (2, 2);
nargoutchk (0, 1);

parser = inputParser;
parser.FunctionName = mfilename;
parser.CaseSensitive = false;
parser.KeepUnmatched = false;
parser.StructExpand = true;

parser.addRequired('A', @(x) validateattributes (x, {'numeric'}, ...
    {'2d', 'square', 'nonempty', 'nonnan', 'finite'}, mfilename, 'A'));
parser.addRequired('B', @(x) validateattributes (x, {'numeric'}, ...
    {'2d', 'square', 'nonempty', 'nonnan', 'finite'}, mfilename, 'A'));

parser.parse(A, B);

[ra, ca] = size (A);
[rb, cb] = size (B);

%% Compute the matrix

M = kron (A, speye (rb, cb)) + kron (speye (ra, ca), B);

end
