function out = ImageDiv( in, varargin )
%% Computes the divergence of an input image.
%
% out = ImageDiv( in, varargin )
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
% xSettings : either a structure or a cell array containing the optional
%             parameters that will be passed to ImageDx to compute the x
%             derivative of the input image.
% ySettings : either a structure or a cell array containing the optional
%             parameters that will be passed to ImageDy to compute the y
%             derivative of the input image.
%
% Output parameters:
%
% out : array containing the divergence of the input image.
%
% Description:
%
% Computes the divergence of an input signal pointwise using a finite difference
% scheme.
%
% Example:
%
% I = rand(512,256)
% xSettings.scheme = 'scharr';
% ySettings = { 'scheme', 'backward', 'gridSize', [1.5 1.5] };
% ImageDiv(I, xSettings, ySettings)
%
% See also ImageDx, ImageDy, ImageGrad

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

parser.addParamValue('xSettings', struct([]), @(x) isstruct(x)||iscell(x) );
parser.addParamValue('ySettings', struct([]), @(x) isstruct(x)||iscell(x) );

parser.parse(in,varargin{:});
opts = parser.Results;

%% Algorithm

out = ImageDx(in,opts.xSettings) + ImageDy(in,opts.ySettings);

end
