/*  header.h        Larn is copyrighted 1986 by Noah Morgan. */

#ifdef MSDOS
#   define LARNHOME ""
#endif

#ifndef WIZID
#   define WIZID  1000
#endif

#define TRUE 1
#define FALSE 0

#ifdef VMS
#define unlink(x)   delete(x)    /* remove a file */
#endif

#define SCORENAME   "larn.scr"
#define LOGFNAME    "larn.log"
#define HELPNAME    "larn.hlp"
#define LEVELSNAME  "larn.maz"
#define FORTSNAME   "larn.ftn"
#define PLAYERIDS   "larn.pid"
#define HOLIFILE    "holidays"
#define DIAGFILE    "Diagfile"
#ifdef MSDOS
#   define LARNOPTS "larn.opt"
#   define SAVEFILE "larn.sav"
#   define SWAPFILE "larn.swp"
#   define CKPFILE  "larn.ckp"
#else
# ifdef VMS
#   define LARNOPTS "larn.opt"
#   define SAVEFILE "larn.sav"
#   define CKPFILE  "larn.ckp"
# else
#   define LARNOPTS ".larnopts"
#   define SAVEFILE "Larn.sav"
#   define CKPFILE  "Larn.ckp"
#   define MAIL     /* disable the mail routines for MSDOS */
# endif VMS
#endif MSDOS

#define MAXLEVEL 11    /*  max # levels in the dungeon         */
#define MAXVLEVEL 3    /*  max # of levels in the temple of the luran  */
#define MAXX 67
#define MAXY 17

#define SCORESIZE 10    /* this is the number of people on a scoreboard max */
#define MAXPLEVEL 100   /* maximum player level allowed        */
#define SPNUM 38        /* maximum number of spells in existance   */
#define TIMELIMIT 30000 /* maximum number of moves before the game is called */
#define TAXRATE 1/20    /* tax rate for the LRS */


/*  this is the structure that holds the entire dungeon specifications  */
struct cel
    {
    short   hitp;   /*  monster's hit points    */
    char    mitem;  /*  the monster ID          */
    char    item;   /*  the object's ID         */
    short   iarg;   /*  the object's argument   */
    char    know;   /*  have we been here before*/
    };

/* this is the structure for maintaining & moving the spheres of annihilation */
struct sphere
    {
    struct sphere *p;   /* pointer to next structure */
    char x,y,lev;       /* location of the sphere */
    char dir;           /* direction sphere is going in */
    char lifetime;      /* duration of the sphere */
    };

# ifdef MSDOS
/* Since only 1 level is needed at one time, each level can be swapped
 * to disk if there is not enough memory to allocate it.  Thus, there
 * need only be room for 1 level.  When a level is needed, if it is
 * already in memory, there is nothing to do.  If it isn't, get it from
 * disk after swapping out the oldest level - dgk.
 */
# define FREEBLOCK  -99
typedef struct _ramblock RAMBLOCK;
typedef struct _diskblock DISKBLOCK;
struct _ramblock {
    RAMBLOCK    *next;          /* For a linked list */
    int     level;          /* Level stored or FREEBLOCK */
    long        gtime;          /* The time stored */
    struct  cel cell[MAXX * MAXY];  /* The storage */
};
struct _diskblock {
    DISKBLOCK   *next;          /* For linked list */
    int     level;          /* Level stored or FREEBLOCK */
    long        gtime;          /* The time stored */
    long        fpos;           /* The disk position */
};
extern RAMBLOCK *ramblks;
extern DISKBLOCK *diskblks;

# endif MSDOS

# ifdef MSDOS
#  define NULL 0L       /* For large model only */
# else
#  define NULL 0
# endif MSDOS
#define BUFBIG  4096            /* size of the output buffer */
#define MAXIBUF 4096            /* size of the input buffer */
#define LOGNAMESIZE 40          /* max size of the players name */
#define PSNAMESIZE 40           /* max size of the process name */
#define SAVEFILENAMESIZE 128    /* max size of the savefile path */
