[
  Inherit
    ('SYS$LIBRARY:STARLET','SYS$LIBRARY:PASCAL$LIB_ROUTINES'),
  Environment
    ('STOPWATCH.PEN')
]

MODULE STOPWATCH;

[HIDDEN]
TYPE
  $UWORD = [WORD] 0..65535;
  v_array = varying [256] of char;
  date_time_type = array [1..7] of $uword;

[HIDDEN]
VAR
  start_date_time : [GLOBAL] date_time_type;
  stop_date_time : [GLOBAL] date_time_type;


[GLOBAL]
PROCEDURE  Start_stopwatch;
VAR
  ret_status : integer;
BEGIN
  ret_status := $numtim (start_date_time);
  IF not odd(ret_status) then
    LIB$SIGNAL(ret_status);
END;


[GLOBAL]
FUNCTION  Stop_stopwatch : v_array;
VAR
  temp : date_time_type;
  ret_status : integer;
  i : integer;
  s : array [4..7] of v_array;
BEGIN
  ret_status := $numtim (stop_date_time);
  IF not odd(ret_status) then
    LIB$SIGNAL(ret_status);

  FOR i := 7 downto 5 do
    IF ( stop_date_time[i] - start_date_time[i] ) < 0 then
      stop_date_time[i-1] := stop_date_time[i-1] - 1;

  IF ( stop_date_time[7] - start_date_time[7] ) < 0 then
    stop_date_time[7] := stop_date_time[7] + 100;
  IF ( stop_date_time[6] - start_date_time[6] ) < 0 then
    stop_date_time[6] := stop_date_time[6] + 60;
  IF ( stop_date_time[5] - start_date_time[5] ) < 0 then
    stop_date_time[5] := stop_date_time[5] + 60;
  IF ( stop_date_time[4] - start_date_time[4] ) < 0 then
    stop_date_time[4] := stop_date_time[4] + 24;

  FOR i := 4 to 7 do
    BEGIN
      temp[i] := stop_date_time[i] - start_date_time[i];
      writev (s[i],temp[i]:1);
      IF s[i].length=1 then
        s[i] := '0' + s[i];
    END;

  stop_stopwatch := s[4] + ':' + s[5] + ':' + s[6] + '.' + s[7];
END;

END.
