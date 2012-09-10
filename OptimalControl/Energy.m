function out = Energy(u, c, f, varargin)
%% Energy functional considered in this optimal control framework.
%
% out = Energy(u, c, f, ...)
%
% Input parameters (required):
%
% u : image reconstruction (double array).
% c : mask (double array).
% f : initial image (double array).
%
% Input parameters (optional):
%
% lambda : regularisation weight. (nonnegative scalar, default = 1.0)
%
% Output parameters:
%
% out : The energy corresponding to the input variables, that is
%       0.5*||u-f||_2^2 + lambda * ||c||_1
%
% Description:
%
% Evaluates the energy that we consider in this optimal control framework.
%
% Example:
% u = rand(100,100);
% c = double(rand(100,100) > 0.6);
% f = rand(100,100);
% l = 0.73;
% E = Energy(u,c,f,l);
%
% See also norm.

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

% Last revision on: 10.09.2012 11:12

narginchk(3, 4);
nargoutchk(0, 1);

parser = inputParser;
parser.FunctionName = mfilename;
parser.CaseSensitive = false;
parser.KeepUnmatched = true;
parser.StructExpand = true;

parser.addRequired('u', @(x) ismatrix(x)&&IsDouble(x));
parser.addRequired('c', @(x) ismatrix(x)&&IsDouble(x));
parser.addRequired('f', @(x) ismatrix(x)&&IsDouble(x));
parser.addOptional('lambda',1.0,@(x) isscalar(x)&&(x>=0));

parser.parse(u,c,f,varargin{:});
opts = parser.Results;

ExcM = ExceptionMessage('BadDim', '', ...
    'The size of all the data must coincide');

assert(isequal(size(u),size(c),size(f)),ExcM.id,ExcM.message);

if abs(opts.lambda) < 10*eps
    % TODO: Fix the bug w.r.t. to warnings in ExceptionMessage.
    ExcM = ExceptionMessage('BadArg', '', ...
        'There is no penalisation on the Mask values.');
    warning(ExcM.id,ExcM.message);
end

out = 0.5*norm(opts.u(:)-opts.f(:),2)^2 + opts.lambda*norm(opts.c(:),1);

end
