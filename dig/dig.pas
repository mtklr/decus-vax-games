[ Inherit ('INTERACT') ]

PROGRAM DigDug(input,output,Detpic,HlpPic);

{ A game of low cunning and high boredom ... any resemblance between this
  game and any existing game is entirely deliberate.
  Idea stolen and program written by Ian Thornborough.
  Started writing on 28-9-84.
  Copyright (C) I.H.Thornborough 1984. }

CONST
	MaxSpook= '9';

TYPE
	vstring	= varying[255] of char;
	spk	= RECORD
			state 	: char;
			x	: integer;
			y	: integer;
  			dir	: 0..3;
		  END;

VAR
	DetPic,
	HlpPic		: text;
	spook		: array ['0'..MaxSpook] of spk;
	map		: packed array [1..24] of packed array [1..40] of char;
	buffer  	: vstring;
	beep,
	SaveSpookNo,
	SpookNo		: char;
	MeX,
	MeY,
	i,
	delay,
	lives,
	score,
	move,
	lastmove,
	screen,
	fire_count,
	x,
	y		: integer;
	dead,
	HavePick,
	SpookGone,
	GameOver,
	LastSpook	: boolean;

{*****************************************************************************}

FUNCTION dirt : char;
BEGIN
	If x < 8 then
	  dirt := '.'
	Else
	  If x < 16 then
	    dirt := 'O'
	  Else
	    dirt := '@';
END;

{*****************************************************************************}

PROCEDURE pos(v,h : integer);
VAR
	Xdis,
	Ydis	: integer;
BEGIN
	qio_write (VT100_esc+'['+dec(v)+';'+dec(h+1)+'H');
	x := v;
	y := h;
END;

{*****************************************************************************}

PROCEDURE LoadHelp;
VAR
	line	: varying[255] of char;
BEGIN
    Image_dir;
	open(HlpPic,'image_dir:Dighlp.dat',history := readonly,error := continue);
	reset(HlpPic);
	While not EOF(HlpPic) do
	  BEGIN
	    readln(HlpPic,line);
	    If line[1] <> '%' then
	      qio_write (line)
	    Else
              qio_1_char;
	  END;
	close(HlpPic);
END;

{*****************************************************************************}

Procedure AskBeep;
{ Ask if they want beeps or not ...
  if not assign beep the null char. / if so  assign beep the bell char. }
Begin
	qio_write (VT100_esc+'[2J'+VT100_esc+'(0'+VT100_esc+'[11;13H'+VT100_esc+'#6lqqqqqqqqqqqqqk'+VT100_esc+'[12;13H'+VT100_esc+'#6x BEEP (Y/N)  x'+VT100_esc+'[13;13H'+VT100_esc+'#6mqqqqqqqqqqqqqj'+VT100_esc+'[12;25H');
	If upper_case(qio_1_char) = 'Y' then
	  beep := chr(7)
	Else
	  beep := chr(0);
	qio_write (beep);
End;

{*****************************************************************************}

PROCEDURE AskHelp;
BEGIN
	qio_write (VT100_esc+'[12;15H'+VT100_esc+'#6HELP'+VT100_esc+'[12;25H');
	If (upper_case(qio_1_char) = 'Y') then
	  LoadHelp;
END;

{*****************************************************************************}

PROCEDURE DrawField;
VAR
	i	: integer;
BEGIN
	qio_write (VT100_esc+'(0');
	For i := 1 to 24 do
	  qio_write (VT100_esc+'['+dec(i)+';1H'+VT100_esc+'#6'+map[i]);
END;

{*****************************************************************************}

PROCEDURE UpdateScnNo;
BEGIN
	qio_write (VT100_esc+'[24;2H'+dec(screen));
END;

{*****************************************************************************}

PROCEDURE UpdateScore;
BEGIN
	qio_write (VT100_esc+'7'+VT100_esc+'[24;15H'+dec(score)+VT100_esc+'8');
END;

{*****************************************************************************}

PROCEDURE UpdateLives;
VAR
	i	: integer;
BEGIN
	For i := 1 to lives do
	  qio_write (VT100_esc+'[24;'+dec(26+(i*2))+'H`');
	If lives < 5 then
	  For i := (lives+1) to 5 do
	    qio_write (VT100_esc+'[24;'+dec(26+(i*2))+'H~');
END;

{*****************************************************************************}

