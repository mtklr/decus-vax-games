{Check userid - allow only certain users to access wizard mode - MWK,Opusii}
[psect(id$code)] function valid_user:boolean;

    type
        word    = 0..65535;
        recj    = record
                        unameinfo       : packed record
                                unamelen        : word;
                                jpi$_username   : word;
                        END;
                        ptr_uname       : ^usernam;
                        ptr_unamelen    : ^integer;
                        ENDlist         : integer
                  END;
        usernam         = packed array [1..12] of char;
 
    var
        mwkusr, curusr: usernam;
        file1 : text;  
 
        { function returns the players USERNAME                 -JWT-   }
    function mwk_get_username : usernam;
      var
        user            : usernam;
        icode           : integer;
        jpirec          : recj;
 
        { calls GETJPI routine to return the USERNAME           -JWT-   }
      function sys$getjpi       (%immed p1      : integer;
                                %immed  p2      : integer;
                                %immed  p3      : integer;
                                var     itmlst  : recj;
                                %immed  p4      : integer;
                                %immed  p5      : integer;
                                %immed  p6      : integer) : integer;
        external;
 
      BEGIN
        with jpirec do
          BEGIN
            unameinfo.unamelen          := 12;
            unameinfo.jpi$_username     := %x202;
            new (ptr_uname);
            ptr_uname^                  := '            ';
            new (ptr_unamelen);
            ptr_unamelen^               := 0;
            ENDlist                     := 0
          END;
        icode := SYS$GETJPI (0,0,0,jpirec,0,0,0);
        if not odd(icode) then
          BEGIN
            writeln('Error in GETJPI process');
            halt
          END
        else
          mwk_get_username := jpirec.ptr_uname^
        END;

BEGIN                                                         {-NBT-}
  valid_user := false; 
  mwkusr:=mwk_get_username;
  priv_switch(1);
  open(file1,file_name:=MORIA_WIZ, organization:=sequential,history:=old,
       sharing:=readwrite,error:=continue);
  if (status(file1) = 0) then
          BEGIN
                reset(file1);
                while not(eof(file1)) do begin
                  readln(file1,curusr,error:=continue);
                  if mwkusr = curusr then valid_user := true;
                end;
                close(file1,error:=continue);
          END
        else
         BEGIN
         prt ('ERROR: A severe error occurred in IDSection. Please notify the DM...',1,1);
         Pause(24);
         End;
  END;

[psect(id$code)] function loseruser:boolean;

    type
        word    = 0..65535;
        recj    = record
                        unameinfo       : packed record
                                unamelen        : word;
                                jpi$_username   : word;
                        END;
                        ptr_uname       : ^usernam;
                        ptr_unamelen    : ^integer;
                        ENDlist         : integer
                  END;
        usernam         = packed array [1..12] of char;
 
    var
        mwkusr, curusr: usernam;
        file1 : text;  

        { function returns the players USERNAME                 -JWT-   }
    function mwk_get_username : usernam;
      var
        user            : usernam;
        icode           : integer;
        jpirec          : recj;
 
        { calls GETJPI routine to return the USERNAME           -JWT-   }
      function sys$getjpi       (%immed p1      : integer;
                                %immed  p2      : integer;
                                %immed  p3      : integer;
                                var     itmlst  : recj;
                                %immed  p4      : integer;
                                %immed  p5      : integer;
                                %immed  p6      : integer) : integer;
        external;
 
      BEGIN
        with jpirec do
          BEGIN
            unameinfo.unamelen          := 12;
            unameinfo.jpi$_username     := %x202;
            new (ptr_uname);
            ptr_uname^                  := '            ';
            new (ptr_unamelen);
            ptr_unamelen^               := 0;
            ENDlist                     := 0
          END;
        icode := SYS$GETJPI (0,0,0,jpirec,0,0,0);
        if not odd(icode) then
          BEGIN
            writeln('Error in GETJPI process');
            halt
          END
        else
          mwk_get_username := jpirec.ptr_uname^
        END;

BEGIN                                                         {-NBT-}
  loseruser := false; 
  mwkusr:=mwk_get_username;
  priv_switch(1);
  open(file1,file_name:=MORIA_LOS, organization:=sequential,history:=old,
       sharing:=readwrite,error:=continue);
  if (status(file1) = 0) then
          BEGIN
                reset(file1);
                while not(eof(file1)) do begin
                  readln(file1,curusr,error:=continue);
                  if mwkusr = curusr then loseruser := true;
                end;
                close(file1,error:=continue);
          END
        else
         BEGIN
         prt ('ERROR: A severe error occurred in IDSection. Please notify the DM...',1,1);
         Pause(24);
         End;
  END;
