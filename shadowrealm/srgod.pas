[inherit
('srinit','srsys','srio','srother','srop','srgodact','srcom','srmove',
 'srtime','srmisc','sys$library:starlet')]

program srgod(input,output);
const
  silly_name_max = 138;
var
  range:array[1..maxmonsters,1..maxnaturalweapon] of integer;

  silly_name:array[1..silly_name_max] of tinystring := (
'Agroth','Agrit','Atamut','Ali Baba','Arnold','Aluzin','Aarg','Agmeish',
'Buster','Boozer','Brent','Bugzool','Butch','Barhirin','Broog','Bidmog',
'Buffy','Bonkme',
'Chadwik','Chuck','Chimlick','Cheuk','Chumliz','Carbanor','Canawok',
'Cordread','Cirith','Claus',
'Droog','Dirk','Daldy','Denowet','Draka','Dum dum','Dimwit','Dumbo','Dan',
'Elvis','Ecthel','Eneroth','Elethil','Eugumoot','Eleduin','Egor',
'Feanor','Farglatz','Farging','Fletch','Friggit',
'Gothmog','Grondin','Gagleous','Grog','Gerland','Ginreth',
'Gruziha',
'Herbruk','Halwath','Helmut','Hercimer','Howarmuk','Henkhelm','Krunk',
'Ingwe','Ingrish',
'Jerluk','Jabbalop','Jocko','Jeth','Junga','Jinga','Jimba','Jill',
'Krotche','Kunta','Killroy','Kaputa','Kuch','Kumquat','Kurgan','Khadaffy',
'Krazool',
'Lenin','Leonard','Leo','Lear','Louie','Lister','Larendil','Loketary',
'Muarasah','Morgoth','Mugwump','Melmen','Masnads','Mrokbut',
'Milknrou','Mybalon','Mordy',
'Nadien','Nupit',
'Opie','Orgrond','Orville','Ogden','Orion','Oloof',
'Pharelen','Pogo','Pfzarrak','Poofley','Proklmt',
'Rellinger','Rhunwik','Rugrat','Retred','Rocky','Rhygon','Rejuon',
'Rogundin','Roxanne',
'Scarythe','Smegma','Spunk','Sindar','Sarek','Swatme','Swishme',
'Telemcus','Talyrand','Turin','Tymeup',
'Vethrax','Vermouth','Whacker','Wonkme','Wog','Whipme');

[ASYNCHRONOUS] FUNCTION lib$getjpi (
	item_code : INTEGER;
	VAR process_id : [VOLATILE] UNSIGNED := %IMMED 0;
	process_name : [CLASS_S] PACKED ARRAY [$l3..$u3:INTEGER] OF CHAR := %IMMED 0;
	%REF resultant_value : [VOLATILE,UNSAFE] ARRAY [$l4..$u4:INTEGER] OF $UBYTE := %IMMED 0;
	VAR resultant_string : [CLASS_S,VOLATILE] PACKED ARRAY [$l5..$u5:INTEGER] OF CHAR := %IMMED 0;
	VAR resultant_length : [VOLATILE] $UWORD := %IMMED 0) : INTEGER; EXTERNAL;

[ASYNCHRONOUS] FUNCTION lib$init_timer (
	VAR context : [VOLATILE] UNSIGNED := %IMMED 0) : INTEGER; EXTERNAL;

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

[external,asynchronous]
procedure cli$get_value(entity_desc:string; retdesc:string; len:unsigned);
external;

[global]
function getkey(key_mode:integer := 0):char;
begin
  getkey := '.';
end;

function room_number:integer;
var
  process_name:packed array[1..15] of char;
  len:$uword := 0;                         
begin
  sysstatus := lib$getjpi(jpi$_prcnam,,,,process_name,len);
  room_number := number(substr(process_name,1,index(process_name,' ')));
end;

function setup_things:boolean;
var
  dummy_channel:$uword;
begin
  here.valid := room_number;
  seed := clock;
  human := false;
  lib$init_timer(timercontext); 
  openfiles;
  if debug then rewrite(outfile);
  %include 'root:srclass.pas';
  tickerquick := getticks;
  tickernormal := getticks;
  tickerslow := getticks;
  privlevel := 0;
  forget_all;
  readnames;
  readindexes;
  readints;
  interactive := true;
  getroom(here.valid);
  if assign_channel(here.mbx,dummy_channel) then
  begin
writeln('Did assign channel to this room''s mailbox!!!');
    freeroom;
    setup_things := false
  end
  else
  begin
    bug_out('Could not assign channel to this room :)');
    setup_things := true;
    here.mbx := substr(mymbx,1,20);
    putroom;
