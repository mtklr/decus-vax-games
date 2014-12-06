[Inherit('M1', 'M2', 'M3', 'M4', 'M5'),
 Environment('M6')]

Module M6;


(*  effect functions  *)

Const
  EFF_HURT = 1; EFF_HEAL = 2; EFF_G_GOLD = 3; EFF_T_GOLD = 4;
  EFF_MIN_LEV = 5; EFF_CLS_ONLY = 6; EFF_CHNG_CLS = 7; EFF_G_ATTRI = 8;
  EFF_G_MAXHEALTH = 9; EFF_G_MAXMANA = 10; EFF_G_MAXSPEED = 11; EFF_G_AC = 12;
  EFF_FREEZE = 13; EFF_TELEPORT = 14;
  MaxEffect = 14;

[Hidden]
Const
  BufferSize = 100;

[Hidden]
Type
  BufferType = Record
    Top : Integer;
    Effects : Array[1..BufferSize] Of Effect_Type;
  End;

[Hidden]
Var
  EffectFile : File Of Effect_Type;
  Buffer : BufferType;

Var
  EffectTable : [Readonly] Array[1..MaxEffect] Of Short_String_Type := (
    'hurt', 'heal', 'give gold', 'take gold',
    'minimum level', 'class only', 'change class', 'gain attributes',
    'gain max health', 'gain max mana', 'gain max speed', 'gain armor class',
    'freeze', 'teleport');

  EffPs1Table : [Readonly] Array[1..MaxEffect] Of Short_String_Type := (
    'damage', 'health', 'amount', 'amount',
    'minimum level', 'class', 'class', 'attribute',
    'amount', 'amount', 'amount', 'amount',
    'time', 'location');

  EffPs2Table : [Readonly] Array[1..MaxEffect] Of Short_String_Type := (
    '', '', '', '',
    '', '', '', 'amount',
    '', '', '', '',
    '', '');

(* external event functions *)

[External, Hidden]
Procedure LogEvent(S, T, A, L : $UWord; M : String_Type := '';
  DI : Boolean := False; P1, P2, P3, P4, P5, Id : Integer := 0);
External;

Procedure SetUpEffect;
Var IsOpen : [Static] Boolean := False;
Begin
  If IsOpen Then Begin
    IsOpen := False; Close(EffectFile);
  End Else Begin
    IsOpen := True;
    Open_File(FILE_EFFECT, EffectFile, Root+'Effect.Mon', Size(Effect_Type));
  End;
End;

Procedure InitEffectFile(Max : $UWord);
Var Effect : Effect_Type; I : Integer;
Begin
  Effect := Zero;
  For I := 1 To Max Do Put_Record(FILE_EFFECT, I, IAddress(Effect));
  InitAlloc(Alloc_EFFECT, Max);
End;

Procedure IncEffectQuota(Amount : $UWord);
Var Effect : Effect_Type;
    I, Start, Finish : $UWord := 0;
Begin
  Effect := Zero;
  If Inc_Alloc_Quota(ALLOC_EFFECT, Amount, Start, Finish) Then
    For I := Start To Finish Do
      Put_Record(FILE_EFFECT, I, IAddress(Effect))
  Else LogErr('Error increase effect quota. ');
End;

[Hidden]
Procedure LoadBuffer(Ptr : EffPtr_Type);
Var Effect : Effect_Type; I : Integer;
Begin
  Buffer := Zero;
  If Ptr.FromEff > 0 Then Begin
    For I := Ptr.FromEff to Ptr.ToEff Do Begin
      Read_Record(FILE_EFFECT, I, IAddress(Effect));
      Buffer.Effects[I - Ptr.FromEff + 1] := Effect;
    End;
    Buffer.Top := Ptr.ToEff - Ptr.FromEff + 1;
  End;
End;

[Hidden]
Procedure SaveBuffer(Var Ptr : EffPtr_Type);
Var I : $UWord := 0; Done : Boolean := False;
Begin
  If Buffer.Top > 0 Then Begin
    If Alloc_Items(ALLOC_EFFECT, Ptr.FromEff, Buffer.Top) Then Begin
      Ptr.ToEff := Ptr.FromEff + Buffer.Top - 1;
      For I := 1 To Buffer.Top Do
        Update_Record(FILE_EFFECT, Ptr.FromEff+I-1, IAddress(Buffer.Effects[I]));
    End Else LogErr('Error allocating effectss. ');
  End;
End;

