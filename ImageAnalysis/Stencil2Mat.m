function M = Stencil2Mat(stencil, varargin)
%% Transform a 3x3 Stencil for diffusion into the corresponding Matrix.
%
% M = Stencil2Mat(stencil, ...)
%
% Input parameters (required):
%
% stencil : 3x3 cell array containing the entries of the stencil.
%
% Input parameters (parameters):
%
% Parameters are either struct with the following fields and corresponding
% values or option/value pairs, where the option is specified as a string.
%
% boundary : which boundary conditions should be applied. Possible choices are
%            'Neumann' or 'Dirichlet'. (string, default = 'Neumann').
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
% M : matrix corresponding to the stencil.
%
% Output parameters (optional):
%
% -
%
% Description:
%
% Generates the matrix corresponding to a (non-constant) convolution with a 3x3
% Stencil on a 2D signal. The signal is assumed to be indexed columnwise, e.g.
% the convolution can be done by M*x(:), where M is the output matrix and x the
% signal.
%
% Example:
%
% nr = 3+randi(768,1);
% nc = 3+randi(768,1);
%
% S22 = rand(nr, nc);
%
% S12 = rand(nr, nc);
% S21 = rand(nr, nc);
% S23 = rand(nr, nc);
% S32 = rand(nr, nc);
%
% S11 = rand(nr, nc);
% S13 = rand(nr, nc);
% S31 = rand(nr, nc);
% S33 = rand(nr, nc);
%
% S = { S11 S12 S13 ; S21 S22 S23 ; S31 S32 S33 };
%
% % With Dirichlet Boundary Conditions:
%
% M = Stencil2Mat(S,'boundary','dirichlet');
%
% x = rand(nr*nc,1);
% y1 = M*x(:);
% temp = NonConstantConvolution(reshape(x,nr,nc), S, 'boundary', 'Dirichlet', 'correlation', true);
% y2 = temp(:);
%
% % y1 and y2 are identical.
%
% With Neumann Boundary Conditions:
%
% M = Stencil2Mat(S,'boundary','neumann');
%
% x = rand(nr*nc,1);
% y1 = M*x(:);
% temp = NonConstantConvolution(reshape(x,nr,nc), S, 'boundary', 'Neumann', 'correlation', true);
% y2 = temp(:);
%
% % y1 and y2 are identical.
%
% See also NonConstantConvolution

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

% Last revision on: 11.06.2013 18:00

%% Notes

% TODO: Extend to stencils of arbitrary size.

%% Parse input and output.

narginchk(1, 3);
nargoutchk(0, 3);

parser = inputParser;
parser.FunctionName = mfilename;
parser.CaseSensitive = false;
parser.KeepUnmatched = true;
parser.StructExpand = true;

parser.addRequired('stencil', @(x) validateattributes(x, {'cell'}, ...
    {'size', [3,3]}, mfilename, 'stencil', 1));

parser.addParamValue('boundary', 'Neumann', ...
    @(x) strcmpi(x, validatestring(x, {'Dirichlet', 'Neumann'}, mfilename, ...
    'boundary')));

parser.parse( stencil, varargin{:});
opts = parser.Results;

[nr nc] = size(stencil{1});
for i = 2:9
    if ~isequal([nr nc], size(stencil{i}))
        ExcM = ExceptionMessage('Input', 'message', ...
            'All stencil entries must have same size.');
        error(ExcM.id, ExcM.message);
    end
end

%% Run code.

