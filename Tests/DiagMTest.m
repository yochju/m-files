function tests = DiagMTest ()
%% Unit test for method DiagM
tests = functiontests (localfunctions);
end

function DMTest (testcase)
v = [1, 2, 3, 4];
M = DiagM(v);
sol = sparse([ ...
    1, 0, 0, 0; ...
    0, 2, 0, 0; ...
    0, 0, 3, 0; ...
    0, 0, 0, 4]);
verifyEqual(testcase, sol, M);
end