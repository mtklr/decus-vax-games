{$S-}
{

		Program	: Multi USer Qix 

		Authors	: Rex Croft       - Macro

                          Murray Speight - Pascal 

		Place	: University Of Waikato 

		Date 	: Jan 1983

	Software Is Subject To Change Without Notification
        The Author And His Family assume No Rsponsability For
	Its Reliabliity Or Use. 

         }

Program MQix(Input,Output);

Label	9999;  { For Abortive exit Of Pgm }


Const 	Max_Num_Players	= 8;             { Up To 8 Players }
	Screen_Dim_R 	= 24;            { PLaying Board 40 * 23 }
	Screen_Dim_C	= 40;
	Len_Of_Buff	= 1920;          { Buffer to Write Chars }
        Max_Name_Length = 32;            { Lenngth of a players name }

Type 	Player_Responce = Packed Array [1..Max_Num_Players] Of Char;
	Buffer		= Packed Array [1..Len_Of_Buff] Of Char;	
	Positions	= Array [1..Max_Num_Players] Of INteger;
	Players_Screen	= Array [1..Screen_Dim_R,1..Screen_Dim_C] Of Char;
	Died_Type	= Array [1..Max_NUm_Players] Of Boolean;
	Name_Line	= Packed array [1..max_Name_Length] of Char;
        Name_Table	= Array [1..Max_Num_Players] of name_LIne;

