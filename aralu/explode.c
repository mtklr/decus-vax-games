#include "aralu.h"

void explode( y, x, object, number, dir)
int y, x, number;
char object, dir;
{
int i, j, damage, monnum;
int lexdist, rexdist, uexdist, dexdist;
char map_char;
char item_killer[20];

lexdist = rexdist = uexdist = dexdist = 2;
switch( dir) {
  case UP:    dexdist = 0; break;
  case DOWN:  uexdist = 0; break;
  case LEFT:  lexdist = 0; break;
  case RIGHT: rexdist = 0; break;
  default: break;
} /* End switch */

/* smg$begin_pasteboard_update(&pb); */
for( i = y-dexdist; i <= y+uexdist; i++)
 if ( i > 0 && i < MAXROWS)
  for( j = x-lexdist; j <= x+rexdist; j++) {
   if ( j > 0 && j < MAXCOLS) {
     if ( obstacle( map[i][j].mapchar)) {
       if ( isamonster( map[i][j].mapchar)) {
         monnum = map[i][j].number;
         if ( ping_monster( j, i, monnum)) return;
         if ( object == 'b' || object == 'c' )
           do_attack( monnum, 99, object, dir);
         else  /* Multiple mines */
           while( number-- >0 && !monsters[monnum].dead)
             do_attack( monnum, 88, MINE, dir);
       }
       else if ( map[i][j].mapchar == '@') {
         if ( object == 'b'  ||  object == 'c')
           strcpy( item_killer, spells[object-MAGIC_NUMBER]);
         else strcpy( item_killer, object_names[get_name( object)]);
         damage = number*(5*(2+1) - 2*abs(y-i) - 2*abs(x-j));
         prt_msg("You are enveloped in the ball!");
         take_damage( damage, item_killer);
       }
       prt_char( map[i][j].mapchar, i, j);
     }
     else
       prt_char( '*', i, j);
   }
 } /* End FOR2 */
/* smg$end_pasteboard_update(&pb); */

/* clean up the mess */
/* don't have to print out obstacles, since we didn't write over them */
for( i = y-dexdist; i <= y+uexdist; i++)
 if ( i > 0 && i < MAXROWS)
  for( j = x-lexdist; j <= x+rexdist; j++)
   if ( j > 0 && j < MAXCOLS)
     if ( !obstacle( map[i][j].mapchar)) prt_char( SPACE, i, j);
}
