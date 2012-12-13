function [ uk, varargout ] = SplitBregman12( A, b, lambda, C, f, varargin)
%% Performs split Bregman iteration with one 1-norm and one 2-norm term.
%
% [uk, flag, dk, bk, itO, itI, dukIn, dukOut ddk ener gap] =
%            SplitBregman12(A, b, lambda, C, f, varargin)
%
% Input Parameters (required):
%
% A      : matrix in front of the variable in the 1-norm term. (matrix)
% b      : vector offset in the 1-norm term. (vector)
% lambda : regularisation weight in front of the 2-norm term. (scalar)
% C      : matrix in front of the variable in the 2-norm term (matrix)
% f      : vector offset in the 2-norm term. (vector)
%
% Input parameters (parameters):
%
% Parameters are either struct with the following fields and corresponding
% values or option/value pairs, where the option is specified as a string.
%
% mu   : regularisation weight used internally by the split Bregman algorithm.
%        (scalar, default = 2)
% iOut : number of Bregman iterations. (integer, default = 1)
% iIn  : number of alternating minimisations. (integer, default = 1)
% tolOut : tolerance limit when to abort outer iterations (scalar,
%          default = 1e-3)
% tolIn : tolerance limit when to abort inner iterations (scalar,
%          default = 1e-3)
%
% Input parameters (optional):
%
% The number of optional parameters is always at most one. If a function takes
% an optional parameter, it does not take any other parameters.
%
% -
%
% Output Parameters:
%
% uk   : Solution vector (vector).
%
% Output parameters (optional):
%
% flag   : Flag indicating the stopping criterion (integer).
%          0 : tolerance limit was reached.
%          1 : max number of iterations was reached.
% dk     : dual variable dk = A*uk-b. (vector)
% bk     : auxiliary variable used for the updates. (vector)
% itO    : number of Bregman iterations. (integer)
% dukIn  : distances between two iterates uk from the inner iteration. (matrix)
% dukOut : distances between two iterates uk from the outer iteration. (vector)
% ddk    : distances between two iterates dk. (matrix)
% ener   : energy after each outer iteration (vector)
% gap    : norm of d-Ax-b after each outer iteration. (vector)
%
% Description:
%
% Computes the minimum of ||Ax+b||_1 + lambda/2*||Cx+f||^2_2 through a split
% Bregman approach. Note that the formulation used here contains + inside the
% norms, whereas a more common choice in the literature would be -.
% Check http://www.stanford.edu/~tagoldst/Tom_Goldstein/Split_Bregman.html for
% more information on the algorithm.
%
% Example:
%
% A = sprandsym(100, 0.2);
% b = rand(100, 1);
% C = sprandsym(100, 0.2);
% f = rand(100, 1);
% lambda = 1.75;
% u = Optimization.SplitBregman12(A,b,lambda,C,f,'itOut',100,'itIn',5);
%
% See also fminunc.

% Copyright 2011, 2012 Laurent Hoeltgen <laurent.hoeltgen@gmail.com>
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

% Last revision on: 13.12.2012 10:30

%% Check Input and Output

narginchk(5, 15);
nargoutchk(0, 11);

parser = inputParser;
parser.FunctionName = mfilename;
parser.CaseSensitive = false;
parser.KeepUnmatched = true;
parser.StructExpand = true;

parser.addRequired('A', @(x) validateattributes(x, ...
    {'numeric'}, {'2d','nonempty','finite'}, ...
    mfilename, 'A', 1));

parser.addRequired('b', @(x) validateattributes(x, ...
    {'numeric'}, {'column','nonempty','finite', 'size', [size(A,1) 1]}, ...
    mfilename, 'b', 2));

parser.addRequired('lambda', @(x) validateattributes(x, ...
    {'numeric'}, {'scalar','nonempty','finite','nonnegative'}, ...
    mfilename, 'lambda', 3));

parser.addRequired('C', @(x) validateattributes(x, ...
    {'numeric'}, {'2d','nonempty','finite'}, ...
    mfilename, 'C', 4));

parser.addRequired('f', @(x) validateattributes(x, ...
    {'numeric'}, {'column','nonempty','finite', 'size', [size(C,1) 1]}, ...
    mfilename, 'f', 5));

