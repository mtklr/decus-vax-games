/* source/player.c: player specific variable definitions

   Copyright (c) 1989-92 James E. Wilson, Robert A. Koeneke

   This software may be copied and distributed for educational, research, and
   not for profit purposes provided that this copyright and statement are
   included in all such copies. */

#include "config.h"
#include "constant.h"
#include "types.h"

/* Player record for most player related info */
player_type py;
/* player location in dungeon */
int16 char_row;
int16 char_col;
/* calculated base hp values for player at each level, store them so that
   drain life + restore life does not affect hit points */
int16u player_hp[MAX_PLAYER_LEVEL];

/* Class titles for different levels				*/
#ifdef MACGAME
char *(*player_title)[MAX_PLAYER_LEVEL];
#else
char *player_title[MAX_CLASS][MAX_PLAYER_LEVEL] = {
	/* Warrior	 */
{"Rookie","Private","Soldier","Mercenary","Veteran(1st)","Veteran(2nd)",
"Veteran(3rd)","Warrior(1st)","Warrior(2nd)","Warrior(3rd)","Warrior(4th)",
"Swordsman-1","Swordsman-2","Swordsman-3","Hero","Swashbuckler","Myrmidon",
"Champion-1","Champion-2","Champion-3","Superhero","Knight","Superior Knt",
"Gallant Knt","Knt Errant","Guardian Knt","Baron","Duke","Lord (1st)",
"Lord (2nd)","Lord (3rd)","Lord (4th)","Lord (5th)","Lord (6th)","Lord (7th)",
"Lord (8th)","Lord (9th)","Lord Gallant","Lord Keeper","Lord Noble"},
	/* Mage		 */
{"Novice","Apprentice","Trickster-1","Trickster-2","Trickster-3","Cabalist-1",
"Cabalist-2","Cabalist-3","Visionist","Phantasmist","Shadowist","Spellbinder",
"Illusionist","Evoker (1st)","Evoker (2nd)","Evoker (3rd)","Evoker (4th)",
"Conjurer","Theurgist","Thaumaturge","Magician","Enchanter","Warlock",
"Sorcerer","Necromancer","Mage (1st)","Mage (2nd)","Mage (3rd)","Mage (4th)",
"Mage (5th)","Wizard (1st)","Wizard (2nd)","Wizard (3rd)","Wizard (4th)",
"Wizard (5th)","Wizard (6th)","Wizard (7th)","Wizard (8th)","Wizard (9th)",
"Wizard Lord"},
	/* Priests	 */
{"Believer","Acolyte(1st)","Acolyte(2nd)","Acolyte(3rd)","Adept (1st)",
"Adept (2nd)","Adept (3rd)","Priest (1st)","Priest (2nd)","Priest (3rd)",
"Priest (4th)","Priest (5th)","Priest (6th)","Priest (7th)","Priest (8th)",
"Priest (9th)","Curate (1st)","Curate (2nd)","Curate (3rd)","Curate (4th)",
"Curate (5th)","Curate (6th)","Curate (7th)","Curate (8th)","Curate (9th)",
"Canon (1st)","Canon (2nd)","Canon (3rd)","Canon (4th)","Canon (5th)",
"Low Lama","Lama-1","Lama-2","Lama-3","High Lama","Great Lama","Patriarch",
"High Priest","Great Priest","Noble Priest"},
	/* Rogues	 */
{"Vagabond","Footpad","Cutpurse","Robber","Burglar","Filcher","Sharper",
"Magsman","Common Rogue","Rogue (1st)","Rogue (2nd)","Rogue (3rd)",
"Rogue (4th)","Rogue (5th)","Rogue (6th)","Rogue (7th)","Rogue (8th)",
"Rogue (9th)","Master Rogue","Expert Rogue","Senior Rogue","Chief Rogue",
"Prime Rogue","Low Thief","Thief (1st)","Thief (2nd)","Thief (3rd)",
"Thief (4th)","Thief (5th)","Thief (6th)","Thief (7th)","Thief (8th)",
"Thief (9th)","High Thief","Master Thief","Executioner","Low Assassin",
"Assassin","High Assassin","Guildsmaster"},
	/* Rangers	 */
{"Runner (1st)","Runner (2nd)","Runner (3rd)","Strider (1st)","Strider (2nd)",
"Strider (3rd)","Scout (1st)","Scout (2nd)","Scout (3rd)","Scout (4th)",
"Scout (5th)","Courser (1st)","Courser (2nd)","Courser (3rd)","Courser (4th)",
"Courser (5th)","Tracker (1st)","Tracker (2nd)","Tracker (3rd)",
"Tracker (4th)","Tracker (5th)","Tracker (6th)","Tracker (7th)",
"Tracker (8th)","Tracker (9th)","Guide (1st)","Guide (2nd)","Guide (3rd)",
"Guide (4th)","Guide (5th)","Guide (6th)","Guide (7th)","Guide (8th)",
"Guide (9th)","Pathfinder-1","Pathfinder-2","Pathfinder-3","Ranger",
"High Ranger","Ranger Lord"},
	/* Paladins	 */
{"Gallant","Keeper (1st)","Keeper (2nd)","Keeper (3rd)","Keeper (4th)",
"Keeper (5th)","Keeper (6th)","Keeper (7th)","Keeper (8th)","Keeper (9th)",
"Protector-1","Protector-2","Protector-3","Protector-4","Protector-5",
"Protector-6","Protector-7","Protector-8","Defender-1","Defender-2",
"Defender-3","Defender-4","Defender-5","Defender-6","Defender-7","Defender-8",
"Warder (1st)","Warder (2nd)","Warder (3rd)","Warder (4th)","Warder (5th)",
"Warder (6th)","Warder (7th)","Warder (8th)","Warder (9th)","Guardian",
"Chevalier","Justiciar","Paladin","High Lord"}
};
#endif

