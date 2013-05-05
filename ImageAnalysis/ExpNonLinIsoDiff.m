function [out] = ExpNonLinIsoDiff(in, varargin)
%% Perform explicit non linear isotropic diffusion
%
% [out] = ExpNonLinIsoDiff(in, varargin)
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
% tau            : time step size (default = 0.25).
% timestepmethod : how the time steps are chosen. ('fixed', 'adaptive', 'fed')
%                  (default 'fixed')
% its            : number of iterations (default = 1).
% diffusivity    : which diffusivity should be used ('charbonnier', 
%                  'perona-malik' or 'custom') (default = charbonnier).
% diffusivityfun : function handle for custom diffusivty,
%                  (default = @(x) ones(size(x))
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
% out : the diffused image.
%
% Output parameters (optional):
%
% -
%
% Description:
%
% Performs a explicit nonlinear isotropic diffusion scheme on the input image.
%
% Example:
%
% -
%
% See also

% Copyright 2013 Laurent Hoeltgen <laurent.hoeltgen@gmail.com>, Martin Schmidt
% <schmidt@mia.uni-saarland.de>
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

% Last revision on: 03.05.2013 09:25

%% Notes
%
% Thanks to Martin Schmidt for providing the code basis.
%
% TODO:
% - Add Gridsizes.
% - Add FED.

%% Parse input and output.

narginchk(1, 13);
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
parser.addParamValue('tau', 0.20, @(x) validateattributes(x, ...
    {'double'}, {'scalar', 'nonnegative'}, mfilename, 'tau'));
parser.addParamValue('timestepmethod', 'fixed', ...
    @(x) strcmpi(x, validatestring(x, ...
    {'fixed', 'adaptive', 'fed'}, ...
    mfilename, 'timestepmethod')));
parser.addParamValue('its', 1, @(x) validateattributes(x, ...
    {'double'}, {'scalar', 'integer', 'positive'}, mfilename, 'its'));
parser.addParamValue('diffusivity', 'charbonnier', ...
    @(x) strcmpi(x, validatestring(x, ...
    {'charbonnier', 'perona-malik', 'custom'}, ...
    mfilename, 'diffusivity')));
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
    case 'custom'
        diffuse = opts.diffusivityfun;
end

switch lower(opts.timestepmethod)
    case 'fixed'
        ts = opts.tau;
    case 'adaptive'
        ts = -1.0; % Cannot be computed here.
    case 'fed'
        ts = -1.0; % Cannot be computed here.
end

out = in;
[nr nc] = size(out);

% Iterate.
for i = 1:opts.its
    % Compute the gradient magnitude of the smoothed image.
    if opts.sigma > 0
        temp = imfilter( ...
            out, fspecial('gaussian', [7 7], opts.sigma), 'symmetric', 'same');
    else
        temp = out;
    end
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
    
    S0 =zeros(nr,nc);
    S1 = (1.0/2.0)*(gJplus+g);
    S5 = (1.0/2.0)*(gJminus+g);
    S2 = (1.0/2.0)*(gIminus+g);
    S4 = (1.0/2.0)*(gIplus+g);
    S3 = - S1 - S2 - S4 - S5;
    
    if strcmpi(opts.timestepmethod,'adaptive')
        % Multiplying by 1.01 ensures that we are really below the threshold.
        ts = 1./(1.01*max(abs(S3(:))));
    end
    
    % Set up the cell array for the non constant convolution.
    S={ ...
        S0, S1, S0 ; ...
        S2, S3, S4 ; ...
        S0, S5, S0 };
    
    % Perform a explicit diffusion step
    out = out + ts*NonConstantConvolution(out, S, 'correlation', true);
end

end
