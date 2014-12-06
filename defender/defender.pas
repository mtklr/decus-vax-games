[
  Inherit 
    (
      'SYS$LIBRARY:STARLET',
      'INTERACT'
    )
]

PROGRAM  Defender;

CONST
  max_aliens = 8;
TYPE
  pointer = ^shot;
  shot    = record
              x_posn : integer;
              y_posn : integer;
              prev   : pointer;
              next   : pointer;
            End;
  v_array = varying [200] of char;
VAR
  Screen        : array [1..40,1..20] of integer;
  x_alien       : array [1..max_aliens] of integer;
  y_alien       : array [1..max_aliens] of integer;
  d_alien       : array [1..max_aliens] of integer;
  alien_type    : array [1..max_aliens] of char;
  alien_alive   : array [1..max_aliens] of boolean;
  gun_working   : array [1..9] of boolean;
  gun_shot      : array [1..9] of integer;
  score         : integer;
  penality      : integer;
  command       : char;
  head_shot     : pointer;
  this_shot     : pointer;
  shot_deleted  : boolean;


PROCEDURE  Setup;
VAR
  i : integer;
  x : integer;
  y : integer;
BEGIN
  command := ' ';
  clear;
  qio_write (VT100_inverse);
  FOR y := 1 to 24 do
    BEGIN
      posn (1,y);
      qio_write (VT100_wide);
    END;
  FOR y := 21 to 22 do
    BEGIN
      posn (1,y);
      FOR x := 1 to 40 do
        qio_write (' ');
    END;

  FOR i := 1 to max_aliens do
    alien_alive[i] := false;

  FOR i := 1 to 9 do
    gun_working[i] := true;

  qio_write (VT100_normal);

  FOR x := 1 to 9 do
    BEGIN
      posn (x*4,21);
      qio_write ('^');
      posn (x*4,23);
      qio_write (dec(x));
    END;

  posn (15,24);
  qio_write ('SCORE : 0');
END;


PROCEDURE Refresh_screen;
VAR
  i : integer;
  x : integer;
  y : integer;
BEGIN
  command := ' ';
  clear;
  qio_write (VT100_inverse);
  FOR y := 1 to 24 do
    BEGIN
      posn (1,y);
      qio_write (VT100_wide);
    END;
  FOR y := 21 to 22 do
    BEGIN
      posn (1,y);
      FOR x := 1 to 40 do
        qio_write (' ');
    END;

  qio_write (VT100_normal);

  FOR x := 1 to 9 do
    BEGIN
      posn (x*4,21);
      IF gun_working[x] then
        qio_write ('^')
      ELSE
        qio_write ('*');
      posn (x*4,23);
      qio_write (dec(x));
    END;

  posn (15,24);
  qio_write ('SCORE : 0');
END;


PROCEDURE  Start_screen;
BEGIN
  clear;
  show_graphedt ('Defender.pic');
END;


PROCEDURE  Initialize;
BEGIN
  image_dir;
  score := 1;
END;


PROCEDURE  Get_command;
VAR
  valid_com : boolean;
  input_buffer : v_array;
  i : integer;
BEGIN
  input_buffer := qio_readln (80);
  i := 1;
  REPEAT
    IF ( i > length(input_buffer) ) then
      command := ' '
    ELSE
      command := input_buffer[i];
    i := i + 1;

    valid_com := true;
    IF ( command in ['1'..'9'] ) then
      IF not ( gun_working[ord(command)-ord('0')] ) or
             ( gun_shot[ord(command)-ord('0')] = 2 ) then
        valid_com := false;
  UNTIL ( valid_com );

  IF upper_case(command) = 'W' then
    refresh_screen;
END;


PROCEDURE  Create_aliens;
VAR
  but_not_for_long : integer;
  super : integer;
  nu : integer;
  n : integer;
