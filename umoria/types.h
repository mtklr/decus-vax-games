/* source/types.h: global type declarations

   Copyright (c) 1989-92 James E. Wilson, Robert A. Koeneke

   This software may be copied and distributed for educational, research, and
   not for profit purposes provided that this copyright and statement are
   included in all such copies. */

typedef unsigned long  int32u;
typedef long	       int32;
typedef unsigned short int16u;
typedef short	       int16;
typedef unsigned char  int8u;
/* some machines will not accept 'signed char' as a type, and some accept it
   but still treat it like an unsigned character, let's just avoid it,
   any variable which can ever hold a negative value must be 16 or 32 bits */

#define VTYPESIZ	80
#define BIGVTYPESIZ	160
typedef char vtype[VTYPESIZ];
/* note that since its output can easily exceed 80 characters, objdes must
   always be called with a bigvtype as the first paramter */
typedef char bigvtype[BIGVTYPESIZ];
typedef char stat_type[7];

/* Many of the character fields used to be fixed length, which greatly
   increased the size of the executable.  I have replaced many fixed
   length fields with variable length ones. */

/* all fields are given the smallest possbile type, and all fields are
   aligned within the structure to their natural size boundary, so that
   the structures contain no padding and are minimum size */

/* bit fields are only used where they would cause a large reduction in
   data size, they should not be used otherwise because their use
   results in larger and slower code */

typedef struct creature_type
{
  char *name;		/* Descrip of creature	*/
  int32u cmove;		/* Bit field		*/
  int32u spells;	/* Creature spells	*/
  int16u cdefense;	/* Bit field		*/
  int16u mexp;		/* Exp value for kill	*/
  int8u sleep;		/* Inactive counter/10	*/
  int8u aaf;		/* Area affect radius	*/
  int8u ac;		/* AC			*/
  int8u speed;		/* Movement speed+10	*/
  int8u cchar;		/* Character rep.	*/
  int8u hd[2];		/* Creatures hit die	*/
  int8u damage[4];	/* Type attack and damage*/
  int8u level;		/* Level of creature	*/
} creature_type;

typedef struct m_attack_type	/* Monster attack and damage types */
  {
    int8u attack_type;
    int8u attack_desc;
    int8u attack_dice;
    int8u attack_sides;
  } m_attack_type;

typedef struct recall_type	/* Monster memories. -CJS- */
  {
    int32u r_cmove;
    int32u r_spells;
    int16u r_kills, r_deaths;
    int16u r_cdefense;
    int8u r_wake, r_ignore;
    int8u r_attacks[MAX_MON_NATTACK];
  } recall_type;

typedef struct monster_type
{
  int16 hp;		/* Hit points		*/
  int16 csleep;		/* Inactive counter	*/
  int16 cspeed;		/* Movement speed	*/
  int16u mptr;		/* Pointer into creature*/
  /* Note: fy, fx, and cdis constrain dungeon size to less than 256 by 256 */
  int8u fy;		/* Y Pointer into map	*/
  int8u fx;		/* X Pointer into map	*/
  int8u cdis;		/* Cur dis from player	*/
  int8u ml;
  int8u stunned;
  int8u confused;
} monster_type;

typedef struct treasure_type
{
  char *name;		/* Object name		*/
  int32u flags;		/* Special flags	*/
  int8u tval;		/* Category number	*/
  int8u tchar;		/* Character representation*/
  int16 p1;		/* Misc. use variable	*/
  int32 cost;		/* Cost of item		*/
  int8u subval;		/* Sub-category number	*/
  int8u number;		/* Number of items	*/
  int16u weight;	/* Weight		*/
  int16 tohit;		/* Plusses to hit	*/
  int16 todam;		/* Plusses to damage	*/
  int16 ac;		/* Normal AC		*/
  int16 toac;		/* Plusses to AC	*/
  int8u damage[2];	/* Damage when hits	*/
  int8u level;		/* Level item first found */
} treasure_type;

