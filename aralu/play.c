#include "aralu.h"

short parse_keystroke( keyhit)
int keyhit;
{
int dummy, diff_num, d;
short ret = 0;
/* figure out which key was hit and stuff like that */

switch( keyhit) {

        case 'q': drink_potion(); break;
        case 'Q': prt_msg("Saving game...");
                  ret = E_SAVED;
                  break;
        case 'S': prt_msg("Choose another speed.");
                  wtimeout(dsp_viewport, -1);
                  wclear(dsp_status);
                  prt_difficulty(dsp_status);
                  diff_num = getkey();
                  switch( diff_num) {
                   case '1': DIFFICULTY = DIFFSLOW; break;
                   case '2': DIFFICULTY = DIFFFAST; break;
                   case '3': DIFFICULTY = DIFFVERYFAST; break;
                   case '4': DIFFICULTY = DIFF1200BAUD; break;
                   default: DIFFICULTY = DIFFNORMAL;
                  }
                  wclear(dsp_status);
                  wtimeout(dsp_viewport, TIMEOUT);
                  prt_status();
                  break;
        case UP   :
        case LEFT :
        case DOWN :
        case RIGHT: move_plr( keyhit); break;
        case KEY_UP:
                    move_plr(UP); break;
        case KEY_DOWN:
                    move_plr(DOWN); break;
        case KEY_LEFT:
                    move_plr(LEFT); break;
        case KEY_RIGHT:
                    move_plr(RIGHT); break;
        case ' ': fire_item( ARROW); break;
        case 'u': choose_spell(); break;
        case 's': wclear(dsp_status);
                  prt_status();
                  break;
        case 't': get_time(); break;
        case 'b': prt_inven(); break;
        case 'c': change_viewport( ppos.y, ppos.x);
                  dely = 0; delx = 0;
                  break;
        case 'e': if ( underchar != DOOR  &&  underchar != STORE)
                    prt_msg("There is no door here to enter.");
                  else if ( underchar == STORE) {
                    prt_msg("You walk into the store.");
                    map[ppos.y][ppos.x].number = 1;
                    enter_store();
                  }
                  else if ( !KEYPOSESS)
                    prt_msg("You don't have a key to open this door.");
                  else {
                    GAINLEVEL = TRUE;
                    underchar = SPACE;
                  }
                  break;
        case 23: if ( operator) {
                    operator = FALSE;
                    prt_msg("Wizard mode off.");
                 }
                 else if ( strcmp( username, SUPERUSER) == 0) {
                    operator = TRUE;
                    prt_msg("Wizard mode on.");
                 }
                 else prt_msg("Press '?' for help.");
                 break;
        case 26:  prt_msg("Quit/no save? ['y' to confirm]");
                  if ( toupper( getkey()) == 'Y') ret = E_ENDGAME;
                  break;
        case 12:  refresh(); break;
        /* case 2:   prt_msg("Zoom!"); sys$setpri(0,0,4,0); break; */
        /* case 18:  recall_messages(); break; */
        case 'x': exchange_weap(); break;
        case 'w': wear_wield(); break;
        case 'd': drop(); break;
        case 'r': read_scroll(); break;
        case 'v': view(); break;
        case 'h': do_heal(); break;
        case '?': help(); break;
/* Operator commands */
        case 11: if (!operator) prt_msg("Press '?' for help.");
                 else kill_mon();
                 break;
        case 13: if (!operator) prt_msg("Press '?' for help.");
                 else where();
                 break;
        case 14: if (!operator) prt_msg("Press '?' for help.");
                 else {
                   if ( stop_monst) stop_monst = FALSE;
                   else stop_monst = TRUE;
                 }
                 break;
        case 16: if (!operator) prt_msg("Press '?' for help.");
                 else create_object();
                 break;
        case 1:  if (!operator) prt_msg("Press '?' for help.");
                 else cure_all();
                 break;
        case 4:  if (!operator) prt_msg("Press '?' for help.");
                 else delete_object();
                 break;
        case 5:  if (!operator) prt_msg("Press '?' for help.");
                 else set_stats();
                 break;
        case 6:  if (!operator) prt_msg("Press '?' for help.");
                 else fly();
                 break;
        case 7:  if (!operator) prt_msg("Press '?' for help.");
                 else goto_level();
                 break;
        case KEY_BACKSPACE:
        case 8: if (!operator) prt_msg("Press '?' for help.");
                else { health = MAXHEALTH; prt_health(); }
                break;
        default: prt_msg("Press '?' for help.");
} /* End switch */
if ( dead) ret = E_ENDGAME;
else if (GAINLEVEL) ret = E_GAINLEVEL;
return( ret);
}

void recall_messages()
{
/* int r_c; */
/* $DESCRIPTOR( return_d,"Press any key to return to game."); */

/* prt_msg(""); /1* line advance *1/ */
/* smg$begin_pasteboard_update(&pb); */
/* smg$unpaste_virtual_display(&dsp_main,&pb); */
/* smg$unpaste_virtual_display(&dsp_status,&pb); */
/* smg$unpaste_virtual_display(&dsp_inven,&pb); */
/* smg$end_pasteboard_update(&pb); */
/* smg$put_chars(&dsp_command,&return_d,&22,&23,&1,&2); */
/* smg$read_keystroke(&kboard,&r_c); */
/* prt_msg(""); /1* line advance *1/ */
/* smg$begin_pasteboard_update(&pb); */
/* smg$paste_virtual_display(&dsp_main,&pb,&2,&2); */
/* smg$paste_virtual_display(&dsp_status,&pb,&2,&43); */
/* smg$end_pasteboard_update(&pb); */
    return;
}

