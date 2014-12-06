[Inherit('M1', 'M2', 'M3', 'M4'),
 Environment('M5')]

Module M5;


(* entity functions *)

[Hidden]
Type
  LocationType = Record
    NodeIn : $UWord;
    PosIn  : $UByte;
  End;

  Entity_Type = Record     (* not to be confused with EntityType *)
    Id     : $UWord;
    Entity : EntityType;
    Next   : ^Entity_Type;
  End;

[Hidden]
Var
  Entity_File : File Of EntityType;
  Who_File : File Of LocationType;    (* for quick generation of who list *)
  TopEntity : Entity_Type;            (* start of link list!              *)

Procedure SetUpEntity;
Var IsOpen : [Static] Boolean := False;
Begin
  If IsOpen Then Begin
    IsOpen := False; Close(Entity_File); Close(Who_File);
  End Else Begin
    IsOpen := True;
    Open_File(FILE_ENTITY, Entity_File, Root+'Entity.Mon', Size(EntityType));
    Open_File(FILE_WHO, Who_File, Root+'Who.Mon', Size(LocationType));
  End;
End;

Procedure InitEntityFile(Max : $UWord);
Var Entity : EntityType; Location : LocationType; I : Integer;
Begin
  Entity := Zero; Location := Zero;
  For I := 1 To Max Do Begin
    Put_Record(FILE_ENTITY, I, IAddress(Entity));
    Put_Record(FILE_WHO, I, IAddress(Location));
  End;
  InitAlloc(ALLOC_ENTITY, Max);
End;

Procedure IncEntityQuota(Amount : $UWord);
Var Entity : EntityType;
    Location : LocationType;
    I, Start, Finish : $UWord := 0;
Begin
  Entity := Zero;
  Location := Zero;
  If Inc_Alloc_Quota(ALLOC_ENTITY, Amount, Start, Finish) Then
    For I := Start To Finish Do Begin
      Put_Record(FILE_ENTITY, I, IAddress(Entity));
      Put_Record(FILE_WHO, I, IAddress(Entity));
    End
  Else LogErr('Error increase entity quota. ');
End;

Procedure LoadEntitys;
Var Current, Next : ^Entity_Type; Entity : EntityType; I : Integer;
    Allocation : Alloc_Record_Type;
Begin
  TopEntity := Zero;               (* initiate entity link list  *)
  New(Next);                       (* notice TopEntity is always *)
  TopEntity.Next := Next;          (* empty                      *)
  Read_Record(FILE_ALLOC, ALLOC_ENTITY, IAddress(Allocation));
  If (Allocation.Topused > 0) Then Begin
    For I := 1 To Allocation.Topused Do Begin
      Current := Next;
      Read_Record(FILE_ENTITY, I, IAddress(Entity));
      Current^.Id := I;
      Current^.Entity := Entity;
      New(Next);
      Current^.Next := Next;
    End;
  End;
  Dispose(Current^.Next);         (* finiciate block link list     *)
  Current^.Next := NIL;           (* dispose the unused block_type *)
End;

Procedure ReadEntity(EntityId : $UWord; Var Entity : EntityType);
(*
 *  only some of the data in the record do not change
 *  when fast mode is turned on. use your own judgement
 *  while calling this procedure.
 *)
Var I : Integer; Current : ^Entity_Type;
Begin
  If FAST_MODE Then Begin
    Current := TopEntity.Next;
    If (Entityid > 1) Then
      For I := 1 To (EntityId-1) Do
        Current := Current^.Next;
    Entity := Current^.Entity;
  End Else Read_Record(FILE_ENTITY, EntityId, IAddress(Entity));
End;

Procedure PrintEntityNames(EntityKind : $UWord := 0);
Var Allocation : Alloc_Record_Type;
    Entity : EntityType;
    I : Integer;
