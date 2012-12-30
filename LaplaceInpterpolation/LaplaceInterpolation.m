function [out, varargout] = LaplaceInterpolation(in, varargin)
%% Performs Laplace interpolation 
%
% [out, varargout] = LaplaceInterpolation(in, varargin)
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
% m      : lower bound. See description. (scalar, default = 0)
% M      : upper bound. See description. (scalar, default = 1)
% solver : Which solving strategy should be used for the occuring linear system.
%          (char array, default = backslash)
% oSolv  : If applicable, options that should be passed to the solver. (struct,
%          default = struct())
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
% -
%
% Output parameters (optional):
%
% -
%
% Description:
%
% Solves the following partial differential equation.
%
% (c - m).*(u - f) + (M - c).*(-D).*u = 0
%
% where D is the Laplace operator, m and M two constants, c a mask indicating
% the certainity that a data point is known, f the given data and u the sought
% unknown solution.
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

% Last revision on: 30.12.2012 19:10

%% Notes

%% Parse input and output.

narginchk(,);
nargoutchk(,);

parser = inputParser;
parser.FunctionName = mfilename;
parser.CaseSensitive = false;
parser.KeepUnmatched = true;
parser.StructExpand = true;

parser.addRequired('in', @(x) validateattributes(x, {'numeric'}, ...
    {'2d', 'finite', 'nonnan'}, mfilename, 'in'));

parser.addParamValue('mask', zeros(size(in)), @(x) validateattributes(x, ...
    {'numeric'}, {'2d', 'finite', 'nonnan', 'size', size(in)}, ...
    mfilename, 'mask'));

parser.addParamValue('m', 0, @(x) validateattributes(x, {'numeric'}, ...
    {'scalar', 'finite', 'nonnan'}, mfilename, 'm'));

parser.addParamValue('M', 1, @(x) validateattributes(x, {'numeric'}, ...
    {'scalar', 'finite', 'nonnan'}, mfilename, 'M'));

parser.addParamValue('solver', 'backslash', @(x) strcmpi(x, ...
    validatestring( x, {'backslash', 'GaussSeidel', 'Jacobi', 'Parabolic', ...
    'FED', 'MultiGrid', 'lsqr'}, mfilename, 'solver')));

parser.addParamValue('oSolv', struct(), @(x) validateattributes(x, ...
    {'struct'}, {'scalar'}, mfilename, 'oSolv'));

parser.parse(in, varargin{:})
opts = parser.Results;

MExc = ExceptionMessage('Input', 'message', ...
    'Size of mask and input data must coincide.');
assert(isequal(size(in),size(opts.mask)), MExc.id, MExc.message);

%% Run code.

switch opts.solver
    case 'backslash'
        out = SolveBackslash(opts);
    case 'lsqr'
        out = SolveLSQR(opts);
end
		       
end
