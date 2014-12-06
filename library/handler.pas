[
  Inherit
    ('SYS$LIBRARY:STARLET','SYS$LIBRARY:PASCAL$LIB_ROUTINES','ERROR'),
  Environment
    ('HANDLER.PEN')
]

MODULE HANDLER;

[HIDDEN]
TYPE
  $UWORD = [WORD] 0..65535;
  v_array = varying [256] of char;

[HIDDEN]
VAR
  efn : [VOLATILE] unsigned;
  channel : $UWORD;
  channel_initialized : boolean;

VAR
{Handler}
  desblk : [GLOBAL] Record
                      findlink   : integer;
                      proc       : integer;
                      arglist    : array [0..1] of integer;
                      exitreason : integer;
                    End;


[HIDDEN]
PROCEDURE  initialize_channel;
VAR
  ret_status            : integer;
BEGIN
  channel_initialized := true;
  lib$get_ef (efn);
  IF efn = -1 then
    ERROR ('%HANDLER-F-INITIALIZE, No Event Flag Avaliable.');
  ret_status := $assign ( chan := channel , devnam := 'tt:' );
  IF not odd(ret_status) then
    LIB$SIGNAL(ret_status);
END;

[HIDDEN]
PROCEDURE  ctrlc_ast;
BEGIN
  $exit ( code := ss$_clifrcext );
END;

[GLOBAL]
PROCEDURE  Force;
VAR
  ret_status : integer;
BEGIN
  IF not channel_initialized then
    initialize_channel;
  ret_status := $qiow ( efn  := efn,
                        chan := channel,
                        func := io$_setmode + io$m_ctrlcast,
                        p1   := %immed iaddress (ctrlc_ast)
                      );
  IF not odd(ret_status) then
    LIB$SIGNAL(ret_status);
END;


[GLOBAL]
PROCEDURE Setup_handler ( handler_address : integer );
VAR
  ret_status : integer;
BEGIN
  WITH desblk do
    BEGIN
      proc       := handler_address;
      arglist[0] := 1;
      arglist[1] := iaddress(exitreason);
    END;

  ret_status := $DCLEXH (desblk);
  IF not odd(ret_status) then
    LIB$SIGNAL(ret_status);
END; 


[GLOBAL]
PROCEDURE  No_handler;
VAR
  ret_status : integer;
BEGIN
  ret_status := $CANEXH (desblk);
  IF not odd(ret_status) then
    LIB$SIGNAL(ret_status);
END;

END.
