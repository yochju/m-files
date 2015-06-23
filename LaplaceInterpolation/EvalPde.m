function out = EvalPde(f, u, varargin)
%% Evaluates Laplace equation with mixed boundary conditions.
%
% out = EvalPde(f, u, ...)
%
% Input parameters (required):
%
% f : Data used for the interpolation. (array)
% u : Test solution for the PDE. (array)
%
% Input parameters (parameters):
%
% Parameters are either struct with the following fields and corresponding
% values or option/value pairs, where the option is specified as a string.
%
% mask   : Set of known (fuzzy) data points. (array, default = zeros(size(in)))
% m      : lower bound. See description. (scalar, default = 0)
% M      : upper bound. See description. (scalar, default = 1)
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
% out : array containing the pointwise evaluation of the PDE.
%
% Output parameters (optional):
%
% -
%
% Description:
%
% Evaluates the following PDE for given f, u and mask c:
%
% (c-m).*(u-f) - (M-c).*D*u
%
% which corresponds to the Laplace equation with mixed (Robin-) boundary
% conditions in case of a binary valued c if it is solved with a righthand side
% of 0. Positions where c == 1, will represent Dirichlet boundary conditions and
% positions where c == 0, will be the domain where the PDE should be solved.
% Note that the outer boundaries (unless specified through c) will be modelled
% with Neumann Boundary conditions. If c contains arbitrary values between 0 and
% 1, the above model can be considered to be a fuzzy mixed boundary value
% problem where c acts as the fuzzy indicator. Values for c outside of the
% interval [0,1] are allowed. Their interpretation is left to the user. The data
% inside the mask can be thresholded individually. By default, the thresholding
% is turned of. If set using the individual input parameters, values below the
% threshold will be set to
%
% Example:
% u = rand(100,100);
% c = double(rand(100,100) > 0.6);
% f = rand(100,100);
% s = EvalPde(f,u,c);
%
% See also Mask, PdeM, Residual, Rhs, SolvePde

% Copyright 2012, 2015 Laurent Hoeltgen <laurent.hoeltgen@gmail.com>
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

% Last revision on: 23.06.2015 10:45

narginchk(2, 8);
nargoutchk(0, 1);

parser = inputParser;
parser.FunctionName = mfilename;
parser.CaseSensitive = false;
parser.KeepUnmatched = true;
parser.StructExpand = true;

parser.addRequired('f', @(x) validateattributes(x, {'numeric'}, ...
    {'2d', 'finite', 'nonnan'}, mfilename, 'f'));

parser.addRequired('u', @(x) validateattributes(x, {'numeric'}, ...
    {'2d', 'finite', 'nonnan'}, mfilename, 'u'));

parser.addParameter('mask', zeros(size(f)), @(x) validateattributes(x, ...
    {'numeric'}, {'2d', 'finite', 'nonnan', 'size', size(in)}, ...
    mfilename, 'mask'));

parser.addParameter('m', 0, @(x) validateattributes(x, {'numeric'}, ...
    {'scalar', 'finite', 'nonnan'}, mfilename, 'm'));

parser.addParameter('M', 1, @(x) validateattributes(x, {'numeric'}, ...
    {'scalar', 'finite', 'nonnan'}, mfilename, 'M'));

parser.parse(f, u, varargin{:})
opts = parser.Results;

ExcM = ExceptionMessage('Input', 'message', ...
    'Data, mask and solution must have same size.');
assert( isequal( size(opts.f), size(opts.u), size(opts.mask)), ...
    ExcM.id, ExcM.message );

%% Run code.

[row, col] = size(opts.u);

% TODO: make passing of options more flexible.
% NOTE: the correct call would be LaplaceM(row, col, ...), however this assumes
% that the data is labeled row-wise. The standard MATLAB numbering is
% column-wise, therefore, we switch the order of the dimensions to get the
% (hopefully) correct behavior.

% TODO: specifying anything different from Neumann Boundary conditions is tricky
% so far. In the ideal case, This method should accept a parameter with the
% struct below as an argument which would then be passed onto LaplaceM. At the
% moment this strategy prohibits setting the Boundary treatment.
% options = struct( ...
%     'KnotsR', [-1 0 1], ...
%     'KnotsC', [-1 0 1], ...
%     'optsR', struct(), ...
%     'optsC', struct());
D = LaplaceM(col, row, ...
    'KnotsR',[-1 0 1],'KnotsC',[-1 0 1], ...
    'Boundary', 'Neumann');

out = (opts.mask - opts.m).*(u-f) ...
    - (opts.M - opts.mask).*reshape(D*u(:),row,col);

end