/* Base experience levels, may be adjusted up for race and/or class*/
int32u player_exp[MAX_PLAYER_LEVEL] = {
      10,      25,	45,	 70,	  100,	    140,      200,	280,
     380,     500,     650,	850,	 1100,	   1400,     1800,     2300,
    2900,    3600,    4400,    5400,	 6800,	   8400,    10200,    12500,
   17500,   25000,  35000L,  50000L,   75000L,	100000L,  150000L,  200000L,
 300000L, 400000L, 500000L, 750000L, 1500000L, 2500000L, 5000000L, 10000000L
};

/*Race	STR,INT,WIS,DEX,CON,CHR,
	Ages, heights, and weights (male then female)
	Racial Bases for: dis,srh,stl,fos,bth,bthb,bsav,hitdie,
	infra, exp base, choice-classes */
#ifdef MACGAME
race_type *race;
#else
race_type race[MAX_RACES] = {
   {"Human",	 0,  0,	 0,  0,	 0,  0,
      14,  6, 72,  6,180, 25, 66,  4,150, 20,
      0,  0,  0,  0,  0,  0,  0, 10,  0, 100, 0x3F,
    },
   {"Half-Elf", -1,  1,	 0,  1, -1,  1,
      24, 16, 66,  6,130, 15, 62,  6,100, 10,
      2,  6,  1, -1, -1,  5,  3,  9,  2, 110, 0x3F,
    },
   {"Elf",	-1,  2,	 1,  1, -2,  1,
      75, 75, 60,  4,100,  6, 54,  4, 80,  6,
      5,  8,  1, -2, -5, 15,  6,  8,  3, 120, 0x1F,
    },
   {"Halfling", -2,  2,	 1,  3,	 1,  1,
      21, 12, 36,  3, 60,  3, 33,  3, 50,  3,
      15, 12,  4, -5,-10, 20, 18,  6,  4, 110, 0x0B,
    },
   {"Gnome",	-1,  2,	 0,  2,	 1, -2,
      50, 40, 42,  3, 90,  6, 39,  3, 75,  3,
      10,  6,  3, -3, -8, 12, 12,  7,  4, 125, 0x0F,
    },
   {"Dwarf",	 2, -3,	 1, -2,	 2, -3,
      35, 15, 48,  3,150, 10, 46,  3,120, 10,
      2,  7,  -1,  0, 15,  0,  9,  9,  5, 120, 0x05,
    },
   {"Half-Orc",	 2, -1,	 0,  0,	 1, -4,
      11,  4, 66,  1,150,  5, 62,  1,120,  5,
      -3,  0, -1,  3, 12, -5, -3, 10,  3, 110, 0x0D,
    },
   {"Half-Troll",4, -4, -2, -4,	 3, -6,
      20, 10, 96, 10,255, 50, 84,  8,225, 40,
      -5, -1, -2,  5, 20,-10, -8, 12,  3, 120, 0x05,
    }
 };
