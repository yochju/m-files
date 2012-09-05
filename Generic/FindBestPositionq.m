function p = FindBestPositionq(V, x, varargin)
%% Find closest match inside a given vector.
%
% p = FindBestPositionq(V, x, ...)
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
% Output paramaters:
%
% p : position of the best approximation to x inside V. (scalar)
%
% Description:
%
% Looks for the best approximation of the scalar x inside the vector V and
% returns by default the position of the first occurence. This behaviour can be
% overriden by providing a third parameter which may be either 'first' or 'last'
% to return the respective occurence. This version is faster than
% FindBestPosition. However, no error checking is being performed for the
% interpolation step. Furthermore, the behaviour of the two methods is not
% identical for values of x outside of the convex hull of V. FindBestPositionq
% ignores the third parameter when extrapolation is being done. This method is
% not recommended. Use with care.
%
% Example:
%
% V = [ 0 0 1 2 2 3 4 5 ];
% x = 2.1;
% p = FindBestPositionq(V,x,'first')
%
% yields p = 4;
%
% p = FindBestPositionq(V,x,'last')
%
% yields p = 5;
%
% See also FindBestPosition, interp1q.

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

% Last revision: 05.09.2012 16:10

%% Check number of input and output arguments.

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

% Note the the extrapolation case is being handled differently than for
% FindBestPosition.
if x >= max(opts.V)
    p = length(opts.V);
elseif x <= min(opts.V)
    p = 1;
else
    temp = unique(opts.V);
    p = round(interp1q(temp, (1:length(temp))' , opts.x ));
    p = find( V==temp(p) , 1 , lower(opts.pos) );
end
end
