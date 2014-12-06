[Inherit('M1', 'M2', 'M3', 'M4', 'M5', 'M6', 'M7_2'),
 Environment('M7_3')]

Module M7_3(Output);


(* event functions *)

Const
  EVENT_BLOCK_SIZE = 20;
  MAX_EVENT_BLOCK = 10;

Type
  Event_Parm_Type = Array[1..5] Of Integer;

  Event_Type = Record
    Sender, Target, Action, Location : $UWord;
    Msg : String_Type;
    Parms : Event_Parm_Type;
    LogTime : $UQuad;
  End;

  Events_Type = Record
    Point : $UWord;
    Events : Array[1..EVENT_BLOCK_SIZE] Of Event_Type;
  End;

[Hidden]
Var
  Event_File : File Of Events_Type;

Var
  MyEntityId : $UWord;
  MyEventPoint : $UWord;
  MyLocation : $UWord;
  MyPosition : $UWord;
  ImDead : Boolean;

[External, Hidden]
Procedure InitEnemyList; external;

[External, Hidden]
Procedure LoadRoomNpc(Location : $UWord); External;

[External, Hidden]
Procedure LogNpcEvent(Var AnEvent : Event_Type; Where : $UWord); External;

[External, Hidden]
Procedure UpdateRoomNpc(IsLeaving : Boolean; Id : $UWord); External;

[External, Hidden]
Procedure DriveEnemyList; External;

Procedure HandleEvent(Var AnEvent : Event_Type; EntityId, Loc : $UWord);
Forward;

Procedure SetUpEvent;
Var IsOpen : [Static] Boolean := False;
Begin
  If IsOpen Then Begin
    IsOpen := False; Close(Event_File);
  End Else Begin
    IsOpen := True;
    Open_File(FILE_EVENT, Event_File, Root+'Event.Mon', Size(Events_Type));
  End;
End;

Procedure InitEventFile;
Var Events : Events_Type; I : $UWord;
Begin
  Events := Zero;
  Events.Point := 1;
  For I := 1 To MAX_EVENT_BLOCK Do Put_Record(FILE_EVENT, I, IAddress(Events));
End;

Procedure SetMyEvent;
Var Events : Events_Type; Id : $UWord;
Begin
  Id := MyLocation Mod MAX_EVENT_BLOCK + 1;
  Read_Record(FILE_EVENT, Id, IAddress(Events));
  MyEventPoint := Events.Point;
  LoadRoomNpc(MyLocation);
End;

[Global]
Procedure LogEvent(S, T, A, L : $UWord;
   M : String_Type := ''; DI : Boolean := False;
   P1, P2, P3, P4, P5, Id : Integer := 0);
Var Events : Events_Type; OldPoint : $UWord;
Begin
  If (Id = 0) Then
    Id := L Mod MAX_EVENT_BLOCK + 1;
  Get_Record(FILE_EVENT, Id, IAddress(Events));
  With Events.Events[Events.Point] Do Begin
    Sender := S;    Target   := T;
    Action := A;    Location := L;  Msg := M;
    Parms[1] := P1; Parms[2] := P2;
    Parms[3] := P3; Parms[4] := P4; Parms[5] := P5;
    LogTime := GetRealTime;
  End;
  OldPoint := Events.Point;
  If Events.Point = MAX_EVENT_BLOCK Then
    Events.Point := 1
  Else
    Events.Point := Events.Point + 1;
  Update_Record(FILE_EVENT, Id, IAddress(Events));
  If (T = ALL_TARGET) Then
    LogNpcEvent(Events.Events[OldPoint], L)
  Else If DI Then
    HandleEvent(Events.Events[OldPoint], T, L);
End;

Procedure LogGlobEvent(Sender, Target, Action : $UWord;
   Msg : String_Type := ''; P1, P2, P3, P4, P5 : Integer := 0);
Var I : Integer;
Begin
  For I := 1 To MAX_EVENT_BLOCK Do Begin
    LogEvent(Sender, Target, Action, GLOB_LOCATION, Msg, FALSE,
       P1, P2, P3, P4, P5, I);
  End;
End;

Procedure CheckEvent;
Var Events : Events_Type;
    Id, OldPoint, OldLocation : $UWord;
