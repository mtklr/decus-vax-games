
/* This program is exclusively inteded to work with the purity test version */
/* 4.  I assume no liability or credit for making this mindless program and */
/* I seek no credit nor claim any responsibility for creating it.           */

#include stdio
#include stdlib             /* atoi (character)             */
#include smgdef             /* to make a real getchar()     */
#include libdef             /* to get username for score    */
#include descrip
#include jpidef
#define maxquest 500        /* number of qeustions total    */
#define True 1
#define False 0
#define datafile "$1$dua12:[temp.masmummy]purity.test"
#define keep     "$1$dua12:[temp.masmummy]purity.score"
#define disclaim "$1$dua12:[temp.masmummy]purity.disclaimer"
#define savefile "sys$scratch:purity.results"

unsigned int keyboard;      /* so I can make getchar () work */
int current;                /* current question being asked  */
int yes;                    /* number of affimative answers  */
int save;                   /* boolean to control saving     */
int quit;                   /* for quitting DUH!             */
int show;                   /* analogous to echo on/off      */
char line[81];              /* string array to read from file*/
FILE *fp;                   /* low and behold, file pointer  */

int xprint ()
{
  int a;
  int b;
  a = False;

  printf ("\033<\033[1;1f\033[J\033[0m\n");
  printf ("\033[9;30HDo you want to make");
  printf ("\033[10;30Ha printout of this?");

  while (b != SMG$K_TRM_CTRLM )
  {
  if (b == SMG$K_TRM_UP ) ++a;
  if (b == SMG$K_TRM_DOWN) --a;
  if (a < 0) a = 1;
  if (a > 1) a = 0;
  if (a == 1)
   {
    printf ("\033[12;30HME? Not on my life!");
    printf ("\033[7m\033[13;30HHOT DAMN!! Sure do!\033[0m");
   }
  if (a == 0)
   {
    printf ("\033[13;30HHOT DAMN!! Sure do!");
    printf ("\033[7m\033[12;30HME? Not on my life!\033[0m");
   }
  smg$read_keystroke (&keyboard,&b);
  }
  return a;
}

char custgetchar()

{
  char a;

  smg$read_keystroke (&keyboard,&a);
  if (a == 'n' || a =='N' )
  {
    if (show) printf ("no");
    printf ("\n");
    return 'n';
  }
  else if (a == 'y' || a == 'Y')
  {
    if (show) printf ("yes");
    printf ("\n");
    return 'y';
  }
  else if (a == 'q' || a == 'Q')
  {
    printf ("quit\n");
    return 'q';
  }
  else if (a == 's' || a == 'S')
  {
    printf ("save\n");
    return 's';
  }
  if (show) printf ("Default is NO");
  printf ("\n");
  return 'n';
}


int subint (char a[81])    /* less messy than using strncpy */

{
  int b;
  char c[5];
  int d;

  d = 0;
  for (b=1 ; b<5 ; ++b)
  {
    c[b] = a[b];
    if (!(c[b] <= '9' && c[b] >= '0')) c[b] = '0';
    d = 10.0 * d+(c[b] - '0');
  }
  if (a[5] != '.') d = 0;
  return d;
}

void get_ans (int *quit, int *yes, int *save)  /* call with get_ans (&quit) */
{
  char b;

  printf("Your answer? (y/[N]/q/s) ");
  b = custgetchar();

  if (b == 'q') *quit = True;
  else if (b == 's') *save = True;
  if (b == 'y') *yes= *yes + 1;
  printf ("\n\n");
}

int divider (char a[81])

{
  if (strstr(a," ______________________________")!= NULL)  return True;
  return False;
}

char *printdiv (int c)

{
  char b[81];
  int d;

  d = 3;
  fgets (b,132,fp);
  fgets (b,132,fp);
  printf ("\033<\033[1;1f\033[J\033[0m\n");
  printf (" ______________________________________________________________________________\n");
  while (strstr(b,"Have you") == NULL)
  {
    ++d;
    printf (b);
    fgets (b,132,fp);
  }
  printf ("\033[%d;24r",d);
  printf ("\033[%d;1H ______________________________________________________________________________\n",d-1);
  printf ("\033[22;1HHave you ever done any of the following:");
  return b;
}

char *head ()

