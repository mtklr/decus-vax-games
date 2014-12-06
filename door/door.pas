[ Inherit ('INTERACT') ]

program Door;

Const gap_to_home = 2;

Type 
     Screens = Array [1..24] of packed array [1..40] of char;
     traces  = Array [1..24] of array [1..40] of integer;

var Pc,Pr,dc,dr,score, 
    R,C ,
    Rc,Rr ,
    move ,
    Len,
    Screen_no ,
    lives ,
    Screen , 
    Num_dots  : integer;
    M         : traces;
    S         : Screens;
    was_dot   ,
    quit      : Boolean;

   Tim : integer;


Procedure at(X,Y:Integer;Ch:Char;I:Integer);
Begin 
   M[X,y] := I;
   IF S[X,y] = '~' then 
      Num_Dots := Num_Dots - 1;
   S[X,y] := ch;
   If ch = '~' then 
      Num_Dots := Num_Dots + 1;
   
   posn (y,x);
   qio_write (ch);
end;

Procedure New_Pos( var R,C : Integer );

Begin
   Repeat 
      R := rnd(4,22);
      C := rnd(4,38);
   Until ( S[R,c]  in ['~',' '] ) and ( M[R,c] < maxint );
end;

Procedure Initalise;

Var count,Er,Ec,W,Cc,Cr,Tr,Tc,Ix,Iy,J,F : Integer;
    posnd,Rev : Boolean;

Begin
   tim := max(5,tim - screen div 2);
   Screen := screen + 1;
   S[1]  := '@@@      @@      @@      @@      @@     ';
   S[2]  := '@@@  @@  @@  @@  @@  @@  @@  @@  @@  @@ ';
   S[3]  := '@@@~~@@~~@@~~@@~~@@~~@@~~@@~~@@~~@@~~@@ ';
   S[4]  := '  ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~  ';
   S[5]  := '  ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~  ';
   S[6]  := ' @@~~@@~~@@~~@@~~@@~~@@~~@@~~@@~~@@~~@@@';
   S[7]  := ' @@~~@@~~@@~~@@~~@@~~@@~~@@~~@@~~@@~~@@@';
   S[8]  := '  ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~  ';
   S[9]  := '  ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~  ';
   S[10] := '@@@~~@@~~@@~~@@~~@@~~@@~~@@~~@@~~@@~~@@ ';
   S[11] := '@@@~~@@~~@@~~@@~~@@~~@@~~@@~~@@~~@@~~@@ ';
   S[12] := '  ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~  ';
   S[13] := '  ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~  ';
   S[14] := ' @@~~@@~~@@~~@@~~@@~~@@~~@@~~@@~~@@~~@@@';
   S[15] := ' @@~~@@~~@@~~@@~~@@~~@@~~@@~~@@~~@@~~@@@';
   S[16] := '  ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~  ';
   S[17] := '  ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~  ';
   S[18] := '@@@~~@@~~@@~~@@~~@@~~@@~~@@~~@@~~@@~~@@ ';
   S[19] := '@@@~~@@~~@@~~@@~~@@~~@@~~@@~~@@~~@@~~@@ ';
   S[20] := '  ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~  ';
   S[21] := '  ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~  ';
   S[22] := ' @@~~@@~~@@~~@@~~@@~~@@~~@@~~@@~~@@~~@@@';
   S[23] := ' @@  @@  @@  @@  @@  @@  @@  @@  @@  @@@';
   S[24] := '     @@      @@      @@      @@      @@@'; 
   num_dots := 540;
   For Cr := 1 to 5 do 
      For Cc := 1 to 9 do begin
         tr := ( Cr - 1 ) * 4  + 3;
         tc := ( Cc - 1 ) * 4  + 3;
         posnd := false;
         count := 0 ;
         repeat 
            count := count + 1;
            case random(4) of          
               1 {top}   : If (S[tr+1,tc-1] <> 'a'  )   and 
                              (S[tr,tc-2] <> 'a' ) and 
                              (S[Tr-1,Tc+1] <> 'a' ) then begin
                             posnd := true;
                             S[tr,Tc+1] := 'a';
                             S[tr,Tc+2] := 'a';
                           end;                   
               2 {bot}   : If (S[tr+3,tc-2] <> 'a'  )   and 
                              ( (S[tr+1,tc-1] <> 'a'  )   or 
                               (S[tr-1,tc+1] <> 'a'  ) ) then begin 
                             posnd := true;
                            S[Tr+3,Tc+1] := 'a';
                            S[Tr+3,Tc+2] := 'a';
                          end;
               3 {left}  : If (S[tr,tc+1] <> 'a'  )   and
                              (S[tr+1,tc-1] <> 'a'  )   and
                              (S[tr-2,tc] <> 'a'  )   then begin 
                             posnd := true;
                            S[Tr+1,Tc] := 'a';
                            S[Tr+2,Tc] := 'a';
                           end;
               4 {right} :If (S[tr-2,tc+3] <> 'a'  )   and
                             ( (S[tr-1,tc+1] <> 'a'  )   or 
                              (S[tr+1,tc-1] <> 'a'  )   ) then begin 
                             posnd := true;
                            S[Tr+1,Tc+3] := 'a';
                            S[Tr+2,Tc+3] := 'a';
                          end;
               end { case };
         until posnd or ( count > 10 );
         If posnd then 
            Num_dots := Num_dots - 2;
      end;
   len := 0;   
   move := 0;
   rev := False;
   reset_screen;
   clear;
   qio_write (VT100_graphics_on);
   For R := 1 to 24 do begin
      qio_Write (VT100_Esc+'['+dec(R)+'H'+VT100_Esc+'#6');
      For C := 1 to 40 do 
         If ( S[r,c] = '@' ) Then Begin
            If not Rev Then begin
               rev := true;
               qio_Write(VT100_Esc+'[7m');
            end;
            qio_write(' ');
            M[r,c] := maxint;
         end Else begin
            If Rev Then Begin
               rev := false;
               qio_Write(VT100_Esc+'[m');
            end;
            qio_Write(S[R,c]);
            If S[R,c] = 'a' Then 
               M[R,c] := maxint
            else
               M[R,c] := 0;
         end;
      qio_write(VT100_Esc+'[H');
   end;
   qio_writeln(VT100_Esc+'[m'+VT100_graphics_on);
   New_Pos(Rr,Rc);
   If S[Rr,Rc] = '~' then 
      was_dot := true
   else
      was_dot := false;
   Repeat 
      New_pos(Pr,Pc); 
   until ( Abs(pr-Rr)+abs(Pc-Rc)) > 20  ;
   If S[Pr,PC] = '~' then begin
      Score := score + 1;
   end;
   at(Rr,Rc,'*',Move);
   at(Pr,Pc,'`',0);
   at(2,2,Chr( Ord('0') + Lives ),maxint);
   New_pos(Er,Ec);
   at(Er,Ec,'E',maxint);
