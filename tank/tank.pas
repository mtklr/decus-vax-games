
{$S-}
{$C+}
{

		Program	: Tank

		Authors	: Rex Croft       - Macro

                          Murray Speight - Pascal 

		Place	: University Of Waikato 

		Date 	: May 1982 

	Software Is Subject To Change Without Notification
        The Author And His Family assume No Rsponsability For
	Its Reliabliity Or Use. 

         }

Program Tank(Input,Output);

Label	9999;  { For Abortive exit Of Pgm }


Const 	Max_Num_Players	= 8;             { Up To 8 Players }
	Screen_Dim_X 	= 23;            { PLaying Board 40 * 23 }
	Screen_Dim_Y	= 40;
	Len_Of_Buff	= 1024;          { Buffer to Write Chars }
        Max_Name_Length = 32;            { Lenngth of a players name }

Type 	Player_Responce = Packed Array [1..Max_Num_Players] Of Char;
	Buffer		= Packed Array [1..Len_Of_Buff] Of Char;	
	Positions	= Array [1..Max_Num_Players] Of INteger;
	Players_Screen	= Array [1..Screen_Dim_X,1..Screen_Dim_Y] Of Char;
	Died_Type	= Array [1..Max_NUm_Players] Of Boolean;
	Name_Line	= Packed array [1..max_Name_Length] of Char;
        Name_Table	= Array [1..Max_Num_Players] of name_LIne;

Var 	Responce 	,			{ What Players Have Typed }
	Head_Sym	: Player_Responce;      { What Symbol is THe Head }
	Screen		: Players_Screen;       { 23 * 40 Array For Screen}
	Name		: Name_Table;           { Names Of Each Player }
        Init_Pos_X	,                       { Where initaially Players Start }
        Init_Pos_Y      ,                       {  "" "" For Y Coord }
	Score		,                       { Score Of Each PLayer }
        Game		,                       { Num Games Each PLayer Played }
	Games_Won 	,                       { Games Won By Each PLayer }
	Move_X		,                       { What Dir Each Playe Is Moving X Coord }
	Move_Y		,                       { "" "" Y Coord }
	Head_X		,                       { Where The Head Is For Each Player X Coord }
	Head_Y	 	,                       { "" "" Y Coord }
	Start_X		,
	Start_Y		,
        Rand		,
        Laser_Charge	,
	End_X		,
	End_Y		: Positions;            { "" "" Y Cord }
	TT_Buff		: Buffer;               { Lenght Of Buffer To Hold Screen Output }
	TT_Len		,                       { String To Hold Screen Output }
        Who_Is_PLaying  ,                       { Word With Bits Set As To Who is Playing }
	You		,                       { Which Number You are } 
	Dummy 		,                       { Dummy argument }
	Num_players     ,                       { How Many people are Playing }
	Max_Player_Number ,                     { The Highest PLayers Number who is Playing }
	Move_Count	,
        Num_Moved_Last_Round    ,               { Number of players who moved last Round ( Last Screen Update ) }
	Players_Removing	: Integer;      { Are We Removing Odd 1 or even 2 players Tails }
	Fired		,
        Shields         ,
	Quit		,                       { Has The PLayer Quit (not playing ) or is He Playing }
	Died 		: Died_Type;            { Has The PLayer Died ( Died If He has Quit ) }
	Back_space	,
	Line_Feed	,
	Up_Line		,
	Esc		: Char;                 { esc For escape sequences }
	Seed		: Real;                 { Seed for random number generaotor }
        Time_Now	: Packed array [1..11] Of Char;

Procedure Break_Buff;

   Procedure Snake_Screen( Var Line : Buffer ; Var Lenght : Integer );extern; 

{ Only Call This Once From The Add_head Function 

   Does not write array to screen }

Begin
   Snake_Screen(TT_Buff,TT_Len); 
   TT_Len := 0;
end;


Procedure Help_Screen;extern;

Procedure Buff_Pos_Char_1( X,Y : Integer ; Ch : Char );

{ Write Char at Pos X,Y in Buffer }

Begin
   TT_Buff[TT_Len+1] := Esc;
   TT_Buff[TT_Len+2] := 'Y';
   TT_Buff[TT_Len+3] := Chr(31+X);
   TT_Buff[TT_Len+4] := Chr(31+Y);
   TT_Buff[TT_Len+5] := Ch;
   TT_Len := TT_Len + 5;
end;

Procedure Buff_Pos( X,Y : Integer);

{ Write Char at Pos X,Y in Buffer }

Begin
   TT_Buff[TT_Len+1] := Esc;
   TT_Buff[TT_Len+2] := 'Y';
   TT_Buff[TT_Len+3] := Chr(31+X);
   TT_Buff[TT_Len+4] := Chr(31+Y);
   TT_Len := TT_Len + 4;
end;

Procedure Buff_Char_1( Ch : Char );

{ Write Char at Pos X,Y in Buffer }

