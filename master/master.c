#include <ncurses.h>
#include "master.h"

create_windows()  				/* Handle the windows stuff */
{
    dsp_main = newwin(22, 14, 0, 0);
    dsp_score = newwin(22, 12, 0, 0);
    dsp_pegs = newwin(22, 10, 0, 0);
    dsp_help = newwin(22, 44, 0, 0);
    dsp_text = newwin(2, 79, 0, 0);
}


put_windows()					/* put windows on the screen */
{
int i;
/* Note: since the help display is not bordered, you have to paste it before 
         pasting the score display in order to get the border for the score */
mvwin(dsp_pegs, 2, 2);
for( i=2; i< 22; i+=2)
    mvwhline(dsp_pegs, i, 1, '-', 9);
for( i=2; i< 22; i+=2) 
    mvwhline(dsp_main, i, 1, '-', 13);

    mvwin(dsp_help, 2, 37);
    mvwin(dsp_score, 2, 26);
    mvwin(dsp_text, 24, 1);
    mvwhline(dsp_score, 2, 1, 2, 11);
    refresh();
}


delete_windows()				/* clear screen */
{
    delwin(dsp_main);
    delwin(dsp_score);
    delwin(dsp_pegs);
    delwin(dsp_help);
    delwin(dsp_text);
}


prt_help()
{
int i, row;

i = row = 0;
while( helptext[i] != NULL) prt( dsp_help, helptext[i++], ++row, 2, 0);
wrefresh(dsp_help);
}


prt( display, message, y, x, flags)		/* put something in a display */
WINDOW *display;
char *message;
int y, x, flags;
{
int text = 0;

wattron(display, flags);
mvwprintw(display, y, x, message);
wclrtoeol(display);
wstandend(display);
wrefresh(display);
}

prt_char( display, ch, row, col, flags)
WINDOW *display;
char ch;
int row, col, flags;
{
row++;
col++;
wattron(display, flags);
mvwaddch(display, row, col, ch);
wstandend(display);
wrefresh(display);
}

exit_game()
{
nocbreak();
delete_windows();
endwin();
exit( 0);
}

prt_color( col)
int col;
{
prt_char( dsp_main, names[col][0], cur_row, cur_col, A_BOLD);
prt_char( dsp_main, names[col][1], cur_row, cur_col+1, A_BOLD);
wrefresh(dsp_main);
}


init_game()
{
int j, i, color, found;
char str[80];

initscr();
noecho();
raw();
nonl();
create_windows();
keypad(stdscr, TRUE);
put_windows();
prt_help();
randomize();
prt( dsp_pegs, "  Clues  ", 1, 1, A_BOLD);
prt( dsp_score, " W   L   %", 1, 1, A_BOLD);
score_row = 3;
cur_row = 2;
cur_col = 1;
for( i=0; i< game; i++) used[i] = 0; 
for( i=0; i< 4; i++) {
   guess[i] = ' ';
   code[i] = ' ';
}
for( i=0; i< 4; i++) {
  do {
    color = randnum( game);
    code[i] = colors[color];
    if ( used[color]) found = TRUE;
    else found = FALSE;
  } while( found);
  used[color]++;	/* Keep track of how many times that color is used */
 } /* End FOR */
prt( dsp_main, " XX XX XX XX ", 1, 1, A_BOLD);
if ( wins == 0) pcnt = 0;
else pcnt = wins/(wins + losses) * 100;
sprintf( str, "%2.0f  %2.0f %3.0f ", wins, losses, pcnt);
prt( dsp_score, str, score_row, 1, 0);
cursor();
}


print_code()
{
int i, j, array[4];
char str[80];

for ( j=0; j< 4; j++)
  for ( i=0; i< game; i++)
    if ( code[j] == colors[i]) {
      array[j] = i;
      break;
    }

sprintf(str," %s %s %s %s \0", names[array[0]], names[array[1]], 
					names[array[2]], names[array[3]]);
prt( dsp_main, str, 1, 1, A_BOLD);
}

try_again()
{
char dummy;

print_code();
while( 1) {
  dummy=getch();
  if ( toupper( dummy) == 'Y') {
    delete_windows();
    init_game(); 
    break;
  }
  else if ( toupper( dummy) == 'N') {
    delete_windows();
    exit_game();
    break;
  }
  else prt( dsp_text, "Please enter Y or N. ", 1, 1, 0);
} /* End while */
}


