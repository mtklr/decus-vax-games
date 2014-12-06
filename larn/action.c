/*
    action.c

    Routines to perform the actual actions associated with various
    player entered commands.

    act_remove_gems         remove gems from a throne
    act_sit_throne          sit on a throne
    act_up_stairs           go up stairs
    act_down_stairs         go down stairs
    act_drink_fountain      drink from a fountain
    act_wash_fountain       wash at a fountain
    act_up_shaft            up volcanic shaft
    act_down_shaft          down volcanic shaft
    volshaft_climbed        place player near volcanic shaft
    act_desecrate_altar     desecrate an altar
    act_donation_pray       pray, donating money
    act_just_pray           pray, not donating money
    act_prayer_heard        prayer was heard
    act_ignore_altar        ignore an altar
    act_open_chest          open a chest
    act_open_door           open a door
*/

#include "header.h"
#include "larndefs.h"
#include "monsters.h"
#include "objects.h"
#include "player.h"

/*
    act_remove_gems

    Remove gems from a throne.

    arg is zero if there is a gnome king associated with the throne

    Assumes that cursors() has been called previously, and that a check
    has been made that the throne actually has gems.
*/
act_remove_gems( arg )
int arg ;
    {
    int i, k ;

    k=rnd(101);
    if (k<25)
        {
        for (i=0; i<rnd(4); i++) 
            creategem(); /* gems pop off the throne */
        item[playerx][playery]=ODEADTHRONE;
        know[playerx][playery]=0;
        }
    else if (k<40 && arg==0)
        {
        createmonster(GNOMEKING);
        item[playerx][playery]=OTHRONE2;
        know[playerx][playery]=0;
        }
    else 
        lprcat("\nNothing happens");

    return ;
    }

/*
    act_sit_throne

    Sit on a throne.

    arg is zero if there is a gnome king associated with the throne

    Assumes that cursors() has been called previously.
*/
act_sit_throne( arg )
int arg ;
    {
    int k ;

    k=rnd(101);
    if (k<30 && arg==0)
        {
        createmonster(GNOMEKING);
        item[playerx][playery]=OTHRONE2;
        know[playerx][playery]=0;
        }
    else if (k<35) 
        { 
        lprcat("\nZaaaappp!  You've been teleported!\n"); 
        beep(); 
        oteleport(0); 
        }
    else 
        lprcat("\nNothing happens");

    return ;
    }

/*
    assumes that cursors() has been called and that a check has been made that
    the user is actually standing at a set of up stairs.
*/
act_up_stairs()
    {
    if (level >= 2 && level != 11)
        {
        newcavelevel( level - 1 )  ;
        draws( 0, MAXX, 0, MAXY );
        bot_linex() ;
        }
    else
        lprcat("\nThe stairs lead to a dead end!") ;
    return ;
    }

/*
    assumes that cursors() has been called and that a check has been made that
    the user is actually standing at a set of down stairs.
*/
act_down_stairs()
    {
    if (level != 0 && level != 10 && level != 13)
        {
        newcavelevel( level + 1 )  ;
        draws( 0, MAXX, 0, MAXY );
        bot_linex() ;
        }
    else
        lprcat("\nThe stairs lead to a dead end!") ;
    return ;
    }

/*
    Code to perform the action of drinking at a fountian.  Assumes that
    cursors() has already been called, and that a check has been made that
    the player is actually standing at a live fountain.
*/
act_drink_fountain()
    {
    int x ;

    if (rnd(1501)<2)
        {
        lprcat("\nOops!  You seem to have caught the dreadful sleep!");
        beep(); 
        lflush();  
        sleep(3);  
        died(280); 
        return;
        }

    x = rnd(100);
    if (x<7)
        {
        c[HALFDAM] += 200 + rnd(200);
        lprcat("\nYou feel a sickness coming on");
        }

    else if (x < 13)
        quaffpotion(23, FALSE ); /* see invisible,but don't know the potion */

    else if (x < 45)
        lprcat("\nnothing seems to have happened");

    else if (rnd(3) != 2)
        fntchange(1);   /*  change char levels upward   */

    else
        fntchange(-1);  /*  change char levels downward */

    if (rnd(12)<3)
        {
        lprcat("\nThe fountains bubbling slowly quiets");
        item[playerx][playery]=ODEADFOUNTAIN; /* dead fountain */
        know[playerx][playery]=0;
        }
    return;
    }

