include ../makefile.defs

EXE=run_fruit

FSRC = $(wildcard *.f90) $(wildcard *.F08) $(wildcard ../../*.F08)
CSRC = $(wildcard ../modules/*.c)
FOBJ = $(patsubst %.F08,%.o,$(patsubst %.f90,%.o,$(FSRC)))
COBJ = $(patsubst %.c,%.o,$(CSRC))

IFLAGS := -I. -I../lib -J../mod/
LDFLAGS :=-L. -L../lib
LIBS = -lffiles

all: $(FOBJ) $(COBJ)
#	$(CP) *.mod ../mod/
	$(FC) $(IFLAGS) $(FCFLAGS) $(LDFLAGS) -o $(EXE) $(FOBJ) $(COBJ) $(LIBS)

clean:
	$(RM) *.o *.mod $(EXE) *.dyn *.spi *.spl *.a \#* ./prof/* test.txt *.gcno *.gcda *.gcov gmon.out

test: $(EXE)
	./$(EXE) 2>/dev/null

fruit.o: fruit.f90
	$(FC) $(IFLAGS) $(FCFLAGS) -c $<

fruit_driver.o: fruit_driver.f90 $(filter-out fruit_driver.o, $(FOBJ))	
	$(FC) $(IFLAGS) $(FCFLAGS) -c $<

%.o : %.F08 fruit.o
	$(FC) $(IFLAGS) $(FCFLAGS) -c $<