Var 	Responce 	,			{ What Players Have Typed }
   	Ch_on		,
	Head_Sym	: Player_Responce;      { What Symbol is THe Head }
   	Cal		,
	Screen		: Players_Screen;       { 23 * 40 Array For Screen}
	Name		: Name_Table;           { Names Of Each Player }
        Init_pos_R	,                       { Where initaially Players Start }
        Init_pos_C      ,                       {  "" "" For Y Coord }
	Score		,                       { Score Of Each PLayer }
        Game		,                       { Num Games Each PLayer Played }
	Games_Won 	,                       { Games Won By Each PLayer }
	Move_R		,                       { What Dir Each Playe Is Moving X Coord }
	Move_C		,                       { "" "" Y Coord }
	Head_R		,                       { Where The Head Is For Each Player X Coord }
	Head_C	 	,                       { "" "" Y Coord }
        Rand		: Positions;
	TT_Buff		: Buffer;               { Lenght Of Buffer To Hold Screen Output }
	TT_Len		,                       { String To Hold Screen Output }
        Cursor_R	,
        Cursor_C	,
        Who_Is_PLaying  ,                       { Word With Bits Set As To Who is Playing }
	You		,                       { Which Number You are } 
	Dummy 		,                       { Dummy argument }
        Area_75_Per	,
   	Area_Filled	,
	Num_players     ,                       { How Many people are Playing }
	Max_Player_Number : integer;                     { The Highest PLayers Number who is Playing }
	Quit		,                       { Has The PLayer Quit (not playing ) or is He Playing }
   	Can_Create	,
	Creating	: Died_Type;            { Has The PLayer Died ( Died If He has Quit ) }
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


   procedure Write_5( ch1,ch2,ch3,ch4,ch5 : CHar);
   
   Begin
    TT_len := TT_len + 1;
    TT_Buff[TT_len] := Ch1;
    TT_len := TT_len + 1;
    TT_Buff[TT_len] := Ch2;
    TT_len := TT_len + 1;
    TT_Buff[TT_len] := Ch3;
    TT_len := TT_len + 1;
    TT_Buff[TT_len] := Ch4;
    TT_len := TT_len + 1;
    TT_Buff[TT_len] := Ch5;
   end;
   


   procedure Write_4( ch1,ch2,ch3,ch4 : CHar);
   
   Begin
    TT_len := TT_len + 1;
    TT_Buff[TT_len] := Ch1;
    TT_len := TT_len + 1;
    TT_Buff[TT_len] := Ch2;
    TT_len := TT_len + 1;
    TT_Buff[TT_len] := Ch3;
    TT_len := TT_len + 1;
    TT_Buff[TT_len] := Ch4;
   end;
   


   procedure Write_3( ch1,ch2,ch3 : CHar);
   
   Begin
    TT_len := TT_len + 1;
    TT_Buff[TT_len] := Ch1;
    TT_len := TT_len + 1;
    TT_Buff[TT_len] := Ch2;
    TT_len := TT_len + 1;
    TT_Buff[TT_len] := Ch3;
   end;
   


   procedure Write_2( ch1,ch2 : CHar);
   
   Begin
    TT_len := TT_len + 1;
    TT_Buff[TT_len] := Ch1;
    TT_len := TT_len + 1;
    TT_Buff[TT_len] := Ch2;
   end;
   


   procedure Write_1( ch1 : CHar);
   
   Begin
    TT_len := TT_len + 1;
    TT_Buff[TT_len] := Ch1;
   end;
   


   procedure at(R,C:Integer;ch : char );
   
   Begin 
      If ( Abs(R-Cursor_R) <= 2 ) and ( Abs(C-Cursor_C) <= 2 ) Then Begin 
	 Case ( R - Cursor_R  )*5 + ( C - Cursor_C )  of 
	  { Up  ,       -2, 0  } -10 : Write_5(Esc,'Y',Chr(31+R),Chr(31+C),ch);
	  { Up  ,LEft   -2,-1  } -11 : Write_5(Esc,'Y',Chr(31+R),Chr(31+C),ch);
	  { Up  ,LEft   -2,-2  } -12 : Write_5(Esc,'Y',Chr(31+R),Chr(31+C),ch);
	  { Up  ,Right  -2, 1  }  -9 : Write_5(Esc,'Y',Chr(31+R),Chr(31+C),ch);
	  { Up  ,Right  -2, 2  }  -8 : Write_5(Esc,'Y',Chr(31+R),Chr(31+C),ch);
	  { Up  ,LEft   -1,-2  }  -7 : Write_5(Esc,'Y',Chr(31+R),Chr(31+C),ch);
	  { Up  ,LEft   -1,-1  }  -6 : write_4(Esc,'A',chr(8),Ch);
	  { Up  ,       -1, 0  }  -5 : write_3(Esc,'A',ch);
	  { Up  ,Right  -1, 1  }  -4 : Write_5(Esc,'Y',Chr(31+R),Chr(31+C),ch);
	  { Up  ,Right  -1, 2  }  -3 : Write_5(Esc,'Y',Chr(31+R),Chr(31+C),ch);
	  {     ,Left    0,-2  }  -2 : write_3(chr(8),chr(8),ch);
	  {     ,Left    0,-1  }  -1 : write_2(chr(8),ch);
	  {     ,        0, 0  }   0 : write_1(ch); 
	  {     ,Right   0, 1  }   1 : write_3(Esc,'C',ch);
	  {     ,Right   0, 2  }   2 : Write_5(Esc,'Y',Chr(31+R),Chr(31+C),ch);
	  { Down,Left    1,-2  }   3 : write_4(Chr(10),Chr(8),chr(8),ch);
	  { Down,Left    1,-1  }   4 : write_3(Chr(10),Chr(8),ch);
	  { Down         1, 0  }   5 : Write_2(Chr(10),ch);
	  { Down,Right   1, 1  }   6 : Write_4(Chr(10),Esc,'C',ch);
	  { Down,Right   1, 2  }   7 : Write_5(Esc,'Y',Chr(31+R),Chr(31+C),ch);
	  { Down,Left    2,-2  }   8 : Write_5(Esc,'Y',Chr(31+R),Chr(31+C),ch);
	  { Down,Left    2,-1  }   9 : write_4(Chr(10),chr(10),Chr(8),ch);
	  { Down         2, 0  }  10 : Write_3(Chr(10),chr(10),ch);
	  { Down,Right   2, 1  }  11 : Write_5(Esc,'Y',Chr(31+R),Chr(31+C),ch);
	  { Down,Right   2, 2  }  12 : Write_5(Esc,'Y',Chr(31+R),Chr(31+C),ch);
	 end;
      end else  Begin
	 Write_5(Esc,'Y',Chr(31+R),Chr(31+C),ch);
      end;
      Cursor_R := R;
      Cursor_C := C + 1;
      If C >= 40 Then 
	 Cursor_C := 999;
   end;


   Procedure new_Screen_Char( R,C : Integer );   

   var Count : Integer;

   Begin
	 Count := 0;   
	 If r-1 > 0 then 
	    If Screen[r-1,c] in ['$','l','w','k','t','n','u','x'] Then 
	       Count := Count + 1;
	 If c - 1 > 0 then 
	    If screen[r,c-1] in ['$','l','w','t','n','m','v','q']  Then
	       Count := Count + 2;
	 If c + 1 <= screen_Dim_C  then 
	    If Screen[r,c+1] in ['$','w','k','n','u','v','j','q']  Then 
	       Count := Count + 4;
	 If r +1 <= Screen_Dim_R then 
	    If Screen[r+1,c] in ['$','t','n','u','m','v','j','x'] Then 
	       Count := Count + 8;
	 Case Count Of 
	    0	: Screen[R,C] := ' '; 
	    1,8,9 : Screen[R,C] := 'x';
	    2,4,6 : Screen[R,C] := 'q';
	    3	: Screen[R,C] := 'j';
	    5	: Screen[R,C] := 'm';
	    7	: Screen[R,C] := 'v';
	    10	: Screen[R,C] := 'k';
	    11	: Screen[R,C] := 'u';
	    12	: Screen[R,C] := 'l';
	    13	: Screen[R,C] := 't';
	    14	: Screen[R,C] := 'w';
	    15	: Screen[R,C] := 'n'
	 end { case };
   end;



Procedure Help_Screen;extern;

Function pos( R,C : Integer ): CHar;

{ Write Char at Pos X,Y in Buffer }

Begin
   Write(Esc,'Y',Chr(31+R),Chr(31+C));
   pos := Chr(0);
