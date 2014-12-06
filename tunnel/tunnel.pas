[
  Inherit 
    (
      'SYS$LIBRARY:STARLET',
      'INTERACT'
    )
]

PROGRAM  Tunnel ( input , output );

TYPE
  Pointer = ^list;
  list    = Record
               left_side  : integer;
               right_side : integer;
               prev       : pointer;
               next       : pointer;
            End;
  v_array = varying [256] of char;
VAR
  x_posn        : integer;
  score         : integer;
  command       : char;
  game_over     : boolean;
  head          : pointer;
  this          : pointer;
  line          : pointer;
  width         : integer;


PROCEDURE  Handler ( exitreason : integer := 1 );
BEGIN
  reset_screen;
  clear;
  qio_write (vt100_esc+'[?5l');
END;


PROCEDURE  Finish;
BEGIN
  reset_screen;
  qio_write (vt100_esc+'[?5l');
  qio_purge;
  clear;
  top_ten (score);
END;


PROCEDURE  Setup;
VAR
  i : integer;
BEGIN
  clear;
  posn (1,1);
  qio_write (vt100_esc+'[?5h');
  qio_write (vt100_esc+'[7m');
  FOR i := 1 to 23 do
    qio_writeln (vt100_wide+'                                        ');
  x_posn := 20;
  NEW (head);
  this := head;
  FOR i := 1 to 22 do
    BEGIN
      NEW (line);
      this^.next := line;
      line^.prev := this;
      this := line;
      line^.left_side := 1;
      line^.right_side := 40;
    END;
  head^.left_side := 1;
  head^.right_side := 40;
  head^.prev := line;
  line^.next := head;
  width := 10;
  this^.left_side := 16;
  this^.right_side := 26;
  posn (this^.left_side+1,24);
  qio_write (vt100_wide);
  FOR i := 1 to width do
    qio_write (' ');
  qio_write (vt100_esc+'D'+vt100_wide);
  posn (x_posn,1);
  qio_write ('O');
END;


PROCEDURE  Initialize;
BEGIN
  image_dir;
  show_graphedt ('tunnel.pic');
  score := 0;
  Setup_handler(iaddress(handler));
  Force;
END;


PROCEDURE  Get_command;
VAR
  last : char;
BEGIN
  last := command;
  command := qio_1_char_now;
  IF ( command = chr(-1) ) then
    command := last;
END;


PROCEDURE  Move;
VAR
  i : integer;
  outline : v_array;
BEGIN
  score := score + 1;
  this := this^.next;

  IF command = '1' then
    x_posn := x_posn - 1
  ELSE
  IF command = '3' then
    x_posn := x_posn + 1;

  game_over := ( this^.next^.left_side >= x_posn ) or
               ( this^.next^.right_side <= x_posn );

  CASE random(2) of
    1 : IF ( this^.prev^.left_side > 2 ) then
         this^.left_side := this^.prev^.left_side - 1
        ELSE
          this^.left_side := this^.prev^.left_side + 1;
    2 : IF ( this^.prev^.left_side + width < 38 ) then
          this^.left_side := this^.prev^.left_side + 1
        ELSE
          this^.left_side := this^.prev^.left_side - 1;
  End;

  this^.right_side := this^.left_side + width + 1;

  outline := '';
  FOR i := 1 to width do
    outline := outline + ' ';
  outline := vt100_esc+'[24;'+dec(this^.left_side+1)+'H'+
             outline +
             vt100_esc+'D'+vt100_wide+
             vt100_esc+'[;'+dec(x_posn)+'HO'+
             vt100_cr+dec(score);
  qio_write (outline);
END;


BEGIN
  Initialize;
  setup;
  REPEAT
    sleep_start (width);
    get_command;
    move;
    sleep_wait;
    IF ( (score mod 200) = 0 ) then
      BEGIN
        qio_write (chr(7));
        width := width - 1;
      END;
  UNTIL ( game_over ) or ( upper(command) = 'Q' );
  No_handler;
  Finish;
END.