void move_plr( direction)
int direction;
{
int number, dx, dy, rnd;
char testchar;

/* If player is confused, change the direction randomly */
if ( flags[CONFUSE].valid) {
  if ( (rnd = randnum(4)) < 1) direction = UP;
  else if ( rnd < 2) direction = DOWN;
  else if ( rnd < 3) direction = LEFT;
  else direction = RIGHT;
}
switch( direction) {
  case UP: dx = 0; dy = -1; break;
  case DOWN: dx = 0; dy = 1; break;
  case LEFT: dx = -1; dy = 0; break;
  case RIGHT: dx = 1; dy = 0; break;
} /* End switch */

testchar = map[ppos.y+dy][ppos.x+dx].mapchar;
number = map[ppos.y+dy][ppos.x+dx].number;
if ( !obstacle(testchar)) { do_move( direction); underchar = testchar;}
else if (isamonster( testchar)) do_attack( number, WIELD, SWORD, direction);
else check_object( testchar, number, direction);
}

void read_scroll() /* read a scroll */
{
int bp_num, item_num, PREWEIGHT, rnd_scr;
char read[80];

if ( (bp_num = check_inven( SCROLL)) != FALSE) {
  item_num = identify( SCROLL);
  if ( (--BACKPACK[bp_num].quantity) == 0) {
    BACKPACK[bp_num].invenchar = SPACE;
    compress_inven();
  }
  PREWEIGHT = CURWEIGHT;
  CURWEIGHT -= ITEM_PROPS[item_num][WEIGHT];
  if ( (PREWEIGHT >= MAXWEIGHT) && (CURWEIGHT < MAXWEIGHT)) {
    change_speed( 2.0);
    prt_msg("The burden of the pack is lifted.");
    prt_speed();
  }
  prt_wgt();
  if ( (rnd_scr = randnum( 100)) < 85) {
    if ( in_arena) {
      prt_msg("You cannot teleport out of the arena.");
      prt_msg("The scroll vanishes.");
      return;
    }
    prt_msg("This is a teleport scroll.");
    map[ppos.y][ppos.x].mapchar = SPACE;
    map[ppos.y][ppos.x].number = 1;
    prt_char( map[ppos.y][ppos.x].mapchar, ppos.y, ppos.x);
    do {
      ppos.y = randnum( MAXROWS);
      ppos.x = randnum( MAXCOLS);
    } while( map[ppos.y][ppos.x].mapchar != SPACE);
    map[ppos.y][ppos.x].mapchar = '@';
    map[ppos.y][ppos.x].number = 1;
    underchar = SPACE;
    prt_char( map[ppos.y][ppos.x].mapchar, ppos.y, ppos.x);
    change_viewport( ppos.y, ppos.x);
    dely = delx = 0;
    prt_msg("Poof!");
    }
  else {
    prt_msg("This is an Enchant Item scroll.");
    enchant();
  }
}
else prt_msg("You have no scrolls to read.");
}

void enchant()
{
int echar, item_num, bp_num;

prt_msg("Enchant which item? [* for list]");
echar = getkey();
echar -= MAGIC_NUMBER;
if ( echar+MAGIC_NUMBER == '*') { prt_inven(); enchant(); }
else if ( echar < 1  ||  echar > MAXINVEN-1) {
       prt_msg("You cannot enchant that!");
       prt_msg("The scroll vanishes into dust.");
       return;
}
else if ( BACKPACK[echar].invenchar != SPACE) { /* you have it */
       item_num = identify( BACKPACK[echar].invenchar);
       if ( ITEM_PROPS[item_num][WEARABLE] == TRUE) {
         if ( ITEM_PROPS[item_num][ITEMCHAR] == ARMOR)
           prt_msg("Your armor glows brightly for a moment.");
         else if ( ITEM_PROPS[item_num][ITEMCHAR] == ORB)
           prt_msg("The Orb pulsates with a bright green glow.");
         else
           prt_msg("Your weapon glows brightly for a moment.");

         BACKPACK[echar].condition++;
       }
       else {
         prt_msg("You cannot enchant that!");
         prt_msg("The scroll vanishes into dust.");
       }
}
}

void view() /* look in a given direction */
{
int dx, dy, ax, ay;
int item_num, i, j, mon_health, sight_dist;
int distance = 0; /* cur viewing distance */
char viewchar[80];
char mon_health_msg[80];
int dir;

prt_msg("View which direction?");
dir = getkey();
switch( dir) {
        case KEY_UP:
        case UP: dx = 0; dy = -1; sight_dist = MAXVIEWDIST/2; break;
        case KEY_RIGHT:
        case RIGHT: dx = 1; dy = 0; sight_dist = MAXVIEWDIST; break;
        case KEY_LEFT:
        case LEFT: dx = -1; dy = 0; sight_dist = MAXVIEWDIST; break;
        case KEY_DOWN:
        case DOWN: dx = 0; dy = 1; sight_dist = MAXVIEWDIST/2; break;
        default: prt_msg("Invalid direction."); return;
} /* End switch */

    ax = ppos.x+dx; ay = ppos.y+dy;
    while( ++distance < sight_dist) {
       if ( isamonster( map[ay][ax].mapchar)) {
         mon_health = monsters[map[ay][ax].number].health;
         if ( mon_health > 7+(level*5)) strcpy( mon_health_msg,"which is in perfect health");
         else if ( mon_health > 4+(level*5)) strcpy( mon_health_msg,"which has some minor wounds");
         else if ( mon_health > (level*5)) strcpy( mon_health_msg,"and it is hurting badly now");
         else strcpy( mon_health_msg,"which is very near death");

         sprintf(viewchar,"You see %s, %s.",
                mon_names[monsters[map[ay][ax].number].n_num], mon_health_msg);
         prt_msg(viewchar);
       }
       else if ( map[ay][ax].mapchar == WALL) {
         prt_msg("You see a stone wall.");
         break;
       }
       else if ( map[ay][ax].mapchar != SPACE) {
         if ( (item_num = identify( map[ay][ax].mapchar)) == MAGIC_NUMBER)
           sprintf(viewchar,"You see a %s.",
                                  object_names[get_name( map[ay][ax].mapchar)]);
         else if ( combinable( item_num)) {
           if ( map[ay][ax].number <= 1)
             sprintf(viewchar,"You see a %s.",
                                  object_names[get_name( map[ay][ax].mapchar)]);
           else
             sprintf(viewchar,"You see %d %ss.",map[ay][ax].number,
                                  object_names[get_name( map[ay][ax].mapchar)]);
         }
         else {
          if ( map[ay][ax].number < 2)
            sprintf(viewchar,"You see a %s in very poor condition.",
                                object_names[get_name( map[ay][ax].mapchar)]);
          else if ( map[ay][ax].number < 3)
            sprintf(viewchar,"You see a %s in poor condition.",
                                object_names[get_name( map[ay][ax].mapchar)]);
          else if ( map[ay][ax].number < 4)
            sprintf(viewchar,"You see a %s in average condition.",
                                object_names[get_name( map[ay][ax].mapchar)]);
          else if ( map[ay][ax].number < 5)
            sprintf(viewchar,"You see a %s in good condition.",
                                object_names[get_name( map[ay][ax].mapchar)]);
          else if ( map[ay][ax].number < 6)
            sprintf(viewchar,"You see a %s in perfect condition.",
                                object_names[get_name( map[ay][ax].mapchar)]);
          else
            sprintf(viewchar,"You see an enchanted %s!",
                                object_names[get_name( map[ay][ax].mapchar)]);
         }
         prt_msg(viewchar);
       }
       ax = ax + dx; ay = ay + dy;
    } /* End while */
}

