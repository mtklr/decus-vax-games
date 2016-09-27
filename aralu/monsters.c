#include "aralu.h"

void do_attack(int mon_num, int bp_num, char spell, int dir);

int eat( object) 
char object;
{
switch( object) {
   case WALL:
   case DOOR:
   case STORE:
   case BONES:
   case ARENA:
   case KEY:
   case BRIDGE:
   case BRIDGE2:
   case PIT:
   case WATER: return( FALSE);
}
return( TRUE);
}
   

char get_move( dir, i, newx, newy)
int dir, i, *newx, *newy;
{
int dx, dy;

monsters_struct *mon_ptr;
mon_ptr = &monsters[i];

  switch( dir) {
	case NORTH: dx = 0; dy = -1; break;
	case SOUTH: dx = 0; dy = 1; break;
	case WEST: dx = -1; dy = 0; break;
	case EAST: dx = 1; dy = 0; break;
	default: printf("Error finding direction.\n"); exit(1); /* Impossible */
  } /* End switch */

  if ( (randnum( 100) < mon_ptr->follow) ||  flags[MON_CONFUSE].valid) { 
    if ( randnum(4) < 2) dx = -dx; 
    else dy = -dy; 
  } 				/* if monsters are confused or their follow */
				/* is poor, make them go the wrong way */
				/* if monsters are hurting, they run away 
				   and hide -- flying monsters can't run */
  if ( mon_ptr->health < .25*3*(i+5) && !mon_ptr->fly) { dx = -dx; dy = -dy; } 

  *newy = mon_ptr->posy + dy;
  *newx = mon_ptr->posx + dx;
  return( map[*newy][*newx].mapchar);
}



