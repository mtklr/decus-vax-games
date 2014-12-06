#include stdio
#include stdlib
#include smgdef
#include descrip
#include "master.h"
#include "random.c"

on_ctrl()					/* enable control-C */
{
int mask = 0x02000000;
lib$enable_ctrl(&mask);
}
	
no_ctrl()					/* disable control-C */
{
int mask = 0x02000000;
lib$disable_ctrl(&mask);
}

create_windows()  				/* Handle the windows stuff */
{
smg$create_pasteboard(&pb);
smg$create_virtual_keyboard(&kboard);
smg$set_cursor_mode(&pb,&SMG$M_SCROLL_JUMP);
smg$create_virtual_display(&21,&13,&dsp_main,&SMG$M_BORDER);
smg$create_virtual_display(&21,&11,&dsp_score,&SMG$M_BORDER);
smg$create_virtual_display(&21,&9,&dsp_pegs,&SMG$M_BORDER);
smg$create_virtual_display(&21,&43,&dsp_help);
smg$create_virtual_display(&1,&78,&dsp_text);
smg$set_keypad_mode(&kboard,&SMG$M_KEYPAD_APPLICATION);
}


put_windows()					/* put windows on the screen */
{
int i;
/* Note: since the help display is not bordered, you have to paste it before 
         pasting the score display in order to get the border for the score */
smg$begin_pasteboard_update(&pb);
smg$paste_virtual_display(&dsp_pegs,&pb,&2,&2);
for( i=2; i< 22; i+=2) 
  smg$draw_line(&dsp_pegs,&i,&1,&i,&9);
smg$paste_virtual_display(&dsp_main,&pb,&2,&12);
for( i=2; i< 22; i+=2) 
  smg$draw_line(&dsp_main,&i,&1,&i,&13);
smg$paste_virtual_display(&dsp_help,&pb,&2,&37);
smg$paste_virtual_display(&dsp_score,&pb,&2,&26);
smg$paste_virtual_display(&dsp_text,&pb,&24,&1);
smg$draw_line(&dsp_score,&2,&1,&2,&11);
smg$end_pasteboard_update(&pb);
}


delete_windows()				/* clear screen */
{
smg$delete_virtual_keyboard(&kboard);
smg$delete_pasteboard(&pb);
}


prt_help()
{
int i, row;

i = row = 0;
while( helptext[i] != NULL) prt( dsp_help, helptext[i++], ++row, 2, 0);
}


prt( display, message, y, x, flags)		/* put something in a display */
int display, y, x, flags;
char *message;
{
int text = 0;
$DESCRIPTOR( mess_d, message);

if ( display == dsp_text) text = SMG$M_ERASE_TO_EOL;
mess_d.dsc$w_length = strlen(message);
smg$put_chars(&display,&mess_d,&y,&x,&text,&flags);
}

prt_char( display, ch, row, col, flags)
char ch;
int row, col, flags, display;
{
char ch_c[1];
$DESCRIPTOR( p_char, ch_c);
ch_c[0] = ch;
row++;
col++;

p_char.dsc$w_length = 1;
smg$put_chars(&display,&p_char,&row,&col,0,&flags);
}

exit_game()
{
on_ctrl();
delete_windows();
exit( 0);
}

prt_color( col)
int col;
{
prt_char( dsp_main, names[col][0], cur_row, cur_col, SMG$M_BOLD);
prt_char( dsp_main, names[col][1], cur_row, cur_col+1, SMG$M_BOLD);
}


init_game()
{
int j, i, color, found;
char str[80];

no_ctrl();
create_windows();
put_windows();
prt_help();
randomize();
prt( dsp_pegs, "  Clues  ", 1, 1, SMG$M_BOLD);
prt( dsp_score, " W   L   %", 1, 1, SMG$M_BOLD);
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
    color = random( game);
    code[i] = colors[color];
    if ( used[color]) found = TRUE;
    else found = FALSE;
  } while( found);
  used[color]++;	/* Keep track of how many times that color is used */
 } /* End FOR */
prt( dsp_main, " XX XX XX XX ", 1, 1, SMG$M_BOLD);
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
prt( dsp_main, str, 1, 1, SMG$M_BOLD);
}

try_again()
{
char dummy;

print_code();
while( 1) {
  smg$read_keystroke( &kboard, &dummy);
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
smg$set_cursor_abs( &dsp_main, &asdf, &shit);
}


main( argc, argv)
int argc;
char *argv[];
{
int i, j, key, count;
char str[80];

/* Begin setup */
printf("As a parameter, use \"m\" for master or \"d\" for difficult games.\n");
lib$wait(&3.0);
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
  smg$read_keystroke(&kboard,&key);
  key = toupper( key);
  switch( key) {
    case 18: case 12: smg$repaint_screen( &pb); break;
    case 26: 
     	exit_game(); break;
    case 20: /* move left */
	if ( (cur_col - 3) < 1) cur_col = 1; 
	else cur_col -= 3;
	cursor();
	break;
    case 21: /* move right */
	if ( (cur_col + 3) > 10) cur_col = 10;
	else cur_col += 3;
	cursor();
	break;
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
	    prt_char( dsp_pegs, pegs[i], cur_row, (count++)*2+1, SMG$M_REVERSE);
	for ( j=0; j< 4; j++)
	  if ( pegs[j] == 'o')
	    prt_char( dsp_pegs, pegs[j], cur_row, (count++)*2+1, SMG$M_REVERSE);

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

	smg$erase_line( &dsp_text);
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
