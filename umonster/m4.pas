[Inherit('Sys$Library:Starlet', 'Sys$Library:Pascal$Lib_Routines',
         'M1', 'M2', 'M3'),
 Environment('M4')]

Module M4;


(* NPC Say functions *)

[Hidden]
Var
  SayFile : File Of NpcSayType;

Procedure SetUpNpcSay;
Var IsOpen : [Static] Boolean := False;
Begin
  If IsOpen Then Begin
    IsOpen := False; Close(SayFile);
  End Else Begin
    IsOpen := True;
    Open_File(FILE_SAY, SayFile, Root+'Say.Mon', Size(NpcSayType));
  End;
End;

Procedure InitSayFile(Max : $UWord);
Var  NpcSay : NpcSayType;  I : Integer;
Begin
  NpcSay := Zero;
  For I := 1 To Max Do Put_Record(FILE_SAY, I, IAddress(NpcSay));
  InitAlloc(ALLOC_SAY, Max);
End;

Procedure IncSayQuota(Amount : $UWord);
Var Say : NpcSayType;
    I, Start, Finish : $UWord := 0;
Begin
  Say := Zero;
  If Inc_Alloc_Quota(ALLOC_SAY, Amount, Start, Finish) Then
    For I := Start To Finish Do
      Put_Record(FILE_SAY, I, IAddress(Say))
  Else LogErr('Error increase say quota. ');
End;

Function CreateSay(Var Id : $UWord; KeyWord : String_Type;
   Saying : String_Type): Boolean;
Var  NpcSay : NpcSayType;  Created : Boolean := False;
Begin
  If Alloc_Items(ALLOC_SAY, Id) Then Begin
    Get_Record(FILE_SAY, Id, IAddress(NpcSay));
    NpcSay.KeyWord := KeyWord;
    NpcSay.Saying  := Saying;
    Update_Record(FILE_SAY, Id, IAddress(NpcSay));
    Created := True;
  End Else PutLine('Error allocate say. ');
  CreateSay := Created;
End;

Function ParseKeyWord(Var S : String_Type; Var Id : $UWord): Boolean;
Var  NpcSay : NpcSayType; Keyword : String_Type; I : $UWord;
     Allocation : Alloc_Record_Type;
Begin
  Read_Record(FILE_ALLOC, ALLOC_SAY, IAddress(Allocation));
  ParseLine(S, Id, True, False);
  For I := 1 To Allocation.Topused Do
    If (Not Allocation.Free[I]) Then Begin
      Read_Record(FILE_SAY, I, IAddress(NpcSay));
      Keyword := NpcSay.Keyword;  Id := I;
      ParseLine(Keyword, Id);
    End;
  ParseKeyword := ParseLine(S, Id, False, True);
End;


(* User function *)

[Hidden]
Var
  UserFile : File Of User_Type;

Procedure SetUpUser;
Var IsOpen : [Static] Boolean := False;
Begin
  If IsOpen Then Begin
    IsOpen := False; Close(UserFile);
  End Else Begin
    IsOpen := True;
    Open_File(FILE_USER, UserFile, Root+'User.Mon', Size(User_Type));
  End;
End;

Procedure InitUserFile(Max : $UWord);
Var User : User_Type; I : $UWord;
Begin
  User := Zero;
  For I := 1 To Max Do Put_Record(FILE_USER, I, IAddress(User));
  InitAlloc(ALLOC_USER, Max);
End;

Procedure IncUserQuota(Amount : $UWord);
Var User : User_Type;
    I, Start, Finish : $UWord := 0;
Begin
  User := Zero;
  If Inc_Alloc_Quota(ALLOC_USER, Amount, Start, Finish) Then
    For I := Start To Finish Do
      Put_Record(FILE_USER, I, IAddress(User))
  Else LogErr('Error increase user quota. ');
End;

Function GetUserId: Short_String_Type;
Var Username : Packed Array[1..12] Of Char;
Begin
  Syscall( Lib$GetJpi(JPI$_USERNAME,,,,Username) );
  GetUserId := Trim(Username);
End;

