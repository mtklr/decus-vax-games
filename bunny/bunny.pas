[ Inherit ('INTERACT') ]

Program  Bunny_Hunt (ins_file);

CONST
  hole_pos = 11;

TYPE
  one_nine = 1..9;
  two = array[1..2] of integer;
  two_char = Packed Array[1..2] of char;
  one_10 = Packed Array[1..10] of char;
  one_17 = Packed Array[1..17] of char;
  one_49 = Packed Array[1..49] of char;
  super_b_type = record
                  pos  : two;
                  sb_level:integer;
                 end;

  bunny_type = record
                   pos   : two;
                   alive : boolean;
                 end;

  level_type = record
                 any_bunnies : boolean;
                 bunny       : array[1..20] of bunny_type;
               end;

var 
 last_pos,
 evador   : two;
 max_g_at : array[one_nine] of integer;
 level    : array[one_nine] of level_type;
 score_ch : packed array[0..3] of char;
 ins_file : text;

 super_bunny : super_b_type;
 last_at_den,
 at_den      : two;
 seed        : real;
 ev_speed,  score,  cmd,
 this_level, last_level,
 limit, counter, time_thru, bunny_speed,
 den_ux, den_uy, den_lx, den_ly, den_dir  : integer;
 exit, failure, success,
 just_turned, next_level_found : boolean;


Procedure  spot(x,y :integer; ch :char);
begin
 x := x + 1; y := y + 7;
 posn (y,x);
 qio_write (ch);
end;  


Procedure  send_message(x :integer; message :one_49);
VAR
  l,k :integer;
begin
 qio_write (VT100_graphics_off);
 for l := 0 to 6 do
  begin
   posn (32,x+l);
   last_pos[1] := 8888;
   for k := 1 to 7 do
     qio_write (message[(l*7)+k]);
  end;
 qio_write (VT100_graphics_on);
end;


Procedure  main_message(x :integer; message :one_17);
var  l,k :integer;

begin
 qio_write (VT100_graphics_off);
 posn (9,x);
 last_pos[1] := 8888;
 for k := 1 to 17 do
   qio_write (message[k]);
 qio_write (VT100_graphics_on);
end;


Procedure  tell_story;
var   len :integer;
    ins_line :varying [256] of char;

begin
 open(ins_file,'Image_dir:bunny.scn',history := readonly,error := continue);
 if status(ins_file) = 0 then
  begin
   reset(ins_file);
   while not eof(ins_file) do
    begin
     readln(ins_file,ins_line);
     len := ins_line.length;
     if len = 3
      then qio_1_char
      else qio_write(ins_line);
    end;
  end
 else
  begin
   clear;
   main_message(5,' Can''t find the  ');
   main_message(7,'  instructions...');
   main_message(9,'  It''s all up to ');
   main_message(11,'     you now.    ');
   main_message(15,'   Good Luck...  ');
  end;
 qio_1_char;
end;  


Procedure  assign_bunnies;
var  k,l :integer;
begin
 seed := clock;
 for k := 1 to 9 do
 with level[k] do
  begin
   any_bunnies := true;
   for l := 1 to max_g_at[k] do
   with bunny[l] do
    begin
     alive := true;
     case random(4) of
      1 : begin
           pos[1] := random(21);
           pos[2] := random(8);
          end;
      2 : begin
           pos[1] := random(8);
           pos[2] := random(21);
          end;
      3 : begin
           pos[1] := random(21);
           pos[2] := 13+random(8);
          end;
      4 : begin
           pos[1] := 13+random(8);
           pos[2] := random(21);
          end
     end; 
    end;
  end;
end; 


Procedure  initialise;
var   l ,k : integer;
begin
 for k:=1 to 9 do max_g_at[k] := k+4;
 assign_bunnies;
 bunny_speed:= 1;
 time_thru  := 1;
 this_level := 1;
 limit      := 1;
 ev_speed   := 50;
 score      := 0;
 for k := 0 to 3 do 
   score_ch[k] := ' ';
 super_bunny.pos[1]   := 11;
 super_bunny.pos[2]   := 11;
 super_bunny.sb_level := 0;
 next_level_found     := true;
 {** Bunny Den **}
 at_den[1] := 1; at_den[2] := 1; den_dir:=3;
 den_ux:=21; den_uy:=21; den_lx:=1; den_ly:=1; just_turned := true;
