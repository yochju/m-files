function locations = stencilmask(stencil, data, pos)
%% Compute valid mask entries that lie inside the domain
%
% Compute valid mask entries for a specified position. Position may be outside
% of the domain
%
% locations = stencilmask(stencil, data, pos)
%
% Mandatory Parameters:
%
% stencil: array containing the size of the stencil
% data:    array containing the size of the data array   
% pos:     scalar integer indicating current position
%
% Optional Parameters:
%
% -
%
% Output Parameters:
%
% locations: coloumn array of booleans indicating valid mask positions
%
% Example
%
% stencilmask([3], [5], 1)
%
% returns [false; true; true] and this means that for at position 1 the valid
% entries for the convolution are positioned at 0 and 1. 
%
% See also stencillocs

% Copyright (c) 2016 Laurent Hoeltgen <hoeltgen@b-tu.de>
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

% Last revision: 2016-05-17 15:00

%% Parse input and output.

narginchk(3, 3);
nargoutchk(0, 1);

parser               = inputParser;
parser.FunctionName  = mfilename;
parser.KeepUnmatched = false;
parser.StructExpand  = false;

% Parse mandatory arguments

parser.addRequired('stencil', ...
    @(x) validateattributes(x, ...
    {'double'}, ...
    {'vector', 'nonempty', 'nonsparse', 'integer', 'positive'}, ...
    mfilename, 'stencil', 1));

parser.addRequired('data', ...
    @(x) validateattributes(x, ...
    {'double'}, ...
    {'vector', 'nonempty', 'nonsparse', 'integer', 'positive'}, ...
    mfilename, 'data', 2));

parser.addRequired('pos', ...
    @(x) validateattributes(x, ...
    {'double'}, ...
    {'scalar', 'integer'}, ...
    mfilename, 'pos', 3));


parser.parse(stencil, data, pos);

%% Run Code

locations = (0 < mexstencilmask(stencil, data, pos));