end;



Procedure Do_Move;

var Valid : Boolean;

   Procedure Move_Robot;


   var I,temp_dist,dist,Rcr,Rcc,Rdc,Rdr,Alt_Rdc,Alt_Rdr,alt_move : Integer;

   Begin
      If S[Rr,Rc] = 'a' Then Begin { Been Hit By A Door }
         New_Pos(Rr,Rc);
         If S[Rr,Rc] = '~' then 
            was_dot := true 
         else
            was_dot := false;         
         at(Rr,Rc,'*',Move);
      end;
      dist := maxint;
      alt_move := maxint;
      For I := 1 to 4 do begin
         case I of 
            1 : Begin
                  Rcr := 1;
                  Rcc := 0;
                end;
            2 : Begin 
                  Rcr := -1;
                  Rcc := 0;
                end;
            3 : Begin
                  Rcr := 0;
                  Rcc := 1;
                end;
             4 : Begin
                   Rcr := 0;
                   Rcc := -1;
                 end;
         end { Case };
         If (( Rr + Rcr ) >= 1 ) and (( Rc + Rcc ) >= 1 ) and 
            (( Rr + Rcr ) <= 24 ) and (( Rc + Rcc ) <= 40 ) Then Begin
            temp_dist  := Abs((Rr+Rcr)-Pr)**2+Abs((Rc+Rcc)-Pc)**2;
            If ( ( temp_dist < dist ) and 
                 ( M[Rr+Rcr,Rc+Rcc] <= ( move - (temp_dist + 20)))) 
                              Then begin
                  dist := temp_dist;
                  Rdc  := Rcc;
                  Rdr  := Rcr;
            end else 
               if (  alt_move > M[Rr+Rcr,Rc+Rcc] ) then begin
                  alt_move := M[Rr+Rcr,Rc+Rcc] ;
                  alt_Rdc  := Rcc;
                  alt_Rdr  := Rcr;
               end;
         end;
      end;
      If Was_Dot Then 
         at(Rr,Rc,'~',move-1)
      else
         at(Rr,Rc,' ',move-1);
      If dist = maxint then begin
         RDr := alt_RDr;
         RDc := alt_Rdc;
      end;
      Rr := Rr + Rdr;
      Rc := Rc + Rdc;
      If S[Rr,Rc] = '`' Then Begin
         Lives := Lives - 1;
         If lives > 0 then begin 
            at(2,2,Chr( Ord('0') + Lives ),maxint);
            Repeat 
               New_pos(Pr,Pc); 
            until ( Abs(pr-Rr)+abs(Pc-Rc)) > 20  ;
            Dr := 0;
            Dc := 0;
            If S[Pr,PC] = '~' then begin
               Score := score + 1;
            end;
         end;
      end Else 
         If S[Rr,Rc] = '~' Then begin
            Was_Dot := true
         end else
            Was_dot := false;
      at(Rr,Rc,'*',move);         
   end;

   Procedure pos_Extra( Ch : Char );

   Var Er,Ec : Integer;

   Begin
     repeat 
        New_pos(Er,Ec);
     Until (Abs(Er - Rr) + Abs(Ec - Rc) < 12 ) and
           (S[Er+1,Ec] <> '@') and 
           (S[Er-1,Ec] <> '@') and 
           (S[Er,Ec+1] <> '@') and 
           (S[Er,Ec-1] <> '@');
     at(Er,Ec,ch,maxint);
    end;

