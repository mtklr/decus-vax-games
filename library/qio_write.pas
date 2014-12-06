[
  Inherit
    ('SYS$LIBRARY:STARLET','SYS$LIBRARY:PASCAL$LIB_ROUTINES','VT100','DEBUG'),
  Environment
    ('QIO_WRITE.PEN')
]

MODULE QIO_WRITE;

[HIDDEN]
TYPE
  $UWORD = [WORD] 0..65535;
  v_array = varying [256] of char;

[HIDDEN]
VAR
  channel               : $UWORD;
  channel_initialized    : boolean;

VAR
  qio_write_speed : integer := 0;   { never changed set with the debugger }

[HIDDEN]
PROCEDURE  initialize_channel;
VAR
  ret_status            : integer;
BEGIN
  if not debugger_initialized then
    DBG_init;
  channel_initialized := true;
  ret_status := $assign ( chan := channel , devnam := 'tt:' );
  IF not odd(ret_status) then
    LIB$SIGNAL(ret_status);
END;


[GLOBAL]
PROCEDURE  QIO_write ( text : v_array );
VAR
  ret_status            : integer;
BEGIN
  IF not channel_initialized then
    initialize_channel;
  IF debugger_on and not debugger_alone then
    BEGIN
      dbg^.request := 2;
      dbg^.dbg_qio_write_speed := qio_write_speed;
      dbg^.dbg_qio_write := text;
      dbg_call;
    END
  ELSE
    BEGIN
      ret_status := $qiow (chan:= channel,
                           func:= io$_writevblk,
                             p1:= text.body,
                             p2:= text.length
                          );
      IF not odd(ret_status) then
        LIB$SIGNAL(ret_status);
    END;
END;


[GLOBAL]
PROCEDURE  QIO_writeln ( text : [TRUNCATE] v_array );
BEGIN
  IF present(text) then
    QIO_write ( text );
  QIO_write ( VT100_cr  + VT100_lf );
END;

END.
