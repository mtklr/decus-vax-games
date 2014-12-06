[Inherit('Moria.Env')] Module Misc;

	{ Use date and time to produce random seed		-RAK-	}
[global,psect(setup$code)] function get_seed : unsigned;
    type
	$quad = [quad,unsafe] record
		l0	: unsigned;
		l1	: unsigned;
	end;
    var
	time		: $quad;
	seed_val	: unsigned;

    [asynchronous,external (SYS$GETTIM)] function get_time(
		var time : $quad) : integer;
		external;

    begin
      get_time(time);				{ Current time	}
      seed_val := uor(time.l0,time.l1);		{ Random number }
      get_seed := uor(seed_val,%X'00000001');	{ Odd number	}
    end;


	{ Returns the day number; 1=Sunday...7=Saturday		-RAK-	}
[global,psect(setup$code)] function day_num : integer;
    var
	i1		: integer;
    [external(LIB$DAY)] function day(
	var daynum		: integer;
	dum1			: integer := %immed 0;
	dum2			: integer := %immed 0) : integer;
	external;
    begin
      day(i1);
      day_num := ((i1+3) mod 7) + 1;
    end;


	{ Returns the hour number; 0=midnight...23=11 PM	-RAK-	}
[global,psect(setup$code)] function hour_num : integer;
    var
	hour		: integer;
	time_str	: packed array [1..11] of char;
    begin
      time(time_str);
      readv(substr(time_str,1,2),hour,error:=continue);
      hour_num := hour;
    end;


	{ Set up the variables that depend upon the difficulty of
	  game chosen.						-DMF-	}
[global,psect(setup$code)] procedure set_difficulty(diff : integer);
    begin
      case diff of
	1 : begin				{ Brain-dead	}
		dun_str_mc	:= 75;
		dun_str_qc	:= 30;
		dun_unusual	:= 250;
		obj_great	:= 50;
		treas_room_alloc:= 3;
		treas_any_alloc	:= 1;
		treas_gold_alloc:= 4;
		obj_std_adj	:= 0.9;
		obj_std_min	:= 3;
		obj_town_level	:= 5;
		obj_base_magic	:= 6;
		obj_base_max	:= 70;
		obj_div_special	:= 20;
		obj_div_cursed	:= 1.2;
		mon_nasty	:= 150;
		mon_mult_adj	:= 15;
	    end;
	2 : begin				{ Easy		}
		dun_str_mc	:= 85;
		dun_str_qc	:= 45;
		dun_unusual	:= 175;
		obj_great	:= 42;
		treas_room_alloc:= 5;
		treas_any_alloc	:= 1;
		treas_gold_alloc:= 3;
		treas_gold_alloc:= 3;
		obj_std_adj	:= 1.05;
		obj_std_min	:= 5;
		obj_town_level	:= 6;	
		obj_base_magic	:= 9;
		obj_base_max	:= 85;
		obj_div_special	:= 15;
		obj_div_cursed	:= 1.2;
		mon_nasty	:= 100;
		mon_mult_adj	:= 10;
	    end;
	3 : begin				{ Normal	}
		dun_str_mc	:= 95;
		dun_str_qc	:= 55;
		dun_unusual	:= 100;
		obj_great	:= 30;
		treas_room_alloc:= 7;
		treas_any_alloc	:= 2;
		treas_gold_alloc:= 2;
		obj_std_adj	:= 1.25;
		obj_std_min	:= 7;
		obj_town_level	:= 7;
		obj_base_magic	:= 12;
		obj_base_max	:= 100;
		obj_div_special	:= 11;
		obj_div_cursed	:= 1.2;
		mon_nasty	:= 50;
		mon_mult_adj	:= 7;
	    end;
	4 : begin				{ Hard		}
		dun_str_mc	:= 97;
		dun_str_qc	:= 75;
		dun_unusual	:= 60;
		obj_great	:= 24;
		treas_room_alloc:= 12;
		treas_any_alloc	:= 3;
		treas_gold_alloc:= 2;
		obj_std_adj	:= 1.5;
		obj_std_min	:= 10;
		obj_town_level	:= 10;
		obj_base_magic	:= 15;
		obj_base_max	:= 115;
		obj_div_special	:= 8;
		obj_div_cursed	:= 1.2;
		mon_nasty	:= 20;
		mon_mult_adj	:= 5;
	    end;
	5 : begin				{ Ultra-hard	}
		dun_str_mc	:= 99;
		dun_str_qc	:= 85;
		dun_unusual	:= 30;
		obj_great	:= 15;
		treas_room_alloc:= 15;
		treas_any_alloc	:= 4;
		treas_gold_alloc:= 1;
		obj_std_adj	:= 2.0;
		obj_std_min	:= 15;
		obj_town_level	:= 15;
		obj_base_magic	:= 18;
		obj_base_max	:= 130;
		obj_div_special	:= 6;
		obj_div_cursed	:= 1.2;
		mon_nasty	:= 5;
		mon_mult_adj	:= 3;
	    end;
	end;
    end;


	{ Center a string inside of a field			-DMF-	}
[global,psect(misc4$code)] function center(str : string; len : integer) : string;
	var
		i1,i2,i3	: integer;
	begin
	  if (length(str) > 0) and ((str[1] = ' ') or
				    (str[length(str)] = ' ')) then
	    begin
	      i1 := 1;
	      i2 := length(str);
	      i3 := i2;
	      while (str[i1] = ' ') do
		begin
		  i1 := i1 + 1;
		  i3 := i3 - 1;
		end;
	      while (str[i2] = ' ') do
		begin
		  i2 := i2 - 1;
		  i3 := i3 - 1;
		end;
	      str := substr(str,i1,i3);
	    end;
	  i1 := length(str);
	  for i2 := 1 to (len-i1) div 2 do
	    str := ' ' + str;
	  center := pad(str,' ',len);
	end;


	{ Check to see if everyone should be kicke out of the game,	}
	{ by attempting to open the kick-out file.		-DMF-	}
[global,psect(setup$code)] function check_kickout : boolean;
    var
	kick	: text;
    begin
      open(kick,file_name:=moria_lck,history:=old,sharing:=readonly,
	      error:=continue);
      if (status(kick) = 0) then
	check_kickout := true
      else
	check_kickout := false;
    end;


	{ Check the day-time strings to see if open		-RAK-	}
[global,psect(setup$code)] function check_time : boolean;
    begin
      case days[day_num,(hour_num+5)] of
	'.'  :	check_time := false;	{ Closed		}
	'X'  :	check_time := true;	{ Normal hours		}
	otherwise check_time := false;	{ Other, assumed closed }
      end;
    end;


	{ Generates a random integer number of NORMAL distribution -RAK-}
[global,psect(misc1$code)] function randnor(mean,stand : integer) : integer;
    begin
      randnor :=  trunc(sqrt(-2.0*ln(randint(9999999)/10000000.0))*
		  cos(6.283*(randint(9999999)/10000000.0))*stand) + mean;
    end;


	{ Checks a co-ordinate for in bounds status		-RAK-	}
[global,psect(misc1$code)] function in_bounds(y,x : integer) : boolean;
    begin
      if ((y > 1) and (y < cur_height) and
	  (x > 1) and (x < cur_width)) then
	in_bounds := true
      else
	in_bounds := false;
    end;


	{ Checks points north, south, east, and west for a type -RAK-	}
[global,psect(misc1$code)] function next_to4   (
			y,x		:	integer;
			group_set	: obj_set
					) : integer;
    var
	i1	: integer;
    begin
      i1 := 0;
      if (y > 1) then
	if (cave[y-1,x].fval in group_set) then
	  i1 := i1 + 1;
      if (y < cur_height) then
	if (cave[y+1,x].fval in group_set) then
	  i1 := i1 + 1;
      if (x > 1) then
	if (cave[y,x-1].fval in group_set) then
	  i1 := i1 + 1;
      if (x < cur_width) then
	if (cave[y,x+1].fval in group_set) then
	  i1 := i1 + 1;
      next_to4 := i1
    end;


	{ Checks all adjacent spots for elements		-RAK-	}
[global,psect(misc1$code)] function next_to8   (
			y,x		:	integer;
			group_set	:	obj_set
					) : integer;
    var
	i1,i2,i3	: integer;
    begin
      i1 := 0;
      for i2 := (y - 1) to (y + 1) do
	for i3 := (x - 1) to (x + 1) do
	  if (in_bounds(i2,i3)) then
	    if (cave[i2,i3].fval in group_set) then
	      i1 := i1 + 1;
      next_to8 := i1
    end;


[global,psect(misc1$code)] function rotate_dir(dir,rot : integer) : integer;
    begin
      if (dir = 5) then
	rotate_dir := 5
      else
	rotate_dir := key_of[(oct_of[dir] + rot) mod 8]
    end;

	{ Returns hexdecant of dy,dx			}
	{ 0,1 = ea 2,3 = ne, 4,5 = n ... 14,15 = se	}
[global,psect(misc1$code)] function get_hexdecant(dy,dx : integer) : bytlint;
    var
	ay,ax		: integer;
	hexdecant	: bytlint;
    begin
	ay := abs(dy); ax := abs(dx);
	if (ay*2.41421 < ax) then hexdecant := 1
	else if (ay < ax) then hexdecant := 2
	else if (ay/2.41421 < ax) then hexdecant := 3
	else hexdecant := 4;
	if (dx < 0) then hexdecant := 9 - hexdecant;
	if (dy > 0) then get_hexdecant := (17 - hexdecant) mod 16
	else get_hexdecant := hexdecant;
    end;


	{ Link all free space in treasure list together			}
[global,psect(generate$code)] procedure tlink;
      var
	i1		: integer;
      begin
	for i1 := 1 to max_talloc do
	  begin
	    t_list[i1] := blank_treasure;
	    t_list[i1].p1 := i1 - 1;
	  end;
	tcptr := max_talloc;
      end;


	{ Link all free space in monster list together			}
[global,psect(generate$code)] procedure mlink;
      var
	i1		: integer;
      begin
	for i1 := 1 to max_malloc do
	  begin
	    m_list[i1] := blank_monster;
	    m_list[i1].nptr := i1 - 1;
	  end;
	m_list[2].nptr := 0;
	muptr := 0;
	mfptr := max_malloc;
      end;


	{ Initializes M_LEVEL array for use with PLACE_MONSTER	-RAK-	}
[global,psect(setup$code)] procedure init_m_level;
    var
	i1,i2,i3		: integer;
    begin
      i1 := 1;
      i2 := 0;
      i3 := max_creatures - win_mon_tot;
      repeat
	m_level[i2] := 0;
	while ((i1 <= i3) and (c_list[i1].level = i2)) do
	  begin
	    m_level[i2] := m_level[i2] + 1;
	    i1 := i1 + 1;
	  end;
	i2 := i2 + 1;
      until (i2 > max_mons_level);
      for i1 := 2 to max_mons_level do
	m_level[i1] := m_level[i1] + m_level[i1-1];
    end;


	{ Initializes T_LEVEL array for use with PLACE_OBJECT	-RAK-	}
[global,psect(setup$code)] procedure init_t_level;
    var
	i1,i2			: integer;
    begin
      i1 := 1;
      i2 := 0;
      repeat
	while ((i1 <= max_objects) and (object_list[i1].level = i2)) do
	  begin
	    t_level[i2] := t_level[i2] + 1;
	    i1 := i1 + 1;
	  end;
	i2 := i2 + 1;
      until ((i2 > max_obj_level) or (i1 > max_objects));
      for i1 := 1 to max_obj_level do
	t_level[i1] := t_level[i1] + t_level[i1-1];
    end;


	{ Adjust prices of objects				-RAK-	}
[global,psect(setup$code)] procedure price_adjust;
    var
	i1			: integer;
    begin
      for i1 := 1 to max_objects do
	with object_list[i1] do
	  cost := trunc(cost*cost_adj + 0.99);
      for i1 := 1 to inven_init_max do
	with inventory_init[i1] do
	  cost := trunc(cost*cost_adj + 0.99);
    end;


	{ Adjust weights of objects				-DMF-	}
[global,psect(setup$code)] procedure item_weight_adjust;
    var
	i1			: integer;
    begin
      for i1 := 1 to max_objects do
	with object_list[i1] do
	  weight := weight * weight_adj;
      for i1 := 1 to inven_init_max do
	with inventory_init[i1] do
	  weight := weight * weight_adj;
    end;


	{ Converts input string into a dice roll		-RAK-	}
	{	Normal input string will look like '2d6', '3d8'... ect. }
[global,psect(misc1$code)] function damroll(dice : dtype) : integer;
    var
	i1,num,sides			: integer;
    begin
      for i1 := 1 to length(dice) do
	if (dice[i1] = 'd') then
	  dice[i1] := ' ';
      num := 0;
      sides := 0;
      readv(dice,num,sides,error:=continue);
      damroll := rand_rep(num,sides);
    end;


	{ Returns true if no obstructions between two given points -RAK-}
[global,psect(misc1$code)] function los(y1,x1,y2,x2 : integer) : boolean;
    var
	ty,tx,stepy,stepx,p1,p2		: integer;
	slp,tmp				: real;
	flag				: boolean;
    begin
      ty := (y1 - y2);
      tx := (x1 - x2);
      flag := true;
      if ((ty <> 0) or (tx <> 0)) then
	begin
	  if (ty < 0) then
	    stepy := -1
		  else
	    stepy := 1;
	  if (tx < 0) then
	    stepx := -1
	  else
	    stepx := 1;
	  if (ty = 0) then
	    repeat
	      x2 := x2 + stepx;
	      flag := cave[y2,x2].fopen;
	    until((x1 = x2) or (not (flag)))
	  else if (tx = 0) then
	    repeat
	      y2 := y2 + stepy;
	      flag := cave[y2,x2].fopen;
	    until((y1 = y2) or (not (flag)))
	  else if (abs(ty) > abs(tx)) then
	    begin
	      slp := abs(tx/ty)*stepx;
	      tmp := x2;
	      repeat
		y2 := y2 + stepy;
		tmp := tmp + slp;
		p1 := round(tmp - 0.1);
		p2 := round(tmp + 0.1);
		if (not ((cave[y2,p1].fopen) or (cave[y2,p2].fopen))) then
		  flag := false;
	      until((y1 = y2) or (not (flag)))
	    end
	  else
	    begin
	      slp := abs(ty/tx)*stepy;
	      tmp := y2;
	      repeat
		x2 := x2 + stepx;
		tmp := tmp + slp;
		p1 := round(tmp - 0.1);
		p2 := round(tmp + 0.1);
		if (not ((cave[p1,x2].fopen) or (cave[p2,x2].fopen))) then
		  flag := false;
	      until((x1 = x2) or (not (flag)))
	    end;
	end;
      los := flag;
    end;


	{ Returns symbol for given row, column			-RAK-	}
[global,psect(misc5$code)] procedure loc_symbol(y,x : integer; var sym : char);
    begin
      with cave[y,x] do
	if ((cptr = 1) and (not(find_flag))) then
	  sym := '@'
	else if (py.flags.blind > 0) then
	  sym := ' '
	else
	  begin
	    if (cptr > 1) then
	      begin
		with m_list[cptr] do
		  if ((ml) and
(not(fval in water_set) or ((fval in water_set) and
			     ((uand(c_list[mptr].cmove,%X'00800000') <> 0) or
			     (distance(char_row,char_col,y,x) <=
				5)))) and
		      ((uand(c_list[mptr].cmove,%X'00010000') = 0) or
		       (py.flags.see_inv))) then
		    sym := c_list[mptr].cchar
		  else if (tptr > 0) then
		    sym := t_list[tptr].tchar
		  else if (fval < 10) then
		    sym := '.'
		  else if (fval < 16) then
		    sym := '#'
		  else
		    sym := '`';
	      end
	    else if (tptr > 0) then
	      if (fval in water_set) then
		if (t_list[tptr].tval in float_set) or
		   ((distance(char_row,char_col,y,x) <= 5) and
		    (los(char_row,char_col,y,x))) then
		  sym := t_list[tptr].tchar
		else
		  sym := '`'
	      else
		sym := t_list[tptr].tchar
	    else if (fval < 10) then
	      sym := '.'
	    else if (fval < 16) then
	      sym := '#'
	    else
	      sym := '`';
	  end;
    end;


	{ Tests a spot for light or field mark status		-RAK-	}
[global,psect(misc1$code)] function test_light(y,x : integer) : boolean;
    begin
      with cave[y,x] do
	test_light := ((pl) or (fm) or (tl))
    end;


	{ Compact monsters					-RAK-	}