Begin
  Read_Record(FILE_ALLOC, ALLOC_ENTITY, IAddress(Allocation));
  PutLine(DivLine+DivLine);
  For I := 1 To Allocation.Topused Do
    If (Not Allocation.Free[I]) Then Begin
      ReadEntity(I, Entity);
      If (Entity.EntityKind = EntityKind) Or (EntityKind = 0) Then
        PrintStr(Entity.Name);
    End;
  PrintStr;
  PutLine(DivLine+DivLine);
End;

Procedure UpdateLocation(EntityId, NodeIn, Pos : $UWord);
Var Location : LocationType;
Begin
  Get_Record(FILE_WHO, EntityId, IAddress(Location));
  Location.NodeIn := NodeIn;
  Location.PosIn := Pos;
  Update_Record(FILE_WHO, EntityId, IAddress(Location));
End;

Procedure GetLocation(EntityId : $UWord; Var NodeIn, Pos : $UWord);
Var Location : LocationType;
Begin
  Read_Record(FILE_WHO, EntityId, IAddress(Location));
  NodeIn := Location.NodeIn;
  Pos := Location.PosIn;
End;

Function GrabEntity(Prompt : String_Type; Var S : String_Type;
   Var EntityId : $UWord; EntityKind : $UWord := 0): Boolean;
Var Allocation : Alloc_Record_type; Entity : EntityType;
    I, NameLog : $UWord; NameStr : String_Type;
Begin
  While (S.Length = 0) Do
    GrabLine(Prompt, S);
  Read_Record(FILE_ALLOC, ALLOC_ENTITY, IAddress(Allocation));
  ParseLine(S, EntityId, TRUE, FALSE);
  For I := 1 To Allocation.Topused Do
    If (Not Allocation.Free[I]) Then Begin
      ReadEntity(I, Entity);
      If (Entity.EntityKind = EntityKind) Or (EntityKind = 0) Then Begin
        NameLog := I;
        NameStr := Entity.Name;
        ParseLine(NameStr, NameLog);
      End;
    End;
  GrabEntity := ParseLine(S, EntityId, FALSE, TRUE);
End;


(*  Item map functions  *)

[Hidden]
Var
  ItemMapFile : File Of ItemMapType;

Procedure SetUpItemMap;
Var IsOpen : [Static] Boolean := False;
Begin
  If IsOpen Then Begin
    IsOpen := False; Close(ItemMapFile);
  End Else Begin
    IsOpen := True;
    Open_File(FILE_ITEMMAP, ItemMapFile, Root+'ItemMap.Mon', Size(ItemMapType));
  End;
End;

Procedure InitItemMapFile(Max : $UWord);
Var ItemMap : ItemMapType; I : Integer;
Begin
  ItemMap := Zero;
  For I := 1 To Max Do Put_Record(FILE_ITEMMAP, I, IAddress(ItemMap));
  InitAlloc(ALLOC_ITEMMAP, Max);
End;

Procedure IncItemMapQuota(Amount : $UWord);
Var ItemMap : ItemMapType;
    I, Start, Finish : $UWord := 0;
Begin
  ItemMap := Zero;
  If Inc_Alloc_Quota(ALLOC_ITEMMAP, Amount, Start, Finish) Then
    For I := Start To Finish Do
      Put_Record(FILE_ITEMMAP, I, IAddress(ItemMap))
  Else LogErr('Error increase item map quota. ');
End;

Function FindToken(EntityLog, MapId : $UWord; Var FoundIn : $UWord): Boolean;
Var  ItemMap : ItemMapType; I : $UWord := 0;
  Found, Done : Boolean := False;
Begin
  Read_Record(FILE_ITEMMAP, MapId, IAddress(ItemMap));
  While Not Found And Not Done Do Begin
    I := I + 1; 
    Found := (ItemMap.Ids[I] = EntityLog);
    Done := (I = ItemMapSize);
  End;
  If Not Found And (ItemMap.Next > 0) Then
    Found := FindToken(EntityLog, ItemMap.Next, FoundIn);
  FoundIn := MapId;
  FindToken := Found;
