include ../makefile.defs

EXE=benchmark

FSRC = $(wildcard *.F08)
FOBJ = $(patsubst %.F08,%.o,$(FSRC))

IFLAGS := -I. -I../lib -J../mod/
LDFLAGS :=-L. -L../lib
LIBS = -lffiles

all: $(FOBJ)
	$(FC) $(IFLAGS) $(FCFLAGS) $(LDFLAGS) -fopenmp -o $(EXE) $(FOBJ) $(COBJ) $(LIBS)

clean:
	$(RM) *.o *.mod $(EXE) *.dyn *.spi *.spl *.a \#* ./prof/* test.txt *.gcno *.gcda *.gcov gmon.out

profile: $(EXE)
	./$(EXE) 2>/dev/null

%.o : %.F08
	$(FC) $(IFLAGS) $(FCFLAGS) -c $<