Begin
  Id := MyLocation Mod MAX_EVENT_BLOCK + 1;
  OldLocation := MyLocation;
  Read_Record(FILE_EVENT, Id, IAddress(Events));
  While (MyEventPoint <> Events.Point) And (OldLocation = MyLocation) Do Begin
    OldPoint := MyEventPoint;
    If MyEventPoint = MAX_EVENT_BLOCK Then
      MyEventPoint := 1
    Else
      MyEventPoint := MyEventPoint + 1;
    HandleEvent(Events.Events[OldPoint], MyEntityId, MyLocation);
(*
 * a lot of things could happen in handle event. since MyEventPoint is
 * a global variable, chances are it will get changed in handleevent.
 * There is no clean way to prevent this. Break out of the loop when
 * location is changed seem to fix most of the problem..
 *)
  End;
End;

Procedure Resurrect(Var Entity : EntityType;
  Var PersonBlk : BlockType;
  EntityId, Where : $UWord;
  Print : Boolean);
Var List : Array[1..ItemMapSize] Of $UWord;
    InvenMap, RoomMap : ItemMapType;
    RoomBlk : BlockType;
    NodeIn, Home, Cls : EntityType;
    GoldDropped : Integer := 0;
    OldPos, I : $UWord := 0;
    Dummy1, Dummy2 : Integer := 0;
    Dummy3 : Boolean := False;
