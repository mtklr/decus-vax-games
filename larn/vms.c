#ifdef VMS
#include "header.h"

#include <file.h>
#include <stat.h>
#include <stdio.h>
#include <stsdef.h>
#include <ssdef.h>
#include <descrip.h>
#include <iodef.h>
#include <ttdef.h>
#include <tt2def.h>

/*
 * Read until end of file or until buffer is full.
 * don't let the vms read (which stops once per record)
 * fool the program.
 */
vread(fd, buf, size)
int fd;
char    *buf;
int size;
{
    int csize;      /* cumulative size  */
    int isize;      /* incremental size */

    csize = 0;
    do {
        isize = read(fd, buf, size);
        if (isize > 0) {
            csize += isize;
            buf   += isize;
            size  -= isize;
        }
    } while (isize > 0);
    return (csize);
}

#else VMS

#ifndef vread       /* if not done as a macro in header.h */
vread(fd, buf, size)
int fd;
char    *buf;
int size;
{
    return (read(fd, buf, size));
}
#endif vread
#endif VMS

#ifdef VMS
/*
 * Run a command in a subjob.  Used for mailing the winners congratulations,
 * tax bills, etc.  Used for the shell escape command (!).  Conditionalized
 * for VMS wherever used (un*x has the right primitives).
 */
long
oneliner(cstr)
char    *cstr;
{
    struct  dsc$descriptor  cdsc;
    register long       sts;
    register long       pstat;

    cdsc.dsc$a_pointer = cstr;
    cdsc.dsc$w_length  = strlen(cstr);
    cdsc.dsc$b_dtype   = DSC$K_DTYPE_T;
    cdsc.dsc$b_class   = DSC$K_CLASS_S;

/*    sts = LIB$SPAWN(&cdsc, 0, 0, 0, 0, 0, &pstat, 0, 0, 0, 0, 0);
    if (sts != SS$_NORMAL)
        return (sts);
    else   
*/
        return (pstat);
}

/*
  Data to convert the escape codes produced by VT style keypad keys to things
  that LARN will understand.
*/
#define MAX_KP_CONV 19
struct 
    {
    char *inp_str;
    char *out_str;
    } keypad_conv[MAX_KP_CONV] = { { "\x1BOp", "i" },      /* KP0 */
                                   { "\x1BOq", "b" },      /* KP1 */
                                   { "\x1BOr", "j" },      /* KP2 */
                                   { "\x1BOs", "n" },      /* KP3 */
                                   { "\x1BOt", "h" },      /* KP4 */
                                   { "\x1BOu", "." },      /* KP5 */
                                   { "\x1BOv", "l" },      /* KP6 */
                                   { "\x1BOw", "y" },      /* KP7 */
                                   { "\x1BOx", "k" },      /* KP8 */
                                   { "\x1BOy", "u" },      /* KP9 */
                   { "\x1BOn", "." },      /* KP. */
                   { "\x1BOl", "," },      /* KP, */
                   { "\x1B[A", "K" },      /* uparrow */
                   { "\x1B[B", "J" },      /* downarrow*/
                   { "\x1B[C", "L" },      /* right arrow */
                   { "\x1B[D", "H" },      /* left arrow */
                   { "\x1BOP", "m" },      /* PF1 */
                   { "\x1BOS", "@" },      /* PF4 */
                                   { "\x1B[23~", "\x1B" }  /* (ESC) */
                                 };

/*
  VMS-specific terminal character read.  Gets a character from the terminal,
  translating keypad as necessary.  Assumes VT-class terminals.
*/
vms_ttgetch()
    {

#define BUFFLEN 10

    char           *i;
    int            j;
    register int   incount;
    static char    buffer[BUFFLEN];
    static char    *bufptr = buffer;
    static char    *bufend = buffer;

    lflush();       /* be sure output buffer is flushed */

    /* Read the first char from the user
    */
    if (bufptr >= bufend) 
        {
        bufptr = bufend = buffer;
        incount = vmsread(buffer, BUFFLEN, 0);
        while ( incount <= 0 )
            incount = vmsread(buffer, 1, 2);
        bufend = &buffer[incount];
        }

    /* If the first char was an ESCAPE, get the characters from an
       escape sequence (eg pressing a key that generates such a
       sequence).  If it was a plain old escape, the vmsread() call
       will return TIMEOUT.
    */
    if (*bufptr == '\x1B' )
        {
        incount = vmsread( bufend, (BUFFLEN - 1), 0 );
        if (incount >= 0)
        bufend += incount ;
    }

    /* Make sure the buffer is zero-terminated, since vmsread() 
       doesn't zero-terminate the characters read.
    */
    *bufend = '\0' ;

    /* run through the keypad conversion table to convert keypad
       keys (escape sequences) and other supported escape sequences
       to Larn command characters.
    */
    for ( j = 0; j < MAX_KP_CONV ; j++ )
        if (strcmp( &buffer, keypad_conv[j].inp_str ) == 0 )
            {
        strcpy( &buffer, keypad_conv[j].out_str );
        bufend = &buffer[strlen(&buffer)];
        break;
        }

    /* If after running through the table the first character is still
       ESCAPE, then we probably didn't get a match.  Force unsupported
       keys that generate escape sequences to just return an ESCAPE.
       Effectively prevents key translations that generate escape
       sequences.
    */
    if (*bufptr == '\x1B' )
        {
    bufend = &buffer[1] ;
    }
    *bufend = '\0' ;

    if (*bufptr == '\r')
        *bufptr = '\n';

    return (*bufptr++ & 0xFF);
    }

typedef struct 
    {
    short int    status;
    short int    term_offset;
    short int    terminator;
    short int    term_size;
    } IOSTAB;

int vmsread(buffer, size, timeout)
char       *buffer;
int        size;
int        timeout;
    {

#define TIMEOUT (-2)
#define ERROR   (-1)

    extern int        iochan;

    register int      status;
    IOSTAB            iostab;
    static long       termset[2] = { 0, 0 };      /* No terminator    */

    status = SYS$QIOW( 
            0,               /* Event flag             */
            iochan,          /* Input channel        */
            IO$_READLBLK | IO$M_NOFILTR | IO$M_TIMED,
                             /* Read, no echo, no translate    */
            &iostab,         /* I/O status block        */
            NULL,            /* AST block (none)        */
            0,               /* AST parameter        */
            buffer,          /* P1 - input buffer        */
            size,            /* P2 - buffer length        */
            timeout,         /* P3 - timeout            */
            &termset,        /* P4 - terminator set        */
            NULL,            /* P5 - ignored (prompt buffer)    */
            0                /* P6 - ignored (prompt size)    */
            );
    if (status == SS$_TIMEOUT)
        return (TIMEOUT);
    else if (status != SS$_NORMAL)
        return (ERROR);
    else 
        {
        if ((status = iostab.term_offset + iostab.term_size) > 0)
            return (status);
        return (TIMEOUT);
        }
    }

#endif VMS
