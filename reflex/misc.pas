(****************** This file is a collection of routines from  **************
 ******************    the INTERACT Pascal Games Library...     **************
 *****************                                               *************
 ****************  (c) Waikato University, Hamilton, NEW ZEALAND  ************
 *
 *  The INTERACT Library was written by Paul Denize   PDENIZE@WAIKATO.AC.NZ 
 *
 *  Contributing authors: Rex Croft                   CCC_REX@WAIKATO.AC.NZ
 *                        Lawrence D'Oliviero         LDO@WAIKATO.AC.NZ
 *                        Chris Guthrey               CGUTHREY@WAIKATO.AC.NZ
 *
 *  Several improvements to the TOPTEN Score Table System 
 *  contributed by:
 *                        Bill Brennessel      MASMUMMY@ubvmsc.cc.buffalo.edu
 *
 * You are granted permission to use the routines in this file or any other
 * routines from any INTERACT Library File on condition that this header is
 * retained and credit given where due.
 *
 * Note of course that there is no warranty of any kind whatsoever.
 *
 *)
[
  Inherit(
    (*'GEN$:[PAS]VAXTYPES', *)
    'SYS$LIBRARY:PASCAL$LIB_ROUTINES',
    'SYS$LIBRARY:STARLET' 
    (* 'GEN$:[PAS]VMSRTL' *) 
  ),
  Environment
    ('MISC.PEN')
]
MODULE MISC( OUTPUT );

(*****************************************************************
 ** THIS FILE IS MERELY A CONCISE COMPILATION OF ROUTINES TAKEN **
 ** FROM A NUMBER OF INTERACT GAMES LIBRARY SOURCE FILES. ONLY  **
 ** THE ROUTINES NEEDED BY THIS PARTICULAR GAME ARE INCLUDED.   **
 *****************************************************************)

%INCLUDE 'VT100_ESC_SEQS.PAS'

TYPE
      { signed integer types }
	$byte = [BYTE] -128..127;
	$word = [WORD] -32768..32767;
	$quad = [QUAD,UNSAFE] RECORD
		l0:UNSIGNED; l1:INTEGER; END;
	$octa = [OCTA,UNSAFE] RECORD
		l0,l1,l2:UNSIGNED; l3:INTEGER; END;

      { unsigned integer types }
	$ubyte = [BYTE] 0..255;
	$uword = [WORD] 0..65535;
	$uquad = [QUAD,UNSAFE] RECORD
		l0,l1:UNSIGNED; END;
	$uocta = [OCTA,UNSAFE] RECORD
		l0,l1,l2,l3:UNSIGNED; END;

      { miscellaneous types }
	$packed_dec = [BIT(4),UNSAFE] 0..15;
	$deftyp = [UNSAFE] INTEGER;
	$defptr = [UNSAFE] ^$DEFTYP;


[HIDDEN]
TYPE
  v_array = varying [256] of char;

[GLOBAL]
FUNCTION System_Call ( ret_status : integer ) : Boolean;
BEGIN
  IF not odd(ret_status) then
    LIB$SIGNAL(ret_status);
  System_Call := odd(ret_status);
END;

[GLOBAL]
PROCEDURE  TERMINATE ( code : integer := 1 );
BEGIN
  $EXIT ( code );
END;

[GLOBAL]
PROCEDURE  KILL ( PID : [TRUNCATE] UNSIGNED );
BEGIN
  IF PRESENT(PID) then
    System_Call ($DELPRC(pidadr:=PID))
  ELSE
    System_Call ($DELPRC);
END;

VAR
  terminal_input_channel    : $UWORD;
  terminal_output_channel   : $UWORD;
  channel_initialized : Boolean := False;


[GLOBAL]
PROCEDURE  initialize_channel( input_device : v_array := 'TT:';
                               output_device : v_array := 'TT:' );
BEGIN
  IF not channel_initialized then
    BEGIN  
      System_Call ($assign ( chan := terminal_output_channel , devnam := output_device));
      IF input_device = output_device THEN     {are in and out devices same?}
        terminal_input_channel := terminal_output_channel {same channel}
      ELSE
        System_Call ($assign ( chan := terminal_input_channel ,devnam := input_device ));
    END;
END;

[GLOBAL]
FUNCTION  QIO_1_char_now : char;
VAR
  buffer : packed array [1..1] of char;
BEGIN
  buffer[1] := chr(-1);
  System_Call ($qiow ( chan:= terminal_input_channel,
                        func:= io$_readvblk+io$m_timed+io$m_noecho+io$m_nofiltr,
                        p1:= buffer,
                        p2:= 1, { bufferlength }
                        p3:= 0 ));
   Qio_1_char_now := buffer[1];
END;


[GLOBAL]
FUNCTION  QIO_readln ( characters : integer ) : v_array;
TYPE
  iosb_type = [QUAD] Record
                       Status : $uword;
                       Nrbytes : $uword;
                       Terminator : char;
                       Reserved : $ubyte;
                       Terminator_length : $ubyte;
                       Cursor_offset : $ubyte
                     End;
