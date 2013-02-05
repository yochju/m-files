function [out] = ImageReadJBIG(name)
%% Reads an image in JBIG format.
%
% [out] = ImageReadJBIG(name)
%
% Input parameters (required):
%
% name : Name of the file to be read.
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
% -
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
% Uses the program jbgtopbm to read a jbg file. The program jbgtopbm must
% be installed somewhere where the system command can find it. The software is
% available here: http://www.cl.cam.ac.uk/~mgk25/jbigkit/ and licensed under the
% GPL.
%
% Example:
%
% -
%
% See also

% Copyright 2013 Laurent Hoeltgen <laurent.hoeltgen@gmail.com>
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

% Last revision on: 05.02.2013 15:25

%% Notes

%% Parse input and output.

narginchk(1,1);
nargoutchk(0,1);

parser = inputParser;
parser.FunctionName = mfilename;
parser.CaseSensitive = false;
parser.KeepUnmatched = true;
parser.StructExpand = true;

parser.addRequired('name', @(x) validateattributes( x, {'char'}, ...
    {'row'}, mfilename, 'name', 1) );

% Check if file exists.
MExc = ExceptionMessage('Input', 'message', ...
    'Target file does not exist. Aborting.');
assert(exist(name,'file')==2, MExc.id, MExc.message);

%% Run code.

% Check whether there is a pbmtojbg binary.
[status jbgtopbm] = system('which jbgtopbm');

% The last character is a new line feed.
jbgtopbm = jbgtopbm(1:(end-1));

if status == 0
    tmp_nam = [tempname '.pbm'];
    [status result] = system([jbgtopbm ' ' name ' ' tmp_nam]);
    if status ~= 0
        MExc = ExceptionMessage('Internal', 'message', ...
            ['jbgtopbm failed with status ' num2str(status) ...
            '. Message was: ' result]);
        error(MExc.id, MExc.message);
    else
        MExc = ExceptionMessage('Input', 'message', ...
            'Could not create temporary pbm file. Aborting.');
        assert(exist( tmp_nam,'file')==2, MExc.id, MExc.message);
        out = imread(tmp_nam,'pbm');
        delete(tmp_nam);
    end
else
    MExc = ExceptionMessage('Internal', 'message', ...
        'Cannot find jbgtopbm executable');
    error(MExc.id, MExc.message);
end

end
