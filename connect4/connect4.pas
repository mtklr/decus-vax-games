[ Inherit ('INTERACT') ]

PROGRAM Connect4;

TYPE
  also      = (all,some);
  v_array   = varying [256] of char;
  string    = varying [20]  of char;
  filename  = varying [16]  of char;

VAR
  moves       : integer;
  last_move_x : integer;
  last_move_y : integer;
  size        : integer;
  len         : integer;
  score       : integer;
  point       : array [0..9,0..9] of char;
  best_move   : Record
                  x      : integer;
                  y      : integer;
                  pri    : integer;
                  size   : integer;
                  follow : integer;
                END;
  ret         : char;
  it          : string;


PROCEDURE  scrollup;
{ scrolls picture up }
BEGIN
  qio_write ( VT100_Esc + 'D' );
END; { scrollup }


PROCEDURE  Split_screen;
BEGIN
  qio_write ( VT100_Esc + '[19;23r' );
END; { split }


PROCEDURE  Split_off;
BEGIN
  qio_write ( VT100_Esc + '[1;24r' );
  posn ( 1,23 );
END; { split }


PROCEDURE Drawscreen;
VAR
  i : integer;
BEGIN
  clear;
  posn (11,2);
  qio_write ( VT100_top + 'Connect  4');
  posn (11,3);
  qio_write ( VT100_bottom + 'Connect  4');

  posn (11,7);
  qio_write ( VT100_wide );
  qio_write ( VT100_graphics_on );
  qio_write ('l');
  FOR i := 1 to 8 do
    qio_write ('q');
  qio_write ('k');
  FOR i := 1 to 8 do
    BEGIN
      posn (11,7+i);
      qio_write ( VT100_wide );
      qio_write ('x');
      posn (20,7+i);
      qio_write ('x');
    END;
  posn (11,16);
  qio_write ( VT100_wide );
  qio_write ('m');
  FOR i := 1 to 8 do
    qio_write ('q');
  qio_write ('j');
  qio_write ( VT100_graphics_off );
  posn (12,17);
  qio_write ( VT100_wide );
  FOR i := 1 to 8 do
    qio_write ( dec(i) );
END; { Drawscreen }


PROCEDURE Setup;
VAR
  i : integer;
  j : integer;
BEGIN
  image_dir;
  FOR i := 1 to 8 do
    FOR j := 1 to 8 do
      point [i,j] := ' ';
  drawscreen;
  split_screen;
END; { Setup }


PROCEDURE Screen ( a, b : integer; ch : char );
BEGIN
  point [a,b] := ch;
  posn (11+a,16-b);
  qio_write (ch);
END; { Screen }


PROCEDURE First_turn;
VAR
  ran : integer;
BEGIN
  moves := 1;
  ran := random(8);
  screen (ran,1,'X');
  posn (20,23);
  qio_write ('Computers move  : ' + dec(ran));
  scrollup;
END; { First_turn }


FUNCTION Down_count ( x, y : integer; ch : char ) : integer;
BEGIN
  IF ( y=0 ) or ( point[x,y]<>ch ) then 
    down_count := 0
  ELSE
    down_count := down_count(x,y-1,ch) + 1;
END; { Down_count }


FUNCTION Left_count ( x, y : integer; ch : char ) : integer;
BEGIN
  IF ( x=0 ) or ( point[x,y]<>ch ) then 
    left_count := 0
  ELSE
    left_count := left_count(x-1,y,ch) + 1;
END; { Left_count }


FUNCTION Right_count ( x, y : integer; ch : char ) : integer;
BEGIN
  IF ( x=9 ) or ( point[x,y]<>ch ) then 
    right_count := 0
  ELSE
    right_count := right_count(x+1,y,ch) + 1;
END; { Right_count }


FUNCTION Up_L_count ( x, y : integer; ch : char ) : integer;
BEGIN
  IF ( y=9 ) or ( x=0 ) or ( point[x,y]<>ch ) then 
    up_l_count := 0
  ELSE
    up_l_count := up_l_count(x-1,y+1,ch) + 1;
END; { Up_L_count }


FUNCTION Down_R_count ( x, y : integer; ch : char ) : integer;
BEGIN
  IF ( y=0 ) or ( x=9 ) or ( point[x,y]<>ch ) then 
    down_r_count := 0
  ELSE
    down_r_count := down_r_count(x+1,y-1,ch) + 1;
END; { Down_count }


FUNCTION UP_R_count ( x, y : integer; ch : char ) : integer;
BEGIN
  IF ( y=9 ) or ( x=9 ) or ( point[x,y]<>ch ) then 
    up_r_count := 0
  ELSE
    up_r_count := up_r_count(x+1,y+1,ch) + 1;
END; { UP_R_count }


