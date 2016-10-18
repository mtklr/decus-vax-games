#include "aralu.h"

int obstacle( testchar)
char testchar;
{
switch( testchar) {
        case SPACE:
        case BRIDGE:
        case BRIDGE2:
                return( FALSE);
                break;
        default: return( TRUE);
}
}

short isamonster( testchar)
char testchar;
{
if ( (testchar >= 'A' && testchar <= 'Z') ||
     (testchar >= 'a' && testchar <= 'z')) return( TRUE);
else return( FALSE);
}

short combinable( number)
int number;
{
return( ITEM_PROPS[number][COMBINE]);
}

void get_time()
{
int i;
time_t time_val;
char time_msg[80];
char *hour[2] = {"AM","PM"};
struct tm *time_structure;

time(&time_val);
time_structure = localtime(&time_val);

 if(time_structure->tm_hour > 12)
   {
     time_structure->tm_hour = (time_structure->tm_hour) - 12;
     i = 1;
   }
  else i = 0;

sprintf(time_msg,"Time:   %2d:%02d %s",time_structure->tm_hour,
                                                time_structure->tm_min,hour[i]);
prt_in_disp(dsp_status,time_msg,10,20);
}

/* Note:  since grab_num is only used with the wizard commands, there is no
          need to run through the do_acts() procedure during number read */
short grab_num( prompt)
char *prompt;
{
char num[11];
echo();
curs_set(1);
wprintw(dsp_command, "%s", prompt);
wgetstr(dsp_command, num);
curs_set(0);
noecho();
return( atoi( num));
}

void change_speed( number)
double number;
{
int i, j, k;
int limit;

speed *= number;

j = 0;
k = 0;
while( j++ < MAXMONSTERS*level) {
  limit = monsters[k].max_mon;
  for( i=0; i< limit; i++) {
    if ( number < 1) monsters[k].speed -= 1;
    else monsters[k].speed += 1;
    k++;
  } /* End FOR loop */
} /* End while */
}

void check_speed()
{

if ( speed > 1) {
  prt_msg("The effect of the potion wears off.");
  prt_msg("You feel yourself slow down.");
  change_speed( 0.5);
  prt_speed();
 }
else if ( speed < 1) {
  prt_msg("The effect of the potion wears off.");
  prt_msg("You feel yourself speed up.");
  change_speed( 2.0);
  prt_speed();
 }
else if ( speed == 1 && CURWEIGHT >= MAXWEIGHT) {
  prt_msg("The effect of the potion wears off.");
  prt_msg("You feel yourself slow down.");
  change_speed( 0.5);
  prt_speed();
 }
flags[SPEED].valid = FALSE;
flags[SPEED].moves = 0;
}

void check_confusion()
{
prt_msg("The confusion wears off.");
flags[CONFUSE].valid = FALSE;
flags[CONFUSE].moves = 0;
}

void check_immunity()
{
prt_msg("You no longer feel invulnerable.");
flags[IMMUNITY].valid = FALSE;
flags[IMMUNITY].moves = 0;
}

void check_mon_confuse()
{
flags[MON_CONFUSE].valid = FALSE;
flags[MON_CONFUSE].moves = 0;
}

void check_blind()
{
prt_msg("Your vision clears...");
/* smg$paste_virtual_display(&dsp_main,&pb,&2,&2); */
flags[BLIND].valid = FALSE;
flags[BLIND].moves = 0;
}

int get_name( obj_to_ident) /* gets name of object only */
char obj_to_ident;
{
int i = 0;

do {
  if ( ITEM_PROPS[i][ITEMCHAR] == obj_to_ident) { return( i); break; }
}while( MAXOBJECTS> i++);   /* note: this includes all objects */
return( MAGIC_NUMBER);      /* no such object - error in screen file */
}

void prt_status() /* Print out the stats */
{
wclear(dsp_status);
wprintw(dsp_status, "Character Stats");
wrefresh(dsp_status);
prt_username( username);
prt_level();
prt_exp();
prt_health();
prt_wealth();
prt_speed();
prt_kills();
prt_key_status();
get_time();
prt_str();
prt_int();
prt_dex();
prt_con();
prt_buse();
prt_wgt();
}

/* Note:  It's impossible right now to get to "Forget it" speed, since the
          flag for SPEED is just on/off.  If it were made such that a specific
          number of times the slow/fast potion was drank, they could be
          accounted for in the check_speed() routine.  Right now, though, I
          just have the slow/fast flag set for on/off with a number of moves
          dependent on the number of potions drank.
*/
void prt_speed()
{
char speed_msg[80];
char cur_speed[10];

if ( speed==1) strcpy( cur_speed,"   Normal");
else if ( speed<1) {
   if ( speed == .5) strcpy( cur_speed,"     Slow");
   else if ( speed == .25) strcpy( cur_speed,"Very Slow");
   else if ( speed <= .125) strcpy( cur_speed,"Forget it");
}
else if ( speed>1) strcpy( cur_speed,"     Fast");
sprintf(speed_msg,"Speed: %s", cur_speed);
prt_in_disp(dsp_status,speed_msg,3,20);
}

