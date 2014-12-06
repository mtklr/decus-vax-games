[
  Inherit
    ('SYS$LIBRARY:STARLET','VT100'),
  Environment
    ('GET_POSN.PEN')
]

MODULE GET_POSN;

[HIDDEN]TYPE
  v_array = varying [100] of char;

[GLOBAL]
FUNCTION  Get_Posn ( x , y : integer ) : v_array;
VAR
  sx,sy : v_array;
BEGIN
  IF ( x < 2 ) then
    IF ( y < 2 ) then
      get_posn := VT100_ESC + '[H'
    ELSE
      BEGIN
        writev (sy,y:1);
        get_posn := VT100_ESC + '[' + sy + 'H';
      END
  ELSE
  IF ( y < 2 ) then
    BEGIN
      writev (sx,x:1);
      get_posn := VT100_ESC + '[;' + sx + 'H';
    END
  ELSE
    BEGIN
      writev (sx,x:1);
      writev (sy,y:1);
      get_posn := VT100_ESC + '[' + sy + ';' + sx + 'H';
    END;
END;

END.
