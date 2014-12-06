[Inherit('Moria.Env')] Module Files;

[external(lib$get_foreign)] procedure get_foreign(
	%descr msg_str		: string;
	%descr prompt		: string   := %immed 0;
	%ref len		: integer := %immed 0);
	external;

[external(cli$dcl_parse)] function dcl_parse(%descr line : string;
					     %ref table : integer := %immed 0;
					     %immed ooga : integer := %immed 0;
					     %immed oogi : integer := %immed 0;
					     %immed oogu : integer := %immed 0
					    ) : boolean; external;

[external(cli$present)] function present(%descr name : string) : boolean;
	external;

[external(cli$get_value)] function get_value(%descr name    : string;
					   %descr ret_buf : string
					  ) : boolean;
	external;

	{ Attempt to open the intro file			-RAK-	}
[global,psect(setup$code)] procedure intro(var finam : vtype);
      var
	xpos,i1,loc                     : integer;
	dummy                           : char;
	day_test,in_line                : vtype;
	file1                           : text;
	file2                           : file of key_type;
	exit_flag                       : boolean;
	moriadef			: [external] integer;
	line				: string;
	want_restore			: boolean;
	restore_name			: string;
	want_wizard			: boolean;
	wiz_pass			: string;
	out_val				: string;

      procedure qualifier_help;
	begin
	  writeln('Invalid Moria option!  Valid qualifiers are:');
	  writev(out_val,'  /difficulty=X       (Where X is a difficulty from 1 to 5, default of 3)');
	  writeln(out_val);
	  writev(out_val,'  /score[=max_score]  (List high scores;',
			 ' default is ',max_high_scores:1,')');
	  writeln(out_val);
	  writeln('  /trap=[keep]        (Put all incoming messages on ',
		  'the message line)');
	  writeln('  /notrap             (Default; let messages appear ',
		  'normally)');
	  writeln('  /top[=max_score]    (Top scores to display when ',
		  'charcter dies; default is 20)');
	  writeln('  /hear               (Warn about hearing things in water)');
	  check_pswd('doublespeak',true);
	  if (wizard2) then
	    begin
	      writeln('  /wizard[=password]  (Enter wizard mode ',
		      'password; default is -booboo-)');
	      writeln('  /restore[=filename] (Restore character in master file)');
	      writeln('  /undead[=filename]  (Change the dead flag in save file)');
	    end;
	end;

      begin
	exit_flag := false;
	clear(1,1);
	{ Attempt to read hours.dat.  If it does not exist,     }
	{ then create a standard one.                           }
	priv_switch(1);
	open(file1,file_name:=MORIA_HOU,
		history:=readonly,sharing:=readonly,error:=continue);
	if (status(file1) = 0) then
	  begin
	    reset(file1);
	    repeat
	      readln(file1,in_line,error:=continue);
	      if (length(in_line) > 3) then
		begin
		  day_test := substr(in_line,1,4);
		  if      (day_test = 'SUN:') then days[1] := in_line
		  else if (day_test = 'MON:') then days[2] := in_line
		  else if (day_test = 'TUE:') then days[3] := in_line
		  else if (day_test = 'WED:') then days[4] := in_line
		  else if (day_test = 'THU:') then days[5] := in_line
		  else if (day_test = 'FRI:') then days[6] := in_line
		  else if (day_test = 'SAT:') then days[7] := in_line;
		end;
	    until(eof(file1));
	    close(file1,error:=continue);
	    priv_switch(0);
	  end
	else    { Create a standard hours file                  }
	  begin
	    priv_switch(0);
	    open(file1,file_name:=MORIA_HOU,
		organization:=sequential,history:=new,
		sharing:=readwrite,error:=continue);
	    if (status(file1) = 0) then
	      begin
		rewrite(file1,error:=continue);
		writeln(file1,'    Moria operating hours are:');
		writeln(file1,'    |    AM     |    PM     |');
		writeln(file1,'    1         111         111');
		writeln(file1,'    2123456789012123456789012');
		for i1 := 1 to 7 do
		  writeln(file1,days[i1]);
		writeln(file1,'       (X=Open; .=Closed)');
		close(file1,error:=continue);
		writeln('Created ',MORIA_HOU);
		exit_flag := true;
	      end
	    else
	      begin
		writeln('Error in creating ',MORIA_HOU);
		exit;
	      end;
	  end;

	{ Check the hours, if closed then require password	}
	{ For lack of someplace better to put it, the /SCORE
	  qualifier goes here...			-KRC-	}
	{ Hmm, this seems to be becoming a definite trend here:
		here comes the /RESTORE qualifier	-KRC	}
	{ All qualifiers converted to a .cld file, and several
	  new qualifiers addedd				-DMF-	}
	if (not(exit_flag)) then
	  begin
	    line := '';
	    get_foreign(line);
	    if not(dcl_parse('moria '+line,moriadef)) then
	      begin
		qualifier_help;
		exit;
	      end;
	    if present('score') then
	      begin
		max_score := 0;
		if (get_value('score',out_val) and (length(out_val) > 0)) then
		  readv(out_val,max_score,error:=continue);
		if (max_score < 1) or (max_score > max_high_scores) then
		  max_score := 20;
		top_twenty;
		exit;
	      end;
	    if present('wizard') then
	      begin
		if (get_value('wizard',wiz_pass) and
		   (length(wiz_pass) > 0)) then
		  check_pswd(wiz_pass,true)
		else
		  check_pswd('',false);
	      end;
	    if present('trap') then
	      begin
		want_trap := true;
		if (get_value('trap',out_val)) then
		  begin
		    readv(out_val,max_mess_keep,error:=continue);
		    if (max_mess_keep < 1) then max_mess_keep := 1;
		    if (max_mess_keep > 1000) then max_mess_keep := 1000;
		  end;
	      end
	    else
	      want_trap := false;
	    if present('warn') then
	      want_warn := true
	    else
	      want_warn := false;
	    if present('difficulty') then
	      if (get_value('difficulty',out_val)) then
		begin
		  readv(out_val,py.misc.diffic,error:=continue);
		  if (py.misc.diffic > 5) then py.misc.diffic := 5;
		  if (py.misc.diffic < 1) then py.misc.diffic := 1;
		end;
	    if present('restore') then
	      begin
		if (get_value('restore',restore_name) and
		   (length(restore_name) > 0)) then
		  begin
		    if not(wizard1) then check_pswd('',false);
		    if (wizard1) then restore_char(restore_name,true,false);
		    exit;
		  end
		else
		  begin
		    if not(wizard1) then check_pswd('',false);
		    if (wizard1) then restore_char('',false,false);
		    exit;
		  end;
	      end;
	    if present('undead') then
	      begin
		if (get_value('undead',restore_name) and
		   (length(restore_name) > 0)) then
		  begin
		    if not(wizard1) then check_pswd('',false);
		    if (wizard1) then restore_char(restore_name,true,true);
		    exit;
		  end
		else
		  begin
		    if not(wizard1) then check_pswd('',false);
		    if (wizard1) then restore_char('',false,true);
		    exit;
		  end;
	      end;
	    if (not(wizard1)) then
	      begin
		no_controly;
		if uw$id then
		  if already_playing then
		    begin
		      writeln ( 'Hey bub, you''re already playing a game.' );
		      exit;
		    end ;
	      end;
	    if (not(check_time)) then
	      if (not(wizard1)) then
		begin
		  priv_switch(1);
		  open(file1,file_name:=MORIA_HOU,
			history:=readonly,sharing:=readonly,error:=continue);
		  if (status(file1) = 0) then
		    begin
		      reset(file1);
		      repeat
			readln(file1,in_line);
			writeln(in_line);
		      until(eof(file1));
		      close(file1,error:=continue);
		    end;
		  priv_switch(0);
		  exit;
		end;
	  end;

	{ Print the introduction message, news, ect...		}
	priv_switch(1);
	open(file1,file_name:=MORIA_MOR,
		organization:=sequential,history:=readonly,
		sharing:=readwrite,error:=continue);
	if (status(file1) = 0) then
	  begin
	    if (not(exit_flag)) then
	      begin
		reset(file1);
		repeat
		  readln(file1,in_line,error:=continue);
		  writeln(in_line);
		until (eof(file1));
		pause_exit(24,0);
		close(file1,error:=continue);
	      end
	    else
	      close(file1,error:=continue);
	    priv_switch(0);
	  end
	else    { Create one...                                 }
	  begin
	    priv_switch(0);
	    open(file1,file_name:=MORIA_MOR,
		organization:=sequential,history:=new,
		sharing:=readwrite,error:=continue);
	    if (status(file1) = 0) then
	      begin
		rewrite(file1,error:=continue);