FUNCTION Down_L_count ( x, y : integer; ch : char ) : integer;
BEGIN
  IF ( y=0 ) or ( x=0 ) or ( point[x,y]<>ch ) then 
    down_l_count := 0
  ELSE
    down_l_count := down_l_count(x-1,y-1,ch) + 1;
END; { Down_L_count }


FUNCTION Priority ( x, y : integer; info : also ) : integer;
VAR
  i : integer;
  k : integer;

        PROCEDURE Number_check ( n, p : integer; ch : char );
        BEGIN
          IF ( down_count(x,y-1,ch) >= n ) or
             ( left_count(x-1,y,ch) + right_count(x+1,y,ch) >= n ) or
             ( up_l_count(x-1,y+1,ch) + down_r_count(x+1,y-1,ch) >= n ) or
             ( up_r_count(x+1,y+1,ch) + down_l_count(x-1,y-1,ch) >= n ) then
            priority := p;
        END; { Number_check }


        FUNCTION Total_count ( ch : char ) : integer;
        BEGIN
          total_count := down_count(x,y-1,ch) + 
                         left_count(x-1,y,ch) + right_count(x+1,y,ch) +
                         up_l_count(x-1,Y+1,ch) + down_r_count(x+1,Y-1,ch) +
                         up_r_count(x+1,Y+1,ch) + down_l_count(x-1,y-1,ch);
        END;

{ priority code begins, NOTE computer 'X' }

BEGIN
  priority := 10;
{ number check ( eg below ) 4 = priority given if row of 1 'O's is found }
  Number_check(1,4,'O');
  Number_check(2,3,'X');
  Number_check(2,2,'O');
  Number_check(3,1,'O');
  Number_check(3,0,'X');

  { side affect if all infomation required }

  IF ORD(info)=0 then
    size := total_count('X');
END; { priority }


FUNCTION correct_priority ( x, y : integer; quant : integer ) : boolean;
VAR
  i : integer;
  k : integer;

        PROCEDURE Check ( n : integer; ch : char );
        BEGIN
          IF ( down_count(x,y-1,ch) >= n ) or
             ( left_count(x-1,y,ch) + right_count(x+1,y,ch) >= n ) or
             ( up_l_count(x-1,y+1,ch) + down_r_count(x+1,y-1,ch) >= n ) or
             ( up_r_count(x+1,y+1,ch) + down_l_count(x-1,y-1,ch) >= n ) then
            correct_priority := true;
        END; { Number_check }

{ priority code begins, NOTE computer 'X' }

BEGIN
  correct_priority := false;
  IF ( quant=0 ) then check(3,'X');
  IF ( quant=1 ) then check(3,'O');
END; { correct_priority }


FUNCTION Count_length ( x, y : integer ) : integer;
VAR
  len : integer;
  tot_len : integer;

BEGIN
  tot_len := 0;
  len := (down_count(x,y,'O'));
  IF ( len>3 ) then tot_len := len;
  len := (left_count(x-1,y,'O')+right_count(x+1,y,'O')+1);
  IF ( len>3 ) then tot_len := tot_len + len;
  len := (up_l_count(x-1,y+1,'O')+down_r_count(x+1,y-1,'O')+1);
  IF ( len>3 ) then tot_len := tot_len + len;
  len := (up_r_count(x+1,y+1,'O')+down_l_count(x-1,y-1,'O')+1);
  IF ( len>3 ) then tot_len := tot_len + len;
  count_length := tot_len;
END; { Count_length }


FUNCTION Player_won : boolean;
BEGIN
  player_won := correct_priority (last_move_x,last_move_y,1);
END; { player_won }


FUNCTION Computer_won : boolean;
BEGIN
  Computer_won := correct_priority (best_move.x,best_move.y,0);
END; { computer_won }


PROCEDURE Refresh_screen;
VAR
  a, b : integer;
BEGIN
  FOR a := 1 to 8 do
    FOR b := 1 to 8 do
      IF ( point[a,b]<>' ' ) then
        screen(a,b,point[a,b]);
END; { Refresh_screen }


PROCEDURE Players_turn;
VAR
  ch : char;
 a,b :integer;
BEGIN
  REPEAT
    REPEAT
      posn (20,23);
      qio_write ('Your move (1-8) : ');
      ch := upper_case(qio_1_char);
      last_move_x := ORD(ch) - ORD('0');
      qio_write ( ch );
      scrollup;
      IF ( ch='I' ) then 
        BEGIN
          reset_screen;
          show_graphedt ('CONNECT4.PIC');
          drawscreen;
          refresh_screen;
          split_screen;
        END;
      IF ( last_move_x<1 ) or ( last_move_x>8 ) and ( ch<>'I' ) then
        BEGIN
          posn (20,23);
          qio_write ('? WHAT ?');
          scrollup;
        END;
    UNTIL ( last_move_x>=1 ) and ( last_move_x<=8 );
    last_move_y := 0;
    REPEAT
      last_move_y := last_move_y + 1;
    UNTIL ( point[last_move_x,last_move_y]=' ' ) or ( last_move_y=8 );
    IF ( point[last_move_x,last_move_y]<>' ' ) then
      BEGIN
        posn (20,23);
        qio_write ('* FULL *');
        scrollup;
      END;
  UNTIL ( point[last_move_x,last_move_y]=' ' );
  screen (last_move_x,last_move_y,'O');
  moves := moves + 1;
