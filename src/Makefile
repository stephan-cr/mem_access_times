CC = gcc
CFLAGS = -Wall -Wextra -Werror -pipe -O2

all:	mem_access_time

mem_access_time:	mem_access_time.c
	$(CC) $(CFLAGS) -lrt -o $@ $<

clean:
	rm -f mem_access_time *.o

.PHONY:	all clean
