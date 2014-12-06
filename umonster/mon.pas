[Inherit('Sys$Library:Starlet', 'Sys$Library:Pascal$Lib_Routines',
         'M1','M2','M3','M4','M5','M6','M7','M7_2',
         'M7_3', 'M9','M9_2','M10')]

Program Mon;

Const
  C_Play = 1; C_Quit = 2; C_Rebuild = 3; C_Root = 4; C_Force = 5;
  MaxCmds = 5;

Type
  ItemType = Record
    Blen  : $UWord;
    Code  : $UWord;
    Baddr : Unsigned;
    Raddr : Unsigned;
  End;

Var
  CmdTable : [ReadOnly] Array[1..MaxCmds] Of Short_String_Type :=
    ('Play', 'Quit', 'Rebuild', 'Root', 'Force');
  S : String_Type; Cmd : $UWord; Done : Boolean := False;

[External, Hidden]
Procedure InitEnemyList; External;

Procedure SetupDump;
Var ItemList : Packed Array[1..2] Of ItemType;
    DumpFn : String_Type;
Begin
  DumpFn := Root+'Dump.Mon';
  ItemList[1].Blen := DumpFn.Length;
  ItemList[1].Code := Lnm$_String;
  ItemList[1].Baddr := IAddress(DumpFn);
  ItemList[2] := Zero;
  SysCall( $CreLnm(, 'LNM$PROCESS_TABLE', 'SYS$ERROR',,ItemList) );
End;

Procedure SetupMisc;
Begin
  InitSmg;
  InitTimer;
  SetupError;
  SetUpDump;
End;

Procedure SetupFiles;
Begin
  SetupAlloc;
  SetupNpcSay;
  SetupUser;
  SetupLine;
  SetupEntity;
  SetupItemMap;
  SetupBlock;
  SetupExit;
  SetupEvent;
  SetupEffect;
  SetUpMemory;
End;

Function WelcomeBack: Boolean;
Var User : user_Type; 
    NodeIn, Entity : EntityType;
    MyPersonBlk : BlockType;
Begin
  If (Not IsPlaying(MyUserLog)) Then Begin
    Welcomeback := True;
    Get_Record(FILE_USER, MyUserLog, IAddress(User));
    MyEntityId := User.EntityLog;                           (* entity   *)
    SysCall( Lib$GetJpi(JPI$_PID,,,User.ProcessId) );       (* process  *)
    User.IsPlaying := True;
    Update_Record(FILE_USER, MyUserLog, IAddress(User));
    Get_Record(FILE_ENTITY, MyEntityId, IAddress(Entity));
    Entity.Driver := MyUserLog;
    Update_Record(FILE_ENTITY, MyEntityId, IAddress(Entity));
    GetLocation(MyEntityId, MyLocation, MyPosition);
    ReadEntity(MyLocation, NodeIn);
    ChangeMapPos(MyEntityId, MyLocation, NodeIn.RoomMapId, MyPosition);
    ReadBlock(Entity.PersonId, MyPersonBlk);
    ImDead := (MypersonBlk.Person.Health = 0);
    PutLine('Welcome back! ', 1);
    InitEnemyList;
    SetMyEvent;
    DescRoomIn(NodeIn, MyEntityId);
    LogGlobEvent(0, 0, EV_INFORM, '('+Entity.Name+' once again roams the land)');
  End Else Begin
    Welcomeback := False;
    LogErr('You are already in the game. ');
  End;
End;

Function MakeNewPlayer: Boolean;
Var User : User_Type;
    NodeIn : EntityType;
    S : String_Type := '';
Begin
  While (S.Length = 0) Do
    GrabLine('What is your name? ', S);
  S := Short(S);
  If CreateUser(MyUserLog) Then Begin
    If CreatePerson(S, MyEntityId, MyUserLog, MyUserLog, The_Great_Beginning, 
    POS_IN_ROOM) Then Begin
      MakeNewPlayer := True;
      Get_Record(FILE_USER, MyUserLog, IAddress(User));
      User.EntityLog := MyEntityId;
      User.IsPlaying := True;
      Update_Record(FILE_USER, MyUserLog, IAddress(User));
      MyLocation := The_Great_Beginning;
      MyPosition := POS_IN_ROOM;
      ImDead := False;
      PutLine('Welcome! ', 1);
      InitEnemyList;
      SetMyEvent;
      ReadEntity(MyLocation, NodeIn);
      DescRoomIn(NodeIn, MyEntityId);
      LogGlobEvent(0, 0, EV_INFORM, '('+S+' is born)');
    End Else Begin
      MakeNewPlayer := False;
      DeleteUser(MyUserLog);
      LogErr('Create player failed, notify monster manager. ')
    End;
  End Else Begin
    MakeNewPlayer := False;
    PutLine('The universe is full, notify monster manager. ');
  End;