Procedure DeleteEffect(Var Ptr : EffPtr_Type);
Var Effect : Effect_Type; I : Integer;
Begin
  Effect := Zero;
  If Ptr.FromEff > 0 Then Begin
    For I := Ptr.FromEff To Ptr.ToEff Do
      Update_Record(FILE_EFFECT, I, IAddress(Effect));
    Dealloc_Items(ALLOC_EFFECT, Ptr.FromEff, Ptr.ToEff - Ptr.FromEff + 1);
    Ptr.FromEff := 0; Ptr.ToEff := 0;
  End;
End;

Function GrabEffect(Var Effect : Effect_Type; Var S : String_Type): Boolean;
Var Index : $UWord := 0;
Begin
  If GrabTable('Effect kind? ', EffectTable, S, Effect.Effect) Then Begin
    If (Effect.Effect = EFF_CLS_ONLY) Or (Effect.Effect = EFF_CHNG_CLS)
    Then Begin  (* special case 1 *)
      If GrabEntity('Which class? ', S, Index, ENTITY_CLASS) Then Begin
        GrabEffect := True;
        Effect.Parm1 := Index;
      End Else GrabEffect := False;
    End Else If (Effect.Effect = EFF_G_ATTRI) Then Begin  (* special case 2 *)
      If GrabTable('Attributes? ', PersonAttriTable, S, Index) Then Begin
        GrabEffect := True;
        Effect.Parm1 := Index;
        Effect.Parm2 := GrabNumberW('Amount? ', S);
      End Else GrabEffect := False;
    End Else If (Effect.Effect = EFF_TELEPORT) Then Begin  (* special case 3 *)
      If GrabEntity('Teleport to? ', S, Index, ENTITY_ROOM) Then Begin
        GrabEffect := True;
        Effect.Parm1 := Index;
      End;
    End Else Begin
      GrabEffect := True;
      If (EffPs1Table[Effect.Effect].Length > 0) Then
        Effect.Parm1 := GrabNumberW(EffPs1Table[Effect.Effect]+'? ', S);
      If (EffPs2Table[Effect.Effect].Length > 0) Then
        Effect.Parm2 := GrabNumberW(Effps2Table[Effect.Effect]+'? ', S);
    End;
  End Else GrabEffect := False;
End;

Procedure PrintEffect(L : Short_String_Type;
  Var Effect : Effect_Type);
Var L1, L2 : String_Type := '';
    Entity : EntityType;
Begin
  PutLine(L+EffectTable[Effect.Effect]+': ');
  If (Effect.Effect = EFF_CLS_ONLY) Or (Effect.Effect = EFF_CHNG_CLS)
  Then Begin  (* special case 1 *)
    ReadEntity(Effect.Parm1, Entity);
    L1 := 'Class                '+Entity.Name;
  End Else If (Effect.Effect = EFF_G_ATTRI) Then Begin  (* special case 2 *)
    L1 := 'Attributes           '+PadStr(PersonAttriTable[Effect.Parm1], 20);
    WriteV(L2, 'Amount               ', Effect.Parm2:0);
  End Else If (Effect.Effect = EFF_TELEPORT) Then Begin  (* special case 3 *)
    ReadEntity(Effect.Parm1, Entity);
    L1 := 'Destination          '+Entity.Name;
  End Else Begin
    If (Effps1Table[Effect.Effect].Length > 0) Then Begin
      WriteV(L1, Effect.Parm1:0);
      L1 := PadStr(EffPs1Table[Effect.Effect], 20)+PadStr(L1, 20);
    End;
    If (Effps2Table[Effect.Effect].Length > 0) Then Begin
      WriteV(L1, Effect.Parm1:0);
      L2 := PadStr(EffPs2Table[Effect.Effect], 20)+PadStr(L2, 20);
    End;
  End;
  PutLine(L1+L2);
End;
  
Procedure EditEffect(Var Ptr : EffPtr_Type; Var S : String_Type);
Const
  C_Quit = 1; C_Exit = 2; C_Add = 3; C_Delete = 4; C_Print = 5;
  MaxCmd = 5;
