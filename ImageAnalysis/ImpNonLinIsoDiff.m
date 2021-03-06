function [out, varargout] = ImpNonLinIsoDiff(in, varargin)
%% Perform explicit non linear isotropic diffusion
%
% [out] = ImpNonLinIsoDiff(in, varargin)
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
% lambda         : diffusivity parameter (scalar, default = 0.5).
% sigma          : smoothing parameter used for the computation of the gradient
%                  magnitude (scalar, default = 0).
% tau            : time step size (scalar, default = 0.20).
% timestepmethod : how the time steps are chosen. ('fixed', 'fed')
%                  (string, default = 'fixed')
% processTime    : total diffusion time of the process. (scalar, default = inf).
% fedopts        : options used for computing the fed time steps. (struct,
%                  default = struct([]))
% its            : number of iterations (scalar, default = inf).
% diffusivity    : which diffusivity should be used ('charbonnier',
%                  'perona-malik', 'exp-perona-malik', 'weickert' or 'custom')
%                  (string, default = charbonnier).
% diffusivityfun : function handle for custom diffusivty,
%                  (handle, default = @(x) ones(size(x))
% gradmag        : options to be used for the computation of the gradient
%                  magnitude (struct, default = struct('scheme','central')).
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
% [J, T, its] = ImpNonLinIsoDiff(I,'its', 1, 'diffusivity', 'weickert', ...
%    'timestepmethod', 'fixed', 'lambda', 3.5, 'tau', 320, 'sigma', 3.0);
%
% See also ExpNonLinIsoDiff

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

% Last revision on: 19.06.2013 15:00

%% Notes
%
% TODO:
% - Add Gridsizes.
% - Add FED.
% - Allow a vector of timesteps to be passed. In that case, the
%   number of iterations coincides with the length of the vector.

%% Parse input and output.

narginchk(1, 21);
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
parser.addParamValue('processTime', inf, @(x) validateattributes(x, ...
    {'double'}, {'scalar', 'nonnegative'}, mfilename, 'processTime'));
parser.addParamValue('timestepmethod', 'fixed', ...
    @(x) strcmpi(x, validatestring(x, ...
    {'fixed', 'fed'}, ...
    mfilename, 'timestepmethod')));
parser.addParamValue('fedopts', struct([]), ...
    @(x) validateattributes(x, {'struct'}, {}, mfilename, 'fedopts'));
parser.addParamValue('its', inf, @(x) validateattributes(x, ...
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

parser.parse(in, varargin{:});
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
    case 'fed'
        ts = -1.0; % Cannot be computed here.
end

out = in;
diffTime = 0;

% Iterate.
for i = 1:min(intmax, opts.its)
    
    S = IsoDiffStencil(out, ...
        'sigma', opts.sigma, ...
        'diffusivity', opts.diffusivity, ...
        'diffusivityfun', opts.diffusivityfun, ...
        'gradmag', opts.gradmag );
    
    % If the next timestep would exceed the specified process Time, make it
    % smaller.
    if opts.processTime > 0
        ts = min(ts, opts.processTime-diffTime);
    end
    
    % Perform a implicit diffusion step.
    % Setup the matrix.
    A = speye(numel(out),numel(out)) - ts*Stencil2Mat(S, 'boundary', 'Neumann');
    % Compute RHS.
    temp = out(:);
    % Solve Linear system.
    temp = A\temp;
    % Reshape data.
    out = reshape(temp, size(out));
    
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
