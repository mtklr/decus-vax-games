	{ Eat some food...					-RAK-	}
[psect(misc2$code)] procedure eat;
      var
		i1				: unsigned;
		i3,i4,i5			: integer;
		i2,item_ptr			: treas_ptr;
		out_val				: vtype;
		redraw,ident			: boolean;
		tstat				: stat_set;
		dam_pts				: integer;
      begin
	reset_flag := true;
	if (inven_ctr > 0) then
	  begin
	    if (find_range([food,junk_food],false,i2,i3)) then
	      begin
		redraw := false;
		if (get_item(item_ptr,'Eat what?',redraw,i3,trash_char,false)) then
		  with item_ptr^.data do
		    begin
		      dam_pts := 0;
		      if (redraw) then draw_cave;
		      reset_flag := false;
		      i1 := flags;
		      ident := false;
		      while (i1 > 0) do
			begin
			  i4 := bit_pos(i1);
	{ Foods							}
	case (i4) of
	  1  :	with py.flags do
		  begin
		    poisoned := poisoned + randint(10) + level;
		    ident := true;
		  end;
	  2  :	with py.flags do
		  begin
		    blind := blind + randint(250) + 10*level + 100;
		    draw_cave;
		    msg_print('A veil of darkness surrounds you.');
		    ident := true;
		  end;
	  3  :	with py.flags do
		  begin
		    afraid := afraid + randint(10) + level;
		    msg_print('You feel terrified!');
		    ident := true;
		  end;
	  4  :	with py.flags do
		  begin
		    confused := confused + randint(10) + level;
		    msg_print('You feel drugged.');
		  end;
	  5  :	with py.flags do
		  image := image + randint(200) + 25*level + 200;
	  6  :	ident := cure_me(py.flags.poisoned);
	  7  :	ident := cure_me(py.flags.blind);
	  8  :	with py.flags do
		  if (afraid > 1) then
		    begin
		      afraid := 1;
		      ident := true;
		    end;
	  9  :	ident := cure_me(py.flags.confused);
 	  10 :	ident := lose_stat(sr,'X','X');
	  11 :	ident := lose_stat(cn,'X','X');
	  12 :	ident := lose_stat(iq,'X','X');
	  13 :	ident := lose_stat(ws,'X','X');
	  14 :	ident := lose_stat(dx,'X','X');
	  15 :	ident := lose_stat(ca,'X','X');
	  16 :  ident := restore_stat(sr,'You feel your strength returning.');
	  17 :  ident := restore_stat(cn,'X');
	  18 :  ident := restore_stat(iq,'Your head spins for a moment.');
	  19 :  ident := restore_stat(ws,'X');
	  20 :  ident := restore_stat(dx,'You feel more agile.');
	  21 :  ident := restore_stat(ca,'X');
	  22 :	dam_pts := dam_pts + randint(3);
	  23 :	dam_pts := dam_pts + randint(6);
	  24 :	dam_pts := dam_pts + randint(12);
	  25 :	dam_pts := dam_pts + damroll('2d12');
	  26 :	dam_pts := dam_pts + damroll('4d12');
	  27 :  dam_pts := dam_pts - randint(4);
	  28 :  dam_pts := dam_pts - randint(8);
	  29 :  ident := cure_me(py.flags.hoarse);
{ fill player to full, then adds food value }
	  30 :	begin
		  py.flags.food := player_food_full;
		  msg_print('Yum!');
		end;
	  31 : begin
		 i5 := bit_pos(flags2);
                 case (i5) of 
{crunchy}          1 : case randint(4) of 
                         1 : msg_print('*munch* *munch*');
                         2 : msg_print('*crunch* *crunch*');
			 3 : msg_print('*munch* *crunch*');
			 4 : msg_print('*crunch* *munch*');
			otherwise;
 		       end; {case 1}
{liquid}           2 : begin
		         case randint(3) of
			   1 : msg_print('*guzzle* *guzzle*');
			   2 : msg_print('*glug* *glug* *glug*');
			   3 : msg_print('*slurp*');
		          otherwise;
			 end;  {case}
 			 if (randint(3) = 1) then
		   	   begin
			     msg_print('*Burp*');
			     msg_print('(''scuse me....)');
			   end;  {Belch}
                       end; {case 2}
                 otherwise;
		 end;  {case}
	     end; {case 31}
	  otherwise;
	  if (dam_pts <> 0) then
	    ident := hp_player(dam_pts,'poisonous food.');
	end;
	{ End of food actions...				}
			end;
		      if (ident) then
			identify(item_ptr^.data);
		      if (flags <> 0) then
			with py.misc do
			  if (level > 0) then
			   begin
			    exp := exp + round(level/lev);
			    prt_experience;
			   end;
		      add_food(p1);
		      py.flags.status := uand(%X'FFFFFFFC',py.flags.status);
		      prt_hunger;
		      desc_remain(item_ptr);
		      inven_destroy(item_ptr);
		      prt_weight;
		    end
		else
		  if (redraw) then draw_cave;
	      end
	    else
	      msg_print('You are not carrying any food.');
	  end
	else
	  msg_print('But you are not carrying anything.');
      end;
