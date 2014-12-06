/************************************************************************
 *                                  *
 *          Copyright (c) 1982, Fred Fish           *
 *              All Rights Reserved             *
 *                                  *
 *  This software and/or documentation is released for public   *
 *  distribution for personal, non-commercial use only.     *
 *  Limited rights to use, modify, and redistribute are hereby  *
    bp = _tcpbuf;
    while ((bp = index(bp,':')) != NULL) {
    bp++;
    if (*bp++ == id[0] && *bp != NULL && *bp++ == id[1]) {
        if (*bp != NULL && *bp++ != '=') {
        return(NULL);
        } else {
        return(decode(bp,area));
        }
    }
    }
    return(NULL);
}

/*
 *  INTERNAL FUNCTION
 *
 *  decode   transfer string capability, decoding escapes
 *
 *  SYNOPSIS
 *
 *  static char *decode(bp,area)
 *  char *bp;
 *  char **area;
 *
 *  DESCRIPTION
 *
 *  Transfers the string capability, up to the next ':'
 *  character, or null, to the buffer pointed to by
 *  the pointer in *area.  Note that the initial
 *  value of *area and *area is updated to point
 *  to the next available location after the null
 *  terminating the transfered string.
 *
 *  BUGS
 *
 *  There is no overflow checking done on the destination
 *  buffer, so it better be large enough to hold
 *  all expected strings.
 *
 */

/*
 *  PSEUDO CODE
 *
 *  Begin decode
 *      Initialize the transfer pointer.
 *      While there is an input character left to process
 *      Switch on input character
 *      Case ESCAPE:
 *          Decode and xfer the escaped sequence.
 *          Break
 *      Case CONTROLIFY:
 *          Controlify and xfer the next character.
 *          Advance the buffer pointer.
 *          Break
 *      Default:
 *          Xfer a normal character.
 *      End switch
 *      End while
 *      Null terminate the output string.
 *      Remember where the output string starts.
 *      Update the output buffer pointer.
 *      Return pointer to the output string.
 *  End decode
 *
 */

static char *decode(bp,area)
char *bp;
char **area;
{
    char *cp, *bgn;
    char *do_esc();

    cp = *area;
    while (*bp != NULL && *bp != ':') {
    switch(*bp) {
    case '\\':
        bp = do_esc(cp++,++bp);
        break;
    case '^':
        *cp++ = *++bp & 037;
        bp++;
        break;
    default:
        *cp++ = *bp++;
        break;
    }
    }
    *cp++ = (char) NULL;
    bgn = *area;
    *area = cp;
    return(bgn);
}

/*
 *  INTERNAL FUNCTION
 *
 *  do_esc    process an escaped sequence
 *
 *  SYNOPSIS
 *
 *  char *do_esc(out,in);
 *  char *out;
 *  char *in;
 *
 *  DESCRIPTION
 *
 *  Processes an escape sequence pointed to by
 *  in, transfering it to location pointed to
 *  by out, and updating the pointer to in.
 *
 */

/*
 *  PSEUDO CODE
 *
 *  Begin do_esc
 *      If the first character is not a NULL then
 *      If is a digit then
 *          Set value to zero.
 *          For up to 3 digits
 *              Accumulate the sum.
 *          End for
 *          Transfer the sum.
 *          Else if character is in remap list then
 *          Transfer the remapped character.
 *          Advance the input pointer once.
 *          Else
 *          Simply transfer the character.
 *          End if
 *      End if
 *      Return updated input pointer.
 *  End do_esc
 *
 */

static char *maplist = {
    "E\033b\bf\fn\nr\rt\t"
};

char *do_esc(out,in)
char *out;
char *in;
{
    int count;
    char ch;
    char *cp;

    if (*in != NULL) {
    if (isdigit(*in)) {
        ch = 0;
        for (count = 0; count < 3 && isdigit(*in); in++) {
         ch <<= 3;
         ch |= (*in - '0');
        }
        *out++ = ch;
    } else if ((cp = index(maplist,*in)) != NULL) {
        *out++ = *++cp;
        in++;
    } else {
        *out++ = *in++;
    }
    }
    return(in);
}
