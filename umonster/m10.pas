[Inherit('M1','M2','M3','M4','M5','M6','M7','M7_2',
         'M7_3','M9'),
 Environment('M10')]

Module M10;

Var
  Brief : Boolean := False;

[Hidden]
Function IcanAct(Var S : String_Type; Var Me : EntityType;
  Var PersonBlk : BlockType): Boolean;
Begin
  ReadEntity(MyEntityId, Me);
  Read_Record(FILE_BLOCK, Me.PersonId, IAddress(PersonBlk));
  If (PersonBlk.Person.Health = 0) Then Begin
    IcanAct := False;
    S := '';
    PutLine('You are dead! ');
  End Else IcanAct := True;
End;

[Hidden]
Function ParseEntityHere(Var NodeIn : EntityType; Var S : String_Type;
  Var Target : $UWord): Boolean;
Var Done, SeeHidden, SeeInvisi : Boolean := False;
    Map : ItemMapType;
Begin
  SeeHidden := IsWindy;
  SeeInvisi := IsWindy;
  ParseLine(S, Target, TRUE, FALSE);
  Read_Record(FILE_ITEMMAP, NodeIn.RoomMapId, IAddress(Map));
  While Not Done Do Begin
    ParseMap(Map, 0, POS_IN_ROOM);
    ParseMap(Map, 0, POS_OBJ_HERE);
    ParseMap(Map, 0, POS_GUARD_N);
    ParseMap(Map, 0, POS_GUARD_S);
    ParseMap(Map, 0, POS_GUARD_E);
    ParseMap(Map, 0, POS_GUARD_W);
    ParseMap(Map, 0, POS_GUARD_U);
    ParseMap(Map, 0, POS_GUARD_D);
    If SeeHidden Then Begin
      ParseMap(Map, 0, POS_HIDDEN);
      ParseMap(Map, 0, POS_OBJ_HIDE);
    End;
    If SeeInvisi Then Begin
      ParseMap(Map, 0, POS_INVISI);
    End;
    If (Map.Next > 0) Then
      Read_Record(FILE_ITEMMAP, Map.Next, IAddress(Map))
    Else Done := True;
  End;
  ParseEntityHere := ParseLine(S, Target, FALSE, TRUE);
End;

[Hidden]
Function ParseHold(Var Entity : EntityType; Var S : String_Type;
  Var ObjId : $UWord): Boolean;
Var Done : Boolean := False;
    Map : ItemMapType;
Begin
  ParseLine(S, ObjId, TRUE, FALSE);
  Read_Record(FILE_ITEMMAP, Entity.InvenId, IAddress(Map));
  While Not Done Do Begin
    ParseMap(Map, 0, POS_INVEN);
    If (Map.Next > 0) Then
      Read_Record(FILE_ITEMMAP, Map.Next, IAddress(Map))
    Else Done := True;
  End;
  ParseHold := ParseLine(S, ObjId, FALSE, TRUE);
End;

[Hidden]
Function ParseEquip(Var Entity : EntityType; Var S : String_Type;
  Var ObjId : $UWord): Boolean;
Var Done : Boolean := False;
    Map : ItemMapType;
Begin
  ParseLine(S, ObjId, TRUE, FALSE);
  Read_Record(FILE_ITEMMAP, Entity.InvenId, IAddress(Map));
  While Not Done Do Begin
    ParseMap(Map, 0, POS_WEAPON);
    ParseMap(Map, 0, POS_ARMOR);
    If (Map.Next > 0) Then
      Read_Record(FILE_ITEMMAP, Map.Next, IAddress(Map))
    Else Done := True;
  End;
  ParseEquip := ParseLine(S, ObjId, FALSE, TRUE);
End;


(* command functions *)

Procedure Do_Attack(Var NodeIn : EntityType; Var S : String_Type);
Var Entity, TargEntity : EntityType;
    PersonBlk : BlockType;
   Target : $UWord;
