function varargout = ImageToJBIG(in, name, varargin)
%% Write binary image to JBIG file.
%
% [status result] = ImageToJBIG(in, name, varargin)
%
% Input parameters (required):
%
% in   : Input data to be stored. Must be binary valued. (array)
% name : Target file name without extension. (string)
%
% Input parameters (parameters):
%
% Parameters are either struct with the following fields and corresponding
% values or option/value pairs, where the option is specified as a string.
%
% Encoding : whether the underlying pbm file is stored in ascii ('ASCII') or raw
%            bits ('rawbits'). (default = 'rawbits')
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
% status : Return value from the pbmtojbg binary.
% result : Return value from the pbmtojbg binary.
%
% Output parameters (optional):
%
% -
%
% Description:
%
% Uses the program pbmtojbg to write an image to jbg format. The program
% pbmtojbg must be installed somewhere where the system command can find it. The
% software is available here: http://www.cl.cam.ac.uk/~mgk25/jbigkit/ and
% licensed under the GPL.
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

% Last revision on: 05.02.2013 14:26

%% Notes

%% Parse input and output.

narginchk(2,4);
nargoutchk(0,2);

parser = inputParser;
parser.FunctionName = mfilename;
parser.CaseSensitive = false;
parser.KeepUnmatched = true;
parser.StructExpand = true;

parser.addRequired('in', @(x) validateattributes( x, {'numeric', 'logical'}, ...
    {'2d', 'finite', 'nonempty', 'nonnan', 'nonsparse'}, ...
    mfilename, 'in', 1) );

parser.addRequired('name', @(x) validateattributes( x, {'char'}, ...
    {'row'}, mfilename, 'name', 2) );

parser.addParamValue('Encoding', 'rawbits', @(x) strcmpi(x, ...
    validatestring( x, {'rawbits', 'ASCII'}, mfilename, 'Encoding') ) );

parser.parse(in, name, varargin{:});
opts = parser.Results;

% pbm file format may only contain binary data.
MExc = ExceptionMessage('Input', 'message', ...
    'Input data must be binary.');
assert(all((in(:)==0)|(in(:)==1)),MExc.id,MExc.message);

% Do not overwrite any existing file.
MExc = ExceptionMessage('Input', 'message', ...
    'Target file already exists. Aborting.');
assert(exist([name '.jbg'],'file')==0, MExc.id, MExc.message);

%% Run code.

% Check whether there is a pbmtojbg binary.
[status pbmtojbg] = system('which pbmtojbg');

% The last character is a new line feed.
pbmtojbg = pbmtojbg(1:(end-1));

if status == 0
    tmp_nam = [tempname '.pbm'];
    imwrite(in, tmp_nam, 'Encoding', opts.Encoding);
    [varargout{1:nargout}] = system([pbmtojbg ' ' tmp_nam ' ' name '.jbg']);
    delete(tmp_nam);
else
    MExc = ExceptionMessage('Internal', 'message', ...
        'Cannot find pbmtojbg executable');
    error(MExc.id, MExc.message);
end

end