PROCEDURE HighLightDetails;
VAR
	i,
	j	: integer;
BEGIN
	qio_write (VT100_esc+'[1m');
	For j := 2 to 39 do
	  For i := 2 to 22 do
	    If map[i,j] in ['`','0'..'9','U','T','a'] then
	      BEGIN
		qio_write (VT100_esc+'['+dec(i)+';'+dec(j)+'H');
	        If map[i,j] in ['0'..'9'] then
		  BEGIN
		    If spook[map[i,j]].state = 'M' then
	  	      qio_write ('*')
		    Else
		      qio_write ('#');
		  END
	        Else
	  	  qio_write (map[i,j]);
	      END;
	qio_write (VT100_esc+'[m');
END;

{*****************************************************************************}

PROCEDURE RedrawScreen;
VAR
	i	: integer;
BEGIN
	DrawField;
	UpdateScnNo;
	UpdateScore;
	UpdateLives;
	HighLightDetails;
END;

{*****************************************************************************}

PROCEDURE LoadDetails;
VAR	
	line	: packed array[1..40] of char;
	c	: integer;
BEGIN
	c := 0;
    Image_dir;
	open(DetPic,'image_dir:Digdet.dat',history := readonly,error := continue);
	reset(DetPic);
	While not EOF(DetPic) do
	   BEGIN
	     c := c+1;
	     readln(DetPic,line);
	     map[c] := line;
	   END;
	close(DetPic);
END;

{*****************************************************************************}

PROCEDURE GenerateSpooks;
VAR
	chk,
	g,
	h,
	testx,
	testy	: integer;
	e,
	f,
	count	: char;
BEGIN
	count := '/';
	chk := 0;
	For e := '0' to SpookNo do
	  BEGIN
	    spook[e].state := 'M';
	    spook[e].dir := 0;
	  END;
	REPEAT
	  chk := chk+1;
	  If chk = 100 then
            chk := 0;
	  testx := rnd(delay,22);
	  testy := rnd(4,37);
	  If  ((map[testx,testy]     in ['.','O','@'])
	   and (map[testx-1,testy-1] in ['.','O','@'])
	   and (map[testx-1,testy]   in ['.','O','@'])
	   and (map[testx-1,testy+1] in ['.','O','@'])
	   and (map[testx,testy-1]   in ['.','O','@'])
	   and (map[testx,testy]     in ['.','O','@'])
	   and (map[testx,testy+1]   in ['.','O','@'])
	   and (map[testx+1,testy-1] in ['.','O','@'])
	   and (map[testx+1,testy]   in ['.','O','@'])
	   and (map[testx+1,testy+1] in ['.','O','@'])) then
	    BEGIN  
	      count := succ(count);
	      spook[count].X := testx;
	      spook[count].Y := testy;
	      For g := (testx-1) to (testx+1) do
		For h := (testy-1) to (testy+1) do
		  qio_write (VT100_esc+'['+dec(g)+';'+dec(h)+'H ');
	      qio_write (VT100_esc+'['+dec(testx)+';'+dec(testy)+'H'+VT100_esc+'[1m*'+VT100_esc+'[m');
	      For g := (testx-1) to (testx+1) do
		For h := (testy-1) to (testy+1) do
	          map[g,h] := ' ';
	      map[testx,testy] := count;
	    END;
	UNTIL count = SpookNo;
END;

{*****************************************************************************}

PROCEDURE GenerateRocks;
VAR
	go	: boolean;
	chk,
	v,
	testx,
	testy	: integer;
	count	: char;
BEGIN
	chk := 0;
	count := '0';
	REPEAT
	  chk := chk+1;
	  If chk = 100 then
            chk := 0;
	  go := true;
	  testx := rnd(4,18);
	  testy := rnd(4,36);
	  For v := 4 to 18 do
	    If ((map[v,testy] = 'a')
	     or (map[v,testy-1] = 'a')
	     or (map[v,testy+1] = 'a')) then
	      go := false;
	  If ((not (map[testx+1,testy] in [' ','0'..'9'])) and go) then
	    BEGIN
	      count := succ(count);
	      qio_write (VT100_esc+'['+dec(testx)+';'+dec(testy)+'H'+VT100_esc+'[1m'+'a'+VT100_esc+'[m');
	      map[testx,testy] := 'a';
	    END;
	UNTIL count = '6';
END;

{*****************************************************************************}

