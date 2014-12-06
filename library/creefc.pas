[
  Inherit
    ('SYS$LIBRARY:STARLET','SYS$LIBRARY:PASCAL$LIB_ROUTINES','ERROR.PEN'),
  Environment
    ('CREEFC.PEN')
]

MODULE Creefc;

[HIDDEN]TYPE
  v_array = varying [256] of char;

[GLOBAL]
PROCEDURE  Create_event_flag_cluster (   name : v_array;
                                      cluster : v_array := '64-95' );
VAR
  ret_status : integer;
  group : integer;
BEGIN
  IF ( cluster = '64-95' ) then
    group := 64
  ELSE
  IF ( cluster = '96-127' ) then
    group := 96
  ELSE
    ERROR ('%INTERACT-CREATE-EVENT_FLAG_CLUSTER, cluster groups ''64-95'' & ''96-127'' only.');

  ret_status := $ascefc (efn:=group,name:=name);
  IF not odd(ret_status) then
    LIB$SIGNAL(ret_status);
END;

END.
