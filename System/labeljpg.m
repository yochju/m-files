function labeljpg()
%% Script used store my photographs.
%
% labeljpg()
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
% Copies photographs in jpg file format from current working folder to photo
% archive (path is hardcoded).
%
% Example:
%
% -
%
% See also labelmpg

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

% Last revision on: 25.12.2012 10:00

%% Notes

%% Parse input and output.

%% Run code.

% Define destination root. Must end in a /!
root = '/home/laurent/Dropbox/Pictures/Photo/';

% Get listing of the current folder.
listing = dir('*');

% Work recursively through all the subfolders.
for i = 1:length(listing)
    if (listing(i).isdir == 1)
        if ~strcmp(listing(i).name,'.') && ~strcmp(listing(i).name,'..')
            % Move down and call labeljpg again.
            cd(listing(i).name);
            labeljpg();
            % Move back one level higher and continue searching.
            cd ..;
        end
    end
end

% Get the names of all jpg/JPG files.
% Todo: Handle .jpeg extensions.
% Something like:
% A = dir();
% B = regexp({A(:).name}, '.+\.jp(e)?g', 'match', 'ignorecase'); B{:}
% should do the trick. This would also eliminate the need to do 2 scans.
filesl = dir('*.jpg');
filesL = dir('*.JPG');
files = cell(1,length(filesl)+length(filesL));
for i = 1:length(filesl)
    files{i} = filesl(i).name;
end
for i = 1:length(filesL)
    files{length(filesl)+i} = filesL(i).name;
end

for i = 1:length(files)

    % Extract the time information from the photograph.
    data = imfinfo(files{i});
    dTime = regexp(data.DateTime, ...
        '(\d{4}):(\d{2}):(\d{2})\s(\d{2}):(\d{2}):(\d{2})','tokens');
    % Remove leading 0s.
    y = regexprep(dTime{1}(1),'^0+','');
    m = regexprep(dTime{1}(2),'^0+','');
    d = regexprep(dTime{1}(3),'^0+','');
    
    % Create the folder to store the photograph in.
    if ~isdir([root y{1} '/' m{1} '/' d{1}])
        mkdir([root y{1} '/' m{1} '/' d{1}]);
    end
    
    % Set up the filename.
    target = [ ...
        root y{1} '/' m{1} '/' d{1} '/' ...
        regexprep(data.DateTime,'(\d{4}):(\d{2}):(\d{2})','$1-$2-$3')];
    
    % Copy the photograph. Add a number if it already exists.
    if isempty(dir([target '.jpg']))
        copyfile(files{i},[target '.jpg']);
    else
        num = 1;
        while exist([target '(' num2str(num) ')' '.jpg'], 'file')
            num = num + 1;
        end
        copyfile(files{i},[target '(' num2str(num) ')' '.jpg']);
    end
end
end
