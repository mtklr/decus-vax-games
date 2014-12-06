#include "header.h"
#include "larndefs.h"
#include "objects.h"
#include "player.h"

#ifdef __STDC__
	    show1( int, char*[] );
            show3( int );
static      show2( int );
static void t_setup( int );
static void t_endup( int );

#define SIGNED signed
#else
	    show1( );
            show3( );
static      show2( );
static void t_setup( );
static void t_endup( );

#define SIGNED
#endif

static int  qshowstr();
showwear();
showwield();
showread();
showquaff();
showeat();
extern int dropflag;

/* Allow only 26 items (a to z) in the player's inventory */
#define MAXINVEN 26

/* The starting limit to the number of items the player can carry.  
   The limit should probably be based on player strength and the
   weight of the items.
*/
#define MIN_LIMIT 15

/* define a sentinel to place at the end of the sorted inventory.
   (speeds up display reads )
*/
#define END_SENTINEL 255

/* declare the player's inventory.  These should only be referenced
   in this module.
    iven     - objects in the player's inventory
    ivenarg  - attribute of each item ( + values, etc )
    ivensort - sorted inventory (so we don't sort each time)
*/
char iven[MAXINVEN];
SIGNED  short ivenarg[MAXINVEN];
unsigned char ivensort[MAXINVEN+1];    /* extra is for sentinel */

static char srcount = 0 ; /* line counter for showstr() */

/*
  Initialize the player's inventory
*/
void init_inventory( )
    {
    int i;

    for ( i = 0; i < MAXINVEN ; i++ )
        {
    iven[i] = ivenarg[i] = 0;
    ivensort[i] = END_SENTINEL ;
    }
    ivensort[MAXINVEN] = END_SENTINEL;

    /* For zero difficulty games, start the player out with armor and weapon.
       We can sort the inventory right away because a dagger is 'later' than
       leather armor.
    */
    if (c[HARDGAME] <= 0)
    {
    iven[0] = OLEATHER;
    iven[1] = ODAGGER;
    ivenarg[0] = ivenarg[1] = c[WEAR] = ivensort[0] = 0;
    ivensort[1] = c[WIELD] = 1;
    }
    }

/*
    show character's inventory
*/
showstr(select_allowed)
char select_allowed;
    {
    register int i,number, item_select;

    for (number=3, i=0; i<MAXINVEN; i++)
        if (iven[i])
            number++;  /* count items in inventory */
    t_setup(number);
    item_select = qshowstr(select_allowed);
    t_endup(number);
    return( item_select );
    }

static int qshowstr(select_allowed)
char select_allowed;
    {
    register int i,j,k,sigsav,itemselect=0;

    srcount=0;
    sigsav=nosignal;
    nosignal=1; /* don't allow ^c etc */
    if (c[GOLD])
        {
        lprintf(".)   %d gold pieces",(long)c[GOLD]);
        srcount++;
        }
    for (k=(MAXINVEN-1); k>=0; k--)
      if (iven[k])
        {
        for (i=22; i<84; i++)
             for (j=0; j<=k; j++)
                 if (i==iven[j])
             {
             itemselect = show2(j);
             if (itemselect && select_allowed)
            goto quitit;
             }
        k=0;
        }

    lprintf("\nElapsed time is %d.  You have %d mobuls left",(long)((gtime+99)/100+1),(long)((TIMELIMIT-gtime)/100));
    itemselect = more(select_allowed);     
quitit:
    nosignal=sigsav;
    if (select_allowed)
    return( (itemselect > 0) ? itemselect : 0 );
    else
    return( 0 );
    }

/*
 subroutine to clear screen depending on # lines to display

*/
static void t_setup(count)
register int count;
    {
    if (count<20)  /* how do we clear the screen? */
        {
        cl_up(79,count);
        cursor(1,1);
        }
    else
        {
        resetscroll();
        clear();
        }
    }

/*
 subroutine to restore normal display screen depending on t_setup()

*/
static void t_endup(count)
register int count;
    {
    if (count<18)  /* how did we clear the screen? */
        draws(0,MAXX,0,(count>MAXY) ? MAXY : count);
    else
        {
        drawscreen(); 
        setscroll();
        }
    }

/*
    function to show the things player is wearing only
 */
