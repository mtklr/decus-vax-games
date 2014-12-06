[inherit('moria.env','dungeon.env')] module inven;

  [global,psect(inven$code)]
  function change_all_ok_stats(nok,nin : boolean) : integer;
      var
		curse	: treas_ptr;
		count	: integer;
      begin
	count := 0;
	curse := inventory_list;
	while (curse <> nil) do
	  begin
	    if (curse^.is_in) then
	      curse^.ok := nin
	    else
	      curse^.ok := nok;
	    if (curse^.ok) then count := count + 1;
	    curse := curse^.next;
	  end;
	change_all_ok_stats := count;
      end;


	{ Returns a '*' for cursed items, a ')' for normal ones -RAK-	}
	{ NOTE: '*' returned only if item has been identified...        }
    [global,psect(inven$code)] function cur_char1 : char;
      begin
	with inven_temp^.data do
	  if (uand(cursed_worn_bit,flags) = 0) then
	    cur_char1 := ')'    { Not cursed...                 }
	  else if (uand(known_cursed_bit,flags2) <> 0) then
	    cur_char1 := '*'    { Cursed and detected by spell }
	  else if (index(name,'^') > 0) then
	    cur_char1 := ')'    { Cursed, but not identified    }
	  else
	    cur_char1 := '*';   { Cursed and identified...      }
      end;


	{ Returns a '*' for cursed items, a ')' for normal ones -RAK-	}
    [global,psect(inven$code)] function cur_char2 : char;
      begin
	with inven_temp^.data do
	  if (uand(cursed_worn_bit,flags) = 0) then
	    cur_char2 := ')'    { Not cursed... }
	  else
	    cur_char2 := '*';   { Cursed...     }
      end;

	{ Returns a ' ' for uninsured items, a '(' for insured ones -DMF-}
    [global,psect(inven$code)] function cur_insure : char;
      begin
	with inven_temp^.data do
	  if (uand(flags2,insured_bit) = 0) then
	    cur_insure := ' '
	  else
	    cur_insure := '(';
      end;

	{ Comprehensive function block to handle all inventory	-RAK-	}
	{ and equipment routines.  Five kinds of calls can take place.  }
	{ Note that '?' is a special call for other routines to display }
	{ only a portion of the inventory, and take no other action.    }
    [global,psect(inven$code)] function inven_command(
		command		: char;
		var item_ptr	: treas_ptr;
		prompt		: vtype) : boolean;
      const
	display_size	= 20;
      var
	com_val,scr_state               : integer;
	exit_flag,test_flag		: boolean;
	save_back			: boolean;
	blegga				: treas_ptr;
	cur_display			: array [1..display_size] of treas_ptr;
	cur_display_size		: integer;
	valid_flag			: boolean;


      procedure clear_display;
	var
		index			: integer;
	begin
	  cur_display_size := 0;
	  for index := 1 to display_size do
	    cur_display[index] := nil;
	end;