{
  char a[81];
  int d;

  d = 3;
  while (strstr(a," Section 1: ") == NULL)
    fgets (a,132,fp);
  printf ("\033<\033[1;1f\033[J\033[0m\n");
  printf (" ______________________________________________________________________________\n");
  while (strstr(a,"Have you ever") == NULL)
  {
    ++d;
    printf (a);
    fgets (a,132,fp);
  }
  printf ("\033[A ______________________________________________________________________________\n");
  printf ("\033[%d;24r",d);
  printf ("\033[22;1HHave you ever done any of the following:");
  return a;
}

void percentage ()   /* puts up the percentage header at top    */

{
  char a[80];                /* shows % pure                 */
  char b[80];                /* prints trailing blanks       */
  int c;
  int d;

  printf ("\033(0");
  printf ("\033[1;1H\033[7m");
  if (current != 1)
  {
    for (c=1 ; c < (((current-yes-1)*80)/(current-1)) ; c++)
      printf ("a");
    printf ("\033[0m");
    for (d=c ; d < 80 ; d++)
      printf ("a");
  }
  else
    printf ("aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa\033[0m");
  printf ("\033(B");
  printf ("\033[23;1H");
}

void scoreme ()

{
  char user[12];              /* username                      */
  char time[80];
  char a[80];
  int b;
  int c;
  $DESCRIPTOR (datetime_d,time);
  $DESCRIPTOR (udesc,user);

  udesc.dsc$a_pointer = user;
  udesc.dsc$w_length = sizeof(user);
  lib$getjpi (&JPI$_USERNAME,0,0,0,&udesc);
  if (current != 1) c = ((current-yes-1)*100)/(current-1);

  datetime_d.dsc$w_length=23;
  lib$date_time (&datetime_d);

  user[12] = '\0';
  for (b=0 ; b<12 ; b++)
  {
    if (user[b] >= ' ' && user[b] <= 'z' )
      a[b] = user[b];
    else
      a[b] = ' ';
  }
  for (b=0; b <6 ; b++)
  {
    if (time[b] >= ' ' && time[b] <= 'z')
      a[b+12] = time[b];
    else
      a[b+12] = ' ';
  }
  a[18] = ' ';
  for (b=12; b <17 ; b++)
  {
    if (time[b] >= ' ' && time[b] <= 'z')
      a[b+7] = time[b];
    else
      a[b+7] = ' ';
  }
  a[24] = '\0';
  
  if (current == 1)
    fprintf (fp,"%s  PURITY_%s an undetermined \%\%  Pure from 0 questions.\n",a,user);
  else
    fprintf (fp,"%s  PURITY_%s %d\%\%  Pure from %d questions.\n",a,user,c,current-1);
}

void savestupid ()

{
  int a;
  int b;
  FILE *sp;                 /* file pointer for save file    */

  a = current*9;
  b = (current-yes+1)*7;
  sp = fopen (savefile,"w");
  fprintf (sp,"%d\n%d\n",a,b);
  fclose (sp);
}

void del ()

{
  $DESCRIPTOR(file_d,savefile);
  lib$delete_file(&file_d);
}

int retrieve (int *current, int *yes)

{
  int a;
  int b;
  FILE *rp;                 /* file pointer for save file    */
  
  rp = fopen (savefile,"r");

  if (rp != NULL)
  {
    fscanf(rp,"%d\n",&a);
    fscanf(rp,"%d\n",&b);
    fclose (rp);
    del ();

    *current = (a/9)-1;
    *yes = (*current-(b/7))+2;
    return True;
  }
  return False;
}

int echo ()

{
  int a;
  int b;
  a = True;

  printf ("\033<\033[1;1f\033[J\033[0m\n");
  printf ("\033[9;30HDo you want results");
  printf ("\033[10;30Hprinted to screen??");

  while (b != SMG$K_TRM_CTRLM )
  {
  if (b == SMG$K_TRM_UP ) ++a;
  if (b == SMG$K_TRM_DOWN) --a;
  if (a < 0) a = 1;
  if (a > 1) a = 0;
  if (a == 1)
   {
    printf ("\033[13;30HNO,I'm too perverse");
    printf ("\033[7m\033[12;30H  Yeah, why not?   \033[0m");
   }
  if (a == 0)
   {
    printf ("\033[12;30H  Yeah, why not?   ");
    printf ("\033[7m\033[13;30HNO,I'm too perverse\033[0m");
   }
  smg$read_keystroke (&keyboard,&b);
  }
  return a;
}

void sendjob()

