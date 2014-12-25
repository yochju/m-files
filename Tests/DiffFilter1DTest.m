function tests = DiffFilter1DTest ()
%% Unit test for the method DiffFilter1D
tests = functiontests (localfunctions);
end

% http://en.wikipedia.org/wiki/Finite_difference_coefficient
% for more tests

function FirstOrderTest (testCase)
%% Test for first order derivatives with default values.
[coeffs, cons] = DiffFilter1D ([ 0, 1],   1);
verifyEqual (testCase, coeffs, [-1, 1]);
verifyEqual (testCase, cons, 1);
[coeffs, cons] = DiffFilter1D ([-1, 0],   1);
verifyEqual (testCase, coeffs, [-1, 1]);
verifyEqual (testCase, cons, 1);
[coeffs, cons] = DiffFilter1D ([-1, 0, 1], 1);
verifyEqual (testCase, coeffs, [-0.5, 0, 0.5]);
verifyEqual (testCase, cons, 2);
end

function SecondOrderTest (testCase)
%% Test for second order derivative with default values.
[coeffs, cons] = DiffFilter1D ([-1, 0, 1], 2);
verifyEqual (testCase, coeffs, [1, -2, 1]);
verifyEqual (testCase, cons, 2);
end

function GridSizeTest (testCase)
%% Test for different values of the GridSize parameter.
[coeffs, cons] = DiffFilter1D ([ 0, 1], 1, 'GridSize', 0.5);
verifyEqual (testCase, coeffs, [-2, 2]);
verifyEqual (testCase, cons, 1);
[coeffs, cons] = DiffFilter1D ([ 0, 1], 1, 'GridSize', 2.0);
verifyEqual (testCase, coeffs, [-0.5, 0.5]);
verifyEqual (testCase, cons, 1);
end
