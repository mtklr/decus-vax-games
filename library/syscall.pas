[
  Inherit
    ('SYS$LIBRARY:STARLET','SYS$LIBRARY:PASCAL$LIB_ROUTINES'),
  Environment
    ('SYSCALL.PEN')
]

MODULE SYSCALL;

[GLOBAL]
PROCEDURE  TERMINATE ( code : integer := 1 );
BEGIN
  $EXIT ( code );
END;

[GLOBAL]
PROCEDURE  KILL ( PID : [TRUNCATE] UNSIGNED );
VAR
  ret_status : integer;
BEGIN
  IF PRESENT(PID) then
    ret_status := $DELPRC(pidadr:=PID)
  ELSE
    ret_status := $DELPRC;
  IF not odd(ret_status) then
    LIB$SIGNAL(ret_status);
END;

END.
