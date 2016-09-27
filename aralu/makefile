# aralu makefile

PROG = aralu
SRC = $(wildcard ./*.c)
OBJ = $(SRC:.c=.o)

LDLIBS = -lncurses

CFLAGS +=
LDFLAGS +=

all: $(PROG)

$(PROG): $(OBJ)

clean:
	$(RM) $(PROG)
	$(RM) *.o

.PHONY: all clean
