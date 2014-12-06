
{$S-}
{$C+}
{

                 XXXXX    X     X   XXXXX   X    X  XXXXXX
                X     X   XX    X  X     X  X    X  X     
                X         X X   X  X     X  X   X   X     
                 XXXXX    X  X  X  XXXXXXX  XXXX    XXXXX 
                      X   X   X X  X     X  X  X    X     
                X     X   X    XX  X     X  X   X   X     
                 XXXXX    X     X  X     X  X    X  XXXXXX
                                                          

		Program	: Snake

		Authors	: Rex Croft       - Macro

                          Murray Speight - Pascal 

		Place	: University Of Waikato 

		Date 	: May 1982 

	Software Is Subject To Change Without Notification
        The Author And His Family assume No Rsponsability For
	Its Reliabliity Or Use. 

         }

Program Snake(Input,Output);

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
        Init_pos_Y      ,                       {  "" "" For Y Coord }
	Score		,                       { Score Of Each PLayer }
        Game		,                       { Num Games Each PLayer Played }
	Games_Won 	,                       { Games Won By Each PLayer }
	Move_X		,                       { What Dir Each Playe Is Moving X Coord }
	Move_Y		,                       { "" "" Y Coord }
	Head_X		,                       { Where The Head Is For Each Player X Coord }
	Head_Y	 	,                       { "" "" Y Coord }
	Tail_X		,                       { Where The Tail Is For Each Player X Coord }
	Tail_Y		: Positions;            { "" "" Y Cord }
	TT_Buff		: Buffer;               { Lenght Of Buffer To Hold Screen Output }
	TT_Len		,                       { String To Hold Screen Output }
        Who_Is_PLaying  ,                       { Word With Bits Set As To Who is Playing }
	You		,                       { Which Number You are } 
	Dummy 		,                       { Dummy argument }
	Num_players     ,                       { How Many people are Playing }
	Max_Player_Number ,                     { The Highest PLayers Number who is Playing }
        Num_Moved_Last_Round    ,               { Number of players who moved last Round ( Last Screen Update ) }
	Players_Removing	: Integer;      { Are We Removing Odd 1 or even 2 players Tails }
	Quit		,                       { Has The PLayer Quit (not playing ) or is He Playing }
	Died 		: Died_Type;            { Has The PLayer Died ( Died If He has Quit ) }
	Esc		: Char;                 { esc For escape sequences }
	Seed		: Real;                 { Seed for random number generaotor }


Procedure Break_Buff;

   Procedure Snake_Screen( Var Line : Buffer ; Var Lenght : Integer );extern; 

{ Only Call This Once From The Add_head Function 

   Does not write array to screen }

Begin
   Snake_Screen(TT_Buff,TT_Len); 
   TT_Len := 0;
end;


Procedure Help_Screen;extern;

Procedure Pos( X,Y : Integer ; Ch : Char );

{ Write Char at Pos X,Y in Buffer }

Begin
   TT_Buff[TT_Len+1] := Esc;
   TT_Buff[TT_Len+2] := 'Y';
   TT_Buff[TT_Len+3] := Chr(31+X);
   TT_Buff[TT_Len+4] := Chr(31+Y);
   TT_Buff[TT_Len+5] := Ch;
   TT_Len := TT_Len + 5;
end;

Function at(X,Y: Integer):Char;

{ Posotion Cursor at X , Y this Is For Use In Write Statments }

Begin
   Write(esc,'Y',chr(31+X),Chr(31+Y));
   at := Chr(0);
end;


Function Snake_Init(Var You :  INteger ; Var Game_going : Integer):Integer;extern;

Procedure Name_Set(Var Name : Name_Line );extern;

Procedure Name_Get( VAR Name : Name_Line ; Play : Integer );extern;

Procedure Score_Set( Player : INTEGER; VAR Score,Games_PLayed,wins : INteger);
							extern;
Procedure Score_Get( Player : INTEGER; VAR Score,Games_Played,wins : Integer );
							extern;
Procedure Snake_Start( Var Whos_PLaying : Integer ; var Rand : Positions );Extern;

Procedure Snake_Read(Var Directions : Player_Responce );Extern;

Procedure Snake_Game_End;extern;

Procedure Snake_Wait;Extern;

Procedure Snake_Game_count( Var Num : Integer);extern;

Procedure Snake_Dead(Var PLayer : Integer );extern;

Procedure Sleep( Num_Sec : Integer);extern;

Procedure Draw_Scores;

Var I,num_on_table,play,max_score,Top_play,Total_Num_Games,This_score: Integer;


