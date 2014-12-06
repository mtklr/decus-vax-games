const
{Note to the Wizard:
   Tweaking these constants can *GREATLY* change the game.
   Two years of constant tuning have generated these values.
   Minor adjustments are encouraged, but you must be very
   careful not to unbalance the game.  Moria was meant to be
   challenging, not a give away.  Many adjustments can cause
   cause the game to act strangely, or even cause errors.
 
Current version number of Moria  }
        cur_version   = 5.0;
 
{ QIOW constants, see $IODEF in STARLET.MLB }
        IO$_WRITEVBLK = %B'0000000000110000';   {  48D, 0030H   }
        IO$_TTYREADALL= %B'0000000000111010';   {  58D, 003AH   }
        IO$M_NOECHO   = %B'0000000001000000';   {  64D, 0040H   }
        IO$M_NOWAIT   = %B'0000000010000000';   { 128D, 0080H   }
        IO$M_PURGE    = %B'0000100000000000';   {2048D, 0800H   }
        IO$MOR_OUTPUT = IO$_WRITEVBLK;
        IO$MOR_INPUT  = IO$_TTYREADALL + IO$M_NOECHO;
        IO$MOR_DELAY  = IO$MOR_INPUT   + IO$M_NOWAIT;
        IO$MOR_IPURGE = IO$MOR_DELAY   + IO$M_PURGE;
 
{ IO bug exists at high baud rates (baud >= 9600).  This bug
  is believed to be in the device driver.  It can be avoided by
  hibernating the process a small amount of time before perform-
  ing a QIOW read operation. }
        IO$MOR_IOPAUSE= 5;  { x/100 secs of sleep before inkey
 
  ENCRYPTION CONSTANTS                                          
  NOTE: These numbers were pulled from the air, and can be      
        changed.  If changed, characters produced from other    
        versions will fail to restore.}


        encrypt_seed1 = 342342;
        encrypt_seed2 = 342944081;
 
{ DUNGEON SIZE PARAMETERS }
        max_height    = 66;     { Multiple of 11; >= 22 }
        max_width     = 198;    { Multiple of 33; >= 66 }
        screen_height = 22;
        screen_width  = 66;
 
{ OUTPUT DUNGEON SECTION SIZES }
        outpage_height= 44;{ 44 lines of dungeon/section }
        outpage_width = 99;{ 100 columns of dungeon/section }
 
