function [ukj ckj counter] = OCNonLinearAll(f, g, V, W, lambda, mu, epsilon, ...
    N, M, L, theta, xi, varargin)
%% Solve all (nonlinear) optimal control models.
%
% Solves: argmin_{u,c} lambda/2||u-f||_2^2 + mu||c-g||_1 + epsilon/2||c-g||_2^2
%         such that (c-V).*(u-f) - (W-c).*Du = 0
%
% g, V, W are model parameters. Reasonable choices are:
%
% g = 0, V = 0, W = 1:
% argmin_{u,c} lambda/2||u-f||_2^2 + mu||c||_1 + epsilon/2||c||_2^2
% such that c.*(u-f) - (1-c).*Du = 0
%
% g = 1, V = 1, W = 0:
% argmin_{u,c} lambda/2||u-f||_2^2 + mu||c-1||_1 + epsilon/2||c-1||_2^2
% such that (1-c).*(u-f) - c.*Du = 0
%
% lambda, mu, epsilon define the characteristics for the solution.
%
% lambda : penalises deviations from input signal.
% mu : penalises non-sparse masks.
% epsilon : if mu > 0, it acts as a regularising parameter and should be small.
% if mu = 0, it acts as a counterweight to lambda.

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

% Last revision: 2013-07-03 11:30

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
counter = zeros(3, max([N ; M ; L]));

tic(2);

for k = 1:N
    %% Update diffusivity
    
    % Compute stencil.
    S = IsoDiffStencil(reshape(v, [nr nc])    , ...
        'sigma',          opts.sigma          , ...
        'lambda',         opts.glambda        , ...
        'diffusivity',    opts.diffusivity    , ...
        'diffusivityfun', opts.diffusivityfun , ...
        'gradmag',        opts.gradmag        );
    
    % Transform stencil into Matrix.
    Dk = Stencil2Mat(S, 'boundary', 'Neumann');
    
    uk_old = ukj;
    ck_old = ckj;
    
    tic(1);
    
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
        
        ukj_old = ukj;
        ckj_old = ckj;
        
        if (abs(mu)>100*eps('double'))
            %% There is a l1 term, we will use PDHG.
            
            [ukj ckj count] = OCPDHG(f, g, Akj, Bkj, gkj, ukj, ckj, ...
                xi, L, lambda, mu, epsilon, theta);
            
            % Increment counter.
            counter(3,j) = counter(3,j) + count;
        else
            %% There are only quadratic terms, we use the KKT conditions.
            
            [ukj ckj] = OCKKT(f, g, Akj, Bkj, gkj, ukj, ckj, ...
                lambda, epsilon, theta);
            
            % Increment counter.
            counter(3,k) = counter(3,k) + 1;
        end
        
        counter(2,k) = counter(2,k) + 1;
        
        if ((norm(ukj_old-ukj,2) < 1e-8) || (norm(ckj_old-ckj,2) < 1e-8))
            %% Fixpoint has been reached for the linearised problem.
            
            time = toc(1);
            
            disp(['[OC] Breaking from inner loop at iteration (' ...
                num2str(k) ', ' num2str(j) ')']);
            disp(['[OC] Runtime: ' num2str(time)]);
            disp(['[OC] Distance u: ' num2str(norm(ukj_old-ukj,2))]);
            disp(['[OC] Distance c: ' num2str(norm(ckj_old-ckj,2))]);
            break;
        end
        
    end
    
    if (j >= M)
        %% Iterations for linearised problem exhausted.
        
        time = toc(1);
        disp('[OC] Iterations for linearised problem exhausted.');
        disp(['[OC] Runtime: ' num2str(time)]);
        disp(['[OC] Distance u: ' num2str(norm(ukj_old-ukj,2))]);
        disp(['[OC] Distance c: ' num2str(norm(ckj_old-ckj,2))]);
    end
    
    v = ukj;
    counter(1,1) = counter(1,1) + 1;
    
    if ((norm(uk_old-ukj,2) < 1e-8) || (norm(ck_old-ckj,2) < 1e-8))
        %% Reached fixpoint for lagged diffusivity.
        
        time = toc(2);
        
        disp(['[OC] Breaking from outer loop at iteration (' num2str(k) ')']);
        disp(['[OC] Runtime: ' num2str(time)]);
        disp(['[OC] Distance u: ' num2str(norm(uk_old-ukj,2))]);
        disp(['[OC] Distance c: ' num2str(norm(ck_old-ckj,2))]);
        break;
    end
    
end

if (k>=N)
    %% Iterations for lagged diffusivity exhausted.
    
    time = toc(2);
    
    disp('[OC] Lagged diffusivity updates exhausted.');
    disp(['[OC] Runtime: ' num2str(time)]);
    disp(['[OC] Distance u: ' num2str(norm(uk_old-ukj,2))]);
    disp(['[OC] Distance c: ' num2str(norm(ck_old-ckj,2))]);
end

ukj = reshape(ukj, [nr nc]);
ckj = reshape(ckj, [nr nc]);

end

function [ukjn ckjn] = OCKKT(f, g, Akj, Bkj, gkj, ukj, ckj, ...
    lambda, epsilon, theta)
%% Solve linearised model with only quadratic terms using the KKT conditions

% Solves

% argmin_{u,c} lambda/2||u-f||^2 + epsilon/2||c-g||^2 + theta/2||u-ukj||^2 + ...
% theta/2||c-ckj||^2
% under the condition: Akj*u + Bkj*c = gkj

tic();