end;

Function Snake_Init(Var You :  INteger ; Var Game_going : Integer):Integer;extern;

Procedure Name_Set(Var Name : Name_Line );extern;

Procedure Name_Get(Var Name : Name_Line ; var Play : [READONLY] Integer );
									extern;
Procedure Score_Set( VAR Player: [READONLY] INTEGER;
				VAR Score,Games_PLayed,wins : INTEGER); extern;
Procedure Score_Get( Var Player : [READONLY] INTEGER;
				VAR Score,Games_Played,wins : Integer );extern;

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
   Writeln(Esc,'<',Esc,'[0m',Esc,'[?2l');
   Write(esc,'H',Esc,'J',Esc,'G');
   Write(' Player   User         Name               Score  Game    ');
   If ( Time_Now[1] = '2' ) Then Begin
      If ( Time_Now[2] >= '2' ) Then Begin
         Time_Now[1] := '1';
         Time_Now[2] := chr( Ord(Time_Now[2]) - 2);
      end Else begin
         Time_Now[1] := ' ';
         Time_Now[2] := chr( Ord(Time_Now[2]) + 8);
      end;
      Write(Time_Now:5);
      Writeln(' pm');
   End Else Begin
      If (( Time_Now[1] = '1' ) and ( Time_Now[2] > '2' )) THen Begin
         Time_Now[1] := ' ';
         Time_Now[2] := chr( Ord(Time_Now[2]) - 2);
         Write(Time_Now:5);
         Writeln(' pm');
      end Else Begin
         If Time_Now[1] = '0' Then 
            Time_Now[1] := ' ';
         Write(Time_Now:5);
         If Time_Now[2] = '2' Then 
            Writeln(' pm')
         else
            Writeln(' am');
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
         Name_Get(Name[Play],Play);
         Write(Play:4);
         Write('    ',Name[Play]:32);
         write(Score[PLay]:7);         { Print Info }
         Writeln(Game[Play]:6);
      End;
   End;
   writeln; 
   Writeln(' Player  Score Indicator ');
   Writeln;
   For Play := 1 to Max_Num_PLayers do Begin
      If Game[PLay] > 0  Then Begin   { IF Games PLayed > 0 Then You Are PLaying  }
         Write(Play:4);
         Write('     ',Esc,'F'); { Graphics }
         Score_Ratio := (Score[play]+Games_won[PLay]*10)*Len_Scale
                            / ((Game[play])**(0.9)*Round(max_score));
         For I := 1 to Round(Score_Ratio) do 
            Write('a');
         If PLay = Top_PLay Then 
             Write(Esc,'G  ** Champ ** ');
         Writeln; { Normal Video }
      end;
    End;

{ Print The Games You Have Played With The Totak Num of Games Played so Far }
   Snake_Game_Count( Total_Num_games );
   writeln(Esc,'G');
   Writeln(' Game # ',Game[You]:1,'    Total # ',Total_Num_Games:1,
           '		Please Wait For Next Game ... ',Esc,'F');
{   If Num_on_Table <= 1 Then 
      Goto 9999;  }
end;

Procedure Draw_screen;

Var play,I,R,C,Line_at : Integer;

   Function Min(A,B:Integer):Integer;

   Begin
      If A < B Then 
         Min := A 
      Else
         Min := B
   end;

Begin { Draw Screen }
   Write(esc,'H',esc,'J',Esc,'F'); { Clear Home }
   Write('l',Esc,'<',Esc,'#6',Esc,'[?2l',Esc,'F');
   For C := 1 To (Screen_Dim_C-2) Do 
      Write('q');
   Writeln('k');
   For R := 2 To ( Screen_dim_R - 1 )  Do begin
      Write('x',Esc,'<',Esc,'#6',Esc,'[?2l',Esc,'F');
      Writeln(Pos(R,Screen_dim_C),'x');
   end;
   Write('m',Esc,'<',Esc,'#6',Esc,'[?2l',Esc,'F');
   For C := 2 to (Screen_Dim_C-1) Do 
      Write('q');
   Writeln('j',Esc,'H');
end;

   
Procedure initalise_Positions;



Var Mult,Play,R,C : Integer;


Begin

Area_Filled := Screen_Dim_R*2 + Screen_Dim_C*2 - 4;

Cursor_C := 9999;

Snake_Start(Who_Is_Playing,Rand);

{ Randomly Position The Starting Pos Of The PLayers }
For play := 1 to Max_num_players do  Begin
   Head_R[Play] := Init_pos_R[Rand[Play]];
   Head_C[play] := Init_pos_C[Rand[PLay]];
   Can_Create[play] := False;
   Creating[play] := False;
   Move_R[Play] := 1;
   Move_C[PLay] := 0;
end;

Mult := 2**(Max_num_Players - 1 );  { 2 ** Number of PLayers - 1}
Num_Players := 0;

{ Examine Each Bit In Mult To See If You Are Playing }
Max_player_number := 0;
For Play := Max_Num_PLayers downto 1 do begin
   If ( Who_Is_PLaying div Mult ) = 1 Then begin
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

