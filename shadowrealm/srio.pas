[inherit('srinit','srsys','sys$library:starlet'),
 environment('srio')]

module srio;

[hidden,external,asynchronous]
procedure remove_x(s:string; draw:boolean := false);
external;

[hidden,external,asynchronous]
procedure unplot_player(theirlog:integer);
external;

[hidden,external,asynchronous]
procedure equip_stats(save:boolean := true);
external;

[hidden,external,asynchronous]
procedure unequip_stats(save:boolean := true);
external;

[asynchronous]
procedure perf(s:string);
begin
  if performance then wl(s);
end;

[asynchronous]
function valid_index(indexnum:integer; n:integer; echo:boolean := false):boolean;
begin
  if (n > 0) and (n <= indx[indexnum].top) then valid_index := true
  else
  begin
    valid_index := false;
    wl('Invalid index.',echo);
  end;
end;

[asynchronous]
procedure collision_wait;
var
  wait_time:real;
begin
  wait_time := random / 5;
  if wait_time < 0.001 then wait_time := 0.001;
  wait(wait_time);
end;

[asynchronous]
procedure deadcheck(var err:integer; s:string);
begin
  err := err + 1;
  if err > maxerr then
  begin
    wl(s+' seems to be deadlocked.');
    if grab_yes('Halt (y/n) ') then halt;
    err := 0;
  end;
end;

[global,asynchronous]
procedure getindex(n:integer);
var
  err:integer;
begin
  perf('getindex');
  indexfile^.valid := 0;
  err := 0;
  find(indexfile,n,error := continue);
  while indexfile^.valid <> n do
  begin              
    deadcheck(err,'getindex');
    collision_wait;
    find(indexfile,n,error := continue);
  end;
  indx[n] := indexfile^;
end;

[global,asynchronous]
procedure putindex(n:integer);
begin
  perf('putindex');
  locate(indexfile,n);
  indexfile^ := indx[n];
  put(indexfile);
end;

[global,asynchronous]
procedure freeindex;
begin
  perf('freeindex');
  unlock(indexfile);
end;

[asynchronous]
procedure getrace(n:integer);
var
  err:integer;
begin
  perf('getrace');
  if valid_index(i_race,n) then
  begin
    racefile^.valid := 0;
    err := 0;
    find(racefile,n,error := continue);
    while racefile^.valid <> n do
    begin              
      deadcheck(err,'getrace');
      collision_wait;
      find(racefile,n,error := continue);
    end;
    race := racefile^;
  end;
end;

procedure putrace;
begin
  perf('putrace');
  locate(racefile,race.valid);
  racefile^ := race;
  put(racefile);
end;

[asynchronous]
procedure freerace;
begin
  perf('freerace');
  unlock(racefile);
end;

[asynchronous]
procedure getint(n:integer);
var
  err:integer;
begin
  perf('getint');
  intfile^.valid := 0;
  err := 0;
  find(intfile,n,error := continue);
  while intfile^.valid <> n do
  begin
    deadcheck(err,'getint');
    collision_wait;
    find(intfile,n,error := continue);
  end;
  an_int[n] := intfile^;
end;

procedure freeint;
begin
  perf('freeint');
  unlock(intfile);
end;

[asynchronous]
procedure putint(n:integer);
begin
  perf('putint');
  locate(intfile,n);
  intfile^ := an_int[n];
  put(intfile);
end;

[asynchronous]
procedure getname(n:integer);
var
  err: integer;
begin
  perf('getname');
  namefile^.valid := 0;
  err := 0;
  find(namefile,n,error := continue);
  while namefile^.valid <> n do
  begin
    deadcheck(err,'getnamefile');
    collision_wait;
    find(namefile,n,error := continue);
  end;
  name[n] := namefile^;
end;

[asynchronous]
procedure putname(n:integer);
begin
  perf('putname');
  locate(namefile,n);
  namefile^ := name[n];
  put(namefile);
end;

[asynchronous]
procedure freename;
begin
  perf('freename');
  unlock(namefile);
end;

[asynchronous]
procedure getroom(n:integer:= 0);
var
  err: integer;
begin
  if not valid_index(i_room,n) then n := pl[now].where.r;
  perf('getroom');
  roomfile^.valid := 0;
  err := 0;
  find(roomfile,n,error := continue);
  while roomfile^.valid <> n do
  begin
    deadcheck(err,'getroom');
    collision_wait;
    find(roomfile,n,error := continue);
  end;
  here := roomfile^;
