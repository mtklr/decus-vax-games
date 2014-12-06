
[psect(misc2$code)] procedure blow;
      var
		i1				: unsigned;
		i3,i4,chance,i5			: integer;
		i2,item_ptr			: treas_ptr;
		dir				: char;
		dur				: integer;
		dumy,y_dumy,x_dumy		: integer;
		out_val				: vtype;
		redraw,ident			: boolean;
		tstat				: stat_set;
		loss				: integer;
      begin
	reset_flag := true;
	if (inven_ctr > 0) then
	  begin
	    if (find_range([misc_usable,horn,chime,valuable_gems],false,i2,i3)) then
	      begin
		redraw := false;
		if (get_item(item_ptr,'Use which item?',redraw,i3,trash_char,false)) then
		  with item_ptr^.data do
		    begin
		      if (redraw) then draw_cave;
			reset_flag := false;
			with py.misc do
			  chance := save + lev + bard_adj - level - 5;
			if (((py.flags.confused + py.flags.afraid) > 0) and
			    ((tval = chime) or (tval = horn))) then
			  msg_print('you can not use the instrument...')
			else if (p1 > 0) then
			begin
			if (chance < 0) then chance := 0;
			if (randint(chance) < use_device) and
			   ((tval <> misc_usable) and (subval <> 24)) then
			  msg_print('You failed to use the item properly.')
			else 
			  begin
			    i1 := flags;
			    ident := false;
			    p1 := p1 - 1;
			    while (i1 > 0) do
			      begin
				i5 := bit_pos(i1);
	if ((tval = chime) or (tval=horn)) then
	begin
	{ Chimes...				      }
	case (i5) of
{ Chime of Light }
	  1  :	ident := light_area(char_row,char_col);
{ Chime of Detect Doors/Stairs }
	  2  :	ident := detect_sdoor;
{ Chime of Detect Traps }
	  3  :	ident := detect_trap;
{ Chime of Teleportation }
	  4  :	begin
		  teleport(100);
		  ident := true;
		end;
{ Chime of Thunderblasts }
	  5  :	ident := earthquake;
{ Chime of Summon Monster }
	  6  :	begin
		  for i3 := 1 to randint(4) do
		    begin
		      y := char_row;
		      x := char_col;
		      if (cave[y,x].fval in water_set) then
			summon_water_monster(y,x,false)
		      else
			summon_land_monster(y,x,false);
		    end;
		  ident := true;
		end;
{ Chime of Disarming }
	   7 :	begin
		  ident := true;
		  for i3 := 1 to 9 do
		    if (i3 <>5) then
		      disarm_all(i3,char_row,char_col);
		end;
{ Chime of Aggravation }
	   8 :	ident := aggravate_monster(20);
{ Chime of Slow Monster }
	   9 :	ident := zap_area(0,-1,c_speed);
{ Chime of Sooth Monster }
	  10 :	ident := zap_area(0,0,c_sleep);
{ Chime of Cure Light Wounds }
	  11 :	ident := hp_player(randint(8),'a chime.');
{ Chime of Changing }
	  12 :	ident := mass_poly;
{ Chime of Remove Curse }
	  13 :	if (remove_curse) then
		  begin
		    msg_print('Your equipment glows blue for a moment...');
		    ident := true;
		  end;
{ Chime of Curing }
	  14 :	with py.flags do
		  ident := cure_me(blind) or cure_me(poisoned)
			or cure_me(confused);
{ Chime of Dispell Evil }
	  15 :	ident := zap_area(%X'0004',60,c_hp);
{ Chime of Darkness }
	  16 :	ident := unlight_area(char_row,char_col);
{ Horns...							       }
{ Horn of Bubbles }
	  17 :	begin
		 msg_print('Bubbles stream forth and surround you!');
		 py.flags.blind := py.flags.blind + (randint(20) +5);
		 ident := unlight_area(char_row,char_col);
		end;
{ Horn of Calling }
	  18 :	begin
		  for i3 := 1 to randint(4) do
		    begin
		      y := char_row;
		      x := char_col;
		      if (cave[y,x].fval in water_set) then
			summon_water_monster(y,x,false)
		      else
			summon_land_monster(y,x,false);
		    end;
		  ident := true;
		end;
{ Horn of Soft Sounds }
	  19 :	ident := sleep_monsters1(char_row,char_col);
{ Horn of *Blasting* }
	  20 :	ident := destroy_area(char_row,char_col);
{ Horn of Cold }
	  21 :	begin
		  msg_print('A wave of cold pours forth...');
		  ident := zap_area(%X'0010',60,c_hp);
		end;
{ Horn of Heat }
	  22 :	begin
		  msg_print('A blast of warm air pours forth...');
		  ident := zap_area(%X'0020',60,c_hp);
		end;
{ Horn of Gas }
	  23 :	begin
		  msg_print('Gas streams out ...!');
		  ident := zap_area(%X'0040',60,c_hp);
		  py.flags.poisoned := py.flags.poisoned + randint(10)
		end;
{ Horn of Recall }
	  24 :	begin
		  py.flags.word_recall := (randint(20) + 20);
		  ident:= true;
		end;
{ Horn of *Chaos* }
	  25 :	begin
		  ident := earthquake;
		  ident := unlight_area(char_row,char_col);
		  for i3 := 1 to randint(4) do
		    begin
		      y := char_row;
		      x := char_col;
		      if (cave[y,x].fval in water_set) then
			summon_water_monster(y,x,false)
		      else
			summon_land_monster(y,x,false);
		    end;
		end;
{ Horn of Glue }
	  26 :	begin
		  msg_print('glue pours out of the horn!');
		  msg_print('all of your equipment is stuck!');
		  for i3 := Equipment_primary to Equipment_cloak do
		    with equipment[i3] do
		      flags := uor(flags,%X'80000000');
		  with equipment[Equipment_secondary] do
		    flags := uor(flags,%X'80000000');
		  ident := true;
		end;
{ Horn of Valhalla }
	  27 :	begin
		  msg_print('The Voice of Odin (oh brother...) smites evil!');
		  ident := zap_area(%X'0004',70,c_hp);
		  light_area(char_row,char_col);
		  hp_player(randint(20)+20,'a horn.');
		end;
{ Horn of Tritons }
	  28 :	with py.flags do
		 begin
		  ident := true;
		  msg_print('All of the seas of the world still (yeah, right)!');
		  msg_print('The gods of the ocean hear you...'	 );
		  blessed := blessed + randint(20);
		  cure_me(blind);
		  cure_me(poisoned);
		end;
{ Horn of Fog }
	  29 :	begin
		  msg_print('Thick fog billows out...');
		  ident := unlight_area(char_row,char_col);
		  msg_print('The nearby creatures are confused');
		  ident := zap_area(0,0,c_confuse);
		end;
	  otherwise ;
	end;
	end
      else
	case (i5) of
{Silver Cross}	1 : begin
			msg_print('You feel secure...');
			protect_evil;
			ident := true;
		    end;
{Gold Cross}	2 : ident := zap_area(%X'0400',100,c_hp);
{Mithril Cross}	3 : begin
                        x := char_row;
                        y := char_col;
                        ident := summon_undead(x,y);
                    end;
{Cross}		4 : begin
                        x := char_row;
                        y := char_col;
                        ident := summon_demon(x,y);
		    end;
{Cross}		5 : begin
			name := name + '(Empty)';
		      msg_print('You free a Djinni from the bottle!');
		      msg_print('He grants you a wish...');
		      msg_print('"I will raise one of your stats by two..."');
		      msg_print('"Which stat would you like to raise?"');
		      ident := (get_com('1=str 2=int 3=wis 4=dex 5=con 6=cha',dir));
		      if ((dir > '0') and (dir < '7')) then
			begin
			  tstat := ord(dir)-49;
			  ident := gain_stat(tstat,'X');
			  ident := gain_stat(tstat,' and x2, too!');
			end
		      else
			msg_print('Oh well, maybe next time.')
		    end;
  { Corked Bottle of Demons }
		6 : begin
			msg_print('You release several demons!');
			x := char_row;
                        y := char_col;
			for i3 := 1 to 4 do
			  summon_demon(x,y);
			py.flags.paralysis := py.flags.paralysis + 2;
			name := name + '(Empty)';
			ident := true;
		    end;
		7 : ident := create_water(char_row,char_col);
		8 : ident := destroy_water(char_row,char_col);
		9 : begin
		       msg_print('Many Undead appear!');
                       x := char_row;
                       y := char_col;
		       for i3 := 1 to 8 do
			 ident := summon_undead(x,y);
		       py.flags.paralysis := py.flags.paralysis + 2;
		    end;
		10 : begin
			msg_print('Many Demons appear!');
                        x := char_row;
                        y := char_col;
			for i3 := 1 to 8 do
			  ident := summon_demon(x,y);
		      py.flags.paralysis := py.flags.paralysis + 2;
		      ident := true;
		    end;
		11: begin
		      with py.stat do
			for tstat := sr to ca do
			  if restore_stat(tstat,'X') then ident := true;
		      if hp_player(damroll('6d7'),'a statue.') then
			ident := true;
		      with py.flags do
			begin
			  if (slow > 0) then
			    begin
			      ident := true;
			      slow := 1;
			    end;
			  if (cure_me(blind) or cure_me(poisoned) or
		cure_me(confused) or cure_me(afraid) or restore_level) then
			  ident := true;
			end;
		      if (ident) then
     msg_print('The statue fills you with life and all maladies are cured.');
		    end;
		12: ident := true;
          	13 :  begin
		  	redraw := true;
		  	wizard_light;
		 	for i3 := (char_col + 1) to (char_col - 1) do
		    	  for i4 := (char_row + 1) to (char_row - 1) do
		      	    if (test_light(i4,i3)) then
			      redraw := false;
		  	if (redraw) then 
		    	wizard_light;
		    end;
		14: ident := zap_area(0,2,c_speed);
		15: begin
			with py.misc do
			  begin
			    loss := 0;
			    for i3 := 1 to 6 do
			      begin
			loss := loss+(money[i3]-money[i3] div 2)*coin$weight;
				money[i3] := money[i3] div 2;
			      end;
			    inven_weight := inven_weight - loss;
			    reset_total_cash;
			  end;
			msg_print('most of your money turns to dust!');
			prt_gold;
			prt_weight;
			ident := true;
		    end;
		16 :  with py.misc do
		        if (cmana < mana) then
		          begin
		            cmana := mana;
		            ident := true;
		            msg_print('Your feel your head clear...');
		          end;
		17 : ident := item_petrify;
		18 : begin
		       item_ptr^.data.damage := '50d5';
		       item_ptr^.data.cost := -1;
		       msg_print('Click!');
		       ident := true;
		     end;
		19 : ident := detect_creatures(c_monster);
		20 : ident := zap_area(%X'0004',60,c_hp);
		21 : begin
			ident := unlight_area(char_row,char_col);
		     end;
		22 : begin
			if (get_dir('Which direction?',dur,dumy,y_dumy,x_dumy)) then
			  begin
			    i3 := char_row;
			    i4 := char_col;
			    ident := fire_ball(3,dur,i3,i4,40,'Acid Ball');
			  end
			else
			  p1 := p1 + 1;
		     end;
		23 : ident := detect_creatures(c_invisible);
		24 : ident := ident_spell;
		25 : ident := light_area(char_row,char_col);
		26 : begin
			for i3 := 1 to randint(4) do
			  begin
{who's the idiot who wrote these things anyhow? }
				y := char_row;
				x := char_col;
				if (cave[y,x].fval in water_set) then
					summon_water_monster(y,x,false)
				else
					summon_land_monster(y,x,false);
			  end;
		    ident := true;
		    end;
		27 : if (remove_curse) then
			begin
			 msg_print('Your junk glows black for a moment...');
			 ident := true;
			end;
		28 : begin
			ident := destroy_area(char_row,char_col);
		     end;
		29 : begin
			py.flags.word_recall := 10 + randint(10);
			msg_print('You feel dizzy for a moment...');
			ident := true;
		     end;
		30 : begin
			msg_print('The teeth flare into flames.');
			py.flags.ring_fire := py.flags.ring_fire+3+randint(3);
			ident := true;
		     end;
		31 : begin
			msg_print('The Demon teeth try to possess you...');
			lose_exp(100);
			change_rep(-10);
			ident := true;
		     end;
	otherwise	
		begin
		  msg_print('Todd Gardiner is fat!');
		  ident := true;
		end;
	end;

	{ End of instrument actions...				     }
			      end;
			    if (ident) then
			      identify(inven_temp^.data);
			    if (flags <> 0) then
			      with py.misc do
				begin
				  exp := exp + round(level/lev);
				  prt_experience;
				end;
			    desc_charges(item_ptr);
			end;
			  end;
		    end
		else
		  if (redraw) then draw_cave;
	      end
	    else
	      msg_print('You are not carrying anything to use...');
	  end
	else
	  msg_print('But you are not carrying anything.');
      end;