{ If You are PLaying Then You Havnt Died }
For R := 1 To Screen_Dim_R do 
   For C := 1 to Screen_Dim_C do
      Screen[R,C] := ' ';
For C := 1 To Screen_Dim_C do Begin
   Screen[1,C] := 'q';
   Screen[Screen_Dim_R,C] := 'q';
end;
For R := 1 To Screen_Dim_R Do Begin
   Screen[R,1] := 'x';
   Screen[R,Screen_Dim_C] := 'x'; 
end;
Screen[1,1] := 'l';
Screen[1,Screen_Dim_C] := 'k';
Screen[Screen_Dim_R,1] := 'm';
Screen[Screen_Dim_R,Screen_Dim_C] := 'j';
Head_Sym[1] := chr(128+ord('1'));  { Set The Bits In The Chars }
Head_Sym[2] := chr(128+ord('2'));
Head_Sym[3] := chr(128+ord('3'));
Head_Sym[4] := chr(128+ord('4'));
Head_Sym[5] := chr(128+ord('5'));
Head_Sym[6] := chr(128+ord('6'));
Head_Sym[7] := chr(128+ord('7'));
Head_Sym[8] := chr(128+ord('8'));

{ Note If This Procedure Is Only Called When You Are Master Snake 
  Draw Screen Should Be In The Mainlkine Before Init_Pos
  And The Writing Of The PLayers Pos Should Be To The Buffer 
  And Then Written To All Who Are PLaying }

Draw_screen;   

{ Pos Inital Player Positions }
For Play := 1 to Max_Num_Players Do  Begin
   responce[Play] := ' ';   { Initalise First Responce Should Not BE Needed }
   Game[PLay] := Game[PLay];
end;
For Play := 1 to Max_Num_PLayers do  
   If Not Quit[Play]  Then  begin
     Ch_On[play] := Screen[Head_R[Play],Head_C[Play]];
     Screen[Head_R[Play],Head_C[Play]] := '*';
     If ( Play <> You ) Then  
      Writeln(pos(Head_R[Play],Head_C[Play]),Head_sym[Play],Esc,'H')
     Else  Begin 
      Writeln(pos(Head_R[You],Head_C[You]),'`',Esc,'H');
     end;
   end;
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
   Area_75_Per := Trunc ( Screen_Dim_R * Screen_Dim_C * (0.90 ));
   Seed := Clock;
   TT_Len := 0;
   

   { set where Each Player Starts }

   Init_pos_R[1] := 1;
   Init_pos_C[1] := 1;
   
   Init_pos_R[2] := Screen_dim_R ;
   Init_pos_C[2] := Screen_dim_C ;
   
   Init_pos_R[3] := 1;
   Init_pos_C[3] := Screen_dim_C;
   
   Init_pos_R[4] := Screen_dim_R;
   Init_pos_C[4] := 1;
   
   Init_pos_R[5] := 1;
   Init_pos_C[5] := Screen_dim_C div 2;
   
   Init_pos_R[6] := Screen_dim_R;
   Init_pos_C[6] := Screen_dim_C div 2;
   
   Init_pos_R[7] := Screen_dim_R div 2;
   Init_pos_C[7] := 1;
   
   Init_pos_R[8] := Screen_dim_R div 2;
   Init_pos_C[8] := Screen_dim_C;

   Writeln(Esc,'<',Esc,'[?2l'); { Vt52 Mode }
   Writeln(Esc,'H',Esc,'J');    { Clear Screen }
   Init_rep := Snake_Init(You,Game_going);
   You := You + 1;   
   If Init_rep = 1 Then Begin
      { you are the First Person to play zero all the scores }
      For Play := 1 to Max_Num_PLayers do begin
         Zero := 0;
         Score_Set(Play,Zero,zero,zero);
      end;
      Help_Screen;
      Writeln(Esc,'[?2l',Esc,'H');
      Writeln(pos(22,3),' Please Enter Your Name Player #',You:1);
      Write(pos(22,51));
      Readln(Name[You]);
      Verify_Name(Name[You]);
      Name_set(Name[You]);
      Write(pos(22,3), ' Hit < Return > When Others Ready   ');
      Readln;
      Writeln;
      Write(pos(22,3), ' Please Wait For Game To Start      ');
      Writeln;
   end Else Begin
      If You = 0 Then Begin
         Writeln(pos(1,33),'Multi User Qix');
         Writeln;
         Writeln(pos(4,10),' Sorry No Qix''s Available');
	 Sleep(3);
         goto 9999;
      end else begin { Init_rep = 0 } 
         Help_Screen;
         Writeln(Esc,'[?2l',esc,'H');
         Writeln(pos(22,3),' Please Enter Your Name Player # ',You:1);
         Write(pos(22,51));
         Readln(Name[You]);
         Verify_name(Name[You]);
         Name_set(Name[You]);
         Writeln;
         Write(pos(22,3), ' Please Wait For Game To Start     ');
         Writeln;
         If Game_Going = 1 Then 
            Snake_Game_End;
      end;
   end;
   Game[You] := 0;
