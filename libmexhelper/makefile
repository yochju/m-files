## Copyright 2013 Laurent Hoeltgen <laurent.hoeltgen@gmail.com>
##
## This program is free software; you can redistribute it and/or modify it under
## the terms of the GNU Lesser General Public License as published by the Free
## Software Foundation; either version 3 of the License, or (at your option) any
## later version.
##
## This program is distributed in the hope that it will be useful, but WITHOUT
## ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS
## FOR A PARTICULAR PURPOSE.  See the GNU General Public License for more
## details.
##
## You should have received a copy of the GNU Lesser General Public License
## along with this program; if not, write to the Free Software Foundation, Inc.,
## 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301, USA.

CC=gcc
CFLAGS=-c -Wall -O3 -DNDEBUG -fpic
IFLAGS=-I. -I/usr/local/MATLAB/R2012a/extern/include/ -I$(HOME)/Software/include
LFLAGS=-L. -L$(HOME)/Software/lib
LDFLAGS=-lmwblas -lm -lopenblas -lcxsparse
SOURCES=$(wildcard *.c)
HEADERS=$(wildcard *.h)
OBJECTS=$(SOURCES:.c=.o)
LIBNAME_SHARED=libmexhelper.so
LIBNAME_STATIC=libmexhelper.a

.PHONY: clean

all: $(OBJECTS)
	$(CC) -shared -o $(LIBNAME_SHARED) $(OBJECTS)
	ar rcs $(LIBNAME_STATIC) $(OBJECTS)
	
%.o: %.c
	$(CC) $(CFLAGS) $(LFLAGS) $(IFLAGS) $< $(LDFLAGS)
	
clean:
	rm -rf $(OBJECTS) $(LIBNAME_SHARED) $(LIBNAME_STATIC)