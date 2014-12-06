[
  Inherit 
    ('SYS$LIBRARY:STARLET','VT100','QIO_WRITE','CLEAR','POSN','GET_POSN','QIO_READ_VARYING','RESET_SCREEN','TRIM','DAYTIME','DEC','GET_JPI','SLEEP'),
  Environment 
    ('TOPTEN.PEN') 
]

MODULE Topten ( infile ,output);
[HIDDEN]
CONST
%include 'sys$library:passtatus.pas' {Status values for PASCAL IO - WWB}

[HIDDEN]
TYPE
  v_array = varying [256] of char;
  u_array = varying [8] of char;
  s_array = varying [12] of char;
  everything = Record
                 tot_games : integer;
                 month     : integer;
                 m_user    : array [1..12] of u_array;
                 m_name    : array [1..12] of s_array;
                 m_score   : array [1..12] of integer;
                 user      : array [0..19] of u_array;
                 name      : array [0..19] of s_array;
                 score     : array [0..19] of integer;
                 games     : array [0..19] of integer;
               End;
[HIDDEN]
VAR
  infile  : File of everything;
  filerec : everything;

[GLOBAL]
PROCEDURE  top_ten ( this_score : integer );
VAR
  last_score : integer;
  directory : v_array;
  gamename  : v_array;
  username  : v_array;
  year_now  : integer;
  month_now : integer;
  i,j,k, me : integer;
  old_name  : s_array;
  old_games : integer;

    PROCEDURE  Get_Image_dir_and_ACN_name ( VAR directory, gamename : v_array );
    VAR
      the_name : v_array;
    BEGIN
      the_name := Get_jpi(jpi$_imagname,100);
      WHILE ( index(the_name,'][') <> 0 ) do
        BEGIN
          the_name := substr(the_name,1,index(the_name,'][')-1) + substr(the_name,index(the_name,'][')+2,length(the_name)-(index(the_name,'][')+2));
        END;
      directory := substr(the_name,1,index(the_name,']'));
      the_name := substr(the_name,index(the_name,']')+1,the_name.length-index(the_name,']'));
      gamename := substr(the_name,1,index(the_name,'.')-1);
    END;

    FUNCTION  month_of_year ( i : integer ) : v_array;
    BEGIN
      month_of_year := substr('JanFebMarAprMayJunJulAugSepOctNovDec',(i*3)-2,3);
    END;

BEGIN
  reset_screen;
  clear;
  posn (1,1);

  username := Get_jpi(jpi$_username,8);
  Get_Date_time; 
  year_now := date_time[1];
  month_now := date_time[2];

  Get_Image_dir_and_ACN_name (directory,gamename);

  REPEAT
    OPEN (infile,directory+gamename+'.ACN',old,,direct,sharing:=readwrite,
      error:=continue);
    CASE status(infile) of
      PAS$K_SUCCESS : ;
      PAS$K_FILNOTFOU : BEGIN
            qio_writeln ('Can''t find file '+gamename+'.ACN Creating New File ...');
            OPEN(infile,directory+gamename+'.ACN',new,,direct,
              sharing:=readwrite,error:=continue);
            IF status(infile) <> 0 THEN
              BEGIN
                qio_writeln ('Can''t Create '+gamename+'.ACN Insufficient priviledge.');
                $exit(1);
              END;
            rewrite (infile);

            infile^.tot_games := 0;
            infile^.month     := month_now;
            FOR i := 1 to 12 do
              infile^.m_user[i] := '        ';
            FOR i := 1 to 12 do
              infile^.m_name[i] := '            ';
            FOR i := 1 to 12 do
              infile^.m_score[i] := -maxint-1;
            FOR i := 0 to 19 do
              infile^.user[i] := '        ';
            FOR i := 0 to 19 do
              infile^.name[i] := '            ';
            FOR i := 0 to 19 do
              infile^.score[i] := -maxint-1;
            infile^.games := zero;

            put (infile);
            reset (infile);
          END;
      PAS$K_ACCMETINC,
      PAS$K_RECLENINC : BEGIN
            qio_writeln ('Error in file format of '+gamename+'.ACN');
            $exit(1);
          END;
      OTHERWISE
          BEGIN
            sleep (1);
            clear;
            Posn(1,1);
            qio_writeln (trim(Username)+', Please Wait ...');
          END;
    END;
  UNTIL status(infile)=PAS$K_SUCCESS;

  REPEAT
    reset (infile,error:=continue);
  UNTIL (status(infile)<>PAS$K_FAIGETLOC);

{ high score for the month }

  infile^.tot_games := infile^.tot_games + 1;
  IF ( infile^.month <> month_now ) and ( infile^.month <> 0 ) then
    BEGIN
      infile^.m_user[infile^.month] := infile^.user[0];
      infile^.m_name[infile^.month] := infile^.name[0];
      infile^.m_score[infile^.month] := infile^.score[0];
      FOR i := 0 to 19 do
        infile^.user[i] := '        ';
      FOR i := 0 to 19 do
        infile^.name[i] := '            ';
      FOR i := 0 to 19 do
        infile^.score[i] := -maxint-1;
      infile^.games := zero;
    END;
  infile^.month := month_now;

