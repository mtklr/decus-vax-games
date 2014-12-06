	{ Scrolls for the reading				-RAK-	}
[psect(misc2$code)] procedure read_scroll;
      var
		i1				: unsigned;
		i3,i4,i5			: integer;
		i2,item_ptr,temp_ptr		: treas_ptr;
		thit,tdam,y,x			: integer;
		tmp				: array [1..8] of integer;
		out_val,str1,str2		: vtype;
		redraw,ident,first,flag		: boolean;
      begin
	first := true;
	reset_flag := true;
	if (inven_ctr > 0) then
	  begin
	    if (find_range([scroll1,scroll2],false,i2,i3)) then
	      if (py.flags.blind > 0) then
		msg_print('You can''t see to read the scroll.')
	      else if (no_light) then
		msg_print('You have no light to read by.')
	      else if (py.flags.confused > 0) then
		begin
		  msg_print('The text seems to swim about the page!');
		  msg_print('You are too confused to read...');
		end
	      else
		begin
		  redraw := false;
		  if (get_item(item_ptr,'Read which scroll?',redraw,i3,trash_char,false)) then
		    with item_ptr^.data do
		      begin
			if (redraw) then draw_cave;
			reset_flag := false;
			i1 := flags;
			ident := false;
			while (i1 > 0) do
			  begin
			    i5 := bit_pos(i1);
			    if (tval = scroll2) then i5 := i5 + 31;
			    if (first) then
			      if (not(i5 in [4,25,42])) then
				begin
			msg_print('As you read the scroll it vanishes.');
				  first := false;
				end;

	{ Scrolls...						}
	case (i5) of
{ Enchant to Hit }
	  1  :	with equipment[Equipment_primary] do
		  begin
		    if (tval > 0) then
		    begin
		      inven_temp^.data := equipment[Equipment_primary];
		      objdes(out_val,inven_temp,false);
		      msg_print('Your ' + out_val + ' glows faintly!');
		      if (enchant(tohit)) then
			begin
			  flags := uand(Everything_flag-Cursed_worn_bit,flags);
				{Un-curse the object}
			  py_bonuses(blank_treasure,0);
			end
		      else
			msg_print('The enchantment fails...');
		    end;
		    ident := true;
		  end;
{ Enchant to Damage }
	  2  :	with equipment[Equipment_primary] do
		  begin
		    if (tval > 0) then
		    begin
		      inven_temp^.data := equipment[Equipment_primary];
		      objdes(out_val,inven_temp,false);
		      msg_print('Your ' + out_val + ' glows faintly!');
		      if (enchant(todam)) then
			begin
			  flags := uand(Everything_flag-Cursed_worn_bit,flags);
			  py_bonuses(blank_treasure,0);
			end
		      else
			msg_print('The enchantment fails...');
		    end;
		    ident := true;
		  end;
{ Enchant Armor }
	  3  :	begin
		  i3 := 0;
		  i4 := 0;
		  if (equipment[Equipment_armor].tval > 0) then
		    begin
		      i3 := i3 + 1;
		      tmp[i3] := Equipment_armor;
		    end;
		  if (equipment[Equipment_shield].tval > 0) then
		    begin
		      i3 := i3 + 1;
		      tmp[i3] := Equipment_shield;
		    end;
		  if (equipment[Equipment_cloak].tval > 0) then
		    begin
		      i3 := i3 + 1;
		      tmp[i3] := Equipment_cloak;
		    end;
		  if (equipment[Equipment_gloves].tval > 0) then
		    begin
		      i3 := i3 + 1;
		      tmp[i3] := Equipment_gloves;
		    end;
		  if (equipment[Equipment_helm].tval > 0) then
		    begin
		      i3 := i3 + 1;
		      tmp[i3] := Equipment_helm;
		    end;
		  if (equipment[Equipment_boots].tval > 0) then
		    begin
		      i3 := i3 + 1;
		      tmp[i3] := Equipment_boots;
		    end;
		  if (equipment[Equipment_belt].tval > 0) then
		    begin
		      i3 := i3 + 1;
		      tmp[i3] := Equipment_belt;
		    end;
		  if (equipment[Equipment_bracers].tval > 0) then
		    begin
		      i3 := i3 + 1;
		      tmp[i3] := Equipment_bracers;
		    end;
		  if (i3 > 0) then i4 := tmp[randint(i3)];
		  if (uand(Cursed_worn_bit,equipment[Equipment_armor].flags) <> 0) then
		    i4 := Equipment_armor
		  else if (uand(Cursed_worn_bit,equipment[Equipment_shield].flags) <> 0) then
		    i4 := Equipment_shield
		  else if (uand(Cursed_worn_bit,equipment[Equipment_cloak].flags) <> 0) then
		    i4 := Equipment_cloak
		  else if (uand(Cursed_worn_bit,equipment[Equipment_helm].flags) <> 0) then
		    i4 := Equipment_helm
		  else if (uand(Cursed_worn_bit,equipment[Equipment_gloves].flags) <> 0) then
		    i4 := Equipment_gloves
		  else if (uand(Cursed_worn_bit,equipment[Equipment_boots].flags) <> 0) then
		    i4 := Equipment_boots
		  else if (uand(Cursed_worn_bit,equipment[Equipment_belt].flags) <> 0) then
		    i4 := Equipment_belt
		  else if (uand(Cursed_worn_bit,equipment[Equipment_bracers].flags) <> 0) then
		    i4 := Equipment_bracers;
		  if (i4 > 0) then
		    with equipment[i4] do
		      begin
			inven_temp^.data := equipment[i4];
			objdes(out_val,inven_temp,false);
			msg_print('Your ' + out_val + ' glows faintly!');
			if (enchant(toac)) then
			  begin
			    flags := uand(Everything_flag-Cursed_worn_bit,flags);
			    py_bonuses(blank_treasure,0);
			  end
			else
			  msg_print('The enchantment fails...');
		      end;
		    ident := true;
		end;
{ Identify }
	  4  :	begin
		  identify(item_ptr^.data);
		  msg_print('This is an identify scroll');
		  msg_print(' ');
		  if (ident_spell) then first := false;
		end;
{ Remove Curse }
	  5  :	if (remove_curse) then
		  begin
		    msg_print('You feel as if someone is watching over you.');
		    ident := true;
		  end;
{ Light }
	  6  :	ident := light_area(char_row,char_col);
{ Summon Monster }
	  7  :	begin
		  for i3 := 1 to randint(3) do
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
{ Phase Door }
	  8  :	begin
		  teleport(10);
		  ident := true;
		end;
{ Teleport }
	  9  :	begin
		  teleport(100);
		  ident := true;
		end;
{ Teleport Level }
	  10 :	begin
		  dun_level := dun_level - 3 + 2*randint(2);
		  if (dun_level < 1) then
		    dun_level := 1;
		  moria_flag := true;
		  ident := true;
		end;
{ Confuse Monster }
	  11 :	begin
		  msg_print('Your hands begin to glow.');
		  py.flags.confuse_monster := true;
		  ident := true;
		end;
{ Magic Mapping }
	  12 :	ident := map_area;
{ Sleep Monster }
	  13 :	ident := sleep_monsters1(char_row,char_col);
{ Rune of Protection }
	  14 :	ident := warding_glyph;
{ Detect Treasure }
	  15 :	ident := detect_item(c_treasure);
{ Detect Object }
	  16 :	ident := detect_item(c_object);
{ Detect Trap }
	  17 :	ident := detect_trap;
{ Detect Secret Door }
	  18 :	ident := detect_sdoor;
{ Mass Genocide }
	  19 :	begin
		  msg_print('This is a mass genocide scroll.');
		  msg_print(' ');
		  ident := mass_genocide;
		end;
{ Detect Invisible }
	  20 :	ident := detect_creatures(c_invisible);
{ Aggravate Monster }
	  21 :	begin
		  ident := aggravate_monster(20);
		  msg_print('There is a high pitched humming noise');
		end;
{ Create Trap }
	  22 :	ident := trap_creation;
	  23 :	ident := td_destroy;
{ Create Door }
	  24 :	ident := door_creation;
{ Recharge Item }
	  25 :	begin
		  identify(item_ptr^.data);
		  msg_print('This is a Recharge-Item scroll.');
		  msg_print(' ');
		  if (recharge(60)) then first := false;
		end;
{ Genocide }
	  26 :	begin
		  msg_print('This is a genocide scroll.');
		  msg_print(' ');
		  ident := genocide;
		end;
{ Darkness }
	  27 :	ident := unlight_area(char_row,char_col);
{ Prot vs Evil }
	  28 :	ident := protect_evil;
{ Create Food }
	  29 :	ident := create_food(3,2,1,0,0);
{ Dispell Creature }
	  30 :	ident := zap_area(%X'0008',60,c_hp);
{ Blank }
	  31 :	begin
		  msg_print('That scroll appeared to be blank.');
		  ident := true;
		end;
{ Enchant Weapon }
	  32 :	with equipment[Equipment_primary] do
		  begin
		    if (tval > 0) then
		    begin
		      inven_temp^.data := equipment[Equipment_primary];
		      objdes(out_val,inven_temp,false);
		      msg_print('Your ' + out_val + ' glows brightly!');
		      flag := false;
		      for i3 := 1 to randint(2) do
			if (enchant(tohit)) then
			  flag := true;
		      for i3 := 1 to randint(2) do
			if (enchant(todam)) then
			  flag := true;
		      if (flag) then
			begin
			  flags := uand(Everything_flag-Cursed_worn_bit,flags);
			  py_bonuses(blank_treasure,0);
			end
		      else
			msg_print('The enchantment fails...');
		    end;
		    ident := true;
		  end;
{ Curse Weapon }
	  33 :	with equipment[Equipment_primary] do
		  begin
		    if (tval > 0) then
		      begin
			inven_temp^.data := equipment[Equipment_primary];
			objdes(out_val,inven_temp,false);
			msg_print('Your ' + out_val +
				' glows black, then fades.');
			tohit := -randint(5) - randint(5);
			todam := -randint(5) - randint(5);
			flags := Cursed_worn_bit;
			py_bonuses(inven_temp^.data,-1);
			ident := true;
		      end;
		  end;
	  34 :	begin
		  if (uand(Cursed_worn_bit,equipment[Equipment_armor].flags) <> 0) then
		    i3 := Equipment_armor
		  else if (uand(Cursed_worn_bit,equipment[Equipment_shield].flags) <> 0) then
		    i3 := Equipment_shield
		  else if (uand(Cursed_worn_bit,equipment[Equipment_cloak].flags) <> 0) then
		    i3 := Equipment_cloak
		  else if (uand(Cursed_worn_bit,equipment[Equipment_helm].flags) <> 0) then
		    i3 := Equipment_helm
		  else if (uand(Cursed_worn_bit,equipment[Equipment_gloves].flags) <> 0) then
		    i3 := Equipment_gloves
		  else if (equipment[Equipment_armor].tval > 0) then
		    i3 := Equipment_armor
		  else if (equipment[Equipment_shield].tval > 0) then
		    i3 := Equipment_shield
		  else if (equipment[Equipment_helm].tval > 0) then
		    i3 := Equipment_helm
		  else if (equipment[Equipment_gloves].tval > 0) then
		    i3 := Equipment_gloves
		  else
		    i3 := 0;
		  if (i3 > 0) then
		    with equipment[i3] do
		      begin
			inven_temp^.data := equipment[i3];
			objdes(out_val,inven_temp,false);
			msg_print('Your ' + out_val + ' glows brightly!');
			flag := false;
			for i3 := 1 to randint(2) + 1 do
			  if (enchant(toac)) then
			    flag := true;
			if (flag) then
			  begin
			    flags := uand(Everything_flag-Cursed_worn_bit,flags);
			    py_bonuses(blank_treasure,0);
			  end
			else
			  msg_print('The enchantment fails...');
		      end;
		    ident := true;
		end;
	  35 :	begin
		  if ((equipment[Equipment_armor].tval > 0) and (randint(4) = 1)) then
		    i3 := Equipment_armor
		  else if ((equipment[Equipment_shield].tval > 0) and (randint(3) = 1)) then
		    i3 := Equipment_shield
		  else if ((equipment[Equipment_cloak].tval > 0) and (randint(3) = 1)) then
		    i3 := Equipment_cloak
		  else if ((equipment[Equipment_helm].tval > 0) and (randint(3) = 1)) then
		    i3 := Equipment_helm
		  else if ((equipment[Equipment_gloves].tval > 0) and (randint(3) = 1)) then
		    i3 := Equipment_gloves
		  else if ((equipment[Equipment_belt].tval > 0) and (randint(3) = 1)) then
		    i3 := Equipment_belt
		  else if ((equipment[Equipment_bracers].tval > 0) and (randint(3) = 1)) then
		    i3 := Equipment_bracers
		  else if (equipment[Equipment_armor].tval > 0) then
		    i3 := Equipment_armor
		  else if (equipment[Equipment_shield].tval > 0) then
		    i3 := Equipment_shield
		  else if (equipment[Equipment_cloak].tval > 0) then
		    i3 := Equipment_cloak
		  else if (equipment[Equipment_helm].tval > 0) then
		    i3 := Equipment_helm
		  else if (equipment[Equipment_gloves].tval > 0) then
		    i3 := Equipment_gloves
		  else if (equipment[Equipment_belt].tval > 0) then
		    i3 := Equipment_belt
		  else if (equipment[Equipment_bracers].tval > 0) then
		    i3 := Equipment_bracers
		  else
		    i3 := 0;
		  if (i3 > 0) then
		    with equipment[i3] do
		      begin
			inven_temp^.data := equipment[i3];
			objdes(out_val,inven_temp,false);
			msg_print('Your ' + out_val +
				' glows black, then fades.');
			flags := Cursed_worn_bit;
			toac := -randint(5) - randint(5);
			py_bonuses(inven_temp^.data,-1);
			ident := true;
		      end;
		end;
{ Summon Undead }
	  36 :	begin
		  for i3 := 1 to randint(3) do
		    begin
		      y := char_row;
		      x := char_col;
		      summon_undead(y,x);
		    end;
		  ident := true;
		end;
	  37 :	ident := bless(randint(12)+6);
	  38 :	ident := bless(randint(24)+12);
	  39 :	ident := bless(randint(48)+24);
{ Word Of Recall }
	  40 :	begin
		  ident := true;
		  py.flags.word_recall := 25 + randint(30);
		  msg_print('The air about you becomes charged...');
		end;
	  41 :	ident := destroy_area(char_row,char_col);
	  42 :	begin
		  ident := true;
		  msg_print('This is a scroll of wishing.');
		  msg_print(' ');
		  prt('What item do you wish to summon?',1,1);
		  if (get_string(str1,1,34,40)) then
		    begin
		      if (str1[1]>='a') then
			str1[1] := chr(ord(str1[1])-32);
		      prt('What abilities should it have?',1,1);
		      if (get_string(str2,1,32,40)) then
			begin
			if (str1[1]>='a') then
			  str1[1] := chr(ord(str1[1])-32);
			if (summon_item(char_row,char_col,str1,str2,10,true)) then
			  first := false
			end;
		    end
		end;
	  43 :	begin
		  msg_print('You feel your life slipping away!');
		  msg_print(' ');
		  died_from := 'an *EVIL SCROLL*';
		  make_tomb;
		  write_tomb;
		  print_dead_character;
		  draw_cave;
		  msg_print('Huh?  What happened???');
		  py.flags.confused := py.flags.confused + randint(5) + 3;
		  ident := true;
		end;
	  44 :	ident := create_food(-1,-2,-3,-4,0); {make munchies}
	  45 :	;
	  46 :	;
	  47 :	;
	  48 :	;
	  49 :	;
	  50 :	;
	  51 :	;
	  52 :	;
	  53 :	;
	  54 :	;
	  55 :	;
	  56 :	;
	  57 :	;
	  58 :	;
	  59 :	;
	  60 :	;
	  61 :	;
	  62 :	;
	  otherwise ;
	end;
	{ End of Scrolls...					}
			  end;
			if (not(reset_flag)) then
			  begin
			    if (ident) then
			      identify(item_ptr^.data);
			    if (not(first)) then
			      begin
				desc_remain(item_ptr);
				inven_destroy(item_ptr);
				prt_weight;
				if (flags <> 0) then
				  with py.misc do
				    begin
				      exp := exp + round(level/lev);
				      prt_experience;
				    end;
			      end;
			  end;
		      end
		  else
		    if (redraw) then draw_cave;
		end
	    else
	      msg_print('You are not carrying any scrolls.');
	  end
	else
	  msg_print('But you are not carrying anything.');
      end;
