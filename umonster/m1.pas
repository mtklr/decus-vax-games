[Inherit('Sys$Library:Starlet',
         'Sys$Library:Pascal$Smg_Routines',
         'Sys$Library:Pascal$Lib_Routines',
         'Sys$Library:Pascal$Mth_Routines'),
 Environment('M1')]

Module M1;

Const
  DivLine = '---------------------------------------';
           (*1234567890123456789012345678901234567890*)
Type
  Short_String_Type = Varying[20] Of Char;
  String_Type = Varying[80] Of Char;
  Long_String_Type = Varying[256] Of Char;

  $Byte = [Byte] -128..127;
  $Word = [Word] -32768..32767;
  $UByte = [Byte] 0..255;
  $UWord = [Word] 0..65535;
  $ULong = [Long] Unsigned;

  $UQuad = Record
    Q1, Q2 : $ULong;
  End;


[Hidden]
Var
  Seed : Unsigned;
  OutChan : $UWord;
  Kbd_Id : Unsigned;
  InLine : Long_String_Type := '';
  Prompt : String_Type := '';
  PrnPrompt : Boolean := True;
  InputFromFile : Boolean := False;
  OutputToFile  : Boolean := False;
  InputFile  : Text;
  OutputFile : Text;
  TimerContext : Unsigned;

[External, Hidden]
Procedure Driver; External;

Procedure SysCall( S : [Unsafe] Unsigned );
Begin
  If Not Odd(S) Then Lib$Signal(S);
End;

Procedure Wait(Sec : Real);
Begin
  SysCall( Lib$Wait(Sec) );
End;

Function Rnd(Max : $UWord): $UWord;
Begin
  Rnd := Round(Mth$Random(Seed)*Max);
End;

(* String function *)

Function LowCase(S : String_Type): String_Type;
Var I : $UWord;
Begin
  If S.Length > 0 Then For I := 1 To S.Length Do
    If S[I] In ['A'..'Z'] Then
      S[I] := Chr(Ord('a') + ( Ord(S[I]) - Ord('A') ));
  LowCase := S;
End;

Function PadStr(S : String_Type; Pos : $UWord): String_Type;
Var I : $UWord;
Begin
  If S.Length < Pos Then For I := S.Length + 1 To Pos Do
    S := S + ' ';
  PadStr := S;
End;

Function Slead(S : String_Type): String_Type;
Var I : $UWord; Done : Boolean := False;
Begin
  I := 0;
  While Not Done Do Begin
    I := I + 1;
    If I > S.Length Then Done := True
    Else Done := ( (S[I] <> ' ') And (S[I] <> Chr(9)) );
  End;
  If I > S.Length Then Slead := ''
  Else Slead := Substr(S, I, S.Length - I + 1);
End;

Function Trim(S : String_Type): String_Type;
Var I : $UWord; Done : Boolean := False;
Begin
  I := S.Length + 1;
  While Not Done Do Begin
    I := I - 1;
    If I = 0 Then Done := True
    Else Done := ( (S[I] <> ' ') And (S[I] <> Chr(9)) );
  End;
  If I = 0 Then Trim := ''
  Else Trim := Substr(S, 1, I);
End;

Function Bite(Var S : String_Type; I : $UWord := 0): String_Type;
Var Done : Boolean := False;
Begin
  While Not Done Do Begin
    I := I + 1;
    If I > S.Length Then Done := True
    Else Done := (S[I] = ' ');
  End;
  If I > S.Length Then Begin
    Bite := S; S := '';  End
  Else Begin
    Bite := Slead(Trim(Substr(S, 1, I)));
    S := Slead(Trim(Substr(S, I+1, S.Length - I)));
  End;
End;

[Hidden]
Function ParseStr(S : String_Type; S1 : String_Type; Var Pos : $UWord;
   Var Exact : Boolean): Boolean;
