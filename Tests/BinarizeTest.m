function tests = BinarizeTest ()
%% Unit test for method Binarize
tests = functiontests (localfunctions);
end

function Bin1Test (testcase)
v = 0:6;
w = Binarize(v, 3, 'min', -1, 'max', 10);
verifyEqual(testcase, [-1, -1, -1, -1, 10, 10, 10], w);
end

function Bin2Test (testcase)
v = 0:6;
w = Binarize(v, 3, 'min', 1, 'max', nan);
verifyEqual(testcase, [1, 1, 1, 1, 4, 5, 6], w);
end

function Bin3Test (testcase)
v = 0:6;
w = Binarize(v, 3, 'min', nan, 'max', 0);
verifyEqual(testcase, [0, 1, 2, 3, 0, 0, 0], w);
end

function Bin4Test (testcase)
v = reshape(1:6, [2, 3]);
w = Binarize(v, 3, 'min', -1, 'max', 10);
verifyEqual(testcase, reshape([-1, -1, -1, 10, 10, 10], [2, 3]), w);
end

function Bin5Test (testcase)
v = reshape(1:6, [2, 3]);
w = Binarize(v, 3, 'min', 1, 'max', nan);
verifyEqual(testcase, reshape([1, 1, 1, 4, 5, 6], [2, 3]), w);
end

function Bin6Test (testcase)
v = reshape(1:6, [2, 3]);
w = Binarize(v, 3, 'min', nan, 'max', 0);
verifyEqual(testcase, reshape([1, 2, 3, 0, 0, 0], [2, 3]), w);
end