Begin
  If IcanAct(S, Entity, PersonBlk) Then Begin
    If ParseEntityHere(NodeIn, S, Target) Then Begin
      ReadEntity(Target, TargEntity);
      If (TargEntity.EntityKind = ENTITY_PERSON) Then Begin
        AttackPerson(Entity, TargEntity, NodeIn, PersonBlk, MyEntityId,
        Target, MyLocation, TRUE);
      End Else PutLine('You want to attack what? ');
    End Else PutLine('No such person can be seen here. ');
  End;
End;

Procedure Do_Block(Var NodeIn : EntityType; Var S : String_Type);
Var Entity : EntityType;
    PersonBlk : BlockType;
    Dir, NewPos, Guardian : $UWord := 0;

 Procedure SetNewPos;
 Begin
   Case Dir Of
     NORTH : NewPos := POS_GUARD_N;
     SOUTH : NewPos := POS_GUARD_S;
     WEST  : NewPos := POS_GUARD_W;
     EAST  : NewPos := POS_GUARD_E;
     UP    : NewPos := POS_GUARD_U;
     DOWN  : NewPos := POS_GUARD_D;
   End;
 End;

Begin
  If IcanAct(S, Entity, PersonBlk) Then Begin
    If (S.Length = 0) Then Begin
      If (MyPosition=POS_GUARD_N) Or (MyPosition=POS_GUARD_S) Or
      (MyPosition=POS_GUARD_W) Or (MyPosition=POS_GUARD_E) Or
      (MyPosition=POS_GUARD_U) Or (MyPosition=POS_GUARD_D) Then Begin
        ChangeMapPos(MyEntityId, MyLocation, NodeIn.RoomMapId, POS_IN_ROOM);
        PutLine('You are no longer blocking the exit. ');
      End Else PutLine('You are not blocking any exit. ');
    End Else If ParseTable(DirTable, S, Dir) Then Begin
      If (Not LookUpMap(Guardian, NodeIn.RoomMapId, 0, FALSE, TRUE, NewPos))
      Then Begin
        SetNewPos;
        ChangeMapPos(MyEntityId, MyLocation, NodeIn.RoomMapId, NewPos);
        PutLine('You are now blocking '+DirTable[Dir]+' exit! ');
      End Else If (Guardian = MyEntityId) Then
        PutLine('You are blocking that exit! ')
      Else PutLine('Someone else already blocked '+DirTable[Dir]+' exit. ');
    End Else PutLine('you can''t block that. ');
  End;
End;

Procedure Do_Cast(Var NodeIn : EntityType; Var S : String_Type);
Var Entity, Spell : EntityType;
    PersonBlk : BlockType;
    SpellId, Target, Dir : $UWord := 0;
    Continue : Boolean := True;
Begin
  If IcanAct(S, Entity, PersonBlk) Then Begin
    If GrabEntity('Spell? ', S, SpellId, ENTITY_SPELL) Then Begin
      ReadEntity(SpellId, Spell);
      If Not HaveEffect(Spell.CastEffect, Entity, PersonBlk, TRUE, FALSE)
      Then Begin
        If (Spell.SpellFlags[SP_GET_DIR]) And (Spell.Power > 0) Then Begin
          If S.Length = 0 Then GrabLine('Direction? ', S);
          Continue := ParseTable(DirTable, S, Dir);
        End;
        If (Spell.SpellFlags[SP_AREA_EFF]) Then
          Target := ALL_TARGET
        Else If (Spell.SpellFlags[SP_GET_PNAME]) Then Begin
          If (Spell.SpellFlags[SP_GET_DIR]) And (Spell.Power > 0) Then Begin
            If S.Length = 0 Then GrabLine('At who? ', S);
            Continue := ParsePeopleHere(NodeIn, S, Target, IsWindy, IsWindy)
          End Else Continue := GrabEntity('At who? ', S, Target, ENTITY_PERSON);
        End Else If (Spell.SpellFlags[SP_GET_ONAME]) Then Begin
          If (Spell.SpellFlags[SP_GET_DIR]) And (Spell.Power > 0) Then Begin
            If S.Length = 0 Then GrabLine('At what? ', S);
            Continue := ParseObjHere(NodeIn, S, Target, IsWindy);
          End Else Continue := GrabEntity('At what? ', S, Target, ENTITY_OBJECT);
        End;
        If Continue Then Begin
          CastSpell(Entity, NodeIn, Spell, PersonBlk, MyEntityId, MyLocation,
          SpellId, Target, Dir, TRUE);
        End Else PutLine(Spell.Name+' fizzled. ');
      End;
    End Else PutLine('I don''t remember that spell. ');
  End;