/*
    Code to perform the action of washing at a fountain.  Assumes that
    cursors() has already been called and that a check has been made that
    the player is actually standing at a live fountain.
*/
act_wash_fountain()
    {
    int x ;

    if (rnd(100) < 11)
        {
        x=rnd((level<<2)+2);
        lprintf("\nOh no!  The water was foul!  You suffer %d hit points!",(long)x);
        lastnum=273;
        losehp(x); 
        bottomline();  
        cursors();
        }

    else if (rnd(100) < 29)
        lprcat("\nYou got the dirt off!");

    else if (rnd(100) < 31)
        lprcat("\nThis water seems to be hard water!  The dirt didn't come off!");

    else if (rnd(100) < 34)
        createmonster(WATERLORD); /*    make water lord     */

    else
        lprcat("\nnothing seems to have happened");

    return;
    }

/*
    Perform the act of climbing down the volcanic shaft.  Assumes
    cursors() has been called and that a check has been made that
    are actually at a down shaft.
*/
act_down_shaft()
    {
    if (level!=0)
        {
        lprcat("\nThe shaft only extends 5 feet downward!");
        return;
        }

    if (packweight() > 45+3*(c[STRENGTH]+c[STREXTRA]))
        {
        lprcat("\nYou slip and fall down the shaft");
        beep();
        lastnum=275;
        losehp(30+rnd(20));
        bottomhp();
        }
    else if (prompt_mode)
        lprcat("climb down");

    newcavelevel(MAXLEVEL);
    draws(0,MAXX,0,MAXY);
    bot_linex();
    return;
    }

/*
    Perform the action of climbing up the volcanic shaft. Assumes
    cursors() has been called and that a check has been made that
    are actually at an up shaft.

*/
act_up_shaft()
    {
    if (level!=11) 
        { 
        lprcat("\nThe shaft only extends 8 feet upwards before you find a blockage!"); 
        return; 
        }

    if (packweight() > 45+5*(c[STRENGTH]+c[STREXTRA])) 
        { 
        lprcat("\nYou slip and fall down the shaft"); 
        beep();
        lastnum=275; 
        losehp(15+rnd(20)); 
        bottomhp(); 
        return; 
        }

    if (prompt_mode)
        lprcat("climb up"); 
    lflush(); 
    newcavelevel(0);
    volshaft_climbed( OVOLDOWN );
    return;
    }

/*
    Perform the action of placing the player near the volcanic shaft
    after it has been climbed.

    Takes one parameter:  the volcanic shaft object to be found.  If have
    climbed up, search for OVOLDOWN, otherwise search for OVOLUP.
*/
static volshaft_climbed(object)
int object;
    {
    int i,j ;

    /* place player near the volcanic shaft */
    for (i=0; i<MAXY; i++)
        for (j=0; j<MAXX; j++)
            if (item[j][i] == object)
                {
                playerx=j;
                playery=i;
                positionplayer();
                i=MAXY;
                break;
                }
    draws(0,MAXX,0,MAXY);
    bot_linex();
    return ;
    }

/*
    Perform the actions associated with Altar desecration.
*/
act_desecrate_altar()
    {
    if (rnd(100)<60)
    { 
    createmonster(makemonst(level+2)+8); 
    c[AGGRAVATE] += 2500; 
    }
    else if (rnd(101)<30)
    {
    lprcat("\nThe altar crumbles into a pile of dust before your eyes");
    forget();   /*  remember to destroy the altar   */
    }
    else
    lprcat("\nnothing happens");
    return ;
    }

/*
    Perform the actions associated with praying at an altar and giving a
    donation.
*/
act_donation_pray()
    {
    unsigned long k,temp ;

    while (1)
        {
        lprcat("\n\n");
        cursor(1,24);
        cltoeoln();
        cursor(1,23);
        cltoeoln();
        lprcat("how much do you donate? ");
        k = readnum((long)c[GOLD]);

        /* VMS has a problem with echo mode input (used in readnum()) such that the
           next carriage return will shift the screen up one line.  To get around
           this, if we are VMS, don't print the next carriage return.  Otherwise,
           print the carriage return needed by all following messages.
	Turns out that all but MS-DOS (which has 25 lines) has this problem.
        */
#ifdef MSDOS
            lprcat("\n");
#endif

        /* make giving zero gold equivalent to 'just pray'ing.  Allows player to
           'just pray' in command mode, without having to add yet another command.
        */
        if (k == 0)
            {
            act_just_pray();
            return;
            }

        if (c[GOLD] >= k)
            {
            temp = c[GOLD] / 10 ;
            c[GOLD] -= k;
            bottomline();

            /* if player gave less than 10% of _original_ gold, make a monster
            */
            if (k < temp || k < rnd(50))
                {
                createmonster(makemonst(level+1));
                c[AGGRAVATE] += 200;
                return;
                }
            if (rnd(101) > 50)
                {
                act_prayer_heard();
                return;
                }
            if (rnd(43) == 5)
                {
                if (c[WEAR])
                    lprcat("You feel your armor vibrate for a moment");
                enchantarmor();
                return;
                }
            if (rnd(43) == 8)
                {
                if (c[WIELD])
                    lprcat("You feel your weapon vibrate for a moment");
                enchweapon();
                return;
                }

            lprcat("Thank You.");
            return ;
            }

        /* Player donates more gold than they have.  Loop back around so
           player can't escape the altar for free.
        */
        lprcat("You don't have that much!");
        }
    }