VAR
  temp : v_array;
  Read_iosb : iosb_type;
BEGIN
  system_Call ( $qiow ( chan:= terminal_input_channel,
                        func:= io$m_timed+io$_readvblk+io$m_noecho+io$m_nofiltr+io$m_escape,
                        iosb:= read_iosb,
                          p1:= temp.body,
                          p2:= characters,
                          p3:= 0 ));
   temp.length := ( read_iosb.Nrbytes );
   qio_readln := temp;
END;


[GLOBAL]
FUNCTION  QIO_1_char : char;
VAR
  buffer : packed array [1..1] of char;
BEGIN
  System_Call ($qiow ( chan:= terminal_input_channel,
                        func:= io$_readvblk+io$m_noecho+io$m_nofiltr,
                          p1:= buffer,
                          p2:= 1 ));
  Qio_1_char := buffer[1];
END;


[GLOBAL]
PROCEDURE  QIO_purge;
BEGIN
  System_Call ($qiow ( chan:= terminal_input_channel,
                        func:= io$_readvblk+io$m_purge ));
END;


[GLOBAL]
FUNCTION  QIO_1_char_timed ( delay : integer ) : char;
VAR
  buffer : packed array [1..1] of char;
BEGIN
  buffer[1] := chr(255);
  System_Call ($qiow ( chan:= terminal_input_channel,
                        func:=io$m_timed+io$_readvblk+io$m_noecho+io$m_nofiltr+io$m_escape,
                          p1:= buffer,
                          p2:= 1,
                          p3:= delay ));
  Qio_1_char_timed := buffer[1];
END;

[GLOBAL]
PROCEDURE  QIO_write ( text : v_array );
BEGIN
  System_Call ($qiow (chan:= terminal_output_channel,
                       func:= io$_writevblk,
                         p1:= text.body,
                         p2:= text.length ));
END;


[GLOBAL]
PROCEDURE  QIO_writeln ( text : [TRUNCATE] v_array );
VAR
  outline     : v_array;
BEGIN
  IF present(text) then
    BEGIN
      outline := text + VT100_cr + VT100_lf;
      System_Call ($qiow (chan:= terminal_output_channel,
                           func:= io$_writevblk,
                             p1:= outline.body,
                             p2:= outline.length  ));
    END
  ELSE
    BEGIN
      outline := VT100_cr + VT100_lf;
      System_Call ($qiow (chan:= terminal_output_channel,
                           func:= io$_writevblk,
                             p1:= outline.body,
                             p2:= outline.length  ));
    END;
END;

[GLOBAL]
PROCEDURE  Sleep ( sec : integer := 0; frac : [TRUNCATE] real );
VAR
  Hundredths : integer;
  delta_wake_time : $quad;
BEGIN
  Hundredths := sec*100;
  IF PRESENT(frac) then
    Hundredths := Hundredths + round(frac*100);
  IF ( hundredths > 0 ) then
    BEGIN
      System_Call (LIB$EMUL (Hundredths, -100000, 0, delta_wake_time));
      IF System_Call ($Schdwk ( daytim := delta_wake_time )) then
        System_Call ($Hiber);
    END;
END;

TYPE
  portiontype = (The_Screen,The_Line);
  cleartype   = (Wholething, To_Start, To_End);
  
[HIDDEN]
VAR
  desblk : Record
             findlink   : integer;
             proc       : integer;
             arglist    : array [0..1] of integer;
             exitreason : integer;
           End;


[HIDDEN]
PROCEDURE  ctrlc_ast;
BEGIN
  $exit ( code := ss$_clifrcext );
END;

[GLOBAL]
PROCEDURE  Force;
BEGIN
  System_Call ($qiow ( chan := terminal_output_channel,
                        func := io$_setmode + io$m_ctrlcast,
                        p1   := %immed iaddress (ctrlc_ast)));
END;


[GLOBAL]
PROCEDURE Setup_handler ( handler_address : integer );
BEGIN
  WITH desblk do
    BEGIN
      proc       := handler_address;
      arglist[0] := 1;
      arglist[1] := iaddress(exitreason);
    END;

  System_Call ($DCLEXH (desblk));
END; 


[GLOBAL]
PROCEDURE  No_handler;
BEGIN
  System_Call ($CANEXH (desblk));
END;


[GLOBAL]
FUNCTION  Upper_case ( c : char ) : char;
BEGIN
  IF ( c in ['a'..'z'] ) then
    c := chr ( ord(c) - ord('a') + ord('A') );
  upper_case := c;
END;

[GLOBAL]
PROCEDURE  Clear ( portion : portiontype := The_Screen;
                   clear   : cleartype   := Wholething );
VAR
  outline : v_array;
BEGIN
  outline := VT100_ESC + '[';

  IF ( clear = Wholething ) then
    outline := outline + '2'
  ELSE
  IF ( clear = To_Start ) then
    outline := outline + '1';

  IF ( portion = The_Screen ) then
    outline := outline + 'J'
  ELSE
  IF ( portion = The_Line ) then
    outline := outline + 'K';

  qio_write (outline);