[global,psect(misc2$code)] procedure compact_monsters;
    var
	i1,i2,i3,ctr,cur_dis		: integer;
	delete_1,delete_any		: boolean;
    begin
      cur_dis := 66;
      delete_any := false;
      repeat
	i1 := muptr;
	i2 := 0;
	repeat
	  delete_1 := false;
	  i3 := m_list[i1].nptr;
	  with m_list[i1] do
	    if (cur_dis > cdis) then
	      if (randint(3) = 1) then
		begin
		  if (i2 = 0) then
		    muptr := i3
		  else
		    m_list[i2].nptr := i3;
		  cave[fy,fx].cptr := 0;
		  m_list[i1] := blank_monster;
		  m_list[i1].nptr := mfptr;
		  mfptr := i1;
		  ctr := ctr + 1;
		  delete_1 := true;
		  delete_any := true;
		end;
	  if (not(delete_1)) then i2 := i1;
	  i1 := i3;
	until (i1 = 0);
	if (not(delete_any)) then cur_dis := cur_dis - 6;
      until (delete_any);
      if (cur_dis < 66) then prt_map;
    end;


	{ Returns a pointer to next free space			-RAK-	}
[global,psect(misc3$code)] procedure popm(var x : integer);
    begin
      if (mfptr < 1) then compact_monsters;
      x := mfptr;
      mfptr := m_list[x].nptr;
    end;


	{ Pushs a record back onto free space list		-RAK-	}
[global,psect(misc3$code)] procedure pushm(x : integer);
    begin
      m_list[x] := blank_monster;
      m_list[x].nptr := mfptr;
      mfptr := x;
    end;


	{ Gives Max hit points					-RAK-	}
[global,psect(misc3$code)] function max_hp(hp_str : dtype) : integer;
    var
	i1,num,die		: integer;
    begin
      for i1 := 1 to length(hp_str) do
	if (hp_str[i1] = 'd') then
	  hp_str[i1] := ' ';
      readv(hp_str,num,die,error:=continue);
      max_hp := num*die;
    end;


	{ Places a monster at given location			-RAK-	}
[global,psect(misc3$code)] procedure place_monster(y,x,z : integer; slp : boolean);
    var
	i1,cur_pos		: integer;
    begin
      popm(cur_pos);
      with m_list[cur_pos] do
	begin
	  fy := y;
	  fx := x;
	  mptr := z;
	  nptr := muptr;
	  muptr := cur_pos;
	  if (uand(c_list[z].cdefense,%X'4000') <> 0) then
	    hp := max_hp(c_list[z].hd)
	  else
	    hp := damroll(c_list[z].hd);
	  cspeed := c_list[z].speed + py.flags.speed;
	  stunned := 0;
	  cdis := distance(char_row,char_col,y,x);
	  cave[y,x].cptr := cur_pos;
	  if (slp) then
	    begin
	      csleep := trunc(c_list[z].sleep/5.0) + randint(c_list[z].sleep);
	    end
	  else
	    csleep := 0;
	end;
    end;


	{ Places a monster at given location			-RAK-	}
[global,psect(misc3$code)] procedure place_win_monster;
    var
	cur_pos			: integer;
	y,x			: integer;
    begin
      if (not(total_winner)) then
	begin
	  popm(cur_pos);
	  with m_list[cur_pos] do
	    begin
	      repeat
		y := randint(cur_height-2)+1;
		x := randint(cur_width-2)+1;
	      until ((cave[y,x].fval in [1,2,4])	and
		     (cave[y,x].cptr = 0)		and
		     (cave[y,x].tptr = 0)		and
		     (distance(y,x,char_row,char_col) > max_sight));
	      fy := y;
	      fx := x;
	      mptr := randint(win_mon_tot) +
				m_level[max_mons_level] + m_level[0];
	      nptr := muptr;
	      muptr := cur_pos;
	      if (uand(c_list[mptr].cdefense,%X'4000') <> 0) then
		hp := max_hp(c_list[mptr].hd)
	      else
		hp := damroll(c_list[mptr].hd);
	      cspeed := c_list[mptr].speed + py.flags.speed;
	      stunned := 0;
	      cdis := distance(char_row,char_col,y,x);
	      cave[y,x].cptr := cur_pos;
	      csleep := 0;
	    end;
	end;
    end;


	{ Allocates a random land monster			-RAK-	}
[global,psect(misc3$code)] procedure alloc_land_monster(alloc_set : obj_set;
			  num,dis : integer;
			  slp : boolean;
			  water : boolean);
    var
	y,x,a,b,i1,i2,i3,count	: integer;
	count2			: integer;
	flag, flag2		: boolean;
    begin
      for i1 := 1 to num do
	begin
	  flag := false;
	  count := 0;
	  count2 := 0;
	  repeat
	    y := randint(cur_height-2)+1;
	    x := randint(cur_width-2)+1;
	    count2 := count2 + 1;
	  until ((cave[y,x].fval in alloc_set)	and
		 (cave[y,x].cptr = 0)		and
		 (cave[y,x].fopen)		and
		 (distance(y,x,char_row,char_col) > dis) or (count2 > 7500));
	  repeat
	    if (dun_level = 0) then
	      i2 := randint(m_level[0])
	    else if (dun_level > max_mons_level) then
	      i2 := randint(m_level[max_mons_level]) + m_level[0]
	    else if (randint(mon_nasty) = 1) then
	      begin
	        i2 := dun_level + abs(randnor(0,4)) + 1;
	        if (i2 > max_mons_level) then i2 := max_mons_level;
	        i3 := m_level[i2] - m_level[i2-1];
	        i2 := randint(i3) + m_level[i2-1];
	      end
	    else
	      i2 := randint(m_level[dun_level]) + m_level[0];
	    if (not water) then
	    flag := (uand(c_list[i2].cmove,%X'00008000') = 0) and
	       ((uand(c_list[i2].cmove,%X'00000010') = 0) or
		(uand(c_list[i2].cmove,%X'00000040') = 0) or
		(uand(c_list[i2].cmove,%X'00800000') <> 0)) 
	    else
	    flag := (uand(c_list[i2].cmove,%X'00008000') = 0) and
	       (uand(c_list[i2].cmove,%X'00000010') <> 0);
	     if (flag) then
	      begin
		if (count2 < 7500) then
		begin
		  place_monster(y,x,i2,slp);
		  flag := true;
		end;
	      end;
	    count := count + 1;
	  until (flag) or (count > 10);
	end
    end;


	{ Places land creature adjacent to given location	-RAK-	}
[global,psect(misc3$code)] function summon_land_monster(
				var y,x :	integer;
				slp	:	boolean
					) : boolean;
    var
	i1,i2,i3,i4,i5,count	: integer;
	flag			: boolean;
    begin
      i1 := 0;
      i5 := dun_level + mon$summon_adj;
      summon_land_monster := false;
      repeat
	i2 := y - 2 + randint(3);
	i3 := x - 2 + randint(3);
	if (in_bounds(i2,i3)) then
	  with cave[i2,i3] do
	    if (fval in earth_set) then
	      if (cptr = 0) then
		if (fopen) then
		  begin
		    flag := false;
		    count := 0;
		    repeat
		      if (i5 > max_mons_level) then
			i4 := max_mons_level
		      else
			i4 := i5;
		      if (dun_level = 0) then
			i4 := randint(m_level[0])
		      else
			i4 := randint(m_level[i4]) + m_level[0];
		      if (uand(c_list[i4].cmove,%X'00008000') = 0) and
			 ((uand(c_list[i4].cmove,%X'00000010') = 0) or
			  (uand(c_list[i4].cmove,%X'00000040') = 0) or
			  (uand(c_list[i4].cmove,%X'00800000') <> 0)) then
			begin
			  place_monster(i2,i3,i4,slp);
			  summon_land_monster := true;
			  flag := true;
			end;
		      count := count + 1;
		    until (flag) or (count > 10);
		    i1 := 9;
		    y := i2;
		    x := i3;
		  end;
	i1 := i1 + 1;
      until (i1 > 9);
    end;


	{ Places water creature adjacent to given location	-DMF-	}
[global,psect(misc3$code)] function summon_water_monster(
				var y,x :	integer;
				slp	:	boolean
					) : boolean;
    var
	i1,i2,i3,i4,i5,count	: integer;
	flag			: boolean;
    begin
      i1 := 0;
      i5 := dun_level + mon$summon_adj;
      summon_water_monster := false;
      repeat
	i2 := y - 2 + randint(3);
	i3 := x - 2 + randint(3);
	if (in_bounds(i2,i3)) then
	  with cave[i2,i3] do
	    if (fval in water_set) then
	      if (cptr = 0) then
		if (fopen) then
		  begin
		    flag := false;
		    count := 0;
		    repeat
		      if (i5 > max_mons_level) then
			i4 := max_mons_level
		      else
			i4 := i5;
		      if (dun_level = 0) then
			i4 := randint(m_level[0])
		      else
			i4 := randint(m_level[i4]) + m_level[0];
		      if (uand(c_list[i4].cmove,%X'00008000') = 0) and
			 ((uand(c_list[i4].cmove,%X'00000010') <> 0) or
			  (uand(c_list[i4].cmove,%X'00000040') = 0) or
			  (uand(c_list[i4].cmove,%X'00800000') <> 0)) then
			begin
			  place_monster(i2,i3,i4,slp);
			  summon_water_monster := true;
			  flag := true;
			end;
		      count := count + 1;
		    until (flag) or (count > 10);
		    i1 := 9;
		    y := i2;
		    x := i3;
		  end;
	i1 := i1 + 1;
      until (i1 > 9);
    end;


	{ Places undead adjacent to given location		-RAK-	}
[global,psect(misc3$code)] function summon_undead(var y,x : integer) : boolean;
    var
	i1,i2,i3,i4,i5,ctr	: integer;
    begin
      i1 := 0;
      summon_undead := false;
      i4 := m_level[max_mons_level] + m_level[0];
      repeat
	i5 := randint(i4);
	ctr := 0;
	repeat
	  if (uand(c_list[i5].cdefense,%X'0008') <> 0) then
	    begin
	      ctr := 20;
	      i4  := 0;
	    end
	  else
	    begin
	      i5 := i5 + 1;
	      if (i5 > i4) then
		ctr := 20
	      else
		ctr := ctr + 1;
	    end;
	until(ctr > 19)
      until(i4 = 0);
      repeat
	i2 := y - 2 + randint(3);
	i3 := x - 2 + randint(3);
	if (in_bounds(i2,i3)) then
	  with cave[i2,i3] do
	    if (fval in [1,2,4,5]) then
	      if ((cptr = 0) and (fopen)) then
		begin
		  place_monster(i2,i3,i5,false);
		  summon_undead := true;
		  i1 := 9;
		  y := i2;
		  x := i3;
		end;
	i1 := i1 + 1;
      until (i1 > 9);
    end;

	{ Places breeding monster adjacent to given location }
[global,psect(misc3$code)] function summon_breed(var y,x : integer) : boolean;
    var
	i1,i2,i3,i4,i5,ctr	: integer;
    begin
      summon_breed := false;
      i1 := 0;
      repeat
	i2 := y - 2 + randint(3);
	i3 := x - 2 + randint(3);
	if (in_bounds(i2,i3)) then
	  with cave[i2,i3] do
	    if (fval in earth_set) or (fval in water_set) then
	      if ((cptr = 0) and (fopen)) then
		begin
		  i4 := m_level[max_mons_level] + m_level[0];
		  repeat
		    i5 := randint(i4);
		    ctr := 0;
		    repeat
		      if (uand(c_list[i5].cmove,%X'00200000') <> 0) and
			 (((fval in earth_set) and
			   (uand(c_list[i5].cmove,%X'00000010') = 0) or
			   (uand(c_list[i5].cmove,%X'00000040') = 0) or
			   (uand(c_list[i5].cmove,%X'00800000') <> 0)) or
			  ((fval in water_set) and
			   (uand(c_list[i5].cmove,%X'00000010') <> 0) or
			   (uand(c_list[i5].cmove,%X'00000040') = 0) or
			   (uand(c_list[i5].cmove,%X'00800000') <> 0))) then
			begin
			  ctr := 20;
			  i4  := 0;
			end
		      else
			begin
			  i5 := i5 + 1;
			  if (i5 > i4) then
			    ctr := 20
 			  else
			    ctr := ctr + 1;
			end;
		    until(ctr > 19)
		  until(i4 = 0);
		  place_monster(i2,i3,i5,false);
		  summon_breed := true;
		  i1 := 9;
		  y := i2;
		  x := i3;
		end;
	i1 := i1 + 1;
      until (i1 > 9);
    end;

	{ Places demon adjacent to given location		-RAK-	}
[global,psect(misc3$code)] function summon_demon(var y,x : integer) : boolean;
    var
	i1,i2,i3,i4,i5,ctr	: integer;
    begin
      i1 := 0;
      summon_demon := false;
      i4 := m_level[max_mons_level] + m_level[0];
      repeat
	i5 := randint(i4);
	ctr := 0;
	repeat
{	 Check monsters for demon }
	  if (uand(c_list[i5].cdefense,%X'0400') <> 0) then
	    begin
	      ctr := 20;
	      i4  := 0;
	    end
	  else
	    begin
	      i5 := i5 + 1;
	      if (i5 > i4) then
		ctr := 20
	      else
		ctr := ctr + 1;
	    end;
	until(ctr > 19)
      until(i4 = 0);
      repeat
	repeat
	  i2 := y - 2 + randint(3);
	  i3 := x - 2 + randint(3);
	until ((i2 <> y)or(i3 <> x));
	if (in_bounds(i2,i3)) then
	  with cave[i2,i3] do
	    if (fval in [1,2,4,5]) then
	      if ((cptr = 0) and (fopen)) then
		begin
		  place_monster(i2,i3,i5,false);
		  summon_demon := true;
		  i1 := 9;
		  y := i2;
		  x := i3;
		end;
	i1 := i1 + 1;
      until (i1 > 9);
    end;

[global,psect(misc3$code)] procedure petrify(amt : integer);
    begin
      with py.flags do
	begin
	  petrification := petrification + randint(amt);
	  if (petrification < 100) then
	    msg_print('You feel your joints stiffening.')
	  else if (petrification < 150) then
	    msg_print('Your feet are beginning to feel heavy.')
	  else if (petrification < 200) then
	    msg_print('Your knees are no longer able to bend.')
	  else if (petrification < 250) then
	    msg_print('Your legs feel like blocks of stone.')
	  else if (petrification < 300) then
	    msg_print('You are finding it difficult to breathe.')
	  else
	    begin
	      msg_print('You have turned to stone.');
	      died_from := 'petrification';
	      upon_death;
	    end;
        end;
    end;

	{ If too many objects on floor level, delete some of them-RAK-	}
[global,psect(misc2$code)] procedure compact_objects;
    var
	i1,i2,ctr,cur_dis		: integer;
	flag				: boolean;
    begin
      ctr := 0;
      cur_dis := 66;
      repeat
	for i1 := 1 to cur_height do
	  for i2 := 1 to cur_width do
	    with cave[i1,i2] do
	      if (tptr > 0) then
		if (distance(i1,i2,char_row,char_col) > cur_dis) then
		  begin
		    flag := false;
		    with t_list[tptr] do
		      case tval of
			Seen_Trap : if (subval in [1,6,9]) then
				    flag := true
				  else if (randint(4) = 1) then
				    flag := true;
			rubble	  : flag := true;
			open_door, closed_door
				  : if (randint(8) = 1) then flag := true;
			up_staircase, down_staircase,
			up_steep_staircase, down_steep_staircase,
			entrance_to_store : ;
			otherwise if (randint(8) = 1) then flag := true;
		      end;
		    if (flag) then
		      begin
			fopen := true;
			t_list[tptr] := blank_treasure;
			t_list[tptr].p1 := tcptr;
			tcptr := tptr;
			tptr := 0;
			ctr := ctr + 1;
		      end;
		  end;
	  if (ctr = 0) then cur_dis := cur_dis - 6;
	until (ctr > 0);
	if (cur_dis < 66) then prt_map;
    end;


	{ Gives pointer to next free space			-RAK-	}
[global,psect(misc4$code)] procedure popt(var x : integer);
    var
	i1			: integer;
    begin
      if (tcptr < 1) then compact_objects;
      x := tcptr;
      tcptr := t_list[x].p1;
    end;


	{ Pushs a record back onto free space list		-RAK-	}
