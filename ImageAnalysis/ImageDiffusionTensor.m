function [ out ] = ImageDiffusionTensor(in, g, varargin)
%% Computes the diffusion tensor J(K_sigma((nabla u).(nabla u)'));

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

% Todo: This is not always noramlised...
grad = ImageGrad(in);
grad(:,:,1) = imfilter(grad(:,:,1), fspecial('gaussian'), 'symmetric');
grad(:,:,2) = imfilter(grad(:,:,2), fspecial('gaussian'), 'symmetric');
gMag = grad(:,:,1).^2 + grad(:,:,2).^2;
grad(:,:,1) = grad(:,:,1)./sqrt(gMag);
grad(:,:,2) = grad(:,:,2)./sqrt(gMag);
grad(or(isnan(grad),isinf(grad))) = 0;

diff = g(gMag);

v1 = grad;
v2 = cat(3, -grad(:,:,2) , grad(:,:,1));
out = zeros([size(in), 2, 2]);

out(:,:,1,1) = diff.*v1(:,:,1).^2 + 1.0*v2(:,:,1).^2;
out(:,:,1,2) = diff.*v1(:,:,1).*v1(:,:,2) + 1.0*v2(:,:,1)*v2(:,:,2);
out(:,:,2,1) = out(:,:,1,2);
out(:,:,2,2) = diff.*v1(:,:,2).^2 + 1.0*v2(:,:,2).^2;

end
