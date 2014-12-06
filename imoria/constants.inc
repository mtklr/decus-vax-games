
const
	{Note to the Wizard:						}
	{	Tweaking these constants can *GREATLY* change the game. }
	{	Two years of constant tuning have generated these	}
	{	values.	 Minor adjustments are encouraged, but you must }
	{	be very careful not to unbalance the game.  Moria was	}
	{	meant to be challenging, not a give away.  Many		}
	{	adjustments can cause the game to act strangely, or even}
	{	cause errors.						}
 
	{ Current version number of Moria				}
	cur_version   = 4.85;{FUBAR}
 
	{ QIOW constants, see $IODEF in STARLET.MLB			}
	IO$MOR_OUTPUT = IO$_WRITEVBLK;
	IO$MOR_INPUT  = IO$_TTYREADALL + IO$M_NOECHO;
	IO$MOR_DELAY  = IO$MOR_INPUT   + IO$M_NOWAIT;
	IO$MOR_IPURGE = IO$MOR_DELAY   + IO$M_PURGE;
  
	{ Wizard accounts (can use wizard/god modes)	      -DCJ/KRC-
	  Please document additions to this list.  Current wizards are:
		games/arcana	: GAMES
		Tom Bunch       : 8630891
		Ken Case	: 9EBB07D3, C8518
                Robert Christ   : 8725262
		Mary Conner	: 26F45030, 8221984
		Brad DeGrazia   : 8830329
		Rob DeLoura	: 8536399
				: DD7CB31C
		Jimbo Harris    : 8727288
		Jonathan Sari	: 8728277
		Raoul St.Pierre : 8832780
		And Dean Yasuda as the MBI!
	}
	wizards = ':GAMES:9EBB07D3:C8518:26F45030:8727288:8536399:DD7CB31C:8728277:8221984:8725262:8832780:8830329:';
 
	{ Encryption constants						}
	{ Note: These numbers were pulled from the air, and can be	}
	{	changed.  If changed, characters produced from other	}
	{	versions will fail to restore.				}
	encrypt_seed1 = 1175191;
	encrypt_seed2 = 997551771;
 
	{ Screen size parameters					}
	screen_height = 22;
	screen_width  = 66;
 
	{ Screen placement parameters					}
	stat_column	= 1 ;
	race_row	= 2 ;
	class_row	= race_row + 1 ;
	title_row	= class_row + 1 ;
	str_row		= title_row + 2 ;
	int_row		= str_row + 1 ;
	wis_row		= int_row + 1 ;
	dex_row		= wis_row + 1 ;
	con_row		= dex_row + 1 ;
	cha_row		= con_row + 1 ;
	level_row	= cha_row + 2 ;
	exp_row		= level_row + 1 ;
	mana_row	= exp_row + 1 ;
	hp_row		= mana_row + 1 ;
	quest_row	= hp_row + 1;
	ac_row		= quest_row + 1 ;
	gold_row	= ac_row + 1 ;
	weight_row	= gold_row + 1 ;
	time_row	= weight_row + 2;
	winner_row	= 23 ;
	winner_column		= 1 ;
 
	status_row	= 24 ;
		hunger_column		= 1 ;
		blind_column		= 9 ;
		confused_column		= 16 ;
		afraid_column		= 26 ;
		poisoned_column		= 34 ;
		searching_column	= 44 ;
		resting_column		= 44 ;
		quested_column		= 53 ;{FUBAR}
		depth_column		= 62 ;
 
 
	sr = 0;	iq = 1;	ws = 2;	dx = 3;	cn = 4;	ca = 5;
	{ Spell Effect Constants! }
	c_null=0;
	c_lightning=1; c_gas=2; c_acid=3; c_cold=4; c_fire=5;
	c_good=6; c_evil=7; c_petrify=8; c_sunray=9; c_illusion=10; c_probe=11;
	c_sleep=12; c_confuse=13; c_hp=14; c_drain=15; c_speed=16; c_hold=17;
	c_turn=18; c_poly=19; c_joke=20; c_monster=21; c_invisible=22;
	c_creature=23; c_object=24; c_treasure=25; c_hp_undead=26;
	c_thunder=27; c_holy_word=28;

	c_sc_hold=1; c_sc_mental=2;

	{ # of numbered objects for easy summoning (ie. create food) }
	num_yum=17;

	{ Dungeon size parameters					}
	max_height    = 66;	{ Multiple of 11; >= 22 }
	max_width     = 198;	{ Multiple of 33; >= 66 }
 
	{ Output dungeon section sizes					}
	outpage_height= 44;	{ 44 lines of dungeon per section	}
	outpage_width = 99;	{ 100 columns of dungeon per section	}
 
	{ Dungeon generation values					}
	{ Note: The entire design of dungeon can be changed by only	}
	{	slight adjustments here.				}
	day_length	= 9600;	{ Turns in a day			}
	dun_tun_rnd	= 36;	{ Random direction (4 is min)		}
	dun_tun_chg	= 70;	{ Chance of changing direction (99 max) }
	dun_tun_fnd	= 12;	{ Distance for auto find to kick in	}
	dun_tun_con	= 15;	{ Chance of extra tunneling		}
	dun_roo_mea	= 32;	{ Mean of # of rooms, standard dev=2	}
	dun_tun_pen	= 25;	{ % chance of room doors		}
	dun_tun_jct	= 15;	{ % chance of doors at tunnel junctons	}
	dun_str_den	= 5;	{ Density of streamers			}
	dun_str_rng	= 2;	{ Width of streamers			}
	dun_str_mag	= 3;	{ Number of magma streamers		}
	dun_str_qua	= 2;	{ Number of quartz streamers		}
	dun_wtr_den	= 5;	{ Density of water			}
	dun_wtr_width	= 4;	{ Width of river			}
	dun_rivers	= 3;	{ Number of rivers			}
	dun_riv_len	= 35;	{ Maximum river length			}
	dun_pools	= 3;	{ Number of pools			}
 
	{ Store constants						}
	max_owner_kind	=  4;	{ Number of different keepers for a shop}
	max_stores	= 11;	{ Number of different stores		}
	max_owners	= max_stores * max_owner_kind;
				{ Number of owners to choose from	}
	max_unnamed	=  6;	{ # of 'odd' shops (Post, etc)	}
	tot_stores	= max_stores+max_unnamed;
	max_fountains	=  2;	{ # of fountains on town level	}
	max_house1	= 4;	{ # of generic houses in town	}
	max_house2	= 8;	{ # of small houses in town }
	max_house3	= 2;	{ # apartments }
	max_house4	= 2;	{ # small apartments }
	day_mugging	= 50;	{ 1/x chance that page gets mugged (day)}
	night_mugging	= 15;	{ 1/x chance that page gets mugged (night)}
	bank_skim	= 0.95;	{ Percent of money that really gets deposited}
	store_inven_max = 24;	{ Max number of discrete objs in inven	}
	store$choices	= 50;	{ Number of items to choice stock from	}
	store$max_inven = 20;	{ Max diff objs in stock before auto sell}
	store$min_inven = 14;	{ Min diff objs in stock before auto buy}
	store$turn_around= 3;	{ Amount of buying and selling normally }
	inven_init_max	= 157;	{ Size of store init array		}
	cost_adj	= 240.00; { FLOAT(Gold$value)--adjusts store costs }
	weight_adj	= 100;	{ Adjust weights of items 		}
	quest_delay	= 800;  { # of turns to wait before char can get quest}
 
	{ Treasure constants						}
	equip_max     = 15;	{ Size of equipment array		}
	max_obj_level = 256;	{ Maximum level of magic in dungeon	}
	max_objects   = 471;	{ Number of objects for universe	}
	max_gold      = 25;	{ Number of different types of gold	}
	max_talloc    = 225;	{ Max objects per level			}
 
	{ Money constants, for those of us who can't remember '12480'   }
	mithril$value	= 12480;{ Iron Pieces				}
	platinum$value	=   960;
	gold$value	=   240;
	silver$value	=    20;
	copper$value	=     4;
	iron$value	=     1;

	{ Constants describing limits of certain objects		}
	obj$lamp_max	=15000; { Maximum amount that lamp can be filled}
	obj$bolt_range	= 18;	{ Maximum range of bolts and balls	}
	obj$rune_prot	= 3000; { Rune of protection resistance		}
 
	{ Creature contants						}
	max_creatures	 = 415; { Number of creatures defined for univ	}
	max_malloc	 = 100 + 1;{ Max that can be allocated		}
	max_malloc_chance= 160; { 1/x chance of new monster each round	}
	max_mons_level	 = 100; { Maximum level of creatures		}
	max_sight	 =  20; { Maximum dis a creature can be seen	}
	max_spell_dis	 =  18; { Maximum dis creat. spell can be cast	}
	max_mon_mult	 =  75; { Maximum reproductions on a level	}
	min_malloc_level =  14; { Minimum number of monsters/level	}
	min_malloc_td	 =   8; { Number of people on town level (day)	}
	min_malloc_tn	 =  12; { Number of people on town level (night)}
	win_mon_tot	 =   2; { Total number of "win" creatures	}
	win_mon_appear	 = 100; { Level where winning creatures begin	}
	out_of_env_dam	 =  32; { max HP lost/rnd/2^move in wrong env	}
	mon$summon_adj	 =   2; { Adjust level of summoned creatures	}
	mon$drain_life	 =   5; { Percent of player exp drained per hit }
 
	{ Trap constants						}
	max_trapa	 = 19;	{ Number of defined traps		}
	max_trapb	 = 20;	{ Includes secret doors			}
 
	{ Descriptive constants						}
	max_colors    = 67;	{ Used with potions	}
	max_mush      = 29;	{ Used with mushrooms	}
	max_woods     = 41;	{ Used with staffs	}
	max_metals    = 32;	{ Used with wands	}
	max_horns     = 13;	{ Used with horns	}
	max_rocks     = 53;	{ Used with rings	}
	max_cloths    =  7;	{ Used with bags/sacks	}
	max_amulets   = 39;	{ Used with amulets	}
	max_syllables = 156;	{ Used with scrolls	}
 
	{ Player constants						}
	max_quests	 = 35;	{ Maximum number of quests per game	}
	max_spells	 = 40;	{ Maximum number of spells per class	}
	max_player_level = 40;	{ Maximum possible character level	}
	max_races	 = 10;  { Number of defined races	        }
	max_class	 = 10;	{ Number of defined classes		}
	max_messages	 = 50;  { Previous messages that in buffer	}
	use_device	 = 3;	{ x> Harder devices x< Easier devices	}
	max_background	 = 177; { Number of types of histories for univ }
	num_quests	 = 5;	{ # of possible quests to select from	}
	player_food_full =10000;{ Getting full				}
	player_food_max	 =15000;{ Maximum food value, beyond is wasted	}
	player_food_faint=  300;{ Character begins fainting		}
	player_food_weak = 1000;{ Warn player that he is getting very low}
	player_food_alert= 2000;{ Warn player that he is getting low	}
	player$regen_faint  = 0.0005;	{ Regen factor when fainting	}
	player$regen_weak   = 0.0015;	{ Regen factor when weak	}
	player$regen_normal = 0.0030;	{ Regen factor when full	}
	player$regen_hpbase = 0.0220;	{ Min amount hp regen		}
	player$regen_mnbase = 0.0080;	{ Min amount mana regen		}
	player_weight_cap= 13;	{ "#"*(1/10 pounds) per strength point	}
	player_exit_pause= 0;	{ Pause time before player can re-roll	}
	max_high_scores = 100;	{ Maximum number of high scores to keep }
	female	= 1 ;
	male	= 2 ;
	{ Base to hit constants						}
	bth_lev_adj	= 3;	{ Adjust BTH per level			}
	bth_plus_adj	= 3;	{ Adjust BTH per plus-to-hit		}
	bth_hit		= 12;	{ Automatic hit; 1/bth_hit		}
 
	{ Misc								}
	null		= chr(0);
 
	Nothing_flag			=	%x'00000000';
	Everything_flag			=	%x'FFFFFFFF';
 
	{ Flags for items that can be worn or wielded		-DCJ-	}
	Strength_worn_bit		=	%x'00000001';
	Dexterity_worn_bit		=	%x'00000002';
	Constitution_worn_bit		=	%x'00000004';
	Intelligence_worn_bit		=	%x'00000008';
	Wisdom_worn_bit			=	%x'00000010';
	Charisma_worn_bit		=	%x'00000020';
	Searching_worn_bit		=	%x'00000040';
	Slow_digestion_worn_bit		=	%x'00000080';
	Stealth_worn_bit		=	%x'00000100';
	Aggravation_worn_bit		=	%x'00000200';
	Teleportation_worn_bit		=	%x'00000400';
	Regeneration_worn_bit		=	%x'00000800';
	Speed_worn_bit			=	%x'00001000';
	Slay_Dragon_worn_bit		=	%x'00002000';
	Slay_Monster_worn_bit		=	%x'00004000';
	Slay_Evil_worn_bit		=	%x'00008000';
	Slay_Undead_worn_bit		=	%x'00010000';
	Cold_Brand_worn_bit		=	%x'00020000';
	Flame_Brand_worn_bit		=	%x'00040000';
	Resist_Fire_worn_bit		=	%x'00080000';
	Resist_Acid_worn_bit		=	%x'00100000';
	Resist_Cold_worn_bit		=	%x'00200000';
	Sustain_Stat_worn_bit		=	%x'00400000';
	Free_Action_worn_bit		=	%x'00800000';
	See_Invisible_worn_bit		=	%x'01000000';
	Resist_Lightning_worn_bit	=	%x'02000000';
	Feather_Fall_worn_bit		=	%x'04000000';
	Blindness_worn_bit		=	%x'08000000';
	Timidness_worn_bit		=	%x'10000000';
	Tunneling_worn_bit		=	%x'20000000';
	Infra_vision_worn_bit		=	%x'40000000';
	Cursed_worn_bit			=	%x'80000000';
 
	{ Flags for items that can be worn or wielded (flags2)		}
	Slay_demon_worn_bit		=	%x'00000001';
	Soul_Sword_worn_bit		=	%x'00000002';
	Slay_regen_worn_bit   		=	%x'00000004';
	Swimming_worn_bit		=	%x'00000008';
	Magic_proof_worn_bit		=	%x'00000010';
	Disarm_worn_bit			=	%x'00000020';
	Sharp_worn_bit			=	%x'00000040';
{	Unused_bit			=	%x'00000080';		}
{	Unused_bit_set			=	%x'000FFF00';		}
{	Unused_bit			=	%x'00100000';		}
	Bad_repute_worn_bit		=	%x'00200000';
	Hunger_worn_bit			=	%x'00400000';
	Negative_gem_bit		=	%x'00800000';
	Increase_carry_worn_bit		=	%x'01000000';
{	Unused_bit			=	%x'02000000';		}
	Holding_bit			=	%x'04000000';
	Swallowing_bit			=	%x'08000000';
	Sharp_bit			=	%x'10000000';            
{	Unused_bit			=	%x'20000000';		}
	Insured_bit			=	%x'40000000';
	Known_cursed_bit		=	%x'80000000';
 
 
	{ Constants for equipment inventory items		-KRC-	}
 
	Equipment_min		=	1;
	Equipment_primary	=	Equipment_min;
	Equipment_helm		=	Equipment_primary + 1;
	Equipment_amulet	=	Equipment_helm + 1;
	Equipment_armor		=	Equipment_amulet + 1;
	Equipment_belt		=	Equipment_armor + 1;
	Equipment_shield	=	Equipment_belt + 1;
	Equipment_gloves	=	Equipment_shield + 1;
	Equipment_bracers	=	Equipment_gloves + 1;
	Equipment_right_ring	=	Equipment_bracers + 1;
	Equipment_left_ring	=	Equipment_right_ring + 1;
	Equipment_boots		=	Equipment_left_ring + 1;
	Equipment_cloak		=	Equipment_boots + 1;
	Equipment_light		=	Equipment_cloak + 1;
	Equipment_secondary	=	Equipment_light + 1;
 
	{ tval constants					-DCJ-	}
 
	Miscellaneous_Object	=	1;
	chest			=	2;
	misc_usable		=	3;
	valuable_jewelry	=	4;
	valuable_gems		=	5;
	bag_or_sack		=	6;
	valuable_gems_wear	=	7;
	sling_ammo		=	10;
	bolt			=	11;
	arrow			=	12;
	spike			=	13;
	Lamp_or_Torch		=	15;
	bow_crossbow_or_sling	=	20;
	hafted_weapon		=	21;
	pole_arm		=	22;
	dagger			=	23;
	sword			=	24;
	pick_or_shovel		=	25;
	maul			=	26;
	gem_helm		=	29;
	boots			=	30;
	gloves_and_gauntlets	=	31;
	Cloak			=	32;
	helm			=	33;
	shield			=	34;
	hard_armor		=	35;
	soft_armor		=	36;
	bracers			=	37;
	belt			=	38;
	amulet			=	40;
	ring			=	45;
	staff			=	55;
	rod			=	60;
	wand			=	65;
	scroll1			=	70;
	scroll2			=	71;
	potion1			=	75;
	potion2			=	76;
	flask_of_oil		=	77;
	food			=	80;
	Junk_food		= 	81;
	chime			=	85;
	horn			=	86;
	Magic_Book		=	90;
	Prayer_Book		=	91;
	Instrument		=	92;
	Song_Book		=	93;
	valuable_metal		=	100;
	Unseen_trap		=	101;
	Seen_trap		=	102;
	Rubble			=	103;
	Open_door		=	104;
	Closed_door		=	105;
	Up_staircase		=	107;
	Down_staircase		=	108;
	Secret_door		=	109;
	Entrance_to_store	=	110;
	Up_steep_staircase	=	111;
	Down_steep_staircase	=	112;    
 	Whirlpool		=	113;

	mithril_pos		=	max_gold;
	platinum_pos		=	max_gold-1;
	gold_pos		=	max_gold-2;
	silver_pos		=	 4;
	copper_pos		=	 3;
	iron_pos		=	 2;

	total$ = 0;
	iron = 1;
	copper = 2;
	silver = 3;
	gold = 4;
	platinum = 5;
	mithril = 6;

	coin$weight = 5;

	ctrl_A			= chr(1);
	ctrl_B			= chr(2);
	ctrl_C			= chr(3);
	ctrl_D			= chr(4);
	ctrl_E			= chr(5);
	ctrl_F			= chr(6);
	ctrl_G			= chr(7);
	ctrl_H			= chr(8);
	ctrl_I			= chr(9);
	ctrl_J			= chr(10);
	ctrl_K			= chr(11);
	ctrl_L			= chr(12);
	ctrl_M			= chr(13);
	ctrl_N			= chr(14);
	ctrl_O			= chr(15);
	ctrl_P			= chr(16);
	ctrl_Q			= chr(17);
	ctrl_R			= chr(18);
	ctrl_S			= chr(19);
	ctrl_T			= chr(20);
	ctrl_U			= chr(21);
	ctrl_V			= chr(22);
	ctrl_W			= chr(23);
	ctrl_X			= chr(24);
	ctrl_Y			= chr(25);
	ctrl_Z			= chr(26);

