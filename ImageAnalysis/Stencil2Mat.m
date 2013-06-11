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

% Last revision on: 11.06.2013 18:00

%% Notes

% TODO: Extend to stencils of arbitrary size.
% TODO: For very large matrices and random coefficients, there seems to be a
%       slight numerical inaccuracy occuring (either here, or in
%       NonConstantConvolution). The source of this inaccuracy is unknown.

%% Parse input and output.

narginchk(1, 3);
nargoutchk(0, 3);

parser = inputParser;
parser.FunctionName = mfilename;
parser.CaseSensitive = false;
parser.KeepUnmatched = true;
parser.StructExpand = true;

parser.addRequired('stencil', @(x) validateattributes(x, {'cell'}, ...
    {}, mfilename, 'stencil', 1));

parser.addParamValue('boundary', 'Neumann', ...
    @(x) strcmpi(x, validatestring(x, {'Dirichlet', 'Neumann'}, mfilename, ...
    'boundary')));

parser.parse( stencil, varargin{:});
opts = parser.Results;

%% Run code.

% TODO: There is no check whether all the entries have the same size.
[nr nc] = size(stencil{1,1});

% Take care of all the difficulties, such as boundary conditions and overlaps in
% the stencil. This is much easier than fiddling around with the matrix.
if strcmpi(opts.boundary,'Neumann')
    for i = 1:nc
        % Top neighbour mirroring.
        stencil{2,2}(1,i) = stencil{2,2}(1,i) + stencil{1,2}(1,i);
        stencil{1,2}(1,i) = 0;
        
        stencil{2,1}(1,i) = stencil{2,1}(1,i) + stencil{1,1}(1,i);
        stencil{1,1}(1,i) = 0;
        stencil{2,3}(1,i) = stencil{2,3}(1,i) + stencil{1,3}(1,i);
        stencil{1,3}(1,i) = 0;
        
        % Bottom neighbour mirroring.
        stencil{2,2}(nr,i) = stencil{2,2}(nr,i) + stencil{3,2}(nr,i);
        stencil{3,2}(nr,i) = 0;
        
        stencil{2,1}(nr,i) = stencil{2,1}(nr,i) + stencil{3,1}(nr,i);
        stencil{3,1}(nr,i) = 0;
        stencil{2,3}(nr,i) = stencil{2,3}(nr,i) + stencil{3,3}(nr,i);
        stencil{3,3}(nr,i) = 0;
    end
    
    for i = 1:nr
        % Left neighbour mirroring.
        stencil{2,2}(i,1) = stencil{2,2}(i,1) + stencil{2,1}(i,1);
        stencil{2,1}(i,1) = 0;
        
        stencil{1,2}(i,1) = stencil{1,2}(i,1) + stencil{1,1}(i,1);
        stencil{1,1}(i,1) = 0;
        stencil{3,2}(i,1) = stencil{3,2}(i,1) + stencil{3,1}(i,1);
        stencil{3,1}(i,1) = 0;
        
        % Right neighbour mirroring.
        stencil{2,2}(i,nc) = stencil{2,2}(i,nc) + stencil{2,3}(i,nc);
        stencil{2,3}(i,nc) = 0;
        
        stencil{1,2}(i,nc) = stencil{1,2}(i,nc) + stencil{1,3}(i,nc);
        stencil{1,3}(i,nc) = 0;
        stencil{3,2}(i,nc) = stencil{3,2}(i,nc) + stencil{3,3}(i,nc);
        stencil{3,3}(i,nc) = 0;
    end
    
    % Corners.
    stencil{2,2}(1,1) = stencil{2,2}(1,1) + stencil{1,1}(1,1);
    stencil{2,2}(nr,1) = stencil{2,2}(nr,1) + stencil{3,1}(nr,1);
    stencil{2,2}(1,nc) = stencil{2,2}(1,nc) + stencil{1,3}(1,nc);
    stencil{2,2}(nr,nc) = stencil{2,2}(nr,nc) + stencil{3,3}(nr,nc);
else

    for i = 1:nc 
        stencil{1,2}(1,i) = 0;
        stencil{1,1}(1,i) = 0;
        stencil{1,3}(1,i) = 0;
        stencil{3,2}(nr,i) = 0;
        stencil{3,1}(nr,i) = 0;
        stencil{3,3}(nr,i) = 0;
    end
    
    for i = 1:nr
        stencil{2,1}(i,1) = 0;
        stencil{1,1}(i,1) = 0;
        stencil{3,1}(i,1) = 0;
        stencil{2,3}(i,nc) = 0;
        stencil{1,3}(i,nc) = 0;
        stencil{3,3}(i,nc) = 0;
    end
    
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
