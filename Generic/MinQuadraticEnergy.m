function x = MinQuadraticEnergy(theta,A,b)
%Computes minimizer of quadratic energies with arbitrarily many terms.
%
%   Input parameters (required):
%
%   theta : weights in front of the quadratic terms. (vector)
%   A     : Matrices inside the quadratic terms. (cell vector)
%   b     : vectors inside the quadratic terms. (cell vector)
%
%   Output parameters:
%
%   x     : the minimzer of the considered energy functional.
%
%   Description:
%
%   MinQuadraticEnergy solves the following multivariate unconstrained
%   optimization problem:
%
%   argmin_{x} sum_{i=1:N} theta(i)/2*||A(i)*x-b(i)||_2^2
%
%   where:
%   theta(i) is a positive weight for all i.
%   A(i) is a matrix for all i.
%   b(i) is a vector for all i.
%
%   Example:
%
%   A = cell(2,1);
%   b = cell(2,1);
%   theta = [2 4];
%   A{1} = [ 1 2 3 ; 3 2 1 ; 9 1 2 ];
%   b{1} = [4 ; 5 ; 6];
%   A{2} = [ 5 2 1 ; 3 100 1 ; -9 1 2 ];
%   b{2} = [1 ; 1 ; 1];
%   MinQuadraticEnergy(theta,A,b)
%   yields the result
%   [ 0.2251 ; -0.0117 ; 1.4862 ]
%
%   See also lsqlin

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

% Last revision on: 13.08.2012 15:00

error(nargchk(3, 3, nargin));
error(nargoutchk(0, 1, nargout));

ExcM = ExceptionMessage('Input');

ExcM.message = 'Input does not have the correct structure.';
assert( isvector(theta) , ExcM.id, ExcM.message);

ExcM.message = 'Weights must all be positive.';
assert( all( theta >= 0 ) , ExcM.id, ExcM.message );

ExcM.message = 'Input does not have the correct structure.';
assert( iscell(A)&&isvector(A), ExcM.id, ExcM.message);
assert( iscell(b)&&isvector(A), ExcM.id, ExcM.message);

ExcM.message = 'Number of weights and linear systems does not conincide.';
assert( length(theta)==length(A), ExcM.id, ExcM.message);
assert( length(theta)==length(b), ExcM.id, ExcM.message);

N = length(theta);

ExcM2 = ExceptionMessage('BadDim');
for i = 1:N
    assert( ismatrix(A{i}), ExcM.id, ExcM.message);
    assert( iscolumn(b{i}), ExcM.id, ExcM.message);
    assert( isequal( size(A{i},1), size(b{i}) ), ExcM2.id, ExcM2.message);
end

LHS = theta(1)*transpose(A{1})*A{1};
RHS = theta(1)*transpose(A{1})*b{1};
for i=2:N
    LHS = LHS + theta(i)*transpose(A{i})*A{i};
    RHS = RHS + theta(i)*transpose(A{i})*b{i};
end
x = LHS\RHS;

end