End;

Procedure Do_Defend(Var S : String_Type);
Var Entity : EntityType;
    PersonBlk : BlockType;
Begin
  If IcanAct(S, Entity, PersonBlk) Then Begin
    Get_Record(FILE_BLOCK, Entity.PersonId, IAddress(PersonBlk));
    PersonBlk.Person.Stats[STAT_DEFEND] := Not
    PersonBlk.Person.Stats[STAT_DEFEND];
    Update_Record(FILE_BLOCK, Entity.PersonId, IAddress(PersonBlk));
    If (PersonBlk.Person.Stats[STAT_DEFEND]) Then
      PutLine('You are now in defensive mode. ')
    Else PutLine('You are no longer in defensive mode. ');
  End;
End;

Procedure Do_Drop(Var NodeIn : EntityType; Var S : String_Type);
Var Entity : EntityType;
    PersonBlk : BlockType;
    ObjId : $UWord := 0;
    S1 : String_Type;
Begin
  If IcanAct(S, Entity, PersonBlk) Then Begin
    If (S.Length = 0) Then GrabLine('drop what? ', S);
    S1 := S;
    If ParseHold(Entity, S1, ObjId) Then Begin
      S := S1;
      DropObj(Entity, NodeIn, PersonBlk, MyEntityId, MyLocation, ObjId, TRUE);
    End Else If ParseEquip(Entity, S, ObjId) Then
      PutLine('You must take it off first. ')
    Else PutLine('You are not holding such object. ');
  End;
End;

Procedure Do_DropGold(Var NodeIn : EntityType; Var S : String_Type);
Var Entity : EntityType;
    PersonBlk, RoomBlk : BlockType;
    Amount : Integer;
Begin
  If IcanAct(S, Entity, PersonBlk) Then Begin
    Amount := GrabNumberI('How much? ', S);
    If (Amount > 0) Then Begin
      DropGold(Entity, NodeIn, PersonBlk, RoomBlk, MyEntityId, 
      MyLocation, Amount, TRUE, IsWindy);
    End Else PutLine('ok. ');
  End;
End;

Procedure Do_Get(Var NodeIn : EntityType; Var S : String_Type);
Var Entity : EntityType;
    PersonBlk : BlockType;
    ObjId : $UWord := 0;
Begin
  If IcanAct(S, Entity, PersonBlk) Then Begin
    If (S.Length = 0) Then GrabLine('get what? ', S);
    If ParseObjHere(NodeIn, S, ObjId, IsWindy) Then Begin
      GetObj(Entity, NodeIn, PersonBlk, MyEntityId, MyLocation, ObjId, TRUE);
    End Else PutLine('No such object can be seen here. ');
  End;
End;

Procedure Do_GetGold(Var NodeIn : EntityType; Var S : String_Type);
Var Entity : EntityType;
    PersonBlk, RoomBlk : BlockType;
    Amount : Integer;
Begin
  If IcanAct(S, Entity, PersonBlk) Then Begin
    Amount := GrabNumberI('How much? ', S);
    If (Amount > 0) Then Begin
      GetGold(Entity, NodeIn, PersonBlk, RoomBlk, MyEntityId,
      MyLocation, Amount, TRUE);
    End Else PutLine('ok. ');
  End;
End;

Procedure Do_Inventory(Var NodeIn : EntityType; Var S : String_Type);
Var Target : $UWord := 0;
    S1 : String_Type;
Begin
  S1 := S;
  If ParsePeopleHere(NodeIn, S1, Target, IsWindy, IsWindy) Then Begin
    S := S1;
    ShowInventory(Target);
  End Else Begin
    ShowInventory(MyEntityId);
  End;
End;
  