parser.addParamValue('mu', 2, @(x) validateattributes(x, ...
    {'numeric'}, {'scalar','nonempty','finite','nonnegative'}, ...
    mfilename, 'mu'));

parser.addParamValue('iOut', 1, @(x) validateattributes(x, ...
    {'numeric'}, {'scalar','nonempty','finite','nonnegative', 'integer'}, ...
    mfilename, 'iOUt'));

parser.addParamValue('iIn', 1, @(x) validateattributes(x, ...
    {'numeric'}, {'scalar','nonempty','finite','nonnegative', 'integer'}, ...
    mfilename, 'iIn'));

parser.addParamValue('tolOut', 1e-3, @(x) validateattributes(x, ...
    {'numeric'}, {'scalar','nonempty','finite','nonnegative'}, ...
    mfilename, 'tolOut'));

parser.addParamValue('tolIn', 1e-3, @(x) validateattributes(x, ...
    {'numeric'}, {'scalar','nonempty','finite','nonnegative'}, ...
    mfilename, 'tolIn'));

parser.parse( A, b, lambda, C, f, varargin{:});
opts = parser.Results;

%% Initialisation

bk = b;
dk = zeros(size(b));

flag = 1;

uOld = inf(size(A,2),1);
mu = opts.mu;

if nargout > 6
    dukIn  = inf(opts.iOut, opts.iIn);
end
if nargout > 7
    dukOut = inf(opts.iOut, 1);
end
if nargout > 8
    ddk    = inf(opts.iOut, opts.iIn);
end
if nargout > 9
    ener = inf(opts.iOut, 1);
end
if nargout > 10
    gap = inf(opts.iOut, 1);
end

%% Perform Optimisation

for itO=1:opts.iOut
    %% Perform Bregman iteration step.
    
    for itI=1:opts.iIn
        %% Perform alternating minimisation steps.
        
        % Solves (by alternating minimisation of the variables u and d)
        % argmin_{u,d} ||d||_1 + lambda/2*||Cu+f||_2^2 + mu/2*||d-Au-b||_2^2.
        % Minimisation w.r.t. to u is a least squares problem, while the
        % minimisation with respect to d has an analytical solution in terms of
        % soft shrinkage. Aborts when both uk and dk don't change anymore.
        uk = ( lambda*(C')*C + mu*(A')*A )\( mu*(A')*(dk-bk)-lambda*(C')*f );
        dk = sign( A*uk+bk ).*max( abs(A*uk+bk)-1.0/mu, 0 );
        
        if (nargout > 6) && (itI > 1)
            dukIn(itO,itI) = norm(uk-utemp,2);
        end
        if (nargout > 8) && (itI > 1)
            ddk(itO,itI)   = norm(dk-dtemp,2);
        end
        
        if (itI > 1) && ...
                (norm(uk-utemp,2) < opts.tolIn) && ...
                (norm(dk-dtemp,2) < opts.tolIn)
            break;
        else
            utemp = uk;
            dtemp = dk;
        end
    end
    
    % Update the Bregman auxiliary variable.
    bk = bk + b - dk + A*uk;
    
    if nargout > 7
        dukOut(itO,1) = norm(uOld-uk,2);
    end
    if nargout > 9
        ener(itO,1) = 0.5*norm(A*uk+b,1) + lambda/2*norm(C*uk+f,2)^2;
    end
    if nargout > 10
        gap(itO,1) = norm(dk-A*uk-b);
    end
    
    if norm(uOld-uk,2) < opts.tolOut
        %% Check for convergence.
        
        % This tolerance check was suggested in the original paper of Goldstein.
        
        flag = 0;
        break;
        
    else
        
        uOld = uk;
        
    end
    
end

if nargout > 1
    varargout{1} = flag;
end
if nargout > 2
    varargout{2} = dk;
end
if nargout > 3
    varargout{3} = bk;
end
if nargout > 4
    varargout{4} = itO;
end
if nargout > 5
    varargout{5} = itI;
end
if nargout > 6
    varargout{6} = dukIn;
end
if nargout > 7
    varargout{7} = dukOut;
end
if nargout > 8
    varargout{8} = ddk;
end
if nargout > 9
    varargout{9} = ener;
end
if nargout > 10
    varargout{10} = gap;
end

end

