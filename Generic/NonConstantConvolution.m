function [out, varargout] = NonConstantConvolution(signal, stencil, varargin)
%% <H1 LINE>
%
% <SIGNATURE>
%
% Input parameters (required):
%
% -
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
% -
%
% Example:
%
% -
%
% See also

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

% Last revision on: dd.mm.yyyy hh:mm

%% Notes

%% Parse input and output.

%% Run code.

[nr nc] = size(signal);
[mr mc] = size(stencil);
I = AddBoundaryData(signal, 'type', 'neumann', 'size', ([mr mc]-1)/2);
shift = ([mr mc]-1)/2;
coeffs = cell(size(stencil));
for i = -shift(1):shift(1)
    for j = -shift(2):shift(2)
        coeffs{i+1+shift(1),j+1+shift(2)} = ...
            stencil{i+1+shift(1),j+1+shift(2)} .* ...
            I((1+shift(1)-i):(nr+shift(1)-i),(1+shift(2)-j):(nc+shift(2)-j));
    end
end
out = sum(cat(3,stencil{:}),3);
	       
end
