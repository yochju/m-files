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

#ifdef __cplusplus
}
#endif

#endif
