#include stdio
#include smgdef
#include descrip
#include "aralu.h"

/* Handle the windows stuff */

create_windows()
{
smg$create_pasteboard(&pb);
smg$create_virtual_keyboard(&kboard);
smg$set_cursor_mode(&pb,&SMG$M_SCROLL_JUMP);
smg$create_virtual_display(&10,&37,&dsp_status,&SMG$M_BORDER);
smg$create_virtual_display(&10,&37,&dsp_inven,&SMG$M_BORDER);
smg$create_virtual_display(&10,&78,&dsp_command,&SMG$M_BORDER);
smg$create_virtual_display(&21,&78,&dsp_help,&SMG$M_BORDER);
smg$create_virtual_display(&MAXROWS,&MAXCOLS,&dsp_main,&SMG$M_BORDER);
smg$create_viewport(&dsp_main,&1,&1,&10,&40);
smg$set_keypad_mode(&kboard,&SMG$M_KEYPAD_APPLICATION);
}


put_windows()
{
$DESCRIPTOR( statlabel, "Character Stats");
$DESCRIPTOR( invenlabel, "Inventory");

smg$begin_pasteboard_update(&pb);
smg$paste_virtual_display(&dsp_status,&pb,&2,&43);
smg$paste_virtual_display(&dsp_main,&pb,&2,&2);
smg$paste_virtual_display(&dsp_command,&pb,&13,&2);
smg$label_border(&dsp_status,&statlabel);
smg$label_border(&dsp_inven,&invenlabel);
smg$end_pasteboard_update(&pb);
}


delete_windows()
{
smg$delete_virtual_keyboard(&kboard);
smg$delete_pasteboard(&pb);
}


prt_in_disp( display, message, y, x)
int display, y, x;
char *message;
{
$DESCRIPTOR( mess_d, message);
mess_d.dsc$w_length = strlen(message);
if ( (y==0) && (x==0))		/* default to the next line, col */
  smg$put_line(&display,&mess_d,0,0,0,&SMG$M_WRAP_WORD);
else 
  smg$put_chars(&display,&mess_d,&y,&x);
}

prt_msg( message)
char *message;
{
$DESCRIPTOR( mess_d, message);
mess_d.dsc$w_length = strlen(message);
smg$put_line(&dsp_command,&mess_d,0,0,0,&SMG$M_WRAP_WORD);
}

prt_char( ch, row, col)
char ch;
int row, col;
{
char ch_c[1];
$DESCRIPTOR( p_char, ch_c);
ch_c[0] = ch;
row++;
col++;

p_char.dsc$w_length = 1;
if ( ch == KEY)
  smg$put_chars(&dsp_main,&p_char,&row,&col,0,&(SMG$M_BOLD+SMG$M_BLINK));
else if ( ch == '*')
  smg$put_chars(&dsp_main,&p_char,&row,&col,0,&SMG$M_BOLD);
else smg$put_chars(&dsp_main,&p_char,&row,&col);
}


change_viewport( rowoff, coloff)
int rowoff, coloff;
{
if ( rowoff)
  if ( rowoff - SCRATIOV > 0) {
    if ( rowoff + SCRATIOV >= MAXROWS) rowoff = MAXROWS-9;
    else rowoff -= SCRATIOV;
  }
  else rowoff = 1;

if ( coloff) 
  if ( coloff - SCRATIOH > 0) {
    if ( coloff + SCRATIOH+3 >= MAXCOLS) coloff = MAXCOLS-39;
    else coloff -= SCRATIOH;
  }
  else coloff = 1;

if ( rowoff && !coloff)
 smg$change_viewport(&dsp_main,&rowoff,0,&10,&40);
else if ( !rowoff && coloff)
 smg$change_viewport(&dsp_main,0,&coloff,&10,&40);
else
 smg$change_viewport(&dsp_main,&rowoff,&coloff,&10,&40);
}