#endif

/* Background information					*/
#ifdef MACGAME
background_type *background;
#else
background_type background[MAX_BACKGROUND] = {
{"You are the illegitimate and unacknowledged child ",		 10, 1, 2, 25},
{"You are the illegitimate but acknowledged child ",		 20, 1, 2, 35},
{"You are one of several children ",				 95, 1, 2, 45},
{"You are the first child ",					100, 1, 2, 50},
{"of a Serf.  ",						 40, 2, 3, 65},
{"of a Yeoman.  ",						 65, 2, 3, 80},
{"of a Townsman.  ",						 80, 2, 3, 90},
{"of a Guildsman.  ",						 90, 2, 3,105},
{"of a Landed Knight.  ",					 96, 2, 3,120},
{"of a Titled Noble.  ",					 99, 2, 3,130},
{"of a Royal Blood Line.  ",					100, 2, 3,140},
{"You are the black sheep of the family.  ",			 20, 3,50, 20},
{"You are a credit to the family.  ",				 80, 3,50, 55},
{"You are a well liked child.  ",				100, 3,50, 60},
{"Your mother was a Green-Elf.  ",				 40, 4, 1, 50},
{"Your father was a Green-Elf.  ",				 75, 4, 1, 55},
{"Your mother was a Grey-Elf.  ",				 90, 4, 1, 55},
{"Your father was a Grey-Elf.  ",				 95, 4, 1, 60},
{"Your mother was a High-Elf.  ",				 98, 4, 1, 65},
{"Your father was a High-Elf.  ",				100, 4, 1, 70},
{"You are one of several children ",				 60, 7, 8, 50},
{"You are the only child ",					100, 7, 8, 55},
{"of a Green-Elf ",						 75, 8, 9, 50},
{"of a Grey-Elf ",						 95, 8, 9, 55},
{"of a High-Elf ",						100, 8, 9, 60},
{"Ranger.  ",							 40, 9,54, 80},
{"Archer.  ",							 70, 9,54, 90},
{"Warrior.  ",							 87, 9,54,110},
{"Mage.  ",							 95, 9,54,125},
{"Prince.  ",							 99, 9,54,140},
{"King.  ",							100, 9,54,145},
{"You are one of several children of a Halfling ",		 85,10,11, 45},
{"You are the only child of a Halfling ",			100,10,11, 55},
{"Bum.  ",							 20,11, 3, 55},
{"Tavern Owner.  ",						 30,11, 3, 80},
{"Miller.  ",							 40,11, 3, 90},
{"Home Owner.  ",						 50,11, 3,100},
{"Burglar.  ",							 80,11, 3,110},
{"Warrior.  ",							 95,11, 3,115},
{"Mage.  ",							 99,11, 3,125},
{"Clan Elder.  ",						100,11, 3,140},
{"You are one of several children of a Gnome ",			 85,13,14, 45},
{"You are the only child of a Gnome ",				100,13,14, 55},
{"Beggar.  ",							 20,14, 3, 55},
{"Braggart.  ",							 50,14, 3, 70},
{"Prankster.  ",						 75,14, 3, 85},
{"Warrior.  ",							 95,14, 3,100},
{"Mage.  ",							100,14, 3,125},
{"You are one of two children of a Dwarven ",			 25,16,17, 40},
{"You are the only child of a Dwarven ",			100,16,17, 50},
{"Thief.  ",							 10,17,18, 60},
{"Prison Guard.  ",						 25,17,18, 75},
{"Miner.  ",							 75,17,18, 90},
{"Warrior.  ",							 90,17,18,110},
{"Priest.  ",							 99,17,18,130},
{"King.  ",							100,17,18,150},
{"You are the black sheep of the family.  ",			 15,18,57, 10},
{"You are a credit to the family.  ",				 85,18,57, 50},
{"You are a well liked child.  ",				100,18,57, 55},
{"Your mother was an Orc, but it is unacknowledged.  ",		 25,19,20, 25},
{"Your father was an Orc, but it is unacknowledged.  ",		100,19,20, 25},
{"You are the adopted child ",					100,20, 2, 50},
{"Your mother was a Cave-Troll ",				 30,22,23, 20},
{"Your father was a Cave-Troll ",				 60,22,23, 25},
{"Your mother was a Hill-Troll ",				 75,22,23, 30},
{"Your father was a Hill-Troll ",				 90,22,23, 35},
{"Your mother was a Water-Troll ",				 95,22,23, 40},
{"Your father was a Water-Troll ",				100,22,23, 45},
{"Cook.  ",							  5,23,62, 60},
{"Warrior.  ",							 95,23,62, 55},
{"Shaman.  ",							 99,23,62, 65},
{"Clan Chief.  ",						100,23,62, 80},
{"You have dark brown eyes, ",					 20,50,51, 50},
{"You have brown eyes, ",					 60,50,51, 50},
{"You have hazel eyes, ",					 70,50,51, 50},
{"You have green eyes, ",					 80,50,51, 50},
{"You have blue eyes, ",					 90,50,51, 50},
{"You have blue-gray eyes, ",					100,50,51, 50},
{"straight ",							 70,51,52, 50},
{"wavy ",							 90,51,52, 50},
{"curly ",							100,51,52, 50},
{"black hair, ",						 30,52,53, 50},
{"brown hair, ",						 70,52,53, 50},
{"auburn hair, ",						 80,52,53, 50},
{"red hair, ",							 90,52,53, 50},
{"blond hair, ",						100,52,53, 50},
{"and a very dark complexion.",					 10,53, 0, 50},
{"and a dark complexion.",					 30,53, 0, 50},
{"and an average complexion.",					 80,53, 0, 50},
{"and a fair complexion.",					 90,53, 0, 50},
{"and a very fair complexion.",					100,53, 0, 50},
{"You have light grey eyes, ",					 85,54,55, 50},
{"You have light blue eyes, ",					 95,54,55, 50},
{"You have light green eyes, ",					100,54,55, 50},
{"straight ",							 75,55,56, 50},
{"wavy ",							100,55,56, 50},
{"black hair, and a fair complexion.",				 75,56, 0, 50},
{"brown hair, and a fair complexion.",				 85,56, 0, 50},
{"blond hair, and a fair complexion.",				 95,56, 0, 50},
{"silver hair, and a fair complexion.",				100,56, 0, 50},
{"You have dark brown eyes, ",					 99,57,58, 50},
{"You have glowing red eyes, ",					100,57,58, 60},
{"straight ",							 90,58,59, 50},
{"wavy ",							100,58,59, 50},
{"black hair, ",						 75,59,60, 50},
{"brown hair, ",						100,59,60, 50},
{"a one foot beard, ",						 25,60,61, 50},
{"a two foot beard, ",						 60,60,61, 51},
{"a three foot beard, ",					 90,60,61, 53},
{"a four foot beard, ",						100,60,61, 55},
{"and a dark complexion.",					100,61, 0, 50},
{"You have slime green eyes, ",					 60,62,63, 50},
{"You have puke yellow eyes, ",					 85,62,63, 50},
{"You have blue-bloodshot eyes, ",				 99,62,63, 50},
{"You have glowing red eyes, ",					100,62,63, 55},
{"dirty ",							 33,63,64, 50},
{"mangy ",							 66,63,64, 50},
{"oily ",							100,63,64, 50},
{"sea-weed green hair, ",					 33,64,65, 50},
{"bright red hair, ",						 66,64,65, 50},
{"dark purple hair, ",						100,64,65, 50},
{"and green ",							 25,65,66, 50},
{"and blue ",							 50,65,66, 50},
{"and white ",							 75,65,66, 50},
{"and black ",							100,65,66, 50},
{"ulcerous skin.",						 33,66, 0, 50},
{"scabby skin.",						 66,66, 0, 50},
{"leprous skin.",						100,66, 0, 50}
};
#endif

