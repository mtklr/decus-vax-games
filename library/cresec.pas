[
  Inherit
    ('SYS$LIBRARY:STARLET','SYS$LIBRARY:PASCAL$LIB_ROUTINES'),
  Environment
    ('CRESEC.PEN')
]

MODULE Cresec;

[HIDDEN]TYPE
  v_array = varying [256] of char;
  $DEFTYP = [UNSAFE] INTEGER;
  $DEFPTR = [UNSAFE] ^$DEFTYP;


[GLOBAL]
PROCEDURE  Create_global_section
      (
        Section_name : v_array;
        Section_size : integer;
        var Section_ptr : $defptr;
        var Section_end : [TRUNCATE] $defptr
      );
CONST
  Pagesize = 512;
VAR
  ret_status : integer;
  Pagecount : integer;
  Maprange : Record
               First : [unsafe] integer;
               Last  : [unsafe] integer;
             End;
BEGIN
  Pagecount := (section_size + pagesize - 1) div pagesize;
  WITH maprange do
    BEGIN
      First := 0;
      Last := %x3fffffff;
    END;
  Ret_Status := $Crmpsc(gsdnam := section_name, 
                        pagcnt := pagecount,
                        flags  := sec$m_gbl+sec$m_wrt+sec$m_dzro+
                                  sec$m_expreg+sec$m_pagfil,
                        inadr  := maprange, 
                        retadr := maprange);
  If not odd(ret_status) then
    LIB$SIGNAL(ret_status);
  Section_ptr := maprange.first;
  IF Present(Section_end) then
    section_end := maprange.last;
END;

[GLOBAL]
PROCEDURE  Delete_global_section ( Section_ptr, Section_end : $defptr );
VAR
  ret_status : integer;
  Maprange : Record
               First : [unsafe] integer;
               Last  : [unsafe] integer;
             End;
BEGIN
  WITH maprange do
    BEGIN
      First := section_ptr;
      Last := section_end;
    END;
  Ret_Status := $Deltva (maprange);
  If not odd(ret_status) then
    LIB$SIGNAL(ret_status);
END;

END.
