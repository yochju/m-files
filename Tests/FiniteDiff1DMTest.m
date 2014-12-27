function tests = FiniteDiff1DMTest ()
%% Unit test for method FiniteDiff1DM
tests = functiontests (localfunctions);
end

function DirichletTest (testCase)
[M, cons] = FiniteDiff1DM( 3, [-1, 0, 1], 2, 'GridSize', 1.0, 'Boundary', 'Dirichlet');
sol = sparse([-2, 1, 0; 1, -2, 1; 0, 1, -2]);
verifyEqual (testCase, M, sol);
verifyEqual (testCase, cons, 2);

[M, cons] = FiniteDiff1DM( 3, [-1, 0, 1], 2, 'GridSize', 0.5, 'Boundary', 'Dirichlet');
sol = sparse(4*[-2, 1, 0; 1, -2, 1; 0, 1, -2]);
verifyEqual (testCase, M, sol);
verifyEqual (testCase, cons, 2);

[M, cons] = FiniteDiff1DM( 3, [0 1], 1, 'GridSize', 1.0, 'Boundary', 'Dirichlet');
sol = sparse([-1, 1, 0; 0, -1, 1; 0, 0, -1]);
verifyEqual (testCase, M, sol);
verifyEqual (testCase, cons, 1);
end

function NeumannTest (testCase)
[M, cons] = FiniteDiff1DM( 3, [-1, 0, 1], 2, 'GridSize', 1.0, 'Boundary', 'Neumann');
sol = sparse([-1, 1, 0; 1, -2, 1; 0, 1, -1]);
verifyEqual (testCase, M, sol);
verifyEqual (testCase, cons, 2);

[M, cons] = FiniteDiff1DM( 3, [-1, 0, 1], 2, 'GridSize', 0.5, 'Boundary', 'Neumann');
sol = sparse(4*[-1, 1, 0; 1, -2, 1; 0, 1, -1]);
verifyEqual (testCase, M, sol);
verifyEqual (testCase, cons, 2);

[M, cons] = FiniteDiff1DM( 3, [0 1], 1, 'GridSize', 1.0, 'Boundary', 'Neumann');
sol = sparse([-1, 1, 0; 0, -1, 1; 0, 0, 0]);
verifyEqual (testCase, M, sol);
verifyEqual (testCase, cons, 1);
end