Var  Done, Term : Boolean := False;
Begin
  S := LowCase(S); S1 := LowCase(S1); Pos := 1;
  If (S.Length = 0) Or (S1.Length = 0) Then Begin
    ParseStr := False;  Pos := 0;  Exact := False;  End
  Else While Not Done Do
    If (Pos > S1.Length) Then Begin           (* parse exact *)
      Done := True; ParseStr := True; Pos := Pos - 1; Exact := True;  End
    Else If (Pos > S.Length) Then Begin       (* parse match *)
      Done := True; ParseStr := True; Pos := Pos - 1; Exact := False;  End
    Else If (S[Pos] <> S1[Pos]) Then Begin    (* maybe, maybe not *)
      Done := True;
      If (S[Pos] = ' ') Then Begin                (* match *)
        ParseStr := True; Pos := Pos - 1; Exact := False;  End
      Else If Term Then Begin                     (* match *)
        ParseStr := True;  Pos := Pos - 2; Exact := False; End
      Else Begin                                  (* no match *)
        ParseStr := False; Pos := Pos - 1; Exact := False;
      End;  End
    Else Begin                                (* keep going *)
      Term := (S[Pos] = ' '); Pos := Pos + 1;  End;
End;

Function ParseLine(Var S1 : String_Type; Var Index : $UWord;
  IsFirst : Boolean := False; IsLast : Boolean := False): Boolean;
Var S : [Static] String_Type; Log, Pos, NewPos : [Static] $UWord;
  FoundOne, FoundExact, Exact : [Static] Boolean;
Begin
  If IsFirst Then Begin      (* first call *)
    S := S1; Log := 0; Pos := 0; NewPos := 0; FoundOne := False;
    FoundExact := False; Exact := False; ParseLine := False;  End
  Else If IsLast Then Begin  (* last call *)
    If FoundOne Then Begin
      Bite(S1, Pos); Index := Log; ParseLine := True; End
    Else Begin
      S1 := ''; Index := 0; ParseLine := False;
    End;  End
  Else If ParseStr(S, S1, NewPos, Exact) Then Begin  (* parsing *)
    If Not FoundOne Then Begin          (* first found *)
      Log := Index; FoundOne := True;
      FoundExact := Exact; Pos := NewPos;  End
    Else If (NewPos > Pos) Then Begin    (* more likely match *)
      Log := Index; FoundExact := Exact; Pos := NewPos;  End
    Else If (NewPos = Pos) And
       (Exact And Not FoundExact) Then Begin  (* exact match *)
      Log := Index; FoundExact := True;  End;
    ParseLine := False;
  End;
End;

Function ParseTable(Table : Array[Lower..Upper: Integer] Of Short_String_Type;
   Var S : String_Type; Var Index : $UWord): Boolean;
Var I, N : $UWord; Tmp : String_Type;
Begin
  ParseLine(S, Index, TRUE, FALSE);
  For I := Lower To Upper Do Begin
    Tmp := Table[I]; N := I; ParseLine(Tmp, N);
  End;
  ParseTable := ParseLine(S, Index, FALSE, TRUE);
End;

Function NumberW(Var S : String_Type): $UWord;
Var I, Num : $UWord; Head : String_Type;
Begin
  I := Index(S, ' ');
  If (I > 1) Then Begin
    Head := Trim(SubStr(S, 1, I));
    S := Slead(SubStr(S, I, S.Length - I + 1));  End
  Else Begin
    Head := S;  S := '';
  End;
  ReadV(Head, Num, Error := Continue);
  NumberW := Num;
End;

Function NumberI(Var S : String_Type): Integer;
Var I, Num : Integer; Head : String_Type;
Begin
  I := Index(S, ' ');
  If (I > 1) Then Begin
    Head := Trim(SubStr(S, 1, I));
    S := Slead(SubStr(S, I, S.Length - I + 1));  End
  Else Begin
    Head := S;  S := '';
  End;
  ReadV(Head, Num, Error := Continue);
  NumberI := Num;
End;

(* Screen management function *)

Procedure PutLine(S : Long_String_Type; ExtraLine : $UWord := 0);
Var Msg : Packed Array[1..256] Of Char; Len, I : $UWord;
Begin
  If OutputToFile Then
    Writeln(OutputFile, S, Error := Continue);
  If (ExtraLine > 0) Then For I := 1 To ExtraLine Do
    S := S + Chr(13) + Chr(10);
  Msg := Chr(13) + Chr(10) + S;  Len := Length(s) + 2;
  SysCall( $Qiow(, OutChan, IO$_WRITEVBLK,,,, Msg, Len,,,,) );
  PrnPrompt := True;
End;

[Hidden]
Procedure PutChars(S : Long_String_Type);
Var Msg : Packed Array[1..256] Of Char; Len : $UWord;
Begin
  Msg := S;  Len := Length(S);
  SysCall( $Qiow(, OutChan, IO$_WRITEVBLK,,,, Msg, Len,,,,) );
