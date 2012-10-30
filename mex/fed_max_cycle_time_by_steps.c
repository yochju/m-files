#include "mex.h"

#include <math.h>
#include "libfed/fed.h"

/* mex -g -I. -I./libfed -lm fed_tau_by_steps.c libfed/fed.c */
void mexFunction(int nlhs, mxArray *plhs[], int nrhs, const mxArray *prhs[])
{    
    int   n          = (int)   mxGetScalar(prhs[0]);
    float tau_max    = (float) mxGetScalar(prhs[1]);

    double *p;
    
    plhs[0] = mxCreateNumericMatrix(1, 1, mxDOUBLE_CLASS, mxREAL);
    p = mxGetPr(plhs[0]);
    p[0] = (double) fed_max_cycle_time_by_steps(n,tau_max);
    
    return;
}