Procedure Do_Look(Var NodeIn : EntityType; Var S : String_Type);
Var S1 : String_Type;
    Target, Dir : $UWord := 0;
    SeeHidden, SeeInvisi : Boolean := False;
Begin
  S1 := S;
  If ParseEntityHere(NodeIn, S1, Target) Then Begin
    S := S1;
    DescEntity(Target);
  End Else Begin
    S1 := S;
    SeeHidden := IsWindy;
    SeeInvisi := IsWindy;
    If ParseTable(DirTable, S1, Dir) Then Begin
      S := S1;
      DescThere(NodeIn,MyLocation,MyEntityId,Dir,Brief,SeeHidden,SeeInvisi);
    End Else Begin
      DescRoomIn(NodeIn, MyEntityId, Brief, SeeHidden, SeeInvisi);
    End;
  End;
End;

Procedure Do_Move(Var NodeIn : EntityType; Dir : $UWord);
Var Entity : EntityType;
    PersonBlk, RoomBlk : BlockType;
    MoveHidden, MoveInvisi : Boolean;
    Loc, Pos : $UWord;
    S : String_Type := '';
Begin
  If IcanAct(S, Entity, PersonBlk) Then Begin
    If (MyPosition = POS_HIDDEN) Then
      MoveHidden := IsWindy
    Else If (MyPosition = POS_INVISI) Then
      MoveInvisi := IsWindy;
    ReadBlock(NodeIn.RoomId, RoomBlk);
    If MovePerson(Entity, NodeIn, PersonBlk, RoomBlk, MyLocation,
    MyEntityId, Dir, TRUE, MoveHidden, MoveInvisi) Then Begin
      SetMyEvent;
      ReadEntity(MyLocation, NodeIn);
      DescRoomIn(NodeIn, MyEntityId, Brief, IsWindy, IsWindy);
    End;
  End;
End;

Procedure Do_Ping(Var NodeIn : EntityType; Var S : String_Type);
Var Targ : EntityType;
    Target, TLoc, TPos : $UWord := 0;
Begin
  If ParsePeopleHere(NodeIn, S, Target, IsWindy, IsWindy) Then Begin
    Read_Record(FILE_ENTITY, Target, IAddress(Targ));
    If (Targ.Driver > 0) Then Begin
      If IsPlaying(Targ.Driver) Then
        PutLine(Targ.Name+' is alive and well. ')
      Else Begin
        GetLocation(Target, TLoc, TPos);
        ChangeMapPos(Target, MyLocation, NodeIn.RoomMapId, 0);
        UpdateLocation(Target, TLoc, TPos);
        PutLine(Targ.Name+' shimmers and vanishes into thin air. ');
      End;
    End Else PutLine(Targ.Name+' is a random character. ');
  End Else PutLine('No such person can be seen here. ');
End;

Procedure Do_Poof(Var NodeIn : EntityTYpe;
  Var S : String_Type);
Var NewLocation, OldPos : $UWord := 0;
Begin
  If IsWindy Then Begin
    If GrabEntity('Where? ', S, NewLocation, ENTITY_ROOM) Then Begin
      TakeToken(MyEntityId, NodeIn.RoomMapId, OldPos);
      MyLocation := NewLocation;
      ReadEntity(MyLocation, NodeIn);
      PutToken(MyEntityId, MyLocation, NodeIn.RoomMapId, OldPos, TRUE);
      SetMyEvent;
      DescRoomIn(NodeIn, MyEntityId, Brief, TRUE, TRUE);
    End;
  End Else PutLine('*poof*');
End;

Procedure Do_Say(Var S : String_Type);
Begin
  LogEvent(MyEntityId, 0, EV_SAY, MyLocation, S, FALSE);
  S := '';
End;

Procedure Do_Sheet(Var NodeIn : EntityType; Var S : String_Type);
Var Target : $UWord := 0;
    S1 : String_Type;
Begin
  S1 := S;
  If ParsePeopleHere(NodeIn, S1, Target, IsWindy, IsWindy) Then Begin
    S := S1;
    If IsWindy Then
      ShowSheet(Target)
    Else PutLine('You are not prived. ');
  End Else Begin
    ShowSheet(MyEntityId);
  End;
