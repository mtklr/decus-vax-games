[inherit('moria.env','dungeon.env')] module player;

	{ Moves player from one space to another...		-RAK-	}
    [global,psect(creature$code)] procedure move_char(dir : integer);
      var
		test_row,test_col       : integer;
		panrow,pancol           : integer;
		i1,i2                   : integer;
      begin
	test_row := char_row;
	test_col := char_col;
	if (dir=5) then find_flag:=false;
	if (py.flags.confused > 0) then         { Confused?             }
	  if (randint(4) > 1) then              { 75% random movement   }
	    if (dir <> 5) then                  { Never random if sitting}
	      begin
		dir := randint(9);
		find_flag := false;
	      end;
	if (move(dir,test_row,test_col)) then   { Legal move?           }
	  with cave[test_row,test_col] do
	    if (cptr < 2) then                  { No creature?          }
	      begin
		if (fopen) then                 { Open floor spot       }
		  if ((find_flag) and
		      ((cave[char_row,char_col].fval in earth_set) =
			(cave[test_row,test_col].fval in water_set))) then
		    begin
		      find_flag := false;
		      move_char(5);
		    end
		  else
		  begin
			{ Move character record (-1)            }
		    move_rec(char_row,char_col,test_row,test_col);
			{ Check for new panel                   }
		    if (get_panel(test_row,test_col)) then
		      prt_map;
			{ Check to see if he should stop        }
		    if (find_flag) then
		      area_affect(dir,test_row,test_col);
			{ Check to see if he notices something  }
		    if (py.flags.blind < 1) then
		      if ((randint(py.misc.fos) = 1) or (search_flag)) then
			search(test_row,test_col,py.misc.srh);
			{ An object is beneath him...           }
		    if (tptr > 0) then
		      carry(test_row,test_col);
			{ Move the light source                 }
		    move_light(char_row,char_col,test_row,test_col);
			{ A room of light should be lit...      }
		    if (fval = lopen_floor.ftval) then
		      begin
			if (py.flags.blind < 1) then
			  if (not(pl)) then
			    light_room(test_row,test_col);
		      end
			{ In doorway of light-room?             }
		    else if (fval in [5,6]) then
		      if (py.flags.blind < 1) then
			begin
			  for i1 := (test_row - 1) to (test_row + 1) do
			    for i2 := (test_col - 1) to (test_col + 1) do
			      if (in_bounds(i1,i2)) then
				with cave[i1,i2] do
				  if (fval = lopen_floor.ftval) then
				    if (not(pl)) then
				      light_room(i1,i2);
			end;
			{ Make final assignments of char co-ords}
		    char_row := test_row;
		    char_col := test_col;
		  end
		else    {Can't move onto floor space}
			{ Try a new direction if in find mode   }
		  if (not(pick_dir(dir))) then
		    begin
		      if (find_flag) then
			begin
			  find_flag := false;
			  move_char(5);
			end
		      else if (tptr > 0) then
			begin
			  reset_flag := true;
			  if (t_list[tptr].tval = Rubble) then
			    msg_print('There is rubble blocking your way.')
			  else if (t_list[tptr].tval = Closed_door) then
			    msg_print('There is a closed door blocking your way.');
			end
		      else
			reset_flag := true;
		    end
	      end
	    else        { Attacking a creature! }
	      begin
		if (find_flag) then
		  begin
		    find_flag := false;
		    move_light(char_row,char_col,char_row,char_col);
		  end;
		if (py.flags.afraid < 1) then   { Coward?       }
		  py_attack(test_row,test_col)
		else                            { Coward!       }
		  msg_print('You are too afraid!');
	      end
      end;


    [global,psect(moria$code)] procedure search_off;
      begin
	search_flag := false;
	find_flag := false;
	move_char(5);
	change_speed(-1);
	py.flags.status := uand(py.flags.status,%X'FFFFFEFF');
	prt_search;
	with py.flags do
	  food_digested := food_digested - 1;
      end;

    [global,psect(moria$code)] procedure rest_off;
      begin
	py.flags.rest := 0;
	py.flags.status := uand(py.flags.status,%X'FFFFFDFF');
	erase_line(1,1);
	prt_rest;
	with py.flags do
	  food_digested := food_digested + 1;
      end;

	{ Decreases players hit points and sets death flag if neccessary}
    [global,psect(moria$code)] procedure take_hit(damage : integer; hit_from : vtype);
      begin
	if (py.flags.invuln > 0) then damage := 0;
	py.misc.chp := py.misc.chp - damage;
	if (search_flag) then search_off;
	if (py.flags.rest > 0) then rest_off;
	flush;
	if (py.misc.chp <= -1) then
	  begin
	    if (not(death)) then
	      begin             { Hee, hee... Ain't I mean?     }
		death := true;
		died_from := hit_from;
		total_winner := false;
	      end;
	    moria_flag := true;
	  end
	else
	  prt_hp;
      end;

	{ Regenerate hit points					-RAK-	}
    [global,psect(moria$code)] procedure regenhp(percent : real);
      begin
	with py.misc do
	  chp := chp + mhp*percent + player$regen_hpbase;
      end;

	{ Regenerate mana points				-RAK-	}
    [global,psect(moria$code)] procedure regenmana(percent : real);
      begin
	with py.misc do
	  cmana := cmana + mana*percent + player$regen_mnbase;
      end;

end.
