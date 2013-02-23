function out = Vec2Mat(in, nr, nc, varargin)
%% Transforms a vector in a 2d array. Inverse of Mat2Vec
%
% out = Vec2Mat(in, nr, nc, ...)
%
% Input parameters (required):
%
% in : input vector (array)
% nr : number of rows in output matrix.
% nc : number of columns in output matrix.
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
% scheme : How the entries will be labeled. If 'col' then the entries will be
% traversed column-wise. If 'row' the entries will be traversed row-wise.
% Default is the column-wise order (coincides with the standard Matlab
% ordering). (string)
%
% Output parameters:
%
% out : Matrix of size nr times nc with the entries from input vector in.
%
% Output parameters (optional):
%
% -
%
% Description:
%
% Reshapes a vector in a matrix of specified dimension.
%
% Example:
%
% X = [1 4 7 ; 2 5 8 ; 3 6 9 ];
% Vec2Mat(Mat2Vec(X,'col'),3,3,'col')
%
% See also reshape, transpose, Mat2Vec

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

% Last revision on: 23.02.2013 17:45

%% Notes

%% Parse input and output.

narginchk(3, 4);
nargoutchk(0, 1);

parser = inputParser;
parser.FunctionName = mfilename;
parser.CaseSensitive = false;
parser.KeepUnmatched = true;
parser.StructExpand = true;

parser.addRequired('in', @(x) validateattributes(x, {'numeric'}, ...
    {'2d'}, mfilename, 'in'));

parser.addRequired('nr', @(x) validateattributes(x, {'numeric'}, ...
    {'scalar', 'integer', 'positive'}, mfilename, 'nr'));

parser.addRequired('nc', @(x) validateattributes(x, {'numeric'}, ...
    {'scalar', 'integer', 'positive'}, mfilename, 'nc'));

parser.addOptional('scheme', 'col', ...
    @(x) any(strcmpi(validatestring(x, {'col', 'row'}, mfilename), ...
    {'col', 'row'})));

parser.parse(in, nr, nc, varargin{:});
opts = parser.Results;

MExc = ExceptionMessage('Input', 'message', ...
    'Number of elements in input vector not compatible with specified size.');
assert(numel(in)==nr*nc, MExc.id, MExc.message);

%% Run code.

switch opts.scheme
    case 'col'
        out = reshape(in,nr,nc);
    case 'row'
        out = transpose(reshape(in,nc,nr));
end
		       
end
