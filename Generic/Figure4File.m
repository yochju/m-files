function fighandle = Figure4File(varargin)
%% Creates a figure handle to plot to a file.
%
% fighandle = Figure4File(varargin)
%
% Input parameters (required):
%
% Input parameters (optional):
%
% Optional parameters are either struct with the following fields and
% corresponding values or option/value pairs, where the option is specified as a
% string.
%
% Size   : Size of the plot in centimeters. (array of length 2)
%          (default = [12 8])
% Border : Distance of the axes from the paper edge in centimeters. (array of
%          length 2) (default = [1.25 1.25])
%
% Output parameters:
%
% fighandle : handle to the figure.
%
% Description:
%
% Sets up a figure such that it can nicely be plotted onto a DIN A4 sheet in
% landscape format. Loosely based on
%
% http://itb.biologie.hu-berlin.de/~schaette/HomeFiles/MatlabPlots.pdf
%
% Example:
% x = linspace(-pi,pi,2048);
% y = sin(x);
% fig = Figure4File('Size', [16 12], 'Border', [1.25 1]);
% plot(x,y);
% xlabel('x');
% ylabel('sin(x)');
% title('A function plot');
% print(fig,'out2.pdf','-dpdf');
%
% See also figure, axes, plot, print

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

% Last revision on: 09.10.2012 10:30

%%
narginchk(0,4);
nargoutchk(0,1);

parser = inputParser;
parser.FunctionName  = mfilename;
parser.CaseSensitive = false;
parser.KeepUnmatched = true;
parser.StructExpand  = true;

parser.addParamValue( ...
    'Size', [12 8], ...
    @(x) isvector(x)&&isequal(length(x),2) ...
    );
parser.addParamValue( ...
    'Border', [1.25 1.25], ...
    @(x) isvector(x)&&isequal(length(x),2) ...
    );

parser.parse(varargin{:})
opts = parser.Results;

% Create the figure and set the parameters.
% NOTE: The paper size is tricky.
% For pdf prints it works out of the box.
% For eps (with epsc2) the size is only respected when
% print(gcf,'outfoo.eps','-depsc2','-loose');
% is being used. For the eps files, the following snippet might be useful:
%
% set(gca, 'Position', get(gca, 'OuterPosition') - ...
%     get(gca, 'TightInset') * [-1 0 1 0; 0 -1 0 1; 0 0 1 0; 0 0 0 1]);
%
% However you must watch the boundaries then.
% (Found at http://nibot-lab.livejournal.com/73290.html)
fighandle = figure();
set(fighandle, 'PaperUnits', 'centimeters');
set(fighandle, 'PaperSize', transpose(opts.Size(:)) );
set(fighandle, 'PaperPositionMode', 'manual');
set(fighandle, 'PaperPosition', [0 0 transpose(opts.Size(:))]);
set(fighandle, 'Position', [100 100 transpose(opts.Size(:))*20]);
axes('Position', [ ...
    transpose(opts.Border(:))./transpose(opts.Size(:)) ...
    1 - 2 * transpose(opts.Border(:))./transpose(opts.Size(:)) ...
    ] );
end