void do_heal() /* heal up */
{
int bp_num, item_num;
int PREWEIGHT;

item_num = identify( HEALTH);
if ( (bp_num = check_inven( HEALTH)) != FALSE) {
  if ( (--BACKPACK[bp_num].quantity) == 0) {
    BACKPACK[bp_num].invenchar = SPACE;
    compress_inven();
  }
  prt_wgt();
  PREWEIGHT = CURWEIGHT;
  CURWEIGHT -= ITEM_PROPS[item_num][WEIGHT];
    if ( (PREWEIGHT >= MAXWEIGHT) && (CURWEIGHT < MAXWEIGHT)) {
    change_speed( 2.0);
    prt_msg("The burden of the pack is lifted.");
    prt_speed();
  }
  if ( health < 5) prt_msg("You are still in bad shape.");
  else if ( health < 20)
  prt_msg("Your major wounds heal, but you are still hurting.");
  else if ( health < 50) prt_msg("You're in average condition.");
  else prt_msg("You're ready for battle.");
  if ( health > MAXHEALTH) health -= ITEM_PROPS[item_num][DAMAGE]/2;
  else health -= ITEM_PROPS[item_num][DAMAGE];
  prt_health();
}
else prt_msg("You have nothing to heal yourself with.");
}

void choose_spell()
{
int i, failure[SPELLNAMES+1], sp, c_wait, yrange, xrange;
char spell[40];
/* $DESCRIPTOR( spell_label,"Magic Spells"); */
/* $DESCRIPTOR( invenlabel, "Inventory"); */

/* smg$erase_display(&dsp_inven); */
wclear(dsp_inven);
/* smg$label_border(&dsp_inven,&spell_label); */
wprintw(dsp_inven, "Magic Spells");
for (i=1; i<= SPELLNAMES; i++) {
   failure[i] =  (75 + pow(i-level-1,3)) - (5*(INT-14) + 3*level) + i*2;
   sprintf(spell,"%c) %20s Failure: %d%%",i+MAGIC_NUMBER,spells[i-1],failure[i]);
   prt_in_disp(dsp_inven,spell,i,1);
}
while( !dead) {
 sp = 0;
 prt_msg("Which spell to use? [* for list and failure %]");
 sp = getkey();
 if ( sp == '*') wrefresh(dsp_inven);
 else break;
}
if (dead) return;

if ( check_inven( ORB) == FALSE) {
  prt_msg("You don't have the Magic Orb.");
  /* smg$label_border(&dsp_inven,&invenlabel); */
  /* smg$paste_virtual_display(&dsp_status,&pb,&2,&43); */
  return;
}

c_wait = 5 * (sp - MAGIC_NUMBER); /* # of moves casting time */
if ( (sp -= MAGIC_NUMBER) <= SPELLNAMES) {
  prt_msg("You summon your energies and attempt to cast the spell.");
  while( c_wait-- > 0)
    do_acts();
  if (dead) return;
}
if ( sp < 5) {
 if ( randnum( 100) > failure[sp]) {
   fire_item( sp+MAGIC_NUMBER);
   if ( randnum( 100) < 10) {
     prt_msg("The Orb's power is draining.");
     BACKPACK[check_inven( ORB)].condition--;
   }
 }
 else prt_msg("The spell fails.");
}
else if ( sp == 5) {
 if ( randnum( 100) > failure[sp]) {
   if ( !flags[MON_CONFUSE].valid) {
     flags[MON_CONFUSE].valid = TRUE;
     flags[MON_CONFUSE].moves += 61;
     prt_msg("The monsters appear to be wandering about in a daze.");
   }
   else prt_msg("The confusion spell has no effect.");
   if ( randnum( 100) > 10) {
     prt_msg("The Orb's power is draining.");
     BACKPACK[check_inven( ORB)].condition--;
   }
 }
 else prt_msg("The spell fails.");
}
else if ( sp == 6) {
 if ( randnum( 100) > failure[sp]) {
   if (in_arena) {
     prt_msg("You cannot teleport out of the arena.");
     return;
   }
   map[ppos.y][ppos.x].mapchar = SPACE;
   map[ppos.y][ppos.x].number = 1;
   prt_char( map[ppos.y][ppos.x].mapchar, ppos.y, ppos.x);
   yrange = BACKPACK[check_inven(ORB)].condition*5;
   xrange = BACKPACK[check_inven(ORB)].condition*10;
   do {
     ppos.y += randnum( yrange) - yrange/2;
     ppos.x += randnum( xrange) - xrange/2;
   } while( (map[ppos.y][ppos.x].mapchar != SPACE)  ||
            (ppos.y < 1  ||  ppos.y >= MAXROWS)  || /* outside screen */
            (ppos.x < 1  ||  ppos.x >= MAXCOLS));   /* outside screen */
   map[ppos.y][ppos.x].mapchar = '@';
   map[ppos.y][ppos.x].number = 1;
   underchar = SPACE;
   prt_char( map[ppos.y][ppos.x].mapchar, ppos.y, ppos.x);
   change_viewport( ppos.y, ppos.x);
   dely = delx = 0;
   prt_msg("Poof!");
   if ( randnum( 100) > 10) {
     prt_msg("The Orb's power is draining.");
     BACKPACK[check_inven( ORB)].condition--;
   }
 }
 else prt_msg("The spell fails.");
}
else prt_msg("No such spell exists.");
/* smg$paste_virtual_display(&dsp_status,&pb,&2,&43); */
/* smg$label_border(&dsp_inven,&invenlabel); */
}

