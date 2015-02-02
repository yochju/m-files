classdef ColourSpace
    %Enumaration for the most common colour spaces for an image.
    %Defines common colour spaces.
    % None:  The underlying colour space is unknown.
    % Bit:   The image represents a bit map, i.e. an indexed gray scale image
    %        with range {0,1}.
    % Byte:  All pixels are encoded by a single byte, i.e. indexed gray scale
    %        image.
    % RGB:   Standard RGB colour space
    % HSV:   HSV colour space
    % YCbCr: YCbCr colour space
    
    % Copyright 2015 Laurent Hoeltgen <laurent.hoeltgen@gmail.com>
    %
    % This program is free software; you can redistribute it and/or modify it
    % under the terms of the GNU General Public License as published by the Free
    % Software Foundation; either version 3 of the License, or (at your option)
    % any later version.
    %
    % This program is distributed in the hope that it will be useful, but
    % WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY
    % or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public License
    % for more details.
    %
    % You should have received a copy of the GNU General Public License along
    % with this program; if not, write to the Free Software Foundation, Inc., 51
    % Franklin Street, Fifth Floor, Boston, MA 02110-1301, USA.
    
    % Last revision on: 02.02.2015 16:00
    
    enumeration
        None, Bit, Byte, RGB, HSV, YCbCr
    end    
end

