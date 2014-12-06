{ Moria Version 4.8	COPYRIGHT (c) Robert Alan Koeneke		}
{                       Public Domain                                   }
{                                                                       }
{       I lovingly dedicate this game to hackers and adventurers        }
{       everywhere...                                                   }
{                                                                       }
{                                                                       }
{       Designer and Programmer : Robert Alan Koeneke                   }
{                                 University of Oklahoma                }
{                                                                       }
{       Assitant Programmers    : Jimmey Wayne Todd                     }
{                                 University of Oklahoma                }
{                                                                       }
{                                 Gary D. McAdoo                        }
{                                 University of Oklahoma                }
{                                                                       }
{       Moria may be copied and modified freely as long as the above    }
{       credits are retained.  No one who-so-ever may sell or market    }
{       this software in any form without the expressed written consent }
{       of the author Robert Alan Koeneke.                              }
{                                                                       }

[inherit('sys$share:starlet'), environment('moria.env')]

program moria(input,output);

	{ Globals						-RAK-	}
	%INCLUDE 'CONSTANTS.INC'
	%INCLUDE 'TYPES.INC'
	%INCLUDE 'VARIABLES.INC'
	%INCLUDE 'VALUES.INC'

	{ Libraries of routines; now modularized	      -KRC/DCJ-	}
	%INCLUDE 'ROUTINES.INC'

	{ Initialize, restore, and get the ball rolling...	-RAK-	}
  begin


	{ SYSPRV stays off except when needed...	}
    priv_switch(0);

	{ Get the time player entered game		}
    sys$gettim(start_time);

	{ Check the terminal type and see if it is supported}
    termdef;

	{ Get the directory location of the image	}
    get_paths;
	
	{ Here comes the monsters....                   }
    load_monsters;

	{ Check to see if an update is in progress		-DMF-	}
    if (check_kickout) then
      begin
	writeln('Imoria is locked . . . Try playing conquest.');
	writeln('Who knows *how* long this might take?');
	exit;
      end;

	{ Some necessary initializations		}
    msg_line       := 1;
    quart_height   := trunc(screen_height/4);
    quart_width    := trunc(screen_width /4);
    dun_level      := 0;
    new(inven_temp);
    inven_temp^.data := blank_treasure;
    inven_temp^.ok := false;
    inven_temp^.insides := 0;
    inven_temp^.next := nil;
    inven_temp^.is_in := false;
    caught_message := nil;
    old_message := nil;
    old_mess_count := 0;
    turn_counter := 100000;

	{ Init an IO channel for QIO			}
    init_channel;

	{ Grab a random seed from the clock		}
    seed := get_seed;

	{ Sort the objects by level			}
    sort_objects;

	{ Init monster and treasure levels for allocate }
    init_m_level;
    init_t_level;

	{ Init the store inventories			}
    store_init;
    if (cost_adj <> 1.00) then price_adjust;
    if (weight_adj <> 1) then item_weight_adjust;
    bank_init;

	{ Build the secret wizard and god passwords	}
    bpswd;

	{ Check operating hours 			}
	{ If not wizard then No_Control_Y               }
	{ Check or create hours.dat, print message	}
    intro(finam);

	{ Generate a character, or retrieve old one...	}
    if (length(finam) > 0) then
      begin     { Retrieve character    }
	generate := get_char(finam,true);
	py.flags.dead := true;
	is_from_file := true;
	save_char(false);
	change_name;
	magic_init(randes_seed);
      end
    else
      begin     { Create character      }
	is_from_file := false;
	finam := 'sys$scratch:MORIACHR.SAV';
	create_character;
	char_inven_init;
	if (class[py.misc.pclass].mspell) then
	  begin         { Magic realm   }
	    learn_spell(msg_flag);
	    gain_mana(spell_adj(iq));
	  end
	else if (class[py.misc.pclass].pspell) then
	  begin         { Clerical realm}
	    learn_prayer;
	    gain_mana(spell_adj(ws));
	  end
	else if (class[py.misc.pclass].dspell) then
	  begin		{ Druidical realm }
	    learn_druid;
	    gain_mana(druid_adj);
	  end
	else if (class[py.misc.pclass].bspell) then
	  begin		{ Bardic realm }
	    learn_song(msg_flag);
	    gain_mana(bard_adj);
	  end;
	py.misc.cmana := py.misc.mana;
	randes_seed := seed;            { Description seed      }
	town_seed   := seed;            { Town generation seed  }
	magic_init(randes_seed);
	generate := true;
      end;
      if (py.misc.pclass = 10) then bare_hands := '2d2';
      with class[py.misc.pclass] do
	if (mspell or pspell or dspell or bspell or mental) then
	  is_magii := true
	else
	  is_magii := false;

	{ Begin the game				}
      replace_name;
      set_gem_values;
      set_difficulty(py.misc.diffic);	{ Set difficulty of game	}
      with py.misc do     { This determines the maximum player level    }
	player_max_exp := trunc(player_exp[max_player_level-1]*expfact);
      clear(1,1);
      prt_stat_block;

	{ Turn on message trapping, if requested	}
    if (want_trap) then set_the_trap;

	{ Loop till dead, or exit			}
    repeat
      if (generate) then generate_cave;         { New level     }
      dungeon;                                  { Dungeon logic }
      generate := true;
    until (death);
    upon_death;                         { Character gets buried }
  end.
