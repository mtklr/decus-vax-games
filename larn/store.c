/* store.c */
/*
This module contains data and routines to handle buildings at the home level.
Routines:

  dnd_2hed
  dnd_hed
  dndstore      The DND store main routine
  handsfull     To tell the player he can carry no more
  out_of_stock  To tell the player an item is out of stock
  no_gold       To tell the player he has no gold
  dnditem       Display DND store items
  sch_head      print the school header
  oschool       main school routine
  obank         Larn National Bank
  obank2        5th level branch of the bank
  banktitle     bank header
  ointerest     accrue interest to bank account
  obanksub      bank main subroutine
  otradhead     trading post header
  otradepost    trading post main function
  cnsitm
  olrs          larn revenue service function
*/

#include "header.h"
#include "larndefs.h"
#include "objects.h"
#include "player.h"

static int dndcount=0,dnditm=0;

/* number of items in the dnd inventory table   */
#define MAXITM 83

/*  this is the data for the stuff in the dnd store */
struct _itm itm[90] = {
/*cost    memory    iven name   iven arg   how
  gp     pointer      iven[]    ivenarg[]  many */

{ 2,        0,      OLEATHER,       0,      3   },
{ 10,       0,      OSTUDLEATHER,   0,      2   },
{ 40,       0,      ORING,          0,      2   },
{ 85,       0,      OCHAIN,         0,      2   },
{ 220,      0,      OSPLINT,        0,      1   },
{ 400,      0,      OPLATE,         0,      1   },
{ 900,      0,      OPLATEARMOR,    0,      1   },
{ 2600,     0,      OSSPLATE,       0,      1   },
{ 150,      0,      OSHIELD,        0,      1   },

/*cost    memory    iven name   iven arg   how
  gp     pointer      iven[]    ivenarg[]  many */

{ 2,        0,      ODAGGER,        0,      3   },
{ 20,       0,      OSPEAR,         0,      3   },
{ 80,       0,      OFLAIL,         0,      2   },
{ 150,      0,      OBATTLEAXE,     0,      2   },
{ 450,      0,      OLONGSWORD,     0,      2   },
{ 1000,     0,      O2SWORD,        0,      2   },
{ 5000,     0,      OSWORD,         0,      1   },
{ 16500,    0,      OLANCE,         0,      1   },
{ 6000,     0,   OSWORDofSLASHING,  0,      0   },
{ 10000,    0,      OHAMMER,        0,      0   },

/*cost    memory    iven name   iven arg   how
  gp     pointer      iven[]    ivenarg[]  many */

{ 150,      0,      OPROTRING,      1,      1   },
{ 85,       0,      OSTRRING,       1,      1   },
{ 120,      0,      ODEXRING,       1,      1   },
{ 120,      0,      OCLEVERRING,    1,      1   },
{ 180,      0,      OENERGYRING,    0,      1   },
{ 125,      0,      ODAMRING,       0,      1   },
{ 220,      0,      OREGENRING,     0,      1   },
{ 1000,     0,      ORINGOFEXTRA,   0,      1   },

{ 280,      0,      OBELT,          0,      1   },

{ 400,      0,      OAMULET,        0,      1   },

{ 6500,     0,      OORBOFDRAGON,   0,      0   },
{ 5500,     0,      OSPIRITSCARAB,  0,      0   },
{ 5000,     0,      OCUBEofUNDEAD,  0,      0   },
{ 6000,     0,      ONOTHEFT,       0,      0   },

{ 590,      0,      OCHEST,         6,      1   },
{ 200,      0,      OBOOK,          8,      1   },
{ 10,       0,      OCOOKIE,        0,      3   },

/*cost    memory    iven name   iven arg   how
  gp     pointer      iven[]    ivenarg[]  many */

{   20,     potionname, OPOTION,    0,      6   },
{   90,     potionname, OPOTION,    1,      5   },
{   520,    potionname, OPOTION,    2,      1   },
{   100,    potionname, OPOTION,    3,      2   },
{   50,     potionname, OPOTION,    4,      2   },
{   150,    potionname, OPOTION,    5,      2   },
{   70,     potionname, OPOTION,    6,      1   },
{   30,     potionname, OPOTION,    7,      7   },
{   200,    potionname, OPOTION,    8,      1   },
{   50,     potionname, OPOTION,    9,      1   },
{   80,     potionname, OPOTION,    10,     1   },

/*cost    memory    iven name   iven arg   how
  gp     pointer      iven[]    ivenarg[]  many */

{   30,     potionname, OPOTION,    11,     3   },
{   20,     potionname, OPOTION,    12,     5   },
{   40,     potionname, OPOTION,    13,     3   },
{   35,     potionname, OPOTION,    14,     2   },
{   520,    potionname, OPOTION,    15,     1   },
{   90,     potionname, OPOTION,    16,     2   },
{   200,    potionname, OPOTION,    17,     2   },
{   220,    potionname, OPOTION,    18,     4   },
{   80,     potionname, OPOTION,    19,     6   },
{   370,    potionname, OPOTION,    20,     3   },
{   50,     potionname, OPOTION,    22,     1   },
{   150,    potionname, OPOTION,    23,     3   },

/*cost    memory    iven name   iven arg   how
  gp     pointer      iven[]    ivenarg[]  many */

{ 100,  scrollname,     OSCROLL,    0,      2   },
{ 125,  scrollname,     OSCROLL,    1,      2   },
{ 60,   scrollname,     OSCROLL,    2,      4   },
{ 10,   scrollname,     OSCROLL,    3,      4   },
{ 100,  scrollname,     OSCROLL,    4,      3   },
{ 200,  scrollname,     OSCROLL,    5,      2   },
{ 110,  scrollname,     OSCROLL,    6,      1   },
{ 500,  scrollname,     OSCROLL,    7,      2   },
{ 200,  scrollname,     OSCROLL,    8,      2   },
{ 250,  scrollname,     OSCROLL,    9,      4   },
{ 20,   scrollname,     OSCROLL,    10,     5   },
{ 30,   scrollname,     OSCROLL,    11,     3   },

/*cost    memory    iven name   iven arg   how
  gp     pointer      iven[]    ivenarg[]  many */

{ 340,  scrollname,     OSCROLL,    12,     1   },
{ 340,  scrollname,     OSCROLL,    13,     1   },
{ 300,  scrollname,     OSCROLL,    14,     2   },
{ 400,  scrollname,     OSCROLL,    15,     2   },
{ 500,  scrollname,     OSCROLL,    16,     2   },
{ 1000, scrollname,     OSCROLL,    17,     1   },
{ 500,  scrollname,     OSCROLL,    18,     1   },
{ 340,  scrollname,     OSCROLL,    19,     2   },
{ 220,  scrollname,     OSCROLL,    20,     3   },
{ 3900, scrollname,     OSCROLL,    21,     0   },
{ 610,  scrollname,     OSCROLL,    22,     1   },
{ 3000, scrollname,     OSCROLL,    23,     0   }
 };

