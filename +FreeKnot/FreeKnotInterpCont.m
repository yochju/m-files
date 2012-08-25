function [x0 x] = FreeKnotInterpCont(f,FpI,a,b,Num,It,Meth)
% [x0 x] = FreeKnotInterpCont(f,FpI,a,b,Num,It,Meth)
% FreeKnotApproxCont computes the optimal knot distribution for piecewise linear
% spline approximation of the convex function f on the interval [a,b]. The
% optimisation is done in the continuous setting.
%
% Usage: [x0 x] = FreeKnotInterpCont(f,FpI,a,b,Num,It,Meth)
% f    : a handle to the considered function.
% FpI  : a handle to the inverse of the first derivative of f.
% a    : lower bound of the considered interval. Equals first knot.
% b    : upper bound of the considered interval. Equals last knot.
% Num  : number of inner (e.g. free) knots.
% It   : number of iterations for the iterative algorithm.
% Meth : method for the initialisation. If 'u', then the initial mask is
%        uniformly distributed. Otherwise it is random.
% x0   : Initial mask.
% x    : Final mask.
%
% See also FreeKnotInterpDisc, FreeKnotApproxDisc, FreeKnotApproxCont.

% Copyright (c) 2011 Laurent Hoeltgen <hoeltgen@mia.uni-saarland.de>
%
% This program is free software; you can redistribute it and/or modify
% it under the terms of the GNU General Public License as published by
% the Free Software Foundation; either version 3 of the License, or
% (at your option) any later version.
%
% This program is distributed in the hope that it will be useful,
% but WITHOUT ANY WARRANTY; without even the implied warranty of
% MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
% GNU General Public License for more details.
%
% You should have received a copy of the GNU General Public License
% along with this program; if not, write to the Free Software
% Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston,
% MA 02110-1301, USA.

error(nargchk(7,7,nargin));

% Generate initial mask with Num+2 knots.
if strcmp(Meth,'u')
    x0 = linspace(a,b,Num+2);
else
    x0 = union([a b],a+(b-a)*rand(Num,1));
end

% Perform iterative scheme alternatively on the even and odd knots.
x=x0;
for i=1:It
    x(2:2:Num+1)=FpI( ( f(x(3:2:Num+2))-f(x(1:2:Num)) )./( x(3:2:Num+2)-x(1:2:Num) ) );
    x(3:2:Num+1)=FpI( ( f(x(4:2:Num+2))-f(x(2:2:Num)) )./( x(4:2:Num+2)-x(2:2:Num) ) );
end
end