var
	horse			: h_name;
	hstat,dist,area,lane	: h_stat;
	fastest,final_fastest   : h_stat;
	bets,true_bets		: h_stat;
	order,final_order	: h_stat;
	times			: array [0..21] of h_stat;
	true_sum_bets,sum_bets	: integer;
	horse_bet,num_horse,count : integer;
	horse_bet_type		: char;
	exit_flag		: boolean;
	odds,true_odds		: statr;


 
procedure display_commands;
begin
  display_gold;
  prt('You may:',20,1);
  prt(' p) place a bet                      v) view the program.',21,2);
  prt(' s) skip a race.                    ^R) Redraw the screen.',22,2);
  prt('^Z) Exit horseracing.',23,2);
end;
 
 
procedure display_track3;
begin
clear(1,1);
put_buffer('-- -- -- -- -- -- -- -- -- -- -- -- -- -- __ __',3,1);
put_buffer('-_',4,51);  put_buffer('-_',5,55);  put_buffer('-_',6,58);
put_buffer('-_',7,61);  put_buffer('-_',8,63);  put_buffer('-_',9,65);
put_buffer('-_',10,67); put_buffer('-_',11,69); put_buffer('_',12,71);
put_buffer('_',13,72);  put_buffer('_',14,73);  put_buffer('_',15,74);
put_buffer('_',16,75);  put_buffer('-- -- -- -- -- -- -- -- -- -- __ ',16,1);
put_buffer('-_',17,35); put_buffer('-_',18,38); put_buffer('-_',19,41);
put_buffer('-_',20,43); put_buffer('_',21,45);  put_buffer('_',22,46);
put_buffer('_',23,46);  put_buffer('_',17,76);  put_buffer('_',18,77);
put_buffer('_',19,77);  put_buffer('_',20,77);  put_buffer('_',21,77);
put_buffer('_',22,77);  put_buffer('_',23,77);
put_qio;
end;
 
 
procedure display_track2;
begin
clear(1,1);
put_buffer('_',2,46);   put_buffer('_',3,46);   put_buffer('_',4,45);
put_buffer('_-',5,43);  put_buffer('_-',6,41);  put_buffer('_-',7,38);
put_buffer('__',8,34);  put_buffer('_',2,77);   put_buffer('_',3,77);
put_buffer('_',4,77);   put_buffer('_',5,77);   put_buffer('_',6,77);
put_buffer('_',7,77);   put_buffer('_',8,77);   put_buffer('_',9,77);
put_buffer('__ __ __ __ __ __ __ __ __ __ --',9,1);
put_buffer('_',10,76);  put_buffer('_',11,75);  put_buffer('_',12,73);
put_buffer('_',13,71);  put_buffer('_-',14,69); put_buffer('_-',15,67);
put_buffer('_-',16,65); put_buffer('_-',17,63); put_buffer('_-',18,60);
put_buffer('_-',19,57); put_buffer('_-',20,53); put_buffer('_-',21,49);
put_buffer('__ __ __ __ __ __ __ __ __ __ __ __ __ -- -- --',22,1);
put_qio;
end;
 
 
procedure display_track4;
begin
clear(1,1);
put_buffer('__ __ -- -- -- -- -- -- -- -- -- -- -- -- -- -- --',3,29);
put_buffer('_-',4,25);  put_buffer('_-',5,22);  put_buffer('_-',6,19);
put_buffer('_-',7,17);  put_buffer('_-',8,15);  put_buffer('_-',9,13);
put_buffer('_-',10,11); put_buffer('_-',11,9);  put_buffer('_',12,8);
put_buffer('_',13,7);   put_buffer('_',14,6);   put_buffer('_',15,5);
put_buffer('_',16,4);   put_buffer('__ -- -- -- -- -- -- -- -- -- --',16,46);
put_buffer('_-',17,43); put_buffer('_-',18,40); put_buffer('_-',19,37);
put_buffer('_-',20,35); put_buffer('_',21,34);  put_buffer('_',22,33);
put_buffer('_',23,33);  put_buffer('_',17,3);   put_buffer('_',18,2);
put_buffer('_',19,2);   put_buffer('_',20,2);   put_buffer('_',21,2);
put_buffer('_',22,2);   put_buffer('_',23,2);
put_qio;
end;
 
