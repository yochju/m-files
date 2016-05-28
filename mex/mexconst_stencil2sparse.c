#include <stdint.h>

#include "mex.h"
#include "matrix.h"

#include "f2mex.h"

void mexFunction (int nlhs, mxArray *plhs[],
                  int nrhs, const mxArray *prhs[]
) {
        int64_t *tmp_siz, *tmp_dims, *tmp_mask, *tmp_out, *ir, *jc;
	double *siz, *dims, *mask, *sten, *out_ir, *out_jc, *out_a;
	mwSize ii, nc, nr, siz_out, count_mask;

	/* Check I/O number */
	if (nlhs != 3) {
		mexErrMsgTxt ("Incorrect number of outputs");
	}
	if (nrhs != 4) {
		mexErrMsgTxt ("Incorrect number of inputs");
	}

	nr = mxGetM (prhs[0]);
	nc = mxGetN (prhs[0]);

	mexPrintf("nr, nc: %ld - %ld\n", nr, nc);
	
	/* Get input and output pointers. */
	siz  = mxGetPr (prhs[0]);
	dims = mxGetPr (prhs[1]);
	mask = mxGetPr (prhs[2]);
	sten = mxGetPr (prhs[3]);
	
	siz_out = 1;
	for (ii = 0; ii < nr * nc; ii++) { siz_out *= (mwSize) siz[ii]; }

	mexPrintf("Siz_out: %ld\n", siz_out);

	tmp_siz  = mxCalloc (nr * nc, sizeof (int64_t));
	tmp_dims = mxCalloc (nr * nc, sizeof (int64_t));
	tmp_mask = mxCalloc (siz_out, sizeof (int64_t));

	count_mask = 0;
	for (ii = 0; ii < siz_out; ii++) {
	  tmp_mask[ii] = (int64_t) mask[ii];
	  if (mask[ii] > 0) { count_mask++; }
	}

	mexPrintf("count_mask: %ld\n", count_mask);
	
	plhs[0] = mxCreateDoubleMatrix (count_mask*siz_out, 1, mxREAL); // ir
	plhs[1] = mxCreateDoubleMatrix (count_mask*siz_out, 1, mxREAL); // jc
	plhs[2] = mxCreateDoubleMatrix (count_mask*siz_out, 1, mxREAL); // a

	out_ir = mxGetPr (plhs[0]);
	out_jc = mxGetPr (plhs[1]);
	out_a  = mxGetPr (plhs[2]);

	for (ii = 0; ii < nr * nc; ii++) {
	 	tmp_siz[ii]  = (int64_t) siz[ii];
	 	tmp_dims[ii] = (int64_t) dims[ii];
	}

	ir = mxCalloc (count_mask*siz_out, sizeof (int64_t));
	jc = mxCalloc (count_mask*siz_out, sizeof (int64_t));

	mexconst_stencil2sparse((int64_t) (nr * nc), (int64_t) (count_mask * siz_out), tmp_siz, tmp_dims, tmp_mask, sten, ir, jc, out_a);

	for (ii = 0; ii < count_mask*siz_out; ii++) {
		out_ir[ii] = (double) ir[ii];
		out_jc[ii] = (double) jc[ii];
	}

	mxFree (tmp_siz);
	mxFree (tmp_dims);
	mxFree (tmp_mask);
	mxFree (ir);
	mxFree (jc);
	
	return;
}