Begin
   Num_on_Table := 0;
   Writeln(esc,'H',Esc,'J',Esc,'G',esc,'<');
   Writeln(' Player   User         Name               Score  Game  Won   Graph');
   writeln(' ------   ----         ----               -----  ----  ---   -----');
   writeln;
   Max_score := -99999;

   { Find The Top Player  goes By The his Score And Num Of Games Played }
   For PLay := 1 to Max_Num_PLayers do  begin
      Score_get(Play,Score[PLay],Game[PLay],Games_won[play]);
      If Game[Play] > 0 Then Begin
         This_score := Round(Score[play] / (Game[play])**(0.8));
         If This_score > Max_score Then Begin
            Top_Play := Play;
            Max_score := This_score + 1;
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
         Write(Games_won[play]:5);
         Write('   ',Esc,'[7m'); { Rev Video }
         If PLay = Top_PLay Then    
             Write(' *** Champ *** ')
      	 Else
            For I := 1 to Round(Score[play]*15 / ((Game[play])**(0.8)*max_score)) do 
               Write(' ');
         Writeln(esc,'[0m'); { Normal Video }
      end;
    End;
   writeln;

{ Print The Games You Have Played With The Totak Num of Games Played so Far }
   Snake_Game_Count( Total_Num_games );
   Writeln(' Game # ',Game[You]:1,'	Total # ',Total_Num_Games:1);
   writeln;
   writeln;
   If Num_on_Table <= 1 Then 
      Goto 9999;
   writeln(' Please Wait For Next Game ..... ');
   writeln(esc,'[?2l',esc,'F');
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
      For Y := 1 to (Screen_Dim_Y-1) do 
         Write('~');
      Writeln('x');
   end;
   write(esc,'#6m');
   For Y := 1 to (Screen_Dim_Y-1) Do 
      Write('q');
   Writeln('j');

{   Show Who You Are At Thje Bottom Of The Screen  }
   Writeln({Esc,'[24;1H',Esc,'#6',Esc,'(BYou # ',You:1,}
	      esc,'[?2l',esc,'F',at(1,1));   
end;

   
Procedure initalise_Positions;



Var Mult,Play,X,Y : Integer;

    Rand	  : Positions;

Begin