/* Classes.							*/
class_type class[MAX_CLASS] = {
/*	  HP Dis Src Stl Fos bth btb sve S  I  W  D Co Ch  Spell Exp  spl */
{"Warrior",9, 25, 14, 1, 38, 70, 55, 18, 5,-2,-2, 2, 2,-1, NONE,    0, 0},
{"Mage",   0, 30, 16, 2, 20, 34, 20, 36,-5, 3, 0, 1,-2, 1, MAGE,   30, 1},
{"Priest", 2, 25, 16, 2, 32, 48, 35, 30,-3,-3, 3,-1, 0, 2, PRIEST, 20, 1},
{"Rogue",  6, 45, 32, 5, 16, 60, 66, 30, 2, 1,-2, 3, 1,-1, MAGE,    0, 5},
{"Ranger", 4, 30, 24, 3, 24, 56, 72, 30, 2, 2, 0, 1, 1, 1, MAGE,   40, 3},
{"Paladin",6, 20, 12, 1, 38, 68, 40, 24, 3,-3, 1, 0, 2, 2, PRIEST, 35, 1}
};

/* making it 16 bits wastes a little space, but saves much signed/unsigned
   headaches in its use */
/* CLA_MISC_HIT is identical to CLA_SAVE, which takes advantage of
   the fact that the save values are independent of the class */