procedure display_track5;
begin
clear(1,1);
put_buffer('_',2,3);    put_buffer('_',3,3);    put_buffer('_',4,3);
put_buffer('_',5,3);    put_buffer('_',6,3);    put_buffer('_',7,3);
put_buffer('_',8,3);    put_buffer('_',2,32);   put_buffer('_',3,32);
put_buffer('_',4,33);   put_buffer('-_',5,34);  put_buffer('-_',6,36);
put_buffer('-_',7,39);  put_buffer('__',8,43);  put_buffer('_',9,4);
put_buffer('-- __ __ __ __ __ __ __ __ __ __',9,46);
put_buffer('_',10,5);   put_buffer('_',11,6);   put_buffer('_',12,7);
put_buffer('_',13,8);   put_buffer('-_',14,9);  put_buffer('-_',15,11);
put_buffer('-_',16,13); put_buffer('-_',17,15); put_buffer('-_',18,18);
put_buffer('-_',19,21); put_buffer('-_',20,25); put_buffer('-_',21,29);
put_buffer('-- -- __ __ __ __ __ __ __ __ __ __ __ __ __',22,34);
put_qio;
end;
 
procedure display_track1;
begin
clear(1,1);
put_buffer('__ __ __ __ __ __ __ __ __ __ __ __ __ __ __ __ __ __ __',2,1);
put_buffer('__ __ __ __ __ __ __',2,58);
put_buffer('__ __ __ __ __ __ __ __ __ __ __ __ __ __ __ __ __ __ __',16,1);
put_buffer('__ __ __ __ __ __ __',16,58);
put_qio;
end;
 
 
procedure get_horse_stats;
  var
    i1,i2		: integer;
    horse_not_chosen 	: array[1..max_horse_names] of boolean;
begin
  num_horse := 5 + randint(4);
  for i1 := 1 to max_horse_names do
    horse_not_chosen[i1] := true;
  for i1 := 1 to num_horse do
    begin
      repeat
	i2 := randint(max_horse_names);
      until (horse_not_chosen[i2]);
      horse[i1] := horsename[i2];
      hstat[i1] := 2*horsestat[i2]-randint(2);
      horse_not_chosen[i2] := false;
    end;
  i2 := randint(250) + randint(250);
  sum_bets := 0;
  for i1 := 1 to num_horse do
    begin
     bets[i1]:= (hstat[i1]-20)**4 div i2;
     sum_bets := sum_bets + bets[i1];
    end;
  for i1 := 1 to num_horse do
    odds[i1] := 0.95*sum_bets/bets[i1] - 1.0;
  i1 := randint(num_horse);
  hstat[i1] := hstat[i1] + randint(2);
  i1 := randint(num_horse);
  hstat[i1] := hstat[i1] + randint(2);
  i1 := randint(num_horse);
  hstat[i1] := hstat[i1] - randint(5);
  true_sum_bets := 0;
  for i1 := 1 to num_horse do
    begin
      true_bets[i1] := (hstat[i1]-20)**4 div i2;
      true_sum_bets := true_sum_bets + true_bets[i1];
    end;
  for i1 := 1 to num_horse do
    true_odds[i1] := 0.95*true_sum_bets/true_bets[i1] - 1.0;
end;
 
 
function move(amount : real):integer;
begin
  move := 0;
  if (amount/10) >= 1 then move := 1;
  if (amount/100) >= 1 then move := 2;
  if (amount/1000) >= 1 then move := 3;
end;
 
 
(*  list horses + odds for the next race *)
procedure list_horses;
  var
    i1 : integer;
    command : char;