void prt_exp()
{
char exp_msg[80];

sprintf(exp_msg,"Exp: %11d",experience);
prt_in_disp( dsp_status, exp_msg, 2, 20);
}

void prt_wealth()
{
char wealth_msg[80];

sprintf(wealth_msg,"Cash flow: %6d",wealth);
prt_in_disp(dsp_status,wealth_msg,3,1);
}

void prt_username( username)
char *username;
{
char user_name[20];

sprintf(user_name,"Player: %9s",username);
prt_in_disp( dsp_status, user_name, 1, 1);
}

void prt_level()
{
char level_msg[80];

sprintf(level_msg,"Level: %9d",level);
prt_in_disp( dsp_status, level_msg, 1, 20);
}

void prt_health()
{
char health_msg[80];

sprintf(health_msg,"Health: %9d",health);
prt_in_disp(dsp_status,health_msg,2,1);
}

void prt_kills()
{
char kill_msg[80];

sprintf(kill_msg,"Kills: %10d",kills);
prt_in_disp(dsp_status,kill_msg,4,1);
}

void prt_key_status()
{

if ( KEYPOSESS)
  prt_in_disp(dsp_status,"Key status:  Yes",4,20);
else
  prt_in_disp(dsp_status,"Key status:   No",4,20);
}

void prt_moves( num)
int num;
{
char n_moves[10];

sprintf(n_moves,"Moves: %9d",flags[num].moves);
prt_in_disp(dsp_status,n_moves,5,20);
}

void prt_str()
{
char str_msg[80];

sprintf(str_msg,"Str: %5d",STR);
prt_in_disp(dsp_status,str_msg,5,1);
}

void prt_int()
{
char int_msg[80];

sprintf(int_msg,"Int: %5d",INT);
prt_in_disp(dsp_status,int_msg,6,1);
}

void prt_dex()
{
char dex_msg[80];

sprintf(dex_msg,"Dex: %5d",DEX);
prt_in_disp(dsp_status,dex_msg,7,1);
}

void prt_con()
{
char con_msg[80];

sprintf(con_msg,"Con: %5d",CON);
prt_in_disp(dsp_status,con_msg,8,1);
}

void prt_buse()
{
char buse_msg[80];

sprintf(buse_msg,"Bow: %5d",BUSE);
prt_in_disp(dsp_status,buse_msg,9,1);
}

void prt_wgt()
{
char wgt_msg[80];

sprintf(wgt_msg,"Wgt: %4d/%4d",CURWEIGHT,MAXWEIGHT);
prt_in_disp(dsp_status,wgt_msg,10,1);
}

/* End stats section */

int check_inven( otc) /* returns position in inventory */
char otc;
{
int i;

for (i=1; i< MAXINVEN; i++)
   if ( BACKPACK[i].invenchar == otc) return( i);
/* Else if you don't have it, return false */
return( FALSE);
}

int identify( obj_to_ident) /* Identifies item properties by finding # */
char obj_to_ident;
{
int i = 0;

do {
  if ( ITEM_PROPS[i][ITEMCHAR] == obj_to_ident) { return( i); break; }
}while( (MAXOBJECTS-NUMITEMS)> ++i);
return( MAGIC_NUMBER);
}

void break_weapon( bp_num)
int bp_num;
{
int PREWEIGHT;

PREWEIGHT = CURWEIGHT;
CURWEIGHT -= ITEM_PROPS[identify( BACKPACK[bp_num].invenchar)][WEIGHT];
if ( (PREWEIGHT >= MAXWEIGHT) && (CURWEIGHT < MAXWEIGHT)) {
  change_speed( 2.0);
  prt_msg("The burden of the pack is lifted.");
  prt_speed();
}
WIELD = 0;
BACKPACK[bp_num].invenchar = SPACE;
prt_wgt();
compress_inven();
}

short ping_monster( x, y, mon_num)              /* ping the ghosted monster */
int x, y, mon_num;
{
monsters_struct *mon_ptr;
mon_ptr = &monsters[mon_num];

if ( map[y][x].number == 9999) return FALSE;
if ( mon_ptr->dead ||
     ( mon_ptr->posy != y  ||  mon_ptr->posx != x)) {
  map[y][x].mapchar = SPACE;
  map[y][x].number = 1;
  prt_char(map[y][x].mapchar,y,x);
  prt_msg("The ghost shimmers and disappears.");
  return( TRUE);
}
else return( FALSE);
}
