/*
 * Copyright 2012 Laurent Hoeltgen <laurent.hoeltgen@gmail.com>
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
 *
 * Last revision on: 31.10.2012 9:00
 */

#include "mex.h"

#include <math.h>
#include "libfed/fed.h"

/* mex -g -I. -I./libfed -lm fed_tau_by_steps.c libfed/fed.c */
void mexFunction(int nlhs, mxArray *plhs[], int nrhs, const mxArray *prhs[])
{    
    int   n          = (int)   mxGetScalar(prhs[0]);
    float tau_max    = (float) mxGetScalar(prhs[1]);

    double *p;
    
    plhs[0] = mxCreateNumericMatrix(1, 1, mxDOUBLE_CLASS, mxREAL);
    p = mxGetPr(plhs[0]);
    p[0] = (double) fed_max_cycle_time_by_steps(n,tau_max);
    
    return;
}