% Take care of all the difficulties, such as boundary conditions and overlaps in
% the stencil. This is much easier than fiddling around with the matrix.
if strcmpi(opts.boundary,'Neumann')
    
    % Top neighbour mirroring.
    stencil{2,2}(1,1:nc) = stencil{2,2}(1,1:nc) + stencil{1,2}(1,1:nc);
    stencil{1,2}(1,1:nc) = 0;
    
    stencil{2,1}(1,1:nc) = stencil{2,1}(1,1:nc) + stencil{1,1}(1,1:nc);
    stencil{1,1}(1,1:nc) = 0;
    stencil{2,3}(1,1:nc) = stencil{2,3}(1,1:nc) + stencil{1,3}(1,1:nc);
    stencil{1,3}(1,1:nc) = 0;
    
    % Bottom neighbour mirroring.
    stencil{2,2}(nr,1:nc) = stencil{2,2}(nr,1:nc) + stencil{3,2}(nr,1:nc);
    stencil{3,2}(nr,1:nc) = 0;
    
    stencil{2,1}(nr,1:nc) = stencil{2,1}(nr,1:nc) + stencil{3,1}(nr,1:nc);
    stencil{3,1}(nr,1:nc) = 0;
    stencil{2,3}(nr,1:nc) = stencil{2,3}(nr,1:nc) + stencil{3,3}(nr,1:nc);
    stencil{3,3}(nr,1:nc) = 0;
    
    % Left neighbour mirroring.
    stencil{2,2}(1:nr,1) = stencil{2,2}(1:nr,1) + stencil{2,1}(1:nr,1);
    stencil{2,1}(1:nr,1) = 0;
    
    stencil{1,2}(1:nr,1) = stencil{1,2}(1:nr,1) + stencil{1,1}(1:nr,1);
    stencil{1,1}(1:nr,1) = 0;
    stencil{3,2}(1:nr,1) = stencil{3,2}(1:nr,1) + stencil{3,1}(1:nr,1);
    stencil{3,1}(1:nr,1) = 0;
    
    % Right neighbour mirroring.
    stencil{2,2}(1:nr,nc) = stencil{2,2}(1:nr,nc) + stencil{2,3}(1:nr,nc);
    stencil{2,3}(1:nr,nc) = 0;
    
    stencil{1,2}(1:nr,nc) = stencil{1,2}(1:nr,nc) + stencil{1,3}(1:nr,nc);
    stencil{1,3}(1:nr,nc) = 0;
    stencil{3,2}(1:nr,nc) = stencil{3,2}(1:nr,nc) + stencil{3,3}(1:nr,nc);
    stencil{3,3}(1:nr,nc) = 0;
    
    % Corners.
    stencil{2,2}(1,1) = stencil{2,2}(1,1) + stencil{1,1}(1,1);
    stencil{2,2}(nr,1) = stencil{2,2}(nr,1) + stencil{3,1}(nr,1);
    stencil{2,2}(1,nc) = stencil{2,2}(1,nc) + stencil{1,3}(1,nc);
    stencil{2,2}(nr,nc) = stencil{2,2}(nr,nc) + stencil{3,3}(nr,nc);
else
    
    % Dirichlet conditions don't need the mirroring but the setting to 0 is
    % still necessary.
    
    stencil{1,2}(1,1:nc) = 0;
    stencil{1,1}(1,1:nc) = 0;
    stencil{1,3}(1,1:nc) = 0;
    stencil{3,2}(nr,1:nc) = 0;
    stencil{3,1}(nr,1:nc) = 0;
    stencil{3,3}(nr,1:nc) = 0;
    
    stencil{2,1}(1:nr,1) = 0;
    stencil{1,1}(1:nr,1) = 0;
    stencil{3,1}(1:nr,1) = 0;
    stencil{2,3}(1:nr,nc) = 0;
    stencil{1,3}(1:nr,nc) = 0;
    stencil{3,3}(1:nr,nc) = 0;
    
end

M = spdiags( ...
    [ ...
    stencil{1,1}(:) stencil{2,1}(:) stencil{3,1}(:) ...
    stencil{1,2}(:) stencil{2,2}(:) stencil{3,2}(:) ...
    stencil{1,3}(:) stencil{2,3}(:) stencil{3,3}(:)], ...
    [0 1 2 nr nr+1 nr+2 2*nr 2*nr+1 2*nr+2], ...
    nr*nc,nr*(nc+2)+2);

% Crop the Matrix M to get the relevant part only.
% Calling sparse here another time makes sense. If the stencil contains 0s, they
% will vanish from the matrix here.
M = sparse(M(:,((nr+1)+1):((nr+1)+nr*nc)));

end
