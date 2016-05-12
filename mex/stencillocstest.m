function tests = stencillocstest()
%% Unit Tests for stencillocs.m
%
% Example
%
% results = runtests('stencillocstest.m')
%
% See also stencillocs

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

% Last revision: 2016-05-12 14:00

tests = functiontests(localfunctions);
end

function testsshrink1(testCase)
verifyEqual(testCase, ...
    stencillocs(5, 7), ...
    [-2; -1; 0; 1; 2], ...
    'AbsTol', 1e-12);
end

function testsshrink2(testCase)
verifyEqual(testCase, ...
    stencillocs([3, 3], [5, 7]), ...
    [-6, -5, -4, -1, 0, 1, 4, 5, 6]', ...
    'AbsTol', 1e-12);
end

function testsshrink2a(testCase)
verifyEqual(testCase, ...
    stencillocs([3, 3]', [5, 7]), ...
    [-6, -5, -4, -1, 0, 1, 4, 5, 6]', ...
    'AbsTol', 1e-12);
end

function testsshrink2b(testCase)
verifyEqual(testCase, ...
    stencillocs([3, 3], [5, 7]'), ...
    [-6, -5, -4, -1, 0, 1, 4, 5, 6]', ...
    'AbsTol', 1e-12);
end

function testsshrink2c(testCase)
verifyEqual(testCase, ...
    stencillocs([3, 3]', [5, 7]'), ...
    [-6, -5, -4, -1, 0, 1, 4, 5, 6]', ...
    'AbsTol', 1e-12);
end