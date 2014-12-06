	{ Potions for the quaffing				-RAK-	}
[psect(misc2$code)] procedure quaff;
      var
		i1				: unsigned;
		i3,i4,i5,i6			: integer;
		i2,item_ptr			: treas_ptr;
		out_val				: vtype;
		redraw,ident			: boolean;
      begin
	reset_flag := true;
	if (inven_ctr > 0) then
	  begin
	    if (find_range([potion1,potion2],false,i2,i3)) then
	      begin
		redraw := false;
		if (get_item(item_ptr,'Quaff which potion?',redraw,i3,trash_char,false)) then
		  with item_ptr^.data do
		    begin
		      if (redraw) then draw_cave;
		      reset_flag := false;
		      i1 := flags;
		      ident := false;
		      while (i1 > 0) do
			begin
			  i6 := bit_pos(i1);
			  if (tval = potion2) then i6 := i6 + 31;
	{ Potions						}
	case (i6) of
{ Gain Str }
	  1  :	ident := gain_stat(sr,'X');
{ Lose Str }
	  2  :	ident := lose_stat(sr,'X','X');
{ Restore Str }
	  3  :	ident := restore_stat(sr,'X');
{ Gain Int }
	  4  :	ident := gain_stat(iq,'X');
{ Lose Int }
	  5  :	begin
		  msg_print('This potion tastes very dull.');
		  ident := lose_stat(iq,'X','X');
		end;
{ Restore Int }
	  6  :	ident := restore_stat(iq,'X');
{ Gain Wis }
	  7  :	ident := gain_stat(ws,'X');
{ Lose Wis }
	  8  :	ident := lose_stat(ws,'X','X');
{ Restore Wis }
	  9  :	ident := restore_stat(ws,'X');
{ Gain Chr }
	  10 :	ident := gain_stat(ca,'X');
{ Lose Chr }
	  11 :	ident := lose_stat(ca,'X','X');
{ Restore Chr }
	  12 :	ident := restore_stat(ca,'X');
{ Cures and healing }
	  13 :	ident := hp_player(damroll('2d7'),'a potion.');
	  14 :	ident := hp_player(damroll('4d7'),'a potion.');
	  15 :	ident := hp_player(damroll('6d7'),'a potion.');
	  16 :	ident := hp_player(1000,'a potion.');
{ Gain Con }
	  17 :	begin
		  py.misc.mhp := py.misc.mhp + 1;
		  py.misc.chp := py.misc.chp + py.misc.mhp;
		  ident := gain_stat(cn,'X');
		  prt_hp;
		end;
{ Gain Experience }
	  18 :	with py.misc do
		  begin
		    i5 := (exp div 2) + 10;
		    if (i5 > 100000) then i5 := 100000;
		    exp := exp + i5;
		    msg_print('You feel more experienced.');
		    prt_experience;
		    ident := true;
		  end;
{ Sleep }
	  19 :	with py.flags do
		  if (not (py.flags.free_act)) then
		    begin
		      msg_print('You fall asleep.');
		      py.flags.paralysis := py.flags.paralysis + 
								randint(4) + 4;
		      ident := true;
		    end;
{ Darkness }
	  20 :	with py.flags do
		  begin
		    msg_print('You are covered by a veil of darkness.');
		    blind := blind + randint(100) + 100;
		    ident := true;
		  end;
{ Confusion }
	  21 :	with py.flags do
		  begin
		    msg_print('Hey!  This is good stuff!  * Hick! *');
		    confused := confused + randint(20) + 12;
		    ident := true;
		  end;
{ Poison }
	  22 :	with py.flags do
		  begin
		    msg_print('You feel very sick.');
		    poisoned := poisoned + randint(15) + 10;
		    ident := true;
		  end;
{ Haste Self }
	  23 :	begin
		  py.flags.fast := py.flags.fast + randint(25) + 15;
		  ident := true;
		end;
{ Slowness }
	  24 :	begin
		  py.flags.slow := py.flags.slow + randint(25) + 15;
		  ident := true;
		end;
	  25 :	ident := detect_creatures(c_monster);
{ Increase Dex }
	  26 :	ident := gain_stat(dx,'X');
{ Restore Dex }
	  27 :	ident := restore_stat(dx,'X');
{ Restore Con }
	  28 :	ident := restore_stat(cn,'X');
{ Cure Blindness }
	  29 :	cure_me(py.flags.blind);
{ Cure Confusion }
	  30 :	cure_me(py.flags.confused);
{ Cure Poison }
	  31 :	cure_me(py.flags.poisoned);
{ Learning }
	  32 :	with py.misc do
		  with class[pclass] do
		    if (mspell) then
		      begin
		        ident := learn_spell(redraw);
			if (redraw) then draw_cave;
		      end
		    else if (bspell) then
		      begin
			ident := learn_song(redraw);
			if (redraw) then draw_cave;
		      end
		    else if (pspell) then
		      ident := learn_prayer
		    else if (dspell) then
		      ident := learn_druid;
{ Lose Memories }
	  33 :	begin
		  msg_print('You feel your memories fade...');
		  msg_print('');
		  i4 := trunc(py.misc.exp/5.0); 
		  lose_exp(randint(i4)+i4);
		  ident := true;
		end;
{ Salt Water }
	  34 :	with py.flags do
		  begin
		    poisoned := 0;
		    py.flags.status := uand(py.flags.status,%X'FFFFFFDF');
		    prt_poisoned;
		    if (food > 150) then food := 150;
		    paralysis := 4;
		    msg_print('The potion makes you vomit!');
		    ident := true;
		  end;
{ Invulnerability }
	  35 :	begin
		  py.flags.invuln := py.flags.invuln + randint(10) + 10;
		  ident := true;
		end;
{ Heroism }
	  36 :	begin
		  py.flags.hero := py.flags.hero + randint(25) + 25;
		  ident := true;
		end;
{ Super-Heroism }
	  37 :	begin
		  py.flags.shero := py.flags.shero + randint(25) + 25;
		  ident := true;
		end;
{ Remove Fear }
	  38 :	ident := cure_me(py.flags.afraid);
{ Restore Level }
	  39 :  begin
		  ident := restore_level;
		  add_food(5000);
		  py.flags.status := uand(%X'FFFFFFFC',py.flags.status);
		  prt_hunger;
		end;
{ Resist Heat }
	  40 :	with py.flags do
		  resist_heat := resist_heat + randint(10) + 10;
{ Resist Cold }
	  41 :	with py.flags do
		  resist_cold := resist_cold + randint(10) + 10;
	  42 :	detect_inv2(randint(12)+12);
{ Slow Poison }
	  43 :	ident := slow_poison;
{ Cure Poison }
	  44 :  ident := cure_me(py.flags.poisoned);
{ Restore Mana }
	  45 :	with py.misc do
		  if (cmana < mana) then
		    begin
		      cmana := mana;
		      ident := true;
		      msg_print('Your feel your head clear...');
		    end;
{ Infra-Vision }
	  46 :	with py.flags do
		  begin
		    tim_infra := tim_infra + 100 + randint(100);
		    ident := true;
		    msg_print('Your eyes begin to tingle.');
		  end;
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
	{ End of Potions...					}
			end;
		      if (ident) then
			identify(item_ptr^.data);
		      if (flags <> 0) then
			begin
		          with py.misc do
			    exp := exp + round(level/lev);
		          prt_experience;
			end;
		      add_food(p1);
		      desc_remain(item_ptr);
		      inven_destroy(item_ptr);
		      prt_weight;
		    end
		else
		  if (redraw) then draw_cave;
	      end
	    else
	      msg_print('You are not carrying any potions.');
	  end
	else
	  msg_print('But you are not carrying anything.');
      end;
