function [u, c, its, flag, ...
    cEvo, uEvo, tEvo, ener] = FindMask(f, lambda, varargin)
%% Find Optimal Mask for Homogeneous inpainting.
%
% [u, c, its, flag, cEvo, uEvo, tEvo, ener] = FindMask(f, lambda, varargin)
%
% Input Parameters (required):
%
% f      : Signal to be considered. (vector)
% lambda : regularisation weight for the energy. (scalar)
%
% Input Parameters (optional):
%
% Optional parameters are either struct with the following fields and
% corresponding values or option/value pairs, where the option is specified as a
% string.
%
% mu           : penalisation for the proximal term. (scalar, default = 1.0)
% e            : quadratic penalisation term for the mask. (scalar, default =
%                1-e3)
% maxit        : maximal number of iterations. (integer, default = 1)
% tol          : tolerance threshold (scalar, default 1e-3)
% SplitBregman : options for the SplitBregman12 algorithm (struct,
%                default = struct())
% SolvePde     : options for the SolvePde algorithm (struct, default = struct())
% Verbose      : whether information should be printed to stderr. Also displays
%                a plot window with information. (boolean, default = false)
% Save         : if non-empty, data is save to this file at each iteration.
%                (string, default = '')
%
% Output Parameters:
%
% u    : optimal reconstruction.
% c    : optimal mask.
% its  : number of performed iterations.
% flag : flag indicating exit status.
%        -1 : maximum number of iterations reached.
%         0 : fix point reached for c.
%         1 : energy stagnated.
%         2 : solution is alternating.
% cEvo : evolution of the mask.
% uEvo : evolution of the solution.
% tEvo : evolution of the distance between 2 consecutive masks.
% ener : evolution of the energy.
%
% Output parameters (optional):
%
%
%
% Description:
%
%
%
% Example:
%
%
%
% See also fmincon.

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

% Last revision on: 11.12.2012 16:36

%% Check Input and Output

narginchk(2,16);
nargoutchk(0,8);

parser = inputParser;
parser.FunctionName = mfilename;
parser.CaseSensitive = false;
parser.KeepUnmatched = true;
parser.StructExpand = true;

parser.addRequired('f', @(x) validateattributes(x, ...
    {'numeric'}, {'column','nonempty','finite'}, mfilename, 'f', 1));

parser.addRequired('lambda', @(x) validateattributes(x, ...
    {'numeric'}, {'scalar','nonempty','finite','nonnegative'}, ...
    mfilename, 'lambda', 2));

parser.addParamValue('mu', 1.0, @(x) validateattributes(x, ...
    {'numeric'}, {'scalar','nonempty','finite','nonnegative'}, ...
    mfilename, 'mu'));

parser.addParamValue('e', 1e-3, @(x) validateattributes(x, ...
    {'numeric'}, {'scalar','nonempty','finite','nonnegative'}, ...
    mfilename, 'e'));

parser.addParamValue('maxit', 1, @(x) validateattributes(x, ...
    {'numeric'}, {'scalar','nonempty','finite','nonnegative', 'integer'}, ...
    mfilename, 'maxit'));

parser.addParamValue('tol', 1e-3, @(x) validateattributes(x, ...
    {'numeric'}, {'scalar','nonempty','finite','nonnegative'}, ...
    mfilename, 'tol'));

parser.addParamValue('SplitBregman', struct(), @(x) validateattributes(x, ...
    {'struct'}, {}, mfilename, 'SplitBregman'));

parser.addParamValue('SolvePde', struct(), @(x) validateattributes(x, ...
    {'struct'}, {}, mfilename, 'SolvePde'));

parser.addParamValue('Save', '', @(x) validateattributes(x, ...
    {'char'}, {'row', 'nonempty'}));

parser.addParamValue('Verbose', false, @(x) validateattributes(x, ...
    {'logical'}, {'scalar'}));

parser.parse( f, lambda, varargin{:});
opts = parser.Results;

%% Initialisation

% Length of the Signal.
N = numel(f);

