{ CASINO.PAS		}
[external] procedure enter_casino; extern;


{ CREATE.PAS		}
[external] procedure put_character; extern;
[external] procedure put_stats; extern;
[external] procedure upd_stats; extern;
[external] procedure put_misc1; extern;
[external] procedure upd_misc1; extern;
[external] procedure put_misc2; extern;
[external] procedure put_misc3; extern;
[external] procedure display_char; extern;
[external] procedure get_name; extern;
[external] procedure change_name; extern;
[external] procedure create_character; extern;
[external] procedure get_ssn; external;
[external] procedure set_gem_values; extern;

{ CREATURE.PAS		}
[external] procedure load_monsters; extern;
[external] procedure mon_name; extern;
[external] function find_mon(virtual_name : ctype): integer; extern;
[external] procedure check_mon_lite(y,x : integer); extern;
[external] procedure multiply_monster(y,x,z : integer; slp : boolean); extern;
[external] procedure creatures(attack : boolean); extern;


{ DEATH.PAS		}
[external] procedure upon_death; extern;
[external] procedure make_tomb; extern;
[external] procedure replace_name; extern;
[external] procedure write_tomb; extern;
[external] procedure print_dead_character; extern;
[external] procedure top_twenty; extern;


{ DESC.PAS		}
[external] procedure randes; extern;
[external] procedure rantitle(var title	: varying[a] of char); extern;
[external] procedure magic_init(random_seed : unsigned); extern;
[external] procedure known1(var object_str : varying[a] of char); extern;
[external] procedure known2(var object_str : varying[a] of char); extern;
[external] procedure unquote(var object_str : varying[a] of char); extern;
[external] procedure identify(item : treasure_type); extern;
[external] procedure objdes(
		var out_val	: varying[a] of char;
		ptr		: treas_ptr;
		pref		: boolean); extern;


{ DUNGEON.PAS		}
[external] procedure move_rec(y1,x1,y2,x2 : integer); extern;
[external] procedure update_stat(tstat : stat_set); extern;
[external] procedure change_stat(
		tstat	: stat_set;
		amount	: integer;
		factor	: integer); extern;
[external] procedure change_speed(num : integer); extern;
[external] procedure py_bonuses(
		tobj	: treasure_type;
		factor	: integer); extern;
[external] function get_panel(y,x : integer) : boolean; extern;
[external] procedure search(y,x,chance : integer); extern;
[external] procedure area_affect(dir,y,x : integer); extern;
[external] procedure carry(y,x : integer); extern;
[external] procedure move_light(y1,x1,y2,x2 : integer); extern;
[external] procedure light_room(y,x : integer); extern;
[external] procedure lite_spot(y,x : integer); extern;
[external] procedure unlite_spot(y,x : integer); extern;
[external] function pick_dir(dir : integer) : boolean; extern;
[external] procedure panel_bounds; extern;
[external] function panel_contains(y,x : integer) : boolean; extern;
[external] function no_light : boolean; extern;
[external] procedure change_trap(y,x : integer); extern;
[external] procedure kicked_out; extern;
[external] procedure call_guards(who : vtype); extern;
[external] procedure call_wizards; extern;
[external] procedure beg_food; extern;
[external] procedure beg_money; extern;
[external] procedure invite_for_meal; extern;
[external] procedure party; extern;
[external] procedure spend_the_night(who : vtype); extern;
[external] procedure worship; extern;
[external] procedure battle_game(plus : integer; kb_str : vtype); extern;
[external] procedure thief_games; extern;
[external] function react(x : integer) : integer; extern;
[external] procedure change_rep(amt : integer); extern;
[external] function check_store_hours(st,sh : integer) : boolean; extern;
[external] procedure hit_trap(var y,x : integer); extern;
[external] function minus_ac(typ_dam : integer) : boolean; extern;
[external] procedure corrode_gas(kb_str : vtype); extern;
[external] procedure poison_gas(dam : integer; kb_str : vtype); extern;
[external] procedure fire_dam(dam : integer; kb_str : vtype); extern;
[external] procedure acid_dam(dam : integer; kb_str : vtype); extern;
[external] procedure cold_dam(dam : integer; kb_str : vtype); extern;
[external] procedure light_dam(dam : integer; kb_str : vtype); extern;
[external] procedure monster_death(y,x : integer; flags : unsigned); extern;
[external] function mon_take_hit(monptr,dam : integer) : integer; extern;
[external] function tot_dam(
		item	: treasure_type;
		tdam	: integer;
		monster	: creature_type) : integer; extern;