{
  int a;
  int b;
  $DESCRIPTOR(crosby_d,"xprint/print_site=crosby $1$dua12:[temp.masmummy.purity]purity.test");
  $DESCRIPTOR(baldy_d,"xprint/print_site=baldy $1$dua12:[temp.masmummy.purity]purity.test");
  $DESCRIPTOR(ellicott_d,"xprint/print_site=ellicott $1$dua12:[temp.masmummy.purity]purity.test");
  $DESCRIPTOR(bell_d,"xprint/print_site=bell $1$dua12:[temp.masmummy.purity]purity.test");

  a = 0;
  b = 0;
  printf ("\033<\033[1;1f\033[J\033[0m\n");
  printf ("\033[10;25HTo which of the listed sites?");
  printf ("\033[11;20H1) Crosby  2) Baldy  3) Ellicott  4) Bell");
  printf ("\033[13;33HChoice? \033[1m");

  while (!((b == SMG$K_TRM_ONE) || (b == SMG$K_TRM_TWO) || (b == SMG$K_TRM_THREE )|| (b == SMG$K_TRM_FOUR )))
    smg$read_keystroke (&keyboard,&b);
  if (b == SMG$K_TRM_ONE)
  {
    printf ("Crosby");
    printf ("\033[0m");
    printf ("\033[15;24HBe sure to pick up your printout!");
    lib$do_command(&crosby_d);
  }
  if (b == SMG$K_TRM_TWO)
  {
    printf ("Baldy");
    printf ("\033[0m");
    printf ("\033[15;24HBe sure to pick up your printout!");
    lib$do_command(&baldy_d);
  }
  if (b == SMG$K_TRM_THREE)
  {
    printf ("Ellicott");
    printf ("\033[0m");
    printf ("\033[15;24HBe sure to pick up your printout!");
    lib$do_command(&ellicott_d);
  }
  if (b == SMG$K_TRM_FOUR)
  {
    printf ("Bell");
    printf ("\033[0m");
    printf ("\033[15;24HBe sure to pick up your printout!");
    lib$do_command(&bell_d);
  }
}

int accept ()

{
  int a;
  char b[132];
  int c;
  char d;
  FILE *dp;                 /* file pointer for disclaimer file      */

  printf ("\033[1;24r");
  b[1] = '1';               /* itialize b to something other than \0 */
  dp = fopen (disclaim,"r");
  if ( dp != NULL)
  {
    for ( c=1 ; c<100 ; c++)
    {
      fgets (b,132,dp);
      printf (b);
    }
  }
  
  printf ("\033[H\033[J");
  printf ("Do you want to \033[1mQ\033[0muit or \033[1mC\033[0montinue ?   ");
  while (!(d == 'q' || d == 'Q' || d == 'c' || d == 'C'))
    smg$read_keystroke (&keyboard,&d);
  if (d == 'q' || d =='Q' )
  {
    printf ("Quit");
    return False;
  }
  printf ("Continue");
  return True;
}

main ()
{
  smg$create_virtual_keyboard (&keyboard);
  fp = fopen (datafile,"r");
  quit = False;
  current = 0;
  yes = 0;
  if (accept ())
  {
      show = echo ();
      if (!(retrieve (&current,&yes)))
        line == head();
      else
      {
        printf ("\033<\033[1;1f\033[J\033[0m\n");
        printf ("\033[2;1H Resuming where you left off....\n");
        printf (" ______________________________________________________________________________\n");
        printf ("\033[4;24r");
      } 
      while ((!quit) && (!save) && (!(current == maxquest)))
      {
        ++current;
        percentage ();
        if (current != subint(line))
        {
          while (current != subint(line))      /* look for question beginning */
          {
            fgets (line,132,fp);               /* get the next line           */
          }
        }

      /* NOW: continue to read until you encounter next num, blank, divider*/

        while ((current+1 != subint(line)) && (!(divider(line))))
        {
          printf (line);                      /* print lines                 */
          fgets (line,81,fp);
        }
        get_ans (&quit,&yes,&save);
        if ((divider(line)) && (!(current == maxquest))) line == printdiv(current);
      }
      fclose (fp);
      printf ("\033<\033[1;1f\033[J\033[0m\n");
      fp = fopen (keep,"a");
      if ((!quit) && (!save)) current++;
      scoreme ();
      if (save)
      {
        savestupid ();
        printf ("Game saved.\n");
      }
      if (current == 1)
        printf ("That interested in the test eh?  Me too!\n");
      else
      {
        if ((!quit) && (!save)) printf ("You completed the test!\n");
        printf ("Your purity is: %d",((current-yes-1)*100)/(current-1));
        printf ("%\%\n");          /* %\%\n ??? well, it DOES work...  */
      }
    }
/*  }*/
}
