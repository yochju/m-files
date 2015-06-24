function [x, varargout] = FreeKnotInterp(f, varargin)
%% Optimal knot distribution for piecewise linear splines interpolation.
%
% [x ErG ErL] = FreeKnotInterp(f, ...)
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
% pts : number of samples to use in the discrete setting. If f is an array, pts
%       defaults to the number of points in f. Otherwise it uses its default
%       value. (integer, default = 1024)
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
% x   : The optimal knot distribution.
% ErG : The global error committed by interpolating with the knots in x.
% ErL : The local error distribution by interpolating with the knots in x.
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
% f = @(x) x.^2;
% fpi = @(x) x/2;
% x = FreeKnot.FreeKnotInterp(f, 'fpi', fpi, 'min', -1, 'max', 1, 'num', 5);
%
% See also FreeKnotApprox

% Copyright 2011, 2012, 2015 Laurent Hoeltgen <laurent.hoeltgen@gmail.com>
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

% Last revision on: 16.06.2015 10:50

%% Notes

%TODO: Make the iteration stop if a fix point is reached.

%% Parse input and output.

narginchk(1, 15);
nargoutchk(0, 3);

parser = inputParser;
parser.FunctionName = mfilename;
parser.CaseSensitive = false;
parser.KeepUnmatched = true;
parser.StructExpand = true;

parser.addRequired('f', @(x) validateattributes(x, ...
    {'function_handle', 'numeric'}, {'vector'}, mfilename, 'f'));

parser.addParameter('fpi', [], @(x) validateattributes(x, ...
    {'function_handle', 'numeric'}, {'vector'}, mfilename, 'fpi'));

parser.addParameter('min', 0, @(x) validateattributes(x, {'numeric'}, ...
    {'scalar', 'real', 'finite'}, mfilename, 'min'));

parser.addParameter('max', 1, @(x) validateattributes(x, {'numeric'}, ...
    {'scalar', 'real', 'finite'}, mfilename, 'max'));

parser.addParameter('num', 3, @(x) validateattributes(x, {'numeric'}, ...
    {'scalar', 'integer', 'finite', 'positive', '>=', 3}, mfilename, 'num'));

parser.addParameter('its', 1, @(x) validateattributes(x, {'numeric'}, ...
    {'scalar', 'integer', 'finite', 'positive'}, mfilename, 'its'));

parser.addParameter('ini', 'uniform', @(x) strcmpi(x, validatestring(x, ...
    {'uniform', 'random'})));

parser.addParameter('pts', 1024, @(x) validateattributes(x, {'numeric'}, ...
    {'scalar', 'integer', 'finite', 'positive'}, mfilename, 'its'));

parser.parse( f, varargin{:});
opts = parser.Results;

a = opts.min;
b = opts.max;
MExc = ExceptionMessage('Input', 'message', ...
    'Lower bound must be strictly smaller than upper bound.');
assert(a<b, MExc.id, MExc.message);

%% Run code.

discrete = true;
if isa(f, 'function_handle') && isa(opts.fpi, 'function_handle')
    discrete = false;
end

if discrete
    
    MExc = ExceptionMessage('Generic', 'message', ...
        'Discrete framework might be cause loss of accuracy.');
    warning(MExc.id, MExc.message);
    
    % Generate data.
    if isa(f, 'function_handle')
        s = linspace(a, b, opts.pts);
        y = f(s);
    else
        opts.pts = numel(f);
        s = linspace(a, b, opts.pts);
        y = f;
    end
    
    % Compute the first derivative of y (central differences). Mirrored bounds.
    % TODO: Make this more flexible with my finite difference methods.
    yp = inf(size(y));
    for i = 2:(numel(y)-1)
        yp(i) = ( y(i+1)-y(i-1) )/( s(i+1)-s(i-1) );
    end
    yp(1)   = (y(3)-y(1))/(s(3)-s(1));
    yp(end) = (y(end)-y(end-1))/(s(end)-s(end-1));
    
    % Generate initial mask.
    if strcmp(opts.ini, 'uniform')
        x = round(linspace(1, numel(y), opts.num));
    else
        temp = randperm(numel(y)-2) + 1;
        x = [ 1 sort(temp(1:(opts.num-2))) numel(y) ];
    end
    
    % Iterate.
    for i = 1:opts.its
        for j = 2:2:(opts.num-1)
            Wert = ( y(x(j+1))-y(x(j-1)) ) / ( s(x(j+1))-s(x(j-1)) );
            Intervall = yp( x(j-1):x(j+1) );
            p = FindBestPosition(Intervall, Wert, 'last') - 1;
            x(j) = x(j-1) + p;
        end
        for j = 3:2:(opts.num-1)
            Wert = ( y(x(j+1))-y(x(j-1)) ) / ( s(x(j+1))-s(x(j-1)) );
            Intervall = yp( x(j-1):x(j+1) );
            p = FindBestPosition(Intervall, Wert, 'last') - 1;
            x(j) = x(j-1) + p;
        end
    end
    
    % Compute additional output.
    if nargout == 2
        [eG, ~] = FreeKnot.ErrorInterp(f, s(x));
        varargout{1} = eG;
    end
    if nargout == 3
        [eG, eL] = FreeKnot.ErrorInterp(f, s(x));
        varargout{1} = eG;
        varargout{2} = eL;
    end
    
else
    
    % Generate initial mask with opts.num knots.
    if strcmp(opts.ini, 'uniform')
        x = linspace(opts.min, opts.max, opts.num);
    elseif strcmp(opts.ini, 'random')
        x = union([a b],a+(b-a)*rand(opts.num-2,1));
    end
    
    % Iterate.
    for i=1:opts.its
        x(2:2:(opts.num-1)) = opts.fpi( ...
            ( f(x(3:2:opts.num)) - f(x(1:2:(opts.num-2))) ) ./ ...
            (   x(3:2:opts.num)  -   x(1:2:(opts.num-2))  ) );
        x(3:2:(opts.num-1)) = opts.fpi( ...
            ( f(x(4:2:opts.num)) - f(x(2:2:(opts.num-2))) ) ./ ...
            (   x(4:2:opts.num)  -   x(2:2:(opts.num-2))  ) );
    end
    
    % Compute additional output.
    if nargout == 2
        [eG, ~] = FreeKnot.ErrorInterp(f, x);
        varargout{1} = eG;
    end
    if nargout == 3
        [eG, eL] = FreeKnot.ErrorInterp(f, x);
        varargout{1} = eG;
        varargout{2} = eL;
    end
    
end

end
