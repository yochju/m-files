function out = ExpHomLinDiff(in,varargin)

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

% Last revision on: 20.10.2012 21:32

narginchk(1, 5);
nargoutchk(0, 1);

parser = inputParser;
parser.FunctionName = mfilename;
parser.CaseSensitive = false;
parser.KeepUnmatched = true;
parser.StructExpand = true;

parser.addRequired('in', @(x) validateattributes( x, {'numeric'}, ...
    {'finite', 'nonempty', 'nonnan'}, ...
    mfilename, 'in', 1) );

parser.addParamValue('timeStep', 0.2, ...
    @(x) validateattributes( x, {'numeric'}, ...
    {'nonnan', 'finite', 'nonnegative', 'scalar'} ));

parser.addParamValue('its', 1, ...
    @(x) validateattributes( x, {'numeric'}, ...
    {'integer', 'nonnan', 'finite', 'nonnegative', 'scalar'} ));

parser.parse(in, varargin{:});
opts = parser.Results;

out = in;
for i = 1:opts.its
    out = out + opts.timeStep*ImageLapl(out,'scheme','rotinv');
end

end
