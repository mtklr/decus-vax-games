/* set object properties */
/* { itemchar, damage, weight, wearable, combine, magic, cost } */
int ITEM_PROPS[MAXOBJECTS][MAXQUALIF] = {  
   { HANDS, 1,  0, 0, 0, 0, 0 },      
   {  HAXE, 4,  70, 1, 0, 0, 100 },
   {   AXE, 8,  110, 1, 0, 0, 300 },
   { ARROW, 2,  8, 0, 1, 0, 10 },   
   { SWORD, 3,  50, 1, 0, 0, 50 },
   { LSWORD, 6,  70, 1, 0, 0, 200 }, 
   {   BOW, 2,  50, 1, 0, 0, 200 },
   { ARMOR, 10, 200, 1, 0, 0, 300 },
   { SCROLL, 0, 5, 0, 1, 1, 60 },
   { HEALTH, -20, 5, 0, 1, 0, 100 },
   { POTION, 0, 10, 0, 1, 0, 100 }, 
   {  ORB, 15, 10, 0, 0, 1, 1000 },
   { MINE, 15, 50, 0, 1, 0, 15 },
/* the following objects are only defined for viewing purposes */
   {  KEY, 0, 0, 0, 0, 0, 0 },     
   { CASH, 0, 0, 0, 0, 0, 0 },
   { DOOR, 0, 0, 0, 0, 0, 0 },
   { STORE, 0, 0, 0, 0, 0, 0 },
   { ARENA, 0, 0, 0, 0, 0, 0 },
   { BONES, 0, 0, 0, 0, 0, 0 },
   { BRIDGE, 0, 0, 0, 0, 0, 0 },
   { BRIDGE2, 0, 0, 0, 0, 0, 0 },
   { WATER, 0, 0, 0, 0, 0, 0 },
   { PIT, 0, 0, 0, 0, 0, 0 }
};


char *spells[SPELLNAMES] = {
   "lightning bolt",
   "fireball",
   "ball of acid",
   "word of destruction",
   "confuse monster",
   "teleport self"
};


char *deaths[] = {
    "shrivels up into a greasy black pile of ash and dies",
    "pays the debt which cancels all others",
    "kicks the bucket","meets his maker","is knocking at the pearly gates",
    "dies"
};


char *object_names[] = {
    "hands",
    "hand axe",
    "two-hand axe",
    "arrow",
    "short sword",
    "longsword",
    "longbow",
    "chain mail armor",
    "*magic* scroll",
    "healing salve",
    "potion",
    "magic orb",
    "exploding mine",
    "key to freedom",
    "few gold pieces",
    "exit up to the next level",
    "store entrance",
    "arena entrance",
    "small pile of bones",
    "bridge across raging rapids",
    "bridge across raging rapids",
    "section of raging rapids",
    "deep dark pit"
};


char *mon_names[] = {
    "the giant ant",
    "the berserker","the clam","the dragon","the earth slime","the flagorian",
    "the grey ghost","the Harpy","the insect","the strawberry jelly",
    "<unknown>","the Verxis","the warthog","the Xourn","Your Mother",
    "the Zumbasu","a troll","itsy and bitsy","Vorpal bunnies",
    "the Dancing Sword","the jabberwock","Dan English","Phil Kilinskas",
    "the relska bottle","Aralu himself"
};

char *attacks[] = {
    "crawls on you","tears your flesh off","spits on you",
    "summons lightning","slimes you","kicks you","bites you",
    "turns you to stone","hits you","slimes you","sends you to Limbo",
    "takes your soul","gores you","kicks you","sends you to your room",
    "spears you","clubs you","give you the finger","nip at your heels",
    "hacks you to bits","bites you","blinks at you","steals your password",
    "makes you sick","sends you to Hell"
};

char *monfire[] = {
    "spits at you","throws a spear at you","scorches you with flames",
    "covers you in ooze","hits you with a firebolt","throws a dagger at you",
    "pukes on you","vaporizes your helpless body"
};


char *errors[] = {
    NULL,
    "error creating windows",
    "can't open screen file",
    "can't close screen file",
    "no player position in screen file",
    "no ending to screen file",
    "error writing to windows",
    "successful end game",
    "error - Usage:  aralu [-csm]",
    "score file created",
    "error opening savefile",
    "error opening scorefile",
    "only superuser can do this",
    "game saved",
    "level gained",
    "error writing to savefile",
    "data corruption - illegal syntax",		/* let them figure it out */
    "error reading from savefile",
    "no savefile present",
    "error writing to scorefile",
    "error reading scorefile",
    "error opening monster datafile"
};
