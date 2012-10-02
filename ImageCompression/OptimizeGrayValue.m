function out = OptimizeGrayValue(c, f, varargin)
%% Optimize data at interpolation sites for better reconstruction.
%
% out = OptimizeGrayValue(c, f, ...)
%
% Input parameters (required):
%
% c : mask indicating the positions where the dirichlet data should be applied.
%     (double array)
% f : image data for the data sites. (double array)
%
% Input parameters (optional):
%
% Optional parameters are either struct with the following fields and
% corresponding values or option/value pairs, where the option is specified as a
% string.
%
% threshData : threshold that should be applied to the mask in front of the data
%              term (u-f). (scalar, default = nan, e.g. no thresholding).
% thrDataMin : value at which the mask for the data term should be set for
%              values below the threshold. (scalar, default = 0).
% thrDataMax : value at which the mask for the data term should be set for
%              values above the threshold. (scalar, default = 1).
% threshDiff : threshold that should be applied to the mask in front of the diff
%              term Laplace u. (scalar, default = nan, e.g. no thresholding).
% thrDiffMin : value at which the mask for the diff term should be set for
%              values below the threshold. (scalar, default = 0).
% thrDiffMax : value at which the mask for the diff term should be set for
%              values above the threshold. (scalar, default = 1).
% lsqrTol    : tolerance limit for the least squares solver. (scalar,
%              default = 1e-8)
% lsqrMaxit  : maximal number of iterations the least squares solver should do.
%              (scalar, default = 20000)
%
% Output parameters:
%
% out : Optimised gray values.
%
% Description:
%
% Optimises the data inside f in the equation
%
% c.*(u-f) - (1-c).*(u_xx + u_yy) = 0
%
% such that the corresponding reconstruction minimises the error in the least
% squares sense. Since the solution of the above Pde can be written as
%
% u = (C - (1-C)*L)^{-1}*C*f
%
% where L represents the Laplace operator we can simply solve the following
% least squares problem to get better data values for the reconstruction
%
% arg min_{g} || (C - (1-C)*L)^{-1}*C*g - f ||_2^2
%
% Note that the solution g returned by this minimisation process only contains
% the optimised gray values. In order to get the improved solution, one must
% additionnally solve the PDE another time with g as data input.
%
% Example:
% c = double(rand(100,100) > 0.6);
% f = rand(100,100);
% g = OptimizeGrayValue(c,f);
% u = SolvePde(g,c)
%
% Here, u will be the best approximation to f.
%
% See also SolvePde

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

% Last revision on: 26.09.2012 17:12

narginchk(2, 18);
nargoutchk(0, 1);

parser = inputParser;
parser.FunctionName = mfilename;
parser.CaseSensitive = false;
parser.KeepUnmatched = true;
parser.StructExpand = true;

parser.addRequired('c', @(x) ismatrix(x)&&IsDouble(x));
parser.addRequired('f', @(x) ismatrix(x)&&IsDouble(x));

parser.addParamValue('threshData', nan, @(x) isscalar(x)&&IsDouble(x));
parser.addParamValue('thrDataMin',  0,  @(x) isscalar(x)&&IsDouble(x));
parser.addParamValue('thrDataMax',  1,  @(x) isscalar(x)&&IsDouble(x));
parser.addParamValue('threshDiff', nan, @(x) isscalar(x)&&IsDouble(x));
parser.addParamValue('thrDiffMin',  0,  @(x) isscalar(x)&&IsDouble(x));
parser.addParamValue('thrDiffMax',  1,  @(x) isscalar(x)&&IsDouble(x));

parser.addParamValue('lsqrTol',        1e-8, @(x) isscalar(x)&&IsDouble(x));
parser.addParamValue('lsqrMaxit',  20000,    @(x) isscalar(x)&&IsDouble(x));

parser.parse(c, f, varargin{:})
opts = parser.Results;

M = PdeM(opts.c, opts);

cData = Binarize(opts.c, opts.threshData, ...
    'min', opts.thrDataMin, 'max', opts.thrDataMax);
C = Mask(cData);

[out, flag, relres, iter] = lsqr( ...
    M\C, opts.f(:), ...
    opts.lsqrTol, opts.lsqrMaxit, ...
    speye(size(M)), speye(size(M)), cData(:).*opts.f(:) );

out = reshape(out,size(opts.f));

if flag ~= 0
    warning('GVO:stop', 'GVO stopped with flag %g, rel. res. %g at it. %g', ...
        flag, relres, iter );
end
end
