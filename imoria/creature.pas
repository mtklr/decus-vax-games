[inherit('moria.env','dungeon.env')] module creature;

[global,psect(creature$code)] procedure load_monsters;

var
  count             : integer;
  f1                : text;
  a		    : ctype;

      begin
        {load monsters from file}
        open(f1,file_name:=MORIA_MON,history:=READONLY);
        Reset(f1);
        for count := 1 to max_creatures do begin
          readln (f1, a);
          readln (f1, c_list[count].aaf);
          readln (f1, c_list[count].ac);
          readln (f1, c_list[count].name);
          readln (f1, c_list[count].cmove : HEX);
          readln (f1, c_list[count].spells : HEX);
          readln (f1, c_list[count].cdefense : HEX);
          readln (f1, c_list[count].sleep);
          readln (f1, c_list[count].mexp);
          readln (f1, c_list[count].speed);
          readln (f1, c_list[count].cchar);
          readln (f1, c_list[count].hd);
          readln (f1, c_list[count].damage);
          readln (f1, c_list[count].level);
	  readln (f1, c_list[count].mr);
        end;
        close(f1);
	open(f1,file_name:=MORIA_CST, history:=READONLY, error:=continue);
	if (status(f1) = 0) then
	reset(f1);
	begin	
	  if (not eof(f1)) then
	  begin
	    repeat
	      readln (f1,a);
	      if (length(a) > 25) then a := substr(a,1,25);
	      if (not eof(f1)) then
	      begin
	        readln (f1,count);
	        if ((count <= max_creatures) and (count > 0)) then
	        begin
		  c_list[count].name := a;
	        end;
	      end;
	    until(eof(f1));
	    close(f1);
	  end;
	end;
      end;

	{ replace <gp> for game players name }
[global,psect(creature$code)] procedure replace_name;

  var
	count		: integer;
	mark		: integer;
	t_str		: vtype;

	begin
	  for count := 1 to max_creatures do 
	    begin
	      mark := index(c_list[count].name, '<gp>');
	      if (mark <> 0) then
		begin
		  t_str := py.misc.name;
		  if (t_str = '') then t_str := 'Dead Guy';
		  if (length(t_str) > 15) then t_str := substr(t_str,1,15);
		  t_str := t_str + substr(c_list[count].name,mark+4,
			   length(c_list[count].name)-(mark+3));
		  if (mark <> 1) then
		      t_str := substr(c_list[count].name,1,mark-1) + t_str;
		  c_list[count].name := t_str;
		end;
	     end;
	 end;


{name any monster you wish [currently virtual]}
[global,psect(creature$code)] procedure mon_name;

	procedure append_mon(mon_num : integer);
	
	var
	  f1		: text;

	begin
	  open(f1,file_name:=MORIA_CST,history:=UNKNOWN,error:=continue);
	  extend(f1);
	  writeln(f1, c_list[mon_num].name);
	  writeln(f1, mon_num : 4);
	  close(f1);
	end;

var
	virtual_name		: ctype;
	mon_num			: integer;

	begin
	  prt('Monster to rename:',1,1);
	  if (get_string(virtual_name,1,20,26)) then
	  begin
	    mon_num := find_mon(virtual_name);
	    if (mon_num <> 0) then
	      begin
		prt('New name:',1,1);
		if (get_string(virtual_name,1,11,26)) then
		  c_list[mon_num].name := virtual_name;
		  append_mon(mon_num);
	      end
	    else
	      msg_print('Hmm.... can''t find a monster with that name');
	  end;
	  msg_print('');
	end;

