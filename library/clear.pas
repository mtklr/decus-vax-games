[
  Inherit 
    ('VT100','QIO_WRITE','CASE_CONVERT','ERROR'),
  Environment 
    ('CLEAR.PEN') 
]

MODULE CLEAR;

[HIDDEN]
TYPE
  v_array = varying [256] of char;

[GLOBAL]
PROCEDURE  Clear ( portiontype : v_array := 'SCREEN';
                   cleartype   : v_array := 'WHOLETHING' );
VAR
  outline : v_array;
BEGIN
  outline := VT100_ESC + '[';

  cleartype := upper_string(cleartype);
  IF ( cleartype = 'WHOLETHING' ) then
    outline := outline + '2'
  ELSE
  IF ( cleartype = 'TO_START' ) then
    outline := outline + '1'
  ELSE
  IF ( cleartype <> 'TO_END' ) then
    ERROR ('%INTERACT-CLEAR, Cleartype /'+cleartype+'/ Unknown.');

  portiontype := upper_string(portiontype);
  IF ( portiontype = 'SCREEN' ) then
    outline := outline + 'J'
  ELSE
  IF ( portiontype = 'LINE' ) then
    outline := outline + 'K'
  ELSE
    error ('%INTERACT-CLEAR, Portiontype /'+portiontype+'/ unknown.');

  qio_write (outline);
END;

END.
