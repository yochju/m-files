#include <math.h>
#include <stdint.h>

#include "mex.h"
#include "matrix.h"

#include "f2mex.h"

void mexFunction( int nlhs,       mxArray *plhs[],
                  int nrhs, const mxArray *prhs[] 
		  )
{
  int64_t *tmp_out;
  double dims, *out;
  mwSize ii, siz_out;
    
  /* Check I/O number */
  if (nlhs > 1) {
    mexErrMsgTxt("Incorrect number of outputs");
  }
  if (nrhs != 1) {
    mexErrMsgTxt("Incorrect number of inputs");
  }

  dims = mxGetScalar(prhs[0]);
  
  siz_out = (mwSize) pow(3.0, dims);

  tmp_out  = mxCalloc(siz_out, sizeof(int64_t));

  plhs[0] = mxCreateDoubleMatrix(siz_out, 1, mxREAL);

  out  = mxGetPr(plhs[0]);

  mexcreate_5p_stencil((int64_t) dims, tmp_out);

  for (ii = 0; ii<siz_out; ii++) {
    out[ii] = (double) tmp_out[ii];
  }

  mxFree(tmp_out);

  return;
}
