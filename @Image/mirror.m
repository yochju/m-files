function out = mirror(obj,size)
%Image/mirror pads the image by reflecting size pixels along each bound.
%
%   Input parameters (required):
%
% TODO
%
%   Input parameters (optional):
%
% TODO
%
%   Output parameters:
%
% TODO
%
%   Description:
%
% TODO
%
%   Example:
%
% TODO
%
%   See also pad, padarray

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

% Last revision on: 18.07.2012 07:01

l_data = double(obj(:,1:size));
t_data = double(obj(1:size,:));
r_data = double(obj(:,(end-size+1):end));
b_data = double(obj((end-size+1):end,:));
out = obj.pad('left',l_data,'right',r_data,'top',t_data,'bottom',b_data);
out.padding = size*ones(1,4);
end