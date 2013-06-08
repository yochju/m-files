function M = Stencil2Mat(stencil)
%% Transform a Stencil to a corresponding Matrix.
%
% M = Stencil2Mat(stencil)
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

% Last revision on: 08.06.2013 20:52

%% Notes

%% Parse input and output.

%% Run code.

[nr nc] = size(stencil{1,1});

M = spdiags( ...
    [ ...
    stencil{1,1}(:) stencil{2,1}(:) stencil{3,1}(:) ...
    stencil{1,2}(:) stencil{2,2}(:) stencil{3,2}(:) ...
    stencil{1,3}(:) stencil{2,3}(:) stencil{3,3}(:)], ...
    [0 1 2 nr nr+1 nr+2 2*nr 2*nr+1 2*nr+2], ...
    nr*nc,nr*(nc+2)+2);

M(sub2ind(size(M),1:nr:nr*nc,1:nr:nr*nc)) = 0;
M(sub2ind(size(M),1:nr:nr*nc,nr+(1:nr:nr*nc))) = 0;
M(sub2ind(size(M),1:nr:nr*nc,2*nr+(1:nr:nr*nc))) = 0;

M(sub2ind(size(M),nr:nr:nr*nc,nr+1+(1:nr:nr*nc))) = 0;
M(sub2ind(size(M),nr:nr:nr*nc,2*nr+1+(1:nr:nr*nc))) = 0;
M(sub2ind(size(M),nr:nr:nr*nc,3*nr+1+(1:nr:nr*nc))) = 0;

% Crop the Matrix M to get the relevant part only.
M = sparse(M(:,((nr+1)+1):((nr+1)+nr*nc)));
		       
end
