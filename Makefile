CC=gcc
CFLAGS=-lulfius -lmicrohttpd -lpthread -lorcania -lyder -ljansson -lhiredis

src = $(wildcard *.c)

exe = $(src:.c=)
bin = $(exe:%=bin/%)

exe-static = $(src:.c=-static)
bin-static = $(exe-static:%=bin/%)

defaults: $(bin) $(bin-static)

bin/%: %.c
	$(CC) -o $@ $< $(CFLAGS)

bin/%-static: %.c
	$(CC) -static -o $@ $< $(CFLAGS)

clean:
	-rm $(bin) $(bin-static)