void fire_item( item) /* fires arrows only right now */
char item;
{
int dx, dy, ax, ay;
int distance = 0;
int bp_num, dr;
int PREWEIGHT;
char spell;

switch( item) {
  case 'a':
  case 'b':
  case 'c':
  case 'd': spell = item;
            item = ORB;
}

if ( (bp_num = check_inven( BOW)) == FALSE  &&  item == ARROW) {
  prt_msg("You don't have the bow.");
  return;
}
else if ( BACKPACK[WIELD].invenchar != BOW && item == ARROW) {
  prt_msg("You are not wielding the bow.");
  return;
}
else if ( (bp_num = check_inven( item)) == FALSE) {
  if ( item == ARROW)
    prt_msg("You don't have any arrows to fire.");
  else
    prt_msg("You don't have the Magic Orb.");
  return;
}

prt_msg("Direction? [^Z abort]");
do {
 dr = 0;
 dr = getkey();
 switch( dr) {
        case KEY_UP:
        case UP: dx = 0; dy = -1; break;
        case KEY_RIGHT:
        case RIGHT: dx = 1; dy = 0; break;
        case KEY_LEFT:
        case LEFT: dx = -1; dy = 0; break;
        case KEY_DOWN:
        case DOWN: dx = 0; dy = 1; break;
        case 26: return; break;
        default: dr = 999;
 } /* End switch */
} while( dr==999 && !dead);
if (dead) return;

if ( item == ARROW) {
  PREWEIGHT = CURWEIGHT;
  CURWEIGHT -= ITEM_PROPS[identify( ARROW)][WEIGHT];
  if ( (PREWEIGHT >= MAXWEIGHT) && (CURWEIGHT < MAXWEIGHT)) {
    change_speed( 2.0);
    prt_msg("The burden of the pack is lifted.");
    prt_speed();
  }
BUSE++;
prt_buse();
prt_wgt();

if ( (--BACKPACK[bp_num].quantity) == 0) {
  BACKPACK[bp_num].invenchar = SPACE;
  compress_inven();
}
} /* End arrow if */

    ax = ppos.x+dx; ay = ppos.y+dy;

    while( ++distance < ARROWDIST) {
      if ( map[ay][ax].mapchar == WALL) {
       if ( item == ORB)
         if ( spell == 'b' || spell == 'c') explode( ay, ax, spell, 1, dr);
       break;
      }
      else if ( isamonster( map[ay][ax].mapchar)) {
          if ( ping_monster( ax, ay, map[ay][ax].number)) return;
          if ( item == ORB) {
            if ( spell == 'b' || spell == 'c') explode( ay, ax, spell, 1, dr);
            else if ( spell == 'a'  ||  spell == 'd')
              do_attack( map[ay][ax].number, 99, spell, dr);
            else do_attack( map[ay][ax].number, 999, ARROW, dr);
          }
          else do_attack( map[ay][ax].number, 999, ARROW, dr); /* arrow */
          break;
      }
      if ( item == ORB  &&  (spell == 'b' || spell == 'c'))
        prt_char('*', ay, ax);
      else {
        if (dr==UP || dr==DOWN) prt_char('|', ay, ax);
        else prt_char('-', ay, ax);
      }
      prt_char( map[ay][ax].mapchar, ay, ax);
      ax = ax + dx; ay = ay + dy;
    } /* End while */

}

void compress_inven() /* takes out "used" or dropped objects */
{
int i;
for ( i=1; i< MAXINVEN-1; i++)
   if ( BACKPACK[i].invenchar == SPACE) {
     strcpy( BACKPACK[i].name, BACKPACK[i+1].name);
     BACKPACK[i].invenchar = BACKPACK[i+1].invenchar;
     BACKPACK[i].quantity = BACKPACK[i+1].quantity;
     BACKPACK[i].condition = BACKPACK[i+1].condition;
     if (i+1 == WIELD) WIELD = i;
     else if (i+1 == WORN) WORN = i;
     else if (i+1 == ALTWEAP) ALTWEAP = i;
     BACKPACK[i+1].invenchar = SPACE;
   }
}

void prt_inven()
{
int i = 1;
int item_num;
char item_to_ident;
char items[80];

/* smg$erase_display(&dsp_inven); */
/* smg$paste_virtual_display(&dsp_inven,&pb,&2,&43); */
wclear(dsp_inven);
wprintw(dsp_inven, "Inventory");
do {
  if ( BACKPACK[i].invenchar != SPACE) {
   item_to_ident = BACKPACK[i].invenchar;
   item_num = identify( item_to_ident);
   if ( i == WORN)
     sprintf(items,"%c) %16s [%d][worn] %3d lb.",i+MAGIC_NUMBER,BACKPACK[i].name,
                  BACKPACK[i].condition,
                  ITEM_PROPS[item_num][WEIGHT]*BACKPACK[i].quantity);
   else if ( i == WIELD)
     sprintf(items,"%c) %13s [%d][wielded] %3d lb.",i+MAGIC_NUMBER,BACKPACK[i].name,
                  BACKPACK[i].condition,
                  ITEM_PROPS[item_num][WEIGHT]*BACKPACK[i].quantity);
   else
     sprintf(items,"%c) %17s [%d] (%d) %4d lb.",i+MAGIC_NUMBER,BACKPACK[i].name,
                  BACKPACK[i].condition,BACKPACK[i].quantity,
                  ITEM_PROPS[item_num][WEIGHT]*BACKPACK[i].quantity);
   prt_in_disp(dsp_inven,items,i,1);
   }
} while( MAXINVEN >i++);
}