writeln(file1,'                         *********************');
writeln(file1,'                         **    Moria ',cur_version:4:2,'   **');
writeln(file1,'                         *********************');
writeln(file1,'                   COPYRIGHT (c) Robert Alan Koeneke');
writeln(file1,' ');
writeln(file1,'Programers : Robert Alan Koeneke / University of Oklahoma');
writeln(file1,'             Jimmey Wayne Todd   / University of Oklahoma');
writeln(file1,' ');
writeln(file1,'UW Modifications by : Kenneth Case, Mary Conner,');
writeln(file1,'                      Robert DeLoura, Dan Flye,');
writeln(file1,'                      Todd Gardiner, Dave Jungck,');
writeln(file1,'                      Andy Walker, Dean Yasuda.');
writeln(file1,' ');
writeln(file1,'University of Washington version 4.8');
writeln(file1,' ');
writeln(file1,'Dungeon Master: This file may contain updates and news.');
		close(file1,error:=continue);
		writeln('Created ',MORIA_MOR);
		exit_flag := true;
	      end
	    else
	      begin
		writeln('Error in creating ',MORIA_MOR);
		exit;
	      end;
	  end;
	{ Check for MASTER.DAT                          }
	priv_switch(1);
	open (file2,file_name:=moria_mas,
		access_method:=keyed,organization:=indexed,history:=readonly,
		sharing:=readwrite,error:=continue);
	if (status(file2) <> 0) then
	  begin
	    priv_switch(0);
	    open (file2,file_name:=moria_mas,
		access_method:=keyed,organization:=indexed,history:=new,
		sharing:=readwrite,error:=continue);
	    if (status(file2) = 0) then
	      begin
		writeln('Created ',MORIA_MAS);
		close(file2,error:=continue);
		exit_flag := true;
	      end
	    else
	      begin
		writeln('Error in creating ',MORIA_MAS);
		exit;
	      end;
	  end
	else
	  begin
	    close(file2,error:=continue);
	    priv_switch(0);
	  end;
	{ Check for high score file				}
	priv_switch(1);
	open (file1,file_name:=moria_top,
		organization:=sequential,history:=readonly,
		sharing:=readwrite,error:=continue);
	if ((status(file1) <> 0) and (status(file1) <> 2)) then
	  begin
	    priv_switch(0);
	    open (file1,file_name:=moria_top,
		organization:=sequential,history:=new,
		sharing:=readwrite,error:=continue);
	    if (status(file1) = 0) then
	      begin
		writeln('Created ',MORIA_TOP);
		close(file1,error:=continue);
		exit_flag := true;
	      end
	    else
	      begin
		writeln('Error in creating ',MORIA_TOP);
		exit;
	      end;
	  end
	else
	  begin
	    close(file1,error:=continue);
	    priv_switch(0);
	  end;
	{ Check for death log file				}
	priv_switch(1);
	open (file1,file_name:=moria_dth,
		organization:=sequential,history:=readonly,
		sharing:=readwrite,error:=continue);
	if ((status(file1) <> 0) and (status(file1) <> 2)) then
	  begin
	    priv_switch(0);
	    open (file1,file_name:=moria_dth,
		organization:=sequential,history:=new,
		sharing:=readwrite,error:=continue);
	    if (status(file1) = 0) then
	      begin
		rewrite(file1,error:=continue);
