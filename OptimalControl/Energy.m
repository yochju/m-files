function E = Energy(u, c, f, varargin)
%% Energy functional considered for interpolation with optimal knot sites
%
% E = Energy(u, c, f, ...)
%
% Input parameters (required):
%
% u : image reconstruction (double array).
% c : mask (double array).
% f : initial image (double array).
%
% Input parameters (parameters):
%
% Parameters are either struct with the following fields and corresponding
% values or option/value pairs, where the option is specified as a string.
%
% lambda  : regularisation weight for the L1 term of the mask.
%           (positive scalar, default = 1.0)
% epsilon : regularisation weight for the L2 term of the mask.
%           (nonnegative scalar, default = 1e-3)
% mu      : proximal weight used inside the linearised steps. (nonnegative
%           scalar, default = 0)
% d       : righthand side for the proximal term. (array, default =
%           zeros(size(c))
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
% E : The energy corresponding to the input variables, that is
%     0.5*||u-f||_2^2 + lambda*||c||_1 + epsilon/2*||c||^2_2 + mu/2*||c-d||_2
%
% Output parameters (optional):
%
% -
%
% Description:
%
% Evaluates the energy that we consider in this optimal control framework for
% determining optimal data sites with homegeneous diffusion.
%
% Example:
% u = rand(100,100);
% c = double(rand(100,100) > 0.6);
% f = rand(100,100);
% l = 0.73;
% E = Energy(u,c,f,'lambda',l);
%
% See also norm.

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

% Last revision on: 16.06.2015 13:56

%% Notes

%% Parse input and output.

narginchk(3, 11);
nargoutchk(0, 1);

parser = inputParser;
parser.FunctionName = mfilename;
parser.CaseSensitive = false;
parser.KeepUnmatched = true;
parser.StructExpand = true;

parser.addRequired('u', @(x) validateattributes(x, {'numeric'}, ...
    {'vector'}, mfilename, 'u', 1));
parser.addRequired('c', @(x) validateattributes(x, {'numeric'}, ...
    {'vector', 'size', size(u)}, mfilename, 'c', 1));
parser.addRequired('f', @(x) validateattributes(x, {'numeric'}, ...
    {'vector', 'size', size(c)}, mfilename, 'f', 1));

parser.addParameter('lambda', 1.0, @(x) validateattributes(x, ...
    {'numeric'}, {'scalar','nonempty','finite','positive'}, ...
    mfilename, 'lambda'));
parser.addParameter('epsilon', 1e-3, @(x) validateattributes(x, ...
    {'numeric'}, {'scalar','nonempty','finite','nonnegative'}, ...
    mfilename, 'epsilon'));
parser.addParameter('mu', 0.0, @(x) validateattributes(x, ...
    {'numeric'}, {'scalar','nonempty','finite','nonnegative'}, ...
    mfilename, 'mu'));
parser.addParameter('d', zeros(size(c)), @(x) validateattributes(x, ...
    {'numeric'}, {'vector', 'size', size(c), 'finite','nonnegative'}, ...
    mfilename, 'd'));

parser.parse(u, c, f, varargin{:});
opts = parser.Results;

%% Run code.

E = 0.5 * norm(u(:)-f(:),2)^2 + ...
    opts.lambda * norm(c(:), 1)/2 + ...
    opts.epsilon * norm(c(:), 2)^2/2 + ...
    opts.mu * norm(c(:)-opts.d(:), 2)^2/2;

end
