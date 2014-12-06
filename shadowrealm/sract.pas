[inherit ('srinit','srsys','srother','srmove','srmisc','srio'),
 environment('sract')]

module sract;

[asynchronous]
procedure remember(sendlog,x,y,base,head,mask:integer);
begin
  person[sendlog].alive := unmask(mask,m_alive);
  person[sendlog].here := true;
  person[sendlog].loc.x := x;
  person[sendlog].loc.y := y;
  person[sendlog].feet := base;
  person[sendlog].head := head;
end;

[asynchronous]
procedure plot_player(theirlog,x,y,p1,p2:integer);
begin
  people_map[x,y] := theirlog;
  fix_scenery(x,y);
  person[theirlog].loc.x := x;
  person[theirlog].loc.y := y;
  person[theirlog].feet := p1;
  person[theirlog].head := p2;
end;

[asynchronous,global]
procedure unplot_player(theirlog:integer);
begin
  with person[theirlog].loc do
  begin
    people_map[x,y] := 0;
    fix_scenery(x,y);
  end;
end;

[asynchronous]
procedure bump_me(s:string);
begin
  wl(s+' bumps into you.');
  do_go(1+rnd mod 9);
end;

[asynchronous]
function soundfrom(x,y:integer):string;
var
  slope:real;
begin
  slope := (y-pl[now].where.y)/(0.1+x-pl[now].where.x);
  if y-pl[now].where.y < 0 then
  begin
    if abs(slope) > 1 then soundfrom := dir[d_north]
    else if x-pl[now].where.x > 0 then soundfrom := dir[d_east]
    else soundfrom := dir[d_west];
  end
  else
  begin
    if abs(slope) > 1 then soundfrom := dir[d_south]
    else if x-pl[now].where.x > 0 then soundfrom := dir[d_east]
    else soundfrom := dir[d_west];
  end;
end;

[global,asynchronous]
procedure handle_act;
var
  moron,n,i,j,mask,sendlog,theact,x,y,p1,p2,p3,p4:integer;
  a_loc:loc;
  sendname:shortstring;
  s,ss:$udata;
begin
  with act do
  begin
    sendlog := sender;
    theact := action;
    s := msg;
    ss:= note;
    x := xloc;
    y := yloc;
    p1 := parm1;
    p2 := parm2;
    p3 := parm3;
    p4 := parm4;
  end;

  if sendlog <> 0 then sendname := name[na_player].id[sendlog]
  else sendname := 'Unknown';

  case theact of

e_ack:if sendlog = 0 then person[plr[now].log].here := true;

e_attack:
begin
  decompress(p2,i,j,moron);
  if (p1 = plr[now].log) and not pl[now].sts[ps_dead].on and in_range(x,y,p4) then
	get_attack(sendlog,x,y,i,j,p3,s)
  else if (p1 = plr[now].log) and not pl[now].sts[ps_dead].on then
	act_out(plr[now].log,e_msg,pl[now].where.x,pl[now].where.y,0,
	sendlog,,,name[na_player].id[plr[now].log]+' out of range.')
  else if (p1 = plr[now].log) then
	act_out(plr[now].log,e_msg,pl[now].where.x,pl[now].where.y,0,
	sendlog,,,name[na_player].id[plr[now].log]+' is already dead.');
end;

e_assign:{x,y,first in,to room}
begin
  if unmask(p1,m_first_in) then readnames;
  if (sendlog = 0) and (p2 = pl[now].where.r) then
  begin {assign to room}
{Once the room's process is here, we can start sending to it.  If done
earlier, we'll send to ourselves and get all confused.  We can assume the
room process is in this room, otherwise it wouldn't send to us}
    assign_channel(s,person[plr[now].log].channel);
    person[plr[now].log].here := true;
    act_out(plr[now].log,e_booga,pl[now].where.x,pl[now].where.y,
	pl[now].attrib_ex[st_base],pl[now].attrib[at_size],,
	do_mask(not pl[now].sts[ps_dead].on,m_alive,human,m_human),
	name[na_player].id[plr[now].log],,,person[plr[now].log].channel);
  end
  else if sendlog <> 0 then
  begin
    person[sendlog].here := false;
{A person is considered here upon getting ]e_walkin.  The room's process is
 considered here upon e_assign}
    indx[i_ingame].on[sendlog] := true;
    wl(name[na_player].id[sendlog]+' now roams the land.');
    if window_name = 'Who list' then add_x(name[na_player].id[sendlog]);
    assign_channel(s,person[sendlog].channel);
  end;
