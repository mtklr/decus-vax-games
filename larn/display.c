/* display.c */
#include "header.h"
#include "larndefs.h"
#include "objects.h"
#include "player.h"

#define botsub( _idx, _x, _y, _str )        \
    if ( c[(_idx)] != cbak[(_idx)] )        \
    {                                   \
    cbak[(_idx)] = c[(_idx)];           \
    cursor( (_x), (_y) );               \
    lprintf( (_str), (long)c[(_idx)] ); \
    }

static int  minx,maxx,miny,maxy,k;
static char bot1f=0,bot2f=0,bot3f=0;
static char always=0;
       char regen_bottom = 0;

/*
    bottomline()

    now for the bottom line of the display
 */
bottomline()
    {   recalc();   bot1f=1;    }
bottomhp()
    {   bot2f=1;    }
bottomspell()
    {   bot3f=1;    }
bottomdo()
    {
    if (bot1f) { bot3f=bot1f=bot2f=0; bot_linex(); return; }
    if (bot2f) { bot2f=0; bot_hpx(); }
    if (bot3f) { bot3f=0; bot_spellx(); }
    }

bot_linex()
    {
    register int i;
    if ( regen_bottom || (always))
        {
        regen_bottom = FALSE ;
        cursor( 1,18);
        if (c[SPELLMAX]>99)  lprintf("Spells:%3d(%3d)",(long)c[SPELLS],(long)c[SPELLMAX]);
                        else lprintf("Spells:%3d(%2d) ",(long)c[SPELLS],(long)c[SPELLMAX]);
        lprintf(" AC: %-3d  WC: %-3d  Level",(long)c[AC],(long)c[WCLASS]);
        if (c[LEVEL]>99) lprintf("%3d",(long)c[LEVEL]);
                    else lprintf(" %-2d",(long)c[LEVEL]);
        lprintf(" Exp: %-9d %s\n",(long)c[EXPERIENCE],class[c[LEVEL]-1]);
        lprintf("HP: %3d(%3d) STR=%-2d INT=%-2d ",
            (long)c[HP],(long)c[HPMAX],(long)(c[STRENGTH]+c[STREXTRA]),(long)c[INTELLIGENCE]);
        lprintf("WIS=%-2d CON=%-2d DEX=%-2d CHA=%-2d LV:",
            (long)c[WISDOM],(long)c[CONSTITUTION],(long)c[DEXTERITY],(long)c[CHARISMA]);

        if ((level==0) || (wizard))  c[TELEFLAG]=0;
        if (c[TELEFLAG])  lprcat(" ?");  else  lprcat(levelname[level]);
        lprintf("  Gold: %-6d",(long)c[GOLD]);
        always=1;  botside();
        c[TMP] = c[STRENGTH]+c[STREXTRA];
        for (i=0; i<100; i++) cbak[i]=c[i];
        return;
        }

    botsub(SPELLS,8,18,"%3d");
    if (c[SPELLMAX]>99)
        {
        botsub(SPELLMAX,12,18,"%3d)");
        }
    else
        botsub(SPELLMAX,12,18,"%2d) ");
    botsub(HP,5,19,"%3d");
    botsub(HPMAX,9,19,"%3d");
    botsub(AC,21,18,"%-3d");
    botsub(WCLASS,30,18,"%-3d");
    botsub(EXPERIENCE,49,18,"%-9d");
    if (c[LEVEL] != cbak[LEVEL])
        {
        cursor(59,18);
        lprcat(class[c[LEVEL]-1]);
        }
    if (c[LEVEL]>99)
        {
        botsub(LEVEL,40,18,"%3d");
        }
    else
        botsub(LEVEL,40,18," %-2d");
    c[TMP] = c[STRENGTH]+c[STREXTRA];
    botsub(TMP,18,19,"%-2d");
    botsub(INTELLIGENCE,25,19,"%-2d");
    botsub(WISDOM,32,19,"%-2d");
    botsub(CONSTITUTION,39,19,"%-2d");
    botsub(DEXTERITY,46,19,"%-2d");
    botsub(CHARISMA,53,19,"%-2d");
    if ((level != cbak[CAVELEVEL]) || (c[TELEFLAG] != cbak[TELEFLAG]))
        {
        if ((level==0) || (wizard))
            c[TELEFLAG]=0;
        cbak[TELEFLAG] = c[TELEFLAG];
        cbak[CAVELEVEL] = level;
        cursor(59,19);
        if (c[TELEFLAG])
            lprcat(" ?");
        else
            lprcat(levelname[level]);
        }
    botsub(GOLD,69,19,"%-6d");
    botside();
    }

