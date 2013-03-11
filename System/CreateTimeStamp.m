function out = CreateTimeStamp(str)
%% Create a string containing actual time (up to seconds)
%
% out = CreateTimeStamp(str)
%
% Input parameters (required):
%
% -
%
% Input parameters (parameters):
%
% Parameters are either struct with the following fields and corresponding
% values or option/value pairs, where the option is specified as a string.
%
% -
%
% Input parameters (optional):
%
% The number of optional parameters is always at most one. If a function takes
% an optional parameter, it does not take any other parameters.
%
% str : A string array to be prepended to the actual time.
%
% Output parameters:
%
% -
%
% Output parameters (optional):
%
% -
%
% Description:
%
% Returns a string containing the actual time. If a argument is provided, the
% time is appended.
%
% Example:
%
% CreateTimeStamp()
%
% See also datestr

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

% Last revision on: 08.03.2013 20:33

%% Notes

%% Parse input and output.

narginchk(0,1);
nargoutchk(0,1);

%% Run code.

if nargin == 0
    out = datestr(now,'yyyymmddHHMMSS');
elseif nargin == 1
    try
        validateattributes(str, {'char'}, {'row'}, mfilename, 'str', 1);
        out = [ str '_' datestr(now,'yyyymmddHHMMSS') ];
    catch err
        if strcmp(err.identifier,'MATLAB:CreateTimeStamp:invalidType')
            out = datestr(now,'yyyymmddHHMMSS');
        elseif strcmp(err.identifier,'MATLAB:CreateTimeStamp:expectedRow') && iscolumn(str)
            out = [ transpose(str(:)) '_' datestr(now,'yyyymmddHHMMSS') ];
        else
            rethrow(err)
        end
    end
else
    MExc = ExceptionMessage('Input');
    error(MExc.id,MExc.message);
end
end
