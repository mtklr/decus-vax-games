[inherit ('srinit','srsys','srother','srmisc','srio','srmenu'),
 environment('srop')]

module srop;

[hidden,external]
function getkey(key_mode:integer := 0):char;
external;

procedure grab_kind(prompt:string; var kind:integer);
begin
  case grab_key(prompt,key_kind) of
    'r':kind := na_race;
    'o':kind := na_obj;
    'R':kind := na_room;
    'f':kind := na_foreground;
    'p':kind := na_player;
    's':kind := na_spell;
    'q':kind := 0;
  end;
end;

procedure install_foregrounds;
begin
  getfg;

  with fg.effect[1] do
  begin
    fg.name[1]	:= 'Wall';
    icon	:= ' ';
    rendition	:= reverse;
    base	:= 0;
    altitude	:= 20;
    kind	:= fg_normal;
    fparm1	:= 0;
    fparm2	:= 0;
    dsc		:= '';
    on		:= true;
    walk_through:= false;
    walk_on	:= false;
    climb	:= false;
  end;

  with fg.effect[2] do
  begin
    fg.name[2] := 'Closed door';
    icon	:= '+';
    rendition	:= reverse;
    base	:= 0;
    altitude	:= 20;
    kind	:= fg_door;
    fparm1	:= 3;
    fparm2	:= 0;
    dsc		:= '';
    on		:= true;
    walk_through:= false;
    walk_on	:= false;
    climb	:= false;
  end;

  with fg.effect[3] do
  begin
    fg.name[3]	:= 'Open door';
    icon	:= '-';
    rendition	:= bold;
    base	:= 0;
    altitude	:= 20;
    kind	:= fg_door;
    fparm1	:= 2;
    fparm2	:= 0;
    dsc		:= '';
    on		:= true;
    walk_through:= true;
    walk_on	:= false;
    climb	:= false;
  end;

  with fg.effect[4] do
  begin
    fg.name[4]	:= 'Stairway down';
    icon	:= '<';
    rendition	:= bold;
    base	:= 0;
    altitude	:= 0;
    kind	:= fg_exit;
    fparm1	:= 0;
    fparm2	:= 0;
    dsc		:= '';
    on		:= true;
    walk_through:= true;
    walk_on	:= true;
    climb	:= true;
  end;

  with fg.effect[5] do
  begin
    fg.name[5] := 'Stairway Up';
    icon	:= '>';
    rendition	:= bold;
    base	:= 0;
    altitude	:= 0;
    kind	:= fg_exit;
    fparm1	:= 0;
    fparm2	:= 0;
    dsc		:= '';
    on		:= true;
    walk_through:= true;
    walk_on	:= true;
    climb	:= true;
  end;

  putfg;
end;

procedure balance_distribution;
var
  i,j:integer;
  s:string;
  class_array:array[1..maxclass] of integer;
  race_array:array[1..maxindex] of integer;
begin
  for i := 1 to maxclass do class_array[i] := 0;
  for i := 1 to maxindex do race_array[i] := 0;
  for i := 1 to indx[i_player].top do
  if indx[i_player].on[i] and (not indx[i_npc].on[i]) then
  begin
    getplayer(i);
    freeplayer;
    if player.attrib_ex[st_class] <> 0 then
    class_array[ player.attrib_ex[st_class] ] :=
    class_array[ player.attrib_ex[st_class] ] + 1;

    if player.attrib_ex[st_race] <> 0 then
    race_array[ player.attrib_ex[st_race] ] :=
    race_array[ player.attrib_ex[st_race] ] + 1;
  end;
  wl('Class distribution');
  for i := 1 to maxclass do
  if class_array[i] > 0 then
  begin
    writev(s,write_nice(class_name[i],20),':',class_array[i]:0);
    wl(s);
  end;
  wl('Race distribution');
  for i := 1 to indx[i_race].top do
  if race_array[i] > 0 then
  begin
    writev(s,write_nice(name[na_race].id[i],20),':',race_array[i]:0);
    wl(s);
  end;
end;

procedure find_gold;
var
  i:integer;
  s:string;
begin
  for i := 1 to indx[i_player].top do
  begin
    getplayer(i);
    freeplayer;
    if player.attrib[at_wealth] <> 0 then
    begin
      writev(s,write_nice(name[na_player].id[i],20),':',
      player.attrib[at_wealth]:0);
      wl(s);
    end;
  end;