[external] function py_attack(y,x : integer) : boolean; extern;
[external] function find_range(
		item_val	: obj_set;
		inner		: boolean;
		var first	: treas_ptr;
		var count	: integer) : boolean; extern;
[external] function player_test_hit(bth,level,pth,ac : integer; 
				was_fired : boolean) : boolean; extern;
[external] function test_hit(bth,level,pth,ac : integer) : boolean; extern;
[external] procedure delete_monster(i2 : integer); extern;
[external] procedure summon_object(y,x,num,typ : integer); extern;
[external] function get_money_type(
		prompt		: string;
		var back	: boolean;
		no_check	: boolean) : integer; extern;
[external] function coin_stuff(typ : char; var type_num : integer)
			: boolean; extern;
[external] function set_money(typ : char; coin_num : integer) : boolean;
						extern;
[external] function movement_rate(cspeed,mon : integer) : integer; extern;
[external] procedure get_player_move_rate; extern;
[external] procedure xp_loss(amount : integer); extern;
[external] function twall(y,x,t1,t2 : integer) : boolean; extern;
[external] procedure dungeon; extern;


{ FILES.PAS		}
[external] procedure intro(var finam : vtype); extern;
[external] procedure print_map; extern;
[external] procedure print_objects; extern;
[external] procedure print_monsters; extern;
[external] procedure file_character; extern;


{ GENERATE.PAS		}
[external] procedure generate_cave; extern;


{ HELP.PAS		}
[external] procedure ident_char; extern;
[external] procedure help; extern;
[external] procedure wizard_help; extern;
[external] procedure moria_help(help_level : vtype); extern;


{ INVEN.PAS		}
[external] function change_all_ok_stats(nok,nin : boolean) : integer; extern;
[external] function cur_char1 : char; extern;
[external] function cur_char2 : char; extern;
[external] function cur_insure : char; extern;
[external] function inven_command(
		command		: char;
		var item_ptr	: treas_ptr;
		prompt		: vtype) : boolean; extern;
[external] procedure delete_inven_item(ptr : treas_ptr); extern;
[external] procedure inven_destroy(item_ptr : treas_ptr); extern;
[external] procedure inven_drop(
		item_ptr	: treas_ptr;
		y,x		: integer;
		mon		: boolean); extern;
[external] function inven_damage(
		typ		: obj_set;
		perc		: integer) : integer; extern;
[external] function inven_check_weight : boolean; extern;
[external] function inven_check_num : boolean; extern;
[external] function add_inven_item(item : treasure_type) : treas_ptr; extern;
[external] function inven_carry : treas_ptr; extern;
[external] function get_item(
			var com_ptr	: treas_ptr;
			pmt		: vtype;
			var redraw	: boolean;
			count		: integer;
			var choice	: char;
			mon		: boolean;
			no_wait		: boolean := false) : boolean; extern;


{ IO.PAS		}
[external] procedure convert_time(
		int_time	: unsigned;
		var bin_time	: quad_type); extern;
[external] procedure sleep(int_time : unsigned); extern;
[external] procedure mini_sleep(int_time : unsigned); extern;
[external] procedure priv_switch(switch_val : integer); extern;
[external] procedure no_controly; extern;
[external] procedure controly; extern;
[external] procedure exit; extern;
[external] procedure init_channel; extern;
[external] procedure inkey(var getchar : char); extern;
[external] procedure msg_record(message : vtype; save : boolean); extern;
[external] procedure inkey_delay(
		var getchar	: char;
		delay		: integer); extern;
[external] procedure flush; extern;
[external] procedure inkey_flush(var x : char); extern;
[external] procedure get_message; extern;
[external] procedure set_the_trap; extern;
[external] procedure disable_the_trap; extern;
[external] procedure erase_line(
		row 	: integer;
		col	: integer); extern;
