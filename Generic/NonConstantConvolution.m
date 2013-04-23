function [out] = NonConstantConvolution(signal, stencil, varargin)
%% Perform convolution with a spatially varying convolution stencil
%
% [out] = NonConstantConvolution(signal, stencil, ...)
%
% Input parameters (required):
%
% signal  : The data to be convolved. (2d double array)
% stencil : The convolution stencil. The stencil is passed as a cell array where
%           each entry has the same size as the signal. These etnries represent
%           the convolution coefficients used at the corresponding position. If
%           your signal is nr times nc and your convolution mask is mr times mc,
%           then stencil is an mr times mc cell array where each entry is a nr
%           times nc double array. In position (i,j), the data signal(i,j) will
%           be convolved with the entries stencil{r,s}(i,j) where r and s vary
%           between 1 and mr (resp. mc).
%
% Input parameters (parameters):
%
% Parameters are either struct with the following fields and corresponding
% values or option/value pairs, where the option is specified as a string.
%
% boundary    : How the boundary should be treated. Possible options are
%               'Neumann' and 'Dirichlet'. Default is 'Neumann'.
% correlation : Whether correlation should be performed instead of convolution.
%               The difference lies in the fact, that convolution rotates the
%               stencil mask by 180 degrees whereas correlation does not.
%               (default = false).
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
% out : The convolved input signal.
%
% Output parameters (optional):
%
% -
%
% Description:
%
% Perform convolution with a spatially varying convolution stencil on 2D Data
% sets.
%
% Example:
%
% nr = 5;
% nc = 5;
% mr = 3;
% mc = 3;
% I = rand(nr,nc);
% S0 = zeros(nr,nc);
% S1 = -ones(nr,nc);
% S4 = 4*ones(nr,nc);
% S = { S0 , S1 , S0 ; S1 , S4 , S1 ; S0 , S1 , S0 };
% J = NonConstantConvolution(I,S);
%
% See also conv

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

% Last revision on: 23.04.2013 21:06

%% Notes

%% Parse input and output.

narginchk(2, 6);
nargoutchk(0, 1);

parser = inputParser;
parser.FunctionName = mfilename;
parser.CaseSensitive = false;
parser.KeepUnmatched = true;
parser.StructExpand = true;

parser.addRequired('signal', @(x) validateattributes(x, {'numeric'}, ...
    {'nonempty','finite','2d'}, mfilename, 'signal', 1));
parser.addRequired('stencil', @(x) validateattributes(x, {'cell'}, ...
    {'nonempty'}, mfilename, 'stencil', 2));
parser.addParamValue('correlation', false, @(x) validateattributes(x, ...
    {'logical'}, {'scalar'}, mfilename, 'correlation'));
parser.addParamValue('boundary', 'Neumann', ...
    @(x) strcmpi(x, validatestring(x, {'Dirichlet', 'Neumann'}, mfilename, ...
    'boundary')));

parser.parse( signal, stencil, varargin{:});
opts = parser.Results;

if ~all(all(cellfun(@(x) isequal(size(x),size(signal)), stencil)));
    ExcM = ExceptionMessage('Input','message', ...
        'All stencil entries must have same size as input signal.');
    error(ExcM.id,ExcM.message);
end

%% Run code.

[nr nc] = size(signal);
if opts.correlation
    %% Perform correlation and not convolution.
    stencil = rot90(stencil,2);
end
[mr mc] = size(stencil);
I = AddBoundaryData(signal, 'type', opts.boundary, 'size', ([mr mc]-1)/2);
shift = ([mr mc]-1)/2;
coeffs = cell(size(stencil));
for i = -shift(1):shift(1)
    for j = -shift(2):shift(2)
        coeffs{i+1+shift(1),j+1+shift(2)} = ...
            stencil{i+1+shift(1),j+1+shift(2)} .* ...
            I((1+shift(1)-i):(nr+shift(1)-i),(1+shift(2)-j):(nc+shift(2)-j));
    end
end
out = sum(cat(3,coeffs{:}),3);

end