end; 


Procedure  plot(x,y :integer; ch :char);
begin
 if ((x in [1..21]) and (y in [1..21])) then
   qio_write(Get_posn(y+7,x+1)+ch);
end;


Procedure  boom;
var  ch : char;
      k : integer;
begin
 ch := '.';
 for k := 1 to 2 do
 begin
  plot(evador[1],evador[2],ch);     plot(evador[1]+1,evador[2],ch);
  plot(evador[1]-1,evador[2]-1,ch); plot(evador[1],evador[2]+1,ch);
  plot(evador[1]+1,evador[2]-1,ch); plot(evador[1]-1,evador[2]+1,ch);
  plot(evador[1]+2,evador[2],ch);   plot(evador[1]-2,evador[2],ch);
  plot(evador[1]+1,evador[2]+1,ch); plot(evador[1],evador[2]-1,ch);
  plot(evador[1],evador[2]+2,ch);   plot(evador[1]-2,evador[2]+2,ch);
  plot(evador[1]-1,evador[2]-2,ch); plot(evador[1]+2,evador[2]-2,ch);
  plot(evador[1]+2,evador[2]+2,ch); ch := ' ';
 end;
end;


Procedure  Draw_level_value;
begin
  if last_level > 0 then
    BEGIN
      posn (3,3 + ((10 - last_level) * 2));
      qio_write (' ');
    END;
  if this_level > 0 then
    BEGIN
      posn (3,3 + ((10 - this_level) * 2));
      qio_write (chr(this_level + 48));
    END;
 last_pos[1] := 8888;
end;


Procedure  draw_new_score;
var  k :integer;
Begin
 posn (1,1);
 for k := 0 to 3 do
  if not ( ( (((score)mod(10 ** (4-k)))div(10 ** (3-k))) = 0 )
             and (score_ch[k] = ' ') )
   then score_ch[k] := chr( (((score)mod(10 ** (4-k)))div(10 ** (3-k))) + 48 );
 qio_write (score_ch[0] + score_ch[1] + score_ch[2] + score_ch[3]);
End;  


Procedure  sub_draw(value : one_nine; x_val : integer);
var  l : integer;
begin
 send_message(x_val+1,'                                                 ');
 with level[value] do
  for l := 1 to max_g_at[value] do
   begin
    if bunny[l].alive then
     begin
      with bunny[l] do
       spot( ((pos[1]-1)DIV(3) + x_val),((pos[2]-1)DIV(3) + 25),'.' );
     end;
   end;
end;


Procedure  draw_next_level_up;
var  k : integer;
begin
 if this_level < 9 then
  begin
   k := this_level;
   Repeat
    k := k+1;
   Until ((level[k].any_bunnies) or (k=9));
   if level[k].any_bunnies then
    sub_draw(k,3)
   else
    send_message(4,'         No           Upper         Level        ');
  end
 else
  send_message(4,'          On           Top          Level        ');
end; 


Procedure  draw_next_level_down;
var  k : integer;
begin
 if this_level > 1 then
  begin
   k := this_level;
   Repeat
    k := k-1;
   Until ((level[k].any_bunnies) or (k=1));
   if level[k].any_bunnies
    then sub_draw(k,14)
    else
     send_message(15,'          No          Lower         Level        ');
  end
 else
  send_message(15,'          On         Lowest         Level        ');
end; 



Procedure  plot_bunnies(value :one_nine; chr :char);
var  k:integer;
begin
 spot(11,11,'a');
 with level[value] do
 for k := 1 to max_G_at[value] do
  if bunny[k].alive then
    with bunny[k] do spot(pos[1],pos[2],chr);
 with super_bunny do
 begin
  if (this_level = sb_level)
   then spot(pos[1],pos[2],'#')
   else
    begin
     if (pos[1] = 11) and (pos[2] = 11)
      then spot(pos[1],pos[2],'a')
      else spot(pos[1],pos[2],' ');
    end;
 end;
end;  