end;

procedure create_race(s:string);
var
  racenum,i:integer;
begin
  if allocate(i_race,racenum) then
  begin
    getname(na_race);
    name[na_race].id[racenum] := s;
    putname(na_race);
    getrace(racenum);
    with race do
    begin
      for i := 1 to el_max do
      with armor[i] do
      begin
	chance := 0;
	magnitude := 0;
      end;
      for i := 1 to maxnaturalweapon do weapon[i] := 0;
      for i := 1 to at_max do attrib[i] := 0;
      for i := 1 to el_max do proficiency[i] := 0;
      hands := false;
      sound := 'Hi!';
    end;
    putrace;
  end;
end;

procedure designate_randoms;
var
  n:integer;
begin
  if get_name(name[na_player].id,'Player',n,,i_npc) then
  begin
    getindex(i_npc);
    indx[i_npc].on[n] := not indx[i_npc].on[n];
    putindex(i_npc);
    if indx[i_npc].on[n] then
    wl(name[na_player].id[n]+' is now a random.')
    else wl(name[na_player].id[n]+' is not longer a random.')
  end;
end;

procedure custom_race(n:integer);
var
  d_st,s:string;
  d_ss:shortstring;
  d_bo:boolean;
  d_ic:char;
  i,d_in:integer;
begin
  mc := 1;
  getrace(n);
  freerace;
  with race do
  begin
    set_menu('Name of race',,k_sst,,name[na_race].id[n]);
    set_menu('Sound race makes','(Direction): this_string',k_str,,sound);
    set_menu('Can use weapons',,k_boo,,,hands);
    for i := 1 to maxnaturalweapon do
    begin
      writev(s,'Attack spell #',i:0);
      set_menu(s,,k_spe,weapon[i],,,,,,na_spell);
    end;
    for i := 1 to at_max do
    set_menu(attrib_name[i],,k_int,attrib[i]);
    for i := 1 to el_max do
      set_menu('Proficiency '+element[i],,k_int,proficiency[i]);
    for i := 1 to el_max do
    begin
      set_menu('% chance ('+element[i]+')',
      '% chance this attack form will be modified',k_int,armor[i].chance);
      set_menu('% block ('+element[i]+')',
      '% damage taken off if attack is to be modified',k_int,
      armor[i].magnitude);
    end;                             
  end;
  do_menu('race.help');
  getname(na_race);
  get_menu_sst(name[na_race].id[n]);
  putname(na_race);
  getrace(n);
  get_menu_str(race.sound);
  get_menu_boo(race.hands);
  with race do
  begin
    for i := 1 to maxnaturalweapon do get_menu_int(weapon[i]);
    for i := 1 to at_max do get_menu_int(attrib[i]);
    for i := 1 to el_max do get_menu_int(proficiency[i]);
    for i := 1 to el_max do
    with armor[i] do
    begin
      get_menu_int(chance);
      get_menu_int(magnitude);
    end;
  end;
  putrace;
end;

procedure create_room(s:string; x,y:integer := 0);
var
  roomnum,i,j,k:integer;
begin
  if x = 0 then grab_num('Room size X',x,1,maxhoriz,40);
  if y = 0 then grab_num('Room size Y',y,1,maxvert,13);
  if allocate(i_room,roomnum) then
  begin
    getname(na_room);
    name[na_room].id[roomnum] := s;
    putname(na_room);
    getroom(roomnum);
    with here do
    begin
      level := 50;
      size.x := x;
      size.y := y;
      for j := 1 to y do
	for i := 1 to x do
	  background[i,j] := ' ';
    end;
    putroom;
    getfg(roomnum);
    with fg do
    begin
      for i := 1 to maxhoriz do
      for j := 1 to maxvert do
      for k := 1 to fg_layers do fg.map[i,j,k] := 0;
      for i := 1 to maxobjs do
      with object[i] do
      begin
	object.num := 0;
	object.condition := 0;
	for j := 1 to maxunique do object.parm[j] := 0;
	loc.x := 0;
	loc.y := 0;
	hidden := 0;
      end;
      for i := 1 to maxfg do
      with effect[i] do
      begin
	kind	:= 0;
	base	:= 0;
	altitude:= 0;
        rendition := 0;
	fparm1	:= 0;
	fparm2	:= 0;
	dsc	:= '';
	on	:= false;
	walk_through := true;
	walk_on := true;
	climb	:= true;
      end;
    end;
    putfg;
  end;
