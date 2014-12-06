/*
 *  monster.c
 *
 *  createmonster(monstno)      Function to create a monster next to the player
 *      int monstno;
 *
 *  int cgood(x,y,itm,monst)    Function to check location for emptiness
 *      int x,y,itm,monst;
 *
 *  createitem(it,arg)          Routine to place an item next to the player
 *      int it,arg;
 *
 *  vxy(x,y)            Routine to verify/fix (*x,*y) for being within bounds
 *      int *x,*y;
 *
 *  hitmonster(x,y)     Function to hit a monster at the designated coordinates
 *      int x,y;
 *
 *  hitm(x,y,amt)       Function to just hit a monster at a given coordinates
 *      int x,y,amt;
 *
 *  hitplayer(x,y)      Function for the monster to hit the player from (x,y)
 *      int x,y;
 *
 *  dropsomething(monst)    Function to create an object when a monster dies
 *      int monst;
 *
 *  dropgold(amount)        Function to drop some gold around player
 *      int amount;
 *
 *  something(level)        Function to create a random item around player
 *      int level;
 *
 *  newobject(lev,i)        Routine to return a randomly selected new object
 *      int lev,*i;
 *
 *  spattack(atckno,xx,yy)  Function to process special attacks from monsters
 *      int atckno,xx,yy;
 *
 *  checkloss(x)    Routine to subtract hp from user and flag bottomline display
 *      int x;
 *
 */
#include "header.h"
#include "larndefs.h"
#include "monsters.h"
#include "objects.h"
#include "player.h"

#include <ctype.h>
#define min(x,y) (((x)>(y))?(y):(x))
#define max(x,y) (((x)>(y))?(x):(y))

extern fullhit(), ifblind();

/*
 *  createmonster(monstno)      Function to create a monster next to the player
 *      int monstno;
 *
 *  Enter with the monster number (1 to MAXMONST+8)
 *  Returns no value.
 */
createmonster(mon)
    int mon;
    {
    register int x,y,k,i;
    if (mon<1 || mon>MAXMONST+8)    /* check for monster number out of bounds */
        {
        beep(); lprintf("\ncan't createmonst(%d)\n",(long)mon); nap(3000); return;
        }
    while (monster[mon].genocided && mon<MAXMONST) mon++; /* genocided? */
    for (k=rnd(8), i= -8; i<0; i++,k++) /* choose direction, then try all */
        {
        if (k>8) k=1;   /* wraparound the diroff arrays */
        x = playerx + diroffx[k];       y = playery + diroffy[k];
        if (cgood(x,y,0,1)) /* if we can create here */
            {
            mitem[x][y] = mon;
            hitp[x][y] = monster[mon].hitpoints;
            stealth[x][y]=0;
            know[x][y] &= ~KNOWHERE;
            switch(mon)
                {
                case ROTHE: case POLTERGEIST: case VAMPIRE: stealth[x][y]=1;
                };
            return;
            }
        }
    }

/*
 *  int cgood(x,y,itm,monst)      Function to check location for emptiness
 *      int x,y,itm,monst;
 *
 *  Routine to return TRUE if a location does not have itm or monst there
 *  returns FALSE (0) otherwise
 *  Enter with itm or monst TRUE or FALSE if checking it
 *  Example:  if itm==TRUE check for no item at this location
 *            if monst==TRUE check for no monster at this location
 *  This routine will return FALSE if at a wall,door or the dungeon exit
 *  on level 1
 */
static int cgood(x,y,itm,monst)
    register int x,y;
    int itm,monst;
    {
    /* cannot create either monster or item if:
       - out of bounds
       - wall
       - closed door
       - dungeon entrance
    */
    if (((y < 0) || (y > MAXY-1) || (x < 0) || (x > MAXX-1)) ||
         (item[x][y] == OWALL) ||
         (item[x][y] == OCLOSEDDOOR) ||
         ((level == 1) && (x == 33) && (y == MAXY-1)))
        return( FALSE );

    /* if checking for an item, return False if one there already
    */
    if ( itm && item[x][y])
        return( FALSE );

    /* if checking for a monster, return False if one there already _or_
       there is a pit/trap there.
    */
    if (monst)
        {
        if (mitem[x][y])
            return (FALSE);
        switch(item[x][y])
            {
            /* note: not invisible traps, since monsters are not affected
               by them.
            */
            case OPIT:         case OANNIHILATION:
            case OTELEPORTER:  case OTRAPARROW:
            case ODARTRAP:    case OTRAPDOOR:
                return(FALSE);
                break;
            default:
                break;
            }
        }
    return(TRUE);
    }

