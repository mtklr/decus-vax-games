[inherit ('srinit','srsys','srother','srio','srmove','srmisc'),
 environment('srcom')]

module srcom;

[ASYNCHRONOUS] FUNCTION smg$put_chars (
	display_id : UNSIGNED;
	text : [CLASS_S] PACKED ARRAY [$l2..$u2:INTEGER] OF CHAR;
	start_row : INTEGER := %IMMED 0;
	start_column : INTEGER := %IMMED 0;
	flags : UNSIGNED := %IMMED 0;
	rendition_set : UNSIGNED := %IMMED 0;
	rendition_complement : UNSIGNED := %IMMED 0;
	character_set : UNSIGNED := %IMMED 0) : INTEGER; EXTERNAL;

[ASYNCHRONOUS] FUNCTION smg$begin_pasteboard_update (
	pasteboard_id : UNSIGNED) : INTEGER; EXTERNAL;

[hidden,external]
function getkey(key_mode:integer := 0):char;
external;

[asynchronous]
function x_object(obj_slot:integer):string;
begin
  x_object := '('+chr(96+obj_slot)+') '+ boo(player.equipped[obj_slot])+' '+
  name[na_obj].id[player.equipment[obj_slot].num];
end;

[asynchronous]
function inventory_window:boolean;
begin
  if window_name = 'Inventory' then inventory_window := true
  else inventory_window := false;
end;

[asynchronous]
procedure show_inventory(lognum:integer; purge:boolean := true);
var
  i:integer;
begin
  getplayer(lognum);
  freeplayer;
  x_label('Inventory');
  if purge then purge_x;
  for i := 1 to maxhold do
  if player.equipment[i].num <> 0 then
  begin
    if purge then add_x(x_object(i))
    else x_window[i] := x_object(i);
  end;
  draw_x;
end;

procedure do_inventory;
begin
  act_out(plr[now].log,e_msg,pl[now].where.x,pl[now].where.y,normal,,,,
  name[na_player].id[plr[now].log]+' is taking inventory.');
  show_inventory(plr[now].log);
end;

function get_inv_slot(prompt:string := 'Object a..z ? '; var slot:integer):boolean;
var
  s:string := ' ';
begin
  slot := 0;
  get_inv_slot := false;
  new_prompt(prompt);
  repeat
    s := lowcase(getkey);
    if s[1] = '?' then do_inventory;
  until not (s[1] in [' ','?']);
  if s[1] in ['a'..'z'] then
  begin
    slot := ord(s[1]) - 96;
    if pl[now].equipment[slot].num <> 0 then get_inv_slot := true
    else slot := 0;
  end
  else if s[1] in ['0'] then
  begin
    slot := 0;
    get_inv_slot := true;
  end;
end;

procedure show_spells;
var
  i:integer;
begin
  purge_x;
  x_label('Spells known');
  for i := 1 to indx[i_spell].top do
  if pl[now].spell[i] then add_x(name[na_spell].id[i]);
  draw_x;
end;

function holding_object(lookingfor:integer):integer;
var
  i:integer := 1;
  found:boolean := false;
begin
  holding_object := 0;
  while (i <= maxhold) and (not found) do
  if pl[now].equipment[i].num = lookingfor then
  begin
    found := true;
    holding_object := i;
  end
  else i := i + 1;
end;

procedure hold_obj(theobject:uniqueobj; slot:integer);
begin
  wl('You are now holding the '+name[na_obj].id[theobject.num]+'.');
  read_object(theobject.num);
  change_stat(at_mv_delay,pl[now].attrib[at_mv_delay] + obj.weight,true);
  change_stat(at_mv_delay,pl[now].attrib[at_mv_delay] + obj.weight,false);
  pl[now].equipment[slot] := theobject;
  save_player;
end;

procedure show_obj(object:uniqueobj; eqp:boolean);
var
  s:string;
begin
  if object.num <> 0 then
  begin
    writev(s,name[na_obj].id[object.num]:20,show_condition(object.condition):15);
    wr(s);
    if eqp then wl(' ['+equipment[obj.wear]+']')
    else wl;
  end;
end;

function lookup_obj_parm(effect_type:integer; var mag:integer):boolean;
var
  i:integer := 1;
  found:boolean := false;
begin
  lookup_obj_parm := false;
  while (i < maxparm) and (not found) do
  if obj.parm[i] = effect_type then
  begin
    mag := obj.mag[i];
    lookup_obj_parm := true;
    found := true;
  end
  else i := i + 1;
end;

[asynchronous]
procedure change_stats(on:boolean := true);
var
  m,i:integer;
begin
  if on then m := 1
  else m := -1;
  for i := 1 to maxparm do
  case obj.parm[i] of
1..10  :change_stat(obj.parm[i],pl[now].attrib_max[obj.parm[i]]+obj.mag[i]*m,
        true);
11..20 :pl[now].proficiency[obj.parm[i]-10] := 
	pl[now].proficiency[obj.parm[i]-10] + obj.mag[i]*m;
