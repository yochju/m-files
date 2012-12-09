function [v varargout] = EigenValuesSym2x2(M)
%% Returns the eigenvalues of a symmetric 2 times 2 matrix.
%
% [v w] = EigenValuesSym2x2(M)
%
% Input parameters (required):
%
% M : 2 x 2 real symmetric matrix. (array)
%
% Input parameters (parameters):
%
% Parameters are either struct with the following fields and corresponding
% values or option/value pairs, where the option is specified as a string.
%
% -
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
% v : if only one output parameter is specified, the v is a 1x2 vector
%     containing the eigenvalues. If two output argmunts are required, v
%     represents the first eigenvalue.
%
% Output parameters (optional):
%
% w : if required, w contains the second eigenvalue
%
% Description:
%
% Computes the eigenvalues of a real symmetric 2x2 matrix.
%
% Example:
%
% M = [3 1 ; 1 3];
% [v1 v2] = EigenValuesSym2x2(M)
%
% See also eig, eigs

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

% Last revision on: 08.12.2012 20:45

%% Notes.

%% Parse input and output.

narginchk(1, 1);
nargoutchk(0, 2);

parser = inputParser;
parser.FunctionName = mfilename;
parser.CaseSensitive = false;
parser.KeepUnmatched = true;
parser.StructExpand = true;

parser.addRequired('M', @(x) validateattributes(x, {'numeric'}, ...
    {'size', [2 2], 'nonsparse'}, mfilename, 'M'));

parser.parse(M);

ExcM = ExceptionMessage('Input', 'message', 'Input matrix must be symmetric.');
assert(IsSymmetric(M), ExcM.id, ExcM.message);

%% Run code.

a = M(1,1);
b = M(2,1);
c = M(2,2);

if nargout < 2
   
    v = [ nan nan ];
    v(1) = 0.5*(a+c-sqrt(4*b^2+(a-c)^2));
    v(2) = 0.5*(a+c+sqrt(4*b^2+(a-c)^2));
    
else
    
    v = 0.5*(a+c-sqrt(4*b^2+(a-c)^2));
    varargout{1} = 0.5*(a+c+sqrt(4*b^2+(a-c)^2));

end