/*
    Performs the actions associated with 'just praying' at the altar.  Called
    when the user responds 'just pray' when in prompt mode, or enters 0 to
    the money prompt when praying.

    Assumes cursors(), and that any leading \n have been printed (to get
    around VMS echo mode problem.
*/
act_just_pray()
    {
    if (rnd(100)<75) 
    lprcat("nothing happens");
    else if (rnd(43) == 10)
    {
    if (c[WEAR]) 
        lprcat("You feel your armor vibrate for a moment");
    enchantarmor(); 
    return;
    }
    else if (rnd(43) == 10)
    {
    if (c[WIELD]) 
        lprcat("You feel your weapon vibrate for a moment");
    enchweapon(); 
    return;
    }
    else 
    createmonster(makemonst(level+1));
    return;
    }

/*
    function to cast a +3 protection on the player
 */
static act_prayer_heard()
    {
    lprcat("You have been heard!");
    if (c[ALTPRO]==0) 
        c[MOREDEFENSES]+=3;
    c[ALTPRO] += 500;   /* protection field */
    bottomline();
    }

/*
    Performs the act of ignoring an altar.

    Assumptions:  cursors() has been called.
*/
act_ignore_altar()
    {
    if (rnd(100)<30)    
        {
        createmonster(makemonst(level+1)); 
        c[AGGRAVATE] += rnd(450); 
        }
    else    
        lprcat("\nNothing happens");
    return;
    }

/*
    Performs the act of opening a chest.  

    Parameters:   x,y location of the chest to open.
    Assumptions:  cursors() has been called previously
*/
act_open_chest(x,y)
int x,y ;
    {
    int i,k;

    k=rnd(101);
    if (k<40)
        {
        lprcat("\nThe chest explodes as you open it"); beep();
        i = rnd(10);  lastnum=281;  /* in case he dies */
        lprintf("\nYou suffer %d hit points damage!",(long)i);
        checkloss(i);
        switch(rnd(10)) /* see if he gets a curse */
            {
            case 1: c[ITCHING]+= rnd(1000)+100;
                    lprcat("\nYou feel an irritation spread over your skin!");
                    beep();
                    break;

            case 2: c[CLUMSINESS]+= rnd(1600)+200;
                    lprcat("\nYou begin to lose hand to eye coordination!");
                    beep();
                    break;

            case 3: c[HALFDAM]+= rnd(1600)+200;
                    beep();
                    lprcat("\nA sickness engulfs you!");    break;
            };
    item[x][y]=know[x][y]=0;    /* destroy the chest */
        if (rnd(100)<69) creategem(); /* gems from the chest */
    dropgold(rnd(110*iarg[playerx][playery]+200));
        for (i=0; i<rnd(4); i++) something(iarg[playerx][playery]+2);
        }
    else
        lprcat("\nNothing happens");
    return;
    }

/*
    Perform the actions common to command and prompt mode when opening a
    door.  Assumes cursors().

    Parameters:     the X,Y location of the door to open.
    Return value:   TRUE if successful in opening the door, false if not.
*/
act_open_door( x, y )
int x ;
int y ;
    {
    if (rnd(11)<7)
        {
        switch(iarg[x][y])
            {
            case 6: c[AGGRAVATE] += rnd(400);   break;

            case 7: lprcat("\nYou are jolted by an electric shock ");
                    lastnum=274; losehp(rnd(20));  bottomline();  break;

            case 8: loselevel();  break;

            case 9: lprcat("\nYou suddenly feel weaker ");
                    if (c[STRENGTH]>3) c[STRENGTH]--;
                    bottomline();  break;

            default:    break;
            }
    return( 0 );
        }
    else
        {
        know[x][y]=0;
        item[x][y]=OOPENDOOR;
        return( 1 );
        }
    }