/*
    special subroutine to update only the gold number on the bottomlines
    called from ogold()
 */
bottomgold()
    {
    botsub(GOLD,69,19,"%-6d");
    }

/*
    special routine to update hp and level fields on bottom lines
    called in monster.c hitplayer() and spattack()
 */
static bot_hpx()
    {
    if (c[EXPERIENCE] != cbak[EXPERIENCE])
        {
        recalc();
        bot_linex();
        }
    else
        botsub(HP,5,19,"%3d");
    }

/*
    special routine to update number of spells called from regen()
 */
static bot_spellx()
    {
    botsub(SPELLS,9,18,"%2d");
    }

/*
    common subroutine for a more economical bottomline()
 */
static struct bot_side_def
    {
    int typ;
    char *string;
    }
    bot_data[] =
    {
    STEALTH,"stealth",      UNDEADPRO,"undead pro",     SPIRITPRO,"spirit pro",
    CHARMCOUNT,"Charm",     TIMESTOP,"Time Stop",       HOLDMONST,"Hold Monst",
    GIANTSTR,"Giant Str",   FIRERESISTANCE,"Fire Resit", DEXCOUNT,"Dexterity",
    STRCOUNT,"Strength",    SCAREMONST,"Scare",         HASTESELF,"Haste Self",
    CANCELLATION,"Cancel",  INVISIBILITY,"Invisible",   ALTPRO,"Protect 3",
    PROTECTIONTIME,"Protect 2", WTW,"Wall-Walk"
    };

static botside()
    {
    register int i,idx;
    for (i=0; i<17; i++)
        {
        idx = bot_data[i].typ;
        if ((always) || (c[idx] != cbak[idx]))
           {
           if ((always) || (cbak[idx] == 0))
                { if (c[idx]) { cursor(70,i+1); lprcat(bot_data[i].string); } }  else
           if (c[idx]==0)     { cursor(70,i+1); lprcat("          "); }
           cbak[idx]=c[idx];
           }
        }
    always=0;
    }

/*
 *  subroutine to draw only a section of the screen
 *  only the top section of the screen is updated.  If entire lines are being
 *  drawn, then they will be cleared first.
 */
static int d_xmin=0,d_xmax=MAXX,d_ymin=0,d_ymax=MAXY;  /* for limited screen drawing */
draws(xmin,xmax,ymin,ymax)
    int xmin,xmax,ymin,ymax;
    {
    register int i,idx;
    if (xmin==0 && xmax==MAXX) /* clear section of screen as needed */
        {
        if (ymin==0) cl_up(79,ymax);
        else for (i=ymin; i<ymin; i++)  cl_line(1,i+1);
        xmin = -1;
        }
    d_xmin=xmin;    d_xmax=xmax;    d_ymin=ymin;    d_ymax=ymax;    /* for limited screen drawing */
    drawscreen();
    if (xmin<=0 && xmax==MAXX) /* draw stuff on right side of screen as needed*/
        {
        for (i=ymin; i<ymax; i++)
            {
            idx = bot_data[i].typ;
            if (c[idx])
                {
                cursor(70,i+1); lprcat(bot_data[i].string);
                }
            cbak[idx]=c[idx];
            }
        }
    }

#ifdef DECRainbow
 static int DECgraphics;     /* The graphics mode toggle */

# define DECgraphicsON() if (!DECgraphics) lprc('\16'), DECgraphics = 1
# define DECgraphicsOFF() if (DECgraphics) lprc('\17'), DECgraphics = 0

/* For debugging on a non-DEC
# define DECgraphicsON() if (!DECgraphics) lprcat("\33[4m"), DECgraphics = 1
# define DECgraphicsOFF() if (DECgraphics) lprcat("\33[0m"), DECgraphics = 0
*/

# define DEClprc(ch)    if (ch & 0x80) {\
                            DECgraphicsON();\
                            lprc(ch ^ 0x80);\
                        } else {\
                            DECgraphicsOFF();\
                            lprc(ch);\
                        }
#define nlprc(_ch) DEClprc(_ch)
# else
#define nlprc(_ch) lprc(_ch)
#endif DECRainbow

/*
    drawscreen()

    subroutine to redraw the whole screen as the player knows it
 */
