function out = ImageRestore(in,map)
%% Recovers an indexed image based on a given colormap.
%
% [out map] = ImageIndex(in)
%
% Input parameters (required):
%
% in  : Input image to be restored.
% map : Colormap to be used.
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
% -
%
% Output parameters:
%
% out : Restored image.
%
% Output parameters (optional):
%
% -
%
% Description:
%
% Restores an indexed image using the provided colormap. The indices are 1
% based, e.g. the smallest index should be 1. The returned image satisfies
% out(in==i)=map(i) for all i.
%
% Example:
%
% ImageRestore([1 2 3 4 5 6],[0 0.1 0.3 0.2 0.4 1.0]);
%
% See also ImageIndex, ImageQuantization

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

% Last revision on: 07.02.2013 11:15

%% Notes

%% Parse input and output.

narginchk(2,2);
nargoutchk(0,1);

parser = inputParser;
parser.FunctionName = mfilename;
parser.CaseSensitive = false;
parser.KeepUnmatched = true;
parser.StructExpand = true;

parser.addRequired('in', @(x) validateattributes( x, {'numeric'}, ...
    {'2d', 'finite', 'nonempty', 'nonnan', 'nonsparse'}, ...
    mfilename, 'in', 1) );

parser.addRequired('map', @(x) validateattributes( x, {'numeric'}, ...
    {'vector', 'finite', 'nonempty', 'nonnan', 'nonsparse', ...
    'numel', numel(unique(in))}, mfilename, 'map', 1) );

parser.parse(in,map);

%% Run code.

out = in;
for i = 1:numel(map)
    out(in==i) = map(i);
end

end