BEGIN
  nu := ( score div 50 ) + 1;
  IF ( nu > max_aliens ) then
    nu := max_aliens;
  IF ( nu > 0 ) then
    BEGIN
      n := 1;
      WHILE ( n < nu ) and ( alien_alive[n] ) do
        n := n + 1;
      IF not ( alien_alive[n] ) then
        BEGIN
          super := random(4);
          IF ( super = 1 ) then
            BEGIN
              alien_alive[n] := true;
              reset_randomizer;
              REPEAT
                but_not_for_long := randomize(9);
              UNTIL ( gun_working[but_not_for_long] );
              CASE but_not_for_long of
                1 : x_alien[n] := 24;
                2 : x_alien[n] := 28;
                3 : x_alien[n] := 32;
                4 : x_alien[n] := 36;
                5 : x_alien[n] := 40;
                6 : x_alien[n] := 4;
                7 : x_alien[n] := 8;
                8 : x_alien[n] := 12;
                9 : x_alien[n] := 16;
              END;
              IF ( but_not_for_long > 5 ) then
                d_alien[n] := 1
              ELSE
                d_alien[n] := -1;
              y_alien[n] := 1;
              alien_type[n] := '$';
            END
          ELSE
            BEGIN
              alien_alive[n] := true;
              d_alien[n] := random(2);
              IF ( d_alien[n] <> 1 ) then
                d_alien[n] := -1;
              x_alien[n] := random (30)+5;
              y_alien[n] := 1;
              alien_type[n] := '#';
            END;
          posn (x_alien[n],Y_alien[n]);
          qio_write (alien_type[n]);
        END;
    END;
END;


PROCEDURE  Create_shot;
BEGIN
  penality := penality + 1;
  new (this_shot);
  this_shot^.next := head_shot;
  IF ( head_shot <> nil ) then
    head_shot^.prev := this_shot;
  this_shot^.prev := nil;
  head_shot := this_shot;
  WITH this_shot^ do
    BEGIN
      x_posn := (4*(ord(command)-ord('0')));
      y_posn := 20;
    END;
  gun_shot[ord(command)-ord('0')] := gun_shot[ord(command)-ord('0')] + 1;
END;


PROCEDURE  Delete_shot;
VAR
  temp : pointer;
BEGIN
  gun_shot[this_shot^.x_posn div 4] :=
          gun_shot[this_shot^.x_posn div 4] - 1;
  IF ( this_shot^.prev <> nil ) then
    this_shot^.prev^.next := this_shot^.next
  ELSE
    head_shot := this_shot^.next;
  IF ( this_shot^.next <> nil ) then
    this_shot^.next^.prev := this_shot^.prev;
  temp := this_shot^.next;
  dispose (this_shot);
  this_shot := temp;
  shot_deleted := true;
END;


PROCEDURE  Boom ( n : integer );
VAR
  i : integer;
BEGIN
  posn (x_alien[n]-2,y_alien[n]-2);
  qio_write ('. .  ');
  posn (x_alien[n]-2,y_alien[n]-1);
  qio_write (' .  .');
  posn (x_alien[n]-2,y_alien[n]);
  qio_write ('   . ');
  posn (x_alien[n]-2,y_alien[n]+1);
  qio_write (' .   ');
  posn (x_alien[n]-2,y_alien[n]+2);
  IF ( y_alien[n]+2 < 21 ) then
    qio_write ('. .  ');
  FOR i := -2 to 1 do
    BEGIN
      posn (x_alien[n]-2,y_alien[n]+i);
      qio_write ('     ');
    END;
  posn (x_alien[n]-2,y_alien[n]+2);
  IF ( y_alien[n]+2 < 21 ) then
    qio_write ('     ');

{ fix one gun }

  reset_randomizer;
  REPEAT
    i := randomize(9);
  UNTIL ( i = 0 ) or_else ( not gun_working[i] );

  IF ( i > 0 ) then
    BEGIN
      gun_working[i] := true;
      posn (i*4,21);
      qio_write ('^');
    END;
END;


PROCEDURE  Move;
VAR
  n : integer;
  out : v_array;
BEGIN
  IF ( command in ['1'..'9'] ) then
    create_shot;

{ delete shots }
  out := '';
  this_shot := head_shot;
  WHILE ( this_shot <> nil ) do
    BEGIN
      out := out + get_posn (this_shot^.x_posn,this_shot^.y_posn) + ' ';
      this_shot := this_shot^.next;
    END;
  qio_write (out);

