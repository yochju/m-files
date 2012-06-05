function out = ImageChannelFun( in, fun )
%% Apply a scalar valued function on each channel.
%
% out = ImageChannelFun( in, fun )
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

% Last revision on: 05.06.2012 09:56

%% Check Input and Output Arguments

error(nargchk(2, 2, nargin));
error(nargoutchk(0, 1, nargout));

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
out = zeros(s(end),1);
emit_warning = true;
for i = 1:s(end)
    temp = fun(opts.in(:,:,i));
    if (emit_warning == true) && ~isscalar(temp)
        warning(['ImageAnalysis:' mfilename ':BadInput'], ...
            'Function handle returns non scalar result.');
        emit_warning = false;
    end
    out(i) = temp;
end

end