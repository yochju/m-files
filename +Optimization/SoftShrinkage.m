function x = SoftShrinkage(lambda,theta,A,B)
%Performs (multivariate) soft shrinkage (also extended variant).
%
%   Input parameters (required):
%
%   lambda: weight in front of the absolute value. (vector)
%   theta : weights in front of the quadratic terms. (vector)
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
%   argmin_{x} ||lambda*x||_1 + sum_{i=1:N} theta(i)/2*||A(:,i)*x-B(:,i)||^2_2;
%
%   where:
%   lambda is a diagonal matrix with positive entries.
%   theta(i) is a positive weight for all i.
%   A(:,i) is a diagonal matrix for all i.
%   B(:,i) is a vector for all i.
%
%   Note that the problem decouples and can be treated componentwise.Thus, if
%   the solution is sought in R^k, and we have N quadratic terms, then the input
%   variables should have the following structure:
%
%   lambda : vector in R^k.
%   theta  : vector in R^(N); 
%   A      : matrix in R^(k,N);
%   B      : matrix in R^(k,N);
%
%  It follows that the i-th entry of lambda and the i-th row of theta, A, B
%  will be used for for component x(i).
%
%   Example:
%
%   lambda = [3.5 3.5 3.5 3.5];
%   theta  = 1;
%   A      = [1 ; 1 ; 1 ; 1];
%   B      = [3 ; 4 ; 5 ; 6];
%   x = Softhrinkage(lambda,theta,A,B) will return
%   x = [0 0.5 1.5 2.5];
%   which is the minimizer of the energy functional
%   lambda*||x||_1 + 1/2*||x - [3 ; 4 ; 5 ; 6]||_2^2;
%
%   lambda = [4 0.02 6];
%   theta  = [1 10]; 
%   A      = [7 2 ; 0 -6 ; 1 6];
%   B      = [2 6 ; 2 4 ; 3 8 ];
%   x = Softhrinkage(lambda,theta,A,B) will return
%   x = [ 1.4067 ; - 0.6666 ; 1.3213 ];
%   which is the minimizer of the energy functional
%   ||diag(lambda)*x||_1 + sum_{i=1:2} theta(i)/2*||A(:,i)*x-B(:,i)||_2^2
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

% Last revision on: 13.08.2012 16:00

error(nargchk(4, 4, nargin));
error(nargoutchk(0, 1, nargout));

ExcM = ExceptionMessage('Input');

ExcM.message = 'Input does not have the correct structure.';
assert( isvector(lambda) , ExcM.id, ExcM.message);
assert( isvector(theta) , ExcM.id, ExcM.message);
assert( ismatrix(A) , ExcM.id, ExcM.message);
assert( ismatrix(B) , ExcM.id, ExcM.message);

ExcM.message = 'Weights must all be positive.';
assert( all( lambda >= 0 ) , ExcM.id, ExcM.message );
assert( all( theta >= 0 ) , ExcM.id, ExcM.message );

lambda = lambda(:);
k = length(lambda);
N = length(theta);

ExcM.message = 'Number of weights and coefficients does not conincide.';
assert( isequal(size(A),[k N]), ExcM.id, ExcM.message);
assert( isequal(size(B),[k N]), ExcM.id, ExcM.message);

x = zeros(k,1);
for i = 1:k
    x(i) = SoftShrinkage1D(lambda(i),theta,A(i,:),B(i,:));
end

end
