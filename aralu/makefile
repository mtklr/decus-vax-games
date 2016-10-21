# aralu makefile

PROG = aralu
SRC = $(wildcard ./*.c)
OBJ = $(SRC:.c=.o)

LDLIBS = -lncurses

CFLAGS += -O0 -g -Wall -Wextra
LDFLAGS +=

all: $(PROG)

$(PROG): $(OBJ)

clean:
	$(RM) $(PROG)
	$(RM) *.o

.PHONY: all clean