Begin
   TT_Buff[TT_Len+1] := Ch;
   TT_Len := TT_Len + 1;
end;

Procedure Buff_Char_3( Ch_1,Ch_2,Ch_3 : Char );

{ Write Char at Pos X,Y in Buffer }

Begin
   TT_Buff[TT_Len+1] := Ch_1;
   TT_Buff[TT_Len+2] := Ch_2;
   TT_Buff[TT_Len+3] := Ch_3;
   TT_Len := TT_Len + 3;
end;


Function at(X,Y: Integer):Char;

{ Posotion Cursor at X , Y this Is For Use In Write Statments }

Begin
   Write(esc,'Y',chr(31+X),Chr(31+Y));
   at := Chr(0);
end;


Function Snake_Init(Var You :  INteger ; Var Game_going : Integer):Integer;extern;

Procedure Name_Set(Var Name : Name_Line );extern;

Procedure Name_Get(Var Name : Name_Line ; var Play : Integer );extern;

Procedure Score_Set( Var Player,Score,Games_PLayed,wins : INteger);extern;

Procedure Score_Get( Var Player,Score,Games_Played,wins : Integer );extern;

Procedure Snake_Start(var Whos_PLaying : Integer ; var Rand : Positions );Extern;

Procedure Snake_Read(Var Directions : Player_Responce );Extern;

Procedure Snake_Game_End;extern;

Procedure Snake_Wait;Extern;

Procedure Snake_Game_count( Var Num : Integer);extern;

Procedure Snake_Dead(Var PLayer : Integer );extern;

Procedure Sleep( Num_Sec : Integer);extern;

Function Mth$Random(var Seed : real):Real;extern;

Procedure Draw_Scores;

Const Len_Scale = 50;

Var I,num_on_table,play,Top_play,Total_Num_Games: Integer;
    This_Score,	Max_score , Score_Ratio : Real;


Begin
   Time(Time_Now);
   Num_on_Table := 0;
   Write(esc,'H',Esc,'J',Esc,'G',esc,'<');
   Write(' Player   User         Name               Score  Game  Won     ');
   If ( Time_Now[1] = '2' ) Then Begin
      If ( Time_Now[2] >= '2' ) Then Begin
         Time_Now[1] := '1';
         Time_Now[2] := chr( Ord(Time_Now[2]) - 2);
      end Else begin
         Time_Now[1] := ' ';
         Time_Now[2] := chr( Ord(Time_Now[2]) + 8);
      end;
      Write(esc,'[1m',Time_Now:5);
      Writeln(' pm',esc,'[0m');
   End Else Begin
      If (( Time_Now[1] = '1' ) and ( Time_Now[2] > '2' )) THen Begin
         Time_Now[1] := ' ';
         Time_Now[2] := chr( Ord(Time_Now[2]) - 2);
         Write(esc,'[1m',Time_Now:5);
         Writeln(' pm',esc,'[0m');
      end Else Begin
         If Time_Now[1] = '0' Then 
            Time_Now[1] := ' ';
         Write(esc,'[1m',Time_Now:5);
         If Time_Now[2] = '2' Then 
            Writeln(' pm',esc,'[0m')
         else
            Writeln(' am',esc,'[0m');
      end;
   end;
   writeln;
   Max_score := -99999.0;

   { Find The Top Player  goes By The his Score And Num Of Games Played }
   For PLay := 1 to Max_Num_PLayers do  begin
      Score_get(Play,Score[PLay],Game[PLay],Games_won[play]);
      If Game[Play] > 0 Then Begin
         This_score := (Score[play]+ Games_won[play]*10) / (Game[play])**(0.9);
         If This_score > Max_score Then Begin
            Top_Play := Play;
            Max_score := This_score + 1.0;
         end;
      end;
   end;
   For Play := 1 to Max_Num_PLayers do Begin
      If Game[PLay] > 0  Then Begin   { IF Games PLayed > 0 Then You Are PLaying  }
         Num_On_Table := Num_On_Table + 1;
         If PLay = Top_PLay Then 
            Write(esc,'[1m');  { High intensity Flash }
         Write(Play:4);
         Write('    ',Name[Play]:32);
         write(Score[PLay]:7);         { Print Info }
         Write(Game[Play]:6);
         Writeln(Games_won[play]:5,esc,'[0m'); { Exit High Intens }
      End;
   End;
   writeln; 
   Writeln(' Player  Score Indicator ');
   Writeln;
   For Play := 1 to Max_Num_PLayers do Begin
      If Game[PLay] > 0  Then Begin   { IF Games PLayed > 0 Then You Are PLaying  }
         If PLay = Top_PLay Then 
            Write(esc,'[1m');  { High intensity Flash }
         Write(Play:4);
         Write('     ',Esc,'[7m'); { Rev Video }
         Score_Ratio := (Score[play]+Games_won[PLay]*10)*Len_Scale
                            / ((Game[play])**(0.9)*Round(max_score));
         For I := 1 to Round(Score_Ratio) do 
            Write(' ');
         If PLay = Top_PLay Then 
             Write(Esc,'[0m',Esc,'[1;5m ** Champ ** ');
         Writeln(esc,'[0m'); { Normal Video }
      end;
    End;

