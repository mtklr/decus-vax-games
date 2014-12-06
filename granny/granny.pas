[
  Inherit 
    (
      'SYS$LIBRARY:STARLET',
      'INTERACT'
    )
]

PROGRAM  Granny;

CONST
  max_victims = 20;
  black  = 'B';
  child  = 'C';
  dog    = 'D';
  granny = 'G';
  mother = 'M';
  police = 'P';
  building  = 50;
  building1 = 100;
  building2 = 200;
  building3 = 300;
  building4 = 400;
  building5 = 500;
  building6 = 600;
  building7 = 700;
  building8 = 800;
  building9 = 900;
  road     = 0;
  beep     = chr(7);

TYPE
  v_array  = varying [100] of char;

VAR
  x_posn        : integer;
  y_posn        : integer;
  direct        : integer;
  score         : integer;
  screen        : array [1..40,1..21] of integer;
  command       : char;
  person_killed : boolean;
  victim        : array [1..max_victims] of char;
  victim_x      : array [1..max_victims] of integer;
  victim_y      : array [1..max_victims] of integer;
  victim_d      : array [1..max_victims] of integer;
  victim_o      : array [1..max_victims] of integer;
  odd_even      : boolean;


PROCEDURE  Finish;
BEGIN
  reset_screen;
  qio_purge;
  clear;
  top_ten (score);
END;


PROCEDURE Refresh_screen;
VAR
  i, x, y, r : integer;
BEGIN
  command := ' ';
  show_graphedt ('granny.scn',wait:=false);
  posn (x_posn,y_posn);
  qio_write (VT100_graphics_on+'`'+VT100_graphics_off);
END;


PROCEDURE  Setup;
VAR
  i, x, y, r : integer;
BEGIN
  For x := 1 to 40 do
    BEGIN
      screen[x,1] := building1;
      screen[x,2] := building1;
      screen[x,20] := building2;
      screen[x,21] := building2;
    END;
  For y := 1 to 20 do
    BEGIN
      screen[1,y] := building3;
      screen[2,y] := building3;
      screen[39,y] := building4;
      screen[40,y] := building4;
    END;
  For x := 8 to 19 do
    BEGIN
      screen[x,6] := building5;
      screen[x,7] := building5;
      screen[x,8] := building5;
      screen[x,9] := building5;
      screen[x,13] := building6;
      screen[x,14] := building6;
      screen[x,15] := building6;
      screen[x,16] := building6;
    END;
  For x := 24 to 34 do
    BEGIN
      screen[x,6] := building7;
      screen[x,7] := building7;
      screen[x,8] := building7;
      screen[x,9] := building7;
      screen[x,13] := building8;
      screen[x,14] := building8;
      screen[x,15] := building8;
      screen[x,16] := building8;
    END;

  For x := 17 to 26 do
    For y := 8 to 14 do
      screen[x,y] := road;

  For x := 20 to 23 do
    For y := 10 to 12 do
      screen[x,y] := building9;

  For i := 1 to max_victims do
    victim[i] := ' ';

  x_posn := 22;
  y_posn := 18;
  direct := 5;
  refresh_screen;
END;


PROCEDURE  Initialize;
BEGIN
  show_graphedt ('granny.pic');
  score := 0;
END;


PROCEDURE  Get_command;
BEGIN
  command := qio_1_char_now;
  IF ( Upper_case(command) = 'W' ) then
    refresh_screen;
END;


PROCEDURE  Check_for_victim;
VAR
  i : integer;
BEGIN
  For i := 1 to max_victims do
    IF ( victim[i] <> ' ' ) and 
       ( victim_x[i] = x_posn ) and ( victim_y[i] = y_posn ) then
      BEGIN
        CASE victim[i] of
          granny : BEGIN
                     score := score + 100;
                     posn (16,22);
                     qio_write ('Gota Granny'+beep);
                     victim[i] := ' ';
                   END;
          mother : BEGIN
                     score := score + 25;
                     posn (16,22);
                     qio_write ('Gota Mother'+beep);
                     victim[i] := ' ';
                   END;
          black  : BEGIN
                     score := score + 50;
                     posn (16,22);
                     qio_write ('Gota Bonus '+beep);
                     victim[i] := ' ';
                   END;
          child  : BEGIN
                     score := score + 20;
                     posn (16,22);
                     qio_write ('Hit The Kid'+beep);
                     victim[i] := ' ';
                   END;
          dog    : BEGIN
                     score := score + 10;
                     posn (16,22);
                     qio_write ('Dog Gone   '+beep);
                     victim[i] := ' ';
                   END;
          police : BEGIN
                     show_graphedt ('granny.jai',wait:=false);
                     sleep (2);
                     person_killed := true;
                   END;
          otherwise;
        End;
      END;
END;


PROCEDURE  Move;
BEGIN
  posn (24,23);
  qio_write (dec(score));

  CASE command of
    '2' : direct := 2;
    '4' : direct := 4;
    '6' : direct := 6;
    '8' : direct := 8;
    otherwise;
  End;

  posn (x_posn,y_posn);
  CASE direct of
    2 : BEGIN
          qio_write (' '+VT100_lf+VT100_bs+VT100_graphics_on+'`'+VT100_graphics_off);
          y_posn := y_posn + 1;
        END;
    4 : BEGIN
          qio_write (' '+VT100_bs+VT100_bs+VT100_graphics_on+'`'+VT100_graphics_off);
          x_posn := x_posn - 1;
        END;
    6 : BEGIN
          qio_write (' '+VT100_graphics_on+'`'+VT100_graphics_off);
          x_posn := x_posn + 1;
        END;
    8 : BEGIN
          qio_write (' '+VT100_bs+VT100_esc+'[A'+VT100_graphics_on+'`'+VT100_graphics_off);
          y_posn := y_posn - 1;
        END;
    otherwise;
  End; {case}

  IF ( screen[x_posn,y_posn] > building ) then
    person_killed := true;

  check_for_victim;
