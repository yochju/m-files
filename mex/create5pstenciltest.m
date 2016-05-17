function tests = create5pstenciltest()
%% Unit Tests for create5pstencil.m
%
% Example
%
% results = runtests('create5pstenciltest.m')
%
% See also create5pstencil

% Copyright (c) 2016 Laurent Hoeltgen <hoeltgen@b-tu.de>
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

% Last revision: 2016-05-12 17:00

tests = functiontests(localfunctions);
end

function testsshrink1(testCase)
verifyEqual(testCase, ...
    create5pstencil(1), ...
    [true; true; true]);
end

function testsshrink2(testCase)
verifyEqual(testCase, ...
    create5pstencil(2), ...
    [false; true; false; true; true; true; false; true; false]);
end
