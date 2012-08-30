function out = FindFileType(listing,type)
%% Filter input for files of a certain type.
%
% out = FindFileType(listing,type)
%
% Input parameters (required):
%
% listing : cellstring containing files.
% type    : string containing the filetype (jpg, mpeg, ...)
%
% Output parameters:
%
% out : cellstr with found matches.
%
% See also strfind, regexp

% Copyright 2012 Laurent Hoeltgen <laurent.hoeltgen@gmail.com>
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

% Last revision: 30.08.2012 11:32

%% Check input parameters

narginchk(2, 2);
nargoutchk(0, 1);

out = StrFilter(listing,[type '$'],false);
end
