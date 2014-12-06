/* fortune.c */
#ifdef VMS
#include <types.h>
#include <stat.h>
#include <file.h>
#else
# include <sys/types.h>
# include <sys/stat.h>
# ifndef BSD4.1
#  include <fcntl.h>
# else BSD4.1
# define O_RDONLY 0
# endif BSD4.1
#endif VMS

#include "header.h"
#include "player.h"
#include "larndefs.h"
extern char fortfile[];

outfortune()
    {
    char *p;

    lprcat("\nThe cookie was delicious.");
    if (c[BLINDCOUNT])
        return;
#ifdef MSDOS
    msdosfortune();
#else
    if (p=fortune(fortfile))
        {
        lprcat("  Inside you find a scrap of paper that says:\n");
        lprcat(p);
        }
#endif
    }

# ifdef MSDOS
# include <stdio.h>
/* Rumors has been entirely rewritten to be disk based.  This is marginally
 * slower, but requires no mallocked memory.  Notice this in only valid for
 * files smaller than 32K.
 */
static int fortsize = 0;

static msdosfortune()
{
    int fd, status, i;
    char    buf[BUFSIZ], ch;

    if (fortsize < 0)   /* We couldn't open fortunes */
        return;
    if ((fd = open(fortfile, O_RDONLY | O_BINARY)) >= 0) {
        if (fortsize == 0)
            fortsize = (int) lseek(fd, 0L, 2);
        if (lseek(fd, (long) rund(fortsize), 0) < 0)
            return;

        /* Skip to next newline or EOF
         */
        do {
            status = read(fd, &ch, 1);
        } while (status != EOF && ch != '\n');
        if (status == EOF)
            if (lseek(fd, 0L, 0) < 0) /* back to the beginning */
                return;

        /* Read in the line.  Search for CR ('\r'), not NL
         */
        for (i = 0; i < BUFSIZ - 1; i++)
            if (read(fd, &buf[i], 1) == EOF || buf[i] == '\r')
                break;
        buf[i] = '\0';

        /* And spit it out
         */
        lprcat("  Inside you find a scrap of paper that says:\n");
        lprcat(buf);
        close(fd);
    } else
        fortsize = -1;  /* Don't try opening it again */
}

# else

/*
 *  function to return a random fortune from the fortune file
 */
static char *base=0;    /* pointer to the fortune text */
static char **flines=0; /* array of pointers to each fortune */
static int fd=0;    /* true if we have load the fortune info */
static int nlines=0;    /* # lines in fortune database */

static char *fortune(file)
char *file;
{
    register char *p;
    register int lines,tmp;
    struct stat stat;
    void *malloc();

    if (fd == 0) {
        if ((fd=open(file,O_RDONLY)) < 0)   /* open the file */
            return(0); /* can't find file */

        /* find out how big fortune file is and get memory for it */
        stat.st_size = 16384;
        if ((fstat(fd,&stat) < 0)
        || ((base=(char *)malloc(1+stat.st_size)) == 0)) {
            close(fd);
            fd= -1;
            free((char*)base);
            return(0);  /* can't stat file */
        }

        /* read in the entire fortune file */
#ifdef VMS
        /*
         * fstat lies about the size (each record has up to
         * three bytes of fill reported as actual size).
         * vread returns correct size.
         */
        stat.st_size = vread(fd,base,stat.st_size);
        if (stat.st_size <= 0)
#else
        if (vread(fd,base,stat.st_size) != stat.st_size)
#endif
        {
            close(fd);
            fd= -1;
            free((char*)base);
            return(0);  /* can't read file */
        }
        close(fd);
        base[stat.st_size]=0;   /* final NULL termination */

        /* count up all the lines (and 0 terminate) to know memory
         * needs
         */
        for (p=base,lines=0; p<base+stat.st_size; p++) /* count lines */
            if (*p == '\n') *p=0,lines++;
        nlines = lines;

        /* get memory for array of pointers to each fortune */
        if ((flines=(char**)malloc(nlines*sizeof(char*))) == 0) {
            free((char*)base);
            fd= -1;
            return(0); /* malloc() failure */
        }

        /* now assign each pointer to a line */
        for (p=base,tmp=0; tmp<nlines; tmp++)
            {
            flines[tmp]=p;  while (*p++); /* advance to next line */
            }
    }

    if (fd > 2) /* if we have a database to look at */
        return(flines[rund((nlines<=0)?1:nlines)]);
    else
        return(0);
}
# endif