writeln(file1,'Moria death log file');
writeln(file1);
writeln(file1,'Key to abbreviations:');
writeln(file1);
writeln(file1,'For Race:          For Class:');
writeln(file1,'  1 = Human          1 = Warrior');
writeln(file1,'  2 = Half-Elf       2 = Mage');
writeln(file1,'  3 = Elf            3 = Priest');
writeln(file1,'  4 = Halfling       4 = Rogue');
writeln(file1,'  5 = Gnome          5 = Ranger');
writeln(file1,'  6 = Dwarf          6 = Paladin');
writeln(file1,'  7 = Half-Orc       7 = Druid');
writeln(file1,'  8 = Half-Troll     8 = Bard');
writeln(file1,'  9 = Phraint        9 = Adventurer');
writeln(file1,' 10 = Dryad         10 = Monk');
writeln(file1);
writeln(file1,'             Dif Class   Dung Dung');
writeln(file1,' Username      Race  Lvl Cur  Max  Died from');
writeln(file1,' ------------ - -- -- -- ---- ---- --------------------------------------------');
		close(file1,error:=continue);
		writeln('Created ',MORIA_DTH);
		exit_flag := true;
	      end;
	  end;
	if (exit_flag) then
	  begin
	    writeln('Notice: System MORIA wizard should set the protection');
	    writeln('        on  files  just created.  See INSTALL.HLP for');
	    writeln('        help on setting protection on the files.');
	    writeln('Notice: File HOURS.DAT may be edited to set operating');
	    writeln('        hours for MORIA.');
	    writeln('Notice: File MORIA.DAT may be edited to contain  news');
	    writeln('        items, etc...');
	    exit;
	  end;
	if present('top') then
	  begin
	    max_score := 0;
	    if (get_value('top',out_val) and (length(out_val) > 0)) then
	      readv(out_val,max_score,error:=continue);
	    if (max_score < 1) or (max_score > max_high_scores) then
	      max_score := max_high_scores;
	  end
	else
	  max_score := 0;
	if present('finam') then
	  begin
	    if (get_value('finam',out_val) and (length(out_val) > 0)) then
	      begin
		loc := index(out_val,'/');
		while (loc <> 0) and (length(out_val) > 0) do
		  begin
		    if (loc = 1) and (length(out_val) = 0) then
		      begin
			loc := 0;
			out_val := '';
		      end
		    else
		      begin
			out_val := substr(out_val,loc+1,length(out_val)-loc);
			loc := index(out_val,' ');
			while (loc <> 0) and (length(out_val) > 0) do
			  begin
			    if (loc = 1) and (length(out_val) = 0) then
			      begin
			        loc := 0;
			        out_val := '';
			      end
			    else
			      begin
			        out_val := substr(out_val,loc+1,
						  length(out_val)-loc);
			        loc := index(out_val,' ');
			      end;
			  end;
			loc := index(out_val,'/');
		      end;
		  end;
		finam := out_val;
	      end
	    else
	      finam := '';
	  end;
      end;


	{ Prints dungeon map to external file			-RAK-	}
[global,psect(misc2$code)] procedure print_map;
    var
	i1,i2,i3,i4,i5,i6,i7,i8         : integer;
	dun_line                        : varying [133] of char;
	filename1                       : varying [80] of char;
	tmp                             : char;
	file1                           : text;
    begin
      prt('File name: ',1,1);
      if (get_string(filename1,1,12,64)) then
	begin
	  if (length(filename1) = 0) then filename1 := 'MORIAMAP.DAT';
	  open(file1,filename1,error:=continue);
	  if (status(file1) = 0) then
	    begin
	      prt('Writing Moria Dungeon Map...',1,1);
	      put_qio;
	      rewrite(file1,error:=continue);
	      i1 := 1;
	      i7 := 0;
	      repeat
		i2 := 1;
		i3 := i1 + outpage_height - 1;
		if (i3 > cur_height) then
		  i3 := cur_height;
		i7 := i7 + 1;
		i8 := 0;
		repeat
		  i4 := i2 + outpage_width - 1;
		  if (i4 > cur_width) then
		    i4 := cur_width;
		  i8 := i8 + 1;
		  writeln(file1,chr(12),error:=continue);
		  write(file1,'Section[',i7:1,',',i8:1,'];     ',
							error:=continue);
		  writeln(file1,'Depth : ',(dun_level*50):1,' (feet)',
							error:=continue);
		  writeln(file1,' ',error:=continue);
		  write(file1,'   ',error:=continue);
		  for i5 := i2 to i4 do
		    begin
		      i6 := trunc(i5/100);
		      write(file1,i6:1,error:=continue);
		    end;
		  writeln(file1,error:=continue);
		  write(file1,'   ',error:=continue);
		  for i5 := i2 to i4 do
		    begin
		      i6 := trunc(i5/10) - trunc(i5/100)*10;
		      write(file1,i6:1,error:=continue);
		    end;
		  writeln(file1,error:=continue);
		  write(file1,'   ',error:=continue);
		  for i5 := i2 to i4 do
		    begin
		      i6 := i5 - trunc(i5/10)*10;
		      write(file1,i6:1,error:=continue);
		    end;
		  writeln(file1,error:=continue);
		  for i5 := i1 to i3 do
		    begin
		      writev(dun_line,i5:3);
		      for i6 := i2 to i4 do
			begin
			  if (test_light(i5,i6)) then
			    loc_symbol(i5,i6,tmp)
			  else
			    tmp := ' ';
			  dun_line := dun_line + tmp;
			end;
		      writeln(file1,dun_line,error:=continue);
		    end;
		  i2 := i2 + outpage_width;
		until (i2 >= cur_width);
		i1 := i1 + outpage_height;
	      until (i1 >= cur_height);
	      close(file1,error:=continue);
	      prt('Completed.',1,1);
	    end;
	end
    end;


	{ Prints a list of random objects to a file.  Note that -RAK-	}
	{ the objects produced is a sampling of objects which           }
	{ be expected to appear on that level.                          }
