function out = EvalPde(f, u, c, varargin)
%% Evaluates Laplace equation with mixed boundary conditions.
%
% out = EvalPde(f, u, c, ...)
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
% threshData : value at which the mask c in front of the data term (u-f) should
%              be thresholded. (default = nan, e.g. no thresholding)
% thrDataMin : value at which the mask points below threshData should be set to.
%              (default = 0).
% thrDataMax : value at which the mask points above threshData should be set to.
%              (default = 1).
% threshDiff : value at which the mask c in front of the Laplacian should be
%              thresholded. (default = nan, e.g. no thresholding)
% thrDiffMin : value at which the mask points below threshDiff should be set to.
%              (default = 0).
% thrDiffMax : value at which the mask points above threshDiff should be set to.
%              (default = 1).
%
% Output parameters:
%
% out : vector containing the pointwise evaluation of the PDE.
%
% Description:
%
% Evaluates the following PDE for given f, u and c:
%
% c.*(u-f) - (1-c).*(u_xx + u_yy)
%
% which corresponds to the Laplace equation with mixed (Robin-) boundary
% conditions in case of a binary valued c if it is solved with a righthand side
% of 0. Positions where c == 1, will represent Dirichlet boundary conditions and
% positions where c == 0, will be the domain where the PDE should be solved.
% Note that the outer boundaries (unless specified through c) will be modelled
% with Neumann Boundary conditions. If c contains arbitrary values between 0 and
% 1, the above model can be considered to be a fuzzy mixed boundary value
% problem where c acts as the fuzzy indicator. Values for c outside of the
% interval [0,1] are allowed. Their interpretation is left to the user. The data
% inside the mask can be thresholded individually. By default, the thresholding
% is turned of. If set using the individual input parameters, values below the
% threshold will be set to
%
% Example:
% u = rand(100,100);
% c = double(rand(100,100) > 0.6);
% f = rand(100,100);
% s = EvalPde(f,u,c);
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

% Last revision on: 21.09.2012 15:30

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

parser.addParamValue('threshData', nan, @(x) isscalar(x)&&IsDouble(x));
parser.addParamValue('thrDataMin', 0, @(x) isscalar(x)&&IsDouble(x));
parser.addParamValue('thrDataMax', 1, @(x) isscalar(x)&&IsDouble(x));

parser.addParamValue('threshDiff', nan, @(x) isscalar(x)&&IsDouble(x));
parser.addParamValue('thrDiffMin', 0, @(x) isscalar(x)&&IsDouble(x));
parser.addParamValue('thrDiffMax', 1, @(x) isscalar(x)&&IsDouble(x));

parser.parse(f, u, c, varargin{:})
opts = parser.Results;

% TODO: Add error string.
assert(isequal(size(opts.f),size(opts.u),size(opts.c)));

[row col] = size(u);

% TODO: make passing of options more flexible.
D = LaplaceM(row, col, ...
    'KnotsR',[-1 0 1],'KnotsC',[-1 0 1], ...
    'Boundary', 'Neumann');

% TODO: this will fail for 2D data sets.
cData = Binarize(opts.c, opts.threshData, ...
    'min', opts.thrDataMin, ...
    'max', opts.thrDataMax);

cDiff = Binarize(opts.c, opts.threshDiff, ...
    'min', opts.thrDiffMin, ...
    'max', opts.thrDiffMax);

% TODO: rewrite this as not to require the matrix construction.
out = cData.*(u(:)-f(:)) - (1 - cDiff).*(D*u(:));

end