END;


[GLOBAL]
PROCEDURE  ERROR ( text : [TRUNCATE] v_array );
BEGIN
  writeln ( VT100 + VT100_graphics_off + VT100_normal + VT100_normal_scroll + VT100_no_application_keypad + VT100_ESC + '[J' );
  IF present(text) then
    writeln (text)
  else
    writeln ('No Message');
  $EXIT;
END;


[GLOBAL]
FUNCTION  Get_Posn ( x , y : integer ) : v_array;
VAR
  outline,sx,sy : v_array;
BEGIN
  outline := VT100_ESC + '[';

  IF ( y > 1 ) then
    BEGIN
      writev (sy,y:1);
      outline := outline + sy;
    END;

  IF ( x > 1 ) then
    BEGIN
      writev (sx,x:1);
      outline := outline + ';' + sx;
    END;

  get_posn := outline + 'H';
END;

[GLOBAL]
PROCEDURE  Posn ( x , y : integer );
BEGIN
  qio_write (get_posn(x,y));
END;


[HIDDEN]
VAR
  seed : integer;
  seed_initialized : boolean;


[GLOBAL]
PROCEDURE  Seed_initialize ( users_seed : [TRUNCATE] integer );
VAR
  time : packed array [0..1] of integer;
BEGIN
  seed_initialized := true;
  IF present(users_seed) then
    seed := users_seed
  ELSE
    BEGIN
      $gettim(time);
      seed := time[0];
    END;
END;


[GLOBAL]
FUNCTION  Random ( ub : integer ) : integer;
{ Produce random integer between 1 & ub inclusive }

        FUNCTION  Mth$Random ( VAR seed : integer ) : real;
          extern;

BEGIN
  If not seed_initialized then
    seed_initialize;
  Random := Trunc (( Mth$Random ( seed ) * ub ) + 1);
END; { Random }


[GLOBAL]
FUNCTION  Rnd ( lb, ub : integer ) : integer;
{ Produce random integer between lb & ub }

        FUNCTION  Mth$Random ( VAR seed : integer ) : real;
          extern;

BEGIN
  If not seed_initialized then
    seed_initialize;
  rnd := Trunc (( Mth$Random ( seed ) * (ub-lb+1) ) + lb );
END; { Random }


[GLOBAL]
FUNCTION  _Dec ( number    : integer;
                pad_char  : char := ' ';
                pad_len   : integer := 0
              ) : v_array;
VAR
  Result : v_array;
BEGIN
  Writev (result,number:0);
  WHILE ( result.length < abs(pad_len) ) do
    IF ( pad_len < 0 ) then
      result := result + pad_char
    ELSE
      result := pad_char + result;
  _dec := result;
END;

[GLOBAL]
FUNCTION  Get_jpi_Str ( jpicode , retlen : integer ) : v_array;
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
  System_Call ($Getjpiw(itmlst := itemlist));
  retname := name;
  retname.length := retlen;
  get_jpi_str := retname;
END;

FUNCTION  Get_jpi_Val ( jpicode : INTEGER ) : UNSIGNED;
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
  resulting_value : UNSIGNED;
  retname : v_array;
BEGIN
  WITH itemlist do
   BEGIN
     WITH item[1] do
       BEGIN
         Bufsize := 4;
         Code := jpicode;
         Bufadr := iaddress(resulting_value);
         Lenadr := 0
       END;
     No_more := 0
   END;
  System_Call ($Getjpiw(itmlst := itemlist));
  get_jpi_val := resulting_value;
END;

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
BEGIN
  IF not image_dir_done then
    BEGIN
      image_dir_done := true;
      the_name := Get_jpi_str(jpi$_imagname,100);
    
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

      System_Call ($Crelnm (tabnam:='LNM$PROCESS_TABLE',
                             lognam:='IMAGE_DIR',
                             itmlst:=itemlist ));
    END;
END;


[GLOBAL]
PROCEDURE  Square ( x1 , y1 , x2 , y2 : integer );
VAR
  i : integer;
  sx : v_array;
  buffer : v_array;
BEGIN
  IF ( x1 > x2 - 1 ) or ( y1 > y2 - 1 ) then
    ERROR ('%INTERACT-SQUARE, Top Corner Bottom Corner Overlap');
  IF ( abs(x2-x1) > 132 ) then
    ERROR ('%INTERACT-SQUARE, Size Error delta x distance too large.');
  IF ( abs(y2-y1) > 24 ) then
    ERROR ('%INTERACT-SQUARE, Size Error delta y distance too large.');

  buffer := get_posn (x1,y1) + VT100_graphics_on + 'l';
  FOR i := x1+1 to x2-1 do
    buffer := buffer + 'q';
  buffer := buffer + 'k';
  qio_write (buffer);
  writev(sx,x2-x1-1:1);
  sx := 'x' + VT100_ESC + '[' + sx + 'C' + 'x';
  FOR i := y1+1 to y2-1 do
    qio_write ( get_posn(x1,i)+ sx );
  buffer := get_posn (x1,y2) + 'm';
  IF ( x1 < x2 - 1 ) then
    FOR i := x1+1 to x2-1 do
      buffer := buffer + 'q';
  buffer := buffer + 'j' + VT100_graphics_off;
  qio_write (buffer);
