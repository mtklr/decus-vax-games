{ Moria Version 5.0     COPYRIGHT (c) Robert Alan Koeneke
                        Public Domain
                   Modified EXTENSIVELY by:
                    Matthew W. Koch   -MWK
                    Kendall R. Sears  -Opusii
                   with minor help from:
                    Russell E. Billings -REB
                    David G. Strubel    -DGS

        I lovingly dedicate this game to hackers and adventurers
        everywhere...

        Designer and Programmer : Robert Alan Koeneke
                                  University of Oklahoma
        Assitant Programmer     : Jimmey Wayne Todd
                                  University of Oklahoma
                                                                    
        Moria may be copied and modified freely as long as the above
        credits are retained.  No one who-so-ever may sell or market
        this software in any form without the expressed written consent
        of the author Robert Alan Koeneke.}

{[environment('moria.env')]} program moria(input,output,Opusii,Matt);
                                                                 
        { Globals }
        %INCLUDE 'MOR_INCLUDE:CONSTANTS.INC'
        %INCLUDE 'MOR_INCLUDE:TYPES.INC'
        %INCLUDE 'MOR_INCLUDE:VARIABLES.INC'
        %INCLUDE 'MOR_INCLUDE:VALUES.INC'
        %INCLUDE 'MOR_INCLUDE:SPELL_VALUES.INC'
                
        { Libraries of routines }
        %INCLUDE 'MOR_INCLUDE:IO.INC'
        %INCLUDE 'MOR_INCLUDE:MISC.INC'
        %INCLUDE 'MOR_INCLUDE:DEATH.INC'
        %INCLUDE 'MOR_INCLUDE:HELP.INC'
        %INCLUDE 'MOR_INCLUDE:DESC.INC'
        %INCLUDE 'MOR_INCLUDE:USERID.INC'        {-MWK}
        %INCLUDE 'MOR_INCLUDE:BLACK_MARKET.INC'  {-WLP}
        %INCLUDE 'MOR_INCLUDE:FILES.INC'
        %INCLUDE 'MOR_INCLUDE:STORE1.INC'
        %INCLUDE 'MOR_INCLUDE:SAVE.INC'
        %INCLUDE 'MOR_INCLUDE:CREATE.INC'
        %INCLUDE 'MOR_INCLUDE:GENERATE.INC'
        %INCLUDE 'MOR_INCLUDE:MORIA.INC'
        %INCLUDE 'MOR_INCLUDE:DATAFILES.INC'
        %INCLUDE 'MOR_INCLUDE:TERMDEF.INC'
 
{ Initialize, restore, and get the ball rolling.
  
Read in the critters' flags and convert them.  -Opusii}



 BEGIN
 
        { SYSPRV stays off except when needed...}
    priv_switch(0);
 
        { Check the terminal type and see if it is supported}
    termdef;
 
        { Get the directory location of the image}
    get_paths;
 
        { Setup pause time for IO
          setup_io_pause;
 
         Some neccesary initializations }
    msg_line       := 1;
    quart_height   := trunc(screen_height/4);
    quart_width    := trunc(screen_width /4);
    dun_level      := 0;
 
{ Init an IO channel for QIO }
    init_channel;
 
{ Grab a random seed from the clock }
    seed := get_seed;


	read_data;
                

{ Sort the objects by level }
    sort_objects;
 
        { Init monster and treasure levels for allocate }
    init_m_level;
    init_t_level;
 
        { Init the store inventories }
    store_init;
    if (cost_adj <> 1.00) then price_adjust;
 
{ The Wizard and God Passwords have been removed. Valid Wizards are determined
  based on acct. name. }
                      
        { Check operating hours 
          If not wizard then No_Control_Y }
    get_foreign(finam);
 
        { Check or create hours.dat, print message }
    intro(finam);
 
        { Generate a character, or retrieve old one...  }
    if (length(finam) > 0) then
      BEGIN     { Retrieve character }
        generate := get_char(finam);
        change_name;
        magic_init(randes_seed)
      END
    else
      BEGIN     { Create character }
        create_character;
        char_inven_init;
        if (class[py.misc.pclass].mspell) then
          BEGIN         { Magic realm }
            learn_spell(msg_flag);
            gain_mana(int_adj)
          END
        else if (class[py.misc.pclass].pspell) then
          BEGIN         { Clerical realm}
            learn_prayer;
            gain_mana(wis_adj)
          END;
	if (class[py.misc.pclass].espell) then
	  BEGIN
	    learn_extra(msg_flag);
	    gain_mana(wis_adj)
	  END;

        py.misc.cmana := py.misc.mana;
        randes_seed := seed;            { Description seed }
        town_seed   := seed;            { Town generation seed  }
        magic_init(randes_seed);
        generate := true
      END;
 
{ begin the game }
      with py.misc do     { This determines the maximum player level }
        player_max_exp := trunc(player_exp[max_player_level-1]*expfact);
      clear(1,1);                                                
      prt_stat_block;
 
{ Loop till dead, or exit }
    repeat
      if (generate) then generate_cave; { New level }
      dungeon; { Dungeon logic }
      generate := true;
    until (death);
    upon_death; { Character gets buried }
  END.
                                                             
     