%% Set up the linear system to obtain the dual variable.
LHS = (Akj*(Akj'))/(lambda+theta) + (Bkj*(Bkj'))/(epsilon+theta);
RHS = (Akj/(lambda+theta))*(lambda*f+theta*ukj) + ...
    (Bkj/(epsilon+theta))*(epsilon*g+theta*ckj) - gkj;

%% Compute dual variable.
p = LHS\RHS;
if (norm(LHS*p-RHS,2) > 1e-10)
    %% We couldn't find an accurate value for the lagrangian multipliers.
    ExcM = ExceptionMessage('Internal', 'message', ...
        '[KKT] Failed to compute lagrangian multiplier.');
    warning(ExcM.id, ExcM.message);
end

%% Compute primal variables.
ukjn = (lambda*f+theta*ukj-(Akj')*p)/(lambda+theta);
ckjn = (epsilon*g + theta*ckj - (Bkj')*p)/(epsilon+theta);

%% Debug and log.

time = toc();

disp(['[KKT] Runtime: ' num2str(time)]);
disp(['[KKT] Residual in dual system: ' num2str(norm(LHS*p-RHS,2))]);
disp(['[KKT] Residual in constraint: ' ...
    num2str(norm(Akj*ukjn+Bkj*ckjn-gkj,2),2)]);

end

function [ukjn ckjn counter] = OCPDHG(f, g, Akj, Bkj, gkj, ukj, ckj, ...
    xi, L, lambda, mu, epsilon, theta)
%% Solve linearised model with l1 term using PDHG algorithm.

% Internal Parameter to steer the accuracy of the norm esitmate.
tol = 1e-3;

% Determine the norm of the matrix [Akj Bkj] necessary for the upper bound on
% the step sizes. normest uses power iterations to compute the norm.
[nrm, ~] = normest([Akj Bkj], tol);

% We need zeta*tau*||(Akj Bkj)||^2 < 1. Setting zeta to 0.25 is an arbitrary
% choice. Note, that we add some tol value to ensure that we are really below
% the limit 1.
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

tic();

for n = 1:L
    %% Iterate
    
    % Save old data for extrapolation.
    ukjnold = ukjn;
    ckjnold = ckjn;
    
    %% Dual update.
    
    % Solves:
    % yn = argmin_y 1/2||y - (yn + zeta*Akj*ukjnbar + zeta*Bkj*ckjnbar||^2 + ...
    % zeta*<y,gkj>
    yn = yn + zeta*(Akj*ukjnbar + Bkj*ckjnbar - gkj);
    
    %% Primal update
    
    % Solves:
    % ukjn = argmin_x 1/2||x-(ukjn-tau*Akj'yn)||^2 + lambda*tau/2||x-f||^2 + ...
    % tau*theta/2*||x-ukjn||^2
    ukjn = (ukjn - tau*((Akj')*yn - lambda*f - theta*ukj)) / ...
        (1 + tau*(lambda + theta));
    
    % Solves:
    % ckjn = argmin_x 1/2||x-(ckjn-tau*Bkj'yn)||^2 + tau*mu||x-g||_1 + ...
    % tau*epsilon*||x-g||^2 + tau*theta/2*||x-ckjn||^2
    ckjn = g + OCShrink( ...
        (ckjn - tau*((Bkj')*yn - theta*ckj)-(1+tau*theta)*g) / ...
        (1 + tau*epsilon + tau*theta), ...
        tau*mu/(1 + tau*epsilon + tau*theta));
    
    %% Extrapolation step. Requires 0<=xi<=1.
    
    ukjnbar = ukjn + xi*(ukjn - ukjnold);
    ckjnbar = ckjn + xi*(ckjn - ckjnold);
    
    %% Debug and log.
    
    % Increment counter.
    counter = counter + 1;
    
    if (n>1) && ...
            ((norm(ukjnold-ukjn,2) < 1e-14) || ...
            (norm(ckjnold-ckjn,2) < 1e-14)) && ...
            (norm(Akj*ukjn+Bkj*ckjn-gkj,2) < 1e-14)
        %% Stop if we close to a fixpoint that fulfills the constraints.
        
        time = toc();
        
        disp(['[PDHG] Algorithm stopped after ' num2str(n) ...
            ' iterations. Results:']);
        disp(['[PDHG] Runtime: ' num2str(time)]);
        disp(['[PDHG] Distance u: ' num2str(norm(ukjnold-ukjn,2))]);
        disp(['[PDHG] Distance c: ' num2str(norm(ckjnold-ckjn,2))]);
        disp(['[PDHG] Residual in constraint: ' ...
            num2str(norm(Akj*ukjn+Bkj*ckjn-gkj,2),2)]);
        return;
    end
    
end

% Couldn't reach desired accuracy with specified number of iterations. Return
% whatever we have got at this point.
time = toc();

disp('[PDHG] Algorithm used all the iterations. Final results are:');
disp(['[PDHG] Runtime: ' num2str(time)]);
disp(['[PDHG] Distance u: ' num2str(norm(ukjnold-ukjn,2))]);
disp(['[PDHG] Distance c: ' num2str(norm(ckjnold-ckjn,2))]);
disp(['[PDHG] Residual in constraint: ' ...
    num2str(norm(Akj*ukjn+Bkj*ckjn-gkj,2),2)]);

end

function y = OCShrink(x, lambda)
%% Soft shrinkage.

% Solves y = argmin_y lambda||y||_1 + 1/2||y-x||^2
y = sign(x).*max(abs(x)-lambda, 0);
end
