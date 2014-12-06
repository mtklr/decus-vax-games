[Hidden]
Const
  T = True;
  F = False;

  y = 0;
  x = 10;    (* don't cares in bonus table *)

Const
  (* Offensive formation *)

  OF_HAIL_BRENT = 1;
  OF_FIREBALL = 2;
  OF_RED_GUN = 3;
  OF_TROLL_FRONT = 4;
  OF_HAMMER_FORMATION = 5;
  OF_LED_PIPE = 6;
  OF_PUNT = 7;
  OF_KICK = 8;
  MAX_OF = 8;

  (* Offensive play *)

  OP_PLAY_ACT_PASS = 1;
  OP_POWER_RUN_INSIDE = 2;
  OP_POWER_SWEEP = 3;
  OP_SCREEN = 4;
  OP_DEEP_PASS = 5;
  OP_CROSSING_PASS = 6;
  OP_COUNTER_GAP = 7;
  OP_PUNT = 8;
  OP_KICK = 9;
  MAX_OP = 9;

  OP_KICK_OFF = 10;   (* special *)

  (* Defensive formation *)

  DF_TURTLE = 1;
  DF_PREVENT = 2;
  DF_EAGLE = 3;
  DF_NORMAL = 4;
  DF_BEAR = 5;
  DF_GOAL_LINE = 6;
  DF_AGAIN_PUNT = 7;
  DF_AGAIN_KICK = 8;
  MAX_DF = 8;

  (* Defensive play *)

  DP_PASS_BLITZ = 1;
  DP_RUN_BLITZ = 2;
  DP_ZONE = 3;
  DP_REACT = 4;
  DP_AGAIN_PUNT = 5;
  DP_AGAIN_KICK = 6;
  MAX_DP = 6;

  DP_RUN_BACK = 7;  (* special *)

Type
  String = Packed Array[1..20] Of Char;

Var
  (* Offensive formatin action flag *)

  OffenFormFlags : [ReadOnly] Array[1..MAX_OF, 1..MAX_OP] Of Boolean := (
      (F, F, F, F, T, T, F, F, F),
      (T, T, T, T, T, T, T, F, F),
      (T, T, T, T, T, T, T, F, F),
      (T, T, T, T, T, T, T, F, F),
      (T, T, T, T, T, T, T, F, F),
      (F, T, T, T, F, F, T, F, F),
      (F, F, F, F, F, F, F, T, F),
      (F, F, F, F, F, F, F, F, T));

  (* Defensive formation action flag *)

  DefFormFlags : [ReadOnly] Array[1..MAX_DF, 1..MAX_DP] Of Boolean := (
      (F, F, T, T, F, F),
      (T, T, T, T, F, F),
      (T, T, T, T, F, F),
      (T, T, T, T, F, F),
      (T, T, T, T, F, F),
      (F, T, F, T, F, F),
      (F, F, F, F, T, F),
      (F, F, F, F, F, T));

  (* Formation match up bonus *)

  Form_MatchUp_Bonus : [ReadOnly] Array[1..MAX_OF, 1..MAX_DF] Of Integer := (
      (1, 2, 4, 6, 7, 9, x, x),
      (2, 1, 2, 4, 5, 8, x, x),
      (3, 2, 1, 2, 4, 7, x, x),
      (4, 3, 2, 1, 2, 6, x, x),
      (6, 4, 3, 2, 1, 4, x, x),
      (7, 6, 4, 3, 2, 1, x, x),
      (x, x, x, x, x, x, x, x),
      (x, x, x, x, x, x, x, x));

  (* Play match up bonus *)

  Play_MatchUp_Bonus : [ReadOnly] Array[1..MAX_OP, 1..MAX_DP] Of Integer := (
      (0, 5, 3, 3, x, x),
      (2, 2, 3, 2, x, x),
      (1, 0, 4, 3, x, x),
      (7, 4, 0, 0, x, x),
      (1, 4, 2, 2, x, x),
      (0, 3, 2, 4, x, x),
      (0, 0, 6, 5, x, x),
      (x, x, x, x, x, x),
      (x, x, x, x, x, x));

  (* Blizt bonus *)

  Blitz_Bonus : [ReadOnly] Array[1..MAX_DF] Of Integer := (
      0, 1, 2, 3, 5, 6, y, y);

  (* Pass bonus *)

  Pass_Bonus : [ReadOnly] Array[1..MAX_OF] Of Integer := (
      6, 5, 3, 2, 1, 0, y, y);

  (* tables *)  

  OF_Table : [ReadOnly] Array[1..MAX_OF] Of String := (
    'Hail_Brent',
    'Fireball',
    'Red_Gun',
    'Troll_Front',
    'Hammer_Form',
    'Led_Pipe',
    'Punt_Formation',
    'Kick_Formation');

  OP_Table : [ReadOnly] Array[1..MAX_OP] Of String := (
    'PlayAction_Pass',
    'PowerRun_Inside',
    'Power_Sweep',
    'Screen_Pass',
    'Deep_Pass',
    'Crossing_Pass',
    'Counter_Gap',
    'Punt',
    'Kick');

  DF_Table : [ReadOnly] Array[1..MAX_DF] Of String := (
    'Turtle',
    'Prevent',
    'Eagle',
    'Normal',
    'Bear',
    'Goal_Line',
    'Against_Punt',
    'Against_Kick');

  DP_Table : [ReadOnly] Array[1..MAX_DP] Of String := (
    'Pass_Blitz',
    'Run_Blitz',
    'Zone_Defense',
    'React_Defense',
    'Punt_Block',
    'Kick_Block');

  
Function Rnd(Max : Integer): Integer;
Var FirstCall : [Static] Boolean := True; Seed : [Static] Unsigned;
Begin
  If FirstCall Then Begin
    FirstCall := False;
    Seed := Clock;
  End;
  Rnd := Round(Mth$Random(Seed)*(Max-1) + 1);
End;

Function IsPass(OPlay : Integer): Boolean;
Begin
  IsPass := (OPlay = OP_PLAY_ACT_PASS) Or
            (OPlay = OP_SCREEN) Or
            (OPlay = OP_DEEP_PASS) Or
            (OPlay = OP_CROSSING_PASS);
End;

Function IsDeepPass(OPlay : Integer): Boolean;
Begin
  IsDeepPass := (OPlay = OP_PLAY_ACT_PASS) Or
                (OPlay = OP_DEEP_PASS);
End;

Function IsEasyPass(OPlay : Integer): Boolean;
Begin
  IsEasyPass := (OPlay = OP_SCREEN);
End;

Function IsBlitz(DPlay : Integer): Boolean;
Begin
  IsBlitz := (DPlay = DP_PASS_BLITZ) Or
             (DPlay = DP_RUN_BLITZ);
End;

Function Roll_Play(OFor, OPlay, DFor, DPlay: Integer): Integer;
Var I : Integer;
Begin
  I := Form_MatchUp_Bonus[OFor, DFor]
      +Play_MatchUp_Bonus[OPlay, DPlay];
  If (IsPass(OPlay) And IsBlitz(DPlay)) Then Begin
    If (Blitz_Bonus[DFor] > 3) Then Begin   (* Do Or Die! *)
      If (Rnd(100) < 40) Then Begin
        I := - Rnd(15);
      End Else Begin
        I := I + Pass_Bonus[OFor];
      End;
    End Else Begin                          (* Boring! *)
      I := I + Pass_Bonus[OFor] - Blitz_Bonus[DFor];
    End;
  End;
  Roll_Play := I;
End;
