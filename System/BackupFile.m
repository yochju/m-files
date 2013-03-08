function BackupFile()
%% <H1 LINE>
%
% <SIGNATURE>
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
% -
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

% Last revision on: dd.mm.yyyy hh:mm

%% Notes

% TODO: If buffer is not saved, make a backup by creating a new file (but
% where?)

%% Parse input and output.

%% Run code.

p = matlab.desktop.editor.getActiveFilename();

if isequal(exist(p,'file'),2)
    
    [pathstr, name, ext] = fileparts(p);
    
    name = [name '-' datestr(now,'yyyy-MM-dd-hh-mm-ss')];
    
    [status, message, messageid] = copyfile(p,fullfile(pathstr,[name ext]));
    
    if ~isempty(messageid) || ~isequal(status,1)
        
        MExc = ExceptionMessage('Internal', 'message', ...
            ['Could not create backup. Cause was: ' message]);
        
        error(MExc.id,MExc.message);
        
    end
    
else
    
    MExc = ExceptionMessage('Internal', 'message', ...
        'Cannot create backup of unsaved file.');
    
    % Create a backup in current working directory ( pwd() )
    % How does p look like if there is no editor open? empty?
    
    error(MExc.id,MExc.message);
    
end
		       
end
