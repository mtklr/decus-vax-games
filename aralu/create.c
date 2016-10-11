#include "aralu.h"

make_choice( attribute, value, row, display)
int value, row;
WINDOW *display;
char *attribute;
{
char choices[20];

sprintf(choices,"%s: %5d",attribute,value);
prt_in_disp(display,choices,row,1);
}

short add_points( changes, dsp_create, cboard)
int changes, cboard;
WINDOW *dsp_create;
{
int add;

  prt_in_disp(dsp_create,"Add 1 point to which attribute?  ",10,1);
  /* smg$read_keystroke(&cboard,&add); */
  switch( add=getch()) {
        case 'a': make_choice( "a) STR",++STR,3,dsp_create); break;
        case 'b': make_choice( "b) INT",++INT,4,dsp_create); break;
        case 'c': make_choice( "c) DEX",++DEX,5,dsp_create); break;
        case 'd': make_choice( "d) CON",++CON,6,dsp_create); break;
        default : prt_in_disp(dsp_create,"Value out of range.                 ",10,1);
                  sleep( 1);
                  changes++;
/*                changes = add_points( changes, dsp_create, cboard); */
  }
return( --changes);
}

prt_difficulty(board)
WINDOW *board;
{
prt_in_disp(board,"Select difficulty level",1,5);
prt_in_disp(board,"-----------------------",2,5);
prt_in_disp(board,"1) Slow",3,1);
prt_in_disp(board,"2) Fast",4,1);
prt_in_disp(board,"3) Look out (very fast)",5,1);
prt_in_disp(board,"4) 1200 baud rate",6,1);
prt_in_disp(board,"5) Normal (default)",7,1);
}

short create_character()
{
int cpb, cboard;
int changes, diff_num;
short ret = 0;
char left[20];

STR = INT = DEX = CON = 11;
changes = 16; /* how many changes player gets to make */

/* put choices up on the screen and read keystrokes to change stats */
/* smg$create_pasteboard(&cpb); */
/* smg$create_virtual_keyboard(&cboard); */
/* smg$set_cursor_mode(&cpb,&SMG$M_SCROLL_JUMP); */
/* smg$create_virtual_display(&10,&32,&dsp_create,&SMG$M_BORDER); */
/* smg$paste_virtual_display(&dsp_create,&cpb,&6,&25); */
WINDOW *dsp_create = newwin(10, 32, 6, 25);
prt_difficulty(dsp_create);
/* smg$read_keystroke(&cboard,&diff_num); */
switch( diff_num=getch()) { /* Note: these values are VERY touchy */
   case '1': DIFFICULTY = 0.2; break;
   case '2': DIFFICULTY = 0.05; break;
   case '3': DIFFICULTY = 0.01; break;
   case '4': DIFFICULTY = 0.40; break;
   default: DIFFICULTY = 0.1;
}
/* smg$erase_display(&dsp_create); */
wclear(dsp_create);
prt_in_disp(dsp_create,"Attributes",1,12);
prt_in_disp(dsp_create,"------------",2,11);
make_choice( "a) STR",STR,3,dsp_create);
make_choice( "b) INT",INT,4,dsp_create);
make_choice( "c) DEX",DEX,5,dsp_create);
make_choice( "d) CON",CON,6,dsp_create);
sprintf(left,"Points left: %2d",changes);
prt_in_disp(dsp_create,left,7,1);
while( (changes = add_points( changes, dsp_create, cboard)) > 0) {
  sprintf(left,"Points left: %2d",changes);
  prt_in_disp(dsp_create,left,7,1);
} /* End while */

/* All done, get rid of initial created boards and windows */
/* smg$delete_virtual_keyboard(&cboard); */
/* smg$delete_virtual_display(&dsp_create); */
/* smg$delete_pasteboard(&cpb); */
delwin(dsp_create);

/* initialize player before beginning game */
underchar = SPACE;
speed = level = 1;
MAXHEALTH = health = ((CON+level)*8);
kills = delx = dely = monkilled = 0;
CURWEIGHT = 0;
MAXWEIGHT = (STR*20);
BUSE = 0;
ALTWEAP = WORN = WIELD = 0;

return( ret);
}