[global,psect(misc4$code)] procedure pusht(x : integer);
    begin
      t_list[x] := blank_treasure;
      t_list[x].p1 := tcptr;
      tcptr := x;
    end;


	{ Order the treasure list by level			-RAK-	}
[global,psect(setup$code)] procedure sort_objects;
    var
	i1,i2,i3,gap		: integer;
	tmp			: treasure_type;
    begin
      gap := max_objects div 2;
      while (gap > 0) do
	begin
	  for i1 := gap+1 to max_objects do
	    begin
	      i2 := i1 - gap;
	      while (i2 > 0) do
		begin
		  i3 := i2 + gap;
		  if (object_list[i2].level > object_list[i3].level) then
		    begin
		      tmp := object_list[i2];
		      object_list[i2] := object_list[i3];
		      object_list[i3] := tmp;
		    end
		  else
		    i2 := 0;
		  i2 := i2 - gap;
		end;
	    end;
	  gap := gap div 2;
	end;
    end;



	{ Chance of treasure having magic abilities		-RAK-	}
	{ Chance increases with each dungeon level			}
[global,psect(misc4$code)] procedure magic_treasure(x,level : integer);
    var
	chance,special,cursed,i1,wpn_type	: integer;

   procedure Ego_sword(x : integer);
     	begin
	  with t_list[x] do
        	case randint(5) of
	  		1 : begin {Holy Avenger}
				  flags := uor(flags,see_invisible_worn_bit+
						     sustain_stat_worn_bit+
						     resist_acid_worn_bit+
						     resist_fire_worn_bit+
						     strength_worn_bit+
						     slay_undead_worn_bit+
						     slay_evil_worn_bit);
				  tohit := tohit + 5;
				  todam := todam + 5;
				  toac	:= randint(4);
				  p1	:= randint(4) - 1;
				  name	:= name + ' (HA)';
				  cost	:= cost + p1*50000;
				  cost	:= cost + 1000000;
				end;
			2 : begin {Defender}
				  flags := uor(flags,feather_fall_worn_bit+
						     see_invisible_worn_bit+
						     resist_lightning_worn_bit+
						     free_action_worn_bit+
						     resist_cold_worn_bit+
						     resist_acid_worn_bit+
						     resist_fire_worn_bit+
						     regeneration_worn_bit+
						     stealth_worn_bit);
				  tohit := tohit + 3;
				  todam := todam + 3;
				  toac	:= 5 + randint(5);
				  name	:= name + ' [%P4] (DF)';
				  p1	:= randint(3);
				  cost	:= cost + p1*50000;
				  cost	:= cost + 750000;
				end;
			3 : begin {Demon Bane}
				  flags := uor(flags,resist_fire_worn_bit);
				  flags2 := uor(flags2,slay_demon_worn_bit);
				  tohit := tohit + 3;
				  todam := todam + 3;
				  name := name + ' (DB)';
				  cost := cost + 500000;
				end;
			4 : begin {Soul Sword}
				  flags := uor(flags,intelligence_worn_bit+
						     wisdom_worn_bit+
						     charisma_worn_bit+
						     see_invisible_worn_bit+
						     regeneration_worn_bit);
				  flags2 := uor(flags2,soul_sword_worn_bit+
						       bad_repute_worn_bit);
				  tohit := tohit + 5;
				  todam := todam + 10;
				  p1 := -randint(3) - 2;
				  cost := cost + 800000 + p1*40000;
				  name := name + ' (SS)';
				end;
			5 : begin {Vorpal Sword}
				  flags := uor(flags,sustain_stat_worn_bit);
				  flags2 := uor(flags2,sharp_worn_bit);
				  p1 := 1;
				  tohit := tohit + 5;
				  todam := todam + 5;
				  cost := cost + 750000;
				  name := name + ' (V)';
				end;
			end; {of case}
		  end; {of procedure}

    procedure Slaying_sword(x : integer);
		begin
	  	  with t_list[x] do
			case randint(4) of
				1 : begin {Slay Monster}
				  flags := uor(flags,see_invisible_worn_bit+
						     slay_monster_worn_bit);
				  tohit := tohit + 3;
				  todam := todam + 3;
				  name := name + ' (SM)';
				  cost := cost + 500000;
				end;

				2 : begin {Slay Dragon}
				  flags := uor(flags,slay_dragon_worn_bit);
				  tohit := tohit + 3;
				  todam := todam + 3;
				  name := name + ' (SD)';
				  cost := cost + 400000;
				end;

				3 : begin {Slay Undead}
				  flags := uor(flags,slay_undead_worn_bit);
				  tohit := tohit + 2;
				  todam := todam + 2;
				  name := name + ' (SU)';
				  cost := cost + 300000;
				end;

				4 : begin {Slay Regenerative}
				  flags2 := uor(flags2,slay_regen_worn_bit);
				  tohit := tohit + 2;
				  todam := todam + 2;
				  cost := cost + 150000;
				  name := name + ' (SR)';
				end;
			end; {of case}
		end; {of procedure}

    procedure Magic_sword(x : integer);
		begin
		  with t_list[x] do
			case randint(4) of
				1 : begin {Flame Tongue}
				  flags := uor(flags,flame_brand_worn_bit);
				  tohit := tohit + 1;
				  todam := todam + 3;
				  name := name + ' (FT)';
				  cost := cost + 200000;
				end;

				2 : begin {Frost Brand}
				  flags := uor(flags,cold_brand_worn_bit);
				  tohit := tohit + 1;
				  todam := todam + 1;
				  name := name + ' (FB)';
				  cost := cost + 120000;
				end;

				3 : begin {Wizards Blade}
				  flags2 := uor(flags2,Magic_proof_worn_bit);
				  weight := trunc(weight * 4 / 5);
				  tval := Dagger;
				  tohit := tohit + 3;
				  todam := todam + 1;
				  cost := cost + 80000;
				  name := name + ' (WB)';
				end;	

				4 : begin {Blessed Blade}
				  flags := uor(flags,magic_proof_worn_bit);
				  tval := maul;
				  tohit := tohit +2;
				  todam := todam +4;
				  cost := cost + 80000;
				  name := name + ' (BB)';
				end;
			end; {of case}
		end; {of procedure}

	{ Boolean : is object enchanted		  -RAK- }
    function magik(chance : integer) : boolean;
      begin
	magik := (randint(150) <= chance); { for deeper dungeon levels }
      end;

	{ Enchant a bonus based on degree desired -RAK- }
    function m_bonus(base,max_std,level : integer) : integer;
      var
	x,stand_dev		: integer;
      begin
	stand_dev := trunc(obj_std_adj*level) + obj_std_min;
	if (stand_dev > max_std) then stand_dev := max_std;
	x := trunc(abs(randnor(0,stand_dev))/10.0) + base;
	if (x < base) then
	  m_bonus := base
	else
	  m_bonus := x;
      end;

    begin
      chance := obj_base_magic +(level*(obj_base_max-obj_base_magic)) div 100;
      if (chance > obj_base_max) then chance := obj_base_max;
      special := trunc(chance/obj_div_special);
      cursed  := trunc(chance/obj_div_cursed);
      with t_list[x] do
	{ Depending on treasure type, it can have certain magical properties}
	case tval of
 { Miscellaneous Objects}
	  valuable_gems :
		begin
		  case subval of
			1 : p1 := randint(10) + 10;
			2 : p1 := randint(5) +2;
			3 : p1 := randint(8) + 7;
			4 : p1 := randint(3) + 3;
			5 : p1 := randint(10) + 10;
			6 : p1 := randint(5) + 5;
			7 : p1 := randint(15) + 15;
			8 : p1 := randint(3) + 2;
			9 : p1 := randint(5) + 3;
			10: p1 := randint(3) + 2;
			11: p1 := randint(6) + 4;
		     end;
		end;
	  misc_usable :
		begin
		  if (magik(chance)) then
		    if (magik(special)) then
		      case subval of
			14   : begin {statues}
				 case randint(3) of
				   1 : {summoning undead}
				     begin
					flags := uor(flags,%X'00000100');
					name := name + ' Major of Undead Summoning';
					cost := 0;
					p1 := randint(4) + 2;
				     end;
				   2 : {summon demon}
				     begin
					flags := uor(flags,%X'00000200');
					name := name + ' Major of Demon Summoning';
					cost := 0;
					p1 := randint(3) + 1;
				     end;
				   3 : {Life giving}
				     begin
					flags := uor(flags,%X'00000400');
					name := name + ' Life Giving';
					cost := 900000;
					p1 := randint(5) + 3;
				     end;
				  end;
				end;
			 15	    : begin
					case randint(4) of
					 1 : begin
					       name := name + ' from a Dragon';
					       p1 := randint(4) + 2;
					       cost := cost + p1*20000;
					      flags := uor(flags,%X'20000000');

					     end;
					2 : begin
						name := name + ' of a Demon';
						p1 := randint(4) +2;
						cost := cost + p1*20000;
					      flags := uor(flags,%X'40000000');
					     end;
				  otherwise  ;
				     end;
				end;
			16,17,18    : begin {crucifixes}
					case randint(4) of
				         1,2,3 : begin 
					      flags := uor(flags,%X'00000001');
					      name := name + ' of Turning';
					      p1 := randint(p1*2) + 2;
					      cost := cost + p1*20000;
					     end;
					 4 : begin
					      flags := uor(flags,%X'00000002');
					      name := name + ' of Demon Dispelling';
					      p1 := randint( trunc(subval/2));
					      cost := cost + p1 * 50000;
					     end;
					  end;
					end;
			19 : begin
				flags := uor(flags,%X'00000004');
				name := name + ' of Summon Undead';
				cost := 0;
				p1 := 2;
			     end;
			20 : begin
				flags := uor(flags,%X'00000008');
				name := name + ' of Demon Summoning';
				cost := 0;
				p1 := 2;
 			     end;
			21 : begin
				case randint(3) of
				  1 : begin
					flags := uor(flags,%X'00000010');
					name := name +' containing a Djinni';
					cost := 200000;
					p1 := 1;
				      end;
				  2,3 : begin
{this routine sucks!!!!!}		flags := uor(flags,%X'00000020');
					name := name+' containing some Demons';
					cost := 0;
					p1 := 1
				     end;
				 end;
				end;
			end;
		end;
 { Armor and shields }
	  shield, hard_armor, soft_armor :
		 begin
		    if ((tval = soft_armor) and (subval=6)) then
		      begin
{sorry about the mess.  dean}
			if (randint(4)=1) then
			begin
			  t_list[x] := yums[11+randint(3)];
	  t_list[x].weight := t_list[x].weight*weight_adj;
			  t_list[x].cost:=trunc(t_list[x].cost*cost_adj);
			end;
		      end
		    else if ((tval=hard_armor) and (subval=13)) then
		      if (magik(chance) or (randint(5)=1)) then
			begin
			if (magik(special) or (randint(5)=1)) then
			  if (randint(3)=1) then
			    t_list[x] := yums[17]
			  else
			    t_list[x] := yums[16]
			else
			  t_list[x] := yums[15];
	  t_list[x].weight := t_list[x].weight*weight_adj;
			  t_list[x].cost:=trunc(t_list[x].cost*cost_adj);
			end;
		    if magik(chance) then
		      begin
			toac := m_bonus(1,30,level);
			if magik(special) then
			  case randint(9) of
			1     : begin
				  flags := uor(flags,resist_lightning_worn_bit+
						     resist_cold_worn_bit+
						     resist_acid_worn_bit+
						     resist_fire_worn_bit);
				  name := name + ' (R)';
				  toac := toac + 5;
				  cost := cost + 250000;
				end;
			2     : begin	{ Resist Acid	}
				  flags := uor(flags,resist_acid_worn_bit);
				  name := name + ' (RA)';
				  cost := cost + 100000;
				end;
			3,4   : begin	{ Resist Fire	}
				  flags := uor(flags,resist_fire_worn_bit);
				  name := name + ' (RF)';
				  cost := cost + 60000;
				end;
			5,6   : begin	{ Resist Cold	}
				  flags := uor(flags,resist_cold_worn_bit);
				  name := name + ' (RC)';
				  cost := cost + 60000;
				end;
			7,8,9 : begin	{ Resist Lightning}
				  flags := uor(flags,resist_lightning_worn_bit);
				  name := name + ' (RL)';
				  cost := cost + 50000;
				end;
			  end
		      end
		    else if (magik(cursed)) then
		      begin
			toac := -m_bonus(1,40,level);
			cost := 0;
			flags := uor(cursed_worn_bit,flags);
		      end
		  end;
{ Weapons }
	  hafted_weapon, pole_arm, sword, dagger, maul :
		begin
		    if magik(chance) then
		      begin
			tohit := m_bonus(0,40,level);
			todam := m_bonus(0,40,level);
			if magik(special) then
			  if ((subval = 99) and (randint(5)=1)) then 
			       begin
				  flags := uor(flags,charisma_worn_bit+
						searching_worn_bit+
						stealth_worn_bit+
						regeneration_worn_bit+
						resist_acid_worn_bit+
						resist_cold_worn_bit);
				  p1 := -5;
				  cost := 120000;
				  name := name + ' of Trollkind';
				  damage := '3d4';
				end
			   else 
			     begin
			       wpn_type := randint(100);
			         if (wpn_type < 61) then
				   Magic_sword(x)
			         else if (wpn_type < 81) then
				   Slaying_sword(x)
			         else if (wpn_type < 96) then
				   Ego_sword(x)
			         else 
				   begin
				     Magic_sword(x);
				     Ego_sword(x);
				   end
			     end 
		    else if (magik(cursed)) then
		      begin
			tohit := -m_bonus(1,55,level);
			todam := -m_bonus(1,55,level);
			flags := uor(cursed_worn_bit,flags);
			cost := 0;
		      end
		  end
	      end;
{ Bows, crossbows, and slings }
	    bow_crossbow_or_sling :
		 begin
		    if magik(chance) then
		      begin
 		        tohit := m_bonus(1,30,level);
		        if magik(special) then 
			  begin
 			    flags2 := uor(flags2,sharp_worn_bit);
			    tohit := tohit + 5;
			    cost := cost + 300000;
			    name := name + ' of Criticals';
			  end;
		      end
		    else if (magik(cursed)) then
		      begin
			tohit := -m_bonus(1,50,level);
			flags := uor(cursed_worn_bit,flags);
			cost := 0;                     
		      end;
		  end;
{ Digging tools }
	   pick_or_shovel :
		 begin
		    if magik(chance) then
		      case randint(3) of
			1,2:begin{25}
			      p1 := m_bonus(2,25,level);
			      cost := cost + p1*10000;
			    end;
			3 : begin
			      p1 := -m_bonus(1,30,level);
			      cost := 0;
			      flags := uor(cursed_worn_bit,flags);
			    end;
		      end;
		  end;
{ Gloves and Gauntlets }
	     gloves_and_gauntlets :
		 begin
		    if magik(chance) then
		      begin
			toac := m_bonus(1,20,level);
			if magik(special)  then
			  if ((subval = 5) and (randint(10)=1)) then
				begin
				  name := name + ' of the Hive';
				  flags := uor(flags,dexterity_worn_bit);
				  p1 := 2;
				  cost := cost + 50000;
				end
			  else
			  case randint(5) of
			    1  :begin
				  flags := uor(free_action_worn_bit,flags);
				  name := name + ' of Free Action';
				  cost := cost + 100000;
				end;
			    2  :begin
				  tohit := 1 + randint(3);
				  todam := 1 + randint(3);
				  name := name + ' of Slaying';
				  cost := cost + (tohit+todam)*25000;
				end;
			    3 : begin
				  flags2 := uor(flags2,disarm_worn_bit);
				  flags := uor(flags,Feather_fall_worn_bit+
						See_invisible_worn_bit);
				  p1 := m_bonus(5,50,level);
				  cost := cost + 20000 + p1*5;
				  name := name + ' of Thievery (%P1)';
				end;
			    4,5 : begin
				  flags := uor(flags,Slow_digestion_worn_bit+
							Strength_worn_bit);
				  p1 := randint(4);
				  name := name + ' of Ogre Power';
				  cost := cost + 150000;
				end;
			  end;
		      end
		    else if (magik(cursed)) then
		      begin
			if (magik(special)) then
			  case randint(3) of
			    1 : begin
				  flags := uor(flags,cursed_worn_bit+
						     dexterity_worn_bit);
				  name := name + ' of Clumsiness';
				  p1 := 1;
				end;
			    2 : begin
				  flags := uor(flags,cursed_worn_bit+
						     strength_worn_bit);
				  name := name + ' of Weakness';
				  p1 := 1;
				end;
			    3 : begin
				  flags := uor(flags,cursed_worn_bit+
						    intelligence_worn_bit);
				  name := name + ' of Ogre Intelligence';
				  p1 := 1;
				end;
			  end;
			toac := -m_bonus(1,40,level);
			p1   := -m_bonus(1,10,level);
			flags := uor(cursed_worn_bit,flags);
			cost := 0;
		      end
		  end;
{ Boots }
	  boots :
		 begin
		    if magik(chance)  then
		      begin
			toac := m_bonus(1,20,level);
			if magik(special) then
			  case randint(16) of
			    1 : begin
				  flags := uor(speed_worn_bit,flags);
				  name := name + ' of Speed';
				  p1 := 1;
				  cost := cost + 500000;
				end;
		         2..5 : begin
				  flags := uor(stealth_worn_bit,flags);
				  name := name + ' of Stealth';
				  cost := cost + 50000;
				end;
		      otherwise begin
				if ((subval = 4) and (randint(6)=1))then
				begin
				  flags := uor(charisma_worn_bit+
						feather_fall_worn_bit+
						see_invisible_worn_bit+
						free_action_worn_bit,flags);
				  flags2 := uor(magic_proof_worn_bit,flags2);
				  p1 := 3;
				  name := name + ' of Dryadkind';
				  cost := 1 {see magi item};
				end
				else
				begin
				  flags := uor(feather_fall_worn_bit,flags);
				  name := name + ' of Slow descent';
				  cost := cost + 25000;
				end
			    end
		      end
		    else if (magik(cursed)) then
		      begin
			case randint(3) of
			  1 : begin
				flags := uor(flags,cursed_worn_bit+
						   speed_worn_bit);
				name := name + ' of Slowness';
				p1 := -1;
			      end;
			  2 : begin
				flags := uor(flags,cursed_worn_bit+
						   aggravation_worn_bit);
				name := name + ' of Noise';
			      end;
			  3 : begin
				flags := uor(flags,cursed_worn_bit);
				name := name + ' of Great Mass';
				weight := weight*5;
			      end;
			end;
			cost := 0;
			ac := -m_bonus(2,45,level);
		      end;
		  end;
	 end;
{ Helms }
	  helm :
		 begin
		    if magik(chance)  then
		      begin
			toac := m_bonus(1,20,level);
			if magik(special)  then
			  case subval of
			1,2,3,4,5 :  case randint(3) of
				1 : begin
				      p1 := randint(2);
				      flags := uor(Intelligence_worn_bit,flags);
				      name := name + ' of Intelligence';
				      cost := cost + p1*50000;
				    end;
				2 : begin
				      p1 := randint(2);
				      flags := uor(wisdom_worn_bit,flags);
				      name := name + ' of Wisdom';
				      cost := cost + p1*50000;
				    end;
				3 : begin
				      p1 := 1 + randint(4);
				      flags := uor(infra_vision_worn_bit,flags);
				      name := name + ' of Infra-Vision';
				      cost := cost + p1*25000;
				    end;
			      end;
		    6,7,8,9,10   :  case randint(6) of
				1 : begin
				      p1 := randint(3);
				      flags := uor(flags,free_action_worn_bit+
							 constitution_worn_bit+
							 strength_worn_bit+
							 dexterity_worn_bit);
				      name := name + ' of Might';
				      cost := cost + 100000 + p1*50000;
				    end;
				2 : begin
				      p1 := randint(3);
				      flags := uor(flags,wisdom_worn_bit+
							 charisma_worn_bit);
				      name := name + ' of Lordliness';
				      cost := cost + 100000 + p1*50000;
				    end;
				3 : begin
				      p1 := randint(3);
				      flags := uor(flags,free_action_worn_bit+
							 strength_worn_bit+
							 constitution_worn_bit+
							 dexterity_worn_bit);
				      name := name + ' of the Magi';
				      cost := cost + 300000 + p1*50000;
				    end;
				4 : begin
				      p1 := randint(3);
				      flags := uor(flags,charisma_worn_bit);
				      name := name + ' of Beauty';
				      cost := cost + 75000;
				    end;
				5 : begin
				      p1 := 1 + randint(4);
				      flags := uor(flags,see_invisible_worn_bit+
							 searching_worn_bit);
				      name := name + ' of Seeing';
				      cost := cost + 100000 + p1*10000;
				    end;
				6 : begin
				      flags := uor(flags,regeneration_worn_bit);
				      name := name + ' of Regeneration';
				      cost := cost + 150000;
				    end;
			11 : 	begin
				      name := name + ' of Hobbitkind';
				      flags := uor(flags,Infra_vision_worn_bit+
						see_invisible_worn_bit+
						free_action_worn_bit+
						searching_worn_bit);
				      cost := cost + 170000;
				      p1 := 5;
				end;
			      end;
			  end;
		      end
		    else if (magik(cursed)) then
		      begin
			toac := -m_bonus(1,45,level);
			flags := uor(cursed_worn_bit,flags);
			cost := 0;
			if (magik(special)) then
			  case randint(15) of
			    1,2 : begin
				  p1 := -1;
				  flags := uor(intelligence_worn_bit,flags);
				  name := name + ' of Stupidity';
				end;
			    3,4 : begin
				  p1 := -1;
				  flags := uor(flags,wisdom_worn_bit);
				  name := name + ' of Dullness';
				end;
			    5,6 : begin
				  flags := uor(blindness_worn_bit,flags);
				  name := name + ' of Blindness';
				end;
			    7,8 : begin
				  flags := uor(timidness_worn_bit,flags);
				  name := name + ' of Timidness';
				end;
			    9,10 : begin
				  p1 := -1;
				  flags := uor(strength_worn_bit,flags);
				  name := name + ' of Weakness';
				end;
			    11,12 : begin
				  flags := uor(teleportation_worn_bit,flags);
				  name := name + ' of Teleportation';
				end;
			    13,14 : begin
				  p1 := -1;
				  flags := uor(charisma_worn_bit,flags);
				  name := name + ' of Ugliness';
				end;
			    15 : begin
				p1 := -5;
				name := name + ' of **TOTAL DOOM**';
				flags := uor(flags,cursed_worn_bit+
						strength_worn_bit+
						dexterity_worn_bit+
						Constitution_worn_bit+
						Intelligence_worn_bit+
						wisdom_worn_bit+
						charisma_worn_bit+
						stealth_worn_bit+
						aggravation_worn_bit+
						teleportation_worn_bit+
						blindness_worn_bit+
						timidness_worn_bit);
				flags2 := uor(flags2,hunger_worn_bit+
						known_cursed_bit);
				end;
			  end;
			p1 := p1 * randint(5);
		      end;
		  end;
{girdles, belts and buckles}
	  belt :
		 begin
		    if magik(chance) then
		      begin
			toac := m_bonus(1,20,level);
			if magik(special) then
			  case subval of
			1 : begin 
			      flags2 := uor(increase_carry_worn_bit,flags2);
			      case randint(16) of
				1 : if (randint(3) = 1) then
			             begin
				      p1 := 7;
				      flags := uor(resist_lightning_worn_bit+
						resist_fire_worn_bit+
						resist_cold_worn_bit+
						resist_acid_worn_bit+
						regeneration_worn_bit+
						free_action_worn_bit,flags);
				      flags2:=uor(magic_proof_worn_bit,flags2);
				      name := name + ' of Titan Strength';
				      cost := cost + 7500000;
				     end
				    else
				     begin
				      p1 := 6;
				      flags := uor(resist_lightning_worn_bit+
						resist_acid_worn_bit,flags);
				      flags2:=uor(magic_proof_worn_bit,flags2);
				      name := name+ ' of Storm Giant Strength';
				      cost := cost + 3500000;
				     end;
				2 : begin
				      p1 := 5;
				      flags := uor(resist_lightning_worn_bit+
						resist_acid_worn_bit,flags);
				      name := name+ ' of Cloud Giant Strength';
				      cost := cost + 2000000;
				    end;
				3,4 : begin
				      p1 := 4;
				      flags := uor(resist_fire_worn_bit,flags);
				      name := name + ' of Fire Giant Strength';
				      cost := cost + 1750000;
				    end;
				5,6,7 : begin
				      p1 := 3;
				      flags := uor(resist_cold_worn_bit,flags);
				      name := name+ ' of Frost Giant Strength';
				      cost := cost + 1250000;
				    end;
				8,9,10,11 : begin
				      p1 := 2;
				      name := name+ ' of Stone Giant Strength';
				      cost := cost + 800000;
				    end;
				12,13,14,15,16 : begin
				      p1 := 1;
				      name := name + ' of Hill Giant Strength';
				      cost := cost + 600000;
				    end;
				  end;
				  tohit := p1; 
				  todam := p1;
				end;

		    10,11   :  case randint(2) of
				1 : begin
				      toac := toac + randint(5);
				      flags2 := uor(magic_proof_worn_bit,flags2);
				      name := name + ' of Deflection';
				      cost := cost + toac*20000;
				    end;
				2 : begin
				      flags := uor(flags,sustain_stat_worn_bit+
						     slow_digestion_worn_bit);
				      name := name + ' of Improved Digestion';
				      p1 := 2;
				      cost := cost + 100000;
				    end;
			13 : 	begin
				      name := name + ' of Dwarvenkind';
				      flags := uor(flags,Infra_vision_worn_bit+
						tunneling_worn_bit+
						sustain_stat_worn_bit);
				     flags2 := uor(flags2,magic_proof_worn_bit);						
				      cost := cost + 70000;
				      p1 := 2;
				end;
			      end;
			  end;
		      end
		    else if (magik(cursed)) then
		      begin
			toac := -m_bonus(1,45,level);
			flags := uor(cursed_worn_bit,flags);
			cost := 0;
			if (magik(special)) then
			  case subval of
			    1 : case randint(2) of
				1 : begin
				  p1 := -2;
				  flags := uor(charisma_worn_bit,flags);
				  name := name + ' of Sex Change';
				  end;
				2 : begin
				  p1 := -1;
				  flags := uor(flags,strength_worn_bit);
				  name := name + ' of Weakness';
				  end;
				end;
			  10,11 : begin
				  p1 := -1;
				  flags := uor(flags,cursed_worn_bit+
						timidness_worn_bit);
				  name := name + ' of Fear'
				end;
			    13 : begin
				  p1 := -1;
				  flags2 := uor(flags2,hunger_worn_bit);
				  flags := uor(flags,cursed_worn_bit);
				  name := name + ' of Hunger';
				end;
			  end;
			p1 := p1*randint(5);
		      end;
		  end;
{ Rings }
	  ring :
		 begin
		    case subval of
		1,2,3,4,5,6 :	if (magik(cursed)) then
				  begin
				    p1 := -m_bonus(1,20,level);
				    flags := uor(cursed_worn_bit,flags);
				    cost := -cost;
				  end
				else
				  begin
				    p1 := m_bonus(1,10,level);
				    cost := cost + p1*10000;
				  end;
			  7 :	if (magik(cursed)) then
				  begin
				    p1 := -randint(3);
				    flags := uor(cursed_worn_bit,flags);
				    cost := -cost;
				  end
				else
				  p1 := 1;
			  8  :	begin
				  p1 := 5*m_bonus(1,20,level);
				  cost := cost + p1*10000;
				end;
			  22 :	begin	{ Increase damage	}
				  todam := m_bonus(1,20,level);
				  cost := cost + todam*10000;
				  if (magik(cursed)) then
				    begin
				      todam := -todam;
				      flags := uor(cursed_worn_bit,flags);
				      cost := -cost;
				    end
				end;
			  23 :	begin	{ Increase To-Hit	}
				  tohit := m_bonus(1,20,level);
				  cost := cost + todam*10000;
				  if (magik(cursed)) then
				    begin
				      tohit := -tohit;
				      flags := uor(cursed_worn_bit,flags);
				      cost := -cost;
				    end
				end;
			  24 :	begin	{ Protection		}
				  toac := m_bonus(1,20,level);
				  cost := cost + todam*10000;
				  if (magik(cursed)) then
				    begin
				      toac := -toac;
				      flags := uor(cursed_worn_bit,flags);
				      cost := -cost;
				    end
				end;
			  33 :	begin	{ Slaying	}
				  todam := m_bonus(1,25,level);
				  tohit := m_bonus(1,25,level);
				  cost := cost + (tohit+todam)*10000;
				  if (magik(cursed)) then
				    begin
				      tohit := -tohit;
				      todam := -todam;
				      flags := uor(cursed_worn_bit,flags);
				      cost := -cost;
				    end
				end;
			  35 : begin   { Speed -10 or worse }
				  p1 := -(10+randint(10));
				  cost := cost + (1000000*p1);
				  if (uand(%X'80000000',flags)<>0) then
				     flags := uand(%X'7FFFFFFF',flags);
			       end;
			    otherwise ;
			  end;

		end;
{ Amulets }
	  amulet :
		 begin
		    case subval of
		1,2,3,4,5,6 :	if (magik(cursed)) then
				  begin
				    p1 := -m_bonus(1,20,level);
				    flags := uor(cursed_worn_bit,flags);
				    cost := -cost;
				  end
				else
				  begin
				    p1 := m_bonus(1,10,level);
				    cost := cost + p1*10000;
				  end;
			  7  :	begin
				  p1 := 5*m_bonus(1,25,level);
				  if (magik(cursed)) then
				    begin
				      p1 := -p1;
				      cost := -cost;
				      flags := uor(cursed_worn_bit,flags);
				    end
				  else
				    cost := cost + 10000*p1;
				end;
			    otherwise ;
			  end;
		  end;
			{ Subval should be even for store, odd for dungeon}
			{ Dungeon found ones will be partially charged	  }
{ Lamps and torches }
	  lamp_or_torch :
		 begin 
		    if ((subval mod 2) = 1) then
		      p1 := randint(p1);
		  end;
{ Wands }
	  wand :
		begin
		    case subval of
			1   :	p1 := randint(10) + 6;
			2   :	p1 := randint(8)  + 6;
			3   :	p1 := randint(5)  + 6;
			4   :	p1 := randint(8)  + 6;
			5   :	p1 := randint(4)  + 3;
			6   :	p1 := randint(8)  + 6;
			7   :	p1 := randint(20) + 12;
			8   :	p1 := randint(20) + 12;
			9   :	p1 := randint(10) + 6;
			10  :	p1 := randint(12) + 6;
			11  :	p1 := randint(10) + 12;
			12  :	p1 := randint(3)  + 3;
			13  :	p1 := randint(8)  + 6;
			14  :	p1 := randint(10) + 6;
			15  :	p1 := randint(5)  + 3;
			16  :	p1 := randint(5)  + 3;
			17  :	p1 := randint(5)  + 6;
			18  :	p1 := randint(5)  + 4;
			19  :	p1 := randint(8)  + 4;
			20  :	p1 := randint(6)  + 2;
			21  :	p1 := randint(4)  + 2;
			22  :	p1 := randint(8)  + 6;
			23  :	p1 := randint(5)  + 2;
			24  :	p1 := randint(12) + 12;
			25  :   p1 := randint(20) + 10;
			otherwise ;
		    end
		  end;
{ Staffs }
	  staff : 
		begin
		    case subval of
			1   :	p1 := randint(20) + 12;
			2   :	p1 := randint(8)  + 6;
			3   :	p1 := randint(5)  + 6;
			4   :	p1 := randint(20) + 12;
			5   :	p1 := randint(15) + 6;
			6   :	p1 := randint(4)  + 5;
			7   :	p1 := randint(5)  + 3;
			8   :	p1 := randint(3)  + 1;
			9   :	p1 := randint(3)  + 1;
			10  :	p1 := randint(3)  + 1;
			11  :	p1 := randint(5)  + 6;
			12  :	p1 := randint(10) + 12;
			13  :	p1 := randint(5)  + 6;
			14  :	p1 := randint(5)  + 6;
			15  :	p1 := randint(5)  + 6;
			16  :	p1 := randint(10) + 12;
			17  :	p1 := randint(3)  + 4;
			18  :	p1 := randint(5)  + 6;
			19  :	p1 := randint(5)  + 6;
			20  :	p1 := randint(3)  + 4;
			21  :	p1 := randint(10) + 12;
			22  :	p1 := randint(3)  + 4;
			23  :	p1 := randint(3)  + 4;
			24  :	p1 := randint(3)  + 1;
			25  :	p1 := randint(10) + 6;
			26  :	p1 := randint(6)  + 6;
			otherwise ;
		    end
		  end;
{ Chimes }
	  chime :
		begin
		    case subval of
			1   :   p1 := randint(20) + 12;
			2   :   p1 := randint(8)  + 6;
			3   :   p1 := randint(5)  + 6;
			4   :   p1 := randint(4)  + 5;
			5   :   p1 := randint(5)  + 3;
			6   :   p1 := randint(3)  + 1;
			7   :   p1 := randint(10) + 10;
			8   :   p1 := randint(10) + 12;
			9   :   p1 := randint(5)  + 6;
			10  :   p1 := randint(5)  + 6;
			11  :   p1 := randint(5)  + 6;
			12  :   p1 := randint(5)  + 6;
			13  :   p1 := randint(3)  + 4;
			14  :   p1 := randint(3)  + 4;
			15  :   p1 := randint(3)  + 4;
			16  :   p1 := randint(10) + 6;
			otherwise ;
		    end
		  end;
{ Horns }
	 horn :
		begin
		    case subval of
			1   :   p1 := randint(10) + 6;
			2   :   p1 := randint(6)  + 3;
			3   :   p1 := randint(5)  + 6;
			4   :   p1 := randint(3)  + 1;
			5   :   p1 := randint(3)  + 4;
			6   :   p1 := randint(3)  + 4;
			7   :   p1 := randint(3)  + 4;
			8   :   p1 := randint(10) + 3;
			9   :   p1 := randint(5)  + 1;
			10  :   p1 := randint(3)  + 1;
			11  :   p1 := randint(3)  + 4;
			12  :   p1 := randint(3)  + 4;
			13  :   p1 := randint(8)  + 1;
			otherwise ;
		    end
		  end;
{ Cloaks }
	  cloak :
		begin
		    if magik(chance) then
		      begin
			if magik(special) then
			  case randint(9) of
		1..4	      : begin
				  name := name + ' of Protection';
				  toac := m_bonus(2,40,level);
				  cost := cost + 25000 + toac*10000;
				end;
		5..8	      : begin
				  toac := m_bonus(1,20,level);
				  p1 := randint(3);
				  flags := uor(stealth_worn_bit,flags);
				  name := name + ' of Stealth (%P1)';
				  cost := cost + p1*50000 + toac*10000;
				end;
		9	: begin
				  name := name + ' of Elvenkind';
				  p1 := 2; 
				  cost := cost + 200000;
				  flags := uor(flags,see_invisible_worn_bit+
						sustain_stat_worn_bit+
						stealth_worn_bit+
						charisma_worn_bit);
					end
			  end
			else
			  begin
			    toac := m_bonus(1,20,level);
			    cost := cost + toac+10000;
			  end;
		      end
		    else if (magik(cursed)) then
		      case randint(3) of
			1 : begin
			      flags := uor(flags,cursed_worn_bit+
						 aggravation_worn_bit);
			      name := name + ' of Irritation';
			      ac   :=  0;
			      toac  := -m_bonus(1,10,level);
			      tohit := -m_bonus(1,10,level);
			      todam := -m_bonus(1,10,level);
			      cost :=  0;
			    end;
			2 : begin
			      flags := uor(cursed_worn_bit,flags);
			      name := name + ' of Vulnerability';
			      ac   := 0;
			      toac := -m_bonus(10,100,level+50);
			      cost := 0;
			    end;
			3 : begin
			      flags := uor(cursed_worn_bit,flags);
			      name := name + ' of Enveloping';
			      toac  := -m_bonus(1,10,level);
			      tohit := -m_bonus(2,40,level+10);
			      todam := -m_bonus(2,40,level+10);
			      cost := 0;
			    end;
		      end;
		  end;
{ Chests }
	  chest :
		begin
		  If (subval = 5) then
		    name := name + '^ (Looted)'
		  else
		    case (randint(level)+4) of
		      1		: begin
				    name := name + '^ (Empty)';
				  end;
		      2		: begin
				    flags := uor(%X'00000001',flags);
				    name := name + '^ (Locked)';
				  end;
		      3,4	: begin
				    flags := uor(%X'00000011',flags);
				    name := name + '^ (Poison Needle)';
				  end;
		      5,6	: begin
				    flags := uor(%X'00000021',flags);
				    name := name + '^ (Poison Needle)';
				  end;
		      7,8,9	: begin
				    flags := uor(%X'00000041',flags);
				    name := name + '^ (Gas Trap)';
				  end;
		      10,11	: begin
				    flags := uor(%X'00000081',flags);
				    name := name + '^ (Explosion Device)';
				  end;
		      12,13,14	: begin
				    flags := uor(%X'00000101',flags);
				    name := name + '^ (Summoning Runes)';
				  end;
		      15,16,17	: begin
				    flags := uor(%X'00000071',flags);
				    name := name + '^ (Multiple Traps)';
				  end;
		      otherwise	  begin
				    flags := uor(%X'00000181',flags);
				    name := name + '^ (Multiple Traps)';
				  end;
		    end;
		  end;
{ Arrows, bolts, ammo, and spikes }
	sling_ammo, arrow, bolt, spike :
		begin
		  if (tval in [bolt,arrow]) then
		    if magik(chance) then
		      begin
			tohit := m_bonus(1,35,level);
			todam := m_bonus(1,35,level);
			if magik(special) then
			  case tval of	{CASE 1}
			 11,12 :  case randint(10) of	{CASE 2}
			   1,2,3 :begin
				    name := name + ' of Slaying';
				    tohit := tohit + 5;
				    todam := todam + 5;
				    cost := cost + 2000;
				  end;
			   4,5	 :begin
				    flags := uor(flags,flame_brand_worn_bit);
				    tohit := tohit + 2;
				    todam := todam + 4;
				    name := name + ' of Fire';
				    cost := cost + 2500;
				  end;
			   6,7	 :begin
				    flags := uor(flags,slay_evil_worn_bit);
				    tohit := tohit + 3;
				    todam := todam + 3;
				    name := name + ' of Slay Evil';
				    cost := cost + 2500;
				  end;
			   8,9	 :begin
				    flags := uor(flags,slay_monster_worn_bit);
				    tohit := tohit + 2;
				    todam := todam + 2;
				    name := name + ' of Slay Monster';
				    cost := cost + 3000;
				  end;
			   10	 :begin
				    flags := uor(flags,slay_dragon_worn_bit);
				    tohit := tohit + 10;
				    todam := todam + 10;
				    name := name + ' of Dragon Slaying';
				    cost := cost + 3500;
				  end;
				  end; {CASE 2}
		      otherwise ;
			  end;	{CASE 1}
		      end
		    else if (magik(cursed)) then
		      begin
			tohit := -m_bonus(5,55,level);
			todam := -m_bonus(5,55,level);
			flags := uor(cursed_worn_bit,flags);
			cost := 0;
		      end;
		    number := 0;
		    for i1 := 1 to 7 do number := number + randint(6);
		    missle_ctr := missle_ctr + 1;
		    if (missle_ctr > 65534) then
		      missle_ctr := 1;
		    subval := missle_ctr + 512;
		  end;
	    otherwise ;
	  end
      end;


	{ Places a particular trap at location y,x		-RAK-	}
