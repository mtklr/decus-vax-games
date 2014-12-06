/*
  Monster related definitions
*/

#define MAXMONST 56     /* maximum # monsters in the dungeon   */

/*  this is the structure definition of the monster data
*/
struct monst
    {
    char    *name;
    char    level;
    short   armorclass;
    char    damage;
    char    attack;
    char    defense;
    char    genocided;
    char    intelligence; /* monsters intelligence -- used to choose movement */
    short   gold;
    short   hitpoints;
    unsigned long experience;
    };

extern struct monst monster[];

/*  defines for the monsters as objects     
*/
#define BAT 1
#define GNOME 2
#define HOBGOBLIN 3
#define JACKAL 4
#define KOBOLD 5
#define ORC 6
#define SNAKE 7
#define CENTIPEDE 8
#define JACULI 9
#define TROGLODYTE 10
#define ANT 11
#define EYE 12 
#define LEPRECHAUN 13
#define NYMPH 14
#define QUASIT 15 
#define RUSTMONSTER 16 
#define ZOMBIE 17 
#define ASSASSINBUG 18 
#define BUGBEAR 19 
#define HELLHOUND 20 
#define ICELIZARD 21 
#define CENTAUR 22 
#define TROLL 23 
#define YETI 24 
#define WHITEDRAGON 25
#define ELF 26
#define CUBE 27 
#define METAMORPH 28 
#define VORTEX 29 
#define ZILLER 30 
#define VIOLETFUNGI 31 
#define WRAITH 32 
#define FORVALAKA 33 
#define LAMANOBE 34 
#define OSEQUIP 35 
#define ROTHE 36
#define XORN 37
#define VAMPIRE 38
#define INVISIBLESTALKER 39
#define POLTERGEIST 40
#define DISENCHANTRESS 41
#define SHAMBLINGMOUND 42
#define YELLOWMOLD 43
#define UMBERHULK 44
#define GNOMEKING 45
#define MIMIC 46
#define WATERLORD 47
#define BRONZEDRAGON 48
#define GREENDRAGON 49
#define PURPLEWORM 50
#define XVART 51
#define SPIRITNAGA 52
#define SILVERDRAGON 53
#define PLATINUMDRAGON 54
#define GREENURCHIN 55
#define REDDRAGON 56
#define DEMONLORD 57
#define DEMONPRINCE 64
