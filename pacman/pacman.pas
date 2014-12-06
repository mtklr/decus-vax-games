[ Inherit ('SYS$LIBRARY:STARLET','INTERACT') ]

{        Pacman is brought to you courtesy of :

        Martin Reid,
        University Of Waikato,
        Hamilton,
        New Zealand.

        Creation Date: Feb 1982

}

Program Pac_man;

{ Simulation of Arcade Game Pacman }

Type 
      How_Good     = (Good,Bad); { Used to specify whether the Greebly will
                                   move towards or away from the pacman - this
                                   depends upon whether the pacman has recently
                                   eaten a Pep pill. }
      General_Direction
                   = (Horizontal,Vertical);
      Ch           = Packed Array[1..1] Of Char;   { String Descriptor For Put_Screen }
      Way          = (Up,Right,Down,Left,Nowhere); { Direction Of Movement }
      Screen_Line  = Packed Array[1..40] of Char;  { Line to be read in from a File }
      Screen_Array = Array[1..24] of Screen_line;  { Contains Every Char in Screen }
      Horrible_little_object = Record
                               y_pos,x_pos : Integer;
                               Shape : Char;
                               End;
Var Direction : Way;
    Moved_Once : Boolean;
    Frames : Integer;
    Greebly_Val : Integer;
    achar : Char;
    J : Integer;
    Adate,Atime : Packed Array [1..11] Of Char;
    Lowest : Integer;
    Skill : Integer;
    Dots_left : Integer;
    Save_x,Save_y : Integer;
    Lives : Integer;
    Strength : Integer;
    Fightback : Boolean;
    Lastmove : Way;
    X_Dist,Y_dist : Integer;
    Score : Integer;
    Moved : Boolean;
    Greebly : Horrible_little_object;
    Command : Integer;
    a,I : Integer;
    Maze_line : Screen_line;
    Pacman : Horrible_little_object;
    Bell,Dot,Asterisk,Blank : Char;
    Screen : Screen_Array;
    Zap : Char;

Procedure Eat; Forward;
Procedure Move_pacman; Forward;
Procedure Move_Greebly; Forward;

Procedure Initialise;
Begin
   Moved_Once := False;
   Skill := 75;
   (*Frames := -4;*)
   Frames := -1;
   Lives := 3;
   Score := 0;
   Bell := Chr(7);
   Blank := ' ';
   Pacman.Shape := '`';
   Dot := '~';
   Asterisk := '*';
   Greebly.Shape := '#';
   Image_dir;
   show_graphedt('PACMAN.INS');
End;

Procedure Draw_Maze;
Begin
   show_graphedt('PACMAN.SCN',wait:=false);
   qio_Write (VT100_Esc+'<'+VT100_Esc+'[m'+VT100_Esc+'(B');
   posn (1,1);
   qio_Write (VT100_Esc+'#6SCORE:'+VT100_Esc+'[1;8H'+dec(score,,5));
   Screen[2] := 'XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX';
   Screen[3] := 'X~~~~~~~~~~~~~~~~~~~X~~~~~~~~~~~~~~~~~~X';
   Screen[4] := 'X~XXXXXXX~XXXXXXXXX~X~XXXXXXXXX~XXXXXX~X';
   Screen[5] := 'X*XXXXXXX~XXXXXXXXX~X~XXXXXXXXX~XXXXXX*X';
   Screen[6] := 'X~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~X';
   Screen[7] := 'XXXXXXXXXX~X~XXXXXXXXXXXXXXX~X~XXXXXXXXX';
   Screen[8] := '         X~X~~~~~~~~X~~~~~~~~X~X        ';
   Screen[9] := '         X~XXXXXXXX~X~XXXXXXXX~X        ';
   Screen[10] := 'XXXXXXXXXX~X        X        X~XXXXXXXXX';
   Screen[11] := '          ~                   ~         ';
   Screen[12] := '          ~  XXXXXXXXXXXXXXX  ~         ';
   Screen[13] := 'XXXXXXXXXX~X X             X X~XXXXXXXXX';
   Screen[14] := '         X~X XXXXXXXXXXXXXXX X~X        ';
   Screen[15] := '         X~X                 X~X        ';
   Screen[16] := 'XXXXXXXXXX~X XXXXXXXXXXXXXXX X~XXXXXXXXX';
   Screen[17] := 'X~~~~~~~~~~~~~~~~~~~X~~~~~~~~~~~~~~~~~~X';
   Screen[18] := 'X~XXXXXXXXX~XXXXXXX~X~XXXXXXX~XXXXXXXX~X';
   Screen[19] := 'X*~~~~~~~~X~~~~~~~~~~~~~~~~~~~X~~~~~~~*X';
   Screen[20] := 'XXXXXXXXX~X~XXXXXXXXXXXXXXXXX~X~XXXXXXXX';
   Screen[21] := 'X~~~~~~~~~~~~~~~~~~~X~~~~~~~~~~~~~~~~~~X';
   Screen[22] := 'X~XXXXXXXXXXXXXXXXX~X~XXXXXXXXXXXXXXXX~X';
   Screen[23] := 'X~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~X';
   Screen[24] := 'XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX';
