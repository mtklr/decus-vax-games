[
  Inherit
    ('QIO_WRITE','QIO_READ','IMAGE_DIR','POSN','CLEAR','RESET_SCREEN','VT100'),
  Environment
    ('SHOW_GRAPHEDT.PEN')
]

MODULE SHOW_GRAPHEDT ( Ingraphedt );

[HIDDEN]
TYPE
  v_array = varying [256] of char;
  string  = varying [20] of char;
[HIDDEN]
VAR
  ingraphedt     : text;
  image_dir_done : boolean;

[GLOBAL]
PROCEDURE  Show_graphedt ( filename : string; wait : boolean := true );
VAR
  line : v_array;
  rep : char;
BEGIN
  IF not image_dir_done then
    Image_dir;
  IF ( wait ) then
    rep := qio_1_char_now;
  OPEN (ingraphedt,'image_dir:'+filename,history:=readonly,error:=continue);
  IF status(ingraphedt) = 0 then
    BEGIN
      reset (ingraphedt);
      WHILE not eof(ingraphedt) and (( rep = chr(-1)) or ( not wait )) do
        BEGIN
          IF wait then
            rep := qio_1_char_now;
          readln (ingraphedt,line);
          qio_write (line);
        END;
      close (ingraphedt);
      posn (1,1);
      IF wait and ( rep = chr(-1) ) then
        rep := qio_1_char;
    END
  ELSE
    BEGIN
      clear;
      posn (18,10);
      qio_write ('couldn''t find filename .... '+filename);
      posn (28,20);
      qio_write (VT100_Bright+'Press  <'+VT100_Flash+'Return'+VT100_normal+VT100_bright+'>'+VT100_normal);
      posn (1,1);
      IF ( rep  = chr(-1) ) then
        rep := qio_1_char;
    END;
  reset_screen;
END;

END.
