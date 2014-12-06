#ifdef MSDOS
# include <stdio.h>
# include <process.h>
# include <dos.h>
# include <fcntl.h>
# include <sys/types.h>
# include <sys/stat.h>
# include "header.h"
# include "larndefs.h"

# define DEVICE     0x80
# define RAW        0x20
# define IOCTL      0x44
# define STDIN      0
# define STDOUT     1
# define GETBITS    0
# define SETBITS    1
# define PATHSEP    ';'

/* Normal characters are output when the shift key is not pushed.
 * Shift characters are output when either shift key is pushed.
 */
#  define KEYPADHI  83
#  define KEYPADLOW 71
#  define iskeypad(x)   (KEYPADLOW <= (x) && (x) <= KEYPADHI)
static struct {
    char normal, shift;
    } pad[KEYPADHI - KEYPADLOW + 1] = {
            {'y', 'Y'},     /* 7 */
            {'k', 'K'},     /* 8 */
            {'u', 'U'},     /* 9 */
            {' ', ' '},     /* - */
            {'h', 'H'},     /* 4 */
            {' ', ' '},     /* 5 */
            {'l', 'L'},     /* 6 */
            {' ', ' '},     /* + */
            {'b', 'B'},     /* 1 */
            {'j', 'J'},     /* 2 */
            {'n', 'N'},     /* 3 */
            {'i', 'i'},     /* Ins */
            {'.', '.'}      /* Del */
};

/* BIOSgetch gets keys directly with a BIOS call.
 */
#ifdef    OS2LARN
# define SHIFT       (RIGHTSHIFT | LEFTSHIFT)
#else
# define SHIFT       (0x1 | 0x2)
#endif
#  define KEYBRD_BIOS   0x16

static char
BIOSgetch() {
    unsigned char scan, shift, ch;
    union REGS regs;

#ifdef    OS2LARN
    KBDKEYINFO  kbd;

    KbdCharIn(&kbd,IO_WAIT,(HKBD) 0);
    ch    = kbd.chChar;
    scan  = kbd.chScan;
    shift = kbd.fsState;
#else
    /* Get scan code.
    */
    regs.h.ah = 0;
    int86(KEYBRD_BIOS, &regs, &regs);
    ch = regs.h.al;
    scan = regs.h.ah;

    /* Get shift status.
     */
    regs.h.ah = 2;
    int86(KEYBRD_BIOS, &regs, &regs);
    shift = regs.h.al;
#endif

    /* If scan code is for the keypad, translate it.
     */
    if (iskeypad(scan)) {
        if (shift & SHIFT)
            ch = pad[scan - KEYPADLOW].shift;
        else
            ch = pad[scan - KEYPADLOW].normal;
    }
    return ch;
}

kgetch()
{
    /* BIOSgetch can use the numeric key pad on IBM compatibles. */
    if (keypad)
        return BIOSgetch();
    else
        return getch();
}

doshell()
{
    char *comspec = getenv("COMSPEC");

    clear();
    lflush();
    if (comspec == NULL
    || (spawnl(P_WAIT, comspec, comspec, NULL) < 0)) {
        write(2, "A> ", 3);
        while (getche() != '\r')
            ;
    }
}

static  unsigned    old_stdin, old_stdout, ioctl();

static unsigned
ioctl(handle, mode, setvalue)
unsigned setvalue;
{
#ifndef OS2LARN
    union REGS regs;

    regs.h.ah = IOCTL;
    regs.h.al = mode;
    regs.x.bx = handle;
    regs.h.dl = setvalue;
    regs.h.dh = 0;          /* Zero out dh */
    intdos(&regs, &regs);
    return (regs.x.dx);
#endif
}

int rawio;
void
setraw()
{
    if (!rawio)
        return;
    old_stdin = ioctl(STDIN, GETBITS, 0);
    old_stdout = ioctl(STDOUT, GETBITS, 0);
    if (old_stdin & DEVICE)
        (void) ioctl(STDIN, SETBITS, old_stdin | RAW);
    if (old_stdout & DEVICE)
        (void) ioctl(STDOUT, SETBITS, old_stdout | RAW);
}

void
unsetraw()
{
    if (!rawio)
        return;
    if (old_stdin)
        (void) ioctl(STDIN, SETBITS, old_stdin);
    if (old_stdout)
        (void) ioctl(STDOUT, SETBITS, old_stdout);
}


/* Add a backslash to any name not ending in /, \ or :   There must
 * be room for the \
 */
