
[Inherit('M1', 'M2', 'M3', 'M4', 'M5', 'M6', 'M7', 'M7_2','M7_3'),
 Environment('M9')]

Module M9;


[External, Hidden]
Procedure UpdateEnemyList(Id : $UWord; Var Npc : EntityType); External;

(* action functions *)

Function CanAct(Var PersonBlk : BlockType): Boolean;
Begin
  With PersonBlk.Person Do Begin
    CanAct := (DiffInTick(GetRealTime, LastAct) > ActionDelay);
  End;
End;

Function MovePerson(Var Entity, NodeIn : EntityType; 
   Var PersonBlk, RoomBlk : BlockType; Var Location : $UWord;
   EntityId, Dir : $UWord; Print : Boolean;
   MoveHidden, MoveInvisi : Boolean := False): Boolean;
Var NodeTo : EntityType; AnExit : ExitType;
    OldPos, NewPos, Origin, Dest : $UWord; 
    Moved : Boolean := False;
    Dummy1, Dummy2 : Integer := 0;
    Dummy3 : Boolean := False;

 Function CanPass: Boolean;
 Var GuardPos, Guardian : $UWord;
 Begin
   Case Dir Of
     NORTH : GuardPos := POS_GUARD_N;
     SOUTH : GuardPos := POS_GUARD_S;
     WEST  : GuardPos := POS_GUARD_W;
     EAST  : GuardPos := POS_GUARD_E;
     UP    : GuardPos := POS_GUARD_U;
     DOWN  : GuardPos := POS_GUARD_D;
   End;
   If LookUpMap(Guardian, NodeIn.RoomMapId, 0, FALSE, TRUE, GuardPos) Then
     CanPass := (EntityId = Guardian)
   Else CanPass := True;
 End;

 Procedure SetIndex;
 Begin
   ReadExit(RoomBlk.Room.Exits[Dir], AnExit);
   If (AnExit.Node[1] = Location) Then Begin
     Origin := 1;
     Dest   := 2;
   End Else Begin
     Origin := 2;
     Dest   := 1;
   End;
 End;

Begin
  If (RoomBlk.Room.Exits[Dir] > 0) Then Begin
    If CanPass Then Begin
      SetIndex;
      If Not HaveEffect(AnExit.Effect, Entity, PersonBlk, Print, FALSE) Then Begin
        If TakeToken(EntityId, NodeIn.RoomMapId, OldPos) Then Begin
          If (OldPos = POS_HIDDEN) And (MoveHidden) Then Begin
            NewPos := POS_HIDDEN;
            If Print Then PutLine('You move under the shadow. ');
          End Else If (OldPos = POS_INVISI) And (MoveInvisi) Then Begin
            NewPos := POS_INVISI;
            If Print Then PutLine('You move invisiblely. ');
          End Else Begin
            NewPos := POS_IN_ROOM;
            LogEvent(EntityId, 0, EV_MOVE_OUT, Location, '', FALSE,
               RoomBlk.Room.Exits[Dir], Origin);
          End;
          Freeze(200.0/PersonBlk.Person.MaxSpeed, EntityId);
          AffectPerson(AnExit.Effect, EntityId, Location, Entity, PersonBlk,
          Dummy1, Dummy2, Dummy3, Print, FALSE);
          ReadEntity(AnExit.Node[Dest], NodeTo);
          If PutToken(EntityId, AnExit.Node[Dest], NodeTo.RoomMapId, NewPos,
          TRUE) Then Begin
            Location := AnExit.Node[Dest];  (* return value *)
            LogEvent(EntityId, 0, EV_MOVE_IN, Location, '', FALSE,
               RoomBlk.Room.Exits[Dir], Dest);
            Moved := True;
          End Else LogErr('Fatal Error: MovePerson: PutToken ');
        End Else LogErr('Fatal Error: MovePerson: TakeToken ');
      End Else LogEvent(EntityId, 0, EV_MOVE_FAIL, Location, '', FALSE,
                  RoomBlk.Room.Exits[Dir], Origin);
    End Else If Print Then PutLine('Your way is blocked! ');
  End Else If Print Then PutLine('You can''t go that way! ');
  MovePerson := Moved;
End;

Procedure GetObj(Var Entity, NodeIn : EntityType;
  Var PersonBlk : BlockType;
  EntityId, Where, What : $UWord;
  Print : Boolean := False);
Var Obj : EntityType;
    OldPos : $UWord := 0;
    Dummy1, Dummy2 : Integer := 0;
    Dummy3 : Boolean := False;
