
CC=gcc
CFLAGS=-lulfius -lmicrohttpd -lpthread -lorcania -lyder -ljansson -lhiredis

src = $(wildcard *.c)
exe = bin/$(src:.c=)
exe-static = bin/$(src:.c=-static)

defaults:  $(exe) $(exe-static)

bin/%: %.c
	$(CC) -o $@ $< $(CFLAGS)

bin/%-static: %.c
	$(CC) -static -o $@ $< $(CFLAGS)

clean:
	-rm $(exe) $(exe-static)
