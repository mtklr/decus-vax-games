/*
** Written by Stephan Dasia.
**
** permission is granted to freely distribute this code provided that you:
**
** 1) don't charge for it
** 2) leave my name and header on it
** 3) clearly document your changes and place your name on them
** 4) and please send the changes to me
**
*/
/* Shuffle: game()	This is main game loop				*/
/*									*/
/*          end_game()	This procedure is called when a level		*/
/*			is ended. It quits if you did it in to		*/
/*			many turns.					*/
/*									*/

#include "shuffle.h"

game(row,level)
int *row[],level;
{
 int nbr ,counter;
 char c;

  do
  {
    counter=0;
    screen();
    switch_row(row,level);
    draw_row(row,level,counter);
    if(counter==0)
    {
      move(18,20);
      printw("Which switch ? ");
      mvcur(0,0,18,35);
    }
    refresh();
    do
    {
      do
      {
        c=getch();
        c&=0x7f;
	nbr=0;
        if(c>='1' && c<='4')
        {
          counter++;
          nbr=1;
          mvcur(0,0,18,35);
          printw("%c",c);
        }
        if(c=='\022')
        {
	  clear();
          screen();
          draw_row(row,level,counter);
          refresh();
        }
        if(c=='?' || c=='h' || c=='H')
        {
          clear();
          help();
          refresh();
          while((c=getch()) != ' ');
	  clear();
          screen();
          draw_row(row,level,counter);
          refresh();
        }
      }
      while( nbr!=1 && c!='?' && c!='h' && c!='H' && c!='q' && c!='Q');
      do_switch(row,c-'0');
      draw_row(row,level,counter);
      refresh();
    }
    while(test_row(row) ==0 && c!='q' && c!='Q');
    if(c!='q' && c!='Q')
      end_game(counter,level);
    level++;
  }
  while(c!='q' && c!='Q' && counter<test_level(level) && level<=MAXLEVEL);
  if(c=='q' || c=='Q')
  {
    clear();
    refresh();
  }
}


end_game(cntr,lvl)	/* gives a next level if you did it ok, and     */
int cntr,lvl;		/* stops it if you did it in to many turns	*/
{
  char x;

  move(20,2);
  if(cntr<=test_level(lvl))
  {
    printw("You did it in %d switches.",cntr);
    move(20,42);
    printw("press <space> to continue");
    refresh();
    move(20,67);
    clrtoeol();
    while((x=getch()) !=' ');
  }
  else
  {
    printw("You did it in %d switches and",cntr);
    printw(" it could be done in %d switches.\n\n",lvl*FAC1);    
    refresh();
    exit();
  }
}