end;

procedure custom_room_menu;
var
  d_st,s:string;
  d_ss:shortstring;
  d_ic,fg_ico:char;
  d_bo:boolean;
  d_in,i:integer;
begin
  mc := 1;
  set_menu('Room name',,k_sst,,name[na_room].id[pl[now].where.r]);
  set_menu('Room level',,k_int,here.level);
  set_menu('Kind ','0 - Normal, 1 - Random',k_int,here.kind);
  set_menu('Size x',,k_int,here.size.x);
  set_menu('Size y',,k_int,here.size.y);
  for i := 1 to maxexit do
  begin
    writev(s,dir[i]);
    set_menu('['+s+']To room ',,k_roo,here.exit[i].toroom);
    set_menu('['+s+']Face x ',,k_int,here.exit[i].face);
  end;
  do_menu('room.help');
  getname(na_room);
  get_menu_sst(name[na_room].id[pl[now].where.r]);
  putname(na_room);
  getroom;
  get_menu_int(here.level);
  get_menu_int(here.kind);
  get_menu_int(here.size.x);
  get_menu_int(here.size.y);
  for i := 1 to maxexit do
  begin
    get_menu_int(here.exit[i].toroom);
    get_menu_int(here.exit[i].face);
  end;
  putroom;
end;

procedure custom_room;
var
  textfile:text;
  s:string := '';
  file_data:$udata;
  i,j,endscreen:integer;
begin
  if not grab_yes('Read from file') then custom_room_menu
  else
  grab_line('Enter filename',s);
  if s <> '' then
  begin
    open(textfile,'sys$login:'+s,history := readonly,
	access_method := sequential,error := continue);
    if status(textfile) = 0 then
    begin
      reset(textfile);
      j := pl[now].where.y;
      while not eof(textfile) and (j <= 1 + here.size.y - pl[now].where.y) do
      begin
	readln(textfile,file_data);
	if pl[now].where.x - 1 + length(file_data) > here.size.x then
	endscreen := 1 + here.size.x - pl[now].where.x
	else endscreen := length(file_data);
	for i := 1 to endscreen do
	here.background[pl[now].where.x+i-1,j] := file_data[i];
	j := j + 1;
      end;
      draw_screen(false);
    end
    else wl('I could not open that file.');
  end;
end;

procedure do_save_room;
var
  save:packed array[1..maxhoriz,1..maxvert] of char;
  fg_save:packed array[1..maxhoriz,1..maxvert,1..fg_layers] of 1..maxfg;
  i,j:integer;
begin
  for j := 1 to maxvert do
    for i := 1 to maxhoriz do
    save[i,j] := here.background[i,j];
  fg_save := fg.map;
  getroom;
  here.background := save;
  putroom;
  getfg;
  fg.map := fg_save;
  putfg;
  wl('Background saved.');
end;

procedure custom_foreground;
var
  d_st,s:string;
  d_ss:shortstring;
  d_ic,fg_ico:char;
  geom,xx1,xx2,yy1,yy2,
  fg_type,fg_slot,d_in:integer;
  d_bo:boolean;
