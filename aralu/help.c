#include "aralu.h"


char *helptext[] = {
"                              A  R  A  L  U  ",
"                            - - - - - - - - -",
"  Aralu is a game based on real time in which the player tries to maneuver",
"throughout the realm obtaining weapons, armor, health, magic items, etc. to",
"help kill the monsters in the realm.  Experience is given for each monster",
"killed and as you gain levels, the monsters get more numerous and more",
"difficult to kill.  The object of the game is to kill all the monsters on the",
"current level and then find the key to the exits to the next level.",
" ",
"  Commands in the game are given by single keystrokes and are as follows:",
"    u     - use magic orb                  r     - read scroll		",
"    b     - check backpack                 t     - show time           ",
"    c     - center window                  w     - wear/wield item     ",
"    d     - drop item                      Q     - quit and save game  ",
"    v     - look any direction            ^Z     - abort game/no save  ",
" i,j,k,l  - move up,down,left,right       ^L     - redraw screen       ",
"   ^B     - reset priority                 SPACE  - fire arrow		",
"    q     - quaff potion                   s     - show status		",
"    x     - exchange primary weapon        h     - heal wounds		",
"    e     - exit level or enter store      S     - change speed of game",
NULL /* End help listing */
};

char *ophelp[] = {
"  Commands for Operators only:",
" ",
"    ^P    - create object (enter character to create)",
"    ^M    - show monster locations and stats in (x,y)",
"    ^D    - delete wall or object (enter direction)",
"    ^H    - heal self to maxhealth",
"    ^N    - toggle stop/start all monsters from moving",
"    ^K    - kill all monsters on level (enter letter of monster to kill)",
"    ^E    - set stats to desired values",
"    ^G    - go to level 'n'",
" ",
" Please note:  Game will not be scored if any of the above commands are ",
"               entered, and it really reduces the challenge and fun of the",
"               game, so try not to use these commands often.",
"               Remember, a true test of how good a player is is not how well",
"               he knows the Op commands, but how little he uses them.",
NULL /* End of OP help listing */
};



help()
{
int i;
char dummy;
/* $DESCRIPTOR( help_d, helptext); */
/* $DESCRIPTOR( ophelp_d, ophelp); */
/* $DESCRIPTOR( return_d, "Press any key to return to game"); */
/* $DESCRIPTOR( opreturn_d, "Press any key to continue list"); */
char *return_d = "Press any key to return to game";
char *opreturn_d = "Press any key to continue list";

i = 0;
/* smg$paste_virtual_display(&dsp_help,&pb,&2,&2); */
   while( helptext[i] != NULL) {
	/* help_d.dsc$w_length = strlen( helptext[i]); */
	/* help_d.dsc$a_pointer = helptext[i++]; */
 	/* smg$put_line(&dsp_help,&help_d,0,0,0,0); */
        wprintw(dsp_help, "%s\n", helptext[i]);
        i++;
   }
if (operator) {
/* smg$put_chars(&dsp_help,&opreturn_d,&21,&23,&SMG$M_ERASE_LINE,&SMG$M_REVERSE); */
standout();
mvprintw(21, 23, "%s", opreturn_d);
standend();
/* smg$read_keystroke(&kboard,&dummy); */
getch();
/* smg$erase_display(&dsp_help); */
wclear(dsp_help);
i = 0;
   while( ophelp[i] != NULL) {
	/* ophelp_d.dsc$w_length = strlen( ophelp[i]); */
	/* ophelp_d.dsc$a_pointer = ophelp[i++]; */
 	/* smg$put_line(&dsp_help,&ophelp_d,0,0,0,0); */
        wprintw(dsp_help, "%s\n", ophelp[i]);
        i++;
   }
}
/* smg$put_chars(&dsp_help,&return_d,&21,&23,&SMG$M_ERASE_LINE,&SMG$M_REVERSE); */
standout();
mvprintw(21, 23, "%s", return_d);
standend();
/* smg$read_keystroke(&kboard,&dummy); */
getch();
/* smg$erase_display(&dsp_help); */
/* smg$unpaste_virtual_display(&dsp_help,&pb); */
wclear(dsp_help);
}