/*
 *  createitem(it,arg)      Routine to place an item next to the player
 *      int it,arg;
 *
 *  Enter with the item number and its argument (iven[], ivenarg[])
 *  Returns no value, thus we don't know about createitem() failures.
 */
createitem(it,arg)
    int it,arg;
    {
    register int x,y,k,i;
    if (it >= MAXOBJ) return;   /* no such object */
    for (k=rnd(8), i= -8; i<0; i++,k++) /* choose direction, then try all */
        {
        if (k>8) k=1;   /* wraparound the diroff arrays */
        x = playerx + diroffx[k];       y = playery + diroffy[k];
        if (cgood(x,y,1,0)) /* if we can create here */
            {
            item[x][y] = it;  know[x][y]=0;  iarg[x][y]=arg;  return;
            }
        }
    }


/*
 *  vxy(x,y)       Routine to verify/fix coordinates for being within bounds
 *      int *x,*y;
 *
 *  Function to verify x & y are within the bounds for a level
 *  If *x or *y is not within the absolute bounds for a level, fix them so that
 *    they are on the level.
 *  Returns TRUE if it was out of bounds, and the *x & *y in the calling
 *  routine are affected.
 */
vxy(x,y)
    int *x,*y;
    {
    int flag=0;
    if (*x<0) { *x=0; flag++; }
    if (*y<0) { *y=0; flag++; }
    if (*x>=MAXX) { *x=MAXX-1; flag++; }
    if (*y>=MAXY) { *y=MAXY-1; flag++; }
    return(flag);
    }

/*
 *  hitmonster(x,y)     Function to hit a monster at the designated coordinates
 *      int x,y;
 *
 *  This routine is used for a bash & slash type attack on a monster
 *  Enter with the coordinates of the monster in (x,y).
 *  Returns no value.
 */
hitmonster(x,y)
    int x,y;
    {
    extern char lastmonst[] ;
    register int tmp,monst,damag,flag;
    if (c[TIMESTOP])  return;  /* not if time stopped */
    vxy(&x,&y); /* verify coordinates are within range */
    if ((monst = mitem[x][y]) == 0) return;
    hit3flag=1;  ifblind(x,y);
    tmp = monster[monst].armorclass + c[LEVEL] + c[DEXTERITY] + c[WCLASS]/4 - 12;
    cursors();
    if ((rnd(20) < tmp-c[HARDGAME]) || (rnd(71) < 5)) /* need at least random chance to hit */
        {
        lprcat("\nYou hit");  flag=1;
        damag = fullhit(1);
        if (damag<9999) damag=rnd(damag)+1;
        }
    else
        {
        lprcat("\nYou missed");  flag=0;
        }
    lprcat(" the "); lprcat(lastmonst);
    if (flag)   /* if the monster was hit */
      if ((monst==RUSTMONSTER) || (monst==DISENCHANTRESS) || (monst==CUBE))
        if (c[WIELD]>=0)
          if (ivenarg[c[WIELD]] > -10)
            {
            lprintf("\nYour weapon is dulled by the %s",lastmonst); beep();
            --ivenarg[c[WIELD]];

            /* fix for dulled rings of strength,cleverness, and dexterity
               bug.
            */
            switch (iven[c[WIELD]])
                {
                case ODEXRING :
                    c[DEXTERITY]--;
                    break;
                case OSTRRING :
                    c[STREXTRA]--;
                    break;
                case OCLEVERRING :
                    c[INTELLIGENCE]--;
                    break;
                }
            }
    if (flag)  hitm(x,y,damag);
    if (monst == VAMPIRE) if (hitp[x][y]<25)  { mitem[x][y]=BAT; know[x][y]=0; }
    }