begin
  mc := 1;
  if not get_name(fg.name,'Enter foreground to customize:',fg_slot)
  then fg_slot := empty_foreground;
  writev(s,'Foreground (',fg_slot:0,') name');
  set_menu(s,,k_sst,,fg.name[fg_slot]);
  with fg.effect[fg_slot] do
  begin
    set_menu('Fg icon',,k_ico,,icon);
    set_menu('Fg icon stats',
	'Normal = 0, Bold = 1, Reverse = 2, Blink = 4, Underline = 8',
	k_int,rendition);
    set_menu('FG type',,k_int,kind,,,,,,na_fg_type);
    set_menu('Base (altitude)',,k_int,base);
    set_menu('Height',,k_int,altitude);
    set_menu('Foreground parm1',,k_int,fparm1,,,-1);
    set_menu('Foreground parm2',,k_int,fparm2,,,-1);
    set_menu('Foreground parm3',,k_int,fparm3,,,-1);
    set_menu('Foreground parm4',,k_int,fparm4,,,-1);
    set_menu('Description',,k_dsc,,dsc);
    set_menu('Initial status',,k_boo,,,on);
    set_menu('Can walk through',,k_boo,,,walk_through);
    set_menu('Can walk on',,k_boo,,,walk_on);
    set_menu('Can climb',,k_boo,,,climb);
    set_menu('Destination room',,k_roo,dest.r);
    set_menu('Destination x loc',
	'Use -1 for a room face, otherwise enter x loc',k_int,dest.x);
    set_menu('Destination y loc',
	'For face use (n=1 s=2 e=3 w=4) otherwise enter y loc',k_int,dest.y);
  end;
  do_menu('fg.help');
  getfg;
  get_menu_sst(fg.name[fg_slot]);
  with fg.effect[fg_slot] do
  begin
    get_menu_ico(icon);
    get_menu_int(rendition);
    get_menu_int(kind);
    get_menu_int(base);
    get_menu_int(altitude);
    get_menu_int(fparm1);
    get_menu_int(fparm2);
    get_menu_int(fparm3);
    get_menu_int(fparm4);
    get_menu_sst(dsc);
    get_menu_boo(on);
    get_menu_boo(walk_through);
    get_menu_boo(walk_on);
    get_menu_boo(climb);
    get_menu_int(dest.r);
    get_menu_int(dest.x);
    get_menu_int(dest.y);
  end;
  putfg;
end;

procedure create_object(s:string);
var
  objnum,i:integer;
begin
  if allocate(i_object,objnum) then
  begin
    getobj(objnum);
    with obj do
    begin
      icon	:= '?';
      wear	:= 0;
      weight	:= 0;
      worth	:= 0;
      line_d	:= '';
      examine_d	:= '';
      get_d	:= '';
      use_d	:= '';
      howprint	:= 0;
      for i := 1 to maxcomponent do component[i] := 0;
      for i := 1 to maxparm do
      begin
	parm[i] := 0;
	mag[i] := 0;
      end;
      grab_num('Shall the object be a [1 - Weapon][2 - Armor][3 - Misc]',i,1,2,1);
      case i of
	1:begin
	    parm[1] := ef_largest;
	    parm[2] := ef_smallest;
	    parm[3] := ef_weapon;
	  end;
	2:begin
	    parm[1] := ef_largest;
	    parm[2] := ef_smallest;
	    parm[3] := ef_noise;
	    parm[4] := 0;
	    parm[5] := ef_c_weapon;
	    parm[6] := ef_m_weapon;
	    parm[7] := ef_c_missile;
	    parm[8] := ef_m_missile;
	    parm[9] := ef_c_self;
	    parm[10] := ef_m_self;
	    parm[11] := ef_c_fire;
	    parm[12] := ef_m_fire;
	    parm[13] := ef_c_magic;
	    parm[14] := ef_m_magic;
	    parm[15] := ef_c_holy;
	    parm[16] := ef_m_holy;
	    parm[17] := ef_c_force;
	    parm[18] := ef_m_force;
	    parm[19] := ef_c_electric;
	    parm[20] := ef_m_electric;
	  end;
	3:begin
	    parm[1] := ef_largest;
	    parm[2] := ef_smallest;
	    for i := 3 to 20 do parm[i] := i-2;
	  end;
      end;
    end;
    putobj;
    getname(na_obj);
    name[na_obj].id[objnum] := s;
    putname(na_obj);
    wl('Object created.');
  end;
end;

procedure create_spell(s:string);
var
  spellnum,i:integer;
begin
  if allocate(i_spell,spellnum) then
  begin
    getspell(spellnum);
    with spell do
    begin
      icon	:= '*';
      effect	:= 0;
      element	:= 0;
      caster	:= false;
      prompt	:= false;
      mana	:= 0;
      difficulty:= 100;
      castingtime := 0;
      geometry	:= 0;
      geo1	:= 0;
      geo2	:= 0;
      for i := 1 to 4 do parm[i] := 0;
    end;
    putspell;
    getname(na_spell);
    name[na_spell].id[spellnum] := s;
    putname(na_spell);
    wl('Spell created.');
  end;
