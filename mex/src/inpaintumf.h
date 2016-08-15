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

#ifndef INPAINTUMF_H
#define INPAINTUMF_H

#ifdef __cplusplus
extern "C"
{
#endif

  void solve_inpainting_coo(long *n, long *nz, long *ir, long *jc, double *a, double *rhs, double *x, long *alloc);

#ifdef	__cplusplus
}
#endif

#endif /* INPAINTUMF_H */