int16 class_level_adj[MAX_CLASS][MAX_LEV_ADJ] = {
/*	       bth    bthb   device  disarm   save/misc hit  */
/* Warrior */ {	4,	4,	2,	2,	3 },
/* Mage    */ { 2,	2,	4,	3,	3 },
/* Priest  */ { 2,	2,	4,	3,	3 },
/* Rogue   */ { 3,	4,	3,	4,	3 },
/* Ranger  */ { 3,	4,	3,	3,	3 },
/* Paladin */ { 3,	3,	3,	2,	3 }
};

int32u spell_learned = 0;	/* bit mask of spells learned */
int32u spell_worked = 0;	/* bit mask of spells tried and worked */
int32u spell_forgotten = 0;	/* bit mask of spells learned but forgotten */
int8u spell_order[32];		/* order spells learned/remembered/forgotten */

/* Warriors don't have spells, so there is no entry for them.  Note that
   this means you must always subtract one from the py.misc.pclass before
   indexing into magic_spell[]. */
#ifdef MACGAME
spell_type (*magic_spell)[31];
#else
spell_type magic_spell[MAX_CLASS-1][31] = {
  {		  /* Mage	   */
     {	1,  1, 22,   1},
     {	1,  1, 23,   1},
     {	1,  2, 24,   1},
     {	1,  2, 26,   1},
     {	3,  3, 25,   2},
     {	3,  3, 25,   1},
     {	3,  3, 27,   2},
     {	3,  4, 30,   1},
     {	5,  4, 30,   6},
     {	5,  5, 30,   8},
     {	5,  5, 30,   5},
     {	5,  5, 35,   6},
     {	7,  6, 35,   9},
     {	7,  6, 50,  10},
     {	7,  6, 40,  12},
     {	9,  7, 44,  19},
     {	9,  7, 45,  19},
     {	9,  7, 75,  22},
     {	9,  7, 45,  19},
     { 11,  7, 45,  25},
     { 11,  7, 99,  19},
     { 13,  7, 50,  22},
     { 15,  9, 50,  25},
     { 17,  9, 50,  31},
     { 19, 12, 55,  38},
     { 21, 12, 90,  44},
     { 23, 12, 60,  50},
     { 25, 12, 65,  63},
     { 29, 18, 65,  88},
     { 33, 21, 80, 125},
     { 37, 25, 95, 200}
   },
   {		  /* Priest	   */
     {	1,  1, 10,   1},
     {	1,  2, 15,   1},
     {	1,  2, 20,   1},
     {	1,  2, 25,   1},
     {	3,  2, 25,   1},
     {	3,  3, 27,   2},
     {	3,  3, 27,   2},
     {	3,  3, 28,   3},
     {	5,  4, 29,   4},
     {	5,  4, 30,   5},
     {	5,  4, 32,   5},
     {	5,  5, 34,   5},
     {	7,  5, 36,   6},
     {	7,  5, 38,   7},
     {	7,  6, 38,   9},
     {	7,  7, 38,   9},
     {	9,  6, 38,  10},
     {	9,  7, 38,  10},
     {	9,  7, 40,  10},
     { 11,  8, 42,  10},
     { 11,  8, 42,  12},
     { 11,  9, 55,  15},
     { 13, 10, 45,  15},
     { 13, 11, 45,  16},
     { 15, 12, 50,  20},
     { 15, 14, 50,  22},
     { 17, 14, 55,  32},
     { 21, 16, 60,  38},
     { 25, 20, 70,  75},
     { 33, 24, 90, 125},
     { 39, 32, 99, 200}
   },
   {		  /* Rogue	   */
     { 99, 99,	0,   0},
     {	5,  1, 50,   1},
     {	7,  2, 55,   1},
     {	9,  3, 60,   2},
     { 11,  4, 65,   2},
     { 13,  5, 70,   3},
     { 99, 99,	0,   0},
     { 15,  6, 75,   3},
     { 99, 99,	0,   0},
     { 17,  7, 80,   4},
     { 19,  8, 85,   5},
     { 21,  9, 90,   6},
     { 99, 99,	0,   0},
     { 23, 10, 95,   7},
     { 99, 99,	0,   0},
     { 99, 99,	0,   0},
     { 25, 12, 95,   9},
     { 27, 15, 99,  11},
     { 99, 99,	0,   0},
     { 99, 99,	0,   0},
     { 29, 18, 99,  19},
     { 99, 99,	0,   0},
     { 99, 99,	0,   0},
     { 99, 99,	0,   0},
     { 99, 99,	0,   0},
     { 99, 99,	0,   0},
     { 99, 99,	0,   0},
     { 99, 99,	0,   0},
     { 99, 99,	0,   0},
     { 99, 99,	0,   0},
     { 99, 99,	0,   0},
   },
   {		   /* Ranger	    */
     {	3,  1, 30,   1},
     {	3,  2, 35,   2},
     {	3,  2, 35,   2},
     {	5,  3, 35,   2},
     {	5,  3, 40,   2},
     {	5,  4, 45,   3},
     {	7,  5, 40,   6},
     {	7,  6, 40,   5},
     {	9,  7, 40,   7},
     {	9,  8, 45,   8},
     { 11,  8, 40,  10},
     { 11,  9, 45,  10},
     { 13, 10, 45,  12},
     { 13, 11, 55,  13},
     { 15, 12, 50,  15},
     { 15, 13, 50,  15},
     { 17, 17, 55,  15},
     { 17, 17, 90,  17},
     { 21, 17, 55,  17},
     { 21, 19, 60,  18},
     { 23, 25, 95,  20},
     { 23, 20, 60,  20},
     { 25, 20, 60,  20},
     { 25, 21, 65,  20},
     { 27, 21, 65,  22},
     { 29, 23, 95,  23},
     { 31, 25, 70,  25},
     { 33, 25, 75,  38},
     { 35, 25, 80,  50},
     { 37, 30, 95, 100},
     { 99, 99,	0,   0}
   },
   {		  /* Paladin	   */
     {	1,  1, 30,   1},
     {	2,  2, 35,   2},
     {	3,  3, 35,   3},
     {	5,  3, 35,   5},
     {	5,  4, 35,   5},
     {	7,  5, 40,   6},
     {	7,  5, 40,   6},
     {	9,  7, 40,   7},
     {	9,  7, 40,   8},
     {	9,  8, 40,   8},
     { 11,  9, 40,  10},
     { 11, 10, 45,  10},
     { 11, 10, 45,  10},
     { 13, 10, 45,  12},
     { 13, 11, 45,  13},
     { 15, 13, 45,  15},
     { 15, 15, 50,  15},
     { 17, 15, 50,  17},
     { 17, 15, 50,  18},
     { 19, 15, 50,  19},
     { 19, 15, 50,  19},
     { 21, 17, 50,  20},
     { 23, 17, 50,  20},
     { 25, 20, 50,  20},
     { 27, 21, 50,  22},
     { 29, 22, 50,  24},
     { 31, 24, 60,  25},
     { 33, 28, 60,  31},
     { 35, 32, 70,  38},
     { 37, 36, 90,  50},
     { 39, 38, 95, 100}
   }
 };
