function [u, c, eArr] = OptContNonLinDenoise(f, g, lam, m, theta, outer, inner, V, W, varargin)
%
% Solves: argmin_{u,c} lambda/2||u-f||^2 + mu/2||c-g||^2
%         such that (c-V).*(u-f) - (W-c).*Du = 0

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

parser = inputParser;
parser.FunctionName = mfilename;
parser.CaseSensitive = false;
parser.KeepUnmatched = true;
parser.StructExpand = true;

parser.addRequired('f', @(x) validateattributes(x, {'numeric'}, ...
    {'nonempty','finite','2d'}, mfilename, 'f', 1));

parser.addRequired('g', @(x) validateattributes(x, {'numeric'}, ...
    {'nonempty','finite','2d'}, mfilename, 'g', 2));

parser.addRequired('lam', @(x) validateattributes(x, {'numeric'}, ...
    {'scalar', 'nonnegative'}, mfilename, 'lam', 3));

parser.addRequired('m', @(x) validateattributes(x, {'numeric'}, ...
    {'scalar', 'nonnegative'}, mfilename, 'm', 4));

parser.addRequired('theta', @(x) validateattributes(x, {'numeric'}, ...
    {'scalar', 'nonnegative'}, mfilename, 'theta', 5));

parser.addRequired('outer', @(x) validateattributes(x, ...
    {'double'}, {'scalar', 'integer', 'positive'}, mfilename, 'outer', 6));

parser.addRequired('inner', @(x) validateattributes(x, ...
    {'double'}, {'scalar', 'integer', 'positive'}, mfilename, 'inner', 7));

parser.addRequired('V', @(x) validateattributes(x, {'numeric'}, ...
    {'nonempty','finite','2d'}, mfilename, 'V', 8));

parser.addRequired('W', @(x) validateattributes(x, {'numeric'}, ...
    {'nonempty','finite','2d'}, mfilename, 'W', 9));

parser.addParamValue('lambda', 0.5, @(x) validateattributes(x, ...
    {'double'}, {'scalar', 'nonnegative'}, mfilename, 'lambda'));

parser.addParamValue('sigma', 0.5, @(x) validateattributes(x, ...
    {'double'}, {'scalar', 'nonnegative'}, mfilename, 'sigma'));

parser.addParamValue('diffusivity', 'charbonnier', ...
    @(x) strcmpi(x, validatestring(x, ...
    {'charbonnier', 'perona-malik', 'exp-perona-malik', ...
    'weickert', 'custom'}, mfilename, 'diffusivity')));

parser.addParamValue('diffusivityfun', @(x) ones(size(x)), ...
    @(x) validateattributes(x, {'function_handle'}, {'scalar'}, ...
    mfilename, 'diffusivityfun'));

parser.addParamValue('gradmag', struct('scheme','central'), ...
    @(x) validateattributes(x, {'struct'}, {}, mfilename, 'gradmag'));

parser.parse( f, g, lam, m, theta, outer, inner, V, W, varargin{:});
opts = parser.Results;

% Image Size and Number or pixels.
[nr nc] = size(f);
N = nr*nc;
I = speye(N,N);

% Initialise Mask and Signal somewhere in the middle.
% Unsure if this is ok or not.
c = 0.5*ones(size(f));
u = mean(f(:))*ones(size(f));

c = c(:);
u = u(:);
f = f(:);
g = g(:);
V = V(:);
W = W(:);

% Array for storing energy values.
eArr = inf(4,outer*inner);

for k = 1:outer
    
    % Update data for diffusion tensor.
    v = reshape(u, [nr nc]);
    
    S = IsoDiffStencil(v, ...
        'sigma', opts.sigma, ...
        'diffusivity', opts.diffusivity, ...
        'diffusivityfun', opts.diffusivityfun, ...
        'gradmag', opts.gradmag );
    
    D = Stencil2Mat(S, 'boundary', 'Neumann');
    
    for j = 1:inner
        
        % Save old position for Taylor expansion.
        cbar = c;
        ubar = u;
        
        % Perform Taylor expansion
        A = spdiags( cbar - V , 0, N, N) - spdiags( W - cbar , 0, N, N)*D;
        B = spdiags( ubar - f + D * ubar , 0, N, N);
        % ! I have 2 gs for the same different data! BUG!
        gk = cbar.*((I+D)*ubar) - V.*f;
        % Set up the linear system to obtain the dual variable.
        LHS = (1/(lam+theta))*(A*(A')) + (1/(m+theta))*(B*(B'));
        RHS = (1/(lam+theta))*A*(lam*f+theta*ubar) + ...
            (1/(m+theta))*B*(m*g+theta*cbar) - gk;
        % Compute dual variable.
        p = LHS\RHS;
        % Compute primal variables.
        u = (1/(lam+theta))*(lam*f+theta*ubar-(A')*p);
        c = (1/(m+theta))*(m*g + theta*cbar - (B')*p);
        
        % Compute energy.
        eArr(1,(k-1)*inner + j) = EneR(u,c,f,g,lam,m);
        eArr(2,(k-1)*inner + j) = ErrConstr(u,c,f,V,W,D);
        eArr(3,(k-1)*inner + j) = norm(u-f,2)^2;
        eArr(4,(k-1)*inner + j) = norm(c-g,2)^2;
        if abs(eArr(2,(k-1)*inner + j))< 1e-10
            eArr = eArr(:,1:((k-1)*inner + j));
            break;
        end
    end
    if abs(eArr(2,(k-1)*inner + j))< 1e-10
        break;
    end
end
u = reshape(u, [nr nc]);
c = reshape(c, [nr nc]);
end

function e = EneR(u,c,f,g,lambda,mu)
e = 0.5*lambda*norm(u-f,2)^2 + 0.5*mu*norm(g-c,2)^2;
end

function e = ErrConstr(u,c,f,V,W,D)
e = norm((c-V).*(u-f) - (W-c).*(D*u),2);
end
