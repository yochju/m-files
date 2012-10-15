function out = ImageHess( in, varargin )
%% Short description.
%
% out = ImageHess( in, varargin )
%
% Input parameters (required):
%
% in : input image (matrix)
%
% Input parameters (optional):
%
% Optional parameters are either struct with the following fields and
% corresponding values or option/value pairs, where the option is specified as a
% string.
% xSettings  : either a structure or a cell array containing the optional
%              parameters that will be passed to ImageDxx to compute the 2nd x
%              derivative of the input image.
% ySettings  : either a structure or a cell array containing the optional
%              parameters that will be passed to ImageDyy to compute the 2nd y
%              derivative of the input image.
% xySettings : either a structure or a cell array containing the optional
%              parameters that will be passed to ImageDxy to compute the mixed
%              derivative of the input image.
%
% Output parameters:
%
% out : n x m x 2 x 2 array containing the derivatives, where n and m are the
%       dimensions of the input image.
%
% Description:
%
% Computes the Hessian of an input signal at each point using a finite
% difference scheme.
%
% Example:
%
% I = rand(512,256)
% xSettings.scheme = 'scharr';
% ySettings = { 'scheme', 'backward', 'gridSize', [1.5 1.5] };
% xySettings = struct([]);
% ImageGrad(I, xSettings, ySettings, xySettings)
%
% See also ImageDxx, ImageDyy, ImageDxy, ImageLapl

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

% Last revision on: 30.04.2012 07:01

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

parser.addParamValue('xSettings', struct([]), @(x) isstruct(x)||iscell(x) );
parser.addParamValue('ySettings', struct([]), @(x) isstruct(x)||iscell(x) );
parser.addParamValue('xySettings', struct([]), @(x) isstruct(x)||iscell(x) );

parser.parse(in,varargin{:});
opts = parser.Results;

%% Algorithm

[nr nc] = size(in);
out = zeros(nr,nc,2,2);
out(:,:,1,1) = ImageDxx(in,opts.xSettings);
out(:,:,1,2) = ImageDxy(in,opts.xySettings);
out(:,:,2,1) = ImageDxy(in,opts.xySettings);
out(:,:,2,2) = ImageDyy(in,opts.ySettings);

end
