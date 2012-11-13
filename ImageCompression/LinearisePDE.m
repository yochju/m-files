function [Du Dc] = LinearisePDE(f, u, c, varargin)
%% Compute first order approximation to Laplace Equation
%
% out = LinearisePDE(f, u, c, ...)
%
% Input parameters (required):
%
% f : Dirichlet boundary data. (double array)
% u : (potential) reconstruction. (double array of same size as f)
% c : mask indicating the positions where the dirichlet data should be applied.
%     (double array of same size as f)
%
% Input parameters (optional):
%
% Optional parameters are either struct with the following fields and
% corresponding values or option/value pairs, where the option is specified as a
% string.
%
% Output parameters:
%
% Du : Jacobian with respect to u. (array)
% Dc : Jacobian with respect to c. (array)
%
% Description:
%
% Considers the following nonlinear function
%
% T(u,c) := c.*(u-f) - (1-c).*(u_xx + u_yy)
%
% which corresponds to the Laplace equation with mixed (Robin-) boundary
% conditions in case of a binary valued c if it is solved with a righthand side
% of 0. Positions where c == 1, will represent Dirichlet boundary conditions and
% positions where c == 0, will be the domain where the PDE should be solved.
% Computes a linear approximation of T in the point (u,c).
%
% T(x,y) = T(u,c) + Du(u,c)(x-u,y-c) + Dc(u,c)(x-u,y-c)
%
% Example:
%
%
% See also Mask, PdeM, Residual, Rhs, SolvePde

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

% Last revision on: 02.10.2012 12:19

narginchk(3, 7);
nargoutchk(0, 1);

parser = inputParser;
parser.FunctionName = mfilename;
parser.CaseSensitive = false;
parser.KeepUnmatched = true;
parser.StructExpand = true;

parser.addRequired('f', @(x) ismatrix(x)&&IsDouble(x));
parser.addRequired('u', @(x) ismatrix(x)&&IsDouble(x));
parser.addRequired('c', @(x) ismatrix(x)&&IsDouble(x));

parser.parse(f, u, c, varargin{:})
opts = parser.Results;

ExcM = ExceptionMessage('Input');
assert( ...
    isequal(size(opts.f),size(opts.u),size(opts.c)), ...
    ExcM.id, ExcM.message );

[row col] = size(opts.u);

% TODO: make passing of options more flexible.
% NOTE: the correct call would be LaplaceM(row, col, ...), however this assumes
% that the data is labeled row-wise. The standard MATLAB numbering is
% column-wise, therefore, we switch the order of the dimensions to get the
% (hopefully) correct behavior.
D = LaplaceM(col, row, ...
    'KnotsR',[-1 0 1],'KnotsC',[-1 0 1], ...
    'Boundary', 'Neumann');

Du = Mask(c) + (speye(numel(c),numel(c)) - Mask(c))*D;
Dc = spdiags( u(:) - f(:) + D*u(:) , 0 , numel(u), numel(u) );

end
