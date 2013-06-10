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

% Last revision on: 10.06.2013 18:00

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
    {}, mfilename, 'stencil', 1));

parser.addParamValue('boundary', 'Neumann', ...
    @(x) strcmpi(x, validatestring(x, {'Dirichlet', 'Neumann'}, mfilename, ...
    'boundary')));

parser.parse( stencil, varargin{:});
opts = parser.Results;

%% Run code.

[nr nc] = size(stencil{1,1});

M = spdiags( ...
    [ ...
    stencil{1,1}(:) stencil{2,1}(:) stencil{3,1}(:) ...
    stencil{1,2}(:) stencil{2,2}(:) stencil{3,2}(:) ...
    stencil{1,3}(:) stencil{2,3}(:) stencil{3,3}(:)], ...
    [0 1 2 nr nr+1 nr+2 2*nr 2*nr+1 2*nr+2], ...
    nr*nc,nr*(nc+2)+2);

% Remove indices that belong to entries outside of the domain. This also ensures
% correct handling of Dirichlet Neumann conditions.

% The following code fails on matrices with more than 65536^2 entries on 32 bit
% systems, because Matlab only uses 31 bit for the index. We use the (slightly)
% faster method for small matrices and switch to the other one when the data
% gets too large.
[str, msize] = computer;
if (nr*nc)^2 < msize
    %% TODO : The methods still differ somewhere...
    M(sub2ind(size(M),1:nr:nr*nc,1:nr:nr*nc)) = 0;
    M(sub2ind(size(M),1:nr:nr*nc,nr+(1:nr:nr*nc))) = 0;
    M(sub2ind(size(M),1:nr:nr*nc,2*nr+(1:nr:nr*nc))) = 0;
    
    M(sub2ind(size(M),nr:nr:nr*nc,nr+1+(1:nr:nr*nc))) = 0;
    M(sub2ind(size(M),nr:nr:nr*nc,2*nr+1+(1:nr:nr*nc))) = 0;
    M(sub2ind(size(M),nr:nr:nr*nc,3*nr+1+(1:nr:nr*nc))) = 0;
else
    for i = 1:nr:(nr*nc)
        M(i, i) = 0;             % S11
        M(i, i+nr) = 0;          % S12
        M(i, i+2*nr) = 0;        % S13
        M(i+(nr-1), i+nr) = 0;   % S31
        M(i+(nr-1), i+2*nr) = 0; % S32
        M(i+(nr-1), i+3*nr) = 0; % S32
    end
end

% Crop the Matrix M to get the relevant part only.
% Calling sparse here another time makes sense. If the stencil contains 0s, they
% will vanish from the matrix here.
M = sparse(M(:,((nr+1)+1):((nr+1)+nr*nc)));

% Neumann boundary conditions need special treatment. Dirichlet boundary
% conditions are handled automatically by cropping and setting to 0.
if strcmpi(opts.boundary,'Neumann')
    % Neumann boundary conditions can be handled by adding the coefficients of
    % the stencil that hang out of the image back onto the central stencil entry
    % (e.g. main diagonal).
    
    % Direct left neighbour.
    for i = 1:nr
        M(i,i) = M(i,i) + stencil{2,1}(i,1);
    end
    
    % Direct right neighbour.
    for i = 1:nr
        M((nc-1)*nr+i,(nc-1)*nr+i) = ...
            M((nc-1)*nr+i,(nc-1)*nr+i) + stencil{2,3}(i,nc);
    end
    
    % Top neighbour.
    for i = 1:nc
        M(1+(i-1)*nr,1+(i-1)*nr) = ...
            M(1++(i-1)*nr,1+(i-1)*nr) + stencil{1,2}(1,i);
    end
    
    % Bottom neighbour.
    for i = 1:nc
        M(nr+(i-1)*nr,nr+(i-1)*nr) = ...
            M(nr+(i-1)*nr,nr+(i-1)*nr) + stencil{3,2}(nr,i);
    end
    
    % Upper left neighbour.
    M(1,1) = M(1,1) + stencil{1,1}(1,1);
    
    % Upper right neighbour.
    M((nc-1)*nr,(nc-1)*nr) = M((nc-1)*nr,(nc-1)*nr) + stencil{1,3}(1,nc);
    
    % Lower left neighbour.
    M(nr,nr) = M(nr,nr) + stencil{3,1}(nr,1);
    
    % Lower right neighbour.
    M(nr*nc,nr*nc) = M(nr*nc,nr*nc) + stencil{3,3}(nr,nc);
    
end

end
