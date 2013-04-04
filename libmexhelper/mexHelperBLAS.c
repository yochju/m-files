/*
 * Copyright 2013 Laurent Hoeltgen <laurent.hoeltgen@gmail.com>
 *
 * This program is free software; you can redistribute it and/or modify it under
 * the terms of the GNU Lesser General Public License as published by the Free
 * Software Foundation; either version 3 of the License, or (at your option) any
 * later version.
 *
 * This program is distributed in the hope that it will be useful, but WITHOUT
 * ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS
 * FOR A PARTICULAR PURPOSE.  See the GNU General Public License for more
 * details.
 *
 * You should have received a copy of the GNU Lesser General Public License
 * along with this program; if not, write to the Free Software Foundation, Inc.,
 * 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301, USA.
 */

/* Last revision on: 01.04.2013 21:30 */

#include <mex.h>
#include <matrix.h>
#include <blas.h>

#include <stdlib.h>
#include <stddef.h>
#include <math.h>

#include <cblas.h>
#include <suitesparse/cs.h>

#include <mexHelperBLAS.h>

/* - MISC --------------------------------------------------------------------*/


int mfiles_cs2mx(const cs *in, mxArray *out) {
    mxSetM(out, in->m);
    mxSetN(out, in->n);
    mxSetNzmax(out, in->nzmax);
    mxSetJc(out, (mwIndex *) in->p);
    mxSetIr(out, (mwIndex *) in->i);
    mxSetPr(out, in->x);
    return EXIT_SUCCESS;
}


int mfiles_mx2cs(const mxArray *in, cs *out) {
    out->m = mxGetM(in);
    out->n = mxGetN(in);
    out->nzmax = mxGetNzmax(in);
    out->nz = -1;
    out->p = (int *) mxGetJc(in);
    out->i = (int *) mxGetIr(in);
    out->x = (double *) mxGetPr(in);
    return EXIT_SUCCESS;
}

/* - DXPDOTY ---------------------------------------------------------------- */

int mfiles_dxdoty(const mxArray *x, mxArray *y) {
    ptrdiff_t rx = mxGetM(x);
    ptrdiff_t cx = mxGetN(x);
    ptrdiff_t ry = mxGetM(y);
    ptrdiff_t cy = mxGetN(y);

    if ((rx != ry) || (cx != 1) || (cy != 1)) {
        mexErrMsgIdAndTxt("mfiles:BadDim",
                          "Dimensions of matrices do not match.");
    }

    double *pA = mxGetPr(x);
    double *pB = mxGetPr(y);
    mwIndex i;
    /* BLAS: dtbmv */
    for (i = 0; i < rx; i++) {
        pB[i] *= pA[i];
    }
    return EXIT_SUCCESS;
}

/* - DGEMM ------------------------------------------------------------------ */

int mfiles_dgemm00(
                   double alpha,
                   const mxArray *A,
                   const mxArray *B,
                   double beta,
                   mxArray *C) {
    ptrdiff_t rA = mxGetM(A);
    ptrdiff_t cA = mxGetN(A);
    ptrdiff_t rB = mxGetM(B);
    ptrdiff_t cB = mxGetN(B);
    ptrdiff_t rC = mxGetM(C);
    ptrdiff_t cC = mxGetN(C);

    if (mxIsSparse(A) || mxIsSparse(B) || mxIsSparse(C)) {
        mexErrMsgIdAndTxt("mfiles:BadType",
                          "Sparse matrices are not supported.");
    }

    if (mxIsComplex(A) || mxIsComplex(B) || mxIsComplex(C)) {
        mexErrMsgIdAndTxt("mfiles:BadType",
                          "Complex matrices are not supported.");
    }

    if ((cA != rB) || (rA != rC) || (cB != cC)) {
        mexErrMsgIdAndTxt("mfiles:BadDim",
                          "Dimensions of matrices do not match.");
    }

    double *pA = mxGetPr(A);
    double *pB = mxGetPr(B);
    double *pC = mxGetPr(C);
    dgemm("N", "N", &rC, &cC, &cA, &alpha, pA, &rC, pB, &cA, &beta, pC, &rC);
    return EXIT_SUCCESS;
}

