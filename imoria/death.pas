[Inherit('Moria.Env')] Module Death;

var
	f1	: text;
        f2      : file of key_type;
	dstr	: array [0..19] of vtype;

	{ Handles the gravestone and top-twenty routines	-RAK-	}
[global,psect(death$code)] procedure upon_death;
    type
	word	= 0..65535;
	recj	= record
			unameinfo	: packed record
				unamelen	: word;
				jpi$_username	: word;
			end;
			ptr_uname	: ^usernam;
			ptr_unamelen	: ^integer;
			endlist		: integer
	end;
	usernam		= packed array [1..12] of char;

    var

        temp_id : ssn_type;
        temp    : ntype;

	{ function returns the players USERNAME			-JWT-	}
    function get_username : usernam;
      var
	user		: usernam;
	icode		: integer;
	jpirec		: recj;

	{ calls GETJPI routine to return the USERNAME		-JWT-	}
      function sys$getjpi	(%immed	p1	: integer;
			 	%immed	p2	: integer;
			 	%immed	p3	: integer;
			 	var	itmlst	: recj;
			 	%immed	p4	: integer;
			 	%immed	p5	: integer;
			 	%immed	p6	: integer) : integer;
        external;

      begin
	with jpirec do
	  begin
	    unameinfo.unamelen		:= 12;
	    unameinfo.jpi$_username	:= %x202;
	    new (ptr_uname);
	    ptr_uname^			:= '            ';
	    new (ptr_unamelen);
	    ptr_unamelen^		:= 0;
	    endlist			:= 0
	  end;
	icode := SYS$GETJPI (0,0,0,jpirec,0,0,0);
	if not odd(icode) then
	  begin
	    writeln('Error in GETJPI process');
	    halt
	  end
	else
	  get_username := jpirec.ptr_uname^
	end;



	{ Centers a string within a 31 character string		-JWT-	}
    function fill_str (p1 : vtype) : vtype;
      var
	s1	: vtype;
	i1	: integer;
      begin
        s1 := '';
        i1 := trunc(length(p1) / 2);
        fill_str := substr(pad(s1,' ',15-i1) + pad(p1,' ',31),1,31);
      end;


	{ Prints a line to the screen efficiently		-RAK-	}
    procedure dprint(str : vtype; row : integer);
      var
	i1,i2,nblanks,xpos			: integer;
	prt_str					: vtype;
      begin
	prt_str := '';
	nblanks := 0;
        xpos := 0;
	for i1 := 1 to length(str) do
	  begin
	    if (str[i1] = ' ') then
	      begin
		if (xpos > 0) then
		  begin
		    nblanks := nblanks + 1;
		    if (nblanks > 5) then
		      begin
			nblanks := 0;
			put_buffer(prt_str,row,xpos);
			prt_str := '';
			xpos := 0;
		      end
		  end;
	      end
	    else
	      begin
		if (xpos = 0) then xpos := i1;
		if (nblanks > 0) then
		  begin
		    for i2 := 1 to nblanks do
		      prt_str := prt_str + ' ';
		    nblanks := 0;
		  end;
		prt_str := prt_str + str[i1];
	      end;
	  end;
	if (xpos > 0) then
	  put_buffer(prt_str,row,xpos);
      end;


[global,psect(death$code)] procedure make_tomb;
      var
	str1,str2,str3,str4,str5,str6,str7,str8 : vtype;
	i1 : integer;
	day : packed array [1..11] of char;
      begin
        date(day);
	str1 := fill_str(py.misc.name);
	str2 := fill_str(py.misc.title);
	str3 := fill_str(py.misc.tclass);
        writev(str4,'Level : ',py.misc.lev:1);
	str4 := fill_str(str4);
        writev(str5,py.misc.exp:1,' Exp');
	str5 := fill_str(str5);
	writev(str6,(py.misc.account+py.misc.money[total$]):1,' Au');
	str6 := fill_str(str6);
	writev(str7,'Died on Level : ',dun_level:1);
	str7 := fill_str(str7);
	str8 := fill_str(died_from);
dstr[00] := ' ';
dstr[01] := '               _______________________';
dstr[02] := '              /                       \         ___';
dstr[03] := '             /                         \ ___   /   \      ___';
dstr[04] := '            /            RIP            \   \  :   :     /   \';
dstr[05] := '           /                             \  : _;,,,;_    :   :';
dstr[06] := '          /'+str1+                       '\,;_          _;,,,;_';
dstr[07] := '         |               the               |   ___';
dstr[08] := '         | '+str2+                       ' |  /   \';
dstr[09] := '         |                                 |  :   :';
dstr[10] := '         | '+str3+                       ' | _;,,,;_   ____';
dstr[11] := '         | '+str4+                       ' |          /    \';
dstr[12] := '         | '+str5+                       ' |          :    :';
dstr[13] := '         | '+str6+                       ' |          :    :';
dstr[14] := '         | '+str7+                       ' |         _;,,,,;_';
dstr[15] := '         |            killed by            |';
dstr[16] := '         | '+str8+                       ' |';
dstr[17] := '         |           '+day+    '           |';
dstr[18] := '        *|   *     *     *    *   *     *  | *';
dstr[19] := '________)/\\_)_/___(\/___(//_\)/_\//__\\(/_|_)_______';
	clear(1,1);
	for i1 := 0 to 19 do
	  dprint(dstr[i1],i1+1);
	flush;
      end;

