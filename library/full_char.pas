[
  Inherit
    ('SYS$LIBRARY:STARLET','VT100'),
  Environment
    ('FULL_CHAR.PEN')
]

MODULE FULL_CHAR;

[HIDDEN]TYPE
  v_array = varying [256] of char;

[GLOBAL]
FUNCTION  Full_char ( character : char ) : v_array;
VAR
  c : integer;
BEGIN
  c := ord(character);
  IF ( c in [0..31,127] ) then
    full_char := VT100_inverse + chr(64+c) + VT100_normal
  ELSE
  IF ( c < 128 ) then
    full_char := character
  ELSE
  IF ( (c-128) in [0..31,127] ) then
    full_char := VT100_inverse + VT100_bright + chr(c-64) + VT100_normal
  ELSE
    full_char := VT100_bright + character;
END;

END.