End;

Function TakeToken(Id, MapId : $UWord; Var Pos : $UWOrd): Boolean;
Var  ItemMap : ItemMapType; Done, Found : Boolean := False; I : Integer := 0;
Begin
  Get_Record(FILE_ITEMMAP, MapId, IAddress(ItemMap));
  While Not Done And Not Found Do Begin
    I := I + 1;
    Found := (ItemMap.Ids[I] = Id);
    Done := (I = ItemMapSize);
  End;
  If Found Then Begin
    Pos := ItemMap.Pos[I];
    ItemMap.Ids[I] := 0;
    ItemMap.Pos[I] := 0;
    Update_Record(FILE_ITEMMAP, MapId, IAddress(ItemMap));
  End Else Begin
    Free_Record(FILE_ITEMMAP);
    If (ItemMap.Next > 0) Then
      Found := TakeToken(Id, ItemMap.Next, Pos);
  End;
  TakeToken := Found;
End;

Function PutToken(Id, Loc, MapId, Pos : $UWord; More : Boolean): Boolean;
Var  ItemMap : ItemMapType; Done, Found : Boolean := False; I : Integer := 0;
Begin
  Get_Record(FILE_ITEMMAP, MapId, IAddress(ItemMap));
  While Not Done And Not Found Do Begin
    I := I + 1;
    Found := (ItemMap.Ids[I] = 0);
    Done := (I = ItemMapSize);
  End;
  If Found Then Begin
    ItemMap.Ids[I] := Id;
    ItemMap.Pos[I] := Pos;
    Update_Record(FILE_ITEMMAP, MapId, IAddress(ItemMap));
    UpdateLocation(Id, Loc, Pos);
  End Else If More Then Begin
    If (ItemMap.Next > 0) Then Begin
      Free_Record(FILE_ITEMMAP);
      Found := PutToken(Id, Loc, ItemMap.Next, Pos, More)
    End Else If Alloc_Items(ALLOC_ITEMMAP, ItemMap.Next) Then Begin
      Update_Record(FILE_ITEMMAP, MapId, IAddress(ItemMap));
      Found := PutToken(Id, Loc, ItemMap.Next, Pos, More);
    End Else Free_Record(FILE_ITEMMAP);
  End;
  PutToken := Found;
End;

Function LookUpMap(Var Val : $UWord; MapId, Id : $UWord;
   IdOnly, PosOnly : Boolean;
   P1, P2, P3, P4, P5, P6, P7, P8, P9, P10, P11, P12 : $UWord := 0): Boolean;
Var  Map : ItemMapType; I : Integer; Done, Found, PosMatch : Boolean := False;

 Procedure FindOne;
 Begin
   With Map Do Begin
     If IdOnly Then Begin
       Found := (Ids[I] = Id);
       Val := Pos[I];
     End Else Begin
       PosMatch := (Pos[I]=P1) Or (Pos[I]=P2) Or (Pos[I]=P3) Or
       (Pos[I]=P4) Or (Pos[I]=P5) Or (Pos[I]=P6) Or (Pos[I]=P7) Or
       (Pos[I]=P8) Or (Pos[I]=P9) Or (Pos[I]=P10) Or (Pos[I]=P11) Or
       (Pos[I]=P12);
       If PosOnly Then Begin
         Found := PosMatch;
         Val := Ids[I];
       End Else Begin
         Found := (PosMatch And (Map.Ids[I] = Id));
         Val := 0;
       End;
     End;
   End;
 End;

Begin
  Read_Record(FILE_ITEMMAP, MapId, IAddress(Map));
  While Not Done Do Begin
    I := 0;
    While (I < ItemmapSize) And Not Found Do Begin
      I := I + 1;
      If (Map.Ids[I] > 0) And (Map.Pos[I] > 0) Then
        FindOne;
    End;
    If Not Found And (Map.Next > 0) Then
      Read_Record(FILE_ITEMMAP, Map.Next, IAddress(Map))
    Else Done := True;
  End;
  LookUpMap := Found;