static char d_flag;
drawscreen()
    {
    register int i,j,k,ileft,iright;

    if (d_xmin==0 && d_xmax==MAXX && d_ymin==0 && d_ymax==MAXY)
        {
        d_flag=1;  clear(); /* clear the screen */
        }
    else
        {
        d_flag=0;  cursor(1,1);
        }
    if (d_xmin<0)
        d_xmin=0; /* d_xmin=-1 means display all without bottomline */

    /* display lines of the screen
    */
    for ( j = d_ymin ; j < d_ymax ; j++ )
        {
        /* When we show a spot of the dungeon, we have 4 cases:
            squares we know nothing about
                - know == 0
            squares we've been at and still know whats there
                - know == KNOWALL (== KNOWHERE | HAVESEEN)
            squares we've been at, but don't still recall because
            something else happened there.
                - know == HAVESEEN
            squares we recall, but haven't been at (an error condition)
                - know == KNOWHERE

           to minimize printing of spaces, scan from left of line until
           we reach a location that the user knows.
        */
        ileft = d_xmin - 1;
        while ( ++ileft < d_xmax )
            if (know[ileft][j])     /* instead of know[i][j] != 0 */
                break;              /* exitloop while */

        /* if not a blank line ... */
        if ( ileft < d_xmax )
            {
            /* scan from right of line until we reach a location that the
               user knows.
            */
            iright = d_xmax ;
            while ( --iright > ileft )
                if (know[iright][j])
                    break ;    /* exitloop while */

            /* now print the line, after positioning the cursor.
               print the line with bold objects in a different
               loop for effeciency
            */
            cursor( ileft+1, j+1 );
            if (boldobjects)
                for ( i=ileft ; i <= iright ; i++ )

                    /* we still need to check for the location being known,
                       for we might have an unknown spot in the middle of
                       an otherwise known line.
                    */
                    if ( know[i][j] == 0 )
                        nlprc( ' ' );
                    else if ( know[i][j] & HAVESEEN )
                        {
                        /* if monster there and the user still knows the place,
                           then show the monster.  Otherwise, show what was
                           there before.
                        */
                        if (( i == playerx ) &&
                            ( j == playery ))
                            nlprc('@');
                        else if (( k = mitem[i][j] ) &&
                            ( know[i][j] & KNOWHERE ))
                            nlprc( monstnamelist[k] );
                        else if (((k=item[i][j]) == OWALL ) ||
                                 (objnamelist[k] == floorc))
                            nlprc( objnamelist[k] );
                        else
                            {
                            setbold();
                            nlprc( objnamelist[k] );
                            resetbold();
                            }
                        }
                    else
                        /* error condition.  recover by resetting location
                           to an 'unknown' state.
                        */
                        {
                        nlprc( ' ' );
                        mitem[i][j] = item[i][j] = 0 ;
                        }
            else /* non-bold objects here */
                for ( i=ileft ; i <= iright ; i++ )

                    /* we still need to check for the location being known,
                       for we might have an unknown spot in the middle of
                       an otherwise known line.
                    */
                    if ( know[i][j] == 0 )
                        nlprc( ' ' );
                    else if ( know[i][j] & HAVESEEN )
                        {
                        /* if monster there and the user still knows the place,
                           then show the monster.  Otherwise, show what was
                           there before.
                        */
                        if (( i == playerx ) &&
                            ( j == playery ))
                            nlprc('@');
                        else if (( k = mitem[i][j] ) &&
                            ( know[i][j] & KNOWHERE ))
                            nlprc( monstnamelist[k] );
                        else
                            nlprc( objnamelist[item[i][j]] );
                        }
                    else
                        /* error condition.  recover by resetting location
                           to an 'unknown' state.
                        */
                        {
                        nlprc( ' ' );
                        mitem[i][j] = item[i][j] = 0 ;
                        }
            }   /* if (ileft < d_xmax ) */
        }       /* for (j) */

#ifdef DECRainbow
    if (DECRainbow)
        DECgraphicsOFF();
#endif DECRainbow
    resetbold();
    if (d_flag)  { always=1; botside(); always=1; bot_linex(); }
/*
    oldx=99;
*/
    d_xmin = d_ymin = 0; d_xmax = MAXX; d_ymax = MAXY; /* for limited screen drawing */
    }

/*
    showcell(x,y)

    subroutine to display a cell location on the screen
 */
