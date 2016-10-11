#include <stdio.h>
#include <ctype.h>
#include <math.h>
#include <time.h>
#include <curses.h>
#include <string.h>
#include <stdlib.h>

#define	ISCLEAR( position)	(position == SPACE)
#define location(chr,target) ((unsigned int)strchr(target,chr)-(unsigned int)target)
/* #define upcase(str_to_do) {$DESCRIPTOR(a,str_to_do);STR$UPCASE(&a,&a);} */

#define scorefile	"aralu.score"
#define savefile        "aralu.sav"
#define monfile		"monsters.dat"

/* Screenfiles MUST have MAXROWS x MAXCOLS lines in it, otherwise the game */
/* will screw up fast. */
#define screenpath      "./"
#define SUPERUSER	"MASANDY"
#define MAXSCOREENTRIES 20  /* number of entries in the score file */
#define SCRATIOV 	4   /* how close you get to the top/bottom */
#define SCRATIOH	16  /* how close you get to the left/right */
#define BONUS		200 /* bonus multiplier per level */
#define ARROWDIST 	20  /* maximum arrow travel distance */
#define MAXVIEWDIST	20  /* maximum distance a player can see in one dir */
#define plr_timeout 	0   /* Timeout for player input - don't change */

#define TRUE		1
#define FALSE		0

/* Define for movement */
#define UP 		'i'
#define DOWN 		'k'
#define LEFT		'j'
#define RIGHT		'l'

/* Define for monster movement */
#define NORTH		-1
#define SOUTH		1
#define WEST		-2
#define EAST		2

/* Define for characters in screen file */
#define SPACE 		' '
#define WALL 		'#'

/* use weapon defines below for other weapons/objects */
/* reserve A through Z for all monsters */

/* Define itemchars for inventory */
/* All items below are displayed in the store inventory */
#define HANDS		 0 	/* Beginning player has no weapon */
#define HAXE            '\\'
#define AXE		'|'
#define ARROW  		'%'
#define SWORD		'/'
#define LSWORD          '_'
#define BOW		'}'
#define ARMOR		')'	/* Does negative damage when you get hit */
#define SCROLL		'~'	/* Magic scrolls */
#define HEALTH		'&'     /* Healing salve  -  also negative damage */
#define POTION		'!'	/* potion of speed/slowness/etc. */
#define ORB 		'*'	/* Magic Orb */
#define MINE		'.'	/* Exploding mine */
/* Total items above: 13 */

/* Define for dungeon screen comparison (no qualities to chars below) */
#define NUMITEMS	10	/* number of items below - for viewing */
#define KEY 		'>'     /* also must be defined in ITEM_PROPS & obj_names */
#define CASH 		'$'
#define DOOR 		'+'
#define STORE		'^'
#define ARENA		':'
#define BONES		'?'
#define BRIDGE		'='
#define BRIDGE2		'"'
#define WATER		'{'
#define PIT		'-'

/* Define for inventory properties */
#define MAXOBJECTS	23	/* total number of objects ==> 13 + NUMITEMS */
#define ITEMCHAR	0	/* character defined for weapon */
#define DAMAGE 		1
#define WEIGHT		2  	/* weight per object */
#define WEARABLE	3	/* Also WIELDABLE (boolean) */
#define COMBINE		4       /* Object combinable in inventory? (boolean) */
#define MAGIC		5	/* magic flag (for fags) */
#define COST 		6  	/* cost per item */
#define MAXQUALIF	7	/* itemchar,damage,weight, etc... (total) */

#define MAXROWS		60      /* file must be 132 columns by 60 rows */
#define MAXCOLS		132

/* Defines for the inventory (backpack) */
#define MAXINVEN	11	/* inventory size = 10 */
#define SPELLNAMES 	6	/* number of spells in Orb */

/* Define for flags */
#define IMMUNITY	0
#define SPEED		1
#define CONFUSE		2
#define MON_CONFUSE   	3
#define BLIND		4
#define NUMFLAGS	5 	/* total above */

/* Define for monsters */
#define MAXMONSTERS 	3   /* # different monsters per level */
#define DIFFMON 	25  /* # of different monsters possible */
#define MONCRYPT	65  /* makes decimal to ascii upper case (start w/0) */
#define MAGIC_NUMBER	96  /* makes ascii lower case to decimal (start w/1) */

/* Define for error messages */
#define E_WIND		1
#define E_OPENSCREEN    2
#define E_CLOSESCREEN   3
#define E_NOPLAYPOS     4
#define E_NOENDSCREEN   5
#define E_PRINTWIND     6
#define E_ENDGAME	7
#define E_USAGE		8
#define E_CREATED	9
#define E_OPENSAVE	10
#define E_OPENSCORE 	11
#define E_NOTSUPER	12
#define E_SAVED		13
#define E_GAINLEVEL	14
#define E_WRITESAVE	15
#define E_DATACORRUPT 	16
#define E_READSAVE	17
#define E_NOSAVEFILE	18
#define E_WRITESCORE	19
#define E_READSCORE	20
#define E_OPENMON	21