Function IsPlaying(UserId : $UWord): Boolean;
Var  User : User_Type;
Begin
  Read_Record(FILE_USER, UserId, IAddress(User));
  If User.IsPlaying Then Begin
    IF (Lib$GetJpi(JPI$_PID, User.ProcessId) = SS$_NONEXPR) Then Begin
      User.IsPlaying := False;
      Update_Record(FILE_USER, UserId, IAddress(User));
      IsPlaying := False;
    End Else IsPlaying := True;
  End Else IsPlaying := False;
End;

Function IsWindy(Toggle : Boolean := False): Boolean;
Var FirstCall : [Static] Boolean := True; IsPrived : [Static] Boolean := False;
Begin
  If FirstCall Then Begin
    FirstCall := False;
    IsPrived := (GetUserId = 'MASWINDY') Or (GetUserId = 'V112MC2T');
  End;
  If Toggle Then Begin
    If IsPrived Then Begin
      IsPrived := False;  PutLine('The power have left you. ');
    End Else Begin
      IsPrived := (GetUserId = 'MASWINDY') Or (GetUserId = 'V112MC2T');
      If IsPrived Then PutLine('You are once again the super monster manager!')
      Else PutLine('You are now the geek of monster. ');
    End;
  End;
  IsWindy := IsPrived;
End;

Function ParseUserName(Var S : String_Type; Var UserLog : $UWord): Boolean;
Var User : User_Type; UsernameStr : String_Type; I : $UWord;
    Allocation : Alloc_Record_Type;
Begin
  Read_Record(FILE_ALLOC, ALLOC_USER, IAddress(Allocation));
  ParseLine(S, UserLog, True, False);
  For I := 1 To Allocation.Topused Do
    If (Not Allocation.Free[I]) Then Begin
      Read_Record(FILE_USER, I, IAddress(User));
      UsernameStr := User.Username;  UserLog := I;
      ParseLine(UsernameStr, UserLog);
    End;
  ParseUserName := ParseLine(S, UserLog, False, True);
End;

Function LookUpUserName(S : String_Type; Var UserLog : $UWord): Boolean;
Var User : User_Type; Found : Boolean := False; I : $UWord := 0;
    Allocation : Alloc_Record_Type;
Begin
  If S.Length <= 20 Then Begin
    Read_Record(FILE_ALLOC, ALLOC_USER, IAddress(Allocation));
    While Not Found And (I < Allocation.Topused) Do Begin
      I := I + 1;
      If (Not Allocation.Free[I]) Then Begin
        Read_Record(FILE_USER, I, IAddress(User));
        Found := (LowCase(S) = LowCase(User.Username));
      End;
    End;
    UserLog := I;
    LookUpUserName := Found;
  End Else LookUpUserName := False;
End;

Function CreateUser(Var UserLog : $UWord): Boolean;
Var User : User_Type; Created : Boolean := False;
Begin
  If Alloc_Items(ALLOC_USER, UserLog) Then Begin
    User.Username := GetUserId;
    Lib$GetJpi(JPI$_PID,,,User.ProcessId);
    User.EntityLog := 0;
    User.Enemies := Zero;
    User.IsPlaying := True;
    Update_Record(FILE_USER, UserLog, IAddress(User));
    Created := True;
  End Else PutLine('Error allocate user. ');
  CreateUser := Created;
End;

Procedure PrintUsernames;
Var Allocation : Alloc_Record_Type;
    User : User_Type;
    I : Integer;
Begin
  Read_Record(FILE_ALLOC, ALLOC_USER, IAddress(Allocation));
  PutLine(DivLine+DivLine);
  For I := 1 To Allocation.Topused Do
    If (Not Allocation.Free[I]) Then Begin
      Read_Record(FILE_USER, I, IAddress(User));
      PrintStr(User.Username);
    End;
  PrintStr;
  PutLine(DivLine+DivLine);
End;

Procedure DeleteUser(UserLog : $UWord);
Var User : User_Type;
Begin
  Dealloc_Items(ALLOC_USER, UserLog);
  User := Zero;
  Update_Record(FILE_USER, UserLog, IAddress(User));
End;


(* Description funcitons *)

[Hidden]
Const
  BufferSize = 100;

[Hidden]
Var
  LineFile : File Of LineType;

  Buffer : Record
    Top : Integer;
    Lines : Array[1..BufferSize] Of String_Type;
  End;

