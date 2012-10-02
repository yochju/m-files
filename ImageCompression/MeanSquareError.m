function out = MeanSquareError(u, f)
%% Computes residual of a solution (squared l2 norm).
%
% out = Residual(u, f)
%
% Input parameters (required):
%
% u : (potential) reconstruction. (double array)
% f : Dirichlet boundary data. (double array of same size as u)
%
% Output parameters:
%
% out : Mean square error between u and f.
%
% Description:
%
% Computes the mean square error between u and f.
%
% Example:
% u = rand(100,100);
% f = rand(100,100);
% s = Residual(u, f);
%
% See also Residual

% Copyright 2012 Laurent Hoeltgen <laurent.hoeltgen@gmail.com>
%
% This program is free software; you can redistribute it and/or modify it
% under the terms of the GNU General Public License as published by the Free
% Software Foundation; either version 3 of the License, or (at your option)
% any later version.
%
% This program is distributed in the hope that it will be useful, but
% WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY
% or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public License
% for more details.
%
% You should have received a copy of the GNU General Public License along
% with this program; if not, write to the Free Software Foundation, Inc., 51
% Franklin Street, Fifth Floor, Boston, MA 02110-1301, USA.

% Last revision on: 02.10.2012 15:10

narginchk(2, 2);
nargoutchk(0, 1);

parser = inputParser;
parser.FunctionName = mfilename;
parser.CaseSensitive = false;
parser.KeepUnmatched = true;
parser.StructExpand = true;

parser.addRequired('u', @(x) ismatrix(x)&&IsDouble(x));
parser.addRequired('f', @(x) ismatrix(x)&&IsDouble(x));

parser.parse(u, f)
opts = parser.Results;

% TODO: Add error string.
assert( isequal( size(opts.f), size(opts.u) ) );

out = norm( u(:) - f(:), 2)^2/numel(u);
end