End;

Procedure ExitPlaying;
Var NodeIn, Entity : EntityType; User : User_Type;
Begin
  ReadEntity(MyLocation, NodeIn);
  ChangeMapPos(MyEntityId, MyLocation, NodeIn.RoomMapId, 0);  (* tricky! *)
  UpdateLocation(MyEntityId, MyLocation, MyPosition);         (*         *)
  Get_Record(FILE_ENTITY, MyEntityId, IAddress(Entity));
  Entity.Driver := 0;
  Update_Record(FILE_ENTITY, MyEntityId, IAddress(Entity));   (* entity   *)
  Get_Record(FILE_USER, MyUserLog, IAddress(User));
  User.ProcessId := 0;
  User.IsPlaying := False;
  Update_Record(FILE_USER, MyUserLog, IAddress(User));        (* user     *)
  PutLine('You vanished in a brilliant burst of multicolor light. ');
  LogGlobEvent(0, 0, EV_INFORM, '('+Entity.Name+' returns to sleep)');
End;

Procedure Do_Play;
Begin
  SetupFiles;
  If FAST_MODE Then Begin
    PutLine('Running in fast mode..');
    PutLine('Load entity..');
    LoadEntitys;
    PutLine('Load block..');
    LoadBlocks;
    PutLine('Load exit..');
    LoadExits;
  End;
  If LookupUsername(MyUserId, MyUserLog) Then Begin
    If WelcomeBack Then Begin
      ParseCmd;
      ExitPlaying;
    End;
  End Else If MakeNewPlayer Then Begin
    ParseCmd;
    ExitPlaying;
  End;
  SetupFiles;
End;

Procedure Do_Rebuild;
Var S : String_Type;
    EntityLog : $UWord;
Begin
  Setupfiles;
  PutLine('Initialize say file.. ');
  InitSayFile(10);
  PutLine('Initialize user file.. ');
  InitUserFile(10);
  PutLine('Initialize line file.. ');
  InitLineFile(10);
  PutLine('Initialize entity file.. ');
  InitEntityFile(10);
  PutLine('Initialize map file.. ');
  InitItemMapFile(10);
  PutLine('Initialize block file.. ');
  InitBlockFile(10);
  PutLine('Initialize exit file.. ');
  InitExitFile(10);
  PutLine('Initialize event file.. ');
  InitEventFile;
  PutLine('Initialize effect file.. ');
  InitEffectFile(10);
  PutLine('Initialize memory file.. ');
  InitMemoryFile(10);
  PutLine('Create the great beginning..');
  CreateRoom('The great beginning', EntityLog);
  PutLine('Create human..');
  CreateClass('Human', EntityLog);
  Setupfiles;
End;

Procedure Do_Root(Var S : String_Type);
Begin
  While (S.Length = 0) Do 
    GrabLine('New path? ', S);
  Root := S;
  S := '';
  PutLine('Done. ');
End;

Procedure Do_Force(Var S : String_Type);
Begin
  While (S.Length = 0) Do 
    GrabLine('New username? ', S);
  MyUserId := S;
  S := '';
  PutLine('You are now '+MyUserId+'.');
End;

Begin
  SetupMisc;
  MyUserId := GetUserId;
  PutLine('Welcome to UB monster version 1.0! ', 1);
  While Not Done Do Begin
    If GrabTable('Start> ', CmdTable, S, Cmd) Then
      Case Cmd Of 
        C_Quit    : Done := True;
        C_PLay    : Do_Play;
        C_Rebuild : If IsWindy Then Do_Rebuild;
        C_Root    : If IsWindy Then Do_Root(S);
        C_Force   : If IsWindy Then Do_Force(S);
      End
    Else PutLine('Type ? for a list of command. ');
  End;
  PutLine('Thank you for playing UB monster! ');
End.
