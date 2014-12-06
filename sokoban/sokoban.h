/***********************************************************************
   You may wish to alter the following directory paths
***********************************************************************/
/**/
/* SCREENPATH: the name of the directioy where the screen file are held */
/**/
#define SCREENPATH 	"$1$dua12:[temp.masmummy]"

/**/
/* SAVEPATH: the name of the path where save files are held */
/*           Attention: Be sure that there are no other files with */
/*                      the name <username>.sav                    */
/**/
/*  Note:  Since there will be only one save file per user (unless he
/*           somehow deletes the file), I changed the format of
/*          "path:username.sav" to simply "homedirectory:savefile"
/*  --ADV-- */
#define sfname   	"sys$login:sokoban.sav"

/**/
/* LOCKPATH: temporary file which is created to ensure that no users */
/*           work with the scorefile at the same time                */
/**/
/* I took this out since locking the file was screwing up the VMS 
/* conversion  --ADV--
/*
/* #define LOCKFILE	"$1$dua22:[temp.masandy]sok.lock"*/

/**/
/* SCOREFILE: the full pathname of the score file */
/**/
#define SCOREFILE "$1$dua12:[temp.masmummy]sok.score"

/**/
/* MAXUSERNAME: defines the maximum length of a system's user name */
/**/
#define MAXUSERNAME	10

/**/
/* MAXSCOREENTRIES: defines the maximum numner of entries in the scoretable */
/**/
#define MAXSCOREENTRIES     21

/**/
/* SUPERUSER: defines the name of the game superuser */
/*            Note:  only allows superuser to create a score file.
/**/
#define SUPERUSER "MASANDY"

/**/
/* PASSWORD: defines the password necessary for creating a new score file */
/**/
#define PASSWORD "nabokos"

/**/
/* OBJECT: this typedef is used for internal and external representation */
/*         of objects                                                    */
/**/
typedef struct {
   char obj_intern;	/* internal representation of the object */
   char obj_display;	/* display char for the object		 */
   short invers;	/* if set to 1 the object will be shown invers */
} OBJECT;

/**/
/* You can now alter the definitions below.
/* Attention: Do not alter `obj_intern'. This would cause an error */
/*            when reading the screenfiles                         */
/**/
static OBJECT 
   player = 	 { '@', '@', 0 },
   playerstore = { '+', '@', 1 },
   store = 	 { '.', '.', 0 },
   packet = 	 { '$', '$', 0 },
   save = 	 { '*', '$', 1 },
   ground = 	 { ' ', ' ', 0 },
   wall = 	 { '#', '#', 1 };

/*************************************************************************
********************** DO NOT CHANGE BELOW THIS LINE *********************
*************************************************************************/
#define MAXROW		20
#define MAXCOL		40

typedef struct {
   short x, y;
} POS;

#define E_FOPENSCREEN	1
#define E_PLAYPOS1	2
#define E_ILLCHAR	3
#define E_PLAYPOS2	4
#define E_TOMUCHROWS	5
#define E_TOMUCHCOLS	6
#define E_ENDGAME	7
#define E_NOUSER	9
#define E_FOPENSAVE	10
#define E_WRITESAVE	11
#define E_STATSAVE	12
#define E_READSAVE	13
#define E_ALTERSAVE	14
#define E_SAVED		15
#define E_TOMUCHSE	16
#define E_FOPENSCORE	17
#define E_READSCORE	18
#define E_WRITESCORE	19
#define E_USAGE		20
#define E_LEVHIGHMAX	21
#define E_LEVELTOOHIGH	22
#define E_NOSUPER	23
#define E_NOSAVEFILE	24

char username[10];
