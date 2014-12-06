[
  Inherit 
    (
      'SYS$LIBRARY:STARLET',
      'INTERACT'
    )
]

PROGRAM  Chicken ( input , output );

CONST
  max_chickens = 5;
  max_shots = 5;
  space   = 0;
  chicken = 1;
  player  = 2;
  shot    = 3;
  wall    = 4;
  top = 1;
  bot = 23;
  lef = 5;
  rig = 40;
  shoot = ' ';

VAR
  x_posn        : integer;
  y_posn        : integer;
  direct        : integer;
  screen        : array [lef..rig,top..bot] of integer;
  x_chicken     : array [1..max_chickens] of integer;
  y_chicken     : array [1..max_chickens] of integer;
  d_chicken     : array [1..max_chickens] of integer;
  chicken_alive : array [1..max_chickens] of boolean;
  command       : char;
  l_score       : integer;
  score         : integer;
  person_killed : boolean;
  x_shot        : array [1..max_shots] of integer;
  y_shot        : array [1..max_shots] of integer;
  d_shot        : array [1..max_shots] of integer;
  shot_alive    : array [1..max_shots] of boolean;
  beep          : boolean := true;


PROCEDURE Refresh_screen;
VAR
  i, y : integer;
BEGIN
  clear;
  FOR y := top to bot do
    BEGIN
      posn (1,y);
      qio_write (VT100_wide);
    END;
  Square (lef,top,rig,bot);
  FOR i := 1 to max_chickens do
    IF chicken_alive[i] then
      BEGIN
        posn (x_chicken[i],y_chicken[i]);
        qio_write ('C');
      END;
  posn (x_posn,y_posn);
  qio_write (VT100_graphics_on+'`'+VT100_graphics_off);
END;


PROCEDURE  Setup;
VAR
  i, x, y, r : integer;
BEGIN
  command := ' ';
  clear;
  FOR y := top to bot do
    BEGIN
      posn (1,y);
      qio_write (VT100_wide);
    END;
  Square (lef,top,rig,bot);

  FOR x := lef to rig do
    screen[x,top] := wall;
  FOR x := lef to rig do
    screen[x,bot] := wall;
  FOR y := top to bot do
    screen[lef,y] := wall;
  FOR y := top to bot do
    screen[rig,y] := wall;

  FOR i := 1 to max_chickens do
    chicken_alive[i] := false;
  FOR i := 1 to max_shots do
    shot_alive[i] := false;
  person_killed := false;

  x_posn := random(rig-lef-11)+lef+5;
  y_posn := random(bot-top-11)+top+5;
  direct := random(8);
  IF direct > 4 then
    direct := direct + 1;

  posn (1,2);
  qio_write ('0');
END;


PROCEDURE  Initialize;
BEGIN
  image_dir;
  show_graphedt ('chicken.pic');
  score := 0;
  l_score := 0;
END;


PROCEDURE  Get_command;
BEGIN
  command := qio_1_char_now;
  IF ( Upper_case(command) = 'W' ) then
    refresh_screen;
END;


PROCEDURE  Move_in_square ( VAR x, y, d : integer );
BEGIN
  IF ( d in [1,2,3] ) and ( screen[x,y+1] = wall ) then
    d := d + 6;
  IF ( d in [7,8,9] ) and ( screen[x,y-1] = wall ) then
    d := d - 6;
  IF ( d in [1,4,7] ) and ( screen[x-1,y] = wall ) then
    d := d + 2;
  IF ( d in [3,6,9] ) and ( screen[x+1,y] = wall ) then 
    d := d - 2;

  IF ( d in [1,2,3] ) then
    y := y + 1;
  IF ( d in [7,8,9] ) then
    y := y - 1;
  IF ( d in [1,4,7] ) then
    x := x - 1;
  IF ( d in [3,6,9] ) then
    x := x + 1;
END;


PROCEDURE  Create_shot;
VAR
  n : integer;
BEGIN
  n := 1;
  WHILE ( n < max_shots ) and ( shot_alive[n] ) do
    n := n + 1;
  IF not ( shot_alive[n] ) then
    BEGIN
      shot_alive[n] := true;
      x_shot[n] := x_posn;
      y_shot[n] := y_posn;
      d_shot[n] := direct;
      screen[x_posn,y_posn] := shot;
    END;
