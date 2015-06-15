function out = Binarize(in, thresh, varargin)
%% Binarizes given input data.
%
% out = Binarize(in, thresh, ...)
%
% % Input parameters (required):
%
% in     : Data to be thresholded.
% thresh : Threshold to be applied. If set to nan, no thresholding will be
%          performed.
%
% Input parameters (optional):
%
% Optional parameters are either struct with the following fields and
% corresponding values or option/value pairs, where the option is specified as a
% string.
%
% min : value at which entries below the threshold should be set to. If nan, the
%       values will remain untouched. (default = 0)
% max : value at which entries above the threshold should be set to. If nan, the
%       values will remain untouched.
%
% Output parameters:
%
% out : The thresholded data.
%
% Description:
%
% Thresholds a given data set such that all the values below the specified limit
% are set to a given lower bound and all the values above the limit will be set
% to a given upper bound. Leaving certain values untouched can be achieved by
% specifying the corresponding parameters as nan. Note that lower bound is
% checked with "<=" whereas the upper bound will use ">".
%
% Example:
% in = [ 0 1 2 3 4 5 6 ];
% Binarize(in, 3, 'min', -1, 'max', 10) returns [-1 -1 -1 -1 10 10 10]
% Binarize(in, 3, 'max', nan) returns [0 0 0 0 4 5 6]
%
% See also Threshold, max, min

% Copyright 2012, 2015 Laurent Hoeltgen <laurent.hoeltgen@gmail.com>
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

% Last revision on: 15.06.2015 16:26

narginchk(2, 6);
nargoutchk(0, 1);

parser = inputParser;
parser.FunctionName = mfilename;
parser.CaseSensitive = false;
parser.KeepUnmatched = true;
parser.StructExpand = true;

% Note: isscalar(nan) as well as isDouble(nan) evaluate to true.
parser.addRequired('in', @(x) ismatrix(x));
parser.addRequired('thresh', @(x) isscalar(x));

parser.addParameter('min', 0, @(x) isscalar(x));
parser.addParameter('max', 1, @(x) isscalar(x));

parser.parse(in, thresh, varargin{:})
opts = parser.Results;

% This could be done in a more efficient way, but the formulation below allows
% to set the thresholding to 'nan' and to leave the values untouched since
% x > nan as well as x < nan always evaluate to false. Furthermore, setting min
% or max to 'nan' will leave the values below (resp. above) the threshold at
% their original value.
out = opts.in;
out( logical( (out <= thresh) .* ~isnan(opts.min) ) ) = opts.min;
out( logical( (out >  thresh) .* ~isnan(opts.max) ) ) = opts.max;

end
