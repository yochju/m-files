function [x, varargout] = LinSolvePDHG(A, b, varargin)
%% Solve linear system with PDHG Algorithm
%
% [x, flag, relres, iter, resvec] = LinSolvePDHG(A, b, tol, maxit, x0, mode, 
%                                                param)
%
% Input parameters (required):
%
% A : system matrix. (2D array)
% b : Righthand side of the linear system. (double array)
%
% Input parameters (parameters):
%
% Parameters are either struct with the following fields and corresponding
% values or option/value pairs, where the option is specified as a string.
%
% tol   : tolerance limit. Algorithm aborts when relative residual is below tol.
%         (scalar, default = 1e-10);
% maxit : maximal number of iterations. (scalar, default = 1000)
% x0    : initial value for the iterative scheme. (array, default = A'*b)
% mode  : which scheme should be used. Choices are 'plain' (standard scheme),
%         'adaptive' (like 'plain' but with adaptive stepsizes) and
%         'precondition' (like adaptive but with componentwise adaptive
%         stepsizes). (string, default = 'plain').
% param : parameters for the different modes. param should be a structure with
%         the following fields:
%         param.L     : estimate for the norm of A (default found through
%                       normest(A))
%         param.tau   : step size. (default = 1)
%         param.theta : extrapolation parameter. (plain and adaptive mode). Must
%                       be between 0 and 1. (default = 1)
%         param.gamma : scaling parameter for the adaptive steps. (adaptive
%                       mode) Must be between 0 and 1. (default = 1)
%         param.alpha : scaling parameter for the adaptive steps. (precondition
%                       mode) Must be between 0 and 2. (default = 1)
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
% x : Minimiser of 0.5*||A*x-b||_2^2.
%
% Output parameters (optional):
%
% flag   : flag indicating the stopping resaon. 0 means the suggested tolerance
%          was reached. 1 indicates the maximum number of iterates was reached.
% relres : relative residual of the final solution.
% iter   : number of iterations performed.
% resvec : residual vector.
%
% Description:
%
% Uses the PDHG algorithm of Pock and Chambolle for solving the linear system
% Ax=b. For more information on the algorithm, consider:
%
% Diagonal preconditioning for first order primal-dual algorithms in convex
% optimization, Thomas Pock and Antonin Chambolle, 2011
% A First-Order Primal-Dual Algorithm for Convex Problems with Applications to
% Imaging, Antonin Chambolle and Thomas Pock, 2011
%
% Example:
%
% A = rand(100,100);
% b = rand(100,1);
% x = LinSolvePDHG(A,b);
%
% See also mldivide

% Copyright 2013 Laurent Hoeltgen <laurent.hoeltgen@gmail.com>
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

% Last revision on: 07.04.2013 11:30

%% Notes

%% Parse input and output.

narginchk(2,6);
nargoutchk(0,5);

parser = inputParser;
parser.FunctionName = mfilename;
parser.CaseSensitive = false;
parser.KeepUnmatched = true;
parser.StructExpand = true;

parser.addRequired('A', @(x) validateattributes(x, {'numeric'}, ...
    {'2d', 'nonempty', 'finite'}, mfilename, 'A', 1));
parser.addRequired('b', @(x) validateattributes(x, {'numeric'}, ...
    {'column', 'numel', size(A,2), 'nonempty', 'finite'}, mfilename, 'b', 2));

parser.addParamValue('tol', 1e-10, @(x) validateattributes(x, ...
    {'numeric'}, {'scalar', 'nonempty', 'finite', 'nonnegative'}, ...
    mfilename, 'tol'));
parser.addParamValue('maxit', 1000, @(x) validateattributes(x, ...
    {'numeric'}, {'scalar', 'nonempty', 'finite', 'nonnegative', 'integer'}, ...
    mfilename, 'maxit'));
parser.addParamValue('x0', transpose(A)*b, @(x) validateattributes(x, ...
    {'numeric'}, {'column', 'numel', size(A,1), 'nonempty', 'finite'}, ...
    mfilename, 'x0'));
parser.addParamValue('mode', 'plain', @(x) strcmpi(validatestring(x, ...
    {'plain', 'adaptive', 'precondition'}, mfilename, 'mode'), x));
parser.addParamValue('param', struct([]), @(x) validateattributes(x, ...
    {'struct'}, {}, mfilename, 'param'));

parser.parse( A, b, varargin{:});
opts = parser.Results;

%% Run code.

% Set up the parameters for the iterative scheme.

ExcM = ExceptionMessage('Input', 'message', 'Invalid parameter specification.');

if isfield(opts.param,'theta')
        theta = opts.param.theta;
        assert(isscalar(theta), ExcM.id, ExcM.message);
        assert((theta>=0)&&(theta<=1), ExcM.id, ExcM.message);
else
    theta = 1.0;
end

x = opts.x0;
xbar = opts.x0;
y = zeros(size(b));

if ~strcmp(opts.mode,'precondition')
    % Handle plain and adaptive cases.
    if isfield(opts.param,'L')
        L = opts.param.L;
        assert(isscalar(L), ExcM.id, ExcM.message);
    else
        L = normest(A,1e-3);
    end
    if isfield(opts.param,'tau')
        tau = opts.param.tau;
        assert(isscalar(tau), ExcM.id, ExcM.message);
        assert(tau>0, ExcM.id, ExcM.message);
    else
        tau = 1;
    end
    sigma = 1.0/(tau*L^2+0.01);
    if strcmp(opts.mode,'adaptive')
        if isfield(opts.param,'gamma')
            gamma = opts.param.gamma;
            assert(isscalar(gamma), ExcM.id, ExcM.message);
            assert((gamma<=1)&&(gamma>=0), ExcM.id, ExcM.message);
        else
            gamma = 1.0;
        end
    end
else
    % Setup the preconditioning matrices (we just store the diagonal entries).
    if isfield(opts.param, 'alpha')
        alpha = opts.param.alpha;
        assert(isscalar(alpha), ExcM.id, ExcM.message);
        assert((alpha<=2)&&(alpha>=0), ExcM.id, ExcM.message);
    else
        alpha = 1.0;
    end
    K = abs(A);
    % If a row or column sum is 0, we have to prevent a division by 0. At the
    % moment we set those entries back to 1. I'm not sure this is the optimal
    % choice. The references don't mention this case.
    col0 = sum(K,1)<100*eps;
    row0 = sum(K,2)<100*eps;
    tau = 1./sum(K.^(2-alpha),1);
    tau(col0) = 1;
    tau = tau(:);
    sigma = 1./sum(K.^alpha,2);
    sigma(row0) = 1;
end

for i = 1:opts.maxit
    if norm(A*x-b) < (opts.tol)*norm(b)
        break;
    end
    % Note that the next lines work for scalar and matrix valued sigma and tau.
    y = (1+sigma).\(y + sigma.*(A*xbar-b));
    xold = x;
    x = x - tau.*(transpose(A)*y);
    if strcmp(opts.mode,'adaptive')
        theta = 1/sqrt(1+2*gamma*sigma);
        tau = tau/theta;
        sigma = sigma*theta;
    end
    xbar = x + theta*(x-xold);
end

% Handle the output data.
% TODO.
end

