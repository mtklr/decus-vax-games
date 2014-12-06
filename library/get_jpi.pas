[
  Inherit
    ('SYS$LIBRARY:STARLET','SYS$LIBRARY:PASCAL$LIB_ROUTINES'),
  Environment
    ('GET_JPI.PEN')
]

MODULE Get_jpi;

[HIDDEN]
TYPE
  $UWORD = [WORD] 0..65535;
  v_array = varying [256] of char;

[GLOBAL]
FUNCTION  Get_jpi ( jpicode , retlen : integer ) : v_array;
VAR
  itemlist    : record
                  item : array [1..1] of 
                    record
                      bufsize : $uword;
                      code    : $uword;
                      bufadr  : integer;
                      lenadr  : integer
                    end;
                  no_more : integer;
                end;
  name : packed array [1..256] of char;
  retname : v_array;
  ret_status : integer;
BEGIN
  WITH itemlist do
   BEGIN
     WITH item[1] do
       BEGIN
         Bufsize := retlen;
         Code := jpicode;
         Bufadr := iaddress(name);
         Lenadr := 0
       END;
     No_more := 0
   END;
  ret_status := $Getjpiw(itmlst := itemlist);
  IF not odd(ret_status) then
    LIB$SIGNAL(ret_status);
  retname := name;
  retname.length := retlen;
  get_jpi := retname;
END;
END.
