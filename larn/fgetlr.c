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
 *  fgetlr    get logical record from a file
 *
 *  KEY WORDS
 *
 *  fgetlr
 *  string functions
 *
 *  SYNOPSIS
 *
 *  char *fgetlr(bp,bpsize,fp)
 *  char *bp;
 *  int bpsize;
 *  FILE *fp;
 *
 *  DESCRIPTION
 *
 *  Reads the next logical record from stream "fp" into buffer "bp"
 *  until next unescaped newline, "bpsize" minus one characters
 *  have been read, end of file, or read error.
 *  The last character read is followed by a NULL.
 *
 *  A logical record may span several physical records by having
 *  each newline escaped with the standard C escape character
 *  (backslash).
 *
 *  This is particularly useful for things like the termcap
 *  file, where a single entry is too long for one physical
 *  line, yet needs to be treated as a single record.
 *
 *  Returns its first argument unless an end of file or read
 *  error occurs prior to any characters being read.
 *
 *  BUGS
 *
 *  The only way to know if read was terminated due to buffer size
 *  limitation is to test for a newline before the terminating
 *  null.
 *
 */

#include <stdio.h>

/*
 *  PSEUDO CODE
 *
 *  Begin fgetlr
 *      If read fails then
 *      Return NULL.
 *      Else
 *      Find out how many characters were read.
 *      Initialize pointer to terminating null.
 *      If last char read was newline then
 *          If newline was escaped then
 *          Replace backslash with the newline.
 *          Replace newline with null.
 *          Read and append more.
 *          End if
 *      End if
 *      Return buffer pointer.
 *      End if
 *  End fgetlr
 *
 */

char *fgetlr(bp,bpsize,fp)
char *bp;
int bpsize;
FILE *fp;
{
    int numch;
    char *cp;

    if (fgets(bp,bpsize,fp) == NULL) {
    return(NULL);
    } else {
    numch = strlen(bp);
    cp = &bp[numch];
    if (*--cp == '\n') {
        if (numch > 1 && *--cp == '\\') {
        *cp++ = '\n';
        *cp = (char) NULL;
        fgetlr(cp,bpsize-numch+1,fp);
        }
    }
    return(bp);
    }
}
