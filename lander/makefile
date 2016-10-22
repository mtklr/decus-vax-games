# lander Makefile

PROG = lander
SRC = $(wildcard *.c)
OBJ = $(SRC:.c=.o)

CFLAGS += -O0 -g -DHS_FILE=\"lander.hs\"
LDFLAGS +=
LDLIBS = -lncurses -lm

all: $(PROG)

$(PROG): $(OBJ)
	$(CC) -o $@ $^ $(LDFLAGS) $(LDLIBS)

clean:
	$(RM) $(PROG)
	$(RM) *.o

.PHONY: all clean
