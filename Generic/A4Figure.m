function fighandle = A4Figure()
%% Creates a figure handle to plot on DIN A4 landscape paper.
%
% fighandle = A4Figure()
%
% Input parameters (required):
%
% Input parameters (optional):
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
% fig = A4Figure();
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

% Last revision on: 08.10.2012 17:36

%%
narginchk(0, 0);
nargoutchk(0, 1);

% Size of the plot in centimeters.
xSize = 27.7;
ySize = 19;

% Paper size (A4)
xA4Land = 29.7;
yA4Land = 21.0;

% Left and top border of the figure on the sheet.
xLeft = (xA4Land - xSize)/2;
yTop  = (yA4Land - ySize)/2;

% Distance of the axis from the figure boundary.
xLeftAxis  = 1.5/xSize;
yBotAxis   = 1.5/ySize;

% Size of the axis.
AxisWidth  = 1 - 2*xLeftAxis;
AxisHeight = 1 - 2*yBotAxis;

% Create the figure and set the parameters.
fighandle = figure();
set(fighandle, 'PaperUnits', 'centimeters');
set(fighandle, 'PaperOrientation', 'landscape');
set(fighandle, 'PaperType', 'A4');
set(fighandle, 'PaperPosition', [xLeft yTop xSize ySize]);
set(fighandle, 'Position', [100 100 xSize*50 ySize*50]);
axes('Position', [ xLeftAxis yBotAxis AxisWidth AxisHeight ] );
end