/*
 *  hitm(x,y,amt)       Function to just hit a monster at a given coordinates
 *      int x,y,amt;
 *
 *  Returns the number of hitpoints the monster absorbed
 *  This routine is used to specifically damage a monster at a location (x,y)
 *  Called by hitmonster(x,y)
 */
hitm(x,y,amt)
    int x,y;
    register amt;
    {
    extern char lastmonst[] ;
    register int monst;
    int hpoints,amt2;
    vxy(&x,&y); /* verify coordinates are within range */
    amt2 = amt;     /* save initial damage so we can return it */
    monst = mitem[x][y];
    if (c[HALFDAM]) amt >>= 1;  /* if half damage curse adjust damage points */
    if (amt<=0) amt2 = amt = 1;
    lasthx=x;  lasthy=y;
    stealth[x][y]=1;    /* make sure hitting monst breaks stealth condition */
    c[HOLDMONST]=0; /* hit a monster breaks hold monster spell  */
    switch(monst) /* if a dragon and orb(s) of dragon slaying   */
        {
        case WHITEDRAGON:       case REDDRAGON:         case GREENDRAGON:
        case BRONZEDRAGON:      case PLATINUMDRAGON:    case SILVERDRAGON:
            amt *= 1+(c[SLAYING]<<1);   break;
        }
/* invincible monster fix is here */
    if (hitp[x][y] > monster[monst].hitpoints)
        hitp[x][y] = monster[monst].hitpoints;
    if ((hpoints = hitp[x][y]) <= amt)
        {
#ifdef EXTRA
        c[MONSTKILLED]++;
#endif
        lprintf("\nThe %s died!",lastmonst);
        raiseexperience((long)monster[monst].experience);
        amt = monster[monst].gold;  if (amt>0) dropgold(rnd(amt)+amt);
        dropsomething(monst);   disappear(x,y); bottomline();
        return(hpoints);
        }
    hitp[x][y] = hpoints-amt;   return(amt2);
    }

/*
 *  hitplayer(x,y)      Function for the monster to hit the player from (x,y)
 *      int x,y;
 *
 *  Function for the monster to hit the player with monster at location x,y
 *  Returns nothing of value.
 */
hitplayer(x,y)
    int x,y;
    {
    extern char lastmonst[] ;
    register int dam,tmp,mster,bias;
    vxy(&x,&y); /* verify coordinates are within range */
    lastnum = mster = mitem[x][y];
/*  spirit naga's and poltergeist's do nothing if scarab of negate spirit   */
    if (c[NEGATESPIRIT] || c[SPIRITPRO])  if ((mster ==POLTERGEIST) || (mster ==SPIRITNAGA))  return;
/*  if undead and cube of undead control    */
    if (c[CUBEofUNDEAD] || c[UNDEADPRO]) if ((mster ==VAMPIRE) || (mster ==WRAITH) || (mster ==ZOMBIE)) return;
    if ((know[x][y] & KNOWHERE) == 0)
        show1cell(x,y);
    bias = (c[HARDGAME]) + 1;
    hitflag = hit2flag = hit3flag = 1;
    yrepcount=0;
    cursors();  ifblind(x,y);
    if (c[INVISIBILITY]) if (rnd(33)<20) 
        {
        lprintf("\nThe %s misses wildly",lastmonst);    return;
        }
    if (c[CHARMCOUNT]) if (rnd(30)+5*monster[mster].level-c[CHARISMA]<30)
        {
        lprintf("\nThe %s is awestruck at your magnificence!",lastmonst);
        return;
        }
    if (mster==BAT) dam=1;
    else
        {
        dam = monster[mster].damage;
        dam += rnd((int)((dam<1)?1:dam)) + monster[mster].level;
        }
    tmp = 0;
    if (monster[mster].attack>0)
      if (((dam + bias + 8) > c[AC]) || (rnd((int)((c[AC]>0)?c[AC]:1))==1))
        { if (spattack(monster[mster].attack,x,y)) { lflushall(); return; }
          tmp = 1;  bias -= 2; cursors(); }
    if (((dam + bias) > c[AC]) || (rnd((int)((c[AC]>0)?c[AC]:1))==1))
        {
        lprintf("\n  The %s hit you ",lastmonst);   tmp = 1;
        if ((dam -= c[AC]) < 0) dam=0;
        if (dam > 0) { losehp(dam); bottomhp(); lflushall(); }
        }
    if (tmp == 0)  lprintf("\n  The %s missed ",lastmonst);
    }

