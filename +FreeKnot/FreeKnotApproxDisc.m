function [ K ] = FreeKnotApproxDisc(f,x,Nk,It,Meth)
% [ K ] = FreeKnotApproxDisc(f,x,Nk,It,Meth)
% FreeKnotApproxDisc computes the optimal knot distribution for piecewise linear
% spline approximation of the convex function f on the interval [x(1),x(end)].
% The optimisation is done in the discrete setting.
%
% Usage: [ K ] = FreeKnotApproxDisc(f,x,Nk,It,Meth)
% f    : a handle to the considered function or a vector with evaluations.
% x    : a handle to the inverse of the first derivative of f.
% Nk   : number of inner (e.g. free) knots.
% It   : number of iterations for the iterative algorithm.
% Meth : method for the initialisation. If 'u', then the initial mask is
%        uniformly distributed. Otherwise it is random.
% K    : Positions of the knots.. such that x(K) gives the knots.
%
% See also FreeKnotInterpCont, FreeKnotInterpDisc, FreeKnotApproxCont.

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

error(nargchk(5,5,nargin));

% Generate initial mask with Nk+2 knots.
K = GenerateMask( Meth , Nk+2 , length(x) );

% Apply iterative scheme.
if isa(f,'function_handle')
    for i = 1:It
        xi = zeros(Nk+1,2);
        D = zeros(Nk+1,1);
        for j = 1:(Nk+1)
            xi(j,1) = 0.75*x(K(j)) + 0.25*x(K(j+1));
            xi(j,2) = 0.25*x(K(j)) + 0.75*x(K(j+1));
            D(j) = (f(xi(j,2)) - f(xi(j,1)))/(xi(j,2)-xi(j,1));
        end
        for j = Nk:-1:1
            new = (f(xi(j+1,1))-f(xi(j,1))+D(j)*xi(j,1)-D(j+1)*xi(j+1,1))/(D(j)-D(j+1));
            %K(j+1) = interp1(x,1:length(x),new,'nearest');
            K(j+1) = round(interp1q(x,[1:length(x)]',new));
        end
    end
else
    y = f;
    for i = 1:It
        xi = zeros(Nk+1,2);
        fi = zeros(Nk+1,2);
        D  = zeros(Nk+1,1);
        for j = 1:(Nk+1)
            xi(j,1) = 0.75*x(K(j)) + 0.25*x(K(j+1));
            xi(j,2) = 0.25*x(K(j)) + 0.75*x(K(j+1));
            fi(j,1) = interp1q(x,y,xi(j,1));
            fi(j,2) = interp1q(x,y,xi(j,2));
            D(j) = (fi(j,2) - fi(j,1))/(xi(j,2)-xi(j,1));
        end
        for j = 1:Nk
            a1 = D(j);
            b1 = fi(j,1);
            c1 = xi(j,1);
            a2 = D(j+1);
            b2 = fi(j+1,1);
            c2 = xi(j+1,1);
            new = ( ( b2 -a2*c2 ) - ( b1 - a1*c1 ) )/( a1 - a2 );
            %K(j+1) = interp1(x,1:length(x),new,'nearest');
            K(j+1) = round(interp1q(x,[1:length(x)]',new));
        end
    end
end
end