end;

[asynchronous]        
procedure putroom;
begin
  perf('putroom');
  locate(roomfile,here.valid);
  roomfile^ := here;
  put(roomfile);
end;
     
[asynchronous]
procedure freeroom;
begin 
  perf('freeroom');
  unlock(roomfile);
end;

[asynchronous]
procedure getfg(n:integer:= 0);
var
  err:integer;
begin
  if not valid_index(i_room,n) then n := pl[now].where.r;
  fgfile^.valid := 0;
  err := 0;
  find(fgfile,n,error := continue);
  while fgfile^.valid <> n do
  begin
    deadcheck(err,'getfg');
    collision_wait;
    find(fgfile,n,error := continue);
  end;
  fg := fgfile^;
end;

[asynchronous]        
procedure putfg;
begin
  perf('putfg');
  locate(fgfile,here.valid);
  fgfile^ := fg;
  put(fgfile);
end;
     
[asynchronous]
procedure freefg;
begin
  perf('freefg');
  unlock(fgfile);
end;

[asynchronous]
procedure getplayer(n:integer);
var
  err:integer;
begin
  perf('getplayer');
  if valid_index(i_player,n) then
  begin
    err := 0;
    playerfile^.valid := 0;
    find(playerfile,n,error := continue);
    while playerfile^.valid <> n do
    begin
      deadcheck(err,'getplayer');
      collision_wait;
      find(playerfile,n,error := continue);
    end;
    player := playerfile^;
  end;
end;

[asynchronous]
procedure putplayer;
begin
  perf('putplayer');
  locate(playerfile,player.valid);
  playerfile^ := player;
  put(playerfile);
end;

[asynchronous]
procedure freeplayer;
begin
  perf('freeplayer');
  unlock(playerfile);
end;
           
[asynchronous]
procedure getobj(n:integer);
var
  err:integer;
begin
  perf('getobj');
  if valid_index(i_object,n) then
  begin
    objfile^.valid := 0;
    err := 0;
    find(objfile,n,error := continue);
    while objfile^.valid <> n do
    begin
      deadcheck(err,'getobj');
      collision_wait;
      find(objfile,n,error := continue);
    end;
    obj := objfile^;
  end;
end;

[asynchronous]
procedure putobj;
begin
  perf('putobj ');
  locate(objfile,obj.valid);
  objfile^ := obj;
  put(objfile);
end;

[asynchronous]
procedure freeobj;
begin
  perf('freeobj');
  unlock(objfile);
end;

[asynchronous]
procedure read_object(n:integer);
begin
  if obj.valid <> n then
  begin
    getobj(n);
    freeobj;
  end;
end;

[asynchronous]
procedure getspell(n:integer);
var
  err:integer;
begin
  perf('getspell');
  if valid_index(i_spell,n) then
  begin
    spellfile^.valid := 0;
    err := 0;
    find(spellfile,n,error := continue);
    while spellfile^.valid <> n do
    begin
      deadcheck(err,'getspell');
      collision_wait;
      find(spellfile,n,error := continue);
    end;
    spell := spellfile^;
  end;
end;

[asynchronous]
procedure putspell;
begin
  perf('putspell ');
  locate(spellfile,spell.valid);
  spellfile^ := spell;
  put(spellfile);
end;

[asynchronous]
procedure freespell;
begin
  perf('freespell');
  unlock(spellfile);
end;

procedure typefile(filename:string);
var
  textfile:text;
  aline:string;
  error:boolean;
begin
  error := false;
  open(textfile,filename,history := old,sharing := readonly,
	error := continue);
  reset(textfile);
  repeat
    if not eof (textfile) then
    begin
      readln(textfile,aline);
      wl(aline);
    end
    else error := true;
  until error;
  close(textfile);
end;

[asynchronous]
procedure player_stats;
begin
  if player.valid <> plr[now].log then
  begin
    getplayer(plr[now].log);
    freeplayer;
  end;
  pl[now] := player;
  with person[plr[now].log] do
  begin
    loc.x := pl[now].where.x;
    loc.y := pl[now].where.y;
  end;
end;