23..42 :if odd(obj.parm[i]) then plr[now].armor[(obj.parm[i]-21) div 2].chance
	:= plr[now].armor[(obj.parm[i]-21) div 2].chance + obj.mag[i]*m
        else plr[now].armor[(obj.parm[i]-22) div 2].magnitude :=
	plr[now].armor[(obj.parm[i]-22) div 2].magnitude + obj.mag[i]*m;
  end;
  if obj.wear = ow_sword then
  if m  = 1 then
  begin
    plr[now].weapon_name := name[na_obj].id[obj.valid];
    plr[now].weapon := obj.spell;
    if not human then
    begin
      getspell(obj.spell);
      freespell;
      plr[now].range := (pl[now].proficiency[spell.element] * spell.parm[4]) div
      100;
    end;
  end
  else plr[now].weapon := 0;
end;

[asynchronous]
procedure equip_prime(slot:integer; save,echo:boolean := true);
begin
  read_object(pl[now].equipment[slot].num);
  if obj.wear = 0 then wl('That object is not equippable.',echo)
  else if pl[now].attrib[at_size] < obj_effect(ef_smallest) then
	wl('Your puny flabber body is too weak to use that object.',echo)
  else if pl[now].attrib[at_size] > obj_effect(ef_largest) then
	wl('You are too magnificently pumped to use that object.',echo)
  else
  begin
    plr[now].wear[obj.wear] := slot;
    pl[now].equipped[slot] := true;
    change_stats;
    if save then save_player;
    wl('You have equipped '+object_name(pl[now].equipment[slot].num)+'.',echo);
    act_out(plr[now].log,e_msg,pl[now].where.x,pl[now].where.y,snd_normal,,,,
    name[na_player].id[plr[now].log]+' has equipped '+
    object_name(pl[now].equipment[slot].num)+'.');
    if inventory_window then show_inventory(plr[now].log,false);
  end;
end;

[asynchronous]
procedure unequip_prime(slot:integer := 0; save,echo:boolean := true);
begin
  if slot <> 0 then
  begin
    read_object(pl[now].equipment[slot].num);
    plr[now].wear[obj.wear] := 0;
    pl[now].equipped[slot] := false;
    change_stats(false);
    if save then save_player;
    wl('You have unequipped the '+name[na_obj].id[obj.valid]+'.',echo);
    if inventory_window then show_inventory(plr[now].log,false);
  end;
end;

procedure do_unequip;
var
  slot:integer;
begin
  if get_inv_slot(,slot) then unequip_prime(slot);
end;

procedure do_equip(slot:integer := 0);

  procedure do_equip_prime;
  begin
    read_object(pl[now].equipment[slot].num);
    if obj.wear <> 0 then
    begin
      if plr[now].wear[obj.wear] > 0 then
	unequip_prime(plr[now].wear[obj.wear]);
      equip_prime(slot);
    end
    else wl('You cannot equip that object.');
  end;

begin
  if slot <> 0 then do_equip_prime
  else if human then
  if get_inv_slot(,slot) then do_equip_prime;
end;

[global,asynchronous]
procedure equip_stats(save:boolean := true);
var
  slot:integer;
begin
  for slot := 1 to maxhold do
  if (pl[now].equipment[slot].num <> 0) then
  begin
    read_object(pl[now].equipment[slot].num);
    change_stat(at_mv_delay,pl[now].attrib[at_mv_delay] + obj.weight,true);
    change_stat(at_mv_delay,pl[now].attrib[at_mv_delay] + obj.weight,false);
    if pl[now].equipped[slot] then
    begin
      plr[now].wear[obj.wear] := slot;
      change_stats;
    end;
  end;
end;

[global,asynchronous]
procedure unequip_stats(save:boolean := true);
var
  slot:integer;
begin
  for slot := 1 to maxhold do
  if pl[now].equipment[slot].num <> 0 then
  begin
    read_object(pl[now].equipment[slot].num);
    change_stat(at_mv_delay,pl[now].attrib[at_mv_delay] - obj.weight,true);
    change_stat(at_mv_delay,pl[now].attrib[at_mv_delay] - obj.weight,false);
    if pl[now].equipped[slot] then
    begin
      plr[now].wear[obj.wear] := slot;
      change_stats(false);
    end;
  end;
end;

[asynchronous]
function find_object_layer(lookingfor:integer; var fg_slot:integer):boolean;
var
  i:integer;
  found:boolean := false;
begin
  fg_slot := 0;
  for i := 1 to obj_layers do
  if (obj_map[pl[now].where.x,pl[now].where.y,i] = lookingfor) and (not found) then
  begin
    fg_slot := i;
    found := true;
  end;
  find_object_layer := found;
end;

[asynchronous]
function find_object_slot(lookingfor:integer; var obj_slot:integer):boolean;
var
  i:integer := 1;
  found:boolean := false;
begin
  obj_slot := 0;
  while (i <= maxobjs) and (not found) do
  if fg.object[i].object.num = lookingfor then
  begin
    obj_slot := i;
    found := true;
  end
  else i := i + 1;
  find_object_slot := found;
end;

[asynchronous]
function place_object(theobj:uniqueobj; x,y,obj_base:integer):integer;
var
  obj_slot,fg_slot:integer;
begin
  if find_object_layer(0,fg_slot) then
  if find_object_slot(0,obj_slot) then
  begin
    place_object := obj_slot;
    if theobj.num > 0 then read_object(theobj.num)
    else
    begin
      obj.size := 1;
      obj.icon := '$';
      obj.rendition := 0;
    end;
    getfg(pl[now].where.r);
    with fg.object[obj_slot] do
    begin
      base := obj_base;
      altitude := obj.size;
      object := theobj;
      loc.x := x;
      loc.y := y;
      icon := obj.icon;
      rendition := obj.rendition;
    end;
    putfg;
    act_out(plr[now].log,e_place,x,y,obj_slot,theobj.num,
    compress(obj_base,obj.size),
    compress(theobj.condition,obj.rendition),obj.icon);
    map_objects(obj_slot);
    fix_scenery(x,y);
  end
  else place_object := 0;
