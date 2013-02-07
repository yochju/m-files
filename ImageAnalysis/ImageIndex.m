function [out map] = ImageIndex(in)
%% Indexes the colors in an image.
%
% [out map] = ImageIndex(in)
%
% Input parameters (required):
%
% in : Input image to be indexed.
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
% out : indexed image.
% map : corresponding colormap.
%
% Output parameters (optional):
%
% -
%
% Description:
%
% Indexes all the colors in an image. The colors are sorted in ascending order
% and indexed starting with 1. The sorted color array is returned inside map.
% The returned image contains the indices, e.g. the color in out(out==i)
% corresponds to map(i).
%
% Example:
%
% I = rand(256,256);
% J = ImageQuantization(I,128);
% [out map] = ImageIndex(I);
%
% See also ImageRestore, ImageQuantization

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

% Last revision on: 07.02.2013 11:00

%% Notes

%% Parse input and output.

narginchk(1,1);
nargoutchk(0,2);

parser = inputParser;
parser.FunctionName = mfilename;
parser.CaseSensitive = false;
parser.KeepUnmatched = true;
parser.StructExpand = true;

parser.addRequired('in', @(x) validateattributes( x, {'numeric'}, ...
    {'2d', 'finite', 'nonempty', 'nonnan', 'nonsparse'}, ...
    mfilename, 'in', 1) );

parser.parse(in);

%% Run code.		       
		       
map = sort(unique(in));
out = in;
for i = 1:numel(map)
    out(in==map(i)) = i;
end

end
