var

	cur_inven			: [psect(inven$data)]
					  treas_ptr;	{ Current inven page  }
	is_magii			: [psect(player$data)]
					  boolean;	{ True if has mana    }
	start_time			: [psect(setup$data)]
					  quad_type;	{ Time started playing}
	is_from_file			: [psect(player$data)]
					  boolean;	{ True if restored    }
	bank				: [psect(player$data)]
					  money_type;	{ Bank's money	      }
	coin$value			: [psect(player$data)]
					  money_type;	{ Copy of money values}
	player_max_exp			: [psect(player$data)]
					  integer;	{ Max exp possible    }
	seed				: [psect(player$data),global]
					  unsigned;	{ Contains seed #     }
	randes_seed			: [psect(setup$data)]
					  unsigned;	{ For encoding colors }
	town_seed			: [psect(generate$data)]
					  unsigned;	{ Seed for town genera}
	channel				: [psect(io$data),global]
					  integer;	{ I/O channel #       }
	pasteb				: [psect(io$data),global]
					  unsigned;	{ Pasteboard id       }
	io$bin_pause			: [psect(io$data)]
					  quad_type;	{ I/O pause time      }
	cur_height,cur_width		: [psect(player$data)]
					  integer;	{ Cur dungeon size    }
	dun_level			: [psect(player$data)]
					  integer;	{ Cur dungeon level   }
	missle_ctr			: [psect(player$data)]
					  integer;	{ Counter for missles }
	msg_line			: [psect(player$data)]
					  integer;	{ Contains message txt}
	msg_flag			: [psect(player$data)]
					  boolean;	{ Set with first msg  }
	msg_prev			: [psect(io$data)] {previous messages}
					  array[1..max_messages] of vtype;
	quest				: [psect(quest$data)] {quest data}
					  array[1..num_quests] of integer;
	old_msg				: [psect(player$data)]
					  vtype;	{ Last message	      }
	want_trap			: [psect(player$data)]
					  boolean;	{ True = trap messages}
	want_warn			: [psect(player$data)]
					  boolean;	{ True = water warning}
	caught_message			: [psect(player$data)]
					  message_ptr;	{ Message from other  }
	old_message			: [psect(player$data)]
					  message_ptr;	{ Past messages	      }
	old_mess_count			: [psect(player$data)]
					  integer;	{ Count of old mess's }
	max_mess_keep			: [psect(player$data)]
					  integer;	{ Max old to keep     }
	cur_message			: [psect(player$data)]
					  message_ptr;	{ Pointer to add mess }
	message_cursor			: [psect(player$data)]
					  message_ptr;	{ Pointer to read mess}
	caught_count			: [psect(player$data)]
					  integer;	{ # of mesgs waiting  }
	max_score			: [psect(player$data)]
					  integer;	{ # of scores to list }
	generate			: [psect(setup$data)]
					  boolean;	{ Generate next level }
	death				: [psect(player$data)]
					  boolean;	{ True if died	      }
	died_from			: [psect(player$data)]
					  vtype;	{ What killed him     }
	turn_counter			: [psect(dungeon$data)] 
					  integer;	{ Turns ellapsed      }
	find_flag			: [psect(player$data)]
					  boolean;	{ Used in MORIA	      }
	cave_flag			: [psect(player$data)]
					  boolean;	{ Used in GET_PANEL   }
	light_flag			: [psect(player$data)]
					  boolean;	{ Used in MOVE_LIGHT  }
	redraw				: [psect(player$data)]
					  boolean;	{ For redraw screen   }
	print_stat			: [psect(player$data)]
					  unsigned;	{ Flag for stats      }
	turn				: [psect(player$data)]
					  integer;	{ Cur trun of game    }
	wizard1				: [psect(player$data)]
					  boolean;	{ Wizard flag	      }
	wizard2				: [psect(player$data)]
					  boolean;	{ Wizard flag	      }
	used_line			: [psect(player$data)]
					  array [2..23] of boolean;
	password1			: [psect(setup$data)]
					  packed array [1..12] of char;
	password2			: [psect(setup$data)]
					  packed array [1..12] of char;
	wdata				: [psect(setup$data)]
					  array [1..2,0..12] of unsigned;
	days				: [psect(setup$data)]
					  array [1..7] of vtype;
	closing_flag			: [psect(player$data)]
					  integer;	{ Used for closing   }
	uw$id				: [psect(setup$data)]
					  boolean;	{ Is this a UW node? }
{neatness arrays}
	key_of		: [psect(player$data)]  array [0..8] of byteint;
	oct_of		: [psect(player$data)]  array [1..9] of byteint;
	dx_of		: [psect(player$data)]  array [1..9] of bytlint;
	dy_of		: [psect(player$data)]  array [1..9] of bytlint;
	{ Bit testing array						}
	bit_array			: [psect(player$data)]
					  array [1..32] of unsigned;

	{ External file names; are all located in directory with image	}
	MORIA_HOU			: [psect(setup$data)] vtype;
	MORIA_MOR			: [psect(setup$data)] vtype;
	MORIA_MAS			: [psect(setup$data)] vtype;
	MORIA_TOP			: [psect(setup$data)] vtype;
	MORIA_TRD			: [psect(setup$data)] vtype;
	MORIA_HLP			: [psect(setup$data)] vtype;
	MORIA_LCK			: [psect(setup$data)] vtype;
	MORIA_DTH			: [psect(setup$data)] vtype;
	MORIA_MON			: [psect(setup$data)] vtype;
	MORIA_CST			: [psect(setup$data)] vtype;

	{  Following are calculated from max dungeon sizes		}
	max_panel_rows,max_panel_cols	: [psect(player$data)] integer;
	quart_height,quart_width	: [psect(player$data)] integer;
	panel_row,panel_col		: [psect(player$data)] integer;
	panel_row_min,panel_row_max	: [psect(player$data)] integer;
	panel_col_min,panel_col_max	: [psect(player$data)] integer;
	panel_col_prt,panel_row_prt	: [psect(player$data)] integer;

	{  Following are all floor definitions				}
	cave				: [psect(moria$data)]
					  array [1..max_height] of row_floor;
	blank_floor			: [psect(generate$data)] cave_type;
	dopen_floor			: [psect(generate$data)] floor_type;
	lopen_floor			: [psect(generate$data)] floor_type;
	corr_floor1			: [psect(generate$data)] floor_type;
	corr_floor2			: [psect(generate$data)] floor_type;
	corr_floor3			: [psect(generate$data)] floor_type;
	corr_floor4			: [psect(generate$data)] floor_type;
	rock_wall1			: [psect(generate$data)] floor_type;
	rock_wall2			: [psect(generate$data)] floor_type;
	rock_wall3			: [psect(generate$data)] floor_type;
	water1				: [psect(generate$data)] floor_type;
	water2				: [psect(generate$data)] floor_type;
	water3				: [psect(generate$data)] floor_type;
	boundry_wall			: [psect(generate$data)] floor_type;

	{  Following are set definitions				}
	floor_set			: [psect(moria$data)] obj_set;
	wall_set			: [psect(moria$data)] obj_set;
	pwall_set			: [psect(moria$data)] obj_set;
	corr_set			: [psect(moria$data)] obj_set;
	trap_set			: [psect(moria$data)] obj_set;
	light_set			: [psect(moria$data)] obj_set;
	water_set			: [psect(moria$data)] obj_set;
	earth_set			: [psect(moria$data)] obj_set;
	float_set			: [psect(moria$data)] obj_set;
	slow_set			: [psect(moria$data)] obj_set;
	stable_set			: [psect(moria$data)] obj_set;

	{ Following are player variables				}
	py			: [psect(player$data)] player_type;
	player_title		: [psect(player$data)]
				  array [1..max_class] of
				  array [1..max_player_level] of btype;
	player_exp		: [psect(player$data)]
				  array [1..max_player_level] of integer;
	acc_exp			: [psect(player$data)]
				  real;	{ Accumulator for fractional exp}
	bare_hands		: [psect(player$data)]
				  dtype;
	msg_terse		: [psect(io$data)] boolean;
	record_ctr		: [psect(io$data)] byteint;
	char_row		: [psect(player$data)] integer;
	char_col		: [psect(player$data)] integer;
	com_val			: [psect(player$data)] integer;
	pclass			: [psect(player$data)] integer;
	sex_type		: [psect(player$data)] vtype;
	race			: [psect(create$data)]
				  array [1..max_races] of race_type;
	background		: [psect(create$data)]
				  array [1..max_background] of background_type;
	rgold_adj		: [psect(store$data)]
				  array [1..max_races] of
				  array [1..max_races] of real;
	class			: [psect(create$data)]
				  array [1..max_class] of class_type;
	magic_spell		: [psect(player$data)]
				  array [1..max_class] of 
				  array [1..max_spells] of spell_type;
	yums			: [psect(setup$data)] 
				  array [1..num_yum] of treasure_type;
	monk_book		: [psect(setup$data)] treasure_type;
	player_init		: [psect(create$data)]
				  array [1..max_class] of
				  array [1..5] of byteint;
	total_winner		: [psect(setup$data)] boolean;

	{ Following are store definitions				}
	owners			: [psect(store$data)]
				  array [1..max_owners] of owner_type;
	store			: [psect(store$data)]
				  array [1..max_stores] of store_type;
	store_door		: [psect(generate$data)]
				  array [1..max_stores+max_unnamed+5] of
				  treasure_type;
	store_choice		: [psect(store$data)]
				  array [1..max_stores] of 
				  array [1..store$choices] of integer;
	store_buy		: [psect(store$data)]
				  array [1..max_stores] of obj_set;
	store_hours		: [psect(store$data)]
				  array [1..max_stores+max_unnamed] of
				  array [1..7] of htype;
	store_bribe		: [psect(store$data)]
				  array [1..max_stores+max_unnamed] of integer;
	mugging_chance		: [psect(store$data)]	{ Chance page gets }
				  integer;		{ mugged	   }

	{ Following are treasure arrays	and variables			}
	object_list		: [psect(moria$data)] 
				  array [1..max_objects] of treasure_type;
	object_ident		: [psect(moria$data)] 
				  array [1..max_objects] of boolean;
	t_level			: [psect(moria$data)] 
				  array [0..max_obj_level] of integer;
	gold_list		: [psect(moria$data)] 
				  array [1..max_gold]    of treasure_type;
	t_list			: [psect(moria$data)] 
				  array [1..max_talloc]  of treasure_type;
	equipment		: [psect(player$data)] 
				  array [1..equip_max]	 of treasure_type;
	inventory_list		: [psect(player$data)] treas_ptr;
	inven_temp		: [psect(player$data)] treas_ptr;
	inventory_init		: [psect(setup$data)] 
				  array [1..inven_init_max] of treasure_type;
	blank_treasure		: [psect(moria$data)] treasure_type;
	inven_ctr		: [psect(player$data)]
				  integer;	{ Total different obj's	}
	inven_weight		: [psect(player$data)]
				  integer;	{ Cur carried weight	}
	equip_ctr		: [psect(player$data)]
				  integer;	{ Cur equipment ctr	}
	tcptr			: [psect(moria$data)]
				  integer;	{ Cur treasure heap ptr	}

	{ Following are variables that change with level of difficulty	}
	{ 1/x chance of treasure per magma		}
	dun_str_mc		: [psect(generate$data)] integer;
	{ 1/x chance of treasure per quartz		}
	dun_str_qc		: [psect(generate$data)] integer;
	{ Level/x chance of unusual room		}
	dun_unusual		: [psect(generate$data)] integer;
	{ Amount of objects for rooms			}
	treas_room_alloc	: [psect(generate$data)] integer;
	{ Amount of objects for corridors		}
	treas_any_alloc		: [psect(generate$data)] integer;
	{ Amount of gold (and gems)			}
	treas_gold_alloc	: [psect(generate$data)] integer;
	{ 1/n Chance of item being a Great Item 	}
	obj_great		: [psect(moria$data)] integer;
	{ Adjust STD per level				}
	obj_std_adj		: [psect(moria$data)] real;
	{ Minimum STD					}
	obj_std_min		: [psect(moria$data)] integer;
	{ Town object generation level			}
	obj_town_level		: [psect(moria$data)] integer;
	{ Base amount of magic				}
	obj_base_magic		: [psect(moria$data)] integer;
	{ Max amount of magic				}
	obj_base_max		: [psect(moria$data)] integer;
	{ magic_chance/# = special magic		}
	obj_div_special		: [psect(moria$data)] integer;
	{ magic_chance/# = cursed items			}
	obj_div_cursed		: [psect(moria$data)] real;
	{ High value slows multiplication		}
	mon_mult_adj		: [psect(moria$data)] integer;
	{ Dun_level/x chance of high level creature	}
	mon_nasty		: [psect(moria$data)] integer;

	{ Following are feature objects defined for dungeon		}
	trap_lista		: [psect(generate$data)]
				  array [1..max_trapa]   of treasure_type;
	trap_listb		: [psect(generate$data)]
				  array [1..max_trapb]   of treasure_type;
	scare_monster		: [psect(generate$data)]
				  treasure_type;	{ Special trap	}
	some_rubble		: [psect(generate$data)]
				  treasure_type;
	door_list		: [psect(generate$data)]
				  array [1..3]		 of treasure_type;
	up_stair		: [psect(generate$data)]
				  treasure_type;
	down_stair		: [psect(generate$data)]
				  treasure_type;
	up_steep		: [psect(generate$data)]
				  treasure_type;
	down_steep		: [psect(generate$data)]
				  treasure_type;

	{ Following are creature arrays and variables			}
	c_list		: [psect(moria$data)]
			  array [1..max_creatures] of creature_type;
	m_list		: [psect(moria$data)]
			  array [0..max_malloc]    of monster_type;
	m_level		: [psect(generate$data)]
			  array [0..max_mons_level] of integer;
	blank_monster	: [psect(generate$data)]
			  monster_type;	{ Blank monster values	}
	muptr		: [psect(generate$data)]
			  integer;	{ Cur used monster ptr	}
	mfptr		: [psect(generate$data)]
			  integer;	{ Cur free monster ptr	}
	mon_tot_mult	: [psect(moria$data)]
			  integer;	{ # of repro's of creature	}

	{ Following are arrays for descriptive pieces			}
	colors			: [psect(setup$data)]
				  array [1..max_colors]	 of atype;
	mushrooms		: [psect(setup$data)]
				  array [1..max_mush]    of atype;
	woods			: [psect(setup$data)]
				  array [1..max_woods]   of atype;
	metals			: [psect(setup$data)]
				  array [1..max_metals]  of atype;
	horns			: [psect(setup$data)]
				  array [1..max_horns]	 of atype;
	rocks			: [psect(setup$data)]
				  array [1..max_rocks]   of atype;
	amulets			: [psect(setup$data)]
				  array [1..max_amulets] of atype;
	cloths			: [psect(setup$data)]
				  array [1..max_cloths] of atype;
	syllables		: [psect(setup$data)]
				  array [1..max_syllables] of dtype;
	vowel_set		: [psect(moria$data)]
				  char_set;

	{ Following are variables for the Save Character Routines	}
	finam			: [psect(save$data)]
				  vtype;
	key_rec			: [psect(save$data)]
				  key_type;

	{ Cursor variables, used for cursor positioning			}
	cursor_r	: [psect(io$data),global]
			  array [1..24] of varying[10] of char;
	curlen_r	: [psect(io$data),global] integer;
	cursor_c	: [psect(io$data),global]
			  array [1..80] of varying[10] of char;
	curlen_c	: [psect(io$data),global] integer;
	cursor_l	: [psect(io$data),global] integer;
	row_first	: [psect(io$data),global] boolean;
	cursor_erl	: [psect(io$data),global] varying[10] of char;
	cursor_erp	: [psect(io$data),global] varying[10] of char;
