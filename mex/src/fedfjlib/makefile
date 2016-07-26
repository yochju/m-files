include ../../makefile.defs

FEDLIB=libfed.a

all: $(FEDLIB)
	$(MV) $(FEDLIB) ../../lib/$(FEDLIB)

clean:
	$(RM) *.o *.mod *.dyn *.spi *.spl *.a \#* *.gcno *.gcda *.gcov gmon.out

%.o : %.c
	$(CC) $(CCFLAGS) -c $<

$(FEDLIB): fed.o fed.h fed_kappa.h
	$(AR) $@ $<
