[ Inherit ('INTERACT') ]

Program  DRUNK_HUNT (ins_file);

const
  ubx = 22;
  uby = 30;
  max_shots = 5;
  max_drunks = 15;
  x_margin = 1;
  y_margin = 5;

type
  one_nine = 1..9;
  two = array[1..2] of integer;
  string_type = Varying[ 256 ] of char;
  player_type = Record
                  pos : two;
                  turn,
                  dir : integer;
                end;
  some_type = Record
                pos   : two;
                turn,
                dir   : integer;
                alive : boolean;
              end;

VAR 
 player   : player_type;
 gardiner : some_type;
 The_Park : array[0..ubx+1,0..uby+1] of char;
 drunk    : array[1..max_drunks] of some_type;
 shot     : array[1..max_shots] of some_type;
 ins_file : text;
 score_ch : packed array[0..3] of char;
 shot_speed, drunk_speed, gardiner_speed,
 drunk_freq, gardiner_freq,
 drunks_deployed, shot_limit, score,
 limit, counter, last_shot : integer;
 drunks_out, shots_fired, shot_just_fired,
 exit, failure : boolean;


Procedure  spot(x,y :integer; ch :char);
begin
 x := x + x_margin; y := y + y_margin;
 posn (y,x);
 qio_write (ch);
end;  {spot}


Procedure  assign_asterix;
var  k,l :integer;
begin
 for k := 1 to ubx do
  for l := 1 to ubx do
   The_Park[k,l] := ' ';
 for k := 1 to rnd(25,35) do
  case random(4) of
   1 : The_Park[rnd(2,8),random(uby)] := '*';
   2 : The_Park[rnd(2,ubx),rnd(14,uby)] := '*';
   3 : The_Park[rnd(14,ubx),random(ubx)] := '*';
   4 : The_Park[rnd(2,ubx),random(8)] := '*';
  end; 
end; { assign_asterix }


Procedure  tell_story;
var   len :integer;
    ins_line :varying [256] of char;

begin
 open(ins_file,'Image_dir:drunk.scn',history := readonly,error := continue);
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
   posn(5,5); qio_write(' Can''t find the  ');
   posn(5,7); qio_write('  instructions...');
   posn(5,9); qio_write('  It''s all up to ');
   posn(5,11); qio_write('     you now.    ');
   posn(5,15); qio_write('   Good Luck...  ');
  end;
 qio_1_char;
end;  { tell story }


Procedure  initialise;
var   l ,k : integer;
begin
 Image_dir;
 assign_asterix;
 with player do
  begin
   pos[1] := (ubx)div(2);
   pos[2] := (uby)div(2);
   dir := rnd(0,7);
   turn := 2;
  end;
 score := 0;
 for k := 0 to 3 do
  score_ch[k] := ' ';
 for k := 1 to max_drunks do
  drunk[k].alive := false;
 for k := 1 to max_shots do
  shot[k].alive := false;
 gardiner.alive := false;
 shot_limit := 1;
 shot_speed := 2;
 drunk_speed := 1;
 gardiner_speed := 1;
 drunks_deployed := 0;
 drunk_freq := 100;
 gardiner_freq := 250;
 shots_fired := false; drunks_out := false;
 limit := 1000; counter := 0;
 exit := false; failure := false;
end; {init}


Procedure  draw_new_score(added : integer);
var  k :integer;
Begin
 score := score + added;
 posn(1,1);
 for k := 0 to 3 do
  if not ( ( (((score)mod(10 ** (4-k)))div(10 ** (3-k))) = 0 )
             and (score_ch[k] = ' ') )
   then score_ch[k] := chr( (((score)mod(10 ** (4-k)))div(10 ** (3-k))) + 48 );
 qio_write (score_ch[0] + score_ch[1] + score_ch[2] + score_ch[3]);
End;  { draw_new_score }


Procedure  opposite(var what :integer);
Begin
 what := (what + 4)mod(8);
