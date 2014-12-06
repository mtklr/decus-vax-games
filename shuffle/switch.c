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
/* Shuffle: switch_row		switch the numbers for the computer	*/
/*									*/
/*	    do_switch()		switch the numbers for the player	*/
/*									*/
/*	    switch_number()	switch the numbers			*/
/*									*/

#include "shuffle.h"


switch_row(rw,lvl)	/* switch the numbers for the computer */
int *rw[] , lvl;
{
  int r[MAXPLAY_L],cnt,df,x;

  RANDOM2(time(0));
  do
  {
    x=2;
    r[x-2]=RANDOM1()%4+1;
    do
    {
      r[x-1]=RANDOM1()%4+1;
    }
    while(r[x-2]==r[x-1]);
    for(cnt=1;cnt<=lvl*FAC1;cnt++)
    {
      do
      {
        r[x]=RANDOM1()%4+1;
      }
      while(r[x-1]==r[x]);
      df=abs(r[x-2]-r[x-1]);
      switch(df)
      {
        case(2): if(r[x-2] ==1 || r[x-1] ==1)
                 {
                     r[x]=RANDOM1()%2;
                     if(r[x]==0)
                       r[x]=2;
                     else
                       r[x]=4;
                 }
                 else
                 {
                     r[x]=RANDOM1()%2;
                     if(r[x]==0)
                       r[x]=1;
                     else
                       r[x]=3;
                 }
                 break;
        case(3): r[x]=RANDOM1()%2+2;
                 break;
      }
      do_switch(rw,r[x]);
      x++;
    }
  }
  while(test_row(rw) == 1);
}


do_switch(rw,mv)	/* switch the numbers for the player */
int *rw[];
int mv;
{
   switch(mv)
   {
     case(1): switch_number(rw,1,2,3,4);
                break;
     case(2): switch_number(rw,2,3,4,5);
                break;
     case(3): switch_number(rw,5,6,7,8);
                break;
     case(4): switch_number(rw,6,7,8,9);
                break;
   }
}


switch_number(rwx,n1,n2,n3,n4)	/* switch the numbers */
int *rwx[],n1,n2,n3,n4;
{
  int *temp;
    temp    = rwx[n1];
    rwx[n1] = rwx[n4];
    rwx[n4] = temp;
    temp    = rwx[n2];
    rwx[n2] = rwx[n3];
    rwx[n3] = temp;
}