End;

[Hidden]
Function KeyGet : Char;
Var Term : [Static] $UWord := 0;
Begin
  If PrnPrompt Then Begin
    PutChars(Chr(13)+Chr(10)+Prompt+InLine); PrnPrompt := False;
  End;
  If ( Smg$Read_Keystroke(Kbd_Id, Term,, 0,,,) Mod 2 ) = 0 Then KeyGet := Chr(0)
  Else KeyGet := Chr(Term);
End;

[Hidden]
Function KeyStroke : Char;
Var Ch : Char;
Begin
  Ch := KeyGet;
  While Ch = Chr(0) Do Begin
    Driver; Wait(0.1); Ch := KeyGet;
  End;
  KeyStroke := Ch;
End;

[Hidden]  
Procedure Grab_Line_Prime(Var S : String_Type);
Var Ch : Char;
Begin
  PrnPrompt := True;
  Ch := KeyStroke;
  While (Ch <> Chr(13)) And (Length(InLine) < 72) Do Begin
    If (Ch = Chr(8)) Or (Ch = Chr(127)) Then Begin       (* Delete character *)
      If InLine.Length = 1 Then Begin
        InLine := ''; PutChars(Chr(8)+' '+Chr(8)); End
      Else If InLine.Length > 1 Then Begin
        InLine := Substr(InLine, 1, InLine.Length-1);
        PutChars(Chr(8)+' '+Chr(8));
      End;  End
    Else if Ch = Chr(21) Then Begin                      (* Delete line *)
      InLine := ''; PutChars(Chr(13)+Chr(27)+'[K'+Prompt);  End
    Else If ((Ord(Ch)>31) And (Ord(Ch)<127)) Then Begin  (* Default *)
      InLine := InLine + Ch; PutChars(Ch);
    End;
    Ch := KeyStroke;
  End;
  PutChars(Chr(13)); PrnPrompt := True; S := InLine;
  If OutputToFile Then Writeln(OutputFile, Prompt+InLine, Error := Continue);
  InLine := '';
End;

(* Input/Output function *)

[Hidden]
Function ReadFromFile(Var S : String_Type): Boolean;
Var Done, ReadIn : Boolean := False;
Begin
  Done := Eof(InputFile);
  While Not Done Do Begin
    ReadLn(InputFile, S);
    If (S.Length = 0) Then ReadIn := False
    Else If (S[1] <> ';') Then ReadIn := True
    Else ReadIn := False;
    Done := ReadIn Or Eof(InputFile);
    PutLine('%'+S);
  End;
  If ReadIn Then ReadFromFile := True
  Else Begin
    ReadFromFile := False;  InputFromFile := False;  Close(InputFile);
  End;
End;

Procedure GrabLine(NewPrompt : String_Type; Var S : String_Type;
   Process : Boolean := True);
Begin
  Prompt := NewPrompt;
  If (S.Length > 0) Then Driver
  Else If Not InputFromFile Then Grab_Line_Prime(S)
  Else If Not ReadFromFile(S) Then Grab_Line_Prime(S);
  If Process Then S := Slead(Trim(S));
End;

Function GrabNumberW(Prompt : String_Type; Var S : String_Type): $UWord;
Begin
  While S.Length = 0 Do GrabLine(Prompt, S);
  GrabNumberW := NumberW(S);
End;

Function GrabNumberI(Prompt : String_Type; Var S : String_Type): Integer;
Begin
  While S.Length = 0 Do GrabLine(Prompt, S);
  GrabNumberI := NumberI(S);
End;

Function GrabBoolean(Prompt : String_Type; Var S : String_Type): Boolean;
Begin
  While S.Length = 0 Do GrabLine(Prompt, S);
  If (S[1] = 'T') Or (S[1] = 't') Then Begin
    GrabBoolean := True;
    Bite(S);
  End Else Begin
    GrabBoolean := False;
    S := '';
  End;
End;

Function GrabShortStr(Prompt : String_Type; Var S : String_Type): Short_String_Type;
Begin
  While S.Length = 0 Do GrabLine(Prompt, S);
  GrabShortStr := Bite(S);
End;

