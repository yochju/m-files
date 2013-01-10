function [u v w] = QuadraticCompletion(a, b, c)
%% Performs quadratic completion on the polynomial ax^2 + bx + c
%
% [u v w] = QuadraticCompletion(a, b, c)
%
% Input parameters (required):
%
% a : coefficient of the quadratic term. (array)
% b : coefficient of the linear term (array)
% c : coefficient of the constant term (array)
%
% Input parameters (parameters):
%
% Parameters are either struct with the following fields and corresponding
% values or option/value pairs, where the option is specified as a string.
%
% -
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
% u : scaling of the quadratic term
% v : shift inside the quadratic term
% w : shift outside the quadratic term
%
% Output parameters (optional):
%
% -
%
% Description:
%
% Computes the coefficients u, v and w such that the polynomials
% a*x^2 + b*x + c and u*(x+b)^2+w are identical. a, b and c can be arrays (if
% identical size) in which case the computation is done componentwise.
%
% Example:
%
% [u, v, w] = QuadraticCompletion(1,6,9) yields u = 1, v = 3, w = 0.
%
% See also

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

% Last revision on: 10.01.2013 16:23

%% Notes

%% Parse input and output.

narginchk(3,3);
nargoutchk(0,3);

parser = inputParser;
parser.FunctionName = mfilename;
parser.CaseSensitive = false;
parser.KeepUnmatched = true;
parser.StructExpand = true;

parser.addRequired('a', @(x) validateattributes(x, {'numeric'}, ...
    {'finite', 'nonnan'}, mfilename, 'a'));
parser.addRequired('b', @(x) validateattributes(x, {'numeric'}, ...
    {'finite', 'nonnan', 'size', size(a)}, mfilename, 'b'));
parser.addRequired('c', @(x) validateattributes(x, {'numeric'}, ...
    {'finite', 'nonnan', 'size', size(a)}, mfilename, 'c'));

parser.parse(a,b,c);

%% Run code.		       

u = a;
v = b./(2*a);
w = c-(b.^2)./(4*a);

end
