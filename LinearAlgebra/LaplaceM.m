function M = LaplaceM(r,c,varargin)
%% Returns the matrix corresponding to the Laplace operator.
%
% M = KroneckerSum(A,B)
%
% Computes the matrix corresponding to the Laplace operator. The discretisation
% is based on separable finite difference schemes (which can be specified
% through the options). The returned matrix is sparse. Boundary conditions can
% be specified through optional parameters. Accepted values are 'Neumann' or
% 'Dirichlet'.
%
% Input Parameters (required):
%
% r : number of rows of the signal. (positive integer)
% c : number of columns of the signal. (positive integer)
%
% Input Parameters (pairs), (optional):
%
% 'KnotsR'    : knots to consider for the row discretisation of the second
%               derivative, e.g. x-derivative. (array of integers) (default
%               [-1,0,1])
% 'KnotsC'    : knots to consider for the column discretisation of the second
%               derivative, e.g. y-derivative. (array of integers) (default
%               [-1,0,1])
% 'GridSizeR' : size of the grid for rows. (positive double) (default = 1.0)
% 'GridSizeR' : size of the grid for columns. (positive double) (default = 1.0)
% 'Boundary'  : boundary condition. (string) (default = 'Neumann')
% 'Tolerance' : tolerance when checking the consistency order. (default 100*eps)
%
% Output Parameters
%
% M : Matrix of the corresponding scheme. (sparse matrix)
%
% Example
%
% Remarks
%
% The implementation assumes that the points are number row-wise. This is in
% conflict with the standard numbering scheme in MATLAB, which runs column-wise
% over a matrix.
% TODO: implement an option to make this behavior changeable.
%
% See also DiffFilter1DM.

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

% Last revision: 02.10.2012 12:20

%% Check input parameters

narginchk(2, 14);
nargoutchk(0, 1);

optargin = size(varargin,2);
stdargin = nargin - optargin;

assert( stdargin == 2, ...
    'LinearAlgebra:LaplaceM:BadInput', ...
    ['The first two parameters must be the number of rows and columns of ' ...
     'the signal.']);
assert( mod(optargin,2)==0, ...
    'LinearAlgebra:LaplaceM:BadInput', ...
    'Optional arguments must come in pairs.');

KnotsR = [-1 0 1];
GridSR = 1.0;
KnotsC = [-1 0 1];
GridSC = 1.0;
BoundCond = 'Neumann';
Tol = 100*eps;
for i = 1:2:optargin
    switch varargin{i}
        case 'KnotsR'
            KnotsR = varargin{i+1};
        case 'KnotsC'
            KnotsC = varargin{i+1};
        case 'GridSizeR'
            GridSR = varargin{i+1};
        case 'GridSizeC'
            GridSC = varargin{i+1};
        case 'Boundary'
            BoundCond = varargin{i+1};
        case 'Tolerance'
            Tol = varargin{i+1};
    end
end

%% Set up internal variables.

MR = FiniteDiff1DM(c, KnotsR, 2, ...
    'GridSize', GridSR, 'Boundary', BoundCond, 'Tolerance', Tol);
MC = FiniteDiff1DM(r, KnotsC, 2, ...
    'GridSize', GridSC, 'Boundary', BoundCond, 'Tolerance', Tol);
if r == 1
    M = MR;
elseif c == 1
    M = MC;
else
    M = KroneckerSum(MC,MR);
end