End;

Procedure Put_Screen(What : Char; Y,X  : Integer);
   Begin
      If  Not ((Y < 1) Or (Y > 24) Or ( X < 1 ) Or ( X > 40))  Then
       qio_write (get_posn(x,y)+What);
   End;


Procedure Add_To_Score(Number : Integer);
   Begin
      Score := Score + Number;
      If Number > 5 Then
         Begin
            qio_Write (get_posn(19,13)+dec(Number,,4));
            qio_Write (get_posn(8,1)+dec(Score,,5));
         End
      Else 
      If Score Mod 10 = 0 Then
        qio_Write (get_posn(8,1)+dec(Score,,5));
      If Number = 5 Then Fightback := True;
      Dots_left := Pred(Dots_left);
      Screen[pacman.y_pos,pacman.x_pos] := ' ';
   End;

Procedure Move_A_Greebly(Which_Way : Way);
   Begin
      Lastmove := Which_way;
      Moved := True;
      With Greebly Do
         Begin
            If Random(100) < Skill Then
               Begin
                  If Screen[Y_Pos,X_pos] = '~' Then
                          Put_Screen(Dot,Y_pos,X_Pos)
                  Else 
                        If Screen[Y_Pos,X_pos] = '*' Then 
                                Put_Screen(Asterisk,Y_Pos,X_Pos)
                        Else    Put_Screen(Blank,Y_Pos,X_Pos);
                  Case Which_way Of
                   Up     : Y_Pos := Pred(Y_Pos);
                   Right  : Begin
                               If X_Pos > 38 Then X_Pos := 0;
                               X_Pos := Succ(X_Pos);
                            End;
                   Down   : Y_Pos := Succ(Y_Pos);
                   Left   : Begin
                               If X_Pos < 3 Then X_Pos := 41;
                               X_Pos := Pred(X_Pos);
                            End;
               End;
      End;
      Put_Screen(Shape,Y_pos,X_Pos);
      If Skill > 100 Then
         If random (100) < (Skill mod 100) Then 
            If Not Moved_Once Then
               Begin 
                  Move_Greebly;
                  Moved_Once := True;
               End
         Else
            Moved_Once := False;
      End;
End;
            

