classdef FreeKnotTest < matlab.unittest.TestCase
    % Unit Tests for the functions provided in +FreeKnot
    % Performs the unit tests for the function euclid. Enter
    %
    % import matlab.unittest.TestSuite;
    % suite = TestSuite.fromPackage('FreeKnot');
    % result = run(suite);
    %
    % at the prompt to evaluate all tests
    
    % Copyright (c) 2016 Laurent Hoeltgen <hoeltgen@b-tu.de>
    %
    % Permission is hereby granted, free of charge, to any person obtaining a
    % copy of this software and associated documentation files (the
    % "Software"), to deal in the Software without restriction, including
    % without limitation the rights to use, copy, modify, merge, publish,
    % distribute, sublicense, and/or sell copies of the Software, and to permit
    % persons to whom the Software is furnished to do so, subject to the
    % following conditions:
    %
    % The above copyright notice and this permission notice shall be included
    % in all copies or substantial portions of the Software.
    %
    % THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS
    % OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
    % MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN
    % NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM,
    % DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR
    % OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE
    % USE OR OTHER DEALINGS IN THE SOFTWARE.
    
    % Last revision: 2016-01-30 20:00
    
    methods (Test)
        function testoptapprox(testCase)
            c = FreeKnot.OptApprox(@(x) x.^2, 'fpi', @(x) x/2, ...
                'min', -1, 'max', 1, 'num', 3, 'its', 1000, 'ini', 'random');
            testCase.verifyEqual(c, [-1, 0, 1], 'AbsTol', 1e-15);
            
            c = FreeKnot.OptApprox(@(x) x.^2, 'fpi', @(x) x/2, ...
                'min', 0, 'max', 1, 'num', 3, 'its', 1000, 'ini', 'random');
            testCase.verifyEqual(c, [0, 0.5, 1], 'AbsTol', 1e-15);
            
            c = FreeKnot.OptApprox(@(x) x.^2, 'fpi', @(x) x/2, ...
                'min', -2, 'max', 2, 'num', 5, 'its', 1000, 'ini', 'random');
             testCase.verifyEqual(c, [-2, -1, 0, 1, 2], 'AbsTol', 1e-15);
        end
        
        function testoptinterp(testCase)
            c = FreeKnot.OptInterp(@(x) x.^2, 'fpi', @(x) x/2, ...
                'min', -1, 'max', 1, 'num', 3, 'its', 1000, 'ini', 'random');
            testCase.verifyEqual(c, [-1, 0, 1], 'AbsTol', 1e-15);
            
            c = FreeKnot.OptInterp(@(x) x.^2, 'fpi', @(x) x/2, ...
                'min', 0, 'max', 1, 'num', 3, 'its', 1000, 'ini', 'random');
            testCase.verifyEqual(c, [0, 0.5, 1], 'AbsTol', 1e-15);
            
            c = FreeKnot.OptInterp(@(x) x.^2, 'fpi', @(x) x/2, ...
                'min', -2, 'max', 2, 'num', 5, 'its', 1000, 'ini', 'random');
             testCase.verifyEqual(c, [-2, -1, 0, 1, 2], 'AbsTol', 1e-15);
        end
        
        function testerrorapprox(testCase)
            [eG, eL] = FreeKnot.ErrorApprox( @(x) x.^2, [-1, 0, 1]);
            testCase.verifyEqual(eL, [1, 1]/16, 'AbsTol', 1e-15);
            testCase.verifyEqual(eG, 1/8, 'AbsTol', 1e-15);
        end
        
        function testerrorinterp(testCase)
            [eG, eL] = FreeKnot.ErrorInterp( @(x) x.^2, [-1, 0, 1]);
            testCase.verifyEqual(eL, [1, 1]/6, 'AbsTol', 1e-15);
            testCase.verifyEqual(eG, 1/3, 'AbsTol', 1e-15);
        end
    end
    
end

