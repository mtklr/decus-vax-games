#include <stdlib.h>

int randomize()
{
  int seed;
  char dt[30];

  /* $DESCRIPTOR(d_s,dt); */
  /* lib$date_time(&d_s); */
  /* random_seed=(dt[16]+dt[19]*7+dt[21]*88+dt[22]*624); */
  /* random_incl= (mth$random(&random_seed) % 50); */
  srandom(time(NULL));
}

int randnum(max_num)
{
  /* int seed; */
  /* seed=(random_seed + ++random_incl*624); */
  if (max_num)
    return(abs((int)random() % max_num));
  else
    return(max_num/2); /* Division by zero */
}
