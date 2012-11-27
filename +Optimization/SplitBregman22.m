function [ uk ] = SplitBregman22( A, b, lambda, C, f, mu, iterout, iterin )
%% Performs Bregman iteration with two 2-norm terms.
%
% Computes the minimum of 0.5*||Ax+b||^2 + lambda/2*||Cx+f||^2
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
        uk = (lambda*C'*C + mu*A'*A )\(mu*A'*(dk-bk)-lambda*C'*f);
        dk = mu/(1.0+mu)*(A*uk+bk);
    end
    bk = bk + b - dk + A*uk;
end
end
