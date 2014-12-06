#include <stdio.h>
#include <signal.h>
#include unixlib
#include "sokoban.h"

extern FILE *fopen();

extern short scorelevel, scoremoves, scorepushes;

static short scoreentries;
static short rank;
static struct {
   char user[MAXUSERNAME];
   short lv, mv, ps;
} scoretable[MAXSCOREENTRIES];

static FILE *scorefile;

short outputscore() {

   short ret;

   if( (ret = readscore()) == 0)
      showscore();
   return( (ret == 0) ? E_ENDGAME : ret);
}

short makenewscore() {

   short i;
   short ret = 0;
   short file_count = 0;
   char blank_line[70];

   scoreentries = 0;
   if( (scorefile = fopen( SCOREFILE, "w")) == NULL)
      ret = E_FOPENSCORE;
   else {
      for (i=0; i<70; i++) /* Make the blank line to put into the score file */
	blank_line[i] = ' ';
      blank_line[70] = '\0';
      for (file_count=0; file_count < MAXSCOREENTRIES; file_count++)
        if( fprintf( scorefile,"%s\n", blank_line) == NULL) ret = E_WRITESCORE;
      fclose( scorefile);
   }
   return( (ret == 0) ? E_ENDGAME : ret);
}

short score() {
   
   short ret;

   if( (ret = readscore()) == 0)
      if( (ret = makescore()) == 0)
	 if( (ret = writescore()) == 0)
	    showscore();
   return( (ret == 0) ? E_ENDGAME : ret);
}

readscore() {

   short rank;
   short ret = 0;
   long tmp;

   if( (scorefile = fopen( SCOREFILE, "r")) == NULL)
      ret = E_FOPENSCORE;
   else {
         while(fscanf(scorefile,"%d",&rank)!=EOF  &&  rank < MAXSCOREENTRIES-1)
	   {
            fscanf( scorefile, "%10s  %8d  %8d  %8d\n", scoretable[rank].user, 
	     &scoretable[rank].lv, &scoretable[rank].mv, &scoretable[rank].ps);
            scoreentries++;
           }
      }
  fclose( scorefile);
  return( ret);
}

makescore() {

   short ret = 0, pos, i, build = 1, insert;

   if( (pos = finduser()) > -1) {	/* user already in score file */
      insert =    (scorelevel > scoretable[pos].lv)
	       || ( (scorelevel == scoretable[pos].lv) &&
                    (scoremoves < scoretable[pos].mv)
		  )
	       || ( (scorelevel == scoretable[pos].lv) &&
		    (scoremoves == scoretable[pos].mv) &&
		    (scorepushes < scoretable[pos].ps)
		  );
      if( insert) { 			/* delete existing entry */
	 for( i = pos; i < scoreentries-1; i++)
	    cp_entry( i, i+1);
	 scoreentries--;
      }
      else build = 0;
   }
   else if( scoreentries == MAXSCOREENTRIES)
      ret = E_TOMUCHSE;
   if( (ret == 0) && build) {
      pos = findpos();			/* find the new score position */
      if( pos > -1) {			/* score table not empty */
	 for( i = scoreentries; i > pos; i--)
	    cp_entry( i, i-1);
      }
      else pos = scoreentries;

      strcpy( scoretable[pos].user, username);
      scoretable[pos].lv = scorelevel;
      scoretable[pos].mv = scoremoves;
      scoretable[pos].ps = scorepushes;
       scoreentries++;
   }
   return( ret);
}

finduser() {

   short i, found = 0;

   for( i = 0; (i < scoreentries) && (! found); i++)
      found = (strcmp( scoretable[i].user, username) == 0);
   return( (found) ? i-1 : -1);
}

findpos() {
 
   short i, found = 0;

   for( i = 0; (i < scoreentries) && (! found); i++)
      found =    (scorelevel > scoretable[i].lv)
	      || ( (scorelevel == scoretable[i].lv) &&
                   (scoremoves < scoretable[i].mv)
		 )
	      || ( (scorelevel == scoretable[i].lv) &&
		   (scoremoves == scoretable[i].mv) &&
		   (scorepushes < scoretable[i].ps)
		 );
   return( (found) ? i-1 : -1);
}

writescore() {

   short ret = 0;
   long tmp;
   char score_string[70];

   if( (scorefile = fopen( SCOREFILE, "r+")) == NULL)
      ret = E_FOPENSCORE;
   else {
      for (tmp = 0; tmp < scoreentries; tmp++) {
        sprintf(score_string,"   %d  %10s  %8d  %8d  %8d",
             tmp,scoretable[tmp].user,scoretable[tmp].lv,
             scoretable[tmp].mv,scoretable[tmp].ps);
        while(strlen(score_string) < 70) strcat(score_string," ");
        score_string[70] = '\0';
        if (fprintf(scorefile,"%s\n",score_string) == NULL) 
          {fclose(scorefile); return(E_WRITESCORE);}
      }
    }
   fclose( scorefile);
   return( ret);
}

showscore() {

   register short lastlv = 0, lastmv = 0, lastps = 0, i;

   fprintf( stdout, "Rank        User     Level     Moves    Pushes\n");
   fprintf( stdout, "==============================================\n");
   for ( i = 0; i < scoreentries; i++)
     printf("   %d  %10s  %8d  %8d  %8d\n",i+1,scoretable[i].user,
	     scoretable[i].lv,scoretable[i].mv,scoretable[i].ps);
}

cp_entry( i1, i2)
register short i1, i2;
{
   strcpy( scoretable[i1].user, scoretable[i2].user);
   scoretable[i1].lv = scoretable[i2].lv;
   scoretable[i1].mv = scoretable[i2].mv;
   scoretable[i1].ps = scoretable[i2].ps;
}
