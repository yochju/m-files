FC=gfortran

FSRC = $(wildcard *.F08)
FOBJ = $(patsubst %.F08,%.o,$(FSRC))

IFLAGS := -I.

LDFLAGS :=-L.

FCFLAGS :=-static-libgfortran -std=f2008 -static -ffree-form -Wall -Wextra -fimplicit-none -cpp $(IFLAGS) $(LDFLAGS)

.PHONY: clean all

.SUFFIXES:
.SUFFIXES: .o .c .F08 .mod

all: $(FOBJ)

clean:
	$(RM) *.o *.mod

mod_gvo.o : mod_gvo.F08 mod_inpainting.o
	$(FC) $(FCFLAGS) -c $<

mod_array.o : mod_array.F08 mod_miscfun.o
	$(FC) $(FCFLAGS) -c $<

mod_optmask.o : mod_optmask.F08 mod_inpainting.o mod_array_ops.o
	$(FC) $(FCFLAGS) -c $<

mod_stencil.o : mod_stencil.F08 mod_miscfun.o mod_array.o
	$(FC) $(FCFLAGS) -c $<

mod_laplace.o : mod_laplace.F08 mod_sparse.o mod_stencil.o mod_array.o
	$(FC) $(FCFLAGS) -c $<

mod_inpainting.o : mod_inpainting.F08 mod_laplace.o mod_stencil.o
	$(FC) $(FCFLAGS) -c $<

%.o : %.F08
	$(FC) $(FCFLAGS) -c $<