End;

Procedure ParseMap(Var Map : ItemMapType; Excpt, OldPos : $UWord := 0);
Var Entity : EntityType; I : $UWord;
  NameStr : String_Type; NameLog : $UWord;
Begin
  With Map Do Begin
    For I := 1 To ItemMapSize Do
      If (Ids[I] > 0) And (Ids[I] <> Excpt) And (Pos[I] > 0) Then
        If (Pos[I] = OldPos) Or (OldPos = 0) Then Begin
          ReadEntity(Ids[I], Entity);
          NameLog := Ids[I];
          NameStr := Entity.Name;
          ParseLine(NameStr, NameLog);
        End;
  End;
End;

Function ChangeMapPos(Id, Loc, MapId, NewPos : $UWord): Boolean;
Var Done, Found : Boolean := False; Map : ItemMapType;
    I : Integer := 0; 
Begin
  Get_Record(FILE_ITEMMAP, MapId, IAddress(Map));
  While Not Done Do Begin
    While Not Found And (I < ItemMapSize) Do Begin
      I := I + 1;
      If (Map.Ids[I] = Id) Then Begin
        Found := True;
        Map.Pos[I] := NewPos;
        Update_Record(FILE_ITEMMAP, MapId, IAddress(Map));
        UpdateLocation(Id, Loc, NewPos);
      End;
    End;
    If Not Found And (Map.Next > 0) Then Begin
      Free_Record(FILE_ITEMMAP);
      MapId := Map.Next;
      Get_Record(FILE_ITEMMAP, MapId, IAddress(Map));
    End Else Begin
      Done := True;
      If Not Found Then Free_Record(FILE_ITEMMAP);
    End;
  End;
  ChangeMapPos := Found;
End;

Procedure PrintItemMap(MapId : $UWord);
Var  ItemMap : ItemMapType; L : String_Type; I : Integer;
Begin
  Read_Record(FILE_ITEMMAP, MapId, IAddress(ItemMap));
  PutLine(DivLine+DivLine);
  For I := 1 To ItemMapSize Do Begin
    If (ItemMap.Ids[I] = 0) Then
      WriteV(L, ' Slot: ',I:0)
    Else
      WriteV(L, ' Slot: ',I:0,' Id: ',ItemMap.Ids[I]:0,' Position: ',PosTable[ItemMap.Pos[I]]);
    PutLine(L);
  End;
  WriteV(L, ' Next: ', ItemMap.Next:0);
  PutLine(L);
  PutLine(DivLine+DivLine);
End;


(*  Block functions  *)

[Hidden]
Type
  Block_Type = Record      (* not to be confused with BlockType *)
    Id    : $UWord;
    Block : BlockType;
    Next  : ^Block_Type;
  End;

[Hidden]
Var
  BlockFile : File Of BlockType;
  TopBlock : Block_Type;             (* start of link list! *)

Procedure SetUpBlock;
Var IsOpen : [Static] Boolean := False;
Begin
  If IsOpen Then Begin
    IsOpen := False; Close(BlockFile);
  End Else Begin
    IsOpen := True;
    Open_File(FILE_BLOCK, BlockFile, Root+'Block.Mon', Size(BlockType));
  End;
End;

Procedure InitBlockFile(Max : $UWord);
Var Block : BlockType; I : Integer;
Begin
  Block := Zero;
  For I := 1 To Max Do Put_Record(FILE_BLOCK, I, IAddress(Block));
  InitAlloc(ALLOC_BLOCK, Max);
End;

Procedure IncBlockQuota(Amount : $UWord);
Var Block : BlockType;
    I, Start, Finish : $UWord := 0;
Begin
  Block := Zero;
  If Inc_Alloc_Quota(ALLOC_BLOCK, Amount, Start, Finish) Then
    For I := Start To Finish Do
      Put_Record(FILE_BLOCK, I, IAddress(Block))
  Else LogErr('Error increase block quota. ');
