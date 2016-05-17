function tests = stencilmasktest()
%% Unit Tests for stencilmask.m
%
% Example
%
% results = runtests('stencilmasktest.m')
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

% Last revision: 2016-05-17 14:00

tests = functiontests(localfunctions);
end

function testsshrink0(testCase)
verifyEqual(testCase, ...
    stencilmask(3, 10, -1), ...
    [false; false; false]);
end

function testsshrink1(testCase)
verifyEqual(testCase, ...
    stencilmask(3, 10, 0), ...
    [false; false; true]);
end

function testsshrink2(testCase)
verifyEqual(testCase, ...
    stencilmask(3, 10, 1), ...
    [false; true; true]);
end

function testsshrink3(testCase)
verifyEqual(testCase, ...
    stencilmask(3, 10, 2), ...
    [true; true; true]);
end