[global,psect(misc2$code)] procedure print_objects;
    var
	nobj,i1,i2,level                : integer;
	filename1,tmp_str               : varying [80] of char;
	file1                           : text;
    begin
      prt('Produce objects on what level?: ',1,1);
      get_string(tmp_str,1,33,10);
      level := 0;
      readv(tmp_str,level,error:=continue);
      prt('Produce how many objects?: ',1,1);
      get_string(tmp_str,1,28,10);
      nobj := 0;
      readv(tmp_str,nobj,error:=continue);
      if ((nobj > 0) and (level > -1) and (level < 1201)) then
	begin
	  if (nobj > 9999) then nobj := 9999;
	  prt('File name: ',1,1);
	  if (get_string(filename1,1,12,64)) then
	    begin
	      if (length(filename1) = 0) then filename1 := 'MORIAOBJ.DAT';
	      open(file1,filename1,error:=continue);
	      if (status(file1) = 0) then
		begin
		  writev(tmp_str,nobj:1);
		  prt(tmp_str + ' random objects being produced...',1,1);
		  put_qio;
		  rewrite(file1,error:=continue);
	writeln(file1,'*** Random Object Sampling:',error:=continue);
	writeln(file1,'*** ',nobj:1,' objects',error:=continue);
	writeln(file1,'*** For Level ',level:1,error:=continue);
	writeln(file1,'',error:=continue);
	writeln(file1,'',error:=continue);
		  popt(i2);
		  for i1 := 1 to nobj do
		    begin
		      t_list[i2] := object_list[get_obj_num(level)];
		      magic_treasure(i2,level);
		      inven_temp^.data := t_list[i2];
		      with inven_temp^.data do
			begin
			  unquote(name);
			  known1(name);
			  known2(name);
			end;
		      objdes(tmp_str,inven_temp,true);
		      writeln(file1,tmp_str,error:=continue);
		    end;
		  pusht(i2);
		  close(file1,error:=continue);
		  prt('Completed.',1,1);
		end
	      else
		prt('File could not be opened.',1,1);
	    end;
	end;
    end;


	{ Prints a listing of monsters				-RAK-	}
[global,psect(wizard$code)] procedure print_monsters;
    var
	i1,i2,xpos,atype,adesc,acount,i5: integer;
	file1                           : text;
	out_val,filename1               : vtype;
	attstr,attx                     : vtype;
	damstr                          : etype;

    begin
      prt('File name: ',1,1);
      if (get_string(filename1,1,12,64)) then
	begin
	  if (length(filename1) = 0) then filename1 := 'MORIAMON.DAT';
	  open(file1,filename1,error:=continue);
	  if (status(file1) = 0) then
	    begin
	      prt('Writing Monster Dictionary...',1,1);
	      put_qio;
	      rewrite(file1,error:=continue);
	      for i1 := 1 to max_creatures do
		with c_list[i1] do
		  begin
	{ Begin writing to file                                 }
writeln(file1,'--------------------------------------------',error:=continue);
out_val := name + '                              ';
writeln(file1,i1:3,'  ',out_val:30,'     (',cchar:1,')',error:=continue);
writeln(file1,'     Speed =',speed:2,'  Level     =',level:2,'  Exp =',mexp:5,
		error:=continue);
writeln(file1,'     AC    =',ac:2,   '  Eye-sight =',aaf:2,'  HD  =',hd:5,
							error:=continue);
if (uand(%X'80000000',cmove) <> 0) then
  writeln(file1,'     Creature is a ***Win Creature***',error:=continue);
if (uand(%X'00080000',cmove) <> 0) then
  writeln(file1,'     Creature Eats/kills other creatures.',error:=continue);
if (uand(%X'00004000',cmove) <> 0) then
  writeln(file1,'     Creature is good (negative experience)',error:=continue);
if (uand(%X'00008000',cmove) <> 0) then
  writeln(file1,'     Creature will not normally appear.',error:=continue);
if (uand(%X'0001',cdefense) <> 0) then
  writeln(file1,'     Creature is a dragon.',error:=continue);
if (uand(%X'0002',cdefense) <> 0) then
  writeln(file1,'     Creature is a monster.',error:=continue);
if (uand(%X'0400',cdefense) <> 0) then
  writeln(file1,'     Creature is a demon.',error:=continue);
if (uand(%X'0004',cdefense) <> 0) then
  writeln(file1,'     Creature is evil.',error:=continue);
if (uand(%X'0008',cdefense) <> 0) then
  writeln(file1,'     Creature is undead.',error:=continue);
if (uand(%X'0010',cdefense) <> 0) then
  writeln(file1,'     Creature harmed by cold.',error:=continue);
if (uand(%X'0020',cdefense) <> 0) then
  writeln(file1,'     Creature harmed by fire.',error:=continue);
if (uand(%X'0040',cdefense) <> 0) then
  writeln(file1,'     Creature harmed by poison.',error:=continue);
if (uand(%X'0080',cdefense) <> 0) then
  writeln(file1,'     Creature harmed by acid.',error:=continue);
if (uand(%X'0100',cdefense) <> 0) then
  writeln(file1,'     Creature harmed by blue light.',error:=continue);