Begin
  Move := Move + 1;
  Case Ord(qio_1_Char_Now) of 
      50 { 2 } :  Begin
                     dc := 0;
                     dr := 1;
                  end;
      52 { 4 }  : Begin
                     dr := 0;
                     dc := -1;
                  end;
      53 { 5 }  : Begin 
                     dc := 0;
                     dr := 0;
                  end;
      54 { 6 }  : Begin
                     dr := 0;
                     dc := 1;
                  end;
      56 { 8 } : Begin
                     dc := 0;
                     dr := -1;
                  end;
      48 { 0. Knock down } :
                     If (( pr + dr ) > 1 ) and (( Pc + Dc ) >  1 ) and 
                        (( Pr + dr ) < 24) and (( Pc + Dc ) < 40 ) Then 
                           If S[pr+dr,pc+dc] = 'a' Then begin
                              at(pr+dr,Pc+dc,' ',0);
                              Score := score - 20;
                           end;
      46 { . Stop } : repeat 
                        { nothing }
                      until qio_1_char = '.';
      81 { Q },113 {q} : Quit := True;
      otherwise 
   end { Case };
   Move_Robot;
   at(pr,pc,' ',0);
   valid := true;
   If (( pr + dr ) < 1 ) or (( Pc + Dc ) < 1 ) or
      (( Pr + dr ) > 24) or (( Pc + Dc ) > 40 ) Then 
      valid := False
   Else
      Case S[Pr+dr,Pc+dc] of 
         '~' : Score := Score + 1;
         '@' : Valid := false;
         ' ' : ;
         'a' : Begin
               If S[Pr+dc,Pc-dr] = '@' Then Begin
                  at(Pr+dr,Pc+dc,' ',0);
                  at(Pr+dr-dc,Pc+dc+dr,' ',0);
                  at(Pr+2*dr-2*dc,Pc+2*dr+2*dc,'a',maxint);
                  at(pr+3*dr-2*dc,Pc+2*dr+3*dc,'a',maxint);
               end else 
                  If S[Pr-dc,Pc+dr] = '@' Then Begin
                     at(pr+dr,Pc+dc,' ',0);
                     at(pr+dr+dc,Pc+dc-dr,' ',0);
                     at(Pr+2*dr+2*dc,Pc+2*dc-2*dr,'a',maxint);
                     at(Pr+3*dr+2*dc,Pc-2*dr+3*dc,'a',maxint);
                  end else
                     valid := false;
               end;
            '*'  : Begin 
                     Lives := Lives - 1;
                     If Lives > 0 then begin 
                        at(2,2,Chr( Ord('0') + Lives ),maxint);
                        qio_write (VT100_bell);
                        Repeat 
                           New_pos(Pr,Pc); 
                        until ( Abs(pr-Rr)+abs(Pc-Rc)) > 20 ;
                        Dr := 0;
                        Dc := 0;
                        If S[Pr,PC] = '~' then begin
                           Score := score + 1;
                        end;
                     end;
                   end;
               'E' : Pos_extra('X');
               'X' : Pos_extra('T');
               'T' : Pos_Extra('R');
               'R' : Pos_Extra('A');
               'A' : Score := Score + 250;
      end; { case}    
      If valid Then begin
         pr := pr + dr ;
         Pc := pc + dc ;
       end;
      at(pr,pc,'`',0);
   end;

Begin
 show_graphedt ('Door.scn');
 tim := 20;
 Score := 0;
 screen := 1;
 Quit := False;
 lives := 1;
  repeat 
   initalise;
    Repeat 
      Sleep_Start (tim);
      Do_Move;
      Sleep_Wait;
  until ( lives =  0 )  or ( quit ) or ( num_dots = 0 );
until ( lives =  0 )  or ( quit ) ;
top_ten(score);  
end.
