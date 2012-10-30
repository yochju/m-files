#include "mex.h"

#include <math.h>
#include "libfed/fed.h"

// mex -g -I. -I./libfed -lm fed_tau_by_steps.c libfed/fed.c
void mexFunction(int nlhs, mxArray *plhs[], int nrhs, const mxArray *prhs[])
{    
    int   n          = (int)   mxGetScalar(prhs[0]);
    float tau_max    = (float) mxGetScalar(prhs[1]);
    int   reordering = (int)   mxGetScalar(prhs[2]);
    
    double *p;
    float *tau = NULL;
    
    plhs[0] = mxCreateNumericMatrix(1, n, mxDOUBLE_CLASS, mxREAL);
    p = mxGetPr(plhs[0]);
    
    int nn = fed_tau_by_steps(n, tau_max, reordering, &tau);
    int ii;
    for(ii = 0; ii<nn; ii++){
        p[ii] = (double) tau[ii];
    }
    
    return;
}