Procedure  move_bunnies;
var
  l,k : integer;
  dir : array[1..2] of -1..1;

begin
 for k := 1 to max_G_at[this_level] do
 with level[this_level].bunny[k] do
  if alive then
   begin
    for l := 1 to 2 do
     if pos[l] < evador[l]
      then dir[l]:=1
      else dir[l]:=-1;
    spot(pos[1],pos[2],' ');
    if (ABS(pos[1] - evador[1]) >= ABS(pos[2] - evador[2]))
     then pos[1] := pos[1] + dir[1]
     else pos[2] := pos[2] + dir[2];
    if (pos[1] = evador[1]) and (pos[2] = evador[2])
     then failure := true;
    if ((pos[1] = hole_pos) and (pos[2] = hole_pos))
     then
      begin
       alive := false;
       case this_level of
        1,2,3 : score := score + (time_thru * this_level);
        4,5,6 : score := score + (2 * time_thru * this_level);
        7,8,9 : score := score + (3 * time_thru * this_level)
       end;
       draw_new_score;
      end
     else spot(pos[1],pos[2],'*');
    if alive then level[this_level].any_bunnies := true;
   end; { for k , if alive , with level[this_level].bunny[k]}
end;  


Procedure  Plot_Bunny_den(ch :char);
var lx,ly,ux,uy,x,y :integer;
    met :boolean;
begin
 spot(11,11,ch);
 Draw_next_level_up;
 y:=1; ly:=1; lx:=0; uy:=21; ux:=21;
 met := false;
 Repeat
  x:=lx;
  Repeat
   x:=x+1;
   if not ((x=at_den[1]) and (y=at_den[2]))
    then spot(x,y,ch)
    else met:=true;
  until met or (x=ux);
  lx:=lx+1;
   if not met then
   begin
    y:=ly;
    Repeat
     y:=y+1;
     if not ((x=at_den[1]) and (y=at_den[2]))
      then spot(x,y,ch)
      else met:=true;
    until met or (y=uy);
    ly:=ly+1;
    end;
  if not met then
   begin
    x:=ux;
    Repeat
     x:=x-1;
     if not ((x=at_den[1]) and (y=at_den[2]))
      then spot(x,y,ch)
      else met:=true;
    until met or (x=lx);
    ux:=ux-1;
    end;
  if not met then
   begin
    y:=uy;
    Repeat
     y:=y-1;
     if not ((x=at_den[1]) and (y=at_den[2]))
      then spot(x,y,ch)
      else met:=true;
    until met or (y=ly);
    uy:=uy-1;
   end;
 until met;
end; 


Procedure  Close_in_den;

 Function  cond_main :boolean;
 begin
  cond_main := ((evador[1] >= den_lx) and (evador[1] <= den_ux)
               and (evador[2] >= den_ly) and (evador[2] <= den_uy));
 end;

 Function  cond_1 :boolean;
 begin
  cond_1 := (at_den[2]=den_ly) and (evador[1]>at_den[1]) and
              (evador[1]<den_ux) and (evador[2]=den_ly);
 end;

 Function  cond_2 :boolean;
 begin
  cond_2 := (at_den[1]=den_ux) and (evador[2]>at_den[2]) and
              (evador[2]<den_uy) and (evador[1]=den_ux);
 end;

 Function  cond_3 :boolean;
 begin
  cond_3 := (at_den[2]=den_uy) and (evador[1]<at_den[1]) and
              (evador[1]>den_lx) and (evador[2]=den_uy);
 end;

 Function  cond_4 :boolean;
 begin
  cond_4 := (at_den[1]=den_lx) and (evador[2]<at_den[2]) and
              (evador[2]>den_ly) and (evador[1]=den_lx);
 end;