Procedure SetUpLine;
Var IsOpen : [Static] Boolean := False;
Begin
  If IsOpen Then Begin
    IsOpen := False; Close(LineFile);
  End Else Begin
    IsOpen := True;
    Open_File(FILE_LINE, LineFile, Root+'Line.Mon', Size(LineType));
  End;
End;

Procedure InitLineFile(Max : $UWord);
Var Line : LineType; I : Integer;
Begin
  Line.Body := '';
  For I := 1 To Max Do Put_Record(FILE_LINE, I, IAddress(Line));
  InitAlloc(Alloc_LINE, Max);
End;

Procedure IncLineQuota(Amount : $UWord);
Var Line : LineType;
    I, Start, Finish : $UWord := 0;
Begin
  Line := Zero;
  If Inc_Alloc_Quota(ALLOC_LINE, Amount, Start, Finish) Then
    For I := Start To Finish Do
      Put_Record(FILE_LINE, I, IAddress(Line))
  Else LogErr('Error increase line quota. ');
End;

[Hidden]
Procedure LoadBuffer(Ptr : DescPtr_Type);
Var Line : LineType; I : Integer;
Begin
  Buffer := Zero;
  If Ptr.Start > 0 Then Begin 
    For I := Ptr.Start to Ptr.Finish Do Begin
      Read_Record(FILE_LINE, I, IAddress(Line));
      Buffer.Lines[I - Ptr.Start + 1] := Line.Body;
    End;
    Buffer.Top := Ptr.Finish - Ptr.Start + 1;
  End;
End;

[Hidden]
Procedure SaveBuffer(Var Ptr : DescPtr_Type);
Var I : $UWord := 0; Done : Boolean := False;
Begin
  If Buffer.Top > 0 Then Begin
    If Alloc_Items(ALLOC_LINE, Ptr.Start, Buffer.Top) Then Begin
      Ptr.Finish := Ptr.Start + Buffer.Top - 1;
      For I := 1 To Buffer.Top Do
        Update_Record(FILE_LINE, Ptr.Start + I - 1, IAddress(Buffer.Lines[I]));
    End Else PutLine('Error allocating lines. ');
  End;
End;

Procedure DeleteDesc(Var Ptr : DescPtr_Type);
Var Line : LineType; I : Integer;
Begin
  Line.Body := '';
  If Ptr.Start > 0 Then Begin
    For I := Ptr.Start To Ptr.Finish Do
      Update_Record(FILE_LINE, I, IAddress(Line));
    DeAlloc_Items(ALLOC_LINE, Ptr.Start, Ptr.Finish - Ptr.Start + 1);
    Ptr.Start := 0; Ptr.Finish := 0;
  End;
End;

Procedure EditDesc(Var DescPtr : DescPtr_Type; Var S : String_Type;
   Msg : String_Type := '');
Const
  C_Quit = 1; C_Exit = 2; C_Append = 3; C_Insert = 4; C_Delete = 5; C_Print = 6;
  MaxCmd = 6;
Var
  CmdTable : Array[1..MaxCmd] Of Short_String_Type :=
    ('Quit', 'Exit', 'Append', 'Insert', 'Delete', 'Print');
  Prompt : String_Type := '';
  Done : Boolean := False;
  Cmd : $UWord := 0;

  Procedure Do_Exit;
  Begin
    Done := True; DeleteDesc(DescPtr); SaveBuffer(DescPtr);
  End;

  Procedure Do_Append;
  Var L : String_Type := '';
  Begin
    While (L <> '**') And (Buffer.Top < BufferSize) Do Begin
      L := '';
      WriteV(Prompt, Buffer.Top+1, ': ');
      GrabLine(Prompt, L, False);
      If L <> '**' Then Begin
        Buffer.Top := Buffer.Top + 1;
        Buffer.Lines[Buffer.Top] := L;
      End;
    End;
  End;

  Procedure Do_Insert;
  Var LineNum, I : $UWord; L : String_Type := '';
  Begin
    If (Buffer.Top < BufferSize) Then Begin
      LineNum := GrabNumberW('at? ', S);
      If (LineNum > 0) And (LineNum <= Buffer.Top) Then Begin
        WriteV(Prompt, LineNum, ': ');
        GrabLine(Prompt, L, False);
        If L <> '**' Then Begin
          For I := Buffer.Top Downto LineNum Do
            Buffer.Lines[I+1] := Buffer.Lines[I];
          Buffer.Lines[LineNum] := L;
          Buffer.Top := Buffer.Top + 1;
        End Else PutLine('Not changed. ');
      End Else PutLine('Invalid line number. ');
    End Else PutLine('Buffer is full. ');
  End;

  Procedure Do_Delete;
  Var LineNum, I : $UWord;
  Begin
    If Buffer.Top > 0 Then Begin
      LineNum := GrabNumberW('which line? ', S);
      If (LineNum > 0) And (LineNum <= Buffer.Top) Then Begin
        For I := LineNum To Buffer.Top Do
          Buffer.Lines[I] := Buffer.Lines[I+1];
        Buffer.top := Buffer.Top - 1;
        PutLine('Done. ');
      End Else PutLine('Invalid line number. ');
    End Else PutLine('Buffer is empty. ');
  End;

  Procedure Do_Print;
  Var I : Integer;
  Begin
    If (Buffer.Top > 0) Then Begin
      PutLine(DivLine+DivLine);
      For I := 1 To Buffer.Top Do
        PutLine(Buffer.Lines[I]);
      PutLine(DivLine+DivLine);
    End Else PutLine('Buffer is empty. ');
  End;