if (uand(%X'0200',cdefense) <> 0) then
  writeln(file1,'     Creature harmed by Stone-to-Mud.',error:=continue);
if (uand(%X'1000',cdefense) <> 0) then
  writeln(file1,'     Creature cannot be charmed or slept.',error:=continue);
if (uand(%X'2000',cdefense) <> 0) then
  writeln(file1,'     Creature seen with Infra-Vision.',error:=continue);
if (uand(%X'4000',cdefense) <> 0) then
  writeln(file1,'     Creature has MAX hit points.',error:=continue);
if (uand(%X'8000',cdefense) <> 0) then
  writeln(file1,'     Creature regenerates.',error:=continue);
if (uand(%X'00010000',cmove) <> 0) then
  writeln(file1,'     Creature is invisible.',error:=continue);
if (uand(%X'00100000',cmove) <> 0) then
  writeln(file1,'     Creature picks up objects.',error:=continue);
if (uand(%X'00200000',cmove) <> 0) then
  writeln(file1,'     Creature multiplies.',error:=continue);
if (uand(%X'01000000',cmove) <> 0) then
  writeln(file1,'     Carries object(s).',error:=continue);
if (uand(%X'02000000',cmove) <> 0) then
  writeln(file1,'     Carries gold, gems, ect.',error:=continue);
if (uand(%X'04000000',cmove) <> 0) then
  writeln(file1,'       Has object/gold 60% of time.',error:=continue);
if (uand(%X'08000000',cmove) <> 0) then
  writeln(file1,'       Has object/gold 90% of time.',error:=continue);
if (uand(%X'10000000',cmove) <> 0) then
  writeln(file1,'       Has 1d2 object(s)/gold.',error:=continue);
if (uand(%X'20000000',cmove) <> 0) then
  writeln(file1,'       Has 2d2 object(s)/gold.',error:=continue);
if (uand(%X'40000000',cmove) <> 0) then
  writeln(file1,'       Has 4d2 object(s)/gold.',error:=continue);
	{ Creature casts spells / Breaths Dragon breath...      }
if (spells > 0) then
  begin
    writeln(file1,'   --Spells/Dragon Breath =',error:=continue);
    if (uand(spells,%X'80000000') <> 0) then
      writeln(file1,'       Doesn''t cast spells 1 out of ',uand(%X'F',spells):1,
		' turns.',error:=continue)
    else
      writeln(file1,'       Casts spells 1 out of ',uand(%X'F',spells):1,
		' turns.',error:=continue);
    if (uand(%X'00000010',spells) <> 0) then
      writeln(file1,'       Can teleport short.',error:=continue);
    if (uand(%X'00000020',spells) <> 0) then
      writeln(file1,'       Can teleport long.',error:=continue);
    if (uand(%X'00000040',spells) <> 0) then
      writeln(file1,'       Teleport player to itself.',error:=continue);
    if (uand(%X'00000080',spells) <> 0) then
      writeln(file1,'       Cause light wounds.',error:=continue);
    if (uand(%X'00000100',spells) <> 0) then
      writeln(file1,'       Cause serious wounds.',error:=continue);
    if (uand(%X'00000200',spells) <> 0) then
      writeln(file1,'       Hold person.',error:=continue);
    if (uand(%X'00000400',spells) <> 0) then
      writeln(file1,'       Cause blindness.',error:=continue);
    if (uand(%X'00000800',spells) <> 0) then
      writeln(file1,'       Cause confusion.',error:=continue);
    if (uand(%X'00001000',spells) <> 0) then
      writeln(file1,'       Cause fear.',error:=continue);
    if (uand(%X'00002000',spells) <> 0) then
      writeln(file1,'       Summon a monster.',error:=continue);
    if (uand(%X'00004000',spells) <> 0) then
      writeln(file1,'       Summon an undead.',error:=continue);
    if (uand(%X'00008000',spells) <> 0) then
      writeln(file1,'       Slow person.',error:=continue);
    if (uand(%X'00010000',spells) <> 0) then
      writeln(file1,'       Drains mana for healing.',error:=continue);
    if (uand(%X'00020000',spells) <> 0) then
      writeln(file1,'       Shadow Breath/Orb of draining.',error:=continue);
    if (uand(%X'00040000',spells) <> 0) then
      writeln(file1,'       **Unknown spell value**',error:=continue);
    if (uand(%X'00080000',spells) <> 0) then
      writeln(file1,'       Breaths Lightning Dragon Breath.',error:=continue);
    if (uand(%X'00100000',spells) <> 0) then
      writeln(file1,'       Breaths Gas Dragon Breath.',error:=continue);
    if (uand(%X'00200000',spells) <> 0) then
      writeln(file1,'       Breaths Acid Dragon Breath.',error:=continue);
    if (uand(%X'00400000',spells) <> 0) then
      writeln(file1,'       Breaths Frost Dragon Breath.',error:=continue);
    if (uand(%X'00800000',spells) <> 0) then
      writeln(file1,'       Breaths Fire Dragon Breath.',error:=continue);
    if (uand(%X'01000000',spells) <> 0) then
      writeln(file1,'       Casts Illusion.',error:=continue);
    if (uand(%X'02000000',spells) <> 0) then
      writeln(file1,'       Summon a demon.',error:=continue);
    if (uand(%X'04000000',spells) <> 0) then
      writeln(file1,'       Summon multiplying monster.',error:=continue);
    if (uand(%X'08000000',spells) <> 0) then
      writeln(file1,'       Gaze for petrification.',error:=continue);
  end;
	{ Movement for creature                                 }
writeln(file1,'   --Movement =',error:=continue);
if (uand(%X'00000001',cmove) <> 0) then
  writeln(file1,'       Move only to attack.',error:=continue);
