function x = SoftShrinkage(lambda,theta,A,B)
%Performs (multivariate) soft shrinkage (also extended variant).
%
%   Input parameters (required):
%
%   lambda: weight in front of the absolute value. (vector)
%   theta : weights in front of the quadratic terms. (matrix)
%   A     : weights in front of the unknown inside the quad. terms. (matrix)
%   B     : weights inside the quadratic terms. (matrix)
%
%   Output parameters:
%
%   x     : the minimzer of the considered energy functional.
%
%   Description:
%
%   SoftShrinkage solves the following multivariate unconstrained optimization
%   problem: 
%
%   argmin_{x} lambda*||x||_1 + sum_{i=1:N} theta(i)/2 * ||A(i)*x-B(i)||^2_2;
%
%   where:
%   lambda is a diagonal matrix with positive entries.
%   theta(i) is a diagonal matrix with positive entries for all i.
%   A(i) is a diagonal matrix for all i.
%   B(i) is a vector for all i.
%
%   Note that the problem decouples and can be treated componentwise.Thus, if
%   the solution is sought in R^k, and we have N quadratic terms, then the input
%   variables should have the following structure:
%
%   lambda : vector in R^k.
%   theta  : matrix in R^(k,N); 
%   A      : matrix in R^(k,N);
%   B      : matrix in R^(k,N);
%
%  It follows that the i-th entry of lambda and the i-th row of theta, A, B
%  will be used for for component x(i).
%
%   Example:
%
%   x = SoftShrinkage1D(3,5,2,8) solves the problem
%   argmin_{x} 3*abs(x) + 5/2 * ( 2*x - 8 )^2;
%
%   See also SoftShrinkage1D

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

% Last revision on: 10.08.2012 17:00

lambda = lambda(:);
k = length(lambda);
x = zeros(k,1);
for i = 1:k
    x(i) = SoftShrinkage1D(lambda(i),theta(i,:),A(i,:),B(i,:));
end

end
