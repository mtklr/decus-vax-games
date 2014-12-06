[
  Inherit 
    (
      'SYS$LIBRARY:STARLET',
      'INTERACT'
    )
]

PROGRAM  Daleks;

CONST
  left    = 2;
  right   = 39;
  top     = 2;
  bottom  = 21;
  nothing = ' ';
  dalek   = 'D';
  doctor  = 'O';
  junk    = '*';
  dont_wait = false;

TYPE
  dalek_pointer = ^dalek_node;
  dalek_node = Record
                  x , y : integer;
                  prev : dalek_pointer;
                  next : dalek_pointer;
                End;
  big_array = array [1..(right-left+1)*(bottom-top+1)] of Record
                  x , y : integer;
              End;            
  v_array = varying [10] of char;

VAR
  board : array [left..right,top..bottom] of char;
  score : integer;
  screwdriver_used : boolean;
  x_posn , y_posn : integer;
  head_dalek : dalek_pointer;
  level : integer;
  doctor_dead : boolean;
  daleks_dead : boolean;
  last_stand : boolean;
  beeps_on : boolean;


FUNCTION  move_right ( n : integer ) : v_array;
BEGIN
  IF n = 0 then
    move_right := ''
  ELSE
  IF n = 1 then
    move_right := VT100_esc + '[C'
  ELSE
    move_right := VT100_esc + '[' + dec(n) + 'C';
END;


PROCEDURE  Initialize;
BEGIN
  show_graphedt ('Daleks.pic');
  score := 0;
  level := 0;
  head_dalek := nil;
  doctor_dead := false;
  daleks_dead := false;
  beeps_on := false;
END;


PROCEDURE  Place_doctor_first_time;
VAR 
  x,y : integer;
BEGIN
  x_posn := random(right-left+1)+left-1;
  y_posn := random(bottom-top+1)+top-1;
  FOR x := max(left,x_posn-1) to min(x_posn+1,right) do
    FOR y := max(top,y_posn-1) to min(y_posn+1,bottom) do
      board[x,y] := doctor;
END;


PROCEDURE  Remove_doctor_with_style;
VAR
  x,y,i : integer;
BEGIN
  qio_write (get_posn (x_posn,y_posn)+
            VT100_graphics_on+'`'+VT100_graphics_off);
  board[x_posn,y_posn] := nothing;

  qio_write (get_posn (x_posn,y_posn)+nothing);

  FOR i := 1 to 3 do
    BEGIN
      qio_write (VT100_bright+
            get_posn (x_posn,max(y_posn-i,top))+
            VT100_graphics_on+'~'+VT100_graphics_off+
            get_posn (x_posn,min(y_posn+i,bottom))+
            VT100_graphics_on+'~'+VT100_graphics_off+
            get_posn (max(x_posn-i,left),y_posn)+
            VT100_graphics_on+'~'+VT100_graphics_off+
            get_posn (min(x_posn+i,right),y_posn)+
            VT100_graphics_on+'~'+VT100_graphics_off+
            VT100_normal+
            get_posn (x_posn,max(y_posn-i,top))+
            board[x_posn,max(y_posn-i,top)]+
            get_posn (x_posn,min(y_posn+i,bottom))+
            board[x_posn,min(y_posn+i,bottom)]+
            get_posn (max(x_posn-i,left),y_posn)+
            board[max(x_posn-i,left),y_posn]+
            get_posn (min(x_posn+i,right),y_posn)+
            board[min(x_posn+i,right),y_posn]);
    END;
END;


FUNCTION  Teleport_possible : boolean;
VAR 
  x,y,i,j : integer;
  r : integer;
  safe_places : integer;
  safe : boolean;
  safe_where : big_array;
BEGIN
  safe_places := 0;
  FOR x := left to right do
    FOR y := top to bottom do
      IF board[x,y] = nothing then
        BEGIN
          safe := true;
          i := max(left,x-1);
          r := min(x+1,right);
          WHILE ( i <= r ) and safe do
            BEGIN
              FOR j := max(top,y-1) to min(y+1,bottom) do
                IF ( board[i,j] = dalek ) then
                  safe := false;
              i := i + 1;
            END;
          IF safe then
            BEGIN
              safe_places := safe_places + 1;
              safe_where[safe_places].x := x;
              safe_where[safe_places].y := y;
            END;
        END;
                
  teleport_possible := ( safe_places <> 0 );

  IF safe_places <> 0 then
    BEGIN
      i := random(safe_places);
      remove_doctor_with_style;
      x_posn := safe_where[i].x;
      y_posn := safe_where[i].y;
    END;
