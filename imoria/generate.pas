[Inherit('Moria.Env')] Module Generate;

	{ Generates a random dungeon level			-RAK-	}
[global,psect(generate$code)] procedure generate_cave;
    type
	coords = record
		y	: integer;
		x	: integer;
	end;


    var
	doorstk			: array [1..100] of coords;
	doorptr			: integer;
	stupid			: vtype;

	{ Always picks a correct direction		}
      procedure correct_dir(var rdir,cdir : integer; y1,x1,y2,x2 : integer);
	var
		test_dir	: integer;
	begin
	  if (y1 < y2) then
	    rdir :=  1
	  else if (y1 = y2) then
	    rdir :=  0
	  else
	    rdir := -1;
	  if (x1 < x2) then
	    cdir :=  1
	  else if (x1 = x2) then
	    cdir :=  0
	  else
	    cdir := -1;
	  if ((rdir <> 0) and (cdir <> 0)) then
	    case randint(2) of
		1 :	rdir := 0;
		2 :	cdir := 0
	    end
	end;


	{ Chance of wandering direction			}
      procedure rand_dir(var rdir,cdir : integer; 
			     y1,x1,y2,x2,chance : integer);
	begin
	  case randint(chance) of
		1 :	begin
			  rdir := -1;
			  cdir :=  0
			end;
		2 :	begin
			  rdir :=  1;
			  cdir :=  0
			end;
		3 :	begin
			  rdir :=  0;
			  cdir := -1
			end;
		4 :	begin
			  rdir :=  0;
			  cdir :=  1
			end;
		otherwise correct_dir(rdir,cdir,y1,x1,y2,x2)
	  end
	end;
    

	{ Blanks out entire cave				-RAK-	}
    procedure blank_cave;
      var
	i1,i2	: integer;
      begin
        for i1 := 1 to max_height do
	  for i2 := 1 to max_width do
	    cave[i1,i2] := blank_floor;
      end;


	{ Fills in empty spots with desired rock		-RAK-	}
	{ Note: 9 is a temporary value.				}
    procedure fill_cave(fill : floor_type);
      var
	i1,i2	: integer;
      begin
	for i1 := 2 to cur_height - 1 do
	  for i2 := 2 to cur_width - 1 do
	    with cave[i1,i2] do
	      if (fval in [0,8,9]) then
		begin
		  fval := fill.ftval;
		  fopen := fill.ftopen;
		end;
      end;


	{ Places indestructable rock around edges of dungeon	-RAK-	}
    procedure place_boundry;
      var
	i1	: integer;
      begin
	for i1 := 1 to cur_height do
	  begin
	    cave[i1,1].fval          := boundry_wall.ftval;
	    cave[i1,1].fopen         := boundry_wall.ftopen;
	    cave[i1,cur_width].fval  := boundry_wall.ftval;
	    cave[i1,cur_width].fopen := boundry_wall.ftopen;
	  end;
	for i1 := 1 to cur_width do
	  begin
	    cave[1,i1].fval           := boundry_wall.ftval;
	    cave[1,i1].fopen          := boundry_wall.ftopen;
	    cave[cur_height,i1].fval  := boundry_wall.ftval;
	    cave[cur_height,i1].fopen := boundry_wall.ftopen;
	  end;
      end;


	{ Places "streamers" of rock through dungeon		-RAK-	}
    procedure place_streamer(rock : floor_type; treas_chance : integer);
      var
	i1,y,x,dir,ty,tx,t1,t2		: integer;
	flag				: boolean;
      begin

	{ Choose starting point and direction		}
	y := trunc(cur_height/2.0) + 11 - randint(23);
	x := trunc(cur_width/2.0)  + 16 - randint(33);

	dir := randint(8);	{ Number 1-4, 6-9	}
	if (dir > 4) then dir := dir + 1;

	{ Place streamer into dungeon			}
	flag := false;	{ Set to true when y,x are out-of-bounds}
	t1 := 2*dun_str_rng + 1;	{ Constants	}
	t2 :=   dun_str_rng + 1;
	repeat
	  for i1 := 1 to dun_str_den do
	    begin
	      ty := y + randint(t1) - t2;
	      tx := x + randint(t1) - t2;
	      if (in_bounds(ty,tx)) then
	        with cave[ty,tx] do
		  if (fval = rock_wall1.ftval) then
		    begin
		      fval := rock.ftval;
		      fopen := rock.ftopen;
		      if (randint(treas_chance) = 1) then
		        place_gold(ty,tx);
		    end;
	    end;
	  if (not(move(dir,y,x))) then flag := true;
	until(flag);
      end;


    procedure all_the_river_stuff;
      type
	river_deal = record
	  in1,in2,out	: integer; { (keypad) directions; in is upstream }
	  flow		: integer; { water flow out of this river spot }
	  pos		: integer; { in array of s_l_type; if > num_left then }
				   { spot is no longer available }
	end;

	s_l_type = record
	  loc		: coords; { cross-ref back to river_deal }
	  is_active	: boolean;{ is still an unresolved river source}
	end;

      const
	size_y = 10;
	size_x = 31;
	total_size = 310;
	segment_size = 6;

      var
	  gup		: array [1..size_y] of array [1..size_x] of river_deal;
	  s_list	: array [1..total_size] of s_l_type;
	  num_left,s_l_top	: integer;
	  max_wet	: integer; { # of river or next-to-river }
	  i1,i2		: integer;
	  river_mouth	: coords;
	  out_str	: string;

	{ returns position of (this + dir) in gup or this if out of bounds }
	function move_this(dir : integer; this : coords; var that : coords) : boolean;
	  begin
	    move_this := false;
	    that.y := this.y + dy_of[dir];
	    that.x := this.x + dx_of[dir];
	    if (that.y in [1..size_y]) and (that.x in [1..size_x]) then
	      move_this := true
	    else	{reset to legal value}
	      that := this;
	  end;


	{make gup[this] unavailable (for later selection), decrement num_left}
	procedure remove_this(this : coords);
	  var i1	: integer;
	      that	: coords;
	      last	: s_l_type;
 	  begin
	    with gup[this.y,this.x] do
	     if (pos <= num_left) then {if gup[this].pos is still available}
	      begin
		last := s_list[num_left];  {switch gup[this].pos with top elmt}
		s_list[num_left] := s_list[pos];
		s_list[pos] := last;
		gup[last.loc.y,last.loc.x].pos := pos;
		pos := num_left;
		num_left := num_left - 1;  {pop gup[this].pos}
	      end;
	  end;

	procedure plot_water(y,x : integer; font,tdir : integer);
	  var
		num_dots	: integer;
		dots		: array [1..5] of coords;
		i1		: integer;
	    begin
	      dots[1].y := y;
	      dots[1].x := x;
	      case font of
		0 : num_dots := 1;
		1 : begin
		      num_dots := 2;
		      dots[2].y := y + dx_of[tdir];
		      dots[2].x := x - dy_of[tdir];
		    end;
		otherwise
		      begin
			num_dots := 5;
			for i1 := 1 to 4 do
			  begin
			    dots[i1+1].y := y + dy_of[2*i1];
			    dots[i1+1].x := x + dx_of[2*i1];
			  end;
		      end;
	      end;
	      for i1 := 1 to num_dots do
		if in_bounds(dots[i1].y,dots[i1].x) then
		  with cave[dots[i1].y,dots[i1].x] do
		  begin
		    if (fval in [1,2]) then
		      begin
			fval := water2.ftval;
			fopen := water2.ftopen;
		      end
		    else
		      begin
			fval := water1.ftval;
			fopen := water1.ftopen;
		      end;
		    h2o := 1;
		    if (tptr <> 0) and (t_list[tptr].tval > valuable_metal)
			 then
		      begin
			pusht(tptr);
			tptr := 0;
		      end;
		  end { with cave }
	    end;

{ A recursive procedure, starting at river mouth and moving upstream; connects
  the dots laid out by chart_river. }

      procedure place_river(dir,next_dir : integer; this,wiggle : coords);
       var
	i1,i2,y,x,oy,ox		: integer;
	temp_dir,done_first	: integer; { compute next direction }
	up1,up2			: coords;
	tflow			: integer;

       function figure_out_path_of_water : integer;
	var 
	 target_dy,target_dx,dist_squared	: integer;
	 i1,dot_product,rand_num,chance		: integer;
	 start	: array [0..8] of integer;
	 flag	: boolean;
	begin
	  target_dy := y - oy;
	  target_dx := x - ox;
	  dist_squared := target_dy * target_dy + target_dx * target_dx;
	  start[0] := 1;
	  for i1 := 0 to 7 do	{octant number}
	    begin
	      dot_product := target_dy*dy_of[key_of[i1]] + target_dx*dx_of[key_of[i1]];
	{formula subtracts dist_squared to keep stream semi-normal}
	{diagonals give root2 inflated dot_products}
	      if (dot_product > 0) then
		if i1 in [1,3,5,7] then
		  chance := dot_product * dot_product * 2 - dist_squared
		else
		  chance := dot_product * dot_product * 4 - dist_squared
	      else
		chance := 0;
	      if (chance > 0) then
		start[i1+1] := start[i1] + chance
	      else
		start[i1+1] := start[i1];
	    end;
	{choose random directions; chances partitioned by start[]}
	  rand_num := randint(start[8] - 1);
	  flag := false;
	  i1 := -1;
	  repeat
	    i1 := i1 + 1;
	    flag := (start[i1 + 1] > rand_num);
	  until (flag);
	  figure_out_path_of_water := key_of[i1];
	end;

       begin
	move_this(dir,this,up1);	{up1 is upstream end of segment}
	move_this(next_dir,up1,up2);	{up2 is upstream end of next segment}
	tflow := (gup[up2.y,up2.x].flow - 1) div 2;	{river size}
		{aim (y,x) toward upstream end of segment, randomize slightly}
	oy := segment_size * this.y + wiggle.y;
	ox := segment_size * this.x + wiggle.x;
	if (dir <> next_dir) then
	  begin
	    i1 := oct_of[next_dir] - oct_of[dir]; { (1=left, -1 = right) mod 8}
	    if (oct_of[dir] mod 2 = 0) then
	      i2 := rotate_dir(next_dir,i1)
	    else
	      i2 := rotate_dir(next_dir,2*i1);
	    wiggle.y := dy_of[i2] + (randint(3) - 2);
	    wiggle.x := dx_of[i2] + (randint(3) - 2);
	  end;
	i1 := 0;
	y := segment_size*up1.y+wiggle.y; {y,x=(upstream) destination of river}
	x := segment_size*up1.x+wiggle.x;
	while ((oy <> y) or (ox <> x)) do
	 begin
	  temp_dir := figure_out_path_of_water;
	  if (temp_dir) in [2,4,6,8] then
	    begin
	      move(temp_dir,oy,ox);
	      plot_water(oy,ox,tflow,temp_dir);
	    end
	  else
	    begin
	      if (randint(2) = 1) then
		done_first := 1
	      else
		done_first := -1;
	      move(rotate_dir(temp_dir,done_first),oy,ox);
	      plot_water(oy,ox,tflow,temp_dir);
	      move(rotate_dir(temp_dir,-done_first),oy,ox);
	      plot_water(oy,ox,tflow,temp_dir);
	    end;
	 end;
		{branch rivers 1 move early to make branching more gradual}
	with gup[up2.y,up2.x] do
	  begin
	    if (in1 <> 5) then
	      place_river(next_dir,in1,up1,wiggle);
	    if (in2 <> 5) then
	      place_river(next_dir,in2,up1,wiggle);
	  end;
      end;

	    
{ recursively charts basic path of stream upstream }
	procedure chart_river;
	  var i1,i2,dir,branches	: integer;
	      out_flow,in_flow		: integer;
	      this,thing		: coords;
	      that			: array [1..3] of coords;
	      that_dir			: array [1..3] of integer;
	      that_ok,that_chosen	: array [1..3] of boolean;
	      starting_river		: boolean;


{determines next point(s) upstream depending on coordinates (this), previous
 direction (gup[this].out), and available positions. outputs # of branches}
	  function choose_stream_dirs(var this : coords) : integer;
	    var i1	: integer;
	      done	: boolean;
	    begin
	      this := s_list[s_l_top].loc;
	      dir := gup[this.y,this.x].out;
	      for i1 := 1 to 3 do	{left,straight,right}
		begin
		  that_dir[i1] := rotate_dir(dir,2-i1);
		  that_ok[i1] := move_this(that_dir[i1],this,that[i1]);
		  if that_ok[i1] then
		    that_ok[i1] := gup[that[i1].y,that[i1].x].pos <= num_left;
		  that_chosen[i1] := false;
		end;
	      done := false;
	      if ((randint(3*gup[this.y,this.x].flow) = 1) or
		 not (that_ok[1] or that_ok[2] or that_ok[3])) then
		begin  {end stream if blocked or small river and random}
		  done := true;
		  choose_stream_dirs := 0;
		end
	      else if (((randint(5) = 1) or not (that_ok[1] or that_ok[3]))
	      and that_ok[2]) then
		begin	{straight stream (1/5 and ok) or sides blocked}
		  done := true;
		  that_chosen[2] := true;
		  choose_stream_dirs := 1;
		end
	      else if ((randint(5) = 1) and (that_ok[1] and that_ok[3])) then
		begin	{fork 1/5 and both sides ok}
		  done := true;
		  that_chosen[1] := true;
		  that_chosen[3] := true;
		  choose_stream_dirs := 2;
		end;
	      if (not done) then	{ 1 or 3 must be open } 
		{check 1 side first; if it fails, second must be true}
		begin
		  i1 := 2*randint(2) - 1;
		  that_chosen[i1] := that_ok[i1];
		  that_chosen[4-i1] := not that_chosen[i1];
		  choose_stream_dirs := 1;
		end;
		{no rivers adjacent each other (except connected segments)}
	    end;

	{get highest unresolved river segment; s_l_top points to new segment
	 if any is found. }
	  function dequeue_s_list : boolean;
	    begin
	      while ((s_l_top > num_left) and (not s_list[s_l_top].is_active)) do
		s_l_top := s_l_top - 1;
	      if (s_l_top > num_left) then
		begin
		  s_list[s_l_top].is_active := false;
		  dequeue_s_list := true;
		end
	      else
		dequeue_s_list := false;
	    end;	

	  begin { chart_river }
	    starting_river := true;
	    remove_this(s_list[randint(num_left)].loc);{element is now s_l_top}
	    s_list[s_l_top].is_active := true;
	    this := s_list[s_l_top].loc;
	    gup[this.y,this.x].flow := 4+randint(3);
	    river_mouth := this;
	    for i1 := 1 to 3 do
	      that_chosen[i1] := false;
	    i1 := 0;
	    repeat		{ choose initial heading, in streams }
	      dir := randint(8);
	      if (dir = 5) then
		dir := 9;
	      i1 := i1 + 1;
	      if move_this(dir,this,that[2]) then
		that_chosen[2] := gup[that[2].y,that[2].x].pos <= num_left;
	    until ((that_chosen[2]) or (i1 >= 10));
	    that_dir[2] := dir;
	    that_ok[2] := true;
	    branches := 1;
	    while dequeue_s_list do	{loop until river stops}
	      begin
		if starting_river then
		  starting_river := false
		else
		  branches := choose_stream_dirs(this);
	      for i1 := 1 to 9 do 
		  if move_this(i1,this,thing) then
		    remove_this(thing);
	      if (that_chosen[1]) then	{ No sharp left turns }
		begin	
		  move_this(rotate_dir(dir,1),this,thing);
		  if move_this(rotate_dir(dir,2),thing,thing) then
		    remove_this(thing)
		end;
	      if (that_chosen[3]) then  { No sharp right turns }
		begin
		  move_this(rotate_dir(dir,-1),this,thing);
		  if move_this(rotate_dir(dir,-2),thing,thing) then
		    remove_this(thing)
		end;
		out_flow := gup[this.y,this.x].flow;
		i2 := 1;
		for i1 := 1 to 3 do
		  if (that_chosen[i1] and (total_size-num_left<max_wet)) then
		    begin
		      if (branches = 1) then
			in_flow := out_flow
		      else
			in_flow := out_flow - randint(2);
		      if (in_flow > 0) then
			with gup[that[i1].y,that[i1].x] do
			  begin
		            if (i2 = 1) then
			      gup[this.y,this.x].in1 := that_dir[i1]
		            else
			      gup[this.y,this.x].in2 := that_dir[i1];
			    s_list[pos].is_active := true;
			    out := that_dir[i1];
			    flow := in_flow;
			  end;
		      i2 := i2 + 1;
		    end;
	      end;
	  end;

	  procedure draw_river;
	    var
		first_dir	: integer;
		wiggle,that	: coords;
	    begin
	      wiggle.y := randint(3) - 2;
	      wiggle.x := randint(3) - 2;
	      {XXX place whirlpool at segment_size*river + wiggle}
	      first_dir := gup[river_mouth.y,river_mouth.x].in1;
	      move_this(first_dir,river_mouth,that);
	      with gup[that.y,that.x] do
		begin
		  if (in1 <> 5) then
		    place_river(first_dir,in1,river_mouth,wiggle);
		  if (in2 <> 5) then
		    place_river(first_dir,in2,river_mouth,wiggle);
		end;
	    end;


	  begin { all_the_river_stuff }
	    max_wet := randint(total_size) - 50;
	    if (max_wet < 0) then
		max_wet := 0;
	    num_left := 0;
	    for i1 := 1 to size_y do
	      for i2 := 1 to size_x do
		begin
		  num_left := num_left + 1;
		  with gup[i1,i2] do
		   begin
		    in1 := 5;
		    in2 := 5;
		    out := 5;
		    flow := 0;
		    pos := num_left;
		   end;
		  with s_list[num_left] do
		   begin
		    loc.y := i1;
		    loc.x := i2;
		    is_active := false;
		   end;
		end;
	    for i1 := 1 to num_left do {remove borders of map}
	      with s_list[i1] do
		if (loc.y = 1) or (loc.y = size_y) or (loc.x = 1) or (loc.x = size_x) then
		  remove_this(loc);
	    s_l_top := num_left;
	    while (total_size - num_left < max_wet) do
	      begin
		chart_river;
		draw_river;
	      end;		
	  end;


	{ Place a pool of water, and rough up the edges		-DMF-	}
    procedure place_pool(water : floor_type);
      var
	i1,y,x	: integer;
      begin
	y := trunc(cur_height/2.0) + 11 - randint(23);
	x := trunc(cur_width/2.0) + 16 - randint(33);
      end;


	{ Place a trap with a given displacement of point	-RAK-	}
    procedure vault_trap(y,x,yd,xd,num : integer);
      var
	count,y1,x1,i1		: integer;
	flag			: boolean;
      begin
	for i1 := 1 to num do
	  begin
	    flag := false;
	    count := 0;
	    repeat
	      y1 := y - yd - 1 + randint(2*yd+1);
	      x1 := x - xd - 1 + randint(2*xd+1);
	      with cave[y1,x1] do
	        if (fval in floor_set) then
	          if (tptr = 0) then
		    begin
		      place_trap(y1,x1,1,randint(max_trapa));
		      flag := true;
		    end;
	      count := count + 1;
	    until((flag) or (count > 5));
	  end;
      end;


	{ Place a trap with a given displacement of point	-RAK-	}
    procedure vault_monster(y,x,num : integer);
      var
		i1,y1,x1		: integer;
      begin
	for i1 := 1 to num do
	  begin
	    y1 := y;
	    x1 := x;
	    summon_land_monster(y1,x1,true);
	  end;
      end;


	{ Builds a room at a row,column coordinate		-RAK-	}
    procedure build_room(yval,xval : integer);
      var
		y_height,y_depth	: integer;
		x_left,x_right		: integer;
		i1,i2			: integer;
		cur_floor		: floor_type;
      begin
	if (dun_level <= randint(25)) then
	  cur_floor := lopen_floor	{ Floor with light	}
	else
	  cur_floor := dopen_floor;	{ Dark floor		}
	y_height := yval - randint(4);
	y_depth  := yval + randint(3);
	x_left   := xval - randint(11);
	x_right  := xval + randint(11);
	for i1 := y_height to y_depth do
	  for i2 := x_left to x_right do
	    begin
	      cave[i1,i2].fval  := cur_floor.ftval;
	      cave[i1,i2].fopen := cur_floor.ftopen;
	    end;
	for i1 := (y_height - 1) to (y_depth + 1) do
	  begin
	    cave[i1,x_left-1].fval   := rock_wall1.ftval;
	    cave[i1,x_left-1].fopen  := rock_wall1.ftopen;
	    cave[i1,x_right+1].fval  := rock_wall1.ftval;
	    cave[i1,x_right+1].fopen := rock_wall1.ftopen;
	  end;
	for i1 := x_left to x_right do
	  begin
	    cave[y_height-1,i1].fval  := rock_wall1.ftval;
	    cave[y_height-1,i1].fopen := rock_wall1.ftopen;
	    cave[y_depth+1,i1].fval   := rock_wall1.ftval;
	    cave[y_depth+1,i1].fopen  := rock_wall1.ftopen;
	  end
      end;


	{ Builds a room at a row,column coordinate		-RAK-	}
	{ Type 1 unusual rooms are several overlapping rectangular ones	}
    procedure build_type1(yval,xval : integer);
      var
		y_height,y_depth	: integer;
		x_left,x_right		: integer;
		i0,i1,i2		: integer;
		cur_floor		: floor_type;
      begin
	if (dun_level <= randint(25)) then
	  cur_floor := lopen_floor	{ Floor with light	}
	else
	  cur_floor := dopen_floor;	{ Dark floor		}
	for i0 := 1 to (1 + randint(2)) do
	  begin
	    y_height := yval - randint(4);
	    y_depth  := yval + randint(3);
	    x_left   := xval - randint(11);
	    x_right  := xval + randint(11);
	    for i1 := y_height to y_depth do
	      for i2 := x_left to x_right do
		begin
		  cave[i1,i2].fval  := cur_floor.ftval;
		  cave[i1,i2].fopen := cur_floor.ftopen;
		end;
	    for i1 := (y_height - 1) to (y_depth + 1) do
	      begin
		with cave[i1,x_left-1] do
		  if (fval <> cur_floor.ftval) then
		    begin
		      fval  := rock_wall1.ftval;
		      fopen := rock_wall1.ftopen;
		    end;
		with cave[i1,x_right+1] do
		  if (fval <> cur_floor.ftval) then
		    begin
		      fval  := rock_wall1.ftval;
		      fopen := rock_wall1.ftopen;
		    end;
	      end;
	    for i1 := x_left to x_right do
	      begin
		with cave[y_height-1,i1] do
		  if (fval <> cur_floor.ftval) then
		    begin
		      fval  := rock_wall1.ftval;
		      fopen := rock_wall1.ftopen;
		    end;
		with cave[y_depth+1,i1] do
		  if (fval <> cur_floor.ftval) then
		    begin
		      fval  := rock_wall1.ftval;
		      fopen := rock_wall1.ftopen;
		    end;
	      end;
	  end;
      end;


	{ Builds an unusual room at a row,column coordinate	-RAK-	}
	{ Type 2 unusual rooms all have an inner room:			}
	{   1 - Just an inner room with one door			}
	{   2 - An inner room within an inner room			}
	{   3 - An inner room with pillar(s)				}
	{   4 - Inner room has a maze					}
	{   5 - A set of four inner rooms				}
    procedure build_type2(yval,xval : integer);
      var
		y_height,y_depth	: integer;
		x_left,x_right		: integer;
		i1,i2			: integer;
		cur_floor		: floor_type;
      begin
	if (dun_level <= randint(30)) then
	  cur_floor := lopen_floor	{ Floor with light	}
	else
	  cur_floor := dopen_floor;	{ Dark floor		}
	y_height := yval - 4;
	y_depth  := yval + 4;
	x_left   := xval - 11;
	x_right  := xval + 11;
	for i1 := y_height to y_depth do
	  for i2 := x_left to x_right do
	    begin
	      cave[i1,i2].fval  := cur_floor.ftval;
	      cave[i1,i2].fopen := cur_floor.ftopen;
	    end;
	for i1 := (y_height - 1) to (y_depth + 1) do
	  begin
	    cave[i1,x_left-1].fval   := rock_wall1.ftval;
	    cave[i1,x_left-1].fopen  := rock_wall1.ftopen;
	    cave[i1,x_right+1].fval  := rock_wall1.ftval;
	    cave[i1,x_right+1].fopen := rock_wall1.ftopen;
	  end;
	for i1 := x_left to x_right do
	  begin
	    cave[y_height-1,i1].fval  := rock_wall1.ftval;
	    cave[y_height-1,i1].fopen := rock_wall1.ftopen;
	    cave[y_depth+1,i1].fval   := rock_wall1.ftval;
	    cave[y_depth+1,i1].fopen  := rock_wall1.ftopen;
	  end;
	{ The inner room		}
	y_height := y_height + 2;
	y_depth  := y_depth  - 2;
	x_left   := x_left   + 2;
	x_right  := x_right  - 2;
	for i1 := (y_height - 1) to (y_depth + 1) do
	  begin
	    cave[i1,x_left-1].fval   := 8;
	    cave[i1,x_right+1].fval  := 8;
	  end;
	for i1 := x_left to x_right do
	  begin
	    cave[y_height-1,i1].fval  := 8;
	    cave[y_depth+1,i1].fval   := 8;
	  end;
	{ Inner room varitions		}
	case randint(5) of
	  1 :	begin	{ Just an inner room...	}
		  case randint(4) of	{ Place a door	}
		    1 :	place_secret_door(y_height-1,xval);
		    2 :	place_secret_door(y_depth+1,xval);
		    3 :	place_secret_door(yval,x_left-1);
		    4 :	place_secret_door(yval,x_right+1);
		  end;
		  vault_monster(yval,xval,1);
		end;
	  2 :	begin	{ Treasure Vault	}
		  case randint(4) of	{ Place a door	}
		    1 :	place_secret_door(y_height-1,xval);
		    2 :	place_secret_door(y_depth+1,xval);
		    3 :	place_secret_door(yval,x_left-1);
		    4 :	place_secret_door(yval,x_right+1);
		  end;
		  for i1 := yval-1 to yval+1 do
		    begin
		      cave[i1,xval-1].fval   := 8;
		      cave[i1,xval+1].fval   := 8;
		    end;
		  cave[yval-1,xval].fval  := 8;
		  cave[yval+1,xval].fval  := 8;
		  case randint(4) of	{ Place a door	}
		    1 :	place_locked_door(yval-1,xval);
		    2 :	place_locked_door(yval+1,xval);
		    3 :	place_locked_door(yval,xval-1);
		    4 :	place_locked_door(yval,xval+1);
		  end;
			{ Place an object in the treasure vault	}
		  case randint(10) of
		    1 : place_a_staircase(yval,xval,up_staircase);
		    2 : place_a_staircase(yval,xval,down_staircase);
		    otherwise place_object(yval,xval);
		  end;
			{ Guard the treasure well		}
		  vault_monster(yval,xval,2+randint(3));
			{ If the monsters don't get 'em...	}
		  vault_trap(yval,xval,4,10,2+randint(3));
		end;
	  3 :	begin	{ Inner pillar(s)...	}
		  case randint(4) of	{ Place a door	}
		    1 :	place_secret_door(y_height-1,xval);
		    2 :	place_secret_door(y_depth+1,xval);
		    3 :	place_secret_door(yval,x_left-1);
		    4 :	place_secret_door(yval,x_right+1);
		  end;
		  for i1 := yval-1 to yval+1 do
		    for i2 := xval-1 to xval+1 do
		      cave[i1,i2].fval   := 8;
		  if (randint(2) = 1) then
		    begin
		      case randint(2) of
		        1 : begin
		              for i1 := yval-1 to yval+1 do
			        for i2 := xval-6 to xval-4 do
			          cave[i1,i2].fval   := 8;
		              for i1 := yval-1 to yval+1 do
			        for i2 := xval+4 to xval+6 do
			          cave[i1,i2].fval   := 8;
		            end;
		        2 : begin
		              for i1 := yval-1 to yval+1 do
			        for i2 := xval-7 to xval-5 do
			          cave[i1,i2].fval   := 8;
		              for i1 := yval-1 to yval+1 do
			        for i2 := xval+5 to xval+7 do
			          cave[i1,i2].fval   := 8;
		            end;
		      end;
		      if (randint(3) = 1) then	{ Inner rooms	}
			begin
			  for i1 := xval-5 to xval+5 do
			    begin
			      cave[yval-1,i1].fval := 8;
			      cave[yval+1,i1].fval := 8;
			    end;
			  case randint(2) of
			    1 : place_secret_door(yval+1,xval-3);
			    2 : place_secret_door(yval-1,xval-3);
			  end;
			  case randint(2) of
			    1 : place_secret_door(yval+1,xval+3);
			    2 : place_secret_door(yval-1,xval+3);
			  end;
			  if (randint(3) = 1) then place_object(yval,xval-2);
			  if (randint(3) = 1) then place_object(yval,xval+2);
			  vault_monster(yval,xval-2,randint(2));
			  vault_monster(yval,xval+2,randint(2));
			end;
		    end;
		end;
	  4 :	begin	{ Maze inside...	}
		  case randint(4) of	{ Place a door	}
		    1 :	place_secret_door(y_height-1,xval);
		    2 :	place_secret_door(y_depth+1,xval);
		    3 :	place_secret_door(yval,x_left-1);
		    4 :	place_secret_door(yval,x_right+1);
		  end;
		  for i1 := y_height to y_depth do
		    for i2 := x_left to x_right do
		      if (odd(i2+i1)) then
			cave[i1,i2].fval := 8;
		{ Monsters just love mazes...		}
		  vault_monster(yval,xval-5,randint(3));
		  vault_monster(yval,xval+5,randint(3));
		{ Traps make them entertaining...	}
		  vault_trap(yval,xval-3,2,8,randint(3));
		  vault_trap(yval,xval+3,2,8,randint(3));
		{ Mazes should have some treasure too..	}
		  for i1 := 1 to 3 do
		    random_object(yval,xval,1);
		end;
	  5 :	begin	{ Four small rooms...	}
		  for i1 := y_height to y_depth do
		    cave[i1,xval].fval := 8;
		  for i1 := x_left to x_right do
		    cave[yval,i1].fval := 8;
		  case randint(2) of
		    1 :	begin
			  i1 := randint(10);
			  place_secret_door(y_height-1,xval-i1);
			  place_secret_door(y_height-1,xval+i1);
			  place_secret_door(y_depth+1,xval-i1);
			  place_secret_door(y_depth+1,xval+i1);
			end;
		    2 :	begin
			  i1 := randint(3);
			  place_secret_door(yval+i1,x_left-1);
			  place_secret_door(yval-i1,x_left-1);
			  place_secret_door(yval+i1,x_right+1);
			  place_secret_door(yval-i1,x_right+1);
			end;
		  end;
		{ Treasure in each one...		}
		  random_object(yval,xval,2+randint(2));
		{ Gotta have some monsters...		}
		  vault_monster(yval+2,xval-4,randint(2));
		  vault_monster(yval+2,xval+4,randint(2));
		  vault_monster(yval-2,xval-4,randint(2));
		  vault_monster(yval-2,xval+4,randint(2));
		end;
	end;
      end;


	{ Builds a room at a row,column coordinate		-RAK-	}
	{ Type 3 unusual rooms are cross shaped				}
    procedure build_type3(yval,xval : integer);
      var
		y_height,y_depth	: integer;
		x_left,x_right		: integer;
		i0,i1,i2		: integer;
		cur_floor		: floor_type;
      begin
	if (dun_level <= randint(25)) then
	  cur_floor := lopen_floor	{ Floor with light	}
	else
	  cur_floor := dopen_floor;	{ Dark floor		}
	i0 := 2 + randint(2);
	y_height := yval - i0;
	y_depth  := yval + i0;
	x_left   := xval - 1;
	x_right  := xval + 1;
	for i1 := y_height to y_depth do
	  for i2 := x_left to x_right do
	    begin
	      cave[i1,i2].fval  := cur_floor.ftval;
	      cave[i1,i2].fopen := cur_floor.ftopen;
	    end;
	for i1 := (y_height - 1) to (y_depth + 1) do
	  begin
	    with cave[i1,x_left-1] do
	      begin
		fval  := rock_wall1.ftval;
		fopen := rock_wall1.ftopen;
	      end;
	    with cave[i1,x_right+1] do
	      begin
		fval  := rock_wall1.ftval;
		fopen := rock_wall1.ftopen;
	      end;
	  end;
	for i1 := x_left to x_right do
	  begin
	    with cave[y_height-1,i1] do
	      begin
		fval  := rock_wall1.ftval;
		fopen := rock_wall1.ftopen;
	      end;
	    with cave[y_depth+1,i1] do
	      begin
		fval  := rock_wall1.ftval;
		fopen := rock_wall1.ftopen;
	      end;
	  end;
	i0 := 2 + randint(9);
	y_height := yval - 1;
	y_depth  := yval + 1;
	x_left   := xval - i0;
	x_right  := xval + i0;
	for i1 := y_height to y_depth do
	  for i2 := x_left to x_right do
	    begin
	      cave[i1,i2].fval  := cur_floor.ftval;
	      cave[i1,i2].fopen := cur_floor.ftopen;
	    end;
	for i1 := (y_height - 1) to (y_depth + 1) do
	  begin
	    with cave[i1,x_left-1] do
	      if (fval <> cur_floor.ftval) then
		begin
		  fval  := rock_wall1.ftval;
		  fopen := rock_wall1.ftopen;
		end;
	    with cave[i1,x_right+1] do
	      if (fval <> cur_floor.ftval) then
		begin
		  fval  := rock_wall1.ftval;
		  fopen := rock_wall1.ftopen;
		end;
	  end;
	for i1 := x_left to x_right do
	  begin
	    with cave[y_height-1,i1] do
	      if (fval <> cur_floor.ftval) then
		begin
		  fval  := rock_wall1.ftval;
		  fopen := rock_wall1.ftopen;
		end;
	    with cave[y_depth+1,i1] do
	      if (fval <> cur_floor.ftval) then
		begin
		  fval  := rock_wall1.ftval;
		  fopen := rock_wall1.ftopen;
		end;
	  end;
	{ Special features...			}
	case randint(4) of
	  1 :	begin	{ Large middle pillar		}
		  for i1 := yval-1 to yval+1 do
		    for i2 := xval-1 to xval+1 do
		      cave[i1,i2].fval := 8;
		end;
	  2 :	begin	{ Inner treasure vault		}
		  for i1 := yval-1 to yval+1 do
		    begin
		      cave[i1,xval-1].fval   := 8;
		      cave[i1,xval+1].fval   := 8;
		    end;
		  cave[yval-1,xval].fval  := 8;
		  cave[yval+1,xval].fval  := 8;
		  case randint(4) of	{ Place a door	}
		    1 :	place_secret_door(yval-1,xval);
		    2 :	place_secret_door(yval+1,xval);
		    3 :	place_secret_door(yval,xval-1);
		    4 :	place_secret_door(yval,xval+1);
		  end;
		{ Place a treasure in the vault		}
		  place_object(yval,xval);
		{ Let's gaurd the treasure well...	}
		  vault_monster(yval,xval,2+randint(2));
		{ Traps naturally			}
		  vault_trap(yval,xval,4,4,1+randint(3));
		end;
	  3 :	begin
		  if (randint(3) = 1) then
		    begin
		      cave[yval-1,xval-2].fval := 8;
		      cave[yval+1,xval-2].fval := 8;
		      cave[yval-1,xval+2].fval := 8;
		      cave[yval-1,xval+2].fval := 8;
		      cave[yval-2,xval-1].fval := 8;
		      cave[yval-2,xval+1].fval := 8;
		      cave[yval+2,xval-1].fval := 8;
		      cave[yval+2,xval+1].fval := 8;
		      if (randint(3) = 1) then
			begin
			  place_secret_door(yval,xval-2);
			  place_secret_door(yval,xval+2);
			  place_secret_door(yval-2,xval);
			  place_secret_door(yval+2,xval);
			end;
		    end
		  else if (randint(3) = 1) then
		    begin
		      cave[yval,xval].fval := 8;
		      cave[yval-1,xval].fval := 8;
		      cave[yval+1,xval].fval := 8;
		      cave[yval,xval-1].fval := 8;
		      cave[yval,xval+1].fval := 8;
		    end
		  else if (randint(3) = 1) then
		    cave[yval,xval].fval := 8;
		end;
	  4 :	;
	end;
      end;
{  procedure build_cave(yval,xval : integer);
      var
		y_height,y_depth	: integer;
		x_left,x_right		: integer;
		i1,i2			: integer;
		radius			: integer;
     begin
	y_height := yval - 11;
	y_depth  := yval + 11;
	x_left   := xval - 11;
	x_right  := xval + 11;
	for i1 := y_height to y_depth do
	  for i2 := x_left to x_right do
	   begin
	    radius := trunc(sqrt(((((i1 - yval) ** 2) + ((i2 - xval) ** 2)))));
	    if ((radius + randint(3)) > 9) then
	      begin
		cave[i1,i2].fval  := rock_type1.ftval;
		cave[i1,i2].fopen := rock_type1.ftopen;
	      end
	    else
	      begin
		cave[i1,i2].fval  := dopen_floor.ftval;
		cave[i1,i2].fopen := dopen_floor.ftopen;
	      end;
	   end;
	  place_object(yval,xval);
	  vault_monster(yval,xval,2+randint(2));
	  vault_trap(yval,xval,4,4,1+randint(3));
      end;  }

	{ Constructs a tunnel between two points		}
    procedure tunnel(row1,col1,row2,col2 : integer);
      var
	tmp_row,tmp_col		: integer;
	row_dir,col_dir 	: integer;
	i1,i2,tmp		: integer;
	tunstk			: array [1..1000] of coords;
	wallstk			: array [1..1000] of coords;
	tunptr			: integer;
	wallptr			: integer;
	stop_flag,door_flag	: boolean;


	{ Main procedure for Tunnel			}
	{ Note: 9 is a temporary value		}
      begin
	stop_flag := false;
	door_flag := false;
	tunptr    := 0;
	wallptr   := 0;
	correct_dir(row_dir,col_dir,row1,col1,row2,col2);
	repeat
	  if (randint(100) > dun_tun_chg) then
	    rand_dir(row_dir,col_dir,row1,col1,row2,col2,dun_tun_rnd);
	  tmp_row := row1 + row_dir;
	  tmp_col := col1 + col_dir;
	  while (not(in_bounds(tmp_row,tmp_col))) do
	    begin
	      rand_dir(row_dir,col_dir,row1,col1,row2,col2,dun_tun_rnd);
	      tmp_row := row1 + row_dir;
	      tmp_col := col1 + col_dir;
	    end;
	  with cave[tmp_row,tmp_col] do
	    if (fval = rock_wall1.ftval) then
	      begin
		row1 := tmp_row;
		col1 := tmp_col;
		if (wallptr < 1000) then
		  wallptr := wallptr + 1;
		wallstk[wallptr].y := row1;
		wallstk[wallptr].x := col1;
		for i1 := row1-1 to row1+1 do
		  for i2 := col1-1 to col1+1 do
		    if (in_bounds(i1,i2)) then
		      with cave[i1,i2] do
			if (fval in wall_set) then
			  fval := 9;
	      end
	    else if (fval = corr_floor1.ftval) then
	      begin
		row1 := tmp_row;
		col1 := tmp_col;
		if (not(door_flag)) then
		  begin
		    if (doorptr <= 100) then
		      begin
			doorptr := doorptr + 1;
			doorstk[doorptr].y := row1;
			doorstk[doorptr].x := col1;
		      end;
		    door_flag := true;
		  end;
		if (randint(100) > dun_tun_con) then
		  stop_flag := true;
	      end
	    else if (fval = 0) then
	      begin
		row1 := tmp_row;
		col1 := tmp_col;
		if (tunptr < 1000) then
		  tunptr := tunptr + 1;
		tunstk[tunptr].y := row1;
		tunstk[tunptr].x := col1;
		door_flag := false;
	      end
	    else if (fval <> 9) then
	      begin
		row1 := tmp_row;
		col1 := tmp_col;
	      end;
	until (((row1 = row2) and (col1 = col2)) or (stop_flag));
	for i1 := 1 to tunptr do
	  begin
	    cave[tunstk[i1].y,tunstk[i1].x].fval  := corr_floor1.ftval;
	    cave[tunstk[i1].y,tunstk[i1].x].fopen := corr_floor1.ftopen;
	  end;
	for i1 := 1 to wallptr do
	  with cave[wallstk[i1].y,wallstk[i1].x] do
	    if (fval = 9) then
	      begin
		if (randint(100) < dun_tun_pen) then
		  place_door(wallstk[i1].y,wallstk[i1].x)
		else
		  begin
		    fval  := corr_floor2.ftval;
		    fopen := corr_floor2.ftopen;
		  end;
	      end;
      end;


	{ Places door at y,x position if at least 2 walls found	}
    procedure try_door(y,x : integer);

      function next_to(y,x : integer) : boolean;
	begin
	  if (next_to8(y,x,[4,5,6]) > 2) then
	    if ((cave[y-1,x].fval in wall_set) and 
		(cave[y+1,x].fval in wall_set)) then
	      next_to := true
	    else if ((cave[y,x-1].fval in wall_set) and 
		     (cave[y,x+1].fval in wall_set)) then
	      next_to := true
	    else
	      next_to := false
	  else
	    next_to := false
	end;

      begin
	if (randint(100) > dun_tun_jct) then
	  if (cave[y,x].fval = corr_floor1.ftval) then
	    if (next_to(y,x)) then
	      place_door(y,x);
      end;


	{ Cave logic flow for generation of new dungeon		}
    procedure cave_gen;
      type
	spot_type = record
		endx	: integer;
		endy	: integer;
	end;
	room_type = array [1..20,1..20] of boolean;
      var
	room_map		: room_type;
	i1,i2,i3,i4		: integer;
	y1,x1,y2,x2		: integer;
	pick1,pick2		: integer;
	row_rooms,col_rooms	: integer;
	alloc_level		: integer;
	yloc			: array [1..400] of worlint;
	xloc			: array [1..400] of worlint;

      begin
        seed := get_seed;
        row_rooms := 2*trunc(cur_height/screen_height);
        col_rooms := 2*trunc(cur_width /screen_width);
        for i1 := 1 to row_rooms do
	  for i2 := 1 to col_rooms do
	    room_map[i1,i2] := false;
        for i1 := 1 to randnor(dun_roo_mea,2) do
	  room_map[randint(row_rooms),randint(col_rooms)] := true;
        i3 := 0;
        for i1 := 1 to row_rooms do
	  for i2 := 1 to col_rooms do
	    if (room_map[i1,i2] = true) then
	      begin
	        i3 := i3 + 1;
	        yloc[i3] := (i1-1)*(quart_height*2 + 1) + quart_height + 1;
	        xloc[i3] := (i2-1)*(quart_width*2  + 1) + quart_width  + 1;
		if (dun_level > randint(dun_unusual)) then
		  case randint(3) of
		    1 : build_type1(yloc[i3],xloc[i3]);
		    2 : build_type2(yloc[i3],xloc[i3]);
		    3 : build_type3(yloc[i3],xloc[i3]);
		  end
		else
	          build_room(yloc[i3],xloc[i3]);
	      end;
        for i4 := 1 to i3 do
	  begin
	    pick1 := randint(i3);
	    pick2 := randint(i3);
	    y1 := yloc[pick1];
	    x1 := xloc[pick1];
	    yloc[pick1] := yloc[pick2];
	    xloc[pick1] := xloc[pick2];
	    yloc[pick2] := y1;
	    xloc[pick2] := x1
	  end;
	doorptr := 0;
        for i4 := 1 to i3-1 do
	  begin
	    y1 := yloc[i4];
	    x1 := xloc[i4];
	    y2 := yloc[i4+1];
	    x2 := xloc[i4+1];
	    tunnel(y2,x2,y1,x1)
	  end;
        fill_cave(rock_wall1);
	for i1 := 1 to dun_str_mag do
	  place_streamer(rock_wall2,dun_str_mc);
	for i1 := 1 to dun_str_qua do
	  place_streamer(rock_wall3,dun_str_qc);
	place_boundry;
	all_the_river_stuff;
	for i1 := 1 to dun_pools do
	  place_pool(water1);
		{ Place intersection doors	}
	for i1 := 1 to doorptr do
	  begin
	    try_door(doorstk[i1].y,doorstk[i1].x-1);
	    try_door(doorstk[i1].y,doorstk[i1].x+1);
	    try_door(doorstk[i1].y-1,doorstk[i1].x);
	    try_door(doorstk[i1].y+1,doorstk[i1].x);
	  end;
	alloc_level := trunc(dun_level/3);
	if (alloc_level < 2) then
	  alloc_level := 2
	else if (alloc_level > 10) then
	  alloc_level := 10;
	place_stairs(up_staircase,randint(2),3);
	place_stairs(down_staircase,randint(2)+2,3);
	place_stairs(up_steep_staircase,1,3);
	place_stairs(down_steep_staircase,1,3);
	alloc_land_monster([1,2],(randint(8)+min_malloc_level+alloc_level),0,true,false);
	alloc_land_monster([16,17,18],(randint(8)+min_malloc_level+alloc_level) div 3,0,true,true);
	alloc_object([4],3,randint(alloc_level));
	alloc_object([1,2],5,randnor(treas_room_alloc,3));
	alloc_object([1,2,4],5,randnor(treas_any_alloc,3));
	alloc_object([1,2,4],4,randnor(treas_gold_alloc,3));
	alloc_object([1,2,4],1,randint(alloc_level));
	if (dun_level >= win_mon_appear) then place_win_monster;
      end;


    procedure town_gen;

      var
	y,x			: integer;
	i1,i2,i3,i4,i5,num	: integer;
	rooms			: array [0..35] of integer;
	roomdone		: array [0..35] of boolean;
	center			: integer;
	out_val			: vtype;

	{ Builds a building at a row,column coordinate, and	}
	{ set up the initial contents by setting p1 to		}
	{ whatever inside type is desired			}
     procedure build_store(store_num,where : integer);
      var
		yval,y_height,y_depth	: integer;
		xval,x_left,x_right	: integer;
		i1,i2,cur_pos,house_type,i3	: integer;
		old_seed		: unsigned;
      procedure make_door(y,x : integer);
       begin
	with cave[y,x] do
	  begin
	    fval  := corr_floor3.ftval;
	    fopen := corr_floor3.ftopen;
	    popt(cur_pos);
	    tptr := cur_pos;
	    if (store_num <= tot_stores) then
	      t_list[cur_pos] := store_door[store_num]
	    else
	      t_list[cur_pos] := store_door[tot_stores+1];
	  end;
	mini_sleep(5);
	old_seed := seed;
	seed := get_seed;
	if (store_num > tot_stores) then
	 with t_list[cur_pos] do
	  case house_type of
	    1 : p1 := 8 + randint(4);
	    2 : p1 := randint(10);
	    3 : p1 := 3 + randint(6);
	    4 : p1 := randint(7);
	    5 : p1 := 1;
	    otherwise ;
	  end; 
	seed := old_seed;
       end;

{ for castle--changes all in both lines of symmetry }
      procedure dr_castle(dy,dx : integer; ft : floor_type);
	var t : integer;
	begin
	  dx := abs(dx);
	  dy := abs(dy);
	  repeat
	    dy := -dy;
	    if (dy <= 0) then
		dx := -dx;
	    cave[yval+dy,xval+dx].fopen := ft.ftopen;
	    cave[yval+dy,xval+dx].fval := ft.ftval;
	  until ((dy >= 0) and (dx >= 0));
	end;

      procedure blank_square(dy,dx : integer);
	begin
	  cave[yval+dy,xval+dx].fopen := dopen_floor.ftopen;
	  cave[yval+dy,xval+dx].fval := dopen_floor.ftval;
	end;

      begin
	yval := 10*(where div 9)+6;
	xval := 14*(where mod 9)+11;
	if (store_num > tot_stores) then
	  house_type := store_num - tot_stores
	else
	  house_type := 0;
	if ((house_type = 1) or (house_type = 3)) then
	    begin
		y_height := yval - 1 - randint(2);
		y_depth  := yval + 1 + randint(3);
		x_left   := xval - 1 - randint(4);
		x_right  := xval + 2 + randint(3);
	    end
	else if (house_type = 2) then
	    begin
		yval := yval - 2 + randint(3);
		xval := xval - 3 + randint(4);
		y_height := yval - randint(2);
		y_depth := yval + randint(3);
		x_left := xval - randint(3);
		x_right := xval + randint(4);
	    end
	else if (house_type = 5) then
	    begin
	      yval := yval + 5;
	      y_height := yval - 3;
	      y_depth := yval + 3;
	      x_left := xval - 5;
	      x_right := xval + 5;
	    end
	else
	    begin
		y_height := yval - 3;
		y_depth := yval + 3;
		x_left := xval - 5;
		x_right := xval + 5;
	    end;
	for i1 := y_height to y_depth do
	  for i2 := x_left to x_right do
	    begin
		cave[i1,i2].fval := boundry_wall.ftval;
		cave[i1,i2].fopen := boundry_wall.ftopen;
	    end;
	if (house_type = 4) then
	  for i2 := x_left to x_right do
	    begin
		cave[yval,i2].fval := dopen_floor.ftval;
		cave[yval,i2].fopen := dopen_floor.ftopen;
	    end;
	if (house_type = 5) then
	  begin
	dr_castle(0,5,water1); dr_castle(1,5,water1); dr_castle(1,6,water1);
	dr_castle(2,6,water1); dr_castle(2,7,water1); dr_castle(3,7,water1);
	dr_castle(4,7,water1); dr_castle(4,6,water1); dr_castle(5,6,water1);
	dr_castle(5,5,water1); dr_castle(5,4,water1); dr_castle(5,3,water1);
	dr_castle(4,3,water1); dr_castle(4,2,water1); dr_castle(3,2,water1);
dr_castle(3,1,water1); dr_castle(3,0,water1); dr_castle(3,6,boundry_wall);
dr_castle(4,5,boundry_wall);dr_castle(4,4,boundry_wall);
	  end;
	if (house_type = 3) then
	 begin
	  make_door(y_height,xval-2+randint(4));
	  make_door(y_depth,xval-2+randint(4));
	  make_door(yval-2+randint(3),x_left);
	  make_door(yval-2+randint(3),x_right);
	 end
	else if (house_type = 4) then
	 begin
	   make_door(yval-1,xval-4);
	   make_door(yval+1,xval-4);
	   make_door(yval-1,xval+4);
	   make_door(yval+1,xval+4);
	   make_door(yval-1,xval);
	   make_door(yval+1,xval);
	 end
	else if (house_type = 5) then
	 begin
	   i1 := 2*randint(2)-3;
	   make_door(yval+2*i1,xval-1);
	   make_door(yval+2*i1,xval);
	   make_door(yval+2*i1,xval+1);
	   blank_square(3*i1,-1);
	   blank_square(3*i1,0);
	   blank_square(3*i1,1);
	 end	  
	else
	 begin
	  case randint(4) of
	   1 : begin
		i1 := randint(y_depth-y_height) + y_height - 1;
		i2 := x_left;
	       end;
	   2 : begin
		i1 := randint(y_depth-y_height) + y_height - 1;
		i2 := x_right;
	       end;
	   3 : begin
		i1 := y_depth;
		i2 := randint(x_right-x_left) + x_left - 1;
	       end;
	   4 : begin
		i1 := y_height;
		i2 := randint(x_right-x_left) + x_left - 1;
	       end
	  end;
	  make_door(i1,i2);
	 end
      end;

    procedure build_house(house_num,where : integer);
      begin
	build_store(house_num+tot_stores,where);
      end;

	{ Build a fountain at row, column coordinate	-dmf-	}
    procedure build_fountain (where : integer);
      var
		yval,y_height,y_depth	: integer;
		xval,x_left,x_right	: integer;
		i1,i2,cur_pos		: integer;
		count			: integer;
		flr			: array [1..35] of integer;
		old_seed		: unsigned;
      begin
	yval := 10*(where div 9)+4+randint(3);
	xval := 14*(where mod 9)+9+randint(3);
	for i1 := 1 to 35 do
	  flr[i1] := 2;
	flr[1] := 1;
	flr[7] := 1;
	for i1 := 10 to 12 do
	  flr[i1] := 3;
	for i1 := 16 to 17 do
	  flr[i1] := 3;
	for i1 := 19 to 20 do
	  flr[i1] := 3;
	for i1 := 24 to 26 do
	  flr[i1] := 3;
	flr[29] := 1;
	flr[35] := 1;
	y_height:= yval - 2;
	y_depth	:= yval + 2;
	x_left	:= xval - 3;
	x_right	:= xval + 3;
	count := 0;
	repeat
	  i1 := randint(35);
	until (flr[i1] = 2) and (i1 <> 18);
	flr[i1] := 4;
	for i1 := y_height to y_depth do
	  for i2 := x_left to x_right do
	    begin
	      count := count + 1;
	      case flr[count] of
		1 : begin
		      cave[i1,i2].fval := dopen_floor.ftval;
		      cave[i1,i2].fopen := dopen_floor.ftopen;
		    end;
		2 : begin
		      cave[i1,i2].fval := boundry_wall.ftval;
		      cave[i1,i2].fopen := boundry_wall.ftopen;
		    end;
		3 : begin
		      cave[i1,i2].fval := water1.ftval;
		      cave[i1,i2].fopen := water1.ftopen;
		      mini_sleep(5);
		      old_seed := seed;
		      seed := get_seed;
		      if (randint(12) = 1) then place_gold(i1,i2);
		      seed := old_seed;
		    end;
		4 : begin
		      cave[i1,i2].fval := rock_wall2.ftval;
		      cave[i1,i2].fopen := rock_wall2.ftopen;
		    end;
	      end;
	    end;
      end;

{ randomize array[0..num-1] }
      procedure mixem(num : integer);
	var i1,i2,i3 : integer;
	begin
	 for i1 := 0 to num-1 do
	  begin
	    i2 := i1-1+randint(num-i1);
	    i3 := rooms[i1];
	    rooms[i1] := rooms[i2];
	    rooms[i2] := i3;
	  end;
	end;


	{ Town logic flow for generation of new town		}

     begin {town_gen}
	seed := town_seed;
	for i1 := 0 to 35 do
	    roomdone[i1] := false;
	center := 10 + randint(5);
	i3 := 0;
	for i1 := -2 to 2 do
	  for i2 := -1 to 2 do
	    if (((i1<2) and (i1>-2)) or ((i2>-1) and (i2<2))) then
	      begin
		roomdone[center+i1+i2*9] := true;
		if ((i1<>0) or (i2=-1) or (i2=2)) then	{not castle}
		  begin
		    rooms[i3] := center+i1+i2*9;
		    i3 := i3 + 1;
		  end;
	      end;
	mixem(i3);
	build_store(4,rooms[0]);
	build_store(5,rooms[1]);
	build_store(6,rooms[2]);
	build_store(9,rooms[3]);
	build_store(10,rooms[4]);
	build_store(11,rooms[5]);
	build_store(13,rooms[6]);
	build_store(17,rooms[7]);
	build_fountain(rooms[8]);
	build_fountain(rooms[9]);
	for i1 := 1 to max_house1 do
	  build_house(1,rooms[9+i1]);
	i3 := 0;
	for i1 := 0 to 35 do
	  if (not roomdone[i1]) then
	    begin
	      rooms[i3] := i1;
	      i3 := i3 + 1;
	    end;
	mixem(i3);
	build_store(1,rooms[0]);
	build_store(2,rooms[1]);
	build_store(3,rooms[2]);
	build_store(7,rooms[3]);
	build_store(8,rooms[4]);
	build_store(15,rooms[5]);
	build_store(16,rooms[6]);
	build_fountain(rooms[8]);
	build_fountain(rooms[9]);
	build_house(4,rooms[10]);
	for i1 := 1 to max_house2 do
	  build_house(2,rooms[10+i1]);
	fill_cave(dopen_floor);
	repeat
	  i1 := randint(4);
	  i2 := randint(4);
	until (i1 <> i2);
	place_boundry;
	if ((py.misc.cur_age.hour > 17) or (py.misc.cur_age.hour < 6)) then
	  begin		{ Night	}
	    mugging_chance := night_mugging;
	    for i1 := 1 to cur_height do
	      for i2 := 1 to cur_width do
		if (cave[i1,i2].fval <> dopen_floor.ftval) then
		  cave[i1,i2].pl := true;
	    place_stairs(down_staircase,2,0);
	    place_stairs(down_steep_staircase,1,0);
	    seed := get_seed;
	    alloc_land_monster([1,2],min_malloc_tn,3,true,false);
	    alloc_land_monster([16,17,18],7,0,true,true);
	    store_maint;
	  end
	else
	  begin		{ Day	}
	    mugging_chance := day_mugging;
            for i1 := 1 to cur_height do
	      for i2 := 1 to cur_width do
	        cave[i1,i2].pl := true;
	    place_stairs(down_staircase,2,0);
	    place_stairs(down_steep_staircase,1,0);
	    seed := get_seed;
	    alloc_land_monster([1,2],min_malloc_td,3,true,false);
	    alloc_land_monster([16,17,18],7,0,true,true);
	    store_maint;
	  end;
      end;


    begin
      panel_row_min	:= 0;
      panel_row_max	:= 0;
      panel_col_min	:= 0;
      panel_col_max	:= 0;
      char_row		:= -1;
      char_col		:= -1;

      tlink;
      mlink;
      blank_cave;

      if (dun_level = 0) then
	begin
	  cur_height := screen_height * 2;
	  cur_width  := screen_width * 2;
	  max_panel_rows := trunc(cur_height/screen_height)*2 - 2;
	  max_panel_cols := trunc(cur_width /screen_width )*2 - 2;
	  panel_row := 0;
	  panel_col := 0;
	  town_gen;
	end
      else
	begin
	  cur_height := max_height;
	  cur_width  := max_width;
	  max_panel_rows := trunc(cur_height/screen_height)*2 - 2;
	  max_panel_cols := trunc(cur_width /screen_width )*2 - 2;
	  panel_row := max_panel_rows;
	  panel_col := max_panel_cols;
	  cave_gen
	end;
    end;

End.
