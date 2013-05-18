function NewFunction()
%% Create buffer with function template.
%
% NewFunction()
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
% Creates a new buffer and inserts a template for new functions. The template
% is the content of the file ~/Templates/matlab.m.
%
% Example:
%
% NewFunction()
%
% See also  matlab.desktop.editor.newDocument

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

% Last revision on: 08.03.2013 07:47

%% Notes

%% Parse input and output.

narginchk(0,0);
nargoutchk(0,0);

%% Run code.


template = [char(java.lang.System.getProperty('user.home')) ...
    '/Templates/matlab.m'];
url = ['file://' template];

% Alternative:
% if ispc
% home = [getenv('HOMEDRIVE') getenv('HOMEPATH')];
% else
% home = getenv('HOME');
% end

% More information on the api:
% http://blogs.mathworks.com/desktop/2011/05/16/matlab-editor-api-examples/
% http://blogs.mathworks.com/desktop/2011/05/09/r2011a-matlab-editor-api/
try
    
    str = urlread(url);
    matlab.desktop.editor.newDocument(str);
    
catch err
    
    if strcmp(err.identifier,'MATLAB:urlread:ConnectionFailed')
        
        if exist(template,'file')~=2
            
            excM = ExceptionMessage('NotFound', ...
                'message', 'Template file does not seem to exist.');
            MExc = MException(excM.id,excM.message);
            err = addCause(err, MExc);
            rethrow(err);
            
        end
        
    else
        
        rethrow(err);
        
    end
    
end

end