end;

e_booga:{x,y,feet,head,0,mask}
begin
  remember(sendlog,x,y,p1,p2,p4);
  if not unmask(p4,m_invisible) then
  begin
    plot_special(x,y);
    plot_player(sendlog,x,y,p1,p2);
  end;
end;

e_bump:
if (x = pl[now].where.x) and (y = pl[now].where.y) and not pl[now].sts[ps_dead].on
then get_bump(sendlog,p1,p2,sendname,s);

e_can_spawn:if not spawned_out then
	act_out(plr[now].log,e_can_spawn_ack,,,,,,,,,,person[sendlog].channel);

e_can_spawn_ack:if other_lognum = 0 then other_lognum := sendlog;

e_challenge:
wl('I '+sendname+' do hereby challenge '+name[na_player].id[p1]+'!');

e_deassign:remove_player(sendlog);

e_refuse:
wl('I, '+sendname+', am currently engaged in battle!');

e_reborn:
begin
  person[sendlog].alive := true;
  if in_range(x,y,p1) then wl(name[na_player].id[sendlog]+' has been reborn.');
  fix_scenery(x,y);
end;

e_died:{killerlog,theirexp,p1=theirpoints,p2=kills,p3=killed}
begin
  person[sendlog].alive := false;
  if x <> plr[now].log then wl(sendname+' has been slain by '+name[na_player].id[x]+'!')
  else
  begin
    wl('You have slain '+sendname+'!');
    if y > 10 then n := trunc((ln(y) + p1)*p2/p3)
    else n := trunc(p1*p2/p3);
    change_stat_ex(st_experience,pl[now].attrib_ex[st_experience]+n);
    if not indx[i_npc].on[sendlog] then
    change_stat_ex(st_kills,pl[now].attrib_ex[st_kills] + 1);
    change_stat(at_points,pl[now].attrib_max[at_points] + n,true);
    change_stat(at_points,pl[now].attrib[at_points] + n);
    save_player;
  end;
end;

e_disappear:
if person[sendlog].here then
begin
  plot_special(person[sendlog].loc.x,person[sendlog].loc.y);
  unplot_player(sendlog);
  if on_screen(person[sendlog].loc.x,person[sendlog].loc.y) then
  wl(sendname+' has disappeared!');
end;

e_drop:
begin
  fg.object[p2].object.num := p1;
  fg.object[p2].loc.x := x;
  fg.object[p2].loc.y := y;
  map_objects(p1);
  if in_range(x,y,p3) then
  wl(sendname+' drop a '+s+' to the ground.')
  else if in_range(x,y,p3*2) then
  wl('You hear a thud in the distance.');
  fix_scenery(x,y);
end;

e_get:
begin
  forget_foreground_object(p1);
  if in_range(x,y,20) then
  wl(sendname+' picks up '+s);
  fix_scenery(x,y);
end;

e_halt:
if p1 = plr[now].log then
begin
  wl(sendname+' directs a bolt of black light at you!');
  halt;
end;

e_kill:if x = plr[now].log then do_die(sendlog);

e_listen:
act_out(plr[now].log,e_noise,pl[now].where.x,pl[now].where.y,
pl[now].attrib[at_noise],sendlog,,,plr[now].sound);

e_noise:
if p2 = plr[now].log then
if in_range(x,y,p1+pl[now].attrib[at_perception]) then
wl(soundfrom(x,y)+': '+s);

e_move:{x,y,base,size,p3,mask}
if person[sendlog].here then
begin
  unplot_player(sendlog);
  plot_player(sendlog,x,y,p1,p2);
  if (x = pl[now].where.x) and (y = pl[now].where.y) and not pl[now].sts[ps_dead].on then
  bump_me(sendname);
