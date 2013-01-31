function [varargout] = Map(values, functions, varargin)
%% Maps functions onto input values
%
% [ ... ] = Map(values, functions, ...)
%
% Input parameters (required):
%
% values    : an array or cell array of input parameters.
% functions : a cell array of function handles.
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
% -
%
% Output parameters (optional):
%
% -
%
% Description:
%
% Applies each function from the functions array onto the input in values. If
% values is a simple array, then this is done componentwise. The same holds when
% values is 1x1 cell array. If values is a cell array of larger size, then the
% i-th entry of each array is passed to every function in functions (see
% examples). Besides the mentioned input parameters, the function can take any
% options that can also be passed to cellfun. These options are not parsed and
% passed as is!
%
% Example:
%
% Map([1 2 3], {@min, @max}) yields
% [ 1 3 ]
%
% [v p] = Map([1 2 3], {@min, @max}) and
% [v p] = Map([1 2 3], {@min, @max}) yield
% v = [ 1 3 ]
% p = [ 1 3 ]
%
% w = Map({[1 3 2], [9 0 1]}, {@plus, @times}, 'UniformOutput', false) yields
% w = { [10 3 3], [9 0 2] }
%
% See also cellfun

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

% Last revision on: 12.01.2013 21:00

%% Notes

%% Parse input and output.

narginchk(2,inf);
nargoutchk(0,inf);

parser = inputParser;
parser.FunctionName = mfilename;
parser.CaseSensitive = false;
parser.KeepUnmatched = true;
parser.StructExpand = true;

parser.addRequired('values', @(x) validateattributes(x, ...
    {'numeric', 'cell'}, {}, mfilename, 'values'));
parser.addRequired('functions', @(x) validateattributes(x, ...
    {'cell'}, {}, mfilename, 'values'));
parser.parse(values, functions);

MExc = ExceptionMessage('Input', 'message', ...
    'The second argument must be a cell array of function handles.');
assert( all(cellfun(@(f) isa(f,'function_handle'), functions)), ...
    MExc.id, MExc.message);


%% Run code.

if iscell(values)
    [varargout{1:nargout}] = cellfun(@(f) f(values{:}), ...
        functions, varargin{:});
else
    [varargout{1:nargout}] = cellfun(@(f) f(values), ...
        functions, varargin{:});
end

end
