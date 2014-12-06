	{ Wands for the aiming...				}
[psect(misc2$code)] procedure aim;
      var
		i1				: unsigned;
		i3,i4,chance,i5			: integer;
		dir				: integer;
		i2,item_ptr			: treas_ptr;
		dumy,y_dumy,x_dumy		: integer;
		out_val				: vtype;
		redraw,ident			: boolean;
      begin
	redraw := false;
	reset_flag := true;
	if (inven_ctr > 0) then
	  begin
	    if (find_range([Wand],false,i2,i3)) then
	      begin
		if (get_item(item_ptr,'Aim which wand?',redraw,i3,trash_char,false)) then
		  with item_ptr^.data do
		    begin
		      if (redraw) then draw_cave;
		      reset_flag := false;
		      redraw := false;
		      y_dumy := char_row;
		      x_dumy := char_col;
		if (get_dir('Which direction?',dir,dumy,y_dumy,x_dumy)) then
			begin
			  if (py.flags.confused > 0) then
			    begin
			      msg_print('You are confused...');
			      repeat
				dir := randint(9);
			      until(dir <> 5);
			    end;
			  i1 := flags;
			  ident := false;
			  with py.misc do
			    chance := save + lev + spell_adj(iq) - level;
			  if (py.flags.confused > 0) then
			    chance := trunc(chance/2.0);
			  if (chance < 0) then chance := 0;
			  if (randint(chance) < use_device) then
			    msg_print('You failed to use the wand properly.')
			  else if (p1 > 0) then
			    begin
			      p1 := p1 - 1;
			      while (i1 > 0) do
				begin
				  i5 := bit_pos(i1);
				  i3 := char_row;
				  i4 := char_col;
	{ Wands							}
	case (i5) of
	  1  :	begin
		  msg_print('A line of blue shimmering light appears.');
		  light_line(dir,char_row,char_col,1);
		  ident := true;
		end;
	  2  :	begin
		  fire_bolt(c_lightning,dir,i3,i4,damroll('3d8')
			,'Lightning Bolt');
		  ident := true;
		end;
	  3  :	begin
		  fire_bolt(c_cold,dir,i3,i4,damroll('4d8'),'Frost Bolt');
		  ident := true;
		end;
	  4  :	begin
		  fire_bolt(c_fire,dir,i3,i4,damroll('6d8'),'Fire Bolt');
		  ident := true;
		end;
	  5  :	ident := wall_to_mud(dir,i3,i4);
	  6  :	ident := poly_monster(dir,i3,i4);
	  7  :	ident := zap_monster(dir,i3,i4,-damroll('4d6'),c_hp);
	  8  :	ident := zap_monster(dir,i3,i4,1,c_speed);
	  9  :	ident := zap_monster(dir,i3,i4,-1,c_speed);
	  10 :	ident := zap_monster(dir,i3,i4,0,c_confuse);
	  11 :	ident := zap_monster(dir,i3,i4,0,c_sleep);
	  12 :	ident := zap_monster(dir,i3,i4,50,c_drain);
	  13 :	ident := td_destroy2(dir,i3,i4);
	  14 :	begin
		  fire_bolt(0,dir,i3,i4,damroll('2d6'),'Magic Missile');
		  ident := true;
		end;
	  15 :	ident := build_wall(dir,i3,i4);
	  16 :	ident := clone_monster(dir,i3,i4);
	  17 :	ident := teleport_monster(dir,i3,i4);
	  18 :	ident := disarm_all(dir,i3,i4);
	  19 :	begin
		  fire_ball(c_lightning,dir,i3,i4,24,'Lightning Ball');
		  ident := true;
		end;
	  20 :	begin
		  fire_ball(c_cold,dir,i3,i4,32,'Cold Ball');
		  ident := true;
		end;
	  21 :	begin
 		  fire_ball(c_fire,dir,i3,i4,48,'Fire Ball');
 		  ident := true;
		end;
	  22 :	begin
		  fire_ball(c_gas,dir,i3,i4,8,'Stinking Cloud');
		  ident := true;
		end;
	  23 :	begin
		  fire_ball(c_acid,dir,i3,i4,40,'Acid Ball');
		  ident := true;
		end;
	  24 :	i1 := 2**(randint(24) - 1);
	  25 :  ident := zap_monster(dir,i3,i4,0,c_probe);
	  otherwise ;
	end;
	{ End of Wands...					}
				end;
			      if (ident) then
				identify(item_ptr^.data);
			      if (flags <> 0) then
				with py.misc do
				  begin
				    exp := exp + round(level/lev);
				    prt_experience;
				  end;
			      desc_charges(item_ptr);
			    end
			end
		    end
	      end
	    else
	      msg_print('You are not carrying any wands.');
	  end
	else
	  msg_print('But you are not carrying anything.');
	if (redraw) then draw_cave;
      end;
