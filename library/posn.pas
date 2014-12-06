[
  Inherit
    ('VT100','QIO_WRITE'),
  Environment
    ('POSN.PEN')
]

MODULE POSN;

[HIDDEN]
TYPE
  v_array = varying [256] of char;

[GLOBAL]
PROCEDURE  Posn ( x , y : integer );
VAR
  sx,sy : v_array;
BEGIN
  IF ( x < 2 ) then
    IF ( y < 2 ) then
      qio_write ( VT100_ESC + '[H' )
    ELSE
      BEGIN
        writev (sy,y:1);
        qio_write ( VT100_ESC + '[' + sy + 'H' );
      END
  ELSE
  IF ( y < 2 ) then
    BEGIN
      writev (sx,x:1);
      qio_write ( VT100_ESC + '[;' + sx + 'H' );
    END
  ELSE
    BEGIN
      writev (sx,x:1);
      writev (sy,y:1);
      qio_write ( VT100_ESC + '[' + sy + ';' + sx + 'H' );
    END;
END;

END.
