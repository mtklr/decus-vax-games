/*
  Function, data declarations
*/
extern char regen_bottom;
extern char floorc, wallc;
extern char boldobjects;
extern char auto_pickup;
extern char VERSION,SUBVERSION;
extern char aborted[],beenhere[],boldon,cheat,ckpfile[],ckpflag;
extern char *class[],course[],diagfile[],fortfile[],helpfile[],holifile[];
extern char ckpfile[];
# ifdef MSDOS
extern int  swapfd;
extern char swapfile[];
extern long tell(), lseek();
# endif
extern char *inbuffer;
extern char item[MAXX][MAXY],iven[],know[MAXX][MAXY],larnlevels[],lastmonst[];
extern char level,*levelname[],logfile[],loginname[],logname[],*lpbuf,*lpend;
extern char *lpnt,mitem[MAXX][MAXY],monstlevel[];
extern char monstnamelist[],nch[],ndgg[],nlpts[],nomove,nosignal,nowelcome;
extern char nplt[],nsw[],*objectname[];
extern char hacklike_objnamelist[];
extern char original_objnamelist[];
extern char objnamelist[],optsfile[],*potionname[],playerids[],potprob[];
extern char predostuff,psname[],restorflag,savefilename[],scorefile[],scprob[];
extern char screen[MAXX][MAXY],*scrollname[],sex,*spelcode[],*speldescript[];
extern char spelknow[],*spelname[],*spelmes[];
extern char splev[],stealth[MAXX][MAXY],wizard;
extern short diroffx[],diroffy[],hitflag,hit2flag,hit3flag,hitp[MAXX][MAXY];
extern short iarg[MAXX][MAXY],ivenarg[],lasthx,lasthy,lastnum,lastpx,lastpy;
extern short nobeep,oldx,oldy,playerx,playery;
extern int dayplay,enable_scroll,yrepcount,userid,wisid,lfd,fd;
extern long initialtime,outstanding_taxes,skill[],gtime,c[],cbak[];
extern unsigned long lrandx;
# ifndef MSDOS      /* Different storage under MSDOS */
extern struct cel *cell;
# endif
extern struct sphere *spheres;

void *malloc();
char *fortune(),*getenv(),*getlogin(),*lgetw(),*lgetl(),*ctime();
char *tmcapcnv(),*tgetstr(),*tgoto();
long paytaxes(),lgetc(),lrint(),time();
unsigned long readnum();

    /* macro to create scroll #'s with probability of occurrence */
#define newscroll() (scprob[rund(81)])
    /* macro to return a potion # created with probability of occurrence */
#define newpotion() (potprob[rund(41)])
    /* macro to return the + points on created leather armor */
#define newleather() (nlpts[rund(c[HARDGAME]?13:15)])
    /* macro to return the + points on chain armor */
#define newchain() (nch[rund(10)])
    /* macro to return + points on plate armor */
#define newplate() (nplt[rund(c[HARDGAME]?4:12)])
    /* macro to return + points on new daggers */
#define newdagger() (ndgg[rund(13)])
    /* macro to return + points on new swords */
#define newsword() (nsw[rund(c[HARDGAME]?6:13)])
    /* macro to destroy object at present location */
#define forget() (item[playerx][playery]=know[playerx][playery]=0)
    /* macro to wipe out a monster at a location */
#define disappear(x,y) (mitem[x][y]=know[x][y]=0)

#ifdef VT100
    /* macro to turn on bold display for the terminal */
#define setbold() (lprcat(boldon?"\33[1m":"\33[7m"))
    /* macro to turn off bold display for the terminal */
#define resetbold() (lprcat("\33[m"))
    /* macro to setup the scrolling region for the terminal */
#define setscroll() (lprcat("\33[20;24r"))
    /* macro to clear the scrolling region for the terminal */
#define resetscroll() (lprcat("\33[;24r"))
    /* macro to clear the screen and home the cursor */
#define clear() (lprcat("\33[2J\33[f"), regen_bottom=TRUE)
#define cltoeoln() lprcat("\33[K")
#else /* VT100 */
    /* defines below are for use in the termcap mode only */
#define ST_START 1
#define ST_END   2
#define BOLD     3
#define END_BOLD 4
#define CLEAR    5
#define CL_LINE  6
#define T_INIT   7
#define T_END    8
#define CL_DOWN 14
#define CURSOR  15
    /* macro to turn on bold display for the terminal */
#define setbold() (*lpnt++ = ST_START)
    /* macro to turn off bold display for the terminal */
#define resetbold() (*lpnt++ = ST_END)
    /* macro to setup the scrolling region for the terminal */
#define setscroll() enable_scroll=1
    /* macro to clear the scrolling region for the terminal */
#define resetscroll() enable_scroll=0
    /* macro to clear the screen and home the cursor */
#define clear() (*lpnt++ =CLEAR, regen_bottom=TRUE)
    /* macro to clear to end of line */
#define cltoeoln() (*lpnt++ = CL_LINE)
#endif /* VT100 */

    /* macro to output one byte to the output buffer */
#define lprc(ch) ((lpnt>=lpend)?(*lpnt++ =(ch), lflush()):(*lpnt++ =(ch)))

    /* macro to seed the random number generator */
#define srand(x) (lrandx=x)
#ifdef MACRORND
    /* macros to generate random numbers   1<=rnd(N)<=N   0<=rund(N)<=N-1 */
#define rnd(x)  ((((lrandx=lrandx*1103515245+12345)>>7)%(x))+1)
#define rund(x) ((((lrandx=lrandx*1103515245+12345)>>7)%(x))  )
#endif /* MACRORND */

#define KNOWNOT   0x00
#define HAVESEEN  0x1
#define KNOWHERE  0x2
#define KNOWALL   (HAVESEEN | KNOWHERE)
#ifdef MSDOS
# ifdef OS2LARN
#  define PATHLEN   256
#  define DIRLEN    256
#  define INCL_BASE
#  include <os2.h>
#  define sleep(x)	DosSleep(x*1000L);
# else
#  define PATHLEN   80
#  define DIRLEN    64
# endif
  extern   char    larndir[];
  extern int       raw_io, DECRainbow, keypad, ramlevels, cursorset;
  extern unsigned char cursorstart, cursorend;
#endif MSDOS

extern char prompt_mode ;
