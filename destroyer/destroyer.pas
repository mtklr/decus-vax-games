{****************************************************************************


               D E S T R O Y E R    S U P E R    L E A G U E .
               -----------------------------------------------

                Written By  :  Paul Seo Shuen Hwa.  20 May 1981
                               University of Waikato.
                Modified By :  Paul Denize. 11 Oct 1988
                               Royal New Zealand Navy


 ****************************************************************************}

[ Inherit ('INTERACT') ]

PROGRAM  Destroyer;

TYPE
  maxrow      = 0..24;
  maxcolumn   = 0..81;
  movelist    = (up, speedup, thrustup, down, speeddown, thrustdown, stop);
  courselist  = (highest, high, low, lowest, missed);

  misseltype  = Record
                  strikingcourse : courselist;
                  course : maxrow;
                  column : maxcolumn;
                  tag : boolean
                End;

  guntype     = Record
                  move : movelist;
                  row : maxrow
                End;

  alientype   = Record
                  column : maxcolumn;
                  tag : boolean                {still alive}
                End;

VAR
  missel1, missel2 : misseltype;
  gun1, gun2       : guntype;
  aliennumber      : 0..6;
  alien            : array [1..8] of alientype;
  ch               : char;
  score            : integer;
  lives            : integer;
  energy           : integer;
  first            : boolean;
  quit             : boolean;


PROCEDURE  show_screen;
VAR
  i : maxcolumn;
BEGIN
  clear;
  posn (1,1);
  qio_write ('Lasers<* <* <*        Score : '+dec(Score,,5)+'         Energy : '+dec(Energy,,4)+'        Lasers*> *> *>');
  show_graphedt('Destroyer.Scn',wait:=false);
END;

PROCEDURE  alien_fire;

    PROCEDURE  firealienmissel;
    VAR
      r : integer;
    BEGIN
      r := random(8);
      IF not alien[r].tag then
        BEGIN
          alien[r].tag := true;
          IF r <= 4 then
            alien[r].column := 2
          ELSE
            alien[r].column := 77;
          aliennumber := aliennumber + 1;
        END;
    END;

BEGIN
  IF (aliennumber < 2) or
     ((score > 200) and (aliennumber < 3)) or
     ((score > 2000) and (aliennumber < 4)) or
     ((score > 7000) and (aliennumber < 5)) or
     ((score > 10000) and (aliennumber < 6)) then
    firealienmissel;
END;

PROCEDURE  missel1strike(row : maxrow; column, aliencolumn : maxcolumn);
BEGIN
  IF (column - aliencolumn) > 1 then
    BEGIN
      posn (aliencolumn,row);
      QIO_write (VT100_graphics_on+pad('','q',(column - aliencolumn))+VT100_graphics_off);
    END;
  posn (aliencolumn,row);
  QIO_write ('*'+VT100_bs);
  QIO_write (pad('',' ',max(0,(column - aliencolumn + 1)))+'<*');
  aliennumber := aliennumber - 1;
  score := score + 32 + 33 - aliencolumn;
  posn (31,1);
  qio_write (dec(score,,5))
END;

PROCEDURE  missel2strike(row : maxrow; column, aliencolumn : maxcolumn);
BEGIN
  IF (aliencolumn - column) > 1 then
    BEGIN
      posn (column,row);
      QIO_write (VT100_graphics_on+pad('','q',(aliencolumn - column))+VT100_graphics_off)
    END;
  posn (aliencolumn,row);
  QIO_write ('*');
  posn (45,row);
  QIO_write (pad('*>',' ',max(0,(aliencolumn - column + 3))));
  aliennumber := aliennumber - 1;
  score := score + 32 - 47 + aliencolumn;
  posn (31,1);
  qio_write (dec(score,,5))
END;

PROCEDURE  missel1missed(row : maxrow; column : maxcolumn);
BEGIN
  posn (3,row);
  QIO_write (VT100_graphics_on+'qqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqq'+VT100_graphics_off);
  posn (3,row);
  QIO_write ('                               <*');
  energy := energy - 10;
  posn (54,1);
  qio_write (dec(Energy,,4))
END;

PROCEDURE  missel2missed(row : maxrow; column : maxcolumn);
BEGIN
  posn (column,row);
  QIO_write (VT100_graphics_on+'qqqqqqqqqqqqqqqqqqqqqqqqqqqqqqq'+VT100_graphics_off);
  posn (45,row);
  QIO_write ('*>                               ');
  energy := energy - 10;
  posn (54,1);
  qio_write (dec(Energy,,4))
END;

