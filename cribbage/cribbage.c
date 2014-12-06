/*		cribbage.c		*/

/*  Play the computer in the game of cribbage!  */

/* (C) 1985 - Dave Taylor: ihnp4!hpfcla!d_taylor  - or -  hplabs!hpcnof!dat */

/* Cribbage display board added by:
 * Chris Yoder ->	(ihnp4|allegra)!scgvaxd!engvax!chris    or
 *			engvax!chris@csvax.caltech.edu
 * Hughes Aircraft Company
 * Space and Communications Group
 * Computing Technology Center
 * Feb. 1986
 */

#include <stdio.h>
#include curses /* For display routines. */

#define swap(a,b)	{ int c; c = b; b = a; a = c; }
#define suite(n)	(int) (n-1) / 13
#define plural(n)	n == 1? "" : "s"
#define merge(hand,c)	hand.card[4] = c; order(&hand, 5)
#define pick_card()	deck[top_of_deck++]

#define add_points(who,n)	{ points[who] += n; peg(who,n); \
				  if (points[who] >= limit) winner(who); }

#define save(base, a,b,c,d) 	{ base.card[0] = my_hand.card[a]; \
	                          base.status[0] = AVAILABLE; \
                                  base.card[1] = my_hand.card[b]; \
	                          base.status[1] = AVAILABLE; \
			          base.card[2] = my_hand.card[c]; \
	                          base.status[2] = AVAILABLE; \
                                  base.card[3] = my_hand.card[d]; \
	                          base.status[3] = AVAILABLE; }

#define show_played_cards	0

#define DECKSIZE 	52
#define CRIB		2
#define YOU		1
#define ME		0

#define LONG_FORM	0	/* for card format output */
#define SHORT_FORM	1
#define QUIET		0	/* compute point sum */
#define EXPLAIN		1

#define PLAYED  	1	/* card played yet? */
#define AVAILABLE 	0
#define DISCARDED      (-1)

#define ACE		1
#define JACK		11
#define QUEEN		12
#define KING		13

struct card_hand {
	 int card[6];
	 int status[6];
       };

struct card_hand my_hand, your_hand, crib_hand;

int  deck[DECKSIZE], top_of_deck, limit;
int  points[] = {0, 0};
int  whose_crib, show_counting = 0, starter;

int	my_for_peg =  0, your_for_peg =  0; /* These for display purposes. */
int	my_bck_peg = -1, your_bck_peg = -1; /* -cy */

WINDOW	*board_win, *i_o_win; /* Main windows. */

#define YOUR_CARD_EDGE  0
#define YOUR_CARD_TOP   8
#define MY_CARD_EDGE   18
#define MY_CARD_TOP     8
#define CRIB_CARD_EDGE whose_crib == ME? MY_CARD_EDGE : YOUR_CARD_EDGE
#define CRIB_CARD_TOP  18
#define BOARD_TOP       0
#define BOARD_EDGE      0
#define I_O_TOP         0
#define I_O_EDGE       40

#define VISIBLE		1
#define INVISIBLE	0

WINDOW	*your_card_win[7], *my_card_win[7], *crib_card_win; 
/* Card display windows. */

/* End of display purposes. */

char *say(), *say_card();

main(argc, argv)
int argc;
char *argv[];
{
	extern char *optarg;
	extern int   opterr;
	register int i=0, j;
	int      c;

	limit  = 121;	/* default counting limit for game (in orig = 150) */
	opterr = 0;	/* suppress the 'getopt' error messages */

	while ((c = getopt(argc, argv, "l:v")) != EOF)
	  switch (c) {
	    case 'l' : sscanf(optarg, "%d", &limit);
		       if (limit < 11) 
			 exit(printf("** Limit must be greater than 10! **\n"));
		       if (limit > 121)
			 exit(printf("** Limit must not be greater than 121! **\n"));
		       break;
	    case 'v' : show_counting++;		
		       break;
	    default  : exit(printf("Usage: %s [-v] [-l limit]\n", argv[0]));
	  }

	setup_screen();

	wprintw(i_o_win,"\n              Cribbage 1.2\n\n");

	wprintw(i_o_win,"We are playing up to %s points.\nGood luck!\n\n",
		say(limit));

	srand(time(0));
	whose_crib = rand() % 2;

	do {
	  shuffle();
	  wprintw(i_o_win,"\nIt's %s crib...\n\n", whose_crib==ME? "my" : "your");
	  wrefresh(i_o_win);
	  deal_cards();
	  display_hand(your_hand, 6, VISIBLE, YOU);
	  pick_crib();
	  player_add_to_crib();
	
	  /** pick the starter card! **/

	  starter = pick_card();
	  make_card (&crib_card_win,say_card(starter,SHORT_FORM),
		    CRIB_CARD_TOP,CRIB_CARD_EDGE);
	  wprintw(i_o_win,"\nThe starter is the %s",say_card(starter,LONG_FORM));
	  if (rank(starter) == JACK) {
	    wprintw(i_o_win,"\nfor two ('his heels').\n");
	    add_points(whose_crib, 2);
	  }
	  wprintw(i_o_win,".\n");
	  wrefresh(i_o_win);

	  play(! whose_crib);
	  wprintw(i_o_win,"\nOkay, let's count up!  (Recall the \nstarter is the %s)\n\n",
	         say_card(starter, LONG_FORM));
	  wrefresh(i_o_win);
	  total_points(whose_crib);
	  wprintw(i_o_win,"\nYou have %d points and I have %d points\n",
                  points[YOU], points[ME]);
	  wrefresh(i_o_win);
	  whose_crib = ! whose_crib;
	  delwin (crib_card_win);
	} while (1);
    cleanup();
}

