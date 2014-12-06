	{ Pray like HELL...					-RAK-	}
[psect(misc2$code)] procedure pray;
      var
		i2,dir				: integer;
		i1,item_ptr			: treas_ptr;
		choice,chance			: integer;
		dumy,y_dumy,x_dumy		: integer;
		redraw				: boolean;
		ident				: boolean;
		bs				: vtype;
      begin
	reset_flag := true;
	if (py.flags.blind > 0) then
	  msg_print('You can''t see to read your prayer!')
	else if (no_light) then
	  msg_print('You have no light to read by.')
	else if (py.flags.confused > 0) then
	  msg_print('You are too confused...')
	else if (class[py.misc.pclass].pspell) then
	  if (inven_ctr > 0) then
	    begin
	      if (find_range([Prayer_Book],false,i1,i2)) then
	        begin
		  redraw := false;
		  if (get_item(item_ptr,'Use which Holy Book?',
					redraw,i2,trash_char,false)) then
		    begin
		      if (cast_spell('Recite which prayer?',item_ptr,
						choice,chance,redraw)) then
			with magic_spell[py.misc.pclass,choice] do
			  begin
			    reset_flag := false;
			    if (randint(100) < chance) then
			      msg_print('You lost your concentration!')
			    else
			      begin
				y_dumy := char_row;
				x_dumy := char_col;
	{ Prayers...					}
	case choice of
{ Detect Evil }
	  1  :	detect_creatures(c_evil);
{ Cure Light Wounds }
	  2  :	hp_player(damroll('3d3'),'a prayer.');
{ Bless }
	  3  :	bless(randint(12)+12);
{ Remove Fear }
	  4  :	cure_me(py.flags.afraid);
{ Call Light }
	  5  :	light_area(char_row,char_col);
{ Find Traps }
	  6  :	detect_trap;
{ Detect Doors/Stairs }
	  7  :	detect_sdoor;
{ Slow Poison }
	  8  :	slow_poison;
{ Blind Creature }
	  9  :	if (get_dir('Which direction?',dir,dumy,y_dumy,x_dumy)) then
		  zap_monster(dir,char_row,char_col,0,c_confuse);
{ Portal }
	  10 :	teleport(py.misc.lev*3);
{ Cure Medium Wounds }
	  11 :	hp_player(damroll('4d4'),'a prayer.');
{ Ray of Sanctification }
	  12 : if (get_dir('Which direction?',dir,dumy,y_dumy,x_dumy)) then
		fire_bolt(c_good,dir,char_row,char_col,damroll('2d6'),
			'Purple Ray');
{ Heroism }
	  13 :  py.flags.hero := py.flags.hero + randint(24) + 48;
{ Sanctuary }
	  14 :	sleep_monsters1(char_row,char_col);
{ Remove Curse }
	  15 :	for i2 := Equipment_min to equip_max-1 do
		  with equipment[i2] do
		    flags := uand(flags,%X'7FFFFFFF');
{ Resist Heat and Cold }
	  16 :	with py.flags do
		  begin
		    resist_heat := resist_heat + randint(10) + 10;
		    resist_cold := resist_cold + randint(10) + 10;
		  end;
{ Silence }
	  17 : py.flags.temp_stealth := py.flags.temp_stealth + (randint(20) + 15);
{ Resist Petrification }
	  18 : py.flags.resist_petri := py.flags.resist_petri + (randint(15) + 10);
{ Neutralize Poison }
	  19 :	cure_me(py.flags.poisoned);
{ Cure Serious Wounds }
	  20 :	hp_player(damroll('9d4'),'a prayer.');
{ Chant }
	  21 : bless(24+randint(48));
{ Sense Invisible }
	  22 :	detect_inv2(randint(24)+24);
{ Protection from Evil }
	  23 :	protect_evil;
{ Earthquake }
	  24 :	earthquake;
{ Create food }
	  25 : create_food(3,2,1,0,0);
{ Sense Surroundings }
	  26 :	map_area;
{ Orb of Draining }
	  27 :	if (get_dir('Which direction?',dir,dumy,y_dumy,x_dumy)) then
		  fire_ball(c_good,dir,char_row,char_col,
				damroll('3d6')+py.misc.lev,'Black Sphere');
{ Cure Critical Wounds }
	  28 :	hp_player(damroll('20d4'),'a prayer.');
{ Turn Undead }
	  29 :	zap_area(0,0,c_turn);
{ Prayer }
	  30 :	py.flags.shero := 24 + randint(48);
{ Dispell Undead }
	  31 :	zap_area(%X'0008',3*py.misc.lev,c_hp);
{ Resist Paralysis }
	  32 :  py.flags.free_time := py.flags.free_time + (randint(20) + 15);
{ Blade Barrier }
	  33 :  py.flags.blade_ring := py.flags.blade_ring+3+randint(3);
{ Dispell Evil }
	  34 :	zap_area(%X'0004',3*py.misc.lev,c_hp);
{ Heal }
	  35 :	hp_player(200,'a prayer.');
{ Resist Magic }
	  36 : py.flags.magic_prot := py.flags.magic_prot + 40 + randint(40);
{ Holy Thunder }
	  37 : begin
		msg_print('KABOOM!');
		zap_area(%X'0004',4+randint(4),c_thunder);
	       end;
{ Glyph of Warding }
	  38 :	warding_glyph;
{ Hero's Feast }
	  39 :	begin
		  msg_print('You have a marvelous meal!');
		  py.flags.food := player_food_full+4000;
		  prt_hunger;
		  hp_player(200,'a prayer.');
		  create_food(6,4,3,2,1);
		  py.flags.status := uand(%X'FFFFFFFC',py.flags.status);
		  prt_hunger;
		  msg_print('You are full.');
		end;
{ Holy Word }
	  40 :	begin
		  zap_area(%X'0004',6*py.misc.lev,c_holy_word);
		  cure_me(py.flags.afraid);
		  cure_me(py.flags.poisoned);
		  hp_player(1000,'a prayer.');
		end;
	  otherwise ;
	end;
	{ End of prayers...				}
			        if (not(reset_flag)) then
			          with py.misc do
			            begin
			              exp := exp + sexp;
			              prt_experience;
				      sexp := 0;
			            end
			      end;
			    with py.misc do
			      if (not(reset_flag)) then
				begin
				  if (smana > cmana) then
				    begin
				      msg_print('You faint from fatigue!');
				      py.flags.paralysis := 
					randint(5*trunc(smana-cmana));
				      cmana := 0;
				      if (randint(3) = 1) then
		{does not check for sustain}
		      		lower_stat(cn,'You have damaged your health!');
				    end
				  else
				    cmana := cmana - smana;
				  prt_mana;
			        end
			  end
		    end
		  else
		    if (redraw) then draw_cave;
	        end
	      else
	        msg_print('But you are not carrying any Holy Books!');
	    end
	  else
	    msg_print('But you are not carrying any Holy Books!')
	else
	  msg_print('Pray hard enough and your prayers may be answered.');
      end;
