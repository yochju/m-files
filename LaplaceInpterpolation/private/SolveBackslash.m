function u = SolveBackslash(in)
%% Solves Laplace Interpolation with the backslash operator.
%
% u = SolveBackslash(in)
%
% Input parameters (required):
%
% in : struct containing all the data passed to LaplaceInterpolation.m
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
% u : Laplace interpolated function.
%
% Output parameters (optional):
%
% -
%
% Description:
%
% Performs Laplace interpolation by solving the occuring linear system with the
% backslash operator. This function should not be used by itself, rather call
% LaplaceInterpolation.
%
% Example:
%
% -
%
% See also LaplaceInterpolation

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

narginchk(1, 1);
nargoutchk(1, 1);

parser = inputParser;
parser.FunctionName = mfilename;
parser.CaseSensitive = false;
parser.KeepUnmatched = true;
parser.StructExpand = true;

parser.addRequired('in', @(x) validateattributes(x, ...
    {'struct'}, {'scalar'}, mfilename, 'in'));
parser.parse(in);

%% Run code.

A = PdeM(in.mask, 'ml', in.ml, 'mu', in.mu);
b = Rhs(in.in, 'mask', in.mask, 'ml', in.ml);
u = mldivide(A,b);
		       
end