{ Print The Games You Have Played With The Totak Num of Games Played so Far }
   Snake_Game_Count( Total_Num_games );
   writeln;
   Writeln(' Game # ',Game[You]:1,'    Total # ',Total_Num_Games:1,
           '		Please Wait For Next Game ... ',Esc,'[?2l',Esc,'F');
   If Num_on_Table <= 1 Then 
      Goto 9999;
end;

Procedure Draw_screen;

Var play,I,X,Y,Line_at : Integer;

   Function Min(A,B:Integer):Integer;

   Begin
      If A < B Then 
         Min := A 
      Else
         Min := B
   end;

Begin { Draw Screen }
   Write(at(1,1),esc,'J',esc,'<',esc,'(0',esc,'<',esc,'(0');     { Clear Home }
   Write(esc,'#6l');
   For Y := 1 To (Screen_Dim_Y-2) Do 
      Write('q');
   Writeln('k');
   For X := 2 To ( Screen_dim_X - 1 )  Do begin
      Write(esc,'#6x');
      Writeln(Esc,'[',(Screen_dim_Y-2):1,'Cx');
   end;
   write(esc,'#6m');
   For Y := 1 to (Screen_Dim_Y-1) Do 
      Write('q');
   Writeln('j');
   Writeln(Esc,'[1;1H',Esc,'[?2l',esc,'F');

end;

   
Procedure initalise_Positions;



Var Mult,Play,X,Y : Integer;


Begin

Players_Removing := -1;  { On First Few Moves Want To Draw Hazzards }

Snake_Start(Who_Is_Playing,Rand);


{ Randomly Position The Starting Pos Of The PLayers }
For play := 1 to Max_num_players do  Begin
   Head_X[Play] := Init_Pos_X[Rand[Play]];
   Head_Y[play] := Init_Pos_Y[Rand[PLay]];
   Laser_Charge[play] := 0;
   Shields[play] := True;
   Fired[play] := False;
   Move_X[Play] := 0;
   Move_Y[PLay] := 0;
end;

Mult := 2**(Max_num_Players - 1 );  { 2 ** Number of PLayers - 1}
Num_Players := 0;

{ Examine Each Bit In Mult To See If You Are Playing }
Max_player_number := 0;
For Play := Max_Num_PLayers downto 1 do begin
   If ( Who_Is_PLaying div Mult ) = 1 Then begin
      Name_Get(Name[Play],Play);
      Num_Players := Num_PLayers + 1;
      Quit[play] := False;   { Bit Set You Are Playing }
      Who_is_Playing := Who_is_Playing - Mult;
      If Max_player_number = 0 Then 
         Max_player_number := play ;{ The Highest Numbered Player }
   end else begin
      Quit[Play] := True;   { Bit Not Set Not Playing ie Quit }
   end;
   Mult := Mult div 2;
end;

Num_Moved_Last_Round := 0;

{ If You are PLaying Then You Havnt Died }
For Play := 1 to Max_Num_Players Do  Begin
   If Not Quit[Play] Then Begin
      Died[Play] := False;
      Num_Moved_Last_Round := Num_Moved_Last_Round + 1;
   end else
      Died[play] := True;
   responce[Play] := ' ';   { Initalise First Responce Should Not BE Needed }
end;
Move_Count := 0;
For PLay := 1 to Max_Num_PLayers do 
   Game[PLay] :=   Game[PLay] + 1;
For X := 1 To Screen_Dim_X do 
   For Y := 1 to Screen_Dim_Y do
      Screen[X,y] := ' ';
For Y := 1 To Screen_Dim_Y do Begin
   Screen[1,Y] := 'q';
   Screen[Screen_Dim_X,Y] := 'q';
end;
For X := 1 To Screen_Dim_X Do Begin
   Screen[X,1] := 'x';
   Screen[X,Screen_Dim_Y] := 'x'; 
end;
Screen[1,1] := 'l';
Screen[1,Screen_Dim_Y] := 'k';
Screen[Screen_Dim_X,1] := 'm';
Screen[Screen_Dim_X,Screen_Dim_y] := 'j';
Head_Sym[1] := chr(128+ord('1'));  { Set The Bits In The Chars }
Head_Sym[2] := chr(128+ord('2'));
Head_Sym[3] := chr(128+ord('3'));
Head_Sym[4] := chr(128+ord('4'));
Head_Sym[5] := chr(128+ord('5'));
Head_Sym[6] := chr(128+ord('6'));
Head_Sym[7] := chr(128+ord('7'));
Head_Sym[8] := chr(128+ord('8'));

