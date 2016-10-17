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
"    u     - use magic orb                  r     - read scroll         ",
"    b     - check backpack                 t     - show time           ",
"    c     - center window                  w     - wear/wield item     ",
"    d     - drop item                      Q     - quit and save game  ",
"    v     - look any direction            ^Z     - abort game/no save  ",
" i,j,k,l  - move up,down,left,right       ^L     - redraw screen       ",
"   ^B     - reset priority                 SPACE  - fire arrow         ",
"    q     - quaff potion                   s     - show status         ",
"    x     - exchange primary weapon        h     - heal wounds         ",
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

void help()
{
int i;
char dummy;
char *return_d = "Press any key to return to game";
char *opreturn_d = "Press any key to continue list";

wclear(dsp_help);

i = 0;
   while( helptext[i] != NULL) {
        wprintw(dsp_help, "%s\n", helptext[i]);
        i++;
   }
if (operator) {
    wstandout(dsp_help);
    mvwprintw(dsp_help, 20, 23, "%s", opreturn_d);
    wstandend(dsp_help);
    wrefresh(dsp_help);
    getch();
    wclear(dsp_help);
    i = 0;
       while( ophelp[i] != NULL) {
            wprintw(dsp_help, "%s\n", ophelp[i]);
            i++;
       }
}
wstandout(dsp_help);
mvwprintw(dsp_help, 20, 23, "%s", return_d);
wstandend(dsp_help);
wrefresh(dsp_help);
getch();
wclear(dsp_help);
wrefresh(dsp_help);
redraw_windows();
put_windows();
}