/*
    for the college of larn
 */
char course[26];    /*  the list of courses taken   */
static char coursetime[] = { 10, 15, 10, 20, 10, 10, 10, 5 };

/*
    function for the dnd store
 */
static dnd_2hed()
    {
    lprcat("Welcome to the Larn Thrift Shoppe.  We stock many items explorers find useful\n");
    lprcat(" in their adventures.  Feel free to browse to your hearts content.\n");
    lprcat("Also be advised, if you break 'em, you pay for 'em.");
    }

static dnd_hed()
    {
    register int i;
    for (i=dnditm; i<26+dnditm; i++)    dnditem(i);
    cursor(50,18); lprcat("You have ");
    }

dndstore()
  {
  register int i;
  dnditm = 0;
  nosignal = 1; /* disable signals */
  clear();  dnd_2hed();
  if (outstanding_taxes>0)
    {
    lprcat("\n\nThe Larn Revenue Service has ordered us to not do business with tax evaders.\n"); beep();
    lprintf("They have also told us that you owe %d gp in back taxes, and as we must\n",(long)outstanding_taxes);
    lprcat("comply with the law, we cannot serve you at this time.  Soo Sorry.\n");
    cursors();
    lprcat("\nPress "); standout("escape"); lprcat(" to leave: "); lflush();
    i=0;
    while (i!='\33') i=ttgetch();
    drawscreen();  nosignal = 0; /* enable signals */ return;
    }

  dnd_hed();
  while (1)
    {
    cursor(59,18); lprintf("%d gold pieces",(long)c[GOLD]);
    cltoeoln(); cl_dn(1,20);    /* erase to eod */
    lprcat("\nEnter your transaction ["); standout("space");
    lprcat(" for more, "); standout("escape");
    lprcat(" to leave]? ");
    i=0;
    while ((i<'a' || i>'z') && (i!=' ') && (i!='\33') && (i!=12))  i=ttgetch();
    if (i==12) { clear();  dnd_2hed();  dnd_hed(); }
    else if (i=='\33')
        { drawscreen();  nosignal = 0; /* enable signals */ return; }
    else if (i==' ')
        {
        cl_dn(1,4);
    if ((dnditm += 26) >= MAXITM)
            dnditm=0;
        dnd_hed();
        }
    else
        {  /* buy something */
        lprc(i);    /* echo the byte */
        i += dnditm - 'a';
    if (i>=MAXITM) outofstock(); else
        if (itm[i].qty <= 0) outofstock(); else
        if (pocketfull()) handsfull(); else
        if (c[GOLD] < (long) itm[i].price * 10) nogold(); else
            {
            if (itm[i].mem != 0) *itm[i].mem[itm[i].arg] = ' ';
            c[GOLD] -= (long) itm[i].price * 10;
            itm[i].qty--;  take(itm[i].obj,itm[i].arg);
            if (itm[i].qty==0) dnditem(i);  nap(1001);
            }
        }

    }
  }

