function stencil = create5pstencil(dim)
%% Create 5 point stencil for arbitrary dimensions
%
% Create a mask for a 5 point stencil in arbitrary dimensions
%
% stencil = create5pstencil(dim)
%
% Mandatory Parameters:
%  
% dim:     scalar integer indicating in which dimension we operate
%
% Optional Parameters:
%
% -
%
% Output Parameters:
%
% stencil: coloumn array of booleans indicating valid mask positions
%
% Example
%
% create5pstencil(1)
%
% returns [true; true; true]
%
% whereas
%
% create5pstencil(2)
%
% returns [false; true; false; true; true; true; false; true; false]
%
% See also stencillocs, stencilmask

% Copyright (c) 2016 Laurent Hoeltgen <hoeltgen@b-tu.de>
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

% Last revision: 2016-05-17 15:00

%% Parse input and output.

narginchk(1, 1);
nargoutchk(0, 1);

parser               = inputParser;
parser.FunctionName  = mfilename;
parser.KeepUnmatched = false;
parser.StructExpand  = false;

% Parse mandatory arguments

parser.addRequired('dim', ...
    @(x) validateattributes(x, ...
    {'double'}, ...
    {'scalar', 'integer', 'positive'}, ...
    mfilename, 'dim', 1));

parser.parse(dim);

%% Run Code

stencil = (0 < mexcreate_5p_stencil(dim));
end