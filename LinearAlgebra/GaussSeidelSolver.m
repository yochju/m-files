function [x, varargout] = GaussSeidelSolver(A, b, varargin)
%% Gauß Seidel solver for linear systems.

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

% Last revision on: 11.11.2012 21:00

%% Parse input.

narginchk(2, 16);
nargoutchk(1, 5);

parser = inputParser;
parser.FunctionName = mfilename;
parser.CaseSensitive = false;
parser.KeepUnmatched = true;
parser.StructExpand = true;

% System Matrix
parser.addRequired('A', ...
    @(x) validateattributes(x, {'single', 'double'}, ...
    {'2d', 'nonempty', 'nonnan', 'finite'}, ...
    mfilename, 'A'));

% Righthand side. Can be a matrix too.
parser.addRequired('b', ...
    @(x) validateattributes(x, {'single', 'double'}, ...
    {'2d', 'nonempty', 'nonnan', 'finite'}, ...
    mfilename, 'b'));

% Initial guess. If non is specified we initialise with 0.
parser.addParamValue('x0', [], ...
    @(x) validateattributes(x, {'single', 'double'}, ...
    {'2d', 'nonempty', 'nonnan', 'finite', 'size', size(b)}, ...
    mfilename, 'x0'));

% Tolerance threshold for the relative residual.
parser.addParamValue('tol', 1e-10, ...
    @(x) validateattributes(x, {'numeric'}, ...
    {'scalar', 'real', 'finite', 'nonnegative'}, ...
    mfilename, 'tol'));

% Maximal number of iterations.
parser.addParamValue('maxit', 1, ...
    @(x) validateattributes(x, {'numeric'}, ...
    {'scalar', 'integer', 'finite', 'nonnegative'}, ...
    mfilename, 'maxit'));

% Relaxation parameter.
parser.addParamValue('relax', 1.0, ...
    @(x) validateattributes(x, {'numeric'}, ...
    {'scalar', 'real', 'nonnegative', '<=', 2.0}, ...
    mfilename, 'relax'));

% Preconditioning Matrix. (Left preconditioner)
parser.addParamValue('M1', [], ...
    @(x) validateattributes(x, {'single', 'double'}, ...
    {'2d', 'nonempty', 'nonnan', 'finite', 'size', size(A)}, ...
    mfilename, 'M1'));

% Preconditioning Matrix. (Right preconditioner)
parser.addParamValue('M2', [], ...
    @(x) validateattributes(x, {'single', 'double'}, ...
    {'2d', 'nonempty', 'nonnan', 'finite', 'size', size(A)}, ...
    mfilename, 'M2'));

% Check whether method will converge. As this can be very slow, it is turned off
% by default.
parser.addParamValue('check', false, ...
    @(x) validateattributes(x, {'logical'}, ...
    {'scalar'}, mfilename, 'check'));

parser.parse(A, b, varargin{:})
opts = parser.Results;

%% Initialise data.

if ~isempty(opts.x0)
    x = opts.x0;
else
    x = zeros(size(opts.b));
end

if ~isempty(opts.M1)
    A = M1*A;
    b = M2*b;
end
if ~isempty(opts.M2)
    A = A*M2;
end

flag   = 0;
it     = 1;
resvec = A*x-b;
relres = sqrt(sum(resvec.^2))./sqrt(sum(x.^2));

D = A-spdiags(zeros(size(A,1),1),0,A);
U = triu(A, 1);
L = tril(A,-1);
S1 = (D + opts.relax*L);
S2 = (opts.relax*U + (opts.relax-1)*D);

%% Perform convergence check if desired.
if opts.check
    T = -(D+L)\U;
    r = eigs(T,1);
    if abs(r) >= 1
        ExcM = ExceptionMessage('Input','Method may not converge.');
        warning(ExcM.id,ExcM.message);
    end
    flag = -1;
end

%% Check for trivial solutions.
if max(sqrt(sum(b.^2))) < 100*eps(max(sqrt(sum(b.^2))))
    x = zeros(size(A,2),size(b,2));
    resvec = x;
    relres = 0;
    it = inf;
end

%% Perform iterations.
while ((it <= opts.maxit) && (max(relres) > opts.tol))
    x = S1\(opts.relax*b-S2*x);
    if nargout >= 3
        if ~isempty(opts.M2)
            resvec = A*(opts.M2*x)-b;
            relres = sqrt(sum(resvec.^2))./sqrt(sum((opts.M2*x).^2));
        else
            resvec = A*x-b;
            relres = sqrt(sum(resvec.^2))./sqrt(sum(x.^2));
        end
    end
    it = it + 1;
end

if ~isempty(opts.M2)
    x = opts.M2*x;
end

%% If no other errors appeared and we reached maxit, set flag accordingly.
if (it == opts.maxit) && (flag == 0)
    flag = 1;
end

%% Set output vars. Follows output order of other standard matlab solvers.

switch nargout
    case 2
        varargout{1} = flag;
    case 3
        varargout{1} = flag;
        varargout{2} = relres;
    case 4
        varargout{1} = flag;
        varargout{2} = relres;
        varargout{3} = it;
    case 5
        varargout{1} = flag;
        varargout{2} = relres;
        varargout{3} = it;
        varargout{4} = resvec;
end

end
