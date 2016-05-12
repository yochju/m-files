function locations = stencillocs(stencil, data)
%% Compute relative positions of a (full) stencil
%
% Computes the relative linear locations inside an array that are needed for
% convolution. Does not take current position or boundaries into account.
% Assumes matlab like column-wise labelling. Works for arbitrary dimensional
% arrays.
%
% locations = stencillocs(stencil, data)
%
% Mandatory Parameters:
%
% stencil: array containing the size of the stencil
% data:    array containing the size of the data array   
%
% Optional Parameters:
%
% -
%
% Output Parameters:
%
% locations: coloumn array of integer double values containing the relative
%            shifts.
%
% Example
%
% stencillocs([3], [5])
%
% returns [-1; 0; 1] and this means that for at position k in my data array the
% corresponding entries for the convolution are positioned at k-1, k+0 and k+1. 
%
% stencillocs([3, 5], [7, 7])
%
% returns [-15; -14; -13; -8; -7; -6; -1; 0; 1; 6; 7; 8; 13; 14; 15], which
% corresponds to the relative shifts from my current position to obtain the
% respective entries.
%
% See also

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

% Last revision: 2016-05-12 14:00

%% Parse input and output.

narginchk(2, 2);
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

parser.parse(stencil, data);

%% Run Code

locations = mexstencillocs(stencil, data);