#endif

char *spell_names[62] = {
  /* Mage Spells */
  "Magic Missile",  "Detect Monsters",	"Phase Door",  "Light Area",
  "Cure Light Wounds",	"Find Hidden Traps/Doors",  "Stinking Cloud",
  "Confusion",	"Lightning Bolt",  "Trap/Door Destruction", "Sleep I",
  "Cure Poison",  "Teleport Self",  "Remove Curse",  "Frost Bolt",
  "Turn Stone to Mud",	"Create Food",	"Recharge Item I",  "Sleep II",
  "Polymorph Other",  "Identify",  "Sleep III",	 "Fire Bolt",  "Slow Monster",
  "Frost Ball",	 "Recharge Item II", "Teleport Other",	"Haste Self",
  "Fire Ball", "Word of Destruction", "Genocide",
  /* Priest Spells, start at index 31 */
  "Detect Evil",  "Cure Light Wounds",	"Bless",  "Remove Fear", "Call Light",
  "Find Traps",	 "Detect Doors/Stairs",	 "Slow Poison",	 "Blind Creature",
  "Portal",  "Cure Medium Wounds",  "Chant",  "Sanctuary",  "Create Food",
  "Remove Curse",  "Resist Heat and Cold",  "Neutralize Poison",
  "Orb of Draining",  "Cure Serious Wounds",  "Sense Invisible",
  "Protection from Evil",  "Earthquake",  "Sense Surroundings",
  "Cure Critical Wounds",  "Turn Undead",  "Prayer",  "Dispel Undead",
  "Heal",  "Dispel Evil",  "Glyph of Warding",	"Holy Word"
};

/* Each type of character starts out with a few provisions.	*/
/* Note that the entries refer to elements of the object_list[] array*/
/* 344 = Food Ration, 365 = Wooden Torch, 123 = Cloak, 318 = Beginners-Majik,
   103 = Soft Leather Armor, 30 = Stiletto, 322 = Beginners Handbook */

int16u player_init[MAX_CLASS][5] = {
		{ 344, 365, 123,  30, 103},	/* Warrior	 */
		{ 344, 365, 123,  30, 318},	/* Mage		 */
		{ 344, 365, 123,  30, 322},	/* Priest	 */
		{ 344, 365, 123,  30, 318},	/* Rogue	 */
		{ 344, 365, 123,  30, 318},	/* Ranger	 */
		{ 344, 365, 123,  30, 322}	/* Paladin	 */
};
