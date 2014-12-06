/*
	I got this off net.sources from Henry Spencer.
	It is a public domain getopt(3) like in System V.
	I have made the following modifications:

	index(s,c) was added because too many people could
	not compile getopt without it.

	A test main program was added, ifdeffed by STANDALONE.
	This main program is a public domain implementation
	of the getopt(1) program like in System V.  The getopt
	program can be used to standardize shell option handling.
		e.g.  cc -DSTANDALONE getopt.c -o getopt
*/
#include <stdio.h>

#ifndef lint
static	char	sccsfid[] = "@(#) getopt.c 5.0 (UTZoo) 1985";
#endif

#define	ARGCH    (int)':'
#define BADCH	 (int)'?'
#define EMSG	 ""
#define	ENDARGS  "--"

/* this is included because index is not on some UNIX systems */
static
char *
index (s, c)
register	char	*s;
register	int 	c;
	{
	while (*s)
		if (c == *s) return (s);
		else s++;
	return (NULL);
	}

/*
 * get option letter from argument vector
 */
int	opterr = 1,		/* useless, never set or used */
	optind = 1,		/* index into parent argv vector */
	optopt;			/* character checked for validity */
char	*optarg;		/* argument associated with option */

#define tell(s)	fputs(*nargv,stderr);fputs(s,stderr); \
		fputc(optopt,stderr);fputc('\n',stderr);return(BADCH);


getopt(nargc,nargv,ostr)
int	nargc;
char	**nargv,
	*ostr;
{
	static char	*place = EMSG;	/* option letter processing */
	register char	*oli;		/* option letter list index */
	char	*index();

	if(!*place) {			/* update scanning pointer */
		if(optind >= nargc || *(place = nargv[optind]) != '-' || !*++place) return(EOF);
		if (*place == '-') {	/* found "--" */
			++optind;
			return(EOF);
		}
	}				/* option letter okay? */
	if ((optopt = (int)*place++) == ARGCH || !(oli = index(ostr,optopt))) {
		if(!*place) ++optind;
		tell(": illegal option -- ");
	}
	if (*++oli != ARGCH) {		/* don't need argument */
		optarg = NULL;
		if (!*place) ++optind;
	}
	else {				/* need an argument */
		if (*place) optarg = place;	/* no white space */
		else if (nargc <= ++optind) {	/* no arg */
			place = EMSG;
			tell(": option requires an argument -- ");
		}
	 	else optarg = nargv[optind];	/* white space */
		place = EMSG;
		++optind;
	}
	return(optopt);			/* dump back option letter */
}


#ifdef STANDALONE

#ifndef lint
static	char	sccspid[] = "@(#) getopt.c 5.1 (WangInst) 6/15/85";
#endif

main (argc, argv) char **argv;
	{
	char	*optstring = argv[1];
	char	*argv0 = argv[0];
	extern	int 	optind;
	extern	char	*optarg;
	int 	opterr = 0;
	int 	C;
	char	*opi;
	if (argc == 1)
		{
		fprintf (stderr, "Usage: %s optstring args\n", argv0);
		exit (1);
		}
	argv++;
	argc--;
	argv[0] = argv0;
	while ((C = getopt (argc, argv, optstring)) != EOF)
		{
		if (C == BADCH) opterr++;
		printf ("-%c ", C);
		opi = index (optstring, C);
		if (opi && opi[1] == ARGCH)
			if (optarg)
				printf ("\"%s\" ", optarg);
			else opterr++;
		}
	printf ("%s", ENDARGS);
	while (optind < argc)
		printf (" \"%s\"", argv[optind++]);
	putchar ('\n');
	exit (opterr);
	}

#endif