void
append_slash(name)
char *name;
{
    char *ptr;

    if (!*name)
        return;
    ptr = name + (strlen(name) - 1);
    if (*ptr != '\\' && *ptr != '/' && *ptr != ':') {
        *++ptr = '\\';
        *++ptr = '\0';
    }
}

/* Lopen a file somewhere along the PATH
 */
plopen(name)
char    *name;
{
    char    buf[PATHLEN], *bp, *pp, lastch, *strchr();
    int fd;

    /* Try the default directory first.  Then look along PATH unless
     * the name has path components.
     */
    if ((fd = lopen(name)) >= 0)
        return fd;
    else if (strpbrk(name, "\\/:") == NULL) {
        pp = getenv("PATH");
        while (pp && *pp) {
            bp = buf;
            while (*pp && *pp != PATHSEP)
                lastch = *bp++ = *pp++;
            if (strchr("\\/:", lastch) == NULL)
                *bp++ = '\\';
            strcpy(bp, name);
            if ((fd = lopen(buf)) >= 0)
                return fd;
            if (*pp)
                pp++;
        }
    }
    return -1;
}


/* Follow the PATH, trying to fopen the file.  Takes one additional
 * argument which can be NULL.  Otherwise this argument gets filled
 * in the full path to the file.  Returns as does fopen().
 */
FILE *
fopenp(name, mode, pathname)
char *name, *mode, *pathname;
{
    char buffer[BUFSIZ], *buf, *bufp, *pathp, *getenv(), lastch;
    FILE *fp;

    /* If pathname is given, use it instead of buf so the calling
     * process knows the path we found name under
     */
    if (pathname)
        buf = pathname;
    else
        buf = buffer;

    /* Try the default directory first.  If the file can't be opened,
     * start looking along the path.
     */
    strcpy(buf, name);
    if (fp = fopen(buf, mode))
        return fp;
    else if (strpbrk(name, "\\/:") == NULL) {
        pathp = getenv("PATH");
        while (pathp && *pathp) {
            bufp = buf;
            while (*pathp && *pathp != PATHSEP)
                lastch = *bufp++ = *pathp++;
            if (lastch != '\\' && lastch != '/')
                *bufp++ = '\\';
            strcpy(bufp, name);
            if (fp = fopen(buf, mode))
                return fp;
            if (*pathp)
                pathp++;
        }
    }
    return NULL;
}

/* Diagnositic information about the disposition of levels between ram
 * and disk.
 */
levelinfo()
{
    DISKBLOCK   *dp;
    RAMBLOCK    *rp;

    cursors();
    lflush();
    fprintf(stderr, "\nRAM:\n");
    for (rp = ramblks; rp; rp = rp->next)
        fprintf(stderr, "%4d  gt:%6ld\n", rp->level, rp->gtime);
    fprintf(stderr, "\nDISK:\n");
    for (dp = diskblks; dp; dp = dp->next)
        fprintf(stderr, "%4d  gt:%6ld  fpos:%ld\n",
        dp->level, dp->gtime, dp->fpos);
    nomove=1;
    return (yrepcount = 0);
}

int swapfd = 0; /* file descriptor for the swap file */
int ramlevels = MAXLEVEL + MAXVLEVEL;   /* the maximum */


/* Allocate as many levels as possible, then check that the swap file
 * will have enough storage for the overflow.  You must be able to allocate
 * at least one level or there will be nowhere to swap to/from.  If a swap
 * file is opened it remains open for the whole game.
 */