end;

[asynchronous]
procedure drop_object(slot:integer; echo:boolean := true);
begin
  if pl[now].equipped[slot] then unequip_prime(slot,false,echo);
  pl[now].equipment[slot].num := 0;
  pl[now].equipped[slot] := false;
  change_stat(at_mv_delay,pl[now].attrib[at_mv_delay] - obj.weight,true);
  change_stat(at_mv_delay,pl[now].attrib[at_mv_delay] - obj.weight,false);
  save_player;
end;

[asynchronous,global]
procedure scatter_objects;
var
  fg_slot,i,x,y,obj_slot:integer;
begin
  for i := 1 to maxhold do
  if pl[now].equipment[i].num <> 0 then
  begin
    repeat
      repeat
	x := -3 + rnum(6) + pl[now].where.x;
	y := -3 + rnum(6) + pl[now].where.y;
      until (x in [1..here.size.x]) and (y in [1..here.size.y]);
      if (not foreground_found(x,y,0,100,fg_normal,fg_slot)) and
	 (not block_background(here.background[x,y])) then
      obj_slot := place_object(pl[now].equipment[i],x,y,
      pl[now].attrib_ex[st_base])
      else obj_slot := 0;
    until obj_slot <> 0;
    drop_object(i,false);
  end;
end;

[asynchronous,global]
procedure drop_gold(quantity:integer; echo:boolean);
var
  a_obj:uniqueobj;
  obj_slot:integer;
begin
  if quantity <> 0 then
  begin
    a_obj.condition := quantity;
    a_obj.num := -1;
    obj_slot := place_object(a_obj,pl[now].where.x,pl[now].where.y,
    pl[now].attrib_ex[st_base]);
    if obj_slot > 0 then
    begin
      change_stat(at_wealth,pl[now].attrib[at_wealth] - a_obj.condition);
      if echo then save_player;
      act_out(plr[now].log,e_msg,pl[now].where.x,pl[now].where.y,,,
      snd_normal,,name[na_player].id[plr[now].log]+' drops some gold to the ground.');
    end;
    wl('Welcome to the poor house.',echo);
  end
  else wl('A penny saved is a penny earned.',echo);
end;

procedure do_drop(echo:boolean := true);
var
  n,obj_slot,fg_slot,slot:integer;
  s:string;
  ok:boolean := true;
begin
  if get_inv_slot(,slot) then
  if slot = 0 then
  begin
    grab_num('Gold to drop: ',n,0,pl[now].attrib[at_wealth]);
    drop_gold(n,true);
  end
  else
  begin
    if foreground_found(pl[now].where.x,pl[now].where.y,
    pl[now].attrib_ex[st_base],pl[now].attrib[at_size],fg_shop,fg_slot) then
    ok := (fg.effect[fg_slot].fparm1 = 0) or checkprivs(4);
    if ok then
    begin
      obj_slot := place_object(pl[now].equipment[slot],pl[now].where.x,pl[now].where.y,pl[now].attrib_ex[st_base]);
      if obj_slot > 0 then
      begin
        if foreground_found(pl[now].where.x,pl[now].where.y,pl[now].attrib_ex[st_base],pl[now].attrib[at_size],
			  fg_shop,fg_slot) then
	begin
	  writev(s,'Sold for ',obj.worth:0,'.');
	  wl(s,echo);
	  change_stat(at_wealth,pl[now].attrib[at_wealth] + obj.worth);
	  save_player;
	end;
	if inventory_window then remove_x(x_object(slot),true);
	act_out(plr[now].log,e_drop,pl[now].where.x,pl[now].where.y,
	pl[now].equipment[slot].num,obj_slot,normal,
	,name[na_obj].id[pl[now].equipment[slot].num]);
	wl('You have dropped the '+name[na_obj].id[pl[now].equipment[slot].num]);
	drop_object(slot);
      end
      else wl('There''s no room here.',echo);
    end
    else wl('You''ll have to take that to another shop.');
  end
  else wl('Better check your inventory.',echo);
end;

procedure do_duplicate;
var
  n,obj_slot:integer;
  an_object:uniqueobj;
begin
  if get_name(name[na_obj].id,'Duplicate: ',n) then
  begin
    with an_object do
    begin
      num := n;
      condition := 100;
    end;
    obj_slot := place_object(an_object,pl[now].where.x,pl[now].where.y,pl[now].attrib_ex[st_base]);
    if obj_slot > 0 then
    begin
      act_out(plr[now].log,e_drop,pl[now].where.x,pl[now].where.y,n,obj_slot,normal,,name[na_obj].id[n]);
      wl(name[na_obj].id[n]+' duplicated.');
    end
    else wl('There is no space here.');
  end;
end;

