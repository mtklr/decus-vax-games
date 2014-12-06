{ Copyright * Asteroids * by Graham Joyce and Stefan Spadoni . }

PROGRAM Asteroids(Input,Output, help_file, Data_file);

{ this is a scaled down version of asteroids, whith the added extra of a 
  greebie shooting missiles at you as well. The game was created by 
  Graham Joyce, and was modified to it's present state by Stefan Spadoni. }

LABEL
	1;
CONST
	Esc			= Chr(27);
	Bell			= Chr(7);
	White_100		= ''(27)'[?5h';
	Black_100		= ''(27)'[?5l';
	Home_100		= ''(27)'[H';
	Clear_100		= ''(27)'[2J';
	Jump_100		= ''(27)'[?4l';
	Home_52			= ''(27)'H';
	Clear_52		= ''(27)'J';
	VT52			= ''(27)'[?2l';
	Ansi_Mode 		= ''(27)'<';
	Line			= ''(13)''(10)'';
	Place			= ''(27)'[23;0H';
 	Large_100		= ''(27)'#6';
	Scroll_Region 		= ''(27)'[1;23r';

	Blank 			= ' ';
	Star 			= '*';
	Player 			= 'V';
	Greebie 		= '#';
	Missile 		= '!';

	Max_right 		= 39;
	Min_left  		= 2;
	Centre    		= 20;
	Left 			= -1;
	Right 			= +1;
	Down 			= 0;
	Min_player_row		= 5;

TYPE
	Num_of_Line		= 1 .. 150;
	Num_of_Char		= 1 .. 60;

	Screen_Line 		= Packed Array [ -6 .. 46 ] Of Char;

	Buffer_St		= Packed Array[1..256] Of Char;

	Buffer_Rec		= Record
					Len	: Integer;
					String	: Buffer_St;
				End;


VAR
	Data_file,
	help_file		: Text;

	Stars_Line		: Packed Array [ Num_of_line ,
						   Num_of_Char ] of Char;

	Seed 			: Real;

	Char_String		: Varying [150] Of Char;

	ch 			: packed array [1..7] of char;

  	Out			: Buffer_Rec;

	Shot_Going,
	Back_Thrust,
	Greebie_Dead , 
	Dead 			: Boolean;

	Answer 			: Char;

	Time_out,
	Score,
	Sector , 
 	Field , 
	Ext_Move , 
	Greebie_Pos , 
	Shot_Row , 
	Down_Count ,
	Player_col , 
	Player_Row,
	Test_Num,
	Moves , 
	This_Move 		: Integer;

	Screen 			: Packed Array [ 0  .. 26 ] Of Screen_Line;

{ Here end declerations , procedures and functions related to util/lib begin }

PROCEDURE Sleep( Seconds : Integer); Extern;

PROCEDURE Sleep_Set( Efn , Sec : Integer ); Extern;

PROCEDURE Sleep_Start; Extern;

PROCEDURE Sleep_Wait; Extern;

[ asynchronous,unbound]
PROCEDURE TT_Write( Var Buff : Buffer_St; Var Len : Integer); Extern;

PROCEDURE Image_Dir; Extern;

PROCEDURE TT_Init( One : Integer); Extern;

FUNCTION TT_1_Char_Now: Char; Extern;

FUNCTION TT_1_Char: Char; extern;

FUNCTION Random( lb,ub : Integer):integer;

	FUNCTION Mth$Random( Var Seed : Real):Real;extern;

Begin
	Random := lb + Trunc(Mth$Random(Seed)*(ub-lb+1));

End; { random }

PROCEDURE Break;

Begin
  	TT_write(out.string,out.len);
  	out.len := 0;

End; { break }

Procedure At( row , Col : integer);

Begin

	Out.len := Out.len + 1;
	Out.String[Out.len] := Esc;
	Out.len := Out.len + 1;
	Out.String[Out.len] := 'Y';
	Out.len := Out.len + 1;
	Out.String[Out.len] := Chr( 31 + Row);
	Out.len := Out.len + 1;
	Out.String[Out.len] := Chr( 31 + Col);

End; { at }

PROCEDURE Write_1(ch1 : char);

Begin
	Out.len := Out.len + 1;
	Out.String[Out.len] := ch1;

End; { Write_1 }

PROCEDURE Write_3(ch1,ch2,ch3 : char);

Begin
	Out.len := Out.len + 1;
	Out.String[Out.len] := ch1;
	Out.len := Out.len + 1;
	Out.String[Out.len] := ch2;
	Out.len := Out.len + 1;
	Out.String[Out.len] := ch3;

End; { Write_3 }

PROCEDURE Write_6(ch1,ch2,ch3,ch4,ch5,ch6 : char);

Begin
	Out.len := Out.len + 1;
	Out.String[Out.len] := ch1;
	Out.len := Out.len + 1;
	Out.String[Out.len] := ch2;
	Out.len := Out.len + 1;
	Out.String[Out.len] := ch3;
	Out.len := Out.len + 1;
	Out.String[Out.len] := ch4;
	Out.len := Out.len + 1;
	Out.String[Out.len] := ch5;
	Out.len := Out.len + 1;
	Out.String[Out.len] := ch6;

End; { Write_6 }


PROCEDURE write_ch(Row,Col : integer; ch1:char);

Begin
	Out.len := Out.len + 1;
	Out.String[Out.len] := Esc;
	Out.len := Out.len + 1;
	Out.String[Out.len] := 'Y';
	Out.len := Out.len + 1;
	Out.String[Out.len] := Chr( 31 + Row);
	Out.len := Out.len + 1;
	Out.String[Out.len] := Chr( 31 + Col);
	Out.len := Out.len + 1;
	Out.String[Out.len] := ch1;

End; { write_ch }

PROCEDURE write_st( write_string : packed array[lb..ub:integer] of char);
Var
 	pos	: integer;
Begin
  	for pos := 1 to ub do
  		out.string[out.len+pos] := write_string[pos];
  	out.len := out.len + ub;

End; { write_ch }

{                  Main Procedures and Functions Begin Here                   }

PROCEDURE top_ten(score : integer ); extern;
{ a fortran topten score table sub-program }

FUNCTION Last_Score:Integer; Extern;
{ a fortran function to return the score of an 
  existing user }

PROCEDURE Set_echo ( var file_var : text ;  echo : boolean); Extern;

PROCEDURE Calculate_score;
{ obvious ... }
Begin
	Score := ((((Sector * Sector) + (Field * 3))div 2)*3);

End; { calculate_score }

PROCEDURE Read_Help_File;
{ introduce the instructions for playing the game }

var
	len		: integer;
        Help_Line   	: Varying [256] of Char;

Begin

	TT_Init(1);
	Image_Dir;
	Out.len := 0;
	Open(Help_File,'Image_Dir:Asteroids.scn', 
	  History := Readonly, Error := Continue);
	If Status(Help_File) = 0 Then
	Begin
		Reset(Help_File);
		While Not Eof(Help_File) Do 
		Begin
			Readln(Help_File,Help_Line);
			Len := Help_Line.Length;
			TT_Write(Help_Line.Body,Len);	    
		End;
	End 
	Else 
	Begin
		Write_st(' Can''t find help screen. Type <Return> to play ');
		Break;
	End;
	TT_1_Char; { Wait til hit a char }

End; {Read_Help_File }

PROCEDURE Read_Data_File;
{ read in data file }

var
        Help_Line   	: Varying [256] of Char;
	line_num,
	Char_num	: integer;
Begin

	Out.len := 0;
	Open(Data_file,'Image_Dir:Asteroids.dat', 
	History := Readonly, Error := Continue);
	If Status(Data_file) = 0 Then 
	Begin
		Reset(Data_file);
		For line_num := 1 to 150 do 
		Begin
			Readln(Data_file,Help_Line);
			For Char_num := 1 to 60 do
			   stars_line[ line_num , Char_num ] := help_line[ Char_num ] ;
		end
	End 
	Else 
	Begin
		write_st(line);
		Write_st(' Can''t find Data File. Game Aborted !');
		Break;	
		Goto 1;
	End
End; { Read_Data_File }
	
PROCEDURE New_Star_Line;
{ create a new string of stars and blacks }

Var 
	line_num,
	Index_1,
	Start_point,
	index 	: integer;
 
Begin
	IF Back_Thrust then
	Begin
		Player_Row := Player_Row - 1 ;
		IF Player_Row < 5 then Player_Row := 5;
	End
	Else
	Begin
		For index :=3 To 22 Do Screen[ index ] := Screen[ index + 1 ] ;

		write_st(ansi_mode);
		write_st(place);
		write_st(large_100);
		write_st(vt52);

	  	line_num :=Random( Sector + 1, Sector + Random( 1, 10));
		IF Line_num > 150 then Line_num := 150;

	 	Start_point :=Random (1, 20);

		For Index := Start_point TO Start_point + 39 Do
			screen[ 23, Index - Start_point + 1] := 
				stars_line [ line_num , index ];

		index := 0;
		While index <= 39 do
		Begin
			Index := Index + 1;

			If screen [ 23 , index] = star
			   then write_ch(23,index,star);

			IF (Index < 39 ) 
			   And (screen [23 ,index] = Star)
			   And (screen [23 ,index + 1] = Star) then 
			   Begin
				write_1(Star);
				Index := Index + 1;
			   End;

			IF (Index < 39 ) 
			   And (screen [23 ,index] = Star)
			   And (screen [23 ,index + 1] = Blank) then 
			   Begin
				write_1(Blank);
				Index := Index + 1;
			   End;
		End;

		Break;
	End; { if not back thrust }

	IF Back_Thrust
	  then write_ch(Player_Row + 1,Player_col,blank)
	  Else write_ch(Player_Row,Player_col,blank);
	Write_ch(3,greebie_pos,blank);
	Write_ch(down_count,shot_row,blank);

	at(23,1);
	IF not Back_Thrust then write_st(line);

	Back_Thrust := False;

	Break;

End; { new_star_line}

PROCEDURE Move_Player;
{ get the next move from player and move the ship }

Begin

	CASE  TT_1_Char_Now OF
		'1','4','7'     : this_move := left;

		'2','5','8'     : this_move := down;

		'3','6','9'     : this_move := right;

		'0'		: IF Player_Row > 5 
				     then Back_Thrust := true;

		'Q','q','e','E' : dead := true;
		otherwise this_move := this_move;

	end; { case }

	IF not Back_Thrust Then
	Begin
		Player_col := Player_col + this_move;
		if Player_col  < min_left then Player_col := min_left;
		if Player_col  > max_right then Player_col := max_right;
	End;

	write_ch(Player_Row,Player_col,player);

end; { Move_Player }

PROCEDURE check_dead;
{ check if player has crashed against an asteroid }

Begin
  If screen[Player_row +1,Player_col] = star then dead := true;

End; { check_dead }

PROCEDURE Fire_part_1;
{ part of the fire procedure below }

Begin
	IF shot_row < min_left then
	  shot_row := min_left;
	IF shot_row > max_right then
	  shot_row := max_right;
	down_count := down_count + 1;
	case screen[down_count - 1,shot_row] of
	blank : begin
			IF screen[down_count, shot_row] = star then
			Begin
				shot_going := false;
				screen[down_count, shot_row] := blank;
				write_ch(down_count-1,shot_row,blank);
			End
			else
			Begin
				If down_count >= 23 then 
				begin
					Shot_going := false;
					write_ch(down_count-2,shot_row,blank);
				End
				else
				begin
					write_ch(down_count,shot_row,missile);
				end;
			end
		End;	
	star : begin
			write_ch(down_count-2,shot_row,blank);
			screen[down_count - 1,shot_row] := blank;
			shot_going := false;
		end;
	OtherWise write_ch(down_count,shot_row,missile);

	End; { case }
	if ( down_count = Player_Row) AND
	   (shot_going) AND
  	  (shot_row = Player_col) then 
	begin 
		dead := true;
		shot_going := false;
	end;

	If not shot_going then shot_row := 0;

End; { fire part 1 }


PROCEDURE fire_a_shot;
{ fire a new shot if one is not yet going
  and calculate if missile has hit anything }
Var 
	Choise : integer;
Begin 
	IF not dead then
	Begin
		if  not shot_going then
		begin
			down_count := 3;
			shot_going := true;
			shot_row := greebie_pos;
		end;

		IF (Sector < 20 ) 
		  Then choise := 1 
		  Else
		  IF ( Sector >= 20 ) And ( Sector < 40 ) 
		    Then choise := 2
		    Else
		    IF (Sector >= 40 ) And ( Sector < 60)
		      Then choise := 3
		      Else choise := 4;
	
		Case choise of
		1:fire_part_1;

		2: Begin
			IF (Sector = 20 ) and ( field = 1) then
			  Write_Ch(1,1,bell);

			IF (screen[down_count + 1, shot_row] = star) And
			(screen[down_count + 1,shot_row + left] = star) then
			  shot_row := shot_row + 1;

			IF (screen[down_count + 1, shot_row] = star) And
			(screen[down_count + 1,shot_row + right] = star) then
			  shot_row := shot_row - 1;

			IF (screen[down_count + 1, shot_row] = star) And
			(screen[down_count + 1,shot_row + left] = Blank) And
			(screen[down_count + 1,shot_row + right] = Blank) then
			Begin
				Case Random( 1,2 ) of
					1: shot_row := shot_row - 1;
					2: shot_row := shot_row + 1;
				End; {case}
			End;

			IF (screen[down_count + 2, shot_row] = star) And
			(screen[down_count + 2,shot_row + left] = star) then
			  shot_row := shot_row + 1;

			IF (screen[down_count + 2, shot_row] = star) And
			(screen[down_count + 2,shot_row + right] = star) then
			  shot_row := shot_row - 1;

			IF (screen[down_count + 2, shot_row] = star) And
			(screen[down_count + 2,shot_row + left] = Blank) And
			(screen[down_count + 2,shot_row + right] = Blank) then
			Begin
				Case Random( 1,2 ) of
					1: shot_row := shot_row - 1;
					2: shot_row := shot_row + 1;
				End; {case}
			End;

			fire_part_1;
		end; { 2 }

		3:Begin
			IF (Sector = 40 ) and ( field = 1 ) then 
			   Write_Ch(1,1,bell);
			IF shot_row > Player_col then 
				shot_row := shot_row + left;
			IF shot_row < Player_col then 
				shot_row := shot_row + Right;
			fire_part_1;
		End; { 3 }

		4:Begin
			IF (Sector = 60 ) and ( field = 1 ) then 
			   Write_Ch(1,1,bell);
			Case Random( 1,2 ) of
			1: Begin
				IF shot_row > Player_col then 
				  shot_row := shot_row + left;
				IF shot_row < Player_col then 
				  shot_row := shot_row + Right;

			Fire_part_1;

			End; { 1 }

			2: Begin
				IF (screen[down_count + 1,shot_row] = star) And
				(screen[down_count + 1,shot_row + left] = star)
				   then shot_row := shot_row + 1;

				IF (screen[down_count + 1,shot_row] = star) And
				(screen[down_count+ 1,shot_row + right] = star)
				 then shot_row := shot_row - 1;

				IF (screen[down_count + 1,shot_row] = star) And
				(screen[down_count+1,shot_row+left] =Blank) And
				(screen[down_count +1,shot_row+ right] = Blank)
				then
				Begin
					Case Random( 1,2 ) of
						1: shot_row := shot_row - 1;
						2: shot_row := shot_row + 1;
					End; {case}
				End;

				IF (screen[down_count+ 2, shot_row] = star) And
				(screen[down_count + 2,shot_row + left] = star)
				  then shot_row := shot_row + 1;
			
				IF (screen[down_count + 2,shot_row] = star) And
				(screen[down_count +2,shot_row + right] = star)
				  then shot_row := shot_row - 1;
			
				IF (screen[down_count +2, shot_row] = star) And
				(screen[down_count+2,shot_row+left] =Blank) And
				(screen[down_count+2,shot_row + right] = Blank)
				 then
				Begin
					Case Random( 1,2 ) of
						1: shot_row := shot_row - 1;
						2: shot_row := shot_row + 1;
					End; {case}

				End;

				Fire_part_1;

				End; { 2 }
			End; {case}

		End; { 4 }

		end;{case}

	End; { if not dead }

End; { fire_a_shot }


PROCEDURE move_greebie;
{ work out the next position of the greebie }

Begin
	IF greebie_pos > Player_col then 
	begin
		greebie_pos := greebie_pos + left;
		IF greebie_pos > Player_col then 
		  greebie_pos := greebie_pos - ext_move;
	end;

	IF greebie_pos < Player_col then 
	begin
		greebie_pos := greebie_pos + Right;
		IF greebie_pos < Player_col then 
		  greebie_pos := greebie_pos + ext_move;
	end;

	IF (screen[4, greebie_pos] = star) AND
	   (screen[4,greebie_pos + left] = star) then
	  greebie_pos := greebie_pos + 1;

	IF (screen[4, greebie_pos] = star) AND
	   (screen[4,greebie_pos + Right ] = star) then
	   greebie_pos := greebie_pos - 1;

	IF (screen[4, greebie_pos] = star) AND
	   (screen[4,greebie_pos + Right ] = Blank) AND
	   (screen[4, greebie_pos + Left] = Blank) then
	Begin
  		Case Random( 1, 2) of
			1: greebie_pos := greebie_pos + 1;
			2: greebie_pos := greebie_pos - 1;
		end;
	end;

        IF greebie_pos < min_left then
          greebie_pos := min_left;

	IF greebie_pos > max_right then
	  greebie_pos := max_right;
	write_ch(3,greebie_pos,greebie);
	
end; { move_greebie }

PROCEDURE display_dead;
{ a little bit of flashy graphics }
Var
	i : integer;

begin
	write_st(Ansi_mode);
	for i:=1 to 10 do
	Begin
		if odd(i) then
		  Begin
			  write_st(White_100);
		   	  Break;
		  End
		else
		  Begin
			  write_st(Black_100);
		   	  Break;
			  writeln(bell);
		  End;
	end;
End;{ display_dead }

PROCEDURE set_up;
{ initialisation of variables etc.. }
Var
	t	: Integer;

Begin

	seed := clock;

	write_st(Ansi_mode);
	write_st(clear_100);
	write_st(scroll_region);
	write_st(Jump_100);

	for t := 1 to 22 do 
	begin
		writev(char_string,Esc,'[',t:1,';',0:1,'H');
		write_st(Char_string);
		write_st(large_100);
	Break;
	end;

	Back_Thrust := False;
	dead := false;
	greebie_dead := false;
	shot_going := false;

	Score := 0;

	Player_Row := 12;

	ext_move := 0;

	Time_out := 30;

	test_num := 970;

	field := 0;
 	
	greebie_pos := Random (3,38);

	Player_col := centre;

        writev(char_string,esc,'[',24:1,';',12:1,'H','SECTOR :              FIELD :                SCORE :');

        write_st(char_string);
	write_st(vt52);

	break;

End; { set_up }

PROCEDURE change_int( temp : integer);
Var
	i	: integer;
Begin
	For i := 1 to 7 do ch[i] := blank;
	i := 0;
	While temp > 0 Do
	Begin
		i := i + 1;
		ch [ i ] := chr((temp mod 10 ) + ord('0'));
		temp := temp div 10;
	End;

End; { change_int }

PROCEDURE Check_Previous_Score;
{ Check to see if player wants to start further ahead. }

Begin
	IF Last_Score > 2440 then
	Begin
		write_st(clear_100);
		write_st(Home_100);
		At(1,1);
		write_st(large_100);
		At(1,1);
		write_st('     Hi there HOT SHOT !!!');
		write_st(line);
		write_st(line);
		write_st('                  Do you want to Begin anew ,');
		write_st(line);
		write_st('                  OR continue from sector 30 ?');
		write_st(line);
		write_st(line);
		write_st('   Press "B<egin>" to start Anew OR any character to start at Sector 30.');
		Break;
		Case TT_1_Char of
			'b','B': Sector := 0;
			Otherwise Sector := 30;
		End; { case }
	End;

End; { Check previous Score }

PROCEDURE increment_Sector;
{ add 1 to Sector if fields is = to 20 }

Begin

	Sector := Sector + 1;
	field := 0;
	test_num:= test_num - 3;
	if Sector > 10 then ext_move := 1;

End; { increment_Sector }

Begin { ...main... }

	Read_Help_File;
	Read_Data_File;
	Check_Previous_score;
	set_up;

	repeat
		IF field = 20 then
		  time_out := Time_out - 1;

		If time_out < 1 then time_out := 1;

		Sleep_set( 21, Time_out);

		Sleep_Start;

		Field := Field + 1;

		if field = 1 then 
		begin
			change_int(sector);
			At(24,21);
			write_3(ch[3],ch[2],ch[1]);
		End;

		change_int(field);
		at(24,44);
		write_3(ch[3],ch[2],ch[1]);

		calculate_score;

		change_int(score);
		at(24,67);
		write_6(Ch[6], Ch[5], Ch[4], Ch[3], Ch[2], Ch[1]);

		Break;

		new_star_line;

		Move_Player;

		move_greebie;

		Fire_a_shot;

		check_dead;

		if field = 20 then 
		   increment_Sector;

		write_ch(24,78,blank);

		Break;

		Sleep_Wait;

	until dead;

	if dead then display_dead;

	top_ten( Score );

	1: { the end of program }
end. { ...main... }