{returns number of monster in list specified by virtual_name}
[global,psect(creature$code)] function find_mon(virtual_name : ctype): integer;
  
  var
	count		: integer;
	maybe		: boolean;

	begin
	  maybe := false;
	  for count := 1 to max_creatures do
	  begin
	  if (not maybe) then
	    begin
	      if (virtual_name = c_list[count].name) then 
	        begin
		  find_mon := count;
		  maybe := true;
	        end;
	    end;
	  end;
	  if (maybe = false) then find_mon := 0;
	end;


	{ Makes sure new creature gets lit up			-RAK-	}
  [global,psect(creature$code)] procedure check_mon_lite(y,x : integer);
    begin
      with cave[y,x] do
	if (cptr > 1) then
	  if (not(m_list[cptr].ml)) then
	    if ((tl) or (pl)) then
	      if (los(char_row,char_col,y,x)) then
		begin
		  m_list[cptr].ml := true;
		  lite_spot(y,x);
		end;
    end;


	{ Places creature adjacent to given location		-RAK-	}
	{ Rats and Flies are fun!                                       }
  [global,psect(creature$code)] procedure multiply_monster(y,x,z : integer; slp : boolean);
    var
	i1,i2,i3                : integer;

    begin
      i1 := 0;
      repeat
	i2 := y - 2 + randint(3);
	i3 := x - 2 + randint(3);
	if (in_bounds(i2,i3)) then
	  with cave[i2,i3] do
	    if (fval in floor_set) then
	      if ((tptr = 0) and (cptr <> 1)) then
		begin
		  if (cptr > 1) then    { Creature there already?       }
		    begin
			{ Some critters are canabalistic!       }
		      if (uand(c_list[z].cmove,%X'00080000') <> 0) then
			begin
			  delete_monster(cptr);
			  place_monster(i2,i3,z,slp);
			  check_mon_lite(i2,i3);
			  mon_tot_mult := mon_tot_mult + 1;
			end;
		    end
		  else
			{ All clear, place a monster    }
		    begin
		      place_monster(i2,i3,z,slp);
		      check_mon_lite(i2,i3);
		      mon_tot_mult := mon_tot_mult + 1;
		    end;
		  i1 := 18;
		end;
	i1 := i1 + 1;
      until (i1 > 18);
    end;

  [global,psect(creature$code)] procedure creatures(attack : boolean);
      var
		i1,i2,i3,moldy,moldx    : integer;
		hear_count		: integer;

      procedure update_mon(monptr : integer);
	var
		flag            : boolean;
		h_range,s_range	: integer;	
	begin
	  with m_list[monptr] do
	    with cave[fy,fx] do
	      begin
		flag := false;
		if (fval in water_set) and	{in water, not flying}
		 (uand(c_list[mptr].cmove,%X'00800000') = 0) then
		  begin
		    h_range := 10;
		    s_range := 5;
		  end
		else
		  begin
		    h_range := -1;
		    s_range := max_sight;
		  end;
		if ((py.flags.blind < 1) and panel_contains(fy,fx)) then
		  if (wizard2) then
		    flag := true
		  else if (los(char_row,char_col,fy,fx) and (cdis <= s_range)) then
		    with c_list[mptr] do
		      if ((pl) or (tl)) then	{can see creature?}
			flag := py.flags.see_inv or (uand(%X'10000',cmove)=0)
		      else if (py.flags.see_infra > 0) then	{infravision?}
			flag := (cdis <= py.flags.see_infra) and (uand(%X'2000',cdefense) <> 0);
		if (los(char_row,char_col,fy,fx) and (not flag) and
		  (cdis <= h_range)) then {noise in water?}
		      hear_count := hear_count + 1;
	{ Light it up...        }
		if (flag) then
		  begin
		    if (not(ml)) then
		      begin
			print(c_list[mptr].cchar,fy,fx);
			ml := true;
			if (search_flag) then
			  search_off;
			if (py.flags.rest > 0) then
			  rest_off;
			flush;
			if (find_flag) then
			  begin
			    find_flag := false;
			    move_char(5);
			  end;
		      end;
		  end
	{ Turn it off...        }
		else if (ml) then
		  begin
		    ml := false;
		    if ((tl) or (pl)) then
		      lite_spot(fy,fx)
		    else
		      unlite_spot(fy,fx);
		  end;
	      end;
	end;


	{ Move the critters about the dungeon			-RAK-	}
      function mon_move(monptr : integer) : boolean;
	type
		mm_type = array [1..5] of integer;
	var
		i1,i2,i3                : integer;
		mm                      : mm_type;
		out_val                 : vtype;
		move_test               : boolean;

	{ Choose correct directions for monster movement	-RAK-	}
	procedure get_moves(monptr : integer; var mm : mm_type);
	  var
		move_val,octant_side,a_cptr : integer;
	{ octant_side = +/-1 }
	  begin
	    if (m_list[monptr].csleep <> 0) then m_list[monptr].csleep := 0;
	    y := char_row - m_list[monptr].fy;
	    x := char_col - m_list[monptr].fx;
	    move_val := get_hexdecant(y,x);
	    octant_side := 2*(move_val mod 2)-1;
	    mm[1] := key_of[move_val div 2];
	    mm[2] := rotate_dir(mm[1],octant_side);
	    mm[3] := rotate_dir(mm[1],-octant_side);
	    mm[4] := rotate_dir(mm[2],octant_side);
	    mm[5] := rotate_dir(mm[3],-octant_side);
	  end;


	{ Make an attack on the player (chuckle...)		-RAK-	}
	procedure make_attack(monptr : integer);
	  var
		xpos,atype,adesc,dam    : integer;
		acount			: integer;
		i1,i2,i3,i4,i5          : integer;
		attstr,attx             : vtype;
		cdesc,mdesc,ddesc       : vtype;
		damstr                  : etype;
		flag                    : boolean;
		ident			: boolean;
		item_ptr		: treas_ptr;
	  begin
	    with m_list[monptr] do
	    with c_list[mptr] do
	      begin
		attstr := damage;
		find_monster_name( cdesc, monptr, true );
		cdesc := cdesc + ' ';
		{ For 'DIED_FROM' string        }
		if (uand(%X'80000000',cmove) <> 0) then
		  ddesc := 'The ' + name
		else
		  ddesc := '& ' + name;
		inven_temp^.data.name   := ddesc;
		inven_temp^.data.number := 1;
		objdes(ddesc,inven_temp,true);
		died_from := ddesc;
		{ End DIED_FROM                 }
		while (length(attstr) > 0) do
		  begin
		    xpos := index(attstr,'|');
		    if (xpos > 0) then
		      begin
			attx := substr(attstr,1,xpos-1);
			attstr := substr(attstr,xpos+1,length(attstr)-xpos);
		      end
		    else
		      begin
			attx := attstr;
			attstr := '';
		      end;
		    readv(attx,atype,adesc,damstr,error:=continue);
		    if (py.flags.protevil > 0) then
		      if (uand(cdefense,%X'0004') <> 0) then
			if ((py.misc.lev+1) > level) then
			  begin
			    atype := 99;
			    adesc := 99;
			  end;
		    if (py.flags.protmon > 0) then
		      if (uand(cdefense,%X'0002') <> 0) then
			if ((py.misc.lev+1) > level) then
			  begin
			    atype := 99;
			    adesc := 99;
			  end;
		    if (index(damstr,'-')) > 0 then
		      begin
			insert_str(damstr,'-',' ');
			readv(damstr,acount,damstr,error:=continue);
		      end
		    else
		      acount := 1;
		    with py.misc do
		    for i5 := 1 to acount do begin
		    case atype of
{Normal attack  }     1  : flag := test_hit(60,level,0,pac+ptoac);
{Poison Strength}     2  : flag := test_hit(-3,level,0,pac+ptoac);
{Confusion attack}    3  : flag := test_hit(10,level,0,pac+ptoac);
{Fear attack    }     4  : flag := test_hit(10,level,0,pac+ptoac);
{Fire attack    }     5  : flag := test_hit(10,level,0,pac+ptoac);
{Acid attack    }     6  : flag := test_hit(0,level,0,pac+ptoac);
{Cold attack    }     7  : flag := test_hit(10,level,0,pac+ptoac);
{Lightning attack}    8  : flag := test_hit(10,level,0,pac+ptoac);
{Corrosion attack}    9  : flag := test_hit(0,level,0,pac+ptoac);
{Blindness attack}    10 : flag := test_hit(2,level,0,pac+ptoac);
{Paralysis attack}    11 : flag := test_hit(2,level,0,pac+ptoac);
{Steal Money    }     12 : flag := test_hit(5,level,0,py.misc.lev) and
				(py.misc.money[total$] > 0);
{Steal Object   }     13 : flag := test_hit(2,level,0,py.misc.lev) and
				(inven_ctr > 0);
{Poison         }     14 : flag := test_hit(5,level,0,pac+ptoac);
{Lose dexterity}      15 : flag := test_hit(0,level,0,pac+ptoac);
{Lose constitution}   16 : flag := test_hit(0,level,0,pac+ptoac);
{Lose intelligence}   17 : flag := test_hit(2,level,0,pac+ptoac);
{Lose wisdom}         18 : flag := test_hit(0,level,0,pac+ptoac);
{Lose experience}     19 : flag := test_hit(5,level,0,pac+ptoac);
{Aggravate monsters}  20 : flag := true;
{Disenchant        }  21 : flag := test_hit(20,level,0,pac+ptoac);
{Eat food          }  22 : flag := test_hit(5,level,0,pac+ptoac);
{Eat light         }  23 : flag := test_hit(5,level,0,pac+ptoac);
{Eat charges       }  24 : flag := test_hit(15,level,0,pac+ptoac);
{Lose charisma     }  25 : flag := test_hit(2,level,0,pac+ptoac);
{Petrification     }  26 : flag := test_hit(10,level,0,pac+ptoac);
{POISON poison     }  27 : flag := test_hit(5,level,0,pac+ptoac);
		      99 :      flag := true;
		      otherwise flag := false;
		    end;
		    if (flag) then
		      begin
			case adesc of
			  1 : msg_print(cdesc + 'hits you.');
			  2 : msg_print(cdesc + 'bites you.');
			  3 : msg_print(cdesc + 'claws you.');
			  4 : msg_print(cdesc + 'stings you.');
			  5 : msg_print(cdesc + 'touches you.');
			  6 : msg_print(cdesc + 'kicks you.');
			  7 : msg_print(cdesc + 'gazes at you.');
			  8 : msg_print(cdesc + 'breathes on you.');
			  9 : msg_print(cdesc + 'spits on you.');
			 10 : msg_print(cdesc + 'makes a horrible wail.');
			 11 : msg_print(cdesc + 'embraces you.');
			 12 : msg_print(cdesc + 'crawls on you.');
			 13 : msg_print(cdesc + 'releases a cloud of spores.');
			 14 : msg_print(cdesc + 'begs you for money.');
			 15 : msg_print('You''ve been slimed!');
			 16 : msg_print(cdesc + 'crushes you.');
			 17 : msg_print(cdesc + 'tramples you.');
			 18 : msg_print(cdesc + 'drools on you.');
			 19 : case randint(9) of
				1 : msg_print(cdesc + 'insults you!');
				2 : msg_print(cdesc + 'insults your mother!');
				3 : msg_print(cdesc + 'gives you the finger!');
				4 : msg_print(cdesc + 'humiliates you!');
				5 : msg_print(cdesc + 'wets on your leg!');
				6 : msg_print(cdesc + 'defiles you!');
				7 : msg_print(cdesc + 'dances around you!');
				8 : msg_print(cdesc + 'makes obscene gestures!');
				9 : msg_print(cdesc + 'moons you!!!');
			      end;
			 23 : msg_print(cdesc + 'sings a charming song');
			 24 : msg_print(cdesc + 'kisses you');
			 25 : msg_print(cdesc + 'gores you');
			 26 : case randint(2) of
				1 : msg_print(cdesc + 'moos forlornly');
				2 : msg_print(cdesc + 'questioningly looks at you');
			      end;
			 27 : msg_print(cdesc + 'shocks you');
			 28 : msg_print(cdesc + 'squirts ink at you');
			 29 : msg_print(cdesc + 'entangles you');
			 30 : msg_print(cdesc + 'sucks your blood');
			 31 : msg_print(cdesc + 'goes for your throat!');
			 32 : msg_print(cdesc + 'blows bubbles at you');
			 33 : msg_print(cdesc + 'squawks at you');
			 34 : msg_print(cdesc + 'pecks at you');
			 35 : msg_print(cdesc + 'barks at you');
			 36 : msg_print(cdesc + 'rubs against your leg');
			 37 : msg_print(cdesc + 'follows you around');
         	         99 : msg_print(cdesc + 'is repelled.');
			  otherwise ;
			end;
			case atype of
{Normal attack  }         1  :  begin
				  dam := damroll(damstr);
				  with py.misc do
				    dam :=dam - round(((pac+ptoac)/200.0)*dam);
				  take_hit(dam,ddesc);
				  prt_hp;
				end;
{Poison Strength}         2  :  begin
				  take_hit(damroll(damstr),ddesc);
				  ident := lose_stat(sr,'You feel weaker.','You feel weaker for a moment, then it passes.');
				  prt_hp;
				end;
{Confusion attack}        3  :  with py.flags do
				  begin
				    take_hit(damroll(damstr),ddesc);
				    if (randint(2) = 1) then
				      begin
					if (confused < 1) then
					  begin
					    msg_print('You feel confused.');
					    confused:=confused+randint(level);
					  end;
					confused := confused + 3;
				      end;
				    prt_hp;
				  end;
{Fear attack    }         4  :  with py.flags do
				  begin
				    take_hit(damroll(damstr),ddesc);
				    if (player_spell_saves) then
				      msg_print('You resist the effects!')
				    else if (afraid < 1) then
				      begin
					msg_print('You are suddenly afraid!');
					afraid := afraid + 3 + randint(level);
				      end
				    else
				      afraid := afraid + 3;
				    prt_hp;
				  end;
{Fire attack    }         5  :  begin
				  msg_print('You are enveloped in flames!');
				  fire_dam(damroll(damstr),ddesc);
				end;
{Acid attack    }         6  :  begin
				  msg_print('You are covered in acid!');
				  acid_dam(damroll(damstr),ddesc);
				end;
{Cold attack    }         7  :  begin
				  msg_print('You are covered with frost!');
				  cold_dam(damroll(damstr),ddesc);
				end;
{Lightning attack}        8  :  begin
				  msg_print('Lightning strikes you!');
				  light_dam(damroll(damstr),ddesc);
				end;
{Corrosion attack}        9  :  begin
			msg_print('A stinging red gas swirls about you.');
				  corrode_gas(ddesc);
				  take_hit(damroll(damstr),ddesc);
				  prt_hp;
				end;
{Blindness attack}        10 :  with py.flags do
				  begin
				    take_hit(damroll(damstr),ddesc);
				    if (blind < 1) then
				      begin
					blind := blind + 10 + randint(level);
					msg_print('Your eyes begin to sting.');
					msg_print(' ');
				      end;
				    blind := blind + 5;
				    prt_hp;
				  end;
{Paralysis attack}        11 :  with py.flags do
				  begin
				    take_hit(damroll(damstr),ddesc);
				    if (player_spell_saves) then
				      msg_print('You resist the effects!')
				    else if (paralysis < 1) then
				      begin
					if (free_act or (free_time>0)) then
					  msg_print('You are unaffected.')
					else
					  begin
					    paralysis:=randint(level) + 3;
					    msg_print('You are paralyzed.');
					  end;
				      end;
				    prt_hp;
				  end;
{Steal Money     }        12 :  with py.misc do
				  begin
				    if ((randint(256) < py.stat.c[dx]) and
					(py.flags.paralysis < 1)) then
		msg_print('You quickly protect your money pouch!')
				    else
				      if (money[total$] > 0) then
					begin
					  subtract_money(randint(5) * (money[total$] * gold$value) div 100,false);
					  msg_print('Your purse feels lighter.');
					  prt_weight;
					  prt_gold;
				        end;
				    if (randint(2) = 1) then
				      begin
					msg_print('There is a puff of smoke!');
					teleport_away(monptr,max_sight);
				      end;
				  end;
{Steal Object   }         13 :  with py.stat do
				  begin
				    if ((randint(256) < py.stat.c[dx]) and
					(py.flags.paralysis < 1)) then
		msg_print('You grab hold of your backpack!')
				    else
				      begin
					item_ptr := inventory_list;
					i1 := randint(inven_ctr) - 1;
					while (item_ptr <> nil) and (i1 > 0) do
					  begin
					    item_ptr := item_ptr^.next;
					    i1 := i1 - 1;
					  end;
					if (item_ptr^.is_in = false) then
					  if (uand(item_ptr^.data.flags2,
						   holding_bit) <> 0) then
					    begin
					      if (item_ptr^.insides = 0) then
					        inven_destroy(item_ptr);
					    end
					  else
					    inven_destroy(item_ptr)
					else
					  inven_destroy(item_ptr);
					prt_weight;
				msg_print('Your backpack feels lighter.');
				      end;
				    if (randint(2) = 1) then
				      begin
					msg_print('There is a puff of smoke!');
					teleport_away(monptr,max_sight);
				      end;
				  end;
{Poison         }         14 :  with py.flags do
				  begin
				    take_hit(damroll(damstr),ddesc);
				    prt_hp;
				    msg_print('You feel very sick.');
				    poisoned := poisoned+randint(level)+5;
				  end;
{Lose dexterity }         15 :  with py.flags do
				  begin
				    take_hit(damroll(damstr),ddesc);
		lose_stat(dx,'You feel more clumsy',
		'You feel clumsy for a moment, then it passes.');
			            prt_hp;
				  end;
{Lose constitution }      16 :  with py.flags do
				  begin
				    take_hit(damroll(damstr),ddesc);
		ident := lose_stat(cn,'Your health is damaged!',
		'Your body resists the effects of the disease.');
				    prt_hp;
				  end;
{Lose intelligence }      17 :  with py.flags do
				  begin
				    take_hit(damroll(damstr),ddesc);
		lose_stat(iq,'You feel your memories fading.',
		'You feel your memories fade, then they are restored!');
				    prt_hp;
				  end;
{Lose wisdom      }       18 :  with py.flags do
				  begin
				    take_hit(damroll(damstr),ddesc);
		lose_stat(ws,'Your wisdom is drained.',
		'Your wisdom is sustained.');
				    prt_hp;
				  end;
{Lose experience  }       19:   begin                                          
				msg_print('You feel your life draining away!');
				  i1:=damroll(damstr)+
					(py.misc.exp div 100)*mon$drain_life;
				  lose_exp(i1);
				end;
{Aggravate monster}       20:   aggravate_monster(5);
{Disenchant       }       21:   begin
				  flag := false;
				  case randint(8) of
				    1 : i1 := Equipment_primary;
				    2 : i1 := Equipment_armor;
				    3 : i1 := Equipment_belt;
				    4 : i1 := Equipment_shield;
				    5 : i1 := Equipment_cloak;
				    6 : i1 := Equipment_gloves;
				    7 : i1 := Equipment_bracers;
				    8 : i1 := Equipment_helm;
				  end;
				  with equipment[i1] do
				    begin
				      if (tohit > 0) then
					begin
					  tohit := tohit -
					   randint(2 - ord(tohit = 1));
					  flag := true;
					end;
				      if (todam > 0) then
					begin
					  todam := todam -
					    randint(2 - ord(todam = 1));
					  flag := true;
					end;
				      if (toac > 0) then
					begin
					  toac  := toac  -
					    randint(2 - ord(toac = 1));
					  flag := true;
					end;
				    end;
				  if (flag) then
				    begin
		    msg_print('There is a static feeling in the air...');
				      py_bonuses(blank_treasure,1);
				    end;
				end;
{Eat food         }       22:   begin
				  if (find_range([food],false,item_ptr,i2)) then
				    begin
				      inven_destroy(item_ptr);
				      prt_weight;
				    end;
				end;
{Eat light        }       23:   begin
				  with equipment[Equipment_light] do
				    if (p1 > 0) then
				      begin
					p1 := p1 - 250 - randint(250);
					if (p1 < 1) then p1 := 1;
					msg_print('Your light dims...');
				      end;
				end;
{Eat charges     }        24:   if (inven_ctr > 0) then
				  begin
				    item_ptr := inventory_list;
				    for i1 := 1 to randint(inven_ctr)-1 do
				      item_ptr := item_ptr^.next;
				    i4 := level;
				    with item_ptr^.data do
				      if (tval in [staff,rod,wand]) then
					if (p1 > 0) then
					  begin
					    hp := hp + i4*p1;
					    p1 := 0;
				msg_print('Energy drains from your pack!');
					  end;
				  end;
{Lose charisma	 }	  25:   with py.flags do
				  begin
				    take_hit(damroll(damstr),ddesc);
		lose_stat(ca,'Your skin starts to itch.',
		'Your skin starts to itch, but feels better now.');
				    prt_hp;
				  end;
{Petrification  }	  26:  with py.flags do
				 begin
				   petrify(hp);
				 end;
{POISON Poison	}	  27:  with py.flags do
				 begin
				   poisoned := poisoned + damroll(damstr);
				   msg_print('You feel very sick.');
				 end;
			  99:  ;
			  otherwise ;
			end
		      end
		    else
		      case adesc of
			  1,2,3,6  : msg_print(cdesc + 'misses you.');
			  otherwise ;
		      end
		    end
		  end
	      end
	  end;


	{ Make the move if possible, five choices		-RAK-	}
	function make_move(monptr : integer; mm : mm_type) : boolean;
	  var
		i1,i2,newy,newx         : integer;
		movebits                : unsigned;
		flag,tflag	        : boolean;
		squash,doesit		: ctype;

	  begin
	    i1 := 1;
	    flag := false;
	    make_move := false;
	    movebits := c_list[m_list[monptr].mptr].cmove;
	    repeat
		{ Get new positon               }
	      newy := m_list[monptr].fy;
	      newx := m_list[monptr].fx;
	      move(mm[i1],newy,newx);
	      with cave[newy,newx] do
		if (fval <> 15) then
		  begin
		    tflag := false;
		    if (cptr = 1) then
			tflag := true
		    else if (fopen) then
		      begin
			if (fval in floor_set) then
			  if (uand(movebits,%X'00000040') = 0) then
				tflag := true
			  else if ((fval in earth_set) =
				   (uand(movebits,%X'00000010') = 0)) then
				tflag := true;
		      end
		{ Creature moves through walls? }
		    else if (uand(movebits,%X'40000') <> 0) then
		      tflag := true
		{ Creature can open doors?      }
		    else if (tptr > 0) then
	with t_list[tptr] do
	  with m_list[monptr] do
	    if (uand(movebits,%X'20000') <> 0) then
	      begin     { Creature can open doors...                    }
		case tval of
		  Closed_door : begin   { Closed doors...       }
			  if (p1 = 0) then              { Closed doors  }
			    begin
			      tflag := true;
			      if (fm) then
				if (los(char_row,char_col,newy,newx)) then
				  begin
				    t_list[tptr] := door_list[1];
				    fopen := true;
				    lite_spot(newy,newx);
				    tflag := false;
				  end;
			    end
			  else if (p1 > 0) then         { Locked doors  }
			    begin
			      if (randint(100-level) < 5) then
				p1 := 0;
			    end
			  else if (p1 < 0) then         { Stuck doors   }
			    begin
			      if (randint(hp) > (10+abs(p1))) then
				p1 := 0;
			    end;
			end;
		  Secret_door : begin   { Secret doors...       }
			  tflag := true;
			  if (fm) then
			    if (los(char_row,char_col,newy,newx)) then
			      begin
				t_list[tptr] := door_list[1];
				fopen := true;
				lite_spot(newy,newx);
				tflag := false;
			      end;
			end;
		  otherwise ;
		end;
	      end
	    else
	      begin     { Creature can not open doors, must bash them   }
		case tval of
		  Closed_door : begin   { Closed doors...       }
			  i2 := abs(p1) + 20;
			  if (randint(hp) > i2) then
			    begin
			      tflag := true;
			      if (fm) then
				if (los(char_row,char_col,newy,newx)) then
				  begin
				    t_list[tptr] := door_list[1];
				    t_list[tptr].p1 := randint(2) - 1;
				    fopen := true;
				    lite_spot(newy,newx);
				    tflag := false;
				  end;
			    end
			end;
		  Secret_door : ;       { Secret doors...       }
		  otherwise ;
		end;
	      end;
		{ Glyph of warding present?     }
		    if (tflag) then
		      if (tptr > 0) then
			if (t_list[tptr].tval = Seen_Trap) then
			  if (t_list[tptr].subval = 99) then
			    begin
			      if (randint(obj$rune_prot) < c_list[m_list[monptr].mptr].level) then
				begin
				  if ((newy=char_row) and (newx=char_col)) then
				    msg_print('The rune of protection is broken!');
				  delete_object(newy,newx);
				end
			      else
				tflag := false;
			    end;
		{ Creature has attempted to move on player?     }
		    if (tflag) then
		      if (cptr = 1) then
			begin
			  if (not (m_list[monptr].ml)) then
			    update_mon(monptr);
			  if (find_flag) then
			    begin
			      find_flag := false;
			      move_char(5);
			    end;
			  make_attack(monptr);
		{ Player has read a Confuse Monster?    }
		{ Monster gets a saving throw...        }
			  if (py.flags.confuse_monster) then
			    with m_list[monptr] do
			     with c_list[mptr] do
			      begin
				msg_print('Your hands stop glowing.');
				py.flags.confuse_monster := false;
				if mon_save(monptr,0,c_sc_mental) then
		msg_print('The ' + name + ' is unaffected.')
				else
				  begin
		msg_print('The ' + name + ' appears confused.');
				    confused := true;
				  end;
			      end;
			  tflag := false;
			  flag  := true;
			end
		{ Creature is attempting to move on other creature?     }
		      else 
			if ((cptr > 1) and ((newy <> m_list[monptr].fy) or
			 (newx <> m_list[monptr].fx))) then
			begin
		{ Creature eats other creatures?        }
			  if (uand(movebits,%X'80000') <> 0) then
			  begin
			    if (m_list[cptr].ml = true) then
			    begin
			      squash := c_list[m_list[cptr].mptr].name;
			      doesit := c_list[m_list[monptr].mptr].name;
			      case randint(10) of
