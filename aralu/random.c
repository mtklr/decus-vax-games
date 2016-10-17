#include <stdlib.h>
#include <time.h>

void randomize()
{
  srandom(time(NULL));
}

int randnum(max_num)
{
  if (max_num)
    return(abs((int)random() % max_num));
  else
    return(max_num/2); /* Division by zero */
}
