function [ out ] = DiffusionTensor(in, varargin)
%% Computes the diffusion tensor J(K_sigma((nabla u).(nabla u)'));
%
% [ out ] = ImageDiffusionTensor(in, ...)
%
% Input parameters (required):
%
% in : input image to be used for the computation of the diffusion tensor
%      (2d double array).
%
% Input parameters (parameters):
%
% Parameters are either struct with the following fields and corresponding
% values or option/value pairs, where the option is specified as a string.
%
% lambda         : diffusivity parameter (default = 0.5).
% sigma          : smoothing parameter used for the computation of the gradient
%                  magnitude (default = 0).
% diffusivity    : which diffusivity should be used ('charbonnier',
%                  'perona-malik', 'exp-perona-malik', 'weickert' or 'custom')
%                  (default = charbonnier).
% diffusivityfun : function handle for custom diffusivty,
%                  (default = @(x) ones(size(x)). Note that the function must be
%                  scalar valued function which is pointwise applicable on
%                  arrays of arbitrary size. Further, it should return 1.0 for
%                  0.0 as input. A warning is emitted otherwise.
% grad           : options to be used for the computation of the gradient
%                  (default = struct('scheme','central')).
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
% -
%
% Output parameters (optional):
%
% out : diffusion tensor. If in is an nr*nc image, then out is a nr*nc*2*2 array
%       where the latter two indices denote the tensor entries.
%
% Description:
%
% Computes the diffusion tensor g(nabla(u)*nabla(u)'), where nabla(u) is the
% gradient of the image u and where g is a scalar valued smooth monotonically
% decreasing function on the interval [0,inf) with g(0)=1.
%
% Example:
%
% -
%
% See also IsoDiffStencil, Tensor2Stencil, Stencil2Mat

% Copyright 2012, 2013 Laurent Hoeltgen <laurent.hoeltgen@gmail.com>
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

% Last revision on: 09.07.2013 15:10

%% Notes

% References:
%
% Functions of Matrices, Theory and Computation
% Nicholas J. Higham,
% Society for Industrial and Applied Mathematics, 2008
% ISBN: 978-0-89871-646-7
%
% Anisotropic Diffusion in Image Processing
% J. Weickert,
% Teubner, Stuttgart, 1998.
% Available from: http://www.mia.uni-saarland.de/weickert/book.html

% TODO: Extend this code to compute the structure tensor too. Requires
% convolving the matrix entrie of nabla(u)*nabla(u)'. v1 and v2 will then be the
% eigenvectors and l1 and l2 the corresponding eigenvalues.

%% Parse input and output.

narginchk(1, 11);
nargoutchk(0, 1);

parser = inputParser;
parser.FunctionName = mfilename;
parser.CaseSensitive = false;
parser.KeepUnmatched = true;
parser.StructExpand = true;

parser.addRequired('in', @(x) validateattributes(x, {'numeric'}, ...
    {'nonempty','finite','2d'}, mfilename, 'in', 1));

parser.addParamValue('lambda', 0.5, @(x) validateattributes(x, ...
    {'double'}, {'scalar', 'nonnegative'}, mfilename, 'lambda'));
parser.addParamValue('sigma', 0.0, @(x) validateattributes(x, ...
    {'double'}, {'scalar', 'nonnegative'}, mfilename, 'sigma'));
parser.addParamValue('diffusivity', 'custom', ...
    @(x) strcmpi(x, validatestring(x, ...
    {'charbonnier', 'perona-malik', 'exp-perona-malik', ...
    'weickert', 'custom'}, mfilename, 'diffusivity')));
parser.addParamValue('diffusivityfun', @(x) ones(size(x)), ...
    @(x) validateattributes(x, {'function_handle'}, {'scalar'}, ...
    mfilename, 'diffusivityfun'));
parser.addParamValue('grad', struct('scheme','central'), ...
    @(x) validateattributes(x, {'struct'}, {}, mfilename, 'grad'));

parser.parse( in, varargin{:});
opts = parser.Results;

%% Run code.

% Define the diffusivity function to be used.
switch lower(opts.diffusivity)
    case 'charbonnier'
        diffuse = @(x) 1.0./sqrt(1.0 + x/opts.lambda^2);
    case 'perona-malik'
        diffuse = @(x) 1.0./(1.0 + x/opts.lambda^2);
    case 'exp-perona-malik'
        diffuse = @(x) exp(-x./(2*opts.lambda^2));
    case 'weickert'
        diffuse = @(x) weickertdiffusivity(x, opts.lambda);
    case 'custom'
        diffuse = opts.diffusivityfun;
        if abs(diffuse(0)-1.0) >= 1e-10
            ExcM = ExceptionMessage('Input', 'message', ...
                'Diffusivity should return 1 for input 0.');
            warning(ExcM.id, ExcM.message);
        end
end

if opts.sigma > 0
    temp = imfilter( ...
        in, fspecial('gaussian', [7 7], opts.sigma), 'symmetric', 'same');
else
    temp = in;
end

% Compute Image gradient.
grad = ImageGrad(temp, 'xSettings', opts.grad, 'ySettings', opts.grad);

% Compute squared euclidean norm of the gradient.
gMag = grad(:,:,1).^2 + grad(:,:,2).^2;

% Normalise gradient.
grad(:,:,1) = grad(:,:,1)./sqrt(gMag);
grad(:,:,2) = grad(:,:,2)./sqrt(gMag);

% Gradient is 0 in flat regions. We use the convention 0/0 = 0.
grad(or(isnan(grad),isinf(grad))) = 0;

% The diffusion tensor is defined through its eigenvectors and eigenvalues. The
% eigenvectors should be the (normalised) gradient (= v1) and a vector
% perpendicular to the gradient (= v2).
v1 = grad;
v2 = cat(3, -grad(:,:,2) , grad(:,:,1));

% Apply the diffusivity on the eigenvalues. The eigenvalues of the matrix
% grad*grad' are given by ||grad||^2 and 0. We apply the diffusivity on these
% eigenvalues and use them for the diffusion tensor. Note that the eigenvalue
% corresponding to the eigenvector perpendicular to the gradient is 0 and by
% requirement, g(0)=1.0. This means, that we will apply full diffusion along
% edges and inhibit diffusion across edges.
l1 = diffuse(gMag);
l2 = ones(size(in));

% Allocate space for the tensor entries.
out = zeros([size(in), 2, 2]);

% out = [v1 v2]*diag(l1,l2)*[v1 v2]'.
out(:,:,1,1) = l1.*v1(:,:,1).^2 + l2.*v2(:,:,1).^2;
out(:,:,1,2) = l1.*v1(:,:,1).*v1(:,:,2) + l2.*v2(:,:,1).*v2(:,:,2);
out(:,:,2,1) = out(:,:,1,2); % The tensor is symmetric by definition.
out(:,:,2,2) = l1.*v1(:,:,2).^2 + l2.*v2(:,:,2).^2;

end

function y = weickertdiffusivity(x,lambda)
y = zeros(size(x));
y(abs(x)<100*eps) = 1;
y(abs(x)>=100*eps) = 1 - exp(-3.31488./((x(abs(x)>=100*eps).^4)./lambda^8));
end