{ replace shots }
  out := '';
  this_shot := head_shot;
  WHILE ( this_shot <> nil ) do
    BEGIN
      this_shot^.y_posn := this_shot^.y_posn - 1;
      IF ( this_shot^.y_posn <= 1 ) then
        delete_shot
      ELSE
        BEGIN
          shot_deleted := false;
          FOR n := 1 to max_aliens do
            IF ( this_shot <> nil ) then
              IF ( x_alien[n] = this_shot^.x_posn ) and
                 ( y_alien[n] = this_shot^.y_posn ) then
                BEGIN
                  alien_alive[n] := false;
                  delete_shot;
                  score := score + y_alien[n] div 2;
                  boom (n);
                END;
        END;

      IF not shot_deleted then
        BEGIN
          this_shot^.y_posn := this_shot^.y_posn - 1;
          IF ( this_shot^.y_posn <= 1 ) then
            delete_shot
          ELSE
            BEGIN
              shot_deleted := false;
              FOR n := 1 to max_aliens do
                IF ( this_shot <> nil ) then
                  IF ( x_alien[n] = this_shot^.x_posn ) and
                     ( y_alien[n] = this_shot^.y_posn ) then
                    BEGIN
                      alien_alive[n] := false;
                      delete_shot;
                      score := score + y_alien[n] div 2;
                      boom (n);
                    END;
              IF not shot_deleted then
                BEGIN
                  out := get_posn (this_shot^.x_posn,this_shot^.y_posn) + '|' + out;
                  this_shot := this_shot^.next;
                END;
            END;
        END;
    END;
  qio_write (out);
END;


PROCEDURE  Move_aliens;
VAR
  nu : integer;
  out: v_array;
BEGIN
  FOR nu := 1 to max_aliens do
    IF ( alien_alive[nu] ) then
      BEGIN
        out := get_posn (x_alien[nu],y_alien[nu]) + ' ';
        y_alien[nu] := y_alien[nu] + 1;
        IF ( x_alien[nu] = 2 ) then
          d_alien[nu] := 1;
        IF ( x_alien[nu] = 39 ) then
          d_alien[nu] := -1;
        x_alien[nu] := x_alien[nu] + d_alien[nu];

        shot_deleted := false;
        this_shot := head_shot;
        WHILE ( this_shot <> nil ) and not ( shot_deleted ) do
          BEGIN
            IF ( x_alien[nu] = this_shot^.x_posn ) and
               ( y_alien[nu] = this_shot^.y_posn ) then
              BEGIN
                alien_alive[nu] := false;
                delete_shot;
                score := score + y_alien[nu] div 2;
                qio_write (out);
                boom (nu);
              END;
            IF not shot_deleted then
              this_shot := this_shot^.next;
          END;

        IF not shot_deleted then
          IF ( y_alien[nu] = 21 ) then
            BEGIN
              alien_alive[nu] := false;
              qio_write ( out );
              IF ( x_alien[nu] mod 4 = 0 ) then
                BEGIN
                  gun_working[x_alien[nu] div 4] := false;
                  qio_write ( get_posn (x_alien[nu],21) + '*' );
                END;
            END
          ELSE
            qio_write ( out + get_posn (x_alien[nu],y_alien[nu]) + alien_type[nu] );
    END;
END;


FUNCTION  Person_killed : boolean;
VAR
  i : integer;
  temp : boolean := true;
BEGIN
  for i := 1 to 9 do
    if gun_working[i] then
      temp := false;
  person_killed := temp;
END;


PROCEDURE  Show_score;
BEGIN
  score := score - ( penality div 10 );
  penality := penality mod 10;
  IF score < 1 then 
    score := 1;
  posn (23,24);
  qio_write (dec(score)+' ');
END;


BEGIN
  Initialize;
  start_screen;
  setup;
  REPEAT
    sleep_start (20);
    show_score;
    get_command;
    move;
    create_aliens;
    move_aliens;
    posn (1,1);
    sleep_wait;
  UNTIL person_killed or ( upper_case(command) = 'Q' );
  qio_purge;
  clear;
  top_ten (score);
END.
