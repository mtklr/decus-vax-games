      {  Use a monk's mental discipline. . . .                  -RAD-   }
[psect(misc2$code)] procedure discipline;
      var
                i2,dir                          : integer;
                i1,item_ptr                     : treas_ptr;
                choice,chance                   : integer;
                dumy,y_dumy,x_dumy              : integer;
                redraw,flag                     : boolean;
                ident                           : boolean;
      begin
	redraw := false;
        reset_flag := true;
        if (py.flags.confused > 0) then
          msg_print('You are too confused to concentrate....')
        else if (py.flags.image > 0) then
          msg_print('Colors and images run through your head, distracting you.')
	else
	  begin
	    flag := false;
	    for i2 := 1 to 40 do
	      if (magic_spell[py.misc.pclass,i2].learned) then flag := true;
	    if (flag) then
	      begin
	        inven_temp^.data := monk_book;
	        if (cast_spell('Use which discipline?',inven_temp,
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
	{ Disciplines....}
	case choice of
{ Self-Healing }
           1 :  hp_player(damroll('4d4'),'a magic spell.'); 
{ Courage } 
           2 :  cure_me(py.flags.afraid);
{ Slow Poison } 
           3 :  slow_poison;
{ Negate Hunger } 
           4 :  begin
		  py.flags.food := player_food_full + 4000;  	
		  py.flags.status := uand(%X'FFFFFFFC',py.flags.status);
		  prt_hunger;
		  msg_print('You are full.');
		end;
{ Sense Enemies }
           5 :  detect_creatures(c_creature);
{ Self-Healing II }                 
           6 :  hp_player(damroll('8d4'),'a prayer.');
{ Night Vision }
           7 :  py.flags.tim_infra := py.flags.tim_infra + randint(25) + 25;
{ Poison Immunity }
           8 :  cure_me(py.flags.poisoned);
{ See Invisible } 
           9 :  detect_inv2(randint(24)+24);
{ Advanced Self-Healing } 
          10 :  hp_player(damroll('16d4'),'a prayer.'); 
{ Resist Petrification }
          11 :  py.flags.resist_petri := py.flags.resist_petri + randint(15) + 10;
{ Stealth }
          12 :  py.flags.temp_stealth := py.flags.temp_stealth+randint(15)+10;
{ Free Action } 
          13 :  py.flags.free_time := py.flags.free_time + (randint(10) + py.misc.lev); 
{ Improved Speed }
          14 :  with py.flags do
                  fast := fast + randint(20) + py.misc.lev;
	  otherwise ;
	end;
	{ End of Disciplines...}
			  if (not(reset_flag)) then 
			    with py.misc do
			      begin
			        exp := exp + sexp;
			        prt_experience;
			        sexp := 0;
			      end;
		        end;
		      with py.misc do
		        if (not(reset_flag)) then
			  begin
			    if (smana > cmana) then
			      begin
			        msg_print('You are distracted by the effort!');
			        py.flags.paralysis :=
				  randint(5*trunc(smana-cmana));
			        cmana := 0;
			      end
			    else
			      cmana := cmana - smana;
			    prt_mana;
			  end;
		    end
		else
		  erase_line(1,1);
	      end
	    else
	      msg_print('You don''t know any disciplines!');
	  end;
      end;
