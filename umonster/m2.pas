[Inherit('Sys$Library:Starlet',
         'M1'),
 Environment('M2')]

Module M2;


(* Error Function *)

Const
  ErrFn = 'DISK$USERDISK1:[MAS0.MASMONST.DATAFILES.MONSTERII]Error.Mon';

Var
  ErrMsg : Long_String_Type;
  ErrFile : [Hidden] Text;

Procedure SetupError;
Var  IsOpen : [Static] Boolean := False;
Begin
  If IsOpen Then Begin
    IsOpen := False;  Close(ErrFile);
  End Else Begin
    Open(ErrFile, ErrFn, History := Unknown, Sharing := ReadWrite);
    Extend(ErrFile);
    IsOpen := True;
  End;
End;

Procedure LogErr(S : Long_String_Type);
Var  Dstr, Tstr : Packed Array[1..11] Of Char;
Begin
  PutLine(S);
  Date(Dstr);  Time(TStr);
  S := Dstr + ' ' + Tstr + ' ' + S;
  WriteLn(ErrFile, S);
End;


(* RMS functions *)

Const
  FILE_ALLOC = 1;  FILE_SAY = 2;   FILE_USER = 3;    FILE_LINE = 4;
  FILE_ENTITY = 5; FILE_BLOCK = 6; FILE_ITEMMAP = 7; FILE_EXIT = 8;
  FILE_EVENT = 9;  FILE_WHO = 10;  FILE_EFFECT = 11; FILE_MEMORY = 12;
  MaxFiles = 13;

  ALLOC_SAY = 1;   ALLOC_USER = 2;    ALLOC_LINE = 3; ALLOC_ENTITY = 4;
  ALLOC_BLOCK = 5; ALLOC_ITEMMAP = 6; ALLOC_EXIT = 7; ALLOC_EFFECT = 8;
  ALLOC_MEMORY = 9;
  MaxAllocation = 9;

  Wait_Time = 20;

[Hidden]
Type
  Unsafe_File = [Unsafe] File Of Char;
  Ptr_To_Fab  = ^Fab$Type;
  Ptr_To_Rab  = ^Rab$Type;

Var
  Fnames : Array[1..MaxFiles] Of Short_String_Type := (
    'Allocation file', 'Say file', 'User file', 'Line file',
    'Entity file', 'Block file', 'Item map file', 'Exit file',
    'Event file', 'Location file', 'Effect file', 'Memory file',
    '');

  Allocnames : Array[1..MaxAllocation] Of Short_String_Type := (
    'Say', 'User', 'Line', 'Entity', 'Block',
    'Item map', 'Exit', 'Effect', 'Memory');

[Hidden]
Var
  Fab_Ptrs : Array[1..MaxFiles] Of Ptr_To_Fab;
  Rab_ptrs : Array[1..MaxFiles] Of Ptr_To_Rab;
  Rms_Status : Unsigned;

[External, Hidden]
Function Pas$Fab(VAR F : UnSafe_File) : Ptr_To_Fab; Extern;

[External, Hidden]
Function Pas$Rab(VAR F : Unsafe_File) : Ptr_To_Rab; Extern;

Procedure Open_File(F_Id : $UWord; Var F : Unsafe_File; Fn : String_Type;
                    Rsz : $UWord);
Begin
  Open(F, Fn, History := Unknown, Access_Method := Direct, Sharing := ReadWrite);
  Fab_Ptrs[F_Id] := Pas$Fab(F);
  Rab_Ptrs[F_Id] := Pas$Rab(F);
  Rab_Ptrs[F_Id]^.RAB$W_RSZ := Rsz;
End;

Procedure Get_Record(F_Id : $UWord; R_Id, R : [Long, Unsafe] Unsigned);
Begin
  Rab_Ptrs[F_Id]^.RAB$B_RAC := RAB$C_KEY;
  Rab_Ptrs[F_Id]^.RAB$B_TMO := Wait_Time;
  Rab_Ptrs[F_Id]^.RAB$L_ROP := RAB$M_WAT + RAB$M_TMO;
  Rab_Ptrs[F_Id]^.RAB$L_UBF := R;
  Rab_Ptrs[F_Id]^.RAB$L_KBF := IAddress(R_Id);
  Rms_Status := $GET(Rab_Ptrs[F_Id]^);
  If Rms_Status <> RMS$_NORMAL Then Begin
    WriteV(ErrMsg, 'Error Get Record ', FNames[F_Id], ' ', Rms_Status);
    LogErr(ErrMsg);
    Halt;
  End;
End;