if (uand(%X'00000002',cmove) <> 0) then
  writeln(file1,'       20% random movement.',error:=continue);
if (uand(%X'00000004',cmove) <> 0) then
  writeln(file1,'       40% random movement.',error:=continue);
if (uand(%X'00000008',cmove) <> 0) then
  writeln(file1,'       75% random movement.',error:=continue);
if (uand(%X'00400000',cmove) <> 0) then
  writeln(file1,'      Creature can anchor in water.',error:=continue);
if (uand(%X'00800000',cmove) <> 0) then
  writeln(file1,'       Creature flies.',error:=continue);
if (uand(%X'00000010',cmove) <> 0) then
  writeln(file1,'       Creature is water based.',error:=continue);
if (uand(%X'00000040',cmove)  = 0) then
  writeln(file1,'       Survives in land and water.',error := continue);
if (uand(%X'00020000',cmove) <> 0) then
  writeln(file1,'       Can open doors.',error:=continue);
if (uand(%X'00040000',cmove) <> 0) then
  writeln(file1,'       Can phase through walls.',error:=continue);
writeln(file1,'   --Creature attacks =',error:=continue);
attstr := damage;
while (length(attstr) > 0) do
  begin
    xpos := index(attstr,'|');
    if (xpos > 0) then
      begin
	attx := substr(attstr,1,xpos-1);
	attstr := substr(attstr,xpos+1,length(attstr)-xpos);
      end
    else
      begin
	attx := attstr;
	attstr := '';
      end;
    readv(attx,atype,adesc,damstr,error:=continue);
    out_val := '';
    if (index(damstr,'-')) > 0 then
      begin
	insert_str(damstr,'-',' ');
	readv(damstr,acount,damstr,error:=continue);
      end
    else
      acount := 1;
    for i5 := 1 to acount do begin
    case adesc of
	1 :  out_val := '       Hits for ';
	2 :  out_val := '       Bites for ';
	3 :  out_val := '       Claws for ';
	4 :  out_val := '       Stings for ';
	5 :  out_val := '       Touches for ';
	6 :  out_val := '       Kicks for ';
	7 :  out_val := '       Gazes for ';
	8 :  out_val := '       Breathes for ';
	9 :  out_val := '       Spits for ';
	10:  out_val := '       Wails for ';
	11:  out_val := '       Embraces for ';
	12:  out_val := '       Crawls on you for ';
	13:  out_val := '       Shoots spores for ';
	14:  out_val := '       Begs for money for ';
	15:  out_val := '       Slimes you for ';
	16:  out_val := '       Crushes you for ';
	17:  out_val := '       Tramples you for ';
	18:  out_val := '       Drools on you for ';
	19:  out_val := '       Insults you for ';
	20:  out_val := '       UW''s you for ';
	21:  out_val := '	DMF''s you for ';
	22:  out_val := '       Cultivates you for ';
	23:  out_val := '       Charms you for ';
	24:  out_val := '       Kisses you for ';
	25:  out_val := '       Gores you for ';
	26:  out_val := '       Moo''s you for ';
	27:  out_val := '       Electrocutes you for ';
	28:  out_val := '       Inks you for ';
	29:  out_val := '       Bleeds you for ';
	30:  out_val := '       Bites you for ';
	99:  out_val := '       Is repelled...';
	otherwise out_val := '     **Unknown value** ';
    end;
    case atype of
{Normal attack  }     1  : out_val := out_val + 'normal damage.';
{Poison Strength}     2  : out_val := out_val + 'lowering strength.';
{Confusion attack}    3  : out_val := out_val + 'confusion.';
{Fear attack    }     4  : out_val := out_val + 'fear.';
{Fire attack    }     5  : out_val := out_val + 'fire damage.';
{Acid attack    }     6  : out_val := out_val + 'acid damage.';
{Cold attack    }     7  : out_val := out_val + 'cold damage.';
{Lightning attack}    8  : out_val := out_val + 'lightning damage.';
{Corrosion attack}    9  : out_val := out_val + 'corrosion damage.';
{Blindness attack}    10 : out_val := out_val + 'blindness.';
{Paralysis attack}    11 : out_val := out_val + 'paralyzation.';
{Steal Money    }     12 : out_val := out_val + 'stealing money.';
{Steal Object   }     13 : out_val := out_val + 'stealing object.';
{Poison         }     14 : out_val := out_val + 'poison damage.';
{Lose Dex       }     15 : out_val := out_val + 'lose dexterity.';
{Lose Con       }     16 : out_val := out_val + 'lose constitution.';
{Lose Int       }     17 : out_val := out_val + 'lose intelligence.';
{Lose Wis       }     18 : out_val := out_val + 'lose wisdom.';
{Lose Exp       }     19 : out_val := out_val + 'lose experience.';
{Aggravation    }     20 : out_val := out_val + 'aggravates monsters.';
{Disenchant     }     21 : out_val := out_val + 'disenchants objects.';
{Eats food      }     22 : out_val := out_val + 'eating food.';
{Eats light     }     23 : out_val := out_val + 'eating light source.';
{Eats charges   }     24 : out_val := out_val + 'absorbing charges.';
{Lose Chr	}     25 : out_val := out_val + 'lose charisma.';
{Petrification	}     26 : out_val := out_val + 'petrification.';
{ Special       }     99 : out_val := out_val + 'blank message.';
		      otherwise out_val := out_val + '**Unknown value**';
    end;
    out_val := out_val + ' (' + damstr + ')';
    writeln(file1,out_val,error:=continue);
  end;
  end;
  write(file1,'   --Magic Resistance : ');
  if (c_list[i1].mr=0)
    then writeln(file1,'None')
    else if (c_list[i1].mr < 20)
	   then writeln(file1,'Very Low')
    else if (c_list[i1].mr < 50)
	   then writeln(file1,'Low')
    else if (c_list[i1].mr < 80)
	   then writeln(file1,'Medium')
    else if (c_list[i1].mr < 110)
	   then writeln(file1,'High')
    else if (c_list[i1].mr < 140)
	   then writeln(file1,'Very High')
    else writeln(file1,'Extreme');

  for i2 := 1 to 2 do writeln(file1,' ',error:=continue);