End;  { opposite }

Procedure  right(var what :integer);
Begin
 what := (what + 7)mod(8);
End;  { right }

Procedure  left(var what :integer);
Begin
 what := (what + 9)mod(8);
End;  { left }

Procedure  x_bounce(var this_dir :integer);
Begin
 this_dir := 6 - this_dir;
End;  { x_bounce }

Procedure  y_bounce(var this_dir :integer);
Begin
 this_dir := (10 - this_dir)mod(8);
End;  { y_bounce }

Procedure  rand_bounce(var this_dir :integer);
Begin
 this_dir := (this_dir + 10 + random(3))mod(8);
End;  { rand_bounce }

Function  in_bounds(this_pos :two):boolean;
Begin
 in_bounds := (this_pos[1] in [1..ubx]) and (this_pos[2] in [1..uby]);
End;  { in_bounds }

Function  equiv_pos(this_pos, that_pos :two):boolean;
Begin
 equiv_pos := (this_pos[1] = that_pos[1]) and (this_pos[2] = that_pos[2]);
End;  { equiv_pos }


Function  move(this_pos :two; this_dir :integer):two;
var  move_temp :two;
Begin
 move_temp := this_pos;
 case this_dir of
  0 : begin
       move_temp[1] := this_pos[1]+1;
       move_temp[2] := this_pos[2]-1;
      end;
  1 : move_temp[1] := this_pos[1]+1;
  2 : begin
       move_temp[1] := this_pos[1]+1;
       move_temp[2] := this_pos[2]+1;
      end;
  3 : move_temp[2] := this_pos[2]+1;
  4 : begin
       move_temp[1] := this_pos[1]-1;
       move_temp[2] := this_pos[2]+1;
      end;
  5 : move_temp[1] := this_pos[1]-1;
  6 : begin
       move_temp[1] := this_pos[1]-1;
       move_temp[2] := this_pos[2]-1;
      end;
  7 : move_temp[2] := this_pos[2]-1
 end;
 move := move_temp;
End;  { move }


Procedure  check_shot( shot_value :integer; var this_shot : some_type);
var  j :integer;

Begin
 with this_shot do
 case the_park[pos[1],pos[2]] of
  '%','`' : begin
             failure := true;
             alive := false;
            end;
    '#'   : begin
            j := 0;
             repeat
              j := j + 1;
             until equiv_pos(pos,drunk[j].pos) or (j = 15);
             drunk[j].alive := false;
             alive := false;
             spot(pos[1],pos[2],' ');
             the_park[pos[1],pos[2]] := ' ';
             draw_new_score(10);
             drunks_deployed := drunks_deployed - 1;
            end;
    '$'   : begin
             alive := false;
             gardiner.alive := false;
             spot(pos[1],pos[2],' ');
             the_park[pos[1],pos[2]] := ' ';
             draw_new_score(15);
            end;
    '.'   : begin
             j := 0;
             repeat
              j := j + 1;
              if shot[j].alive then
               if equiv_pos(pos,shot[j].pos) and (j <> shot_value) then
                begin
                 alive := false;
                 shot[j].alive := false;
                end;
             until  not alive or (j = 5);
             spot(pos[1],pos[2],' ');
             the_park[pos[1],pos[2]] := ' ';
            end;
    '*'   : begin
             draw_new_score(1);
             alive := false;
             spot(pos[1],pos[2],' ');
             the_park[pos[1],pos[2]] := ' ';
            end;
   otherwise
         shots_fired := true;
         spot(pos[1],pos[2],'.');
         the_park[pos[1],pos[2]] := '.'
 end; { case }
End;  { check_shot }


