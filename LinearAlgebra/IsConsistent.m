function out = IsConsistent(A, b, varargin)
%% Check if linear system is consistent (solvable).
%
% out = IsConsistent(A, b, tol)
%
% Input parameters (required):
%
% A : System matrix (2D array)
% b : Righthand side. If column vector, it serves as a single righthand side. If
%     it is a 2D array, then the consistency is checked for every column.
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
% tol : tolerance used for the computation of the number of singular values.
%       (scalar, default = max(size(A))*eps(norm(A))).
%
% Output parameters:
%
% out : Whether the linear system(s) AX=B is solvable or not (by direct or least
%       square means) If righthand side is an array, result is returned for
%       every column. (Boolean)
%
% Output parameters (optional):
%
% -
%
% Description:
%
% Use Rouché-Capelli theorem to check for consistency of the linear system AX=B.
% If B is a matrix, then the check is performed columnwise.
%
% Example:
%
% A = [1 2 ;0 1];
% b = [3 ; 4];
% IsConsistent(A,b)
%
% See also det, rank

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

% Last revision on: 08.12.2012 22:15

%% Notes

%% Parse input and output.

narginchk(2, 3);
nargoutchk(0, 1);

parser = inputParser;
parser.FunctionName = mfilename;
parser.CaseSensitive = false;
parser.KeepUnmatched = true;
parser.StructExpand = true;

parser.addRequired('A', @(x) validateattributes(x, {'numeric'}, ...
    {'2d', 'finite', 'nonnan'}, mfilename, 'A'));

parser.addRequired('b', @(x) validateattributes(x, {'numeric'}, ...
    {'finite', 'nonnan'}, mfilename, 'b'));

parser.addOptional('tol', max(size(A))*eps(norm(A)), ...
    @(x) validateattributes(x, {'numeric'}, {'scalar', 'positive'}, ...
    mfilename, 'tol'));

parser.parse(A, b, varargin{:});
opts = parser.Results;

%% Run code.

if ~isequal(size(A,1),size(b,1))
    ExcM = ExceptionMessage('Input', 'message', ...
        'System Matrix and righthand sides have incompatible sizes.');
    error(ExcM.id, ExcM.message);
end

if iscolumn(b)
    out = isequal(rank(A,opts.tol), rank([A, b],opts.tol));
else
    f = @(x) isequal(rank(A,opts.tol), rank([A, x],opts.tol));
    D = mat2cell(b, size(b,1), ones(size(b,2),1));
    out = cellfun(f,D);
end

end