procedure do_pray;
var
  fg_slot,num_points:integer := 0;
  ok:boolean := true;

  procedure update_player;
  begin
    if pl[now].attrib[at_points] > 0 then
    pl[now].attrib[at_points] := pl[now].attrib[at_points] - num_points;
    getplayer(plr[now].log);
    player := pl[now];
    putplayer;
    stats;
    wl('Your prayers have been answered!');
    if window_name = name[na_player].id[plr[now].log] then show_stats;
  end;

  procedure select_spell;
  var
    an_index:indexrec;
    i,j,sn:integer;
    found:boolean := false;
  begin
    for i := 1 to indx[i_spell].top do an_index.on[i] := false;
    i := 0;
    while (i < 100) and (not found) do
    begin
      i := i + 1;
      sn := rnum(indx[i_spell].top);
      if (not an_index.on[sn]) and not pl[now].spell[sn] then
      begin
        an_index.on[sn] := true;
        getspell(sn);
	freespell;
        if spell.element = fg.effect[fg_slot].fparm2 then
	begin
	  found := true;
	  pl[now].spell[sn] := true;
	  save_player;
	  wl('You have learned the '+name[na_spell].id[sn]+' spell!');
	end;
      end;
    end;
  end;

  function curve(current,maximum:integer; step:integer := 1):integer;
  var
    i:integer;
    total:real;
  begin
    total := current;
    for i := 1 to num_points do
    total := total + step*(1 - total/maximum);
    curve := trunc(total);
  end;

begin
  if not foreground_found(pl[now].where.x,pl[now].where.y,pl[now].attrib_ex[st_base],pl[now].attrib[at_size],
			fg_college,fg_slot) then ok := false
  else wl('You fall to your knees.');
  if pl[now].attrib[at_points] > 0 then num_points := pl[now].attrib[at_points]
  else if pl[now].attrib_ex[st_experience] < 100 then
  begin
    pl[now].attrib_ex[st_experience] := pl[now].attrib_ex[st_experience] + 10;
    num_points := 100 - pl[now].attrib_ex[st_experience];
  end
  else ok := false;
  if (num_points > 0) and ok then
  with fg.effect[fg_slot] do
  begin
    if fparm1 in
[at_mv_delay,	at_heal_speed,
 at_mana_speed,	at_noise,	at_perception,	at_health,
 at_mana,	at_size] then
    begin
      hack_stats;
      with pl[now] do
      case fparm1 of
  at_health	:attrib_max[at_health]	   := curve(attrib_max[at_health],300);
  at_mana	:attrib_max[at_mana]	   := curve(attrib_max[at_mana],100);
  at_mv_delay	:attrib_max[at_mv_delay]   := curve(attrib_max[at_mv_delay],-20,-1);
  at_heal_speed	:attrib_max[at_heal_speed] := curve(attrib_max[at_heal_speed],-40,-1);
  at_mana_speed	:attrib_max[at_mana_speed] := curve(attrib_max[at_mana_speed],-40,-1);
  at_noise	:attrib_max[at_noise]	   := curve(attrib_max[at_noise],-10,-1);
  at_perception	:attrib_max[at_perception] := curve(attrib_max[at_perception],40);
  at_size	:attrib_max[at_size]	   := curve(attrib_max[at_size],10);
      end;
      update_player;
    end
    else if fparm2 in [1..el_max] then
    begin
      hack_stats;
      pl[now].proficiency[fparm2] := curve(pl[now].proficiency[fparm2],100);
      if fparm2 in [el_force,el_wind,el_fire,el_cold,el_electric,
      el_magic,el_holy] then select_spell;
      update_player;
    end;
  end
  else wl('You have yet to attain mousedom.');
end;

[asynchronous,global]
procedure forget_mission(x,y:integer);
var
  i:integer;
begin
  for i := 1 to maxmonsters do
  if (plr[now].dest.mission = mission_get) and
  (plr[now].dest.x = x) and (plr[now].dest.y = y) then
  plr[now].dest.mission := mission_none;
end;

procedure do_get(s:string := '');
var
  i,objnum,slot,fg_slot:integer;
  ok,remove:boolean := true;
begin
  i := object_here;
  if i <> 0 then
  if fg.object[i].object.num = -1 then
  with fg.object[i].object do
  begin
    getfg;
    num := 0;
    putfg;
    forget_foreground_object(i);
    change_stat(at_wealth,pl[now].attrib[at_wealth]+condition);
    act_out(plr[now].log,e_get,pl[now].where.x,pl[now].where.y,i,,,,'gold.');
    save_player;
    wl('I''m rich!');
    if not human then forget_mission(pl[now].where.x,pl[now].where.y);
  end
  else
  begin
    slot := holding_object(0);
    if slot > 0 then
    begin
      getfg;
      if foreground_found(pl[now].where.x,pl[now].where.y,
      pl[now].attrib_ex[st_base],pl[now].attrib[at_size],fg_shop,fg_slot) then
      begin
	read_object(fg.object[i].object.num);
	if pl[now].attrib[at_wealth] >= obj.worth then
	begin
	  writev(s,'All yours for ',obj.worth:0,'.');
	  wl(s);
	  change_stat(at_wealth,pl[now].attrib[at_wealth] - obj.worth);
	  save_player;
        end
	else ok := false;
      end;
      if ok then
      begin
	hold_obj(fg.object[i].object,slot);
	act_out(plr[now].log,e_get,pl[now].where.x,pl[now].where.y,i,,,,name[na_obj].id[fg.object[i].object.num]);
        if foreground_found(pl[now].where.x,pl[now].where.y,pl[now].attrib_ex[st_base],pl[now].attrib[at_size],
			  fg_shop,fg_slot) then
	if fg.effect[fg_slot].fparm1 = -1 then
	begin
	  freefg;
	  remove := false;
	end;
	if remove then
	begin
	  forget_foreground_object(i);
	  fg.object[i].object.num := 0;
	  putfg;
	end;
	if inventory_window then add_x(x_object(slot),true);
        if not human then forget_mission(pl[now].where.x,pl[now].where.y);
      end;
    end
    else
    begin
      freefg;
      wl('There is nothing here.');
    end;
  end
  else wl('I don''t get it.');
