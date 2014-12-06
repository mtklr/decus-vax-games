/************************************************************************
 *                                  *
 *          Copyright (c) 1982, Fred Fish           *
 *              All Rights Reserved             *
 *                                  *
 *  This software and/or documentation is released for public   *
 *  distribution for personal, non-commercial use only.     *
 *  Limited rights to use, modify, and redistribute are hereby  *
 *  granted for non-commercial purposes, provided that all      *
 *  copyright notices remain intact and all changes are clearly *
 *  documented.  The author makes no warranty of any kind with  *
 *  respect to this product and explicitly disclaims any implied    *
 *  warranties of merchantability or fitness for any particular *
 *  purpose.                            *
 *                                  *
 ************************************************************************
 */


/*
 *  LIBRARY FUNCTION
 *
 *  tputs     output string with appropriate padding
 *
 *  KEY WORDS
 *
 *  termcap
 *
 *  SYNOPSIS
 *
 *  tputs(cp,affcnt,outc)
 *  char *cp;
 *  int affcnt;
 *  int (*outc)();
 *
 *  DESCRIPTION
 *
 *  Outputs string pointed to by cp, using function outc, and
 *  following it with the appropriate number of padding characters.
 *  Affcnt contains the number of lines affected, which is used
 *  as a multiplier for the specified per line pad time.  If
 *  per line pad count is not applicable, affcnt should be 1,
 *  NOT zero.
 *
 *  The format of the string pointed to by cp is:
 *
 *      [pad time][*]<string to send>
 *
 *      where:  pad time => time to delay in milliseconds
 *          * => specifies that time is per line
 *          
 *  The pad character is assumed to reside in the external
 *  variable "PC".  Also, the external variable "ospeed"
 *  should contain the output speed of the terminal as
 *  encoded in /usr/include/sgtty.h  (B0-B9600).
 *
 *  BUGS
 *
 *  Digit conversion is based on native character set
 *  being ASCII.
 *
 */

/*
 *  Miscellaneous stuff
 */

#include <stdio.h>
#include <ctype.h>

# ifndef MSDOS
extern char PC;         /* Pad character to use */
extern char ospeed;     /* Encoding of output speed */

static int times[] = {
    0,              /* Tenths of ms per char 0 baud */
    2000,           /* Tenths of ms per char 50 baud */
    1333,           /* Tenths of ms per char 75 baud */
    909,            /* Tenths of ms per char 110 baud */
    743,            /* Tenths of ms per char 134 baud */
    666,            /* Tenths of ms per char 150 baud */
    500,            /* Tenths of ms per char 200 baud */
    333,            /* Tenths of ms per char 300 baud */
    166,            /* Tenths of ms per char 600 baud */
    83,             /* Tenths of ms per char 1200 baud */
    55,             /* Tenths of ms per char 1800 baud */
    41,             /* Tenths of ms per char 2400 baud */
    20,             /* Tenths of ms per char 4800 baud */
    10              /* Tenths of ms per char 9600 baud */
};
# endif


/*
 *  PSEUDO CODE
 *
 *  Begin tgoto
 *      If string pointer is invalid then
 *      Return without doing anything.
 *      Else
 *      For each pad digit (if any)
 *          Do decimal left shift.
 *          Accumulate the lower digit.
 *      End for
 *      Adjust scale to tenths of milliseconds
 *      If there is a fractional field
 *          Skip the decimal point.
 *          If there is a valid tenths digit
 *          Accumulate the tenths.
 *          End if
 *          Discard remaining digits.
 *      End if
 *      If per line is specified then
 *          Adjust the pad time.
 *          Discard the per line flag char.
 *      End if
 *      While there are any characters left
 *          Send them out via output function.
 *      End while
 *      Transmit any padding required.
 *      End if
 *  End tgoto
 *
 */

tputs(cp,affcnt,outc)
char *cp;
int affcnt;
int (*outc)();
{
    int ptime;          /* Pad time in tenths of milliseconds */

    if (cp == NULL || *cp == NULL) {
    return;
    } else {
    for (ptime = 0; isdigit(*cp); cp++) {
        ptime *= 10;
        ptime += (*cp - '0');
    }
    ptime *= 10;
    if (*cp == '.') {
        cp++;
        if (isdigit(*cp)) {
        ptime += (*cp++ - '0');
        }
        while (isdigit(*cp)) {cp++;}
    }
    if (*cp == '*') {
        ptime *= affcnt;
        cp++;
    }
    while (*cp != NULL) {
        (*outc)(*cp++);
    }
# ifndef MSDOS
# ifndef VMS
    do_padding(ptime,outc);
# endif
# endif
    }
}

# ifndef MSDOS
/*
 *  FUNCTION
 *
 *  do_padding    transmit any pad characters required
 *
 *  SYNOPSIS
 *
 *  static do_padding(ptime,outc)
 *  int ptime;
 *  int (*outc)();
 *
 *  DESCRIPTION
 *
 *  Does any padding required as specified by ptime (in tenths
 *  of milliseconds), the output speed given in the external
 *  variable ospeed, and the pad character given in the
 *  external variable PC.
 *
 */

/*
 *  PSEUDO CODE
 *
 *  Begin do_padding
 *      If there is a non-zero pad time then
 *      If the external speed is in range then
 *          Look up the delay per pad character.
 *          Round pad time up by half a character.
 *          Compute number of characters to send.
 *          For each pad character to send
 *          Transmit the pad character.
 *          End for
 *      End if
 *      End if
 *  End do_padding
 *
 */

static do_padding(ptime,outc)
int ptime;
int (*outc)();
{
    register int nchars;
    register int tpc;

    if (ptime != 0) {
    if (ospeed > 0 && ospeed <= (sizeof(times)/ sizeof(int))) {
        tpc = times[ospeed];
        ptime += (tpc / 2);
        nchars = ptime / tpc;
        for ( ; nchars > 0; --nchars) {
        (*outc)(PC);
        }
    }
    }
}
# endif