/*
    function for the players hands are full
 */
static handsfull()
    { lprcat("\nYou can't carry anything more!"); lflush(); nap(2200); }
static outofstock()
    { lprcat("\nSorry, but we are out of that item."); lflush(); nap(2200); }
static nogold()
    { lprcat("\nYou don't have enough gold to pay for that!"); lflush(); nap(2200); }

/*
    dnditem(index)

    to print the item list;  used in dndstore() enter with the index into itm
 */
static dnditem(i)
    register int i;
    {
    register int j,k;
    if (i >= MAXITM)  return;
    cursor( (j=(i&1)*40+1) , (k=((i%26)>>1)+5) );
    if (itm[i].qty == 0)  { lprintf("%39s","");  return; }
    lprintf("%c) ",(i%26)+'a');
    if (itm[i].obj == OPOTION)
        { lprcat("potion of "); lprintf("%s",&potionname[itm[i].arg][1]); }
    else if (itm[i].obj == OSCROLL)
        { lprcat("scroll of "); lprintf("%s",&scrollname[itm[i].arg][1]); }
    else lprintf("%s",objectname[itm[i].obj]);
    cursor( j+31,k );  lprintf("%6d", (long) itm[i].price * 10);
    }


/*
    function to display the header info for the school
 */
static sch_hed()
    {
    clear();
    lprcat("The College of Larn offers the exciting opportunity of higher education to\n");
    lprcat("all inhabitants of the caves.  Here is a list of the class schedule:\n\n\n");
    lprcat("\t\t    Course Name \t       Time Needed\n\n");

    if (course[0]==0) lprcat("\t\ta)  Fighters Training I         10 mobuls"); /*line 7 of crt*/
    lprc('\n');
    if (course[1]==0) lprcat("\t\tb)  Fighters Training II        15 mobuls");
    lprc('\n');
    if (course[2]==0) lprcat("\t\tc)  Introduction to Wizardry    10 mobuls");
    lprc('\n');
    if (course[3]==0) lprcat("\t\td)  Applied Wizardry            20 mobuls");
    lprc('\n');
    if (course[4]==0) lprcat("\t\te)  Behavioral Psychology       10 mobuls");
    lprc('\n');
    if (course[5]==0) lprcat("\t\tf)  Faith for Today             10 mobuls");
    lprc('\n');
    if (course[6]==0) lprcat("\t\tg)  Contemporary Dance          10 mobuls");
    lprc('\n');
    if (course[7]==0) lprcat("\t\th)  History of Larn              5 mobuls");

    lprcat("\n\n\t\tAll courses cost 250 gold pieces.");
    cursor(30,18);
    lprcat("You are presently carrying ");
    }

