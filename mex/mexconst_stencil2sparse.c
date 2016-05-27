#include <stdint.h>

#include "mex.h"
#include "matrix.h"

#include "f2mex.h"

void mexFunction (int nlhs, mxArray *plhs[],
                  int nrhs, const mxArray *prhs[]
) {
        int64_t *tmp_siz, *tmp_dims, *tmp_mask, *tmp_out, *ir, *jc;
	double *siz, *dims, *mask, *out_ir, *out_jc, *out_a;
	mwSize ii, nc, nr, siz_out;

	/* Check I/O number */
	if (nlhs != 3) {
		mexErrMsgTxt ("Incorrect number of outputs");
	}
	if (nrhs != 3) {
		mexErrMsgTxt ("Incorrect number of inputs");
	}

	nr = mxGetM (prhs[0]);
	nc = mxGetN (prhs[0]);

	/* Get input and output pointers. */
	siz  = mxGetPr (prhs[0]);
	dims = mxGetPr (prhs[1]);
	mask = mxGetPr (prhs[2]);
	
	siz_out = 1;
	for (ii = 0; ii < nr * nc; ii++) { siz_out *= (mwSize) siz[ii]; }

	tmp_siz  = mxCalloc (nr * nc, sizeof (int64_t)); // Fix sizes here ?
	tmp_dims = mxCalloc (nr * nc, sizeof (int64_t));
	tmp_out  = mxCalloc (siz_out, sizeof (int64_t));

	plhs[0] = mxCreateDoubleMatrix (siz_out, 1, mxREAL); // Fix sizes here!
	plhs[1] = mxCreateDoubleMatrix (siz_out, 1, mxREAL);
	plhs[2] = mxCreateDoubleMatrix (siz_out, 1, mxREAL);

	out_ir = mxGetPr (plhs[0]);
	out_jc = mxGetPr (plhs[1]);
	out_a  = mxGetPr (plhs[2]);

	for (ii = 0; ii < nr * nc; ii++) {
		tmp_siz[ii]  = (int64_t) siz[ii];
		tmp_dims[ii] = (int64_t) dims[ii];
		tmp_mask[ii] = (int64_t) mask[ii];
	}

	mexconst_stencil2sparse((int64_t) nr * nc, tmp_siz, tmp_dims, tmp_mask, tmp_sten, ir, jc, out_a);

	for (ii = 0; ii < siz_out; ii++) {
		out_ir[ii] = (double) ir[ii];
		out_jc[ii] = (double) jc[ii];
	}

	mxFree (tmp_siz);
	mxFree (tmp_dims);
	mxFree (tmp_mask);
	mxFree (tmp_out);
	mxFree (ir);
	mxFree (jc);
	
	return;
}