int mfiles_dgemm01(
                   double alpha,
                   const mxArray *A,
                   const mxArray *B,
                   double beta,
                   mxArray *C) {
    ptrdiff_t rA = mxGetM(A);
    ptrdiff_t cA = mxGetN(A);
    ptrdiff_t rB = mxGetM(B);
    ptrdiff_t cB = mxGetN(B);
    ptrdiff_t rC = mxGetM(C);
    ptrdiff_t cC = mxGetN(C);

    if (mxIsSparse(A) || mxIsSparse(B) || mxIsSparse(C)) {
        mexErrMsgIdAndTxt("mfiles:BadType",
                          "Sparse matrices are not supported.");
    }

    if (mxIsComplex(A) || mxIsComplex(B) || mxIsComplex(C)) {
        mexErrMsgIdAndTxt("mfiles:BadType",
                          "Complex matrices are not supported.");
    }

    if ((cA != cB) || (rA != rC) || (rB != cC)) {
        mexErrMsgIdAndTxt("mfiles:BadDim",
                          "Dimensions of matrices do not match.");
    }

    double *pA = mxGetPr(A);
    double *pB = mxGetPr(B);
    double *pC = mxGetPr(C);
    dgemm("N", "T", &rC, &cC, &cA, &alpha, pA, &rC, pB, &cA, &beta, pC, &rC);
    return EXIT_SUCCESS;
}

int mfiles_dgemm10(
                   double alpha,
                   const mxArray *A,
                   const mxArray *B,
                   double beta,
                   mxArray *C) {
    ptrdiff_t rA = mxGetM(A);
    ptrdiff_t cA = mxGetN(A);
    ptrdiff_t rB = mxGetM(B);
    ptrdiff_t cB = mxGetN(B);
    ptrdiff_t rC = mxGetM(C);
    ptrdiff_t cC = mxGetN(C);

    if (mxIsSparse(A) || mxIsSparse(B) || mxIsSparse(C)) {
        mexErrMsgIdAndTxt("mfiles:BadType",
                          "Sparse matrices are not supported.");
    }

    if (mxIsComplex(A) || mxIsComplex(B) || mxIsComplex(C)) {
        mexErrMsgIdAndTxt("mfiles:BadType",
                          "Complex matrices are not supported.");
    }

    if ((rA != rB) || (cA != rC) || (cB != cC)) {
        mexErrMsgIdAndTxt("mfiles:BadDim",
                          "Dimensions of matrices do not match.");
    }

    double *pA = mxGetPr(A);
    double *pB = mxGetPr(B);
    double *pC = mxGetPr(C);
    dgemm("T", "N", &rC, &cC, &cA, &alpha, pA, &rC, pB, &cA, &beta, pC, &rC);
    return EXIT_SUCCESS;
}

int mfiles_dgemm11(
                   double alpha,
                   const mxArray *A,
                   const mxArray *B,
                   double beta,
                   mxArray *C) {
    ptrdiff_t rA = mxGetM(A);
    ptrdiff_t cA = mxGetN(A);
    ptrdiff_t rB = mxGetM(B);
    ptrdiff_t cB = mxGetN(B);
    ptrdiff_t rC = mxGetM(C);
    ptrdiff_t cC = mxGetN(C);

    if (mxIsSparse(A) || mxIsSparse(B) || mxIsSparse(C)) {
        mexErrMsgIdAndTxt("mfiles:BadType",
                          "Sparse matrices are not supported.");
    }

    if (mxIsComplex(A) || mxIsComplex(B) || mxIsComplex(C)) {
        mexErrMsgIdAndTxt("mfiles:BadType",
                          "Complex matrices are not supported.");
    }

    if ((rA != cB) || (cA != rC) || (rB != cC)) {
        mexErrMsgIdAndTxt("mfiles:BadDim",
                          "Dimensions of matrices do not match.");
    }

    double *pA = mxGetPr(A);
    double *pB = mxGetPr(B);
    double *pC = mxGetPr(C);
    dgemm("T", "T", &rC, &cC, &cA, &alpha, pA, &rC, pB, &cA, &beta, pC, &rC);
    return EXIT_SUCCESS;
}

/* - DGEMV ------------------------------------------------------------------ */