/* only damage, ac, and tchar are constant; level could possibly be made
   constant by changing index instead; all are used rarely */
/* extra fields x and y for location in dungeon would simplify pusht() */
/* making inscrip a pointer and mallocing space does not work, there are
   two many places where inven_types are copied, which results in dangling
   pointers, so we use a char array for them instead */
#define INSCRIP_SIZE 13  /* notice alignment, must be 4*x + 1 */
typedef struct inven_type
{
  int16u index;		/* Index to object_list */
  int8u name2;		/* Object special name  */
  char inscrip[INSCRIP_SIZE]; /* Object inscription   */
  int32u flags;		/* Special flags	*/
  int8u tval;		/* Category number	*/
  int8u tchar;		/* Character representation*/
  int16 p1;		/* Misc. use variable	*/
  int32 cost;		/* Cost of item		*/
  int8u subval;		/* Sub-category number	*/
  int8u number;		/* Number of items	*/
  int16u weight;	/* Weight		*/
  int16 tohit;		/* Plusses to hit	*/
  int16 todam;		/* Plusses to damage	*/
  int16 ac;		/* Normal AC		*/
  int16 toac;		/* Plusses to AC	*/
  int8u damage[2];	/* Damage when hits	*/
  int8u level;		/* Level item first found */
  int8u ident;		/* Identify information */
} inven_type;

#define PLAYER_NAME_SIZE 27

typedef struct player_type
{
  struct misc
    {
      char name[PLAYER_NAME_SIZE];	/* Name of character	*/
      int8u male;	/* Sex of character	*/
      int32 au;		/* Gold			*/
      int32 max_exp;	/* Max experience	*/
      int32 exp;	/* Cur experience	*/
      int16u exp_frac;	/* Cur exp fraction * 2^16 */
      int16u age;	/* Characters age	*/
      int16u ht;	/* Height		*/
      int16u wt;	/* Weight		*/
      int16u lev;	/* Level		*/
      int16u max_dlv;	/* Max level explored	*/
      int16 srh;	/* Chance in search	*/
      int16 fos;	/* Frenq of search	*/
      int16 bth;	/* Base to hit		*/
      int16 bthb;	/* BTH with bows	*/
      int16 mana;	/* Mana points		*/
      int16 mhp;	/* Max hit pts		*/
      int16 ptohit;	/* Plusses to hit	*/
      int16 ptodam;	/* Plusses to dam	*/
      int16 pac;	/* Total AC		*/
      int16 ptoac;	/* Magical AC		*/
      int16 dis_th;	/* Display +ToHit	*/
      int16 dis_td;	/* Display +ToDam	*/
      int16 dis_ac;	/* Display +ToAC	*/
      int16 dis_tac;	/* Display +ToTAC	*/
      int16 disarm;	/* % to Disarm		*/
      int16 save;	/* Saving throw		*/
      int16 sc;		/* Social Class		*/
      int16 stl;	/* Stealth factor	*/
      int8u pclass;	/* # of class		*/
      int8u prace;	/* # of race		*/
      int8u hitdie;	/* Char hit die		*/
      int8u expfact;	/* Experience factor	*/
      int16 cmana;	/* Cur mana pts		*/
      int16u cmana_frac; /* Cur mana fraction * 2^16 */
      int16 chp;	/* Cur hit pts		*/
      int16u chp_frac;	/* Cur hit fraction * 2^16 */
      char history[4][60]; /* History record	*/
    } misc;
  /* Stats now kept in arrays, for more efficient access. -CJS- */
  struct stats
    {
      int8u max_stat[6];	/* What is restored */
      int8u cur_stat[6];	/* What is natural */
      int16 mod_stat[6];	/* What is modified, may be +/- */
      int8u use_stat[6];	/* What is used */
    } stats;
  struct flags
    {
      int32u status;		/* Status of player    */
      int16 rest;		/* Rest counter	       */
      int16 blind;		/* Blindness counter   */
      int16 paralysis;		/* Paralysis counter   */
      int16 confused;		/* Confusion counter   */
      int16 food;		/* Food counter	       */
      int16 food_digested;	/* Food per round      */
      int16 protection;		/* Protection fr. evil */
      int16 speed;		/* Cur speed adjust    */
      int16 fast;		/* Temp speed change   */
      int16 slow;		/* Temp speed change   */
      int16 afraid;		/* Fear		       */
      int16 poisoned;		/* Poisoned	       */
      int16 image;		/* Hallucinate	       */
      int16 protevil;		/* Protect VS evil     */
      int16 invuln;		/* Increases AC	       */
      int16 hero;		/* Heroism	       */
      int16 shero;		/* Super Heroism       */
      int16 blessed;		/* Blessed	       */
      int16 resist_heat;	/* Timed heat resist   */
      int16 resist_cold;	/* Timed cold resist   */
      int16 detect_inv;		/* Timed see invisible */
      int16 word_recall;	/* Timed teleport level*/
      int16 see_infra;		/* See warm creatures  */
      int16 tim_infra;		/* Timed infra vision  */
      int8u see_inv;		/* Can see invisible   */
      int8u teleport;		/* Random teleportation*/
      int8u free_act;		/* Never paralyzed     */
      int8u slow_digest;	/* Lower food needs    */
      int8u aggravate;		/* Aggravate monsters  */
      int8u fire_resist;	/* Resistance to fire  */
      int8u cold_resist;	/* Resistance to cold  */
      int8u acid_resist;	/* Resistance to acid  */
      int8u regenerate;		/* Regenerate hit pts  */
      int8u lght_resist;	/* Resistance to light */
      int8u ffall;		/* No damage falling   */
      int8u sustain_str;	/* Keep strength       */
      int8u sustain_int;	/* Keep intelligence   */
      int8u sustain_wis;	/* Keep wisdom	       */
      int8u sustain_con;	/* Keep constitution   */
      int8u sustain_dex;	/* Keep dexterity      */
      int8u sustain_chr;	/* Keep charisma       */
      int8u confuse_monster;	/* Glowing hands.    */
      int8u new_spells;		/* Number of spells can learn. */
    } flags;
} player_type;