1 : msg_print('Uh oh...it looks like the '+squash+' is in need of first aid.');
2 : msg_print('*splat* *crunch* *gobble* *BUUUUUUURP*');
3 : msg_print('Look out!  The '+squash+' is going to-- Eeeeew...never mind.');
4 : msg_print('Ick...the '+doesit+' has '+squash+' all over his toes.');
5 : msg_print('The nice '+doesit+' took out the '+squash+' for you.');
6 : msg_print('WoWEE, Auggie Ben-Doggie!  The '+squash+' just got blatted!');
7 : msg_print('The '+squash+' Society will not appreciate this. . .');
8 : msg_print('The '+squash+' is not amused.');
9 : msg_print('The '+doesit+' pauses to clean the '+squash+' off.');
10: msg_print('Aw, darn.  There goes '+itos(c_list[m_list[cptr].mptr].mexp)+' experience!');
			    end;
			    end;
			    delete_monster(cptr);
			    end
			  else
			    tflag := false;
		      end;
		{ Creature has been allowed move...     }
		    if (tflag) then
		      with m_list[monptr] do
			begin
		{ Pick up or eat an object              }
			  if (uand(movebits,%X'100000') <> 0) then
			    with cave[newy,newx] do
			      if (tptr > 0) then
				if (t_list[tptr].tval < valuable_metal) then
				  delete_object(newy,newx);
		{ Move creature record                  }
			  move_rec(fy,fx,newy,newx);
			  fy := newy;
			  fx := newx;
			  flag := true;
			  make_move := true;
			end
		  end;
	      i1 := i1 + 1;
		{ Up to 5 attempts at moving, then give up...   }
	    until ((flag) or (i1 > 5));
	  end;

	function move_confused(monptr : integer; var mm : mm_type) : boolean; 
	    begin
		mm[1] := randint(9);
		mm[2] := randint(9);
		mm[3] := randint(9);
		mm[4] := randint(9);
		mm[5] := randint(9);
		move_confused := make_move(monptr,mm);
	    end;



	{ Creatures can cast spells too.  (Dragon Breath)	-RAK-	}
	{ cast_spell := true if creature changes position       }
	{ took_turn  := true if creature casts a spell          }
	function cast_spell(    monptr          : integer;
				var took_turn   : boolean) : boolean;
	  var
		i1                      : unsigned;
		i2,i3,y,x,chance2       : integer;
		chance,thrown_spell     : integer;
		r1                      : real;
		spell_choice            : array [1..31] of integer;
		cdesc,ddesc,outval      : vtype;
		stop_player		: boolean;
	  begin
	    with m_list[monptr] do
	      with c_list[mptr] do
		begin
		  chance := int(uand(spells,%X'0000000F'));
		  chance2 := int(uand(spells,%X'80000000'));
		{ 1 in x chance of casting spell                }
		{ if chance2 is true then 1 in x of not casting }
		  if (((chance2 = 0) and (randint(chance) <> 1)) or
			((chance2 <> 0) and (randint(chance) = 1))) then
		    begin
		      cast_spell := false;
		      took_turn  := false;
		    end
		{ Must be within certain range                  }
		  else if (cdis > max_spell_dis) then
		    begin
		      cast_spell := false;
 		      took_turn  := false;
		    end
		{ Must have unobstructed Line-Of-Sight          }
		  else if (not(los(char_row,char_col,fy,fx))) then
		    begin
		      cast_spell := false;
		      took_turn  := false;
		    end
		  else  { Creature is going to cast a spell     }
		    begin
		      took_turn  := true;
		      cast_spell := false;
		{ Describe the attack                           }
		      find_monster_name( cdesc, monptr, true );
		      cdesc := cdesc + ' ';
		      { For 'DIED_FROM' string  }
		      if (uand(%X'80000000',cmove) <> 0) then
			ddesc := 'The ' + name
		      else
			ddesc := '& ' + name;
		      inven_temp^.data.name   := ddesc;
		      inven_temp^.data.number := 1;
		      objdes(ddesc,inven_temp,true);
		{ End DIED_FROM                 }
		{ Extract all possible spells into spell_choice }
		      i1 := uand(spells,%X'0FFFFFF0');
		      i3 := 0;
		      while (i1 <> 0) do
			begin
			  i2 := bit_pos(i1);
			  i3 := i3 + 1;
			  spell_choice[i3] := i2;
			end;
		{ Choose a spell to cast                        }
		      thrown_spell := spell_choice[randint(i3)];
		{ Cast the spell...                             }
		      stop_player := false;
		      case thrown_spell of
{Teleport Short} 5 :    teleport_away(monptr,5);
{Teleport Long } 6 :    teleport_away(monptr,max_sight);
{Teleport To   } 7 :    begin
			  stop_player := true;
			  cdesc := cdesc + 'casts a spell.';
			  msg_print(cdesc);
			  msg_print(' ');
			  teleport_to(fy,fx);
			end;
{Light Wound   } 8 :    begin
			  stop_player := true;
			  if (index(cdesc,'Bard') <> 0) or
			     (index(cdesc,'Ranger') <> 0) or
			     (index(cdesc,'Master Bard') <> 0) then
			  cdesc := cdesc + 'shoots an arrow.'
			  else cdesc := cdesc + 'casts a spell.';
			  msg_print(cdesc);
			  if (player_spell_saves) then
			    msg_print('You resist the effects of the spell.')
			  else
			    take_hit(damroll('3d8'),ddesc);
			end;
{Serious Wound } 9 :    begin
			  stop_player := true;
			  cdesc := cdesc + 'casts a spell.';
			  msg_print(cdesc);
			  if (player_spell_saves) then
			    msg_print('You resist the affects of the spell.')
			  else
			    take_hit(damroll('8d8'),ddesc);
			end;
{Hold Person   }10 :    begin
			  stop_player := true;
			  cdesc := cdesc + 'casts a spell.';
			  msg_print(cdesc);
			  if (py.flags.free_act or (py.flags.free_time>0)) then
			    msg_print('You are unaffected...')
			  else if (player_spell_saves) then
			    msg_print('You resist the affects of the spell.')
			  else
			    begin
			      msg_print('You can''t move!');
		 	      if (py.flags.paralysis > 0) then
				py.flags.paralysis:=py.flags.paralysis+2
			      else
				py.flags.paralysis:=randint(5)+4;
			    end
			end;
{Cause Blindnes}11 :    begin
			  stop_player := true;
			  cdesc := cdesc + 'casts a spell.';
			  msg_print(cdesc);
			  if (player_spell_saves) then
			    msg_print('You resist the affects of the spell.')
			  else if (py.flags.blind > 0) then
			    py.flags.blind := py.flags.blind + 6
			  else
			    begin
			      py.flags.blind := 12+randint(3);
			      msg_print(' ');
			    end;
			end;
{Cause Confuse }12 :    begin
			  stop_player := true;
			  cdesc := cdesc + 'casts a spell.';
			  msg_print(cdesc);
			  if (player_spell_saves) then
			    msg_print('You resist the affects of the spell.')
			  else if (py.flags.confused > 0) then
			    py.flags.confused := py.flags.confused + 2
			  else
			    py.flags.confused := randint(5) + 3;
			end;
{Cause Fear    }13 :    begin
			  stop_player := true;
			  cdesc := cdesc + 'casts a spell.';
			  msg_print(cdesc);
			  if (player_spell_saves) then
			    msg_print('You resist the affects of the spell.')
			  else if (py.flags.afraid > 0) then
			    py.flags.afraid := py.flags.afraid + 2
			  else
			    py.flags.afraid := randint(5) + 3;
			end;
{Summon Monster}14 :    begin
			  stop_player := true;
			  cdesc := cdesc + 'magically summons a monster!';
			  msg_print(cdesc);
			  y := char_row;
			  x := char_col;
			  if (cave[y,x].fval in water_set) then
			    summon_water_monster(y,x,false)
			  else
			    summon_land_monster(y,x,false);
			  check_mon_lite(y,x);
			end;
{Summon Undead} 15 :    begin
			  stop_player := true;
			  cdesc := cdesc + 'magically summons an undead!';
			  msg_print(cdesc);
			  y := char_row;
			  x := char_col;
			  summon_undead(y,x);
			  check_mon_lite(y,x);
			end;
{Slow Person  } 16 :    with py.flags do
			 begin
			  stop_player := true;
			  cdesc := cdesc + 'casts a spell.';
			  msg_print(cdesc);
			  if (free_act or (free_time>0)) then
			    msg_print('You are unaffected...')
			  else if (player_spell_saves) then
			    msg_print('You resist the affects of the spell.')
			  else if (slow > 0) then
			    slow := slow + 2
			  else
			    slow := randint(5) + 3;
			 end;
{Drain Mana   } 17 :    if (trunc(py.misc.cmana) > 0) then
			  begin
			    stop_player := true;
			    outval := cdesc+'draws psychic energy from you!';
			    msg_print(outval);
			    outval := cdesc+'appears healthier...';
			    msg_print(outval);
			    r1 := ( randint(level) div 2 ) + 1;
			    if (r1 > py.misc.cmana) then r1 := py.misc.cmana;
			    py.misc.cmana := py.misc.cmana - r1;
			    hp := hp + 6*trunc(r1);
			  end;
{Breath Evil  } 18 :    begin
 			    stop_player := true;
     if index(cdesc,'High Priest')<>0 
       then cdesc := cdesc + 'throws a cloud of black vapors at you!'
       else cdesc := cdesc + 'breathes black vapors around you!';
			    msg_print(cdesc);
			    i1 := (py.misc.exp div 100)*mon$drain_life;
			    breath(7,char_row,char_col,1,ddesc);
                        end;
{Breath Petrify }19:	begin
			    stop_player := true;
			    cdesc := cdesc + 'breathes petrifying gas at you!';
			    msg_print(cdesc);
			    breath(9,char_row,char_col,1,ddesc);
			end;
{Breath Light } 20 :    begin
			  stop_player := true;
			  if (index(cdesc,'Druid') <> 0) or
			     (index(cdesc,'Titan') <> 0) then
			    cdesc := cdesc + 'casts a spell.'
			  else
			    cdesc := cdesc + 'breathes lightning.';
			  msg_print(cdesc);
			  if (index(cdesc,'Druid') <> 0) or
			     (index(cdesc,'Titan') <> 0) then
			    breath(1,char_row,char_col,32,ddesc)
			  else
			    breath(1,char_row,char_col,trunc(hp/4.0),ddesc);
			end;
{Breath Gas   } 21 :    begin
			  stop_player := true;
			  cdesc := cdesc + 'breathes gas.';
			  msg_print(cdesc);
			  breath(2,char_row,char_col,trunc(hp/3.0),ddesc);
			end;
{Breath Acid  } 22 :    begin
			  stop_player := true;
			  cdesc := cdesc + 'breathes acid.';
			  msg_print(cdesc);
			  breath(3,char_row,char_col,trunc(hp/3.0),ddesc);
			end;
{Breath Frost } 23 :    begin
			  stop_player := true;
			  cdesc := cdesc + 'breathes frost.';
			  msg_print(cdesc);
			  breath(4,char_row,char_col,trunc(hp/3.0),ddesc);
			end;
{Breath Fire  } 24 :    begin
			  stop_player := true;
			  if (index(cdesc,'Heirophant Druid') <> 0) then
			    cdesc := cdesc + 'casts a spell.'
			  else
			    cdesc := cdesc + 'breathes fire.';
			  msg_print(cdesc);
			  if (index(cdesc,'Heirophant Druid') <> 0) then
			    breath(5,char_row,char_col,48,ddesc)
			  else
			    breath(5,char_row,char_col,trunc(hp/3.0),ddesc);
			end;
{Cast Illusion }25 :	begin
			  stop_player := true;
			  cdesc := cdesc + 'casts a spell.';
			  msg_print(cdesc);
			  if (player_spell_saves) then
			    msg_print('You resist the affects of the spell.')
			  else if (py.flags.image > 0) then
			    py.flags.image := py.flags.image + 2
			  else
			    py.flags.image := randint(20) + 10;
			end;			  
 {Summon Demon}	26 :	begin
			  stop_player := true;
			  cdesc := cdesc + 'magically summons a demon!';
			  msg_print(cdesc);
			  y := char_row;
			  x := char_col;
			  summon_demon(y,x);
			  check_mon_lite(y,x);
			end;
{Summon Breed } 27  :   begin
			  stop_player := true;
			  cdesc := cdesc + 'magically summons a monster!';
			  msg_print(cdesc);
			  y := char_row;
			  x := char_col;
			  summon_breed(y,x);
			  check_mon_lite(y,x);
			end;
{Stoning Gaze}	28  :	begin  
			  stop_player := true;
			  cdesc := cdesc + 'gazes at you!';
			  msg_print(cdesc);
			  if (player_spell_saves) then
			    msg_print('You resist the affects!')
			  else petrify(hp);
			end;
		otherwise begin
			    stop_player := true;
			    msg_print('Creature cast unknown spell.');
			    cdesc := '';
			  end;
		      end;
		{ End of spells                                 }
		{ Stop player if in find mode	-DCJ/KRC-	}
		      if (find_flag and stop_player) then
			begin
			  find_flag  := false;
			  move_char(5);
			end;
		    end;
		end;
	  end;


	{ Main procedure for monster movement (MON_MOVE)	-RAK-	}
	begin
	  mon_move := false;
	  with c_list[m_list[monptr].mptr] do
	    begin
		{ Does the creature regenerate?				}
	      if (uand(cdefense,%X'8000') <> 0) then
		m_list[monptr].hp := m_list[monptr].hp + randint(4);
	      if (m_list[monptr].hp > max_hp(hd) ) then
		m_list[monptr].hp := max_hp(hd);
		{ Does the critter multiply?                            }
	      if (uand(cmove,%X'00200000') <> 0) then
		if (max_mon_mult >= mon_tot_mult) then
		  if ((py.flags.rest mod mon_mult_adj) = 0) then
		    with m_list[monptr] do
		      begin
			i3 := 0;
			for i1 := fy-1 to fy+1 do
			  for i2 := fx-1 to fx+1 do
			    if (in_bounds(i1,i2)) then
			      if (cave[i1,i2].cptr > 1) then
				i3 := i3 + 1;
			if (i3 < 4) then
			  if (randint(i3*mon_mult_adj) = 1) then
			    multiply_monster(fy,fx,mptr,false);
		      end;
		{ Creature is confused?  Chance it becomes un-confused  }
	      move_test := false;
	      if (m_list[monptr].confused) then
		begin
		  mon_move := move_confused(monptr,mm);
		  m_list[monptr].confused := (randint(8) <> 1);
		  move_test := true;
		end
		{ Creature may cast a spell                             }
	      else if (spells > 0) then
		mon_move := cast_spell(monptr,move_test);
	      if (not(move_test)) then
		begin
		{ 75% random movement                                   }
		  if ((randint(100) <= 75) and
		    (uand(cmove,%X'00000008') <> 0)) then
			mon_move := move_confused(monptr,mm)
		{ 40% random movement                                   }
		  else if ((randint(100) <= 40) and
		    (uand(cmove,%X'00000004') <> 0))  then
			mon_move := move_confused(monptr,mm)
		{ 20% random movement                                   }
		  else if ((randint(100) <= 20) and
		    (uand(cmove,%X'00000002') <> 0))  then
		   	mon_move := move_confused(monptr,mm)
		{ Normal movement                                       }
		  else if (uand(cmove,%X'00000001') = 0) then
		    begin
		      if (randint(200) = 1) then
			mon_move := move_confused(monptr,mm)
		      else
			begin
			  get_moves(monptr,mm);
		          mon_move := make_move(monptr,mm);
		        end;
		    end
		{ Attack, but don't move                                }
		else
		  if (m_list[monptr].cdis < 2) then
		    begin
		      get_moves(monptr,mm);
		      mon_move := make_move(monptr,mm);
		    end;
		end;
	    end;
	end;

	procedure splash(monptr : integer);
	var i1,mon_swimming,drown_dam : integer;
	begin
	  with m_list[monptr] do
	    with c_list[mptr] do begin
	      mon_swimming := INT(uand(cmove,%X'00000700')) DIV 256;
	      drown_dam := randint(out_of_env_dam);
{ here will also be modifiers due to waterspeed,depth }
{ divide damage by 2 for each mon_swimming level, random rounding procedure }
	      for i1 := 1 to mon_swimming do
		drown_dam := (drown_dam+(randint(3)-1)) div 3;
	      hp := hp - drown_dam;
	      csleep := 0;
	      if (hp < 0) then begin
		monster_death(fy,fx,cmove);
		with cave[fy,fx] do
		  delete_monster(cptr);
	      end;
	    end;
	end;

	{ Main procedure for creatures				-RAK-	}
      begin
	get_player_move_rate;
	if (muptr > 0) then
	  begin
	{ Process the monsters  }
	hear_count := 0;
	i1 := muptr;
	repeat
	  with m_list[i1] do
	    begin
	      cdis := distance(char_row,char_col,fy,fx);
	      if (attack) then  { Attack is argument passed to CREATURE}
		begin
		  i3 := movement_rate(cspeed,i1);
		  if (i3 > 0) then
		    for i2 := 1 to i3 do
		      begin
			if ((cdis <= c_list[mptr].aaf) or (ml)) then
			  begin
			    if (csleep > 0) then
			      if (py.flags.aggravate) then
				csleep := 0
			      else if (py.flags.rest < 1) then
				if (randint(10) > py.misc.stl) then
				  csleep := csleep - trunc(75.0/cdis);
			      if (stunned > 0) then
				stunned := stunned - 1;
			    if ((csleep <= 0) and (stunned <= 0)) then
			      begin
				moldy := fy;
				moldx := fx;
				if (mon_move(i1)) then
				  if (ml) then
				    begin
				      ml := false;
				      if (test_light(moldy,moldx)) then
					lite_spot(moldy,moldx)
				      else
					unlite_spot(moldy,moldx);
				    end;
			      end;
			  end;
			update_mon(i1);
		      end {for 1 to i3 loop}
		  else
		    update_mon(i1);
		end  {if attacking}
	      else
		update_mon(i1);
	      if (cave[fy,fx].fval in floor_set) then
	      if (((cave[fy,fx].fval in water_set) <>
		 (uand(c_list[mptr].cmove,%X'00000010') <> 0)) and
		 (uand(c_list[mptr].cmove,%X'00000040') <> 0)) then
		splash(i1);
	    end;
	  i1 := m_list[i1].nptr;
	until ((i1 = 0) or (moria_flag));
	if (want_warn) then
	  if (hear_count = 1) then
	    msg_print('You hear a noise in the water.')
	  else if (hear_count > 1) then
	    msg_print('You hear some noises in the water.');
	{ End processing monsters       }
	  end;
      end;
end.
