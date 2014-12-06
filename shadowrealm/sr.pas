{     
Need extra fparm for element type of hurt foreground

	Program structure:
0	1	2	3	4	5	6
init
init	>sys
init	sys	>io
init	sys	io	>other
init	sys		other	>misc
init	sys		other	>menu
init	sys		other	misc	>move
init	sys	io	other	msc+mnu	>op
init	sys	io	other	misc	move	>com
init	sys	io	other	misc	move	>act
init	sys		other		move	>time
}

[inherit
('srinit','srsys','srio','srother','srop','sract','srcom','srmove',
 'srtime','srmisc','sys$library:starlet')]

program sr(input,output);

[ASYNCHRONOUS] FUNCTION lib$cvt_from_internal_time (
	operation : UNSIGNED;
	VAR resultant_time : [VOLATILE] UNSIGNED;
	input_time : $UQUAD := %IMMED 0) : INTEGER; EXTERNAL;

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

[ASYNCHRONOUS] FUNCTION smg$end_pasteboard_update (
	pasteboard_id : UNSIGNED) : INTEGER; EXTERNAL;
 
[ASYNCHRONOUS] FUNCTION smg$begin_pasteboard_update (
	pasteboard_id : UNSIGNED) : INTEGER; EXTERNAL;

[ASYNCHRONOUS] FUNCTION smg$repaint_screen (
	pasteboard_id : UNSIGNED) : INTEGER; EXTERNAL;
 
[global]
function getkey(key_mode:integer := 0):char;
forward;

procedure show_status;
var
  s:string;
  i,n:integer;
