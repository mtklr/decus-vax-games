[
  Inherit
    (
      
      'SYS$LIBRARY:STARLET',
      'ERROR',
      'HANDLER',
      'CRESEC',
      'CREEFC'
    ),
  ENVIRONMENT
    ('DEBUG')
]

MODULE  Debug (output);

[HIDDEN]
CONST
  dbg_request = 96;
  dbg_reply   = 97;

[HIDDEN]
TYPE
  v_array = varying [256] of char;
  $DEFTYP = [UNSAFE] INTEGER;
  $DEFPTR = [UNSAFE] ^$DEFTYP;

TYPE
  debugger_data = Record
                    exit_please : boolean;
                    Partner : boolean;
                    Initialized : boolean;
                    message_from_partner : boolean;
                    message_reads : v_array;
                    CASE request : integer of
                      1 :
                        ( dbg_qio_1_char : char );
                      2 :
                        ( dbg_qio_write_speed : integer;
                          dbg_qio_write : v_array );
                      3 : 
                        ( dbg_qio_1_char_now : char );
                      4 :
                        ( dbg_qio_readln_characters : integer;
                          dbg_qio_readln : v_array );
                      6 :
                        ( dbg_qio_1_char_timed_delay : integer;
                          dbg_qio_1_char_timed : char );
                  End;

[HIDDEN]
VAR
  res : integer;

VAR
  dbg : ^debugger_data;
  debugger_initialized : boolean := false;
  debugger_alone : boolean;
  debugger_on : boolean;

[HIDDEN]
FUNCTION  DEBUG_FLAG : boolean;
Extern;

[HIDDEN]
PROCEDURE  DBG_Exit_Handler ( exit_reason : integer );
BEGIN
  dbg^.exit_please := true;
  dbg^.request := 0;
  $Setef ( efn := dbg_request );
END;


[GLOBAL]
PROCEDURE  DBG_init;
VAR
  i : integer;
  sect_end : $defptr;
BEGIN
  debugger_initialized := true;
  debugger_on := debug_flag;
  IF debugger_on then
    BEGIN
      create_global_section ('INTERACT_DBG',size(debugger_data),dbg,sect_end);
      IF dbg^.partner then
        BEGIN
          Setup_handler ( iaddress(DBG_Exit_handler) );
          debugger_alone := false;
          IF set_interlocked(dbg^.Initialized) then
            ERROR ('%INTERACT_DEBUG, One process is already in debug mode.');
          Create_event_flag_cluster ('INTERACT_DBG','96-127');
        END
      ELSE
        BEGIN
          debugger_alone := true;
          delete_global_section (dbg,sect_end);
        END;
    END;
END;

[GLOBAL]
PROCEDURE  DBG_call;
BEGIN
  IF debugger_alone then
    ERROR ('%INTERACT_DEBUG, Must not call if no partner.');
  REPEAT
    $Setef ( efn := dbg_request );
    $Waitfr ( efn := dbg_reply );
    $Clref ( efn := dbg_reply );
    IF ( dbg^.message_from_partner ) then
      writeln (dbg^.message_reads);
  UNTIL ( not dbg^.message_from_partner );
END;


END.
