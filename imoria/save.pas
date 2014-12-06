[Inherit('Moria.Env')] Module Save;

[external] procedure sub_quadtime(a,b,c : [reference] quad_type); extern;

	{ This save package was brought to by			-JWT-
	  and                                                   -RAK-   }

	{ Data Corruption means character is dead, or save file was -RAK-
	  screwed with.  Keep them guessing as to what is actually wrong.}
[global,psect(save$code)] procedure data_exception;
      begin
	clear(1,1);
	prt('Data Corruption Error.',1,1);
	prt('',2,1);
	exit;
      end;


	{ Uses XOR function to encode data			-RAK-	}
[global,psect(save$code)] procedure coder(var line : ntype);
      var
		i1                      : integer;
		i2,i3,i4                : unsigned;
      begin
	for i1 := 1 to length(line) do
	  begin
	    i2 := uint(ord(line[i1]));
	    i3 := uint(randint(256)-1);
	    i4 := uxor(i2,i3);
	    line[i1] := chr(i4);
	  end;
      end;


	{ Encrypts a line of text, complete with a data-check sum-RAK-	}
	{ (original by JWT)                                             }
[global,psect(save$code)] procedure encrypt(var line : ntype);
      var
	i1,i2           : integer;
	temp            : ntype;

      begin
	i2 := 0;
	for i1 := 1 to length(line) do
	  i2 := i2 + ord(line[i1]) + i1;
	temp := line;
	writev(line,i2:1,' ',temp);
	coder(line);
      end;


	{ Decrypts a line of text, complete with a data-check sum-RAK-	}
	{ (original by JWT)                                             }

	{ 87/05/11	Modified to continue on readv error.	-KC-	}

[global,psect(save$code)] procedure decrypt(var line : ntype);
      var
	i1,i2,i3        : integer;
	temp            : ntype;
	tmp             : char;
	original	: ntype;

      begin
	i2 := 0;
	original := line;
	coder(line);
	temp := line;
	readv(temp,i3,tmp,line,error:=continue);
	for i1 := 1 to length(line) do
	  i2 := i2 + ord(line[i1]) + i1;
	if (i2 <> i3) then data_exception;
      end;


	{ Actual save procedure 			-RAK- & -JWT-	}
