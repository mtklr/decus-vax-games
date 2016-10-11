#include "aralu.h"

static short scoreentries;
static short rank;
static struct {
   char user[10];
   short level, kills, exp;
} scoretable[MAXSCOREENTRIES+1];
static FILE *scf;

short score()
{
short ret = 0;

   if( (ret = readscore()) == 0)
      if( (ret = makescore()) == 0)
	 if( (ret = writescore()) == 0)
	    showscore();
   return( (ret == 0) ? E_ENDGAME : ret);
}

short outputscore()
{
short ret;

   if( (ret = readscore()) == 0)
      showscore();
   return( (ret == 0) ? E_ENDGAME : ret);
}

readscore() {

   short rank;
   short ret = 0;

   if( (scf = fopen( scorefile, "r")) == NULL)
      ret = E_OPENSCORE;
   else {
         while(fscanf(scf,"%hd",&rank)!=EOF  &&  rank < MAXSCOREENTRIES)
	   {
            fscanf( scf, "%10s  %8d  %8d  %8d\n", scoretable[rank].user,
	 &scoretable[rank].level,&scoretable[rank].kills,&scoretable[rank].exp);
            scoreentries++;
           }
      }
  fclose( scf);
  return( ret);
}

makescore() {

   short ret = 0, pos, i, build = 1, insert;

   if( (pos = finduser()) > -1) {	/* user already in score file */
      insert =    (experience + wealth > scoretable[pos].exp)
	       || ( (level == scoretable[pos].level) &&
                    (kills > scoretable[pos].kills)
		  )
	       || ( (level == scoretable[pos].level) &&
		    (kills == scoretable[pos].kills) &&
		    (experience + wealth > scoretable[pos].exp)
		  );
      if( insert) { 			/* delete existing entry */
	 for( i = pos; i < scoreentries-1; i++)
	    cp_entry( i, i+1);
	 scoreentries--;
      }
      else build = 0;
   }
   else if( scoreentries == MAXSCOREENTRIES+1)
      ret = E_READSCORE;
   if( (ret == 0) && build) {
      pos = findpos();			/* find the new score position */
      if( pos > -1) {			/* score table not empty */
	 for( i = scoreentries; i > pos; i--)
	    cp_entry( i, i-1);
      }
      else pos = scoreentries;

      strcpy( scoretable[pos].user, username);
      scoretable[pos].level = level;
      scoretable[pos].kills = kills;
      scoretable[pos].exp = experience + wealth;
/*       scoreentries++; */
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
      found =    (experience + wealth > scoretable[i].exp)
	      || ( (level == scoretable[i].level) &&
                   (kills > scoretable[i].kills)
		 )
	      || ( (level == scoretable[i].level) &&
		   (kills == scoretable[i].kills) &&
		   (experience + wealth > scoretable[i].exp)
		 );
   return( (found) ? i-1 : -1);
}

writescore() {

   short ret = 0;
   long tmp;
   char score_string[70];

   if( (scf = fopen( scorefile, "r+")) == NULL)
      ret = E_OPENSCORE;
   else {
      for (tmp = 0; tmp < scoreentries; tmp++) {
        sprintf(score_string,"   %2d  %10s  %8d  %8d  %8d",
             tmp,scoretable[tmp].user,scoretable[tmp].level,
             scoretable[tmp].kills,scoretable[tmp].exp);
        while(strlen(score_string) < 70) strcat(score_string," ");
        score_string[69] = '\0';
        if (fprintf(scf,"%s\n",score_string) == NULL)
          {fclose( scf); return(E_WRITESCORE);}
      }
    }
   fclose( scf);
   return( ret);
}

showscore() {

  short i;

   fprintf( stdout, " Rank      User       Level      Kills  Experience\n");
   fprintf( stdout, "==================================================\n");
   for ( i = 0; i < scoreentries; i++)
     printf("   %2d  %10s  %8d  %8d  %8d\n",i+1,scoretable[i].user,
	     scoretable[i].level,scoretable[i].kills,scoretable[i].exp);
}

cp_entry( i1, i2)
register short i1, i2;
{
   strcpy( scoretable[i1].user, scoretable[i2].user);
   scoretable[i1].level = scoretable[i2].level;
   scoretable[i1].kills = scoretable[i2].kills;
   scoretable[i1].exp = scoretable[i2].exp;
}

short create_scorefile()
{
FILE *newfile;
short i;
short ret = 0;
short file_count;
char blank_line[70];

if ( ( newfile = fopen(scorefile,"w")) != NULL) {
  for (i=0; i<70; i++)
     blank_line[i] = ' '; /* Make the blank line to put into the score file */
  blank_line[69] = '\0';
  for (file_count=0; file_count < MAXSCOREENTRIES; file_count++)
    if( fprintf( newfile,"%s\n", blank_line) == NULL) ret = E_WRITESCORE;
  fclose( newfile);
}
else ret = E_OPENSCORE;
return( ret);
}
