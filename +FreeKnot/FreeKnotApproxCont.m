function [x0 x] = FreeKnotApproxCont(f,a,b,Num,It,Meth)
% [x0 x] = FreeKnotApproxCont(f,a,b,Num,It,Meth)
% FreeKnotApproxCont computes the optimal knot distribution for piecewise linear
% spline approximation of the convex function f on the interval [a,b]. The
% optimisation is done in the continuous setting.
%
% Usage: [x0 x] = FreeKnotApproxCont(f,a,b,Num,It,Meth)
% f    : a handle to the considered function.
% a    : lower bound of the considered interval. Equals first knot.
% b    : upper bound of the considered interval. Equals last knot.
% Num  : number of inner (e.g. free) knots.
% It   : number of iterations for the iterative algorithm.
% Meth : method for the initialisation. If 'u', then the initial mask is
%        uniformly distributed. Otherwise it is random.
% x0   : Initial mask.
% x    : Final mask.
%
% See also FreeKnotInterpCont, FreeKnotInterpDisc, FreeKnotApproxDisc.

% Copyright 2011,2012 Laurent Hoeltgen <laurent.hoeltgen@gmail.com>
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

% Last revision: 05.09.2012 16:10

%% Check number of input and output arguments.

narginchk(6,6);
nargoutchk(0,2);

% Generate initial mask with Num+2 knots.
if strcmp(Meth,'u')
    x0 = linspace(a,b,Num+2);
else
    x0 = union([a b],a+(b-a)*rand(Num,1));
end

% Apply the iterative scheme.
x = x0;
xi = zeros(Num+1,2);
for i=1:It
    % Compute optimal local solution.
    xi(1:end,1) = 0.75*x(1:end-1)+0.25*x(2:end);
    xi(1:end,2) = 0.25*x(1:end-1)+0.75*x(2:end);
    
    % Compute intersection points of the local linear splines.
    Dpf = (f(xi(2:end,2))-f(xi(2:end,1)))./(xi(2:end,2)-xi(2:end,1));
    Df = (f(xi(1:end-1,2))-f(xi(1:end-1,1)))./(xi(1:end-1,2)-xi(1:end-1,1));
    x(2:end-1) = (xi(1:end-1,1).*Df - xi(2:end,1).*Dpf - f(xi(1:end-1,1)) + f(xi(2:end,1)))./(Df-Dpf);
end
end
