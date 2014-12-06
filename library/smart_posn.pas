[
  Inherit
    ('VT100','QIO_WRITE','POSN'),
  Environment
    ('SMART_POSN.PEN')
]

MODULE SMART_POSN;

[HIDDEN]
TYPE
  v_array = varying [256] of char;

[HIDDEN]
VAR
   Smart_Cursor     : Record
                        C_x : integer;
                        C_y : integer;
                      End;

[GLOBAL]
PROCEDURE  Smart_Posn ( to_x, to_y : integer; VAR init : boolean );
VAR
  smart_sequence : [STATIC] Array [-3..2,-2..2] of v_array
    := ({x=-3} (VT100_ESC+'[2A'+VT100_bs+VT100_bs+VT100_bs,
                VT100_ESC+'M'+VT100_bs+VT100_bs+VT100_bs,
                VT100_bs+VT100_bs+VT100_bs,
                VT100_LF+VT100_bs+VT100_bs+VT100_bs,
                VT100_LF+VT100_LF+VT100_bs+VT100_bs+VT100_bs),
        {x=-2} (VT100_ESC+'[2A'+VT100_bs+VT100_bs,
                VT100_ESC+'M'+VT100_bs+VT100_bs,
                VT100_bs+VT100_bs,
                VT100_LF+VT100_bs+VT100_bs,
                VT100_LF+VT100_LF+VT100_bs+VT100_bs),
        {x=-1} (VT100_ESC+'[2A'+VT100_bs,
                VT100_ESC+'M'+VT100_bs,
                VT100_bs,
                VT100_LF+VT100_bs,
                VT100_LF+VT100_LF+VT100_bs),
        {x= 0} (VT100_ESC+'[2A',
                VT100_ESC+'M',
                '',
                VT100_LF,
                VT100_LF+VT100_LF),
        {x=+1} (VT100_ESC+'[2A'+VT100_ESC+'[C',
                VT100_ESC+'M'+VT100_ESC+'[C',
                VT100_ESC+'[C',
                VT100_LF+VT100_ESC+'[C',
                VT100_LF+VT100_LF+VT100_ESC+'[C'),
        {x=+2} (VT100_ESC+'[2A'+VT100_ESC+'[2C',
                VT100_ESC+'M'+VT100_ESC+'[2C',
                VT100_ESC+'[2C',
                VT100_LF+VT100_ESC+'[2C',
                VT100_LF+VT100_LF+VT100_ESC+'[2C'));
  dx, dy : integer;
BEGIN
  IF clear_interlocked(init) then
    posn (to_x,to_y)
  ELSE
    BEGIN
      dx := to_x - Smart_Cursor.c_x;
      dy := to_y - Smart_Cursor.c_y;
      IF ( dx >= -3 ) and ( dx <= 2 ) and ( abs(dy) <= 2 ) then
        qio_write (smart_sequence[dx,dy])
      ELSE
        posn (to_x,to_y);
    END;
  Smart_Cursor.C_x := to_x;
  Smart_Cursor.C_y := to_y;
END;


[GLOBAL]
PROCEDURE  Smart_qio_write ( str : v_array );
BEGIN
  Smart_Cursor.C_x := min(80,Smart_Cursor.C_x + str.length);
  qio_write (str);
END;


[GLOBAL]
PROCEDURE  Smart_shift ( i : integer );
BEGIN
  Smart_Cursor.C_x := min(80,Smart_Cursor.C_x + i);
END;
                
END.