begin
  clear(2,1);
  for i1 := 1 to num_horse do
    begin
	prt('odds',3,36);
	writev(out_val,i1:2,'.   ',horse[i1]);
	prt(out_val,4+i1,3);
	if (odds[i1] < 0.2) then odds[i1] := 0.2;
	if (odds[i1] >= 4.75) then writev(out_val,trunc(odds[i1]+0.5):3)
	else if (odds[i1] < 0.90) then writev(out_val,trunc(5*odds[i1]+0.5):1,'/5')
	else if (trunc(odds[i1]*2+0.5) mod 2 = 0) then
	  writev(out_val,trunc(odds[i1]+0.25):3)
	else writev(out_val,trunc(odds[i1]*2+0.5):1,'/2');
      prt(out_val,4+i1,37);
    end;
 if bet = 0 then begin
    prt('[hit any key to continue]',23,24);
    get_com('',command);
    clear(2,1);
    display_commands;
  end
end;


procedure print_positions(row,col : integer);
  var
    i1 : integer;
  begin
    for i1 := 1 to 4 do
      begin
	if (horse_bet=fastest[i1]) then
	  put_buffer('-->',row-1+i1,col)
	else
	  put_buffer('   ',row-1+i1,col);
	  writev(out_val,fastest[i1]:1,'  ',horse[fastest[i1]]);
        put_buffer(out_val,row-1+i1,col+3);
      end;
  end;