shuffle()
{
	/* shuffle the 52 random integers into deck.. */
	register int i, j;

	for (i=0;i<DECKSIZE;i++) deck[i] = i+1;
	/** shuffle the deck once... **/
	for (i=DECKSIZE-1;i>1;i--) {
	  j = rand() % i;
	  swap(deck[i], deck[j]);
	}
	/** and do it again for good luck! **/
	for (i=DECKSIZE-1;i>1;i--) {
	  j = rand() % i;
	  swap(deck[i], deck[j]);
	}
	top_of_deck = 0;
}

deal_cards()
{
	/* deal cards out: six per player */
	register int i;
	int offset;

	for (i=0;i<6;i++) {
	  your_hand.card[i]   = pick_card();
	  your_hand.status[i] = AVAILABLE;
	  my_hand.card[i]     = pick_card();
	  my_hand.status[i]   = AVAILABLE;
	  crib_hand.status[i] = AVAILABLE;	/* all crib cards available! */
	}
	order(&my_hand, 6);	/* sort lowest to highest rank */
	order(&your_hand, 6);	/*   for both hands...         */
	show_hand(your_hand, 6, "You are dealt: ","\n",PLAYED);
}

pick_crib()
{
	/* pick for crib...get best hand(s) and then put remainder
	    in crib.  If other players crib, pick hand with same value
	    that gives them the LEAST points in the two cards (ie try
	    not to be same suite, pairs, fifteens, fives, etc etc) */

	struct card_hand hand[15];
	int worst, hand_to_use, val;
	int i,j,k,l, best=0, possible=0, discard[2];

	for (i=0; i<3; i++)
	  for (j=i+1; j<4; j++)
	    for (k=j+1; k<5; k++)
	      for (l=k+1; l<6; l++) {
	        val = hand_value(my_hand, i, j, k, l, 0, QUIET);
	        if (val > best) {
                  possible=0;
	          save(hand[possible],i,j,k,l);
	          possible++;
	          best = val;
	        }
	        else if (val == best) {
		  save(hand[possible],i,j,k,l);
	          possible++;
		}
	      }

	best = -1; 
	worst = 99;

	if (possible > 1) { /* more than one hand with the same value! */
	  if (whose_crib == ME) { /* our crib! Pick hand with BEST crib cards!*/
	    for (i=0;i<possible;i++) {
	      if ((j = cribval(my_hand, hand[i])) > best) {
	        best = j;
		hand_to_use = i;	/* save this index! */
	      }
	     }
	  }
	  else { /* other players crib. Pick hand with WORST crib cards! */
	    for (i=0;i<possible;i++) {
	      if ((j = cribval(my_hand, hand[i])) < worst) {
	        worst = j;
		hand_to_use = i;	/* save this index! */
	      }
	     }
	 }
        }
        else hand_to_use = 0;	/* ONLY one hand with max points */

	get_exceptions(my_hand, hand[hand_to_use], &discard[0], &discard[1]);

	crib_hand.card[0] = my_hand.card[discard[0]];
	crib_hand.card[1] = my_hand.card[discard[1]];

	my_hand.status[discard[0]] = DISCARDED;
	my_hand.status[discard[1]] = DISCARDED;
	compress(&my_hand);
}


player_add_to_crib()
{
	/** let the player pick two cards to put in the crib.. **/
	char buffer[50];
	int  card1 = 0, card2 = 0, i1,i2, i, okay;

	wprintw(i_o_win,"\n");
	sprintf(buffer,"Discard into %s crib: ", whose_crib==ME?"my":"your");

	do {
	  i1 = -1;	i2 = -1;
	  read_a_card(buffer, 2, &card1, &card2);
	  for (i=0;i<6;i++) {
	         if (your_hand.card[i] == card1) i1 = i;
	    else if (your_hand.card[i] == card2) i2 = i;
	  }
	  if (i1 == -1 && i2 == -1)
	    wprintw(i_o_win,"Neither card is in your hand!\n\n");
	  else if (i1 == -1 || i2 == -1) 
	    wprintw(i_o_win,"The %s isn't in your hand!\n\n",
	    	   say_card(i1 == -1? card1 : card2, LONG_FORM));
	  okay = (i1 != -1 && i2 != -1);
	  wrefresh(i_o_win);
	} while (! okay);

	if (i1>i2) swap(i1,i2); /* Make sure that i1 is < i2. */

	crib_hand.card[2]   = your_hand.card[i1];
	crib_hand.status[2] = AVAILABLE;
	crib_hand.card[3]   = your_hand.card[i2];
	crib_hand.status[3] = AVAILABLE;

	your_hand.status[i1] = DISCARDED;
	your_hand.status[i2] = DISCARDED;
	compress(&your_hand);
	order(&crib_hand, 4);

	remove_card(your_card_win,i1,YOU);
	remove_card(your_card_win,i2-1,YOU);
}

play(turn)
int turn;
{
	/** play the two hands... 'first' is who should discard first.. **/

	int sum, card, cards_played[10], total_cards_played = 0;
	int valid_card, index, a_move, i;

	wprintw(i_o_win,"\nNo cards out..\n");
	wrefresh(i_o_win);
	display_hand(my_hand, 4, INVISIBLE, ME);
	index = 0;
	sum   = 0;

	while (total_cards_played < 8) {
	  a_move = 0;
	  if (turn == ME)
	    {
	      if (stuck(my_hand, sum)) 
	        wprintw(i_o_win,"I can't go!\n");
	      else {
	        card = pick_discard(cards_played, index, sum);
	        wprintw(i_o_win,"I play the %s\n",say_card(card,LONG_FORM));
	        a_move++;
	      }
	      wrefresh(i_o_win);
	    }
	  else if (stuck(your_hand, sum)) 
	    {
	      wprintw(i_o_win,"you can't go!\n");
	      wrefresh(i_o_win);
	    }
	  else {
	    show_hand(your_hand, 4, "Your hand is ","... \n",AVAILABLE);
	    valid_card = 0;
            do {
	      read_a_card("You play the : ",1, &card, &valid_card);
	      if (value_of(card) + sum > 31) {
	        wprintw(i_o_win,"That'll take us over 31!\n");
	        valid_card = 1;
	      }
	      else if ((valid_card = mark_as_played(&your_hand, card, YOU)) != 0)
	        wprintw(i_o_win,"You don't have that card to play!\n");
	      wrefresh(i_o_win);
	    } while (valid_card == 1);
	    a_move++;
	  }

	  if (a_move) {
	    total_cards_played++;
	    add_to_played(turn, card, cards_played, &index, &sum,
                          total_cards_played);
	  }

	  turn = ! turn;
	}
}