END;


[GLOBAL]
PROCEDURE  Reset_screen;
BEGIN
  qio_write ( VT100 + VT100_graphics_off + VT100_normal + VT100_normal_scroll + VT100_no_application_keypad );
END;

[HIDDEN]
VAR
  ingraphedt     : text;

[GLOBAL]
FUNCTION Show_graphedt ( filename : v_array; wait : boolean := true ) : CHAR;
(* 
  IF wait is true then the character that is pressed is returned, otherwise
   chr(255) is returned
*)
VAR
  line : v_array;
  rep : char := chr(255);
  ret_val : char;
BEGIN
  IF not image_dir_done then
    Image_dir;
  IF ( wait ) then
    rep := qio_1_char_now;
  OPEN (ingraphedt,'image_dir:'+filename,history:=readonly,error:=continue);
  IF status(ingraphedt) = 0 then
    BEGIN
      reset (ingraphedt);
      WHILE not eof(ingraphedt) and (( rep = chr(-1)) or ( not wait )) do
        BEGIN
          IF wait then
            rep := qio_1_char_now;
          readln (ingraphedt,line);
          qio_writeln(line);
        END;
      close (ingraphedt);
      posn (1,1);
      IF wait and ( rep = chr(-1) ) then
        rep := qio_1_char;
    END
  ELSE
    BEGIN
      clear;
      posn (18,10);
      qio_write ('couldn''t find filename .... '+filename);
      posn (28,20);
      qio_write (VT100_Bright+'Press  <'+VT100_Flash+'Return'+VT100_normal+VT100_bright+'>'+VT100_normal);
      posn (1,1);
      IF ( rep  = chr(-1) ) then
        rep := qio_1_char;
    END;
  reset_screen;
  Show_GraphEdt := rep;
END;

[GLOBAL]
FUNCTION  Full_char ( character : char ) : v_array;
VAR
  c : integer;
BEGIN
  c := ord(character);
  IF ( c in [0..31,127] ) then
    full_char := VT100_inverse + chr(64+c) + VT100_normal
  ELSE
  IF ( c < 128 ) then
    full_char := character
  ELSE
  IF ( (c-128) in [0..31,127] ) then
    full_char := VT100_inverse + VT100_bright + chr(c-64) + VT100_normal
  ELSE
    full_char := VT100_bright + character;
END;


[Global]
PROCEDURE  Formated_read
 (VAR return_value   : v_array;
      picture_clause : v_array;
      x_posn         : integer;
      y_posn         : integer;
      default_value  : v_array := '';
      field_full_terminate : boolean := false;
      begin_brace    : v_array := '';
      end_brace      : v_array := ''
 );
VAR
  i : integer;
  ch : char;
  outline : v_array;


    PROCEDURE  Go_left;
    BEGIN
      IF ( i <> 1 ) then
        BEGIN
          REPEAT
            i := i - 1;
          UNTIL ( i = 1 ) or ( picture_clause[i] in ['9','X'] );
          IF not ( picture_clause[i] in ['9','X'] ) then
            BEGIN
              WHILE not ( picture_clause[i] in ['9','X'] ) do
                i := i + 1;
            END;
        END;
    END;


    PROCEDURE  Go_right;
    BEGIN
      IF ( i <> length(picture_clause) ) then
        BEGIN
          REPEAT
            i := i + 1;
          UNTIL ( i = length(picture_clause) ) or ( picture_clause[i] in ['9','X'] );
          IF not ( picture_clause[i] in ['9','X'] ) then
            BEGIN
              WHILE not ( picture_clause[i] in ['9','X'] ) do
                i := i - 1;
            END;
        END;
    END;


    PROCEDURE  Escape_sequence;
    BEGIN
      ch := qio_1_char;
      IF ( ch = '[' ) then
        BEGIN
          ch := qio_1_char;
          CASE ch of
            'C' : go_right;
            'D' : go_left;
            Otherwise
             qio_write (chr(7));                
          End;
        END
      ELSE
        qio_write (chr(7));                
    END;


    PROCEDURE  Delete;
    VAR
      last : integer;
    BEGIN
      IF ( i <> 1 ) then
        BEGIN
          last := length(picture_clause)+1;
          REPEAT
            last := last - 1;
          UNTIL ( last = 1 ) or ( picture_clause[last] in ['9','X'] );

          IF ( i <> last ) or ( return_value[i] = ' ' ) then
            REPEAT
              i := i - 1;
            UNTIL ( i = 1 ) or ( picture_clause[i] in ['9','X'] );

          IF not ( picture_clause[i] in ['9','X'] ) then
            BEGIN
              WHILE not ( picture_clause[i] in ['9','X'] ) do
                i := i + 1;
            END
          ELSE
            BEGIN
              posn (x_posn+i-1,y_posn);
               qio_write (' '+VT100_bs);
              return_value[i] := ' ';
            END;
        END;
    END;


    PROCEDURE  Key_control;
    BEGIN
      IF ( ch = chr(13) ) then
        BEGIN
          field_full_terminate := true;
          i := length(picture_clause) + 1;
        END
      ELSE
      IF ( ch = chr(27) ) then
        escape_sequence
      ELSE
      IF ( ch = chr(127) ) then
        delete
      ELSE
        qio_write (chr(7));                
    END;


