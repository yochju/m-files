function [u c varargout] = OptimalControlPenalize(f, varargin)
%% Algorithm for the optimisation of the considered framework.
%
% [u c ...] = OptimalControlPenalize(f, ...)
%
% Input parameters (required):
%
% f : the input image to be compressed.
%
% Input parameters (optional):
%
% Optional parameters are either struct with the following fields and
% corresponding values or option/value pairs, where the option is specified as a
% string.
%
% MaxOuter : maximum number of outer iterations (scalar, default = 1).
% MaxInner : maximum number of inner iterations (scalar, default = 10).
% TolOuter : tolerance threshold for outer iterations (double, default = 1e-3).
% TolInner : tolerance threshold for inner iterations (double, default = 1e-3).
% uInit    : initial value for reconstruction. (array, default = f).
% cInit    : initial value for reconstruction. (array, default = random mask).
% lambda   : regularisation parameter. (double scalar, default = 1.0).
% penPDE   : initial penalisation on the PDE (double, default = 1.0).
% penu     : initial penalisation on prox. term for u (double, default = 1.0).
% penc     : initial penalisation on prox. term for c (double, default = 1.0).
% uStep    : penalisation increment for u (double, default = 2.0).
% cStep    : penalisation increment for c (double, default = 2.0).
% PDEstep  : penalisation increment for the PDE (double, default = 2.0).
% thresh   : value at which mask should be thresholded. If negative, no
%            threshold will be done. Instead the PDE will be solved another time
%            to assert that the solution is feasible. A value of 0 means that
%            nothing will be done. Positive values imply a thresholding at the
%            given level. Note that the latter two variants may yield unfeasible
%            solutions with respect to the PDE. E.g the variables u and c may
%            not necessarily solve the PDE at the same time. (default = 0).
%
% Output parameters (required):
%
% u     : obtained reconstruction (array).
% c     : corresponding mask (array).
%
% Output parameters (optional):
%
% ItIn  : number of inner iterations performed.
% ItOut : number of outer iterations performed.
% EnVal : energy at each iteration step.
% ReVal : residual at each iteration step.
% IncPe : iterations when a increase in the penalisation happened.
%
% Description
%
% Solves the optimal control formulation for PDE based image compression using
% the Laplacian.
%
% min 0.5*||u-f||_2^2 + l*||c||_1 s.th. c*(u-f)-(1-c)*D*u = 0
%
% The algorithm is a composition of several tools. The hard PDE constraint is
% replaced using an augmented formulation of the initial energy.
%
% min 0.5*||u-f||_2^2 + l*||c||_1 + t*||c*(u-f)-(1-c)*D*u||_2^2
%
% The thus obtained formulation is then solved alternatingly with respect to the
% reconstruction and to the mask. If a fix point (or the maximal number of
% alternating steps) is reached, then the penalisation on the PDE is increased.
% Then, the alternating optimisation steps are being repeated. Finally, the
% algorithm also adds to proximal terms that penalise excessively large
% deviation from the old iterates. This hopefully helps keeping the process
% stable.
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

% Last revision on: 10.09.2012 16:10

%% Perform input and output argument checking.

narginchk(1,31);
nargoutchk(2,7);

parser = inputParser;
parser.FunctionName = mfilename;
parser.CaseSensitive = false;
parser.KeepUnmatched = true;
parser.StructExpand = true;

parser.addRequired('f', @(x) ismatrix(x)&&IsDouble(x));

parser.addParamValue('MaxOuter', 1, @(x) isscalar(x)&&IsInteger(x));
parser.addParamValue('MaxInner', 10, @(x) isscalar(x)&&IsInteger(x));

% The rather large tolerance values are correct. See the implementation below
% for more explanations. The point is that we are very tolerant here.
parser.addParamValue('TolOuter', 1e3, @(x) isscalar(x)&&(x>=0));
parser.addParamValue('TolInner',1e3, @(x) isscalar(x)&&(x>=0));

parser.addParamValue('uInit', [], @(x) ismatrix(x)&&IsDouble(x));
parser.addParamValue('cInit', [], @(x) ismatrix(x)&&IsDouble(x));

parser.addParamValue('lambda', 1.0, @(x) isscalar(x)&&(x>=0));

parser.addParamValue('penPDE', 1.0, @(x) isscalar(x)&&(x>=0));
parser.addParamValue('penu',   1.0, @(x) isscalar(x)&&(x>=0));
parser.addParamValue('penc',   1.0, @(x) isscalar(x)&&(x>=0));

parser.addParamValue('uStep',   2, @(x) isscalar(x)&&(x>=0));
parser.addParamValue('cStep',   2, @(x) isscalar(x)&&(x>=0));
parser.addParamValue('PDEstep', 2, @(x) isscalar(x)&&(x>=0));

parser.addParamValue('thresh', 0, @(x) isscalar(x)&&IsDouble(x));

parser.parse(f,varargin{:})
opts = parser.Results;

% Initialise solution and mask.
if isempty(opts.uInit)
    u = f;
else
    u = opts.uInit;
end

if isempty(opts.cInit)
    c = rand(size(f));
else
    c = opts.cInit;
end

if nargout > 2
    ItIn = 0;
    ItOut = 0;
    EnerVal  = inf*ones(1,opts.MaxInner*opts.MaxOuter);
    ResiVal  = inf*ones(1,opts.MaxInner*opts.MaxOuter);
    IncPEN   = inf*ones(1,opts.MaxOuter);
end