[external] procedure clear(row,col : integer); extern;
[external] procedure print(
		str_buff	: varying[a] of char;
		row		: integer;
		col		: integer); extern;
[external] procedure prt(
		str_buff	: varying[a] of char;
		row		: integer;
		col		: integer); extern;
[external] function msg_print(str_buff : varying[a] of char) : boolean; extern;
[external] function get_com(
		prompt		: varying[a] of char;
		var command	: char) : boolean; extern;
[external] function get_yes_no(prompt : varying[a] of char) : boolean; extern;
[external] function get_string(
		var in_str	: varying[a] of char;
		row,column,slen : integer) : boolean; extern;
[external] function get_hex_value(row,col,slen : integer) : integer; extern;
[external] procedure print_hex_value(num,row,col : integer); extern;
[external] procedure pause(prt_line : integer); extern;
[external] procedure pause_exit(
		prt_line	: integer;
		delay		: integer); extern;
[external] procedure get_paths; extern;


{ PLAYER.PAS		}
[external] procedure find_off; extern;
[external] procedure search_off; extern;
[external] procedure rest_off; extern;
[external] procedure take_hit(damage : integer; hit_from : vtype); extern;
[external] procedure regenhp(percent : real); extern;
[external] procedure regenmana(percent : real); extern;

{ QUEST.PAS		}
[external] procedure enter_fortress; extern;
[external] function itos(i : integer): ctype; extern;

{ SAVE.PAS		}
[external] procedure data_exception; extern;
[external] procedure coder(var line : ntype); extern;
[external] procedure encrypt(var line : ntype); extern;
[external] procedure encrypt_write(var line : ntype); extern;
[external] procedure decrypt(var line : ntype); extern;
[external] procedure read_decrypt(var line : btype); extern;
[external] function save_char(quick : boolean) : boolean; extern;
[external] function get_char(fnam : vtype; prop : boolean) : boolean; extern;
[external] procedure restore_char(
		fnam	: vtype;
		present	: boolean;
		undead	: boolean); extern;


{ SCREEN.PAS		}
[external] procedure prt_map; extern;
[external] procedure prt_stat(
		stat_name	: vtype;
		stat		: byteint;
		row,column	: integer); extern;
[external] procedure prt_field(info : vtype; row,column : integer); extern;
[external] procedure prt_num(
		header		: vtype;
		num,row,column	: integer); extern;
[external] procedure prt_title; extern;
[external] procedure prt_a_stat(tstat : stat_set); extern;
[external] procedure prt_level; extern;
[external] procedure prt_mana; extern;
[external] procedure prt_hp; extern;
[external] procedure prt_pac; extern;
[external] procedure prt_gold; extern;
[external] procedure prt_weight; extern;
[external] procedure prt_time; extern;
[external] procedure prt_depth; extern;
[external] procedure prt_hunger; extern;
[external] procedure prt_blind; extern;
[external] procedure prt_confused; extern;
[external] procedure prt_afraid; extern;
[external] procedure prt_poisoned; extern;
[external] procedure prt_search; extern;
[external] procedure prt_rest; extern;
[external] procedure prt_quested; extern;
[external] procedure prt_winner; extern;
[external] procedure prt_experience; extern;
[external] procedure prt_6_stats(p : stat_s_type; row,col : byteint); extern;
[external] procedure prt_stat_block; extern;
[external] procedure draw_cave; extern;


{ STORE.PAS		}
[external] procedure prt_comment1; extern;
[external] procedure prt_comment2(offer,asking,final : integer); extern;
[external] procedure prt_comment3(offer,asking,final : integer); extern;
[external] procedure prt_comment4; extern;
[external] procedure prt_comment5; extern;
[external] procedure prt_comment6; extern;
[external] procedure display_commands; extern;
[external] procedure haggle_commands(typ : integer); extern;
[external] procedure display_inventory(store_num,start : integer); extern;
[external] procedure display_cost(store_num,pos : integer); extern;
[external] procedure store_prt_gold; extern;
[external] procedure display_store(store_num,cur_top : integer); extern;
[external] function get_store_item(
		var com_val	: integer;
		pmt		: vtype;
		i1,i2		: integer) : boolean; extern;
