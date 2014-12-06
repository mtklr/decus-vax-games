[inherit ('srinit','srsys','srother','srmove','srmisc','srio'),
 environment('srgodact')]

module srgodact;

const
  path_unknown	= 0;
  path_right	= 1;
  path_left	= 2;
type
  mazerec = record;
    path:integer;
    steps:integer;
    direction:integer;
  end;
var
  maze:array[1..maxmonsters] of mazerec;
  pathname:array[0..2] of shortstring := ('unknown','right','left');
  asynch_possess:[volatile] boolean := false;

[hidden,external,asynchronous]
procedure possess_someone(log:integer := 0);
external;

[hidden,external,asynchronous]
procedure forget_mission(x,y:integer);
external;

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

procedure follow(x,y:integer);

  function choose(a,b:integer):integer;
  begin
    case rnum(2) of
    1:choose := a;
    2:choose := b;
    end;
  end;

  procedure try(a,b,c,d,e,f,g:integer := 0);
  var
    dd:array[1..7] of integer;
    max_try,tempx,tempy:integer;
    i:integer := 1;
    moved:boolean := false;
  begin
    dd[1] := a;
    if d = 0 then
    begin
      dd[2] := choose(b,c);
      if dd[2] = b then dd[3] := c
      else dd[3] := b;
      max_try := 3;
    end
    else
    begin
      dd[2] := b;
      dd[3] := c;
      dd[4] := d;
      dd[5] := e;
      dd[6] := f;
      dd[7] := g;
      max_try := 7;
    end;
    while (i <= max_try) and not moved do
    begin
      new_coords(pl[now].where.x,pl[now].where.y,tempx,tempy,dd[i]);
      if can_move(tempx,tempy,dd[i],false) then
      begin
        moved := true;
        do_go(dd[i]);
	if maze[now].path <> 0 then
	begin
	  maze[now].direction := dd[i];
	  maze[now].steps := maze[now].steps - 1;
	  if maze[now].steps = 0 then maze[now].path := path_unknown;
	end;
      end;
      i := i + 1;
    end;
    if not moved and (maze[now].path <> 0) then
    begin
      if maze[now].path = path_right then maze[now].path := path_left
      else maze[now].path := path_right;
    end
    else if not moved then
    begin
      maze[now].path := rnum(2);	{right/left}
      case maze[now].path of
path_right:
	case dd[1] of
	1:maze[now].direction := 3;
	2:maze[now].direction := 6;
	3:maze[now].direction := 9;
	4:maze[now].direction := 2;
	6:maze[now].direction := 8;
	7:maze[now].direction := 1;
	8:maze[now].direction := 4;
	9:maze[now].direction := 7;
	end;
path_left:
	case dd[1] of
	1:maze[now].direction := 7;
	2:maze[now].direction := 4;
	3:maze[now].direction := 1;
	4:maze[now].direction := 8;
	6:maze[now].direction := 2;
	7:maze[now].direction := 9;
	8:maze[now].direction := 6;
	9:maze[now].direction := 3;
	end;
      end;
      if rnum(4) = 1 then maze[now].steps := bell(40,2)
      else maze[now].steps := rnum(4);
    end;
  end;

begin
  if maze[now].path = path_unknown then
  begin
    if (x < pl[now].where.x) then
    begin
      if (y < pl[now].where.y) then try(7,8,4)
      else if (y > pl[now].where.y) then try(1,2,4)
      else try(4,1,7);
    end
    else if (x > pl[now].where.x) then
    begin
      if (y < pl[now].where.y) then try(9,6,8)
      else if (y > pl[now].where.y) then try(3,2,6)
      else try(6,3,9);
    end
    else if y < pl[now].where.y then try(8,7,9)
    else if y > pl[now].where.y then try(2,1,3);
  end
  else
  case maze[now].path of
path_right:
    case maze[now].direction of
	1:try(7,4,1,2,3,6,9);
	2:try(4,1,2,3,6,9,8);
	3:try(1,2,3,6,9,8,7);
	4:try(8,7,4,1,2,3,6);
	6:try(2,3,6,9,8,7,4);
	7:try(9,8,7,4,1,2,3);
	8:try(6,9,8,7,4,1,2);
	9:try(3,6,9,8,7,4,1);
    end;
path_left:
    case maze[now].direction of
	1:try(3,2,1,4,7,8,7);
	2:try(6,3,2,1,4,7,8);
	3:try(9,6,3,2,1,4,7);
	4:try(2,1,4,7,8,9,6);
	6:try(8,9,6,3,2,1,4);
	7:try(1,4,7,8,9,6,3);
	8:try(4,7,8,9,6,3,2);
	9:try(7,8,9,6,3,2,1);
    end;
  end;
end;

[asynchronous]
procedure plot_player(theirlog,x,y,p1,p2:integer);
begin
  people_map[x,y] := theirlog;
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
  i,j,loop,moron,n,old_now,sendlog,theact,x,y,p1,p2,p3,p4:integer;
  a_loc:loc;
  sendname:shortstring;
  s,ss:$udata;
  dummy_channel:$uword;

  procedure remember_coords;
  begin
    person[sendlog].loc.x := x;
    person[sendlog].loc.y := y;
  end;

procedure handle_prime(room_process:boolean := false);
begin
  now := loop;
  case theact of

e_attack:{x,y,target,compress(damage,randomness),element,radius}
if not room_process then
if p1 = plr[now].log then
begin
  decompress(p2,i,j,moron);
  if not pl[now].sts[ps_dead].on then
  if in_range(x,y,p4) then
  begin
    remember_attack(sendlog,bell(i,j));
    get_attack(sendlog,x,y,i,j,p3,s)
  end
  else if not pl[now].sts[ps_dead].on then act_out(plr[now].log,e_msg,pl[now].where.x,
	pl[now].where.y,0,sendlog,,,name[na_player].id[plr[now].log]+
	' dances outside your range.')
  else act_out(plr[now].log,e_msg,pl[now].where.x,pl[now].where.y,0,sendlog
	,,,name[na_player].id[plr[now].log]+' says, "I''m already dead!"');
