#include "mex.h"
#include "f2mex.h"

void mexFunction( int nlhs,       mxArray *plhs[],
                  int nrhs, const mxArray *prhs[] 
		  )
{
  double *in, *out;        
  mwSize nc, nr;
    
  /* Check I/O number */
  if (nlhs > 1) {
    mexErrMsgTxt("Incorrect number of outputs");
  }
  if (nrhs!=1) {
    mexErrMsgTxt("Incorrect number of inputs");
  }
    
  /* Brief error checking */

  nr = mxGetM(prhs[0]);  
  nc = mxGetN(prhs[0]);
    
  /* Allocate output */
  plhs[0] = mxCreateDoubleMatrix(nr, nc, mxREAL);

  /* Get input and output pointers. */
  in  = mxGetPr(prhs[0]);
  out = mxGetPr(plhs[0]);

  mexcumsum(nr*nc, in, out);
  
  return;
}