showwear()
    {
    register int i,j,sigsav,count,itemselect=0;

    sigsav=nosignal;  nosignal=1; /* don't allow ^c etc */
    srcount=0;

    for (count=2,j=0; j< MAXINVEN; j++)   /* count number of items we will display */
        if (i=iven[j])
            switch(i)
            {
            case OLEATHER:  case OPLATE:    case OCHAIN:
            case ORING:     case OSTUDLEATHER:  case OSPLINT:
            case OPLATEARMOR:   case OSSPLATE:  case OSHIELD:
            count++;
            };

    t_setup(count);

    for (i=22; i<84; i++)
         for (j=0; j< MAXINVEN; j++)
           if (i==iven[j])
            switch(i)
                {
                case OLEATHER:  case OPLATE:    case OCHAIN:
                case ORING:     case OSTUDLEATHER:  case OSPLINT:
                case OPLATEARMOR:   case OSSPLATE:  case OSHIELD:
                if (itemselect = show2(j))
            goto quitit;
                };
    itemselect = more(TRUE);     
quitit:
    nosignal=sigsav;    
    t_endup(count);
    return( (itemselect > 1) ? itemselect : 0 );
    }

/*
    function to show the things player can wield only
 */
showwield()
    {
    register int i,j,sigsav,count,itemselect=0;
    sigsav=nosignal;  nosignal=1; /* don't allow ^c etc */
    srcount=0;

     for (count=2,j=0; j< MAXINVEN; j++)  /* count how many items */
       if (i=iven[j])
        switch(i)
            {
            case ODIAMOND:  case ORUBY:  case OEMERALD:  case OSAPPHIRE:
            case OBOOK:     case OCHEST:  case OLARNEYE: case ONOTHEFT:
            case OSPIRITSCARAB:  case OCUBEofUNDEAD:
            case OPOTION:   case OSCROLL:  break;
            default:  count++;
            };

    t_setup(count);

    for (i=22; i<84; i++)
         for (j=0; j< MAXINVEN; j++)
           if (i==iven[j])
            switch(i)
                {
                case ODIAMOND:  case ORUBY:  case OEMERALD:  case OSAPPHIRE:
                case OBOOK:     case OCHEST:  case OLARNEYE: case ONOTHEFT:
                case OSPIRITSCARAB:  case OCUBEofUNDEAD:
                case OPOTION:   case OSCROLL:  
            break;
                default:  
            if (itemselect = show2(j))
            goto quitit;
                };
    itemselect = more(TRUE);     
quitit:
    nosignal=sigsav;    
    t_endup(count);
    return( (itemselect > 1) ? itemselect : 0 );
    }

/*
 *  function to show the things player can read only
 */
showread()
    {
    register int i,j,sigsav,count,itemselect = 0;
    sigsav=nosignal;  nosignal=1; /* don't allow ^c etc */
    srcount=0;

    for (count=2,j=0; j< MAXINVEN; j++)
        switch(iven[j])
            {
            case OBOOK: case OSCROLL:   count++;
            };
    t_setup(count);

    for (i=22; i<84; i++)
         for (j=0; j< MAXINVEN; j++)
           if (i==iven[j])
            switch(i)
                {
                case OBOOK: case OSCROLL:
            if (itemselect = show2(j))
            goto quitit;
                };
    itemselect = more(TRUE);
quitit:
    nosignal=sigsav;
    t_endup(count);
    return((itemselect > 1) ? itemselect : 0 );
    }

/*
 *  function to show the things player can eat only
 */
showeat()
    {
    register int i,j,sigsav,count,itemselect=0;
    sigsav=nosignal;  nosignal=1; /* don't allow ^c etc */
    srcount=0;

    for (count=2,j=0; j< MAXINVEN; j++)
        switch(iven[j])
            {
            case OCOOKIE:   count++;
            };
    t_setup(count);

    for (i=22; i<84; i++)
         for (j=0; j< MAXINVEN; j++)
           if (i==iven[j])
            switch(i)
                {
                case OCOOKIE:   
            if (itemselect=show2(j))
            goto quitit;
                };
    itemselect = more(TRUE);     
quitit:
    nosignal=sigsav;    
    t_endup(count);
    return( (itemselect > 1) ? itemselect : 0 );
    }

/*
    function to show the things player can quaff only
 */
showquaff()
    {
    register int i,j,sigsav,count,itemselect=0;
    sigsav=nosignal;  nosignal=1; /* don't allow ^c etc */
    srcount=0;

    for (count=2,j=0; j< MAXINVEN; j++)
        switch(iven[j])
            {
            case OPOTION:   count++;
            };
    t_setup(count);

    for (i=22; i<84; i++)
         for (j=0; j< MAXINVEN; j++)
           if (i==iven[j])
            switch(i)
                {
                case OPOTION:
            if (itemselect=show2(j))
            goto quitit;
                };
    itemselect = more(TRUE);
quitit:
    nosignal=sigsav;
    t_endup(count);
    return( (itemselect > 1 ) ? itemselect : 0 );
    }

