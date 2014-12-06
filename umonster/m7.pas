[Inherit('M1', 'M2', 'M3', 'M4', 'M5', 'M6'),
 Environment('M7')]

Module M7;

Const
  B_ROOM = 1; B_PERSON = 2; B_OBJECT = 3; B_SPELL = 4; B_EXIT = 5;
  B_CLASS = 6; B_USER = 7; B_MEMORY = 8;
  MaxBuild = 8;

Var
  BuildTable : Array[1..MaxBuild] Of Short_String_Type := (
    'Room', 'Person', 'Object', 'Spell', 'Exit', 'Class', 'User',
    'Memory');

[External, Hidden]
Procedure ChangeMemory(Var S : String_Type; Where : $UWord);
External;

Function Short(S : String_Type): Short_String_Type;
Begin
  If (S.Length <= 20) Then
    Short := S
  Else Short := SubStr(S, 1, 20);
End;

[Hidden]
Function CanLink(Loc, Dir : $UWord): Boolean;
Var Entity : EntityType; Block : BlockType;
Begin
  If (Dir > 0) Then Begin
    ReadEntity(Loc, Entity);
    Read_Record(FILE_BLOCK, Entity.RoomId, IAddress(Block));
    CanLink := (Block.Room.Exits[Dir] = 0);
  End Else CanLink := True;
End;

[Hidden]
Procedure LinkRooms(ExitId, FromLoc, ToLoc, FromDir, ToDir : $UWord);
Var Entity : EntityType; Block : BlockType;
Begin
  If (FromDir > 0) Then Begin
    ReadEntity(FromLoc, Entity);
    Get_Record(FILE_BLOCK, Entity.RoomId, IAddress(Block));
    Block.Room.Exits[FromDir] := ExitId;
    Update_Record(FILE_BLOCK, Entity.RoomId, IAddress(Block));
  End;
  If (ToDir > 0) Then Begin
    ReadEntity(ToLoc, Entity);
    Get_Record(FILE_BLOCK, Entity.RoomId, IAddress(Block));
    Block.Room.Exits[ToDir] := ExitId;
    Update_Record(FILE_BLOCK, Entity.RoomId, IAddress(Block));
  End;
End;

Function ParsePeopleHere(Var Room : EntityType; Var S : String_Type;
  Var Target : $UWord; SeeHidden, SeeInvisi : Boolean := False): Boolean;
Var Done : Boolean := False; Map : ItemMapType;
Begin
  ParseLine(S, Target, TRUE, FALSE);
  Read_Record(FILE_ITEMMAP, Room.RoomMapId, IAddress(Map));
  While Not Done Do Begin
    ParseMap(Map, 0, POS_IN_ROOM);
    ParseMap(Map, 0, POS_GUARD_N);
    ParseMap(Map, 0, POS_GUARD_S);
    ParseMap(Map, 0, POS_GUARD_E);
    ParseMap(Map, 0, POS_GUARD_W);
    ParseMap(Map, 0, POS_GUARD_U);
    ParseMap(Map, 0, POS_GUARD_D);
    If SeeHidden Then Begin
      ParseMap(Map, 0, POS_HIDDEN);
    End;
    If SeeInvisi Then Begin
      ParseMap(Map, 0, POS_INVISI);
    End;
    If (Map.Next > 0) Then
      Read_Record(FILE_ITEMMAP, Map.Next, IAddress(Map))
    Else Done := True;
  End;
  ParsePeopleHere := ParseLine(S, Target, FALSE, TRUE);
End;

Function ParseObjHere(Var Room : EntityType; Var S : String_Type;
  Var ObjId : $UWord; SeeHidden : Boolean := False): Boolean;
Var Done : Boolean := False; Map : ItemMapType;
Begin
  ParseLine(S, ObjId, TRUE, FALSE);
  Read_Record(FILE_ITEMMAP, Room.RoomMapId, IAddress(Map));
  While Not Done Do Begin
    ParseMap(Map, 0, POS_OBJ_HERE);
    If SeeHidden Then Begin
      ParseMap(Map, 0, POS_OBJ_HIDE);
    End;
    If (Map.Next > 0) Then
      Read_Record(FILE_ITEMMAP, Map.Next, IAddress(Map))
    Else Done := True;
  End;
  ParseObjHere := ParseLine(S, ObjId, FALSE, TRUE);
End;