end;

procedure custom_spell(spellnum:integer);
var
  d_in:integer;
  d_st:string;
  d_bo:boolean;
  d_ic:char;
  d_ss:shortstring;
  obj_name:string;
  s:string;
  i:integer;
begin
  mc := 1;
  getspell(spellnum);
  freespell;
  with spell do
  begin
    set_menu('Name of spell',,k_sst,,name[na_spell].id[valid]);
    set_menu('Offensive spell',,k_boo,,,indx[i_offense].on[valid]);
    set_menu('Effect',,k_int,effect,,,,,,na_spell_ef);
    set_menu('Element',,k_int,element,,,,,,na_elements);
    set_menu('Caster',,k_boo,,,caster);
    set_menu('Prompt',,k_boo,,,prompt);
    set_menu('Icon',,k_ico,,icon);
    set_menu('Icon rendition',
	'Normal = 0, Bold = 1, Reverse = 2, Blink = 4, Underline = 8',
	k_int,rendition);
    set_menu('Mana',,k_int,mana);
    set_menu('Difficulty',,k_int,difficulty);
    set_menu('Time',,k_int,castingtime);
    set_menu('Duration',,k_int,duration);
    set_menu('Caster desc',,k_dsc,,casterdesc);
    set_menu('Victim desc',,k_dsc,,victimdesc);
    set_menu('Geometry',
	'[1 point] [2 line] [3 blip] [4 rectangle] [5 circle]',k_int,geometry);
    set_menu('Geo parm 1',,k_int,geo1);
    set_menu('Geo parm 2',,k_int,geo2);
  end;
  for i := 1 to 4 do
  begin
    writev(s,'Parm',i:0);
    set_menu(s,,k_int,spell.parm[i],,,-999);
  end;
  do_menu('spell.help');

  getname(na_spell);
  get_menu_sst(name[na_spell].id[spellnum]);
  putname(na_spell);

  getindex(i_offense);
  get_menu_boo(d_bo);
  indx[i_offense].on[spellnum] := d_bo;
  putindex(i_offense);

  getspell(spellnum);
  with spell do
  begin
    get_menu_int(effect);
    get_menu_int(element);
    get_menu_boo(caster);
    get_menu_boo(prompt);
    get_menu_ico(icon);
    get_menu_int(rendition);
    get_menu_int(mana);
    get_menu_int(difficulty);
    get_menu_int(castingtime);
    get_menu_int(duration);
    get_menu_sst(casterdesc);
    get_menu_sst(victimdesc);
    get_menu_int(geometry);
    get_menu_int(geo1);
    get_menu_int(geo2);
  end;
  for i := 1 to 4 do get_menu_int(spell.parm[i]);
  putspell;
  act_out(plr[now].log,e_msg,pl[now].where.x,pl[now].where.y,normal,,,,
	name[na_player].id[plr[now].log]+' is done customizing an object.');
end;

procedure custom_object(objnum:integer);
var
  d_in:integer;
  d_st:string;
  d_bo:boolean;
  d_ic:char;
  d_ss:shortstring;
  obj_name:string;
  s:string;
  i:integer;