PROCEDURE GeneratePick;
VAR
	chk,
	testx,
	testy	: integer;
	count	: char;
BEGIN
	count := '0';
	chk := 0;
	REPEAT
	  chk := chk+1;
	  If chk = 100 then
            chk := 0;
	  testx := rnd(4,19);
	  testy := rnd(4,36);
	  If (map[testx,testy] in ['.','O','@']) then
	    BEGIN
	      count := succ(count);
	      qio_write (VT100_esc+'['+dec(testx)+';'+dec(testy)+'H'+VT100_esc+'[1m'+'T'+VT100_esc+'[m');
	      map[testx,testy] := 'T';
	    END;
	UNTIL count = '1';
END;

{*****************************************************************************}

PROCEDURE GenerateUranium;
VAR
	chk,
	testx,
	testy	: integer;
	count	: char;
BEGIN
	count := '0';
	chk := 0;
	REPEAT
	  chk := chk+1;
	  If chk = 100 then
            chk := 0;
	  testx := rnd(4,19);
	  testy := rnd(4,36);
	  If map[testx,testy] in ['.','O','@'] then
	    BEGIN
	      count := succ(count);
	      qio_write (VT100_esc+'['+dec(testx)+';'+dec(testy)+'H'+VT100_esc+'[1m'+'U'+VT100_esc+'[m');
	      map[testx,testy] := 'U';
	    END;
	UNTIL count = '8';
END;

{*****************************************************************************}

PROCEDURE GenerateMe;
VAR
	chk	: integer;
BEGIN
	chk := 0;
	MeX := 2;
	REPEAT
	  chk := chk+1;
	  If chk = 100 then
            chk := 0;
	  MeY := rnd(3,38);
	UNTIL map[2,MeY] in ['.',' '];
	qio_write (VT100_esc+'['+dec(MeX)+';'+dec(MeY)+'H'+VT100_esc+'[1m'+'`'+VT100_esc+'[m');
END;

{*****************************************************************************}

PROCEDURE GenerateDetails;
BEGIN
	GenerateMe;
	GenerateSpooks;
	GenerateRocks;
	GeneratePick;
	GenerateUranium;
END;

{*****************************************************************************}

PROCEDURE killspook(k : char; how : char := 'L');
BEGIN
	If spook[k].X < 8 then
	  score := score+1
	Else
	  If spook[k].X < 16 then
	    score := score+3
	  Else
	    score := score+5;
	If (lastspook and (how <> 'R')) then
	  score := score+100;
	If how = 'L' then
	  score := score+15
	Else
	  score := score+30;
	UpdateScore;
	map[spook[k].X,spook[k].Y] := ' ';
	spook[k] := spook[SpookNo];
	SpookNo := pred(SpookNo);
	If SpookNo = '0' then
	  lastspook := true;
	If SpookNo < '0' then
	  spookgone := true;
	qio_write (beep);
END;

{*****************************************************************************}

PROCEDURE MoveUp(obj,bckgrd : char);
BEGIN
	If not (map[x-1,y] in ['a','q','x','k','l','m','j']) then
	  BEGIN
	    x := x-1;
	    qio_write (VT100_esc+'[D'+bckgrd+VT100_esc+'[D'+VT100_esc+'[A'+VT100_esc+'[1m'+obj+VT100_esc+'[m');
	  END;
END;

{*****************************************************************************}

PROCEDURE MoveDown(obj,bckgrd : char);
BEGIN
	If not (map[x+1,y] in ['a','q','x','k','l','m','j']) then
	  BEGIN
	    x := x+1;
	    qio_write (VT100_esc+'[D'+bckgrd+VT100_esc+'[D'+VT100_esc+'[B'+VT100_esc+'[1m'+obj+VT100_esc+'[m');
	  END;
END;

{*****************************************************************************}

PROCEDURE MoveRight(obj,bckgrd : char);
BEGIN
	If not (map[x,y+1] in ['a','q','x','k','l','m','j']) then
	  BEGIN
	    y := y+1;
	    qio_write (VT100_esc+'[D'+bckgrd+VT100_esc+'[D'+VT100_esc+'[C'+VT100_esc+'[1m'+obj+VT100_esc+'[m');
	  END;
END;

{*****************************************************************************}

