function out = ImagePyramid(in, varargin)
%% Resizes an input image to different scales.
%
% out = ImagePyramid( in, varargin )
%
% Input parameters (required):
%
% in : input image (matrix).
%
% Input parameters (optional):
%
% Optional parameters are either struct with the following fields and
% corresponding values or option/value pairs, where the option is specified as a
% string.
%
% scaling   : the scaling factor for the individual numbers. Can be any
%             nonnegative real valued number. If larger than 1, the images will
%             become bigger. For factors smaller than 1, they become smaller.
%             Default value is 0.5.
% maxScales : the maximal number of scales to be computed. Restricts the number
%             of scales to be computed. This is especially useful in combination
%             with scaling factors larger than 1. The default value is 128,
%             which allows to compute a full pyramid with scaling 0.95 of an
%             512x512 pixel image.
% method    : A string specifying the interpolation value to be used. The
%             possible values coincide with those from imresize, e.g. they are
%             'nearest', 'bilinear', 'bicubic'. The default method is bicubic.
%
% Output parameters:
%
% out : A cell array containing the rescaled images.
%
% Description:
%
% The method computes the same image at different resolution levels using a
% specified interpolation method.
%
% Example:
%
% ImagePyramid(rand(512,512),'scaling', 0.98, 'maxScales', 25);
%
% See also imresize, interp2, impyramid

% Copyright 2012, 2013 Laurent Hoeltgen <laurent.hoeltgen@gmail.com>
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

% Last revision on: 24.04.2013 09:45

%% Check Input and Output Arguments

% asserts that there's at least 1 input parameter.
narginchk(1, max(nargin,0));
nargoutchk(0, 1);

parser = inputParser;
parser.FunctionName = mfilename;
parser.CaseSensitive = false;
parser.KeepUnmatched = true;
parser.StructExpand = true;

parser.addRequired('in', @(x) validateattributes( x, {'numeric'}, ...
    {'2d', 'finite', 'nonempty', 'nonnan'}, ...
    mfilename, 'in', 1) );

parser.addParamValue('scaling', 0.5, @(x) validateattributes( x, ...
    {'numeric'}, {'finite', 'nonnegative', 'real' 'nonempty', 'scalar'}, ...
    mfilename, 'scaling'));

parser.addParamValue('maxScales', 128, @(x) validateattributes( x, ...
    {'numeric'}, {'positive', 'nonempty', 'integer', 'scalar'}, ...
    mfilename, 'maxScales'));

parser.addParamValue('method', 'bicubic', @(x) strcmpi(x, validatestring( x, ...
    {'nearest', 'bilinear', 'bicubic'}, mfilename, 'method') ) );

parser.parse(in,varargin{:});
opts = parser.Results;

%% Algorithm

% Determine the maximal number of levels and initialize output. Note, that the
% smallest side determines the maximal number of scales that could be computed
% since we have a lower bound of 1px.
[nr nc] = size(in);
n = min([nr nc]);

% We need to discern 2 cases. If the scaling is smaller than 1, we solve the
% equation n*s^q = 1 for q. This gives us the number of levels that we can
% compute. If the scaling is larger than one, the equation yields negative
% solutions and becomes useless. Since in that case we could compute infinitely
% many levels anyway, we just stop once we have attained maxScales.
if opts.scaling < 1
    out = cell(1,min(opts.maxScales,floor(log(1/n)/log(opts.scaling))));
else
    out = cell(1,opts.maxScales);
end

% Compute the different scalings using imresize.
for k = 1:length(out)
    out{k} = imresize(in, opts.scaling^(k-1), opts.method);
end
end
