#include <curses.h>
#include unixlib
#include stdlib
#include libdef
#include jpidef
#include descrip
#include "sokoban.h"

#define location(chr,target) ((unsigned int)strchr(target,chr)-(unsigned int)target)

extern char  *strrchr();
extern short readscreen(), play(), outputscore(),
	     makenewscore(), restoregame(), score();

extern short level, packets, savepack, moves, pushes, rows, columns;
short scoring = 1;
short scorelevel, scoremoves, scorepushes;
char  map[MAXROW+1][MAXCOL+1];
POS   ppos;
char  *prgname;

static short optshowscore = 0, 
	     optmakescore = 0, 
             optrestore = 1,  /* Auto restore if savefile is present    */
			      /* don't get level from score file --ADV--*/
	     optlevel = 0; 
static short superduperuser = 0;

static short userlevel;

main( argc, argv) 
short argc; 
char *argv[];
{
   short ret, ret2;
$DESCRIPTOR(usernamedesc,username);

   scorelevel = 0;
   moves = pushes = packets = savepack = 0;
   if( (prgname = strrchr( argv[0], '/')) == NULL)
      prgname = argv[0];
   else prgname++;
   lib$getjpi(&JPI$_USERNAME,0,0,0,&usernamedesc);
   if (strchr(username,' ')!=0)
     username[location(' ',username)] = 0;
   if( username  == NULL)
      ret = E_NOUSER;
   else {
        if (strcmp( username, SUPERUSER) == 0) superduperuser = 1;
      if( (ret = checkcmdline( argc, argv)) == 0) {
	 if( optrestore)  /* Always restore game if file is present */
	    ret = restoregame();
         if( optshowscore)
	    ret = outputscore();
         else if( optmakescore) {
	    if( superduperuser) {
	          ret = makenewscore();
	    }
	    else ret = E_NOSUPER;
	 }
         else if( optlevel > 0) {
	       if( superduperuser) {
	          level = optlevel;
		  optrestore = 0;
		  scoring = 0;  /* Ahh!  No cheating now! */
	       }
	       else {
		/* Note: if user desires to play lower level, he can do so */
	        /*       and still be scored. */
		    if ( optlevel <= level) {
                        level = optlevel;
			optrestore = 0;
	            }
		    else ret = E_LEVHIGHMAX; /* Level higher than maxlevel */
	       }
	 }
      }
   }
   if( ret == 0)
      ret = gameloop();
   else if (ret == 1) {
          level = 1;
	  optrestore = 0;
	  ret = gameloop();
	}
   errmess( ret);
   if( scorelevel && scoring) {
      ret2 = score();
      errmess( ret2);
   }
   exit( 0); /* End of main */
}

checkcmdline( argc, argv) 
short argc;
char *argv[];
{
   short ret = 0;

   if( argc > 1)
      if( (argc == 2) && (argv[1][0] == '-')) {
	 if( (argv[1][1] == 's') && (argv[1][2] == '\0'))
	    optshowscore = 1;
	 else if( (argv[1][1] == 'c') && (argv[1][2] == '\0'))
	    optmakescore = 1;
	 else if( (argv[1][1] == 'r') && (argv[1][2] == '\0'))
	    optrestore = 1;
	 else if( (optlevel = atoi( &(argv[1][1]))) == 0)
	    ret = E_USAGE;
      }
      else ret = E_USAGE; 
   return( ret);
}

gameloop() {

   short ret = 0;

   initscr(); crmode(); noecho();
   if( ! optrestore) ret = readscreen();
   while( ret == 0) {
      if( (ret = play()) == 0) {
         level++;
         moves = pushes = packets = savepack = 0;
         ret = readscreen();
      }
   }
   clear(); refresh(); 
   nocrmode(); echo(); endwin();
   return( ret);
}

getpassword() {
int E_ILLPASSWORD = 30;  /* Not used */

   char passwd[20];
   scanf("Password: %s",passwd);
   return( (strcmp(passwd, PASSWORD) == 0) ? 0 : E_ILLPASSWORD);
}

char *message[] = {
   "illegal error number",
   "cannot open screen file",
   "more than one player position in screen file",
   "illegal char in screen file",
   "no player position in screenfile",
   "too much rows in screen file",
   "too much columns in screenfile",
   "level aborted",
   NULL,			/* errmessage deleted */
   "cannot get your username",
   "cannot open savefile",
   "error writing to savefile",
   "cannot stat savefile",
   "error reading savefile",
   "cannot restore, your savefile has been altered",
   "game saved",
   "too many users in score table",
   "cannot open score file",
   "error reading scorefile",
   "error writing scorefile",
   "illegal command line syntax",
   "level number higher than current maxlevel",
   "level number too big in command line",
   "only superuser is allowed to make a new score table",
   "cannot find file to restore"
};

errmess( ret) 
register short ret;
{
   if ( ret != E_ENDGAME) {
      fprintf( stderr, "Sokoban: ");
      switch( ret) {
         case E_FOPENSCREEN: case E_PLAYPOS1:   case E_ILLCHAR: 
	 case E_PLAYPOS2:    case E_TOMUCHROWS: case E_TOMUCHCOLS: 
	 case E_ENDGAME:     case E_NOUSER:      
	 case E_FOPENSAVE:   case E_WRITESAVE:  case E_STATSAVE:    
	 case E_READSAVE:    case E_ALTERSAVE:  case E_SAVED:       
	 case E_TOMUCHSE:    case E_FOPENSCORE: case E_READSCORE: 
	 case E_WRITESCORE:  case E_USAGE:	case E_LEVHIGHMAX:
	 case E_LEVELTOOHIGH: case E_NOSUPER:	case E_NOSAVEFILE:
			     fprintf( stderr, "%s\n", message[ret]);
                             break;
         default:            fprintf( stderr, "%s\n", message[0]);
                             break;
      }
     }
      if( ret == E_USAGE) usage();
}

usage() {
   printf("Usage: sokoban [-{s|c|r|<nn>}]\n\n");
   printf("           -c:    create new score table (superuser only)\n");
   printf("           -r:    restore saved game\n");
   printf("           -s:    show score table\n");
   printf("           -<nn>: play this level (<nn> must be greater than 0)\n");
}
