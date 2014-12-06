[Inherit('M1','M2','M3','M4','M5','M6','M7','M7_2','M7_3','M9'),
 Environment('M9_2')]

Module M9_2;


(* NPC customization routines *)

Const
  NPC_ACT_GO_S   = 1;
  NPC_ACT_GO_N   = 2;
  NPC_ACT_GO_W   = 3;
  NPC_ACT_GO_E   = 4;
  NPC_ACT_GO_D   = 5;
  NPC_ACT_GO_U   = 6; 
  MaxNpcAct = 6;

Var
  NpcActTable : Array[1..MaxNpcAct] Of Short_String_Type := (
    'South', 'North', 'West', 'East', 'Down', 'Up');

[Global]
Procedure ChangeMemory(Var S : String_Type; Where : $UWord);
Const
  M_Bexp = 1; M_Bgold = 2; M_Ap = 3; M_Saying = 4;
  MaxMemOpt = 4;
Var
  MemOptTable : Array[1..MaxmemOpt] Of Short_String_Type := (
    'Base experience', 'Base gold', 'Action points', 'Saying');
  Opt, EntityId : $UWord := 0;
  NodeIn, Entity : EntityType;
  Memory : MemoryType;

 Procedure EditSaying;
 Begin
   PutLine('Not yet implemented. ');
 End;

 Procedure AddAp;
 Var I, Pos, Act, Act2, Dir : $UWord := 0;
   Done, Found : Boolean := False;
 Begin
   While not Found And Not Done Do Begin
     I := I + 1;
     Found := (Memory.ActPoints[I].Where = 0);
     Done := (I = MaxActPoints);
   End;
   If Found Then With Memory.ActPoints[I] Do Begin
     If GrabEntity('Location? ', S, Where, ENTITY_ROOM) Then Begin
(*
       If GrabTable('Likely position? ', PosTable, S, Pos) Then
         Position := Pos;
 *)
       If GrabTable('Primary action? ', NpcActTable, S, Act) Then
         Action := Act;
       If GrabTable('Running action? ', NpcActTable, S, Act2) Then
         RunAct := Act2;
       If GrabTable('Forbidden direction? ', DirTable, S, Dir) Then
         Outdir := Dir;
     End Else PutLine('Not added. ');
   End Else PutLine('Memory action points are used up. ');
 End;

 Procedure DeleteAp;
 Var Index : $UWord;
 Begin
   Index := GrabNumberW('Which action points? ', S);
   If (Index > 0) And (Index < MaxActPoints) Then
     Memory.ActPoints[Index].Where := 0
   Else PutLine('Out of range. ');
 End;

 Procedure Listap;
 Var I : $UWord;
   L : String_Type := '';
   Entity : EntityType;
 Begin
   PutLine(DivLine+DivLine);
   for I := 1 To MaxActPoints Do
     If (Memory.ActPoints[I].Where > 0) Then With Memory.ActPoints[I] Do Begin
       WriteV(L, 'Action points ', I:0, ':');
       PutLine(L);
       ReadEntity(Where, Entity);
       PutLine('Location      : '+Entity.Name);
(*
       If (Position > 0) Then PutLine('Position      : '+PosTable[Position]);
 *)
       If (Action > 0) Then   PutLine('Action        : '+NpcActTable[Action]);
       If (RunAct > 0) Then   PutLine('Run Action    : '+NpcActTable[Runact]);
       If (OutDir > 0) Then   PutLine('Out Direction : '+DirTable[OutDir]);
       PutLine(DivLine+DivLine);
     End;
 End;

 Procedure EditActionPoints;
 Const
   AP_Add = 1; AP_Delete = 2; AP_List = 3; AP_Quit = 4; MaxApOpt = 4;
 Var
   ApOptTable : Array[1..MaxApOpt] Of Short_String_Type := (
     'Add', 'Delete', 'List', 'Quit');
   ApOpt : $UWord := 0;
   Done : Boolean := False;
 Begin
   While Not Done Do Begin
     If GrabTable('Edit ActionPoints> ', ApOptTable, S, ApOpt) Then
       Case ApOpt Of
         AP_Add    : AddAp;
         AP_Delete : DeleteAp;
         AP_List   : ListAp;
         AP_Quit   : Done := True;
       End
     Else PutLine('Type ? for a list of action points edit command. ');
   End;
 End;