begin 
 last_pos := last_at_den;
 spot(at_den[1],at_den[2],'a');
 if not just_turned then
  begin
   if (at_den[1]=den_ux) and (at_den[2]=den_ly) then
    begin
     den_dir:=2; den_ly:=den_ly+1; just_turned := true;
    end;
   if (at_den[1]=den_lx) and (at_den[2]=den_uy) then
    begin 
     den_dir:=4; den_uy:=den_uy-1; just_turned := true;
    end;
   if (at_den[2]=den_ly) and (at_den[1]=den_lx) then
    begin
     den_dir:=3; den_lx:=den_lx+1; just_turned := true;
    end;
   if (at_den[2]=den_uy) and (at_den[1]=den_ux) then
    begin
     den_dir:=1; den_ux:=den_ux-1; just_turned := true;
    end;
  end  
 else
  just_turned := false;
 last_at_den := at_den;
 case den_dir of
  1 : at_den[1]:=at_den[1]-1;
  2 : at_den[2]:=at_den[2]+1;
  3 : at_den[1]:=at_den[1]+1;
  4 : at_den[2]:=at_den[2]-1
 end;
 if NOT (cond_main or cond_1 or cond_2 or cond_3 or cond_4)
      OR ((at_den[1] = evador[1]) and (at_den[2] = evador[2])) then
  begin
   boom;
   failure := true;
  end;
end; 


Procedure  Next_level_up;
var k:integer;
begin
 next_level_found := false;
 if this_level < 9 then
  begin
   k := this_level;
   repeat
    k:=k+1;
   until ((level[k].any_bunnies) or (k=9));
   if level[k].any_bunnies then
    begin
     next_level_found := true;
     last_level := this_level;
     if last_level >= 1
      then plot_bunnies(last_level,' ')
      else plot_Bunny_den(' '); 
     this_level := k;
     plot_bunnies(this_level,'*');
     Draw_level_value;
     draw_next_level_up;
     draw_next_level_down;
    end
   else
    send_message(4,'          No          Upper         Level        ');
  end
 else
  send_message(4,'          On           Top          Level        ');
end; 


Procedure  Next_level_down(go_into_den :boolean);
var k:integer;

begin
 next_level_found := false;
 if this_level > 1 then
  begin
   k := this_level;
   repeat
    k:=k-1;
   until ((level[k].any_bunnies) or (k=1));
   if level[k].any_bunnies then
    begin
     next_level_found := true;
     last_level := this_level;
     plot_bunnies(last_level,' ');
     this_level := k;
     plot_bunnies(this_level,'*');
     draw_level_value;
     draw_next_level_up;
     draw_next_level_down;
    end
   else
    if go_into_den then
     begin
      send_message(15,' Into  The Denof the  Great Bunny   with   you!  ');
      last_level := this_level;
      this_level:=0;
      plot_bunnies(last_level,' ');
      plot_Bunny_den('a');
     end;
  end
 else
  if go_into_den then
   begin
    send_message(15,'So You Want togo that  far   Down    Ay?         ');
    last_level := this_level;
    this_level:=0;
    plot_bunnies(last_level,' ');
    draw_level_value;
    plot_Bunny_den('a');
   end;
end; 


Procedure  Move_Super_Bunny;
var  l,k :integer;
     dir : array[1..2] of -1..1;
     dist: array[1..2] of integer;

begin
 with super_bunny do
 begin
  if (sb_level = this_level) then
   begin
    for l := 1 to 2 do
     begin
      dist[l] := ABS(evador[l] - pos[l]);
      if pos[l] > evador[l]
       then dir[l] := -1
       else dir[l] := 1;
      if ((21 - ABS(evador[l] - pos[l])) < ABS(evador[l] - pos[l])) then
       begin
        dir[l] := -1 * dir[l];
        dist[l] := 21 - ABS(evador[l] - pos[l]);
       end
      else
       dist[l] := ABS(evador[l] - pos[l]);
     end;
    if (pos[1] = 11) and (pos[2] = 11)
     then spot(pos[1],pos[2],'a')
     else spot(pos[1],pos[2],' ');
    if dist[1] >= dist[2]
     then pos[1] := pos[1] + dir[1]
     else pos[2] := pos[2] + dir[2];
    if pos[1] > 21 then pos[1] := 1;
    if pos[2] > 21 then pos[2] := 1;
    if pos[1] < 1  then pos[1] := 21;
    if pos[2] < 1  then pos[2] := 21;
    if (pos[1] = evador[1]) and (pos[2] = evador[2])
     then failure := true;
    spot(pos[1],pos[2],'#');
   end
  else
   begin
    if (random(3) = 1) then
     begin
      if sb_level > 0 then
        BEGIN
          posn (4,3 + ((10 - sb_level) * 2));
          qio_write (' ');
        END;
      if (this_level > sb_level) then sb_level := sb_level + 1
      else if (sb_level > 1)     then sb_level := sb_level - 1;
      posn (4,3 + ((10 - sb_level) * 2));
      qio_write ('*');
      if (this_level = sb_level) then
       begin
        spot(pos[1],pos[2],'#');
        qio_write (VT100_bell);
       end;
     end;
   end;
 end; 