void exchange_weap() /* quick-change alternate weapon */
{
int DUMMY, bp_num, item_num;
int wchar;
char wielding[80];

if ( WIELD == 0 && ALTWEAP == 0) /* get an initial weapon */
  wear_wield();
else if ( ALTWEAP == 0) {
  prt_msg("Make which weapon alternate? [* for list]");
  wchar = getkey();
  wchar -= MAGIC_NUMBER;
  if ( wchar+MAGIC_NUMBER == '*') { prt_inven(); exchange_weap(); }
  else if ( wchar < 1  ||  wchar > MAXINVEN-1) {
         prt_msg("Value out of range.");
         return;
  }
  else if ( BACKPACK[wchar].invenchar != SPACE) { /* you have it */
         item_num = identify( BACKPACK[wchar].invenchar);
         if ( ITEM_PROPS[item_num][WEARABLE] == TRUE  &&
              ITEM_PROPS[item_num][ITEMCHAR] != ARMOR) {
           ALTWEAP = wchar;
         sprintf(wielding,"Alternate now %s.",BACKPACK[wchar].name);
         prt_msg(wielding);
         }
         else prt_msg( "You can't wield that!");
  }
  else prt_msg("You have no such object.");
} /* End ALTERNATE initialization */
else {              /* already have an alternate */
  DUMMY = WIELD;    /* need 3 variables to switch two */
  WIELD = ALTWEAP;
  bp_num = WIELD;
  sprintf(wielding,"Now wielding %s.",BACKPACK[bp_num].name);
  prt_msg(wielding);
  ALTWEAP = DUMMY;
}
}

void wear_wield() /* wears armor or wields weapon */
{
int bp_num, item_num;
int wchar;
char wielding[80];

prt_msg("Wear/wield which item? [* for list]");
wchar = getkey();
wchar -= MAGIC_NUMBER;
if ( wchar+MAGIC_NUMBER == '*') { prt_inven(); wear_wield(); }
else if ( wchar < 1  ||  wchar > MAXINVEN-1) {
       prt_msg("Value out of range.");
       return;
}
else if ( BACKPACK[wchar].invenchar != SPACE) { /* you have it */
       item_num = identify( BACKPACK[wchar].invenchar);
       if ( ITEM_PROPS[item_num][WEARABLE] == TRUE) {
         if ( ITEM_PROPS[item_num][ITEMCHAR] == ARMOR) {
           WORN = wchar;
           sprintf(wielding,"Now wearing %s.",BACKPACK[wchar].name);
           prt_msg(wielding);
           prt_inven();
         }
         else {
           WIELD = wchar;
           sprintf(wielding,"Now wielding %s.",BACKPACK[wchar].name);
           prt_msg(wielding);
           prt_inven();
         }
       }
       else prt_msg( "I don't see how you can use that.");
}
else prt_msg("You have no such object.");
}

void drop() /* drop, what else? */
{
int PREWEIGHT, amount;
int dropall = 0;
int dchar;
char drop_msg[80];

if ( underchar != SPACE) {
  prt_msg("There is no room to drop anything here.");
  return;
}
prt_msg("Drop which item? [* for list]");
dchar = getkey();
dchar -= MAGIC_NUMBER;
if ( dchar+MAGIC_NUMBER == '*') { prt_inven(); drop(); }
else if ( dchar < 1  ||  dchar > MAXINVEN-1) {
       prt_msg("Value out of range.");
       return;
}
else if ( BACKPACK[dchar].invenchar != SPACE) { /* you have it */
        underchar = BACKPACK[dchar].invenchar;
        if ( WORN == dchar) WORN = 0;
        else if ( WIELD == dchar) WIELD = 0;
        else if ( ALTWEAP == dchar) ALTWEAP = 0;
        if ( !combinable( identify( underchar))) {
          map[ppos.y][ppos.x].number = BACKPACK[dchar].condition;
          BACKPACK[dchar].invenchar = SPACE;
          sprintf(drop_msg,"Dropped %s.",BACKPACK[dchar].name);
          amount = 1;
        }
        else {
          if ( BACKPACK[dchar].quantity > 1) {
            sprintf(drop_msg,"You have %d %ss.  Drop all [y/n]",
                    BACKPACK[dchar].quantity,object_names[identify(underchar)]);
            prt_msg(drop_msg);
            strcpy(drop_msg,"\0\0\0");
            dropall = getkey();
            if ( dropall == 'y') {
              map[ppos.y][ppos.x].number = BACKPACK[dchar].quantity;
              amount = BACKPACK[dchar].quantity;
              sprintf(drop_msg,"Dropped %d %ss.",amount,BACKPACK[dchar].name);
              BACKPACK[dchar].quantity = 0;
              BACKPACK[dchar].invenchar = SPACE;
            }
            else {
              BACKPACK[dchar].quantity--;
              sprintf(drop_msg,"Dropped %s.",BACKPACK[dchar].name);
              amount = 1;
              map[ppos.y][ppos.x].number = 1;
            }
          }
          else {
            BACKPACK[dchar].quantity = 0;
            BACKPACK[dchar].invenchar = SPACE;
            sprintf(drop_msg,"Dropped %s.",BACKPACK[dchar].name);
            amount = 1;
            map[ppos.y][ppos.x].number = 1;
          }
        }

      PREWEIGHT = CURWEIGHT;
      CURWEIGHT -= ITEM_PROPS[identify( underchar)][WEIGHT] * amount;
      if ( (PREWEIGHT >= MAXWEIGHT) && (CURWEIGHT < MAXWEIGHT)) {
          change_speed( 2.0);
          prt_msg("The burden of the pack is lifted.");
          prt_speed();
        }
        prt_msg(drop_msg);
        prt_wgt();
        compress_inven();
}
else prt_msg("You have no such object.");
}

