#include "mex.h"

#include <math.h>
#include "libfed/fed.h"

/* mex -g -I. -I./libfed -lm fed_tau_by_steps.c libfed/fed.c*/
void mexFunction(int nlhs, mxArray *plhs[], int nrhs, const mxArray *prhs[])
{    
    float T          = (float) mxGetScalar(prhs[0]);
    int   M          = (int)   mxGetScalar(prhs[1]);
    float tau_max    = (float) mxGetScalar(prhs[2]);
    int   reordering = (int)   mxGetScalar(prhs[3]);
    
    double *p;
    float *tau = NULL;
    
    int n = fed_tau_by_process_time(T, M, tau_max, reordering, &tau);
    plhs[0] = mxCreateNumericMatrix(1, n, mxDOUBLE_CLASS, mxREAL);
    p = mxGetPr(plhs[0]);
    int ii;
    for(ii = 0; ii<n; ii++){
        p[ii] = (double) tau[ii];
    }
    
    return;
}