end; 


Procedure  Move(where:integer);
var  k :integer;
  temp :two;

begin
 temp := evador;
 case where of
  1 : begin
       temp[1] := temp[1]+1;
       temp[2] := temp[2]-1;
      end;
  2 : temp[1] := temp[1]+1;
  3 : begin
       temp[1] := temp[1]+1;
       temp[2] := temp[2]+1;
      end;
  4 : temp[2] := temp[2]-1;
  6 : temp[2] := temp[2]+1;
  7 : begin
       temp[1] := temp[1]-1;
       temp[2] := temp[2]-1;
      end;
  8 : temp[1] := temp[1]-1;
  9 : begin
       temp[1] := temp[1]-1;
       temp[2] := temp[2]+1;
      end;
  5 :
 end;
 if temp[1] > 21 then temp[1] := 1;
 if temp[1] < 1 then temp[1] := 21;
 if temp[2] > 21 then temp[2] := 1;
 if temp[2] < 1 then temp[2] := 21;
 spot(evador[1],evador[2],' '); 
 evador := temp;
end; 


Procedure  Move_evador;
var   k :integer;
Begin
 move(cmd);
 failure := ((evador[1] = hole_pos) and (evador[2] = hole_pos));
 k:=0;
 if not failure and (this_level >= 1) then
  repeat
   k := k+1;
   with level[this_level].bunny[k] do
    failure := (alive and (evador[1] = pos[1]) and (evador[2] = pos[2]))
              or ((evador[1] = super_bunny.pos[1])
               and (evador[2] = super_bunny.pos[2])
               and (super_bunny.sb_level = this_level));
  until (k=max_G_at[this_level]) or failure;
 if not failure then spot(evador[1],evador[2],'`')
                else boom;
end;  


Procedure  Get_Command;
begin
  case qio_1_char_now of
   '-','U','u' : begin
                  next_level_up;
                  cmd := 5;
                 end;
   ',','D','d' : begin
                 if this_level>0
                  then next_level_down(true)
                  else 
                  send_message(15,'  You   Can''t    go   Lower  Then   This  Sucker ');
                  cmd := 5;
                 end;
    '0','.': if this_level>0 then
              begin
               last_level := this_level;
               this_level := 0;
               plot_bunnies(last_level,' ');
               draw_level_value;
               plot_bunny_den('a');
               cmd := 5;
              end;
     '1'   : cmd := 1;
     '2'   : cmd := 2;
     '3'   : cmd := 3;
     '4'   : cmd := 4;
     '5'   : cmd := 5;
     '6'   : cmd := 6;
     '7'   : cmd := 7;
     '8'   : cmd := 8;
     '9'   : cmd := 9;
   'Q','q',
   'E','e' : begin
              exit:=true;
              cmd := 5;
             end;
   otherwise 
  end;
end; 


Procedure  All_to_do_with_Level;
var  k :integer;
begin
 if ((ev_speed > 11) and (random(60) = 2))
  then ev_speed := ev_speed - 1;
 if (this_level>=1) then
  with level[this_level] do
   begin
    case this_level of
     1,2,3   : limit:=3;
     4,5,6   : limit:=2;
     7,8,9,0 : limit:=1
    end;
    counter := (counter+1)MOD(limit);
    if counter=0 then
     begin
      any_bunnies := false;
      move_bunnies;
      for k := 1 to bunny_speed do
       move_super_bunny;
      if not failure then
       begin
        if not any_bunnies then next_level_up;
        if not next_level_found then
         begin
          send_message(4,'Nothing above, we''ll try the other   way.        ');
          next_level_down(false);
         end;
        if not next_level_found then success := true;
       end;
     end; 
   end 
 else 
  for k := 1 to 2 do
   if not failure then close_in_den;