END;


PROCEDURE  Find_delete_shot ( x, y : integer );
VAR
  n : integer;
BEGIN
  FOR n := 1 to max_shots do
    IF ( x_shot[n] = x ) and ( y_shot[n] = y ) then
      shot_alive[n] := false;
END;

  
PROCEDURE  Find_and_kill_chicken ( x, y : integer );
VAR
  i : integer;
BEGIN
  FOR i := 1 to max_chickens do
    IF ( x_chicken[i] = x ) and ( y_chicken[i] = y ) then
      chicken_alive[i] := false;
END;


PROCEDURE  Move_shots;
VAR
  n : integer;
BEGIN
{ step 1 }
  FOR n := 1 to max_shots do
    IF ( shot_alive[n] ) then
      BEGIN
        screen [x_shot[n],y_shot[n]] := space;
        posn (x_shot[n],y_shot[n]);
        qio_write (' ');

        move_in_square ( x_shot[n],y_shot[n],d_shot[n] );

        IF ( screen [x_shot[n],y_shot[n]] = player ) then
          BEGIN
            person_killed := true;
            find_delete_shot(x_shot[n],y_shot[n]);
          END
        ELSE
        IF ( screen [x_shot[n],y_shot[n]] = shot ) then
          BEGIN
            screen [x_shot[n],y_shot[n]] := space;
            find_delete_shot(x_shot[n],y_shot[n]);
            posn (x_shot[n],y_shot[n]);
            qio_write (' ');
          END
        ELSE
        IF ( screen [x_shot[n],y_shot[n]] = chicken ) then
          BEGIN
            shot_alive[n] := false;
            find_and_kill_chicken (x_shot[n],y_shot[n]);
            screen [x_shot[n],y_shot[n]] := space;
            posn (x_shot[n],y_shot[n]);
            qio_write (' ');
            score := score + 5;
          END
        ELSE
          screen [x_shot[n],y_shot[n]] := shot;
    END;
{ step 2 }
  FOR n := 1 to max_shots do
    IF ( shot_alive[n] ) then
      BEGIN
        screen [x_shot[n],y_shot[n]] := space;

        move_in_square ( x_shot[n],y_shot[n],d_shot[n] );

        IF ( screen [x_shot[n],y_shot[n]] = player ) then
          BEGIN
            person_killed := true;
            find_delete_shot(x_shot[n],y_shot[n]);
          END            
        ELSE
        IF ( screen [x_shot[n],y_shot[n]] = shot ) then
          BEGIN
            screen [x_shot[n],y_shot[n]] := space;
            find_delete_shot(x_shot[n],y_shot[n]);
            posn (x_shot[n],y_shot[n]);
            qio_write (' ');
          END
        ELSE
        IF ( screen [x_shot[n],y_shot[n]] = chicken ) then
          BEGIN
            shot_alive[n] := false;
            find_and_kill_chicken (x_shot[n],y_shot[n]);
            screen [x_shot[n],y_shot[n]] := space;
            posn (x_shot[n],y_shot[n]);
            qio_write (' ');
            score := score + 5;
          END
        ELSE
          BEGIN
            screen [x_shot[n],y_shot[n]] := shot;
            posn (x_shot[n],y_shot[n]);
            qio_write ('.');
          END;
    END;
END;


PROCEDURE  Move;
BEGIN
  posn (x_posn,y_posn);
  qio_write (' ');
  screen[x_posn,y_posn] := space;

  CASE command of
    'B' : beep   := not beep;
    '1' : direct := 1;
    '2' : direct := 2;
    '3' : direct := 3;
    '4' : direct := 4;
    '6' : direct := 6;
    '7' : direct := 7;
    '8' : direct := 8;
    '9' : direct := 9;
    otherwise;
  End; {case}

  move_in_square ( x_posn,y_posn,direct );

  IF ( screen[x_posn,y_posn] = chicken ) then
    person_killed := true
  ELSE
  IF ( screen[x_posn,y_posn] = shot ) then
    person_killed := true
  ELSE
    BEGIN
      posn (x_posn,y_posn);
      qio_write ('*');
      screen [x_posn,y_posn] := player;
    END;
END;