PROCEDURE MoveLeft(obj,bckgrd : char);
BEGIN
	If not (map[x,y-1] in ['a','q','x','k','l','m','j']) then
	  BEGIN
	    y := y-1;
	    qio_write (VT100_esc+'[D'+bckgrd+VT100_esc+'[D'+VT100_esc+'[D'+VT100_esc+'[1m'+obj+VT100_esc+'[m');
	  END;
END;

{*****************************************************************************}

PROCEDURE DropRock(Rx,Ry : integer);
BEGIN
	pos(Rx,Ry);
	REPEAT
	  WHILE map[x+1,y] = ' ' do
	    BEGIN
	      pos(x,y);
	      map[x,y] := ' ';
	      MoveDown('a',' ');
	      map[x,y] := 'a';
	    END;
	  If map[x+1,y] = '`' then
	    BEGIN
	      dead := true;
	      map[x+1,y] := ' ';
	    END
	  Else
	    If (map[x+1,y] in ['0'..'9']) then
	      killspook(map[x+1,y],'R');
	UNTIL (map[x+1,y] in ['.','O','@','a','q','U','T']);
END;

{*****************************************************************************}

PROCEDURE spookrun;
BEGIN
	pos(spook['0'].X,spook['0'].Y);
	If x <= 2 then
	  BEGIN
	    map[x,y] := ' ';
	    If (y < MeY) then
	      MoveLeft('*',' ')
	    Else
	      MoveRight('*',' ');
	    map[x,y] := '0';
	    If ((y <= 2) or (y >= 39)) then
	      BEGIN
	        qio_write (VT100_esc+'[D ');
	        spookgone := true;
	      END;
	  END
	Else
	  BEGIN
	    If (map[x-1,y] <> 'a')and(map[x-1,y] <> '`') then
	      BEGIN
		map[x,y] := ' ';
	        MoveUp('*',' ');
		map[x,y] := '0';
	      END
	    Else
	      BEGIN
		If (y-MeY) > 0 then
		  If map[x,y+1] in ['x'] then
		    BEGIN
		      map[x,y] := ' ';
		      MoveLeft('*',' ');
		      map[x,y] := '0';
		    END
		  Else
		    BEGIN
		      map[x,y] := ' ';
		      MoveRight('*',' ');
		      map[x,y] := '0';
		    END
		Else
		  If map[x,y-1] in ['x'] then
		    BEGIN
		      map[x,y] := ' ';
		      MoveRight('*',' ');
		      map[x,y] := '0';
		    END
		  Else
		    BEGIN
		      map[x,y] := ' ';
		      MoveLeft('*',' ');
		      map[x,y] := '0';
		    END;
	      END;
	  END;
	spook['0'].X := x;
	spook['0'].Y := y;
	If map[x-1,y] = 'a' then
	  DropRock(x-1,y);
END;

{*****************************************************************************}

PROCEDURE MoveSpooks;
VAR
	i 	: char;
	dx,
	dy	: integer;
	movesucc: boolean;

{-----------------------------------------------------------------------------}

	PROCEDURE MoveMadMole;
	BEGIN
	  If spook[i].state = 'M' then
	    If (abs(x-MeX) > abs(y-MeY)) then
	      BEGIN
		If ((x-MeX) > 0) then
		  BEGIN
		    If (map[x-1,y] in [' ','`']) then
		      BEGIN
			map[x,y] := ' ';
			MoveUp('*',' ');
			spook[i].dir := 0;
			movesucc := true;
		      END;
		  END
		Else
		  If (map[x+1,y] in [' ','`']) then
		    BEGIN
		      map[x,y] := ' ';
		      MoveDown('*',' ');
		      spook[i].dir := 3;
		      movesucc := true;
		    END;
		If not movesucc then
		  BEGIN
		    If ((y-MeY) > 0) then
		      BEGIN
			If (map[x,y-1] in [' ','`'])and((y-MeY) <> 0) then
			  BEGIN
			    map[x,y] := ' ';
			    MoveLeft('*',' ');
			    spook[i].dir := 1;
			    movesucc := true;
			  END
			Else
			  spook[i].state := 'G';
		      END
		    Else
		      BEGIN
			If (map[x,y+1] in [' ','`'])and((y-MeY) <> 0) then
			  BEGIN
			    map[x,y] := ' ';
			    MoveRight('*',' ');
		  	    spook[i].dir := 2;
			    movesucc := true;
			  END
			Else
			  spook[i].state := 'G';
		      END;
		  END;
	    END
	  Else
	    BEGIN
	      If ((y-MeY) > 0) then
		BEGIN
		  If (map[x,y-1] in [' ','`']) then
		    BEGIN
		      map[x,y] := ' ';
		      MoveLeft('*',' ');
		      spook[i].dir := 1;
		      movesucc := true;
		    END;
		END
	      Else
		If (map[x,y+1] in [' ','`']) then
		  BEGIN
		    map[x,y] := ' ';
		    MoveRight('*',' ');
		    spook[i].dir := 2;
		    movesucc := true;
		  END;
	      If not movesucc then
		If ((x-MeX) > 0) then
		  If (map[x-1,y] in [' ','`'])and((x-MeX) <> 0) then
		    BEGIN
		      map[x,y] := ' ';
		      MoveUp('*',' ');
		      spook[i].dir := 0;
		      movesucc := true;
		    END
		  Else
		    spook[i].state := 'G'
		Else
		  If (map[x+1,y] in [' ','`'])and((x-MeX) <> 0) then
		    BEGIN
		      map[x,y] := ' ';
		      MoveDown('*',' ');
		      spook[i].dir := 3;
		      movesucc := true;
		    END
		  Else
		    spook[i].state := 'G';
	    END;
	END;

