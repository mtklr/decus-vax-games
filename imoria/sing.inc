

	{ Sing a Bard song				       -CAPN/DMF-   }
[psect(misc2$code)] procedure sing;
      var
		i2,dir,i3			: integer;
		i1,item_ptr			: treas_ptr;
		choice,chance			: integer;
		dumy,y_dumy,x_dumy		: integer;
		redraw				: boolean;
		ident				: boolean;
      begin
	reset_flag := true;
	if (py.flags.hoarse > 0) then
	  msg_print('You are too hoarse to sing!')
	else if (py.flags.afraid > 0) then
	  msg_print('You are too scared to play music!')
	else if (py.flags.confused > 0) then
	  msg_print('You are too confused...')
	else if (class[py.misc.pclass].bspell) then
	  if (inven_ctr > 0) then
	    begin
	      if (find_range([Song_book],false,i1,i2)) then
		begin
		  redraw := false;
		  if (get_item(item_ptr,'Use which Instrument?',
					redraw,i2,trash_char,false)) then
		    begin
		      if (cast_spell('Play which song?',item_ptr,
						choice,chance,redraw)) then
			with magic_spell[py.misc.pclass,choice] do
			  begin
			    reset_flag := false;
			    if (randint(100) < chance) then
			    begin
			       case randint(5) of
				 1  : msg_print('*Squak*');
				 2  : msg_print('*Gag!*');
				 3  : msg_print('*Aaugh!*');
				 4  : msg_print('*Yargh!*');
				 5  : msg_print('*Cough!*');
			       end; { of the bad notes }
			       case randint(2) of
				 1  : msg_print('You sing a sour note!');
				 2  : msg_print('You sing an awful note!');
			       end
			    end
			    else
			      begin
				y_dumy := char_row;
				x_dumy := char_col;
	{ Songs....					}
	case choice of
{ Detect Monster }
	  1  :	detect_creatures(c_monster);
{ Battle Song }
	  2  :	bless(randint(12)+12);
{ Blink }
	  3  :	teleport(10);
{ Light }
	  4  :	light_area(char_row,char_col);
{ Detect Doors	}
	  5  :	begin
		  detect_sdoor;
		  detect_trap;
		end;
{ Magical Jig }
	  6  :	if (get_dir('Which direction?',dir,dumy,y_dumy,x_dumy)) then
		  zap_monster(dir,char_row,char_col,0,c_confuse);
{ Detect Magic }
	  7  : detect_magic;
{ Minor Cure }
	  8  :	hp_player(damroll('5d3'),'a magic spell.');
{ Battle Dance }
	  9  :	begin
		  py.flags.hero := py.flags.hero + (randint(10) +5);
		  bless(randint(20)+20);
		end;
{ Charm Monsters }
	  10 :	sleep_monsters1(char_row,char_col);
{ Detect Curse }
	  11 :	detect_curse;
{ Detect Invisible }
	  12 : detect_creatures(c_invisible);
{ Cure Poison }
	  13 :	cure_me(py.flags.poisoned);
{ Invisibility }
	  14 : py.flags.temp_stealth := py.flags.temp_stealth+randint(15)+10;
{ Teleport Self }
	  15 : teleport(py.misc.lev*6);
{ Infravision }
          16 :  py.flags.tim_infra := py.flags.tim_infra + randint(50) + 50;
{ Physical Humor }
	  17 :	if (get_dir('Which diretion?',dir,dumy,y_dumy,x_dumy)) then
		  fire_bolt(c_joke,dir,char_row,char_col,damroll('3d8'),
			'punch line');
{ Recharge Item }
	  18 :	recharge(20);
{ Remove Curse }
	  19 :	for i2 := Equipment_min to equip_max-1 do
		  with equipment[i2] do
		    flags := uand(flags,%X'7FFFFFFF');
{ Legend Lore }
	  20 :	ident_spell;
{ Mass Charm }
	  21 : zap_area(0,0,c_sleep);
{ Detect Treasure }
	  22 : detect_item(c_treasure);
{ Detect Object }
	  23 : detect_item(c_object);
{ Resist Petrification }
	  24 : py.flags.resist_petri := py.flags.resist_petri + randint(15) + 10;
{ Create Food and Drink }
	  25 :	create_food(3,9,1,0,0);
{ Panic }
	  26 :	begin
		  msg_print('You scare the creatures!');
		  zap_area(0,0,c_confuse);
		end;
{ Word of Recall }
	  27 : py.flags.word_recall := randint(20) + 20;
{ Protection from Nature }
	  28 :	with py.flags do
		  begin
		    resist_heat := resist_heat + randint(15) +10;
		    resist_cold := resist_cold + randint(15) +10;
		    resist_lght := resist_lght + randint(15) +10;
		 end;
{ See Invisible }
	  29 : detect_inv2(randint(24)+24);
{ Magic Mapping }
	  30 :	map_area;
{ Joke of Death }
	  31 :	if (get_dir('Which direction?',dir,dumy,y_dumy,x_dumy)) then
		  fire_ball(c_joke,dir,char_row,char_col,30,'terrible joke');
{ Battle Frenzy }
	  32 :	begin
		  bless(randint(30)+30);
		  py.flags.hero := randint(30)+30;
		  py.flags.shero := randint(30)+30;
		end;
{ Slow Creature }
	  33 :	if (get_dir('Which direction?',dir,dumy,y_dumy,x_dumy)) then
		  zap_monster(dir,char_row,char_col,-1,c_speed);
{ Resist Charm }
	  34 :	with py.flags do
		begin
		  free_time := free_time + randint(10) + py.misc.lev;
		  magic_prot := magic_prot + randint(10) + py.misc.lev;
		end;
{ Item Lore }
	  35 :	lore_spell;
{ Song of Protection }
	  36 :	begin
		  py.flags.protmon := (randint(20)+py.misc.lev );
		  protect_evil;
		  bless(randint(24)+24);
		end;
{ Last Laugh }
	  37 : zap_area(0,50,c_joke);
{ Teleport Level }
	  38 :	begin
		  dun_level := dun_level - 3 + 2*randint(2);
		  if (dun_level < 1) then
		    dun_level := 1;
		  moria_flag := true;
		end;
{ Clairvoyance }
	  39 :	begin
		  redraw := true;
		  wizard_light;
		  for i2 := (char_col + 1) to (char_col - 1) do
		    for i3 := (char_row + 1) to (char_row - 1) do
		      if (test_light(i3,i2)) then
			redraw := false;
		  if (redraw) then 
		    wizard_light;
		end;
{ Song of Power }
	  40 :	begin
		  zap_area(%X'0006',4*py.misc.lev,c_hp);
		  cure_me(py.flags.poisoned);
		  hp_player(300, 'a spell');
		  cure_me(py.flags.blind);
		end;
	  otherwise ;
	end;
	{ End of songs...			       }
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
msg_print('You lose your voice attempting the song!');
				      py.flags.hoarse :=
					randint(5*trunc(smana-cmana));
				      cmana := 0;
				  if (randint(3) = 1) then lower_stat(ca,'Your self-esteem is lowered!');
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
		msg_print('But you are not carrying any Instruments!');
	    end
	  else
	    msg_print('But you are not carrying any Instruments!')
	else
	  case (bard_adj+randint(4)) of
	    1,2 : msg_print('You utter a gutteral cry.');
	    3,4 : msg_print('You mumble a simple tune.');
	    5,6 : msg_print('You sing a fair song.');
	    7,8 : msg_print('You sing a very nice song.');
	    9,10,11 : msg_print('You sing quite beautifully.');
	  end;
      end;
 
 