end;

e_activate:
if room_process then
begin
  act_out(0,e_msg,,,,,,,'No no no.');
end;

e_assign:
if room_process then
begin
  if unmask(p1,m_first_in) then readnames;
  begin
    indx[i_ingame].on[sendlog] := true;
    assign_channel(s,person[sendlog].channel);
    person[sendlog].here := true;
    act_out(0,e_ack,,,,,,,,,,sendlog);
  end;
end;

e_booga:
if room_process then
remember(sendlog,x,y,p1,p2,p4);

e_bump:
if not room_process then
if (x = pl[now].where.x) and (y = pl[now].where.y) and not pl[now].sts[ps_dead].on
then get_bump(sendlog,p1,p2,sendname,s);

e_challenge:
if p1 = plr[now].log then
begin
  if find_enemy(moron) then act_out(plr[now].log,e_refuse,,,sendlog)
  else remember_attack(sendlog,1);
end;

e_refuse:
if p1 = plr[now].log then forget_attack(p1);

e_deassign:
if room_process then
begin
  deassign_channel(person[sendlog].channel);
  indx[i_ingame].on[sendlog] := false;
  person[sendlog].here := false;
end;

e_reborn:
if room_process then person[sendlog].alive := true;

e_died:
if not room_process then
begin
  person[sendlog].alive := false;
  forget_attack(sendlog);
  if x = plr[now].log then
  begin
    act_out(plr[now].log,e_msg,,,,,,,name[na_player].id[plr[now].log]+
	' says, "Ha ha, '+ss+'"');
    if y > 0 then n := trunc((ln(y) + p1)*p2/p3)
    else n := trunc(p1*p2/p3);
    change_stat_ex(st_experience,pl[now].attrib_ex[st_experience] + n);
    change_stat_ex(st_kills,pl[now].attrib_ex[st_kills] + 1);
    change_stat(at_points,pl[now].attrib[at_points] + n);
    save_player;
  end;
end;

e_drop:
if room_process then
begin
  fg.object[p2].object.num := p1;
  fg.object[p2].loc.x := x;
  fg.object[p2].loc.y := y;
end;

e_get:
if room_process then
begin
  forget_foreground_object(p1);
  forget_mission(x,y);
end;

e_halt:
if room_process then halt;

e_kill:if x = plr[now].log then do_die(sendlog);

e_listen:
act_out(plr[now].log,e_noise,pl[now].where.x,pl[now].where.y,
pl[now].attrib[at_noise],sendlog,,,plr[now].sound);

e_move:
if not room_process then
begin
  if person[sendlog].here then
  begin
    unplot_player(sendlog);
    plot_player(sendlog,x,y,p1,p2);
    remember_coords;
    if (x = pl[now].where.x) and (y = pl[now].where.y) and not pl[now].sts[ps_dead].on then bump_me(sendname);
  end;
end;

e_msg:;

e_open:
if room_process then toggle_door(x,y,p1);

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
end;

e_status:if p1 = plr[now].log then
begin
  writev(s,sendname,':',stat[p2],' ',p3:0,' of ',p4:0,'.');
  wl(s);
end;

e_req_status:if p1 = plr[now].log then
act_out(plr[now].log,e_status,,,sendlog,p2,pl[now].attrib[p2],
pl[now].attrib_max[p2]);

e_remotepoof:
if p2 = plr[now].log then
begin
  a_loc.x := x;
  a_loc.y := y;
  a_loc.r := p1;
  poof_prime(a_loc);
end;

e_pong:
if room_process then person[sendlog].here := true;

e_possess:
if room_process and (monsters_active <= maxmonsters) then possess_someone(x)
else
begin
  if assign_channel(s,dummy_channel) then
  act_out(0,e_possess_not,x,,,,,,,,,dummy_channel);
end;

e_possess_not:
if room_process and (monsters_active <= maxmonsters) then possess_someone(x);

e_spell:
if not room_process then handle_spell(act);

e_walkin:
if not room_process then
begin
  if pl[now].where.r = p3 then
  begin
    remember(sendlog,x,y,p1,p2,p4);
    act_out(plr[now].log,e_booga,
	pl[now].where.x,
	pl[now].where.y,
	pl[now].attrib_ex[st_base],
	pl[now].attrib[at_size],,
	do_mask(not pl[now].sts[ps_dead].on,m_alive,human,m_human),
	name[na_player].id[plr[now].log],,,sendlog);
  end;
end;

e_turn_on:
if room_process then
turn_on_fg(x,false);

e_turn_off:
if room_process then
turn_off_fg(x,false);

e_toggle:
if room_process then
toggle_fg(x,false);

e_walkout:
if room_process then
begin
  with person[sendlog] do
  writev(qpqp,sendlog:0,' X ',loc.x:0,' Y ',loc.y:0,' Here ',
	boo(person[sendlog].here),'e_walkout!');
  bug_out(qpqp);
  remove_player(sendlog,,false);
  if empty_room then all_done := true;
end;

e_throw:
if not room_process then
if (pl[now].where.x = x) and (pl[now].where.y = y) then wl('Ouch!');

    otherwise wl('Someone logged a bad act.');
  end;
end;

begin
  old_now := now;
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
  for loop := 1 to maxmonsters do
  if (not pl[loop].sts[ps_dead].on) and (sendlog <> plr[loop].log) then
  handle_prime;
  handle_prime(true);
  now := old_now;
end;

end.
