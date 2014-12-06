[inherit('moria.env','dungeon.env')] module wizard;
type
	data_array	= array [1..max_objects] of treasure_type;
	{ Print Moria credits					-RAK-	}
[global,psect(misc1$code)]    procedure game_version;
      var
	tmp_str			: vtype;
      begin
	clear(1,1);
	writev(tmp_str,'               Moria Version ',cur_version:3:2);
put_buffer(tmp_str,1,1);
put_buffer('Version 0.1  : 03/25/83',2,1);
put_buffer('Version 1.0  : 05/01/84',3,1);
put_buffer('Version 2.0  : 07/10/84',4,1);
put_buffer('Version 3.0  : 11/20/84',5,1);
put_buffer('Version 4.0  : 01/20/85',6,1);
put_buffer('Modules :',8,1);
put_buffer('     V1.0  Dungeon Generator      - RAK',9,1);
put_buffer('           Character Generator    - RAK & JWT',10,1);
put_buffer('           Moria Module           - RAK',11,1);
put_buffer('           Miscellaneous          - RAK & JWT',12,1);
put_buffer('     V2.0  Town Level & Misc      - RAK',13,1);
put_buffer('     V3.0  Internal Help & Misc   - RAK',14,1);
put_buffer('     V4.0  Source Release Version - RAK',15,1);
put_buffer('Robert Alan Koeneke               Jimmey Wayne Todd Jr.',17,1);
put_buffer('Student/University of Oklahoma    Student/University of Oklahoma',18,1);
put_buffer('119 Crystal Bend                  1912 Tiffany Dr.',19,1);
put_buffer('Norman, OK 73069                  Norman, OK  73071',20,1);
put_buffer('(405)-321-2925                    (405) 360-6792',21,1);
	pause(24);
	draw_cave;
      end;


	{ Light up the dungeon					-RAK-	}