% TODO: these options are hardcoded throughout the framework.
[row col] = size(u);
LapM = LaplaceM(row, col, 'KnotsR', [-1 0 1], 'KnotsC', [-1 0 1], ...
    'Boundary', 'Neumann');

k = 1;
NumIter = 0;
while k <= opts.MaxOuter
    %% Outer loop increases the penalization of deviations in the constraint.
    
    uOldK = u;
    cOldK = c;
    
    i = 1;
    while i <= opts.MaxInner
        %% Inner loop minimizes alternatively with respect to u and c.
        
        % Minimization w.r.t. to u is an lsq problem.
        % Minimization w.r.t. to c can be done through an extended variant of
        % soft shrinkage.
        
        uOldI = u;
        cOldI = c;
        
        % Find optimal u by solving a least squares problem.
        
        coeffs = [ 1 opts.penPDE opts.penu ];
        A = cell(3,1);
        b = cell(3,1);
        
        % NOTE: In the 2D case, the operators will have to respect the
        % column-wise numbering of the pixels!
        A{1} = speye(length(f(:)),length(f(:)));
        b{1} = f(:);
        
        A{2} = ConstructMat4u(cOldI,LapM);
        b{2} = cOldI(:).*f(:);
        
        A{3} = speye(length(f(:)),length(f(:)));
        b{3} = uOldI(:);
        
        u = Optimization.MinQuadraticEnergy(coeffs,A,b);
        
        % Find optimal c through a shrinkage approach.
        
        lambda = opts.lambda*ones(length(c(:)),1);
        theta = [ opts.penPDE opts.penc ];
        A = [ u(:) - f(:) + LapM*u(:) cOldI(:) ];
        b = [ LapM*u(:) cOldI(:) ];
        c = Optimization.SoftShrinkage(lambda,theta,A,b);
        
        % Check if we can stop iterating and compute optional results.
        
        if nargout > 2
            EnerVal((k-1)*opts.MaxInner+i) = Energy(u,c,opts.f,opts.lambda);
            ResiVal((k-1)*opts.MaxInner+i) = Residual(u,c,opts.f);
            ItIn = ItIn + 1;
        end
        
        % While it might be unusual to have the following situation, we should
        % still account for it:
        %
        % Assume x_k = 1e12; Then
        % (xk + eps(xk)/2) - xk returns 0 although eps(xk)/2 is not 0.
        % In fact eps(xk)/2 is roughly 10e-4. In this case, a convergence test
        % of the form abs((xk + eps(xk)/2) - xk) < 1e-6 would always fail.
        %
        % A far better test would be:
        % abs((xk + eps(xk)/2) - xk) < 10*E_TOL*eps(xk)
        % where E_TOL is the tolerance measure and the factor 10 should allow
        % rounding errors. With this formulation we have:
        %
        % abs((xk + 11*E_TOL*eps(xk)) - xk) < 10*E_TOL*eps(xk) -> FALSE
        % abs((xk +  9*E_TOL*eps(xk)) - xk) < 10*E_TOL*eps(xk) -> TRUE
        %
        % This holds for any xk now.
        
        changeI = max([norm(uOldI(:)-u(:),Inf) norm(cOldI(:)-c(:),Inf)]);
        NumIter = NumIter + 1;
        
        % Note that opts.TolInner should be chosen rather large for our usual
        % data ranges.
        if changeI < 10*opts.TolInner*eps(changeI)
            break;
        else
            i = i + 1;
        end
        
    end
    
    % Check if we can end the algorithm and compute optional results.
    
    changeK = max([norm(uOldK(:)-u(:),Inf) norm(cOldK(:)-c(:),Inf)]);
    
    if nargin > 2
        ItOut = ItOut + 1;
    end
    
    % See the comments above changeI for details.
    if changeK < 10*opts.TolOuter*eps(changeK)
        break;
    else
        opts.penPDE = opts.penPDE*opts.PDEstep;
        opts.penu = opts.penu*opts.uStep;
        opts.penc = opts.penc*opts.cStep;
        if nargout > 2
            IncPEN(k) = NumIter;
        end
        k = k + 1;
    end
    
end

% If thresholding is positive, we use this value as a threshold.
% 0 means we do nothing to the solution from the iterative strategy.
% For negative values we solve the corresponding PDE in order to assert the the
% solution is feasible.
if opts.thresh < 0
    u = SolvePde(f,c);
elseif opts.thresh > 0
    u = Threshold(SolvePde(f,c),opts.thresh);
end

if nargout > 2
    EnerVal(EnerVal==Inf) = [];
    ResiVal(ResiVal==Inf) = [];
    IncPEN(IncPEN==Inf) = [];
end

switch nargout
    case 3
        varargout{1} = ItIn;
    case 4
        varargout{1} = ItIn;
        varargout{2} = ItOut;
    case 5
        varargout{1} = ItIn;
        varargout{2} = ItOut;
        varargout{3} = Enerval;
    case 6
        varargout{1} = ItIn;
        varargout{2} = ItOut;
        varargout{3} = EnerVal;
        varargout{4} = ResiVal;
    case 7
        varargout{1} = ItIn;
        varargout{2} = ItOut;
        varargout{3} = EnerVal;
        varargout{4} = ResiVal;
        varargout{5} = IncPEN;
end

end

function out = ConstructMat4u(c,D)
out = spdiags(c(:),0,length(c(:)),length(c(:))) - ...
    spdiags(1-c(:),0,length(c(:)),length(c(:)))*D;
end