allocate_memory()
{
    register int    i;
    DISKBLOCK   *dp, *dp2;
    RAMBLOCK    *rp;

    /* First allocate the maximum number of disk blocks, some of which
     * may not be used, but must do the allocation now since we don't
     * yet know how many levels will be allocatable.
     */
    for (i = 0; i < MAXLEVEL + MAXVLEVEL; i++) {
        if ((dp = (DISKBLOCK *) malloc(sizeof(DISKBLOCK))) == NULL)
            died(-285);
        dp->next = diskblks;
        diskblks = dp;
    }
    dp = diskblks;      /* Move this along in the next loop */

    /* Now allocate ram storage, up to ramlevels in count.
     */
    for (i = 0; i < MAXLEVEL + MAXVLEVEL; i++) {
        if (i < ramlevels)
            rp = (RAMBLOCK *) malloc(sizeof(RAMBLOCK));
        else
            rp = NULL;
        if (rp == NULL) {
            if (i == 0)
                died(-285); /* have to have at least one */

            /* Open the swap file if not yet done so
             */
            if (swapfd == 0) {
                swapfd = open(swapfile,
                    O_RDWR | O_CREAT | O_TRUNC | O_BINARY,
                    S_IWRITE | S_IREAD);
                if (swapfd < 0)
                    error("Can't open swapfile `%s'\n",
                    swapfile);

                /* First block is FREE and will be used to
                 * swap out the first level.  When another
                 * level gets swapped in, its block will be
                 * FREE.
                 */
                if (dp == NULL)
                    error("NULL1 disk pointer?\n");
                dp->level = FREEBLOCK;
                dp->fpos = 0;
                dp->gtime = 0;
                lseek(swapfd, (long) sizeof rp->cell, 0);
            }

            /* And try to seek the size of this level
             */
            dp = dp->next;
            if (dp == NULL)
                error("NULL2 disk pointer?\n");
            dp->level = FREEBLOCK;
            dp->gtime = 0;
            dp->fpos = tell(swapfd);
            if (lseek(swapfd, (long) sizeof rp->cell, 1) < 0L)
                error("Not enough disk space for swapfile `%s'\n",
                swapfile);
        } else {
            rp->next = ramblks;
            ramblks = rp;
            rp->level = FREEBLOCK;
            rp->gtime = 0;
        }
    }

    /* dp now points to the last diskblock used.  Truncate the diskblock
     * list here and free up the other blocks (for what it's worth ...)
     */
    dp2 = dp->next;
    dp->next = NULL;
    dp = dp2;
    while (dp) {
        dp2 = dp->next;
        free((char *) dp);
        dp = dp2;
    }
}


/* VARARGS1 */
warn(format, a1, a2, a3)
char *format;
long a1, a2, a3;
{
    fprintf(stderr, format, a1, a2, a3);
}

/* VARARGS1 */
error(format, a1, a2, a3, a4)
char *format;
long a1, a2, a3, a4;
{
    unsetraw();
    resetcursor();
    fputc('\n', stderr);
    fprintf(stderr, format, a1, a2, a3, a4);
    sleep(5);
    exit(1);
}

static unsigned char ocursorstart, ocursorend;
unsigned char cursorstart, cursorend;
int cursorset;

/* Save the old value of the cursor then put in the new value.
 */
# define READCURSORPOS  0x03
# define SETCURSORTYPE  0x01
# define BIOSVIDEO  0x10
setcursor()
{
#ifdef OS2LARN
  USHORT  rc;
  VIOCURSORINFO   curinfo;

  if (cursorset == 0)
      return;

  /* Save the cursor type in 'ocursorstart' and 'ocursorend'. 
  */
  rc = VioGetCurType((PVIOCURSORINFO) &curinfo, (HVIO) NULL);
  if (rc != 0)
  {
      /* errors don't happen. */
  }
  ocursorstart = curinfo.yStart;
  ocursorend   = curinfo.cEnd;

  /* set the cursor type according to global variables
     'cursorstart' and 'cursorend'.
  */
  curinfo.cEnd   = cursorend;
  curinfo.yStart = cursorstart;
  curinfo.cx     = 0; /* default width, 1 char */
  curinfo.attr   = 0; /* 'Normal' attribute */

  rc = VioSetCurType((PVIOCURSORINFO) &curinfo, (HVIO) NULL);
  if (rc != 0)
  {
      /* errors don't happen. */
  }

#else
    union   REGS    regs;

    if (cursorset == 0)
        return;

    regs.h.ah = READCURSORPOS;
    regs.h.bh = 0;
    int86(BIOSVIDEO, &regs, &regs);
    ocursorstart = regs.h.ch;
    ocursorend = regs.h.cl;

    regs.h.ah = SETCURSORTYPE;
    regs.h.bh = 0;
    regs.h.ch = cursorstart;
#if 0
    regs.h.ch = 0x20 ;
#endif
    regs.h.cl = cursorend;
    int86(BIOSVIDEO, &regs, &regs);
#endif
}

/* Restore the old cursor upon exit
 */
resetcursor()
{
#ifdef OS2LARN
  VIOCURSORINFO   curinfo;

  if (cursorset == 0)
      return;

  curinfo.cEnd   = ocursorend;
  curinfo.yStart = ocursorstart;
  curinfo.cx     = 0; /* default width, 1 char */
  curinfo.attr   = 0; /* 'Normal' attribute */

  VioSetCurType((PVIOCURSORINFO) &curinfo, (HVIO) NULL);
#else
    union   REGS    regs;

    if (cursorset == 0)
        return;
    regs.h.ah = SETCURSORTYPE;
    regs.h.bh = 0;
    regs.h.ch = ocursorstart;
    regs.h.cl = ocursorend;
    int86(BIOSVIDEO, &regs, &regs);
#endif
}
# endif /* MSDOS */
