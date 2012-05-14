function err = PeakSignalToNoiseRatio(I1,I2,M)
%% Compute the peak signal to noise ratio between two signals.
%
% err = PeakSignalToNoiseRatio(I1,I2,M)
%
% Input Parameters (required):
%
% I1 : first input image (double matrix).
% I2 : second input image (double matrix).
% M  : theoretically maximal signal value. (scalar, default = 1);
%
% Output Parameters
%
% err : peak to signal ratio (scalar or array).
%
% Example
%
% Compute the mean square error between two random matrices.
% I1 = rand(10,10);
% I2 = rand(10,10);
% err = PeakSignalToNoiseRatio(I1,I2);
%
% See also norm, MeanSquareError.

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

% Last revision: 2012/04/16 12:25

%% Check input parameters

error(nargchk(2, 3, nargin));
error(nargoutchk(0, 1, nargout));
dim = size(I1);
assert(isequal(size(I1),size(I2)), ...
    'ImageAnalysis:MeanSquareError:BadInput', ...
    'Input data has not the same dimensions.');

if nargin == 2
    M = 1.0;
end

%% Compute error
err = 10*log10(M^2./MeanSquareError(I1,I2));
end