BEGIN
  return_value := '';

{ get x & y if left out }

  FOR i := 1 to length(picture_clause) do
      CASE picture_clause[i] of
        '9' : IF length(default_value) < i then
                return_value := return_value + ' '
              ELSE
              IF ( default_value[i] in [' ','0'..'9'] ) then
                return_value := return_value + default_value[i]
              ELSE
                ERROR ('DEFAULT VALUE /'+default_value[i]+'/ DOES NOT MATCH PICTURE CLAUSE /'+picture_clause[i]+'/');
        'X' : IF length(default_value) < i then
                return_value := return_value + ' '
              ELSE
              IF ( default_value[i] in [' '..'~'] ) then
                return_value := return_value + default_value[i]
              ELSE
                ERROR ('%INTERACT-F-DVMM, DEFAULT VALUE /'+full_char(default_value[i])+'/ DOES NOT MATCH PICTURE CLAUSE /'+picture_clause[i]+'/');
       otherwise 
          return_value := return_value + picture_clause[i];
      End;

  outline := '';

  posn (x_posn,y_posn);
  IF length(begin_brace) > 0 then
    outline := outline + begin_brace;
  outline := outline + return_value;
  IF length(end_brace) > 0 then
    outline := outline + end_brace;

  qio_write (outline);

  IF length(begin_brace) > 0 then
    x_posn := x_posn + length(begin_brace);

  i := 1;
  REPEAT
    WHILE ( i <= length(picture_clause) ) do
      BEGIN
        posn (x_posn+i-1,y_posn);
        CASE picture_clause[i] of
          '9' : BEGIN
                  ch := qio_1_char;
                  IF ( ch in [' ','0'..'9'] ) then
                    BEGIN
                      return_value[i] := ch;
                      qio_write (ch);
                      i := i + 1;
                    END
                  ELSE
                    key_control;
                END;
          'X' : BEGIN
                  ch := qio_1_char;
                  IF ( ch in [' '..'~'] ) then
                    BEGIN
                      return_value[i] := ch;
                      qio_write (ch);
                      i := i + 1;
                    END
                  ELSE
                    key_control;
                END;
         otherwise 
            i := i + 1;
        End;
      END;
    IF ( i > length(picture_clause) ) and ( not field_full_terminate ) then
      i := length(picture_clause);
  UNTIL ( i > length(picture_clause) );
END;


[ASYNCHRONOUS, EXTERNAL(STR$TRIM)]
FUNCTION  $Trim
  ( VAR destination_str : [CLASS_S] PACKED ARRAY [$L1 .. $U1 : INTEGER] OF CHAR;
        source_str      : [CLASS_S] PACKED ARRAY [$L2 .. $U2 : INTEGER] OF CHAR;
    VAR return_length   : $UWORD
  ) : integer;
Extern;

[GLOBAL]
FUNCTION  Trim ( text : v_array ) : v_array;
BEGIN
  System_Call ($trim (text.body,text,text.length));
  trim := text;
END;

TYPE
  date_time_type = array [1..7] of $uword;


[ASYNCHRONOUS, EXTERNAL(LIB$DAY_OF_WEEK)]
FUNCTION  $Day_of_week
    (
        time     : $quad := %IMMED 0;
    VAR day_num  : integer
    ) : integer;
Extern;


[GLOBAL]
FUNCTION  Get_Date_time : date_time_type;
VAR
  Date_time : date_time_type;
BEGIN
  System_Call ($numtim (date_time));
  get_date_time := date_time;
END;


[GLOBAL]
FUNCTION  Day_num ( Date_Time : date_time_type ) : integer;
VAR
  temp : integer;
  q : $quad;
BEGIN
  System_Call ($gettim(q));
  System_Call ($day_of_week(q,temp));
  day_num := temp;
END;


[HIDDEN]
CONST
(* These values are returned by the predefined STATUS function. *)

    PAS$K_SUCCESS    =    0;    (* last operation successful *)
    PAS$K_FILNOTFOU  =    3;    (* file not found *)
    PAS$K_ACCMETINC  =    5;    (* ACCESS_METHOD specified is incompatible with this file *)
    PAS$K_RECLENINC  =    6;    (* RECORD_LENGTH specified is inconsistent with this file *)

[HIDDEN]
TYPE
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
  newfile : File of everything;
  game_count_incremented : boolean := false;

