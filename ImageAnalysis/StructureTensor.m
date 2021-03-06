function [ out ] = StructureTensor(in, varargin)
%% Computes the structue tensor K_rho * nabla(u_sigma).nabla(u_sigma)'
%
% [ out ] = StructureTensor(in, ...)
%
% Input parameters (required):
%
% in : input image to be used for the computation of the structure tensor
%      (2d double array).
%
% Input parameters (parameters):
%
% Parameters are either struct with the following fields and corresponding
% values or option/value pairs, where the option is specified as a string.
%
% sigma : smoothing applied on the input image before computing the gradient.
%         (scalar, default = 0).
% rho   : smoothing applied on the tensor entries. (scalar, default = 0)
% grad  : options to be used for the computation of the gradient
%         (struct, default = struct('scheme','central')).
%
% Input parameters (optional):
%
% The number of optional parameters is always at most one. If a function takes
% an optional parameter, it does not take any other parameters.
%
% -
%
% Output parameters:
%
% out : structue tensor. If in is an nr*nc image, then out is a nr*nc*3 array
%       where the latter index denotes the tensor entries. The first entry
%       corresponds to (u_x)^2, the second to u_x*u_y and the third to (u_y).^2.
%
% Output parameters (optional):
%
% -
%
% Description:
%
% Computes the structure tensor K_rho * nabla(u_sigma).nabla(u_sigma)', where
% nabla(u) is the gradient of the image u. u_sigma means that u has been
% smoothed by gaussian convolution with standard deviation sigma and K_rho is a
% channelwise gaussian smoothing with standard deviation rho.
%
% Example:
%
% I = random(256, 256);
% J = StructureTensor(I, 'sigma', 0.1, 'rho', 1.5);
%
% See also Structure2DiffusionTensor

% Copyright 2013 Laurent Hoeltgen <laurent.hoeltgen@gmail.com>
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

% Last revision on: 12.07.2013 15:00

%% Notes

% References:
%
% Förstner, W.; Gülch, E. (June 1987). "A Fast Operator for Detection and
% Precise Location of Distinct Points, Corners and Centres of Circular
% Features". ISPRS Intercommission Workshop, Interlaken.

%% Parse input and output.

narginchk(1, 7);
nargoutchk(0, 1);

parser = inputParser;
parser.FunctionName = mfilename;
parser.CaseSensitive = false;
parser.KeepUnmatched = true;
parser.StructExpand = true;

parser.addRequired('in', @(x) validateattributes(x, {'numeric'}, ...
    {'nonempty','finite','2d'}, mfilename, 'in', 1));

parser.addParamValue('sigma', 0.0, @(x) validateattributes(x, ...
    {'double'}, {'scalar', 'nonnegative'}, mfilename, 'sigma'));

parser.addParamValue('rho', 0.0, @(x) validateattributes(x, ...
    {'double'}, {'scalar', 'nonnegative'}, mfilename, 'sigma'));

parser.addParamValue('grad', struct('scheme','central'), ...
    @(x) validateattributes(x, {'struct'}, {}, mfilename, 'grad'));

parser.parse( in, varargin{:});
opts = parser.Results;

%% Run code.

% Smooth input image
if opts.sigma > 0
    temp = imfilter( ...
        in, fspecial('gaussian', [7 7], opts.sigma), 'symmetric', 'same');
else
    temp = in;
end

% Compute image gradient.
grad = ImageGrad(temp, 'xSettings', opts.grad, 'ySettings', opts.grad);

% Compute the tensor nabla(u).nabla(u)'. Note that this tensor has one
% eigenvector parallel to the gradient and one perpendicular to the gradient.
% The eigenvalues are the squared euclidean norm of the gradient and 0. Note
% that the structure tensor is based on the non-normalised gradient.
[nr nc] = size(in);
out = zeros(nr, nc, 3);
out(:,:,1) = grad(:,:,1).^2;
out(:,:,2) = grad(:,:,1).*grad(:,:,2);
out(:,:,3) = grad(:,:,2).^2;

% Smooth the entries in the tensor nabla(u).nabla(u)'
if opts.rho > 0
    out(:,:,1) = imfilter( out(:,:,1), ...
        fspecial('gaussian', [7 7], opts.rho), 'symmetric', 'same');
    out(:,:,2) = imfilter( out(:,:,2), ...
        fspecial('gaussian', [7 7], opts.rho), 'symmetric', 'same');
    out(:,:,3) = imfilter( out(:,:,3), ...
        fspecial('gaussian', [7 7], opts.rho), 'symmetric', 'same');
end

end