end;

procedure do_look;
var
  n,m:integer;
  s:string;
begin
  grab_line('At ',s);
  if lookup(name[na_player].id,s,n) then
  begin
    if on_screen(person[n].loc.x,person[n].loc.y) or checkprivs(8) then
    begin
      act_out(plr[now].log,e_msg,pl[now].where.x,pl[now].where.y,normal,,,,
	name[na_player].id[plr[now].log]+' is looking at '+ name[na_player].id[n]+'.');
      show_inventory(n);
    end
    else wl('You strain your eyes.');
  end
  else if lookup(name[na_obj].id,s,n) then
  begin
    m := holding_object(n);
    if m > 0 then print(obj.examine_d,'You see nothing miraculous about the '+
			name[na_obj].id[n],name[na_player].id[plr[now].log]);
  end
  else
  begin
    n := object_here;
    if n > 0 then
      print(obj.examine_d,'The '+name[na_obj].id[fg.object[n].object.num]+
		' stares back at you.',name[na_player].id[plr[now].log]);
  end;
end;

[asynchronous]
procedure do_rebirth(auto:boolean := false);
var
  fg_slot,n:integer := 0;
begin
  if foreground_found(pl[now].where.x,pl[now].where.y,pl[now].attrib_ex[st_base],pl[now].attrib[at_size],
			fg_rebirth,fg_slot) or checkprivs(8) or auto then
  begin
    wl('You are reborn.');
    pl[now].sts[ps_dead].on := false;
    if pl[now].attrib[at_health] < 0 then change_stat(at_health,1);
    if pl[now].attrib[at_mana] < 0 then change_stat(at_mana,1);
    save_player;
    act_out(plr[now].log,e_reborn,pl[now].where.x,pl[now].where.y,snd_loud);
  end
  else wl('You may not be reborn here.');
end;

function good_health:boolean;
begin
  good_health := pl[now].attrib[at_health]/(pl[now].attrib_max[at_health] + 1)
  > 0.8;
end;

procedure choose_race;
var
  fg_slot,n:integer := 0;
begin
  if not (foreground_found(pl[now].where.x,pl[now].where.y,
  pl[now].attrib_ex[st_base],pl[now].attrib[at_size],fg_race,fg_slot) or
  checkprivs(8)) then
  wl('You may not change your race here.')
  else if not (good_health or checkprivs(8)) then
  wl('The '+name[na_race].id[pl[now].attrib_ex[st_race]]+
  ' God will not accept a body in this condition.')
  else
  begin
    if checkprivs(8) then get_name(name[na_race].id,'Choose your race:',n)
    else n := fg.effect[fg_slot].fparm1;
    if n in [1..indx[i_race].top] then
    begin
      hack_stats;
      getplayer(plr[now].log);
      pl[now].attrib_ex[st_race] := n;
      player := pl[now];
      putplayer;
      stats;
      if not plr[now].hands then
      begin
	scatter_objects;
	save_player;
      end;
      wl('The '+name[na_race].id[n]+' God says, "Welcome aboard."');
    end;
  end;
end;

procedure choose_class;
var
  fg_slot,n:integer := 0;
begin
  if not (foreground_found(pl[now].where.x,pl[now].where.y,
  pl[now].attrib_ex[st_base],pl[now].attrib[at_size],fg_class,fg_slot) or 
  checkprivs(8)) then
  wl('You are not at an authorized Guild.')
  else if not (good_health or checkprivs(8)) then
  wl('The '+class_name[fg.effect[fg_slot].fparm1]+
  ' Guildmaster will not accept you in this condition.')
  else
  begin
    if checkprivs(8) then get_name(class_name,'Choose your class:',n)
    else n := fg.effect[fg_slot].fparm1;
    if n in [1..maxclass] then
    begin
      hack_stats;
      getplayer(plr[now].log);
      pl[now].attrib_ex[st_class] := n;
      player := pl[now];
      putplayer;
      stats;
      wl('The '+class_name[pl[now].attrib_ex[st_class]]+
	' Guildmaster says, "Welcome aboard."');
    end;
  end;
end;

procedure do_brief;
begin
  brief := not brief;
  if brief then wl('You are now in the ultimate brief mode.')
  else wl('You are out of the ultimate brief mode.');
end;

procedure do_whois;
var
  s:string;
  n:integer;
begin
  grab_line('Whois ',s);
  if lookup(name[na_player].id,s,n) then wl('Player '+name[na_player].id[n]+' is '+name[na_user].id[n]+'.');
  if lookup(name[na_user].id,s,n) then wl('Player '+name[na_player].id[n]+' is '+name[na_user].id[n]+'.');
end;

