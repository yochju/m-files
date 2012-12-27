function K = FreeKnotInterpDisc(f,x,Nk,It,Meth)
%% K = FreeKnotInterpDisc(f,x,Nk,It,Meth)
%
% FreeKnotInterpDisc computes the optimal knot distribution for piecewise linear
% spline interpolation of the convex function f on the interval [x(1),x(end)].
% The optimisation is done in the discrete setting.
%
% Usage: [ K ] = FreeKnotInterpDisc(f,x,Nk,It,Meth)
% f    : a handle to the considered function or a vector with evaluations.
% x    : a handle to the inverse of the first derivative of f.
% Nk   : number of inner (e.g. free) knots.
% It   : number of iterations for the iterative algorithm.
% Meth : method for the initialisation. If 'u', then the initial mask is
%        uniformly distributed. Otherwise it is random.
% K    : Positions of the knots.. such that x(K) gives the knots.
%
% See also FreeKnotInterpCont, FreeKnotApproxDisc, FreeKnotApproxCont.

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

narginchk(5,5);
nargoutchk(0,1);

if isa(f,'function_handle')
    y = f(x);
else
    y = f;
end

% Compute derivatives at the points x. Endpoints are mirrored to guarantee
% monotonicity.
L = length(x);
yp = zeros(1,L);
for i = 2:(L-1)
    yp(i) = ( y(i+1)-y(i-1) )/( x(i+1)-x(i-1) );
end
yp(1) = yp(2);
yp(end) = yp(end-1);

% Generate initial mask with Nk+2 knots.
K = GenerateMask( Meth , Nk+2 , length(x) );

% Apply iterative scheme.
L = length(K);
for i = 1:It
    for j = 2:2:(L-1)
        Wert = ( y(K(j+1))-y(K(j-1)) ) / ( x(K(j+1))-x(K(j-1)) );
        Intervall = yp( K(j-1):K(j+1) );
        p = FindBestPosition(Intervall,Wert,'last') - 1;
        K(j) = K(j-1) + p;
    end
    for j = 3:2:(L-1)
        Wert = ( y(K(j+1))-y(K(j-1)) ) / ( x(K(j+1))-x(K(j-1)) );
        Intervall = yp( K(j-1):K(j+1) );
        p = FindBestPosition(Intervall,Wert,'last') - 1;
        K(j) = K(j-1) + p;
    end
end
end