Begin
  ReadEntity(What, Obj);
  If Not HaveEffect(Obj.GetEffect, Entity, PersonBlk, Print, FALSE) Then Begin
    If TakeToken(What, NodeIn.RoomMapId, OldPos) Then Begin
      If PutToken(What, EntityId, Entity.InvenId, POS_INVEN, FALSE) Then Begin
        If Print Then PutLine('You have taken a(n) '+Obj.Name+'.');
        LogEvent(EntityId, 0, EV_INFORM, Where, Entity.Name+' took a(n) '
        +Obj.Name+'.');
        AffectPerson(Obj.GetEffect, EntityId, Where, Entity, PersonBlk,
        Dummy1, Dummy2, Dummy3, Print, FALSE);
      End Else Begin
        PutToken(What, Where, NodeIn.RoomMapId, OldPos, TRUE);
        If Print Then PutLine('You can''t hold any more objects. ');
      End;
    End Else If Print Then PutLine('Someone else got it before you. ');
  End Else LogEvent(EntityId, 0, EV_INFORM, Where,
    Entity.Name+' fail to get a(n) '+Obj.Name+'.');
End;

Procedure GetGold(Var Entity, NodeIn : EntityType;
  Var PersonBlk, RoomBlk : BlockType;
  EntityId, Where : $UWord; Amount : Integer;
  Print : Boolean);
Begin
  Get_Record(FILE_BLOCK, NodeIn.RoomId, IAddress(RoomBlk));
  If (RoomBlk.Room.Goldhere >= Amount) Then Begin
    RoomBlk.Room.Goldhere := RoomBlk.Room.Goldhere - Amount;
    Update_Record(FILE_BLOCK, NodeIn.RoomId, IAddress(RoomBlk));
    Get_Record(FILE_BLOCK, Entity.PersonId, IAddress(PersonBlk));
    PersonBlk.Person.Gold := PersonBlk.Person.Gold + Amount;
    Update_Record(FILE_BLOCK, Entity.PersonId, IAddress(PersonBlk));
    If Print Then PutLine('got it! ');
    LogEvent(EntityId, 0, EV_INFORM, Where, Entity.Name+' took some gold. ');
  End Else Begin
    Free_Record(FILE_BLOCK);
    If Print Then PutLine('There isn''t that much gold here. ');
  End;
End;

Procedure DropObj(Var Entity, NodeIn : EntityType;
  Var PersonBlk : BlockType;
  EntityId, Where, What : $UWord;
  Print : Boolean := False);
Var Obj : EntityType;
    OldPos : $UWord := 0;
    Dummy1, Dummy2 : Integer := 0;
    Dummy3 : Boolean := False;
Begin
  ReadEntity(What, Obj);
  If Not HaveEffect(Obj.GetEffect, Entity, PersonBlk, Print, TRUE) Then Begin
    If TakeToken(What, Entity.InvenId, OldPos) Then Begin
      PutToken(What, Where, NodeIn.RoomMapId, POS_OBJ_HERE, TRUE);
      If Print Then PutLine('You dropped a(n) '+Obj.Name+'.');
      LogEvent(EntityId, 0, EV_INFORM, Where, Entity.Name+' dropped a(n) '
      +Obj.Name+'.');
      AffectPerson(Obj.GetEffect, EntityId, Where, Entity, PersonBlk,
      Dummy1, Dummy2, Dummy3, Print, TRUE);
    End Else If Print Then PutLine('You are not holding '+Obj.Name+'.');
  End Else LogEvent(EntityId, 0, EV_INFORM, Where,
    Entity.Name+' fail to drop a(n) '+Obj.Name+'.');
End;

Procedure DropGold(Var Entity, NodeIn : EntityType;
  Var PersonBlk, RoomBlk : BlockType;
  EntityId, Where : $UWord; Amount : Integer;
  Print : Boolean;
  Prived : Boolean := False);
Begin
  Get_Record(FILE_BLOCK, Entity.PersonId, IAddress(PersonBlk));
  If (PersonBlk.Person.Gold >= Amount) Then Begin
    PersonBlk.Person.Gold := PersonBlk.Person.Gold - Amount;
    Update_Record(FILE_BLOCK, Entity.PersonId, IAddress(PersonBlk));
    Get_Record(FILE_BLOCK, NodeIn.RoomId, IAddress(RoomBlk));
    RoomBlk.Room.Goldhere := RoomBlk.Room.Goldhere + Amount;
    Update_Record(FILE_BLOCK, NodeIn.RoomId, IAddress(RoomBlk));
    If Print Then PutLine('dropped. ');
    LogEvent(EntityId, 0, EV_INFORM, Where, Entity.Name+' dropped some gold. ');
  End Else If Prived Then Begin
    Free_Record(FILE_BLOCK);
    Get_Record(FILE_BLOCK, NodeIn.RoomId, IAddress(RoomBlk));
    RoomBlk.Room.Goldhere := RoomBlk.Room.Goldhere + Amount;
    Update_Record(FILE_BLOCK, NodeIn.RoomId, IAddress(RoomBlk));
    If Print Then PutLine('You create some gold here. ');
    LogEvent(EntityId, 0, EV_INFORM, Where, Entity.Name+' create some gold. ');
  End Else Begin
    Free_Record(FILE_BLOCK);
    If Print Then PutLine('You don''t have that much gold. ');
  End;