% Matrix corresponding to the Laplacian. (1D)
D = LaplaceM(N,1);

% Mask
c    = inf(N,1);
cbar = inf(N,1);

% Logging
cEvo = nan(opts.maxit,N);
uEvo = nan(opts.maxit,N);
tEvo = nan(opts.maxit,1);
ener = inf(opts.maxit,1);

% flag indicates how the algorithm stopped.
%   -1 : maximum number of iterations reached.
%    0 : fix point reached for c.
%    1 : energy stagnated.
%    2 : solution is alternating.
flag = -1;

if ~isempty(opts.Save)
    ExcM = ExceptionMessage('Input', 'message', 'Save File must not exist.');
    assert(exist(opts.Save,'file')==0, ExcM.id, ExcM.message);
    failsafe = true;
else
    failsafe = false;
end

timeTotal = 0;

data = struct( ...
    'iteration', cell(opts.maxit,1), ...
    'lastiter', cell(opts.maxit,1), ...
    'mask', cell(opts.maxit,1), ...
    'solution', cell(opts.maxit,1), ...
    'cEvo', cell(opts.maxit,1), ...
    'uEvo', cell(opts.maxit,1), ...
    'tEvo', cell(opts.maxit,1), ...
    'ener', cell(opts.maxit,1), ...
    'timeIter', cell(opts.maxit,1), ...
    'timeTotal', cell(opts.maxit,1) ...
    );

%% Run Code.