Procedure Put_Record(F_Id : $UWord; R_Id, R : [Long, Unsafe] Unsigned);
Begin
  Rab_Ptrs[F_Id]^.RAB$B_RAC := RAB$C_KEY;
  Rab_Ptrs[F_Id]^.RAB$B_TMO := Wait_Time;
  Rab_Ptrs[F_Id]^.RAB$L_ROP := RAB$M_UIF + RAB$M_WAT + RAB$M_TMO;
  Rab_Ptrs[F_Id]^.RAB$L_RBF := R;
  Rab_Ptrs[F_Id]^.RAB$L_KBF := IAddress(R_Id);
  Rms_Status := $Put(Rab_Ptrs[F_Id]^);
  If Rms_Status <> RMS$_NORMAL Then Begin
    WriteV(ErrMsg, 'Error Put Record ', FNames[F_Id], ' ', Rms_Status);
    LogErr(ErrMsg);
    Halt;
  End;
End;

Procedure Update_Record(F_Id : $UWord; R_Id, R : [Long, Unsafe] Unsigned);
Begin
  Rab_Ptrs[F_Id]^.RAB$B_RAC := RAB$C_KEY;
  Rab_Ptrs[F_Id]^.RAB$B_TMO := Wait_Time;
  Rab_Ptrs[F_Id]^.RAB$L_ROP := RAB$M_RLK + RAB$M_WAT + RAB$M_TMO;
  Rab_Ptrs[F_Id]^.RAB$L_RBF := R;
  Rab_Ptrs[F_Id]^.RAB$L_KBF := IAddress(R_Id);
  Rms_Status := $Find(Rab_Ptrs[F_Id]^);
  Rms_Status := $Update(Rab_Ptrs[F_Id]^);
  If Rms_Status <> RMS$_NORMAL Then Begin
    WriteV(ErrMsg, 'Error Update Record ', FNames[F_Id], ' ', Rms_Status);
    LogErr(ErrMsg);
    Halt;
  End;
End;

Procedure Free_Record(F_Id : $UWord);
Begin
  Rms_Status := $RELEASE(Rab_Ptrs[F_Id]^);
  If Rms_Status <> RMS$_NORMAL Then Begin
    WriteV(ErrMsg, 'Error Free Record ', FNames[F_Id], ' ', Rms_Status);
    LogErr(ErrMsg);
  End;
End;

Procedure Read_Record(F_Id : $UWord; R_Id, R : [Long, Unsafe] Unsigned);
Begin
  Rab_Ptrs[F_Id]^.RAB$B_RAC := RAB$C_KEY;
  Rab_Ptrs[F_Id]^.RAB$B_TMO := Wait_Time;
  Rab_Ptrs[F_Id]^.RAB$L_ROP := RAB$M_NLK + RAB$M_WAT + RAB$M_TMO;
  Rab_Ptrs[F_Id]^.RAB$L_UBF := R;
  Rab_Ptrs[F_Id]^.RAB$L_KBF := IAddress(R_Id);
  Rms_Status := $GET(Rab_Ptrs[F_Id]^);
  If Rms_Status <> RMS$_NORMAL Then Begin
    WriteV(ErrMsg, 'Error Read Record ', FNames[F_Id], ' ', Rms_Status);
    LogErr(ErrMsg);
    Halt;
  End;
End;


(* Allocation functions *)

Const
  Max_Alloc_Item = 20000;
  Default_Root = 'DISK$USERDISK1:[MAS0.MASMONST.DATAFILES.MONSTERII]';

Type
  Alloc_Record_Type = Packed Record
    Top, Topused, Used : $UWord;
    Free : Packed Array[1..Max_Alloc_Item] Of Boolean;
  End;

Var
  Root : String_Type := Default_Root;
  Alloc_File : File Of Alloc_Record_Type;

Procedure SetUpAlloc;
Var IsOpen : [Static] Boolean := False;
Begin
  If IsOpen Then Begin
    IsOpen := False; Close(Alloc_File);
  End Else Begin
    IsOpen := True;
    Open_File(FILE_ALLOC, Alloc_File, Root+'Alloc.Mon', Size(Alloc_Record_Type));
  End;
End;

Procedure InitAlloc(Id, Max : $UWord);
Var Alloc_Record : Alloc_Record_Type; I : Integer;
Begin
  Alloc_Record.Top     := Max;
  Alloc_Record.Topused := 0;
  Alloc_Record.Used    := 0;
  For I := 1 to Max_Alloc_Item do Alloc_Record.Free[i] := True;
  Put_Record(FILE_ALLOC, Id, IAddress(Alloc_Record));
End;

[Hidden]
Function Allocated(Var At : $UWord; Amount : $UWord;
   Var Alloc_Record : Alloc_Record_Type): Boolean;