typedef struct spell_type
{  /* spell name is stored in spell_names[] array at index i, +31 if priest */
  int8u slevel;
  int8u smana;
  int8u sfail;
  int8u sexp;	/* 1/4 of exp gained for learning spell */
} spell_type;

typedef struct race_type
{
  char	*trace;		/* Type of race			*/
  int16 str_adj;	/* adjustments			*/
  int16 int_adj;
  int16 wis_adj;
  int16 dex_adj;
  int16 con_adj;
  int16 chr_adj;
  int8u b_age;	       /* Base age of character		*/
  int8u m_age;	       /* Maximum age of character	*/
  int8u m_b_ht;	      /* base height for males		*/
  int8u m_m_ht;	      /* mod height for males		*/
  int8u m_b_wt;	      /* base weight for males		*/
  int8u m_m_wt;	      /* mod weight for males		*/
  int8u f_b_ht;	      /* base height females		*/
  int8u f_m_ht;	      /* mod height for females	*/
  int8u f_b_wt;	      /* base weight for female	*/
  int8u f_m_wt;	      /* mod weight for females	*/
  int16 b_dis;	       /* base chance to disarm		*/
  int16 srh;	       /* base chance for search	*/
  int16 stl;	       /* Stealth of character		*/
  int16 fos;	       /* frequency of auto search	*/
  int16 bth;	       /* adj base chance to hit	*/
  int16 bthb;	       /* adj base to hit with bows	*/
  int16 bsav;	       /* Race base for saving throw	*/
  int8u bhitdie;	       /* Base hit points for race	*/
  int8u infra;	       /* See infra-red			*/
  int8u b_exp;	       /* Base experience factor	*/
  int8u rtclass;       /* Bit field for class types	*/
} race_type;