end { Initalise Mainline };

[GLOBAL] Function Add_head( Var Responce : Player_responce ):Integer;

Var Play : Integer;

Procedure Add_this_players_Head;

var P,pos_R,Pos_c,dir_R,dir_C : Integer;

   Procedure New_join_Char( Into_wall : Boolean) ;

   var count : Integer;

   Begin
         Case Screen[pos_r,pos_C] of 
	    'k' : Count := 10;
	    'u' : Count := 11;
	    'l' : Count := 12;
	    't' : Count := 13;
	    'w' : Count := 14;
	    'n' : Count := 15;
	    'j' : Count := 3;
	    'm' : Count := 5;
	    'q' : Count := 6;
	    'v' : Count := 7;
	    'x' : Count := 9;
	 end;	       	
         If into_Wall Then 
	    Case ( Dir_R + 1 ) + ( Dir_C + 1 ) * 2 of 
	       2 : Count := Count + 8;
	       4 : Count := Count + 1;
	       1 : Count := Count + 4;
	       5 : Count := Count + 2;
	    end
   	 else
	    Case ( Dir_R + 1 ) + ( Dir_C + 1 ) * 2 of 
	       2 : Count := Count + 1;
	       4 : Count := Count + 8;
	       1 : Count := Count + 2;
	       5 : Count := Count + 4;
	    end;
	 Case Count Of 
	    0	: Screen[pos_r,Pos_C] := ' '; 
	    1,8,9 : Screen[pos_r,Pos_C] := 'x';
	    2,4,6 : Screen[pos_r,Pos_C] := 'q';
	    3	: Screen[pos_r,Pos_C] := 'j';
	    5	: Screen[pos_r,Pos_C] := 'm';
	    7	: Screen[pos_r,Pos_C] := 'v';
	    10	: Screen[pos_r,Pos_C] := 'k';
	    11	: Screen[pos_r,Pos_C] := 'u';
	    12	: Screen[pos_r,Pos_C] := 'l';
	    13	: Screen[pos_r,Pos_C] := 't';
	    14	: Screen[pos_r,Pos_C] := 'w';
	    15	: Screen[pos_r,Pos_C] := 'n'
	 end { case };
   end;


   procedure new_tail_CHar;

   begin
    Case (move_R[play]+1) + (Move_C[play]+1)*4 of 
      6 : { Down }
             Case (Dir_R+1) + (Dir_C+1)*4 Of 
               6 : { Down }
                   Screen[Pos_R,Pos_C]  := 'x';
               9 : { Right }
                   Screen[Pos_R,Pos_C]  := 'm';
               1 : { Left }
                   Screen[Pos_R,Pos_C]  := 'j';
               4 : { Up Note : This Is Poss On First Move }
                   Screen[Pos_R,Pos_C]  := 'x';
               end { Case };
      4 : { Up }
             Case (Dir_R+1) + (Dir_C+1)*4 Of 
               6 : { Down }
                   Screen[Pos_R,Pos_C]  := 'x';
               4 : { Up }
                   Screen[Pos_R,Pos_C]  := 'x';               
               9 : { Right }
                   Screen[Pos_R,Pos_C]  := 'l';
               1 : { Left }
                   Screen[Pos_R,Pos_C]  := 'k';   
               end { Case };
      
      9 : { Right }
             Case (Dir_R+1) + (Dir_C+1)*4 Of 
               6 : { Down }
                   Screen[Pos_R,Pos_C]  := 'k';               
               4 : { Up }
                   Screen[Pos_R,Pos_C]  := 'j';               
               9 : { Right }
                   Screen[Pos_R,Pos_C]  := 'q';
               1 : { Left }
                   Screen[Pos_R,Pos_C]  := 'q';   
               end { Case };

      1 : { Left }
             Case (Dir_R+1) + (Dir_C+1)*4 Of 
               9 : { Right }
                   Screen[Pos_R,Pos_C]  := 'q';
               6 : { Down }
                   Screen[Pos_R,Pos_C]  := 'l';               
               4 : { Up }
                   Screen[Pos_R,Pos_C]  := 'm';               
               1 : { Left }
                   Screen[Pos_R,Pos_C]  := 'q';   
               end { Case };

      end { Case };
   end;	 

   Function move_Anti_Clock( var R,C,Prev_R,Prev_C : integer):Boolean;

   var 
     Save_R,Save_C : Integer;

   Begin
     Save_R := R;
     Save_C := C;
     Case ( Prev_C - C ) of 
      1 : 
	 Case Screen[R,C] of 
	    'l' : R := R + 1;
      	    'w' : R := R + 1;
      	    't' : R := R + 1;
      	    'n' : R := R + 1;
	    'm' : R := R - 1;
	    'v' : C := C - 1;
	    'q' : C := C - 1;
	 end;
      0 :
	 Case ( prev_R - R ) Of 
	    1 :
	       Case Screen[R,c] of
		  'l' : C := C + 1;
		  'w' : C := C - 1;
		  'k' : C := C - 1;
		  't' : R := R - 1;
		  'n' : C := C - 1;
		  'u' : C := C - 1;
		  'x' : R := R - 1;
	       end;
	    0 : ;
	    -1:
	       Case Screen[R,c] of 
		  't' : C := C + 1;
		  'n' : C := C + 1; 
		  'u' : R := R + 1;
		  'm' : C := C + 1;
		  'v' : C := C + 1;
		  'j' : C := C - 1;
		  'x' : R := R + 1;
	       end;
	 end;
      -1:
	 Case Screen[R,c] of 
	    'w' : C := C + 1;
	    'k' : R := R + 1;
	    'n' : R := R - 1;
	    'u' : R := R - 1;
	    'v' : R := R - 1;
	    'j' : R := R - 1;
	    'q' : C := C + 1;
	 end;
   end;
   move_Anti_Clock := true;
   Prev_R := Save_R;
   Prev_C := Save_C;
   If Screen[R,C] = 'a' Then begin { reverse }
     prev_R := R;
     prev_C := C;
     R := Save_R;
     C := Save_C;
   end else     
    If Screen[R,c] = '*' Then 
   	move_Anti_Clock := False
    Else
      IF Screen[R,C] = ' ' Then 
   	 Writeln(' **** INTERNAL ERROR **** MOVE_ANTI_CLOCK ');