{ insert/find user somewhere }

  i := 0;
  WHILE ( i<19 ) and ( infile^.user[i]<>username ) do
    i := i + 1;
  IF ( infile^.user[i]<>username ) then
    BEGIN
      infile^.user[i] := username;
      infile^.name[i] := '            ';
      infile^.score[i] := -maxint-1;
      infile^.games[i] := 0;
    END;
  last_score := infile^.score[i];
  infile^.games[i] := infile^.games[i] + 1;
  me := i;

{ move user up }

  IF this_score > infile^.score[i] then
    BEGIN
      j := 0;
      WHILE this_score <= infile^.score[j] do
        j := j + 1;
      IF j < i then
        BEGIN
          old_name := infile^.name[i];
          old_games := infile^.games[i];
          FOR k := i downto j+1 do
            BEGIN
              infile^.user[k] := infile^.user[k-1];
              infile^.name[k] := infile^.name[k-1];
              infile^.score[k] := infile^.score[k-1];
              infile^.games[k] := infile^.games[k-1];
            END;
          infile^.user[j] := username;
          infile^.name[j] := old_name;
          infile^.games[j] := old_games;
          me := j;
        END;
      infile^.score[me] := this_score;
    END;

{ display this }

  clear;
  posn (1,1);
  qio_write ('Immortal Players For '+dec(year_now-1)+' - '+dec(year_now)+'               Top Players For '+month_of_year(month_now)+' ');
  qio_writeln (VT100_bright+dec(infile^.tot_games,,6)+' Games'+VT100_normal);
  qio_writeln (VT100_graphics_on+'oooooooooooooooooooooooooooooooo               ooooooooooooooooooo'+VT100_graphics_off);
  qio_writeln ('Month  Username  Name         Score     Num Username  Name         Score   Games');
  qio_writeln;

  For i := month_now-1 downto 1 do
    IF ( infile^.m_score[i] <> -maxint-1 ) then
      qio_writeln (' '+month_of_year(i)+'   '+infile^.m_user[i]+'  '+infile^.m_name[i]+' '+dec(infile^.m_score[i],,5));
  For i := 12 downto month_now do
    IF ( infile^.m_score[i] <> -maxint-1 ) then
      qio_writeln (' '+month_of_year(i)+'   '+infile^.m_user[i]+'  '+infile^.m_name[i]+' '+dec(infile^.m_score[i],,5));

  For i := 0 to 11 do
    IF ( infile^.score[i] <> -maxint-1 ) then
      qio_write (get_posn(41,5+i)+dec(i+1,,3)+' '+infile^.user[i]+'  '+infile^.name[i]+' '+dec(infile^.score[i],,5)+'   '+dec(infile^.games[i],,3));

  posn (5,18);
  qio_write ('You Are Seated At '+dec(me+1)+' In '+gamename);
  IF ( last_score = -maxint-1 ) AND ( me < 12 ) THEN
    BEGIN
        { on board first game }
      posn (5,20);
      qio_writeln (VT100_bright+'Enter Your Name [ Return to Leave ]'+VT100_normal);
      posn (42,18);
      qio_writeln ('Current Score '+dec(this_score));
    END
  ELSE
  IF ( last_score = -maxint-1 ) THEN
    BEGIN
        { first game not on board }
      posn (42,18);
      qio_writeln ('Current Score '+dec(this_score));
    END
  ELSE
  IF ( last_score < this_score ) and ( me < 12 ) THEN
    BEGIN
        { on board and doing better }
      posn (42,18);
      qio_write ('Previous Score '+dec(last_score));
      posn (5,20);
      qio_writeln (VT100_bright+'Enter Your Name [ Return to Leave ]'+VT100_normal);
      posn (42,20);
      qio_writeln ('Current Score '+dec(this_score));
    END
  ELSE
    BEGIN
        { doing worse on or off board or better but still off board }
      posn (42,18);
      qio_writeln ('Previous Score '+dec(last_score));
      posn (42,20);
      qio_writeln ('Current Score '+dec(this_score));
    END;

  IF (( last_score < this_score ) or ( last_score = -maxint-1 )) 
        AND ( me < 12 ) THEN
    BEGIN
      posn (55,5+me);
      infile^.name[me] := QIO_read_varying (12);
      infile^.name[me].length := 12;
    END;

  filerec := infile^;
  REPEAT
    rewrite (infile,error:=continue);
  until (status(infile)<>PAS$K_ERRDURREW);
  infile^ := filerec;
  REPEAT
    Put (infile);
  until (status(infile)=PAS$K_SUCCESS) or (status(infile)=PAS$K_EOF);
  Close (infile);
  posn (1,23);
END;

END.