Procedure Find_A_Move(Quality   : How_Good ;
                      Indicator : General_Direction);
   Begin
      With Greebly Do
      Begin
      Case Indicator Of
      Horizontal : Begin
                      Case Quality Of
                      Good : Begin
                               If X_Dist > 0 Then  { Want to move RIGHT }
                                 Begin
                                  If (Succ(X_Pos) <> 41) Then
                                    Begin
                                      If Not ((Screen[Y_Pos,Succ(X_Pos)] = 'X') Or
                                              (Screen[Y_pos,Succ(X_Pos)] = '#') Or
                                              (Not fightback and (lastmove = Left))) Then
                                      Move_A_Greebly(Right);  {Moves And Sets Moved to TRUE }
                                    End
                                  Else
                                    Begin
                                      If Not ((Screen[Y_Pos,1] = 'X') Or
                                              (Screen[Y_pos,1] = '#') Or
                                              (Not fightback and (lastmove = Left))) Then
                                      Move_A_Greebly(Right);  {Moves And Sets Moved to TRUE }
                                    End;
                                 End
                               Else 
                               If (Pred(X_Pos) <> 0) then
                                 Begin
                                   If Not ((Screen[Y_Pos,Pred(X_Pos)] = 'X') Or
                                          (Screen[Y_pos,Pred(X_Pos)] = '#') Or
                                          (Not Fightback and (lastmove = Right))) Then
                                  Move_A_Greebly(Left);  {Moves And Sets Moved to TRUE }
                                 End
                               Else
                                 Begin
                                   If Not ((Screen[Y_Pos,40] = 'X') Or
                                          (Screen[Y_pos,40] = '#') Or
                                          (Not Fightback and (lastmove = Right))) Then
                                     Move_A_Greebly(Left);  {Moves And Sets Moved to TRUE }
                                 End;
                             End;
                   Bad  : Begin
                               If X_Dist <= 0 Then  { Want to move RIGHT }
                                Begin
                                  If (Succ(X_Pos)<>41) Then
                                    Begin
                                      If Not ((Screen[Y_Pos,Succ(X_Pos)] = 'X') Or
                                              (Screen[Y_pos,Succ(X_Pos)] = '#') Or
                                              (Not fightback and (lastmove = Left))) Then
                                      Move_A_Greebly(Right);  {Moves And Sets Moved to TRUE }
                                    End
                                  Else
                                    Begin
                                      If Not ((Screen[Y_Pos,1] = 'X') Or
                                              (Screen[Y_pos,1] = '#') Or
                                              (Not fightback and (lastmove = Left))) Then
                                      Move_A_Greebly(Right);  {Moves And Sets Moved to TRUE }
                                    End
                                End
                               Else 
                                 Begin
                                   If (Pred(X_Pos)<>0) Then
                                     Begin
                                       If Not ((Screen[Y_Pos,Pred(X_Pos)] = 'X') Or
                                              (Screen[Y_pos,Pred(X_Pos)] = '#') Or
                                              (Not Fightback and (lastmove = Right))) Then
                                          Move_A_Greebly(Left);  {Moves And Sets Moved to TRUE }
                                     End
                                   Else
                                     Begin
                                       If Not ((Screen[Y_Pos,40] = 'X') Or
                                              (Screen[Y_pos,40] = '#') Or
                                              (Not Fightback and (lastmove = Right))) Then
                                          Move_A_Greebly(Left);  {Moves And Sets Moved to TRUE }
                                     End;
                                 End;
                          End;
                   End;
                   End;
      Vertical   : Begin
                      Case Quality Of
                      Good : Begin
                               If Y_Dist > 0 Then  { Want to move DOWN }
                                 BEGIN
                                  If Not ((Screen[Succ(Y_Pos),X_Pos] = 'X') Or
                                          (Screen[Succ(Y_pos),X_Pos] = '#') Or 
                                          (Screen[Succ(Y_pos),X_pos] = '^') Or
                                          (Not Fightback and (lastmove = Up))) Then
                                  Move_A_Greebly(Down); {Moves And Sets Moved to TRUE }
                                 END
                               Else 
                                  If Not ((Screen[Pred(Y_Pos),X_Pos] = 'X') Or
                                          (Screen[Pred(Y_pos),X_Pos] = '#') Or
                                          (Not Fightback and (lastmove = Down))) Then
                                  Move_A_Greebly(Up); {Moves And Sets Moved to TRUE }
                            End;
                      Bad : Begin
                               If Y_Dist <= 0 Then  { Want to move DOWN }
                                 BEGIN
                                  If Not ((Screen[Succ(Y_Pos),X_Pos] = 'X') Or
                                          (Screen[Succ(Y_pos),X_Pos] = '#') Or 
                                          (Screen[Succ(Y_pos),X_pos] = '^') Or
                                          (Not Fightback and (lastmove = Up))) Then
                                  Move_A_Greebly(Down); {Moves And Sets Moved to TRUE }
                                END
                               Else 
                                  If Not ((Screen[Pred(Y_Pos),X_Pos] = 'X') Or
                                          (Screen[Pred(Y_pos),X_Pos] = '#') Or
                                          (Not Fightback and (lastmove = Down))) Then
                                  Move_A_Greebly(Up); {Moves And Sets Moved to TRUE }
                            End;
                      End;
                   End;
               End;
      End;
   End;


