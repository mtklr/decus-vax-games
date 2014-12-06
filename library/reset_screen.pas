[
  Inherit
    ('QIO_WRITE','VT100'),
  Environment
    ('RESET_SCREEN.PEN')
]

MODULE RESET_SCREEN;

[HIDDEN]
TYPE
  v_array = varying [256] of char;

[GLOBAL]
PROCEDURE  Reset_screen;
BEGIN
  qio_write ( VT100 + VT100_graphics_off + VT100_normal + VT100_normal_scroll + VT100_no_application_keypad );
END;

END.
