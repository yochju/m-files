function out = PdeM(c, varargin)
%% System Matrix for Laplace interpolation
%
% out = PdeM(c, ...)
%
% Input parameters (required):
%
% c : Set of known (fuzzy) data points. (array)
%
% Input parameters (parameters):
%
% Parameters are either struct with the following fields and corresponding
% values or option/value pairs, where the option is specified as a string.
%
% ml       : Lower bound. See description. (scalar, default = 0)
% mu       : Upper bound. See description. (scalar, default = 1)
% optsLapl : Options to be passed to LaplaceM. (struct, default = struct())
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
% Constructs the Matrix that corresponds to the finite difference discretisation
% of the following linear PDE
%
% (c-m).*(u-f) - (M-c).*D*u = 0
%
% which corresponds to the Laplace equation with mixed (Robin-) boundary
% conditions in case of a binary valued c if it is solved with a righthand side
% of 0. Positions where c == 1, will represent Dirichlet boundary conditions and
% positions where c == 0, will be the domain where the PDE should be solved.
% Note that the outer boundaries (unless specified through c) will be modelled
% with Neumann Boundary conditions. If c contains arbitrary values between 0 and
% 1, the above model can be considered to be a fuzzy mixed boundary value
% problem where c acts as the fuzzy indicator. Values for c outside of the
% interval [0,1] are allowed. Their interpretation is left to the user. The mask
% for the interpolation sites can be binarized independently for the data term
% and for the differential term. The binarization is being done with the
% Binarize function.
%
% Example:
%
% c = double(rand(100,100) > 0.6);
% PdeM(c);
%
% See also EvalPde, SolvePde, LaplaceM

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

% Last revision on: 23.06.2015 10:30

%% Notes

%% Parse input and output.

narginchk(1, 7);
nargoutchk(0, 1);

parser = inputParser;
parser.FunctionName = mfilename;
parser.CaseSensitive = false;
parser.KeepUnmatched = true;
parser.StructExpand = true;

parser.addRequired('c', @(x) validateattributes(x, ...
    {'numeric'}, {'2d', 'finite', 'nonnan'}, ...
    mfilename, 'c'));

parser.addParameter('ml', 0, @(x) validateattributes(x, {'numeric'}, ...
    {'scalar', 'finite', 'nonnan'}, mfilename, 'ml'));

parser.addParameter('mu', 1, @(x) validateattributes(x, {'numeric'}, ...
    {'scalar', 'finite', 'nonnan'}, mfilename, 'mu'));

parser.addParameter('optsLapl', struct(), @(x) validateattributes(x, ...
    {'struct'}, {}));

parser.parse(c, varargin{:})
opts = parser.Results;

%% Run code.

% NOTE: the correct call would be LaplaceM(row, col, ...), however this assumes
% that the data is labeled row-wise. The standard MATLAB numbering is
% column-wise, therefore, we switch the order of the dimensions to get the
% (hopefully) correct behavior.

[row, col] = size(opts.c);
D = LaplaceM(col, row, opts.optsLapl);
out = spdiags( c(:)-opts.ml, 0, numel(c), numel(c)) - ...
    spdiags( opts.mu - c(:), 0, numel(c), numel(c))*D;

end