total_points(who)
int who;
{
	/** sum up points for each hand... **/

	int points_in_hand;

	if (who == ME) { /* computer crib, so player counts first! */
	  display_hand(your_hand, 4, VISIBLE, YOU);
	  player_counts(your_hand, YOU);
	  display_hand(my_hand, 4, VISIBLE, ME);
	  I_count(my_hand, ME);
	  sleep(3);
	  undisplay_hand(ME);
	  display_hand(crib_hand, 4, VISIBLE, ME);
	  I_count(crib_hand, CRIB);
	  undisplay_hand(YOU);
	  undisplay_hand(ME);
	}
	else { /* player crib...computer counts up */
	  display_hand(my_hand, 4, VISIBLE, ME);
	  I_count(my_hand, ME);
	  display_hand(your_hand, 4, VISIBLE, YOU);
	  player_counts(your_hand, YOU);
	  undisplay_hand(YOU);
	  display_hand(crib_hand, 4, VISIBLE, YOU);
	  player_counts(crib_hand, CRIB);	
	  undisplay_hand(YOU);
	  undisplay_hand(ME);
	}	
}

player_counts(hand, what)
struct card_hand hand;
int what;
{
	/** sum up value of hand...**/

	int value, input_value;
	char line[10];

	if (what == YOU)
          show_hand(hand, 4, "Your hand is ","... \n",PLAYED);
	else
	  show_hand(hand, 4, "Your crib is ","... \n",PLAYED);
	
	merge(hand, starter);
	value = hand_value(hand, 0,1,2,3,4, QUIET);

	wprintw(i_o_win,"How many points? ");
	wrefresh(i_o_win);
	gets(line);
	wprintw(i_o_win,"%s\n",line);
	if (strncmp(line, "qu",2)==0) leave();
	sscanf(line,"%d", &input_value);

	if (input_value > value) {
	  if (value == 0)	
	    wprintw(i_o_win,"\nC'mon!  There aren't any points in that hand!\n");
	  else {
	    (void) hand_value(hand, 0,1,2,3,4, EXPLAIN);
	    wprintw(i_o_win,"\nThat hand's worth exactly %s point%s!!\n",
                   say(value), plural(value));
	  }
	} else if (input_value != value) { /* counted too low! */
	  (void) hand_value(hand, 0,1,2,3,4, EXPLAIN);
	  wprintw(i_o_win,"\n...I counted %s points!  Too bad, eh?\n", say(value));
	  value = input_value;
	}
	wrefresh(i_o_win);
	add_points(YOU, value);
}


I_count(hand, who)
struct card_hand hand;
int who;
{
	/** let the computer count as appropriate.. **/
	int points_in_hand;
	
        if (who == ME) {
          show_hand(my_hand, 4, "My hand is: ", "\n",PLAYED);
	  merge(my_hand, starter);
	  points_in_hand = hand_value(my_hand, 0, 1, 2, 3, 4, QUIET);
	  wprintw(i_o_win,"giving me %s point%s!\n",
                 say(points_in_hand), plural(points_in_hand));
	  add_points(ME, points_in_hand);
	}
	else {
          show_hand(crib_hand, 4, "The crib is: ","... it's worth\n",PLAYED);
	  merge(crib_hand, starter);
	  points_in_hand = hand_value(crib_hand, 0, 1, 2, 3, 4, QUIET);
	  if (points_in_hand == 0)
	    wprintw(i_o_win,"no points!\n");
	  else {
	    wprintw(i_o_win,"an additional %s point%s!\n", 
                   say(points_in_hand), plural(points_in_hand));
	    add_points(ME, points_in_hand);
	  }
	}
      wrefresh(i_o_win);
}


read_a_card(prompt, howmany, card1, card2)
char *prompt;
int howmany, *card1, *card2;
{
	char line[10];
	int  loc, error, cardz[2], val, i;

input:
	wprintw(i_o_win,"%s",prompt);
	wrefresh(i_o_win);
	gets(line);
	wprintw(i_o_win,"%s\n",line);
	wrefresh(i_o_win);
	if (strncmp(line, "qu",2)==0) leave();
	if (line[strlen(line)-1] == '\n') line[strlen(line)-1] = '\0';

	loc = 0;
	i = 0;
	do {
	  error=0;
	  while (line[loc] == ' ' || line[loc] == ',') loc++;
	  if (line[loc] == '\0') 
            error=4;
	  else
	    switch(tolower(line[loc])) {
	      case 'a' : val = ACE;		break;
	      case '1' : if (line[++loc] != '0') error=1;
		         else val=10;	break;
	      case 'j' : val = JACK;	break;
	      case 'q' : val = QUEEN; 	break;	
	      case 'k' : val = KING;	break;
	      default  : if (line[loc] > '1' && line[loc] <= '9')
	 		    val = (int) line[loc] - (int) '0';
		         else
		            error=2;
	    }
	  if (!error) {
	    switch(tolower(line[++loc])) {
	      case 's' : 	break;
	      case 'c' : val += 13;	break;
	      case 'h' : val += 26;	break;
	      case 'd' : val += 39;	break;
	      default  : error=3;
	    }
	  }

	  switch (error) {
	    case 0:	break;		/** all okay! **/
	    case 1: wprintw(i_o_win,"Use 'A' for ace, or '10' for ten card\n");
		    wrefresh(i_o_win);
	            goto input;
	    case 2: wprintw(i_o_win,"Unknown card!  Use same notation as presented!\n");
		    wrefresh(i_o_win);
		    goto input;
	    case 3: wprintw(i_o_win,"Unknown suite!  Use notation above!\n");
		    wrefresh(i_o_win);
		    goto input;
	    case 4: wprintw(i_o_win,"expecting %d card%s...\n",howmany,plural(howmany));	
		    wrefresh(i_o_win);
		    goto input;
	    default: wprintw(i_o_win,"Error %d on input!\n",error);
		     wrefresh(i_o_win);
	             goto input;
	  }
	  loc++;
	  cardz[i++] = val;
	} while (i < howmany);

	*card1 = cardz[0];
	*card2 = cardz[1];
}

