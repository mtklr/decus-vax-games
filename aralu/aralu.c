#include stdio
#include smgdef
#include descrip
#include jpidef
#include ctype
#include math
#include time
#include "aralu.h"
#include "random.c"


cursor_on()
{
printf("\33[?25h");
}

cursor_off()
{
printf("\33[?25l");
}

enable_control()
{
int mask = 0x02000000;
lib$enable_ctrl(&mask);
}

disable_control()
{
int mask = 0x02000000;
lib$disable_ctrl(&mask);
}

/*
clear_buffer()
{
$DESCRIPTOR(command_d,"set terminal/notypeahead");

smg$execute_command(&dsp_command,&command_d,&SMG$M_DATA_FOLLOWS);
}
*/


create( obj, quan)
short quan;
char obj;
{
short i = 0;
short y, x;

while( i< quan) { 				
  y = random(MAXROWS);
  x = random(MAXCOLS);
  if ( ISCLEAR( map[y][x].mapchar)) { 
     map[y][x].mapchar = obj; 
     if ( ITEM_PROPS[identify( obj)][COMBINE]) map[y][x].number = 1;
     else map[y][x].number = random( 5) + 1;
     lib$wait(&0.008);		/* to give the random a better effect */
     prt_char( map[y][x].mapchar, y, x);
     i++; 
  }
}
}

create_objects()
{
int obj_num;
/* for the creation, make a few extras, since monsters eat them */
create( HEALTH, MAXMONSTERS*level);
create( SWORD, 2);
create( LSWORD, 2);
create( DOOR, 2);
create( STORE, 2);
create( POTION, 2);
create( CASH, random(5));
create( MINE, random(8));
create( PIT, random(8));
create( SCROLL, random(5));
if ( (obj_num = random( 6)) == 1) create( POTION, 1);
else if ( obj_num==2) { create( SCROLL, 4); create( HAXE, 1); }
else if ( obj_num==3) { create( AXE, 1); create( ARMOR, 1); }
else if ( obj_num==4) { create( BOW, 1); create( ARROW, 10); }
else if ( obj_num==5) { create( ARMOR, 1); create( LSWORD, 1); }
else create( SPACE, 1);		/* should never happen */
}

sub_holdmap()
{
int i = 0;

while( holdmap[i].num != -5) {
  map[holdmap[i].y][holdmap[i].x].number = holdmap[i].num;
  map[holdmap[i].y][holdmap[i].x].mapchar = holdmap[i].holdchar;
  if ( holdmap[i].holdchar == '@') { 
    ppos.y = holdmap[i].y; 
    ppos.x = holdmap[i].x; 
    holdmap[i].holdchar = '@';
  }
  i++;
}
}


short readscreen()
{
FILE *readfile;

char screenfile[80];
short ret = 0;
short i, j;

sprintf(screenfile,"%sscreen.%d",screenpath,level);
if ( (readfile = fopen( screenfile,"r")) != NULL) {
 for (i=0; i< MAXROWS; i++) {
     fgets (maparray[i], MAXCOLS+5, readfile);
     maparray[i][MAXCOLS] = '\0';
  }

 for (i=0; i< MAXROWS; i++)  
    for (j=0; j< MAXCOLS; j++) {
        map[i][j].mapchar = maparray[i][j];
        map[i][j].number = 9999;
        if ( map[i][j].mapchar == '@') { ppos.y = i;  ppos.x = j; 
  	  map[i][j].mapchar = SPACE; maparray[i][j] = SPACE;}
	else if ( map[i][j].mapchar == BONES) { a_posy = i; a_posx = j; }
    }

 underchar = SPACE; 	         	/* starting out new screen */
/* can't print out the monsters with the rest of the map, since the character
   you see on the screen is not the same as the encoded character of the
   monster, so we have to do it in write_map() */
if ( access( savefile, "r") != 0  &&  level == 1)
  if ( (ret = read_monsters())) errmess( ret);

} /* End file-open IF */
else ret = E_OPENSCREEN;
fclose( readfile);
return( ret);
}


prt_sub_holdmap()
{
int i = 0;

while( holdmap[i].num != -5) {
  prt_char( holdmap[i].holdchar, holdmap[i].y, holdmap[i].x);
  i++;
 } /* End while */
}


write_map()
{
int count;
$DESCRIPTOR( map_desc, maparray);

map_desc.dsc$w_length = MAXCOLS;
  for (count=1;count<=MAXROWS;count++) { 
      map_desc.dsc$a_pointer = &maparray[count-1][0];
      smg$put_line(&dsp_main,&map_desc,0,0,0,0); 
  }

prt_monsters();
}



short getkey()
{
int key, send;
double denom;


while( !dead) {
send = FALSE;
if ( smg$read_keystroke(&kboard,&key,0,&timeout) != 556) {
   send = TRUE;
   timeout_count--;
}
if ( !in_arena) {	/* can't heal while waiting in arena */  
  if ( CON == 20) denom = 1;
  else {
    if ( (denom = 20-CON) < 0) denom = 1 + 1/(CON-20);
    else denom++;
  }
  if ( (++timeout_count*DIFFICULTY)/denom >=1) { 
    if ( health < MAXHEALTH) {
      health += 1; 
      prt_health(); 
    }
    timeout_count = 0; 
  }
} /* End ARENA If */

do_acts();

if ( send && !dead) return( key);
} /* End while */
}