end;
	{ End writing to file                                   }
	      close(file1,error:=continue);
	      prt('Completed.',1,1);
	    end;
	end
    end;


	{ Print the character to a file or device		-RAK-	}
[global,psect(misc2$code)] procedure file_character;
    var
	i1,i2,xbth,xbthb,xfos,xsrh,xstl,xdis	: integer;
	xsave,xdev,xswm,xrep,pos		: integer;
	xinfra					: vtype;
	file1					: text;
	out_val,filename1,prt1,prt2,new_page	: vtype;
	tstat					: stat_set;
	out_c					: array [stat_set] of stat_type;
	curse					: treas_ptr;

    begin
      prt('File name: ',1,1);
      if (get_string(filename1,1,12,64)) then
	begin
	  if (length(filename1) = 0) then filename1 := 'MORIACHR.DAT';
	  open(file1,filename1,error:=continue);
	  if (status(file1) = 0) then
	    begin
	      prt('Writing character sheet...',1,1);
	      put_qio;
	      rewrite(file1,error:=continue);
	      new_page := chr(12);
	      writeln(file1,new_page,error:=continue);
	      for tstat := sr to ca do	      
		cnv_stat(py.stat.c[tstat],out_c[tstat]);
	      writeln(file1,' ',error:=continue);
	      writeln(file1,' ',error:=continue);
	      writeln(file1,' ',error:=continue);
write(file1,  '  Name  : ',pad(py.misc.name,' ',24),error:=continue);
write(file1,  '  Age         :',py.misc.age:4,error:=continue);
writeln(file1,'     Strength     : ',out_c[sr]:6,error:=continue);
write(file1,  '  Race  : ',pad(py.misc.race,' ',24),error:=continue);
write(file1,  '  Height      :',py.misc.ht:4,error:=continue);
writeln(file1,'     Intelligence : ',out_c[iq]:6,error:=continue);
write(file1,  '  Sex   : ',pad(py.misc.sex,' ',24),error:=continue);
write(file1,  '  Weight      :',py.misc.wt:4,error:=continue);
writeln(file1,'     Wisdom       : ',out_c[ws]:6,error:=continue);
write(file1,  '  Class : ',pad(py.misc.tclass,' ',24),error:=continue);
write(file1,  '  Social Class:',py.misc.sc:4,error:=continue);
writeln(file1,'     Dexterity    : ',out_c[dx]:6,error:=continue);
write(file1,  '  Title : ',pad(py.misc.title,' ',24),error:=continue);
write(file1,  '  Difficulty  :',py.misc.diffic:4,error:=continue);
writeln(file1,'     Constitution : ',out_c[cn]:6,error:=continue);
write(file1,  '         ',' ':30,error:=continue);
write(file1,  '              ',error:=continue);
writeln(file1,'     Charisma     : ',out_c[ca]:6,error:=continue);
	      writeln(file1,' ',error:=continue);
	      writeln(file1,' ',error:=continue);
	      writeln(file1,' ',error:=continue);
	      writeln(file1,' ',error:=continue);
write(file1,  '  + To Hit    :',py.misc.dis_th:3,'   ',error:=continue);
write(file1,  '     Level      :',py.misc.lev:9,error:=continue);
writeln(file1,'     Max Hit Points :',py.misc.mhp:4,error:=continue);
write(file1,  '  + To Damage :',py.misc.dis_td:3,'   ',error:=continue);
write(file1,  '     Experience :',py.misc.exp:9,error:=continue);
writeln(file1,'     Cur Hit Points :',trunc(py.misc.chp):4,error:=continue);
write(file1,  '  + To AC     :',py.misc.dis_tac:3,'   ',error:=continue);
write(file1,  '     Gold       :',py.misc.money[total$]:9,error:=continue);
writeln(file1,'     Max Mana       :',py.misc.mana:4,error:=continue);
write(file1,  '    Total AC  :',py.misc.dis_ac:3,'   ',error:=continue);
write(file1,  '     Account    :',py.misc.account:9,error:=continue);
writeln(file1,'     Cur Mana       :',py.misc.mana:4,error:=continue);

	      writeln(file1,' ',error:=continue);
	      writeln(file1,' ',error:=continue);
	      with py.misc do
		begin
		  xbth  := bth + lev*bth_lev_adj + ptohit*bth_plus_adj;
		  xbthb := bthb + lev*bth_lev_adj + ptohit*bth_plus_adj;
		  xfos  := 27 - fos;
		  if (xfos < 0) then xfos := 0;
		  xsrh  := srh + spell_adj(iq);
		  xstl  := stl;
		  xdis  := disarm + lev + 2*todis_adj + spell_adj(iq);
		  xsave := save + lev + spell_adj(ws);
		  xdev  := save + lev + spell_adj(iq);
		  xswm  := py.flags.swim + 4;
		  xrep  := 6 + rep div 25;
		  writev(xinfra,py.flags.see_infra*10:1,' feet');
		end;