Procedure  start_shot(this_pos :two; this_dir :integer);
var  temp :two;
Begin
 with shot[last_shot] do
  begin
   dir := this_dir;
   alive := true;
   shot_just_fired := not shot_just_fired;
   if not shot_just_fired then
    begin
     the_park[pos[1],pos[2]] := ' ';
     spot(pos[1],pos[2],' ');
    end;
   temp := move(this_pos,this_dir);
   while not in_bounds(temp) do
    begin
     if not (temp[1] in [1..ubx]) then x_bounce(this_dir);
     if not (temp[2] in [1..uby]) then y_bounce(this_dir);
     temp := move(this_pos,this_dir);
    end;
   pos := temp;
   check_shot(last_shot, shot[last_shot]);
   if not alive then shot_just_fired := false;
  end; { with shot[last_shot] }
End;  { start_shot }


Procedure  move_player;
var  temp :two;

Begin
 with player do
  begin
   case turn of
    1 : left(dir);
    3 : right(dir);
    2 : if shot_just_fired then
         with shot[last_shot] do
           start_shot(pos,dir);
   end;
   temp := move(pos,dir);
   while not in_bounds(temp) do
    begin
     if not (temp[1] in [1..ubx]) then x_bounce(dir);
     if not (temp[2] in [1..uby]) then y_bounce(dir);
     temp := move(pos,dir);
    end;
   if The_Park[pos[1],pos[2]] in ['*','%'] then
    begin
     the_park[pos[1],pos[2]] := '*';
     spot(pos[1],pos[2],'*');
    end
   else
    begin
     the_park[pos[1],pos[2]] := ' ';
     spot(pos[1],pos[2],' '); 
    end;
   pos := temp;
   if The_Park[pos[1],pos[2]] = '*' then
    begin
     dir := rnd(0,7);
     The_park[pos[1],pos[2]] := '%';
    end
   else The_park[pos[1],pos[2]] := '`';
   spot(pos[1],pos[2],'`');
   posn (1,1);
  end; { with player }
End;  { player_move }


Procedure  initiate_gardiner;
var k :integer;
Begin
 with gardiner do
 begin
  turn := 2;
  alive := true;
  case random(4) of
   1 : begin
        pos[1] := 1;
        pos[2] := 1;
       end;
   2 : begin
        pos[1] := 1;
        pos[2] := uby;
       end;
   3 : begin
        pos[1] := ubx;
        pos[2] := 1;
       end;
   4 : begin
        pos[1] := ubx;
        pos[2] := uby;
       end
  end;  { case }
  dir := rnd(0,7);
  the_park[pos[1],pos[2]] := '$';
  spot(pos[1],pos[2],'$');
  qio_write(VT100_bell + VT100_bell);
 end;
End;  { initiate_gardiner }


Procedure  move_gardiner;
var  temp :two;
     loop_cntr : integer;

 Procedure  check_gardiner;
 Begin
  with gardiner do
  case the_park[pos[1],pos[2]] of
   '%','`' : begin
              failure := true;
              alive := false;
             end;
     '*'   : spot(pos[1],pos[2],'*');
     '$'   : begin
              spot(pos[1],pos[2],' ');
              the_park[pos[1],pos[2]] := ' ';
             end;
     '.'   : begin
              spot(pos[1],pos[2],'.');
              alive := false;
             end;
   otherwise
             spot(pos[1],pos[2],'$');
             the_park[pos[1],pos[2]] := '$'
  end; { case }
 End;  { check_gardiner }

Begin
 with gardiner do
  begin
   case random(30) of
    2,4,17  : turn := 1;
    5,13,18 : turn := 3;
    6,7,8,9 : The_park[pos[1],pos[2]] := '*';
    otherwise
            turn := 2
   end; { case }
   case turn of
    1 : left(dir);
    3 : right(dir);
    otherwise
   end;
   temp := move(pos,dir);
   loop_cntr := 0;
   while (loop_cntr < 5) and ((not in_bounds(temp))
            or (The_Park[temp[1],temp[2]] in ['*','$','#'])) do
    begin
     if not (temp[1] in [1..ubx]) then x_bounce(dir);
     if not (temp[2] in [1..uby]) then y_bounce(dir);
     temp := move(pos,dir);
     if in_bounds(temp) then
      if The_Park[temp[1],temp[2]] in ['*','$','#'] then
       begin
        rand_bounce(dir);
        temp := move(pos,dir);
       end;
     loop_cntr := loop_cntr + 1;
    end;
   if (loop_cntr < 5) then
    begin
     check_gardiner;
     pos := temp;
     check_gardiner;
    end;
   posn (1,1);
  end; { with gardiner }
