#include <sys/stat.h>
#include "aralu.h"

static struct stat sfstat;
static int i, j, k;

short savegame()
{
FILE *outfile;
short ret = 0;

if ( (outfile = fopen( savefile,"w")) != NULL) {
  /* write out information in the same way it was read in */
  /* create struct so people can't edit savefile */
  strcpy( player.username,username);
  player.underchar = underchar;
  player.level = level;
  player.health = health;
  player.speed = speed;
  player.operator = operator;
  player.experience = experience;
  player.wealth = wealth;
  player.kills = kills;
  player.monkilled = monkilled;
  player.STR = STR;
  player.INT = INT;
  player.DEX = DEX;
  player.CON = CON;
  player.BUSE = BUSE;
  player.delx = delx;
  player.dely = dely;
  player.MAXHEALTH = MAXHEALTH;
  player.MAXWEIGHT = MAXWEIGHT;
  player.CURWEIGHT = CURWEIGHT;
  player.WIELD = WIELD;
  player.WORN = WORN;
  player.ALTWEAP = ALTWEAP;
  player.KEYPOSESS = KEYPOSESS;
  player.DIFFICULTY = DIFFICULTY;
/*
 for (i=0; i< MAXROWS; i++)
    for (j=0; j< MAXCOLS; j++)
        maparray[i][j] = map[i][j].mapchar;
*/
nocbreak();
k = 0;
 for (i=0; i< MAXROWS; i++)
    for (j=0; j< MAXCOLS; j++)
        if ( map[i][j].mapchar != WALL && map[i][j].mapchar != SPACE &&
             !isamonster( map[i][j].mapchar) && map[i][j].mapchar != WATER &&
             map[i][j].mapchar != BRIDGE && map[i][j].mapchar != BRIDGE2) {
          holdmap[k].holdchar = map[i][j].mapchar;
          holdmap[k].num = map[i][j].number;
          holdmap[k].x = j;
          holdmap[k].y = i;
          k++;
        }
 holdmap[k].num = -5;

  if ( fwrite( &player, sizeof(player), 1, outfile) != NULL) {
    if ( fwrite( &ppos, sizeof(ppos), 1, outfile) != NULL)
      if ( fwrite( &monsters, sizeof(monsters), 1, outfile) != NULL)
        if ( fwrite( &BACKPACK, sizeof(BACKPACK), 1, outfile) != NULL)
/*        if ( fwrite( &(maparray[0][0]), sizeof(maparray), 1, outfile) != NULL)
            if ( fwrite( &map, sizeof(map), 1, outfile) != NULL)
*/
            if ( fwrite( &holdmap, sizeof(holdmap), 1, outfile) != NULL)
              if ( fwrite( &flags, sizeof(flags), 1, outfile) != NULL)
              ret = E_SAVED;
  }
  else ret = E_WRITESAVE;
 }
else ret = E_OPENSAVE;
fclose ( outfile);
if ( stat( savefile, &sfstat) != 0) ret = E_WRITESAVE;
else if ( (outfile = fopen( savefile, "a")) == NULL) ret = E_OPENSAVE;
else {
   if ( fwrite( &sfstat, sizeof( sfstat), 1, outfile) == NULL) ret = E_WRITESAVE;
   fclose( outfile);
}
return ( ret);
}

short restore()
{
FILE *infile;
short ret = 0;
struct stat oldsfstat;

if ( stat( savefile, &oldsfstat) != 0) ret = E_NOSAVEFILE;
else {
printf("\33[24;1HRestoring game...\n");
if ( (infile = fopen( savefile,"r")) != NULL) {
  if ( fread( &player, sizeof(player), 1, infile) != NULL) {
    if ( fread( &ppos, sizeof(ppos), 1, infile) != NULL)
      if ( fread( &monsters, sizeof(monsters), 1, infile) != NULL)
        if ( fread( &BACKPACK, sizeof(BACKPACK), 1, infile) != NULL)
/*        if ( fread( &(maparray[0][0]), sizeof(maparray), 1, infile) != NULL)
            if ( fread( &map, sizeof(map), 1, infile) != NULL)
*/
            if ( fread( &holdmap, sizeof(holdmap), 1, infile) != NULL)
              if ( fread( &flags, sizeof(flags), 1, infile) != NULL)
         if ( fread( &sfstat, sizeof(sfstat), 1, infile) != NULL) {
             if ( (strcmp( username, SUPERUSER) != 0) &&
                ( (strcmp( username, player.username) != 0) ||
                  (sfstat.st_dev != oldsfstat.st_dev) ||
                  (sfstat.st_mode != oldsfstat.st_mode) ||
                  (sfstat.st_uid != oldsfstat.st_uid) ||
                  (sfstat.st_gid != oldsfstat.st_gid) ||
/* for some reason, there is a slight delay in saving, so the time is off */
/* by a decimal value.. no problem, just check to see if it's close */
                  (oldsfstat.st_mtime - sfstat.st_mtime > 2)))
            ret = E_DATACORRUPT;
         else {
/* in case the operator is restoring someone else's game */
          if ( strcmp( username, SUPERUSER) == 0  &&
               strcmp( username, player.username) != 0) operator = TRUE;
          else operator =  player.operator;
          strcpy( username, player.username);
          underchar = player.underchar;
          level =     player.level;
          health =    player.health;
          speed =     player.speed;
          experience= player.experience;
          wealth =    player.wealth;
          monkilled = player.monkilled;
          kills =     player.kills;
          STR =       player.STR;
          INT =       player.INT;
          DEX =       player.DEX;
          CON =       player.CON;
          BUSE =      player.BUSE;
          delx =      player.delx;
          dely =      player.dely;
          MAXHEALTH = player.MAXHEALTH;
          MAXWEIGHT = player.MAXWEIGHT;
          CURWEIGHT = player.CURWEIGHT;
          WIELD =     player.WIELD;
          WORN =      player.WORN;
          ALTWEAP =   player.ALTWEAP;
          KEYPOSESS = player.KEYPOSESS;
          DIFFICULTY = player.DIFFICULTY;
/*
 for (i=0; i< MAXROWS; i++)
    for (j=0; j< MAXCOLS; j++)
        maparray[i][j] = map[i][j].mapchar;
*/
          ret = 0;
          fclose ( infile);
          }
        }
  }
  else ret = E_READSAVE;
 }
else ret = E_OPENSAVE;
fclose ( infile);
}
return ( ret);
}