cursor()
{
int asdf, shit;

asdf = cur_row+1;
shit = cur_col+1;
move(asdf, shit);
}


main( argc, argv)
int argc;
char *argv[];
{
int i, j, key, count;
char str[80];

/* Begin setup */
printf("As a parameter, use \"m\" for master or \"d\" for difficult games.\n");
sleep(1);
wins = losses = 0;
game = REGULAR;

if ( argc > 1) {
  switch( toupper( argv[1][0])) {
     	 case 'M': game = MASTER; break;
	 case 'D': game = DIFFICULT; break;
         default: printf( "There is no option with that letter.\n");
		  printf( "Valid options are:  \"M\" or \"D\".\n");
		  exit(0);
  } /* End switch */
}

/* Do everything to start a game next */
init_game();

/* Main loop */
while( 1) {
  key=getch();
  key = toupper( key);
  switch( key) {
    case 18: case 12: refresh(); break;
    case 26: 
     	exit_game(); break;
    case KEY_LEFT:
    case 20: /* move left */
	if ( (cur_col - 3) < 1) cur_col = 1; 
	else cur_col -= 3;
	cursor();
	break;
    case KEY_RIGHT:
    case 21: /* move right */
	if ( (cur_col + 3) > 10) cur_col = 10;
	else cur_col += 3;
	cursor();
	break;
    case ' ':
    case 13: /* select sequence */
	count = 0;
	for ( i=0; i< 4; i++)
	   if ( guess[i] == ' ') {
	     prt( dsp_text, "You must have all four colors selected first.", 1,
									1, 0);
	     j = FALSE;
	     break;
	   }
	   else j = TRUE;
	if ( !j) break;
	for ( j=0; j< 4; j++) {
	  for ( i=0; i< 4; i++) 
	     if ( (guess[i] == guess[j])  &&  ( i != j)) {
	       prt( dsp_text, 
	  "Multiple occurrence of single color found.  Choose again.", 1, 1, 0);
	       count = 99;
	       break;
	     }
	  if ( count == 99) break;
	}
	if ( count == 99) break;
	/* compare computer code and guess here */
	for ( j=0; j< 4; j++)
	  for ( i=0; i< 4; i++)
		if ( guess[i] == code[j]) {
		  if ( i == j) pegs[j] = 'X';
		  else pegs[j] = 'o';
		  break;
		}
		else pegs[j] = ' ';
	pegs[4] = 0;
        /* print out pegs for clues */
	count = 0;
	for ( i=0; i< 4; i++)
	  if ( pegs[i] == 'X')
	    prt_char( dsp_pegs, pegs[i], cur_row-1, (count++)*2+1, A_REVERSE);
	for ( j=0; j< 4; j++)
	  if ( pegs[j] == 'o')
	    prt_char( dsp_pegs, pegs[j], cur_row-1, (count++)*2+1, A_REVERSE);

	for( i=0; i< 4; i++) guess[i] = ' ';
 	cur_row += 2;
	/* if winner, score here and start new game */	
	if ( strcmp( pegs, "XXXX") == 0) {
	  wins++;
	  prt( dsp_text, "You won.  Would you like to try again? [y/n] ", 1, 1,
									     0);
	  try_again();
	  cur_row = 2;
	}  
  	if ( cur_row > 20) {
	  /* end game due to too many guesses */
	  losses++;
	  prt( dsp_text, "You lose.  Would you like to try again? [y/n] ", 1, 
								   	  1, 0);
	  try_again();
	  cur_row = 2;
	}

        wclrtoeol(dsp_text);
	cur_col = 1;
	cursor();
 	break;
    default: 
      for( i=0; i< game; i++)
        if ( key == colors[i]) {
 	  prt_color( i);
	  if ( cur_col< 4) guess[0] = key;
	  else if ( cur_col< 7) guess[1] = key;
	  else if ( cur_col< 10) guess[2] = key;
  	  else guess[3] = key;
 	  if ( (cur_col + 3) > 10) cur_col = 10;
	  else cur_col += 3;
	  cursor();
          break;
        }
  } /* End switch */
} /* End while */
}