[global,psect(save$code)] function save_char(quick : boolean) : boolean;

      var
	tot_monsters,tot_treasure		: integer;
	i1,i2,trys,spot				: integer;
	xfloor					: unsigned;
	save_seed				: unsigned;
	fnam					: vtype;
	out_rec,title1,title2			: ntype;
	f1					: text;
	f2					: file of key_type;
	flag,file_flag				: boolean;
	tstat					: stat_set;
	curse					: treas_ptr;
	current_time,delta_time			: quad_type;
	tim					: time_type;

    procedure encrypt_write (var line : ntype);
      begin
	encrypt(line);
        writeln(f1,line,error:=continue)
      end;

      begin
	if py.flags.dead or quick then
	  begin
	    flag := true;
	    if (is_from_file) then
	      open(f1,file_name:=finam,record_length:=1024,history:=old,
		      error:=continue)
	    else
	      open(f1,file_name:=finam,record_length:=1024,history:=new,
		      error:=continue);
	  end
	else
	  begin
	    prt('Enter Filename:',1,1);
	    flag := false;
	    { Open the user's save file                             -JWT-   }
	    if (get_string(fnam,1,17,60)) then
	      begin
	        if (length(fnam) = 0) then fnam := finam;
	        if (is_from_file) and (fnam = finam) then
		  open (f1,FILE_NAME:=fnam,record_length:=1024,history:=old,
				ERROR:=continue)
		else
		  open (f1,FILE_NAME:=fnam,record_length:=1024,history:=new,
				ERROR:=continue);
	        if (status(f1) <> 0) then
	          msg_print('Error creating> ' + fnam)
	        else
	          flag := true;
	      end;
	  end;
	delete_file(fnam);
	{ Make an attempt to open the MASTER file               -JWT-   }
	if (flag) then
	  begin
	    rewrite(f1,error:=continue);
	    priv_switch(1);
	    open (f2,file_name:=moria_mas,
		    error:=continue,access_method:=keyed,organization:=indexed,
		    history:=old,sharing:=readwrite);
	    if (status(f2) <> 0) then
	      begin
		priv_switch(0);
		open (f2,file_name:=moria_mas,
			error:=continue,access_method:=keyed,
			organization:=indexed,history:=new,sharing:=readwrite);
	      end;
	      if (status(f2) <> 0) then
		begin
		  msg_print('Error saving character, contact MORIA Wizard.');
		  close(f1,error:=continue);
		  flag := false;
		end;
	  end;
	{ Write social security number to MASTER		-KRC-	}
	if (flag) then
	  begin
	    spot := ord(py.misc.ssn[70]);
	    trys := 1;
	    file_flag := false;
	    repeat
	      if (spot < 32) or (spot > 116) then spot := 32;
	      py.misc.ssn[70] := chr(spot+trys);
	      title1 := py.misc.ssn;
	      seed := encrypt_seed1;
	      coder(title1);
	      for i1 := 1 to 70 do
		key_rec.file_id[i1] := title1[i1];
	      f2^ := key_rec;
	      put(f2,error:=continue);
	      if (status(f2) <> 0) then
		begin
		  trys := trys + 1;
		  if (trys > 10) then
		    begin
		      file_flag := true;
		      flag := false;
		      msg_print('Error in writing to MASTER.');
		    end;
		end
	      else
		file_flag := true;
	    until(file_flag);
	    close(f2,error:=continue);
	    priv_switch(0);
	  end;
	{ If ID was written to MASTER, continue saving          -RAK-   }
	if (flag) then
	  begin
	    save_seed := get_seed;
	    writev(title2,save_seed:12,' ',py.misc.ssn);
	    seed := encrypt_seed2;
	    encrypt_write(title2);
	    seed := save_seed;
		{ Message to player on what is happening}
	    if not py.flags.dead then
	      begin
		clear(1,1);
	        if not(quick) then put_qio
		  else fnam := finam;
		prt('Saving character in '+fnam+'...',1,1);
	      end;
		{ Version number of Moria               }
	    writev(out_rec,cur_version);
	    encrypt_write(out_rec);
		{ Write out the player record.	}
	    with py.misc do                              
	      begin
		writev(out_rec,xtr_wgt:1,' ',account:1,' ',money[0]:1,' ',
money[6]:1,' ',money[5]:1,' ',money[4]:1,' ',money[3]:1,' ',money[2]:1,' ',
money[1]:1,' ',diffic:1);
		encrypt_write(out_rec);

		with py.misc.birth do
		  writev(out_rec,year:1,' ',month:1,' ',day:1,' ',hour:1,' ',
				 secs:1);
		encrypt_write(out_rec);

		with py.misc.cur_age do
		  writev(out_rec,year:1,' ',month:1,' ',day:1,' ',hour:1,' ',
				 secs:1);
		encrypt_write(out_rec);

{FUBAR modification for quests}
		writev(out_rec,py.flags.quested,' ',py.misc.cur_quest:1,' ',
py.misc.quests:1);
		encrypt_write(out_rec);

		sys$gettim(current_time);
		sub_quadtime(current_time,start_time,delta_time);
		sys$numtim(tim,delta_time);
		add_play_time(tim,py.misc.play_tm);
		with tim do
		  writev(out_rec,years:1,' ',months:1,' ',days:1,' ',hours:1,
				 ' ',minutes:1,' ',seconds:1,' ',hundredths:1);
		encrypt_write(out_rec);

		writev(out_rec,name);
		encrypt_write(out_rec);

		writev(out_rec,race);
		encrypt_write(out_rec);

		writev(out_rec,sex);
		encrypt_write(out_rec);

		writev(out_rec,tclass);
		encrypt_write(out_rec);

		writev(out_rec,title);
		encrypt_write(out_rec);

		for i1 := 1 to 5 do
		  begin
		    out_rec := history[i1];
		    encrypt_write(out_rec);
		  end;

		writev(out_rec,cheated);
		encrypt_write(out_rec);

		writev(out_rec,char_row:1,' ',char_col:1,' ',
		  pclass:1,' ',prace:1,' ',
		  age:1,' ',ht:1,' ',wt:1,' ',sc:1,' ',max_exp:1,' ',
		  exp:1,' ',rep:1,' ',deaths:1,' ',premium:1,' ',lev:1,' ',
		  max_lev:1,' ',expfact:2:1);
		encrypt_write(out_rec);

		writev(out_rec,srh:1,' ',fos:1,' ',stl:1,' ',bth:1,' ',
		  bthb:1,' ',
		  mana:1,' ',cmana:1,' ',mhp:1,' ',chp:1:1,' ',
		  ptohit:1,' ',ptodam:1,' ',pac:1,' ',ptoac:1,' ',
		  dis_th:1,' ',dis_td:1,' ',dis_ac:1,' ',dis_tac:1,' ',
		  disarm:1,' ',save:1,' ',hitdie:1);
		encrypt_write(out_rec);

                {change by Dean--inven_ctr calculated from scratch to
                 (hopefully) solve some of the get-after-EOF save bugs}
		inven_ctr:=0;
		curse:=inventory_list;
		while (curse<>nil) do
		  begin
		    curse := curse^.next;
		    inven_ctr := inven_ctr + 1;
		  end;
		writev(out_rec,inven_ctr:1,' ',
		  inven_weight:1,' ',equip_ctr:1,' ',dun_level:1,' ',
		  missle_ctr:1,' ',mon_tot_mult:1,' ',uand(%X'F',turn):1,
		  ' ',randes_seed:12);
		encrypt_write(out_rec);
	      end;

	    with py.flags do
	      begin
		writev(out_rec,insured:1,' ',dead:1);
		encrypt_write(out_rec);
	      end;

		{ Write out the inventory records.	}
	    curse := inventory_list;
	    while (curse <> nil) do
	      begin
		writev(out_rec,curse^.data.tchar,curse^.data.name);
		encrypt_write(out_rec);

		writev(out_rec,curse^.is_in:1,curse^.insides:1);
		encrypt_write(out_rec);

		writev(out_rec,curse^.data.damage);
		encrypt_write(out_rec);

		with curse^.data do
		  writev(out_rec,tval:1,' ',subval:1,' ',weight:1,' ',
			number:1,' ',tohit:1,' ',todam:1,' ',ac:1,' ',
			toac:1,' ',p1:1,' ',flags:1,' ',flags2:1,' ',
			level:1,' ',cost:1);
		encrypt_write(out_rec);
		curse := curse^.next;
	      end;

		{ Write out the equipment records.	}
	    for i1 := Equipment_min to equip_max-1 do
	      begin
		writev(out_rec,equipment[i1].tchar,equipment[i1].name);
		encrypt_write(out_rec);

		writev(out_rec,equipment[i1].damage);
		encrypt_write(out_rec);
		with equipment[i1] do
		  writev(out_rec,tval:1,' ',subval:1,' ',weight:1,' ',
			number:1,' ',tohit:1,' ',todam:1,' ',ac:1,' ',
			toac:1,' ',p1:1,' ',flags:1,' ',flags2:1,' ',
			level:1,' ',cost:1);
		encrypt_write(out_rec);
	      end;
	
	    with py.stat do
		begin

		  writev(out_rec,p[sr]:1,' ',c[sr]:1,' ',m[sr]:1,' ',l[sr]:1,
			' ',p[iq]:1,' ',c[iq]:1,' ',m[iq]:1,' ',l[iq]:1,
			' ',p[ws]:1,' ',c[ws]:1,' ',m[ws]:1,' ',l[ws]:1,
			' ',p[dx]:1,' ',c[dx]:1,' ',m[dx]:1,' ',l[dx]:1,
			' ',p[cn]:1,' ',c[cn]:1,' ',m[cn]:1,' ',l[cn]:1,
			' ',p[ca]:1,' ',c[ca]:1,' ',m[ca]:1,' ',l[ca]:1);
		encrypt_write(out_rec);
	      end;

	    with py.flags do
	      begin
		writev(out_rec,status:1,' ',blind:1,' ',confused:1,' ',
			food:1,' ',food_digested:1,' ',protection:1,' ',
			speed:1,' ',afraid:1,' ',
			poisoned:1,' ',see_inv:1);
		encrypt_write(out_rec);

		writev(out_rec,fast:1,' ',slow:1,' ',protevil:1,' ',
			teleport:1,' ',free_act:1,' ',slow_digest:1,' ',
			petrification:1);
		encrypt_write(out_rec);

		writev(out_rec,aggravate:1,' ',sustain[sr]:1,' ',
			sustain[iq]:1,' ',sustain[ws]:1,' ',sustain[cn]:1,
			' ',sustain[dx]:1,' ',sustain[ca]:1);
		encrypt_write(out_rec);

		writev(out_rec,fire_resist:1,' ',cold_resist:1,' ',
			acid_resist:1,' ',regenerate:1,' ',lght_resist:1,' ',
			ffall:1,' ',confuse_monster:1);
		encrypt_write(out_rec);

		writev(out_rec,image:1,' ',invuln:1,' ',hero:1,' ',
			shero:1,' ',blessed:1,' ',
			resist_heat:1,' ',resist_cold:1,' ',detect_inv:1,' ',
			word_recall:1,' ',see_infra:1,' ',tim_infra:1);
		encrypt_write(out_rec);

		writev(out_rec,resist_lght:1,' ',free_time:1,' ',ring_fire:1,
			' ',protmon:1,' ',hoarse:1,' ',magic_prot:1,' ',
			ring_ice:1,' ',temp_stealth:1,' ',resist_petri:1,' ',
			blade_ring:1);
		encrypt_write(out_rec);
	      end;

	    for i1 := 1 to max_spells do
	      with magic_spell[py.misc.pclass,i1] do
		begin
		  writev(out_rec,learned:5,' ',sexp:5);
		  encrypt_write(out_rec);
		end;

		{ Write the important dungeon info and floor	-RAK-	}
	    begin
	      writev(out_rec,cur_height:1,' ',cur_width:1,' ',
		max_panel_rows:1,' ',max_panel_cols:1);
	      encrypt_write(out_rec);

		{ Save the floor	}
	      tot_treasure := 0;
	      for i1 := 1 to cur_height do
		begin
		  out_rec := pad(' ',' ',cur_width);
		  for i2 := 1 to cur_width do
		    begin
		      with cave[i1,i2] do
			begin
			  xfloor := fval;
			  if (fopen) then
			    xfloor := uor(xfloor,%X'20');
			  if (pl) then
			    xfloor := uor(xfloor,%X'40');
			  if (fm) then
			    xfloor := uor(xfloor,%X'80');
			  out_rec[i2] := chr(xfloor);
			  if (tptr > 0) then
			    tot_treasure := tot_treasure + 1;
			end;
		    end;
		  encrypt_write(out_rec);
		end;

		{ Save the Treasure List		}
	      writev(out_rec,tot_treasure:1);
	      encrypt_write(out_rec);
	      for i1 := 1 to cur_height do
		for i2 := 1 to cur_width do
		  if (cave[i1,i2].tptr > 0) then
		    with t_list[cave[i1,i2].tptr] do
		      begin
			writev(out_rec,i1:1,' ',i2:1);
			encrypt_write(out_rec);

			writev(out_rec,tchar,name);
			encrypt_write(out_rec);

			writev(out_rec,damage);
			encrypt_write(out_rec);

			writev(out_rec,tval:1,' ',subval:1,' ',weight:1,' ',
			  number:1,' ',tohit:1,' ',todam:1,' ',ac:1,' ',
			  toac:1,' ',p1:1,' ',flags:1,' ',flags2:1,' ',
			  level:1,' ',cost:1);
			encrypt_write(out_rec);
		      end;

		{ Save identified list			}
	      out_rec := '';
	      for i1 := 1 to max_objects do
		begin
		  if (object_ident[i1]) then
		    out_rec := out_rec + 'T'
		  else
		    out_rec := out_rec + 'F';
		end;
	      encrypt_write(out_rec);

		{ Save the Monster List 		}
	      i1 := muptr;
	      tot_monsters := 0;
	      if (i1 > 0) then
		repeat
		  tot_monsters := tot_monsters + 1;
		  with m_list[i1] do
		    i1 := nptr;
		until (i1 = 0);
	      writev(out_rec,tot_monsters:1);
	      encrypt_write(out_rec);
	      i1 := muptr;
	      if (i1 > 0) then
		repeat
		  with m_list[i1] do
		    begin
		      writev(out_rec,fy:1,' ',fx:1,' ',mptr:1,' ',hp:1,
			' ',cspeed:1,' ',csleep:1,' ',cdis:1,' ',ml:1,
			' ',confused:1);
		      encrypt_write(out_rec);
		      i1 := nptr;
		    end;
		until (i1 = 0);

		{ Save the town level stores		}
	      writev(out_rec,town_seed:12);
	      encrypt_write(out_rec);
	      writev(out_rec,bank[0]:1,' ',bank[6]:1,' ',bank[5]:1,' ',
		bank[4]:1,' ',bank[3]:1,' ',bank[2]:1,' ',bank[1]:1);
	      encrypt_write(out_rec);
	      for i1 := 1 to max_stores do
		with store[i1] do
		  begin
		{ Save items...                 }
		    writev(out_rec,store_ctr:1);
		    encrypt_write(out_rec);                
		    for i2 := 1 to store_ctr do
		      with store_inven[i2].sitem do
			begin
			  writev(out_rec,store_inven[i2].scost);
			  encrypt_write(out_rec);
			  writev(out_rec,tchar,name);
			  encrypt_write(out_rec);
			  writev(out_rec,damage);
			  encrypt_write(out_rec);

			  writev(out_rec,tval:1,' ',subval:1,' ',weight:1,
				' ',number:1,' ',tohit:1,' ',todam:1,' ',
				ac:1,' ',toac:1,' ',p1:1,' ',flags:1,' ',
				flags2:1,' ',level:1,' ',cost:1);
			  encrypt_write(out_rec);
			end;
		    with store_open do
		      with py.misc do
			if ((cur_age.year > year) or
			    ((cur_age.year = year) and
			     ((cur_age.month > month) or
			      ((cur_age.month = month) and
			       ((cur_age.day > day) or
				((cur_age.day = day) and
				 ((cur_age.hour > hour) or
				  ((cur_age.hour = hour) and
				   ((cur_age.secs > secs)))))))))) then
			  begin
			    year := 0;
			    month := 0;
			    day := 0;
			    secs := 0;
			  end;
		    with store_open do
		      writev(out_rec,owner:1,' ',insult_cur:1,' ',year:1,' ',
				     month:1,' ',day:1,' ',hour:1,' ',secs:1);
		    encrypt_write(out_rec);
		  end;
	    end;
	    close(f1,error:=continue);
	  end;
	if (flag and not py.flags.dead) then
	  begin
	    writev(out_rec,'Character saved. [Moria Version ',
						cur_version:5:2,']');
	    prt(out_rec,2,1);
	    exit;
	  end;
	save_char := flag;
	seed := get_seed;
      end;


	{ Restore a saved game				-RAK- & -JWT-	}
[global,psect(save$code)] function get_char(fnam : vtype; prop : boolean) : boolean;
      label
	panic;       
      var
	tot_treasures,tot_monsters              : integer;
	i1,i2,i3,i4,dummy                       : integer;
	xfloor,save_seed                        : unsigned;
	save_version                            : real;
	in_rec,temp                             : ntype;
	temp_id					: ssn_type;
	f1                                      : text;
	f2                                      : file of key_type;
	dun_flag                                : boolean;
	cheated					: boolean;
	n_stores				: integer;
	was_dead,bag_lost,paniced		: boolean;
	lost_inven_count,lost_equip_count	: integer;
	ptr,curse,cur_bag			: treas_ptr;
	trash_char				: char;

  procedure read_decrypt (var line:ntype);
    begin
      readln(f1,line);
      decrypt(line)
    end;

  procedure add_item; {Extensive clarifications and bug fixes here by Dean}
    begin
      new(ptr);
      if (inventory_list = nil) then
	inventory_list := ptr
      else
	begin
          curse := inventory_list;
          while (curse^.next <> nil) do
		curse := curse^.next;
          curse^.next := ptr;
	end;
      ptr^.data := inven_temp^.data;
      ptr^.is_in := inven_temp^.is_in;
      ptr^.insides := inven_temp^.insides;
      ptr^.ok := false;
      ptr^.next := nil;
      if (ptr^.data.tval = bag_or_sack) then cur_bag := ptr;
      if (ptr^.is_in) and (cur_bag <> nil) then
	cur_bag^.insides := cur_bag^.insides + 1;
    end;

      begin
	dun_flag := false;
	paniced := false;
	clear(1,1);
	open (f1,FILE_NAME:=fnam,record_length:=1024,ERROR:=continue,
		HISTORY:=OLD);
	if (status(f1) <> 0) then
	  begin
	    prt('Error Opening> '+fnam,1,1);
	    prt('',2,1);
	    paniced := true;
	    goto panic;
	  end;
	reset(f1,ERROR:=continue);
	seed := encrypt_seed2;
	read_decrypt(in_rec);
	temp := substr(in_rec,1,12);
	readv(temp,save_seed,error:=continue);
	temp := substr(in_rec,14,70);
	py.misc.ssn := temp;
	seed := encrypt_seed1;
	coder(temp);
	temp_id := temp;
	priv_switch(1);
	open (f2,file_name:=moria_mas,
		access_method:=keyed,organization:=indexed,
		history:=old,sharing:=readwrite,error:=continue);
	if (status(f2) <> 0) then
	  begin
	    prt('ERROR opening file MASTER.',1,1);
	    paniced := true;
	    goto panic;
	  end;
	findk(f2,0,temp_id,eql,error:=continue);
	{FXJLM -- have it exit if the index isn't found!}
	if (EOF(f2)) then begin
	    writeln('--------------------------------------------------------');
	    writeln('| There was a data corruption error with the character |');
	    writeln('| Terminating IMORIA now.                              |');
	    writeln('--------------------------------------------------------');
	    HALT;
	end;
	delete(f2,error:=continue);
	{FXJLM -- end of kluge}
	if (status(f2) <> 0) then
	  data_exception;
	close(f2);
	priv_switch(0);
	seed := save_seed;
	prt('Restoring Character...',1,1);
	put_qio;
	read_decrypt(in_rec);
	readv(in_rec,save_version,error:=continue);
	if (save_version <> cur_version) then
	  begin
	    prt('Save file is incompatible with this version.',2,1);
	    writev(in_rec,'  [Save file version ',save_version:5:2,']');
	    prt(in_rec,3,1);
	    writev(in_rec,'  [Moria version     ',cur_version:5:2,']');
	    prt(in_rec,4,1);

	    if (save_version > 4.0) and (save_version < cur_version) then
	      dun_flag := true
	    else
	      exit;
	    prt('Updating character for newer version...',5,1);
	    pause(24);
	  end;

	read_decrypt(in_rec);
	with py.misc do
	  readv(in_rec,py.misc.xtr_wgt,py.misc.account,money[0],money[6],
	money[5],money[4],money[3],money[2],money[1],diffic,error:=continue);
	read_decrypt(in_rec);

{
	with py.misc do
	  readv(in_rec,mr,error:=continue);
	read_decrypt(in_rec);
}

	with py.misc.birth do                              
	  readv(in_rec,year,month,day,hour,secs,error:=continue);

	read_decrypt(in_rec);
	with py.misc.cur_age do
	  readv(in_rec,year,month,day,hour,secs,error:=continue);

{FUBAR modification for quests}
	if (dun_flag)
	  then begin
		 py.flags.quested := false;
		 py.misc.cur_quest := 0;
		 py.misc.quests := 0;
	       end
	  else begin
		 read_decrypt(in_rec);
		 readv(in_rec,py.flags.quested,py.misc.cur_quest,py.misc.quests);
               end;

	read_decrypt(in_rec);
	with py.misc.play_tm do
	  readv(in_rec,years,months,days,hours,minutes,seconds,hundredths,
		       error:=continue);

	read_decrypt(in_rec);
	with py.misc do
	  readv(in_rec,name,error:=continue);

	read_decrypt(in_rec);
	with py.misc do
	  readv(in_rec,race,error:=continue);

	read_decrypt(in_rec);
	with py.misc do
	  readv(in_rec,sex,error:=continue);

	read_decrypt(in_rec);
	with py.misc do
	  readv(in_rec,tclass,error:=continue);

	read_decrypt(in_rec);
	with py.misc do
	  readv(in_rec,title,error:=continue);

	for i1 := 1 to 5 do
	  begin
	    read_decrypt(in_rec);
 	    py.misc.history[i1] := in_rec;
	  end;

	read_decrypt(in_rec);
	readv(in_rec,cheated,error:=continue);
	py.misc.cheated := py.misc.cheated or cheated;

	read_decrypt(in_rec);
	with py.misc do
	  begin
	    readv(in_rec,char_row,char_col,pclass,prace,age,ht,wt,sc,
		  max_exp,exp,rep,deaths,premium,lev,max_lev,expfact,
		  error:=continue);
	    if wt > max_allowable_weight then
		wt := TRUNC ( 0.9*max_allowable_weight )
	    else if wt < min_allowable_weight then
		wt := TRUNC ( 1.10*min_allowable_weight ) ;
	  end ;

	case py.misc.pclass of
	  1	: py.misc.mr := -10;
	  2,3	: py.misc.mr := 0;
	otherwise py.misc.mr := -5;
	end;

	read_decrypt(in_rec);
	with py.misc do
	  readv(in_rec,srh,fos,stl,bth,bthb,mana,cmana,mhp,chp,
		ptohit,ptodam,pac,ptoac,dis_th,dis_td,dis_ac,dis_tac,
		disarm,save,hitdie,error:=continue);

	read_decrypt(in_rec);
	readv(in_rec,inven_ctr,inven_weight,equip_ctr,dun_level,
	      missle_ctr,mon_tot_mult,turn,randes_seed,error:=continue);

	with py.flags do
	  begin
	    read_decrypt(in_rec);
	    readv(in_rec,insured,dead,error:=continue);
{	    if dead and prop then
	      begin
		msg_print('Hmmm, it would appear that you are dead.');
		if insured then
		  begin
		    msg_print('Luckily, your insurance is paid up!');
		    py.misc.deaths := py.misc.deaths + 1;
		    insured := false;
		  end
		else
		  begin
		    msg_print('Unfortunately, you hadn''t paid for insurance.');
		    exit;
		  end;
	      end
	    else
	      was_dead := false; }
	  end;
	was_dead := false;
	{ Read in the inventory records.	}
	inventory_list := nil;
	lost_inven_count := 0;
	bag_lost := false;
        cur_bag := nil;
	{use of i2 to store inven_ctr deleted by Dean}
	for i1 := 1 to inven_ctr do
	  begin
	    read_decrypt(in_rec);
	    readv(in_rec,inven_temp^.data.tchar,inven_temp^.data.name,
			 error:=continue);

	    read_decrypt(in_rec);
	    readv(in_rec,trash_char,inven_temp^.insides,error:=continue);
	    inven_temp^.is_in := trash_char = 'T';
	    read_decrypt(in_rec);
	    readv(in_rec,inven_temp^.data.damage,error:=continue);

	    read_decrypt(in_rec);
	    with inven_temp^.data do
	        readv(in_rec,tval,subval,weight,number,tohit,todam,ac,
			toac,p1,flags,flags2,level,cost,error:=continue);
	    if ((was_dead) and
		(uand(inven_temp^.data.flags2,insured_bit) = 0)) then
	      begin
		if (inven_temp^.data.tval = bag_or_sack) then 
		  bag_lost := true;
		lost_inven_count := lost_inven_count + 1;
		inven_weight := inven_weight - inven_temp^.data.number *
					       inven_temp^.data.weight;
	      end
	    else if (bag_lost and inven_temp^.is_in) then
	      lost_inven_count := lost_inven_count + 1
	    else
	      begin
		if (was_dead) then
		  inven_temp^.data.flags2 := uand(inven_temp^.data.flags2,
						  %X'BFFFFFFF');
		add_item;
                bag_lost := false
	      end;
	  end;
	inven_ctr := 0;
	ptr := inventory_list;
	while (ptr <> nil) do
	  begin
	    ptr := ptr^.next;
	    inven_ctr := inven_ctr + 1;
	  end;
	if (lost_inven_count = 1) then
	  msg_print('You lost an item that wasn''t insured.')
	else if (lost_inven_count > 1) then
	  msg_print('You lost several items that weren''t insured.');

	{ Read in the equipment records.	}
	lost_equip_count := 0;
	for i1 := Equipment_min to equip_max-1 do
	  with inven_temp^.data do
	    begin
	      read_decrypt(in_rec);
	      readv(in_rec,tchar,name,error:=continue);

	      read_decrypt(in_rec);
	      readv(in_rec,damage,error:=continue);

	      read_decrypt(in_rec);
	      readv(in_rec,tval,subval,weight,number,tohit,todam,ac,
			toac,p1,flags,flags2,level,cost,error:=continue);
	      if ((was_dead) and (tval > 0) and 
		  (uand(flags2,insured_bit) = 0)) then
		begin
		  lost_equip_count := lost_equip_count + 1;
		  equipment[i1] := blank_treasure;
		  inven_weight := inven_weight - inven_temp^.data.number *
						 inven_temp^.data.weight;
		  if (i1 <> equip_max-1) then
		    py_bonuses(inven_temp^.data,-1);
		end
	      else
		begin
		  if (was_dead) then
		    inven_temp^.data.flags2 := uand(inven_temp^.data.flags2,
							%X'BFFFFFFF');
		  equipment[i1] := inven_temp^.data;
		end;
	    end;
	equip_ctr := equip_ctr - lost_equip_count;
	if (lost_equip_count = 1) then
	  msg_print('You lost a piece of equipment that wasn''t insured.')
	else if (lost_equip_count > 1) then
	  msg_print('You lost several pieces of equipment that weren''t insured.');

	if (was_dead) then msg_print(' ');

	read_decrypt(in_rec);
	with py.stat do
	  readv(in_rec,p[sr],c[sr],m[sr],l[sr],p[iq],c[iq],m[iq],l[iq],
		p[ws],c[ws],m[ws],l[ws],p[dx],c[dx],m[dx],l[dx],p[cn],c[cn],
		m[cn],l[cn],p[ca],c[ca],m[ca],l[ca],error:=continue);
	with py.flags do
	  begin
	    read_decrypt(in_rec);
	    readv(in_rec,status,blind,confused,food,food_digested,protection,
			speed,afraid,poisoned,see_inv,error:=continue);

	    read_decrypt(in_rec);
	    readv(in_rec,fast,slow,protevil,teleport,free_act,
			slow_digest,petrification,error:=continue);

	    read_decrypt(in_rec);
	    readv(in_rec,aggravate,sustain[sr],sustain[iq],sustain[ws],
			sustain[cn],sustain[dx],sustain[ca],error:=continue);

	    read_decrypt(in_rec);
	    readv(in_rec,fire_resist,cold_resist,acid_resist,regenerate,
			lght_resist,ffall,confuse_monster,error:=continue);

	    read_decrypt(in_rec);
	    readv(in_rec,image,invuln,hero,shero,blessed,resist_heat,
			resist_cold,detect_inv,word_recall,see_infra,
			tim_infra,error:=continue);

	    read_decrypt(in_rec);
	    readv(in_rec,resist_lght,free_time,ring_fire,protmon,hoarse,
			magic_prot,ring_ice,temp_stealth,resist_petri,
			blade_ring,error:=continue);
	  end;

	for i1 := 1 to max_spells do
	  with magic_spell[py.misc.pclass,i1] do
	    begin
	      read_decrypt(in_rec);
	      readv(in_rec,learned,sexp,error:=continue)
	    end;

		{ If same version, restore dungeon level...	}
	if (save_version > 4.8) then
	  begin
		{ Read the important dungeon info and floor     }
	    read_decrypt(in_rec);
	    readv(in_rec,cur_height,cur_width,max_panel_rows,max_panel_cols,
			 error:=continue);

		{ Restore the floor	}
	    for i1 := 1 to cur_height do
	      begin
		read_decrypt(in_rec);
		for i2 := 1 to cur_width do
		  begin
		    xfloor := ord(in_rec[i2]);
		    with cave[i1,i2] do
		      begin
			fval := int(uand(%X'1F',xfloor));
			if (uand(%X'20',xfloor) <> 0) then
			  fopen := true;
			if (uand(%X'40',xfloor) <> 0) then
			  pl := true;
			if (uand(%X'80',xfloor) <> 0) then
			  fm := true;
			tl := false;
			tptr := 0;
			cptr := 0;
		      end;
		  end;
	      end;

		{ Restore the Treasure List		}
	    tlink;
	    read_decrypt(in_rec);
	    readv(in_rec,tot_treasures,error:=continue);
	    for i1 := 1 to tot_treasures do
	      begin
		popt(i2);
		with t_list[i2] do
		  begin
		    read_decrypt(in_rec);
		    readv(in_rec,i3,i4,error:=continue);
		    cave[i3,i4].tptr := i2;

		    read_decrypt(in_rec);
		    readv(in_rec,tchar,name,error:=continue);

		    read_decrypt(in_rec);
		    readv(in_rec,damage,error:=continue);

		    read_decrypt(in_rec);
		    readv(in_rec,tval,subval,weight,number,tohit,todam,ac,
			toac,p1,flags,flags2,level,cost,error:=continue)
		  end;
	      end;

		{ Re-identify objects			}
	    read_decrypt(in_rec);
	    for i1 := 1 to max_objects do
	      if (in_rec[i1] = 'T') then
		identify(object_list[i1])
	      else
		object_ident[i1] := false;

		{ Restore the Monster List		}
	    mlink;
	    read_decrypt(in_rec);
	    readv(in_rec,tot_monsters,error:=continue);
	    i3 := 0;
	    for i1 := 1 to tot_monsters do
	      begin
		read_decrypt(in_rec);
		popm(i2);
		with m_list[i2] do
		  begin
		    readv(in_rec,fy,fx,mptr,hp,cspeed,csleep,cdis,ml,confused,
				 error:=continue);
		    cave[fy,fx].cptr := i2;
		    if (muptr = 0) then
		      muptr := i2
		    else
		      m_list[i3].nptr := i2;
		    nptr := 0;
		    i3 := i2;
		  end;
	      end;

		{ Restore the town level stores 	}
	    read_decrypt(in_rec);
	    readv(in_rec,town_seed,error:=continue);
	    read_decrypt(in_rec);
	    readv(in_rec,bank[0],bank[6],bank[5],bank[4],bank[3],bank[2],
		bank[1],error:=continue);
	    for i1 := 1 to max_stores do
	      if (i1 < 7) or (save_version >= 4.82) then
		with store[i1] do
		  begin
		    read_decrypt(in_rec);
		    readv(in_rec,i2,error:=continue);
		    store_ctr := i2;
		    for i3 := 1 to i2 do
		      with store_inven[i3].sitem do
			begin
			  read_decrypt(in_rec);
			  readv(in_rec,store_inven[i3].scost,error:=continue);
			  read_decrypt(in_rec);
			  readv(in_rec,tchar,name,error:=continue);
			  read_decrypt(in_rec);
			  readv(in_rec,damage,error:=continue);
			  read_decrypt(in_rec);
			  readv(in_rec,tval,subval,weight,number,tohit,todam,
				ac,toac,p1,flags,flags2,level,cost,
				error:=continue)
			end;
		  { If not current version then re-outfit the stores      }
		    read_decrypt(in_rec);
		    with store_open do
		    readv(in_rec,i3,insult_cur,year,month,day,hour,secs,
			  error:=continue);
		    if ( save_version > 4.81 ) then owner := i3;
		  end
	  end;

	close(f1,error:=continue);
	seed := get_seed;
	get_char := dun_flag;
panic:	if (paniced) then exit;
      end;


	{ Wizard command for restoring character		-RAK-	}
[global,psect(save$code)] procedure restore_char (
		fnam	: vtype;
		present	: boolean;
		undead	: boolean);
      var
	i1					: integer;
	in_rec,temp				: ntype;
	temp_id					: ssn_type;
	f1					: text;
	f2					: file of key_type;
	flag,bleah_flag,exit_flag		: boolean;
	command					: char;
      begin
	exit_flag := false;
	bleah_flag := true;
	if not(present) then
	  begin
	    if (not(undead)) then
	     repeat
	      msg_print('What kind of restore? (<d>eath-flag, <m>aster-file) ');
	      if (get_com('',command)) then
		case command of
		  'd' : begin
			  exit_flag := true;
			  undead := true;
			end;
		  'm' : begin
			  exit_flag := true;
			  undead := false;
			end;
		end
	      else
		bleah_flag := false;
	     until (exit_flag);
	    if (bleah_flag) then
	      begin
		prt('Name of file to be restored: ',1,1);
		flag := get_string(fnam,1,30,48);
	      end
	    else
	      flag := false;
	  end
	else
	  flag := true;
	if flag then
	  begin
	    if (length(fnam) = 0) then fnam := finam;
	    priv_switch(1);
	    open (f1,file_name:=fnam,
		record_length:=1024,history:=old,error:=continue);
	    if (status(f1) <> 0) then
	      msg_print('Error Opening> '+fnam)
	    else
	      begin
		  { Check to see if master is openable   -JPS- }
		flag := true;
		open (f2,file_name:=moria_mas,
			access_method:=keyed,organization:=indexed,
			history:=old,sharing:=readwrite,error:=continue);
		if (status(f2) <> 0) then
		  begin
		    open (f2,file_name:=moria_mas,
			access_method:=keyed,organization:=indexed,
			history:=new,sharing:=readwrite,error:=continue);
		    if (status(f2) <> 0) then
		      begin
			msg_print('MASTER could not be opened.');
			flag := false;
		      end;
		  end;
		if (flag) then
		  begin
			{ Reset the character in the master file.  -JPS- }
		    reset(f1,error:=continue);
		    readln(f1,in_rec,error:=continue);
		    seed := encrypt_seed2;
		    decrypt(in_rec);
		    temp := substr(in_rec,14,70);
		    seed := encrypt_seed1;
		    coder(temp);
		    temp_id := temp;
		    for i1 := 1 to 70 do
		      key_rec.file_id[i1] := temp[i1];
		    findk(f2,0,temp_id,eql,error:=continue);
		    delete(f2,error:=continue);
		    f2^ := key_rec;
		    put(f2,error:=continue);
		    if (status(f2) = 0) then
		      msg_print('Character restored...')
		    else
		      msg_print('Could not write ID in MASTER.');
		  end;
		close(f1,error:=continue);
		close(f2,error:=continue);
	      end;
	    seed := get_seed;
	    priv_switch(0);
	  end;
	if (undead) then
	  begin
	    get_char(fnam,false);
	    py.flags.dead := false;
	    finam := fnam;
	    save_char(false);
	  end;
      end;

End.