/* begin initialization */
/* Integers and strings for global variables */
short operator;		/* superuser flag */
short dead;		/* Character is dead if true */
short GAINLEVEL;	/* If true, character advances */
short KEYPOSESS;	/* if true, character can exit through door */
short dely, delx; 	/* variables for scrolling viewport */
short monkilled; 	/* number of monsters you have killed/level */
short timeout_count;	/* number of timeouts there are for monster movement */
long moves;		/* number of moves per level */
short stop_monst;	/* God flag for stopping monster movement */
short in_arena;		/* Is the player inside the arena? */
short can_exit;		/* Can the player exit the arena? */
short in_store;		/* Is the player in the store? */
int a_posx, a_posy;	/* Position for the monster in the arena */
int rival_num;		/* Monster number in the arena */
double DIFFICULTY;	/* Difficulty level - DO NOT CHANGE in CREATE.C! */
			/* define the following for the windows */
int pb, kboard;
WINDOW *dsp_main, *dsp_status, *dsp_inven, *dsp_command, *dsp_help, *dsp_viewport;

int random_seed, random_incl;	/* for randomize functions */

struct {
  int valid;       	/* flag activated? */
  int moves;		/* number of moves remaining */
} flags[NUMFLAGS];

struct {
  char mapchar;		/* char you see on screen */
  int number;		/* generic number => monster#, quantity or condition */
} map[MAXROWS][MAXCOLS+5];
char maparray[MAXROWS][MAXCOLS+5];

struct {
   int y, x, num;
   char holdchar;
} holdmap[300];

char username[10];
char underchar;
double speed;
int experience, wealth, kills, level, health;
int STR, INT, CON, DEX, BUSE, CURWEIGHT, MAXWEIGHT, MAXHEALTH, WIELD, WORN;
int ALTWEAP;

typedef struct player_a {
    char username[10];
    char underchar;   	/* what are you standing on? */
    short operator;     /* is he playing an OP game? */
    short monkilled;    /* total number of monsters killed per level */
    short KEYPOSESS;    /* keep the keyposession */
    double speed;  	/* player's speed */
    double DIFFICULTY;  /* current speed of the game */
    int level;		/* current level */
    int health;  	/* current health level */
    int experience;	/* current exp */
    int wealth;		/* cash flow */
    int kills;
    int delx;		/* the following are strictly for the savefile */
    int dely;
    int STR, INT, CON;	/* attributes */
    int DEX, BUSE;      /* more attributes */
    int CURWEIGHT;	/* current weight of backpack */
    int MAXWEIGHT;	/* max weight a player can carry in the backpack */
    int MAXHEALTH; 	/* max health to start player */
    int WIELD;          /* keep track of what the player is wielding - attack */
    int WORN;		/* same comment */
    int ALTWEAP;	/* alternate weapon in backpack */
} player_struct;
player_struct player;

typedef struct backpack_a {
    char name[20];
    char invenchar;
    int quantity;
    int condition;
} backpack_struct;
backpack_struct BACKPACK[MAXINVEN];

typedef struct monsters_a {
    char mon_char;
    char underchar;	/* character of the object walked on */
    int number;		/* number of monster */
    int n_num; 		/* name number (array below) */
    int a_num;  	/* attack number (array below) */
    int f_num;		/* fire number (array below) */
    int max_mon;	/* maximum number of this type of monster per level */
    int fly;		/* can the monster float through walls, etc. */
    int magic;		/* are the monsters magical? */
    int hlspd;		/* heal speed of monsters */
    int dir;		/* previous direction moved */
    int dam;		/* damage the monster does */
    int health;  	/* current health of monster */
    int follow;		/* how well the creature follows you */
    int reschance;      /* chance of ressurection per round */
    int dead;           /* obvious */
    int speed;		/* move speed */
    int firec;		/* chance monster fires/moves per round */
    int range;		/* how close monster has to be before moving */
    int posy;
    int posx;
} monsters_struct;
monsters_struct monsters[100];

typedef struct position_a {
    int x, y;		/* my position on the screen */
} position_struct;
position_struct ppos;

extern int ITEM_PROPS[MAXOBJECTS][MAXQUALIF];
extern char *spells[SPELLNAMES];
extern char *deaths[];
extern char *object_names[];
extern char *mon_names[];
extern char *attacks[];
extern char *monfire[];
extern char *errors[];

/* end initialization */
