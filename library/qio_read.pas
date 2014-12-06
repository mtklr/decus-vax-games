[
  Inherit
    ('SYS$LIBRARY:STARLET','SYS$LIBRARY:PASCAL$LIB_ROUTINES','ERROR','DEBUG'),
  Environment
    ('QIO_READ.PEN')
]

MODULE QIO_READ;

[HIDDEN]
TYPE
  $UWORD = [WORD] 0..65535;
  $UBYTE = [BYTE] 0..255;
  v_array = varying [256] of char;

[HIDDEN]VAR
{QIO}
  efn                : [VOLATILE] unsigned;
  channel            : $UWORD;
  channel_initialized : Boolean;


[HIDDEN]
PROCEDURE  initialize_channel;
VAR
  ret_status : integer;
BEGIN
  if not debugger_initialized then
    DBG_init;
  channel_initialized := true;
  lib$get_ef (efn);
  IF efn = -1 then
    ERROR ('%QIO-F-INITIALIZE, No Event Flag Avaliable.');
  ret_status := $assign ( chan := channel , devnam := 'tt:' );
  IF not odd(ret_status) then
    LIB$SIGNAL(ret_status);
END;


[GLOBAL]
FUNCTION  QIO_1_char_now : char;
VAR
  buffer : packed array [1..1] of char;
  ret_status : integer;
BEGIN
  IF not channel_initialized then
    initialize_channel;
  IF debugger_on and not debugger_alone then
    BEGIN
      dbg^.request := 3;
      dbg_call;
      Qio_1_char_now := dbg^.dbg_qio_1_char_now;
    END
  ELSE
    BEGIN
      buffer[1] := chr(-1);
      ret_status := $qiow ( efn:= efn,
                           chan:= channel,
                           func:= io$_readvblk+io$m_timed+io$m_noecho+io$m_nofiltr,
                             p1:= buffer,
                             p2:= 1, { bufferlength }
                             p3:= 0
                           );
      IF not odd(ret_status) then
        LIB$SIGNAL(ret_status);
      Qio_1_char_now := buffer[1];
    END;
END;


[GLOBAL]
FUNCTION  QIO_readln ( characters : integer ) : v_array;
TYPE
  iosb_type = [QUAD] Record
                       Status : $uword;
                       Nrbytes : $uword;
                       Terminator : char;
                       Reserved : $ubyte;
                       Terminator_length : $ubyte;
                       Cursor_offset : $ubyte
                     End;
VAR
  temp : v_array;
  Read_iosb : iosb_type;
  ret_status : integer;
BEGIN
  IF not channel_initialized then
    initialize_channel;
  IF debugger_on and not debugger_alone then
    BEGIN
      dbg^.request := 4;
      dbg^.dbg_qio_readln_characters := characters;
      dbg_call;
      qio_readln := dbg^.dbg_qio_readln;
    END
  ELSE
    BEGIN
      ret_status := $qiow ( efn:= efn,
                           chan:= channel,
                           func:= io$m_timed+io$_readvblk+io$m_noecho+io$m_nofiltr+io$m_escape,
                           iosb:= read_iosb,
                             p1:= temp.body,
                             p2:= characters,
                             p3:= 0
                          );
    
      IF not odd(ret_status) then
        LIB$SIGNAL(ret_status);
    
      temp.length := ( read_iosb.Nrbytes );
      qio_readln := temp;
    END;
END;


[GLOBAL]
FUNCTION  QIO_1_char : char;
VAR
  buffer : packed array [1..1] of char;
  ret_status : integer;
BEGIN
  IF not channel_initialized then
    initialize_channel;
  IF debugger_on and not debugger_alone then
    BEGIN
      dbg^.request := 1;
      dbg_call;
      Qio_1_char := dbg^.dbg_qio_1_char;
    END
  ELSE
    BEGIN
      ret_status := $qiow ( efn:= efn,
                           chan:= channel,
                           func:= io$_readvblk+io$m_noecho+io$m_nofiltr,
                             p1:= buffer,
                             p2:= 1
                          );
      IF not odd(ret_status) then
        LIB$SIGNAL(ret_status);
      Qio_1_char := buffer[1];
    END;
END;


[GLOBAL]
PROCEDURE  QIO_purge;
VAR
  ret_status : integer;
BEGIN
  IF channel_initialized then
    IF debugger_on and not debugger_alone then
      BEGIN
        dbg^.request := 5;
        dbg_call;
      END
    ELSE
      BEGIN
        ret_status := $qiow ( efn:= efn,
                             chan:= channel,
                             func:= io$_readvblk+io$m_purge
                            );
        IF not odd(ret_status) then
          LIB$SIGNAL(ret_status);
      END;
END;


[GLOBAL]
FUNCTION  QIO_1_char_timed ( delay : integer ) : char;
VAR
  buffer : packed array [1..1] of char;
  ret_status : integer;
BEGIN
  IF not channel_initialized then
    initialize_channel;
  IF debugger_on and not debugger_alone then
    BEGIN
      dbg^.request := 6;
      dbg^.dbg_qio_1_char_timed_delay := delay;
      dbg_call;
      Qio_1_char_timed := dbg^.dbg_qio_1_char_timed;
    END
  ELSE
    BEGIN
      buffer[1] := chr(255);
      ret_status := $qiow ( efn:= efn,
                           chan:= channel,
                           func:=io$m_timed+io$_readvblk+io$m_noecho+io$m_nofiltr+io$m_escape,
                             p1:= buffer,
                             p2:= 1,
                             p3:= delay
                           );
      IF not odd(ret_status) then
        LIB$SIGNAL(ret_status);
      Qio_1_char_timed := buffer[1];
    END;
END;

END.