showcell(x,y)
    int x,y;
    {
    register int i,j,k,m;
    if (c[BLINDCOUNT])  return; /* see nothing if blind     */
    if (c[AWARENESS]) { minx = x-3; maxx = x+3; miny = y-3; maxy = y+3; }
            else      { minx = x-1; maxx = x+1; miny = y-1; maxy = y+1; }

    if (minx < 0) minx=0;       if (maxx > MAXX-1) maxx = MAXX-1;
    if (miny < 0) miny=0;       if (maxy > MAXY-1) maxy = MAXY-1;

    for (j=miny; j<=maxy; j++)
      for (m=minx; m<=maxx; m++)
        if ((know[m][j] & KNOWHERE) == 0)
            {
            cursor(m+1,j+1);
        x=maxx;
        while (know[x][j] & KNOWHERE)
        --x;
            for (i=m; i<=x; i++)
                {
                if ((k=mitem[i][j]) != 0)  lprc(monstnamelist[k]);
                else switch(k=item[i][j])
                    {
                    case OWALL:  case 0: case OIVTELETRAP:  case OTRAPARROWIV:
                    case OIVDARTRAP: case OIVTRAPDOOR:
#ifdef DECRainbow
                        if (DECRainbow) {
                            DEClprc(objnamelist[k]);
                        } else
#endif DECRainbow
                        lprc(objnamelist[k]);   
                        break;
                    default:
                        if (boldobjects)
                            setbold();
                        lprc(objnamelist[k]);
                        if (boldobjects)
                            resetbold();
                        break;
                    };
                know[i][j] = KNOWALL;
                }
            m = maxx;
#ifdef DECRainbow
            if (DECRainbow)
                DECgraphicsOFF();
#endif DECRainbow
            }
    }

/*
    this routine shows only the spot that is given it.  the spaces around
    these coordinated are not shown
    used in godirect() in monster.c for missile weapons display
 */
show1cell(x,y)
    int x,y;
    {
    cursor(x+1,y+1);

    /* see nothing if blind, but clear previous player position
    */
    if (c[BLINDCOUNT])
        {
        if ((x == oldx) && (y == oldy))
            lprc(' ');
        return;
        }

    if ((k=mitem[x][y]))
        lprc(monstnamelist[k]);
    else switch(k=item[x][y])
        {
        case OWALL:  case 0:  case OIVTELETRAP:  case OTRAPARROWIV:
        case OIVDARTRAP: case OIVTRAPDOOR:
# ifdef DECRainbow
            if (DECRainbow) {
                DEClprc(objnamelist[k]);
                DECgraphicsOFF();
            } else
# endif
                lprc(objnamelist[k]);
                break;

        default:
            if (boldobjects)
                setbold();
            lprc(objnamelist[k]);
            if (boldobjects)
                resetbold();
            break;
        };
    know[x][y] = KNOWALL;   /* we end up knowing about it */
    }

/*
    showplayer()

    subroutine to show where the player is on the screen
    cursor values start from 1 up
 */
showplayer()
    {
    show1cell( oldx, oldy );
    cursor(playerx+1,playery+1);
    lprc('@');
    cursor(playerx+1,playery+1);
    oldx=playerx;  oldy=playery;
    }

/*
    moveplayer(dir)

    subroutine to move the player from one room to another
    returns 0 if can't move in that direction or hit a monster or on an object
    else returns 1
    nomove is set to 1 to stop the next move (inadvertent monsters hitting
    players when walking into walls) if player walks off screen or into wall
 */
short diroffx[] = { 0,  0, 1,  0, -1,  1, -1, 1, -1 };
short diroffy[] = { 0,  1, 0, -1,  0, -1, -1, 1,  1 };
moveplayer(dir)
    int dir;            /*  from = present room #  direction = [1-north]
                            [2-east] [3-south] [4-west] [5-northeast]
                            [6-northwest] [7-southeast] [8-southwest]
                        if direction=0, don't move--just show where he is */
    {
    register int k,m,i,j;
    extern char prayed ;

    if (c[CONFUSE]) if (c[LEVEL]<rnd(30)) dir=rund(9); /*if confused any dir*/
    k = playerx + diroffx[dir];     m = playery + diroffy[dir];
    if (k<0 || k>=MAXX || m<0 || m>=MAXY) { nomove=1; return(yrepcount = 0); }
    i = item[k][m];         j = mitem[k][m];

    /* prevent the player from moving onto a wall, or a closed door when
       in command mode, unless the character has Walk-Through-Walls.
    */
    if ((i==OCLOSEDDOOR && !prompt_mode) || (i==OWALL) && c[WTW]==0)
        { 
        nomove=1;  
        return(yrepcount = 0); 
        }
    if (k==33 && m==MAXY-1 && level==1)
        {
        newcavelevel(0); 
        for (k=0; k<MAXX; k++) 
            for (m=0; m<MAXY; m++)
                if (item[k][m]==OENTRANCE)
                    { 
                    playerx=k; 
                    playery=m; 
                    positionplayer();  
                    drawscreen(); 
                    return(0); 
                    }
        }
    /* hit a monster
    */    
    if (j>0)     
        { hitmonster(k,m); return(yrepcount = 0); } 

    /* check for the player ignoring an altar when in command mode.
    */
    if ((!prompt_mode) &&
        (item[playerx][playery] == OALTAR) &&
        (!prayed))
        {
    cursors();
    lprcat("\nYou have ignored the altar!");
    act_ignore_altar();
    }
    prayed = 0 ;

    lastpx = playerx;   lastpy = playery;
    playerx = k;        playery = m;
    if (i && i!=OTRAPARROWIV && i!=OIVTELETRAP && i!=OIVDARTRAP && i!=OIVTRAPDOOR) 
        return(yrepcount = 0);  
    else 
        return(1);
    }