End;  { move_gardiner }


Procedure  move_shots;
var
  j, k, l : integer;
  temp : two;

begin
 shots_fired := false;
 for k := 1 to max_shots do
 with shot[k] do
  begin
   for l := 1 to shot_speed do
   if alive then
    begin
     temp := move(pos,dir);
     while not in_bounds(temp) do
      begin
       if not (temp[1] in [1..ubx]) then x_bounce(dir);
       if not (temp[2] in [1..uby]) then y_bounce(dir);
       temp := move(pos,dir);
      end;
     check_shot(k,shot[k]);
     if alive then
      begin
       pos := temp;
       check_shot(k,shot[k]);
      end;
    end; { if alive }
   end; { with shot[k] }
End;  {shot_move}


Procedure  initiate_drunk;
var k :integer;
Begin
 k := 0;
 repeat
  k := k + 1;
  if not drunk[k].alive then
  with drunk[k] do
   begin
    alive := true;
    case random(4) of
     1 : begin
          pos[1] := 1;
          pos[2] := 1;
         end;
     2 : begin
          pos[1] := 1;
          pos[2] := uby;
         end;
     3 : begin
          pos[1] := ubx;
          pos[2] := 1;
         end;
     4 : begin
          pos[1] := ubx;
          pos[2] := uby;
         end
    end;  { case }
    dir := rnd(0,7);
    drunks_out := true;
    drunks_deployed := drunks_deployed - 1;
    spot(pos[1],pos[2],'#');
    the_park[pos[1],pos[2]] := '#';
    qio_write(VT100_bell);
   end;
 until (drunk[k].alive or (k = max_drunks)) ;
End;  { initiate_drunk }


Procedure  move_drunks;
var
  j, k, l,
  loop_cntr : integer;
  temp : two;

Begin
 drunks_out := false;
 for k := 1 to max_drunks do
 with drunk[k] do
  begin
   if alive and equiv_pos(pos,player.pos) then
    begin
     failure := true;
     alive := false;
    end;
   for l := 1 to drunk_speed do
   if alive and not failure then
    begin
     temp := move(pos,dir);
     loop_cntr := 0;
     while (loop_cntr < 5) and (not in_bounds(temp))
             or (The_Park[temp[1],temp[2]] = '*') do
      begin
       if not (temp[1] in [1..ubx]) then x_bounce(dir);
       if not (temp[2] in [1..uby]) then y_bounce(dir);
       if The_Park[temp[1],temp[2]] in ['*','$','#']
        then rand_bounce(dir);
       temp := move(pos,dir);
       loop_cntr := loop_cntr + 1;
      end;
     if (loop_cntr < 5) then
      begin
       spot(pos[1],pos[2],' ');
       the_park[pos[1],pos[2]] := ' ';
       pos := temp;
      end;
     case the_park[pos[1],pos[2]] of
      '%','`' : begin
                 failure := true;
                 alive := false;
                end;
        '.'   : begin
                 j := 0;
                 repeat
                  j := j + 1;
                 until  equiv_pos(pos,shot[j].pos) or (j = 5);
                 alive := false;
                 shot[j].alive := false;
                 spot(pos[1],pos[2],' ');
                 the_park[pos[1],pos[2]] := ' ';
                 draw_new_score(10);
                 drunks_deployed := drunks_deployed - 1;
                end;
       otherwise
              spot(pos[1],pos[2],'#');
              the_park[pos[1],pos[2]] := '#';
              drunks_out := true
     end; { case }
    end; { if alive }
  end; { with drunk }