END;


PROCEDURE  Create_daleks ( nu : integer );
VAR
  i,j : integer;
  x,y : integer;
  safe_places : integer;
  safe_where : big_array;
  this_dalek : dalek_pointer;
  buffer : varying [200] of char;
  spaces : integer;
BEGIN
  safe_places := 0;
  FOR x := left to right do
    FOR y := top to bottom do
      IF ( board[x,y] = nothing ) then
        BEGIN
          safe_places := safe_places + 1;
          safe_where[safe_places].x := x;
          safe_where[safe_places].y := y;
        END;

  reset_randomizer;
  FOR j := 1 to min(nu,safe_places) do
    BEGIN
      NEW (this_dalek);
      this_dalek^.next := head_dalek;
      IF ( head_dalek <> nil ) then
        head_dalek^.prev := this_dalek;
      head_dalek := this_dalek;
            
      i := randomize(safe_places);
      this_dalek^.x := safe_where[i].x;
      this_dalek^.y := safe_where[i].y;

      board[this_dalek^.x,this_dalek^.y] := dalek;
    END;

  FOR y := top to bottom do
    BEGIN
      buffer := '';
      spaces := 100;
      FOR x := left to right do
        IF ( board[x,y] = dalek ) then
          BEGIN
            IF ( spaces > 5 ) then
              buffer := buffer + get_posn(x,y) + dalek
            ELSE
              buffer := buffer + pad('',' ',spaces) + dalek;
            spaces := 0;
          END
        ELSE
          spaces := spaces + 1;
      qio_write (buffer);
    END;
END;


PROCEDURE  Put_on_doctor_with_style;
VAR
  x,y,i : integer;
BEGIN
  FOR i := 3 downto 1 do
    BEGIN
      qio_write (VT100_bright+
            get_posn (x_posn,max(y_posn-i,top))+
            VT100_graphics_on+'~'+VT100_graphics_off+
            get_posn (x_posn,min(y_posn+i,bottom))+
            VT100_graphics_on+'~'+VT100_graphics_off+
            get_posn (max(x_posn-i,left),y_posn)+
            VT100_graphics_on+'~'+VT100_graphics_off+
            get_posn (min(x_posn+i,right),y_posn)+
            VT100_graphics_on+'~'+VT100_graphics_off+
            VT100_normal+
            get_posn (x_posn,max(y_posn-i,top))+
            board[x_posn,max(y_posn-i,top)]+
            get_posn (x_posn,min(y_posn+i,bottom))+
            board[x_posn,min(y_posn+i,bottom)]+
            get_posn (max(x_posn-i,left),y_posn)+
            board[max(x_posn-i,left),y_posn]+
            get_posn (min(x_posn+i,right),y_posn)+
            board[min(x_posn+i,right),y_posn]);
    END;
  qio_write (get_posn (x_posn,y_posn)+
            VT100_graphics_on+'`'+VT100_graphics_off);
  board[x_posn,y_posn] := doctor;
END;


FUNCTION  beep_on_or_off : v_array;
BEGIN
  IF beeps_on then
    beep_on_or_off := 'ON '
  ELSE
    beep_on_or_off := 'OFF';
END;


PROCEDURE  Setup;
VAR
  x , y , i : integer;
BEGIN
  clear;
  posn (1,1);
  for y := 1 to 23 do
    qio_writeln (VT100_wide);
  square (left-1,top-1,right+1,bottom+1);
  FOR x := left to right do
    FOR y := top to Bottom do
      board[x,y] := nothing;
  level := level + 1;
  screwdriver_used := false;
  last_stand := false;
  qio_write (get_posn (2,23)+
            'LEVEL : '+VT100_bright+dec(level)+VT100_normal+
            get_posn (14,23)+
            'BEEPS : '+VT100_bright+beep_on_or_off+VT100_normal+
            get_posn (27,23)+
            'SCORE : '+VT100_bright+dec(score)+VT100_normal);
  place_doctor_first_time;
  create_daleks ((level**2)*6);
  FOR x := max(left,x_posn-1) to min(x_posn+1,right) do
    FOR y := max(top,y_posn-1) to min(y_posn+1,bottom) do
      board[x,y] := nothing;
  put_on_doctor_with_style;
  qio_purge;
END;


PROCEDURE  Sonic_screwdriver;
VAR
  this_dalek : dalek_pointer;
  temp_dalek : dalek_pointer;
