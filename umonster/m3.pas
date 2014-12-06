[Inherit('M1', 'M2'),
 Environment('M3')]

Module M3;

Const
  MaxExitFlag = 32;

  NORTH = 1;
  SOUTH = 2;
  WEST  = 3;
  EAST  = 4;
  UP    = 5;
  DOWN  = 6;
  MaxRoomExits = 6;

  ROOM_ENV_SHOP = 1;
  ROOM_ENV_SANC = 2;
  MaxRoomEnv = 64;

  MaxActPoints = 10;

  MaxNpcSaying = 10;

  ATT_STR = 1;
  ATT_INT = 2;
  ATT_WIS = 3;
  ATT_CHA = 4;
  ATT_DEX = 5;
  ATT_CON = 6;
  MaxPersonAttri = 6;

  STAT_R_FIRE = 1;
  STAT_R_COLD = 2;
  STAT_R_ELEC = 3;
  STAT_R_ACID = 4;
  STAT_DEFEND = 5;
  STAT_WORN_ARMOR = 5;
  MaxPersonStats = 64;

  OBJ_WEAPON = 1;
  OBJ_ARMOR  = 2;
  MaxObjKind = 2;

  SP_GET_PNAME = 1;
  SP_GET_ONAME = 2;
  SP_GET_MSG   = 3;
  SP_GET_DIR   = 4;
  SP_AREA_EFF  = 5;
  SP_RND_DIR   = 6;
  MaxSpellFlags = 8;

  SPELL_NORMAL = 1;
  SPELL_INFORM = 2;
  MaxSpellKind = 2;

  ItemMapSize = 20;

  ENTITY_ROOM = 1;
  ENTITY_PERSON = 2;
  ENTITY_OBJECT = 3;
  ENTITY_SPELL = 4;
  ENTITY_CLASS = 5;
  MaxEntityKind = 5;

  POS_IN_ROOM  = 1;  (* people in room *)
  POS_HIDDEN   = 2;
  POS_INVISI   = 3;
  POS_GUARD_S  = 4;
  POS_GUARD_N  = 5;
  POS_GUARD_W  = 6;
  POS_GUARD_E  = 7;
  POS_GUARD_U  = 8;
  POS_GUARD_D  = 9;
  POS_INVEN    = 10;  (* obj hold        *)
  POS_ARMOR    = 11;  (* weapon wield    *)
  POS_WEAPON   = 12;  (* armor wield     *)
  POS_OBJ_HERE = 13;  (* object in room  *)
  POS_OBJ_SALE = 14;  (* object for sale *)
  POS_OBJ_HIDE = 15;  (* object hidden   *)
  MaxPos = 15;

  ADD = 1;
  DELETE = 2;

  MaxLevel = 41;

  GLOB_LOCATION = 65535;
  ALL_TARGET = 65535;

  EV_INFORM = 1;
  EV_MOVE_IN = 2;
  EV_MOVE_OUT = 3;
  EV_MOVE_FAIL = 4;
  EV_ATTACK = 5;
  EV_HEALTH = 6;
  EV_KILLED = 7;
  EV_SAY = 8;
  EV_CAST = 9;
  EV_FREEZE = 10;
  EV_TELEPORT = 11;

  MaxEnemies = 5;
  MaxActivePlayer = 100;