Procedure Do_Change(Var S : String_Type; Where, MapId : $UWord);
Var Entity : EntityType;
    Block : BlockType;
    Cmd, EntityId : $UWord := 0;

 Procedure ChangeRoom;
 Const
   R_Alias = 1; R_Desc_M = 2; R_Desc_E = 3; R_Desc_Mc = 4; R_Env = 5;
   MaxRoomOpt = 5;
 Var
   RoomOptTable : Array[1..MaxRoomOpt] Of Short_String_Type := (
     'exit alias', 'main description', 'exit description', 'magic description',
     'environment');
   Opt : $UWord := 0;
 Begin
   If GrabEntity('Room name? ', S, EntityId, ENTITY_ROOM) Then Begin
     If GrabTable('Room option? ', RoomOptTable, S, Opt) Then Begin
       ReadEntity(EntityId, Entity);
       Read_Record(FILE_BLOCK, Entity.RoomId, IAddress(Block));
       Case Opt Of
         R_Alias   : PutLine('Not yet implmented. ');
         R_Desc_M  : EditDesc(Block.Room.MainDesc, S);
         R_Desc_E  : EditDesc(Block.Room.ExitDesc, S);
         R_Desc_Mc : EditDesc(Block.Room.MagicDesc, S);
         R_Env     : PutLine('Not yet implmented. ');
       End;
       Update_Record(FILE_BLOCK, Entity.RoomId, IAddress(Block));
     End Else PutLine('Type ? for a list of room options. ');
   End Else PutLine('No such room exist. ');
 End;

 Procedure ChangePerson;
 Begin
   PutLine('Not yet implmented. ');
 End;

 Procedure ChangeSpell;
 Const
   S_Spell_Effect = 1; S_Cast_Effect = 2; S_Flags = 3; S_Power = 4;
   S_Kind = 5; MaxSpellOpt = 5;
 Var
   SpellOptTable : Array[1..MaxSpellOpt] Of Short_String_Type := (
     'target effect', 'caster effect', 'flags', 'power', 'kind');
   Opt : $UWord := 0;

  Procedure GrabSpellFlags;
  Begin
    With Entity Do Begin
      If GrabBoolean('Has area effect(T for true)? ', S) Then
        SpellFlags[SP_AREA_EFF] := True
      Else Begin
        SpellFlags[SP_AREA_EFF] := False;
        If GrabBoolean('Look for personal name(T for true)? ', S) Then
          SpellFlags[SP_GET_PNAME] := True
        Else Begin
          SpellFlags[SP_GET_PNAME] := False;
          If GrabBoolean('Look for object name(T for true)? ', S) Then
            SpellFlags[SP_GET_ONAME] := True
          Else SpellFlags[SP_GET_ONAME] := False;
       End;
     End;
     If GrabBoolean('Look for direction(T for true)? ', S) Then Begin
       SpellFlags[SP_GET_DIR] := True;
       If GrabBoolean('Random direction(T for ture)? ', S) Then
         SpellFlags[SP_RND_DIR] := True
       Else SpellFlags[SP_RND_DIR] := False;
     End Else SpellFlags[SP_GET_DIR] := False;
   End;
 End;

 Begin
   If GrabEntity('Spell name? ', S, EntityId, ENTITY_SPELL) Then Begin
     If GrabTable('Spell option? ', SpellOptTable, S, Opt) Then Begin
       ReadEntity(EntityId, Entity);
       Case Opt Of
         S_Spell_Effect : EditEffect(Entity.SpellEffect, S);
         S_Cast_Effect  : EditEffect(Entity.CastEffect, S);
         S_Flags : GrabSpellFlags;
         S_Power : Entity.Power := GrabNumberW('Power? ', S);
         S_Kind  : If Not GrabTable('Kind? ', SpellKindTable, S,
                   Entity.SpellKind) Then
                     PutLine('Type ? for a list of spell kind. ');
       End;
       Update_Record(FILE_ENTITY, EntityId, IAddress(Entity));
     End Else PutLine('Type ? for a list of spell options. ');
   End Else PutLine('Error parsing spell name. ');
 End;

 Procedure ChangeObject;
 Const
   O_Kind = 1; O_Get_Effect = 2; O_Worn_Effect = 3;
   O_Use_Effect = 4; O_Att_Effect = 5;
   MaxObjOpt = 5;
 Var
   ObjOptTable : Array[1..MaxObjOpt] Of Short_String_Type := (
    'kind', 'get effect', 'worn effect', 'use effect', 'attack effect');
   Opt : $UWord := 0;
   NodeIn : EntityType;
 Begin
   While (S.Length = 0) Do GrabLine('Object name? ', S);
   ReadEntity(Where, NodeIn);
   If ParseObjHere(NodeIn, S, EntityId, TRUE) Then Begin
     If GrabTable('Object option? ', ObjOptTable, S, Opt) Then Begin
       ReadEntity(EntityId, Entity);
       Case Opt Of
         O_Kind : 
           If GrabTable('Object kind? ', ObjKindTable, S, Entity.ObjKind) Then
             PutLine('Done. ')
           Else PutLine('Type ? for a list of object kind.');
         O_Get_Effect  : EditEffect(Entity.GetEffect, S);
         O_Worn_Effect : EditEffect(Entity.WornEffect, S);
         O_Use_Effect  : EditEffect(Entity.UseEffect, S);
         O_Att_Effect  : EditEffect(Entity.AttEffect, S);
       End;
       Update_Record(FILE_ENTITY, EntityId, IAddress(Entity));
     End Else PutLine('Type ? for list of object options. ');
   End Else PutLine('No such object can be seen here. ');
 End;

 Procedure ChangeExit;
 Const
   E_Succ_Desc = 1; E_Fail_Desc = 2; E_In_Desc = 3; E_Out_Desc = 4;
   E_Effect = 5; E_Flags = 6;
   MaxExitOpt = 6;
 Var
   ExitOptTable : Array[1..MaxExitOpt] Of Short_String_Type := (
     'success desc', 'fail desc', 'into room desc',
     'out of room desc', 'pass effect', 'flags');
   EntityLog, Dir, Index, Opt : $UWord := 0;
   AnExit : ExitType;
 Begin
   If GrabEntity('Room? ', S, EntityLog, ENTITY_ROOM) Then Begin
     If GrabTable('Exit direction? ', DirTable, S, Dir) Then Begin
       ReadEntity(EntityLog, Entity);
       ReadBlock(Entity.RoomId, Block);
       If (Block.Room.Exits[Dir] > 0) Then Begin
         Read_Record(FILE_EXIT, Block.Room.Exits[Dir], IAddress(AnExit));
         If (AnExit.Node[1] = EntityLog) And (AnExit.Dire[1] = Dir) Then
           Index := 1
         Else Index := 2;  (* cross my finger.. *)
         If GrabTable('Exit option? ', ExitOptTable, S, Opt) Then Begin
           Case Opt Of
             E_Succ_Desc : EditDesc(AnExit.SuccDesc[Index], S);
             E_Fail_Desc : EditDesc(AnExit.FailDesc[Index], S);
             E_In_Desc   : EditDesc(AnExit.InDesc[Index], S);
             E_Out_Desc  : EditDesc(AnExit.OutDesc[Index], S);
             E_Effect    : EditEffect(AnExit.Effect, S);
             E_Flags     : PutLine('Not yet implemented. ');
           End;
           Update_Record(FILE_EXIT, Block.Room.Exits[Dir], IAddress(AnExit));
         End Else PutLine('Type ? for a list of exit options. ');
       End Else PutLine('There is no exit at that direction. ');
     End Else PutLine('error parsing direction. ');
   End Else PutLine('There is no such room. ');
 End;

 Procedure ChangeClass;
 Const
   C_Homeroom = 1; C_Group = 2; C_Effect = 3; MaxClassOpt = 3;
 Var
   ClassOptTable : Array[1..MaxClassOpt] Of Short_String_Type := (
     'Homerooom', 'Group', 'Class effect');
   ClassId, Opt : $UWord := 0;
 Begin
   If GrabEntity('Class? ', S, ClassId, ENTITY_CLASS) Then Begin
     If GrabTable('Class option? ', ClassOptTable, S, Opt) Then Begin
       ReadEntity(ClassId, Entity);
       Case Opt Of
         C_Homeroom : If Not GrabEntity('Homeroom? ', S, Entity.Homeroom,
             ENTITY_ROOM) Then PutLine('Error parsing home room name. ');
         C_Group    : Entity.Group := GrabNumberW('Group? ', S);
         C_Effect   : EditEffect(Entity.ClassEffect, S);
       End;
       Update_Record(FILE_ENTITY, ClassId, IAddress(Entity));
     End Else PutLine('Type ? for a list of class option. ');
   End Else PutLine('No such class. ');
 End;

