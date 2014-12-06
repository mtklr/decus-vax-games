/*
** Written by Stephan Dasia.
**
** permission is granted to freely distribute this code provided that you:
**
** 1) don't charge for it
** 2) leave my name and header on it
** 3) clearly document your changes and place your name on them
** 4) and please send the changes to me
**
*/
/* Shuffle: shuffle.h							*/
/*									*/
/* this is the header file, it does all the necessary includes.		*/


#include <stdio.h>
#include <math.h>
#include <curses.h>

/* Here start the definitions of the random generator. I've used an	*/
/* other random generator which is declared in xrand.c.			*/  

#define RANDOM1		rnd_i
#define RANDOM2		rnd_init

/* Here are the definitions of MAXLEVEL, be sure that the last number	*/
/* of MAXLEVEL is a 0.							*/

#define FAC1		5
#define FAC2		1.1
#define MAXLEVEL 	1000
#define MAXCOMP_L	5000	/* MAXLEVEL*FAC1			*/
#define MAXPLAY_L	5500	/* MAXCOMP_L*FAC2			*/
