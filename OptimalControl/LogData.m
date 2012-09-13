function LogData(data,URL)
%% Save the computed data in the specified folder.
%
% LogData(data,URL)
%
% Input parameters (required):
%
% data : structure containing the data to be saved.
% URL  : absolute folder path to the location where the data should be saved.
%
% Input parameters (optional):
%
% Output parameters:
%
% Description:
%
% Saves the data computed by the optimal control framework inside a mat file in
% the specified folder.
%
% Example:
%
% See also save.

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

% Last revision on: 13.09.2012 11:00

narginchk(2, 2);
nargoutchk(0, 0);

parser = inputParser;
parser.FunctionName = mfilename;
parser.CaseSensitive = false;
parser.KeepUnmatched = true;
parser.StructExpand = true;

parser.addRequired('data', @(x) isstruct(x));
parser.addRequired('URL', @(x) ischar(x)&&isdir(x));

parser.parse(data,URL);
opts = parser.Results;

if ~strcmp(opts.URL(end),'/')
    opts.URL = [opts.URL '/'];
end

logname = ['Results-' datestr(now,'yyyy-mm-dd_HH-MM-SS')];
save([ opts.URL logname ],'-struct','data');

end