End;

Procedure Do_Takeoff(Var S : String_Type);
Var Entity, Obj : EntityType;
    PersonBlk : BlockType;
    ObjId : $UWord := 0;
Begin
  If IcanAct(S, Entity, PersonBlk) Then Begin
    If (S.Length = 0) Then GrabLine('Take off what? ', S);
    If ParseEquip(Entity, S, ObjId) Then Begin
      ReadEntity(ObjId, Obj);
      TakeoffObj(Entity, Obj, PersonBlk, MyEntityId, MyLocation, ObjId, TRUE);
    End Else PutLine('You are not holding such object. ');
  End;
End;

Procedure Do_Whereis(Var S : String_Type);
Var AnEntity, RoomEntity : EntityType;
    EntityId, Where, Pos : $UWord := 0;
Begin
  If GrabEntity('Where is what? ', S, EntityId) Then Begin
    ReadEntity(EntityId, AnEntity);
    GetLocation(EntityId, Where, Pos);
    If (Where > 0) Then
      ReadEntity(Where, RoomEntity)
    Else RoomEntity.Name := 'Void';
    PutLine(AnEntity.Name+' is in '+RoomEntity.Name+'.');
  End;
End;

Procedure Do_Who;
Var Allocation : Alloc_Record_Type; User : User_Type;
  Entity, Class, NodeIn : EntityType;
  PersonBlk : BlockType;
  I : Integer;
  Loc, Pos : $UWord;
  S : String_Type;
Begin
  Read_Record(FILE_ALLOC, ALLOC_USER, IAddress(Allocation));
  PutLine('Name                Level     Class               Location  ');
  PutLine(DivLine+DivLine);
  For I := 1 To Allocation.Topused Do
    If (Not Allocation.Free[I]) Then Begin
      Read_Record(FILE_USER, I, IAddress(User));
      If (User.IsPlaying) Then Begin
        ReadEntity(User.EntityLog, Entity);
        Read_Record(FILE_BLOCK, Entity.PersonId, IAddress(PersonBlk));
        ReadEntity(PersonBlk.Person.Class, Class);
        GetLocation(User.EntityLog, Loc, Pos);
        ReadEntity(Loc, NodeIn);
        WriteV(S, PersonBlk.Person.Level:0);
        PutLine(PadStr(Entity.Name, 20)+PadStr(S, 10)+PadStr(Class.Name, 20)+
        NodeIn.Name);
      End;
    End;
  PutLine(DivLine+DivLine);
End;

Procedure Do_Wield(Var S : String_Type);
Var Entity, Obj : EntityType;
    PersonBlk : BlockType;
    ObjId : $UWord := 0;
Begin
  If IcanAct(S, Entity, PersonBlk) Then Begin
    If (S.Length = 0) Then GrabLine('Wield what? ', S);
    If ParseHold(Entity, S, ObjId) Then Begin
      ReadEntity(ObjId, Obj);
      If (Obj.ObjKind = OBJ_WEAPON) Then
        WieldWeapon(Entity, Obj, PersonBlk, MyEntityId, MyLocation, ObjId, TRUE)
      Else If (Obj.ObjKind = OBJ_ARMOR) Then
        WearArmor(Entity, Obj, PersonBlk, MyEntityId, MyLocation, ObjId, TRUE)
      Else PutLine('You can''t wield '+Obj.Name+'.');
    End Else PutLine('You are not holding such object. ');
  End;
End;

Procedure Do_Brief;
Begin
  Brief := Not Brief;
  If Brief Then
    PutLine('Brief description.')
  Else PutLine('Verbose description. ');
End;

