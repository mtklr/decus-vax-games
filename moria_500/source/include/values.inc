  value
 
        wizard := false;
        used_line  := (22 of false);
        death      := false;
        total_winner := false;
        stat_column := 1;
        turn  := 0;
        pclass := 0;
        print_stat := 0;
 
{ For the testing of bits }
        bit_array := (
{ Bit #1 }     %X'00000001',
{ Bit #2 }     %X'00000002',
{ Bit #3 }     %X'00000004',
{ Bit #4 }     %X'00000008',
{ Bit #5 }     %X'00000010',
{ Bit #6 }     %X'00000020',
{ Bit #7 }     %X'00000040',
{ Bit #8 }     %X'00000080',
{ Bit #9 }     %X'00000100',
{ Bit #10 }    %X'00000200',
{ Bit #11 }    %X'00000400',
{ Bit #12 }    %X'00000800',
{ Bit #13 }    %X'00001000',
{ Bit #14 }    %X'00002000',
{ Bit #15 }    %X'00004000',
{ Bit #16 }    %X'00008000',
{ Bit #17 }    %X'00010000',
{ Bit #18 }    %X'00020000',
{ Bit #19 }    %X'00040000',
{ Bit #20 }    %X'00080000',
{ Bit #21 }    %X'00100000',
{ Bit #22 }    %X'00200000',
{ Bit #23 }    %X'00400000',
{ Bit #24 }    %X'00800000',
{ Bit #25 }    %X'01000000',
{ Bit #26 }    %X'02000000',
{ Bit #27 }    %X'04000000',
{ Bit #28 }    %X'08000000',
{ Bit #29 }    %X'10000000',
{ Bit #30 }    %X'20000000',
{ Bit #31 }    %X'40000000',
{ Bit #32 }    %X'80000000');
 
        { Operating hours for Moria
               X = Open; . = Closed  }
        days    :=(           
                'SUN:........................|',
                'MON:........................|',
                'TUE:........................|',
                'WED:........................|',
                'THU:........................|',
                'FRI:........................|',
                'SAT:........................|');
 
        closing_flag := 0;
 
        { VALUES FOR FLOOR TYPES }
        blank_floor:= (0,0,0,false,false,false,false);
        dopen_floor  := (  1,true ); { Dark open floor }
        lopen_floor  := (  2,true ); { Light open floor }
        corr_floor1  := (  4,true ); { Corridor open floor }
        corr_floor2  := (  5,true ); { Room junction marker }
        corr_floor3  := (  6,true ); { Door type floor }
        corr_floor4  := (  7,false); { Secret door type floor
          FLOOR VALUES 8 AND 9 ARE USED IN GENERATE }
        rock_wall1   := ( 10,false); { Granite rock wall }
        rock_wall2   := ( 11,false); { Magma rock wall }
        rock_wall3   := ( 12,false); { Quartz rock wall }
        boundry_wall := ( 15,false); { Indestructable wall }
 
        { PLAYER RECORD IS SPECIAL }
        py              :=      (    
        (' ',' ',' ',' ',' ',
         0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,
         ('','','','','')),(0,0,0,0,0,0,0,0,0,0,0,0),
        (0,0,0,0,0,5000,2,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,
         false,false,false,false,false,false,false,false,false,
         false,false,false,false,false,false,false,false,false));
 
        bare_hands := '1d2';
        acc_exp    := 0.0;
 
 { Each character class has a list of spells they can use.  In cases the
   entire array is blank }
                           
        magic_spell :=  ((               { Warrior }
 ('' ,99,99, 0, 0,false),('' ,99,99, 0, 0,false),
 ('' ,99,99, 0, 0,false),('' ,99,99, 0, 0,false),
 ('' ,99,99, 0, 0,false),('' ,99,99, 0, 0,false),
 ('' ,99,99, 0, 0,false),('' ,99,99, 0, 0,false),
 ('' ,99,99, 0, 0,false),('' ,99,99, 0, 0,false),
 ('' ,99,99, 0, 0,false),('' ,99,99, 0, 0,false),
 ('' ,99,99, 0, 0,false),('' ,99,99, 0, 0,false),
 ('' ,99,99, 0, 0,false),('' ,99,99, 0, 0,false),
 ('' ,99,99, 0, 0,false),('' ,99,99, 0, 0,false),
 ('' ,99,99, 0, 0,false),('' ,99,99, 0, 0,false),
 ('' ,99,99, 0, 0,false),('' ,99,99, 0, 0,false),
 ('' ,99,99, 0, 0,false),('' ,99,99, 0, 0,false),
 ('' ,99,99, 0, 0,false),('' ,99,99, 0, 0,false),
 ('' ,99,99, 0, 0,false),('' ,99,99, 0, 0,false),
 ('' ,99,99, 0, 0,false),('' ,99,99, 0, 0,false),
 ('' ,99,99, 0, 0,false)),
                                        (   { Mage }
 ('Magic Missle' , 1, 1,5, 22,false),
 ('Detect Monsters' , 1, 1,5, 27,false),
 ('Phase Door' , 1, 2,4, 22,false),
 ('Light Area' , 1, 2,4, 25,false),
 ('Cure Light Wounds' , 3, 3,8, 25,false),
 ('Find Hidden Traps/Doors', 3, 3,6, 45,false),
 ('Stinking Cloud' , 3, 4,8, 27,false),
 ('Confusion' , 3, 4,6, 32,false),
 ('Lightning Bolt' , 5, 4, 25, 32,false),
 ('Trap/Door Destruction' , 5, 5, 30, 37,false),
 ('Sleep I' , 5, 5, 20, 32,false),
 ('Cure Poison' , 5, 5, 25, 37,false),
 ('Teleport Self' , 7, 6, 35, 37,false),
 ('Remove Curse' , 7, 6, 40, 50,false),
 ('Frost Bolt' , 7, 6, 50, 40,false),
 ('Turn Stone to Mud' , 9, 7, 75, 44,false),
 ('Identify' ,9, 7, 75, 95,false),
 ('Recharge Item I' , 9, 7, 90, 70,false),
 ('Sleep II' , 9, 7, 75, 45,false),
 ('Polymorph Other' ,11, 7,100, 45,false),
 ('Create Food' , 11, 7, 75, 50,false),
 ('Sleep III' ,13, 7, 90, 50,false),
 ('Fire Bolt' ,15, 9,100, 50,false),
 ('Slow Monster' ,17, 9,125, 50,false),
 ('Frost Ball' ,19,12,150, 52,false),
 ('Recharge Item II' ,21,12,175, 85,false),
 ('Teleport Other' ,23,12,200, 60,false),
 ('Haste Self' ,25,12,250, 60,false),
 ('Fire Ball' ,29,18,350, 60,false),
 ('Word of Destruction' ,33,21,500, 75,false),
 ('Genocide' ,37,25,800, 95,false)),
                                       (   { Priest }
 ('Detect Evil' , 1, 1,3, 15,false),
 ('Cure Light Wounds' , 1, 2,4, 25,false),
 ('Bless' , 1, 2,3, 25,false),
 ('Remove Fear' ,1, 2,3, 25,false),
 ('Call Light' , 3, 2,6, 25,false),
 ('Find Traps' , 3, 3,8, 30,false),
 ('Detect Doors/Stairs' , 3, 3,8, 30,false),
 ('Slow Poison' , 3, 3, 10, 27,false),
 ('Blind Creature' , 5, 4, 16, 27,false),
 ('Portal' , 5, 4, 20, 27,false),
 ('Cure Medium Wounds' , 5, 4, 20, 30,false),
 ('Chant' , 5, 5, 20, 30,false),
 ('Sanctuary' , 7, 5, 30, 30,false),
 ('Create Food' , 7, 5, 30, 40,false),
 ('Remove Curse' , 7, 6, 35, 40,false),
 ('Resist Heat and Cold' , 7, 7, 35, 40,false),
 ('Neutralize Poison' , 9, 6, 40, 35,false),
 ('Orb of Draining' , 9, 7, 40, 35,false),
 ('Cure Serious Wounds' , 9, 7, 40, 40,false),
 ('Sense Invisible' ,11, 8, 40, 40,false),
 ('Protection from Evil' ,11, 8, 50, 40,false),
 ('Earthquake' ,11, 9, 60, 50,false),
 ('Sense Surroundings' ,13,10, 60, 45,false),
 ('Cure Critical Wounds' ,13,11, 65, 45,false),
 ('Turn Undead' ,15,12, 80, 45,false),
 ('Prayer' ,15,14, 90, 45,false),
 ('Dispell Undead' ,17,14,125, 50,false),
 ('Heal' ,21,16,150, 55,false),
 ('Dispell Evil' ,25,20,300, 60,false),
 ('Glyph of Warding' ,33,24,500, 75,false),
 ('Holy Word' ,39,32,800, 95,false)),
                                        (  { Rogue }
 ('' ,99,99, 0, 0,false),('' ,99,99, 0, 0,false),
 ('' ,99,99, 0, 0,false),('' ,99,99, 0, 0,false),
 ('' ,99,99, 0, 0,false),('' ,99,99, 0, 0,false),
 ('' ,99,99, 0, 0,false),('' ,99,99, 0, 0,false),
 ('' ,99,99, 0, 0,false),('' ,99,99, 0, 0,false),
 ('' ,99,99, 0, 0,false),('' ,99,99, 0, 0,false),
 ('' ,99,99, 0, 0,false),('' ,99,99, 0, 0,false),
 ('' ,99,99, 0, 0,false),('' ,99,99, 0, 0,false),
 ('' ,99,99, 0, 0,false),('' ,99,99, 0, 0,false),
 ('' ,99,99, 0, 0,false),('' ,99,99, 0, 0,false),
 ('' ,99,99, 0, 0,false),('' ,99,99, 0, 0,false),
 ('' ,99,99, 0, 0,false),('' ,99,99, 0, 0,false),
 ('' ,99,99, 0, 0,false),('' ,99,99, 0, 0,false),
 ('' ,99,99, 0, 0,false),('' ,99,99, 0, 0,false),
 ('' ,99,99, 0, 0,false),('' ,99,99, 0, 0,false),
 ('' ,99,99, 0, 0,false)),
                                        ( { Ranger }
 ('Magic Missle' , 3, 1,6, 30,false),
 ('Detect Monsters' , 3, 2,6, 35,false),
 ('Phase Door' , 3, 2,8, 35,false),
 ('Light Area' , 5, 3,8, 35,false),
 ('Cure Light Wounds' , 5, 3,8, 40,false),
 ('Find Hidden Traps/Doors' , 5, 4, 10, 45,false),
 ('Stinking Cloud' , 7, 6, 24, 40,false),
 ('Confusion' , 7, 6, 20, 40,false),
 ('Lightning Bolt' , 9, 7, 30, 40,false),
 ('Trap/Door Destruction' , 9, 8, 30, 45,false),
 ('Sleep I' ,11, 8, 40, 40,false),
 ('Cure Poison' ,11, 9, 40, 45,false),
 ('Teleport Self' ,13,10, 50, 45,false),
 ('Remove Curse' ,13,11, 50, 55,false),
 ('Frost Bolt' ,15,12, 60, 50,false),
 ('Turn Stone to Mud' ,15,13, 60, 50,false),
 ('Identify',17,25, 80, 95,false),
 ('Recharge Item I' ,17,17, 70, 90,false),
 ('Sleep II' ,21,17, 70, 55,false),
 ('Polymorph Other' ,21,19, 70, 60,false),
 ('Create Food' ,23,17, 60, 55,false),
 ('Sleep III' ,23,20, 80, 60,false),
 ('Fire Bolt' ,25,20, 80, 60,false),
 ('Slow Monster' ,25,21, 80, 65,false),
 ('Frost Ball' ,27,21, 90, 65,false),
 ('Recharge Item II' ,29,23, 90, 95,false),
 ('Teleport Other' ,31,25,100, 70,false),
 ('Haste Self' ,33,25,150, 75,false),
 ('Fire Ball' ,35,25,200, 80,false),
 ('Word of Destruction' ,37,30,500, 95,false),
 ('' ,99,99,0,0,false)),
                                        ( { Paladin }
 ('Detect Evil' , 1, 1,4, 30,false),
 ('Cure Light Wounds' , 2, 2,8, 35,false),
 ('Bless' , 3, 3, 12, 35,false),
 ('Remove Fear' , 5, 3, 20, 35,false),
 ('Call Light' , 5, 4, 20, 35,false),
 ('Find Traps' , 7, 5, 25, 40,false),
 ('Detect Doors/Stairs' , 7, 5, 25, 40,false),
 ('Slow Poison' , 9, 7, 30, 40,false),
 ('Blind Creature' , 9, 7, 30, 40,false),
 ('Portal' , 9, 8, 30, 40,false),
 ('Cure Medium Wounds' ,11, 9, 40, 40,false),
 ('Chant' ,11,10, 40, 45,false),
 ('Sanctuary' ,11,10, 40, 45,false),
 ('Create Food' ,13,10, 50, 45,false),
 ('Remove Curse' ,13,11, 50, 45,false),
 ('Resist Heat and Cold' ,15,13, 60, 45,false),
 ('Neutralize Poison' ,15,15, 60, 50,false),
 ('Orb of Draining' ,17,15, 70, 50,false),
 ('Cure Serious Wounds' ,17,15, 70, 50,false),
 ('Sense Invisible' ,19,15, 75, 50,false),
 ('Protection from Evil' ,19,15, 75, 50,false),
 ('Earthquake' ,21,17, 80, 50,false),
 ('Sense Surroundings' ,23,17, 80, 50,false),
 ('Cure Critical Wounds' ,25,20, 80, 50,false),
 ('Turn Undead' ,27,21, 90, 50,false),
 ('Prayer' ,29,22, 95, 50,false),
 ('Dispell Undead' ,31,24,100, 60,false),
 ('Heal' ,33,28,125, 60,false),
 ('Dispell Evil' ,35,32,150, 70,false),
 ('Glyph of Warding' ,37,36,200, 90,false),
 ('Holy Word' ,39,38,500, 95,false)),

 			( {Consultant}
 ('Magic Missle' , 1, 1,5, 22,false),
 ('Detect Monsters' , 1, 1,5, 27,false),
 ('Phase Door' , 1, 2,4, 22,false),
 ('Light Area' , 1, 2,4, 25,false),
 ('Cure Light Wounds' , 3, 3,8, 25,false),
 ('Find Hidden Traps/Doors', 3, 3,6, 45,false),
 ('Stinking Cloud' , 3, 4,8, 27,false),
 ('Confusion' , 3, 4,6, 32,false),
 ('Lightning Bolt' , 5, 4, 25, 32,false),
 ('Trap/Door Destruction' , 5, 5, 30, 37,false),
 ('Sleep I' , 5, 5, 20, 32,false),
 ('Cure Poison' , 5, 5, 25, 37,false),
 ('Teleport Self' , 7, 6, 35, 37,false),
 ('Remove Curse' , 7, 6, 40, 50,false),
 ('Frost Bolt' , 7, 6, 50, 40,false),
 ('Turn Stone to Mud' , 9, 7, 75, 44,false),
 ('Identify' ,9, 7, 75, 95,false),
 ('Recharge Item I' , 9, 7, 90, 70,false),
 ('Sleep II' , 9, 7, 75, 45,false),
 ('Polymorph Other' ,11, 7,100, 45,false),
 ('Create Food' , 11, 7, 75, 50,false),
 ('Sleep III' ,13, 7, 90, 50,false),
 ('Fire Bolt' ,15, 9,100, 50,false),
 ('Slow Monster' ,17, 9,125, 50,false),
 ('Frost Ball' ,19,12,150, 52,false),
 ('Recharge Item II' ,21,12,175, 85,false),
 ('Teleport Other' ,23,12,200, 60,false),
 ('Haste Self' ,25,12,250, 60,false),
 ('Fire Ball' ,29,18,350, 60,false),
 ('Word of Destruction' ,33,21,500, 75,false),
 ('Genocide' ,37,25,800, 95,false)),


 			( {Consultant}
 ('Magic Missle' , 1, 1,5, 22,false),
 ('Detect Monsters' , 1, 1,5, 27,false),
 ('Phase Door' , 1, 2,4, 22,false),
 ('Light Area' , 1, 2,4, 25,false),
 ('Cure Light Wounds' , 3, 3,8, 25,false),
 ('Find Hidden Traps/Doors', 3, 3,6, 45,false),
 ('Stinking Cloud' , 3, 4,8, 27,false),
 ('Confusion' , 3, 4,6, 32,false),
 ('Lightning Bolt' , 5, 4, 25, 32,false),
 ('Trap/Door Destruction' , 5, 5, 30, 37,false),
 ('Sleep I' , 5, 5, 20, 32,false),
 ('Cure Poison' , 5, 5, 25, 37,false),
 ('Teleport Self' , 7, 6, 35, 37,false),
 ('Remove Curse' , 7, 6, 40, 50,false),
 ('Frost Bolt' , 7, 6, 50, 40,false),
 ('Turn Stone to Mud' , 9, 7, 75, 44,false),
 ('Identify' ,9, 7, 75, 95,false),
 ('Recharge Item I' , 9, 7, 90, 70,false),
 ('Sleep II' , 9, 7, 75, 45,false),
 ('Polymorph Other' ,11, 7,100, 45,false),
 ('Create Food' , 11, 7, 75, 50,false),
 ('Sleep III' ,13, 7, 90, 50,false),
 ('Fire Bolt' ,15, 9,100, 50,false),
 ('Slow Monster' ,17, 9,125, 50,false),
 ('Frost Ball' ,19,12,150, 52,false),
 ('Recharge Item II' ,21,12,175, 85,false),
 ('Teleport Other' ,23,12,200, 60,false),
 ('Haste Self' ,25,12,250, 60,false),
 ('Fire Ball' ,29,18,350, 60,false),
 ('Word of Destruction' ,33,21,500, 75,false),
 ('Genocide' ,37,25,800, 95,false)));




 
        { For Create Food spell use... }
 mush := ('& pint~ of fine grade mush' ,80,',',%X'00000000',1500, 0, 308, 1, 1,
           0, 0, 0, 0, '1d1' , 1);
 
        char_row := 0;
        char_col := 0;
 
        { Initialize player generation variables }
        sex_type  := 'FemaleMale  ';
 
        {Race   STR,INT,WIS,DEX,CON,CHR,
                Ages, heights, and weights,
                Racial Bases for: dis,srh,stl,fos,bth,bthb,bsav,hitdie,
                infra, choice-classes }
{ Class choice bit string goes (from MSB to LSB): Consultant2, Consultant,
  Paladin, Rogue, Priest, Mage, Rogue, Fighter }
 
        race :=  (            
             ('Human',0,0,0,0,0,0,14,6,72,6,180,25,66,4,120,20,1.00,
                          0,0,0,0,0,0,0, 10,0,%B'00111111'),
             ('Half-Elf',-1,1,0,1,-1,1,24,16,66,6,130,15,62,6,100,10,1.10,
                          2,6,1, -1,0,5,3,9,3,%B'00111111'),
             ('Elf',-1,2,1,1,-2,1,75,75,60,4,100,6,54,4,80,6,1.20,
                          5,8,1, -2, -5, 15,6,8,4,%B'00011111'),
             ('Halfling',-2,2,1,3,1,1,21,12,36,3,60,3,33,3,50,3,1.10,
                         15, 12,4, -5,-10, 20, 18,6,4,%B'00001011'),
             ('Gnome',-1,2,0,2,1,-2,50,40,42,3,90,6,39,3,75,3,1.25,
                         10,6,3, -3, -8, 12, 12,7,3,%B'00001111'),
             ('Dwarf',2,-3,1,-2,2,-3,35,15,48,3,150,10,46,3,120,10,1.20,
                          2,7,0,0, 15,0,9,9,5,%B'00000101'),
             ('Half-Orc',2,-1,0,0,1,-4,11,4,66,1,150,5,62,1,120,5,1.10,
                         -3,0, -1,3, 12, -5, -3, 10,3,%B'00001101'),
             ('Half-Troll',4,-4,-2,-4,3,-6,20,10,96,10,300,50,84,8,260,40,1.20,
                         -5, -1, -2,5, 20,-10, -8, 12,3,%B'00000101'));
 
{ Buying and selling adjustments for character race VS store owner race }
            
        rgold_adj :=  (
               {  Hum,HfE,Elf,Hob,Gno,Dwa,HfO,HfT}
{Human      }  ( 0.00, 0.05, 0.05, 0.10, 0.13, 0.15, 0.20, 0.25),
{Half-Elf   }  ( 0.10, 0.00, 0.00, 0.05, 0.10, 0.20, 0.25, 0.30),
{Elf        }  ( 0.10, 0.05, 0.00, 0.05, 0.10, 0.20, 0.25, 0.30),
{Halfling     }  ( 0.15, 0.10, 0.05,-0.05, 0.05, 0.10, 0.15, 0.30),
{Gnome      }  ( 0.15, 0.15, 0.10, 0.05,-0.05, 0.10, 0.15, 0.30),
{Dwarf      }  ( 0.15, 0.20, 0.20, 0.10, 0.10,-0.05, 0.25, 0.35),
{Half-Orc   }  ( 0.15, 0.20, 0.25, 0.15, 0.15, 0.30, 0.10, 0.15),
{Half-Troll }  ( 0.10, 0.15, 0.15, 0.10, 0.10, 0.30, 0.10, 0.10));
 
{ Classes...}
        class := (
('Warrior'   ,0.00,18, 20, 12, 1, 40, 65, 50,20, 4,-1,-1, 1, 2,-1, false,false, false,0,0),
('Mage'      ,0.30,2, 30, 15, 2, 35, 35, 25,30,-4, 2, 0, 1,-2, 0, false, true ,false,0,0),
('Priest'    ,0.10,4, 25, 15, 2, 35, 50, 40,30, 0,-1, 2,-1, 1, 1, true , false,false,0,0),
('Rogue'     ,0.00,6, 45, 30, 4, 18, 60, 65,25, 2, 1,-1, 3, 1,-1, false, false,false,0,0),
('Ranger'    ,0.40,4, 30, 20, 3, 25, 55, 70,25, 1, 1, 0, 1, 1, 1, false, true ,false,0,0),
('Paladin'   ,0.35,6, 15, 12, 1, 40, 65, 45,20, 2,-1, 1, 0, 1, 2, true , false, false,0,0),
('Consultant',0.00,8, 20, 12, 1, 40, 65, 50,20, 4,-1,-1, 1, 2,-1, false, false,true,1,92 ),
('Consultant2',0.00,8, 20, 12, 1, 40, 65, 50,20, 4,-1,-1, 1, 2,-1, false,false, true ,2,93));
 
{ Class titles for different levels }
        player_title := (
{ WARRIOR }
('Novice','Veteran','Veteran','Veteran','Warrior','Warrior','Warrior',
'Swordsman','Swordsman','Swordsman','Hero','Swashbuckler','Myrmidon',
'Champion','Champion','Champion','Superhero','Knight','Superior Knt',
'Gallant Knt','Knt Errent','Keeper','Protector','Defender','Warder',
'Guardian Knt','Chevalier','Justiciar','Lord','Lord','Lord','Lord','Lord',
'Lord','Lord','Lord','Lord','Lord Gallant','Lord Keeper','Lord Noble',
'Lord Noble','Lord Noble','Lord Noble','Lord Noble','Lord Noble','Lord Noble'),
{ MAGE }
('Novice','Apprentice','Trickster','Trickster','Trickster','Cabalist',
'Cabalist','Cabalist','Visionist','Phantasmist','Shadowist','Spellbinder',
'Illusionist','Evoker','Evoker','Evoker','Evoker','Conjurer','Theurgist',
'Thaumaturer','Magician','Enchanter','Warlock','Sorcerer','Necromancer',
'Mage','Mage','Mage','Mage','Mage','Wizard','Wizard','Wizard','Wizard',
'Wizard','Wizard','Wizard','Wizard','Wizard','Wizard Lord','Wizard Lord',
'Wizard Lord','Wizard Lord','Wizard Lord','Wizard Lord','Wizard Lord'),
{ PRIESTS }
('Believer','Acolyte','Acolyte','Acolyte','Adept','Adept','Adept','Priest',
'Priest','Priest','Priest','Priest','Priest','Priest','Priest',
'Priest','Curate','Curate','Curate','Curate','Curate','Curate','Curate',
'Curate','Curate','Canon','Canon','Canon','Canon','Canon',
'Low Lama','Lama','Lama','Lama','High Lama','Great Lama','Patriarch',
'High Priest','Great Priest','Noble Priest','Noble Priest','Noble Priest',
'Noble Priest','Noble Priest','Noble Priest','Noble Priest'),
{ ROGUES }
('Apprentice','Footpad','Cutpurse','Robber','Burglar','Filcher','Sharper',
'Magsman','Common Rogue','Rogue','Rogue','Rogue','Rogue','Rogue','Rogue',
'Rogue','Rogue','Rogue','Master Rogue','Expert Rogue','Senior Rogue',
'Chief Rogue','Prime Rogue','Low Thief','Thief','Thief','Thief',
'Thief','Thief','Thief','Thief','Thief','Thief','High Thief','Master Thief',
'Executioner','Low Assassin','Assassin','HighAssassin','Guildsmaster',
'Guildsmaster','Guildsmaster','Guildsmaster','Guildsmaster','Guildsmaster',
'Guildsmaster'),
{ RANGERS }
('Runner','Runner','Runner','Strider','Strider','Strider','Scout','Scout',
'Scout','Scout','Scout','Courser','Courser','Courser','Courser',
'Courser','Tracker','Tracker','Tracker','Tracker','Tracker','Tracker',
'Tracker','Tracker','Tracker','Guide','Guide','Guide','Guide','Guide','Guide',
'Guide','Guide','Guide','Pathfinder','Pathfinder','Pathfinder','Ranger',
'High Ranger','Ranger Lord','Ranger Lord','Ranger Lord','Ranger Lord',
'Ranger Lord','Ranger Lord','Ranger Lord'),
{ PALADINS }
('Gallant','Keeper','Keeper','Keeper','Keeper','Keeper','Keeper','Keeper',
'Keeper','Keeper','Protector','Protector','Protector','Protector','Protector',
'Protector','Protector','Protector','Defender','Defender','Defender',
'Defender','Defender','Defender','Defender','Defender','Warder','Warder',
'Warder','Warder','Warder','Warder','Warder','Warder','Warder','Gauardian',
'Chevalier','Justiciar','Paladin','High Lord','High Lord','High Lord',
'High Lord','High Lord','High Lord','High Lord'),
{TEST}
('Novice','Veteran','Veteran','Veteran','Warrior','Warrior','Warrior',
'Swordsman','Swordsman','Swordsman','Hero','Swashbuckler','Myrmidon',
'Champion','Champion','Champion','Superhero','Knight','Superior Knt',
'Gallant Knt','Knt Errent','Keeper','Protector','Defender','Warder',
'Guardian Knt','Chevalier','Justiciar','Lord','Lord','Lord','Lord','Lord',
'Lord','Lord','Lord','Lord','Lord Gallant','Lord Keeper','Lord Noble',
'Lord Noble','Lord Noble','Lord Noble','Lord Noble','Lord Noble','Lord Noble'),

('Novice','Veteran','Veteran','Veteran','Warrior','Warrior','Warrior',
'Swordsman','Swordsman','Swordsman','Hero','Swashbuckler','Myrmidon',
'Champion','Champion','Champion','Superhero','Knight','Superior Knt',
'Gallant Knt','Knt Errent','Keeper','Protector','Defender','Warder',
'Guardian Knt','Chevalier','Justiciar','Lord','Lord','Lord','Lord','Lord',
'Lord','Lord','Lord','Lord','Lord Gallant','Lord Keeper','Lord Noble',
'Lord Noble','Lord Noble','Lord Noble','Lord Noble','Lord Noble','Lord Noble')

);

{Base experience levels, may be adjusted up for race and/or class}
        player_exp :=   (
10,25,45,70,100,150,220,310,410,520,650,900,1200,1600,2000,2600,3300,4100,5000,
6500,8000,10500,14000,19000,25000,33000,43000,58000,78000,110000,175000,260000,
360000,510000,750000,1100000,1300000,1600000,2000000,2500000,3000000,3500000,
4000000,4500000,5000000,9999999 );
{Base experience levels, may be adjusted up for race and/or class
        player_exp :=   (
     10, 25, 45, 70,100,140,200,280,380, 500,
    650,850, 1100, 1400, 1800, 2300, 2900, 3600, 4400,5400,
   6800, 8400,10200,12500,17500,25000,35000,50000,75000,100000,
150000,200000, 300000, 400000, 500000, 750000,1500000,2500000,5000000,9999999;}
 
 
{ Background information }
        background := (
('You are the illegitimate and unacknowledged child ', 10, 1, 2,-25),
('You are the illegitimate but acknowledged child ', 20, 1, 2,-15),
('You are one of several children ', 95, 1, 2, -5),
('You are the 1st born child ', 100, 1, 2,0),
('of a Serf.  ', 40, 2, 3, 15),
('of a Yeoman.  ', 65, 2, 3, 30),
('of a Townsman.  ', 80, 2, 3, 40),
('of a Guildsman.  ', 90, 2, 3, 55),
('of a Landed Knight.  ', 96, 2, 3, 70),
('of a Titled Noble.  ', 99, 2, 3, 80),
('of a Royal Blood Line.  ', 100, 2, 3, 90),
('You are the black sheep of the family.  ', 20, 3,50,-30),
('You are a credit to the family.  ', 80, 3,50,5),
('You are a well liked child.  ', 100, 3,50, 10),
('Your mother was a Woods-Elf.  ', 40, 4, 1,0),
('Your father was a Woods-Elf.  ', 75, 4, 1,5),
('Your mother was a Grey-Elf.  ', 90, 4, 1,5),
('Your father was a Grey-Elf.  ', 95, 4, 1, 10),
('Your mother was a High-Elf.  ', 98, 4, 1, 15),
('Your father was a High-Elf.  ', 100, 4, 1, 20),
('You are one of several children ', 60, 7, 8,0),
('You are the only child ', 100, 7, 8,5),
('of a Woods-Elf ', 75, 8, 9,0),
('of a Grey-Elf ', 95, 8, 9,5),
('of a High-Elf ', 100, 8, 9, 10),
('Ranger.  ', 40, 9,54, 30),
('Archer.  ', 70, 9,54, 40),
('Warrior.  ',87, 9,54, 60),
('Mage.  ', 95, 9,54, 75),
('Prince.  ', 99, 9,54, 90),
('King.  ', 100, 9,54, 95),
('You are one of several children of a Halfling ', 85,10,11, -5),
('You are the only child of a Halfling ', 100,10,11,5),
('Gardener.  ', 20,11, 3,5),
('Tavern Owner.  ', 30,11, 3, 30),
('Miller.  ', 40,11, 3, 40),
('Home Owner.  ', 50,11, 3, 50),
('Burglar.  ', 80,11, 3, 60),
('Warrior.  ', 95,11, 3, 65),
('Mage.  ', 100,11, 3, 75),
('Clan Elder.  ', 100,11, 3, 90),
('You are one of several children of a Gnome ', 85,13,14, -5),
('You are the only child of a Gnome ', 100,13,14,5),
('Beggar.  ',20,14, 3,5),
('Bragart.  ', 50,14, 3, 20),
('Prankster.  ', 75,14, 3, 35),
('Warrior.  ', 95,14, 3, 50),
('Mage.  ', 100,14, 3, 75),
('You are one of two children of a Dwarven ', 25,16,17,-10),
('You are the only child of a Dwarven ', 100,16,17,0),
('Thief.  ', 10,17,18, 10),
('Prison Guard.  ', 25,17,18, 25),
('Miner.  ', 75,17,18, 40),
('Warrior.  ', 90,17,18, 60),
('Priest.  ', 99,17,18, 80),
('King.  ', 100,17,18,100),
('You are the black sheep of the family.  ', 15,18,57,-40),
('You are a credit to the family.  ', 85,18,57,0),
('You are a well liked child.  ', 100,18,57,5),
('Your mother was an Orc, but it is unacknowledged. ' , 25,19,20,-25),
('Your father was an Orc, but it is unacknowledged. ' ,100,19,20,-25),
('You are the adopted child ', 100,20, 2,0),
('Your mother was a Cave-Troll ', 30,22,23,-30),
('Your father was a Cave-Troll ', 60,22,23,-25),
('Your mother was a Hill-Troll ', 75,22,23,-20),
('Your father was a Hill-Troll ', 90,22,23,-15),
('Your mother was a Water-Troll ',95,22,23,-10),
('Your father was a Water-Troll ',100,22,23, -5),
('Cook.  ', 5,23,62, 10),
('Warrior.  ', 95,23,62,5),
('Shaman.  ', 99,23,62, 15),
('Clan Chief.  ', 100,23,62, 30),
('You have dark brown eyes, ', 20,50,51,0),
('You have brown eyes, ', 60,50,51,0),
('You have hazel eyes, ', 70,50,51,0),
('You have green eyes, ', 80,50,51,0),
('You have blue eyes, ', 90,50,51,0),
('You have blue-gray eyes, ', 100,50,51,0),
('straight ', 70,51,52,0),
('wavey ', 90,51,52,0),
('curly ', 100,51,52,0),
('black hair, ', 30,52,53,0),
('brown hair, ', 70,52,53,0),
('auburn hair, ', 80,52,53,0),
('red hair, ', 90,52,53,0),
('blonde hair, ', 100,52,53,0),
('and a very dark complexion.', 10,53,-1,0),
('and a dark complexion.', 30,53,-1,0),
('and an average complexion.', 80,53,-1,0),
('and a fair complexion.', 90,53,-1,0),
('and a very fair complexion.', 100,53,-1,0),
('You have light grey eyes, ', 85,54,55,0),
('You have light blue eyes, ', 95,54,55,0),
('You have light green eyes, ', 100,54,55,0),
('straight ', 75,55,56,0),
('wavey ', 100,55,56,0),
('black hair, and a fair complexion.', 75,56,-1,0),
('brown hair, and a fair complexion.', 85,56,-1,0),
('blonde hair, and a fair complexion.',95,56,-1,0),
('silver hair, and a fair complexion.', 100,56,-1,0),
('You have dark brown eyes, ', 99,57,58,0),
('You have glowing red eyes, ', 100,57,58, 10),
('straight ', 90,58,59,0),
('wavey ', 100,58,59,0),
('black hair, ', 75,59,60,0),
('brown hair, ', 100,59,60,0),
('a one foot beard, ', 25,60,61,0),
('a two foot beard, ', 60,60,61,1),
('a three foot beard, ', 90,60,61,3),
('a four foot beard, ', 100,60,61,5),
('and a dark complexion.', 100,61,-1,0),
('You have slime green eyes, ', 60,62,63,0),
('You have puke yellow eyes, ', 85,62,63,0),
('You have blue-bloodshot eyes, ', 99,62,63,0),
('You have glowing red eyes, ', 100,62,63,5),
('dirty ', 33,63,64,0),
('mangy ', 66,63,64,0),
('oily ', 100,63,64,0),
('sea-weed green hair, ', 33,64,65,0),
('bright red hair, ', 66,64,65,0),
('dark purple hair, ', 100,64,65,0),
('and green ',25,65,66,0),
('and blue ', 50,65,66,0),
('and white ',75,65,66,0),
('and black ',100,65,66,0),
('ulcerous skin.', 33,66,-1,0),
('scabby skin.', 66,66,-1,0),
('leprous skin.', 100,66,-1,0));
 
 
{ Treasure related values }
        inven_ctr := 0;
        inven_weight := 0;
        missle_ctr := 0;
        equip_ctr := 0;
        blank_treasure := (' ',0,' ',0,0,0,0,0,0,0,0,0,0,' ',0);
 
{ Gold list (All types of gold and gems are defined here) }
        gold_list := (
('copper', 100, '$',%X'00000000', 0, 3,1,0,0,0,0,0,0, ' ' , 1),
('copper', 100, '$',%X'00000000', 0, 4,2,0,0,0,0,0,0, ' ' , 1),
('copper', 100, '$',%X'00000000', 0, 5,3,0,0,0,0,0,0, ' ' , 1),
('silver', 100, '$',%X'00000000', 0, 6,4,0,0,0,0,0,0, ' ' , 1),
('silver', 100, '$',%X'00000000', 0, 8,5,0,0,0,0,0,0, ' ' , 1),
('silver', 100, '$',%X'00000000', 0,10,6,0,0,0,0,0,0, ' ' , 1),
('garnets',100, '*',%X'00000000', 0,11,7,0,0,0,0,0,0, ' ' , 1),
('garnets',100, '*',%X'00000000', 0,12,8,0,0,0,0,0,0, ' ' , 1),
('gold' , 100, '$',%X'00000000', 0,14,9,0,0,0,0,0,0, ' ' , 1),
('gold' , 100, '$',%X'00000000', 0,16,0,0,0,0,0,0,0, ' ' , 1),
('gold' , 100, '$',%X'00000000', 0,18,1,0,0,0,0,0,0, ' ' , 1),
('opals', 100, '*',%X'00000000', 0,20,2,0,0,0,0,0,0, ' ' , 1),
('saphires', 100, '*',%X'00000000', 0,24,3,0,0,0,0,0,0, ' ' , 1),
('gold' , 100, '$',%X'00000000', 0,28,4,0,0,0,0,0,0, ' ' , 1),
('rubies', 100, '*',%X'00000000', 0,35,5,0,0,0,0,0,0, ' ' , 1),
('diamonds', 100, '*',%X'00000000', 0,40,6,0,0,0,0,0,0, ' ' , 1),
('emeralds', 100, '*',%X'00000000', 0,70,7,0,0,0,0,0,0, ' ' , 1),
('mithril' , 100, '$',%X'00000000',0,140,8,0,0,0,0,0,0, ' ' , 1));
 
{ Object description:  Objects are defined here.  Each object has the following
                       attributes:
      Descriptor : Name of item and formats.
                   %C is replaced with a random color.
                   %W is replaced with a random wood.
                   %M is replaced with a random metal.
                   %R is replaced with a random rock.
                   %P1 is replaced with the number in P1 (see below).
                   %P2 is replaced with plus-to-hit.
                   %P3 is replaced with plus-to-damage.
                   %P4 is replaced with plus-to-AC.
                   %P5 is replaced with number in P1, no sign.
                   & is replaced with 'a', 'an', or a number.
                   ~ is replaced with null or 's'.
      Character  : Character that represents the item.
      Type value : Value representing the type of object.
                   1   ~   Miscellaneous Object.
                   2   &   chest.
                   10  (Left Curly Brace)  sling ammo.
                   11  (Left Curly Brace)  bolt.
                   12  (Left Curly Brace)  arrow.
                   13  ~   spike.
                   15  ~   Lamp or Torch.
                   20  (Right curly brace)  bow, crossbow, or sling.           
                   21  /   hafted weapon.
                   22  \   pole arm.
                   23  |   sword or dagger.
                   25  \   digging tools.
                   30  ]   boots.
                   31  ]   gloves and gauntlets.
                   32  (   Cloak
                   33  ]   helm.
                   34  )   shield.
                   35  [   hard armor.
                   36  (   soft armor.
                   40  "   amulet.
                   45  =   ring.
                   55  _   staff.
                   60  -   rod.
                   65  -   wand.
                   70  ?   scroll.
                   71  ?   scroll.    continued
                   75  !   potion.                              
                   76  !   potion.    continued
                   77  !   flask of oil.
                   80  ,   food.
                   90  ?   Magic Book.
                   91  ?   Prayer Book.
		   92  ?   extra book 1.
		   93  ?   extra book 2.
                   100 $   valuable metal.
                   100 *   valuable gems.
                   101 .   Unseen trap.
                   102 ^   Seen trap.
                   103 :   Rubble.
                   104 '   Open door.
                   105 +   Closed door.
                   107 <   Up staircase.
                   108 >   Down staircase.
                   109 #   Secret door.
                   110 1,2,3,4,5,6,7   Entrance to store.
                   111 ^   Black Market Trap (store)
 
      Sub value  : separate value for each item of a type.
      Damage     : amount of damage item can cause.
      Weight     : relative weight of an item.
      Number     : number of items appearing in group.
                   If items can be added together then subval > 255
                   If items are considered one unit when added together then
                                subval > 511
      To hit     : magical pluses to hit.
      To damage  : magical pluses to damage.
      AC         : objects relative armor class.
                   1 is worse than 5 is worse than 10 ect...
      To AC      : Magical bonuses to AC.
      P1         : Catch all for magical abilities such as pluses to strength,
                   minuses to searching...
      Flags      : Abilities of object.  Each abilitiy is a bit.  Bits 1-31
                   are used. (Signed integer)
 
      Flags used for anything that can be worn or wielded:
                      Bit #   Hex #           Ability
                      1       00000001        Strength
                      2       00000002        Dexterity
                      3       00000004        Constitution
                      4       00000008        Intelligence
                      5       00000010        Wisdom
                      6       00000020        Charisma
                      7       00000040        Searching
                      8       00000080        Slow digestion
                      9       00000100        Stealth
                      10      00000200        Aggravation
                      11      00000400        Teleportation
                      12      00000800        Regeneration
                      13      00001000        Speed
                      14      00002000        Slay Dragon
                      15      00004000        Slay Monster
                      16      00008000        Slay Evil
                      17      00010000        Slay Undead
                      18      00020000        Cold Brand
                      19      00040000        Flame Brand
                      20      00080000        Resist Fire
                      21      00100000        Resist Acid
                      22      00200000        Resist Cold
                      23      00400000        Sustain Stat (P1)
                      24      00800000        Free Action
                      25      01000000        See Invisible
                      26      02000000        Resist Lightning
                      27      04000000        Feather Fall
                      28      08000000        Blindness
                      29      10000000        Timidness
                      30      20000000        Tunneling
                      31      40000000        Infra vision
                      32      80000000        Cursed                 
      Level      : Minimum level on which item can be found.
      Cost       : Relative cost of item.
                   Special Abilities can be added to item by MAGIC_INIT,
                   found in MISC.INC.
 
        Scrolls, Potions, and Food:
                Flags is used to define a function which reading/quaffing
                will cause.  Most scrolls and potions have only one bit
                set.  Potions will generally have some food value, found
                in P1.
 
        Wands and Staves:
                Flags defines a function, P1 contains number of charges
                for item.  P1 is set in MAGIC_INIT (MISC.INC)
        
        Chests:
                Traps are added randomly by MAGIC.INIT in MISC.INC.
        
          Object list (All objects must be defined here) }

        object_list := (
('& %M Mushroom~| of Poison',80,',',%X'00000001',500,0,257,1,1,0,0,0,0,'0d0',7),
('& %M Mushroom~| of Blindness',80,',',%X'00000002',500,0,258,1,1,0,0,0,0,'0d0' ,9),
('& %M Mushroom~| of Paranoia',80,',',%X'00000004',500,0,259,1,1,0,0,0,0,'0d0', 9),
('& %M Mushroom~| of Confusion',80,',',%X'00000008',500,0,260,1,1,0,0,0,0,'0d0', 7),
('& %M Mushroom~| of Halucination',80,',',%X'00000010',500,0,261,1,1,0,0,0,0,'0d0',13),
('& %M Mushroom~| of Cure Poison',80,',',%X'00000020',500,60,262,1,1,0,0,0,0,'0d0', 8),
('& %M Mushroom~| of Cure Blindness',80,',',%X'00000040',500,50,263,1,1,0,0,0,0,'0d0',10),
('& %M Mushroom~| of Cure Paranoia',80,',',%X'00000080',500,25,264,1,1,0,0,0,0,'0d0',12),
('& %M Mushroom~| of Cure Confusion',80,',',%X'00000100',500,50,265,1,1,0,0,0,0,'0d0', 6),
('& %M Mushroom~| of Weakness',80,',',%X'04000200',500,0,266,1,1,0,0,0,0,'0d0', 7),
('& %M Mushroom~| of Unhealth',80,',',%X'04000400',500,50,267,1,1,0,0,0,0,'10d10',15),
('& %M Mushroom~| of Restore Constitution',80,',',%X'00010000',500,350,268,1,1,0,0,0,0,'0d0', 20),
('& %M Mushroom~| of First-Aid',80,',',%X'00200000',500,5,269,1,1,0,0,0,0,'0d0',6),
('& %M Mushroom~| of Minor Cures',80,',',%X'00400000',500,20,270,1,1,0,0,0,0,'0d0',7),
('& %M Mushroom~| of Light Cures',80,',',%X'00800000',500,30,271,1,1,0,0,0,0,'0d0',10),
('& %M Mushroom~| of Restoring' ,80,',',%X'001F8040',500,1000,272,1,1,0,0,0,0,'0d0',30),
('& Hairy %M Mold~| of Poison',80,',',%X'00000001',1200,0,273,1,1,0,0,0,0,'0d0',15),
('& Hairy %M Mold~| of Halucinations',80,',',%X'00000010',1200,0,274,1,1,0,0,0,0,'0d0',18),
('& Hairy %M Mold~| of Cure Poison',80,',',%X'00000020',1200,75,275,1,1,0,0,0,0,'0d0',19),
('& Hairy %M Mold~| of Unhealth',80,',',%X'00000400',1200,25,276,1,1,0,0,0,0,'6d8',28),
('& Hairy %M Mold~| of Cure Serious Wounds',80,',',%X'02000000',1200,75,277,2,1,0,0,0,0,'0d0',16),
('& Ration~ of Food',80,',',%X'00000000',5000,3,307,10,1,0,0,0,0,'0d0',0),
('& Ration~ of Food',80,',',%X'00000000',5000,3,307,10,1,0,0,0,0,'0d0',5),
('& Ration~ of Food',80,',',%X'00000000',5000,3,307,10,1,0,0,0,0,'0d0',10),
('& Slime Mold~',80,',',%X'00000000',3000,2,308,5,1,0,0,0,0,'0d0',1),
('& Piece~ of Elvish Waybread',80,',',%X'02000020',7500,10,311,3,1,0,0,0,0,'0d0',6),
('& Piece~ of Elvish Waybread',80,',',%X'02000020',7500,10,311,3,1,0,0,0,0,'0d0',12),
('& Piece~ of Elvish Waybread',80,',',%X'02000020',7500,10,311,3,1,0,0,0,0,'0d0',20),
('& Dagger (Main Gauche)^ (%P2,%P3)',23,'|',%X'00000000',0,25,1,30,1,0,0,0,0,'1d5',2),
('& Dagger (Misercorde)^ (%P2,%P3)',23,'|',%X'00000000',0,10,2,15,1,0,0,0,0,'1d4',0),
('& Dagger (Stiletto)^ (%P2,%P3)',23,'|',%X'00000000',0,10,3,12,1,0,0,0,0,'1d4',0),
('& Dagger (Bodkin)^ (%P2,%P3)' ,23,'|',%X'00000000',0,10,4,20,1,0,0,0,0,'1d4',1),
('& Broken dagger^ (%P2,%P3)' ,23,'|',%X'00000000',0,0,5,15,1,-2,-2,0,0,'1d1',0),
('& Backsword^ (%P2,%P3)',23,'|',%X'00000000',0,60,6,95,1,0,0,0,0,'1d9',7),
('& Bastard Sword^ (%P2,%P3)' ,23,'|',%X'00000000',0,350,7,140,1,0,0,0,0,'3d4',14),
('& Thrusting Sword (Bilbo)^ (%P2,%P3)' ,23,'|',%X'00000000',0,60,8,80,1,0,0,0,0,'1d6',4),
('& Thrusting Sword (Baselard)^ (%P2,%P3)' ,23,'|',%X'00000000',0,80,9,100,1,0,0,0,0,'1d7',5),
('& Broadsword^ (%P2,%P3)' ,23,'|',%X'00000000',0,255,10,150,1,0,0,0,0,'2d5',9),
('& Two Handed Sword (Claymore)^ (%P2,%P3)',23,'|',%X'00000000',0,775,11,200,1,0,0,0,0,'3d6',30),
('& Cutlass^ (%P2,%P3)' ,23,'|',%X'00000000',0,85,12,110,1,0,0,0,0,'1d7',7),
('& Two Handed Sword (Espadon)^ (%P2,%P3)' ,23,'|',%X'00000000',0,655,13,180,1,0,0,0,0,'3d6',35),
('& Executioner''s Sword^ (%P2,%P3)',23,'|',%X'00000000',0,850,14,260,1,0,0,0,0,'4d5',40),
('& Two Handed Sword (Flamberge)^ (%P2,%P3)',23,'|',%X'00000000',0,1000,15,240,1,0,0,0,0,'4d5',45),
('& Foil^ (%P2,%P3)',23,'|',%X'00000000',0,35,16,30,1,0,0,0,0,'1d5',2),
('& Katana^ (%P2,%P3)',23,'|',%X'00000000',0,400,17,120,1,0,0,0,0,'3d4',18),
('& Longsword^ (%P2,%P3)',23,'|',%X'00000000',0,300,18,130,1,0,0,0,0,'1d10' ,12),
('& Two Handed Sword (No-Dachi)^ (%P2,%P3)',23,'|',%X'00000000',0,675,19,200,1,0,0,0,0,'4d4',45),
('& Rapier^ (%P2,%P3)',23,'|',%X'00000000',0,42,20,40,1,0,0,0,0,'1d6',4),
('& Sabre^ (%P2,%P3)' ,23,'|',%X'00000000',0,50,21,50,1,0,0,0,0,'1d7',5),
('& Small Sword^ (%P2,%P3)',23,'|',%X'00000000',0,48,22,75,1,0,0,0,0,'1d6',5),
('& Two Handed Sword (Zweihander)^ (%P2,%P3)' ,23,'|',%X'00000000',0,1000,23,280,1,0,0,0,0,'4d6',50),
('& Broken sword^ (%P2,%P3)',23,'|',%X'00000000',0,0,24,75,1,-2,-2,0,0,'1d1',0),
('& Battle Axe (Balestarius)^ (%P2,%P3)',21,'\',%X'00000000',0,500,1,180,1,0,0,0,0,'2d8',30),
('& Ball and Chain^ (%P2,%P3)',21,'\',%X'00000000',0,200,2,150,1,0,0,0,0,'2d4',20),
('& Battle Axe (European)^ (%P2,%P3)' ,21,'\',%X'00000000',0,334,3,170,1,0,0,0,0,'3d4',13),
('& Broad Axe^ (%P2,%P3)',21,'\',%X'00000000',0,304,4,160,1,0,0,0,0,'2d6',17),
('& Cat-O-Nine Tails^ (%P2,%P3)',21,'\',%X'00000000',0,14,5,40,1,0,0,0,0,'1d4',3),
('& Wooden Club^ (%P2,%P3)',21,'\',%X'00000000',0,1,6,100,1,0,0,0,0,'1d3',0),
('& Flail^ (%P2,%P3)' ,21,'\',%X'00000000',0,353,7,150,1,0,0,0,0,'2d6',12),
('& Two Handed Great Flail^ (%P2,%P3)',21,'\',%X'00000000',0,590,8,280,1,0,0,0,0,'3d6',45),
('& Morningstar^ (%P2,%P3)',21,'\',%X'00000000',0,396,9,150,1,0,0,0,0,'2d6',10),
('& Mace^ (%P2,%P3)',21,'\',%X'00000000',0,130,10,120,1,0,0,0,0,'2d4',6),
('& War Hammer^ (%P2,%P3)' ,21,'\',%X'00000000',0,225,11,120,1,0,0,0,0,'3d3',5),
('& Mace (Lead filled)^ (%P2,%P3)' ,21,'\',%X'00000000',0,502,12,180,1,0,0,0,0,'3d4',15),
('& Awl-Pike^ (%P2,%P3)',22,'/',%X'00000000',0,340,1,160,1,0,0,0,0,'1d8',8),
('& Beaked Axe^ (%P2,%P3)' ,22,'/',%X'00000000',0,408,2,180,1,0,0,0,0,'2d6',15),
('& Fauchard^ (%P2,%P3)',22,'/',%X'00000000',0,376,3,170,1,0,0,0,0,'1d10' ,17),
('& Glaive^ (%P2,%P3)',22,'/',%X'00000000',0,363,4,190,1,0,0,0,0,'2d6',20),
('& Halberd^ (%P2,%P3)' ,22,'/',%X'00000000',0,430,5,190,1,0,0,0,0,'3d4',22),
('& Lucerne Hammer^ (%P2,%P3)',22,'/',%X'00000000',0,376,6,120,1,0,0,0,0,'2d5',11),
('& Pike^ (%P2,%P3)',22,'/',%X'00000000',0,358,7,160,1,0,0,0,0,'2d5',15),
('& Spear^ (%P2,%P3)' ,22,'/',%X'00000000',0,36,8,50,1,0,0,0,0,'1d6',5),
('& Lance^ (%P2,%P3)' ,22,'/',%X'00000000',0,230,9,300,1,0,0,0,0,'2d8',10),
('& Javelin^ (%P2,%P3)' ,22,'/',%X'00000000',0,18,10,30,1,0,0,0,0,'1d4',4),
('& Short Bow^ (%P2)' ,20,'}',%X'00000000',2,50,1,30,1,0,0,0,0,'1d1',3),
('& Long Bow^ (%P2)',20,'}',%X'00000000',3,120,2,40,1,0,0,0,0,'1d1',10),
('& Composite Bow^ (%P2)',20,'}',%X'00000000',4,240,3,40,1,0,0,0,0,'1d1',40),
('& Light Crossbow^ (%P2)' ,20,'}',%X'00000000',5,140,10,110,1,0,0,0,0,'1d1',15),
('& Heavy Crossbow^ (%P2)' ,20,'}',%X'00000000',6,300,11,200,1,0,0,0,0,'1d1',30),
('& Sling^ (%P2)',20,'}',%X'00000000',1,5,20,5,1,0,0,0,0,'0d0',1),
('& Arrow~^ (%P2,%P3)',12,'{',%X'00000000',0,1,1,2,1,0,0,0,0,'1d4',2),
('& Bolt~^ (%P2,%P3)' ,11,'{',%X'00000000',0,2,1,3,1,0,0,0,0,'1d5',2),
('& Rounded Pebble~^ (%P2,%P3)' ,10,'{',%X'00000000',0,1,1,4,1,0,0,0,0,'1d2',0),
('& Iron Shot~^ (%P2,%P3)' ,10,'{',%X'00000000',0,2,1,5,1,0,0,0,0,'1d3',3),
('& Iron Spike~',13,'~',%X'00000000',0,1,1,10,1,0,0,0,0,'1d1',1),
('& Brass Lantern~ with %P5 turns of light',15,'~',%X'00000000',7500,35,1,50,1,0,0,0,0,'1d1',1),
('& Wooden Torch~ with %P5 turns of light' ,15,'~',%X'00000000',4000,2,13,30,1,0,0,0,0,'1d1',1),
('& Orcish Pick^ (%P1) (%P2,%P3)',25,'\',%X'20000000',2,500,2,180,1,0,0,0,0,'1d5',20),
('& Dwarven Pick^ (%P1) (%P2,%P3)' ,25,'\',%X'20000000',3,1200,3,200,1,0,0,0,0,'2d5',50),
('& Gnomish Shovel^ (%P1) (%P2,%P3)',25,'\',%X'20000000',1,100,5,50,1,0,0,0,0,'1d2',20),
('& Dwarven Shovel^ (%P1) (%P2,%P3)',25,'\',%X'20000000',2,250,6,120,1,0,0,0,0,'1d3',40),
('& Pair of Soft Leather Shoes^ [%P6,%P4]' ,30,']',%X'00000000',0,4,1,5,1,0,0,1,0,'0d0',1),
('& Pair of Soft Leather Boots^ [%P6,%P4]' ,30,']',%X'00000000',0,7,2,20,1,0,0,2,0,'1d1',4),
('& Pair of Hard Leather Boots^ [%P6,%P4]' ,30,']',%X'00000000',0,12,3,40,1,0,0,3,0,'1d1',6),
('& Soft Leather Cap^ [%P6,%P4]',33,']',%X'00000000',0,4,1,10,1,0,0,1,0,'0d0',2),
('& Hard Leather Cap^ [%P6,%P4]',33,']',%X'00000000',0,12,2,15,1,0,0,2,0,'0d0',4),
('& Metal Cap^ [%P6,%P4]',33,']',%X'00000000',0,30,3,20,1,0,0,3,0,'1d1',7),
('& Iron Helm^ [%P6,%P4]',33,']',%X'00000000',0,75,4,75,1,0,0,5,0,'1d3',20),
('& Steel Helm^ [%P6,%P4]' ,33,']',%X'00000000',0,200,5,60,1,0,0,6,0,'1d3',40),
('& Silver Crown^ (%P1)',33,']',%X'00000000',0,250,6,20,1,0,0,0,0,'1d1',44),
('& Golden Crown^ (%P1)',33,']',%X'00000000',0,500,7,30,1,0,0,0,0,'1d1',47),
('& Jewel Encrusted Crown^ (%P1)',33,']',%X'00000000',0,1000,8,40,1,0,0,0,0,'1d1',50),
('& Robe^ [%P6,%P4]',36,'(',%X'00000000',0,4,1,20,1,0,0,2,0,'0d0',1),
('Soft Leather Armor^ [%P6,%P4]',36,'(',%X'00000000',0,18,2,80,1,0,0,4,0,'0d0',2),
('Soft Studded Leather^ [%P6,%P4]' ,36,'(',%X'00000000',0,35,3,90,1,0,0,5,0,'1d1',3),
('Hard Leather Armor^ [%P6,%P4]',36,'(',%X'00000000',0,55,4,100,1,-1,0,6,0,'1d1',5),
('Hard Studded Leather^ [%P6,%P4]' ,36,'(',%X'00000000',0,100,5,110,1,-1,0,7,0,'1d2',7),
('Woven Cord Armor^ [%P6,%P4]',36,'(',%X'00000000',0,45,6,150,1,-1,0,6,0,'0d0',7),
('Soft Leather Ring Mail^ [%P6,%P4]',36,'(',%X'00000000',0,160,7,130,1,-1,0,6,0,'1d2',10),
('Hard Leather Ring Mail^ [%P6,%P4]',36,'(',%X'00000000',0,230,8,150,1,-2,0,8,0,'1d3',12),
('Leather Scale Mail^ [%P6,%P4]',36,'(',%X'00000000',0,330,9,140,1,-1,0,11,0,'1d1',14),
('Metal Scale Mail^ [%P6,%P4]',35,'[',%X'00000000',0,430,1,250,1,-2,0,13,0,'1d4',24),
('Chain Mail^ [%P6,%P4]',35,'[',%X'00000000',0,530,2,220,1,-2,0,14,0,'1d4',26),
('Rusty Chain Mail^ [%P6,%P4]',35,'[',%X'00000000',0,0,3,200,1,-5,0,14,-8,'1d4',26),
('Double Chain Mail^ [%P6,%P4]' ,35,'[',%X'00000000',0,630,4,260,1,-2,0,15,0,'1d4',28),
('Augmented Chain Mail^ [%P6,%P4]' ,35,'[',%X'00000000',0,675,5,270,1,-2,0,16,0,'1d4',30),
('Bar Chain Mail^ [%P6,%P4]',35,'[',%X'00000000',0,720,6,280,1,-2,0,18,0,'1d4',34),
('Metal Brigandine Armor^ [%P6,%P4]',35,'[',%X'00000000',0,775,7,290,1,-3,0,19,0,'1d4',36),
('Laminated Armor^ [%P6,%P4]' ,35,'[',%X'00000000',0,825,8,300,1,-3,0,20,0,'1d4',38),
('Partial Plate Armor^ [%P6,%P4]',35,'[',%X'00000000',0,900,9,260,1,-3,0,22,0,'1d6',42),
('Metal Lamellar Armor^ [%P6,%P4]' ,35,'[',%X'00000000',0,950,10,340,1,-3,0,23,0,'1d6',44),
('Full Plate Armor^ [%P6,%P4]',35,'[',%X'00000000',0,1050,11,380,1,-3,0,25,0,'2d4',48),
('Ribbed Plate Armor^ [%P6,%P4]',35,'[',%X'00000000',0,1200,12,380,1,-3,0,28,0,'2d4',50),
('& Cloak^ [%P6,%P4]' ,32,'(',%X'00000000',0,3,1,10,1,0,0,1,0,'0d0',1),
('& Set of Leather Gloves^ [%P6,%P4]' ,31,']',%X'00000000',0,3,1,5,1,0,0,1,0,'0d0',1),
('& Set of Gauntlets^ [%P6,%P4]',31,']',%X'00000000',0,35,2,25,1,0,0,2,0,'1d1',12),
('& Small Leather Shield^ [%P6,%P4]',34,')',%X'00000000',0,30,1,50,1,0,0,2,0,'1d1',3),
('& Medium Leather Shield^ [%P6,%P4]' ,34,')',%X'00000000',0,60,2,75,1,0,0,3,0,'1d2',8),
('& Large Leather Shield^ [%P6,%P4]',34,')',%X'00000000',0,120,3,100,1,0,0,4,0,'1d2',15),
('& Small Metal Shield^ [%P6,%P4]' ,34,')',%X'00000000',0,50,4,65,1,0,0,3,0,'1d2',10),
('& Medium Metal Shield^ [%P6,%P4]',34,')',%X'00000000',0,125,5,90,1,0,0,4,0,'1d3',20),
('& Large Metal Shield^ [%P6,%P4]' ,34,')',%X'00000000',0,200,6,120,1,0,0,5,0,'1d3',30),
('& %R Ring| of Gain Strength^ (%P1)' ,45,'=',%X'00000001',0,400,1,2,1,0,0,0,0,'0d0',30),
('& %R Ring| of Gain Dexterity^ (%P1)',45,'=',%X'00000002',0,400,2,2,1,0,0,0,0,'0d0',30),
('& %R Ring| of Gain Constitution^ (%P1)',45,'=',%X'00000004',0,400,3,2,1,0,0,0,0,'0d0',30),
('& %R Ring| of Gain Intelligence^ (%P1)',45,'=',%X'00000008',0,350,4,2,1,0,0,0,0,'0d0',30),
('& %R Ring| of Speed^ (%P1)' ,45,'=',%X'00001000',0,3000,7,2,1,0,0,0,0,'0d0',50),
('& %R Ring| of Searching^ (%P1)',45,'=',%X'00000040',0,250,8,2,1,0,0,0,0,'0d0',7),
('& %R Ring| of Telportation^',45,'=',%X'80000400',0,0,9,2,1,0,0,0,0,'0d0',7),
('& %R Ring| of Slow Digestion^',45,'=',%X'00000080',0,250,10,2,1,0,0,0,0,'0d0',7),
('& %R Ring| of Resist Fire^',45,'=',%X'00080000',0,250,11,2,1,0,0,0,0,'0d0',14),
('& %R Ring| of Resist Cold^',45,'=',%X'00200000',0,250,12,2,1,0,0,0,0,'0d0',14),
('& %R Ring| of Feather Falling^',45,'=',%X'04000000',0,200,13,2,1,0,0,0,0,'0d0',7),
('& %R Ring| of Adornment^',45,'=',%X'00000000',0,20,14,2,1,0,0,0,0,'1d1',7),
('& %R Ring| of Adornment^',45,'=',%X'00000000',0,30,15,2,1,0,0,0,0,'0d0',7),
('& %R Ring| of Weakness^',45,'=',%X'00000001',-5,0,16,2,1,0,0,0,0,'0d0',7),
('& %R Ring| of Lordly Protection (FIRE)^',45,'=',%X'00080000',0,1200,17,2,1,0,0,0,5,'0d0',50),
('& %R Ring| of Lordly Protection (ACID)^',45,'=',%X'00100000',0,1200,18,2,1,0,0,0,5,'0d0',50),
('& %R Ring| of Lordly Protection (COLD)^',45,'=',%X'00200000',0,1200,19,2,1,0,0,0,5,'0d0',50),
('& %R Ring| of WOE^',45,'=',%X'80000640',-5,0,20,2,1,0,0,0,-3,'0d0',50),
('& %R Ring| of Stupidity^',45,'=',%X'80000008',-5,0,21,2,1,0,0,0,0,'0d0',20),
('& %R Ring| of Increase Damage^ (%P3)' ,45,'=',%X'00000000',0,100,22,2,1,0,0,0,0,'0d0',20),
('& %R Ring| of Increase To-Hit^ (%P2)' ,45,'=',%X'00000000',0,100,23,2,1,0,0,0,0,'0d0',20),
('& %R Ring| of Protection^ [%P4]' ,45,'=',%X'00000000',0,100,24,2,1,0,0,0,0,'0d0',7),
('& %R Ring| of Aggravate Monster^',45,'=',%X'80000200',0,0,25,2,1,0,0,0,0,'0d0',7),
('& %R Ring| of See Invisible^' ,45,'=',%X'01000000',0,340,26,2,1,0,0,0,0,'0d0',40),
('& %R Ring| of Sustain Strength^' ,45,'=',%X'00400000',1,750,27,2,1,0,0,0,0,'0d0',44),
('& %R Ring| of Sustain Intelligence^',45,'=',%X'00400000',2,600,28,2,1,0,0,0,0,'0d0',44),
('& %R Ring| of Sustain Wisdom^',45,'=',%X'00400000',3,600,29,2,1,0,0,0,0,'0d0',44),
('& %R Ring| of Sustain Constitution^',45,'=',%X'00400000',4,750,30,2,1,0,0,0,0,'0d0',44),
('& %R Ring| of Sustain Dexterity^',45,'=',%X'00400000',5,750,31,2,1,0,0,0,0,'0d0',44),
('& %R Ring| of Sustain Charisma^' ,45,'=',%X'00400000',6,500,32,2,1,0,0,0,0,'0d0',7),
('& %R Ring| of Slaying^',45,'=',%X'00000000',6,1000,33,2,1,0,0,0,0,'0d0',50),
('& %A Amulet| of Adornment^' ,40,'"',%X'00000000',0,20,11,3,1,0,0,0,0,'0d0',16),
('& %A Amulet| of Adornment^' ,40,'"',%X'00000000',0,30,12,3,1,0,0,0,0,'0d0',16),
('& %A Amulet| of Wisdom^ (%P1)',40,'"',%X'00000010',0,300,5,3,1,0,0,0,0,'0d0',20),
('& %A Amulet| of Charisma^ (%P1)' ,40,'"',%X'00000020',0,250,6,3,1,0,0,0,0,'0d0',20),
('& %A Amulet| of Searching^ (%P1)',40,'"',%X'00000040',0,250,7,3,1,0,0,0,0,'0d0',14),
('& %A Amulet| of Telportation^',40,'"',%X'80000400',0,0,8,3,1,0,0,0,0,'0d0',14),
('& %A Amulet| of Slow Digestion^' ,40,'"',%X'00000080',0,200,9,3,1,0,0,0,0,'0d0',14),
('& %A Amulet| of Resist Acid^' ,40,'"',%X'00100000',0,300,10,3,1,0,0,0,0,'0d0',24),
('& %A Amulet| of the Magi^',40,'"',%X'01800040',0,5000,13,3,1,0,0,0,3,'0d0',50),
('& %A Amulet| of DOOM^',40,'"',%X'8000007F',-5,0,14,3,1,0,0,0,0,'0d0',50),
('& Scroll~ %T| of Enchant Weapon To-Hit',70,'?',%X'00000001',0,125,257,5,1,0,0,0,0,'0d0',12),
('& Scroll~ %T| of Enchant Weapon To-Dam',70,'?',%X'00000002',0,125,258,5,1,0,0,0,0,'0d0',12),
('& Scroll~ %T| of Enchant Armor',70,'?',%X'00000004',0,125,259,5,1,0,0,0,0,'0d0',12),
('& Scroll~ %T| of Identify',70,'?',%X'00000008',0,50,260,5,1,0,0,0,0,'0d0',1),
('& Scroll~ %T| of Identify',70,'?',%X'00000008',  {change?}0,50,260,5,1,0,0,0,0,'0d0',5),
('& Scroll~ %T| of Identify',70,'?',%X'00000008',  {change?}0,50,260,5,1,0,0,0,0,'0d0',10),
('& Scroll~ %T| of Remove Curse',70,'?',%X'00000010',0,100,261,5,1,0,0,0,0,'0d0',7),
('& Scroll~ %T| of Light',70,'?',%X'00000020',0,15,262,5,1,0,0,0,0,'0d0',0),
('& Scroll~ %T| of Light',70,'?',%X'00000020',0,15,262,5,1,0,0,0,0,'0d0',3),
('& Scroll~ %T| of Light',70,'?',%X'00000020',0,15,262,5,1,0,0,0,0,'0d0',7),
('& Scroll~ %T| of Summon Monster' ,70,'?',%X'00000040',0,0,263,5,1,0,0,0,0,'0d0',1),
('& Scroll~ %T| of Phase Door',70,'?',%X'00000080',0,15,264,5,1,0,0,0,0,'0d0',1),
('& Scroll~ %T| of Teleport',70,'?',%X'00000100',0,40,265,5,1,0,0,0,0,'0d0',10),
('& Scroll~ %T| of Monster Confusion' ,70,'?',%X'00000400',0,30,267,5,1,0,0,0,0,'0d0',5),
('& Scroll~ %T| of Magic Mapping',70,'?',%X'00000800',0,40,268,5,1,0,0,0,0,'0d0',5),
('& Scroll~ %T| of Sleep Monster',70,'?',%X'00001000',0,35,269,5,1,0,0,0,0,'0d0',5),
('& Scroll~ %T| of Rune of Protection',70,'?',%X'00002000',0,500,270,5,1,0,0,0,0,'0d0',50),
('& Scroll~ %T| of Treasure Detection',70,'?',%X'00004000',0,15,271,5,1,0,0,0,0,'0d0',0),
('& Scroll~ %T| of Object Detection',70,'?',%X'00008000',0,15,272,5,1,0,0,0,0,'0d0',0),
('& Scroll~ %T| of Trap Detection' ,70,'?',%X'00010000',0,35,273,5,1,0,0,0,0,'0d0',5),
('& Scroll~ %T| of Trap Detection' ,70,'?',%X'00010000',0,35,273,5,1,0,0,0,0,'0d0',8),
('& Scroll~ %T| of Trap Detection' ,70,'?',%X'00010000',0,35,273,5,1,0,0,0,0,'0d0',12),
('& Scroll~ %T| of Door/Stair Location' ,70,'?',%X'00020000',0,35,274,5,1,0,0,0,0,'0d0',5),
('& Scroll~ %T| of Door/Stair Location' ,70,'?',%X'00020000',0,35,274,5,1,0,0,0,0,'0d0',10),
('& Scroll~ %T| of Door/Stair Location' ,70,'?',%X'00020000',0,35,274,5,1,0,0,0,0,'0d0',15),
('& Scroll~ %T| of Mass Genocide',70,'?',%X'00040000',0,1000,275,5,1,0,0,0,0,'0d0',50),
('& Scroll~ %T| of Detect Invisible',70,'?',%X'00080000',0,15,276,5,1,0,0,0,0,'0d0',1),
('& Scroll~ %T| of Aggravate Monster' ,70,'?',%X'00100000',0,0,277,5,1,0,0,0,0,'0d0',5),
('& Scroll~ %T| of Trap Creation',70,'?',%X'00200000',0,0,278,5,1,0,0,0,0,'0d0',12),
('& Scroll~ %T| of Trap/Door Destruction',70,'?',%X'00400000',0,50,279,5,1,0,0,0,0,'0d0',12),
('& Scroll~ %T| of Door Creation',70,'?',%X'00800000',0,100,280,5,1,0,0,0,0,'0d0',12),
('& Scroll~ %T| of Recharging',70,'?',%X'01000000',0,200,281,5,1,0,0,0,0,'0d0',40),
('& Scroll~ %T| of Genocide',70,'?',%X'02000000',0,750,282,5,1,0,0,0,0,'0d0',35),
('& Scroll~ %T| of Darkness',70,'?',%X'04000000',0,0,283,5,1,0,0,0,0,'0d0',1),
('& Scroll~ %T| of Protection from Evil',70,'?',%X'08000000',0,50,284,5,1,0,0,0,0,'0d0',30),
('& Scroll~ %T| of Create Food' ,70,'?',%X'10000000',0,10,285,5,1,0,0,0,0,'0d0',5),
('& Scroll~ %T| of Dispell Undead' ,70,'?',%X'20000000',0,200,286,5,1,0,0,0,0,'0d0',40),
('& Scroll~ %T| of *Enchant Weapon*',71,'?',%X'00000001',0,500,257,5,1,0,0,0,0,'0d0',50),
('& Scroll~ %T| of Curse Weapon',71,'?',%X'00000002',0,0,258,5,1,0,0,0,0,'0d0',50),
('& Scroll~ %T| of *Enchant Armor*',71,'?',%X'00000004',0,500,259,5,1,0,0,0,0,'0d0',50),
('& Scroll~ %T| of Curse Armor' ,71,'?',%X'00000008',0,0,260,5,1,0,0,0,0,'0d0',50),
('& Scroll~ %T| of Summon Undead',71,'?',%X'00000010',0,0,261,5,1,0,0,0,0,'0d0',15),
('& Scroll~ %T| of Blessing',71,'?',%X'00000020',0,15,262,5,1,0,0,0,0,'0d0',1),
('& Scroll~ %T| of Holy Chant',71,'?',%X'00000040',0,40,263,5,1,0,0,0,0,'0d0',12),
('& Scroll~ %T| of Holy Prayer' ,71,'?',%X'00000080',0,80,264,5,1,0,0,0,0,'0d0',24),
('& Scroll~ %T| of Word-of-Recall' ,71,'?',%X'00000100',0,150,265,5,1,0,0,0,0,'0d0',5),
('& Scroll~ %T| of *Destruction*',71,'?',%X'00000200',0,250,266,5,1,0,0,0,0,'0d0',40),
('& %C Potion~| of Gain Strength',75,'!',%X'00000001',0,200,257,4,1,0,0,0,0,'1d1',10),
('& %C Potion~| of Gain Strength',75,'!',%X'00000001',0,200,257,4,1,0,0,0,0,'1d1',25),
('& %C Potion~| of Poison' ,75,'!',%X'00000002',0,0,258,4,1,0,0,0,0,'1d1',3),
('& %C Potion~| of Restore Strength',75,'!',%X'00000004',0,300,259,4,1,0,0,0,0,'1d1',20),
('& %C Potion~| of Gain Intelligence' ,75,'!',%X'00000008',0,300,260,4,1,0,0,0,0,'1d1',10),
('& %C Potion~| of Gain Intelligence' ,75,'!',%X'00000008',0,300,260,4,1,0,0,0,0,'1d1',25),
('& %C Potion~| of Lose Intelligence' ,75,'!',%X'00000010',0,0,261,4,1,0,0,0,0,'1d1',25),
('& %C Potion~| of Restore Intelligence',75,'!',%X'00000020',0,300,262,4,1,0,0,0,0,'1d1',20),
('& %C Potion~| of Gain Wisdom' ,75,'!',%X'00000040',0,300,263,4,1,0,0,0,0,'1d1',10),
('& %C Potion~| of Gain Wisdom' ,75,'!',%X'00000040',0,300,263,4,1,0,0,0,0,'1d1',25),
('& %C Potion~| of Lose Wisdom' ,75,'!',%X'00000080',0,0,264,4,1,0,0,0,0,'1d1',25),
('& %C Potion~| of Restore Wisdom' ,75,'!',%X'00000100',0,300,265,4,1,0,0,0,0,'1d1',20),
('& %C Potion~| of Charisma',75,'!',%X'00000200',0,300,266,4,1,0,0,0,0,'1d1',10),
('& %C Potion~| of Charisma',75,'!',%X'00000200',0,300,266,4,1,0,0,0,0,'1d1',25),
('& %C Potion~| of Ugliness',75,'!',%X'00000400',0,0,267,4,1,0,0,0,0,'1d1',25),
('& %C Potion~| of Restore Charisma',75,'!',%X'00000800',0,300,268,4,1,0,0,0,0,'1d1',20),
('& %C Potion~| of Cure Light Wounds' ,75,'!',%X'10001000',50,15,269,4,1,0,0,0,0,'1d1',0),
('& %C Potion~| of Cure Light Wounds' ,75,'!',%X'10001000',50,15,269,4,1,0,0,0,0,'1d1',1),
('& %C Potion~| of Cure Light Wounds' ,75,'!',%X'10001000',50,15,269,4,1,0,0,0,0,'1d1',2),
('& %C Potion~| of Cure Serious Wounds' ,75,'!',%X'30002000',100,40,270,4,1,0,0,0,0,'1d1',3),
('& %C Potion~| of Cure Critical Wounds',75,'!',%X'70004000',100,100,271,4,1,0,0,0,0,'1d1',5),
('& %C Potion~| of Healing',75,'!',%X'70008000',200,200,272,4,1,0,0,0,0,'1d1',12),
('& %C Potion~| of Gain Constitution' ,75,'!',%X'00010000',0,300,273,4,1,0,0,0,0,'1d1',10),
('& %C Potion~| of Gain Constitution' ,75,'!',%X'00010000',0,300,273,4,1,0,0,0,0,'1d1',25),
('& %C Potion~| of Gain Experience',75,'!',%X'00020000',0,2500,274,4,1,0,0,0,0,'1d1',50),
('& %C Potion~| of Sleep',75,'!',%X'10040000',100,0,275,4,1,0,0,0,0,'1d1',0),
('& %C Potion~| of Blindness' ,75,'!',%X'00080000',0,0,276,4,1,0,0,0,0,'1d1',0),
('& %C Potion~| of Confusion' ,75,'!',%X'00100000',50,0,277,4,1,0,0,0,0,'1d1',0),
('& %C Potion~| of Poison' ,75,'!',%X'00200000',0,0,278,4,1,0,0,0,0,'1d1',3),
('& %C Potion~| of Haste Self',75,'!',%X'00400000',0,75,279,4,1,0,0,0,0,'1d1',1),
('& %C Potion~| of Slowness',75,'!',%X'00800000',50,0,280,4,1,0,0,0,0,'1d1',1),
('& Icky Green Potion~| of Slime Mold Juice',75,'!',%X'30000000',400,2,281,4,1,0,0,0,0,'1d1',0),
('& Light Brown Potion~| of Apple Juice',75,'!',%X'00000000',250,1,282,4,1,0,0,0,0,'1d1',0),
('& Clear Potion~| of Water',75,'!',%X'00000000',200,0,283,4,1,0,0,0,0,'1d1',0),
('& %C Potion~| of Gain Dexterity' ,75,'!',%X'02000000',0,300,284,4,1,0,0,0,0,'1d1',10),                        
('& %C Potion~| of Gain Dexterity' ,75,'!',%X'02000000',0,300,284,4,1,0,0,0,0,'1d1',25),
('& %C Potion~| of Restore Dexterity' ,75,'!',%X'04000000',0,300,285,4,1,0,0,0,0,'1d1',20),
('& %C Potion~| of Restore Constitution',75,'!',%X'68000000',0,300,286,4,1,0,0,0,0,'1d1',20),
('& %C Potion~| of Learning',76,'!',%X'00000001',0,200,287,4,1,0,0,0,0,'1d1',10),
('& %C Potion~| of Learning',76,'!',%X'00000001',0,200,287,4,1,0,0,0,0,'1d1',25),
('& %C Potion~| of Lose Memories',76,'!',%X'00000002',0,0,288,4,1,0,0,0,0,'1d1',10),
('& %C Potion~| of Salt Water',76,'!',%X'00000004',0,0,289,4,1,0,0,0,0,'1d1',0),
('& %C Potion~| of Invulnerability',76,'!',%X'00000008',0,250,290,4,1,0,0,0,0,'1d1',40),
('& %C Potion~| of Heroism',76,'!',%X'00000010',0,35,291,4,1,0,0,0,0,'1d1',1),
('& %C Potion~| of Super Heroism',76,'!',%X'00000020',0,100,292,4,1,0,0,0,0,'1d1',3),
('& %C Potion~| of Boldliness',76,'!',%X'00000040',0,10,293,4,1,0,0,0,0,'1d1',1),
('& %C Potion~| of Restore Life Levels' ,76,'!',%X'00000080',0,400,294,4,1,0,0,0,0,'1d1',25),
('& %C Potion~| of Resist Heat' ,76,'!',%X'00000100',0,30,295,4,1,0,0,0,0,'1d1',1),
('& %C Potion~| of Resist Cold' ,76,'!',%X'00000200',0,30,296,4,1,0,0,0,0,'1d1',1),
('& %C Potion~| of Detect Invisible',76,'!',%X'00000400',0,50,297,4,1,0,0,0,0,'1d1',3),
('& %C Potion~| of Slow Poison' ,76,'!',%X'00000800',0,25,298,4,1,0,0,0,0,'1d1',1),
('& %C Potion~| of Neutralize Poison' ,76,'!',%X'00001000',0,75,299,4,1,0,0,0,0,'1d1',5),
('& %C Potion~| of Restore Mana',76,'!',%X'00002000',0,35,300,4,1,0,0,0,0,'1d1',25),
('& %C Potion~| Infra-Vision' ,76,'!',%X'00004000',0,20,301,4,1,0,0,0,0,'1d1',3),
('& %C Potion~| of Longevity' ,76,'!',%X'00008000',0,50,302,4,1,0,0,0,0,'1d1',55),
('& %C Potion~| of Gain MANA' ,76,'!',%X'00010000',0,50,303,4,1,0,0,0,0,'1d1',55),
('& Flask~ of oil' ,77,'!',%X'00040000',7500,3,257,10,1,0,0,0,0,'2d6',1),
('& %M Wand| of Light^ (%P1 charges)' ,65,'-',%X'00000001',0,200,1,10,1,0,0,0,0,'1d1',2),
('& %M Wand| of Lightning Bolts^ (%P1 charges)' ,65,'-',%X'00000002',0,600,2,10,1,0,0,0,0,'1d1',15),
('& %M Wand| of Frost Bolts^ (%P1 charges)',65,'-',%X'00000004',0,800,3,10,1,0,0,0,0,'1d1',20),
('& %M Wand| of Fire Bolts^ (%P1 charges)' ,65,'-',%X'00000008',0,1000,4,10,1,0,0,0,0,'1d1',30),
('& %M Wand| of Stone-to-Mud^ (%P1 charges)',65,'-',%X'00000010',0,300,5,10,1,0,0,0,0,'1d1',12),
('& %M Wand| of Polymorph^ (%P1 charges)',65,'-',%X'00000020',0,400,6,10,1,0,0,0,0,'1d1',20),
('& %M Wand| of Heal Monster^ (%P1 charges)',65,'-',%X'00000040',0,0,7,10,1,0,0,0,0,'1d1',2),
('& %M Wand| of Haste Monster^ (%P1 charges)' ,65,'-',%X'00000080',0,0,8,10,1,0,0,0,0,'1d1',2),
('& %M Wand| of Slow Monster^ (%P1 charges)',65,'-',%X'00000100',0,500,9,10,1,0,0,0,0,'1d1',2),
('& %M Wand| of Confuse Monster^ (%P1 charges)' ,65,'-',%X'00000200',0,400,10,10,1,0,0,0,0,'1d1',2),
('& %M Wand| of Sleep Monster^ (%P1 charges)' ,65,'-',%X'00000400',0,500,11,10,1,0,0,0,0,'1d1',7),
('& %M Wand| of Drain Life^ (%P1 charges)' ,65,'-',%X'00000800',0,1200,12,10,1,0,0,0,0,'1d1',50),
('& %M Wand| of Trap/Door destruction^ (%P1 charges)',65,'-',%X'00001000',0,100,13,10,1,0,0,0,0,'1d1',12),
('& %M Wand| of Magic Missle^ (%P1 charges)',65,'-',%X'00002000',0,200,14,10,1,0,0,0,0,'1d1',2),
('& %M Wand| of Wall Building^ (%P1 charges)' ,65,'-',%X'00004000',0,400,15,10,1,0,0,0,0,'1d1',25),
('& %M Wand| of Clone Monster^ (%P1 charges)' ,65,'-',%X'00008000',0,0,16,10,1,0,0,0,0,'1d1',2),
('& %M Wand| of Teleport Away^ (%P1 charges)' ,65,'-',%X'00010000',0,350,17,10,1,0,0,0,0,'1d1',20),
('& %M Wand| of Disarming^ (%P1 charges)',65,'-',%X'00020000',0,700,18,10,1,0,0,0,0,'1d1',20),
('& %M Wand| of Lightning Balls^ (%P1 charges)' ,65,'-',%X'00040000',0,1200,19,10,1,0,0,0,0,'1d1',35),
('& %M Wand| of Cold Balls^ (%P1 charges)' ,65,'-',%X'00080000',0,1500,20,10,1,0,0,0,0,'1d1',40),
('& %M Wand| of Fire Balls^ (%P1 charges)' ,65,'-',%X'00100000',0,1800,21,10,1,0,0,0,0,'1d1',50),
('& %M Wand| of Stinking Cloud^ (%P1 charges)',65,'-',%X'00200000',0,400,21,10,1,0,0,0,0,'1d1',5),
('& %M Wand| of Acid Balls^ (%P1 charges)' ,65,'-',%X'00400000',0,1650,21,10,1,0,0,0,0,'1d1',48),
('& %M Wand| of Wonder^ (%P1 charges)',65,'-',%X'00800000',0,250,22,10,1,0,0,0,0,'1d1',2),
('& %W Staff| of Light^ (%P1 charges)',55,'_',%X'00000001',0,250,1,50,1,0,0,0,0,'1d2',5),
('& %W Staff| of Door/Stair Location^ (%P1 charges)',55,'_',%X'00000002',0,350,2,50,1,0,0,0,0,'1d2',10),
('& %W Staff| of Trap Location^ (%P1 charges)',55,'_',%X'00000004',0,350,3,50,1,0,0,0,0,'1d2',10),
('& %W Staff| of Treasure Location^ (%P1 charges)' ,55,'_',%X'00000008',0,200,4,50,1,0,0,0,0,'1d2',5),
('& %W Staff| of Object Location^ (%P1 charges)',55,'_',%X'00000010',0,200,5,50,1,0,0,0,0,'1d2',5),
('& %W Staff| of Earthquakes^ (%P1 charges)',55,'_',%X'00000040',0,350,7,50,1,0,0,0,0,'1d2',40),
('& %W Staff| of Summoning^ (%P1 charges)' ,55,'_',%X'00000080',0,0,8,50,1,0,0,0,0,'1d2',10),
('& %W Staff| of Summoning^ (%P1 charges)' ,55,'_',%X'00000080',0,0,8,50,1,0,0,0,0,'1d2',50),
('& %W Staff| of *Destruction*^ (%P1 charges)',55,'_',%X'00000200',0,2500,10,50,1,0,0,0,0,'1d2',50),
('& %W Staff| of Starlite^ (%P1 charges)',55,'_',%X'00000400',0,800,11,50,1,0,0,0,0,'1d2',20),
('& %W Staff| of Haste Monsters^ (%P1 charges)' ,55,'_',%X'00000800',0,0,12,50,1,0,0,0,0,'1d2',10),
('& %W Staff| of Slow Monsters^ (%P1 charges)',55,'_',%X'00001000',0,800,13,50,1,0,0,0,0,'1d2',10),
('& %W Staff| of Sleep Monsters^ (%P1 charges)' ,55,'_',%X'00002000',0,700,14,50,1,0,0,0,0,'1d2',10),
('& %W Staff| of Cure Light Wounds^ (%P1 charges)' ,55,'_',%X'00004000',0,350,15,50,1,0,0,0,0,'1d2',5),
('& %W Staff| of Detect Invisible^ (%P1 charges)',55,'_',%X'00008000',0,200,16,50,1,0,0,0,0,'1d2',5),
('& %W Staff| of Speed^ (%P1 charges)',55,'_',%X'00010000',0,800,17,50,1,0,0,0,0,'1d2',40),
('& %W Staff| of Slowness^ (%P1 charges)',55,'_',%X'00020000',0,0,18,50,1,0,0,0,0,'1d2',40),
('& %W Staff| of Mass Polymorph^ (%P1 charges)' ,55,'_',%X'00040000',0,750,19,50,1,0,0,0,0,'1d2',46),
('& %W Staff| of Remove Curse^ (%P1 charges)' ,55,'_',%X'00080000',0,500,20,50,1,0,0,0,0,'1d2',47),
('& %W Staff| of Detect Evil^ (%P1 charges)',55,'_',%X'00100000',0,350,21,50,1,0,0,0,0,'1d2',20),
('& %W Staff| of Curing^ (%P1 charges)' ,55,'_',%X'00200000',0,1000,22,50,1,0,0,0,0,'1d2',25),
('& %W Staff| of Dispell Evil^ (%P1 charges)' ,55,'_',%X'00400000',0,1200,23,50,1,0,0,0,0,'1d2',49),
('& %W Staff| of Darkness^ (%P1 charges)',55,'_',%X'01000000',0,0,25,50,1,0,0,0,0,'1d2',50),
('& %W Staff| of Darkness^ (%P1 charges)',55,'_',%X'01000000',0,0,25,50,1,0,0,0,0,'1d2',5),
('& Book of Magic Spells [Beginners-Magik]',90,'?',%X'0000007F',0,25,257,30,1,-100,0,0,0,'1d1',40),
('& Book of Magic Spells [Magik I]',90,'?',%X'0000FF80',0,100,258,30,1,-100,0,0,0,'1d1',40),
('& Book of Magic Spells [Magik II]',90,'?',%X'00FF0000',0,400,259,30,1,-100,0,0,0,'1d1',40),
('& Book of Magic Spells [The Mages Guide to Power]',90,'?',%X'7F000000',0,800,261,30,1,-100,0,0,0,'1d1',40),
('& Holy Book of Prayers [Beginners Handbook]',91,'?',%X'000000FF',0,25,258,30,1,-100,0,0,0,'1d1',40),
('& Holy Book of Prayers [Words of Wisdom]',91,'?',%X'0000FF00',0,100,259,30,1,-100,0,0,0,'1d1',40),
('& Holy Book of Prayers [Chants and Blessings]',91,'?',%X'01FF0000',0,300,260,30,1,-100,0,0,0,'1d1',40),
('& Holy Book of Prayers [Exorcism and Dispelling]',91,'?',%X'7E000000',0,900,261,30,1,-100,0,0,0,'1d1',40),
('& Small wooden chest' ,2,'&',%X'0F000000',0,20,1,250,1,0,0,0,0,'2d3',7),
('& Large wooden chest' ,2,'&',%X'15000000',0,60,4,500,1,0,0,0,0,'2d5',15),
('& Small iron chest' ,2,'&',%X'0F000000',0,100,7,300,1,0,0,0,0,'2d4',25),
('& Large iron chest' ,2,'&',%X'1F000000',0,150,10,1000,1,0,0,0,0,'2d6',35),
('& Small steel chest',2,'&',%X'0F000000',0,200,13,500,1,0,0,0,0,'2d4',45),
('& Large steel chest',2,'&',%X'23000000',0,250,16,1000,1,0,0,0,0,'2d6',50),
('& Rat Skeleton',1,'s',%X'00000000',0,0,1,10,1,0,0,0,0,'1d1',1),
('& Giant Centipede Skeleton' ,1,'s',%X'00000000',0,0,2,25,1,0,0,0,0,'1d1',1),
('Some filthy rags^ [%P6,%P4]',36,'~',%X'00000000',0,0,99,20,1,0,0,1,0,'0d0',0),
('& empty bottle',1,'!',%X'00000000',0,0,4,2,1,0,0,0,0,'1d1',0),
('Some shards of pottery',1,'~',%X'00000000',0,0,5,5,1,0,0,0,0,'1d1',0),
('& Human Skeleton',1,'s',%X'00000000',0,0,7,50,1,0,0,0,0,'1d1',1),
('& Dwarf Skeleton',1,'s',%X'00000000',0,0,8,60,1,0,0,0,0,'1d1',1),
('& Elf Skeleton',1,'s',%X'00000000',0,0,9,40,1,0,0,0,0,'1d1',1),
('& Gnome Skeleton',1,'s',%X'00000000',0,0,10,25,1,0,0,0,0,'1d1',1),
('& broken set of teeth',1,'s',%X'00000000',0,0,11,3,1,0,0,0,0,'1d1',0),
('& large broken bone',1,'s',%X'00000000',0,0,12,2,1,0,0,0,0,'1d1',0),    
('& broken stick',1,'~',%X'00000000',0,0,13,3,1,0,0,0,0,'1d1',0)
); 
 
{ Items which are sold in the stores are different from dungeon
  items so that identify works properly.  Note that the players
  recieve their initial items from this list,so position is
  very important..  }
 
        inventory_init :=       (
('& Ration~ of Food',80,',',%X'00000000',5000,3,307,10,5,0,0,0,0,'0d0',0),{  1}
('& Hard Biscuit~' ,80,',',%X'00000000',500,1,309,2,5,0,0,0,0,'0d0',0),{  2}
('& Strip~ of Beef Jerky',80,',',%X'00000000',1750,2,310,2,5,0,0,0,0,'0d0',0),{  3}
('& Pint of Fine Ale' ,80,',',%X'00000000',500,1,311,10,3,0,0,0,0,'0d0',0),{  4}
('& Pint of Fine Wine',80,',',%X'00000000',400,2,311,10,1,0,0,0,0,'0d0',0),{  5}
('& Dagger (Misercorde) (%P2,%P3)' ,23,'|',%X'00000000',0,10,2,15,1,0,0,0,0,'1d4',0),{  6}
('& Dagger (Stiletto) (%P2,%P3)',23,'|',%X'00000000',0,10,3,12,1,0,0,0,0,'1d4',0),{  7}
('& Bastard Sword (%P2,%P3)',23,'|',%X'00000000',0,350,7,140,1,0,0,0,0,'3d4',0),{  8}
('& Broadsword (%P2,%P3)',23,'|',%X'00000000',0,255,10,150,1,0,0,0,0,'2d5',0),{  9}
('& Longsword (%P2,%P3)',23,'|',%X'00000000',0,300,18,130,1,0,0,0,0,'1d10' ,0),{ 10}
('& Small Sword (%P2,%P3)' ,23,'|',%X'00000000',0,48,22,75,1,0,0,0,0,'1d6',0),{ 11}
('& Broad Axe (%P2,%P3)',21,'\',%X'00000000',0,304,4,160,1,0,0,0,0,'2d5',0),{ 12}
('& Morningstar (%P2,%P3)' ,21,'\',%X'00000000',0,396,9,150,1,0,0,0,0,'2d6',0),{ 13}
('& Mace (%P2,%P3)',21,'\',%X'00000000',0,130,10,120,1,0,0,0,0,'2d4',0),{ 14}
('& War Hammer (%P2,%P3)',21,'\',%X'00000000',0,225,11,120,1,0,0,0,0,'3d3',0),{ 15}
('& Halberd (%P2,%P3)',22,'/',%X'00000000',0,430,5,190,1,0,0,0,0,'3d4',0),{ 16}
('& Pike (%P2,%P3)',22,'/',%X'00000000',0,358,7,160,1,0,0,0,0,'2d5',0),{ 17}
('& Spear (%P2,%P3)',22,'/',%X'00000000',0,36,8,50,1,0,0,0,0,'1d6',0),{ 18}
('& Short Bow (%P2)',20,'}',%X'00000000',2,50,1,30,1,0,0,0,0,'1d1',0),{ 19}
('& Long Bow (%P2)',20,'}',%X'00000000',3,120,2,40,1,0,0,0,0,'1d1',0),{ 20}
('& Light Crossbow (%P2)',20,'}',%X'00000000',5,160,10,110,1,0,0,0,0,'1d1',0),{ 21}
('& Sling (%P2)',20,'}',%X'00000000',1,5,20,5,1,0,0,0,0,'0d0',0),{ 22}
('& Arrow~ (%P2,%P3)' ,12,'{',%X'00000000',0,1,1,2,1,0,0,0,0,'1d4',0),{ 23}
('& Bolt~ (%P2,%P3)',11,'{',%X'00000000',0,2,1,3,1,0,0,0,0,'1d5',0),{ 24}
('& Iron Shot~ (%P2,%P3)',10,'{',%X'00000000',0,2,1,5,1,0,0,0,0,'1d3',0),{ 25}
('& Pick (%P1) (%P2,%P3)',25,'\',%X'20000000',1,50,1,150,1,0,0,0,0,'1d3',0),{ 26}
('& Shovel (%P1) (%P2,%P3)',25,'\',%X'20000000',0,15,2,60,1,0,0,0,0,'1d2',0),{ 27}
('& Pair of Soft Leather Boots [%P6,%P4]',30,']',%X'00000000',0,7,2,30,1,0,0,2,0,'1d1',0),{ 28}
('& Pair of Hard Leather Boots [%P6,%P4]',30,']',%X'00000000',0,12,3,40,1,0,0,3,0,'1d1',0),{ 29}
('& Hard Leather Cap [%P6,%P4]' ,33,']',%X'00000000',0,12,2,15,1,0,0,2,0,'0d0',0),{ 30}
('& Metal Cap [%P6,%P4]',33,']',%X'00000000',0,30,3,20,1,0,0,3,0,'1d1',0),{ 31}
('& Iron Helm [%P6,%P4]',33,']',%X'00000000',0,75,4,75,1,0,0,5,0,'1d3',0),{ 32}
('Soft Leather Armor [%P6,%P4]' ,36,'(',%X'00000000',0,18,2,80,1,0,0,4,0,'0d0',0),{ 33}
('Soft Studded Leather [%P6,%P4]',36,'(',%X'00000000',0,35,3,90,1,0,0,5,0,'1d1',0),{ 34}
('Hard Leather Armor [%P6,%P4]' ,36,'(',%X'00000000',0,55,4,100,1,-1,0,6,0,'1d1',0),{ 35}
('Hard Studded Leather [%P6,%P4]',36,'(',%X'00000000',0,100,5,110,1,-1,0,7,0,'1d2',0),{ 36}
('Leather Scale Mail [%P6,%P4]' ,36,'(',%X'00000000',0,330,9,140,1,-1,0,11,0,'1d1',0),{ 37}
('Metal Scale Mail [%P6,%P4]' ,35,'[',%X'00000000',0,430,1,250,1,-2,0,13,0,'1d4',0),{ 38}
('Chain Mail [%P6,%P4]' ,35,'[',%X'00000000',0,530,2,220,1,-2,0,14,0,'1d4',0),{ 39}
('Partial Plate Armor [%P6,%P4]',35,'[',%X'00000000',0,900,9,260,1,-3,0,22,0,'1d6',0),{ 40}
('Full Plate Armor [%P6,%P4]' ,35,'[',%X'00000000',0,1050,11,380,1,-3,0,25,0,'2d4',0),{ 41}
('& Cloak [%P6,%P4]',32,'(',%X'00000000',0,3,1,10,1,0,0,1,0,'0d0',0),{ 42}
('& Set of Leather Gloves [%P6,%P4]',31,']',%X'00000000',0,3,1,5,1,0,0,1,0,'0d0',0),{ 43}
('& Set of Gauntlets [%P6,%P4]' ,31,']',%X'00000000',0,35,2,25,1,0,0,2,0,'1d1',0),{ 44}
('& Small Leather Shield [%P6,%P4]',34,')',%X'00000000',0,30,1,50,1,0,0,2,0,'1d1',0),{ 45}
('& Medium Leather Shield [%P6,%P4]',34,')',%X'00000000',0,60,2,75,1,0,0,3,0,'1d2',0),{ 46}
('& Small Metal Shield [%P6,%P4]',34,')',%X'00000000',0,50,4,65,1,0,0,3,0,'1d3',0),{ 47}
('& Ring of Resist Fire',45,'=',%X'00080000',0,250,11,2,1,0,0,0,0,'0d0',0),{ 48}
('& Ring of Resist Cold',45,'=',%X'00200000',0,250,12,2,1,0,0,0,0,'0d0',0),{ 49}
('& Ring of Feather Falling',45,'=',%X'04000000',0,250,13,2,1,0,0,0,0,'0d0',0),{ 50}
('& Ring of Protection [%P4]' ,45,'=',%X'00000000',0,100,24,2,1,0,0,0,0,'0d0',0),{ 51}
('& Amulet of Charisma (%P1)' ,40,'"',%X'00000020',0,250,6,3,1,0,0,0,0,'0d0',0),{ 52}
('& Amulet of Slow Digestion' ,40,'"',%X'00000080',0,200,9,3,1,0,0,0,0,'0d0',0),{ 53}
('& Amulet of Resist Acid' ,40,'"',%X'00100000',0,300,10,3,1,0,0,0,0,'0d0',0),{ 54}
('& Scroll~ of Enchant Weapon To-Hit' ,70,'?',%X'00000001',0,125,300,5,1,0,0,0,0,'0d0',0),{ 55}
('& Scroll~ of Enchant Weapon To-Dam' ,70,'?',%X'00000002',0,125,301,5,1,0,0,0,0,'0d0',0),{ 56}
('& Scroll~ of Enchant Armor' ,70,'?',%X'00000004',0,125,302,5,1,0,0,0,0,'0d0',0),{ 57}
('& Scroll~ of Identify',70,'?',%X'00000008',0,50,303,5,2,0,0,0,0,'0d0',0),{ 58}
('& Scroll~ of Remove Curse',70,'?',%X'00000010',0,100,304,5,1,0,0,0,0,'0d0',0),{ 59}
('& Scroll~ of Light' ,70,'?',%X'00000020',0,15,305,5,3,0,0,0,0,'0d0',0),{ 60}
('& Scroll~ of Phase Door' ,70,'?',%X'00000080',0,15,306,5,2,0,0,0,0,'0d0',0),{ 61}
('& Scroll~ of Magic Mapping' ,70,'?',%X'00000800',0,40,307,5,2,0,0,0,0,'0d0',0),{ 62}
('& Scroll~ of Treasure Detection' ,70,'?',%X'00004000',0,15,308,5,2,0,0,0,0,'0d0',0),{ 63}
('& Scroll~ of Object Detection',70,'?',%X'00008000',0,15,309,5,2,0,0,0,0,'0d0',0),{ 64}
('& Scroll~ of Detect Invisible',70,'?',%X'00080000',0,15,310,5,2,0,0,0,0,'0d0',0),{ 65}
('& Scroll~ of Recharging' ,70,'?',%X'01000000',0,200,311,5,1,0,0,0,0,'0d0',0),{ 66}
('& Book of Magic Spells [Beginners-Magik]',90,'?',%X'0000007F',0,25,257,30,1,-100,0,0,0,'1d1',0),{ 67}
('& Book of Magic Spells [Magik I]',90,'?',%X'0000FF80',0,100,258,30,1,-100,0,0,0,'1d1',0),{ 68}
('& Book of Magic Spells [Magik II]',90,'?',%X'00FF0000',0,400,259,30,1,-100,0,0,0,'1d1',0),{ 69}
('& Book of Magic Spells [The Mages Guide to Power]',90,'?',%X'7F000000',0,800,261,30,1,-100,0,0,0,'1d1',0),{ 70}
('& Holy Book of Prayers [Beginners Handbook]',91,'?',%X'000000FF',0,25,258,30,1,-100,0,0,0,'1d1',0),{ 71}
('& Holy Book of Prayers [Words of Wisdom]',91,'?',%X'0000FF00',0,100,259,30,1,-100,0,0,0,'1d1',0),{ 72}
('& Holy Book of Prayers [Chants and Blessings]',91,'?',%X'01FF0000',0,300,260,30,1,-100,0,0,0,'1d1',0),{ 73}
('& Holy Book of Prayers [Exorcism and Dispelling]',91,'?',%X'7E000000',0,900,261,30,1,-100,0,0,0,'1d1',0),{ 74}
('& Potion~ of Restore Strength',75,'!',%X'00000004',0,300,310,4,1,0,0,0,0,'1d1',0),{ 75}
('& Potion~ of Restore Intelligence',75,'!',%X'00000020',0,300,311,4,1,0,0,0,0,'1d1',0),{ 76}
('& Potion~ of Restore Wisdom',75,'!',%X'00000100',0,300,312,4,1,0,0,0,0,'1d1',0),{ 77}
('& Potion~ of Restore Charisma',75,'!',%X'00000800',0,300,313,4,1,0,0,0,0,'1d1',0),{ 78}
('& Potion~ of Cure Light Wounds',75,'!',%X'10001000',0,15,314,4,2,0,0,0,0,'1d1',0),{ 79}
('& Potion~ of Cure Serious Wounds',75,'!',%X'30002000',0,40,315,4,1,0,0,0,0,'1d1',0),{ 80}
('& Potion~ of Cure Critical Wounds',75,'!',%X'70004000',0,100,316,4,1,0,0,0,0,'1d1',0),{ 81}
('& Potion~ of Restore Dexterity',75,'!',%X'04000000',0,300,317,4,1,0,0,0,0,'1d1',0),{ 82}
('& Potion~ of Restore Constitution',75,'!',%X'68000000',0,300,318,4,1,0,0,0,0,'1d1',0),{ 83}
('& Potion~ of Heroism' ,76,'!',%X'00000010',0,35,319,4,2,0,0,0,0,'1d1',0),{ 84}
('& Potion~ of Boldliness' ,76,'!',%X'00000040',0,10,320,4,2,0,0,0,0,'1d1',0),{ 85}
('& Wand of Light (%P1 charges)',65,'-',%X'00000001',0,200,1,10,1,0,0,0,0,'1d1',2),{ 86}
('& Wand of Lightning Bolts (%P1 charges)' ,65,'-',%X'00000002',0,600,2,10,1,0,0,0,0,'1d1',6),{ 87}
('& Wand of Magic Missle (%P1 charges)' ,65,'-',%X'00002000',0,200,14,10,1,0,0,0,0,'1d1',2),{ 88}
('& Wand of Disarming (%P1 charges)',65,'-',%X'00020000',0,700,18,10,1,0,0,0,0,'1d1',12),{ 89}
('& Wand of Lightning Balls (%P1 charges)' ,65,'-',%X'00040000',0,1200,19,10,1,0,0,0,0,'1d1',20),{ 90}
('& Wand of Wonder (%P1 charges)',65,'-',%X'00200000',0,250,22,10,1,0,0,0,0,'1d1',10),{ 91}
('& Staff of Light (%P1 charges)',55,'_',%X'00000001',0,250,1,50,1,0,0,0,0,'1d2',3),{ 92}
('& Staff of Door/Stair Location (%P1 charges)' ,55,'_',%X'00000002',0,350,2,50,1,0,0,0,0,'1d2',7),{ 93}
('& Staff of Trap Location (%P1 charges)',55,'_',%X'00000004',0,350,3,50,1,0,0,0,0,'1d2',7),{ 94}
('& Staff of Detect Invisible (%P1 charges)',55,'_',%X'00008000',0,200,16,50,1,0,0,0,0,'1d2',3),{ 95}
('& Potion~ of Restore Life Levels',76,'!',%X'00000080',0,400,321,4,1,0,0,0,0,'1d1',0),{ 96}
('& Scroll~ of Blessing',71,'?',%X'00000020',0,15,312,5,2,0,0,0,0,'0d0',0),{ 97}
('& Scroll~ of Word-of-Recall',71,'?',%X'00000100',0,150,265,5,3,0,0,0,0,'0d0',0),{ 98}
('& Potion~ of Slow Poison',76,'!',%X'00000800',0,25,322,4,2,0,0,0,0,'1d1',0),{ 99}
('& Potion~ of Neutralize Poison',76,'!',%X'00001000',0,75,323,4,1,0,0,0,0,'1d1',0),{100}
('& Wand of Stinking Cloud (%P1 charges)',65,'-',%X'00200000',0,400,21,10,1,0,0,0,0,'1d1',5),{101}
('& Iron Spike~',13,'~',%X'00000000',0,1,1,10,1,0,0,0,0,'1d1',1),{102}
('& Brass Lantern~ with %P5 turns of light',15,'~',%X'00000000',7500,35,2,50,1,0,0,0,0,'1d1',1),{103}
('& Wooden Torch~ with %P5 turns of light' ,15,'~',%X'00000000',4000,2,270,30,5,0,0,0,0,'1d1',1),{104}
('& Flask~ of oil' ,77,'!',%X'00040000',7500,3,257,10,5,0,0,0,0,'2d6',1), {105}
('& Book of extra Spells [Consultants-Magik]',92,'?',%X'00000FFF',0,25,257,30,1,-100,0,0,0,'1d1',0){
106}
                                        );


        blk_mkt_init :=       (                                                       
                                   
('& Ration~ of Food'                           , 80, ',',  %X'00000000',
  5000,       30, 307,  10,   5,   0,   0,   0,   0,   '0d0', 50),      {  1}
('& Piece~ of Elvish Waybread'                 , 80, ',',  %X'02000020',
  8000,      100, 311,   3,   2,   0,   0,   0,   0,   '0d0', 50),      {  2}
('& Mushroom~ of Restoring'                    , 80, ',',  %X'001F8040',
  1000,    10000, 272,   1,   2,   0,   0,   0,   0,   '0d0', 50),      {  3}
('& Mushroom~ of Restore Constitution'         , 80, ',',  %X'00010000',
  1000,      700, 268,   1,   2,   0,   0,   0,   0,   '0d0', 50),      {  4}
('& Dagger (Main Gauche) (%P2,%P3)'            , 23, '|',  %X'00000000',
     0,    25000,   1,  30,   1,   0,   0,   0,   0,   '1d5', 50),      {  5}
('& Bastard Sword (%P2,%P3)'                   , 23, '|',  %X'00000000',
     0,    35000,   7, 140,   1,   0,   0,   0,   0,   '3d4', 50),      {  6}
('& Broadsword (%P2,%P3)'                      , 23, '|',  %X'00000000',  
     0,    25500,  10, 150,   1,   0,   0,   0,   0,   '2d5', 50),      {  7}
('& Two Handed Sword (Claymore) (%P2,%P3)'     , 23, '|',  %X'00000000',
     0,    77500,  11, 200,   1,   0,   0,   0,   0,   '3d6', 50),      {  8}
('& Two Handed Sword (Espadon) (%P2,%P3)'      , 23, '|',  %X'00000000',
     0,    67500,  13, 180,   1,   0,   0,   0,   0,   '3d6', 50),      {  9}
('& Executioner''s Sword (%P2,%P3)'            , 23, '|',  %X'00000000',
     0,    85000,  14, 260,   1,   0,   0,   0,   0,   '4d5', 50),      { 10}
('& Two Handed Sword (Flamberge) (%P2,%P3)'    , 23, '|',  %X'00000000',
     0,   100000,  15, 240,   1,   0,   0,   0,   0,   '4d5', 50),      { 11}
('& Longsword (%P2,%P3)'                       , 23, '|',  %X'00000000',
     0,    30000,  18, 130,   1,   0,   0,   0,   0,  '1d10', 50),      { 12}
('& Two Handed Sword (No-Dachi) (%P2,%P3)'     , 23, '|',  %X'00000000',
     0,    67500,  19, 200,   1,   0,   0,   0,   0,   '4d4', 50),      { 13}
('& Small Sword (%P2,%P3)'                     , 23, '|',  %X'00000000',
     0,     4800,  22,  75,   1,   0,   0,   0,   0,   '1d6', 50),      { 14}
('& Two Handed Sword (Zweihander) (%P2,%P3)'   , 23, '|',  %X'00000000',
     0,   100000,  23, 280,   1,   0,   0,   0,   0,   '4d6', 50),      { 15}
('& Battle Axe (Balestarius) (%P2,%P3)'        , 21, '\',  %X'00000000',
     0,    50000,   1, 180,   1,   0,   0,   0,   0,   '2d8', 50),      { 16}
('& Battle Axe (European) (%P2,%P3)'           , 21, '\',  %X'00000000',
    0,     33400,   3, 170,   1,   0,   0,   0,   0,   '3d4', 50),      { 17}
('& Broad Axe (%P2,%P3)'                       , 21, '\',  %X'00000000',
    0,     30400,   4, 160,   1,   0,   0,   0,   0,   '2d6', 50),      { 18}
('& Two Handed Great Flail (%P2,%P3)'          , 21, '\',  %X'00000000',
    0,     59000,   8, 280,   1,   0,   0,   0,   0,   '3d6', 50),      { 19}
('& Morningstar (%P2,%P3)'                     , 21, '\',  %X'00000000',
    0,     39600,   9, 150,   1,   0,   0,   0,   0,   '2d6', 50),      { 20}
('& Mace (%P2,%P3)'                            , 21, '\',  %X'00000000',
    0,     13000,  10, 120,   1,   0,   0,   0,   0,   '2d4', 50),      { 21}
('& War Hammer (%P2,%P3)'                      , 21, '\',  %X'00000000',
    0,     22500,  11, 120,   1,   0,   0,   0,   0,   '3d3', 50),      { 22}
('& Mace (Lead filled) (%P2,%P3)'              , 21, '\',  %X'00000000',
    0,     50200,  12, 180,   1,   0,   0,   0,   0,   '3d4', 50),      { 23}
('& Beaked Axe (%P2,%P3)'                      , 22, '/',  %X'00000000',
    0,     40800,   2, 180,   1,   0,   0,   0,   0,   '2d6', 50),      { 24}
('& Glaive (%P2,%P3)',22,'/',%X'00000000',
0,36300,4,190,1,0,0,0,0,'2d6',50),      { 25}
('& Halberd (%P2,%P3)',22,'/',%X'00000000',
0,43000,5,190,1,0,0,0,0,'3d4',50),      { 26}
('& Lucerne Hammer (%P2,%P3)'  , 22, '/',  %X'00000000',
0,37600,6,120,1,0,0,0,0,'2d5',50),      { 27}
('& Pike (%P2,%P3)'   ,22, '/',  %X'00000000',
0,35800,7,160,1,0,0,0,0,'2d5',50),      { 28}
('& Lance (%P2,%P3)'    ,22,'/',%X'00000000',
0,23000,9,300,1,0,0,0,0,'2d8',50),      { 29}
('& Short Bow (%P2)'    ,20,'}',%X'00000000',
2,5000,1,30,1,0,0,0,0,'1d1',50),      { 30}
('& Long Bow (%P2)'   ,20,'}',%X'00000000',
3,12000,2,40,1,0,0,0,0,'1d1',50),      { 31}
('& Composite Bow (%P2)'   ,20,'}',%X'00000000',
4,24000,3,40,1,0,0,0,0,'1d1',50),      { 32}
('& Light Crossbow (%P2)'    ,20,'}',%X'00000000',
5,14000,10,110,1,0,0,0,0,'1d1',50),      { 33}
('& Heavy Crossbow (%P2)'    ,20,'}',%X'00000000',
6,30000,11,200,1,0,0,0,0,'1d1',50),      { 34}
('& Sling (%P2)'   ,20,'}',%X'00000000',
1,500,20,5,1,0,0,0,0,'0d0',50),      { 35}
('& Arrow~ (%P2,%P3)'   ,12,'{',%X'00000000',
0,100,1,2,1,0,0,0,0,'1d4',50),      { 36}
('& Bolt~ (%P2,%P3)'    ,11,'{',%X'00000000',
0,200,1,3,1,0,0,0,0,'1d5',50),      { 37}
('& Rounded Pebble~ (%P2,%P3)'    ,10,'{',%X'00000000',
0,100,1,4,1,0,0,0,0,'1d2',50),      { 38}
('& Iron Shot~ (%P2,%P3)'    ,10,'{',%X'00000000',
0,200,1,5,1,0,0,0,0,'1d3',50),      { 39}
('& Brass Lantern~ with %P5 turns of light',15,'~',%X'00000000',
7500,3500,1,50,1,0,0,0,0,'1d1',50),      { 40}
('& Orcish Pick (%P1) (%P2,%P3)'  ,25,'\',%X'20000000',
2,50000,2,180,1,0,0,0,0,'1d5',50),      { 41}
('& Dwarven Pick (%P1) (%P2,%P3)'    ,25,'\',%X'20000000',
3,120000,3,200,1,0,0,0,0,'2d5',50),      { 42}
('& Gnomish Shovel (%P1) (%P2,%P3)'  ,25,'\',%X'20000000',
1,10000,5,50,1,0,0,0,0,'1d2',50),      { 43}
('& Dwarven Shovel (%P1) (%P2,%P3)'  ,25,'\',%X'20000000',
2,25000,6,120,1,0,0,0,0,'1d3',50),      { 44}
('& Pair of Hard Leather Boots [%P6,%P4]'   ,30,']',%X'00000000',
0,1200,3,40,1,0,0,3,0,'1d1',50),      { 45}
('& Hard Leather Cap [%P6,%P4]'  ,33,']',%X'00000000',
0,1200,2,15,1,0,0,2,0,'0d0',50),      { 46}
('& Metal Cap [%P6,%P4]'  ,33,']',%X'00000000',
0,3000,3,20,1,0,0,3,0,'1d1',50),      { 47}
('& Iron Helm [%P6,%P4]'  ,33,']',%X'00000000',
0,7500,4,75,1,0,0,5,0,'1d3',50),      { 48}
('& Steel Helm [%P6,%P4]'    ,33,']',%X'00000000',
0,20000,5,60,1,0,0,6,0,'1d3',50),      { 49}
('& Silver Crown (%P1)'   ,33,']',%X'00000000',
0,25000,6,20,1,0,0,0,0,'1d1',50),      { 50}
('& Golden Crown (%P1)'   ,33,']',%X'00000000',
0,50000,7,30,1,0,0,0,0,'1d1',50),      { 51}
('& Jewel Encrusted Crown (%P1)'   ,33,']',%X'00000000',
0,100000,8,40,1,0,0,0,0,'1d1',50),      { 52}
('Double Chain Mail [%P6,%P4]'    ,35,'[',%X'00000000',
0,63000,4,260,1,-2,0,15,0,'1d4',50),      { 53}
('Augmented Chain Mail [%P6,%P4]'    ,35,'[',%X'00000000',
0,67500,5,270,1,-2,0,16,0,'1d4',50),      { 54}
('Bar Chain Mail [%P6,%P4]'   ,35,'[',%X'00000000',
0,72000,6,280,1,-2,0,18,0,'1d4',50),      { 55}
('Metal Brigandine Armor [%P6,%P4]'   ,35,'[',%X'00000000',
0,77500,7,290,1,-3,0,19,0,'1d4',50),      { 56}
('Laminated Armor [%P6,%P4]'    ,35,'[',%X'00000000',
0,82500,8,300,1,-3,0,20,0,'1d4',50),      { 57}
('Partial Plate Armor [%P6,%P4]'   ,35,'[',%X'00000000',
0,90000,9,260,1,-3,0,22,0,'1d6',50),      { 58}
('Metal Lamellar Armor [%P6,%P4]'    ,35,'[',%X'00000000',
0,95000,10,340,1,-3,0,23,0,'1d6',50),      { 59}
('Full Plate Armor [%P6,%P4]'   ,35,'[',%X'00000000',
0,105000,11,380,1,-3,0,25,0,'2d4',50),      { 60}
('Ribbed Plate Armor [%P6,%P4]'   ,35,'[',%X'00000000',       
0,120000,12,380,1,-3,0,28,0,'2d4',50),      { 61}
('& Cloak [%P6,%P4]'    ,32,'(',%X'00000000',
0,300,1,10,1,0,0,1,0,'0d0',50),      { 62}
('& Set of Leather Gloves [%P6,%P4]'    ,31,']',%X'00000000',
0,300,1,5,1,0,0,1,0,'0d0',50),      { 63}
('& Set of Gauntlets [%P6,%P4]'   ,31,']',%X'00000000',
0,3500,2,25,1,0,0,2,0,'1d1',50),      { 64}
('& Small Leather Shield [%P6,%P4]'   ,34,')',%X'00000000',
0,3000,1,50,1,0,0,2,0,'1d1',50),      { 65}
('& Medium Leather Shield [%P6,%P4]'    ,34,')',%X'00000000',
0,6000,2,75,1,0,0,3,0,'1d2',50),      { 66}
('& Large Leather Shield [%P6,%P4]'   ,34,')',%X'00000000',
0,12000,3,100,1,0,0,4,0,'1d2',50),      { 67}
('& Small Metal Shield [%P6,%P4]'    ,34,')',%X'00000000',
0,5000,4,65,1,0,0,3,0,'1d2',50),      { 68}
('& Medium Metal Shield [%P6,%P4]'   ,34,')',%X'00000000',
0,12500,5,90,1,0,0,4,0,'1d3',50),      { 69}
('& Large Metal Shield [%P6,%P4]'    ,34,')',%X'00000000',
0,20000,6,120,1,0,0,5,0,'1d3',50),      { 70}
('& Ring of Gain Strength (%P1)'       ,45,'=',%X'00000001',
0,40000,1,2,1,0,0,0,0,'0d0',50),      { 71}
('& Ring of Gain Dexterity (%P1)'      ,45,'=',%X'00000002',
0,40000,2,2,1,0,0,0,0,'0d0',50),      { 72}
('& Ring of Gain Constitution (%P1)'      ,45,'=',%X'00000004',
0,40000,3,2,1,0,0,0,0,'0d0',50),      { 73}
('& Ring of Gain Intelligence (%P1)'      ,45,'=',%X'00000008',
0,35000,4,2,1,0,0,0,0,'0d0',50),      { 74}
('& Ring of Speed (%P1)'       ,45,'=',%X'00001000',
0,300000,7,2,1,0,0,0,0,'0d0',50),      { 75}
('& Ring of Searching (%P1)'      ,45,'=',%X'00000040',
0,25000,8,2,1,0,0,0,0,'0d0',50),      { 76}
('& Ring of Slow Digestion'   ,45,'=',%X'00000080',
0,25000,10,2,1,0,0,0,0,'0d0',50),      { 77}
('& Ring of Feather Falling'   ,45,'=',%X'04000000',
0,20000,13,2,1,0,0,0,0,'0d0',50),      { 78}
('& Ring of Lordly Protection (FIRE)'   ,45,'=',%X'00080000',
0,120000,17,2,1,0,0,0,5,'0d0',50),      { 79}
('& Ring of Lordly Protection (ACID)'   ,45,'=',%X'00100000',
0,120000,18,2,1,0,0,0,5,'0d0',50),      { 80}
('& Ring of Lordly Protection (COLD)'   ,45,'=',%X'00200000',
0,120000,19,2,1,0,0,0,5,'0d0',50),      { 81}
('& Ring of Increase Damage (%P3)'    ,45,'=',%X'00000000',
0,10000,22,2,1,0,0,0,0,'0d0',50),      { 82}
('& Ring of Increase To-Hit (%P2)'    ,45,'=',%X'00000000',
0,10000,23,2,1,0,0,0,0,'0d0',50),      { 83}
('& Ring of Protection [%P4]'    ,45,'=',%X'00000000',
0,10000,24,2,1,0,0,0,0,'0d0',50),      { 84}
('& Ring of See Invisible'    ,45,'=',%X'01000000',
0,34000,26,2,1,0,0,0,0,'0d0',50),      { 85}
('& Ring of Slaying'   ,45,'=',%X'00000000',
6,100000,33,2,1,0,0,0,0,'0d0',50),      { 86}
('& Amulet of Wisdom (%P1)'     ,40,'"',%X'00000010',
0,30000,1,3,1,0,0,0,0,'0d0',50),      { 87}
('& Amulet of Charisma (%P1)'      ,40,'"',%X'00000020',
0,25000,2,3,1,0,0,0,0,'0d0',50),      { 88}
('& Amulet of Searching (%P1)'     ,40,'"',%X'00000040',
0,25000,3,3,1,0,0,0,0,'0d0',50),      { 89}
('& Amulet of Slow Digestion'     ,40,'"',%X'00000080',
0,20000,4,3,1,0,0,0,0,'0d0',50),      { 90}
('& Amulet of the Magi'     ,40,'"',%X'01800040',
0,500000,5,3,1,0,0,0,3,'0d0',50),      { 91}
('& Scroll~ of Enchant Weapon To-Hit'     ,70,'?',%X'00000001',
0,12500,257,5,1,0,0,0,0,'0d0',50),      { 92}
('& Scroll~ of Enchant Weapon To-Dam'     ,70,'?',%X'00000002',
0,12500,258,5,1,0,0,0,0,'0d0',50),      { 93}
('& Scroll~ of Enchant Armor'     ,70,'?',%X'00000004',
0,12500,259,5,1,0,0,0,0,'0d0',50),      { 94}
('& Scroll~ of Identify'     ,70,'?',%X'00000008',
0,5000,260,5,1,0,0,0,0,'0d0',50),      { 95}
('& Scroll~ of Teleport'     ,70,'?',%X'00000100',
0,4000,265,5,1,0,0,0,0,'0d0',50),      { 96}
('& Scroll~ of Teleportation'      ,70,'?',%X'00000200',
0,9000,266,5,1,0,0,0,0,'0d0',50),      { 97}
('& Scroll~ of Rune of Protection'     ,70,'?',%X'00002000',
0,50000,270,5,1,0,0,0,0,'0d0',50),      { 98}
('& Scroll~ of Door/Stair Location'      ,70,'?',%X'00020000',
0,3500,274,5,1,0,0,0,0,'0d0',50),      { 99}
('& Scroll~ of Mass Genocide'     ,70,'?',%X'00040000',
0,100000,275,5,1,0,0,0,0,'0d0',50),      {100}
('& Scroll~ of Detect Invisible'     ,70,'?',%X'00080000',
0,1500,276,5,1,0,0,0,0,'0d0',50),      {101}
('& Scroll~ of Recharging'     ,70,'?',%X'01000000',
0,2000,281,5,1,0,0,0,0,'0d0',50),      {102}
('& Scroll~ of Genocide'     ,70,'?',%X'02000000',
0,75000,282,5,1,0,0,0,0,'0d0',50),      {103}
('& Scroll~ of Protection from Evil'     ,70,'?',%X'08000000',
0,5000,284,5,1,0,0,0,0,'0d0',50),      {104}
('& Scroll~ of Dispell Undead'      ,70,'?',%X'20000000',
0,20000,286,5,1,0,0,0,0,'0d0',50),      {105}
('& Scroll~ of *Enchant Weapon*'     ,71,'?',%X'00000001',
0,50000,257,5,1,0,0,0,0,'0d0',50),      {106}
('& Scroll~ of *Enchant Armor*'     ,71,'?',%X'00000004',
0,50000,259,5,1,0,0,0,0,'0d0',50),      {107}
('& Scroll~ of Word-of-Recall'      ,71,'?',%X'00000100',
0,15000,265,5,1,0,0,0,0,'0d0',50),      {108}
('& Scroll~ of *Destruction*'     ,71,'?',%X'00000200',
0,25000,266,5,1,0,0,0,0,'0d0',50),      {109}
('& Potion~ of Gain Strength'     ,75,'!',%X'00000001',
0,20000,257,4,1,0,0,0,0,'1d1',50),      {110}
('& Potion~ of Restore Strength'     ,75,'!',%X'00000004',
0,30000,259,4,1,0,0,0,0,'1d1',50),      {111}
('& Potion~ of Gain Intelligence'      ,75,'!',%X'00000008',
0,30000,260,4,1,0,0,0,0,'1d1',50),      {112}
('& Potion~ of Restore Intelligence'     ,75,'!',%X'00000020',
0,30000,262,4,1,0,0,0,0,'1d1',50),      {113}
('& Potion~ of Gain Wisdom'      ,75,'!',%X'00000040',
0,30000,263,4,1,0,0,0,0,'1d1',50),      {114}
('& Potion~ of Restore Wisdom'      ,75,'!',%X'00000100',
0,30000,265,4,1,0,0,0,0,'1d1',50),      {115}
('& Potion~ of Charisma'     ,75,'!',%X'00000200',
0,30000,266,4,1,0,0,0,0,'1d1',50),      {116}
('& Potion~ of Restore Charisma'     ,75,'!',%X'00000800',
0,30000,268,4,1,0,0,0,0,'1d1',50),      {117}
('& Potion~ of Gain Constitution'      ,75,'!',%X'00010000',
0,30000,273,4,1,0,0,0,0,'1d1',50),      {118}
('& Potion~ of Gain Experience'     ,75,'!',%X'00020000',
0,250000,274,4,1,0,0,0,0,'1d1',50),      {119}
('& Potion~ of Haste Self'     ,75,'!',%X'00400000',
0,7500,279,4,1,0,0,0,0,'1d1',50),      {120}
('& Potion~ of Gain Dexterity'      ,75,'!',%X'02000000',
0,30000,284,4,1,0,0,0,0,'1d1',50),      {121}
('& Potion~ of Restore Dexterity'      ,75,'!',%X'04000000',
0,30000,285,4,1,0,0,0,0,'1d1',50),      {122}
('& Potion~ of Restore Constitution'     ,75,'!',%X'68000000',
0,30000,286,4,1,0,0,0,0,'1d1',50),      {123}
('& Potion~ of Learning'     ,76,'!',%X'00000001',
0,20000,287,4,1,0,0,0,0,'1d1',50),      {124}
('& Potion~ of Invulnerability'     ,76,'!',%X'00000008',
0,25000,290,4,1,0,0,0,0,'1d1',50),      {125}
('& Potion~ of Restore Life Levels'      ,76,'!',%X'00000080',
0,40000,294,4,1,0,0,0,0,'1d1',50),      {126}
('& Potion~ of Detect Invisible'     ,76,'!',%X'00000400',
0,5000,297,4,1,0,0,0,0,'1d1',50),      {127}
('& Potion~ of Neutralize Poison'      ,76,'!',%X'00001000',
0,7500,299,4,1,0,0,0,0,'1d1',50),      {128}
('& Potion~ of Restore Mana'     ,76,'!',%X'00002000',
0,3500,300,4,1,0,0,0,0,'1d1',50),      {129}
('& Potion~ Infra-Vision'      ,76,'!',%X'00004000',
0,2000,301,4,1,0,0,0,0,'1d1',50),      {130}
('& Flask~ of oil',77,'!',%X'00040000',
7500,300,257,10,1,0,0,0,0,'2d6',50),      {131}
('& Wand of Light (%P1 charges)'           ,65,'-',%X'00000001',
0,20000,1,10,1,0,0,0,0,'1d1',50),      {132}
('& Wand of Lightning Bolts (%P1 charges)'      ,65,'-',%X'00000002',
0,60000,2,10,1,0,0,0,0,'1d1',50),      {133}
('& Wand of Frost Bolts (%P1 charges)'     ,65,'-',%X'00000004',
0,80000,3,10,1,0,0,0,0,'1d1',50),      {134}
('& Wand of Fire Bolts (%P1 charges)'      ,65,'-',%X'00000008',
0,100000,4,10,1,0,0,0,0,'1d1',50),      {135}
('& Wand of Stone-to-Mud (%P1 charges)'     ,65,'-',%X'00000010',
0,30000,5,10,1,0,0,0,0,'1d1',50),      {136}
('& Wand of Polymorph (%P1 charges)'     ,65,'-',%X'00000020',
0,40000,6,10,1,0,0,0,0,'1d1',50),      {137}
('& Wand of Slow Monster (%P1 charges)'     ,65,'-',%X'00000100',
0,50000,9,10,1,0,0,0,0,'1d1',50),      {138}
('& Wand of Confuse Monster (%P1 charges)'      ,65,'-',%X'00000200',
0,40000,10,10,1,0,0,0,0,'1d1',50),      {139}
('& Wand of Sleep Monster (%P1 charges)'      ,65,'-',%X'00000400',
0,50000,11,10,1,0,0,0,0,'1d1',50),      {140}
('& Wand of Drain Life (%P1 charges)'      ,65,'-',%X'00000800',
0,120000,12,10,1,0,0,0,0,'1d1',50),      {141}
('& Wand of Trap/Door destruction (%P1 charges)'     ,65,'-',%X'00001000',
0,10000,13,10,1,0,0,0,0,'1d1',50),      {142}
('& Wand of Magic Missle (%P1 charges)'     ,65,'-',%X'00002000',
0,20000,14,10,1,0,0,0,0,'1d1',50),      {143}
('& Wand of Wall Building (%P1 charges)'      ,65,'-',%X'00004000',
0,40000,15,10,1,0,0,0,0,'1d1',50),      {144}
('& Wand of Clone Monster (%P1 charges)'      ,65,'-',%X'00008000',
0,15000,16,10,1,0,0,0,0,'1d1',50),      {145}
('& Wand of Teleport Away (%P1 charges)'      ,65,'-',%X'00010000',
0,35000,17,10,1,0,0,0,0,'1d1',50),      {146}
('& Wand of Disarming (%P1 charges)'     ,65,'-',%X'00020000',
0,70000,18,10,1,0,0,0,0,'1d1',50),      {147}
('& Wand of Lightning Balls (%P1 charges)'      ,65,'-',%X'00040000',
0,120000,19,10,1,0,0,0,0,'1d1',50),      {148}
('& Wand of Cold Balls (%P1 charges)'      ,65,'-',%X'00080000',
0,150000,20,10,1,0,0,0,0,'1d1',50),      {149}
('& Wand of Fire Balls (%P1 charges)'      ,65,'-',%X'00100000',
0,180000,21,10,1,0,0,0,0,'1d1',50),      {150}
('& Wand of Stinking Cloud (%P1 charges)'     ,65,'-',%X'00200000',
0,40000,21,10,1,0,0,0,0,'1d1',50),      {151}
('& Wand of Acid Balls (%P1 charges)'      ,65,'-',%X'00400000',
0,165000,21,10,1,0,0,0,0,'1d1',50),      {152}
('& Wand of Wonder (%P1 charges)'     ,65,'-',%X'00800000',
0,25000,22,10,1,0,0,0,0,'1d1',50),      {153}
('& Staff of Light (%P1 charges)'     ,55,'_',%X'00000001',
0,25000,1,50,1,0,0,0,0,'1d2',50),      {154}
('& Staff of Door/Stair Location (%P1 charges)'     ,55,'_',%X'00000002',
0,35000,2,50,1,0,0,0,0,'1d2',50),      {155}
('& Staff of Trap Location (%P1 charges)'     ,55,'_',%X'00000004',
0,35000,3,50,1,0,0,0,0,'1d2',50),      {156}
('& Staff of Treasure Location (%P1 charges)'      ,55,'_',%X'00000008',
0,20000,4,50,1,0,0,0,0,'1d2',50),      {157}
('& Staff of Object Location (%P1 charges)'     ,55,'_',%X'00000010',
0,20000,5,50,1,0,0,0,0,'1d2',50),      {158}
('& Staff of Teleportation (%P1 charges)'     ,55,'_',%X'00000020',
0,40000,6,50,1,0,0,0,0,'1d2',50),      {159}
('& Staff of Earthquakes (%P1 charges)'     ,55,'_',%X'00000040',
0,35000,7,50,1,0,0,0,0,'1d2',50),      {160}
('& Staff of Summoning (%P1 charges)'      ,55,'_',%X'00000080',
0,20000,8,50,1,0,0,0,0,'1d2',50),      {161}
('& Staff of *Destruction* (%P1 charges)'     ,55,'_',%X'00000200',
0,250000,10,50,1,0,0,0,0,'1d2',50),      {162}
('& Staff of Starlite (%P1 charges)'     ,55,'_',%X'00000400',
0,80000,11,50,1,0,0,0,0,'1d2',50),      {163}
('& Staff of Slow Monsters (%P1 charges)'     ,55,'_',%X'00001000',
0,80000,13,50,1,0,0,0,0,'1d2',50),      {164}
('& Staff of Sleep Monsters (%P1 charges)'      ,55,'_',%X'00002000',
0,70000,14,50,1,0,0,0,0,'1d2',50),      {165}
('& Staff of Detect Invisible (%P1 charges)'     ,55,'_',%X'00008000',
0,20000,16,50,1,0,0,0,0,'1d2',50),      {166}
('& Staff of Speed (%P1 charges)'     ,55,'_',%X'00010000',
0,80000,17,50,1,0,0,0,0,'1d2',50),      {167}
('& Staff of Mass Polymorph (%P1 charges)'      ,55,'_',%X'00040000',
0,75000,19,50,1,0,0,0,0,'1d2',50),      {168}
('& Staff of Remove Curse (%P1 charges)'      ,55,'_',%X'00080000',
0,50000,20,50,1,0,0,0,0,'1d2',50),      {169}
('& Staff of Detect Evil (%P1 charges)'     ,55,'_',%X'00100000',
0,35000,21,50,1,0,0,0,0,'1d2',50),      {170}
('& Staff of Curing (%P1 charges)'      ,55,'_',%X'00200000',
0,100000,22,50,1,0,0,0,0,'1d2',50),      {171}
('& Staff of Dispell Evil (%P1 charges)'      ,55,'_',%X'00400000',
0,120000,23,50,1,0,0,0,0,'1d2',50),      {172}
('& Magic Book [Beginners-Magik+Magik I]',90,'?',%X'0000FFFF',
0,40000,257,30,1,-100,0,0,0,'1d1',50),      {173}
('& Magic Book [Magik II+Mages Guide to Power]',90,'?',%X'7FFF0000',
0,80000,259,30,1,-100,0,0,0,'1d1',50),      {174}
('& Prayer Book [Beginners Handbook+Words of Wisdom]',91,'?',%X'0000FFFF',
0,2500,258,30,1,-100,0,0,0,'1d1',50),      {175}
('& Prayer Book [Chants+Blessings+Exorcism+Dispelling]',91,'?',%X'7FFF0000',
0,90000,261,30,1,-100,0,0,0,'1d1',50)); 
                    


        store_choice    :=      (
{ General Store }
(105,104,103,102,102,104,42,105,104,27,26,5,4,3,3,2,2,2,1,1,1,1,1,1,1,1),
{ Armory }
(30,31,32,33,34,35,36,37,38,39,40,41,43,44,45,46,47,30,33,34,43,44,28,29,30,31),
{ Weaponsmith }
( 6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23,24,25,6,7,23,25,23,25),
{ Temple }
(71,72,73,74,59,59,77,79,80,81,84,85,13,14,15,96,97,98,100,79,79,80,80,81,72,98),
{ Alchemy shop }
(55,56,57,58,58,60,61,62,63,64,65,66,75,76,78,82,83,60,61,62,63,64,98,99,98,98),
{ Magic-User store}                                                        
(67,49,50,51,52,53,54,48,68,
69,69,70,86,87,88,89,90,91,92,93,94,95,86,101,68,88),
{Black Market}
(1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1)
                                );
 
{ Each store will buy only certain items,based on TVAL }
        store_buy := (                                                    
       [25,30,32,80,77,15,13],
       [30,31,33,34,35,36],
       [10,11,12,20,21,22,23],
       [21,70,71,75,76,91],
       [70,71,75,76],
       [40,45,55,65,70,71,75,76,90],
       [11,12,20,21,22,23,30,31,32,33,34,35,40,45,55,60,65,70,71,75,76,90,91,92]);
 
{ Store owners have different characteristics for pricing and haggling
  Note: Store owners should be added in groups,one for each store }
        owners := (
('Erick the Honest       (Human)      General Store',250,0.75,0.08,0.04,1,12),
('Mauglin the Grumpy     (Dwarf)      Armory',32000,1.00,0.12,0.04,6,5),
('Arndal Beast-Slayer    (Half-Elf)   Weaponsmith',10000,0.85,0.10,0.05,2,8),
('Hardblow the Humble    (Human)      Temple',3500,0.75,0.09,0.06,1,15),
('Ga-nat the Greedy      (Gnome)      Alchemist',12000,1.20,0.15,0.04,5,9),
('Valeria Starshine      (Elf)        Magic Shop',32000,0.75,0.10,0.05,3,11),
('Ugluk the Ugly         (Orc)        Black Market',10000000,2.5,1.5,0.01,7,6),
('Andy the Friendly      (Halfling)   General Store',200,0.70,0.08,0.05,4,15),
('Darg-Low the Grim      (Human)      Armory',10000,0.90,0.11,0.04,1,9),
('Oglign Dragon-Slayer   (Dwarf)      Weaponsmith',32000,0.95,0.12,0.04,6,8),
('Gunnar the Paladin     (Human)      Temple',5000,0.85,0.10,0.05,1,23),
('Mauser the Chemist     (Half-Elf)   Alchemist',10000,0.90,0.11,0.05,2,8),
('Gopher the Great!      (Gnome)      Magic Shop',20000,1.15,0.13,0.06,5,10),
('Gloin the Fierce       (Dwarf)      Black Market',20000000,2.5,1.5,0.01,6,4),
('Lyar-el the Comely     (Elf)        General Store',300,0.65,0.07,0.06,3,18),
('Mauglim the Horrible   (Half-Orc)   Armory',3000,1.00,0.13,0.05,7,9),
('Ithyl-Mak the Beastly  (Half-Troll) Weaponsmith',3000,1.10,0.15,0.06,8,8),
('Delihla the Pure       (Half-Elf)   Temple',25000,0.80,0.07,0.06,2,20),
('Wizzle the Chaotic     (Halfling)   Alchemist',10000,0.90,0.10,0.06,4,8),
('Inglorian the Mage     (Human?)     Magic Shop',32000,1.00,0.10,0.07,1,10),
('Grima Wormtongue       (Human?)     Black Market',15000000,2.5,1.5,0.01,1,5));
 
{ Each type of character starts out with a few provisions...
  NOTE: the the entries refer to array elements of INVENTORY_INIT array}
        player_init := (                                                     
                (1,104,42,7,33),{ Warrior }
                (1,104,42,7,67),{ Mage    }
                (1,104,42,7,71),{ Priest  }
                (1,104,42,7,33),{ Rogue   }
                (1,104,42,7,67),{ Ranger  }       
                (1,104,42,7,71),{ Paladin }
                (1,104,42,7,106),{ Consultant }
                (1,104,42,7,106));{ Consultant }
        
 
{ Identified objects flags }
        object_ident := (max_objects of false);
 
{ Traps are just Nasty treasures... }
        trap_lista := (                    
('an open pit',102,' ',%X'00000000',0,0,1,0,0,0,0,0,0,'2d6',-50),
('an arrow trap',101,'.',%X'00000000',0,0,2,0,0,0,0,0,0,'1d8',0),
('a covered pit',101,'.',%X'00000000',0,0,3,0,0,0,0,0,0,'2d6',0),
('a trap door',101,'.',%X'00000000',0,0,4,0,0,0,0,0,0,'2d8',0),
('a gas trap' ,101,'.',%X'00000000',0,0,5,0,0,0,0,0,0,'1d4',0),
('a loose rock' ,101,'.',%X'00000000',0,0,6,0,0,0,0,0,0,'0d0',0),
('a dart trap',101,'.',%X'00000000',0,0,7,0,0,0,0,0,0,'1d4',0),
('a strange rune',101,'.',%X'00000000',0,0,8,0,0,0,0,0,0,'0d0',0),
('some loose rock' ,101,'.',%X'00000000',0,0,9,0,0,0,0,0,0,'2d6',0),
('a gas trap' ,101,'.',%X'00000000',0,0,10,0,0,0,0,0,0,'1d4',0),
('a strange rune',101,'.',%X'00000000',0,0,11,0,0,0,0,0,0,'0d0',0),
('a blackened spot',101,'.',%X'00000000',0,0,12,0,0,0,0,0,0,'4d6',0),
('some corroded rock',101,'.',%X'00000000',0,0,13,0,0,0,0,0,0,'4d6',0),
('a gas trap',101,'.',%X'00000000',0,0,14,0,0,0,0,0,0,'2d6',0),
('a gas trap',101,'.',%X'00000000',5,0,15,0,0,0,0,0,0,'1d4',10),
('a bomb',101,'.',%X'00000000',5,0,16,0,0,0,0,0,0,'10d6',5),
('a dart trap',101,'.',%X'00000000',5,0,17,0,0,0,0,0,0,'1d8',10),
('a dart trap',101,'.',%X'00000000',5,0,18,0,0,0,0,0,0,'1d8',10),
('a teleport trap',101,'.',%X'00000000',5,0,20,0,0,0,0,0,0,'0d0',10));
 
{ Traps: Level represents the difficulty of disarming; 
         and P1 represents the experienced gained when disarmed}
        trap_listb := (
('an open pit',102,' ',%X'00000000',1,0,1,0,0,0,0,0,0,'2d6',-50),
('an arrow trap',102,'^',%X'00000000',3,0,2,0,0,0,0,0,0,'1d8',-10),
('a covered pit',102,'^',%X'00000000',2,0,3,0,0,0,0,0,0,'2d6',-40),
('a trap door',102,'^',%X'00000000',5,0,4,0,0,0,0,0,0,'2d8',-25),
('a gas trap' ,102,'^',%X'00000000',3,0,5,0,0,0,0,0,0,'1d4',5),
('a loose rock' ,102,';',%X'00000000',0,0,6,0,0,0,0,0,0,'0d0',-90),
('a dart trap',102,'^',%X'00000000',5,0,7,0,0,0,0,0,0,'1d4',10),
('a strange rune',102,'^',%X'00000000',5,0,8,0,0,0,0,0,0,'0d0',-10),
('some loose rock' ,102,'^',%X'00000000',5,0,9,0,0,0,0,0,0,'2d6',-10),
('a gas trap',102,'^',%X'00000000',10,0,10,0,0,0,0,0,0,'1d4',5),
('a strange rune' ,102,'^',%X'00000000',5,0,11,0,0,0,0,0,0,'0d0',-10),
('a blackened spot',102,'^',%X'00000000',10,0,12,0,0,0,0,0,0,'4d6',10),
('some shattered rock',102,'^',%X'00000000',10,0,13,0,0,0,0,0,0,'4d6',10),
('a gas trap',102,'^',%X'00000000',5,0,14,0,0,0,0,0,0,'2d6',5),
('a gas trap',102,'^',%X'00000000',5,0,15,0,0,0,0,0,0,'1d4',10),
('a bomb',102,'^',%X'00000000',25,0,16,0,0,0,0,0,0,'10d6',25),
('a dart trap',102,'^',%X'00000000',5,0,17,0,0,0,0,0,0,'1d8',10),
('a dart trap',102,'^',%X'00000000',5,0,18,0,0,0,0,0,0,'1d8',10),
{ SPECIAL CASE,see DOOR_LIST below (SUBVALS MUST AGREE) }
('a closed door',105,'+',%X'00000000',0,0,19,0,0,0,0,0,0,'1d1',0),         
('a teleport trap',102,'^',%X'00000000',0,0,20,0,0,0,0,0,0,'0d0',50));

blk_mkt_trap := 
('a Black Market Store',111,'7',%X'00000000',5,0,107,0,0,0,0,0,0,'1d1',100);
 
{ Stores are just special traps }
        store_door := (
('The entrance to the General Store',110,'1',%X'00000000',0,0,101,0,0,0,0,0,0,'0d0',0),
('The entrance to the Armory',110,'2',%X'00000000',0,0,102,0,0,0,0,0,0,'0d0',0),
('The entrance to the Weapon Smiths',110,'3',%X'00000000',0,0,103,0,0,0,0,0,0,'0d0',0),
('The entrance to the Temple',110,'4',%X'00000000',0,0,104,0,0,0,0,0,0,'0d0',0),
('The entrance to the Alchemy Shop',110,'5',%X'00000000',0,0,105,0,0,0,0,0,0,'0d0',0),
('The entrance to the Magic Shop',110,'6',%X'00000000',0,0,106,0,0,0,0,0,0,'0d0',0),
('The entrance to the Black Market',110,'7',%X'00000000',0,0,107,0,0,0,0,0,0,'0d0',1));

 scare_monster :=
('a strange rune',102,'^',%X'00000000',0,0,99,0,0,0,0,0,0,'0d0',-90);
 
rubble := ('some rubble',103,':',%X'00000000',0,0,1,0,0,0,0,0,0,'0d0',0);
 
{ Secret door must have same subval as closed door in TRAP_LISTB.
  See CHANGE_TRAP}
 door_list := (
('an open door',104,'''',%X'00000000',0,0,1,0,0,0,0,0,0,'1d1',0),
('a closed door',105,'+',%X'00000000',0,0,19,0,0,0,0,0,0,'1d1',0),
('a secret door',109,'#',%X'00000000',0,0,19,0,0,0,0,0,0,'1d1',0));
 
 up_stair := ('an up staircase ',107,'<',%X'00000000',0,0,1,0,0,0,0,0,0,'1d1',0);
 
 down_stair := ('a down staircase',108,'>',%X'00000000',0,0,1,0,0,0,0,0,0,'1d1',0);
 
 
{ Sets for easy testing }
  floor_set   := [1,2,4,5,6,7];  wall_set    := [10,11,12];
  pwall_set   := [10,11,12,15];  corr_set    := [4,5];
  trap_set    := [101,102,109,110,111];               
  light_set   := [102,103,104,105,107,108,109,110,111];
 
{ Descriptive phrases }
        colors  :=   (
                      'Amber','Azure','Blue','Blue Speckled','Blue Spotted',
		      'Black','Black Speckled','Black Spotted','Brown',
		      'Brown Speckled','Brown Spotted','Bubbling',
                      'Chartreuse','Clear','Cloudy','Copper','Copper Spotted',
                      'Crimson','Cyan','Dark Blue','Dark Green','Dark Red',
                      'Ecru','Gold','Gold Spotted','Green','Green Speckled',
                      'Green Spotted','Grey','Grey Spotted','Hazy','Indigo',
                      'Light Blue','Light Green','Magenta','Metallic Blue',
                      'Metallic Red','Metallic Green','Metallic Purple',
                      'Misty','Orange','Orange Speckled','Orange Spotted',
                      'Pink','Pink Speckled','Plaid','Puce','Purple',
                      'Purple Speckled','Purple Spotted','Red','Red Speckled',
                      'Red Spotted','Silver','Silver Speckled',
                      'Silver Spotted','Smokey','Tan','Tangerine','Topaz',
                      'Turquoise','Violet','Vermilion','White',
                      'White Speckled','White Spotted','Yellow' );
        mushrooms := (
                      'Blue','Black','Brown','Copper','Crimson','Dark blue',
                      'Dark green','Dark red','Gold','Green','Grey',
                      'Light Blue','Light Green','Orange','Pink','Plaid',
                      'Purple','Red','Tan','Turquoise','Violet','White',
                      'Yellow','Wrinkled','Wooden','Slimey','Speckled',
                      'Spotted','Furry' );
        woods   :=   (
                      'Applewood','Ashen','Aspen','Avocado wood','Balsa',
                      'Banyan','Birch','Ceder','Cherrywood','Cinnibar',
                      'Cottonwood','Cypress','Dogwood','Driftwood','Ebony',
                      'Elm wood','Eucalyptus','Grapevine','Hawthorn','Hemlock',
                      'Hickory','Iron wood','Juniper','Locust','Mahogany',
                      'Magnolia','Manzanita','Maple','Mulberry','Oak','Pecan',
                      'Persimmon','Pine','Redwood','Rosewood','Spruce','Sumac',
                      'Sycamore','Teak','Walnut','Zebra wood' );
        metals  :=   (
                      'Aluminium','Bone','Brass','Bronze','Cast Iron',
                      'Chromium','Copper','Gold','Iron','Lead','Magnesium',
                      'Molybdenum','Nickel','Pewter','Rusty','Silver','Steel',
                      'Tin','Titanium','Tungsten','Zirconium','Zinc',
                      'Aluminium Plated','Brass Plated','Copper Plated',
                      'Gold Plated','Nickel Plated','Silver Plated',
                      'Steel Plated','Tin Plated','Zinc Plated' );
        rocks   :=   (
                      'Amber','Agate','Alexandrite','Amethyst','Antlerite',
                      'Aquamarine','Argentite','Azurite','Beryl','Bloodstone',
                      'Calcite','Carnelian','Coral','Corundum','Cryolite',
                      'Diamond','Diorite','Emerald','Flint','Fluorite',
                      'Gabbro','Garnet','Granite','Gypsum','Hematite','Jade',
                      'Jasper','Kryptonite','Lapus lazuli','Limestone',
                      'Malachite','Manganite','Marble','Moonstone',
                      'Neptunite','Obsidian','Onyx','Opal','Pearl','Pyrite',
                      'Quartz','Quartzite','Rhodonite','Rhyolite','Ruby',
                      'Saphire','Sphalerite','Staurolite','Tiger eye','Topaz',
                      'Turquoise','Zircon' );
        amulets :=   (
                      'Birch','Ceder','Dogwood','Driftwood','Elm wood',
                      'Hemlock','Hickory','Mahogany','Maple','Oak','Pine',
                      'Redwood','Rosewood','Walnut','Aluminium','Bone','Brass',
                      'Bronze','Copper','Iron','Lead','Nickel','Agate',
                      'Amethyst','Diamond','Emerald','Flint','Garnet','Jade',
                      'Obsidian','Onyx','Opal','Pearl','Quartz','Ruby',
                      'Saphire','Tiger eye','Topaz','Turquoise' );
        syllables := (
                      'a','ab','ag','aks','ala','an','ankh','app','arg','arze',
                      'ash','aus','ban','bar','bat','bek','bie','bin','bit',
                      'bjor','blu','bot','bu','byt','comp','con','cos','cre',
                      'dalf','dan','den','doe','dok','eep','el','eng','er',
                      'ere','erk','esh','evs','fa','fid','for','fri','fu','gan',
                      'gar','glen','gop','gre','ha','he','hyd','i','ing','ion',
                      'ip','ish','it','ite','iv','jo','kho','kli','klis','la',
                      'lech','man','mar','me','mi','mic','mik','mon','mung',
                      'mur','nej','nelg','nep','ner','nes','nis','nih','nin',
                      'o','od','ood','org','orn','ox','oxy','pay','pet','ple',
                      'plu','po','pot','prok','re','rea','rhov','ri','ro','rog',
                      'rok','rol','sa','san','sat','see','sef','seh','shu',
                      'ski','sna','sne','snik','sno','so','sol','sri','sta',
                      'sun','ta','tab','tem','ther','ti','tox','trol','tue',
                      'turs','u','ulk','um','un','uni','ur','val','viv','vly',
                      'vom','wah','wed','werg','wex','whon','wun','x','yerg',
                      'yp','zun' ); 
 
{ Used in DESC.INC for replacing the & in descriptions }
        vowel_set := ['a','e','i','o','u','A','E','I','O','U'];


 
{ Creatures must be defined here. See TYPES.INC under creature_type for a
  complete list of all variables for creatures.  Some of the less obvious
  are explained below.
 
        Hit points:     '#1d#2' where #2 is the range of each roll and
                        #1 is the number of added up rolls to make.
                        Example: a creature with 5 eight-sided hit die
                        is given '5d8'.
 
                Attack types:
                1       Normal attack
                2       Poison Strength
                3       Confusion attack
                4       Fear attack
                5       Fire attack
                6       Acid attack
                7       Cold attack
                8       Lightning attack
                9       Corrosion attack
                10      Blindness attack
                11      Paralysis attack
                12      Steal Money
                13      Steal Object
                14      Poison
                15      Lose dexterity
                16      Lose constitution
                17      Lose intelligence
                18      Lose wisdom
                19      Lose experience
                20      Aggravation
                21      Disenchants
                22      Eats food
                23      Eats light
                24      Eats charges
                25      Turn to stone
                26      Vampire Bite
                27	Mind Flayer Attack
		28	Hell Hose Attack
		29	Vargouille Attack
		99      Blank
 
                Attack descriptions:
                1       hits you.
                2       bites you.
                3       claws you.
                4       stings you.
                5       touches you.
                6       kicks you.
                7       gazes at you.
                8       breathes on you.
                9       spits on you.
                10      makes a horrible wail.
                11      embraces you.
                12      crawls on you.
                13      releases a cloud of spores.
                14      begs you for money.
                15      You've been slimed.
                16      crushes you.
                17      tramples you.
                18      drools on you.
		20	touches you with its tentacles.
                99      is repelled.
 
        Example:  For a creature which bites for 1d6,then stings for
                  2d4 and loss of dex you would use:
                        '1 2 1d6|15 4 2d4'
 
                CMOVE flags:
Movement.       00000001        Move only to attack
        .       00000002        Move,attack normal
        .       00000008        20% random movement
        .       00000010        40% random movement
        .       00000020        75% random movement
Special +       00010000        Invisible movement
        +       00020000        Move through door
        +       00040000        Move through wall
        +       00080000        Move through creatures
        +       00100000        Picks up objects
        +       00200000        Multiply monster
Carries =       01000000        Carries objects.
        =       02000000        Carries gold.
        =       04000000        Has 60% of time.
        =       08000000        Has 90% of time.
        =       10000000        1d2 objects/gold.
        =       20000000        2d2 objects/gold.
        =       40000000        4d2 objects/gold.
Special ~       80000000        Win-the-Game creature.
 
                SPELL Flags:
Frequency       000001    1     These add up to x.  Then
(1 in x).       000002    2     if RANDINT(X) = 1 the
        .       000004    4     creature casts a spell.
        .       000008    8
Spells  =       000010  Teleport short (blink)
        =       000020  Teleport long
        =       000040  Teleport player to monster
        =       000080  Cause light wound
        =       000100  Cause serious wound
        =       000200  Hold person (Paralysis)
        =       000400  Cause blindness
        =       000800  Cause confusion
        =       001000  Cause fear
        =       002000  Summon monster
        =       004000  Summon undead
        =       008000  Slow Person
        =       010000  Drain Mana
        =       020000  Not Used 
        =       040000  Not Used 
Breaths +       080000  Breathe Lightning
        +       100000  Breathe Gas
        +       200000  Breathe Acid
        +       400000  Breathe Frost
        +       800000  Breathe Fire
 
                CDEFENSE flags:
                0001    Hurt by Slay Dragon.
                0002    Hurt by Slay Monster.
                0004    Hurt by Slay Evil.
                0008    Hurt by Slay Undead.
                0010    Hurt by Frost.
                0020    Hurt by Fire.
                0040    Hurt by Poison.
                0080    Hurt by Acid.
                0100    Hurt by Light-Wand.
                0200    Hurt by Stone-to-Mud.
                0400    Minus experience.
                0800    Not used.
                1000    Cannot be charmed or slept.
                2000    Can be seen with infra-vision.               
                4000    Max Hit points.
                8000    Not used.
 
 
        Sleep (sleep)   :       A measure in turns of how fast creature
                                will notice player (on the average).
        Area of affect (aaf) :  Max range that creature is able to "notice"
                                the player. 

 Creature data goes here - mwk,opusii

         c_list := (
('Filthy Street Urchin',%X'0012000A',%X'00000000',%X'2034',400,0,
   4,1,1,'p','1d4','1 14 0d0|12 5 0d0' ,0),etc.... );
 
        blank_monster   := (0,0,0,0,0,0,0,0,0,false,false);}