end; 

Procedure  Draw_screen;
var k :integer;

 Procedure  Box(stx,sty,lx,ly :integer);
 begin
  spot(stx-1,sty-7,'l');
  for k := (stx+1) to (stx+lx) do spot(k-1,sty-7,'x');
  spot(stx+lx,sty-7,'m'); 
  for k := (sty+1) to (sty+ly) do spot(stx+lx,k-7,'q');
  spot(stx+lx,sty+ly-6,'j'); 
  for k := (stx+lx) downto (stx+1) do spot(k-1,sty+ly-6,'x');
  spot(stx-1,sty+ly-6,'k'); 
  for k := (sty+ly) downto (sty+1) do spot(stx-1,k-7,'q');
 end;

begin
 clear;
 for k := 1 to 23 do
 begin
  posn (1,k); qio_write (VT100_Wide);
 end;
 qio_write (VT100_graphics_on);
 box(1,7,21,21); box(3,31,7,7); box(14,31,7,7); box(4,1,18,3);
 posn(1,3); qio_write ('LEVEL');
 posn (31,2); qio_write ('ABOVE YOU');
 posn (31,13); qio_write ('BELOW YOU');
 spot(11,11,'a');
 plot_bunnies(this_level,'*');
 Draw_level_value;
 draw_next_level_up;
 draw_next_level_down;
end; 


Procedure  Initial_Move;
Begin
 qio_purge;
 evador[1] := 11; evador[2] := 11;
 while not(cmd in [1,2,3,4,6,7,8,9]) do
  cmd := (ord(qio_1_char)-ord('0'));
 Move(cmd);
 spot(11,11,'a');
 spot(evador[1],evador[2],'`');
End;  


Procedure  Carry_on_Game;
var  k :integer;
begin
 with super_bunny do spot(pos[1],pos[2],' ');
 spot(evador[1],evador[2],' '); 
 main_message(4,'    Well Done!   ');
 main_message(6,'You have cleared ');
 main_message(7,' all the levels  ');
 main_message(9,' You''ve just dug ');
 main_message(10,' another hole so ');
 main_message(11,'let''s see how you');
 main_message(13,' do this time....');
 main_message(17,' <press a key>   ');
 time_thru := time_thru + 1;
 if (time_thru > 2) then bunny_speed := bunny_speed + 1;
 for k:=1 to 9 do max_g_at[k] := max_g_at[k] + 1;
 assign_bunnies;
 cmd := 5;
 qio_purge;
 qio_1_char;
 main_message(4,'                 ');
 main_message(6,'                 ');
 main_message(7,'                 ');
 main_message(9,'                 ');
 main_message(10,'                 ');
 main_message(11,'                 ');
 main_message(13,'                 ');
 main_message(17,'                 ');
 plot_bunnies(this_level,'*');
 draw_level_value;
 draw_next_level_up;
 draw_next_level_down;
 next_level_found := true;
 success := false;
 Initial_Move;
end;


Procedure  write_result;
begin
 qio_write (VT100_graphics_off);
 clear;
 posn (5,13);
 if exit then qio_write ('Chicken.....');
 if failure then
  if this_level < 0
   then qio_write ('Gobbled up by the Great Bunny......')
   else
    if (score < 200)
     then qio_write ('Hopeless Bunny.....')
     else qio_write ('Smarter than your average Bunny.....');
 posn (3,18);qio_write ('Press a key to see how you rate' + VT100_esc + '[H');
 qio_purge;
 qio_1_char;
end;


BEGIN  
 image_dir;
 clear;
 posn (5,10);
 qio_write (VT100_Wide + 'Do you require instructions?' + VT100_esc + '[H');
 if (qio_1_char in ['Y','y']) then tell_story;
 initialise;
 Draw_screen;
 Initial_Move;
 Repeat
  sleep_start (ev_speed);
  Get_Command;
  Move_Evador;
  if not(exit or failure) then All_to_do_with_Level;
  if success then carry_on_game;
  sleep_wait;
 Until failure or exit;
 write_result;
 top_ten(score);
END.
