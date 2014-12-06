[
  Inherit
    ('QIO_WRITE','GET_POSN','ERROR','VT100'),
  Environment
    ('SQUARE.PEN')
]

MODULE SQUARE;

[HIDDEN]
TYPE
  v_array = varying [256] of char;

[GLOBAL]
PROCEDURE  Square ( x1 , y1 , x2 , y2 : integer );
VAR
  i : integer;
  sx : v_array;
  buffer : v_array;
BEGIN
  IF ( x1 > x2 - 1 ) or ( y1 > y2 - 1 ) then
    ERROR ('%INTERACT-SQUARE, Top Corner Bottom Corner Overlap');
  IF ( abs(x2-x1) > 132 ) then
    ERROR ('%INTERACT-SQUARE, Size Error delta x distance too large.');
  IF ( abs(y2-y1) > 24 ) then
    ERROR ('%INTERACT-SQUARE, Size Error delta y distance too large.');

  buffer := get_posn (x1,y1) + VT100_graphics_on + 'l';
  FOR i := x1+1 to x2-1 do
    buffer := buffer + 'q';
  buffer := buffer + 'k';
  qio_write (buffer);
  writev(sx,x2-x1-1:1);
  sx := 'x' + VT100_ESC + '[' + sx + 'C' + 'x';
  FOR i := y1+1 to y2-1 do
    qio_write ( get_posn(x1,i)+ sx );
  buffer := get_posn (x1,y2) + 'm';
  IF ( x1 < x2 - 1 ) then
    FOR i := x1+1 to x2-1 do
      buffer := buffer + 'q';
  buffer := buffer + 'j' + VT100_graphics_off;
  qio_write (buffer);
END;

END.
