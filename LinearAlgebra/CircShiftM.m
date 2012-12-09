function V = CircShiftM(n, varargin)
%% Returns the circular shift matrix of order n.
%
% V = CircShiftM(n, p)
%
% Input parameters (required):
%
% n : Size of the matrix. (positive integer)
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
% p : amount of positions to shift. (integer, default = 1)
%
% Output parameters:
%
% V : The circular shift matrix of order n. (sparse matrix)
%
% Output parameters (optional):
%
% -
%
% Description:
%
% The circular shift matrix of order n performs a shift on a given vector with a
% circular wrap around. Shifts can be to the left (positive values of p) or to
% the right (negative values of p).
%
% Example:
%
% n = 4;
% V = CircShiftM(n);
%
% See also circshift

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

% Last revision: 04.12.2012 21:45

%% Notes.

%% Check Input/Output parameters.

narginchk(1, 2);
nargoutchk(0, 1);

parser = inputParser;
parser.FunctionName = mfilename;
parser.CaseSensitive = false;
parser.KeepUnmatched = true;
parser.StructExpand = true;

parser.addRequired('n', @(x) validateattributes(x, {'numeric'}, ...
    {'scalar', 'integer', 'positive'}, mfilename, 'n'));

parser.addOptional('p', 1, @(x) validateattributes(x, {'numeric'}, ...
    {'scalar', 'integer'}, mfilename, 'p'));

parser.parse(n, varargin{:});
opts = parser.Results;

%% Run code.

p = mod(opts.p,n);
V = sparse(1:n, [(p+1):n, 1:p], ones(1,n), n, n);

end
