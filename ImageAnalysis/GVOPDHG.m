function [x, flag, relres, iter, resvec] = GVOPDHG(M, C, f, varargin)
%% Solves the gray value optimisation problem for PDE based inpainting.
%
% [x, flag, relres, iter, resvec] = GVOPDHG(M, C, f, tol, maxit, x0, mode, 
%                                           param)
%
% Input parameters (required):
%
% M : Inpainting matrix. (2D array)
% C : Mask. (2D array)
% f : Image. (double array)
%
% Input parameters (parameters):
%
% Parameters are either struct with the following fields and corresponding
% values or option/value pairs, where the option is specified as a string.
%
% tol   : tolerance limit. Algorithm aborts when relative residual is below tol.
%         (scalar, default = 1e-10);
% maxit : maximal number of iterations. (scalar, default = 1000)
% x0    : initial value for the iterative scheme. (array, default = C*f)
% mode  : which scheme should be used. Choices are 'plain' (standard scheme),
%         and 'precondition' (like adaptive but with componentwise adaptive
%         stepsizes). (string, default = 'plain').
% param : parameters for the different modes. param should be a structure with
%         the following fields:
%         param.L     : estimate for the norm of [M -C] (default found through
%                       normest([M -C]))
%         param.tau   : step size. (default = 1)
%         param.theta : extrapolation parameter. (plain mode). Must
%                       be between 0 and 1. (default = 1)
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
% x      : Minimiser of 0.5*||M\(C*x)-f||_2^2.
% flag   : flag indicating the stopping resaon. 0 means the suggested tolerance
%          was reached. 1 indicates the maximum number of iterates was reached.
% relres : relative residual of the final solution.
% iter   : number of iterations performed.
% resvec : residual vector.
%
% Output parameters (optional):
%
% -
%
% Description:
%
% Uses the PDHG algorithm of Pock and Chambolle for solving the gray value
% optimization problem for PDE-based inpainting. See:
%
% Diagonal preconditioning for first order primal-dual algorithms in convex
% optimization, Thomas Pock and Antonin Chambolle, 2011
% A First-Order Primal-Dual Algorithm for Convex Problems with Applications to
% Imaging, Antonin Chambolle and Thomas Pock, 2011
%
% Example:
%
% -
%
% See also lsqr

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

% Last revision on: 07.04.2013 21:00

%% Notes

%% Parse input and output.

narginchk(2,6);
nargoutchk(0,5);

parser = inputParser;
parser.FunctionName = mfilename;
parser.CaseSensitive = false;
parser.KeepUnmatched = true;
parser.StructExpand = true;

parser.addRequired('M', @(x) validateattributes(x, {'numeric'}, ...
    {'2d', 'nonempty', 'finite'}, mfilename, 'M', 1));
parser.addRequired('C', @(x) validateattributes(x, {'numeric'}, ...
    {'2d', 'nonempty', 'finite'}, mfilename, 'C', 2));
parser.addRequired('f', @(x) validateattributes(x, {'numeric'}, ...
    {'column', 'numel', size(A,1), 'nonempty', 'finite'}, mfilename, 'f', 3));

parser.addParamValue('tol', 1e-10, @(x) validateattributes(x, ...
    {'numeric'}, {'scalar', 'nonempty', 'finite', 'nonnegative'}, ...
    mfilename, 'tol'));
parser.addParamValue('maxit', 1000, @(x) validateattributes(x, ...
    {'numeric'}, {'scalar', 'nonempty', 'finite', 'nonnegative', 'integer'}, ...
    mfilename, 'maxit'));
parser.addParamValue('x0', C*f, @(x) validateattributes(x, ...
    {'numeric'}, {'column', 'numel', size(A,1), 'nonempty', 'finite'}, ...
    mfilename, 'x0'));
parser.addParamValue('mode', 'plain', @(x) strcmpi(validatestring(x, ...
    {'plain', 'precondition'}, mfilename, 'mode'), x));
parser.addParamValue('param', struct([]), @(x) validateattributes(x, ...
    {'struct'}, {}, mfilename, 'param'));

parser.parse( M, C, f, varargin{:});
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
d = zeros(size(x));
y = zeros(size(x));

if ~strcmp(opts.mode,'precondition')
    % Handle plain case.
    if isfield(opts.param,'L')
        L = opts.param.L;
        assert(isscalar(L), ExcM.id, ExcM.message);
    else
        L = normest([M -C],1e-3);
    end
    if isfield(opts.param,'tau')
        tau = opts.param.tau;
        assert(isscalar(tau), ExcM.id, ExcM.message);
        assert(tau>0, ExcM.id, ExcM.message);
    else
        tau = 1;
    end
    sigma = 1.0/(tau*L^2+0.01);
else
    % Setup the preconditioning matrices (we just store the diagonal entries).
    if isfield(opts.param, 'alpha')
        alpha = opts.param.alpha;
        assert(isscalar(alpha), ExcM.id, ExcM.message);
        assert((alpha<=2)&&(alpha>=0), ExcM.id, ExcM.message);
    else
        alpha = 1.9;
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
    tauM = tau(1:numel(f));
    tauC = tau((numel(f)+1):end);
    sigma = 1./sum(K.^alpha,2);
    sigma(row0) = 1;
end

flag = 1;
for iter = 1:opts.maxit
    resvec = M\(C*x)-f;
    relres = norm(resvec)/norm(f);
    if relres < opts.tol
        flag = 0;
        break;
    end
    % Note that the next lines work for scalar and matrix valued sigma and tau.
    y = y + sigma.*(M*dbar-C*xbar);
    xold = x;
    dold = d;
    x = x + tauC.*(C*y);
    d = (1 + tauM).\(d - tauM*(transpose(M)*y-f));
    xbar = x + theta*(x-xold);
    dbar = d + theta*(d-dold);
end

end