void move_monsters( i)		/* move the monster 'i' toward the player */
int i;
{
/* For tdir[5], 0 = primary direction; 1 = alternate direction,
   	        2 = monster's current direcion, 3 = -primary, 4 = -alternate */
int movedir, testdir[5], newy, newx, firex, firey, ax, ay, moveoff, hlspeed;
int m_spell, fdr;
int distance = 0;
int k = 1;
char direction, testchar, firechar;
char fire_msg[80];
char mon_heal[80];
char dropped[80];

monsters_struct *mon_ptr;
mon_ptr = &monsters[i];

/* First see if the monster can fire -- is it in line with the player and if
   the fire percentage is high enough */
if ( (mon_ptr->posy == ppos.y  ||  mon_ptr->posx == ppos.x) &&
      randnum( 100) < mon_ptr->firec) {
  if ( mon_ptr->posy == ppos.y) { 
    if ( ppos.x < mon_ptr->posx) 
      { firey = 0; firex = -1; firechar = '-'; fdr = LEFT;}
    else { firey = 0; firex = 1; firechar = '-'; fdr = RIGHT;}
  }
  else if ( mon_ptr->posx == ppos.x) { 
    if ( ppos.y < mon_ptr->posy) 
      { firex = 0; firey = -1; firechar = '|'; fdr = UP;}
    else { firex = 0; firey = 1; firechar = '|'; fdr = DOWN;}
  }
  else printf("Error moving monster #%d.\n", i); /* should never happen */
  ax = mon_ptr->posx+firex; ay = mon_ptr->posy+firey;
  /* Check to see if the monster casts a spell -- 15% chance */
  if ( mon_ptr->magic  &&  randnum(100) < 15) {
    firechar = '*';
    m_spell = randnum( 2)+2;
    sprintf( fire_msg,"%s summons a %s!",
	          		  mon_names[mon_ptr->n_num], spells[m_spell-1]);
    prt_msg( fire_msg);
    mon_ptr->health -= 3;
  }

  while( map[ay][ax].mapchar != WALL  &&  (++distance < ARROWDIST) &&
         map[ay][ax].mapchar != '@' && !isamonster(map[ay][ax].mapchar)) {
    prt_char( firechar, ay, ax);
    prt_char( map[ay][ax].mapchar, ay, ax);
    ax = ax + firex; ay = ay + firey;
  } /* End while */
  if ( map[ay][ax].mapchar == '@') {
    if ( firechar != '*') monster_attack( i, ARROW);
    else explode( ay, ax, m_spell+MAGIC_NUMBER, 1, fdr); 
  }
  else if ( isamonster( map[ay][ax].mapchar)) {
    if ( firechar != '*') do_attack( map[ay][ax].number, 999, NULL, fdr);
    else explode( ay, ax, m_spell+MAGIC_NUMBER, 1, fdr);
  }
  else if ( distance != ARROWDIST && map[ay][ax].mapchar != WALL) 
      prt_msg("Error in monster firing.");
}
else {						/* can't fire anything */

/* first see if monster is close enough to the player to move */
if ( abs(ppos.y - mon_ptr->posy) < mon_ptr->range/2 &&
     abs(ppos.x - mon_ptr->posx) < mon_ptr->range) {
  if ( abs(mon_ptr->posx - ppos.x) > abs(mon_ptr->posy - ppos.y)) {
    if ( mon_ptr->posx > ppos.x) testdir[0] = WEST;
    else testdir[0] = EAST;
    if ( mon_ptr->posy > ppos.y) testdir[1] = NORTH;
    else testdir[1] = SOUTH;
/* contiue moving the monster in the same direction (not back and forth) */
    if ( (testdir[2] = mon_ptr->dir) == -testdir[0]) testdir[0] = testdir[1];
    if ( testdir[2] == -testdir[1]) testdir[1] = -testdir[1];
  }
  else {
    if ( mon_ptr->posy > ppos.y) testdir[0] = NORTH;
    else testdir[0] = SOUTH;
    if ( mon_ptr->posx > ppos.x) testdir[1] = WEST;
    else testdir[1] = EAST;
/* contiue moving the monster in the same direction (not back and forth) */
    if ( (testdir[2] = mon_ptr->dir) == -testdir[0]) testdir[0] = testdir[1];
    if ( testdir[2] == -testdir[1]) testdir[1] = -testdir[1];
  }  
  testdir[3] = -testdir[0];
  testdir[4] = -testdir[1];

  movedir = testdir[0];
  testchar = get_move( movedir, i, &newx, &newy);
  if ( testchar == '@') { 	/* First choice -- attack */
    monster_attack( i, SWORD); 
    return; 
  }
  else while( (!mon_ptr->fly && (testchar == WALL || testchar == WATER))
             || isamonster( testchar) || testchar == ARENA) {
	 movedir = testdir[k++];
         testchar = get_move( movedir, i, &newx, &newy);
	 if ( k > 4) break; 	
        } /* End while */

/* All choices for movement have been covered, reset monster direction */
  mon_ptr->dir = movedir;
    
  if ( testchar == '@') {  	/* trapped monster in cove -- attack */
    monster_attack( i, SWORD); 
    return; 
  }
/* Can't run over walls if trapped */
  else if ( testchar == WALL && !mon_ptr->fly) return; 

  if ( !mon_ptr->fly) {
   if ( testchar == MINE)
     explode( mon_ptr->posy, mon_ptr->posx, MINE, map[newy][newx].number, NULL);
   if ( testchar == PIT)
     do_attack( i, 77, NULL, NULL);
  }
 if ( mon_ptr->dead) {				/* monster was killed */
  if ( monkilled == MAXMONSTERS*level) {	
    map[newy][newx].mapchar = KEY;
    map[newy][newx].number = 1;
    sprintf(dropped,"%s drops the key as it writhes in agony and dies.",
		     				mon_names[mon_ptr->n_num]);
    prt_msg(dropped);
    prt_char( KEY, newy, newx);
  }
  else {
    if ( testchar == SPACE || testchar == MINE) {
      map[newy][newx].mapchar = CASH;
      map[newy][newx].number = 1;
    }
    else {
      sprintf(dropped,"%s's gold was lost when he died.",mon_names[mon_ptr->n_num]);
      prt_msg(dropped);
      map[newy][newx].mapchar = testchar;
      map[newy][newx].number = 1;
    }
    prt_char(map[newy][newx].mapchar,newy,newx);
  }
  if ( mon_ptr->number == rival_num && in_arena) {
    can_exit = TRUE;
    map[newy][newx].mapchar = HAXE;
    map[newy][newx].number = 1;
    map[a_posy][a_posx].mapchar = BONES;
    prt_char( map[a_posy][a_posx].mapchar, a_posy, a_posx); 
  }
   map[mon_ptr->posy][mon_ptr->posx].mapchar = mon_ptr->underchar;
   map[mon_ptr->posy][mon_ptr->posx].number = 1;
   prt_char(map[mon_ptr->posy][mon_ptr->posx].mapchar,
                                                  mon_ptr->posy,mon_ptr->posx); 
 } /* End IF (dead) */
else { 						/* monster was not killed */
   map[mon_ptr->posy][mon_ptr->posx].mapchar = mon_ptr->underchar;
   map[mon_ptr->posy][mon_ptr->posx].number = 1;
   prt_char(map[mon_ptr->posy][mon_ptr->posx].mapchar,
                                                  mon_ptr->posy,mon_ptr->posx); 
   map[newy][newx].mapchar = mon_ptr->mon_char;
   map[newy][newx].number = i;
   prt_char(map[newy][newx].mapchar,newy,newx);

   mon_ptr->posy = newy;
   mon_ptr->posx = newx;
   if ( eat( testchar) && !mon_ptr->fly) mon_ptr->underchar = SPACE;
   else mon_ptr->underchar = testchar;
  } /* End (dead) ELSE */
 } /* End movedist IF */
 else { /* if monster is hurting and it's time to heal, add one to the health */
   if ( (hlspeed = mon_ptr->hlspd*mon_ptr->speed) < 1) hlspeed = 1;
   if ( moves % hlspeed == 0  &&  mon_ptr->health < .8*3*(i+5)) 
     mon_ptr->health++;
 } /* End movedist ELSE */

} /* End firing ELSE */
}