(* row is the dependant variable,  column depends on horse stats  *)
procedure start;
  var
    i1,i2,row,col	: integer;
    exit_flag		: boolean;
    count		: integer;
    win_count,new_win_count : integer;
    which_screen,screen_low,screen_high : integer;
    still_racing	: h_bool;
    adjust		: integer;
    command		: char;
    

  procedure start_race;
    var i1  : integer;
    begin
      for i1 := 1 to num_horse do
	begin
	  writev(out_val,i1:1);
	  put_buffer(out_val,i1+3,2);
	end;
      msg_print('The horses are now entering the starting gate...');
      msg_print('And they''re off!!');
      for i1 := 1 to num_horse do
	put_buffer('  ',3+i1,2);
    end;

  procedure get_positions;
    var i1,i2,t  : integer;
    begin
      for i1 := win_count+1 to num_horse-1 do
	for i2 := num_horse-1 downto i1 do
	  if (dist[fastest[i2]] < dist[fastest[i2+1]]) then
	    begin
	      t := fastest[i2];
	      fastest[i2] := fastest[i2+1];
	      fastest[i2+1] := t;
	  end;
      for i1 := win_count+1 to num_horse do
	order[fastest[i1]] := i1;
    end;

 
  function find_plot(horse : integer; var row,col : integer) : boolean;
    var t : integer;
    begin
      find_plot := false;
      t := dist[horse];
      if ((t >= screen_low) and (t <= screen_high)) then
	begin
	  find_plot := true;
	  if (t <= 730) then row := 3+(horse*(750-t)+(lane[horse]*t) div 2) div 730
	  else if (t > 3770) then row := 8+lane[horse]
	  else if ((t <= 1090) or (t > 3410)) then row := 11+lane[horse] div 2
	  else if (t <= 1310) then row := 3+trunc(cos((t-1090)/140)*(120+10*lane[horse])/15)
	  else if (t <= 1530) then row := 23+trunc(cos((t-1090)/140)*(120+10*lane[horse])/15)
	  else if (t <= 2970) then row := 14-lane[horse] div 2
	  else if (t <= 3190) then row := 23-trunc(cos((t-2970)/140)*(120+10*lane[horse])/15)
	  else row := 3 - trunc(cos((t-2970)/140)*(120+10*lane[horse])/15);
	  if (t <= 730) then col := 1 + t div 10
	  else if (t <= 1090) then col := t div 10 - 72
	  else if (t <= 1530) then col := 37+trunc(sin((t-1090)/140)*(120+lane[horse]*10)/10)
	  else if (t <= 1890) then col := 190 - t div 10
	  else if (t <= 2610) then col := 262 - t div 10
	  else if (t <= 2970) then col := 338 - t div 10
	  else if (t <= 3410) then col := 41-trunc(sin((t-2980)/140)*(120+lane[horse]*10)/10)
	  else if (t <= 3770) then col := t div 10 - 300
	  else col := (t - 3761) div 10;
	end;
    end;

  procedure predict_order;
    var i1,i2,sum,t : integer;
	temp	: h_stat;
    begin
      for i2 := 1 to num_horse do
	final_order[i2] := 0;
      for i1 := 1 to num_horse do
	begin
	  sum := 0;
	  for i2 := 1 to num_horse do
	    begin	{find chance of horse finishing in place i1}
	      if (final_order[i2] = 0) then 
		sum := sum + trunc(10000*i1*true_odds[i2] /
		  ((i1*(i1+1)+2*true_odds[i2])*(i1*(i1-1)+2*true_odds[i2])));
	      temp[i2] := sum;
	    end;
	  t := randint(sum);
	  i2 := 0;
	  repeat
	    i2 := i2 + 1;
	  until (t <= temp[i2]);
	  final_order[i2] := i1;
	  final_fastest[i1] := i2;
	end;
    end;

  procedure predict_race;
    var
	t,t2,try_speedy,speedy,old_speedy,i1,i2,seg,pokey : integer;
    begin
      old_speedy := 99999;
      for i1 := 1 to num_horse do
       begin
	i2 := 0;
	t := final_fastest[i1];
	t2 := hstat[t]*hstat[t];
	speedy := 0;
	for i2 := 1 to 6 do
	  begin
	    try_speedy := (randint(t2)+randint(t2)+randint(t2)) div 100
				+2*(num_horse-i1+1);
	    if ((try_speedy > speedy) and (try_speedy < old_speedy)) then
	       speedy := try_speedy;
	  end;
	if (speedy = 0) then
	  speedy := old_speedy - randint(3) + 1;
	old_speedy := speedy;
{ horse run time = 6000 - 2*speedy; times[1..20] is time for each segment }
	times[0,t] := 0;
	for i2 := 1 to 20 do
	  times[i2,t] := 31 - speedy div 10; {time to move distance x}
	pokey := randint(randint(6));
 	speedy := speedy mod 10 + 10 + pokey*2;
	for i2 := 1 to pokey do
	  begin	{slowdown near end of race}
	    seg := 21 - randint(randint(4));
	    times[seg,t] := times[seg,t]+4;
	  end;
	for i2 := 1 to speedy do
	  begin
	    if (randint(2)=1) then
		seg := randint(20)
	    else
		seg := (13+randint(5)+randint(5)) mod 20 + 1;
	    times[seg,t] := times[seg,t]-2;
	  end;
	for i2 := 1 to 20 do	{make moves cumulative}
	  times[i2,t] := times[i2-1,t] + times[i2,t];
	times[21,t] := times[20,t] + 40;
      end;
    end;
	  
  begin
    which_screen := 1;
    screen_high := 0;
    count := 0;
    win_count := 0;
    new_win_count := 0;
    predict_order;
    predict_race;
    for i1 := 1 to num_horse do
      begin
	fastest[i1] := i1;
	area[i1] := 0;
	still_racing[i1] := true;
      end;
    for which_screen := 1 to 7 do
      begin
	screen_low := screen_high + 1;
	get_positions;
	case which_screen of
	  1 : begin
		display_track1;
		start_race;
		screen_high := 730;
	      end;
	  2 : begin
		display_track2;
		print_positions(3,3);
		screen_high := 1310;
	      end;
	  3 : begin
		display_track3;
		print_positions(18,3);
		screen_high := 1890;
	      end;
	  4 : begin
		screen_high := 2610;
		display_track1;
		print_positions(18,30);
	      end;
	  5 : begin
		display_track4;
		print_positions(18,55);
		screen_high := 3190;
	      end;
	  6 : begin
		display_track5;
		print_positions(3,55);
		screen_high := 3770;
	      end;
	  7 : begin
		display_track1;
		print_positions(18,30);
		screen_high := 4549; {but race stops at 4400}
		for i1 := 3 to 15 do
		  put_buffer('|',i1,63);
	      end;
	end;
	for i1 := 1 to num_horse do
	  case (order[i1] mod 4) of
	    0 : lane[i1] := 2;
	    1 : lane[i1] := 1;
	    2 : lane[i1] := 3;
	    3 : lane[i1] := 0;
	  end;
	exit_flag := false;
	repeat
	  count := count + 2;
	  for i1 := 1 to num_horse do
	    begin
	      if find_plot(i1,row,col) then
		put_buffer(' ',row,col);
	      if ((count > times[area[i1],i1]) and (area[i1] < 21)) then
		area[i1] := area[i1] + 1;		  
	      dist[i1] := 220*area[i1]-((times[area[i1],i1] - count)*220) div
			(times[area[i1],i1]-times[area[i1]-1,i1]) + randint(2);
	      if find_plot(i1,row,col) then
		if (i1 = horse_bet) then
		  put_buffer('*',row,col)
		else
		  begin
		    writev(out_val,i1:1);
		    put_buffer(out_val,row,col);
		  end;
	      if (which_screen < 7) then
		begin
		  if (dist[i1] > screen_high) then
		    exit_flag := true;
		end
	      else
		if ((dist[i1] > 4400) and still_racing[i1]) then
		  begin
		    new_win_count := new_win_count + 1;
		    still_racing[i1] := false;
		    put_buffer('|',row,63);
		  end;
	    end;
	  if (which_screen = 7) then
	    if (new_win_count > win_count) then
	      begin
		get_positions;
		win_count := new_win_count;
		exit_flag := (win_count >= 4);
	      end;
	until (exit_flag);
      end;
    for i1 := 1 to num_horse do
      begin
	order[i1] := final_order[i1];
	fastest[i1] := final_fastest[i1];
      end;
    get_com('',command);
    clear(1,1);
  end;
 