END; { Players_turn }



PROCEDURE Computers_turn;
VAR
  i : integer;
  j : integer;
  k : integer;
  dumb_move : boolean;
  randomize : array [1..8] of integer;
BEGIN
  posn (20,23);
  qio_write ('Computers move  : ');
  best_move.pri := 20;
  FOR i := 1 to 8 do 
    BEGIN
      j := 0;
      REPEAT
        j := j + 1;
      UNTIL ( point[i,j]=' ' ) or ( j=8 );
      IF ( point[i,j]=' ' ) then
        IF ( priority(i,j,all)<best_move.pri ) or
           (( priority(i,j,all)=best_move.pri ) and 
           ( size>best_move.size )) then
          BEGIN
            dumb_move := false;
            IF ( j<8 ) then
              BEGIN
                IF ( correct_priority(i,j+1,1) ) and 
                      not( priority(i,j,some)=0 ) then
                  dumb_move := true;
                IF ( priority(i,j,some)>1 ) and 
                    ( priority(i,j+1,some)=0 ) then
                  dumb_move := true;
              END;
            IF not dumb_move then
              BEGIN
                WITH best_move do
                  BEGIN
                    x := i;
                    y := j;
                    pri := priority (i,j,all);
                  END;
                  best_move.size := size;
              END;
          END;
    END;
  IF ( best_move.pri=20 ) then
    BEGIN
      FOR j := 1 to 8 do
        randomize[j] := 0;
      k := 0;
      REPEAT
        WITH best_move do
          BEGIN
            REPEAT
              x := random(8);
            UNTIL ( x<>randomize[1] ) and ( x<>randomize[2] ) and
                  ( x<>randomize[3] ) and ( x<>randomize[4] ) and
                  ( x<>randomize[5] ) and ( x<>randomize[6] ) and
                  ( x<>randomize[7] );
            k := k + 1;
            randomize[k] := x;
            j := 0;
            REPEAT
              j := j + 1;
            UNTIL ( point[k,j]=' ' ) or ( j=8 );
            IF ( point[k,j]=' ' ) then
              y := j;
          END;
      UNTIL ( point[k,j]=' ' );
      best_move.x := k;
      best_move.y := j;
    END;
  qio_write ( dec(best_move.x));
  scrollup;
  screen ( best_move.x,best_move.y,'X');
  moves := moves + 1;
END; { Computers_turn }


PROCEDURE Play_game;
VAR
  first : char;
BEGIN
  posn (19,23);
  qio_write ('Type I for instructions');
  scrollup;
  REPEAT
    posn (20,23);
    qio_write ('Can I go first (Y/N) :');
    first := upper_case (qio_1_char);
    qio_write ( first );
    scrollup;
    IF ( first='I' ) then 
      BEGIN
        reset_screen;
        show_graphedt ('CONNECT4.PIC');
        drawscreen;
        split_screen;
      END;
  UNTIL ( first='Y' ) or ( first='N' );
  moves := 1;
  IF ( first='Y' ) then
    first_turn
  ELSE
    moves := 0;
  REPEAT
    IF ( moves<64 ) then
      players_turn;
    IF not player_won and ( moves<64 ) then
      computers_turn;
  UNTIL ( moves=64 ) or player_won or computer_won;
END; { Play_game }


{ MAIN BODY }


BEGIN
  setup;
  play_game;
  posn (20,23);
  IF computer_won then
    BEGIN
      qio_write ('I win.  Better luck next time!!!');
      score := 0;
    END
  ELSE
    IF player_won then
      BEGIN
        qio_write ('Congratulations.  You have won.');
        score := ((( 64-moves )* (count_length (last_move_x,last_move_y)))
                     div 4);
      END
    ELSE
      BEGIN
        qio_write ('A draw.  Try harder next time.');
        score := 0;
      END;
  scrollup;
  scrollup;
  posn (20,23);
  IF ( score>0 ) then
    BEGIN
      qio_write ( VT100_Bright + VT100_flash + 'Press  < Return >' );
      posn (1,1);
      ret := qio_1_char;
      qio_write ( VT100_Normal );
      reset_screen;
      top_ten (score);
    END
  ELSE
    BEGIN
      reset_screen;
      posn (1,23);
    END;
END. { Connect4 }
