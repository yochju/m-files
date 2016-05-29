#include <stdint.h>

#include "mex.h"
#include "matrix.h"

#include "f2mex.h"

void mexFunction(int nlhs, mxArray *plhs[],
        int nrhs, const mxArray *prhs[]
        ) {
        int64_t *tmp_siz, *tmp_dims, *tmp_mask, *ir, *jc, sparse_siz;
        double *siz, *dims, *mask, *sten, *out_ir, *out_jc, *out_a;
        mwSize ii, nc, nr, prod_siz;

        /* Check I/O number */
        if (nlhs != 3) {
                mexErrMsgTxt("Incorrect number of outputs");
        }
        if (nrhs != 4) {
                mexErrMsgTxt("Incorrect number of inputs");
        }

        nr = mxGetM(prhs[0]);
        nc = mxGetN(prhs[0]);

        /* Get input and output pointers. */
        siz = mxGetPr(prhs[0]);
        dims = mxGetPr(prhs[1]);
        mask = mxGetPr(prhs[2]);
        sten = mxGetPr(prhs[3]);

        prod_siz = 1;
        for (ii = 0; ii < nr * nc; ii++) {
                prod_siz *= (mwSize) siz[ii];
        }

        tmp_siz = mxCalloc(nr * nc, sizeof (int64_t));
        tmp_dims = mxCalloc(nr * nc, sizeof (int64_t));
        tmp_mask = mxCalloc(prod_siz, sizeof (int64_t));

        sparse_siz = 0;
        for (ii = 0; ii < prod_siz; ii++) {
                tmp_mask[ii] = (int64_t) mask[ii];
        }

        for (ii = 0; ii < nr * nc; ii++) {
                tmp_siz[ii] = (int64_t) siz[ii];
                tmp_dims[ii] = (int64_t) dims[ii];
        }

        mexstencil2sparse_size((int64_t) nr * nc, tmp_siz, tmp_dims, tmp_mask, &sparse_siz);

        plhs[0] = mxCreateDoubleMatrix(sparse_siz, 1, mxREAL); // ir
        plhs[1] = mxCreateDoubleMatrix(sparse_siz, 1, mxREAL); // jc
        plhs[2] = mxCreateDoubleMatrix(sparse_siz, 1, mxREAL); // a

        out_ir = mxGetPr(plhs[0]);
        out_jc = mxGetPr(plhs[1]);
        out_a = mxGetPr(plhs[2]);

        ir = mxCalloc(sparse_siz, sizeof (int64_t));
        jc = mxCalloc(sparse_siz, sizeof (int64_t));

        mexconst_stencil2sparse((int64_t) (nr * nc), sparse_siz, tmp_siz, tmp_dims, tmp_mask, sten, ir, jc, out_a);

        for (ii = 0; ii < sparse_siz; ii++) {
                out_ir[ii] = (double) ir[ii];
                out_jc[ii] = (double) jc[ii];
        }

        mxFree(tmp_siz);
        mxFree(tmp_dims);
        mxFree(tmp_mask);
        mxFree(ir);
        mxFree(jc);

        return;
}
