function [out, varargout] = ExpLinDiff(in, varargin)
%% Perform explicit non linear isotropic diffusion
%
% [out] = ExpLinDiff(in, varargin)
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
% tau            : time step size (default = 0.25).
% timestepmethod : how the time steps are chosen. ('fixed', 'fed')
%                  (default 'fixed
% processTime    : total diffusion time of the process.
% fedopts        : options used for computing the fed time steps. (default
%                  struct([]))
% fedopts        : options used for computing the laplacian. (default
%                  struct([]))
% its            : number of iterations (default = 1).
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
% Performs a explicit linear diffusion scheme on the input image.
%
% Example:
%
% I = rand(256,256)
% [J, T, its] = ExpLinDiff(I,'its',1000,'diffusivity','weickert', ...
%    'timestepmethod', 'fixed', 'lambda', 3.5, 'tau',0.25, 'sigma', 3.0, ...
%    'processTime', 320);
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

% Last revision on: 11.05.2013 21:00

%% Notes
%
% TODO:
% - Add FED.
% - Allow a vector of timesteps to be passed. In that case, the
%   number of iterations coincides with the length of the vector.

%% Parse input and output.

narginchk(1, 13);
nargoutchk(0, 3);

parser = inputParser;
parser.FunctionName = mfilename;
parser.CaseSensitive = false;
parser.KeepUnmatched = true;
parser.StructExpand = true;

parser.addRequired('in', @(x) validateattributes(x, {'numeric'}, ...
    {'nonempty','finite','2d'}, mfilename, 'in', 1));

parser.addParamValue('tau', 0.20, @(x) validateattributes(x, ...
    {'double'}, {'scalar', 'nonnegative'}, mfilename, 'tau'));

parser.addParamValue('processTime', inf, @(x) validateattributes(x, ...
    {'double'}, {'scalar', 'nonnegative'}, mfilename, 'processTime'));

parser.addParamValue('timestepmethod', 'fixed', ...
    @(x) strcmpi(x, validatestring(x, ...
    {'fixed', 'fed'}, ...
    mfilename, 'timestepmethod')));

parser.addParamValue('fedopts', struct(), ...
    @(x) validateattributes(x, {'struct'}, {}, mfilename, 'fedopts'));

parser.addParamValue('lapopts', struct(), ...
    @(x) validateattributes(x, {'struct'}, {}, mfilename, 'lapopts'));

parser.addParamValue('its', 1, @(x) validateattributes(x, ...
    {'double'}, {'scalar', 'integer', 'positive'}, mfilename, 'its'));

parser.parse( in, varargin{:} );
opts = parser.Results;

% Note that this does not take into consideration the possibility to handle 1D
% signals as 2D signals or as 1D signals.
if isfield(opts.lapopts,'gridSize')
    if opts.tau > 1/sum(2./(opts.lapopts.gridSize).^2)
        ExcM = ExceptionMessage('Input', 'message', ...
            'Your choice of grid size and time step may be unstable.');
        warning(ExcM.id,ExcM.message);
    end
elseif (opts.tau > 0.25) && strcmpi(opts.timestepmethod,'fixed')
    ExcM = ExceptionMessage('Input', 'message', ...
        'Your choice of grid size and time step may be unstable.');
    warning(ExcM.id,ExcM.message);
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
for i = 1:opts.its
    % Perform a explicit diffusion step.
    out = out + ts*ImageLapl( out, opts.lapopts );
    % Compute total diffusion time.
    diffTime = diffTime + ts;
    
    if (diffTime >= opts.processTime)
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
