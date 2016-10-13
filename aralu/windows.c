#include "aralu.h"

/* Handle the windows stuff */

create_windows()
{
/* smg$create_pasteboard(&pb); */
/* smg$create_virtual_keyboard(&kboard); */
/* smg$set_cursor_mode(&pb,&SMG$M_SCROLL_JUMP); */
/* smg$create_virtual_display(&10,&37,&dsp_status,&SMG$M_BORDER); */
/* smg$create_virtual_display(&10,&37,&dsp_inven,&SMG$M_BORDER); */
/* smg$create_virtual_display(&10,&78,&dsp_command,&SMG$M_BORDER); */
/* smg$create_virtual_display(&21,&78,&dsp_help,&SMG$M_BORDER); */
/* smg$create_virtual_display(&MAXROWS,&MAXCOLS,&dsp_main,&SMG$M_BORDER); */
/* smg$create_viewport(&dsp_main,&1,&1,&10,&40); */
/* smg$set_keypad_mode(&kboard,&SMG$M_KEYPAD_APPLICATION); */
    dsp_status = newwin(10, 37, 2, 43);
    dsp_inven = newwin(10, 37, 2, 43);
    dsp_command = newwin(10, 78, 13, 2);
    dsp_help = newwin(21, 78, 0, 0);
    dsp_main = newwin(MAXROWS, MAXCOLS, 0, 0);
    dsp_viewport = derwin(dsp_main, 10, 40, 1, 1);
}

put_windows()
{
/* $DESCRIPTOR( statlabel, "Character Stats"); */
/* $DESCRIPTOR( invenlabel, "Inventory"); */

/* smg$begin_pasteboard_update(&pb); */
/* smg$paste_virtual_display(&dsp_status,&pb,&2,&43); */
/* smg$paste_virtual_display(&dsp_main,&pb,&2,&2); */
/* smg$paste_virtual_display(&dsp_command,&pb,&13,&2); */
/* smg$label_border(&dsp_status,&statlabel); */
/* smg$label_border(&dsp_inven,&invenlabel); */
/* smg$end_pasteboard_update(&pb); */
    wrefresh(dsp_status);
    wrefresh(dsp_viewport);
    wrefresh(dsp_command);
}

delete_windows()
{
/* smg$delete_virtual_keyboard(&kboard); */
/* smg$delete_pasteboard(&pb); */
}

prt_in_disp( display, message, y, x)
WINDOW *display;
int y, x;
char *message;
{
    mvwprintw(display, y, x, "%s", message);
    wrefresh(display);
}

prt_msg( message)
char *message;
{
    wprintw(dsp_command, "%s", message);
    wrefresh(dsp_command);
}

prt_char( ch, row, col)
char ch;
int row, col;
{
if ( ch == KEY)
    mvwaddch(dsp_main, row, col, ch | A_BOLD | A_BLINK);
else if ( ch == '*')
    mvwaddch(dsp_main, row, col, ch | A_BOLD);
else
    mvwaddch(dsp_main, row, col, ch);
}

change_viewport( rowoff, coloff)
int rowoff, coloff;
{
if ( rowoff)
  if ( rowoff - SCRATIOV > 0) {
    if ( rowoff + SCRATIOV >= MAXROWS) rowoff = MAXROWS-9;
    else rowoff -= SCRATIOV;
  }
  else rowoff = 0;

if ( coloff)
  if ( coloff - SCRATIOH > 0) {
    if ( coloff + SCRATIOH+3 >= MAXCOLS) coloff = MAXCOLS-39;
    else coloff -= SCRATIOH;
  }
  else coloff = 0;

if ( rowoff && !coloff)
    mvderwin(dsp_viewport, rowoff, 0);
else if ( !rowoff && coloff)
    mvderwin(dsp_viewport, 0, coloff);
else
    mvderwin(dsp_viewport, rowoff, coloff);
}
