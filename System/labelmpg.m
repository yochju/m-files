function labelmpg()
%% Script used store my videos.
%
% labelmpg()
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
% Copies videos in mpg or avi file format from current working folder to video
% archive (path is hardcoded).
%
% Example:
%
% -
%
% See also labeljpg

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
root = '/home/laurent/Desktop/Video/';

% Work throgh all the subfolders.
listing = dir('*');

% Work recursively through all the subfolders.
for i = 1:length(listing)
    if (listing(i).isdir == 1)
        if ~strcmp(listing(i).name,'.') && ~strcmp(listing(i).name,'..')
            % Move down and call labeljpg again.
            cd(listing(i).name);
            labelmpg();
            % Move back one level higher and continue searching.
            cd ..;
        end
    end
end

% Work through all the files.
filesl = dir('*.mpg');
filesL = dir('*.MPG');
filesa = dir('*.avi');
filesA = dir('*.AVI');
files = cell(1,length(filesl)+length(filesL)+length(filesa)+length(filesA));
for i = 1:length(filesl)
    files{i} = filesl(i).name;
end
for i = 1:length(filesL)
    files{length(filesl)+i} = filesL(i).name;
end
for i = 1:length(filesa)
    files{length(filesl)+length(filesL)+i} = filesa(i).name;
end
for i = 1:length(filesA)
    files{length(filesl)+length(filesL)+length(filesa)+i} = filesA(i).name;
end

for i = 1:length(files)
    
    data = dir(files{i});
    [y m d] = datevec(data.datenum);
    
    if ~isdir([root num2str(y) '/' num2str(m) '/' num2str(d)])
        mkdir([root num2str(y) '/' num2str(m) '/' num2str(d)]);
    end
    
    target = [ ...
        root num2str(y) '/' num2str(m) '/' num2str(d) '/' ...
        datestr(data.datenum,'yyyy-mm-dd HH:MM:SS')];
    if regexpi(files{i},'mpg$')
        if isempty(dir([target '.mpg']))
            copyfile(files{i},[target '.mpg']);
        else
            num = 1;
            while exist([target '(' num2str(num) ')' '.mpg'],'file')
                num = num + 1;
            end
            copyfile(files{i},[target '(' num2str(num) ')' '.mpg']);
        end
    elseif regexpi(files{i},'avi$')
        if isempty(dir([target '.avi']))
            copyfile(files{i},[target '.avi']);
        else
            num = 1;
            while exist([target '(' num2str(num) ')' '.avi'], 'file')
                num = num + 1;
            end
            copyfile(files{i},[target '(' num2str(num) ')' '.avi']);
        end
    end
end
end
