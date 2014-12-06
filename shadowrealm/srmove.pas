[inherit 
('srinit','srsys','srmisc','srother','srio','srmap','sys$library:starlet'),
 environment('srmove')]

module srmove;

[ASYNCHRONOUS] FUNCTION lib$spawn (
	command_string : [CLASS_S] PACKED ARRAY [$l1..$u1:INTEGER] OF CHAR := %IMMED 0;
	input_file : [CLASS_S] PACKED ARRAY [$l2..$u2:INTEGER] OF CHAR := %IMMED 0;
	output_file : [CLASS_S] PACKED ARRAY [$l3..$u3:INTEGER] OF CHAR := %IMMED 0;
	flags : UNSIGNED := %IMMED 0;
	process_name : [CLASS_S] PACKED ARRAY [$l5..$u5:INTEGER] OF CHAR := %IMMED 0;
	VAR process_id : [VOLATILE] UNSIGNED := %IMMED 0;
	%IMMED completion_status_address : $DEFPTR := %IMMED 0;
	byte_integer_event_flag_num : $UBYTE := %IMMED 0;
	%IMMED [UNBOUND, ASYNCHRONOUS] PROCEDURE AST_address := %IMMED 0;
	%IMMED varying_AST_argument : [UNSAFE] INTEGER := %IMMED 0;
	prompt_string : [CLASS_S] PACKED ARRAY [$l11..$u11:INTEGER] OF CHAR := %IMMED 0;
	cli : [CLASS_S] PACKED ARRAY [$l12..$u12:INTEGER] OF CHAR := %IMMED 0) : INTEGER; EXTERNAL;

[ASYNCHRONOUS] FUNCTION lib$delete_file (
	filespec : [CLASS_S] PACKED ARRAY [$l1..$u1:INTEGER] OF CHAR;
	default_filespec : [CLASS_S] PACKED ARRAY [$l2..$u2:INTEGER] OF CHAR := %IMMED 0;
	related_filespec : [CLASS_S] PACKED ARRAY [$l3..$u3:INTEGER] OF CHAR := %IMMED 0;
	%IMMED [UNBOUND, ASYNCHRONOUS] PROCEDURE user_success_procedure := %IMMED 0;
	%IMMED [UNBOUND, ASYNCHRONOUS] PROCEDURE user_error_procedure := %IMMED 0;
	%IMMED [UNBOUND, ASYNCHRONOUS] PROCEDURE user_confirm_procedure := %IMMED 0;
	%IMMED user_specified_argument : [UNSAFE] INTEGER := %IMMED 0;
	VAR resultant_name : [CLASS_S,VOLATILE] PACKED ARRAY [$l8..$u8:INTEGER] OF CHAR := %IMMED 0;
	VAR file_scan_context : [VOLATILE] UNSIGNED := %IMMED 0) : INTEGER; EXTERNAL;

[ASYNCHRONOUS] FUNCTION smg$begin_pasteboard_update (
	pasteboard_id : UNSIGNED) : INTEGER; EXTERNAL;

[asynchronous,hidden,external]
procedure scatter_objects;
external;

[asynchronous,hidden,external]
procedure drop_gold(quantity:integer; echo:boolean);
external;

[asynchronous]
function good_coordinates(x,y:integer):boolean;
begin
  good_coordinates := (x > 0) and (y > 0) and
		      (x <= here.size.x) and (y <= here.size.y);
end;

procedure show_player_status;
var
  s:string;
  i:integer;
