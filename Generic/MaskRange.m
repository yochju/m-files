function y = MaskRange(sig_size,win_size,pos)
% MaskRange
% Returns the range of indices of a mask of size (2*win_size+1) that overlap
% with the signal of size sig_size at position pos.
%
% Example
% signal = 1:10;
% window = ones(1,5);
% MaskRange(10,2,1)

% Copyright 2011 Laurent Hoeltgen <hoeltgman@gmail.com>
%
% This program is free software; you can redistribute it and/or modify
% it under the terms of the GNU General Public License as published by
% the Free Software Foundation; either version 3 of the License, or
% (at your option) any later version.
%
% This program is distributed in the hope that it will be useful,
% but WITHOUT ANY WARRANTY; without even the implied warranty of
% MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
% GNU General Public License for more details.
%
% You should have received a copy of the GNU General Public License
% along with this program; if not, write to the Free Software
% Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston,
% MA 02110-1301, USA

y = max(win_size+2-pos,1):min(sig_size+win_size+1-pos,2*win_size+1);
end