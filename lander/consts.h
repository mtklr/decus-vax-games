#define ALTITUDE_INIT 1500.0                   /* initial altitude in metres */
#define LANDSCAPE_WIDTH 5000.0             /* initial screen width in metres */
#define PAD '='                    /* landing pad char in template of screen */
#define CRASH 2                                           /* status of crash */
#define LANDED 1                 /* status of potentially successful landing */
#define FLYING 0                                  /* status of flying lander */
#define GRAVITY 3.2   /* rate of descent in metres per second due to gravity */
#define ACCEPTABLE 5.0   /* acceptable landing velocity in metres per second */
#define SCR_Y 22                            /* height of lunarscape in chars */
#define SCR_X 76                             /* width of lunarscape in chars */
               /* macro to determine of y and x are legal screen coordinates */
#define LEGAL_YX(y, x) ((y) < SCR_Y && (x) < SCR_X && (y) >= 0 && (x) >= 0)
#define SCR_ADJ(y) (y + 1)   /* difference between lunarscape y and screen y */
#define MAX_PADS 20        /* maximum number of landing pads in a lunarscape */



#define HS_FILE "disk$userdisk1:[mas0.maslib.games.lander]land.score"

#define BSD
#define RAND_BSD

#define M_PI   3.141592654
#define M_PI_2 1.570796327
#define cbreak crmode
#define random() rand()
#define srandom(x) srand(x)

