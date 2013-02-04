function out = ImageChangeRange(in, iMin, iMax, oMin, oMax, varargin)
%% Changes the range from [iMin;iMax] to [oMin;oMax] on in.
%
% out = ImageChangeRange(in, iMin, iMax, oMin, oMax, gamma)
%
% Input parameters (required):
%
% in   : Input signal.
% iMin : Minimal value of current range.
% iMax : Maximal value of current range.
% oMin : Minimal value of desired range.
% oMax : Maximal value of desired range.
%
% Input parameters (parameters):
%
% Parameters are either struct with the following fields and corresponding
% values or option/value pairs, where the option is specified as a string.
%
% -
%
% Input parameters (optional):
%
% The number of optional parameters is always at most one. If a function takes
% an optional parameter, it does not take any other parameters.
%
% gamma : exponential correction factor. (default = 1).
%
% Output parameters:
%
% out : Image with to rescaled range.
%
% Output parameters (optional):
%
% -
%
% Description:
%
% Changes the range of the image data in a linear way with a possible gamma
% correction. Note that passing vectors for the range is allowed. Then, a
% channelwise transform will be attempted.
%
% Example:
%
% -
%
% See also

% Copyright 2013 Laurent Hoeltgen <laurent.hoeltgen@gmail.com>
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

% Last revision on: 04.02.2013 20:46

%% Notes

%% Parse input and output.

narginchk(5,6);
nargoutchk(0,1);

parser = inputParser;
parser.FunctionName = mfilename;
parser.CaseSensitive = false;
parser.KeepUnmatched = true;
parser.StructExpand = true;

parser.addRequired('in', @(x) validateattributes( x, {'numeric'}, ...
    {'2d', 'finite', 'nonempty', 'nonnan', 'nonsparse'}, ...
    mfilename, 'in', 1) );

parser.addRequired('iMin', @(x) validateattributes( x, {'numeric'}, ...
    {'2d', 'finite', 'nonempty', 'nonnan'}, ...
    mfilename, 'iMin', 2) );

parser.addRequired('iMax', @(x) validateattributes( x, {'numeric'}, ...
    {'2d', 'finite', 'nonempty', 'nonnan', '<', iMin}, ...
    mfilename, 'iMax', 3) );

parser.addRequired('oMin', @(x) validateattributes( x, {'numeric'}, ...
    {'2d', 'finite', 'nonempty', 'nonnan'}, ...
    mfilename, 'oMin', 4) );

parser.addRequired('oMax', @(x) validateattributes( x, {'numeric'}, ...
    {'2d', 'finite', 'nonempty', 'nonnan', '<', oMin}, ...
    mfilename, 'oMax', 5) );

parser.addOptional('gamma', 1.0, validateattributes( x, {'numeric'}, ...
    {'scalar', 'finite', 'nonempty', 'nonnan'}, ...
    mfilename, 'gamma', 6) );

parser.parse(in, iMin, iMax, oMin, oMax, varargin{:});

%% Run code.

a = (oMax-oMin)./(iMax-iMin);
b = (iMax.*oMin-iMin.*oMax)./(iMax-iMin);
out = (a.*in+b).^gamma;

end