Type
  (*  Npc saying  *)
  NpcSayType = Record
    KeyWord : String_Type;
    Saying  : String_Type;
  End;

  (*  user type  *)
  User_Type = Record
    Username  : Short_String_Type;
    ProcessId : Unsigned;
    EntityLog : $UWord;
    Enemies   : Array[1..MaxEnemies] Of $UWord;
    IsPlaying : Boolean;
  End;

  (*  Description Pointer Type  *)
  DescPtr_Type = Record
    Start, Finish : $UWord;
  End;

  LineType = Record
    Body : String_Type;
  End;

  (*  Effect Pointer Type  *)
  EffPtr_Type = Record
    FromEff, ToEff : $UWord;
  End;

  (* Effect Type *)
  Effect_Type = Record
    Effect : $UWord;
    Parm1, Parm2 : $UWord;
  End;

  (*  Entity Type  *)
  EntityType = Record
    Name   : Short_String_Type;   (* my name! *)
    EntityKind : $UWord;          (* what kind of entity am I? *)
    Case Integer Of
      ENTITY_ROOM:
        (RoomId    : $UWord;
         RoomMapId : $UWord);
      ENTITY_PERSON:
        (Owner    : $UWord;
         Driver   : $UWord;
         PersonId : $UWord;
         InvenId  : $UWord;
         MemoryId : $UWord);
      ENTITY_OBJECT:
        (ObjKind    : $UWord;
         GetEffect  : EffPtr_Type;
         WornEffect : EffPtr_Type;
         UseEffect  : EffPtr_Type;
         AttEffect  : EffPtr_Type);
      ENTITY_SPELL:
        (SpellEffect : EffPtr_Type;
         CastEffect  : EffPtr_Type;
         SpellFlags  : Packed Array[1..MaxSpellFlags] Of Boolean;
         Power       : $UWord;
         Spellkind   : $UWord);
      ENTITY_CLASS:
        (Homeroom    : $UWord;
         Group       : $UWord;
         ClassEffect : EffPtr_Type);
  End;

  (*  Exit Type  *)
  ExitType = Record
    Node : Array[1..2] Of $UWord;
    Dire : Array[1..2] Of $UByte;
    SuccDesc : Array[1..2] Of DescPtr_Type;
    FailDesc : Array[1..2] Of DescPtr_Type;
    InDesc   : Array[1..2] Of DescPtr_Type;  (* into the room desc *)
    OutDesc  : Array[1..2] Of DescPtr_Type;  (* out of room desc *)
    Effect   : EffPtr_Type;
    ExitFlag : Packed Array[1..MaxExitFlag] Of Boolean;
  End;

  (*  Room Type  *)
  RoomType = Record
    GoldHere  : Integer;
    RoomClass : $UWord;
    NameDis   : $UByte;
    MainDesc  : DescPtr_Type;
    ExitDesc  : DescPtr_Type;
    MagicDesc : DescPtr_Type;
    ExitAlias : Short_String_Type;
    AliasDir  : $UByte;
    Exits : Array[1..MaxRoomExits] Of $UWord;
    Env : Packed Array[1..MaxRoomEnv] Of Boolean;
  End;

  (*  Memory Type *)
  ActPointsType = Record
    Where : $UWord;
    Position : $UByte;   (* My favorite position *)
    Action   : $UByte;   (* Act like I'm real *)
    RunAct   : $UByte;   (* What do I do when I'm chased? *)
    OutDir   : $UByte;   (* Don't go this way! I might get lost *)
  End;

  MemoryType = Record
    BaseExp, BaseGold : Integer;
    Kills, Killed : Integer;
    ActPoints : Array[1..MaxActPoints] Of ActPointsType;
    NpcSaying : Array[1..MaxNpcSaying] Of $UWord;
  End;

  (*  Person Type  *)
  PersonType = Record
    Group, Class, Home : $UWord;
    Exp, Gold : Integer;
    Level, Health, Mana : $UWord;
    Weapon : $UWord;         (* hack for faster game *)
    ArmorClass : $UWord;
    ActionDelay : $UWord;    (* Freeze! *)
    LastAct  : $UQuad;
    LastHeal : $UQuad;
    Stats : Packed Array[1..MaxPersonStats] Of Boolean;
    Attributes : Array[1..MaxPersonAttri] Of $Word;
    MaxHealth, MaxMana, MaxSpeed : $Word;
  End;

  (*  Item Map Type  *)
  ItemMapType = Record
    Ids  : Packed Array[1..ItemMapSize] Of $UWord;
    Pos  : Packed Array[1..ItemMapSize] Of $UByte;
    Next : $UWord;
  End;

  (*  Block Type  *)
  BlockType = Record
    Case Integer Of
      1: (Room : RoomType);
      2: (Person : PersonType);
  End;

Var
  FAST_MODE : Boolean := False;

  DirTable : [ReadOnly] Array[1..MaxRoomExits] Of Short_String_Type := (
    'north', 'south', 'west', 'east', 'up', 'down');

  RevDirTable : [ReadOnly] Array[1..MaxRoomExits] Of Short_String_Type := (
    'South', 'North', 'East', 'West', 'Down', 'Up');

  PersonAttritable : [ReadOnly] Array[1..MaxPersonAttri] Of Short_String_Type := (
    'Strength', 'Intelligence', 'Wisdom', 'Charisma', 'Dexterity',
    'Constitution');

  EntityKindTable : [ReadOnly] Array[1..MaxEntityKind] Of Short_String_Type := (
    'Room', 'Person', 'Object', 'Spell', 'Class');

  ObjKindTable : [ReadOnly] Array[1..MaxObjKind] Of Short_String_Type := (
    'Weapon', 'Armor');

  SpellKindTable : [ReadOnly] Array[1..MaxSpellKind] Of Short_String_Type := (
    'Normal', 'Inform');

  PosTable : [ReadOnly] Array[1..MaxPos] Of Short_String_Type := (
    'People in room', 'Hidden',          'Invisible',
    'Guardian South', 'Guardian North',  'Guardian West',
    'Guardian East',  'Guardian Up',     'Guardian Down',
    'Inventory',      'Armor',           'Weapon', 
    'Object in room', 'Object for sale', 'Object hidden'
    );

  LevelExpTable : [ReadOnly] Array[1..MaxLevel] Of Integer := (
    12,        20,        34,        58,        100,
    170,       290,       490,       840,       1240,
    2100,      3600,      6000,      10200,     16200,
    27000,     42000,     72000,     120000,    200000,
    340000,    580000,    1000000,   1800000,   3200000,
    5000000,   7000000,   10500000,  14000000,  20000000,
    30000000,  42000000,  56000000,  80000000,  110000000,
    150000000, 200000000, 280000000, 400000000, 600000000,
    1200000000
    );

  AddTable : [ReadOnly] Array[1..2] Of Short_String_Type := (
    'Add', 'Delete');

  The_Great_Beginning : $UWord := 1;

  InPlay : Boolean := False;

  MyUserLog : $UWord := 0;
  MyUserId  : Short_String_Type := '';

End.