Procedure Move_Greebly;
Begin
   Moved := False;
   With Greebly Do
      Begin
         X_Dist := Pacman.X_pos - X_pos; 
         Y_Dist := Pacman.Y_pos - Y_pos;
         If (X_dist = 0) And (Y_dist = 0) Then Eat;
         If ( Y_Pos = 12 ) or ( Y_Pos = 13 ) Then { Optimize for Tunnel }
            If Abs ( X_Dist ) > 20 Then
               X_Dist := -X_Dist;
         If Abs(X_dist) > Abs(Y_dist) Then { We want to move towards it }
                                           { horizontally    this  move }
             Begin
               If Fightback Then
                 Begin
                   Find_A_Move(Bad,Vertical);
                If Not Moved Then 
                   Find_A_Move(Bad,Horizontal);
                If Not Moved Then
                   Find_A_Move(Good,Horizontal);
                If Not Moved Then
                   Find_A_Move(Good,Vertical);
                 End
            Else
              Begin
                Find_A_Move(Good,Horizontal);
                If Not Moved Then
                   Find_A_Move(Good,Vertical);
                If Not Moved Then
                   Find_A_Move(Bad,Vertical);
                If Not Moved Then 
                   Find_A_Move(Bad,Horizontal);
             End;
             End
         Else 
            Begin
               If Fightback Then
                  Begin
                   Find_A_Move(Bad,Horizontal);
                   If Not Moved Then
                   Find_A_Move(Bad,Vertical);
                   If Not Moved Then
                   Find_A_Move(Good,Horizontal);
                   If Not Moved Then
                   Find_A_Move(Good,Vertical);
                  End
                Else
                 Begin
               Find_A_Move(Good,Vertical);
                If Not Moved Then
                   Find_A_Move(Good,Horizontal);
                If Not Moved Then
                   Find_A_Move(Bad,Horizontal);
                If Not Moved Then
                   Find_A_Move(Bad,Vertical);
                 End;
            End;
      end;
End;

Procedure Greebly_start;
   Begin
      save_x := Pacman.x_pos;
      save_y := Pacman.y_pos;
      Fightback := false;
      Lastmove := Nowhere;
      Greebly.X_Pos := 20;
      Greebly.Y_Pos := 12;
      pacman.x_pos := 20;
      pacman.y_pos := 1;
      Move_Greebly;
      Move_Greebly;
      pacman.x_pos := save_x;
      pacman.y_pos := save_y;
   End;

Procedure Pacman_Start;
   Begin
      Pacman.x_pos := 20;
      Pacman.Y_pos := 19;
      strength := 0;
      Move_Pacman;
   End;

Procedure Eat;
   Begin
      Put_Screen(Bell,1,1);
      If Fightback Then
         Begin
         Greebly_Val := 2*Greebly_Val;
         Add_To_Score(Greebly_Val);
         Strength := 40;
         Dots_left := succ(Dots_left);
         Greebly_Start;
         End
      Else
         Begin
         Lives := pred(lives);
         If lives = 0 Then 
           BEGIN
             qio_Write (VT100_Esc+'<'+VT100_Esc+'(B'+VT100_Esc+'[m'+VT100_Esc+'[?8h');
             Top_ten(Score);
             $exit(1);
           END;
         qio_Write (VT100_graphics_off);
         posn (15,1);
         qio_write ('Frames :'+dec(Frames)+'    Lives '+VT100_Graphics_on+Pad(Pad('','`',lives),' ',3));
         Greebly_Start;
         Put_Screen(Blank,Pacman.Y_Pos,Pacman.X_Pos);
         Pacman_Start;
         End;
   End;

