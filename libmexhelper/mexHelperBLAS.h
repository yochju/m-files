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

/* 
 * Notice:
 * The functions herein are wrappers around BLAS and CXSparse implementations to
 * easen the usage of common operations related to matrices and vectors. These
 * functions take care of the different handling of full and sparse matrices.
 * For full matrices the BLAS implementation provided by Matlab itself is being
 * used. Sparse matrices require a CXSparse implementation to be installed on
 * the system. CXSparse can be found here:
 *
 * http://www.cise.ufl.edu/research/sparse/CXSparse/
 *
 * Documentation is available under:
 *
 * http://www.cise.ufl.edu/research/sparse/CSparse/
 *
 * The original BLAS implementation can be found here:
 *
 * http://www.netlib.org/blas/
 *
 * Note that the Matlab interface to BLAS functions does not follow the official
 * specification.
 */

/*
 * Mex files are compiled with:
 * mex -v -largeArrayDims matmult.c -lmwblas -lm -lcxsparse -lmexHelperBLAS
 */

#ifndef mexHelperBLAS_H
#define	mexHelperBLAS_H
#include <cs.h>
#include <mex.h>

#ifdef	__cplusplus
extern "C" {
#endif

int mfiles_cs2mx(const cs *in, mxArray *out);
int mfiles_mx2cs(const mxArray *in, cs *out);

/* Computes: diag(x)*y */
int mfiles_dxdoty( const mxArray *x, mxArray *y );
 
/* Computes: alpha A*B + beta C */
int mfiles_dgemm00(
              double   alpha,
        const mxArray *A,
        const mxArray *B,
              double   beta,
              mxArray *C);

/* Computes: alpha A*B^T + beta C */
int mfiles_dgemm01(
              double   alpha,
        const mxArray *A,
        const mxArray *B,
              double   beta,
              mxArray *C);

/* Computes: alpha A^T*B + beta C */
int mfiles_dgemm10(
              double   alpha,
        const mxArray *A,
        const mxArray *B,
              double   beta,
              mxArray *C);

/* Computes: alpha A^T*B^T + beta C */
int mfiles_dgemm11(
              double   alpha,
        const mxArray *A,
        const mxArray *B,
              double   beta,
              mxArray *C);

/* Computes: y <- alpha A*x + beta y */ 
int mfiles_dgemv0(
              double   alpha,
        const mxArray *A,
        const mxArray *x,
              double   beta,
              mxArray *y);

/* Computes: y <- alpha A^T*x + beta y */ 
int mfiles_dgemv1(
              double   alpha,
        const mxArray *A,
        const mxArray *x,
              double   beta,
              mxArray *y);

#ifdef	__cplusplus
}
#endif

#endif	/* mexHelperBLAS_H */
