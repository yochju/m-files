/*
 * Copyright 2013 Laurent Hoeltgen <laurent.hoeltgen@gmail.com>
 *
 * This program is free software; you can redistribute it and/or modify it under
 * the terms of the GNU General Public License as published by the Free Software
 * Foundation; either version 3 of the License, or (at your option) any later
 * version.
 *
 * This program is distributed in the hope that it will be useful, but WITHOUT
 * ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS
 * FOR A PARTICULAR PURPOSE.  See the GNU General Public License for more
 * details.
 *
 * You should have received a copy of the GNU General Public License along with
 * this program; if not, write to the Free Software Foundation, Inc., 51 Franklin
 * Street, Fifth Floor, Boston, MA 02110-1301, USA.
 */

/* Last revision on: 01.04.2013 21:30 */

#include "mex.h"
#include "matrix.h"
#include <blas.h>

#include <stdlib.h>
#include <math.h>

#include <cblas.h>
#include <suitesparse/cs.h>

#include <mexHelperBLAS.h>

/* - DGEMM ------------------------------------------------------------------ */

int mfiles_dgemm00(
              double   alpha,
        const mxArray *A,
        const mxArray *B,
              double   beta,
              mxArray *C)
{   
    size_t rA = mxGetM(A);
    size_t cA = mxGetN(A);
    size_t rB = mxGetM(B);
    size_t cB = mxGetN(B);
    size_t rC = mxGetM(C);
    size_t cC = mxGetN(C);
    
    if( mxIsSparse(A) || mxIsSparse(B) || mxIsSparse(C) ) {
        mexErrMsgIdAndTxt("mfiles:BadType",
                "Sparse matrices are not supported.");
    }
    
    if( mxIsComplex(A) || mxIsComplex(B) || mxIsComplex(C) ) {
        mexErrMsgIdAndTxt("mfiles:BadType",
                "Complex matrices are not supported.");
    }
    
    if( (cA!=rB) || (rA!=rC) || (cB!=cC) ) {
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
              double   alpha,
        const mxArray *A,
        const mxArray *B,
              double   beta,
              mxArray *C)
{   
    size_t rA = mxGetM(A);
    size_t cA = mxGetN(A);
    size_t rB = mxGetM(B);
    size_t cB = mxGetN(B);
    size_t rC = mxGetM(C);
    size_t cC = mxGetN(C);
        
    if( mxIsSparse(A) || mxIsSparse(B) || mxIsSparse(C) ) {
        mexErrMsgIdAndTxt("mfiles:BadType",
                "Sparse matrices are not supported.");
    }
    
    if( mxIsComplex(A) || mxIsComplex(B) || mxIsComplex(C) ) {
        mexErrMsgIdAndTxt("mfiles:BadType",
                "Complex matrices are not supported.");
    }
    
    if( (cA!=cB) || (rA!=rC) || (rB!=cC) ) {
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
              double   alpha,
        const mxArray *A,
        const mxArray *B,
              double   beta,
              mxArray *C)
{   
    size_t rA = mxGetM(A);
    size_t cA = mxGetN(A);
    size_t rB = mxGetM(B);
    size_t cB = mxGetN(B);
    size_t rC = mxGetM(C);
    size_t cC = mxGetN(C);
    
    if( mxIsSparse(A) || mxIsSparse(B) || mxIsSparse(C) ) {
        mexErrMsgIdAndTxt("mfiles:BadType",
                "Sparse matrices are not supported.");
    }
    
    if( mxIsComplex(A) || mxIsComplex(B) || mxIsComplex(C) ) {
        mexErrMsgIdAndTxt("mfiles:BadType",
                "Complex matrices are not supported.");
    }
    
    if( (rA!=rB) || (cA!=rC) || (cB!=cC) ) {
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
              double   alpha,
        const mxArray *A,
        const mxArray *B,
              double   beta,
              mxArray *C)
{   
    size_t rA = mxGetM(A);
    size_t cA = mxGetN(A);
    size_t rB = mxGetM(B);
    size_t cB = mxGetN(B);
    size_t rC = mxGetM(C);
    size_t cC = mxGetN(C);
    
    if( mxIsSparse(A) || mxIsSparse(B) || mxIsSparse(C) ) {
        mexErrMsgIdAndTxt("mfiles:BadType",
                "Sparse matrices are not supported.");
    }
    
    if( mxIsComplex(A) || mxIsComplex(B) || mxIsComplex(C) ) {
        mexErrMsgIdAndTxt("mfiles:BadType",
                "Complex matrices are not supported.");
    }
    
    if( (rA!=cB) || (cA!=rC) || (rB!=cC) ) {
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
              double   alpha,
        const mxArray *A,
        const mxArray *x,
              double   beta,
              mxArray *y)
{   
    size_t rA = mxGetM(A);
    size_t cA = mxGetN(A);
    size_t rx = mxGetM(x);
    size_t cx = mxGetN(x);
    size_t ry = mxGetM(y);
    size_t cy = mxGetN(y);
    
    if( mxIsSparse(x) || mxIsSparse(y) ) {
        mexErrMsgIdAndTxt("mfiles:BadType",
                "Sparse vectors are not supported.");
    }
    
    if( mxIsComplex(A) || mxIsComplex(x) || mxIsComplex(y) ) {
        mexErrMsgIdAndTxt("mfiles:BadType",
                "Complex data is not supported.");
    }
    
    if( (cA!=rx) || (rA!=ry) || (cx!=1) || (cy!=1) ) {
        mexErrMsgIdAndTxt("mfiles:BadDim",
                "Dimensions of matrices do not match.");
    }
    
    if (mxIsSparse(A)) {
        double *px = mxGetPr(x);
        double *py = mxGetPr(y);
        double *pz = mxCalloc(ry, sizeof(double));
        
        cs *cs_A = cs_calloc(1, sizeof(cs) );
        cs_A->nzmax = mxGetNzmax(A);
        cs_A->m     = rA;
        cs_A->n     = cA;
        cs_A->p     = mxGetJc(A);      /* Column count      */
        cs_A->i     = mxGetIr(A);      /* Row indexing      */
        cs_A->x     = mxGetPr(A);      /* Non-zero elements */
        cs_A->nz    = -1;
        
        /* Compute z <- A*x */
        cs_gaxpy(cs_A, px, pz);
        
        int INC = 1;
        /* Compute y <- beta y */
        dscal(&ry,&beta,py,&INC);        
        /* Compute y <- alpha*z+y */
        daxpy(&ry,&alpha,pz,&INC,py,&INC);
                
        cs_free(cs_A);
        mxFree(pz);
    }
    else {
        double *pA = mxGetPr(A);
        double *px = mxGetPr(x);
        double *py = mxGetPr(y);
        int INC = 1;
        dgemv("N", &rA, &cA, &alpha, pA, &rA, px, &INC, &beta, py, &INC);
    }
    
    return EXIT_SUCCESS;
}

/* Computes: y <- alpha A^T*x + beta y */ 
int mfiles_dgemv1(
              double   alpha,
        const mxArray *A,
        const mxArray *x,
              double   beta,
              mxArray *y)
{   
    size_t rA = mxGetM(A);
    size_t cA = mxGetN(A);
    size_t rx = mxGetM(x);
    size_t cx = mxGetN(x);
    size_t ry = mxGetM(y);
    size_t cy = mxGetN(y);
    
    if( mxIsSparse(x) || mxIsSparse(y) ) {
        mexErrMsgIdAndTxt("mfiles:BadType",
                "Sparse vectors are not supported.");
    }
    
    if( mxIsComplex(A) || mxIsComplex(x) || mxIsComplex(y) ) {
        mexErrMsgIdAndTxt("mfiles:BadType",
                "Complex data is not supported.");
    }
    
    if( (rA!=rx) || (cA!=ry) || (cx!=1) || (cy!=1) ) {
        mexErrMsgIdAndTxt("mfiles:BadDim",
                "Dimensions of matrices do not match.");
    }
    
    if (mxIsSparse(A)) {
        double *px = mxGetPr(x);
        double *py = mxGetPr(y);
        double *pz = mxCalloc(ry, sizeof(double));
        
        cs *cs_A    = cs_calloc(1, sizeof(cs) );
        cs_A->nzmax = mxGetNzmax(A);
        cs_A->m     = rA;
        cs_A->n     = cA;
        cs_A->p     = mxGetJc(A);      /* Column count      */
        cs_A->i     = mxGetIr(A);      /* Row indexing      */
        cs_A->x     = mxGetPr(A);      /* Non-zero elements */
        cs_A->nz    = -1;
        
        /* Compute z <- A^T*x */
        cs *cs_AT   = cs_transpose(cs_A, 1);
        cs_gaxpy(cs_AT, px, pz);
        
        int INC = 1;
        /* Compute y <- beta y */
        dscal(&ry,&beta,py,&INC);        
        /* Compute y <- alpha*z+y */
        daxpy(&ry,&alpha,pz,&INC,py,&INC);
        
        cs_free(cs_A);
        cs_spfree(cs_AT);
        mxFree(pz);
    }
    else {
        double *pA = mxGetPr(A);
        double *px = mxGetPr(x);
        double *py = mxGetPr(y);
        int INC = 1;
        dgemv("T", &rA, &cA, &alpha, pA, &rA, px, &INC, &beta, py, &INC);
    }
    
    return EXIT_SUCCESS;
}

/* -------------------------------------------------------------------------- */