end;   	    


   Function Move_Clock( var R,C,Prev_R,Prev_C : Integer):Boolean;

   var 
     Save_R,Save_C : Integer;

   Begin
     Save_R := R;
     Save_C := C;
     Case ( Prev_C - C ) of 
      1 : 
	 Case Screen[R,C] of 
	    'l' : R := R + 1;
      	    'w' : C := C - 1;
      	    't' : R := R - 1;
      	    'n' : R := R - 1;
	    'm' : R := R - 1;
	    'v' : R := R - 1;
	    'q' : C := C - 1;
	 end;
      0 :
	 Case ( prev_R - R ) Of 
	    1 :
	       Case Screen[R,c] of
		  'l' : C := C + 1;
		  'w' : C := C + 1;
		  'k' : C := C - 1;
		  't' : C := C + 1;
		  'n' : C := C + 1;
		  'u' : R := R - 1;
		  'x' : R := R - 1;
	       end;
	    0 : ;
	    -1:
	       Case Screen[R,c] of 
		  't' : R := R + 1;
		  'n' : C := C - 1; 
		  'u' : C := C - 1;
		  'm' : C := C + 1;
		  'v' : C := C - 1;
		  'j' : C := C - 1;
		  'x' : R := R + 1;
	       end;
	 end;
      -1:
	 Case Screen[R,c] of 
	    'w' : R := R + 1;
	    'k' : R := R + 1;
	    'n' : R := R + 1;
	    'u' : R := R + 1;
	    'v' : C := C + 1;
	    'j' : R := R - 1;
	    'q' : C := C + 1;
	 end;
   end;
   move_Clock := true;
   Prev_R := Save_R;
   Prev_C := Save_C;
   If Screen[R,C] = 'a' Then begin { reverse }
     prev_R := R;
     prev_C := C;
     R := Save_R;
     C := Save_C;
   end else     
    If Screen[R,c] = '*' Then 
   	move_Clock := False
    Else
      IF Screen[R,C] = ' ' Then 
   	 Writeln(' **** INTERNAL ERROR **** MOVE_CLOCK ');
end;   	    


Procedure fill_area;

var Sr,Sc,R,C,Prev_R,Prev_C,area_C,Area_A: Integer;
    some_one_there : Boolean;

   procedure Bfill_C(Fr,Fc: Integer);

   Begin
     If Cal[Fr,Fc] = ' ' Then Begin
   	Cal[FR,FC] := 'C';
        BFill_C(FR-1,FC);
   	BFill_C(FR,FC+1);
        BFill_C(FR+1,FC);
        BFill_C(FR,FC-1);
   	Bfill_C(FR+1,Fc+1);
   	Bfill_C(FR+1,Fc-1);
   	Bfill_C(FR-1,Fc+1);
   	Bfill_C(FR-1,Fc-1);
     end else 
      If Cal[FR,FC] in ['A','*'] Then 
   	Some_one_there := true;
   end;

   procedure Bfill_A(FR,FC: Integer);

   Begin
     If Cal[FR,FC] = ' ' Then Begin
   	Cal[FR,FC] := 'A';
        BFill_A(FR-1,FC);
   	BFill_A(FR,FC+1);
        BFill_A(FR+1,FC);
        BFill_A(FR,FC-1);

        BFill_A(FR+1,FC+1);
   	BFill_A(FR+1,FC-1);
        BFill_A(FR-1,FC+1);
        BFill_A(FR-1,FC-1);
     end else 
      If Cal[FR,FC] in ['C','*'] Then 
   	Some_one_there := true;
   end;

   Procedure Display_Fill( Ch : Char );

   var S,R,C : Integer;
       H   : Char;

   begin
     H := Chr( Ord('a') + Ord(Head_sym[play]) - Ord('1') );
     R := 1 ;
     S := 0 ; 
     Write_5(Esc,'<',Esc,'[','7');
     write_5('m',Esc,'[','?','2');
     Write_3('l',Esc,'F');
     While R <= Screen_Dim_R do begin
   	C := 1;
   	While ( C < Screen_Dim_C ) do  begin
   	  While ( C < screen_Dim_C ) and ( Cal[R,C]<>ch ) do 
   	   C := C + 1;
   	  If Cal[R,C] = Ch then  
	    Write_4(Esc,'Y',Chr(31+R),Chr(31+C));
   	  While ( C < screen_Dim_C) and ( Cal[R,C] = ch ) do  begin
   	   write_1(H);
   	   Screen[R,C] := '*';
   	   S := S + 1;
   	   C := C + 1;
   	  end;
        end;
   	r := R + 1;
     end;   	  
     Score[play] := S + Score[play];
     Area_Filled := Area_Filled + S;
     Write_5(Esc,'<',Esc,'[','0');
     write_5('m',Esc,'[','?','2');
     Write_3('l',Esc,'F');
     Cursor_R := 9999;
   end;

      
