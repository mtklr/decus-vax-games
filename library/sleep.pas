[
  Inherit
    ('SYS$LIBRARY:STARLET','SYS$LIBRARY:PASCAL$LIB_ROUTINES','ERROR'),
  Environment
    ('SLEEP.PEN')
]

MODULE SLEEP;

[HIDDEN]
TYPE

  $QUAD = [QUAD,UNSAFE] RECORD
    L0:UNSIGNED; L1:INTEGER; END;
  v_array = varying [256] of char;

[HIDDEN]
VAR
  efn : [VOLATILE] unsigned;
  initialized : boolean;


[HIDDEN]
PROCEDURE  Initialise;
BEGIN
  initialized := true;
  lib$get_ef (efn);
  IF efn = -1 then
    ERROR ('%INTERACT-SLEEP_START_INITIALIZE, No Event Flag Avaliable.');
END;

[GLOBAL]
PROCEDURE  Sleep_start ( interval : integer );
VAR
  delta_timer_alarm : $quad;
  ret_status            : integer;
BEGIN
  IF not initialized then
    initialise;

  IF interval > 0 then
    BEGIN
      ret_status := LIB$EMUL (interval, -100000, 0, delta_timer_alarm);
      IF not odd(ret_status) then
        LIB$SIGNAL(ret_status);
      ret_status := $setimr (efn:=efn,daytim:=delta_timer_alarm);
      IF not odd(ret_status) then
        LIB$SIGNAL(ret_status);
    END;
END;


[GLOBAL]
PROCEDURE  Sleep_wait;
VAR
  ret_status            : integer;
BEGIN
  ret_status := $waitfr (efn:=efn);
  IF not odd(ret_status) then
    LIB$SIGNAL(ret_status);
END;


[GLOBAL]
PROCEDURE  Sleep ( sec : integer := 0; frac : [TRUNCATE] real );
VAR
  Hundredths : integer;
  delta_wake_time : $quad;
  ret_status            : integer;
BEGIN
  Hundredths := sec*100;
  IF PRESENT(frac) then
    Hundredths := Hundredths + round(frac*100);
  IF ( hundredths > 0 ) then
    BEGIN
      ret_status := LIB$EMUL (Hundredths, -100000, 0, delta_wake_time);
      IF not odd(ret_status) then
        LIB$SIGNAL(ret_status);
      ret_status := $Schdwk ( daytim := delta_wake_time );
      IF not odd(ret_status) then
        LIB$SIGNAL(ret_status)
      ELSE
        BEGIN
          ret_status := $Hiber;
          IF not odd(ret_status) then
            LIB$SIGNAL(ret_status);
        END;
    END;
END;

END.
