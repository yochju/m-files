include makefile.defs

all:
	$(MAKE) --directory=src all
	$(MAKE) --directory=fruit all
	$(MAKE) --directory=benchmark all

clean:
	$(RM) *.o *.mod *.mexmaci64
	$(MAKE) --directory=src clean
	$(MAKE) --directory=fruit clean
	$(MAKE) --directory=benchmark clean

test:
	$(MAKE) --directory=fruit test

doc:
	ford gendoc.md
