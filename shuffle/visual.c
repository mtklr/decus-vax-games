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
/* Shuffle: screen()	The game screen					*/
/*									*/
/*          help()	This procedure is the online help		*/
/*									*/

#include "shuffle.h"


screen()                             /* game screen */
{
  move(8,13);
  printw("+-----------2-----------+ ");
  printw("      +-----------4-----------+\n");
  printw("             |       +---2---+       |  ");
  printw("     |       +---4---+       |\n");
  printw("   +---+   +---+   +---+   +---+   +---+");
  printw("   +---+   +---+   +---+   +---+\n");
  printw("   |   |   |   |   |   |   |   |   |   |");
  printw("   |   |   |   |   |   |   |   |\n");
  printw("   +---+   +---+   +---+   +---+   +---+");
  printw("   +---+   +---+   +---+   +---+\n");
  printw("     |       +---1---+       |  ");
  printw("     |       +---3---+       |\n");
  printw("     +-----------1-----------+");
  printw("       +-----------3-----------+\n");
  move(17,0);
  printw("+-----------------+---------------------+-------------------");
  printw("-------------+\n");
  printw("| LEVEL:          |                     |");
  printw("                                |\n");
  printw("+-----------------+---------------------+-------------------");
  printw("-------------+\n");
}


help()			/* help screen */
{
  move(0,30);
  printw("S H U F F L E\n");
  move(1,30);
  printw("-------------");
  move(3,1);
  printw("\tThe problem in this game is to get the");
  printw(" numbers from 1 to 9\n");
  printw("\tin the correct order using keys ");
  printw("1 to 4.\n");
  printw("\tAvailable commands are :\n");
  printw("\t1   : to switch the boxes one to four.\n");
  printw("\t2   : to switch the boxes two to five.\n");
  printw("\t3   : to switch the boxes five to eight.\n");
  printw("\t4   : to switch the boxes six to nine.\n");
  printw("\tq   : to end the game.\n");
  printw("\t?,h : to get this screen.\n");
  printw("\t^R  : to redraw screen\n");
  move(16,34);
  printw("press <space>\n");
}
