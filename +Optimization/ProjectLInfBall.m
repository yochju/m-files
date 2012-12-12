function w = ProjectLInfBall(v, varargin)
%% Projects point onto L-Infinity ball of specified radius.
%
% w = ProjectLInfBall(v, r)
%
% Input parameters (required):
%
% v : vector to be projected.
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
% r : radius of the ball to be projected on.
%
% Output parameters:
%
% w : projection on the L-Infinity Ball.
%
% Output parameters (optional):
%
% -
%
% Description:
%
% Returns the vector w which is the solution to the following constrained
% minimization problem:
%
%  argmin_w ||w - v||_2 such that ||w||_inf <= r.
%
% Example:
%
% -
%
% See also

% Copyright 2012 Laurent Hoeltgen <laurent.hoeltgen@gmail.com>
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

% Last revision on: 11.12.2012 20:25

%% Notes

%% Parse input and output.

narginchk(1,2);
nargoutchk(0,1);

parser = inputParser;
parser.FunctionName = mfilename;
parser.CaseSensitive = false;
parser.KeepUnmatched = true;
parser.StructExpand = true;

parser.addRequired('v', @(x) validateattributes(x, ...
    {'numeric'}, {'vector','nonempty','finite'}, mfilename, 'v', 1));
parser.addOptional('r', 1, @(x) validateattributes(x, ...
    {'numeric'}, {'scalar', 'positive', 'finite'}, mfilename, 'r', 2));

parser.parse( v, varargin{:});
opts = parser.Results;

%% Run code.

if norm(v,Inf) <= opts.r
    w = v;
else
    w = zeros(size(v));
    w(find(v==min(v),1,'first')) = opts.r;
end

end