{-----------------------------------------------------------------------------}

	PROCEDURE MoveGhost;
	BEGIN
	  If (abs(x-MeX)) >= (abs(y-MeY)) then
	    BEGIN
	      If (x-MeX) > 0 then
		BEGIN
		  If (map[x-1,y] in [' ','`']) then
		    BEGIN
		      map[x,y] := dirt;
		      MoveUp('*',dirt);
	              spook[i].dir := 0;
		      spook[i].state := 'M';
		      movesucc := true;
		    END
		  Else
		    BEGIN
		      If not (map[x-1,y] in ['0'..'9','T','a']) then
			BEGIN
			  map[x,y] := dirt;
			  MoveUp('#',dirt);
			  spook[i].dir := 0;
			  movesucc := true;
			END;
		    END;
		END
	      Else
		BEGIN
		  If (map[x+1,y] in [' ','`']) then
		    BEGIN
		      map[x,y] := dirt;
		      MoveDown('*',dirt);
	              spook[i].dir := 3;
		      spook[i].state := 'M';
		      movesucc := true;
		    END
		  Else
		    BEGIN
		      If not (map[x+1,y] in ['0'..'9','T','a']) then
			BEGIN
			  map[x,y] := dirt;
			  MoveDown('#',dirt);
			  spook[i].dir := 3;
			  movesucc := true;
			END;
		    END;
		END;
	    END
	  Else
	    BEGIN
	    If (y-MeY) > 0 then
	      BEGIN
	      If (map[x,y-1] in [' ','`']) then
		BEGIN
		  map[x,y] := dirt;
		  MoveLeft('*',dirt);
		  spook[i].dir := 1;
		  spook[i].state := 'M';
		  movesucc := true;
		END
	      Else
		BEGIN
		  If not (map[x,y-1] in ['0'..'9','T','a']) then
		    BEGIN
		      map[x,y] := dirt;
		      MoveLeft('#',dirt);
		      spook[i].dir := 1;
		      movesucc := true;
		    END;
		END;
	      END
	    Else
	      BEGIN
	      If (map[x,y+1] in [' ','`']) then
		BEGIN
		  map[x,y] := dirt;
		  MoveRight('*',dirt);
		  spook[i].dir := 2;
		  spook[i].state := 'M';
		  movesucc := true;
		END
	      Else
		BEGIN
		  If not (map[x,y+1] in ['0'..'9','T','a']) then
		    BEGIN
		      map[x,y] := dirt;
		      MoveRight('#',dirt);
		      spook[i].dir := 1;
		      movesucc := true;
		    END;
		END;
	      END;
	    END;
	  If not movesucc then
	    If map[x-1,y] in ['.','O','@'] then
	      BEGIN
	        map[x,y] := dirt;
	        MoveUp('#',dirt);
		spook[i].dir := 0;
		movesucc := true;
	      END
	    Else
	      If map[x+1,y] in ['.','O','@'] then
	        BEGIN
	          map[x,y] := dirt;
	          MoveDown('#',dirt);
		  spook[i].dir := 3;
	  	  movesucc := true;
	        END
	      Else
	    	If map[x,y-1] in ['.','O','@'] then
	          BEGIN
	            map[x,y] := dirt;
	            MoveLeft('#',dirt);
		    spook[i].dir := 1;
		    movesucc := true;
	          END
	  	Else
	          BEGIN
	            map[x,y] := dirt;
	            MoveRight('#',dirt);
		    spook[i].dir := 2;
		    movesucc := true;
	          END;
	END;

