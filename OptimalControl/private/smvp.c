#include "mex.h"

void mexFunction( int nlhs,       mxArray *plhs[],
                  int nrhs, const mxArray *prhs[] 
                 )
                
{   /* Sparse matrix-dense vector product 
     *       
     *  Inputs:
     *           
     *           A - m x n sparse matrix
     *           b - n x 1 dense vector
     *           
     *  Outputs:
     *   
     *           x = A*b
     *
     *  Darren Engwirda 2006.       
     */

    double *s, *b, *x;           
    int *ir, *jc, i, ncol, k;                          
    
    /* Check I/O number */
    if (nlhs!=1) {
        mexErrMsgTxt("Incorrect number of outputs");
    }
    if (nrhs!=2) {
        mexErrMsgTxt("Incorrect number of inputs");
    }
    
    /* Brief error checking */
    
    ncol = mxGetN(prhs[0]);
    
    if ((ncol!=mxGetM(prhs[1])) || (mxGetN(prhs[1])!=1)) {
        mexErrMsgTxt("Wrong input dimensions");
    }
    if (!mxIsSparse(prhs[0])) {
        mexErrMsgTxt("Matrix must be sparse");
    }
    
    
    /* Allocate output */
    plhs[0] = mxCreateDoubleMatrix(mxGetM(prhs[0]), 1, mxREAL);
    
    /* I/O pointers */
    ir = mxGetIr(prhs[0]);      /* Row indexing      */
    jc = mxGetJc(prhs[0]);      /* Column count      */
    s  = mxGetPr(prhs[0]);      /* Non-zero elements */
    b  = mxGetPr(prhs[1]);      /* Rhs vector        */
    x  = mxGetPr(plhs[0]);      /* Output vector     */
    
    
    /* Multiplication */
    
    for (i=0; i<ncol; i++) {            /* Loop through columns */
     
        int stop = jc[i+1];
        double rhs = b[i];
        
        for (k=jc[i]; k<stop; k++) {    /* Loop through non-zeros in ith column */
        
            x[ir[k]] += s[k] * rhs;
        }
    }
    
    /* End */
}