resurrect( num)
int num;
{

monsters[num].dead = FALSE;
monsters[num].underchar = SPACE;
monsters[num].health = 3*(monsters[num].n_num+5);
/* give him a new position */
do {			  
  monsters[num].posy = randnum( MAXROWS); 
  monsters[num].posx = randnum( MAXCOLS);
 }while( !ISCLEAR( map[monsters[num].posy][monsters[num].posx].mapchar));
}


short read_monsters()
{
FILE *mfile;
int mon_num, y, x, i, max_m_ct;
int count = 0;
short ret = 0;
char dummy[80];

monsters_struct *m;	/* new monster type read in */
monsters_struct *nm;	/* next monster number of that type */

if ( (mfile = fopen( monfile,"r")) != NULL) {
  do { 
      if (count++ > 10) {
       printf("\nNo ending comment in monsters datafile."); 
       exit(0); 
      }
      fgets(dummy,80,mfile);
    } while( strstr(dummy,"**/") == 0);
  mon_num = -1;
  do {
/* Note: monster 'type' defined by "n_num" (name number read in from file) */
     mon_num++;
     m = &monsters[mon_num];
     fscanf(mfile,"%d %d %d %c %d %d %d %d %d %d %d %d %d %d %d %d",
 	     &m->max_mon,&m->n_num,&m->a_num,&m->mon_char,&m->dam,&m->health,
 	     &m->follow,&m->speed,&m->firec,&m->range,&m->reschance,&m->f_num,
	     &m->dead,&m->fly,&m->magic,&m->hlspd);
     do {
       x = randnum(MAXCOLS);
       y = randnum(MAXROWS);
     } while( !ISCLEAR( map[y][x].mapchar));
     m->posy = y; 
     m->posx = x;
     m->underchar = SPACE;
     m->dir = NORTH;
     m->number = mon_num;
     max_m_ct = m->max_mon;

/* Create the maximum number of monsters per 'type' -- eg. 4 ants, 3 clams */
     while( max_m_ct-- > 1) {		/* if only one, skip next procedure */
        mon_num++;
        nm = &monsters[mon_num];       /* next monster number */
        nm->number = mon_num;
        nm->max_mon = m->max_mon;
        nm->n_num = m->n_num;
        nm->a_num = m->a_num;
        nm->mon_char = m->mon_char;
        nm->dam = m->dam;
        nm->health = m->health;
        nm->follow = m->follow;
        nm->speed = m->speed;
        nm->firec = m->firec;
        nm->range = m->range;
        nm->reschance = m->reschance;
        nm->f_num = m->f_num;
        nm->dead = m->dead;
        nm->fly = m->fly;
        nm->magic = m->magic;
        nm->hlspd = m->hlspd;
        do {
          x = randnum(MAXCOLS);
          y = randnum(MAXROWS);
        } while( !ISCLEAR( map[y][x].mapchar));
        nm->posy = y; 
        nm->posy = y; 
        nm->posx = x;
        nm->underchar = SPACE;
        nm->dir = NORTH;
     } /* End while */
   } while( m->n_num < DIFFMON-1);	/* use n_num as a counter for DIFFMON */
fclose( mfile);
}
else ret = E_OPENMON;
return( ret);
}