For Play := 1 to Max_Num_PLayers do 
      Screen[Head_X[Play],Head_Y[Play]] := 'O';
{ Note If This Procedure Is Only Called When You Are Master Snake 
  Draw Screen Should Be In The Mainlkine Before Init_Pos
  And The Writing Of The PLayers Pos Should Be To The Buffer 
  And Then Written To All Who Are PLaying }

Draw_screen;   

{ Pos Inital Player Positions }
For Play := 1 to Max_Num_PLayers do  
   If ( Not Quit[Play]  ) and ( Play <> You ) Then  
      Writeln(at(Head_X[Play],Head_Y[Play]),Head_sym[Play])
   Else 
      If Play = You Then 
         Writeln(at(Head_X[You],Head_Y[You]),'`')
      Else 
         Writeln(at(Head_X[play],Head_Y[Play]),'O');
Sleep(1);
end;

Procedure Initalise_Mainline;

Var Zero,Init_Rep,PLay,Name_Pos,Game_Going : Integer;

Procedure Verify_name(VAr Name : Name_Line );

Var I : INteger;


Begin
   For I := 1 to Max_Name_length do   { Remove All Invalid Chars From The Name}
      If ( Name[i] < ' ' ) Then Begin
            Write(chr(7));
            Name[i] := ' ';
      end;
end;


Begin
   Esc := Chr(27);
   Back_Space := CHr(8);
   Line_Feed  := Chr(10);
   Up_Line    := 'A'   { Used With <ESC>A For Move up One Line };
   Seed := Clock;
   TT_Len := 0;
   

   { set where Each Player Starts }

   Init_Pos_X[1] := 2;
   Init_Pos_Y[1] := 2;
   
   Init_Pos_X[2] := Screen_dim_x - 1;
   Init_Pos_Y[2] := Screen_dim_Y - 1;
   
   Init_Pos_X[3] := 2;
   Init_Pos_Y[3] := Screen_dim_y - 1;
   
   Init_Pos_X[4] := Screen_dim_x - 1;
   Init_Pos_Y[4] := 2;
   
   Init_Pos_X[5] := 2;
   Init_Pos_Y[5] := Screen_dim_Y div 2;
   
   Init_Pos_X[6] := Screen_dim_x - 1 ;
   Init_Pos_Y[6] := Screen_dim_Y div 2;
   
   Init_Pos_X[7] := Screen_dim_x div 2 + 1;
   Init_Pos_Y[7] := 2;
   
   Init_Pos_X[8] := Screen_dim_x div 2 + 1;
   Init_Pos_Y[8] := Screen_dim_Y - 1;

   Writeln(Esc,'<'); { Vt52 Mode }
   Writeln(Esc,'[1;1H',Esc,'[J');    { Clear Screen }
   Init_rep := Snake_Init(You,Game_going);
   You := You + 1;   
   If Init_rep = 1 Then Begin
      { you are the First Person to play zero all the scores }
      For Play := 1 to Max_Num_PLayers do begin
         Zero := 0;
         Score_Set(Play,Zero,zero,zero);
      end;
      Help_Screen;
      Writeln(esc,'[1;1H',Esc,'[?2l');
      Writeln(at(22,3),' Please Enter Your Name Player #',You:1);
      Write(at(22,51));
      Readln(Name[You]);
      Verify_Name(Name[You]);
      Name_set(Name[You]);
      Write(at(22,3), ' Hit < Return > When Others Ready   ');
      Readln;
      Writeln;
      Write(at(22,3), ' Please Wait For Game To Start      ');
      Writeln;
   end Else Begin
      If You = 0 Then Begin
         Writeln(esc,'[1;18H',Esc,'#3TANK');
         Writeln(esc,'[2;18H',Esc,'#4TANK');
         Writeln(esc,'[4;8H' ,Esc,'#6  Sorry No Tanks Available');
	 Sleep(3);
         goto 9999;
      end else begin { Init_rep = 0 } 
         Help_Screen;
         Writeln(esc,'[1;1H',Esc,'[?2l');
         Writeln(at(22,3),' Please Enter Your Name Player # ',You:1);
         Write(at(22,51));
         Readln(Name[You]);
         Verify_name(Name[You]);
         Name_set(Name[You]);
         Writeln;
         Write(at(22,3), ' Please Wait For Game To Start     ');
         Writeln;
         If Game_Going = 1 Then 
            Snake_Game_End;
      end;
   end;
   Game[You] := 0;
end { Initalise Mainline };

[GLOBAL] Function Add_head( Var Responce : Player_responce ):Integer;

const Max_num_Hazzards = 32;
      Moves_Per_Player = 75;
      Gap_Around = 1;

Var Play, Dir_X, num_Moved, Dir_Y, Pos_x, Pos_Y ,X,Y,Num_Hazzards : Integer;
    Died_This_Round					  : Died_TYpe;

Procedure Remove_Phaser;

var X,y,play : Integer;

