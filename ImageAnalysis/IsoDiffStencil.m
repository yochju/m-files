function stencil = IsoDiffStencil(in, varargin)
%% Generate Stencil for isotropic (nonlinear) diffusion.
%
% stencil = IsoDiffStencil(in, varargin)
%
% Input parameters (required):
%
% in : Input image (double array).
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
% gradmag        : options to be used for the computation of the gradient
%                  magnitude (default = struct('scheme','central')).
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
% stencil : cell array containing the entries for the diffusion process.
%
% Output parameters (optional):
%
% -
%
% Description:
%
% -
%
% Example:
%
% -
%
% See also ExpNonLinIsoDiff, Stencil2Mat

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

% Last revision on: 06.06.2013 15:10

%% Notes

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
parser.addParamValue('gradmag', struct('scheme','central'), ...
    @(x) validateattributes(x, {'struct'}, {}, mfilename, 'gradmag'));

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

[nr nc] = size(temp);
g = diffuse(ImageGradMag(temp, ...
    'xSettings',opts.gradmag, ...
    'ySettings',opts.gradmag).^2);

% Compute the diffusivities.
gIminus = circshift(g,[0 1]);
gIminus(:,1)=gIminus(:,2);

gIplus = circshift(g,[0 -1]);
gIplus(:,nc)=gIplus(:,nc-1);

gJplus = circshift(g,[1 0]);
gJplus(1,:)=gJplus(2,:);

gJminus = circshift(g,[-1 0]);
gJminus(nr,:)=gJminus(nr-1,:);

% Set up the stencil entries.
S0 =zeros(nr,nc);
S1 = (1.0/2.0)*(gJplus+g);
S5 = (1.0/2.0)*(gJminus+g);
S2 = (1.0/2.0)*(gIminus+g);
S4 = (1.0/2.0)*(gIplus+g);
S3 = - S1 - S2 - S4 - S5;

% Set up the cell array for the non constant convolution.
stencil = { ...
    S0, S1, S0 ; ...
    S2, S3, S4 ; ...
    S0, S5, S0 };

end

function y = weickertdiffusivity(x,lambda)
y = zeros(size(x));
y(abs(x)<100*eps) = 1;
y(abs(x)>=100*eps) = 1 - exp(-3.31488./((x(abs(x)>=100*eps).^4)./lambda^8));
end