(*  displays the amount paid per $2 bet  *)
procedure display_winnings;
  var
    command : char;
    win1,win2,win3,show3,place2,place3,earnings : real;
  begin
	win1 := odds[fastest[1]]*2 + 2;
	win2 := odds[fastest[1]]/1.5 + 2;
	if win2 < 2.20 then win2 := 2.20;
	win3 := odds[fastest[1]]/3 + 2;
	if win3 < 2.20 then win3 := 2.20;
	place2 := odds[fastest[2]]/1.5 + 2;
	if place2 < 2.20 then place2 := 2.20;
	place3 := odds[fastest[2]]/3 + 2;
	if place3 < 2.20 then place3 := 2.20;
	show3  := odds[fastest[3]]/3 + 2;
	if show3 < 2.20 then show3 := 2.20;
	earnings := 0;
	if (horse_bet=fastest[1]) then
	  case (horse_bet_type) of
	    'w' : earnings := win1;
	    'p' : earnings := win2;
	    's' : earnings := win3;
	    otherwise ;
	  end
	else if ((horse_bet=fastest[2]) and (horse_bet_type='p')) then
	  earnings := place2
	else if ((horse_bet=fastest[2]) and (horse_bet_type='s')) then
	  earnings := place3
	else if ((horse_bet=fastest[3]) and (horse_bet_type='s')) then
	  earnings := show3;
	gld := gld + trunc(earnings*bet/2);
	if (earnings > 0) then
	  case randint(2) of
	    1 : msg_print('you won.');
	    2 : msg_print('your horse came in.');
	  end
	else msg_print('no luck this time.');
	clear(2,1);
	print_positions(10,1);
	writev(out_val,win1:8:2);
	put_buffer(out_val,10,42);
	writev(out_val,win2:8:2);
	put_buffer(out_val,10,53);
	writev(out_val,win3:8:2);
	put_buffer(out_val,10,64);
	writev(out_val,place2:8:2);
	put_buffer(out_val,11,53);
	writev(out_val,place3:8:2);
	put_buffer(out_val,11,64);
	writev(out_val,show3:8:2);
	put_buffer(out_val,12,64);
	prt('[hit any key to continue]',23,24);
	get_com('',command);
	clear(1,1);
    end;