End;

Procedure LoadBlocks;
Var Current, Next : ^Block_Type; Block : BlockType; I : Integer;
    Allocation : Alloc_Record_Type;
Begin
  TopBlock := Zero;               (* initiate block link list  *)
  New(Next);                      (* notice TopBlock is always *)
  TopBlock.Next := Next;          (* empty                     *)
  Read_Record(FILE_ALLOC, ALLOC_BLOCK, IAddress(Allocation));
  If (Allocation.Topused > 0) Then Begin
    For I := 1 To Allocation.Topused Do Begin
      Current := Next;
      Read_Record(FILE_BLOCK, I, IAddress(Block));
      Current^.Id := I;
      Current^.Block := Block;
      New(Next);
      Current^.Next := Next;
    End;
  End;
  Dispose(Current^.Next);         (* finiciate block link list     *)
  Current^.Next := NIL;           (* dispose the unused block_type *)
End;

Procedure ReadBlock(BlockId : $UWord; Var Block : BlockType);
(*
 *  only some of the data in the record do not change
 *  when fast mode is turned on. use your own judgement
 *  while calling this procedure.
 *)
Var I : Integer; Current : ^Block_Type;
Begin
  If FAST_MODE Then Begin
    Current := TopBlock.Next;
    If (BlockId > 1) Then
      For I := 1 To (BlockId-1) Do
        Current := Current^.Next;
    Block := Current^.Block;
  End Else Read_Record(FILE_BLOCK, BlockId, IAddress(Block));
End;


(* Exit functions *)

[Hidden]
Type
  Exit_Type = Record        (* not to be confused with ExitType *)
    Id   : $UWord;
    Exit : ExitType;
    Next : ^Exit_Type;
  End;

[Hidden]
Var
  ExitFile : File Of ExitType;
  TopExit  : Exit_Type;

Procedure SetUpExit;
Var IsOpen : [Static] Boolean := False;
Begin
  If IsOpen Then Begin
    IsOpen := False; Close(ExitFile);
  End Else Begin
    IsOpen := True;
    Open_File(FILE_EXIT, ExitFile, Root+'Exit.Mon', Size(ExitType));
  End;
End;

Procedure InitExitFile(Max : $UWord);
Var Exit : ExitType; I : Integer;
Begin
  Exit := Zero;
  For I := 1 To Max Do Put_Record(FILE_EXIT, I, IAddress(Exit));
  InitAlloc(ALLOC_EXIT, Max);
End;

Procedure IncExitQuota(Amount : $UWord);
Var Exit : ExitType;
    I, Start, Finish : $UWord := 0;
Begin
  Exit := Zero;
  If Inc_Alloc_Quota(ALLOC_EXIT, Amount, Start, Finish) Then
    For I := Start To Finish Do
      Put_Record(FILE_EXIT, I, IAddress(Exit))
  Else LogErr('Error increase exit quota. ');
End;

Procedure LoadExits;
Var Current, Next : ^Exit_Type; Exit : ExitType; I, Max : Integer;
    Allocation : Alloc_Record_Type;
Begin
  TopExit := Zero;                 (* initiate exit link list  *)
  New(Next);                       (* notice TopExit is always *)
  TopExit.Next := Next;            (* empty                    *)
  Read_Record(FILE_ALLOC, ALLOC_EXIT, IAddress(Allocation));
  If (Allocation.Topused > 0) Then Begin
    For I := 1 To Allocation.Topused Do Begin
      Current := Next;
      Read_Record(FILE_EXIT, I, IAddress(Exit));
      Current^.Id := I;
      Current^.Exit := Exit;
      New(Next);
      Current^.Next := Next;
    End;
  End;
  Dispose(Current^.Next);         (* finiciate exit link list     *)
  Current^.Next := NIL;           (* dispose the unused exit_type *)
