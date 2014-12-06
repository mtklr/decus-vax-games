[Inherit('M1', 'M2', 'M3', 'M4', 'M5', 'M6'),
 Environment('M7_2')]

Module M7_2;


(* text output functions *)

Function HealthLevel(Health, MaxHealth : Integer): $UWord;
Begin
  Case (Health*100 Div MaxHealth) Of
    0      : HealthLevel := 0;
    1..20  : HealthLevel := 1;
    21..40 : HealthLevel := 2;
    41..60 : HealthLevel := 3;
    61..80 : HealthLevel := 4;
    81..99 : HealthLevel := 5;
    100    : HealthLevel := 6;
    Otherwise HealthLevel := 7;
  End;
End;

Procedure DescHealth(S : Short_String_Type; HealthLev : Integer;
   IsYou : Boolean);
Begin
  If IsYou Then
    Case HealthLev Of
      0: PutLine('You are dead! ');
      1: PutLine('You are near death! ');
      2: PutLine('You are in critical condition, and very weak! ');
      3: PutLine('You are very badly wounded! ');
      4: PutLine('You have some serious wounds. ');
      5: PutLine('You have some minor wounds. ');
      6: PutLine('You are in perfect health. ');
      7: PutLine('You are in exceptional health. ');
      Otherwise PutLine('You are in bogus health, notify monster manager. ');
    End
  Else
    Case HealthLev Of
      0: PutLine(S+' is dead! ');
      1: PutLine(S+' seems to be dead! ');
      2: PutLine(S+' is in critical condition, and very weak! ');
      3: PutLine(S+' is very badly wounded! ');
      4: PutLine(S+' has some serious wounds. ');
      5: PutLine(S+' has some minor wounds. ');
      6: PutLine(S+' is in perfect health. ');
      7: PutLine(S+' is in exceptional health. ');
      Otherwise PutLine(S+' is in bogus health, notify monster manager. ');
    End;
End;

Procedure DescAttack(S1, S2 : Short_String_Type;
  S3 : Short_String_Type := '');
Begin
  If (S3.Length = 0) Then 
    Case Rnd(2) Of
      0: PutLine(S1+' dealt a crushing blow to '+S2+'! ');
      1: PutLine(S1+' crashed into '+S2+' with lightning speed! ');
      2: PutLine(S2+' doubles over from the blow from '+S1+'! ');
    End
End;

Procedure DescSpellAttack(Name1, Name2, SpellName : Short_String_Type;
  IsRemote, HitAll : Boolean);
Begin
  If IsRemote And HitAll Then
    PutLine('A '+SpellName+' flew into the room and hits everybody! ')
  Else If IsRemote Then
    PutLine('A '+SpellName+' flew into the room and hits '+Name2+'! ')
  Else If HitAll Then
    PutLine(Name1+' cast a '+SpellName+' and hits everybody! ')
  Else
    PutLine(Name1+' cast a '+SpellName+' at '+Name2+'! ');
End;

[Hidden]
Procedure PrintPeopleHere(Var Map : ItemMapType; Me : $UWord);
Var Entity : EntityType; I : Integer;
Begin
  For I := 1 To ItemMapSize Do
    If (Map.Pos[I] = POS_IN_ROOM) And (Map.Ids[I] <> Me) Then Begin
      ReadEntity(Map.Ids[I], Entity);
      PutLine(Entity.Name+' is here. ');
    End;
End;

[Hidden]
Procedure PrintObjHere(Var Map : ItemMapType);
Var Entity : EntityType; I : Integer;
Begin
  For I := 1 To ItemMapSize Do
    If (Map.Pos[I] = POS_OBJ_HERE) Then Begin
      ReadEntity(Map.Ids[I], Entity);
      PutLine('There is a(n) '+Entity.Name+' here. ');
    End;
End;

[Hidden]
Procedure PrintObjSale(Var Map : ItemMapType);
Var Entity : EntityType; I : Integer;
Begin
  For I := 1 To ItemMapSize Do
    If (Map.Pos[I] = POS_OBJ_SALE) Then Begin
      ReadEntity(Map.Ids[I], Entity);
      PutLine(Entity.Name+' is for sale here. ');
    End;
End;

[Hidden]
Procedure PrintObjHidden(Var Map : ItemMapType);
Var Entity : EntityType; I : Integer;
Begin
  For I := 1 To ItemMapSize Do
    If (Map.Pos[I] = POS_OBJ_HIDE) Then Begin
      ReadEntity(Map.Ids[I], Entity);
      PutLine(Entity.Name+' is hidden here. ');
    End;
End;

