  value
 
	wizard1		:= false;
	wizard2		:= false;
	{ God and Wizard passwords: God is for debugging purposes only. }
	wdata		:=(
		(457867,180,157,35,220,14,127,160,163,38,68,135,50),
		(698297,10,5,91,148,139,60,167,62,184,175,229,147)
			  );
	used_line	:= (22 of false);
	death		:= false;
	total_winner	:= false;
	turn		:= 0;
	pclass		:= 0;
	print_stat	:= 0;
	coin$value	:= (0,1,4,20,240,960,12480);
 
	{ For the testing of bits				-RAK-	}
	bit_array	:= (
		%X'00000001',	{ Bit number 1	}
		%X'00000002',	{ Bit number 2	}
		%X'00000004',	{ Bit number 3	}
		%X'00000008',	{ Bit number 4	}
		%X'00000010',	{ Bit number 5	}
		%X'00000020',	{ Bit number 6	}
		%X'00000040',	{ Bit number 7	}
		%X'00000080',	{ Bit number 8	}
		%X'00000100',	{ Bit number 9	}
		%X'00000200',	{ Bit number 10 }
		%X'00000400',	{ Bit number 11 }
		%X'00000800',	{ Bit number 12 }
		%X'00001000',	{ Bit number 13 }
		%X'00002000',	{ Bit number 14 }
		%X'00004000',	{ Bit number 15 }
		%X'00008000',	{ Bit number 16 }
		%X'00010000',	{ Bit number 17 }
		%X'00020000',	{ Bit number 18 }
		%X'00040000',	{ Bit number 19 }
		%X'00080000',	{ Bit number 20 }
		%X'00100000',	{ Bit number 21 }
		%X'00200000',	{ Bit number 22 }
		%X'00400000',	{ Bit number 23 }
		%X'00800000',	{ Bit number 24 }
		%X'01000000',	{ Bit number 25 }
		%X'02000000',	{ Bit number 26 }
		%X'04000000',	{ Bit number 27 }
		%X'08000000',	{ Bit number 28 }
		%X'10000000',	{ Bit number 29 }
		%X'20000000',	{ Bit number 30 }
		%X'40000000',	{ Bit number 31 }
		%X'80000000'	{ Bit number 32 }
			);
 
	{ Operating hours for Moria				-RAK-	}
	{	X = Open; . = Closed					}
	days	:=(
		'SUN:XXXXXXXXXXXXXXXXXXXXXXXX|',
		'MON:XXXXXXXX.........XXXXXXX|',
		'TUE:XXXXXXXX.........XXXXXXX|',
		'WED:XXXXXXXX.........XXXXXXX|',
		'THU:XXXXXXXX.........XXXXXXX|',
		'FRI:XXXXXXXX.........XXXXXXX|',
		'SAT:XXXXXXXXXXXXXXXXXXXXXXXX|'
		   );
 
	closing_flag := 0;
 
	{ Values for floor types					}
	blank_floor:= (0,0,0,false,false,false,false,false,0,0);
	dopen_floor	:= (  1,true ); { Dark open floor	}
	lopen_floor	:= (  2,true ); { Light open floor	}
	corr_floor1	:= (  4,true ); { Corridor open floor	}
	corr_floor2	:= (  5,true ); { Room junction marker	}
	corr_floor3	:= (  6,true ); { Door type floor	}
	corr_floor4	:= (  7,false); { Secret door type floor}
	{ Floor values 8 and 9 are used in generate		}
	rock_wall1	:= ( 10,false); { Granite rock wall	}
	rock_wall2	:= ( 11,false); { Magma rock wall	}
	rock_wall3	:= ( 12,false); { Quartz rock wall	}
	boundry_wall	:= ( 15,false); { Indestructable wall	}
	water1		:= ( 16,true);	{ Water on floor	}
	water2		:= ( 17,true);	{ Water on room floor	}
	water3		:= ( 18,true);	{ Lit water on floor	}
 
	{ Player record is special					}
	py		:=	(
	(0,0,(0,0,0,0,0,0,0),(0,0,0,0,0),(0,0,0,0,0),(0,0,0,0,0,0,0),3,
	 ' ',' ',' ',' ',' ',' ',
	 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,
	 ('','','','',''),false,0,0,0),
	((0,0,0,0,0,0),(0,0,0,0,0,0),(0,0,0,0,0,0),(0,0,0,0,0,0)),
	(false,false,0,0,0,0,0,7500,2,0,0,0,false,
	 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,
	 false,false,false,false,false,false,false,false,false,
	 false,false,false,(false,false,false,false,false,false),false,
	 0,0,0,0,0,0,0,0,0,0,false,false)
				);

	key_of	:= (6,9,8,7,4,1,2,3,5);
	oct_of	:= (5,6,7,4,8,0,3,2,1);
	dx_of	:= (-1,0,1,-1,0,1,-1,0,1);
	dy_of	:= (1,1,1,0,0,0,-1,-1,-1);
	bare_hands	:= '1d1';
 
	acc_exp		:= 0.0;
 
	{ Each character class has a list of spells they can use.  In	}
	{ cases the entire array is blank				}
 
	magic_spell :=	    (	    (		    { Warrior	    }
 (''				,99,99,	 0,  0,false),
 (''				,99,99,	 0,  0,false),
 (''				,99,99,	 0,  0,false),
 (''				,99,99,	 0,  0,false),
 (''				,99,99,	 0,  0,false),
 (''				,99,99,	 0,  0,false),
 (''				,99,99,	 0,  0,false),
 (''				,99,99,	 0,  0,false),
 (''				,99,99,	 0,  0,false),
 (''				,99,99,	 0,  0,false),
 (''				,99,99,	 0,  0,false),
 (''				,99,99,	 0,  0,false),
 (''				,99,99,	 0,  0,false),
 (''				,99,99,	 0,  0,false),
 (''				,99,99,	 0,  0,false),
 (''				,99,99,	 0,  0,false),
 (''				,99,99,	 0,  0,false),
 (''				,99,99,	 0,  0,false),
 (''				,99,99,	 0,  0,false),
 (''				,99,99,	 0,  0,false),
 (''				,99,99,	 0,  0,false),
 (''				,99,99,	 0,  0,false),
 (''				,99,99,	 0,  0,false),
 (''				,99,99,	 0,  0,false),
 (''				,99,99,	 0,  0,false),
 (''				,99,99,	 0,  0,false),
 (''				,99,99,	 0,  0,false),
 (''				,99,99,	 0,  0,false),
 (''				,99,99,	 0,  0,false),
 (''				,99,99,	 0,  0,false),
 (''				,99,99,	 0,  0,false),
 (''				,99,99,	 0,  0,false),
 (''				,99,99,	 0,  0,false),
 (''				,99,99,	 0,  0,false),
 (''				,99,99,	 0,  0,false),
 (''				,99,99,	 0,  0,false),
 (''				,99,99,	 0,  0,false),
 (''				,99,99,	 0,  0,false),
 (''				,99,99,	 0,  0,false),
 (''				,99,99,	 0,  0,false)
					),
					(		{ Mage		}
{ 1} ('Magic Missile'		    , 1, 1,  5, 22,false),
{ 2} ('Detect Monsters'		    , 1, 1,  5, 23,false),
{ 3} ('Phase Door'		    , 1, 2,  4, 24,false),
{ 4} ('Light Area'		    , 1, 2,  4, 26,false),
{ 5} ('Cure Light Wounds'	    , 3, 3,  8, 25,false),
{ 6} ('Find Hidden Traps/Doors'	    , 3, 3,  6, 55,false),
{ 7} ('Stinking Cloud'		    , 3, 4,  8, 27,false),
{ 8} ('Confusion'		    , 3, 4,  6, 30,false),
{ 9} ('Lightning Bolt'		    , 5, 4, 25, 30,false),
{10} ('Trap/Door Destruction'	    , 5, 5, 30, 30,false),
{11} ('Sleep I'			    , 5, 5, 20, 30,false),
{12} ('Cure Poison'		    , 5, 5, 25, 35,false),
{13} ('Shadow Door'		    , 7, 6, 35, 35,false),
{14} ('Remove Curse'		    , 7, 6, 40, 50,false),
{15} ('Frost Bolt'		    , 7, 6, 50, 40,false),
{16} ('Create Food'		    , 7, 6, 50, 40,false),
{17} ('Infravision'		    , 7, 6, 50, 40,false),
{18} ('Invisibility'		    , 7, 6, 60, 35,false),
{19} ('Turn Stone to Mud'	    , 9, 7, 75, 44,false),
{20} ('Recharge Item I'		    , 9, 7, 90, 75,false),
{21} ('Sleep II'		    , 9, 7, 75, 45,false),
{22} ('Phantasmal Force'	    ,11, 7, 80, 50,false),
{23} ('Polymorph Other'		    ,11, 7,100, 45,false),
{24} ('Identify'		    ,11, 7, 75, 99,false),
{25} ('Ring of Frost'		    ,13, 7, 75, 45,false),
{26} ('Sleep III'		    ,13, 7, 90, 50,false),
{27} ('Hold Monster'		    ,15, 9,100, 50,false),
{28} ('Fire Bolt'		    ,15, 9,100, 50,false),
{29} ('Slow Creature'		    ,17, 9,125, 50,false),
{30} ('Protection from Magic'	    ,17, 9,125, 55,false),
{31} ('Frost Ball'		    ,19,12,150, 55,false),
{32} ('Death Spell'		    ,19,18,200, 55,false),
{33} ('Ring of Fire'		    ,21,12,175, 60,false),
{34} ('Recharge Item II'	    ,21,12,175, 90,false),
{35} ('Teleport Other'		    ,23,15,200, 60,false),
{36} ('Haste Self'		    ,25,15,250, 65,false),
{37} ('Fire Ball'		    ,28,18,350, 65,false),
{38} ('Power Word: Destruction'	    ,31,21,500, 80,false),
{39} ('Power Word: Kill'	    ,34,25,600, 80,false),
{40} ('Genocide'		    ,37,25,800, 95,false)
			),
					(		{ Priest	}
{ 1} ('Detect Evil'		    , 1, 1,  3, 10,false),
{ 2} ('Cure Light Wounds'	    , 1, 2,  4, 15,false),
{ 3} ('Bless'			    , 1, 2,  3, 20,false),
{ 4} ('Remove Fear'		    , 1, 2,  3, 25,false),
{ 5} ('Call Light'		    , 3, 2,  6, 25,false),
{ 6} ('Find Traps'		    , 3, 3,  8, 27,false),
{ 7} ('Detect Doors/Stairs'	    , 3, 3,  8, 27,false),
{ 8} ('Slow Poison'		    , 3, 3, 10, 28,false),
{ 9} ('Blind Creature'		    , 5, 4, 16, 29,false),
{10} ('Portal'			    , 5, 4, 20, 30,false),
{11} ('Cure Medium Wounds'	    , 5, 4, 20, 32,false),
{12} ('Ray of Sanctification'	    , 5, 4, 20, 40,false),
{13} ('Heroism'			    , 7, 4, 20, 40,false),
{14} ('Sanctuary'		    , 7, 5, 30, 36,false),
{15} ('Remove Curse'		    , 7, 6, 35, 38,false),
{16} ('Resist Heat and Cold'	    , 7, 7, 35, 38,false),
{17} ('Silence'			    , 9, 7, 40, 40,false),
{18} ('Resist Petrification'	    , 9, 7, 40, 40,false),
{19} ('Neutralize Poison'	    , 9, 7, 40, 38,false),
{20} ('Cure Serious Wounds'	    , 9, 7, 40, 40,false),
{21} ('Chant'			    ,11, 8, 20, 34,false),
{22} ('Sense Invisible'		    ,11, 8, 40, 42,false),
{23} ('Protection from Evil'	    ,11, 8, 50, 42,false),
{24} ('Earthquake'		    ,11, 9, 60, 55,false),
{25} ('Create Food and Drink'	    ,13, 9, 30, 38,false),
{26} ('Sense Surroundings'	    ,13,10, 60, 45,false),
{27} ('Orb of Draining'		    ,13,10, 40, 58,false),
{28} ('Cure Critical Wounds'	    ,15,11, 65, 45,false),
{29} ('Turn Undead'		    ,15,12, 80, 50,false),
{30} ('Holy Prayer'		    ,17,14, 90, 50,false),
{31} ('Dispell Undead'		    ,17,14,125, 55,false),
{32} ('Resist Paralysis'	    ,19,15,150, 55,false),
{33} ('Blade Barrier'		    ,21,16,175, 60,false),
{34} ('Dispel Evil'		    ,23,18,200, 70,false),
{35} ('Heal'			    ,25,20,250, 60,false),
{36} ('Resist Magic'		    ,27,22,300, 80,false),
{37} ('Holy of Thunder'		    ,30,23,400, 70,false),
{38} ('Glyph of Warding'	    ,33,24,500, 90,false),
{39} ('Hero''s Feast'		    ,35,28,600, 95,false),
{40} ('Holy Word'		    ,39,32,800, 99,false)
					),
					(		{ Rogue	       }
 ('Detect Monsters'		, 3, 2,	 6, 35,false),
 ('Battle Song'			, 3, 2,  7, 35,false),
 ('Blink'			, 3, 2,	 8, 35,false),
 ('Light Area'			, 5, 4,	 8, 35,false),
{5} ('Find Hidden Doors/Traps'	, 5, 5, 10, 45,false),
 ('Magical Jig'			, 7, 8, 15, 40,false),
 ('Detect Magic'		, 7, 9, 20, 70,false),
 (''				,99,99,	 0,  0,false),
 ('Battle Dance'		, 9,10,	25, 45,false),
{10} ('Charm Monsters'		, 9,11, 40, 50,false),
 ('Detect Curse'		,11,12, 30, 40,false),
 ('Detect Invisible'		,11,12,	35, 40,false),
 ('Cure Poison'			,13,14, 40, 45,false),
 ('Invisibility'		,15,16, 50, 50,false),
{15} ('Shadow Gate'		,17,18, 60, 55,false),
 (''				,99,99,	 0,  0,false),
 (''				,99,99,	 0,  0,false),
 ('Recharge Item'		,19,18, 70, 55,false),
 ('Remove Curse'		,21,20, 50, 90,false),
{20} ('Legend Lore'		,23,22, 80, 95,false),
 (''				,99,99,	 0,  0,false),
 ('Detect Treasure'		,25,25, 60, 50,false),
 ('Detect Object'		,25,25, 60, 55,false),
 (''				,99,99,	 0,  0,false),
{25} (''			,99,99,  0,  0,false),
 (''				,99,99,	 0,  0,false),
 ('Word of Recall'		,27,27, 90, 60,false),
 (''				,99,99,  0,  0,false),
 ('See Invisible'		,29,29,100, 65,false),
{30} ('Magic Mapping'		,31,30,110, 70,false),
 (''				,99,99,	 0,  0,false),
 ('Battle Frenzy'		,33,31,125, 70,false),
 (''				,99,99,	 0,  0,false),
 ('Resist Charm'		,35,32,150, 70,false),
{35} ('Item Lore'		,37,33,200, 95,false),
 (''				,99,99,	 0,  0,false),
 (''				,99,99,	 0,  0,false),
 (''				,99,99,	 0,  0,false),
 (''				,99,99,	 0,  0,false),
 (''				,99,99,	 0,  0,false)
					),
					(		{ Ranger	}
('Moon Beam'		       , 1,  2,	 3, 20,false),
('Detect Monster'	       , 1,  2,	 5, 33,false),
('Battle Song'		       , 2,  3,	 8, 35,false),
('Light'		       , 2,  3, 13, 35,false),
{5}('Minor Cure'	       , 3,  4, 15, 40,false),
('Find Safe Path'	       , 4,  5, 10, 45,false),
('Magical Jig'		       , 4,  5, 17, 45,false),
('Warp Wood'		       , 4,  5, 17, 45,false),
('Battle Dance'		       , 5,  5, 25, 40,false),
{10}('Cure Poison'	       , 5,  5, 30, 48,false),
('Charm'		       , 7,  5, 35, 35,false),
('Detect Curse'		       , 7,  6, 40, 45,false),
('Summon Insects'	       , 7,  7, 40, 50,false),
('Call Lightning'	       , 9,  9, 40, 55,false),
{15}('Magic Resistance'	       , 9, 10, 45, 45,false),
(''			       ,99, 99,	 0,  0,false),
('Create Food'		       , 9, 10, 40, 55,false),
('Remove Curse'		       ,11, 10, 50, 45,false),
('Infravision'		       ,11, 10, 50, 50,false),
{20}('Major Cure'	       ,11, 11, 55, 50,false),
('Resist Petrification'	       ,13, 11, 60, 55,false),
('Transplant'		       ,13, 11, 60, 45,false),
(''			       ,99, 99,	 0,  0,false),
('Dispell Magic'	       ,15, 11, 60, 58,false),
{25}('Fire Stream'	       ,15, 11, 60, 70,false),
('Protection from Nature'      ,17, 12, 65, 55,false),
('Stone to Mud'		       ,17, 12, 65, 55,false),
('Goodberry'		       ,19, 14, 70, 65,false),
('Creeping Doom'	       ,37, 21,120, 65,false),
{30}('Pillar of Fire'	       ,23, 15, 80, 65,false),
('Word of Recall'	       ,25, 15, 85, 50,false),
('Lightning Ball'	       ,27, 15, 90, 90,false),
('Word of Blindness'	       ,29, 16, 95, 55,false),
('Protection from Monsters'    ,31, 20,100, 60,false),
(''			       ,99, 99,	 0,  0,false),
(''			       ,99, 99,	 0,  0,false),
('Resist Charm'		       ,33, 22,110, 65,false),
('Battle Frenzy'	       ,35, 25,125, 65,false),
('Dispel Monster'	       ,37, 30,200, 70,false),
(''			       ,99, 99,  0,  0,false)
				),
 
					(		{ Paladin	}
 ('Detect Evil'			, 1, 1,	 4, 30,false),
 ('Cure Light Wounds'		, 2, 2,	 8, 35,false),
 ('Bless'			, 3, 3, 12, 35,false),
 ('Remove Fear'			, 5, 3, 20, 35,false),
 ('Call Light'			, 5, 4, 20, 35,false),
 ('Find Traps'			, 7, 5, 25, 40,false),
 ('Detect Doors/Stairs'		, 7, 5, 25, 40,false),
{8} ('Slow Poison'		, 9, 7, 30, 40,false),

 ('Blind Creature'		, 9, 7, 30, 40,false),
 ('Portal'			, 9, 8, 30, 40,false),
 ('Cure Medium Wounds'		,11, 9, 40, 40,false),
 ('Ray of Sanctification'	,11, 9, 40, 40,false),
 ('Heroism'			,11, 9, 40, 40,false),
 ('Sanctuary'			,13,10, 40, 45,false),
 ('Remove Curse'		,13,11, 50, 45,false),
 ('Resist Heat and Cold'	,15,13, 60, 45,false),
 ('Silence'			,15,13, 60, 45,false),
{18} ('Resist Petrification'	,15,13, 60, 50,false),

 ('Neutralize Poison'		,15,15, 60, 50,false),
 ('Cure Serious Wounds'		,17,15, 70, 50,false),
 ('Chant'			,17,15, 70, 50,false),
 ('Sense Invisible'		,19,15, 75, 50,false),
 ('Protection from Evil'	,19,15, 75, 50,false),
 ('Earthquake'			,21,17, 80, 50,false),
 ('Create Food and Drink'	,21,10, 50, 45,false),
 ('Sense Surroundings'		,23,17, 80, 50,false),
 ('Orb of Draining'		,23,20, 70, 85,false),
 ('Cure Critical Wounds'	,25,20, 80, 50,false),
 ('Turn Undead'			,25,21, 90, 50,false),
 ('Holy Prayer'			,27,22,100, 50,false),

 ('Dispell Undead'		,29,24,110, 60,false),
 ('Resist Paralysis'		,31,26,125, 55,false),
 ('Blade Barrier'		,33,27,150, 60,false),
 ('Dispell Evil'		,35,28,175, 70,false),
 ('Heal'			,37,32,200, 75,false),
 ('Resist Magic'		,38,32,250, 75,false),
 ('Holy Thunder'		,39,30,250, 80,false),
 (''				,99,99,  0,  0,false),
 (''				,99,99,  0,  0,false),
 (''				,99,99,  0,  0,false)
					),
					(		 { Druid     }
{ 1}('Moon Beam'			,1,  1,	 3, 15,false),
    ('Detect Monster'			,1,  1,	 4, 15,false),
    ('Battle Song'			,1,  2,	 4, 20,false),
    ('Light'				,1,  2,	 4, 25,false),
{ 5}('Minor Cure'			,3,  3,	 8, 25,false),
    ('Find Safe Path'			,3,  3,	 8, 28,false),
    ('Magical Jig'			,3,  3, 10, 27,false),
    ('Warp Wood'			,3,  4, 12, 29,false),
    ('Battle Dance'			,5,  4, 20, 30,false),
{10}('Cure Poison'			,5,  4, 25, 30,false),
    ('Charm'    			,5,  5, 35, 45,false),
    ('Detect Curse'			,5,  5, 40, 50,false),
    ('Summon Insects'			,7,  5, 35, 35,false),
    ('Call Lightning'			,7,  5, 35, 38,false),
{15}('Magic Resistance'			,7,  6, 45, 40,false),
    ('Starlight'			,7,  6, 45, 40,false),
    ('Create Food'			,9,  6, 40, 40,false),
    ('Remove Curse'			,9,  6, 45, 55,false),
    ('Infravision'			,9,  7, 60, 40,false),
{20}('Major Cure'			,9,  7, 70, 40,false),
    ('Resist Petrification'		,11,  7, 60, 45,false),
    ('Transplant'			,11,  8, 70, 55,false),
    ('Sunray'				,11,  9, 70, 60,false),
    ('Dispell Magic'			,11,  9, 80, 50,false),
{25}('Fire Stream'			,11,  9, 80, 65,false),
    ('Protection from Nature'		,13,  9, 90, 40,false),
    ('Stone to Mud'			,13,  9,100, 50,false),
    ('Goodberry'			,15, 11,100, 50,false),
    ('Creeping Doom'			,33, 17,200, 65,false),
{30}('Pillar of Fire'			,15, 11,110, 55,false),
    ('Word of Recall'			,17, 11,100, 60,false),
    ('Lightning Ball'			,17, 12,100, 55,false),
    ('Word of Blindness'		,19, 12,120, 55,false),
    ('Protection from Monsters'		,21, 14,140, 55,false),
    ('Control Temperature'		,23, 17,160, 60,false),
    ('Ring of Fire'			,25, 19,180, 75,false),
    ('Resist Charm'			,27, 21,200, 75,false),
    ('Battle Frenzy'			,29, 23,300, 70,false),
    ('Dispel Monster'			,31, 25,400, 80,false),
    ('Note of Destruction'		,34, 27,500, 85,false)
					),
					(	      { Bards	 }
{ 1} ('Detect Monsters'		    , 1, 1,  6, 35,false),
{ 2} ('Battle Song'		    , 1, 2,  7, 35,false),
{ 3} ('Blink'			    , 1, 2,  8, 35,false),
{ 4} ('Light Area'		    , 1, 2,  8, 35,false),
{ 5} ('Detect Hidden Doors/Traps'   , 3, 3, 10, 45,false),
{ 6} ('Magical Jig'		    , 3, 4, 20, 40,false),
{ 7} ('Detect Magic'		    , 3, 4, 50, 60,false),
{ 8} ('Minor Cure'		    , 3, 4, 20, 40,false),
{ 9} ('Battle Dance'		    , 5, 5, 30, 45,false),
{10} ('Charm Monsters'		    , 5, 5, 40, 40,false),
{11} ('Detect Curse'		    , 5, 9, 60, 50,false),
{12} ('Detect Invisible'	    , 7, 8, 40, 45,false),
{13} ('Cure Poison'		    , 7, 8, 40, 45,false),
{14} ('Invisibility'		    , 7,11, 60, 55,false),
{15} ('Teleport Self'		    , 9,10, 60, 50,false),
{16} ('Infravision'		    , 9,11, 50, 55,false),
{17} ('Physical Humor'		    , 9,11, 70, 55,false),
{18} ('Recharge Item'		    ,11,11, 60, 85,false),
{19} ('Remove Curse'		    ,13,12, 50, 55,false),
{20} ('Legend Lore'		    ,11,13, 80, 99,false),
{21} ('Mass Charm'		    ,11,12, 70, 55,false),
{22} ('Detect Treasure'		    ,13,11, 60, 80,false),
{23} ('Detect Object'		    ,13,11, 60, 80,false),
{24} ('Resist Petrification'	    ,15,12, 70, 60,false),
{25} ('Create Food and Drink'	    ,15,13, 80, 60,false),
{26} ('Panic'			    ,15,15, 80, 60,false),
{27} ('Word of Recall'		    ,17,15, 80, 60,false),
{28} ('Protection from Nature'	    ,17,16, 80, 65,false),
{29} ('See Invisible'		    ,17,16, 80, 60,false),
{30} ('Magic Mapping'		    ,19,18, 90, 65,false),
{31} ('Joke of Death'		    ,19,18, 80, 60,false),
{32} ('Battle Frenzy'		    ,19,18, 90, 80,false),
{33} ('Slow Creature'		    ,21,19,100, 65,false),
{34} ('Resist Charm'		    ,23,22,120, 65,false),
{35} ('Item Lore'		    ,25,20,110, 90,false),
{36} ('Song of Protection'	    ,27,25,200, 70,false),
{37} ('Last Laugh'		    ,29,23,150, 70,false),
{38} ('Teleport Level'		    ,31,27,300, 75,false),
{39} ('Clairvoyance'		    ,35,29,500, 92,false),
{40} ('Song of Power'		    ,39,32,800, 97,false)
				),
					(		{ Adventurer	    }
{ 1} ('Magic Missile'		    , 3, 1,  6, 30,false),
{ 2} ('Detect Monsters'		    , 3, 2,  6, 35,false),
{ 3} ('Phase Door'		    , 3, 2,  8, 35,false),
{ 4} ('Light Area'		    , 5, 3,  8, 26,false),
{ 5} ('Cure Light Wounds'	    , 5, 3,  8, 25,false),
{ 6} ('Find Hidden Traps/Doors'	    , 7, 4, 10, 45,false),
{ 7} ('Stinking Cloud'		    , 7, 6, 24, 40,false),
{ 8} ('Confusion'		    , 9, 6, 20, 40,false),
{ 9} ('Lightning Bolt'		    , 9, 7, 30, 40,false),
{10} ('Trap/Door Destruction'	    ,11, 8, 30, 45,false),
{11} ('Sleep I'			    ,11, 8, 40, 40,false),
{12} ('Cure Poison'		    ,13, 9, 40, 45,false),
{13} ('Shadow Door'		    ,13,10, 50, 45,false),
{14} ('Remove Curse'		    ,15,11, 50, 55,false),
{15} ('Frost Bolt'		    ,15,12, 60, 50,false),
{16} ('Create Food'		    ,17,12, 60, 55,false),
{17} ('Infravision'		    ,17,12, 60, 50,false),
{18} ('Invisibility'		    ,17,13, 60, 50,false),
{19} ('Turn Stone to Mud'	    ,19,15, 70, 50,false),
{20} ('Recharge Item I'		    ,19,17, 70, 90,false),
{21} ('Sleep II'		    ,21,17, 70, 55,false),
{22} ('Phantasmal Force'	    ,21,19, 60, 50,false),
{23} ('Polymorph Other'		    ,23,19, 70, 60,false),
{24} ('Identify'		    ,23,25, 70, 95,false),
{25} ('Ring of Frost'		    ,25,19, 80, 60,false),
{26} ('Sleep III'		    ,25,20, 80, 60,false),
{27} ('Hold Monster'		    ,27,20, 80, 50,false),
{28} ('Fire Bolt'		    ,27,20, 80, 60,false),
{29} ('Slow Creature'		    ,29,21, 90, 65,false),
{30} ('Protection From Magic'	    ,31,21, 90, 70,false),
{31} ('Frost Ball'		    ,31,21, 90, 65,false),
{32} ('Death Spell'		    ,33,21,100, 60,false),
{33} ('Ring of Fire'		    ,35,21,110, 65,false),
{34} ('Recharge Item II'	    ,35,23,120, 95,false),
{35} ('Teleport Other'		    ,37,25,150, 70,false),
{36} ('Haste Self'		    ,37,25,200, 75,false),
{37} ('Fire Ball'		    ,39,27,250, 80,false),
{38} ('Power Word: Destruction'	    ,39,30,300, 95,false),
{39} (''			    ,99,99,  0,	 0,false),
{40} (''			    ,99,99,  0,	 0,false)
					),
    			(		    { Monk	    }
 ('Self-Healing'		, 3, 3,	 5, 50,false),
 ('Courage'			, 5, 5,	10, 50,false),
 ('Slow Poison'			, 7, 7,	10, 50,false),
 ('Negate Hunger' 		, 9, 9,	15, 50,false),
 ('Sense Enemies'		,11,11,	20, 50,false),
 ('Self-Healing II'		,13,13,	20, 50,false),
 ('Night Vision'		,15,15,	30, 50,false),
 ('Poison Immunity'		,17,17,	40, 50,false),
 ('See Invisible'		,19,19,	50, 50,false),
 ('Advanced Self-Healing'	,21,21,	60, 50,false),
 ('Resist Petrification'	,23,23,	70, 50,false),
 ('Stealth'			,25,25,	80, 50,false),
 ('Free Action'			,27,27,	90, 50,false),
 ('Improved Speed'		,29,29,100, 50,false),
 (''				,99,99,	 0,  0,false),
 (''				,99,99,	 0,  0,false),
 (''				,99,99,	 0,  0,false),
 (''				,99,99,	 0,  0,false),
 (''				,99,99,	 0,  0,false),
 (''				,99,99,	 0,  0,false),
 (''				,99,99,	 0,  0,false),
 (''				,99,99,	 0,  0,false),
 (''				,99,99,	 0,  0,false),
 (''				,99,99,	 0,  0,false),
 (''				,99,99,	 0,  0,false),
 (''				,99,99,	 0,  0,false),
 (''				,99,99,	 0,  0,false),
 (''				,99,99,	 0,  0,false),
 (''				,99,99,	 0,  0,false),
 (''				,99,99,	 0,  0,false),
 (''				,99,99,	 0,  0,false),
 (''				,99,99,	 0,  0,false),
 (''				,99,99,	 0,  0,false),
 (''				,99,99,	 0,  0,false),
 (''				,99,99,	 0,  0,false),
 (''				,99,99,	 0,  0,false),
 (''				,99,99,	 0,  0,false),
 (''				,99,99,	 0,  0,false),
 (''				,99,99,	 0,  0,false),
 (''				,99,99,	 0,  0,false)
		       ) );
 


	{ Create fake book for using monk disciplines		}
 monk_book :=