Begin
  ReadEntity(Where, NodeIn);
  If (S.Length = 0) Then GrabLine('Person name? ', S);
  If ParsePeopleHere(NodeIn, S, EntityId) Then Begin
    ReadEntity(EntityId, Entity);
    If (Entity.MemoryId > 0) Then Begin
      If GrabTable('Memory option? ', MemOptTable, S, Opt) Then Begin
        Read_Record(FILE_MEMORY, Entity.MemoryId, IAddress(Memory));
        Case Opt Of
          M_Bexp   : Memory.BaseExp := GrabNumberI('Base experience? ', S);
          M_Bgold  : Memory.BaseGold := GrabNumberI('Base gold? ', S);
          M_Saying : EditSaying;
          M_Ap     : EditActionPoints;
        End;
        Update_Record(FILE_MEMORY, Entity.MemoryId, IAddress(Memory));
      End;
    End Else PutLine(Entity.Name+' do not have memory. ');
  End Else PutLine('No such person here. ');
End;


(*  Npc driver routines *)

Const
  MaxRoomNpc = 100;  (* should be more than enough..           *)
  MaxGlobNpc = 5;    (* this should be adjusted very carefully *)

Type
  RoomNpclistType = Record
    Top   : Integer;
    Point : Integer;
    Ids   : Array[1..MaxRoomNpc] Of $UWord;
    Items : Array[1..MaxRoomNpc] Of EntityType;
  End;

  GlobNpcListType = Record
    Next  : Integer;
    Point : Integer;
    Ids   : Array[1..MaxGlobNpc] Of $UWord;
    Items : Array[1..MaxGlobNpc] Of EntityType;
  End;

Var
  RoomNpc   : RoomNpcListType;
  MyEnemies : GlobNpcListType;

[Global]
Procedure InitEnemyList;
Begin
  MyEnemies.Next := 1;
  MyEnemies.Point := 0;
  MyEnemies.Items := Zero;
  MyEnemies.Ids := Zero;
End;

[Global]
Procedure UpdateEnemyList(Id : $UWord;
  Var Npc : EntityType);
Var Found : Boolean := False;
    I : Integer;
Begin
  For I := 1 To MaxGlobNpc Do
    If (MyEnemies.Ids[I] = Id) Then
      Found := True;
  If Not Found Then With MyEnemies Do Begin
    Next := Next + 1;
    If (Point > MaxGlobNpc) Then
      Next := 1;
    Items[Next] := Npc;
    Ids[Next] := Id;
  End;
End;

[Global]
Procedure LoadRoomNpc(Location : $UWord);
Var Map : ItemMapType;
    NodeIn, Entity, Npc : EntityType;
    PersonBlk, NpcPersonBlk : BlockType;
    I : Integer;
    Done : Boolean := False;
Begin
  RoomNpc := Zero;
  RoomNpc.Point := 1;
  ReadEntity(MyEntityId, Entity);
  ReadBlock(Entity.PersonId, PersonBlk);
  ReadEntity(Location, NodeIn);
  Read_Record(FILE_ITEMMAP, NodeIn.RoomMapId, IAddress(Map));
  While Not Done Do Begin
    For I := 1 To ItemMapSize Do
      If (Map.Ids[I] > 0) And (Map.Ids[I] <> MyEntityId) And (Map.Pos[I] > 0)
      Then Begin
        ReadEntity(Map.Ids[I], Npc);
        If (Npc.EntityKind = ENTITY_PERSON) And (Npc.Driver = 0) Then Begin
          RoomNpc.Top := RoomNpc.Top + 1;
          RoomNpc.Items[RoomNpc.Top] := Npc;
          RoomNpc.Ids[RoomNpc.Top] := Map.Ids[I];
          ReadBlock(Npc.PersonId, NpcPersonBlk);
          If (PersonBlk.Person.Group <> NpcPersonBlk.Person.Group) Then
            UpdateEnemyList(Map.Ids[I], Npc);
        End;
      End;
    If (Map.Next > 0) Then
      Read_Record(FILE_ITEMMAP, Map.Next, IAddress(Map))
    Else Done := True;
  End;
End;

[Global]
Procedure LogNpcEvent(Var AnEvent : Event_Type; Where : $UWord);
Var I : Integer;
    TempList : RoomNpcListType;
Begin
  If (Where <> MyLocation) Then Begin
    TempList := RoomNpc;
    LoadRoomNpc(Where);
  End;
  For I := 1 To RoomNpc.Top Do
    HandleEvent(AnEvent, RoomNpc.Ids[I], Where);
  If (Where <> MyLocation) Then
    RoomNpc := TempList;
End;

[Global]
Procedure UpdateRoomNpc(IsLeaving : Boolean; Id : $UWord);
Var I : Integer;
Begin
  If IsLeaving And (RoomNpc.Top > 0) Then Begin
    For I := 1 To RoomNpc.Top Do
      If (RoomNpc.Ids[I] = Id) Then Begin
        RoomNpc.Ids[I] := 0;
        RoomNpc.Items[I] := Zero;
      End;
  End Else If Not IsLeaving Then Begin
    RoomNpc.Top := RoomNpc.Top + 1;
    RoomNpc.Ids[RoomNpc.Top] := Id;
    ReadEntity(Id, RoomNpc.Items[RoomNpc.Top]);
  End;
