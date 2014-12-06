/* bill.c */
#include "header.h"
#include "larndefs.h"

# ifdef MAIL
# include "player.h"
# ifdef VMS
# define MAILTMP    "sys$scratch:"
# else
# define MAILTMP    "/tmp/#"
# endif
static int pid;
static char mail600[sizeof(MAILTMP)+sizeof("mail600")+20];
# endif
/*
 *  function to create the tax bill for the user
 */
# ifdef MAIL
static letter1()
# else
static letter1(gold)
long gold;
# endif
  {
# ifdef MAIL
  sprintf(mail600,"%s%dmail600",MAILTMP,pid); /* prepare path */
  if (lcreat(mail600) < 0) { write(1,"can't write 600 letter\n",23); return(0);}
#ifndef RFCMAIL
  lprcat("\n\n\n\n\n\n\n\n\n\n\n\n");
#endif /*RFCMAIL*/
# endif
#ifdef RFCMAIL
  lprcat("From: LRS (Larn Revenue Service)\n");
  lprcat("Subject: Undeclared Income\n\n");
#else /*RFCMAIL*/
  standout("From:"); lprcat("  the LRS (Larn Revenue Service)\n");
  standout("\nSubject:"); lprcat("  undeclared income\n");
#endif /*RFCMAIL*/
  lprcat("\n   We heard you survived the caverns of Larn.  Let me be the");
  lprcat("\nfirst to congratulate you on your success.  It is quite a feat.");
  lprcat("\nIt must also have been very profitable for you.");
  lprcat("\n\n   The Dungeon Master has informed us that you brought");
# ifdef MAIL
  lprintf("\n%d gold pieces back with you from your journey.  As the",(long)c[GOLD]);
# else
  lprintf("\n%d gold pieces back with you from your journey.  As the", gold);
# endif
  lprcat("\ncounty of Larn is in dire need of funds, we have spared no time");
  lprintf("\nin preparing your tax bill.  You owe %d gold pieces as",
# ifdef MAIL
    (long)c[GOLD]*TAXRATE);
# else
    gold * TAXRATE);
# endif
  lprcat("\nof this notice, and is due within 5 days.  Failure to pay will");
  lprcat("\nmean penalties.  Once again, congratulations, We look forward");
  lprcat("\nto your future successful expeditions.\n");
# ifdef MAIL
  lwclose();
# endif
  return(1);
  }

static letter2()
  {
# ifdef MAIL
  sprintf(mail600,"%s%dmail600",MAILTMP,pid); /* prepare path */
  if (lcreat(mail600) < 0) { write(1,"can't write 601 letter\n",23); return(0);}
#ifndef RFCMAIL
  lprcat("\n\n\n\n\n\n\n\n\n\n\n\n");
#endif /*RFCMAIL*/
# endif
#ifdef RFCMAIL
  lprcat("From: King (His Majesty King Wilfred of Larndom)\n");
  lprcat("Subject: A Noble Deed\n\n");
#else /*RFCMAIL*/
  standout("From:"); lprcat("  His Majesty King Wilfred of Larndom\n");
  standout("\nSubject:"); lprcat("  a noble deed\n");
#endif /*RFCMAIL*/
  lprcat("\n   I have heard of your magnificent feat, and I, King Wilfred,");
  lprcat("\nforthwith declare today to be a national holiday.  Furthermore,");
  lprcat("\nhence three days, Ye be invited to the castle to receive the");
  lprcat("\nhonour of Knight of the realm.  Upon thy name shall it be written. . .");
  lprcat("\nBravery and courage be yours.");
  lprcat("\nMay you live in happiness forevermore . . .\n");
# ifdef MAIL
  lwclose();
# endif
  return(1);
  }

static letter3()
  {
# ifdef MAIL
  sprintf(mail600,"%s%dmail600",MAILTMP,pid); /* prepare path */
  if (lcreat(mail600) < 0) { write(1,"can't write 602 letter\n",23); return(0);}
#ifndef RFCMAIL
  lprcat("\n\n\n\n\n\n\n\n\n\n\n\n");
#endif /*RFCMAIL*/
# endif
#ifdef RFCMAIL
  lprcat("From: Endelford (Count Endelford)\n");
  lprcat("Subject: You Bastard!\n\n");
#else /*RFCMAIL*/
  standout("From:"); lprcat("  Count Endelford\n");
  standout("\nSubject:"); lprcat("  You Bastard!\n");
#endif /*RFCMAIL*/
  lprcat("\n   I heard (from sources) of your journey.  Congratulations!");
  lprcat("\nYou Bastard!  With several attempts I have yet to endure the");
  lprcat(" caves,\nand you, a nobody, makes the journey!  From this time");
  lprcat(" onward, bewarned\nupon our meeting you shall pay the price!\n");
# ifdef MAIL
  lwclose();
# endif
  return(1);
  }

