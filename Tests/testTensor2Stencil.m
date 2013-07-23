function test_suite = testTensor2Stencil

initTestSuite;

function test_ap0bp0cp0aap0bbp0
nr = 3;
nc = 3;
a = 0*ones(nr, nc);
b = 0*ones(nr, nc);
c = 0*ones(nr, nc);
alpha = 0*ones(nr, nc);
beta  = 0*ones(nr, nc);
h = 1/sqrt(2);
S =Tensor2Stencil(a,b,c,alpha,beta,'size',h);
st = [ ...
    S{1,1}(1,1) S{1,2}(1,1) S{1,3}(1,1) ; ...
    S{2,1}(1,1) S{2,2}(1,1) S{2,3}(1,1) ; ...
    S{3,1}(1,1) S{3,2}(1,1) S{3,3}(1,1) ];
assertElementsAlmostEqual(st, [0 0 0 ; 0 0 0 ; 0 0 0], ...
    'absolute', 1e-10, 1e-10);

function test_ap1bp0cp0aap0bbp0
nr = 3;
nc = 3;
a = 1*ones(nr, nc);
b = 0*ones(nr, nc);
c = 0*ones(nr, nc);
alpha = 0*ones(nr, nc);
beta  = 0*ones(nr, nc);
h = 1/sqrt(2);
S =Tensor2Stencil(a,b,c,alpha,beta,'size',h);
st = [ ...
    S{1,1}(1,1) S{1,2}(1,1) S{1,3}(1,1) ; ...
    S{2,1}(1,1) S{2,2}(1,1) S{2,3}(1,1) ; ...
    S{3,1}(1,1) S{3,2}(1,1) S{3,3}(1,1) ];
assertElementsAlmostEqual(st, [0 0 0 ; 2 -4 2 ; 0 0 0], ...
    'absolute', 1e-10, 1e-10);

function test_ap0bp1cp0aap0bbp0
nr = 3;
nc = 3;
a = 0*ones(nr, nc);
b = 1*ones(nr, nc);
c = 0*ones(nr, nc);
alpha = 0*ones(nr, nc);
beta  = 0*ones(nr, nc);
h = 1/sqrt(2);
S = Tensor2Stencil(a,b,c,alpha,beta,'size',h);
st = [ ...
    S{1,1}(1,1) S{1,2}(1,1) S{1,3}(1,1) ; ...
    S{2,1}(1,1) S{2,2}(1,1) S{2,3}(1,1) ; ...
    S{3,1}(1,1) S{3,2}(1,1) S{3,3}(1,1) ];
assertElementsAlmostEqual(st, [1 0 -1 ; 0 0 0 ; -1 0 1], ...
    'absolute', 1e-10, 1e-10);

function test_ap0bp0cp1aap0bbp0
nr = 3;
nc = 3;
a = 0*ones(nr, nc);
b = 0*ones(nr, nc);
c = 1*ones(nr, nc);
alpha = 0*ones(nr, nc);
beta  = 0*ones(nr, nc);
h = 1/sqrt(2);
S =Tensor2Stencil(a,b,c,alpha,beta,'size',h);
st = [ ...
    S{1,1}(1,1) S{1,2}(1,1) S{1,3}(1,1) ; ...
    S{2,1}(1,1) S{2,2}(1,1) S{2,3}(1,1) ; ...
    S{3,1}(1,1) S{3,2}(1,1) S{3,3}(1,1) ];
assertElementsAlmostEqual(st, [0 2 0 ; 0 -4 0 ; 0 2 0], ...
    'absolute', 1e-10, 1e-10);

function test_ap1bp1cp0aap0bbp0
nr = 3;
nc = 3;
a = 1*ones(nr, nc);
b = 1*ones(nr, nc);
c = 0*ones(nr, nc);
alpha = 0*ones(nr, nc);
beta  = 0*ones(nr, nc);
h = 1/sqrt(2);
S =Tensor2Stencil(a,b,c,alpha,beta,'size',h);
st = [ ...
    S{1,1}(1,1) S{1,2}(1,1) S{1,3}(1,1) ; ...
    S{2,1}(1,1) S{2,2}(1,1) S{2,3}(1,1) ; ...
    S{3,1}(1,1) S{3,2}(1,1) S{3,3}(1,1) ];
assertElementsAlmostEqual(st, [1 0 -1 ; 2 -4 2 ; -1 0 1], ...
    'absolute', 1e-10, 1e-10);

