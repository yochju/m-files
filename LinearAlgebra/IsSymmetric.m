function out = IsSymmetric(M)
%% Returns true if matrix is (real) symmetric, false otherwise.
%
% out = IsSymmetric(M)
%
% Input parameters (required):
%
% M : Matrix to be test. (array)
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
% out : true or false, depending on whether the matrix is symmetric.
%
% Output parameters (optional):
%
% -
%
% Description:
%
% Tests whether the input matrix is symmetric. Input must be a real square
% matrix, otherwise an error is thrown.
%
% Example:
%
% IsSymmetric([1 2 ; 2 1]) returns true.
% IsSymmetric([1 2 ; 4 1]) returns false.
%
% See also transpose, isequal

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

% Last revision on: 04.12.2012 21:55

%% Notes

%% Parse input and output.

narginchk(1, 1);
nargoutchk(0, 1);

parser = inputParser;
parser.FunctionName = mfilename;
parser.CaseSensitive = false;
parser.KeepUnmatched = true;
parser.StructExpand = true;

parser.addRequired('M', @(x) validateattributes(x, {'numeric'}, ...
    {'2d', 'nonempty', 'real', 'finite', 'nonnan'}, mfilename, 'M', 1));

parser.parse(M);

MExc = ExceptionMessage('Input','message','Input matrix must be square.');
assert(diff(size(M))==0, MExc.id, MExc.message);

%% Run code.

out = all(isequal(M,transpose(M)));

end