static letter4()
  {
# ifdef MAIL
  sprintf(mail600,"%s%dmail600", MAILTMP,pid); /* prepare path */
  if (lcreat(mail600) < 0) { write(1,"can't write 603 letter\n",23); return(0);}
#ifndef RFCMAIL
  lprcat("\n\n\n\n\n\n\n\n\n\n\n\n");
#endif /*RFCMAIL*/
# endif
#ifdef RFCMAIL
  lprcat("From: Mainair (Mainair, Duke of Larnty)\n");
  lprcat("Subject: High Praise\n\n");
#else /*RFCMAIL*/
  standout("From:"); lprcat("  Mainair, Duke of Larnty\n");
  standout("\nSubject:"); lprcat("  High Praise\n");
#endif /*RFCMAIL*/
  lprcat("\n   With a certainty a hero I declare to be amongst us!  A nod of");
  lprcat("\nfavour I send to thee.  Me thinks Count Endelford this day of");
  lprcat("\nright breath'eth fire as of dragon of whom ye are slayer.  I");
  lprcat("\nyearn to behold his anger and jealously.  Should ye choose to");
  lprcat("\nunleash some of thy wealth upon those who be unfortunate, I,");
  lprcat("\nDuke Mainair, Shall equal thy gift also.\n");
# ifdef MAIL
  lwclose();
# endif
  return(1);
  }

static letter5()
  {
# ifdef MAIL
  sprintf(mail600,"%s%dmail600", MAILTMP,pid); /* prepare path */
  if (lcreat(mail600) < 0) { write(1,"can't write 604 letter\n",23); return(0);}
#ifndef RFCMAIL
  lprcat("\n\n\n\n\n\n\n\n\n\n\n\n");
#endif /*RFCMAIL*/
# endif
#ifdef RFCMAIL
  lprcat("From: StMary (St. Mary's Children's Home)\n");
  lprcat("Subject: These Poor Children\n\n");
#else /*RFCMAIL*/
  standout("From:"); lprcat("  St. Mary's Children's Home\n");
  standout("\nSubject:"); lprcat("  these poor children\n");
#endif /*RFCMAIL*/
  lprcat("\n   News of your great conquests has spread to all of Larndom.");
  lprcat("\nMight I have a moment of a great man's time.  We here at St.");
  lprcat("\nMary's Children's Home are very poor, and many children are");
  lprcat("\nstarving.  Disease is widespread and very often fatal without");
  lprcat("\ngood food.  Could you possibly find it in your heart to help us");
  lprcat("\nin our plight?  Whatever you could give will help much.");
  lprcat("\n(your gift is tax deductible)\n");
# ifdef MAIL
  lwclose();
# endif
  return(1);
  }

static letter6()
  {
# ifdef MAIL
  sprintf(mail600, "%s%dmail600", MAILTMP, pid); /* prepare path */
  if (lcreat(mail600) < 0) { write(1,"can't write 605 letter\n",23); return(0);}
#ifndef RFCMAIL
  lprcat("\n\n\n\n\n\n\n\n\n\n\n\n");
#endif
# endif
#ifdef RFCMAIL
  lprcat("From: CancerSociety (The National Cancer Society of Larn)\n");
  lprcat("Subject: Hope\n\n");
#else /*RFCMAIL*/
  standout("From:"); lprcat("  The National Cancer Society of Larn\n");
  standout("\nSubject:"); lprcat("  hope\n");
#endif /*RFCMAIL*/
  lprcat("\nCongratulations on your successful expedition.  We are sure much");
  lprcat("\ncourage and determination were needed on your quest.  There are");
  lprcat("\nmany though, that could never hope to undertake such a journey");
  lprcat("\ndue to an enfeebling disease -- cancer.  We at the National");
  lprcat("\nCancer Society of Larn wish to appeal to your philanthropy in");
  lprcat("\norder to save many good people -- possibly even yourself a few");
  lprcat("\nyears from now.  Much work needs to be done in researching this");
  lprcat("\ndreaded disease, and you can help today.  Could you please see it");
  lprcat("\nin your heart to give generously?  Your continued good health");
  lprcat("\ncan be your everlasting reward.\n");
# ifdef MAIL
  lwclose();
# endif
  return(1);
  }


static int (*pfn[])()= { letter1, letter2, letter3, letter4, letter5, letter6 };

# ifdef MAIL
/*
 *  function to mail the letters to the player if a winner
 */
mailbill()
    {
#ifdef VMS
    register int i;
    char buf[128];
    pid = getpid();
    for (i=0; i<sizeof(pfn)/sizeof(int (*)()); i++)
        if ((*pfn[i])()) {
            sprintf(buf, "mail %s %s\n", loginname, mail600);
            oneliner(buf);
            delete(mail600);
        }
    }
#else
    register int i;
    char buf[128];
    wait(0);  pid=getpid();
    if (fork() == 0)
        {
        resetscroll();
        for (i=0; i<sizeof(pfn)/sizeof(int (*)()); i++)
            if ((*pfn[i])())
                {
                sleep(20);
                sprintf(buf,"mail %s < %s",loginname,mail600);
                system(buf);  unlink(mail600);
                }
        exit();
        }
    }
#endif
# else

/* Page the mail to the terminal    - dgk
 */
readmail(gold)
long    gold;
{
    register int i;

    for (i = 0; i < (sizeof pfn) / (sizeof pfn[0]); i++) {
        resetscroll();
        clear();
        (*pfn[i])(gold);    /* a bit dirty 'cause of args */
        retcont();
    }
}
# endif