End;

[Hidden]
Procedure DriveEnemy(NpcId : $UWord;
  Var Npc : EntityType);
Var Index : $UWord;
    PersonBlk : BlockType;
    Memory : MemoryType;
    MyEntity, DriverEntity, NodeIn : EntityType;
    LowHealth : Boolean;
    Where, Pos : $UWord;

 Procedure SearchMemory;
 Var I : Integer := 0;
 Begin
   Index := 0;
   While (Index = 0) And (I < MaxActPoints) Do Begin
     I := I + 1;
     If Memory.ActPoints[I].Where = Where Then
       Index := I;
   End;
 End;

 Procedure ActRunAway;
 Var Dir : Integer;
     RoomBlk : BlockType;
 Begin
   ReadBlock(NodeIn.RoomId, RoomBlk);
   If (MyLocation = Where) And (Rnd(100) < 50) Then Begin
     ReadEntity(MyEntityId, MyEntity);
     AttackPerson(Npc, MyEntity, NodeIn, PersonBlk, NpcId, MyEntityId, 
     Where, FALSE);
   End Else Begin
     If (Index > 0) Then Begin
       Case Memory.Actpoints[Index].RunAct Of
         NPC_ACT_GO_S : Dir := South;
         NPC_ACT_GO_N : Dir := North;
         NPC_ACT_GO_W : Dir := West;
         NPC_ACT_GO_E : Dir := East;
         NPC_ACT_GO_D : Dir := Down;
         NPC_ACT_GO_U : Dir := Up;
         Otherwise Dir := (Memory.Actpoints[Index].OutDir + Rnd(4)) Mod 6 + 1;
       End;
     End Else Dir := Rnd(5) + 1;
     MovePerson(Npc, NodeIn, PersonBlk, RoomBlk, Where, NpcId, Dir, FALSE);
   End;
 End;

 Procedure ActAttack;
 Begin
   ReadEntity(MyEntityId, MyEntity);
   AttackPerson(Npc, MyEntity, NodeIn, PersonBlk, NpcId, MyEntityId, 
   Where, FALSE);
 End;

 Procedure ActChase;
 Var Dir : Integer;
     RoomBlk : BlockType;
 Begin
   ReadBlock(NodeIn.RoomId, RoomBlk);
   If (Index > 0) Then Begin
     Case Memory.Actpoints[Index].Action Of
       NPC_ACT_GO_S : Dir := South;
       NPC_ACT_GO_N : Dir := North;
       NPC_ACT_GO_W : Dir := West;
       NPC_ACT_GO_E : Dir := East;
       NPC_ACT_GO_D : Dir := Down;
       NPC_ACT_GO_U : Dir := Up;
       Otherwise Dir := (Memory.Actpoints[Index].OutDir + Rnd(4)) Mod 6 + 1;
     End;
   End Else Dir := Rnd(5) + 1;
   MovePerson(Npc, NodeIn, PersonBlk, RoomBlk, Where, NpcId, Dir, FALSE);
 End;

Begin
  GetLocation(NpcId, Where, Pos);
  Get_Record(FILE_BLOCK, Npc.PersonId, IAddress(PersonBlk));
  If (PersonBlk.Person.Health > 0) Then Begin
    if CanAct(PersonBlk) Then Begin
      PersonBlk.Person.ActionDelay := 0;
      PersonBlk.Person.LastAct := GetRealTime;
      Update_Record(FILE_BLOCK, Npc.PersonId, IAddress(PersonBlk));
      LowHealth := ((PersonBlk.Person.Health*2) < (PersonBlk.Person.Maxhealth));
      If (Npc.MemoryId > 0) Then Begin
        Read_Record(FILE_MEMORY, Npc.MemoryId, IAddress(Memory));
        SearchMemory;  (* set index *)
      End;
      ReadEntity(Where, NodeIn);
      If LowHealth Then
        ActRunAway
      Else If (Where <> MyLocation) Then
        ActChase
      Else ActAttack;
    End Else Begin 
      Free_Record(FILE_BLOCK);
      TimeHeal(NpcId, Where);
    End;
  End Else Begin
    Free_Record(FILE_BLOCK);
    Resurrect(Npc, PersonBlk, NpcId, Where, FALSE);
  End;
End;

[Global]  
Procedure DriveEnemyList;
Var OldPoint : Integer;
Begin
  OldPoint := MyEnemies.Point;
  If (OldPoint = 0) Then
    OldPoint := MaxGlobNpc;
  With MyEnemies Do Repeat
    Point := Point + 1;
    If Point > MAxGlobNpc Then
      Point := 1;
    If Ids[Point] > 0 Then
      DriveEnemy(Ids[Point], Items[Point]);
  Until (Ids[Point] > 0) Or (Point = OldPoint);
End;

End.
