function [out, varargout] = ExplicitDiffusion(in, varargin)
%% Perform explicit non linear anisotropic diffusion
%
% [out] = ExpNonLinAniDiff(in, varargin)
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
% sigma          : smoothing parameter used for the structure tensor
%                  computation. (default = 0).
% rho            : smoothing parameter used for the structure tensor
%                  computation. (default = 0).
% grad           : options to be used for the computation of the gradient
%                  for the structure tensor.
%                  (default = struct('scheme','central')).
% mode           : wich mode to use for the computation of the diffusion tensor.
%                  (default = 'eced').
% cedalpha       : model paramater for the 'ced' mode.
% cedC           : model parameter for the 'ced' mode.
% tau            : time step size (default = 0.20).
% timestepmethod : how the time steps are chosen. ('fixed', 'adaptive', 'fed')
%                  (default 'fixed
% processTime    : total diffusion time of the process. (default = inf).
% fedopts        : options used for computing the fed time steps. (default
%                  struct([]))
% its            : number of iterations (default = inf).
% lambda         : diffusivity parameter (default = 0.5).
% diffusivity    : which diffusivity should be used ('charbonnier',
%                  'perona-malik', 'exp-perona-malik', 'weickert' or 'custom')
%                  (default = charbonnier).
% diffusivityfun : function handle for custom diffusivty,
%                  (default = @(x) ones(size(x))
% alpha          : discretisation parameter for the stencil. (default =
%                  zeros(size(in)).
% beta           : discretisation parameter for the stencil. (default =
%                  zeros(size(in))
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
% Performs a explicit nonlinear anisotropic diffusion scheme on the input image.
%
% Example:
%
% I = rand(256,256)
% [J, T, its] = ExpNonLinAniDiff(I,'its', 1000, 'diffusivity', 'weickert', ...
%    'timestepmethod', 'fixed', 'lambda', 3.5, 'tau', 0.25, 'sigma', 3.0, ...
%    'processTime', 320);
%
% See also ExpLinDiff, ExpNonLinIsoDiff

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

% Last revision on: 12.07.2013 16:00

%% Notes
%
% TODO:
% - Add Gridsizes.
% - Add FED.
% - Allow a vector of timesteps to be passed. In that case, the
%   number of iterations coincides with the length of the vector.
% - Add handling of different boundary conditions.
%
% References
%
% Anisotropic Diffusion in Image Processing
% J. Weickert,
% Teubner, Stuttgart, 1998.
% Available from: http://www.mia.uni-saarland.de/weickert/book.html

%% Parse input and output.

narginchk(1, 34);
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
parser.addParamValue('rho', 0.0, @(x) validateattributes(x, ...
    {'double'}, {'scalar', 'nonnegative'}, mfilename, 'rho'));
parser.addParamValue('cedalpha', 0.01, @(x) validateattributes(x, ...
    {'double'}, {'scalar', 'positive'}, mfilename, 'cedalpha'));
parser.addParamValue('cedC', 0.0, @(x) validateattributes(x, ...
    {'double'}, {'scalar', 'nonnegative'}, mfilename, 'cedC'));
parser.addParamValue('mode', 'eced', ...
    @(x) strcmpi(x, validatestring(x, {'eced', 'ced'}, mfilename, 'mode')));
parser.addParamValue('tau', 0.20, @(x) validateattributes(x, ...
    {'double'}, {'scalar', 'nonnegative'}, mfilename, 'tau'));
parser.addParamValue('processTime', inf, @(x) validateattributes(x, ...
    {'double'}, {'scalar', 'nonnegative'}, mfilename, 'processTime'));
parser.addParamValue('timestepmethod', 'fixed', ...
    @(x) strcmpi(x, validatestring(x, ...
    {'fixed', 'adaptive', 'fed'}, ...
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
parser.addParamValue('alpha', inf(size(in)), @(x) validateattributes(x, ...
    {'numeric'}, {'nonempty','finite','2d'}, mfilename, 'alpha'));
parser.addParamValue('beta', inf(size(in)), @(x) validateattributes(x, ...
    {'numeric'}, {'nonempty','finite','2d'}, mfilename, 'beta'));
parser.addParamValue('grad', struct('scheme','central'), ...
    @(x) validateattributes(x, {'struct'}, {}, mfilename, 'grad'));
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
    
    % Compute Structure Tensor.
    ST = StructureTensor(out, ...
        'rho', opts.rho, 'sigma', opts.sigma, 'grad', opts.grad);
    
    % Compute Diffusion Tensor
    DT = Structure2DiffusionTensor(ST, ...
        'mode', opts.mode, 'alpha', opts.cedalpha, 'C', opts.cedC, ...
        'lambda', opts.lambda, 'diffusivity', opts.diffusivity, ...
        'diffusivityfun', opts.diffusivityfun ...
        );
    
    % Check if alpha and beta have been specified. If not, set them to get the
    % non-negativity discretisation from the references. While not the best
    % possible choice for every case, it is reasonable for most applications.
    if all(isinf(opts.alpha))
        opts.alpha = zeros(size(in));
    end
    if all(isinf(opts.beta))
        opts.beta = sign(DT(:,:,2));
    end
    
    S = Tensor2Stencil(DT(:,:,1), DT(:,:,2), DT(:,:,3), opts.alpha, opts.beta);
    if (any(S{1,1}(:)<0) || any(S{1,2}(:)<0) || any(S{1,3}(:)<0) || ...
            any(S{2,1}(:)<0) || any(S{2,3}(:)<0) || any(S{3,1}(:)<0) || ...
            any(S{3,2}(:)<0) || any(S{3,3}(:)<0) )
        % TODO: Currently this check triggers quite often. Check Tensor2Stencil.
        % The results look fine, though.
        ExcM = ExceptionMessage('Internal', 'message', ...
            ['Discrete Stencil may be unstable, some offdiagonal entries ' ...
            'are negative']);
        warning(ExcM.id, ExcM.message);
    end
    if any(S{1,1}(:) + S{1,2}(:) + S{1,3}(:) + S{2,1}(:) + S{2,2}(:) + ...
            S{2,3}(:) + S{3,1}(:) + S{3,2}(:) + S{3,3}(:) > 10e-10)
        ExcM = ExceptionMessage('Internal', 'message', ...
            'Discrete Stencil may violate average gray value preservation');
        warning(ExcM.id, ExcM.message);
    end
    
    % Set time step to maximal value for the current step.
    if strcmpi(opts.timestepmethod, 'adaptive')
        % Multiplying by 1.01 ensures that we are really below the threshold.
        ts = 1./(1.01*max(abs(S{2,2}(:))));
        if max(ts(:)) < 1e-3
            ExcM = ExceptionMessage('Internal', 'message', ...
                'Time stepsize is very small.');
            warning(ExcM.id, ExcM.message);
        end
    end
    
    % If the next timestep would exceed the specified process Time, make it
    % smaller.
    if ~isinf(opts.processTime)
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