function get_race_bet : boolean;
  var
    comment      : vtype;
    i1          : integer;
    exit_flag    : boolean;
    horse_flag   : boolean;

  function get_bet_type : boolean;
    var
      command    : char;
      exit_flag  : boolean;
    begin
      get_bet_type := true;
      exit_flag := false;
      repeat
	msg_print('What kind of bet? (<w>in, <p>lace, or <s>how) ');
	if get_com('',command) then
	  case ord(command) of
            119,112,115 : begin
		  horse_bet_type := command;
		  exit_flag := true;
		end;
	  end
	else
	  begin
	    get_bet_type := false;
	    exit_flag := true;
	  end;
      until (exit_flag)
    end;
 
 
  function get_bet_horse : boolean;
    var
      exit_flag : boolean;
      comment   : vtype;
      i1	: integer;
    begin
      get_bet_horse := true;
      exit_flag := false;
      list_horses;
      repeat
	comment := 'Which horse do you want to bet on?';
	if get_response(comment,i1) then
	  exit_flag := (i1>0) and (i1<num_horse + 1)
	else
	  begin
	    exit_flag := true;
	    get_bet_horse := false;
	  end;
      until(exit_flag);
      horse_bet := i1;
      clear(1,1);
      display_commands;
    end;

  begin
      exit_flag := false;
      get_race_bet := false;
      bet := 0;
      comment := 'How much would you like to bet (2 to 1000 gp)? ';
      repeat
      if get_response(comment, bet) then
        if (bet>1) and (bet<1001) then exit_flag := true
        else prt('Improper value.',1,1)
     else
      begin
         exit_flag := true;
         bet := 0
      end;
  until (exit_flag);
  if (bet > gld) then
     begin
       prt('You have not the gold!',1,1);
       bet := 0;
     end;
  if (bet > 0) then
    if get_bet_horse then
      if get_bet_type then
	begin
	  get_race_bet := true;
	  gld := gld - bet;
	  bets[horse_bet] := bets[horse_bet] + bet;
	  sum_bets := sum_bets + bet;
	  for i1 := 1 to num_horse do
	    odds[i1] := sum_bets*0.9/bets[i1] - 1;
	end;	  
end;
 
 
function get_horse_command : boolean;
  var
    command     : char;
begin
  get_horse_command := false;
  if get_com('', command) then
     begin
       case (ord(command))  of
           112   : get_horse_command := get_race_bet;
  (*^R*)   18   :   begin
                       clear(1,1);
                       display_commands;
                    end;
           118  :  list_horses;
           115  :  begin
                     get_horse_stats;
                     msg_print('You skip a race.');
		     spend_time(4800 div races_per_day,'at the track',false);
                   end;
         otherwise prt('Invalid Command.',1,1);
       end
     end
  else exit_flag  := true;
end;
 
 
procedure game_horse;
  var
   n,i1		: integer;
   command	: char;
begin
clear(1,1);
exit_flag := false;
      case (randint(4)) of
        1,2,3: prt('It is a beautiful day at the track.',1,1);
        4    : prt('It is pouring down rain and the track is muddy.',1,1);
      end;
display_commands;
get_horse_stats;
repeat
      display_gold;
      if get_horse_command then
        begin
          start;
	  display_winnings;
	  spend_time(4800 div races_per_day,'at the track',false);
	  display_commands;
	  display_gold;
	  get_horse_stats;
        end;
      check_casino_kickout;
      with py.misc.cur_age do
	if ((py.misc.cur_age.day mod 7) in [2..7]) and
	   (hour >= 6) and (hour < 18) then
	  begin
	    closed := true;
	    exit_flag := true;
	    msg_print('There are no more races today...Come back tomorrow.');
	    msg_print(' ');
	  end;
until(exit_flag)
end;
