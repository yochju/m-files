include makefile.defs

all:
	$(MAKE) --directory=libs all
	$(MAKE) --directory=fruit all

clean:
	$(RM) *.o *.mod *.mexmaci64

mod_miscfun.o : mod_miscfun.F08 mod_constants.o
	$(FC) $(FCFLAGS) -c $<

mod_array.o : mod_array.F08 mod_miscfun.o
	$(FC) $(FCFLAGS) -c $<

mod_stencil.o : mod_stencil.F08 mod_miscfun.o mod_array.o mod_constants.o
	$(FC) $(FCFLAGS) -c $<

mod_laplace.o : mod_laplace.F08 mod_sparse.o mod_stencil.o mod_array.o
	$(FC) $(FCFLAGS) -c $<

mod_cmexinterface.o : mod_cmexinterface.F08 mod_stencil.o mod_miscfun.o
	$(FC) $(FCFLAGS) -c $<

%.F08 : %.fypp
	$(PP) $< $@

%.o : %.F08
	$(FC) $(FCFLAGS) -c $<

$(LIB): $(FOBJ)
	$(AR) $@ $^
	$(RM) *.o

tags: $(FSRC) $(CSRC)
	ctags -e --langmap=fortran:.F08 $^
