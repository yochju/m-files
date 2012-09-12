function [u c varargout] = MultiScaleOptimalControlPenalize(f, varargin)
%% Algorithm for the optimisation of the considered framework (multiscale)
%
% [u c ...] = MultiScaleOptimalControlPenalize(f, ...)
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
% lambda   : regularisation parameter. (double scalar, default = 1.0).
% penPDE   : initial penalisation on the PDE (double, default = 1.0).
% penu     : initial penalisation on prox. term for u (double, default = 1.0).
% penc     : initial penalisation on prox. term for c (double, default = 1.0).
% uStep    : penalisation increment for u (double, default = 2.0).
% cStep    : penalisation increment for c (double, default = 2.0).
% PDEstep  : prnalisation increment for the PDE (double, default = 2.0).
% thresh   : value at which mask should be thresholded. If negative, no
%            threshold will be done. (scalar, default = -1);
% scaling  : scaling factor for the different levels. Values smaller than 1.0
%            reduce the image size, while values larger than 1.0 increase the
%            image size. The value 1.0 disables the multiscale approach.
%            (double, default = 1.0)
% NSamples : numer of sample to stop when building the multiscale pyramid.
%            (double. default = 1)
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
% stable. The major difference between this algorithm and OptimalControlPenalize
% is the additional use of a multiscale framework. Starting at a very coarse
% discretisation level, the solution is being computed and used as an
% initialization on the next finer level.
%
% See also fmincon, OptimalControlPenalize.

% Copyright 2012 Laurent Hoeltgen <laurent.hoeltgen@gmail.com>
%
% This program is free software; you can redistribute it and/or modify it
% under the terms of the GNU General Public License as published by the Free
% Software Foundation; either version 3 of the License, or (at your option)
% any later version.
%
% This program is distributed in the hope that it will be useful, but
% WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY
% or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public License
% for more details.
%
% You should have received a copy of the GNU General Public License along
% with this program; if not, write to the Free Software Foundation, Inc., 51
% Franklin Street, Fifth Floor, Boston, MA 02110-1301, USA.

% Last revision on: 10.09.2012 16:37

%% Perform input and output argument checking.

narginchk(1,29);
nargoutchk(2,7);

parser = inputParser;
parser.FunctionName = mfilename;
parser.CaseSensitive = false;
parser.KeepUnmatched = true;
parser.StructExpand = true;

parser.addRequired('f', @(x) ismatrix(x)&&IsDouble(x));

parser.addParamValue('MaxOuter', 1, @(x) isscalar(x)&&IsInteger(x));
parser.addParamValue('MaxInner', 10, @(x) isscalar(x)&&IsInteger(x));

parser.addParamValue('TolOuter', 1e-3, @(x) isscalar(x)&&(x>=0));
parser.addParamValue('TolInner',1e-3, @(x) isscalar(x)&&(x>=0));

parser.addParamValue('uInit', [], @(x) ismatrix(x)&&IsDouble(x));
parser.addParamValue('cInit', [], @(x) ismatrix(x)&&IsDouble(x));

parser.addParamValue('lambda', 1.0, @(x) isscalar(x)&&(x>=0));

parser.addParamValue('penPDE', 1.0, @(x) isscalar(x)&&(x>=0));
parser.addParamValue('penu',   1.0, @(x) isscalar(x)&&(x>=0));
parser.addParamValue('penc',   1.0, @(x) isscalar(x)&&(x>=0));

parser.addParamValue('uStep',   2, @(x) isscalar(x)&&(x>=0));
parser.addParamValue('cStep',   2, @(x) isscalar(x)&&(x>=0));
parser.addParamValue('PDEstep', 2, @(x) isscalar(x)&&(x>=0));

parser.addParamValue('thresh', -1.0, @(x) isscalar(x)&&IsDouble(x));

parser.addParamValue('scaling', 1.0, @(x) isscalar(x)&&(x>=0));
parser.addParamValue('NSamples', 1, @(x) isscalar(x)&&IsInteger(x));

parser.parse(f,varargin{:})
opts = parser.Results;

Scales = CoarseToFine(f,opts.scaling,opts.NSamples);
opts.uInit = [];
opts.cInit = [];

opts = rmfield(opts,'f');

fprintf('Solving on 1 / %d\n',length(Scales));
[u c ItIn ItOut EnerVal ResiVal IncPEN] = OptimalControlPenalize( ...
    Scales{1}, opts );

opts.uInit = u;
opts.cInit = c;

for i = 2:length(Scales)
    fprintf('Solving on %d / %d\n',i,length(Scales));
    opts.uInit = interp1( ...
        linspace(0, 1, length(u(:))), u, linspace(0,1,length(Scales{i})));
    opts.cInit = interp1( ...
        linspace(0, 1, length(c(:))), c, linspace(0,1,length(Scales{i})));
    
    [u c ItIn ItOut EnerVal ResiVal IncPEN] = OptimalControlPenalize( ...
        Scales{i}, opts);
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