[asynchronous]
procedure stats;
var
  i:integer;

  procedure race_stats;
  begin
    if race.valid <> pl[now].attrib_ex[st_race] then
    begin
      getrace(pl[now].attrib_ex[st_race]);
      freerace;
    end;
    with race do
    begin
      for i := 1 to el_max do
      begin
        pl[now].proficiency[i] := pl[now].proficiency[i] + race.proficiency[i];
        plr[now].armor[i].chance := armor[i].chance;
        plr[now].armor[i].magnitude := armor[i].magnitude;
        plr[now].sound := sound;
        plr[now].hands := hands;
        plr[now].n_weapon := weapon;
      end;
      for i := 1 to at_max do
      if not (human and (i in [at_wealth,at_points])) then
      begin
	pl[now].attrib_max[i] := pl[now].attrib_max[i] + attrib[i];
	if i <> at_points then 
	pl[now].attrib[i] := pl[now].attrib[i] + attrib[i];
      end;
    end;
  end;

  procedure class_stats;
  begin
    with class[pl[now].attrib_ex[st_class]] do
    begin
      for i := 1 to at_max do
      if not (human and (i in [at_wealth,at_points])) then
      begin
	pl[now].attrib_max[i] := pl[now].attrib_max[i] + attrib[i];
	if i <> at_points then pl[now].attrib[i] := pl[now].attrib[i] + attrib[i];
      end;
      for i := 1 to el_max do
      pl[now].proficiency[i] := pl[now].proficiency[i] + proficiency[i];
    end;
  end;

  procedure condition_stats;
  begin
    for i := 1 to ps_max do
    if pl[now].sts[i].on then
    pl[now].sts[i].time := pl[now].sts[i].time + getticks;
  end;

begin
  race_stats;
  class_stats;
  condition_stats;
  equip_stats(false);
end;

[asynchronous]
procedure hack_stats;
var
  i:integer;

  procedure hack_race_stats;
  begin
    if race.valid <> pl[now].attrib_ex[st_race] then
    begin
      getrace(pl[now].attrib_ex[st_race]);
      freerace;
    end;
    with race do
    begin
      for i := 1 to at_max do
      if not (human and (i in [at_wealth,at_points])) then
      begin
	pl[now].attrib[i] := pl[now].attrib[i] - attrib[i];
	pl[now].attrib_max[i] := pl[now].attrib_max[i] - attrib[i];
      end;
      for i := 1 to el_max do
	pl[now].proficiency[i] := pl[now].proficiency[i] - proficiency[i];
    end;
  end;

  procedure hack_class_stats;
  begin
    with class[pl[now].attrib_ex[st_class]] do
    begin
      for i := 1 to at_max do
      if not (human and (i in [at_wealth,at_points])) then
      begin
	pl[now].attrib[i] := pl[now].attrib[i] - attrib[i];
	pl[now].attrib_max[i] := pl[now].attrib_max[i] - attrib[i];
      end;
      for i := 1 to el_max do
  	pl[now].proficiency[i] := pl[now].proficiency[i] - proficiency[i];
    end;
  end;

  procedure hack_condition_stats;
  begin
    for i := 1 to ps_max do
    if pl[now].sts[i].on then
    pl[now].sts[i].time := pl[now].sts[i].time - getticks;
  end;

begin
  hack_race_stats;
  hack_class_stats;
  hack_condition_stats;
  unequip_stats(false);
end;

[asynchronous]
procedure save_player;
var
  i:integer;
begin
  hack_stats;
  getplayer(plr[now].log);
  player := pl[now];
  putplayer;
  stats;
end;

[asynchronous]
procedure readnames;
var
  i:integer;
begin
  for i := 1 to na_max do
  begin
    getname(i);
    freename;
  end;
end;

procedure readints;
var
  i:integer;
begin
  for i := 1 to n_max do
  begin
    getint(i);
    freeint;
  end;
end;

procedure readindexes;
var
  i:integer;
begin
  for i := 1 to i_max do
  begin
    getindex(i);
    freeindex;
  end;
end;

[asynchronous]
procedure unwho_prime(lognum:integer; echo:boolean);
begin
  wl('It appears '+name[na_player].id[lognum]+' was stackdumped.',echo);
  getindex(i_ingame);
  indx[i_ingame].on[lognum] := false;
  putindex(i_ingame);
end;

[asynchronous]
procedure remove_player(log:integer; echo:boolean := false;
			unwho:boolean := true);
begin
  deassign_channel(person[log].channel);
  if person[log].here then unplot_player(log);
  if unwho then unwho_prime(log,echo);
  if window_name = 'Who list' then remove_x(name[na_player].id[log]);
  indx[i_ingame].on[log] := false;
  person[log].here := false;