Begin
  If GrabTable('Change what? ', BuildTable, S, Cmd) Then
    Case Cmd Of
      B_ROOM   : ChangeRoom;
      B_PERSON : ChangePerson;
      B_SPELL  : ChangeSpell;
      B_OBJECT : ChangeObject;
      B_EXIT   : ChangeExit;
      B_CLASS  : ChangeClass;
      B_USER   : PutLine('Not yet implemented. ');
      B_MEMORY : ChangeMemory(S, Where);
    End
  Else PutLine('Type ? for list of command. ');
End;

Procedure Do_Create(Var S : String_Type; Where, MapId : $UWord);
Var Cmd : $UWord := 0;
    ExitId, EntityLog : $UWord := 0;
    FromLoc, ToLoc, FromDir, ToDir : $UWord := 0;
    NameStr : Short_String_Type;

 Procedure DoCreateExit;
 Begin
   If GrabEntity('Exit from? ', S, FromLoc, ENTITY_ROOM) Then Begin
     If GrabEntity('Exit to? ', S, ToLoc, ENTITY_ROOM) Then Begin
       If Not GrabTable('From direction? ', DirTable, S, FromDir) Then
         FromDir := 0;
       If CanLink(FromLoc, FromDir) Then Begin
         If Not GrabTable('To direction? ', DirTable, S, ToDir) Then
           ToDir := 0;
         If CanLink(ToLoc, ToDir) Then Begin
           If CreateExit(ExitId, FromLoc, ToLoc, FromDir, ToDir) Then Begin
             LinkRooms(ExitId, FromLoc, ToLoc, FromDir, ToDir);
             PutLine('Exit created. ');
           End;
         End Else PutLine('Exit already exist in second room. ');
       End Else PutLine('Exit already exist in first room. ');
     End Else PutLine('Second room not found. ')
   End Else PutLine('First room not found. ');
 End;

 Procedure DoCreateEntity;
 Begin
   While S.Length = 0 Do GrabLine('Name? ', S);
   NameStr := Short(S);
   S := '';
   Case Cmd Of
     B_ROOM :
       If CreateRoom(NameStr, EntityLog) Then
         PutLine('Room created. ')
       Else PutLine('Room creation failed. ');
     B_PERSON :
       If CreatePerson(NameStr, EntityLog, 0, 0, Where, MapId) Then
         PutLine('Person created. ')
       Else PutLine('Person creation failed. ');
     B_OBJECT :
       If CreateObject(NameStr, EntityLog, Where, MapId) Then
         PutLine('Object created. ')
       Else PutLine('Object creation failed. ');
     B_SPELL :
       If CreateSpell(NameStr, EntityLog) Then
         PutLine('Spell created. ')
       Else PutLine('Spell creation failed. ');
     B_CLASS :
       If CreateClass(NameStr, EntityLog) Then
         PutLine('Class created. ')
       Else PutLine('Class creation failed. ');
   End  (* case *)
 End;

 Procedure DoCreateMemory;
 Var NodeIn : EntityType;
 Begin
   ReadEntity(Where, NodeIn);
   If (S.Length = 0) Then GrabLine('Person name? ', S);
   If ParsePeopleHere(NodeIn, S, EntityLog) Then Begin
     If CreateMemory(EntityLog) Then
       PutLine('Done. ')
     Else PutLine('Create memory failed. ');
   End Else PutLine('No such person can be seen here. ');
 End;

