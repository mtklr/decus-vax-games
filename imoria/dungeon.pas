[inherit('moria.env','sys$share:starlet'),environment('dungeon.env')]
module dungeon;

    var
	dir_val                 : integer;      { For movement          }
	y,x,moves               : integer;      { For movement          }
	i1,i2,tmp1              : integer;      { Temporaries           }
	old_chp,old_cmana       : integer;      { Detect change         }
	regen_amount            : real;         { Regenerate hp and mana}
	command                 : char;         { Last command          }
	out_val                 : vtype;        { For messages          }
	tmp_str                 : vtype;        { Temporary             }
	moria_flag              : boolean;      { Next level when true  }
	reset_flag              : boolean;      { Do not move creatures }
	search_flag             : boolean;      { Player is searching   }
	teleport_flag           : boolean;      { Handle telport traps  }
	player_light            : boolean;      { Player carrying light }
	save_msg_flag           : boolean;      { Msg flag after INKEY  }
	s1,s2,s3,s4		: ttype;	{ Summon item strings	}
	i_summ_count		: integer;	{ Summon item count	}
	tstat			: stat_set;
	trash_ptr		: treas_ptr;
	trash_char		: char;
	f1			: text;

	%INCLUDE 'TRADE.INC'
	%INCLUDE 'INSURANCE.INC'
	%INCLUDE 'BANK.INC'
	{ General spells and misc routines	}
	%INCLUDE 'SPELLS.INC'

	{ Moves creature record from one space to another	-RAK-	}
    [global,psect(moria$code)] procedure move_rec(y1,x1,y2,x2 : integer);
      begin
	if ((y1 <> y2) or (x1 <> x2)) then
	  begin
	    cave[y2,x2].cptr := cave[y1,x1].cptr;
	    cave[y1,x1].cptr := 0
	  end
      end;

    [global,psect(moria$code)] procedure update_stat(tstat : stat_set);
      begin
	with py.stat do
	  c[tstat] := squish_stat(p[tstat] + 10*m[tstat] - l[tstat]);
      end;

	{ Changes stats up or down for magic items		-RAK-	}
    [global,psect(moria$code)] procedure change_stat(
			tstat	: stat_set;
			amount	: integer;
			factor	: integer);
      begin
	with py.stat do
	  begin
	    m[tstat] := m[tstat] + amount*factor;
	    update_stat(tstat)
	  end;
      end;

	{ Changes speed of monsters relative to player		-RAK-	}
	{ Note: When the player is sped up or slowed down, I simply     }
	{       change the speed of all the monsters.  This greatly     }
	{       simplified the logic...                                 }
     [global,psect(moria$code)] procedure change_speed(num : integer);
      var
		i1,old			: integer;
      begin
	py.flags.speed := py.flags.speed + num;
	i1 := muptr;
	while (i1 <> 0) do
	  begin
	    m_list[i1].cspeed := m_list[i1].cspeed + num;
	    i1 := m_list[i1].nptr;
	  end;
      end;


	{ Player bonuses					-RAK-	}
	{ When an item is worn or taken off, this re-adjusts the player }
	{ bonuses.  Factor=1 : wear; Factor=-1 : removed                }
   [global,psect(moria$code)] procedure py_bonuses(
			tobj	: treasure_type;
			factor	: integer);
      var
	item_flags,item_flags2          : unsigned;
	i1,i2,old_dis_ac                : integer;
      begin
	with py.flags do
	  begin
	    if (slow_digest) then
	      food_digested := food_digested + 1;
	    if (regenerate) then
	      food_digested := food_digested - 3;
	    see_inv     := false;
	    teleport    := false;
	    free_act    := false;
	    slow_digest := false;
	    aggravate   := false;
	    for tstat := sr to ca do
	      sustain[tstat] := false;
	    fire_resist := false;
	    hunger_item := false;
	    acid_resist := false;
	    cold_resist := false;
	    regenerate  := false;
	    lght_resist := false;
	    ffall       := false;
	  end;

	if (uand(strength_worn_bit,tobj.flags) <> 0) then
	  begin
	    change_stat(sr,tobj.p1,factor);
	    print_stat := uor(%X'0001',print_stat);
	  end;
	if (uand(magic_proof_worn_bit,tobj.flags2) <> 0) then
	  begin
	    py.misc.save := py.misc.save + (25 * factor);
	  end;
	if (uand(bad_repute_worn_bit,tobj.flags2) <> 0) then
	  begin
	    change_rep(-100*factor); {XXX hey!  this is bad! new variable!-ste}
	  end;
	if (uand(disarm_worn_bit,tobj.flags2) <> 0) then
	  begin
	    py.misc.disarm := py.misc.disarm + (tobj.p1 * factor);
	  end;
	if (uand(dexterity_worn_bit,tobj.flags) <> 0) then
	  begin
	    change_stat(dx,tobj.p1,factor);
	    print_stat := uor(%X'0002',print_stat);
	  end;
	if (uand(constitution_worn_bit,tobj.flags) <> 0) then
	  begin
	    change_stat(cn,tobj.p1,factor);
	    print_stat := uor(%X'0004',print_stat);
	  end;
	if (uand(intelligence_worn_bit,tobj.flags) <> 0) then
	  begin
	    change_stat(iq,tobj.p1,factor);
	    print_stat := uor(%X'0008',print_stat);
	  end;
	if (uand(wisdom_worn_bit,tobj.flags) <> 0) then
	  begin
	    change_stat(ws,tobj.p1,factor);
	    print_stat := uor(%X'0010',print_stat);
	  end;
	if (uand(charisma_worn_bit,tobj.flags) <> 0) then
	  begin
	    change_stat(ca,tobj.p1,factor);
	    print_stat := uor(%X'0020',print_stat);
	  end;
	if (uand(searching_worn_bit,tobj.flags) <> 0) then
	  begin
	    py.misc.srh := py.misc.srh + (tobj.p1 * factor);
	    py.misc.fos := py.misc.fos - (tobj.p1 * factor);
	  end;
	if (uand(stealth_worn_bit,tobj.flags) <> 0) then
	  py.misc.stl := py.misc.stl + (tobj.p1 * factor) + factor;
	if (uand(speed_worn_bit,tobj.flags) <> 0) then
	  begin
	    i1 := tobj.p1*factor;
	    change_speed(-i1);
	  end;
	if (uand(blindness_worn_bit,tobj.flags) <> 0) then
	  if (factor > 0) then
	    py.flags.blind := py.flags.blind + 1000;
	if (uand(timidness_worn_bit,tobj.flags) <> 0) then
	  if (factor > 0) then
	    py.flags.afraid := py.flags.afraid + 50;
	if (uand(infra_vision_worn_bit,tobj.flags) <> 0) then
	  py.flags.see_infra := py.flags.see_infra + (tobj.p1 * factor);
	if (uand(swimming_worn_bit,tobj.flags2) <> 0) then
	  begin
	    i1 := tobj.p1*factor;
	  end;
	if (uand(increase_carry_worn_bit,tobj.flags2) <> 0) then
	  begin
	    case tobj.p1 of
	      1 : i1 := 500;
	      2 : i1 := 1000;
	      3 : i1 := 1750;
	      4 : i1 := 2500;
	      5 : i1 := 3500;
	      6 : i1 := 4500;
	      7 : i1 := 6000;
	    end;
	    py.misc.xtr_wgt := py.misc.xtr_wgt + i1 * factor;
	  end;
	with py.misc do
	  begin
	    old_dis_ac := dis_ac;
	    ptohit  := tohit_adj;       { Real To Hit   }
	    ptodam  := todam_adj;       { Real To Dam   }
	    ptoac   := toac_adj;        { Real To AC    }
	    pac     := 0;               { Real AC       }
	    dis_th  := ptohit;  { Display To Hit        }
	    dis_td  := ptodam;  { Display To Dam        }
	    dis_ac  := 0;       { Display To AC         }
	    dis_tac := ptoac;   { Display AC            }
	    for i1 := equipment_min to equip_max-2 do
	      with equipment[i1] do
		if (tval > 0) then
		  begin
		    if (uand(cursed_worn_bit,flags) = 0) then
		      begin
			pac    := pac    + ac;
			dis_ac := dis_ac + ac;
		      end;
		    ptohit := ptohit + tohit;
		    ptodam := ptodam + todam;
		    ptoac  := ptoac  + toac;
		    if (index(name,'^') = 0) then
		      begin
			dis_th  := dis_th  + tohit;
			dis_td  := dis_td  + todam;
			dis_tac := dis_tac + toac;
		      end;
		  end;
	    dis_ac := dis_ac + dis_tac;

		{ Add in temporary spell increases	}
	    with py.flags do
	      begin
		if (invuln > 0) then
		  begin
		    pac    := pac    + 100;
		    dis_ac := dis_ac + 100;
		  end;
		if (blessed > 0) then
		  begin
		    pac    := pac    + 5;
		    dis_ac := dis_ac + 5;
		  end;
		if (detect_inv > 0) then
		  see_inv := true;
	      end;

	    if (old_dis_ac <> dis_ac) then
	      print_stat := uor(%X'0040',print_stat);
	    item_flags2 := 0;
	    item_flags  := 0;
	    for i1 := equipment_min to equip_max-2 do
	      with equipment[i1] do
		begin
		  item_flags  := uor(item_flags,flags);
		  item_flags2 := uor(item_flags2,flags2);
		end;
	    with py.flags do
	      begin
		slow_digest := uand(slow_digestion_worn_bit,item_flags) <> 0;
	        aggravate := uand(aggravation_worn_bit,item_flags) <> 0;
		teleport := uand(teleportation_worn_bit,item_flags) <> 0;
		regenerate := uand(regeneration_worn_bit,item_flags) <> 0;
		hunger_item := uand(hunger_worn_bit,item_flags2) <> 0;
		fire_resist := uand(resist_fire_worn_bit,item_flags) <> 0;
		acid_resist := uand(resist_acid_worn_bit,item_flags) <> 0;
		cold_resist := uand(resist_cold_worn_bit,item_flags) <> 0;
		free_act := uand(free_action_worn_bit,item_flags) <> 0;
		see_inv := uand(see_invisible_worn_bit,item_flags) <> 0;
		lght_resist := uand(resist_lightning_worn_bit,item_flags) <> 0;
		ffall := uand(feather_fall_worn_bit,item_flags) <> 0;
	      end;
	    for i1 := equipment_min to equip_max-2 do
	      with equipment[i1] do
		if (uand(sustain_stat_worn_bit,flags) <> 0) then
		  if ((p1>0) and (p1<7)) then
		    py.flags.sustain[p1-1] := true;
	    with py.flags do
	      begin
		if (slow_digest) then
		  food_digested := food_digested - 1;
		if (regenerate) then
		  food_digested := food_digested + 3;
	      end;
	  end;
      end;


	{ Given an row (y) and col (x), this routine detects  -RAK-	}
	{ when a move off the screen has occurred and figures new borders}
    [global,psect(moria$code)] function get_panel(y,x : integer) : boolean;
      var
		prow,pcol       : integer;
      begin
	prow := panel_row;
	pcol := panel_col;
	if ((y < panel_row_min + 2) or (y > panel_row_max - 2)) then
	  begin
	    prow := trunc((y - 2)/(screen_height/2));
	    if (prow > max_panel_rows) then
	      prow := max_panel_rows;
	  end;
	if ((x < panel_col_min + 3) or (x > panel_col_max - 3)) then
	  begin
	    pcol := trunc((x - 3)/(screen_width/2));
	    if (pcol > max_panel_cols) then
	      pcol := max_panel_cols;
	  end;
	if ((prow <> panel_row) or (pcol <> panel_col) or not(cave_flag)) then
	  begin
	    panel_row := prow;
	    panel_col := pcol;
	    panel_bounds;
	    get_panel := true;
	    cave_flag := true;
	  end
	else
	  get_panel := false;
      end;


	{ Searches for hidden things... 			-RAK-	}
    [global,psect(moria$code)] procedure search(y,x,chance : integer);
      var
		i1,i2           : integer;
      begin
	with py.flags do
	  if (confused+blind > 0) then
	    chance := trunc(chance/10.0)
	   else if (no_light) then
	    chance := trunc(chance/5.0);
	for i1 := (y - 1) to (y + 1) do
	  for i2 := (x - 1) to (x + 1) do
	    if (in_bounds(i1,i2)) then
	      if ((i1 <> y) or (i2 <> x)) then
		if (randint(100) < chance) then
		  with cave[i1,i2] do
	{ Search for hidden objects             }
		    if (tptr > 0) then
		      with t_list[tptr] do
		{ Trap on floor?                }
			if (tval = Unseen_trap) then
			  begin
			    msg_print('You have found ' + name + '.');
			    change_trap(i1,i2);
			    find_flag := false;
			  end
		{ Secret door?                  }
			else if (tval = Secret_door) then
			  begin
			    msg_print('You have found a secret door.');
			    fval := corr_floor2.ftval;
			    change_trap(i1,i2);
			    find_flag := false;
			  end
		{ Chest is trapped?             }
			else if (tval = chest) then
			  begin
			    if (flags > 1) then
			      if (index(name,'^') > 0) then
				begin
				  known2(name);
		msg_print('You have discovered a trap on the chest!');
				end;
			  end;
      end;


	{ Turns off Find_flag if something interesting appears	-RAK-	}
	{ BUG: Does not handle corridor/room corners, but I didn't want }
	{      to add a lot of checking for such a minor detail         }
    [global,psect(moria$code)] procedure area_affect(dir,y,x : integer);
      var
		z               : array [1..3] of integer;
		i1,row,col      : integer;
      begin
	if (cave[y,x].fval = 4) then
	  begin
	    i1 := 0;
	    if (next_to4(y,x,[4,5,6]) > 2) then
	      find_flag := false;
	  end;
	if ((find_flag) and (py.flags.blind < 1)) then
	  begin
	    case dir of
	  1,3,7,9 :     begin
			  z[1] := rotate_dir(dir,-1);
			  z[2] := dir;
			  z[3] := rotate_dir(dir,1);
			end;
	  2,4,6,8 :     begin
			  z[1] := rotate_dir(dir,-2);
			  z[2] := dir;
			  z[3] := rotate_dir(dir,2);
			end;
	    end;
	    for i1 := 1 to 3 do
	      begin
		row := y;
		col := x;
		if (move(z[i1],row,col)) then
		  with cave[row,col] do
		    begin
			{ Empty doorways        }
		      if (fval = 5) then
			find_flag := false;
			{ Objects player can see}
			{ Including doors       }
		      if (find_flag) then
			if (player_light) then
			  begin
			    if (tptr > 0) then
			      if (not(t_list[tptr].tval in [Unseen_trap,Secret_door])) then
				find_flag := false;
			  end
			else if ((tl) or (pl) or (fm)) then
			  if (tptr > 0) then
			    if (not(t_list[tptr].tval in [Unseen_trap,Secret_door])) then
			      find_flag := false;
			{ Creatures             }
		      if (find_flag) then
			if ((tl) or (pl) or (player_light)) then
			  if (cptr > 1) then
			    with m_list[cptr] do
			      if (ml) then
				find_flag := false;
		    end
	      end
	  end;
      end;


	{ Player is on an object.  Many things can happen BASED -RAK-	}
	{ on the TVAL of the object.  Traps are set off, money and most }
	{ objects are picked up.  Some objects, such as open doors, just}
	{ sit there...                                                  }
    [global,psect(moria$code)] procedure carry(y,x : integer);
      var
	item_ptr			: treas_ptr;
	out_val                         : vtype;
	page_char			: char;
	inv_char			: char;
	tmp_ptr				: treas_ptr;
	count				: integer;
	money_flag			: boolean;

      begin
	money_flag := false;
	find_flag := false;
	with cave[y,x] do
	  begin
	    inven_temp^.data := t_list[tptr];
		{ There's GOLD in them thar hills!      }
		{ OPPS!                                 }
	    if (t_list[tptr].tval in trap_set) then
	      hit_trap(y,x)
		{ Attempt to pick up an object.         }
	    else if (t_list[tptr].tval <= valuable_metal) then
	      begin
		if (inven_check_num) then	{ Too many objects?     }
		  if (inven_check_weight) then  { Weight limit check    }
		    begin			{ Okay, pick it up      }
		      pusht(tptr);
		      tptr := 0;
		      if (inven_temp^.data.tval = valuable_metal) then
			begin
			  item_ptr := money_carry;
			  money_flag := true;
			end
		      else
			item_ptr := inven_carry;
		      prt_weight;
		      objdes(out_val,item_ptr,true);
		      if (money_flag) then
			begin
			  page_char := '$';
			  inv_char := '$';
			end
		      else
		      begin
			count := 0;
			tmp_ptr := inventory_list;
			if (tmp_ptr^.next = item_ptr^.next) then
			  count := 0
			else	
			repeat
			  count := count + 1;
			  tmp_ptr := tmp_ptr^.next;
			until (tmp_ptr^.next = item_ptr^.next);
			if ((count div 20) > 9) then
			  begin
			    page_char := '*';
			    inv_char:= '*';
		          end
			else	
			begin	
			  page_char := chr((count div 20)+49);
			  inv_char := chr(count - (count div 20)*20 + 97);
			end;
		      end;
		      out_val := 'You have ' + out_val+'. '+'('+page_char+inv_char+')';
		      msg_print(out_val);
		    end
		  else
		    msg_print('You can''t carry that much weight.')
		else
		  msg_print('You can''t carry that many items.');
	      end;
	  end;
      end;


	{ Package for moving the character's light about the screen     }
	{ Three cases : Normal, Finding, and Blind              -RAK-   }
    [global,psect(moria$code)] procedure move_light(y1,x1,y2,x2 : integer);

	{ Given two sets of points, draw the block		}
    procedure draw_block(y1,x1,y2,x2 : integer);
      var
	i1,i2,xpos,xmax				: integer;
	topp,bott,left,righ			: integer;
	new_topp,new_bott,new_left,new_righ	: integer;
	floor_str,save_str			: vtype;
	tmp_char				: char;
	flag					: boolean;
      begin
	{ From uppermost to bottom most lines player was on...  }
	{ Points are guaranteed to be on the screen (I hope...) }
	topp := maxmin(y1,y2,panel_row_min);
	bott := minmax(y1,y2,panel_row_max);
	left := maxmin(x1,x2,panel_col_min);
	righ := minmax(x1,x2,panel_col_max);
	new_topp := y2 - 1;     { Margins for new things to appear}
	new_bott := y2 + 1;
	new_left := x2 - 1;
	new_righ := x2 + 1;
	for i1 := topp to bott do
	  begin
	    floor_str := '';    { Null out print string         }
	    xpos      := 0;
	    save_str  := '';
	    for i2 := left to righ do   { Leftmost to rightmost do}
	      begin
		with cave[i1,i2] do
		  begin
		    if ((pl) or (fm)) then
		      flag := (((i1=y1) and (i2=x1)) or ((i1=y2) and (i2=x2)))
		    else
		      begin
			flag := true;
			if (((i1 >= new_topp) and (i1 <= new_bott)) and
			    ((i2 >= new_left) and (i2 <= new_righ))) then
			  begin
			    if (tl) then
			      if (fval in pwall_set) then
				pl := true
			      else if (tptr > 0) then
				if (t_list[tptr].tval in light_set) then
				  if (not(fm)) then
				    fm := true;
			  end
		      end;
		    if ((pl) or (tl) or (fm)) then
		      loc_symbol(i1,i2,tmp_char)
		    else
		      tmp_char := ' ';
		    if (py.flags.image > 0) then
		      if (randint(12) = 1) then
			tmp_char := chr(randint(95) + 31);
		    if (flag) then
		      begin
			if (xpos = 0) then xpos := i2;
			xmax := i2;
		      end;
		    if (xpos > 0) then floor_str := floor_str + tmp_char;
		  end;
	      end;
	    if (xpos > 0) then
	      begin
		i2 := i1;       { Var for PRINT cannot be loop index}
		print(substr(floor_str,1,1+xmax-xpos),i2,xpos);
	      end;
	  end;
      end;


	{ Normal movement					}
    procedure sub1_move_light;
      var
	i1,i2                                   : integer;
      begin
	light_flag := true;
	for i1 := y1-1 to y1+1 do       { Turn off lamp light   }
	  for i2 := x1-1 to x1+1 do
	    cave[i1,i2].tl := false;
	for i1 := y2-1 to y2+1 do
	  for i2 := x2-1 to x2+1 do
	    cave[i1,i2].tl := true;
	draw_block(y1,x1,y2,x2);        { Redraw area           }
      end;

	{ When FIND_FLAG, light only permanent features 	}
    procedure sub2_move_light;
      var
	i1,i2,xpos                      : integer;
	floor_str,save_str              : vtype;
	tmp_char                        : char;
	flag                            : boolean;
      begin
	if (light_flag) then
	  begin
	    for i1 := y1-1 to y1+1 do
	      for i2 := x1-1 to x1+1 do
		cave[i1,i2].tl := false;
	    draw_block(y1,x1,y1,x1);
	    light_flag := false;
	  end;
	for i1 := y2-1 to y2+1 do
	  begin
	    floor_str := '';
	    save_str  := '';
	    xpos := 0;
	    for i2 := x2-1 to x2+1 do
	      with cave[i1,i2] do
		begin
		  flag := false;
		  if (not((fm) or (pl))) then
		    begin
		      tmp_char := ' ';
		      if (player_light) then
			if (fval in pwall_set) then
			  begin
			    pl := true; { Turn on perm light    }
			    loc_symbol(i1,i2,tmp_char);
			    flag := true;
			  end
			else
			  if (tptr > 0) then
			    if (t_list[tptr].tval in light_set) then
			      begin
				fm := true;     { Turn on field marker  }
				loc_symbol(i1,i2,tmp_char);
				flag := true;
			      end;
		    end
		  else
		    loc_symbol(i1,i2,tmp_char);
		  if (flag) then
		    begin
		      if (xpos = 0) then xpos := i2;
		      if (length(save_str) > 0) then
			begin
			  floor_str := floor_str + save_str;
			  save_str := '';
			end;
		      floor_str := floor_str + tmp_char;
		    end
		  else if (xpos > 0) then
		    save_str := save_str + tmp_char;
		end;
	    if (xpos > 0) then
	      begin
		i2 := i1;
		print(floor_str,i2,xpos);
	      end;
	  end;
      end;

	{ When blinded, move only the player symbol...		}
    procedure sub3_move_light;
      var
	i1,i2                   : integer;
      begin
	if (light_flag) then
	  begin
	    for i1 := y1-1 to y1+1 do
	      for i2 := x1-1 to x1+1 do
		cave[i1,i2].tl := false;
	    light_flag := false;
	  end;
	print(' ',y1,x1);
	print('@',y2,x2);
      end;

	{ With no light, movement becomes involved...		}
    procedure sub4_move_light;
      var
	i1,i2                   : integer;
      begin
	light_flag := true;
	if (cave[y1,x1].tl) then
	  begin
	    for i1 := y1-1 to y1+1 do
	      for i2 := x1-1 to x1+1 do
		begin
		  cave[i1,i2].tl := false;
		  if (test_light(i1,i2)) then
		    lite_spot(i1,i2)
		  else
		    unlite_spot(i1,i2);
		end;
	  end
	else if (test_light(y1,x1)) then
	  lite_spot(y1,x1)
	else
	  unlite_spot(y1,x1);
	print('@',y2,x2);
      end;

	{ Begin move_light procedure				}
    begin
      if (py.flags.blind > 0) then
	sub3_move_light
      else if (find_flag) then
	sub2_move_light
      else if (not(player_light)) then
	sub4_move_light
      else
	sub1_move_light;
    end;


	{ Room is lit, make it appear				-RAK-	}
  [global,psect(moria$code)] procedure light_room(y,x : integer);
    var
	tmp1,tmp2               : integer;
	start_row,start_col     : integer;
	end_row,end_col         : integer;
	i1,i2                   : integer;
	ypos,xpos               : integer;
	floor_str               : vtype;
	tmp_char                : char;


    procedure find_light(y1,x1,y2,x2 : integer);
      var
	i1,i2,i3,i4     : integer;
      begin
	for i1 := y1 to y2 do
	  for i2 := x1 to x2 do
	    if (cave[i1,i2].fval in [1,2,17]) then
	      begin
		for i3 := i1-1 to i1+1 do
		  for i4 := i2-1 to i2+1 do
		      cave[i3,i4].pl := true;
		if (cave[i1,i2].fval = 17) then
		  cave[i1,i2].fval := 18
		else
		  cave[i1,i2].fval := 2;
	      end;
      end;

    begin
      tmp1 := trunc(screen_height/2);
      tmp2 := trunc(screen_width /2);
      start_row := trunc(y/tmp1)*tmp1 + 1;
      start_col := trunc(x/tmp2)*tmp2 + 1;
      end_row := start_row + tmp1 - 1;
      end_col := start_col + tmp2 - 1;
      find_light(start_row,start_col,end_row,end_col);
      for i1 := start_row to end_row do
	begin
	  floor_str := '';
	  ypos := i1;
	  for i2 := start_col to end_col do
	    with cave[i1,i2] do
	      begin
		if ((pl) or (fm)) then
		  begin
		    if (length(floor_str) = 0) then
		      xpos := i2;
		    loc_symbol(i1,i2,tmp_char);
		    floor_str := floor_str + tmp_char
		  end
		else
		  if (length(floor_str) > 0) then
		    begin
		      print(floor_str,ypos,xpos);
		      floor_str := ''
		    end
	      end;
	  if (length(floor_str) > 0) then
	    print(floor_str,ypos,xpos)
	end;
    end;


	{ Lights up given location				-RAK-	}
    [global,psect(moria$code)] procedure lite_spot(y,x : integer);
      var
		spot_char       : vtype;
		temp            : char;
      begin
	if (panel_contains(y,x)) then
	  begin
	    loc_symbol(y,x,temp);
	    spot_char := temp;
	    print(spot_char,y,x)
	  end
      end;


	{ Blanks out given location				-RAK-	}
    [global,psect(moria$code)] procedure unlite_spot(y,x : integer);
      begin
	if (panel_contains(y,x)) then
	  print(' ',y,x);
      end;


	{ Picks new direction when in find mode 		-RAK-	}
    [global,psect(moria$code)] function pick_dir(dir : integer) : boolean;
      var
		z               : array [1..2] of integer;
		i1,y,x,heading	: integer;
      begin
	if ((find_flag) and (next_to4(char_row,char_col,corr_set) = 2)) then
	  begin
	    case dir of
		1,3,7,9 : begin
			    z[1] := rotate_dir(dir,-1);
			    z[2] := rotate_dir(dir,1);
			  end;
		2,4,6,8 : begin
			    z[1] := rotate_dir(dir,-2);
			    z[2] := rotate_dir(dir,2);
			end;
	    end;
	    pick_dir := false;
	    for i1 := 1 to 2 do
	      begin
		y := char_row;
		x := char_col;
		if (move(z[i1],y,x)) then
		  if (cave[y,x].fopen) then
		    begin
		      pick_dir := true;
		      com_val := z[i1] + 48
		    end
	      end
	  end
	else
	  begin
	    pick_dir := false;
	  end;
      end;


	{ Calculates current boundries				-RAK-	}
    [global,psect(moria$code)] procedure panel_bounds;
      begin
	panel_row_min := (trunc(panel_row*(screen_height/2)) + 1);
	panel_row_max := panel_row_min + screen_height - 1;
	panel_row_prt := panel_row_min - 2;
	panel_col_min := (trunc(panel_col*(screen_width/2)) + 1);
	panel_col_max := panel_col_min + screen_width - 1;
	panel_col_prt := panel_col_min - 15;
      end;


	{ Tests a given point to see if it is within the screen -RAK-	}
	{ boundries.                                                    }
    [global,psect(moria$code)] function panel_contains(y,x : integer) : boolean;
      begin
	if ((y >= panel_row_min) and (y <= panel_row_max)) then
	  if ((x >= panel_col_min) and (x <= panel_col_max)) then
	    panel_contains := true
	  else
	    panel_contains := false
	else
	  panel_contains := false;
      end;


	{ Returns true if player has no light			-RAK-	}
    [global,psect(moria$code)] function no_light : boolean;
      begin
	no_light := false;
	with cave[char_row,char_col] do
	  if (not(tl)) then
	    if (not(pl)) then
	      no_light := true;
      end;


	{ Change a trap from invisible to visible		-RAK-	}
	{ Note: Secret doors are handled here                           }
    [global,psect(moria$code)] procedure change_trap(y,x : integer);
      var
		i3              : integer;
      begin
	with cave[y,x] do
	  if (t_list[tptr].tval in [Unseen_trap,Secret_door]) then
	    begin
	      i3 := tptr;
	      place_trap(y,x,2,t_list[i3].subval);
	      pusht(i3);
	      lite_spot(y,x);
	    end;
      end;




	{ Here's a bunch of otherwise worthless procedures that are     }
	{ used to give the peasant's houses a bit of variety.   -RAD-   }
	      

     [global,psect(moria$code)] procedure kicked_out;
       begin                                         
	 msg_print('The owner kicks you out...');
       end; 

     [global,psect(moria$code)] procedure call_guards(who : vtype);
       begin
	 msg_print('The '+who+' call(s) for the Town Guards!');
	 monster_summon_by_name(char_row,char_col,'Town Guard',true,false);
         monster_summon_by_name(char_row,char_col,'Town Guard',true,false);
       end;

     [global,psect(moria$code)] procedure call_wizards;
       begin
	 msg_print('The mage calls for a Town Wizard to remove you.');
	 monster_summon_by_name(char_row,char_col,'Town Wizard',true,false);
       end;

     [global,psect(moria$code)] procedure beg_food;          {Unfinished}
       var	i2		: integer;
		item_ptr	: treas_ptr;
       begin
	if (find_range([food],false,item_ptr,i2)) then
	  begin
	    msg_print('The occupants beg you for food.');
	    if get_yes_no('Will you feed them?') then
	      begin
		spend_time(200,'feeding people',false);
		msg_print('How kind of you!');
		inven_destroy(item_ptr);
		change_rep(5);
		prt_weight;
	      end
	    else
	      begin
		msg_print('What a jerk!');
		change_rep(-10);
	      end;
	  end
	else
	  beg_money;
       end;
                                                     
     [global,psect(moria$code)] procedure beg_money;         {Unfinished}
	var	i1 : integer;
	begin
	  msg_print('The occupants beg you for money.');
	  if get_yes_no('Will you give them some?') then
	    with py.misc do
	      begin
		if (money[total$] > 0) then
		begin
		  msg_print('How kind of you!');
		  spend_time(100,'giving handouts',false);
		  i1 := ((randint(12)*money[total$]) div 1000 + 20)*gold$value;
                  if (i1 > money[total$]*gold$value div 2) then
		    i1 := money[total$]*gold$value div 2;
		  subtract_money(i1,false);
		  prt_weight;
		  prt_gold;
		  if (i1 > 20*gold$value) then
		    change_rep(5)
		  else
		    change_rep((i1+5*gold$value-1) div (5*gold$value));
		  prt_weight;
		  prt_gold;
		end
	      else
	        msg_print('They are disappointed because you have no money.');
	    end
	  else
	    begin
	      msg_print('What a jerk!');
	      change_rep(-10); {bug fixed here; used to be 10 -- MAV }
	    end;
       end;

  procedure eat_the_meal;
    var yummers,old_food : integer;
    begin
      yummers := react(randint(8)-2);
      old_food := py.flags.food;
      if ((yummers=10) and (randint(2)=1)) then yummers := 15;
      spend_time(50 + 50 * yummers,'eating like a pig',false);
      case yummers of
	15 : begin
		msg_print('It is a sumptuous banquet, and you feel quite stuffed.');
		py.flags.food := player_food_max;
		py.flags.status := uand(%X'FFFFFFFC',py.flags.status);
		prt_hunger;
		change_rep(3);
	       end;
	6..10 : begin
		msg_print('It is an ample meal, and you feel full.');
		py.flags.food := player_food_full;
		py.flags.status := uand(%X'FFFFFFFC',py.flags.status);
		prt_hunger;
		change_rep(1);
	       end;
	otherwise
	     if ((yummers>0) or player_saves(py.misc.lev+5*spell_adj(cn))) then
		begin
		  msg_print('It was a boring meal, and you eat very little.');
		  py.flags.food := old_food;
		  prt_hunger;
	        end
	       else
		begin
		  msg_print('Yuk!  That meal was AWFUL!');
		  msg_print('You throw up!');
		  if (py.flags.food > 150) then py.flags.food := 150;
		  msg_print('You get food poisoning.');
		  py.flags.poisoned := py.flags.poisoned + randint(10) + 5;
		  change_rep(-2);
 	        end;
      end; {case}
    end;


    [global,psect(moria$code)] procedure invite_for_meal;
      begin
	msg_print('The occupants invite you in for a meal.');
	if get_yes_no('Do you accept?') then
	  eat_the_meal;
      end;

    [global,psect(moria$code)] procedure party;
      begin
        msg_print('The owner invites you to join the party!');
	if get_yes_no('Do you accept?') then
	begin
	  spend_time(400+randint(1600),'at a party',false);
          case randint(6) of
	  1 : begin
		msg_print('Someone must have spiked the punch!');
	       	msg_print('Oh, your aching head!');
		py.flags.confused := py.flags.confused + 25 + randint(25);
	      end;
	  2 : begin
		msg_print('Gee, those brownies were awfully unusual....');
		msg_print('You feel a little strange now.');
		py.flags.image := py.flags.image + 200 + randint(100);
	      end;
	  3 : begin
		msg_print('You smoked something strange at the party.');
		case (randint(2)) of
		  1 : py.flags.hero := py.flags.hero + 25 + randint(25);
		  2 : py.flags.afraid := py.flags.afraid + 25 + randint(25);
		end;
	      end;
      4,5,6 : msg_print('It is an interesting party, and you enjoy yourself.');
          end; {case}
	end;
      end; {party}


    [global,psect(moria$code)] procedure spend_the_night(who : vtype);
      begin
	msg_print('The occupant(s) invite you to rest in his house.');
	if get_yes_no('Do you accept?') then
	 begin
	  spend_time(1,'at the home of the '+who+'.',true);
	  change_rep(2);
	 end
	else if get_yes_no('Okay, how about staying for a meal?') then
	  eat_the_meal;
      end;

     [global,psect(moria$code)] procedure worship;
      var preachy,i1 : integer;
      begin
	msg_print('The priest invites you to participate in the service.');
	if get_yes_no('Do you accept?') then
	  begin
	     preachy := randint(4);
	     case preachy of
	      1	: msg_print('You sit through a fascinating church service.');
	      2	: msg_print('You sit through an interesting church service.');
	      3 : msg_print('You sit through a boring church service.');
	      4 : msg_print('You sit through a long, boring church service.');
	     end;
	   spend_time(100*(randint(7)+preachy*preachy),'at the Church',false);
	    msg_print('The priest asks for donations for a new church.');
	    if get_yes_no('Will you give him some money?') then
	      with py.misc do
		if (money[total$] > 0) then
		  begin
		    msg_print('Bless you, dude!');
		    i1:=((randint(12)*money[total$]) div 1000 + 20)*gold$value;
                    if (i1 > money[total$]*gold$value div 2) then
			i1 := money[total$]*gold$value div 2;
		    subtract_money(i1,false);
		    prt_weight;
		    prt_gold;
		    if (i1 > 20*gold$value) then
			change_rep(5)
		    else
			change_rep((i1+5*gold$value-1) div (5*gold$value));
		  end
		else 
		  begin
		    msg_print('He says ''It is the thought that counts, my child.');
                    msg_print('Thank you for being willing to give.');
		  end
	    else
	      msg_print('Syo problem, man?');
	    change_rep(-5);
	  end
	else if (react(6)=0) then
	  begin
	    msg_print('You heathen!  Get out of my temple!');
	    change_rep(-5);
	  end;
      end;

    [global,psect(moria$code)] procedure battle_game(plus : integer; kb_str : vtype);
      var score,i1,time : integer;
      begin
	if get_yes_no('Do you accept their invitation?') then
	  begin
	    msg_print('Good for you!');
	    score := 0;
	    time := 10;
	    with py.misc do
	      begin
		for i1 := 1 to 7 do
		  if player_test_hit(bth,lev,plus,20*i1,false) then
		    begin
		      score := score + 1;
		      time := time * 2 + 10;
		    end;
	      end;
	    spend_time(time,'with some '+kb_str,false);
	    case score of
	      1 : begin
		    msg_print('They ridicule your clumsy performance...');
		    msg_print('"Come back when you are more experienced!!"');
		    change_rep(-2);
		  end;
	      2 : msg_print('You do not do well...');
	      3 : msg_print('"Pretty good for a beginner!"');
	      4 : msg_print('They are quite impressed!');
	      5 : begin
		    msg_print('They are amazed by your incredible prowess!');
		    change_rep(2);
		  end;
	      6,7 : begin
		   msg_print('You handle them all with ease!');
		   msg_print('"Thanks for the workout! Come back anytime!!"');
		   py.misc.exp := py.misc.exp + 10;
		   change_rep(5);
		 end;
	      otherwise 
		begin
		 msg_print('"Boy that was quick!! What a little wimp!"');
		 msg_print('They pummel you senseless and toss you out into the street!');
		 take_hit(damroll('2d4'),kb_str);
		 change_rep(-5);
		 py.flags.confused := py.flags.confused + 5 + randint(5);
		end;
	    end;
	  end;
      end;

    procedure brothel_game;
      begin
	if get_yes_no('Do you accept?') then
	  begin
	    change_rep(-3);
	    with py.misc do
	      if (disarm + lev + 2*todis_adj + spell_adj(iq) > randint(100)) then
		begin
		  msg_print('Good! You are invited to join the house!');
		  exp := exp + 5;
		  spend_time(600,'putting out for peasants',false);
		end
	      else
		begin
		  msg_print('You fail to please your customers.');
		  spend_time(400,'imitating a pine board',false);
		end;
	  end;
      end;

    procedure guild_or_not(passed : boolean);
     begin
      if (passed) then
       begin
	spend_time(600,'showing off your skills',false);
	msg_print('Good! You are invited to join the guild!');
	py.misc.exp := py.misc.exp + 5;
	change_rep(-3);
       end
     else 
	begin
	  spend_time(400,'or lack thereof',false);
	  msg_print('You fail to impress them.');
	  if (randint(3) = 1) then
	    begin
	      msg_print('They think you are with the guard!');
	      msg_print('You are stabbed by one of them before you escape');
	      take_hit(randint(randint(16)),'Thieves Guild Member');
	      prt_hp;
	    end;
	end;
     end;

    [global,psect(moria$code)] procedure thief_games;
      begin
	if (randint(2) = 1) then
	  begin
msg_print('The thieves invite you to prove your ability to pick locks.');
	    if get_yes_no('Do you accept?') then
	      with py.misc do
	guild_or_not(disarm+lev+2*todis_adj+spell_adj(iq) > randint(100));
	  end
	else
	  begin                                                  
	    msg_print('The thieves invite you to show your stealthiness.');
	    if get_yes_no('Do you accept?') then
		guild_or_not(py.misc.stl > randint(12));
	  end
      end;

{returns 0 to 10 -- SD 2.4; x is average reaction for a 0 SC ugly half-troll}
    [global,psect(moria$code)] function react(x : integer) : integer;
      var   ans  : integer;
      begin
	ans := (py.stat.c[ca]+py.misc.rep*2+randint(200)+randint(200)
		+randint(200)) div 50 + x - 4;
	if (ans < 0) then ans := 0
	else if (ans > 10) then ans := 10;
	react := ans;
      end;

    [global,psect(moria$code)] procedure change_rep(amt : integer);
      var cost,left : integer;
      begin
	with py.misc do
	  if ((amt<0) or (rep+amt<=0)) then	{bad deed or make up for sins}
	    rep := rep + amt
	  else	{ good deed that puts char into positive reputation }
{ good characters progress slowly -- past 0 it costs 2, past 20 costs 3...}
	    begin
	      if (rep < 0) then	{ go from bad to good }
		begin
		  amt := amt + rep;
		  rep := 0;
		end; {increase goodness}
	      rep := trunc(sqrt((20+rep)*(20+rep)+40*amt)-20);
	    end;
      end;

	{ Check to see if a store is open, message when closed	-DMF-	}
    [global,psect(moria$code)] function check_store_hours(st,sh : integer) : boolean;
      var
	name,prop	: string;
	ope		: char;
	flag		: boolean;
      begin
	if (sh <> 0) then
	  with store[sh].store_open do
	    with py.misc do
	      flag := ((cur_age.year > year) or 
	          ((cur_age.year = year) and
	           ((cur_age.month > month) or
		    ((cur_age.month = month) and
		     ((cur_age.day > day) or
		      ((cur_age.day = day) and
		       ((cur_age.hour > hour) or
		        ((cur_age.hour = hour) and
		         ((cur_age.secs > secs))))))))))
	else
	  flag := true;
	if (flag) then
	  begin
	    name := store_door[st].name;
	    insert_str(name,'the entrance to the ','');
	    ope := store_hours[st,py.misc.cur_age.day mod 7 + 1,
				  py.misc.cur_age.hour div 2 + 1];
	    case ope of
	      ' ' : check_store_hours := true;
	      'N',
	      'W',
	      'D' : begin
		      case ope of
		        'N' : prop := 'night.';
		        'W' : prop := 'weekend.';
		        'D' : prop := 'day.';
		      end;
		      if (wizard2) then
		        begin
		          msg_print('Being a wizard, you break into the shop.');
		          msg_print('');
		          check_store_hours := true;
		        end
		      else
		        begin
		          msg_print('Sorry, the '+name+' is closed for the '+prop);
		          check_store_hours := false;
		        end;
		    end;
	      'B' : begin
		      writev(prop,'Do you wish to pay ',store_bribe[st]:1,
				  ' gold to bribe the owner?');
		      if (get_yes_no(prop)) then
		        if (py.misc.money[total$] >= store_bribe[st]) then
		          begin
			    check_store_hours := true;
			    subtract_money(store_bribe[st]*gold$value,false);
			    msg_print('The owner reluctantly lets you in.');
			    msg_print('');
		          end
		        else
		          begin
			    check_store_hours := false;
			    msg_print('You haven''t the money to bribe the owner!');
		          end
		      else
		        begin
		          check_store_hours := false;
		          msg_print('The owner complains bitterly about being woken up for no reason.');
		        end;
		    end;
	      otherwise check_store_hours := false;          
	    end;
	  end
	else
	  msg_print('The doors are locked.');
      end;


	{ Player hit a trap...	(Chuckle)		     	-RAK-	}
    [global,psect(moria$code)] procedure hit_trap(var y,x : integer);
      var
		i1,i2,ty,tx             : integer;
		dam                     : integer;
		ident 			: boolean;


      begin
	change_trap(y,x);
	lite_spot(char_row,char_col);
	find_flag := false;
	with cave[y,x] do
	with py.misc do
	  begin
	    dam := damroll(t_list[tptr].damage);
	    case t_list[tptr].subval of
{ Open pit}   1 : begin
		    msg_print('You fell into a pit!');
		    if (py.flags.ffall) then
		      msg_print('You gently float down.')
		    else
		      take_hit(dam,'an open pit.');
		  end;
{ Arrow trap} 2 : begin
		    if (test_hit(125,0,0,pac+ptoac)) then
		      begin
			take_hit(dam,'an arrow trap.');
			msg_print('An arrow hits you.');
		      end
		    else
		      msg_print('An arrow barely misses you.');
		  end;
{ Covered pit}3 : begin
		    msg_print('You fell into a covered pit.');
		    if (py.flags.ffall) then
		      msg_print('You gently float down.')
		    else
		      take_hit(dam,'a covered pit.');
		      place_trap(y,x,2,1);
		  end;
{ Trap door}  4 : begin
		    msg_print('You fell through a trap door!');
		    msg_print(' ');
		    moria_flag := true;
		    dun_level := dun_level + 1;
		    if (py.flags.ffall) then
		      msg_print('You gently float down.')
		    else
		      take_hit(dam,'a trap door.');
		  end;
{ Sleep gas}  5 : if (py.flags.paralysis = 0) then
		    begin
		      msg_print('A strange white mist surrounds you!');
		      if (py.flags.free_act) then
			msg_print('You are unaffected.')
		      else
			begin
			  msg_print('You fall asleep.');
			  py.flags.paralysis := py.flags.paralysis +
							randint(10) + 4;
			end
		    end;
{ Hid Obj}    6 : begin
		    fm := false;
		    pusht(tptr);
		    place_object(y,x);
		    msg_print('Hmmm, there was something under this rock.');
		  end;
 { STR Dart}  7 : begin
		    if (test_hit(125,0,0,pac+ptoac)) then
		      if lose_stat(sr,'','A small dart hits you.') then
			begin
			  take_hit(dam,'a dart trap.');
		     	  print_stat := uor(%X'0001',print_stat);
			  msg_print('A small dart weakens you!');
			end
		    else
		      msg_print('A small dart barely misses you.');
		  end;
{ Teleport}   8 : begin
		    teleport_flag := true;
		    msg_print('You hit a teleport trap!');
		  end;
{ Rockfall}   9 : begin
		    take_hit(dam,'falling rock.');
		    pusht(tptr);
		    place_rubble(y,x);
		    msg_print('You are hit by falling rock');
		  end;
{ Corrode gas}10: begin
		    corrode_gas('corrosion gas.');
		    msg_print('A strange red gas surrounds you.');
		  end;
{ Summon mon} 11: begin
		    fm := false;        { Rune disappears...    }
		    pusht(tptr);
		    tptr := 0;
		    for i1 := 1 to (2+randint(3)) do
		      begin
			ty := char_row;
			tx := char_col;
			if cave[ty,tx].fval in water_set then
			  summon_water_monster(ty,tx,false)
			else
			  summon_land_monster(ty,tx,false);
		      end;
		  end;
{ Fire trap}  12: begin
		    fire_dam(dam,'a fire trap.');
		    msg_print('You are enveloped in flames!');
		  end;
{ Acid trap}  13: begin
		    acid_dam(dam,'an acid trap.');
		    msg_print('You are splashed with acid!');
		  end;
{ Poison gas} 14: begin
		    poison_gas(dam,'a poison gas trap.');
		    msg_print('A pungent green gas surrounds you!');
		  end;
{ Blind Gas } 15: begin
		    msg_print('A black gas surrounds you!');
		    with py.flags do
		      blind := blind + randint(50) + 50;
		  end;
{ Confuse Gas}16: with py.flags do
		    begin
	      msg_print('A gas of scintillating colors surrounds you!');
		      confused := confused + randint(15) + 15;
		    end;
{ Slow Dart}  17: begin
		    if (test_hit(125,0,0,pac+ptoac)) then
		      begin
			take_hit(dam,'a dart trap.');
			msg_print('A small dart hits you!');
			with py.flags do
			  slow := slow + randint(20) + 10;
		      end
		    else
		      msg_print('A small dart barely misses you.');
		  end;
{ CON Dart}   18: begin
		    if (test_hit(125,0,0,pac+ptoac)) then
		      if lose_stat(cn,'','A small dart hits you.') then
			begin
			  take_hit(dam,'a dart trap.');
			  print_stat := uor(%X'0004',print_stat);
			  msg_print('A small dart weakens you!');
			end
		    else
		      msg_print('A small dart barely misses you.');
		  end;
{Secret Door} 19: ;
{ Chute}      20: begin
		    msg_print('You fell down a chute!');
		    msg_print(' ');
		    moria_flag := true;
		    dun_level := dun_level + randint(6);
		    if (py.flags.ffall) then
		      msg_print('You gently slide down.')
		    else
		      take_hit(dam,'chute landing.');
		  end;
{ Scare Mon}  99: ;
                                                             
			{ Town level traps are special, the stores...	}
{ General    }101: if (check_store_hours(1,1))  then enter_store(1);
{ Armory     }102: if (check_store_hours(2,2))  then enter_store(2);
{ Weaponsmith}103: if (check_store_hours(3,3))  then enter_store(3);
{ Temple     }104: if (check_store_hours(4,4))  then enter_store(4);
{ Alchemy    }105: if (check_store_hours(5,5))  then enter_store(5);
{ Magic-User }106: if (check_store_hours(6,6))  then enter_store(6);
{ Inn	     }107: if (check_store_hours(7,7))  then enter_store(7);
{ Trade Post }108: if (check_store_hours(8,0))  then enter_trading_post;
{ Library    }109: if (check_store_hours(9,8))  then enter_store(8);
{ Music Shop }110: if (check_store_hours(10,9)) then enter_store(9);
{ Insurance  }111: if (check_store_hours(12,0)) then msg_print(
		'Moved...to the bank.');
{ Bank       }112: if (check_store_hours(13,0)) then enter_bank;
{ Gem Shop   }113: if (check_store_hours(11,10)) then enter_store(10);
{ $ Changer  }114: if (check_store_hours(14,0)) then msg_print(
		'Oh, just go to the bloody bank!');
{ Casino     }115: if (check_store_hours(15,0)) then enter_casino;
{ Deli       }116: if (check_store_hours(16,11)) then enter_store(11);
{ Fortress   }117: enter_fortress;
{ Whirlpool}  123: begin
		     msg_print('You are swept into a whirlpool!');
		     msg_print(' ');
		     moria_flag := true;
		     repeat
		      dun_level := dun_level + 1;
		      if not (py.flags.ffall) then {XXX...swimming_worn}
		       begin
			msg_print('You are drowning!');
			take_hit(dam,'drowning.');
		       end;
		     until (randint(2) = 1);
		   end;
{ House      }120,121,122: begin
		     case t_list[tptr].p1 of
		       1 : begin
			     msg_print('The building is empty.');
			     if (react(10)=0) then
				begin
				  msg_print('The building is being guarded!');
				  call_guards('Magic Mouth spell');
				end;
			     end;
		       2 : begin
			     msg_print('There is a Thieves'' Guild meeting here.');
			     case react(6) of
				0	: call_guards('Guildmaster');
				1..7    : kicked_out;
				8..10   : thief_games;
			     end;
			   end;
		       3 : begin
			     msg_print('This is a town brothel.  Some young prostitutes are here.');
			     case react(10) of
				0 : call_guards('prostitutes');
				1..6 : kicked_out;
				otherwise begin
					    if (py.misc.sex='Male') then
					      begin
		msg_print('The girls invite you to prove your abilities.');
		battle_game(spell_adj(ca),'some playful prostitutes');
					      end
					    else
					      begin
		msg_print('The girls invite you to work with them.');
						brothel_game;
					      end;
			     		  end;
			     end;
			   end;
	      	       4 : begin
				msg_print('Some drunken fighters are telling tales here.');
			        case react(8) of
				  0	: call_guards('group of fighters');
				  1..6  : kicked_out;
				  otherwise 
				    begin
				      msg_print('They ask you to demonstrate your fighting skill.');
				      battle_game(py.misc.ptohit,'some drunken fighters');
				    end;
				end;
			   end;
		       5 : begin
			     msg_print('There is a party in progress here.');
			     case react(8) of
				0	: call_guards('party''s host');
				1..5	: kicked_out;
				otherwise party;
			     end;
			   end;
		       6 : begin
			     case randint(2) of
				1:msg_print('The building is a poorhouse.');
				2:msg_print('This is an orphanage.');
			     end;
			     case react(12) of
				0 	: call_guards('beggars');
				1..4   	: kicked_out;
				otherwise case(2) of
				   1 : beg_food;
				   2 : beg_money;
				end;
			     end;
			   end;
		     7,8 : begin
			     case randint(3) of
				1 :msg_print('This is the home of a peasant family.');
				2 :msg_print('These are the quarters of a humble laborer.');
				3 :msg_print(' This is the home of several poor families.');
			     end;
			     case react(8) of
				0	: call_guards('peasant(s)');
				1..3 	: kicked_out;
				4..7	: invite_for_meal;
				8..10	: spend_the_night('peasant(s)');
			     end;
			   end;
		       9 : begin
			     case randint(3) of
			1,2 : msg_print('This is the home of a merchant.');
			3   : msg_print('This is the house of an accomplished craftsman.');
			     end;
			     case react(5) of
				0	: call_guards('owner');
				1..4	: kicked_out;
				5..9	: invite_for_meal;
				10	: spend_the_night('gentleman');
			     end;
			   end;
		      10 : begin
			     msg_print('There is a religious service in progress here.');
			     case react(8) of
				0	: call_guards('High Priest');
				1..5	: kicked_out;
				otherwise worship;
			     end;
			   end;
		      11 : begin
			     case randint(3) of
				1:msg_print('This is the house of a wealthy shopkeeper.');
				2:msg_print('This is the mansion of a affluent noble.');
				3:msg_print('This is the estate of an rich guildsman.');
			     end;
			     case react(2) of
				0	: call_guards('master of the house');
				1..3	: kicked_out;
				4..9	: invite_for_meal;
				10	: spend_the_night('master of the house');
			     end;
			   end;
		      12 : begin
			     msg_print('This is the home of a powerful mage.');
			     case react(5) of
				0	: call_wizards;
				1..3	: call_guards('mage');
				4..9	: kicked_out;
				10	: invite_for_meal;
			     end;
			   end;
		     end;
		     t_list[tptr].p1 := 1;
		     prt_time;
		     prt_stat_block;
		   end;
		otherwise	msg_print('Unknown trap value');
	    end
	  end
      end;


	{ AC gets worse 					-RAK-	}
	{ Note: This routine affects magical AC bonuse so that stores   }
	{       can detect the damage.                                  }
    [global,psect(moria$code)] function minus_ac(typ_dam : integer) : boolean;
      var
	i1,i2                   : integer;
	tmp                     : array [1..8] of integer;
      begin
	i1 := 0;
	if (equipment[Equipment_armor].tval > 0) then
	  begin
	    i1 := i1 + 1;
	    tmp[i1] := Equipment_armor;
	  end;
	if (equipment[Equipment_shield].tval > 0) then
	  begin
	    i1 := i1 + 1;
	    tmp[i1] := Equipment_shield;
	  end;
	if (equipment[Equipment_cloak].tval > 0) then
	  begin
	    i1 := i1 + 1;
	    tmp[i1] := Equipment_cloak;
	  end;
	if (equipment[Equipment_gloves].tval > 0) then
	  begin
	    i1 := i1 + 1;
	    tmp[i1] := Equipment_gloves;
	  end;
	if (equipment[Equipment_helm].tval > 0) then
	  begin
	    i1 := i1 + 1;
	    tmp[i1] := Equipment_helm;
	  end;
	if (equipment[Equipment_boots].tval > 0) then
	  begin
	    i1 := i1 + 1;
	    tmp[i1] := Equipment_boots;
	  end;
	if (equipment[Equipment_belt].tval > 0) then
	  begin
	   i1 := i1 + 1;
	   tmp[i1] := Equipment_belt;
	  end;
	if (equipment[Equipment_bracers].tval > 0) then
	  begin
	   i1 := i1 + 1;
	   tmp[i1] := Equipment_bracers;
	  end;
	minus_ac := false;
	if (i1 > 0) then
	  begin
	    i2 := tmp[randint(i1)];
	    inven_temp^.data := equipment[i2];
	    with equipment[i2] do
	      if (uand(flags,typ_dam) <> 0) then
		begin
		  objdes(out_val,inven_temp,false);
		  msg_print('Your ' + out_val + ' resists damage!');
		  minus_ac := true;
		end
	      else if ((ac+toac) > 0) then
		begin
		  objdes(out_val,inven_temp,false);
		  msg_print('Your ' + out_val + ' is damaged!');
		  toac := toac - 1;
		  py_bonuses(blank_treasure,0);
		  minus_ac := true;
		end
	  end
      end;


	{ Corrode the unsuspecting person's armor               -RAK-   }
    [global,psect(moria$code)] procedure corrode_gas(kb_str : vtype);
      begin
	if (not (minus_ac(resist_acid_worn_bit))) then
	  take_hit(randint(8),kb_str);
	print_stat := uor(%X'0040',print_stat);
	if (inven_damage([sword,dagger,helm,gem_helm,shield,hard_armor,wand],5) > 0)
	then
	  begin
	    msg_print('There is an acrid smell coming from your pack.');
	    prt_weight;
	  end ;
      end;


	{ Poison gas the idiot...				-RAK-	}
    [global,psect(moria$code)] procedure poison_gas(dam : integer; kb_str : vtype);
      begin
	take_hit(dam,kb_str);
	print_stat := uor(%X'0040',print_stat);
	py.flags.poisoned := py.flags.poisoned + 12 + randint(dam);
      end;


	{ Burn the fool up...					-RAK-	}
    [global,psect(moria$code)] procedure fire_dam(dam : integer; kb_str : vtype);
      begin
	if (py.flags.fire_resist)then
	  dam := dam div 3;
	if (py.flags.resist_heat > 0) then
	  dam := dam div 3;
	take_hit(dam,kb_str);
	print_stat := uor(%X'0080',print_stat);
	if (inven_damage([arrow,bow_crossbow_or_sling,hafted_weapon,pole_arm,
			  maul,boots,gloves_and_gauntlets,Cloak,soft_armor,
			  staff,scroll1,scroll2],3) > 0) then
	  begin
	    msg_print('There is smoke coming from your pack!');
	    prt_weight ;
	  end ;
      end;


	{ Throw acid on the hapless victim			-RAK-	}
    [global,psect(moria$code)] procedure acid_dam(dam : integer; kb_str : vtype);
      var
		flag            : integer;
      begin
	flag := 0;
	if (minus_ac(resist_acid_worn_bit)) then
	  flag := 1;
	if (py.flags.acid_resist) then
	  flag := flag + 2;
	case flag of
	  0 : take_hit(dam,kb_str);
	  1 : take_hit((dam div 2),kb_str);
	  2 : take_hit((dam div 3),kb_str);
	  3 : take_hit((dam div 4),kb_str);
	end;
	print_stat := uor(%X'00C0',print_stat);
	if (inven_damage([Miscellaneous_object,chest,bolt,arrow,hafted_weapon,
			  bow_crossbow_or_sling,pole_arm,boots,
			  gloves_and_gauntlets,Cloak,soft_armor],3) > 0) then
	  begin
	    msg_print('There is an acrid smell coming from your pack!');
	    prt_weight ;
	  end ;
      end;


	{ Freeze him to death...				-RAK-	}
    [global,psect(moria$code)] procedure cold_dam(dam : integer; kb_str : vtype);
      begin
	if (py.flags.cold_resist)then
	  dam := dam div 3;
	if (py.flags.resist_cold > 0) then
	  dam := dam div 3;
	take_hit(dam,kb_str);
	print_stat := uor(%X'0080',print_stat);
	if (inven_damage([potion1,potion2],5) > 0) then
	  begin
	    msg_print('Something shatters inside your pack!');
	    prt_weight ;
	  end ;
      end;


	{ Lightning bolt the sucker away...			-RAK-	}
    [global,psect(moria$code)] procedure light_dam(dam : integer; kb_str : vtype);
      begin
	if (py.flags.lght_resist) then
	  dam := dam div 3;
	if (py.flags.resist_lght > 0) then
	  dam := dam div 3;
	take_hit(dam,kb_str);
	print_stat := uor(%X'0080',print_stat);
      end;


	{ Allocates objects upon a creatures death		-RAK-	}
	{ Oh well, another creature bites the dust...  Reward the victor}
	{ based on flags set in the main creature record                }
  [global,psect(moria$code)] procedure monster_death(y,x : integer; flags : unsigned);
    var
	i1              : integer;
    begin
      i1 := INT(uand(flags,%X'03000000') div (%X'01000000'));
      if (uand(flags,%X'04000000') <> 0) then
	if (randint(100) < 60) then
	  summon_object(y,x,1,i1);
      if (uand(flags,%X'08000000') <> 0) then
	if (randint(100) < 90) then
	  summon_object(y,x,1,i1);
      if (uand(flags,%X'10000000') <> 0) then
	summon_object(y,x,randint(2),i1);
      if (uand(flags,%X'20000000') <> 0) then
	summon_object(y,x,damroll('2d2'),i1);
      if (uand(flags,%X'40000000') <> 0) then
	summon_object(y,x,damroll('4d3'),i1);
      if (uand(flags,%X'80000000') <> 0) then
	begin
	  total_winner := true;
	  prt_winner;
	  msg_print('*** CONGRATULATIONS *** You have won the game...');
	  msg_print('Use <CONTROL>-Y when you are ready to quit.');
	end;
    end;


	{ Decreases monsters hit points and deletes monster if needed.	}
	{ (Picking on my babies...)                             -RAK-   }
     [global,psect(moria$code)] function mon_take_hit(monptr,dam : integer) : integer;
      var
	acc_tmp                 : real;
      begin
	with m_list[monptr] do
	  begin
	    hp := hp - dam;
	    csleep := 0;
	    if (hp < 0) then
	      begin
		monster_death(fy,fx,c_list[mptr].cmove);
		if ((mptr = py.misc.cur_quest) and (py.flags.quested)) then
		  begin
		    py.flags.quested := false;
		    prt_quested;
		    msg_print('*** QUEST COMPLETED ***');
		    msg_print('Return to the surface and report to the Arch-Wizard.');
		  end;
		with c_list[mptr] do
		  with py.misc do
		    begin
		      if (uand(cmove,%X'00004000') = 0) and (mexp > 0) then
		       begin
		        acc_tmp := mexp*((level+0.1)/lev);
		        i1 := trunc(acc_tmp);
		        acc_exp := acc_exp + (acc_tmp - i1);
		        if (acc_exp > 1) then
			  begin
			    i1 := i1 + 1;
			    acc_exp := acc_exp - 1.0;
			  end;
		        exp := exp + i1;
		       end
		      else if (mexp > 0) then
			begin
			  change_rep(-mexp);
			  if (py.misc.rep > -250) then
			    begin
			      msg_print('The townspeople look at you sadly.');
			      msg_print('They shake their heads at the needless violence.');
			    end
			  else if (py.misc.rep > -1000) then
			    begin
			      monster_summon_by_name(char_row,char_col,'Town Guard',true,false);
			      msg_print('The townspeople call for the guards!');
			    end
			  else if (py.misc.rep > -2500) then
			    begin
			      monster_summon_by_name(char_row,char_col,'Town Wizard',true,false);
			      msg_print('A Town Wizard appears!');
			    end
			  else
			    begin
			      msg_print('Your god disapproves of your recent town killing spree.');
			      msg_print('Unlike the townspeople, he can do something about it.');
			      msg_print(' ');
			      died_from := 'The Wrath of God';
			      upon_death;
			    end;
			end;
		    end;
		mon_take_hit := mptr;
		delete_monster(monptr);
		if (i1 > 0) then prt_experience;
	      end
	    else
	      mon_take_hit := 0;
	  end
      end;


	{ Special damage due to magical abilities of object	-RAK-	}
     [global,psect(moria$code)] function tot_dam(
		item	: treasure_type;
		tdam	: integer;
		monster	: creature_type) : integer;
      begin
	with item do
	  if (tval in [sling_ammo,bolt,arrow,bow_crossbow_or_sling,
		hafted_weapon,pole_arm,sword,dagger,maul,flask_of_oil,
		lamp_or_torch]) then
	    with monster do
	      begin
		{ Slay Dragon   }
		if ((uand(cdefense,%X'0001') <> 0) and
		    (uand(flags,slay_dragon_worn_bit) <> 0)) then
		  tdam := tdam*4
		{ Slay Undead   }
		else if ((uand(cdefense,%X'0008') <> 0) and
			 (uand(flags,slay_undead_worn_bit) <> 0)) then
		  tdam := tdam*3
		{ Demon Bane	}
		else if ((uand(cdefense,%X'0400') <> 0) and
			 (uand(flags2,slay_demon_worn_bit) <> 0)) then
		  tdam := tdam*3
		{ Slay Monster  }
		else if ((uand(cdefense,%X'0002') <> 0) and
			 (uand(flags,slay_monster_worn_bit) <> 0)) then
		  tdam := tdam*2
		{ Slay Regenerative }
		else if ((uand(cdefense,%X'8000') <> 0) and
			 (uand(flags2,slay_regen_worn_bit) <> 0)) then
		  tdam := tdam*3
		{ Slay Evil     }
		else if ((uand(cdefense,%X'0004') <> 0) and
			 (uand(flags,slay_evil_worn_bit) <> 0)) then
		  tdam := tdam*2
		{ Frost         }
		else if ((uand(cdefense,%X'0010') <> 0) and
			 (uand(flags,cold_brand_worn_bit) <> 0)) then
		  tdam := trunc(tdam*1.5)
		{ Fire          }
		else if ((uand(cdefense,%X'0020') <> 0) and
			 (uand(flags,flame_brand_worn_bit) <> 0)) then
		  tdam := trunc(tdam*1.5)
		{ Soul Sword	}
		else if ((not(uand(cdefense,%X'0008') <> 0)) and
			 (uand(flags2,soul_sword_worn_bit) <> 0)) then
		  tdam := tdam*2;
	    end;
	tot_dam := tdam;
      end;


	{ Player attacks a (poor, defenseless) creature 	-RAK-	}
    [global,psect(moria$code)] function py_attack(y,x : integer) : boolean;
      var
	a_cptr,a_mptr,i3,blows,tot_tohit,py_crit,crit_mult  	: integer;
	m_name,out_val                  		: vtype;
	mean_jerk_flag,is_sharp				: boolean;
	backstab_flag					: boolean;
      begin
	py_attack := false;
	a_cptr := cave[y,x].cptr;
	a_mptr := m_list[a_cptr].mptr;
	if (py.misc.pclass = 4) and (m_list[a_cptr].csleep <> 0) then
	    backstab_flag := true
	else backstab_flag := false;
	m_list[a_cptr].csleep := 0;
	find_monster_name(m_name,a_cptr,false) ;
	if (equipment[Equipment_primary].tval > 0) then       { Proper weapon }
	  blows := attack_blows(equipment[Equipment_primary].weight,tot_tohit)
	else                                    { Bare hands?   }
	  if (py.misc.pclass = 10) then
	    begin
	      blows := attack_blows(12000,tot_tohit) + 1;
	      tot_tohit := 0;
	    end
	  else
	    begin
	      blows := 2;
	      tot_tohit := -3
	    end;
	if backstab_flag then tot_tohit := tot_tohit + (py.misc.lev div 4);

 { Adjust weapons for class }
	if ((py.misc.pclass = 2) and (equipment[Equipment_primary].tval in 
			[sword,hafted_weapon,maul,pole_arm])) then
		tot_tohit := tot_tohit - 5
	else if (py.misc.pclass = 1) then
		  tot_tohit := tot_tohit + 1 + (py.misc.lev div 2)
	else if ((py.misc.pclass = 3) and (equipment[Equipment_primary].tval
 			in [sword,hafted_weapon,dagger,pole_arm])) then
		tot_tohit := tot_tohit - 4
	else if ((py.misc.pclass = 7) and (equipment[Equipment_primary].tval in
 			[sword,hafted_weapon,pole_arm])) then
		tot_tohit := tot_tohit - 4
	else if ((py.misc.pclass = 8) and (equipment[Equipment_primary].tval in
 			[hafted_weapon,maul,pole_arm])) then
		tot_tohit := tot_tohit - 3;

 { Fix for arrows}
	if (equipment[Equipment_primary].tval in [sling_ammo,bolt,arrow]) then
	  blows := 1;
	tot_tohit := tot_tohit + py.misc.ptohit;
{ stopped from killing town creatures?? }
	if ((uand(c_list[a_mptr].cmove,%X'00004000')=0) or (randint(100)<-py.misc.rep)) then
	  mean_jerk_flag := true
	else
	  mean_jerk_flag := get_yes_no('Are you sure you want to?');
	if mean_jerk_flag then
	{ Loop for number of blows, trying to hit the critter...        }
	 with py.misc do
	  repeat
	    if (player_test_hit(bth,lev,tot_tohit,c_list[a_mptr].ac,false)) then
	      begin
		if backstab_flag then
		  writev(out_val,'You backstab ',m_name,'!')
		else
		  writev(out_val,'You hit ',m_name,'.');
		msg_print(out_val);
		with equipment[Equipment_primary] do
		  begin
		    if (tval > 0) then          { Weapon?       }
		      begin
			i3 := damroll(damage);
			i3 := tot_dam(equipment[Equipment_primary],i3,c_list[a_mptr]);
			is_sharp := (tval <> bow_crossbow_or_sling) and
				(uand(flags2,sharp_worn_bit) <> 0);
			crit_mult := critical_blow(weight,tot_tohit,is_sharp,false);
			if backstab_flag then
			   i3 := i3 * ((py.misc.lev div 7) + 1);
			if (py.misc.pclass = 1) then
			   i3 := i3 + (py.misc.lev div 3);
			i3 := i3 + (i3 + 5) * crit_mult;
		      end
		    else                        { Bare hands!?  }
		      begin
			if (py.misc.pclass = 10) then
			  begin
			    i3 := randint((4 + 2*py.misc.lev) div 3);
			    crit_mult := critical_blow(12000,0,false,false);
			    if (randint(crit_mult+2) > 2) then
				do_stun(a_cptr,-10,2);
			    i3 := i3 + (i3 + 5) * crit_mult;
			  end
			else
			  begin
			    i3 := damroll(bare_hands);
			    crit_mult := critical_blow(1,0,false,false);
			    i3 := i3 + (i3 + 5) * crit_mult;
			  end;
		      end;
		  end;
		i3 := i3 + ptodam;
		if (i3 < 0) then i3 := 0;
	{ See if we done it in...                               }
		with m_list[a_cptr] do
		  if (mon_take_hit(a_cptr,i3) > 0) then
		    begin
		      msg_print('You have slain '+m_name+'.');
		      blows := 0;
		      py_attack := false;
		    end
		  else
		    py_attack := true;  { If creature hit, but alive...}
		  with equipment[Equipment_primary] do
        { Use missiles up}
		    if (tval in [sling_ammo,bolt,arrow]) then
		      begin
			number := number - 1;
			if (number <= 0) then
			  begin
			    inven_weight := inven_weight - weight;
			    prt_weight;
			    equip_ctr := equip_ctr - 1;
			    inven_temp^.data := equipment[Equipment_primary];
			    equipment[Equipment_primary] := blank_treasure;
			    py_bonuses(inven_temp^.data,-1);
			  end;
		      end;
	      end
	    else
	      begin
		writev(out_val,'You miss ',m_name,'.');
		msg_print(out_val);
	      end;
	    blows := blows - 1;
	  until (blows < 1)
      end;


	{ Finds range of item in inventory list 		-RAK-	}
    [global,psect(moria$code)] function find_range(
			item_val	: obj_set;
			inner		: boolean;
			var first	: treas_ptr;
			var count	: integer) : boolean;
      var
		flag            : boolean;
		ptr		: treas_ptr;
      begin
	count := 0;
	ptr := inventory_list;
	flag := false;
	first := nil;
	change_all_ok_stats(false,false);
	while (ptr <> nil) do
	  begin
	    if (ptr^.data.tval in item_val) and
	       ((ptr^.is_in = false) or inner) and
	       ((ptr^.insides = 0) or (ptr^.data.tval <> bag_or_sack)) then
	      begin
	        if (not(flag)) then
	          begin
		    flag := true;
		    first := ptr;
	          end;
		ptr^.ok := true;
		count := count + 1;
	      end;
	    ptr := ptr^.next;
	  end;
	find_range := flag;
      end;

    [global,psect(moria$code)] function player_test_hit(bth,level,pth,ac : integer; was_fired : boolean) : boolean;
	var i1 : integer;
	begin
	  if (search_flag) then search_off;
	  if (py.flags.rest > 0) then rest_off;
	  i1 := bth + pth*bth_plus_adj;
	  if was_fired then
	    i1 := i1 + (level*class[py.misc.pclass].mbthb) div 2
	  else
	    i1 := i1 + (level*class[py.misc.pclass].mbth) div 2;
	  if (randint(i1) > ac) then
	    player_test_hit := true
	  else if (randint(20) = 1) then
	    player_test_hit := true
	  else player_test_hit := false;
	end;

	{ Attacker's level and pluses, defender's AC		-RAK-	}
    [global,psect(moria$code)] function test_hit(bth,level,pth,ac : integer) : boolean;
      var
		i1                      : integer;
      begin
	if (search_flag) then
	  search_off;
	if (py.flags.rest > 0) then
	  rest_off;
	i1 := bth + level*bth_lev_adj + pth*bth_plus_adj;
{ hits if above ac or 1 in 20.  OOK! }
	test_hit := (randint(i1) > ac) or (randint(20) = 1);
      end;


	{ Deletes a monster entry from the level		-RAK-	}
    [global,psect(moria$code)] procedure delete_monster(i2 : integer);
      var
		i1,i3           : integer;
      begin
	i3 := m_list[i2].nptr;
	if (muptr = i2) then
	  muptr := i3
	else
	  begin
	    i1 := muptr;
	    while (m_list[i1].nptr <> i2) do
	      i1 := m_list[i1].nptr;
	    m_list[i1].nptr := i3;
	  end;
	with m_list[i2] do
	  begin
	    cave[fy,fx].cptr := 0;
	    if (ml) then
	      with cave[fy,fx] do
		if ((pl) or (tl)) then
		  lite_spot(fy,fx)
		else
		  unlite_spot(fy,fx);
	    pushm(i2);
	  end;
	mon_tot_mult := mon_tot_mult - 1;
      end;


	{ Creates objects nearby the coordinates given		-RAK-	}
	{ BUG: Because of the range, objects can actually be placed into}
	{      areas closed off to the player, this is rarely noticable,}
	{      and never a problem to the game.                         }
  [global,psect(moria$code)] procedure summon_object(y,x,num,typ : integer);
    var
	i1,i2,i3                : integer;
    begin
      repeat
	i1 := 0;
	repeat
	  i2 := y - 3 + randint(5);
	  i3 := x - 3 + randint(5);
	  if (in_bounds(i2,i3)) then
	   if (los(y,x,i2,i3)) then	{OOK!}
	    with cave[i2,i3] do
	      if (fval in floor_set) then
		if (tptr = 0) then
		  begin
		    case typ of                 { Select type of object }
		      1 :  place_object(i2,i3);
		      2 :  place_gold(i2,i3);
		      3 :  if (randint(100) < 50) then
			     place_object(i2,i3)
			   else
			     place_gold(i2,i3);
		      otherwise ;
		    end;
		    if (test_light(i2,i3)) then
		      lite_spot(i2,i3);
		    i1 := 10;
		  end;
	  i1 := i1 + 1;
	until (i1 > 10);
	num := num - 1;
      until (num = 0);
    end;


	{ Prompt for what type of money to use			-DMF-	}
      [global,psect(moria$code)] function get_money_type(
			prompt		: string;
			var back	: boolean;
			no_check	: boolean) : integer;
        var
	  out_val	: string;
	  comma_flag	: boolean;
	  test_flag	: boolean;
	  com_val	: integer;

	procedure prompt_money(str : vtype);
	  begin
	    if (comma_flag) then
		out_val := out_val + ', ';
	    out_val := out_val + str;
	    comma_flag := true;
	  end;

        begin
	 with py.misc do
	  begin
	    out_val := prompt;
	    comma_flag := false;
	    test_flag := false;
	    if (money[6] > 0) or (no_check) then prompt_money('<m>ithril');
	    if (money[5] > 0) or (no_check) then prompt_money('<p>latinum');
	    if (money[4] > 0) or (no_check) then prompt_money('<g>old');
	    if (money[3] > 0) or (no_check) then prompt_money('<s>ilver');
	    if (money[2] > 0) or (no_check) then prompt_money('<c>opper');
	    if (money[1] > 0) or (no_check) then prompt_money('<i>ron');
	    prt(out_val,1,1);
	    back := true;
	    repeat
	      inkey(command);
	      com_val := ord(command);
	      case com_val of
		0,3,25,26,27 : begin
				test_flag := true;
				back := false;
			       end;
		109	:  test_flag := (mithril > 0) or (no_check);
		112	:  test_flag := (platinum > 0) or (no_check);
		103	:  test_flag := (gold > 0) or (no_check);
		115	:  test_flag := (silver > 0) or (no_check);
		 99	:  test_flag := (copper > 0) or (no_check);
		105	:  test_flag := (iron > 0) or (no_check);
	      otherwise    ;
	    end;
	  until (test_flag);
	 end;
	 get_money_type := com_val;
        end;

  { Sets the weight of the money type passed. }
[global,psect(moria$code)] function coin_stuff(
			typ 		: char;    { Initial of coin metal }
			var type_num : integer) : boolean;
	begin
	  coin_stuff := true;
	    case (typ) of
		'm' : type_num := mithril;
		'p' : type_num := platinum;
	  	'g' : type_num := gold;
		's' : type_num := silver;
		'c' : type_num := copper;
		'i' : type_num := iron;
		otherwise coin_stuff := false;
	    end;
	end;

[global,psect(moria$code)] function set_money(
				typ : char;        { Initial of money type }
				coin_num : integer { Number of coins }
						) : boolean;
	begin
	  set_money := true;
	  with py.misc do
	    case (typ) of
		'm' : money[mithril] := coin_num;
		'p' : money[platinum] := coin_num;
		'g' : money[gold] := coin_num;
		's' : money[silver] := coin_num;
		'c' : money[copper] := coin_num;
		'i' : money[iron] := coin_num;
		otherwise set_money := false;
	      end;
	end;


	{ Given speed, returns number of moves this turn.	-RAK-	}
	{ NOTE: Player must always move at least once per iteration,    }
	{       a slowed player is handled by moving monsters faster    }
     [global,psect(moria$code)] function movement_rate(
		cspeed,mon		: integer) : integer;
      var
		final_rate	: integer; { final speed as integer }
		c_rate,py_rate	: integer; { rate (0,1,2,3) = (0,1/4,1/2,1)
					     in wrong element }
      begin
	with m_list[mon] do
	  with c_list[mptr] do
	    with cave[fy,fx] do
	      if (fval in earth_set) <> (uand(cmove,%X'00000010') = 0) then
		  c_rate := INT(uand(cmove,%X'00000300') div 256)
	      else
		c_rate := 3;
	if (c_rate = 3) then c_rate := 4;
	py_rate := py.flags.move_rate;
	if (cspeed > 0) then
	  c_rate := c_rate * cspeed
	else
	  py_rate := py_rate * (2-cspeed);
        final_rate := c_rate div py_rate;
	if ((c_rate * turn) mod py_rate < c_rate mod py_rate) then
	  final_rate := final_rate + 1;
 { if player resting, max monster move = 1 }
	if ((final_rate > 1) and (py.flags.rest > 0)) then	
	  movement_rate := 1
	else
	  movement_rate := final_rate;
      end;


    [global,psect(moria$code)] procedure get_player_move_rate;
      var cur_swim : integer;
      begin
	with py.flags do
	  if (cave[char_row,char_col].fval in earth_set) then 
	    move_rate := 4
	  else
	    begin
		cur_swim := ((swim + randint(5) - 1) div 5);
		if (cur_swim <= -2) then move_rate := 0
		else if (cur_swim = -1) then move_rate := 1
		else if (cur_swim = 0) then move_rate := 2
		else if (cur_swim = 1) then move_rate := 4
		else move_rate := 8;
	    end;
      end;	  


{BLEGGA}

	{ Lose experience hack for lose_exp breath		-RAK-	}
[global,psect(moria$code)] procedure xp_loss(amount : integer);
    var
	i1,i2                           : integer;
	av_hp,lose_hp                   : integer;
	av_mn,lose_mn                   : integer;
	flag                            : boolean;
    begin
      amount := (py.misc.exp div 100) * mon$drain_life;
      with py.misc do
	begin
	  msg_print('You feel your life draining away!');
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
		if (mspell or pspell or dspell or bspell or mental) then
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
			else if (bspell) then
			  msg_print('You have forgotten a song!')
			else 
			  msg_print('You have forgotten a discipline!');
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


	{ Tunneling through real wall: 10,11,12 		-RAK-	}
	{ Used by TUNNEL and WALL_TO_MUD                                }
      [global,psect(moria$code)] function twall(y,x,t1,t2 : integer) : boolean;
	begin
	  twall := false;
	  with cave[y,x] do
	    if (t1 > t2) then
	      begin
		if (next_to4(y,x,[1,2]) > 0) then
		  begin
		    fval  := corr_floor2.ftval;
		    fopen := corr_floor2.ftopen;
		  end
		else
		  begin
		    fval  := corr_floor1.ftval;
		    fopen := corr_floor1.ftopen;
		  end;
		if (test_light(y,x)) then
		  if (panel_contains(y,x)) then
		    begin
		      if (tptr > 0) then
			msg_print('You have found something!');
		      lite_spot(y,x);
		    end;
		fm := false;
		pl := false;
		twall := true;
	      end;
	end;


	{ Moria game module					-RAK-	}
	{ The code in this section has gone through many revisions, and }
	{ some of it could stand some more hard work...  -RAK-          }
[global,psect(moria$code)] procedure dungeon;

    function water_hear_range : integer;
      begin
	water_hear_range := 10;
      end;

    function water_see_range : integer;
      begin
	water_see_range := 5;
      end;


	{ I may have written the town level code, but I'm not exactly   }
	{ proud of it.  Adding the stores required some real slucky     }
	{ hooks which I have not had time to re-think.          -RAK-   }


	{ Prompts for a direction				-RAK-	}
     function get_dir(prompt : vtype;
		     var dir,com_val,y,x : integer) : boolean;
      var
		temp_prompt     : vtype;
		flag            : boolean;
		command         : char;
      begin
	flag := false;
	temp_prompt := '(1 2 3 4 6 7 8 9) ' + prompt;
	prompt := '';
	repeat
	  if (get_com(prompt,command)) then
	    begin
	      com_val := ord(command);
	      dir := com_val - 48;
		{ Note that '5' is not a valid direction        }
	      if (dir in [1,2,3,4,6,7,8,9]) then
		begin
		  move(dir,y,x);
		  flag := true;
		  get_dir := true;
		end
	      else
		prompt := temp_prompt;
	    end
	  else
	    begin
	      reset_flag := true;
	      get_dir := false;
	      flag := true;
	    end;
	until (flag);
      end;


	{ Returns random co-ordinates				-RAK-	}
    procedure new_spot(var y,x : integer; swim : boolean);
      begin
	repeat
	  y := randint(cur_height);
	  x := randint(cur_width);
	until ( (cave[y,x].fopen)       and
		(cave[y,x].cptr = 0)    and
		(cave[y,x].tptr = 0)	and
		(swim or (swim <> (cave[y,x].fval in water_set))));
      end;


	{ Search Mode enhancement				-RAK-	}
    procedure search_on;
      begin
	search_flag := true;
	change_speed(+1);
	py.flags.status := uor(py.flags.status,%X'00000100');
	prt_search;
	with py.flags do
	  food_digested := food_digested + 1;
      end;

	{ Resting allows a player to safely restore his hp	-RAK-	}
    procedure rest;
      var
		rest_num                : integer;
		rest_str                : vtype;
      begin
	prt('Rest for how long? ',1,1);
	get_string(rest_str,1,20,10);
	rest_num := 0;
	readv(rest_str,rest_num,error:=continue);
	if (rest_num > 0) then
	  begin
	    if (search_flag) then
	      search_off;
	    py.flags.rest := rest_num;
	    turn_counter := turn_counter + rest_num;
	    py.flags.status := uor(py.flags.status,%X'00000200');
	    prt_rest;
	    with py.flags do
	      food_digested := food_digested - 1;
	    msg_print('Press any key to wake up...');
	    put_qio;
	  end
	else
	  erase_line(msg_line,msg_line);
      end;


	{ Teleport the player to a new location 		-RAK-	}
    procedure teleport(dis : integer);
      var
		y,x     : integer;
      begin
	repeat
	  y := randint(cur_height);
	  x := randint(cur_width);
	  while (distance(y,x,char_row,char_col) > dis) do
	    begin
	      y := y + trunc((char_row-y)/2);
	      x := x + trunc((char_col-x)/2);
	    end;
	until ((cave[y,x].fopen) and (cave[y,x].cptr  < 2));
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
	teleport_flag := false;
      end;


	{ Return spell number and failure chance		-RAK-	}
     function cast_spell(prompt		: vtype;
			item_ptr	: treas_ptr;
			var sn,sc	: integer;
			var redraw	: boolean) : boolean;
      var
		i2,i4           : unsigned;
		i1,i3           : integer;
		spell           : spl_type;
      begin
	i1 := 0;
	i2 := item_ptr^.data.flags;
	i4 := item_ptr^.data.flags2;
	repeat
	  i3 := bit_pos64(i4,i2);
{ Avoid the cursed bit like the plague				-DMF-	}
	  if (i3 > 31) then i3 := i3 - 1;
	  if (i3 > 0) then
	    with magic_spell[py.misc.pclass,i3] do
	      if (slevel <= py.misc.lev) then
		if (learned) then
		  begin
		    i1 := i1 + 1;
		    spell[i1].splnum := i3;
		  end;
	until((i2 = 0) and (i4 = 0));
	if (i1 > 0) then
	  cast_spell := get_spell(spell,i1,sn,sc,prompt,redraw);
	if (redraw) then
	  draw_cave;
      end;


	{ Examine a Book					-RAK-	}
    procedure examine_book;
      var
		i2,i4                   : unsigned;
		i3,i5			: integer;
		i1,item_ptr		: treas_ptr;
		redraw,flag             : boolean;
		dummy                   : char;
		out_val                 : vtype;
      begin
	redraw := false;
	if (not(find_range([Magic_book,Prayer_Book,Instrument,Song_book],false,i1,i3))) then
	  msg_print('You are not carrying any books.')
	else if (get_item(item_ptr,'Which Book?',redraw,i3,trash_char,false)) then
	  begin
	    flag := true;
	    with item_ptr^.data do
	      if (class[py.misc.pclass].mspell) then
		begin
		  if (tval <> Magic_Book) then
		    begin
		      msg_print('You do not understand the language.');
		      flag := false;
		    end;
		end
	      else if (class[py.misc.pclass].pspell) then
		begin
		  if (tval <> Prayer_Book) then
		    begin
		      msg_print('You do not understand the language.');
		      flag := false;
		    end;
		end
	      else if (class[py.misc.pclass].dspell) then
		begin
		  if (tval <> Instrument) then
		    begin
		      msg_print('You do not posses the talent.');
		      flag := false;
		    end;
		end
	      else if (class[py.misc.pclass].bspell) then
		begin
		  if (tval <> Song_book) then
		    begin
		      msg_print('You can not read the music.');
		      flag := false;
		    end;
		end
	      else
		begin
		  msg_print('You do not understand the language.');
		  flag := false;
		end;
	    if (flag) then
	      begin
		redraw := true;
		i5 := 0;
		i2 := item_ptr^.data.flags;
		i4 := item_ptr^.data.flags2;
		clear(1,1);
	writev(out_val,'   Name                         Level  Mana   Known');
		prt(out_val,1,1);
		repeat
		  i3 := bit_pos64(i4,i2);
		  if (i3 > 31) then i3 := i3 - 1;
		  if (i3 > 0) then
		    with magic_spell[py.misc.pclass,i3] do
		      begin
			i5 := i5 + 1;
			if (slevel < 99) then
			  begin
			    writev(out_val,chr(96+i5),') ',pad(sname,' ',30),
				slevel:2,'     ',smana:2,'   ',learned);
			    prt(out_val,i5+1,1);
			  end
			else
			  prt('',i5+1,1);
		      end;
		until ((i2 = 0) and (i4 = 0));
		prt('[Press any key to continue]',24,20);
		inkey(dummy);
	      end;
	  end;
	if (redraw) then draw_cave;
      end;


	{ Drop an object being carried				-RAK-	}
	{ Note: Only one object per floor spot...                       }
    procedure drop;
      var
		i1,i2		: integer;
		com_ptr		: treas_ptr;
		redraw          : boolean;
		out_val         : vtype;
		temp		: integer;
		count		: integer;
      begin
	reset_flag := true;
	with py.misc do
	  temp := money[6]+money[5]+money[4]+money[3]+money[2]+money[1];
	if (inven_ctr > 0) or (temp > 0) then
	  begin
	    count := change_all_ok_stats(true,false);
	    com_ptr := inventory_list;
	    while (com_ptr <> nil) do
	      begin
		if (com_ptr^.data.tval = bag_or_sack) and
		   (com_ptr^.insides <> 0) then
		  begin
		    com_ptr^.ok := false;
		    count := count - 1;
		  end;
		com_ptr := com_ptr^.next;
	      end;
	      redraw := false;  {Someone said that it always redraws when drop}
	      if (get_item(com_ptr,'Which one? ',redraw,count,trash_char,true)) then
	      begin
		if (redraw) then draw_cave;
		with cave[char_row,char_col] do
		  if (tptr > 0) then
		    msg_print('There is something there already.')
		  else
		    begin
		      if (trash_char = '$') then
		        inven_drop(com_ptr,char_row,char_col,true)
		      else
			inven_drop(com_ptr,char_row,char_col,false);
		      prt_weight;
		      objdes(out_val,inven_temp,true);
		      out_val := 'Dropped ' + out_val + '.';
		      msg_print(out_val);
		      reset_flag := false;
		    end
	      end
	    else if (redraw) then
	      draw_cave;
	  end
	else
	  msg_print('You are not carrying anything.');
      end;


	{ Deletes object from given location			-RAK-	}
   [global,psect(moria$code)] function delete_object(y,x : integer) : boolean;
    begin
      delete_object := false;
      with cave[y,x] do
	begin
	  if (t_list[tptr].tval = Secret_door) then
	    fval := corr_floor3.ftval;
	  fopen := true;
	  pusht(tptr);
	  tptr := 0;
	  fm := false;
	  if (test_light(y,x)) then
	    begin
	      lite_spot(y,x);
	      delete_object := true;
	    end
	  else
	    unlite_spot(y,x);
	end;
    end;


	{ Chests have traps too...				-RAK-	}
	{ Note: Chest traps are based on the FLAGS value                }
    procedure chest_trap(y,x : integer);
      var
	i1,i2,i3                : integer;
	ident			: boolean;
      begin
	with t_list[cave[y,x].tptr] do
	  begin
	    if (uand(%X'00000010',flags) <> 0) then
	      begin
		msg_print('A small needle has pricked you!');
		if lose_stat(sr,'','You are unaffected.') then
		  begin
		    take_hit(damroll('1d4'),'a poison needle.');
		    print_stat := uor(%X'0001',print_stat);
		    msg_print('You feel weakened!');
		  end
	      end;
	    if (uand(%X'00000020',flags) <> 0) then
	      begin
		msg_print('A small needle has pricked you!');
		take_hit(damroll('1d6'),'a poison needle.');
		py.flags.poisoned := py.flags.poisoned + 10 + randint(20);
	      end;
	    if (uand(%X'00000040',flags) <> 0) then
	      begin
		msg_print('A puff of yellow gas surrounds you!');
		if (py.flags.free_act) then
		  msg_print('You are unaffected.')
		else
		  begin
		    msg_print('You choke and pass out.');
		    py.flags.paralysis := 10 + randint(20);
		  end;
	      end;
	    if (uand(%X'00000080',flags) <> 0) then
	      begin
		msg_print('There is a sudden explosion!');
		delete_object(y,x);
		take_hit(damroll('5d8'),'an exploding chest.');
	      end;
	    if (uand(%X'00000100',flags) <> 0) then
	      begin
		for i1 := 1 to 3 do
		  begin
		    i2 := y;
		    i3 := x;
		    if (cave[i2,i3].fval in water_set) then
		      summon_water_monster(i2,i3,false)
		    else
		      summon_land_monster(i2,i3,false);
		  end;
	      end;
	  end;
      end;


	{ Opens a closed door or closed chest...		-RAK-	}
    procedure openobject;
      var
		y,x,tmp         : integer;
		flag            : boolean;
      begin
	y := char_row;
	x := char_col;
	if (get_dir('Which direction?',tmp,tmp,y,x)) then
	  begin
	    with cave[y,x] do
	      if (tptr > 0) then
			{ Closed door           }
		if (t_list[tptr].tval = Closed_door) then
		  with t_list[tptr] do
		    begin
		      if (p1 > 0) then  { It's locked...        }
			begin
			  with py.misc do
			    tmp := disarm + lev + 2*todis_adj + spell_adj(iq);
			  if (py.flags.confused > 0) then
			    msg_print('You are too confused to pick the lock.')
			  else if ((tmp-p1) > randint(100)) then
			    begin
			      msg_print('You have picked the lock.');
			      py.misc.exp := py.misc.exp + 1;
			      prt_experience;
			      p1 := 0;
			    end
			  else
			    msg_print('You failed to pick the lock.');
			end
		      else if (p1 < 0) then     { It's stuck    }
			msg_print('It appears to be stuck.');
		      if (p1 = 0) then
			begin
			  t_list[tptr] := door_list[1];
			  fopen := true;
			  lite_spot(y,x);
			end;
		    end
			{ Open a closed chest...                }
		else if (t_list[tptr].tval = chest) then
		  begin
		    with py.misc do
		      tmp := disarm + lev + 2*todis_adj + spell_adj(iq);
		    with t_list[tptr] do
		      begin
			flag := false;
			if (uand(%X'00000001',flags) <> 0) then
			  if (py.flags.confused > 0) then
			    msg_print('You are too confused to pick the lock.')
			  else if ((tmp-(2*level)) > randint(100)) then
			    begin
			      msg_print('You have picked the lock.');
			      flag := true;
			      py.misc.exp := py.misc.exp + level;
			      prt_experience;
			    end
			  else
			    msg_print('You failed to pick the lock.')
			else
			  flag := true;
			if (flag) then
			  begin
			    flags := uand(%X'FFFFFFFE',flags);
			    tmp := index(name,' (');
			    if (tmp > 0) then
			      name := substr(name,1,tmp-1);
			    name := name + ' (Empty)';
			    known2(name);
			    cost := 0;
			  end;
			flag := false;
			{ Was chest still trapped?  (Snicker)   }
			if (uand(%X'00000001',flags) = 0) then
			  begin
			    chest_trap(y,x);
			    if (tptr > 0) then
			      flag := true
			  end;
		      end;
			{ Chest treasure is allocted as if a creature   }
			{ had been killed...                            }
		    if (flag) then
		      begin
			monster_death(y,x,t_list[tptr].flags);
			t_list[tptr].flags := 0;
		      end;
		  end
		else
		  msg_print('I do not see anything you can open there.')
	      else
		msg_print('I do not see anything you can open there.')
	  end;
      end;


	{ Closes an open door...				-RAK-	}
    procedure closeobject;
      var
		y,x,tmp         : integer;
		m_name		: vtype ;
      begin
	y := char_row;
	x := char_col;
	if (get_dir('Which direction?',tmp,tmp,y,x)) then
	  begin
	    with cave[y,x] do
	      if (tptr > 0) then
		if (t_list[tptr].tval = Open_door) then
		  if (cptr = 0) then
		    if (t_list[tptr].p1 = 0) then
		      begin
			t_list[tptr] := door_list[2];
			fopen := false;
			lite_spot(y,x);
		      end
		    else
		      msg_print('The door appears to be broken.')
		  else
		    begin
		      find_monster_name ( m_name, cptr, true ) ;
		      msg_print( m_name + ' is in your way!')
		    end
		else
		  msg_print('I do not see anything you can close there.')
	      else
		msg_print('I do not see anything you can close there.')
	  end;
      end;

	{ Go up one level					-RAK-	}
	{ Or several, with a steep staircase			-DMF-	}
    procedure go_up;
      begin
	with cave[char_row,char_col] do
	if (tptr > 0) then
	  if (t_list[tptr].tval = Up_staircase) then
	    begin
	      dun_level := dun_level - 1;
	      moria_flag := true;
	      msg_print('You enter a maze of up staircases.');
	      msg_print('You pass through a one-way door.');
	    end
	  else if (t_list[tptr].tval = Up_steep_staircase) then
	    begin
	      dun_level := dun_level - randint(3) - 1;
	      if (dun_level < 0) then dun_level := 0;
	      moria_flag := true;
	      msg_print('You enter a long maze of up staircases.');
	      msg_print('You pass through a one-way door.');
	    end
	  else
	    msg_print('I see no up staircase here.')
	else
	  msg_print('I see no up staircase here.');
      end;


	{ Go down one level					-RAK-	}
	{ Or several, with a steep staircase			-DMF-	}
    procedure go_down;
      begin
	with cave[char_row,char_col] do
	if (tptr > 0) then
	  if (t_list[tptr].tval = Down_staircase) then
	    begin
	      dun_level := dun_level + 1;
	      moria_flag := true;
	      msg_print('You enter a maze of down staircases.');
	      msg_print('You pass through a one-way door.');
	    end
	  else if (t_list[tptr].tval = Down_steep_staircase) then
	    begin
	      dun_level := dun_level + randint(3) + 1;
	      moria_flag := true;
	      msg_print('You enter a long maze of down staircases.');
	      msg_print('You pass through a one-way door.');
	    end
	  else
	    msg_print('I see no down staircase here.')
	else
	  msg_print('I see no down staircase here.');
      end;


	{ Tunnels through rubble and walls			-RAK-	}
	{ Must take into account: secret doors, special tools           }
    procedure tunnel;
      var
		y,x,i1,i2,tabil         : integer;
      begin
	y := char_row;
	x := char_col;
	if (get_dir('Which direction?',i1,i1,y,x)) then
	  with cave[y,x] do
	    begin
	{ Compute the digging ability of player; based on       }
	{ strength, and type of tool used                       }
	      tabil := (py.stat.c[sr] + 20) div 5;
	      if (equipment[Equipment_primary].tval > 0) then
		with equipment[Equipment_primary] do
		  if (uand(tunneling_worn_bit,flags) <> 0) then
		    tabil := tabil + 25 + p1*50;
	{ Regular walls; Granite, magma intrusion, quartz vein  }
	{ Don't forget the boundry walls, made of titanium (255)}
	      case fval of
		10 : begin
			i1 := randint(1200) + 80;
			if (twall(y,x,tabil,i1)) then
			  msg_print('You have finished the tunnel.')
			else
			  msg_print('You tunnel into the granite wall.');
		      end;
		11 : begin
			i1 := randint(600) + 10;
			if (twall(y,x,tabil,i1)) then
			  msg_print('You have finished the tunnel.')
			else
			  msg_print('You tunnel into the magma intrusion.');
		      end;
		12 : begin
			i1 := randint(400) + 10;
			if (twall(y,x,tabil,i1)) then
			  msg_print('You have finished the tunnel.')
			else
			  msg_print('You tunnel into the quartz vein.');
		      end;
		15 : msg_print('This seems to be permanent rock.');
		16 : msg_print('You can''t tunnel through water!');
		otherwise begin
	{ Is there an object in the way?  (Rubble and secret doors)}
		  if (tptr > 0) then
		    begin
		{ Rubble...     }
		      if (t_list[tptr].tval = Rubble) then
			begin
			  if (tabil > randint(180)) then
			    begin
			      pusht(tptr);
			      tptr := 0;
			      fm := false;
			      fopen := true;
			      msg_print('You have removed the rubble.');
			      if (randint(10) = 1) then
				begin
				  place_object(y,x);
				  if (test_light(y,x)) then
				    msg_print('You have found something!');
				end;
			      lite_spot(y,x);
			    end
			  else
			    msg_print('You dig in the rubble...');
			end
		{ Secret doors...}
		      else if (t_list[tptr].tval = Secret_door) then
			begin
			  msg_print('You tunnel into the granite wall.');
			  search(char_row,char_col,py.misc.srh);
			end
		      else
			msg_print('You can''t tunnel through that.');
		    end
		  else
		    msg_print('Tunnel through what?  Empty air???');
		end;
	      end;
	    end;
      end;


	{ Disarms a trap					-RAK-	}
    procedure disarm_trap;
      var
	y,x,i1,tdir                             : integer;
	tot,t1,t2,t3,t4,t5                      : integer;
      begin
	y := char_row;
	x := char_col;
	if (get_dir('Which direction?',tdir,i1,y,x)) then
	  with cave[y,x] do
	    begin
	      if (tptr > 0) then
		begin
		  t1 := py.misc.disarm; { Ability to disarm     }
		  t2 := py.misc.lev;    { Level adjustment      }
		  t3 := 2*todis_adj;    { Dexterity adjustment  }
		  t4 := spell_adj(iq);        { Intelligence adjustment}
		  tot := t1 + t2 + t3 + t4;
		  if (py.flags.blind > 0) then
		    tot := trunc(tot/5.0)
		  else if (no_light) then
		    tot := trunc(tot/2.0);
		  if (py.flags.confused > 0) then
		    tot := trunc(tot/3.0);
		  i1 := t_list[tptr].tval;
		  t5 := t_list[tptr].level;
		  if (i1 = Seen_trap) then            { Floor trap    }
		    with t_list[tptr] do
		      begin
			if ((tot - t5) > randint(100)) then
			  begin
			    msg_print('You have disarmed the trap.');
			    py.misc.exp := py.misc.exp + p1;
			    fm := false;
			    pusht(tptr);
			    tptr := 0;
			    move_char(tdir);
			    lite_spot(y,x);
			    prt_experience;
			  end
			else if (randint(tot) > 5) then
			  msg_print('You failed to disarm the trap.')
			else
			  begin
			    msg_print('You set the trap off!');
			    move_char(tdir);
			  end;
		      end
		  else if (i1 = 2) then         { Chest trap    }
		    with t_list[tptr] do
		      begin
			if (index(name,'^') > 0) then
			  msg_print('I don''t see a trap...')
			else if (uand(%X'000001F0',flags) <> 0) then
			  begin
			    if ((tot - t5) > randint(100)) then
			      begin
				flags := uand(%X'FFFFFE0F',flags);
				i1 := index(name,' (');
				if (i1 > 0) then
				  name := substr(name,1,i1-1);
				if (uand(%X'00000001',flags) <> 0) then
				  name := name + ' (Locked)'
				else
				  name := name + ' (Disarmed)';
				msg_print('You have disarmed the chest.');
				known2(name);
				py.misc.exp := py.misc.exp + t5;
				prt_experience;
			      end
			    else if (randint(tot) > 5) then
			      msg_print('You failed to disarm the chest.')
			    else
			      begin
				msg_print('You set a trap off!');
				known2(name);
				chest_trap(y,x);
			      end;
			  end
			else
			  msg_print('The chest was not trapped.');
		      end
		  else
		    msg_print('I do not see anything to disarm there.');
		end
	      else
		msg_print('I do not see anything to disarm there.');
	    end
      end;


	{ Look at an object, trap, or monster			-RAK-	}
	{ Note: Looking is a free move, see where invoked...            }
    procedure look;
      var
		i1,i2,y,x       : integer;
		dir,dummy       : integer;
		flag            : boolean;
		fchar           : char;
      begin
	flag := false;
	y := char_row;
	x := char_col;
	if (get_dir('Look which direction?',dir,dummy,y,x)) then
	  if (py.flags.blind < 1) then
	    begin
	      y := char_row;
	      x := char_col;
	      i1 := 0;
	      repeat
		move(dir,y,x);
		with cave[y,x] do
		  begin
		    if (cptr > 1) then
		      if (m_list[cptr].ml) then
			begin
			  i2 := m_list[cptr].mptr;
			  fchar := c_list[i2].name[1];
			  if (fchar in vowel_set) then
			    writev(out_val,'You see an ',c_list[i2].name,'.')
			  else
			    writev(out_val,'You see a ',c_list[i2].name,'.');
			  msg_print(out_val);
			  flag := true;
			end;
		    if ((tl) or (pl) or (fm)) then
		      begin
			if (tptr > 0) then
			  if (t_list[tptr].tval = Secret_door) then
			    msg_print('You see a granite wall.')
			  else if (t_list[tptr].tval <> Unseen_trap) then
			    begin
			      inven_temp^.data := t_list[tptr];
			      inven_temp^.data.number := 1;
			      objdes(out_val,inven_temp,true);
			      msg_print('You see ' + out_val + '.');
			      flag := true;
			    end;
			if (not(fopen)) then
			  begin
			    flag := true;
			    case fval of
			      10 : msg_print('You see a granite wall.');
			      11 : msg_print('You see some dark rock.');
			      12 : msg_print('You see a quartz vein.');
			      15 : msg_print('You see a granite wall.');
			      otherwise ;
			    end;
			  end
			else
			  case fval of
			    16,17 : begin
				      flag := true;
				      msg_print('You see some water.');
				    end;
			    otherwise ;
			  end;
		      end;
		    end;
		i1 := i1 + 1;
	      until ((not cave[y,x].fopen) or (i1 > max_sight));
	      if (not flag) then
		msg_print('You see nothing of interest in that direction.');
	    end
	  else
	    msg_print('You can''t see a damn thing!');
      end;


	{ Add to the players food time				-RAK-	}
    procedure add_food(num : integer);
      begin
	with py.flags do
	  begin
	    if (food < 0) then food := 0;
	    food := food + num;
	    if (food > player_food_full) then msg_print('You are full.');
	    if (food > player_food_max) then
	      begin
		msg_print('You''re getting fat from eating so much.');
		food := player_food_max;
		py.misc.wt := py.misc.wt + trunc(py.misc.wt*0.1);
		if py.misc.wt > max_allowable_weight then
		  begin
		    msg_print ( 'Oh no...  Now you''ve done it.' ) ;
		    death := true ;
		    moria_flag := true ;
		    total_winner := false ;
		    died_from := 'gluttony.'
		  end
		else
		  begin
		    case randint(3) of
			1 : msg_print ( 'Buuurrrppppp !' ) ;
			2 : msg_print ( 'Remember, obesity kills.' ) ;
			3 : msg_print ( 'Your armor doesn''t seem to fit too well anymore.' ) ;
		    end ;	
		  end ;	
	      end;
	  end;
      end;


	{ Describe number of remaining charges...		-RAK-	}
    procedure desc_charges(item_ptr : treas_ptr);
      var
	rem_num                 : integer;
	out_val                 : vtype;
      begin
	if (index(item_ptr^.data.name,'^') = 0) then
	  begin
	    rem_num := item_ptr^.data.p1;
	    writev(out_val,'You have ',rem_num:1,' charges remaining.');
	    msg_print(out_val);
	  end;
      end;


	{ Describe amount of item remaining...			-RAK-	}
    procedure desc_remain(item_ptr : treas_ptr);
      var
	out_val                 : vtype;

      begin
	inven_temp^.data := item_ptr^.data;
	with inven_temp^.data do
	  number := number - 1;
	objdes(out_val,inven_temp,true);
	out_val := 'You have ' + out_val + '.';
	msg_print(out_val);
      end;


	{ Throw an object across the dungeon... 		-RAK-	}
	{ Note: Flasks of oil do fire damage                            }
	{ Note: Extra damage and chance of hitting when missles are used}
	{       with correct weapon.  I.E.  wield bow and throw arrow.  }
    procedure throw_object(to_be_fired : boolean);
      var
	item_val,tbth,tpth,tdam,tdis,crit_mult	: integer;
	y_dumy,x_dumy,dumy	                : integer;
	y,x,oldy,oldx,dir,cur_dis,count         : integer;
	redraw,flag			        : boolean;
	out_val, m_name				: vtype;
	item_ptr,i7				: treas_ptr;

      procedure inven_throw(item_ptr : treas_ptr);
	begin
	  inven_temp^.data := item_ptr^.data;
	  inven_temp^.data.number := 1;
	  with item_ptr^.data do
	    begin
	      if ((number > 1) and (subval > 511)) then
		begin
		  number := number - 1;
		  inven_weight := inven_weight - weight;
		end
	      else
		inven_destroy(item_ptr);
	    end;
	    prt_weight;
	end;


      function poink : obj_set;
        begin
	  with equipment[equipment_primary] do
	    if (tval = bow_crossbow_or_sling) then
	      case p1 of
		1 : poink := [sling_ammo];
	        2,3,4 : poink := [arrow];
	        5,6 : poink := [bolt]
	      end
	    else
	      poink := []
	end;

      procedure facts(var tbth,tpth,tdam,tdis : integer);
	var
		tmp_weight                      : integer;
	begin
	  with inven_temp^.data do
	    begin
	      if (weight < 1) then
		tmp_weight := 1
	      else
		tmp_weight := weight;
		{ Throwing objects			}
	      tdam := damroll(damage) + todam;
	      tbth := trunc(py.misc.bthb*0.75);
	      tpth := py.misc.ptohit  + tohit;
	      tdis := trunc((py.stat.c[sr]+100)*200/tmp_weight);
	      if (tdis > 10) then tdis := 10;
		{ Using Bows, slings, or crossbows	}
	      if (to_be_fired) then	{ checks for correct wpn in poink }
		begin
		 case equipment[Equipment_primary].p1 of
		  1 : 	begin       { Sling and Bullet  }
			  tdam := tdam + 2;
			  tdis := 20;
			end;
		  2 :   begin       { Short Bow and Arrow    }
			  tdam := tdam + 2;
			  tdis := 25;
			end;
		  3 :   begin       { Long Bow and Arrow     }
			  tdam := tdam + 3;
			  tdis := 30;
			end;
		  4 :   begin       { Composite Bow and Arrow}
			  tdam := tdam + 4;
			  tdis := 35;
			end;
		  5 :   begin       { Light Crossbow and Bolt}
			  tdam := tdam + 2;
			  tdis := 25;
			end;
		  6 :   begin       { Heavy Crossbow and Bolt}
			  tdam := tdam + 4;
			  tdis := 35;
			end;
		 end;
		 tbth := py.misc.bthb;
		 tpth := tpth + equipment[Equipment_primary].tohit;
		 weight := weight + equipment[Equipment_primary].weight + 5000;
		end;
	    end;
	end;

      procedure drop_throw(y,x : integer);
	var
		i1,i2,i3,cur_pos                : integer;
		flag                            : boolean;
		out_val                         : vtype;
	begin
	  flag := false;
	  i1 := y;
	  i2 := x;
	  i3 := 0;
	  if (randint(10) > 1) then
	    repeat
	      if (in_bounds(i1,i2)) then
		with cave[i1,i2] do
		  if (fopen) then
		    if (tptr = 0) then
		      flag := true;
	      if (not(flag)) then
		begin
		  i1 := y + randint(3) - 2;
		  i2 := x + randint(3) - 2;
		  i3 := i3 + 1;
		end;
	    until((flag) or (i3 > 9));
	  if (flag) then
	    begin
	      popt(cur_pos);
	      cave[i1,i2].tptr := cur_pos;
	      t_list[cur_pos] := inven_temp^.data;
	      if (test_light(i1,i2)) then
		lite_spot(i1,i2);
	    end
	  else
	    begin
	      objdes(out_val,inven_temp,false);
	      msg_print('The ' + out_val + ' disappears.');
	    end;
	end;

      begin
	redraw := false;
        if to_be_fired then
	  find_range(poink,false,i7,count)
        else
	  begin
	    count := change_all_ok_stats(true,false);
	    item_ptr := inventory_list;
	    while (item_ptr <> nil) do
	      begin
	        if (uand(item_ptr^.data.flags2,holding_bit) <> 0) and
	          (item_ptr^.insides > 0) then
	        count := count - 1;
	        item_ptr := item_ptr^.next;
	      end;
	  end;
	reset_flag := true;
	if to_be_fired then
	  writev(out_val,'Fire which one?')
	else
	  writev(out_val,'Hurl which item?');
	if (count = 0) then
	  if to_be_fired then
	    msg_print('You have nothing to fire!')
	  else
	    msg_print('But you have nothing to throw.')
	else
	 if (get_item(item_ptr,out_val,redraw,count,trash_char,false)) then
	   begin
	    if (redraw) then
	      draw_cave;
	    y_dumy := char_row;
	    x_dumy := char_col;
	    if (get_dir('Which direction?',dir,dumy,y_dumy,x_dumy)) then
	      begin
		reset_flag := false;
		desc_remain(item_ptr);
		if (py.flags.confused > 0) then
		  begin
		    msg_print('You are confused...');
		    repeat
		      dir := randint(9);
		    until(dir <> 5);
		  end;
		inven_throw(item_ptr);
		facts(tbth,tpth,tdam,tdis);
		with inven_temp^.data do
		  begin
		    flag := false;
		    y := char_row;
		    x := char_col;
		    oldy := char_row;
		    oldx := char_col;
		    cur_dis := 0;
		    repeat
		      move(dir,y,x);
		      cur_dis := cur_dis + 1;
		      if (test_light(oldy,oldx)) then
			lite_spot(oldy,oldx);
		      if (cur_dis > tdis) then flag := true;
		      with cave[y,x] do
			begin
			  if ((fopen) and (not(flag))) then
			    begin
			      if (cptr > 1) then
				begin
				  flag := true;
				  with m_list[cptr] do
				    begin
				      tbth := tbth - cur_dis;
				      if (player_test_hit(tbth,py.misc.lev,tpth,c_list[mptr].ac,to_be_fired)) then
					begin
					  i1 := mptr;
					  objdes(out_val,inven_temp,false);
	find_monster_name ( m_name, cptr, false ) ;
	msg_print('The ' + out_val + ' hits ' + m_name + '.');
	tdam := tot_dam(inven_temp^.data,tdam,c_list[i1]);
	with inven_temp^.data do
	  begin
	    crit_mult := critical_blow(weight,tpth,(uand(equipment[equipment_primary].flags2,sharp_worn_bit) <> 0),to_be_fired);
	    tdam := tdam + (5 + tdam) * crit_mult
	  end;
	if ( mon_take_hit(cptr,tdam) > 0) then
	  msg_print('You have killed ' + m_name + '.');
					end
				      else
					drop_throw(oldy,oldx);
				    end;
				end
			      else
				begin
				  if (panel_contains(y,x)) then
				    if (test_light(y,x)) then
				      print(tchar,y,x);
				end;
			    end
			  else
			    begin
			      flag := true;
			      drop_throw(oldy,oldx);
			    end;
			end;
		      oldy := y;
		      oldx := x;
		    until (flag);
		  end;
	      end
	    end
	  else
	      if (redraw) then draw_cave;
      end;


	{ Bash open a door or chest				-RAK-	}
	{ Note: Affected by strength and weight of character            }
    procedure bash;
      var
	y,x,tmp                                 : integer;
	old_ptodam,old_ptohit,old_bth           : integer;
	m_name					: vtype ;
      begin
	y := char_row;
	x := char_col;
	if (get_dir('Which direction?',tmp,tmp,y,x)) then
	  begin
	    with cave[y,x] do
	      if (cptr > 1) then
		begin
		  if (py.flags.afraid > 0) then
		    msg_print('You are afraid!')
		  else
		    begin
			{ Save old values of attacking  }
		      inven_temp^.data := equipment[Equipment_primary];
		      old_ptohit := py.misc.ptohit;
		      old_ptodam := py.misc.ptodam;
		      old_bth    := py.misc.bth;
			{ Use these values              }
		      equipment[Equipment_primary] := blank_treasure;
		      with equipment[Equipment_primary] do
			begin
			  damage := equipment[Equipment_shield].damage;
			  weight := (py.stat.c[sr] + 20) * 100;
			  tval   := 1;
			end;
		      with py do
			begin
			  misc.bth    := trunc(((stat.c[sr]+20) div 5+misc.wt)/6.0);
			  misc.ptohit := 0;
			  misc.ptodam := trunc(misc.wt/75.0) + 1;
			end;
		      if (py_attack(y,x)) then
			do_stun(cptr,-10,2);
			{ Restore old values            }
		      equipment[Equipment_primary] := inven_temp^.data;
		      py.misc.ptohit := old_ptohit;
		      py.misc.ptodam := old_ptodam;
		      py.misc.bth    := old_bth;
		      if (randint(300) > py.stat.c[dx]) then
			begin
			  msg_print('You are off-balance.');
			  py.flags.paralysis := randint(3);
			end;
		    end;
		end
	      else if (tptr > 0) then
		with t_list[tptr] do
		  if (tval = Closed_door) then
		    begin
		      with py do
			if (test_hit(misc.wt+(stat.c[sr]*stat.c[sr]) div 500,0,0,abs(p1)+150)) then
			  begin
			    msg_print('You smash into the door! ' +
				'The door crashes open!');
			    t_list[tptr] := door_list[1];
			    p1 := 1;
			    fopen := true;
			    lite_spot(y,x);
			  end
			else
			  begin
			    msg_print('You smash into the door! ' +
				'The door holds firm.');
			    py.flags.paralysis := 2;
			  end;
		    end
		  else if (tval = chest) then
		    begin
		      if (randint(10) = 1) then
			begin
			  msg_print('You have destroyed the chest...');
			  msg_print('and its contents!');
			  name := '& ruined chest';
			  flags := 0;
			end
		      else if (uand(%X'00000001',flags) <> 0) then
			if (randint(10) = 1) then
			  begin
			    msg_print('The lock breaks open!');
			    flags := uand(%X'FFFFFFFE',flags);
			  end;
		    end
		  else
		    msg_print('I do not see anything you can bash there.')
	      else
		msg_print('I do not see anything you can bash there.');
	  end;
      end;


	{ Jam a closed door					-RAK-	}
    procedure jamdoor;
      var
		i1		: treas_ptr;
		y,x,tmp         : integer;
		m_name		: vtype ;
      begin
	y := char_row;
	x := char_col;
	if (get_dir('Which direction?',tmp,tmp,y,x)) then
	  begin
	    with cave[y,x] do
	      if (tptr > 0) then
		with t_list[tptr] do
		  if (tval = Closed_door) then
		    if (cptr = 0) then
		      begin
			if (find_range([spike],false,i1,i2)) then
			  begin
			    msg_print('You jam the door with a spike.');
			    with i1^.data do
			      if (number > 1) then
				number := number - 1
			      else
				inven_destroy(i1);
			    prt_weight ;
			    p1 := -abs(p1) - 20;
			  end
			else
			  msg_print('But you have no spikes...');
		      end
		    else
		      begin
			find_monster_name ( m_name, cptr, true ) ;
		        msg_print( m_name + ' is in your way!' ) ;
		      end
		  else if (tval = Open_door) then
		    msg_print('The door must be closed first.')
		  else
		    msg_print('That isn''t a door!')
	      else
		msg_print('That isn''t a door!');
	  end;
      end;


	{ Refill the players lamp				-RAK-	}
    procedure refill_lamp;
      var
	i2,i3				: integer;
	i1				: treas_ptr;
	out_val                         : vtype;
      begin
	i3 := equipment[Equipment_light].subval;
	if ((i3 > 0) and (i3 < 10)) then
	  if (find_range([flask_of_oil],false,i1,i2)) then
	    begin
	      msg_print('Your lamp is full.');
	      with equipment[Equipment_light] do
		begin
		  p1 := p1 + i1^.data.p1;
		  if (p1 > obj$lamp_max) then p1 := obj$lamp_max;
		end;
	      desc_remain(i1);
	      inven_destroy(i1);
	      prt_weight ;
	    end
	  else
	    msg_print('You have no oil.')
	else
	  msg_print('But you are not using a lamp.');
      end;

	{ Check for message from AST message trapper	-DMF-	}
    procedure dump_ast_mess;
      var
	cur		: integer;
	str1,str2	: string;
	ptr,ptr2	: message_ptr;
	messagestr      : string;
      begin
	if caught_count > 0 then
	begin
	  if (caught_count > 1) then
	    msg_print('You hear some messages from a distant location...')
	  else
	    msg_print('You hear a message from a distant location...');
	  while (caught_message <> nil) do
	    begin
	      messagestr := caught_message^.data;
	      for cur := 0 to 31 do
		while (index(messagestr,chr(cur)) <> 0) do
		  begin
		    writev(str1,'^',chr(cur + 64));
		    writev(str2,chr(cur));
		    insert_str(messagestr,str2,str1);
		  end;
	      while (length(messagestr) > 71) do
		begin
		    tmp_str := substr(messagestr,1,71);
		    messagestr := substr(messagestr,72,length(messagestr)-71);
		      msg_print(tmp_str);
		end;
	      msg_print(messagestr);
	      caught_count := caught_count - 1;
	      message_cursor := caught_message;
	      caught_message := caught_message^.next;
	      if (old_message = nil) then
		begin
		  old_message := message_cursor;
		  old_message^.next := nil;
		  old_mess_count := 1;
		end
	      else
		begin
		  message_cursor^.next := old_message;
		  old_message := message_cursor;
		  old_mess_count := old_mess_count + 1;
		  if (old_mess_count > max_mess_keep) then
		    begin
		      ptr := old_message;
		      while (ptr^.next^.next <> nil) do
			ptr := ptr^.next;
		      ptr2 := ptr^.next;
		      dispose(ptr2);
		      ptr^.next := nil;
		      old_mess_count := old_mess_count - 1;
		    end;
		end;
	    end;
	end;
      end;

    procedure view_old_mess;
      var
	done	: boolean;
	ptr	: message_ptr;
	cur	: integer;
	out_mess: string;
      begin
	ptr := old_message;
	done := false;
	while (ptr <> nil) and (not(done)) do
	  begin
	    out_mess := ptr^.data;
	    if length(out_mess) > 71 then
	      begin
		while (length(out_mess) > 71) do
		  begin
		    tmp_str := substr(out_mess,1,71);
		    out_mess := substr(out_mess,72,length(out_mess)-71);
		    done := msg_print(tmp_str);
		  end;
	      end;
	    done := msg_print(out_mess);
	    ptr := ptr^.next;
	  end;
      end;

	{ Using objects                         }
	%INCLUDE 'SCROLLS.INC'
	%INCLUDE 'POTIONS.INC'
	%INCLUDE 'EAT.INC'
	%INCLUDE 'WANDS.INC'
	%INCLUDE 'STAFFS.INC'
	%INCLUDE 'BLOW.INC'
	{ Spell casting                         }
	%INCLUDE 'MAGIC.INC'
	%INCLUDE 'PRAYER.INC'
	%INCLUDE 'PLAY.INC'
	%INCLUDE 'SING.INC'
	%INCLUDE 'MONK.INC'

      procedure bother(num : integer);
	begin
	  if (num > 5) then
	    msg_print('Your sword screams insults at passing monsters!')
	  else
	    begin
	      msg_print('Your sword loudly shouts to all nearby creatures,');
		case num of
1 : msg_print('What kinda monsters are you, mice -- or giant mice???');
2 : msg_print('You pathetic creatures are not worth tarnishing my blade!');
3 : msg_print('Attention all monsters:  SUPPERTIME!!!');
4 : msg_print('Boy are we wounded!! Sure hope we don''t run into a kobold!');
5 : msg_print('Now where did I misplace my armor?  Hmmm...');
		end;
	    end;
	  if (aggravate_monster(20)) then
	    msg_print('You hear the sounds of movement in the distance!');
	  msg_print(' ');
	end;

    function water_move_item(row,col,num : integer) : boolean;
      begin
	water_move_item := true;
      end;

    procedure water_move_player;
      begin
      end;

    function water_move_creature(num : integer) : boolean;
      begin
	water_move_creature := true;
      end;

    procedure water_move;
      var
		i1,i2		: integer;
		flag		: boolean;
      begin
{	for i1 := 1 to max_height do
	  for i2 := 1 to max_width do
	    cave[i1,i2].moved := false;
	for i1 := 1 to max_height do
	  for i2 := 1 to max_width do
	    begin
	      if (cave[i1,i2].tptr > 0) and
		 (t_list[cave[i1,i2].tptr].tval < unseen_trap) then
		begin
		  flag := water_move_item(i1,i2,cave[i1,i2].tptr);
		end;
	    end;
}	water_move_player;
	i1 := muptr;
	while (i1 <> 0) do
	  begin
	    m_list[i1].moved := false;
	    i1 := m_list[i1].nptr;
	  end;
	i1 := muptr;
	while (i1 <> 0) do
	  begin
	    flag := water_move_creature(i1);
	    i1 := m_list[i1].nptr;
	  end;
      end;


	{ Main procedure for dungeon... 			-RAK-	}
	{ Note: There is a lot of prelinimary magic going on here at first}
    begin
      s1 := '';
      s2 := '';
      s3 := '';
      s4 := '';
      cur_inven := inventory_list;
      i_summ_count := 0;
	{ Check light status for setup          }
      with equipment[Equipment_light] do
	if (p1 > 0) then
	  player_light := true
	else
	  player_light := false;
	{ Check for a maximum level             }
      with py.misc do
	if (dun_level > max_lev) then max_lev := dun_level;
	{ Set up the character co-ords          }
      if ((char_row = -1) or (char_col = -1)) then
	repeat
	  char_row := randint(cur_height);
	  char_col := randint(cur_width);
	until (cave[char_row,char_col].fopen)		and
	      (cave[char_row,char_col].cptr = 0)	and
	      (cave[char_row,char_col].tptr = 0)	and
	      (not(cave[char_row,char_col].fval in water_set));
	{ Reset flags and initialize variables  }
      moria_flag    := false;
      cave_flag     := false;
      find_flag     := false;
      search_flag   := false;
      teleport_flag := false;
      mon_tot_mult  := 0;
      cave[char_row,char_col].cptr := 1;
      old_chp   := trunc(py.misc.chp);
      old_cmana := trunc(py.misc.cmana);
	{ Light up the area around character    }
      move_char(5);
	{ Light, but do not move critters       }
      creatures(false);
	{ Print the depth                       }
      prt_depth;

	{ Loop until dead, or new level 		}
      repeat

	{ Check for the AST's			-DMF-	}
	if (want_trap) then dump_ast_mess;

	{ Increment turn counter			}
	turn := turn + 1;
	if (py.flags.speed > 0) or
	    ((turn mod (abs(py.flags.speed) + 1)) = 0) then
	  begin
	    water_move;
	    adv_time(true);	{ Increment game time }
	  end;
	{ Sunrise and Sunset			  -KRC-	}
	with py.misc.cur_age do
	  if (dun_level = 0) then
	    if ((hour = 6) and (secs = 0)) then
	      begin
	        for i1 := 1 to cur_height do
		  for i2 := 1 to cur_width do
		    cave[i1,i2].pl := true;
		store_maint;
		draw_cave;
	      end
	    else if ((hour = 18) and (secs = 0)) then
	      begin
	        for i1 := 1 to cur_height do
		  for i2 := 1 to cur_width do
		    if (cave[i1,i2].fval <> dopen_floor.ftval) then
		      cave[i1,i2].pl := true
		    else
		      cave[i1,i2].pl := false;
		store_maint;
		draw_cave;
	      end;
	{ Check for kickout				}
	check_kickout_time(turn,10);
	{ Check for game hours                          }
	if (not(wizard1)) then
	  if ((turn mod 100) = 1) then
	    if not(check_time) then
	      if (closing_flag > 2) then
		begin
		  if (search_flag) then
		    search_off;
		  if (py.flags.rest > 0) then
		    rest_off;
		  find_flag := false;
		  msg_print('The gates to Moria are now closed.');
		  msg_print('');
		  repeat
		    py.flags.dead := false;
		    save_char(true);
		  until(false);
		end
	      else
		begin
		  if (search_flag) then
		    search_off;
		  if (py.flags.rest > 0) then
		    rest_off;
		  move_char(5);
		  closing_flag := closing_flag + 1;
		  msg_print('The gates to Moria are closing...');
		  msg_print('Please finish up or save your game.');
		  msg_print('');
		end;

	{ Check for creature generation 		}
	if (randint(max_malloc_chance) = 1) then
	  alloc_land_monster(floor_set,1,max_sight,false,false);
	{ Screen may need updating, used mostly for stats}
	if (print_stat > 0) then
	  begin
	    if (uand(%X'0001',print_stat) <> 0) then
	      prt_a_stat(sr);
	    if (uand(%X'0002',print_stat) <> 0) then
	      prt_a_stat(dx);
	    if (uand(%X'0004',print_stat) <> 0) then
	      prt_a_stat(cn);
	    if (uand(%X'0008',print_stat) <> 0) then
	      prt_a_stat(iq);
	    if (uand(%X'0010',print_stat) <> 0) then
	      prt_a_stat(ws);
	    if (uand(%X'0020',print_stat) <> 0) then
	      prt_a_stat(ca);
	    if (uand(%X'0040',print_stat) <> 0) then
	      prt_pac;
	    if (uand(%X'0100',print_stat) <> 0) then
	      prt_hp;
	    if (uand(%X'0200',print_stat) <> 0) then
	      prt_title;
	    if (uand(%X'0400',print_stat) <> 0) then
	      prt_level;
	  end;
	{ Check light status                            }
	with equipment[Equipment_light] do
	  if (player_light) then
	    if (p1 > 0) then
	      begin
		p1 := p1 - 1;
		if (p1 = 0) then
		  begin
		    msg_print('Your light has gone out!');
		    player_light := false;
		    find_flag := false;
		    move_light(char_row,char_col,char_row,char_col);
		  end
		else if (p1 < 40) then
		  if (randint(5) = 1) then
		    begin
		      if (find_flag) then
			begin
			  find_flag := false;
			  move_light(char_row,char_col,char_row,char_col);
			end;
		      msg_print('Your light is growing faint.');
		    end;
	      end
	    else
	      begin
		player_light := false;
		find_flag := false;
		move_light(char_row,char_col,char_row,char_col);
	      end
	  else if (p1 > 0) then
	    begin
	      p1 := p1 - 1;
	      player_light := true;
	      move_light(char_row,char_col,char_row,char_col);
	    end;

	{ Update counters and messages			}
	with py.flags do
	  begin
		{ Check food status             }
	    regen_amount := player$regen_normal;
	    if ((hunger_item) and (food > (player_food_alert + 15))) then 
	       food := player_food_alert + 15;
   	    if (food < player_food_alert) then
	      begin
		if (food < player_food_weak) then
		  begin
		    if (food < 0) then
		      regen_amount := 0
		    else if (food < player_food_faint) then
		      regen_amount := player$regen_faint
		    else if (food < player_food_weak) then
		      regen_amount := player$regen_weak;
		    if (uand(%X'00000002',status) = 0) then
		      begin
			status := uor(%X'00000003',status);
			msg_print('You are getting weak from hunger.');
			if (find_flag) then
			  move_char(5);
			prt_hunger;
			py.misc.wt := py.misc.wt - trunc(py.misc.wt*0.015);
			msg_print ( 'Your clothes seem to be getting loose.' ) ;
			if py.misc.wt < min_allowable_weight then
			  begin
			    msg_print ( 'Oh no...  Now you''ve done it.' ) ;
			    death := true ;
			    moria_flag := true ;
			    total_winner := false ;
			    died_from := 'starvation.'
			  end ;	
		      end;
		    if (food < 0) then
		      if (randint(5) = 1) then
			begin
			  paralysis := paralysis + randint(3);
			  msg_print('You faint from the lack of food.');
			  if (find_flag) then
			    move_char(5);
			end
		    else if (food < player_food_faint) then
		      if (randint(8) = 1) then
			begin
			  paralysis := paralysis + randint(5);
			  msg_print('You faint from the lack of food.');
			  if (find_flag) then
			    move_char(5);
			end;
		  end
		else
		  begin
		    if (uand(%X'00000001',status) = 0) then
		      begin
			status := uor(%X'00000001',status);
			msg_print('You are getting hungry.');
			if (find_flag) then
			  move_char(5);
			prt_hunger;
		      end;
		  end;
	      end;
	{ Food consumtion       }
	{ Note: Speeded up characters really burn up the food!  }
	    if (speed < 0) then
	      food := food - (speed*speed) - food_digested
	    else
	      food := food - food_digested;
	{ Regenerate            }
	    with py.misc do
	      begin
		if (regenerate) then regen_amount := regen_amount*1.5;
		if (rest > 0)   then regen_amount := regen_amount*2;
		if (py.flags.poisoned < 1) then
		  if (chp < mhp) then
		    regenhp(regen_amount);
		if (cmana < mana) then
		    regenmana(regen_amount);
	      end;
	{ Blindness             }
	    if (blind > 0) then
	      begin
		if (uand(%X'00000004',status) = 0) then
		  begin
		    status := uor(%X'00000004',status);
		    prt_map;
		    prt_blind;
		    if (search_flag) then
		      search_off;
		  end;
		blind := blind - 1;
		if (blind = 0) then
		  begin
		    status := uand(%X'FFFFFFFB',status);
		    prt_blind;
		    prt_map;
		    msg_print('The veil of darkness lifts.');
		    if (find_flag) then
		      move_char(5);
		  end;
	      end;
	{ Confusion             }
	    if (confused > 0) then
	      begin
		if (uand(%X'00000008',status) = 0) then
		  begin
		    status := uor(%X'00000008',status);
		    prt_confused;
		  end;
		confused := confused - 1;
		if (confused = 0) then
		  begin
		    status := uand(%X'FFFFFFF7',status);
		    prt_confused;
		    msg_print('You feel less confused now.');
		    if (find_flag) then
		      move_char(5);
		  end;
	      end;
{ Resist Lightning }
        If (resist_lght > 0) then resist_lght := resist_lght - 1;
{ Protection from Monsters }
        If (protmon > 0) then protmon := protmon - 1;
{ Ring of Fire }
        If (ring_fire > 0) then
          begin
            msg_print('Flames arise!');
            explode(c_fire,char_row,char_col,20+randint(20),'Ring of Fire');
            ring_fire := ring_fire - 1;
          end;
{ Ring of Frost }
	if (ring_ice > 0) then
	  begin
	    explode(c_cold,char_row,char_col,10+randint(20),'Ring of Frost');
	    ring_ice := ring_ice - 1;
	  end;
{ Blade Barrier }
	if (blade_ring > 0) then
	  begin
	    explode(c_null,char_row,char_col,12+randint(py.misc.lev)
		,'Blade Barrier');
	    blade_ring := blade_ring - 1;
	  end;
{ Magic protection }
  If (magic_prot > 0) then
    begin
      if (uand(%X'40000000',status) = 0) then
        begin
          status := uor(%X'40000000',status);
          py.misc.save := py.misc.save + 25;
        end;
      magic_prot := magic_prot - 1;
      if (magic_prot = 0) then
       begin
	 py.misc.save := py.misc.save - 25;
	 status := uand(%X'BFFFFFFF',status);
       end;
    end;
{Timed resist Petrification}
  if (resist_petri > 0) then
    resist_petri := resist_petri - 1;
        { Timed Stealth    }
            if (temp_stealth > 0) then
              begin
                if (uand(%X'20000000',status) = 0) then
                  begin
                    status := uor(%X'20000000',status);
                    py.misc.stl := py.misc.stl + 3;
                  end;
                temp_stealth := temp_stealth - 1;
                if (temp_stealth = 0) then
                  begin
                    status := uand(%X'DFFFFFFF',status);
                    py.misc.stl := py.misc.stl - 3;
                    msg_print('The monsters can once again detect you with ease.')
                  end;
              end;
 { Resist Charm }
        If (free_time > 0) then
          begin
            If (uand(%X'00800000',status)=0) then
              begin
                status := uor(%X'00800000',status);
                free_time := free_time - 1;
                If (free_time = 0) then
                  begin
                    status := uand(%X'FF7FFFFF',status);
                    If (find_flag) then
		      move_char(5);
                  end;
              end;
            end;
	{ Hoarse		}
	    if (hoarse > 0) then
	      begin
	        hoarse := hoarse - 1;
		if (hoarse = 0) then
		  msg_print('You feel your voice returning.');
	      end;
	{ Afraid                }
	    if (afraid > 0) then
	      begin
		if (uand(%X'00000010',status) = 0) then
		  begin
		    if ((shero+hero) > 0) then
		      afraid := 0
		    else
		      begin
			status := uor(%X'00000010',status);
			prt_afraid;
		      end;
		  end
		else if ((shero+hero) > 0) then
		  afraid := 1;
		afraid := afraid - 1;
		if (afraid = 0) then
		  begin
		    status := uand(%X'FFFFFFEF',status);
		    prt_afraid;
		    msg_print('You feel bolder now.');
		    if (find_flag) then
		      move_char(5);
		  end;
	      end;
	{ Poisoned              }
	    if (poisoned > 0) then
	      begin
		if (uand(%X'00000020',status) = 0) then
		  begin
		    status := uor(%X'00000020',status);
		    prt_poisoned;
		  end;
		poisoned := poisoned - 1;
		if (poisoned = 0) then
		  begin
		    status := uand(%X'FFFFFFDF',status);
		    prt_poisoned;
		    msg_print('You feel better.');
		    if (find_flag) then
		      move_char(5);
		  end
		else
		  begin
		    case con_adj of
			-4      : take_hit(4,'poison.');
			-3,-2   : take_hit(3,'poison.');
			-1      : take_hit(2,'poison.');
			0       : take_hit(1,'poison.');
			1,2,3   : if ((turn mod 2) = 0) then
				    take_hit(1,'poison.');
			4,5     : if ((turn mod 3) = 0) then
				    take_hit(1,'poison.');
			6       : if ((turn mod 4) = 0) then
				    take_hit(1,'poison.');
		    end;
		  end;
	      end;
	{ Fast                  }
	    if (fast > 0) then
	      begin
		if (uand(%X'00000040',status) = 0) then
		  begin
		    status := uor(%X'00000040',status);
		    msg_print('You feel yourself moving faster.');
		    change_speed(-1);
		    if (find_flag) then
		      move_char(5);
		  end;
		fast := fast - 1;
		if (fast = 0) then
		  begin
		    status := uand(%X'FFFFFFBF',status);
		    msg_print('You feel yourself slow down.');
		    change_speed(+1);
		    if (find_flag) then
		      move_char(5);
		  end;
	      end;
	{ Slow                  }
	    if (slow > 0) then
	      begin
		if (uand(%X'00000080',status) = 0) then
		  begin
		    status := uor(%X'00000080',status);
		    msg_print('You feel yourself moving slower.');
		    change_speed(+1);
		    if (find_flag) then
		      move_char(5);
		  end;
		slow := slow - 1;
		if (slow = 0) then
		  begin
		    status := uand(%X'FFFFFF7F',status);
		    msg_print('You feel yourself speed up.');
		    change_speed(-1);
		    if (find_flag) then
		      move_char(5);
		  end;
	      end;
	{ Resting is over?      }
	    if (rest > 0) then
	      begin
		  { Hibernate every 20 iterations so that process does  }
		  { not eat up system...                                }
		  { NOTE: Remove comments for VMS version 4.0 or greater}
		  {       INKEY_DELAY takes care of hibernation for     }
		  {       VMS 3.7 or less                               }
		if ((rest mod 20) = 1) then
		  begin
		    sleep(1);
    if (uand(equipment[equipment_primary].flags2,soul_sword_worn_bit) <> 0)
		    then
		      begin
		        bother(randint(10));
		        rest := 1
		      end;
		  end;
		rest := rest - 1;
		  { Test for any key being hit to abort rest.  Also,    }
		  { this will do a PUT_QIO which updates the screen...  }
		  { One more side benifit; since inkey_delay hibernates }
		  { small amount before executing, this makes resting   }
		  { less CPU intensive...                               }
		inkey_delay(command,0);
		if (want_trap) then dump_ast_mess;
		if (rest = 0) then              { Resting over          }
		  rest_off
		else if (command <> null) then  { Resting aborted       }
		  rest_off
	      end;
	{ Hallucinating?  (Random characters appear!)}
	    if (image > 0) then
	      begin
		image := image - 1;
		if (image = 0) then
		  draw_cave;
	      end;
{	if (speed > 0) and (paral_init = speed_paral) then
	  paralysis := paralysis + paral_init + 1;
}	{ Paralysis             }
	    if (paralysis > 0) then
	      begin
		paralysis := paralysis - 1;
		if (rest > 0) then
		  rest_off;
		if (search_flag) and (paralysis > paral_init) then
		  search_off;
	      end;
	{	if (speed > 0) and (speed_flag) then
		  begin
		    speed_flag := false;
		    speed_paral := paral_init;
		  end
		else if (speed_paral > 1) then
		  speed_paral := speed_paral - 1
		else
		  begin
		    speed_paral := 0;
		    speed_flag := true;
		  end;}
	{ Protection from evil counter}
	    if (protevil > 0) then protevil := protevil - 1;
	{ Inulnerability        }
	    if (invuln > 0) then
	      begin
		if (uand(%X'00001000',status) = 0) then
		  begin
		    status := uor(%X'00001000',status);
		    if (find_flag) then
		      move_char(5);
		    msg_print('Your skin turns into steel!');
		    py.misc.pac := py.misc.pac + 100;
		    py.misc.dis_ac := py.misc.dis_ac + 100;
		    prt_pac;
		  end;
		invuln := invuln - 1;
		if (invuln = 0) then
		  begin
		    status := uand(%X'FFFFEFFF',status);
		    if (find_flag) then
		      move_char(5);
		    msg_print('Your skin returns to normal...');
		    py.misc.pac := py.misc.pac - 100;
		    py.misc.dis_ac := py.misc.dis_ac - 100;
		    prt_pac;
		  end;
	      end;
	{ Heroism       }
	    if (hero > 0) then
	      begin
		if (uand(%X'00002000',status) = 0) then
		  begin
		    status := uor(%X'00002000',status);
		    if (find_flag) then
		      move_char(5);
		    with py.misc do
		      begin
			mhp := mhp + 10;
			chp := chp + 10;
			bth := bth + 12;
			bthb:= bthb+ 12;
		      end;
		    msg_print('You feel like a HERO!');
		    prt_hp;
		  end;
		hero := hero - 1;
		if (hero = 0) then
		  begin
		    status := uand(%X'FFFFDFFF',status);
		    if (find_flag) then
		      move_char(5);
		    with py.misc do
		      begin
			mhp := mhp - 10;
			if (chp > mhp) then chp := mhp;
			bth := bth - 12;
			bthb:= bthb- 12;
		      end;
		    msg_print('The heroism wears off.');
		    prt_hp;
		  end;
	      end;
	{ Super Heroism }
	    if (shero > 0) then
	      begin
		if (uand(%X'00004000',status) = 0) then
		  begin
		    status := uor(%X'00004000',status);
		    if (find_flag) then
		      move_char(5);
		    with py.misc do
		      begin
			mhp := mhp + 20;
			chp := chp + 20;
			bth := bth + 24;
			bthb:= bthb+ 24;
		      end;
		    msg_print('You feel like a SUPER HERO!');
		    prt_hp;
		  end;
		shero := shero - 1;
		if (shero = 0) then
		  begin
		    status := uand(%X'FFFFBFFF',status);
		    if (find_flag) then
		      move_char(5);
		    with py.misc do
		      begin
			mhp := mhp - 20;
			if (chp > mhp) then chp := mhp;
			bth := bth - 24;
			bthb:= bthb- 24;
		      end;
		    msg_print('The super heroism wears off.');
		    prt_hp;
		  end;
	      end;
	{ Blessed       }
	    if (blessed > 0) then
	      begin
		if (uand(%X'00008000',status) = 0) then
		  begin
		    status := uor(%X'00008000',status);
		    if (find_flag) then
		      move_char(5);
		    with py.misc do
		      begin
			bth := bth + 5;
			bthb:= bthb+ 5;
			pac := pac + 5;
			dis_ac := dis_ac + 5;
		      end;
		    msg_print('You feel righteous!');
		    prt_hp;
		    prt_pac;
		  end;
		blessed := blessed - 1;
		if (blessed = 0) then
		  begin
		    status := uand(%X'FFFF7FFF',status);
		    if (find_flag) then
		      move_char(5);
		    with py.misc do
		      begin
			bth := bth - 5;
			bthb:= bthb- 5;
			pac := pac - 5;
			dis_ac := dis_ac - 5;
		      end;
		    msg_print('The prayer has expired.');
		    prt_hp;
		    prt_pac;
		  end;
	      end;
	{ Resist Heat   }
	    if (resist_heat > 0) then resist_heat := resist_heat - 1;
	{ Resist Cold   }
	    if (resist_cold > 0) then resist_cold := resist_cold - 1;
	{ Detect Invisible      }
	    if (detect_inv > 0) then
	      begin
		if (uand(%X'00010000',status) = 0) then
		  begin
		    status := uor(%X'00010000',status);
		    see_inv := true;
		  end;
		detect_inv := detect_inv - 1;
		if (detect_inv = 0) then
		  begin
		    status := uand(%X'FFFEFFFF',status);
		    see_inv := false;
		    py_bonuses(blank_treasure,0);
		  end;
	      end;
	{ Timed infra-vision    }
	    if (tim_infra > 0) then
	      begin
		if (uand(%X'00020000',status) = 0) then
		  begin
		    status := uor(%X'00020000',status);
		    see_infra := see_infra + 1;
		  end;
		tim_infra := tim_infra - 1;
		if (tim_infra = 0) then
		  begin
		    status := uand(%X'FFFDFFFF',status);
		    see_infra := see_infra - 1;
		    msg_print('Your eyes stop tingling.');
		  end;
	      end;
	{ Word-of-Recall  Note: Word-of-Recall is a delayed action      }
	    if (word_recall > 0) then
	      if (word_recall = 1) then
		begin
		  if (dun_level > 0) then
		    begin
		      msg_print('You feel yourself yanked upwards!');
		      dun_level := 0;
		    end
		  else if (py.misc.max_lev > 0) then
		    begin
		      msg_print('You feel yourself yanked downwards!');
		      dun_level := py.misc.max_lev;
		    end;
		  moria_flag := true;
		  paralysis := paralysis + 1;
		  word_recall := 0;
		end
	      else
		word_recall := word_recall - 1;

	{ Check hit points for adjusting...			}
	      with py.misc do
		if (not(find_flag)) then
		  if (py.flags.rest < 1) then
		    begin
		      if (old_chp <> trunc(chp)) then
			begin
			  if (chp > mhp) then chp := mhp;
			  prt_hp;
			  old_chp := trunc(chp);
			end;
		      if (old_cmana <> trunc(cmana)) then
			begin
			  if (cmana > mana) then cmana := mana;
			  if (is_magii) then prt_mana;
			  old_cmana := trunc(cmana);
			end
		    end;
	  end;
	if ((py.flags.paralysis < 1) and        { Accept a command?     }
	    (py.flags.rest < 1) and
	    (not(death))) then
	{ Accept a command and execute it                               }
	  repeat
	    print_stat := 0;
	    reset_flag := false;
	    turn_counter := turn_counter + 1;
	    if (turn_counter > 4000000) then turn_counter := 100000;
		{ Random teleportation  }
	    if (py.flags.teleport) then
	      if (randint(100) = 1) then
		begin
		  find_flag := false;
		  teleport(40);
		end;
	    if (not (find_flag)) then
	      begin
		print('',char_row,char_col);
		save_msg_flag := msg_flag;
		inkey(command);
		if (save_msg_flag) then erase_line(msg_line,msg_line);
		com_val := ord(command);
	      end;
	{ Commands are executed in following case statement             }
	{ The following keys are used for commands:			}
	{ ^A ^B ^C ^D ^E ^F ^G ^H ^I ^J ^K ^L ^M ^N ^O ^P ^R ^T ^U ^V	}
	{ ^W ^X ^Y ^Z ^_ $ + . / 1 2 3 4 5 6 7 8 9 < > ?		}
	{ A B C D E F G H I L M P R S T U V W ]				}
	{ a b c d e f h i j l m o p q r s t u v w x |			}
	  case com_val of

		0,3,25 :begin					{^Y = exit    }
			  flush;
			  if (get_com('Enter ''Q'' to quit',command)) then
			    case command of
			      'q','Q':  begin
					  if (total_winner) then
					    begin
					      moria_flag := true;
					      death      := true;
					    end
					  else
					    begin
					      if (is_from_file) then
						begin
open(f1,file_name:=finam,record_length:=1024,history:=old,
	disposition:=delete,error:=continue);
close(f1,error:=continue);
						end;
					      clear(1,1);
					      exit;
					    end;
					end;
			      otherwise ;
			    end;
			  reset_flag := true;
			end;
		13 :    begin                                   {^M = repeat  }
			  msg_print(old_msg);
			  reset_flag := true;
			end;
		16 :    if (wizard1) then                       {^P = password}
			  begin
			    msg_print('Wizard mode off.');
			    wizard1 := false;
			    wizard2 := false;
			    reset_flag := true;
			    no_controly;
			  end
			else
			  begin
			    if py.misc.cheated then
			     begin
			      if check_pswd('doublespeak',true) then
			        begin
				  msg_print('Wizard mode on.');
				  controly;
			        end
			     end
			    else
			      if check_pswd('',false) then
				begin
				  msg_print('Wizard mode on.');
				  controly;
				end;
			    reset_flag := true;
			  end;
		18 :    begin                                   {^R = redraw  }
			  draw_cave;
			  reset_flag := true;
			end;
		26 :    begin                                   {^Z = save    }
			  if (total_winner) then
			    begin
	msg_print('You are a Total Winner, your character must be retired...');
	msg_print('Use <Control>-Y to when you are ready to quit.');
			    end
			  else
			    begin
			      if (search_flag) then
				search_off;
			      py.flags.dead := false;
			      save_char(false);
			      py.flags.dead := true;
			    end;
			end;
		31 : if (wizard1 and search_flag) then
			begin
			  py.misc.cheated := false;
			  msg_print('Cheat flag turned off.');
			end
		      else reset_flag:=true;
		36 :    begin                                   {$  = Shell   }
{FXJLM -- 1-21-90  Kluged out the shell. hahahaha!!!!}
{			  clear(1,1);
	writeln('[Entering DCL shell, type "EOJ" to resume your game]');
			  writeln;
			  if (want_trap) then disable_the_trap;
			  controly;
			  shell_out;
			  no_controly;
			  if (want_trap) then set_the_trap;
			  clear(1,1);
			  draw_cave;
			  reset_flag := true;
}			end;
		43 :	begin					{+ = lvl help }
			  writev(out_val,py.misc.expfact:4:2);
			  moria_help('Character Classes Experience '+out_val);
			  draw_cave;
			  reset_flag := true;   { Free move     }
			end;
		46 :    begin                                   {. = find     }
			  y := char_row;
			  x := char_col;
			  if (get_dir('Which direction?',dir_val,
							com_val,y,x)) then
			    begin
			      find_flag := true;
			      move_char(dir_val);
			    end
			end;
		47 :    begin                                   {/ = identify }
			  ident_char;
			  reset_flag := true;
			end;
		49 :    move_char(com_val - 48);        { Move dir 1    }
		50 :    move_char(com_val - 48);        { Move dir 2    }
		51 :    move_char(com_val - 48);        { Move dir 3    }
		52 :    move_char(com_val - 48);        { Move dir 4    }
		53 :    begin                           { Rest one turn }
			  move_char(com_val - 48);
			  sleep(0);     { Sleep 1/10 a second}
			  flush;
			end;
		54 :    move_char(com_val - 48);        { Move dir 6    }
		55 :    move_char(com_val - 48);        { Move dir 7    }
		56 :    move_char(com_val - 48);        { Move dir 8    }
		57 :    move_char(com_val - 48);        { Move dir 9    }
		60 :    go_up;                                  {< = go up    }
		62 :    go_down;                                {> = go down  }
		63 :    begin                                   {? = help     }
			  help;
			  reset_flag := true;   { Free move     }
			end;
		65 :	begin				       {A = age, Hours}
			  msg_print(show_char_age);
			  msg_print('You have been playing for '+show_play_time);
			  reset_flag := true;
			end;
		66 :    bash;                                   {B = bash     }
		67 :    begin                                   {C = character}
			  if (get_com('Print to file? (Y/N)',command)) then
			    case command of
			      'y','Y':  file_character;
			      'n','N':  begin
					  change_name;
					  draw_cave;
					end;
			      otherwise ;
			    end;
			  reset_flag := true;   { Free move     }
			end;
		68 :    disarm_trap;                            {D = disarm   }
		69 :    eat;                                    {E = eat      }
		70 :    refill_lamp;                            {F = refill   }
		71 :	begin					{G = Game date}
			  msg_print('The date is '+
				  full_date_string(py.misc.cur_age));
			  reset_flag := true;
			end;
		72 :    begin					{H = moria hlp}
			  moria_help('');
			  draw_cave;
			  reset_flag := true;   { Free move     }
			end;
		73 :	begin				     {I = Selected inv}
			  reset_flag := true;
			  if (inven_command('I',trash_ptr,'')) then
			    draw_cave;
			end;
		75 :	begin				     {K = Know Quest  }
			  if (py.flags.quested) then
msg_print('Current quest is to kill a '+c_list[py.misc.cur_quest].name)
			  else
			    msg_print('No quest currently.');
			  reset_flag := true; {free turn}
			end;
		76 :    begin                                   {L = location }
			  reset_flag := true;   { Free move     }
			  if ((py.flags.blind > 0) or (no_light)) then
			    msg_print('You can''t see your map.')
			  else
			    begin
			      writev(out_val,
			      'Section [',
			      (trunc((char_row-1)/outpage_height)+1):1,',',
			      (trunc((char_col-1)/outpage_width )+1):1,
			      ']; Location = [',char_row:1,',',char_col:1,']');
			      msg_print(out_val);
			    end;
			end;
		77:	begin					{M = money    }
			  reset_flag := true;
			  if (inven_command('M',trash_ptr,'')) then
			    draw_cave;
			end;
		78:	begin
			  mon_name;				{N = name mstr}
			  reset_flag := true;
			end;
		79:	view_old_mess;			        {O = Old Mess }
		80:     begin                                   {P = print map}
			  reset_flag := true;   { Free move     }
			  if ((py.flags.blind > 0) or (no_light)) then
			    msg_print('You can''t see to draw a map.')
			  else
			    print_map;
			end;
		81 :	begin				      {Q = toggle more}
			  msg_terse := not msg_terse;
			  if (msg_terse) then
			    msg_print('Question ''-More-'' toggled off')
			  else
			    msg_print('Question ''-More-'' toggled on');
			  reset_flag := true;	{Free move    }
			end;
		82 :    rest;                                   {R = rest     }
		83 :    if (search_flag) then                   {S = srh mode }
			  begin
			    search_off;
			    reset_flag := true; { Free move     }
			  end
			else if (py.flags.blind > 0) then
		  msg_print('You are incapable of searching while blind.')
			else
			  begin
			    search_on;
			    reset_flag := true; { Free move     }
			  end;
		84 :    tunnel;                                 {T = tunnel   }
		85 :	blow;					{U = use instr}
		86 :    begin
			  msg_record('',false);		{V = preVious messages}
			  reset_flag := true;
			end;
		87 :	begin					{W = what time}
			  msg_print('The current time is '+show_current_time);
			  reset_flag := true;
			end;
		93 :	begin					{] = armr help}
			  moria_help('Adventuring Armor_Class Armor_List');
			  draw_cave;
			  reset_flag := true;   { Free move     }
			end;
		97 :    aim;                                    {a = aim      }
		98 :    examine_book;                           {b = browse   }
		99 :    closeobject;                            {c = close    }
		100:    drop;                                   {d = drop     }
		101:    begin                                   {e = equipment}
			  reset_flag := true;   { Free move     }
			  if (inven_command('e',trash_ptr,'')) then
			    draw_cave;
			end;

		102:	throw_object(true);			{f = fire }
		104:    throw_object(false);			{h = hurlx }
		105:    begin                                   {i = inventory}
			  reset_flag := true;   { Free move     }
			  if (inven_command('i',trash_ptr,'')) then
			    draw_cave;
			end;
		106:    jamdoor;                                {j = jam      }
		108:    begin                                   {l = look     }
			  look;
			  reset_flag := true;   { Free move     }
			end;
		109:    if (class[py.misc.pclass].mspell) then
			  cast                                  {m = magick   }
			else if (class[py.misc.pclass].mental) then
			  discipline				{m = monk? :) }
			else
			  sing;					{m = music    }
		111:    openobject;                             {o = open     }
		112:    if (class[py.misc.pclass].pspell) then
			  pray					{p = pray     }
			else
			  play;					{p = play     }
		113:    quaff;                                  {q = quaff    }
		114:    read_scroll;                            {r = read     }
		115:    if (py.flags.blind > 0) then            {s = search   }
		  msg_print('You are incapable of searching while blind.')
			else
			  search(char_row,char_col,py.misc.srh);
		116:    begin                                   {t = unwear   }
			  reset_flag := true;
			  if (inven_command('t',trash_ptr,'')) then
			     draw_cave
			  else
			     prt_weight;
			end;
		117:    use;                                    {u = use staff}
		118:    game_version;                           {v = version  }
		119:    begin                                   {w = wear     }
			  reset_flag := true;
			  if (inven_command('w',trash_ptr,'')) then
			     draw_cave
			  else
			     prt_weight;
			end;
		120:    begin                                   {x = exchange }
			  reset_flag := true;
			  if (inven_command('x',trash_ptr,'')) then
			    draw_cave;
			end;
		124:	begin					{| = wpn help }
			  moria_help('Adventuring Weapons Weapon_List');
			  draw_cave;
			  reset_flag := true;   { Free move     }
			end;
		otherwise  if (wizard1) then
		  begin
		    reset_flag := true; { Wizard commands are free moves}
	      case com_val of
		1  :    with py.flags do		{^A = Cure all}
			 begin
			  hp_player(1000,'cheating');
			  remove_curse;
			  cure_me(blind); cure_me(hoarse); cure_me(afraid);
			  cure_me(poisoned); cure_me(confused);
			  for tstat := sr to ca do
			    restore_stat(tstat,'');
			  if (slow > 1) then
			    slow := 1;
			  if (image > 1) then
			    image := 1;
			 end;
		2  :    print_objects;                          {^B = objects }
		4  :    begin                                   {^D = up/down }
			  prt('Go to which level (0 -1200) ? ',1,1);
			  if (get_string(tmp_str,1,31,10)) then
			    begin
			      i1 := -1;
			      readv(tmp_str,i1,error:=continue);
			      if (i1 > -1) then
			        begin
			          dun_level := i1;
			          if (dun_level > 1200) then
				    dun_level := 1200;
			          moria_flag := true;
			        end
			      else
			        erase_line(msg_line,msg_line);
			    end
			  else
			    erase_line(msg_line,msg_line);
			end;
		8  :    wizard_help;				{^H = wizhelp }
		9  :    begin					{^I = identify}
			  msg_print('Poof!  Your items are all identifed!!!');
			  trash_ptr := inventory_list;
			  while (trash_ptr <> nil) do
			    begin
				identify(trash_ptr^.data);
				known2(trash_ptr^.data.name);
				trash_ptr := trash_ptr^.next;
			    end;
			end;
		12 :    wizard_light;				{^L = wizlight}
		14 :    print_monsters;				{^N = mon map }
		20 :    teleport(100);				{^T = teleport}
		22 :    restore_char('',false,false);		{^V = restore }
		otherwise if (wizard2) then
	      case com_val of
		5  :    change_character;			{^E = wizchar }
		6  :    mass_genocide;				{^F = genocide}
		7  :    begin					{^G = treasure}
			  alloc_object(floor_set,5,25);
			  prt_map;
			end;
		10 :    begin                                   {^J = gain exp}
			  if py.misc.exp = 0
                            then
                              py.misc.exp := 1
                            else
                              py.misc.exp := py.misc.exp * 2;
			  prt_experience;
			end;
		11 :    begin                                   {^K = summon  }
			  y := char_row;
			  x := char_col;
			  if (cave[y,x].fval in water_set) then
			    summon_water_monster(y,x,true)
			  else
			    summon_land_monster(y,x,true);
			  creatures(false);
			end;
		15 :    begin					{^O = summon  }
			  monster_summon_by_name(char_row,char_col,'',false,true);
			  creatures(false);
			end;
		21 :	summon_item(char_row,char_col,'','',0,false);
								{^U = summon  }
		23 :    wizard_create;                          {^W = create  }
		24 :	edit_score_file;			{^X = ed score}
		otherwise  prt('Type ''?'' for help...',1,1);
	      end
		else
		  prt('Type ''?'' for help...',1,1);
	      end;
		  end
			  else
				begin
				  prt('Type ''?'' for help...',1,1);
				  reset_flag := true;
				end;
	  end;
	{ End of commands                                               }
	  until (not(reset_flag) or (moria_flag));
	{ Teleport?                     }
	if (teleport_flag) then teleport(100);
	{ Move the creatures            }
	if (not moria_flag) then creatures(true);
	{ Exit when moria_flag is set   }
      until (moria_flag);
      if (search_flag) then search_off; { Fixed "SLOW" bug; 06-11-86 RAK     }
    end;

End.
