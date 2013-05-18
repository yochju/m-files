function [o11, o12, o22] = ApplyFunToSym2x2Mat(a, c, fun)
%% Apply a function to a symmetric tensor.
%
% [o11, o12, o22] = ApplyFunToSym2x2Mat(a, c, fun)
%
% Input parameters (required):
%
% a   : Matrix entry (double array)
% c   : Matrix entry (double array)
% fun : Function to be applied onto the matrix. (double array)
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
% o11 : Matrix entry
% o12 : Matrix entry
% o22 : Matrix entry
%
% Output parameters (optional):
%
% -
%
% Description:
%
% Applies the function fun onto the the matrix [ a^2 , a*c ; a*c , c^2 ]. The
% output corresponds to the matrix [ o11 , o12 ; o12 , o22 ]. The input entries
% can be arrays of the same size. In that case, the are computed pointwise. fun
% should be a handle to a function that accepts a double array and returns its
% input pointwise evaluated.
%
% This function is especially useful for computing functions of tensors of the
% form v*(v').
%
% Example:
%
% A = [ 3^2 3*9 ; 3*9 9^2 ];
% g = @(x) 1./sqrt(1+x.^2);
% [o11 o12 o22] = ApplyFunToSym2x2Mat(3, 9, g);
%
% See also funm

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

% Last revision on: 18.05.2013 18:53

%% Notes

%% Parse input and output.

narginchk(3, 3);
nargoutchk(0, 3);

parser = inputParser;
parser.FunctionName = mfilename;
parser.CaseSensitive = false;
parser.KeepUnmatched = true;
parser.StructExpand = true;

parser.addRequired('a', @(x) validateattributes(x, {'numeric'}, ...
    {'real', 'finite', 'nonnan'}, mfilename, 'a'));
parser.addRequired('c', @(x) validateattributes(x, {'numeric'}, ...
    {'real', 'finite', 'size', size(a), 'nonnan'}, mfilename, 'c'));
parser.addRequired('fun', @(x) validateattributes(x, {'function_handle'}, ...
    {}, mfilename, 'fun'));

parser.parse(a,c,fun);

%% Run code.

a2c2 = a.^2 + c.^2;
fa2c2 = fun(a2c2);
o11 = (c.^2 * fun(zeros(size(a))) + a.^2 * fa2c2)./a2c2;
o12 = a.*c.*( fa2c2 - fun(zeros(size(a))) )./a2c2;
o22 = (a.^2 * fun(zeros(size(a))) + c.^2 * fa2c2)./a2c2;
		       
end
