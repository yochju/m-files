function [ uk ] = SplitBregman11( A, b, lambda, C, f, mu, iterout, iterin, iterout2, iterin2 )
%% Performs Bregman iteration with two 1-norm terms.
%
% Computes the minimum of ||Ax+b||_1 + lambda* ||Cx+f||_1
% mu is regularization weight
% iter is the number of iterations

% Copyright 2011, 2012 Laurent Hoeltgen <laurent.hoeltgen@gmail.com>
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

% Last revision on: 27.11.2012 14:40

bk = b;
dk = zeros(length(b),1);
for i=1:iterout
    for j=1:iterin
        uk = Optimization.SplitBregman12( lambda*C, lambda*f, mu, A, bk-dk, mu, iterout2, iterin2 );
        dk = sign( A*uk+bk ).*max( abs(A*uk+bk)-1.0/mu, 0 );
    end
    bk = bk + b - dk + A*uk;
end
end
