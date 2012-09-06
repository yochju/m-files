function x = SoftShrinkage1D(lambda,theta,A,B)
%Performs univariate soft shrinkage (also extended variant).
%
%   Input parameters (required):
%
%   lambda: scalar weight in front of the absolute value.
%   theta : vector of weights in front of the quadratic terms.
%   A     : vector of weights in front of the unknown inside the quad. terms.
%   B     : vector of weights inside the quadratic terms.
%
%   Output parameters:
%
%   x     : the minimzer of the considered energy functional.
%
%   Description:
%
%   SoftShrinkage1D solves the following univariate unconstrained optimization
%   problem.
%
%   argmin_{x} lambda*abs(x) + sum_{i=1:N} theta(i)/2 * ( A(i)*x - B(i) )^2;
%
%   Example:
%
%   x = SoftShrinkage1D(3,5,2,8) solves the problem
%   argmin_{x} 3*abs(x) + 5/2 * ( 2*x - 8 )^2;
%   (= 3.85)
%
%   x = SoftShrinkage1D(3,[5 6],[1 2],[8 7]) solves the problem
%   argmin_{x} 3*abs(x) + 5/2 * ( x - 8 )^2 + 6/2 * ( 2*x - 7 ); 
%   (= 4.1724)
%
%   See also fminunc

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

% Last revision on: 13.08.2012 15:20

narginchk(4, 4);
nargoutchk(0, 1);

ExcM = ExceptionMessage('Input');

ExcM.message = 'Input does not have the correct structure.';
assert( isscalar(lambda) , ExcM.id, ExcM.message);
assert( isvector(theta) , ExcM.id, ExcM.message);
assert( isvector(A) , ExcM.id, ExcM.message);
assert( isvector(B) , ExcM.id, ExcM.message);

ExcM.message = 'Weights must all be positive.';
assert( lambda >= 0 , ExcM.id, ExcM.message );
assert( all( theta >= 0 ) , ExcM.id, ExcM.message );

ExcM.message = 'Number of weights and coefficients does not conincide.';
assert( length(theta)==length(A), ExcM.id, ExcM.message);
assert( length(theta)==length(B), ExcM.id, ExcM.message);

theta = theta(:);
A = A(:);
B = B(:);

[a b c] = CollectCoeffs(theta,A,B);
[a b ~] = QuadraticCompletion(a,b,c);
x = softshrink(b,lambda/a);

end

function [A B C] = CollectCoeffs(a,b,c)
% INPUT : coefficients a(i)*(b(i)*x-c(i))^2 for i = 1:n
% OUTPUT: coefficients A*x^2 + B*x + C such that both expressions are identical
% for all x.
A = dot(a(:),b(:).^2);
B = -2*dot(a(:),b(:).*c(:));
C = dot(a(:),c(:).^2);
end

function [A B C] = QuadraticCompletion(a,b,c)
% INPUT : Coefficients of a*x^2 + b*x + c
% OUTPUT: Coefficients of A*(x-B)^2+C such that both epressions are identical
% for all x.
A = a(:);
B = -b(:)./(2*a(:));
C = c(:) - (b(:).^2)./(4*a(:));
end

function out = softshrink(b,lam)
% Soft shrinkage function. Solves the univariate optimization problem
% argmin_{x} lam*abs(x) + 1/2*(x-b)^2;
out = sign(b).*max(abs(b)-lam,0);
end
