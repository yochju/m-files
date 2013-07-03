function [ukj ckj counter] = OCNonLinearAll(f, lambda, mu, epsilon, varargin)
%% Solve all (nonlinear) optimal control models.
%
% [ukj ckj counter] = OCNonLinearAll(f, lambda, mu, epsilon, ...)
%
% Input parameters (required):
%
% f : Input Signal. (2d double array)
% lambda : Weight of the data term ||u-f||_2^2. (positive scalar)
% mu : Weight of the data term ||c-g||_1 (nonnegative scalar)
% epsilon : Weight of the data term ||c-g||_2^2 (nonnegative scalar)
%
% Input parameters (parameters):
%
% Parameters are either struct with the following fields and corresponding
% values or option/value pairs, where the option is specified as a string.
%
% g : Model parameter. Indicates which values mask c should take, default =
%     zeros(size(f))
% V : Model parameter. Steers weighting of the data term in the PDE, default =
%     zeros(size(f))
% W : Model parameter. Steers weighting of the diffusion term in the PDE,
%     default = zeros(size(f))
% theta : Weight for the proximal term. Positive scalar, default = 0.1.
% xi : Extrapolation stepsize for the PDHG Algorithm. Nonnegative scalar between
%      0 and 1, default = 1.0.
% N : Number of lagged diffusivity steps, positive integer, default = 1.
% M : Number of linearisations, positive integer, default = 1000.
% L : Number of PDHG iterations, positive integer, default = 100000.
% glambda : parameter for the diffusivity, nonnegative scalar, default = 0.1
% sigma : smoothing parameter for the diffusivity, nonnegative scalar, default =
%         0.5
% diffusivity : diffusivity function to be used, string, default =
%               'charbonnier'.
% diffusivityfun : function handle to custom diffusivity, function_handle,
%                  default = @(x) ones(size(x)).
% gradmag : options to compute gradient magnitude, struct, default =
%           struct('scheme', 'central').
% debug : whether to output debugging messages, boolean, default = false.
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
% ukj : Reconstruction
% ckj : Mask
% counter : array containing the number of iterations performed.
%
% Output parameters (optional):
%
% -
%
% Description:
%
% Solves: argmin_{u,c} lambda/2||u-f||_2^2 + mu||c-g||_1 + epsilon/2||c-g||_2^2
%         such that (c-V).*(u-f) - (W-c).*Du = 0
%
% where D is a differential operator of the Form
%
% div( g( ||nabla u_sigma||^2 ) nabla u )
%
% where u_sigma is gaussian convolved version of u with std. sigma. div is the
% divergence and nabla the gradient operator.
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
%
% Example:
%
% [nr nc] = size(f);
% g       = 0*ones([nr nc]);
% V       = 0*ones([nr nc]);
% W       = 1*ones([nr nc]);
%
% %% Linear denoising.
%
% lambda  = 1.0;
% mu      = 0.0;
% epsilon = 0.5;
%
% N = 1;
% M = 100;
% L = 100;
%
% theta = 0.1;
% xi    = 1.0;
%
% [u1 c1 d1] = OCNonLinearAll(f, lambda, mu, epsilon, ...
%     'g', g, 'V', V, 'W', W, ...
%     'N', N, 'M', M, 'L', L, 'theta', theta, 'xi', xi, ...
%     'diffusivity', 'custom', 'diffusivityfun', @(x) ones(size(x)));
% %% Non-Linear Denoising
%
% lambda  = 1.0;
% mu      = 0.0;
% epsilon = 1.0;
%
% N = 5;
% M = 20;
% L = 2000;
%
% theta = 0.1;
% xi    = 1.0;
%
% [u2 c2 d2] = OCNonLinearAll(f, lambda, mu, epsilon, ...
%     'g', g, 'V', V, 'W', W, ...
%     'N', N, 'M', M, 'L', L, 'theta', theta, 'xi', xi, ...
%     'diffusivity', 'perona-malik', 'glambda', 0.01, 'sigma', 0.1);
%
% %% Linear Inpainting
%
% disp('Testing linear inpainting');
%
% lambda  = 1.0;
% mu      = 0.5;
% epsilon = 1e-9;
%
% N = 1;
% M = 20;
% L = 200;
%
% theta = 0.1;
% xi    = 1.0;
%
% [u3 c3 d3] = OCNonLinearAll(f, lambda, mu, epsilon, ...
%     'g', g, 'V', V, 'W', W, ...
%     'N', N, 'M', M, 'L', L, 'theta', theta, 'xi', xi, ...
%     'diffusivity', 'custom', 'diffusivityfun', @(x) ones(size(x)));
%
% %% Nonlinear Inpainting
%
% disp('Testing non-linear inpainting');
%
% lambda  = 1.0;
% mu      = 0.5;
% epsilon = 1e-9;
%
% N = 2;
% M = 20;
% L = 200;
%
% theta = 0.1;
% xi    = 1.0;
%
% [u4 c4 d4] = OCNonLinearAll(f, lambda, mu, epsilon, ...
%     'g', g, 'V', V, 'W', W, ...
%     'N', N, 'M', M, 'L', L, 'theta', theta, 'xi', xi, ...
%     'diffusivity', 'perona-malik', 'glambda', 0.01, 'sigma', 0.1);
%
% See also

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

