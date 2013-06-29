function OCNonLinearAll(f, g, V, W, lambda, mu, epsilon, ...
    N, M, L, theta, xi, varargin)
%% Solve all (nonlinear) optimal control models.

% Solves: argmin_{u,c} lambda/2||u-f||_2^2 + mu||c-g||_1 + epsilon/2||c-g||_2^2
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

% Last revision: 2013-06-28 17:50

%% Parse Input.

parser = inputParser;
parser.FunctionName = mfilename;
parser.CaseSensitive = false;
parser.KeepUnmatched = true;
parser.StructExpand = true;

parser.addRequired('f', @(x) validateattributes(x, {'numeric'}, ...
    {'nonempty','finite','2d'}, mfilename, 'f', 1));

parser.addRequired('g', @(x) validateattributes(x, {'numeric'}, ...
    {'nonempty','finite','2d'}, mfilename, 'g', 2));

parser.addRequired('V', @(x) validateattributes(x, {'numeric'}, ...
    {'nonempty','finite','2d'}, mfilename, 'V', 3));

parser.addRequired('W', @(x) validateattributes(x, {'numeric'}, ...
    {'nonempty','finite','2d'}, mfilename, 'W', 4));

parser.addRequired('lambda', @(x) validateattributes(x, {'numeric'}, ...
    {'scalar', 'nonnegative'}, mfilename, 'lambda', 5));

parser.addRequired('mu', @(x) validateattributes(x, {'numeric'}, ...
    {'scalar', 'nonnegative'}, mfilename, 'mu', 6));

parser.addRequired('epsilon', @(x) validateattributes(x, {'numeric'}, ...
    {'scalar', 'nonnegative'}, mfilename, 'epsilon', 7));

parser.addRequired('N', @(x) validateattributes(x, ...
    {'double'}, {'scalar', 'integer', 'positive'}, mfilename, 'N', 8));

parser.addRequired('M', @(x) validateattributes(x, ...
    {'double'}, {'scalar', 'integer', 'positive'}, mfilename, 'M', 9));

parser.addRequired('L', @(x) validateattributes(x, ...
    {'double'}, {'scalar', 'integer', 'positive'}, mfilename, 'L', 10));

parser.addRequired('theta', @(x) validateattributes(x, {'numeric'}, ...
    {'scalar', 'nonnegative'}, mfilename, 'theta', 11));

parser.addRequired('xi', @(x) validateattributes(x, {'numeric'}, ...
    {'scalar', 'nonnegative'}, mfilename, 'xi', 12));

parser.addParamValue('glambda', 0.1, @(x) validateattributes(x, ...
    {'double'}, {'scalar', 'nonnegative'}, mfilename, 'glambda'));

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

parser.parse( f, g, V, W, lambda, mu, epsilon, ...
    N, M, L, theta, xi, varargin{:});
opts = parser.Results;

%% Initialise variables and save some important data.

[nr nc] = size(f);
Num = nr*nc;
I = speye(Num, Num);

% Reshape the data into vectors.
f = f(:);
g = g(:);
V = V(:);
W = W(:);

% Give the model the full information available at the begginning.
ukj = f;
ckj = ones(size(f));

% If N == 1, then we perform Dk corresponds to the Laplacian and we obtain the
% linear model.
v   = ones(size(f));

% Count the number of iterations.
counter = 0;