void drink_potion() /* pretty self-explanitory */
{
int bp_num, item_num, change = TRUE;
int PREWEIGHT, OLDMAXWEIGHT;
int d_chance;
char drink[80];

if ( (bp_num = check_inven( POTION)) != FALSE) {
  item_num = identify( POTION);
  if ( (--BACKPACK[bp_num].quantity) == 0) {
    BACKPACK[bp_num].invenchar = SPACE;
    compress_inven();
  }
  if ( (d_chance = randnum(100)) < 5) {
    if ( flags[SPEED].valid) {
      prt_msg("You feel yourself slow down a bit.");
      if ( speed < 1) /* already SLOW */
        flags[SPEED].moves += 301;
      else
        flags[SPEED].moves = 301 - flags[SPEED].moves;
    }
    else {
      prt_msg("You feel yourself slow down.");
      change_speed( 0.5);
      prt_speed();
      flags[SPEED].valid = TRUE;
      flags[SPEED].moves = 301;
    }
  }
  else if ( d_chance < 10) {
    if ( flags[SPEED].valid) {
      prt_msg("You feel yourself speed up a bit.");
      if ( speed > 1) /* already FAST */
        flags[SPEED].moves += 301;
      else
        flags[SPEED].moves = 301 - flags[SPEED].moves;
    }
    else {
      prt_msg("You feel yourself speed up.");
      change_speed( 2.0);
      prt_speed();
      flags[SPEED].valid = TRUE;
      flags[SPEED].moves = 301;
    }
  }
  else if ( d_chance < 18) {
    prt_msg("You feel your health returning.");
    health += 20;
    prt_health();
  }
  else if ( d_chance < 26) {
    prt_msg("Your arms feel like tree trunks.");
    STR += 1;
    OLDMAXWEIGHT = MAXWEIGHT;
    MAXWEIGHT = (STR*20);
    if ( CURWEIGHT < MAXWEIGHT  &&  CURWEIGHT >= OLDMAXWEIGHT) {
      prt_msg("You feel yourself speed up.");
      change_speed( 2.0);
      prt_speed();
      prt_str();
      change = FALSE;
    }
  }
  else if ( d_chance < 32) {
    prt_msg("You feel healthier.");
    CON += 1;
    MAXHEALTH = ((CON+level)*8);
    prt_con();
  }
  else if ( d_chance < 40) {
    prt_msg("E = mc^2");
    INT += 1;
    prt_int();
  }
  else if ( d_chance < 48) {
    prt_msg("You feel light as a feather.");
    DEX += 1;
    prt_dex();
  }
  else if ( d_chance < 56) {
    prt_msg("An air of confusion surrounds you...");
    prt_msg("Everything seems funny all of a sudden.");
    flags[CONFUSE].valid = TRUE;
    flags[CONFUSE].moves += 301;
  }
  else if ( d_chance < 64) {
    prt_msg("You feel immortal!");
    flags[IMMUNITY].valid = TRUE;
    flags[IMMUNITY].moves += 301;
  }
  else if ( d_chance < 72) {
    prt_msg("Your eyes sting - darkness surrounds you!");
    flags[BLIND].valid = TRUE;
    flags[BLIND].moves += 151;
    /* smg$unpaste_virtual_display(&dsp_main,&pb); */
  }
  else {
    prt_msg("You feel slightly refreshed.");
    health += 5;
    prt_health();
  }
  PREWEIGHT = CURWEIGHT;
  CURWEIGHT -= ITEM_PROPS[item_num][WEIGHT];
  if ( (PREWEIGHT >= MAXWEIGHT) && (CURWEIGHT < MAXWEIGHT)) {
    if ( change) change_speed( 2.0);
    prt_msg("The burden of the pack is lifted.");
    prt_speed();
  }
  prt_wgt();
} /* End check_inven IF */
else prt_msg("You have nothing to drink.");
}

void check_object( testobj, number, direction) /* checks and parses object */
int number;
char testobj, direction;
{
int rnd_num;
char dum_msg[10];

switch( testobj) {

        case PIT:
                  do_move( direction);
                  underchar = PIT;
                  map[ppos.y][ppos.x].number = 1;
                  prt_msg("You fell into a pit!");
                  if ( randnum( 23)+1 > DEX)
                    take_damage( 10, "falling into a pit");
                  else {
                    prt_msg("Your quick reflexes soften the fall.");
                    take_damage( randnum( 10)+1, "falling into a pit");
                  }
                  break;
        case MINE:
                  if ( randnum( 20)+1 > DEX) {
                    if (number < 2) prt_msg("The mine exploded!");
                    else prt_msg("The mines exploded!");
                    explode( ppos.y, ppos.x, MINE, number, NULL);
                    do_move( direction);
                    underchar = SPACE;
                    break;
                  }
                  /* Else continue and pickup below */
        case KEY:
        case HAXE:
        case AXE:
        case SWORD:
        case LSWORD:
        case ARROW:
        case ARMOR:
        case BOW:
        case HEALTH:
        case POTION:
        case ORB:
        case SCROLL:
        case CASH:
                do_pickup( testobj, number, direction);
                break;
        case DOOR:
                do_move( direction);
                underchar = DOOR;
                break;
        case STORE:
                do_move( direction);
                underchar = STORE;
                break;
        case ARENA:
                if ( !can_exit && in_arena) break;
                else if ( can_exit && in_arena) {
                  do_move( direction);
                  underchar = ARENA;
                  do_move( direction); /* push the player through the entrance */
                  prt_msg("You feel the relief of freedom.");
                  map[ppos.y][ppos.x].number = 1;
                  in_arena = FALSE;
                }
                else {
                  do_move( direction);
                  underchar = ARENA;
                  do_move( direction); /* push the player through the entrance */
                  prt_msg("You boldly stride into the arena.");
                  map[ppos.y][ppos.x].number = 1;
                  enter_arena();
                }
                break;
} /* End of switch */
}

