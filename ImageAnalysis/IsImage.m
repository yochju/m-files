function out = IsImage( in )
%% Verifies whether input is an image (i.e. an array of pixels).
%
% out = IsImage( in )
%
% Input parameters (required):
%
% in : data to be tested.
%
% Output parameters:
%
% out : true or false, depending on whether input is an image or not.
%
% Description:
%
% This routine checks whether the specified data is an image or not. The
% criteria are that the input is an nonempty 2d or 3d array of finite
% real-valued values. Note that there is no specification of the number of
% channels for color valued (3d) images.
%
% Example:
%
% IsImage(rand(10,10))
%
% returns the boolean true, whereas
%
% IsImage(inf(10,10))
%
% will return false.
%
% See also validateattributes, isa

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

% Last revision on: 30.04.2012 12:30

%% Check Input and Output Arguments

error(nargchk(1, 1, nargin));
error(nargoutchk(0, 1, nargout));

%% Algorithm

out = true;
try
    validateattributes(in, ...
        {'numeric'}, ...
        {'finite', 'nonempty', 'nonnan', 'real'} );
    dim = size(in);
    if length(dim) < 2 || length(dim) > 3
        error( ...
            'ImageAnalysis:isImage:NoImage', ...
            'Input is not an image.' );
    end
catch
    out = false;
end

end