function test_suite = testnorm0

initTestSuite;

function test_normal
assertEqual(norm0([2 -3 4] ), 3);
assertEqual(norm0([2 -3 4]'), 3);
assertEqual(norm0([-6 2 0] ), 2);
assertEqual(norm0([-6 2 0]'), 2);
assertEqual(norm0([0 0 0] ), 0);
assertEqual(norm0([0 0 0]'), 0);

function test_small
assertEqual(norm0([1e-10 0 0] ), 1);
assertEqual(norm0([1e-10 0 0]'), 1);
assertEqual(norm0([eps -eps ; 0 0]), 2);
assertEqual(norm0([0 eps ; eps 0]), 2);

function test_large
assertEqual(norm0([1e20 0 0] ), 1);
assertEqual(norm0([1e100 0 0]'), 1);
assertEqual(norm0([1e20 -1e20 ; 0 0]), 2);
assertEqual(norm0([0 1e100 ; -1e100 0]), 2);

function test_mixed
assertEqual(norm0([1e100 -1e100 ; 0 -10 ; eps -eps]), 5);