begin
  if get_name(name[na_player].id,'Stats on who',n) then
  with person[n] do
  begin
    x_label(name[na_player].id[n]+'''s stats');
    purge_x;
    add_x('room    '+name[na_room].id[an_int[n_location].int[n]]);
    add_x('x loc   '+int(loc.x));
    add_x('y loc   '+int(loc.y));
    add_x('feet    '+int(feet));
    add_x('head    '+int(head));
    add_x('here    '+boo(here));
    add_x('alive   '+boo(alive));
    add_x('channel '+int(channel));
    draw_x;
    for i := 1 to at_max do
    act_out(plr[now].log,e_req_status,,,n,i,,,,,,person[n].channel);
  end;
end;

function revive_player:boolean;
var
  i:integer := 0;
  s:string;
  passed:boolean := false;
begin
  wl('Attempting to revive your old bones...');
  if (op_userid < op_userid(name[na_user].id[plr[now].log])) then
  revive_player := true
  else if (lowcase(get_userid) <> name[na_user].id[plr[now].log]) then
  begin
    wl('A voice thunders from above!');
    repeat
      grab_line('What''s the password! ',s,,false);
      passed := (lowcase(player.password) = lowcase(s));
      i := i + 1;
      if not passed and (i < 3) then wl('Try again.');
    until passed or (i = 3);
    revive_player := passed;
  end
  else revive_player := true;
end;

procedure init_player(playername:string := '');
var
  i,n:integer;
  s:string;

  procedure init_prime;
  begin
    plr[now].log := n;
    wl('Damn glad you could make it.');
    grab_line('Enter a password you will remember:',s,,false);
    if playername = '' then playername := name[na_user].id[plr[now].log];
    getname(na_player);
    name[na_player].id[n] := playername;
    putname(na_player);
    getname(na_user);
    name[na_user].id[plr[now].log] := lowcase(get_userid);
    if checkprivs(10) then
    begin
      grab_line('Username',s);
      if s <> '' then name[na_user].id[plr[now].log] := s;
    end;
    putname(na_user);
    getplayer(plr[now].log);
    player.password:= lowcase(s);
    pl[now].where.r := 1;
    pl[now].where.x := 1;
    pl[now].where.y := 1;
    putplayer;
  end;

begin
  first_time := true;
  if allocate(i_player,n) then init_prime
  else
  begin
    remove_old_player;
    init_prime;
  end;
end;

function setup_character:boolean;
var
  s:string;
  i:integer;
  new_player:boolean;
  myusername:shortstring;
begin
  openfiles;
  %include 'root:srclass.pas';
  tickerquick := getticks;
  tickernormal := getticks;
  tickerslow := getticks;
  myusername := lowcase(get_userid);
  privlevel := min(10,op_userid);
  now := 1;
  forget_all;
  wl;
  wl('Welcome to '+game_name+'!');
  wl('Written by Peter Beaty (maself@ubvms.cc.buffalo.edu).');
  if checkprivs(10) then
    if grab_yes('Enter system? ') then do_system;
  readnames;
  readindexes;
  new_player := not exact_name(na_user,i,myusername);
  plr[now].log := i;
  grab_line('By what name are you known',s);
  setup_character := true;
  if (s = '') and new_player then init_player
  else if s = '' then setup_character := revive_player
  else if lookup(name[na_player].id,s,i) then
  begin
    plr[now].log := i;
    setup_character := revive_player;
  end
  else if new_player then init_player(s)
  else if checkprivs(10) then init_player(s)
  else setup_character := false;
  interactive := true;
end;

procedure enter_realm;
var
  s:string;
begin
  debug := false;
  getplayer(plr[now].log);
  player.mbx := substr(mymbx,1,20);
  putplayer;
  getindex(i_ingame);
  indx[i_ingame].on[plr[now].log] := true;
  putindex(i_ingame);
  assign_channels;
  player_stats;
  stats;
  show_stats;
  act_out(plr[now].log,e_msg,,,,,,,name[na_player].id[plr[now].log]+
	'Has entered the realm.');
  enter_room(pl[now].where);
  set_mbx_ast;
end;

procedure leave_realm;
begin
  wl('Saving game...');
  leave_room('reality');
  act_out(plr[now].log,e_deassign,,,,,,,,,true);
  deassign_channels;
  deassign_channel(mychannel);
  getindex(i_ingame);
  indx[i_ingame].on[plr[now].log] := false;
  putindex(i_ingame);
  sysstatus := lib$cvt_from_internal_time(lib$k_second_of_year,
  %ref pl[now].last_play);
  save_player;
  smg$end_pasteboard_update(pasteboard);
end;

[global]
function handle_key(a_key:$uword; key_mode:integer):boolean;
var
  i,x,y:integer;
  a_loc:loc;
  s:string;

main_help	:array[1..50] of shortstring := (
	'1..9 Keypad Movement',
	'up/dn arrows scroll',
	'5  Go through exit',
	'0  Picks up object',
	'Enter Attacks target',
	',  Target''s health',
	'''  Says something',
	'A  Rebirth',
	'^a Toggle screen',
	'b  player status',
	'B  Brief mode',
	'C  choose class',
	'c  climb',
	'd  drops an object',
	'D  duplicate object',
	'e  equip something',
	'F  Paste foregrounds',
	'^f show fg layers',
	'i  inventory',
	'j  jump up',
	'k  kneel at shrine',
	'K  Known spells',
	'l  look at someone',
	'^l listen for sounds',
	'm  map a foreground',
	'n  change your name',
	'o  open/close a door',
	'O  operator menu',
	'p  set your password',
	'P  players list',
	'^p toggle privs',
	'q  quits',
	'^r refresh screen',
	'r  use something',
	'R  change race',
	's  show stats',
	'S  Scan players',
	't  throw something',
	'T  target someone',
	'u  unequip something',
	'U  unmap foreground',
	'v  set scroll ratio',
	'V  toggle view',
	'w  who list',
	'W  whisper something',
	'^w  set window size',
	'X  show coordinates',
	'x  center yourself',
	'y  yell something',
	'z  zap a spell');

operator_help:array[1..25] of shortstring := (
	'^a activete npc',
	'C  toggle cursor',
	'd  debug mode',
	'D  delete player',
	'e  map text',
	'^e drag char',
	'E  edit something',
	'f  find fg type',
	'i  install foregnds',
	'k  kill someone :)',
	'l L ^l cheat',
	'M  make room, etc',
	'^p respond to poof',
	'p  poof somewhere',
	'q  Quit players',
	'P  disk performance',
	'^r player <> random',
	'r  remote poof',
	's  show plr status',
	'S  enter system',
	'u U ^u set screen',
	'v  center viewport',
	'w  do a whois',
	'^w write foreground',
	'x  poof to target');

  begin
    case key_mode of

