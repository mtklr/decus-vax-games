[ Inherit ('INTERACT') ]

program catch;

TYPE 
    string2 = packed array[1..2] of char;

VAR i,j,x,y,numberstar,
    think,score,mult,
    howmanystar :integer;
    esc,direction       :char;
    grid                :array[0..18,0..18] of char;
    ranvalue            :real;
    finish,catch        :boolean;
    timeran             :packed array[1..11] of char;


PROCEDURE help;
BEGIN
  posn (11,1);
  clear;
  qio_writeln ('          Welcome to catch');
  qio_writeln ('          ~~~~~~~~~~~~~~~~~');
  qio_writeln ('The idea of the game is to move the # about');
  qio_writeln ('the box , shown on the  screen , using  the');
  qio_writeln ('following keys-');
  qio_writeln (VT100_graphics_on);
  qio_writeln ('                l   ^   k');
  qio_writeln ('                 \  x  /');
  qio_writeln ('                  7 8 9');
  qio_writeln ('                <q4   6q>');
  qio_writeln ('                  1 2 3');
  qio_writeln ('                 /  x  \');
  qio_writeln ('                m   V   j');
  qio_write   (VT100_graphics_off);
  qio_writeln ('  point  is  given  every  time  you  move');
  qio_writeln ('But as  you move around one of the 8 squares');
  qio_writeln ('around you will be blocked by a star.');
  qio_writeln ('You cannot move on to a star and you can not');
  qio_writeln ('move over the edges.');
  qio_writeln ('The highest score possible is 288 (I think).');
  qio_writeln ('See how close you can get to 288.');
  qio_writeln;
  qio_writeln ('     press <return> to start');
  qio_1_char;
END;

PROCEDURE drawbox;
BEGIN
  posn (1,1);
  clear;
  posn (18,1);
  qio_write (VT100_top+'Catch');
  posn (18,2);
  qio_write (VT100_bottom+'Catch');
  posn (18,3);
  qio_write (VT100_wide+'~~~~~');
  qio_write (VT100_graphics_on);
  posn (11,4);
  qio_write (VT100_wide+'lqqqqqqqqqqqqqqqqqk');
  FOR i := 1 TO 17 DO
    BEGIN
      posn (11,4+i);
      qio_write (VT100_wide+'x                 x');
    END;
  posn (11,22);
  qio_write (VT100_wide+'mqqqqqqqqqqqqqqqqqj');
  posn (20,13);
  qio_write ('#');
  qio_write (VT100_graphics_off);
  posn (31,4);
  qio_write ('Score');
  posn (31,5);
  qio_write ('-----');
  posn (33,6);
  qio_write ('0');
  posn (1,13);
  qio_write ('Type "e"');
  posn (1,14);
  qio_write ('to exit');
END{drawbox};

PROCEDURE position(x,y:integer;character:char);

BEGIN
  x := x + 11;
  y := y + 4;
  posn (x,y);
  qio_write (character);
END{position};

PROCEDURE starcount(xstart,xfinish,ystart,yfinish:integer);

VAR i,j :integer;

BEGIN
    numberstar := 0;
    FOR i := xstart TO xfinish DO
	FOR j := ystart TO yfinish DO
	    IF (i <> 0) OR (j <> 0) THEN
		IF (grid[x + i,y + j] = '*') THEN
		    numberstar := numberstar + 1;
END{starcount};

PROCEDURE finalstar(xdisplace,ydisplace:integer);

BEGIN
    IF grid[x + xdisplace,y + ydisplace] <> '*' THEN
	BEGIN
	    grid[x + xdisplace,y + ydisplace] := '*';
	    position(x + xdisplace,y + ydisplace,'*');
	    finish := true;
	END
    ELSE
	think := think + 1;
END{finalstar};

PROCEDURE mainstar;

BEGIN
    starcount(-1,1,-1,1);
    numberstar := 8 - numberstar;
    IF numberstar = 1 THEN
    	catch := true;
    think :=random(numberstar);
    finish := false;
    WHILE (finish = false) DO
	CASE think OF
	    1:finalstar(-1,-1);
	    2:finalstar(0,-1);
	    3:finalstar(-1,0);
	    4:finalstar(1,-1);
	    5:finalstar(-1,1);
	    6:finalstar(1,0);
	    7:finalstar(0,1);
	    8:finalstar(1,1);
	END;
END{mainstar};

PROCEDURE move;

VAR overedge,commanderror  :boolean;
    tempx,tempy,numberstar :integer;

BEGIN
    overedge := false;
    commanderror := false;
    posn (1,17);
    qio_write ('   ');
    posn (1,16);
    qio_write ('Move');
    direction := qio_1_char;
    posn (1,4);
    qio_write ('          ');
    tempx := x;
    tempy := y;
    IF (direction >= '1') AND (direction <= '9')
      AND (direction <> '5') THEN
	CASE direction OF
	  '1':IF (x > 1) AND (y < 17) THEN
		BEGIN
		    tempx := x - 1;
		    tempy := y + 1;
	    	END
	    ELSE
	        overedge := true;
	  '2':IF y < 17 THEN
	        tempy := y + 1
	      ELSE
	        overedge := true;
	  '3':IF (x < 17) AND (y < 17) THEN
	    	BEGIN
		   tempx := x + 1;
		   tempy := y + 1;
	    	END
	      ELSE
	    	overedge := true;
	  '4':IF x > 1 THEN
		tempx := x - 1
	      ELSE
		overedge := true;
	  '6':IF x < 17 THEN
		tempx := x + 1
	      ELSE
		overedge := true;
	  '7':IF (x > 1) AND (y > 1) THEN
		BEGIN
		    tempx := x - 1;
		    tempy := y - 1;
		END
	      ELSE
		overedge := true;
	  '8':IF y > 1 THEN
		tempy := y - 1
	      ELSE
		overedge := true;
	  '9':IF (x < 17) AND (y > 1) THEN
		BEGIN
		    tempx := x + 1;
		    tempy := y - 1;
		END
	      ELSE
		overedge := true;
    	END
    ELSE
	commanderror := true;
    IF grid[tempx,tempy] = '*' THEN
      BEGIN
        posn (1,4);
	qio_write ('On to star'+chr(7));
      END
    ELSE
    IF overedge THEN
      BEGIN
        posn (1,4);
	qio_write ('Over edge'+chr(7));
      END
    ELSE
    IF (direction <> 'e') AND (direction <> 'E') THEN
    IF  commanderror THEN
      BEGIN
	posn (1,4);
        qio_write ('Try again'+chr(7));
      END
    ELSE
	BEGIN
	    position(x,y,' ');
	    position(tempx,tempy,'#');
	    x := tempx;
	    y := tempy;
	    mainstar;
	    IF catch THEN
		BEGIN
		    posn (14,23);
                    qio_write (VT100_wide+'You are caught');
		    qio_write (chr(7));
                    posn (1,16);
                    qio_write (chr(7));
		    direction := 'e';
		END;
	    score := score + 1;
	    posn (32,6);
            qio_write (dec(score,,2));
	END;
END{move};

BEGIN{mainline}
    esc := chr(155);
    reset_screen;
    ranvalue := 0.0;
    time(timeran);
    mult := (ord(timeran[11]) - 48)*1000000 + (ord(timeran[10]) - 48)*10000000;
    posn (1,1);
    clear;
    qio_write ('Do you require instructions (y/n) ');
    IF ( qio_1_char in ['y','Y'] ) THEN
      help;
    score := 0;
    FOR i := 0 TO 18 DO
	BEGIN
	    grid[0,i] := '*';
	    grid[18,i] := '*';
	END;
    FOR i := 1 TO 17 DO
	BEGIN
	    grid[i,0] := '*';
	    grid[i,18] := '*';
	END;
    FOR i := 1 TO 17 DO
    	FOR j := 1 TO 17 DO
    	    grid[i,j] := ' ';
    x := 9;
    y := 9;    
    drawbox;
    WHILE (direction <> 'e') AND (direction <> 'E') DO
        move;
    posn (1,17);
    qio_write (' ');
    posn (1,23);
  top_ten (score);
END.