int
cribval(full_hand, partial_hand)
struct card_hand full_hand, partial_hand;
{
	/* compute crib value of the two cards in hand */
	int value, card[2], i, j;

	get_exceptions(full_hand, partial_hand, &i, &j);
	
	card[0] = partial_hand.card[i];
	card[1] = partial_hand.card[j];

	value = 0;
	if (value_of(card[0]) + value_of(card[1]) == 15) value++;
	if (value_of(card[0]) ==  5) value++;
	if (value_of(card[1]) ==  5) value++;
	if (rank(card[0]) == rank(card[1])) value++;
	if (suite(card[0]) == suite(card[1])) value++;

	return(value);
}

int
hand_value(hand, c1,c2,c3,c4,c5, verbose)
struct card_hand hand;
int c1,c2,c3,c4,c5, verbose;
{
	/* compute point value of hand returning value.  Verbose lets the 
	   computer enumerate the point computation.. */

	int value = 0, norun=1, i,j,k,l, card[5], cval[5], csuite[5], crank[5];

	/** only use flag if final counting up! **/
	if (c5 != 0 && show_counting) verbose++;

	card[0] = hand.card[c1];
	card[1] = hand.card[c2];
	card[2] = hand.card[c3];
	card[3] = hand.card[c4];
	card[4] = hand.card[c5];

	for (i=0; i<5; i++) {
	  cval[i]   = value_of(card[i]);
	  crank[i]  = rank(card[i]);
	  csuite[i] = suite(card[i]);
	}

	if (c5 == 0) { 	/* not here - set to all unmatching values! */
	  cval[4]   = -1;
 	  crank[4]  = -1;
	  csuite[4] = -1;
	}

	if (verbose)
	  {
	    wprintw(i_o_win,"\nI score this hand as:\n");
	    wrefresh(i_o_win);
	  }

	/* first off, let's compute all point values of two card combos.. */

	for (i=0; i<4; i++)
	  for (j=i+1; j<5; j++) {
	    if (cval[i] + cval[j] == 15) {
              value += 2; 
	      if (verbose)
		{
		  wprintw(i_o_win,"two-card fifteen: %s\n", say(value));
		  wrefresh(i_o_win);
		}
	    }
	    else if (crank[i] == crank[j]) {
	      value += 2; 
	      if (verbose)
		{
		  wprintw(i_o_win,"a pair: %s\n", say(value));
		  wrefresh(i_o_win);
		}
	    }
	  }

	/* now three card fifteens... */

	for (i=0; i<3; i++)
	  for (j=i+1; j<4; j++) 
	    for (k=j+1; k<5; k++) {
	      if ((cval[i]+cval[j]+cval[k]) == 15) 
	        if (c5 || k != 4) {
	          value += 2;
	          if (verbose)
		    {
		      wprintw(i_o_win,"a three-card fifteen: %s\n", say(value));
		      wrefresh(i_o_win);
		    }
	        }
	    }

	/* check for a four-card 15 combination (pretty unlikely!) */

	for (i=0; i<2; i++)
	  for (j=i+1; j<3; j++) 
	    for (k=j+1; k<4; k++)
	      for (l=k+1;l<5; l++) 
	        if (cval[i]+cval[j]+cval[k]+cval[l] == 15) 
	          if (c5 || l != 4) {
	            value += 2;
	            if (verbose)
		      {
			wprintw(i_o_win,"four-card fifteen: %s\n", say(value));
			wrefresh(i_o_win);
		      }
	          }

	/* check for a five-card 15 combination! (fat chance!) */

	if (cval[0]+cval[1]+cval[2]+cval[3]+cval[4] == 15) 
	  if (c5) {
	    value += 2;
	    if (verbose)
	      {
		wprintw(i_o_win,"five-card fifteen: %s\n", say(value));
		wrefresh(i_o_win);
	      }
	  }
	
	/* check for five card run.. */

	if ((crank[0]+1 == crank[1]) && (crank[1]+1 == crank[2]) &&
	    (crank[2]+1 == crank[3]) && (crank[3]+1 == crank[4])) {
	  value += 5;
	  norun--;
	  if (verbose)
	    {
	      wprintw(i_o_win,"a run of five: %s\n", say(value));
	      wrefresh(i_o_win);
	    }
        }

	/* check for four card run.. */

	else {
	  for (i=0; i<2; i++)
	    for (j=i+1; j<3; j++) 
	      for (k=j+1; k<4; k++) 
	        for (l=k+1; l<5; l++)
	         if ((crank[i]+1 == crank[j]) && (crank[j]+1 == crank[k]) &&
	             (crank[k]+1 == crank[l])) {
	           value += 4;
	           norun--;
	           if (verbose)
		     {
		       wprintw(i_o_win,"a run of four: %s\n",say(value));
		       wrefresh(i_o_win);
		     }
	    	 }      
	}

	/* then check for three card run */

	if (norun == 1)  
	  for (i=0; i<3; i++)
	    for (j=i+1; j<4; j++) 
	      for (k=j+1; k<5; k++) 
	         if ((crank[i]+1 == crank[j]) && (crank[j]+1 == crank[k])) {
	           value += 3;
	           if (verbose)
		     {
			wprintw(i_o_win,"a run of three: %s\n",say(value));
			wrefresh(i_o_win);
		     }
	         }

	/* and finally check for flush! */
	
	/** five card? **/

	if ((csuite[0] == csuite[1]) && (csuite[1] == csuite[2]) &&
            (csuite[2] == csuite[3]) && (csuite[3] == csuite[4]))  {
	      value += 5;
	      if (verbose)
		{
		  wprintw(i_o_win,"five card flush: %s\n",say(value));
		  wrefresh(i_o_win);
		}
	}
	else {
	  for (i=0; i<2; i++)
	    for (j=i+1; j<3; j++) 
	      for (k=j+1; k<4; k++) 
	        for (l=k+1; l<5; l++)
	          if ((csuite[i] == csuite[j]) && (csuite[j] == csuite[k]) &&
	              (csuite[k] == csuite[l])) 
	              if (suite(starter) != csuite[i]) { /* not starter? */
	                value += 4;
	                if (verbose)
			  {
			    wprintw(i_o_win,"four card flush: %s\n",say(value));
			    wrefresh(i_o_win);
			  }
	              }
	}

	/** one final check: if all five cards are given to the program 
	    (indicating final counting) AND the hand contains a jack that
	    is of the same suite as the starter, add a point for 'his nobs' **/

	if (c5) 
	  for (i=0;i<5;i++)
	    if (crank[i] == JACK)
	      if (csuite[i] == suite(starter) && card[i] != starter) {
	        value += 1;
		if (verbose)
		  {
		    wprintw(i_o_win,"and one for his nobs: %s\n", say(value));
		    wrefresh(i_o_win);
		  }
	      }

	return(value);
}