end;

e_msg:
if (p2 = 0) or (p2 = plr[now].log) then
begin
  if (p1 = 0) then wl(s)
  else if in_range(x,y,p1) then wl(s);
end;

e_open:toggle_door(x,y,p1);

e_ping:if (x = plr[now].log) or (x = 0) then
	act_out(plr[now].log,e_pong,,,,,,,,,,y);

e_place:
begin
  with fg.object[p1] do
  begin
    loc.x := x;
    loc.y := y;
    object.num := p2;
    icon := s[1];
    decompress(p3,base,altitude,moron);
    decompress(p4,object.condition,rendition,moron);
  end;
  map_objects(p1);
  fix_scenery(x,y);
  if (pl[now].where.x = x) and (pl[now].where.y = y) then wl('Ouch!');
end;

{e_process:if p1 = plr[now].log then setup_room_process;}

e_status:if p1 = plr[now].log then
begin
  writev(s,sendname,':',stat[p2],' ',p3:0,' of ',p4:0,'.');
  wl(s);
end;

e_req_status:if p1 = plr[now].log then
act_out(plr[now].log,e_status,,,sendlog,p2,pl[now].attrib[p2],
pl[now].attrib_max[p2]);

e_remotepoof:
if (p1 = pl[now].where.r) then
begin
  if person[p2].here then
  begin
    g_plot(g_circle,person[p2].loc.x,person[p2].loc.y,0,3,0,20,' ',bold+reverse);
    g_plot(g_circle,person[p2].loc.x,person[p2].loc.y,0,3,0,20,chr(0));
  end;

  if p2 = plr[now].log then
  if checkprivs(4) then
  begin
    writev(s,'You have been requested by ',name[na_player].id[sendlog],
    ' at the ',name[na_room].id[p1],' ',x:0,',',y:0,'.');
    wl(s);
    plr[now].dest.mission := p1;
    plr[now].dest.x := x;
    plr[now].dest.y := y;
  end
  else
  begin
    a_loc.x := x;
    a_loc.y := y;
    a_loc.r := p1;
    poof_prime(a_loc);
  end;
end;

e_pong:person[sendlog].here := true;

e_quit:halt;

e_spawn:setup_room_process(p1);

e_spell:
if person[sendlog].here then handle_spell(act);

e_walkin:{x,y,base,size,room,mask}
begin
  if pl[now].where.r = p3 then
  begin
    name[na_player].id[sendlog] := s;
    remember(sendlog,x,y,p1,p2,p4);
    indx[i_ingame].on[sendlog] := true;
    if not unmask(p4,m_invisible) then
    begin
      plot_special(x,y);
      plot_player(sendlog,x,y,p1,p2);
    end;
    if not indx[i_npc].on[sendlog] then
    act_out(plr[now].log,e_booga,pl[now].where.x,pl[now].where.y,
	pl[now].attrib_ex[st_base],pl[now].attrib[at_size],,
	do_mask(not pl[now].sts[ps_dead].on,m_alive,human,m_human,
	pl[now].sts[ps_invisible].on,m_invisible),
	name[na_player].id[plr[now].log],,,person[sendlog].channel);
  end;
end;

e_turn_on:turn_on_fg(x,false);
e_turn_off:turn_off_fg(x,false);
e_toggle:toggle_fg(x,false);

e_walkout:
if person[sendlog].here then
begin
  if s <> '' then
  wl(name[na_player].id[sendlog]+' has entered '+s+'.');
  plot_special(person[sendlog].loc.x,person[sendlog].loc.y);
  unplot_player(sendlog);
  person[sendlog].here := false;
end;

e_throw:
begin
  g_plot(g_blip,person[sendlog].loc.x,person[sendlog].loc.y,x,y,0,10,s[1],p1);
  fix_scenery(x,y);
  if (pl[now].where.x = x) and (pl[now].where.y = y) then wl('Ouch!');
end;

    otherwise wl('Someone logged a bad act.');
  end;
end;

end.
