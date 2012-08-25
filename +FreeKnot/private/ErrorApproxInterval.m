function [ E ] = ErrorApproxInterval(f,a,b)
% [ E ] = ErrorApproxInterval(f,a,b)
% Computes the error for the optimal L1 approximation with linear splines on
% the interval [a,b].
%
% Usage: [ Err ] = ErrorApprox( f, x )
% f : a handle to the considered function.
% a : lower bound of the interval.
% b : upper bound of the interval.
% E : the conmputed error for the approximation between a and b.

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

error(nargchk(3,3,nargin));

E = quad(f,a,b) - 2*quad(f,0.75*a + 0.25*b,0.25*a + 0.75*b);
end
