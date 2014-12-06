[
  Inherit 
    ('VT100.PEN'),
  Environment
    ('ERROR.PEN')
]

MODULE ERROR ( output );

[HIDDEN]
TYPE
  v_array = varying [256] of char;

[GLOBAL]
PROCEDURE  ERROR ( text : v_array );
BEGIN
  writeln ( VT100 + VT100_graphics_off + VT100_normal + VT100_normal_scroll + VT100_no_application_keypad + VT100_ESC + '[J' );
  writeln (text);
  HALT;
END;

END.