[HIDDEN]
PROCEDURE  Get_Image_dir_and_ACN_name ( VAR directory, gamename : v_array );
VAR
  the_name : v_array;
BEGIN
  the_name := Get_jpi_str(jpi$_imagname,100);
  WHILE ( index(the_name,'][') <> 0 ) do
    BEGIN
      the_name := substr(the_name,1,index(the_name,'][')-1) + substr(the_name,index(the_name,'][')+2,length(the_name)-(index(the_name,'][')+2));
    END;
  directory := substr(the_name,1,index(the_name,']'));
  the_name := substr(the_name,index(the_name,']')+1,the_name.length-index(the_name,']'));
  gamename := substr(the_name,1,index(the_name,'.')-1);
END;

[HIDDEN]
FUNCTION  month_of_year ( i : integer ) : v_array;
BEGIN
  month_of_year := substr('JanFebMarAprMayJunJulAugSepOctNovDec',(i*3)-2,3);
END;

[HIDDEN]
PROCEDURE  Display_Screen ( current_state : everything; date_time : date_time_type; me : integer; gamename : v_array; last_score : integer );
VAR
  i : integer;
  year_now  : integer;
  month_now : integer;
BEGIN
  year_now  := date_time[1];
  month_now := date_time[2];
  clear;
  posn (1,1);
  qio_write ('Immortal Players For '+_dec(year_now-1)+' - '+_dec(year_now)+'               Top Players For '+month_of_year(month_now)+' ');
  qio_writeln (VT100_bright+_dec(current_state.tot_games,,6)+' Games'+VT100_normal);
  qio_writeln (VT100_graphics_on+'oooooooooooooooooooooooooooooooo               ooooooooooooooooooo'+VT100_graphics_off);
  qio_writeln ('Month  Username  Name         Score     Num Username  Name         Score   Games');
  qio_writeln;

  For i := month_now-1 downto 1 do
    IF ( current_state.m_score[i] <> -maxint-1 ) then
      qio_writeln (' '+month_of_year(i)+'   '+current_state.m_user[i]+'  '+current_state.m_name[i]+' '+_dec(current_state.m_score[i],,5))
    ELSE
      qio_writeln;
  For i := 12 downto month_now do
    IF ( current_state.m_score[i] <> -maxint-1 ) then
      qio_writeln (' '+month_of_year(i)+'   '+current_state.m_user[i]+'  '+current_state.m_name[i]+' '+_dec(current_state.m_score[i],,5))
    ELSE
      qio_writeln;

  For i := 0 to 11 do
    IF ( current_state.score[i] <> -maxint-1 ) then
      qio_write (get_posn(41,5+i)+_dec(i+1,,3)+' '+current_state.user[i]+'  '+current_state.name[i]+' '+_dec(current_state.score[i],,5)+'   '+_dec(current_state.games[i],,3));

  posn (5,18);
  qio_write ('You Are Seated At '+_dec(me+1)+' In '+gamename);

  IF ( last_score <> -maxint-1 ) THEN
    BEGIN
        { doing worse on or off board or better but still off board }
      posn (42,18);
      qio_writeln ('Previous Score '+_dec(last_score));
    END;
END;

[HIDDEN]
PROCEDURE  Display_Current_Score (last_score : integer; this_score : integer );
BEGIN
  posn (42,20);
  qio_writeln ('Current Score '+_dec(this_score));
END;

[HIDDEN]
PROCEDURE  Display_Update_Prompts (me : integer; last_score : integer; this_score : integer );
BEGIN
  IF ( me < 12 ) THEN
    BEGIN
      posn (5,20);
      qio_writeln (VT100_bright+'Enter Your Name [ Return to Leave ]'+VT100_normal);
    END;
END;

[HIDDEN]
PROCEDURE  Create_new_score_file ( directory : v_array; gamename : v_array; date_time : date_time_type );
VAR
  i : integer;
  month_now : integer;
BEGIN
  month_now := date_time[2];
  OPEN(newfile,directory+gamename+'.ACN',new,,direct,error:=continue);
  IF status(newfile) <> PAS$K_SUCCESS THEN
    BEGIN
      qio_writeln ('Can''t Create '+gamename+'.ACN Insufficient priviledge.');
      $exit(1);
    END;
  rewrite (newfile);
  newfile^.tot_games := 0;
  newfile^.month     := month_now;
  FOR i := 1 to 12 do
    BEGIN
      newfile^.m_user[i] := '        ';
      newfile^.m_name[i] := '            ';
      newfile^.m_score[i] := -maxint-1;
    END;
  FOR i := 0 to 19 do
    BEGIN
      newfile^.user[i] := '        ';
      newfile^.name[i] := '            ';
      newfile^.score[i] := -maxint-1;
    END;
  newfile^.games := zero;
  put (newfile);
  close (newfile);
END;

[HIDDEN]
PROCEDURE  Update_Topten ( VAR current_state : everything; 
                            date_time : date_time_type; 
                            username : v_array; 
                            this_score : integer; 
                        VAR me : integer; 
                        VAR last_score : integer; 
                            newname : [TRUNCATE] s_array );
