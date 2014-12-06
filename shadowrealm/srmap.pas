[inherit ('srinit','srsys','srmisc','srother','srio'),
 environment('srmap')]

module srmap;

const
  maxjunction	= 100;
  maxroom	= 50;
  floor_icon	= 'o';
  fgt_floor	= 0;
  fgt_wall	= 1;
  fgt_door	= 2;
  fgt_stairup	= 4;
  fgt_stairdn	= 5;
type

  roomsrec = record
    x1,x2,y1,y2	:integer;
  end;

  junction = record
	x,y,used:integer;
	home	:integer;
	on	:boolean;
	dir	:array[1..4] of boolean;
  end;

[asynchronous]
procedure draw_map;
var
  all_connected:boolean := false;
  map_home	:array[1..maxhoriz,1..maxvert] of integer;
  junc		:array[1..maxjunction] of junction;
  connection	:array[1..maxroom] of integer;
  room		:array[1..maxroom] of roomsrec;
  path,tries,num_rooms,blocks,i,j,jn,direction:integer := 0;

  function free_junction(var j_slot:integer):boolean;
  var
    i:integer := 1;
    done:boolean := false;
  begin
    free_junction := false;
    while (i <= maxjunction) and (not done) do
    if not junc[i].on then
    begin
      done := true;
      j_slot := i;
      free_junction := true;
    end
    else i := i + 1;
  end;

  procedure do_connection(root1,root2:integer);
  var
    i,sum:integer := 0;
  begin
    while (root1 <> connection[root1]) do root1 := connection[root1];
    while (root2 <> connection[root2]) do root2 := connection[root2];
    if root1 <> root2 then connection[root1] := root2;
    for i := 1 to maxroom do
    if connection[i] <> i then sum := sum + 1;
    if sum = num_rooms - 1 then all_connected := true;
  end;

  procedure draw_corridor;
  var
    i,j,j_slot,k,count,range,xx,yy,xo,yo:integer := 0;
    first:boolean := true;
    s:string;

    procedure zap(n:integer);
    begin
      with junc[j_slot] do
      if not dir[n] then
      begin
	used := used + 1;
	dir[n] := true;
      end;
    end;

  function screen_edge(x,y:integer):boolean;
  begin
    screen_edge := false;
    case direction of
    1:if y = 1 then screen_edge := true;
    2:if y = here.size.y then screen_edge := true;
    3:if x = here.size.x then screen_edge := true;
    4:if x = 1 then screen_edge := true;
    end;
  end;

  begin
    range := 2 * rnum(10);
    xx := junc[jn].x;
    yy := junc[jn].y;
    xo := xx;
    yo := yy;
    path := junc[jn].home;
    junc[jn].used := junc[jn].used + 1;
    junc[jn].dir[direction] := true;
    if not screen_edge(xx,yy) then
    repeat
      if first then
      begin
	fg.map[xx,yy,1] := fgt_floor;
	first := false;
      end
      else fg.map[xx,yy,1] := fgt_floor;
      map_home[xx,yy] := path;
      blocks := blocks + 1;
      count := count + 1;
      xo := xx;
      yo := yy;
      case direction of
	1:yy := yy - 1;
	2:yy := yy + 1;
	3:xx := xx + 1;
	4:xx := xx - 1;
      end;
    until screen_edge(xx,yy) or
	(count = range) or
	(fg.map[xx,yy,1] = fgt_floor);

    if fg.map[xx,yy,1] = fgt_floor then
    if map_home[xx,yy] <> path then
    begin
      fg.map[xo,yo,1] := fgt_door;
      do_connection(map_home[xx,yy],path);
    end;

    if (fg.map[xx,yy,1] <> fgt_floor) then
      if free_junction(j_slot) then
      with junc[j_slot] do
      begin
{	if xx = 1 then zap(4);
	if xx = here.size.x then zap(3);
	if yy = 1 then zap(1);
	if yy = here.size.y then zap(2);}
	home := path;
	on := true;
	used := 1;
	x := xx;
	y := yy;
      end;
  end;

  procedure draw_rooms;
  var
    i,j,k:integer;
  begin
    for k := 1 to num_rooms do
    begin
      with room[k] do
      for j := room[k].y1 to room[k].y2 do
      for i := room[k].x1 to room[k].x2 do
      begin
	fg.map[i,j,1] := fgt_floor;
	map_home[i,j] := k;
      end;
    end;
  end;

  procedure create_rooms;
  var
    size_x,size_y,tries:integer;

    function no_overlap:boolean;
    var
      ii:integer;
      o_x,o_y:boolean := false;
    begin
      if i <> 1 then
      for ii := 1 to i-1 do
      begin
        if (room[i].x1 in [room[ii].x1-1..room[ii].x2+1]) or
	   (room[i].x1 in [room[ii].x1-1..room[ii].x2+1]) or
	   (room[ii].x1 in [room[i].x1-1..room[i].x2 +1]) or
	   (room[ii].x2 in [room[i].x1-1..room[i].x2 +1]) then o_x := true;
        if (room[i].y1 in [room[ii].y1-1..room[ii].y2+1]) or
	   (room[i].y2 in [room[ii].y1-1..room[ii].y2+1]) or
	   (room[ii].y2 in [room[i].y1-1..room[i].y2 +1]) or
	   (room[ii].y2 in [room[i].y1-1..room[i].y2 +1]) then o_y := true;
      end;
      no_overlap := not (o_x and o_y);
    end;

  begin
    i := 1;
    repeat
      tries := tries + 1;
      with room[i] do
      begin
	size_x := 4 + 2 * rnum(8);
	size_y := 2 + 2 * rnum(4);
	x1 := 2 * rnum((1 + here.size.x - size_x) div 2);
	y1 := 2 * rnum((1 + here.size.y - size_y) div 2);
	x2 := x1 + size_x -1;
	y2 := y1 + size_y -1;
	if no_overlap then
	with junc[1 + maxjunction - i] do
	begin
	  home := i;
	  on := true;
	  case rnum(2) of
	  1:begin
	      x := round((x1 + x2)/2);
	      if y1 = 1 then y := y2
	      else if y2 = here.size.y then y := y1
	      else
	      case rnum(2) of
	      1:y := y1;
	      2:y := y2;
	      end;
	    end;
	  2:begin
	      y := round((y1 + y2)/2);
	      if x1 = 1 then x := x2
	      else if x2 = here.size.x then x := x1
	      else
	      case rnum(2) of
	      1:x := x1;
	      2:x := x2;
	      end;
	    end;
	  end;
	  i := i + 1;
	end;
      end;
    until (tries > 1000) or (i = maxroom);
    num_rooms := i - 1;
  end;

  procedure init_junction(i:integer);
  var
    j:integer;
  begin
    with junc[i] do
    begin
      on := false;
      used := 0;
      home := 0;
      for j := 1 to 4 do dir[j] := false;
    end;
  end;

  procedure init_junctions;
  begin
    for i := 1 to maxroom do connection[i] := i;
    for i := 1 to maxjunction do init_junction(i);
    for i := 1 to here.size.x do
    for j := 1 to here.size.y do
    begin
      fg.map[i,j,1] := fgt_wall;
      map_home[i,j] := 0;
    end;
  end;

  procedure map_stairways;
  var
    x,y:integer;
  begin
    for i := 1 to rnum(6) do
    begin
      free_space(x,y);
      if i < 3 then fg.map[x,y,1] := fgt_stairup
      else fg.map[x,y,1] := fgt_stairdn;
    end;
  end;

begin
  getfg(here.valid);
  init_junctions;
  create_rooms;
  draw_rooms;
  tries := 1;
  repeat
    tries := tries + 1;
    for jn := 1 to maxjunction do
    begin
      if junc[jn].on then
      if (junc[jn].used < 4) then
      begin
	repeat
	  direction := rnum(4);
	until not junc[jn].dir[direction];
	draw_corridor;
	if junc[jn].used = 4 then init_junction(jn);
      end;
    end;
  until all_connected or (tries > 20);
  tries := 1;
  repeat
    tries := tries + 1;
    for jn := 1 to maxjunction do
    with junc[jn] do
    begin
      if on then
      if used = 1 then
      begin
	repeat
	  direction := rnum(4);
	until not dir[direction];
	draw_corridor;
      end;
    end;
  until (tries > 20);
  map_stairways;
  putfg;
end;

end.