begin
For Play := 1 to max_num_players do Begin
   If Fired[play] Then begin
      Buff_Pos(Start_X[Play],Start_Y[PLay]);
      IF Start_X[play] = End_X[play] Then Begin       { Right Or LEft }
         If Start_Y[play] < End_y[Play] Then     { Right }
            For Y := start_y[play] to End_Y[play] do  begin
               Buff_Char_1(' ');
            end
         Else                                    { Left }
            For Y := start_y[play] downto End_Y[play] do  begin
               Buff_Char_3(' ',Back_space,Back_Space);
            end;
      End Else Begin      { Up or Down }
         Y := Start_Y[PLay];
         If Start_X[play] < End_X[Play] Then   { Down }
            For X := start_X[play] to End_X[play] do  Begin
               Buff_Char_3(' ',Back_Space,Line_Feed);
            End
         Else                                  { Up }
            For X := start_X[play] downto End_X[play] do  begin
	       Buff_Char_3(' ',Esc,Up_Line);
               Buff_Char_1(Back_Space);
            end;
      end;
   Fired[play] := False;
   End;
end;                  
end;

Procedure Player_Died(play : Integer; By_Phaser_Shot : Boolean);

Begin
   If Not Died_This_round[play] Then begin
      Died_This_Round[Play] := True;
      If ( Not Shields[play] ) or ( Not By_Phaser_Shot ) Then Begin
         Buff_Pos_Char_1(Head_X[Play],Head_Y[PLay],'*');
         Screen[Head_X[Play],Head_Y[Play]] := ' ';      { Revove Player Form Screen So Can't Die Again }
         If Not Shields[play] Then Begin
            If Num_PLayers <> Num_Moved_Last_Round Then  
               Score[Play] := Score[Play] + 
                     (( Num_PLayers - Num_Moved_Last_Round  + 1 )**2 * 100 ) 
                     div ( NUm_Players**2);
            Snake_Dead(play); 
         End;
       End Else Begin
         Buff_Pos_Char_1(Head_X[Play],Head_Y[PLay],'+');
         Screen[Head_X[Play],Head_Y[Play]] := '+';      { Revove Player Form Screen So Can't Die Again }
      End;
   End;
end;

Procedure Fire_Phaser(Dir_x,Dir_y,Pos_x,Pos_Y,play: Integer);

Const Max_Len_shot = 10;


Var at_x,at_y,len_shot,Max_Len_this_Shot: Integer;

Procedure Check_end_of_Shot;

Const Points_For_Killing = 64;

Begin
      Case Screen[at_x,At_Y] of
       '1','2','3','4',
       '5','6','7','8' : Begin
                           Score[Play] := Score[Play] + Points_for_Killing;
                           PLayer_died(Ord(Screen[at_x,at_y]) - Ord('0'),True);
                         end;
       'X'	       : 
			 Begin
                            Buff_Char_3(Esc,'G','x');
                            Buff_char_1(Esc);
                            Buff_char_1('F');
                            Screen[at_x,At_Y] := 'H';
                            Score[Play] := Score[PLay] + 2;
	                 end;
        'H'	       : Begin
                            Buff_char_1(' ');
                            Screen[at_x,At_Y] := ' ';
                            Score[Play] := Score[play] + 3;
                         end;
        otherwise  { Nothing };
      end { Case }
End;


Begin
   If Laser_Charge[Play] >= Max_Len_Shot Then begin
      Max_Len_This_Shot := Max_len_Shot;
      Laser_Charge[play] := Laser_charge[play] - Max_len_Shot;
   end Else begin
      Max_Len_This_Shot := Laser_Charge[play];
      Laser_Charge[play] := 0;
   end;
   Fired[play] := True;
   Case (( Dir_X + 1 ) + ( Dir_Y+1)*4 ) of 
    { Right } 
    9 : Begin
         at_X := Pos_X;
         at_Y := Pos_Y + 1;
         Start_X[play] := at_X;
         Start_Y[play] := at_Y;
         Len_Shot := 0;
    	    Buff_Pos(at_x,At_Y);
         While ( Screen[at_X,At_Y] = ' ' ) and ( Len_shot < Max_Len_This_Shot ) do begin
            Buff_Char_1('q');
            Len_shot := Len_shot + 1;
            at_y := at_y + 1;
         end;
         Check_End_Of_Shot;
         End_X[Play] := At_X;
         End_Y[Play] := At_Y-1;
      end;
   { Left }
   1 : Begin
         at_X := Pos_X;
         at_y := Pos_Y - 1;
         Start_X[play] := at_X;
         Start_Y[play] := at_Y;
         Len_Shot := 0;
         Buff_Pos(at_x,at_Y);
         While ( Screen[at_X,At_Y] = ' ' ) and ( Len_shot < Max_Len_This_Shot ) do begin
            Buff_Char_3('q',Back_space,Back_Space);
            Len_shot := Len_shot + 1;
            at_y := at_y - 1;
         end;
	    Check_End_Of_Shot;
         End_X[Play] := At_X;
         End_Y[Play] := At_Y+1;
      end;
   { Up }
   4 : Begin
         at_X := Pos_X - 1  ;
         at_y := Pos_Y;
         Start_X[play] := at_X;
         Start_Y[play] := at_Y;
         Len_Shot := 0;
         Buff_Pos(at_X,at_Y);
         While ( Screen[at_X,At_Y] = ' ' ) and ( Len_shot < Max_Len_This_Shot ) do begin
            Buff_Char_3('x',esc,Up_Line);
            Buff_Char_1(Back_Space);
            Len_shot := Len_shot + 1;
            at_x := at_x - 1;
         end;
	    Check_End_Of_Shot;
         End_X[Play] := At_X+1;
         End_Y[Play] := At_Y;
      end;
   { Down }
   6 : Begin
         at_X := Pos_X + 1 ;
         at_y := Pos_Y;
         Start_X[play] := at_X;
         Start_Y[play] := at_Y;
         Len_Shot := 0;
	    Buff_Pos(at_x,at_Y);
         While ( Screen[at_X,At_Y] = ' ' ) and ( Len_shot < Max_Len_This_Shot ) do begin
            Buff_Char_3('x',Back_Space,Line_Feed);
            Len_shot := Len_shot + 1;
            At_x := At_x + 1;
         end;
	    Check_End_Of_Shot;
         End_X[Play] := At_X - 1;
         End_Y[Play] := At_Y;
      end;
   end {case};
   If Len_Shot = 0 Then 
      Fired[play] := False;
end;            

Procedure Fire_This_players_Phaser;

Begin
   If (( Ord(Responce[play]) > 16  ) Or ( Ord(responce[Play]) = 5 )) and 
      ( Not Died[Play] ) { Could Of Died By Hitting Wall } Then Begin
      Score[Play] := Score[Play] - 1;
      responce[play] := Chr(1);      { Change Responce So Does Not Keep On Firing }
      Fire_Phaser(Move_X[play],Move_Y[play],Head_X[play],Head_Y[play],Play);   
   end;
end;


Procedure Add_This_Players_Head;

var Player_On : integer;

Procedure Draw_Head;

Begin
Case ( Dir_X + 1 ) + ( Dir_Y + 1)*4 of 
   6 { Down } : Buff_Char_3(Back_Space,Line_Feed,Head_Sym[play]);
   9 { Right} : Buff_Char_1(Head_sym[Play]);
   1 { Left } : Buff_Char_3(Back_space,Back_space,Head_sym[play]);
   4 { Up  }  : Begin
      Buff_Char_3(Esc,Up_Line,Back_Space);
      Buff_Char_1(Head_sym[Play]);
      End;
   End{Case};
end;

begin
   If Not Quit[Play] And (Ord(Responce[PLay]) = 0 )  Then begin
      Died[PLay] := True;      { If PLayer quit Then 
      Quit[PLay] := True;         Initalise all Variables }
      Game[Play] := 0;
      Score[Play] := 0;
      Games_Won[PLay] := 0;
      Score_Set(Play,Score[Play],Game[PLay],Games_Won[PLay]);
   end else 
      If Not Died[Play]  Then Begin
         Laser_Charge[play] := Laser_Charge[play] + 1;         
         Dir_X := Move_X[Play];
         Dir_Y := Move_Y[PLay];
	 Pos_X := Head_X[Play];
         Pos_Y := Head_Y[Play];
         { Change Direction Of The Position You Move To is Not A Wall ie = '.' }
         Case Ord(responce[Play]) Mod 16 Of 
            8 : If Not ( Screen[Pos_x-1,Pos_Y] in ['X','H','q','x'] ) Then  Begin
                     Dir_X := -1 ;
                     Dir_Y := 0 ;      { Moving Up }
                  end;
            2 : If Not ( Screen[Pos_X+1,Pos_Y] in ['X','H','q','x'] ) Then Begin
                     Dir_X := 1;
                     Dir_Y := 0;         { Moving Down }
                  end;
            4 : If Not ( Screen[Pos_X,Pos_Y-1] in ['X','H','q','x'] ) Then Begin
                     Dir_X := 0;          { Moving Left }
                     Dir_Y := -1;
                  end;
            6 : If Not ( Screen[Pos_X,Pos_Y+1] in ['X','H','q','x'] ) Then Begin
                     Dir_X := 0;            { Moving Right }
                     Dir_Y := 1;
               end;
            otherwise { Do Nothing Same Dir As Before }
         end { Case };
	 If Not Died_This_Round[PLay] Then Begin
            If Screen[Pos_X,Pos_y] = '+' Then 
               Buff_Pos_Char_1(Pos_X,Pos_Y,Screen[Pos_x,Pos_Y])
            else begin 
               If ( Ord(Screen[Pos_X,Pos_Y]) = (Ord(Head_Sym[play])-128) ) Then Begin
                  Screen[Pos_X ,Pos_Y ] := ' ';
                  Buff_Pos_Char_1(Pos_X,Pos_Y,' ');
               End Else Begin 
                  If Screen[Pos_x,Pos_Y] = 'O' Then 
                     Buff_Pos_Char_1(Pos_X,Pos_Y,'O')
                  Else Begin  { Must be In Another Player or blank }
                     Buff_Pos_Char_1(Pos_X,Pos_Y,Esc);
                     Buff_Char_1('C');
                  End;
               End;
            End;
         End;
         { Given LAst Direction Or New Direction }
         If ( Dir_X = -1*move_X[play]) and ( Dir_Y = -1*Move_Y[play]) Then Begin
            Dir_X := Move_X[Play]; { Can't Reverse Your Direction }
            Dir_Y := MOve_Y[Play];
         end;
         If Screen[Pos_X + Dir_X , Pos_Y + Dir_Y ] in [' ','O','+','1'..'8'] Then Begin  
	    { Going into a Blank square ok to move }
            If Not Died_This_Round[Play] Then Begin { Just Want TO Fire Laser }
               If Screen[Pos_X + Dir_X , Pos_Y + Dir_Y ] = '+' Then
                  Shields[play] := True
               else
                  If Screen[Pos_X + Dir_X , Pos_Y + Dir_Y ] = '+' Then
                     Laser_Charge[play] := Laser_Charge[play] + 3;
               Pos_X := Pos_X + Dir_X;
               Pos_Y := Pos_Y + Dir_Y;
               Move_X[Play] := Dir_X;
               Move_Y[PLay] := Dir_Y;
               Head_X[Play] := Pos_X;
               Head_Y[Play] := Pos_Y;
               Draw_Head;
   	       If Not ( Screen[Pos_X,Pos_Y] = 'O' ) Then 
                  Screen[Pos_X,Pos_Y] :=  chr(Ord(Head_sym[PLay])-128); { Get Rid Of First Bit Set For Comparisons Later }
            End { If Not Died_This_Round } ;
         end else begin { You HAve Died Hit Into A Non Blank Square }
            If Not Died_This_Round[PLay] Then Begin
               Pos_X := Pos_X + Dir_X;
               Pos_Y := Pos_Y + Dir_Y;
               Move_X[Play] := Dir_X;
               Move_Y[PLay] := Dir_Y;
   	       Head_X[Play] := Pos_X;
               Head_Y[Play] := Pos_Y;
               If Screen[Pos_X , Pos_Y ] = 'x' Then Begin
                  Head_X[play] := Screen_Dim_X - Head_X[play] + 1;
                  If Pos_Y = Screen_Dim_Y Then 
                     Head_Y[play] := 2
                  Else
                     Head_Y[play] := Screen_Dim_Y - 1;
		  If not ( Screen[Head_X[play],Head_Y[play]] = 'O') Then 
                     Screen[Head_X[play],Head_Y[Play]] :=  
                        chr(Ord(Head_sym[PLay])-128); 
                  Buff_Pos_Char_1(Head_X[Play],Head_y[play],Head_Sym[play]);
               end Else
                  If Screen[Pos_X,Pos_Y] = 'q' Then Begin
                     Head_Y[play] := Screen_Dim_Y - Head_Y[play] + 1;
                     If Pos_X = Screen_Dim_X Then
                        Head_X[play] := 2
                     Else
                        Head_X[play] :=  Screen_Dim_X - 1;
      		     If Not ( Screen[Head_X[play],Head_Y[play]] = 'O' ) Then 
                        Screen[Head_X[play],Head_Y[Play]] :=  
                              chr(Ord(Head_sym[PLay])-128); 
                     Buff_Pos_Char_1(Head_X[Play],Head_y[play],Head_Sym[play]);
                  End Else 
   	             player_Died(play,False);
            End;
         end;
      end;
end;

 Procedure Jump_Player( Play : Integer );

 Begin
   Head_X[Play] := Init_Pos_X[Rand[play]];
   Head_Y[Play] := Init_Pos_Y[Rand[play]];
   Move_X[play] := 0;
   Move_Y[play] := 0;
   If Head_Y[Play]  = (Screen_Dim_Y - 1 )Then 
      Move_Y[play] := -1
   else
      If Head_Y[play] = 2 Then 
         Move_Y[play] := 1
      Else
         If Head_X[play] = 2 THen
            Move_X[PLay] := 1
         Else
            Move_X[Play] := -1;
   responce[play] := chr(1);
   end;

 begin
   Move_Count := Move_Count + 1; 
   remove_phaser; 
   For PLay := 1 to Max_Player_Number Do Begin
      Died_This_Round[Play] := False;
   end;
   If Players_reMoving = 1 Then Begin      { If 1 Then Loop Clockwise }
      For Play := 1 to Max_Player_number do 
         add_This_Players_head;
      PLayers_ReMoving := 2;                { Next Round Shall remove Even Ones }
      For Play := 1 to Max_Player_number do 
         Fire_This_Players_Phaser;
   end else 
      If Players_removing = 2 Then Begin
         For Play := Max_Player_Number downto 1 do 
            add_This_Players_head;               { Go Clockwise In Updating }
         PLayers_ReMoving := 1;
         For Play := Max_Player_Number downto 1 do 
            Fire_This_Players_Phaser;               
      end else Begin
        If Players_removing < 0 Then Begin
           Players_Removing := Players_removing + 1;
   	   For Num_Hazzards := 1 to Max_num_Hazzards  do Begin
               Repeat 
                  X := Gap_Around + trunc(Mth$Random(Seed)*(Screen_Dim_X-GaP_around*2)) + 1;
               until Not ( (  X = 2 ) or 
                           (  X =  (Screen_Dim_X - 1)) or
                           (  X = ( Screen_Dim_x div 2 + 1 ) ) );
               repeat
                  Y := Gap_Around + trunc(Mth$Random(seed)*(Screen_Dim_Y-Gap_Around*2)) + 1;
               Until Not ( ( Y = ( Screen_Dim_Y div 2 )) or 
                           ( Y = 2 ) or 
                           ( Y = Screen_Dim_Y - 1 ) ) ;
	       If Screen[X,y] = ' ' Then Begin
                  Screen[X,y] := 'X';
                  Buff_Pos_Char_1(X,y,'X');
               End;
            End;
            For PLay := 1 to Max_PLayer_Number do 
               If Not Quit[PLay] Then  Begin
                  Move_X[play] := 0;
                  Move_Y[PLay] := 0;
                  If ( Head_Y[PLay] > ( Screen_Dim_Y Div 2 ) ) Then 
                     Move_Y[Play] := -1
                  Else
                     If ( Head_Y[PLay] < ( Screen_Dim_Y Div 2 ) ) Then 
                        Move_Y[PLay] := 1
                     Else { = }
                        If ( Head_X[Play] > ( Screen_Dim_X Div 2 )) Then
                           Move_X[Play] := -1
                        else { < } 
                           Move_X[Play] := 1;
               end;
        End Else Begin
           Players_Removing := Players_removing + 1;
           Sleep(1);
        End;
      end;
      Num_Moved  := 0;
   For PLay := 1 to Max_Player_Number Do 
     If ( Not Died[play] ) and ( Not Quit[play] ) Then Begin
      Num_Moved :=  Num_Moved + 1;
      If Died_This_Round[PLay] Then Begin
         If Screen[Head_X[play],Head_Y[play]] = ' ' Then 
            Buff_Pos_Char_1(Head_X[play],Head_Y[Play],' ');
         If Shields[Play] Then Begin
            Shields[play] := False;
            Jump_Player(play);
         End Else Begin
            Num_Moved := Num_Moved + 1;
            Died[Play] := True;
         End;
      End;
     end;
   If Num_Moved < Num_Moved_Last_Round Then 
      Move_Count := 0;
   If ( Num_Moved * Moves_Per_Player < Move_Count ) Then Begin
      NUm_Moved := 0;
      Buff_Char_3(Chr(7),Chr(7),Chr(7));
      For play := 1 to Max_Num_Players do 
         If ( Not Quit[play] ) and 
            ( Not Died[play] ) and
            ( Not Died_This_Round[play] ) Then Begin
              Shields[play] := False;
              PLayer_Died(play,False);
         end;
   end;
   Num_Moved_Last_Round := Num_Moved;
   If Num_Moved_Last_Round  <= 1 Then Begin                  { Ie There IS Only 1 or 0 PLayers Left }
      For PLay := 1 to Max_player_Number do Begin
	If Not Quit[Play] Then Begin
            If ( Not Died[PLay] ) and ( Not Died_this_Round[play] ) Then Begin
               Score[PLay] := Score[Play] + 100;    { One Hundred If You Last Left }
               Games_Won[PLay] := Games_Won[PLay] + 1;
            end;
            Score_set(Play,Score[Play],Game[Play],Games_Won[PLay]);
         end;
       end;
      Add_head := 0;            { Return 0 To Stop The Game }
   end else 
      Add_Head := 1;            { 1 To Continue }
   Buff_Pos_char_1(23,40,chr(0));
   Break_Buff;    { does not write the buffer just says To 
                   Write this buffer to all the players when add_head exits }
end { add_Head};


Procedure Snake_PLay;extern;


Begin { Mainline }
   LineLimit(Output,MaxInt);
   Initalise_Mainline;
   While True Do Begin
      Initalise_Positions;      { initalises Pos Only relavent for master snake }
      Snake_Play;               { Calls Add_head with the Moves of the players  until add_head returns 1 ( end of game ) }
      Draw_Scores;
      Snake_Game_End;           { Syncs all players Together }
   end;
9999 : 
  Writeln(esc,'<', esc, '[62;1"p' );
end.