begin
  mc := 1;
  read_object(objnum);
  set_menu('Name of object',,k_sst,,name[na_obj].id[obj.valid]);
  set_menu('Object''s icon',,k_ico,,obj.icon);
  set_menu('Icon stats',
	'Normal = 0, Bold = 1, Reverse = 2, Blink = 4, Underline = 8',
	k_int,obj.rendition);
  set_menu('Attack spell ',,k_spe,obj.spell);
  set_menu('Examine description','examine',k_dsc,,obj.examine_d);
  set_menu('Get description','get',k_dsc,,obj.get_d);
  set_menu('Use description','use',k_dsc,,obj.use_d);
  set_menu('Ground description','ground',k_dsc,,obj.line_d);
  set_menu('Cost of object',,k_int,obj.worth);
  set_menu('Size of object',,k_int,obj.size);
  set_menu('Weight of object',,k_int,obj.weight);
  set_menu('How object prints',
'[0 - ""][1 - a][2 - an][3 - some][4 - the]',k_int,obj.howprint,,,0,4,1);
  writev(s,'Wear slot [',0:0,'..',maxparm:0,']');
  set_menu('Wear slot',s,k_int,obj.wear,,,0,maxparm,
		obj.wear,na_equipment);
  for i := 1 to maxparm do
  begin
    writev(s,'Parameter',i:0);
    set_menu(s,'Enter corresponding numnber',k_sta,obj.parm[i],,,
		0,ef_max,obj.parm[i],na_weapon);
    writev(s,'Magnitude',i:0);
    set_menu(s,,k_int,obj.mag[i],,,-999);
  end;
  do_menu('object.help');
  getname(na_obj);
  get_menu_sst(name[na_obj].id[objnum]);
  putname(na_obj);
  getobj(objnum);
  with obj do
  begin
    get_menu_ico(icon);
    get_menu_int(rendition);
    get_menu_int(spell);
    get_menu_sst(examine_d);
    get_menu_sst(get_d);
    get_menu_sst(use_d);
    get_menu_sst(line_d);
    get_menu_int(worth);
    get_menu_int(size);
    get_menu_int(weight);
    get_menu_int(howprint);
    get_menu_int(wear);
  end;
  for i := 1 to maxparm do
  with obj do
  begin
    get_menu_int(parm[i]);
    get_menu_int(mag[i]);
  end;
  putobj;
  act_out(plr[now].log,e_msg,pl[now].where.x,pl[now].where.y,normal,,,,name[na_player].id[plr[now].log]+' is done customizing an object.');
end;

procedure custom_fg_geometry;
var
  add_fg:boolean;
  plotted_icon:char;
  s:string;
  fg_slot,geom,xx1,xx2,yy1,yy2:integer;
begin
  if get_name(fg.name,'Enter foreground:',fg_slot) then
  begin
    add_fg := not grab_yes('Delete foreground');
    wl('1 - Point         4 - Rectangle');
    wl('2 - Line          5 - Circle');
    wl('3 - Blip          6 - Face');
    grab_num('Enter geometry:',geom,1,5,1);
    wl('When you are at a destination coordinate, hit "."');
    case geom of
g_face:
      begin
	xx1 := -1;
	grab_num('Enter face n=1,s=2,e=3,w=4:',yy1,1,4,1);
      end;
g_rectangle,g_line:
      begin
        wl('Go to the upper left corner.');
        getkey(key_move_only);
        xx1 := pl[now].where.x;
        yy1 := pl[now].where.y;
        wl('Go to the lower right corner.');
        getkey(key_move_only);
        xx2 := pl[now].where.x;
        yy2 := pl[now].where.y;
      end;
g_point:begin
	wl('Go to the point.');
	getkey(key_move_only);
	xx1 := pl[now].where.x;
	yy1 := pl[now].where.y;
      end;
g_circle:
      begin
	wl('Go to the center of the circle.');
	getkey(key_move_only);
	xx1 := pl[now].where.x;
	yy1 := pl[now].where.y;
	wl('Go east/west to determine the inner circle radius.');
	getkey(key_move_only);
        xx2 := abs(pl[now].where.x - xx1);
	wl('Go east/west to determine the outer circle radius.');
	getkey(key_move_only);
	yy2 := abs(pl[now].where.x - xx1);
      end;
    end;
    if add_fg then plotted_icon := fg.effect[fg_slot].icon
    else plotted_icon := chr(0);
    g_plot(geom,xx1,yy1,xx2,yy2,fg.effect[fg_slot].base,
	fg.effect[fg_slot].altitude,plotted_icon,fg.effect[fg_slot].rendition);
    map_foreground(fg_slot,geom,xx1,yy1,xx2,yy2,add_fg);
  end;
end;

procedure do_custom;
var
  s,thename:string;
  n,kind:integer;
begin
  grab_kind('Edit (?):',kind);
  if kind <> 0 then
  case kind of
na_obj:if checkprivs(8,true) then
	if get_name(name[kind].id,names[kind],n) then custom_object(n);
na_spell:if checkprivs(8,true) then
	if get_name(name[kind].id,names[kind],n) then custom_spell(n);
na_race:if checkprivs(8,true) then
	if get_name(name[kind].id,names[kind],n) then custom_race(n);
na_room:if checkprivs(2,true) then custom_room;
na_foreground:if checkprivs(2,true) then custom_foreground;
  end;