oschool()
    {
    register int i;
    long time_used;
    nosignal = 1; /* disable signals */
    sch_hed();
    while (1)
        {
        cursor(57,18); lprintf("%d gold pieces.   ",(long)c[GOLD]); cursors();
        lprcat("\nWhat is your choice ["); standout("escape");
        lprcat(" to leave] ? ");  yrepcount=0;
        i=0;  while ((i<'a' || i>'h') && (i!='\33') && (i!=12)) i=ttgetch();
        if (i==12) { sch_hed();  continue; }
        else if (i=='\33')
            { nosignal = 0; drawscreen();  /* enable signals */ return; }
        lprc(i);
        if (c[GOLD] < 250)  nogold();  else
        if (course[i-'a'])
            { lprcat("\nSorry, but that class is filled."); nap(1000); }
        else
        if (i <= 'h')
            {
            c[GOLD] -= 250; time_used=0;
            switch(i)
                {
                case 'a':   c[STRENGTH] += 2;  c[CONSTITUTION]++;
                            lprcat("\nYou feel stronger!");
                            cl_line(16,7);
                            break;

                case 'b':   if (course[0]==0)
                                {
                                lprcat("\nSorry, but this class has a prerequisite of Fighters Training I");
                                c[GOLD]+=250;  time_used= -10000;  break;
                                }
                            lprcat("\nYou feel much stronger!");
                            cl_line(16,8);
                            c[STRENGTH] += 2;  c[CONSTITUTION] += 2;  break;

                case 'c':   c[INTELLIGENCE] += 2; 
                            lprcat("\nThe task before you now seems more attainable!");
                            cl_line(16,9);  break;

                case 'd':   if (course[2]==0)
                                {
                                lprcat("\nSorry, but this class has a prerequisite of Introduction to Wizardry");
                                c[GOLD]+=250;  time_used= -10000;  break;
                                }
                            lprcat("\nThe task before you now seems very attainable!");
                            cl_line(16,10);
                            c[INTELLIGENCE] += 2;  break;

                case 'e':   c[CHARISMA] += 3;  
                            lprcat("\nYou now feel like a born leader!");
                            cl_line(16,11);  break;

                case 'f':   c[WISDOM] += 2;  
                            lprcat("\nYou now feel more confident that you can find the potion in time!");
                            cl_line(16,12);  break;

                case 'g':   c[DEXTERITY] += 3;  
                            lprcat("\nYou feel like dancing!");
                            cl_line(16,13);  break;

                case 'h':   c[INTELLIGENCE]++;
                            lprcat("\nYour instructor told you that the Eye of Larn is rumored to be guarded\n");
                            lprcat("by a platinum dragon who possesses psionic abilities. ");
                            cl_line(16,14);  break;
                }
            time_used += coursetime[i-'a']*100;
            if (time_used > 0)
              {
              gtime += time_used;
              course[i-'a']++;  /*  remember that he has taken that course  */
              c[HP] = c[HPMAX];  c[SPELLS] = c[SPELLMAX]; /* he regenerated */

              if (c[BLINDCOUNT])    c[BLINDCOUNT]=1;  /* cure blindness too!  */
              if (c[CONFUSE])       c[CONFUSE]=1;   /*  end confusion   */
              adjtime((long)time_used); /* adjust parameters for time change */
              }
            nap(1000);
            }
        }
    }

/*
 *  for the first national bank of Larn
 */
int lasttime=0; /* last time he was in bank */
obank()
    {
    banktitle("    Welcome to the First National Bank of Larn.");
    }
obank2()
    {
    banktitle("Welcome to the 5th level branch office of the First National Bank of Larn.");
    /* because we state the level in the title, clear the '?' in the
       level display at the bottom, if the user teleported.
    */
    c[TELEFLAG] = 0;
    }
static banktitle(str)
    char *str;
    {
    nosignal = 1; /* disable signals */
    clear();  lprcat(str);
    if (outstanding_taxes>0)
        {
        register int i;
        lprcat("\n\nThe Larn Revenue Service has ordered that your account be frozen until all\n"); beep();
        lprintf("levied taxes have been paid.  They have also told us that you owe %d gp in\n",(long)outstanding_taxes);
        lprcat("taxes, and we must comply with them. We cannot serve you at this time.  Sorry.\n");
        lprcat("We suggest you go to the LRS office and pay your taxes.\n");
        cursors();
        lprcat("\nPress "); standout("escape"); lprcat(" to leave: "); lflush();
        i=0;
        while (i!='\33') i=ttgetch();
        drawscreen();  nosignal = 0; /* enable signals */ return;
        }
    lprcat("\n\n\tGemstone\t      Appraisal\t\tGemstone\t      Appraisal");
    obanksub();     nosignal = 0; /* enable signals */
    drawscreen();
    }

/*
 *  function to put interest on your bank account
 */
