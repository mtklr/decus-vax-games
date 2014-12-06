[inherit('moria.env','dungeon.env')] module screen;

	{ Prints the map of the dungeon				-RAK-	}
[global,psect(screen1$code)] procedure prt_map;
    var
	i1,i2,i3,i4,i5	: integer;
	ypos,xpos,isp	: integer;
	floor_str	: vtype;
	tmp_char	: char;
	flag		: boolean;
    begin
      redraw := false;			{ Screen has been redrawn	}
      i3 := 1;				{ Used for erasing dirty lines	}
      i4 := 14;				{ Erasure starts in this column }
      for i1 := panel_row_min to panel_row_max do	{ Top to bottom }
	begin
	  i3 := i3 + 1;			{ Increment dirty line ctr	}
	  if (used_line[i3]) then	{ If line is dirty...		}
	    begin
	      erase_line(i3,i4);	{ erase it.			}
	      used_line[i3] := false;	{ Now it's a clean line		}
	    end;
	  floor_str := '';		{ Floor_str is string to be printed}
	  ypos := i1;			{ Save row			}
	  flag := false;		{ False until floor_str <> ''	}
	  isp := 0;			{ Number of blanks encountered	}
	  for i2 := panel_col_min to panel_col_max do	{ Left to right }
	    with cave[i1,i2] do
	      begin			{ Get character for location	}
		if (test_light(i1,i2)) then
		  loc_symbol(i1,i2,tmp_char)
		else if ((cptr = 1) and (not(find_flag))) then
		  tmp_char := '@'
		else if (cptr > 1) then
		  if (m_list[cptr].ml) then
		    loc_symbol(i1,i2,tmp_char)
		  else
		    tmp_char := ' '
		else
		  tmp_char := ' ';
		if (tmp_char = ' ') then{ If blank...			}
		  begin
		    if (flag) then	{ If floor_str <> '' then	}
		      begin
			isp := isp + 1; { Increment blank ctr		}
			if (isp > 3) then	{ Too many blanks, print}
			  begin			{ floor_str and reset	}
			    print(floor_str,ypos,xpos);
			    flag := false;
			    isp := 0;
			  end;
		      end
		  end
		else
		  begin
		    if (flag) then	{ Floor_str <> ''		}
		      begin
			if (isp > 0) then	{ Add on the blanks	}
			  begin
			    for i5 := 1 to isp do
			      floor_str := floor_str + ' ';
			    isp := 0;
			  end;			{ Add on the character	}
			floor_str := floor_str + tmp_char;
		      end
		    else
		      begin		{ Floor_str = ''		}
			xpos := i2;	{ Save column for printing	}
			flag := true;	{ Set flag to true		}
			floor_str := tmp_char;	{ Floor_str <> ''	}
		      end;
		  end;
	      end;
	  if (flag) then		{ Print remainder, if any	}
	    print(floor_str,ypos,xpos);
	end;
    end;


	{ Print character stat in given row, column		-RAK-	}
[global,psect(screen$code)] procedure prt_stat(
			stat_name	: vtype;
			stat		: byteint;
			row,column	: integer);
      var
		out_val1		: stat_type;
		out_val2		: vtype;
      begin
	cnv_stat(stat,out_val1);
	out_val2 := stat_name + out_val1;
	put_buffer(out_val2,row,column);
      end;

	{ Print character info in given row, column		-RAK-	}
[global,psect(screen$code)] procedure prt_field(info : vtype; row,column : integer);
      var
		out_val1,out_val2	: vtype;
      begin
	put_buffer(pad(info,' ',14),row,column);
      end;

	{ Print number with header at given row, column		-RAK-	}
[global,psect(screen$code)] procedure prt_num(
			header		:	vtype;
			num,row,column	:	integer);
      var
		out_val			: vtype;
      begin
	writev(out_val,header,num:1,'  ');
	put_buffer(out_val,row,column);
      end;

	{ Prints title of character's level			-RAK-	}
[global,psect(screen1$code)] procedure prt_title;
    begin
      prt_field(py.misc.title,title_row,stat_column);
    end;

	{ Prints stat (str..cha) in correct row		-STEVEN-	}
[global,psect(screen1$code)] procedure prt_a_stat(tstat : stat_set);
    begin
      prt_stat('',py.stat.c[tstat],str_row+ord(tstat),stat_column+6);
    end;

	{ Prints level						-RAK-	}
[global,psect(screen1$code)] procedure prt_level;
    begin
      prt_num( '',py.misc.lev,level_row,stat_column+6);
    end;

	{ Prints player's mana					-DCJ-	}
[global,psect(moria$code)] procedure prt_mana;
      var
		out_val			: vtype;
    begin
      writev(out_val,trunc(py.misc.cmana):1,'/',py.misc.mana:1,' ');
      if ( length(out_val) < 8 ) then out_val := pad(out_val, ' ', 8) ;
      put_buffer(out_val,mana_row,stat_column+6);
    end;

	{ Prints hit points					-DCJ-	}
[global,psect(moria$code)] procedure prt_hp;
      var
		out_val			: vtype;
    begin
      writev(out_val,trunc(py.misc.chp):1,'/',py.misc.mhp:1,' ');
      if ( length(out_val) < 8 ) then out_val := pad(out_val, ' ', 8) ;
      put_buffer(out_val,hp_row,stat_column+6);
    end;

	{ Prints current AC					-RAK-	}
[global,psect(screen2$code)] procedure prt_pac;
    begin
      prt_num( '',py.misc.dis_ac,ac_row,stat_column+6);
    end;

	{ Prints current gold					-RAK-	}
[global,psect(screen2$code)] procedure prt_gold;
    begin
      prt_num( '',py.misc.money[total$],gold_row,stat_column+6);
    end;

	{ Prints current inventory weight			-DCJ-	}
[global,psect(screen2$code)] procedure prt_weight;
    begin
      prt_num('',inven_weight div 100,weight_row,stat_column+6);
      prt_num('',weight_limit,weight_row+1,stat_column+6);
    end;

	{ Print time of game day				-DMF-	}
[global,psect(screen1$code)] procedure prt_time;
    begin
      with py.misc.cur_age do
	put_buffer(time_string(hour,secs)+' '+day_of_week_string(day,2)+' '+
		   place_string(day),time_row,stat_column);
    end;

	{ Prints depth in stat area				-RAK-	}
[global,psect(screen1$code)] procedure prt_depth;
      var
		depths	: vtype;
		depth	: integer;
      begin
	depth := dun_level*50;
	if (depth = 0) then
	  depths := 'Town level'
	else if (depth < 10000) then
	  writev(depths,'Depth: ',depth:1,' (feet)')
        else writev(depths,'Depth: ',depth:1,'   ');
	prt(depths,status_row,depth_column);
      end;

	{ Prints status of hunger				-RAK-	}
[global,psect(screen1$code)] procedure prt_hunger;
    begin
      if (uand(%X'000002',py.flags.status) <> 0) then
	put_buffer('Weak    ',status_row,hunger_column)
      else if (uand(%X'000001',py.flags.status) <> 0) then
	put_buffer('Hungry  ',status_row,hunger_column)
      else
	put_buffer('        ',status_row,hunger_column);
    end;

	{ Prints Blind status					-RAK-	}
[global,psect(screen1$code)] procedure prt_blind;
    begin
      if (uand(%X'000004',py.flags.status) <> 0) then
	put_buffer('Blind  ',status_row,blind_column)
      else
	put_buffer('       ',status_row,blind_column);
    end;

	{ Prints Confusion status				-RAK-	}
[global,psect(screen1$code)] procedure prt_confused;
    begin
      if (uand(%X'000008',py.flags.status) <> 0) then
	put_buffer('Confused  ',status_row,confused_column)
      else
	put_buffer('          ',status_row,confused_column);
    end;

	{ Prints Fear status					-RAK-	}
[global,psect(screen1$code)] procedure prt_afraid;
    begin
      if (uand(%X'000010',py.flags.status) <> 0) then
	put_buffer('Afraid  ',status_row,afraid_column)
      else
	put_buffer('        ',status_row,afraid_column);
    end;

	{ Prints Poisoned status				-RAK-	}
[global,psect(screen1$code)] procedure prt_poisoned;
    begin
      if (uand(%X'000020',py.flags.status) <> 0) then
	put_buffer('Poisoned  ',status_row,poisoned_column)
      else
	put_buffer('          ',status_row,poisoned_column);
    end;

	{ Prints Searching status				-RAK-	}
[global,psect(screen1$code)] procedure prt_search;
    begin
      if (uand(%X'000100',py.flags.status) <> 0) then
	put_buffer('Searching',status_row,searching_column)
      else
	put_buffer('         ',status_row,searching_column);
    end;

	{ Prints Resting status					-RAK-	}
[global,psect(screen1$code)] procedure prt_rest;
    begin
      if (uand(%X'000200',py.flags.status) <> 0) then
	put_buffer('Resting  ',status_row,resting_column)
      else
	put_buffer('         ',status_row,resting_column);
    end;

	{ Prints Quested status					-RAD-	}
[global,psect(screen1$code)] procedure prt_quested;
    begin
      if (py.flags.quested) then 
	put_buffer(' Quest  ',status_row,quested_column)
      else if (py.misc.cur_quest > 0) then
 	put_buffer('  Done  ',status_row,quested_column)
      else 
        put_buffer('        ',status_row,quested_column);
    end;

	{ Prints winner status on display			-RAK-	}
[global,psect(screen1$code)] procedure prt_winner;
    begin
      put_buffer('*Winner*',winner_row,winner_column);
    end;

[global,psect(screen2$code)] procedure prt_experience;
  var
	tmp_exp		: integer;
    begin
      with py.misc do
	begin
	  if (exp > player_max_exp) then exp := player_max_exp;
	  if (lev < max_player_level) then
	    begin
	      while (trunc(player_exp[lev]*expfact) <= exp) do gain_level;
	      if (exp > max_exp) then max_exp := exp;
	    end;
	end;
      prt_num('',py.misc.exp,exp_row,stat_column+6);
    end;

[global,psect(screen1$code)] procedure prt_6_stats(p : stat_s_type;
						row,col : byteint);
    begin
	prt_stat('STR : ',p[sr],row  ,col);
	prt_stat('INT : ',p[iq],row+1,col);
	prt_stat('WIS : ',p[ws],row+2,col);
	prt_stat('DEX : ',p[dx],row+3,col);
	prt_stat('CON : ',p[cn],row+4,col);
	prt_stat('CHR : ',p[ca],row+5,col);
    end;

	{ Prints character-screen info				-RAK-	}
[global,psect(screen1$code)] procedure prt_stat_block;
    begin
      prt_field(py.misc.race,		     race_row,stat_column);
      prt_field(py.misc.tclass,		     class_row,stat_column);
      prt_title;
      prt_6_stats(py.stat.c,str_row,stat_column);
      prt_num( 'LEV : ',py.misc.lev,	     level_row,stat_column);
      prt_num( 'EXP : ',py.misc.exp,	     exp_row,stat_column);
      if is_magii then
	begin
	  prt_field('MANA: ',		     mana_row,stat_column);
	  prt_mana;
	end;
      prt_field('HP  : ',		     hp_row,stat_column);
      prt_hp;
      prt_num( 'QST : ',py.misc.quests,      quest_row,stat_column);
      prt_num( 'AC  : ',py.misc.dis_ac,	     ac_row,stat_column);
      prt_num( 'GOLD: ',py.misc.money[total$], gold_row,stat_column);
      prt_field('WGHT:',		     weight_row,stat_column);
      prt_field('M_WT:',		     weight_row+1,stat_column);
      prt_weight;
      prt_time;
      if (total_winner) then prt_winner;
      prt_hunger; {'If' statements here redundant and unnecessary, so}
      prt_blind;  { removed per Dean's suggestion                -MAV}
      prt_confused;
      prt_afraid;
      prt_poisoned;
      prt_search;
      prt_rest;
      prt_quested;
    end;

	{ Draws entire screen					-RAK-	}
[global,psect(screen1$code)] procedure draw_cave;
    begin
      clear(1,1);
      prt_stat_block;
      prt_map;
      prt_depth;
      prt_search;
    end;
end.
