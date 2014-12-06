[
  Inherit 
    (
      'SYS$LIBRARY:STARLET',
      'INTERACT'
    )
]

PROGRAM  Mole;

CONST
  number_of_aliens = 10;
  dirt = 1;
  rock = 2;
  gold = 3;
  wall = 4;
  dirt_percentage = 92;
  rock_percentage = 3;
  { the rest is gold, Yippee }

VAR
  x_posn        : integer;
  y_posn        : integer;
  rock_x        : integer;
  rock_y        : integer;
  score         : integer;
  gold_here     : integer;
  start_score   : integer;
  screen        : array [1..40,1..20] of integer;
  x_alien       : array [1..number_of_aliens] of integer;
  y_alien       : array [1..number_of_aliens] of integer;
  rock_fall     : boolean;
  person_killed : boolean;
  alien_alive   : array [1..number_of_aliens] of boolean;
  command       : char;


FUNCTION  Max ( a,b,c,d : integer ) : integer;
VAR
  temp : integer;
BEGIN
  temp := -100000;
  IF ( a <= 0 ) and ( a > temp ) then temp := a;
  IF ( b <= 0 ) and ( b > temp ) then temp := b;
  IF ( c <= 0 ) and ( c > temp ) then temp := c;
  IF ( d <= 0 ) and ( d > temp ) then temp := d;
  max := temp;
END;


PROCEDURE  Finish;
BEGIN
  reset_screen;
  qio_purge;
  clear;
  top_ten (score div 10);
END;


PROCEDURE Refresh_screen;
VAR
  i, x, y, r : integer;
BEGIN
  command := ' ';
  clear;
  qio_write (VT100_inverse);
  FOR y := 1 to 20 do
    posn (1,y);
  FOR y := 1 to 20 do
    BEGIN
      posn (1,y);
      qio_write (VT100_wide);
    END;
  FOR y := 1 to 20 do
    BEGIN
      posn (1,y);
      FOR x := 1 to 40 do
        BEGIN
          IF ( screen [x,y] = wall ) then
            qio_write ('#')
          ELSE
          IF ( screen [x,y] in [dirt,gold] ) then
            qio_write (' ')
          ELSE
          IF ( screen [x,y] = rock ) then
            qio_write ( VT100_normal + VT100_graphics_on + '`' + VT100_graphics_off + VT100_inverse )
          ELSE
            qio_write ( VT100_normal + ' ' + VT100_inverse );
        END;
    END;
  qio_write (VT100_normal);
  posn (32,22);
  qio_write ('SCORE : ');
  posn (x_posn,y_posn);
  qio_write ('*');
END;


PROCEDURE  Setup;
VAR
  i, x, y, r : integer;
BEGIN
  command := ' ';
  gold_here := 0;
  clear;
  qio_write (VT100_inverse);
  FOR y := 1 to 20 do
    BEGIN
      posn (1,y);
      qio_write (VT100_wide);
      FOR x := 1 to 40 do
        BEGIN
          r := random (100);
          IF ( x = 1 ) or ( x = 40 ) or ( y = 1 ) or ( y = 20 ) then
            BEGIN
              screen [x,y] := wall;
              qio_write ('#');
            END
          ELSE
          IF ( r < dirt_percentage ) then
            BEGIN
              screen [x,y] := dirt;
              qio_write (' ');
            END
          ELSE
          IF ( r < dirt_percentage + rock_percentage + ((20-y) div 5)) 
               and ( y < 19 ) and ( screen[x,y-1] <> rock ) then
            BEGIN
              screen [x,y] := rock;
              qio_write ( VT100_normal + VT100_graphics_on + '`' + VT100_graphics_off + VT100_inverse );
            END
          ELSE
            BEGIN
              screen [x,y] := gold;
              gold_here := gold_here + 1;
              qio_write (' ');
            END;
        END;
    END;

  FOR i := 1 to number_of_aliens do
    alien_alive[i] := false;

  x_posn := 20;
  y_posn := 10;
  screen [x_posn,y_posn-1] := dirt;
  posn (x_posn,y_posn-1);
  qio_write (' ');
  qio_write (VT100_normal);
  start_score := score;
  posn (32,22);
  qio_write ('SCORE : ');
  posn (x_posn,y_posn);
  qio_write ('*');

END;


PROCEDURE  Initialize;
BEGIN
  show_graphedt ('mole.pic');
  score := 1;
END;


PROCEDURE  Get_command;
VAR
  last : char;
BEGIN
  last := command;
  command := qio_1_char_now;
  IF ( command = chr(-1) ) then
    command := last;
  IF ( Upper_case(command) = 'W' ) then
    refresh_screen;