end;  {move_drunk}


Procedure  plot_asterix;
var  k, j :integer;
begin
 for k := 1 to ubx do
  begin
   for j := 1 to uby do
    if (The_Park[k,j] = '*')
     then spot(k,j,'*');
  end;
end;  {plot_asterix}


Procedure  Draw_screen;
var k :integer;
begin
 clear;
 for k := x_margin to ubx+x_margin+1 do
 begin
   posn(1,k); 
   qio_write (VT100_wide);
 end;
 square (y_margin,x_margin,uby+y_margin+1,ubx+x_margin+1);
 qio_write(VT100_graphics_on);
 plot_asterix;
end; {Draw_screen}


Procedure  command_box;
Begin
 shot_just_fired := false;
 case qio_1_char_now of
    '1'   : player.turn := 1;
    '2'   : player.turn := 2;
    '3'   : player.turn := 3;
  '5',' ' : begin
             last_shot := 1;
             while (shot[last_shot].alive and (last_shot < shot_limit))
               do  last_shot := last_shot + 1;
             if not shot[last_shot].alive then
               begin
                shots_fired := true;
                start_shot(player.pos,player.dir);
               end;
             if (last_shot = shot_limit) then qio_purge;
            end;
  'Q','q' : exit := true;
  otherwise
 end; { case }
End;  { command_box }


Procedure  play_the_game;
var  k :integer;
Begin
 command_box;
 if not exit then
  begin
   move_player;
   for k := 1 to gardiner_speed do
    if gardiner.alive then move_gardiner
    else if (random(gardiner_freq) = 2)
          then initiate_gardiner;
   move_shots;
   if not failure then
    if drunks_out
     then move_drunks
     else initiate_drunk;
   if not failure then
    begin
     for k := 1 to drunk_speed do
      if (drunks_deployed < max_drunks) and (random(drunk_freq) = 2)
       then initiate_drunk;
     counter := (counter + 1)mod(limit);
     if (counter = 0) then
      begin
       if (limit > 50) then limit := limit - 20;
       if ((gardiner_speed)mod(2) = 1) and ((gardiner_freq)mod(2) = 1)
        then if (gardiner_freq > 20) then gardiner_freq := gardiner_freq - 5
        else
          begin
           if (gardiner_speed < 3) then gardiner_speed := gardiner_speed + 1
           else if (gardiner_freq > 20)
                 then gardiner_freq := gardiner_freq - 5;
          end;
       if ((drunk_speed)mod(2) = 1) and ((drunk_freq)mod(2) = 1)
        then if (drunk_freq > 15) then drunk_freq := drunk_freq - 5
        else
          begin
           if (drunk_speed < 3) then drunk_speed := drunk_speed + 1
           else if (drunk_freq > 15) then drunk_freq := drunk_freq - 5;
          end;
      end; { if count = 0 }
    end; { if not failure }
   if (random(50) = 2) and (shot_limit < 5)
    then shot_limit := shot_limit + 1;
   if score < 100 then player.turn := 2;
  end;
End;  { play_the_game }


Procedure  write_result;
Begin
 qio_write(VT100_graphics_off);
 clear;
 posn(5,10); qio_write('What hit you?');
 qio_purge;
 qio_1_char;
 top_ten(score);
End;  { write_result }


BEGIN  {mainline}
 Initialise;
 clear;
 posn(5,10);
 qio_write(VT100_wide + 'Do you require instructions?' + VT100_Esc + '[H');
 if (qio_1_char in ['Y','y']) then tell_story;
 Draw_screen;
 repeat
  sleep_start(20);
  PLAY_THE_GAME;
  sleep_wait;
 until exit or failure;
 write_result;
END. 
