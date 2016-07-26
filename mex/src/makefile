include ../makefile.defs

all: $(LIB)
	$(MAKE) --directory=fedfjlib all
	$(RM) *.o
	$(MV) $(LIB) ../lib/$(LIB)
	$(MV) *.mod ../mod/

clean:
	$(RM) *.o *.mod *.dyn *.spi *.spl *.a \#* *.gcno *.gcda *.gcov gmon.out
	$(MAKE) --directory=fedfjlib clean

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

tags: $(FSRC) $(CSRC)
	ctags -e --langmap=fortran:.F08 $^