Procedure PrintTable(Table : Array[Lower..Upper: Integer] Of Short_String_Type);
Var I : $UWord; Tmp : Long_String_Type := ''; S : String_Type := '';
Begin
  For I := Lower To Upper Do Begin
    Tmp := Tmp + PadStr(Table[I], 21);
    If Tmp.Length < 80 Then S := Tmp
    Else Begin
      Putline(S); Tmp := PadStr(Table[I], 21);
    End;
  End;
  PutLine(Tmp);
End;

Procedure PrintStr(Str : String_Type := '');
Var S : [Static] String_Type := ''; Tmp : [Static] Long_String_Type := '';
Begin
  If Str.Length = 0 Then Begin
    Putline(Tmp); S := ''; Tmp := '';  End
  Else Begin
    Tmp := Tmp + PadStr(Str, 21);
    If Tmp.Length < 80 Then S := Tmp
    Else Begin
      PutLine(S); Tmp := PadStr(Str, 21);
    End;
  End;
End;

Function GrabTable(Prompt : String_Type;
   Table : Array[Lower..Upper:Integer] Of Short_String_Type;
   Var S : String_Type; Var Index : $UWord): Boolean;
Begin
  While S.Length = 0 Do Begin
    GrabLine(Prompt, S);
    If S='?' Then Begin
      PutLine(DivLine+DivLine);
      PrintTable(Table);
      PutLine(DivLine+DivLine);
      S := '';
    End;
  End;
  GrabTable := ParseTable(table, S, Index);
End;

(* Timer function *)

Function GetRealTime: $UQuad;
Var TimerVal : $UQuad;
Begin
  SysCall($GeTTim(TimerVal)); GetRealTime := TimerVal;
End;

Function AddRealTime(Sec : Real; TimerVal : $UQuad): $UQuad;
Var  TimerVal1, TimerVal2 : $UQUad;
Begin
  SysCall( Lib$CvtF_To_Internal_Time(LIB$K_DELTA_SECONDS_F, Sec, TimerVal1));
  SysCall( lib$Add_Times(TimerVal, TimerVal1, TimerVal2));
  AddRealTime := TimerVal2;
End;

Function GetTick: Integer;
Var TimerVal : $UQuad; Sec : Real;
Begin
  SysCall(Lib$Stat_Timer(1, TimerVal, TimerContext));
  SysCall(Lib$CvtF_From_Internal_Time(LIB$K_DELTA_SECONDS_F, Sec, TimerVal));
  GetTick := Trunc(Sec*10);
End;

Function DiffInTick(T1, T2 : $UQuad): Integer;
Var T3 : $UQuad; Sec : Real;
Begin
  If (T1.Q2 > T2.Q2) Or ((T1.Q2 = T2.Q2) And (T1.Q1 > T2.Q1)) Then Begin
    SysCall( Lib$Sub_Times(T1, T2, T3));
    SysCall( Lib$CvtF_From_Internal_Time(LIB$K_DELTA_SECONDS_F, Sec, T3) );
    DiffinTick := Trunc(Sec*10);
  End Else DiffInTick := 0;
End;

(* Utility function *)

Procedure Do_Photo(Var S : String_Type);
Var Fn : String_Type;
Begin
  If Not OutputToFile Then Begin
    While S.Length = 0 Do GrabLine('File name? ', S);
    Fn := S;  S := '';
    Open(OutPutFile, Fn, History := UnKnown);
    Rewrite(OutputFile);
    OutPutToFile := True;
(*    If (Status(OutputFile) = 0) Then OutputToFile := True
    Else PutLine('Error open file: '+fn); *)
  End;
End;

Procedure Do_Source(Var S : String_Type);
Var Fn : String_Type;
Begin
  If Not InputFromFile Then Begin
    While S.Length = 0 Do GrabLine('File name? ', S);
    Fn := S;  S := '';
    Open(InputFile, Fn, History := Old, Error := Continue);
    Reset(InputFile, Error := Continue);
    If (Status(InputFile) = 0) Then InputFromFile := True
    Else PutLine('Error open file: '+fn);
  End;
End;

(* Initialization function *)

Procedure InitSmg;
Begin
  SysCall( Smg$Create_Virtual_Keyboard(Kbd_Id) );
  SysCall( $Assign('SYS$OUTPUT', OutChan) );
End;

Procedure InitTimer;
Begin
  Seed := Clock;
  TimerContext := 0;
  SysCall(Lib$Init_Timer(TimerContext));
End;

End.