{ DUNGEON GENERATION VALUES
  NOTE: The entire design of dungeon can be changed by only
        slight adjustments here. }
        dun_tun_rnd  = 36; { Rand dir (4 is min) }
        dun_tun_chg  = 70; { Chance of changing dir (99 max) }
        dun_tun_fnd  = 12; { Distance for auto find to kick in }
        dun_tun_con  = 15; { Chance of extra tunneling }
        dun_roo_mea  = 32; { Mean of # of rooms, std dev=2 }
        dun_tun_pen  = 25; { % chance of room doors }
        dun_tun_jct  = 15; { % chance of doors at tunnel junctons }
        dun_str_den  = 5;  { Density of streamers }
        dun_str_rng  = 2;  { Width of streamers }
        dun_str_mag  = 3;  { # of magma streamers }
        dun_str_mc   = 95; { 1/x chance of treasure/magma }
        dun_str_qua  = 2;  { # of quartz streamers }
        dun_str_qc   = 55; { 1/x chance of treasure/quartz }
        dun_unusual  = 300;{ Level/x chance of unusual room }
                           
{ STORE CONSTANTS }
        max_owners   = 21;   { # of owners to choose from }
        max_stores   = 7;    { # of different stores }
        store_inven_max = 24;{ Max # of discrete objs in inven  }
        store$choices = 26;  { # of items to choose stock from  }
        store$max_inven = 20;{ Max diff objs in stock before auto sell}
        store$min_inven = 14;{ Min diff objs in stock before auto buy}
        store$turn_around = 3;{ Amt of buying and selling normally }
        bmstore$turn_around = 20;{ Amt of buying and selling normally }
        inven_init_max = 106;{ Size of store init array }
        blk_mkt_max = 176;{ Size of black mkt store array }
        cost_adj = 1.00; { Adjust prices for buying and selling  }
 
{ TREASURE CONSTANTS }
        inven_max = 35;     { Size of inventory array(DO NOT CHANGE)}
        max_obj_level = 50; { Max level of magic in dungeon }
        obj_great = 14;     { 1/n Chance of item being a Great Item }
        max_objects = 351;  { # of objects for universe }
        max_gold  = 18;     { # of different types of gold }
        max_talloc = 225;   { Max objects/level }
        treas_room_alloc = 8;{ Amt of objects for rooms }
        treas_any_alloc = 2;{ Amt of objects for corridors }
        treas_gold_alloc = 2;{ Amt of gold (and gems) }
 
{ MAGIC TREASURE GENERATION CONSTANTS
  NOTE: Number of special objects, and degree of enchantments
        can be adjusted here. }
        obj_std_adj = 1.25; { Adjust STD/level }
        obj_std_min = 7;    { Minimum STD }
        obj_town_level = 5; { Town object generation level }
        obj_base_magic = 20;{ Base amt of magic }
        obj_base_max = 70;  { Max amt of magic }
        obj_div_special = 7;{ magic_chance/# = special magic }
        obj_div_cursed = 1.3;{ magic_chance/# = cursed items }
 
{ CONSTANTS DESCRIBING LIMITS OF CERTAIN OBJECTS }
        obj$lamp_max = 15000; { Max amt that lamp can be filled}
        obj$bolt_range = 18;  { Max range of bolts and balls }
 
{ CREATURE CONTANTS }
{        max_creatures = 278; { # of creatures defined for univ }
        max_malloc = 100 + 1;{ Max that can be allocated }
        max_malloc_chance = 170; { 1/x chance of new monster each round }
        max_mons_level = 40; { Max level of creatures }
        max_sight =  20; { Max dist a creature can be seen }
        max_spell_dis = 20; { Max dist creat. spell can be cast }
        max_mon_mult = 80; { Max reproductions on a level }
        mon_mult_adj = 7; { High value slows multiplication }
        mon_nasty = 50; { Dun_level/x chance of high level creature }
        min_malloc_level = 20; { Min # of monsters/level }
        min_malloc_td = 4; { # of people on town level (day) }
        min_malloc_tn = 8; { # of people on town level (night)}
        win_mon_tot = 1; { Total number of "win" creatures }
        win_mon_appear = 70; { Level where winning creatures begin }
        mon$summon_adj = 2; { Adjust level of summoned creatures }
        mon$drain_life = 2; { % of player exp drained/hit }
 
{ TRAP CONSTANTS }
        max_trapa = 19; { # of defined traps }
        max_trapb = 20; { Includes secret doors }
 
{ DESCRIPTIVE CONSTANTS }
        max_colors = 67; { Used with potions }
        max_mush = 29;   { Used with mushrooms }
        max_woods = 41;  { Used with staves }
        max_metals = 31; { Used with wands }
        max_rocks = 52;  { Used with rings }
        max_amulets = 39;{ Used with amulets }
        max_syllables = 153; { Used with scrolls }
 
{ PLAYER CONSTANTS }
        max_player_level = 46;  { Max possible char level }
        max_races = 8; { # of defined races }
        max_class = 8; { # of defined classes }
        use_device = 3;{ x> Harder devices x< Easier devices }
        max_background = 128; { # of types of histories for univ }
        player_food_full = 7500;{ Getting full }
        player_food_max = 12500;{ Max food value, beyond is wasted  }
        player_food_faint = 180; { Char begins fainting }
        player_food_weak = 650; { Warn player that he is getting very low}
        player_food_alert = 1100; { Warn player that he is getting low }
        player$regen_faint = 0.002; { Regen factor  fainting }
        player$regen_weak = 0.004; { Regen factor  weak }
        player$regen_normal = 0.006; { Regen factor  full }
        player$regen_hpbase = 0.025; { Min amt hp regen }
        player$regen_mnbase = 0.075; { Min amt mana regen }
        player_weight_cap = 130; { 100*(1/10 pounds)/strength pt }
        player_exit_pause = 5; { Pause time before player can re-roll  }
 
{ BASE TO HIT CONSTANTS }
        bth_lev_adj = 3; { Adjust BTH/level }
        bth_plus_adj = 3; { Adjust BTH/plus-to-hit }
        bth_hit = 12; { Automatic hit; 1/bth_hit }
 
{ MISC }
        null = chr(0);
                        
