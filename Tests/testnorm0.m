function testnorm0
assertEqual(norm0([2 -3 4] ), 3);
assertEqual(norm0([2 -3 4]'), 3);

assertEqual(norm0([-6 2 0] ), 2);
assertEqual(norm0([-6 2 0]'), 2);

assertEqual(norm0([1e-10 0 0] ), 1);
assertEqual(norm0([1e-10 0 0]'), 1);

assertEqual(norm0([0 0 0] ), 0);
assertEqual(norm0([0 0 0]'), 0);

assertEqual(norm0([eps -eps ; 0 0]), 2);
assertEqual(norm0([0 eps ; eps 0]), 2);

assertEqual(norm0([1e100 -1e00 ; 0 -10 ; eps -eps]), 5);
end
