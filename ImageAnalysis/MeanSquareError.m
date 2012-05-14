function err = MeanSquareError(I1,I2)
%% Compute the mean square error between two matrices/images.
%
% err = MeanSquareError(I1,I2)
%
% Input Parameters (required):
%
% I1 : first input image (double array with up to 3 dimensions).
% I2 : second input image (double array with up to 3 dimensions).
%
% Output Parameters
%
% err : the mean square error (scalar or array).
%
% Example
%
% Compute the mean square error between two random matrices (gray value images).
% I1 = rand(10,10);
% I2 = rand(10,10);
% err = MeanSquareError(I1,I2);
%
% Compute the mean squar error (channelwise) between to color images with 4
% channels each.
% I1 = rand([10,10,4]);
% I2 = rand([10,10,4]);
% err = MeanSquareError(I1,I2);
%
% See also norm, PeakSignalToNoiseRatio

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

% Last revision: 2012/04/16 12:16

%% Check input parameters

error(nargchk(2, 2, nargin));
error(nargoutchk(0, 1, nargout));
dim = size(I1);
assert(isequal(size(I1),size(I2)), ...
    'ImageAnalysis:MeanSquareError:BadInput', ...
    'Input data has not the same dimensions.');

%% Compute error
% If the input image has more than 1 channel, we return the MSE for each channel
% individually.

switch length(dim)
    case 1
        err = sum((I1-I2).^2)/numel(I1);
    case 2
        err = sum(sum((I1-I2).^2))/numel(I1);
    case 3
        err = zeros(dim(3),1);
        for i = 1:dim(3)
            err(i) = sum(sum((I1(:,:,i)-I2(:,:,i)).^2))/numel(I1(:,:,i));
        end
    otherwise
        error('ImageAnalysis:MeanSquareError:BadInput', ...
            'Tensors with more than 3 dimensions are not supported.');
end
end