Var
  CmdTable : Array[1..MaxCmd] Of Short_String_Type :=
    ('Quit', 'Exit', 'Add', 'Delete', 'Print');
  Done : Boolean := False;
  Cmd, I : $UWord := 0;

 Procedure DoExit;
 Begin
   DeleteEffect(Ptr); SaveBuffer(Ptr); Done := True;
 End;

 Procedure DoAdd;
 Var AnEffect : Effect_Type;
 Begin
   If GrabEffect(AnEffect, S) Then Begin
     Buffer.Top := Buffer.Top + 1;
     Buffer.Effects[Buffer.Top] := AnEffect;
   End Else PutLine('Not added. ');
 End;

 Procedure DoDelete;
 Var Index, I : $UWord;
 Begin
   Index := GrabNumberW('Which one(enter a number)? ', S);
   If (Index > 0) And (Index <= Buffer.Top) Then Begin
     Buffer.Top := Buffer.Top - 1;
     For I := Index to Buffer.Top Do
       Buffer.Effects[I] := Buffer.Effects[I+1];
   End Else PutLine('Invalid range. ');
 End;

 Procedure DoPrint;
 Var I : Integer;
     L : Short_String_Type;
 Begin
   If (Buffer.Top = 0) Then
     PutLine('The buffer is empty. ')
   Else Begin
     PutLine(DivLine+DivLine);
     For I := 1 To Buffer.Top Do Begin
       WriteV(L, I:0, ': ');
       PrintEffect(PadStr(L, 5), Buffer.Effects[I]);
       PutLine(DivLine+DivLine);
     End;
   End;
 End;

Begin
  LoadBuffer(Ptr);
  While Not Done Do Begin
    If GrabTable('Edit Effect> ', CmdTable, S, Cmd) Then
      Case Cmd Of
        C_Quit   : Done := True;
        C_Exit   : DoExit;
        C_Add    : DoAdd;
        C_Delete : DoDelete;
        C_Print  : DoPrint;
      End
    Else PutLine('Type ? for a list of effect editing commands. ');
  End;
End;


(* fun stuff *)

Function HaveEffect(Ptr : EffPtr_Type;
   Entity : EntityType;
   Var PersonBlk : BlockType;
   Print, Reverse : Boolean): Boolean;
Var  Failed : Boolean := False; I : Integer := 0;
Begin
  Read_Record(FILE_BLOCK, Entity.PersonId, IAddress(PersonBlk));
  LoadBuffer(Ptr);
  While Not Failed And (I < Buffer.Top) Do Begin
    I := I + 1;
    With Buffer.Effects[I] Do Begin
      If Not Reverse Then Case Effect Of
        EFF_T_GOLD   :
          If (PersonBlk.Person.Gold < Parm1) Then Begin
            Failed := True;
            If Print Then PutLine('You don''t have enough gold! ');
          End;
        EFF_MIN_LEV  :
          If (PersonBlk.Person.Level < Parm1) Then Begin
            Failed := True;
            If Print Then PutLine('Your level is low! ');
          End;
        EFF_CLS_ONLY :
          If (PersonBlk.Person.Class <> Parm1) Then Begin
            Failed := True;
            If Print Then PutLine('You are not the right class! ');
          End;
      End Else Case Effect Of  (* reverse *)
        EFF_G_GOLD :
          If (PersonBlk.Person.Gold < Parm1) Then Begin
            Failed := True;
            If Print Then PutLine('You don''t have enough gold! ');
          End;
        EFF_G_ATTRI :
          If (PersonBlk.Person.Attributes[Parm1] <= Parm2) Then Begin
            Failed := True;
            If Print Then PutLine('Your '+PersonAttriTable[Parm1]+' is too low. ');
          End;
        EFF_G_MAXHEALTH :
          If (PersonBlk.Person.Maxhealth <= Parm1) Then Begin
            Failed := True;
            If Print Then PutLine('Your max health is too low. ');
          End;
        EFF_G_MAXMANA :
          If (PersonBlk.Person.Maxmana <= Parm1) Then Begin
            Failed := True;
            If Print Then PutLine('Your max mana is too low. ');
          End;
        EFF_G_MAXSPEED :
          If (PersonBlk.Person.Maxspeed <= Parm1) Then Begin
            Failed := True;
            If Print Then PutLine('Your max speed is too low. ');
          End;
        EFF_G_AC :
          If (PersonBlk.Person.ArmorClass <= Parm1) Then Begin
            Failed := True;
            If Print Then PutLine('Your armor class is too low. ');
          End;
      End;  (* case *)
    End;  (* with *)
  End;  (* while *)
  HaveEffect := Failed;
End;

Procedure DoDie(Var Entity : EntityType;
  Var PersonBlk : BlockType;
  Var ExpGained : Integer);
