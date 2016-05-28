#ifndef F2MEX_H
#define F2MEX_H

#include <stdint.h>

#ifdef __cplusplus
extern "C"
{
#endif

extern void mexcumsum (int64_t, double *, double *);

extern void mexstencillocs (int64_t, int64_t, int64_t *, int64_t *, int64_t *);

extern void mexstencilmask (int64_t, int64_t, int64_t *, int64_t *, int64_t, int64_t *);

extern void mexcreate_5p_stencil (int64_t, int64_t *);

extern void mexstencil2sparse_size (int64_t, int64_t *, int64_t *, int64_t *, int64_t *);

extern void mexconst_stencil2sparse (int64_t, int64_t, int64_t *, int64_t *, int64_t *, double *, int64_t *, int64_t *,
                                     double *);

extern void mexstencil2sparse (int64_t, int64_t *, int64_t *, int64_t *, double *, int64_t *, int64_t *, double *);

#ifdef __cplusplus
}
#endif

#endif
