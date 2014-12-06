[
  Inherit
    ('SYS$LIBRARY:STARLET'),
  Environment
    ('DAY.PEN')
]

MODULE DAY;

[HIDDEN]TYPE
  v_array = varying [256] of char;

[GLOBAL]
FUNCTION  Day_str ( day : integer ) : v_array;
BEGIN
  CASE day of
    1 : day_str := 'MON';
    2 : day_str := 'TUE';
    3 : day_str := 'WED';
    4 : day_str := 'THU';
    5 : day_str := 'FRI';
    6 : day_str := 'SAT';
    7 : day_str := 'SUN';
  End;
END;

END.