0	:
case a_key of
  smg$k_trm_up		:x_up;
  smg$k_trm_down	:x_down;
  otherwise handle_key := true;
end;

key_kind:
begin
  case a_key of
  smg$k_trm_question_mark:
  begin
    wl('f - foreground   o - object    p - player');
    wl('r - race         R - Room      s - spell');
  end;
  smg$k_trm_lowercase_f,
  smg$k_trm_lowercase_o,
  smg$k_trm_lowercase_r,
  smg$k_trm_lowercase_s,
  smg$k_trm_uppercase_r,
  smg$k_trm_lowercase_q:handle_key := true;
  end;
end;

key_get_direction:
begin
  case a_key of
    smg$k_trm_kp2		:a_key := smg$k_trm_two;
    smg$k_trm_kp4		:a_key := smg$k_trm_four;
    smg$k_trm_kp6		:a_key := smg$k_trm_six;
    smg$k_trm_kp8		:a_key := smg$k_trm_eight;
  end;

  case a_key of
    smg$k_trm_two,
    smg$k_trm_four,
    smg$k_trm_six,
    smg$k_trm_eight,
    smg$k_trm_lowercase_n,
    smg$k_trm_uppercase_n,
    smg$k_trm_lowercase_s,
    smg$k_trm_uppercase_s,
    smg$k_trm_lowercase_e,
    smg$k_trm_uppercase_e,
    smg$k_trm_lowercase_w,
    smg$k_trm_uppercase_w	:handle_key := true;
    otherwise handle_key := false;
  end;
end;

key_move_only:
case a_key of
  smg$k_trm_kp1,
  smg$k_trm_one		:do_go(1);
  smg$k_trm_kp2,
  smg$k_trm_two		:do_go(2);
  smg$k_trm_kp3,
  smg$k_trm_three	:do_go(3);
  smg$k_trm_kp4,
  smg$k_trm_four	:do_go(4);
  smg$k_trm_kp5,
  smg$k_trm_five	:do_go(5);
  smg$k_trm_kp6,
  smg$k_trm_six		:do_go(6);
  smg$k_trm_kp7,
  smg$k_trm_seven	:do_go(7);
  smg$k_trm_kp8,
  smg$k_trm_eight	:do_go(8);
  smg$k_trm_kp9,
  smg$k_Trm_nine	:do_go(9);
  smg$k_trm_period,
  smg$k_trm_dot		:handle_key := true;
end;