/*
 *  dropsomething(monst)    Function to create an object when a monster dies
 *      int monst;
 *
 *  Function to create an object near the player when certain monsters are killed
 *  Enter with the monster number
 *  Returns nothing of value.
 */
static dropsomething(monst)
    int monst;
    {
    switch(monst)
        {
        case ORC:             case NYMPH:      case ELF:      case TROGLODYTE:
        case TROLL:           case ROTHE:      case VIOLETFUNGI:
        case PLATINUMDRAGON:  case GNOMEKING:  case REDDRAGON:
            something(level); return;

        case LEPRECHAUN: if (rnd(101)>=75) creategem();
                         if (rnd(5)==1) dropsomething(LEPRECHAUN);   return;
        }
    }

/*
 *  dropgold(amount)    Function to drop some gold around player
 *      int amount;
 *
 *  Enter with the number of gold pieces to drop
 *  Returns nothing of value.
 */
dropgold(amount)
    register int amount;
    {
    if (amount > 250) 
        createitem(OMAXGOLD,amount/100);  
    else  
        createitem(OGOLDPILE,amount);
    }

/*
 *  something(level)    Function to create a random item around player
 *      int level;
 *
 *  Function to create an item from a designed probability around player
 *  Enter with the cave level on which something is to be dropped
 *  Returns nothing of value.
 */
something(level)
    int level;
    {
    register int j;
    int i;
    if (level<0 || level>MAXLEVEL+MAXVLEVEL) return;    /* correct level? */
    if (rnd(101)<8)
        something(level); /* possibly more than one item */
    j = newobject(level,&i);
    createitem(j,i);
    }

/*
 *  newobject(lev,i)    Routine to return a randomly selected new object
 *      int lev,*i;
 *
 *  Routine to return a randomly selected object to be created
 *  Returns the object number created, and sets *i for its argument
 *  Enter with the cave level and a pointer to the items arg
 */
static char nobjtab[] = { 0, OSCROLL,  OSCROLL,  OSCROLL,  OSCROLL, OPOTION,
    OPOTION, OPOTION, OPOTION, OGOLDPILE, OGOLDPILE, OGOLDPILE, OGOLDPILE,
    OBOOK, OBOOK, OBOOK, OBOOK, ODAGGER, ODAGGER, ODAGGER, OLEATHER, OLEATHER,
    OLEATHER, OREGENRING, OPROTRING, OENERGYRING, ODEXRING, OSTRRING, OSPEAR,
    OBELT, ORING, OSTUDLEATHER, OSHIELD, OCOOKIE, OFLAIL, OCHAIN, OBATTLEAXE,
    OSPLINT, O2SWORD, OCLEVERRING, OPLATE, OLONGSWORD };

