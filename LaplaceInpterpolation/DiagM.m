function M = DiagM(v)
%% Returns a sparse matrix with input on its diagonal.
%
% M = DiagM(v)
%
% Input parameters (required):
%
% v : data to be placed on the diagonal. The entries follow standard matlab
%     numbering. (double array)
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
% M : sparse matrix containing the data in v on its diagonal.
%
% Output parameters (optional):
%
% -
%
% Description:
%
% Returns a sparse matrix with input on its diagonal.
%
% Example:
%
% v = rand(10,6,2);
% M = DiagM(v);
%
% See also spdiags, sparse

% Copyright 2012 Laurent Hoeltgen <laurent.hoeltgen@gmail.com>
%
% This program is free software; you can redistribute it and/or modify it
% under the terms of the GNU General Public License as published by the Free
% Software Foundation; either version 3 of the License, or (at your option)
% any later version.
%
% This program is distributed in the hope that it will be useful, but
% WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY
% or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public License
% for more details.
%
% You should have received a copy of the GNU General Public License along
% with this program; if not, write to the Free Software Foundation, Inc., 51
% Franklin Street, Fifth Floor, Boston, MA 02110-1301, USA.

% Last revision on: 30.12.2012 16:40

%% Notes

%% Parse input and output.

narginchk(1, 1);
nargoutchk(0, 1);

parser = inputParser;
parser.FunctionName = mfilename;
parser.CaseSensitive = false;
parser.KeepUnmatched = true;
parser.StructExpand = true;

parser.addRequired('v', @(x) validateattributes(x, {'numeric'}, ...
    {'nonsparse', 'nonnan', 'finite'}, mfilename, 'v'));

parser.parse(v)

%% Run code.

M = spdiags( v(:), 0, numel(v), numel(v));

end