[global,psect(death$code)] procedure write_tomb;
      var
	fnam    : vtype;
	command : char;
	f1	: text;
	i1      : integer;
	flag	: boolean;
      begin
	if (get_com('Print to file? (Y/N)',command)) then
	  case command of
	    'y','Y':  begin
			prt('Enter Filename:',1,1);
			flag := false;
			repeat
			  if (get_string(fnam,1,17,60)) then
			    begin
			      if (length(fnam) = 0) then fnam:='MORIACHR.DIE';
			      open (f1,file_name:=fnam,error:=continue);
			      if (status(f1) <> 0) then
			        prt('Error creating> ' + fnam,2,1)
			      else
			        begin
				  flag := true;
				  rewrite(f1,error:=continue);
				  for i1 := 0 to 19 do
				    writeln(f1,dstr[i1],error:=continue);
				end;
			      close(f1,error:=continue);
	  		    end
			  else
			    flag := true;
			until(flag);
		      end;
	    otherwise ;
	  end;
      end;

	{ Prints the gravestone of the character		-RAK-	}
    procedure print_tomb;
      var
	fnam					: vtype;
	command					: char;
	i1					: integer;
	flag					: boolean;
	user					: usernam;

  begin
      if (py.misc.lev > 10) then
	begin
    	user := get_username;
	open(f1,file_name:=MORIA_DTH,history:=old,sharing:=none,
	  access_method:=sequential, error:=continue);
	if (status(f1) = 0) then
	  begin
	    extend(f1,error:=continue);
	    if (py.misc.cheated) then
	    writeln(f1, '*',user,py.misc.diffic:2,' ',py.misc.prace:2,' ',
		py.misc.pclass:2,py.misc.lev:3,' ',dun_level:4,' ',
		py.misc.max_lev:4,' ',died_from)
	    else
	    writeln(f1, ' ',user,py.misc.diffic:2,' ',py.misc.prace:2,' ',
		py.misc.pclass:2,py.misc.lev:3,' ',dun_level:4,' ',
		py.misc.max_lev:4,' ',died_from);
	    writeln(f1,'  ',substr(py.misc.ssn,1,44) +' '+show_current_time);
	  end;
	  close(f1,error:=continue);
	end;
	make_tomb;
	write_tomb;
      end;


	{ Calculates the total number of points earned		-JWT-	}
	{ The formula was changed to reflect the difficulty of low exp.
	  modifier classes like warriors			-Cap'n- }
    function total_points : integer;
      begin
	with py.misc do
	  if (expfact = 0) then
	    total_points := max_exp + 100*max_lev
	  else
	    total_points := trunc(max_exp / expfact) + 100*max_lev;
      end;


	{ Allow the bozo to print out his dead character...	-KRC-	}
[global,psect(death$code)] procedure print_dead_character;
      var
	command : char;
      begin
	if (get_com('Print character sheet to file? (Y/N)',command)) then
	  case command of
	    'y','Y': file_character;
	    otherwise ;
	  end;
      end;


	{ Enters a players name on the top twenty list		-JWT-	}
[global,psect(death$code)] procedure top_twenty;
      var
	list		: array [1..max_high_scores] of string;
	blank		: packed array [1..13] of char;
	i1,i2,i3,i4	: integer;
	n1		: integer;
	trys		: integer;
	o1,o2		: vtype;
	f1		: text;
	flag,file_flag	: boolean;
	temp		: ntype;
	ch		: char;
      begin
	if (py.misc.cheated) then exit;
	clear(1,1);
	for i1 := 1 to max_high_scores do
	  list[i1] := '';
	n1 := 1;
	priv_switch(1);
	trys := 0;
	file_flag := false;
	repeat
	  open (f1,file_name:=moria_top,
		organization:=sequential,history:=old,
		sharing:=none,error:=continue);
	  if (status(f1) = 2) then
	    begin
	      trys := trys + 1;
	      if (trys > 5) then
		file_flag := true
	      else
		sleep(2);
	    end
	  else
	    file_flag := true;
	until(file_flag);
	if ((status(f1) <> 0) and (status(f1) <> 2)) then
	  open (f1,file_name:=moria_top,
		organization:=sequential,history:=new,
		sharing:=none,error:=continue);
	if (status(f1) <> 0) then
	  begin
	    writeln('Error in opening ',moria_top);
	    writeln('Please contact local Moria Wizard.');
	    exit;
	  end;
	reset(f1);
	while ((not eof(f1)) and (n1 <= max_high_scores)) do
	  begin
	    readln(f1,temp,error:=continue);
	    seed := encrypt_seed1;
	    decrypt(temp);
	    list[n1] := temp;
	    n1 := n1 + 1;
	  end;
	n1 := n1 - 1;
	i1 := 1;
	i3 := total_points;
	flag := false;
	while ((i1 <= n1) and (not flag)) do
	  begin
	    readv(list[i1],blank,i4,error:=continue);
	    if (i4 < i3) then
	      flag := true
	    else
	      i1 := i1 + 1;
	  end;
	if ((i3 > 0) and ((flag) or (n1 = 0) or (n1 < max_high_scores))) then
	  begin
	    for i2 := max_high_scores-1 downto i1 do
	      list[i2+1] := list[i2];
	    o1 := get_username;
	    writev(list[i1],pad(o1,' ',13),i3:8,' ',py.misc.diffic:1,' ',
		center(py.misc.name,24),' ',py.misc.lev:2,' ',
		center(py.misc.race,10),' ',center(py.misc.tclass,16));
	    if (n1 < max_high_scores) then
	      n1 := n1 + 1;
	    max_score := n1;
	    flag := false;
	  end;
	rewrite(f1);
	for i1 := 1 to n1 do
	  begin
	    temp := list[i1];
	    seed := encrypt_seed1;
	    encrypt(temp);
	    writeln(f1,temp);
	  end;
	close(f1);
	priv_switch(0);
	put_buffer('Username     Points  Diff    Character name    Level  Race         Class',1,1);
	put_buffer('____________ ________ _ ________________________ __ __________ ________________',2,1);
	i2 := 3;
	if (max_score > n1) then max_score := n1;
	for i1 := 1 to max_score do
	  begin
	    insert_str(list[i1],chr(7),'');
	    put_buffer(list[i1],i2,1);
	    if (i1 <> 1) and ((i1 mod 20) = 0) and (i1 <> max_score) then
	      begin
		prt('[Press any key to continue, or <Control>-Z to exit]',
			24,1);
		inkey(ch);
		case ord(ch) of
		  3,25,26 : begin
			      erase_line(24,1);
			      put_buffer(' ',23,13);
			      exit;
			    end;
		  otherwise ;
		end;
		clear(3,1);
		i2 := 2;
	      end;
	    i2 := i2 + 1;
	  end;
	erase_line(23,1);
	put_qio;
      end;


	{ Change the player into a King!			-RAK-	}
    procedure kingly;
      begin
	{ Change the character attributes...		}
	dun_level := 0;
	died_from := 'Ripe Old Age';
	with py.misc do
	  begin
	    lev := lev + max_player_level;
	    if ( characters_sex = male ) then
	      begin
		title  := 'Magnificent';
		tclass := tclass + ' King';
	      end
	    else
	      begin
		title  := 'Beautiful';
		tclass := tclass + ' Queen';
	      end;
	    account := account + 250000;
	    max_exp := max_exp + 5000000;
	    exp := max_exp;
	  end;
	{ Let the player know that he did good...	}
	clear(1,1);
	dprint('                                  #',2);
	dprint('                                #####',3);
	dprint('                                  #',4);
	dprint('                            ,,,  $$$  ,,,',5);
	dprint('                        ,,=$   "$$$$$"   $=,,',6);
	dprint('                      ,$$        $$$        $$,',7);
	dprint('                      *>         <*>         <*',8);
	dprint('                      $$         $$$         $$',9);
	dprint('                      "$$        $$$        $$"',10);
	dprint('                       "$$       $$$       $$"',11);
	dprint('                        *#########*#########*',12);
	dprint('                        *#########*#########*',13);
	dprint('                          Veni, Vidi, Vici!',16);
	dprint('                     I came, I saw, I conquered!',17);
	dprint('                      All Hail the Mighty King!',18);
	flush;
	pause(24);
      end;


	{ What happens upon dying...				-RAK-	}
    begin
      temp := py.misc.ssn;
      seed := encrypt_seed1;
      coder(temp);
      temp_id := temp;
      priv_switch(1);
      open(f2,file_name:=moria_mas,access_method:=keyed,
        organization:=indexed,history:=old,sharing:=readwrite,error:=continue);
      if (status(f2) <> 0) then
      begin
	msg_print('ERROR opening file MASTER.  Contact your local wizard.');
	msg_print('Status = '+itos(status(f1)));
	msg_print(' ');
      end
      else begin
        findk(f2,0,temp_id,error:=continue);
        delete(f2,error:=continue);
      end;
      close(f2,error:=continue);
      priv_switch(0);
      open(f1,file_name:=finam,record_length:=1024,history:=old,
		disposition:=delete,error:=continue);
      close(f1,error:=continue);
      if (total_winner) then kingly;
      print_tomb;
      print_dead_character;
      top_twenty;
      exit;
    end;

End.