[external] procedure shut_store(store_num : integer); extern;
[external] function increase_insults(store_num : integer) : boolean; extern;
[external] procedure decrease_insults(store_num : integer); extern;
[external] function haggle_insults(store_num : integer) : boolean; extern;
[external] function receive_offer(
		store_num		: integer;
		comment			: vtype;
		var new_offer		: integer;
		last_offer,factor	: integer) : integer; extern;
[external] function purchase_haggle(
		store_num	: integer;
		var price	: integer;
		item		: treasure_type;
		blitz		: boolean) : integer; extern;
[external] function sell_haggle(
		store_num	: integer;
		var price	: integer;
		item		: treasure_type;
		blitz		: boolean) : integer; extern;
[external] procedure spend_time(days_spent : integer; place : vtype;
					whole_days : boolean); extern;
[external] function store_purchase(
		store_num	: integer;
		var cur_top	: integer;
		blitz		: boolean) : boolean; extern;
[external] function store_sell(
		store_num	: integer;
		cur_top		: integer;
		blitz		: boolean) : boolean; extern;
[external] procedure enter_store(store_num : integer); extern;
[external] function item_value(item : treasure_type) : integer; extern;
[external] function sell_price (
		snum			: integer;
		var max_sell,min_sell	: integer;
		item			: treasure_type) : integer; extern;
[external] function store_check_num(store_num : integer) : boolean; extern;
[external] procedure store_carry(
		store_num	: integer;
		var ipos	: integer); extern;
[external] procedure store_destroy(
		store_num,item_val	: integer; 
		one_of			: boolean); extern;
[external] procedure store_init; extern;
[external] procedure bank_init; extern;
[external] procedure store_create(store_num : integer); extern;
[external] procedure store_maint; extern;


{ TERMDEF.PAS		}
[external] procedure termdef; external;


{ WIZARD.PAS		}
[external] procedure game_version; extern;
[external] procedure wizard_light; extern;
[external] procedure monster_summon_by_name(
		y,x	: integer;
		name	: ctype;
		present	: boolean;
		sleepy	: boolean); extern;
[external] function summon_item(
		y,x	: integer;
		name1	: ttype;
		name2	: ttype;
		count	: integer;
		present : boolean) : boolean; extern;
[external] procedure change_character; extern;
[external] procedure edit_score_file; extern;
[external] procedure wizard_create; extern;






[external] procedure py_bonuses(
		tobj	: treasure_type;
		factor	: integer); extern;
[external] function delete_object(y,x : integer) : boolean; extern;
[external] procedure set_difficulty(diff : integer); extern;
[external] function center(str : string; len : integer) : string; extern;
[external] procedure eat; extern;
[external] procedure cast; extern;
[external] function get_seed : unsigned; extern;
[external] function day_num : integer; extern;
[external] function hour_num : integer; extern;
[external] function check_kickout : boolean; extern;
[external] function check_time : boolean; extern;
[external] function randnor(mean,stand : integer) : integer; extern;
[external] function in_bounds(y,x : integer) : boolean; extern;
[external] function next_to4(
		y,x		: integer;
		group_set	: obj_set) : integer; extern;
[external] function next_to8(
		y,x		: integer;
		group_set	: obj_set) : integer; extern;
[external] function rotate_dir(dir,rot : integer) : integer; extern;
[external] function get_hexdecant(dy,dx : integer) : bytlint; extern;
[external] procedure tlink; extern;
[external] procedure mlink; extern;
[external] procedure init_m_level; extern;
[external] procedure init_t_level; extern;
[external] procedure price_adjust; extern;
[external] procedure item_weight_adjust; extern;
[external] function damroll(dice : dtype) : integer; extern;
[external] function los(y1,x1,y2,x2 : integer) : boolean; extern;
[external] procedure loc_symbol(y,x : integer; var sym : char); extern;
[external] function test_light(y,x : integer) : boolean; extern;
[external] procedure compact_monsters; extern;
[external] procedure popm(var x : integer); extern;
[external] procedure pushm(x : integer); extern;
[external] function max_hp(hp_str : dtype) : integer; extern;
[external] procedure place_monster(y,x,z : integer; slp : boolean); extern;
[external] procedure place_win_monster; extern;
[external] procedure alloc_land_monster(alloc_set : obj_set;
		num,dis	: integer;
		slp	: boolean;
		water   : boolean); extern;

