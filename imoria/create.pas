[Inherit('Moria.Env')] Module Create ;

	{ Prints the following information on the screen.	-JWT-	}
[global,psect(create$code)] procedure put_character;
    begin
      clear(1,1);
      with py.misc do
	begin
	  prt('Name      : ' + name,3,3);
	  prt('Race      : ' + race,4,3);
	  prt('Sex       : ' + sex,5,3);
	  prt('Class     : ' + tclass,6,3)
	end
    end;

	{ Prints the following information on the screen.	-JWT-	}
[global,psect(create$code)] procedure put_stats;
    begin
      with py do
	begin
	  prt_6_stats(stat.c,3,65);
	  prt_num('+ To Hit   : ',misc.dis_th,10,4);
	  prt_num('+ To Damage: ',misc.dis_td,11,4);
	  prt_num('+ To AC    : ',misc.dis_tac,12,4);
	  prt_num('  Total AC : ',misc.dis_ac,13,4);
	end
    end;

	{ Updates the following information on the screen. (wow)-KRC-	}
[global,psect(create$code)] procedure upd_stats;
    var tstat : stat_set;
    begin
      with py do
	begin
	  for tstat := sr to ca do
	      prt_stat( '', stat.c[tstat], 3+ord(tstat), 71 );
	  prt_num( '', misc.dis_th, 10, 17 );
	  prt_num( '', misc.dis_td, 11, 17 );
	  prt_num( '', misc.dis_tac,12, 17 );
	  prt_num( '', misc.dis_ac, 13, 17 );
	end
    end;

	{ Prints age, height, weight, and SC			-JWT-	}
[global,psect(create$code)] procedure put_misc1;
    begin
      with py do
	begin
	  prt_num('Age          : ',misc.age	,3,40);
	  prt_num('Height       : ',misc.ht	,4,40);
	  prt_num('Weight       : ',misc.wt	,5,40);
	  prt_num('Social Class : ',misc.sc	,6,40);
	  prt_num('Difficulty   : ',misc.diffic	,7,40);
	end;
    end;

	{ Updates age, height, weight, and SC (amazing, huh?)	-KRC-	}
[global,psect(create$code)] procedure upd_misc1;
    begin
      with py do
	begin
	  prt_num( '', misc.age, 3, 55 );
	  prt_num( '', misc.ht , 4, 55 );
	  prt_num( '', misc.wt , 5, 55 );
	  prt_num( '', misc.sc , 6, 55 );
	end;
    end;

	{ Prints the following information on the screen.	-JWT-	}
[global,psect(create$code)] procedure put_misc2;
    begin
      with py.misc do
	begin
	  prt_num('Level      : ',lev,10,31);
	  prt_num('Experience : ',exp,11,31);
	  prt_num('Gold       : ',money[total$],12,31);
	  prt_num('Account    : ',account,13,31);
	  prt_num('Max Hit Points : ',mhp,10,54);
	  prt_num('Cur Hit Points : ',trunc(chp),11,54);
	  prt_num('Max Mana       : ',mana,12,54);
	  prt_num('Cur Mana       : ',trunc(cmana),13,54);
	end
    end;

	{ Prints ratings on certain abilities			-RAK-	}
[global,psect(create$code)] procedure put_misc3;
      var
	xbth,xbthb,xfos,xsrh,xstl,xdis	: integer;
	xsave,xdev,xswm,xrep		: integer;
	xinfra				: vtype;
      begin
	clear(14,1);
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
	prt('(Miscellaneous Abilities)',16,24);
	put_buffer('Fighting    : '+likert(xbth ,12) ,17, 2);
	put_buffer('Bows/Throw  : '+likert(xbthb,12) ,18, 2);
	put_buffer('Saving Throw: '+likert(xsave, 6) ,19, 2);
	put_buffer('Stealth     : '+likert(xstl , 1) ,17,27);
	put_buffer('Disarming   : '+likert(xdis , 8) ,18,27);
	put_buffer('Magic Device: '+likert(xdev , 7) ,19,27);
	put_buffer('Perception  : '+likert(xfos , 3) ,17,52);
	put_buffer('Searching   : '+likert(xsrh , 6) ,18,52);
	put_buffer('Infra-Vision: '+xinfra,	      19,52);
	put_buffer('Swimming    : '+likert(xswm , 1) ,20,52);
	put_buffer('Reputation  : '+likert(xrep , 1) ,20, 2);
      end;

	{ Used to display the character on the screen.		-RAK-	}
