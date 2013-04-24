function out = ImageChannelTransform( in , fun )
%% Applies the function f channelwise onto an image.
%
% out = ImageChannelTransform( in , f )
%
% Input parameters (required):
%
% in  : input image ( array, the last dimension is assumed to contain the pixel
%       values ).
% fun : a function handle to apply on each channel.
%
% Output parameters:
%
% out : image where fun has been applied onto each pixel.
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

% Copyright 2012, 2013 Laurent Hoeltgen <laurent.hoeltgen@gmail.com>
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

% Last revision on: 24.04.2013 09:45

%% Check Input and Output Arguments

narginchk(2, 2);
nargoutchk(0, 1);

parser = inputParser;
parser.FunctionName = mfilename;
parser.CaseSensitive = false;
parser.KeepUnmatched = true;
parser.StructExpand = true;

parser.addRequired('in', @(x) validateattributes( x, {'numeric'}, ...
    {'finite', 'nonempty', 'nonnan'}, ...
    mfilename, 'in', 1) );

parser.addRequired('fun', @(x) validateattributes( x, ...
    {'function_handle'}, {}, ...
    mfilename, 'fun') );

parser.parse(in,fun);
opts = parser.Results;

%% Algorithm

s = size(opts.in);
out = zeros(s);
emit_warning = true;
for i = 1:s(end)
    temp = fun(opts.in(:,:,i));
    if (emit_warning == true) && ~isequal(size(temp),s(1:(end-1)))
        warning(['ImageAnalysis:' mfilename ':BadInput'], ...
            'Function handle returns result of a different size than input');
        emit_warning = false;
    end
    out(:,:,i) = temp;
end

end
