function mask = FindAbsSmallest(M,k)
%% Finds the k smallest elements in absolute value in the given array.
%
% mask = FindAbsSmallest(M,k)
%
% Input parameters (required):
%
% M : array to be searched.
% k : number of entries to be searched.
%
% Input parameters (parameters):
%
% -
%
% Output Parameters
%
% mask : binary mask, where true indicates a position.
%
% Output parameters (optional):
%
% -
%
% Example
%
% M = [1 2 3 4 ; 9 8 7 5 ; 9 8 9 4 ];
% k = 3;
% mask = FindAbsSmallest(M,k);
%
% See also FindLargest, FindSmallest, FindAbsLargest

% Copyright 2012, 2103 Laurent Hoeltgen <laurent.hoeltgen@gmail.com>
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

% Last revision: 2013-07-05 17:04

%% Comments and Remarks.

%% Parse Input.

narginchk(2,2);
nargoutchk(0,1);

parser = inputParser;
parser.FunctionName = mfilename;
parser.CaseSensitive = false;
parser.KeepUnmatched = true;
parser.StructExpand = true;

parser.addRequired('M', @(x) validateattributes(x, {'numeric'}, ...
    {'nonempty', 'finite'}, mfilename, 'M', 1));

parser.addRequired('k', @(x) validateattributes(x, {'double'}, ...
    {'scalar', 'integer', 'positive'}, mfilename, 'k', 2));

parser.parse( M, k);
opts = parser.Results;

%% Perform computation

sortedValues = unique(abs(opts.M(:)));
minValues = sortedValues(1:opts.k);
mask = ismember(opts.M, minValues);

end