[external] function summon_land_monster(
		var y,x : integer;
		slp	: boolean) : boolean; extern;
[external] function summon_water_monster(
		var y,x : integer;
		slp	: boolean) : boolean; extern;
[external] function summon_undead(var y,x : integer) : boolean; extern;
[external] function summon_demon(var y,x : integer) : boolean; extern;
[external] function summon_breed(var y,x : integer) : boolean; extern;
[external] procedure petrify(amt : integer); extern;
[external] procedure compact_objects; extern;
[external] procedure popt(var x : integer); extern;
[external] procedure pusht(x : integer); extern;
[external] procedure sort_objects; extern;
[external] procedure magic_treasure(x,level : integer); extern;
[external] procedure place_trap(y,x,typ,subval : integer); extern;
[external] procedure place_rubble(y,x : integer); extern;
[external] procedure place_open_door(y,x : integer); extern;
[external] procedure place_broken_door(y,x : integer); extern;
[external] procedure place_closed_door(y,x : integer); extern;
[external] procedure place_locked_door(y,x : integer); extern;
[external] procedure place_stuck_door(y,x : integer); extern;
[external] procedure place_secret_door(y,x : integer); extern;
[external] procedure place_door(y,x : integer); extern;
[external] procedure place_a_staircase(y,x,typ : integer); extern;
[external] procedure place_stairs(typ,num,walls : integer); extern;
[external] procedure place_gold(y,x : integer); extern;
[external] function get_obj_num(level : integer) : integer; extern;
[external] procedure place_object(y,x : integer); extern;
[external] procedure alloc_object(
		alloc_set	: obj_set;
		typ,num		: integer); extern;
[external] procedure random_object(y,x,num : integer); extern;
[external] procedure cnv_stat(
		stat		: byteint;
		var out_val	: stat_type); extern;
[external] function spell_adj(attr : stat_set) : integer; extern;
[external] function bard_adj : integer; extern;
[external] function druid_adj : integer; extern;
[external] function monk_adj : integer; extern;
[external] function chr_adj : real; extern;
[external] function con_adj : integer; extern;
[external] function get_hitdie : integer; extern;
[external] function place_string(num : integer) : string; extern;
[external] function day_of_week_string(
		day	: integer;
		wid	: integer) : string; extern;
[external] function month_string(mon : integer) : string; extern;
[external] function time_string(
		hour	: integer;
		sec	: integer) : string; extern;
[external] procedure time_diff(
		a	: game_time_type;
		b	: game_time_type;
		var c	: game_time_type); extern;
[external] procedure add_days(
		var ti	: game_time_type;
		d	: integer); extern;
[external] function full_date_string(time : game_time_type) : string; extern;
[external] procedure adv_time(flag : boolean); extern;
[external] function play_time(t : time_type) : string; extern;
[external] procedure add_play_time(
		var res	: time_type;
		add	: time_type); extern;
[external] function show_char_age : string; extern;
[external] function show_current_time : string; extern;
[external] function show_play_time : string; extern;
[external] function bag_descrip(bag : treas_ptr) : string; extern;
[external] function squish_stat(this : integer) : byteint; extern;
[external] function in_statp(stat : byteint) : byteint; extern;
[external] function de_statp(stat : byteint) : byteint; extern;
[external] function tohit_adj : integer; extern;
[external] function toac_adj : integer; extern;
[external] function todis_adj : integer; extern;
[external] function todam_adj : integer; extern;
[external] function likert(x,y : integer) : btype; extern;
[external] procedure bpswd; extern;
[external] function characters_sex : byteint ; extern;
[external] function max_allowable_weight : wordint ; extern;
[external] function min_allowable_weight : wordint ; extern;
[external] function weight_limit : integer; extern;
[external] function money_carry : treas_ptr; extern;
[external] function cost_str(amount : integer) : string; extern;
[external] procedure reset_total_cash; extern;
[external] procedure add_money(amount : integer); extern;
[external] procedure subtract_money(
		amount		: integer;
		make_change	: boolean); extern;
[external] function send_page(to_bank : integer) : boolean; extern;
[external] procedure spell_chance(var spell : spl_rec); extern;
[external] procedure print_new_spells(
		spell		: spl_type;
		num		: integer;
		var redraw	: boolean); extern;