Begin
  Get_Record(FILE_BLOCK, Entity.PersonId, IAddress(PersonBlk));
  With PersonBlk.Person Do Begin
    ExpGained := Exp+1;
    Level := 0;
    Exp := 0;
    Health := 0;
  End;
  Update_Record(FILE_BLOCK, Entity.PersonId, IAddress(PersonBlk));
End;

Procedure AffectPerson(Ptr : EffPtr_Type;
  EntityId, Location : $UWord;
  Var Entity : EntityType;
  Var PersonBlk : BlockType;
  Var Damage, ExpGained : Integer;
  Var WasDead : Boolean;
  Print, Reverse : Boolean);
Var I, Tmp : Integer := 0;
    Heal, GoldGain, MHGain, MMGain, MSGain, ACGain, MHLoss, MMLoss,
    MSLoss, ACLoss, DelayTime, NewDest : Integer := 0;
    AttriGain, AttriLoss : Array[1..MaxPersonAttri] Of Integer := (0,0,0,0,0,0);
    OldClass, NewClass : $UWord := 0;
    OldCls, NewCls : EntityType;
    Dummy1, Dummy2 : Integer := 0;
    Dummy3, IsNpc : Boolean := False;

 Procedure TransEffect;
 Begin
   With Buffer.Effects[I] Do Begin
     If Not Reverse Then
       Case Effect Of
         Eff_HURT        : Damage := Damage + Parm1;
         EFF_HEAL        : Heal := Heal + Parm1;
         EFF_G_GOLD      : GoldGain := GoldGain + Parm1;
         EFF_T_GOLD      : GoldGain := GoldGain - Parm1;
         EFF_G_ATTRI     : AttriGain[Parm1] := AttriGain[Parm1] + Parm2;
         EFF_G_MAXHEALTH : MHGain := MHGain + Parm1;
         EFF_G_MAXMANA   : MMGain := MMGain + Parm1;
         EFF_G_MAXSPEED  : MSGain := MSGain + Parm1;
         EFF_G_AC        : ACGain := ACGain + Parm1;
         EFF_FREEZE      : DelayTime := DelayTime + Parm1;
         EFF_TELEPORT    : NewDest := Parm1;
         EFF_CHNG_CLS    : If Parm1<>PersonBlk.Person.Class Then NewClass := Parm1
       End
     Else
       Case Effect Of
         Eff_HURT        : Heal := Heal + Parm1;
         EFF_HEAL        : Damage := Damage + Parm1;
         EFF_G_GOLD      : GoldGain := GoldGain - Parm1;
         EFF_T_GOLD      : GoldGain := GoldGain + Parm1;
         EFF_G_ATTRI     : AttriLoss[Parm1] := AttriLoss[Parm1] + Parm2;
         EFF_G_MAXHEALTH : MHLoss := MHLoss + Parm1;
         EFF_G_MAXMANA   : MMLoss := MMLoss + Parm1;
         EFF_G_MAXSPEED  : MSLoss := MSLoss + Parm1;
         EFF_G_AC        : ACLoss := ACLoss + Parm1;
       End
   End;  (* with effect *)
 End;

 Procedure HandleEffect;
 Begin
   With PersonBlk.Person Do Begin
     If (Damage > 0) Then Begin
       Tmp := (Damage - Rnd(ArmorClass));
       If (Stats[STAT_DEFEND]) Then
         Tmp := Round(Tmp*0.666);
       If (Tmp >= Health) Then
         Health := 0
       Else Health := Health - Tmp;
     End;
     If (GoldGain <> 0) Then Begin
       Gold := Gold + GoldGain;
     End;
     If (Heal > 0) Then Begin
       Tmp := Heal + Health;
       If (Tmp >= Maxhealth) Then
         Health := Maxhealth
       Else Health := Tmp;
     End;
     For I := 1 To MaxPersonAttri Do Begin
       If AttriGain[I] > 0 Then
         Attributes[I] := Attributes[I] + AttriGain[I];
       If AttriLoss[I] > 0 Then Begin
         If (AttriLoss[I] >= Attributes[I]) Then
           Attributes[I] := 0
         Else Attributes[I] := Attributes[I] - AttriLoss[I];
       End;
     End;
     If MHGain > 0 Then Begin
       Maxhealth := Maxhealth + MHGain;
     End;
     If MHLoss > 0 Then Begin
       If MHLoss >= Maxhealth Then
         Maxhealth := 0
       Else Maxhealth := Maxhealth - MHLoss;
     End;
     If MMGain > 0 Then Begin
       Maxmana := Maxmana + MMGain;
     End;
     If MMLoss > 0 Then Begin
       If MMLoss >= Maxmana Then
         Maxmana := 0
       Else Maxmana := Maxmana - MMLoss;
     End;
     If MSGain > 0 Then Begin
       Maxspeed := Maxspeed + MSGain;
     End;
     If MSLoss > 0 Then Begin
       If MSLoss >= Maxspeed Then
         Maxspeed := 0
       Else Maxspeed := Maxspeed - MSLoss;
     End;
     If ACGain > 0 Then Begin
       ArmorClass := ArmorClass + ACGain;
     End;
     If ACLoss > 0 Then Begin
       If ACLoss >= ArmorClass Then
         ArmorClass := 0
       Else ArmorClass := ArmorClass - ACLoss;
     End;
     If (NewClass > 0) Then Begin
       OldClass := Class;
       Class := NewClass;
       Group := NewCls.Group;
       Home  := NewCls.Homeroom;
     End;
   End;
 End;

 Procedure PrintEffect;
 Begin
   If Print Then Begin
     If (Damage > Heal) Then
       PutLine('You feel some pain. ')
     Else If (Heal > Damage) Then
        PutLine('You feel healthier. ');
     If (GoldGain > 0) Then
       PutLine('You gained some gold. ')
     Else If (GoldGain < 0) Then
       PutLine('You''ve lost some gold. ');
     If (NewClass > 0) Then PutLine('You are now a '+NewCls.Name+'.');
     For I := 1 To MaxPersonAttri Do Begin
       If (AttriGain[I] > AttriLoss[I]) Then
         PutLine('You gained some '+PersonAttriTable[I]+'.')
       Else If (AttriLoss[I] > AttriGain[I]) Then
         PutLine('You lost some '+PersonAttriTable[I]+'.');
     End;
     If (MHGain > MHLoss) Then 
       PutLine('You feel *healthier*.')
     Else If (MHLoss > MHGain) Then
       PutLine('Your health is damaged. ');
     If (MMGain > MMLoss) Then
       PutLine('You are magically enchanted. ')
     Else If (MMLoss > MMGain) Then
       PutLine('You are magically disenchanted. ');
     If (MSGain > MSLoss) Then
       PutLine('You feel faster. ')
     Else If (MSLoss > MSGain) Then
       PutLine('You feel slower. ');
     If (ACGain > ACLoss) Then
       PutLine('You feel more invulnerable. ')
     Else If (ACLoss > ACGain) Then
       PutLine('You feel more vulnerable. ');
   End;
 End;

