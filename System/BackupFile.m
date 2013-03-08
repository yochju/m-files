function BackupFile()
%% Create a backup of the currently active buffer.
%
% BackupFile()
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
% Creates a backup file of the currently active buffer by appending the current
% time to its name and saving it to a separate file in the same folder as the
% original file. If the buffer is unsaved, the file will be created in the
% current working directory.
%
% Example:
%
% BackupFile()
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

% Last revision on: 08.03.2013 20:21

%% Notes

%% Parse input and output.

narginchk(0,0);
nargoutchk(0,0);

%% Run code.

p = matlab.desktop.editor.getActiveFilename();

if isequal(exist(p,'file'),2)
    
    [pathstr, name, ext] = fileparts(p);
    
    name = [name '-' datestr(now,'yyyy-MM-dd-hh-mm-ss')];
    
    [status, message, messageid] = copyfile(p,fullfile(pathstr,[name ext]));
    
    if ~isempty(messageid) || ~isequal(status,1)
        
        MExc = ExceptionMessage('Internal', 'message', ...
            ['Could not create backup. Cause: ' message]);
        error(MExc.id,MExc.message);
        
    end
    
else % ~isequal(exist(p,'file'),2)
    
    if ~isempty(p)
        
        [~, name, ext] = fileparts(p);
        name = [name '-' datestr(now,'yyyy-MM-dd-hh-mm-ss')];
        
        doc = matlab.desktop.editor.getActive();
        
        [fid message] = fopen(fullfile(pwd(), [name ext]), 'w');
        
        if fid >= 0
            
            nbytes = fprintf(fid, doc.Text);
            if nbytes <= 0
                MExc = ExceptionMessage('Internal', 'message', ...
                    'Non positive number of bytes written to backup file.');
                error(MExc.id,MExc.message);
            end
            
            status = fclose(fid);
            if ~isequal(status,0)
                MExc = ExceptionMessage('Internal', 'message', ...
                    'Could not close file where backup was written to.');
                error(MExc.id,MExc.message);
            end
            
        else % fid < 0
            
            MExc = ExceptionMessage('Internal', 'message', ...
                ['Could not create backup. Cause: ' message]);
            error(MExc.id,MExc.message);
            
        end
        
    else % isempty(p)
        
        MExc = ExceptionMessage('Internal', 'message', ...
            'Cannot create backup of a buffer without a name.');
        
        error(MExc.id,MExc.message);
        
    end
    
end

end