BEGIN
  screwdriver_used := true;
  qio_write (VT100_graphics_on+VT100_bright);
  IF y_posn > top then
    IF x_posn > left then
      IF x_posn < right then
        qio_write (get_posn(x_posn-1,y_posn-1)+'lqk')
      ELSE
        qio_write (get_posn(x_posn-1,y_posn-1)+'lq')
    ELSE
      qio_write (get_posn(x_posn,y_posn-1)+'qk');

  IF x_posn > left then
    IF x_posn < right then
      qio_write (get_posn(x_posn-1,y_posn)+'x x')
    ELSE
      qio_write (get_posn(x_posn-1,y_posn)+'x ')
  ELSE
    qio_write (get_posn(x_posn,y_posn)+' x');

  IF y_posn < bottom then
    IF x_posn > left then
      IF x_posn < right then
        qio_write (get_posn(x_posn-1,y_posn+1)+'mqj')
      ELSE
        qio_write (get_posn(x_posn-1,y_posn+1)+'mq')
    ELSE
      qio_write (get_posn(x_posn,y_posn+1)+'qj');

  qio_write (VT100_graphics_off+VT100_normal);

  this_dalek := head_dalek;
  WHILE ( this_dalek <> nil ) do
    BEGIN
      IF ( abs(this_dalek^.x-x_posn) < 2 ) and 
         ( abs(this_dalek^.y-y_posn) < 2 ) then
        BEGIN
          IF ( this_dalek^.prev = nil ) then
            head_dalek := head_dalek^.next
          ELSE
            this_dalek^.prev^.next := this_dalek^.next;
          IF ( this_dalek^.next <> nil ) then
            this_dalek^.next^.prev := this_dalek^.prev;
          board[this_dalek^.x,this_dalek^.y] := nothing;
          IF beeps_on then
            qio_write (VT100_bell);
          temp_dalek := this_dalek;
          this_dalek := this_dalek^.next;
          DISPOSE (temp_dalek);
          score := score + 1 + ord(last_stand);
          qio_write (get_posn (27,23)+
                    'SCORE : '+VT100_bright+dec(score)+VT100_normal);
        END
      ELSE
        this_dalek := this_dalek^.next;
    END;

  IF y_posn > top then
    IF x_posn > left then
      IF x_posn < right then
        qio_write (get_posn(x_posn-1,y_posn-1)+
            board[x_posn-1,y_posn-1]+
            board[x_posn,y_posn-1]+
            board[x_posn+1,y_posn-1])
      ELSE
        qio_write (get_posn(x_posn-1,y_posn-1)+
            board[x_posn-1,y_posn-1]+
            board[x_posn,y_posn-1])
    ELSE
      qio_write (get_posn(x_posn,y_posn-1)+
            board[x_posn,y_posn-1]+
            board[x_posn+1,y_posn-1]);

  IF x_posn > left then
    IF x_posn < right then
      qio_write (get_posn(x_posn-1,y_posn)+
            board[x_posn-1,y_posn]+
            ' '+
            board[x_posn+1,y_posn])
    ELSE
      qio_write (get_posn(x_posn-1,y_posn)+
            board[x_posn-1,y_posn]+
            ' ')
  ELSE
    qio_write (get_posn(x_posn,y_posn)+
            ' '+
            board[x_posn+1,y_posn]);

  IF y_posn < bottom then
    IF x_posn > left then
      IF x_posn < right then
        qio_write (get_posn(x_posn-1,y_posn+1)+
            board[x_posn-1,y_posn+1]+
            board[x_posn,y_posn+1]+
            board[x_posn+1,y_posn+1])
      ELSE
        qio_write (get_posn(x_posn-1,y_posn+1)+
            board[x_posn-1,y_posn+1]+
            board[x_posn,y_posn+1])
    ELSE
      qio_write (get_posn(x_posn,y_posn+1)+
            board[x_posn,y_posn+1]+
            board[x_posn+1,y_posn+1]);
  qio_write (get_posn (x_posn,y_posn)+
            VT100_graphics_on+'`'+VT100_graphics_off);
END;


PROCEDURE  refresh;
VAR
  this_dalek : dalek_pointer;
  x,y : integer;
  buffer : varying [200] of char;
  spaces : integer;
