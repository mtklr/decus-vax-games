[
  Inherit
    ('QIO_WRITE','QIO_READ','VT100'),
  Environment
    ('QIO_READ_VARYING.PEN')
]

MODULE QIO_READ_VARYING;

[HIDDEN]
TYPE
  v_array = varying [256] of char;

[GLOBAL]
FUNCTION  qio_read_varying ( chars : integer := 80 ) : v_array;
VAR
  c : char;
  temp : v_array;
BEGIN
  temp := '';

  c := qio_1_char;
  IF c <> chr(13) then
    REPEAT
      IF ( c in [' '..'~'] ) and ( temp.length < chars ) then
        BEGIN
          qio_write (c);
          temp := temp + c;
        END
      ELSE
      IF ( c = chr(127) ) and ( temp.length <> 0 ) then
        BEGIN
          qio_write (VT100_bs+' '+VT100_bs);
          temp.length := temp.length - 1;
        END
      ELSE
        qio_write (VT100_bell);
      c := qio_1_char;
    UNTIL ( c = vt100_cr );
  qio_read_varying := temp;
  qio_writeln;
END;

END.