('& Book of Mental Disciplines'			   ,  miscellaneous_object, '?',%X'00000000',%X'00003FFF',
    0,      0,   1,  10,   1,   0,   0,   0,   0, '0d0'  ,  1);

	char_row	:= 0;
	char_col	:= 0;
 
	{ Initialize player generation variables			}
	sex_type  := 'FemaleMale  ';
 
	{Race	(STR,INT,WIS,DEX,CON,CHR),
		age,,mht,,mwt,,fht,,fwt,,bxp,
	Racial: dis,srh,stl,fos,bth,bthb,bsav,HD,infra,swim,classes}
 
	{ For choice-classes, the bits run in reverse order, with adventurer
	  on the left, and fighter on the right.
Monk, Adventurer, Bard, Druid, Paladin, Ranger, Rogue, Priest, Mage, Warrior }
 
	race	:=	(
		('Human',   (  0,  0,  0,  0,  0,  0),
			 14,  6, 72,  6,180, 25, 66,  4,120, 20, 1.00,
		 0,  0,  0,  0,  0,  0,  0, 10,  0,  0, %B'1111111111'	),
		('Half-Elf', (-1,  1,  0,  1, -1,  1),
			 24, 16, 66,  6,130, 15, 62,  6,100, 10, 1.10,
		 2,  6,  1, -1,  0,  5,  3,  9,  0,  1, %B'1111111111'	),
		('Elf',	     (-1,  2,  1,  1, -2,  1),
			 75, 75, 60,  4,100,  6, 54,  4, 80,  6, 1.20,
		 5,  8,  1, -2, -5, 15,  6,  8,  0,  2, %B'0111011111'	),
		('Halfling', (-2,  2,  1,  3,  1,  1),
			 21, 12, 36,  3, 60,  3, 33,  3, 50,  3, 1.10,
		15, 12,  4, -5,-10, 20, 18,  6,  4, -2, %B'1011001010'	),
		('Gnome',    (-1,  2,  0,  2,  1, -2),
			 50, 40, 42,  3, 90,  6, 39,  3, 75,  3, 1.25,
		10,  6,  3, -3, -8, 12, 12,  7,  3, -1, %B'0001001110'	),
		('Dwarf',     (2, -3,  1, -2,  2, -3),
			 35, 15, 48,  3,150, 10, 46,  3,120, 10, 1.20,
		 2,  7,  0,  0, 15,  0,  9,  9,  5, -2, %B'0001000101'	),
		('Half-Orc',  (2, -1,  0,  0,  1, -4),
			 11,  4, 66,  1,150,  5, 62,  1,120,  5, 1.10,
		-3,  0, -1,  3, 12, -5, -3, 10,  3,  0, %B'1000001101'	),
		('Half-Troll',(4, -4, -3, -4,  4, -6),
			 20, 10, 96, 10,300, 50, 84,  8,260, 40, 1.20,
		-5, -1, -2,  5, 20,-10, -9, 12,  3,  2, %B'0000000101'	),
		('Phraint',   (0,  0, -4,  5,  0, -3),
			 15, 10, 96, 24,100, 20, 84, 12, 95, 16, 1.20,
		15, 10,  5,  4,  3,  5, -3,  8,  5, -1, %B'1110011011'	),
		('Dryad',    (-1,  0,  3,  0, -2,  3),
			 75, 75, 60,  4, 85,  6, 40,  4, 70,  6, 1.20,
		 2,  6,  1, -1,  0,  5,  3,  7,  3, -1, %B'1011010100'	)
		);
 
	{ Buying and selling adjustments for character race VS store	}
	{ owner race							}
 
	rgold_adj :=	(
	      {	 Hum,  HfE,  Elf,  Hal,	 Gno,  Dwa,  HfO,  HfT,	 Phr,  Dry}
{Human	    } ( 0.00, 0.05, 0.05, 0.10, 0.13, 0.15, 0.20, 0.25, 0.20, 0.05),
{Half-Elf   } ( 0.10, 0.00, 0.00, 0.05, 0.10, 0.20, 0.25, 0.30, 0.25, 0.05),
{Elf	    } ( 0.10, 0.05, 0.00, 0.05, 0.10, 0.20, 0.25, 0.30, 0.30, 0.00),
{Halfling   } ( 0.15, 0.10, 0.05,-0.05, 0.05, 0.10, 0.15, 0.30, 0.25, 0.05),
{Gnome	    } ( 0.15, 0.15, 0.10, 0.05,-0.05, 0.10, 0.15, 0.30, 0.20, 0.15),
{Dwarf	    } ( 0.15, 0.20, 0.20, 0.10, 0.10,-0.05, 0.25, 0.35, 0.15, 0.30),
{Half-Orc   } ( 0.15, 0.20, 0.25, 0.15, 0.15, 0.30, 0.10, 0.15, 0.15, 0.25),
{Half-Troll } ( 0.10, 0.15, 0.15, 0.10, 0.10, 0.30, 0.10, 0.10, 0.15, 0.25),
{Phraint    } ( 0.20, 0.25, 0.30, 0.25, 0.20, 0.15, 0.15, 0.15,-0.10, 0.20),
{Dryad	    } ( 0.10, 0.05, 0.05, 0.05, 0.15, 0.30, 0.30, 0.25, 0.20,-0.05)
			);
 
	{ Classes...	
 title, m_exp, adj_hd, mdis, msrh, mstl, mfos, mbth, mbthb, msav,(stat adjs),
??,??,??,??,??,??}

	class	:=	(
('Warrior',0.00,10, 25,14, 1, 38,10, 8,10,( 5,-2,-2, 2, 2,-1),
	   false,false,false,false,false,-10),
('Mage',   0.30, 0, 30,16, 2, 36, 4, 4,25,(-5, 3, 0, 0,-2, 0),
	   false,true ,false,false,false,0),
('Priest', 0.20, 3, 25,16, 2, 32, 6, 5,20,( 0,-3, 3,-1, 1, 2),
	   true ,false,false,false,false,0),
('Rogue',  0.10, 6, 45,32, 4, 16, 6,10,15,( 2, 0,-2, 3, 1, 1),
	   false,false,false,true ,false,-5),
('Ranger', 0.30, 4, 30,24, 3, 24, 6,10,20,( 2, 0, 1, 1, 1, 2),
	   false,false,true ,false,false,-5),
('Paladin',0.35, 6, 20,12, 1, 38, 8, 6,15,( 3,-3, 1, 0, 2, 2),
	   true ,false,false,false,false,-5),
('Druid',  0.20, 3, 25,16, 1, 32, 4, 7,20,(-1,-1, 2, 0, 0, 3),
	   false,false,true ,false,false,-5),
('Bard',   0.30, 4, 30,22, 2, 28, 5, 6,20,( 2, 1,-1, 2, 0, 3),
	   false,false,false,true ,false,-5),
('Adventurer',0.40,4,30,24,3, 24, 6, 6,20,( 2, 2,-1, 1, 1, 0),
	   false,true ,false,false,false,-5),
('Monk',   0.10, 4, 45,24, 3, 24, 8, 6,25,( 2, 0, 2, 3, 1, 1),
	   false,false,false,false,true,-5)
			);
 
	{ Class titles for different levels				}
	player_title	:=	(
	{ Warrior	}
('Novice','Veteran(1st)','Veteran(2nd)','Veteran(3rd)','Warrior(1st)',
'Warrior(2nd)','Warrior(3rd)','Swordsman-1','Swordsman-2','Swordsman-3',
'Hero','Swashbuckler','Myrmidon','Champion-1','Champion-2','Champion-3',
'Superhero','Knight','Superior Knt','Gallant Knt','Knt Errent','Keeper',
'Protector','Defender','Warder','Guardian Knt','Chevalier','Justiciar',
'Lord (1st)','Lord (2nd)','Lord (3rd)','Lord (4th)','Lord (5th)','Lord (6th)',
'Lord (7th)','Lord (8th)','Lord (9th)','Lord Gallant','Lord Keeper',
'Lord Noble'),
	{ Mage		}
('Novice','Apprentice','Trickster-1','Trickster-2','Trickster-3','Cabalist-1',
'Cabalist-2','Cabalist-3','Visionist','Phantasmist','Shadowist','Spellbinder',
'Illusionist','Evoker (1st)','Evoker (2nd)','Evoker (3rd)','Evoker (4th)',
'Conjurer','Theurgist','Thaumaturer','Magician','Enchanter','Warlock',
'Sorcerer','Necromancer','Mage (1st)','Mage (2nd)','Mage (3rd)','Mage (4th)',
'Mage (5th)','Wizard (1st)','Wizard (2nd)','Wizard (3rd)','Wizard (4th)',
'Wizard (5th)','Wizard (6th)','Wizard (7th)','Wizard (8th)','Wizard (9th)',
'Wizard Lord'),
	{ Priests	}
('Believer','Acolyte(1st)','Acolyte(2nd)','Acolyte(3rd)','Adept (1st)',
'Adept (2nd)','Adept (3rd)','Priest (1st)','Priest (2nd)','Priest (3rd)',
'Priest (4th)','Priest (5th)','Priest (6th)','Priest (7th)','Priest (8th)',
'Priest (9th)','Curate (1st)','Curate (2nd)','Curate (3rd)','Curate (4th)',
'Curate (5th)','Curate (6th)','Curate (7th)','Curate (8th)','Curate (9th)',
'Canon (1st)','Canon (2nd)','Canon (3rd)','Canon (4th)','Canon (5th)',
'Low Lama','Lama-1','Lama-2','Lama-3','High Lama','Great Lama','Patriarch',
'High Priest','Great Priest','Noble Priest'),
	{ Rogues	}
('Apprentice','Footpad','Cutpurse','Robber','Burglar','Filcher','Sharper',
'Magsman','Common Rogue','Rogue (1st)','Rogue (2nd)','Rogue (3rd)',
'Rogue (4th)','Rogue (5th)','Rogue (6th)','Rogue (7th)','Rogue (8th)',
'Rogue (9th)','Master Rogue','Expert Rogue','Senior Rogue','Chief Rogue',
'Prime Rogue','Low Thief','Thief (1st)','Thief (2nd)','Thief (3rd)',
'Thief (4th)','Thief (5th)','Thief (6th)','Thief (7th)','Thief (8th)',
'Thief (9th)','High Thief','Master Thief','Executioner','Low Assassin',
'Assassin','HighAssassin','Guildsmaster'),
	{ Rangers	}
('Runner (1st)','Runner (2nd)','Runner (3rd)','Strider (1st)','Strider (2nd)',
'Strider (3rd)','Scout (1st)','Scout (2nd)','Scout (3rd)','Scout (4th)',
'Scout (5th)','Courser (1st)','Courser (2nd)','Courser (3rd)','Courser (4th)',
'Courser (5th)','Tracker (1st)','Tracker (2nd)','Tracker (3rd)',
'Tracker (4th)','Tracker (5th)','Tracker (6th)','Tracker (7th)',
'Tracker (8th)','Tracker (9th)','Guide (1st)','Guide (2nd)','Guide (3rd)',
'Guide (4th)','Guide (5th)','Guide (6th)','Guide (7th)','Guide (8th)',
'Guide (9th)','Pathfinder-1','Pathfinder-2','Pathfinder-3','Ranger',
'High Ranger','Ranger Lord'),
	{ Paladins	}
('Gallant','Keeper (1st)','Keeper (2nd)','Keeper (3rd)','Keeper (4th)',
'Keeper (5th)','Keeper (6th)','Keeper (7th)','Keeper (8th)','Keeper (9th)',
'Protector-1','Protector-2','Protector-3','Protector-4','Protector-5',
'Protector-6','Protector-7','Protector-8','Defender-1','Defender-2',
'Defender-3','Defender-4','Defender-5','Defender-6','Defender-7','Defender-8',
'Warder (1st)','Warder (2nd)','Warder (3rd)','Warder (4th)','Warder (5th)',
'Warder (6th)','Warder (7th)','Warder (8th)','Warder (9th)','Gauardian',
'Chevalier','Justiciar','Paladin','High Lord'),
	 { Druids	}
('Aspirant-1','Aspirant-2','Ovate (1st)','Ovate (2nd)','Ovate(3th)',
'Initiate-1','Initiate-2',
'1st Cabal','2nd Cabal','3rd Cabal','4th Cabal','5th Cabal','6th Cabal',
'7th Cabal','8th Cabal','9th Cabal','10th Cabal','11th Cabal','12th Cabal',
'13th Cabal','Low Druid','Druid (1st)','Druid (2nd)','Druid (3rd)',
'Druid (4th)','Druid (5th)','Druid (6th)','Adept Druid','Arch Druid',
'Great Druid','Master Druid','Grand Druid','Lord Druid','LowHierophant',
'Hierophant-1','Hierophant-2','Hierophant-3','Hierophant-4','Hierophant-5',
'Forest Master'),
	 { Bards	}
('Singer','Rhymer','Joker','Lyrist (1st)','Lyrist (2nd)','Lyrist (3rd)',
'Jester (1st)','Jester (2nd)','Sonnateer-1',
'Sonnateer-2','Sonnateer-3','Skald (1st)','Skald (2nd)','Skald (3rd)',
'Comic (1st)','Comic (2nd)','Comic (3rd)','Racaraide-1','Racaraide-2',
'Racaraide-3','Joungleur-1','Joungleur-2','Joungleur-3','Minstrel-1',
'Minstrel-2','Minstrel-3','Muse (1st)','Muse (2nd)','Muse(3rd)','Lorist (1st)',
'Lorist (2nd)','Lorist (3rd)','Initiate Bard','Bard (1st)','Bard (2nd)',
'Bard (3rd)','Master Bard-1','Master Bard-2','Master Bard-3','Bardic Sage'),
	{ Adventurer	}
('Dimwit','Beginner','Amateur','Flathead','PileofLeaves','Novice','Brass Bell',
'Orange Cake','White Unicorn','Charlatan','CloveofGarlic','Nasty Knife',
'ParlorMgician','Gaudy Crown','Loaf of Bread','Lurking Grue','Noisome Stew',
'Broken Timber','Granite Wall','FCD #3','Adventurer-1','Adventurer-2',
'Adventurer-3','AIMFIZ Scroll','VILSTU Potion','Sr Adventurer','Master Advnt',
'WizofFrobozz','Enchanter','Sorcerer','Wizard (1st)','Wizard (2nd)',
'Wizard (3rd)','Wizard (4th)','Wizard (5th)','Wizard (6th)','Wizard (7th)',
'Zorkmid Coin','DungeonMaster','Implementer'),
	{ Monk		}
('Disciple','Acolyte(1st)','Acolyte(2nd)','Acolyte(3rd)','Neophyte(1st)',
'Neophyte(2nd)','Neophyte(3rd)','Neophyte(4th)','Adept (1st)','Adept (2nd)',
'Adept (3rd)','Hermit (1st)','Hermit (2nd)','Hermit (3rd)','Hermit (4th)',
'Hermit (5th)','Curate (1st)','Curate (2nd)','Curate (3rd)','Curate (4th)',
'Curate (5th)','Curate (6th)','Curate (7th)','Curate (8th)','Curate (9th)',
'Master (1st)','Master (2nd)','Master (3rd)','Master (4th)','Master (5th)',
'SupriorMaster','Low Lama','High Lama','Great Lama','DancingLlama',
'Holy Man','Hi-YA Man','Baby Buddha','BuddingBuddha','Buddha')	

				);
	{ Base experience levels, may be adjusted up for race and/or class}
	player_exp :=	(
     10,     25,     45,     70,    100,    140,    200,    280,    380,   500,
    650,    850,   1100,   1400,   1800,   2300,   2900,   3600,   4400,  5400,
   6800,   8400,  10200,  12500,  17500,  25000,  35000,  50000,  75000,100000,
 150000, 200000, 300000, 400000, 500000, 750000,1500000,2500000,5000000,9999999
			);
 
 
	{ Background information					}
	background	:=	(
('You are the illegitimate and unacknowledged child ',		 10, 1, 2,-25),
('You are the illegitimate but acknowledged child ',		 20, 1, 2,-15),
('You are one of several children ',				 95, 1, 2, -5),
('You are the 1st child ',					100, 1, 2,  0),
('of a Serf.  ',  						 40, 2, 3, 15),
('of a Yeoman.  ',						 65, 2, 3, 30),
('of a Townsman.  ',						 80, 2, 3, 40),
('of a Guildsman.  ',						 90, 2, 3, 55),
('of a Landed Knight.  ',					 96, 2, 3, 70),
('of a Titled Noble.  ',					 99, 2, 3, 80),
('of a Royal Blood Line.  ',					100, 2, 3, 90),
('You are the black sheep of the family.  ',			 20, 3,50,-30),
('You are a credit to the family.  ',				 80, 3,50,  5),
('You are a well liked child.  ',				100, 3,50, 10),
('Your mother was a Green-Elf.  ',				 40, 4, 1,  0),
('Your father was a Green-Elf.  ',				 75, 4, 1,  5),
('Your mother was a Grey-Elf.  ',				 90, 4, 1,  5),
('Your father was a Grey-Elf.  ',				 95, 4, 1, 10),
('Your mother was a High-Elf.  ',				 98, 4, 1, 15),
('Your father was a High-Elf.  ',				100, 4, 1, 20),
('You are one of several children ',				 60, 7, 8,  0),
('You are the only child ',					100, 7, 8,  5),
('of a Green-Elf ',		  				 75, 8, 9,  0),
('of a Grey-Elf ',						 95, 8, 9,  5),
('of a High-Elf ',						100, 8, 9, 10),
('Ranger.  ',							 40, 9,54, 30),
('Archer.  ',							 70, 9,54, 40),
('Warrior.  ',							 87, 9,54, 60),
('Mage.  ',							 95, 9,54, 75),
('Prince.  ',							 99, 9,54, 90),
('King.	 ',							100, 9,54, 95),
('You are one of several children of a Halfling ',		 85,10,11, -5),
('You are the only child of a Halfling ',			100,10,11,  5),
('Bum.  ',							 20,11, 3,  5),
('Tavern Owner.	 ',						 30,11, 3, 30),
('Miller.  ',							 40,11, 3, 40),
('Home Owner.  ',						 50,11, 3, 50),
('Burglar.  ',							 80,11, 3, 60),
('Monk.  ',							 95,11, 3, 65),
('Mage.  ',							100,11, 3, 75),
('Clan Elder.  ',						100,11, 3, 90),
('You are one of several children of a Gnome ',			 85,13,14, -5),
('You are the only child of a Gnome ',				100,13,14,  5),
('Beggar.  ',							 20,14, 3,  5),
('Bragart.  ',							 50,14, 3, 20),
('Prankster.  ',						 75,14, 3, 35),
('Druid.  ',							 95,14, 3, 50),
('Mage.  ',							100,14, 3, 75),
('You are one of two children of a Dwarven ',			 25,16,17,-10),
('You are the only child of a Dwarven ',			100,16,17,  0),
('Thief.  ',							 10,17,18, 10),
('Prison Guard.	 ',						 25,17,18, 25),
('Miner.  ',							 75,17,18, 40),
('Warrior.  ',							 90,17,18, 60),
('Priest.  ',							 99,17,18, 80),
('King.	 ',							100,17,18,100),
('You are the black sheep of the family.  ',			 15,18,57,-40),
('You are a credit to the family.  ',				 85,18,57,  0),
('You are a well liked child.  ',				100,18,57,  5),
('Your mother was an Orc, but it is unacknowledged.  ',		 25,19,20,-25),
('Your father was an Orc, but it is unacknowledged.  ',		100,19,20,-25),
('You are the adopted child ',					100,20, 2,  0),
('Your mother was a Cave-Troll ',				 30,22,23,-30),
('Your father was a Cave-Troll ',				 60,22,23,-25),
('Your mother was a Hill-Troll ',				 75,22,23,-20),
('Your father was a Hill-Troll ',				 90,22,23,-15),
('Your mother was a Water-Troll ',				 95,22,23,-10),
('Your father was a Water-Troll ',				100,22,23, -5),
('Cook.	 ',							  5,23,62, 10),
('Warrior.  ',							 95,23,62,  5),
('Shaman.  ',							 99,23,62, 15),
('Clan Chief.  ',						100,23,62, 30),
('You are one of many illegitimate children ',			  5,25,26,-30),
('You are one of several illegitimate children ',		 10,25,26,-25),
('You are one of many children ',				 50,25,26,-10),
('You are one of several children ',				 75,25,26, -5),
('You are the 2nd child ',					 95,25,26,  0),
('You are the only child ',					100,25,26,  5),
('of a Worker.  ',						 50,26,27, 15),
('of a Warrior.  ',						 75,26,27, 30),
('of an Elite Warrior.  ',					 90,26,27, 50),
('of the Hive Mother.  ',					100,26,27,100),
('You are the outcast of the hive.  ',				  5,27,38,-50),
('You are the black sheep of the hive.  ',			 20,27,38,-30),
('You are a credit to the hive.	 ',				 80,27,38,  5),
('You are a well liked child.  ',				100,27,38, 10),
('You are the Dryad of a sickly ',				 15,28,29,-20),
('You are the Dryad of a large ',				 40,28,29,  0),
('You are the Dryad of a rich, green ',				 60,28,29,  0),
('You are the Dryad of a magnificent ',				 90,28,29, 10),
('You are the Dryad of a stump! ',				100,28,54,-30),
('pine tree',							 30,29,30,  5),
('birch tree',							 40,29,30, 15),
('ash tree',							 50,29,30, 30),
('cedar tree',							 70,29,30, 50),
('willow tree',							 90,29,30, 70),
('oak tree',							100,29,30, 90),
(', but the elven community avoids your forest.	 ',		 10,30,54,-30),
(' in a small glade.  ',					 40,30,54, -5),
(' and you are a fine upholder of the woodlands.  ',		 60,30,54,  5),
(' and Humans and Half-Elves hold your tree sacred.  ',		 88,30,54, 20),
(' where the Elves hold yearly ceremonies.  ',			 90,30,54, 25),
(' that all races hold in reverence.  ',			100,30,54, 30),
('You have small ',						 40,38,39,  0),
('You have large ',						 70,38,39,  0),
('You have very large ',					100,38,39,  0),
('buggy green eyes, ',						 10,39,40,  0),
('buggy silver eyes, ',						 30,39,40,  0),
('iridescent eyes, ',						 70,39,40,  0),
('glowing eyes, ',						100,39,40,  0),
('straight feelers, ',						 10,40,41,  0),
('curved feelers, ',						 30,40,41,  0),
('bent feelers, ',						 80,40,41,  0),
('very long feelers, ',						100,40,41,  0),
('and dull brown chiton. ',					 10,41,-1,  0),
('and shiny brown chiton. ',					 60,41,-1,  0),
('and shiny black chiton. ',					 90,41,-1,  0),
('and polished silver chiton. ',				100,41,-1,  0),
('You have dark brown eyes, ',					 20,50,51,  0),
('You have brown eyes, ',					 60,50,51,  0),
('You have hazel eyes, ',					 70,50,51,  0),
('You have green eyes, ',					 80,50,51,  0),
('You have blue eyes, ',					 90,50,51,  0),
('You have blue-gray eyes, ',					100,50,51,  0),
('straight ',							 70,51,52,  0),
('wavey ',							 90,51,52,  0),
('curly ',							100,51,52,  0),
('black hair, ',						 30,52,53,  0),
('brown hair, ',						 70,52,53,  0),
('auburn hair, ',						 80,52,53,  0),
('red hair, ',							 90,52,53,  0),
('blonde hair, ',						100,52,53,  0),
('and a very dark complexion.',					 10,53,-1,  0),
('and a dark complexion.',					 30,53,-1,  0),
('and an average complexion.',					 80,53,-1,  0),
('and a fair complexion.',					 90,53,-1,  0),
('and a very fair complexion.',					100,53,-1,  0),
('You have light grey eyes, ',					 85,54,55,  0),
('You have light violet eyes, ',				 90,54,55,  0),
('You have light blue eyes, ',					 95,54,55,  0),
('You have light green eyes, ',					 98,54,55,  2),
('You have light golden colored eyes, ',			100,54,55,  5),
('straight ',							 75,55,56,  0),
('wavey ',							100,55,56,  0),
('jet black hair, and a fair complexion.',			 75,56,-1,  0),
('light brown hair, and a fair complexion.',			 85,56,-1,  0),
('blonde hair, and a fair complexion.',				 95,56,-1,  0),
('silver hair, and a fair complexion.',				 98,56,-1,  1),
('hair the color of spun gold and pale skin.',			100,56,-1,  5),
('You have dark brown eyes, ',					 99,57,58,  0),
('You have glowing red eyes, ',					100,57,58, 10),
('straight ',							 90,58,59,  0),
('wavey ',							100,58,59,  0),
('black hair, ',						 75,59,60,  0),
('brown hair, ',						100,59,60,  0),
('a one foot beard, ',						 25,60,61,  0),
('a two foot beard, ',						 60,60,61,  1),
('a three foot beard, ',					 90,60,61,  3),
('a four foot beard, ',						100,60,61,  5),
('and a dark complexion.',					100,61,-1,  0),
('You have slime green eyes, ',					 60,62,63,  0),
('You have puke yellow eyes, ',					 85,62,63,  0),
('You have blue-bloodshot eyes, ',				 99,62,63,  0),
('You have glowing red eyes, ',					100,62,63,  5),
('dirty ',							 33,63,64,  0),
('mangy ',							 66,63,64,  0),
('oily ',							100,63,64,  0),
('sea-weed green hair, ',					 33,64,65,  0),
('bright red hair, ',						 66,64,65,  0),
('dark purple hair, ',						100,64,65,  0),
('and green ',							 25,65,66,  0),
('and blue ',							 50,65,66,  0),
('and white ',							 75,65,66,  0),
('and black ',							100,65,66,  0),
('ulcerous skin.',						 33,66,-1,  0),
('scabby skin.',						 66,66,-1,  0),
('leprous skin.',						100,66,-1,  0)
			);
 
 
	{ Treasure related values					}
	inven_ctr	:= 0;
	inven_weight	:= 0;
	missle_ctr	:= 0;
	equip_ctr	:= 0;
	blank_treasure	:= (' ',0,' ',0,0,0,0,0,0,0,0,0,0,0,' ',0);
 
	{ The level of a valuable_metal determines what type of money it is,
	  where:
			iron		= 1
			copper		= 2
			silver		= 3
			gold		= 4
			platinum	= 5
			mithril		= 6

	{ Gold list (All types of gold and gems are defined here)	}
	gold_list	:=	(
('& copper piece~'				   , valuable_metal, '$',0,0,
    0,	    0,	 2,   5, 420,	0,   0,	  0,   0, ' '	 ,  2),
('& iron piece~'				   , valuable_metal, '$',0,0,
    0,	    0,	 1,   5,2400,	0,   0,	  0,   0, ' '	 ,  1),
('& copper piece~'				   , valuable_metal, '$',0,0,
    0,	    0,	 4,   5, 720,	0,   0,	  0,   0, ' '	 ,  2),
('& silver piece~'				   , valuable_metal, '$',0,0,
    0,	    0,	 5,   5, 180,	0,   0,	  0,   0, ' '	 ,  3),
('& iron piece~'				   , valuable_metal, '$',0,0,
    0,	    0,	 3,   5,4800,	0,   0,	  0,   0, ' '	 ,  1),
('& copper piece~'				   , valuable_metal, '$',0,0,
    0,	    0,	 6,   5,1200,	0,   0,	  0,   0, ' '	 ,  2),
('& silver piece~'				   , valuable_metal, '$',0,0,
    0,	    0,	 7,   5, 300,   0,   0,   0,   0, ' '	 ,  3),
('& gold piece~'				  , valuable_metal, '$',0,0,
    0,	    0,	12,   5,  30,	0,   0,	  0,   0, ' '	 ,  4),
('& iron piece~'				   , valuable_metal, '$',0,0,
    0,	    0,	 3,   5,9000,	0,   0,	  0,   0, ' '	 ,  1),
('& copper piece~'				   , valuable_metal, '$',0,0,
    0,	    0,	 6,   5,2400,	0,   0,	  0,   0, ' '	 ,  2),
('& silver piece~'				   , valuable_metal, '$',0,0,
    0,	    0,	 7,   5, 600,   0,   0,   0,   0, ' '	 ,  3),
('& gold piece~'				  , valuable_metal, '$',0,0,
    0,	    0,	12,   5,  60,	0,   0,	  0,   0, ' '	 ,  4),
('& copper piece~'				   , valuable_metal, '$',0,0,
    0,	    0,	 6,   5,6000,	0,   0,	  0,   0, ' '	 ,  2),
('& silver piece~'				   , valuable_metal, '$',0,0,
    0,	    0,	 7,   5,1200,   0,   0,   0,   0, ' '	 ,  3),
('& gold piece~'				  , valuable_metal, '$',0,0,
    0,	    0,	12,   5, 120,	0,   0,	  0,   0, ' '	 ,  4),
('& silver piece~'				   , valuable_metal, '$',0,0,
    0,	    0,	 7,   5,1500,   0,   0,   0,   0, ' '	 ,  3),
('& gold piece~'				  , valuable_metal, '$',0,0,
    0,	    0,	18,   5, 150,	0,   0,	  0,   0, ' '	 ,  4),
('& platinum piece~'				  , valuable_metal, '$',0,0,
    0,	    0,	20,   5,  50,	0,   0,	  0,   0, ' '	 ,  5),
('& silver piece~'				   , valuable_metal, '$',0,0,
    0,	    0,	16,   5,3000,	0,   0,	  0,   0, ' '	 ,  3),
('& gold piece~'				  , valuable_metal, '$',0,0,
    0,	    0,	24,   5, 250,	0,   0,	  0,   0, ' '	 ,  4),
('& platinum piece~'				  , valuable_metal, '$',0,0,
    0,	    0,	28,   5,  75,	0,   0,	  0,   0, ' '	 ,  5),
('& mithril piece~'				  , valuable_metal, '$',0,0,
    0,	    0,	32,   5,   8,	0,   0,	  0,   0, ' '	 ,  6),
('& gold piece~'				   , valuable_metal, '$',0,0,
    0,	    0,	50,   5, 600,	0,   0,	  0,   0, ' '	 ,  4),
('& platinum piece~'				  , valuable_metal, '$',0,0,
    0,	    0,	55,   5, 200,	0,   0,	  0,   0, ' '	 ,  5),
('& mithril piece~'				  , valuable_metal, '$',0,0,
    0,	    0,	60,   5,  20,	0,   0,	  0,   0, ' '	 ,  6)
				);
 
	{ Object description:  Objects are defined here.  Each object has
	the following attributes:
		Descriptor : Name of item and formats.
			%C is replaced with a random color.
			%W is replaced with a random wood.
			%M is replaced with a random metal.
			%H is replaced with a random horn.
			%R is replaced with a random rock.
			%N is replaced with a random cloth.
			%P1 is replaced with the number in P1 (see below).
			%P2 is replaced with plus-to-hit.
			%P3 is replaced with plus-to-damage.
			%P4 is replaced with plus-to-AC.
			%P5 is replaced with number in P1, no sign.
			& is replaced with 'a', 'an', or a number.
			~ is replaced with null or 's'.
		Character  : Character that represents the item.
		Type value : Value representing the type of object.
			1   ~	Miscellaneous Object.
			2   &	chest.
			3   ~	Miscellaneous Usable Object.
			4   *	Valuable Jewelry.
			5   *	Valuable Gems.
			6   ~	Bag or Sack.
			7   *   "Wearable" Gem.
			10  (Left Curly Brace)	sling ammo.
			11  (Left Curly Brace)	bolt.
			12  (Left Curly Brace)	arrow.
			13  ~	spike.
			15  ~	Lamp or Torch.
			20  (Right curly brace)	 bow, crossbow, or sling.
			21  \	hafted weapon.
			22  /	pole arm.
			23  |	dagger.  --mage weapon
			24  |	sword.
			25  /   pick or shovel.
			26  \	maul.    --clerical weapon
			29  ]	gem helm.
			30  ]	boots.
			31  ]	gloves and gauntlets.
			32  (	cloak
			33  ]	helm.
			34  )	shield.
			35  [	hard armor.
			36  (	soft armor.
			37  ]   bracers.
			38  ]   belt.
			40  "	amulet.
			45  =	ring.
			55  _	staff.
			60  -	rod.
			65  -	wand.
			70  ?	scroll.
			71  ?	scroll.	   continued
			75  !	potion.
			76  !	potion.	   continued
			77  !	flask of oil.
			80  ,	food.
			85  %	chime.
			86  %	horn.
			90  ?	Magic Book.
			91  ?	Prayer Book.
			92  %	Druid Instrument.
			93  %	Bard Song Book.
			100 $	valuable metal.
			100 *	valuable gems.
			101 .	Unseen trap.
			102 ^	Seen trap.
			103 :	Rubble.
			104 '	Open door.
			105 +	Closed door.
			107 <	Up staircase.
			108 >	Down staircase.
			109 #	Secret door.
			110 1,2,3,4,5,6,7,8,9,0	  Entrance to store.
 
		Sub value  : separate value for each item of a type.
		Damage	   : amount of damage item can cause.
		Weight	   : relative weight of an item.
		Number	   : number of items appearing in group.
			If items can be added together then
				subval > 255
			If items are considered one unit when added
			together then
				subval > 511
		To hit	   : magical pluses to hit.
		To damage  : magical pluses to damage.
		AC	   : objects relative armor class.
			1 is worse than 5 is worse than 10 etc...
		To AC	   : Magical bonuses to AC.
		P1	   : Catch all for magical abilities such as
			     pluses to strength, minuses to searching...
		Flags	   : Abilities of object.  Each abilitiy is a
			     bit.  Bits 1-31 are used. (Signed integer)
 
		Flags used for anything that can be worn or wielded:
				Bit #	Hex #		Ability
				1	00000001	Strength
				2	00000002	Dexterity
				3	00000004	Constitution
				4	00000008	Intelligence
				5	00000010	Wisdom
				6	00000020	Charisma
				7	00000040	Searching
				8	00000080	Slow digestion
				9	00000100	Stealth
				10	00000200	Aggravation
				11	00000400	Teleportation
				12	00000800	Regeneration
				13	00001000	Speed
				14	00002000	Slay Dragon
				15	00004000	Slay Monster
				16	00008000	Slay Evil
				17	00010000	Slay Undead
				18	00020000	Cold Brand
				19	00040000	Flame Brand
				20	00080000	Resist Fire
				21	00100000	Resist Acid
				22	00200000	Resist Cold
				23	00400000	Sustain Stat (P1)
				24	00800000	Free Action
				25	01000000	See Invisible
				26	02000000	Resist Lightning
				27	04000000	Feather Fall
				28	08000000	Blindness
				29	10000000	Timidness
				30	20000000	Tunneling
				31	40000000	Infra vision
				32	80000000	Cursed
 
		Flags2	   : continuing the flag list...
 
				01	00000001	Slay Demon
				02	00000002	Soul Sword
				03	00000004	Slay Regenerative
				04	00000008	Swimming
				05	00000010	Proof vs. Magic
				06	00000020	Disarming
				07	00000040	Vorpal/Critical
				30      00200000	Bad Reputation Item
				31      00400000        Item of Hunger
				32      00800000	Special Magic Gem 
				33      01000000        Increase carry item
				35	04000000	Item of holding
				36	08000000	Item of devouring
 				37      10000000        Sharp weapon
				39      20000000        Insured item
				40      80000000        Known cursed item


		Level	   : Minimum level on which item can be found.
		Cost	   : Relative cost of item.
 
		Special Abilities can be added to item by MAGIC_INIT,
		found in MISC.PAS.
 
	Scrolls, Potions, and Food:
		Flags is used to define a function which reading/quaffing
		will cause.  Most scrolls and potions have only one bit
		set.  Potions will generally have some food value, found
		in P1.
 
	Wands, Staffs, Chimes, and Horns:
 
		Flags defines a function, P1 contains number of charges
		for item.  P1 is set in MAGIC_INIT (MISC.PAS)
 
	Chests:
		Traps are added randomly by MAGIC.INIT in MISC.PAS.
	}

	{ Yums -- A numbered array for eatin' purposes! }
	yums :=	(
('& Hard Biscuit~'				   ,  food, ',',%X'00000000',Nothing_flag,
  500,	    1, 309,   2,   1,	0,   0,	  0,   0, '0d0'	 , -1), {1}
('& Pint of Fine Wine'				   ,  food, ',',%X'00000000',Nothing_flag,
  400,	    2, 312,  10,   1,	0,   0,	  0,   0, '0d0'	 , -1), {2}
('& Strip~ of Beef Jerky'			   ,  food, ',',%X'00000000',Nothing_flag,
 1750,	    2, 310,   2,   1,	0,   0,	  0,   0, '0d0'	 , -1), {3}
('& Piece~ of Elvish Waybread'			   ,  food, ',',%X'00000000',%X'21800020',
 3500,	   10, 313,   3,   1,	0,   0,	  0,   0, '0d0'	 , -1), {4}
('& Rice-a-Roni~| (The San Francisco Treat!)'	   ,  food, 'R',%X'00000000',%X'330001C0',
 2000,	    0, 314,   3,   1,	0,   0,	  0,   0, '0d0'	 , -1), {5}
('& Jolly Green Jelly~| (Ho Ho Ho!)'  		   ,  food, 'J',%X'00000000',%X'22400060',
 4000,	   50, 315,   3,   1,	0,   0,	  0,   0, '0d0'	 , -1), {6}
('& pint~ of fine grade mush'			   ,  food, ',',%X'00000000',%X'00000000',
 1500,	    0, 306, 252,   1,   0,   0,   0,   0, '0d0',   -1), {7}
('& Slime Mold~'				   ,  food, ',',%X'00000000',Nothing_flag,
 3000,	    2, 308,   5,   1,	0,   0,	  0,   0, '0d0'	 , -1), {8}
('& Pint of Fine Ale'				   ,  food, ',',%X'00000000',Nothing_flag,
  500,	    1, 311,  10,   1,	0,   0,	  0,   0, '0d0'	 , -1),{9}
('& Handful~ of Berries| (Smurfberries)'  		   ,  food, ',',%X'00000000',%X'30400000',
 1000,	    0, 317,   3,   1,	0,   0,	  0,   0, '0d0'	 , -1),{10}
('& Handful~ of Berries| (Goodberries)'  		   ,  food, ',',%X'00000000',%X'30C00080',
 1000,	    0, 318,   3,   1,	0,   0,	  0,   0, '0d0'	 , -1), {11}
('& Cool Set of Threads^ [%P6,%P4]'		   ,  soft_armor, '(',%X'00000000',Nothing_flag,
    0,	   45,	11,  75,   1,  -1,   0,	  3,   0, '0d0'	 , -1),	{12}
('Filthy Naga Hide Armor^ [%P6,%P4]'		   ,  soft_armor, '(',%X'00000000',Nothing_flag,
    0,	   45,	12, 300,   1,  -1,   0,	  9,   0, '0d0'	 , -1),	{13}
('Stone Plate Armor^ [%P6,%P4]'			   ,  hard_armor, '[',%X'00000000',Nothing_flag,
    0,	   45,	14, 600,   1,  -6,   0,	 10,   0, '2d4'	 , -1),	{14}
('Elven Chain Mail^ [%P6,%P4]'			   ,  soft_armor, '(',%X'00000000',Nothing_flag,
    0,	  900,	13, 160,   1,  -1,   0,	 17,   0, '1d2'	 , -1),	{15}
('Mithril Chain Mail^ [%P6,%P4]'		   ,  hard_armor, '[',%X'00000000',Nothing_flag,
    0,	 1800,	15, 240,   1,  -1,   0,	 24,   0, '1d4'	 , -1),	{16}
('Mithril Plate Armor^ [%P6,%P4]'			   ,  hard_armor, '[',%X'00000000',Nothing_flag,
    0,	 3600,	16, 400,   1,  -1,   0,	 32,   0, '2d4'	 , -1)	{17}
);
	{ Object list[1..max_objects] (All objects must be defined here)}
	object_list	:=	(
('& %M Mushroom~| of Poison'			   ,  food, ',',%X'00000000',%X'00000001',
  500,	    0, 257,   1,   1,	0,   0,	  0,   0, '0d0'	 ,  7),
('& %M Mushroom~| of Blindness'			   ,  food, ',',%X'00000000',%X'00000002',
  500,	    0, 258,   1,   1,	0,   0,	  0,   0, '0d0'	 ,  9),
('& %M Mushroom~| of Paranoia'			   ,  food, ',',%X'00000000',%X'00000004',
  500,	    0, 259,   1,   1,	0,   0,	  0,   0, '0d0'	 ,  9),
('& %M Mushroom~| of Confusion'			   ,  food, ',',%X'00000000',%X'00000008',
  500,	    0, 260,   1,   1,	0,   0,	  0,   0, '0d0'	 ,  7),
('& %M Mushroom~| of Hallucination'		   ,  food, ',',%X'00000000',%X'00000010',
  500,	    0, 261,   1,   1,	0,   0,	  0,   0, '0d0'	 , 13),
('& %M Mushroom~| of Cure Poison'		   ,  food, ',',%X'00000000',%X'00000020',
  500,	   60, 262,   1,   1,	0,   0,	  0,   0, '0d0'	 ,  8),
('& %M Mushroom~| of Cure Blindness'		   ,  food, ',',%X'00000000',%X'00000040',
  500,	   50, 263,   1,   1,	0,   0,	  0,   0, '0d0'	 , 10),
('& %M Mushroom~| of Cure Paranoia'		   ,  food, ',',%X'00000000',%X'00000080',
  500,	   25, 264,   1,   1,	0,   0,	  0,   0, '0d0'	 , 12),
('& %M Mushroom~| of Cure Confusion'		   ,  food, ',',%X'00000000',%X'00000100',
  500,	   50, 265,   1,   1,	0,   0,	  0,   0, '0d0'	 ,  6),
('& %M Mushroom~| of Weakness'			   ,  food, ',',%X'00000000',%X'04000200',
  500,	    0, 266,   1,   1,	0,   0,	  0,   0, '0d0'	 ,  7),
('& %M Mushroom~| of Unhealth'			   ,  food, ',',%X'00000000',%X'04000400',
  500,	   50, 267,   1,   1,	0,   0,	  0,   0, '10d10', 15),
('& %M Mushroom~| of Restore Constitution'	   ,  food, ',',%X'00000000',%X'00010000',
  500,	  350, 268,   1,   1,	0,   0,	  0,   0, '0d0'	 , 20),
('& %M Mushroom~| of First-Aid'			   ,  food, ',',%X'00000000',%X'00200000',
  500,	    5, 269,   1,   1,	0,   0,	  0,   0, '0d0'	 ,  6),
('& %M Mushroom~| of Minor Cures'		   ,  food, ',',%X'00000000',%X'00400000',
  500,	   20, 270,   1,   1,	0,   0,	  0,   0, '0d0'	 ,  7),
('& %M Mushroom~| of Light Cures'		   ,  food, ',',%X'00000000',%X'00800000',
  500,	   30, 271,   1,   1,	0,   0,	  0,   0, '0d0'	 , 10),
('& %M Mushroom~| of Restoring'			   ,  food, ',',%X'00000000',%X'001F8040',
  500,	 1000, 272,   1,   1,	0,   0,	  0,   0, '0d0'	 , 30),
('& Hairy %M Mold~| of Poison'			   ,  food, ',',%X'00000000',%X'00000001',
 1200,	    0, 273,   1,   1,	0,   0,	  0,   0, '0d0'	 , 15),
('& Hairy %M Mold~| of Hallucinations'		   ,  food, ',',%X'00000000',%X'00000010',
 1200,	    0, 274,   1,   1,	0,   0,	  0,   0, '0d0'	 , 18),
('& Hairy %M Mold~| of Cure Poison'		   ,  food, ',',%X'00000000',%X'00000020',
 1200,	   75, 275,   1,   1,	0,   0,	  0,   0, '0d0'	 , 19),
('& Hairy %M Mold~| of Unhealth'		   ,  food, ',',%X'00000000',%X'00000400',
 1200,	   25, 276,   1,   1,	0,   0,	  0,   0, '6d8'	 , 28),
('& Hairy %M Mold~| of Cure Serious Wounds'	   ,  food, ',',%X'00000000',%X'01800000',
 1200,	   75, 277,   2,   1,	0,   0,	  0,   0, '0d0'	 , 16),
('& Ration~ of Food'				   ,  food, ',',%X'00000000',Nothing_flag,
 5000,	    3, 307,  10,   1,	0,   0,	  0,   0, '0d0'	 ,  0),
('& Ration~ of Food'				   ,  food, ',',%X'00000000',Nothing_flag,
 5000,	    3, 307,  10,   1,	0,   0,	  0,   0, '0d0'	 ,  5),
('& Ration~ of Food'				   ,  food, ',',%X'00000000',Nothing_flag,
 5000,	    3, 307,  10,   1,	0,   0,	  0,   0, '0d0'	 , 10),
('& Slime Mold~'				   ,  food, ',',%X'00000000',Nothing_flag,
 3000,	    2, 308,   5,   1,	0,   0,	  0,   0, '0d0'	 ,  1),
('& Piece~ of Elvish Waybread'			   ,  food, ',',%X'00000000',%X'21800020',
 3500,	   10, 313,   3,   1,	0,   0,	  0,   0, '0d0'	 ,  6),
('& Handful~ of Berries| (Poisonous)'  		   ,  food, ',',%X'00000000',%X'0C0000000',
 1000,	    0, 316,   3,   1,	0,   0,	  0,   0, '0d0'	 ,  8),
('& Piece~ of Elvish Waybread'			   ,  food, ',',%X'00000000',%X'21800020',
 3500,	   10, 313,   3,   1,	0,   0,	  0,   0, '0d0'	 , 12),
('& Handful~ of Berries| (Smurfberries)'  	   ,  food, ',',%X'00000000',%X'10400000',
 1000,	    0, 317,   3,   1,	0,   0,	  0,   0, '0d0'	 , 20),
('& Piece~ of Elvish Waybread'			   ,  food, ',',%X'00000000',%X'21800020',
 3500,	   10, 313,   3,   1,	0,   0,	  0,   0, '0d0'	 , 30),
('& Handful~ of Berries| (Goodberries)'		   ,  food, ',',%X'00000000',%X'10C00080',
 1000,	    0, 318,   3,   1,	0,   0,	  0,   0, '0d0'	 , 40),
('& Jolly Green Jelly~| (Ho Ho Ho!)'  		   ,  food, 'J',%X'00000000',%X'224001C0',
 2000,	    0, 315,   3,   1,	0,   0,	  0,   0, '0d0'	 , 50),
('& Dagger (Main Gauche)^ (%P2,%P3)'		   , dagger, '|',%X'10000000',Nothing_flag,
    0,	   25,	 1,  30,   1,	0,   0,	  0,   0, '1d5'	 ,  2),
('& Dagger (Misercorde)^ (%P2,%P3)'		   , dagger, '|',%X'10000000',Nothing_flag,
    0,	   10,	 2,  15,   1,	0,   0,	  0,   0, '1d4'	 ,  0),
('& Dagger (Stiletto)^ (%P2,%P3)'		   , dagger, '|',%X'10000000',Nothing_flag,
    0,	   10,	 3,  12,   1,	0,   0,	  0,   0, '1d4'	 ,  0),
('& Dagger (Bodkin)^ (%P2,%P3)'			   , dagger, '|',%X'10000000',Nothing_flag,
    0,	   10,	 4,  20,   1,	0,   0,	  0,   0, '1d4'	 ,  1),
('& Broken dagger^ (%P2,%P3)'			   , dagger, '|',%X'10000000',Nothing_flag,
    0,	    0,	 5,  15,   1,  -2,  -2,	  0,   0, '1d1'	 ,  0),
('& Backsword^ (%P2,%P3)'			   ,  sword, '|',%X'10000000',Nothing_flag,
    0,	   60,	 6,  95,   1,	0,   0,	  0,   0, '1d9'	 ,  7),
('& Bastard Sword^ (%P2,%P3)'			   ,  sword, '|',%X'10000000',Nothing_flag,
    0,	  350,	 7, 140,   1,	0,   0,	  0,   0, '3d4'	 , 14),
('& Thrusting Sword (Bilbo)^ (%P2,%P3)'		   ,  dagger, '|',%X'10000000',Nothing_flag,
    0,	   60,	 8,  80,   1,	0,   0,	  0,   0, '1d6'	 ,  4),
('& Thrusting Sword (Baselard)^ (%P2,%P3)'	   ,  dagger, '|',%X'10000000',Nothing_flag,
    0,	   80,	 9, 100,   1,	0,   0,	  0,   0, '1d7'	 ,  5),
('& Broadsword^ (%P2,%P3)'			   ,  sword, '|',%X'10000000',Nothing_flag,
    0,	  255,	10, 150,   1,	0,   0,	  0,   0, '2d5'	 ,  9),
('& Two Handed Sword (Claymore)^ (%P2,%P3)'	   ,  sword, '|',%X'10000000',Nothing_flag,
    0,	  775,	11, 200,   1,	0,   0,	  0,   0, '3d6'	 , 30),
('& Cutlass^ (%P2,%P3)'				   ,  sword, '|',%X'10000000',Nothing_flag,
    0,	   85,	12, 110,   1,	0,   0,	  0,   0, '1d7'	 ,  7),
('& Two Handed Sword (Espadon)^ (%P2,%P3)'	   ,  sword, '|',%X'10000000',Nothing_flag,
    0,	  655,	13, 180,   1,	0,   0,	  0,   0, '3d6'	 , 35),
('& Executioner''s Sword^ (%P2,%P3)'		   ,  sword, '|',%X'10000000',Nothing_flag,
    0,	  850,	14, 260,   1,	0,   0,	  0,   0, '4d5'	 , 40),
('& Two Handed Sword (Flamberge)^ (%P2,%P3)'	   ,  sword, '|',%X'10000000',Nothing_flag,
    0,	 1000,	15, 240,   1,	0,   0,	  0,   0, '4d5'	 , 45),
('& Foil^ (%P2,%P3)'				   ,  dagger, '|',%X'10000000',Nothing_flag,
    0,	   35,	16,  30,   1,	0,   0,	  0,   0, '1d5'	 ,  2),
('& Katana^ (%P2,%P3)'				   ,  sword, '|',%X'10000000',Nothing_flag,
    0,	  400,	17, 120,   1,	0,   0,	  0,   0, '3d4'	 , 18),
('& Longsword^ (%P2,%P3)'			   ,  sword, '|',%X'10000000',Nothing_flag,
    0,	  300,	18, 130,   1,	0,   0,	  0,   0, '1d10' , 12),
('& Two Handed Sword (No-Dachi)^ (%P2,%P3)'	   ,  sword, '|',%X'10000000',Nothing_flag,
    0,	  675,	19, 200,   1,	0,   0,	  0,   0, '4d4'	 , 45),
('& Rapier^ (%P2,%P3)'				   ,  dagger, '|',%X'10000000',Nothing_flag,
    0,	   42,	20,  40,   1,	0,   0,	  0,   0, '1d6'	 ,  4),
('& Sabre^ (%P2,%P3)'				   ,  sword, '|',%X'10000000',Nothing_flag,
    0,	   50,	21,  50,   1,	0,   0,	  0,   0, '1d7'	 ,  5),
('& Small Sword^ (%P2,%P3)'			   ,  dagger, '|',%X'10000000',Nothing_flag,
    0,	   48,	22,  75,   1,	0,   0,	  0,   0, '1d6'	 ,  5),
('& Two Handed Sword (Zweihander)^ (%P2,%P3)'	   ,  sword, '|',%X'10000000',Nothing_flag,
    0,	 1000,	23, 280,   1,	0,   0,	  0,   0, '4d6'	 , 50),
('& Broken sword^ (%P2,%P3)'			   ,  sword, '|',%X'10000000',Nothing_flag,
    0,	    0,	24,  75,   1,  -2,  -2,	  0,   0, '1d1'	 ,  0),
('& Battle Axe (Balestarius)^ (%P2,%P3)'	   ,  hafted_weapon, '\',%X'1000000',Nothing_flag,
    0,	  500,	 1, 180,   1,	0,   0,	  0,   0, '2d8'	 , 30),
('& Ball and Chain^ (%P2,%P3)'			   ,  maul, '\',%X'00000000',Nothing_flag,
    0,	  200,	 2, 150,   1,	0,   0,	  0,   0, '2d4'	 , 20),
('& Battle Axe (European)^ (%P2,%P3)'		   ,  hafted_weapon, '\',%X'10000000',Nothing_flag,
    0,	  334,	 3, 170,   1,	0,   0,	  0,   0, '3d4'	 , 13),
('& Broad Axe^ (%P2,%P3)'			   ,  hafted_weapon, '\',%X'10000000',Nothing_flag,
    0,	  304,	 4, 160,   1,	0,   0,	  0,   0, '2d6'	 , 17),
('& Cat-O-Nine Tails^ (%P2,%P3)'		   ,  dagger, '\',%X'00000000',Nothing_flag,
    0,	   14,	 5,  40,   1,	0,   0,	  0,   0, '1d4'	 ,  3),
('& Wooden Club^ (%P2,%P3)'			   ,  maul, '\',%X'00000000',Nothing_flag,
    0,	    1,	 6, 100,   1,	0,   0,	  0,   0, '1d3'	 ,  0),
('& Flail^ (%P2,%P3)'				   ,  maul, '\',%X'00000000',Nothing_flag,
    0,	  353,	 7, 150,   1,	0,   0,	  0,   0, '2d6'	 , 12),
('& Two Handed Great Flail^ (%P2,%P3)'		   ,  maul, '\',%X'00000000',Nothing_flag,
    0,	  590,	 8, 280,   1,	0,   0,	  0,   0, '3d6'	 , 45),
('& Morningstar^ (%P2,%P3)'			   ,  maul, '\',%X'00000000',Nothing_flag,
    0,	  396,	 9, 150,   1,	0,   0,	  0,   0, '2d6'	 , 10),
('& Mace^ (%P2,%P3)'				   ,  maul, '\',%X'00000000',Nothing_flag,
    0,	  130,	10, 120,   1,	0,   0,	  0,   0, '2d4'	 ,  6),
('& War Hammer^ (%P2,%P3)'			   ,  maul, '\',%X'00000000',Nothing_flag,
    0,	  225,	11, 120,   1,	0,   0,	  0,   0, '3d3'	 ,  5),
('& Mace (Lead filled)^ (%P2,%P3)'		   ,  maul, '\',%X'00000000',Nothing_flag,
    0,	  502,	12, 180,   1,	0,   0,	  0,   0, '3d4'	 , 15),
('& Iron Shod Quarterstaff^ (%P2,%P3)'		   ,  maul, '\',%X'00000000',Nothing_flag,
    0,	   25,  13, 100,   1,   0,   0,   0,   0, '1d5'  ,  2),
('& Awl-Pike^ (%P2,%P3)'			   ,  pole_arm, '/',%X'10000000',Nothing_flag,
    0,	  340,	 1, 160,   1,	0,   0,	  0,   0, '1d8'	 ,  8),
('& Beaked Axe^ (%P2,%P3)'			   ,  pole_arm, '/',%X'10000000',Nothing_flag,
    0,	  408,	 2, 180,   1,	0,   0,	  0,   0, '2d6'	 , 15),
('& Fauchard^ (%P2,%P3)'			   ,  pole_arm, '/',%X'10000000',Nothing_flag,
    0,	  376,	 3, 170,   1,	0,   0,	  0,   0, '1d10' , 17),
('& Glaive^ (%P2,%P3)'				   ,  pole_arm, '/',%X'10000000',Nothing_flag,
    0,	  363,	 4, 190,   1,	0,   0,	  0,   0, '2d6'	 , 20),
('& Halberd^ (%P2,%P3)'				   ,  pole_arm, '/',%X'10000000',Nothing_flag,
    0,	  430,	 5, 190,   1,	0,   0,	  0,   0, '3d4'	 , 22),
('& Lucerne Hammer^ (%P2,%P3)'			   ,  pole_arm, '/',%X'00000000',Nothing_flag,
    0,	  376,	 6, 120,   1,	0,   0,	  0,   0, '2d5'	 , 11),
('& Pike^ (%P2,%P3)'				   ,  pole_arm, '/',%X'10000000',Nothing_flag,
    0,	  358,	 7, 160,   1,	0,   0,	  0,   0, '2d5'	 , 15),
('& Spear^ (%P2,%P3)'				   ,  pole_arm, '/',%X'10000000',Nothing_flag,
    0,	   36,	 8,  50,   1,	0,   0,	  0,   0, '1d6'	 ,  5),
('& Lance^ (%P2,%P3)'				   ,  pole_arm, '/',%X'10000000',Nothing_flag,
    0,	  230,	 9, 300,   1,	0,   0,	  0,   0, '2d8'	 , 10),
('& Javelin^ (%P2,%P3)'				   ,  pole_arm, '/',%X'10000000',Nothing_flag,
    0,	   18,	10,  30,   1,	0,   0,	  0,   0, '1d4'	 ,  4),
('& Short Bow^ (%P2)'				   ,  bow_crossbow_or_sling, '}',%X'00000000',Nothing_flag,
    2,	   50,	 1,  30,   1,	0,   0,	  0,   0, '0d0'	 ,  3),
('& Long Bow^ (%P2)'				   ,  bow_crossbow_or_sling, '}',%X'00000000',Nothing_flag,
    3,	  120,	 2,  40,   1,	0,   0,	  0,   0, '0d0'	 , 10),
('& Composite Bow^ (%P2)'			   ,  bow_crossbow_or_sling, '}',%X'00000000',Nothing_flag,
    4,	  240,	 3,  40,   1,	0,   0,	  0,   0, '0d0'	 , 40),
('& Light Crossbow^ (%P2)'			   ,  bow_crossbow_or_sling, '}',%X'00000000',Nothing_flag,
    5,	  140,	10, 110,   1,	0,   0,	  0,   0, '0d0'	 , 15),
('& Heavy Crossbow^ (%P2)'			   ,  bow_crossbow_or_sling, '}',%X'00000000',Nothing_flag,
    6,	  300,	11, 200,   1,	0,   0,	  0,   0, '1d1'	 , 30),
('& Sling^ (%P2)'				   ,  bow_crossbow_or_sling, '}',%X'00000000',Nothing_flag,
    1,	    5,	20,   5,   1,	0,   0,	  0,   0, '0d0'	 ,  1),
('& Arrow~^ (%P2,%P3)'				   ,  arrow, '{',%X'10000000',Nothing_flag,
    0,	    1,	 1,   2,   1,	0,   0,	  0,   0, '3d4'	 ,  2),
('& Bolt~^ (%P2,%P3)'				   ,  bolt, '{',%X'10000000',Nothing_flag,
    0,	    2,	 1,   3,   1,	0,   0,	  0,   0, '3d5'	 ,  2),
('& Rounded Pebble~^ (%P2,%P3)'			   ,  sling_ammo, '{',%X'00000000',Nothing_flag,
    0,	    1,	 1,   4,   1,	0,   0,	  0,   0, '3d2'	 ,  0),
('& Iron Shot~^ (%P2,%P3)'			   ,  sling_ammo, '{',%X'00000000',Nothing_flag,
    0,	    2,	 1,   5,   1,	0,   0,	  0,   0, '3d3'	 ,  3),
('& Iron Spike~'				   ,  spike, '~',%X'10000000',Nothing_flag,
    0,	    1,	 1,  10,   1,	0,   0,	  0,   0, '1d1'	 ,  1),
('& Magic Lantern^ (%P5 turns left)'		   ,  Lamp_or_Torch, '~',%X'00000000',Nothing_flag,
20000,	  200,	17,  45,   1,	0,   0,	  0,   0, '1d8'	 , 20),
('& Magic Torch^ (%P5 turns left)'		   ,  Lamp_or_Torch, '~',%X'00000000',Nothing_flag,
 9000,	   30,	15,   1,   1,	0,   0,	  0,   0, '2d6'	 , 10),
('& Brass Lantern~ with %P5 turns of light'	   ,  Lamp_or_Torch, '~',%X'00000000',Nothing_flag,
 7500,	   35,	 1,  50,   1,	0,   0,	  0,   0, '1d1'	 ,  1),
('& Wooden Torch~ with %P5 turns of light'	   ,  Lamp_or_Torch, '~',%X'00000000',Nothing_flag,
 4000,	    2,	13,  30,   1,	0,   0,	  0,   0, '1d1'	 ,  1),
('& Orcish Pick^ (%P1) (%P2,%P3)'		   ,  25, '\',%X'10000000',Tunneling_worn_bit,
    2,	  500,	 2, 180,   1,	0,   0,	  0,   0, '1d3'	 , 20),
('& Dwarven Pick^ (%P1) (%P2,%P3)'		   ,  25, '\',%X'10000000',Tunneling_worn_bit,
    3,	 1200,	 3, 200,   1,	0,   0,	  0,   0, '1d4'	 , 50),
('& Gnomish Shovel^ (%P1) (%P2,%P3)'		   ,  25, '\',%X'00000000',Tunneling_worn_bit,
    1,	  100,	 5,  50,   1,	0,   0,	  0,   0, '1d2'	 , 20),
('& Dwarven Shovel^ (%P1) (%P2,%P3)'		   ,  25, '\',%X'00000000',Tunneling_worn_bit,
    2,	  250,	 6, 120,   1,	0,   0,	  0,   0, '1d3'	 , 40),
('& Orcish Pick^ (%P1) (%P2,%P3)'		   ,  25, '\',%X'10000000',%X'20100084',
    3,	 1500,	 7, 180,   1,	0,   0,	  0,   0, '2d3'	 , 40),
('& Pair of Soft Leather Shoes^ [%P6,%P4]'	,  boots, ']',%X'00000000',Nothing_flag,
    0,	    4,	 1,   5,   1,	0,   0,	  1,   0, '0d0'	 ,  1),
('& Pair of Soft Leather Boots^ [%P6,%P4]'	,  boots, ']',%X'00000000',Nothing_flag,
    0,	    7,	 2,  20,   1,	0,   0,	  2,   0, '1d1'	 ,  4),
('& Pair of Hard Leather Boots^ [%P6,%P4]'	   	,  boots, ']',%X'00000000',Nothing_flag,
    0,	   12,	 3,  40,   1,	0,   0,	  3,   0, '1d1'	 ,  6),
('& Pair of Sandals^ [%P6,%P4]'			,  boots, ']',Nothing_flag,Nothing_flag,
    0,      1,   4,   1,   1,   0,   0,   0,   0, '0d0'  ,  1),
('& Soft Leather Cap^ [%P6,%P4]'		   ,  helm, ']',%X'00000000',Nothing_flag,
    0,	    4,	 1,  10,   1,	0,   0,	  1,   0, '0d0'	 ,  2),
('& Hard Leather Cap^ [%P6,%P4]'		   ,  helm, ']',%X'00000000',Nothing_flag,
    0,	   12,	 2,  15,   1,	0,   0,	  2,   0, '0d0'	 ,  4),
('& Metal Cap^ [%P6,%P4]'			   ,  helm, ']',%X'00000000',Nothing_flag,
    0,	   30,	 3,  20,   1,	0,   0,	  3,   0, '1d1'	 ,  7),
('& Iron Helm^ [%P6,%P4]'			   ,  helm, ']',%X'00000000',Nothing_flag,
    0,	   75,	 4,  75,   1,	0,   0,	  5,   0, '1d3'	 , 20),
('& Steel Helm^ [%P6,%P4]'			   ,  helm, ']',%X'00000000',Nothing_flag,
    0,	  200,	 5,  60,   1,	0,   0,	  6,   0, '1d3'	 , 40),
('& Silver Crown^ [%P6,%P4] (%P1)'		   ,  helm, ']',%X'00000000',Nothing_flag,
    0,	  250,	 6,  20,   1,	0,   0,	  0,   0, '1d1'	 , 44),
('& Golden Crown^ [%P6,%P4] (%P1)'		   ,  helm, ']',%X'00000000',Nothing_flag,
    0,	  500,	 7,  30,   1,	0,   0,	  0,   0, '1d1'	 , 47),
('& Jewel Encrusted Crown^ [%P6,%P4] (%P1)'	   ,  helm, ']',%X'00000000',Nothing_flag,
    0,	 1000,	 8,  40,   1,	0,   0,	  0,   0, '1d1'	 , 50),
('& Iron Helm^ of Gems [%P6,%P4]'			   ,  gem_helm, ']',%X'00000000',%X'00000000',
    2,    300,   9,  75,   1,   0,   0,   2,   0, '1d3'  , 50),
('& Steel Helm^ of Gems [%P6,%P4]'			   ,  gem_helm, ']',%X'00000000',%X'00000000',
    5,    700,   10,  60,   1,   0,   0,  3,   0, '1d3'  , 75),
('& Cloth Hat^ [%P6,%P4]'			   ,  helm, '~',Nothing_flag,Nothing_flag,
    0,      5,   11,   5,   1,   0,   0,  0,   0, '0d0'  ,  1),
('& Cloth Hat^ [%P6,%P4]'			   ,  helm, '~',Nothing_flag,Nothing_flag,
    0,      5,   11,   5,   1,   0,   0,  0,   0, '0d0'  ,  1),
('& Finely cut %R| of Teleportation^'			   , valuable_gems_wear, '*',%X'00000000',%X'00000400',
    0,    300,   1,   5,   1,   0,   0,   0,   0, '0d0'  , 5),
('& Finely cut %R| of Resist Cold^'			   , valuable_gems_wear, '*',%X'00000000',%X'00200000',
    0,    250,   2,   5,   1,   0,   0,   0,   0, '0d0'  , 14),
('& Finely cut %R| of Resist Acid^'			   , valuable_gems_wear, '*',%X'00000000',%X'00100000',
    0,    250,   3,   5,   1,   0,   0,   0,   0, '0d0'  , 14),
('& Finely cut %R| of See Invisible^'			   , valuable_gems_wear, '*',%X'00000000',%X'01000000',
    0,    350,   4,   5,   1,   0,   0,   0,   0, '0d0'  , 40),
('& Finely cut %R| of Stealth^'			   , valuable_gems_wear, '*',%X'00000000',%X'00000100',
    0,    300,   5,   5,   1,   0,   0,   0,   0, '0d0'  , 35),
('& Finely cut %R| of Slow Digestion^'			   , valuable_gems_wear, '*',%X'00000000',%X'00000800',
    0,    200,   6,   5,   1,   0,   0,   0,   0, '0d0'  , 14),
('& Finely cut %R| of Lordly Protection (FIRE)^'			   , valuable_gems_wear, '*',%X'00000000',%X'00000800',
    0,    1200,   7,   5,   1,   0,   0,   0,   5, '0d0'  , 40),
('& Robe^ [%P6,%P4]'				   ,  soft_armor, '(',%X'00000000',Nothing_flag,
    0,	    4,	 1,  20,   1,	0,   0,	  2,   0, '0d0'	 ,  1),
('Soft Leather Armor^ [%P6,%P4]'		   ,  soft_armor, '(',%X'00000000',Nothing_flag,
    0,	   18,	 2,  80,   1,	0,   0,	  4,   0, '0d0'	 ,  2),
('Soft Studded Leather^ [%P6,%P4]'		   ,  soft_armor, '(',%X'00000000',Nothing_flag,
    0,	   35,	 3,  90,   1,	0,   0,	  5,   0, '1d1'	 ,  3),
('Hard Leather Armor^ [%P6,%P4]'		   ,  soft_armor, '(',%X'00000000',Nothing_flag,
    0,	   55,	 4, 100,   1,  -1,   0,	  6,   0, '1d1'	 ,  5),
('Hard Studded Leather^ [%P6,%P4]'		   ,  soft_armor, '(',%X'00000000',Nothing_flag,
    0,	  100,	 5, 110,   1,  -1,   0,	  7,   0, '1d2'	 ,  7),
('Woven Cord Armor^ [%P6,%P4]'			   ,  soft_armor, '(',%X'00000000',Nothing_flag,
    0,	   45,	 6, 150,   1,  -1,   0,	  6,   0, '0d0'	 ,  7),
('Soft Leather Ring Mail^ [%P6,%P4]'		   ,  soft_armor, '(',%X'00000000',Nothing_flag,
    0,	  160,	 7, 130,   1,  -1,   0,	  6,   0, '1d2'	 , 10),
('Hard Leather Ring Mail^ [%P6,%P4]'		   ,  soft_armor, '(',%X'00000000',Nothing_flag,
    0,	  230,	 8, 150,   1,  -2,   0,	  8,   0, '1d3'	 , 12),
('Leather Scale Mail^ [%P6,%P4]'		   ,  soft_armor, '(',%X'00000000',Nothing_flag,
    0,	  330,	 9, 140,   1,  -1,   0,	 11,   0, '1d1'	 , 16),
('Leather Brigantine Armor^ [%P6,%P4]'		   ,  soft_armor, '(',%X'00000000',Nothing_flag,
    0,	  380,	10, 190,   1,  -1,   0,	 12,   0, '1d2'	 , 20),
('Metal Scale Mail^ [%P6,%P4]'			   ,  hard_armor, '[',%X'00000000',Nothing_flag,
    0,	  430,	 1, 250,   1,  -2,   0,	 13,   0, '1d4'	 , 24),
('Chain Mail^ [%P6,%P4]'			   ,  hard_armor, '[',%X'00000000',Nothing_flag,
    0,	  530,	 2, 220,   1,  -2,   0,	 14,   0, '1d4'	 , 26),
('Rusty Chain Mail^ [%P6,%P4]'			   ,  hard_armor, '[',%X'00000000',Nothing_flag,
    0,	    0,	 3, 200,   1,  -5,   0,	 14,  -8, '1d4'	 , 26),
('Double Chain Mail^ [%P6,%P4]'			   ,  hard_armor, '[',%X'00000000',Nothing_flag,
    0,	  630,	 4, 260,   1,  -2,   0,	 15,   0, '1d4'	 , 28),
('Augmented Chain Mail^ [%P6,%P4]'		   ,  hard_armor, '[',%X'00000000',Nothing_flag,
    0,	  675,	 5, 270,   1,  -2,   0,	 16,   0, '1d4'	 , 30),
('Bronze Plate Mail^ [%P6,%P4]'			   ,  hard_armor, '[',%X'00000000',Nothing_flag,
    0,	  700,	13, 380,   1,  -4,   0,	 21,   0, '1d6'	 , 32),
('Bar Chain Mail^ [%P6,%P4]'			   ,  hard_armor, '[',%X'00000000',Nothing_flag,
    0,	  720,	 6, 280,   1,  -2,   0,	 18,   0, '1d4'	 , 34),
('Metal Brigandine Armor^ [%P6,%P4]'		   ,  hard_armor, '[',%X'00000000',Nothing_flag,
    0,	  775,	 7, 290,   1,  -3,   0,	 19,   0, '1d4'	 , 36),
('Laminated Armor^ [%P6,%P4]'			   ,  hard_armor, '[',%X'00000000',Nothing_flag,
    0,	  825,	 8, 300,   1,  -3,   0,	 20,   0, '1d4'	 , 38),
('Partial Plate Armor^ [%P6,%P4]'		   ,  hard_armor, '[',%X'00000000',Nothing_flag,
    0,	  900,	 9, 260,   1,  -3,   0,	 22,   0, '1d6'	 , 42),
('Metal Lamellar Armor^ [%P6,%P4]'		   ,  hard_armor, '[',%X'00000000',Nothing_flag,
    0,	  950,	10, 340,   1,  -3,   0,	 23,   0, '1d6'	 , 44),
('Full Plate Armor^ [%P6,%P4]'			   ,  hard_armor, '[',%X'00000000',Nothing_flag,
    0,	 1050,	11, 380,   1,  -3,   0,	 25,   0, '2d4'	 , 48),
('Ribbed Plate Armor^ [%P6,%P4]'		   ,  hard_armor, '[',%X'00000000',Nothing_flag,
    0,	 1200,	12, 380,   1,  -3,   0,	 28,   0, '2d4'	 , 50),
('& Cloak^ [%P6,%P4]'				   ,  Cloak, '(',%X'00000000',Nothing_flag,
    0,	    3,	 1,  10,   1,	0,   0,	  1,   0, '0d0'	 ,  1),
('& Cloak^ [%P6,%P4]'				   ,  Cloak, '(',%X'00000000',Nothing_flag,
    0,	    3,	 1,  10,   1,	0,   0,	  1,   0, '0d0'	 ,  1),
('& Set of Leather Gloves^ [%P6,%P4]'		   ,  gloves_and_gauntlets, ']',%X'00000000',Nothing_flag,
    0,	    3,	 1,   5,   1,	0,   0,	  1,   0, '0d0'	 ,  1),
('& Set of Gauntlets^ [%P6,%P4]'		   ,  gloves_and_gauntlets, ']',%X'00000000',Nothing_flag,
    0,	   35,	 2,  25,   1,	0,   0,	  2,   0, '1d1'	 , 12),
('& Set of Cloth Gloves^ [%P6,%P4]'		   ,  gloves_and_gauntlets, ']',Nothing_flag,Nothing_flag,
    0,      1,   5,   1,   1,   0,   0,   0,   0, '0d0'  ,  1),
('& Silver Belt Buckle'				   ,  belt , '*', Nothing_flag,Nothing_flag,
    0,     30,  10,  50,    1,   0,   0,   0,   0, '0d0'  ,  5),
('& Gold Belt Buckle'				   ,  belt , '*', Nothing_flag,Nothing_flag,
    0,    120,  11,  50,    1,   0,   0,   0,   0, '0d0'  , 10),
('& Leather Belt'				   ,  belt , '(', Nothing_flag,Nothing_flag,
    0,    10,   13,  75,    1,   0,   0,   0,   0, '0d0'  ,  1),
('& Girdle^ [%P6,%P4]'	         		   ,  belt , '(', Nothing_flag,Nothing_flag,
    0,      0,   1, 100,    1,   0,   0,   1,   0, '0d0'  , 10),
('& Set of Bracers^ of Protection'		   ,  bracers, ']', %X'00000000',%X'00000000',
    0,	 1200,	 1, 125,   1,	0,   0,	  6,   0, '0d0'	 , 35),
('& Set of Bracers^ of Defense'		   ,  bracers, ']', %X'00000000',%X'00000000',
    0,	 2400,	 2, 125,   1,	0,   0,	  7,   0, '0d0'	 , 40),
('& Set of Bracers^ of Shielding'		   ,  bracers, ']', %X'00000000',%X'00000000',
    0,	 3600,	 3, 125,   1,	0,   0,	  8,   0, '0d0'	 , 45),
('& Set of Mithril Bracers'		   ,  bracers, ']', %X'00000000',%X'00000000',
    0,	 4800,	 4, 125,   1,	0,   0,	  9,   0, '0d0'	 , 50),
('& Set of Adamantite Bracers'		   ,  bracers, ']', %X'00000000',%X'00000000',
    0,	 6000,	 5, 125,   1,	0,   0,	 10,   0, '0d0'	 , 55),
('& Set of Bracers^ of Weapon Attraction'	   ,  bracers, ']', %X'00000000',%X'80000000',
    0,	-1200,	 6, 125,   1,   -6,   0,  -6,   0, '0d0'	 , 30),
('& Small silver Bracelet^ of Warding (R)'	   ,  bracers, '*', %X'00000010',%X'02380000',
    1,  10000,   7,   5,   1,    0,   0,   5,   0, '0d0' , 50), 
('& Small Leather Shield^ [%P6,%P4]'		   ,  shield, ')',%X'00000000',Nothing_flag,
    0,	   30,	 1,  50,   1,	0,   0,	  2,   0, '1d1'	 ,  3),
('& Medium Leather Shield^ [%P6,%P4]'		   ,  shield, ')',%X'00000000',Nothing_flag,
    0,	   60,	 2,  75,   1,	0,   0,	  3,   0, '1d2'	 ,  8),
('& Large Leather Shield^ [%P6,%P4]'		   ,  shield, ')',%X'00000000',Nothing_flag,
    0,	  120,	 3, 100,   1,	0,   0,	  4,   0, '1d2'	 , 15),
('& Small Metal Shield^ [%P6,%P4]'		   ,  shield, ')',%X'00000000',Nothing_flag,
    0,	   50,	 4,  65,   1,	0,   0,	  3,   0, '1d2'	 , 10),
('& Medium Metal Shield^ [%P6,%P4]'		   ,  shield, ')',%X'00000000',Nothing_flag,
    0,	  125,	 5,  90,   1,	0,   0,	  4,   0, '1d3'	 , 20),
('& Large Metal Shield^ [%P6,%P4]'		   ,  shield, ')',%X'00000000',Nothing_flag,
    0,	  200,	 6, 120,   1,	0,   0,	  5,   0, '1d3'	 , 30),
('& %R Ring| of Gain Strength^ (%P1)'		   ,  ring, '=',0,Strength_worn_bit,
    0,	  400,	 1,   2,   1,	0,   0,	  0,   0, '0d0'	 , 30),
('& %R Ring| of Gain Dexterity^ (%P1)'		   ,  ring, '=',0,Dexterity_worn_bit,
    0,	  400,	 2,   2,   1,	0,   0,	  0,   0, '0d0'	 , 30),
('& %R Ring| of Gain Constitution^ (%P1)'	   ,  ring, '=',0,Constitution_worn_bit,
    0,	  400,	 3,   2,   1,	0,   0,	  0,   0, '0d0'	 , 30),
('& %R Ring| of Gain Intelligence^ (%P1)'	   ,  ring, '=',0,Intelligence_worn_bit,
    0,	  350,	 4,   2,   1,	0,   0,	  0,   0, '0d0'	 , 30),
('& %R Ring| of Speed^ (%P1)'			   ,  ring, '=',0,Speed_worn_bit,
    0,	 8000,	 7,   2,   1,	0,   0,	  0,   0, '0d0'	 , 50),
('& %R Ring| of Speed^ (%P1)'			   ,  ring, '=', 0, Speed_worn_bit,
    0,	    1,	35,   2,   1,	0,   0,	  0,   0, '0d0'	 ,  5),
('& %R Ring| of Searching^ (%P1)'		   ,  ring, '=',0,Searching_worn_bit,
    0,	  250,	 8,   2,   1,	0,   0,	  0,   0, '0d0'	 ,  7),
('& %R Ring| of Teleportation^'			    ,  ring, '=',0,Cursed_worn_bit+Teleportation_worn_bit,
    0,	    0,	 9,   2,   1,	0,   0,	  0,   0, '0d0'	 ,  7),
('& %R Ring| of Slow Digestion^'		   ,  ring, '=',0,Slow_digestion_worn_bit,
    0,	  250,	10,   2,   1,	0,   0,	  0,   0, '0d0'	 ,  7),
('& %R Ring| of Resist Fire^'			   ,  ring, '=',0,Resist_fire_worn_bit,
    0,	  250,	11,   2,   1,	0,   0,	  0,   0, '0d0'	 , 14),
('& %R Ring| of Resist Cold^'			   ,  ring, '=',0,Resist_cold_worn_bit,
    0,	  250,	12,   2,   1,	0,   0,	  0,   0, '0d0'	 , 14),
('& %R Ring| of Feather Falling^'		   ,  ring, '=',0,Feather_Fall_worn_bit,
    0,	  200,	13,   2,   1,	0,   0,	  0,   0, '0d0'	 ,  7),
('& %R Ring| of Adornment^'			   ,  ring, '=',%X'00000000',Nothing_flag,
    0,	   20,	14,   2,   1,	0,   0,	  0,   0, '0d0'	 ,  7),
('& %R Ring| of Adornment^'			   ,  ring, '=',%X'00000000',Nothing_flag,
    0,	   30,	15,   2,   1,	0,   0,	  0,   0, '0d0'	 ,  7),
('& %R Ring| of Weakness^'			   ,  ring, '=',0,Cursed_worn_bit+Strength_worn_bit,
   -5,	    0,	16,   2,   1,	0,   0,	  0,   0, '0d0'	 ,  7),
('& %R Ring| of Lordly Protection (FIRE)^'	   ,  ring, '=',0,Resist_fire_worn_bit,
    0,	 1200,	17,   2,   1,	0,   0,	  0,   5, '0d0'	 , 50),
('& %R Ring| of Lordly Protection (ACID)^'	   ,  ring, '=',0,Resist_acid_worn_bit,
    0,	 1200,	18,   2,   1,	0,   0,	  0,   5, '0d0'	 , 50),
('& %R Ring| of Lordly Protection (COLD)^'	   ,  ring, '=',0,Resist_cold_worn_bit,
    0,	 1200,	19,   2,   1,	0,   0,	  0,   5, '0d0'	 , 50),
('& %R Ring| of WOE^'				   ,  ring, '=',0,
Cursed_worn_bit+Aggravation_worn_bit+teleportation_worn_bit,
   -5,	    0,	20,   2,   1,	0,   0,	  0,  -3, '0d0'	 , 50),
('& %R Ring| of Stupidity^'			   ,  ring, '=',0,
Cursed_worn_bit+Intelligence_worn_bit,
   -5,	    0,	21,   2,   1,	0,   0,	  0,   0, '0d0'	 , 20),
('& %R Ring| of Increase Damage^ (%P3)'		   ,  ring, '=',%X'00000000',Nothing_flag,
    0,	  100,	22,   2,   1,	0,   0,	  0,   0, '0d0'	 , 20),
('& %R Ring| of Increase To-Hit^ (%P2)'		   ,  ring, '=',%X'00000000',Nothing_flag,
    0,	  100,	23,   2,   1,	0,   0,	  0,   0, '0d0'	 , 20),
('& %R Ring| of Protection^ [%P4]'		   ,  ring, '=',%X'00000000',Nothing_flag,
    0,	  100,	24,   2,   1,	0,   0,	  0,   0, '0d0'	 ,  7),
('& %R Ring| of Aggravate Monster^'		   ,  ring, '=',0,
cursed_worn_bit+aggravation_worn_bit,
    0,	    0,	25,   2,   1,	0,   0,	  0,   0, '0d0'	 ,  7),
('& %R Ring| of See Invisible^'			   ,  ring, '=',0,see_invisible_worn_bit,
    0,	  340,	26,   2,   1,	0,   0,	  0,   0, '0d0'	 , 40),
('& %R Ring| of Sustain Strength^'		   ,  ring, '=',0,Sustain_Stat_worn_bit,
    1,	  750,	27,   2,   1,	0,   0,	  0,   0, '0d0'	 , 44),
('& %R Ring| of Sustain Intelligence^'		   ,  ring, '=',0,Sustain_Stat_worn_bit,
    2,	  600,	28,   2,   1,	0,   0,	  0,   0, '0d0'	 , 44),
('& %R Ring| of Sustain Wisdom^'		   ,  ring, '=',0,Sustain_Stat_worn_bit,
    3,	  600,	29,   2,   1,	0,   0,	  0,   0, '0d0'	 , 44),
('& %R Ring| of Sustain Constitution^'		   ,  ring, '=',0,Sustain_Stat_worn_bit,
    4,	  750,	30,   2,   1,	0,   0,	  0,   0, '0d0'	 , 44),
('& %R Ring| of Sustain Dexterity^'		   ,  ring, '=',0,Sustain_Stat_worn_bit,
    5,	  750,	31,   2,   1,	0,   0,	  0,   0, '0d0'	 , 44),
('& %R Ring| of Sustain Charisma^'		   ,  ring, '=',0,Sustain_Stat_worn_bit,
    6,	  500,	32,   2,   1,	0,   0,	  0,   0, '0d0'	 ,  7),
('& %R Ring| of Slaying^'			   ,  ring, '=',%X'00000000',Nothing_flag,
    6,	 1000,	33,   2,   1,	0,   0,	  0,   0, '0d0'	 , 50),
('& %R Ring| of Gnomekind^'			   ,  ring, '=',Nothing_flag,%x'00400088',
    2,   2000,  34,   2,   1,   0,   0,   0,   0, '0d0'  , 40),
('& %A Amulet| of Adornment^'			   ,  amulet, '"',%X'00000000',Nothing_flag,
    0,	   20,	11,   3,   1,	0,   0,	  0,   0, '0d0'	 , 16),
('& %A Amulet| of Adornment^'			   ,  amulet, '"',%X'00000000',Nothing_flag,
    0,	   30,	12,   3,   1,	0,   0,	  0,   0, '0d0'	 , 16),
('& %A Amulet| of Wisdom^ (%P1)'		   ,  amulet, '"',0,wisdom_worn_bit,
    0,	  300,	 5,   3,   1,	0,   0,	  0,   0, '0d0'	 , 20),
('& %A Amulet| of Charisma^ (%P1)'		   ,  amulet, '"',0,charisma_worn_bit,
    0,	  250,	 6,   3,   1,	0,   0,	  0,   0, '0d0'	 , 20),
('& %A Amulet| of Searching^ (%P1)'		   ,  amulet, '"',0,searching_worn_bit,
    0,	  250,	 7,   3,   1,	0,   0,	  0,   0, '0d0'	 , 14),
('& %A Amulet| of Teleportation^'		    , amulet, '"',0,cursed_worn_bit+teleportation_worn_bit,
    0,	    0,	 8,   3,   1,	0,   0,	  0,   0, '0d0'	 , 14),
('& %A Amulet| of Slow Digestion^'		   ,  amulet, '"',0,slow_digestion_worn_bit,
    0,	  200,	 9,   3,   1,	0,   0,	  0,   0, '0d0'	 , 14),
('& %A Amulet| of Resist Acid^'			   ,  amulet, '"',0,resist_acid_worn_bit,
    0,	  300,	10,   3,   1,	0,   0,	  0,   0, '0d0'	 , 24),
('& %A Amulet| of the Magi^'			   ,  amulet, '"',0,see_invisible_worn_bit+free_action_worn_bit+searching_worn_bit,
    0,	 5000,	13,   3,   1,	0,   0,	  0,   3, '0d0'	 , 50),
('& %A Amulet| of DOOM^'			   ,  amulet, '"',0,
cursed_worn_bit+strength_worn_bit+dexterity_worn_bit+constitution_worn_bit+
intelligence_worn_bit+wisdom_worn_bit+charisma_worn_bit+searching_worn_bit,
   -5,	    0,	14,   3,   1,	0,   0,	  0,   0, '0d0'	 , 50),
('& Scroll~ %T| of Enchant Weapon To-Hit'	   ,  scroll1, '?',%X'00000000',%X'00000001',
    0,	  125, 257,   5,   1,	0,   0,	  0,   0, '0d0'	 , 12),
('& Scroll~ %T| of Enchant Weapon To-Dam'	   ,  scroll1, '?',%X'00000000',%X'00000002',
    0,	  125, 258,   5,   1,	0,   0,	  0,   0, '0d0'	 , 12),
('& Scroll~ %T| of Enchant Armor'		   ,  scroll1, '?',%X'00000000',%X'00000004',
    0,	  125, 259,   5,   1,	0,   0,	  0,   0, '0d0'	 , 12),
('& Scroll~ %T| of Identify'			   ,  scroll1, '?',%X'00000000',%X'00000008',
    0,	   50, 260,   5,   1,	0,   0,	  0,   0, '0d0'	 ,  1),
('& Scroll~ %T| of Identify'			   ,  scroll1, '?',%X'00000000',%X'00000008',
    0,	   50, 260,   5,   1,	0,   0,	  0,   0, '0d0'	 ,  5),
('& Scroll~ %T| of Identify'			   ,  scroll1, '?',%X'00000000',%X'00000008',
    0,	   50, 260,   5,   1,	0,   0,	  0,   0, '0d0'	 , 10),
('& Scroll~ %T| of Remove Curse'		   ,  scroll1, '?',%X'00000000',%X'00000010',
    0,	  100, 261,   5,   1,	0,   0,	  0,   0, '0d0'	 ,  7),
('& Scroll~ %T| of Light'			   ,  scroll1, '?',%X'00000000',%X'00000020',
    0,	   15, 262,   5,   1,	0,   0,	  0,   0, '0d0'	 ,  0),
('& Scroll~ %T| of Light'			   ,  scroll1, '?',%X'00000000',%X'00000020',
    0,	   15, 262,   5,   1,	0,   0,	  0,   0, '0d0'	 ,  3),
('& Scroll~ %T| of Light'			   ,  scroll1, '?',%X'00000000',%X'00000020',
    0,	   15, 262,   5,   1,	0,   0,	  0,   0, '0d0'	 ,  7),
('& Scroll~ %T| of Summon Monster'		   ,  scroll1, '?',%X'00000000',%X'00000040',
    0,	    0, 263,   5,   1,	0,   0,	  0,   0, '0d0'	 ,  1),
('& Scroll~ %T| of Phase Door'			   ,  scroll1, '?',%X'00000000',%X'00000080',
    0,	   15, 264,   5,   1,	0,   0,	  0,   0, '0d0'	 ,  1),
('& Scroll~ %T| of Teleport'			   ,  scroll1, '?',%X'00000000',%X'00000100',
    0,	   40, 265,   5,   1,	0,   0,	  0,   0, '0d0'	 , 10),
('& Scroll~ %T| of Teleport Level'		   ,  scroll1, '?',%X'00000000',%X'00000200',
    0,	   50, 266,   5,   1,	0,   0,	  0,   0, '0d0'	 , 20),
('& Scroll~ %T| of Monster Confusion'		   ,  scroll1, '?',%X'00000000',%X'00000400',
    0,	   30, 267,   5,   1,	0,   0,	  0,   0, '0d0'	 ,  5),
('& Scroll~ %T| of Magic Mapping'		   ,  scroll1, '?',%X'00000000',%X'00000800',
    0,	   40, 268,   5,   1,	0,   0,	  0,   0, '0d0'	 ,  5),
('& Scroll~ %T| of Sleep Monster'		   ,  scroll1, '?',%X'00000000',%X'00001000',
    0,	   35, 269,   5,   1,	0,   0,	  0,   0, '0d0'	 ,  5),
('& Scroll~ %T| of Rune of Protection'		   ,  scroll1, '?',%X'00000000',%X'00002000',
    0,	  500, 270,   5,   1,	0,   0,	  0,   0, '0d0'	 , 50),
('& Scroll~ %T| of Treasure Detection'		   ,  scroll1, '?',%X'00000000',%X'00004000',
    0,	   15, 271,   5,   1,	0,   0,	  0,   0, '0d0'	 ,  0),
('& Scroll~ %T| of Object Detection'		   ,  scroll1, '?',%X'00000000',%X'00008000',
    0,	   15, 272,   5,   1,	0,   0,	  0,   0, '0d0'	 ,  0),
('& Scroll~ %T| of Trap Detection'		   ,  scroll1, '?',%X'00000000',%X'00010000',
    0,	   35, 273,   5,   1,	0,   0,	  0,   0, '0d0'	 ,  5),
('& Scroll~ %T| of Trap Detection'		   ,  scroll1, '?',%X'00000000',%X'00010000',
    0,	   35, 273,   5,   1,	0,   0,	  0,   0, '0d0'	 ,  8),
('& Scroll~ %T| of Trap Detection'		   ,  scroll1, '?',%X'00000000',%X'00010000',
    0,	   35, 273,   5,   1,	0,   0,	  0,   0, '0d0'	 , 12),
('& Scroll~ %T| of Door/Stair Location'		   ,  scroll1, '?',%X'00000000',%X'00020000',
    0,	   35, 274,   5,   1,	0,   0,	  0,   0, '0d0'	 ,  5),
('& Scroll~ %T| of Door/Stair Location'		   ,  scroll1, '?',%X'00000000',%X'00020000',
    0,	   35, 274,   5,   1,	0,   0,	  0,   0, '0d0'	 , 10),
('& Scroll~ %T| of Door/Stair Location'		   ,  scroll1, '?',%X'00000000',%X'00020000',
    0,	   35, 274,   5,   1,	0,   0,	  0,   0, '0d0'	 , 15),
('& Scroll~ %T| of Mass Genocide'		   ,  scroll1, '?',%X'00000000',%X'00040000',
    0,	 1000, 275,   5,   1,	0,   0,	  0,   0, '0d0'	 , 50),
('& Scroll~ %T| of Detect Invisible'		   ,  scroll1, '?',%X'00000000',%X'00080000',
    0,	   15, 276,   5,   1,	0,   0,	  0,   0, '0d0'	 ,  1),
('& Scroll~ %T| of Aggravate Monster'		   ,  scroll1, '?',%X'00000000',%X'00100000',
    0,	    0, 277,   5,   1,	0,   0,	  0,   0, '0d0'	 ,  5),
('& Scroll~ %T| of Trap Creation'		   ,  scroll1, '?',%X'00000000',%X'00200000',
    0,	    0, 278,   5,   1,	0,   0,	  0,   0, '0d0'	 , 12),
('& Scroll~ %T| of Trap/Door Destruction'	   ,  scroll1, '?',%X'00000000',%X'00400000',
    0,	   50, 279,   5,   1,	0,   0,	  0,   0, '0d0'	 , 12),
('& Scroll~ %T| of Door Creation'		   ,  scroll1, '?',%X'00000000',%X'00800000',
    0,	  100, 280,   5,   1,	0,   0,	  0,   0, '0d0'	 , 12),
('& Scroll~ %T| of Recharging'			   ,  scroll1, '?',%X'00000000',%X'01000000',
    0,	  200, 281,   5,   1,	0,   0,	  0,   0, '0d0'	 , 40),
('& Scroll~ %T| of Genocide'			   ,  scroll1, '?',%X'00000000',%X'02000000',
    0,	  750, 282,   5,   1,	0,   0,	  0,   0, '0d0'	 , 35),
('& Scroll~ %T| of Darkness'			   ,  scroll1, '?',%X'00000000',%X'04000000',
    0,	    0, 283,   5,   1,	0,   0,	  0,   0, '0d0'	 ,  1),
('& Scroll~ %T| of Protection from Evil'	   ,  scroll1, '?',%X'00000000',%X'08000000',
    0,	   50, 284,   5,   1,	0,   0,	  0,   0, '0d0'	 , 30),
('& Scroll~ %T| of Create Food'			   ,  scroll1, '?',%X'00000000',%X'10000000',
    0,	   15, 285,   5,   1,	0,   0,	  0,   0, '0d0'	 , 10),
('& Scroll~ %T| of Dispell Undead'		   ,  scroll1, '?',%X'00000000',%X'20000000',
    0,	  200, 286,   5,   1,	0,   0,	  0,   0, '0d0'	 , 40),
('& Scroll~ %T| of *Enchant Weapon*'		   ,  scroll2, '?',%X'00000000',%X'00000001',
    0,	  500, 257,   5,   1,	0,   0,	  0,   0, '0d0'	 , 50),
('& Scroll~ %T| of Curse Weapon'		   ,  scroll2, '?',%X'00000000',%X'00000002',
    0,	    0, 258,   5,   1,	0,   0,	  0,   0, '0d0'	 , 50),
('& Scroll~ %T| of *Enchant Armor*'		   ,  scroll2, '?',%X'00000000',%X'00000004',
    0,	  500, 259,   5,   1,	0,   0,	  0,   0, '0d0'	 , 50),
('& Scroll~ %T| of Curse Armor'			   ,  scroll2, '?',%X'00000000',%X'00000008',
    0,	    0, 260,   5,   1,	0,   0,	  0,   0, '0d0'	 , 50),
('& Scroll~ %T| of Summon Undead'		   ,  scroll2, '?',%X'00000000',%X'00000010',
    0,	    0, 261,   5,   1,	0,   0,	  0,   0, '0d0'	 , 15),
('& Scroll~ %T| of Blessing'			   ,  scroll2, '?',%X'00000000',%X'00000020',
    0,	   15, 262,   5,   1,	0,   0,	  0,   0, '0d0'	 ,  1),
('& Scroll~ %T| of Holy Chant'			   ,  scroll2, '?',%X'00000000',%X'00000040',
    0,	   40, 263,   5,   1,	0,   0,	  0,   0, '0d0'	 , 12),
('& Scroll~ %T| of Holy Prayer'			   ,  scroll2, '?',%X'00000000',%X'00000080',
    0,	   80, 264,   5,   1,	0,   0,	  0,   0, '0d0'	 , 24),
('& Scroll~ %T| of Word-of-Recall'		   ,  scroll2, '?',%X'00000000',%X'00000100',
    0,	  150, 265,   5,   1,	0,   0,	  0,   0, '0d0'	 ,  5),
('& Scroll~ %T| of *Destruction*'		   ,  scroll2, '?',%X'00000000',%X'00000200',
    0,	  250, 266,   5,   1,	0,   0,	  0,   0, '0d0'	 , 40),
('& Scroll~ %T| of Wishing'			   ,  scroll2, '?',%X'00000000',%X'00000400',
    0,	15000, 267,   5,   1,	0,   0,	  0,   0, '0d0',   50),
('& Scroll~ %T| of Feign Death'			   ,  scroll2, '?',%X'00000000',%X'00000800',
    0,	    0, 268,   5,   1,   0,   0,   0,   0, '0d0',   10),
('& Scroll~ %T| of Make Munchies'		   ,  scroll2, '?',%X'00000000'
,%X'00001000',
    0,    150, 269,   5,   1,   0,   0,   0,   0, '0d0',   25),
('& %C Potion~| of Gain Strength'		   ,  potion1, '!',%X'00000000',%X'00000001',
    0,	 6500, 257,   4,   1,	0,   0,	  0,   0, '1d1'	 , 25),
('& %C Potion~| of Poison'			   ,  potion1, '!',%X'00000000',%X'00000002',
    0,	    0, 258,   4,   1,	0,   0,	  0,   0, '1d1'	 ,  3),
('& %C Potion~| of Restore Strength'		   ,  potion1, '!',%X'00000000',%X'00000004',
    0,	  300, 259,   4,   1,	0,   0,	  0,   0, '1d1'	 , 40),
('& %C Potion~| of Gain Intelligence'		   ,  potion1, '!',%X'00000000',%X'00000008',
    0,	 6500, 260,   4,   1,	0,   0,	  0,   0, '1d1'	 , 25),
('& %C Potion~| of Lose Intelligence'		   ,  potion1, '!',%X'00000000',%X'00000010',
    0,	    0, 261,   4,   1,	0,   0,	  0,   0, '1d1'	 , 25),
('& %C Potion~| of Restore Intelligence'	   ,  potion1, '!',%X'00000000',%X'00000020',
    0,	  300, 262,   4,   1,	0,   0,	  0,   0, '1d1'	 , 40),
('& %C Potion~| of Gain Wisdom'			   ,  potion1, '!',%X'00000000',%X'00000040',
    0,	 6500, 263,   4,   1,	0,   0,	  0,   0, '1d1'	 , 25),
('& %C Potion~| of Lose Wisdom'			   ,  potion1, '!',%X'00000000',%X'00000080',
    0,	    0, 264,   4,   1,	0,   0,	  0,   0, '1d1'	 , 25),
('& %C Potion~| of Restore Wisdom'		   ,  potion1, '!',%X'00000000',%X'00000100',
    0,	  300, 265,   4,   1,	0,   0,	  0,   0, '1d1'	 , 40),
('& %C Potion~| of Charisma'			   ,  potion1, '!',%X'00000000',%X'00000200',
    0,	 6500, 266,   4,   1,	0,   0,	  0,   0, '1d1'	 , 25),
('& %C Potion~| of Ugliness'			   ,  potion1, '!',%X'00000000',%X'00000400',
    0,	    0, 267,   4,   1,	0,   0,	  0,   0, '1d1'	 , 25),
('& %C Potion~| of Restore Charisma'		   ,  potion1, '!',%X'00000000',%X'00000800',
    0,	  300, 268,   4,   1,	0,   0,	  0,   0, '1d1'	 , 40),
('& %C Potion~| of Cure Light Wounds'		   ,  potion1, '!',%X'00000000',%X'10001000',
   50,	   15, 269,   4,   1,	0,   0,	  0,   0, '1d1'	 ,  0),
('& %C Potion~| of Cure Light Wounds'		   ,  potion1, '!',%X'00000000',%X'10001000',
   50,	   15, 269,   4,   1,	0,   0,	  0,   0, '1d1'	 ,  1),
('& %C Potion~| of Cure Light Wounds'		   ,  potion1, '!',%X'00000000',%X'10001000',
   50,	   15, 269,   4,   1,	0,   0,	  0,   0, '1d1'	 ,  2),
('& %C Potion~| of Cure Serious Wounds'		   ,  potion1, '!',%X'00000000',%X'30002000',
  100,	   40, 270,   4,   1,	0,   0,	  0,   0, '1d1'	 ,  3),
('& %C Potion~| of Cure Critical Wounds'	   ,  potion1, '!',%X'00000000',%X'70004000',
  100,	  100, 271,   4,   1,	0,   0,	  0,   0, '1d1'	 ,  5),
('& %C Potion~| of Healing'			   ,  potion1, '!',%X'00000000',%X'70008000',
  200,	 2500, 272,   4,   1,	0,   0,	  0,   0, '1d1'	 , 12),
('& %C Potion~| of Gain Constitution'		   ,  potion1, '!',%X'00000000',%X'00010000',
    0,	 6500, 273,   4,   1,	0,   0,	  0,   0, '1d1'	 , 25),
('& %C Potion~| of Gain Experience'		   ,  potion1, '!',%X'00000000',%X'00020000',
    0,	15000, 274,   4,   1,	0,   0,	  0,   0, '1d1'	 , 50),
('& %C Potion~| of Sleep'			   ,  potion1, '!',%X'00000000',%X'10040000',
  100,	    0, 275,   4,   1,	0,   0,	  0,   0, '1d1'	 ,  0),
('& %C Potion~| of Blindness'			   ,  potion1, '!',%X'00000000',%X'00080000',
    0,	    0, 276,   4,   1,	0,   0,	  0,   0, '1d1'	 ,  0),
('& %C Potion~| of Confusion'			   ,  potion1, '!',%X'00000000',%X'00100000',
   50,	    0, 277,   4,   1,	0,   0,	  0,   0, '1d1'	 ,  0),
('& %C Potion~| of Poison'			   ,  potion1, '!',%X'00000000',%X'00200000',
    0,	    0, 278,   4,   1,	0,   0,	  0,   0, '1d1'	 ,  3),
('& %C Potion~| of Haste Self'			   ,  potion1, '!',%X'00000000',%X'00400000',
    0,	  155, 279,   4,   1,	0,   0,	  0,   0, '1d1'	 ,  1),
('& %C Potion~| of Slowness'			   ,  potion1, '!',%X'00000000',%X'00800000',
   50,	    0, 280,   4,   1,	0,   0,	  0,   0, '1d1'	 ,  1),
('& Icky Green Potion~| of Slime Mold Juice'	   ,  potion1, '!',%X'00000000',%X'30000000',
  400,	    2, 281,   4,   1,	0,   0,	  0,   0, '1d1'	 ,  0),
('& Light Brown Potion~| of Apple Juice'	   ,  potion1, '!',%X'00000000',Nothing_flag,
  250,	    1, 282,   4,   1,	0,   0,	  0,   0, '1d1'	 ,  0),
('& Clear Potion~| of Water'			   ,  potion1, '!',%X'00000000',Nothing_flag,
  200,	    0, 283,   4,   1,	0,   0,	  0,   0, '1d1'	 ,  0),
('& %C Potion~| of Gain Dexterity'		   ,  potion1, '!',%X'00000000',%X'02000000',
    0,	 6500, 284,   4,   1,	0,   0,	  0,   0, '1d1'	 , 25),
('& %C Potion~| of Restore Dexterity'		   ,  potion1, '!',%X'00000000',%X'04000000',
    0,	  300, 285,   4,   1,	0,   0,	  0,   0, '1d1'	 , 40),
('& %C Potion~| of Restore Constitution'	   ,  potion1, '!',%X'00000000',%X'68000000',
    0,	  300, 286,   4,   1,	0,   0,	  0,   0, '1d1'	 , 40),
('& %C Potion~| of Learning'			   ,  potion2, '!',%X'00000000',%X'00000001',
    0,	  200, 287,   4,   1,	0,   0,	  0,   0, '1d1'	 , 45),
('& %C Potion~| of Lose Memories'		   ,  potion2, '!',%X'00000000',%X'00000002',
    0,	    0, 288,   4,   1,	0,   0,	  0,   0, '1d1'	 , 10),
('& %C Potion~| of Salt Water'			   ,  potion2, '!',%X'00000000',%X'00000004',
    0,	    0, 289,   4,   1,	0,   0,	  0,   0, '1d1'	 ,  0),
('& %C Potion~| of Invulnerability'		   ,  potion2, '!',%X'00000000',%X'00000008',
    0,	12500, 290,   4,   1,	0,   0,	  0,   0, '1d1'	 , 40),
('& %C Potion~| of Heroism'			   ,  potion2, '!',%X'00000000',%X'00000010',
    0,	   35, 291,   4,   1,	0,   0,	  0,   0, '1d1'	 ,  1),
('& %C Potion~| of Super Heroism'		   ,  potion2, '!',%X'00000000',%X'00000020',
    0,	  100, 292,   4,   1,	0,   0,	  0,   0, '1d1'	 ,  3),
('& %C Potion~| of Boldliness'			   ,  potion2, '!',%X'00000000',%X'00000040',
    0,	   10, 293,   4,   1,	0,   0,	  0,   0, '1d1'	 ,  1),
('& %C Potion~| of Restore Life Levels'		   ,  potion2, '!',%X'00000000',%X'00000080',
    0,	  400, 294,   4,   1,	0,   0,	  0,   0, '1d1'	 , 40),
('& %C Potion~| of Resist Heat'			   ,  potion2, '!',%X'00000000',%X'00000100',
    0,	   30, 295,   4,   1,	0,   0,	  0,   0, '1d1'	 ,  1),
('& %C Potion~| of Resist Cold'			   ,  potion2, '!',%X'00000000',%X'00000200',
    0,	   30, 296,   4,   1,	0,   0,	  0,   0, '1d1'	 ,  1),
('& %C Potion~| of Detect Invisible'		   ,  potion2, '!',%X'00000000',%X'00000400',
    0,	   50, 297,   4,   1,	0,   0,	  0,   0, '1d1'	 ,  3),
('& %C Potion~| of Slow Poison'			   ,  potion2, '!',%X'00000000',%X'00000800',
    0,	   25, 298,   4,   1,	0,   0,	  0,   0, '1d1'	 ,  1),
('& %C Potion~| of Neutralize Poison'		   ,  potion2, '!',%X'00000000',%X'00001000',
    0,	   75, 299,   4,   1,	0,   0,	  0,   0, '1d1'	 ,  5),
('& %C Potion~| of Restore Mana'		   ,  potion2, '!',%X'00000000',%X'00002000',
    0,	 3000, 300,   4,   1,	0,   0,	  0,   0, '1d1'	 , 25),
('& %C Potion~| Infra-Vision'			   ,  potion2, '!',%X'00000000',%X'00004000',
    0,	   20, 301,   4,   1,	0,   0,	  0,   0, '1d1'	 ,  3),
('& Flask~ of oil'				   ,  flask_of_oil, '!',%X'00000000',%X'00040000',
 7500,	    3, 257,  10,   1,	0,   0,	  0,   0, '2d6'	 ,  1),
('& %M Wand| of Probing^ (%P1 charges)'            ,  wand, '-',%X'00000000',%X'01000000',
    0,   1500,  25,  10,   1,   0,   0,   0,   0, '1d1'  , 30),
('& %M Wand| of Light^ (%P1 charges)'		   ,  wand, '-',%X'00000000',%X'00000001',
    0,	  200,	 1,  10,   1,	0,   0,	  0,   0, '1d1'	 ,  2),
('& %M Wand| of Lightning Bolts^ (%P1 charges)'	   ,  wand, '-',%X'00000000',%X'00000002',
    0,	  600,	 2,  10,   1,	0,   0,	  0,   0, '1d1'	 , 15),
('& %M Wand| of Frost Bolts^ (%P1 charges)'	   ,  wand, '-',%X'00000000',%X'00000004',
    0,	  800,	 3,  10,   1,	0,   0,	  0,   0, '1d1'	 , 20),
('& %M Wand| of Fire Bolts^ (%P1 charges)'	   ,  wand, '-',%X'00000000',%X'00000008',
    0,	 1000,	 4,  10,   1,	0,   0,	  0,   0, '1d1'	 , 30),
('& %M Wand| of Stone-to-Mud^ (%P1 charges)'	   ,  wand, '-',%X'00000000',%X'00000010',
    0,	  300,	 5,  10,   1,	0,   0,	  0,   0, '1d1'	 , 12),
('& %M Wand| of Polymorph^ (%P1 charges)'	   ,  wand, '-',%X'00000000',%X'00000020',
    0,	  400,	 6,  10,   1,	0,   0,	  0,   0, '1d1'	 , 20),
('& %M Wand| of Heal Monster^ (%P1 charges)'	   ,  wand, '-',%X'00000000',%X'00000040',
    0,	    0,	 7,  10,   1,	0,   0,	  0,   0, '1d1'	 ,  2),
('& %M Wand| of Haste Monster^ (%P1 charges)'	   ,  wand, '-',%X'00000000',%X'00000080',
    0,	    0,	 8,  10,   1,	0,   0,	  0,   0, '1d1'	 ,  2),
('& %M Wand| of Slow Monster^ (%P1 charges)'	   ,  wand, '-',%X'00000000',%X'00000100',
    0,	  500,	 9,  10,   1,	0,   0,	  0,   0, '1d1'	 ,  2),
('& %M Wand| of Confuse Monster^ (%P1 charges)'	   ,  wand, '-',%X'00000000',%X'00000200',
    0,	  400,	10,  10,   1,	0,   0,	  0,   0, '1d1'	 ,  2),
('& %M Wand| of Sleep Monster^ (%P1 charges)'	   ,  wand, '-',%X'00000000',%X'00000400',
    0,	  500,	11,  10,   1,	0,   0,	  0,   0, '1d1'	 ,  7),
('& %M Wand| of Drain Life^ (%P1 charges)'	   ,  wand, '-',%X'00000000',%X'00000800',
    0,	 2500,	12,  10,   1,	0,   0,	  0,   0, '1d1'	 , 50),
('& %M Wand| of Trap/Door destruction^ (%P1 charges)',65, '-',%X'00000000',%X'00001000',
    0,	  100,	13,  10,   1,	0,   0,	  0,   0, '1d1'	 , 12),
('& %M Wand| of Magic Missile^ (%P1 charges)'	   ,  wand, '-',%X'00000000',%X'00002000',
    0,	  200,	14,  10,   1,	0,   0,	  0,   0, '1d1'	 ,  2),
('& %M Wand| of Wall Building^ (%P1 charges)'	   ,  wand, '-',%X'00000000',%X'00004000',
    0,	 1400,	15,  10,   1,	0,   0,	  0,   0, '1d1'	 , 25),
('& %M Wand| of Clone Monster^ (%P1 charges)'	   ,  wand, '-',%X'00000000',%X'00008000',
    0,	    0,	16,  10,   1,	0,   0,	  0,   0, '1d1'	 ,  2),
('& %M Wand| of Teleport Away^ (%P1 charges)'	   ,  wand, '-',%X'00000000',%X'00010000',
    0,	  350,	17,  10,   1,	0,   0,	  0,   0, '1d1'	 , 20),
('& %M Wand| of Disarming^ (%P1 charges)'	   ,  wand, '-',%X'00000000',%X'00020000',
    0,	  700,	18,  10,   1,	0,   0,	  0,   0, '1d1'	 , 20),
('& %M Wand| of Lightning Balls^ (%P1 charges)'	   ,  wand, '-',%X'00000000',%X'00040000',
    0,	 1200,	19,  10,   1,	0,   0,	  0,   0, '1d1'	 , 35),
('& %M Wand| of Cold Balls^ (%P1 charges)'	   ,  wand, '-',%X'00000000',%X'00080000',
    0,	 1500,	20,  10,   1,	0,   0,	  0,   0, '1d1'	 , 40),
('& %M Wand| of Fire Balls^ (%P1 charges)'	   ,  wand, '-',%X'00000000',%X'00100000',
    0,	 1800,	21,  10,   1,	0,   0,	  0,   0, '1d1'	 , 50),
('& %M Wand| of Stinking Cloud^ (%P1 charges)'	   ,  wand, '-',%X'00000000',%X'00200000',
    0,	  400,	22,  10,   1,	0,   0,	  0,   0, '1d1'	 ,  5),
('& %M Wand| of Acid Balls^ (%P1 charges)'	   ,  wand, '-',%X'00000000',%X'00400000',
    0,	 2650,	23,  10,   1,	0,   0,	  0,   0, '1d1'	 , 48),
('& %M Wand| of Wonder^ (%P1 charges)'		   ,  wand, '-',%X'00000000',%X'00800000',
    0,	  250,	24,  10,   1,	0,   0,	  0,   0, '1d1'	 ,  2),
('& %W Staff| of Light^ (%P1 charges)'		   ,  staff, '_',%X'00000000',%X'00000001',
    0,	  250,	 1,  50,   1,	0,   0,	  0,   0, '1d2'	 ,  5),
('& %W Staff| of Door/Stair Location^ (%P1 charges)',  staff, '_',%X'00000000',%X'00000002',
    0,	  350,	 2,  50,   1,	0,   0,	  0,   0, '1d2'	 , 10),
('& %W Staff| of Trap Location^ (%P1 charges)'	   ,  staff, '_',%X'00000000',%X'00000004',
    0,	  350,	 3,  50,   1,	0,   0,	  0,   0, '1d2'	 , 10),
('& %W Staff| of Treasure Location^ (%P1 charges)' ,  staff, '_',%X'00000000',%X'00000008',
    0,	  200,	 4,  50,   1,	0,   0,	  0,   0, '1d2'	 ,  5),
('& %W Staff| of Object Location^ (%P1 charges)'   ,  staff, '_',%X'00000000',%X'00000010',
    0,	  200,	 5,  50,   1,	0,   0,	  0,   0, '1d2'	 ,  5),
('& %W Staff| of Teleportation^ (%P1 charges)'	   ,  staff, '_',%X'00000000',%X'00000020',
    0,	  400,	 6,  50,   1,	0,   0,	  0,   0, '1d2'	 , 20),
('& %W Staff| of Earthquakes^ (%P1 charges)'	   ,  staff, '_',%X'00000000',%X'00000040',
    0,	  350,	 7,  50,   1,	0,   0,	  0,   0, '1d2'	 , 40),
('& %W Staff| of Summoning^ (%P1 charges)'	   ,  staff, '_',%X'00000000',%X'00000080',
    0,	    0,	 8,  50,   1,	0,   0,	  0,   0, '1d2'	 , 10),
('& %W Staff| of Summoning^ (%P1 charges)'	   ,  staff, '_',%X'00000000',%X'00000080',
    0,	    0,	 8,  50,   1,	0,   0,	  0,   0, '1d2'	 , 50),
('& %W Staff| of *Destruction*^ (%P1 charges)'	   ,  staff, '_',%X'00000000',%X'00000200',
    0,	 2500,	10,  50,   1,	0,   0,	  0,   0, '1d2'	 , 50),
('& %W Staff| of Starlite^ (%P1 charges)'	   ,  staff, '_',%X'00000000',%X'00000400',
    0,	  800,	11,  50,   1,	0,   0,	  0,   0, '1d2'	 , 20),
('& %W Staff| of Haste Monsters^ (%P1 charges)'	   ,  staff, '_',%X'00000000',%X'00000800',
    0,	    0,	12,  50,   1,	0,   0,	  0,   0, '1d2'	 , 10),
('& %W Staff| of Slow Monsters^ (%P1 charges)'	   ,  staff, '_',%X'00000000',%X'00001000',
    0,	  800,	13,  50,   1,	0,   0,	  0,   0, '1d2'	 , 10),
('& %W Staff| of Sleep Monsters^ (%P1 charges)'	   ,  staff, '_',%X'00000000',%X'00002000',
    0,	  700,	14,  50,   1,	0,   0,	  0,   0, '1d2'	 , 10),
('& %W Staff| of Cure Light Wounds^ (%P1 charges)' ,  staff, '_',%X'00000000',%X'00004000',
    0,	  350,	15,  50,   1,	0,   0,	  0,   0, '1d2'	 ,  5),
('& %W Staff| of Detect Invisible^ (%P1 charges)'  ,  staff, '_',%X'00000000',%X'00008000',
    0,	  200,	16,  50,   1,	0,   0,	  0,   0, '1d2'	 ,  5),
('& %W Staff| of Speed^ (%P1 charges)'		   ,  staff, '_',%X'00000000',%X'00010000',
    0,	  800,	17,  50,   1,	0,   0,	  0,   0, '1d2'	 , 40),
('& %W Staff| of Slowness^ (%P1 charges)'	   ,  staff, '_',%X'00000000',%X'00020000',
    0,	    0,	18,  50,   1,	0,   0,	  0,   0, '1d2'	 , 40),
('& %W Staff| of Mass Polymorph^ (%P1 charges)'	   ,  staff, '_',%X'00000000',%X'00040000',
    0,	 1750,	19,  50,   1,	0,   0,	  0,   0, '1d2'	 , 46),
('& %W Staff| of Remove Curse^ (%P1 charges)'	   ,  staff, '_',%X'00000000',%X'00080000',
    0,	  500,	20,  50,   1,	0,   0,	  0,   0, '1d2'	 , 47),
('& %W Staff| of Detect Evil^ (%P1 charges)'	   ,  staff, '_',%X'00000000',%X'00100000',
    0,	  350,	21,  50,   1,	0,   0,	  0,   0, '1d2'	 , 20),
('& %W Staff| of Curing^ (%P1 charges)'		   ,  staff, '_',%X'00000000',%X'00200000',
    0,	 1000,	22,  50,   1,	0,   0,	  0,   0, '1d2'	 , 25),
('& %W Staff| of Dispell Evil^ (%P1 charges)'	   ,  staff, '_',%X'00000000',%X'00400000',
    0,	 1200,	23,  50,   1,	0,   0,	  0,   0, '1d2'	 , 49),
('& %W Staff| of Darkness^ (%P1 charges)'	   ,  staff, '_',%X'00000000',%X'01000000',
    0,	    0,	25,  50,   1,	0,   0,	  0,   0, '1d2'	 , 50),
('& %W Staff| of Darkness^ (%P1 charges)'	   ,  staff, '_',%X'00000000',%X'01000000',
    0,	    0,	25,  50,   1,	0,   0,	  0,   0, '1d2'	 ,  5),
('& %W Staff| of Identify^ (%P1 charges)'	   ,  staff, '_',%X'00000000',%X'02000000',
    0,	 1500,	26,  50,   1,	0,   0,	  0,   0, '1d2'	 , 20),
('& Book of Magic Spells [Beginners-Magik]'	   ,  Magic_Book, '?',%X'00000000',%X'0000007F',
    0,	   25, 257,  60,   1,-100,   0,	  0,   0, '1d1'	 , 40),
('& Book of Magic Spells [Magik I]'		   ,  Magic_Book, '?',%X'00000000',%X'0007FF80',
    0,	  100, 258,  60,   1,-100,   0,	  0,   0, '1d1'	 , 40),
('& Book of Magic Spells [Magik II]'		   ,  Magic_Book, '?',%X'00000000',%X'7FF80000',
    0,	  400, 259,  60,   1,-100,   0,	  0,   0, '1d1'	 , 40),
('& Book of Magic Spells [The Mages Guide to Power]',  Magic_Book, '?',%X'000001FF',%X'00000000',
    0,	  800, 261,  60,   1,-100,   0,	  0,   0, '1d1'	 , 40),
('& Holy Book of Prayers [Beginners Handbook]'	   ,  Prayer_Book, '?',%X'00000000',%X'000000FF',
    0,	   25, 258,  60,   1,-100,   0,	  0,   0, '1d1'	 , 40),
('& Holy Book of Prayers [Words of Wisdom]'	   ,  Prayer_Book, '?',%X'00000000',%X'0007FF00',
    0,	  100, 259,  60,   1,-100,   0,	  0,   0, '1d1'	 , 40),
('& Holy Book of Prayers [Chants and Blessings]'   ,  Prayer_Book, '?',%X'00000001',%X'7FF80000',
    0,	  300, 260,  60,   1,-100,   0,	  0,   0, '1d1'	 , 40),
('& Holy Book of Prayers [Exorcism and Dispelling]',  Prayer_Book, '?',%X'000001FE',%X'00000000',
    0,	  900, 261,  60,   1,-100,   0,	  0,   0, '1d1'	 , 40),
('& Small wooden chest'				   ,   chest, '&',%X'00000000',%X'0F000000',
    0,	  300,	 1, 250,   1,	0,   0,	  0,   0, '2d3'	 ,  7),
('& Large wooden chest'				   ,   chest, '&',%X'00000000',%X'15000000',
    0,	  320,	 4, 500,   1,	0,   0,	  0,   0, '2d5'	 , 15),
('& Small iron chest'				   ,   chest, '&',%X'00000000',%X'0F000000',
    0,	  420,	 7, 300,   1,	0,   0,	  0,   0, '2d4'	 , 25),
('& Large iron chest'				   ,   chest, '&',%X'00000000',%X'1F000000',
    0,	  520,	10,1000,   1,	0,   0,	  0,   0, '2d6'	 , 35),
('& Small steel chest'				   ,   chest, '&',%X'00000000',%X'0F000000',
    0,	  520,	13, 500,   1,	0,   0,	  0,   0, '2d4'	 , 45),
('& Large steel chest'				   ,   chest, '&',%X'00000000',%X'23000000',
    0,	  620,	16,1000,   1,	0,   0,	  0,   0, '2d6'	 , 50),
('& %N Bag| of Holding (250)'		   , bag_or_sack, '~',%X'04000000',%X'00000000',
 25000,	 1000,	 1, 150,   1,	0,   0,	  0,   0, '0d0'	 , 35),
('& %N Bag| of Holding (500)'		   , bag_or_sack, '~',%X'04000000',%X'00000000',
 50000, 2000,	2,  150,   1,	0,   0,	  0,   0, '0d0'	 , 45),
('& %N Bag| of Holding (1000)'		   , bag_or_sack, '~',%X'04000000',%X'00000000',
 100000, 5000,	 3, 350,   1,	0,   0,	  0,   0, '0d0'	 , 50),
('& %N Bag| of Holding (1500)'		   , bag_or_sack, '~',%X'04000000',%X'00000000',
 150000, 7000,	 3, 600,   1,	0,   0,	  0,   0, '0d0'	 , 50),
('& %N Bag| of Devouring'			   , bag_or_sack, '~',%X'0C000000',%X'00000000',
 150000,    0,	 4, 600,   1,	0,   0,	  0,   0, '0d0'	 , 20),
('& Rat Skeleton'				   ,   Miscellaneous_Object, 's',%X'00000000',Nothing_flag,
    0,	    0,	 1,  10,   1,	0,   0,	  0,   0, '1d1'	 ,  1),
('& Giant Centipede Skeleton'			   ,   Miscellaneous_Object, 's',%X'00000000',Nothing_flag,
    0,	    0,	 2,  25,   1,	0,   0,	  0,   0, '1d1'	 ,  1),
('Some filthy rags^ [%P6,%P4]'			   ,  soft_armor, '~',%X'00000000',Nothing_flag,
    0,	    0,	99,  20,   1,	0,   0,	  1,   0, '0d0'	 ,  0),
('& empty bottle'				   ,   Miscellaneous_Object, '!',%X'00000000',Nothing_flag,
    0,	    0,	 4,   2,   1,	0,   0,	  0,   0, '1d1'	 ,  0),
('Some shards of pottery'			   ,   Miscellaneous_Object, '~',%X'00000000',Nothing_flag,
    0,	    0,	 5,   5,   1,	0,   0,	  0,   0, '1d1'	 ,  0),
('& Human Skeleton'				   ,   Miscellaneous_Object, 's',%X'00000000',Nothing_flag,
    0,	    0,	 7,  50,   1,	0,   0,	  0,   0, '1d1'	 ,  1),
('& Dwarf Skeleton'				   ,   Miscellaneous_Object, 's',%X'00000000',Nothing_flag,
    0,	    0,	 8,  60,   1,	0,   0,	  0,   0, '1d1'	 ,  1),
('& Elf Skeleton'				   ,   Miscellaneous_Object, 's',%X'00000000',Nothing_flag,
    0,	    0,	 9,  40,   1,	0,   0,	  0,   0, '1d1'	 ,  1),
('& Gnome Skeleton'				   ,   Miscellaneous_Object, 's',%X'00000000',Nothing_flag,
    0,	    0,	10,  25,   1,	0,   0,	  0,   0, '1d1'	 ,  1),
('& broken set of teeth'			   ,   Miscellaneous_Object, 's',%X'00000000',Nothing_flag,
    0,	    0,	11,   3,   1,	0,   0,	  0,   0, '1d1'	 ,  0),
('& large broken bone'				   ,   Miscellaneous_Object, 's',%X'00000000',Nothing_flag,
    0,	    0,	12,   2,   1,	0,   0,	  0,   0, '1d1'	 ,  0),
('& dead human body'				   , chest, 'z',%X'00000000',%X'0F000000',
    0,	    0,	 5,  50,   1,	0,   0,	  0,   0, '1d1'	 ,  7),
('& broken stick'				   ,   Miscellaneous_Object, '~',%X'00000000',Nothing_flag,
    0,	    0,	13,   3,   1,	0,   0,	  0,   0, '1d1'	 ,  0),
('& broken set of teeth'			   ,   misc_usable , 's',nothing_flag,Nothing_flag,
    0,	    0,  15,   3,   1,   0,   0,   0,   0, '1d1'  ,  0),
('& %A Statue^'					   ,   misc_usable , '~',%X'00000000',nothing_flag,
    0,	   20,	14,  10,   1,	0,   0,	  0,   0, '1d2'	 ,   5),
('& %A Statue^'					   ,   misc_usable , '~',%X'00000000',nothing_flag,
    0,	   20,	14,  10,   1,	0,   0,	  0,   0, '1d2'	 ,  10),
('& %A Statue^'					      ,	  misc_usable , '~',%X'00000000',nothing_flag,
    0,	   20,	14,  10,   1,	0,   0,	  0,   0, '1d2'	 ,  25),
('& Finely cut %R| of Detect Monsters^ (%P1 charges)'		             , valuable_gems , '*',nothing_flag,%X'00040000',
    0,	  350,   1,   5,   1,	0,   0,	  0,   0, '0d0'	 ,  14),
('& Finely cut %R| of Dispell Evil^ (%P1 charges)'		             , valuable_gems , '*',nothing_flag,%X'00080000',
    0,	  1200,  2,   5,   1,	0,   0,	  0,   0, '0d0'	 ,  49),
('& Finely cut %R| of Darkness^ (%P1 charges)'		             , valuable_gems , '*',nothing_flag,%X'00100000',
    0,	  0,   3,   5,   1,	0,   0,	  0,   0, '0d0'	 ,  7),
('& Finely cut %R| of Acid Balls^ (%P1 charges)'		             , valuable_gems , '*',nothing_flag,%X'00200000',
    0,	  1800,   4,   5,   1,	0,   0,	  0,   0, '0d0'	 ,  50),
('& Finely cut %R| of Detect Invisible^ (%P1 charges)'		             , valuable_gems , '*',nothing_flag,%X'00400000',
    0,	  225,   5,   5,   1,	0,   0,	  0,   0, '0d0'	 ,  47),
('& Finely cut %R| of Identify^ (%P1 charges)'		             , valuable_gems , '*',nothing_flag,%X'00800000',
    0,	  400,   6,   5,   1,	0,   0,	  0,   0, '0d0'	 ,  40),
('& Finely cut %R| of Light^ (%P1 charges)'		             , valuable_gems , '*',nothing_flag,%X'01000000',
    0,	  300,   7,   5,   1,	0,   0,	  0,   0, '0d0'	 ,  2),
('& Finely cut %R| of Summoning^ (%P1 charges)'		             , valuable_gems , '*',nothing_flag,%X'02000000',
    0,	  0,   8,   5,   1,	0,   0,	  0,   0, '0d0'	 ,  3),
('& Finely cut %R| of Remove Curse^ (%P1 charges)'		             , valuable_gems , '*',nothing_flag,%X'04000000',
    0,	 700,   9,   5,   1,	0,   0,	  0,   0, '0d0'	 ,  25),
('& Finely cut %R| of Annihilation^ (%P1 charges)'		             , valuable_gems , '*',nothing_flag,%X'08000000',
    0,	1000,   10,   5,   1,	0,   0,	  0,   0, '0d0'	 ,  40),
('& Finely cut %R| of Recall^ (%P1 charges)'		             , valuable_gems , '*',nothing_flag,%X'10000000',
    0,  1200,   11,   5,   1,	0,   0,	  0,   0, '0d0'	 ,  22),
('& Finely cut Agate~', 5, '*',%X'00000000',%X'00000000',
    0,     50, 257,   5,   1,   0,   0,   0,   0, '0d0',    5),    
('& Finely cut Diamond~', 5, '*',%X'00000000',%X'00000000',
    0,     500, 258,   5,   1,   0,   0,   0,   0, '0d0',    35), 
('& Rough cut Diamond~', 5, '*',%X'00000000',%X'00000000',
    0,     100, 259,   5,   1,   0,   0,   0,   0, '0d0',    15),
('& Rough cut Sapphire~', 5, '*',%X'00000000',%X'00000000',
    0,     40, 260,   5,   1,   0,   0,   0,   0, '0d0',    7), 
('& Finely cut Sapphire~', 5, '*',%X'00000000',%X'00000000',
    0,     250, 261,   5,   1,   0,   0,   0,   0, '0d0',    12),
('& Small bag~ of Opals', 5, '*',%X'00000000',%X'00000000',
    0,     250, 262,   5,   1,   0,   0,   0,   0, '0d0',    10),
('& Small bag~ of Sapphires', 5, '*',%X'00000000',%X'00000000',
    0,     450, 263,   5,   1,   0,   0,   0,   0, '0d0',    15),
('& Small pouch~ of Diamonds', 5, '*',%X'00000000',%X'00000000',
    0,     1000, 264,   5,   1,   0,   0,   0,   0, '0d0',    45), 
('& Large sack~ of Pearls', 5, '*',%X'00000000',%X'00000000',
    0,     650, 265,   35,   1,   0,   0,   0,   0, '0d0',    25), 
('& Large sack~ of Sapphires', 5, '*',%X'00000000',%X'00000000',
    0,     600, 266,   5,   1,   0,   0,   0,   0, '0d0',    30), 
('& Large pouch~ of Diamonds', 5, '*',%X'00000000',%X'00000000',
    0,     2000, 267,   5,   1,   0,   0,   0,   0, '0d0',    65), 
('& Finely wrought silver necklace~', amulet, '*',%X'00000000',%X'00000000',
    0,     50, 268,   5,   1,   0,   0,   0,   0, '0d0',    1), 
('& Finely wrought gold necklace~', amulet, '*',%X'00000000',%X'00000000',
    0,     100, 269,   5,   1,   0,   0,   0,   0, '0d0',    7), 
('& Finely wrought mithril necklace~', amulet, '*',%X'00000000',%X'00000000',
    0,     400, 270,   5,   1,   0,   0,   0,   0, '0d0',    9), 
('& Small silver Bracelet~', bracers, '*',%X'00000000',%X'00000000',
    0,     25, 271,   5,   1,   0,   0,   0,   0, '0d0',    2), 
('& Small gold Bracelet~', bracers, '*',%X'00000000',%X'00000000',
    0,     50, 272,   5,   1,   0,   0,   0,   0, '0d0',    5), 
('& Small platinum bracelet~', bracers, '*',%X'00000000',%X'00000000',
    0,     100, 273,   5,   1,   0,   0,   0,   0, '0d0',    8), 
('& Small gold pendant~', 5, '*',%X'00000000',%X'00000000',
    0,     75, 274,   5,   1,   0,   0,   0,   0, '0d0',    5), 
('& Small mithril pendant~', 5, '*',%X'00000000',%X'00000000',
    0,     350, 275,   5,   1,   0,   0,   0,   0, '0d0',    10), 
('& Large mithril garter-belt~', 5, '*',%X'00000000',%X'00000000',
    0,     1500, 276,   5,   1,   0,   0,   0,   0, '0d0',    45), 
('& Silver Cross^'				   ,   misc_usable , '~',%X'00000000',%X'00000000',
    0,	  250,	16,   3,   1,	0,   0,	  0,   0, '1d1'	 ,  15),
('& Gold Cross^'				   ,   misc_usable , '~',%X'00000000',%X'00000000',
    0,	  500,	17,   5,   1,	0,   0,	  0,   0, '1d1'	 ,  25),
('& Mithril Cross^'				   ,   misc_usable , '~',%X'00000000',%X'00000000',
    0,	 750,	18,  10,   1,	0,   0,	  0,   0, '1d1'	 ,  45),
('& %M Cross^'				   ,   misc_usable , '~',%X'00000000',%X'00000000',
    0,	  20,	19,   5,   1,	0,   0,	  0,   0, '1d1'	 ,  20),
('& %M Cross^'				   ,   misc_usable , '~',%X'00000000',%X'00000000',
    0,	  20,	20,   5,   1,	0,   0,	  0,   0, '1d1'	 ,  35),
('& Corked Bottle^'				   ,   misc_usable , '!',%X'00000000',%X'00000000',
    0,	   0,	21,   1,   1,	0,   0,	  0,   0, '1d1'	 ,  10),
('& Holy Hand Grenade of Antioch'		   ,   misc_usable , '~',%X'00000000',%X'00020000',
    1,	  350,	24,  25,   1,  99,   0,	  0,   0, '1d1'	 ,  25),
('& %M Chime| of Light^ (%P1 charges)'		   ,  85, '%',%X'00000000',%X'00000001',
    0,	  275,	 1,   1,   1,	0,   0,	  0,   0, '0d0'	 , 10),
('& %M Chime| of Detect Doors/Stairs^ (%P1 charges)', 85, '%',%X'00000000',%X'00000002',
    0,	  375,	 2,   1,   1,	0,   0,	  0,   0, '0d0'	 , 15),
('& %M Chime| of Detect Traps^ (%P1 charges)'	   ,  85, '%',%X'00000000',%X'00000004',
    0,	  375,	 3,   1,   1,	0,   0,	  0,   0, '0d0'	 , 15),
('& %M Chime| of Teleportation^ (%P1 charges)'	   ,  85, '%',%X'00000000',%X'00000008',
    0,	  450,	 4,   1,   1,	0,   0,	  0,   0, '0d0'	 , 23),
('& %M Chime| of Thunderblasts^ (%P1 charges)'	   ,  85, '%',%X'00000000',%X'00000010',
    0,	  400,	 5,   1,   1,	0,   0,	  0,   0, '0d0'	 , 42),
('& %M Chime| of Summon Monster^ (%P1 charges)'	   ,  85, '%',%X'00000000',%X'00000020',
    0,	    0,	 6,   1,   1,	0,   0,	  0,   0, '0d0'	 , 10),
('& %M Chime| of Disarming^ (%P1 charges)'	   ,  85, '%',%X'00000000',%X'00000040',
    0,	  400,	 7,   1,   1,	0,   0,	  0,   0, '0d0'	 , 30),
('& %M Chime| of Aggravation^ (%P1 charges)'	   ,  85, '%',%X'00000000',%X'00000080',
    0,	    0,	 8,   1,   1,	0,   0,	  0,   0, '0d0'	 , 15),
('& %M Chime| of Slow Monster^ (%P1 charges)'	   ,  85, '%',%X'00000000',%X'00000100',
    0,	  850,	 9,   1,   1,	0,   0,	  0,   0, '0d0'	 , 15),
('& %M Chime| of Soothe Monster^ (%P1 charges)'	    ,  85, '%',%X'00000000',%X'00000200',
    0,	  800,	10,   1,   1,	0,   0,	  0,   0, '0d0'	 , 15),
('& %M Chime| of Cure Light Wound^ (%P1 charges)'  ,  85, '%',%X'00000000',%X'00000400',
    0,	  400,	11,   1,   1,	0,   0,	  0,   0, '0d0'	 , 10),
('& %M Chime| of Changing^ (%P1 charges)'	   ,  85, '%',%X'00000000',%X'00000800',
    0,	  800,	12,   1,   1,	0,   0,	  0,   0, '0d0'	 , 46),
('& %M Chime| of Remove Curse^ (%P1 charges)'	   ,  85, '%',%X'00000000',%X'00001000',
    0,	  675,	13,   1,   1,	0,   0,	  0,   0, '0d0'	 , 47),
('& %M Chime| of Curing^ (%P1 charges)'		   ,  85, '%',%X'00000000',%X'00002000',
    0,	 1100,	14,   1,   1,	0,   0,	  0,   0, '0d0'	 , 27),
('& %M Chime| of Dispell Evil^ (%P1 charges)'	   ,  85, '%',%X'00000000',%X'00004000',
    0,	 1300,	15,   1,   1,	0,   0,	  0,   0, '0d0'	 , 49),
('& %M Chime| of Darkness^ (%P1 charges)'	   ,  85, '%',%X'00000000',%X'00008000',
    0,	    0,	16,   1,   1,	0,   0,	  0,   0, '0d0'	 , 20),
('& %H| of Bubbles^ (%P1 charges)'	      ,	 86, '%',%X'00000000',%X'00010000',
    0,	    0,	 1,  20,   1,	0,   0,	  0,   0, '0d0'	 , 15),
('& %H| of Calling^ (%P1 charges)'	      ,	 86, '%',%X'00000000',%X'00020000',
    0,	    0,	 2,  20,   1,	0,   0,	  0,   0, '0d0'	 , 10),
('& %H| of Soft Sounds^ (%P1 charges)'	      ,	 86, '%',%X'00000000',%X'00040000',
    0,	  600,	 3,  20,   1,	0,   0,	  0,   0, '0d0'	 ,  8),
('& %H| of *Blasting*^ (%P1 charges)'	      ,	 86, '%',%X'00000000',%X'00080000',
    0,	 2600,	 4,  20,   1,	0,   0,	  0,   0, '0d0'	 , 49),
('& %H| of Cold^ (%P1 charges)'		      ,	 86, '%',%X'00000000',%X'00100000',
    0,	 1000,	 5,  20,   1,	0,   0,	  0,   0, '0d0'	 , 40),
('& %H| of Heat^ (%P1 charges)'		      ,	 86, '%',%X'00000000',%X'00200000',
    0,	 1000,	 6,  20,   1,	0,   0,	  0,   0, '0d0'	 , 40),
('& %H| of Gas^ (%P1 charges)'		      ,	 86, '%',%X'00000000',%X'00400000',
    0,	  900,	 7,  20,   1,	0,   0,	  0,   0, '0d0'	 , 35),
('& %H| of Recall^ (%P1 charges)'	      ,	 86, '%',%X'00000000',%X'00800000',
    0,	 1200,	 8,  20,   1,	0,   0,	  0,   0, '0d0'	 , 30),
('& %H| of *Chaos*^ (%P1 charges)'	      ,	 86, '%',%X'00000000',%X'01000000',
    0,	  800,	 9,  20,   1,	0,   0,	  0,   0, '0d0'	 , 43),
('& %H| of Glue^ (%P1 charges)'		      ,	 86, '%',%X'00000000',%X'02000000',
    0,	    0,	10,  20,   1,	0,   0,	  0,   0, '0d0'	 , 20),
('& %H| of Valhalla^ (%P1 charges)'	      ,	 86, '%',%X'00000000',%X'04000000',
    0,	 2700,	11,  20,   1,	0,   0,	  0,   0, '0d0'	 , 50),
('& %H| of Tritons^ (%P1 charges)'	      ,	 86, '%',%X'00000000',%X'08000000',
    0,	  200,	12,  20,   1,	0,   0,	  0,   0, '0d0'	 , 15),
('& %H| of Fog^ (%P1 charges)'		      ,	 86, '%',%X'00000000',%X'10000000',
    0,	  500,	13,  20,   1,	0,   0,	  0,   0, '0d0'	 , 25),
('& Pipes of Peace [Beginners Instrument]'    ,	 92, '%',%X'00000000',%X'000003FF',
    0,	   30, 258,  40,   1,-100,   0,	  0,   0, '1d1'	 , 40),
('& Lyre of Nature [Instrument I]',		92,   '%',%X'00000000',%X'000FFC00',
    0,	  105, 259,  40,   1,-100,   0,	  0,   0, '0d0'	 , 40),
('& Lute of the Woods [Instrument II]',		 92,   '%',%X'00000000',%X'7FF00000',
    0,	  320, 260,  40,   1,-100,   0,	  0,   0, '0d0'	 , 40),
('& Harp of the Druids [Greater Instrument]'		     ,	92, '%',%X'000001FF',%X'00000000',
    0,	  850, 261,  40,   1,-100,   0,	  0,   0, '2d1'	 ,40),
('& Book of Bard Lyrics [Beginners Handbook]',	 93,   '%',%X'00000000',%X'000007FF',
    0,	   30, 262,  50,   1,-100,   0,	  0,   0, '0d0'	 , 40),
('& Songs of Charming [Song Book I]'		,  93, '%',%X'00000000',%X'000FF800',
    0,	  105, 263,  60,   1,-100,   0,	  0,   0, '1d1'	 ,40),
('& Ballads of Knowledge [Song Book II]'	      ,	 93, '%',%X'00000000',%X'7FF00000',
    0,	  305, 264,  60,   1,-100,   0,	  0,   0, '1d1'	 ,40),
('& Epics of the Bards [Greater Song Book]'    ,  93,	'%',%X'000001FF',%X'00000000',
    0,	  950, 265,  60,   1,-100,   0,	  0,   0, '0d0'	 , 40)
				);
 
 
	{ Items which are sold in the stores are different from dungeon }
	{ items so that identify works properly.  Note that the players }
	{ receive their initial items from this list, so position is	}
	{ very important...						}
 
	inventory_init :=	(
('& Ration~ of Food'				   ,  food, ',',%X'00000000',Nothing_flag,
 5000,	    3, 307,  10,   5,	0,   0,	  0,   0, '0d0'	 ,  0), {  1}
('& Hard Biscuit~'				   ,  food, ',',%X'00000000',Nothing_flag,
  500,	    1, 309,   2,   5,	0,   0,	  0,   0, '0d0'	 ,  0), {  2}
('& Strip~ of Beef Jerky'			   ,  food, ',',%X'00000000',Nothing_flag,
 1750,	    2, 310,   2,   5,	0,   0,	  0,   0, '0d0'	 ,  0), {  3}
('& Pint of Fine Ale'				   ,  food, ',',%X'00000000',Nothing_flag,
  500,	    1, 311,  10,   3,	0,   0,	  0,   0, '0d0'	 ,  0), {  4}
('& Pint of Fine Wine'				   ,  food, ',',%X'00000000',Nothing_flag,
  400,	    2, 312,  10,   1,	0,   0,	  0,   0, '0d0'	 ,  0), {  5}
('& Dagger (Misercorde) (%P2,%P3)'		   ,  dagger, '|',%X'10000000',Nothing_flag,
    0,	   10,	 2,  15,   1,	0,   0,	  0,   0, '1d4'	 ,  0), {  6}
('& Dagger (Stiletto) (%P2,%P3)'		   ,  dagger, '|',%X'10000000',Nothing_flag,
    0,	   10,	 3,  12,   1,	0,   0,	  0,   0, '1d4'	 ,  0), {  7}
('& Bastard Sword (%P2,%P3)'			   ,  sword, '|',%X'10000000',Nothing_flag,
    0,	  350,	 7, 140,   1,	0,   0,	  0,   0, '3d4'	 ,  0), {  8}
('& Broadsword (%P2,%P3)'			   ,  sword, '|',%X'10000000',Nothing_flag,
    0,	  255,	10, 150,   1,	0,   0,	  0,   0, '2d5'	 ,  0), {  9}
('& Longsword (%P2,%P3)'			   ,  sword, '|',%X'10000000',Nothing_flag,
    0,	  300,	18, 130,   1,	0,   0,	  0,   0, '1d10' ,  0), { 10}
('& Small Sword (%P2,%P3)'			   ,  dagger, '|',%X'10000000',Nothing_flag,
    0,	   48,	22,  75,   1,	0,   0,	  0,   0, '1d6'	 ,  0), { 11}
('& Broad Axe (%P2,%P3)'			   ,  hafted_weapon, '\',%X'10000000',Nothing_flag,
    0,	  304,	 4, 160,   1,	0,   0,	  0,   0, '2d5'	 ,  0), { 12}
('& Morningstar (%P2,%P3)'			   ,  maul, '\',%X'00000000',Nothing_flag,
    0,	  396,	 9, 150,   1,	0,   0,	  0,   0, '2d6'	 ,  0), { 13}
('& Mace (%P2,%P3)'				   ,  maul, '\',%X'00000000',Nothing_flag,
    0,	  130,	10, 120,   1,	0,   0,	  0,   0, '2d4'	 ,  0), { 14}
('& War Hammer (%P2,%P3)'			   ,  maul, '\',%X'00000000',Nothing_flag,
    0,	  225,	11, 120,   1,	0,   0,	  0,   0, '3d3'	 ,  0), { 15}
('& Halberd (%P2,%P3)'				   ,  pole_arm, '/',%X'10000000',Nothing_flag,
    0,	  430,	 5, 190,   1,	0,   0,	  0,   0, '3d4'	 ,  0), { 16}
('& Pike (%P2,%P3)'				   ,  pole_arm, '/',%X'10000000',Nothing_flag,
    0,	  358,	 7, 160,   1,	0,   0,	  0,   0, '2d5'	 ,  0), { 17}
('& Spear (%P2,%P3)'				   ,  pole_arm, '/',%X'10000000',Nothing_flag,
    0,	   36,	 8,  50,   1,	0,   0,	  0,   0, '1d6'	 ,  0), { 18}
('& Short Bow (%P2)'				   ,  bow_crossbow_or_sling, '}',%X'00000000',Nothing_flag,
    2,	   50,	 1,  30,   1,	0,   0,	  0,   0, '0d0'	 ,  0), { 19}
('& Long Bow (%P2)'				   ,  bow_crossbow_or_sling, '}',%X'00000000',Nothing_flag,
    3,	  120,	 2,  40,   1,	0,   0,	  0,   0, '0d0'	 ,  0), { 20}
('& Light Crossbow (%P2)'			   ,  bow_crossbow_or_sling, '}',%X'00000000',Nothing_flag,
    5,	  160,	10, 110,   1,	0,   0,	  0,   0, '0d0'	 ,  0), { 21}
('& Sling (%P2)'				   ,  bow_crossbow_or_sling, '}',%X'00000000',Nothing_flag,
    1,	    5,	20,   5,   1,	0,   0,	  0,   0, '0d0'	 ,  0), { 22}
('& Arrow~ (%P2,%P3)'				   ,  arrow, '{',%X'10000000',Nothing_flag,
    0,	    1,	 1,   2,   1,	0,   0,	  0,   0, '3d4'	 ,  0), { 23}
('& Bolt~ (%P2,%P3)'				   ,  bolt, '{',%X'10000000',Nothing_flag,
    0,	    2,	 1,   3,   1,	0,   0,	  0,   0, '3d5'	 ,  0), { 24}
('& Iron Shot~ (%P2,%P3)'			   ,  sling_ammo, '{',%X'00000000',Nothing_flag,
    0,	    2,	 1,   5,   1,	0,   0,	  0,   0, '3d3'	 ,  0), { 25}
('& Pick (%P1) (%P2,%P3)'			   ,  25, '\',%X'10000000',Tunneling_worn_bit,
    1,	   50,	 1, 150,   1,	0,   0,	  0,   0, '1d3'	 ,  0), { 26}
('& Shovel (%P1) (%P2,%P3)'			   ,  25, '\',%X'00000000',Tunneling_worn_bit,
    0,	   15,	 2,  60,   1,	0,   0,	  0,   0, '1d2'	 ,  0), { 27}
('& Pair of Soft Leather Boots [%P6,%P4]'	  	   ,  boots, ']',%X'00000000',Nothing_flag,
    0,	    7,	 2,  30,   1,	0,   0,	  2,   0, '1d1'	 ,  0), { 28}
('& Pair of Hard Leather Boots [%P6,%P4]'		   ,  boots, ']',%X'00000000',Nothing_flag,
    0,	   12,	 3,  40,   1,	0,   0,	  3,   0, '1d1'	 ,  0), { 29}
('& Hard Leather Cap [%P6,%P4]'				   ,  helm, ']',%X'00000000',Nothing_flag,
    0,	   12,	 2,  15,   1,	0,   0,	  2,   0, '0d0'	 ,  0), { 30}
('& Metal Cap [%P6,%P4]'			   ,  helm, ']',%X'00000000',Nothing_flag,
    0,	   30,	 3,  20,   1,	0,   0,	  3,   0, '1d1'	 ,  0), { 31}
('& Iron Helm [%P6,%P4]'			   ,  helm, ']',%X'00000000',Nothing_flag,
    0,	   75,	 4,  75,   1,	0,   0,	  5,   0, '1d3'	 ,  0), { 32}
('Soft Leather Armor [%P6,%P4]'			   ,  soft_armor, '(',%X'00000000',Nothing_flag,
    0,	   18,	 2,  80,   1,	0,   0,	  4,   0, '0d0'	 ,  0), { 33}
('Soft Studded Leather [%P6,%P4]'		   ,  soft_armor, '(',%X'00000000',Nothing_flag,
    0,	   35,	 3,  90,   1,	0,   0,	  5,   0, '1d1'	 ,  0), { 34}
('Hard Leather Armor [%P6,%P4]'			   ,  soft_armor, '(',%X'00000000',Nothing_flag,
    0,	   55,	 4, 100,   1,  -1,   0,	  6,   0, '1d1'	 ,  0), { 35}
('Hard Studded Leather [%P6,%P4]'		   ,  soft_armor, '(',%X'00000000',Nothing_flag,
    0,	  100,	 5, 110,   1,  -1,   0,	  7,   0, '1d2'	 ,  0), { 36}
('Leather Scale Mail [%P6,%P4]'			   ,  soft_armor, '(',%X'00000000',Nothing_flag,
    0,	  330,	 9, 140,   1,  -1,   0,	 11,   0, '1d1'	 ,  0), { 37}
('Metal Scale Mail [%P6,%P4]'			   ,  hard_armor, '[',%X'00000000',Nothing_flag,
    0,	  430,	 1, 250,   1,  -2,   0,	 13,   0, '1d4'	 ,  0), { 38}
('Chain Mail [%P6,%P4]'				   ,  hard_armor, '[',%X'00000000',Nothing_flag,
    0,	  530,	 2, 220,   1,  -2,   0,	 14,   0, '1d4'	 ,  0), { 39}
('Partial Plate Armor [%P6,%P4]'		   ,  hard_armor, '[',%X'00000000',Nothing_flag,
    0,	  900,	 9, 260,   1,  -3,   0,	 22,   0, '1d6'	 ,  0), { 40}
('Full Plate Armor [%P6,%P4]'			   ,  hard_armor, '[',%X'00000000',Nothing_flag,
    0,	 1050,	11, 380,   1,  -3,   0,	 25,   0, '2d4'	 ,  0), { 41}
('& Cloak [%P6,%P4]'				   ,  Cloak, '(',%X'00000000',Nothing_flag,
    0,	    3,	 1,  10,   1,	0,   0,	  1,   0, '0d0'	 ,  0), { 42}
('& Set of Leather Gloves [%P6,%P4]'		   ,  gloves_and_gauntlets, ']',%X'00000000',Nothing_flag,
    0,	    3,	 1,   5,   1,	0,   0,	  1,   0, '0d0'	 ,  0), { 43}
('& Set of Gauntlets [%P6,%P4]'			   ,  gloves_and_gauntlets, ']',%X'00000000',Nothing_flag,
    0,	   35,	 2,  25,   1,	0,   0,	  2,   0, '1d1'	 ,  0), { 44}
('& Small Leather Shield [%P6,%P4]'		   ,  shield, ')',%X'00000000',Nothing_flag,
    0,	   30,	 1,  50,   1,	0,   0,	  2,   0, '1d1'	 ,  0), { 45}
('& Medium Leather Shield [%P6,%P4]'		   ,  shield, ')',%X'00000000',Nothing_flag,
    0,	   60,	 2,  75,   1,	0,   0,	  3,   0, '1d2'	 ,  0), { 46}
('& Small Metal Shield [%P6,%P4]'		   ,  shield, ')',%X'00000000',Nothing_flag,
    0,	   50,	 4,  65,   1,	0,   0,	  3,   0, '1d3'	 ,  0), { 47}
('& Ring of Resist Fire'			   ,  ring, '=',%X'00000000',%X'00080000',
    0,	  250,	11,   2,   1,	0,   0,	  0,   0, '0d0'	 ,  0), { 48}
('& Ring of Resist Cold'			   ,  ring, '=',%X'00000000',%X'00200000',
    0,	  250,	12,   2,   1,	0,   0,	  0,   0, '0d0'	 ,  0), { 49}
('& Ring of Feather Falling'			   ,  ring, '=',%X'00000000',%X'04000000',
    0,	  250,	13,   2,   1,	0,   0,	  0,   0, '0d0'	 ,  0), { 50}
('& Ring of Protection [%P4]'			   ,  ring, '=',%X'00000000',Nothing_flag,
    0,	  100,	24,   2,   1,	0,   0,	  0,   0, '0d0'	 ,  0), { 51}
('& Amulet of Charisma (%P1)'			   ,  amulet, '"',%X'00000000',%X'00000020',
    0,	  250,	 6,   3,   1,	0,   0,	  0,   0, '0d0'	 ,  0), { 52}
('& Amulet of Slow Digestion'			   ,  amulet, '"',%X'00000000',%X'00000080',
    0,	  200,	 9,   3,   1,	0,   0,	  0,   0, '0d0'	 ,  0), { 53}
('& Amulet of Resist Acid'			   ,  amulet, '"',%X'00000000',%X'00100000',
    0,	  300,	10,   3,   1,	0,   0,	  0,   0, '0d0'	 ,  0), { 54}
('& Scroll~ of Enchant Weapon To-Hit'		   ,  scroll1, '?',%X'00000000',%X'00000001',
    0,	  125, 300,   5,   1,	0,   0,	  0,   0, '0d0'	 ,  0), { 55}
('& Scroll~ of Enchant Weapon To-Dam'		   ,  scroll1, '?',%X'00000000',%X'00000002',
    0,	  125, 301,   5,   1,	0,   0,	  0,   0, '0d0'	 ,  0), { 56}
('& Scroll~ of Enchant Armor'			   ,  scroll1, '?',%X'00000000',%X'00000004',
    0,	  125, 302,   5,   1,	0,   0,	  0,   0, '0d0'	 ,  0), { 57}
('& Scroll~ of Identify'			   ,  scroll1, '?',%X'00000000',%X'00000008',
    0,	   50, 303,   5,   2,	0,   0,	  0,   0, '0d0'	 ,  0), { 58}
('& Scroll~ of Remove Curse'			   ,  scroll1, '?',%X'00000000',%X'00000010',
    0,	  100, 304,   5,   1,	0,   0,	  0,   0, '0d0'	 ,  0), { 59}
('& Scroll~ of Light'				   ,  scroll1, '?',%X'00000000',%X'00000020',
    0,	   15, 305,   5,   3,	0,   0,	  0,   0, '0d0'	 ,  0), { 60}
('& Scroll~ of Phase Door'			   ,  scroll1, '?',%X'00000000',%X'00000080',
    0,	   15, 306,   5,   2,	0,   0,	  0,   0, '0d0'	 ,  0), { 61}
('& Scroll~ of Magic Mapping'			   ,  scroll1, '?',%X'00000000',%X'00000800',
    0,	   40, 307,   5,   2,	0,   0,	  0,   0, '0d0'	 ,  0), { 62}
('& Scroll~ of Treasure Detection'		   ,  scroll1, '?',%X'00000000',%X'00004000',
    0,	   15, 308,   5,   2,	0,   0,	  0,   0, '0d0'	 ,  0), { 63}
('& Scroll~ of Object Detection'		   ,  scroll1, '?',%X'00000000',%X'00008000',
    0,	   15, 309,   5,   2,	0,   0,	  0,   0, '0d0'	 ,  0), { 64}
('& Scroll~ of Detect Invisible'		   ,  scroll1, '?',%X'00000000',%X'00080000',
    0,	   15, 310,   5,   2,	0,   0,	  0,   0, '0d0'	 ,  0), { 65}
('& Scroll~ of Recharging'			   ,  scroll1, '?',%X'00000000',%X'01000000',
    0,	  200, 311,   5,   1,	0,   0,	  0,   0, '0d0'	 ,  0), { 66}
('& Book of Magic Spells [Beginners-Magik]',Magic_Book,'?',%X'00000000',%X'0000007F',
    0,	   25, 257,  60,   1,-100,   0,	  0,   0, '1d1'	 ,  0), { 67}
('& Book of Magic Spells [Magik I]'		   ,  Magic_Book, '?',%X'00000000',%X'0007FF80',
    0,	  100, 258,  60,   1,-100,   0,	  0,   0, '1d1'	 ,  0), { 68}
('& Book of Magic Spells [Magik II]'		   ,  Magic_Book, '?',%X'00000000',%X'7FF80000',
    0,	  400, 259,  60,   1,-100,   0,	  0,   0, '1d1'	 ,  0), { 69}
('& Book of Magic Spells [Mages Guide to Power]',  Magic_Book, '?',%X'000001FF',%X'0000000',
    0,	  800, 260,  60,   1,-100,   0,	  0,   0, '1d1'	 ,  0), { 70}
('& Holy Book of Prayers [Beginners Handbook]'	   ,  Prayer_Book, '?',%X'00000000',%X'000000FF',
    0,	   25, 258,  60,   1,-100,   0,	  0,   0, '1d1'	 ,  0), { 71}
('& Holy Book of Prayers [Words of Wisdom]'	   ,  Prayer_Book, '?',%X'00000000',%X'0007FF00',
    0,	  100, 259,  60,   1,-100,   0,	  0,   0, '1d1'	 ,  0), { 72}
('& Holy Book of Prayers [Chants and Blessings]'   ,  Prayer_Book, '?',%X'00000001',%X'7FF80000',
    0,	  300, 260,  60,   1,-100,   0,	  0,   0, '1d1'	 ,  0), { 73}
('& Holy Book of Prayers [Exorcism and Dispelling]',  Prayer_Book, '?',%X'000001FE',%X'00000000',
    0,	  900, 261,  60,   1,-100,   0,	  0,   0, '1d1'	 ,  0), { 74}
('& Potion~ of Restore Strength'		   ,  potion1, '!',%X'00000000',%X'00000004',
    0,	  300, 310,   4,   1,	0,   0,	  0,   0, '1d1'	 ,  0), { 75}
('& Potion~ of Restore Intelligence'		   ,  potion1, '!',%X'00000000',%X'00000020',
    0,	  300, 311,   4,   1,	0,   0,	  0,   0, '1d1'	 ,  0), { 76}
('& Potion~ of Restore Wisdom'			   ,  potion1, '!',%X'00000000',%X'00000100',
    0,	  300, 312,   4,   1,	0,   0,	  0,   0, '1d1'	 ,  0), { 77}
('& Potion~ of Restore Charisma'		   ,  potion1, '!',%X'00000000',%X'00000800',
    0,	  300, 313,   4,   1,	0,   0,	  0,   0, '1d1'	 ,  0), { 78}
('& Potion~ of Cure Light Wounds'		   ,  potion1, '!',%X'00000000',%X'10001000',
   50,	   15, 314,   4,   2,	0,   0,	  0,   0, '1d1'	 ,  0), { 79}
('& Potion~ of Cure Serious Wounds'		   ,  potion1, '!',%X'00000000',%X'30002000',
  100,	   40, 315,   4,   1,	0,   0,	  0,   0, '1d1'	 ,  0), { 80}
('& Potion~ of Cure Critical Wounds'		   ,  potion1, '!',%X'00000000',%X'70004000',
  100,	  100, 316,   4,   1,	0,   0,	  0,   0, '1d1'	 ,  0), { 81}
('& Potion~ of Restore Dexterity'		   ,  potion1, '!',%X'00000000',%X'04000000',
    0,	  300, 317,   4,   1,	0,   0,	  0,   0, '1d1'	 ,  0), { 82}
('& Potion~ of Restore Constitution'		   ,  potion1, '!',%X'00000000',%X'68000000',
    0,	  300, 318,   4,   1,	0,   0,	  0,   0, '1d1'	 ,  0), { 83}
('& Potion~ of Heroism'				   ,  potion2, '!',%X'00000000',%X'00000010',
    0,	   35, 319,   4,   2,	0,   0,	  0,   0, '1d1'	 ,  0), { 84}
('& Potion~ of Boldliness'			   ,  potion2, '!',%X'00000000',%X'00000040',
    0,	   10, 320,   4,   2,	0,   0,	  0,   0, '1d1'	 ,  0), { 85}
('& Wand of Light (%P1 charges)'		   ,  wand, '-',%X'00000000',%X'00000001',
    0,	  200,	 1,  10,   1,	0,   0,	  0,   0, '1d1'	 ,  2), { 86}
('& Wand of Lightning Bolts (%P1 charges)'	   ,  wand, '-',%X'00000000',%X'00000002',
    0,	  600,	 2,  10,   1,	0,   0,	  0,   0, '1d1'	 ,  6), { 87}
('& Wand of Magic Missile (%P1 charges)'	    ,  wand, '-',%X'00000000',%X'00002000',
    0,	  200,	14,  10,   1,	0,   0,	  0,   0, '1d1'	 ,  2), { 88}
('& Wand of Disarming (%P1 charges)'		   ,  wand, '-',%X'00000000',%X'00020000',
    0,	  700,	18,  10,   1,	0,   0,	  0,   0, '1d1'	 , 12), { 89}
('& Wand of Lightning Balls (%P1 charges)'	   ,  wand, '-',%X'00000000',%X'00040000',
    0,	 1200,	19,  10,   1,	0,   0,	  0,   0, '1d1'	 , 20), { 90}
('& Wand of Wonder (%P1 charges)'		   ,  wand, '-',%X'00000000',%X'00800000',
    0,	  250,	24,  10,   1,	0,   0,	  0,   0, '1d1'	 , 10), { 91}
('& Staff of Light (%P1 charges)'		   ,  staff, '_',%X'00000000',%X'00000001',
    0,	  250,	 1,  50,   1,	0,   0,	  0,   0, '1d2'	 ,  3), { 92}
('& Staff of Door/Stair Location (%P1 charges)'	   ,  staff, '_',%X'00000000',%X'00000002',
    0,	  350,	 2,  50,   1,	0,   0,	  0,   0, '1d2'	 ,  7), { 93}
('& Staff of Trap Location (%P1 charges)'	   ,  staff, '_',%X'00000000',%X'00000004',
    0,	  350,	 3,  50,   1,	0,   0,	  0,   0, '1d2'	 ,  7), { 94}
('& Staff of Detect Invisible (%P1 charges)'	   ,  staff, '_',%X'00000000',%X'00008000',
    0,	  200,	16,  50,   1,	0,   0,	  0,   0, '1d2'	 ,  3), { 95}
('& Potion~ of Restore Life Levels'		   ,  potion2, '!',%X'00000000',%X'00000080',
    0,	  400, 321,   4,   1,	0,   0,	  0,   0, '1d1'	 ,  0), { 96}
('& Scroll~ of Blessing'			   ,  scroll2, '?',%X'00000000',%X'00000020',
    0,	   15, 312,   5,   2,	0,   0,	  0,   0, '0d0'	 ,  0), { 97}
('& Scroll~ of Word-of-Recall'			   ,  scroll2, '?',%X'00000000',%X'00000100',
    0,	  150,  313,   5,   3,	0,   0,	  0,   0, '0d0'	 ,  0), { 98}
('& Potion~ of Slow Poison'			   ,  potion2, '!',%X'00000000',%X'00000800',
    0,	   25, 322,   4,   2,	0,   0,	  0,   0, '1d1'	 ,  0), { 99}
('& Potion~ of Neutralize Poison'		   ,  potion2, '!',%X'00000000',%X'00001000',
    0,	   75, 323,   4,   1,	0,   0,	  0,   0, '1d1'	 ,  0), {100}
('& Wand of Stinking Cloud (%P1 charges)'	   ,  wand, '-',%X'00000000',%X'00200000',
    0,	  400,	22,  10,   1,	0,   0,	  0,   0, '1d1'	 ,  5), {101}
('& Iron Spike~'				   ,  spike, '~',%X'10000000',Nothing_flag,
    0,	    1,	 1,  10,   1,	0,   0,	  0,   0, '1d1'	 ,  1), {102}
('& Brass Lantern~ with %P5 turns of light'	   ,  Lamp_or_Torch, '~',%X'00000000',Nothing_flag,
 7500,	   35,	 2,  50,   1,	0,   0,	  0,   0, '1d1'	 ,  1), {103}
('& Wooden Torch~ with %P5 turns of light'	   ,  Lamp_or_Torch, '~',%X'00000000',Nothing_flag,
 4000,	    2, 270,  30,   5,	0,   0,	  0,   0, '1d1'	 ,  1), {104}
('& Flask~ of oil'				   ,  flask_of_oil, '!',%X'00000000',%X'00040000',
 7500,	    3, 257,  10,   5,	0,   0,	  0,   0, '2d6'	 ,  1), {105}
('Lodging for one day'				   ,  95, '.',%X'00000000',Nothing_flag,
    1,	   50, 300,3000,  14,	0,   0,	  0,   0, '0d0'	 ,  0),	 {106}
('& Pipes of Peace [Beginners Instruments]'		   ,  92, '%',%X'00000000',%X'000003FF',
    0,	   30, 258,  40,   1,-100,   0,	  0,   0, '1d1'	 , 40), {107}
('& Lyre of Nature [Instrument I]',		92,   '%',%X'00000000',%X'0007FC00',
    0,	  105, 259,  40,   1,-100,   0,	  0,   0, '0d0'	 , 40),{108}
('& Lute of the Woods [Instrument II]',		 92,   '%',%X'00000000',%X'7FF80000',
    0,	  320, 260,  40,   1,-100,   0,	  0,   0, '0d0'	 , 40),{109}
('& Harp of the Druids [Greater Instrument]'		     ,	92, '%',%X'000001FF',%X'00000000',
    0,	  850, 261,  40,   1,-100,   0,	  0,   0, '2d1'	 ,40), {110}
('& Book of Bard Lyrics [Beginners Song book]',	  93,	'%',%X'00000000',%X'000007FF',
    0,	   30, 262,  50,   1,-100,   0,	  0,   0, '0d0'	 , 40),{111}
('& Songs of Charming [Song Book I]'			,  93, '%',%X'00000000',%X'000FF800',
    0,	  105, 263,  60,   1,-100,   0,	  0,   0, '1d1'	 ,40), {112}
('& Ballads of Knowledge [Song Book II]'		     ,	93, '%',%X'00000000',%X'7FF00000',
    0,	  305, 264,  60,   1,-100,   0,	  0,   0, '1d1'	 ,40), {113}
('& Epics of the Bards [Greater Song Book]',93,	  '%',%X'000001FF',%X'00000000',
    0,	  950, 265,  60,   1,-100,   0,	  0,   0, '0d0'	 , 40), {114}
('Lodging for the week'				  ,   95, '.',0,0,
    7,	  200, 301,3000,   1,	0,   0,	  0,   0, '0d0',    0), {115}
('Lodging for three days'			  ,   95, '.',0,0,
   30,	  120, 302,3000,   1,	0,   0,	  0,   0, '0d0',    0),	 {116}
('Chime of Light (%P1 charges)'			  ,   85, '%',%X'00000000',%X'00000001',
    0,	  275,	 1,   1,   1,	0,   0,	  0,   0, '0d0',   10), {117}
('Chime of Detect Doors/Stairs (%P1 charges)', 85, '%', %X'00000000',%X'00000002',
    0,	  375,	 2,   1,   1,	0,   0,	  0,   0, '0d0',   15), {118}
('Chime of Remove Curse (%P1 charges)', 85, '%',%X'00000000',%X'00001000',
    0,	  675,	13,   1,   1,	0,   0,	  0,   0, '0d0',   47), {119}
('Horn of Soft Sounds (%P1 charges)', 86, '%',%X'00000000',%X'00040000',
    0,	  600,	 3,  20,   1,	0,   0,	  0,   0, '0d0',    8), {120}
('Horn of Tritons (%P1 charges)', 86, '%',%X'00000000',%X'08000000',
    0,	  200,	12,  20,   1,	0,   0,	  0,   0, '0d0',   15), {121}
('& Finely cut Agate~', 5, '*',%X'00000000',%X'00000000',
    0,     50, 257,   5,   1,   0,   0,   0,   0, '0d0',    5), {122}
('& Finely cut Diamond~', 5, '*',%X'00000000',%X'00000000',
    0,     500, 258,  5,   1,   0,   0,   0,   0, '0d0',     10), {123}
('& Rough cut Diamond~', 5, '*',%X'00000000',%X'00000000',
    0,     100, 259,  5,   1,   0,   0,   0,   0, '0d0',     10), {124}
('& Rough cut Sapphire~', 5, '*',%X'00000000',%X'00000000',
    0,     40, 260,  5,   1,   0,   0,   0,   0, '0d0',     5), {125}
('& Finely cut Sapphire~', 5, '*',%X'00000000',%X'00000000',
    0,     250, 261,  5,   1,   0,   0,   0,   0, '0d0',     10), {126}
('& Small pouch of Diamonds~', 5, '*',%X'00000000',%X'00000000',
    0,     1000, 262,  5,   1,   0,   0,   0,   0, '0d0',     10), {127}
('& Finely wrought gold necklace~', 4, '*',%X'00000000',%X'00000000',
    0,     100, 263,  5,   1,   0,   0,   0,   0, '0d0',     10), {128}
('& Small silver bracelet~', bracers, '*',%X'00000000',%X'00000000',
    0,     80, 264,  5,   1,   0,   0,   0,   0, '0d0',     10), {129}
('& Large mithril garter-belt~', 4, '*',%X'00000000',%X'00000000',
    0,     1500, 265,  5,   1,   0,   0,   0,   0, '0d0',     20), {130}
('& Small silver pendant~', 4, '*',%X'00000000',%X'00000000',
    0,     60, 266,  5,   1,   0,   0,   0,   0, '0d0',     5), {131}
('& Small gold pendant~', 4, '*',%X'00000000',%X'00000000',
    0,     90, 267,  5,   1,   0,   0,   0,   0, '0d0',     10), {132}
('& Small mithril pendant~', 4, '*',%X'00000000',%X'00000000',
    0,     450, 268,  5,   1,   0,   0,   0,   0, '0d0',     15), {133}
('& Finely cut Gem of Detect Monsters (%P1 charges)', 5, '*',nothing_flag,%X'00040000',
    0,	  350,   1,   5,   1,	0,   0,	  0,   0, '0d0'	 ,  10), {134}
('& Finely cut Gem of Dispell Evil (%P1 charges)', 5, '*',nothing_flag,%X'00080000',
    0,	  1200,  2,   5,   1,	0,   0,	  0,   0, '0d0'	 ,  10), {135}
('& Finely cut Gem of Acid Balls (%P1 charges)', 5, '*',nothing_flag,%X'00200000',
    0,	  1000,   4,   5,   1,	0,   0,	  0,   0, '0d0'	 ,  10), {136}
('& Finely cut Gem of Detect Invisible (%P1 charges)', 5, '*',nothing_flag,%X'00400000',
    0,	  200,   5,   5,   1,	0,   0,	  0,   0, '0d0'	 ,  10), {137}
('& Finely cut Gem of Identify (%P1 charges)', 5, '*',nothing_flag,%X'00800000',
    0,	  600,   6,   5,   1,	0,   0,	  0,   0, '0d0'	 ,  10), {138}
('& Finely cut Gem of Light (%P1 charges)', 5, '*',nothing_flag,%X'01000000',
    0,	  100,   7,   5,   1,	0,   0,	  0,   0, '0d0'	 ,  10), {139}
('& Finely cut Gem of Remove Curse (%P1 charges)', 5, '*',nothing_flag,%X'04000000',
    0,	  250,   8,   5,   1,	0,   0,	  0,   0, '0d0'	 ,  10), {140}
('& Finely cut Gem of Annihilation (%P1 charges)', 5, '*',nothing_flag,%X'08000000',
    0,	  350,   7,   5,   1,	0,   0,	  0,   0, '0d0'	 ,  10), {141}
('& Finely cut Gem of Recall (%P1 charges)', 5, '*',nothing_flag,%X'10000000',
    0,	 1200,   7,   5,   1,	0,   0,	  0,   0, '0d0'	 ,  10), {142}
('& Box~ of Piranha Crackers'                      ,junk_food, ',',%X'00000001',
%X'40000000', 1500,4, 257,   2,   1,   0,   0,   0,   0, '0d0'  , 0),{143}
('& Can~ of Orca-Cola'                     	   ,junk_food, ',',%X'00000002',
%X'40000000',  500,4, 258,   2,   1,   0,   0,   0,   0, '0d0'  , 0),{144}
('& Twelve-Pound Troll Burger~'                    ,junk_food, ',',%X'00000001',
%X'40000000', 7500,15, 259,   2,   1,   0,   0,   0,   0, '0d0'  , 0),{145}
('& Bag~ of Brontosaurus Chips'                    ,junk_food, ',',%X'00000001',
%X'40000000', 3000,12, 260,   2,   1,   0,   0,   0,   0, '0d0'  , 0),{146}
('& Slice~ of Purple Mushroom Pizza'               ,junk_food, ',',%X'00000001',
%X'40000400', 1500,8, 261,   2,   1,   0,   0,   0,   0, '2d6'  , 0),{147} 
		       { This ought to surprise them, Pizza = Oil now }
('& Peanut Butter and Grape Jelly Sandwich~'       ,junk_food, ',',%X'00000001',
%X'40000000', 1000,5, 262,   2,   1,   0,   0,   0,   0, '0d0'  , 0),{148}
('& Dragon Steak~'                                 ,junk_food, ',',%X'00000001',
%X'50000000', 5000,15, 263,   2,   1,   0,   0,   0,   0, '0d0'  , 0),{149}
('& Vorpal Bunny Throat Lozenge~'                  ,junk_food, ',',%X'00000001',
%X'40000000',   50,2, 264,   2,   1,   0,   0,   0,   0, '0d0'  , 0),{150}
('& Deep-Fried Giant Centipede~'                   ,junk_food, ',',%X'00000001',
%X'40000000',  750,5, 265,   2,   1,   0,   0,   0,   0, '0d0'  , 0),{151}
('& Pint~ of Beetle Juice'                         ,junk_food, ',',%X'00000002',
%X'40000000', 1000,4, 266,   2,   1,   0,   0,   0,   0, '0d0'  , 0),{152}
('& Bowl~ of Bat Stew'                             ,junk_food, ',',%X'00000001',
%X'40000000', 2000,6, 267,   2,   1,   0,   0,   0,   0, '0d0'  , 0),{153}
('& Jar~ of Pickled Leeches'                       ,junk_food, ',',%X'00000001',
%X'40000000', 1500,5, 268,   2,   1,   0,   0,   0,   0, '0d0'  , 0),{154}
('& Pack~ of Kitten McNuggets'                     ,junk_food, ',',%X'00000001',
%X'40000000', 1500,8, 269,   2,   1,   0,   0,   0,   0, '0d0'  , 0),{155}
('& Iron Shod Quarterstaff^ (%P2,%P3)'		   ,  maul, '\',%X'00000000',Nothing_flag,
    0,	   25,   13, 100,   1,   0,   0,   0,   0, '1d5'  ,  0), {156}
('Room and board for one day'				   ,  95, '.',%X'00000000',Nothing_flag,
    1,	   70, 303,3000,  14,	0,   0,	  0,   0, '0d0'	 ,  0)	 {157}
		    	);
 			
{ Note : Raised from 26 to 50 possible choices			-DMF-	}
 
	store_choice	:=	(
	{ General Store }
(105,104,103,102,105,104, 42,105, 27, 26,  5,  4,  3,  3,  2,102,103,104,105,
   1,  1,  1,  2,  2,  3,  3,  1,  1,  1,  1,  4,  1,  1,  1,  1,  1,  1,  1,
   1,  1,  1,  1,  1,  1, 27, 26,  4,103,104,105),
	{ Armory	}
( 30, 31, 32, 33, 34, 35, 36, 37, 38, 39, 40, 41, 43, 44, 45, 46, 47, 30, 33,
  34, 43, 44, 28, 29, 30, 31, 30, 31, 32, 33, 34, 35, 36, 37, 38, 39, 40, 41,
  43, 44, 45, 46, 47, 28, 29, 30, 31, 30, 32, 35),
	{ Weaponsmith	}
(  6,  7,  8,  9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 20, 21, 22, 23, 24,
  25,  6,  7, 23, 25, 23, 25,  6,  7,  8, 9 , 10, 11, 12, 13, 14, 15, 16, 17,
  18, 19, 20, 21, 22, 23, 24, 25,  6,  7, 156, 156),
	{ Temple	}
( 59, 59, 77, 79, 80, 81, 84, 85, 13, 14, 15, 96, 97, 98,100, 79, 79, 80, 80,
  81, 98, 59, 77, 80, 81, 84, 59, 59, 77, 79, 80, 81, 84, 85, 13, 14, 15, 96,
  97, 98, 59, 77, 80, 81, 84, 85, 13, 156, 156, 96),
	{ Alchemy shop	}
( 55, 56, 57, 58, 58, 60, 61, 62, 63, 64, 65, 66, 75, 76, 78, 82, 83, 60, 61,
  62, 63, 64, 98, 99, 98, 98, 62, 63, 64, 65, 66, 75, 76, 78, 82, 83, 60, 61,
  55, 56, 57, 58, 59, 60, 61, 62, 63, 64, 65, 66),
	{ Magic shop	}
( 49, 50, 51, 52, 53, 54, 48, 86, 87, 88, 89, 90, 91, 92, 93, 94, 95, 86,101,
  88, 49, 50, 51, 52, 53, 54, 86, 87, 88, 89, 90, 91, 92, 93, 94, 95, 86,101,
  49, 50, 51, 52, 53, 54, 48, 86, 87, 88, 89, 90),
	{ Inn		}
(106,106,106,106,106,106,106,106,106,106,106,106,106,106,106,106,106,106,106,
 106,106,106,106,106,106,115,115,115,115,115,115,115,115,116,116,116,116,116,
 116,116,116,157,157,157,157,157,157,157,157,157),
	{ Library	}
( 67, 68, 69, 70, 71, 72, 73, 74, 67, 68, 69, 70, 71, 72, 58, 62, 63, 64, 65,
  68, 67, 71, 68, 72, 67, 68, 69, 70, 71, 72, 73, 74, 68, 58, 62, 63, 64, 65,
  73, 68, 69, 70, 67, 68, 71, 58, 62, 63, 64, 65),
	{ Music Shop	}
(107,108,109,110,111,112,113,114,114,107,108,109,110,111,112,113,113,114,107,
 108,109,110,111,112,113,114,112,107,107,107,108,108,108,109,109,109,110,110,
 111,112,117,118,119,120,121,117,118,119,120,121),
	{ Gem Shop	}
(122,137,142,123,124,125,126,127,128,129,130,131,132,133,122,124,125,126,126,
 127,127,134,129,130,133,131,135,133,122,134,122,122,130,136,140,124,122,125,
 123,137,124,125,126,141,138,129,130,131,132,139),
	{ All-Nite Deli }
(144,145,146,147,148,149,150,151,152,153,154,155,143,144,145,146,147,148,149,
 150,151,152,153,154,155,143,144,145,146,147,148,149,150,151,152,153,154,155,
 143,144,145,146,148,149,151,152,153,154,155,143)
				);
 
	{ Each store will buy only certain items, based on TVAL }
	store_buy	:=	(
{General Store	}		[1,2,3,13,15,25,30,32,38,77,80,85,86],
{Armory		}		[29,30,31,33,34,35,36,37],
{Weaponsmith	}		[10,11,12,20,21,22,23,24,26],
{Temple		}		[21,70,71,75,76,91,94],
{Alchemy shop	}		[70,71,75,76],
{Magic Shop	}		[1,3,6,40,45,55,60,65,90],
{Inn	 	}		[106],
{Library	}		[91,90,71,70],
{Music Shop	}		[85,86,92,93],
{Jewelry Shop	}		[4,5,7,29,37,38,40,45],		
{All-Night Deli }		[81]
		);

	{ Hours that a store is open, in two hour increments.
		  = Open
		N = 'Closed for the night'
		W = 'Closed for the weekend'
		D = 'Closed for the day'
		B = Bribeable
					}
	store_hours := (
		{	Sat		Sun		Mon	Tue
			Wed		Thu		Fri		}
{General Store	}('NNB       BN','NNB       BN','NNB       BN','NNB       BN',
		  'NNB       BN','NNB       BN','NNB       BN'),
{Armory		}('NNNB     WWW','WWWWWWWWWWWW','WWWB     NNN','NNNB     NNN',
		  'NNNB     NNN','NNNB     NNN','NNNB     NNN'),
{Weapon Smiths	}('NNNB     WWW','WWWWWWWWWWWW','WWWB     NNN','NNNB     NNN',
		  'NNNB     NNN','NNNB     NNN','NNNB     NNN'),
{Temple		}('            ','            ','            ','            ',
		  '            ','            ','            '),
{Alchemy Shop	}('NNNN    NNNN','NNNN    NNNN','NNNN    NNNN','NNNN    NNNN',
		  'NNNN    NNNN','NNNN    NNNN','NNNN    NNNN'),
{Magic Shop	}('NNNN    NNNN','NNNN    NNNN','NNNN    NNNN','NNNN    NNNN',
		  'NNNN    NNNN','NNNN    NNNN','NNNN    NNNN'),
{Inn		}('            ','            ','            ','            ',
		  '            ','            ','            '),
{Trading Post	}('NNNB      BW','WWWWWWWWWWWW','WWWB      BN','NNNB      BN',
		  'NNNB      BN','NNNB      BN','NNNB      BN'),
{Library	}('NNN        N','NNN        N','NNN        N','NNN        N',
		  'NNN        N','NNN        N','NNN        N'),
{Music Shop 	}('NNNB    BNNN','NNNB   BNNNN','NNNB    BNNN','NNNB    BNNN',
		  'NNNB    BNNN','NNNB    BNNN','NNNB    BNNN'),
{Gem Store	}('NNNB     BNN','NNNB   BNNNN','NNNB     BNN','NNNB     BNN',
		  'NNNB     BNN','NNNB     BNN','NNNB     BNN'),
{Insurance Shop	}('BBBB     BBB','BBBB     BBB','BBBB     BBB','BBBB     BBB',
		  'BBBB     BBB','BBBB     BBB','BBBB     BBB'),
{Bank		}('NNNN   WWWWW','WWWWWWWWWWWW','WWWW     NNN','NNNN     NNN',
		  'NNNN     NNN','NNNN     NNN','NNNN     WWW'),
{Money Exchange	}('NNNB     BWW','WWWWWWWWWWWW','WWWB     BNN','NNNB     BNN',
		  'NNNB     BNN','NNNB     BNN','NNNB     BNN'),
{Casino		}('            ','            ','   DDDDDD   ','   DDDDDD   ',
		  '   DDDDDD   ','   DDDDDD   ','   DDDDDD   '),
{All-Night Deli }('            ','            ','            ','            ',
                  '            ','            ','            '),
{Quest Store    }('            ','            ','            ','            ',
		  '            ','            ','            '));
	{ Store owners can be bribed to open up their shop during
	  certain hours (so that you can always have the opportunity to
	  buy insurance, and suchlike.)					}
	store_bribe := (
				50,
				150,    
				150,
				75,
				75,
				300,
				25,
				50,
				100,
				50,
				75,
				100,
				100,
				25,
				100,
				0,
				0);
 
	{ Store owners have different characteristics for pricing and haggling}
	{ Note: Store owners should be added in groups, one for each store    }
	owners		:=	(
{set number one}
('Erick the Honest       (Human)      General Store',
	 2500, 0.75, 0.08, 0.04, 1, 12),
('Mauglin the Grumpy     (Dwarf)      Armory'	    ,
	32000, 1.00, 0.12, 0.04, 6,  5),
('Arndal Beast-Slayer    (Half-Elf)   Weaponsmith'  ,
	10000, 0.85, 0.10, 0.05, 2,  8),
('Hardblow the Humble    (Human)      Temple'	    ,
	 3500, 0.75, 0.09, 0.06, 1, 15),
('Ga-nat the Greedy      (Gnome)      Alchemist'    ,
	12000, 1.20, 0.15, 0.04, 5,  9),
('Valeria Starshine      (Elf)        Magic Shop'   ,
	32000, 0.75, 0.10, 0.05, 3, 11),
('Tika Majere            (Human)      Inn'	    ,
	32000, 1.00, 0.08, 0.05, 1,  7),
('Socrates the Philosopher  (Human)  Library',
	 5000, 1.00, 0.10, 0.05, 1,  10),
('Dysella of Oakglade    (Dryad)      Music Shop',
	10000, 1.00, 0.10, 0.05,10,  10),
('The Dragon Master      (Human)       Gem Store',
         15000, 0.95, 0.10, 0.05, 1,  5),
('Grond the Grotesque	(Half-Orc)     All-Nite Deli',
	  3000, 1.00, 0.10, 0.05, 7,  5),


{set number two}
('Andy the Friendly      (Halfling)   General Store',
	 2000, 0.70, 0.08, 0.05, 4, 15),
('Darg-Low the Grim      (Human)      Armory'	    ,
	10000, 0.90, 0.11, 0.04, 1,  9),
('Oglign Dragon-Slayer   (Dwarf)      Weaponsmith'  ,
 	32000, 0.95, 0.12, 0.04, 6,  8),
('Gunnar the Paladin     (Human)      Temple'	    ,
	 5000, 0.85, 0.10, 0.05, 1, 23),
('Mauser the Chemist     (Half-Elf)   Alchemist'    ,
	10000, 0.90, 0.11, 0.05, 2,  8),
('K''rek Kwith the Quick  (Phraint)    Magic Shop'   ,
	32000, 0.90, 0.10, 0.05, 9,  5),
('Samwise                (Halfling)   Inn'	    ,
	32000, 0.70, 0.10, 0.05, 4, 12),
('Elrond the Wise        (Elf)        Library',
	 5000, 1.00, 0.10, 0.05, 3,  10),
('Shaun the Bard         (Human)    Music Shop',
	10000, 1.00, 0.10, 0.05, 1,  10),
('Ari-San                (Elf)       Gem Store',
         15000, 1.00, 0.10, 0.05, 3,  10),
('Gerald Ciceau		 (Human)     All-Nite Deli',
	  3000, 1.00, 0.07, 0.05, 1,  5),

{set number three}
('Lyar-el the Comely     (Elf)        General Store',
	 3000, 0.65, 0.07, 0.06, 3, 18),
('Mauglim the Horrible   (Half-Orc)   Armory'	    ,
	 3000, 1.00, 0.13, 0.05, 7,  9),
('Ithyl-Mak the Beastly	 (Half-Troll) Weaponsmith'  ,
	 3000, 1.10, 0.15, 0.06, 8,  8),
('Delihla the Pure       (Half-Elf)   Temple'	    ,
	25000, 0.80, 0.07, 0.06, 2, 20),
('Wizzle the Chaotic     (Halfling)   Alchemist'    ,
	10000, 0.90, 0.10, 0.06, 4,  8),
('Inglorian the Mage     (Human?)     Magic Shop'   ,
	32000, 1.00, 0.10, 0.07, 1, 10),
('Lucas the Portly       (Human)      Inn'	    ,
	32000, 0.75, 0.10, 0.03, 1,  3),
('Dyxel the Beautiful    (Dryad)      Library',
	 5000, 1.00, 0.10, 0.05,10, 15),
('Roland the Melodic     (Halfling)   Music Shop',
	10000, 1.00, 0.10, 0.05, 4,  10),
('Galton the turrible    (Half-Orc)   Gem Store',
         15000, 0.95, 0.20, 0.05, 7,  4),
('Joseph Tansli		 (Human)      All-Nite Deli',
	  3000, 1.00, 0.10, 0.05, 1, 10),

{set number four}
('Felimid mac Fal        (Half-Elf)   General Store',
	 3500, 1.10, 0.15, 0.10, 2,  5),
('Andre the Dull         (Half-Troll) Armory'	    ,
	10000, 1.00, 0.08, 0.04, 7,  8),
('Vlad Taltos            (Human)      Weaponsmith'  ,
	25000, 0.80, 0.10, 0.03, 1, 15),
('Brother Maynard        (Human)      Temple'	    ,
	15000, 1.00, 0.15, 0.08, 1,  5),
('Questor Thews	         (Gnome)      Alchemist'    ,
	20000, 0.70, 0.10, 0.02, 5, 10),
('Gopher the Great!      (Gnome)      Magic Shop'   ,
	20000, 1.15, 0.13, 0.06, 5, 10),
('Dean the *Very* large  (Phraint)    Inn'	    ,
	32000, 0.90, 0.10, 0.05, 9,  1),
('Kelstor the Sage       (Human)      Library',
	 5000, 1.00, 0.10, 0.05, 1,  10),               
('K''phelt the Drone     (Phraint)    Music Shop',
	10000, 1.00, 0.10, 0.05, 9,  10),
('Daphnea the Tender     (Dryad)      Gem Store',
         15000, 0.80, 0.10, 0.05,10,  3),
('Clarion the Exotic 	 (Dryad)      All-Nite Deli',
	  3000, 1.00, 0.10, 0.05,10,  5)
				);

	{ Each type of character starts out with a few provisions...	}
	{ Note the the entries refer to array elements of INVENTORY_INIT array}
	player_init	:=	(
		(   1, 104,  42,   7,  33),	{ Warrior	}
		(   1, 104,  42,   7,  67),	{ Mage		}
		(   1, 104,  42, 156,  71),	{ Priest	}
		(   1, 104,  33,   7, 111),	{ Rogue		}
		(   1, 104,  42,   7, 107),	{ Ranger	}
		(   1, 104,  42,   7,  71),	{ Paladin	}
		(   1, 104,  42, 156, 107),	{ Druid		}
		(   1, 104,  42,   7, 111),	{ Bard		}
		(   1, 104,  42,   7,  67),	{ Adventurer	}
		(   1, 104,  42,  28,  43)	{ Monk		}
		);
 
                                   
	{ Identified objects flags					}
	object_ident := (max_objects of false);
 
	{ Traps are just Nasty treasures...				}
	trap_lista	:=	(
('an open pit'					   , Seen_trap, ' ',%X'00000000',%X'00000000',
    0,	    0,	 1,   0,   0,	0,   0,	  0,   0, '2d6'	 ,-50),
('an arrow trap'				   , Unseen_trap, '.',%X'00000000',%X'00000000',
    0,	    0,	 2,   0,   0,	0,   0,	  0,   0, '1d8'	 ,  0),
('a covered pit'				   , Unseen_trap, '.',%X'00000000',%X'00000000',
    0,	    0,	 3,   0,   0,	0,   0,	  0,   0, '2d6'	 ,  0),
('a trap door'					   , Unseen_trap, '.',%X'00000000',%X'00000000',
    0,	    0,	 4,   0,   0,	0,   0,	  0,   0, '2d8'	 ,  0),
('a gas trap'					   , Unseen_trap, '.',%X'00000000',%X'00000000',
    0,	    0,	 5,   0,   0,	0,   0,	  0,   0, '1d4'	 ,  0),
('a loose rock'					   , Unseen_trap, '.',%X'00000000',%X'00000000',
    0,	    0,	 6,   0,   0,	0,   0,	  0,   0, '0d0'	 ,  0),
('a dart trap'					   , Unseen_trap, '.',%X'00000000',%X'00000000',
    0,	    0,	 7,   0,   0,	0,   0,	  0,   0, '1d4'	 ,  0),
('a strange rune'				   , Unseen_trap, '.',%X'00000000',%X'00000000',
    0,	    0,	 8,   0,   0,	0,   0,	  0,   0, '0d0'	 ,  0),
('some loose rock'				   , Unseen_trap, '.',%X'00000000',%X'00000000',
    0,	    0,	 9,   0,   0,	0,   0,	  0,   0, '2d6'	 ,  0),
('a gas trap'					   , Unseen_trap, '.',%X'00000000',%X'00000000',
    0,	    0,	10,   0,   0,	0,   0,	  0,   0, '1d4'	 ,  0),
('a strange rune'				   , Unseen_trap, '.',%X'00000000',%X'00000000',
    0,	    0,	11,   0,   0,	0,   0,	  0,   0, '0d0'	 ,  0),
('a blackened spot'				   , Unseen_trap, '.',%X'00000000',%X'00000000',
    0,	    0,	12,   0,   0,	0,   0,	  0,   0, '4d6'	 ,  0),
('some corroded rock'				   , Unseen_trap, '.',%X'00000000',%X'00000000',
    0,	    0,	13,   0,   0,	0,   0,	  0,   0, '4d6'	 ,  0),
('a gas trap'					   , Unseen_trap, '.',%X'00000000',%X'00000000',
    0,	    0,	14,   0,   0,	0,   0,	  0,   0, '2d6'	 ,  0),
('a gas trap'					   , Unseen_trap, '.',%X'00000000',%X'00000000',
    5,	    0,	15,   0,   0,	0,   0,	  0,   0, '1d4'	 , 10),
('a gas trap'					   , Unseen_trap, '.',%X'00000000',%X'00000000',
    5,	    0,	16,   0,   0,	0,   0,	  0,   0, '1d8'	 ,  5),
('a dart trap'					   , Unseen_trap, '.',%X'00000000',%X'00000000',
    5,	    0,	17,   0,   0,	0,   0,	  0,   0, '1d8'	 , 10),
('a dart trap'					   , Unseen_trap, '.',%X'00000000',%X'00000000',
    5,	    0,	18,   0,   0,	0,   0,	  0,   0, '1d8'	 , 10),
('a chute'					   , Unseen_trap, '.',%X'00000000',%X'00000000',
    5,	    0,	20,   0,   0,	0,   0,	  0,   0, '4d8'	 , 20)
				);
 
	{ Traps: Level represents the difficulty of disarming;	}
	{ and P1 represents the experienced gained when disarmed}
	trap_listb	:=	(
('an open pit'					   , Seen_trap, ' ',%X'00000000',%X'00000000',
    1,	    0,	 1,   0,   0,	0,   0,	  0,   0, '2d6'	 ,-50),
('an arrow trap'				   , Seen_trap, '^',%X'00000000',%X'00000000',
    3,	    0,	 2,   0,   0,	0,   0,	  0,   0, '1d8'	 ,-10),
('a covered pit'				   , Seen_trap, '^',%X'00000000',%X'00000000',
    2,	    0,	 3,   0,   0,	0,   0,	  0,   0, '2d6'	 ,-40),
('a trap door'					   , Seen_trap, '^',%X'00000000',%X'00000000',
    5,	    0,	 4,   0,   0,	0,   0,	  0,   0, '2d8'	 ,-25),
('a gas trap'					   , Seen_trap, '^',%X'00000000',%X'00000000',
    3,	    0,	 5,   0,   0,	0,   0,	  0,   0, '1d4'	 ,  5),
('a loose rock'					   , Seen_trap, ';',%X'00000000',%X'00000000',
    0,	    0,	 6,   0,   0,	0,   0,	  0,   0, '0d0'	 ,-90),
('a dart trap'					   , Seen_trap, '^',%X'00000000',%X'00000000',
    5,	    0,	 7,   0,   0,	0,   0,	  0,   0, '1d4'	 , 10),
('a strange rune'				   , Seen_trap, '^',%X'00000000',%X'00000000',
    5,	    0,	 8,   0,   0,	0,   0,	  0,   0, '0d0'	 ,-10),
('some loose rock'				   , Seen_trap, '^',%X'00000000',%X'00000000',
    5,	    0,	 9,   0,   0,	0,   0,	  0,   0, '2d6'	 ,-10),
('a gas trap'					   , Seen_trap, '^',%X'00000000',%X'00000000',
   10,	    0,	10,   0,   0,	0,   0,	  0,   0, '1d4'	 ,  5),
('a strange rune'				   , Seen_trap, '^',%X'00000000',%X'00000000',
    5,	    0,	11,   0,   0,	0,   0,	  0,   0, '0d0'	 ,-10),
('a blackened spot'				   , Seen_trap, '^',%X'00000000',%X'00000000',
   10,	    0,	12,   0,   0,	0,   0,	  0,   0, '4d6'	 , 10),
('some corroded rock'				   , Seen_trap, '^',%X'00000000',%X'00000000',
   10,	    0,	13,   0,   0,	0,   0,	  0,   0, '4d6'	 , 10),
('a gas trap'					   , Seen_trap, '^',%X'00000000',%X'00000000',
    5,	    0,	14,   0,   0,	0,   0,	  0,   0, '2d6'	 ,  5),
('a gas trap'					   , Seen_trap, '^',%X'00000000',%X'00000000',
    5,	    0,	15,   0,   0,	0,   0,	  0,   0, '1d4'	 , 10),
('a gas trap'					   , Seen_trap, '^',%X'00000000',%X'00000000',
    5,	    0,	16,   0,   0,	0,   0,	  0,   0, '1d8'	 ,  5),
('a dart trap'					   , Seen_trap, '^',%X'00000000',%X'00000000',
    5,	    0,	17,   0,   0,	0,   0,	  0,   0, '1d8'	 , 10),
('a dart trap'					   , Seen_trap, '^',%X'00000000',%X'00000000',
    5,	    0,	18,   0,   0,	0,   0,	  0,   0, '1d8'	 , 10),
	{ Special case, see DOOR_LIST below (subvals must agree)	}
('a closed door'				   , Closed_door, '+',%X'00000000',%X'00000000',
    0,	    0,	19,   0,   0,	0,   0,	  0,   0, '1d1'	 ,  0),
('a chute'					   , Seen_trap, '^',%X'00000000',%X'00000000',
    5,	    0,	20,   0,   0,	0,   0,	  0,   0, '4d8'	 , 20)
				);
 
	{ Stores are just special traps			}
	store_door	:= (
('the entrance to the General Store'		   , Entrance_to_store, 'G',%X'00000000',%X'00000000',
    0,	    0, 101,   0,   0,	0,   0,	  0,   0, '0d0'	 ,  0),
('the entrance to the Armory'			   , Entrance_to_store, 'R',%X'00000000',%X'00000000',
    0,	    0, 102,   0,   0,	0,   0,	  0,   0, '0d0'	 ,  0),
('the entrance to the Weapon Smiths'		   , Entrance_to_store, 'W',%X'00000000',%X'00000000',
    0,	    0, 103,   0,   0,	0,   0,	  0,   0, '0d0'	 ,  0),
('the entrance to the Temple'			   , Entrance_to_store, 'T',%X'00000000',%X'00000000',
    0,	    0, 104,   0,   0,	0,   0,	  0,   0, '0d0'	 ,  0),
('the entrance to the Alchemy Shop'		   , Entrance_to_store, 'A',%X'00000000',%X'00000000',
    0,	    0, 105,   0,   0,	0,   0,	  0,   0, '0d0'	 ,  0),
('the entrance to the Magic Shop'		   , Entrance_to_store, 'M',%X'00000000',%X'00000000',
    0,	    0, 106,   0,   0,	0,   0,	  0,   0, '0d0'	 ,  0),
('the entrance to the Inn'			   , Entrance_to_store, 'I',%X'00000000',%X'00000000',
    0,	    0, 107,   0,   0,	0,   0,	  0,   0, '0d0'	 ,  0),
('the entrance to the Trading Post'		   , Entrance_to_store, 'P',%X'00000000',%X'00000000',
    0,	    0, 108,   0,   0,	0,   0,	  0,   0, '0d0'	 ,  0),
('the entrance to the Library'			   , Entrance_to_store, 'L',%X'00000000',%X'00000000',
    0,	    0, 109,   0,   0,	0,   0,	  0,   0, '0d0'	 ,  0),
('the entrance to the Music Shop'		   , Entrance_to_store, 'U',%X'00000000',%X'00000000',
    0,	    0, 110,   0,   0,	0,   0,	  0,   0, '0d0'	 ,  0),
('the entrance to the Gem Store'		   , Entrance_to_store, 'J',%X'00000000',%X'00000000',
    0,	    0, 113,   0,   0,	0,   0,	  0,   0, '0d0'	 ,  0),
('the entrance to the Insurance Shop'		   , Entrance_to_store, 'N',%X'00000000',%X'00000000',
    0,	    0, 111,   0,   0,	0,   0,	  0,   0, '0d0'	 ,  0),
('the entrance to the Bank'			   , Entrance_to_store, 'B',%X'00000000',%X'00000000',
    0,	    0, 112,   0,   0,	0,   0,	  0,   0, '0d0'	 ,  0),
('the entrance to the Money Exchange'		   , Entrance_to_store, 'X',%X'00000000',%X'00000000',
    0,	    0, 114,   0,   0,	0,   0,	  0,   0, '0d0'	 ,  0),
('the entrance to the Casino'			   , Entrance_to_store, 'C',%X'00000000',%X'00000000',
    0,	    0, 115,   0,   0,	0,   0,	  0,   0, '0d0'	 ,  0),
('the entrance to the All-Nite Deli'		   , Entrance_to_store, 'D',%X'00000000',%X'00000000',
    0,	    0, 116,   0,   0,	0,   0,	  0,   0, '0d0'	 ,  0),
('the entrance to a strange building' 		   , Entrance_to_store, 'Q',%X'00000000',%X'00000000',
    0,	    0, 117,   0,   0,	0,   0,	  0,   0, '0d0'	 ,  0),
('the entrance to a building'		   , Entrance_to_store, '+',%X'00000000',%X'00000000',
    0,	    0, 120,   0,   0,	0,   0,	  0,   0, '0d0'	 ,  0),
('the entrance to a building'		   , Entrance_to_store, '+',%X'00000000',%X'00000000',
    0,	    0, 121,   0,   0,	0,   0,	  0,   0, '0d0'	 ,  0),
('the entrance to a building'		   , Entrance_to_store, '+',%X'00000000',%X'00000000',
    0,	    0, 122,   0,   0,	0,   0,	  0,   0, '0d0'	 ,  0),
('the entrance to a building'		   , Entrance_to_store, '+',%X'00000000',%X'00000000',
    0,	    0, 123,   0,   0,	0,   0,	  0,   0, '0d0'	 ,  0),
('the entrance to a building'		   , Entrance_to_store, '+',%X'00000000',%X'00000000',
    0,	    0, 124,   0,   0,	0,   0,	  0,   0, '0d0'	 ,  0)
				);
 
 scare_monster :=
('a strange rune'				   , Seen_trap, '^',%X'00000000',%X'00000000',
    0,	    0,	99,   0,   0,	0,   0,	  0,   0, '0d0'	 ,-90);
 
 some_rubble :=
('some rubble'					   , Rubble, ':',%X'00000000',%X'00000000',
    0,	    0,	 1,   0,   0,	0,   0,	  0,   0, '0d0'	 ,  0);
 
 
	{ Secret door must have same subval as closed door in	}
	{ TRAP_LISTB.  See CHANGE_TRAP				}
	door_list	:=	(
('an open door'					   , Open_door,'''',%X'00000000',%X'00000000',
    0,	    0,	 1,   0,   0,	0,   0,	  0,   0, '1d1'	 ,  0),
('a closed door'				   , Closed_door, '+',%X'00000000',%X'00000000',
    0,	    0,	19,   0,   0,	0,   0,	  0,   0, '1d1'	 ,  0),
('a secret door'				   , Secret_door, '#',%X'00000000',%X'00000000',
    0,	    0,	19,   0,   0,	0,   0,	  0,   0, '1d1'	 ,  0)
				);
 
 up_stair   :=                                    
('an up staircase'				  , Up_staircase, '<',%X'00000000',%X'00000000',
    0,	    0,	 1,   0,   0,	0,   0,	  0,   0, '1d1'	 ,  0);
 
 down_stair :=
('a down staircase'				   , Down_staircase, '>',%X'00000000',%X'00000000',
    0,	    0,	 1,   0,   0,	0,   0,	  0,   0, '1d1'	 ,  0);
 
 up_steep :=
('a steep staircase'				   , Up_steep_staircase, '<',%X'00000000',%X'00000000',
    0,	    0,	 1,   0,   0,	0,   0,	  0,   0, '1d1'	 ,  0);
 
down_steep :=
('a steep staircase'				   , Down_steep_staircase, '>',%X'00000000',%X'00000000',
    0,	    0,	 1,   0,   0,	0,   0,	  0,   0, '1d1'	 ,  0);
 
 
	{ Sets for easy testing						}
	floor_set   := [1,2,4,5,6,7,16,17,18];
	wall_set    := [10,11,12];
	pwall_set   := [10,11,12,15];
	corr_set    := [4,5];
	trap_set    := [Unseen_trap,Seen_trap,Secret_door,Entrance_to_store];
	light_set   := [Seen_trap,Rubble,Open_door,Closed_door,Up_staircase,
			Down_staircase,Up_steep_staircase,Down_steep_staircase,
			Secret_door,Entrance_to_store];
	water_set   := [16,17,18];
	earth_set   := [1,2,4,5,6,7];
	float_set   := [arrow,lamp_or_torch,bow_crossbow_or_sling,boots,
			gloves_and_gauntlets,cloak,soft_armor,scroll1,scroll2,
			potion1,potion2,flask_of_oil,food,magic_book,
			prayer_book,song_book];
	stable_set  := [chest,spike,hard_armor];
	slow_set    := [hafted_weapon,pole_arm,sword,dagger,pick_or_shovel,
			maul,helm,gem_helm,shield,valuable_metal];
 
	{ Descriptive phrases						}
	colors	:=   ('Amber','Azure','Blue','Blue Speckled','Blue Spotted',
		      'Black','Black Speckled','Black Spotted',
		      'Brown','Brown Speckled','Brown Spotted',
		      'Bubbling',
		      'Chartreuse','Clear','Cloudy',
		      'Copper','Copper Spotted','Crimson','Cyan',
		      'Dark Blue','Dark Green','Dark Red','Ecru',
		      'Gold','Gold Spotted',
		      'Green','Green Speckled','Green Spotted',
		      'Grey','Grey Spotted','Hazy','Indigo',
		      'Light Blue','Light Green','Magenta','Metallic Blue',
		      'Metallic Red','Metallic Green','Metallic Purple',
		      'Misty',
		      'Orange','Orange Speckled','Orange Spotted',
		      'Pink','Pink Speckled',
		      'Plaid','Puce','Purple','Purple Speckled',
		      'Purple Spotted','Red','Red Speckled','Red Spotted',
		      'Silver','Silver Speckled','Silver Spotted','Smokey',
		      'Tan','Tangerine','Topaz','Turquoise',
		      'Violet','Vermilion','White','White Speckled',
		      'White Spotted','Yellow'
		     );
	mushrooms:=   ('Blue','Black','Brown','Copper','Crimson',
		      'Dark blue','Dark green','Dark red','Gold',
		      'Green','Grey','Light Blue','Light Green',
		      'Orange','Pink','Plaid','Purple','Red','Tan',
		      'Turquoise','Violet','White','Yellow',
		      'Wrinkled','Wooden','Slimey','Speckled',
		      'Spotted','Furry'
		     );
	woods	:=   ('Applewood','Ashen','Aspen','Avocado wood',
		      'Balsa','Banyan','Birch','Cedar','Cherrywood',
		      'Cinnibar','Cottonwood','Cypress','Dogwood',
		      'Driftwood','Ebony','Elm wood','Eucalyptus',
		      'Grapevine','Hawthorn','Hemlock','Hickory',
		      'Iron wood','Juniper','Locust','Mahogany',
		      'Magnolia','Manzanita','Maple','Mulberry',
		      'Oak','Pecan','Persimmon','Pine','Redwood',
		      'Rosewood','Spruce','Sumac','Sycamore','Teak',
		      'Walnut','Zebra wood'
		     );
	metals	:=   ('Aluminium','Bone','Brass','Bronze','Cast Iron',
		      'Chromium','Copper','Gold','Iron','Lead',
		      'Magnesium','Molybdenum','Nickel',
		      'Pewter','Rusty','Silver','Steel','Tin',
		      'Titanium','Tungsten','Zirconium','Zinc',
		      'Aluminium Plated','Brass Plated','Copper Plated',
		      'Gold Plated','Nickel Plated','Silver Plated',
		      'Steel Plated','Tin Plated','Zinc Plated','Uranium'
		     );
	horns	:=   ('Bag Pipes','Bugle','Conch Shell','Fife','Harmonica',
		      'Horn','Picolo','Pipes','Recorder','Reed','Trumpet',
		      'Tuba','Whistle');
	rocks	:=   ('Amber','Agate','Alexandrite','Amethyst','Antlerite',
		      'Aquamarine','Argentite','Azurite','Beryl','Bloodstone',
		      'Calcite','Carnelian','Coral','Corundum','Cryolite',
		      'Diamond','Diorite','Emerald','Flint','Fluorite',
		      'Gabbro','Garnet','Granite','Gypsum','Hematite','Jade',
		      'Jasper','Kryptonite','Lapus lazuli','Limestone',
		      'Malachite','Manganite','Marble','Mica','Moonstone',
		      'Neptunite','Obsidian','Onyx','Opal','Pearl','Pyrite',
		      'Quartz','Quartzite','Rhodonite','Rhyolite','Ruby',
		      'Sapphire','Sphalerite','Staurolite','Tiger eye','Topaz',
		      'Turquoise','Zircon'
		     );
	amulets :=   ('Birch','Cedar','Dogwood','Driftwood',
		      'Elm wood','Hemlock','Hickory','Mahogany',
		      'Maple','Oak','Pine','Redwood','Rosewood',         
		      'Walnut','Aluminium','Bone','Brass','Bronze',
		      'Copper','Iron','Lead','Nickel','Agate','Amethyst',
		      'Diamond','Emerald','Flint','Garnet',
		      'Jade','Obsidian','Onyx','Opal','Pearl','Quartz',
		      'Ruby','Saphire','Tiger eye','Topaz','Turquoise'
		     );
	cloths	  := ('Burlap','Cotton','Wool','Sack-cloth','Rabbit-fur',
		      'Lizard-skin','Goat-skin');
	syllables := ('a','ab','ag','aks','ala','an','ankh','app',
		      'arg','arze','ash','aus','ban','bar','bat','bek',
		      'bie','bin','bit','bjor','blu','brd','bu',
		      'byt','comp','con','cos','cre','dalf','dan',
		      'den','doe','dok','eep','el','eng','er','ere','erk',
		      'esh','evs','fa','fid','for','fri','fu','gan',
		      'gar','glen','gop','gre','ha','he','hyd','i',
		      'ing','ion','ip','ish','it','ite','iv','jo',
		      'kho','kli','klis','la','lech','man','mar',
		      'me','mi','mic','mik','mon','mung','mur','naed',
		      'neg','nep','ner','nes','nis','nih','nin','o','od',
		      'ood','ook','oook','org','orn','ox','oxy','pay','pet',
		      'ple','plu','po','pot','prok','re','rea','rhov',
		      'ri','ro','rog','rok','rol','sa','san','sat',
		      'see','sef','seh','shu','si','snd','sne','snik',
		      'sno','so','sol','spam','sri','sta','sun','ta','taf',
		      'tem','ther','ti','tox','trol','tue','turs','u',
		      'ulk','um','un','uni','ur','val','viv','vly',
		      'vom','wah','wed','werg','wex','whon','wlf','x',
		      'yerg','yp','zun'
		     );
 
	{ Used in DESC.INC for replacing the & in descriptions		}
	vowel_set	:= ['a','e','i','o','u','A','E','I','O','U'];
 
	{ Creatures must be defined here				}
	{	See TYPES.INC under creature_type for a complete list
		of all variables for creatures.	 Some of the less obvious
		are explained below.
 
	Area of affect (aaf) :	Max range that creature is able to "notice"
				the player.
 
	Armor Class (AC): difficulty to hit.
 
		CMOVE flags:
Movement.	00000001	Move only to attack
	.	00000002	20% random movement
	.	00000004	40% random movement
	.	00000008	75% random movement
	.	00000010	On = Water-based; Off = Land-based
	.	00000040	Drowns/Suffocates in wrong element
	.	00000300	monster rate in wrong elm't (0=stop,3=full)
Special	+	00004000	Is a 'good' monster (reputation)
	+	00008000	Is a monster that will not normally appear
					(such as Town Guards)
					These can only be summoned by summon
					monster by name.
	+	00010000	Invisible movement
	+	00020000	Move through door
	+	00040000	Move through wall
	+	00080000	Move through creatures
	+	00100000	Picks up objects
	+	00200000	Multiply monster
	+	00400000	Can anchor in water
	+	00800000	Flying creature
Carries =	01000000	Carries objects.
	=	02000000	Carries gold.
	=	04000000	Has 60% of time.
	=	08000000	Has 90% of time.
	=	10000000	1d2 objects/gold.
	=	20000000	2d2 objects/gold.
	=	40000000	4d2 objects/gold.
Special ~	80000000	Win-the-Game creature.
 
		SPELL Flags:
Frequency	00000001    1	  These add up to x.  Then
(1 in x).	00000002    2	  if RANDINT(X) = 1 the
	.	00000004    4	  creature casts a spell.
	.	00000008    8
Spells	=	00000010  Teleport short (blink)
	=	00000020  Teleport long
	=	00000040  Teleport player to monster
	=	00000080  Cause light wound
	=	00000100  Cause serious wound
	=	00000200  Hold person (Paralysis)
	=	00000400  Cause blindness
	=	00000800  Cause confusion
	=	00001000  Cause fear
	=	00002000  Summon monster
	=	00004000  Summon undead
	=	00008000  Slow Person
	=	00010000  Drain Mana
	=	00020000  Shadow Breath/Orb of Draining
	=	00040000  Not Used
Breaths +	00080000  Breath Lightning
	+	00100000  Breath Gas
	+	00200000  Breath Acid
	+	00400000  Breath Frost
	+	00800000  Breath Fire
	=	01000000  Casts Illusion
	=	02000000  Summon Demon
	=	04000000  Summon Multiplying Monster (heh heh)
	=	08000000  Gaze from distance for petrification
	.	80000000  makes no casting 1 in x (instead of casting 1 in x)
 
		CDEFENSE flags:
		0001	Hurt by Slay Dragon.
		0002	Hurt by Slay Monster.
		0004	Hurt by Slay Evil.
		0008	Hurt by Slay Undead.
		0010	Hurt by Frost.
		0020	Hurt by Fire.
		0040	Hurt by Poison.
		0080	Hurt by Acid.
		0100	Hurt by Light-Wand.
		0200	Hurt by Stone-to-Mud.
		0400	Hurt by Slay Demon.
		0800	Not used.
		1000	Cannot be charmed or slept.
		2000	Can be seen with infra-vision.
		4000	Max Hit points.
		8000	Regenerates.
 
	Sleep (sleep)	:	A measure in turns of how fast creature
				will notice player (on the average).
									
	Experience	:	Base Experience for slaying the creature.

	Speed		:	Base Monster Speed.

	Character Rep.	:	The character used on the map.
	
	Hit points:	'#1d#2' where #2 is the range of each roll and
			#1 is the number of added up rolls to make.
			Example: a creature with 5 eight-sided hit die
			is given '5d8'.
 
		Attack types:
		1	Normal attack
		2	Lose Strength
		3	Confusion attack
		4	Fear attack
		5	Fire attack
		6	Acid attack
		7	Cold attack
		8	Lightning attack
		9	Corrosion attack
		10	Blindness attack
		11	Paralysis attack
		12	Steal Money
		13	Steal Object
		14	Poison
		15	Lose dexterity
		16	Lose constitution
		17	Lose intelligence
		18	Lose wisdom
		19	Lose experience
		20	Aggravation
		21	Disenchants
		22	Eats food
		23	Eats light
		24	Eats charges
		25	Lose charisma
		26	Petrification
		27	POISON poison
		99	Blank
 
		Attack descriptions:
		1	hits you.
		2	bites you.
		3	claws you.
		4	stings you.
		5	touches you.
		6	kicks you.
		7	gazes at you.
		8	breathes on you.
		9	spits on you.
		10	makes a horrible wail.
		11	embraces you.
		12	crawls on you.
		13	releases a cloud of spores.
		14	begs you for money.
		15	You've been slimed.
		16	crushes you.
		17	tramples you.
		18	drools on you.
		19	insults you.
		23	plays a song.
		24	kisses you.
		25	gores you.
		26	"bovine"s you.
		27	electrocutes you.
		28	inks you.
		29	entangles you.
		30	blood sucks you.
		31	goes for your throat.
		32	blows bubbles at you.
		33	squawks at you.
		34	pecks at you.
		35	barks at you.
		36	rubs against your leg.
		99	is repelled.

 
	Example:  For a creature which claws twice for 1d6, then stings for
		  2d4 and loss of dex you would use:
			'1 3 2-1d6|15 4 2d4'

	Level	: Base level the creature is found on.

	moo.monst in dua2:[sa65] has bovine monsters }

	blank_monster	:= (0,0,0,0,0,0,0,0,0,false,false,false); 

















