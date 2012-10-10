function UpdateFunction()

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

% Last revision on: 09.10.2012 15:50

doc = matlab.desktop.editor.getActive;

% Update Copyright string.
ts = regexp( doc.Text, ...
    'Copyright (\d\d\d\d,)*(\d\d\d\d){1}','tokens');

if ~strcmp( ts{1}{end}, datestr(now,'yyyy') )
    doc.Text = regexprep( ...
        doc.Text, ...
        'Copyright (\d\d\d\d,)*(\d\d\d\d){1}', ...
        ['Copyright $1$2,' datestr(now, 'yyyy')]);
end

% Update the Last revision string.
doc.Text = regexprep( ...
    doc.Text, ...
    'Last revision on: \d\d.\d\d.\d\d\d\d \d\d:\d\d', ...
    'Last revision on: ${datestr(now, ''dd.mm.yyyy HH:MM'')}' );

end
