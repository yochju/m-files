function [x varargout] = FreeKnotInterp(f, varargin)
%% Optimal knot distribution for piecewise linear splines interpolation.
%
% [x x0] = FreeKnotInterpCont(f,FpI,a,b,Num,It,Meth)
%
% Input parameters (required):
%
% f : The function to be interpolated. Must be able to take an array as
%     argument. If the passed argument is an array, the method operates in the
%     discrete setting. (function handle or array)
%
% Input parameters (parameters):
%
% Parameters are either struct with the following fields and corresponding
% values or option/value pairs, where the option is specified as a string.
%
% fpi : Inverse of the derivative of the function f. If this argument is not a
%       function handle, then the whole method operates in a discrete framework.
%       (function handle or array)
% min : Lower bound of the interval to be considered. (scalar, default = 0)
% max : Upper bound of the interval to be considered. (scalar, default = 1)
% num : Number of knots to be considered. (positive integer, default = 3)
% its : Number of iterations to be run. (nonnegative integer, default = 1)
% ini : How to initialise the method. Possible values are 'uniform' or 'random'.
%       (char array, default = 'uniform')
% pts : number of samples to use in the discrete setting.
%       (integer, default = 1024)
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
% x : The optimal knot distribution.
%
% Output parameters (optional):
%
% -
%
% Description:
%
% Computes the optimal knot distribution for piecewise linear spline
% interpolation of a strictly convex function f on the interval [a,b].
%
% Example:
%
% -
%
% See also FreeKnotApprox

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

% Last revision on: 26.12.2012

%% Notes

%% Parse input and output.

narginchk(1,15);
% nargoutchk(0,2);

parser = inputParser;
parser.FunctionName = mfilename;
parser.CaseSensitive = false;
parser.KeepUnmatched = true;
parser.StructExpand = true;

parser.addRequired('f', @(x) validateattributes(x, ...
    {'function_handle', 'numeric'}, {'vector'}, mfilename, 'f'));

parser.addParamValue('fpi', [], @(x) validateattributes(x, ...
    {'function_handle', 'numeric'}, {'vector'}, mfilename, 'fpi'));

parser.addParamValue('min', 0, @(x) validateattributes(x, {'numeric'}, ...
    {'scalar', 'real', 'finite'}, mfilename, 'min'));

parser.addParamValue('max', 0, @(x) validateattributes(x, {'numeric'}, ...
    {'scalar', 'real', 'finite'}, mfilename, 'max'));

parser.addParamValue('num', 3, @(x) validateattributes(x, {'numeric'}, ...
    {'scalar', 'integer', 'finite', 'positive', '>=', 3}, mfilename, 'num'));

parser.addParamValue('its', 1, @(x) validateattributes(x, {'numeric'}, ...
    {'scalar', 'integer', 'finite', 'positive'}, mfilename, 'its'));

parser.addParamValue('ini', 'uniform', @(x) strcmpi(x, validatestring(x, ...
    {'uniform', 'random'})));

parser.addParamValue('pts', 1024, @(x) validateattributes(x, {'numeric'}, ...
    {'scalar', 'integer', 'finite', 'positive'}, mfilename, 'its'));

parser.parse( knots, order, varargin{:});
opts = parser.Results;

a = opts.min;
b = opts.max;
MExc = ExceptionMessage('Input', 'message', ...
    'Lower bound must be strictly smaller than upper bound.');
assert(a<b, MExc.id, MExc.message);

%% Run code.

% Generate initial mask with opts.num knots.
if strcmp(opts.ini, 'uniform')
    x0 = linspace(opts.min, opts.max, opts.num);
elseif strcmp(opts.ini, 'random')
    x0 = union([a b],a+(b-a)*rand(opts.num-2,1));
end

x=x0;
discrete = true;
if isa(f, 'function_handle') && isa(opts.fpi, 'function_handle')
    discrete = false;
end

% Set up the data required for the discrete mode.
if discrete
    s = linspace(a,b,opts.pts);
    if isa(f,'function_handle')
        y = f(s);
    else
        y = f;
    end
    
    yp = zeros(1,opts.num);
    for i = 2:(L-1)
        yp(i) = ( y(i+1)-y(i-1) )/( x(i+1)-x(i-1) );
    end
    yp(1) = yp(2);
    yp(end) = yp(end-1);
    %% TODO: Discrete setting not yet implemented.
else
    for i=1:opts.its
        x(2:2:(opts.num-1)) = opts.fpi( ...
            ( f(x(3:2:opts.num)) - f(x(1:2:(opts.num-2))) ) ./ ...
            (   x(3:2:opts.num)  -   x(1:2:(opts.num-2))  ) );
        x(3:2:(opts.num-1)) = opts.fpi( ...
            ( f(x(4:2:opts.num)) - f(x(2:2:(opts.num-2))) ) ./ ...
            (   x(4:2:opts.num)  -   x(2:2:(opts.num-2))  ) );
    end
end

end
