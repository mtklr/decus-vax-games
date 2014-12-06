{Add magical plusses}
[psect(misc$code)] procedure add_tohit(a,b,c,i:integer;var r:integer);
BEGIN
   r := randint(a) + randint(b) + randint(c);
   store[7].store_inven[i].sitem.tohit := r;
END;

{Add magical plusses}
[psect(misc$code)] procedure add_todam(a,b,c,i:integer;var r:integer);
BEGIN
   r := randint(a) + randint(b) + randint(c);
   store[7].store_inven[i].sitem.todam := r;
END;

{Add magical plusses}
[psect(misc$code)] procedure add_ac(a,b,c,i:integer;var r:integer);
BEGIN
   r := randint(a) + randint(b) + randint(c);
   store[7].store_inven[i].sitem.ac := r;
END;

{Add magical plusses}
[psect(misc$code)] procedure add_toac(a,b,c,i:integer;var r:integer);
BEGIN
   r := randint(a) + randint(b) + randint(c);
   store[7].store_inven[i].sitem.toac := r;
END;

{Add magical plusses}
[psect(misc$code)] procedure add_p1(a,b,c,i:integer;var r:integer);
BEGIN
   r := a + randint(b) + randint(c);
   store[7].store_inven[i].sitem.p1 := r;
END;

[psect(misc$code)] procedure add_p1_rods(a,b,c,i:integer;var r:integer);
BEGIN
   r := a + randint(b) + c;
   store[7].store_inven[i].sitem.p1 := r;
END;

{ Soup-up the Black Market inventory - mwk}
[psect(store$code)]
procedure soup_up_black_market(indx:integer);
var
   r1,r2,r3,r4,r5 : integer;