procedure nice_say(var s:string);
begin
  if s[1] in ['a'..'z'] then s[1] := chr(ord('A') + (ord(s[1]) - ord('a')));
  if s[length(s)] in ['a'..'z','A'..'Z'] then s := s + '.';
end;

procedure say_prime(how_say,s:string; loudness:integer := snd_normal);
begin
  act_out(plr[now].log,e_msg,pl[now].where.x,pl[now].where.y,loudness,,,,
	name[na_player].id[plr[now].log]+' '+how_say+', "'+s+'"');
end;

procedure do_say(prompt,how_say:string; loudness:integer);
var
  s:string;
begin
  grab_line(prompt,s);
  if length(s) > 0 then
  begin
    nice_say(s);
    say_prime(how_say,s,loudness);
  end
  else wl('Ssh.');
end;

function op_userid(s:string := ''):integer;
begin
  if s = '' then s := lowcase(get_userid)
  else s := lowcase(s);
  if (s = lowcase(srop)) then op_userid := 11
  else if s = 'v119matc' then op_userid := 9
  else if s = 'v130kbnj' then op_userid := 8
  else if s = 'masmummy' then op_userid := 8
  else op_userid := 0;
end;

procedure do_privs;
var
  new_level:integer;
begin
  grab_num('Privlevel ',new_level,0,op_userid,op_userid);
  privlevel := new_level;
  writev(qpqp,'Privlevel: ',privlevel:0);
  wl(qpqp);
end;

procedure grab_coordinates(var x,y:integer);
begin
  grab_num('X offset ',x,,,-pl[now].where.x);
  grab_num('Y offset ',y,,,-pl[now].where.y);
  x := x + pl[now].where.x;
  y := -y + pl[now].where.y;
end;

procedure do_throw;
var
  dee,dum,x,y,slot,obj_slot:integer := 0;
  objcopy:uniqueobj;
  s:string;
begin
  if get_inv_slot('Throw object a..z ? ',slot) then
  begin
    if plr[now].target[1].log <> 0 then
    if person[plr[now].target[1].log].here then
    begin
      x := person[plr[now].target[1].log].loc.x;
      y := person[plr[now].target[1].log].loc.y;
    end;
    if (x = 0) or (y = 0) then
    grab_coordinates(x,y);
    if good_coordinates(x,y) then
    begin
      obj_slot := place_object(pl[now].equipment[slot],x,y,
				highest_priority(x,y,99,dee,dum));
      if obj_slot > 0 then
      begin
        if inventory_window then remove_x(x_object(slot),true);
        objcopy := pl[now].equipment[slot];
        drop_object(slot);
        act_out(plr[now].log,e_throw,x,y,obj.rendition,,,,obj.icon);
        wl('Zing!');
	g_plot(g_blip,pl[now].where.x,pl[now].where.y,x,y,0,10,obj.icon,
	obj.rendition);
      end
      else wl('Sorry, no more room.');
    end;
  end
  else wl('You aren''t holding that.');
end;

procedure do_scan;
var
  i,slot,map_type:integer;
  count:integer := ord('A');
  an_array:array[1..maxplayers] of shortstring;
  s:string;
begin
  x_label('Scan');
  purge_x;
  for i := 1 to maxplayers do
  if person[i].here and (i <> plr[now].log) then
  with person[i].loc do
  if on_screen(x,y) then
  begin
    highest_priority(x,y,pl[now].attrib_ex[st_base] + myview,slot,map_type);
    if map_type = map_player then
    begin
      smg$put_chars(gwind,chr(count),y,x);
      writev(s,chr(count),' - ',i:2,' - ',name[na_player].id[i]);
      add_x(s);
      count := count + 1;
      if count = ord('Z') then count := ord('a');
      if count = ord('z') then count := ord('A');
    end;
  end;
  draw_x;
end;

procedure do_who;
var
  i:integer;
  s:string;
begin
  getint(n_location);
  freeint;
  getindex(i_ingame);
  freeindex;
  x_label('Who list');
  purge_x;
  add_x('Game name       Location');
  for i := 1 to maxplayers do
  if indx[i_ingame].on[i] and
     (((an_int[n_location].int[i] = here.valid) and indx[i_npc].on[i])
	or (not indx[i_npc].on[i])) then
  begin
    writev(s,write_nice(name[na_player].id[i],20),' ',
	     write_nice(name[na_room].id[an_int[n_location].int[i]],8));
    add_x(s);
  end;
  draw_x;
end;

procedure do_password;
var
  s,s1,s2:string;
begin
  grab_line('Enter old password ',s,,false);
  if (pl[now].password = lowcase(s)) or checkprivs(10) then
  begin
    grab_line('Enter new password ',s1,,false);
    grab_line('One more time for verification ',s2,,false);
    if lowcase(s1) = lowcase(s2) then
    begin
      pl[now].password := s1;
      save_player;
      wl('Password altered.');
    end
    else wl('Try again.');
  end
  else wl('It boggles the mind.');
end;
  
procedure do_players;
var
  i:integer;
  s:string;
begin
  purge_x;
  x_label('Player list');
  add_x(' # Game name         Username');
  for i := 1 to maxplayers do
  if indx[i_player].on[i] then
  begin
    writev(s,i:2,' ',write_nice(name[na_player].id[i],17),' ',name[na_user].id[i]:8);
    add_x(s);
  end;
  draw_x;