[external] function get_spell(spell : spl_type; num : integer;
		var sn,sc	: integer; prompt : vtype;
		var redraw	: boolean) : boolean; extern;
[external] function num_new_spells(smarts : integer) : integer; extern;
[external] function learn_spell(var redraw : boolean) : boolean; extern;
[external] function learn_prayer : boolean; extern;
[external] function learn_song(var redraw : boolean) : boolean; extern;
[external] function learn_druid : boolean; extern;
[external] procedure gain_mana(amount : integer); extern;
[external] procedure gain_level; extern;
[external] procedure insert_num(
		var object_str	: varying[a] of char;
		mtc_str		: varying[b] of char;
		number		: integer;
		show_sign	: boolean); extern;
[external] function check_pswd(
		passw	: string;
		present	: boolean) : boolean; extern;
[external] function attack_blows(
		weight		: integer;
		var wtohit	: integer) : integer; extern;
[external] function critical_blow(
		weight,plus : integer;
		cs_sharp,is_fired	: boolean) : integer; extern;
[external] function move(dir : integer; var y,x : integer) : boolean; extern;
[external] function player_saves(adjust : integer) : boolean; extern;
[external] function player_spell_saves : boolean; extern;
[external] procedure char_inven_init; extern;
[external] procedure move_char(dir : integer); extern;
[external] procedure quaff; extern;
[external] procedure pray; extern;
[external] procedure play; extern;
[external] procedure read_scroll; extern;
[external] function mon_resists(a_cptr : byteint) : boolean; extern;
[external] function mon_save(a_cptr,bonus,
				spell_class : integer) : boolean; extern;
[external] function sleep_monsters1(y,x : integer) : boolean; extern;
[external] function detect_item(typ : integer) : boolean; extern;
[external] function detect_trap : boolean; extern;
[external] function detect_sdoor : boolean; extern;
[external] function light_area(y,x : integer) : boolean; extern;
[external] function unlight_area(y,x : integer) : boolean; extern;
[external] function map_area : boolean; extern;
[external] function ident_spell : boolean; extern;
[external] function aggravate_monster(dis_affect : integer) : boolean; extern;
[external] function trap_creation : boolean; extern;
[external] function door_creation : boolean; extern;
[external] function td_destroy : boolean; extern;
[external] function light_line(dir,y,x,power : integer) : boolean; extern;
[external] function starlite(y,x : integer) : boolean; extern;
[external] function disarm_all(dir,y,x : integer) : boolean; extern;
[external] function detect_curse : boolean; extern;
[external] procedure get_flags (
		typ				: integer;
		var weapon_type,harm_type	: integer;
		var destroy			: obj_set); extern;
[external] function detect_magic : boolean; extern;
[external] function purify : boolean; extern;
[external] function lore_spell : boolean; extern;
[external] function fire_bolt(
		typ,dir,y,x,dam : integer;
		bolt_typ	: ctype) : boolean; extern;
[external] function fire_ball(
		typ,dir,y,x,dam_hp	: integer;
		descrip			: ctype) : boolean; extern;
[external] function creeping_doom(
		dir,y,x,dam_hp,range	: integer;
		ddesc			: ctype) : boolean; extern;
[external] function fire_line(
		typ,dir,y,x,dam_hp	: integer;
		descrip			: ctype) : boolean; extern;
[external] function breath(
		typ,y,x,dam_hp	: integer;
		ddesc		: vtype) : boolean; extern;
