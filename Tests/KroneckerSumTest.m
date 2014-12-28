function tests = KroneckerSumTest ()
%% Unit test for method KroneckerSum
tests = functiontests (localfunctions);
end

function SumTest (testcase)
A = [1, 2; 3, 4];
B = [5, 6; 7, 8];
M = KroneckerSum (A, B);
sol = sparse([ ...
    6, 6, 2,  0; ...
    7, 9, 0,  2; ...
    3, 0, 9,  6; ...
    0, 3, 7, 12]);
verifyEqual(testcase, sol, M);
end