END;


PROCEDURE  Move;
BEGIN
  IF ( screen[x_posn,y_posn-1] = rock ) and ( command in ['2','4','6'] ) then
    BEGIN
      rock_fall := true;
      rock_x := x_posn;
      rock_y := y_posn-1;
    END;

  CASE command of
    '2' : IF not ( screen [x_posn,y_posn+1] in [rock,wall] ) then
            BEGIN
              posn (x_posn,y_posn);
              qio_write (' '+VT100_lf+VT100_bs+'*');
              y_posn := y_posn + 1;
            END;
    '4' : IF not ( screen [x_posn-1,y_posn] in [rock,wall] ) then
            BEGIN
              posn (x_posn-1,y_posn);
              qio_write ('* ');
              x_posn := x_posn - 1;
            END;
    '6' : IF not ( screen [x_posn+1,y_posn] in [rock,wall] ) then
            BEGIN
              posn (x_posn,y_posn);
              qio_write (' *');
              x_posn := x_posn + 1;
            END;
    '8' : IF not ( screen [x_posn,y_posn-1] in [rock,wall] ) then
            BEGIN
              posn (x_posn,y_posn-1);
              qio_write ('*'+VT100_lf+VT100_bs+' ');
              y_posn := y_posn - 1;
            END;
    otherwise;
  End; {case}

  CASE ( screen [x_posn,y_posn] ) of
     dirt : BEGIN
              score := score + 1;
              IF (score mod 10) = 0 Then
                BEGIN
                  posn (40,22);
                  qio_write (dec(score div 10));
                END;
            END;
     gold : BEGIN
              score := score + 10;
              posn (40,22);
              qio_write (dec(score div 10));
              gold_here := gold_here - 1;
            END;
     otherwise;
  End; {case}

  IF ( rock_fall ) and ( x_posn = rock_x ) and ( y_posn - 1 = rock_y ) then
    rock_fall := false;

  screen [x_posn,y_posn] := 0;
END;


PROCEDURE  Drop_rock;
VAR
  nu : integer;
BEGIN
  screen [rock_x,rock_y] := 0;
  REPEAT
    sleep ( frac := 0.02 );
    posn (rock_x,rock_y);
    qio_write (' ');
    rock_y := rock_y + 1;
    posn (rock_x,rock_y);
    qio_write (VT100_graphics_on+'`'+VT100_graphics_off);
    FOR nu := 1 to number_of_aliens do
      IF ( alien_alive[nu] ) then
        IF ( rock_x = x_alien[nu] ) and ( rock_y = y_alien[nu] ) then
          BEGIN
            alien_alive[nu] := false;
            score := score + 200;
            posn (40,22);
            qio_write (dec(score div 10));
          END;
    IF ( rock_x = x_posn ) and ( rock_y = y_posn ) then
      person_killed := true;
  UNTIL ( screen[rock_x,rock_y+1] > 0 );

  rock_fall := false;
  posn (rock_x,rock_y);
  qio_write (' ');
END;


PROCEDURE  Create_aliens;
VAR
  nu : integer;
  n  : integer;
BEGIN
  CASE ((score - start_score) div 30 ) of
    0 : nu := 0;
    1 : nu := 1;
    otherwise nu := (((score- start_score) div 500) + 1);
  End; {case}

  IF ( nu > number_of_aliens ) then
    nu := number_of_aliens;

  IF ( nu > 0 ) and not (( x_posn in [15..25] ) and ( y_posn in [7..13] )) then
    BEGIN
      n := 1;
      WHILE ( n < nu ) and ( alien_alive[n] ) do
        n := n + 1;
      IF not ( alien_alive[n] ) then
        BEGIN
          alien_alive[n] := true;
          x_alien[n] := 20;
          y_alien[n] := 10;
        END;
    END;
END;


PROCEDURE  Move_aliens;
VAR
  nu : integer;
  slime_depth : integer;
  x , y : integer;
  i, r : integer;
  ok : boolean;
  count : integer;
  number_times : integer;

    FUNCTION  Clear_path ( x1 , y1 , x2 , y2 : integer ) : boolean;
    VAR
      temp : boolean;
    BEGIN
      temp := ( screen[x1,y1] <= 0 );
      IF temp then
        temp := ( x2 > 0 ) and ( x2 < 41 ) and ( y1 > 0 ) and ( y2 < 21 );
      IF temp then
        temp := ( screen[x2,y2] < 0 ) and ( screen[x2,y2] > slime_depth );
      clear_path := temp;
    END;