FUNCTION  Corner_too_close ( r : integer ) : boolean;
BEGIN
  Corner_too_close :=
    (( r = 1 ) and ( x_posn < lef+5 ) and ( y_posn < top+5 )) or
    (( r = 2 ) and ( x_posn > rig-5 ) and ( y_posn < top+5 )) or
    (( r = 3 ) and ( x_posn < lef+5 ) and ( y_posn > bot-5 )) or
    (( r = 4 ) and ( x_posn > rig-5 ) and ( y_posn > bot-5 ));
END;


PROCEDURE  Create_chickens;
VAR
  nu : integer;
  n  : integer;
  r  : integer;
BEGIN
  nu := ( score div 50 ) + 1;
  IF ( nu > max_chickens ) then
    nu := max_chickens;

  IF ( nu > 0 ) then
    BEGIN
      n := 1;
      WHILE ( n < nu ) and ( chicken_alive[n] ) do
        n := n + 1;
      IF not ( chicken_alive[n] ) then
        BEGIN
          IF beep then
            qio_write (chr(7));
          chicken_alive[n] := true;
          reset_randomizer;
          REPEAT
            r := random(4);
          UNTIL ( NOT corner_too_close(r) );
          CASE r of
            1 : BEGIN
                  x_chicken[n] := lef+1;
                  y_chicken[n] := top+1;
                END;
            2 : BEGIN
                  x_chicken[n] := rig-1;
                  y_chicken[n] := top+1;
                END;
            3 : BEGIN
                  x_chicken[n] := lef+1;
                  y_chicken[n] := bot-1;
                END;
            4 : BEGIN
                  x_chicken[n] := rig-1;
                  y_chicken[n] := bot-1;
                END;
          End;
          d_chicken[n] := random(8);
          IF d_chicken[n] > 4 then
            d_chicken[n] := d_chicken[n] + 1;
        END;
    END;
END;


PROCEDURE  Turn_chickens ( x , y : integer );
VAR
  i : integer;
BEGIN
  FOR i := 1 to max_chickens do
    IF ( chicken_alive[i] ) and 
       ( x_chicken[i] = x ) and ( y_chicken[i] = y ) then
      BEGIN
        d_chicken[i] := random(8);
        IF d_chicken[i] > 4 then
          d_chicken[i] := d_chicken[i] + 1;
      END;
END;


PROCEDURE  Move_chickens;
VAR
  nu : integer;
  r : integer;
BEGIN
  FOR nu := 1 to max_chickens do
    IF ( chicken_alive[nu] ) then
      BEGIN
        screen [x_chicken[nu],y_chicken[nu]] := space;
        posn (x_chicken[nu],y_chicken[nu]);
        qio_write (' ');

        move_in_square ( x_chicken[nu],y_chicken[nu],d_chicken[nu] );

        IF ( screen [x_chicken[nu],y_chicken[nu]] = player ) then
          person_killed := true
        ELSE
        IF ( screen [x_chicken[nu],y_chicken[nu]] = shot ) then
          BEGIN
            chicken_alive[nu] := false;
            screen [x_chicken[nu],y_chicken[nu]] := space;
            find_delete_shot(x_chicken[nu],y_chicken[nu]);
            posn (x_chicken[nu],y_chicken[nu]);
            qio_write (' ');
            score := score + 5;
          END
        ELSE
        IF ( screen [x_chicken[nu],y_chicken[nu]] = chicken ) then
          turn_chickens (x_chicken[nu],y_chicken[nu])
        ELSE
          BEGIN
            screen [x_chicken[nu],y_chicken[nu]] := chicken;
            posn (x_chicken[nu],y_chicken[nu]);
            qio_write ('C');
          END;
    END;
END;


BEGIN
  Initialize;
  setup;
  REPEAT
    sleep_start(20);
    get_command;
    move;
    IF not person_killed then
      IF ( command = shoot ) then
        create_shot;
    IF not person_killed then
      move_shots;
    IF not person_killed then
      create_chickens;
    IF not person_killed then
      move_chickens;
    IF l_score <> score then
      BEGIN
        posn (1,2);
        qio_write (dec(score));
        l_score := score;
      END;
    posn (1,1);
    sleep_wait;
  UNTIL ( person_killed ) or ( upper_case(command) = 'Q' );
  qio_purge;
  clear;
  top_ten (score);
END.