show_hand(hand, max, prefix, suffix, alt_stat)
struct card_hand hand;
int max, alt_stat;
char *prefix, *suffix;
{
	/** display hand on one line... **/
	register int i;

	wprintw(i_o_win,"%s",prefix);
	for (i=0;i<max;i++) 
	  if (hand.status[i] == AVAILABLE || hand.status[i] == alt_stat)
	    wprintw(i_o_win,"%s ",say_card(hand.card[i],SHORT_FORM));
	  else if (show_played_cards)
	    wprintw(i_o_win,"(%s) ",say_card(hand.card[i],SHORT_FORM));
	wprintw(i_o_win,"%s",suffix);
	wrefresh(i_o_win);
}

char *say_card(n, pw)
int n, pw;
{
	/* display card 'n'.  PW = Partial Word flag... */

	static char buffer[40];
	register int r;
	char temp[15];
	
	switch ((r = rank(n))) {
	  case ACE  : strcpy(buffer,pw?"A":"Ace"); 	break;
	  case JACK : strcpy(buffer,pw?"J":"Jack");	break;
	  case QUEEN: strcpy(buffer,pw?"Q":"Queen");break;
	  case KING : strcpy(buffer,pw?"K":"King");	break;
	  default   : if (pw) sprintf(buffer,"%d",r);
	              else {
		        strcpy(temp, say(r));
			temp[0] = toupper(temp[0]);
	                strcpy(buffer,temp);
	              }
	}

	if (! pw) strcat(buffer, " of ");

	switch(suite(n)) {
	  case 0: strcat(buffer,pw?"s":"Spades");		break;
	  case 1: strcat(buffer,pw?"c":"Clubs");		break;
	  case 2: strcat(buffer,pw?"h":"Hearts");		break;
	  case 3: strcat(buffer,pw?"d":"Diamonds");		break;
	}

	return( (char *) buffer);
}

int
value_of(n)
int n;
{
	int r, v;
	
	if ((r = n % 13) == 0) v = 10;
	else if (r > 10)       v = 10;
	else v = r;

	return(v);
}

order(hand, max)
struct card_hand *hand;
int max;
{
	/* reorder hand according to rank, lowest to highest */

	int i, changed, temp, tempstat;

	do {
          changed = 0;
	  for (i = 0; i < max-1; i++)
	    if (rank(hand->card[i]) > rank(hand->card[i+1])) {
	      temp = hand->card[i];
	      tempstat = hand->status[i];
	      hand->card[i] = hand->card[i+1];
	      hand->status[i] = hand->status[i+1];
	      hand->card[i+1] = temp;
	      hand->status[i+1] = tempstat;
	      changed++;
	    }
	 } while (changed);
}

int
mark_as_played(hand, card, whose)
struct card_hand *hand;
int card, whose;
/*
 *     Modified by Chris Yoder to allow for the removal of displayed hands.
 *     whose -> whose card is being played.
 */
{
	/** mark card in hand as being played.  Return non-zero if card not
	    in hand! **/
	int win_num;
	register int i;

	win_num = 0;
	for (i=0;i<4;i++) {
	  if (hand->card[i] == card && hand->status[i] == AVAILABLE) {
	    hand->status[i] = PLAYED;
	    if (whose == ME)
	      remove_card(my_card_win,0,ME);
	    else
	      remove_card(your_card_win,win_num,YOU);
	    return(0);
	  }
	  if (hand->status[i] == AVAILABLE) win_num++;
        }
	return(1);
}

get_exceptions(full_hand, partial_hand, v0, v1)
struct card_hand full_hand, partial_hand;
int *v0, *v1;
{
	/** return index of two elements in full_hand NOT in partial_hand **/
	int i, i1=0, a, b;
	
	a = (-1);
	for (i=0; i<6; i++) {
	  if (full_hand.card[i] != partial_hand.card[i1]) {
	    if (a >= 0) b = i;
	    else        a = i;
	  }
	  else i1++;
	}
	*v0 = a;
	*v1 = b;
}

