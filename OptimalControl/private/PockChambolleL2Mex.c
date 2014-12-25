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
 * this program; if not, write to the Free Software Foundation, Inc., 51
 * Franklin Street, Fifth Floor, Boston, MA 02110-1301, USA.
 */

#include <math.h>
#include <stdlib.h>
#include "mex.h"
#include "matrix.h"

double sgn(double x)
{
    if (x>0) { return 1.0; }
    else { return -1.0; }
    return 0.0;
}

double max0(double x)
{
    if (x > 0.0) { return x; }
    else { return 0.0; }
}

void smvp(
        mwIndex *ir,
        mwIndex *jc,
        double *s,
        double *b,
        double *x,
        mwSize ncol)
{
    int i, k;
    for (i=0; i<ncol; i++) {
        int stop = jc[i+1];
        double rhs = b[i];
        for (k=jc[i]; k<stop; k++) {
            x[ir[k]] += s[k] * rhs;
        }
    }
    return;
}

/* compile with -largeArrayDims flag */

/* Signature:
 * [u c j du dc] = PC(f,cbar,A,A',B,g,eps,mu,lambda,L,tol,gamma)
 */

void mexFunction(
        int nlhs,       mxArray *plhs[],
        int nrhs, const mxArray *prhs[]
        )
{
    /*
     * f      = signal.
     * cb     = cbar (old mask).
     * A      = inpainting mask.
     * At     = transpose of inpainting mask.
     * b      = diagonal entries of the matrix B.
     * g      = RHS of my linearisation.
     * eps    = epsilon from energy (regularisation term).
     * mu     = mu from energy (proximal term).
     * lambda = lambda from energy (sparsity term).
     * gamma  = factor for convergence acceleration. (not implemented)
     */
    
    double *f, *cb, *A, *At, *b, *g;
    double eps, mu, lambda, L, tol, gamma;
    
    mwIndex *Air, *Ajc, *Atir, *Atjc;
    
    /* Get size of matrix A. */
    mwSize Anrow  = mxGetM(prhs[2]);
    mwSize Ancol  = mxGetN(prhs[2]);
    
    /* Get size of matrix A'. */
    mwSize Atnrow = mxGetM(prhs[3]);
    mwSize Atncol = mxGetN(prhs[3]);
    
    /* Note that the Matrix A is square. The above dimensions should all be the
     * same.
     */
    
    /* Get input data. */
    f      = mxGetPr(prhs[0]);
    cb     = mxGetPr(prhs[1]);
    
    A      = mxGetPr(prhs[2]);
    Air    = mxGetIr(prhs[2]);
    Ajc    = mxGetJc(prhs[2]);
    
    At     = mxGetPr(prhs[3]);
    Atir   = mxGetIr(prhs[3]);
    Atjc   = mxGetJc(prhs[3]);
    
    b      = mxGetPr(prhs[4]);
    g      = mxGetPr(prhs[5]);
    
    eps    = mxGetScalar(prhs[6]);
    mu     = mxGetScalar(prhs[7]);
    lambda = mxGetScalar(prhs[8]);
    L      = mxGetScalar(prhs[9]);
    tol    = mxGetScalar(prhs[10]);
    /* gamma  = mxGetScalar(prhs[11]); */
    
    int ii,jj;
    
    /* Variables used in the iterations.
     * u     = current solution.
     * ub    = extrapolated solution.
     * uold  = old solution.
     * c     = current mask.
     * cba   = extrapolated mask.
     * cold  = old mask.
     * temp1 = temp variable to store data.
     * temp2 = temp variable to store data.
     * y     = internal var used by the algorithm.
     */
    double *u, *c, *ub, *uold, *cba, *cold, *temp1, *temp2, *y;
    u     = mxCalloc(Anrow,  sizeof(double));
    ub    = mxCalloc(Anrow,  sizeof(double));
    uold  = mxCalloc(Anrow,  sizeof(double));
    
    c     = mxCalloc(Anrow,  sizeof(double));
    cba   = mxCalloc(Anrow,  sizeof(double));
    cold  = mxCalloc(Anrow,  sizeof(double));
    
    y     = mxCalloc(Anrow,  sizeof(double));
    temp1 = mxCalloc(Anrow,  sizeof(double));
    temp2 = mxCalloc(Atnrow, sizeof(double));
    
    double du, dc;                          /* distance between the iterates. */
    
    /* Perform power method to get estimate of the largest eigenvalue of A. */
    double *EVO, *EV, *EVtemp;
    
    EVO    = mxCalloc(Anrow, sizeof(double));
    EV     = mxCalloc(Anrow, sizeof(double));
    EVtemp = mxCalloc(Anrow, sizeof(double));
    
    double lam, norm;
    
    /* Initialise vector with 1. */
    for ( ii = 0; ii < Anrow; ii++ ) { EVO[ii] = 1.0; }
    /* Iterate to get estimate for largest eigenvalue of A */
    for ( ii = 0; ii < 50; ii++ )
    {
        /* EV = A*EVO */
        smvp( Air, Ajc, A, EVO, EV, Ancol);
        /* EVtemp = A*EV */
        smvp( Air, Ajc, A, EV, EVtemp, Ancol);
        
        lam = 0.0;                                 /* <EV,EVtemp> = <EV,A*EV> */
        norm = 0.0;                                /* <EV,EV> */
        for( jj = 0; jj < Anrow ; jj++ ){
            lam   += EV[jj]*EVtemp[jj];
            norm  += EV[jj]*EV[jj];
        }
        
        lam = lam/norm;
        norm = sqrt(norm);
        
        /* Normalise current estimate for the eigenvector
         * and reset temp vars.
         */
        for ( jj = 0; jj < Anrow; jj++ )
        {
            EVO[jj] = EV[jj]/norm;
            EV[jj] = 0.0;
            EVtemp[jj] = 0.0;
        }
    }
    
    /* Get largest Eigenvalue of B */
    double temp = b[0]*b[0];
    for ( ii = 0; ii < Anrow; ii++ ) {
        if( b[ii]*b[ii] > temp ){ temp = b[ii]*b[ii]; }
    }
    
    /* Add Eigenvalues to get estimate for squared operator norm. */
    lam = lam*lam + temp;
    
    /* Set step sizes */
    double tau = 0.25;
    double sigma = 1.0/((lam+0.1)*tau);
    double theta = 1.0;
    
    double dummy = 1.0/(1.0+tau*eps+tau*mu);                    /* Time saver */
    
    for ( ii = 0; ii < L; ii++ )
    {
        
        /* temp1 = A*ub */
        smvp( Air, Ajc, A, ub, temp1, Ancol );
        
        for ( jj = 0; jj < Anrow; jj++ )
        {    
            /* Update y:
             * y = y + sigma * ( A*ub + b*cb - g )
             */
            y[jj] = y[jj] + sigma * (temp1[jj] + b[jj] * cba[jj] - g[jj]);
            temp1[jj] = 0.0;
            
            /* Save variables u and c inside uold and cold:
             * uold = u
             * cold = c
             */
            uold[jj] = u[jj];
            cold[jj] = c[jj];
        }
        
        /* temp2 = A'*y */
        smvp( Atir, Atjc, At, y, temp2, Atncol);
        
        for ( jj = 0; jj < Anrow; jj++ )
        {
            /* Update u:
             * u = 1/(1+tau) * ( u - tau*( A'*y - f) )
             */
            u[jj] = 1.0/(1.0+tau) * (u[jj] - tau*(temp2[jj] - f[jj]));
            /* Update c:
             * c = 1/(1+lambda*tau+mu) * ( c - tau * B'y - mu * cba );
             */
            c[jj] = 1.0/(1.0+tau*lambda+mu) * 
                    ( c[jj] - tau * b[jj] * y[jj] - mu*cba[jj] );
            
            /* Update ub and cba:
             * ub = u + theta*(u-uold);
             * cb = c + theta*(c-cold);
             */
            ub[jj]    = u[jj] + theta*(u[jj]-uold[jj]);
            cba[jj]   = c[jj] + theta*(c[jj]-cold[jj]);
            temp2[jj] = 0.0;
        }
        
        /* Compute squared norm between to iterates. */
        du = 0.0;
        dc = 0.0;
        for (jj = 0; jj < Anrow; jj++ )
        {
            du += (u[jj]-uold[jj])*(u[jj]-uold[jj]);
            dc += (c[jj]-cold[jj])*(c[jj]-cold[jj]);
        }
        du = sqrt(du);
        dc = sqrt(dc);
        
        /* Stop if change has become small enough */
        if ((ii > 1) && (du < tol) && (dc < tol)) {
            break;
        }
    }
    
    /* Create Output. */
    double *ur, *cr;
    plhs[0] = mxCreateDoubleMatrix(Anrow,  1, mxREAL);
    plhs[1] = mxCreateDoubleMatrix(Atnrow, 1, mxREAL);
    ur = mxGetData(plhs[0]);
    cr = mxGetData(plhs[1]);
    plhs[2] = mxCreateDoubleScalar(ii);
    plhs[3] = mxCreateDoubleScalar(du);
    plhs[4] = mxCreateDoubleScalar(dc);
    
    for( jj = 0; jj < Anrow; jj++ ){
        ur[jj] = u[jj];
        cr[jj] = c[jj];
    }
    
    /* Free space. */
    mxFree(temp1);
    mxFree(temp2);
    mxFree(y);
    mxFree(c);
    mxFree(cba);
    mxFree(cold);
    mxFree(u);
    mxFree(ub);
    mxFree(uold);
    mxFree(EVO);
    mxFree(EV);
    mxFree(EVtemp);
    
    return;
}