end;

[asynchronous]
function empty_room:boolean;
var
  i:integer;
begin
  empty_room := true;
  for i := 1 to maxplayers do
  if person[i].here and (not indx[i_npc].on[i]) then empty_room := false;
end;

[global,asynchronous]
function ping(lognum:integer):boolean;
{Returns value of pong}
var
  dummy,ok:boolean;
begin
  writev(qpqp,'Ping ',lognum);
  bug_out(qpqp);
  ping := false;
  if human then ok := (lognum <> plr[now].log)
  else ok := (not indx[i_npc].on[lognum]) and
  (an_int[n_location].int[lognum] = here.valid);
  if ok then
  begin
    dummy := person[lognum].here;
    person[lognum].here := false;
    act_out(0,e_ping,lognum,mychannel);
    wait(3);
    if not person[lognum].here then
    begin
      remove_player(lognum,true,human);
      if (not human) then
      if empty_room then all_done := true;
    end
    else
    begin
      ping := true;
      wl(name[na_player].id[lognum]+' has ponged.');
      person[lognum].here := dummy;
    end;
  end;
  bug_out('End ping!');
end;

[asynchronous]
function do_mask(b1:boolean := true; m1:integer := 0;
		 b2:boolean := true; m2:integer := 0;
		 b3:boolean := true; m3:integer := 0;
		 b4:boolean := true; m4:integer := 0):integer;
var
  mask_sum:integer := 0;
begin
  if b1 then mask_sum := mask_sum + m1;
  if b2 then mask_sum := mask_sum + m2;
  if b3 then mask_sum := mask_sum + m3;
  if b4 then mask_sum := mask_sum + m4;
  do_mask := mask_sum;
end;

procedure assign_channels;
{Assigns channels to all the non-npc people in the game}
var
  i,mylog:integer;
  npc_done:boolean := false;
begin
  if now = 0 then mylog := 0
  else mylog := plr[now].log;
  for i := 1 to maxplayers do
  if (indx[i_ingame].on[i]) and (i <> mylog) and (not indx[i_npc].on[i]) then
  begin
    getplayer(i);
    freeplayer;
    if human then
    begin
      if assign_channel(player.mbx,person[i].channel) then
	act_out(plr[now].log,e_assign,,,
	do_mask(first_time,m_first_in),,,,mymbx,
	name[na_player].id[plr[now].log],,person[i].channel)
	else ping(i);
    end
    else
    if (an_int[n_location].int[i] = here.valid) then
    begin
      if assign_channel(player.mbx,person[i].channel) then
      act_out(,e_assign,,,,here.valid,,,mymbx,,,person[i].channel)
      else ping(i);
    end;
  end;
end;

procedure deassign_channels;
var
  i:integer;
begin
  getindex(i_ingame);
  freeindex;
  for i := 1 to maxplayers do
  if (indx[i_ingame].on[i]) then deassign_channel(person[i].channel);
end;

procedure addrooms(n:integer);
var
  i:integer;
begin
  getindex(i_room);
  for i := indx[i_room].top + 1 to indx[i_room].top + n do
  begin
    locate(roomfile,i);
    roomfile^.valid := i;
    put(roomfile);
    locate(fgfile,i);
    fgfile^.valid := i;
    put(fgfile);
  end;
  indx[i_room].top := indx[i_room].top + n;
  putindex(i_room);
end;

procedure addobjects(n:integer);
var
  i:integer;
begin
  getindex(i_object);
  for i := indx[i_object].top + 1 to indx[i_object].top + n do
  begin
    locate(objfile,i);
    objfile^.valid := i;
    put(objfile);
  end;
  indx[i_object].top := indx[i_object].top + n;
  putindex(i_object);
end;

procedure addspells(n:integer);
var
  i:integer;
begin
  getindex(i_spell);
  for i := indx[i_spell].top + 1 to indx[i_spell].top + n do
  begin
    locate(spellfile,i);
    spellfile^.valid := i;
    put(spellfile);
  end;
  indx[i_spell].top := indx[i_spell].top + n;
  putindex(i_spell);
end;

procedure addraces(n:integer);
var
  i:integer;
begin
  getindex(i_race);
  for i := indx[i_race].top + 1 to indx[i_race].top + n do
  begin
    locate(racefile,i);
    racefile^.valid := i;
    put(racefile);
  end;
  indx[i_race].top := indx[i_race].top + n;
  putindex(i_race);
