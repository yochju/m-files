#include <stdint.h>

#include "mex.h"
#include "matrix.h"

#include "f2mex.h"

void mexFunction (int nlhs, mxArray *plhs[],
                  int nrhs, const mxArray *prhs[]
) {
        int64_t *tmp_siz, *tmp_dims, *tmp_mask, tmp_out;
	double *siz, *dims, *mask, *out;
	double pos;
	mwSize ii, nc, nr, siz_prod;

	/* Check I/O number */
	if (nlhs > 1) {
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

	siz_prod = 1;
	for (ii = 0; ii < nr * nc; ii++) { siz_prod *= (mwSize) siz[ii]; }

	tmp_siz  = mxCalloc (nr * nc, sizeof (int64_t));
	tmp_dims = mxCalloc (nr * nc, sizeof (int64_t));
	tmp_mask = mxCalloc (siz_prod, sizeof (int64_t));

	for (ii = 0; ii < nr * nc; ii++) {
		tmp_siz[ii]  = (int64_t) siz[ii];
		tmp_dims[ii] = (int64_t) dims[ii];
	}

	for (ii = 0; ii < siz_prod; ii++) {
	  tmp_mask[ii] = (int64_t) mask[ii];
	}

	mexstencil2sparse_size ((int64_t) nr * nc, tmp_siz, tmp_dims, tmp_mask, &tmp_out);

	plhs[0] = mxCreateDoubleScalar ((double) tmp_out);
	
	mxFree (tmp_siz);
	mxFree (tmp_dims);
	mxFree (tmp_mask);

	return;
}