Var Going : Boolean := True; I : $UWord := 0;
Begin
  While Going And (I < Amount) Do Begin
    Going := Alloc_Record.Free[At + I];
    I := I + 1;
  End;
  If Not Going Then At := At + I;
  Allocated := Going;
End;

Function Alloc_Items(Id : $UWord; Var Log : $UWord;
   Amount : $UWord := 1): Boolean;
Var Alloc_Record : Alloc_Record_Type; Done, Found : Boolean := False;
  I, C : $UWord := 1;
Begin
  Get_Record(FILE_ALLOC, Id, IAddress(Alloc_Record));
  While Not Done Do Begin
    If Allocated(I, Amount, Alloc_Record) Then Begin
      Log := I;
      Found := True;
      For C := 0 To Amount - 1 Do
        Alloc_Record.Free[Log+C] := False;
      Alloc_Record.Used := Alloc_Record.Used + Amount;
      If (Alloc_Record.Used > Alloc_Record.Topused) Then
        Alloc_Record.Topused := Alloc_Record.Used;
      Update_Record(FILE_ALLOC, Id, IAddress(Alloc_Record));
    End;
    Done := Found Or (I >= Alloc_Record.Top);    
  End;
  If Not Found Then Free_Record(FILE_ALLOC);
  Alloc_Items := Found;
End;

Procedure Dealloc_Items(Id, Num : $UWord; Amount : $UWord := 1);
Var Alloc_Record : Alloc_Record_Type; I : $UWord;
Begin
  Get_Record(FILE_ALLOC, Id, IAddress(Alloc_Record));
  For I := 0 To Amount - 1 Do
    Alloc_Record.Free[Num+I] := True;
  Alloc_Record.Used := Alloc_Record.Used - Amount;
  Update_Record(FILE_ALLOC, Id, IAddress(Alloc_Record));
End;

Procedure Alloc_Slot(Id, Slot : $UWord; IsFree : Boolean);
(*
 *  This procedure should only be called from debugging
 *  or packing utilities. Be careful!
 *)
Var  Alloc_Record : Alloc_Record_Type;
Begin
  Get_Record(FILE_ALLOC, Id, IAddress(Alloc_Record));
  Alloc_Record.Free[Slot] := IsFree;
  Update_Record(FILE_ALLOC, Id, IAddress(Alloc_Record));
End;

Function Inc_Alloc_Quota(Id, Amount : $UWord;
   Var Start, Finish : $UWord): Boolean;
Var Alloc_Record : Alloc_Record_Type;
Begin
  Get_Record(FILE_ALLOC, Id, IAddress(Alloc_Record));
  If Alloc_Record.Top + Amount > Max_Alloc_Item Then Begin
    Free_Record(FILE_ALLOC);
    Inc_Alloc_Quota := False;
  End Else Begin
    Start := Alloc_Record.Top + 1;
    Finish := Alloc_Record.Top + Amount;
    Alloc_Record.Top := Finish;
    Update_Record(FILE_ALLOC, Id, IAddress(Alloc_Record));
    Inc_Alloc_Quota := True;
  End;
End;

Procedure Print_Alloc(Id : $UWord);
Var Alloc_Record : Alloc_Record_Type; I, J : $UWord := 1; S : String_Type := '';
Begin
  Read_Record(FILE_ALLOC, Id, IAddress(Alloc_Record));
  WriteV(S, '   Used: ', Alloc_Record.Used:0,
            '   Top used: ', Alloc_Record.Topused:0,
            '   Max: ', Alloc_Record.Top:0);
  PutLine(S);
  PutLine(DivLine+DivLine);
  While I <= Alloc_Record.Top Do Begin
    Writev(S, I:5, ': '); J := 1;
    While (J <= 50) And (I <= Alloc_Record.Top) Do Begin
      If Alloc_Record.Free[I] Then S := S + '0'
      Else S := S + '1';
      If (J Mod 10) = 0 Then S := S + ' ';
      I := I + 1; J := J + 1;
    End;
    Putline(S);
  End;
  PutLine(DivLine+DivLine);
End;

Procedure Show_Alloc;
Var Allocation : Alloc_Record_Type;
    I : Integer;
    S : String_Type;
Begin
  PutLine('                           Top      Used  Top used  ');
  PutLine(DivLine+DivLine);
  For I := 1 To MaxAllocation Do Begin
    Read_Record(FILE_ALLOC, I, IAddress(Allocation));
    WriteV(S, PadStr(Allocnames[I], 20), Allocation.Top:10,
    Allocation.Used:10, Allocation.Topused:10);
    PutLine(S);
  End;
  PutLine(DivLine+DivLine);
End;

End.