BEGIN
  clear;
  posn (1,1);
  for y := 1 to 23 do
    qio_writeln (VT100_wide);
  square (left-1,top-1,right+1,bottom+1);
  qio_write (get_posn (2,23)+
            'LEVEL : '+VT100_bright+dec(level)+VT100_normal+
            get_posn (14,23)+
            'BEEPS : '+VT100_bright+beep_on_or_off+VT100_normal+
            get_posn (27,23)+
            'SCORE : '+VT100_bright+dec(score)+VT100_normal);
  FOR y := top to bottom do
    BEGIN
      buffer := '';
      spaces := 100;
      FOR x := left to right do
      CASE board[x,y] of
        nothing : spaces := spaces + 1;
        dalek   : BEGIN
                    IF ( spaces > 5 ) then
                      buffer := buffer + get_posn(x,y) + dalek
                    ELSE
                      buffer := buffer + pad('',' ',spaces) + dalek;
                    spaces := 0;
                  END;
        doctor  : BEGIN
                    IF ( spaces > 5 ) then
                      buffer := buffer + get_posn(x,y) + VT100_graphics_on+'`'+VT100_graphics_off
                    ELSE
                      buffer := buffer + pad('',' ',spaces) + VT100_graphics_on+'`'+VT100_graphics_off;
                    spaces := 0;
                  END;
        junk    : BEGIN
                    IF ( spaces > 5 ) then
                      buffer := buffer + get_posn(x,y) + junk
                    ELSE
                      buffer := buffer + pad('',' ',spaces) + junk;
                    spaces := 0;
                  END;
      END;
      qio_write (buffer);
    END;
END;


PROCEDURE  Move_doctor;
VAR
  x , y : integer;
  threatened : boolean;
  command : char;
  valid_command : boolean;
BEGIN
  REPEAT
    posn (1,1);
    IF not last_stand then
      command := upper_case(qio_1_char)
    ELSE
      command := '5';
    IF ord(command) = 23 then
      refresh;
    IF command = 'B' then
      BEGIN
        beeps_on := not beeps_on;
        posn (14,23);
        qio_write ('BEEPS : '+VT100_bright+beep_on_or_off+VT100_normal);
      END;
    CASE command of
      '1' : valid_command := ( x_posn > left ) and ( y_posn < bottom );
      '2' : valid_command := ( y_posn < bottom );
      '3' : valid_command := ( x_posn < right ) and ( y_posn < bottom );
      '4' : valid_command := ( x_posn > left );
      '5' : valid_command := true;
      '6' : valid_command := ( x_posn < right );
      '7' : valid_command := ( x_posn > left ) and ( y_posn > top );
      '8' : valid_command := ( y_posn > top );
      '9' : valid_command := ( x_posn < right ) and ( y_posn > top );
      'S' : valid_command := ( screwdriver_used = false );
      'T' : valid_command := teleport_possible;
      'L' : valid_command := true;
     Otherwise valid_command := false;
    End;
  UNTIL ( valid_command );

  IF ( command = 'T' ) then
    BEGIN
      put_on_doctor_with_style;
      score := max(score-(2**max(0,level-2)),0);
      posn (27,23);
      qio_write ('SCORE : '+VT100_bright+dec(score)+VT100_normal);
      clear ('LINE','TO_END');
    END;

  IF not last_stand then
    BEGIN
      board[x_posn,y_posn] := nothing;
      posn (x_posn,y_posn);
      qio_write (nothing);

      IF ( command in ['1','2','3'] ) then
        y_posn := y_posn + 1;
      IF ( command in ['7','8','9'] ) then
        y_posn := y_posn - 1;
      IF ( command in ['1','4','7'] ) then
        x_posn := x_posn - 1;
      IF ( command in ['3','6','9'] ) then
        x_posn := x_posn + 1;

      IF ( command = 'S' ) then
        sonic_screwdriver;

      IF ( command = 'L' ) then
        BEGIN
          last_stand := true;
          IF not screwdriver_used then
            BEGIN
              threatened := false;
              FOR x := max(left,x_posn-1) to min(right,x_posn+1) do
                FOR y := max(top,y_posn-1) to min(bottom,y_posn+1) do
                  IF board[x,y] = dalek then 
                    threatened := TRUE;
              IF threatened then
                sonic_screwdriver;
            END;
        END;

      IF ( board[x_posn,y_posn] <> nothing ) then
        BEGIN
          IF beeps_on then
            qio_write (VT100_bell);
          doctor_dead := true;
        END;

      board[x_posn,y_posn] := doctor;
      posn (x_posn,y_posn);
      qio_write (VT100_graphics_on+'`'+VT100_graphics_off);
    END
  ELSE
  IF not screwdriver_used then
    BEGIN
      threatened := false;
      FOR x := max(left,x_posn-1) to min(right,x_posn+1) do
        FOR y := max(top,y_posn-1) to min(bottom,y_posn+1) do
          IF board[x,y] = dalek then 
            threatened := TRUE;
      IF threatened then
        sonic_screwdriver;
    END;
