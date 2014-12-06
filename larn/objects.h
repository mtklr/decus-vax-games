/*
  Object definitions
*/
#define MAXSCROLL 28    /* maximum number of scrolls that are possible */
#define MAXPOTION 35    /* maximum number of potions that are possible */

#define MAXOBJ 93       /* the maximum number of objects   n < MAXOBJ */

/*  this is the structure definition for the items in the dnd store */
struct _itm
    {
    short   price;
    char    **mem;
    char    obj;
    char    arg;
    char    qty;
    };

extern struct _itm itm[];

/*  defines for the objects in the game     */
#define MAXOBJECT  92

#define OALTAR 1
#define OTHRONE 2
#define OORB 3
#define OPIT 4
#define OSTAIRSUP 5
#define OELEVATORUP 6
#define OFOUNTAIN 7
#define OSTATUE 8
#define OTELEPORTER 9
#define OSCHOOL 10
#define OMIRROR 11
#define ODNDSTORE 12
#define OSTAIRSDOWN 13
#define OELEVATORDOWN 14
#define OBANK2 15
#define OBANK 16
#define ODEADFOUNTAIN 17
#define OMAXGOLD 70
#define OGOLDPILE 18
#define OOPENDOOR 19
#define OCLOSEDDOOR 20
#define OWALL 21
#define OTRAPARROW 66
#define OTRAPARROWIV 67

#define OLARNEYE 22

#define OPLATE 23
#define OCHAIN 24
#define OLEATHER 25
#define ORING 60
#define OSTUDLEATHER 61
#define OSPLINT 62
#define OPLATEARMOR 63
#define OSSPLATE 64
#define OSHIELD 68
#define OELVENCHAIN 92

#define OSWORDofSLASHING 26
#define OHAMMER 27
#define OSWORD 28
#define O2SWORD 29
#define OSPEAR 30
#define ODAGGER 31
#define OBATTLEAXE 57
#define OLONGSWORD 58
#define OFLAIL 59
#define OLANCE 65
#define OVORPAL 90
#define OSLAYER 91

#define ORINGOFEXTRA 32
#define OREGENRING 33
#define OPROTRING 34
#define OENERGYRING 35
#define ODEXRING 36
#define OSTRRING 37
#define OCLEVERRING 38
#define ODAMRING 39

#define OBELT 40

#define OSCROLL 41
#define OPOTION 42
#define OBOOK 43
#define OCHEST 44             
#define OAMULET 45

#define OORBOFDRAGON 46
#define OSPIRITSCARAB 47
#define OCUBEofUNDEAD 48
#define ONOTHEFT 49

#define ODIAMOND 50
#define ORUBY 51
#define OEMERALD 52
#define OSAPPHIRE 53

#define OENTRANCE 54
#define OVOLDOWN 55
#define OVOLUP 56
#define OHOME 69

#define OKGOLD 71
#define ODGOLD 72
#define OIVDARTRAP 73
#define ODARTRAP 74
#define OTRAPDOOR 75
#define OIVTRAPDOOR 76
#define OTRADEPOST 77
#define OIVTELETRAP 78
#define ODEADTHRONE 79
#define OANNIHILATION 80        /* sphere of annihilation */
#define OTHRONE2 81
#define OLRS 82             /* Larn Revenue Service */
#define OCOOKIE 83
#define OURN 84
#define OBRASSLAMP 85
#define OHANDofFEAR 86      /* hand of fear */
#define OSPHTAILSMAN 87     /* tailsman of the sphere */
#define OWWAND 88           /* wand of wonder */
#define OPSTAFF 89          /* staff of power */
/* used up to 92 */