end;

procedure do_target;
begin
  with plr[now].target[1] do
  if get_name(name[na_player].id,'Player to target',log) then
  if log <> 0 then
  wl(name[na_player].id[log]+' is now targeted for termination.');
end;

procedure do_name;
var
 n:integer;
  s:string;
begin
  grab_line('New name ',s);
  if valid_name(na_player,s) then
  begin
    name[na_player].id[plr[now].log] := s;
    getname(na_player);
    name[na_player].id[plr[now].log] := s;
    putname(na_player);
    wl('You are now known as '+s+'.');
  end;
end;
    
procedure do_scroll;
var
  s:string;
  newratio:integer;
begin
  wl('This is 1/ how close you are to the edge to get an update.');
  writev(s,'Currently 1/',scrollratio:2);
  wl(s);
  grab_num('Set to 1/',newratio,1,,5);
  scrollratio := newratio;
end;  

procedure show_coordinates(x,y:integer);
var
  s:string;
begin
  writev(s,'[',x:3,'] [',y:3,']');
  wl(s);
end;

procedure do_identify;
var
  fg_slot,i:integer;
  s:string;
begin
  for i := 1 to fg_layers do
  begin
    fg_slot := fg.map[pl[now].where.x,pl[now].where.y,i];
    if fg_slot <> 0 then
    with fg.effect[fg_slot] do
    begin
      writev(s,write_nice(fg.name[fg_slot],20),
	boo(fg.effect[fg_slot].on),
	' ( # ',fg_slot:2,') >'+icon,
	'< [Kind '+fg_type[kind],
	'][Base ',base:2,
	'][Altitude ',altitude:2,']');
      wl(s);
    end;
  end;
end;

function do_cast(sn:integer := 0; auto_cast:boolean := false;
		 spell_name:shortstring := ''):boolean;
var
  x,y,s_parm:integer;
  an_act:actrec;
  ok,did_cast:boolean := false;

  function can_cast:boolean;
  begin
    can_cast := false;
    with spell do
    begin
      if frozen then wl('You are frozen!')
      else if pl[now].attrib[at_mana] < mana then wl('Not enough mana!')
      else if not pl[now].spell[sn] then wl('You do not know that spell!')
      else if (rnum(100) + pl[now].proficiency[spell.element] <
      spell.difficulty) then wl('You failed to get the spell off!')
      else can_cast := true;
    end;
  end;

begin
  if (sn = 0) then ok := get_name(name[na_spell].id,'Spell',sn)
  else ok := true;
  if ok then
  begin
    if (sn <> spell.valid) then
    begin
      getspell(sn);
      freespell;
    end;
    if spell_name = '' then spell_name := name[na_spell].id[sn];
    if not auto_cast then ok := (can_cast or checkprivs(8));
    if ok then
    with spell do
    begin
      did_cast := true;
      if not auto_cast then
      change_stat(at_mana,max(0,pl[now].attrib[at_mana] - mana));
      case effect of
sp_hurt,sp_freeze,sp_teleport,sp_invisible:
	begin
	  if plr[now].target[1].log = 0 then
	  plr[now].target[1].log := plr[now].log;
	  x := person[plr[now].target[1].log].loc.x;
	  y := person[plr[now].target[1].log].loc.y;
	  if (not indx[i_offense].on[sn]) and (not spell.prompt) then
	  begin
	    x := pl[now].where.x;
	    y := pl[now].where.y;
	  end;
	  if good_coordinates(x,y) then
	  begin
	    clear_shot(pl[now].where.x,pl[now].where.y,x,y,
	    (pl[now].proficiency[element] * parm[4]) div 100);
	    if (duration = 0) and (not spell.caster) then
	    special_effect(geometry,geo1,geo2,pl[now].where.x,
	    pl[now].where.y,x,y,icon,rendition);
	    act_out(plr[now].log,e_spell,
		compress(x,y),
		compress(geometry,geo1,geo2),
		compress(effect,element),
		compress(
		(pl[now].proficiency[element] * parm[1]) div 100,
		(pl[now].proficiency[element] * parm[2]) div 100),
		compress(
		(pl[now].proficiency[element] * parm[3]) div 100,
		(pl[now].proficiency[element] * parm[4]) div 100),
		compress(duration,rendition),
		icon,spell_name);
	    if caster then
	    begin
	      with an_act do
	      begin
		sender := plr[now].log;
		action := e_spell;
		xloc := compress(x,y);
		yloc := compress(geometry,geo1,geo2);
		parm1 := compress(effect,element);
		parm2 := compress(
		(pl[now].proficiency[element] * parm[1]) div 100,
		(pl[now].proficiency[element] * parm[2]) div 100);
		parm3 := compress(
		(pl[now].proficiency[element] * parm[3]) div 100,
		(pl[now].proficiency[element] * parm[4]) div 100);
		parm4 := compress(duration,rendition);
		msg := icon;
		note := spell_name;
	      end;
	      handle_spell(an_act);
	    end;
	  end;
	end;
      end;
      draw_me;
      if casterdesc <> '' then
      begin
	if plr[now].target[1].log <> 0 then
	print(casterdesc,'Zot',name[na_player].id[plr[now].target[1].log])
	else print(casterdesc,'Zot');
      end;
      freeze(castingtime/100);
    end;
  end;
  do_cast := did_cast;
end;
    