/* Computes: y <- alpha A*x + beta y */
int mfiles_dgemv0(
                  double alpha,
                  const mxArray *A,
                  const mxArray *x,
                  double beta,
                  mxArray *y) {
    ptrdiff_t rA = mxGetM(A);
    ptrdiff_t cA = mxGetN(A);
    ptrdiff_t rx = mxGetM(x);
    ptrdiff_t cx = mxGetN(x);
    ptrdiff_t ry = mxGetM(y);
    ptrdiff_t cy = mxGetN(y);

    if (mxIsSparse(x) || mxIsSparse(y)) {
        mexErrMsgIdAndTxt("mfiles:BadType",
                          "Sparse vectors are not supported.");
    }

    if (mxIsComplex(A) || mxIsComplex(x) || mxIsComplex(y)) {
        mexErrMsgIdAndTxt("mfiles:BadType",
                          "Complex data is not supported.");
    }

    if ((cA != rx) || (rA != ry) || (cx != 1) || (cy != 1)) {
        mexErrMsgIdAndTxt("mfiles:BadDim",
                          "Dimensions of matrices do not match.");
    }

    if (mxIsSparse(A)) {
        double *px = mxGetPr(x);
        double *py = mxGetPr(y);
        double *pz = mxCalloc(ry, sizeof (double));

        cs *cs_A = cs_calloc(1, sizeof (cs));
        mfiles_mx2cs(A, cs_A);

        /* Compute z <- A*x */
        cs_gaxpy(cs_A, px, pz);

        /* Compute y <- beta y */
        cblas_dscal(ry, beta, py, 1);
        /* Compute y <- alpha*z+y */
        cblas_daxpy(ry, alpha, pz, 1, py, 1);

        cs_free(cs_A);
        mxFree(pz);
    } else {
        double *pA = mxGetPr(A);
        double *px = mxGetPr(x);
        double *py = mxGetPr(y);
        cblas_dgemv(CblasRowMajor, CblasNoTrans,
                    rA, cA, alpha, pA, rA, px, 1, beta, py, 1);
    }

    return EXIT_SUCCESS;
}

/* Computes: y <- alpha A^T*x + beta y */
int mfiles_dgemv1(double alpha, const mxArray *A, const mxArray *x,
                  double beta, mxArray *y) {
    size_t rA = mxGetM(A);
    size_t cA = mxGetN(A);
    size_t rx = mxGetM(x);
    size_t cx = mxGetN(x);
    size_t ry = mxGetM(y);
    size_t cy = mxGetN(y);

    if (mxIsSparse(x) || mxIsSparse(y)) {
        mexErrMsgIdAndTxt("mfiles:BadType",
                          "Sparse vectors are not supported.");
    }

    if (mxIsComplex(A) || mxIsComplex(x) || mxIsComplex(y)) {
        mexErrMsgIdAndTxt("mfiles:BadType",
                          "Complex data is not supported.");
    }

    if ((rA != rx) || (cA != ry) || (cx != 1) || (cy != 1)) {
        mexErrMsgIdAndTxt("mfiles:BadDim",
                          "Dimensions of matrices do not match.");
    }

    if (mxIsSparse(A)) {
        double *px = mxGetPr(x);
        double *py = mxGetPr(y);
        double *pz = mxCalloc(ry, sizeof (double));

        cs *cs_A = cs_calloc(1, sizeof (cs));
        mfiles_mx2cs(A, cs_A);

        /* Transpose A */
        cs *cs_AT = cs_transpose(cs_A, 1);
        /* Compute z <- A^T*x */
        cs_gaxpy(cs_AT, px, pz);

        /* Compute y <- beta y */
        cblas_dscal(ry, beta, py, 1);
        /* Compute y <- alpha*z+y */
        cblas_daxpy(ry, alpha, pz, 1, py, 1);

        cs_free(cs_A); /* Check this cs_free and cs_spfree ? */
        cs_spfree(cs_AT);
        mxFree(pz);
    } else {
        double *pA = mxGetPr(A);
        double *px = mxGetPr(x);
        double *py = mxGetPr(y);
        cblas_dgemv(CblasRowMajor, CblasTrans,
                    rA, cA, alpha, pA, rA, px, 1, beta, py, 1);

    }

    return EXIT_SUCCESS;
}

/* -------------------------------------------------------------------------- */