show1(idx,str2)
    register int idx;
    register char *str2[];
    {
        lprc('\n');
        cltoeoln();
    if (str2==0)
        lprintf("%c)   %s",idx+'a',objectname[iven[idx]]);
    else if (*str2[ivenarg[idx]]==0)
        lprintf("%c)   %s",idx+'a',objectname[iven[idx]]);
    else
        lprintf("%c)   %s of%s",idx+'a',objectname[iven[idx]],str2[ivenarg[idx]]);
    }

show3(index)
register int index ;
    {
    srcount=0;
    return( show2(index) );
    }

static int show2(index)
register int index;
    {
    register int itemselect = 0;

    switch(iven[index])
        {
        case OPOTION:   show1(index,potionname);  break;
        case OSCROLL:   show1(index,scrollname);  break;

        case OLARNEYE:      case OBOOK:         case OSPIRITSCARAB:
        case ODIAMOND:      case ORUBY:         case OCUBEofUNDEAD:
        case OEMERALD:      case OCHEST:        case OCOOKIE:
        case OSAPPHIRE:     case ONOTHEFT:      show1(index,(char **)0);  break;

        default:
        lprc('\n');
        cltoeoln();
        lprintf("%c)   %s",index+'a',objectname[iven[index]]);
        if (ivenarg[index]>0)
            lprintf(" + %d",(long)ivenarg[index]);
        else if (ivenarg[index]<0)
            lprintf(" %d",(long)ivenarg[index]);
        break;
        }
    if (c[WIELD]==index) lprcat(" (weapon in hand)");
    if ((c[WEAR]==index) || (c[SHIELD]==index))  lprcat(" (being worn)");
    if (++srcount>=22) 
    { 
    srcount=0; 
    itemselect = more(TRUE); 
    clear(); 
    }
    return( itemselect );
    }

/*
    function to put something in the players inventory
    returns 0 if success, 1 if a failure
*/
take(itm,arg)
    int itm,arg;
    {
    register int i,limit;
/*  cursors(); */
    if ((limit = 15+(c[LEVEL]>>1)) > MAXINVEN)
        limit=MAXINVEN;
    for (i=0; i<limit; i++)
        if (iven[i]==0)
            {
            iven[i] = itm;  ivenarg[i] = arg;  limit=0;
            switch(itm)
                {
                case OPROTRING: case ODAMRING: case OBELT: limit=1;  break;
                case ODEXRING:      c[DEXTERITY] += ivenarg[i]+1; limit=1;  break;
                case OSTRRING:      c[STREXTRA]  += ivenarg[i]+1;   limit=1; break;
                case OCLEVERRING:   c[INTELLIGENCE] += ivenarg[i]+1;  limit=1; break;
                case OHAMMER:       c[DEXTERITY] += 10; c[STREXTRA]+=10;
                                    c[INTELLIGENCE]-=10;    limit=1;     break;

                case OORBOFDRAGON:  c[SLAYING]++;       break;
                case OSPIRITSCARAB: c[NEGATESPIRIT]++;  break;
                case OCUBEofUNDEAD: c[CUBEofUNDEAD]++;  break;
                case ONOTHEFT:      c[NOTHEFT]++;       break;
                case OSWORDofSLASHING:  c[DEXTERITY] +=5;   limit=1; break;
                };
            lprcat("\nYou pick up:"); show3(i);
            if (limit) bottomline();  return(0);
            }
    lprcat("\nYou can't carry anything else");  return(1);
    }

/*
    subroutine to drop an object  returns 1 if something there already else 0
 */
drop_object(k)
    int k;
    {
    int itm;
    if ((k<0) || (k>=MAXINVEN)) 
    return(0);
    itm = iven[k];  cursors();
    if (itm==0) { lprintf("\nYou don't have item %c! ",k+'a'); return(1); }
    if (item[playerx][playery])
        { beep(); lprcat("\nThere's something here already"); return(1); }
    if (playery==MAXY-1 && playerx==33) return(1); /* not in entrance */
    item[playerx][playery] = itm;
    iarg[playerx][playery] = ivenarg[k];
    lprcat("\n  You drop:"); show3(k); /* show what item you dropped*/
    know[playerx][playery] = 0;  iven[k]=0; 
    if (c[WIELD]==k) c[WIELD]= -1;      if (c[WEAR]==k)  c[WEAR] = -1;
    if (c[SHIELD]==k) c[SHIELD]= -1;
    adjustcvalues(itm,ivenarg[k]);
    dropflag=1; /* say dropped an item so wont ask to pick it up right away */
    return(0);
    }

/*
    routine to tell if player can carry one more thing
    returns 1 if pockets are full, else 0
*/
pocketfull()
    {
    register int i,limit; 
    if ((limit = MIN_LIMIT + (c[LEVEL]>>1) ) > MAXINVEN )  
    limit = MAXINVEN;
    for (i=0; i<limit; i++) 
    if (iven[i]==0) 
        return(0);
    return(1);
    }
