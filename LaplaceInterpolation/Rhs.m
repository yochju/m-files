function out = Rhs(in, varargin)
%% Computes the righthand side of the discretised PDE.
%
% out = Rhs(f, ...)
%
% Input parameters (required):
%
% in : Righthand side of the equation. (array)
%
% Input parameters (parameters):
%
% Parameters are either struct with the following fields and corresponding
% values or option/value pairs, where the option is specified as a string.
%
% mask   : Set of known (fuzzy) data points. (array, default = zeros(size(in)))
% ml     : lower bound. See description. (scalar, default = 0)
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
% out : The righthand side corresponding to the discretised PDE. (array)
%
% Output parameters (optional):
%
% -
%
% Description:
%
% Returns (c-m).*in, the righthand side corresponding to the PDE for Laplace
% interpolation.
%
% Example:
%
% -
%
% See also

% Copyright 2012, 2015 Laurent Hoeltgen <laurent.hoeltgen@gmail.com>
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

% Last revision on: 23.06.2015 10:40

%% Notes

%% Parse input and output.

narginchk(1, 5);
nargoutchk(0, 1);

parser = inputParser;
parser.FunctionName = mfilename;
parser.CaseSensitive = false;
parser.KeepUnmatched = true;
parser.StructExpand = true;

parser.addRequired('in', @(x) validateattributes(x, {'numeric'}, ...
    {'2d', 'finite', 'nonnan'}, mfilename, 'in'));

parser.addParameter('mask', zeros(size(in)), @(x) validateattributes(x, ...
    {'numeric'}, {'2d', 'finite', 'nonnan', 'size', size(in)}, ...
    mfilename, 'mask'));

parser.addParameter('ml', 0, @(x) validateattributes(x, {'numeric'}, ...
    {'scalar', 'finite', 'nonnan'}, mfilename, 'ml'));

parser.parse(in, varargin{:})
opts = parser.Results;

MExc = ExceptionMessage('Input', 'message', ...
    'Size of mask and input data must coincide.');
assert(isequal(size(in),size(opts.mask)), MExc.id, MExc.message);

%% Run code.

out = (opts.mask-opts.ml).*in;

end