[global,psect(misc4$code)] procedure place_trap(y,x,typ,subval : integer);
    var
	cur_pos			: integer;
	cur_trap		: treasure_type;
    begin
      if (typ = 1) then
	cur_trap := trap_lista[subval]
      else
	cur_trap := trap_listb[subval];
      popt(cur_pos);
      cave[y,x].tptr  := cur_pos;
      t_list[cur_pos] := cur_trap;
    end;


	{ Places rubble at location y,x				-RAK-	}
[global,psect(misc4$code)] procedure place_rubble(y,x : integer);
    var
	cur_pos			: integer;
    begin
      popt(cur_pos);
      with cave[y,x] do
	begin
	  tptr := cur_pos;
	  fopen := false;
	end;
      t_list[cur_pos] := some_rubble;
    end;


[global,psect(misc4$code)] procedure place_open_door(y,x : integer);
    var
	cur_pos			: integer;
  begin
    popt(cur_pos);
    with cave[y,x] do
      begin
	tptr := cur_pos;
	t_list[cur_pos] := door_list[1];
	fval  := corr_floor3.ftval;
	fopen := true;
      end;
  end;


[global,psect(misc4$code)] procedure place_broken_door(y,x : integer);
    var
	cur_pos			: integer;
  begin
    popt(cur_pos);
    with cave[y,x] do
      begin
	tptr := cur_pos;
	t_list[cur_pos] := door_list[1];
	fval  := corr_floor3.ftval;
	fopen := true;
	t_list[cur_pos].p1 := 1;
      end;
  end;


