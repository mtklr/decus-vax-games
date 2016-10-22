#define REGULAR		6		/* Game type */
#define DIFFICULT	8		/* Game type */
#define MASTER		10		/* Game type */
#define MAXCOLORS   	10		/* Max number of colors */

#define TRUE 		1
#define FALSE 		0

WINDOW *dsp_main, *dsp_pegs, *dsp_help, *dsp_score, *dsp_text;

int random_incl, random_seed;		/* for random functions */

int game;				/* Difficult or Master  or Regular */
double wins, losses, pcnt;		/* Number of wins, losses, and win % */
int cur_row, cur_col;			/* Cursor position */
int score_row;

/* 10 colors are: red, yellow, green, blue, black, white, orange, tan, brown, 
	       purple */
char colors[MAXCOLORS+1] = {"RYGUKWOTBP"};
char *names[MAXCOLORS] = {
  "Rd", "Yl", "Gn", "Bu", "Bk", "Wt", "Or", "Tn", "Br", "Pp"
};
int used[MAXCOLORS];

char pegs[4];		/* black and white clue pegs given by computer */
char guess[4];		/* player's guess of 4 colors */
char code[4];		/* computer code of 4 colors */

char *helptext[] = {
"            MasterMind",
" ",
"           Standard Game:",
" R - select RED      Y - select YELLOW",
" U - select BLUE     K - select BLACK",
" W - select WHITE    G - select GREEN",
" ",
"    Difficult Game: (2 added colors)",
" O - select ORANGE   T - select TAN",
" ",
"     Master Game: (4 added colors)",
" B - select BROWN    P - select PURPLE",
" ",
" Control-R & Control-L redraw",
"    Control-Z exits game",
" <return> selects 4-color sequence",
"         and compares to computer code",
" ",
" Clue pegs:",
" X = correct color, correct position",
" o = correct color, incorrect position",
NULL /* End help listing */
};
