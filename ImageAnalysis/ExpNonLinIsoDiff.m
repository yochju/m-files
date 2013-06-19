function [out, varargout] = ExpNonLinIsoDiff(in, varargin)
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
%                  (default 'fixed
% processTime    : total diffusion time of the process. (default = inf).
% fedopts        : options used for computing the fed time steps. (default
%                  struct([]))
% its            : number of iterations (default = inf).
% diffusivity    : which diffusivity should be used ('charbonnier',
%                  'perona-malik', 'exp-perona-malik', 'weickert' or 'custom')
%                  (default = charbonnier).
% diffusivityfun : function handle for custom diffusivty,
%                  (default = @(x) ones(size(x))
% gradmag        : options to be used for the computation of the gradient
%                  magnitude (default = struct('scheme','central')).
% convolve       : whether to compute the explicit time steps through a non
%                  constant convolution or through a matrix vector produt. The
%                  default is to use a convolution. (logical, default = true).
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
% T   : total diffusion time.
% its : number of iterations performed.
%
% Description:
%
% Performs a explicit nonlinear isotropic diffusion scheme on the input image.
%
% Example:
%
% I = rand(256,256)
% [J, T, its] = ExpNonLinIsoDiff(I,'its', 1000, 'diffusivity', 'weickert', ...
%    'timestepmethod', 'fixed', 'lambda', 3.5, 'tau', 0.25, 'sigma', 3.0, ...
%    'processTime', 320);
%
% See also ExpLinDiff

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

% Last revision on: 19.06.2013 12:00

%% Notes
%
% Thanks to Martin Schmidt for providing the code basis.
%
% TODO:
% - Add Gridsizes.
% - Add FED.
% - Allow a vector of timesteps to be passed. In that case, the
%   number of iterations coincides with the length of the vector.
% - Add handling of different boundary conditions.

%% Parse input and output.

narginchk(1, 23);
nargoutchk(0, 3);

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
parser.addParamValue('processTime', -1.0, @(x) validateattributes(x, ...
    {'double'}, {'scalar', 'nonnegative'}, mfilename, 'processTime'));
parser.addParamValue('timestepmethod', 'fixed', ...
    @(x) strcmpi(x, validatestring(x, ...
    {'fixed', 'adaptive', 'fed'}, ...
    mfilename, 'timestepmethod')));
parser.addParamValue('fedopts', struct([]), ...
    @(x) validateattributes(x, {'struct'}, {}, mfilename, 'fedopts'));
parser.addParamValue('its', 1, @(x) validateattributes(x, ...
    {'double'}, {'scalar', 'integer', 'positive'}, mfilename, 'its'));
parser.addParamValue('diffusivity', 'charbonnier', ...
    @(x) strcmpi(x, validatestring(x, ...
    {'charbonnier', 'perona-malik', 'exp-perona-malik', ...
    'weickert', 'custom'}, mfilename, 'diffusivity')));
parser.addParamValue('diffusivityfun', @(x) ones(size(x)), ...
    @(x) validateattributes(x, {'function_handle'}, {'scalar'}, ...
    mfilename, 'diffusivityfun'));
parser.addParamValue('gradmag', struct('scheme','central'), ...
    @(x) validateattributes(x, {'struct'}, {}, mfilename, 'gradmag'));
parser.addParamValue('convolve', true, @(x) validateattributes(x, ...
    {'logical'}, {'scalar'}, mfilename, 'convolve'));

parser.parse( in, varargin{:});
opts = parser.Results;

% Handle those cases, where it is not clear how far the process should run.
if isinf(opts.its) && isinf(opts.processTime)
    % Neither the maximal number of iterations, nor the total process time have
    % been specified. Impossible to find until what point to diffuse. Aborting.
    ExcM = ExceptionMessage('Input', 'message', ...
        'Either the number of iterations or the total time must be specified.');
    error(ExcM.id, ExcM.message);
elseif ~isinf(opts.its) && ~isinf(opts.processTime)
    % Both have been specified. In that case, the processTime wins.
    opts.its = intmax;
end

%% Run code.

switch lower(opts.timestepmethod)
    case 'fixed'
        ts = opts.tau;
    case 'adaptive'
        ts = -1.0; % Cannot be computed here.
    case 'fed'
        ts = -1.0; % Cannot be computed here.
end

out = in;
diffTime = 0;

% Iterate.
for i = 1:min(intmax,opts.its)
    
    S = IsoDiffStencil(in, ...
        'sigma', opts.sigma, ...
        'diffusivity', opts.diffusivity, ...
        'diffusivityfun', opts.diffusivityfun, ...
        'gradmag', opts.gradmag );
    
    % Set time step to maximal value for the current step.
    if strcmpi(opts.timestepmethod,'adaptive')
        % Multiplying by 1.01 ensures that we are really below the threshold.
        ts = 1./(1.01*max(abs(S{2,2}(:))));
    end
    
    % If the next timestep would exceed the specified process Time, make it
    % smaller.
    if opts.processTime > 0
        ts = min(ts, opts.processTime-diffTime);
    end
    
    % Perform a explicit diffusion step.
    if opts.convolve
        out = out + ts*NonConstantConvolution(out, S, 'correlation', true);
    else
        A = Stencil2Mat(S, 'boundary', 'Neumann');
        temp = out(:);
        temp = temp + ts*(A*temp);
        out = reshape(temp, size(out));
    end
    % Compute total diffusion time.
    diffTime = diffTime + ts;
    
    if (opts.processTime > 0) && (diffTime >= opts.processTime)
        % Stop iterating when we reach the specified process time.
        break;
    end
end

if nargout >= 2
    varargout{1} = diffTime;
end

if nargout >= 3
    varargout{2} = i; 
end
end
