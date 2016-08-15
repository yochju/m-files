// Copyright (C) 2015 Laurent Hoeltgen <hoeltgen@b-tu.de>
//
// This program is free software: you can redistribute it and/or modify it under
// the terms of the GNU General Public License as published by the Free Software
// Foundation, either version 3 of the License, or (at your option) any later
// version.
//
// This program is distributed in the hope that it will be useful, but WITHOUT
// ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS
// FOR A PARTICULAR PURPOSE. See the GNU General Public License for more details.
//
// You should have received a copy of the GNU General Public License along with
// this program. If not, see <http://www.gnu.org/licenses/>.

#include <stdlib.h>
#include <stdio.h>
#include <umfpack.h>

#include <inpaintumf.h>

/*
 * alloc ==  2: routine will only be called a single time, perform everything (alloc, computations and free).
 * alloc ==  1: perform allocation and symbolic decomposition (alloc, computations, no free).
 * alloc ==  0: just update Ai, Ap, Ax (no alloc, computations, no free).
 * alloc == -1: free memory (no alloc, no computations, free).
 * int solve_inpainting_coo(long *n, long *nz, long *ir, long *jc, double *a, double *rhs, double *x, int alloc)
 */
void solve_inpainting_coo(long *n, long *nz, long *ir, long *jc, double *a, double *rhs, double *x, long *alloc)
{
        double Info[UMFPACK_INFO];
        double Control[UMFPACK_CONTROL];
        SuiteSparse_long status;
        static void *Symbolic;
        void *Numeric;
        static long   *Ap, *Ai;
        static double *Ax;

        /* Allocation must be done at first invocation (alloc == 1), bu we keep them in memory for the later calls. */
        if ((*alloc == 1)||(*alloc == 2))
        {
                Ap = calloc((*n)+1, sizeof(SuiteSparse_long));
                if (!Ap)
                {
                        return;
                }
                Ai = calloc(*nz, sizeof(SuiteSparse_long));
                if (!Ai)
                {
                        free(Ap);
                        return;
                }
                Ax = calloc(*nz, sizeof(double));
                if (!Ax)
                {
                        free(Ap);
                        free(Ai);
                        return;
                }
        }

        if (*alloc >= 0)
        {
                /* Set default parameters. */
                umfpack_dl_defaults(Control);

                /* Convert coo to csc coordinates. */
                status = umfpack_dl_triplet_to_col ((SuiteSparse_long) *n, (SuiteSparse_long) *n, (SuiteSparse_long) *nz, ir, jc, a, Ap, Ai, Ax, (long *) NULL);

                if (status < 0)
                {
                        return;
                }

                if (*alloc >= 1)
                {
                        status = umfpack_dl_symbolic ((SuiteSparse_long) *n, (SuiteSparse_long) *n, Ap, Ai, Ax, &Symbolic, Control, Info);
                        if (status < 0)
                        {
                                return;
                        }
                }

                status = umfpack_dl_numeric (Ap, Ai, Ax, Symbolic, &Numeric, Control, Info);
                if (status < 0)
                {
                        return;
                }

                status = umfpack_dl_solve (UMFPACK_A, Ap, Ai, Ax, x, rhs, Numeric, Control, Info);

                if (status < 0)
                {
                        return;
                }

                umfpack_dl_free_numeric(&Numeric);
        }

        if ((*alloc == -1)||(*alloc == 2 ))
        {
                free (Ap);
                free (Ai);
                free (Ax);
                umfpack_dl_free_symbolic (&Symbolic);
        }

        return;
}
