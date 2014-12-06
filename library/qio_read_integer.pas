[
  Inherit
    ('QIO_WRITE','QIO_READ','VT100'),
  Environment
    ('QIO_READ_INTEGER.PEN')
]

MODULE QIO_READ_INTEGER;

[HIDDEN]
TYPE
  $BIT8 = [BIT(8),UNSAFE] 0..255;
  v_array = varying [256] of char;


[HIDDEN]
FUNCTION Digit ( ch : char ) : boolean;
BEGIN
  Digit := (ch >= '0') and (ch <= '9')
END;


[HIDDEN]
FUNCTION  Number ( str : v_array ) : integer;
VAR
  n : integer;
  i : integer;
BEGIN
  n := 0;
  IF str.length > 0 then
    BEGIN
      FOR i := 1+(str[1]='-')::$bit8 to str.length do
        n := n * 10 + ord(str[i]) - ord('0');
      IF str[1]='-' then
        n := -n;
    END;
  number := n;
END;


[GLOBAL]
FUNCTION  qio_read_integer : integer;
VAR
  n : integer;
  c : char;
  negative : boolean;
  temp : v_array;
BEGIN
  temp := '';
  n := number(temp);

  c := qio_1_char;
  REPEAT
    IF ( c='-' ) then
      BEGIN
        qio_write (c);
        temp := '-';
        c := qio_1_char;
      END;

    REPEAT
      IF Digit(c) and 
        ((( n <= (MAXINT-number(c)) div 10 ) and ( n >=0 )) or
         (( n >= (-MAXINT+number(c)-1) div 10 ) and ( n < 0 ))) then
        BEGIN
          qio_write (c);
          temp := temp + c;
          n := number(temp);
        END
      ELSE
      IF ( c = chr(127) ) and ( temp <> '' ) then
        BEGIN
          qio_write (VT100_bs+' '+VT100_bs);
          temp.length := temp.length - 1;
          n := number(temp);
        END
      ELSE
        qio_write (VT100_bell);
      c := qio_1_char;
    UNTIL ( temp = '' ) or ( c = vt100_cr );
  UNTIL ( temp <> '' );
  qio_read_integer := number(temp);
  qio_writeln;
END;

END.
