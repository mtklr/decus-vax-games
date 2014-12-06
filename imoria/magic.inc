	{ Throw a magic spell					-RAK-	}
[psect(misc2$code)] procedure cast;
      var
		i2,dir				: integer;
		i1,item_ptr			: treas_ptr;
		choice,chance			: integer;
		dumy,y_dumy,x_dumy		: integer;
		redraw				: boolean;
		ident				: boolean;
      begin
	reset_flag := true;
	if (py.flags.blind > 0) then
	  msg_print('You can''t see to read your spell book!')
	else if (no_light) then
	  msg_print('You have no light to read by.')
	else if (py.flags.confused > 0) then
	  msg_print('You are too confused...')
	else if (class[py.misc.pclass].mspell) then
	  if (inven_ctr > 0) then
	    begin
	      if (find_range([Magic_Book],false,i1,i2)) then
		begin
		  redraw := false;
		  if (get_item(item_ptr,'Use which spell-book?',redraw,
						i2,trash_char,false)) then
		    begin
		      if (cast_spell('Cast which spell?',item_ptr,
						choice,chance,redraw)) then
			with magic_spell[py.misc.pclass,choice] do
			  begin
			    reset_flag := false;
			    if (randint(100) < chance) then
			      msg_print('You failed to get the spell off!')
			    else
			      begin
				y_dumy := char_row;
				x_dumy := char_col;
	{ Spells...					}
	case choice of
{ Magic Missile }
	  1  :	if (get_dir('Which direction?',dir,dumy,y_dumy,x_dumy)) then
		  fire_bolt(0,dir,char_row,char_col,
					damroll('2d6')+1,'Magic Missile');
{ Detect Monster }
	  2  :	detect_creatures(c_monster);
{ Phase Door }
	  3  :	teleport(10);
{ Light }
	  4  :	light_area(char_row,char_col);
{ Cure Light }
	  5  :	hp_player(damroll('4d4'),'a magic spell.');
{ Find Hidden Traps/Door }
	  6  :	begin
		  detect_sdoor;
		  detect_trap;
		end;
{ Stinking Cloud }
	  7  :	if (get_dir('Which direction?',dir,dumy,y_dumy,x_dumy)) then
		  fire_ball(c_gas,dir,char_row,char_col,9,'Stinking Cloud');
{ Confuse Monster }
	  8  :	if (get_dir('Which direction?',dir,dumy,y_dumy,x_dumy)) then
		  zap_monster(dir,char_row,char_col,0,c_confuse);
{ Lightning Bolt }
	  9 :	if (get_dir('Which direction?',dir,dumy,y_dumy,x_dumy)) then
		  fire_bolt(c_lightning,dir,char_row,char_col,
					damroll('3d8')+1,'Lightning Bolt');
{ Trap/Door Destruction }
	  10 :	td_destroy;
{ Sleep I }
	  11 :	if (get_dir('Which direction?',dir,dumy,y_dumy,x_dumy)) then
		  zap_monster(dir,char_row,char_col,0,c_sleep);
{ Cure Poison }
	  12 :	cure_me(py.flags.poisoned);
{ Shadow Door }
	  13 :	teleport(py.misc.lev*5);
{ Remove Curse }
	  14 :	for i2 := Equipment_min to equip_max-1 do
		  with equipment[i2] do
		    flags := uand(flags,%X'7FFFFFFF');
{ Frost Bolt }
	  15 :	if (get_dir('Which direction?',dir,dumy,y_dumy,x_dumy)) then
		  fire_bolt(c_cold,dir,char_row,char_col,
					damroll('4d8')+1,'Frost Bolt');

{ Create Food }
	  16 :	create_food(7,7,0,0,0);
{ Infravision }
	  17 : py.flags.tim_infra := py.flags.tim_infra + 50 + randint(50);
{ Invisibility }
	  18 : py.flags.temp_stealth := py.flags.temp_stealth+randint(15)+10;
{ Turn Stone to Mud }
	  19 :	if (get_dir('Which direction?',dir,dumy,y_dumy,x_dumy)) then
		  wall_to_mud(dir,char_row,char_col);
{ Recharge Item I }
	  20 :	recharge(20);
{ Sleep II }
	  21 :	sleep_monsters1(char_row,char_col);
{ Phantasmal Force }
	  22 :	if (get_dir('Which direction?',dir,dumy,y_dumy,x_dumy)) then
		  fire_bolt(c_illusion,dir,char_row,char_col,damroll('8d4'),
			'phantasmal force');
{ Polymorph Other }
	  23 :	if (get_dir('Which direction?',dir,dumy,y_dumy,x_dumy)) then
		  poly_monster(dir,char_row,char_col);
{ Identify }
	  24 :	ident_spell;
{ Ring of Frost }
	  25 : py.flags.ring_ice := py.flags.ring_ice + 3 + randint(3);
{ Sleep III }
	  26 :	zap_area(0,0,c_sleep);
{ Hold Monster }
	  27 :	if (get_dir('Which direction?',dir,dumy,y_dumy,x_dumy)) then
		  zap_monster(dir,char_row,char_col,4+randint(4),c_hold);
{ Fire Bolt }
	  28 :	if (get_dir('Which direction?',dir,dumy,y_dumy,x_dumy)) then
		  fire_bolt(c_fire,dir,char_row,char_col,
					damroll('6d8')+1,'Fire Bolt');
{ Slow Creature }
	  29 :	if (get_dir('Which direction?',dir,dumy,y_dumy,x_dumy)) then
		  zap_monster(dir,char_row,char_col,-1,c_speed);
{ Protection From Magic }
	  30 : py.flags.magic_prot := py.flags.magic_prot + 20 + randint(20);
{ Frost Ball }
	  31 :	if (get_dir('Which direction?',dir,dumy,y_dumy,x_dumy)) then
		  fire_ball(c_cold,dir,char_row,char_col,40,'Frost Ball');
{ Death Spell }
	  32 :	zap_area(0,py.misc.lev div 2+damroll('4d8'),c_drain);
{ Ring of Fire }
	  33 :	py.flags.ring_fire := py.flags.ring_fire + 3 + randint(3);
{ Recharge Item II }
	  34 :	recharge(50);
{ Teleport Other }
	  35 :	if (get_dir('Which direction?',dir,dumy,y_dumy,x_dumy)) then
		  teleport_monster(dir,char_row,char_col);
{ Haste Self }
	  36 :	with py.flags do
		  fast := fast + randint(20) + py.misc.lev;
{ Fire Ball }
	  37 :	if (get_dir('Which direction?',dir,dumy,y_dumy,x_dumy)) then
		  fire_ball(c_fire,dir,char_row,char_col,59,'Fire Ball');
{ Power Word: Destruction }
	  38 :	destroy_area(char_row,char_col);
{ Power Word: Kill }
	  39 :	if (get_dir('Which direction?',dir,dumy,y_dumy,x_dumy)) then
		  fire_bolt(0,dir,char_row,char_col,
					damroll('24d8'),'Black Bolt');
{ Genocide }
	  40 :	genocide;
	  otherwise ;
	end;
	{ End of spells...				}
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
				      msg_print('You faint from the effort!');
				      py.flags.paralysis :=
					randint(5*trunc(smana-cmana));
				      cmana := 0;
				      if (randint(3) = 1) then
		{lower_stat == no sustain}
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
		msg_print('But you are not carrying any spell-books!');
	    end
	  else
	    msg_print('But you are not carrying any spell-books!')
	else
	  msg_print('You can''t cast spells!');
      end;
