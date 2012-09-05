function [ E ] = ErrorApproxInterval(f,a,b)
% [ E ] = ErrorApproxInterval(f,a,b)
% Computes the error for the optimal L1 approximation with linear splines on
% the interval [a,b].
%
% Usage: [ Err ] = ErrorApprox( f, a, b )
% f : a handle to the considered function.
% a : lower bound of the interval.
% b : upper bound of the interval.
% E : the conmputed error for the approximation between a and b.
%
% See also ErrorApprox, ErrorApproxLoc, ErrorInterp, ErrorInterpLoc

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

narginchk(3,3);
nargoutchk(0,1);

E = quad(f,a,b) - 2*quad(f,0.75*a + 0.25*b,0.25*a + 0.75*b);
end
