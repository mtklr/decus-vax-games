[
  Environment
    ('EXTRACT.PEN')
]

MODULE EXTRACT;

[HIDDEN]TYPE
  v_array = varying [256] of char;

[GLOBAL]
FUNCTION  Extract ( str   : v_array;
                    start : integer ) : v_array;
BEGIN
  Extract := substr(str,start,str.length-start+1);
END;

END.
