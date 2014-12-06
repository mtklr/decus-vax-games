[
  Inherit
    ('SYS$LIBRARY:STARLET'),
  Environment
    ('DEC.PEN')
]

MODULE DEC;

[HIDDEN]TYPE
  v_array = varying [256] of char;

[GLOBAL]
FUNCTION  Dec ( number    : integer;
                pad_char  : char := ' ';
                pad_len   : integer := 0
              ) : v_array;
VAR
  Result : v_array;
BEGIN
  Writev (result,number:0);
  WHILE ( result.length < abs(pad_len) ) do
    IF ( pad_len < 0 ) then
      result := result + pad_char
    ELSE
      result := pad_char + result;
  dec := result;
END;

END.
