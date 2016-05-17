#ifndef F2MEX_H
#define F2MEX_H

#ifdef __cplusplus
extern "C"
{
#endif

  extern void mexcumsum (long, double *, double *);

  extern void mexstencillocs (long, long, long *, long *, long *);
  extern void mexstencilmask (long, long, long *, long *, long, long *);
  extern void mexcreate_5p_stencil (long, long *);

#ifdef __cplusplus
}
#endif

#endif