compress(hand)
struct card_hand *hand;
{
	/** compress hand to ensure that there are no 'holes' from
	    the crib selection process **/
	int buffer[4], i, j=0;

	for (i=0;i<6;i++)
	  if (hand->status[i] != DISCARDED) buffer[j++] = hand->card[i];
	for (i=0;i<4;i++) {
	  hand->card[i] = buffer[i];
	  hand->status[i] = AVAILABLE;
	}
}

int
stuck(hand, sum)
struct card_hand hand;
int sum;
{
	/** returns zero if one of the cards in the given hand
	    can be added to sum without breaking '31' else returns one **/
	register int i;

	for (i=0;i<4;i++)
	  if (hand.status[i] == AVAILABLE)
	    if (sum + value_of(hand.card[i]) < 32) return(0);
	return(1);
}

add_to_played(who, card, played_cards, index, sum, total_cards)
int who, card, played_cards[], *index, *sum, total_cards;
{
	/** add card... also give points to the appropriate player
	    if 15, pair, triple, run, 31, or last card is played. **/
	int point_value = 0, i;
	
	point_value = value(card, played_cards, *index, *sum, 1);

	*sum += value_of(card);
	played_cards[*index] = card;
	*index += 1;

	wprintw(i_o_win,"%s ", say(*sum));
	if (point_value) {
	  wprintw(i_o_win,"for %s\n",say(point_value));
	  add_points(who, point_value);
	}
	else
	  wprintw(i_o_win,"\n");

	if (stuck(your_hand, *sum) &&
	    stuck(my_hand, *sum)) {
	  *sum = 0;
	  *index = 0;
	  if (total_cards < 8)
	      wprintw(i_o_win,"\nback to zero...\n\n");
	  wrefresh(i_o_win);
	}
}
	
int
pick_discard(played, index, sum)
int played[], index, sum;
{
	/** pick best card in hand to play, given 'played' as the stack
	    of cards played so far, and sum as the current sum... **/

	/** simply try putting each of the available cards against the
	    current played cards and use highest value if possible, if
	    not, use the highest value card first.. **/

	int i, best=0, best_card=0, valid_card;

	/** Remove the card on the display. **/
	remove_card(my_card_win,0,ME);

	for (i=0;i<4;i++) 
	  if (my_hand.status[i] == AVAILABLE) 
	    if (value_of(my_hand.card[i]) + sum < 32) {
	      if ((valid_card = value(my_hand.card[i],
                   played,index,sum,0)) > best) {
	        best_card = i;
	        best = valid_card;
	      }
	    }

	if (best > 0) { /* actually can make some points!  Let's do it! */
	  my_hand.status[best_card] = PLAYED;
	  return(my_hand.card[best_card]);
	}
	else { /* no choices are inspiring...let's put down the highest */
	  for (i=3;i>-1;i--)
	    if (my_hand.status[i] == AVAILABLE) 
              if (value_of(my_hand.card[i]) + sum < 32) {
	        my_hand.status[i] = PLAYED;
	        return(my_hand.card[i]);
	      }
	}
	wprintw(i_o_win,"couldn't pick a card!\n");
	wrefresh(i_o_win);
	return(-2);
}

int
value(card, played_cards, i, sum, not_computing)
int card, played_cards[], i, sum, not_computing;
{
	/** compute the value of adding the card to the stack of played
	    cards given the sum and whether or not this is a 'real'
	    calculation (ie for point changes, not to figure best card) **/

	int point_value = 0, scratch;
	
	sum += value_of(card);
	played_cards[i] = card;

	/** check for fifteen **/

	if (sum == 15) point_value += 2;

	/** check for four of a kind, three of a kind, pairs.. **/

	scratch = 0;
	if (i>0)
	 if (rank(played_cards[i-1]) == rank(played_cards[i]))
	   scratch = 2;
	if (i>1 && scratch)
	 if (rank(played_cards[i-2]) == rank(played_cards[i]))
	   scratch += 4;
        if (i>2 && scratch == 6)
	 if (rank(played_cards[i-3])==rank(played_cards[i]))
	   scratch += 6;

	point_value += scratch;

	/** okay, now check for runs... **/

	scratch = check_for_runs(played_cards, i+1);
	
	if (scratch > 0) 
	  point_value += scratch;

	/** and how about to 31? **/
	
	if (sum == 31) 
	  if (not_computing) point_value += 1;
	  else 		     point_value += 2;

	/** last card (only if real counting...otherwise the computer would 
	    cheat! **/

	if (not_computing) 
	  if (stuck(your_hand, sum) && stuck(my_hand, sum)) 
	    point_value += 1;

	return(point_value);
}