Begin
  { First Move Around Clock, to check no one on walls for building from walls}
  Cal := Screen; { Uses A Lot Of Processing }
  R := Pos_R;
  C := Pos_C;
  Prev_R := pos_R - Dir_R;
  prev_C := Pos_C - Dir_C;
  Area_C := 0;
  Some_one_there := False;
  repeat 
    Some_one_there := Not move_Clock(R,C,Prev_r,Prev_C);
  Until (Some_one_There or (( R = Pos_R ) and ( C = pos_C ))) ;
  If not Some_one_there Then Begin
    R := Pos_R;
    C := Pos_C;
    Prev_R := pos_R - Dir_R;
    prev_C := Pos_C - Dir_C;
    repeat
      If move_Clock(R,C,Prev_r,Prev_C) Then  begin
        If Screen[R,C] In ['q','x'] Then  begin
          Sr := R + ( C - Prev_C );
          Sc := C - ( R - Prev_R );
          Bfill_C(Sr,Sc)
        end;
       end Else
         Some_one_there := true;
     Until (Some_one_There or (( R = Pos_R ) and ( C = pos_C ))) ;
  end;
  If Not Some_one_There Then 
    Display_Fill('C');
  R := Pos_R;
  C := Pos_C;
  Prev_R := pos_R - Dir_R;
  Prev_C := Pos_C - Dir_C;
  repeat 
     Some_one_there := Not move_Anti_Clock(R,C,Prev_r,Prev_C) 
  until ( Some_one_There or (( R = Pos_R ) and ( C = pos_C ))) ;
  If not some_one_there  Then begin
     R := Pos_R;
     C := Pos_C;
     Prev_R := pos_R - Dir_R;
     prev_C := Pos_C - Dir_C;
     Some_one_there := False;
     repeat
       If move_Anti_Clock(R,C,Prev_r,Prev_C) Then  begin
	If Screen[R,C] In ['q','x'] Then  begin
	  Sr := R - ( C - Prev_C );
	  Sc := C + ( R - Prev_R );
	  Bfill_A(Sr,Sc)
	end;
       end Else
      Some_one_there := true;
     until ( Some_one_There or (( R = Pos_R ) and ( C = pos_C ))) ;
  end;
  If Not Some_one_there Then 
     Display_Fill('A');
end;

Function Valid_move : Boolean;

Begin 
    Valid_move := False;
    Case (Dir_R+1) + (Dir_C+1)*4 Of 
      9 : { Right }
   	  If Ch_on[Play] in ['l','w','t','n','m','v','q'] Then 
   	      Valid_move := True;

      6 : { Down }
   	  If Ch_on[Play] in ['l','w','k','t','n','u','x'] Then 
   	      Valid_move := True;

      4 : { Up }
   	  If Ch_on[Play] in ['t','n','u','m','v','j','x'] Then
   	      Valid_move := True;

      1 : { Left }
   	  If Ch_on[Play] in ['w','k','n','u','v','j','q'] Then 
   	      Valid_move := True;

      end { Case };
end;

