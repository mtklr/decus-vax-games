#include <stdio.h>
#include <types.h>
#include <stat.h>
#include <signal.h>
#include unixlib
#include "sokoban.h"

extern char  *malloc();
extern FILE  *fopen();

extern char  map[MAXROW+1][MAXCOL+1];
extern short level, moves, pushes, packets, savepack, rows, columns;
extern short scoring;
extern POS   ppos;

static long        savedbn;
static FILE        *savefile;
static struct stat sfstat;

short savegame() {

   short ret = 0;

     signal( SIGINT, SIG_IGN);
/*   sfname = malloc( strlen( SAVEPATH) + strlen( username) + 4);*/
/*   sprintf(sfname, "$1$dua22:[temp.masandy]%s.SAV",username);*/
   if( (savefile = fopen( sfname, "w")) == NULL)
      ret = E_FOPENSAVE;
   else {
      savedbn = fileno( savefile);
      if( write( savedbn, &(map[0][0]), MAXROW*MAXCOL) != MAXROW*MAXCOL)
	 ret = E_WRITESAVE;
      else if( write( savedbn, &ppos, sizeof( POS)) != sizeof( POS))     
	 ret = E_WRITESAVE;
      else if( write( savedbn, &scoring, 2) != 2)  ret = E_WRITESAVE;
      else if( write( savedbn, &level, 2) != 2)    ret = E_WRITESAVE;
      else if( write( savedbn, &moves, 2) != 2)    ret = E_WRITESAVE;
      else if( write( savedbn, &pushes, 2) != 2)   ret = E_WRITESAVE;
      else if( write( savedbn, &packets, 2) != 2)  ret = E_WRITESAVE;
      else if( write( savedbn, &savepack, 2) != 2) ret = E_WRITESAVE;
      else if( write( savedbn, &rows, 2) != 2)     ret = E_WRITESAVE;
      else if( write( savedbn, &columns, 2) != 2)     ret = E_WRITESAVE;
      else {
	 fclose( savefile);
	 if( stat( sfname, &sfstat) != 0) ret = E_STATSAVE;
	 else if( (savefile = fopen( sfname, "a")) == NULL)
            ret = E_FOPENSAVE;
         else {
	    fclose( savefile);
	 }
      }
   }
   if( (ret == E_WRITESAVE) || (ret == E_STATSAVE)) printf("Error.\n");
   signal( SIGINT, SIG_DFL);

   return( ret);
}

short restoregame() {

   short ret = 0;
   struct stat oldsfstat;

   signal( SIGINT, SIG_IGN);
/*   sfname = malloc( strlen( SAVEPATH) + strlen( username) + 5);*/
/*   sprintf( sfname, "%s%s.SAV", SAVEPATH, username);*/
   if( stat( sfname, &oldsfstat) < -1) 
      ret = E_NOSAVEFILE;
   else {
      if( (savefile = fopen( sfname, "r")) == NULL)
        ret = 1;  /* If there is no save file, start player at level 1 */
      else {
         savedbn = fileno( savefile);
         if( read( savedbn, &(map[0][0]), MAXROW*MAXCOL) != MAXROW*MAXCOL)
	    ret = E_READSAVE;
         else if( read( savedbn, &ppos, sizeof( POS)) != sizeof( POS))     
	    ret = E_READSAVE;
         else if( read( savedbn, &scoring, 2) != 2)  ret = E_READSAVE;
         else if( read( savedbn, &level, 2) != 2)    ret = E_READSAVE;
         else if( read( savedbn, &moves, 2) != 2)    ret = E_READSAVE;
         else if( read( savedbn, &pushes, 2) != 2)   ret = E_READSAVE;
         else if( read( savedbn, &packets, 2) != 2)  ret = E_READSAVE;
         else if( read( savedbn, &savepack, 2) != 2) ret = E_READSAVE;
         else if( read( savedbn, &rows, 2) != 2)     ret = E_READSAVE;
         else if( read( savedbn, &columns, 2) != 2)     ret = E_READSAVE;
/*	 else if( read( savedbn, &sfstat, sizeof( sfstat)) != sizeof( sfstat))
	    ret = E_READSAVE;
	 else if( (sfstat.st_dev != oldsfstat.st_dev) ||
                  (sfstat.st_ino != oldsfstat.st_ino) ||
                  (sfstat.st_nlink != oldsfstat.st_nlink) ||
                  (sfstat.st_uid != oldsfstat.st_uid) ||
                  (sfstat.st_gid != oldsfstat.st_gid) ||
                  (sfstat.st_mtime != oldsfstat.st_mtime))
            ret = E_ALTERSAVE;*/
      }
   }
   signal( SIGINT, SIG_DFL);
   return( ret);
}