writeln('Did not assign channel to this room.  Assigning channels to other.');
    assign_channels;
  end;
end;

[asynchronous,global]
procedure possess_someone(log:integer := 0);
var
  i,j:integer := 1;
  found:boolean := false;
  new_monster:boolean;
  s:string;

  function free_slot:boolean;
  var
    ii:integer := 1;
    found:boolean := false;
  begin
    while (ii <= maxmonsters) and (not found) do
    if pl[ii].sts[ps_dead].on then
    begin
      now := ii;
      found := true;
    end
    else ii := ii + 1;
    free_slot := found;
  end;

  procedure select_race;
  var
    i,j:integer := 0;
    ok:boolean := false;
  begin
    repeat
      j := j + 1;
      i := rnum(indx[i_race].top);
      getrace(i);
      freerace;
      if (race.attrib[at_points] <= here.level) and
	(indx[i_race].on[i]) then ok := true;
    until ok or (j > 50);
    player.attrib_ex[st_race] := i;
  end;

  procedure select_class;
  var
    i,j:integer := 0;
    ok:boolean := false;
  begin
    repeat
      j := j + 1;
      i := rnum(maxclass);
      if (class[i].attrib[at_points] <= here.level) and
	 (class_name[i] <> '') then ok := true;
    until ok or (j > 50);
    player.attrib_ex[st_class] := i;
  end;

  procedure possess_prime;
  var
    ii:integer;
  begin
    found := true;
    monsters_active := monsters_active + 1;
    getindex(i_ingame);
    indx[i_ingame].on[log] := true;
    putindex(i_ingame);
    getint(n_location);
    an_int[n_location].int[log] := here.valid;
    putint(n_location);
    getplayer(log);
    if new_monster then
    begin
      select_race;
      select_class;
      getname(na_player);
      i := 1;
      repeat
        i := i + 1;
	s := silly_name[rnum(silly_name_max)] + ' the ' +
	name[na_race].id[player.attrib_ex[st_race]];
      until (length(s) <= shortlen) or (i = 200);
      if length(s) <= shortlen then name[na_player].id[log] := s
      else name[na_player].id[log] := name[na_race].id[player.attrib_ex[st_race]];
      putname(na_player);
      for ii := 1 to at_max do player.attrib[ii] := 0;
      for ii := 1 to maxspell do
      if (rnum(100) < ln(here.level)) and (indx[i_spell].on[ii]) then
      begin
        getspell(ii);
        freespell;
        if not (spell.element in [el_self,el_weapon,el_missile]) then
	player.spell[ii] := true
        else player.spell[ii] := false;
      end
      else player.spell[ii] := false;
      for ii := 1 to el_max do player.proficiency[ii] := round(ln(here.level));
{---here add special bonus stats to monsters based on dungeon level---}
      player.attrib[at_health] := here.level;
      player.attrib_max[at_health] := here.level;
      if rnum(4) = 1 then player.attrib[at_points] := round(10*ln(here.level))
      else player.attrib[at_points] := 0;
{---------------------------------------------------------------------}
      player.attrib_ex[st_kills] := 1;
      player.attrib_ex[st_experience] := 7;
      player.attrib_ex[st_killed] := 1;
    end;
    player.sts[ps_dead].on := false;
    player.where.r := here.valid;
    free_space(player.where.x,player.where.y);
    putplayer;
    pl[now] := player;
    plr[now].log := log;
    plr[now].npc := true;
    plr[now].awake := 0;
    plr[now].dest.mission := mission_none;
    plr[now].dest.x := 0;
    plr[now].dest.y := 0;
    for ii := 1 to maxthoughts do
    begin
      plr[now].friend[ii] := 0;
      with plr[now].target[ii] do
      begin
	log := 0;
	hits := 0;
	damage := 0;
      end;
    end;
    person[log].here := true;
    person[log].alive := true;
    stats;
    for ii := 1 to maxnaturalweapon do
    if plr[now].n_weapon[ii] <> 0 then
    begin
      getspell(plr[now].n_weapon[ii]);
      freespell;
      range[now,ii] := (pl[now].proficiency[spell.element] * spell.parm[4]) div
      100;
    end
    else range[now,ii] := 0;
    if new_monster then pl[now].attrib[at_health] := pl[now].attrib_max[at_health];
    if monsters_active > 1 then enter_room(pl[now].where,,,true,true)
    else enter_room(pl[now].where);
  end;