{-----------------------------------------------------------------------------}

	PROCEDURE MoveMildMole;
	VAR
	  next,
	  tries	: integer;
	BEGIN
	  tries := 0;
	  If (spook[i].dir IN [0,2]) then
	    next := 1
	  Else
	    next := -1;
	  REPEAT
	    CASE spook[i].dir of
	      0 : BEGIN
		    If (map[x-1,y] IN [' ','`']) then
		      BEGIN
			map[x,y] := ' ';
			MoveUp('*',' ');
			movesucc := true;
		      END
		    Else
		      BEGIN
			spook[i].dir := (spook[i].dir+next) mod 4;
			tries := tries+1;
		      END;
		  END;
	      1 : BEGIN
		    If (map[x,y-1] in [' ','`']) then
		      BEGIN
			map[x,y] := ' ';
			MoveLeft('*',' ');
			movesucc := true;
		      END
		    Else
		      BEGIN
			spook[i].dir := (spook[i].dir+next) mod 4;
			tries := tries+1;
		      END;
		  END;
	      2 : BEGIN
		    If (map[x,y+1] in [' ','`']) then
		      BEGIN
			map[x,y] := ' ';
			MoveRight('*',' ');
			movesucc := true;
		      END
		    Else
		      BEGIN
			spook[i].dir := (spook[i].dir+next) mod 4;
			tries := tries+1;
		      END;
		  END;
	      3 : BEGIN
		    If (map[x+1,y] in [' ','`']) then
		      BEGIN
			map[x,y] := ' ';
			MoveDown('*',' ');
			movesucc := true;
		      END
		    Else
		      BEGIN
			spook[i].dir := (spook[i].dir+next) mod 4;
			tries := tries+1;
		      END;
		  END;
	      Otherwise { do nothing }
	    END;
	  UNTIL (movesucc or (tries = 4));
	END;

{-----------------------------------------------------------------------------}

BEGIN
	For i := '0' to SpookNo do
	  BEGIN
	    pos(spook[i].X,spook[i].Y);
	    dx := abs(spook[i].X-MeX);
	    dy := abs(spook[i].Y-MeY);
	    movesucc := false;
	    If (((dx < 8) and (dy < 8)) or (spook[i].state = 'G')) then
	      BEGIN
	        If spook[i].state <> 'G' then
	    	  MoveMadMole;
	        If spook[i].state = 'G' then
	  	  MoveGhost;
		If not movesucc then
		  MoveMildMole;
	      END
	    Else
	      MoveMildMole;
	    If not movesucc then
	      spook[i].state := 'G';
	    spook[i].X := x;
	    spook[i].Y := y;
	    If map[x,y] = '`' then
	      dead := true
	    Else
  	      map[x,y] := i;
	  END;
	For i := '0' to SpookNo do
	  If map[spook[i].X-1,spook[i].Y] = 'a' then
	    DropRock(spook[i].X-1,spook[i].Y);
 END;

{*****************************************************************************}

PROCEDURE fire;
VAR
	FireX,
	FireY,
  	count	: integer;

