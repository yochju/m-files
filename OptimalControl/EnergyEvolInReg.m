function out = EnergyEvolInReg(c, f, varargin)
%% Evaluates the Enery in function of the regularisation parameter
%
% out = EnergyEvolInReg(c, f, ...)
%
% Input parameters (required):
%
% c : mask (double array).
% f : initial image (double array).
%
% Input parameters (optional) (2 variants!)
%
% lambda : regularisation weight. (double scalar or array)
%
% or:
%
% min      : minimal value for lambda.
% max      : maximal value for lambda.
% NSamples : number of samples to be used (uses linspace).
%
% Output parameters:
%
% out : The energy corresponding to the input variables, that is
%       0.5*||u-f||_2^2 + lambda * ||c||_1
%
% Description:
%
% Evaluates the energy that we consider in this optimal control framework for
% varying values of lambda. The mask and the initial input data are always
% required as input parameters. Additionnally either a third parameter
% specifying the value(s) for the regulariser or three parameters specifying the
% range to be used have to be specified. In case of a single third parameter it
% is possible to specify a single value or an array of values. In that case, the
% energy will be evaluated and the return value will have the same size as the
% input parameter. If the three parameter variant is chosen, then a uniformly
% distributed set (using linspace) between "min" and "max" will be computed. The
% Energy will be evaluated for each of these values.
%
% Example:
%
% c = double(rand(100,100) > 0.6);
% f = rand(100,100);
% l = 0.73;
% E = EnergyEvolInReg(c,f,l);
%
% or
%
% E = EnergyEvolInReg(c,f,[0.05, 0.1, 0.25]);
%
% or
%
% E = EnergyEvolInReg(c,f,0.03,0.97,136);
%
% See also norm.

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

% Last revision on: 14.09.2012 14:37

narginchk(3,5)
nargoutchk(0,1)

parser = inputParser;
parser.FunctionName  = mfilename;
parser.CaseSensitive = false;
parser.KeepUnmatched = true;
parser.StructExpand  = true;

parser.addRequired('c', @(x) ismatrix(x)&&IsDouble(x));
parser.addRequired('f', @(x) ismatrix(x)&&IsDouble(x));

if nargin == 3
    parser.addOptional('lambda',1.0, @(x) isvector(x)&&IsDouble(x));
else
    parser.addOptional('min', 0.0, @(x) isscalar(x)&&IsDouble(x));
    parser.addOptional('max', 1.0, @(x) isscalar(x)&&IsDouble(x));
    parser.addOptional('NSamples', 100, @(x) IsInteger(x)&&(x>=1));
end

parser.parse(c,f,varargin{:});
opts = parser.Results;

if nargin == 3
    samples = opts.lambda;
else
    samples = linspace(opts.min,opts.max,opts.NSamples);
end

out = arrayfun(@(x) Energy(SolvePde(f(:),c(:)), c(:), f(:), x), samples);

end