begin
  new_monster := (log = 0);
  if free_slot then
  begin
    if (log <> 0) then
    begin
      if indx[i_npc].on[log] then possess_prime;
    end
    else
    begin
      log := 1;
      getindex(i_ingame);
      freeindex;
      while (log <= maxplayers) and (not found) do
      if (not indx[i_ingame].on[log]) and
	(indx[i_player].on[log]) and
	(indx[i_npc].on[log]) then possess_prime
      else log := log + 1;
    end;
  end
  else act_out(0,e_msg,,,,,,,'There are no free npc slots left.')
end;

procedure ping_all;
var
  dummy:array[1..maxplayers] of boolean;
  i:integer;
begin
{If we get a e_pong before we're through setting person[].here := false,
 it's gonna ping 'em...}
  act_out(0,e_ping,0,mychannel);
  for i := 1 to maxplayers do
  begin
    if person[i].here then writeln('People here: ',name[na_player].id[i],'.');
    dummy[i] := person[i].here;
    person[i].here := false;
  end;
  wait(10);
  for i := 1 to maxplayers do
  if (not person[i].here) and dummy[i] then
  begin
    writeln('Removing player ',name[na_player].id[i],'.');
    remove_player(i,,false);
  end;
end;

procedure monitor_room;
begin
  ping_all;
  possess_someone;
  if empty_room then
  begin
    writeln('Empty room in monitor_room');
    all_done := true;
  end;
end;

procedure control;
var
  i,slot:integer;

  function find_friend:boolean;
  var
    i:integer;
  begin
    slot := 0;
    for i := 1 to maxthoughts do
    if plr[now].friend[i] <> 0 then slot := i;
    find_friend := (slot <> 0);
  end;

  function know_spell(var spellnum:integer; offensive:boolean := true):boolean;
  var
    i:integer := 1;
    done:boolean := false;
  begin
    while (i < maxspell * 5) and (not done) do
    begin
      spellnum := rnum(maxspell);
      if pl[now].spell[spellnum] and
      (indx[i_offense].on[spellnum] = offensive) then done := true
      else i := i + 1;
    end;
    know_spell := done;
  end;

  procedure npc_equip;
  var
    i,obj_slot:integer := 0;
  begin
    for i := 1 to maxhold do
    if (not pl[now].equipped[i]) and (pl[now].equipment[i].num <> 0) then
    obj_slot := i;
    do_equip(obj_slot);
  end;

  procedure attack_enemy;

    function npc_attack:boolean;
    var
      weapon_slot:integer;
    begin
      npc_attack := false;
      if (plr[now].weapon <> 0) and
	(plr[now].range > 0) and
	in_range(
	person[plr[now].target[slot].log].loc.x,
	person[plr[now].target[slot].log].loc.y,
	plr[now].range) then
	npc_attack := do_cast(plr[now].weapon,true)
      else
      begin
	weapon_slot := select_weapon;
	if weapon_slot <> 0 then
	if in_range(person[plr[now].target[slot].log].loc.x,
	person[plr[now].target[slot].log].loc.y,
	range[now,weapon_slot]) and (range[now,weapon_slot] > 0) then
	npc_attack := do_attack;
      end;
    end;

    function npc_spell:boolean;
    var
      sn:integer;
    begin
      if know_spell(sn,true) then npc_spell := do_cast(sn)
      else npc_spell := false;
    end;

  begin
    if not npc_attack then
    if not npc_spell then
    follow(person[plr[now].target[slot].log].loc.x,
	person[plr[now].target[slot].log].loc.y);
  end;

  procedure be_nice;
  begin
    follow(person[plr[now].friend[slot]].loc.x,
    person[plr[now].friend[slot]].loc.y);
  end;

  function valid_destination(proper_mission:integer):boolean;
  begin
    with plr[now].dest do
    if (x <> 0) and (y <> 0) and (mission = proper_mission) then
    valid_destination := true
    else valid_destination := false;
  end;

  function low_health:boolean;
  begin
    low_health := false;
    if pl[now].attrib_max[at_health] <> 0 then
    if pl[now].attrib[at_health]/pl[now].attrib_max[at_health] < 0.5 then
    low_health := true;
  end;

  procedure do_mission(mymission:integer);
  var
    fg_slot,x,y:integer;
  begin
    if valid_destination(mymission) then
    begin
      if (plr[now].dest.x = pl[now].where.x) and
	 (plr[now].dest.y = pl[now].where.y) then
      case plr[now].dest.mission of
mission_pray:begin
	       do_pray;
	       plr[now].dest.mission := mission_none;
	       check_room;
	     end;
mission_hide:;
mission_get:begin
	      plr[now].dest.mission := mission_none;
	      do_get;
	      npc_equip;
	      check_room;
	    end;
      end
      else follow(plr[now].dest.x,plr[now].dest.y);
    end
    else
    begin
      case mymission of
