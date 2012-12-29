function [x varargout] = FreeKnotApprox(f, varargin)
%% Optimal knot distribution for piecewise linear splines interpolation.
%
% [x ErG ErL] = FreeKnotApprox(f, ...)
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
% x = FreeKnot.FreeKnotApprox(f, 'min', -1, 'max', 1, 'num', 5);
%
% See also FreeKnotInterp

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

% Last revision: 29.12.2012 09:50

%% Notes

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

parser.addParamValue('min', 0, @(x) validateattributes(x, {'numeric'}, ...
    {'scalar', 'real', 'finite'}, mfilename, 'min'));

parser.addParamValue('max', 1, @(x) validateattributes(x, {'numeric'}, ...
    {'scalar', 'real', 'finite'}, mfilename, 'max'));

parser.addParamValue('num', 3, @(x) validateattributes(x, {'numeric'}, ...
    {'scalar', 'integer', 'finite', 'positive', '>=', 3}, mfilename, 'num'));

parser.addParamValue('its', 1, @(x) validateattributes(x, {'numeric'}, ...
    {'scalar', 'integer', 'finite', 'positive'}, mfilename, 'its'));

parser.addParamValue('ini', 'uniform', @(x) strcmpi(x, validatestring(x, ...
    {'uniform', 'random'})));

parser.addParamValue('pts', 1024, @(x) validateattributes(x, {'numeric'}, ...
    {'scalar', 'integer', 'finite', 'positive'}, mfilename, 'its'));

parser.parse( f, varargin{:});
opts = parser.Results;

a = opts.min;
b = opts.max;
MExc = ExceptionMessage('Input', 'message', ...
    'Lower bound must be strictly smaller than upper bound.');
assert(a<b, MExc.id, MExc.message);

%% Run code.

if ~isa(f, 'function_handle')
    
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
    
    % Generate initial mask.
    if strcmp(opts.ini, 'uniform')
        x = round(linspace(1, numel(y), opts.num));
    else
        temp = randperm(numel(y)-2) + 1;
        x = [ 1 sort(temp(1:(opts.num-2))) numel(y) ];
    end
    
    for i = 1:opts.its
        
        % Determine set of locally optimal knots.
        xi = zeros(opts.num-1,2);
        % Function values of locally optimal knots.
        fi = zeros(opts.num-1,2);
        
        % Slope of the piecewise linear spline.
        D = zeros(opts.num-1,1);
        
        for j = 1:(opts.num-1)
            xi(j,1) = 0.75*s(x(j)) + 0.25*s(x(j+1));
            xi(j,2) = 0.25*s(x(j)) + 0.75*s(x(j+1));
            
            fi(j,1) = interp1(s,y,xi(j,1), 'cubic');
            fi(j,2) = interp1(s,y,xi(j,2), 'cubic');
            
            D(j) = (fi(j,2) - fi(j,1))/(xi(j,2)-xi(j,1));
        end
        
        for j = 1:(opts.num-2)
            
            % Dummy variables.
            a1 = D(j);
            b1 = fi(j,1);
            c1 = xi(j,1);
            a2 = D(j+1);
            b2 = fi(j+1,1);
            c2 = xi(j+1,1);
            
            % Position of the intersection.
            new = ( ( b2 - a2*c2 ) - ( b1 - a1*c1 ) )/( a1 - a2 );
            x(j+1) = round(interp1(s, 1:length(s), new, 'cubic'));
        end
    end
    
    % Compute additional output.
    if nargout == 2
        [eG ~] = FreeKnot.ErrorApprox(f, s(x));
        varargout{1} = eG;
    end
    if nargout == 3
        [eG eL] = FreeKnot.ErrorApprox(f, s(x));
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
    
    % Apply the iterative scheme.
    xi = zeros(opts.num-1,2);
    for i=1:opts.its
        % Compute optimal local solution.
        xi(1:end,1) = 0.75*x(1:end-1)+0.25*x(2:end);
        xi(1:end,2) = 0.25*x(1:end-1)+0.75*x(2:end);
        
        % Compute intersection points of the local linear splines.
        Dpf = (f(xi(2:end,2))-f(xi(2:end,1))) ./ ...
            (xi(2:end,2)-xi(2:end,1));
        Df = (f(xi(1:end-1,2))-f(xi(1:end-1,1))) ./ ...
            (xi(1:end-1,2)-xi(1:end-1,1));
        x(2:end-1) = (xi(1:end-1,1).*Df-xi(2:end,1).*Dpf-f(xi(1:end-1,1)) + ...
            f(xi(2:end,1)))./(Df-Dpf);
    end
    
    % Compute additional output.
    if nargout == 2
        [eG ~] = FreeKnot.ErrorApprox(f, x);
        varargout{1} = eG;
    end
    if nargout == 3
        [eG eL] = FreeKnot.ErrorApprox(f, x);
        varargout{1} = eG;
        varargout{2} = eL;
    end
    
end

end
