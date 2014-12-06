
  type
	byteint		= [byte] 0..255;
	bytlint		= [byte] -128..127;
	wordint		= [word] 0..65535;
	worlint		= [word] -32768..32767;
	quad_type	= record
			    l0	: unsigned;
			    l1  : unsigned;
			  end;
	atype		= varying  [16] of char;
	btype		= varying  [14] of char;
	ctype		= varying  [26] of char;
	dtype		= varying   [5] of char;
	etype		= varying  [34] of char;
	htype		= varying  [12] of char;
	string		= varying [132] of char;
	mtype		= varying [190] of char;
	ntype		= varying[1024] of char;
	ttype		= varying  [68] of char;
	vtype		= varying  [80] of char;
	stat_type	= packed array [1..6] of char;
	account_type	= Varying  [10] of char;
	obj_set		= set of 0..255;
	char_set	= set of 'A'..'z';
	stat_set	= 0..5;
	stat_s_type	= array [stat_set] of byteint;
	ssn_type	= packed array [1..70] of char;
	key_type	= record		{ For char saver	}
		file_id : [key(0)] ssn_type;
		seed	: integer;
	end;
	money_type = array[total$..mithril] of integer;
	game_time_type = record
		year	: integer;
		month	: byteint;
		day	: byteint;
		hour	: byteint;
		secs	: wordint;
	end;
	time_type = record
		years		: wordint;
		months		: wordint;
		days		: wordint;
		hours		: wordint;
		minutes		: wordint;
		seconds		: wordint;
		hundredths	: wordint;
	end;
	creature_type = record
		aaf	: [bit(7),pos(0)] 0..127; { Area affect radius	}
		ac	: [bit(7),pos(8)] 0..127;	{ AC	}
		name	: ctype;	{ Descrip of creature	}
		cmove	: unsigned;	{ Bit field		}
		spells	: unsigned;	{ Creature spells	}
		cdefense: unsigned;	{ Bit field		}
		sleep	: worlint;	{ Inactive counter	}
		mexp	: integer;	{ Exp value for kill	}
		speed	: bytlint;	{ Movement speed	}
		cchar	: char;		{ Character rep.	}
		hd	: dtype;	{ Creatures hit die	}
		damage	: etype;	{ Type attack and damage}
		level	: bytlint;	{ Level of creature	}
		mr      : byteint;	{ Magic Resistance      }
	end;
	monster_type = record
		hp	: worlint;	{ Hit points		}
		csleep	: worlint;	{ Inactive counter	}
		cdis	: worlint;	{ Cur dis from player	}
		mptr	: wordint;	{ Pointer into creature	}
		nptr	: wordint;	{ Pointer to next block	}
		cspeed	: bytlint;	{ Movement speed	}

			{ Note: FY and FX constrain dungeon size to 255	}
		fy	: byteint;	{ Y Pointer into map	}
		fx	: byteint;	{ X Pointer into map	}

		stunned	: [bit(6),pos(104)] -32..31; { Rounds stunned}
		ml	: [bit(1),pos(110)] boolean; { On if shown   }
		confused: [bit(1),pos(111)] boolean; { On if confused}
		moved	: [bit(1),pos(112)] boolean; { On if water-moved}
	end;
	treasure_type = record
		name	: ttype;	{ Object name		}
		tval	: byteint;	{ Catagory number	}
		tchar	: char;		{ Character representation}
		flags2	: unsigned;	{ MORE Special flags	}
		flags	: unsigned;	{ Special flags		}
		p1	: integer;	{ Misc. use variable	}
		cost	: integer;	{ Cost of item		}
		subval	: integer;	{ Sub-catagory number	}
		weight	: wordint;	{ Weight in gp's	}
		number	: wordint;	{ Number of items	}
		tohit	: worlint;	{ Pluses to hit		}
		todam	: worlint;	{ Pluses to damage	}
		ac	: worlint;	{ Normal AC		}
		toac	: worlint;	{ Pluses to AC		}
		damage	: dtype;	{ Damage when hits	}
		level	: bytlint;	{ Level item found	}
	end;
	treas_rec = record
		data	: treasure_type;
		ok	: boolean;
		insides	: wordint;
		is_in	: boolean;
		next	: ^treas_rec;
	end;
	treas_ptr = ^treas_rec;
	player_type = record
		misc : record
			xtr_wgt : integer;	{ Extra weight limit	}
			account	: integer;	{ Money in the bank	}
			money	: money_type;	{ Money on person	}
			birth	: game_time_type;{Date of char's birth	}
			cur_age	: game_time_type;{Current game date	}
			play_tm	: time_type;	{ Time spent in game	}
			diffic	: byteint;	{ Difficulty of game	}
			ssn	: ssn_type;	{ Social Security Number}
			name	: vtype;	{ Name of character	}
			race	: vtype;	{ Race of character	}
			sex	: vtype;	{ Sex of character	}
			title	: vtype;	{ Character's title	}
			tclass	: vtype;	{ Character's class	}
			max_exp : integer;	{ Max experience}
			exp	: integer;	{ Cur experienc	}
			rep	: integer;	{ XP from good creatures }
			deaths	: integer;	{ Number of insured restores}
			premium	: integer;	{ Base cost to restore	}
			age	: wordint;	{ Characters age}
			ht	: wordint;	{ Height	}
			wt	: wordint;	{ Weight	}
			lev	: wordint;	{ Level		}
			max_lev	: wordint;	{ Max level explored}
			srh	: worlint;	{ Chance in search}
			fos	: worlint;	{ Frenq of search}
			bth	: worlint;	{ Base to hit	}
			bthb	: worlint;	{ BTH with bows	}
			mana	: worlint;	{ Mana points	}
			mhp	: worlint;	{ Max hit pts	}
			ptohit	: worlint;	{ Pluses to hit	}
			ptodam	: worlint;	{ Pluses to dam	}
			pac	: worlint;	{ Total AC	}
			ptoac	: worlint;	{ Magical AC	}
			dis_th	: worlint;	{ Display +ToHit}
			dis_td	: worlint;	{ Display +ToDam}
			dis_ac	: worlint;	{ Display +ToAC }
			dis_tac	: worlint;	{ Display +ToTAC}
			disarm  : worlint;	{ % to Disarm	}
			save	: worlint;	{ Saving throw	}
			sc	: worlint;	{ Social Class	}
			pclass	: byteint;	{ # of class	}
			prace	: byteint;	{ # of race	}
			hitdie	: byteint;	{ Char hit die	}
			stl	: bytlint;	{ Stealth factor}
			expfact	: real;		{ Experience factor}
			cmana	: real;		{ Cur mana pts  }
			chp	: real;		{ Cur hit pts	}
			history : array [1..5] of vtype;{ History record}
			cheated : boolean;	{ gone into wizard or god mode}
			mr	: integer;	{ mag.res.lev.delta }
{FUBAR}			quests	: byteint;	{ # completed }
{FUBAR}			cur_quest : wordint;    { creature # of quest }
      		end;
		stat : record
			p : array[stat_set] of byteint;{permanent}
			c : array[stat_set] of byteint;{current=p-l+m*10}
			m : array[stat_set] of bytlint;{net magical adj}
			l : array[stat_set] of byteint;{amt lost}
		end;
		flags : record
			insured		: boolean;	{ Character insured   }
			dead		: boolean;	{ Currently restored  }
			status		: unsigned;	{ Status of player    }
			rest		: integer;	{ Rest counter	      }
			blind		: integer;	{ Blindness counter   }
			paralysis	: integer;	{ Paralysis counter   }
			confused	: integer;	{ Confusion counter   }
			food		: integer;	{ Food counter        }
			food_digested	: integer;	{ Food per round      }
			protection	: integer;	{ Protection fr. evil }
			speed		: integer;	{ Cur speed adjust    }
			speed_paral	: integer;	{ Slow speed adjust   }
			speed_flag	: boolean;	{ On if reset speed   }
			paral_init	: integer;	{ Init val for slow   }
			move_rate	: integer;	{ move_rate	      }
			swim		: integer;	{ Cur swim adjust     }
			fast		: integer;	{ Temp speed change   }
			slow		: integer;	{ Temp speed change   }
			petrification	: integer;	{ Amount Petrified    }
			afraid		: integer;	{ Fear                }
			poisoned	: integer;	{ Poisoned            }
			image		: integer;	{ Hallucinate         }
 			protevil	: integer;	{ Protect VS evil     }
			invuln		: integer;	{ Increases AC        }
			hero		: integer;	{ Heroism	      }
			shero		: integer;	{ Super Heroism	      }
			blessed		: integer;	{ Blessed	      }
			resist_heat	: integer;	{ Timed heat resist   }
			resist_cold	: integer;	{ Timed cold resist   }
			detect_inv	: integer;	{ Timed see invisible }
			word_recall	: integer;	{ Timed teleport level}
			see_infra	: integer;	{ See warm creatures  }
			tim_infra	: integer;	{ Timed infra vision  }
			see_inv		: boolean;	{ Can see invisible   }
			teleport	: boolean;	{ Random teleportation}
			free_act	: boolean;	{ Never paralyzed     }
			slow_digest	: boolean;	{ Lower food needs    }
			aggravate	: boolean;	{ Agravate monsters   }
			fire_resist	: boolean;	{ Resistance to fire  }
			cold_resist	: boolean;	{ Resistance to cold  }
			acid_resist	: boolean;	{ Resistance to acid  }
			hunger_item	: boolean;	{ Resets food counter }
			regenerate	: boolean;	{ Regenerate hit pts  }
			lght_resist	: boolean;	{ Resistance to light }
			ffall		: boolean;	{ No damage falling   }
						        { keep characteristic }
			sustain		: array [0..5] of boolean;
			confuse_monster : boolean;	{ Glowing hands...    }
			resist_lght	: integer;	{ Timed lighting rst  }
			free_time	: integer;	{ Timed free action   }
			ring_fire	: integer;	{ Timed fire spell    }
			protmon		: integer;	{ Timed monst prot    }
			hoarse		: integer;	{ Timed no-bard spells}
			magic_prot	: integer;	{ Timed magic prot    }
			ring_ice	: integer;	{ Timed cold spell    }
			temp_stealth	: integer;	{ Timed stealth       }
			resist_petri	: integer;	{ Timed resist petrify}
			blade_ring	: integer;	{ Timed blade spell   }
			petri_resist    : boolean;	{ Resist Petrification}
{FUBAR}			quested		: boolean;	{ Performing a Quest  }
		end;
	end;
	spell_type = record
		sname	: ctype;
		slevel	: byteint;
		smana	: byteint;
		sexp	: wordint;
		sfail	: byteint;
		learned : boolean;
	end;
	spl_rec = record
		splnum	: integer;
		splchn	: integer;
	end;
	spl_type = array [1..max_spells] of spl_rec;
	race_type = packed record
		trace	: vtype;		{ Type of race		}
		adj	: array [stat_set] of bytlint;
		b_age	: wordint; { Base age of character	}
		m_age	: wordint; { Maximum age of character	}
		m_b_ht	: wordint; { base height for males	}
		m_m_ht	: wordint; { mod height for males	}
		m_b_wt	: wordint; { base weight for males	}
		m_m_wt	: wordint; { mod weight for males	}
		f_b_ht	: wordint; { base height females	}
		f_m_ht	: wordint; { mod height for females	}
		f_b_wt	: wordint; { base weight for female	}
		f_m_wt	: wordint; { mod weight for females	}
		b_exp	: real;	   { Base experience factor	}
		b_dis	: bytlint; { base chance to disarm	}
		srh	: bytlint; { base chance for search	}
		stl	: bytlint; { Stealth of character	}
		fos	: bytlint; { frequency of auto search	}
		bth	: bytlint; { adj base chance to hit	}
		bthb	: bytlint; { adj base to hit with bows	}
		bsav	: bytlint; { Race base for saving throw	}
		bhitdie	: bytlint; { Base hit points for race	}
		infra	: bytlint; { See infra-red		}
		swim	: bytlint; { Race base for swim speed	}
		tclass	: unsigned; { Bit field for class types	}
	end;
	class_type = record
		title	: vtype;	   { type of class		}
		m_exp	: real;		   { Class experience factor	}
		adj_hd	: bytlint;{ Adjust hit points		}
		mdis	: bytlint;{ mod disarming traps	}
		msrh	: bytlint;{ modifier to searching	}
		mstl	: bytlint;{ modifier to stealth	}
		mfos	: bytlint;{ modifier to freq-of-search	}
		mbth	: bytlint;{ modifier to base to hit/2 levels }
		mbthb	: bytlint;{ modifier to base to hit - bows/2 levels }
		msav	: bytlint;{ Class modifier to save	}
		madj	: array[stat_set] of bytlint;
		pspell	: boolean;	   { class use priest spells	}
		mspell	: boolean;	   { class use mage spells	}
		dspell  : boolean;	   { class use druid spells	}
		bspell	: boolean;	   { class use bardic spells	}
		mental  : boolean;	   { class use Monk disciplines }
		mr	: integer;	   { mag.res.class.delta        }
	end;
	background_type	= record
		info	: vtype;	   { History information	}
		roll	: byteint;   { Die roll needed for history}
		chart	: byteint;   { Table number		}
		next	: bytlint;{ Pointer to next table	}
		bonus	: bytlint;{ Bonus to the Social Class	}
	end;
	floor_type = record
		ftval	: [bit(7),pos(0)] 0..127;
		ftopen	: [bit(1),pos(7)] boolean;
	end;
	cave_type = record
		cptr	: byteint;
		tptr	: byteint;
		fval	: [bit(7),pos(16)] 0..127;
		fopen	: [bit(1),pos(23)] boolean;
		fm	: [bit(1),pos(24)] boolean;
		pl	: [bit(1),pos(25)] boolean;
		tl	: [bit(1),pos(26)] boolean;
		moved	: [bit(1),pos(27)] boolean;
		oct	: [bit(3),pos(28)] 0..7; { octant direction }
		h2o	: [bit(4),pos(31)] 0..15;
	end;
	row_floor  = array [1..max_width] of cave_type;
	owner_type = record
		owner_name	: vtype;
		max_cost	: worlint;
		max_inflate	: real;
		min_inflate	: real;
		haggle_per	: real;
		owner_race	: byteint;
		insult_max	: byteint;
	end;
	inven_record = record
		scost		: integer;
		sitem		: treasure_type;
	end;
	store_type = record
		store_open	: game_time_type;
		owner		: byteint;
		insult_cur	: bytlint;
		store_ctr	: byteint;
		store_inven	: array [1..store_inven_max] of inven_record;
	end;
	message_record = RECORD
		data		: string;
		next		: ^message_record;
	end;
	message_ptr = ^message_record;

























