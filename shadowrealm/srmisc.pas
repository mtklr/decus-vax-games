[inherit ('srinit','srsys','srother'),environment('srmisc')]

module srmisc;

[ASYNCHRONOUS] FUNCTION smg$put_chars (
	display_id : UNSIGNED;
	text : [CLASS_S] PACKED ARRAY [$l2..$u2:INTEGER] OF CHAR;
	start_row : INTEGER := %IMMED 0;
	start_column : INTEGER := %IMMED 0;
	flags : UNSIGNED := %IMMED 0;
	rendition_set : UNSIGNED := %IMMED 0;
	rendition_complement : UNSIGNED := %IMMED 0;
	character_set : UNSIGNED := %IMMED 0) : INTEGER; EXTERNAL;

[ASYNCHRONOUS] FUNCTION smg$begin_display_update (
	display_id : UNSIGNED) : INTEGER; EXTERNAL;

[ASYNCHRONOUS] FUNCTION smg$end_display_update (
	display_id : UNSIGNED) : INTEGER; EXTERNAL;

[ASYNCHRONOUS] FUNCTION smg$change_viewport (
	display_id : UNSIGNED;
	viewport_row_start : INTEGER := %IMMED 0;
	viewport_column_start : INTEGER := %IMMED 0;
	viewport_number_rows : INTEGER := %IMMED 0;
	viewport_number_columns : INTEGER := %IMMED 0) : INTEGER; EXTERNAL;

[ASYNCHRONOUS] FUNCTION smg$label_border (
	display_id : UNSIGNED;
	text : [CLASS_S] PACKED ARRAY [$l2..$u2:INTEGER] OF CHAR := %IMMED 0;
	position_code : UNSIGNED := %IMMED 0;
	units : INTEGER := %IMMED 0;
	rendition_set : UNSIGNED := %IMMED 0;
	rendition_complement : UNSIGNED := %IMMED 0;
	character_set : UNSIGNED := %IMMED 0) : INTEGER; EXTERNAL;

[ASYNCHRONOUS] FUNCTION smg$repaste_virtual_display (
	display_id : UNSIGNED;
	pasteboard_id : UNSIGNED;
	pasteboard_row : INTEGER;
	pasteboard_column : INTEGER;
	top_display_id : UNSIGNED := %IMMED 0) : INTEGER; EXTERNAL;

[ASYNCHRONOUS] FUNCTION smg$end_pasteboard_update (
	pasteboard_id : UNSIGNED) : INTEGER; EXTERNAL;
 
[asynchronous]
function distance(x1,y1,x2,y2:real):integer;
begin
  distance := round( ((x2-x1)**2+(y2-y1)**2) **(1/2) );
end;

[asynchronous]
procedure plot_special(x,y:integer);
var
  i:integer;
