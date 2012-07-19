function varargout = imread(varargin)
%Image.imread reads an image file.
%   This is wrapper function for the builtin imread function. It uses the same
%   calling structure but instead of returning a matrix, it returns an Image
%   object. Padding is set to 0. Note that this is a static class method.
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
%   See also imread, imwrite

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

% Last revision on: 18.07.2012 06:46

error(nargoutchk(0,3,nargout));

switch nargout
    case 0
        %% Emit a warning and return image.
        ExcM = ExceptionMessage( ...
            'NumArg', ...
            'No output arguments have been specified.');
        warning(ExcM.id,ExcM.message);
        pixel = imread(varargin{:});
        varargout(1) = {Image(im2double(pixel),[0 0 0 0])};
    case 1
        %% Just return image.
        pixel = imread(varargin{:});
        varargout(1) = {Image(im2double(pixel),[0 0 0 0])};
    case 2
        %% Return image as well as map.
        [pixel map] = imread(varargin{:});
        varargout(1) = {Image(im2double(pixel),[0 0 0 0])};
        varargout(2) = {map};
    case 3
        %% Some specific image types allow the extraction of an alpha channel.
        [pixel map alpha] = imread(varargin{:});
        varargout(1) = {Image(im2double(pixel),[0 0 0 0])};
        varargout(2) = {map};
        varargout(3) = {alpha};
end

end