int add_inven( object, item_num, number) /* find nearest open slot & add */
int item_num, number;
char object;
{
int spot_num;
int PREWEIGHT;
char posess[80];

if ( (spot_num = check_inven( SPACE)) == FALSE) return( FALSE);
else {
  backpack_struct *bp;
  bp = &BACKPACK[spot_num];

  bp->invenchar = object;
  strcpy( bp->name, object_names[item_num]);
  if ( combinable( item_num)) {
    bp->quantity = number;
    bp->condition = 1;
   if ( number > 1)
    sprintf(posess,"You have %d %ss (%c)",bp->quantity,bp->name,spot_num+MAGIC_NUMBER);
   else
    sprintf(posess,"You have a %s (%c)",bp->name,spot_num+MAGIC_NUMBER);
  }
  else {
    bp->condition = number;
    bp->quantity = 1;
    sprintf(posess,"You have a %s (%c)",bp->name,spot_num+MAGIC_NUMBER);
  }
  prt_msg( posess);
  PREWEIGHT = CURWEIGHT;
  CURWEIGHT += ITEM_PROPS[item_num][WEIGHT] * bp->quantity;
  if ( CURWEIGHT >= MAXWEIGHT  &&  PREWEIGHT < MAXWEIGHT) {
    prt_msg("You are moving at half speed due to the excess weight.");
    change_speed( 0.5);
   }
  return( TRUE);
}
}

void do_pickup( object, number, direction) /* picks up an object you walk over */
int number;
char object, direction;
{
int item_num, bp_num, PREWEIGHT;
int cash_flow;
char cash_pickup[80];
char posess[80];

if ( (item_num = identify( object)) != MAGIC_NUMBER) {
  if ( (bp_num = check_inven( object)) != FALSE && combinable( item_num)) {
       PREWEIGHT = CURWEIGHT;
       CURWEIGHT += ITEM_PROPS[item_num][WEIGHT] * number;
       if ( CURWEIGHT >= MAXWEIGHT  &&  PREWEIGHT < MAXWEIGHT) {
          prt_msg("You slow down from the excess weight.");
          change_speed( 0.5);
          prt_speed();
       }
       BACKPACK[bp_num].quantity += number;
       sprintf(posess,"You have %d %ss.",BACKPACK[bp_num].quantity,
                                    object_names[item_num]);
       prt_msg(posess);
       do_move( direction);
       prt_wgt();
       return;
  }
  else if ( add_inven( object, item_num, number)) {
       prt_speed();
       prt_wgt();
       do_move( direction);
       return;
  }
  else {
    prt_msg("Your backpack is full.");
    do_move( direction);
    underchar = object;
    map[ppos.y][ppos.x].number = number;
    return;
  }
 do_move( direction);
 return;
}
/* End cases, now this has to be "item not found" case */
/* object must be CASH or KEY (or error) */
if ( object == KEY) {
  KEYPOSESS = TRUE;
  prt_key_status();
  prt_msg("You found the key!");
}
else { /* must be CASH */
  wealth += (cash_flow = randnum( 50));
  sprintf(cash_pickup,"You pick up %d gold pieces.",cash_flow);
  prt_msg(cash_pickup);
  prt_wealth();
}
do_move( direction);
}

void enter_arena()
{
char rival[80];

monsters_struct *m;
rival_num = randnum( 2*level) + 3;
m = &monsters[rival_num];
sprintf( rival,"Your rival in a battle to the death is: %s.",mon_names[m->n_num]);
prt_msg( rival);
m->posy = a_posy;
m->posx = a_posx;
m->dead = FALSE;
m->health = 3*(monsters[rival_num].n_num+5);
map[m->posy][m->posx].mapchar = m->mon_char;
map[m->posy][m->posx].number = m->number;
prt_char( m->mon_char, a_posy, a_posx);
in_arena = TRUE;
can_exit = FALSE;
}

void display_store_inven()
{
int i;
char item_to_buy[40];
/* $DESCRIPTOR(store_label,"Store Inventory"); */

/* smg$change_virtual_display(&dsp_status,&21,&37); */
/* smg$erase_display(&dsp_status); */
/* smg$label_border(&dsp_status,&store_label); /1* use the stat disp. for store *1/ */
/* smg$paste_virtual_display(&dsp_status,&pb,&2,&43); */
wclear(dsp_status);
wprintw(dsp_status, "Store Inventory");
wrefresh(dsp_status);
for (i=1; i< MAXOBJECTS-NUMITEMS; i++) {
   sprintf(item_to_buy,"%c) %17s %4d gp %4d lb.",i+MAGIC_NUMBER,object_names[i],
                                    ITEM_PROPS[i][COST],ITEM_PROPS[i][WEIGHT]);
   prt_in_disp(dsp_status,item_to_buy,i,1);
}
}

short get_purchase()
{
int bp_num, quality;
int PREWEIGHT;
int c;
char gold_amount[80];
char purchased[80];
/* $DESCRIPTOR(statlabel,"Character Stats"); */

prt_msg("[s]ell/[p]urchase/[e]xit");
c = getch();
if ( c != 'e' && c != 's' && c != 'p')
  if ( get_purchase()) return (FALSE);
if ( c == 'e') {
  /* smg$erase_display(&dsp_status); */
  /* smg$change_virtual_display(&dsp_status,&10,&37); */
  wclear(dsp_status);
  prt_status();
  /* smg$label_border(&dsp_status,&statlabel); */
  /* smg$paste_virtual_display(&dsp_status,&pb,&2,&43); */
  return( TRUE);  /* means that you are leaving the store */
}
if ( c == 's') {
  sell_item();
  sprintf(gold_amount,"You have %d gold remaining.",wealth);
  prt_msg(gold_amount);
  if ( get_purchase()) return (FALSE);
}
if ( c == 'p') {
 sprintf(gold_amount,"You have %d gold remaining.",wealth);
 prt_msg(gold_amount);
 prt_msg("Purchase which item?");
 c = getch();
 if ( (c -= MAGIC_NUMBER) < 1  ||  (c > 12)) { /* 12 items excluding HANDS */
   prt_msg("Value out of range.");
   if ( get_purchase()) return (FALSE);
 }
}
if ( (wealth - ITEM_PROPS[c][COST]) < 0) {
  prt_msg("You don't have the cash flow for this.");
  if ( get_purchase()) return (FALSE);
}
if ( (bp_num = check_inven( ITEM_PROPS[c][ITEMCHAR])) != FALSE  &&
      combinable( c)) {
  wealth -= ITEM_PROPS[c][COST];
  PREWEIGHT = CURWEIGHT;
  CURWEIGHT += ITEM_PROPS[c][WEIGHT];
  if ( CURWEIGHT >= MAXWEIGHT  &&  PREWEIGHT < MAXWEIGHT) {
     prt_msg("You are moving very slowly due to the excess weight.");
     change_speed( 0.5);
   }
  BACKPACK[bp_num].quantity++; /* add one to it */
  sprintf(purchased,"You have %d %ss.",BACKPACK[bp_num].quantity,
                                       object_names[c]);
  prt_msg(purchased);
  sprintf(gold_amount,"You have %d gold remaining.",wealth);
  prt_msg(gold_amount);
}
/* new things bought are in perfect condition */
else {
  if ( combinable( c)) quality = 1;
  else quality = 5;
  if ( add_inven( ITEM_PROPS[c][ITEMCHAR], c, quality)) {
    wealth -= ITEM_PROPS[c][COST];
    sprintf(purchased,"%s purchased for %d cash.",object_names[c],
                                                ITEM_PROPS[c][COST]);
    prt_msg(purchased);
    sprintf(gold_amount,"You have %d gold remaining.",wealth);
    prt_msg(gold_amount);
  }
  else prt_msg("You have no room in your backpack for this.");
}

if ( get_purchase()) return (FALSE); /* endless loop until ^Z is hit (TRUE) */
return (-1);
}