BEGIN
  FOR nu := 1 to number_of_aliens do
    BEGIN
      IF ( alien_alive[nu] ) then
        BEGIN
          r := random(5);
          IF ( r <> 1 ) or ( x_alien[nu] > x_posn + 2 ) or
                           ( x_alien[nu] < x_posn - 2 ) or
                           ( y_alien[nu] > y_posn + 2 ) or
                           ( y_alien[nu] < y_posn - 2 ) then
            BEGIN
              IF ( x_alien[nu] > x_posn + 5 ) or
                 ( x_alien[nu] < x_posn - 5 ) or
                 ( y_alien[nu] > y_posn + 5 ) or
                 ( y_alien[nu] < y_posn - 5 ) then
                number_times := 2
              ELSE              
                number_times := 1;

              FOR count := 1 to number_times do
                BEGIN
                  x := x_alien[nu];
                  y := y_alien[nu];
                  IF ( x_posn = x ) and ( y_posn = y ) then
                    person_killed := true;
                  slime_depth := Max ( screen[x-1,y],
                                       screen[x+1,y],
                                       screen[x,y-1],
                                       screen[x,y+1]);
                  screen [x,y] := slime_depth - 1;
                  IF ( count = 1 ) then
                    BEGIN
                      ok := true;
                      FOR i := 1 to number_of_aliens do
                        IF alien_alive[i] and (i <> nu) and (x = x_alien[i]) and (y = y_alien[i]) Then
                          ok := false;
                      IF ok Then
                        BEGIN
                          posn (x,y);
                          qio_write (' ');
                        END;
                    END;

                  Reset_randomizer;
                  REPEAT
                    r := randomize (4);
                  UNTIL (( r = 1 ) and ( x_posn < x ) and ( screen[x-1,y] = slime_depth )) or
                        (( r = 2 ) and ( x_posn > x ) and ( screen[x+1,y] = slime_depth )) or
                        (( r = 3 ) and ( y_posn < y ) and ( screen[x,y-1] = slime_depth )) or
                        (( r = 4 ) and ( y_posn > y ) and ( screen[x,y+1] = slime_depth )) or
                        ( r = 0 );
                  IF ( r = 0 ) then
                    BEGIN
                      Reset_randomizer;
                      REPEAT
                        r := randomize (4);
                      UNTIL (( r = 1 ) and ( x_posn < x ) and ( clear_path ( x-1,y,x-2,y ))) or
                            (( r = 2 ) and ( x_posn > x ) and ( clear_path ( x+1,y,x+2,y ))) or
                            (( r = 3 ) and ( y_posn < y ) and ( clear_path ( x,y-1,x,y-2 ))) or
                            (( r = 4 ) and ( y_posn > y ) and ( clear_path ( x,y+1,x,y+2 ))) or
                            ( r = 0 );
                      IF ( r = 0 ) then
                        BEGIN
                          Reset_randomizer;
                          REPEAT
                            r := randomize (4);
                          UNTIL (( r = 1 ) and ( screen[x-1,y] = slime_depth )) or
                                (( r = 2 ) and ( screen[x+1,y] = slime_depth )) or
                                (( r = 3 ) and ( screen[x,y-1] = slime_depth )) or
                                (( r = 4 ) and ( screen[x,y+1] = slime_depth ));
                        END;
                    END;
                  CASE r of
                    1 : x_alien[nu] := x - 1;                                
                    2 : x_alien[nu] := x + 1;                                
                    3 : y_alien[nu] := y - 1;                                
                    4 : y_alien[nu] := y + 1;                                
                  End; {case}

                  x := x_alien[nu];
                  y := y_alien[nu];
                  screen [x,y] := slime_depth - 1;
                  IF ( number_times = count ) then
                    BEGIN
                      ok := true;
                      FOR i := 1 to number_of_aliens do
                        IF alien_alive[i] and (i <> nu) and (x = x_alien[i]) and (y = y_alien[i]) Then
                          ok := false;
                      IF ok Then
                        BEGIN
                          posn (x,y);
                          qio_write ('#');
                        END;
                    END;
                  IF ( x_posn = x ) and ( y_posn = y ) then
                    person_killed := true;
                END;
            END;
        END;
    END;
END;


BEGIN
  Initialize;
  setup;
  REPEAT
    IF ( gold_here < 4 ) then
      setup;
    sleep_start (20);
    get_command;
    move;
    IF rock_fall then
      drop_rock;
    create_aliens;
    move_aliens;
    posn (1,1);
    sleep_wait;
  UNTIL ( person_killed ) or ( upper_case(command) = 'Q' );
  Finish;
END.