ointerest()
    {
    register int i;
    if (c[BANKACCOUNT]<0) c[BANKACCOUNT] = 0;
    else if ((c[BANKACCOUNT]>0) && (c[BANKACCOUNT]<500000))
        {
        i = (gtime-lasttime)/100; /* # mobuls elapsed */
        while ((i-- > 0) && (c[BANKACCOUNT]<500000))
            c[BANKACCOUNT] += c[BANKACCOUNT]/250;
        if (c[BANKACCOUNT]>500000) c[BANKACCOUNT]=500000; /* interest limit */
        }
    lasttime = (gtime/100)*100;
    }

static obanksub()
    {
    short gemorder[26];  /* the reference to screen location for each gem */
    long gemvalue[26];   /* the appraisal of the gems */
    unsigned long amt;
    register int i,k,gems_sold=0;

    ointerest();    /* credit any needed interest */

    for (k=i=0; i<26; i++)
        switch(iven[i])
            {
            case OLARNEYE: case ODIAMOND: case OEMERALD:
            case ORUBY: case OSAPPHIRE:

                    if (iven[i]==OLARNEYE)
                        {
                        gemvalue[i]=250000-((gtime*7)/100)*100;
                        if (gemvalue[i]<50000) gemvalue[i]=50000;
                        }
                    else gemvalue[i] = (255&ivenarg[i])*100;
                    gemorder[i]=k;
                    cursor( (k%2)*40+1 , (k>>1)+4 );
                    lprintf("%c) %s",i+'a',objectname[iven[i]]);
                    cursor( (k%2)*40+33 , (k>>1)+4 );
                    lprintf("%5d",(long)gemvalue[i]);  k++;
                    break;

            default:        /* make sure player can't sell non-existant gems */
                gemvalue[i] = 0 ;
                gemorder[i] = 0 ;
            };
    cursor(31,17); lprintf("You have %8d gold pieces in the bank.",(long)c[BANKACCOUNT]);
    cursor(40,18); lprintf("You have %8d gold pieces",(long)c[GOLD]);
    if (c[BANKACCOUNT]+c[GOLD] >= 500000)
        lprcat("\nNote:  Larndom law states that only deposits under 500,000gp  can earn interest.");
    while (1)
        {
        cl_dn(1,20);
        lprcat("\nYour wish? [("); standout("d"); lprcat(") deposit, (");
        standout("w"); lprcat(") withdraw, ("); standout("s");
        lprcat(") sell a stone, or "); standout("escape"); lprcat("]  ");
        yrepcount=0;
        i=0; while (i!='d' && i!='w' && i!='s' && i!='\33') i=ttgetch();
        switch(i)
            {
# ifdef MSDOS
            case 'd':
              lprcat("deposit\n");
              cltoeoln();
              lprcat("How much? "); amt = readnum((long)c[GOLD]);
# else
            case 'd':   lprcat("deposit\nHow much? ");  amt = readnum((long)c[GOLD]);
# endif
                        if (amt<0) { lprcat("\nSorry, but we can't take negative gold!"); nap(2000); amt=0; } else
                        if (amt>c[GOLD])
                          { lprcat("  You don't have that much.");  nap(2000); }
                        else { c[GOLD] -= amt;  c[BANKACCOUNT] += amt; }
                        break;

            case 'w':   lprcat("withdraw\nHow much? "); amt = readnum((long)c[BANKACCOUNT]);
                        if (amt<0) { lprcat("\nSorry, but we don't have any negative gold!");  nap(2000); amt=0; }
                        else if (amt > c[BANKACCOUNT])
                          { lprcat("\nYou don't have that much in the bank!"); nap(2000); }
                        else { c[GOLD] += amt;  c[BANKACCOUNT] -= amt; }
                        break;

            case 's':   lprcat("\nWhich stone would you like to sell? ");
            i=0; while ((i<'a' || i>'z') && i!='*' && i!='\33')
                i=ttgetch();
                        if (i=='*')
              {
              for (i=0; i<26; i++)
                            {
                            if (gemvalue[i])
                                {
                gems_sold = TRUE ;
                c[GOLD]+=gemvalue[i];  iven[i]=0;
                                gemvalue[i]=0;  k = gemorder[i];
                                cursor( (k%2)*40+1 , (k>>1)+4 );
                                lprintf("%39s","");
                                }
                            }
              if (!gems_sold)
                  {
                  lprcat("\nYou have no gems to sell!");
                  nap(2000);
                  }
              }
            else if ( i != '\33' )
                            {
                            if (gemvalue[i=i-'a']==0)
                                {
                                lprintf("\nItem %c is not a gemstone!",i+'a');
                                nap(2000); break;
                                }
                            c[GOLD]+=gemvalue[i];  iven[i]=0;
                            gemvalue[i]=0;  k = gemorder[i];
                            cursor( (k%2)*40+1 , (k>>1)+4 ); lprintf("%39s","");
                            }
                        break;

            case '\33': return;
            };
        cursor(40,17); lprintf("%8d",(long)c[BANKACCOUNT]);
        cursor(49,18); lprintf("%8d",(long)c[GOLD]);
        }
    }