prt_monsters()					/* for restored games */
{
int i, j, k;
int limit;

i = 0;
k = 0;
while( i++ < MAXMONSTERS*level) {
  limit = monsters[k].max_mon;
  for (j=0; j< limit; j++) {
     map[monsters[k].posy][monsters[k].posx].mapchar = monsters[k].mon_char;
     map[monsters[k].posy][monsters[k].posx].number = k;
     prt_char( monsters[k].mon_char, monsters[k].posy, monsters[k].posx);
     k++;
  }
 } /* End while */
}



monster_attack( mon_num, obj)		/* this is for monster attacks */
int mon_num;
char obj;
{
int damage_done;
char op_msg[80];
char mon_attack[80];

if ( obj == ARROW) 
 sprintf(mon_attack,"%s %s.",mon_names[monsters[mon_num].n_num],
 			            monfire[monsters[mon_num].f_num]);
else
 sprintf(mon_attack,"%s %s.",mon_names[monsters[mon_num].n_num],
				    attacks[monsters[mon_num].a_num]);
damage_done = monsters[mon_num].dam + randnum( monsters[mon_num].dam);
if ( operator) { 
  sprintf(op_msg,"MSock: %d",damage_done);
  prt_msg(op_msg);
}
prt_msg(mon_attack);
take_damage( damage_done, mon_names[monsters[mon_num].n_num]);
}


