function p = FindBestPosition(V, x, varargin)
%% Find closest match inside a given vector.
%
% p = FindBestPosition(V, x, ...)
%
% Input parameters (required):
%
% V : vector to be searched (array)
% x : value to be found. (scalar)
%
% Input parameters (optional):
%
% pos : either 'first' or 'last'. (case insensitive, default = 'first')
%
% Output parameters:
%
% p : position of the best approximation to x inside V. (scalar)
%
% Description:
%
% Looks for the best approximation of the scalar x inside the vector V and
% returns by default the position of the first occurence. This behaviour can
% be overriden by providing a third parameter which may be either 'first' or
% 'last' to return the respective occurence.
%
% Example:
%
% V = [ 0 0 1 2 2 3 4 5 ];
% x = 2.1;
% p = FindBestPosition(V,x,'first')
%
% yields p = 4;
%
% p = FindBestPosition(V,x,'last')
%
% yields p = 5;
%
% See also FindBestPositionq, interp1.

% Copyright 2011,2012 Laurent Hoeltgen <laurent.hoeltgen@gmail.com>
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

% Last revision: 05.09.2012 17:02

%% Check Input and Output Arguments

narginchk(2,3);
nargoutchk(0,1);

parser = inputParser;
parser.FunctionName = mfilename;
parser.CaseSensitive = false;
parser.KeepUnmatched = true;
parser.StructExpand = true;

parser.addRequired('V', @(x) ismatrix(x));
parser.addRequired('x', @(x) isscalar(x));
parser.addOptional('pos','first',@(x) any(strcmpi(x,{'first','last'})));

parser.parse(V,x,varargin{:});
opts = parser.Results;

% Use nearest neighbor interpolation to find best approximation inside V.
temp = unique(opts.V);
p = interp1(temp,1:length(temp) , opts.x , 'nearest','extrap');
% Extract position of best approximation.
p = find( opts.V==temp(p) , 1 , lower(opts.pos) );

end
