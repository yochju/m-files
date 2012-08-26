function out = FindAllFiles(root)
%% Lists all files inside folder and its subfolders.
%
% out = FindAllFiles(root)
%
% Input parameters (required):
%
% root : root folder where search should be started.
%
% Output parameters:
%
% out : listing identical to the input but without the excluded files.
%
% See also FindAllFiles, dir

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

% Last revision: 26.08.2012 18:56

%% Check input parameters

narginchk(1, 1);
nargoutchk(0, 1);

% Make sure that the input argument is really a folder.
assert(isdir(root));
% Make sure that the address always ends in a '/'.
if ~strcmpi(root(end),'/')
    root = [ root '/' ];
end
% Get listing for current folder.
listing = dir(root);
% Remove the entries '.' and '..'
listing = ExcludeFromDir(listing,{'.','..'});
out = {};
for i = 1:length(listing)
    if listing(i).isdir
        % Get files from subdir and prepend folder name.
        temp = cellfun( ...
            @(x) [ listing(i).name '/' x ], ...
            FindAllFiles([root listing(i).name '/']) , ...
            'UniformOutput',false);
        % Join the listings.
        out = horzcat(out,temp);
    else
        % Append file to listing.
        out{end+1} = listing(i).name;
    end
end
end