void do_attack( mon_num, bp_num, spell, dir)
int mon_num, bp_num, dir;
char spell;
{
int add_damage, add_wealth, damage_done, miss_chance, mymiss, rnd, dy, dx;
char condmsg[80];
char mymiss_msg[30];
char op_msg[80];
char killed[80];
char player_attack[80];
char dropped[80];
char weapon;

monsters_struct *mon_ptr;
mon_ptr = &monsters[mon_num];

switch( dir) {
   case UP: dx = 0; dy = -1; break;
   case DOWN: dx = 0; dy = 1; break;
   case LEFT: dx = -1; dy = 0; break;
   case RIGHT: dx = 1; dy = 0; break;
} /* End switch */
if ( bp_num < MAXINVEN) /* Not a PIT or MINE */
  if ( ping_monster( ppos.x+dx, ppos.y+dy, mon_num)) return;

if ( bp_num == 99) weapon = ORB;
else if ( bp_num == 999) weapon = ARROW;
else if ( bp_num == 88) weapon = MINE;
else if ( bp_num == 77) weapon = PIT;
else weapon = BACKPACK[bp_num].invenchar;
if ( bp_num != 0) {
  if ( weapon == ARROW) {
    sprintf(player_attack,"The bolt finds its mark and hits %s.",
    						mon_names[mon_ptr->n_num]);
    add_damage = BUSE / (level*2);
    damage_done = randnum( add_damage)+1 + ITEM_PROPS[identify( ARROW)][DAMAGE];
  } 
  else if ( weapon == ORB) {
    if ( spell == 'a') {
    sprintf(player_attack,"The lightning bolt strikes %s!",
 						mon_names[mon_ptr->n_num]);
    add_damage = (INT - 13)/3;
    }
    else if ( spell == 'b') {
    sprintf(player_attack,"The fireball envelops %s!",
 						mon_names[mon_ptr->n_num]);
    add_damage = (INT - 13)/2;
    }
    else if ( spell == 'c') {
    sprintf(player_attack,"The acid ball envelops %s!",
 						mon_names[mon_ptr->n_num]);
    add_damage = (INT - 13)*2;
    }
    else {
    sprintf(player_attack,"%s explodes into dust!",mon_names[mon_ptr->n_num]);
    add_damage = 1000;
    }
    damage_done = randnum( add_damage) + ITEM_PROPS[identify( ORB)][DAMAGE];  
    switch( BACKPACK[check_inven( ORB)].condition) {
	case 1: prt_msg("The Orb's power is very slight.");
	        sprintf(player_attack,"The effect of the spell is greatly reduced.");
		damage_done *= 0.25; break;
	case 2: prt_msg("The spell is cast at one half normal power.");
	        sprintf(player_attack,"The effect of the spell is reduced.");
		damage_done *= 0.5; break;
	case 3: prt_msg("The Orb is weakened in power.");
	        sprintf(player_attack,"The effect of the spell is reduced.");
		damage_done *= 0.75; break;
	case 4: prt_msg("The power of the Orb is slightly low.");
	        sprintf(player_attack,"The effect of the spell is reduced slightly.");
		damage_done *= 0.9;
    } /* End switch */
  }
  else if ( weapon == MINE) {
    sprintf(player_attack,"%s hits the mine!!",mon_names[mon_ptr->n_num]);
    damage_done = randnum( ITEM_PROPS[identify( MINE)][DAMAGE]) + 1;
  }
  else if ( weapon == PIT) {
    sprintf(player_attack,"You hear %s wail in pain as it falls into a pit.",
	    mon_names[mon_ptr->n_num]);
    damage_done = randnum( 10) + 1;
  }
  else {
    add_damage = (STR - 14)/2 + randnum( 4);
    damage_done = randnum( add_damage)+1 + ITEM_PROPS[identify( weapon)][DAMAGE];
    if ( BACKPACK[bp_num].condition < 1) damage_done = 1;
    else damage_done *= (0.20 * BACKPACK[bp_num].condition);
    if ( damage_done <= 1)
      sprintf(player_attack,"Your %s deflects harmlessly off %s.",
	             BACKPACK[bp_num].name,mon_names[mon_ptr->n_num]);
    else if ( damage_done < 5)
      sprintf(player_attack,"Your %s strikes %s.",
	             BACKPACK[bp_num].name,mon_names[mon_ptr->n_num]);
    else if ( damage_done < 9)
      sprintf(player_attack,"You pummel %s with your %s.",
	             mon_names[mon_ptr->n_num],BACKPACK[bp_num].name);
    else if ( damage_done < 12)
      sprintf(player_attack,"You sever %s's disgusting body with your %s.",
	             mon_names[mon_ptr->n_num],BACKPACK[bp_num].name);
    else
      sprintf(player_attack,"You utterly demolish %s with your %s!",
	             mon_names[mon_ptr->n_num],BACKPACK[bp_num].name);

    if ( (miss_chance = DEX - 10) < 0) miss_chance = 0;
    mymiss = randnum( ITEM_PROPS[identify( weapon)][WEIGHT]/10)+1;
    if ( operator) {
      sprintf(mymiss_msg,"Miss chance: %d",mymiss);
      prt_msg(mymiss_msg);
    }
    if ( miss_chance < mymiss) {
      sprintf(player_attack,"You swing wildly at the %s and miss!",mon_names[mon_ptr->n_num]);
      damage_done = 0;
    }
    else if ( randnum( 100) < 8 && BACKPACK[bp_num].condition < 2) {
           sprintf(player_attack,"Your %s shatters into a thousand pieces.",
	 	     BACKPACK[bp_num].name);
	   break_weapon( bp_num);
    }
    else if ( randnum( 100) < 5) {
      sprintf(player_attack,"Your %s finds its way to %s's heart.",
	             BACKPACK[bp_num].name,mon_names[mon_ptr->n_num]);
      damage_done = 1000;	/* automatic kill */
    }
  }
}
else {						/* bare handed attack */
  sprintf(player_attack,"You graze %s with your fists.",
				     mon_names[mon_ptr->n_num]);
    add_damage = (STR - 14)/2;
    damage_done = randnum( add_damage)+1 + ITEM_PROPS[HANDS][DAMAGE];
}
if ( operator) { 
  sprintf(op_msg,"PSock: %d",damage_done);
  prt_msg(op_msg);
}

if ( randnum( 100) < 8 && damage_done > 0 && bp_num != 0) {
  if ( weapon == ORB) bp_num = check_inven( ORB);
  else if ( weapon == ARROW) bp_num = check_inven( BOW);
  if ( weapon != MINE  &&  weapon != PIT  &&  weapon != ORB) {
     BACKPACK[bp_num].condition--;
     prt_msg("Your weapon's condition is worsening.");
  }
}

prt_msg(player_attack);
mon_ptr->health -= damage_done;
if ( mon_ptr->health <= 0) {
  sprintf(killed,"%s %s.",mon_names[mon_ptr->n_num],deaths[randnum( 5)]);
  prt_msg(killed);
  experience += BONUS*level/10;
  if ( weapon == MINE || weapon == PIT) experience -= BONUS*level/20;
  kills++;
  prt_exp();
  prt_kills();
  monkilled++;
  mon_ptr->dead = TRUE;
  if ( weapon == MINE || weapon == PIT) return;
  if ( monkilled == MAXMONSTERS*level) {	
    map[mon_ptr->posy][mon_ptr->posx].mapchar = KEY;
    map[mon_ptr->posy][mon_ptr->posx].number = 1;
    sprintf(dropped,"%s drops the key as it writhes in agony and dies.",
		     				mon_names[mon_ptr->n_num]);
    prt_msg(dropped);
  }
  else {
    if ( mon_ptr->underchar == SPACE) {
      map[mon_ptr->posy][mon_ptr->posx].mapchar = CASH;
      map[mon_ptr->posy][mon_ptr->posx].number = 1;
    }
    else {
      sprintf(dropped,"%s's gold was lost when he died.",
						     mon_names[mon_ptr->n_num]);
      prt_msg(dropped);
      map[mon_ptr->posy][mon_ptr->posx].mapchar = mon_ptr->underchar;
      map[mon_ptr->posy][mon_ptr->posx].number = 1;
    }
  }
  if ( mon_ptr->number == rival_num && in_arena) {
    can_exit = TRUE;
    map[mon_ptr->posy][mon_ptr->posx].mapchar = HAXE;
    map[mon_ptr->posy][mon_ptr->posx].number = 1;
    map[a_posy][a_posx].mapchar = BONES;
    prt_char( map[a_posy][a_posx].mapchar, a_posy, a_posx); 
  }
  prt_char(map[mon_ptr->posy][mon_ptr->posx].mapchar,mon_ptr->posy,
						      		 mon_ptr->posx);
} /* End IF */
}