VAR
  i, j, k : integer;
  old_name  : s_array;
  old_games : integer;
  month_now : integer;
BEGIN
  { high score for the month }
  month_now := date_time[2];

  if not game_count_incremented then
    current_state.tot_games := current_state.tot_games + 1;
  IF ( current_state.month <> month_now ) and ( current_state.month <> 0 ) then
    BEGIN
      if month_now > current_state.month then
        FOR i := current_state.month to month_now-1 do
          BEGIN
            newfile^.m_user[i] := '        ';
            newfile^.m_name[i] := '            ';
            newfile^.m_score[i] := -maxint-1;
          END
      else
        BEGIN
          FOR i := current_state.month to 12 do
            BEGIN
              newfile^.m_user[i] := '        ';
              newfile^.m_name[i] := '            ';
              newfile^.m_score[i] := -maxint-1;
            END;
          IF month_now-1 >= 1 THEN
            FOR i := 1 to month_now-1 do
              BEGIN
                newfile^.m_user[i] := '        ';
                newfile^.m_name[i] := '            ';
                newfile^.m_score[i] := -maxint-1;
              END;
        END;
      current_state.m_user[current_state.month] := current_state.user[0];
      current_state.m_name[current_state.month] := current_state.name[0];
      current_state.m_score[current_state.month] := current_state.score[0];
      FOR i := 0 to 19 do
        BEGIN
          current_state.user[i] := '        ';
          current_state.name[i] := '            ';
          current_state.score[i] := -maxint-1;
        END;
      current_state.games := zero;
    END;
  current_state.month := month_now;

{ insert/find user somewhere }

  i := 0;
  WHILE ( i<19 ) and ( current_state.user[i]<>username ) do
    i := i + 1;
  IF ( current_state.user[i]<>username ) then
    BEGIN
      current_state.user[i] := username;
      current_state.name[i] := '            ';
      current_state.score[i] := -maxint-1;
      current_state.games[i] := 1;
    END
  ELSE
    if not game_count_incremented then
      current_state.games[i] := current_state.games[i] + 1;
  last_score := current_state.score[i];
  me := i;

{ move user up }

  IF this_score > current_state.score[i] then
    BEGIN
      j := 0;
      WHILE this_score <= current_state.score[j] do
        j := j + 1;
      IF j < i then
        BEGIN
          old_name := current_state.name[i];
          old_games := current_state.games[i];
          FOR k := i downto j+1 do
            BEGIN
              current_state.user[k] := current_state.user[k-1];
              current_state.name[k] := current_state.name[k-1];
              current_state.score[k] := current_state.score[k-1];
              current_state.games[k] := current_state.games[k-1];
            END;
          current_state.user[j] := username;
          current_state.name[j] := old_name;
          current_state.games[j] := old_games;
          me := j;
        END;
      current_state.score[me] := this_score;
      IF present(newname) then
        current_state.name[me] := newname;
    END;
END;

[GLOBAL]
PROCEDURE  increment_game_count;
VAR
  last_score : integer;
  directory : v_array;
  gamename  : v_array;
  username  : v_array;
  i,j,k, me : integer;
  newname : s_array;
  current_state : everything;
  date_time : date_time_type;
BEGIN
  username := Get_jpi_str(jpi$_username,8);
  Get_Image_dir_and_ACN_name (directory,gamename);

  REPEAT
    OPEN (newfile,directory+gamename+'.ACN',old,,direct,error:=continue);
    CASE status(newfile) of
      PAS$K_SUCCESS,
      PAS$K_FILNOTFOU,
      PAS$K_ACCMETINC,
      PAS$K_RECLENINC : ;
      OTHERWISE sleep (1);
    END;
  UNTIL (status(newfile)=PAS$K_SUCCESS) or
        (status(newfile)=PAS$K_FILNOTFOU) or
        (status(newfile)=PAS$K_ACCMETINC) or
        (status(newfile)=PAS$K_RECLENINC);

  IF status(newfile)=PAS$K_SUCCESS THEN
    BEGIN
      reset (newfile);
      current_state := newfile^;
      date_time := Get_Date_time; 
      update_topten (current_state,date_time,username,-maxint-1,me,last_score);
      rewrite (newfile);
      newfile^ := current_state;
      Put (newfile);
      Close (newfile);
      game_count_incremented := true;
    END;
END;

[GLOBAL]
PROCEDURE  read_top_ten;
VAR
  last_score : integer;
  directory : v_array;
  gamename  : v_array;
  username  : v_array;
  i,j,k, me : integer;
  newname : s_array;
  current_state : everything;
  date_time : date_time_type;
