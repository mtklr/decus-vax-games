/* nap.c */
#ifdef VMS
#include <signal.h>
#include <types.h>
#include <time.h>
#else
#include <signal.h>
#include <sys/types.h>
#ifdef SYSV
# ifdef MSDOS
#  ifdef    OS2LARN
#   define   INCL_BASE
#   include <os2.h>
#   define sleep(x)	DosSleep(x*1000L)
#  endif
#   include <dos.h>
# else
#   include <sys/times.h>
# endif
#else
#ifdef BSD
#include <sys/timeb.h>
#endif BSD
#endif SYSV
#endif
/*
 *  routine to take a nap for n milliseconds
 */
nap(x)
    register int x;
    {
    if (x<=0) return; /* eliminate chance for infinite loop */
    lflush();
    if (x > 999) sleep(x/1000); else napms(x);
    }

#ifdef NONAP
static napms(x)    /* do nothing */
    int x;
    {
    }
#else NONAP
#ifdef SYSV
/*  napms - sleep for time milliseconds - uses times() */
/* this assumes that times returns a relative time in 60ths of a second */
/* this will do horrible things if your times() returns seconds! */

#ifdef MSDOS
unsigned long
static dosgetms()
{
#ifdef    OS2LARN
  DATETIME dt;
  DosGetDateTime(&dt);

  /* return hundreths of seconds */
  return ( 360000L * dt.hours   +
       6000L   * dt.minutes +
       100L    * dt.seconds + dt.hundredths );
#else
    union REGS regs;

    regs.h.ah = 0x2C;
    intdos(&regs, &regs);

    /* return hundreths of seconds
    */
    return ( 360000L * regs.h.ch +
           6000L * regs.h.cl +
        100L * regs.h.dh + regs.h.dl );
#endif
}

static napms(time)
int time;
{
    unsigned long matchclock;

    if (time <= 0)
        time = 1;   /* eliminate chance of infinite loop */
    matchclock = dosgetms() + (time + 5) / 10;
    if (matchclock > 8640000L)   /* total 100ths-of-seconds in 24 hrs */
        return;

    while (matchclock > dosgetms())
        ;
}

# else
static napms(time)
    int time;
    {
    long matchclock, times();
    struct tms stats;

    if (time<=0) time=1; /* eliminate chance for infinite loop */
    if ((matchclock = times(&stats)) == -1 || matchclock == 0)
        return; /* error, or BSD style times() */
    matchclock += (time / 17);      /*17 ms/tic is 1000 ms/sec / 60 tics/sec */

    while(matchclock < times(&stats))
        ;
    }
# endif /* MSDOS */

#else not SYSV
#ifdef BSD
#ifdef SIGVTALRM
/* This must be BSD 4.2!  */
#include <sys/time.h>
#define bit(_a) (1<<((_a)-1))

static void nullf()
    {
    }

/*  napms - sleep for time milliseconds - uses setitimer() */
static napms(time)
    int time;
    {
    struct itimerval    timeout;
#ifdef SIG_RTNS_INT
    int     (*oldhandler) ();
#else
    void     (*oldhandler) ();
#endif
    int     oldsig;

    if (time <= 0) return;

    timerclear(&timeout.it_interval);
    timeout.it_value.tv_sec = time / 1000;
    timeout.it_value.tv_usec = (time % 1000) * 1000;

    oldsig = sigblock(bit(SIGALRM));
    setitimer(ITIMER_REAL, &timeout, (struct itimerval *)0);
    oldhandler = signal(SIGALRM, nullf);
    sigpause(oldsig);
    signal(SIGALRM, oldhandler);
    sigsetmask(oldsig);
    }

#else
/*  napms - sleep for time milliseconds - uses ftime() */

static napms(time)
    int time;
    {
    /* assumed to be BSD UNIX */
    struct timeb _gtime;
    time_t matchtime;
    unsigned short matchmilli;
    register struct timeb *tp = & _gtime;

    if (time <= 0) return;
    ftime(tp);
    matchmilli = tp->millitm + time;
    matchtime  = tp->time;
    while (matchmilli >= 1000)
        {
        ++matchtime;
        matchmilli -= 1000;
        }

    while(1)
        {
        ftime(tp);
        if ((tp->time > matchtime) ||
            ((tp->time == matchtime) && (tp->millitm >= matchmilli)))
            break;
        }
    }
#endif
#else not BSD
static napms(time) int time; {} /* do nothing, forget it */
#endif BSD
#endif SYSV
#endif NONAP
