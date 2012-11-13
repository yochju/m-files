function [d varargout] = ForwardBackwardSplitting(B, x, lambda, varargin)
%% Forward backward splitting
%
% d = ForwardBackwardSplitting(B, x, lambda, varargin)
%
% Input parameters (required):
%
% B      : matrix in front of the unknown in the quadratic term. (matrix)
% x      : additive constant in the quadratic term. (vector)
% lambda : positive weight in front of the L_1 term. (positive scalar)
%
% Input parameters (optional):
%
% Optional parameters are either struct with the following fields and
% corresponding values or option/value pairs, where the option is specified as a
% string.
%
% maxit : maximal number of iterations. Default is 1. (scalar)
% tau   : step size for the iterations. Default is 1.95/sigma^2 where sigma is
%         the largest eigenvalue of B. Note, that the theoretical limit is
%         2/sigma^2 (not included).
% tol   : tolerance limit. Iterations stop when distance between two iterates
%         becomes smaller than this value. Default is 1e-8. (scalar)
%
% Output parameters:
%
% d : solution vector. (vector)
%
% Output parameters (optional):
%
% it  : number of performed iterations.
% tol : distance between the last and second last iterate.
%
% Description:
%
% Solves the optimization problem:
%
% argmin_{d} lambda*||d||_1 + 1/2*||B*d-x||^2 with lambda > 0.
%
% Example:
%
%
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

% Last revision on: 13.11.2012 16:00

%% Parse input and output.

narginchk(3, 9);
nargoutchk(0, 3);

parser = inputParser;
parser.FunctionName = mfilename;
parser.CaseSensitive = false;
parser.KeepUnmatched = true;
parser.StructExpand = true;

parser.addRequired('B', ...
    @(x) validateattributes(x, {'numeric'}, ...
    {'2d', 'nonempty', 'nonnan', 'finite'}, ...
    mfilename, 'B'));

parser.addRequired('x', ...
    @(x) validateattributes(x, {'numeric'}, ...
    {'vector', 'nonempty', 'nonnan', 'finite'}, ...
    mfilename, 'x'));

parser.addRequired('lambda', ...
    @(x) validateattributes(x, {'numeric'}, ...
    {'scalar', 'nonempty', 'nonnan', 'finite'}, ...
    mfilename, 'lambda'));

parser.addParamValue('maxit', 1, ...
    @(x) validateattributes(x, {'numeric'}, ...
    {'scalar', 'nonempty', 'nonnan', 'finite'}, ...
    mfilename, 'maxit'));

parser.addParamValue('tau', 1.95./eigs(B,1)^2, ...
    @(x) validateattributes(x, {'numeric'}, ...
    {'scalar', 'nonempty', 'nonnan', 'finite'}, ...
    mfilename, 'tau'));

parser.addParamValue('tol', 1e-8, ...
    @(x) validateattributes(x, {'numeric'}, ...
    {'scalar', 'nonempty', 'nonnan', 'finite'}, ...
    mfilename, 'tol'));

parser.parse(B, x, lambda, varargin{:})
opts = parser.Results;


%% Run code.

d_old = inf(size(x(:)));
d = x(:);
i = 1;

while (i <= opts.maxit) && (norm(d-d_old,2) > opts.tol)
    d_old = d;
    d = Optimization.SoftShrinkage( ...
        lambda*opts.tau*ones(size(d(:))), ...
        1, ...
        ones(size(d(:))), ...
        d(:) - opts.tau*B'*(B*d(:)-x(:)) );
    i = i+1;
end

switch nargout
    case 2
        varargout{1} = i;
    case 3
        varargout{1} = i;
        varargout{2} = norm(d-d_old,2);
end

end