Begin
  If GrabTable('Create what? ', BuildTable, S, Cmd) Then
    Case Cmd Of
      B_ROOM, B_PERSON, B_OBJECT, B_SPELL, B_CLASS : DoCreateEntity;
      B_EXIT   : DoCreateExit;
      B_USER   : PutLine('Use force and play commands at Start> prompt. ');
      B_MEMORY : DoCreateMemory;
    End
  Else PutLine('Type ? for a list of create options. ');
End;

Procedure ListExits;
Var Allocation : Alloc_Record_Type;
    AnExit : ExitType;
    FromRoom, ToRoom : EntityType;
    FromDir, ToDir : Short_String_Type;
    L : String_Type;
    I : Integer;
Begin
  PutLine(DivLine+DivLine);
  Read_Record(FILE_ALLOC, ALLOC_EXIT, IAddress(Allocation));
  For I := 1 To Allocation.Topused Do
    If (Not Allocation.Free[I]) Then Begin
      ReadExit(I, AnExit);
      If AnExit.Node[1] > 0 Then
        ReadEntity(AnExit.Node[1], FromRoom)
      Else FromRoom.Name := 'Void';
      If AnExit.Node[2] > 0 Then
        ReadEntity(AnExit.Node[2], ToRoom)
      Else ToRoom.Name := 'Void';
      If AnExit.Dire[1] > 0 Then
        FromDir := DirTable[AnExit.Dire[1]]
      Else FromDir := '';
      If AnExit.Dire[2] > 0 Then
        ToDir := DirTable[AnExit.Dire[2]]
      Else ToDir := '';
      WriteV(L, 'Exit ', I:5, ': ', PadStr(FromRoom.Name, 20), ' ',
      PadStr(FromDir, 6), ' ', PadStr(ToRoom.Name, 20), ' ', PadStr(ToDir, 6));
      PutLine(L);
    End;
  PutLine(DivLine+DivLine);
