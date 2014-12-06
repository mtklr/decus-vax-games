[inherit ('srinit','srsys','srother','srmove','srmisc','srcom',
 'sys$library:starlet'),environment('srtime')]

module srtime;

var
  is_college:boolean := false;
  is_hiding:boolean := false;
  is_object:boolean := false;

[asynchronous]
procedure handle_event(eventnum:integer);
var
  moron,x,y,geometry,geo1,geo2,p1,p2,p3,p4:integer;
  sp_effect,sp_element,duration,rendition:integer;
begin
  with event[eventnum] do
  case action of

e_spell:
begin
  decompress(parm4,duration,rendition,moron);
  decompress(xloc,x,y,moron);
  decompress(yloc,geometry,geo1,geo2);
  decompress(parm1,sp_effect,sp_element,moron);
  decompress(parm2,p1,p2,moron);
  decompress(parm3,p3,p4,moron);
  map_foreground(parm4,geometry,x,y,geo1,geo2,false);
  g_plot(geometry,x,y,geo1,geo2,0,10,chr(0));
  fg.effect[parm4].kind := 0;
  fg.effect[parm4].on := false;
  fg.name[parm4] := '';
end;

  end;
  event[eventnum].action := 0;
end;


procedure check_room;
var
  x,y:integer;
begin
  is_hiding := foreground_location(fg_normal,x,y);
  is_college := foreground_location(fg_college,x,y);
  is_object := object_location(x,y,true);
end;

procedure allacts(check:boolean := true);
var
  i,int_result,old_now,player_top:integer;

  procedure restore_stat;
  var
    addition,restore_time:integer;
  begin
    case i of
  at_points	:restore_time := 0;
  at_health	:if not pl[now].sts[ps_poisoned].on then
	         restore_time := pl[now].attrib[at_heal_speed]
		 else restore_time := pl[now].attrib[at_heal_speed] * 10;
  at_mana	:restore_time := pl[now].attrib[at_mana_speed];
  at_wealth	:restore_time := 0;
  at_mv_delay	:restore_time := 2*60;
  at_size	:restore_time := 2*60;
  at_heal_speed	:restore_time := 2*60;
  at_mana_speed	:restore_time := 2*60;
  at_noise	:restore_time := 2*60;
  at_perception	:restore_time := 2*60;
    end;
    if restore_time > 0 then
    begin
      addition := min(
      abs(round((pl[now].attrib_max[i] * slow)/restore_time)),
      abs(pl[now].attrib_max[i] - pl[now].attrib[i]));
      if pl[now].attrib[i] > pl[now].attrib_max[i] then addition := -addition;
      if addition <> 0 then change_stat(i,pl[now].attrib[i] + addition);
    end;
  end;

begin
  if human then player_top := 1
  else player_top := monsters_active;
  old_now := now;
  if getticks >= tickerquick then
  begin
    for now := 1 to player_top do
    if check and not pl[now].sts[ps_dead].on then check_location(false);
    for i := 1 to event_max do
    if event[i].action <> 0 then
    if getticks > event_time[i] then handle_event(i);
    tickerquick := getticks + round(0.5 * 10); {half second}
  end;

  if getticks >= tickerslow then
  begin

    if not human then check_room;

    for now := 1 to player_top do
    if not pl[now].sts[ps_dead].on then
    for i := 1 to at_max do restore_stat;

    for now := 1 to player_top do
    for i := 1 to ps_max do
    if pl[now].sts[i].on then
    if (pl[now].sts[i].time < getticks) then
    begin
      pl[now].sts[i].on := false;
      case i of
ps_poisoned:wl('You feel much better now.');
ps_invisible:wl('You fade back into view.');
ps_dead:if human then
        begin
	  wl('The '+name[na_race].id[pl[now].attrib_ex[st_race]]+
	  ' God has granted you a new body!');
	  do_rebirth(true);
	end;
      end;
    end;

    sysstatus := $setpri(,,4);
    tickerslow := getticks + 5 * 10; {five seconds}
  end;

  now := old_now;
end;

end.
