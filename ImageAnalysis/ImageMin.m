function out = ImageMin( in )
%% Short description.
%
% out = NewFunction( in )
%
% Input parameters (required):
%
%
%
% Input parameters (optional):
%
%
%
% Output parameters:
%
%
%
% Description:
%
%
%
% Example:
%
%
%
% See also

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

% Last revision on: 06.06.2012 07:39

%% Check Input and Output Arguments

%% Algorithm

out = squeeze(min(min(I,[],1)));

end