End;

Procedure TakeObj;
Begin
End;

Procedure AttackPerson(Var Attk, Targ, NodeIn : EntityType;
  Var PersonBlk : BlockType; Attker, Target, Loc : $UWord; Print : Boolean);
Var Damage, OldPos : $UWord;
Begin
  GetLocation(Attker, Loc, OldPos);  (* I only need oldpos *)
  If (OldPos = POS_HIDDEN) Then Begin
    ChangeMapPos(Attker, Loc, NodeIn.RoomMapId, POS_IN_ROOM);
    If Print Then PutLine('You attack '+Targ.Name+' from under the shadow! ');
  End Else If (OldPos = POS_INVISI) Then Begin
    ChangeMapPos(Attker, Loc, NodeIn.RoomMapId, POS_IN_ROOM);
    If Print Then PutLine('You attack '+Targ.Name+' from thin air! ');
  End Else If Print Then DescAttack('You', Targ.Name);
  With PersonBlk.Person Do Begin
    Damage := (Attributes[ATT_STR] + Attributes[ATT_DEX]) Div 12;
    If (Stats[STAT_DEFEND]) Then
      Freeze( 600.0 / MaxSpeed, Attker)
    Else Freeze( 400.0 / MaxSpeed, Attker);
    LogEvent(Attker, Target, EV_ATTACK, Loc, '', (Targ.Driver = 0),
    Damage, Weapon);
    If (Targ.Driver = 0) Then
      UpdateEnemyList(Target, targ);
  End;
End;

Procedure WieldWeapon(Var Entity, Obj : EntityType;
  Var PersonBlk : BlockType;
  EntityId, Where, What : $UWord;
  Print : Boolean);
Var Dummy1, Dummy2 : Integer := 0;
    Dummy3 : Boolean := False;
Begin
  Read_Record(FILE_BLOCK, Entity.PersonId, IAddress(PersonBlk));
  If (PersonBlk.Person.Weapon = 0) Then Begin
    If (Not HaveEffect(Obj.WornEffect, Entity, PersonBlk, Print, FALSE)) Then Begin
      If ChangeMapPos(What, EntityId, Entity.InvenId, POS_WEAPON) Then Begin
        Get_Record(FILE_BLOCK, Entity.PersonId, IAddress(PersonBlk));
        PersonBlk.Person.Weapon := What;
        Update_Record(FILE_BLOCK, Entity.PersonId, IAddress(PersonBlk));
        If Print Then PutLine('You are now wielding a(n) '+Obj.Name+'.');
        AffectPerson(Obj.WornEffect, EntityId, Where, Entity, PersonBlk,
        Dummy1, Dummy2, Dummy3, Print, FALSE);
      End Else If Print Then
        PutLine('You are not holding'+Obj.Name+'.');
    End;
  End Else PutLine('You are already wielding another weapon. ');
End;

[Hidden]
Function CanWear(Var PersonBlk : BlockType;
  Var Obj: EntityType;
  Var Slot : $UWord): Boolean;
Begin
  Case Obj.ObjKind Of
    OBJ_ARMOR : Slot := STAT_WORN_ARMOR;
    Otherwise Slot := 0;
  End;
  If (Slot > 0) Then
    CanWear := Not PersonBlk.Person.Stats[Slot]
  Else CanWear := False;
End;

Procedure WearArmor(Var Entity, Obj : EntityType;
  Var PersonBlk : BlockType;
  EntityId, Where, What : $UWord;
  Print : Boolean);
Var Dummy1, Dummy2 : Integer := 0;
    Dummy3 : Boolean := False;
    Slot : $UWord := 0;
Begin
  Read_Record(FILE_BLOCK, Entity.PersonId, IAddress(PersonBlk));
  If CanWear(PersonBlk, Obj, Slot) Then Begin
    If (Not HaveEffect(Obj.WornEffect, Entity, PersonBlk, Print, FALSE)) Then Begin
      If ChangeMapPos(What, EntityId, Entity.InvenId, POS_ARMOR) Then Begin
        Get_Record(FILE_BLOCK, Entity.PersonId, IAddress(PersonBlk));
        PersonBlk.Person.Stats[Slot] := True;
        Update_Record(FILE_BLOCK, Entity.PersonId, IAddress(PersonBlk));
        If Print Then PutLine('You are now wearing a(n) '+Obj.Name+'.');
        AffectPerson(Obj.WornEffect, EntityId, Where, Entity, PersonBlk,
        Dummy1, Dummy2, Dummy3, Print, FALSE);
      End Else If Print Then
        PutLine('You are not holding'+Obj.Name+'.');
    End;
  End Else PutLine('You are wearing something else. ');
