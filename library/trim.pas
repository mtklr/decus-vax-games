[
  Inherit
    ('SYS$LIBRARY:STARLET','SYS$LIBRARY:PASCAL$LIB_ROUTINES'),
  Environment
    ('TRIM.PEN')
]

MODULE TRIM;

[HIDDEN]TYPE
  $UWORD = [WORD] 0..65535;
  v_array = varying [256] of char;

[ASYNCHRONOUS, EXTERNAL(STR$TRIM)]
FUNCTION  $Trim
  ( VAR destination_str : [CLASS_S] PACKED ARRAY [$L1 .. $U1 : INTEGER] OF CHAR;
        source_str      : [CLASS_S] PACKED ARRAY [$L2 .. $U2 : INTEGER] OF CHAR;
    VAR return_length   : $UWORD
  ) : integer;
Extern;

[GLOBAL]
FUNCTION  Trim ( text : v_array ) : v_array;
VAR
  ret_status : integer;
BEGIN
  ret_status := $trim (text.body,text,text.length);
  IF not odd(ret_status) then
    LIB$SIGNAL(ret_status);
  trim := text;
END;

END.