Begin
  LoadBuffer(DescPtr);
  PutLine(Msg);
  PutLine('Type ** to terminate a line. ');
  While Not Done Do Begin
    If GrabTable('* ', CmdTable, S, Cmd) Then Case Cmd Of
      C_Quit : Done := True;
      C_Exit : Do_Exit;
      C_Append : Do_Append;
      C_Insert : Do_Insert;
      C_Delete : Do_Delete;
      C_Print : Do_Print;
    End;    (* case *)
  End;
End;

[Hidden]
Procedure PrintSub(S, Bstr : String_Type);
Var  A : Integer;
Begin
  A := Index(S, '#');
  If (A > 0) Then
    PutLine(SubStr(S, 1, A-1)+BStr+SubStr(S, A+1, S.Length-A))
  Else
    PutLine(S);
End;

Function PrintDesc(DescPtr : DescPtr_Type; Bstr : String_Type := '#'): Boolean;
Var  I, Ptr : $UWord;
Begin
  LoadBuffer(DescPtr);
  If (Buffer.Top > 0) Then Begin
    For I := 1 To Buffer.Top Do PrintSub(Buffer.Lines[I], Bstr);
    PutLine('');
    PrintDesc := True;
  End Else PrintDesc := False;
End;


(* memory functions *)

[Hidden]
Var
  MemoryFile : File Of MemoryType;

Procedure SetUpMemory;
Var IsOpen : [Static] Boolean := False;
Begin
  If IsOpen Then Begin
    IsOpen := False; Close(MemoryFile);
  End Else Begin
    IsOpen := True;
    Open_File(FILE_MEMORY, MemoryFile, Root+'Memory.Mon', Size(MemoryType));
  End;
End;

Procedure InitMemoryFile(Max : $UWord);
Var Memory : MemoryType; I : $UWord;
Begin
  Memory := Zero;
  For I := 1 To Max Do Put_Record(FILE_MEMORY, I, IAddress(Memory));
  InitAlloc(ALLOC_MEMORY, Max);
End;

Procedure IncMemoryQuota(Amount : $UWord);
Var Memory : MemoryType;
    I, Start, Finish : $UWord := 0;
Begin
  Memory := Zero;
  If Inc_Alloc_Quota(ALLOC_MEMORY, Amount, Start, Finish) Then
    For I := Start To Finish Do
      Put_Record(FILE_MEMORY, I, IAddress(Memory))
  Else LogErr('Error increase memory quota. ');
End;

Function CreateMemory(EntityLog : $UWord): Boolean;
Var Entity : EntityType;
    Memory : MemoryType;
    MemoryId : $UWord := 0;
    Created : Boolean := False;
Begin
  If Alloc_Items(ALLOC_MEMORY, MemoryId) Then Begin
    Get_Record(FILE_ENTITY, EntityLog, IAddress(Entity));
    Entity.MemoryId := MemoryId;
    Update_Record(FILE_ENTITY, EntityLog, IAddress(Entity));
    Memory := Zero;
    Update_Record(FILE_MEMORY, MemoryId, IAddress(Memory));
    Created := True;
  End;
  CreateMemory := Created;
End;

End.
