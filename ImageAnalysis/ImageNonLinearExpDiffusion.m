function out = ImageNonLinearExpDiffusion(in)
%% Performs an explicit non linear diffusion step.

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

% Last revision on: 24.11.2012 21:41

% TODO: This is a draft version on how to do it (in theory). It does *not* do
% the correct thing (yet)!

temp = AddBoundaryData(in);
I=im2col(temp,[3 3],'sliding');
J=kron(ones(1,size(I,2)),[0 1 0 1 -4 1 0 1 0]');
K=I.*J;
L=sum(K);
out=reshape(L,size(in));
end
