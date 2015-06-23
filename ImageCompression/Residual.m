function out = Residual(u, c, f, varargin)
%% Computes residual of a solution (squared l2 norm).
%
% out = Residual(u, c, f, varargin)
%
% Input parameters (required):
%
% u : (potential) reconstruction. (double array)
% c : mask indicating the positions where the dirichlet data should be applied.
%     (double array of same size as u)
% f : Dirichlet boundary data. (double array of same size as u and c)
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
% out : Residual of the equation c*(u-f)-(1-c)*D*u = 0 where D is the Laplace
%       operator.
%
% Description:
%
% Computes the residual in the squared l2 norm of the equation
% c*(u-f)-(1-c)*D*u = 0 where D is the Laplace operator.
%
% Example:
% u = rand(100,100);
% c = double(rand(100,100) > 0.6);
% f = rand(100,100);
% s = Residual(u, c, f);
%
% See also EvalPde

% Copyright 2012, 2015 Laurent Hoeltgen <laurent.hoeltgen@gmail.com>
%
% This program is free software; you can redistribute it and/or modify it
% under the terms of the GNU General Public License as published by the Free
% Software Foundation; either version 3 of the License, or (at your option)
% any later version.
%
% This program is distributed in the hope that it will be useful, but
% WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY
% or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public License
% for more details.
%
% You should have received a copy of the GNU General Public License along
% with this program; if not, write to the Free Software Foundation, Inc., 51
% Franklin Street, Fifth Floor, Boston, MA 02110-1301, USA.

% Last revision on: 23.06.2015 10:45

narginchk(3, 7);
nargoutchk(0, 1);

parser = inputParser;
parser.FunctionName = mfilename;
parser.CaseSensitive = false;
parser.KeepUnmatched = true;
parser.StructExpand = true;

parser.addRequired('u', @(x) ismatrix(x));
parser.addRequired('c', @(x) ismatrix(x));
parser.addRequired('f', @(x) ismatrix(x));

parser.addParameter('threshData', nan, @(x) isscalar(x));
parser.addParameter('thrDataMin', 0, @(x) isscalar(x));
parser.addParameter('thrDataMax', 1, @(x) isscalar(x));

parser.addParameter('threshDiff', nan, @(x) isscalar(x));
parser.addParameter('thrDiffMin', 0, @(x) isscalar(x));
parser.addParameter('thrDiffMax', 1, @(x) isscalar(x));

parser.parse(u, c, f, varargin{:})
opts = parser.Results;

% TODO: Add error string.
assert( isequal( size(opts.f), size(opts.u), size(opts.c) ) );

out = norm( EvalPde(opts.f, opts.u, opts.c, opts), 2)^2;
end