Procedure ParseCmd;
Const
  C_Attack = 1; C_Block = 2; C_Build = 3; C_Cast = 4;
  C_Down = 5; C_Defend = 6; C_Drop = 7; C_Dropgold = 8;
  C_East = 9; C_Get = 10; C_Getgold = 11; C_Inventory = 12;
  C_Look = 13; C_Memory = 14; C_North = 15; C_Ping = 16;
  C_Poof = 17; C_Photo = 18; C_Priv = 19; C_Quit = 20;
  C_South = 21; C_Source = 22; C_Sheet = 23; C_Say = 24;
  C_Steal = 25; C_Takeoff = 26; C_Up = 27; C_West = 28;
  C_Who = 29; C_Wield = 30; C_Brief = 31; C_Bash = 32;
  C_Hide = 33; C_Search = 34; C_Whereis = 35;
  MaxCmds = 35;
Var
  CmdTable : [Readonly] Array[1..MaxCmds] Of Short_String_Type := 
    ('Attack', 'Block', 'Build', 'Cast',
     'Down', 'Defend', 'Drop', 'Drop gold',
     'East', 'Get', 'Get gold', 'Inventory',
     'Look', 'Memory', 'North', 'Ping',
     'Poof', 'Photo', 'Priv', 'Quit',
     'South', 'Source', 'Sheet', 'Say',
     'Steal', 'Takeoff', 'Up', 'West',
     'Who', 'Wield', 'Brief', 'Bash',
     'Hide', 'Search', 'Where is');
  S, OldS : String_Type := ''; Cmd : $UWord;
  Done : Boolean := False;
  NodeIn : EntityType;
Begin
  InPlay := True;
  While Not Done Do Begin
    If (S.Length = 0) Then Begin
      While (S.Length = 0) Do Begin
        GrabLine('> ', S);
        If (S = '?') Then Begin
          PutLine(DivLine+DivLine);
          PrintTable(CmdTable);
          S := '';
          PutLine(DivLine+DivLine);
        End;
      End;
      If (S = '.') Then
        S := OldS
      Else
        OldS := S;
    End;
    If (S[1] = '''') Then Begin
      S := SubStr(S, 2, S.Length - 1);
      Do_Say(S);
    End Else If ParseTable(CmdTable, S, Cmd) Then Begin
      ReadEntity(MyLocation, NodeIn);
      GetLocation(MyEntityId, MyLocation, MyPosition);
      Case Cmd Of
        C_Attack   : Do_Attack(NodeIn, S);
        C_Block    : Do_Block(NodeIn, S);
        C_Build    : If IsWindy Then Do_Build(NodeIn, S, MyLocation);
        C_Cast     : Do_Cast(NodeIN, S);
        C_Down     : Do_Move(NodeIn, DOWN);
        C_Defend   : Do_Defend(S);
        C_Drop     : Do_Drop(NodeIn, S);
        C_DropGold : Do_DropGold(NodeIn, S);
        C_East     : Do_Move(NodeIn, EAST);
        C_Get      : Do_Get(NodeIn, S);
        C_GetGold  : Do_GetGold(NodeIn, S);
        C_Inventory: Do_Inventory(NodeIn, S);
        C_Look     : Do_Look(NodeIn, S);
        C_Memory   : PutLine('Not yet implemented. ');
        C_North    : Do_Move(NodeIn, NORTH);
        C_Ping     : Do_Ping(NodeIn, S);
        C_Poof     : Do_Poof(NodeIn, S);
        C_Photo    : Do_Photo(S);
        C_Priv     : IsWindy(TRUE);
        C_Quit     : Done := True;
        C_South    : Do_Move(NodeIn, SOUTH);
        C_Source   : Do_Source(S);
        C_Sheet    : Do_Sheet(NodeIn, S);
        C_Say      : Do_Say(S);
        C_Steal    : PutLine('Not yet implemented. ');
        C_Takeoff  : Do_TakeOff(S);
        C_Up       : Do_Move(NodeIn, UP);
        C_West     : Do_Move(NodeIn, WEST);
        C_Who      : Do_Who;
        C_Wield    : Do_Wield(S);
        C_Brief    : Do_Brief;
        C_Bash     : PutLine('Not yet implemented. ');
        C_Hide     : PutLine('Not yet implemented. ');
        C_Search   : PutLine('Not yet implemented. ');
        C_Whereis  : Do_Whereis(S);
      End;  (* case *)
    End Else PutLine('Type ? for a list of command. ');
  End;
  InPlay := False;
End;

End.