/*
    function for the trading post
 */
static otradhead()
    {
    clear();
    lprcat("Welcome to the Larn Trading Post.  We buy items that explorers no longer find\n");
    lprcat("useful.  Since the condition of the items you bring in is not certain,\n");
    lprcat("and we incur great expense in reconditioning the items, we usually pay\n");
    lprcat("only 20% of their value were they to be new.  If the items are badly\n");
    lprcat("damaged, we will pay only 10% of their new value.\n\n");

    lprcat("Here are the items we would be willing to buy from you:\n");
    }

static short tradorder[26];   /* screen locations for trading post inventory */
static otradiven()
    {
    int i,j ;

  /* Print user's iventory like bank */
  for (j=i=0 ; i<26 ; i++)
      if (iven[i])
          {
      cursor( (j%2)*40+1, (j>>1)+8 );
      tradorder[i] = 0 ;    /* init position on screen to zero */
      switch (iven[i])
              {
              case OPOTION:
          if ( potionname[ivenarg[i]][0] != 0 )
              {
              tradorder[i] = j++ ;   /* will display only if identified */
              lprintf( "%c) %s", i+'a', objectname[iven[i]] );
              lprintf(" of%s", potionname[ivenarg[i]] );
              }
                  break;
              case OSCROLL:
          if ( scrollname[ivenarg[i]][0] != 0 )
              {
              tradorder[i] = j++ ;   /* will display only if identified */
              lprintf( "%c) %s", i+'a', objectname[iven[i]] );
              lprintf(" of%s", scrollname[ivenarg[i]] );
              }
          break;
          case OLARNEYE:
          case OBOOK:
          case OSPIRITSCARAB:
          case ODIAMOND:
          case ORUBY:
          case OEMERALD:
          case OCHEST:
          case OSAPPHIRE:
          case OCUBEofUNDEAD:
          case OCOOKIE:
          case ONOTHEFT:
          tradorder[i] = j++ ;  /* put on screen */
          lprintf( "%c) %s", i+'a', objectname[iven[i]] );
          break;
          default:
          tradorder[i] = j++ ;  /* put on screen */
          lprintf( "%c) %s", i+'a', objectname[iven[i]] );
          if (ivenarg[i] > 0)
              lprintf(" +%d", (long)ivenarg[i] );
          else if (ivenarg[i] < 0)
              lprintf(" %d",  (long)ivenarg[i] );
          break;
          }
      }
      else
       tradorder[i] = 0;  /* make sure order array is clear */
    }

static cleartradiven( i )
int i ;
    {
    int j;
    j = tradorder[i] ;
    cursor( (j%2)*40+1, (j>>1)+8 );
    lprintf( "%39s", "" );
    tradorder[i] = 0;
    }