begin
  writev(s,name[na_player].id[plr[now].log],'''s stats');
  x_label(s);
  purge_x;
  for i := 1 to ps_max do
  if pl[now].sts[i].on then
  begin
    writev(s,write_nice(player_status[i],10),':',
	(pl[now].sts[i].time - getticks) div 10:0);
    add_x(s);
  end;
  draw_x;
end;

[asynchronous]
procedure show_stats;
var
  s:string;
  i:integer;
begin
  x_label(name[na_player].id[plr[now].log]);
  purge_x;
  add_x('Race  :'+name[na_race].id[pl[now].attrib_ex[st_race]]);
  add_x('Class :'+class_name[pl[now].attrib_ex[st_class]]);
  for i := 1 to at_max do
  begin
    writev(s,write_nice(attrib_name[i],16),':',pl[now].attrib[i]:0,'/',
	pl[now].attrib_max[i]:0);
    add_x(s);
  end;
  add_x('--------Proficiencies-------');
  for i := 1 to el_max do
  begin
    writev(s,write_nice(element[i],16),':',
    show_condition(pl[now].proficiency[i]));
    add_x(s);
  end;
  add_x('---------Misc Stats---------');
  for i := 1 to st_max do
  begin
    writev(s,write_nice(attrib_ex_name[i],16),':',pl[now].attrib_ex[i]:0);
    add_x(s);
  end;
  add_x('-----------Armor-----------');
  for i := 1 to el_max do
  begin
    writev(s,write_nice(element[i],10),' chance:',
    show_condition(plr[now].armor[i].chance));
    add_x(s);
    writev(s,write_nice(element[i],10),' mod   :',
    show_condition(plr[now].armor[i].magnitude));
    add_x(s);
  end;
  draw_x;
end;

[asynchronous]
function find_thought(looking_for:integer; var slot:integer):boolean;
var
  i:integer := 1;
  found:boolean := false;
begin
  while (i <= maxthoughts) and (not found) do
  if plr[now].target[i].log = looking_for then
  begin
    found := true;
    slot := i;
  end
  else i := i + 1;
  find_thought := found;
end;

[asynchronous]
procedure remember_attack(log,damage:integer);
var
  slot:integer;

  procedure remember_prime;
  begin
    plr[now].target[slot].log := log;
    plr[now].target[slot].hits := plr[now].target[slot].hits + 1;
    plr[now].target[slot].damage := plr[now].target[slot].damage + 1;
  end;

begin
  if plr[now].log <> log then
  begin
    if find_thought(log,slot) then remember_prime
    else if find_thought(0,slot) then remember_prime;
  end;
end;

[asynchronous]
procedure forget_attack(log:integer);
var
  slot:integer;
begin
  if find_thought(log,slot) then
  with plr[now].target[slot] do
  begin
    log := 0;
    damage := 0;
    hits := 0;
  end;
end;

[asynchronous]
procedure do_go(dirnum:integer; move_delay:boolean := true;
		move_modifier:integer := 0);
forward;

[asynchronous]
procedure forget_foreground_effect(slot:integer := 0);
var
  i,j,k:integer;
begin
  for i := 1 to maxhoriz do
  for j := 1 to maxvert do
  for k := 1 to fg_layers do
  if (fg.map[i,j,k] = slot) or (slot = 0) then fg.map[i,j,k] := 0;
end;

[asynchronous]
procedure forget_foreground_object(slot:integer := 0);
var
  i,j,k:integer;
begin
  for i := 1 to maxhoriz do
  for j := 1 to maxvert do
  for k := 1 to obj_layers do
  if (obj_map[i,j,k] = slot) or (slot = 0) then obj_map[i,j,k] := 0;
end;

[asynchronous]
procedure forget_all;
var
  i,j:integer;
begin
  for i := 1 to maxplayers do person[i].here := false;
  for i := 1 to maxhoriz do
  for j := 1 to maxvert do people_map[i,j] := 0;
end;

[asynchronous]
procedure leave_room(roomto:string := '');
begin
  act_out(plr[now].log,e_walkout,pl[now].where.x,pl[now].where.y,,,,,roomto);
  deassign_channel(person[plr[now].log].channel);
  forget_all;
  forget_foreground_object;
  forget_foreground_effect;
  smg$begin_pasteboard_update(pasteboard);
end;

[asynchronous]
procedure setup_room_process(roomnum:integer);
var
  prcnam,out_file_name:string;
  baspri:$uword := 4;
  pid,len:unsigned := 0;

  procedure spawn_proc(exe_dir:string);
  begin
    spawned_out := not (lib$spawn('run '+exe_dir+'srgod',,out_file_name,1,
    prcnam) = 1);
  end;

begin
  writev(prcnam,roomnum:0,' Control');
  writev(out_file_name,'sys$scratch:out_',roomnum:0,'.sr');
  sysstatus := lib$delete_file(out_file_name);
  syscheck('lib$delete_file');
  spawn_proc(root);
  add_acl(out_file_name,
  '(identifier=[mas,'+srop+'],access=read+write+execute+delete)');
  if spawned_out then
  begin
    act_out(plr[now].log,e_can_spawn,,,roomnum,,,,,,true);
    other_lognum := 0;
    wl('You feel a strange sensation...');
    wait(3);
    if other_lognum <> 0 then
    begin
      if checkprivs(10) then
      wl(name[na_player].id[other_lognum]+' is controlling randoms in your room.');
      act_out(plr[now].log,e_spawn,,,other_lognum,,,,,,,
      person[other_lognum].channel);
    end;
  end;
end;

[asynchronous]
procedure enter_room(roomto:loc; ratiox,ratioy:real := 0;
		     sameroom,npc_in:boolean := false);
var
  i,mask:integer := 0;
            
  function nobody_here:boolean;
  var
    ii:integer;
  begin
    nobody_here := true;
    for ii := 1 to indx[i_player].top do
    if an_int[n_location].int[ii] = pl[now].where.r then 
    if (ii <> plr[now].log) and
	(indx[i_ingame].on[ii]) and
	(not indx[i_npc].on[ii]) then nobody_here := false;
  end;

begin
  change_stat_ex(st_base,0);
  if not sameroom then
  begin
    pl[now].where.r := roomto.r;
    getint(n_location);
    an_int[n_location].int[plr[now].log] := roomto.r;
    putint(n_location);
    for i := 1 to maxfg do fg_printed[i] := false;
    getroom(roomto.r);
    freeroom;
    getfg(roomto.r);
    freefg;
    if human then
    begin
      if not assign_channel(here.mbx,person[plr[now].log].channel) then
      setup_room_process(here.valid)
      else
      begin
{The way it works is:  The person just coming into the game logs an e_assign
 to the process(es) already in the game.  When they respond with e_acknowledge,
 we'll start sending to them.}

{This is so if we dumped out, and the god process thought we were still in,
 we wouldn't try plotting them before they assigned the channel.  The point
 at which we start sending to it is once we get their
  1)  e_assign - for when room_process was just activated
  2)  e_ack    - for when room_process acknowledges our e_assign	}
	person[plr[now].log].here := true;
	act_out(plr[now].log,e_assign,,,,,,,mymbx,
		name[na_player].id[plr[now].log],,person[plr[now].log].channel);
	person[plr[now].log].here := false;
      end;
    end;
    if (here.kind = rm_dungeon) and human then
    if nobody_here then draw_map;
  end;
  if roomto.x = -1 then
  case roomto.y of
    1:begin
	pl[now].where.y := 1;
	pl[now].where.x := trunc(ratiox * here.size.x);
      end;
    2:begin
        pl[now].where.y := here.size.y;
	pl[now].where.x := trunc(ratiox * here.size.x);
      end;
    3:begin
	pl[now].where.x := here.size.x;
	pl[now].where.y := trunc(ratioy * here.size.y);
      end;
    4:begin
	pl[now].where.x := 1;
	pl[now].where.y := trunc(ratioy * here.size.y);
      end;
  end
  else
  if (roomto.x = 0) or (roomto.y = 0) then
  free_space(pl[now].where.x,pl[now].where.y)
  else
  begin
    pl[now].where.x := roomto.x;
    pl[now].where.y := roomto.y;
  end;
  draw_screen(sameroom);
  draw_me;
  mask := do_mask(not pl[now].sts[ps_dead].on,m_alive,human,m_human,
  pl[now].sts[ps_invisible].on,m_invisible);
  with pl[now] do
  if (not sameroom) or (npc_in) then
  act_out(plr[now].log,e_walkin,where.x,where.y,attrib_ex[st_base],
	attrib[at_size],where.r,mask,name[na_player].id[plr[now].log],,true)
  else act_out(plr[now].log,e_move,where.x,where.y,attrib_ex[st_base],
	attrib[at_size],where.r,mask,name[na_player].id[plr[now].log]);
end;

[asynchronous]
function dir_convert(dir:integer):integer;
begin
  case dir of
    6:dir_convert := 3;
    7:dir_convert := 4;
    8,9:dir_convert := 1;
    1:dir_convert := 2;
    otherwise dir_convert := dir;
  end;
end;

[asynchronous]
function find_exit(dir:integer; var exitnum:integer):boolean;
var
  i:integer;
begin
  exitnum := 0;
  find_exit := false;

  if dir <> 5 then
  if here.exit[dir_convert(dir)].toroom <> 0 then
  begin
    exitnum := dir_convert(dir);
    find_exit := true;
  end;

  if (exitnum = 0) and (dir = 5) then
  begin
    for i := 1 to fg_layers do
    if fg.map[pl[now].where.x,pl[now].where.y,i] <> 0 then
    if (fg.effect[fg.map[pl[now].where.x,pl[now].where.y,i]].kind = fg_exit) and
     (fg.effect[fg.map[pl[now].where.x,pl[now].where.y,i]].base = pl[now].attrib_ex[st_base])
	then exitnum := fg.map[pl[now].where.x,pl[now].where.y,i];
    if exitnum > 0 then find_exit := (fg.effect[exitnum].dest.r <> 0)
    else find_exit := false;
  end;
end;

[asynchronous]
procedure dispossess_someone(died:boolean := true);
var
  i:integer;
begin
  i := plr[now].log;
  getindex(i_ingame);
  indx[i_ingame].on[i] := false;
  putindex(i_ingame);
  if died then
  begin
    getname(na_player);
    name[na_player].id[plr[now].log] := 'Null';
    putname(na_player);
    act_out(i,e_walkout,,,,,,,'the halls of the dead');
  end
  else act_out(i,e_walkout,,,,,,,'Knox 110');
  pl[now].sts[ps_dead].on := true;
  person[i].here := false;
  monsters_active := monsters_active - 1;
end;

[asynchronous]
procedure do_exit(dirnum:integer);
var
  exitnum:integer;
  ratiox,ratioy:real;
  sameroom:boolean := false;
  dest:loc;
  old_mbx:shortstring;
  a_channel:$uword;
begin
  if find_exit(dirnum,exitnum) then
  begin
    ratiox := pl[now].where.x/here.size.x;
    ratioy := pl[now].where.y/here.size.y;

    if dirnum = 5 then dest := fg.effect[exitnum].dest
    else with here.exit[exitnum] do
    begin
      dest.r := toroom;
      dest.x := -1;
      dest.y := face;
    end;
    sameroom := (dest.r = pl[now].where.r);
    if human then
    begin
      if not sameroom then
      begin
        wl('Exiting '+name[na_room].id[pl[now].where.r]+'...');
        leave_room(name[na_room].id[dest.r]);
      end
      else fix_scenery(pl[now].where.x,pl[now].where.y);
      enter_room(dest,ratiox,ratioy,sameroom);
    end
    else
    begin
      if not sameroom then
      begin
	old_mbx := here.mbx;
	getint(n_location);
	an_int[n_location].int[plr[now].log] := dest.r;
	putint(n_location);
	getroom(dest.r);
	freeroom;
	if assign_channel(here.mbx,a_channel) then
	begin
	  act_out(0,e_possess,plr[now].log,,,,,,,old_mbx,,a_channel);
	  deassign_channel(a_channel);
	  dispossess_someone(false);
	end;
	getroom;
	freeroom;
      end
      else
      enter_room(dest,ratiox,ratioy,sameroom);
    end;
  end;
end;

[asynchronous]
function block_background(icon:char):boolean;
begin
  if icon in ['#','|','_','/','\'] then block_background := true
  else block_background := false;
end;

[asynchronous]
function bump_background(x,y:integer; move_delay:boolean := true):boolean;
var
  s:string;

  procedure delay(d_time:real);
  begin
    if move_delay then freeze(d_time);
  end;

begin
  bump_background := false;
  if block_background(here.background[x,y]) and (not checkprivs(2)) then
  begin
    bump_background := true;
    case here.background[x,y] of
    '#':s :='Arumph!';
    '|':s :='Oomph!';
    '/':s :='Whop!';
    '\':s :='Ooof!';
    '_':s :='Bif!';
    end;
    wl(s);
    if human then
    begin
      act_out(plr[now].log,e_msg,,,,,,,name[na_player].id[plr[now].log]+
	' slams into a wall with a '+s);
      delay(0.75);
    end;
  end
  else if (here.background[x,y] in ['~','^','"']) and (not checkprivs(8)) then
  begin
    case here.background[x,y] of
    '~':delay(0.5);
    '^':delay(1);
    '"':delay(0.25);
    end;
  end;
end;

[asynchronous]
function find_enemy(var slot:integer):boolean;
var
  i,most_damage:integer := 0;
begin
  find_enemy := false;
  for i := 1 to maxthoughts do
  if plr[now].target[i].damage > most_damage then
  begin
    most_damage := plr[now].target[i].damage;
    slot := i;
    find_enemy := true;
  end;
  find_enemy := (most_damage <> 0);
end;

[asynchronous]
function bump_someone(x,y,dir:integer):boolean;
var
  i,log,slot:integer;
begin
  bump_someone := false;
  log := people_map[x,y];
  if log <> 0 then
  if human then
  begin
    if not pl[now].sts[ps_dead].on and
    person[log].alive and
    person[log].here and
    (pl[now].attrib_ex[st_base] = person[log].feet) then
    begin
      bump_someone := true;
      wl('You bump into '+name[na_player].id[log]+'.');
      act_out(plr[now].log,e_bump,x,y,bell(pl[now].attrib[at_size],2),dir);
      if not indx[i_npc].on[log] then
      freeze(0.1 + pl[now].attrib[at_mv_delay] / 100);
    end;
  end
  else
  if person[log].alive and person[log].here and
  (pl[now].attrib_ex[st_base] = person[log].feet) then
  begin
    bump_someone := true;
    if find_enemy(slot) then
    if slot = plr[now].target[slot].log then
    begin
      act_out(plr[now].log,e_bump,x,y,bell(pl[now].attrib[at_size],2),dir);
      freeze(0.1 + pl[now].attrib[at_mv_delay] / 100);
    end;
  end;
end;

[asynchronous]
function step_up(x,y:integer; max_step:integer := -1;
		step_minimum,do_act:boolean := false):boolean;
var
  i:integer := 1;
  difference,mask:integer;
  ok:boolean := false;
begin
{If you can climb here and walkthrough, it'll climb up max_step or max_altitude
 if you can't walkthrough, you have to be able to get to the top}
  if max_step = -1 then max_step := pl[now].attrib[at_size] * 2;
  while (not ok) and (i <= fg_layers) do
  if fg.map[x,y,i] <> 0 then
  if fg.effect[fg.map[x,y,i]].on then
  with fg.effect[fg.map[x,y,i]] do
  begin
    difference := base + altitude - pl[now].attrib_ex[st_base];
    if walk_through then
    begin
	if step_minimum and (base > pl[now].attrib_ex[st_base]) then
	difference := base - pl[now].attrib_ex[st_base]
	else difference := min(difference,max_step);
    end;
    if (difference >= 1) and (difference <= max_step) and climb then
    begin
      if not brief then
	if pl[now].attrib[at_size] = 0 then wl('How did you manage that?')
	else
	case (100 * difference) div pl[now].attrib[at_size] of
	   0..20:wl('You casually step up.');
	  21..50:wl('You step up.');
	 51..100:wl('You jump up.');
	101..200:wl('You climb up.');
	  otherwise wl('You fly into the air.');
	end;
      ok := true;
      change_stat_ex(st_base,pl[now].attrib_ex[st_base] + difference);
      mask := do_mask(not pl[now].sts[ps_dead].on,m_alive,human,m_human,
      pl[now].sts[ps_invisible].on,m_invisible);
      if not pl[now].sts[ps_invisible].on then
      act_out(plr[now].log,e_move,pl[now].where.x,pl[now].where.y,
      pl[now].attrib_ex[st_base],pl[now].attrib[at_size],,mask);
    end
    else i := i + 1;
  end
  else i := i + 1
  else i := i + 1;
  step_up := ok;
end;

[asynchronous]
procedure do_fall(x,y:integer);
var
  old_height,slot,map_type:integer;
begin
  old_height := pl[now].attrib_ex[st_base];
  change_stat_ex(st_base,highest_priority(x,y,pl[now].attrib_ex[st_base],slot,map_type));
  if pl[now].attrib_ex[st_base] < old_height then
  case (100 * (old_height - pl[now].attrib_ex[st_base])) div (pl[now].attrib[at_size] + 1) of
0..9:;
10..30:
begin
  if not brief then wl('You step down.');
  act_out(plr[now].log,e_msg,,,pl[now].attrib[at_noise],,,,name[na_player].id[plr[now].log]+' steps down.');
end;
31..100:
begin
  if not brief then wl('You jump down.');
  act_out(plr[now].log,e_msg,,,pl[now].attrib[at_noise],,,,name[na_player].id[plr[now].log]+' makes a '+adverb+' jump down.');
end;
101..200:
begin
  if not brief then wl('You crash down.');
  act_out(plr[now].log,e_msg,,,pl[now].attrib[at_noise],,,,name[na_player].id[plr[now].log]+' crashes down with a '+adverb+' noise.');
end;
201..300:
begin
  if not brief then wl('You plummet to the ground.');
  act_out(plr[now].log,e_msg,,,pl[now].attrib[at_noise],,,,name[na_player].id[plr[now].log]+' plummets down with a '+adverb+' noise.');
end;
otherwise
begin
  if not brief then wl('Gravity rips your hapless body out of the air.');
  act_out(plr[now].log,e_msg,,,pl[now].attrib[at_noise],,,,name[na_player].id[plr[now].log]+' makes a '+adverb+' dent in the ground.');
end;

  end;
end;

[asynchronous]
function bump_foreground(x,y:integer):boolean;
var
  i:integer;
  ok,blocked:boolean := false;
begin
  for i := 1 to fg_layers do
  if fg.map[x,y,i] <> 0 then
  if fg.effect[fg.map[x,y,i]].on then
  with fg.effect[fg.map[x,y,i]] do
  begin
    if	((pl[now].attrib_ex[st_base] >= base) and
	(pl[now].attrib_ex[st_base] <= base+altitude) and
	(not walk_through)) or (( pl[now].sts[ps_dead].on) and (kind = fg_nodead))
	then blocked := true;
    if	((pl[now].attrib_ex[st_base] = base + altitude) and walk_on) or
	((pl[now].attrib_ex[st_base] = base) and walk_through) or
	((pl[now].attrib_ex[st_base] >= base) and (pl[now].attrib_ex[st_base] <=
	base + altitude) and climb and walk_through) then ok := true;
  end;

  if (not ok) or blocked then ok := step_up(x,y,,true);
  if (not ok) and (not blocked) then
  begin
    do_fall(x,y);
    ok := true;
  end;
  if (not brief) and blocked and (not ok) then wl('Blocked!');
  bump_foreground := (not ok) and (not checkprivs(2));
end;

[asynchronous]
function can_move(x,y,dir:integer; move_delay:boolean := true):boolean;
begin
  if (x < 1) or (y < 1) or (x > here.size.x) or (y > here.size.y) then
	can_move := false
  else if (bump_background(x,y,move_delay) and not pl[now].sts[ps_dead].on) or
	bump_someone(x,y,dir) then can_move := false
  else if bump_foreground(x,y) then can_move := false
  else can_move := true;
end;

[asynchronous]
procedure new_coords(old_x,old_y:integer; var tempx,tempy:integer; dir:integer);
begin
  tempx := old_x;
  tempy := old_y;
  if dir in [1,4,7] then tempx := old_x - 1;
  if dir in [7,8,9] then tempy := old_y - 1;
  if dir in [3,6,9] then tempx := old_x + 1;
  if dir in [1,2,3] then tempy := old_y + 1;
end;

[asynchronous]
procedure do_die(theirlog:integer);
var
  i:integer;
begin
  wl('You''re dead.');
  pl[now].sts[ps_dead].on := true;
  pl[now].sts[ps_dead].time := getticks + bell(3600,2);

  scatter_objects;
  drop_gold(pl[now].attrib[at_wealth],false);
  pl[now].attrib_ex[st_killed] := pl[now].attrib_ex[st_killed] + 1;
  act_out(plr[now].log,e_died,theirlog,pl[now].attrib_ex[st_experience],
    pl[now].attrib_max[at_points],pl[now].attrib_ex[st_kills],
    pl[now].attrib_ex[st_killed],,'weapon',name[na_player].id[plr[now].log]);
  getplayer(plr[now].log);
  hack_stats;
  with pl[now] do
  begin
    attrib_max[at_points]	:= 0;
    attrib_max[at_size]		:= 0;
    attrib_max[at_health]	:= attrib_max[at_health] div 2;
    attrib_max[at_mana]		:= attrib_max[at_mana] div 2;
    attrib_max[at_mv_delay]	:= attrib_max[at_mv_delay] div 2;
    attrib_max[at_heal_speed]	:= attrib_max[at_heal_speed] div 2;
    attrib_max[at_mana_speed]	:= attrib_max[at_mana_speed] div 2;
    attrib_max[at_noise]	:= attrib_max[at_noise] div 2;
    attrib_max[at_perception]	:= attrib_max[at_perception] div 2;
    for i := 1 to el_max do
    pl[now].proficiency[i] := pl[now].proficiency[i] div 2;
    for i := 1 to indx[i_spell].top do
    if rnum(3) = 1 then pl[now].spell[i] := false;
  end;
  player := pl[now];
  putplayer;
  if plr[now].npc then dispossess_someone
  else stats;
  if window_name = name[na_player].id[plr[now].log] then show_stats;
  plr[now].awake := getticks;
end;

[asynchronous]
function modify_hit(p1,p2:integer; attack_type:integer):integer;
var
  damage:integer;
begin
  damage := bell(p1,p2);
  modify_hit := damage;
  if (attack_type <> 0) and (p1 > 0) then
  if rnd100 < plr[now].armor[attack_type].chance then
  modify_hit := damage * (100 - plr[now].armor[attack_type].magnitude) div 100;
end;

[asynchronous]
procedure get_attack(sendlog,x,y,p1,p2,attack_type:integer;
			weaponname:string);
var
  damage:integer;
begin
  if not pl[now].sts[ps_dead].on then
  begin
    damage := modify_hit(p1,p2,attack_type);
    if sendlog <> 0 then
    begin
      lasthitstring := name[na_player].id[sendlog]+'''s '+weaponname;
      wr(lasthitstring+' ',not brief);
      case damage of
-maxint div 2..0:wl('heals you nicely.',not brief);
         1..10:wl('barely hits you.',not brief);
        11..20:wl('hits you good.',not brief);
        21..50:wl('bonks you hard.',not brief);
       51..100:wl('pummels you severly.',not brief);
      101..200:wl('creams your poor little body!',not brief);
        otherwise wl('bashes you into who-hash!',not brief);
      end;
    end
    else lasthitstring := weaponname;
    change_stat(at_health,pl[now].attrib[at_health] - damage);
    if pl[now].attrib[at_health] < 0 then do_die(sendlog);
  end;
end;

[asynchronous]
procedure add_event(theevent:actrec; duration:integer);
var
  i:integer := 1;
  found:boolean := false;
begin
  while (i <= event_max) and (not found) do
  if event[i].action = 0 then
  begin
    event[i] := theevent;
    event_time[i] := getticks + (duration * 10);
    found := true;
  end
  else i := i + 1;
end;  

[asynchronous]
procedure poof_prime(toroom:loc);
var
  sameroom:boolean;
begin
  sameroom := (pl[now].where.r = toroom.r);   
  if not sameroom then leave_room
  else fix_scenery(pl[now].where.x,pl[now].where.y);
  enter_room(toroom,,,sameroom);
end;

[asynchronous]
procedure get_bump(theirlog,force,dir:integer; sendname,weaponname:string);
begin
  change_stat(at_health,pl[now].attrib[at_health] - force);
  remember_attack(theirlog,force);
  wr(sendname+' ');
  case force of
  0..3:wl('bumps into you.');
  4..9:wl('runs you over.');
10..20:wl('bashes you severly.');
otherwise wl('pummels you into the ground.');
  end; 
  if (force div 2) + rnum(force) > pl[now].attrib[at_size] then do_go(dir,false);
  if pl[now].attrib[at_health] < 0 then do_die(theirlog);
end;

[asynchronous]
procedure handle_spell(an_act:actrec);
var
  duration,damage,x,y,geometry,geo1,geo2,moron,fg_slot,
  p1,p2,p3,p4,rend,sp_effect,sp_element:integer;
  a_loc:loc;

  procedure add_foreground;
  begin
    g_plot(geometry,x,y,geo1,geo2,0,10,an_act.msg[1],rend);
    fg_slot := empty_foreground;
    fg.name[fg_slot] := 'x';
    with fg.effect[fg_slot] do
    begin
      icon := an_act.msg[1];
      rendition := rend;
      base := 0;
      altitude := 10;
      case sp_effect of
sp_hurt:begin
	  kind := fg_hurt;
	  fparm2 := p1;
	  fparm3 := p2;
	end;
      end;
      fparm1 := sp_element;
      on := true;
      walk_through := true;
      walk_on := false;
      climb := false;
    end;
    map_foreground(fg_slot,geometry,x,y,geo1,geo2,true);
    an_act.parm4 := fg_slot;
    add_event(an_act,duration);
  end;

begin
  with an_act do
  begin
    decompress(parm4,duration,rend,moron);
    decompress(xloc,x,y,moron);
    decompress(yloc,geometry,geo1,geo2);
    decompress(parm1,sp_effect,sp_element,moron);
    decompress(parm2,p1,p2,moron);
    decompress(parm3,p3,p4,moron);
    if duration > 0 then add_foreground
    else special_effect(geometry,geo1,geo2,person[sender].loc.x,
    person[sender].loc.y,x,y,msg[1],rend);
    if hit_me(geometry,geo1,geo2,x,y) then
    begin
      case sp_effect of
sp_hurt:get_attack(sender,x,y,p1,p2,sp_element,note);
sp_invisible:
        begin
	  if not pl[now].sts[ps_invisible].on then
	  begin
	    pl[now].sts[ps_invisible].on := true;
	    pl[now].sts[ps_invisible].time := getticks;
          end;
	  pl[now].sts[ps_invisible].time :=
	  pl[now].sts[ps_invisible].time + 10 * bell(p1,p2);
	  act_out(plr[now].log,e_disappear);
        end;
sp_freeze:
	begin
	  damage := modify_hit(p1,p2,sp_element);
	  freeze(damage);
	  wl('You have been frozen!');
	end;
sp_teleport:
	begin
	  a_loc.r := here.valid;
	  moron := 0;
	  with a_loc do
	  repeat
	    moron := moron + 1;
	    repeat
	      x := pl[now].where.x + 2 * rnum(p1) - p1;
	      y := pl[now].where.y + 2 * rnum(p1) - p1;
	    until good_coordinates(x,y);
	  until not foreground_found(x,y,pl[now].attrib_ex[st_base],
		pl[now].attrib_ex[st_base] + pl[now].attrib[at_size],
		fg_no_teleport,fg_slot) or (moron = 1000);
	  if good_coordinates(x,y) and (moron < 1000) then poof_prime(a_loc);
	end;
      end;
      remember_attack(sender,damage);
    end;
  end;
end;

[asynchronous]
procedure do_view(short_range:boolean := false);
var
  head_alt:integer;
begin
{  if checkprivs(2,false) then
  begin
    grab_num('Enter "head" altitude ',head_alt,,,pl[now].attrib[at_size]);
    myview := head_alt - pl[now].attrib_ex[st_base];
  end
}
  if myview <> 99 then myview := 99
  else myview := pl[now].attrib[at_size];
  if (not brief) and (not short_range) then wl('View toggled.');
  fix_room(pl[now].attrib_ex[st_base]+myview,short_range);
end;

[asynchronous]
procedure check_location(first:boolean := true);
{This is gonna check for those all important things that happen when you
 stand in a special place such as...
 Taking damage from foreground effect
 Printing a description.
 Triggering a trap_door...}
var
  slot,i:integer;
begin
{if debug and not human then
begin
  writev(qpqp,pl[now].where.x,pl[now].where.y,plr[now].log,now);
  bug_out(qpqp);
end;}
  for i := 1 to fg_layers do
  begin
    slot := fg.map[pl[now].where.x,pl[now].where.y,i];
    if slot <> 0 then
    with fg.effect[slot] do
    if overlap(base,altitude,pl[now].attrib_ex[st_base],pl[now].attrib[at_size]) then
    begin
      if (not fg_printed[slot]) and on then
      begin
	print(dsc);
	fg_printed[slot] := true;
      end;
      if on and first then
      case kind of
fg_view	:do_view(true);
fg_turn_on:if not pl[now].sts[ps_dead].on then turn_on_fg(slot);
fg_turn_off:if not pl[now].sts[ps_dead].on then turn_off_fg(slot);
fg_toggle:if not pl[now].sts[ps_dead].on then toggle_fg(slot);
fg_delay :freeze(fparm1 / 100);
fg_race  :if fparm1 <> 0 then wl('You feel the presence of the '+
	  name[na_race].id[fparm1]+' god here.')
	  else wl('You feel an unknown presence here.');
fg_class :if fparm1 <> 0 then wl('The '+class_name[fparm1]+
	  ' Guildmaster is in.')
	  else wl('The Guildmaster is out.');
fg_college:if fparm1 <> 0 then 
	wl('Welcome to the college of '+attrib_name[fparm1]+'.')
	else if fparm2 <> 0 then
	wl('Welcome to the college of '+element[fparm2]+'.');
fg_rebirth:if  pl[now].sts[ps_dead].on then wl('You feel a great energy around you.');
      end
      else if on then
      case kind of
fg_hurt  :if not pl[now].sts[ps_dead].on then get_attack(0,pl[now].where.x,pl[now].where.y,
	fparm2,fparm3,fparm1,fg.name[slot]);
fg_poison:begin
	    wl('You feel very sick.');
	    if not pl[now].sts[ps_poisoned].on then
	    begin
	      pl[now].sts[ps_poisoned].on := true;
	      pl[now].sts[ps_poisoned].time := getticks + 300;
	    end
	    else
	    pl[now].sts[ps_poisoned].time :=
	    pl[now].sts[ps_poisoned].time + 300;
	  end;
fg_sliding:do_go(fparm1,false,fparm2);
      end;
    end;
  end;
end;

[asynchronous]
function object_here:integer;
var
  found:boolean := false;
  i:integer := 1;
begin
  object_here := 0;
  while (i <= obj_layers) and (not found) do
  if obj_map[pl[now].where.x,pl[now].where.y,i] <> 0 then
  begin
    with fg.object[obj_map[pl[now].where.x,pl[now].where.y,i]] do
    if overlap(base,altitude,pl[now].attrib_ex[st_base],pl[now].attrib[at_size]) then
    begin
      found := true;
      object_here := obj_map[pl[now].where.x,pl[now].where.y,i];
    end
    else i := i + 1;
  end
  else i := i + 1;
end;

[asynchronous]
procedure check_objects;
var
  n:integer;
  s:string;
begin
  n := object_here;
  if n > 0 then
  with fg.object[n].object do
  if num > 0 then wl('There is '+object_name(num)+' here.')
  else
  begin
    writev(s,'There is ',condition:0,' gold here.');
    wl(s);
  end;
end;

[asynchronous]
function paid_toll:boolean;
var
  fg_slot:integer;
  s:string;
begin
  paid_toll := false;
  if foreground_found(pl[now].where.x,pl[now].where.y,
  pl[now].attrib_ex[st_base],pl[now].attrib[at_size],fg_exit,fg_slot) then
  begin
    if fg.effect[fg_slot].fparm1 <> 0 then
    begin
      if pl[now].attrib[at_wealth] >= fg.effect[fg_slot].fparm1 then
      begin
	writev(s,'Do you wish to pay the ',fg.effect[fg_slot].fparm1:0,
	' gold toll');
	if grab_yes(s) then
	begin
	  paid_toll := true;
	  change_stat(at_wealth,pl[now].attrib[at_wealth] -
          fg.effect[fg_slot].fparm1);
	  save_player;
	end;
      end
      else wl('You cannot afford the toll.');
    end
    else paid_toll := true;
  end;
end;

procedure do_go{(dirnum:integer; move_delay:boolean := true;
			move_modifier:integer := 0)};
var
  mask,tempx,tempy:integer := 0;
  s:string;
  light:boolean := true;
begin
   if not (frozen and move_delay) then
   begin
    if drag_char <> chr(0) then here.background[pl[now].where.x,
    pl[now].where.y] := drag_char;
    if fg_map > 0 then map_foreground(fg_map,g_point,pl[now].where.x,pl[now].where.y)
    else if fg_map < 0 then map_foreground(abs(fg_map)
  			,g_point,pl[now].where.x,pl[now].where.y,,,false);
    new_coords(pl[now].where.x,pl[now].where.y,tempx,tempy,dirnum);
    if (tempx < 1) or (tempx > here.size.x) or
    (tempy < 1) or (tempy > here.size.y) then do_exit(dirnum)
    else if (dirnum = 5) then
    begin
      if paid_toll then do_exit(dirnum);
    end
    else
    if can_move(tempx,tempy,dirnum) then
    begin
      people_map[pl[now].where.x,pl[now].where.y] := 0;
      fix_scenery(pl[now].where.x,pl[now].where.y);
      person[plr[now].log].loc.x := tempx;
      person[plr[now].log].loc.y := tempy;
      pl[now].where.x := tempx;
      pl[now].where.y := tempy;
      people_map[pl[now].where.x,pl[now].where.y] := plr[now].log;
      mask := do_mask(not pl[now].sts[ps_dead].on,m_alive,human,m_human,
      pl[now].sts[ps_invisible].on,m_invisible);
      if not pl[now].sts[ps_invisible].on then
      act_out(plr[now].log,e_move,pl[now].where.x,pl[now].where.y,
      pl[now].attrib_ex[st_base],pl[now].attrib[at_size],,mask);
      center_me;
      draw_me;
      check_location(true);
      check_objects;
      if (not checkprivs(8)) and move_delay then
      freeze((pl[now].attrib[at_mv_delay]+move_modifier) / 100)
      else freeze (move_modifier / 100);
    end;
  end;
end;

function find_fg(lookingfor:integer := 0; var slot:integer):boolean;
var
  i:integer;
  found:boolean := false;
begin
  slot := 0;
  i := 1;
  while (i <= maxfg) and (not found) do
  if fg.effect[i].kind = 0 then
  begin
    slot := i;
    found := true;
  end
  else i := i + 1;
  find_fg := found;
end;

end.
