# master Makefile

PROG = master
SRC = $(wildcard *.c)
OBJ = $(SRC:.c=.o)

CFLAGS += -O0 -g -Wall -Wextra
LDFLAGS +=
LDLIBS = -lncurses

all: $(PROG)

$(PROG): $(OBJ)

clean:
	$(RM) $(PROG)
	$(RM) *.o

.PHONY: all clean