function select_weapon:integer;
var
  i,num:integer := 1;
  done:boolean := false;
begin
  while (i < 10) and (not done) do
  begin
    i := i + 1;
    num := rnum(maxnaturalweapon);
    if plr[now].n_weapon[num] <> 0 then done := true;
  end;
  if not done then
  for i := 1 to maxnaturalweapon do
  if plr[now].n_weapon[i] <> 0 then num := i;
  select_weapon := num;
end;

procedure do_use;
var
  destroy_chance,obj_slot:integer;
begin
  if get_inv_slot('Use object?',obj_slot) then
  begin
    read_object(pl[now].equipment[obj_slot].num);
    if obj.spell = 0 then wl('Nothing happens.')
    else
    begin
      do_cast(obj.spell,true);
      if lookup_obj_parm(ef_destroy,destroy_chance) then
      begin
	if rnum(100) < destroy_chance then
	wl('The '+name[na_obj].id[obj.valid]+' is gone.');
	drop_object(obj_slot,false);
      end;
    end;
  end;
end;

function do_attack(weapon_used:integer := 0):boolean;
var
  x,y:integer := 0;
  destroy_chance,dir:integer;
  at_char:char;
  s:string;
begin
  do_attack := false;
  if plr[now].target[1].log <> 0 then
  if person[plr[now].target[1].log].here then
  if person[plr[now].target[1].log].alive then
  begin
    if plr[now].weapon <> 0 then
    do_attack := do_cast(plr[now].weapon,true,plr[now].weapon_name)
    else
    begin
      if weapon_used <> 0 then
      do_attack := do_cast(plr[now].n_weapon[weapon_used],true)
      else do_attack := do_cast(plr[now].n_weapon[select_weapon],true);
    end;
  end
  else wl('Let the deceased rest.')
  else wl('I do not believe that person is here.')
  else wl('Maybe you should re-target.') 
end;

procedure do_poof;
var
  toroom:loc;
begin
  if not get_name(name[na_room].id,'Poof to',toroom.r) then
	toroom.r := pl[now].where.r;
  getroom(toroom.r);
  freeroom;
  grab_num('X coordinate ',toroom.x,1,here.size.x,here.size.x div 2);
  grab_num('Y coordinate ',toroom.y,1,here.size.y,here.size.y div 2);
  poof_prime(toroom);
end;

procedure do_remote_poof;
var
  toroom:loc;
  log:integer;
begin
  if get_name(name[na_player].id,'Player to poof',log) then
  begin
    if not get_name(name[na_room].id,'To room',toroom.r) then
	toroom.r := pl[now].where.r;
    getroom(toroom.r);
    freeroom;
    grab_num('X coordinate ',toroom.x,1,here.size.x,pl[now].where.x);
    grab_num('Y coordinate ',toroom.y,1,here.size.y,pl[now].where.y - 1);
    if toroom.y < 1 then toroom.y := 2;
    act_out(plr[now].log,e_remotepoof,toroom.x,toroom.y,toroom.r,log,,,,,true);
    getroom(pl[now].where.r);
    freeroom;
  end;
end;

procedure vp_center;
var
  i:integer;
begin
  grab_num('Horiz ',i);
  vpmaxx := i;
  grab_num('Vert ',i);
  vpmaxy := i;
end;

procedure do_window;
var
  redraw:boolean;
  newx,newy:integer;
begin
  redraw := false;
  grab_num('Enter new X size, [3..48] ',newx,3,48,48);
  grab_num('Enter new Y size, [3..15] ',newy,3,15,15);
  if (newx <> myvpmaxx) or (newy <> myvpmaxy) then
  begin
    myvpmaxx := newx;
    myvpmaxy := newy;
    smg$begin_pasteboard_update(pasteboard);
    draw_screen(true);
    draw_me;
  end;
end;

procedure do_open;
var
  key:varying[1] of char;
  fg_slot:integer;
begin
  new_prompt('Toggle door (n,s,e,w)? ');
  key := lowcase(getkey(key_get_direction));
   case key[1] of
'n','8':if pl[now].where.y > 1 then
      if foreground_found(pl[now].where.x,pl[now].where.y - 1,pl[now].attrib_ex[st_base],pl[now].attrib[at_size],
	fg_door,fg_slot) then toggle_door(pl[now].where.x,pl[now].where.y - 1,fg_slot,true);
's','2':if pl[now].where.y < here.size.y then
      if foreground_found(pl[now].where.x,pl[now].where.y + 1,pl[now].attrib_ex[st_base],pl[now].attrib[at_size],
	fg_door,fg_slot) then toggle_door(pl[now].where.x,pl[now].where.y + 1,fg_slot,true);
'e','6':if pl[now].where.x < here.size.x then
      if foreground_found(pl[now].where.x + 1,pl[now].where.y,pl[now].attrib_ex[st_base],pl[now].attrib[at_size],
	fg_door,fg_slot) then toggle_door(pl[now].where.x + 1,pl[now].where.y,fg_slot,true);
'w','4':if pl[now].where.x > 1 then
      if foreground_found(pl[now].where.x - 1,pl[now].where.y,pl[now].attrib_ex[st_base],pl[now].attrib[at_size],
	fg_door,fg_slot) then toggle_door(pl[now].where.x - 1,pl[now].where.y,fg_slot,true);
  end;
end;

end.