typedef struct class_type
{
  char *title;		/* type of class		*/
  int8u adj_hd;		/* Adjust hit points		*/
  int8u mdis;		/* mod disarming traps		*/
  int8u msrh;		/* modifier to searching	*/
  int8u mstl;		/* modifier to stealth		*/
  int8u mfos;		/* modifier to freq-of-search	*/
  int8u mbth;		/* modifier to base to hit	*/
  int8u mbthb;		/* modifier to base to hit - bows*/
  int8u msav;		/* Class modifier to save	*/
  int16 madj_str;	/* Class modifier for strength	*/
  int16 madj_int;	/* Class modifier for intelligence*/
  int16 madj_wis;	/* Class modifier for wisdom	*/
  int16 madj_dex;	/* Class modifier for dexterity */
  int16 madj_con;	/* Class modifier for constitution*/
  int16 madj_chr;	/* Class modifier for charisma	*/
  int8u spell;		/* class use mage spells	*/
  int8u m_exp;		/* Class experience factor	*/
  int8u first_spell_lev;/* First level where class can use spells. */
} class_type;

typedef struct background_type
{
  char *info;		/* History information		*/
  int8u roll;		/* Die roll needed for history	*/
  int8u chart;		/* Table number			*/
  int8u next;		/* Pointer to next table	*/
  int8u bonus;		/* Bonus to the Social Class+50	*/
} background_type;

typedef struct cave_type
{
#ifdef AMIGA
  /* This reduces the size from 64 bits to 32 bits. */
  unsigned int cptr : 8;
  unsigned int tptr : 8;
  unsigned int fval : 8;
#else
  int8u cptr;
  int8u tptr;
  int8u fval;
#endif
#if !defined(MSDOS) && !defined(ATARIST_MWC)
  unsigned int lr : 1;  /* room should be lit with perm light, walls with
			   this set should be perm lit after tunneled out */
  unsigned int fm : 1;	/* field mark, used for traps/doors/stairs, object is
			   hidden if fm is FALSE */
  unsigned int pl : 1;	/* permanent light, used for walls and lighted rooms */
  unsigned int tl : 1;	/* temporary light, used for player's lamp light,etc.*/
#else
#ifndef __TURBOC__
  /* this is not legal ANSI C, this is a MSC extension, which will use 1 byte
     for the bitfields whereas MSC uses 2 bytes for the bitfields above */
  /* this is also a MWC extension on the Atari ST */
  unsigned char lr : 1;
  unsigned char fm : 1;
  unsigned char pl : 1;
  unsigned char tl : 1;
#else
  unsigned lr : 1;
  unsigned fm : 1;
  unsigned pl : 1;
  unsigned tl : 1;
#endif
#endif
} cave_type;

typedef struct owner_type
{
  char *owner_name;
  int16 max_cost;
  int8u max_inflate;
  int8u min_inflate;
  int8u haggle_per;
  int8u owner_race;
  int8u insult_max;
} owner_type;

typedef struct inven_record
{
  int32 scost;
  inven_type sitem;
} inven_record;

typedef struct store_type
{
  int32 store_open;
  int16 insult_cur;
  int8u owner;
  int8u store_ctr;
  int16u good_buy;
  int16u bad_buy;
  inven_record store_inven[STORE_INVEN_MAX];
} store_type;

/* 64 bytes for this structure */
typedef struct high_scores
{
  int32 points;
  int32 birth_date;
  int16 uid;
  int16 mhp;
  int16 chp;
  int8u dun_level;
  int8u lev;
  int8u max_dlv;
  int8u sex;
  int8u race;
  int8u class;
  char name[PLAYER_NAME_SIZE];
  char died_from[25];
} high_scores;
