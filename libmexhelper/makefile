CC=gcc
CFLAGS=-c -Wall -O3
IFLAGS=-I. -I/usr/local/MATLAB/R2012a/extern/include/
LFLAGS=
LDFLAGS=-lmwblas -lm -lcxsparse
SOURCES=$(wildcard *.c)
HEADERS=$(wildcard *.h)
OBJECTS=$(SOURCES:.c=.o)
STATICLIB=libmexhelper.a

.PHONY: clean

all: $(OBJECTS)
	ar rcs $(STATICLIB) $(OBJECTS)
	
%.o: %.c
	$(CC) $(CFLAGS) $(IFLAGS) $<
	
clean:
	rm -rf $(OBJECTS) $(STATICLIB) $(SHAREDLIB)