do_acts()
{
int monspeed, i, j, k;
int limit;

lib$wait(&DIFFICULTY);
moves++;
if ( (moves % 500) == 0) get_time();
for ( j = 0; j < NUMFLAGS; j++)
  if ( flags[j].valid) {
    if ( flags[j].moves > 0) {    
      flags[j].moves--;
      if ( operator) prt_moves( j);
    }
    else {
      if ( j == SPEED) check_speed();
      else if ( j == CONFUSE) check_confusion();     
      else if ( j == IMMUNITY) check_immunity();
      else if ( j == MON_CONFUSE) check_mon_confuse();
      else if ( j == BLIND) check_blind();
    }
  }

j = 0;
k = 0;
while( j++ < MAXMONSTERS*level) {
 limit = monsters[k].max_mon;
 for ( i=0; i< limit; i++) {
    if ( !monsters[k].dead) {
      if ( (monspeed = monsters[k].speed) < 1) monspeed = 1;
      if ( moves % monspeed == 0) 
        if ( !stop_monst)		/* God flag for stopping monsters */
          move_monsters( k);
    }
    else if ( random( 100) < monsters[k].reschance) resurrect( k);
    k++;
  } /* End FOR(i) loop */
} /* End while */
}


short gameloop()
{
int key, d = 0;
short ret = 0;

timeout_count = moves = 0;
while( !dead) {
  key = getkey();
  if ( !dead)
    if ( (ret = parse_keystroke( key)) != 0) break;
}
if ( dead) {
  prt_msg("Press RETURN to continue.");
  do {
    smg$read_keystroke(&kboard,&d);
  }while( d != 13);
  prt_msg("Your backpack contained:");
  prt_inven();
  prt_msg("Press RETURN to continue.");
  do {
    smg$read_keystroke(&kboard,&d);
  }while( d != 13);
}
if (ret == E_SAVED) ret = savegame();
return( ret);
}


errmess( number)
int number;
{
delete_windows();
if ( number != E_ENDGAME)
  printf("Aralu: %s\n",errors[number]);
cursor_on();
enable_control();
printf("Thank you for trying aralu.");
exit( 0);
}


main( argc, argv)
int argc;
char *argv[];
{
short i, j;
short ret, restored;
char op_username[12];
char sk[10];

				/* initialize BACKPACK struct for spaces */
for (i=1; i< MAXINVEN; i++)
   BACKPACK[i].invenchar = SPACE;
				/* initialize FLAGS to nothing */
for (i=0; i< NUMFLAGS; i++)
   flags[i].valid = flags[i].moves = 0;
   
GAINLEVEL = KEYPOSESS = operator = dead = stop_monst = 
			in_store = in_arena = can_exit = ret = restored = FALSE;
level = 1;
randomize(); 			/* to get the ball rolling for random numbers */

strcpy( username, getenv("USER"));
if ( argc > 1) {
  if ( argv[1][0] != '-') ret = E_USAGE;
  else switch( toupper( argv[1][1])) {
     	 case 'C':
    		if ( strcmp( username, SUPERUSER) != 0) errmess(  E_NOTSUPER); 
	    	printf("Are you sure you want to create another highscore file?\n");
    		scanf( "%s", sk);
    		if ( toupper( sk[0]) == 'Y') {
      		  if ( (ret = create_scorefile()) == 0) ret = E_CREATED;
    		}
    		else ret = E_ENDGAME;
		break;
	 case 'S': if ( (ret = outputscore()) == 0) ret = E_ENDGAME; break;
	 case 'M': 
		if ( strcmp( username, SUPERUSER) != 0) errmess(  E_NOTSUPER); 
		printf("Enter username:\n");
		scanf( "%s", op_username);
		op_username[9] = 0;
		strcpy( username, op_username);
		break;
         default: ret = E_USAGE;
  } /* End switch */
if ( ret) errmess( ret);
}

if ( (ret = restore()) == 0) restored = TRUE;
else if ( ret != E_NOSAVEFILE) errmess( ret);
else if ( (ret = create_character()) != 0) errmess( ret);

if ( (ret = readscreen()) != 0) errmess( ret);
if (restored) sub_holdmap();

/* game has been restored or re-started */
disable_control();
cursor_off();
/*clear_buffer();*/
create_windows();
change_viewport( ppos.y, ppos.x);
map[ppos.y][ppos.x].mapchar = '@';
maparray[ppos.y][ppos.x] = '@';
write_map();
if ( restored) prt_sub_holdmap();
else create_objects();

prt_status();
get_time();
put_windows();

remove( savefile); 		/* delete savefile so people can't cheat */
while(!dead) {
if ( (ret = gameloop()) == E_GAINLEVEL) {
  prt_msg("Congratulations!  You made it through this level");
  experience = experience + level*BONUS;
  level++;
  MAXHEALTH = ((CON+level)*8);
  if ( (ret = readscreen()) != 0) errmess( ret);
  smg$begin_pasteboard_update(&pb);
  smg$erase_display(&dsp_main); 	/* clear original map */
  change_viewport( ppos.y, ppos.x);	/* restarts the viewport */
  map[ppos.y][ppos.x].mapchar = '@';
  maparray[ppos.y][ppos.x] = '@';
  write_map();				/* print out new map */
  create_objects();
  smg$end_pasteboard_update(&pb);
/*  if ( !flags[SPEED].valid && CURWEIGHT < MAXWEIGHT) speed = 1; */
  KEYPOSESS = GAINLEVEL = FALSE;
  monkilled = dely = delx = 0;
  prt_exp();
  prt_level();
  prt_key_status();
}
else break;
}

delete_windows(); 
if ( dead && !operator) ret = score();

if ( ret) errmess( ret);
else { 
  delete_windows(); 
  cursor_on();
  enable_control();
  printf("Thank you for trying aralu.");
  exit( 0);
}
}