[Hidden]
Procedure PrintGuardianHere(Var Map : ItemMapType; Me : $UWord);
Var Entity : EntityType; I : Integer;
Begin
  For I := 1 To ItemMapSize Do
    If (Map.Ids[I] <> Me) Then Begin
      If (Map.Pos[I] = POS_GUARD_S) Then Begin
        ReadEntity(Map.Ids[I], Entity);
        PutLine(Entity.Name+' is guarding south exit. ');
      End Else If (Map.Pos[I] = POS_GUARD_N) Then Begin
        ReadEntity(Map.Ids[I], Entity);
        PutLine(Entity.Name+' is guarding north exit. ');
      End Else If (Map.Pos[I] = POS_GUARD_W) Then Begin
        ReadEntity(Map.Ids[I], Entity);
        PutLine(Entity.Name+' is guarding west exit. ');
      End Else If (Map.Pos[I] = POS_GUARD_E) Then Begin
        ReadEntity(Map.Ids[I], Entity);
        PutLine(Entity.Name+' is guarding east exit. ');
      End Else If (Map.Pos[I] = POS_GUARD_U) Then Begin
        ReadEntity(Map.Ids[I], Entity);
        PutLine(Entity.Name+' is guarding up exit. ');
      End Else If (Map.Pos[I] = POS_GUARD_D) Then Begin
        ReadEntity(Map.Ids[I], Entity);
        PutLine(Entity.Name+' is guarding down exit. ');
      End;
    End;
End;

[Hidden]
Procedure PrintHiddenHere(Var Map : ItemMapType; Me : $UWord);
Var Entity : EntityType; I : Integer;
Begin
  For I := 1 To ItemMapSize Do
    If (Map.Pos[I] = POS_HIDDEN) And (Map.Ids[I] <> Me) Then Begin
      ReadEntity(Map.Ids[I], Entity);
      PutLine(Entity.Name+' is hidding here. ');
    End;
End;

[Hidden]
Procedure PrintInvisiHere(Var Map : ItemMapType; Me : $UWord);
Var Entity : EntityType; I : Integer;
Begin
  For I := 1 To ItemMapSize Do
    If (Map.Pos[I] = POS_INVISI) And (Map.Ids[I] <> Me) Then Begin
      ReadEntity(Map.Ids[I], Entity);
      PutLine('Invisible '+Entity.Name+' is here. ');
    End;
End;

Procedure DescExits(Var Room : RoomType);
Var I : Integer;
Begin
  If Not PrintDesc(Room.ExitDesc) Then Begin
    For I := 1 to MaxRoomExits Do
      If (Room.Exits[I] > 0) Then
        PutLine('There is an exit from '+DirTable[I]+'.');
    PutLine('');
  End;
End;

Procedure DescRoomIn(Var NodeIn : EntityType; Observer : $UWord;
   Brief, SeeHidden, SeeInvisi, IsThere : Boolean := False);
Var RoomBlk : BlockType; Map : ItemMapType; S : String_Type;
  I : Integer; Done : Boolean := False;
Begin
  If IsThere Then
    PutLine('You see '+NodeIn.Name+'.', 1)
  Else PutLine('You are in '+NodeIn.Name+'.', 1);
  Read_Record(FILE_BLOCK, NodeIn.RoomId, IAddress(RoomBlk));
  If (Not (Brief Or IsThere)) Then Begin
    PrintDesc(RoomBlk.Room.MainDesc);
    DescExits(RoomBlk.Room);
  End;
  If (RoomBlk.Room.Goldhere > 0) Then Begin
    WriteV(S, 'There are ', RoomBlk.Room.Goldhere:0, ' gold here. ');
    PutLine(S);
  End;
  Read_Record(FILE_ITEMMAP, NodeIn.RoomMapId, IAddress(Map));
  While Not Done Do Begin
    PrintPeopleHere(Map, Observer);
    PrintGuardianHere(Map, Observer);
    If SeeHidden Then PrintHiddenHere(Map, Observer);
    If SeeInvisi Then PrintInvisiHere(Map, Observer);
    If (Not IsThere) Then Begin
      PrintObjHere(Map);
      PrintObjSale(Map);
      If SeeHidden Then PrintObjHidden(Map);
    End;
    If (Map.Next > 0) Then
      Read_Record(FILE_ITEMMAP, Map.Next, IAddress(Map))
    Else Done := True;
  End;
End;

Procedure DescThere(Var NodeIn : EntityType; Location, Observer, Dir: $UWord;
   Brief, SeeHidden, SeeInvisi : Boolean := False);
Var NodeSee : EntityType; RoomBlk : BlockType; AnExit : ExitType;
  There : Integer;