key_operator:
begin
  case a_key of
  smg$k_trm_ctrla	:if checkprivs(10,true) then
			 act_out(plr[now].log,e_activate);
  smg$k_trm_uppercase_c	:if rnum(2) = 1 then disable_cursor
			 else enable_cursor;
  smg$k_trm_ctrld	:balance_distribution;
  smg$k_trm_lowercase_d	:debug := not debug;
  smg$k_trm_uppercase_d	:if checkprivs(8,true) then
			 if get_name(name[na_player].id,'Player to delete ',i) then
				delete_player(i);
{  smg$k_trm_ctrld	:begin
			   grab_line('DCL command:',s);
			   sysstatus := lib$spawn(s,,'sys$scratch:sr.scratch');
			   typefile('sys$scratch:sr.scratch');
			   sysstatus := lib$delete_file('sys$scratch:sr.scratch');
			 end;}
  smg$k_trm_lowercase_e	:begin
			   grab_line('Text to be mapped',s);
			   for i := pl[now].where.x to
			   min(pl[now].where.x+length(s)-1,here.size.x) do
			   begin
			     here.background[i,pl[now].where.y] :=
			     s[1+i-pl[now].where.x];
			     fix_scenery(i,pl[now].where.y);
			   end;
			 end;
  smg$k_trm_ctrle	:begin
			   grab_line('Character to be dragged',s);
			   if s = '' then drag_char := chr(0)
			   else drag_char := s[1];
			 end;
  smg$k_trm_uppercase_e	:if checkprivs(1,true) then do_custom;
  smg$k_trm_ctrli	:if checkprivs(10,true) then
			 act_out(plr[now].log,e_halt);
  smg$k_trm_uppercase_f	:find_gold;
  smg$k_trm_lowercase_f	:begin
			   grab_num('Foreground kind to find ',i,1,fg_max);
			   if foreground_location(i,x,y) then
			   begin
			     wl(fg_type[i]);
			     show_coordinates(x,y);
			   end;
			 end;
  smg$k_trm_lowercase_h,
  smg$k_trm_question_mark :x_write_array(operator_help,,'Op help');
  smg$k_trm_lowercase_i	:if grab_yes('Overwrite current foregrounds') then
			 install_foregrounds;
  smg$k_trm_lowercase_k	:if checkprivs(10) then
			 if get_name(name[na_player].id,'Kill whom?',i) then
			 if i = plr[now].log then do_die(i)
			 else act_out(plr[now].log,e_kill,i);
  smg$k_trm_lowercase_l	:if checkprivs(8,true) then
			 if get_name(attrib_name,'Attribute Max',i) then
			 grab_num('Max value',pl[now].attrib_max[i]);
  smg$k_trm_uppercase_l	:if checkprivs(8,true) then
			 if get_name(attrib_name,'Attribute Current',i) then
			 grab_num('Current value',pl[now].attrib[i]);
  smg$k_trm_ctrll	:if checkprivs(8,true) then
			 if get_name(element,'Proficiency in',i,,,0) then
			 grab_num('Value',pl[now].proficiency[i]);
  smg$k_trm_uppercase_m	:if checkprivs(8,true) then do_create;
  smg$k_trm_lowercase_p	:if checkprivs(4,true) then do_poof;
  smg$k_trm_uppercase_p	:begin
			   performance := not performance;
			   wl('Disk performance '+boo(performance));
			 end;
  smg$k_trm_ctrlp	:if plr[now].dest.mission in [1..indx[i_room].top] then
			 begin
			   a_loc.r := plr[now].dest.mission;
			   a_loc.x := plr[now].dest.x;
			   a_loc.y := plr[now].dest.y;
			   poof_prime(a_loc);
			 end;
  smg$k_trm_uppercase_q	:if checkprivs(10,true) then
			 if grab_yes('Quit all players?') then
			 begin
			   grab_line('Message?',s);
			   grab_num('Time',i,0,1000,10);
			   if s = '' then writev(s,'You have ',i:0,
			   ' seconds to quit or your game will be halted.');
			   act_out(plr[now].log,e_msg,,,,,,,s,,true);
			   wait(i);
			   act_out(plr[now].log,e_quit,,,,,,,,,true);
			 end;
  smg$k_trm_lowercase_q	:handle_key := true;
  smg$k_trm_ctrlw	:if checkprivs(2,true) then do_save_room;
  smg$k_trm_lowercase_r	:do_remote_poof;
  smg$k_trm_ctrlr	:designate_randoms;
  smg$k_trm_uppercase_s	:if checkprivs(10,true) then do_system;
  smg$k_trm_lowercase_s	:if checkprivs(10,true) then show_status;
  smg$k_trm_lowercase_t	:if checkprivs(8,true) then
			 begin
			   leave_realm;
			   if get_name(name[na_player].id,
			   'Game name to takeover',i) then
			   begin
			     plr[now].log := i;
			     revive_player;
			     enter_realm;
			   end;
			 end;
  smg$k_trm_lowercase_u	:begin
			   vpmaxx := 78;
			   vpmaxy := 22;
			   myvpmaxx := 78;
			   myvpmaxy := 22;
			   smg$begin_pasteboard_update(pasteboard);
			   draw_screen(true);
			 end;
  smg$k_trm_uppercase_u	:begin
			   vpmaxx := 48;
			   vpmaxy := 15;
			   myvpmaxx := 48;
			   myvpmaxy := 15;
			   smg$begin_pasteboard_update(pasteboard);
			   draw_screen(true);
			 end;
  smg$k_trm_ctrlu	:begin
			   vpmaxx := 78;
			   vpmaxy := 15;
			   myvpmaxx := 78;
			   myvpmaxy := 15;
			   smg$begin_pasteboard_update(pasteboard);
			   draw_screen(true);
			 end;
  smg$k_trm_lowercase_w	:if checkprivs(1,true) then do_whois;
  smg$k_trm_lowercase_v	:vp_center;
  smg$k_trm_lowercase_x	:if plr[now].target[1].log <> 0 then
			 if person[plr[now].target[1].log].here then
			 begin
			   a_loc.r := here.valid;
			   a_loc.x := person[plr[now].target[1].log].loc.x;
			   a_loc.y := person[plr[now].target[1].log].loc.y;
			   poof_prime(a_loc);
			 end
			 else wl('That person is not here.')
			 else wl('You must first target someone.');
  end;
  new_prompt('Op>');