PROCEDURE  move_missel1;
BEGIN
  missel1.tag := false;
  CASE missel1.strikingcourse of
    highest : IF alien[1].tag then
                BEGIN
                  missel1strike(5, missel1.column, alien[1].column);
                  alien[1].tag := false;
                END
              ELSE
                missel1missed(5, missel1.column);
    high    : IF alien[2].tag then
                BEGIN
                  missel1strike(10, missel1.column, alien[2].column);
                  alien[2].tag := false;
                END
              ELSE
                missel1missed(10, missel1.column);
    low     : IF alien[3].tag then
                BEGIN
                  missel1strike(15, missel1.column, alien[3].column);
                  alien[3].tag := false;
                END
              ELSE
                missel1missed(15, missel1.column);
    lowest  : IF alien[4].tag then
                BEGIN
                  missel1strike(20, missel1.column, alien[4].column);
                  alien[4].tag := false;
                END
              ELSE
                missel1missed(20, missel1.column);
    missed  : missel1missed(missel1.course, missel1.column);
  END;
END;

PROCEDURE  move_missel2;
BEGIN
  missel2.tag := false;
  CASE missel2.strikingcourse of
    highest : IF alien[5].tag then
                BEGIN
                  missel2strike(5, missel2.column, alien[5].column);
                  alien[5].tag := false;
                END
              ELSE
                missel2missed(5, missel2.column);
    high    : IF alien[6].tag then
                BEGIN
                  missel2strike(10, missel2.column, alien[6].column);
                  alien[6].tag := false;
                END
              ELSE
                missel2missed(10, missel2.column);
    low     : IF alien[7].tag then
                BEGIN
                  missel2strike(15, missel2.column, alien[7].column);
                  alien[7].tag := false;
                END
              ELSE
                missel2missed(15, missel2.column);
    lowest  : IF alien[8].tag then
                BEGIN
                  missel2strike(20, missel2.column, alien[8].column);
                  alien[8].tag := false;
                END
              ELSE
                missel2missed(20, missel2.column);
    missed  : missel2missed(missel2.course, missel2.column);
  END;
END;

PROCEDURE  firemissel1;
BEGIN
  CASE gun1.row of
    0,1,2,3,4  : missel1.strikingcourse := missed;
    5          : missel1.strikingcourse := highest;
    6, 7, 8, 9 : missel1.strikingcourse := missed;
    10         : missel1.strikingcourse := high;
    11,12,13,14: missel1.strikingcourse := missed;
    15         : missel1.strikingcourse := low;
    16,17,18,19: missel1.strikingcourse := missed;
    20         : missel1.strikingcourse := lowest;
    21,22,23,24: missel1.strikingcourse := missed;
  END;
  missel1.column := 33;
  missel1.tag := true;
  missel1.course := gun1.row;
  move_missel1;
END;

PROCEDURE  firemissel2;
BEGIN
  CASE gun2.row of
    0,1,2,3,4  : missel2.strikingcourse := missed;
    5          : missel2.strikingcourse := highest;
    6, 7, 8, 9 : missel2.strikingcourse := missed;
    10         : missel2.strikingcourse := high;
    11,12,13,14: missel2.strikingcourse := missed;
    15         : missel2.strikingcourse := low;
    16,17,18,19: missel2.strikingcourse := missed;
    20         : missel2.strikingcourse := lowest;
    21,22,23,24: missel2.strikingcourse := missed;
  END;
  missel2.tag := true;
  missel2.column := 47;
  missel2.course := gun2.row;
  move_missel2;
END;

PROCEDURE  defendcommand;
BEGIN
  CASE ORD(QIO_1_char_now) of
    49 : CASE gun1.move of
           up         : gun1.move := down;
           speedup    : gun1.move := up;
           thrustup   : gun1.move := speedup;
           down       : gun1.move := speeddown;
           speeddown  : gun1.move := thrustdown;
           thrustdown : gun1.move := thrustdown;
           stop       : gun1.move := down;
         END;
    50 : gun1.move := stop;
    51 : CASE gun2.move of
           up         : gun2.move := down;
           speedup    : gun2.move := up;
           thrustup   : gun2.move := speedup;
           down       : gun2.move := speeddown;
           speeddown  : gun2.move := thrustdown;
           thrustdown : gun2.move := thrustdown;
           stop       : gun2.move := down;
         END;
    52 : firemissel1;
    54 : firemissel2;
    55 : CASE gun1.move of
           up         : gun1.move := speedup;
           speedup    : gun1.move := thrustup;
           thrustup   : gun1.move := thrustup;
           down       : gun1.move := up;
           speeddown  : gun1.move := down;
           thrustdown : gun1.move := speeddown;
           stop       : gun1.move := up;
         END;
    56 : gun2.move := stop;
    57 : CASE gun2.move of
           up         : gun2.move := speedup;
           speedup    : gun2.move := thrustup;
           thrustup   : gun2.move := thrustup;
           down       : gun2.move := up;
           speeddown  : gun2.move := down;
           thrustdown : gun2.move := speeddown;
           stop       : gun2.move := up;
         END;
    81, 113 : quit := true;
    otherwise;
  END;
END;

