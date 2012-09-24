function out = Rhs(c,f, varargin)
%% Computes the righthand side of the discretised pde linear system.
%
% out = Rhs(c, f, ...)
%
% Input parameters (required):
%
% f : image data for the data sites. (double array)
% c : mask indicating the positions where the dirichlet data should be applied.
%     (double array)
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
%
% Output parameters:
%
% out : Righthand side of the PDE system, e.g. c.*f.

% Copyright 2012 Laurent Hoeltgen <laurent.hoeltgen@gmail.com>
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

% Last revision on: 24.09.2012 17:45

narginchk(2, 8);
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

parser.parse(c, f, varargin{:})
opts = parser.Results;

cData = Binarize(c, opts.threshData, ...
    'thrDataMin',opts.thrDataMin, ...
    'thrDataMax',opts.thrDataMax );

out = cData.*opts.f(:);
end