begin
  for i := 1 to 4 do
  begin
    smg$put_chars(gwind,'-',y,x);
    smg$put_chars(gwind,'\',y,x);
    smg$put_chars(gwind,'|',y,x);
    smg$put_chars(gwind,'/',y,x);
  end;
    smg$put_chars(gwind,' ',y,x);
end;

[asynchronous]
function empty_foreground:integer;
var
  i:integer := 1;
  done:boolean := false;
begin
  while (i <= maxfg) and (not done) do
  if fg.name[i] = '' then done := true
  else i := i + 1;
  empty_foreground := i;
end;

[asynchronous]
function hit_me(geometry,geo1,geo2,x,y:integer):boolean;
var
  d:integer;
begin
  hit_me := false;
  case geometry of
g_circle:
    begin
      d := distance(pl[now].where.x,pl[now].where.y,x,y);
      if (d >= geo1) and (d <= geo2) then hit_me := true;
   end;
g_rectangle:
    if (pl[now].where.x >= x -geo1/2) and (pl[now].where.x <= x +geo1/2) and
       (pl[now].where.y >= y -geo2/2) and (pl[now].where.y <= y +geo2/2) then
	hit_me := true;
g_point:
    if (pl[now].where.x = x) and (pl[now].where.y = y) then hit_me := true;
g_line,g_blip:
    if (pl[now].where.x = x) and (pl[now].where.y = y) then hit_me := true;
  end;
end;

[asynchronous]
function on_screen(x,y:integer):boolean;
begin
  if (x < vpoffsetx) or (x > vpoffsetx + vpsizex) or
     (y < vpoffsety) or (y > vpoffsety + vpsizey) then on_screen := false
  else on_screen := true;
end;

[asynchronous]
function in_range(x,y,r:integer):boolean;
begin
  if distance(pl[now].where.x,pl[now].where.y,x,y) <= r then in_range := true
  else in_range := false;
end;

[asynchronous]
function overlap(a,b,c,d:integer):boolean;
{returns true if c-d somewhere in a-b}
begin
  if ((c >= a) and (c <= a+b)) or
     ((c+d >= a) and (c+d <= a+b)) then overlap := true
  else overlap := false;
end;

[asynchronous]
function highest_priority(x,y,max_priority:integer;
			var slot,map_type:integer):integer;
{returns foreground effect with highest visible base}
var
  i,highest:integer := -999;
begin
  slot := 0;
  map_type := map_background;

  for i := 1 to obj_layers do
  if obj_map[x,y,i] <> 0 then
  begin
    slot := obj_map[x,y,i];
    map_type := map_object;
    with fg.object[obj_map[x,y,i]] do
    highest := base + altitude;
  end;

  for i := 1 to fg_layers do
  if fg.map[x,y,i] <> 0 then
  with fg.effect[fg.map[x,y,i]] do
  if 	(kind <> 0) and (on) and
	(not ((icon = ' ') and (rendition = 0)) ) and
	((base >= highest) or (base + altitude >= highest)) and
	((base <= max_priority) or (base + altitude <= max_priority)) then
  begin
    slot := fg.map[x,y,i];
    map_type := map_fg;
    highest := base + altitude;
  end;

  if people_map[x,y] <> 0 then
  with person[people_map[x,y]] do
  if ((feet >= highest) or (head > highest)) and 
     ((feet <= max_priority) or (head <= max_priority)) then
  begin
    slot := people_map[x,y];
    map_type := map_player;
    highest := head;
  end;
  if highest = -999 then highest := 0;
  highest_priority := highest;
end;

[asynchronous]
procedure draw_me;
var
  dum,dum_dum:integer;
  rendition:unsigned;
begin
  if highest_priority(pl[now].where.x,pl[now].where.y,pl[now].attrib[at_size] + myview,dum,dum_dum) <=
  pl[now].attrib_ex[st_base] + pl[now].attrib[at_size] then rendition := reverse
  else rendition := bold;
  smg$put_chars(gwind,name[na_player].id[plr[now].log][1],
	pl[now].where.y,pl[now].where.x,,rendition);
end;

[asynchronous]
function bg_char(x,y:integer; var rendition:unsigned;
		max_priority:integer := -888;
		slot,map_type:integer := 0):char;
begin
  rendition := 0;
  if max_priority = -888 then max_priority := pl[now].attrib_ex[st_base];
  if slot = 0 then highest_priority(x,y,max_priority,slot,map_type);
  case map_type of
  map_object	:begin
		   bg_char := fg.object[slot].icon;
		   rendition := fg.object[slot].rendition;
		 end;
  map_player	:begin
		   bg_char := name[na_player].id[slot][1];
		   if person[slot].alive then rendition := reverse
		   else rendition := bold;
		 end;
  map_fg	:begin
		   bg_char := fg.effect[slot].icon;
		   rendition := fg.effect[slot].rendition;
		 end;
  map_background:bg_char := here.background[x,y];
  end;
end;

{Looks at the objects in a location, and puts the top one on the
 background.  Otherwise, it just plots the background.}
[asynchronous]
procedure fix_scenery(x,y,max_priority:integer := -888);
var
  thechar:char;
  rendition:unsigned;
begin
  if max_priority = -888 then max_priority := pl[now].attrib_ex[st_base] + myview;
  thechar := bg_char(x,y,rendition,max_priority);
  smg$put_chars(gwind,thechar,y,x,,rendition);
end;

[asynchronous]
procedure fix_room(max_priority:integer; short_range:boolean := false);
var
  i,j,x1,x2,y1,y2:integer;
begin
  if human then
  begin
    if short_range then
    begin
      x1 := vpoffsetx;
      x2 := vpoffsetx + vpsizex;
      y1 := vpoffsety;
      y2 := vpoffsety + vpsizey;
    end
    else
    begin
      x1 := 1;
      x2 := here.size.x;
      y1 := 1;
      y2 := here.size.y;
    end;
    smg$begin_display_update(gwind);
    for j := y1 to y2 do
    for i := x1 to x2 do
    fix_scenery(i,j,max_priority);
    draw_me;
    smg$end_display_update(gwind);
  end;
end;

[asynchronous]
procedure map_objects(f_num:integer := 0);
var
  f_start,f_end,fg_slot:integer;

  procedure plot_object;
  var
    n:integer := 1;
    done:boolean := false;
  begin
    with fg.object[fg_slot] do
    while (n <= obj_layers) and (not done) do
    if obj_map[loc.x,loc.y,n] = 0 then
    begin
      done := true;
      obj_map[loc.x,loc.y,n] := fg_slot;
    end
    else n := n + 1;
  end;

begin
  if f_num = 0 then
  begin
    f_start := 1;
    f_end := maxobjs;
  end
  else
  begin
    f_start := f_num;
    f_end := f_num;
  end;
  for fg_slot := f_start to f_end do
  if fg.object[fg_slot].object.num <> 0 then plot_object;
end;

[asynchronous]
function foreground_found(x,y,feet,head,looking_for:integer;
			var fg_slot:integer):boolean;
var
  i:integer;
begin
  foreground_found := false;
  fg_slot := 0;
  for i := 1 to fg_layers do
  if fg.map[x,y,i] > 0 then
  with fg.effect[fg.map[x,y,i]] do
  if (kind = looking_for) and overlap(base,altitude,feet,head) then
  begin
    foreground_found := true;
    fg_slot := fg.map[x,y,i];
  end;
end;

function object_location(var x,y:integer; closest:boolean := false):boolean;
var
  found:boolean := false;
  i:integer := 1;
  current:integer := 100;

  function find_object(slot:integer):boolean;
  var
    moron:integer;
  begin
    find_object := false;
    if fg.object[slot].object.num <> 0 then
    begin
      x := fg.object[slot].loc.x;
      y := fg.object[slot].loc.y;
      if not foreground_found(x,y,pl[now].attrib_ex[st_base],
      pl[now].attrib_ex[at_size],fg_shop,moron) then find_object := true;
    end;
  end;

begin
  if closest then
  begin
    for i := 1 to maxobjs do
    if fg.object[i].object.num <> 0 then
    if distance(fg.object[i].loc.x,fg.object[i].loc.y,
    pl[now].where.x,pl[now].where.y) < current then
    begin
      found := find_object(i);
      if found then current := distance(x,y,pl[now].where.x,pl[now].where.y);
    end;
  end;
  while (i < 1000) and (not found) do
  begin
    found := find_object(rnum(maxobjs));
    i := i + 1;
  end;
  if not found then
  begin
    i := 1;
    while (i < maxobjs) and (not found) do
    if not find_object(i) then i := i + 1;
  end;
  object_location := found;
end;

function foreground_location(fg_kind:integer; var x,y:integer):boolean;
var
  fg_slot,tries:integer := 1;
  found,done:boolean := false;
begin
  x := 1;
  y := 1;
  while (fg_slot < fg_max) and (not found) do
  if fg.effect[fg_slot].kind = fg_kind then found := true
  else fg_slot := fg_slot + 1;
  if found then
  while (tries < 5000) and (not done) do
  begin
    tries := tries + 1;
    x := rnum(here.size.x);
    y := rnum(here.size.y);
    if foreground_found(x,y,0,10,fg_kind,fg_slot) then done := true;
  end;
  if not done then
  begin
    y := 0;
    while (y < here.size.y) and not done do
    begin
      y := y + 1;
      x := 1;
      while (x < here.size.x) and not done do
      if foreground_found(x,y,0,10,fg_kind,fg_slot) then done := true
      else x := x + 1;
    end;
  end;
  foreground_location := done;
end;

[asynchronous]
procedure map_foreground(fg_slot:integer;
			 geometry,geo1,geo2,geo3,geo4:integer := 0;
			 add_fg:boolean := true);
var
  x,y,dist,sx,sy,ex,ey:integer;
  dx,dy:integer;
  bitmap:array[1..maxhoriz,1..maxvert] of boolean;

  procedure clear_bitmap;
  begin
    for x := 1 to maxhoriz do
    for y := 1 to maxvert do bitmap[x,y] := false;
  end;

  procedure plot_bitmap;
  var
    i,j,n:integer;
    done:boolean;

    function fg_exists:boolean;
    var
      int:integer;
    begin
      fg_exists := false;
      for int := 1 to fg_layers do
      if fg.map[i,j,int] = fg_slot then fg_exists := true;
    end;

  begin
    for j := 1 to maxvert do
    for i := 1 to maxhoriz do
    if bitmap[i,j] then
    begin
      n := 1;
      done := false;

      if (not add_fg) and fg_exists then
      for n := 1 to fg_layers do
      if fg.map[i,j,n] = fg_slot then fg.map[i,j,n] := 0;

      if add_fg and (not fg_exists) then
      while (n <= fg_layers) and (not done) do
      if fg.map[i,j,n] = 0 then
      begin
	done := true;
	fg.map[i,j,n] := fg_slot;
      end
      else n := n + 1;
    end;
  end;

begin
  if fg.effect[fg_slot].kind <> 0 then
  begin
    clear_bitmap;
    case geometry of
g_rectangle:
     for x := geo1 to geo3 do
      for y := geo2 to geo4 do bitmap[x,y] := true;
g_line:
      begin
	dist := distance(geo1,geo2,geo3,geo4);
	dx := geo3 - geo1;
	dy := geo4 - geo2;
	for x := 0 to dist do
        bitmap[round(geo1 + (x * dx)/dist),
	       round(geo2 + (x * dy)/dist)] := true;
      end;
g_point:
     bitmap[geo1,geo2] := true;
g_circle:
	  begin
	    sx := geo1 - geo4;
	    if sx < 1 then sx := 1;
	    sy := geo2 - geo4;
	    if sy < 1 then sy := 1;
	    ex := geo1 + geo4;
	    if ex > maxhoriz then ex := maxhoriz;
	    ey := geo2 + geo4;
	    if ey > maxvert then ey := maxvert;
	    for x := sx to ex do
	    for y := sy to ey do
	    begin
	      dist := distance(geo1,geo2,x,y);
	      if (dist <= geo4) and (dist >= geo3) then bitmap[x,y] := true;
	    end;
	  end;
    end;
    plot_bitmap;
  end;
end;

[asynchronous]
procedure center_x(var didcenterx:boolean);
var
  newoffsetx:integer;
begin
  newoffsetx := pl[now].where.x-(vpsizex div 2);
  if newoffsetx < 1 then newoffsetx := 1;
  if newoffsetx +vpsizex > here.size.x then newoffsetx := here.size.x - vpsizex + 1;
  if newoffsetx <> vpoffsetx then didcenterx := true else didcenterx := false;
  vpoffsetx := newoffsetx;
end;

[asynchronous]
procedure center_y(var didcentery:boolean);
var
  newoffsety:integer;
begin
  newoffsety := pl[now].where.y - (vpsizey div 2);
  if newoffsety < 1 then newoffsety := 1;
  if newoffsety + vpsizey-1 > here.size.y then newoffsety := here.size.y - vpsizey + 1;
  if newoffsety <> vpoffsety then didcentery := true else didcentery := false;
  vpoffsety := newoffsety;
end;

[asynchronous]
procedure center_me(mandatory:boolean := false);
var
  didcenterx,didcentery:boolean;
begin
  didcenterx := false;
  didcentery := false;
  if (pl[now].where.x-vpoffsetx < vpsizex div scrollratio) or 
     (vpoffsetx+vpsizex-pl[now].where.x <= vpsizex div scrollratio) or
     mandatory then center_x(didcenterx);
  if (pl[now].where.y-vpoffsety < vpsizey div scrollratio) or
     (vpoffsety+vpsizey-pl[now].where.y <= vpsizey div scrollratio) or
     didcenterx or
     mandatory then center_y(didcentery);
  if didcentery and (not didcenterx) then center_x(didcenterx);
  if didcenterx or didcentery or mandatory then
  smg$change_viewport(gwind,vpoffsety,vpoffsetx,vpsizey,vpsizex);
end;

[asynchronous]
procedure draw_screen(sameroom:boolean := false);
begin

{Set viewport as large as I can, or to the room size if smaller.}

  vpsizex := min(myvpmaxx,here.size.x);
  vdoffsetx := (vpmaxx - vpsizex) div 2;

  vpsizey := min(myvpmaxy,here.size.y);
  vdoffsety := (vpmaxy - vpsizey) div 2;

  center_me(true);
  if not sameroom then
  begin
    map_objects;
    fix_room(pl[now].attrib_ex[st_base] + myview);
    smg$label_border(gwind,name[na_room].id[here.valid]);
  end;
  smg$repaste_virtual_display(gwind,pasteboard,vdoffsety+2,vdoffsetx+2);
  smg$end_pasteboard_update(pasteboard);
end;

[asynchronous]
procedure turn_on_fg(fg_slot:integer; do_act:boolean := true);
begin
  with fg.effect[fg.effect[fg_slot].fparm1] do
  if not on then
  begin
    if do_act then act_out(plr[now].log,e_turn_on,fg_slot);
    on := true;
    fix_room(pl[now].attrib_ex[st_base] + myview);
  end;
end;

[asynchronous]
procedure turn_off_fg(fg_slot:integer; do_act:boolean := true);
begin
  with fg.effect[fg.effect[fg_slot].fparm1] do
  if on then
  begin
    if do_act then act_out(plr[now].log,e_turn_off,fg_slot);
    on := false;
    fix_room(pl[now].attrib_ex[st_base] + myview);
  end;
end;

[asynchronous]
procedure toggle_fg(fg_slot:integer; do_act:boolean := true);
begin
  if fg.effect[fg.effect[fg_slot].fparm1].on then turn_off_fg(fg_slot,do_act)
  else turn_on_fg(fg_slot,do_act);
end;

[asynchronous]
procedure toggle_door(x,y,fg_slot:integer; do_act:boolean := false);
begin
  wl('It is a pleasure to open for you.');
  if do_act then act_out(plr[now].log,e_open,x,y,fg_slot);
  map_foreground(fg_slot,g_point,x,y,,,false);
  with fg.effect[fg_slot] do
  if fparm1 in [1..maxfg] then
  map_foreground(fparm1,g_point,x,y);
  fix_scenery(x,y);
end;

[asynchronous]
procedure g_plot(geo,geo1,geo2,geo3,geo4,base,altitude:integer; icon:char;
		rendition:unsigned := 0);
var
  sx,sy,ex,ey,x,y,dist,dx,dy,z:integer;
  slot,map_type:integer := 0;
  s:varying[maxhoriz] of char;

  procedure plot_icon;
  {if icon = chr(0), we plot the background,
   otherwise plot the character based on priority}
  var
    lower:boolean;
  begin
    if (icon = chr(0)) or
       ((base + altitude < 
	 highest_priority(x,y,pl[now].attrib_ex[st_base]+myview,slot,map_type))
	 and (map_type <> map_background)) then fix_scenery(x,y)
    else smg$put_chars(gwind,icon,y,x,,rendition);
  end;

  procedure check_limits;
  begin
    if sx < 1 then sx := 1;
    if sy < 1 then sy := 1;
    if ex > maxhoriz then ex := maxhoriz;
    if ey > maxvert then ey := maxvert;
  end;

begin
  if human then
  begin
    if geo <> g_blip then smg$begin_display_update(gwind);
    case geo of
g_circle:
    begin
      sx := geo1 - geo4;
      sy := geo2 - geo4;
      ex := geo1 + geo4;
      ey := geo2 + geo4;
      check_limits;
      for y := sy to ey do
      for x := sx to ex do
      begin
	dist := distance(geo1,geo2,x,y);
	if (dist <= geo4) and (dist >= geo3) then plot_icon;
      end;
    end;

g_rectangle:
    begin
      sx := geo1;
      sy := geo2;
      ex := geo3;
      ey := geo4;
      check_limits;
      for y := sy to ey do
      for x := sx to ex do plot_icon;
    end;

g_line,g_blip:
    begin
      dist := distance(geo1,geo2,geo3,geo4);
      if dist > 0 then
      begin
	dx := geo3 - geo1;
	dy := geo4 - geo2;
	for z := 0 to dist do
	begin
	  x := round(geo1 + z * dx / dist);
	  y := round(geo2 + z * dy / dist);
	  plot_icon;
	  if geo = g_blip then fix_scenery(x,y);
	end;
      end;
    end;

g_point:
    begin
      x := geo1;
      y := geo2;
      plot_icon;
    end;

    end;
    if geo <> g_blip then smg$end_display_update(gwind);
  end;
end;

procedure clear_shot(x0,y0:integer; var x,y:integer; range:integer := 500);
var
  dist,dx,dy,fg_slot:integer;
  z:integer := 1;
  ok:boolean := true;
  s:string;
begin
  dist := distance(x0,y0,x,y);
  range := min(dist,range);
  if range > 0 then
  begin
    dx := x - x0;
    dy := y - y0;
    while (z < range) and ok do
    if foreground_found(round(x0 + z * dx / dist),round(y0 + z * dy / dist),
    pl[now].attrib_ex[st_base],pl[now].attrib[at_size],fg_normal,fg_slot) then 
    begin                                                                 
      if (not fg.effect[fg_slot].walk_through) then ok := false
      else z := z + 1;
    end
    else z := z + 1;
    x := round(x0 + z * dx / dist);
    y := round(y0 + z * dy / dist);
  end
  else
  begin
    range := 0;
    x := x0;
    y := y0;
  end;
end;

[asynchronous]
procedure special_effect(geometry,geo1,geo2,x,y,x1,y1:integer; icon:char;
		rendition:unsigned := 0);
begin
  if human then
  case geometry of
g_circle:
    begin
      g_plot(g_line,x,y,x1,y1,0,5,icon,rendition);
      g_plot(g_line,x,y,x1,y1,0,5,chr(0),rendition);
      g_plot(geometry,x1,y1,geo1,geo2,0,5,icon,rendition);
      g_plot(geometry,x1,y1,geo1,geo2,0,5,chr(0),rendition);
    end;
g_rectangle:
    begin
      g_plot(geometry,x1-geo1 div 2,y1-geo2 div 2,
			    x1+geo1 div 2,y1+geo2 div 2,0,5,icon,rendition);
      g_plot(geometry,x1-geo1 div 2,y1-geo2 div 2,
			    x1+geo1 div 2,y1+geo2 div 2,0,5,chr(0),rendition);
    end;
g_point:
    begin
      g_plot(geometry,x1,y1,0,0,0,5,icon,rendition);
      g_plot(geometry,x1,y1,0,0,0,5,chr(0),rendition);
    end;
g_blip:
      g_plot(geometry,x,y,x1,y1,0,5,icon,rendition);
g_line:
    begin
      g_plot(geometry,x,y,x1,y1,0,5,icon,rendition);
      g_plot(geometry,x,y,x1,y1,0,5,chr(0),rendition);
    end;
  end;
end;

end.
