[
  Inherit
    ('SYS$LIBRARY:STARLET'),
  Environment
    ('SIGN.PEN')
]

MODULE SIGN;

[GLOBAL]
FUNCTION  Sign ( n : integer ) : integer;
BEGIN
  IF n < 0 then
    sign := -1
  ELSE
  IF n > 0 then
    sign := 1
  ELSE
    sign := 0;
END;

END.