End;

Procedure ReadExit(ExitId : $UWord; Var Exit : ExitType);
(*
 *  only some of the data in the record do not change
 *  when fast mode is turned on. use your own judgement
 *  while calling this procedure.
 *)
Var I : Integer; Current : ^Exit_Type;
Begin
  If FAST_MODE Then Begin
    Current := TopExit.Next;
    If (ExitId > 1) Then
      For I := 1 To (Exitid-1) Do
        Current := Current^.Next;
    Exit := Current^.Exit;
  End Else Read_Record(FILE_EXIT, ExitId, IAddress(Exit));
End;

Function CreateExit(Var ExitId : $UWord;
   FromLoc, ToLoc, FromDir, ToDir : $UWord := 0): Boolean;
Var Exit : ExitType; Created : Boolean := False;
Begin
  If Alloc_Items(ALLOC_EXIT, ExitId) Then Begin
    Exit := Zero;
    Exit.Node[1] := FromLoc; Exit.Dire[1] := FromDir;
    Exit.Node[2] := ToLoc;   Exit.Dire[2] := ToDir;
    Update_Record(FILE_EXIT, ExitId, IAddress(Exit));
    Created := True;
  End Else LogErr('Error allocate Exit. ');
  CreateExit := Created;
End;

Procedure DeleteExit(ExitId : $UWord);
Var Exit : ExitType;
Begin
  Exit := Zero;
  Update_Record(FILE_EXIT, ExitId, IAddress(Exit));
  Dealloc_Items(ALLOC_EXIT, ExitId);
End;


(* room functions *)

Function CreateRoom(Name : Short_String_Type;
  Var EntityLog : $UWord): Boolean;
Var Entity : EntityType;
    RoomBlock : BlockType;
    RoomMap : ItemMapType;
    RoomId, RoomMapId : $UWord;
    Created : Boolean := False;
Begin
  If Alloc_Items(ALLOC_BLOCK, RoomId) Then Begin
    If Alloc_Items(ALLOC_ITEMMAP, RoomMapId) Then Begin
      If Alloc_Items(ALLOC_ENTITY, EntityLog) Then Begin
        Entity.Name := Name;
        Entity.EntityKind := ENTITY_ROOM;
        Entity.RoomId := RoomId;
        Entity.RoomMapId := RoomMapId;
        Update_Record(FILE_ENTITY, EntityLog, IAddress(Entity));
        RoomBlock := Zero;
        Update_Record(FILE_BLOCK, RoomId, IAddress(RoomBlock));
        RoomMap := Zero;
        Update_Record(FILE_ITEMMAP, RoomMapId, IAddress(RoomMap));
        Created := True;
        UpdateLocation(EntityLog, 0, 0);
      End Else Begin
        Dealloc_Items(ALLOC_ITEMMAP, RoomMapId);
        Dealloc_Items(ALLOC_BLOCK, RoomId);
      End;
    End Else Dealloc_Items(ALLOC_BLOCK, RoomId);
  End;
  CreateRoom := Created;
End;


(* create person functions *)

Function DefaultPerson: PersonType;
Var Person: PersonType; I : Integer;
Begin
  With Person Do Begin
    Group := 1;
    Class := 2;  (* 1 = the great beginning 2 = human .. *)
    Home := The_Great_Beginning;
    Exp := 1;
    Gold := Rnd(20);
    Level := 0;
    Weapon := 0;
    ArmorClass := 0;
    ActionDelay := 0;
    LastAct  := GetRealTime;
    LastHeal := GetRealTime;
    Stats := Zero;
    For I := 1 to MaxPersonAttri Do
      Attributes[I] := 6 + Rnd(6) + Rnd(4);
    MaxHealth := 12 + Rnd(8) + Rnd(4);
    MaxMana := 6 + Rnd(4) + Rnd(2);
    MaxSpeed := 100 + Rnd(40) + Rnd(20);
    Health := MaxHealth;
    Mana := MaxMana;
  End;
  DefaultPerson := Person;
