
CC=gcc
CFLAGS=-lulfius -lmicrohttpd -lpthread -lorcania -lyder -ljansson -lhiredis

src = $(wildcard *.c)
exe = $(src:.c=)
exe-static = $(src:.c=-static)

defaults:  $(exe) $(exe-static)

%: %.c
	$(CC) -o bin/$@ $< $(CFLAGS)

%-static: %.c
	$(CC) -static -o bin/$@ $< $(CFLAGS)

clean:
	-rm $(exe) $(exe-static)