/*
 *  function to show what magic items have been discovered thus far
 *  enter with -1 for just spells, anything else will give scrolls & potions
 */
static int lincount,count;
seemagic(arg)
    int arg;
    {
    register int i,j,k,number;
    char sort[SPNUM+1]; /* OK as long as SPNUM > MAXSCROLL,MAXPOTION */

    count = lincount = 0;
    nosignal=1;

    /* count and sort the known spell codes
    */
    for (j=0; j <= SPNUM ; j++ )
        sort[j] = SPNUM ;
    for (number = i = 0 ; i < SPNUM ; i++ )
        if (spelknow[i])
            {
            number++;
            j = 0 ;
            while ( strncmp( spelcode[ sort[j] ], spelcode[ i ], 3 ) < 0 )
                j++ ;
            k = number - 1;
            while ( k > j )
                sort[k] = sort[ k-1 ], k-- ;
            sort[j] = i ;
            }

    if (arg == -1) /* if display spells while casting one */
        {
        cl_up(79, ((number + 2) / 3 + 4 )); /* lines needed for display */
        cursor(1,1);
        }
    else
        {
        resetscroll();
        clear();
        }

    lprcat("The magic spells you have discovered thus far:\n\n");
    for (i=0; i<number; i++)
        {
        lprintf("%s %-20s ",spelcode[sort[i]],spelname[sort[i]]);
        seepage();
        }

    if (arg== -1)
        {
        seepage();
        more(FALSE);
        nosignal=0;
        draws(0,MAXX,0, (( number + 2 ) / 3 + 4 ));
        return;
        }

    lincount += 3;
    if (count!=0)
        {
        count=2;
        seepage();
        }

    /* count and sort the known scrolls
    */
    for (j=0; j <= MAXSCROLL ; j++ )
        sort[j] = MAXSCROLL ;
    for (number = i = 0 ; i < MAXSCROLL ; i++ )
        if (scrollname[i][0])
            {
            number++;
            j = 0 ;
            while ( strcmp( &scrollname[sort[j]][1], &scrollname[i][1] ) < 0 )
                j++ ;
            k = number - 1;
            while ( k > j )
                sort[k] = sort[ k-1 ], k-- ;
            sort[j] = i ;
            }

    lprcat("\nThe magic scrolls you have found to date are:\n\n");
    count=0;
    for (i=0; i < number; i++ )
        {
        lprintf("%-26s", &scrollname[sort[i]][1]);
        seepage();
        }

    lincount += 3;
    if ( count != 0 )
        {
        count=2;
        seepage();
        }

    /* count and sort the known potions
    */
    for (j=0; j <= MAXPOTION ; j++ )
        sort[j] = MAXPOTION ;
    for (number = i = 0 ; i < MAXPOTION ; i++ )
        if (potionname[i][0])
            {
            number++;
            j = 0 ;
            while ( strcmp( &potionname[sort[j]][1], &potionname[i][1] ) < 0 )
                j++ ;
            k = number - 1;
            while ( k > j )
                sort[k] = sort[ k-1 ], k-- ;
            sort[j] = i ;
            }

    lprcat("\nThe magic potions you have found to date are:\n\n");
    count=0;
    for (i=0; i < number; i++)
        {
        lprintf("%-26s",&potionname[sort[i]][1]);
        seepage();
        }

    if (lincount!=0)
        more(FALSE);
    nosignal=0;
    setscroll();
    drawscreen();
    }

/*
 *  subroutine to paginate the seemagic function
 */
static seepage()
    {
    if (++count==3)
        {
        lincount++; count=0;    lprc('\n');
        if (lincount>17) {  lincount=0;  more(FALSE);  clear();  }
        }
    }
