#include "mex.h"

#include <math.h>
#include "libfed/fed.h"

/* mex -g -I. -I./libfed -lm fed_tau_by_steps.c libfed/fed.c */
void mexFunction(int nlhs, mxArray *plhs[], int nrhs, const mxArray *prhs[])
{    
    int   n          = (int)   mxGetScalar(prhs[0]);
    int   M          = (int)   mxGetScalar(prhs[1]);
    float tau_max    = (float) mxGetScalar(prhs[2]);

    double *p;
    
    plhs[0] = mxCreateNumericMatrix(1, 1, mxDOUBLE_CLASS, mxREAL);
    p = mxGetPr(plhs[0]);
    p[0] = (double) fed_max_process_time_by_steps(n,M,tau_max);
    
    return;
}
