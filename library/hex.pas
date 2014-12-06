[
  Inherit
    ('SYS$LIBRARY:STARLET'),
  Environment
    ('HEX.PEN')
]

MODULE HEX;

[HIDDEN]TYPE
  v_array = varying [256] of char;

[GLOBAL]
FUNCTION  Hex ( number, len : integer) : v_array;
VAR
  Result : v_array;
BEGIN
  result := '';
  WHILE ( number <> 0 ) do
    BEGIN
      IF (number mod 16) < 10 then
        result := chr(ord('0')+(number mod 16)) +  result
      ELSE
        result := chr(ord('A')+(number mod 16)-10) +  result;
      number := number div 16;
    END;    
  WHILE result.length < len do
    result := '0' + result;
  hex := result;
END;

END.