[global,psect(misc4$code)] procedure place_closed_door(y,x : integer);
    var
	cur_pos			: integer;
  begin
    popt(cur_pos);
    with cave[y,x] do
      begin
	tptr := cur_pos;
	t_list[cur_pos] := door_list[2];
	fval  := corr_floor3.ftval;
	fopen := false;
      end;
  end;


[global,psect(misc4$code)] procedure place_locked_door(y,x : integer);
    var
	cur_pos			: integer;
  begin
    popt(cur_pos);
    with cave[y,x] do
      begin
	tptr := cur_pos;
	t_list[cur_pos] := door_list[2];
	fval  := corr_floor3.ftval;
	fopen := false;
	t_list[cur_pos].p1 := randint(10) + 10;
      end;
  end;


[global,psect(misc4$code)] procedure place_stuck_door(y,x : integer);
    var
	cur_pos			: integer;
  begin
    popt(cur_pos);
    with cave[y,x] do
      begin
	tptr := cur_pos;
	t_list[cur_pos] := door_list[2];
	fval  := corr_floor3.ftval;
	fopen := false;
	t_list[cur_pos].p1 := -randint(10) - 10;
      end;
  end;


[global,psect(misc4$code)] procedure place_secret_door(y,x : integer);
    var
	cur_pos			: integer;
  begin
    popt(cur_pos);
    with cave[y,x] do
      begin
	tptr := cur_pos;
	t_list[cur_pos] := door_list[3];
	fval  := corr_floor4.ftval;
	fopen := false;
      end;
  end;


[global,psect(misc4$code)] procedure place_door(y,x : integer);
    var
	cur_pos			: integer;
  begin
    case randint(3) of
      1 : case randint(4) of
	    1		: place_broken_door(y,x);
	    otherwise	  place_open_door(y,x);
	  end;
      2 : case randint(12) of
	    1,2		: place_locked_door(y,x);
	    3		: place_stuck_door(y,x);
	    otherwise	  place_closed_door(y,x);
	  end;
      3 : place_secret_door(y,x);
    end;
  end;


	{ Place an up staircase at given y,x			-RAK-	}
[global,psect(misc4$code)] procedure place_a_staircase(y,x,typ : integer);
    var
	cur_pos				: integer;
    begin
      with cave[y,x] do
	if (tptr <> 0) then
	  begin
	    pusht(tptr);
	    tptr := 0;
	    fopen := true;
	  end;
      popt(cur_pos);
      cave[y,x].tptr := cur_pos;
      case (typ) of
	up_staircase : t_list[cur_pos] := up_stair;
	down_staircase : t_list[cur_pos] := down_stair;
	up_steep_staircase : t_list[cur_pos] := up_steep;
	down_steep_staircase : t_list[cur_pos] := down_steep;
      end;
    end;

	{ Places a staircase 1=up, 2=down			-RAK-	}
[global,psect(misc4$code)] procedure place_stairs(typ,num,walls : integer);
    var
	i1,i2,y1,x1,y2,x2		: integer;
	flag				: boolean;
    begin
      for i1 := 1 to num do
	  begin
	    flag := false;
	    repeat
	      i2 := 0;
	      repeat
		y1 := randint(cur_height - 12);
		x1 := randint(cur_width	 - 12);
		y2 := y1 + 12;
		x2 := x1 + 12;
		repeat
		  repeat
		    with cave[y1,x1] do
		      if (fval in [1,2,4]) then
			if (tptr = 0) then
			  if (next_to4(y1,x1,wall_set) >= walls) then
			    begin
			      flag := true;
			      place_a_staircase(y1,x1,typ);
			    end;
		    x1 := x1 + 1;
		  until ((x1 = x2) or (flag));
		  x1 := x2 - 12;
		  y1 := y1 + 1;
		until ((y1 = y2) or (flag));
		i2 := i2 + 1;
	      until ((flag) or (i2 > 30));
	      walls := walls - 1;
	    until(flag);
	  end;
    end;


	{ Places a treasure (Gold or Gems) at given row, column -RAK-	}
[global,psect(misc4$code)] procedure place_gold(y,x : integer);
    var
	cur_pos,i1		: integer;
    begin
      popt(cur_pos);
      i1 := (2+randint(dun_level+4)+randint(dun_level+4)) div 4;
      if (randint(obj_great) = 1) then
	i1 := i1 + randint(dun_level);
      if (i1 > max_gold) then
	i1 := max_gold + 1 - randint(randint(3));
      cave[y,x].tptr := cur_pos;
      t_list[cur_pos] := gold_list[i1];
      with t_list[cur_pos] do
	if (tval = valuable_metal) then
	  number := randint(number) + number div 2;
    end;


	{ Returns the array number of a random object		-RAK-	}
[global,psect(misc4$code)] function get_obj_num(level : integer) : integer;
    var
	i1	: integer;
    begin
      if (level > max_obj_level)  then level := max_obj_level;
      if (randint(obj_great) = 1) then level := max_obj_level;
      if (level = 0) then
	i1 := randint(t_level[0])
      else
	i1 := randint(t_level[level]);
      get_obj_num := i1;
    end;



	{ Places an object at given row, column co-ordinate	-RAK-	}
[global,psect(misc4$code)] procedure place_object(y,x : integer);
    var
	cur_pos				: integer;
	mag1,mag2			: integer;
    begin
      popt(cur_pos);
      cave[y,x].tptr := cur_pos;
      t_list[cur_pos] := object_list[get_obj_num(dun_level)];
      magic_treasure(cur_pos,dun_level);
    end;


	{ Allocates an object for tunnels and rooms		-RAK-	}
[global,psect(misc4$code)] procedure alloc_object      (
			alloc_set	:	obj_set;
			typ,num		:	integer
						);
    var
	i1,i2,i3		: integer;
    begin
      for i3 := 1 to num do
	begin
	  repeat
	    i1 := randint(cur_height);
	    i2 := randint(cur_width);
	  until ((cave[i1,i2].fval in alloc_set) and
		 (cave[i1,i2].tptr = 0));
	  case typ of
	    1 : place_trap(i1,i2,1,randint(max_trapa));
	    2 : place_trap(i1,i2,2,randint(max_trapb));
	    3 : place_rubble(i1,i2);
	    4 : place_gold(i1,i2);
	    5 : place_object(i1,i2);
	  end
	end
    end;


	{ Creates objects nearby the coordinates given		-RAK-	}
[global,psect(misc4$code)] procedure random_object(y,x,num : integer);
    var
	i1,i2,i3		: integer;
    begin
      repeat
	i1 := 0;
	repeat
	  i2 := y - 3 + randint(5);
	  i3 := x - 4 + randint(7);
	  with cave[i2,i3] do
	    if (fval in floor_set) then
	      if (tptr = 0) then
		begin
		  if (randint(100) < 75) then
		    place_object(i2,i3)
		  else
		    place_gold(i2,i3);
		  i1 := 9;
		end;
	  i1 := i1 + 1;
	until (i1 > 10);
	num := num - 1;
      until (num = 0);
    end;


	{ Converts stat num into string				-RAK-	}
[global,psect(misc5$code)] procedure cnv_stat  (
			stat		:	byteint;
			var out_val	:	stat_type
					);
    var
	tmp_str				: vtype;
	part1,part2			: integer;
    begin
      if (stat > 150) then
	begin
	  part1 := 18;
	  part2 := stat - 150;
	  writev(tmp_str,part1:2,'/',part2:1);
	end
      else
	writev(tmp_str,(3+(stat div 10)):2);
      if (length(tmp_str) < 6) then tmp_str := pad(tmp_str,' ',6);
      out_val := tmp_str;
      end;

[global,psect(misc5$code)] function spell_adj(attr : stat_set) : integer;
    begin
      with py.stat do
	if (c[attr] >249) then spell_adj := 7
	else if (c[attr] > 239) then spell_adj := 6
	else if (c[attr] > 219) then spell_adj := 5
	else if (c[attr] > 199) then spell_adj := 4
	else if (c[attr] > 149) then spell_adj := 3
	else if (c[attr] > 109) then spell_adj := 2
	else if (c[attr] >  39) then spell_adj := 1
	else spell_adj := 0
    end;