End;

Function CreatePerson(Name : Short_String_Type;
  Var EntityLog : $UWord;
  Owner, Driver : $UWord;
  Where, MapId : $UWord): Boolean;
Var Entity : EntityType;
    PersonBlock : BlockType;
    PersonInven : ItemMapType;
    PersonId, InvenId : $UWord;
    Created : Boolean := False;
Begin
  If Alloc_Items(ALLOC_BLOCK, PersonId) Then Begin
    If Alloc_Items(ALLOC_ITEMMAP, InvenId) Then Begin
      If Alloc_Items(ALLOC_ENTITY, EntityLog) Then Begin
        Entity.Name := Name;
        Entity.EntityKind := ENTITY_PERSON;
        Entity.Owner := Owner;
        Entity.Driver := Driver;
        Entity.PersonId := PersonId;
        Entity.InvenId := InvenId;
        Entity.MemoryId := 0;
        Update_Record(FILE_ENTITY, EntityLog, IAddress(Entity));
        PersonBlock.Person := DefaultPerson;
        Update_Record(FILE_BLOCK, PersonId, IAddress(PersonBlock));
        PersonInven := Zero;
        Update_Record(FILE_ITEMMAP, InvenId, IAddress(PersonInven));
        Created := True;
        PutToken(EntityLog, Where, MapId, POS_IN_ROOM, TRUE);
      End Else Begin
        Dealloc_Items(ALLOC_ITEMMAP, InvenId);
        Dealloc_Items(ALLOC_BLOCK, PersonId);
      End;
    End Else Dealloc_Items(ALLOC_BLOCK, PersonId);
  End;
  CreatePerson := Created;
End;


(* create object functions *)

Function CreateObject(Name : Short_String_Type;
  Var EntityLog : $UWord;
  Where, MapId : $UWord): Boolean;
Var Entity : EntityType;
    Created : Boolean := False;
Begin
  If Alloc_Items(ALLOC_ENTITY, EntityLog) Then Begin
    Entity.Name := Name;
    Entity.EntityKind := ENTITY_OBJECT;
    Entity.ObjKind := 0;
    Entity.GetEffect := Zero;
    Entity.WornEffect := Zero;
    Entity.UseEffect := Zero;
    Entity.AttEffect := Zero;
    Update_Record(FILE_ENTITY, EntityLog, IAddress(Entity));
    Created := True;
    PutToken(EntityLog, Where, MapId, POS_OBJ_HERE, TRUE);
  End;
  CreateObject := Created;
End;


(* create spell functions *)

Function CreateSpell(Name : Short_String_Type;
  Var EntityLog : $UWord): Boolean;
Var Entity : EntityType;
    Created : Boolean := False;
Begin
  If Alloc_Items(ALLOC_ENTITY, EntityLog) Then Begin
    Entity.Name := Name;
    Entity.EntityKind := ENTITY_SPELL;
    Entity.SpellEffect := Zero;
    Update_Record(FILE_ENTITY, EntityLog, IAddress(Entity));
    Created := True;
    UpdateLocation(EntityLog, 0, 0);
  End;
  CreateSpell := Created;
End;

(* create class functions *)

Function CreateClass(Name : Short_String_Type;
  Var EntityLog : $UWord): Boolean;
Var Entity : EntityType;
    Created : Boolean := False;
Begin
  If Alloc_Items(ALLOC_ENTITY, EntityLog) Then Begin
    Entity.Name := Name;
    Entity.EntityKind := ENTITY_CLASS;
    Entity.Homeroom := The_Great_Beginning;
    Entity.Group := 1;
    Entity.ClassEffect := Zero;
    Update_Record(FILE_ENTITY, EntityLog, IAddress(Entity));
    Created := True;
    UpdateLocation(EntityLog, 0, 0);
  End;
  CreateClass := Created;
End;

End.
