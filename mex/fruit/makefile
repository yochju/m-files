include ../makefile.defs

EXE=run_fruit

FSRC = $(wildcard *.f90) $(wildcard *.F08)
CSRC = $(wildcard ../modules/*.c)
FOBJ = $(patsubst %.F08,%.o,$(patsubst %.f90,%.o,$(FSRC)))
COBJ = $(patsubst %.c,%.o,$(CSRC))

IFLAGS := -I. -I../libs
LDFLAGS :=-L. -L../libs
LIBS = -lffiles

all: $(FOBJ) $(COBJ)
	$(FC) -J../libs/ $(IFLAGS) $(FCFLAGS) $(LDFLAGS) -o $(EXE) $(FOBJ) $(COBJ) $(LIBS)

clean:
	$(RM) *.o *.mod $(EXE) *.dyn *.spi *.spl *.a \#* ./prof/* test.txt *.gcno *.gcda *.gcov gmon.out

fruit.o: fruit.f90
	$(FC) $(FCFLAGS) -c $<

fruit_driver.o: fruit_driver.f90 $(filter-out fruit_driver.o, $(FOBJ))	
	$(FC) -J../libs/ $(FCFLAGS) -c $<

%.o : %.F08 fruit.o
	$(FC) -J../libs/ $(FCFLAGS) -c $<
