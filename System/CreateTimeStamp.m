function out = CreateTimeStamp(str)
%% Create a string containing actual time (up to seconds)

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

% Last revision on: 23.11.2012 11:50

%% Notes

%% Parse input and output.

narginchk(0,1);
nargoutchk(0,1);

parser = inputParser;
parser.FunctionName = mfilename;
parser.CaseSensitive = false;
parser.KeepUnmatched = true;
parser.StructExpand = true;

% parser.addOptional('str', '', @(x) validateattributes( x, {'char'}, ...
%     {'row', 'nonempty'}, mfilename, 'str', 1) );
% 
% parser.parse(varargin{:});
% opts = parser.Results;

%% Run code.

if nargin == 0
    out = datestr(now,'yyyymmddHHMMSS');
elseif nargin == 1
    out = [ str '_' datestr(now,'yyyymmddHHMMSS') ];
else
    MExc = ExceptionMessage('Input');
    error(MExc.id,MExc.message);
end
end
