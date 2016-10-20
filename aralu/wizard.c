#include "aralu.h"

void kill_mon() /* kill a monster */
{
int i, j, y, x, n, k;
int limit;
short found;
char msg[80];

prt_msg("Which monster to kill? ['?' for listing]");
if ( (j = getkey()) == '?') {
  where();
  kill_mon();
  return;
}
found = FALSE;
k = 0;
n = 0;
while( n++ < MAXMONSTERS*level) {
  limit = monsters[k].max_mon;
  for ( i=0; i< limit; i++) {
     if ( monsters[k].mon_char == j) {
       monsters[k].dead = TRUE;
       y = monsters[k].posy;
       x = monsters[k].posx;
       map[y][x].mapchar = SPACE;
       map[y][x].number = 1;
       prt_char( map[y][x].mapchar, y, x);
       found = TRUE;
     }
  k++;
  } /* End FOR */
} /* End while */
if ( !found) prt_msg("No such monster exists on this level.");
}

void where() /* tells where the monsters are */
{
int i, j, dummy, k, limit;
char you[80];
char position[80];

j = 0;
k = 0;
while( j++ < MAXMONSTERS*level) {
 limit = monsters[k].max_mon;
 for ( i=0; i< limit; i++) {
   sprintf(position,"(%d) %15s at (%d,%d)[spd:%d](hel:%d)[ded:%d](mag:%d)[hlsp:%d]",
          k,mon_names[monsters[k].n_num],monsters[k].posx,monsters[k].posy,
          monsters[k].speed,monsters[k].health,monsters[k].dead,monsters[k].magic,monsters[k].hlspd);
   prt_msg(position);
   if ( k != 0  &&  k % 8 == 0) {
     prt_msg("Press any key for more ('q' to end listing).");
     dummy = 0;
     dummy = getch();
     if ( dummy == 'q') {
       sprintf(you,"You are at (%d,%d).  Stopmonst: %d",ppos.x,ppos.y,stop_monst);
       prt_msg(you);
       return;
     }
   }
   k++;
 } /* End FOR(i) loop */
} /* End while */
sprintf(you,"You are at (%d,%d).  Stopmonst: %d",ppos.x,ppos.y,stop_monst);
prt_msg(you);
}

void create_object() /* create any object where you are */
{
char obj;

prt_msg("Create which object character?");
obj = getch();
map[ppos.y][ppos.x].number = 5;   /* perfect condition OR 5 quantity */
underchar = obj;
prt_msg("Created.");
}

void delete_object() /* delete object on map */
{
int dx, dy;
int dir;

prt_msg("Remove object which direction?");
dir = getch();
switch( dir) {
        case KEY_UP:
        case UP: dy = -1; dx = 0; break;
        case KEY_DOWN:
        case DOWN: dy = 1; dx = 0; break;
        case KEY_LEFT:
        case LEFT: dx = -1; dy = 0; break;
        case KEY_RIGHT:
        case RIGHT: dx = 1; dy = 0; break;
        default: prt_msg("Invalid direction."); return; break;
}
map[ppos.y+dy][ppos.x+dx].mapchar = SPACE;
map[ppos.y+dy][ppos.x+dx].number = 1;
prt_char( SPACE, ppos.y+dy, ppos.x+dx);
prt_msg("Deleted.");
}

void set_stats() /* make a nice character */
{

STR ? grab_num("STR? ") : STR;
INT ? grab_num("INT? ") : INT;
DEX ? grab_num("DEX? ") : DEX;
CON ? grab_num("CON? ") : CON;
BUSE ? grab_num("BUSE? ") : BUSE;
kills ? grab_num("Kills? ") : kills;
wealth ? grab_num("wealth? ") : wealth;
health ? grab_num("health? ") : health;
experience ? grab_num("experience? ") : experience;
prt_status();
}

void fly() /* teleport */
{

map[ppos.y][ppos.x].mapchar = SPACE;
map[ppos.y][ppos.x].number = 1;
prt_char( map[ppos.y][ppos.x].mapchar, ppos.y, ppos.x);
while( 1) {
  ppos.x = grab_num("X-position? \0");
  ppos.y = grab_num("Y-position? \0");
  if ( !ISCLEAR( map[ppos.y][ppos.x].mapchar))
    prt_in_disp(dsp_command,"Something there. Try again.",9,1);
  else break;
}
map[ppos.y][ppos.x].mapchar = '@';
map[ppos.y][ppos.x].number = 1;
underchar = SPACE;
prt_char( map[ppos.y][ppos.x].mapchar, ppos.y, ppos.x);
change_viewport( ppos.y, ppos.x);
dely = delx = 0;
}

void goto_level() /* go to 'n' level in dungeon */
{

level = grab_num( "Go to which level? " ) - 1;
if (level < 1 || level > NUMLEVELS) return;
GAINLEVEL = TRUE;
}

void cure_all() /* cure all ailments from potions */
{
int j;

for ( j = 0; j < NUMFLAGS; j++)
  flags[j].moves = 0;
}