end;

procedure delete_object(objnum:integer);
begin
end;

procedure delete_room;
begin
end;

procedure do_delete(thename:string);
var
  s:string;
  n:integer;
begin
  n := 0;
  if length(thename) > 0 then
  begin
    s := lowcase(thename);
    case s[1] of
      'o':if lookup(name[na_obj].id,thename,n,true) then delete_object(n);
      'r':delete_room;
    end;
  end;
end;

procedure do_create;
var
  s:string;
  n,kind:integer;
  ok:boolean := false;
begin
  grab_kind('Make',kind);
  if not (kind in [0,na_foreground]) then
  begin
    grab_line('Name',s);
    ok := valid_name(kind,s);
    if ok then
    begin
      case kind of
na_spell:create_spell(s);
na_obj :create_object(s);
na_race:create_race(s);
na_room:begin
	  create_room(s);
	  getroom;
	  freeroom;
	end;
      end;
    end;
  end;
end;

procedure do_system(cmd:char := ' ');
var
  i,j,n:integer;
  done:boolean := false;
  system_help:array[1..9] of shortstring := (
	'i - rebuild indexs',
	'I - rebuild intfile',
	'n - rebuild namefile',
	'a - add races',
	'o - add objects',
	'p - add players',
	'r - add rooms',
	's - add spells',
	'R - rebuild all');

  procedure rebuild_indexfile;
  begin
    for i := 1 to i_max do
    begin
      locate(indexfile,i);
      for j := 1 to maxindex do indexfile^.on[j] := false;
      indexfile^.valid := i;
      indexfile^.top := 0;
      indexfile^.inuse := 0;
      put(indexfile);
    end;
  end;

  procedure rebuild_namefile;
  begin
    for j := 1 to na_max do
    begin
      locate(namefile,j);
      namefile^.valid := j;
      namefile^.loctop := 0;
      for i := 1 to maxindex do namefile^.id[i] := '';
      put(namefile);
    end;
  end;

  procedure rebuild_intfile;
  begin
    for i := 1 to n_max do
    begin
      locate(intfile,i);
      intfile^.valid := i;
      put(intfile);
    end;
  end;

  procedure check_indexfile;
  var
    total:integer;
  begin
    for i := 1 to i_max do
    begin
      total := 0;
      getindex(i);
      for j := 1 to indx[i].top do
      if indx[i].on[j] then total := total + 1;
      indx[i].inuse := total;
      putindex(i);
    end;
  end;

begin
  x_write_array(system_help,,'System');
  repeat
    case grab_key('System>') of
  '9':check_indexfile;
  'R':if grab_yes('This nukes everything.  Really do it') then
      if grab_yes('Ya sure') then
      if grab_yes('Do you have a note from your mother') then
      begin
	rebuild_indexfile;
	rebuild_intfile;
	rebuild_namefile;
	addplayers(10,false);
	addplayers(10,true);
	addrooms(5);
	addraces(10);
	addobjects(5);
	addspells(5);
	create_room('Land of Opportunity',132,64);
	create_race('Human');
	create_race('Elf');
	create_race('Dwarf');
	create_race('Snark');
	create_race('Orc');
	create_race('Troll');
	create_race('Mummy');
	create_race('Snipe');
	create_race('Boojum');
	create_race('Dragon');
      end;
  'q':done := true;
  'i':if grab_yes('Rebuild index file') then rebuild_indexfile;
  'n':if grab_yes('Add namefile') then rebuild_namefile;
  'I':if grab_yes('Rebuild intfile') then rebuild_intfile;
  'r':begin
        grab_num('Number of rooms to add',n,0);
        if n > 0 then addrooms(n);
      end;
  'o':begin
        grab_num('Number of object to add',n,0);
        if n > 0 then addobjects(n);
      end;
  's':begin
        grab_num('Number of spells to add',n,0);
        if n > 0 then addspells(n);
      end;
  'a':begin
        grab_num('Number of races to add',n,0);
        if n > 0 then addraces(n);
      end;
  'p':begin
        grab_num('Number of players to add',n,0);
        if n > 0 then
	begin
	  if grab_yes('Shall there be npcs') then addplayers(n,true)
	  else addplayers(n,false);
	end;
      end;
    end;
  until done;
end;

end.