[global,psect(wizard$code)]  procedure wizard_light;
    var
	i1,i2,i3,i4	: integer;
	flag		: boolean;
    begin
      if (cave[char_row,char_col].pl) then
	flag := false
      else
	flag := true;
      for i1 := 1 to cur_height do
	for i2 := 1 to cur_width do
	  if (cave[i1,i2].fval in floor_set) then
	    for i3 := i1-1 to i1+1 do
	      for i4 := i2-1 to i2+1 do
		with cave[i3,i4] do
		  begin
		    pl := flag;
		    if (not(flag)) then
		      fm := false;
		  end;
      prt_map;
      detect_trap ;
      detect_sdoor ;
    end;

	{ Wizard routine for summoning a specific monster       -RAD-   }
  [global,psect(wizard$code)] procedure monster_summon_by_name(
		y,x	: integer;
		name	: ctype;
		present	: boolean;
		sleepy	: boolean);
    var
	i1,i2,i3,i4 		: integer;
	monster			: ctype;
	junk			: boolean;
    begin
      if not(present) then
	begin
	  prt('Monster desired:  ',1,1);
	  junk := (get_string(monster,1,19,26));
	end
      else
	begin
	  monster := name;
	  junk := true;
	end;
      if junk then begin
	i2 := 0;
	readv(monster,i2,error:=continue);
	if (i2 < 0) then i2 := 1;
	if (i2 > max_creatures) then i2 := max_creatures;
	if (i2 > 0) and (i2 <= max_creatures) then
	  begin
	    i1 := 0;
	    repeat
	      i3 := y - 2 + randint(3);
	      i4 := x - 2 + randint(3);
	      if (in_bounds(i3,i4)) then
		with cave[i3,i4] do
		  if (fval in floor_set) then
		    if (fopen) then
		      begin
			place_monster(i3,i4,i2,sleepy);
			i1 := 8;
			y := i3;
			x := i4;
		      end;
	      i1 := i1 + 1;
	    until (i1 > 8);
	  end
	else
	for i2 := 1 to max_creatures do
	    if (index(c_list[i2].name,monster)<>0) AND (i1<>10) then
		begin
		   i1 := 0;
		   repeat
			i3 := y - 2 + randint(3);
			i4 := x - 2 + randint(3);
			if (in_bounds(i3,i4)) then
			   with cave[i3,i4] do
			      if (fval in floor_set) then
				 if (cptr=0) then
				    if (fopen) then
				       begin
					  place_monster(i3,i4,i2,sleepy);
					  i1 := 9;
					  y := i3;
					  x := i4;
				       end;
			i1 := i1 + 1;
		   until (i1>9);
		end;
      end;
      if not(present) then erase_line(msg_line,msg_line);
    end;


	{ Wizard routine to pick an item from the entire list, and
	  magic it until satisfied				-DMF-	}
  function wizard_moo_item(var back : treasure_type) : boolean;
    const
	display_size = 18;
    type
	list_elem = record
		data	: treasure_type;
		next	: ^list_elem;
	end;
	list_elem_ptr = ^list_elem;
    var
	data_list	: list_elem_ptr;
	cur_top		: list_elem_ptr;
	blegga		: list_elem_ptr;
	curse		: list_elem_ptr;
	cur_display	: array [1..display_size] of list_elem_ptr;
	cur_display_size: integer;
	i1,i2,i3,i4	: integer;
	temp		: string;
	exit_flag	: boolean;	
    procedure init_data_list; 
            { Code streamlined a bit by Dean Yasuda, to eliminate the
              inefficient quicksort/shell-sort combination.  Exact duplicate
              items eliminated from output list.              --MAV }
      var
	temp_ray	: data_array;
	i1,i2,i3,gap,l,r: integer;
	tmp		: treasure_type;
	out_val		: string;
      begin
	for i1 := 1 to max_objects do
	  temp_ray[i1] := object_list[i1];
	gap := max_objects div 2;
	while (gap > 0) do
	  begin
	    for i1 := gap + 1 to max_objects do
	      begin
		i2 := i1 - gap;
		while (i2 > 0) do
		  begin
		    i3 := i2 + gap;
		    if ((temp_ray[i2].tval > temp_ray[i3].tval) or
                     ((temp_ray[i2].tval=temp_ray[i3].tval) and
                     (temp_ray[i2].subval>temp_ray[i3].subval))) then
		      begin
			tmp := temp_ray[i2];
			temp_ray[i2] := temp_ray[i3];
			temp_ray[i3] := tmp;
		      end
		    else
		      i2 := 0;
		    i2 := i2 - gap;
		  end;
	      end;
	    gap := gap div 2;
	  end;
	new(data_list);
	curse := data_list;
	curse^.data := temp_ray[1];
	for i1 := 2 to max_objects do
         if ((temp_ray[i1].tval <> temp_ray[i1-1].tval) or
             (temp_ray[i1].subval <> temp_ray[i1-1].subval)) then    
	  begin
	    new(curse^.next);
	    curse := curse^.next;
	    curse^.data := temp_ray[i1];
	    curse^.next := nil;
	  end;
      end;
    procedure display_commands;
      begin
	prt('You may:',22,1);
	prt(' p) Pick an item.              b) Browse to next page.',23,1);
	prt('^Z) Exit.                     ^R) Redraw screen.',24,1);
      end;
    procedure display_list(start : list_elem_ptr);
      var
	count,old_display_size	: integer;
      begin
	old_display_size := cur_display_size;
	count := 0;
	while (start <> nil) and (count < display_size) do
	  begin
	    count := count + 1;
	    if (cur_display[count] <> start) then
	      begin
		cur_display[count] := start;
		writev(temp,chr(96+count),') ',start^.data.name);
		prt(temp,count+1,1);
	      end;
	    start := start^.next;
	  end;
	cur_display_size := count;
	while (old_display_size > cur_display_size) do
	  begin
	    erase_line(old_display_size+3,1);
	    cur_display[old_display_size] := nil;
	    old_display_size := old_display_size - 1;
	  end;
	if (start = nil) then
	  blegga := data_list
	else
	  blegga := start;
      end;
    procedure clear_display;
      begin
	cur_display_size := 0;
	for i4 := 1 to display_size do
	  cur_display[i4] := nil;
      end;
    procedure display_screen;
      begin
	clear(1,1);
	clear_display;
	display_list(cur_top);
	display_commands;
      end;
    function get_list_entry(
		var com_val	: integer;
		pmt		: vtype;
		i1,i2		: integer) : boolean;
      var
	command	: char;
	flag	: boolean;
      begin
	com_val := 0;
	flag := true;
	writev(temp,'(Entries ',chr(i1+96),'-',chr(i2+96),', ^Z to exit) ',
		       pmt);
	while (((com_val < i1) or (com_val > i2)) and (flag)) do
	  begin
	    prt(temp,1,1);
	    inkey(command);
	    com_val := ord(command);
	    case com_val of
	      3,25,26,27 : flag := false;
	      otherwise com_val := com_val - 96;
	    end;
	  end;
	erase_line(1,1);
	get_list_entry := flag;
      end;
    procedure parse_command;
      var
	command		: char;
	com_val,which	: integer;
      begin
	if get_com('',command) then
	  begin
	    com_val := ord(command);
	    case com_val of
{^R}	      18 : display_screen;
{b}	      98 : begin
		    if (cur_top = blegga) then
		      prt('Entire list is displayed.',1,1)
		    else
		      begin
			cur_top := blegga;
			display_list(cur_top);
		      end;
		   end;
{p}	     112 : begin
		     if (cur_display_size > 0) then
		       if (get_list_entry(which,' Pick which one?',1,
					  cur_display_size)) then
			 begin
			   exit_flag := true;
			   wizard_moo_item := true;
			   back := cur_display[which]^.data;
			 end;
		   end;
	      otherwise prt('Invalid command',1,1);
	    end;
	  end
	else
	  exit_flag := true;
      end;

    begin
      back := blank_treasure;
      init_data_list;
      exit_flag := false;
      cur_top := data_list;
      display_screen;
      wizard_moo_item := false;
      while not exit_flag do parse_command;
    end;


	{ Wizard routine to summon a random item by substring(s) of its
	  name, with a maximum # of tries			-DMF-	}
  [global,psect(wizard$code)] function summon_item (
		y,x	: integer;
		name1	: ttype;
		name2	: ttype;
		count	: integer;
		present : boolean) : boolean;

    const
	low_num = -987654321;
    var
	i1,i2,num_found		: integer;
	optimize		: integer;
	best_value,good_value	: integer;
	best_pick,good_pick	: treasure_type;
	flag,done,found		: boolean;
	out_str			: string;
	cur_pos			: integer;
	command			: char;
	moo_item		: data_array;
	moo_cursor		: array [1..max_objects] of integer;


{ask wizard for item information/Moo!, Moo./Moo?}
      function get_item_descriptions : boolean;
        var ook : boolean;

{prompts for new string, <CR> leaves old value}
	function get_new_ttype(var s : ttype; str : vtype) : boolean;
          var os : ttype;
	  begin
	    get_new_ttype := false;
	    if (length(s) > 0) then
	      writev(out_str,str,' [',s,'] : ')
	    else
	      writev(out_str,str,' : ');
	    prt(out_str,1,1);
	    os := s;
	    if (get_string(s,1,length(out_str)+1,40)) then
	      begin
		get_new_ttype := true;
		if ((length(os) > 0) and (length(s) = 0)) then
	  	  s := os;
	      end;
	  end; { get_new_ttype }

	begin
          get_item_descriptions := false;
	  if get_new_ttype(s1,'Item string') then
	    begin
	      ook := true;	
	      if (index(s1,'Moo!') = 1) then
		begin
		  moo_item[1] := blank_treasure;
		  ook := wizard_moo_item(moo_item[1]);
		  if ook then
		    begin
		      found := true;
		      num_found := 1;
		    end;	
		  draw_cave;
		end;
	      if ook then
	       if get_new_ttype(s2,'More stuff #1') then
		if get_new_ttype(s3,'More stuff #2') then
		 if get_new_ttype(s4,'Special') then
		  begin
		    if (i_summ_count > 0) then
	      		writev(out_str,'Maximum number of tries: [',i_summ_count:1,'] : ')
		    else
		      out_str := 'Maximum number of tries: ';
		    prt(out_str,1,1);
		    if (get_string(out_str,1,length(out_str)+1,60)) then
		      get_item_descriptions := true
		  end
	    end
	end; { get_item_descriptions }

{ use 3 substrings to narrow down specify possible items }
      function narrow_choices : boolean;
	var i1,i2 : integer;

  { eliminate all items without string s from array moo_cursor }
	function narrow(var s : ttype) : boolean;
          begin
	    narrow := false;
	    i2 := 1;
	    if (length(s) > 0) then 
	      for i1 := 1 to num_found do
	  	if (index(object_list[moo_cursor[i1]].name,s) > 0) then
	  	  begin
		    moo_cursor[i2] := moo_cursor[i1];
	  	    i2 := i2 + 1;
	          end;
	    if (i2 > 1) then
	      begin
		narrow := true;	{at least one feasible substring found}
		num_found := i2 - 1;
	      end
          end; { narrow }

	begin
	  narrow_choices := false;
	  for i1 := 1 to max_objects do
	    moo_cursor[i1] := i1;
	  num_found := max_objects;
	  if (narrow(s1)) then
	    begin
	      narrow_choices := true;
	      if narrow(s2) then
		narrow(s3);
	      for i1 := 1 to num_found do
		moo_item[i1] := object_list[moo_cursor[i1]];
	    end;
	end; { narrow_choices }

{ init variables, see if optimizing (1=best, -1= worst); find # of tries } 
      procedure pesky_stuff;
	var omax : integer;
	begin
	  best_value := low_num;
	  good_value := low_num;
	  best_pick := yums[5]; {rice-a-roni}
	  good_pick := yums[5];
	  if (index(s4,'Moo.') > 0) then
	        optimize := 1
	  else if (index(s4,'Moo?') > 0) then
	      optimize := -1
	  else
	    optimize := 0;
	  omax := i_summ_count;
	  readv(out_str,i_summ_count,error:=continue);
	  if (i_summ_count = 0) then
	    i_summ_count := omax;
	  if (i_summ_count <= 0) then
	    i_summ_count := 1;
	  popt(cur_pos);
	  cave[y,x].tptr := cur_pos;
	end;

{ formula for comparing value of items}
      function optimize_item(var pick : treasure_type;
				var value : integer) : boolean;
	var i1 : integer;
	begin
	  optimize_item := false;
	  with t_list[cur_pos] do
	    begin
	      i1 := optimize * (cost + tohit + todam + toac);
	      if (i1 > value) then
		  begin
		    value := i1;
		    pick := t_list[cur_pos];
		    optimize_item := true;
		  end;
	    end;
	end;

    begin
      summon_item := false;
      found := false;
      done := false;
      if present then
	begin
	  flag := (length(name1) <> 0);
	  s1 := name1;
	  s2 := name2;
	  s3 := '';
	  s4 := 'Moo.';
	  writev(out_str,count:1);
	end
      else
	flag := get_item_descriptions; {found := true iff successful Moo!}
      if (flag) then
	begin
	  pesky_stuff;
	  if (not found) then
	    found := narrow_choices;  {create array of all ok choices}
	  if (found) then
	   begin
	    if (not present) then
	      begin
	        msg_print('Press any key to abort...');
	        put_qio;
	      end;
	    i1 := 0;
	    while (i1 < i_summ_count) and (not done) do
	      begin
	        t_list[cur_pos]:=moo_item[((num_found*i1) div i_summ_count)+1];
		if (not present) then
		  begin
		    inkey_delay(command,0);
		    done := (command <> null);
		  end;
		magic_treasure(cur_pos,1000);
		if (((length(s2) = 0) or (index(t_list[cur_pos].name,s2) <> 0)) and
	 	   ((length(s3) = 0) or (index(t_list[cur_pos].name,s3) <> 0))) then
		  begin
		    if optimize_item(best_pick,best_value) then
	{ leave loop prematurely if not optimizing and item is found }
		      if (optimize = 0) then
			done := true
		  end
	{ while no correct pick, get best non-correct item }
		else if ((optimize <> 0) and (best_value = low_num)) then
		  optimize_item(good_pick,good_value);
		i1 := i1 + 1
	      end;	{ while }
	   end;
	  if (best_value > low_num) then
	    begin
	      msg_print('Allocated.');
	      t_list[cur_pos] := best_pick;
	      with t_list[cur_pos] do
		if (subval > 255) then
		  begin
		    i2 := cost;
		    if (i2 < 3) then i2 := 3;
		    number:=trunc(i_summ_count/sqrt(100*i2 div gold$value));
		    if (number < 1) then number := 1
		    else if (number > 100) then number := 100;
		  end;
	    end
	  else if (good_value > low_num) then
	    begin
	      msg_print('Found, but not perfect match.');
	      t_list[cur_pos] := good_pick;
	    end
	  else
	    begin
	      msg_print('Unfortunately your wish did not come true.');
    msg_print('You have, however, been awarded a valuable consolation gift!'); 
	      t_list[cur_pos] := yums[5]; {rice}
	      t_list[cur_pos].number := 12;
	    end;
	  summon_item := true;
	end	{ if flag }
      else
	msg_print('Invalid input');
    end;


	{ Wizard routine for gaining on stats			-RAK-	}
[global,psect(wizard$code)]  procedure change_character;
    var
	tmp_val			: integer;
	tmp_str			: vtype;
	flag			: boolean;
    label
	abort;
    function input_field(
		prompt		: string;
		var num		: integer;
		min,max		: integer;
		var ok		: boolean) : boolean;
      var
	out_val	: string;
	len	: integer;
      begin
	writev(out_val,'Current = ',num:1,', ',prompt);
	len := length(out_val);
	prt(out_val,1,1);
	if (get_string(out_val,1,len+1,10)) then
	  begin
	    len := -999;
	    readv(out_val,len,error:=continue);
	    if ((len >= min) and (len <= max)) then
	      begin
		ok := true;
		num := len;
	      end
	    else
	      ok := false;
	    input_field := true;
	  end
	else
	  input_field := false;
      end;
    begin
      flag := false;
      with py.stat do
	begin
	 for tstat := sr to ca do begin
	  case tstat of
	   sr :  prt('(0 - 250) Strength     = ',1,1); 
	   iq :  prt('(0 - 250) Intelligence = ',1,1);
 	   ws :  prt('(0 - 250) Wisdom       = ',1,1);
	   dx :  prt('(0 - 250) Dexterity    = ',1,1);
	   cn :  prt('(0 - 250) Constitution = ',1,1); 
	   ca :  prt('(0 - 250) Charisma     = ',1,1);
	  end;
	  if not get_string(tmp_str,1,26,10) then goto abort;
	  tmp_val := -999;
	  readv(tmp_str,tmp_val,error:=continue);
	  if (tmp_val <> -999) then
	    begin
	      tmp_val := squish_stat(tmp_val);
	      p[tstat] := tmp_val;
	      c[tstat] := tmp_val;
	      prt_a_stat(tstat);
	    end;
	 end;
	end;
      with py.misc do
	begin
	  tmp_val := mhp;
	  if input_field('(1-32767) Hit points = ',tmp_val,1,32767,flag) then
	    begin
	      if flag then
		begin
		  mhp := tmp_val;
		  chp := mhp;
		  prt_hp;
		end;
	    end
	  else
	    goto abort;
	  tmp_val := mana;
	  if is_magii then
	    if input_field('(0-32767) Mana = ',tmp_val,0,32767,flag) then
	      begin
	        if flag then
		  begin
		    mana := tmp_val;
		    cmana := mana;
		    prt_mana;
		  end
	      end
	    else
	      goto abort;
	  tmp_val := srh;
	  if input_field('(0-200) Searching = ',tmp_val,0,200,flag) then
	    srh := tmp_val
	  else
	    goto abort;
	  tmp_val := stl;
	  if input_field('(0-10) Stealth = ',tmp_val,0,10,flag) then
	    stl := tmp_val
	  else
	    goto abort;
	  tmp_val := disarm;
	  if input_field('(0-200) Disarming = ',tmp_val,0,200,flag) then
	    disarm := tmp_val
	  else
	    goto abort;
	  tmp_val := save;
	  if input_field('(0-100) Save = ',tmp_val,0,100,flag) then
	    save := tmp_val
	  else
	    goto abort;
	  tmp_val := bth;
	  if input_field('(0-200) Base to hit = ',tmp_val,0,200,flag) then
	    bth := tmp_val
	  else
	    goto abort;
	  tmp_val := bthb;
	  if input_field('(0-200) Bows/Throwing = ',tmp_val,0,200,flag) then  
	    bthb := tmp_val
	  else
	    goto abort;
	  tmp_val := money[total$];
	  if input_field('Player Gold = ',tmp_val,0,100000000,flag) then
	    begin
	      if flag then
		begin
		  tmp_val := (tmp_val-money[total$])*gold$value;
		  if (tmp_val>0) then
		    add_money(tmp_val)
		  else
		    subtract_money(-tmp_val,true);
		  prt_weight;
		  prt_gold;
		end;
	    end
	  else
	    goto abort;
	  if not input_field('Account Gold = ',account,0,1000000000,flag) then
	    goto abort;
	  tmp_val := inven_weight;
	  if input_field('Current Weight (100/unit weight) = ',tmp_val,0,900000,flag) then
	    begin
	      inven_weight := tmp_val;
	      prt_weight;
	    end
	  else
	    goto abort;
	end;
abort:
      erase_line(msg_line,msg_line);
      py_bonuses(blank_treasure,0);
    end;



	{ Wizard routine to edit high score file		-DMF-	}
[global,psect(wizard$code)] procedure edit_score_file;
    const
	display_size	= 15;
    type
	list_elem = record
		data	: string;
		next	: ^list_elem;
	end;
	list_elem_ptr = ^list_elem;
    var
	data_list	: list_elem_ptr;
	cur_top		: list_elem_ptr;
	blegga		: list_elem_ptr;
	curse		: list_elem_ptr;
	cur_display	: array [1..display_size] of list_elem_ptr;
	cur_display_size: integer;
	blank		: packed array [1..13] of char;
	i1,i2,i3,i4	: integer;
	trys		: integer;
	f1		: text;
	flag,file_flag	: boolean;
	exit_flag	: boolean;
	temp,temp2	: ntype;
	ch		: char;
	want_save	: boolean;
    procedure display_commands;
      begin
	prt('You may:',21,1);
	prt(' d) Delete an entry.              b) Browse to next page.',22,1);
	prt(' c) Change an entry.',23,1);
	prt('^Z) Exit and save changes         q) Quit without saving.',24,1);
      end;
    procedure display_list(start : list_elem_ptr);
      var
		count,old_display_size	: integer;
      begin
	old_display_size := cur_display_size;
	count := 0;
	while (start <> nil) and (count < display_size) do
	  begin
	    count := count + 1;
	    if (cur_display[count] <> start) then
	      begin
		cur_display[count] := start;
		writev(temp2,chr(96+count),')',start^.data);
		if (length(temp2) > 80) then temp2 := substr(temp2,1,80);
		prt(temp2,count+3,1);
	      end;
	    start := start^.next;
	  end;
	cur_display_size := count;
	while (old_display_size > cur_display_size) do
	  begin
	    erase_line(old_display_size+3,1);
	    cur_display[old_display_size] := nil;
	    old_display_size := old_display_size - 1;
	  end;
	if (start = nil) then
	  blegga := data_list
	else
	  blegga := start;
      end;
    procedure clear_display;
      var
		index	: integer;
      begin
	cur_display_size := 0;
	for index := 1 to display_size do
	  cur_display[index] := nil;
      end;
    procedure display_screen;
      begin
	clear(1,1);
	clear_display;
	put_buffer('  Username     Points  Diff    Character name    Level  Race         Class',2,1);
	put_buffer('  ____________ ________ _ ________________________ __ __________ ______________',3,1);
	display_list(cur_top);
	display_commands;
      end;
    function get_list_entry(
		var com_val	: integer;
		pmt		: vtype;
		i1,i2		: integer) : boolean;
      var
		command		: char;
		flag		: boolean;
      begin
	com_val := 0;
	flag := true;
	writev(out_val,'(Entries ',chr(i1+96),'-',chr(i2+96),', ^Z to exit) ',
			pmt);
	while (((com_val < i1) or (com_val > i2)) and (flag)) do
	  begin
	    prt(out_val,1,1);
	    inkey(command);
	    com_val := ord(command);
	    case com_val of
	      3,25,26,27 : flag := false;
	      otherwise com_val := com_val - 96;
	    end;
	  end;
	erase_line(1,1);
	get_list_entry := flag;
      end;
    procedure parse_command;
      var
	command			: char;
	com_val,which		: integer;
	user,score,name,level	: string;
	race,class,diffic	: string;
	sc,lvl,diff		: integer;
	top_flag		: boolean;

      begin
	if get_com('',command) then
	  begin
	    com_val := ord(command);
	    case com_val of
{^R}	      18: display_screen;
{b}	      98: begin
		    if (cur_top = blegga) then
		      prt('Entire list is displayed.',1,1)
		    else
		      begin
			cur_top := blegga;
			display_list(cur_top);
		      end;
		  end;
{c}	      99: begin
		    if (cur_display_size > 0) then
		      if (get_list_entry(which,' Change which one?',1,
					 cur_display_size)) then
begin
  prt('Username : ',1,1);
  if (get_string(user,1,12,12)) then
    begin
      prt('Score : ',1,1);
      if (get_string(score,1,9,8)) then
	begin
	  prt('Character name : ',1,1);
	  if (get_string(name,1,18,24)) then
	    begin
	      prt('Level : ',1,1);
	      if (get_string(level,1,9,2)) then
		begin
		  prt('Race : ',1,1);
		  if (get_string(race,1,8,10)) then
		    begin
		      prt('Class : ',1,1);
		      if (get_string(class,1,9,16)) then
			begin
			  prt('Difficulty : ',1,1);
			  if (get_string(diffic,1,14,1)) then
			    begin
			      readv(score,sc,error:=continue);
			      readv(level,lvl,error:=continue);
			      readv(diffic,diff,error:=continue);
			      writev(cur_display[which]^.data,
					pad(user,' ',13),sc:8,' ',diff:1,' ',
					center(name,24),' ',lvl:2,' ',
					center(race,10),' ',center(class,16),
					error:=continue);
			      cur_display[which] := nil;
			      display_list(cur_top);
			      prt('Score changed.',1,1);
			    end
			  else
			    prt('Score not changed.',1,1);
			end
		      else
			prt('Score not changed.',1,1);
		    end
		  else
		    prt('Score not changed.',1,1);
		end
	      else
		prt('Score not changed.',1,1);
	    end
          else
	    prt('Score not changed.',1,1);
	end
      else
	prt('Score not changed.',1,1);
    end
  else
    prt('Score not changed.',1,1);
end;
		  end;
{d}	     100: begin
		    if (cur_display_size > 0) then
		      if (get_list_entry(which,' Delete which one?',1,
					 cur_display_size)) then
			begin
			  if (cur_display[which] = cur_top) then 
			    top_flag := true
			  else
			    top_flag := false;
			  curse := data_list;
			  while (curse^.next <> cur_display[which]) do
			    curse := curse^.next;
			  curse^.next := cur_display[which]^.next;
			  if (top_flag) then cur_top := curse^.next;
			end;
			cur_display[which] := nil;
			display_list(cur_top);
		  end;
{q}	     113: begin
		    exit_flag := true;
		    want_save := false;
		  end;
	      otherwise prt('Invalid command',1,1);
	    end;
	  end
        else
	  exit_flag := true;
      end;
    begin
      trys := 0;
      file_flag := false;
      repeat
	open (f1,file_name:=moria_top,organization:=sequential,history:=old,
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
      if (status(f1) <> 0) then
	begin
	  msg_print('Couldn''t open top score file.');
	  msg_print('Try again later.');
	end
      else
	begin
	  data_list := nil;
	  want_save := true;
	  reset(f1);
	  while (not eof(f1)) do
	    begin
	      readln(f1,temp,error:=continue);
	      seed := encrypt_seed1;
	      decrypt(temp);
	      if (data_list = nil) then
		begin
		  new(data_list);
		  data_list^.next := nil;
		  data_list^.data := temp;
		  curse := data_list;
		end
	      else
		begin
		  new(curse^.next);
		  curse := curse^.next;
		  curse^.next := nil;
		  curse^.data := temp;
		end;
	    end;
	  exit_flag := false;
	  cur_top := data_list;
	  display_screen;
	  while not exit_flag do parse_command;
	  if (want_save) then
	    begin
	      rewrite(f1);
	      curse := data_list;
	      while (curse <> nil) do
		begin
		  temp := curse^.data;
		  seed := encrypt_seed1;
		  encrypt(temp);
		  writeln(f1,temp);
		  curse := curse^.next;
		end;
	    end;
	  close(f1);
	end;
      draw_cave;
    end;

	{ Wizard routine for creating objects			-RAK-	}
[global,psect(wizard$code)] procedure wizard_create;
    var
	tmp_val			: integer;
	tmp_str			: vtype;
	flag			: boolean;
    begin
      msg_print('Warning: This routine can cause fatal error.');
      msg_print(' ');
      msg_flag := false;
      with inven_temp^.data do
	begin
          prt('Name   : ',1,1);
          if (get_string(tmp_str,1,10,40)) then
	    name := tmp_str
	  else
	    name := '& Wizard Object!';
	  repeat
	    prt('Tval   : ',1,1);
	    get_string(tmp_str,1,10,10);
	    tmp_val := 0;
	    readv(tmp_str,tmp_val,error:=continue);
	    flag := true;
	    case tmp_val of
	      1,3,6,13,15	: tchar := '~';
	      4,5		: tchar := '*';
	      2 		: tchar := '&';
	      10,11,12		: tchar := '{';
	      20		: tchar := '}';
	      21		: tchar := '/';
	      22,25		: tchar := '\';
	      23		: tchar := '|';
	      30,31,33		: tchar := ']';
	      32,36		: tchar := '(';
	      34		: tchar := ')';
	      35		: tchar := '[';
	      40		: tchar := '"';
	      45		: tchar := '=';
	      55		: tchar := '_';
	      60,65		: tchar := '-';
	      70,71,90,91	: tchar := '?';
	      75,76,77		: tchar := '!';
	      80		: tchar := ',';
	      85,86,92		: tchar := '%';
	      otherwise	flag := false;
	    end;
	  until (flag);
	  tval := tmp_val;
	  prt('Subval : ',1,1);
	  get_string(tmp_str,1,10,10);
	  tmp_val := 1;
	  readv(tmp_str,tmp_val,error:=continue);
	  subval := tmp_val;
	  prt('Weight : ',1,1);
	  get_string(tmp_str,1,10,10);
	  tmp_val := 1;
	  readv(tmp_str,tmp_val,error:=continue);
	  weight := tmp_val;
	  prt('Number : ',1,1);
	  get_string(tmp_str,1,10,10);
	  tmp_val := 1;
	  readv(tmp_str,tmp_val,error:=continue);
	  number := tmp_val;
	  prt('Damage : ',1,1);
	  get_string(tmp_str,1,10,5);
	  damage := tmp_str;
	  prt('+To hit: ',1,1);
	  get_string(tmp_str,1,10,10);
	  tmp_val := 0;
	  readv(tmp_str,tmp_val,error:=continue);
	  tohit := tmp_val;
	  prt('+To dam: ',1,1);
	  get_string(tmp_str,1,10,10);
	  tmp_val := 0;
	  readv(tmp_str,tmp_val,error:=continue);
	  todam := tmp_val;
	  prt('AC     : ',1,1);
	  get_string(tmp_str,1,10,10);
	  tmp_val := 0;
	  readv(tmp_str,tmp_val,error:=continue);
	  ac := tmp_val;
	  prt('+To AC : ',1,1);
	  get_string(tmp_str,1,10,10);
	  tmp_val := 0;
	  readv(tmp_str,tmp_val,error:=continue);
	  toac := tmp_val;
	  prt('P1     : ',1,1);
	  get_string(tmp_str,1,10,10);
	  tmp_val := 0;
	  readv(tmp_str,tmp_val,error:=continue);
	  p1 := tmp_val;
	  prt('Flags  (In HEX): ',1,1);
	  flags := get_hex_value(1,18,8);
	  prt('Flags2 (In HEX): ',1,1);
	  flags2 := get_hex_value(1,18,8);
	  prt('Cost : ',1,1);
	  get_string(tmp_str,1,10,10);
	  tmp_val := 0;
	  readv(tmp_str,tmp_val,error:=continue);
	  cost := tmp_val;
	  if (get_com('Allocate? (Y/N)',command)) then
	    case command of
		'y','Y':  begin
			    popt(tmp_val);
			    t_list[tmp_val] := inven_temp^.data;
			    with cave[char_row,char_col] do
			      begin
				if (tptr > 0) then
				  delete_object(char_row,char_col);
				tptr := tmp_val;
			      end;
			    msg_print('Allocated...');
			  end;
		otherwise msg_print('Aborted...');
	    end;
	  inven_temp^.data := blank_treasure;
	end;
	move_char(5);
	creatures(false);
    end;
end.






