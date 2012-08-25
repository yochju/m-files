function x = ThomasSolver(a,b,c,k,f)
%% Thomas algorithm for solving tridiagonal linear systems.
%
% x = ThomasSolver(a,b,c,k,f)
%
% Input parameters (required):
%
% a : vector containing the entries on the main diagonal.
% b : vector containing the entries on the upper diagonal.
% c : vector containing the entries on the lower diagonal.
% k : offset of the upper and lower diagonal.
% f : right hand side of the linear system.
%
% Output parameters:
%
% x : solution of the linear system A*x = f.
%
% Description:
%
% Uses the Thomas algorithm to solve the linear A*x = f, where A is a tri
% diagonal matrix. The offset of the off-diagonal entries can be arbitrary.
% However, it must be the same for the upper and the lower off-diagonal entries.
%
% Example:
%
%
%
% See also mldivide, mrdivide, lsqr, bicg, gmres

% Copyright 2012 Laurent Hoeltgen <laurent.hoeltgen@gmail.com>
%
% This program is free software; you can redistribute it and/or modify it under
% the terms of the GNU General Public License as published by the Free Software
% Foundation; either version 3 of the License, or (at your option) any later
% version.
%
% This program is distributed in the hope that it will be useful, but WITHOUT
% ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS
% FOR A PARTICULAR PURPOSE. See the GNU General Public License for more details.
%
% You should have received a copy of the GNU General Public License along with
% this program; if not, write to the Free Software Foundation, Inc., 51 Franklin
% Street, Fifth Floor, Boston, MA 02110-1301, USA.

% Last revision on: 25.08.2012 20:00

%% Check Input and Output Arguments

N = length(f);

m = zeros(N,1);
l = zeros(N-k,1);
r = zeros(N-k,1);

m(1:k) = c(1:k);
r=b;

for i = (k+1):N
    l(i-k) = c(i-k)/m(i-k);
    m(i) = a(i)-l(i-k)*r(i-k);
end

y = zeros(N,1);
y(1:k) = f(1:k);
for i = k+1:N
    y(i) = f(i)-l(i-k)*y(i-k);
end

x = zeros(N,1);
x((N-k+1):N) = y((N-k+1):N)./m((N-k+1):N);
for i= N-k:-1:1
    x(i) = (y(i)-r(i)*x(i+k))/m(i);
end
end
