function [out varargout] = ParabolicLaplaceInpainting(c, f, varargin)
%% Performs Laplace inpainting through an iterative approach.
%
% out = ParabolicLaplaceInpainting(c, f, ...)
%
% Input parameters (required):
%
% c : binary mask indicating the locations of the data points. (array)
% f : data values at the positions given in c (array)
%
% Input parameters (optional):
%
% Optional parameters are either struct with the following fields and
% corresponding values or option/value pairs, where the option is specified as a
% string.
%
% tStep : time step size for the iteration. (scalar, default = 0.2)
% its   : total number of iterations. (scalar, default = 1)
% time  : total diffusion time. If specified, it overrides the setting for the
%       : number of iterations. (scalar, default = its*tStep)
% tol   : change threshold when to stop iterating (if reached before the max.
%         number of iterations.) The change is measured as the distance in the 2
%         norm between two consecutive iterates. (scalar, default = 1e-6)
%
% Any combination of iterations, time step and total time that prohibits any
% iteration will yield the solution c.*f as result.
%
% The function calls ImageLapl.m internally. Any option used by this method may
% also be specified here.
%
% Output parameters:
%
% out : the inpainted image.
%
% Output parameters (optional):
%
% itcount : the number of iterations performed.
%
% Description:
%
% Solves the parabolic PDE:
%
% d/dt u = (1-c)*Delta*u - c*(u-f)
%
% where Delta is the Laplace operator by using an explicit finite difference
% scheme (Euler method). The solution for t->inf corresponds to the Laplace
% interpolation which is a solution of
%
% c*(u-f) - (1-c)*Delta*u = 0
%
% Note that this algorithm is rather slow and should not be used for inpainting
% large signals (e.g. anything with more than 512 samples).
%
% Example:
%
% f = rand(512,256)
% c = double(rand(512,256) > 0.5);
% u = ParabolicLaplaceInpainting(c,f,'its',1000);
%
% See also EvalPde, SolvePde, PdeM

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

% Last revision on: 10.10.2012 10:30

%% Check Input and Output Arguments

narginchk(2, 10);
nargoutchk(0, 2);

parser = inputParser;
parser.FunctionName = mfilename;
parser.CaseSensitive = false;
parser.KeepUnmatched = true;
parser.StructExpand = true;

parser.addRequired('c', @(x) validateattributes( x, {'numeric'}, ...
    {'2d', 'finite', 'nonempty', 'nonnan'}, ...
    mfilename, 'c', 1) );
parser.addRequired('f', @(x) validateattributes( x, {'numeric'}, ...
    {'2d', 'finite', 'nonempty', 'nonnan'}, ...
    mfilename, 'f', 2) );

parser.addParamValue('tStep', 0.2, @(x) isscalar(x)&&(x<0.25) );
parser.addParamValue('its', 1, @(x) isscalar(x)&&(x>=1) );
parser.addParamValue('time', inf, @(x) isscalar(x)&&(x>=0));
parser.addParamValue('tol', 1e-6, @(x) isscalar(x)&&(x>=0));

parser.parse(c, f, varargin{:});
opts = parser.Results;

% Check whether the stopping time was specified or not and set the stopping
% criterion accordingly
if ~isinf(opts.time)
    stop = opts.time;
else
    stop = opts.tStep*opts.its;
end

ExcM = ExceptionMessage('Input');
assert( isequal(size(opts.c), size(opts.f)), ExcM.id, ExcM.message );

%% Algorithm

i   = 0;     % Current iteration.
out = c.*f;  % Current solution. (initialised with known data values)
g   = c.*f;  % Data values. (we discard any data whenever c==0)
u_old = out; % Previous iterate. (for tolerance check)

while (i*opts.tStep < stop)
    
    out = out + opts.tStep * ( ...
        (1-c).*ImageLapl(out, opts) - c .*(out-g) );
    
    change = norm(out(:) - u_old(:), 2);
    
    i = i+1;
    
    % Check if we have reached the desired tolerance threshold.
    if  ( ( norm(out(:), 2) > 1e8 ) && ...
            ( change < 10*opts.tol*eps(norm(out(:), 2)) ) ) || ...
            ( ( norm(out(:), 2) <= 1e8 ) && ...
            ( change < opts.tol ) )
        break;
    end
    
    u_old = out;
    
end

if nargout == 2
    varargout{1} = i;
end

end
