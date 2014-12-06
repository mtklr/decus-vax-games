[
  Inherit 
    ('VT100','QIO_WRITE','CASE_CONVERT','ERROR'),
  Environment 
    ('GET_CLEAR.PEN') 
]

MODULE GET_CLEAR;

[HIDDEN]
TYPE
  v_array = varying [256] of char;

[GLOBAL]
FUNCTION  Get_Clear ( portiontype : v_array := 'SCREEN';
                   cleartype   : v_array := 'WHOLETHING' ) : v_array;
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
    ERROR ('%INTERACT-GET_CLEAR, Cleartype /'+cleartype+'/ Unknown.');

  portiontype := upper_string(portiontype);
  IF ( portiontype = 'SCREEN' ) then
    get_clear := outline + 'J'
  ELSE
  IF ( portiontype = 'LINE' ) then
    get_clear := outline + 'K'
  ELSE
    error ('%INTERACT-GET_CLEAR, Portiontype /'+portiontype+'/ unknown.');
END;

END.
