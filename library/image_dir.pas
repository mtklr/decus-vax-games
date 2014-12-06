[
  Inherit
    ('SYS$LIBRARY:STARLET','SYS$LIBRARY:PASCAL$LIB_ROUTINES','GET_JPI'),
  Environment
    ('IMAGE_DIR.PEN')
]

MODULE Image_dir;

[HIDDEN]TYPE
  $UWORD = [WORD] 0..65535;
  v_array = varying [256] of char;

[HIDDEN]VAR
  image_dir_done : boolean;


[GLOBAL]
PROCEDURE  Image_dir;
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
  the_name : v_array;
  name_str : packed array [1..256] of char;
  ret_status : integer;
BEGIN
  IF not image_dir_done then
    BEGIN
      image_dir_done := true;
      the_name := Get_jpi(jpi$_imagname,100);
    
      WHILE ( index(the_name,'][') <> 0 ) do
        BEGIN
          the_name := substr(the_name,1,index(the_name,'][')-1) + substr(the_name,index(the_name,'][')+2,length(the_name)-(index(the_name,'][')+2));
        END;
    
      the_name := substr(the_name,1,index(the_name,']'));
      name_str := the_name;
    
      WITH itemlist do
       BEGIN
         WITH item[1] do
           BEGIN
             Bufsize := length(the_name);
             Code := lnm$_string;
             Bufadr := iaddress(name_str);
             Lenadr := 0
           END;
         No_more := 0
       END;

      ret_status := $Crelnm (tabnam:='LNM$PROCESS_TABLE',
                             lognam:='IMAGE_DIR',
                             itmlst:=itemlist );

      IF not odd(ret_status) then
        LIB$SIGNAL(ret_status);
    END;
END;


END.
