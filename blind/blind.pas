[
  Inherit 
    (
      'SYS$LIBRARY:STARLET',
      'INTERACT'
    )
]

PROGRAM  Blind;

TYPE { creating screen }
  tunnel_pointer = ^tunneler;
  tunneler       = Record;
                     x_posn : integer;
                     y_posn : integer;
                     prev   : tunnel_pointer;
                     next   : tunnel_pointer;
                   End;

VAR { creating screen }
  stack_tunneler  : tunnel_pointer;
  head_tunneler  : tunnel_pointer;
  this_tunneler  : tunnel_pointer;
  up    : boolean;
  down  : boolean;
  left  : boolean;
  right : boolean;


VAR { general }
  a : integer;
  b : integer;
  c : integer;
  i : integer;
  screen  : array [0..20,0..12] of integer;
  x_posn  : integer;
  y_posn  : integer;
  command : char;
  score   : integer;
  timer   : integer;


PROCEDURE  Create_tunneler ( x , y : integer );
VAR
  new_tunneler : tunnel_pointer;
BEGIN
  IF ( stack_tunneler <> nil ) then
    BEGIN
      new_tunneler := stack_tunneler;
      stack_tunneler := stack_tunneler^.next;
    END
  ELSE
    NEW ( new_tunneler );

  new_tunneler^.x_posn := x;
  new_tunneler^.y_posn := y;
  new_tunneler^.prev := nil;
  new_tunneler^.next := head_tunneler;

  IF ( head_tunneler <> nil ) then
    head_tunneler^.prev := new_tunneler;
  head_tunneler := new_tunneler;
END;


PROCEDURE  Delete_tunneler;
BEGIN
  IF ( this_tunneler^.prev = nil ) then
    head_tunneler := head_tunneler^.next
  ELSE
    this_tunneler^.prev^.next := this_tunneler^.next;

  IF ( this_tunneler^.next <>  nil ) then
    this_tunneler^.next^.prev := this_tunneler^.prev;

  this_tunneler^.next := stack_tunneler;  
  stack_tunneler := this_tunneler;
  this_tunneler := this_tunneler^.prev;
END;


FUNCTION  Cant_move_from ( x , y : integer ) : Boolean;
BEGIN
  up    := ( screen[x,y-1] = 1 );
  down  := ( screen[x,y+1] = 1 );
  left  := ( screen[x-1,y] = 1 );
  right := ( screen[x+1,y] = 1 );
  cant_move_from := not ( up or down or left or right );
END;


PROCEDURE  Tunnel_from ( VAR x , y : integer );
BEGIN
  IF cant_move_from(x,y) then
    delete_tunneler
  ELSE
    BEGIN
      c := random (2);
      IF ( c = 1 ) then
        BEGIN
          Create_tunneler (x,y);
          c := random (2);
          IF ( c = 1 ) then
            Create_tunneler (x,y);
        END;
      Reset_randomizer;
      REPEAT
        c := randomize (4);
      UNTIL (( c = 1 ) and up   ) or (( c = 2 ) and down  ) or
            (( c = 3 ) and left ) or (( c = 4 ) and right );

      CASE c of
        1 : screen[x,y] := screen[x,y] * 3;
        2 : screen[x,y] := screen[x,y] * 5;
        3 : screen[x,y] := screen[x,y] * 7;
        4 : screen[x,y] := screen[x,y] * 11;
      End;

      CASE c of
        1 : screen[x,y-1] := screen[x,y-1] * 5;
        2 : screen[x,y+1] := screen[x,y+1] * 3;
        3 : screen[x-1,y] := screen[x-1,y] * 11;
        4 : screen[x+1,y] := screen[x+1,y] * 7;
      End;

      CASE c of
        1 : y := y - 1;
        2 : y := y + 1;
        3 : x := x - 1;
        4 : x := x + 1;
      End;

    END;
END;


PROCEDURE  Exhaust_tunnelers;
BEGIN
  WHILE ( head_tunneler <> nil ) do
    BEGIN
      this_tunneler := head_tunneler;
      WHILE ( this_tunneler <> nil ) do
        BEGIN
          tunnel_from ( this_tunneler^.x_posn , this_tunneler^.y_posn );
          IF ( this_tunneler = nil ) then
            this_tunneler := head_tunneler
          ELSE
            this_tunneler := this_tunneler^.next;
        END;
    END;
END;


PROCEDURE  Tunnel;
BEGIN
  Create_tunneler (x_posn,y_posn);
  Exhaust_tunnelers;

  FOR a := 1 to 19 do
    FOR b := 1 to 11 do
      IF ( screen[a,b] <> 1 ) then
        Create_tunneler (a,b);
  Exhaust_tunnelers;
END;


PROCEDURE  Setup_screen;
BEGIN
  FOR a := 1 to 19 do
    FOR b := 1 to 11 do
      screen[a,b] := 1;

  FOR a := 0 to 20 do
    BEGIN
      screen[a,0]  := 100;
      screen[a,12] := 100;
    END;
  FOR a := 0 to 12 do
    BEGIN
      screen[0,a]  := 100;
      screen[20,a] := 100;
    END;
END;


PROCEDURE  Initialize;
BEGIN
  show_graphedt ('blind.ins');
  clear;
  setup_screen;
  x_posn := random(19);
  y_posn := random(11);
  tunnel;
  show_graphedt ('blind.pic',wait:=false);
  command := ' ';
  posn (x_posn*2,y_posn*2);
  qio_write ('*');
  score := 0;
  timer := 0;
END;


PROCEDURE  Get_command;
BEGIN
  command := qio_1_char_now;
END;


PROCEDURE  Move;
BEGIN

  CASE command of
    '2' : IF (( screen[x_posn,y_posn] mod 5 ) = 0 ) then
            BEGIN
              posn ((x_posn*2),(y_posn*2));
              qio_write (' ');
              posn ((x_posn*2),(y_posn*2)+1);
              qio_write (' ');
              posn ((x_posn*2),(y_posn*2)+2);
              qio_write ('*');
              y_posn := y_posn + 1;
            END;
    '4' : IF (( screen[x_posn,y_posn] mod 7 ) = 0 ) then
            BEGIN
              posn ((x_posn*2)-2,(y_posn*2));
              qio_write ('*  ');
              x_posn := x_posn - 1;
            END;
    '6' : IF (( screen[x_posn,y_posn] mod 11 ) = 0 ) then
            BEGIN
              posn ((x_posn*2),(y_posn*2));
              qio_write ('  *');
              x_posn := x_posn + 1;
            END;
    '8' : IF (( screen[x_posn,y_posn] mod 3 ) = 0 ) then
            BEGIN
              posn ((x_posn*2),(y_posn*2));
              qio_write (' ');
              posn ((x_posn*2),(y_posn*2)-1);
              qio_write (' ');
              posn ((x_posn*2),(y_posn*2)-2);
              qio_write ('*');
              y_posn := y_posn - 1;
            END;
    otherwise;
  End; {case}

  IF ( (screen[x_posn,y_posn] mod 13 ) <> 0 ) then
    BEGIN
      screen[x_posn,y_posn] := screen[x_posn,y_posn] * 13;
      score := score + 1;
    END;
END;


BEGIN
  Initialize;
  REPEAT
    sleep_start (10);
    timer := timer + 1;
    get_command;
    move;
    posn (15,24);
    qio_write (dec(Score));
    posn (25,24);
    qio_write (dec(1000-timer)+'   ');
    posn (1,1);
    sleep_wait;
  UNTIL ( timer = 1000 ) or ( upper_case(command) = 'Q' );
  qio_purge;
  clear;
  top_ten (score);
END.
