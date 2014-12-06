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
/* Shuffle: main()	Gets the options and executes them		*/
/*									*/
/*	    test_row()	Test the order of the numbers			*/
/*									*/
/*	    draw_row()	Draw the numbers on the screen			*/
/*									*/

#include "shuffle.h"


main(argc, argv, optstring)
int argc;
char **argv,*optstring;
{
 int row[9], t, level;
 char c;
extern char *optarg;
extern int optind,opterr;

  initscr();
  crmode();
  nonl(); noecho(); standend();

  for(t=1;t<10;t++) row[t]=t;
  level=1;
  if(argv[1] && !strcmp(argv[1], "-"))
  {
    fprintf(stderr, "Usage: %s [-] [-L level]\n", argv[0]);
    fprintf(stderr, "\t- - give this summary of usage\n");
    fprintf(stderr, "\tL [level] - start at [level] of difficulty\n");
    exit(0);
  }

	/* process the arguments to the program */
/*
 *  while((c = getopt(argc, argv, "L:")) != EOF)
 * {
 *   switch(c)
 *   {
 *   case 'L':
 * 	    level = (int)atoi(optarg);
 *	    if(level>MAXLEVEL)
 *	      level = MAXLEVEL;
 *	    break;
 *   default:
 *    fprintf(stderr, "Unknown flag or improper usage:\n");
 *    fprintf(stderr, "\tuse '%s -' for usage\n", argv[0]);
 *   exit(1);
 *   }
 * }
 */

  game(row,level);
  endwin();
}


test_level(lvl)
int lvl;
{
  int temp;
  temp = lvl*FAC1*FAC2+0.5;
  temp = temp % (MAXPLAY_L+1) ;
  return temp;
}


test_row(rwt)                        /* test the correct order of the numbers */
int rwt[];
{
  int bl=0,q,cnt=0;

    for(q=1;q<10;q++)
     if(rwt[q]==q) cnt++;
    if(cnt==9) bl=1;
    return(bl);
}


draw_row(rw,lvl,cntr)                /* Draw the numbers on the screen */
int *rw[],lvl,cntr;
{
  move(11,3);
  printw("| %d |   | %d |   | %d |   ",rw[1],rw[2],rw[3]);
  printw("| %d |   | %d |   | %d |   ",rw[4],rw[5],rw[6]);
  printw("| %d |   | %d |   | %d | \n",rw[7],rw[8],rw[9]);
  move(18,10);
  printw("%d",lvl);
  move(18,42);
  if(cntr!=0)
    printw("moves : %d",cntr);
  else
    printw("moves : ");
  move(18,20);
  printw("Last switch ? ");
  mvcur(0,0,18,35);
}