for k = 1:N
    %% Update diffusivity
    
    % Compute stencil.
    S = IsoDiffStencil(v                      , ...
        'sigma',          opts.sigma          , ...
        'lambda',         opts.glambda        , ...
        'diffusivity',    opts.diffusivity    , ...
        'diffusivityfun', opts.diffusivityfun , ...
        'gradmag',        opts.gradmag        );
    
    % Transform stencil into Matrix.
    Dk = Stencil2Mat(S, 'boundary', 'Neumann');
    
    for j = 1:M
        %% Update linearised model
        
        % Perform Taylor expansion
        
        % D_u T(ukj, ckj; v)
        Akj = spdiags( ckj - V, 0, Num, Num) ...
            - spdiags( W - ckj, 0, Num, Num)*Dk;
        
        % D_c T(ukj, ckj; v)
        Bkj = spdiags( ukj - f + Dk * ukj, 0, Num, Num);
        
        % Akj*ukj + Bkj*ckj - T(ukj, ckj; v)
        gkj = ckj.*((I+Dk)*ukj) - V.*f;
        
        if abs(mu)>0
            %% There is a l1 term, we will use PDHG.
            
            [ukj ckj count] = OCPDHG(f, g, Akj, Bkj, gkj, ukj, ckj, ...
                xi, L, lambda, mu, epsilon, theta);
            
            % Increment counter.
            counter = counter + count;
        else
            %% There are only quadratic terms, we use the KKT conditions.
            
            [ukj ckj] = OCKKT(f, g, Akj, Bkj, gkj, ukj, ckj, ...
                lambda, epsilon, theta);
            
            % Increment counter.
            counter = counter + 1;
        end
        
    end
    
    v = ukj;
    
end

end

function [ukjn ckjn] = OCKKT(f, g, Akj, Bkj, gkj, ukj, ckj, ...
    lambda, epsilon, theta)
%% Solve linearised model with only quadratic terms using the KKT conditions

% Set up the linear system to obtain the dual variable.
LHS = (Akj*(Akj'))/(lambda+theta) + (Bkj*(Bkj'))/(epsilon+theta);
RHS = (Akj/(lambda+theta))*(lambda*f+theta*ukj) + ...
    (Bkj/(epsilon+theta))*(epsilon*g+theta*ckj) - gkj;

% Compute dual variable.
p = LHS\RHS;

% Compute primal variables.
ukjn = (lambda*f+theta*ukj-(Akj')*p)/(lambda+theta);
ckjn = (epsilon*g + theta*ckj - (B')*p)/(epsilon+theta);

end

function [ukjn ckjn counter] = OCPDHG(f, g, Akj, Bkj, gkj, ukj, ckj, ...
    xi, L, lambda, mu, epsilon, theta)
%% Solve linearised model with l1 term using PDHG algorithm.

% Internal Parameter to steer the accuracy of the norm esitmate.
tol = 1e-3;

% Determine step sizes.
[nrm, ~] = normest([Akj Bkj], tol);

% zeta*tau*||(Akj Bkj)||^2 < 1
zeta     = 0.25;
tau      = 1/(zeta*nrm^2 + tol);

% Initialise Variables
yn      = zeros(size(ukj));
ukjn    = ukj;
ckjn    = ckj;
ukjnbar = ukjn;
ckjnbar = ckjn;

% Count the number of iterations.
counter = 0;

for n = 1:L
    %% Iterate
    
    % Save old data for extrapolation.
    ukjnold = ukjn;
    ckjnold = ckjn;
    
    % Dual update.
    yn = yn + zeta*(Akj*ukjnbar + Bkj*ckjnbar - gkj);
    
    % Primal update
    ukjn = ukjn - tau*((Akj')*yn - lambda*f - theta*ukj);
    ckjn = g + OCShrink( ...
        (ckjn - tau*((Bkj')*yn+theta*ckj)-(1+tau*theta)*g) / ...
        (1 + tau*epsilon + tau*theta), ...
        tau*mu/(1 + tau*epsilon + tau*theta));
    
    % Extrapolation step.
    ukjnbar = ukjn + xi*(ukjn - ukjnold);
    ckjnbar = ckjn + xi*(ckjn - ckjnold);
    
    % Increment counter.
    counter = counter + 1;
end

end

function y = OCShrink(x,lambda)
%% Soft shrinkage.

y = sign(x).*max(abs(x)-lambda,0);
end