End;

Procedure TakeoffObj(Var Entity, Obj : EntityType;
  Var PersonBlk : BlockType;
  EntityId, Where, What : $UWord;
  Print : Boolean);
Var Dummy1, Dummy2 : Integer := 0;
    Dummy3 : Boolean := False;
    Slot : $UWord := 0;
Begin
  If Not HaveEffect(Obj.WornEffect, Entity, PersonBlk, Print, TRUE) Then Begin
    If ChangeMapPos(What, EntityId, Entity.InvenId, POS_INVEN) Then Begin
      Get_Record(FILE_BLOCK, Entity.PersonId, IAddress(PersonBlk));
      If (PersonBlk.Person.Weapon <> What) Then Begin
        CanWear(PersonBlk, Obj, Slot);
        If (Slot > 0) Then
          PersonBlk.Person.Stats[Slot] := FALSE;
      End Else PersonBlk.Person.Weapon := 0;
      Update_Record(FILE_BLOCK, Entity.PersonId, IAddress(PersonBlk));
      If Print Then PutLine('You take off '+Obj.Name+'.');
      AffectPerson(Obj.WornEffect, EntityId, Where, Entity, PersonBlk,
      Dummy1, Dummy2, Dummy3, Print, TRUE);
    End Else PutLine('You are not wielding '+Obj.Name+'.');
  End;
End;

Function GetExitDest(Var NodeIn : EntityType;
  From, Dir : $UWord;
  Var Dest : $UWord): Boolean;
Var RoomBlk : BlockType;
    AnExit : ExitType;
Begin
  ReadBlock(NodeIn.RoomId, RoomBlk);
  If (RoomBlk.Room.Exits[Dir] > 0) Then Begin
    ReadExit(RoomBlk.Room.Exits[Dir], AnExit);
    If (AnExit.Node[1] = From) Then
      Dest := AnExit.Node[2]
    Else Dest := AnExit.Node[1];
  End Else Dest := 0;
  GetExitDest := (Dest > 0);
End;

Procedure CastSpell(Var Entity, NodeIn, Spell : EntityType;
  Var PersonBlk : BlockType;
  EntityId, Where, SpellId, Target, Dir : $UWord;
  Print : Boolean);
Var Dummy1, Dummy2 : Integer := 0;
    Dummy3, Done : Boolean := False;
    TargEntity, RoomIn : EntityType;
    Dest, I : $UWord := 0;
    DriveIt : Boolean := False;
Begin
  If Print Then Begin
    If (Target <> ALL_TARGET) Then Begin
      ReadEntity(Target, TargEntity);
      If (Dir > 0) And (Spell.Power > 0) Then
        PutLine('You cast a '+Spell.Name+' toward '+DirTable[Dir]+' at '+
        TargEntity.Name+'! ')
      Else PutLine('You cast a '+Spell.Name+' at '+TargEntity.Name+'! ');
      If (TargEntity.Driver = 0) Then Begin
        DriveIt := True;
        UpdateEnemyList(Target, TargEntity);
      End;
    End Else Begin
      If (Dir > 0) And (Spell.Power > 0) Then
        PutLine('You cast a '+Spell.Name+' toward the '+DirTable[Dir]+'! ')
      Else PutLine('You cast a '+Spell.Name+'! ');
    End;
  End;
  Freeze(400.0/PersonBlk.Person.MaxSpeed, EntityId);
  If (Dir > 0) Then Begin  (* remote spell *)
    LogEvent(EntityId, Target, EV_CAST, Where, '', False, SpellId, Dir, Where);
    Dest := Where;
    RoomIn := NodeIn;
    While Not Done Do Begin
      If GetExitDest(RoomIn, Dest, Dir, Dest) Then Begin
        ReadEntity(Dest, RoomIn);
        I := I + 1;
        PutLine(Spell.Name+' flew '+DirTable[Dir]+' into '+RoomIn.Name+'. ');
        LogEvent(EntityId, Target, EV_CAST, Dest, '', DriveIt, SpellId,
        Dir, Where);
        If (Spell.SpellFlags[SP_RND_DIR]) Then Dir := Rnd(5)+1;
        Done := (I = Spell.Power);
      End Else Done := True;
    End;
  End Else
    LogEvent(EntityId, Target, EV_CAST, Where, '', DriveIt, SpellId, Dir, Where);
  AffectPerson(Spell.CastEffect, EntityId, Where, Entity, PersonBlk,
  Dummy1, Dummy2, Dummy3, Print, FALSE);
End;

End.