mission_pray:
	if is_college then
	begin
	  if foreground_location(fg_college,x,y) then
	  begin
	    plr[now].dest.x := x;
	    plr[now].dest.y := y;
	    plr[now].dest.mission := mission_pray;
	    say_prime('Proudly announces','I am going to college!',snd_audible);
	  end;
	end;
mission_hide:
	if is_hiding then
	begin
	  if foreground_location(fg_normal,x,y) then
	  begin
	    if foreground_found(x,y,0,pl[now].attrib[at_size]+1,fg_normal,fg_slot) then
	    if fg.effect[fg_slot].walk_through then
	    begin
	      plr[now].dest.x := x;
	      plr[now].dest.y := y;
	      plr[now].dest.mission := mission_hide;
	      if low_health then say_prime('Screams',
	      'Help! Help! I''m being repressed!',snd_loud)
	      else say_prime('Whispers','Let''s scram.',snd_normal);
	    end
	    else do_go(rnum(8));
	  end;
	end;
mission_get:
	if is_object then
	begin
	  if object_location(x,y,true) then
	  begin
	    plr[now].dest.x := x;
	    plr[now].dest.y := y;
	    plr[now].dest.mission := mission_get;
	  end;
	end;
      end;
    end;
  end;

  procedure make_enemy;
  var
    i,count:integer := 0;
  begin
    repeat
      count := count + 1;
      i := rnum(maxplayers);
    until (person[i].here and (i <> plr[now].log)) or (count > 500);
    if person[i].here then
    begin
      act_out(plr[now].log,e_challenge,pl[now].where.x,pl[now].where.y,i);
      remember_attack(i,1);
    end;
  end;

  procedure be_yourself;
  var
    saying:array[1..5] of string := (
	'Hello',
	'This is cool',
	'Greetings, mortal.',
	'What''s new?',
	'Booga');
  begin
    if low_health then do_mission(mission_hide)
    else if pl[now].attrib[at_points] > 0 then do_mission(mission_pray)
    else if plr[now].dest.mission <> 0 then do_mission(plr[now].dest.mission)
    else
    case rnum(10000) of
     1..50:do_mission(mission_hide);
    51..55:say_prime('roars',saying[rnum(5)],snd_normal);
   56..150:make_enemy;
 151..2000:do_go(rnum(8));
2001..4000:if plr[now].hands then do_mission(mission_get);
    end;
  end;

begin
  repeat
    if monsters_active > 0 then
    begin
      if (monsters_active < maxmonsters - 3) then possess_someone;
      now := now + 1;
      if now > maxmonsters then
      begin
	now := 1;
	wait((2+maxmonsters-monsters_active)/10);
      end;
      if (not frozen) and not pl[now].sts[ps_dead].on then
      begin
        allacts;
	if low_health then do_mission(mission_hide)
	else if find_enemy(slot) then attack_enemy
	else if find_friend then be_nice
	else be_yourself;
      end;
    end
    else monitor_room;
  until all_done;
end;

procedure setup_randoms;
var
  i:integer;
begin
  writeln('setup_randoms');
  for i := 1 to maxmonsters do
  begin
    pl[i].sts[ps_dead].on := true;
    plr[i].awake := 0;
  end;
  for i := 1 to maxplayers do
  if (indx[i_npc].on[i]) and (indx[i_ingame].on[i]) and
     (an_int[n_location].int[i] = here.valid) and
     (monsters_active <= maxmonsters) then possess_someone(i);
  check_room;
  set_mbx_ast;
end;

procedure save_randoms;
begin
  for now := 1 to maxmonsters do
  if not pl[now].sts[ps_dead].on then save_player;
end;

procedure delete_outfile;
var
  s:string;
begin
  writev(s,'sys$scratch:out_',room_number:0,'.sr');
  lib$delete_file(s);
end;

procedure set_protection;
var
  s:string;
begin
  writev(s,'sys$scratch:out_',room_number:0,'.sr');
  add_acl(s,'(identifier=[mas],access=read+write+execute+delete)');
  add_acl(s,'(identifier=['+srop+'],access=read+write+execute+delete)');
  add_acl(s,'(identifier=[mas$user7],access=read+write+execute+delete)');
end;

begin
  debug := false;
  set_protection;
  if create_mymbx('MASTERBOX') then
  if setup_things then
  begin
    set_protection;
    setup_randoms;
    writeln('Control');
    control;
    deassign_channel(mychannel);
    save_randoms;
    writeln('Save_randoms');
  end
  else writeln('Could not create mailbox');
  delete_outfile;
end.
