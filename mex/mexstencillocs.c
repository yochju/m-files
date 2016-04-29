#include "mex.h"
#include "matrix.h"

#include "f2mex.h"

void mexFunction( int nlhs,       mxArray *plhs[],
                  int nrhs, const mxArray *prhs[] 
		  )
{
  long *tmp_siz, *tmp_dims, *tmp_out;
  double *siz, *dims, *out;
  mwSize ii, nc, nr, siz_out;
    
  /* Check I/O number */
  if (nlhs > 1) {
    mexErrMsgTxt("Incorrect number of outputs");
  }
  if (nrhs!=2) {
    mexErrMsgTxt("Incorrect number of inputs");
  }
  
  nr = mxGetM(prhs[0]);  
  nc = mxGetN(prhs[0]);

  /* Get input and output pointers. */
  siz  = mxGetPr(prhs[0]);
  dims = mxGetPr(prhs[1]);

  siz_out = 1;
  for (ii=0; ii<nr*nc; ii++) {siz_out *= siz[ii];}
  
  tmp_siz  = mxCalloc(nr*nc,   sizeof(long));
  tmp_dims = mxCalloc(nr*nc,   sizeof(long));
  tmp_out  = mxCalloc(siz_out, sizeof(long));

  plhs[0] = mxCreateDoubleMatrix(siz_out, 1, mxREAL);

  out  = mxGetPr(plhs[0]);

  for (ii = 0; ii<nr*nc; ii++) {
    tmp_siz[ii] = (long) siz[ii];
    tmp_dims[ii] = (long) dims[ii];
  }

  mexstencillocs(nr*nc, siz_out, tmp_siz, tmp_dims, tmp_out);

  for (ii = 0; ii<siz_out; ii++) {
    out[ii] = tmp_out[ii];
  }

  mxFree(tmp_siz);
  mxFree(tmp_dims);
  mxFree(tmp_out);

  return;
}
