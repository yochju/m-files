function Err = ErrorInterpLoc( f, x )
% [ Err ] = ErrorInterpLoc( f, x )
% ErrorInterpLoc computes the local L1 interpolation error between two
% consecutive knots for the function f and its piecewise linear spline
% interpolation with knots x.
%
% Usage: [ Err ] = ErrorInterpLoc( f, x )
% f   : a handle to the considered function.
% x   : an array with the support points for the linear splines.
% Err : an array with the conmputed errors for the approximation between x(i)
%       and x(i+1).

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

error(nargchk(2,2,nargin));

Err = zeros(1,length(x)-1);
for i = 1:(length(x)-1)
    Err(i) = 0.5*( x(i+1)-x(i) )*( f(x(i+1)) + f(x(i)) ) - quad(f,x(i),x(i+1));
end
end