writeln(file1,'(Miscellaneous Abilities)':50,error:=continue);
writeln(file1,' ',error:=continue);
write(file1,  '  Fighting    : ',pad(likert(xbth ,12),' ',10),error:=continue);
write(file1,  '  Stealth     : ',pad(likert(xstl , 1),' ',10),error:=continue);
writeln(file1,'  Perception  : ',pad(likert(xfos , 3),' ',10),error:=continue);
write(file1,  '  Throw/Bows  : ',pad(likert(xbthb,12),' ',10),error:=continue);
write(file1,  '  Disarming   : ',pad(likert(xdis , 8),' ',10),error:=continue);
writeln(file1,'  Searching   : ',pad(likert(xsrh , 6),' ',10),error:=continue);
write(file1,  '  Saving Throw: ',pad(likert(xsave, 6),' ',10),error:=continue);
write(file1,  '  Magic Device: ',pad(likert(xdev , 7),' ',10),error:=continue);
writeln(file1,'  Infra-Vision: ',pad(xinfra,' ',10),error:=continue);
write(file1,  '  Reputation  : ',pad(likert(xswm , 1),' ',10),error:=continue);
write(file1,  '                          ',error:=continue);
writeln(file1,'  Swimming    : ',pad(likert(xrep , 1),' ',10),error:=continue);
	{ Write out the character's history     }
writeln(file1,' ');
writeln(file1,' ');
writeln(file1,'Character Background':45);
for i1 := 1 to 5 do writeln(file1,pad(py.misc.history[i1],' ',71):76);
	{ Write out the time stats		}
writeln(file1,' ');
writeln(file1,' ');
with py.misc.birth do
  begin
    out_val := day_of_week_string(day,10);
    if (index(out_val,' ') > 0) then
      out_val := substr(out_val,1,index(out_val,' ')-1);
    writeln(file1,'  You were born at ',time_string(hour,secs),' on ',
		out_val,', ',month_string(month),' the ',place_string(day),
		', ',year:1,' AH.');
  end;
writeln(file1,'  ',show_char_age);
writeln(file1,'  The current time is ',full_date_string(py.misc.cur_age),'.');
writeln(file1,'  You have been playing for ',show_play_time);
	{ Write out the equipment list...       }
	      i2 := 0;
	      writeln(file1,' ',error:=continue);
	      writeln(file1,' ',error:=continue);
	      writeln(file1,'  [Character''s Equipment List]',error:=continue);
	      writeln(file1,' ',error:=continue);
if (equip_ctr = 0) then
  writeln(file1,'  Character has no equipment in use.',error:=continue)
else
  for i1 := Equipment_min to equip_max-1 do
    with equipment[i1] do
      if (tval > 0) then
	begin
	  case i1 of
	    Equipment_primary		: prt1 := ') You are wielding   : ';
	    Equipment_helm		: prt1 := ') Worn on head       : ';
	    Equipment_amulet		: prt1 := ') Worn around neck   : ';
	    Equipment_armor		: prt1 := ') Worn on body       : ';
	    Equipment_belt		: prt1 := ') Worn around body   : ';
	    Equipment_shield		: prt1 := ') Worn on shield arm : ';
	    Equipment_gloves		: prt1 := ') Worn on hands      : ';
	    Equipment_bracers		: prt1 := ') Worn on wrists     : ';
	    Equipment_right_ring	: prt1 := ') Right ring finger  : ';
	    Equipment_left_ring		: prt1 := ') Left  ring finger  : ';
	    Equipment_boots		: prt1 := ') Worn on feet       : ';
	    Equipment_cloak		: prt1 := ') Worn about body    : ';
	    Equipment_light		: prt1 := ') Light source is    : ';
	    Equipment_secondary		: prt1 := ') Secondary weapon   : ';
	    otherwise   prt1 := ') *Unknown value*    : ';
	  end;
	  i2 := i2 + 1;
	  inven_temp^.data := equipment[i1];
	  objdes(prt2,inven_temp,true);
	  if (uand(inven_temp^.data.flags2,insured_bit) = 0) then
	    writev(out_val,'  ',chr(i2+96),prt1,prt2)
	  else
	    writev(out_val,' (',chr(i2+96),prt1,prt2);
	  writeln(file1,out_val,error:=continue);
	end;
	{ Write out the character's inventory...        }
	      writeln(file1,new_page,error:=continue);
	      writeln(file1,' ',error:=continue);
	      writeln(file1,' ',error:=continue);
	      writeln(file1,' ',error:=continue);
	      writeln(file1,'  [General Inventory List]',error:=continue);
	      writeln(file1,' ',error:=continue);
if (inven_ctr = 0) then
  writeln(file1,'  Character has no objects in inventory.',error:=continue)
else
  begin
    i1 := 1;
    curse := inventory_list;
    while (curse <> nil) do
      begin
	if (i1 mod 50) = 0 then
	  begin
	    writeln(file1,new_page,error:=continue);
	    writeln(file1,' ',error:=continue);
	    writeln(file1,' ',error:=continue);
	    writeln(file1,' ',error:=continue);
	    writeln(file1,'  [General Inventory List, Page ',
				((i1 div 50) + 1):1,']',
				error:=continue);
	    writeln(file1,' ',error:=continue);
	  end;
	inven_temp^.data := curse^.data;
	objdes(prt1,inven_temp,true);
	if (curse^.is_in) then prt1 := '    ' + prt1;
	if (i1 < 27) then
	  if (uand(inven_temp^.data.flags2,insured_bit) = 0) then
	    writev(out_val,' ',chr(i1+96),') ',prt1)
	  else
	    writev(out_val,'(',chr(i1+96),') ',prt1)
	else
	  if (uand(inven_temp^.data.flags2,insured_bit) = 0) then
	    writev(out_val,' *) ',prt1)
	  else
	    writev(out_val,'(*) ',prt1);
	if (uand(inven_temp^.data.flags2,holding_bit) <> 0) then
	  out_val := out_val + bag_descrip(curse);
	writeln(file1,out_val,error:=continue);
	curse := curse^.next;
	i1 := i1 + 1;
      end
  end;
	      writeln(file1,new_page,error:=continue);
	      close(file1,error:=continue);
	      prt('Completed.',1,1);
	    end;
	end
    end;

End.
