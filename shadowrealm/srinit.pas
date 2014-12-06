[environment('srinit')]

module srinit;

const
{-----------------------------------------------------------------------------}
{These constants, in addition to a few usernames are all you should need to
 get Shadowrealm up and running on your system.
 The other filename you should modify is SRCOM.PAS, and the procedure
 op_userid contains privileged usernames.}
  srop		= 'MASELF';
		{This is the username corresponding to the "operator" of the
		 game.}
  temp_root	= '$1$dua12:[temp.maself]';
		{This is where temporary stuff is stored.}
  helproot	= '$1$dua12:[temp.maself]';
		{This is the directory where help files and room descriptions
		are placed.}
  root		= '$1$dua12:[temp.maself]';
		{This is the place where the world files are placed.}
  game_node	= 'UBVMSB';
		{This is the node on which the game is running.}
{-----------------------------------------------------------------------------}
  game_name	= 'Shadowrealm';
  short_wait	= 0.05;
  default	= 32000;
  tinylen	= 10;
  shortlen	= 20;
  midlen	= 30;
  normallen	= 80;
  hugelen	= 240;
  quick		= 0.1;
  normal	= 1;
  slow		= 10;
  x_length	= 15;

  bold		= 1;
  reverse	= 2;
  blink		= 4;
  underline	= 8;

  mission_none = 0;
  mission_pray = 1;
  mission_hide = 2;
  mission_get  = 3;

  event_max	= 10;
  maxclass	= 10;
  maxmenu	= 60;
  x_max		= 100;
  maxnaturalweapon = 3;
  maxmonsters	= 10;
  maxthoughts	= 5;
  maxexit	= 4;
  maxindex	= 100;
  maxobjs	= 100;	{# objects allowed in a room}
  maxplayers	= 100;	{# people allowed to play }
  maxspell	= 100;	{# of spells available}
  maxunique	= 5;
  maxhold	= 26;
  maxhoriz	= 132;
  maxvert	= 64;
  maxdesc	= 10;
  maxfg 	= 54;
  fg_layers	= 3;
  obj_layers	= 3;
  maxerr	= 20;
  maxparm	= 20;
  maxcomponent	= 10;
  maxsecondstats= 10;

{Unique stats}
  st_max	= 6;
  st_base	= 1;
  st_kills	= 2;
  st_killed	= 3;
  st_race	= 4;
  st_class	= 5;
  st_experience	= 6;

{directions}
  d_north	= 1;
  d_south	= 2;
  d_east	= 3;
  d_west	= 4;

{event #'s}
  e_msg		= 1;
  e_walkin	= 2;
  e_walkout	= 3;
  e_spell	= 4;
  e_move	= 5;
  e_bump	= 6;
  e_booga	= 7;
  e_get		= 8;
  e_drop	= 9;
  e_place	= 10;
  e_throw	= 11;
  e_assign	= 12;
  e_deassign	= 13;
  e_halt	= 14;
  e_turn_on  	= 15;
  e_turn_off	= 16;
  e_toggle	= 17;
  e_attack	= 18;
  e_died	= 19;
  e_reborn	= 20;
  e_open	= 21;
  e_kill	= 22;
  e_activate	= 23;
  e_ack		= 24;
  e_ping	= 25;
  e_pong	= 26;
  e_remotepoof	= 27;
  e_process	= 28;
  e_spawn	= 29;
  e_can_spawn	= 30;
  e_can_spawn_ack = 31;
  e_quit	= 32;
  e_listen	= 33;
  e_noise	= 34;
  e_possess	= 35;
  e_possess_not = 36;
  e_challenge	= 37;
  e_refuse	= 38;
  e_req_status	= 39;
  e_status	= 40;
  e_disappear	= 41;

{object effects}
  ef_max	= 43;
  ef_points	= 1;
  ef_health	= 2;
  ef_mana	= 3;
  ef_wealth	= 4;
  ef_mv_delay	= 5;
  ef_size	= 6;
  ef_heal_speed = 7;
  ef_mana_speed = 8;
  ef_noise	= 9;
  ef_perception	= 10;
  ef_force	= 11;
  ef_wind	= 12;
  ef_fire	= 13;
  ef_cold	= 14;
  ef_electric	= 15;
  ef_magic	= 16;
  ef_holy	= 17;
  ef_self	= 18;
  ef_weapon	= 19;
  ef_missile	= 20;
  ef_smallest	= 21;
  ef_largest	= 22;
  ef_c_force	= 23;
  ef_m_force	= 24;
  ef_c_wind	= 25;
  ef_m_wind	= 26;
  ef_c_fire	= 27;
  ef_m_fire	= 28;
  ef_c_cold	= 29;
  ef_m_cold	= 30;
  ef_c_electric	= 31;
  ef_m_electric	= 32;
  ef_c_magic	= 33;
  ef_m_magic	= 34;
  ef_c_holy	= 35;
  ef_m_holy	= 36;
  ef_c_self	= 37;
  ef_m_self	= 38;
  ef_c_weapon	= 39;
  ef_m_weapon	= 40;
  ef_c_missile	= 41;
  ef_m_missile	= 42;
  ef_destroy	= 43;

{Damage elements}
  el_max	= 10;
  el_force	= 1;
  el_wind	= 2;
  el_fire	= 3;
  el_cold	= 4;
  el_electric	= 5;
  el_magic	= 6;
  el_holy	= 7;
  el_self	= 8;
  el_weapon	= 9;
  el_missile	= 10;

{Foreground types}
  fg_max	= 18;
  fg_normal	= 1;
  fg_turn_on	= 2;
  fg_turn_off	= 3;
  fg_toggle	= 4;
  fg_sliding	= 5;
  fg_exit	= 6;
  fg_hurt	= 7;
  fg_delay	= 8;
  fg_poison	= 9;
  fg_race	= 10;
  fg_rebirth	= 11;
  fg_nodead	= 12;
  fg_door	= 13;
  fg_class	= 14;
  fg_shop	= 15;
  fg_view	= 16;
  fg_college	= 17;
  fg_no_teleport= 18;

{geometries available}
  g_point	= 1;
  g_line	= 2;
  g_blip	= 3;
  g_rectangle	= 4;
  g_circle	= 5;
  g_face	= 6;

{Indexes}
  i_max		= 8;
  i_player	= 1;
  i_room	= 2;
  i_object	= 3;
  i_race	= 4;
  i_ingame	= 5;
  i_spell	= 6;
  i_npc		= 7;
  i_offense	= 8;

{Key menu's}
  key_main	= 1;
  key_kind	= 2;
  key_move_only = 3;
  key_operator	= 4;
  key_get_direction = 5;

  k_roo		= 1;		{room name}
  k_obj		= 2;		{object name}
  k_pla		= 3;		{player name}
  k_use		= 4;		{user name}
  k_rac		= 5;		{race name}
  k_spe		= 6;		{spell name}
  k_int		= 7;		{integer}
  k_sst		= 8;		{shortstring}
  k_str		= 9;		{string}
  k_dsc		= 10;		{description}
  k_boo		= 11;		{boolean}
  k_ico		= 12;		{icon}
  k_sta		= 13;		{weapon stat}

{Masks}
  m_alive	= 1;
  m_human	= 2;
  m_invisible	= 4;

  m_first_in	= 1;
  m_to_person	= 2;
  m_for_person	= 4;
  m_to_room	= 8;
  m_for_room	= 16;

{arrays of mapped icon stuff}
  map_background= 0;
  map_fg	= 1;
  map_object	= 2;
  map_player	= 3;

{Integers}
  n_max = 2;
  n_location	= 1;
  n_class	= 2;
    
{Names}
  na_max	= 6;
  na_room	= 1;
  na_obj	= 2;
  na_player	= 3;
  na_user	= 4;
  na_race	= 5;
  na_spell	= 6;
  na_foreground	= 7;
  na_fg_type	= 8;
  na_weapon	= 9;
  na_attribute	= 10;
  na_spell_ef	= 11;
  na_elements	= 12;
  na_equipment	= 13;
  na_classes	= 14;

{Object wear slots}
  ow_max	= 19;
  ow_sword	= 1;
  ow_shield	= 2;
  ow_arms	= 3;
  ow_hands	= 4;
  ow_head	= 5;
  ow_neck	= 6;
  ow_back	= 7;
  ow_chest	= 8;
  ow_legs	= 9;
  ow_feet	= 10;
  ow_ring	= 11;
  ow_body	= 12;
  ow_eyes	= 13;
  ow_wrist	= 14;
  ow_waist	= 15;
  ow_backpack	= 16;
  ow_pouch	= 17;
  ow_quiver	= 18;
  ow_wallet	= 19;

{player's status}
ps_max		= 6;
ps_dead		= 1;
ps_poisoned	= 2;
ps_invisible	= 3;
ps_blind	= 4;
ps_speed	= 5;
ps_strength	= 6;

{Room kinds}
  rm_dungeon	= 1;

{Sound ranges}
  snd_audible	= 100;
  snd_loud	= 50;
  snd_normal	= 25;
  snd_quiet	= 10;
  snd_whisper	= 5;

{Spell effects}
  sp_max	= 4;
  sp_hurt	= 1;
  sp_freeze	= 2;
  sp_teleport	= 3;
  sp_invisible	= 4;

{Character statistics}
  at_max	= 10;
  at_points	= 1;
  at_health	= 2;
  at_mana	= 3;
  at_wealth	= 4;
  at_mv_delay	= 5;
  at_size	= 6;
  at_heal_speed = 7;
  at_mana_speed = 8;
  at_noise	= 9;
  at_perception	= 10;

{Current stats - things which change constantly}
  cat_health	= 1;
  cat_mana	= 2;

  w_xwind	= 1;
  w_twind	= 2;
  w_gwind	= 3;
  w_wind	= 4;

type
  counting	= 1..999999;
  whole		= 0..999999;
  string	= varying[normallen] of char;
  strung	= packed array[1..80] of char;
  shortstring	= varying[shortlen] of char;
  tinystring	= varying[tinylen] of char;
  hugestring	= varying[hugelen] of char;

  $deftyp	= [unsafe] integer;
  $defptr	= [unsafe] ^$deftyp;
  $uword	= [word] 0..65535;
  $ubyte	= [byte] 0..255;
  $udata	= varying[240] of char;
  ident		= packed array[1..12] of char;
  lpack		= packed array[1..15] of char;
  mpack         = packed array[1..64] of char;

  timetype = record
    p1,p2:integer;
  end;

  xy = record;
    x,y:integer;
  end;

  iosb_type = record
    io_status: $uword;
    trans: $uword;
    dsi: unsigned;
  end;

  item_list_3 = record
    buf_len: $uword;
    it_code: $uword;
    buf_adr: unsigned;
    len_adr: unsigned;
  end;
 
  actrec = record
    sender,
    action,
    xloc,
    yloc,
    parm1,
    parm2,
    parm3,
    parm4	:integer;
    msg		:$udata;
    note	:$udata;
  end;

  menu_type = record
    choice	:shortstring;
    prompt	:string;
    kind	:integer;
    int_result	:integer;
    str_result	:string;
    boo_result	:boolean;
    min_int	:integer;
    max_int	:integer;
    def_int	:integer;
    help_menu	:integer;
  end;

  uniqueobj = record
    num		:integer;
    condition	:integer;
    parm	:packed array[1..maxunique] of integer;
    mag		:packed array[1..maxunique] of integer;
  end;

  roomobj = record
    object	:uniqueobj;
    icon	:char;
    rendition	:integer;
    base	:integer;
    altitude	:integer;
    loc		:xy;
    hidden	:integer;
  end;

  loc = record
    r,x,y:integer;
  end;

  destrec = record
    x,y,mission:integer;
  end;

  fg_effect = record
    dest	:loc;
    icon	:char;
    rendition	:integer;
    base	:integer;
    altitude	:integer;
    kind	:integer;
    fparm1	:integer;
    fparm2	:integer;
    fparm3	:integer;
    fparm4	:integer;
    dsc		:shortstring;
    on		:boolean;
    walk_through:boolean;
    walk_on	:boolean;
    climb	:boolean;
  end;

  fgrec = record;
    valid	:integer;
    object	:array[1..maxobjs] of roomobj;
    map		:packed array[1..maxhoriz,1..maxvert,1..fg_layers] of 1..maxfg;
    effect	:array[1..maxfg] of fg_effect;
    name	:array[1..maxfg] of shortstring;
  end;

  georec = record
    geometry	:integer;
    geo1	:integer;
    geo2	:integer;
    geo3	:integer;
    geo4	:integer;
  end;

  temp = record;
    on		:boolean;
    time	:integer;
  end;

  armortype = record
    chance	:integer;
    magnitude	:integer;
  end;

  targetrec = record
    log:integer;
    hits:integer;
    damage:integer;
  end;

  playerrec = record;
    valid	:integer;
    mbx		:shortstring;
    password	:shortstring;
    ex_boo3	:boolean;
    where	:loc;
    attrib_max	:array[1..at_max] of integer;
    attrib	:array[1..at_max] of integer;
    attrib_ex	:array[1..st_max] of integer;
    proficiency	:array[1..el_max] of integer;
    sts		:array[1..ps_max] of temp;
    equipment	:array[1..maxhold] of uniqueobj;
    equipped	:array[1..maxhold] of boolean;
    spell	:array[1..maxspell] of boolean;
    ex_str1	:shortstring;
    ex_str2	:shortstring;
    last_play	:integer;
    ex_int2	:integer;
    ex_int3	:integer;
    ex_int4	:integer;
    ex_boo1	:boolean;
    ex_boo2	:boolean;
  end;

  peoplerec = record;
    channel	:$uword;
    loc		:xy;
    feet	:integer;
    head	:integer;
    here	:boolean;
    alive	:boolean;
  end;

  plrrec = record
    npc		:boolean;
    log		:integer;
    awake	:integer;
    target	:array[1..maxthoughts] of targetrec;
    friend	:array[1..maxthoughts] of integer;
    dest	:destrec;
    sound	:string;
    armor	:array[1..el_max] of armortype;
    wear	:array[1..ow_max] of integer;
    weapon	:integer;
    weapon_name	:shortstring;
    range	:integer;
    hands	:boolean;
    n_weapon	:array[1..maxnaturalweapon] of integer;
  end;

  racerec = record
    valid	:integer;
    armor	:array[1..el_max] of armortype;
    proficiency	:array[1..el_max] of integer;
    weapon	:array[1..maxnaturalweapon] of integer;
    attrib	:array[1..at_max] of integer;
    hands	:boolean;
    sound	:string;
    ex_str1	:shortstring;
    ex_str2	:shortstring;
    ex_int1	:integer;
    ex_int2	:integer;
    ex_int3	:integer;
    ex_int4	:integer;
    ex_boo1	:boolean;
    ex_boo2	:boolean;
  end;

  classrec = record
    armor	:array[1..el_max] of armortype;
    proficiency	:array[1..el_max] of integer;
    attrib	:array[1..at_max] of integer;
  end;

  indexrec = record
    valid	:integer;
    on		:packed array[1..maxindex] of boolean;
    top		:integer;
    inuse	:integer;
  end;

  namerec = record
    valid	:integer;
    loctop	:integer;
    id		:array[1..maxindex] of shortstring;
  end;

  intrec = record;
    valid	:integer;
    int		:array[1..maxplayers] of integer;
  end;

  objrec = record;
    valid	:integer;
    icon	:char;
    rendition	:integer;
    wear	:integer;
    size	:integer;
    weight	:integer;
    worth	:integer;
    line_d	:shortstring;
    examine_d	:shortstring;
    get_d	:shortstring;
    use_d	:shortstring;
    howprint	:integer;
    spell	:integer;
    component	:array [1..maxcomponent] of integer;
    parm	:array [1..maxparm] of integer;
    mag		:array [1..maxparm] of integer;
    ex_str1	:shortstring;
    ex_str2	:shortstring;
    ex_int1	:integer;
    ex_int2	:integer;
    ex_int3	:integer;
    ex_int4	:integer;
    ex_boo1	:boolean;
    ex_boo2	:boolean;
  end;

  exitrec = record
    toroom,
    face	:integer;
  end;

  roomrec = record
    valid	:integer;
    level	:integer;
    kind	:integer;
    size	:xy;
    mbx		:shortstring;
    background	:packed array[1..maxhoriz,1..maxvert] of char;
    exit	:array [1..maxexit] of exitrec;
    ex_str1	:shortstring;
    ex_str2	:shortstring;
    ex_int1	:integer;
    ex_int2	:integer;
    ex_int3	:integer;
    ex_int4	:integer;
    ex_boo1	:boolean;
    ex_boo2	:boolean;
  end;

  spellrec = record
    valid	:integer;
    effect	:integer;
    element	:integer;
    caster	:boolean;
    prompt	:boolean;
    icon	:char;
    rendition	:integer;
    geometry	:integer;
    geo1	:integer;
    geo2	:integer;
    parm	:array[1..4] of integer;
    mana	:integer;
    difficulty	:integer;
    castingtime	:integer;
    duration	:integer;
    casterdesc	:shortstring;
    victimdesc	:shortstring;
    ex_str1	:shortstring;
    ex_str2	:shortstring;
    ex_int1	:integer;
    ex_int2	:integer;
    ex_int3	:integer;
    ex_int4	:integer;
    ex_boo1	:boolean;
    ex_boo2	:boolean;
  end;

var
  drag_char	:[volatile] char := chr(0);
  performance	:[volatile] boolean := false;
  brief		:[volatile] boolean := false;
  first_time	:[volatile] boolean := false;
  debug		:[volatile] boolean := false;
  all_done	:[volatile] boolean := false;
  human		:[volatile] boolean := false;
  spawned_out	:[volatile] boolean := false;
  interactive	:boolean := false;
  full_text	:[volatile] boolean := false;
  seed		:[volatile] integer;
  now		:[volatile] integer;
  other_lognum	:[volatile] integer;
  pos		:[volatile] integer;
  wpos		:[volatile] integer := 0;
  x_last	:[volatile] integer;
  x_start	:[volatile] integer;
  x_end		:[volatile] integer;
  myview	:[volatile] integer := 99;
  monsters_active:[volatile] integer := 0;
  tickerquick	:[volatile] integer;
  tickernormal	:[volatile] integer;
  tickerslow	:[volatile] integer;
  fg_map	:[volatile] integer := 0;
  vdoffsetx	:[volatile] integer;	{Offset of the virtual display on screen}
  vdoffsety	:[volatile] integer;
  vpsizex	:[volatile] integer;	{Current size of viewport}
  vpsizey	:[volatile] integer;
  vpoffsetx	:[volatile] integer;	{Offset of viewport in display}
  vpoffsety	:[volatile] integer;
  scrollratio	:[volatile] integer := 5;
  myvpmaxx	:[volatile] integer := 48;{Defined size of viewport}
  myvpmaxy	:[volatile] integer := 15;
  vpmaxx	:[volatile] integer := 48;
  vpmaxy	:[volatile] integer := 15;
  privlevel	:[volatile] integer;
  mc		:integer := 1;
  pid		:integer;
  mywindowx	:integer;
  mywindowy	:integer;

  mychannel	:[volatile] $uword;
  tt_chan	:[volatile] $uword;
  new_key	:[volatile] $uword := 0;

  lasthitstring	:[volatile] string := 'natural causes';
  qpqp		:[volatile] string;
  window_name	:[volatile] string;
  mymbx		:[volatile] mpack;
  old_prompt	:[volatile] string;
  oldcmd	:string;
  line		:string;
  command	:string;

  timercontext	:[volatile] unsigned := 0;
  sysstatus	:[volatile] unsigned;
  pasteboard	:[volatile] unsigned;
  gwind		:[volatile] unsigned;
  twind		:[volatile] unsigned;
  xwind		:[volatile] unsigned;
  ywind		:[volatile] unsigned;
  keyboard	:[volatile] unsigned;
  save_dcl_ctrl	:[volatile] unsigned;

  outfile	:[volatile] text;
  racefile	:[volatile] file of racerec;
  race		:[volatile] racerec;
  playerfile	:[volatile] file of playerrec;
  player	:[volatile] playerrec;
  namefile	:[volatile] file of namerec;
  name		:[volatile] array[1..na_max] of namerec;
  indexfile	:[volatile] file of indexrec;
  indx		:[volatile] array[1..i_max] of indexrec;
  intfile	:[volatile] file of intrec;
  an_int	:[volatile] array[1..n_max] of intrec;
  roomfile	:[volatile] file of roomrec;
  here		:[volatile] roomrec;
  fgfile	:[volatile] file of fgrec;
  fg		:[volatile] fgrec;
  objfile	:[volatile] file of objrec;
  obj		:[volatile] objrec;
  spellfile	:[volatile] file of spellrec;
  spell		:[volatile] spellrec;
  act		:[volatile] actrec;
  pl		:[volatile] array[1..maxmonsters] of playerrec;
  plr		:[volatile] array[1..maxmonsters] of plrrec;
  class		:[volatile] array[1..maxclass] of classrec;
  person	:[volatile] array[1..maxplayers] of peoplerec;
  event		:[volatile] array[1..event_max] of actrec;
  event_time	:[volatile] array[1..event_max] of integer;
  a_menu	:array[1..maxmenu] of menu_type;
  obj_map	:[volatile] packed array[1..maxhoriz,1..maxvert,1..obj_layers] of 1..maxobjs;
  people_map	:[volatile] packed array[1..maxhoriz,1..maxvert] of 1..maxplayers;
  fg_printed	:[volatile] array[1..maxfg] of boolean;
  x_window	:[volatile] array[1..x_max] of varying[30] of char;

  io_status	:[volatile] iosb_type;
  userident	:[global]   ident;
  user,uname	:varying[31] of char;
 
  dir		:[volatile] array[1..6] of tinystring :=
		('north','south','east','west','up','down');

  class_name:[volatile] array[1..maxclass] of shortstring;

  names: array[1..na_max+8] of shortstring := (
	'Room',
	'Object',
	'Player',
	'User',
	'Race',
	'Spell',
	'Foreground names',
	'Foreground types',
	'Weapon stat',
	'Character attributes',
	'Spell effects',
	'Elements',
	'Equipment wear',
	'Classes');

  player_status: array[1..ps_max] of shortstring := (
	'Dead',
	'Poisoned',
	'Invisible',
	'Blind',
	'Speed',
	'Strength');

  stat:[volatile] array[0..ef_max] of shortstring := (
	'None',
	'Points',
	'Health',
	'Mana',
	'Wealth',
	'Move speed',
	'Size',
	'Heal speed',
	'Mana speed',
	'Noise',
	'Perception',
	'Force',
	'Wind',
	'Fire',
	'Cold',
	'Electric',
	'Magic',
	'Holy',
	'Self',
	'Weapon',
	'Missile',
	'Smallest fit',
	'Largest fit',
	'chance mod force',
	'percent mod force',
	'chance mod wind',
	'percent mod wind',
	'chance mod fire',
	'percent mod fire',
	'chance mod cold',
	'percent mod cold',
	'chance mod electric',
	'percent mod electric',
	'chance mod magic',
	'percent mod magic',
	'chance mod holy',
	'percent mod holy',
	'chance mod self',
	'percent mod self',
	'chance mod weapon',
	'percent mod weapon',
	'chance mod missile',
	'percnet mod missile',
	'% chance destroy'
	);

attrib_name:[volatile] array[1..at_max] of shortstring := (
	'Points',
	'Health',
	'Mana',
	'Wealth',
	'Move delay',
	'Size',
	'Heal speed',
	'Mana speed',
	'Noise',
	'Perception');

  attrib_ex_name:[volatile] array[1..st_max] of shortstring := (
	'Base',
	'Kills',
	'Killed',
	'Race',
	'Class',
	'Experience');

  spell_effects:array[0..sp_max] of shortstring := (
	'None',
	'Hurt',
	'Freeze',
	'Teleport',
	'Invisible');

  element:[volatile] array[0..el_max] of shortstring := (
	'Unknown',
	'force',
	'wind',
	'fire',
	'cold',
	'electric',
	'magic',
	'holy',
	'self',
	'weapon',
	'missile');

  fg_type:[volatile] array[0..fg_max] of shortstring := (
	'Empty',
	'Normal',
	'Turn on',
	'Turn off',
	'Toggle',
	'Sliding',
	'Exit',
	'Hurt',
	'Delay',
	'Poison',
	'Race',
	'Rebirth',
	'No dead',
	'Door',
	'Class',
	'Shop',
	'View',
	'College',
	'no teleport');

  equipment:array[0..ow_max] of shortstring := (
	'Not equippable',
	'Sword hand',
	'Shield hand',
	'Arms',
	'Hands',
	'Head',
	'Neck',
	'Back',
	'Chest',
	'Legs',
	'Feet',
	'Ring',
	'Body',
	'Eyes',
	'Wrist',
	'Waist',
	'Backpack',
	'Pouch',
	'Quiver',
	'Wallet');
end.
