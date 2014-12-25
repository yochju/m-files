function [u c p] = FindMaskDual(f, lambda, varargin)

% Copyright 2014 Laurent Hoeltgen <laurent.hoeltgen@gmail.com>
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

%% Check Input and Output

narginchk(2,22);
nargoutchk(0,8);

parser = inputParser;
parser.FunctionName = mfilename;
parser.CaseSensitive = false;
parser.KeepUnmatched = true;
parser.StructExpand = true;

parser.addRequired('f',      @(x) validateattributes(x, {'numeric'}, {'nonempty','finite'},                        mfilename, 'f',      1));
parser.addRequired('lambda', @(x) validateattributes(x, {'numeric'}, {'scalar','nonempty','finite','nonnegative'}, mfilename, 'lambda', 2));

parser.addParamValue('mu',       1.25,          @(x) validateattributes(x, {'numeric'}, {'scalar', 'nonempty', 'finite', 'nonnegative'},            mfilename, 'mu'));
parser.addParamValue('e',        1e-4,          @(x) validateattributes(x, {'numeric'}, {'scalar', 'nonempty', 'finite', 'nonnegative'},            mfilename, 'e'));
parser.addParamValue('maxit',    1,             @(x) validateattributes(x, {'numeric'}, {'scalar', 'nonempty', 'finite', 'nonnegative', 'integer'}, mfilename, 'maxit'));
parser.addParamValue('cInit',    ones(size(f)), @(x) validateattributes(x, {'numeric'}, {'nonempty','finite'},                                      mfilename, 'cInit'));
parser.addParamValue('PockIt',   25000,         @(x) validateattributes(x, {'numeric'}, {'scalar', 'nonempty', 'finite', 'nonnegative'},            mfilename, 'PockIt'));
parser.addParamValue('PockTol',  1e-12,         @(x) validateattributes(x, {'numeric'}, {'scalar', 'nonempty', 'finite', 'nonnegative'},            mfilename, 'PockTol'));

parser.parse( f, lambda, varargin{:});
opts = parser.Results;

%% Initialisation

[ro co] = size(f);
D       = LaplaceM(ro,co);
N       = ro*co;
I       = speye(N, N);
c       = inf(ro,co);
i       = 1;
cbar    = opts.cInit;

%% Run Code.

while i <= opts.maxit
    fprintf(1,'Iteration: %d',i);
    
    if ((norm(c(:)-cbar(:), 2) < 1e-15) && (i > 1))
        break;
    end
    
    %% - Iterate -------------------------------------------------------- %%
    
    % - Set up current position for Taylor expansion. -------------------- %
    
    % Note that in any case, the pairs (ubar, cbar) and (u, c) will always
    % be feasible solutions of the initial PDE.
    if i == 1
        %% - Start with a full mask. ------------------------------------ %%
        
        M    = spdiags(ToVec(cbar), 0, N, N) - (I - spdiags(ToVec(cbar), 0, N, N))*D;
        ubar = ToIm(M\ToVec(ToIm(cbar,ro,co).*f),ro,co);
        
    else
        %% - Take mask and solution from previous iteration. ------------ %%
        
        cbar = c;
        ubar = u;
        
    end
    
    % - Compute operators occuring in the optimisation -------------------- %
    
    % T(u,c) = c(u-f) - (1-c)*D*u
    % T(u,c) = T(ubar,cbar) + D_uT(ubar,cbar)(u-ubar) + D_cT(ubar,cbar)(c-cbar)
    
    % T(ubar,cbar) = 0
    % A = D_uT(ubar,cbar) = cbar - (1-cbar)*D
    % B = D_cT(ubar,cbar) = ubar-f+D*ubar
    % g = D_uT(ubar,cbar)ubar + D_cT(ubar,cbar)*cbar = cbar*(I+D)*ubar
    
    % Note that A is the inpainting matrix.
    % A = C - (I-C)*D;
    A = spdiags(ToVec(cbar), 0, N, N) - (I - spdiags(ToVec(cbar), 0, N, N))*D;
    
    % B = u - f + D*u;
    bb = ToVec(ubar-f) + smvp(D,ToVec(ubar));
    
    % g = c*(I+D)*u
    g = ToVec(cbar) .* smvp(( I + D ),ToVec(ubar));
    
    % - Solve optimisation problem to get new mask ----------------------- %
    
    [p pval pg numIts] = solvedual(A, bb, ToVec(f), ToVec(ubar), ToVec(cbar), g, ...
        opts.lambda, opts.mu, opts.e, 500);
%     fh = @(p) funGradh3(p, A, bb, ToVec(f), ToVec(ubar), ToVec(cbar), g, ...
%         opts.lambda, opts.mu, opts.e);
%     options = optimset( ...
%         'Display', 'iter-detailed');
%     [p, pval, eflag, outp, outg] = fminunc(fh, 0*bb(:), options);

    % [u c] = solveKKT(p, A, bb, ToVec(f), ToVec(ubar), g, opts.mu);
    [u c] = solveKKT(p, A, bb, ToVec(f), ToVec(ubar), ToVec(cbar), g, opts.mu, opts.e, opts.lambda);
    %% - Compute solution corresponding to new mask. --------------------- %
    
    if norm(c(:)) < 100*eps
        % If c is 0, no need to compute a solution u. It must be 0.
        u = zeros(size(c));
    else
        % Compute solution.
        M = spdiags(c, 0, N, N) - (I - spdiags(c, 0, N, N))*D;
        u = M\ToVec(ToIm(c,ro,co).*f);
    end
    
    % Increase iteration count.
    i = i+1;
    
    u  = ToIm(u,ro,co);
    c  = ToIm(c,ro,co);
end
end

function vec = ToVec(im)
t = im';
vec = t(:);
end

function im = ToIm(vec,r,c)
im = reshape(vec,c,r)';
end

function [f] = funGradh3(p, A, B, f, ub, cb, g, l, m, e)
f = h3(p,A, B, f, ub, cb, g, l, m, e);
g = nablah3(p,A, B, f, ub, cb, g, l, m, e);
end