Begin
  ReadBlock(NodeIn.RoomId, RoomBlk);
  If (RoomBlk.Room.Exits[Dir] = 0) Then
    PutLine('You see nothing of interest in that direction. ')
  Else Begin
    ReadExit(RoomBlk.Room.Exits[Dir], AnExit);
    If (AnExit.Node[1] = Location) Then
      There := AnExit.Node[2]
    Else There := AnExit.Node[1];
    If (There = 0) Then
      PutLine('You see a dead end. ')
    Else Begin
      ReadEntity(There, NodeSee);
      DescRoomIn(NodeSee, Observer, Brief, SeeHidden, SeeInvisi, TRUE);
    End;
  End;
End;

[Hidden]
Procedure DescPerson(Var Entity : EntityType);
Var S : String_Type;
    Cls : EntityType;
    PersonBlk : BlockType;
Begin
  Read_Record(FILE_BLOCK, Entity.PersonId, IAddress(PersonBlk));
  With PersonBlk.Person Do Begin
    ReadEntity(Class, Cls);
    DescHealth(Entity.Name, HealthLevel(Health, MaxHealth), FALSE);
    WriteV(S, Entity.Name, ' is a ', Level:0, 'th level ', Cls.Name+'.');
    PutLine(S);
  End;
End;

Procedure DescEntity(EntityId : $UWord);
Var Entity : EntityType;
Begin
  ReadEntity(EntityId, Entity);
  Case Entity.EntityKind Of
    ENTITY_PERSON : DescPerson(Entity);
    ENTITY_OBJECT : PutLine('You see nothing special about '+Entity.Name+'.');
    Otherwise PutLine(Entity.Name+' is unknow. ');
  End;
End;

Procedure ShowInventory(EntityId : $UWord);
Var Entity, Item : EntityType;
  Map : ItemMapType;
  I : Integer := 0;
  Done : Boolean := False;

 Procedure PrintInven;
 Begin
   PutLine('Inventory: ');
   For I := 1 To ItemMapSize Do
     If (Map.Pos[I] = POS_INVEN) Then Begin
       ReadEntity(Map.Ids[I], Item);
       PutLine('  '+Item.Name);
     End;
 End;

 Procedure PrintEquip;
 Begin
   PutLine('Equipment: ');
   For I := 1 To ItemMapSize Do
     If (Map.Pos[I] = POS_WEAPON) Or ( Map.Pos[I] = POS_ARMOR) Then Begin
       ReadEntity(Map.Ids[I], Item);
       PutLine('  '+Item.Name);
     End;
 End;

Begin
  ReadEntity(EntityId, Entity);
  Read_Record(FILE_ITEMMAP, Entity.InvenId, IAddress(Map));
  While Not Done Do Begin
    PrintInven;
    PrintEquip;
    If (Map.Next > 0) Then
      Read_Record(FILE_ITEMMAP, Map.Next, IAddress(Map))
    Else Done := True;
  End;
End;

Procedure ShowSheet(EntityId : $UWord);
Var S : String_Type;
    Entity, HR, Cls, Wp : EntityType;
    PersonBlk : BlockType;
    I : $UWord;
Begin
  ReadEntity(EntityId, Entity);
  Read_Record(FILE_BLOCK, Entity.InvenId, IAddress(PersonBlk));
  ReadEntity(PersonBlk.Person.Home, HR);
  ReadEntity(PersonBlk.Person.Class, Cls);
  PutLine(DivLine+DivLine);
  If (PersonBlk.Person.Weapon > 0) Then
    ReadEntity(PersonBlk.Person.Weapon, Wp);
  PutLine('Name                ' + Entity.Name);
  With PersonBlk.Person Do Begin
    WriteV(S, 'Group               ', Group:0);
    PutLine(S);
    WriteV(S, 'Class               ', Cls.Name);
    PutLine(S);
    WriteV(S, 'Home                ', HR.Name);
    PutLine(S);
    WriteV(S, 'Level               ', Level:0);
    PutLine(S);
    WriteV(S, 'Experience          ', Exp:0);
    PutLine(S);
    WriteV(S, 'Gold                ', Gold:0);
    PutLine(S);
    WriteV(S, 'ArmorClass          ', ArmorClass:0);
    PutLine(S);
    WriteV(S, 'Health              ', Health:0);
    PutLine(S);
    WriteV(S, 'Mana                ', Mana:0);
    PutLine(S);
    WriteV(S, 'Maxhealth           ', Maxhealth:0);
    PutLine(S);
    WriteV(S, 'Maxmana             ', Maxmana:0);
    PutLine(S);
    WriteV(S, 'Maxspeed            ', MaxSpeed:0);
    PutLine(S);
    For I := 1 To MaxPersonAttri Do Begin
      WriteV(S, PadStr(PersonAttritable[I], 20), Attributes[I]:0);
      PutLine(S);
    End;
    If (Weapon > 0) Then
      PutLine('Weapon              '+Wp.Name);
  End;
  PutLine(DivLine+DivLine);
End;

End.
