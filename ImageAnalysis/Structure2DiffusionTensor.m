function [ out ] = Structure2DiffusionTensor(in, varargin)
%% Converts a structure tensor to a diffusion tensor.
%
% [ out ] = ImageDiffusionTensor(in, ...)
%
% Input parameters (required):
%
% in : structure tensor as computed by StructureTensor.
%
% Input parameters (parameters):
%
% Parameters are either struct with the following fields and corresponding
% values or option/value pairs, where the option is specified as a string.
%
% mode           : which mode should be applied. Possible choices are 'eced' or
%                  'ced'
% lambda         : diffusivity parameter (default = 0.5).
% alpha          : parameter for the ced mode.
% C              : parameter for the ced mode.
% diffusivity    : which diffusivity should be used ('charbonnier',
%                  'perona-malik', 'exp-perona-malik', 'weickert' or 'custom')
%                  (default = charbonnier).
% diffusivityfun : function handle for custom diffusivty,
%                  (default = @(x) ones(size(x)). Note that the function must be
%                  scalar valued function which is pointwise applicable on
%                  arrays of arbitrary size. Further, it should return 1.0 for
%                  0.0 as input. A warning is emitted otherwise.
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
% Computes the diffusion tensor g( K_rho * nabla(u).nabla(u)'), where nabla(u)
% is the gradient of the image u and where g is a scalar valued smooth
% function
%
% Example:
%
% -
%
% See also StructureTensor

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

%% Parse input and output.

narginchk(1, 13);
nargoutchk(0, 1);

parser = inputParser;
parser.FunctionName = mfilename;
parser.CaseSensitive = false;
parser.KeepUnmatched = true;
parser.StructExpand = true;

parser.addRequired('in', @(x) validateattributes(x, {'numeric'}, ...
    {'nonempty','finite'}, mfilename, 'in', 1));

parser.addParamValue('lambda', 0.5, @(x) validateattributes(x, ...
    {'double'}, {'scalar', 'nonnegative'}, mfilename, 'lambda'));

parser.addParamValue('alpha', 0.0, @(x) validateattributes(x, ...
    {'double'}, {'scalar', 'positive'}, mfilename, 'alpha'));

parser.addParamValue('C', 0.0, @(x) validateattributes(x, ...
    {'double'}, {'scalar', 'nonnegative'}, mfilename, 'C'));

parser.addParamValue('mode', 'eced', ...
    @(x) strcmpi(x, validatestring(x, {'eced', 'ced'}, mfilename, 'mode')));

parser.addParamValue('diffusivity', 'custom', ...
    @(x) strcmpi(x, validatestring(x, ...
    {'charbonnier', 'perona-malik', 'exp-perona-malik', ...
    'weickert', 'custom'}, mfilename, 'diffusivity')));

parser.addParamValue('diffusivityfun', @(x) ones(size(x)), ...
    @(x) validateattributes(x, {'function_handle'}, {'scalar'}, ...
    mfilename, 'diffusivityfun'));

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
end

% Extract tensor entries.
a = in(:,:,1);
b = in(:,:,2);
c = in(:,:,3);

% Compute Eigenvalues of the structure tensor.
[nr nc] = size(in(:,:,1));
vals = nan([nr nc 2]);
vals(:,:,1) = 0.5*(a+c-sqrt(4*b.^2+(a-c).^2));
vals(:,:,2) = 0.5*(a+c+sqrt(4*b.^2+(a-c).^2));

% Compute Eigenvectors of the structue tensor.
vecs = nan([nr nc 2 2]);

ind = find(abs(b)<1e-10);
[I, J] = ind2sub([nr nc],ind);
vecs(:,:,1,1) = a-c-sqrt(4*b.^2+(a-c).^2);
vecs(:,:,1,2) = 2*b;
% If b == 0, the matrix was already diagonal.
vecs(I,J,1,1) = 1;
vecs(I,J,1,2) = 0;
vecs(:,:,2,1) = a-c+sqrt(4*b.^2+(a-c).^2);
vecs(:,:,2,2) = 2*b;
% If b == 0, the matrix was already diagonal.
vecs(I,J,2,1) = 0;
vecs(I,J,2,2) = 1;
norm1 = sqrt(vecs(:,:,1,1).^2 + vecs(:,:,1,2).^2);
norm2 = sqrt(vecs(:,:,2,1).^2 + vecs(:,:,2,2).^2);
% Normalise vectors.
vecs(:,:,1,1) = vecs(:,:,1,1)./norm1;
vecs(:,:,1,2) = vecs(:,:,1,2)./norm1;
vecs(:,:,2,1) = vecs(:,:,2,1)./norm2;
vecs(:,:,2,2) = vecs(:,:,2,2)./norm2;

switch lower(opts.mode)
    case 'eced'
        vals = diffuse(vals);
    case 'ced'
        temp = vals;
        vals(:,:,1) = opts.alpha;
        vals(:,:,2) = opts.alpha + ...
            (1-opts.alpha)*exp(-opts.C./(temp(:,:,1)-temp(:,:,2)).^2);
end

out = nan([nr nc 3]);
out(:,:,1) = vals(:,:,1).*vecs(:,:,1,1).^2 + vals(:,:,2).*vecs(:,:,2,1).^2;
out(:,:,2) = vals(:,:,1).*vecs(:,:,1,1).*vecs(:,:,1,2) + ...
    vals(:,:,2).*vecs(:,:,2,1).*vecs(:,:,2,2);
out(:,:,3) = vals(:,:,1).*vecs(:,:,1,2).^2 + vals(:,:,2).*vecs(:,:,2,2).^2;

end

function y = weickertdiffusivity(x, lambda)
y = zeros(size(x));
y(abs(x)<100*eps) = 1;
y(abs(x)>=100*eps) = 1 - exp(-3.31488./((x(abs(x)>=100*eps).^4)./lambda^8));
end