char *say(n)
int n;
{
	/** output number 'n' as a word...return string containing the
	    word.  IE 14 = 'fourteen', 30 = 'thirty' etc etc.. **/

	static char buffer[30];

	if (n>=10 && n<20) {
	  switch (n) {
	    case 10: strcpy(buffer,"ten");	      break;
	    case 11: strcpy(buffer,"eleven");         break;
	    case 12: strcpy(buffer,"twelve");         break;
	    case 13: strcpy(buffer,"thirteen");       break;
	    case 14: strcpy(buffer,"fourteen");       break;
	    case 15: strcpy(buffer,"fifteen");        break;
	    case 16: strcpy(buffer,"sixteen");        break;
	    case 17: strcpy(buffer,"seventeen");      break;
	    case 18: strcpy(buffer,"eighteen");       break;
	    case 19: strcpy(buffer,"nineteen");       break;
	  }
	  return((char *) buffer);
	}

	/** okay... normal word, so let's build it up backwards.. **/

	switch ((int) n / 10) {
	  case 0 : buffer[0] = '\0';		break;
	  case 2 : strcpy(buffer,"twenty");	break;
	  case 3 : strcpy(buffer,"thirty");	break;
	  case 4 : strcpy(buffer,"forty");	break;
	  case 5 : strcpy(buffer,"fifty");	break;
	  case 6 : strcpy(buffer,"sixty");	break;
	  case 7 : strcpy(buffer,"seventy");	break;
	  case 8 : strcpy(buffer,"eighty");	break;
	  case 9 : strcpy(buffer,"ninety");	break;
	  default: sprintf(buffer,"%d", n);
		   return( (char *) buffer);
	}

	if (n>20 && n != 30) strcat(buffer,"-");

	switch(n % 10) {
	  case 0 : break;
	  case 1 : strcat(buffer,"one");	break;
	  case 2 : strcat(buffer,"two");	break;
	  case 3 : strcat(buffer,"three");	break;
	  case 4 : strcat(buffer,"four");	break;
	  case 5 : strcat(buffer,"five");	break;
	  case 6 : strcat(buffer,"six");	break;
	  case 7 : strcat(buffer,"seven");	break;
	  case 8 : strcat(buffer,"eight");	break;
	  case 9 : strcat(buffer,"nine");	break;
	}

	if (strlen(buffer) == 0) strcpy(buffer,"zero");

	return((char *) buffer);
}

winner(who)
int who;
{
	/** show winner and leave **/

	wprintw(i_o_win,"\n\n%s won, reaching %s points first!\n\n",
		who==ME? "I":"You", say(limit));
	wrefresh(i_o_win);
	cleanup();
}

leave()
{
	/** get the heck outta here! **/

	wprintw(i_o_win,"\n\nFinal scores were:\n");
	wprintw(i_o_win,"\nYou had %d point%s and I had %d point%s\n",
		  points[YOU], plural(points[YOU]), 
		  points[ME],  plural(points[ME]));
	wrefresh(i_o_win);
	cleanup();
}

int
check_for_runs(stack, elements)
int stack[], elements;
{
	int i, found[14], min, max, len, seq_len;

	if (elements < 3) return(0);

	for (i=0;i<14;i++) found[i] = 0;

	min=14;
	max=0;
	seq_len=0;

	for (i=elements-1;i>-1;i--) {
	  len = elements - i;

	  min = ( min < rank(stack[i])) ? min : rank(stack[i]);
	  max = ( max > rank(stack[i])) ? max : rank(stack[i]);
  
	  if (++found[rank(stack[i])] > 1) break;
  
	  if ((len > 2) && (max-min+1 == len)) seq_len = len;
	}
	return(seq_len);
}

int
rank(n)
int n;
{
	return(n % 13 == 0? KING : n % 13);
}

/*
 *	   The following procedures were written by Chris Yoder for display
 *	purposes.
 */

/******************************************************************************/

setup_screen()
/*
 *  This procedure will setup the screen so that we can play.
 */
{
  int i;

  initscr();
  for (i=0;i<7;i++) your_card_win[i] = NULL;
  for (i=0;i<7;i++) my_card_win[i] = NULL;
  i_o_win = newwin(22,40,I_O_TOP,I_O_EDGE);
  create_board();
  scrollok(i_o_win,TRUE);
  wmove(i_o_win,0,0);
}

/******************************************************************************/

create_board()
/*
 *  This procedure will create the initial board and position of it.
 */
{
  board_win = newwin(7,39,BOARD_TOP,BOARD_EDGE);
  mvwaddstr(board_win, 0, 0,"+-+-----+-----+-----+-----+-----+-----+");
  mvwaddstr(board_win, 1, 0,"|h|.....|.....|.....|.....|.....|.....|");
  mvwaddstr(board_win, 2, 0,"|c|.....|.....|.....|.....|.....|.....|");
  mvwaddstr(board_win, 3, 0,"+-+-----+-----+-----+-----+-----+-----+");
  mvwaddstr(board_win, 4, 0,"|h|.....|.....|.....|.....|.....|.....|");
  mvwaddstr(board_win, 5, 0,"|c|.....|.....|.....|.....|.....|.....|");
  mvwaddstr(board_win, 6, 0,"+-+-----+-----+-----+-----+-----+-----+");
  wrefresh(board_win);
}

/******************************************************************************/

peg(who, num)
/*
 *	This procedure will do the actual moving of the pegs w/i the program.
 */
int who, num;
{
  int	hold_val; /* Holding variable when switching forward and back pegs. */

  if (num == 0) return; /* So we don't try to move when we aren't moving. */

  if (who == ME)
    { /* Move my piece. */
      hold_val = my_for_peg;		/* Hang onto this location. */
      my_for_peg += num;		/* Figure out where we're going to. */
      remove_peg(ME,my_bck_peg);	/* Take out the back peg. */
      place_peg(ME,my_for_peg);		/* Place it in front. */
      my_bck_peg = hold_val;		/* The back peg is now located where the
					 * front peg used to be. */
    }
  else
    { /* Move your piece. (See above coments). */
      hold_val = your_for_peg;
      your_for_peg += num;
      remove_peg(YOU,your_bck_peg);
      place_peg(YOU,your_for_peg);
      your_bck_peg = hold_val;
    }
}

/******************************************************************************/

remove_peg(who,where)
/*
 *	This procedure will remove a peg from the board.
 */