void enter_store()
{
display_store_inven();
get_purchase();
}

void sell_item()
{
int PREWEIGHT, delwealth, quan;
int flag = 0;
char dummychar;
int schar;
int sellall = 0;
char sell_msg[80];

while( 1) {
schar = 0;
prt_msg("Sell which item? [* for inventory]");
schar = getch();
schar -= MAGIC_NUMBER;
if ( schar+MAGIC_NUMBER == '*') { prt_inven(); flag = 1; }
else break;
}
if ( schar < 1  ||  schar > MAXINVEN-1) prt_msg("Value out of range.");
else if ( (dummychar = BACKPACK[schar].invenchar) != SPACE) {
        if ( WORN == schar) WORN = 0;
        else if ( WIELD == schar) WIELD = 0;
        else if ( ALTWEAP == schar) ALTWEAP = 0;
        if ( !combinable( identify( dummychar))) {
          BACKPACK[schar].quantity = 0;
          BACKPACK[schar].invenchar = SPACE;
          sprintf(sell_msg,"Sold %s.",BACKPACK[schar].name);
          quan = 1;
        }
        else {
          if ( BACKPACK[schar].quantity > 1) {
            sprintf(sell_msg,"You have %d %ss.  Sell all?",
                BACKPACK[schar].quantity, object_names[identify(dummychar)]);
            prt_msg(sell_msg);
            sellall = getch();
            if ( sellall == 'y') {
              quan = BACKPACK[schar].quantity;
              sprintf(sell_msg,"Sold %d %ss.",quan,BACKPACK[schar].name);
              BACKPACK[schar].quantity = 0;
              BACKPACK[schar].invenchar = SPACE;
            }
            else {
              BACKPACK[schar].quantity--;
              sprintf(sell_msg,"Sold %s.",BACKPACK[schar].name);
              quan = 1;
            }
          }
          else {
            BACKPACK[schar].quantity = 0;
            BACKPACK[schar].invenchar = SPACE;
            sprintf(sell_msg,"Sold %s.",BACKPACK[schar].name);
            quan = 1;
          }
        }

      PREWEIGHT = CURWEIGHT;
      CURWEIGHT -= ITEM_PROPS[identify( dummychar)][WEIGHT] * quan;
      if ( (PREWEIGHT >= MAXWEIGHT) && (CURWEIGHT < MAXWEIGHT)) {
          change_speed( 2.0);
          prt_msg("The burden of the pack is lifted.");
        }
        if ( !combinable( identify( dummychar)))
          wealth += (delwealth = ITEM_PROPS[identify( dummychar)][COST] -
                    (5 - BACKPACK[schar].condition) * 10);
        else
          wealth += (delwealth = ITEM_PROPS[identify( dummychar)][COST]*quan);

        prt_msg(sell_msg);
        compress_inven();
}
else prt_msg("You have no such object.");
if (flag) display_store_inven();
}

void take_damage( damage, killer) /* ouch */
int damage;
char *killer;
{
double extra;
char owk[80];
char mess[80];

if ( operator) return; /* no damage taken */
if ( flags[IMMUNITY].valid) {
  sprintf(mess,"%s's blow deflects harmlessly away!",killer);
  prt_msg(mess);
  return;
}
if ( WORN)
  health -=
       (damage - damage/ITEM_PROPS[identify( BACKPACK[WORN].invenchar)][DAMAGE]
        + (5 - BACKPACK[WORN].condition));
else health -= damage;
extra = damage * 0.80;  /* 20% chance that your armor worsens */
if ( randnum( damage) > extra)
  if ( WORN) {
    prt_msg("Your armor's condition is worsening.");
    BACKPACK[WORN].condition -= 1;
  }
prt_health();
if ( health < 0) {
  sprintf(owk," *** You have died  -  killed by %s ***",killer);
  prt_msg(owk);
  dead = TRUE;
 }
}

void do_move( direction)
char direction;
{
int dx, dy;

switch( direction) {
        case UP:
              dely--;
              dx = 0; dy = 1; break;
        case DOWN:
              dely++;
              dx = 0; dy = -1; break;
        case LEFT:
              delx--;
              dx = 1; dy = 0; break;
        case RIGHT:
              delx++;
              dx = -1; dy = 0;
} /* End switch */
ppos.x -= dx;
ppos.y -= dy;
if ( abs(dely) >= SCRATIOV || abs(delx) >= SCRATIOH) {
 change_viewport(ppos.y, ppos.x);
 dely = 0;
 delx = 0;
}
map[ppos.y][ppos.x].mapchar = '@';
map[ppos.y+dy][ppos.x+dx].mapchar = underchar;
prt_char( map[ppos.y+dy][ppos.x+dx].mapchar, ppos.y+dy, ppos.x+dx);
prt_char( map[ppos.y][ppos.x].mapchar, ppos.y, ppos.x);
underchar = SPACE; /* to reset the underchar, since you moved */
}
