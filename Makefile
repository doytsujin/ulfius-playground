
CC=gcc
CPP=g++

CFLAGS=-lulfius -lmicrohttpd -lpthread -lorcania -lyder -ljansson -lhiredis

src = $(wildcard *.c)

exe = $(src:.c=)
bin = $(exe:%=bin/%)

exe-static = $(src:.c=-static)
bin-static = $(exe-static:%=bin/%)

srcpp = $(wildcard *.cc)

exepp = $(srcpp:.cc=)pp
binpp = $(exepp:%=bin/%)

exepp-static = $(srcpp:.cc=pp-static)
binpp-static = $(exepp-static:%=bin/%)

defaults: $(bin) $(bin-static) $(binpp) $(binpp-static)

bin/%: %.c
	$(CC) -o $@ $< $(CFLAGS)

bin/%-static: %.c
	$(CC) -static -o $@ $< $(CFLAGS)

bin/%pp: %.cc
	$(CPP) -o $@ $< $(CFLAGS)

bin/%pp-static: %.cc
	$(CPP) -static -o $@ $< $(CFLAGS)

clean:
	-rm $(bin) $(bin-static)
	-rm $(binpp) $(binpp-static)
