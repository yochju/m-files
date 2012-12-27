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
% pos : either 'first' or 'last'. (case insensitive, default = 'first')
%
% Output parameters:
%
% p : position of the best approximation to x inside V. (scalar)
%
% Output parameters (optional):
%
% -
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
% p = FindBestPosition(V, x, 'last')
%
% yields p = 5;
%
% p = FindBestPosition( (1:10)', [2.1 3.2 8.9])
%
% yields p = [2 3 9]
%
% See also interp1.

% Copyright 2011, 2012 Laurent Hoeltgen <laurent.hoeltgen@gmail.com>
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

% Last revision: 27.12.2012 17:25

%% Check Input and Output Arguments

narginchk(2,3);
nargoutchk(0,1);

parser = inputParser;
parser.FunctionName = mfilename;
parser.CaseSensitive = false;
parser.KeepUnmatched = true;
parser.StructExpand = true;

parser.addRequired('V', @(x) validateattributes(x, {'numeric'}, {}, ...
    mfilename, 'V'));
parser.addRequired('x', @(x) validateattributes(x, {'numeric'}, {}, ...
    mfilename, 'x'));
parser.addOptional('pos', 'first', @(x) strcmpi(x, validatestring(x, ...
    {'first', 'last'})));

parser.parse(V, x, varargin{:});
opts = parser.Results;

%% Run code.

% Use nearest neighbor interpolation to find best approximation inside V.
temp = unique(opts.V);
p = interp1(temp,1:length(temp) , opts.x , 'nearest', 'extrap');

% Extract position of best approximation.
nearest = @(x) find( opts.V==temp(x) , 1 , lower(opts.pos) );
p = arrayfun(nearest, p);

end