{ start changes into start of next page; returns # items in page}
      function display_inv(start : treas_ptr;
				 var next_start : treas_ptr) : integer;
	var
		count,i1 : integer;
		out_val,out_val2 : vtype;
	begin
	  count := 0;
	  while (start <> nil) and (count < display_size) do
	    begin
	      if (start^.ok) then
		begin
		  count := count + 1;
		  if (cur_display[count] <> start) then
		    begin
		      cur_display[count] := start;
		      inven_temp^.data := start^.data;
		      objdes(out_val,inven_temp,true);
		      if (uand(start^.data.flags2,holding_bit) <> 0) then
			if (index(start^.data.name,'|') = 0) then
			  out_val := out_val + bag_descrip(start);
		      if (start^.is_in) then
		        writev(out_val2,cur_insure,chr(96+count),cur_char1,
					'     ',out_val)
		      else
			writev(out_val2,cur_insure,chr(96+count),cur_char1,
					' ',out_val);
		      prt(out_val2,count+1,1);
		    end;
		end;
	      start := start^.next;
	    end;
	  for i1 := count+1 to display_size do
	    begin
	      erase_line(i1+1,1);
	      cur_display[i1] := nil;
	    end;
	  if (start = nil) then	next_start := inventory_list
	  else next_start := start;
	  out_val := prompt;
	  writev(out_val2,chr(count+96));
	  insert_str(out_val,'%N',out_val2);
	  prt(out_val,1,1);
	  display_inv := count;
	end;


	{ Displays inventory items, returns chosen item if want_back. 
	  boolean returns if chosen }
      function show_inven(var ret_ptr : treas_ptr;
			    want_back : boolean;
			   clean_flag : boolean) : boolean;
	var
		command				: char;
		com_val,which,num_choices	: integer;
		exit_flag			: boolean;
		next_inven			: treas_ptr;
		temp_ptr			: treas_ptr;
		wgt				: integer;
		count, count2			: integer;
		caps_flag			: boolean;
	begin
	  show_inven := false;
	  exit_flag := false;
	  num_choices := display_inv(cur_inven,next_inven);
	  repeat
	    if (get_com('',command)) then
	      begin
		com_val := ord(command);
	        caps_flag := false;
		case com_val of
		22,32 : begin
			if (cur_inven = next_inven) then
			  begin
			    prt('Entire inventory displayed.',1,1);
			    num_choices := 0;
			  end
			else
			  begin
			    cur_inven := next_inven;
			    num_choices := display_inv(cur_inven,next_inven);
			  end;
		      end;
        3,25,26,27 : begin
			valid_flag := false;
			exit_flag := true;
		      end;
	49,50,51,52,53,54,55,56,57:
		begin
		  cur_inven := inventory_list;
		  count := 0;
		  if (not ((cur_inven^.next=nil)or(count>=(com_val-49)*20))) then
		  repeat
		    count := count + 1;
		    cur_inven := cur_inven^.next;
		    if (cur_inven^.next = nil) then exit_flag := true
		  until ((cur_inven^.next = nil)or(count>=(com_val-49)*20));
		  if ((cur_inven^.next = nil) and (count <> (com_val-49)*20)) then
		  begin
		    prt('Entire inventory displayed.',1,1);
		    cur_inven := inventory_list;
		  end
		  else
		  begin
		    next_inven := cur_inven;
		    num_choices := display_inv(cur_inven,next_inven);
		  end;
		  prt(': '+chr(com_val),1,75);
		end;
		  otherwise begin
			if (want_back) then
			  begin
			  if (clean_flag) then
			  begin
			  if ((com_val <= ord('Z')) and (com_val >= ord('A')))
			    then caps_flag := true;
			  if (caps_flag) then com_val := com_val - 64
			    else com_val := com_val - 96;
			  end
			  else
			    com_val := com_val - 96;
			  if ((com_val < 1) or (com_val > num_choices)) then
			    begin
			      prt('Invalid selection.',1,1);
			      valid_flag := false;
			      exit_flag := true;
			    end
			  else
			    begin
				if (clean_flag = true) then
				  begin
					ret_ptr := cur_display[com_val];
					  temp_ptr := ret_ptr^.next;
					  wgt := 0;
		  if (uand(ret_ptr^.data.flags2,holding_bit) <> 0) then
  		    begin
		      while ((temp_ptr <> nil) and (temp_ptr^.is_in)) do
		        begin
			  wgt := wgt + temp_ptr^.data.weight * temp_ptr^.data.number;
			  temp_ptr := temp_ptr^.next;
			end;
		    end;
			     if ((ret_ptr^.is_in = false) and (wgt = 0)) then
				  begin
				    if ((caps_flag) and (not( ret_ptr^.data.tval in [10,11,12]))) then
				      count := ret_ptr^.data.number
				    else
				      count := 1;
				    for count2 := 1 to count do
					    inven_destroy (ret_ptr);
					    clear_display;
					    num_choices := display_inv (cur_inven, next_inven);
				  end
			      else
				msg_print('You must empty the bag of holding first.');
					if (num_choices = 0) then 
					  begin
					    prt('No items in inventory.',1,1);
					    valid_flag := false;
					    exit_flag := true;
					  end;
				  end
				else
				  begin
					ret_ptr := cur_display[com_val];
					cur_display[com_val] := nil;
				  	exit_flag := true;
				  	show_inven := true;
				  end;
				end;
			    end
		      else
			begin
			  valid_flag := false;
			  exit_flag := true;
			end;
		      end; { otherwise }
		end; { case }
	      end { command }
	    else
	      begin
		valid_flag := false;
		exit_flag := true;
	      end;
	  until (exit_flag);
	  scr_state := 1;
	end;

	{ Displays equipment items from r1 to end	-RAK-	}
      procedure show_equip(r1 : integer);
	var
	  i1,i2                         : integer;
	  prt1,prt2,out_val             : vtype;
	begin
	  if (r1 > equip_ctr) then      { Last item gone                }
	    prt('',equip_ctr+3,1)
	  else if (r1 > 0) then         { R1 = 0 dummy call             }
	    begin
	      i2 := 0;
	      for i1 := equipment_min to equip_max-1 do { Range of equipment }
		begin
		  with equipment[i1] do
		    if (tval > 0) then
		      begin
			i2 := i2 + 1;
			if (i2 >= r1) then{ Display only given range    }
			  begin
	case i1 of          { Get position          }
		Equipment_primary	: prt1 := ' You are wielding   : ';
		Equipment_helm		: prt1 := ' Worn on head       : ';
		Equipment_amulet	: prt1 := ' Worn around neck   : ';
		Equipment_armor		: prt1 := ' Worn on body       : ';
		Equipment_belt		: prt1 := ' Worn at waist      : ';
		Equipment_shield	: prt1 := ' Worn on arm        : ';
		Equipment_gloves	: prt1 := ' Worn on hands      : ';
		Equipment_bracers	: prt1 := ' Worn on wrists     : ';
		Equipment_right_ring	: prt1 := ' Worn on right hand : ';
		Equipment_left_ring	: prt1 := ' Worn on left hand  : ';
		Equipment_boots		: prt1 := ' Worn on feet       : ';
		Equipment_cloak		: prt1 := ' Worn about body    : ';
		Equipment_light		: prt1 := ' Light source       : ';
		Equipment_secondary	: prt1 := ' Secondary weapon   : ';
		otherwise		  prt1 := ' Unknown value      : ';
	end;
			    inven_temp^.data := equipment[i1];
			    objdes(prt2,inven_temp,true);
			    writev(out_val,cur_insure,chr(i2+96),cur_char2,prt1,prt2);
			    prt(out_val,i2+2,1);
			  end;
		      end;
		end;
	      prt('',i2+3,1);   { Clear last line       }
	      scr_state := 2;   { Set state of screen   }
	    end;
	end;

	{ Remove item from equipment list		-RAK-	}
      function remove(item_val : integer) : treas_ptr;
	var
	  i2,typ				: integer;
	  out_val,prt1,prt2                     : vtype;
	begin
	  typ  := equipment[item_val].tval;
	  inven_temp^.data := equipment[item_val];
	  add_inven_item(equipment[item_val]);
	  inven_weight := inven_weight - inven_temp^.data.number *
					 inven_temp^.data.weight;
	  equipment[item_val] := blank_treasure;
	  equip_ctr      := equip_ctr   - 1;
	  case typ of
	    sling_ammo,bolt,arrow,bow_crossbow_or_sling,hafted_weapon,
		pole_arm,sword,dagger,maul,pick_or_shovel
			: prt1  := 'Was wielding ';
	    Lamp_or_Torch
			: prt1  := 'Light source was ';
	    otherwise
			  prt1  := 'Was wearing ';
	  end;
	  objdes(prt2,inven_temp,true);
	  out_val := prt1 + prt2;
	  msg_print(out_val);
	  if (item_val <> equip_max-1) then     { For secondary weapon  }
	    py_bonuses(inven_temp^.data,-1);
	  remove := inven_temp;
	end;

	{ Unwear routine, remove a piece of equipment	-RAK-	}
      procedure unwear;
	var
	  i1,i2,com_val                         : integer;
	  exit_flag,test_flag                   : boolean;
	  command                               : char;
	  out_val                               : vtype;
	begin
	  if (scr_state = 1) then
	    begin
	      clear(1,1);
	      show_equip(1);
	    end;
	  exit_flag := false;
	  repeat
	    writev(out_val,'(a-',chr(equip_ctr+96),', *,<space> for equipment list,',
		' ^Z to exit) ','Take off which one ?');
	    test_flag := false;
	    msg_print(out_val);
	    repeat
	      inkey(command);
	      com_val := ord(command);
	      case com_val of
		0,3,25,26,27 :  begin
				  test_flag := true;
				  exit_flag := true;
				end;
		42,32        :  begin
				  clear(2,1);
				  show_equip(1);
				end;
		otherwise       begin
				  com_val := com_val - 96;
				  if ((com_val >= 1) and
				      (com_val <= equip_ctr)) then
				    test_flag := true;
				end;
	      end;
	    until (test_flag);
	    if (not(exit_flag)) then
	      begin
		reset_flag := false;    { Player turn   }
		i1 := 0;
		i2 := equipment_min-1;
		repeat
		  i2 := i2 + 1;
		  if (equipment[i2].tval > 0) then
		    i1 := i1 + 1;
		until (i1 = com_val);
		if (uand(cursed_worn_bit,equipment[i2].flags) <> 0) then
		  begin
		    msg_print('Hmmm, it seems to be cursed...');
		    com_val := 0;
		  end
		else
		  remove(i2);
	      end;
	    if (scr_state = 0) then
	      exit_flag := true
	    else if (equip_ctr = 0) then
	      exit_flag := true
	    else if (inven_ctr >= Equipment_min-1) then
	      begin
		show_equip(com_val);
		exit_flag := true
	      end
	    else if (not(exit_flag)) then
	      show_equip(com_val);
	  until(exit_flag);
	  if (scr_state <> 0) then
	    if (equip_ctr = 0) then
	      clear(1,1)
	    else
	      prt('You are currently using -',1,1);
	end;

	{ Wear routine, wear or wield an item		-RAK-	}
      procedure wear;
	var
	  com_val,i1,i2,i3,i4,tmp               : integer;
	  out_val,prt1,prt2                     : vtype;
	  unwear_obj                            : treasure_type;
	  exit_flag,test_flag,listed		: boolean;
	  count,factor				: integer;
	  ptr,item_ptr				: treas_ptr;

	begin
	  exit_flag := false;
	  listed := false;
	  cur_inven := inventory_list;
	  repeat
	   clear_display;
	   change_all_ok_stats(true,false);
	find_range([lamp_or_torch,bow_crossbow_or_sling,
	hafted_weapon,pole_arm,sword,dagger,maul,pick_or_shovel,boots,
	gloves_and_gauntlets,cloak,helm,gem_helm,shield,hard_armor,soft_armor,
	amulet,bracers,belt,ring,valuable_gems_wear],false,ptr,count);
	    item_ptr := inventory_list;
	    test_flag := false;
	    writev(prompt,'(Items a-%N, space for next page, ^Z to exit) Wear/Wield which one?');
	    clear(2,1);
	    test_flag := show_inven(item_ptr,true,false);
                                { Somewhere among the pointers is a bug. }
				{ The above is a STUPID comment. }
	    exit_flag := not test_flag;
	    if (not(exit_flag)) then    { Main logic for wearing        }
	      begin
		reset_flag := false;    { Player turn   }
		test_flag := true;
		case item_ptr^.data.tval of { Slot for equipment    }
		  Lamp_or_Torch		: i1 := Equipment_light;
		  bow_crossbow_or_sling : i1 := Equipment_primary;
		  hafted_weapon		: i1 := Equipment_primary;
		  pole_arm		: i1 := Equipment_primary;
		  sword			: i1 := Equipment_primary;
		  dagger		: i1 := Equipment_primary;
		  maul			: i1 := Equipment_primary;
		  pick_or_shovel	: i1 := Equipment_primary;
		  boots			: i1 := Equipment_boots;
		  gloves_and_gauntlets	: i1 := Equipment_gloves;
		  Cloak			: i1 := Equipment_cloak;
		  helm,gem_helm		: i1 := Equipment_helm;
		  shield		: i1 := Equipment_shield;
		  hard_armor		: i1 := Equipment_armor;
		  soft_armor		: i1 := Equipment_armor;
		  amulet		: i1 := Equipment_amulet;
		  bracers		: i1 := Equipment_bracers;
		  belt			: i1 := Equipment_belt;
		  ring	: if (equipment[Equipment_right_ring].tval = 0) then
			    i1 := Equipment_right_ring
			  else
			    i1 := Equipment_left_ring;
		  valuable_gems_wear :
		    begin
		      if (equipment[equipment_helm].tval = gem_helm) then
		        with equipment[equipment_helm] do
			  begin
			    if (p1 > 0) then
			      begin
				msg_print('The gem adheres itself to your helm!');
				py_bonuses(equipment[equipment_helm],-1);
				if (uand(item_ptr^.data.flags2,
					 negative_gem_bit) <> 0) then
				  begin
				    item_ptr^.data.flags2:= uand(%X'FF7FFFFF',
						item_ptr^.data.flags2);
				    flags := uxor(flags,item_ptr^.data.flags);
				    flags2 := uxor(flags2,item_ptr^.data.flags2);
				    factor := -1;
				  end
				else
				  begin
				   flags := uor(flags,item_ptr^.data.flags);
				   flags2 := uor(flags2,item_ptr^.data.flags2);
				   factor := 1;
				  end;
				cost := cost+factor*item_ptr^.data.cost;
				weight := weight+factor*item_ptr^.data.weight;
				tohit := tohit+factor*item_ptr^.data.tohit;
				todam := todam+factor*item_ptr^.data.todam;
				ac := ac+factor*item_ptr^.data.ac;
				toac := toac+factor*item_ptr^.data.toac;
				p1 := p1 - 1;
				inven_destroy(item_ptr);
				py_bonuses(equipment[equipment_helm],1);
			      end
			    else
			      begin
				msg_print('There is no more room on the helm.');
				if (randint(2) = 1) then
				  begin
				    msg_print('You lose your grip and the gem falls to the floor.');
				    msg_print('The gem shatters!');
				    inven_destroy(item_ptr);
				  end
				else
				  msg_print('You catch the gem in mid air');
			      end;
			  end
		      else
			msg_print('I don''t see how you can use that.');
		      test_flag := false;
		      com_val := 0;
		    end;
		  otherwise
			  begin
			    msg_print('I don''t see how you can use that.');
			    test_flag := false;
			    com_val := 0;
			  end;
		end;
		if (test_flag) then
		  if (equipment[i1].tval > 0) then
		    begin
		      if (uand(cursed_worn_bit,equipment[i1].flags) <> 0) then
			begin
			  inven_temp^.data := equipment[i1];
			  objdes(out_val,inven_temp,false);
			  out_val := 'The ' + out_val + ' you are ';
			  case i1 of
			    Equipment_primary : out_val := out_val + 'wielding ';
			    otherwise   out_val := out_val + 'wearing ';
			  end;
			  msg_print(out_val + 'appears to be cursed.');
			  test_flag := false;
			  com_val := 0;
			end;
		    end;
		if (test_flag) then
		  begin
		    unwear_obj := equipment[i1];
		    equipment[i1] := item_ptr^.data;
		    with equipment[i1] do
		      begin
				{ Fix for torches       }
			if ((subval > 255) and (subval < 512)) then
			  begin
			    number := 1;
			    subval := subval - 255;
			  end;
				{ Fix for weight        }
			inven_weight := inven_weight + weight*number;
		      end;
		    inven_destroy(item_ptr);     { Subtracts weight      }
		    equip_ctr := equip_ctr + 1;
		    py_bonuses(equipment[i1],1);
		    if (unwear_obj.tval > 0) then
		      begin
			equipment[equip_max] := unwear_obj;
			remove(equip_max);
		      end;
		    case i1 of
		      Equipment_primary : prt1 := 'You are wielding ';
		      Equipment_light	: prt1 := 'Your light source is ';
		      otherwise 	  prt1 := 'You are wearing ';
		    end;
		    inven_temp^.data := equipment[i1];
		    objdes(prt2,inven_temp,true);
		    i2 := 0;
		    i3 := equipment_min-1;
		    repeat      { Get the right letter of equipment     }
		      i3 := i3 + 1;
		      if (equipment[i3].tval > 0) then
			i2 := i2 + 1;
		    until (i3 = i1);
		    out_val := prt1 + prt2 + ' (' + chr(i2+96)+cur_char2;
		    msg_print(out_val);
		  end;
	      end;
	    if (scr_state = 0) then
	      exit_flag := true
	    else if (inven_ctr = 0) then
	      exit_flag := true
	  until(exit_flag);
	  if (scr_state <> 0) then prt('You are currently carrying -',1,1);
	end;

	{ Statistics routine, get wizard info on an item	-DMF-	}
      procedure stats;
	var
	  com_val,i1,i2,i3,tmp                  : integer;
	  out_val,prt1,prt2                     : vtype;
	  item_ptr				: treas_ptr;
	  exit_flag,test_flag                   : boolean;
	  trash					: char;
	  line					: integer;
	begin
	  exit_flag := false;
	  repeat
	    writev(prompt,'(Items a-%N, space for next page, ^Z to exit) ',
			  'Statistics on which one ?');
	    clear(1,1);
	    item_ptr := nil;
	    change_all_ok_stats(true,true);
	    clear_display;
	    exit_flag := not show_inven(item_ptr,true,false);
	    if (item_ptr <> nil) then
	      begin
		test_flag := true;
		clear(1,1);
		prt('Name        : ',1,1);
		prt('Description : ',2,1);
		prt('Value       : ',3,1);
		prt('Type        : ',4,1);
		prt('Character   : ',5,1);
		prt('Flags       : ',6,1);
		prt('Flags2      : ',7,1);
		prt('P1          : ',8,1);
		prt('Cost        : ',9,1);
		prt('Subval      : ',10,1);
		prt('Weight      : ',11,1);
		prt('Number      : ',12,1);
		prt('+ To hit    : ',13,1);
		prt('+ To Damage : ',14,1);
		prt('AC          : ',15,1);
		prt('+ To AC     : ',16,1);
		prt('Damage      : ',17,1);
		prt('Level       : ',18,1);
		prt('Insured     : ',19,1);
		prt(item_ptr^.data.name,1,15);
		objdes(out_val,item_ptr,true);
		prt(out_val,2,15);
		writev(out_val,item_ptr^.data.tval:1);
		prt(out_val,3,15);
		case item_ptr^.data.tval of
		  miscellaneous_object	: out_val := 'Miscellaneous object';
		  chest			: out_val := 'Chest';
		  misc_usable		: out_val := 'Miscellaneous usable';
		  valuable_jewelry	: out_val := 'Jewelry';
		  valuable_gems		: out_val := 'Gem';
		  bag_or_sack		: out_val := 'Bag or Sack';
		  valuable_gems_wear	: out_val := 'Wearable Gem';
		  sling_ammo		: out_val := 'Sling ammo';
		  bolt			: out_val := 'Bolt';
		  arrow			: out_val := 'Arrow';
		  spike			: out_val := 'Spike';
		  Lamp_or_Torch		: out_val := 'Lamp or torch';
		  bow_crossbow_or_sling : out_val := 'Ranged weapon';
		  hafted_weapon		: out_val := 'Hafted weapon';
		  pole_arm		: out_val := 'Pole arm';
		  sword			: out_val := 'Sword';
		  dagger		: out_val := 'Light Weapon';
		  maul			: out_val := 'Blunt Weapon';
		  pick_or_shovel	: out_val := 'Pick or shovel';
		  gem_helm		: out_val := 'Gem Helm';
		  boots			: out_val := 'Boots';
		  gloves_and_gauntlets	: out_val := 'Gloves or gauntlets';
		  Cloak			: out_val := 'Cloak';
		  helm			: out_val := 'Helm';
		  shield		: out_val := 'Shield';
		  hard_armor		: out_val := 'Hard armor';
		  soft_armor		: out_val := 'Soft armor';
		  bracers		: out_val := 'Bracers';
		  belt			: out_val := 'Belt';
		  amulet		: out_val := 'Amulet';
		  ring			: out_val := 'Ring';
		  staff			: out_val := 'Staff';
		  rod			: out_val := 'Rod';
		  wand			: out_val := 'Wand';
		  scroll1,scroll2	: out_val := 'Scroll';
		  potion1,potion2	: out_val := 'Potion';
		  flask_of_oil		: out_val := 'Flask of oil';
		  food			: out_val := 'Food';
		  junk_food		: out_val := 'Junk Food';
		  chime			: out_val := 'Chime';
		  horn			: out_val := 'Horn';
		  magic_book		: out_val := 'Magic book';
		  prayer_book		: out_val := 'Prayer book';
		  instrument		: out_val := 'Instrument';
		  song_book		: out_val := 'Song book';
		  otherwise		  out_val := 'Unknown item type';
		end;
		prt(out_val,4,15);
		prt(item_ptr^.data.tchar,5,15);
		print_hex_value(int(item_ptr^.data.flags),6,15);
		print_hex_value(int(item_ptr^.data.flags2),7,15);
		writev(out_val,item_ptr^.data.p1:1);
		prt(out_val,8,15);
		writev(out_val,item_ptr^.data.cost:1);
		prt(out_val,9,15);
		writev(out_val,item_ptr^.data.subval:1);
		prt(out_val,10,15);
		if (item_ptr^.data.weight < 100) then
		  writev(out_val,item_ptr^.data.weight:1,' small')
		else
		  writev(out_val,(item_ptr^.data.weight div 100):1,' large');
		prt(out_val,11,15);
		writev(out_val,item_ptr^.data.number:1);
		prt(out_val,12,15);
		writev(out_val,item_ptr^.data.tohit:1);
		prt(out_val,13,15);
		writev(out_val,item_ptr^.data.todam:1);
		prt(out_val,14,15);
		writev(out_val,item_ptr^.data.ac:1);
		prt(out_val,15,15);
		writev(out_val,item_ptr^.data.toac:1);
		prt(out_val,16,15);
		prt(item_ptr^.data.damage,17,15);
		writev(out_val,item_ptr^.data.level:1);
		prt(out_val,18,15);
		writev(out_val,(uand(item_ptr^.data.flags2,insured_bit) <> 0):1);
		prt(out_val,19,15);
		prt('Hit any key to continue',21,29);
		inkey(trash);
	      end;
	  until(exit_flag);
	end;

	{ Show players money				-DMF-	}
      procedure show_money;
	var
	  prt1	: vtype;
	begin
	  clear(1,1);
	  with py.misc do
	    begin
	      prt('You are carrying -',1,1);
	      writev(prt1,'Mithril  : ',money[mithril]:10);
	      prt(prt1,3,10);
	      writev(prt1,'Platinum : ',money[platinum]:10);
	      prt(prt1,4,10);
	      writev(prt1,'Gold     : ',money[gold]:10);
	      prt(prt1,5,10);
	      writev(prt1,'Silver   : ',money[silver]:10);
	      prt(prt1,6,10);
	      writev(prt1,'Copper   : ',money[copper]:10);
	      prt(prt1,7,10);
	      writev(prt1,'Iron     : ',money[iron]:10);
	      prt(prt1,8,10);
	      writev(prt1,'Total    : ',money[total$]:10);
	      prt(prt1,10,10);
	    end;
	end;

	{ Put an item inside of another item		-DMF-	}
      procedure put_inside;
	var
		put_ptr,into_ptr,temp_ptr	: treas_ptr;
		curse				: treas_ptr;
		count,wgt			: integer;
		redraw,blooey			: boolean;
	procedure destroy_bag(bag : treas_ptr);
	  begin
	    while (bag^.next <> nil) and (bag^.next^.is_in) do
	      begin
		inven_weight := inven_weight - bag^.next^.data.number *
					       bag^.next^.data.weight;
	        delete_inven_item(bag^.next);
	      end;
	    inven_weight := inven_weight - bag^.data.number * bag^.data.weight;
	    delete_inven_item(bag);
	  end;
	begin
	  blooey := false;
	  change_all_ok_stats(true,true);
	  if (get_item(put_ptr,'Put which item?',redraw,inven_ctr,trash_char,
				false,true)) then
	    begin
	      change_all_ok_stats(false,false);
	      temp_ptr := inventory_list;
	      count := 0;
	      while (temp_ptr <> nil) do
		begin
		  if (uand(temp_ptr^.data.flags2,holding_bit) <> 0) then
		    begin
		      temp_ptr^.ok := true;
		      count := count + 1;
		    end;
		  temp_ptr := temp_ptr^.next;
		end;
	      if (count = 0) then
		msg_print('You have nothing to put it into.')
	      else
		begin
		  clear(2,1);
		  if (get_item(into_ptr,'Into which item?',redraw,inven_ctr,
				trash_char,false,true)) then
		    begin
		      if (into_ptr = put_ptr) then
		        msg_print('You can''t seem to fit it inside itself.')
		      else if (uand(put_ptr^.data.flags2,holding_bit) <> 0) then
			begin
			  msg_print('Uh oh, now you''ve done it!');
			  msg_print('You lose the items in both bags!');
			  destroy_bag(put_ptr);
			  destroy_bag(into_ptr);
			end
		      else
		        begin
			  py.flags.paralysis := py.flags.paralysis + 1;
			  reset_flag := false;
			  if (put_ptr = inventory_list) then
			    begin
			      temp_ptr := inventory_list;
			      inventory_list := put_ptr^.next;
			    end
			  else
			    begin
			      curse := inventory_list;
			      while (curse^.next <> put_ptr) do
				curse := curse^.next;
			      temp_ptr := put_ptr;
			      curse^.next := put_ptr^.next;
			    end;
			  curse := inventory_list;
			  while (curse <> into_ptr) do
			    curse := curse^.next;
			  put_ptr^.next := curse^.next;
			  curse^.next := put_ptr;
			  put_ptr^.is_in := true;
			  into_ptr^.insides := into_ptr^.insides + 1;
			  inven_weight := inven_weight - put_ptr^.data.weight *
							 put_ptr^.data.number;
		          msg_print('You stuff it inside');
			  if (uand(put_ptr^.data.flags2,sharp_bit) <> 0) then
			    begin
			      msg_print('You poke a hole in the bag!');
			      blooey := true;
			    end;
			  temp_ptr := into_ptr^.next;
			  wgt := 0;
			  while ((temp_ptr <> nil) and (temp_ptr^.is_in)) do
			    begin
			      wgt := wgt + temp_ptr^.data.weight *
					   temp_ptr^.data.number;
			      temp_ptr := temp_ptr^.next;
			    end;
			  if (wgt > into_ptr^.data.p1) then
			    begin
			      msg_print('The sides of the bag swell and burst!');
			      blooey := true;
			    end;
			  if (blooey) then destroy_bag(into_ptr);
		        end
		    end;
		end;
	    end;
	    cur_inven := inventory_list;
	end;

	{ Take an item out of another item		-DMF-	}
      procedure take_out;
	var
		from_ptr,temp_ptr,curse		: treas_ptr;
		count				: integer;
		redraw,flag			: boolean;
		old_ctr				: integer;
	begin
	 count := change_all_ok_stats(false,true);
	 if (count > 0) then
	  if (get_item(from_ptr,'Remove which item?',redraw,count,trash_char,false,true)) then
	    begin
	      py.flags.paralysis := py.flags.paralysis + 2;
	      reset_flag := false;
	      temp_ptr := inventory_list;
	      while (temp_ptr <> nil) and (temp_ptr <> from_ptr) do
		begin
		  if (uand(temp_ptr^.data.flags2,holding_bit) <> 0) then
		    curse := temp_ptr;
		  temp_ptr := temp_ptr^.next;
		end;
	      if (uand(curse^.data.flags2,swallowing_bit) <> 0) then
		flag := (randint(100) < 6)
	      else
		flag := true;
	      if (flag) then
		begin
	          curse^.insides := curse^.insides - 1;
	          curse := inventory_list;
	          while (curse^.next <> from_ptr) do
		    curse := curse^.next;
	          curse^.next := from_ptr^.next;
	          inven_temp^.data := from_ptr^.data;
	          old_ctr := inven_ctr;
	          inven_carry;
	          {change to next line by Dean; used to begin with
                           if (inven_ctr=old_ctr) then}
		  inven_ctr := inven_ctr - 1;
		  msg_print('You remove the item');
		end
	      else
		msg_print('You make several attempts, but cannot seem to get a grip on it.');
	    cur_inven := inventory_list;
	    end
	  else
	    msg_print('You have nothing to remove.');
	end;

	{ Inventory of selective items, picked by character	-DMF-	}
      procedure selective_inven;
	var
		ptr		: treas_ptr;
		out		: string;
		exit_flag	: boolean;
		command		: char;
	begin
	  ptr := inventory_list;
	  out := ' ';
	  while (ptr <> nil) do
	    begin
	      if (index(out,ptr^.data.tchar) = 0) then
		out := ptr^.data.tchar + out;
	      ptr := ptr^.next;
	    end;
	  out := substr(out,1,length(out)-1);
	  exit_flag := false;
	  repeat
	    prt('What type of items to inventory? ('+out+') ',1,1);
	    if not(get_com('',command)) then
	      exit_flag := true;
	  until (exit_flag) or (index(out,command) <> 0);
	  if not(exit_flag) then
	    begin
	      change_all_ok_stats(false,false);
	      ptr := inventory_list;
	      while (ptr <> nil) do
		begin
		  if (ptr^.data.tchar = command) then
		    ptr^.ok := true;
		  ptr := ptr^.next;
		end;
	      clear_display;
	      clear(1,1);
	      prompt := 'You are currently carrying: space for next page';
	      show_inven(ptr,false,false);
	    end;
	end;

	{ Switch primary and secondary weapons		-RAK-	}
      procedure switch_weapon;
	var
	  prt1,prt2                             : vtype;
	  tmp_obj                               : treasure_type;
	begin
	  if (uand(cursed_worn_bit,equipment[Equipment_primary].flags) <> 0) then
	    begin
	      inven_temp^.data := equipment[Equipment_primary];
	      objdes(prt1,inven_temp,false);
	      msg_print('The ' + prt1 +
			' you are wielding appears to be cursed.');
	    end
	  else
	    begin
		{ Switch weapons        }
	      reset_flag := false;
	      tmp_obj := equipment[Equipment_secondary];
	      equipment[Equipment_secondary] := equipment[Equipment_primary];
	      equipment[Equipment_primary] := tmp_obj;
     { Subtract bonuses      }
	      py_bonuses(equipment[Equipment_secondary],-1);
     { Add bonuses           }
	      py_bonuses(equipment[Equipment_primary],1);
	      if (equipment[Equipment_primary].tval > 0) then
		begin
		  prt1 := 'Primary weapon   : ';
		  inven_temp^.data := equipment[Equipment_primary];
		  objdes(prt2,inven_temp,true);
		  msg_print(prt1 + prt2);
		end;
	      if (equipment[Equipment_secondary].tval > 0) then
		begin
		  prt1 := 'Secondary weapon : ';
		  inven_temp^.data := equipment[Equipment_secondary];
		  objdes(prt2,inven_temp,true);
		  msg_print(prt1 + prt2);
		end;
	    end;
	  if (scr_state <> 0) then
	    begin
	      msg_print('');
	      clear(1,1);
	      prt('You are currently using -',1,1);
	      show_equip(1);
	    end;
	end;

	{ Main logic for INVEN_COMMAND			-RAK-	}
      begin
	inven_command := false;
	exit_flag := false;
	scr_state := 0;
	cur_inven := inventory_list;
	repeat
	  case command of
	    'i' : begin         { Inventory     }
		    if (inven_ctr = 0) then
		      msg_print('You are not carrying anything.')
		    else
		      begin
			clear(1,1);
		        prompt := 'You are currently carrying: space for next page';
		        clear_display;
		        change_all_ok_stats(true,true);
		        show_inven(item_ptr,false,false);
		      end;	
		  end;
	    'c' : begin
		    if (inven_ctr = 0) then
		      msg_print('You are not carrying anything.')
		    else
		      begin
			clear(1,1);
			prompt := 'Warning: a-t/A-T DESTROYS that item: space for next page';
			clear_display;
			change_all_ok_stats(true,true);
			show_inven(item_ptr,true,true);
		      end;
		   end;
	    'e' : begin         { Equipment     }
		    if (equip_ctr = 0) then
		      msg_print('You are not using any equipment.')
		    else if (scr_state <> 2) then
		      begin     { Sets scr_state to 2           }
			clear(1,1);
			prt('You are currently using -',1,1);
			show_equip(1);
		      end;
		  end;
	    's' : begin		{ Statistics of an item	}
		    clear_display;
		    if not(wizard1) and not(wizard2)
		      then msg_print('You *wish*, you sleazy scum-bag!')
		      else
			begin
	        	    if (inven_ctr = 0) then
		                msg_print('You are not carrying anything.')
		            else
		                stats;
		        end;
		  end;
	    't' : begin         { Take off      }
		    if (equip_ctr = 0) then
		      msg_print('You are not using any equipment.')
		    else
		      unwear;   { May set scr_state to 2        }
		  end;
	    'w' : begin         { Wear/wield    }
		    if (inven_ctr = 0) then
		      msg_print('You are not carrying anything.')
		    else
		      wear;     { May set scr_state to 1        }
		  end;
	    'x' : begin
		    if (equipment[Equipment_primary].tval <> 0) then
		      switch_weapon
		    else if (equipment[Equipment_secondary].tval <> 0) then
		      switch_weapon
		    else
		      msg_print('But you are wielding no weapons.');
		  end;
	    'M' : begin
		    if (scr_state <> 4) then
		      begin
			show_money;
			scr_state := 4;
		      end;
		  end;
	    'p' : begin
		    if (inven_ctr = 0) then
		      msg_print('You are not carrying anything.')
		    else
		      put_inside;
		  end;
	    'r' : begin
		    if (inven_ctr = 0) then
		      msg_print('You are not carrying anything.')
		    else
		      take_out;
		  end;
	    'I' : begin
		    if (inven_ctr = 0) then
		      msg_print('You are not carrying anything.')
		    else
		      selective_inven;
		  end;
	{ Special function for other routines                   }
	    '?' : begin { Displays part inven, returns  }
		    cur_inven := inventory_list;
		    clear_display;
		    inven_command := show_inven(item_ptr,true,false);
		    scr_state := 0;     { Clear screen state    }
		  end;
	{ Nonsense command                                      }
	    otherwise ;
	  end;
	  if (scr_state > 0) then
	    begin
	      prt('<e>quip, <i>inven, <t>ake-off, <w>ear/wield, e<x>change, <M>oney, <c>lean.',23,2);
	      if (wizard2) then
		prt('<p>ut item into, <r>emove item from, <s> stats of item, <I>inven selective.',24,2)
	      else
		prt('<p>ut item into, <r>emove item from, <I>inven selective, or ^Z to exit.',24,2);
	      test_flag := false;
	      repeat
		inkey(command);
		com_val := ord(command);
		case com_val of
		  0,3,25,26,27,32 : begin       { Exit from module      }
				    exit_flag := true;
				    test_flag := true;
				  end;
		  otherwise if (command in ['e','i','c','s','t','w','x','M',
				'p','r','I','W']) then	 { Module commands }
			  test_flag := true
			else if (command='?') then ;
		end;
	      until (test_flag);
	      prt('',23,1);
	      prt('',24,1);
	    end
	  else
	    exit_flag := true;
	until(exit_flag);
	if (scr_state > 0) then         { If true, must redraw screen   }
	  inven_command := true;
      end;

	{ Remove an item from inventory_list			-DMF-	}
[global,psect(inven$code)] procedure delete_inven_item(ptr : treas_ptr);
      var
		temp_ptr,curse	: treas_ptr;
      begin
	if (cur_inven = ptr) then
	  cur_inven := cur_inven^.next;
	if (ptr = inventory_list) then
	  begin
	    temp_ptr := inventory_list;
	    inventory_list := ptr^.next;
	    dispose(temp_ptr);
	    inven_ctr := inven_ctr - 1;
	  end
	else
	  begin
	    if (cur_inven = nil) then
	      cur_inven := inventory_list;
	    curse := inventory_list;
	    while (curse^.next <> ptr) do
	      curse := curse^.next;
	    temp_ptr := ptr;
	    curse^.next := ptr^.next;
	    dispose(temp_ptr);
	    inven_ctr := inven_ctr - 1;
	  end;
      end;

	{ Destroy an item in the inventory			-RAK-	}
[global,psect(inven$code)] procedure inven_destroy(item_ptr : treas_ptr);
      begin
	inven_temp^.data := item_ptr^.data;
	with item_ptr^.data do
	  begin
	    if ((number > 1) and (subval < 512))  then
	      begin
		number := number - 1;
		inven_weight := inven_weight - weight;
		inven_temp^.data.number := 1;
	      end
	    else
	      begin
		inven_weight := inven_weight - weight*number;
		delete_inven_item(item_ptr);
	      end;
	  end
      end;

	{ Drops an item from inventory to given location	-RAK-	}
[global,psect(inven$code)] procedure inven_drop(
				item_ptr	: treas_ptr;
				y,x		: integer;
				mon		: boolean);

      var
	i1				: integer;
	temp_ptr			: treas_ptr;

      begin
	with cave[y,x] do
	  begin
	    if (tptr > 0) then pusht(tptr);
	    new(temp_ptr);
	    temp_ptr^.data := item_ptr^.data;
	    if (mon) then
	      inven_temp^.data := item_ptr^.data
	    else
	      inven_destroy(item_ptr);
	    popt(i1);
	    t_list[i1] := inven_temp^.data;
	    tptr := i1;
	    dispose(temp_ptr);
	  end;
      end;

	{ Destroys a type of item on a given percent chance	-RAK-	}
[global,psect(inven$code)] function inven_damage(
			typ		:	obj_set;
			perc		:	integer
					) : integer;
      var
		i1,i2		: integer;
		curse		: treas_ptr;
      begin
	i2 := 0;
	curse := inventory_list;
	while (curse <> nil) do
	  begin
	    with curse^.data do
	      if (tval in typ) then
	        if ((randint(100) < perc) and (curse^.is_in = false)) then
		  if ((uand(curse^.data.flags2,holding_bit) <> 0) and
		      (curse^.insides = 0)) or
		     (uand(curse^.data.flags2,holding_bit) = 0) then
		    begin
		      inven_destroy(curse);
		      i2 := i2 + 1;
		    end;
	    curse := curse^.next;
	  end;
	inven_damage := i2;
      end;

	{ Check inventory for too much weight			-RAK-	}
[global,psect(inven$code)] function inven_check_weight : boolean;
      var
	item_wgt	: integer;
      begin
	with inven_temp^.data do
	  item_wgt := number*weight;
		{ Current stuff + weight <= max weight }
	inven_check_weight := inven_weight + item_wgt <= (weight_limit*100);
      end;

	{ Check to see if he will be carrying too many objects	-RAK-	}
[global,psect(inven$code)] function inven_check_num : boolean;
      begin
	inven_check_num := true;
      end;

	{ Add item to inventory_list				-DMF-	}
[global,psect(inven$code)] function add_inven_item(item : treasure_type) : treas_ptr;
      var
		item_num,wgt,typ,subt,count	: integer;
		flag				: boolean;
		curse,new_item			: treas_ptr;
      procedure insert(ptr : treas_ptr; wgt : integer);
	var
		cur	: treas_ptr;
	begin
	  if (ptr = inventory_list) then
	    begin
	      new_item^.next := inventory_list;
	      inventory_list := new_item;
	    end
	  else
	    begin
	      cur := inventory_list;
	      while (cur^.next <> ptr) do
	        cur := cur^.next;
	      new_item^.next := ptr;
	      cur^.next := new_item;
	    end;
	end;
      begin
	if (inventory_list = nil) then
	  begin
	    new(inventory_list);
	    inventory_list^.data := item;
	    inventory_list^.ok := false;
	    inventory_list^.insides := 0;
	    inventory_list^.is_in := false;
	    inventory_list^.next := nil;
	    inven_weight := inven_weight + item.number * item.weight;
	    add_inven_item := inventory_list;
	    inven_ctr := inven_ctr + 1;
	  end
	else
	  begin
	    with item do
	      begin
		item_num := number;
		typ := tval;
		subt := subval;
		wgt := number * weight;
	      end;
	    new(new_item);
	    new_item^.data := item;
	    new_item^.ok := false;
	    new_item^.insides := 0;
	    new_item^.is_in := false;
	    new_item^.next := nil;
	    curse := inventory_list;
	    repeat
	      with curse^.data do
		if (typ = tval) then
		  begin
		    if (subt = subval) then
		      if (subt > 255) then
			begin
			  number := number + item_num;
			  inven_weight := inven_weight + wgt;
			  add_inven_item := curse;
			  flag := true;
			end;
		  end
		else if (tval < typ) then
		  begin
		    insert(curse,wgt);
		    inven_ctr := inven_ctr + 1;
		    inven_weight := inven_weight + wgt;
		    add_inven_item := new_item;
		    flag := true;
		  end;
	      curse := curse^.next;
	      if (curse <> nil) and (curse^.is_in) then
		while (curse <> nil) and (curse^.is_in) do
		  curse := curse^.next;
	    until ((flag) or (curse = nil));
	    if (not(flag)) then
	      begin
	        curse := inventory_list;
		while (curse^.next <> nil) do
 		  curse := curse^.next;
	        curse^.next := new_item;
		add_inven_item := new_item;
		inven_ctr := inven_ctr + 1;
	        inven_weight := inven_weight + wgt;
	      end;
	  end;
      end;

	{ Add the item in INVEN_MAX to players inventory.  Return the	}
	{ item position for a description if needed...		-RAK-	}
[global,psect(inven$code)] function inven_carry : treas_ptr;
      begin
	inven_carry := add_inven_item(inven_temp^.data);
      end;


	{ Drop money onto ground				-DMF-	}
      function drop_money(var ptr : treas_ptr; var clr : boolean) : boolean;
	var
		out_val		: vtype;
		out_val2	: vtype;
		flag		: boolean;
		test_flag	: boolean;
		command		: char;
		com_val		: integer;
		reset_flag	: boolean;
		max		: integer;
		mon_name	: vtype;
		amt		: integer;
		pos		: integer;
		mon_type	: integer;
      begin
       drop_money := false;
       ptr := nil;
       clr := false;
       if (cave[char_row,char_col].tptr > 0) then
	begin
	 msg_print('There is something there already.');
	 clr := true;
	end
       else
       with py.misc do begin
	com_val := get_money_type('Drop ',reset_flag,false);
	reset_flag := not(reset_flag);
	if not(reset_flag) then
	  begin
	    case com_val of
	      109 : mon_name := 'mithril';
	      112 : mon_name := 'platinum';
	      103 : mon_name := 'gold';
	      115 : mon_name := 'silver';
	       99 : mon_name := 'copper';
	      105 : mon_name := 'iron';
	    end;
	    out_val := 'Drop how much ' + mon_name + ' (1-';
	    coin_stuff(chr(com_val),mon_type);
	    max := money[mon_type];
	    writev(out_val2,max:1);
	    out_val := out_val + out_val2 + '), ^Z to exit : ';
	    prt(out_val,1,1);
	    if (get_string(out_val2,1,length(out_val)+1,10)) then
	      begin
		readv(out_val2,amt,error:=continue);
		if (amt > max) then amt := max;
		if (amt < 1) then
		  begin
		    msg_print('You don''t have that much money.');
		    clr := true;
		  end
		else
		  begin
		    money[mon_type] := money[mon_type] - amt;
		    case mon_type of
			1 : pos := iron_pos;
			2 : pos := copper_pos;
			3 : pos := silver_pos;
			4 : pos := gold_pos;
			5 : pos := platinum_pos;
			6 : pos := mithril_pos;
		    end;
		    inven_temp^.data := gold_list[pos];
		    inven_temp^.data.number := amt;
		    ptr := inven_temp;
		    drop_money := true;
		    inven_weight := inven_weight - coin$weight * amt;
		    reset_total_cash;
		    prt_gold;
		  end;
	      end
	    else
	      erase_line(msg_line,msg_line);
	  end;
       end;
      end;

	{ Get the ID of an item and return the CTR value of it	-RAK-	}
    [global,psect(inven$code)] function get_item(
			var com_ptr	: treas_ptr;
			pmt		: vtype;
			var redraw	: boolean;
			count		: integer;
			var choice	: char;
			mon		: boolean;
			no_wait		: boolean := false) : boolean;
      var
	  command                                       : char;
	  out_val                                       : vtype;
	  test_flag                                     : boolean;
	  i1						: integer;
	  stay						: boolean;
	  only_money 					: boolean;

      begin
	only_money := false;
	stay := false;
	get_item := false;
	if (count < 1) then only_money  := true;
	com_val := 0;
	  begin
	    if (mon) then
	      if (count > 20) then
		writev(out_val,'(Items a-t,$, <space> for inventory, ^Z to exit) ',
				pmt)
	      else if (not only_money) then
		writev(out_val,'(Items a-',chr(count+96),
			       ',$, <space> for inventory list, ^Z to exit) ',pmt)
	      else
		writev(out_val,' ')
	    else
 	      if (count > 20) then
	        writev(out_val,'(Items a-t, <space> for inventory, ^Z to exit) ',pmt)
 	      else
	        writev(out_val,'(Items a-',chr(count+96),
			       ', <space> for inventory list, ^Z to exit) ',pmt);
	    test_flag := false;
	    if (not(no_wait)) then prt(out_val,1,1);
	    repeat
	      if (only_money) then
		command := '$'
	      else
	        begin 
	          if (not(no_wait)) then
		    inkey(command)
	          else
		    command := '*';
	        end;
	      choice := command;
	      com_val := ord(command);
	      case com_val of
		0,3,25,26,27 :  begin
				  test_flag := true;
				  reset_flag := true;
				end;
		42, 32       :  begin
				  clear(2,1);
				  writev(out_val,'(Items a-%N, <space> for next page, ^Z to exit) ',pmt);
				  get_item := inven_command('?',com_ptr,out_val);
				  test_flag := true;
				  redraw := true;
				end;
		36 :		if (mon) then begin
				  test_flag := true;
				  redraw := false;
				  with py.misc do
				    if (money[1]+money[2]+money[3]+money[4]+
			money[5]+money[6] > 0) then
					get_item := drop_money(com_ptr,stay)
				    else
				      begin
					msg_print('You have no money to drop.');
					get_item := false;
					stay := true;
				      end;
				end;
		49,50,51,52,53,54,55,56,57:
		begin
		  test_flag := true;
		  prt(chr(com_val),1,length(out_val)+2);
		  inkey(choice);
		  prt(choice,1,length(out_val)+3);
		  if ((choice <= 't') and (choice >= 'a')) then
		  begin
		  com_ptr := inventory_list;
		  count := 0;
		  if (not ((com_ptr^.next=nil)or(count>=(com_val-49)*20+ord(choice)-97))) then
		  repeat
		  if ((not(com_ptr^.is_in)) and (uand(com_ptr^.data.flags2,holding_bit) = 0)) then count := count + 1;
		    com_ptr := com_ptr^.next;
		  until ((com_ptr^.next = nil)or(count = (com_val-49)*20+ord(choice)-97));
		  if ((com_ptr^.next = nil) and (count<>(com_val-49)*20+ord(choice)-97)) then
		  begin
		    get_item := false;
		    stay := true;
		    prt('Invalid Selection.',1,1);
		  end
		  else
		    get_item := true;
		  end;
		end;
		otherwise       begin
				  com_val := com_val - 96;
				  if ((com_val >= 1) and
				      (com_val <= count) and
				      (com_val <= 20)) then
				    begin
				      com_ptr := inventory_list;
				      i1 := 1;
				      while (com_ptr^.ok = false) do
					com_ptr := com_ptr^.next;
				      while (i1 <> com_val) do
					begin
					  if (com_ptr^.ok) then
					    i1 := i1 + 1;
					  com_ptr := com_ptr^.next;
					  while (com_ptr^.ok = false) do
					    com_ptr := com_ptr^.next;
					end;
				      test_flag := true;
				      get_item := true;
				    end;
				end;
	      end;
	    until (test_flag);
	    if not(stay) then erase_line(msg_line,msg_line);
	  end;
      end;
end.