BEGIN
	FireX := MeX;
	FireY := MeY;
	If move = 50 then
	  BEGIN
	    WHILE (FireX <> (MeX+8))and(map[FireX+1,FireY] = ' ') do
	      BEGIN
	        qio_write (VT100_esc+'[D'+VT100_esc+'(B'+VT100_esc+'[Bv');
	        FireX := FireX+1;
	      END;
	    If map[FireX+1,FireY] in ['0'..'9'] then
	      killspook(map[FireX+1,FireY])
	    Else
	      If map[FireX+1,FireY] in ['a','T','U'] then
	        qio_write (VT100_esc+'[1m');
	    qio_write (VT100_esc+'(0'+VT100_esc+'[B'+VT100_esc+'[D'+map[FireX+1,FireY]+VT100_esc+'[m');
	    If FireX > MeX then
	      BEGIN
	        For count := MeX to (FireX-1) do
		  Begin
   	            qio_write (VT100_esc+'[D'+VT100_esc+'[A ');
		  End;
	      END;
	  END
	Else
	  If move = 52 then
	    BEGIN
	      WHILE (FireY <> (MeY-8))and(map[FireX,FireY-1] = ' ') do
		BEGIN
		  qio_write (VT100_esc+'[2D'+VT100_esc+'(B<');
		  FireY := FireY-1;
		END;
	      If map[FireX,FireY-1] in ['0'..'9'] then
		killspook(map[FireX,FireY-1])
	      Else
	        If map[FireX,FireY-1] = 'a' then
	          qio_write (VT100_esc+'[1m');
  	      qio_write (VT100_esc+'(0'+VT100_esc+'[2D'+map[FireX,FireY-1]+VT100_esc+'[m');
	      If FireY < MeY then
	        BEGIN
	          For count := FireY to (MeY-1) do
		    qio_write (' ');
		END;
	    END
	  Else
	    If move = 54 then
	      BEGIN
		WHILE (FireY <> (MeY+8))and(map[FireX,FireY+1] = ' ') do
		  BEGIN
		    qio_write (VT100_esc+'(B>');
		    FireY := FireY+1;
		  END;
		If map[FireX,FireY+1] in ['0'..'9'] then
		  killspook(map[FireX,FireY+1])
		Else
	          If map[FireX,FireY+1] = 'a' then
	            qio_write (VT100_esc+'[1m');
		qio_write (VT100_esc+'(0'+map[FireX,FireY+1]+VT100_esc+'[m');
		If FireY > MeY then
		  BEGIN
		    If (FireY+1) = 40 then
		      qio_write (VT100_esc+'[D ')
		    Else
		      qio_write (VT100_esc+'[2D ');
		    For count := MeY to (FireY-2) do
                      qio_write (VT100_esc+'[2D ');
		  END;
	      END
	    Else
	      If move = 56 then
		BEGIN
		  WHILE (FireX <> (MeX-8))and(map[FireX-1,FireY] = ' ') do
		    BEGIN
		      qio_write (VT100_esc+'[D'+VT100_esc+'(B'+VT100_esc+'[A^');
		      FireX := FireX-1;
		    END;
		  If map[FireX-1,FireY] in ['0'..'9'] then
		    killspook(map[FireX-1,FireY])
		  Else
	            If map[FireX-1,FireY] = 'a' then
	              qio_write (VT100_esc+'[1m');
  		  qio_write (VT100_esc+'(0'+VT100_esc+'[A'+VT100_esc+'[D'+map[FireX-1,FireY]+VT100_esc+'[m');
		  If FireX < MeX then
		    BEGIN
		      For count := FireX to (MeX-1) do
		        qio_write (VT100_esc+'[D'+VT100_esc+'[B ');
		    END;
		END;
	pos(MeX,MeY);
END;

{*****************************************************************************}

PROCEDURE MoveMe;
BEGIN
	pos(MeX,MeY);
	move := ord(qio_1_char_now);
	If not (move in [23,27,50,52,53,54,56]) then
	  move := lastmove;
	If move = 53 then
	  Begin
	    move := lastmove;
	    If fire_count > 0 then
	      Begin
	        fire;
		fire_count := -1;
	      End;
	  End;
	fire_count := fire_count + 1;
	CASE move of
	  50 : 	BEGIN
		  map[x,y] := ' ';
		  MoveDown('`',' ');
		  MeX := x;
		END;
	  52 : 	BEGIN
		  map[x,y] := ' ';
		  MoveLeft('`',' ');
		  MeY := y;
		END;
	  54 : 	BEGIN
		  map[x,y] := ' ';
		  MoveRight('`',' ');
		  MeY := y;
		END;
	  56 : 	BEGIN
		  map[x,y] := ' ';
		  MoveUp('`',' ');
		  MeX := x;
		END;
	  23 : BEGIN
		 RedrawScreen;
		 move := lastmove;
		 If lastmove = 23 then
		   move := 50;
	       END;
	  27 : GameOver := true;
	  Otherwise {dummy}
	END;
	lastmove := move;
	If map[x,y] in ['T','U'] then
	  BEGIN
	    If map[x,y] = 'T' then
	      HavePick := true;
	    score := score+15;
	    UpdateScore;
	  END;
	If map[x,y] in ['0'..'9'] then
	  BEGIN
	    dead := true;
	    qio_write (VT100_esc+'['+dec(x)+';'+dec(y)+'H*');
	  END
	Else
	  map[x,y] := '`';