int	who, where;
/*
 *	who -> owner of the peg
 *	where -> where the peg is
 */
{
  int	temp, temp2;

  if (where == -1)
    {
      temp = 5 - who;
      wmove(board_win,temp,1);
      wdelch(board_win);
      winsch(board_win,'.');
      wrefresh(board_win);
      return;
    }
  if (where == 0)
    {
      temp = 2 - who;
      wmove(board_win,temp,1);
      wdelch(board_win);
      winsch(board_win,'.');
      wrefresh(board_win);
      return;
    }
  switch((where-1)/30) {
    case 0  : /* first segment (top) */
      temp = 2 - who;
      temp2 = 2 + where + ((where-1)/5);
      wmove(board_win,temp,temp2);
      break;
    case 1  : /* second segment (bottom) */
      temp = 5 - who;
      temp2 = 61 - where;
      temp2 = 2 + temp2 + ((temp2-1)/5);
      wmove(board_win,temp,temp2);
      break;
    case 2  : /* third segment (top) */
      temp = 2 - who;
      temp2 = where - 60;
      temp2 = 2 + temp2 + ((temp2-1)/5);
      wmove(board_win,temp,temp2);
      break;
    case 3  : /* fourth segment (bottom) */
      temp = 5 - who;
      temp2 = 121 - where;
      temp2 = 2 + temp2 + ((temp2-1)/5);
      wmove(board_win,temp,temp2);
      break;
    default : /* sound the alarm, we're dead! */
      return;
    }
  wdelch(board_win);
  winsch(board_win,'.');
  wrefresh(board_win);
  return;
}

/******************************************************************************/

place_peg(who,where)
/*
 *	This procedure will place a peg on the board.
 */
int	who, where;
/*
 *	who -> owner of the peg
 *	where -> where the peg is
 */
{
  int	temp, temp2;

  switch((where-1)/30) {
    case 0  : /* first segment (top) */
      temp = 2 - who;
      temp2 = 2 + where + ((where-1)/5);
      wmove(board_win,temp,temp2);
      break;
    case 1  : /* second segment (bottom) */
      temp = 5 - who;
      temp2 = 61 - where;
      temp2 = 2 + temp2 + ((temp2-1)/5);
      wmove(board_win,temp,temp2);
      break;
    case 2  : /* third segment (top) */
      temp = 2 - who;
      temp2 = where - 60;
      temp2 = 2 + temp2 + ((temp2-1)/5);
      wmove(board_win,temp,temp2);
      break;
    case 3  : /* fourth segment (bottom) */
      temp = 5 - who;
      temp2 = 121 - where;
      temp2 = 2 + temp2 + ((temp2-1)/5);
      wmove(board_win,temp,temp2);
      break;
    default : /* We just won! */
      wmove(board_win,5-who,1);
      break;
    }
  wdelch(board_win);
  winsch(board_win,who == ME? 'c' : 'h');
  wrefresh(board_win);
  return;
}

/******************************************************************************/

display_hand(hand, max, see, whose_side)
/*
 *	   Display a hand so that we can see what we have in card format.
 */
struct card_hand hand;		/* The hand to display. */
int max, see, whose_side;	/* max -> number of cards
				 * see -> ? VISIBLE : INVISIBLE
				 * whose -> ? ME : YOU
				 */
{
  /** display hand as a bunch of cards **/
  register int i;
  int offset;	/* Offset from the edge that the card will be. */

  for (i=0;i<max;i++)
    {
      offset = (i%2) * 3;
      if (see == VISIBLE)
	if (whose_side == ME)
	  make_card (&my_card_win[i],say_card(hand.card[i],SHORT_FORM),
	    MY_CARD_TOP+(i*2),MY_CARD_EDGE+offset);
	else
	  make_card (&your_card_win[i],say_card(hand.card[i],SHORT_FORM),
	    YOUR_CARD_TOP+(i*2),YOUR_CARD_EDGE+offset);
      else /* We assume that the only invisible hand is mine. */
	make_card (&my_card_win[i],"",MY_CARD_TOP+(i*2),MY_CARD_EDGE+offset);
    }
}

/******************************************************************************/

undisplay_hand (whose)
/*
 *        This procedure will allow us to delete a hand from the display after
 *     showing it in the counting procedure.
 */
int	whose;
/*
 *	whose -> whose side the hand is on.
 */
{
  int i;
  if (whose == ME)
    for (i=0;i<4;i++) delwin(my_card_win[i]);
  else
    for (i=0;i<4;i++) delwin(your_card_win[i]);
}

/******************************************************************************/

make_card (win_name,card_name,y,x)
/*
 *	   This procedure will make up a card and display it on the screen.
 *	It *must* be called like:
 *	make_card (&win_name,card_name,y,x);
 */
WINDOW	**win_name;	/* Name of the new window. */
char	*card_name;	/* Name of the card. */
int	y,x;		/* Where to put this card. */
{
  *win_name = newwin(5,7,y,x);
  box(*win_name,'|','-');
  mvwaddstr(*win_name, 1, 1, card_name);
  mvwaddstr(*win_name, 3, 4, card_name);
  wrefresh(*win_name);
}

/******************************************************************************/

remove_card(win_hand,num_to_pull,whose_side)
/*
 *	   This procedure will remove a card from the hand and redisplay the
 *	hand after that.  It assumes that the last element in the array will
 *	be a null.
 */
WINDOW	*win_hand[7];
int	num_to_pull,whose_side;	/* num_to_pull -> number of card in hand.
				 * whose -> ? ME : YOU
				 */
{
  int offset, i;

  delwin (win_hand[num_to_pull]);
  for (i=num_to_pull;win_hand[i]!=NULL;i++) win_hand[i] = win_hand[i+1];
  for (i=0;win_hand[i]!=NULL;i++)
    {
      offset = (i%2) * 3;
      if (whose_side == ME)
	mvwin(win_hand[i],MY_CARD_TOP+(i*2),MY_CARD_EDGE+offset);
      else
	mvwin(win_hand[i],YOUR_CARD_TOP+(i*2),YOUR_CARD_EDGE+offset);
      wrefresh(win_hand[i]);
    }
}

/******************************************************************************/

cleanup()
/*
 *     This procedure will cleanup the screen and set the screen back to what it
 *  was.
 */
{
  sleep(5);
  endwin();
  exit(1);
}
