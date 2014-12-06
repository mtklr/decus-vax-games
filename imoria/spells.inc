
{ Following are spell procedure/functions			-RAK-	}
{ These routines are commonly used in the scroll, potion, wands, and	}
{ staves routines, and are occassionly called from other areas.		}
{ Now included are creature spells also...			-RAK	}

	{ Creates an area of water on open floor		-Cap'n- }
[global,psect(misc6$code)] function create_water(y,x : integer) : boolean;
	begin
	  create_water := true;
	end;

	{ Makes an area of water into open floor		-Cap'n- }
[global,psect(misc6$code)] function destroy_water(y,x : integer) : boolean;
	begin
	  destroy_water := true;
	end;

	{ Does a petrify attack on the fool that used the bad item -Capn-}
[global,psect(misc6$code)] function item_petrify : boolean;
	begin
	  item_petrify := true;
	end;

[global,psect(misc6$code)] function mon_resists(a_cptr : byteint) : boolean;
	var 
		res_chance : integer;
		delta_lev  : integer;
	begin
	  with m_list[a_cptr] do
	    with c_list[mptr] do
	      begin
		res_chance := mr;
		delta_lev := (py.misc.lev + py.misc.mr);
		if (delta_lev < 0) then delta_lev := 0;
		res_chance := res_chance - (5 * delta_lev);
		if (res_chance < 0) then res_chance := 0;
		if (res_chance >= randint(100)) then
		  begin
		    msg_print('The '+name+' is protected by a mysterious force.');
		    mon_resists := true;
		  end
		else 
		  mon_resists := false;
	      end;
 	end;

[global,psect(misc6$code)] function mon_save(a_cptr,bonus,
					spell_class : integer) : boolean;
	var res_chance : integer;
	begin
	  with m_list[a_cptr] do
	    with c_list[mptr] do
	      begin
		if (uand(%X'1000',cdefense)<>0) then
		  case (spell_class) of
		    c_sc_hold : bonus := bonus + 4;
		    c_sc_mental : bonus := bonus + 20;
		    otherwise ;
		    end;
	        mon_save := 20+level+randint(level)+5*bonus >
				randint(80)+randint(py.misc.lev);
	      end;
	end;

function do_stun(a_cptr : byteint; save_bonus,time : integer) : boolean;
	var    held	: integer;
	       m_name	: vtype;
	begin
	  do_stun := true;
	  with m_list[a_cptr] do
	    begin
		find_monster_name(m_name,a_cptr,true);
		if (not mon_resists(a_cptr)) then
	  	if (not mon_save(a_cptr,save_bonus,c_sc_hold)) then
	    	  begin
		    do_stun := true;
		    msg_print(m_name+' appears stunned!');
	            held := stunned + 1 + randint(time);
	            if (held > 24) then
		      stunned := 24
		    else
		      stunned := held;
	          end;
	    end;
	end;




	{ Sleep creatures adjacent to player			-RAK-	}
[global,psect(misc6$code)] function sleep_monsters1(y,x : integer) : boolean;
      var
		i1,i2		: integer;
      begin
	sleep_monsters1 := false;
	for i1 := y-1 to y+1 do
	  for i2 := x-1 to x+1 do
	    with cave[i1,i2] do
	      if (cptr > 1) then
		with m_list[cptr] do
		  with c_list[mptr] do
		    if (not mon_resists(cptr)) then
		    begin
		      sleep_monsters1 := true;
		      if (mon_save(cptr,0,c_sc_mental)) then
			msg_print('The ' + name + ' is unaffected.')
		      else
			begin
			  msg_print('The ' + name + ' falls asleep.');
			  csleep := 500;
			end;
		    end;
      end;

	{ Detect treasure or object on current panel	-Steven-}
[global,psect(misc6$code)] function detect_item(typ : integer) : boolean;
      var
		i1,i2		: integer;
		show_it		: boolean;
      begin
	detect_item := false;
	for i1 := panel_row_min to panel_row_max do
	  for i2 := panel_col_min to panel_col_max do
	    with cave[i1,i2] do
	      if (tptr > 0) then
		begin
		  if (typ=c_treasure) then
		    show_it := t_list[tptr].tval in
			[valuable_metal,valuable_gems,valuable_jewelry]
		  else
		    show_it := t_list[tptr].tval < valuable_metal;
		  if (show_it) then
		   if (not (test_light(i1,i2))) then
		    begin
		      lite_spot(i1,i2);
		      tl := true;
		      detect_item := true;
		    end;
		end;
      end;


	{ Locates and displays traps on current panel		-RAK-	}
[global,psect(misc6$code)] function detect_trap : boolean;
      var
		i1,i2		: integer;
      begin
	detect_trap := false;
	for i1 := panel_row_min to panel_row_max do
	  for i2 := panel_col_min to panel_col_max do
	    with cave[i1,i2] do
	      if (tptr > 0) then
		if (t_list[tptr].tval = Unseen_trap) then
		  begin
		    change_trap(i1,i2);
		    fm := true;
		    detect_trap := true;
		  end
		else if (t_list[tptr].tval = chest) then
		  with t_list[tptr] do
		    known2(name);
      end;

	{ Locates and displays all secret doors on current panel -RAK-	}
[global,psect(misc6$code)] function detect_sdoor : boolean;
      var
		i1,i2		: integer;
      begin
	detect_sdoor := false;
	for i1 := panel_row_min to panel_row_max do
	  for i2 := panel_col_min to panel_col_max do
	    with cave[i1,i2] do
	      if (tptr > 0) then
		{ Secret doors	}
		if (t_list[tptr].tval = Secret_door) then
		  begin
		    fval := corr_floor3.ftval;
		    change_trap(i1,i2);
		    fm := true;
		    detect_sdoor := true;
		  end
		{ Staircases	}
		else if (t_list[tptr].tval in [Up_staircase,Down_staircase,
				up_steep_staircase,down_steep_staircase]) then
		  if (not(fm)) then
		    begin
		      fm := true;
		      lite_spot(i1,i2);
		      detect_sdoor := true;
		    end;
      end;

	{ Light an area: 1.  If corridor then light immediate area -RAK-}
	{		 2.  If room then light entire room.		}
[global,psect(misc6$code)] function light_area(y,x : integer) : boolean;
      var
		i1,i2		: integer;
      begin
	msg_print('You are surrounded by a white light.');
	light_area := true;
	if ((cave[y,x].fval in [1,2,17,18]) and (dun_level > 0)) then
	  light_room(y,x)
	else
	  for i1 := y-1 to y+1 do
	    for i2 := x-1 to x+1 do
	      if (in_bounds(i1,i2)) then
		begin
		  if (not (test_light(i1,i2))) then
		    lite_spot(i1,i2);
		  cave[i1,i2].pl := true;
		end;
      end;

	{ Darken an area, opposite of light area		-RAK-	}
[global,psect(misc6$code)] function unlight_area(y,x : integer) : boolean;
      var
	i1,i2,i3,tmp1,tmp2		: integer;
	start_row,start_col		: integer;
	end_row,end_col			: integer;
	flag				: boolean;
      begin
	flag := false;
	if ((cave[y,x].fval in [1,2,17,18]) and (dun_level > 0)) then
	  begin
	    tmp1 := trunc(screen_height/2);
	    tmp2 := trunc(screen_width /2);
	    start_row := trunc(y/tmp1)*tmp1 + 1;
	    start_col := trunc(x/tmp2)*tmp2 + 1;
	    end_row := start_row + tmp1 - 1;
	    end_col := start_col + tmp2 - 1;
	    for i1 := start_row to end_row do
	      begin
		out_val := '';
		i3 := 0;
		for i2 := start_col to end_col do
		  with cave[i1,i2] do
		    if (fval in [1,2,17,18]) then
		      begin
			pl := false;
			fval := 1;
			if (not(test_light(i1,i2))) then
			  begin
			    if (i3 = 0) then
			      i3 := i2;
			    out_val := out_val + ' ';
			  end
			else if (i3 > 0) then
			  begin
			    flag := true;
			    print(out_val,i1,i3);
			    out_val := '';
			    i3 := 0;
			  end;
		      end
		    else if (i3 > 0) then
		      begin
			flag := true;
			print(out_val,i1,i3);
			out_val := '';
			i3 := 0;
		      end;
		if (i3 > 0) then
		  begin
		    flag := true;
		    print(out_val,i1,i3);
		  end;
	      end;
	  end
	else
	  for i1 := y-1 to y+1 do
	    for i2 := x-1 to x+1 do
	      if (in_bounds(i1,i2)) then
		with cave[i1,i2] do
		  if (fval in [4,5,6]) then
		    if (pl) then
		      begin
			pl := false;
			flag := true;
		      end;
	if (flag) then
	  begin
	    msg_print('Darkness surrounds you...');
	    unlight_area := true;
	  end
	else
	  unlight_area := false;
      end;

	{ Map the current area plus some			-RAK-	}
[global,psect(misc6$code)] function map_area : boolean;
      var
		i1,i2,i3,i4,i5,i6,i7,i8		: integer;
      begin
	map_area := true;
	i1 := panel_row_min - randint(10);
	i2 := panel_row_max + randint(10);
	i3 := panel_col_min - randint(20);
	i4 := panel_col_max + randint(20);
	for i5 := i1 to i2 do
	  for i6 := i3 to i4 do
	    if (in_bounds(i5,i6)) then
	      if (cave[i5,i6].fval in floor_set) then
		for i7 := i5-1 to i5+1 do
		  for i8 := i6-1 to i6+1 do
		    with cave[i7,i8] do
		      if (fval in pwall_set) then
			pl := true
		      else if (tptr > 0) then
			if (t_list[tptr].tval in light_set) then
			  fm := true;
	prt_map;
      end;

	{ Identify an object					-RAK-	}
[global,psect(misc6$code)] function ident_spell : boolean;
      var
		item_ptr		: treas_ptr;
		out_val			: vtype;
		redraw			: boolean;
      begin
	ident_spell := false;
	redraw := false;
	change_all_ok_stats(true,true);
	if (get_item(item_ptr,'Item you wish identified?',
				redraw,inven_ctr,trash_char,false)) then
	  with item_ptr^.data do
	    begin
	      ident_spell := true;
	      identify(item_ptr^.data);
	      known2(name);
	      objdes(out_val,item_ptr,true);
	      msg_print(out_val);
	    end;
	if (redraw) then
	  begin
	    msg_print(' ');
	    draw_cave;
	  end;
      end;

	{ Get all the monsters on the level pissed off...	-RAK-	}
[global,psect(misc6$code)] function aggravate_monster	(
			dis_affect		:	integer
						) : boolean;
      var
		i1		: integer;
      begin
	aggravate_monster := true;
	i1 := muptr;
	repeat
	  with m_list[i1] do
	    begin
	      csleep := 0;
	      if (cdis <= dis_affect) then
		if (cspeed < 2) then
		  cspeed := cspeed + 1;
	    end;
	  i1 := m_list[i1].nptr;
	until(i1 = 0);
      end;

	{ Surround the fool with traps (chuckle)		-RAK-	}
[global,psect(misc6$code)] function trap_creation : boolean;
      var
		i1,i2		: integer;
      begin
	trap_creation := true;
	for i1 := char_row-1 to char_row+1 do
	  for i2 := char_col-1 to char_col+1 do
	    with cave[i1,i2] do
	      if (fval in floor_set) then
		begin
		  if (tptr > 0) then
		    delete_object(i1,i2);
		  place_trap(i1,i2,1,randint(max_trapa));
		end;
      end;

	{ Surround the player with doors...			-RAK-	}
[global,psect(misc6$code)] function door_creation : boolean;
      var
		i1,i2,i3	: integer;
      begin
	door_creation := true;
	for i1 := char_row-1 to char_row+1 do
	  for i2 := char_col-1 to char_col+1 do
	    if ((i1 <> char_row) or (i2 <> char_col)) then
	      with cave[i1,i2] do
		if (fval in floor_set) then
		  begin
		    popt(i3);
		    if (tptr > 0) then
		      delete_object(i1,i2);
		    fopen := false;
		    tptr := i3;
		    t_list[i3] := door_list[2];
		    if (test_light(i1,i2)) then
		      lite_spot(i1,i2);
		  end;
      end;

	{ Destroys any adjacent door(s)/trap(s)			-RAK-	}
[global,psect(misc6$code)] function td_destroy : boolean;
      var
		i1,i2		: integer;
      begin
	td_destroy := false;
	for i1 := char_row-1 to char_row+1 do
	  for i2 := char_col-1 to char_col+1 do
	    with cave[i1,i2] do
	      if (tptr > 0) then
		if (t_list[tptr].tval in [Unseen_trap,Seen_trap,Open_door,
					  Closed_door,Secret_door]) then
		  begin
		    if (delete_object(i1,i2)) then
		      td_destroy := true;
		  end;
      end;


	{ Leave a line of light in given dir, blue light can sometimes	}
	{ hurt creatures...					-RAK-	}
[global,psect(misc6$code)] function light_line(dir,y,x,power:integer):boolean;
      begin
	light_line := true;
	while (cave[y,x].fopen) do
	  begin
	    with cave[y,x] do
	      begin
		if (panel_contains(y,x)) then
		  begin
		    if (not((tl) or (pl))) then
		      if (fval = 2) then
			light_room(y,x)
		      else
			lite_spot(y,x);
		    if (cptr > 1) then
		      with m_list[cptr] do
			with c_list[mptr] do
			  if (not mon_resists(cptr)) then
			  if (uand(%X'0100',cdefense) <> 0) then
			    begin
			      msg_print('The ' + name + ' wails out in pain!');
			      i1 := 0;
			      for i2 := 1 to power do
				i1 := i1 + mon_take_hit(cptr,damroll('2d8'));
			      if (i1 > 0) then
				msg_print('The ' + name +
						' dies in a fit of agony.');
			    end;
		  end;
		pl := true;
	      end;
	    move(dir,y,x);
	  end;
      end;


	{ Light line in all directions				-RAK-	}
[global,psect(misc6$code)] function starlite(y,x : integer) : boolean;
      var
	i1	: integer;
      begin
	starlite := true;
	for i1 := 1 to 9 do
	  if (i1 <> 5) then
	    light_line(i1,y,x,2);
      end;


	{ Disarms all traps/chests in a given direction		-RAK-	}
[global,psect(misc6$code)] function disarm_all(dir,y,x : integer) : boolean;
      var
	i1,oldy,oldx		: integer;
      begin
	disarm_all := false;
	repeat
	  with cave[y,x] do
	    begin
	      if (tptr > 0) then
		with t_list[tptr] do
		  if (tval in [Unseen_trap,Seen_trap]) then
		    begin
		      if (delete_object(y,x)) then
			disarm_all := true;
		    end
		  else if (tval = Closed_door) then
		    p1 := 0
		  else if (tval = Secret_door) then
		    begin
		      fval := corr_floor3.ftval;
		      change_trap(y,x);
		      fm := true;
		      disarm_all := true;
		    end
		  else if (tval = Chest) then
		    if (flags > 0) then
		      begin
			msg_print('Click!');
			flags := 0;
			disarm_all := true;
			i1 := index(name,' (');
			if (i1 > 0) then
			  name := substr(name,1,i1-1);
			name := name + ' (Unlocked)';
			known2(name);
		      end;
	    end;
	  oldy := y;
	  oldx := x;
	  move(dir,y,x);
	until(not(cave[oldy,oldx].fopen))
      end;

function am_i_dumb : boolean;
      begin
	am_i_dumb := py.misc.lev < randint(randint(50));
      end;
	{ Looks to see if item is cursed			-Cap'n-	}
[global,psect(misc6$code)] function detect_curse : boolean;
      var
		item_ptr	: treas_ptr;
		redraw		: boolean;
      begin
	detect_curse := false;
	redraw := false;
	change_all_ok_stats(true,true);
	if (get_item(item_ptr,'Item you wish to examine?',
			redraw,inven_ctr,trash_char,false)) then
	  begin
	    with item_ptr^.data do
	      if (uand(cursed_worn_bit,flags) <> 0) then
	        begin
		  flags2 := uor(flags2,known_cursed_bit);
		  msg_print('The item is cursed!');
	        end
	      else
	        msg_print('This item is not cursed.');
	      detect_curse := true;
	  end;
	if (redraw) then
	  begin
	    msg_print(' ');
	    draw_cave;
	  end;
      end;

	{ Return flags for given type area affect		-RAK-	}
[global,psect(misc6$code)] procedure get_flags (
			typ				: integer;
			var weapon_type,harm_type	: integer;
			var destroy			: obj_set
					);
      begin
	    case typ of
	c_lightning  :  begin {1}
		weapon_type := %X'00080000';
		harm_type   := %X'0100';
		destroy	    := [ring,rod,wand];
	      end;
	c_gas  :  begin	{2}
		weapon_type := %X'00100000';
		harm_type   := %X'0040';
		destroy	    := [];
	      end;
	c_acid  :  begin {3}
		weapon_type := %X'00200000';
		harm_type   := %X'0080';
		destroy	    := [arrow,bow_crossbow_or_sling,hafted_weapon,
				pole_arm,boots,gloves_and_gauntlets,cloak,helm,
				gem_helm,staff,shield,hard_armor,soft_armor,
				scroll1,scroll2,food,Open_door,Closed_door];
	      end;
	c_cold  :  begin {4}
		weapon_type := %X'00400000';
		harm_type   := %X'0010';
		destroy	    := [potion1,potion2];
	      end;
	c_fire  :  begin {5}
		weapon_type := %X'00800000';
		harm_type   := %X'0020';
		destroy	    := [arrow,bow_crossbow_or_sling,hafted_weapon,
				pole_arm,boots,gloves_and_gauntlets,cloak,
				soft_armor,staff,scroll1,scroll2,
				potion1,potion2,food,Open_door,Closed_door];
	      end;
	c_good  :  begin {6}
		weapon_type := %X'00000000';
		harm_type   := %X'0004';
		destroy	    := [];
	      end;
	c_evil  :  begin {7}
		weapon_type := %X'00000000';
		harm_type   := %X'0000';
		destroy	    := [];
	      end;
	c_petrify  :  begin {8}
		weapon_type := %X'00000000';
		harm_type   := %X'0000';
		destroy	    := [potion1,potion2,soft_armor,boots,food];
	       end;
	c_sunray :  begin {9}
		weapon_type := %X'00000000';
		harm_type   := %X'0108';
		destroy	    := [potion1,potion2,scroll1,scroll2,cloak];
	      end;
	otherwise begin
		    weapon_type := 0;
		    harm_type	:= 0;
		    destroy	:= [];
		  end;
	end;
      end;

function bolt_to_creature(dir : integer; var y,x,dist : integer;
		max_dist : integer; visable : boolean) : boolean;
      var
		hit_creature    : boolean;
		oldx,oldy	: integer;
      begin
	hit_creature := false;
	repeat
	  oldy := y;
	  oldx := x;
	  move(dir,y,x);
	  dist := dist + 1;
	  if visable then	{ erase bolt }
	    if test_light(oldy,oldx) then
	      lite_spot(oldy,oldx)
	    else
	      unlite_spot(oldy,oldx);
	  if (dist <= max_dist) then
	    with cave[y,x] do
	      if (fopen) then
		begin
		  hit_creature := (cptr > 1);
		  if (visable and (not hit_creature)) then
		    if panel_contains(y,x) then
		      print('*',y,x);	{ draw bolt }
		end; 
	until ((not cave[y,x].fopen) or (dist > max_dist) or hit_creature);
	bolt_to_creature := hit_creature;
      end;

function move_to_creature(dir : integer; var y,x : integer) : boolean;
      var
		hit_creature	: boolean;
		dist		: integer;
      begin
	dist := 0;
	move_to_creature := bolt_to_creature(dir,y,x,dist,999,false);
      end;

	{ Determine whether an item is magical or not		-Cap'n-	}
[global,psect(misc6$code)] function detect_magic : boolean;
      var
		item_ptr		: treas_ptr;
		redraw,dumb,dumber	: boolean;
      begin
	detect_magic := false;
	redraw := false;
	dumb := am_i_dumb;
	dumber := dumb and am_i_dumb;
	change_all_ok_stats(true,true);
	if (get_item(item_ptr,'Item you wish to examine?',
			redraw,inven_ctr,trash_char,false)) then
	  begin
	    with item_ptr^.data do
	      if ((((flags<>0) or (tohit>0) or (todam>0) or (toac>0)) and
		 not dumb) or dumber) then
		msg_print('The item seems magical!')
	      else
		msg_print('The item does not seem to be magical...');
	    detect_magic := true;
	  end;
	if (redraw) then
	  begin
	    msg_print(' ');
	    draw_cave;
	  end;
      end;


{ Give name for most items in inventory				-Cap'n-	}
[global,psect(misc6$code)] function lore_spell : boolean;
      var
		redraw			: boolean;
		thingy			: treas_ptr;
      begin
	lore_spell := true;
	thingy := inventory_list;
	while (thingy <> nil) do
	  begin
	    if (not am_i_dumb) then 
	      begin
		identify(thingy^.data);
		known2(thingy^.data.name);
	      end;
 	    thingy := thingy^.next;
	  end;
      end;


	{ Shoot a bolt in a given direction			-RAK-	}
[global,psect(misc6$code)] function fire_bolt	(
			typ,dir,y,x,dam : integer;
			bolt_typ	: ctype
					) : boolean;
      var
	i1,oldy,oldx,dist		: integer;
	weapon_type,harm_type		: integer;
	dummy				: obj_set;
	str,str2			: vtype;

    function ill_joke(a_cptr : integer) : boolean;
      var  i2 : integer;
      begin
	ill_joke := true;
	find_monster_name(str,a_cptr,false);
	find_monster_name(str2,a_cptr,true);
	with m_list[a_cptr] do
	  with c_list[mptr] do
	    if (not mon_save(a_cptr,0,c_sc_mental)) then
	      begin
		confused := true;
		i2 := mon_take_hit(a_cptr,dam);
		if (typ=c_illusion) then
		  begin
		    msg_print(str2+' seems to believe the illusion...');
		    if (i2>0) then
			msg_print('and dies from fright!')
		    else
			msg_print('and appears quite shaken.');
		  end
		else
		  begin
		    msg_print('The punch line strikes '+str+'...');
		    if (i2>0) then
			msg_print('who dies in a fit of laughter!')
		    else
			msg_print('who becomes weak from laughter!');
		  end;
	      end
	    else
	      if (typ=c_illusion) then
		msg_print(str2+' is unaffected.')
	      else
		begin
		  find_monster_name(str,a_cptr,true);
		  msg_print(str+' appears offended...');
		  if (mon_take_hit(a_cptr,dam div 4)>0) then
		    msg_print('but your joke still knocks it dead!');
		end;
      end;

      begin
	fire_bolt := true;
	get_flags(typ,weapon_type,harm_type,dummy);
	dist := 0;
	if bolt_to_creature(dir,y,x,dist,obj$bolt_range,true) then
	  with cave[y,x] do
	   if (typ in [c_illusion,c_joke]) then
	     ill_joke(cptr)
	   else
	    with m_list[cptr] do
	      with c_list[mptr] do
		if (not mon_resists(cptr)) then
		begin
		  find_monster_name(str,cptr,false);
		  find_monster_name(str2,cptr,true);
		  msg_print('The ' + bolt_typ + ' strikes '+str+'.');
		  if (uand(harm_type,cdefense) <> 0) then
			dam := dam*2
		  else if (uand(weapon_type,spells) <> 0) then
			dam := trunc(dam/4.0);
		  if (mon_take_hit(cptr,dam) > 0) then
		    msg_print(str2 + ' dies in a fit of agony.')
		  else
		    if (panel_contains(y,x)) then
			begin
			  print(cchar,y,x);
			  ml := true;
			end;
		end
      end;



[global,psect(misc6$code)] function explode	      (
			typ,y,x,dam_hp	    :	    integer;
			descrip			:	ctype
						) : boolean;
      var
	i1,i2,i3			: integer;
	dam,max_dis,thit,tkill		: integer;
	weapon_type,harm_type		: integer;
	destroy				: obj_set;
begin
  explode := true;
  thit	 := 0;
  tkill	 := 0;
  max_dis := 2;
  get_flags(typ,weapon_type,harm_type,destroy);
  for i1 := y-max_dis to y+max_dis do
    for i2 := x-max_dis to x+max_dis do
      if (in_bounds(i1,i2)) then
	if (distance(y,x,i1,i2) <= max_dis) then
	  if (los(y,x,i1,i2)) then	    { FIXED BUG V4.5	    }
	    with cave[i1,i2] do
	      begin
		if (tptr > 0) then
		  if (t_list[tptr].tval in destroy) then delete_object(i1,i2);
		  if (fopen) then
		  begin
		    if (panel_contains(i1,i2)) then print('*',i1,i2);
		    if (cptr > 1) then
		      with m_list[cptr] do
			with c_list[mptr] do
			begin
			  dam := dam_hp;
			  if (typ in [c_illusion,c_joke]) then
			    if (mon_save(cptr,0,c_sc_mental)) then
			      if (typ=c_illusion) then
				dam := 0
			      else
				dam := dam div 4
			    else
			      confused := true;
			  if (uand(harm_type,cdefense) <> 0) then
			    dam := dam*2
			  else if (uand(weapon_type,spells) <> 0) then
			    dam := dam div 4;
			  dam := trunc(dam/(distance(i1,i2,y,x)+1));
			  if ((dam > 0) and (not mon_resists(cptr))) then
			    begin
			      thit := thit + 1;
			      if (mon_take_hit(cptr,dam) > 0) then
				tkill := tkill + 1
			      else
				begin
				  if (panel_contains(i1,i2)) then
				    begin
				      print(cchar,i1,i2);
				      ml := true;
				    end
				end;
			    end;
			end;
		  end;
	      end;
  for i1 := y-max_dis to y+max_dis do
    for i2 := x-max_dis to x+max_dis do
      if (in_bounds(i1,i2)) then
	if (panel_contains(i1,i2)) then
	  if (distance(y,x,i1,i2) <= max_dis) then
	  begin
	    with cave[i1,i2] do
	      if (test_light(i1,i2)) then
		lite_spot(i1,i2)
	      else if (cptr = 1) then
		lite_spot(i1,i2)
	      else if (cptr > 1) then
		if (m_list[cptr].ml) then
		  lite_spot(i1,i2)
		else
		  unlite_spot(i1,i2)
	      else
		unlite_spot(i1,i2);
	  end;
	{ End  explosion...			}
	  if (thit = 1) then
	    msg_print('The ' + descrip + ' envelopes a creature!')
	  else if (thit > 1) then
	    msg_print('The ' + descrip + ' envelopes several creatures!');
	  if (tkill = 1) then
	   if (typ=c_joke) then
	    msg_print('There is a scream of side-splitting laughter!')
	   else
	    msg_print('There is a scream of agony!')
	  else if (tkill > 1) then
	   if (typ=c_joke) then
	    msg_print('There are several screams of agonized laughter!')
	   else
	    msg_print('There are several screams of agony!');
	{ End ball hitting...			}
      end;

	{ Shoot a ball in a given direction.  Note that balls have an	}
	{ area affect....					-RAK-	}
[global,psect(misc6$code)] function fire_ball (	
			typ,dir,y,x,dam_hp	:	integer;
			descrip		    	:	ctype
						) : boolean;
      var
	dist			: integer;
      begin
	dist := 0;
	fire_ball := false;
	if bolt_to_creature(dir,y,x,dist,obj$bolt_range,true) then
	  explode(typ,y,x,dam_hp,descrip)
	else if (dist <= obj$bolt_range) then
	  begin
	    move(10-dir,y,x);
	    fire_ball := explode(typ,y,x,dam_hp,descrip);
	  end;
      end;


	{ Creeping doom type spells, a missile, but with a set range	}
[global,psect(misc6$code)] function creeping_doom	(
			dir,y,x,dam_hp,range	: integer;
			ddesc			: ctype
						) : boolean;
      var
	i1,oldy,oldx,dist		: integer;
	flag				: boolean;
	dummy				: obj_set;
      begin
	dist := 0;
	creeping_doom := true;
	if bolt_to_creature(dir,y,x,dist,range,true) then
	 with cave[y,x] do
	  with m_list[cptr] do
	    with c_list[mptr] do
	      if (not mon_resists(cptr)) then
	      begin
		msg_print('The '+ddesc+' hits the '+c_list[mptr].name+'.');
		if (mon_take_hit(cptr,dam_hp) > 0) then
		  msg_print('The '+c_list[i1].name+' dies in a fit of agony.')
	        else
		  if (panel_contains(y,x)) then
		    begin
		      print(c_list[mptr].cchar,y,x);
		      m_list[cptr].ml := true;
		    end;
	      end
      end;


	{ Fire a spell that affects a line of monsters			}
[global,psect(misc6$code)] function fire_line		(
			typ,dir,y,x,dam_hp	: integer;
			descrip			: ctype
						) : boolean;
      var
	i1,oldy,oldx,dist		: integer;
	weapon_type,harm_type		: integer;
	flag				: boolean;
	dummy				: obj_set;
      begin
	fire_line := true;
	get_flags(typ,weapon_type,harm_type,dummy);
	dist := 0;
	while bolt_to_creature(dir,y,x,dist,obj$bolt_range,true) do
	 with cave[y,x] do
	  with m_list[cptr] do
	    with c_list[mptr] do
	      if (not mon_resists(cptr)) then
	      begin
	msg_print('The '+descrip+' strikes the '+c_list[mptr].name+'.');
		if (uand(harm_type,cdefense) <> 0) then
		  dam_hp := dam_hp * 2
		else if (uand(weapon_type,spells) <> 0) then
		  dam_hp := trunc(dam_hp/4.0);
		if (mon_take_hit(cptr,dam_hp) > 0) then
		  msg_print('The '+c_list[i1].name+' dies in a fit of agony.')
		else
		  begin
		    if (panel_contains(y,x)) then
		      begin
			print(c_list[mptr].cchar,y,x);
			m_list[cptr].ml := true;
		      end;
		  end
	      end
      end;


	{ Breath weapon works like a fire_ball, but affects the player. }
	{ Note the area affect....				-RAK-	}
[global,psect(misc6$code)] function breath		(
			typ,y,x,dam_hp		:	integer;
			ddesc			:	vtype
						) : boolean;
      var
	i1,i2,i3			: integer;
	dam,max_dis			: integer;
	weapon_type,harm_type		: integer;
	flag				: boolean;
	destroy				: obj_set;
      begin
	breath := true;
	max_dis := 2;
	get_flags(typ,weapon_type,harm_type,destroy);
	for i1 := y-2 to y+2 do
	  for i2 := x-2 to x+2 do
	    if (in_bounds(i1,i2)) then
	      if (distance(y,x,i1,i2) <= max_dis) then
		with cave[i1,i2] do
		  begin
		    if (tptr > 0) then
		      if (t_list[tptr].tval in destroy) then
			delete_object(i1,i2);
		    if (fopen) then
		      begin
			if (panel_contains(i1,i2)) then
			  print('*',i1,i2);
			if (cptr > 1) then
			  with m_list[cptr] do
			    with c_list[mptr] do
			      begin
				dam := dam_hp;
				if (uand(harm_type,cdefense) <> 0) then
				  dam := dam*2
				else if (uand(weapon_type,spells) <> 0) then
				  dam := trunc(dam/4.0);
				dam := trunc(dam/(distance(i1,i2,y,x)+1));
				if (not mon_resists(cptr)) then
				  hp := hp - dam;
				csleep := 0;
				if (hp < 0) then
				  begin
				    monster_death(fy,fx,cmove);
				    delete_monster(cptr);
				  end;
			      end
			else if (cptr = 1) then
			  begin
			    dam := trunc(dam_hp/(distance(i1,i2,y,x)+1));
			    case typ of
				1 :	light_dam(dam,ddesc);
				2 :	poison_gas(dam,ddesc);
				3 :	acid_dam(dam,ddesc);
				4 :	cold_dam(dam,ddesc);
				5 :	fire_dam(dam,ddesc);
				7 :	xp_loss(dam);
			    end;
			  end;
		      end;
		  end;
	for i1 := (y - 2) to (y + 2) do
	  for i2 := (x - 2) to (x + 2) do
	    if (in_bounds(i1,i2)) then
	      if (panel_contains(i1,i2)) then
		if (distance(y,x,i1,i2) <= max_dis) then
		  begin
		    with cave[i1,i2] do
		      if (test_light(i1,i2)) then
			lite_spot(i1,i2)
		      else if (cptr = 1) then
			lite_spot(i1,i2)
		      else if (cptr > 1) then
			if (m_list[cptr].ml) then
			  lite_spot(i1,i2)
			else
			  unlite_spot(i1,i2)
		      else
			unlite_spot(i1,i2);
		  end;
      end;



	{ Recharge a wand, staff, or rod.  Sometimes the item breaks. -RAK-}
[global,psect(misc6$code)] function recharge(num : integer) : boolean;
      var
		item_ptr	: treas_ptr;
		redraw		: boolean;
      begin
	recharge := false;
	redraw := false;
	change_all_ok_stats(true,true);
	if (get_item(item_ptr,'Recharge which item?',redraw,inven_ctr,trash_char,false)) then
	  with item_ptr^.data do
	    if (tval in [staff,rod,wand,chime,horn]) then
	      if (randint(8) = 1) then
		begin
		  recharge := true;
		  msg_print('There is a bright flash of light...');
		  inven_destroy(item_ptr);
		end
	      else
		begin
		  recharge := true;
		  num := trunc(num/(level+2));
		  p1 := p1 + 2 + randint(num);
		  if (index(name,'^') = 0) then
		    insert_str(name,' (%P1','^ (%P1');
		end
	    else if ((tval in [lamp_or_torch]) and (subval = 17)) then
	      if (randint(50) = 1) then
		begin
		  recharge := true;
		  msg_print('There is a bright flash of light...');
		  inven_destroy(item_ptr);
		end
	      else
		begin
		  recharge := true;
		  num := num * 100;
		  p1 := p1 + num div 3 + randint(num);
		  if (index(name,'^') = 0) then
		    insert_str(name,' (%P1','^ (%P1');
		end
	    else if ((tval in [lamp_or_torch]) and (subval=15)) then
	      if (randint(15)=1) then
		begin
		  recharge:=true;
		  msg_print('There is a bright flash of light...');
		  inven_destroy(item_ptr);
		end
	      else
		begin
		  recharge:=true;
		  num := num * 80;
		  p1 := p1 + num div 3 + randint(num);
		  if (index(name,'^') = 0) then
		    insert_str(name,' (%P1','^ (%P1');
		end;
	if (redraw) then
	  begin
	    msg_print(' ');
	    draw_cave;
	  end
	else
	  prt_weight;
      end;




{ Contains all aimed spell effects that stop at first victim.  New
  spell effects should be put into constants.inc.  Aux is used for damage
  or speed change if used.}
[global,psect(misc6$code)] function zap_monster(dir,y,x,
				aux,zaptype:integer) : boolean;
      var
	i1 : integer;
	str1,str2 : vtype;

      function did_it_work : boolean;
	begin
	with cave[y,x] do
	with c_list[m_list[cptr].mptr] do
	 case (zaptype) of
	  c_sleep,c_confuse : did_it_work := (not mon_save(cptr,0,c_sc_mental))
				and (not mon_resists(cptr));
	  c_drain : did_it_work := (uand(cdefense,%X'0008')=0)
				and (not mon_resists(cptr));
	  c_speed : did_it_work := ((not mon_save(cptr,0,c_null))
			and (not mon_resists(cptr))) or (aux>0);
	  c_hold : did_it_work := (not mon_save(cptr,0,c_hold))
				and (not mon_resists(cptr));
	  otherwise did_it_work := true;
	 end;
	end;

      procedure yes_it_did;
	begin
	with cave[y,x] do
	  with m_list[cptr] do
	  case zaptype of
	    c_probe : begin
		msg_print('The mysterious ray strikes '+str2+'.');
		writev(str2,hp:1);
		msg_print('A voice booms down from above!  It says..');
		msg_print('This monster has '+str2+' hp left.');
	      end;			
	    c_sleep : begin
		csleep := 500;
		msg_print(str1+' falls asleep.');
	      end;
	    c_confuse : begin
		confused := true;
		csleep := 0;
		msg_print(str1+' appears confused.');
	      end;
	    c_hp,c_drain : if (mon_take_hit(cptr,aux) > 0) then
		msg_print(str1+' dies in a fit of agony.')
	      else
		msg_print(str1+' screams in agony.');
	    c_speed : begin
		cspeed := cspeed+aux;
		csleep := 0;
	      end;
	    c_hold : begin
		msg_print(str1+' appears frozen!');
		i1 := stunned + aux;
		if (i1>31) then i1 := 31;
		stunned := i1;
	      end;
	    otherwise ;
	  end;
	end;

{ returns true for item idents }
      function no_it_didnt : boolean;
	begin
	  no_it_didnt := zaptype in [c_sleep,c_confuse,c_illusion];
	  if (not (zaptype in [c_drain])) then
	    msg_print(str1+' is unaffected.');
	end;


      begin
	zap_monster := false;
	if move_to_creature(dir,y,x) then
	  with cave[y,x] do
	    with m_list[cptr] do
	      with c_list[mptr] do
		begin
		  find_monster_name(str1,cptr,true);
		  find_monster_name(str2,cptr,false);
		  if (did_it_work) then
		    begin
		      yes_it_did;
		      zap_monster := true
		    end
		  else if (no_it_didnt) then
		    zap_monster := true;
		end;
      end;



	{ Turn stone to mud, delete wall....			-RAK-	}
[global,psect(misc6$code)] function wall_to_mud(dir,y,x : integer) : boolean;
      var
		i1			: integer;
		out_val			: vtype;
		flag			: boolean;
      begin
	wall_to_mud := false;
	flag := false;
	repeat
	  move(dir,y,x);
	  with cave[y,x] do
	    if (in_bounds(y,x)) then
	      begin
		if (fval in wall_set) then
		  begin
		    flag := true;
		    twall(y,x,1,0);
		    if (test_light(y,x)) then
		      begin
			msg_print('The wall turns into mud.');
			wall_to_mud := true;
		      end;
		  end
		else if ((tptr > 0) and (not(fopen))) then
		  begin
		    flag := true;
		    if (panel_contains(y,x)) then
		      if (test_light(y,x)) then
			begin
			  inven_temp^.data := t_list[tptr];
			  objdes(out_val,inven_temp,false);
			  msg_print('The ' + out_val + ' turns into mud.');
			  wall_to_mud := true;
			end;
		    delete_object(y,x);
		  end;
		if (cptr > 1) then
		  with m_list[cptr] do
		    with c_list[mptr] do
		      if (uand(%X'0200',cdefense) <> 0) then
			begin
			  i1 := mon_take_hit(cptr,100);
			  flag := true;
			  if (ml) then
			    if (i1 > 0) then
			msg_print('The ' + name + ' dies in a fit of agony.')
			    else
			      msg_print('The ' + name + ' wails out in pain!');
			end;
	      end
	    else
	      flag := true;
	until (flag);
      end;


	{ Destroy all traps and doors in a given direction	-RAK-	}
[global,psect(misc6$code)] function td_destroy2(dir,y,x : integer) : boolean;
      begin
	td_destroy2 := false;
	repeat
	  move(dir,y,x);
	  with cave[y,x] do
	    if (tptr > 0) then
	      with t_list[tptr] do
		if (tval in [Chest,Unseen_trap,Seen_trap,Closed_door,
			     Secret_door]) then
		  begin
		    if (delete_object(y,x)) then
		      begin
			msg_print('There is a bright flash of light!');
			fopen := true;
			td_destroy2 := true;
		      end;
		  end;
	until (not(cave[y,x].fopen));
      end;

	{ Polymorph a monster					-RAK-	}
	{ NOTE: cannot polymorph a winning creature (BALROG)		}
[global,psect(misc6$code)] function poly_monster(dir,y,x : integer) : boolean;
      var
		dist			: integer;
		flag			: boolean;
      begin
	poly_monster := false;
	flag := false;
	dist := 0;
	repeat
	  if bolt_to_creature(dir,y,x,dist,obj$bolt_range,false) then
	    with cave[y,x] do
	      if (not mon_save(cptr,0,c_null)) then
	      begin		  
		if (not mon_resists(cptr)) then
		begin
		  flag := true;
		  delete_monster(cptr);
		  place_monster(y,x,
			randint(m_level[max_mons_level])+ m_level[0],false);
		  if (panel_contains(y,x)) then
		    if (test_light(y,x)) then poly_monster := true;
		end;
	      end
	      else
	msg_print('The '+c_list[m_list[cptr].mptr].name+' is unaffected.')
	  else
	    flag := true;
	until (flag);
      end;


	{ Create a wall...					-RAK-	}
[global,psect(misc6$code)] function build_wall(dir,y,x : integer) : boolean;
      var
		i1		: integer;
      begin
	build_wall := false;
	i1 := 0;
	move(dir,y,x);
	while ((cave[y,x].fopen) and (i1 < 10)) do
	  with cave[y,x] do
	    begin
	      if (tptr > 0) then
		delete_object(y,x);
	      if (cptr > 1) and (not mon_resists(cptr)) then
		mon_take_hit(cptr,damroll('2d8'));
	      fval  := rock_wall2.ftval;
	      fopen := rock_wall2.ftopen;
	      fm := false;
	      if (test_light(y,x)) then
		lite_spot(y,x);
	      i1 := i1 + 1;
	      build_wall := true;
	      move(dir,y,x);
	    end;
      end;

	{ Replicate a creature					-RAK-	}
[global,psect(misc6$code)] function clone_monster(dir,y,x : integer) : boolean;
      begin
	clone_monster := false;
	if move_to_creature(dir,y,x) then
	  with cave[y,x] do
	    if (not mon_resists(cptr)) then
	    begin
	      multiply_monster(y,x,m_list[cptr].mptr,false);
	      if (panel_contains(y,x)) then
	      if (m_list[cptr].ml) then
	        clone_monster := true;
	    end
      end;

	{ Move the creature record to a new location		-RAK-	}
[global,psect(misc6$code)] function teleport_away(monptr,dis : integer) : boolean;
      var
		yn,xn,ctr		: integer;
      begin
	with m_list[monptr] do
          if (not mon_resists(monptr)) then
	  begin
	    ctr := 0;
	    repeat
	      repeat
		yn := fy + (randint(2*dis+1) - (dis + 1));
		xn := fx + (randint(2*dis+1) - (dis + 1));
	      until(in_bounds(yn,xn));
	      ctr := ctr + 1;
	      if (ctr > 9) then
		begin
		  ctr := 0;
		  dis := dis + 5;
		end;
	    until ((cave[yn,xn].fopen) and (cave[yn,xn].cptr = 0));
	    move_rec(fy,fx,yn,xn);
	    if (test_light(fy,fx)) then
	      lite_spot(fy,fx);
	    fy := yn;
	    fx := xn;
	    ml := false;
	    teleport_away := true;
	  end;
      end;

	{ Teleport player to spell casting creature		-RAK-	}
[global,psect(misc6$code)] function teleport_to(ny,nx : integer) : boolean;
      var
	dis,ctr,y,x,i1,i2		: integer;
      begin
	teleport_to := true;
	dis := 1;
	ctr := 0;
	repeat
	  repeat
	    y := ny + (randint(2*dis+1) - (dis + 1));
	    x := nx + (randint(2*dis+1) - (dis + 1));
	  until in_bounds(y,x);
	  ctr := ctr + 1;
	  if (ctr > 9) then
	    begin
	      ctr := 0;
	      dis := dis + 1;
	    end;
	until ((cave[y,x].fopen) and (cave[y,x].cptr < 2));
	move_rec(char_row,char_col,y,x);
	for i1 := char_row-1 to char_row+1 do
	  for i2 := char_col-1 to char_col+1 do
	    with cave[i1,i2] do
	      begin
		tl := false;
		if (not(test_light(i1,i2))) then
		  unlite_spot(i1,i2);
	      end;
	if (test_light(char_row,char_col)) then
	  lite_spot(char_row,char_col);
	char_row := y;
	char_col := x;
	move_char(5);
	creatures(false);
      end;


	{ Teleport all creatures in a given direction away	-RAK-	}
[global,psect(misc6$code)] function teleport_monster(dir,y,x : integer) : boolean;
      var
		yn,xn			: integer;
      begin
	teleport_monster := false;
	while move_to_creature(dir,y,x) do
	  begin
	    teleport_away(cave[y,x].cptr,max_sight);
	    teleport_monster := true;
	  end;
      end;

	{ Delete all creatures within MAX_SIGHT distance	-RAK-	}
	{ NOTE : Winning creatures cannot be genocided			}
[global,psect(misc6$code)] function mass_genocide : boolean;
      var
		i1,i2		: integer;
      begin
	mass_genocide := false;
	i1 := muptr;
	repeat
	  with m_list[i1] do
	    with c_list[mptr] do
	      begin
		i2 := nptr;
		if (cdis <= max_sight) then
		  if (uand(cmove,%X'80000000') = 0) and
		     (not mon_resists(i1)) then
		    begin
		      delete_monster(i1);
		      mass_genocide := true;
		    end;
	      end;
	  i1 := i2;
	until(i1 = 0);
      end;

	{ Delete all creatures of a given type from level.	-RAK-	}
	{ This does not keep creatures of type from appearing later.	}
[global,psect(misc6$code)] function genocide : boolean;
      var
		i1,i2		: integer;
		typ		: char;
      begin
	genocide := true;
	i1 := muptr;
	if (get_com('Which type of creature do wish exterminated?',typ)) then
	  repeat
	    with m_list[i1] do
	      with c_list[mptr] do
		begin
		  i2 := nptr;
		  if (typ = c_list[mptr].cchar) then
		    if (uand(cmove,%X'80000000') = 0) and
		       (not mon_resists(i1)) then
		      delete_monster(i1)
		    else
		      msg_print('The ' + name + ' is unaffected.');
		end;
	    i1 := i2;
	  until(i1 = 0);
      end;


	{ Polymorph any creature that player can see...		-RAK-	}
	{ NOTE: cannot polymorph a winning creature (BALROG)		}
[global,psect(misc6$code)] function mass_poly : boolean;
      var
		i1,i2,y,x	: integer;
      begin
	i1 := muptr;
	mass_poly := false;
	repeat
	  with m_list[i1] do
	    begin
	      i2 := nptr;
	      if (cdis < max_sight) then
		with c_list[mptr] do
		  if (uand(cdefense,%X'80000000') = 0) and
		     (not mon_resists(i1)) then
		    begin
		      y := fy;
		      x := fx;
		      delete_monster(i1);
		      place_monster(y,x,randint(m_level[max_mons_level])
							+ m_level[0],false);
		      mass_poly := true;
		    end;
	    end;
	  i1 := i2;
	until(i1 = 0);
      end;

	{ Display evil creatures on current panel		-RAK-	}
[global,psect(misc6$code)] function detect_creatures(typ : integer) : boolean;
      var
		i1		: integer;
		dummy		: char;
		flag,found	: boolean;
      begin
	flag := false;
	i1 := muptr;
	repeat
	  with m_list[i1] do
	    if (panel_contains(fy,fx)) then
	     begin
	      case (typ) of
	c_evil : found := uand(%X'0004',c_list[mptr].cdefense)<>0;
	c_monster : found := uand(%X'10000',c_list[mptr].cmove)=0;
	c_invisible : found := uand(%X'10000',c_list[mptr].cmove)<>0;
	otherwise ;
	      end;
	      if (found) then
		begin
		  ml := true;
		  print(c_list[mptr].cchar,fy,fx);
		  flag := true;
		end;
	     end;
	  i1 := m_list[i1].nptr;
	until(i1 = 0);
	if (flag) then
	  begin
	    case (typ) of
		c_evil : msg_print('You sense the presence of evil!');
		c_monster : msg_print('You sense the presence of monsters!');
c_invisible : msg_print('You sense the presence of invisible creatures!');
	    end;
	    msg_print(' ');
	    msg_flag := false;
	  end;
	detect_creatures := flag;
      end;

	{ Change players hit points in some manner		-RAK-	}
[global,psect(misc6$code)] function hp_player(num : integer; kind : vtype) : boolean;
      begin
	hp_player := false;
	with py.misc do
	  begin
	    if (num < 0) then
	      begin
		take_hit(num,kind);
		if (chp < 0) then
		 begin
		  msg_print('You feel your life slipping away!');
		  msg_print(' ');
		 end;		
		hp_player := true;
	      end
	    else if (chp < mhp) then
	      begin
		chp := chp + num;
		if (chp > mhp) then
		  chp := mhp;
		prt_hp;
		case trunc(num/5) of
		  0	     :	msg_print('You feel a little better.');
		  1,2	     :	msg_print('You feel better.');
		  3,4,5,6    :	msg_print('You feel much better.');
		  otherwise	msg_print('You feel very good.');
		end;
		hp_player := true;
	      end;
	  end;
      end;

{py.flags:  confused, blind, poisoned, hoarse, afraid}
[global,psect(misc6$code)] function cure_me(var what_flag : integer) : boolean;
      begin
	cure_me := false;
	if (what_flag > 1) then
	  begin
	    what_flag := 1;
	    cure_me := true;
	  end;
      end;


	{ This is a fun one.  In a given block, pick some walls and	}
	{ turn them into open spots.  Pick some open spots and turn	}
	{ them into walls.  An "Earthquake" effect...		-RAK-	}
[global,psect(misc6$code)] function earthquake : boolean;
      var
		i1,i2		: integer;
      begin
	earthquake := true;
	for i1 := char_row-8 to char_row+8 do
	  for i2 := char_col-8 to char_col+8 do
	    if ((i1 <> char_row) or (i2 <> char_col)) then
	      if (in_bounds(i1,i2)) then
		if (randint(8) = 1) then
		  begin
		    with cave[i1,i2] do
		      begin
			if (tptr > 0) then
			  delete_object(i1,i2);
			if (cptr > 1) and (not mon_resists(cptr)) then
			  mon_take_hit(cptr,damroll('2d8'));
			if (fval in wall_set) then
			  begin
			    if (next_to4(i1,i2,[1,2]) > 0) then
			      begin
				fval  := corr_floor2.ftval;
				fopen := corr_floor2.ftopen;
			      end
			    else
			      begin
				fval  := corr_floor1.ftval;
				fopen := corr_floor1.ftopen;
			      end;
			    if (test_light(i1,i2)) then unlite_spot(i1,i2);
			    pl := false;
			    fm := false;
			    if (tl) then lite_spot(i1,i2);
			  end
			else if (fval in floor_set) then
			  begin
			    case randint(10) of
			      1,2,3,4,5 : begin
					    fval  := rock_wall3.ftval;
					    fopen := rock_wall3.ftopen;
					  end;
			      6,7,8	: begin
					    fval  := rock_wall2.ftval;
					    fopen := rock_wall2.ftopen;
					  end;
			      9,10	: begin
					    fval  := rock_wall1.ftval;
					    fopen := rock_wall1.ftopen;
					  end;
			    end;
			    fm := false;
			  end;
		      end;
		    if (test_light(i1,i2)) then
		      lite_spot(i1,i2);
		  end;
      end;

	{ Evil creatures don't like this...			-RAK-	}
[global,psect(misc6$code)] function protect_evil : boolean;
      begin
	protect_evil := true;
	with py.flags do
	  protevil := protevil + randint(25) + 3*py.misc.lev;
      end;

	{ Create food for the player.		-RAK-	}
[global,psect(misc6$code)] function create_food(t0,t1,t2,t3,t4 : integer) : boolean;
      var i1,i2,i3,this_one,dist	: integer;
      begin
	create_food := true;
	for i1 := char_row-2 to char_row+2 do
	  for i2 := char_col-2 to char_col+2 do
	    with cave[i1,i2] do
	      begin
		dist := abs(i1-char_row)+abs(i2-char_col);
		if ((abs(i1-char_row)=2) or (abs(i2-char_col)=2)) then
		  dist := dist + 1;
	        if ((fopen) and (tptr=0) and (dist<5)) then
		  begin
		    case (dist) of
			0 : this_one := t0;	{food types dep. on dist = }
			1 : this_one := t1;	{X434X}
			2 : this_one := t2;	{42124}
			3 : this_one := t3;	{31013}
			4 : this_one := t4;	{42124}
		    end;			{X434X}
		   if (this_one <> 0) then
		   begin
		    place_object(i1,i2);
		    if (this_one < 0) then	{junk food.}
		      begin
			i3 := store_choice[11,(store$choices*(-this_one)
			  +randint(store$choices)+3) div 5];
			t_list[tptr] := inventory_init[i3];
		      end
		    else	{good food}
		        t_list[tptr] := yums[this_one];
		    if (test_light(i1,i2)) then	lite_spot(i1,i2);
		   end;
		  end;
	      end;
      end;

{ cflag is guys that CAN be affected; damage is speed change for c_speed.
  cflag only applies for special hp_damage monsters; others handled
  individually. }
[global,psect(misc6$code)] function zap_area(cflag,dmge,typ : integer):boolean;
      var
	i1,m_next,i2	: integer;

      function did_it_work : boolean;
        var hmm : boolean;
	begin
	 hmm := false;
	 with m_list[i1] do
	  with c_list[mptr] do
	   begin
	    case (typ) of
		c_confuse,c_sleep,c_joke : hmm:=not mon_save(i1,0,c_sc_mental);
		c_hold,c_thunder : hmm := do_stun(i1,0,dmge);
		c_speed : hmm := not mon_save(level,0,c_null) or (dmge>0);
		c_turn : hmm := uand(cdefense,%X'0008')<>0;
		c_drain : hmm := uand(cdefense,%X'0008')=0;
		c_hp : hmm := uand(cdefense,cflag)<>0;
		otherwise hmm := true;
	    end;
	    did_it_work := hmm and (not mon_resists(i1));
	   end;
	end;

      procedure yes_it_did;
	var t1 : integer;
	begin
	 with m_list[i1] do
	   case (typ) of
	    c_confuse,c_turn : begin
		msg_print('The '+c_list[mptr].name+' runs frantically!');
		confused := true;
	      end;
	    c_sleep : csleep := 500;
	    c_speed : begin
		cspeed := cspeed + dmge;
		csleep := 0;
	      end;
	    c_hold : ; {done in do_stun in did_it_work already}
	    c_thunder : confused := true;
	    c_hp,c_joke,c_drain,c_holy_word : with c_list[mptr] do
	      if (mon_take_hit(i1,randint(dmge))>0) then
		  if (typ=c_joke) then
		    msg_print('The '+name+' dies laughing!')
		  else
		    msg_print('The '+name+' dissolves!')
	      else
		if (typ=c_joke) then
		  begin
		    msg_print('The '+name+' chuckles.');
		    confused := true;
		  end
		else
		  begin
		    msg_print('The '+name+' shudders.');
		    if (typ=c_holy_word) then
			if (do_stun(i1,-4,4+randint(4))) then
			  confused := true;
		  end;
	  end;
      end;

      function no_it_didnt : boolean;
	begin
	  with m_list[i1] do
	    if (typ in [c_confuse,c_sleep,c_speed,c_hold,c_joke]) then
	     begin
	      no_it_didnt := true;
	      if (typ=c_joke) then
		begin
msg_print('The '+c_list[mptr].name+' appears offended...');
		  if (mon_take_hit(i1,randint(dmge) div 4) > 0) then
msg_print('and dies from disgust!!!');
	        end
	      else
		msg_print('The '+c_list[mptr].name+' is unaffected.');
	     end;
	end;

      begin
	i1 := muptr;
	zap_area := false;
	repeat
	  m_next := m_list[i1].nptr;
	  with m_list[i1] do
	    with c_list[mptr] do
	      if (ml) then
		if (did_it_work) then
		  begin
		    yes_it_did;
		    zap_area := true;
		  end
		else if (no_it_didnt) then
		  zap_area := true;
	  i1 := m_next;
	until (i1 = 0);
      end;

	{ Leave a glyph of warding... Creatures will not pass over! -RAK-}
[global,psect(misc6$code)] function warding_glyph : boolean;
      var
		i1			: integer;
      begin
	warding_glyph := true;
	with cave[char_row,char_col] do
	  if (tptr = 0) then
	    begin
	      popt(i1);
	      tptr := i1;
	      t_list[i1] := scare_monster;
	    end;
      end;


[global,psect(misc6$code)] procedure lower_stat(tstat : stat_set; msg1 : vtype);
      var
	i1 : byteint;
      begin
	with py.stat do
	  begin
	    l[tstat] := l[tstat] + de_statp(p[tstat] - l[tstat]);
	    update_stat(tstat);
	    if (msg1 = 'X') then
	      case tstat of
		sr : msg_print('You feel very sick.');
		iq : msg_print('You become very dizzy.');
		ws : msg_print('You feel very naive.');
		dx : msg_print('You feel very sore.');
		cn : msg_print('You feel very sick.');
		ca : msg_print('Your skin starts to itch.');
	      end
	    else if (length(msg1) <> 0) then
	      msg_print(msg1);
	    prt_a_stat(tstat);
	  end;
      end;

[global,psect(misc6$code)] function lose_stat(tstat : stat_set;
				msg1,msg2 : vtype) : boolean;
      begin
	lose_stat := true;
	if (not(py.flags.sustain[tstat])) then
	  lower_stat(tstat,msg1)
	else
	  if (msg2 = 'X') then
	    case tstat of
	sr : msg_print('You feel sick for a moment, then it passes.');
	iq : msg_print('You become dizzy for a moment, then it passes.');
	ws : msg_print('You feel naive for a moment, then it passes.');
	dx : msg_print('You feel sore for a moment, then it passes.');
	cn : msg_print('You feel sick for a moment, then it passes.');
	ca : msg_print('Your skin starts to itch, but feels better now.');
	    end
	  else if (length(msg2) <> 0) then
	     msg_print(msg2);
      end;

[global,psect(misc6$code)] function restore_stat(tstat : stat_set;
			msg1 : vtype) : boolean;
      var i1 : byteint; {stat adjusted by magic worn only}
      begin
	restore_stat := true;
	with py.stat do
	  if (l[tstat] > 0) then
	    begin
	      l[tstat] := 0;
	      update_stat(tstat);
	      if (msg1[1] = 'X') then
		case tstat of
		  sr : msg_print('You feel warm all over.');
		  iq : msg_print('You have a warm feeling.');
		  ws : msg_print('You feel your wisdom returning.');
		  dx : msg_print('You feel less clumsy.');
		  cn : msg_print('You feel your health returning.');
		  ca : msg_print('You feel your looks returning.');
		end
	      else if (length(msg1) <> 0) then
		msg_print(msg1);
	      prt_a_stat(tstat);
	    end;
      end;

[global,psect(misc6$code)] function gain_stat(tstat : stat_set;
			msg1 : vtype) : boolean;
      begin
	gain_stat := true;
	with py.stat do begin
	  i1 := in_statp(p[tstat] - l[tstat]);
	  if (i1 < l[tstat]) then
	    l[tstat] := l[tstat] - i1
	  else begin
	    l[tstat] := 0;
	    p[tstat] := squish_stat(p[tstat] - l[tstat] + i1);
	  end;
	  update_stat(tstat);
	  if (msg1 = 'X') then
	    case tstat of
		sr : msg_print('Wow!  What bulging muscles!');
		iq : msg_print('Aren''t you brilliant!');
		ws : msg_print('You suddenly have a profound thought!');
		dx : msg_print('You feel more limber!');
		cn : msg_print('You feel tingly for a moment.');
		ca : msg_print('Gee ain''t you cute!');
	    end
	  else if (length(msg1) <> 0) then
	    msg_print(msg1);
	  prt_a_stat(tstat);
	end;
      end;

	{ Lose experience					-RAK-	}
[global,psect(misc6$code)] procedure lose_exp(amount : integer);
    var
	i1,i2				: integer;
	av_hp,lose_hp			: integer;
	av_mn,lose_mn			: integer;
	flag				: boolean;

    begin
      with py.misc do
	begin
	  if (amount > exp) then
	    exp := 0
	  else
	    exp := exp - amount;
	  i1 := 1;
	  while (trunc(player_exp[i1]*expfact) <= exp) do
	    i1 := i1 + 1;
	  i2 := lev - i1;
	  while (i2 > 0) do
	    begin
	      av_hp := trunc(mhp/lev);
	      av_mn := trunc(mana/lev);
	      lev   := lev - 1;
	      i2    := i2 - 1;
	      lose_hp := randint(av_hp*2-1);
	      lose_mn := randint(av_mn*2-1);
	      mhp  := mhp  - lose_hp;
	      mana := mana - lose_mn;
	      if (mhp  < 1) then mhp  := 1;
	      if (mana < 0) then mana := 0;
	      with class[pclass] do
		if ((mspell) or (pspell) or (dspell) or (bspell)) then
		  begin
		    i1 := 32;
		    flag := false;
		    repeat
		      i1 := i1 - 1;
		      if (magic_spell[pclass,i1].learned) then
			flag := true;
		    until((flag) or (i1 < 2));
		    if (flag) then
		      begin
			magic_spell[pclass,i1].learned := false;
			if (mspell) then
			  msg_print('You have forgotten a magic spell!')
			else if (pspell) then
			  msg_print('You have forgotten a prayer!')
			else
			  msg_print('You have forgotten a song!')
		      end;
		  end;
	    end;
	  if (chp   > mhp)  then chp   := mhp;
	  if (cmana > mana) then cmana := mana;
	  title := player_title[pclass,lev];
	  prt_experience;
	  prt_hp;
	  if (is_magii) then prt_mana;
	  prt_level;
	  prt_title;
	end;
    end;

	{ Slow Poison						-RAK-	}
[global,psect(misc6$code)] function slow_poison : boolean;
    begin
      slow_poison := false;
      with py.flags do
	if (poisoned > 0) then
	  begin
	    poisoned := trunc(poisoned/2.0);
	    if (poisoned < 1) then poisoned := 1;
	    slow_poison := true;
	    msg_print('The effects of the poison has been reduced.');
	  end;
    end;

	{ Bless							-RAK-	}
[global,psect(misc6$code)] function bless(amount : integer) : boolean;
    begin
      bless := true;
      with py.flags do
	blessed := blessed + amount;
    end;

	{ Detect Invisible for period of time			-RAK-	}
[global,psect(misc6$code)] function detect_inv2(amount : integer) : boolean;
    begin
      detect_inv2 := true;
      with py.flags do
	detect_inv := detect_inv + amount;
    end;

	{ The spell of destruction...				-RAK-	}
	{ NOTE : Winning creatures that are deleted will be considered	}
	{	 as teleporting to another level.  This will NOT win the}
	{	 game...						}
[global,psect(misc6$code)] function destroy_area(y,x : integer) : boolean;
    var
	i1,i2,i3			: integer;

    procedure replace_spot(y,x,typ : integer);
      begin
	with cave[y,x] do
	  begin
	    case typ of
	      1,2,3  :	begin
			  fval	:= corr_floor1.ftval;
			  fopen := corr_floor1.ftopen;
			end;
	      4,7,10 :	begin
			  fval	:= rock_wall1.ftval;
			  fopen := rock_wall1.ftopen;
			end;
	      5,8,11 :	begin
			  fval	:= rock_wall2.ftval;
			  fopen := rock_wall2.ftopen;
			end;
	      6,9,12 :	begin
			  fval	:= rock_wall3.ftval;
			  fopen := rock_wall3.ftopen;
			end;
	    end;
	    pl := false;
	    fm := false;
	    if (tptr > 0) then
	      delete_object(y,x);
	    if (cptr > 1) and (not mon_resists(cptr)) then
	      delete_monster(cptr);
	  end;
      end;

    begin
      destroy_area := true;
      if (dun_level > 0) then
	  for i1 := (y-15) to (y+15) do
	    for i2 := (x-15) to (x+15) do
	      if (in_bounds(i1,i2)) then
		if (cave[i1,i2].fval <> 15) then
		  begin
		    i3 := distance(i1,i2,y,x);
		    if (i3 < 13) then
		      replace_spot(i1,i2,randint(6))
		    else if (i3 < 16) then
		      replace_spot(i1,i2,randint(9));
		  end;
      msg_print('There is a searing blast of light!');
      py.flags.blind := py.flags.blind + 10 + randint(10);
    end;


	{ Enchants a plus onto an item...			-RAK-	}
[global,psect(misc6$code)] function enchant(var pluses : worlint) : boolean;
    var
	chance			: integer;
    begin
      chance := 0;
      enchant := false;
      if (pluses > 0) then
	case pluses of
	  1  :	chance := 040;
	  2  :	chance := 100;
	  3  :	chance := 200;
	  4  :	chance := 400;
	  5  :	chance := 600;
	  6  :	chance := 700;
	  7  :	chance := 800;
	  8  :	chance := 900;
	  9  :	chance := 950;
	  otherwise chance := 995;
	end;
      if (randint(1000) > chance) then
	begin
	  pluses := pluses + 1;
	  enchant := true;
	end;
    end;


	{ Removes curses from items in inventory		-RAK-	}
[global,psect(misc6$code)] function remove_curse : boolean;
    var
	i1			: integer;
    begin
      remove_curse := false;
      for i1 := Equipment_primary to Equipment_cloak do
	with equipment[i1] do
	  if (uand(%X'80000000',flags) <> 0) then
	    begin
	      flags := uand(%X'7FFFFFFF',flags);
	      py_bonuses(blank_treasure,0);
	      remove_curse := true;
	    end;
    end;


	{ Restores any drained experience			-RAK-	}
[global,psect(misc6$code)] function restore_level : boolean;
	var
	  max_level		: byteint;

    begin
      restore_level := false;
      max_level := 1;
      while (trunc(player_exp[max_level] * py.misc.expfact)
		<= py.misc.max_exp) do max_level := max_level + 1;
	if (randint(100) > (max_level - py.misc.lev)*2.25) then
	begin
	  with py.misc do
	  begin
	    restore_level := true;
	    msg_print('You feel your life energies returning...');
	    while (exp < max_exp) do
	      begin
		exp := max_exp;
		prt_experience;
	      end;
	  end;
	end
	else
	  msg_print('The restoring fails!');
    end;
 
                                                          
