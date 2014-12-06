[
  Inherit
    ('SYS$LIBRARY:STARLET','SYS$LIBRARY:PASCAL$LIB_ROUTINES',
     'SYS$LIBRARY:PASCAL$STR_ROUTINES','VT100'),
  Environment
    ('CASE_CONVERT.PEN')
]

MODULE CASE_CONVERT;

[HIDDEN]TYPE
  v_array = varying [256] of char;

[GLOBAL]
FUNCTION  Upper_case ( c : char ) : char;
BEGIN
  IF ( c in ['a'..'z'] ) then
    c := chr ( ord(c) - ord('a') + ord('A') );
  upper_case := c;
END;

[GLOBAL]
FUNCTION  Lower_case ( c : char ) : char;
BEGIN
  IF ( c in ['A'..'Z'] ) then
    c := chr ( ord(c) - ord('A') + ord('a') );
  lower_case := c;
END;

[GLOBAL]
FUNCTION  Upper_string ( text : v_array ) : v_array;
VAR
  ret_status : integer;
BEGIN
  ret_status := str$upcase (text.body,text);
  IF not odd(ret_status) then
    LIB$SIGNAL(ret_status);
  upper_string := text;
END;

[GLOBAL]
FUNCTION  Lower_string ( text : v_array ) : v_array;
VAR
  i : integer;
BEGIN
  FOR i := 1 to text.length do
    text[i] := Lower_case (text[i]);
  lower_string := text;
END;

END.