Begin
  Read_Record(FILE_BLOCK, Entity.PersonId, IAddress(PersonBlk));
  If (PersonBlk.Person.Health > 0) Then Begin
    LoadBuffer(Ptr);
    While (I < Buffer.Top) Do Begin
      I := I + 1;
      TransEffect;
    End;
    If (NewClass > 0) Then ReadEntity(NewClass, NewCls);
    Get_Record(FILE_BLOCK, Entity.PersonId, IAddress(PersonBlk));
    HandleEffect;
    Update_Record(FILE_BLOCK, Entity.PersonId, IAddress(PersonBlk));
    PrintEffect;
    IsNpc := (Entity.Driver = 0);
    If (NewClass > 0) Then Begin (* special case 1 *)
      ReadEntity(OldClass, OldCls);
      AffectPerson(Oldcls.ClassEffect, EntityId, Location, Entity, PersonBlk,
      Dummy1, Dummy2, Dummy3, Print, TRUE);
      Dummy1 := 0;
      Dummy2 := 0;
      AffectPerson(NewCls.ClassEffect, EntityId, Location, Entity, PersonBlk,
      Dummy1, Dummy2, Dummy3, Print, FALSE);
    End;
    If (DelayTime > 0) Then Begin  (* special case 2 *)
      LogEvent(0, EntityId, EV_FREEZE, Location, '', IsNpc, DelayTime);
    End;
    If (NewDest > 0) Then Begin  (* special case 3 *)
      LogEvent(0, EntityId, EV_TELEPORT, Location, '', IsNpc, NewDest);
    End;
    If (PersonBlk.Person.Health = 0) Then Begin
      DoDie(Entity, PersonBlk, ExpGained);
      If Print Then PutLine('You are dead! ');
    End;
    WasDead := False;
  End Else Begin
    ExpGained := 0;
    Damage := 0;
    WasDead := True;
  End;
End;

End.
