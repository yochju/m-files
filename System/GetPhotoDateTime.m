function [str year month day hour minute second] = GetPhotoDateTime(file)
%% Extract date time from an image file.
%
% [str year month day hour minute second] = GetPhotoDateTime(file)
%
% Input parameters (required):
%
% file : image file.
%
% Output parameters:
%
% str    : string containing the DateTime as given by imfinfo.
% year   : year of the datetime.
% month  : month of the datetime.
% day    : day of the datetime.
% hour   : hour of the datetime.
% minute : minute of the datetime.
% second : second of the datetime.
%
% Extracts the DateTime information (from imfinfo) from a specified file.
%
% Example
%
% GetPhotoDateTime('~/photo.jpg');
%
% See also imfinfo

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

% Last revision: 01.09.2012 11:38

%% Check input parameters

narginchk(1, 1);
nargoutchk(0, 7);

MExc = ExceptionMessage('NotFound','File does not seem to exist.');
assert(exist(file,'file')==2, MExc.id, MExc.message);

data = imfinfo(file);

MExc = ExceptionMessage('NoField','File does not contain a DateTime.');
assert(isfield(data,'DateTime'), MExc.id, MExc.message);

str = data.DateTime;
data = regexp(str,'(\d{4}):(\d{2}):(\d{2})\s(\d{2}):(\d{2}):(\d{2})','tokens');

year = data{1}(1);
month = data{1}(2);
day = data{1}(3);
hour = data{1}(4);
minute = data{1}(5);
second = data{1}(6);
end