[external] function recharge(num : integer) : boolean; extern;
[external] function zap_monster(dir,y,x,aux,zaptype : integer):boolean;extern;
[external] function wall_to_mud(dir,y,x : integer) : boolean; extern;
[external] function td_destroy2(dir,y,x : integer) : boolean; extern;
[external] function poly_monster(dir,y,x : integer) : boolean; extern;
[external] function build_wall(dir,y,x : integer) : boolean; extern;
[external] function clone_monster(dir,y,x : integer) : boolean; extern;
[external] function teleport_away(monptr,dis : integer) : boolean; extern;
[external] function teleport_to(ny,nx : integer) : boolean; extern;
[external] function teleport_monster(dir,y,x : integer) : boolean; extern;
[external] function mass_genocide : boolean; extern;
[external] function genocide : boolean; extern;
[external] function mass_poly : boolean; extern;
[external] function detect_creatures(typ : integer) : boolean; extern;
[external] function hp_player(num : integer; kind : vtype) : boolean; extern;
[external] function cure_me(var what_flag : integer) : boolean; extern;
[external] function earthquake : boolean; extern;
[external] function protect_evil : boolean; extern;
[external] function create_food(t0,t1,t2,t3,t4 : integer) : boolean; extern;
[external] function zap_area(cflag,dmge,typ : integer) : boolean; extern;
[external] function warding_glyph : boolean; extern;
[external] procedure lower_stat(tstat : stat_set; msg1 : vtype); extern;
[external] function lose_stat(tstat : stat_set;
		msg1,msg2	: vtype) : boolean; extern;
[external] function restore_stat(tstat : stat_set;
		msg1	: vtype) : boolean; extern;
[external] function gain_stat(tstat : stat_set;
		msg1	: vtype) : boolean; extern;
[external] procedure lose_exp(amount : integer); extern;
[external] function slow_poison : boolean; extern;
[external] function bless(amount : integer) : boolean; extern;
[external] function detect_inv2(amount : integer) : boolean; extern;
[external] function destroy_area(y,x : integer) : boolean; extern;
[external] function enchant(var pluses : worlint) : boolean; extern;
[external] function remove_curse : boolean; extern;
[external] function restore_level : boolean; extern;
[external] procedure use; extern;
[external] procedure check_kickout_time(num,check : integer); extern;
[external] procedure aim; extern;
[external] procedure put_buffer(
		%ref	out_str	: varying [a] of char;
		%immed	row	: integer;
		%immed	col	: integer); external;
[external] procedure put_qio; external;
[external] function randint(%immed maxval : integer) : integer; external;
[external] function rand_rep(
		%immed num	: integer;
		%immed die	: integer) : integer; external;
[external] function maxmin(
		%immed	x	: integer;
		%immed	y	: integer;
		%immed	z	: integer) : integer; external;
[external] function minmax(
		%immed	x	: integer;
		%immed	y	: integer;
		%immed	z	: integer) : integer; external;
[external] function bit_pos(%ref test : unsigned) : integer; external;
[external] function bit_pos64(
		%ref	high	: unsigned;
		%ref	low	: unsigned) : integer; external;
[external] function distance(
		%immed y1	: integer;
		%immed x1	: integer;
		%immed y2	: integer;
		%immed x2	: integer) : integer; external;
[external] procedure insert_str(
		%ref object_str : varying[a] of char;
		%ref mtc_str	: varying[b] of char;
		%ref insert_str : varying[c] of char); external;
[external(LIB$SPAWN)] function shell_out(
		command_str	: integer := %immed 0;
		input_file	: integer := %immed 0;
		output_file	: integer := %immed 0;
		flags		: integer := %immed 0;
		process_name	: integer := %immed 0;
		process_id	: integer := %immed 0;
		comp_status	: integer := %immed 0;
		comp_efn	: integer := %immed 0;
		comp_astadr	: integer := %immed 0;
		comp_astprm	: integer := %immed 0 ) : integer; external;
[external] function users : integer; external;
[external] function max_users : integer; external;
[external] function uw_id : boolean; external;
[external] function net_trade : boolean; external;
[external] procedure get_account (account : [reference] packed array [$l1..$u1:integer] of char ); external;
[external] procedure enter_trading_post; extern;
[external] function already_playing : boolean; external;
[external] procedure find_monster_name(
		var m_name	: vtype;
		ptr		: integer;
		begin_sentence	: boolean); external;
[external] procedure sys$gettim(bin_time : [reference] quad_type); external;
[external] procedure sys$numtim(
		weird_num	: [reference] time_type;
		bin_time	: [reference] quad_type); external;
[external] procedure sys$asctim(
		timlin		: [reference] wordint := %immed 0;
		timbuf		: [class_s] packed array [$l1..$u1:integer] of char;
		timadr		: [reference] quad_type := %immed 0;
		cvtflg		: [reference] integer := %immed 0); external;