function test_ap1bp0cp1aap0bbp0
nr = 3;
nc = 3;
a = 1*ones(nr, nc);
b = 0*ones(nr, nc);
c = 1*ones(nr, nc);
alpha = 0*ones(nr, nc);
beta  = 0*ones(nr, nc);
h = 1/sqrt(2);
S =Tensor2Stencil(a,b,c,alpha,beta,'size',h);
st = [ ...
    S{1,1}(1,1) S{1,2}(1,1) S{1,3}(1,1) ; ...
    S{2,1}(1,1) S{2,2}(1,1) S{2,3}(1,1) ; ...
    S{3,1}(1,1) S{3,2}(1,1) S{3,3}(1,1) ];
assertElementsAlmostEqual(st, [0 2 0 ; 2 -8 2 ; 0 2 0], ...
    'absolute', 1e-10, 1e-10);

function test_ap1bp1cp1aap0bbp0
nr = 3;
nc = 3;
a = 1*ones(nr, nc);
b = 1*ones(nr, nc);
c = 1*ones(nr, nc);
alpha = 0*ones(nr, nc);
beta  = 0*ones(nr, nc);
h = 1/sqrt(2);
S =Tensor2Stencil(a,b,c,alpha,beta,'size',h);
st = [ ...
    S{1,1}(1,1) S{1,2}(1,1) S{1,3}(1,1) ; ...
    S{2,1}(1,1) S{2,2}(1,1) S{2,3}(1,1) ; ...
    S{3,1}(1,1) S{3,2}(1,1) S{3,3}(1,1) ];
assertElementsAlmostEqual(st, [1 2 -1 ; 2 -8 2 ; -1 2 1], ...
    'absolute', 1e-10, 1e-10);

function test_ap1bm1cp1aap0bpb0
nr = 3;
nc = 3;
a = 1*ones(nr, nc);
b = -1*ones(nr, nc);
c = 1*ones(nr, nc);
alpha = 0*ones(nr, nc);
beta  = 0*ones(nr, nc);
h = 1/sqrt(2);
S =Tensor2Stencil(a,b,c,alpha,beta,'size',h);
st = [ ...
    S{1,1}(1,1) S{1,2}(1,1) S{1,3}(1,1) ; ...
    S{2,1}(1,1) S{2,2}(1,1) S{2,3}(1,1) ; ...
    S{3,1}(1,1) S{3,2}(1,1) S{3,3}(1,1) ];
assertElementsAlmostEqual(st, [-1 2 1 ; 2 -8 2 ; 1 2 -1], ...
    'absolute', 1e-10, 1e-10);

function test_nr1nc1
nr = 1;
nc = 1;
a = 1*ones(nr, nc);
b = 0*ones(nr, nc);
c = 1*ones(nr, nc);
alpha = 0*ones(nr, nc);
beta  = 0*ones(nr, nc);
h = 1/sqrt(2);
S =Tensor2Stencil(a,b,c,alpha,beta,'size',h);
st = [ ...
    S{1,1}(1,1) S{1,2}(1,1) S{1,3}(1,1) ; ...
    S{2,1}(1,1) S{2,2}(1,1) S{2,3}(1,1) ; ...
    S{3,1}(1,1) S{3,2}(1,1) S{3,3}(1,1) ];
assertElementsAlmostEqual(st, [0 2 0 ; 2 -8 2 ; 0 2 0], ...
    'absolute', 1e-10, 1e-10);

function test_nrRANDncRAND
nr = randi([2,1000],1);
nc = randi([2,1000],1);
a = 1*ones(nr, nc);
b = 0*ones(nr, nc);
c = 1*ones(nr, nc);
alpha = 0*ones(nr, nc);
beta  = 0*ones(nr, nc);
h = 1/sqrt(2);
S =Tensor2Stencil(a,b,c,alpha,beta,'size',h);
st = [ ...
    S{1,1}(1,1) S{1,2}(1,1) S{1,3}(1,1) ; ...
    S{2,1}(1,1) S{2,2}(1,1) S{2,3}(1,1) ; ...
    S{3,1}(1,1) S{3,2}(1,1) S{3,3}(1,1) ];
assertElementsAlmostEqual(st, [0 2 0 ; 2 -8 2 ; 0 2 0], ...
    'absolute', 1e-10, 1e-10);