% Last revision: 2013-07-03 17:30

%% Parse Input.

narginchk(4,32);
nargoutchk(1,3);

parser = inputParser;
parser.FunctionName = mfilename;
parser.CaseSensitive = false;
parser.KeepUnmatched = true;
parser.StructExpand = true;

parser.addRequired('f', @(x) validateattributes(x, {'numeric'}, ...
    {'nonempty', 'finite', '2d'}, mfilename, 'f', 1));

parser.addRequired('lambda', @(x) validateattributes(x, {'numeric'}, ...
    {'scalar', 'positive'}, mfilename, 'lambda', 2));

parser.addRequired('mu', @(x) validateattributes(x, {'numeric'}, ...
    {'scalar', 'nonnegative'}, mfilename, 'mu', 3));

parser.addRequired('epsilon', @(x) validateattributes(x, {'numeric'}, ...
    {'scalar', 'nonnegative'}, mfilename, 'epsilon', 4));

parser.addParamValue('g', zeros(size(f)), @(x) validateattributes(x, ...
    {'numeric'}, {'nonempty','finite','2d'}, mfilename, 'g'));

parser.addParamValue('V', zeros(size(f)), @(x) validateattributes(x, ...
    {'numeric'}, {'nonempty','finite','2d'}, mfilename, 'V'));

parser.addParamValue('W', ones(size(f)), @(x) validateattributes(x, ...
    {'numeric'}, {'nonempty','finite','2d'}, mfilename, 'W'));

parser.addParamValue('theta', 0.1, @(x) validateattributes(x, {'numeric'}, ...
    {'scalar', 'positive'}, mfilename, 'theta'));

parser.addParamValue('xi', 1.0, @(x) validateattributes(x, {'numeric'}, ...
    {'scalar', 'nonnegative', '<=', 1}, mfilename, 'xi'));

parser.addParamValue('N', 1, @(x) validateattributes(x, ...
    {'double'}, {'scalar', 'integer', 'positive'}, mfilename, 'N'));

parser.addParamValue('M', 1000, @(x) validateattributes(x, ...
    {'double'}, {'scalar', 'integer', 'positive'}, mfilename, 'M'));

parser.addParamValue('L', 100000, @(x) validateattributes(x, ...
    {'double'}, {'scalar', 'integer', 'positive'}, mfilename, 'L'));

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

parser.addParamValue('debug', false, @(x) validateattributes(x, ...
    {'logical'}, {'scalar'}, mfilename, 'debug'));

parser.parse( f, lambda, mu, epsilon, varargin{:});
opts = parser.Results;

if ((abs(mu) < 100*eps) && (abs(epsilon) < 100*eps))
    %% We need at least one counterweight to the data fidelity term ||u-f||^2.
    ExcM = ExceptionMessage('Input', 'message', ...
        'Either mu or epsilon must be positive!');
    error(ExcM.id, ExcM.message);
end

%% Initialise variables and save some important data.

[nr nc] = size(f);
Num = nr*nc;
I = speye(Num, Num);

% Get optional parameters.
theta = opts.theta;
xi = opts.xi;

N = opts.N;
M = opts.M;
L = opts.L;

% Reshape the data into vectors.
f = f(:);
g = opts.g(:);
V = opts.V(:);
W = opts.W(:);

% Give the model the full information available at the begginning.
ukj = f;
ckj = ones(size(f));

% If N == 1, then we perform Dk corresponds to the Laplacian and we obtain the
% linear model.
v = ones(size(f));

% Count the number of iterations.
counter = zeros(3, max([N ; M ; L]));

