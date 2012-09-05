function Err = ErrorApproxLoc( f, x )
% [ Err ] = ErrorApproxLoc( f, x )
% ErrorApproxLoc computes the local L1 approximation error between two
% consecutive knots for the function f and its piecewise linear spline
% approximation with knots x.
%
% Usage: [ Err ] = ErrorApproxLoc( f, x )
% f   : a handle to the considered function.
% x   : an array with the support points for the linear splines.
% Err : an array with the conmputed errors for the approximation between x(i)
%       and x(i+1).
%
% See also ErrorApprox, ErrorInterp, ErrorInterpLoc, ErrorApproxInterval

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

narginchk(2,2);
nargoutchk(0,1);

Err = zeros(1,length(x)-1);
for i = 1:(length(x)-1)
    Err(i) = ErrorApproxInterval(f,x(i),x(i+1));
end
end