END;


FUNCTION  Possible_door ( x , y : integer; VAR origin : integer ) : boolean;
VAR
  i : integer;
  j : integer;
BEGIN
  possible_door := false;
  IF ( screen[x,y] = road ) then
    FOR i := -1 to 1 do
      FOR j := -1 to 1 do
        IF ( screen[x+i,y+j] > building ) then
          BEGIN
            possible_door := true;
            origin := screen[x+i,y+j];
          END;
END;


PROCEDURE  Move_in_square ( VAR x, y, d : integer );
BEGIN
  IF ( d in [1,2,3] ) then
    y := y + 1;
  IF ( d in [7,8,9] ) then
    y := y - 1;
  IF ( d in [1,4,7] ) then
    x := x - 1;
  IF ( d in [3,6,9] ) then
    x := x + 1;
END;


FUNCTION  Move_onto_street ( x,y,d : integer ) : boolean;
BEGIN
  move_in_square ( x,y,d );
  move_onto_street := ( screen [x,y] = road );
END;


PROCEDURE  Picka ( VAR victim : char );
VAR
  r : integer;
BEGIN
  r := random(15);
  IF r < 2 then
    victim := granny
  ELSE
  IF r < 6 then
    victim := dog
  ELSE
  IF r < 9 then
    victim := child
  ELSE
  IF r < 11 then
    victim := black
  ELSE
  IF r < 14 then
    victim := mother
  ELSE
    victim := police;
END;


PROCEDURE  Create_victim;
VAR
  nu : integer;
  n  : integer;
BEGIN
  nu := ( score div 100 ) + 3;
  IF nu > max_victims then
    nu := max_victims;

  n := 1;
  WHILE ( n < nu ) and ( victim[n] <> ' ' ) do
    n := n + 1;
  IF ( n <= nu ) and ( victim[n] = ' ' ) then
    BEGIN
      picka (victim[n]);
      REPEAT
        victim_x[n] := random(38)+1;
        victim_y[n] := random(19)+1;
      UNTIL ( possible_door(victim_x[n],victim_y[n],victim_o[n]) and 
            (( victim[n] <> police ) or
           ((( victim_x[n] > x_posn + 2 ) or ( victim_x[n] < x_posn - 2 )) or
            (( victim_y[n] > y_posn + 2 ) or ( victim_y[n] < y_posn - 2 )))));
      reset_randomizer;
      REPEAT
        victim_d[n] := randomize(8);
        IF victim_d[n] > 4 then
          victim_d[n] := victim_d[n] + 1;
      UNTIL ( move_onto_street ( victim_x[n],victim_y[n],victim_d[n] ) );
    END;
END;


PROCEDURE  Turn_and_run ( VAR d : integer );
VAR
  r : integer;
BEGIN
  reset_randomizer;
  REPEAT
    r := randomize(8);
      IF r > 4 then
        r := r + 1;
   UNTIL ( r <> d );
  d := r;
END;


PROCEDURE  Move_victims;
VAR
  nu : integer;
  r : integer;
  x : integer;
  y : integer;
  d : integer;
  outline : v_array;
BEGIN
  odd_even := not odd_even;
  FOR nu := 1 to max_victims do
    BEGIN
      outline := '';
      IF ( victim[nu] = '~' ) then
        BEGIN
          outline := outline + 
              get_posn (victim_x[nu],victim_y[nu]) + VT100_inverse + ' ' + VT100_normal;
          victim[nu] := ' ';
        END
      ELSE
      IF (( odd(nu) and odd_even ) or ( not odd(nu) and not odd_even )) and
       ( victim[nu] <> ' ' ) then
        BEGIN
          outline := outline + get_posn (victim_x[nu],victim_y[nu]) + ' ';
  
          r := random(3);
          IF r = 1 then
            BEGIN
              victim_d[nu] := random(8);
              IF victim_d[nu] > 4 then
                victim_d[nu] := victim_d[nu] + 1;
            END;
          x := victim_x[nu];
          y := victim_y[nu];
          d := victim_d[nu];
          move_in_square ( x,y,d );
          WHILE (( x = x_posn ) and ( y = y_posn ) and 
                not ( victim[nu] = police )) or ( screen[x,y] = victim_o[nu] ) do
            BEGIN
              turn_and_run ( victim_d[nu] );
              x := victim_x[nu];
              y := victim_y[nu];
              d := victim_d[nu];
              move_in_square ( x,y,d );
            END;
  
          move_in_square ( victim_x[nu],victim_y[nu],victim_d[nu] );
   
          IF ( screen [victim_x[nu],victim_y[nu]] > building ) then
            victim[nu] := '~';
  
          outline := outline + get_posn (victim_x[nu],victim_y[nu]) + victim[nu];
      END;
      qio_write (outline);
    END;
END;

BEGIN
  Initialize;
  setup;
  REPEAT
    sleep_start (20);
    get_command;
    move;
    IF not person_killed then
      BEGIN
        create_victim;
        move_victims;
        posn (1,1);
        sleep_wait;
      END;
  UNTIL ( person_killed ) or ( upper_case(command) = 'Q' );
  Finish;
END.