PROCEDURE  defendmove;
VAR
  i : 0..6;

    PROCEDURE  movegun1up ( n : integer );
    VAR
      i : integer;
    BEGIN
      FOR i := 1 to n do
        BEGIN
          IF gun1.row = 3 then
            gun1.move := stop
          ELSE
            BEGIN
              posn (34,gun1.row - 1);
              QIO_write ('<*');
              posn (34,gun1.row);
              QIO_write ('  ');
              gun1.row := gun1.row - 1;
            END;
          defendcommand;
        END;
    END;

    PROCEDURE  movegun1down ( n : integer );
    VAR
      i : integer;
    BEGIN
      FOR i := 1 to n do
        BEGIN
          IF gun1.row = 22 then
            gun1.move := stop
          ELSE
            BEGIN
              posn (34,gun1.row + 1);
              QIO_write ('<*');
              posn (34,gun1.row);
              QIO_write ('  ');
              gun1.row := gun1.row + 1;
            END;
          defendcommand;
        END;
    END;

    PROCEDURE  movegun2up ( n : integer );
    VAR
      i : integer;
    BEGIN
      FOR i := 1 to n do
        BEGIN
          IF gun2.row = 3 then
            gun2.move := stop
          ELSE
            BEGIN
              posn (45,gun2.row - 1);
              QIO_write ('*>');
              posn (45,gun2.row);
              QIO_write ('  ');
              gun2.row := gun2.row - 1;
            END;
          defendcommand;
        END;
    END;

    PROCEDURE  movegun2down ( n : integer );
    VAR
      i : integer;
    BEGIN
      FOR i := 1 to n do
        BEGIN
          IF gun2.row = 22 then
            gun2.move := stop
          ELSE
            BEGIN
              posn (45,gun2.row + 1);
              QIO_write ('*>');
              posn (45,gun2.row);
              QIO_write ('  ');
              gun2.row := gun2.row + 1;
            END;
          defendcommand;
        END;
    END;

BEGIN
  CASE gun1.move of
    up         : movegun1up (1);
    speedup    : movegun1up (2);
    thrustup   : movegun1up (3);
    down       : movegun1down (1);
    speeddown  : movegun1down (2);
    thrustdown : movegun1down (3);
    stop       :;
  END;
  CASE gun2.move of
    up         : movegun2up (1);
    speedup    : movegun2up (2);
    thrustup   : movegun2up (3);
    down       : movegun2down (1);
    speeddown  : movegun2down (2);
    thrustdown : movegun2down (3);
    stop       :;
  END
END;

PROCEDURE  baseexploded;
BEGIN
  show_graphedt ('Destroyer.die',wait:=false);
  lives := lives - 1;
  IF lives = 2 then
    qio_writeln (VT100_graphics_off+get_posn(1,1)+'Laser <* <*           Score : '+dec(Score,,5)+'         Energy : '+dec(Energy,,4)+'        Laser *> *>   ')
  ELSE
  IF lives = 1 then
    qio_writeln (VT100_graphics_off+get_posn(1,1)+'Laser <*              Score : '+dec(Score,,5)+'         Energy : '+dec(Energy,,4)+'        Laser *>      ');
  IF lives > 0 then
    BEGIN
      show_graphedt('Destroyer.scn',wait:=false);
      aliennumber := 0;
      missel1.tag := false;
      missel2.tag := false;
      alien := zero;
      gun1.move := stop;
      gun2.move := stop;
      gun1.row := 12;
      gun2.row := 12;
      first := false;
      QIO_Purge;
    END
END;

PROCEDURE  alien_move;
VAR
  i : integer;

    PROCEDURE  movealien(column1, column2 : maxcolumn; course : maxrow);
    BEGIN
      posn (column2,course);
      QIO_write ('#');
      posn (column1,course);
      QIO_write (' ')
    END;

BEGIN
  FOR i := 1 to 4 do
    IF alien[i].tag then
      IF alien[i].column = 35 then
        baseexploded
      ELSE
        BEGIN
          movealien(alien[i].column, alien[i].column + 1, 5*i);
          alien[i].column := alien[i].column + 1
        END;

  FOR i := 5 to 8 do
    IF alien[i].tag then
      IF alien[i].column = 46 then
        baseexploded
      ELSE
        BEGIN
          movealien(alien[i].column, alien[i].column - 1, 5*(i-4));
          alien[i].column := alien[i].column - 1
        END;
END;

PROCEDURE  initialised;
BEGIN
  Reset_screen;
  quit := false;
  show_graphedt('Destroyer.hlp');
  lives := 3;
  energy := 1000;
  score := 0;
  aliennumber := 0;
  missel1.tag := false;
  missel2.tag := false;
  alien := zero;
  gun1.move := stop;
  gun2.move := stop;
  gun1.row := 12;
  gun2.row := 12;
  first := false
END;

BEGIN
  initialised;
  show_screen;
  while (lives > 0) and not quit do
    BEGIN
      sleep_start (50);
      defendcommand;
      defendmove;
      defendcommand;
      alien_fire;
      alien_move;
      IF score > 5000 then
        alien_move;
      IF score > 12000 then
        alien_move;
      sleep_wait;
      IF energy < 0 then
        BEGIN
          baseexploded;
          lives := 0;
        END
    END;
  top_ten(score);
END.