End;

Procedure Do_List(Var S : String_Type);
Var Cmd : $UWord := 0;
Begin
  If GrabTable('List what? ', BuildTable, S, Cmd) Then
    Case Cmd Of
      B_ROOM   : PrintEntityNames(ENTITY_ROOM);
      B_PERSON : PrintEntityNames(ENTITY_PERSON);
      B_OBJECT : PrintEntityNames(ENTITY_OBJECT);
      B_SPELL  : PrintEntityNames(ENTITY_SPELL);
      B_CLASS  : PrintEntityNames(ENTITY_CLASS);
      B_EXIT   : ListExits;
      B_USER   : PrintUsernames;
      B_MEMORY : PutLine('Not yet implemented. ');
    End
  Else PutLine('Type ? for a list of list options. ');
End;

Procedure Do_Show(Var S : String_Type);
Begin
  PutLine('Not yet implmented. ');
End;

Procedure Do_Quota(Var S : String_Type);
Const
  C_Show = 1; C_Increase = 2; C_Decrease = 3; C_Set = 4; C_Quit = 5;
  C_Print = 6;
  MaxCmd = 6;
Var
  CmdTable : Array[1..MaxCmd] Of Short_String_Type := (
    'Show', 'Increase', 'Decrease', 'Set', 'Quit', 'Print');
  Cmd, Opt : $UWord := 0;
  Done : Boolean := False;

 Procedure DoIncAlloc;
 Var Amount : $UWord;
 Begin
   Amount := GrabNumberW('Increase by how much? ', S);
   If Amount > 0 Then
     Case Opt Of
       ALLOC_SAY     : IncSayQuota(Amount);
       ALLOC_USER    : IncUserQuota(Amount);
       ALLOC_LINE    : IncLineQuota(Amount);
       ALLOC_ENTITY  : IncEntityQuota(Amount);
       ALLOC_ITEMMAP : IncItemMapQuota(Amount);
       ALLOC_BLOCK   : IncBlockQuota(Amount);
       ALLOC_EXIT    : IncExitQuota(Amount);
       ALLOC_EFFECT  : IncEffectQuota(Amount);
       ALLOC_MEMORY  : IncMemoryQuota(Amount);
     End
   Else PutLine('Quota unchanged. ');
 End;

Begin
  While Not Done Do Begin
    If GrabTable('Quota> ', CmdTable, S, Cmd) Then Begin
      If (Cmd = C_Quit) Then
        Done := True
      Else If (Cmd = C_Show) Then
        Show_Alloc
      Else Begin
        If GrabTable('Allocation item? ', Allocnames, S, Opt) Then
          Case Cmd Of
            C_Increase : DoIncAlloc;
            C_Print    : Print_Alloc(Opt);
            C_Decrease : PutLine('Not yet implemented. ');
            C_Set      : PutLine('Not yet implemented. ');
          End
        Else PutLine('Type ? for a list of allocation item. ');
      End;
    End Else PutLine('Type ? for a list of quota command. ');
  End;
End;

Procedure Do_Build(Var NodeIn : EntityType; Var S : String_Type;
   Where : $UWord);
Const
  C_CHANGE = 1; C_CREATE = 2; C_DELETE = 3; C_QUIT = 4; C_LIST = 5; 
  C_SHOW = 6; C_QUOTA = 7;
  MaxCmd = 7;
Var
  CmdTable : Array[1..MaxCmd] Of Short_String_Type := (
    'Change', 'Create', 'Delete', 'Quit', 'List', 'Show', 'Quota');
  Cmd : $UWord := 0;
  Done : Boolean := False;
Begin
  If FAST_MODE Then PutLine('Fast mode is on, be careful. ');
  While Not Done Do Begin
    If GrabTable('Build> ', CmdTable, S, Cmd) Then
      Case Cmd Of
        C_CHANGE : Do_Change(S, Where, NodeIn.RoomMapId);
        C_CREATE : Do_Create(S, Where, NodeIn.RoomMapId);
        C_DELETE : PutLine('Not yet implmented. ');
        C_QUIT   : Done := True;
        C_LIST   : Do_List(S);
        C_SHOW   : Do_Show(S);
        C_QUOTA  : Do_Quota(S);
      End
    Else PutLine('Type ? for a list of build commands. ');
  End;
End;

End.
