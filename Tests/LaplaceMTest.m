function tests = LaplaceMTest ()
%% Unit test for method LaplaceM
tests = functiontests (localfunctions);
end

function DivGradTest (testCase)
M = LaplaceM (3,4);
sol = GradientM (3, 4);
sol = -(sol')*sol;
verifyEqual (testCase, M, sol);
end