newobject(lev,i)
    register int lev,*i;
    {
    register int tmp=33,j;
    if (level<0 || level>MAXLEVEL+MAXVLEVEL) return(0); /* correct level? */
    if (lev>6) tmp=41; else if (lev>4) tmp=39;
    j = nobjtab[tmp=rnd(tmp)];  /* the object type */
    switch(tmp)
        {
        case 1: case 2: case 3: case 4:  /* scroll */
            *i=newscroll(); break;
        case 5: case 6: case 7: case 8:  /* potion */
            *i=newpotion(); break;
        case 9: case 10: case 11: case 12:  /* gold */
            *i=rnd((lev+1)*10)+lev*10+10; break;
        case 13: case 14: case 15: case 16:  /* book */
            *i=lev; break;
        case 17: case 18: case 19:   /* dagger */
            if (!(*i=newdagger()))  return(0);  break;
        case 20: case 21: case 22:   /* leather armor */
            if (!(*i=newleather()))  return(0);  break;
        case 23: case 32: case 38:   /* regen ring, shield, 2-hand sword */
            *i=rund(lev/3+1); break;
        case 24: case 26:            /* prot ring, dexterity ring */
            *i=rnd(lev/4+1);   break;
        case 25:                     /* energy ring */
            *i=rund(lev/4+1); break;
        case 27: case 39:            /* strength ring, cleverness ring */
            *i=rnd(lev/2+1);   break;
        case 30: case 34:           /* ring mail, flail */
            *i=rund(lev/2+1);   break;
        case 28: case 36:           /* spear, battleaxe */
            *i=rund(lev/3+1); if (*i==0) return(0); break;
        case 29: case 31: case 37:  /* belt, studded leather, splint */
            *i=rund(lev/2+1); if (*i==0) return(0); break;
        case 33:                    /* fortune cookie */
            *i=0; break;
        case 35:                    /* chain mail */
            *i=newchain();     break;
        case 40:                    /* plate mail */
            *i=newplate();     break;
        case 41:                    /* longsword */
            *i=newsword();     break;
        }
    return(j);
    }

/*
 *  spattack(atckno,xx,yy)  Function to process special attacks from monsters
 *      int atckno,xx,yy;
 *
 *  Enter with the special attack number, and the coordinates (xx,yy)
 *      of the monster that is special attacking
 *  Returns 1 if must do a show1cell(xx,yy) upon return, 0 otherwise
 *
 * atckno   monster     effect
 * ---------------------------------------------------
 *  0   none
 *  1   rust monster    eat armor
 *  2   hell hound      breathe light fire
 *  3   dragon          breathe fire
 *  4   giant centipede weakening sing
 *  5   white dragon    cold breath
 *  6   wraith          drain level
 *  7   waterlord       water gusher
 *  8   leprechaun      steal gold
 *  9   disenchantress  disenchant weapon or armor
 *  10  ice lizard      hits with barbed tail
 *  11  umber hulk      confusion
 *  12  spirit naga     cast spells taken from special attacks
 *  13  platinum dragon psionics
 *  14  nymph           steal objects
 *  15  bugbear         bite
 *  16  osequip         bite
 *
 *  char rustarm[ARMORTYPES][2];
 *  special array for maximum rust damage to armor from rustmonster
 *  format is: { armor type , minimum attribute 
 */
#define ARMORTYPES 6
#if __STDC__
static signed char rustarm[ARMORTYPES][2] =
#else
static char rustarm[ARMORTYPES][2] =
#endif
    { OSTUDLEATHER,-2, ORING,      -4,
      OCHAIN,      -5, OSPLINT,    -6,
      OPLATE,      -8, OPLATEARMOR,-9  };