[global,psect(create$code)] procedure display_char;
      var
	dummy	: char;
      begin
	put_character;
	put_misc1;
	put_stats;
	put_misc2;
	put_misc3;
      end;

	{ Gets a name for the character				-JWT-	}
[global,psect(create$code)] procedure get_name;
    begin
      prt('Enter your player''s name  [press <RETURN> when finished]',22,3);
      get_string(py.misc.name,3,15,24);
      clear(21,1);
    end;

	{ Chances the name of the character			-JWT-	}
[global,psect(create$code)] procedure change_name;
    var
	c	: char;
	flag	: boolean;
    begin
      flag := false;
      display_char;
      repeat
	prt('<c>hange character name.     <ESCAPE> to continue.',22,3);
	inkey(c);
	case ord(c) of
	  99		: get_name;
	  0,3,25,26,27	: flag := true;
	  otherwise;
	end;
      until (flag);
    end;

[global,psect(create$code)] procedure create_character;

  var

	printed_once,
 	minning		: boolean;
	try_count	: integer;
	tstat		: stat_set;
	best,user,max_r	: stat_s_type;
	best_min	: integer;

    function old_stat(new_guy : integer) : byteint;
      begin
	if (new_guy<150) then
	  old_stat := (squish_stat(new_guy) + 30) div 10
	else
	  old_stat := squish_stat(new_guy) - 132;
      end;

    function new_stat(old_guy : integer) : byteint;
      begin
	if (old_guy<18) then
	  new_stat := squish_stat(old_guy*10-30)
	else
	  new_stat := squish_stat(old_guy+132)
      end;


	{ Get minimum stats the character wants			-DMF-	}
  procedure get_minimums;
    var
	temp	: integer;
	yes_no	: string;


    function get_min_stat (prompt : string; max : byteint) : integer;
      var
	tmp_str	: string;
	abil	: integer;
	perc	: integer;
	out_str	: string;
      begin
	  if (max = 250) then
	      writev(out_str,'Min ',prompt,' (racial max 18/00) : ')
	  else if (max > 150) then
	      writev(out_str,'Min ',prompt,' (racial max 18/',(max-150):1,') : ')
	  else
	    writev(out_str,'Min ',prompt,' (racial max ',old_stat(max):1,') : ');
	  prt(out_str,1,1);
	  abil := 0;
	  get_string(tmp_str,1,length(out_str)+1,10);
	  if (index(tmp_str,'/') > 0) then
	    begin
	      insert_str(tmp_str,'/',' ');
	      readv(tmp_str,abil,perc,error:=continue);
	      if (abil = 18) then
	        if (perc = 0) then
	          abil := 250
	        else
	          abil := 150 + perc
	    end
	  else
	    begin
	      readv(tmp_str,abil,error:=continue);
	      if (abil < 3) then abil := 3
	      else if (abil > 18) then abil := 18;
	      abil := new_stat(abil)
	    end;
	  get_min_stat := abil;
      end;

    begin
      prt('Do you wish to try for minimum statistics? ',1,1);
      if (get_string(yes_no,1,44,1)) then
	case yes_no[1] of
	  'y','Y' :
    begin
      minning := true;
      user[sr] := get_min_stat('STR',max_r[sr]);
      user[iq] := get_min_stat('INT',max_r[iq]);
      user[ws] := get_min_stat('WIS',max_r[ws]);
      user[dx] := get_min_stat('DEX',max_r[dx]);
      user[cn] := get_min_stat('CON',max_r[cn]);
      user[ca] := get_min_stat('CHR',max_r[ca]);
      prt('Printing Stats...',1,1);
      prt_6_stats(user,3,65);
    end;
	  otherwise ;
	end;
      erase_line(1,1);
    end;


	{ Generates character's stats				-JWT-	}
  function get_stat : integer;
    var
	i	: integer;
    begin
      i := randint(4) + randint(4) + randint(4) + 5;
      get_stat := (i-3)*10;
    end;


	{ Changes stats by given amount				-JWT-	}
  function change_stat(cur_stat,amount : integer) : integer;
    var
	i : integer;
    begin
      if (amount < 0) then
	for i := -1 downto amount do
	  cur_stat := cur_stat - squish_stat(de_statp(cur_stat))
      else
	for i := 1 to amount do
	  cur_stat := cur_stat + squish_stat(in_statp(cur_stat));
      change_stat := cur_stat;
    end;


  function max_in_statp(stat : byteint) : byteint;
    begin
      if (stat < 150) then
	stat := stat + 10
      else if (stat < 220) then
	stat := stat + 25
      else if (stat < 240) then
	stat := stat + 10
      else if (stat < 250) then
	stat := stat + 1;
      max_in_statp := stat;
    end;


  function max_de_statp(stat : byteint) : byteint;
    begin
      if (stat < 11) then
	stat := 0
      else if (stat < 151) then
	stat := stat - 10
      else if (stat < 241) then
	begin
	  stat := stat - 6;
	  if (stat < 150) then stat := 150;
	end
      else
	stat := stat - 1;
      max_de_statp := stat;
    end;


  function max_stat(cur_stat,amount : integer) : integer;
    var
	i : integer;
    begin
      if (amount < 0) then
	for i := -1 downto amount do
	  cur_stat := max_de_statp(cur_stat)
      else
	for i := 1 to amount do
	  cur_stat := max_in_statp(cur_stat);
      max_stat := cur_stat;
    end;


	{ Allows player to select a race			-JWT-	}
  function choose_race : boolean;
    var
	i2,i3,i4,i5		: integer;
	s			: char;
	exit_flag		: boolean;
    begin
      i2 := 1;
      i3 := 1;
      i4 := 3;
      i5 := 22;
      clear(21,1);
      prt('Choose a race (? for Help):',21,3);
      repeat
	put_buffer (chr(i3+96)+') '+race[i2].trace,i5,i4);
	i3 := i3 + 1;
	i4 := i4 + 15;
	if (i4 > 70) then
	  begin
	    i4 := 3;
	    i5 := i5 + 1
	  end;
	i2 := i2 + 1
      until (i2 > max_races);
      py.misc.race := '';
      put_buffer('',21,30);
      exit_flag := false;
      repeat
	inkey_flush(s);
	i2 := index('abcdefghijklmnopqrstuvwxyz',s);
	if ((i2 <= max_races) and (i2 >= 1)) then
	  begin
	    py.misc.prace  := i2;
	    py.misc.race   := race[i2].trace;
	    exit_flag := true;
	    choose_race := true;
	    put_buffer(py.misc.race,4,15);
	  end
	else if (s = '?') then
	  begin
	    moria_help('Character Races');
	    exit_flag := true;
	    choose_race := false;
	  end;
      until (exit_flag);
    end;

  procedure print_try_count;
    var
	out_str	: string;
    begin
      writev(out_str,'Try = ',try_count:10);
      put_buffer(out_str,21,60);
      put_qio;
    end;

  function next_best_stats(this : stat_s_type) : integer;
    var
	below,below_sum	: integer;
	tstat		: stat_set;
    begin
      below_sum := 0;
      for tstat := sr to ca do
	if (this[tstat] < user[tstat]) then begin
	  below := user[tstat] - this[tstat];
	  below_sum := below_sum + ((below*(below+1)) div 2);
	end;
      if (below_sum < best_min) then
	begin
	  for tstat := sr to ca do
	    best[tstat] := this[tstat];
	  next_best_stats := below_sum;
	end
      else
	next_best_stats := best_min;
    end;

  function satisfied : boolean;
	forward;

	{ What does it take to satisfy the guy?!		-KRC-	}
  function satisfied;
    var
	s	: char;
	tstat	: stat_set;
    begin
      if not(minning) then
       begin
        if not printed_once then
	  begin
	    clear(21,1);
	    put_misc1;
	    put_stats;
	    prt( 'Press <LF> to reroll, any other key to continue:', 21, 3 );
	    printed_once := true;
	  end
        else
	  begin
	    upd_misc1;
	    upd_stats;
	    prt( '', 21, 51 );
	  end;
        inkey_flush(s);
	satisfied := (ord(s) <> 10);
       end
      else
	begin
	  if not printed_once then
	    begin
	      clear(21,1);
	      prt('Press any key to give up (10000 rolls max): ',21,3);
	      printed_once := true;
	    end;
	  best_min := next_best_stats(py.stat.p);
	  try_count := try_count + 1;
	  if (try_count mod 250) = 0 then print_try_count;
	  inkey_delay(s,0);
	  if ((s <> null) or (try_count = 10000)) then
	    begin
	      minning := false;
	      printed_once := false;
	      for tstat := sr to ca do begin
		py.stat.p[tstat] := best[tstat];
		py.stat.c[tstat] := best[tstat];
	      end;
	      satisfied := satisfied;
	    end
	  else
	    begin
	      satisfied := (best_min = 0);
	      if (best_min = 0) then
		begin
		  put_misc1;
  		  put_stats;
		end;
	    end;
	end;
    end;

	{ Get the statistics for this bozo			-KRC-	}
  procedure get_stats;
      var tstat : stat_set;
      begin
      with py do
	with race[misc.prace] do
	  begin
	    for tstat := sr to ca do
	      begin
		stat.p[tstat] := change_stat(get_stat,adj[tstat]);
		stat.c[tstat]  := stat.p[tstat];		
	      end;
	    misc.rep:= 0;
	    misc.srh    := srh;
	    misc.bth    := bth;
	    misc.bthb   := bthb;
	    misc.fos    := fos;
	    misc.stl    := stl;
	    misc.save   := bsav;
	    misc.hitdie := bhitdie;
	    misc.lev    := 1;
	    misc.ptodam := todam_adj;
	    misc.ptohit := tohit_adj;
	    misc.ptoac  := 0;
	    misc.pac    := toac_adj;
	    misc.expfact:= b_exp;
	    flags.see_infra := infra;
	    flags.swim	:= swim;
	  end;
    end;

	{ Will print the history of a character			-JWT-	}
  procedure print_history;
    var
	i1		: integer;
    begin
      clear(14,1);
      put_buffer('Character Background',14,28);
      for i1 := 1 to 5 do
	put_buffer(py.misc.history[i1],i1+14,5)
    end;


	{ Get the racial history, determines social class	-RAK-	}
	{ Assumtions:	Each race has init history beginning at 	}
	{		(race-1)*3+1					}
	{		All history parts are in ascending order	}
  procedure get_history;
    var
	hist_ptr,cur_ptr,test_roll	: integer;
	start_pos,end_pos,cur_len	: integer;
	line_ctr,new_start,social_class	: integer;
	history_block			: varying [400] of char;
	flag				: boolean;
    begin
	{ Get a block of history text				}
      hist_ptr := (py.misc.prace-1)*3 + 1;
      history_block := '';
      social_class := randint(4);
      cur_ptr := 0;
      repeat
	flag := false;
	repeat
	  cur_ptr := cur_ptr + 1;
	  if (background[cur_ptr].chart = hist_ptr) then
	    begin
	      test_roll := randint(100);
	      while (test_roll > background[cur_ptr].roll) do
		cur_ptr := cur_ptr + 1;
	      with background[cur_ptr] do
		begin
		  history_block := history_block + info;
		  social_class := social_class + bonus;
		  if (hist_ptr > next) then cur_ptr := 0;
		    hist_ptr := next;
		end;
	      flag := true;
	    end;
	until(flag);
      until(hist_ptr < 1);
	{ Process block of history text for pretty output	}
      start_pos := 1;
      end_pos   := length(history_block);
      line_ctr  := 1;
      flag := false;
      while (history_block[end_pos] = ' ') do
	end_pos := end_pos - 1;
      repeat
	while (history_block[start_pos] = ' ') do
	  start_pos := start_pos + 1;
	cur_len := end_pos - start_pos + 1;
	if (cur_len > 70) then 
	  begin;
	    cur_len := 70;
	    while (history_block[start_pos+cur_len-1] <> ' ') do
	      cur_len := cur_len - 1;
	    new_start := start_pos + cur_len;
	    while (history_block[start_pos+cur_len-1] = ' ') do
	      cur_len := cur_len - 1;
	  end
	else
	  flag := true;
	py.misc.history[line_ctr] := substr(history_block,start_pos,cur_len);
	line_ctr := line_ctr + 1;
	start_pos := new_start;
      until(flag);
      for line_ctr := line_ctr to 5 do py.misc.history[line_ctr] := '';
	{ Compute social class for player			}
      if (social_class > 100) then 
	social_class := 100
      else if(social_class < 1) then
	social_class := 1;
      py.misc.rep := 50 - social_class;
      py.misc.sc := social_class;
    end;


	{ Gets the character's sex				-JWT-	}
  function get_sex : boolean;
    var
	s     			: char;
	exit_flag		: boolean;
    begin
      if (py.misc.prace = 10) then begin
	py.misc.sex := 'Female';
	get_sex := true;
	exit_flag := true;
	prt(py.misc.sex,5,15);
      end
      else begin
      py.misc.sex := '';
      clear(21,1);
      prt('Choose a sex (? for Help):',21,3);
      prt('m) Male       f) Female',22,3);
      prt('',21,29);
      repeat
	inkey_flush(s);
	case s of
	  'f' : begin
		  py.misc.sex := 'Female';
		  prt(py.misc.sex,5,15);
		  exit_flag := true;
		  get_sex := true;
		end;
	  'm' : begin
		  py.misc.sex := 'Male';
		  prt(py.misc.sex,5,15);
		  exit_flag := true;
		  get_sex := true;
		end;
	  '?' : begin
		  moria_help('Character Sex');
		  exit_flag := true;
		  get_sex := false;
		end;
	  otherwise ;
	 end;
      until (exit_flag);
      end;
    end;


	{ Computes character's age, height, and weight		-JWT-	}
  procedure get_ahw;
    var
	i1 	: integer;
    begin
      i1 := py.misc.prace;
      py.misc.age := race[i1].b_age + randint(race[i1].m_age);
      with py.misc.birth do
	begin
	  year := 500 + randint(50);
	  month := randint(13);
	  day := randint(28);
	  hour := randint(24)-1;
	  secs := randint(400)-1;
	end;
      with py.misc.cur_age do
	begin
	  year := py.misc.age + py.misc.birth.year;
	  month := py.misc.birth.month;
	  day := py.misc.birth.day + 1;
	  if ((day mod 7) = 0) then
	    add_days(py.misc.cur_age,2);
	  if ((day mod 7) = 1) then
	    add_days(py.misc.cur_age,1);
	  hour := 7;
	  secs := 300 + randint(99);
	end;
      case characters_sex of
	female :
	  begin
	    py.misc.ht := randnor(race[i1].f_b_ht,race[i1].f_m_ht);
	    py.misc.wt := randnor(race[i1].f_b_wt,race[i1].f_m_wt)
	  end;
	male :
	  begin
	    py.misc.ht := randnor(race[i1].m_b_ht,race[i1].m_m_ht);
	    py.misc.wt := randnor(race[i1].m_b_wt,race[i1].m_m_wt)
	  end
      end;
      py.misc.disarm := race[i1].b_dis + todis_adj;
    end;


	{ Gets a character class				-JWT-	}
  function get_class : boolean;
    var
	i1,i2,i3,i4,i5		: integer;
	cl			: array [0..max_class] of integer;
	s			: char;
	exit_flag		: boolean;
	tstat			: stat_set;
    begin
      for i2 := 1 to max_class do cl[i2] := 0;
      i1 := py.misc.prace;
      i2 := 1;
      i3 := 0;
      i4 := 3;
      i5 := 22;
      clear(21,1);
      prt('Choose a class (? for Help):',21,3);
      repeat
	if (uand(race[i1].tclass,bit_array[i2]) <> 0) then
	  begin
	    i3 := i3 + 1;
	    put_buffer (chr(i3+96)+') '+class[i2].title,i5,i4);
	    cl[i3] := i2;
	    i4 := i4 + 15;
	    if (i4 > 70) then
	      begin
		i4 := 3;
		i5 := i5 + 1
	      end;
	  end;
	i2 := i2 + 1;
      until (i2 > max_class);
      py.misc.pclass := 0;
      put_buffer('',21,31);
      exit_flag := false;
      repeat
	inkey_flush(s);
	i2 := index('abcdefghijklmnopqrstuvwxyz',s);
	if ((i2 <= i3) and (i2 >= 1)) then
	  begin
	    py.misc.tclass := class[cl[i2]].title;
	    py.misc.pclass := cl[i2];
	    exit_flag := true;
	    get_class := true;
	    clear(21,1);
	    put_buffer(py.misc.tclass,6,15);
	    with py.misc do
	      begin
	        hitdie := hitdie + class[pclass].adj_hd;
                mhp    := con_adj + hitdie;
	        chp	 := mhp;
                bth    := bth     + class[pclass].mbth * 5 + 20;
	        bthb   := bthb    + class[pclass].mbthb * 5 + 20; 
                srh    := srh     + class[pclass].msrh;
                disarm := disarm  + class[pclass].mdis;
                fos    := fos     + class[pclass].mfos;
                stl    := stl     + class[pclass].mstl;
	        save   := save    + class[pclass].msav;
                title  := player_title[pclass,1];
	        expfact:= expfact + class[pclass].m_exp;
		case pclass of
		  1	: mr := -10;
		  2,3	: mr := 0;
		otherwise mr := -5;
		end;
	      end;
	{ Adjust the stats for the class adjustment		-RAK-	}
            with py do
	      begin
		for tstat := sr to ca do
		  begin
		    stat.p[tstat] := change_stat(stat.p[tstat],
				class[misc.pclass].madj[tstat]);
		    stat.c[tstat] := stat.p[tstat];
		  end;
	        misc.ptodam := todam_adj;	{ Real values		}
	        misc.ptohit := tohit_adj;
	        misc.ptoac  := toac_adj;
	        misc.pac    := 0;
		misc.dis_td := misc.ptodam;	{ Displayed values	}
		misc.dis_th := misc.ptohit;
		misc.dis_tac:= misc.ptoac;
		misc.dis_ac := misc.pac;
	      end;
	  end
	else if (s = '?') then
	  begin
	    moria_help('Character Classes');
	    exit_flag := true;
	    get_class := false;
	  end;
      until(exit_flag);
    end;


  procedure get_money;
    var
	tmp,i1			: integer;
	tstat			: stat_set;
    begin
	with py.stat do
	 begin
	  tmp := 0;
	  for tstat := sr to ca do
	    tmp := tmp + old_stat(c[tstat]);
	 end;
	i1 := py.misc.sc*6 + randint(25) + 325;{ Social Class adj	}
	i1 := i1 - tmp;			{ Stat adj		}
	i1 := i1 + old_stat(py.stat.c[ca]);	{ Charisma adj	}
	if (i1 < 80) then i1 := 80;		{ Minimum		}
	i1 := i1 * gold$value + randint(gold$value);
	add_money(i1);
    end;

	{ Get social security number				-KRC-	}
[global,psect(create$code)] procedure get_ssn;

    [external] procedure lib$date_time	(
			%DESCR time : vtype
					); external;

    var

	account				: packed array [1..8] of char;
	time				: vtype;

    begin

      lib$date_time( time );
      get_account( account );
      py.misc.ssn := '$ < ' + account + ' > - # ' + time + ' # ' + py.misc.name;

    end;

	{ ---------- M A I N  for Character Creation Routine ---------- }
	{							-JWT-	}

  begin
    with py do
      begin
	{ This delay may be reduced, but is recomended to keep players	}
	{ from continuously rolling up characters, which can be VERY	}
	{ expensive CPU wise.						}
	for tstat := sr to ca do
		best[tstat] := 3;
	best_min := 999999999;
	minning := false;
	try_count := 0;
	repeat
	  put_character;
	until(choose_race);
	while (not(get_sex)) do put_character;
	printed_once := false;
	with race[py.misc.prace] do
	  for tstat := sr to ca do
	    max_r[tstat] := max_stat(140,adj[tstat]);
	get_minimums;
	repeat
	  get_stats;
	  get_history;
	  get_ahw;
	until satisfied;
	print_history;
	while (not(get_class)) do
	  begin
	    put_character;
	    print_history;
	    put_misc1;
	    put_stats;
	  end;
	get_money;
	put_stats;
	put_misc2;
	put_misc3;
	get_name;
	get_ssn;
	pause_exit(24,player_exit_pause);
      end
  end;


[global,psect(create$code)] procedure set_gem_values;

var
	count		: integer;

begin
for count := 1 to max_objects do 
 begin
   with object_list[count] do
     if ((index(name,'Finely cut') <> 0) and (index(name,'of') <> 0)) then
      begin
	if (index(name,'Amber') <> 0) then cost := cost + 1000;
	if (index(name,'Agate') <> 0) then cost := cost + 1000;
	if (index(name,'Alexandrite') <> 0) then cost := cost + 5000;
	if (index(name,'Amathyst') <> 0) then cost := cost + 2000;
	if (index(name,'Antlerite') <> 0) then cost := cost + 1000;
	if (index(name,'Aquamarine') <> 0) then cost := cost + 6000;
	if (index(name,'Argentite') <> 0) then cost := cost + 1000;
	if (index(name,'Azurite') <> 0) then cost := cost + 1000;
	if (index(name,'Beryl') <> 0) then cost := cost + 2000;
	if (index(name,'Bloodstone') <> 0) then cost := cost + 3500;
	if (index(name,'Calcite') <> 0) then cost := cost + 1500;
	if (index(name,'Carnelian') <> 0) then cost := cost + 1000;
	if (index(name,'Coral') <> 0) then cost := cost + 1000;
	if (index(name,'Corundum') <> 0) then cost := cost + 1000;
	if (index(name,'Cryolite') <> 0) then cost := cost + 1000;
	if (index(name,'Diamond') <> 0) then cost := cost + 35000;
	if (index(name,'Diorite') <> 0) then cost := cost + 1000;
	if (index(name,'Emerald') <> 0) then cost := cost + 20000;
	if (index(name,'Flint') <> 0) then cost := cost + 5000;
	if (index(name,'Fluorite') <> 0) then cost := cost + 1000;
	if (index(name,'Gabbro') <> 0) then cost := cost + 5000;
	if (index(name,'Garnet') <> 0) then cost := cost + 6500;
	if (index(name,'Granite') <> 0) then cost := cost + 500;
	if (index(name,'Gypsum') <> 0) then cost := cost + 3000;
	if (index(name,'Hematite') <> 0) then cost := cost + 1000;
	if (index(name,'Jade') <> 0) then cost := cost + 12000;
	if (index(name,'Jasper') <> 0) then cost := cost + 3000;
	if (index(name,'Kryptonite') <> 0) then cost := cost + 5000;
	if (index(name,'Lapus lazuli') <> 0) then cost := cost + 4500;
	if (index(name,'Limestone') <> 0) then cost := cost + 1000;
	if (index(name,'Malachite') <> 0) then cost := cost + 3000;
	if (index(name,'Manganite') <> 0) then cost := cost + 5000;
	if (index(name,'Marble') <> 0) then cost := cost + 5500;
	if (index(name,'Mica') <> 0) then cost := cost + 1500;
	if (index(name,'Moonstone') <> 0) then cost := cost + 3000;
	if (index(name,'Neptunite') <> 0) then cost := cost + 1000;
	if (index(name,'Obsidian') <> 0) then cost := cost + 2500;
	if (index(name,'Onyx') <> 0) then cost := cost + 1500;
	if (index(name,'Opal') <> 0) then cost := cost + 1000;
	if (index(name,'Pearl') <> 0) then cost := cost + 11500;
	if (index(name,'Pyrite') <> 0) then cost := cost + 1000;
	if (index(name,'Quartz') <> 0) then cost := cost + 1000;
	if (index(name,'Quartzite') <> 0) then cost := cost + 1500;
	if (index(name,'Rhodonite') <> 0) then cost := cost + 1000;
	if (index(name,'Rhyolite') <> 0) then cost := cost + 1000;
	if (index(name,'Ruby') <> 0) then cost := cost + 14500;
	if (index(name,'Sapphire') <> 0) then cost := cost + 14500;
	if (index(name,'Sphalerite') <> 0) then cost := cost + 1000;
	if (index(name,'Staurolite') <> 0) then cost := cost + 1000;
	if (index(name,'Tiger eye') <> 0) then cost := cost + 8500;
	if (index(name,'Topaz') <> 0) then cost := cost + 1000;
	if (index(name,'Turquoise') <> 0) then cost := cost + 3000;
	if (index(name,'Zircon') <> 0) then cost := cost + 1000;
      end;
   end;
 end;
End.