BEGIN
    with store[7].store_inven[indx] do
       BEGIN
         case sitem.tval of                          
           10,11,12: {Sling ammo, bolts and arrows}
                   BEGIN                              
                     case randint(10) of
                       1,2,3: BEGIN
                                sitem.name := sitem.name + ' of Slaying';
                                add_tohit(5,5,1,indx,r1);
                                add_todam(5,5,1,indx,r2);
                                sitem.cost := sitem.cost + 1250*r1 + 1250*r2
                              END;
                       4,5  : BEGIN
                                sitem.flags := uor(sitem.flags,%X'00040000');
                                sitem.name := sitem.name + ' of Fire';
                                add_tohit(4,4,1,indx,r1);
                                add_todam(4,4,1,indx,r2);
                                sitem.cost := sitem.cost + 1000*r1 + 1000*r2
                              END;
                       6,7  : BEGIN  
                                sitem.flags := uor(sitem.flags,%X'00008000');
                                sitem.name := sitem.name + ' of Slay Evil';
                                add_tohit(4,4,1,indx,r1);
                                add_todam(4,4,1,indx,r2);
                                sitem.cost := sitem.cost + 1000*r1 + 1000*r2
                              END;
                       8,9  : BEGIN
                                sitem.flags := uor(sitem.flags,%X'00004000');
                                sitem.name := sitem.name + ' of Slay Monster';
                                add_tohit(3,2,1,indx,r1);
                                add_todam(3,2,1,indx,r2);
                                sitem.cost := sitem.cost + 900*r1 + 900*r1
                              END;
                       10   : BEGIN
                                sitem.flags := uor(sitem.flags,%X'00002000');
                                sitem.name := sitem.name + ' of Dragon Slaying';
                                add_tohit(8,8,1,indx,r1);
                                add_todam(8,8,1,indx,r2);
                                sitem.cost := sitem.cost + 1000*r1 + 1000*r2
                              END;
                       otherwise ;
                     END;{case}
                     sitem.number := 0;
                     for r1 := 1 to 7 do 
                        sitem.number := sitem.number + randint(12);
                     missle_ctr := missle_ctr + 1;
                     if (missle_ctr > 65534) then missle_ctr := 1;
                     sitem.subval := missle_ctr + 512;
                   END;
           20      : {Sling, crossbows and bows}
                     BEGIN
                       add_tohit(5,5,1,indx,r1);
                       sitem.cost := sitem.cost + 1000*r1 + 10000
                     END;
           21,22,23: {Weapons}
                     case randint(16) of
                        1, 9: BEGIN
                                sitem.flags := uor(sitem.flags,%X'01418001');
                                sitem.name := sitem.name + ' (HA)';
                                add_tohit(6,6,1,indx,r1);
                                add_todam(6,6,1,indx,r2);
                                add_toac(5,1,1,indx,r4);
                                add_p1(1,4,1,indx,r5);{for sustain stat}
                                sitem.cost := sitem.cost + 1000*r1 + 1000*r2;
                                sitem.cost := sitem.cost + 2000*r4;
                                sitem.cost := sitem.cost + 20000
                              END;
                        2,10: BEGIN
                                sitem.flags := uor(sitem.flags,%X'07B80900');
                                sitem.name := sitem.name + ' [%P4] (DF)';
                                add_tohit(6,6,1,indx,r1);
                                add_todam(6,6,1,indx,r2);
                                add_toac(5,5,8,indx,r4);
                                sitem.cost := sitem.cost + 1000*r1 + 1000*r2;
                                sitem.cost := sitem.cost + 2000*r4;
                                sitem.cost := sitem.cost + 25000
                              END;
                        3,11: BEGIN
                                sitem.flags := uor(sitem.flags,%X'01004000');
                                sitem.name := sitem.name + ' (SM)';
                                add_tohit(4,4,1,indx,r1);
                                add_todam(4,4,1,indx,r2);
                                sitem.cost := sitem.cost + 1000*r1 + 1000*r2;
                                sitem.cost := sitem.cost + 15000
                              END;
                        4,12: BEGIN
                                sitem.flags := uor(sitem.flags,%X'00002000');
                                sitem.name := sitem.name + ' (SD)';
                                add_tohit(5,5,1,indx,r1);
                                add_todam(5,5,1,indx,r2);
                                add_toac(10,1,1,indx,r4);
                                sitem.cost := sitem.cost + 1000*r1 + 1000*r2;
                                sitem.cost := sitem.cost + 5000*r4;
                                sitem.cost := sitem.cost + 15000
                              END;
                        5,13: BEGIN
                                sitem.flags := uor(sitem.flags,%X'01008000');
                                sitem.name := sitem.name + ' (SE)';
                                add_tohit(4,4,1,indx,r1);
                                add_todam(4,4,1,indx,r2);
                                sitem.cost := sitem.cost + 1000*r1 + 1000*r2;
                                sitem.cost := sitem.cost + 15000
                              END;
                        6,14: BEGIN
                                sitem.flags := uor(sitem.flags,%X'01010000');
                                sitem.name := sitem.name + ' (SU)';
                                add_tohit(4,4,1,indx,r1);
                                add_todam(4,4,1,indx,r2);
                                sitem.cost := sitem.cost + 1000*r1 + 1000*r2;
                                sitem.cost := sitem.cost + 15000
                              END;
                        7,15: BEGIN
                                sitem.flags := uor(sitem.flags,%X'00040000');
                                sitem.name := sitem.name + ' (FT)';
                                add_tohit(4,4,1,indx,r1);
                                add_todam(4,4,1,indx,r2);
                                sitem.cost := sitem.cost + 1000*r1 + 1000*r2;
                                sitem.cost := sitem.cost + 15000
                              END;
                        8,16: BEGIN
                                sitem.flags := uor(sitem.flags,%X'00002000');
                                sitem.name := sitem.name + ' (SD)';
                                add_tohit(5,5,1,indx,r1);
                                add_todam(5,5,1,indx,r2);
                                add_toac(10,1,1,indx,r4);
                                sitem.cost := sitem.cost + 1000*r1 + 1000*r2;
                                sitem.cost := sitem.cost + 5000*r4;
                                sitem.cost := sitem.cost + 15000
                              END;
                       otherwise ;
                     END;
           25      : {Digging tools}
                     BEGIN
                       add_p1(0,3,3,indx,r5);
                       add_tohit(4,4,1,indx,r1);
                       add_todam(4,4,1,indx,r2);
                       sitem.cost := sitem.cost + 1000*r1 + 1000*r2 + 1000*r5;
                       sitem.cost := sitem.cost + 15000
                     END;
           31      : {Gloves and Gauntlets}
                     case randint(2) of
                       1: BEGIN
                            sitem.flags := uor(sitem.flags,%X'00800000');
                            sitem.name := sitem.name + ' of Free Action';
                            add_ac(4,4,1,indx,r3);
                            add_toac(4,4,1,indx,r4);
                            sitem.cost := sitem.cost + 1000*r3 + 1000*r4;
                            sitem.cost := sitem.cost + 15000
                          END;
                       2: BEGIN
                            sitem.name := sitem.name + ' of Slaying';
                            add_tohit(6,6,1,indx,r1);
                            add_todam(6,6,1,indx,r2);
                            add_ac(4,4,1,indx,r3);
                            add_toac(4,4,1,indx,r4);
                            sitem.cost := sitem.cost + 5000*r1 + 6000*r2;
                            sitem.cost := sitem.cost + 1000*r3 + 1000*r4;
                            sitem.cost := sitem.cost + 15000
                          END;
                       otherwise ;
                     END;
           32      : {Cloaks}
                     case randint(2) of 
                       1: BEGIN
                            sitem.name := sitem.name + ' of Protection';
                            add_ac(4,4,1,indx,r3);
                            add_toac(4,4,1,indx,r4);
                            sitem.cost := sitem.cost + 5000*r3 + 5000*r4
                          END;
                       2: BEGIN
                            sitem.flags := uor(sitem.flags,%X'00000100');
                            sitem.name := sitem.name + ' of Stealth (%P1)';
                            add_p1(0,2,2,indx,r5);
                            add_ac(4,4,1,indx,r3);
                            add_toac(4,4,1,indx,r4);
                            sitem.cost := sitem.cost + 10000*r5 + 5000*r3 + 5000*r4
                          END;
                       otherwise ;
                     END;
           33      : {Helms}
                     case sitem.subval of 
                     1,2,3,4,5: case randint(3) of
                                  1: BEGIN
                                       sitem.flags := uor(sitem.flags,%X'00000008');
                                       sitem.name := sitem.name + ' of Intelligence';
                                       add_p1(0,2,2,indx,r5);
                                       add_ac(4,4,1,indx,r3);
                                       add_toac(4,4,1,indx,r4);
                                       sitem.cost := sitem.cost + 10000*r5;
                                       sitem.cost := sitem.cost + 5000*r3 + 5000*r4
                                     END;
                                  2: BEGIN
                                       sitem.flags := uor(sitem.flags,%X'00000010');
                                       sitem.name := sitem.name + ' of Wisdom';
                                       add_p1(0,2,2,indx,r5);
                                       add_ac(4,4,1,indx,r3);
                                       add_toac(4,4,1,indx,r4);
                                       sitem.cost := sitem.cost + 10000*r5;
                                       sitem.cost := sitem.cost + 5000*r3 + 5000*r4
                                     END;
                                  3: BEGIN
                                       sitem.flags := uor(sitem.flags,%X'40000000');
                                       sitem.name := sitem.name + ' of Infra-Vision';
                                       add_p1(0,4,4,indx,r5);
                                       add_ac(4,4,1,indx,r3);
                                       add_toac(4,4,1,indx,r4);
                                       sitem.cost := sitem.cost + 10000*r5;
                                       sitem.cost := sitem.cost + 5000*r3 + 5000*r4
                                     END;
                                  otherwise ;
                                END;
                     6,7,8    : case randint(6) of
                                  1: BEGIN
                                       sitem.flags := uor(sitem.flags,%X'00800007');
                                       sitem.name := sitem.name + ' of Might';
                                       add_p1(0,4,4,indx,r5);
                                       add_ac(4,4,1,indx,r3);
                                       add_toac(4,4,1,indx,r4);
                                       sitem.cost := sitem.cost + 10000*r5;
                                       sitem.cost := sitem.cost + 5000*r3 + 5000*r4
                                     END;
                                  2: BEGIN
                                       sitem.flags := uor(sitem.flags,%X'00000030');
                                       sitem.name := sitem.name + ' of Lordliness';
                                       add_p1(0,4,4,indx,r5);
                                       add_ac(4,4,1,indx,r3);
                                       add_toac(4,4,1,indx,r4);
                                       sitem.cost := sitem.cost + 10000*r5;
                                       sitem.cost := sitem.cost + 5000*r3 + 5000*r4
                                     END;
                                  3: BEGIN
                                       sitem.flags := uor(sitem.flags,%X'01380008');
                                       sitem.name := sitem.name + ' of the Magi';
                                       add_p1(0,4,4,indx,r5);
                                       add_ac(4,4,1,indx,r3);
                                       add_toac(4,4,1,indx,r4);
                                       sitem.cost := sitem.cost + 10000*r5;
                                       sitem.cost := sitem.cost + 5000*r3 + 5000*r4
                                     END;
                                  4: BEGIN
                                       sitem.flags := uor(sitem.flags,%X'00000020');
                                       sitem.name := sitem.name + ' of Beauty';
                                       add_p1(0,4,4,indx,r5);
                                       add_ac(4,4,1,indx,r3);
                                       add_toac(4,4,1,indx,r4);
                                       sitem.cost := sitem.cost + 10000*r5;
                                       sitem.cost := sitem.cost + 5000*r3 + 5000*r4
                                     END;
                                  5: BEGIN
                                       sitem.flags := uor(sitem.flags,%X'01000040');
                                       sitem.name := sitem.name + ' of Seeing';
                                       add_p1(0,4,4,indx,r5);
                                       add_ac(4,4,1,indx,r3);
                                       add_toac(4,4,1,indx,r4);
                                       sitem.cost := sitem.cost + 10000*r5;
                                       sitem.cost := sitem.cost + 5000*r3 + 5000*r4
                                     END;
                                  6: BEGIN
                                       sitem.flags := uor(sitem.flags,%X'00000800');
                                       sitem.name := sitem.name + ' of Regeneration';
                                       add_ac(4,4,1,indx,r3);
                                       add_toac(4,4,1,indx,r4);
                                       sitem.cost := sitem.cost + 5000*r3 + 5000*r4
                                     END;
                                  otherwise ;
                                END;
                     otherwise ;
                     END;
           34,35   : {Shields and Hard Armor}
                     case randint(10) of
                       1, 6: BEGIN
                               sitem.flags := uor(sitem.flags,%X'02380000');
                               sitem.name := sitem.name + ' (R)';
                               add_toac(8,8,1,indx,r4);
                               sitem.cost := sitem.cost + 10000*r4;
                               sitem.cost := sitem.cost + 50000
                             END;
                       2, 7: BEGIN
                               sitem.flags := uor(sitem.flags,%X'00100000');
                               sitem.name := sitem.name + ' (RA)';
                               add_toac(8,8,1,indx,r4);
                               sitem.cost := sitem.cost + 10000*r4;
                               sitem.cost := sitem.cost + 40000
                             END;
                       3, 8: BEGIN
                               sitem.flags := uor(sitem.flags,%X'00080000');
                               sitem.name := sitem.name + ' (RF)';
                               add_toac(8,8,1,indx,r4);
                               sitem.cost := sitem.cost + 10000*r4;
                               sitem.cost := sitem.cost + 40000
                             END;
                       4, 9: BEGIN
                               sitem.flags := uor(sitem.flags,%X'00200000');
                               sitem.name := sitem.name + ' (RC)';
                               add_toac(8,8,1,indx,r4);
                               sitem.cost := sitem.cost + 10000*r4;
                               sitem.cost := sitem.cost + 40000
                             END;
                       5,10: BEGIN
                               sitem.flags := uor(sitem.flags,%X'02000000');
                               sitem.name := sitem.name + ' (RL)';
                               add_toac(8,8,1,indx,r4);
                               sitem.cost := sitem.cost + 10000*r4;
                               sitem.cost := sitem.cost + 30000
                             END;
                       otherwise ;
                     END;
           40      : {Amulets}
                     case sitem.subval of
                       1,2: BEGIN
                              add_p1(0,2,2,indx,r5);
                              sitem.cost := sitem.cost + 10000*r5
                            END;
                       3  : BEGIN
                              add_p1(8,15,15,indx,r5);
                              sitem.cost := sitem.cost + 10000*r5
                            END;
                       5  : BEGIN
                              add_toac(4,4,0,indx,r4);
                              sitem.cost := sitem.cost + 10000*r4
                            END;
                       otherwise ;
                     END;
           45      : {Rings}
                     case sitem.subval of
                       1,2,3,4: {Gain stat}
                                BEGIN
                                  add_p1(0,2,2,indx,r5);
                                  sitem.cost := sitem.cost + 10000*r5
                                END;
                       7      : {Speed}
                                BEGIN
                                  add_p1(1,2,1,indx,r5);
                                  sitem.cost := sitem.cost + 500000*r5
                                END;
                       8      : {Searching}
                                BEGIN
                                  add_p1(8,15,15,indx,r5);
                                  sitem.cost := sitem.cost + 10000*r5
                                END;
                      10,13,26:  {Slow Digestion, Feather-Falling, See-Invis}
                                BEGIN
                                  add_toac(2,2,1,indx,r4);
                                  sitem.cost := sitem.cost + 10000*r4
                                END;
                      17,18,19: {Lordly Protection}
                                BEGIN
                                  add_toac(10,8,5,indx,r4);
                                  sitem.cost := sitem.cost + 10000*r4
                                END;
                       22     : {Increase Damage}
                                BEGIN
                                  add_todam(3,3,3,indx,r2);
                                  sitem.cost := sitem.cost + 10000*r2
                                END;
                       23     : {Increase To-hit}
                                BEGIN
                                  add_tohit(3,3,3,indx,r1);
                                  sitem.cost := sitem.cost + 10000*r1
                                END;
                       24     : {Protection}     
                                BEGIN
                                  add_toac(4,4,1,indx,r4);
                                  sitem.cost := sitem.cost + 10000*r4
                                END;
                       33     : {Slaying}
                                BEGIN
                                  add_tohit(3,3,3,indx,r1);
                                  add_todam(3,3,3,indx,r2);
                                  sitem.cost := sitem.cost + 10000*r2 + 10000*r1
                                END;
                       otherwise ;
                     END;
           55      : {Staves}
                     case sitem.subval of
                        1   : BEGIN        
                                add_p1_rods(32,20,12,indx,r5);
                                sitem.cost := sitem.cost + 5000*r5
                              END;
                        2   : BEGIN
                                add_p1_rods(14,8,6,indx,r5);
                                sitem.cost := sitem.cost + 5000*r5
                              END;
                        3   : BEGIN
                                add_p1_rods(11,5,6,indx,r5);
                                sitem.cost := sitem.cost + 5000*r5
                              END;
                        4   : BEGIN
                                add_p1_rods(32,20,12,indx,r5);
                                sitem.cost := sitem.cost + 5000*r5
                              END;
                        5   : BEGIN
                                add_p1_rods(21,15,6,indx,r5);
                                sitem.cost := sitem.cost + 5000*r5
                              END;     
                        6   : BEGIN
                                add_p1_rods(9,4,5,indx,r5);
                                sitem.cost := sitem.cost + 5000*r5
                              END;
                        7   : BEGIN
                                add_p1_rods(8,5,3,indx,r5);
                                sitem.cost := sitem.cost + 5000*r5
                              END;
                        8   : BEGIN
                                add_p1_rods(4,3,1,indx,r5);
                                sitem.cost := sitem.cost + 5000*r5
                              END;
                        9   : BEGIN
                                add_p1_rods(4,3,1,indx,r5);
                                sitem.cost := sitem.cost + 5000*r5
                              END;
                        10  : BEGIN
                                add_p1_rods(4,3,1,indx,r5);
                                sitem.cost := sitem.cost + 5000*r5
                              END;
                        11  : BEGIN
                                add_p1_rods(11,5,6,indx,r5);
                                sitem.cost := sitem.cost + 5000*r5
                              END;
                        13  : BEGIN
                                add_p1_rods(11,5,6,indx,r5);
                                sitem.cost := sitem.cost + 5000*r5
                              END;
                        14  : BEGIN
                                add_p1_rods(11,5,6,indx,r5);
                                sitem.cost := sitem.cost + 5000*r5
                              END;
                        16  : BEGIN
                                add_p1_rods(22,10,12,indx,r5);
                                sitem.cost := sitem.cost + 5000*r5
                              END;
                        17  : BEGIN
                                add_p1_rods(7,3,4,indx,r5);
                                sitem.cost := sitem.cost + 5000*r5
                              END;
                        19  : BEGIN
                                add_p1_rods(11,5,6,indx,r5);
                                sitem.cost := sitem.cost + 5000*r5
                              END;
                        20  : BEGIN
                                add_p1_rods(7,3,4,indx,r5);
                                sitem.cost := sitem.cost + 5000*r5
                              END;
                        21  : BEGIN
                                add_p1_rods(22,10,12,indx,r5);
                                sitem.cost := sitem.cost + 5000*r5
                              END;
                        22  : BEGIN
                                add_p1_rods(7,3,4,indx,r5);
                                sitem.cost := sitem.cost + 5000*r5
                              END;
                        23  : BEGIN          
                                add_p1_rods(7,3,4,indx,r5);
                                sitem.cost := sitem.cost + 5000*r5
                              END;
                        24  : BEGIN          
                                add_p1_rods(7,3,1,indx,r5);
                                sitem.cost := sitem.cost + 5000*r5
                              END;
                       otherwise ;           
                     END;
           65      : {Wands}
                     case sitem.subval of
                       1   : BEGIN
                               add_p1_rods(16,10,6,indx,r5);
                               sitem.cost := sitem.cost + 5000*r5
                             END;
                       2   : BEGIN           
                               add_p1_rods(14,8,6,indx,r5);
                               sitem.cost := sitem.cost + 5000*r5
                             END;
                       3   : BEGIN           
                               add_p1_rods(11,5,6,indx,r5);
                               sitem.cost := sitem.cost + 5000*r5
                             END;
                       4   : BEGIN           
                               add_p1_rods(14,8,6,indx,r5);
                               sitem.cost := sitem.cost + 5000*r5
                             END;
                       5   : BEGIN           
                               add_p1_rods(7,4,3,indx,r5);
                               sitem.cost := sitem.cost + 5000*r5
                             END;
                       6   : BEGIN          
                               add_p1_rods(14,8,6,indx,r5);
                               sitem.cost := sitem.cost + 5000*r5
                             END;
                       9   : BEGIN           
                               add_p1_rods(16,10,6,indx,r5);
                               sitem.cost := sitem.cost + 5000*r5
                             END;
                       10  : BEGIN           
                               add_p1_rods(18,12,6,indx,r5);
                               sitem.cost := sitem.cost + 5000*r5
                             END;
                       11  : BEGIN           
                               add_p1_rods(22,10,12,indx,r5);
                               sitem.cost := sitem.cost + 5000*r5
                             END;
                       12  : BEGIN           
                               add_p1_rods(6,3,3,indx,r5);
                               sitem.cost := sitem.cost + 5000*r5
                             END;
                       13  : BEGIN          
                               add_p1_rods(14,8,6,indx,r5);
                               sitem.cost := sitem.cost + 5000*r5
                             END;
                       14  : BEGIN           
                               add_p1_rods(16,10,6,indx,r5);
                               sitem.cost := sitem.cost + 5000*r5
                             END;
                       15  : BEGIN           
                               add_p1_rods(8,5,3,indx,r5);
                               sitem.cost := sitem.cost + 5000*r5
                             END;
                       16  : BEGIN          
                               add_p1_rods(8,5,3,indx,r5);
                               sitem.cost := sitem.cost + 5000*r5
                             END;
                       17  : BEGIN          
                               add_p1_rods(11,5,6,indx,r5);
                               sitem.cost := sitem.cost + 5000*r5
                             END;
                       18  : BEGIN           
                               add_p1_rods(9,5,4,indx,r5);
                               sitem.cost := sitem.cost + 5000*r5
                             END;
                       19  : BEGIN          
                               add_p1_rods(12,8,4,indx,r5);
                               sitem.cost := sitem.cost + 5000*r5
                             END;
                       20  : BEGIN           
                               add_p1_rods(12,8,4,indx,r5);
                               sitem.cost := sitem.cost + 5000*r5
                             END;
                       21  : BEGIN           
                               add_p1_rods(12,8,4,indx,r5);
                               sitem.cost := sitem.cost + 5000*r5
                             END;
                       22  : BEGIN           
                               add_p1_rods(36,24,12,indx,r5);
                               sitem.cost := sitem.cost + 5000*r5
                             END;
                       23  : BEGIN           
                               add_p1_rods(12,8,4,indx,r5);
                               sitem.cost := sitem.cost + 5000*r5
                             END;
                       24  : BEGIN           
                               add_p1_rods(16,10,6,indx,r5);
                               sitem.cost := sitem.cost + 5000*r5
                             END;
                       otherwise ;           
                     END;
           otherwise ;
         END;
         scost := -sitem.cost;
         insert_num(sitem.name,'%P1',sitem.p1,true);
         insert_num(sitem.name,'%P2',sitem.tohit,true);
         insert_num(sitem.name,'%P3',sitem.todam,true);
         insert_num(sitem.name,'%P4',sitem.toac,true);
         insert_num(sitem.name,'%P5',sitem.p1,false);
         insert_num(sitem.name,'%P6',sitem.ac,false);
       END;
END;                                                                    

[psect(store$code)] procedure store_carry( store_num : integer;
                                           var ipos  : integer); forward;

{Add Black Market items to the inventory}
[psect(store$code)]
procedure do_black_market;
var
   indx,iptr,inven_num : integer;
BEGIN
   inven_num := 0;
   store[7].store_ctr := 0;
   while (inven_num < store_inven_max) do
     inven_num := 5 + randint(store_inven_max);
   if (inven_num > store_inven_max) then inven_num := store_inven_max;
   for indx := 1 to inven_num do
      with store[7].store_inven[indx] do
        BEGIN
          iptr := randint(blk_mkt_max);   
          sitem := blk_mkt_init[iptr];
          soup_up_black_market(indx);
          inventory[inven_max] := sitem;
          store_carry(7,iptr);
        END;
   for indx := inven_num to store_inven_max do
      with store[7].store_inven[indx] do
        sitem := blank_treasure;
   store[7].store_ctr := store[7].store_ctr - 1;
END;
                                 
procedure Opusii_vomit(percentage:integer);
BEGIN
if (randint(100) < percentage) then
  with py.flags do
                  BEGIN
                    food := food - 500;
                    paralysis := 4;
                    msg_print('You feel your insides heave!');
                  END
END;