END;

{*****************************************************************************}

PROCEDURE UpdateMe;
VAR
	Sx,
	Sy	: integer;

{-----------------------------------------------------------------------------}

	PROCEDURE TestRockAbove;
	BEGIN
	  If map[(x-1),y] = 'a' then
	    BEGIN
	      Sx := x-1;
	      Sy := y;
	      MoveSpooks;
	      If not (lastmove in [52,54]) then
	        lastmove := (52+(rnd(0,1)*2));
	      MoveMe;
	      DropRock(Sx,Sy);
	      pos(MeX,MeY);
	    END;
	END;

{-----------------------------------------------------------------------------}

BEGIN
	MoveMe;
	TestRockAbove;
	If not dead then
	  TestRockAbove;
END;

{*****************************************************************************}

PROCEDURE TestDead;
BEGIN
	If dead then
	  BEGIN
	    lives := lives-1;
	    If lives = 0 then
	      GameOver := true
	    Else
	      dead := false;
	    qio_write (beep+VT100_esc+'[24;'+dec(28+(lives*2))+'H~'
			+VT100_esc+'['+dec(MeX)+';'+dec(MeY)+'H '+beep);
	    If map[MeX,MeY] in ['0'..'9'] then
	      qio_write (VT100_esc+'['+dec(MeX)+';'+dec(MeY)+'H*')
	    Else
	      BEGIN
	        qio_write (VT100_esc+'['+dec(MeX)+';'+dec(MeY)+'H ');
	        map[MeX,MeY] := ' ';
	      END;
	    If not dead then
	      GenerateMe;
	    If HavePick then
	      GeneratePick;
	    HavePick := false;
	    qio_purge;
	    lastmove := ord(qio_1_char);
	  END;
END;

{*****************************************************************************}

BEGIN
	screen := 0;
	lives := 5;
	fire_count := 0;
	AskBeep;
	AskHelp;
	SaveSpookNo := '2';
	delay := 17;
	qio_write (VT100_esc+'[2J');
	REPEAT
	  screen := screen+1;
	  If ((screen mod 5) = 0) then
	    If lives < 5 then
	      lives := lives+1;
	  dead := false;
	  LastSpook := false;
	  GameOver := false;
	  SpookGone := false;
	  HavePick := false;
	  delay := delay-2;
	  If delay < 3 then
	    delay := 15;
	  SaveSpookNo := succ(SaveSpookNo);
	  If SaveSpookNo > MaxSpook then
	    SaveSpookNo := '3';
	  SpookNo := SaveSpookNo;
	  LoadDetails;
	  RedrawScreen;
	  qio_write (VT100_esc+'(0'+VT100_esc+'[24;27H');
	  For i := 1 to lives do
	    qio_write (' `');
	  GenerateDetails;
	  qio_purge;
	  Repeat
	    lastmove := ord(qio_1_char);
	  Until (lastmove in [50,52,54,56]);
	  REPEAT
	    REPEAT
	      sleep_start (delay);
	      UpdateMe;
	      sleep_wait;
	      sleep_start (delay);
	      If (not SpookGone)and(not LastSpook) then
		MoveSpooks;
	      If (not dead)and(HavePick) then
		UpdateMe;
	      sleep_wait;
	    UNTIL (dead)or(LastSpook)or(SpookGone)or(GameOver);
	    TestDead;
	  UNTIL (dead)or(LastSpook)or(SpookGone)or(GameOver);
	  If (lastspook)and(not dead) then
	    BEGIN
	      REPEAT
	        sleep_start (delay);
	        If not SpookGone then
	          SpookRun;
	        TestDead;
	        If (not dead)and(not SpookGone) then
	  	  UpdateMe;
	        sleep_wait;
	      UNTIL (dead)or(GameOver)or(SpookGone);
	    END;
	  If (not dead)and(not GameOver) then
	    BEGIN
	      sleep(2);
	      qio_write (VT100_esc+'[7m'+VT100_esc+'[1m'+VT100_esc+'[12;6H'+' PRESS A KEY AND TRY THIS LOT '+VT100_esc+'[D'+VT100_esc+'[m');
	      qio_purge;
	      qio_1_char;
	    END;
	UNTIL GameOver;
	qio_write (beep+VT100_esc+'(B');
	top_ten(score);
END.