static char spsel[] = { 1, 2, 3, 5, 6, 8, 9, 11, 13, 14 };
static spattack(x,xx,yy)
    int x,xx,yy;
    {
    extern char lastmonst[] ;
    register int i,j=0,k,m;
    register char *p=0;
    if (c[CANCELLATION]) return(0);
    vxy(&xx,&yy);   /* verify x & y coordinates */
    switch(x)
        {
        case 1: /* rust your armor, j=1 when rusting has occurred */
                m = k = c[WEAR];
                if ((i=c[SHIELD]) != -1)
                    if (--ivenarg[i] < -1) ivenarg[i]= -1; else j=1;
                if ((j==0) && (k != -1))
                  {
                  m = iven[k];
                  for (i=0; i<ARMORTYPES; i++)
                    if (m == rustarm[i][0]) /* find his armor in table */
                        {
                        if (--ivenarg[k]< rustarm[i][1])
                            ivenarg[k]= rustarm[i][1]; else j=1; 
                        break;
                        }
                  }
                if (j==0)   /* if rusting did not occur */
                  switch(m)
                    {
                    case OLEATHER:  p = "\nThe %s hit you -- Your lucky you have leather on";
                                    break;
                    case OSSPLATE:  p = "\nThe %s hit you -- Your fortunate to have stainless steel armor!";
                                    break;
                    }
                else  { beep(); p = "\nThe %s hit you -- your armor feels weaker"; }
                break;

        case 2:     i = rnd(15)+8-c[AC];
            spout:  p="\nThe %s breathes fire at you!";
                    if (c[FIRERESISTANCE])
                      p="\nThe %s's flame doesn't phase you!";
                    else
            spout2: if (p) { lprintf(p,lastmonst); beep(); }
                    checkloss(i);
                    return(0);

        case 3:     i = rnd(20)+25-c[AC];  goto spout;

        case 4: if (c[STRENGTH]>3)
                    {
                    p="\nThe %s stung you!  You feel weaker"; beep();
                    --c[STRENGTH];
                    }
                else p="\nThe %s stung you!";
                break;

        case 5:     p="\nThe %s blasts you with his cold breath";
                    i = rnd(15)+18-c[AC];  goto spout2;

        case 6:     lprintf("\nThe %s drains you of your life energy!",lastmonst);
                    loselevel();  beep();  return(0);

        case 7:     p="\nThe %s got you with a gusher!";
                    i = rnd(15)+25-c[AC];  goto spout2;

        case 8:     if (c[NOTHEFT]) return(0); /* he has a device of no theft */
                    if (c[GOLD])
                        {
                        p="\nThe %s hit you -- Your purse feels lighter";
                        if (c[GOLD]>32767)  c[GOLD]>>=1;
                            else c[GOLD] -= rnd((int)(1+(c[GOLD]>>1)));
                        if (c[GOLD] < 0) c[GOLD]=0;
                        }
                    else  p="\nThe %s couldn't find any gold to steal";
                    lprintf(p,lastmonst); disappear(xx,yy); beep();
                    bottomgold();  return(1);

        case 9: for(j=50; ; )   /* disenchant */
                    {
                    i=rund(26);  m=iven[i]; /* randomly select item */
                    if (m>0 && ivenarg[i]>0 && m!=OSCROLL && m!=OPOTION)
                        {
                        if ((ivenarg[i] -= 3)<0) ivenarg[i]=0;
                        lprintf("\nThe %s hits you -- you feel a sense of loss",lastmonst);
                        beep(); show3(i);  bottomline();  return(0);
                        }
                    if (--j<=0)
                        {
                        p="\nThe %s nearly misses"; break;
                        }
                    break;
                    }       
                break;

        case 10:   p="\nThe %s hit you with his barbed tail";
                   i = rnd(25)-c[AC];  goto spout2;

        case 11:    p="\nThe %s has confused you"; beep();
                    c[CONFUSE]+= 10+rnd(10);        break;

        case 12:    /*  performs any number of other special attacks    */
                    return(spattack(spsel[rund(10)],xx,yy));

        case 13:    p="\nThe %s flattens you with his psionics!";
                    i = rnd(15)+30-c[AC];  goto spout2;

        case 14:    if (c[NOTHEFT]) return(0); /* he has device of no theft */
                    if (emptyhanded()==1)
                      {
                      p="\nThe %s couldn't find anything to steal";
                      break;
                      }
                    lprintf("\nThe %s picks your pocket and takes:",lastmonst);
                    beep();
                    if (stealsomething()==0) lprcat("  nothing"); disappear(xx,yy);
                    bottomline();  return(1);

        case 15:    i= rnd(10)+ 5-c[AC];
            spout3: p="\nThe %s bit you!";
                    goto spout2;

        case 16:    i= rnd(15)+10-c[AC];  goto spout3;
        };
    if (p) { lprintf(p,lastmonst); bottomline(); }
    return(0);
    }

/*
 *  checkloss(x)    Routine to subtract hp from user and flag bottomline display
 *      int x;
 *
 *  Routine to subtract hitpoints from the user and flag the bottomline display
 *  Enter with the number of hit points to lose
 *  Note: if x > c[HP] this routine could kill the player!
 */
checkloss(x)
    int x;
    {
    if (x>0) { losehp(x);  bottomhp(); }
    }