BEGIN
  reset_screen;
  clear;
  posn (1,1);

  username := Get_jpi_str(jpi$_username,8);
  Get_Image_dir_and_ACN_name (directory,gamename);

  REPEAT
    OPEN (infile,directory+gamename+'.ACN',old,,direct,error:=continue);
    CASE status(infile) of
      PAS$K_SUCCESS : ;
      PAS$K_FILNOTFOU : BEGIN
            qio_writeln ('Can''t find file '+gamename+'.ACN Creating New File ...');
            date_time := Get_Date_time; 
            create_new_score_file(directory,gamename,date_time);
          END;
      PAS$K_ACCMETINC,
      PAS$K_RECLENINC : BEGIN
            qio_writeln ('Error in file format of '+gamename+'.ACN');
            $exit(1);
          END;
      OTHERWISE sleep (1);
    END;
  UNTIL status(infile)=PAS$K_SUCCESS;
  reset (infile);
  current_state := infile^;
  close (infile);

  date_time := Get_Date_time; 
  update_topten (current_state,date_time,username,-maxint-1,me,last_score);
  Display_screen (current_state,date_time,me,gamename,last_score);
END;

[GLOBAL]
FUNCTION  read_last_score : integer;
VAR
  last_score : integer;
  directory : v_array;
  gamename  : v_array;
  username  : v_array;
  i,j,k, me : integer;
  newname : s_array;
  current_state : everything;
  date_time : date_time_type;
BEGIN
  username := Get_jpi_str(jpi$_username,8);
  Get_Image_dir_and_ACN_name (directory,gamename);
  REPEAT
    OPEN (infile,directory+gamename+'.ACN',old,,direct,error:=continue);
    CASE status(infile) of
      PAS$K_SUCCESS,
      PAS$K_FILNOTFOU,
      PAS$K_ACCMETINC,
      PAS$K_RECLENINC : last_score := -maxint-1;
      OTHERWISE sleep (1);
    END;
  UNTIL (status(infile)=PAS$K_SUCCESS) or
        (status(infile)=PAS$K_FILNOTFOU) or
        (status(infile)=PAS$K_ACCMETINC) or
        (status(infile)=PAS$K_RECLENINC);
  
  IF status(infile)=PAS$K_SUCCESS THEN
    BEGIN
      reset (infile);
      current_state := infile^;
      close (infile);
      date_time := Get_Date_time; 
      update_topten (current_state,date_time,username,-maxint-1,me,last_score);
    END;
  read_last_score := last_score;
END;

[GLOBAL]
PROCEDURE  top_ten ( this_score : integer );
VAR
  last_score : integer;
  directory : v_array;
  gamename  : v_array;
  username  : v_array;
  i,j,k, me : integer;
  v_name : v_array;
  newname : s_array;
  current_state : everything;
  date_time : date_time_type;
BEGIN
  reset_screen;
  clear;
  posn (1,1);

  username := Get_jpi_str(jpi$_username,8);
  Get_Image_dir_and_ACN_name (directory,gamename);

  REPEAT
    OPEN (infile,directory+gamename+'.ACN',old,,direct,error:=continue);
    CASE status(infile) of
      PAS$K_SUCCESS : ;
      PAS$K_FILNOTFOU : BEGIN
            qio_writeln ('Can''t find file '+gamename+'.ACN Creating New File ...');
            date_time := Get_Date_time; 
            create_new_score_file(directory,gamename,date_time);
          END;
      PAS$K_ACCMETINC,
      PAS$K_RECLENINC : BEGIN
            qio_writeln ('Error in file format of '+gamename+'.ACN');
            $exit(1);
          END;
      OTHERWISE sleep (1);
    END;
  UNTIL status(infile)=PAS$K_SUCCESS;
  reset (infile);
  current_state := infile^;
  close (infile);

  date_time := Get_Date_time; 
  update_topten (current_state,date_time,username,this_score,me,last_score);
  Display_screen (current_state,date_time,me,gamename,last_score);
  Display_current_score (last_score,this_score);
  Display_update_prompts(me,last_score,this_score);

  newname := current_state.name[me];
  IF (( last_score < this_score ) or ( last_score = -maxint-1 )) AND ( me < 12 ) THEN
    BEGIN
      Formated_read (v_name,'XXXXXXXXXXXX',55,5+me,newname);
      newname := v_name;
    END;

  REPEAT
    OPEN (newfile,directory+gamename+'.ACN',old,,direct,error:=continue);
    CASE status(newfile) of
      PAS$K_SUCCESS : ;
      PAS$K_FILNOTFOU,
      PAS$K_ACCMETINC,
      PAS$K_RECLENINC : BEGIN
            qio_writeln ('Unknown File Error in '+gamename+'.ACN');
            $exit(1);
          END;
      OTHERWISE
          BEGIN
            sleep (1);
            clear;
            Posn(1,1);
            qio_writeln (trim(Username)+', Updating Please Wait ...');
          END;
    END;
  UNTIL status(newfile)=PAS$K_SUCCESS;
  reset (newfile);
  current_state := newfile^;
  date_time := Get_Date_time; 
  update_topten (current_state,date_time,username,this_score,me,last_score,newname);
  rewrite (newfile);
  newfile^ := current_state;
  Put (newfile);
  Close (newfile);
  posn (1,23);
END;


END.