end;

key_main:
begin
  handle_key := false;
  case a_key of
  smg$k_trm_up		:x_up;
  smg$k_trm_down	:x_down;
  smg$k_trm_kp0,
  smg$k_trm_zero	:if pl[now].sts[ps_dead].on then wl('Ghosts can''t do that.')
			 else if not plr[now].hands then
			 wl('Your body is not equipped to do that.')
			 else do_get;
  smg$k_trm_kp1,
  smg$k_trm_one		:do_go(1);
  smg$k_trm_kp2,
  smg$k_trm_two		:do_go(2);
  smg$k_trm_kp3,
  smg$k_trm_three	:do_go(3);
  smg$k_trm_kp4,
  smg$k_trm_four	:do_go(4);
  smg$k_trm_kp5,
  smg$k_trm_five	:do_go(5);
  smg$k_trm_kp6,
  smg$k_trm_six		:do_go(6);
  smg$k_trm_kp7,
  smg$k_trm_seven	:do_go(7);
  smg$k_trm_kp8,
  smg$k_trm_eight	:do_go(8);
  smg$k_trm_kp9,
  smg$k_trm_nine	:do_go(9);
  smg$k_trm_space	:if checkprivs(2) then here.background[pl[now].where.x,pl[now].where.y] :=
			 getkey(0);
  smg$k_trm_quote	:do_say('Say: ','says',snd_normal);
  smg$k_trm_comma	:if plr[now].target[1].log = 0 then do_target
			 else if on_screen(person[plr[now].target[1].log].loc.x,
			 person[plr[now].target[1].log].loc.y) then
			 act_out(plr[now].log,e_req_status,,,
			 plr[now].target[1].log,at_health,,,,,,
			 person[plr[now].target[1].log].channel)
			 else wl('I can''t tell from here.');
  smg$k_trm_enter	:if not pl[now].sts[ps_dead].on and (not frozen) then
			 do_attack
			 else if  pl[now].sts[ps_dead].on then wl('You be dead.');
  smg$k_trm_uppercase_a	:if  pl[now].sts[ps_dead].on or checkprivs(10) then do_rebirth
			 else wl('Don''t be silly.');
  smg$k_trm_ctrla	:toggle_full_text(not full_text);
  smg$k_trm_lowercase_b	:show_player_status;
  smg$k_trm_uppercase_b	:do_brief;
  smg$k_trm_lowercase_c	:if not step_up(pl[now].where.x,pl[now].where.y,1,true) then
			 wl('You cannot climb here.');
  smg$k_trm_uppercase_c	:choose_class;
  smg$k_trm_lowercase_d	:if not pl[now].sts[ps_dead].on then do_drop;
  smg$k_trm_uppercase_d	:if checkprivs(2,true) then do_duplicate;
  smg$k_trm_lowercase_e	:if not pl[now].sts[ps_dead].on then do_equip;
  smg$k_trm_uppercase_f	:if checkprivs(2,true) then custom_fg_geometry;
  smg$k_trm_ctrlf	:do_identify;
  smg$k_trm_lowercase_h,
  smg$k_trm_question_mark :x_write_array(main_help,,game_name+' help');
  smg$k_trm_lowercase_i	:do_inventory;
  smg$k_trm_lowercase_j	:if not step_up(pl[now].where.x,pl[now].where.y,
			 2 * pl[now].attrib[at_size],true) then
			 wl('Boing!');
  smg$k_trm_lowercase_k	:if not pl[now].sts[ps_dead].on then do_pray;
  smg$k_trm_uppercase_k	:show_spells;
{  smg$k_trm_ctrlk	:if checkprivs(2) then
		 	begin
			   sysstatus := lib$spawn;
			   smg$repaint_screen(pasteboard);
			 end;}
  smg$k_trm_lowercase_l	:do_look;
  smg$k_trm_uppercase_l	:if checkprivs(2) then do_list;
  smg$k_trm_ctrll	:begin
			   wl('---Listening---');
			   freeze(2);
			   act_out(plr[now].log,e_listen);
			 end;
  smg$k_trm_lowercase_n	:do_name;
  smg$k_trm_lowercase_m	:if checkprivs(2) then
			 if get_name(fg.name,'Foreground to map ',i)
			 then fg_map := i
			 else fg_map := 0;
  smg$k_trm_lowercase_o	:if not pl[now].sts[ps_dead].on then do_open;
  smg$k_trm_uppercase_o	:if checkprivs(1,true) then grab_key('Op> ',key_operator);
  smg$k_trm_lowercase_p	:do_password;
  smg$k_trm_uppercase_p	:do_players;
  smg$k_trm_ctrlp	:do_privs;
  smg$k_trm_lowercase_q	:if grab_yes('Quit forever? ') then handle_key := true;
  smg$k_trm_ctrlr	:smg$repaint_screen(pasteboard);
  smg$k_trm_lowercase_r	:if not pl[now].sts[ps_dead].on then do_use;
  smg$k_trm_uppercase_r	:choose_race;
  smg$k_trm_uppercase_s	:do_scan;
  smg$k_trm_lowercase_s	:show_stats;
  smg$k_trm_uppercase_t	:do_target;
  smg$k_trm_lowercase_t	:if not pl[now].sts[ps_dead].on then do_throw;
  smg$k_trm_lowercase_u	:do_unequip;
  smg$k_trm_uppercase_u	:if checkprivs(2,true) then
			 if get_name(fg.name,'Foreground to unmap ',i) then
			 fg_map := -i
			 else fg_map := 0;
  smg$k_trm_uppercase_v	:do_view;
  smg$k_trm_lowercase_v	:do_scroll;
  smg$k_trm_lowercase_w	:do_who;
  smg$k_trm_uppercase_w	:do_say('Whisper: ','whispers',snd_whisper);
  smg$k_trm_ctrlw	:do_window;
  smg$k_trm_uppercase_x	:show_coordinates(pl[now].where.x,pl[now].where.y);
  smg$k_trm_lowercase_x	:center_me(true);
  smg$k_trm_lowercase_y	:do_say('Yell: ','screams',snd_audible);
  smg$k_trm_lowercase_z	:if not pl[now].sts[ps_dead].on then do_cast;
  end;
  new_prompt('Sr> ');
end;

  end;
end;

{	c_delete	:if checkprivs then do_delete(s);}

function getkey{(key_mode:integer := 0):char};
var
  a_key:$uword;
  gotkey:boolean := false;
begin
  repeat
    a_key := keyget;
    if a_key = smg$k_trm_timeout then
    begin
      if interactive then allacts;
    end
    else gotkey := handle_key(a_key,key_mode);
  until gotkey;
  getkey := chr(a_key);
end;

begin
  if create_mymbx('SHADOWBOX') then
  begin
    setup_display;
    human := true;
    if setup_character then
    begin
      enter_realm;
      getkey(key_main);
      leave_realm;
    end
    else wl('Unable to enter '+game_name+'.');
    remove_display;
  end;
end.