Procedure Move_Pacman;
Begin
   Command := ord(qio_1_Char_Now);
   If (Pacman.X_pos = Greebly.X_pos) and
      (Pacman.Y_Pos = Greebly.Y_Pos) Then Eat;
   If Command <> 255 Then
   Case Command Of
        56     : Direction := Up;
        54     : Direction := Right;
        52     : Direction := Left;
        50     : Direction := Down;
        81,113 : BEGIN
                   qio_Write (VT100_Esc+'<'+VT100_Esc+'(B'+VT100_Esc+'[m'+VT100_Esc+'[?8h');
                   Top_ten(Score);
                   $exit(1);
                 END;
        Otherwise Direction := Nowhere;
    End;
    If Direction <> Nowhere Then
      Put_Screen(Blank,pacman.y_pos,pacman.x_pos);
    Case Direction Of
         Up    : If (pacman.y_pos > 0)  And
                 (Not( Screen[Pred(pacman.y_pos),pacman.x_pos] = 'X')) Then 
                 pacman.y_pos := Pred ( pacman.y_pos );
         Right : If (pacman.x_pos < 40) Then
                   Begin
                    If Not( Screen[pacman.y_pos,Succ(pacman.x_pos)] = 'X') Then 
                       pacman.x_pos := Succ ( pacman.x_pos );
                   End
                 Else 
                      Pacman.x_pos := 1;
         Left  : If (pacman.x_pos > 1) Then
                   Begin
                   If Not( Screen[pacman.y_pos,Pred( pacman.x_pos)] = 'X') Then 
                       pacman.x_pos := Pred ( pacman.x_pos );
                   end
                 Else 
                   Pacman.x_pos := 40;
         Down  : If (pacman.y_pos < 24) And 
                 (Not( Screen[Succ(pacman.y_pos),pacman.x_pos] = 'X')) Then 
                 pacman.y_pos := Succ ( pacman.y_pos );
         Otherwise
         End;
         If Direction <> Nowhere Then
           Put_Screen(Pacman.Shape,pacman.y_pos,pacman.x_pos);
         If Screen[pacman.y_pos,pacman.x_pos] = '~' Then
            Add_to_Score(1)
         Else 
            If Screen[pacman.y_pos,pacman.x_pos] = '*' Then
               Begin
                Add_To_Score(5);
                Fightback := True;
                Greebly.Shape := 'a';
               End;
End;

Begin
Initialise;
qio_Write (VT100_Esc+'<'+VT100_Esc+'[?8l'); 
While lives > 0 Do
   Begin
      qio_purge;
      Frames := Frames + 1;
      If Skill < 95 Then
         Skill := Skill + 5
      Else
         Skill := Skill + 1;
      Draw_maze;
      qio_Write (VT100_graphics_off);
      posn (15,1);
      qio_Write ('Frames :'+dec(Frames)+'    Lives '+VT100_graphics_on);
      For I := 1 To lives Do qio_Write ('`');
      For I := lives To 3 Do qio_Write (' ');
      Pacman.X_Pos := 20;
      Pacman.Y_pos := 19;
      Greebly.Shape := '#';
      Greebly_Start;
      Pacman_Start;
      Dots_left := 288;
      Greebly_Val := 10;
      While Dots_Left > 0 Do
          Begin
             Sleep_Start (15);
             Move_Pacman;
             If Fightback Then
                Strength := Succ (Strength);
             If Strength = 40 Then
                Begin
                  Fightback := False;
                  Greebly.Shape := '#';
                  Strength := 0;    
                End;
             If Random(4)<>1 then
               Move_Greebly;
             posn (1,1);
             Sleep_Wait;
          End;
   End;
qio_Write (VT100_Esc+'<'+VT100_Esc+'(B'+VT100_Esc+'[m'+VT100_Esc+'[?8h');
Top_ten(Score);
End.