otradepost()
    {
    register int i,j,isub,izarg,found;
    register long value;

    dnditm = dndcount = 0;
    nosignal = 1; /* disable signals */
    otradhead();
    otradiven();

    while (1)
       {
       cl_dn(1,21);
       lprcat("\nWhat item do you want to sell to us [");
       standout("escape"); lprcat("] ? ");
       i=0;
       while ( i>'z' || i<'a' && i!=12 && i!='\33' )
           i=ttgetch();
       if (i == '\33')
           {
           recalc();
           drawscreen();
           nosignal=0; /* enable signals */
           return;
           }
       while (1)   /* inner loop for simpler control */
           {
           if (i == 12)
               {
               clear();
               otradhead();
               otradiven();
               break;      /* leave inner while */
               }

           isub = i - 'a' ;
           if (iven[isub] == 0)
               {
               lprintf("\nYou don't have item %c!",isub+'a');
               nap(2000);
               break;      /* leave inner while */
               }
           if (iven[isub]==OSCROLL)
               if (scrollname[ivenarg[isub]][0]==0)
                   {
                   cnsitm();
                   break;      /* leave inner while */
                   }
           if (iven[isub]==OPOTION)
               if (potionname[ivenarg[isub]][0]==0)
                   {
                   cnsitm();
                   break;      /* leave inner while */
                   }
           if (iven[isub]==ODIAMOND ||
               iven[isub]==ORUBY    ||
               iven[isub]==OEMERALD ||
           iven[isub]==OSAPPHIRE )
           value = 20L * (ivenarg[isub] & 255);
       else if (iven[isub]==OLARNEYE)
           {
           value = 50000 - (((gtime*7) / 100) * 20 );
           if (value < 10000)
           value = 10000;
           }
       else
               {
               /* find object in itm[] list for price info */
               found = MAXITM ;
               for (j=0; j<MAXITM; j++)
                   if (itm[j].obj == iven[isub])
                       {
                       found = j ;
                       break;      /* leave for loop */
                       }
               if (found == MAXITM)
                   {
                   lprcat("\nSo sorry, but we are not authorized to accept that item.");
                   nap(2000);
                   break;      /* leave inner while */
                   }
               if (iven[isub] == OSCROLL ||
                   iven[isub] == OPOTION)
                   value = 2 * (long)itm[ j + ivenarg[isub]].price ;
               else
                   {
                   izarg=ivenarg[isub];
                   value = itm[j].price;
                   /* appreciate if a +n object */
                   if (izarg >= 0) value *= 2;
                   while ((izarg-- > 0) && ((value=14*(67+value)/10) < 500000));
                   }
               }
           /* we have now found the value of the item, and dealt with any error
              cases.  Print the object's value, let the user sell it.
           */
           lprintf("\nItem (%c) is worth %d gold pieces to us.  Do you want to sell it? ",i,(long)value);
           yrepcount=0;
           if (getyn()=='y')
               {
               lprcat("yes\n"); c[GOLD]+=value;
               if (c[WEAR] == isub) c[WEAR] = -1;
               if (c[WIELD] == isub) c[WIELD] = -1;
               if (c[SHIELD] == isub) c[SHIELD] = -1;
               adjustcvalues(iven[isub],ivenarg[isub]);
               iven[isub]=0;
               cleartradiven( isub );
               }
           else
           {
           lprcat("no thanks.\n");
           nap(500);
           }
       break;          /* exit inner while */
           }   /* end of inner while */
        }       /* end of outer while */
    }       /* end of routine */

static cnsitm()
    {
    lprcat("\nSorry, we can't accept unidentified objects.");
    nap(2000);
    }

/*
 *  for the Larn Revenue Service
 */
olrs()
    {
    register int i,first;
    unsigned long amt;
    first = nosignal = 1; /* disable signals */
    clear();  resetscroll(); cursor(1,4);
    lprcat("Welcome to the Larn Revenue Service district office.  How can we help you?");
    while (1)
        {
        if (first) { first=0; goto nxt; }
        setscroll();
        cursors();
        lprcat("\n\nYour wish? [(");
        standout("p");
        lprcat(") pay taxes, or ");
        standout("escape");
        lprcat("]  ");  yrepcount=0;
        i=0; while (i!='p' && i!='\33') i=ttgetch();
        switch(i)
            {
            case 'p':   lprcat("pay taxes\nHow much? "); amt = readnum((long)c[GOLD]);
                        if (amt<0) { lprcat("\nSorry, but we can't take negative gold\n"); amt=0; } else
                        if (amt>c[GOLD])    lprcat("  You don't have that much.\n");
                        else  c[GOLD] -= paytaxes((long)amt);
                        break;

            case '\33': nosignal = 0; /* enable signals */
                        setscroll(); drawscreen();  return;
            };

nxt:    cursor(1,6);
        if (outstanding_taxes>0)
            lprintf("You presently owe %d gp in taxes.  ",(long)outstanding_taxes);
        else
            lprcat("You do not owe us any taxes.           ");
        cursor(1,8);
        if (c[GOLD]>0)
            lprintf("You have %6d gp.    ",(long)c[GOLD]);
        else
            lprcat("You have no gold pieces.  ");
        }
    }
