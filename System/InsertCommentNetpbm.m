function InsertCommentNetpbm(image,comment)
%% Insert a comment into any Netpbm (P1 to P6) file.

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

% Last revision on: 24.11.2012 21:41

tempfile = tempname();
fid1 = fopen(image,'r+');
fid2 = fopen(tempfile, 'w');
line = fgets(fid1);
fwrite(fid2,line);
% TODO: Handle cellstr as comments.
fwrite(fid2,comment);
fwrite(fid2,char(10));
while ~feof(fid1)
    fwrite(fid2,fgets(fid1));
end
fclose(fid1);
fclose(fid2);
movefile(tempfile,image);
end
