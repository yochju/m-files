function E = CanonicBasisVector(i,n)
%% Computes the i-th canonical basis vector of length n.
%
% E = CanonicBasisVector(i,n)
%
% Computes the i-th canonical basis vector of length n. This vector has 1 at the
% i-th position and 0 everywhere else.
%
% Input Parameters (required)
%
% i : Position of the 1.
% n : Length of the vector.
%
% Example
%
% CanonicBasisVector(3,4) gives [0 ; 0 ; 1 ; 0 ].
%
% See also speye, eye.

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

% Last revision: 2012/03/14 16:30

%% Comments and Remarks.
%

%% Check input parameters

error(nargchk(2, 2, nargin));
error(nargoutchk(0, 1, nargout));

assert( IsInteger(i)&&IsInteger(n) , ...
    'LinearAlgebra:CanonicBasisVector:BadInput', ...
    ['The input values must be integer valued.']);

assert( (0<i) && (i<=n) , ...
    'LinearAlgebra:CanonicBasisVector:BadInput', ...
    ['The first argument must be larger than 0 and smaller than ' ...
     'the second argument.']);

%% Compute the Vector

E = zeros(n,1);
E(i) = 1;
end