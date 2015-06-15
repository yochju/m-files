function tests = ThresholdTest ()
%% Unit test for method Binarize
tests = functiontests (localfunctions);
end

function Th1Test (testcase)
v = 0:6;
w = Threshold(v, 3);
verifyEqual(testcase, [0, 0, 0, 0, 1, 1, 1], w);
end

function Th2Test (testcase)
v = 0:6;
[w, p] = Threshold(v, 3);
verifyEqual(testcase, [0, 0, 0, 0, 1, 1, 1], w);
verifyEqual(testcase, [5, 6, 7], p);
end

function Th3Test (testcase)
v = 0:6;
[w, p, y] = Threshold(v, 3);
verifyEqual(testcase, [0, 0, 0, 0, 1, 1, 1], w);
verifyEqual(testcase, [5, 6, 7], p);
verifyEqual(testcase, [4, 5, 6], y);
end

function Th4Test (testcase)
v = reshape(1:6, [2, 3]);
w = Threshold(v, 3);
verifyEqual(testcase, reshape([0, 0, 0, 1, 1, 1], [2, 3]), w);
end

function Th5Test (testcase)
v = reshape(1:6, [2, 3]);
[w, p] = Threshold(v, 3);
verifyEqual(testcase, reshape([0, 0, 0, 1, 1, 1], [2, 3]), w);
verifyEqual(testcase, [4; 5; 6], p);
end

function Th6Test (testcase)
v = reshape(1:6, [2, 3]);
[w, p, y] = Threshold(v, 3);
verifyEqual(testcase, reshape([0, 0, 0, 1, 1, 1], [2, 3]), w);
verifyEqual(testcase, [4; 5; 6], p);
verifyEqual(testcase, [4; 5; 6], y);
end