Players_Removing := -1;  { On First Few Moves Don't remove Tail }

Snake_Start(Who_Is_Playing,Rand);


{ Randomly Position The Starting Pos Of The PLayers }
For play := 1 to Max_num_players do  Begin
   Head_X[Play] := Init_Pos_X[Rand[Play]];
   Head_Y[play] := Init_Pos_Y[Rand[PLay]];
   Move_X[play] := 1;
   MOve_Y[Play] := 0;
end;
Tail_X := Head_X;
Tail_Y := Head_Y;

Mult := 2**7;  { 2 ** Number of PLayers - 1}
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
For PLay := 1 to Max_Num_PLayers do 
   Game[PLay] :=   Game[PLay] + 1;
For X := 1 To Screen_Dim_X do 
   For Y := 1 to Screen_Dim_Y do
      Screen[X,y] := '~';
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
   If Not Quit[play] Then 
      Screen[Head_X[Play],Head_Y[Play]] := 'O';
{ Note If This Procedure Is Only Called When You Are Master Snake 
  Draw Screen Should Be In The Mainlkine Before Init_pos
  And The Writing Of The PLayers Pos Should Be To The Buffer 
  And Then Written To All Who Are PLaying }

Draw_screen;   

{ Pos Inital Player Positions }
For Play := 1 to Max_Num_PLayers do  
   If ( Not Quit[Play]  ) Then  
      Writeln(at(Head_X[Play],Head_Y[Play]),Head_sym[Play]);
end;

Procedure Initalise_Mainline;

Var Zero,Init_Rep,PLay,Name_pos,Game_Going : Integer;

Procedure Verify_name(VAr Name : Name_Line );

Var I : INteger;


Begin
   For I := 1 to Max_Name_length do   { Remove All Invalid Chars From The Name}
      If ( Name[i] < ' ' ) or ( Name[i] > '~' ) Then Begin
            Write(chr(7));
            Name[i] := ' ';
      end;
end;


Begin
   Esc := Chr(27);
   Seed := Clock;
   TT_Len := 0;
   

   { set where Each Player Starts }

   Init_pos_X[1] := 2;
   Init_pos_Y[1] := 2;
   
   Init_pos_X[2] := Screen_dim_x - 1;
   Init_pos_Y[2] := Screen_dim_Y - 1;
   
   Init_pos_X[3] := 2;
   Init_pos_Y[3] := Screen_dim_y - 1;
   
   Init_pos_X[4] := Screen_dim_x - 1;
   Init_pos_Y[4] := 2;
   
   Init_pos_X[5] := 2;
   Init_pos_Y[5] := Screen_dim_Y div 2;
   
   Init_pos_X[6] := Screen_dim_x - 1 ;
   Init_pos_Y[6] := Screen_dim_Y div 2;
   
   Init_pos_X[7] := Screen_dim_x div 2;
   Init_pos_Y[7] := 2;
   
   Init_pos_X[8] := Screen_dim_x div 2;
   Init_pos_Y[8] := Screen_dim_Y - 1;

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
         Writeln(esc,'[1;18H',Esc,'#3SNAKE');
         Writeln(esc,'[2;18H',Esc,'#4SNAKE');
         Writeln(esc,'[4;8H' ,Esc,'#6Sorry No Snakes Available');
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

Function Correct_Sym(Last_Move_X,Last_Move_Y,Move_X,Move_Y:Integer):Char;

Begin  { Calculates The Correct symbol To Write Given The Dir You Were In }
    Case (Last_Move_X+1) + (Last_Move_Y+1)*4 Of 
      6 : { Down }
             Case (Move_X+1) + (Move_Y+1)*4 Of 
               6 : { Down }
                   Correct_Sym := 'x';
               9 : { Right }
                   Correct_Sym := 'm';
               1 : { Left }
                   Correct_Sym := 'j';
               4 : { Up Note : This Is Poss On First Move }
                   Correct_Sym := 'x';
               end { Case };
      4 : { Up }
             Case (Move_X+1) + (Move_Y+1)*4 Of 
               6 : { Down }
                   Correct_Sym := 'x';
               4 : { Up }
                   Correct_Sym := 'x';               
               9 : { Right }
                   Correct_Sym := 'l';
               1 : { Left }
                   Correct_Sym := 'k';   
               end { Case };
      
      9 : { Right }
             Case (Move_X+1) + (Move_Y+1)*4 Of 
               6 : { Down }
                   Correct_Sym := 'k';               
               4 : { Up }
                   Correct_Sym := 'j';               
               9 : { Right }
                   Correct_Sym := 'q';
               1 : { Left }
                   Correct_Sym := 'q';   
               end { Case };

      1 : { Left }
             Case (Move_X+1) + (Move_Y+1)*4 Of 
               9 : { Right }
                   Correct_Sym := 'q';
               6 : { Down }
                   Correct_Sym := 'l';               
               4 : { Up }
                   Correct_Sym := 'm';               
               1 : { Left }
                   Correct_Sym := 'q';   
               end { Case };

      end { Case };
end; { Correct Sym }

[GLOBAL] Function Add_head( Var Responce : Player_responce ):Integer;

Var Play, Num_Moved, Dir_X, Dir_Y, Pos_x, Pos_Y : Integer;



Procedure Remove_tail( Var STail_X , STail_Y : Integer );

Var Last_X,Last_Y : Integer;

Begin { removes the Tail of the snake whose tail is at StailX,Y }
{ The Character To Move is determined by the Char at the tail
  and if a character joins up to it }

      Last_X := STail_X;
      Last_Y := STail_Y;
      Pos(STail_X,STail_Y,'~');
      Case Screen[STail_X,STail_Y]  of 
         'l' : If Screen[Stail_X,STail_Y+1] In ['k','j','q'] Then 
                  STail_Y := STail_Y + 1
               Else
                  STail_X := STail_X + 1;
         'k' : If Screen [STail_X,STail_Y-1] In ['l','m','q'] Then 
                  STail_Y := STail_Y - 1
               Else
                  Stail_X := STail_X + 1 ;
         'm' : If Screen[STail_X,STail_Y+1] In ['k','j','q'] Then
                  Stail_Y := STail_Y + 1
               Else
                  Stail_X := Stail_X - 1 ;
         'j' : If Screen[STail_X,STail_Y-1] In ['m','l','q'] Then 
                  STail_Y := STail_Y - 1
               Else
                  STail_X := STail_X - 1;
         'x' : If Screen[STail_X-1,STail_Y] In ['l','k','x'] Then 
                  STail_X := STail_X - 1
               Else
                  STail_X := STail_X + 1;
         'q' : If Screen[STail_X,STail_Y - 1 ] In [ 'l','m','q'] Then 
                  STail_Y := STail_Y - 1
               Else
                  STail_Y := STail_Y + 1;
         end { CAse };
      Screen[Last_X,Last_Y] := '~';
end { remove_Tail};


Procedure Remove_Players_tail( play : Integer );

Var X,Y : Integer;

Begin   { Removed Odd Players Tails Of Play = 1 Even If 2 }
   While Play <= Max_PLayer_Number do Begin
      If Not Died[Play] Then  
         Remove_tail(Tail_X[PLay],Tail_Y[PLay]);
      Play := Play + 2;
   end;
end;


Procedure Add_This_Players_Head;

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
         Dir_X := Move_X[Play];
         Dir_Y := Move_Y[PLay];
	 Pos_X := Head_X[Play];
         Pos_Y := Head_Y[Play];
         { Change Direction Of The Position You Move To is Not A Wall ie = '.' }
         Case Ord(responce[Play]) Of 
            8 : If Screen[Pos_x-1,Pos_Y] = '~' Then  Begin
                     Dir_X := -1 ;
                     Dir_Y := 0 ;      { Moving Up }
                  end;
            2 : If Screen[Pos_X+1,Pos_Y] = '~' Then Begin
                     Dir_X := 1;
                     Dir_Y := 0;         { Moving Down }
                  end;
            4 : If Screen[Pos_X,Pos_Y-1] = '~' Then Begin
                     Dir_X := 0;          { Moving Left }
                     Dir_Y := -1;
                  end;
            6 : If Screen[Pos_X,Pos_Y+1] = '~' Then Begin
                     Dir_X := 0;            { Moving Right }
                     Dir_Y := 1;
                  end;
            otherwise { Do Nothing Same Dir As Before }
         end { Case };
         { Given LAst Direction Or New Direction }
         If Screen[Pos_X + Dir_X , Pos_Y + Dir_Y ] = '~' Then Begin  
	    { Going into a Blank square ok to move }
            Num_Moved := Num_Moved + 1;
            Screen[Pos_X ,Pos_Y ] := 
                  Correct_sym(Move_X[Play],Move_Y[PLay],Dir_X,Dir_Y);
            pos(Pos_X,Pos_Y,Screen[Pos_X,Pos_Y]);
            Pos_X := Pos_X + Dir_X;
            Pos_Y := Pos_Y + Dir_Y;
            Screen[Pos_X,Pos_Y] :=  'O';
            Pos(Pos_X,Pos_Y,Head_Sym[PLay]);
         end else begin { You HAve Died Hit Into A Non Blank Square }
            Died[Play] := True;
            If Num_PLayers <> Num_Moved_Last_Round Then  
               Score[Play] := Score[Play] + 
                     (( Num_PLayers - Num_Moved_Last_Round  + 1 )**2 * 100 ) 
                        div ( NUm_Players**2);
            pos(Pos_X,Pos_Y,Correct_sym(Move_X[Play],Move_Y[PLay],Dir_X,Dir_Y));
            Pos_X := Pos_X + Dir_X;
            Pos_Y := Pos_Y + Dir_Y;
	    Snake_Dead(play); 
         end;
         Move_X[Play] := Dir_X;
         Move_Y[PLay] := Dir_Y;
	 Head_X[Play] := pos_X;
         Head_Y[Play] := Pos_Y;
      end;
end;

begin
   Num_Moved := 0;            { Iniotalise Counter For The Number Who Moved }
   If Players_reMoving = 1 Then Begin      { If 1 Then Loop Clockwise }
      For Play := 1 to Max_Player_number do 
         add_This_Players_head;
      Remove_players_tail(1);               { Remove Odd Players Tail }
      PLayers_ReMoving := 2;                { Next Round Shall remove Even Ones }
   end else 
      If Players_removing = 2 Then Begin
         For Play := Max_Player_Number downto 1 do 
            add_This_Players_head;               { Go Clockwise In Updating }
         Remove_Players_tail(2);
         PLayers_ReMoving := 1;
      end else begin
         For Play := Max_Player_Number downto 1 do { First Few Moves Don't remove Tail }
            add_This_Players_head;               { Go Clockwise In Updating }
         Players_removing := Players_removing + 1;
      end;
   If Num_Moved <= 1 Then Begin                  { Ie There IS Only 1 or 0 PLayers Left }
      For PLay := 1 to Max_player_Number do Begin
	If Not Quit[Play] Then Begin
            If Not Died[PLay] Then Begin
               Score[PLay] := Score[Play] + 100;    { One Hundred If You Last Left }
               Games_Won[PLay] := Games_Won[PLay] + 1;
            end;
            Score_set(Play,Score[Play],Game[Play],Games_Won[PLay]);
         end;
       end;
      Add_head := 0;            { Return 0 To Stop The Game }
   end else 
      Add_Head := 1;            { 1 To Comtinue }
   Num_Moved_Last_Round := Num_Moved;
   Break_Buff;    { does not write the buffer just says To 
                   Write this buffer to all the players when add_head exits }
end { add_Head};


Procedure Snake_PLay;extern;


Begin { Mainline }
   LineLimit(Output,MaxInt);
   Initalise_Mainline;
   While True Do Begin
      Initalise_Positions;      { initalises pos Only relavent for master snake }
      Snake_Play;               { Calls Add_head with the Moves of the players  until add_head returns 1 ( end of game ) }
      Draw_Scores;
      Snake_Game_End;           { Syncs all players Together }
   end;
9999 : 
  Writeln(esc,'<');
end.