i = 1;
while i <= opts.maxit
    
    tic();
    
    %% - Check if we can stop iterating.
    
    if (i>=2)&&(norm(c-cbar)<opts.tol)
        %% Fixpoint reached.
        
        flag = 0;
        break;
        
    elseif (i>=3)&&(abs(ener(i-1)-ener(i-2))<opts.tol)
        %% Energy stagnated.
        
        flag = 1;
        break;
        
    elseif (i>=4) && ...
            (norm(cEvo(i-1,:)-cEvo(i-3,:))<opts.tol) && ...
            (norm(cEvo(i-2,:)-cEvo(i-4,:))<opts.tol)
        %% Solution is alternating.
        
        flag = 2;
        break;
        
    end
    
    %% - Iterate -------------------------------------------------------- %%
    
    % - Set up current position for Taylor expansion. -------------------- %
    
    % Note that in any case, the pairs (ubar, cbar) and (u, c) will always
    % be feasible solutions of the initial PDE.
    if i == 1
        %% - Start with a full mask. ------------------------------------ %%
        
        cbar = ones(N,1);
        ubar = f(:);
        
    else
        %% - Take mask and solution from previous iteration. ------------ %%
        
        cbar = c(:);
        ubar = u(:);
        
    end
    
    % - Compute operators occuring in the optimisatin -------------------- %
    
    % Note that A is the inpainting matrix.
    A = spdiags(cbar(:),0,N,N) - (speye(N,N) - spdiags(cbar(:),0,N,N))*D;
    B = spdiags(f(:)-ubar(:)-D*ubar(:),0,N,N);
    g = cbar(:).*ubar(:) + D*ubar(:);
    
    % This is an undocumented feature in MATLAB to turn non catchable
    % warnings into errors. Use with care! Its only purpose here is to avoid
    % a constantly reoccurring warning whenever the matrix is badly scaled.
    s = warning('error', 'MATLAB:singularMatrix');
    try
        % S contains the inpainting echo in each pixel. This matrix is large and
        % full. Also it's the main reason, why we cannot port this algorithm to
        % 2D.
        S = A\B;
        h = f-A\g;
    catch err
        if opts.Verbose
            ExcM = ExceptionMessage('Internal', ...
                'message', 'Construction of S or h might have failed.');
            warning(ExcM.id,ExcM.message);
        end
    end
    warning(s);
    
    % Set up the matrix and righthand side in the P1 problem.
    if opts.e > 10*eps
        M = [ S ; opts.mu^2*speye(N,N) ; opts.e.*speye(N,N) ];
        l = [ h(:) ; opts.mu^2*cbar(:) ; zeros(size(cbar(:))) ];
    else
        M = [ S ; opts.mu^2*speye(N,N) ];
        l = [ h(:) ; opts.mu^2*cbar(:) ];
    end
    
    % - Solve optimisation problem to get new mask ----------------------- %
    % argmin_c || M c - l ||_2^2 + lambda*|| c ||_1
    
    [ c, fSpB, ~, ~, iSpB ] = Optimization.SplitBregman12( speye(N,N), ...
        zeros(N,1), 1/lambda, M, -l, opts.SplitBregman);
    if opts.Verbose
        fprintf(2,'\nSplit Bregman terminated after %d iterations.', iSpB);
        fprintf(2,'\nStopping reason was: %d', fSpB);
    end
    
    if (any(c<0)||any(c>1))
        ExcM = ExceptionMessage('Internal', ...
            'message', 'Mask went out of range!\n');
        fprintf(2,'\n\n');
        warning(ExcM.id,ExcM.message);
        c(c<0) = 0;
        c(c>1) = 1;
    end
    
    % - Compute solution corresponding to new mask. ---- %
    
    if norm(c) < 100*eps
        %% If c is 0, no need to compute a solution u. It must be 0.
        
        u = zeros(size(c));
        
    else
        %% Compute solution.
        
        u = SolvePde(f, c, opts.SolvePde);
        
    end
    
    if opts.Verbose
        figure(666);
        x = linspace(0,1,numel(f));
        subplot(2,2,1);
        plot(x,f,x,u,x,c,'*r');
        title('Current Solution.');
        subplot(2,2,2);
        plot(x,f,x,ubar,x,cbar,'*r');
        title('Old Solution.');
        subplot(2,2,[3, 4])
        plot(ener(~isinf(ener)),'*r');
        title('Energy');
    end
    
    if nargout > 4
        cEvo(i,:) = c';
        uEvo(i,:) = u';
        tEvo(i) = norm(c-cbar);
        ener(i) = Energy(u(:), c(:), f(:), 'lambda', lambda, 'epsilon', opts.e);
        if (i>1)&&(ener(i) > ener(i-1))
            ExcM = ExceptionMessage('Internal', ...
                'message', 'Energy has increased!\n');
            fprintf(2,'\n\n');
            warning(ExcM.id,ExcM.message);
        end
    end
    
    timeIter = toc();
    timeTotal = timeTotal + timeIter;
    
    if opts.Verbose
        fprintf(2,'\nDistance between actual and last mask: %g',norm(c-cbar));
        fprintf(2,'\nCurrent Energy: %g', ...
            Energy(u, c, f, 'lambda', lambda, 'epsilon', opts.e));
        fprintf(2,'\nRuntime for iteration %d: %g seconds.', i, timeIter);
        fprintf(2,'\nTotal runtime: %g seconds.\n\n', timeTotal);
    end
    
    if failsafe
        data(i).iteration = i;
        
        % This is evil...
        temp = num2cell(i*ones(1,opts.maxit),[1 opts.maxit]);
        [data(:).lastiter] = temp{:};
        
        data(i).mask = c;
        data(i).solution = u;
        data(i).cEvo = cEvo;
        data(i).uEvo = uEvo;
        data(i).tEvo = tEvo;
        data(i).ener = ener;
        data(i).cEvo((i+1):end,:) = [];
        data(i).uEvo((i+1):end,:) = [];
        data(i).tEvo(isnan(tEvo)) = [];
        data(i).ener(isinf(ener)) = [];
        data(i).timeIter = timeIter;
        data(i).timeTotal = timeTotal;
        save(opts.Save, 'data');
    end
    
    % Increase iteration count.
    i = i+1;
    
end

its = min([opts.maxit i]);

cEvo((its+1):end,:) = [];
uEvo((its+1):end,:) = [];

tEvo(isnan(tEvo)) = [];
ener(isinf(ener)) = [];


end