end;

procedure addplayers(n:integer; npc:boolean := false);
var
  i,j:integer;
begin
  getindex(i_player);
  getindex(i_npc);
  getindex(i_ingame);
  for i := indx[i_player].top + 1 to indx[i_player].top + n do
  begin
    indx[i_ingame].on[i] := false;
    indx[i_player].on[i] := npc;
    indx[i_npc].on[i] := npc;
    locate(playerfile,i);
    with playerfile^ do
    begin
      valid := i;
      for j := 1 to maxspell do spell[j] := false;
      for j := 1 to at_max do
      begin
	attrib[j] := 0;
        attrib_max[j] := 0;
      end;
      attrib_ex[st_class] := 1;
      attrib_ex[st_race] := 1;
      attrib_ex[st_kills] := 1;
      attrib_ex[st_killed] := 1;
      where.x := 1;
      where.y := 1;
      where.r := 1;
    end;
    put(playerfile);
  end;
  indx[i_npc].top := indx[i_npc].top + n;
  indx[i_ingame].top := indx[i_ingame].top + n;
  indx[i_player].top := indx[i_player].top + n;
  putindex(i_npc);
  putindex(i_ingame);
  putindex(i_player);
end;

function allocate(indexnum:integer; var n:integer):boolean;
var
  found:boolean;
begin
  perf('allocate');
  getindex(indexnum);
  if indx[indexnum].inuse = indx[indexnum].top then
  begin
    freeindex;
    n := 0;
    allocate := false;
    wl('There is no more space available.');
  end
  else
  begin
    n := 1;
    found := false;
    while (not found) and (n <= indx[indexnum].top) do
    begin
      if (not indx[indexnum].on[n]) then found := true
      else n := n + 1;
    end;
    if found then
    begin
      indx[indexnum].on[n] := true;
      allocate := true;
      indx[indexnum].inuse := indx[indexnum].inuse + 1;
      putindex(indexnum);
    end
    else
    begin
      freeindex;
      wl('Allocation error.');
      allocate := false;
    end;
  end;
  getindex(indexnum);
  freeindex;
end;

procedure deallocate(indexnum:integer; n:integer);
begin
  getindex(indexnum);
  indx[indexnum].inuse := indx[indexnum].inuse - 1;
  indx[indexnum].on[n] := false;
  putindex(indexnum);
end;

procedure delete_player(log:integer);
begin
  deallocate(i_player,log);
  getname(na_player);
  name[na_player].id[log] := 'Deleted';
  putname(na_player);
  getname(na_user);
  name[na_user].id[log] := '';
  putname(na_user);
  wl('Player removed.');
end;

procedure remove_old_player;
var
  i,lowest,lowlog:integer := 0;
begin
  for i := 1 to indx[i_player].top do
  begin
    getplayer(i);
    freeplayer;
    if (player.last_play < lowest) and (not indx[i_npc].on[i]) then
    begin
      lowest := player.last_play;
      lowlog := i;
    end;
  end;
  delete_player(lowlog);
end;

procedure openfiles;
var
  fname:string;
  i:integer;
begin
  if not human and debug then
  begin
    writev(fname,'debug_',here.valid:0,'.sr');
    open(outfile,temp_root+fname,access_method := sequential,
	sharing := readwrite,history := unknown);
    add_acl(fname,'(identifier=[mas,'+srop+'],access=read+write+execute+delete)');
  end;
  open(fgfile,root+'fg.sr',access_method := direct,
	sharing := readwrite,history := unknown);
  open(indexfile,root+'index.sr',access_method := direct,
	sharing := readwrite,history := unknown);
  open(roomfile,root+'room.sr',access_method := direct,
	sharing := readwrite,history := unknown);
  open(namefile,root+'name.sr',access_method := direct,
	sharing := readwrite,history := unknown);
  open(spellfile,root+'spell.sr',access_method := direct,
	sharing := readwrite,history := unknown);
  open(intfile,root+'integer.sr',access_method := direct,
	sharing := readwrite,history := unknown);
  open(objfile,root+'object.sr',access_method := direct,
	sharing := readwrite,history := unknown);
  open(playerfile,root+'player.sr',access_method := direct,
	sharing := readwrite,history := unknown);
  open(racefile,root+'race.sr',access_method := direct,
	sharing := readwrite,history := unknown);
end;

end.