[global,psect(misc2$code)] function bard_adj : integer;
    begin
	bard_adj := (spell_adj(ca) +spell_adj(dx) + 1) div 2;
    end;

[global,psect(misc2$code)] function druid_adj : integer;
    begin
	druid_adj := (spell_adj(ca) + spell_adj(ws) + 1) div 2;
    end;

[global,psect(misc2$code)] function monk_adj : integer;
    begin
	monk_adj := (spell_adj(iq) + spell_adj(ws) + 1) div 2;
    end;

	{ Adjustment for charisma				-RAK-	}
	{ Percent decrease or increase in price of goods		}
[global,psect(misc2$code)] function chr_adj : real;
	var i1 : integer;
    begin
      with py.stat do
	if (c[ca] > 249) then chr_adj := -0.10
	else if (c[ca] > 239) then chr_adj := -0.08
	else if (c[ca] > 219) then chr_adj := -0.06
	else if (c[ca] > 199) then chr_adj := -0.04
	else if (c[ca] > 150) then chr_adj := -0.02
	else if (c[ca] >= 100) then chr_adj := 0.15 - (c[ca] div 10)/100
	else chr_adj := 0.25 - (c[ca] div 10)/50;
    end;

	{ Returns a character's adjustment to hit points	-JWT-	}
[global,psect(misc2$code)] function con_adj : integer;
  begin
    with py.stat do
      if      (c[cn] <	10) then con_adj := -4
      else if (c[cn] <	20) then con_adj := -3
      else if (c[cn] <	30) then con_adj := -2
      else if (c[cn] <	40) then con_adj := -1
      else if (c[cn] < 140) then con_adj :=  0
      else if (c[cn] < 150) then con_adj :=  1
      else if (c[cn] < 226) then con_adj :=  2
      else if (c[cn] < 299) then con_adj :=  3
      else			con_adj :=  4
  end;

	{ Calculates hit points for each level that is gained.	-RAK-	}
[global,psect(misc2$code)] function get_hitdie : integer;
    var
	i1	: integer;
    begin
      get_hitdie := randint(py.misc.hitdie) + con_adj;
    end;

	{ Return the ending to a number string (1st, 2nd, etc)	-DMF-	}
[global,psect(misc5$code)] function place_string(num : integer) : string;
    var
	out	: string;
    begin
      case num of
	1 : writev(out,num:1,'st');
	2 : writev(out,num:1,'nd');
	3 : writev(out,num:1,'rd');
	otherwise
	  begin
	    if (num < 20)
	      then writev(out,num:1,'th')
	      else case num mod 10 of
		     1 : writev(out,num:1,'st');
		     2 : writev(out,num:1,'nd');
		     3 : writev(out,num:1,'rd');
		     otherwise writev(out,num:1,'th');
		   end;
	  end;
      end;
      place_string := out;
    end;


	{ Return first X characters of day of week		-DMF-	}
[global,psect(misc5$code)] function day_of_week_string(
	day	: integer;
	wid	: integer) : string;
    begin
      case (day mod 7) of
	0 : day_of_week_string := substr('Saturday  ',1,wid);
	1 : day_of_week_string := substr('Sunday    ',1,wid);
	2 : day_of_week_string := substr('Monday    ',1,wid);
	3 : day_of_week_string := substr('Tuesday   ',1,wid);
	4 : day_of_week_string := substr('Wednesday ',1,wid);
	5 : day_of_week_string := substr('Thursday  ',1,wid);
	6 : day_of_week_string := substr('Friday    ',1,wid);
      end;
    end;


	{ Return the name of a numbered month			-DMF-	}
[global,psect(misc5$code)] function month_string(mon : integer) : string;
    begin
      case mon of
	1  : month_string := 'January';
	2  : month_string := 'February';
	3  : month_string := 'March';
	4  : month_string := 'April';
	5  : month_string := 'May';
	6  : month_string := 'June';
	7  : month_string := 'July';
	8  : month_string := 'August';
	9  : month_string := 'September';
	10 : month_string := 'October';
	11 : month_string := 'November';
	12 : month_string := 'December';
	13 : month_string := 'Moria';
      end;
    end;


	{ Return the time in the format HH:MM			-DMF-	}
[global,psect(misc5$code)] function time_string(
	hour	: integer;
	sec	: integer) : string;
    var
	out	: string;
	min	: integer;
    begin
      min := trunc(sec * 0.15);
      writev(out,hour:2,':',min:2);
      insert_str(out,' ','0');
      insert_str(out,' ','0');
      time_string := out;
    end;


	{ Return the difference of two time records		-DMF-	}
[global,psect(misc5$code)] procedure time_diff(
	a	: game_time_type;
	b	: game_time_type;
	var c	: game_time_type);
    begin
      if (a.secs < b.secs) then
	begin
	  a.secs := a.secs + 400;
	  a.hour := a.hour - 1;
	end;
      c.secs := a.secs - b.secs;
      if (a.hour < b.hour) then
	begin
	  a.hour := a.hour + 24;
	  a.day := a.day - 1;
	end;
      c.hour := a.hour - b.hour;
      if (a.day < b.day) then
	begin
	  a.day := a.day + 28;
	  a.month := a.month - 1;
	end;
      c.day := a.day - b.day;
      if (a.month < b.month) then
	begin
	  a.month := a.month + 13;
	  a.year := a.year - 1;
	end;
      c.month := a.month - b.month;
      c.year := a.year - b.year;
    end;


	{ Add days to the current date				-DMF-	}
[global,psect(misc5$code)] procedure add_days(
				var ti	: game_time_type;
				d	: integer);
    begin
      with ti do
	begin
	  day := day + d;
	  month := month + (day-1) div 28;
	  day := (day-1) mod 28 + 1;
	  year := year + (month-1) div 13;
	  month := (month-1) mod 13 + 1;
	end;
    end;


	{ Return string with entire date/time			-DMF-	}
[global,psect(misc5$code)] function full_date_string(time : game_time_type) : string;
    var
	out,out2	: string;
	pos		: integer;
    begin
      out := day_of_week_string(time.day,10);
      pos := index(out,' ');
      if (pos > 0) then
	out := substr(out,1,pos-1);
      with time do
	writev(out2,out,', ',month_string(month),' the ',
		    place_string(day),', ',time_string(hour,secs));
      full_date_string := out2;
    end;


	{ Advance the game clock by one 'second'		-DMF-	}
[global,psect(misc5$code)] procedure adv_time(flag : boolean);
      begin
	with py.misc.cur_age do
	  begin
	    secs := secs + 1;
	    if (secs > 399) then
	     begin
	      hour := hour + 1;
	      secs := 0;
	      if (hour = 24) then
	       begin
		day := day + 1;
		hour := 0;
		if (day = 29) then
		 begin
		  month := month + 1;
		  day := 1;
		  if (month = 14) then
		   begin
		    month := 1;
		    year := year + 1;
		   end;
		 end;
	       end;
	     end;
	    if (flag) and ((secs mod 100) = 0) then
	      begin
		prt_hp;
		if is_magii then prt_mana;
		prt_time;
	      end;
	  end;
      end;


	{ Return string for how long character has been playing	-DMF-	}
[global,psect(misc5$code)] function play_time(t : time_type) : string;
      var
	out,out2	: string;
      begin
	with t do
	  begin
	    writev(out,hours:2,':',minutes:2,':',seconds:2,'.',hundredths:2);
	    insert_str(out,' ','0');
	    insert_str(out,' ','0');
	    insert_str(out,' ','0');
	    insert_str(out,' ','0');
	    writev(out2,days:1,' days and ',out,' hours.');
	    if (days = 1) then insert_str(out,'days','day');
	  end;
	play_time := out2;
      end;


	{ Add two time_types together				-DMF-	}
[global,psect(misc5$code)] procedure add_play_time(
		var res	: time_type;
		add	: time_type);
      begin
	with res do
	  begin
	    days := days + add.days;
	    hours := hours + add.hours;
	    minutes := minutes + add.minutes;
	    seconds := seconds + add.seconds;
	    hundredths := hundredths + add.hundredths;
	    if hundredths > 100 then
	      begin
		hundredths := hundredths - 100;
		seconds := seconds + 1;
	      end;
	    if seconds > 60 then
	      begin
		seconds := seconds - 60;
		minutes := minutes + 1;
	      end;
	    if minutes > 60 then
	      begin
		minutes := minutes - 60;
		hours := hours + 1;
	      end;
	    if hours > 24 then
	      begin
		hours :=  hours - 24;
		days := days + 1;
	      end;
	  end;
      end;


	{ Return string for the age of the character		-DMF-	}
[global,psect(misc5$code)] function show_char_age : string;
      var
	dif	: game_time_type;
	out	: string;
      begin
	time_diff(py.misc.cur_age,py.misc.birth,dif);
	with dif do
	  begin
	    writev(out,'You are ',year:1,' years, ',month:1,' months, ',day:1,
		       ' days, and ',time_string(hour,secs),' hours old.');
	    if (year = 1) then insert_str(out,'years','year');
	    if (month = 1) then insert_str(out,'months','month');
	    if (day = 1) then insert_str(out,'days','day');
	  end;
	show_char_age := out;
      end;


	{ Return current time in the game			-DMF-	}
[global,psect(misc5$code)] function show_current_time : string;
      var
	current_time	: quad_type;
	out		: vtype;
      begin
	sys$gettim(current_time);
	sys$asctim(out.length,out.body,current_time);
	show_current_time := out;
      end;

    [external] procedure sub_quadtime(a,b,c : [reference] quad_type); extern;
  
	{ Return string for amount of play time			-DMF-	}
[global,psect(misc5$code)] function show_play_time : string;
      var
	tim			: time_type;
	current_time,delta_time	: quad_type;
      begin
	sys$gettim(current_time);
	sub_quadtime(current_time,start_time,delta_time);
	sys$numtim(tim,delta_time);
	add_play_time(tim,py.misc.play_tm);
	show_play_time := play_time(tim);
      end;


	{ Return description about the contents of a bag	-DMF-	}
[global,psect(misc5$code)] function bag_descrip(bag : treas_ptr) : string;
      var
	count,wgt	: integer;
	ptr		: treas_ptr;
	out,out2	: string;
      begin
	if (bag^.next = nil) or (bag^.next^.is_in = false) then
	  bag_descrip := ' (empty)'
	else
	  begin
	    ptr := bag^.next;
	    count := 0;
	    wgt := 0;
	    while (ptr <> nil) and (ptr^.is_in) do
	      begin
		count := count + ptr^.data.number;
		wgt := wgt + ptr^.data.weight * ptr^.data.number;
		ptr := ptr^.next;
	      end;
	    writev(out,' (',trunc(wgt * 100 / bag^.data.p1):1,'% full, containing ',count:1,' item');
	    if (count <> 1) then out := out + 's';
	    bag_descrip := out + ')';
	  end;
      end;

[global,psect(misc2$code)] function squish_stat(this : integer) : byteint;
    begin
	if (this > 250) then squish_stat := 250
	else if (this < 0) then squish_stat := 0
	else squish_stat := this
    end;


	{ Increases a stat by one randomized level		-RAK-	}
[global,psect(misc2$code)] function in_statp(stat : byteint) : byteint;
    begin
      if (stat < 150) then
	in_statp := 10
      else if (stat < 220) then
	in_statp := randint(25)
      else if (stat < 240) then
	in_statp := randint(10)
      else if (stat < 250) then
	in_statp := 1
      else
	in_statp := 0
    end;


	{ Decreases a stat by one randomized level		-RAK-	}
[global,psect(misc2$code)] function de_statp(stat : byteint) : byteint;
    var duh : byteint;
    begin
      if (stat < 11) then
	de_statp := stat
      else if (stat < 151) then
	de_statp := 10
      else if (stat < 241) then
	begin
	  duh := randint(10) + 5;
	  if (stat - duh < 150) then  duh := stat - 150;
	  de_statp := duh
	end
      else
	de_statp := randint(3);
    end;




	{ Returns a character's adjustment to hit.		-JWT-	}
[global,psect(misc2$code)] function tohit_adj : integer;
  var
	total			: integer;
  begin
    with py.stat do
      begin
	if	(c[dx] <  10) then total := -3
	else if (c[dx] <  30) then total := -2
	else if (c[dx] <  50) then total := -1
	else if (c[dx] < 130) then total :=  0
	else if (c[dx] < 140) then total :=  1
	else if (c[dx] < 150) then total :=  2
	else if (c[dx] < 201) then total :=  3
	else if (c[dx] < 250) then total :=  4
	else			  total :=  5;
	if	(c[sr] <  10) then total := total - 3
	else if (c[sr] <  20) then total := total - 2
	else if (c[sr] <  40) then total := total - 1
	else if (c[sr] < 150) then total := total + 0
	else if (c[sr] < 226) then total := total + 1
	else if (c[sr] < 241) then total := total + 2
	else if (c[sr] < 249) then total := total + 3
	else			  total := total + 4;
    end;
    tohit_adj := total;
  end;


	{ Returns a character's adjustment to armor class	-JWT-	}
[global,psect(misc2$code)] function toac_adj : integer;
  begin
    with py.stat do
      if      (c[dx] <	10) then toac_adj :=  -4
      else if (c[dx] <	20) then toac_adj :=  -3
      else if (c[dx] <	30) then toac_adj :=  -2
      else if (c[dx] <	40) then toac_adj :=  -1
      else if (c[dx] < 120) then toac_adj :=   0
      else if (c[dx] < 150) then toac_adj :=   1
      else if (c[dx] < 191) then toac_adj :=   2
      else if (c[dx] < 226) then toac_adj :=   3
      else if (c[dx] < 249) then toac_adj :=   4
      else			 toac_adj :=   5
  end;


	{ Returns a character's adjustment to disarm		-RAK-	}
[global,psect(misc2$code)] function todis_adj : integer;
  begin
    with py.stat do
      if      (c[dx] <	10) then todis_adj :=  -8
      else if (c[dx] <	20) then todis_adj :=  -6
      else if (c[dx] <	30) then todis_adj :=  -4
      else if (c[dx] <	40) then todis_adj :=  -2
      else if (c[dx] <	50) then todis_adj :=  -1
      else if (c[dx] < 100) then todis_adj :=   0
      else if (c[dx] < 130) then todis_adj :=   1
      else if (c[dx] < 150) then todis_adj :=   2
      else if (c[dx] < 191) then todis_adj :=   4
      else if (c[dx] < 226) then todis_adj :=   5
      else if (c[dx] < 249) then todis_adj :=   6
      else			 todis_adj :=   8
  end;


	{ Returns a character's adjustment to damage		-JWT-	}
[global,psect(misc2$code)] function todam_adj : integer;
  begin
    with py.stat do
      if      (c[sr] <	10) then todam_adj := -2
      else if (c[sr] <	20) then todam_adj := -1
      else if (c[sr] < 130) then todam_adj :=  0
      else if (c[sr] < 140) then todam_adj :=  1
      else if (c[sr] < 150) then todam_adj :=  2
      else if (c[sr] < 226) then todam_adj :=  3
      else if (c[sr] < 241) then todam_adj :=  4
      else if (c[sr] < 249) then todam_adj :=  5
      else			todam_adj :=  6;
  end;

	{ Returns a rating of x depending on y			-JWT-	}
[global,psect(create$code)] function likert(x,y : integer) : btype;
      begin
	if (trunc(x/y) < -3) then
	  likert := 'Very Bad'
	else
	  case trunc(x/y) of
	    -3,-2,-1	: likert := 'Very Bad';
	    0,1		: likert := 'Bad';
	    2		: likert := 'Poor';
	    3,4		: likert := 'Fair';
	    5		: likert := 'Good';
	    6		: likert := 'Very Good';
	    7,8		: likert := 'Superb';
	    otherwise	  likert := 'Excellent';
	  end
      end;


	{ Builds passwords					-RAK-	}
[global,psect(setup$code)] procedure bpswd;
      var
		i1		: integer;
      begin
	seed := wdata[1,0];
	{for i1 := 1 to 12 do}
        {lesser op password}
	  password1 := 'fragrance';{chr( uxor(wdata[1,i1],randint(255)) );}
	seed := wdata[2,0];
	{for i1 := 1 to 12 do}
        {full op password}
	  password2 := 'mopwillow';{chr( uxor(wdata[2,i1],randint(255)) );}
	seed := get_seed;
      end;

	{ Determine character's sex				-DCJ-	}
[global,psect(misc4$code)] function characters_sex : byteint ;
	begin

	  characters_sex := trunc((index(sex_type,py.misc.sex)+5)/6) ;

	end ;


	{ Determine character's maximum allowable weight	-DCJ-	}
[global,psect(misc4$code)] function max_allowable_weight : wordint ;
	begin

	  case characters_sex of
	    female	:
		max_allowable_weight := race[py.misc.prace].f_b_wt +
					4*race[py.misc.prace].f_m_wt ;
	    male	:
		max_allowable_weight := race[py.misc.prace].m_b_wt +
					4*race[py.misc.prace].m_m_wt ;
	  end ;

	end ;

	{ Determine character's minimum allowable weight	-DCJ-	}
[global,psect(misc4$code)] function min_allowable_weight : wordint ;
	begin

	  case characters_sex of
	    female	:
		min_allowable_weight := race[py.misc.prace].f_b_wt -
					4*race[py.misc.prace].f_m_wt ;
	    male	:
		min_allowable_weight := race[py.misc.prace].m_b_wt -
					4*race[py.misc.prace].m_m_wt ;
	  end ;

	end ;

	{ Computes current weight limit				-RAK-	}
[global,psect(misc4$code)] function weight_limit : integer;
      var
	weight_cap	: integer;
      begin
	weight_cap:=(py.stat.c[sr]+30)*player_weight_cap + py.misc.wt;
	if (weight_cap > 3000) then weight_cap := 3000;
	weight_cap := weight_cap + py.misc.xtr_wgt;
	weight_limit := weight_cap;
      end;


	{ Pick up some money					-DMF-	}
[global,psect(misc4$code)] function money_carry : treas_ptr;
      begin
	money_carry := inven_temp;
	with py.misc do
	 with inven_temp^.data do
	  begin
	    money[level] := money[level] + number;
	    reset_total_cash;
	    inven_weight := inven_weight + number * weight;
	  end;
	prt_gold;
	prt_weight;
      end;


	{ Return string describing how much the amount is worth	-DMF-	}
[global,psect(misc4$code)] function cost_str(amount : integer) : string;
    var
	out_val		: string;
    begin
      if (amount >= mithril$value) then
	writev(out_val,(amount div mithril$value):1,' mithril')
      else if (amount >= platinum$value) then
	writev(out_val,(amount div platinum$value):1,' platinum')
      else if (amount >= gold$value) then
	writev(out_val,(amount div gold$value):1,' gold')
      else if (amount >= silver$value) then
	writev(out_val,(amount div silver$value):1,' silver')
      else if (amount >= copper$value) then
	writev(out_val,(amount div copper$value):1,' copper')
      else
	writev(out_val,amount:1,' iron');
      cost_str := out_val;
    end;

[global,psect(misc4$code)] procedure reset_total_cash;
      var i1 : integer;
      begin
	with py.misc do
	  begin
	    money[total$] := 0;
	    for i1 := 1 to 6 do
	      money[total$]:=money[total$]+money[i1]*coin$value[i1];
	    money[total$] := money[total$] div gold$value;
	  end;
      end;


	{ Add money in the lightest possible amounts.		-DMF-/DY}
[global,psect(misc4$code)] procedure add_money(amount	: integer);
      var
	temp,to_bank,wl,i1	: integer;
	out_val			: string;
	type_num		: integer;
	coin_num		: integer;
      procedure add_munny(type_num : integer);
	var trans,w_max : integer;
	begin
	  coin_num := py.misc.money[type_num];
	  trans := amount div coin$value[type_num];
	  w_max := (wl*100-inven_weight) div coin$weight;
	  if (w_max < - coin_num) then
	    w_max := - coin_num;
	  if (w_max < trans) then
	    begin
	      to_bank := to_bank + (trans - w_max) * coin$value[type_num];
	      trans := w_max;
	    end;
	  inven_weight := inven_weight+coin$weight*trans;
	  py.misc.money[type_num] := coin_num + trans;
	  amount := amount mod coin$value[type_num];
	end;

      begin
	to_bank := 0;
	wl := weight_limit;
	with py.misc do
	 begin
	  for type_num := mithril downto iron do
	   add_munny(type_num);
	  reset_total_cash;
	  if (to_bank > 0) then
	    begin
	      msg_print('You cannot carry '+cost_str(to_bank)+
			' of the money');
	      if (get_yes_no('Do you wish to send a page to the bank with the excess money?')) then
		begin
		  i1 := (((95 * to_bank) div 100) div gold$value);
		  if (i1 < 5) then
		    msg_print('The page cannot be moved by such paltry sums of gold.')
		  else
		    if (randint(mugging_chance) = 1) then
		      begin
		        msg_print('The page is mugged!');
		        msg_print('The '+cost_str(to_bank)+' is lost!');
		      end
		    else
		      begin
		        bank[gold] := bank[gold] + i1;
			py.misc.account := py.misc.account + i1;
			bank[total$] := (bank[mithril]*coin$value[mithril]+
bank[platinum]*coin$value[platinum]) div gold$value + bank[gold];
			writev(out_val,i1:1);
			msg_print('The page deposits '+out_val+' gold at the bank for you.');
		      end;
		end
	      else  
		msg_print('You cannot carry the change, so it is lost.');
	    end;
	end;
      end;


	{ Give money to store, but can give back change		-DMF-/DY}
[global,psect(misc4$code)] procedure subtract_money(
			amount		: integer;
			make_change	: boolean);
      var
	amt,trans,temp	: integer;
	typ		: char;
	type_num : integer;

	function sub_munny(type_num : integer) : boolean;
	  var trans,coin_num : integer;
	  begin
	    coin_num := py.misc.money[type_num];
	    trans := (amt+coin$value[type_num]-1) div coin$value[type_num];
	    if (coin_num < trans) then trans := coin_num;
	    temp := temp + coin$weight*trans;
	    py.misc.money[type_num] := coin_num - trans;
	    amt := amt - trans*coin$value[type_num];
	    sub_munny := amt > 0;
	  end;

      begin
	temp := 0;
	amt := amount;
	type_num := 1;
	while (sub_munny(type_num) and (type_num < mithril)) do
	  type_num := type_num + 1;
	inven_weight := inven_weight - temp;
	reset_total_cash;
	if (make_change) then add_money(-amt);
      end;


	{ Send a page to the bank to fetch money		-DMF-	}
[global,psect(misc2$code)] function send_page(to_bank : integer) : boolean;
      var
	back		: boolean;
	from_bank	: integer;
	out_val		: string;

    procedure takey_munny(coin_value : integer; var bank_assets : integer);
      var trans : integer;
      begin
	trans := (to_bank*gold$value) div coin_value;
	if (bank_assets < trans) then trans := bank_assets;
	bank_assets := bank_assets - trans;
	from_bank := from_bank + (trans * coin_value) div gold$value;
	to_bank := to_bank - (trans * coin_value) div gold$value;
	py.misc.account := py.misc.account-(trans*coin_value) div gold$value;
      end;

      begin
	back := false;
	if (get_yes_no('Do you wish to send a page to the bank for money?')) then
	  begin
	    from_bank := 0;
	    if (py.misc.account < to_bank) then
	      msg_print('The page returns and says that your balance is too low.')
	    else if (bank[total$] < to_bank) then
	      msg_print('The page returns and says that the bank is out of money.')
	    else
	      begin
		takey_munny(coin$value[mithril],bank[mithril]);
		takey_munny(coin$value[platinum],bank[platinum]);
		takey_munny(gold$value,bank[gold]);
		if (randint(mugging_chance) = 1) then
		  begin
		    msg_print('The page was mugged while returning from the bank!');
		    writev(out_val,from_bank:1);
		    msg_print('You have lost '+out_val+' gold pieces!');
		  end
		else
		  begin
		    writev(out_val,from_bank:1);
		    msg_print('The page returns with '+out_val+' gold pieces.');
		    subtract_money(py.misc.money[total$] * gold$value,false);
		    back := true;
		  end;
	      end;
	    msg_print(' ');
	  end
	else
	  msg_print('You cannot buy that with the money you are carrying.');
	send_page := back;
      end;


	{ Returns spell chance of failure for spell		-RAK-	}
[global,psect(misc2$code)] procedure spell_chance(var spell : spl_rec);
      begin
	with magic_spell[py.misc.pclass,spell.splnum] do
	  with spell do
	    begin
	      splchn := sfail - 3*(py.misc.lev-slevel);
	      if (class[py.misc.pclass].mspell) then
		splchn := splchn - 3*(spell_adj(iq)-1)
	      else if (class[py.misc.pclass].bspell) then
		splchn := splchn - 3*(bard_adj-1)
	      else if (class[py.misc.pclass].dspell) then
		splchn := splchn - 3*(druid_adj-1)
	      else
		splchn := splchn - 3*(spell_adj(ws)-1);    
	      if (smana > py.misc.cmana) then
		splchn := splchn + 5*trunc(smana-py.misc.cmana);
	      if (splchn > 95) then
		splchn := 95
	      else if (splchn < 5) then
		splchn := 5;
	    end
      end;


	{ Print list of spells					-RAK-	}
[global,psect(misc2$code)] procedure print_new_spells(
			spell		:	spl_type;
			num		:	integer;
			var redraw	:	boolean
					);
    var
	i1				: integer;
	out_val				: vtype;

    begin
      redraw := true;
      clear(1,1);
      prt('   Name                          Level  Mana  %Failure',2,1);
      for i1 := 1 to num do
	with magic_spell[py.misc.pclass,spell[i1].splnum] do
	  if (i1 < 23) then
	  begin
	    spell_chance(spell[i1]);
	    writev(out_val,chr(96+i1),') ',pad(sname,' ',30),
		slevel:3,'    ',smana:3,'      ',spell[i1].splchn:2);
	    prt(out_val,2+i1,1);
	  end;
    end;



	{ Returns spell pointer					-RAK-	}
[global,psect(misc2$code)] function get_spell(spell : spl_type; num : integer;
		     var sn,sc : integer; prompt : vtype;
		     var redraw : boolean) : boolean;
    var
	i1				: integer;
	flag				: boolean;
	choice				: char;
	out_val1,out_val2		: vtype;
    begin
      sn := 0;
      flag := true;
      writev(out_val1,'(Spells a-',chr(num+96),
				', *,<space>=List, <ESCAPE>=exit) ',prompt);
      while (((sn < 1) or (sn > num)) and (flag)) do
	begin
	  prt(out_val1,1,1);
	  inkey(choice);
	  sn := ord(choice);
	  case sn of
	    0,3,25,26,27:	begin
			  flag := false;
{			  reset_flag := true;}
			end;
	    42,32      : print_new_spells(spell,num,redraw);
	    otherwise	sn := sn - 96;
	  end;
	end;
      msg_flag := false;
      if (flag) then
	begin
	  spell_chance(spell[sn]);
	  sc := spell[sn].splchn;
	  sn := spell[sn].splnum;
	end;
      get_spell := flag;
    end;

[global,psect(misc2$code)] function num_new_spells(smarts : integer) : integer;
      begin
	case (smarts) of
	  1..3	: num_new_spells := 1;
	  4,5	: num_new_spells := randint(2);
	  6	: num_new_spells := randint(3);
	  7	: num_new_spells := randint(2)+1;
	  otherwise num_new_spells := 0;
	end;
      end;

	{ Learn some magic spells (Mage)			-RAK-	}
[global,psect(misc2$code)] function learn_spell(var redraw : boolean) : boolean;
      var
	i2,i4				: unsigned;
	i1,i3,sn,sc			: integer;
	new_spells			: integer;
	spell_flag,spell_flag2		: unsigned;
	spell				: spl_type;
	curse				: treas_ptr;
      begin
	learn_spell := false;
	new_spells := num_new_spells(spell_adj(iq));
	i1 := 0;
	spell_flag := 0;
	spell_flag2 := 0;
	curse := inventory_list;
	while (curse <> nil) do
	  begin
	    if (curse^.data.tval = Magic_book) then
	      begin
	        spell_flag := uor(spell_flag,curse^.data.flags);
	        spell_flag2 := uor(spell_flag2,curse^.data.flags2);
	      end;
	    curse := curse^.next;
	  end;
	while ((new_spells > 0) and ((spell_flag > 0) or (spell_flag2 > 0))) do
	  begin
	    i1 := 0;
	    i2 := spell_flag;
	    i4 := spell_flag2;
	    repeat
	      i3 := bit_pos64(i4,i2);
	      if (i3 > 31) then i3 := i3 - 1;
	      with magic_spell[py.misc.pclass,i3] do
		if (slevel <= py.misc.lev) then
		  if (not(learned)) then
		    begin
		      i1 := i1 + 1;
		      spell[i1].splnum := i3;
		    end;
	    until((i2 = 0) and (i4 = 0));
	    if (i1 > 0) then
	      begin
		print_new_spells(spell,i1,redraw);
		if (get_spell(spell,i1,sn,sc,'Learn which spell?',redraw)) then
		  begin
		    magic_spell[py.misc.pclass,sn].learned := true;
		    learn_spell := true;
		    if (py.misc.mana = 0) then
		      begin
			py.misc.mana   := 1;
			py.misc.cmana := 1;
		      end;
		  end
		else
		  new_spells := 0;
	      end
	    else
	      new_spells := 0;
	    new_spells := new_spells - 1;
	  end;
      end;


	{ Learn some magic songs (Bard)			-Cap'n-	}
[global,psect(misc2$code)] function learn_song(var redraw : boolean) : boolean;
      var
	i2,i4				: unsigned;
	i1,i3,sn,sc			: integer;
	new_spells			: integer;
	spell_flag,spell_flag2		: unsigned;
	spell				: spl_type;
	curse				: treas_ptr;
      begin
	learn_song := false;
	new_spells := num_new_spells(bard_adj);
	i1 := 0;
	spell_flag := 0;
	spell_flag2 := 0;
	curse := inventory_list;
	while (curse <> nil) do
	  begin
	    if (curse^.data.tval = Song_book) then
	      begin
	        spell_flag := uor(spell_flag,curse^.data.flags);
	        spell_flag2 := uor(spell_flag2,curse^.data.flags2);
	      end;
	    curse := curse^.next;
	  end;
	while ((new_spells > 0) and ((spell_flag > 0) or (spell_flag2 > 0))) do
	  begin
	    i1 := 0;
	    i2 := spell_flag;
	    i4 := spell_flag2;
	    repeat
	      i3 := bit_pos64(i4,i2);
	      if (i3 > 31) then i3 := i3 - 1;
	      with magic_spell[py.misc.pclass,i3] do
		if (slevel <= py.misc.lev) then
		  if (not(learned)) then
		    begin
		      i1 := i1 + 1;
		      spell[i1].splnum := i3;
		    end;
	    until((i2 = 0) and (i4 = 0));
	    if (i1 > 0) then
	      begin
		print_new_spells(spell,i1,redraw);
		if (get_spell(spell,i1,sn,sc,'Learn which spell?',redraw)) then
		  begin
		    magic_spell[py.misc.pclass,sn].learned := true;
		    learn_song := true;
		    if (py.misc.mana = 0) then
		      begin
			py.misc.mana   := 1;
			py.misc.cmana := 1;
		      end;
		  end
		else
		  new_spells := 0;
	      end
	    else
	      new_spells := 0;
	    new_spells := new_spells - 1;
	  end;
      end;

	{ Learn some prayers (Priest)				-RAK-	}
[global,psect(misc2$code)] function learn_prayer : Boolean;
      var
	i1,i2,i3,i4,new_spell		: integer;
	test_array			: array [1..32] of integer;
	spell_flag,spell_flag2		: unsigned;
	curse				: treas_ptr;
      begin
	i1 := 0;
	spell_flag := 0;
	spell_flag2 := 0;
	curse := inventory_list;
	while (curse <> nil) do
	  begin
	    if (curse^.data.tval = Prayer_book) then
	      begin
	        spell_flag := uor(spell_flag,curse^.data.flags);
	        spell_flag2 := uor(spell_flag2,curse^.data.flags2);
	      end;
	    curse := curse^.next;
	  end;
	i1 := 0;
	while ((spell_flag > 0) or (spell_flag2 > 0)) do
	  begin
	    i2 := bit_pos64(spell_flag2,spell_flag);
	    if (i2 > 31) then i2 := i2 - 1;
	    with magic_spell[py.misc.pclass,i2] do
	      if (slevel <= py.misc.lev) then
		if (not(learned)) then
		  begin
		    i1 := i1 + 1;
		    test_array[i1] := i2;
		  end;
	  end;
	i2 := num_new_spells(spell_adj(ws));
	new_spell := 0;
	while ((i1 > 0) and (i2 > 0)) do
	  begin
	    i3 := randint(i1);
	    magic_spell[py.misc.pclass,test_array[i3]].learned := true;
	    new_spell := new_spell + 1;
	    for i4 := i3 to i1-1 do
	      test_array[i4] := test_array[i4+1];
	    i1 := i1 - 1;	{ One less spell to learn	}
	    i2 := i2 - 1;	{ Learned one			}
	  end;
	  if (new_spell > 0) then
	    begin
	      if (new_spell > 1) then
		msg_print('You learned new prayers!')
	      else
		msg_print('You learned a new prayer!');
	      if (py.misc.exp = 0) then msg_print(' ');
	      if (py.misc.mana = 0) then
		begin
		  py.misc.mana	:= 1;
		  py.misc.cmana := 1;
		end;
	      learn_prayer := true;
	    end
	  else
	    learn_prayer := false;
      end;


	{ Learn some disciplines (Monk)				-RAK-	}
[global,psect(misc2$code)] function learn_discipline : Boolean;
      var
	i1,i2,i3,i4,new_spell		: integer;
	test_array			: array [1..32] of integer;
	spell_flag,spell_flag2		: unsigned;
      begin
	i1 := 0;
	spell_flag := %X'00003FFF';
	spell_flag2 := %X'00000000';
	i1 := 0;
	while ((spell_flag > 0) or (spell_flag2 > 0)) do
	  begin
	    i2 := bit_pos64(spell_flag2,spell_flag);
	    if (i2 > 31) then i2 := i2 - 1;
	    with magic_spell[py.misc.pclass,i2] do
	      if (slevel <= py.misc.lev) then
		if (not(learned)) then
		  begin
		    i1 := i1 + 1;
		    test_array[i1] := i2;
		  end;
	  end;
	i2 := num_new_spells(monk_adj);
	new_spell := 0;
	while ((i1 > 0) and (i2 > 0)) do
	  begin
	    i3 := randint(i1);
	    magic_spell[py.misc.pclass,test_array[i3]].learned := true;
	    new_spell := new_spell + 1;
	    for i4 := i3 to i1-1 do
	      test_array[i4] := test_array[i4+1];
	    i1 := i1 - 1;	{ One less spell to learn	}
	    i2 := i2 - 1;	{ Learned one			}
	  end;
	  if (new_spell > 0) then
	    begin
	      if (new_spell > 1) then
		msg_print('You learned new disciplines!')
	      else
		msg_print('You learned a new discipline!');
	      if (py.misc.exp = 0) then msg_print(' ');
	      if (py.misc.mana = 0) then
		begin
		  py.misc.mana	:= 1;
		  py.misc.cmana := 1;
		end;
	      learn_discipline := true;
	    end
	  else
	    learn_discipline := false;
      end;

	{ Learn some druid spells (Druid)			-Cap'n-	}
[global,psect(misc2$code)] function learn_druid : Boolean;
      var
	i1,i2,i3,i4,new_spell		: integer;
	test_array			: array [1..32] of integer;
	spell_flag,spell_flag2		: unsigned;
	curse				: treas_ptr;
      begin
	i1 := 0;
	spell_flag := 0;
	spell_flag2 := 0;
	curse := inventory_list;
	while (curse <> nil) do
	  begin
	    if (curse^.data.tval = Instrument) then
	      begin
	        spell_flag := uor(spell_flag,curse^.data.flags);
	        spell_flag2 := uor(spell_flag2,curse^.data.flags2);
	      end;
	    curse := curse^.next;
	  end;
	i1 := 0;
	while ((spell_flag > 0) or (spell_flag2 > 0)) do
	  begin
	    i2 := bit_pos64(spell_flag2,spell_flag);
	    if (i2 > 31) then i2 := i2 - 1;
	    with magic_spell[py.misc.pclass,i2] do
	      if (slevel <= py.misc.lev) then
		if (not(learned)) then
		  begin
		    i1 := i1 + 1;
		    test_array[i1] := i2;
		  end;
	  end;
	i2 := num_new_spells(druid_adj);
	new_spell := 0;
	while ((i1 > 0) and (i2 > 0)) do
	  begin
	    i3 := randint(i1);
	    magic_spell[py.misc.pclass,test_array[i3]].learned := true;
	    new_spell := new_spell + 1;
	    for i4 := i3 to i1-1 do
	      test_array[i4] := test_array[i4+1];
	    i1 := i1 - 1;	{ One less spell to learn	}
	    i2 := i2 - 1;	{ Learned one			}
	  end;
	  if (new_spell > 0) then
	    begin
	      if (new_spell > 1) then
		msg_print('You learned new songs!')
	      else
		msg_print('You learned a new song!');
	      if (py.misc.exp = 0) then msg_print(' ');
	      if (py.misc.mana = 0) then
		begin
		  py.misc.mana	:= 1;
		  py.misc.cmana := 1;
		end;
	      learn_druid := true;
	    end
	  else
	    learn_druid := false;
      end;
			       
	{ Gain some mana if you know at least one spell 	-RAK-	}
[global,psect(misc2$code)] procedure gain_mana(amount : integer);
      var
	i1,new_mana			: integer;
	knows_spell			: boolean;
      begin
	knows_spell := false;
	for i1 := 1 to max_spells do
	  if (magic_spell[py.misc.pclass,i1].learned) then
	    knows_spell := true;
	if (knows_spell) then
	  begin
	    if (odd(py.misc.lev)) then
	      case amount of
		0 : new_mana := 0;
		1 : new_mana := 1;
		2 : new_mana := 1;
		3 : new_mana := 1;
		4 : new_mana := 2;
		5 : new_mana := 2;
		6 : new_mana := 3;
		7 : new_mana := 4;
		otherwise new_mana := 0;
	      end
	    else
	      case amount of
		0 : new_mana := 0;
		1 : new_mana := 1;
		2 : new_mana := 1;
		3 : new_mana := 2;
		4 : new_mana := 2;
		5 : new_mana := 3;
		6 : new_mana := 3;
		7 : new_mana := 4;
		otherwise new_mana := 0;
	      end;
	    py.misc.mana  := py.misc.mana  + new_mana;
	    py.misc.cmana := py.misc.cmana + new_mana;
	  end;
      end;


	{ Increases hit points and level			-RAK-	}
[global,psect(misc2$code)] procedure gain_level;
    var
	nhp,dif_exp,need_exp		: integer;
	redraw				: boolean;
	out_val				: vtype;
    begin
      with py.misc do
	  begin
	    nhp := get_hitdie;
	    mhp := mhp + nhp;
	    chp := chp + nhp;
	    if (mhp < 1) then
	      begin
		mhp := 1;
		chp := 1;
	      end;
	    lev := lev + 1;
	    need_exp := trunc(player_exp[lev]*expfact);
	    if (py.misc.exp > need_exp) then
	      begin
		dif_exp := py.misc.exp - need_exp;
		py.misc.exp := need_exp + (dif_exp div 2);
	      end;
	    title := player_title[pclass,lev];
	    writev(out_val,'Welcome to level ',lev:1,'.');
	    msg_print(out_val);
	    msg_print(' ');
	    msg_flag := false;
	    prt_hp;
	    prt_level;
	    prt_title;
	    with class[pclass] do
	      begin
		if (mspell) then
		  begin
		    redraw := false;
		    learn_spell(redraw);
		    if (redraw) then draw_cave;
		    gain_mana(spell_adj(iq));
		    prt_mana;
		  end
		else if (dspell) then
		  begin
		    learn_druid;
		    gain_mana(druid_adj);
		    prt_mana;
		  end
		else if (bspell) then
		  begin
		    redraw := false;
		    learn_song(redraw);
		    if (redraw) then draw_cave;
		    gain_mana(bard_adj);
		    prt_mana;
		  end
		else if (pspell) then
		  begin
		    learn_prayer;
		    gain_mana(spell_adj(ws));
		    prt_mana;
		  end
		else if (mental) then
		  begin
		    learn_discipline;
		    gain_mana(monk_adj);
		    prt_mana;
		  end;
	      end;
	  end;
    end;


  [global,psect(misc1$code)] procedure insert_num(
			var object_str	: varying[a] of char;
			mtc_str		: varying[b] of char;
			number		: integer;
			show_sign	: boolean
					);
    var
	pos,olen,mlen	: integer;
	str1,str2	: vtype;
    begin
      pos := index(object_str,mtc_str);
      if (pos > 0) then
	begin
	  olen := length(object_str);
	  mlen := length(mtc_str);
	  object_str := object_str + ' ';
	  str1 := substr(object_str,1,pos-1);
	  str2 := substr(object_str,pos+mlen,olen-(pos+mlen-1));
	  if ((number >= 0) and (show_sign)) then
	    writev(object_str,str1,'+',number:1,str2)
	  else
	    writev(object_str,str1,number:1,str2);
	end
    end;


	{ Checks to see if user is a wizard			-RAK-	}
[global,psect(wizard$code)] function check_pswd	(
		passw		: string;
		present		: boolean
						) : boolean;
      var
		i1		: integer;
		x		: char;
		tpw		: packed array [1..12] of char;
		account		: account_type;
		checked_out	: boolean;
      begin
	checked_out := false;
	if (present) then
	  tpw := passw
	else begin
	  i1 := 0;
	  tpw := '            ';
	  prt('Password : ',1,1);
	  repeat
	    inkey(x);
	    case ord(x) of
	      13  :       ;
	      otherwise   begin
			    i1 := i1 + 1;
			    tpw[i1] := x;
			  end
	    end;
	  until ((i1 = 12) or (ord(x) = 13));
	end;
	if (tpw = password1) then
	  begin
	    wizard1 := true;
	    checked_out := true;
	  end
	else if (tpw = password2) then
	  begin
	    wizard1 := true;
	    wizard2 := true;
	    checked_out := true;
	  end;
	if ( uw$id ) then
	  begin
	    get_account(account.body);
	    account.length := index( account.body, ' ' )-1;
	    if index( wizards, ':'+account+':' ) = 0 then
	       begin
		 wizard1 := false;
		 wizard2 := false;
		 checked_out := false;
	       end;
	  end;
	msg_flag := false;
	if not present then erase_line(msg_line,msg_line);
	py.misc.cheated := py.misc.cheated or checked_out;
	check_pswd := checked_out;
      end;


	{ Weapon weight VS strength and dexterity		-RAK-	}
[global,psect(moria$code)] function attack_blows(
			weight          :       integer;
			var wtohit      :       integer) : integer;
      var
	max_wield,adj_weight,blows,lev_skill      : integer;
      begin
	blows  := 1;
	wtohit := 0;
	with py.stat do
	  begin
	    max_wield := weight_limit div 10;		
 	    if (max_wield < (weight div 100)) then
{	make to-hit drop off gradually instead of being so abrupt	-DCJ-}
	      wtohit := max_wield - (weight div 100)
	    else
	      begin
		if      (c[dx] <  70) then blows := 3
		else if (c[dx] < 150) then blows := 4
		else if (c[dx] < 151) then blows := 5
		else if (c[dx] < 200) then blows := 6
		else if (c[dx] < 220) then blows := 7
			else if (c[dx] < 240) then blows := 8
		else if (c[dx] < 250) then blows := 10
		else 			   blows := 12;
		lev_skill := class[py.misc.pclass].mbth*(py.misc.lev+10);
{warriors 100-500, paladin 80-400, priest 60-300, mage 40-200}
		blows := trunc(0.8 + blows/3 + lev_skill/350);
{usually 3 for 18+ dex, 5 max except 6 for high level warriors}
		adj_weight := trunc(c[sr]/(weight div 100)*2.5);
		if (adj_weight < 1) then blows := 1
		else if (adj_weight < 2) then blows := trunc(blows/3.0)
		else if (adj_weight <3) then blows := trunc(blows/2.5)
		else if (adj_weight <5) then blows := trunc(blows/2.00)
		else if (adj_weight <10) then blows := trunc(blows/1.66)
		else                          blows := trunc(blows/1.50);
	      end;
	  end;
	attack_blows := blows;
      end;

	{ Critical hits, Nasty way to die...			-RAK-	}
[global,psect(moria$code)] function critical_blow(weight,plus :       integer;
				cs_sharp,is_fired : boolean) : integer;
      var randomthing, py_crit : integer;
      begin
	weight := weight div 100;
	critical_blow := 0;
	{ Weight of weapon, pluses to hit, and character level all      }
	{ contribute to the chance of a critical                        }
	if cs_sharp then
	  weight := weight + 600;
	with py.misc do
	  begin
	    if is_fired then
	      py_crit := class[pclass].mbthb
	    else
	      begin
		py_crit := class[pclass].mbth;
		if (pclass = 10) then	{ monks are crit specialists }
		  py_crit := py_crit*2
	      end;
	    if (randint(5000) <= (weight+6*plus+py_crit*(lev+10))) then
	      begin
		randomthing := randint(300 + randint(weight));
		if (randomthing <= 150) then
		  begin
		    critical_blow := 1;
		    msg_print('It was a good hit! (x2 damage)');
	          end
		else if (randomthing <= 250) then
		  begin
		    critical_blow := 2;
		    msg_print('It was an excellent hit! (x3 damage)');
		  end
		else if (randomthing <= 375) then
		  begin
		    critical_blow := 3;
		    msg_print('It was a superb hit! (x4 damage)');
		  end
		else if (randomthing <= 550) then
		  begin
		    critical_blow := 4;
		    msg_print('It was a *GREAT* hit! (x5 damage)');
		  end
		else if (randomthing < 700) then
		  begin
		    critical_blow := 6;
		    msg_print('It was an *INCREDIBLE* hit! (x7 damage)');
		  end
		else if (randomthing < 875) then
		  begin
		    critical_blow := 9;
		    msg_print('It was an *AMAZING* hit! (x10 damage)');
	          end
		else
		  begin
		    critical_blow := 14;
		    msg_print('It was a **PERFECT** hit! (x15 damage)');
	          end;
	      end;
	  end
      end;



	{ Given direction 'dir', returns new row, column location -RAK- }
[global,psect(misc1$code)] function move(dir : integer; var y,x : integer) : boolean;
      var
		new_row,new_col         : integer;
      begin
	new_row := y + dy_of[dir];
	new_col := x + dx_of[dir];
	move := false;
	if ((new_row >= 1) and (new_row <= cur_height)) then
	  if ((new_col >= 1) and (new_col <= cur_width)) then
	    begin
	      y := new_row;
	      x := new_col;
	      move := true;
	    end
      end;


	{ Saving throws for player character... 		-RAK-	}
[global,psect(moria$code)] function player_saves(adjust : integer) : boolean;
	begin
	  player_saves := (randint(100) <= py.misc.save + adjust) AND
		(randint(20) <> 1)
	end;

[global,psect(moria$code)] function player_spell_saves : boolean;
	begin
	  player_spell_saves := player_saves(py.misc.lev + 5 * spell_adj(ws))
	end;

	{ Init players with some belongings			-RAK-	}
[global,psect(setup$code)] procedure char_inven_init;
      var
	i1,i2,dummy             : integer;
      begin
	inventory_list := nil;
	for i1 := equipment_min to equip_max-1 do
	  equipment[i1].tval := 0;
	for i1 := 1 to 5 do
	  begin
	    i2 := player_init[py.misc.pclass,i1];
	    inven_temp^.data := inventory_init[i2];
	    inven_carry;
	  end;
      end;

[global,psect(moria$code)] procedure find_monster_name(
		var m_name	: vtype;
		ptr		: integer;
		begin_sentence	: boolean);
      var
	i2	: integer;
      begin
	i2 := m_list[ptr].mptr;
		{ Does the player know what he's fighting?      }
	if (((uand(%X'10000',c_list[i2].cmove) <> 0) and
	     (not(py.flags.see_inv))) or (py.flags.blind > 0) or
	     (not(m_list[ptr].ml))) then
	  if begin_sentence then
	    m_name := 'It'
	  else
	    m_name := 'it'
	else
	  if begin_sentence then
	    m_name := 'The ' + c_list[i2].name
	  else
	    m_name := 'the ' + c_list[i2].name;
      end;


	{ Check for kicking people out of the game		-DMF-	}
      [global,psect(moria$code)] procedure check_kickout_time(num,check : integer);
	begin
	  if ((num mod check) = 1) then
	    if (check_kickout) then
	      begin
	        find_flag := false;
	        msg_print('A new version of IMORIA is being installed.');
	        msg_print('After your character is saved, wait a few minutes,');
	        msg_print('And then try to run the game.');
	        msg_print('');
	        repeat
		  py.flags.dead := false;
	          save_char(true);
	        until(false);
	      end;
	end;
End.