Begin
  Get_Record(FILE_BLOCK, Entity.PersonId, IAddress(PersonBlk));
  With PersonBlk.Person Do Begin
    GoldDropped := PersonBlk.Person.Gold;
    Exp := 1;
    Gold := 0;
    Level := 0;
    Weapon := 0;
    ArmorClass := 0;
    Stats := Zero;
    For I := 1 to MaxPersonAttri Do
      Attributes[I] := 6 + Rnd(6) + Rnd(4);
    MaxHealth := 12 + Rnd(8) + Rnd(4);
    MaxMana := 6 + Rnd(4) + Rnd(2);
    MaxSpeed := 100 + Rnd(40) + Rnd(20);
    Health := MaxHealth;
    Mana := MaxMana;
  End;
  Update_Record(FILE_BLOCK, Entity.PersonId, IAddress(PersonBlk));

  List := Zero;
  Get_Record(FILE_ITEMMAP, Entity.InvenId, IAddress(InvenMap));
  For I := 1 To ItemMapSize Do
    If (InvenMap.Ids[I] > 0) And (InvenMap.Pos[I] > 0) Then Begin
      List[I] := InvenMap.Ids[I];
      InvenMap.Ids[I] := 0;
      Invenmap.Pos[I] := 0;
    End;  
  Update_Record(FILE_ITEMMAP, Entity.InvenId, IAddress(InvenMap));
  ReadEntity(Where, NodeIn);
  For I := 1 to ItemMapSize Do
    If (List[I] > 0) Then
      PutToken(List[I], Where, NodeIn.RoomMapId, POS_OBJ_HERE, TRUE);

  Get_Record(FILE_BLOCK, NodeIn.RoomId, IAddress(RoomBLK));
  RoomBlk.Room.Goldhere := RoomBlk.Room.Goldhere + GoldDropped;
  Update_Record(FILE_BLOCK, NodeIn.RoomId, IAddress(RoomBlk));

  TakeToken(EntityId, NodeIn.RoomMapId, OldPos);
  LogEvent(EntityId, 0, EV_INFORM, Where, 
  Entity.Name+'''s body disappeared in a puff of orange smoke. ');
  ReadEntity(PersonBlk.Person.Home, Home);
  PutToken(EntityId, PersonBlk.Person.Home, Home.RoomMapId, POS_IN_ROOM, TRUE);
  LogEvent(EntityId, 0, EV_INFORM, PersonBlk.Person.Home,
  Entity.Name+' appears in a puff of orange smoke. ');

  ReadEntity(PersonBlk.Person.Class, Cls);
  AffectPerson(Cls.ClassEffect, EntityId, Where, Entity, PersonBlk,
  Dummy1, Dummy2, Dummy3, FALSE, FALSE);

  If Print Then Begin
    ImDead := False;
    PutLine('You feel a great weight has been lift off you.. ');
    PutLine('You have been resurrected! ', 1);
    MyLocation := PersonBlk.Person.Home;
    SetMyEvent;
    DescRoomIn(Home, MyEntityId, False, IsWindy, IsWindy);
  End;
End;

Procedure TimeHeal(EntityId, Where : $UWord);
Var Entity : EntityType; PersonBlk : BlockType;
  Amount, TimeTicked : Integer := 0;
  LogHealth, LogMana : Boolean := False;
Begin
  ReadEntity(EntityId, Entity);
  Get_Record(FILE_BLOCK, Entity.PersonId, IAddress(PersonBlk));
  With PersonBlk.Person Do Begin
    TimeTicked := DiffInTick(GetRealTime, LastHeal);
    Amount := Attributes[ATT_CON]*TimeTicked Div 10000;
    If (Amount > 0) And (PersonBlk.Person.Health > 0) Then Begin
      If (Health < MaxHealth) Then Begin
        If (Amount + Health) > Maxhealth Then
          Health := MaxHealth
        Else Health := Amount + Health;
        LogHealth := True;
      End;
      If (Mana < MaxMana) Then Begin
        If (Amount + Mana) > Maxmana Then
          Mana := Maxmana
        Else Mana := Mana + Amount;
        LogMana := True;
      End;
      LastHeal := GetRealTime;
      Update_Record(FILE_BLOCK, Entity.PersonId, IAddress(PersonBlk));
      If LogHealth Then Begin
        LogEvent(EntityId, 0, EV_HEALTH, Where, '', FALSE,
        HealthLevel(Health, Maxhealth));
        If (EntityId = MyEntityId) Then
          DescHealth('You', HealthLevel(Health, maxhealth), TRUE);
      End;
    End Else Begin
      Free_Record(FILE_BLOCK);
      If (Health = 0) Then
        Resurrect(Entity, PersonBlk, EntityId, Where, (EntityId = MyEntityId));
    End;
  End;  (* with *)
End;

[Global]
Procedure Driver;
Var FirstCall : [Static] Boolean := True;
   TickerCheck : [Static] Integer;
   TickerHeal  : [Static] Integer;
   TickerNpc : [Static] Integer;
Begin
  If InPlay Then Begin
    If FirstCall Then Begin
      FirstCall := False;
      TickerCheck := GetTick;
      TickerHeal := GetTick;
      TickerNpc := GetTick;
    End;
    If TickerCheck < GetTick Then Begin
      TickerCheck := TickerCheck + 2;
      CheckEvent;
    End;
    If TickerHeal < GetTick Then Begin  (* healing and more.. *)
      TickerHeal := TickerHeal + 3000;
      TimeHeal(MyEntityId, MyLocation);
    End;
    If TickerNpc < GetTick Then Begin
      TickerNpc := TickerNpc + 3;
      If (Not ImDead) Then
        DriveEnemyList;
    End;
  End;
End;

[Hidden]
Procedure GainExp(EntityId : $UWord; ExpGained : Integer;
   Print, IsKill : Boolean);
Var Index, OldLevel : Integer;
    S : String_Type;
    Entity : EntityType;
    PersonBlk : BlockType;
Begin
  Read_Record(FILE_ENTITY, EntityId, IAddress(Entity));
  Get_Record(FILE_BLOCK, Entity.PersonId, IAddress(PersonBlk));
  With PersonBlk.Person Do Begin
    OldLevel := Level;
    Repeat
      If (Exp + ExpGained) >= LevelExpTable[Level+1] Then Begin
        Level := Level + 1;
        Exp := LevelExpTable[Level];
        Index := Rnd(MaxPersonAttri-1)+1;
        Attributes[Index] := Attributes[Index] + Rnd(2);
        ExpGained := (ExpGained + Exp - LevelExpTable[Level]) Mod 2;
      End Else Begin
        Exp := Exp + ExpGained;
        ExpGained := 0;
      End;
    Until (ExpGained = 0);
  End;
  Update_Record(FILE_BLOCK,  Entity.PersonId, IAddress(PersonBlk));
  If Print And (PersonBlk.Person.Level > OldLevel) Then Begin
    WriteV(S, 'You have gained ', (PersonBlk.Person.Level-OldLevel):0, ' level! ');
    PutLine(S);
  End;
End;

Procedure Freeze(T : Real; Id : $UWord);
Var EndTime : Integer;
    Entity : EntityType;
    PersonBlk : BlockType;
Begin
  If (Id = MyEntityId) Then Begin
    EndTime := GetTick + Round(T * 10);
    While (GetTick < EndTime) Do Begin
      Wait(0.1);
      Driver;
    End;
  End Else Begin
    ReadEntity(Id, Entity);
    Get_Record(FILE_BLOCK, Entity.PersonId, IAddress(PersonBlk));
    PersonBlk.Person.ActionDelay := PersonBlk.Person.ActionDelay+Round(T*10);
    Update_Record(FILE_BLOCK, Entity.PersonId, IAddress(PersonBlk));
  End;
End;

Procedure HandleEvent;  (* forward *)
Var Entity, TargEntity : EntityType;
    AnExit : ExitType;
    Print : Boolean;

 Procedure HandleMoveIn;    (* P1 : exit id; P2 : room index *)
 Begin
   With AnEvent Do Begin
     ReadExit(Parms[1], AnExit);
     If Not PrintDesc(AnExit.InDesc[Parms[2]], Entity.Name) Then
       PutLine(Entity.Name+' came into the room from '+
               DirTable[AnExit.Dire[Parms[2]]]+'.');
     If Print Then UpdateRoomNpc(FALSE, Sender);
   End;
 End;

 Procedure HandleMoveOut;   (* P1 : exit id; P2 : room index *)
 Begin
   With AnEvent Do Begin
     ReadExit(Parms[1], AnExit);
     If Not PrintDesc(AnExit.OutDesc[Parms[2]], Entity.Name) Then
       PutLine(Entity.Name+' has gone '+
               DirTable[AnExit.Dire[Parms[2]]]+'.');
     If Print Then UpdateRoomNpc(TRUE, Sender);
   End;
 End;

 Procedure HandleMoveFail;  (* P1 : exit id; P2 : room index *)
 Begin
   With AnEvent Do Begin
     ReadExit(Parms[1], AnExit);
     If Not PrintDesc(AnExit.FailDesc[Parms[2]], Entity.Name) Then
       PutLine(Entity.Name+' fails to go '+
               DirTable[AnExit.Dire[Parms[2]]]+'.');
   End;
 End;

 Procedure HandleAttack;     (* P1 : damage; P2 : weapon id   *)     
 Var WeaponEntity : EntityType;
     PersonBlk : BlockType;
     AttkEffect : EffPtr_Type;
     ExpGained : Integer := 0;
     WasDead : Boolean := False;
 Begin
   With AnEvent Do Begin
     If (Target = EntityId) Then Begin
       If Print Then DescAttack(Entity.Name, 'you');
       If (Parms[2] > 0) Then Begin
         ReadEntity(Parms[2], WeaponEntity);
         AttkEffect := WeaponEntity.AttEffect;
       End Else AttkEffect := Zero;
       AffectPerson(AttkEffect, Target, Location, TargEntity, PersonBlk,
       Parms[1], ExpGained, WasDead, Print, FALSE);
       If Not WasDead And (PersonBlk.Person.Health = 0) Then Begin
         If Print Then ImDead := True;
         LogEvent(EntityId, Sender, EV_KILLED, Location, '', 
         (Entity.Driver = 0), ExpGained);
       End Else Begin
         LogEvent(EntityId, 0, EV_HEALTH, Location, '', FALSE,
         HealthLevel(PersonBlk.Person.Health, PersonBlk.Person.Maxhealth));
       End;
     End Else If Print Then
       DescAttack(Entity.Name, TargEntity.Name);
   End;
 End;

 Procedure HandleHealth;     (* P1: health level *)
 Begin
   With AnEvent Do Begin
     If (Sender = EntityId) Then
       DescHealth('You', Parms[1], TRUE)
     Else DescHealth(Entity.Name, Parms[1], FALSE);
   End;
 End;

 Procedure HandleKilled;     (* P1: experience *)
 Begin
   With AnEvent Do Begin
     If (Target = EntityId) Then Begin
       If Print Then PutLine('You have killed '+Entity.Name+'! ');
       GainExp(EntityId, Parms[1], Print, TRUE);
     End Else If Print Then
         PutLine(Entity.Name+' has been slain by '+TargEntity.Name+'! ');
   End;
 End;

 Procedure HandleSay;
 Begin
   With AnEvent Do Begin
     PutLine(Entity.Name+' says, " '+Msg+' "');
   End;
 End;

 Procedure HandleCast;       (* P1: spell id;  P2 : direction; *)
 Var                         (* P3: location                   *)
   Damage, ExpGained : Integer := 0;
   WasDead : Boolean := False;
   PersonBlk : BlockType;
   Spell : EntityType;
 Begin
   With AnEvent Do Begin
     ReadEntity(Parms[1], Spell);
     If (Target = EntityId) Or (Target = ALL_TARGET) Then Begin
       If (Target = ALL_TARGET) Then
         ReadEntity(EntityId, TargEntity);
       If Print Then Begin
         DescSpellAttack(Entity.Name, 'you', Spell.Name, (Parms[3] <> Location),
         (Target = ALL_TARGET));
       End;
       AffectPerson(Spell.SpellEffect, EntityId, Location, TargEntity, 
       PersonBlk, Damage, ExpGained, WasDead, Print, FALSE);
       If Not WasDead And (PersonBlk.Person.Health = 0) Then Begin
         LogEvent(EntityId, Sender, EV_KILLED, Location, '', 
         (Entity.Driver = 0), ExpGained);
         If (Location <> Parms[3]) Then
           LogEvent(EntityId, Sender, EV_KILLED, Parms[3], '', 
           (Entity.Driver = 0), ExpGained);
       End Else Begin
         LogEvent(EntityId, 0, EV_HEALTH, Location, '', FALSE,
         HealthLevel(PersonBlk.Person.Health, PersonBlk.Person.Maxhealth));
       End;
     End Else If Print Then
       DescSpellAttack(Entity.Name, TargEntity.Name, Spell.Name,
       (Parms[3] <> Location), FALSE);
   End;
 End;

 Procedure HandleFreeze;     (* P1: delay time *)
 Begin
   With AnEvent Do Begin
     If (Target = EntityId) Then Begin
       If Print Then PutLine('You can''t move! ');
       Freeze(Parms[1], EntityId);
     End Else If Print Then
       PutLine(TargEntity.Name+' is frozen. ');
  End;
 End;

 Procedure HandleTeleport;   (* P1: destination *)
 Var NodeIn : EntityType;
     OldPos : $UWord := 0;
 Begin
   With AnEvent Do Begin
     If (Target = EntityId) Then Begin
       ReadEntity(Location, NodeIn);
       TakeToken(Target, NodeIn.RoomMapId, OldPos);
       ReadEntity(Parms[1], NodeIn);
       PutToken(Target, Parms[1], NodeIn.RoomMapId, OldPos, TRUE);
       LogEvent(Target, 0, EV_INFORM, Parms[1], TargEntity.Name+
       ' appears in a puff of purple smoke. ', FALSE);
       If Print Then Begin
         MyLocation := Parms[1];
         SetMyEvent;
         DescRoomIn(NodeIn, EntityId, TRUE, IsWindy, IsWindy);
      End;
    End Else If Print Then
      PutLine(TargEntity.Name+' vanished in a puff of purple smoke. ');
   End;
 End;

Begin
  Print := (EntityId = MyEntityId);
  With AnEvent Do
    If ((Location =  Loc) Or (Location = GLOB_LOCATION)) And
       ((Sender <> EntityId) Or IsWindy Or (Action = EV_HEALTH)) Then Begin
      If (Sender > 0) Then
        ReadEntity(Sender, Entity);            (* gonna need this *)
      If (Target > 0) And (Target < ALL_TARGET) Then
        ReadEntity(Target, TargEntity);
      Case Action Of
        EV_INFORM    : If Print Then PutLine(Msg);
        EV_MOVE_IN   : If Print Then HandleMoveIn;
        EV_MOVE_OUT  : If Print Then HandleMoveOut;
        EV_MOVE_FAIL : If Print Then HandleMoveFail;
        EV_ATTACK    : HandleAttack;
        EV_HEALTH    : If Print Then HandleHealth;
        EV_KILLED    : HandleKilled;
        EV_SAY       : If Print Then HandleSay;
        EV_CAST      : HandleCast;
        EV_FREEZE    : HandleFreeze;
        EV_TELEPORT  : HandleTeleport;
      End;
    End;
End;

End.
