
	{ Play a Druid song					-CAPN/DMF-   }
[psect(misc2$code)] procedure play;
      var
		i2,dir				: integer;
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
	else if (class[py.misc.pclass].dspell) then
	  if (inven_ctr > 0) then
	    begin
	      if (find_range([Instrument],false,i1,i2)) then
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
				 1  : msg_print('*Twang!*');
				 2  : msg_print('*Boink!*');
				 3  : msg_print('*Ding!*');
				 4  : msg_print('*Plunk!*');
				 5  : msg_print('*Clang!*');
			       end; { of the bad notes }
			       case randint(2) of
				 1  : msg_print('You play a sour note!');
				 2  : msg_print('You play an awful note!');
			       end
			    end
			    else
			      begin
				y_dumy := char_row;
				x_dumy := char_col;
	{ Songs....					}
	case choice of
{ Moon Beam }
	  1  :	if (get_dir('Which direction?',dir,dumy,y_dumy,x_dumy)) then
		begin
		  msg_print('A line of light appears!');
		  light_line(dir,char_row,char_col,1)
		end;
{ Detect Monster }
	  2  :	detect_creatures(c_monster);
{ Battle Song }
	  3  :	bless(randint(12)+12);
{ Light }
	  4  :	light_area(char_row,char_col);
{ Minor Cure }
	  5  :	hp_player(damroll('5d3'),'a magic spell.');
{ Find Safe Path }
	  6  :	begin
		  detect_sdoor;
		  detect_trap;
		end;
{ Magical Jig }
	  7  :	if (get_dir('Which direction?',dir,dumy,y_dumy,x_dumy)) then
		  zap_monster(dir,char_row,char_col,0,c_confuse);
{ Warp Wood }
	  8  :	begin
		  msg_print('The wood around you bends and warps...');
		  td_destroy;
		end;
{ Battle Dance }
	  9  :	begin
		  py.flags.hero := py.flags.hero + (randint(10) +5);
		  bless(randint(20)+20);
		end;
{ Cure Poison }
	  10 :	cure_me(py.flags.poisoned);
{ Charm }
	  11 :	sleep_monsters1(char_row,char_col);
{ Detect Curse }
	  12 :	detect_curse;
{ Summon Insects }
	  13 :	if (get_dir('Which direction?',dir,dumy,y_dumy,x_dumy)) then
		  fire_bolt(0,dir,char_row,char_col,
		    damroll('1d6') + py.misc.lev div 3 * 2,'Insect Swarm');
{ Call Lightning }
	  14 :	if (get_dir('Which direction?',dir,dumy,y_dumy,x_dumy)) then
		  fire_bolt(1,dir,char_row,char_col,
		    damroll('2d8')+ py.misc.lev div 2,'Lightning Bolt');
{ Magic Res. }
	  15 :	py.flags.magic_prot := randint(15) + 10;
{ Starlight }
	  16 :  begin
		  msg_print('A twinkling light appears.');
                  starlite(char_row,char_col);
                end;
{ Create Food }
	  17 :	create_food(10,8,0,0,0);
{ Remove Curse }
          18 :  for i2 := Equipment_min to equip_max-1 do
                  with equipment[i2] do
                    flags := uand(flags,%X'7FFFFFFF');
{ Infravision }
	  19 : py.flags.tim_infra := py.flags.tim_infra + randint(30) + 30;
{ Major Cure }
	  20 : hp_player(damroll('10d4'),'a magic spell. ');
{ Resist Petrification }
	  21 :	py.flags.resist_petri := py.flags.resist_petri + randint(15) + 10;
{ Transplant }
	  22 :	begin
		  msg_print('You step into a nearby patch of fungus...');
		  teleport(py.misc.lev*6);
		end;
{ Sunray }
	  23 :	if (get_dir('Which direction?',dir,dumy,y_dumy,x_dumy)) then
		  fire_ball(10,dir,char_row,char_col,
		    damroll('2d8'),'flash of sunlight');
{ Dispel Magic }
	  24 :	with py.flags do
		 begin
		  cure_me(blind);
		  cure_me(poisoned);
		  cure_me(afraid);
		 end;
{ Fire Stream }
	  25 :	if (get_dir('Which direction?',dir,dumy,y_dumy,x_dumy)) then
		  fire_line(5,dir,char_row,char_col,
		    damroll('3d4') + py.misc.lev div 2,'Stream of Fire');
{ Protection from Nature }
	  26 :	with py.flags do
		  begin
		    resist_heat := resist_heat + randint(15) +10;
		    resist_cold := resist_cold + randint(15) +10;
		    resist_lght := resist_lght + randint(15) +10;
		 end;
{ Turn Stone to Mud }
	  27 :	if (get_dir('Which direction?',dir,dumy,y_dumy,x_dumy)) then
		  wall_to_mud(dir,char_row,char_col);
{ Goodberry }
	  28 :  create_food(11,11,8,10,10);
{ Creeping Doom }   
	  29 :	if (get_dir('Which direction?',dir,dumy,y_dumy,x_dumy)) then
		  creeping_doom(dir,char_row,char_col,py.misc.lev * 3,
				py.misc.lev div 4,'Creeping Doom');
{ Pillar of Fire }
	  30 : if (get_dir('Which direction?',dir,dumy,y_dumy,x_dumy)) then
		 fire_bolt(5,dir,char_row,char_col,
			damroll('5d8')+py.misc.lev div 3,'Pillar of Fire');
{ Word of Recall }
	  31 : py.flags.word_recall := randint(20) + 20;
{ Lightning Ball }
	  32 :	if (get_dir('Which direction?',dir,dumy,y_dumy,x_dumy)) then
		  fire_ball(1,dir,char_row,char_col,py.misc.lev,'Lightning Ball');
{ Word of Blindness }
	  33 :	begin
		  if (zap_area(0,0,c_confuse)) then
		    msg_print('You blind the creatures!');
		end;
{ Protection from Monsters }
	  34 :	py.flags.protmon := (randint(20)+py.misc.lev );
{ Control Temperature }
	  35 :  repeat
		  if (get_dir('Hotter(1) or Colder(2)?',dir,dumy,y_dumy,
			x_dumy)) then
		    begin
		      if (dir = 1) then
			zap_area(%X'0020',30,c_hp)
		      else if (dir = 2) then
			zap_area(%X'0010',30,c_hp);
		    end
		  else
		    dir := 1;
		until ((dir=1) or (dir=2));
{ Ring of Fire }
	  36 : py.flags.ring_fire := randint(4) + 1;
{ Resist Charm }
	  37 : with py.flags do
		begin
		 free_time := free_time + randint(10) + py.misc.lev;
		 magic_prot := magic_prot + randint(10) + py.misc.lev;
		end;
{ Battle Frenzy }
	  38 :	begin
		  bless(randint(30)+30);         
		  py.flags.shero := (randint(20)+20);
		end;
{ Dispel Monster }
	  39 :	zap_area(%X'0002',3*py.misc.lev,c_hp);
{ Note of Destruction }
	  40 :	destroy_area(char_row,char_col);
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
	  case bard_adj of
	    0 : msg_print('You utter a gutteral cry.');
	    1 : msg_print('You utter a gutteral cry.');
	    2 : msg_print('You attempt to sing.');
	    3 : msg_print('You attempt to sing.');
	    4 : msg_print('You sing a song.');
	    5 : msg_print('You sing a song.');
	    6 : msg_print('You sing a nice song.');
	    7 : msg_print('You sing a very nice song.');
	  end;
      end;
 
 