END;


PROCEDURE  Move_daleks;
VAR
  this_dalek : dalek_pointer;
  temp_dalek : dalek_pointer;
  old_board : array [left..right,top..bottom] of char;
  x, y : integer;
  spaces : integer;
  bell : boolean;
  buffer : varying [200] of char;
BEGIN
  old_board := board;
  this_dalek := head_dalek;
  WHILE ( this_dalek <> nil ) do
    BEGIN
      board[this_dalek^.x,this_dalek^.y] := nothing;
      this_dalek := this_dalek^.next;
    END;

  this_dalek := head_dalek;
  WHILE ( this_dalek <> nil ) do
    BEGIN
      this_dalek^.x := this_dalek^.x + sign(x_posn-this_dalek^.x);
      this_dalek^.y := this_dalek^.y + sign(y_posn-this_dalek^.y);

      IF ( board[this_dalek^.x,this_dalek^.y] = doctor ) then
        doctor_dead := true;
      IF ( board[this_dalek^.x,this_dalek^.y] = dalek ) then
        board[this_dalek^.x,this_dalek^.y] := junk;
      IF ( board[this_dalek^.x,this_dalek^.y] = junk ) then
        old_board[this_dalek^.x,this_dalek^.y] := nothing;
      IF ( board[this_dalek^.x,this_dalek^.y] = nothing ) then
        board[this_dalek^.x,this_dalek^.y] := dalek;

      this_dalek := this_dalek^.next;
    END;

{ restore screen }
  FOR y := top to bottom do
    BEGIN
      spaces := 100;
      buffer := '';
      bell := false;
      FOR x := left to right do
        IF ( board[x,y] <> old_board[x,y] ) then
          BEGIN
            IF beeps_on and ( board[x,y] = junk ) then
              bell := true;
            IF ( spaces > 5 ) then
              buffer := buffer + get_posn(x,y) + board[x,y]
            ELSE
              buffer := buffer + move_right(spaces) + board[x,y];
            spaces := 0;
          END
        ELSE
          spaces := spaces + 1;
      IF bell then
        buffer := buffer + VT100_bell;
      qio_write (buffer);
    END;


  this_dalek := head_dalek;
  WHILE ( this_dalek <> nil ) do
    BEGIN
      IF ( board[this_dalek^.x,this_dalek^.y] = junk ) then
        BEGIN
          IF ( this_dalek^.prev = nil ) then
            head_dalek := head_dalek^.next
          ELSE
            this_dalek^.prev^.next := this_dalek^.next;
          IF ( this_dalek^.next <> nil ) then
            this_dalek^.next^.prev := this_dalek^.prev;
          temp_dalek := this_dalek;
          this_dalek := this_dalek^.next;
          DISPOSE (temp_dalek);
          score := score + 1 + ord(last_stand);
          posn (27,23);
          qio_write ('SCORE : '+VT100_bright+dec(score)+VT100_normal);
        END
      ELSE
        this_dalek := this_dalek^.next;
    END;

  IF doctor_dead and beeps_on then
    qio_write (VT100_bell);
  daleks_dead := ( head_dalek = nil );
END;


PROCEDURE  Explode_doctor;
VAR
  x , y , i : integer;
BEGIN
  FOR y := max(top,y_posn-2) to min(y_posn+2,bottom) do
    FOR x := max(left,x_posn-2) to min(x_posn+2,right) do
      BEGIN
        posn (x,y);
        i := random(3);
        IF i = 1 then
          qio_write (' ')
        ELSE
          qio_write ('.');
      END;

  FOR y := max(top,y_posn-2) to min(y_posn+2,bottom) do
    FOR x := max(left,x_posn-2) to min(x_posn+2,right) do
      BEGIN
        posn (x,y);
        CASE board[x,y] of
          nothing : qio_write (nothing);
          doctor  : qio_write (junk);
          dalek  : qio_write (dalek);
          junk    : qio_write (junk);
        END;
      END;
  sleep(sec:=1);
END;


BEGIN
  initialize;
  REPEAT
    setup;
    REPEAT
      move_doctor;
      move_daleks;
    UNTIL ( doctor_dead ) or ( daleks_dead );
    IF doctor_dead then
      explode_doctor
    ELSE
      BEGIN
        posn (1,23);
        clear('LINE');
        qio_write (VT100_bright+'Please Wait ...'+VT100_normal);
        sleep(sec:=2);
      END;
  UNTIL ( doctor_dead ) or ( level = 10 ) ;
  Top_ten (score);
END.
