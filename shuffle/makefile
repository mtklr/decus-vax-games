#
# Makefile for shuffle V1.0
#
# 21/11/89
#
# Stephan Dasia   stephand@maestro.htsa.aha.nl
#                 stephand@htsa.UUCP
#                 ...!hp4nl!htsa!stephand


# Use these lines for BSD.
#Add library 'lseq' for sequent system.
LIBS= -lcurses -ltermcap -lm
CFLAGS = -O

# uncomment these lines for SYSV
#LIBS= -lcurses -lm
#CFLAGS = -O -DSYSV

# If you can compile on a sequent system use :
#PARALLEL= &
#else
PARALLEL=

CC = cc

# where the binary will go
DESTDIR = /usr/local/games
MANDIR	= /usr/man/man6

INC = 	shuffle.h

SRC =	game.c\
	main.c\
	switch.c\
	visual.c\
	xrand.c

OBJ = 	game.o\
	main.o\
	switch.o\
	visual.o\
	xrand.o

shuffle: $(PARALLEL) $(OBJ) $(INC)
	 cc -o shuffle $(OBJ) $(LIBS)

debug: $(PARALLEL) $(OBJ) $(INC)
	cc -g -o shuffle $(OBJ) $(LIBS)

install: shuffle
	install -s -m 711 shuffle $(DESTDIR)
	install -o -m 400 shuffle.6 $(MANDIR)
#	install -s -o games -m 711 shuffle $(DESTDIR)
#	install -o manual -400 shuffle.6 $(MANDIR)

clean:
	/bin/rm -rf shuffle *.o core

shar:
	@/bin/rm -rf ../shuffle.shar
	shar -vc README FILES Makefile *.c *.h shuffle.man > ../shuffle.shar

all: clean shuffle install

depend:
	mkdep $(CFLAGS) $(SRC)

# DO NOT DELETE THIS LINE -- mkdep uses it.
# DO NOT PUT ANYTHING AFTER THIS LINE, IT WILL GO AWAY.

game.o: game.c shuffle.h /usr/include/stdio.h /usr/include/math.h
game.o: /usr/include/curses.h /usr/include/stdio.h /usr/include/sgtty.h
game.o: /usr/include/sys/ioctl.h /usr/include/sys/ttychars.h
game.o: /usr/include/sys/ttydev.h /usr/include/sgtty.h
main.o: main.c shuffle.h /usr/include/stdio.h /usr/include/math.h
main.o: /usr/include/curses.h /usr/include/stdio.h /usr/include/sgtty.h
main.o: /usr/include/sys/ioctl.h /usr/include/sys/ttychars.h
main.o: /usr/include/sys/ttydev.h /usr/include/sgtty.h
switch.o: switch.c shuffle.h /usr/include/stdio.h /usr/include/math.h
switch.o: /usr/include/curses.h /usr/include/stdio.h /usr/include/sgtty.h
switch.o: /usr/include/sys/ioctl.h /usr/include/sys/ttychars.h
switch.o: /usr/include/sys/ttydev.h /usr/include/sgtty.h
visual.o: visual.c shuffle.h /usr/include/stdio.h /usr/include/math.h
visual.o: /usr/include/curses.h /usr/include/stdio.h /usr/include/sgtty.h
visual.o: /usr/include/sys/ioctl.h /usr/include/sys/ttychars.h
visual.o: /usr/include/sys/ttydev.h /usr/include/sgtty.h
xrand.o: xrand.c

# IF YOU PUT ANYTHING HERE IT WILL GO AWAY