begin
   If Not Quit[Play] And (Ord(Responce[PLay]) = 0 )  Then begin
      Quit[PLay] := True;         {Initalise all Variables }
      Game[Play] := 0;
      Score[Play] := 0;
      Games_Won[PLay] := 0;
      Score_Set(Play,Score[Play],Game[PLay],Games_Won[PLay]);
   end else 
      If Not Quit[Play]  Then Begin
         Dir_R := Move_R[Play];
         Dir_C := Move_C[PLay];
	 pos_R := Head_R[Play];
         pos_C := Head_C[Play];
         { Change Direction Of The Position You Move To is Not A Wall ie = '.' }
   	 IF ( Ord(responce[play]) > 128 ) Then 
   	    Can_create[play] := true;
	 Responce[play] := Chr(Ord(Responce[play]) mod 16 );
         Case Ord(responce[Play]) Of 
            8 :   Begin
                     Dir_R := -1 ;
                     Dir_C := 0 ;      { Moving Up }
                  end;
            2 :   Begin
                     Dir_R := 1;
                     Dir_C := 0;         { Moving Down }
                  end;
            4 :   Begin
                     Dir_R := 0;          { Moving Left }
                     Dir_C := -1;
                  end;
            6 :   Begin
                     Dir_R := 0;            { Moving Right }
                     Dir_C := 1;
                  end;
            otherwise { Do Nothing Same Dir As Before }
         end { Case };
   	 If ((  pos_r + dir_r ) > 0 ) and 
   	    ((  pos_r + dir_r ) <= Screen_Dim_R ) and 
   	    ((  pos_c + dir_c ) > 0 ) and 
   	    ((  pos_c + dir_c ) <= Screen_Dim_C ) Then 
	    If Creating[play] Then begin
               If ( Dir_R = -1*Move_R[play]) and ( Dir_C = -1*Move_C[play]) Then Begin
                    Dir_R := Move_R[Play]; { Can't Reverse Your Direction }
                    Dir_C := Move_C[Play];
               end;
	       If Screen[pos_r + Dir_r, Pos_c + Dir_C] = ' ' THen Begin
   		  Area_Filled := Area_Filled + 1;
   		  New_Tail_Char;
	    	  At(pos_r,Pos_C,Screen[Pos_r,Pos_C]);
                  pos_r := Pos_R + Dir_R; Pos_C := Pos_C + Dir_C;
	    	  at(pos_R,pos_C,Head_sym[play]);
	       end else begin { v Must Be a Wall }
	    	  If not ( Screen[pos_r + Dir_r, Pos_c + Dir_C] = '*') Then begin
   		     new_tail_Char;
	    	     At(pos_r,Pos_C,Screen[Pos_r,Pos_C]);
   		     write_1(Chr(7));
                     pos_r := Pos_R + Dir_R; Pos_C := Pos_C + Dir_C;
   		     New_Join_Char(True); { Going into the wall }
		     If ( Screen[Pos_r,POs_C] = ' ') then 
			 Writeln('ERROR NEW JOIN CHAR IS BLANK ');
	       	     Creating[play] := False;
	       	     Can_create[play] := False;
	    	     at(pos_R,pos_C,Head_sym[play]);
		     Fill_area;
		  end 
	       end;		  		 
	    End Else { Not Creating }
	       If Not Valid_Move Then 
		  If ( Screen[pos_r + Dir_r, Pos_c + Dir_C] = ' ' ) Then 
		     If Can_Create[play] Then Begin
			Creating[play] := true;
			Screen[Pos_R,Pos_C] := Ch_on[play]; { For New_join_Char }
			New_join_Char(false); { Going Out Form Wall }
			At(pos_r,Pos_C,Screen[Pos_r,Pos_C]);
			Pos_r := Pos_R + Dir_R; Pos_C := Pos_C + Dir_C;
	    		At(pos_R,pos_C,Head_sym[play]);
		     end else 
   		  else 
   	       else begin
		  If ( Screen[pos_r + Dir_r, Pos_c + Dir_C] <> '*' ) Then Begin
		     Screen[Pos_r,Pos_C] := Ch_on[play];
		     At(pos_r,Pos_C,Screen[Pos_r,Pos_C]);
		     pos_r := Pos_R + Dir_R; Pos_C := Pos_C + Dir_C;
		     At(pos_R,pos_C,Head_sym[play]);
   		  end 
	       end
   	    {end};
   	 If Not (( Pos_R = Head_R[play] ) and ( Pos_C = Head_C[play])) Then Begin
            Move_R[Play] := Dir_r;
            Move_C[PLay] := Dir_c;
	    Head_R[Play] := pos_r;
            Head_C[Play] := pos_c;
   	    Ch_on[play]  := Screen[pos_r,Pos_C];
   	end;
   	Screen[Pos_r,Pos_C] := '*';
      end;
end;		     
		     

 begin
   If ( Game[You] Mod 2 ) = 1 Then Begin      { If 1 Then Loop Clockwise }
      For Play := 1 to Max_Player_number do 
         add_This_Players_head;
   end else 
      Begin
         For Play := Max_Player_Number downto 1 do 
            add_This_Players_head;               { Go Clockwise In Updating }
      end;
   If Area_Filled > Area_75_per Then  begin
      For Play := 1 to max_player_number do begin
   	game[play] := game[play] + 1;
        Score_Set(Play,Score[Play],Game[PLay],Games_Won[PLay]);
     end;
     Add_head := 0
   end else
     Add_Head := 1;            { 1 To Continue }
   at(24,80,chr(0));
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
  Writeln(esc,'<');
end.