id2 = tic();

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
    
    id1 = tic();
    
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
                xi, L, lambda, mu, epsilon, theta, opts.debug);
            
            % Increment counter.
            counter(3,j) = counter(3,j) + count;
        else
            %% There are only quadratic terms, we use the KKT conditions.
            
            [ukj ckj] = OCKKT(f, g, Akj, Bkj, gkj, ukj, ckj, ...
                lambda, epsilon, theta, opts.debug);
            
            % Increment counter.
            counter(3,k) = counter(3,k) + 1;
        end
        
        counter(2,k) = counter(2,k) + 1;
        
        if ((norm(ukj_old-ukj,2) < 1e-6) || (norm(ckj_old-ckj,2) < 1e-6))
            %% Fixpoint has been reached for the linearised problem.
            
            time = toc(id1);
            if opts.debug
                disp(['[OC] Breaking from inner loop at iteration (' ...
                    num2str(k) ', ' num2str(j) ')']);
                disp(['[OC] Runtime: ' num2str(time)]);
                disp(['[OC] Distance u: ' num2str(norm(ukj_old-ukj,2))]);
                disp(['[OC] Distance c: ' num2str(norm(ckj_old-ckj,2))]);
            end
            break;
        end
        
    end
    
    if (j >= M)
        %% Iterations for linearised problem exhausted.
        
        time = toc(id1);
        if opts.debug
            disp('[OC] Iterations for linearised problem exhausted.');
            disp(['[OC] Runtime: ' num2str(time)]);
            disp(['[OC] Distance u: ' num2str(norm(ukj_old-ukj,2))]);
            disp(['[OC] Distance c: ' num2str(norm(ckj_old-ckj,2))]);
        end
    end
    
    v = ukj;
    counter(1,1) = counter(1,1) + 1;
    
    if ((norm(uk_old-ukj,2) < 1e-6) || (norm(ck_old-ckj,2) < 1e-6))
        %% Reached fixpoint for lagged diffusivity.
        
        time = toc(id2);
        
        if opts.debug
            disp(['[OC] Breaking from outer loop at iteration (' ...
                num2str(k) ')']);
            disp(['[OC] Runtime: ' num2str(time)]);
            disp(['[OC] Distance u: ' num2str(norm(uk_old-ukj,2))]);
            disp(['[OC] Distance c: ' num2str(norm(ck_old-ckj,2))]);
        end
        break;
    end
    
end

if ((k>=N) && (N > 1))
    %% Iterations for lagged diffusivity exhausted.
    
    time = toc(id2);
    
    if opts.debug
        disp('[OC] Lagged diffusivity updates exhausted.');
        disp(['[OC] Runtime: ' num2str(time)]);
        disp(['[OC] Distance u: ' num2str(norm(uk_old-ukj,2))]);
        disp(['[OC] Distance c: ' num2str(norm(ck_old-ckj,2))]);
    end
end

if (N == 1)
    %% Completed model without linear diffusivity
    
    time = toc(id2);
    
    if opts.debug
        disp('[OC] Completed model without lagged diffusivity.');
        disp(['[OC] Runtime: ' num2str(time)]);
    end
end

ukj = reshape(ukj, [nr nc]);
ckj = reshape(ckj, [nr nc]);

end

function [ukjn ckjn] = OCKKT(f, g, Akj, Bkj, gkj, ukj, ckj, ...
    lambda, epsilon, theta, debug)
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

if debug
    disp(['[KKT] Runtime: ' num2str(time)]);
    disp(['[KKT] Residual in dual system: ' num2str(norm(LHS*p-RHS,2))]);
    disp(['[KKT] Residual in constraint: ' ...
        num2str(norm(Akj*ukjn+Bkj*ckjn-gkj,2),2)]);
end

end

function [ukjn ckjn counter] = OCPDHG(f, g, Akj, Bkj, gkj, ukj, ckj, ...
    xi, L, lambda, mu, epsilon, theta, debug)
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
            ((norm(ukjnold-ukjn,2) < 1e-6) || ...
            (norm(ckjnold-ckjn,2) < 1e-6)) && ...
            (norm(Akj*ukjn+Bkj*ckjn-gkj,2) < 1e-10)
        %% Stop if we close to a fixpoint that fulfills the constraints.
        
        time = toc();
        
        if debug
            disp(['[PDHG] Algorithm stopped after ' num2str(n) ...
                ' iterations. Results:']);
            disp(['[PDHG] Runtime: ' num2str(time)]);
            disp(['[PDHG] Distance u: ' num2str(norm(ukjnold-ukjn,2))]);
            disp(['[PDHG] Distance c: ' num2str(norm(ckjnold-ckjn,2))]);
            disp(['[PDHG] Residual in constraint: ' ...
                num2str(norm(Akj*ukjn+Bkj*ckjn-gkj,2),2)]);
        end
        return;
    end
    
end

% Couldn't reach desired accuracy with specified number of iterations. Return
% whatever we have got at this point.
time = toc();

if debug
    disp('[PDHG] Algorithm used all the iterations. Final results are:');
    disp(['[PDHG] Runtime: ' num2str(time)]);
    disp(['[PDHG] Distance u: ' num2str(norm(ukjnold-ukjn,2))]);
    disp(['[PDHG] Distance c: ' num2str(norm(ckjnold-ckjn,2))]);
    disp(['[PDHG] Residual in constraint: ' ...
        num2str(norm(Akj*ukjn+Bkj*ckjn-gkj,2),2)]);
end

end

function y = OCShrink(x, lambda)
%% Soft shrinkage.

% Solves y = argmin_y lambda||y||_1 + 1/2||y-x||^2
y = sign(x).*max(abs(x)-lambda, 0);
end
