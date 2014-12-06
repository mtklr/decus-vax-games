{ Moria game module          
  The code in this section has gone through many revisions, and
  some of it could stand some more hard work.}
[psect(moria$code)] procedure dungeon;
    var
        dir_val  : integer;   { For movement }
        y,x,moves: integer;   { For movement }
        i1,i2,tmp1  : integer;   { Temporaries }
        old_chp,old_cmana : integer;   { Detect change }
        regen_amount: real;   { Regenerate hp and mana}
        command  : char;   { Last command }
        out_val  : vtype;  { For messages }       
        tmp_str  : vtype;  { Temporary }
        mwkdum : boolean;
        moria_flag  : boolean;   { Next level when true}
        reset_flag  : boolean;   { Do not move creatures }
        search_flag : boolean;   { Player is searching }
        teleport_flag  : boolean;   { Handle telport traps}
        player_light: boolean;   { Player carrying light }
        save_msg_flag  : boolean;   { Msg flag after INKEY}
            
 
{ check the Balrog's stats to see if dead or just defeated...}
[psect(moria$code)] function check_balrog(mi1,mi2 : integer) :boolean;
var
   num : integer;
BEGIN                                                    
  check_balrog := false;
  if (uand(c_list[mi2].cmove,%X'80000000') <> 0) then
    if (dun_level = 1200) then
      check_balrog := true
    else
      with c_list[mi2] do
       with m_list[mi1] do
        BEGIN
          ac := ac + 5;
          mexp := mexp + 200;
          hp := hp + 80;
          if (((dun_level - win_mon_appear)/343) =
              ((dun_level - win_mon_appear)div 343 )) then
            spells := spells - 1;
        END
END;
            


{ Pre-declaration of MOVE_CHAR }
[psect(creature$code)] procedure move_char(dir : integer);
        forward;
 
 
{ Pre-declaration of CREATURES}
    procedure creatures(attack : boolean); forward;
 
 
{ Changes stats up or down for magic items }
    procedure change_stat(var stat : byteint; amount,factor : integer);
      var
                i1,i2,i3  : integer;
      BEGIN
        i2 := amount * factor;
        i3 := abs(amount);
        for i1 := 1 to i3 do
          if (i2 < 0) then
            stat := de_statt(stat)
          else
            stat := in_statt(stat);
      END;
 
 
{ Changes speed of monsters relative to player
  Note: When the player is sped up or slowed down, I simply
        change the speed of all the monsters.  This greatly
        simplified the logic.}
    procedure change_speed(num : integer);
      var
                i1 : integer;
      BEGIN
        py.flags.speed := py.flags.speed + num;
        i1 := muptr;
        while (i1 <> 0) do
          BEGIN
            m_list[i1].cspeed := m_list[i1].cspeed + num;
            i1 := m_list[i1].nptr;
          END;
      END;                                                       
 
 
{ Player bonuses
  When an item is worn or taken off, this re-adjusts the player
  bonuses.  Factor=1 : wear; Factor=-1 : removed }
    procedure py_bonuses(tobj : treasure_type; factor : integer);
      var
        item_flags : unsigned;
        i1,old_dis_ac : integer;
      BEGIN
        with py.flags do
          BEGIN
            if (slow_digest) then
              food_digested := food_digested + 1;
            if (regenerate) then
              food_digested := food_digested - 3;
            see_inv  := false;
            teleport := false;
            free_act := false;
            slow_digest := false;
            aggravate:= false;
            sustain_str := false;
            sustain_int := false;
            sustain_wis := false;
            sustain_con := false;
            sustain_dex := false;
            sustain_chr := false;
            fire_resist := false;
            acid_resist := false;
            cold_resist := false;
            regenerate  := false;
            lght_resist := false;
            ffall := false;
          END;
 
        if (uand(%X'00000001',tobj.flags) <> 0) then
          BEGIN
            change_stat(py.stat.cstr,tobj.p1,factor);
            change_stat(py.stat.str,tobj.p1,factor);
            print_stat := uor(%X'0001',print_stat);
          END;
        if (uand(%X'00000002',tobj.flags) <> 0) then
          BEGIN
            change_stat(py.stat.cdex,tobj.p1,factor);
            change_stat(py.stat.dex,tobj.p1,factor);
            print_stat := uor(%X'0002',print_stat);
          END;
        if (uand(%X'00000004',tobj.flags) <> 0) then
          BEGIN
            change_stat(py.stat.ccon,tobj.p1,factor);
            change_stat(py.stat.con,tobj.p1,factor);
            print_stat := uor(%X'0004',print_stat);
          END;
        if (uand(%X'00000008',tobj.flags) <> 0) then
          BEGIN
            change_stat(py.stat.cint,tobj.p1,factor);
            change_stat(py.stat.int,tobj.p1,factor);
            print_stat := uor(%X'0008',print_stat);
          END;
        if (uand(%X'00000010',tobj.flags) <> 0) then
          BEGIN
            change_stat(py.stat.cwis,tobj.p1,factor);
            change_stat(py.stat.wis,tobj.p1,factor);
            print_stat := uor(%X'0010',print_stat);
          END;
        if (uand(%X'00000020',tobj.flags) <> 0) then
          BEGIN
            change_stat(py.stat.cchr,tobj.p1,factor);
            change_stat(py.stat.chr,tobj.p1,factor);
            print_stat := uor(%X'0020',print_stat);
          END;
        if (uand(%X'00000040',tobj.flags) <> 0) then
          BEGIN
            py.misc.srh := py.misc.srh + (tobj.p1 * factor);
            py.misc.fos := py.misc.fos - (tobj.p1 * factor);
          END;
        if (uand(%X'00000100',tobj.flags) <> 0) then
          py.misc.stl := py.misc.stl + 2*factor;
        if (uand(%X'00001000',tobj.flags) <> 0) then
          BEGIN
            i1 := tobj.p1*factor;
            change_speed(-i1);
          END;
        if (uand(%X'08000000',tobj.flags) <> 0) then
          if (factor > 0) then
            py.flags.blind := py.flags.blind + 1000;
        if (uand(%X'10000000',tobj.flags) <> 0) then
          if (factor > 0) then
            py.flags.afraid := py.flags.afraid + 50;
        if (uand(%X'40000000',tobj.flags) <> 0) then
          py.flags.see_infra := py.flags.see_infra + (tobj.p1 * factor);
        with py.misc do
          BEGIN
            old_dis_ac := dis_ac;
            ptohit  := tohit_adj; { Real To Hit }
            ptodam  := todam_adj; { Real To Dam }
            ptoac:= toac_adj;  { Real To AC }
            pac  := 0;   { Real AC }
            dis_th  := ptohit;  { Display To Hit }
            dis_td  := ptodam;  { Display To Dam }
            dis_ac  := 0; { Display To AC }
            dis_tac := ptoac;   { Display AC }
            for i1 := 23 to inven_max-2 do
              with inventory[i1] do
                if (tval > 0) then
                  BEGIN
                    if (uand(%X'80000000',flags) = 0) then
                      BEGIN
                        pac := pac    + ac;
                        dis_ac := dis_ac + ac;
                      END;
                    ptohit := ptohit + tohit;
                    ptodam := ptodam + todam;
                    ptoac  := ptoac  + toac;
                    if (index(name,'^') = 0) then
                      BEGIN
                        dis_th  := dis_th  + tohit;
                        dis_td  := dis_td  + todam;
                        dis_tac := dis_tac + toac;
                      END;
                  END;
            dis_ac := dis_ac + dis_tac;
 
{ Add in temporary spell increases }
            with py.flags do
              BEGIN
                if (invuln > 0) then
                  BEGIN
                    pac := pac    + 100;
                    dis_ac := dis_ac + 100;
                  END;
                if (blessed > 0) then
                  BEGIN
                    pac := pac    + 2;
                    dis_ac := dis_ac + 2;
                  END;
                if (detect_inv > 0) then
                  see_inv := true;
              END;
 
            if (old_dis_ac <> dis_ac) then
              print_stat := uor(%X'0040',print_stat);
 
            item_flags := 0;
            for i1 := 23 to inven_max-2 do
              with inventory[i1] do
                item_flags := uor(item_flags,flags);
            if (uand(%X'00000080',item_flags) <> 0) then
              py.flags.slow_digest := true;
            if (uand(%X'00000200',item_flags) <> 0) then
              py.flags.aggravate := true;
            if (uand(%X'00000400',item_flags) <> 0) then
              py.flags.teleport := true;
            if (uand(%X'00000800',item_flags) <> 0) then
              py.flags.regenerate := true;
            if (uand(%X'00080000',item_flags) <> 0) then
              py.flags.fire_resist := true;
            if (uand(%X'00100000',item_flags) <> 0) then
              py.flags.acid_resist := true;
            if (uand(%X'00200000',item_flags) <> 0) then
              py.flags.cold_resist := true;
            if (uand(%X'00800000',item_flags) <> 0) then
              py.flags.free_act := true;
            if (uand(%X'01000000',item_flags) <> 0) then
              py.flags.see_inv := true;
            if (uand(%X'02000000',item_flags) <> 0) then
              py.flags.lght_resist := true;
            if (uand(%X'04000000',item_flags) <> 0) then
              py.flags.ffall := true;
 
            for i1 := 23 to inven_max-2 do
              with inventory[i1] do
                if (uand(%X'00400000',flags) <> 0) then
                  CASE p1 of
                    1 : py.flags.sustain_str := true;
                    2 : py.flags.sustain_int := true;
                    3 : py.flags.sustain_wis := true;
                    4 : py.flags.sustain_con := true;
                    5 : py.flags.sustain_dex := true;
                    6 : py.flags.sustain_chr := true;
                    otherwise ;
                  END;
 
            with py.flags do
              BEGIN
                if (slow_digest) then
                  food_digested := food_digested - 1;
                if (regenerate) then
                  food_digested := food_digested + 3;
              END;
          END;
      END;
 
 
{ Returns a '*' for cursed items, a ')' for normal ones
  NOTE: '*' returned only if item has been identified.}
    function cur_char1(item_val : integer) : char;
      BEGIN
        with inventory[item_val] do
          if (uand(%X'80000000',flags) = 0) then
            cur_char1 := ')' { Not cursed.}
          else if (index(name,'^') > 0) then
            cur_char1 := ')' { Cursed, but not identified }
          else
            cur_char1 := '*';   { Cursed and identified.}
      END;
 
 
{ Returns a '*' for cursed items, a ')' for normal ones }
    function cur_char2(item_val : integer) : char;
      BEGIN
        with inventory[item_val] do
          if (uand(%X'80000000',flags) = 0) then
            cur_char2 := ')' { Not cursed.}
          else
            cur_char2 := '*';   { Cursed.}
      END;
 
 
{ Comprehensive function block to handle all inventory
  and equipment routines.  Five kinds of calls can take place.
  Note that '?' is a special call for other routines to display
  only a portion of the inventory, and take no other action. }
    function inven_command(command : char; r1,r2 : integer) : boolean;
      var
        com_val,scr_state: integer;                 
        exit_flag,test_flag : boolean;
 
 
{ Displays inventory items from r1 to r2 }
      procedure show_inven(r1,r2 : integer);
        var
          i1 : integer;
          tmp_val,out_val  : vtype;
        BEGIN
          if (r1 > 0) then    { R1 = 0 dummy call }
            BEGIN
              for i1 := r1 to r2 do { Print the items }
                BEGIN
                  objdes(tmp_val,i1,true);
                  writev(out_val,chr(i1+96),cur_char1(i1),' ',tmp_val);
                  prt(out_val,i1+1,1);
                END;
              if (r2 < 22) then prt('',r2+2,1); { Clear line after }
              scr_state := 1; { Set state to 1 }
            END;
        END;
 
{ Displays equipment items from r1 to end }
      procedure show_equip(r1 : integer);
        var
          i1,i2 : integer;
          prt1,prt2,out_val : vtype;
        BEGIN
          if (r1 > equip_ctr) then   { Last item gone }
            prt('',equip_ctr+3,1)
          else if (r1 > 0) then   { R1 = 0 dummy call }
            BEGIN
              i2 := 0;
              for i1 := 23 to inven_max-1 do{ Range of equipment }
                BEGIN
                  with inventory[i1] do
                    if (tval > 0) then
                      BEGIN
                        i2 := i2 + 1;
                        if (i2 >= r1) then{ Display only given range }
                          BEGIN
                            CASE i1 of { Get position }
                              23 :      prt1 := ' You are wielding   : ';
                              24 :      prt1 := ' Worn on head       : ';
                              25 :      prt1 := ' Worn around neck   : ';
                              26 :      prt1 := ' Worn on body       : ';
                              27 :      prt1 := ' Worn on arm        : ';
                              28 :      prt1 := ' Worn on hands      : ';
                              29 :      prt1 := ' Worn on right hand : ';
                              30 :      prt1 := ' Worn on left hand  : ';
                              31 :      prt1 := ' Worn on feet       : ';
                              32 :      prt1 := ' Worn about body    : ';
                              33 :      prt1 := ' Light source       : ';
                              34 :      prt1 := ' Secondary weapon   : ';
                              otherwise prt1 := ' Unknown value: ';
                            END;
                            objdes(prt2,i1,true);
                            writev(out_val,chr(i2+96),cur_char2(i1),
                                                                prt1,prt2);
                            prt(out_val,i2+2,1);
                          END;
                      END;
                END;
              prt('',i2+3,1);   { Clear last line }
              scr_state := 2;   { Set state of screen }
            END;
        END;
 
{ Remove item from equipment list }
      function remove(item_val : integer) : integer;
        var
          i1,i2,typ  : integer;
          out_val,prt1,prt2: vtype;
          flag : boolean;                                      
        BEGIN
          i1 := 0;
          flag := false;
          typ  := inventory[item_val].tval;
          repeat
            i1 := i1 + 1;
            with inventory[i1] do
              if (typ > tval) then
                BEGIN
                  for i2 :=  inven_ctr downto i1 do
                    inventory[i2+1] := inventory[i2];
                  inventory[i1]  := inventory[item_val];
                  inven_ctr:= inven_ctr   + 1;
                  equip_ctr:= equip_ctr   - 1;
                  flag := true;
                END;
          until (flag);
          CASE typ of
            10,11,12,20,21,22,23,25 : prt1  := 'Was wielding ';
            15 : prt1  := 'Light source was ';
            otherwise                 prt1  := 'Was wearing ';
          END;
          objdes(prt2,i1,true);
          out_val := prt1 + prt2 + ' (' + chr(i1+96) + ')';
          msg_print(out_val);
          inventory[item_val] := blank_treasure;
          if (item_val <> inven_max-1) then  { For secondary weapon}
            py_bonuses(inventory[i1],-1);
          remove := i1;
        END;
 
{ Unwear routine, remove a piece of equipment }
      procedure unwear;
        var
          i1,i2,com_val : integer;
          exit_flag,test_flag : boolean;
          command : char;
          out_val : vtype;
        BEGIN
          if (scr_state = 1) then
            BEGIN
              clear(1,1);
              show_equip(1);
            END;
          exit_flag := false;
          repeat
            writev(out_val,'(a-',chr(equip_ctr+96),', * for equipment list,',
                ' ^Z to exit) ','Take off which one ?');
            test_flag := false;
            msg_print(out_val);
            repeat
              inkey(command);
              com_val := ord(command);
              CASE com_val of
                0,3,25,26,27 :  BEGIN
                                  test_flag := true;
                                  exit_flag := true;
                                END;
                42 :      BEGIN
                                  clear(2,1);
                                  show_equip(1);
                                END;
                otherwise       BEGIN
                                  com_val := com_val - 96;
                                  if ((com_val >= 1) and
                                      (com_val <= equip_ctr)) then
                                    test_flag := true;
                                END;
              END;
            until (test_flag);
            if (not(exit_flag)) then
              BEGIN
                reset_flag := false; { Player turn }
                i1 := 0;
                i2 := 22;
                repeat
                  i2 := i2 + 1;
                  if (inventory[i2].tval > 0) then
                    i1 := i1 + 1;
                until (i1 = com_val);
                if (uand(%X'80000000',inventory[i2].flags) <> 0) then
                  BEGIN
                    msg_print('Hmmm, it seems to be cursed...');
                    com_val := 0;
                  END
                else
                  remove(i2);
              END;
            if (scr_state = 0) then
              exit_flag := true
            else if (equip_ctr = 0) then
              exit_flag := true
            else if (inven_ctr > 21) then
              exit_flag := true
            else if (not(exit_flag)) then
              show_equip(com_val);
          until(exit_flag);
          if (scr_state <> 0) then
            if (equip_ctr = 0) then
              clear(1,1)
            else
              prt('You are currently using -',1,1);
        END;
 
{ Wear routine, wear or wield an item }
      procedure wear;
        var
          com_val,i1,i2,i3,tmp: integer;
          out_val,prt1,prt2: vtype;
          unwear_obj : treasure_type;
          exit_flag,test_flag : boolean;
        BEGIN
          if (scr_state = 2) then
            BEGIN
              clear(1,1);
              show_inven(1,inven_ctr);
            END;
          exit_flag := false;
          repeat
            writev(out_val,'(a-',chr(inven_ctr+96),', * for equipment list,',
                ' ^Z to exit) ','Wear/Wield which one ?');
            test_flag := false;
            msg_print(out_val);
            repeat
              inkey(command);
              com_val := ord(command);
              CASE com_val of
                0,3,25,26,27 :  BEGIN
                                  test_flag := true;
                                  exit_flag := true;
                                END;
                42 :      BEGIN
                                  clear(2,1);
                                  show_inven(1,inven_ctr);
                                END;
                otherwise       BEGIN
                                  com_val := com_val - 96;
                                  if ((com_val >= 1) and
                                      (com_val <= inven_ctr)) then
                                    test_flag := true;
                                END;
              END;
            until (test_flag);
            if (not(exit_flag)) then { Main logic for wearing }
              BEGIN
                reset_flag := false; { Player turn }
                test_flag := true;
                CASE inventory[com_val].tval of { Slot for equipment }
                  10 : i1 := 23;
                  11 : i1 := 23;
                  12 : i1 := 23;
                  15 : i1 := 33;
                  20 : i1 := 23;
                  21 : i1 := 23;
                  22 : i1 := 23;
                  23 : i1 := 23;
                  25 : i1 := 23;
                  30 : i1 := 31;
                  31 : i1 := 28;
                  32 : i1 := 32;
                  33 : i1 := 24;
                  34 : i1 := 27;
                  35 : i1 := 26;
                  36 : i1 := 26;
                  40 : i1 := 25;
                  45 : if (inventory[29].tval = 0) then   { Rings }
                            i1 := 29
                          else
                            i1 := 30;
                  otherwise
                          BEGIN
                            msg_print('I don''t see how you can use that.');
                            test_flag := false;
                            com_val := 0;
                          END;
                END;
                if (test_flag) then
                  if (inventory[i1].tval > 0) then
                    BEGIN
                      if (uand(%X'80000000',inventory[i1].flags) <> 0) then
                        BEGIN
                          objdes(out_val,i1,false);
                          out_val := 'The ' + out_val + ' you are ';
                          CASE i1 of
                            23 :        out_val := out_val + 'wielding ';
                            otherwise   out_val := out_val + 'wearing ';
                          END;
                          msg_print(out_val + 'appears to be cursed.');
                          test_flag := false;
                          com_val := 0;
                        END
                      else if (inven_ctr > 21) then
                        if (inventory[com_val].number > 1) then
                          if (inventory[com_val].subval < 512) then
                            BEGIN
                        msg_print('You will have to drop something first.');
                              test_flag := false;
                              com_val := 0;
                            END;
                    END;
                if (test_flag) then
                  BEGIN
                    unwear_obj := inventory[i1];
                    inventory[i1] := inventory[com_val];
                    with inventory[i1] do
{ Fix for torches }   BEGIN
                        if ((subval > 255) and (subval < 512)) then
                          BEGIN
                            number := 1;
                            subval := subval - 255;
                          END;
{ Fix for weight }      inven_weight := inven_weight + weight*number;
                        {prt_cur_weight;}
                      END;
                    inven_destroy(com_val);  { Subtracts weight }
                    equip_ctr := equip_ctr + 1;
                    py_bonuses(inventory[i1],1);
                    if (unwear_obj.tval > 0) then
                      BEGIN
                        inventory[inven_max] := unwear_obj;
                        tmp := remove(inven_max);
                        if (tmp < com_val) then
                          com_val := tmp;
                      END;
                    CASE i1 of
                      23 : prt1 := 'You are wielding ';
                      33 : prt1 := 'Your light source is ';
                      otherwise prt1 := 'You are wearing ';
                    END;
                    objdes(prt2,i1,true);
                    i2 := 0;
                    i3 := 22;
                    repeat   { Get the right letter of equipment }
                      i3 := i3 + 1;
                      if (inventory[i3].tval > 0) then
                        i2 := i2 + 1;
                    until (i3 = i1);
                    out_val := prt1 + prt2 + ' (' + chr(i2+96)+cur_char2(i1);
                    msg_print(out_val);
                  END;
              END;
            if (scr_state = 0) then
              exit_flag := true
            else if (inven_ctr = 0) then
              exit_flag := true
            else if (not(exit_flag)) then
              show_inven(com_val,inven_ctr);
          until(exit_flag);
          if (scr_state <> 0) then prt('You are currently carrying -',1,1);
        END;
 
{ Switch primary and secondary weapons }
      procedure switch_weapon;
        var
          prt1,prt2  : vtype;
          tmp_obj : treasure_type;
        BEGIN
          if (uand(%X'80000000',inventory[23].flags) <> 0) then
            BEGIN
              objdes(prt1,23,false);
              msg_print('The ' + prt1 +
                        ' you are wielding appears to be cursed.');
            END
          else
            BEGIN { Switch weapons }
              reset_flag := false;
              tmp_obj := inventory[34];
              inventory[34] := inventory[23];
              inventory[23] := tmp_obj;
              py_bonuses(inventory[34],-1);  { Subtract bonuses }
              py_bonuses(inventory[23],1);   { Add bonuses }
              if (inventory[23].tval > 0) then
                BEGIN
                  prt1 := 'Primary weapon: ';
                  objdes(prt2,23,true);
                  msg_print(prt1 + prt2);
                END;
              if (inventory[34].tval > 0) then
                BEGIN
                  prt1 := 'Secondary weapon : ';
                  objdes(prt2,34,true);
                  msg_print(prt1 + prt2);
                END;
            END;
          if (scr_state <> 0) then
            BEGIN
              msg_print('');
              clear(1,1);
              prt('You are currently using -',1,1);
              show_equip(1);
            END;
        END;
 
{ Main logic for INVEN_COMMAND }
      BEGIN
        inven_command := false;
        exit_flag := false;
        scr_state := 0;
        repeat
          CASE command of
            'i' : BEGIN   { Inventory }
                    if (inven_ctr = 0) then
                      msg_print('You are not carrying anything.')
                    else if (scr_state <> 1) then
                      BEGIN  { Sets scr_state to 1 }
                        clear(1,1);
                        prt('You are currently carrying -',1,1);
                        show_inven(1,inven_ctr);
                      END;
                  END;
            'e' : BEGIN   { Equipment }
                    if (equip_ctr = 0) then
                      msg_print('You are not using any equipment.')
                    else if (scr_state <> 2) then
                      BEGIN  { Sets scr_state to 2 }
                        clear(1,1);
                        prt('You are currently using -',1,1);
                        show_equip(1);
                      END;
                  END;
            't' : BEGIN   { Take off }
                    if (equip_ctr = 0) then
                      msg_print('You are not using any equipment.')
                    else if (inven_ctr > 21) then
                      msg_print('You will have to drop something first.')
                    else
                      unwear;   { May set scr_state to 2 }
                  END;
            'w' : BEGIN   { Wear/wield }
                    if (inven_ctr = 0) then
                      msg_print('You are not carrying anything.')
                    else
                      wear;  { May set scr_state to 1 }
                  END;
            'x' : BEGIN
                    if (inventory[23].tval <> 0) then
                      switch_weapon
                    else if (inventory[34].tval <> 0) then
                      switch_weapon
                    else
                      msg_print('But you are wielding no weapons.');
                  END;
{ Special function for other routines }
            '?' : BEGIN { Displays part inven, returns}
                    show_inven(r1,r2);
                    scr_state := 0;  { Clear screen state }
                  END;
{ Nonsense command }
            otherwise ;
          END;
          if (scr_state > 0) then
            BEGIN
prt('<e>quip, <i>inven, <t>ake-off, <w>ear/wield, e<x>change, ^Z to exit.',24,2);
              test_flag := false;
              repeat
                inkey(command);
                com_val := ord(command);
                CASE com_val of
                  0,3,25,26,27,32 : BEGIN { Exit from module }
                                    exit_flag := true;
                                    test_flag := true;
                                  END;
                  otherwise
                   CASE command of  { Module commands }
                     'e' : test_flag := true;
                     'i' : test_flag := true;
                     't' : test_flag := true;
                     'w' : test_flag := true;
                     'x' : test_flag := true;
                     '?' : ;  { Trap special feature}
                   otherwise ; { Nonsense command }
                   END;
                END;
              until (test_flag);
              prt('',24,1);     
            END
          else
            exit_flag := true;
        until(exit_flag);
        if (scr_state > 0) then   { If true, must redraw screen }
          inven_command := true;
      END;
 
 
{ Get the ID of an item and return the CTR value of it }
    function get_item(  var com_val  : integer;
                        pmt : vtype;
                        var redraw: boolean;
                        i1,i2  : integer) : boolean;
      var
          command: char;
          out_val: vtype;
          test_flag : boolean;
      BEGIN
        get_item := false;
        com_val := 0;
        if (inven_ctr > 0) then
          BEGIN
            writev(out_val,'(Items ',chr(i1+96),'-',chr(i2+96),
                   ', * for inventory list, ^Z to exit) ',pmt);
            test_flag := false;
            prt(out_val,1,1);
            repeat
              inkey(command);
              com_val := ord(command);
              CASE com_val of
                0,3,25,26,27 :  BEGIN
                                  test_flag := true;
                                  reset_flag := true;
                                END;
                42 :      BEGIN
                                  clear(2,1);
                                  inven_command('?',i1,i2);
                                  redraw := true;
                                END;
                otherwise       BEGIN
                                  com_val := com_val - 96;
                                  if ((com_val >= i1) and
                                      (com_val <= i2)) then
                                    BEGIN
                                      test_flag := true;
                                      get_item := true;
                                    END;
                                END;
              END;
            until (test_flag);
            erase_line(msg_line,msg_line);
          END
        else
          msg_print('You are not carrying anything.');
      END;    
 
{ I may have written the town level code, but I'm not exactly
  proud of it.  Adding the stores required some real slucky
  hooks which I have not had time to re-think. }
        %INCLUDE 'MOR_INCLUDE:STORE2.INC'
 
 
{ Calculates current boundries }
    procedure panel_bounds;
      BEGIN
        panel_row_min := (trunc(panel_row*(screen_height/2)) + 1);
        panel_row_max := panel_row_min + screen_height - 1;
        panel_row_prt := panel_row_min - 2;
        panel_col_min := (trunc(panel_col*(screen_width/2)) + 1);
        panel_col_max := panel_col_min + screen_width - 1;
        panel_col_prt := panel_col_min - 15;
      END;
 
 
{ Given an row (y) and col (x), this routine detects
  when a move off the screen has occurred and figures new borders}
    function get_panel(y,x : integer) : boolean;
      var
                prow,pcol : integer;
      BEGIN
        prow := panel_row;
        pcol := panel_col;
        if ((y < panel_row_min + 2) or (y > panel_row_max - 2)) then
          BEGIN
            prow := trunc((y - 2)/(screen_height/2));
            if (prow > max_panel_rows) then
              prow := max_panel_rows;
          END;
        if ((x < panel_col_min + 3) or (x > panel_col_max - 3)) then
          BEGIN
            pcol := trunc((x - 3)/(screen_width/2));
            if (pcol > max_panel_cols) then
              pcol := max_panel_cols;
          END;
        if ((prow <> panel_row) or (pcol <> panel_col) or not(cave_flag)) then
          BEGIN
            panel_row := prow;
            panel_col := pcol;
            panel_bounds;
            get_panel := true;
            cave_flag := true;
          END
        else
          get_panel := false;
      END;
 
 
{ Tests a given point to see if it is within the screen
  boundries. }
    function panel_contains(y,x : integer) : boolean;
      BEGIN
        if ((y >= panel_row_min) and (y <= panel_row_max)) then
          if ((x >= panel_col_min) and (x <= panel_col_max)) then
            panel_contains := true
          else
            panel_contains := false
        else
          panel_contains := false;
      END;
 
 
{ Returns true if player has no light }
    function no_light : boolean;
      BEGIN
        no_light := false;
        with cave[char_row,char_col] do
          if (not(tl)) then
            if (not(pl)) then
              no_light := true;
      END;
 
 
{ Prompts for a direction }
    function get_dir(prompt : vtype;
                     var dir,com_val,y,x : integer) : boolean;
      var
                temp_prompt  : vtype;
                flag: boolean;
                command: char;
      BEGIN
        flag := false;
        temp_prompt := '(1 2 3 4 6 7 8 9) ' + prompt;
        prompt := '';
        repeat
          if (get_com(prompt,command)) then
            BEGIN
              com_val := ord(command);
              dir := com_val - 48;
{ Note that '5' is not a valid direction }
              if (dir in [1,2,3,4,6,7,8,9]) then
                BEGIN
                  move(dir,y,x);
                  flag := true;
                  get_dir := true;
                END
              else
                prompt := temp_prompt;
            END
          else
            BEGIN
              reset_flag := true;
              get_dir := false;
              flag := true;
            END;
        until (flag);
      END;
 
 
 
{ Moves creature record from one space to another }
    procedure move_rec(y1,x1,y2,x2 : integer);
      BEGIN
        if ((y1 <> y2) or (x1 <> x2)) then
          BEGIN
            cave[y2,x2].cptr := cave[y1,x1].cptr;
            cave[y1,x1].cptr := 0
          END
      END;
 
 
{ Room is lit, make it appear }
  procedure light_room(y,x : integer);
    var
        tmp1,tmp2: integer;
        start_row,start_col  : integer;
        end_row,end_col: integer;
        i1,i2 : integer;
        ypos,xpos: integer;
        floor_str: vtype;
        tmp_char : char;
 
 
    procedure find_light(y1,x1,y2,x2 : integer);
      var
        i1,i2,i3,i4  : integer;
      BEGIN
        for i1 := y1 to y2 do
          for i2 := x1 to x2 do
            if (cave[i1,i2].fval in [1,2]) then
              BEGIN
                for i3 := i1-1 to i1+1 do
                  for i4 := i2-1 to i2+1 do
                    cave[i3,i4].pl := true;
                cave[i1,i2].fval := 2;
              END;
      END;
 
    BEGIN
      tmp1 := trunc(screen_height/2);
      tmp2 := trunc(screen_width /2);
      start_row := trunc(y/tmp1)*tmp1 + 1;
      start_col := trunc(x/tmp2)*tmp2 + 1;
      end_row := start_row + tmp1 - 1;
      end_col := start_col + tmp2 - 1;
      find_light(start_row,start_col,end_row,end_col);
      for i1 := start_row to end_row do
        BEGIN
          floor_str := '';
          ypos := i1;
          for i2 := start_col to end_col do
            with cave[i1,i2] do
              BEGIN
                if ((pl) or (fm)) then
                  BEGIN
                    if (length(floor_str) = 0) then
                      xpos := i2;
                    loc_symbol(i1,i2,tmp_char);
                    floor_str := floor_str + tmp_char
                  END
                else
                  if (length(floor_str) > 0) then
                    BEGIN
                      print(floor_str,ypos,xpos);
                      floor_str := ''
                    END
              END;
          if (length(floor_str) > 0) then
            print(floor_str,ypos,xpos)
        END;
    END;
 
 
{ Lights up given location }
    procedure lite_spot(y,x : integer);
      var
                spot_char : vtype;
                temp: char;
      BEGIN
        if (panel_contains(y,x)) then
          BEGIN
            loc_symbol(y,x,temp);
            spot_char := temp;
            print(spot_char,y,x)
          END
      END;
 
 
{ Blanks out given location }
    procedure unlite_spot(y,x : integer);
      BEGIN
        if (panel_contains(y,x)) then
          print(' ',y,x);
      END;
 
 
{ Package for moving the character's light about the screen
  Three cases : Normal, Finding, and Blind }
  procedure move_light(y1,x1,y2,x2 : integer);
 
{ Maximum of a minimum 
  Macro routine included in MORIALIB.OLB }
    function maxmin ( %immed  x:integer;
                      %immed  y:integer;
                      %immed  z:integer ) : integer;  external;
 
{ Minimum of a maximum
  Macro routine included in MORIALIB.OLB }
    function minmax ( %immed  x:integer;
                      %immed  y:integer;
                      %immed  z:integer ) : integer;  external;
 
{ Given two sets of points, draw the block }
    procedure draw_block(y1,x1,y2,x2 : integer);
      var
        i1,i2,xpos: integer;
        topp,bott,left,righ: integer;
        new_topp,new_bott,new_left,new_righ  : integer;
        floor_str,save_str : vtype;
        tmp_char  : char;
        flag: boolean;
      BEGIN
{ From uppermost to bottom most lines player was on.
  Points are guaranteed to be on the screen (I hope...) }
        topp := maxmin(y1,y2,panel_row_min);
        bott := minmax(y1,y2,panel_row_max);
        left := maxmin(x1,x2,panel_col_min);
        righ := minmax(x1,x2,panel_col_max);
        new_topp := y2 - 1;  { Margins for new things to appear}
        new_bott := y2 + 1;
        new_left := x2 - 1;
        new_righ := x2 + 1;
        for i1 := topp to bott do
          BEGIN
            floor_str := ''; { Null out print string }
            xpos:= 0;
            save_str  := '';
            for i2 := left to righ do   { Leftmost to rightmost do}
              BEGIN
                with cave[i1,i2] do
                  BEGIN
                    if ((pl) or (fm)) then
                      if (((i1=y1) and (i2=x1)) or ((i1=y2) and (i2=x2))) then
                        flag := true
                      else
                        flag := false
                    else
                      BEGIN
                        flag := true;
                        if (((i1 >= new_topp) and (i1 <= new_bott)) and
                            ((i2 >= new_left) and (i2 <= new_righ))) then
                          BEGIN
                            if (tl) then
                              if (fval in pwall_set) then
                                pl := true
                              else if (tptr > 0) then
                                if (t_list[tptr].tval in light_set) then
                                  if (not(fm)) then
                                    fm := true;
                          END
                      END;
                    if ((pl) or (tl) or (fm)) then
                      loc_symbol(i1,i2,tmp_char)
                    else
                      tmp_char := ' ';
                    if (py.flags.image > 0) then
                      if (randint(12) = 1) then
                        tmp_char := chr(randint(95) + 31);
                    if (flag) then
                      BEGIN
                        if (xpos = 0) then xpos := i2;
                        if (length(save_str) > 0) then
                          BEGIN
                            floor_str := floor_str + save_str;
                            save_str := '';
                          END;
                        floor_str := floor_str + tmp_char;
                      END
                    else if (xpos > 0) then
                      save_str := save_str + tmp_char;
                  END;
              END;
            if (xpos > 0) then
              BEGIN
                i2 := i1; { Var for PRINT cannot be loop index}
                print(floor_str,i2,xpos);
              END;
          END;
      END;
 
 
{ Normal movement }
    procedure sub1_move_light(y1,x1,y2,x2 : integer);
      var
        i1,i2  : integer;
      BEGIN
        light_flag := true;
        for i1 := y1-1 to y1+1 do { Turn off lamp light }
          for i2 := x1-1 to x1+1 do
            cave[i1,i2].tl := false;
        for i1 := y2-1 to y2+1 do
          for i2 := x2-1 to x2+1 do
            cave[i1,i2].tl := true;
        draw_block(y1,x1,y2,x2);  { Redraw area }
      END;
 
{ When FIND_FLAG, light only permanent features }
    procedure sub2_move_light(y1,x1,y2,x2 : integer);
      var
        i1,i2,xpos : integer;
        floor_str,save_str  : vtype;
        tmp_char: char;
        flag : boolean;
      BEGIN
        if (light_flag) then
          BEGIN
            for i1 := y1-1 to y1+1 do
              for i2 := x1-1 to x1+1 do
                cave[i1,i2].tl := false;
            draw_block(y1,x1,y1,x1);
            light_flag := false;
          END;
        for i1 := y2-1 to y2+1 do
          BEGIN
            floor_str := '';
            save_str  := '';
            xpos := 0;
            for i2 := x2-1 to x2+1 do
              with cave[i1,i2] do
                BEGIN
                  flag := false;
                  if (not((fm) or (pl))) then
                    BEGIN
                      tmp_char := ' ';
                      if (player_light) then
                        if (fval in pwall_set) then
                          BEGIN
                            pl := true; { Turn on perm light }
                            loc_symbol(i1,i2,tmp_char);
                            flag := true;
                          END
                        else
                          if (tptr > 0) then
                            if (t_list[tptr].tval in light_set) then
                              BEGIN
                                fm := true;  { Turn on field marker}
                                loc_symbol(i1,i2,tmp_char);
                                flag := true;
                              END;
                    END
                  else
                    loc_symbol(i1,i2,tmp_char);
                  if (flag) then
                    BEGIN
                      if (xpos = 0) then xpos := i2;
                      if (length(save_str) > 0) then
                        BEGIN
                          floor_str := floor_str + save_str;
                          save_str := '';
                        END;
                      floor_str := floor_str + tmp_char;
                    END
                  else if (xpos > 0) then
                    save_str := save_str + tmp_char;
                END;
            if (xpos > 0) then
              BEGIN
                i2 := i1;
                print(floor_str,i2,xpos);
              END;
          END;
      END;
 
{ When blinded, move only the player symbol.}
    procedure sub3_move_light(y1,yx1,y2,x2 : integer);
      var
        i1,i2 : integer;
      BEGIN
        if (light_flag) then
          BEGIN
            for i1 := y1-1 to y1+1 do
              for i2 := x1-1 to x1+1 do
                cave[i1,i2].tl := false;
            light_flag := false;
          END;
        print(' ',y1,x1);
        print('@',y2,x2);
      END;
 
{ With no light, movement becomes involved.}
    procedure sub4_move_light(y1,x1,y2,x2 : integer);
      var
        i1,i2 : integer;
      BEGIN
        light_flag := true;
        if (cave[y1,x1].tl) then
          BEGIN
            for i1 := y1-1 to y1+1 do
              for i2 := x1-1 to x1+1 do
                BEGIN
                  cave[i1,i2].tl := false;
                  if (test_light(i1,i2)) then
                    lite_spot(i1,i2)
                  else
                    unlite_spot(i1,i2);
                END;
          END
        else if (test_light(y1,x1)) then
          lite_spot(y1,x1)
        else
          unlite_spot(y1,x1);
        print('@',y2,x2);
      END;
 
{ BEGIN move_light procedure }
    BEGIN
      if (py.flags.blind > 0) then
        sub3_move_light(y1,x1,y2,x2)
      else if (find_flag) then
        sub2_move_light(y1,x1,y2,x2)
      else if (not(player_light)) then
        sub4_move_light(y1,x1,y2,x2)
      else
        sub1_move_light(y1,x1,y2,x2);
    END;
 
 
{ Returns random co-ordinates }
    procedure new_spot(var y,x : integer);
      BEGIN
        repeat
          y := randint(cur_height);
          x := randint(cur_width);
        until ( (cave[y,x].fopen)       and
                (cave[y,x].cptr = 0)    and
                (cave[y,x].tptr = 0));
      END;
 
 
{ Search Mode enhancement }
    procedure search_on;
      BEGIN
        search_flag := true;
        change_speed(+1);
        py.flags.status := uor(py.flags.status,%X'00000100');
        prt_search;
        with py.flags do
          food_digested := food_digested + 1;
      END;    
 
    procedure search_off;
      BEGIN
        search_flag := false;
        find_flag := false;
        move_char(5);
        change_speed(-1);
        py.flags.status := uand(py.flags.status,%X'FFFFFEFF');
        prt_search;
        with py.flags do
          food_digested := food_digested - 1;
      END;
 
 
{ Resting allows a player to safely restore his hp }
    procedure rest;
      var
                rest_num : integer;
                rest_str : vtype;
      BEGIN
        prt('Rest for how long? ',1,1);
        get_string(rest_str,1,20,10);
        rest_num := 0;
        readv(rest_str,rest_num,error:=continue);
        if (rest_num > 0) then
          BEGIN
            if (search_flag) then
              search_off;
            py.flags.rest := rest_num;
            py.flags.status := uor(py.flags.status,%X'00000200');
            prt_rest;
            with py.flags do
              food_digested := food_digested - 1;
            msg_print('Press any key to wake up...');
            put_qio;
          END
        else
          erase_line(msg_line,msg_line);
      END;
 
    procedure rest_off;
      BEGIN
        py.flags.rest := 0;
        py.flags.status := uand(py.flags.status,%X'FFFFFDFF');
        erase_line(1,1);
        prt_rest;
        with py.flags do
          food_digested := food_digested + 1;
      END;
 
 
{ Attacker's level and pluses, defender's AC }
    function test_hit(bth,level,pth,ac : integer) : boolean;
      var
                i1 : integer;
      BEGIN
        if (search_flag) then
          search_off;
        if (py.flags.rest > 0) then
          rest_off;
        i1 := bth + level*bth_lev_adj + pth*bth_plus_adj;
        if (randint(i1) > ac) then  { Normal hit }
          test_hit := true
        else if (randint(20) = 1) then { Always hit 1/20 }
          test_hit := true
        else               { Missed }
          test_hit := false;
      END;
 
 
{ Decreases players hit points and sets death flag if neccessary}
    procedure take_hit(damage : integer; hit_from : vtype);
      BEGIN
        if (py.flags.invuln > 0) then damage := 0;
        py.misc.chp := py.misc.chp - damage;
        if (search_flag) then search_off;
        if (py.flags.rest > 0) then rest_off;
        flush;
        if (py.misc.chp <= -1) then
          BEGIN
            if (not(death)) then
              BEGIN { Hee, hee... Ain't I mean? }
                death := true;
                died_from := hit_from;
                total_winner := false;
              END;
            moria_flag := true;
          END
        else
          prt_chp;
      END;
 
 
{ Given speed, returns number of moves this turn.
  NOTE: Player must always move at least once per iteration,
        a slowed player is handled by moving monsters faster }
    function movement_rate(speed : integer) : integer;
      BEGIN
        if (speed > 0) then
          if (py.flags.rest > 0) then
            movement_rate := 1
          else
            movement_rate := speed
        else
          BEGIN
            if ((turn mod (abs(speed) + 2)) = 0) then
              movement_rate := 1
            else
              movement_rate := 0;
          END;
      END;
 
 
{ Regenerate hit points }
    procedure regenhp(percent : real);
      BEGIN
        with py.misc do
          chp := chp + mhp*percent + player$regen_hpbase;
      END;
 
 
{ Regenerate mana points }                        
    procedure regenmana(percent : real);
      BEGIN
        with py.misc do
          cmana := cmana + mana*percent + player$regen_mnbase;
      END;
 
 
{ Change a trap from invisible to visible
  Note: Secret doors are handled here }
    procedure change_trap(y,x : integer);
      var
                i3  : integer;
      BEGIN
        with cave[y,x] do
          if (t_list[tptr].tval in [101,109]) then
            BEGIN
              i3 := tptr;
              place_trap(y,x,2,t_list[i3].subval);
              pusht(i3);
              lite_spot(y,x);
            END;
      END;
 
 
{ Searches for hidden things.}
    procedure search(y,x,chance : integer);
      var
                i1,i2  : integer;
      BEGIN
        with py.flags do
          if (confused+blind > 0) then
            chance := trunc(chance/10.0)
           else if (no_light) then
            chance := trunc(chance/5.0);
        for i1 := (y - 1) to (y + 1) do
          for i2 := (x - 1) to (x + 1) do
            if (in_bounds(i1,i2)) then
              if ((i1 <> y) or (i2 <> x)) then
                if (randint(100) < chance) then
                  with cave[i1,i2] do
{ Search for hidden objects }
                    if (tptr > 0) then
                      with t_list[tptr] do
{ Trap on floor? }      if (tval = 101) then
                          BEGIN
                            msg_print('You have found ' + name + '. ');
                            change_trap(i1,i2);
                            find_flag := false;
                          END                    
{ Secret door? }        else if (tval = 109) then
                          BEGIN
                            msg_print('You have found a secret door.');
                            fval := corr_floor2.ftval;
                            change_trap(i1,i2);
                            find_flag := false;
                          END
{ Chest is trapped? }   else if (tval = 2) then
                          BEGIN
                            if (flags > 1) then
                              if (index(name,'^') > 0) then
                                BEGIN
                                  known2(name);
                msg_print('You have discovered a trap on the chest!');
                                END;
                          END;
      END;
 
 
{ Turns off Find_flag if something interesting appears
  BUG: Does not handle corridor/room corners, but I didn't want
       to add a lot of checking for such a minor detail }
    procedure area_affect(dir,y,x : integer);
      var
                z: array [1..3] of integer;
                i1,row,col: integer;
      BEGIN
        if (cave[y,x].fval = 4) then
          BEGIN
            i1 := 0;
            if (next_to4(y,x,[4,5,6]) > 2) then
              find_flag := false;
          END;
        if ((find_flag) and (py.flags.blind < 1)) then
          BEGIN
            CASE dir of
                1 :     BEGIN
                          z[1] := 4;
                          z[2] := 1;
                          z[3] := 3;
                        END;
                2 :     BEGIN
                          z[1] := 4;
                          z[2] := 2;
                          z[3] := 6;
                        END;
                3 :     BEGIN
                          z[1] := 2;
                          z[2] := 3;
                          z[3] := 6;
                        END;
                4 :     BEGIN
                          z[1] := 8;
                          z[2] := 4;
                          z[3] := 2;
                        END;
                6 :     BEGIN
                          z[1] := 2;
                          z[2] := 6;
                          z[3] := 8;
                        END;
                7 :     BEGIN
                          z[1] := 8;
                          z[2] := 7;
                          z[3] := 4;
                        END;
                8 :     BEGIN
                          z[1] := 4;
                          z[2] := 8;
                          z[3] := 6;
                        END;
                9 :     BEGIN
                          z[1] := 8;
                          z[2] := 9;
                          z[3] := 6;
                        END;
            END;
            for i1 := 1 to 3 do
              BEGIN
                row := y;
                col := x;
                if (move(z[i1],row,col)) then
                  with cave[row,col] do
                    BEGIN
{ Empty doorways }    if (fval = 5) then
                        find_flag := false;
{ Objects player can see
  Including doors }
                      if (find_flag) then
                        if (player_light) then
                          BEGIN
                            if (tptr > 0) then
                              if (not(t_list[tptr].tval in [101,109])) then
                                find_flag := false;
                          END
                        else if ((tl) or (pl) or (fm)) then
                          if (tptr > 0) then
                            if (not(t_list[tptr].tval in [101,109])) then
                              find_flag := false;
{ Creatures }          if (find_flag) then
                        if ((tl) or (pl) or (player_light)) then
                          if (cptr > 1) then
                            with m_list[cptr] do
                              if (ml) then
                                find_flag := false;
                    END
              END
          END;
      END;
 
 
{ Picks new direction when in find mode }
    function pick_dir(dir : integer) : boolean;
      var
                z: array [1..2] of integer;
                i1,y,x : integer;
      BEGIN
        if ((find_flag) and (next_to4(char_row,char_col,corr_set) = 2)) then
          BEGIN
            CASE dir of
                1 :     BEGIN
                          z[1] := 2;
                          z[2] := 4;
                        END;
                2 :     BEGIN
                          z[1] := 4;
                          z[2] := 6;
                        END;
                3 :     BEGIN
                          z[1] := 2;
                          z[2] := 6;
                        END;
                4 :     BEGIN
                          z[1] := 2;
                          z[2] := 8;
                        END;
                6 :     BEGIN
                          z[1] := 2;
                          z[2] := 8;
                        END;
                7 :     BEGIN
                          z[1] := 4;
                          z[2] := 8;
                        END;
                8 :     BEGIN
                          z[1] := 4;
                          z[2] := 6;
                        END;
                9 :     BEGIN
                          z[1] := 6;
                          z[2] := 8;
                        END;
            END;
            pick_dir := false;
            for i1 := 1 to 2 do
              BEGIN
                y := char_row;
                x := char_col;
                if (move(z[i1],y,x)) then
                  if (cave[y,x].fopen) then
                    BEGIN
                      pick_dir := true;
                      com_val := z[i1] + 48
                    END
              END
          END
        else
          BEGIN
            pick_dir := false;
          END;
      END;
 
 
{ AC gets worse
  Note: This routine affects magical AC bonuses so that stores
        can detect the damage. }
    function minus_ac(typ_dam : integer) : boolean;
      var
        i1,i2 : integer;
        tmp: array [1..5] of integer;
      BEGIN
        i1 := 0;
        if (inventory[26].tval > 0) then
          BEGIN
            i1 := i1 + 1;
            tmp[i1] := 26;
          END;
        if (inventory[27].tval > 0) then
          BEGIN
            i1 := i1 + 1;
            tmp[i1] := 27;
          END;
        if (inventory[32].tval > 0) then
          BEGIN
            i1 := i1 + 1;
            tmp[i1] := 32;
          END;
        if (inventory[28].tval > 0) then
          BEGIN
            i1 := i1 + 1;
            tmp[i1] := 28;
          END;
        if (inventory[24].tval > 0) then
          BEGIN
            i1 := i1 + 1;
            tmp[i1] := 24;
          END;
        minus_ac := false;
        if (i1 > 0) then
          BEGIN
            i2 := tmp[randint(i1)];
            with inventory[i2] do
              if (uand(flags,typ_dam) <> 0) then
                BEGIN
                  objdes(out_val,i2,false);
                  msg_print('Your ' + out_val + ' resists damage!');
                  minus_ac := true;
                END
              else if ((ac+toac) > 0) then
                BEGIN
                  objdes(out_val,i2,false);
                  msg_print('Your ' + out_val + ' is damaged!');
                  toac := toac - 1;
                  py_bonuses(blank_treasure,0);
                  minus_ac := true;
                END
          END
      END;
 
 
{ Corrode the unsuspecting person's armor }
    procedure corrode_gas(kb_str : vtype);
      BEGIN
        if (not (minus_ac(%X'00100000'))) then
          take_hit(randint(8),kb_str);
        print_stat := uor(%X'0040',print_stat);
        if (inven_damage([23,33,34,35,65],5) > 0) then
          msg_print('There is an acrid smell coming from your pack.');
      END;
 
 
{ Poison gas the idiot.}
    procedure poison_gas(dam : integer; kb_str : vtype);
      BEGIN
        take_hit(dam,kb_str);
        print_stat := uor(%X'0040',print_stat);
        py.flags.poisoned := py.flags.poisoned + 12 + randint(dam);
      END;
 
 
{ Burn the fool up.}
    procedure fire_dam(dam : integer; kb_str : vtype);
      BEGIN
        if (py.flags.fire_resist)then
          dam := trunc(dam*0.5);
        if (py.flags.resist_heat > 0) then
          dam := trunc(dam*0.5);
        take_hit(dam,kb_str);
        print_stat := uor(%X'0080',print_stat);
        if (inven_damage([12,20,21,22,30,31,32,36,55,70,71],3) > 0) then
          msg_print('There is smoke coming from your pack!');
      END;
 
 
{ Freeze him to death.}
    procedure cold_dam(dam : integer; kb_str : vtype);
      BEGIN
        if (py.flags.cold_resist)then
          dam := trunc(dam*0.5);
        if (py.flags.resist_cold > 0) then
          dam := trunc(dam*0.5);
        take_hit(dam,kb_str);
        print_stat := uor(%X'0080',print_stat);
        if (inven_damage([75,76],5) > 0) then
          msg_print('Something shatters inside your pack!');
      END;
 
 
{ Lightning bolt the sucker away.}
    procedure light_dam(dam : integer; kb_str : vtype);
      BEGIN
        if (py.flags.lght_resist) then
          take_hit(trunc(dam*0.5),kb_str)
        else
          take_hit(dam,kb_str);
        print_stat := uor(%X'0080',print_stat);
      END;
 
 
{ Throw acid on the hapless victim }
    procedure acid_dam(dam : integer; kb_str : vtype);
      var
                flag: integer;
      BEGIN
        flag := 0;
        if (minus_ac(%X'00100000')) then
          flag := 1;
        if (py.flags.acid_resist) then
          flag := flag + 2;
        CASE flag of
          0 : take_hit(dam,kb_str);
          1 : take_hit(trunc(dam*0.75),kb_str);
          2 : take_hit(trunc(dam*0.5),kb_str);
          3 : take_hit(trunc(dam*0.25),kb_str);
        END;
        print_stat := uor(%X'00C0',print_stat);
        if (inven_damage([1,2,11,12,20,21,22,30,31,32,36],3) > 0) then
          msg_print('There is an acrid smell coming from your pack!');
      END;
 
 
{ Teleport the player to a new location }
    procedure teleport(dis : integer);
      var
                y,x  : integer;
      BEGIN
        repeat
          y := randint(cur_height);
          x := randint(cur_width);
          while (distance(y,x,char_row,char_col) > dis) do
            BEGIN
              y := y + trunc((char_row-y)/2);
              x := x + trunc((char_col-x)/2);
            END;
        until ((cave[y,x].fopen) and (cave[y,x].cptr  < 2));
        move_rec(char_row,char_col,y,x);
        for i1 := char_row-1 to char_row+1 do
          for i2 := char_col-1 to char_col+1 do
            with cave[i1,i2] do
              BEGIN
                tl := false;
                if (not(test_light(i1,i2))) then
                  unlite_spot(i1,i2);
              END;
        if (test_light(char_row,char_col)) then
          lite_spot(char_row,char_col);
        char_row := y;
        char_col := x;
        move_char(5);
        creatures(false);
        teleport_flag := false;
      END;
                 
 
{ Player hit a trap...  (Chuckle)}
    procedure hit_trap(var y,x : integer);
      var
        alloc_level,i1,i2,ty,tx,dam : integer;

      BEGIN
        change_trap(y,x);
        lite_spot(char_row,char_col);
        find_flag := false;
        with cave[y,x] do
        with py.misc do
          BEGIN
            dam := damroll(t_list[tptr].damage);
            CASE t_list[tptr].subval of
{ Open pit}   1 : BEGIN
                    msg_print('You fell into a pit!');
                    if (py.flags.ffall) then
                      msg_print('You gently float down.')
                    else
                      take_hit(dam,'an open pit.');
                  END;
{ Arrow trap} 2 : BEGIN
                    if (test_hit(125,0,0,pac+ptoac)) then
                      BEGIN
                        take_hit(dam,'an arrow trap.');
                        msg_print('An arrow hits you.');
                      END
                    else
                      msg_print('An arrow barely misses you.');
                  END;
{ Covered pit}3 : BEGIN
                    msg_print('You fell into a covered pit.');
                    if (py.flags.ffall) then
                      msg_print('You gently float down.')
                    else
                      take_hit(dam,'a covered pit.');
                      place_trap(y,x,2,1);
                  END;
{ Trap door}  4 : BEGIN
                    msg_print('You fell through a trap door!');
                    msg_print(' ');
                    moria_flag := true;
                    dun_level := dun_level + 1;
                    if (dun_level > 1200) then dun_level := 1200;
                    if (py.flags.ffall) then
                      msg_print('You gently float down.')
                    else
                      take_hit(dam,'a trap door.');
                  END;
{ Sleep gas}  5 : if (py.flags.paralysis = 0) then
                    BEGIN
                      msg_print('A strange white mist surrounds you!');
                      if (py.flags.free_act) then
                        msg_print('You are unaffected.')
                      else
                        BEGIN
                          msg_print('You fall asleep.');
                          py.flags.paralysis := py.flags.paralysis +
                                                        randint(10) + 4;
                        END
                    END;
{ Hid Obj}    6 : BEGIN
                    fm := false;
                    pusht(tptr);
                    place_object(y,x);
                    msg_print('Hmmm, there was something under this rock.');
                  END;
 { STR Dart}  7 : BEGIN
                    if (test_hit(125,0,0,pac+ptoac)) then
                      BEGIN
                        if (not py.flags.sustain_str) then
                          BEGIN
                            py.stat.cstr := de_statp(py.stat.cstr);
                            take_hit(dam,'a dart trap.');
                            print_stat := uor(%X'0001',print_stat);
                            msg_print('A small dart weakens you!');
                          END
                        else
                          msg_print('A small dart hits you.');
                      END
                    else
                      msg_print('A small dart barely misses you.');
                  END;
{ Teleport}   8 : BEGIN
                    teleport_flag := true;
                    msg_print('You hit a teleport trap!');
                  END;
{ Rockfall}   9 : BEGIN
                    take_hit(dam,'falling rock.');
                    pusht(tptr);
                    place_rubble(y,x);
                    msg_print('You are hit by falling rock');
                  END;
{ Corrode gas}10: BEGIN
                    corrode_gas('corrosion gas.');
                    msg_print('A strange red gas surrounds you.');
                  END;
{ Summon mon} 11: BEGIN
                    fm := false;  { Rune disappears...}
                    pusht(tptr);
                    tptr := 0;
                    for i1 := 1 to (2+randint(3)) do
                      BEGIN
                        ty := char_row;
                        tx := char_col;
                        summon_monster(ty,tx,false);
                      END;
                  END;
{ Fire trap}  12: BEGIN
                    fire_dam(dam,'a fire trap.');
                    msg_print('You are enveloped in flames!');
                  END;
{ Acid trap}  13: BEGIN
                    acid_dam(dam,'an acid trap.');
                    msg_print('You are splashed with acid!');
                  END;
{ Poison gas} 14: BEGIN
                    poison_gas(dam,'a poison gas trap.');
                    msg_print('A pungent green gas surrounds you!');
                    Opusii_vomit(5);
                  END;
{ Blind Gas } 15: BEGIN
                    msg_print('A black gas surrounds you!');
                    with py.flags do
                      blind := blind + randint(50) + 50;
                  END;
{ H-Bomb }    16: begin                                
                    take_hit(dam,'a bomb.');
                    msg_print('You have set off a bomb!');
                    msg_print('The Earth shakes ...');
                    msg_print('Rocks fly all around you ...');
                    with py.flags do
                       begin
                          blind := 1 + randint(10);
                          confused := 5 + randint(10);
                       end
                  end;
{ Slow Dart}  17: BEGIN
                    if (test_hit(125,0,0,pac+ptoac)) then
                      BEGIN
                        take_hit(dam,'a dart trap.');
                        msg_print('A small dart hits you!');
                        with py.flags do
                          slow := slow + randint(20) + 10;
                      END
                    else
                      msg_print('A small dart barely misses you.');
                  END;
{ CON Dart}   18: BEGIN
                    if (test_hit(125,0,0,pac+ptoac)) then
                      BEGIN
                        if (not py.flags.sustain_con) then
                          BEGIN
                            py.stat.ccon := de_statp(py.stat.ccon);
                            take_hit(dam,'a dart trap.');
                            print_stat := uor(%X'0004',print_stat);
                            msg_print('A small dart weakens you!');
                          END
                        else
                          msg_print('A small dart hits you.');
                      END
                    else
                      msg_print('A small dart barely misses you.');
                  END;

{Secret Door}    19: ;                   

{Teleport levels}20: begin
                       msg_print('You have a strange feeling...');
                       msg_print('You slip into unconsciousness...');
                       py.flags.paralysis := py.flags.paralysis+4+randint(4);
                       msg_print('You wake up confused.');
                       py.flags.confused := py.flags.confused+10+randint(20);
                       case randint(2) of
                         1: dun_level := dun_level + 5;
                         2: dun_level := dun_level - 5;
                       end;
                       if (dun_level<0) then dun_level := 0;
                       if (dun_level>1200) then dun_level := 1200;
                       moria_flag := true;
                     end;



{Scare Mon}      99: ; 

 
{Town level traps are special, the stores.}
{General }      101: enter_store(1);
{Armory }       102: enter_store(2);
{Weaponsmith}   103: enter_store(3);
{Temple }       104: enter_store(4);
{Alchemy}       105: enter_store(5);
{Magic-User }   106: enter_store(6);
{Black Market}  107: enter_store(7);

                otherwise       msg_print('Unknown trap value');
            END
          END
      END;
 
                 
{ Return spell number and failure chance }
    function cast_spell(prompt : vtype;
                        item_val  : integer;
                        var sn,sc : integer;
                        var redraw: boolean) : boolean;
      var
                i2  : unsigned;
                i1,i3  : integer;
                spell  : spl_type;
      BEGIN  
        i1 := 0;
        i2 := inventory[item_val].flags;
        repeat
	  i3 := bit_pos (i2);
          if (class[py.misc.pclass].mspell) then
          if (i3 > 0) then
            with mage_spell[py.misc.pclass,i3] do
              if (slevel <= py.misc.lev) then
                if (learned) then
                  BEGIN
                    i1 := i1 + 1;
                    spell[i1].splnum := i3;
                  END;
          if (class[py.misc.pclass].pspell) then
          if (i3 > 0) then
            with priest_spell[py.misc.pclass,i3] do
              if (slevel <= py.misc.lev) then
                if (learned) then
                  BEGIN
                    i1 := i1 + 1;
                    spell[i1].splnum := i3;
                  END;
          if (class[py.misc.pclass].espell) then
          if (i3 > 0) then
            with extra_spell[py.misc.pclass,i3] do
              if (slevel <= py.misc.lev) then
                if (learned) then
                  BEGIN
                    i1 := i1 + 1;
                    spell[i1].splnum := i3;
                  END;

        until(i2 = 0);
        if (i1 > 0) then
          cast_spell := get_spell(spell,i1,sn,sc,prompt,redraw);
        if (redraw) then
          draw_cave;
      END;
 
 
{ Finds range of item in inventory list }
    function find_range(item_val : obj_set; var i2,i3 : integer) : boolean;
      var
                i1  : integer;
                flag: boolean;
      BEGIN
        i1 := 0;
        i2 := 0;
        i3 := 0;
        flag := false;
        while(i1 < inven_ctr) do
          BEGIN
            i1 := i1 + 1;
            if ((inventory[i1].tval in item_val) and (not (flag))) then
              BEGIN
                flag := true;
                i2 := i1;
              END;
            if ((not(inventory[i1].tval in item_val)) and (flag) and
                                                                (i3 = 0)) then
              i3 := i1 - 1;
          END;
        if ((flag) and (i3 = 0)) then
          i3 := inven_ctr;
        find_range := flag;
      END;
 
 
{ Examine a Book }
    procedure examine_book;
      var
                i2 : unsigned;
                i1,i3,item_val : integer;
                redraw,flag : boolean;
                dummy : char;
                out_val  : vtype;
      BEGIN
        redraw := false;
        if (not(find_range([90,91,92],i1,i3))) then
          msg_print('You are not carrying any books.')
        else if (get_item(item_val,'Which Book?',redraw,i1,i3)) then
          BEGIN
            flag := true;
            with inventory[item_val] do
              if (class[py.misc.pclass].mspell) then
                BEGIN
                  if (tval <> 90) then
                    BEGIN
                      msg_print('You do not understand the language.');
                      flag := false;
                    END;
                END
              else if (class[py.misc.pclass].pspell) then
                BEGIN
                  if (tval <> 91) then
                    BEGIN
                      msg_print('You do not understand the language.');
                      flag := false;
                    END; 
                END
              else if (class[py.misc.pclass].espell) then
                BEGIN
                  if (tval <> 92) then
                    BEGIN
                      msg_print('You do not understand the language.');
                      flag := false;
                    END;
                END
              else
                BEGIN
                  msg_print('You do not understand the language.');
                  flag := false;
                END;


            if (flag) then
              BEGIN
                redraw := true;
                i1 := 0;
                i2 := inventory[item_val].flags;
                clear(1,1);
        writev(out_val,'   Name                         Level  Mana   Known');
                prt(out_val,1,1);
                repeat                                         
                  i3 := bit_pos(i2);
                  if (i3 > 0) then
                  if (class[py.misc.pclass].mspell) then
                    with mage_spell[py.misc.pclass,i3] do
                      BEGIN
                        i1 := i1 + 1;
                        if (slevel < 99) then
                          BEGIN
                            writev(out_val,chr(96+i1),') ',pad(sname,' ',30),
                                slevel:2,'     ',smana:2,'   ',learned);
                            prt(out_val,i1+1,1);
                          END
                        else
                          prt('',i1+1,1);
                      END;
                  if (class[py.misc.pclass].pspell) then
                    with priest_spell[py.misc.pclass,i3] do
                      BEGIN
                        i1 := i1 + 1;
                        if (slevel < 99) then
                          BEGIN
                            writev(out_val,chr(96+i1),') ',pad(sname,' ',30),
                                slevel:2,'     ',smana:2,'   ',learned);
                            prt(out_val,i1+1,1);
                          END
                        else
                          prt('',i1+1,1);
                      END;
                  if (class[py.misc.pclass].espell) then
                    with extra_spell[py.misc.pclass,i3] do
                      BEGIN
                        i1 := i1 + 1;
                        if (slevel < 99) then
                          BEGIN
                            writev(out_val,chr(96+i1),') ',pad(sname,' ',30),
                                slevel:2,'     ',smana:2,'   ',learned);
                            prt(out_val,i1+1,1);
                          END
                        else
                          prt('',i1+1,1);
                      END;
                until (i2 = 0);
                prt('[Press any key to continue]',24,20);
                inkey(dummy);
              END;
          END;
        if (redraw) then draw_cave;
      END;
 
 
{ Player is on an object.  Many things can happen BASED
  on the TVAL of the object.  Traps are set off, money and most
  objects are picked up.  Some objects, such as open doors, just
  sit there.}
    procedure carry(y,x : integer);
      var
        item_val: integer;
        out_val : vtype;
      BEGIN
        find_flag := false;
        with cave[y,x] do
          BEGIN                        
            inventory[inven_max] := t_list[tptr];
{ There's GOLD in them thar hills! }
            if (t_list[tptr].tval = 100) then
              BEGIN
                pusht(tptr);
                tptr := 0;
                with inventory[inven_max] do
                  BEGIN
                    py.misc.au := py.misc.au + cost;
                    writev(out_val,'You have found ',cost:1,
                                ' gold pieces worth of ',name,'. ');
                  END;
                prt_gold;
                msg_print(out_val);
              END
{ OOPS! }   else
              if (t_list[tptr].tval in trap_set) then
                hit_trap(y,x)
              else {Attempt to pick up an object}
               if (t_list[tptr].tval < 100) then
                BEGIN
{ Wgt lim check }   if (inven_check_weight) then
{ Too many objects? } if (inven_check_num) then
{ Okay, pick it up }    BEGIN
                        pusht(tptr);
                        tptr := 0;
                        inven_carry(item_val);
                        objdes(out_val,item_val,true);
                        out_val := 'You have ' + out_val + ' (' +
                                chr(item_val+96) + cur_char1(item_val);
                        prt_cur_weight;
                        msg_print(out_val);
                      END
                    else
                      msg_print('You can''t carry that many items.')
                   else
                     msg_print('You can''t carry that much weight.')
                END
          END
      END;
 
 
{ Drop an object being carried   Note: Only one object per floor spot.}
    procedure drop;
      var
                com_val,i1,i2: integer;
                redraw : boolean;
                out_val: vtype;
      BEGIN
        if (inven_ctr > 0) then
          BEGIN
            if (get_item(com_val,'Which one? ',redraw,1,inven_ctr)) then
              BEGIN
                if (redraw) then draw_cave;
                with cave[char_row,char_col] do
                  if (tptr > 0) then
                    msg_print('There is something there already.')
                  else
                    BEGIN
                      inven_drop(com_val,char_row,char_col);
                      objdes(out_val,inven_max,true);
                      out_val := 'Dropped ' + out_val;
                      prt_cur_weight;
                      msg_print(out_val);
                    END
              END
            else if (redraw) then
              draw_cave;
          END
        else
          msg_print('You are not carrying anything.');
      END;
 
 
{ Deletes a monster entry from the level }
    procedure delete_monster(i2 : integer);
      var
                i1,i3  : integer;
      BEGIN
        i1 := muptr;
        i3 := m_list[i2].nptr;
        if (i1 = i2) then
          muptr := i3
        else
          BEGIN
            while (m_list[i1].nptr <> i2) do
              i1 := m_list[i1].nptr;
            m_list[i1].nptr := i3;
          END;
        with m_list[i2] do
          BEGIN
            cave[fy,fx].cptr := 0;
            if (ml) then
              with cave[fy,fx] do
                if ((pl) or (tl)) then
                  lite_spot(fy,fx)
                else
                  unlite_spot(fy,fx);
            pushm(i2);
          END;
        mon_tot_mult := mon_tot_mult - 1;
      END;
 
 
{ Makes sure new creature gets lit up }
  procedure check_mon_lite(y,x : integer);
    BEGIN
      with cave[y,x] do
        if (cptr > 1) then
          if (not(m_list[cptr].ml)) then
            if ((tl) or (pl)) then
              if (los(char_row,char_col,y,x)) then
                BEGIN
                  m_list[cptr].ml := true;
                  lite_spot(y,x);
                END;
    END;
 
 
{ Places creature adjacent to given location
  Rats and Flys are fun! }
  procedure multiply_monster(y,x,z : integer; slp : boolean);
    var
        i1,i2,i3 : integer;
    BEGIN
      i1 := 0;
      repeat
        i2 := y - 2 + randint(3);
        i3 := x - 2 + randint(3);
        if (in_bounds(i2,i3)) then
          with cave[i2,i3] do
            if (fval in floor_set) then
              if ((tptr = 0) and (cptr <> 1)) then
                BEGIN
                  if (cptr > 1) then { Creature there already? }
                    BEGIN
{ Some critters are canabalistic! }
                      if (uand(c_list[z].cmove,%X'00080000') <> 0) then
                        BEGIN
                          delete_monster(cptr);
                          place_monster(i2,i3,z,slp);
                          check_mon_lite(i2,i3);
                          mon_tot_mult := mon_tot_mult + 1;
                        END;
                    END
                  else
{ All clear, place a monster }
                    BEGIN
                      place_monster(i2,i3,z,slp);
                      check_mon_lite(i2,i3);
                      mon_tot_mult := mon_tot_mult + 1;
                    END;
                  i1 := 18;
                END;
        i1 := i1 + 1;
      until (i1 > 18);
    END;
 
 
{ Creates objects nearby the coordinates given 
  BUG: Because of the range, objects can actually be placed into
       areas closed off to the player, this is rarely noticable,
       and never a problem to the game.}
  procedure summon_object(y,x,num,typ : integer);
    var
        i1,i2,i3 : integer;
    BEGIN
      repeat
        i1 := 0;
        repeat
          i2 := y - 3 + randint(5);
          i3 := x - 3 + randint(5);
          if (in_bounds(i2,i3)) then
            with cave[i2,i3] do
              if (fval in floor_set) then
                if (tptr = 0) then
                  BEGIN
                    CASE typ of  { Select type of object }
                      1 :  place_object(i2,i3);
                      2 :  place_gold(i2,i3);
                      3 :  if (randint(100) < 50) then
                             place_object(i2,i3)
                           else
                             place_gold(i2,i3);
                      otherwise ;
                    END;
                    if (test_light(i2,i3)) then
                      lite_spot(i2,i3);
                    i1 := 10;
                  END;
          i1 := i1 + 1;
        until (i1 > 10);
        num := num - 1;
      until (num = 0);
    END;
 
 
{ Deletes object from given location }
  function delete_object(y,x : integer) : boolean;
    BEGIN
      delete_object := false;
      with cave[y,x] do
        BEGIN
          if (t_list[tptr].tval = 109) then
            fval := corr_floor3.ftval;
          fopen := true;
          pusht(tptr);
          tptr := 0;
          fm := false;
          if (test_light(y,x)) then
            BEGIN
              lite_spot(y,x);
              delete_object := true;
            END
          else
            unlite_spot(y,x);
        END;
    END;
 
 
{ Allocates objects upon a creatures death
  Oh well, another creature bites the dust...  Reward the victor
  based on flags set in the main creature record }
  procedure monster_death(y,x : integer; flags : unsigned);
    var
        i1  : integer;
    BEGIN
      if (uand(flags,%X'01000000') <> 0) then
        i1 := 1
      else
        i1 := 0;
      if (uand(flags,%X'02000000') <> 0) then
        i1 := i1 + 2;
      if (uand(flags,%X'04000000') <> 0) then
        if (randint(100) < 60) then
          summon_object(y,x,1,i1);
      if (uand(flags,%X'08000000') <> 0) then
        if (randint(100) < 90) then
          summon_object(y,x,1,i1);
      if (uand(flags,%X'10000000') <> 0) then
        summon_object(y,x,randint(2),i1);
      if (uand(flags,%X'20000000') <> 0) then
        summon_object(y,x,damroll('2d2'),i1);
      if (uand(flags,%X'40000000') <> 0) then
        summon_object(y,x,damroll('4d3'),i1);
      if ((uand(flags,%X'80000000') <> 0) and balrog_ded) then
        BEGIN
          total_winner := true;
          prt_winner;
          msg_print('*** CONGRATULATIONS *** You have won the game...');
          msg_print('Use <CONTROL>-Y when you are ready to quit.');
        END;
    END;
 
 
{ Decreases monsters hit points and deletes monster if needed.
  (Picking on my babies...) }
    function mon_take_hit(monptr,dam : integer) : integer;
      var    
        acc_tmp  : real;
      BEGIN
        with m_list[monptr] do
          BEGIN
            hp := hp - dam;
            csleep := 0;
            if (hp < 0) then
              BEGIN
                balrog_ded := check_balrog(monptr,mptr);
                monster_death(fy,fx,c_list[mptr].cmove);
                with c_list[mptr] do
                  with py.misc do
                    BEGIN
                     acc_tmp := mexp*((level+0.1)/lev);
                     i1 := trunc(acc_tmp);
                     acc_exp := acc_exp + (acc_tmp - i1);
                     if (acc_exp > 1) then
                       BEGIN
                         i1 := i1 + 1;
                         acc_exp := acc_exp - 1.0
                       END;
                     {Penalize player - subtract experience}
                     if (uand(cdefense,%X'00000400') <> 0) then
                       begin
                         exp := exp - 10*lev;
                         if (exp < 0) then exp:=0;
                       end
                     else
                        exp := exp + i1;
                     if (i1 > 0) then prt_experience
                    END;
                mon_take_hit := mptr;
                delete_monster(monptr);
              END
            else
              mon_take_hit := 0;
          END
      END;
 
 
{ Special damage due to magical abilities of object }
    function tot_dam(item : treasure_type;  tdam : integer;
                     monster : creature_type) : integer;
      BEGIN
        with item do
          if (tval in [10,11,12,20,21,22,23,77]) then
            with monster do
              BEGIN
{ Slay Dragon } if ((uand(cdefense,%X'0001') <> 0) and
                    (uand(flags,%X'00002000') <> 0)) then
                  tdam := tdam*4
{ Slay Undead } else if ((uand(cdefense,%X'0008') <> 0) and
                         (uand(flags,%X'00010000') <> 0)) then
                  tdam := tdam*3
{ Slay Monster} else if ((uand(cdefense,%X'0002') <> 0) and
                         (uand(flags,%X'00004000') <> 0)) then
                  tdam := tdam*2
{ Slay Evil }   else if ((uand(cdefense,%X'0004') <> 0) and
                         (uand(flags,%X'00008000') <> 0)) then
                  tdam := tdam*2
{ Frost }       else if ((uand(cdefense,%X'0010') <> 0) and
                         (uand(flags,%X'00020000') <> 0)) then
                  tdam := trunc(tdam*1.5)
{ Fire }        else if ((uand(cdefense,%X'0020') <> 0) and
                         (uand(flags,%X'00040000') <> 0)) then
                  tdam := trunc(tdam*1.5);
            END;
        tot_dam := tdam;
      END;
 
 
{ Player attacks a (poor, defenseless) creature }
    function py_attack(y,x : integer) : boolean;
      var
        i1,i2,i3,blows,tot_tohit  : integer;
        m_name,out_val: vtype;
      BEGIN
        py_attack := false;
        i1 := cave[y,x].cptr;
        i2 := m_list[i1].mptr;
        m_list[i1].csleep := 0;
{ Does the player know what he's fighting? }
        if ((uand(%X'10000',c_list[i2].cmove) <> 0) and
            (not(py.flags.see_inv))) then
          m_name := 'it'
        else if (py.flags.blind > 0) then
          m_name := 'it'
        else if (not(m_list[i1].ml)) then
          m_name := 'it'
        else
          m_name := 'the ' + c_list[i2].name;
        if (inventory[23].tval > 0) then  { Proper weapon }
          blows := attack_blows(inventory[23].weight,tot_tohit)
        else               { Bare hands? }
          BEGIN
            blows := 2;
            tot_tohit := -3;
          END;
        if (inventory[23].tval in [10,11,12]) then { Fix for arrows}
          blows := 1;
        tot_tohit := tot_tohit + py.misc.ptohit;
{ Loop for number of blows, trying to hit the critter.}
        with py.misc do
          repeat
            if (test_hit(bth,lev,tot_tohit,c_list[i2].ac)) then
              BEGIN
                writev(out_val,'You hit ',m_name,'. ');
                msg_print(out_val);
                with inventory[23] do
                  BEGIN
{ Weapon? }         if (tval > 0) then
                      BEGIN
                        i3 := damroll(damage);
                        i3 := tot_dam(inventory[23],i3,c_list[i2]);
                        i3 := critical_blow(weight,tot_tohit,i3);
                      END
{ Bare hands!?}     else
                      BEGIN
                        i3 := damroll(bare_hands);
                        i3 := critical_blow(1,0,i3);
                      END;
                  END;
                i3 := i3 + ptodam;
                if (i3 < 0) then i3 := 0;
{ See if we done it in.}
                with m_list[i1] do
                  if (mon_take_hit(i1,i3) > 0) then
                    BEGIN
                      writev(out_val,'You have slain ',m_name,'. ');
                      msg_print(out_val);
                      blows := 0;
                      py_attack := false;
                    END
                  else
                    py_attack := true;  { If creature hit, but alive...}
                  with inventory[23] do
{ Use missles up}   if (tval in [10,11,12]) then
                      BEGIN
                        number := number - 1;
                        if (number <= 0) then
                          BEGIN
                            inven_weight := inven_weight - weight;
                            equip_ctr := equip_ctr - 1;
                            inventory[inven_max] := inventory[23];
                            inventory[23] := blank_treasure;
                            py_bonuses(inventory[inven_max],-1);
                            prt_cur_weight;
                          END;
                      END;
              END
            else
              BEGIN
                writev(out_val,'You miss ',m_name,'. ');
                msg_print(out_val);
              END;
            blows := blows - 1;
          until (blows < 1);
      END;
 
 
{ Moves player from one space to another.
  Note: This rountine has been pre-declared; see that for argument}
    procedure move_char;
      var
                test_row,test_col : integer;
                panrow,pancol  : integer;
                i1,i2 : integer;
      BEGIN
        test_row := char_row;
        test_col := char_col;
        if (py.flags.confused > 0) then   { Confused? }
          if (randint(4) > 1) then  { 75% random movement }
            if (dir <> 5) then   { Never random if sitting}
              BEGIN
                dir := randint(9);
                find_flag := false;
              END;
        if (move(dir,test_row,test_col)) then   { Legal move? }
          with cave[test_row,test_col] do
            if (cptr < 2) then   { No creature? }
              BEGIN
                if (fopen) then  { Open floor spot }
                  BEGIN
{ Move character record (-1) }
                    move_rec(char_row,char_col,test_row,test_col);
{ Check for new panel }
                    if (get_panel(test_row,test_col)) then
                      prt_map;
{ Check to see if he should stop }
                    if (find_flag) then
                      area_affect(dir,test_row,test_col);
{Check to see if he notices something}
                    if (py.flags.blind < 1) then
                      if ((randint(py.misc.fos) = 1) or (search_flag)) then
                        search(test_row,test_col,py.misc.srh);
{ An object is beneath him.}
                    if (tptr > 0) then
                      carry(test_row,test_col);
{ Move the light source }
                    move_light(char_row,char_col,test_row,test_col);
{ A room of light should be lit.}
                    if (fval = lopen_floor.ftval) then
                      BEGIN
                        if (py.flags.blind < 1) then
                          if (not(pl)) then
                            light_room(test_row,test_col);
                      END
{ In doorway of light-room? }
                    else if (fval in [5,6]) then
                      if (py.flags.blind < 1) then
                        BEGIN
                          for i1 := (test_row - 1) to (test_row + 1) do
                            for i2 := (test_col - 1) to (test_col + 1) do
                              if (in_bounds(i1,i2)) then
                                with cave[i1,i2] do
                                  if (fval = lopen_floor.ftval) then
                                    if (not(pl)) then
                                      light_room(i1,i2);
                        END;
{ Make final assignments of char co-ords}
                    char_row := test_row;
                    char_col := test_col;
                  END
                else {Can't move onto floor space}
{ Try a new direction if in find mode }
                  if (not(pick_dir(dir))) then
                    BEGIN
                      if (find_flag) then
                        BEGIN
                          find_flag := false;
                          move_char(5);
                        END
                      else if (tptr > 0) then
                        BEGIN
                          reset_flag := true;
                          if (t_list[tptr].tval = 103) then
                            msg_print('There is rubble blocking your way.')
                          else if (t_list[tptr].tval = 105) then
                         msg_print('There is a closed door blocking your way.');
                        END
                      else
                        reset_flag := true;
                    END
              END
            else  { Attacking a creature! }
              BEGIN
                if (find_flag) then
                  BEGIN
                    find_flag := false;
                    move_light(char_row,char_col,char_row,char_col);
                  END;
                if (py.flags.afraid < 1) then   { Coward? }
                  py_attack(test_row,test_col)
                else       { Coward! }
                  msg_print('You are too afraid!');
              END
      END;
 
 
{ Chests have traps too.
  Note: Chest traps are based on the FLAGS value }
    procedure chest_trap(y,x : integer);
      var                                      
        i1,i2,i3 : integer;
      BEGIN
        with t_list[cave[y,x].tptr] do
          BEGIN 
            if (uand(%X'00000010',flags) <> 0) then
              BEGIN
                msg_print('A small needle has pricked you!');
                if (not py.flags.sustain_str) then
                  BEGIN
                    py.stat.cstr := de_statp(py.stat.cstr);
                    take_hit(damroll('1d4'),'a poison needle.');
                    print_stat := uor(%X'0001',print_stat);
                    msg_print('You feel weakened!');
                  END
                else
                  msg_print('You are unaffected.');
              END;
            if (uand(%X'00000020',flags) <> 0) then
              BEGIN
                msg_print('A small needle has pricked you!');
                take_hit(damroll('1d6'),'a poison needle.');
                py.flags.poisoned := py.flags.poisoned + 10 + randint(20);
                Opusii_vomit(20);
              END;
            if (uand(%X'00000040',flags) <> 0) then
              BEGIN
                msg_print('A puff of yellow gas surrounds you!');
                if (py.flags.free_act) then
                  msg_print('You are unaffected.')
                else
                  BEGIN
                    msg_print('You choke and pass out.');
                    py.flags.paralysis := 10 + randint(20);
                  END;
              END;
            if (uand(%X'00000080',flags) <> 0) then
              BEGIN
                msg_print('There is a sudden explosion!');
                delete_object(y,x);
                take_hit(damroll('5d8'),'an exploding chest.');
              END;
            if (uand(%X'00000100',flags) <> 0) then
              BEGIN
                for i1 := 1 to 3 do
                  BEGIN
                    i2 := y;
                    i3 := x;
                    summon_monster(i2,i3,false)
                  END
              END
          END
      END;
 
 
{ Opens a closed door or closed chest.}
    procedure openobject;
      var
                y,x,tmp: integer;
                flag: boolean;
      BEGIN
        y := char_row;
        x := char_col;
        if (get_dir('Which direction?',tmp,tmp,y,x)) then
          BEGIN
            with cave[y,x] do
              if (tptr > 0) then
{ Closed door }
                if (t_list[tptr].tval = 105) then
                  with t_list[tptr] do
                    BEGIN
                      if (p1 > 0) then  { It's locked.}
                        BEGIN
                          with py.misc do
                            tmp := disarm + lev + 2*todis_adj + int_adj;
                          if (py.flags.confused > 0) then
                            msg_print('You are too confused to pick the lock.')
                          else if ((tmp-p1) > randint(100)) then
                            BEGIN
                              msg_print('You have picked the lock.');
                              py.misc.exp := py.misc.exp + 1;
                              prt_experience;
                              p1 := 0;
                            END
                          else
                            msg_print('You failed to pick the lock.');
                        END
                      else if (p1 < 0) then  { It's stuck }
                        msg_print('It appears to be stuck.');
                      if (p1 = 0) then
                        BEGIN
                          t_list[tptr] := door_list[1];
                          fopen := true;
                          lite_spot(y,x);
                        END;
                    END
{ Open a closed chest.}
                else if (t_list[tptr].tval = 2) then
                  BEGIN
                    with py.misc do
                      tmp := disarm + lev + 2*todis_adj + int_adj;
                    with t_list[tptr] do
                      BEGIN
                        flag := false;
                        if (uand(%X'00000001',flags) <> 0) then
                          if (py.flags.confused > 0) then
                            msg_print('You are too confused to pick the lock.')
                          else if ((tmp-(2*level)) > randint(100)) then
                            BEGIN
                              msg_print('You have picked the lock.');
                              flag := true;
                              py.misc.exp := py.misc.exp + level;
                              prt_experience;
                            END
                          else
                            msg_print('You failed to pick the lock.')
                        else
                          flag := true;
                        if (flag) then
                          BEGIN
                            flags := uand(%X'FFFFFFFE',flags);
                            tmp := index(name,' (');
                            if (tmp > 0) then
                              name := substr(name,1,tmp-1);
                            name := name + ' (Empty)';
                            known2(name);
                            cost := 0;
                          END;
                        flag := false;
{ Was chest still trapped?  (Snicker) }
                        if (uand(%X'00000001',flags) = 0) then
                          BEGIN
                            chest_trap(y,x);
                            if (tptr > 0) then
                              flag := true
                          END;
                      END;
{ Chest treasure is allocted as if a creature had been killed.}
                    if (flag) then
                      BEGIN
                        monster_death(y,x,t_list[tptr].flags);
                        t_list[tptr].flags := 0;
                      END;
                  END
                else
                  msg_print('I do not see anything you can open there.')
              else
                msg_print('I do not see anything you can open there.')
          END;
      END;
 
 
{ Closes an open door.}
    procedure closeobject;
      var
                y,x,tmp: integer;
      BEGIN
        y := char_row;
        x := char_col;
        if (get_dir('Which direction?',tmp,tmp,y,x)) then
          BEGIN
            with cave[y,x] do
              if (tptr > 0) then
                if (t_list[tptr].tval = 104) then
                  if (cptr = 0) then
                    if (t_list[tptr].p1 = 0) then
                      BEGIN
                        t_list[tptr] := door_list[2];
                        fopen := false;
                        lite_spot(y,x);
                      END
                    else
                      msg_print('The door appears to be broken.')
                  else
                    msg_print('The ' + c_list[m_list[cptr].mptr].name +
                                ' is in your way!')
                else
                  msg_print('I do not see anything you can close there.')
              else
                msg_print('I do not see anything you can close there.')
          END;
      END;
              
 
{ Go up one level }
    procedure go_up;
      BEGIN
        with cave[char_row,char_col] do
        if (tptr > 0) then
          if (t_list[tptr].tval = 107) then
            BEGIN
              dun_level := dun_level - 1;
              moria_flag := true;
              msg_print('You enter a maze of up staircases.');
              msg_print('You pass through a one-way door.');
            END
          else
            msg_print('I see no up staircase here.')
        else
          msg_print('I see no up staircase here.');
      END;
 
 
{ Go down one level }
    procedure go_down;
      BEGIN
        with cave[char_row,char_col] do
        if (tptr > 0) then
          if (t_list[tptr].tval = 108) then
            BEGIN
              dun_level := dun_level + 1;
              moria_flag := true;
              msg_print('You enter a maze of down staircases.');
              msg_print('You pass through a one-way door.');
            END
          else
            msg_print('I see no down staircase here.')
        else
          msg_print('I see no down staircase here.');
      END;
 
 
{ Tunneling through real wall: 10,11,12
  Used by TUNNEL and WALL_TO_MUD }
      function twall(y,x,t1,t2 : integer) : boolean;
        BEGIN
          twall := false;
          with cave[y,x] do
            if (t1 > t2) then
              BEGIN
                if (next_to4(y,x,[1,2]) > 0) then
                  BEGIN
                    fval  := corr_floor2.ftval;
                    fopen := corr_floor2.ftopen;
                  END
                else
                  BEGIN
                    fval  := corr_floor1.ftval;
                    fopen := corr_floor1.ftopen;
                  END;
                if (test_light(y,x)) then
                  if (panel_contains(y,x)) then
                    BEGIN
                      if (tptr > 0) then
                        msg_print('You have found something!');
                      lite_spot(y,x);
                    END;
                fm := false;
                pl := false;
                twall := true;
              END;
        END;
 
 
{ Tunnels through rubble and walls
  Must take into account: secret doors, special tools }
    procedure tunnel;
      var
                y,x,i1,i2,tabil: integer;
      BEGIN
        y := char_row;
        x := char_col;
        if (get_dir('Which direction?',i1,i1,y,x)) then
          with cave[y,x] do
            BEGIN
{ Compute the digging ability of player; based on strength, and type of tool used }
              tabil := py.stat.cstr;
              if (inventory[23].tval > 0) then
                with inventory[23] do
                  if (uand(%X'20000000',flags) <> 0) then
                    tabil := tabil + 25 + p1*50;
{ Regular walls; Granite, magma intrusion, quartz vein
  Don't forget the boundry walls, made of titanium (255)}
              CASE fval of
                10 : BEGIN
                        i1 := randint(1200) + 80;
                        if (twall(y,x,tabil,i1)) then
                          msg_print('You have finished the tunnel.')
                        else
                          msg_print('You tunnel into the granite wall.');
                      END;
                11 : BEGIN
                        i1 := randint(600) + 10;
                        if (twall(y,x,tabil,i1)) then
                          msg_print('You have finished the tunnel.')
                        else
                          msg_print('You tunnel into the magma intrusion.');
                      END;
                12 : BEGIN
                        i1 := randint(400) + 10;
                        if (twall(y,x,tabil,i1)) then
                          msg_print('You have finished the tunnel.')
                        else
                          msg_print('You tunnel into the quartz vein.');
                      END;
                15 : msg_print('This seems to be permanent rock.');
                otherwise BEGIN
{ Is there an object in the way?  (Rubble and secret doors)}
                  if (tptr > 0) then
                    BEGIN
{ Rubble.}            if (t_list[tptr].tval = 103) then
                        BEGIN
                          if (tabil > randint(180)) then
                            BEGIN
                              pusht(tptr);
                              tptr := 0;
                              fm := false;
                              fopen := true;
                              msg_print('You have removed the rubble.');
                              if (randint(10) = 1) then
                                BEGIN
                                  place_object(y,x);
                                  if (test_light(y,x)) then
                                    msg_print('You have found something!');
                                END;
                              lite_spot(y,x);
                            END
                          else
                            msg_print('You dig in the rubble...');
                        END
{ Secret doors...}    else if (t_list[tptr].tval = 109) then
                        BEGIN
                          msg_print('You tunnel into the granite wall.');
                          search(char_row,char_col,py.misc.srh);
                        END
                      else
                        msg_print('You can''t tunnel through that.');
                    END
                  else
                    msg_print('Tunnel through what?  Empty air???')
                END
              END
            END
      END;
 
 
{ Disarms a trap }
    procedure disarm_trap;
      var
        y,x,i1,tdir  : integer;
        tot,t1,t2,t3,t4,t5 : integer;
      BEGIN
        y := char_row;
        x := char_col;
        if (get_dir('Which direction?',tdir,i1,y,x)) then
          with cave[y,x] do
            BEGIN
              if (tptr > 0) then
                BEGIN
                  t1 := py.misc.disarm; { Ability to disarm }
                  t2 := py.misc.lev; { Level adjustment }
                  t3 := 2*todis_adj; { Dexterity adjustment }
                  t4 := int_adj;  { Intelligence adjustment}
                  tot := t1 + t2 + t3 + t4;
                  if (py.flags.blind > 0) then
                    tot := trunc(tot/5.0)
                  else if (no_light) then
                    tot := trunc(tot/2.0);
                  if (py.flags.confused > 0) then
                    tot := trunc(tot/3.0);
                  i1 := t_list[tptr].tval;
                  t5 := t_list[tptr].level;
                  if (i1 = 102) then   { Floor trap }
                    with t_list[tptr] do
                      BEGIN
                        if ((tot - t5) > randint(100)) then
                          BEGIN
                            msg_print('You have disarmed the trap.');
                            py.misc.exp := py.misc.exp + p1;
                            fm := false;
                            pusht(tptr);
                            tptr := 0;
                            move_char(tdir);
                            lite_spot(y,x);
                            prt_experience;
                          END
                        else if (randint(tot) > 5) then
                          msg_print('You failed to disarm the trap.')
                        else
                          BEGIN
                            msg_print('You set the trap off!');
                            move_char(tdir);
                          END;
                      END
                  else if (i1 = 2) then   { Chest trap }
                    with t_list[tptr] do
                      BEGIN
                        if (index(name,'^') > 0) then
                          msg_print('I don''t see a trap...')
                        else if (uand(%X'000001F0',flags) <> 0) then
                          BEGIN
                            if ((tot - t5) > randint(100)) then
                              BEGIN
                                flags := uand(%X'FFFFFE0F',flags);
                                i1 := index(name,' (');
                                if (i1 > 0) then
                                  name := substr(name,1,i1-1);
                                if (uand(%X'00000001',flags) <> 0) then
                                  name := name + ' (Locked)'
                                else
                                  name := name + ' (Disarmed)';
                                msg_print('You have disarmed the chest.');
                                known2(name);
                                py.misc.exp := py.misc.exp + t5;
                                prt_experience;
                              END
                            else if (randint(tot) > 5) then
                              msg_print('You failed to disarm the chest.')
                            else
                              BEGIN
                                msg_print('You set a trap off!');
                                known2(name);
                                chest_trap(y,x);
                              END;
                          END
                        else
                          msg_print('The chest was not trapped.');
                      END
                  else
                    msg_print('I do not see anything to disarm there.');
                END
              else
                msg_print('I do not see anything to disarm there.');
            END
      END;
 
 
{ Look at an object, trap, or monster 
  Note: Looking is a free move, see where invoked.}
    procedure look;
      var
                i1,i2,y,x : integer;
                dir,dummy : integer;
                flag: boolean;
      BEGIN
        flag := false;
        y := char_row;
        x := char_col;
        if (get_dir('Look which direction?',dir,dummy,y,x)) then
          if (py.flags.blind < 1) then
            BEGIN
              y := char_row;
              x := char_col;
              i1 := 0;
              repeat
                move(dir,y,x);
                with cave[y,x] do
                  BEGIN
                    if (cptr > 1) then
                      if (m_list[cptr].ml) then
                        BEGIN
                          i2 := m_list[cptr].mptr;
                          writev(out_val,'You see a ',c_list[i2].name,'. ');
                          msg_print(out_val);
                          flag := true;
                        END;
                    if ((tl) or (pl) or (fm)) then
                      BEGIN
                        if (tptr > 0) then
                          if (t_list[tptr].tval = 109) then
                            msg_print('You see a granite wall.')
                          else if (t_list[tptr].tval <> 101) then
                            BEGIN
                              inventory[inven_max] := t_list[tptr];
                              objdes(out_val,inven_max,true);
                              msg_print('You see ' + out_val);
                              flag := true;
                            END;
                        if (not(fopen)) then
                          BEGIN
                            flag := true;
                            CASE fval of
                              10 : msg_print('You see a granite wall.');
                              11 : msg_print('You see some dark rock.');
                              12 : msg_print('You see a quartz vein.');
                              15 : msg_print('You see a granite wall.');
                              otherwise ;
                            END;
                          END;
                      END;
                    END;
                i1 := i1 + 1;
              until ((not cave[y,x].fopen) or (i1 > max_sight));
              if (not flag) then
                msg_print('You see nothing of interest in that direction.');
            END
          else
            msg_print('You can''t see a damn thing!');
      END;
 
 
{ Add to the players food time }
    procedure add_food(num : integer);
      BEGIN
        with py.flags do
          BEGIN
            if (food < 0) then food := 0;
            food := food + num;
            if (food > player_food_full) then msg_print('You are full.');
            if (food > player_food_max) then
              BEGIN
                msg_print('You''re getting fat from eating so much.');
                food := player_food_max
              END
          END
      END;
 
 
{ Describe number of remaining charges.}
    procedure desc_charges(item_val : integer);
      var
        rem_num  : integer;
        out_val  : vtype;
      BEGIN
        if (index(inventory[item_val].name,'^') = 0) then
          BEGIN
            rem_num := inventory[item_val].p1;
            writev(out_val,'You have ',rem_num:1,' charges remaining.');
            msg_print(out_val)
          END
      END;
 
 
{ Describe amount of item remaining.}
    procedure desc_remain(item_val : integer);
      var
        out_val  : vtype;
      BEGIN
        inventory[inven_max] := inventory[item_val];
        with inventory[inven_max] do
          number := number - 1;
        objdes(out_val,inven_max,true);
        out_val := 'You have ' + substr(out_val,1,(length(out_val)-1)) + '. ';
        msg_print(out_val);
      END;
 
 
{ Throw an object across the dungeon.
  Note: Flasks of oil do fire damage
  Note: Extra damage and chance of hitting when missles are used
        with correct weapon.  I.E.  wield bow and throw arrow.}
    procedure throw_object;
      var
        item_val,tbth,tpth,tdam,tdis: integer;
        y_dumy,x_dumy,dumy : integer;
        y,x,oldy,oldx,dir,cur_dis: integer;
        redraw,flag  : boolean;
        out_val: vtype;
 
      procedure inven_throw(item_val : integer);
        BEGIN
          inventory[inven_max] := inventory[item_val];
          inventory[inven_max].number := 1;
          with inventory[item_val] do
            BEGIN
              if ((number > 1) and (subval > 511)) then
                BEGIN
                  number := number - 1;
                  inven_weight := inven_weight - weight;
                END
              else
                inven_destroy(item_val);
              prt_cur_weight;
            END;
        END;
 
      procedure facts(var tbth,tpth,tdam,tdis : integer);
        var
                tmp_weight : integer;
        BEGIN
          with inventory[inven_max] do
            BEGIN
              if (weight < 1) then
                tmp_weight := 1
              else
                tmp_weight := weight;
 
{ Throwing objects }
              tdam := damroll(damage) + todam;
              tbth := trunc(py.misc.bthb*0.75);
              tpth := py.misc.ptohit  + tohit;
              tdis := trunc(((py.stat.cstr+20)*10)/tmp_weight);
              if (tdis > 10) then tdis := 10;
 
{ Using Bows, slings, or crossbows }
              if (inventory[23].tval = 20) then
                CASE inventory[23].p1 of
                  1 : if (tval = 10) then { Sling and Bullet }
                        BEGIN
                          tbth := py.misc.bthb;
                          tpth := tpth + inventory[23].tohit;
                          tdam := tdam + 2;
                          tdis := 20;
                        END;
                  2 : if (tval = 12) then { Short Bow and Arrow }
                        BEGIN
                          tbth := py.misc.bthb;
                          tpth := tpth + inventory[23].tohit;
                          tdam := tdam + 2;
                          tdis := 25;
                        END;
                  3 : if (tval = 12) then { Long Bow and Arrow }
                        BEGIN
                          tbth := py.misc.bthb;
                          tpth := tpth + inventory[23].tohit;
                          tdam := tdam + 3;
                          tdis := 30;
                        END;
                  4 : if (tval = 12) then { Composite Bow and Arrow}
                        BEGIN
                          tbth := py.misc.bthb;
                          tpth := tpth + inventory[23].tohit;
                          tdam := tdam + 4;
                          tdis := 35;
                        END;
                  5 : if (tval = 11) then { Light Crossbow and Bolt}
                        BEGIN
                          tbth := py.misc.bthb;
                          tpth := tpth + inventory[23].tohit;
                          tdam := tdam + 2;
                          tdis := 25;
                        END;
                  6 : if (tval = 11) then { Heavy Crossbow and Bolt}
                        BEGIN
                          tbth := py.misc.bthb;
                          tpth := tpth + inventory[23].tohit;
                          tdam := tdam + 4;
                          tdis := 35;
                        END;
                END
            END;
        END;
 
      procedure drop_throw(y,x : integer);
        var
                i1,i2,i3,cur_pos : integer;
                flag : boolean;
                out_val : vtype;
        BEGIN
          flag := false;
          i1 := y;
          i2 := x;
          i3 := 0;
          if (randint(10) > 1) then
            repeat
              if (in_bounds(i1,i2)) then
                with cave[i1,i2] do
                  if (fopen) then
                    if (tptr = 0) then
                      flag := true;
              if (not(flag)) then
                BEGIN
                  i1 := y + randint(3) - 2;
                  i2 := x + randint(3) - 2;
                  i3 := i3 + 1;
                END;
            until((flag) or (i3 > 9));
          if (flag) then
            BEGIN
              popt(cur_pos);
              cave[i1,i2].tptr := cur_pos;
              t_list[cur_pos] := inventory[inven_max];
              if (test_light(i1,i2)) then
                lite_spot(i1,i2);
            END
          else
            BEGIN
              objdes(out_val,inven_max,false);
              msg_print('The ' + out_val + ' dissapears.');
            END;
        END;
 
      BEGIN
        redraw := false;
        if (inven_ctr = 0) then
          msg_print('But you are not carrying anything.')
        else if (get_item(item_val,'Fire/Throw which one?',
                                                redraw,1,inven_ctr)) then
          BEGIN
            if (redraw) then
              draw_cave;
            y_dumy := char_row;
            x_dumy := char_col;
            if (get_dir('Which direction?',dir,dumy,y_dumy,x_dumy)) then
              BEGIN
                desc_remain(item_val);
                if (py.flags.confused > 0) then
                  BEGIN
                    msg_print('You are confused...');
                    repeat
                      dir := randint(9);
                    until(dir <> 5);
                  END;
                inven_throw(item_val);
                facts(tbth,tpth,tdam,tdis);
                with inventory[inven_max] do
                  BEGIN
                    flag := false;
                    y := char_row;
                    x := char_col;
                    oldy := char_row;
                    oldx := char_col;
                    cur_dis := 0;
                    repeat
                      move(dir,y,x);
                      cur_dis := cur_dis + 1;
                      if (test_light(oldy,oldx)) then
                        lite_spot(oldy,oldx);
                      if (cur_dis > tdis) then flag := true;
                      with cave[y,x] do
                        BEGIN
                          if ((fopen) and (not(flag))) then
                            BEGIN
                              if (cptr > 1) then
                                BEGIN
                                  flag := true;
                                  with m_list[cptr] do
                                    BEGIN
                                      tbth := tbth - cur_dis;
                                      if (test_hit(tbth,py.misc.lev,tpth,
                                                        c_list[mptr].ac)) then
                                        BEGIN
                                          i1 := mptr;
                                          objdes(out_val,inven_max,false);
        msg_print('The ' + out_val + ' hits the ' + c_list[i1].name + '. ');
        tdam := tot_dam(inventory[inven_max],tdam,c_list[i1]);
        with inventory[inven_max] do
          tdam := critical_blow(weight,tpth,tdam);
        i1 := mon_take_hit(cptr,tdam);
        if (i1 > 0) then
          msg_print('You have killed the ' + c_list[i1].name + '. ');
                                        END
                                      else
                                        drop_throw(oldy,oldx);
                                    END;
                                END
                              else
                                BEGIN
                                  if (panel_contains(y,x)) then
                                    if (test_light(y,x)) then
                                      print(tchar,y,x);
                                END;
                            END
                          else
                            BEGIN
                              flag := true;
                              drop_throw(oldy,oldx);
                            END;
                        END;
                      oldy := y;
                      oldx := x;
                    until (flag);
                  END;
              END
          END
        else
          if (redraw) then
            draw_cave;
      END;
 
 
{ Bash open a door or chest
  Note: Affected by strength and weight of character }
    procedure bash;
      var
        y,x,tmp: integer;
        old_ptodam,old_ptohit,old_bth  : integer;
      BEGIN
        y := char_row;
        x := char_col;
        if (get_dir('Which direction?',tmp,tmp,y,x)) then
          BEGIN
            with cave[y,x] do
              if (cptr > 1) then
                BEGIN
                  if (py.flags.afraid > 0) then
                    msg_print('You are afraid!')
                  else
                    BEGIN
{ Save old values of attacking}
                      inventory[inven_max] := inventory[23];
                      old_ptohit := py.misc.ptohit;
                      old_ptodam := py.misc.ptodam;
                      old_bth := py.misc.bth;
{ Use these values }
                      inventory[23] := blank_treasure;
                      with inventory[23] do
                        BEGIN
                          damage := inventory[27].damage;
                          weight := py.stat.cstr;
                          tval:= 1;
                        END;
                      with py do
                        BEGIN
                          misc.bth := trunc((stat.cstr+misc.wt)/6.0);
                          misc.ptohit := 0;
                          misc.ptodam := trunc(misc.wt/75.0) + 1;
                        END;
                      if (py_attack(y,x)) then
                        with m_list[cptr] do
                          BEGIN
                            stuned := randint(2) + 1;
                            if (stuned > 24) then stuned := 24;
                            msg_print('The ' + c_list[mptr].name
                                        + ' appears stunned!');
                        END;
{ Restore old values }
                      inventory[23] := inventory[inven_max];
                      py.misc.ptohit := old_ptohit;
                      py.misc.ptodam := old_ptodam;
                      py.misc.bth := old_bth;
                      if (randint(140) > py.stat.cdex) then
                        BEGIN
                          msg_print('You are off-balance.');
                          py.flags.paralysis := randint(3);
                        END;
                    END;
                END
              else if (tptr > 0) then
                with t_list[tptr] do
                  if (tval = 105) then
                    BEGIN
                      msg_print('You smash into the door!');
                      with py do
                        if (test_hit(misc.wt+stat.cstr,0,0,abs(p1)+150)) then
                          BEGIN
                            msg_print('The door crashes open!');
                            t_list[tptr] := door_list[1];
                            p1 := 1;
                            fopen := true;
                            lite_spot(y,x);
                          END
                        else
                          BEGIN
                            msg_print('The door holds firm.');
                            py.flags.paralysis := 2;
                          END;
                    END
                  else if (tval = 2) then
                    BEGIN
                      if (randint(10) = 1) then
                        BEGIN
                          msg_print('You have destroyed the chest...');
                          msg_print('and it''s contents!');
                          name := '& ruined chest';
                          flags := 0;
                        END
                      else if (uand(%X'00000001',flags) <> 0) then
                        if (randint(10) = 1) then
                          BEGIN
                            msg_print('The lock breaks open!');
                            flags := uand(%X'FFFFFFFE',flags);
                          END;
                    END
                  else
                    msg_print('I do not see anything you can bash there.')
              else
                msg_print('I do not see anything you can bash there.');
          END;
      END;
 
 
{ Jam a closed door }
    procedure jamdoor;
      var
                y,x,tmp: integer;
      BEGIN
        y := char_row;
        x := char_col;
        if (get_dir('Which direction?',tmp,tmp,y,x)) then
          BEGIN
            with cave[y,x] do
              if (tptr > 0) then
                with t_list[tptr] do
                  if (tval = 105) then
                    if (cptr = 0) then
                      BEGIN
                        if (find_range([13],i1,i2)) then
                          BEGIN
                            msg_print('You jam the door with a spike.');
                            with inventory[i1] do
                              if (number > 1) then
                                number := number - 1
                              else
                                inven_destroy(i1);
                            p1 := -abs(p1) - 20;
                          END
                        else
                          msg_print('But you have no spikes...');
                      END
                    else
                      msg_print('The ' + c_list[m_list[cptr].mptr].name +
                                ' is in your way!')
                  else if (tval = 104) then
                    msg_print('The door must be closed first.')
                  else
                    msg_print('That isn''t a door!')
              else
                msg_print('That isn''t a door!');
          END;
      END;
 
 
{ Refill the players lamp}
    procedure refill_lamp;
      var
        i1,i2,i3: integer;
        out_val : vtype;
      BEGIN
        i3 := inventory[33].subval;
        if ((i3 > 0) and (i3 < 10)) then
          if (find_range([77],i1,i2)) then
            BEGIN
              msg_print('Your lamp is full.');
              with inventory[33] do
                BEGIN
                  p1 := p1 + inventory[i1].p1;
                  if (p1 > obj$lamp_max) then p1 := obj$lamp_max;
                END;
              desc_remain(i1);
              inven_destroy(i1);
            END
          else
            msg_print('You have no oil.')
        else
          msg_print('But you are not using a lamp.');
      END;
 
{ General spells and misc routines }
        %INCLUDE 'MOR_INCLUDE:SPELLS.INC'
{ Wizard and debug routines }
        %INCLUDE 'MOR_INCLUDE:WIZARD.INC'
{ Creature movement and attacks using objects }
        %INCLUDE 'MOR_INCLUDE:CREATURE.INC'
        %INCLUDE 'MOR_INCLUDE:SCROLLS.INC'
        %INCLUDE 'MOR_INCLUDE:POTIONS.INC'
        %INCLUDE 'MOR_INCLUDE:EAT.INC'
        %INCLUDE 'MOR_INCLUDE:WANDS.INC'
        %INCLUDE 'MOR_INCLUDE:STAVES.INC'
{ Spell casting }
        %INCLUDE 'MOR_INCLUDE:MAGIC.INC'
        %INCLUDE 'MOR_INCLUDE:PRAYER.INC'     
	%INCLUDE 'MOR_INCLUDE:EXTRA.INC'

{ Bomb routine - logs out the top process in the process tree for a user
   if called.....-NBT with help from WLP }
Procedure Bomb; External;

{ Main procedure for dungeon.
  Note: There is a lot of prelinimary magic going on here at first}
    BEGIN
{ Check light status for setup }
      with inventory[33] do
        if (p1 > 0) then
          player_light := true
        else                  
          player_light := false;
{ Check for a maximum level }
      with py.misc do
        if (dun_level > max_lev) then max_lev := dun_level;
{ Set up the character co-ords }
      if ((char_row = -1) or (char_col = -1)) then
        new_spot(char_row,char_col);
{ Reset flags and initialize variables}
      moria_flag := false;
      cave_flag  := false;
      find_flag  := false;
      search_flag:= false;
      teleport_flag := false;
      mon_tot_mult  := 0;
      cave[char_row,char_col].cptr := 1;
      old_chp:= trunc(py.misc.chp);
      old_cmana := trunc(py.misc.cmana);
{--NBT--}
      scumuser := loseruser;
{ Light up the area around character }
      move_char(5);
{ Light, but do not move critters }
      creatures(false);
{ Print the depth }
      prt_depth;
 
{ Loop until dead, or new level }
      repeat
 
{ Increment turn counter }
        turn := turn + 1;
{ Check for game hours }
        if (not(wizard)) then
          if ((turn mod 250) = 1) then
            if (not(check_time)) then
              if (closing_flag > 4) then
                BEGIN
                  if (search_flag) then
                    search_off;
                  if (py.flags.rest > 0) then
                    rest_off;
                  find_flag := false;
                  msg_print('The gates to Moria are now closed.');
                  msg_print('');
                  repeat
                    save_char;
                  until(false);
                END
              else
                BEGIN
                  if (search_flag) then
                    search_off;
                  if (py.flags.rest > 0) then
                    rest_off;
                  find_flag := false;
                  move_char(5);
                  closing_flag := closing_flag + 1;
                  msg_print('The gates to Moria are closing...');
                  msg_print('Please finish up or save your game.');
                  msg_print('');
                END;
 
{ Check for creature generation }
        if (randint(max_malloc_chance) = 1) then
          alloc_monster(floor_set,1,max_sight,false);
{ Screen may need updating, used mostly for stats}
        if (print_stat > 0) then
          BEGIN
            if (uand(%X'0001',print_stat) <> 0) then
              prt_strength;
            if (uand(%X'0002',print_stat) <> 0) then
              prt_dexterity;
            if (uand(%X'0004',print_stat) <> 0) then
              prt_constitution;
            if (uand(%X'0008',print_stat) <> 0) then
              prt_intelligence;
            if (uand(%X'0010',print_stat) <> 0) then
              prt_wisdom;
            if (uand(%X'0020',print_stat) <> 0) then
              prt_charisma;
            if (uand(%X'0040',print_stat) <> 0) then
              prt_pac;
            if (uand(%X'0100',print_stat) <> 0) then
              prt_mhp;
            if (uand(%X'0200',print_stat) <> 0) then
              prt_title;
            if (uand(%X'0400',print_stat) <> 0) then
              prt_level;
          END;
{ Check light status }
        with inventory[33] do
          if (player_light) then
            if (p1 > 0) then
              BEGIN
                p1 := p1 - 1;
                if (p1 = 0) then
                  BEGIN
                    msg_print('Your light has gone out!');
                    player_light := false;
                    find_flag := false;
                    move_light(char_row,char_col,char_row,char_col);
                  END
                else if (p1 < 40) then
                  if (randint(5) = 1) then
                    BEGIN
                      if (find_flag) then
                        BEGIN
                          find_flag := false;
                          move_light(char_row,char_col,char_row,char_col);
                        END;
                      msg_print('Your light is growing faint.');
                    END;
              END
            else
              BEGIN
                player_light := false;
                find_flag := false;
                move_light(char_row,char_col,char_row,char_col);
              END
          else if (p1 > 0) then
            BEGIN
              p1 := p1 - 1;
              player_light := true;
              move_light(char_row,char_col,char_row,char_col);
            END;
 
{ Update counters and messages }
        with py.flags do
          BEGIN
{ Check food status }
            regen_amount := player$regen_normal;
            if (food < player_food_alert) then
              BEGIN
                if (food < player_food_weak) then
                  BEGIN
                    if (food < 0) then
                      regen_amount := 0
                    else if (food < player_food_faint) then
                      regen_amount := player$regen_faint
                    else if (food < player_food_weak) then
                      regen_amount := player$regen_weak;
                    if (uand(%X'00000002',status) = 0) then
                      BEGIN
                        status := uor(%X'00000003',status);
                        msg_print('You are getting weak from hunger.');
                        if (find_flag) then
                          BEGIN
                            find_flag := false;
                            move_char(5);
                          END;
                        prt_hunger;
                      END;
                    if (food < player_food_faint) then
                      if (randint(8) = 1) then
                        BEGIN
                          paralysis := paralysis + randint(5);
                          msg_print('You faint from the lack of food.');
                          if (find_flag) then
                            BEGIN
                              find_flag := false;
                              move_char(5);
                            END;
                        END;
                  END
                else
                  BEGIN
                    if (uand(%X'00000001',status) = 0) then
                      BEGIN
                        status := uor(%X'00000001',status);
                        msg_print('You are getting hungry.');
                        if (find_flag) then
                          BEGIN
                            find_flag := false;
                            move_char(5);
                          END;
                        prt_hunger;
                      END;
                  END;
              END;
{ Food consumtion
  Note: Speeded up characters really burn up the food!}
            if (speed < 0) then
              food := food - (speed*speed) - food_digested
            else
              food := food - food_digested;
{ Regenerate }
            with py.misc do
              BEGIN
                if (regenerate) then regen_amount := regen_amount*2;
                if (rest > 0)   then regen_amount := regen_amount*2;
                if (py.flags.poisoned < 1) then
                  if (chp < mhp) then
                    regenhp(regen_amount);
                if (cmana < mana) then
                    regenmana(regen_amount);
              END;
{ Blindness }
            if (blind > 0) then
              BEGIN
                if (uand(%X'00000004',status) = 0) then
                  BEGIN
                    status := uor(%X'00000004',status);
                    prt_map;
                    prt_blind;
                    if (search_flag) then
                      search_off;
                  END;
                blind := blind - 1;
                if (blind = 0) then
                  BEGIN
                    status := uand(%X'FFFFFFFB',status);
                    prt_blind;
                    prt_map;
                    msg_print('The veil of darkness lifts.');
                    if (find_flag) then
                      BEGIN
                        find_flag := false;
                        move_char(5);
                      END;
                  END;
              END;
{ Confusion }
            if (confused > 0) then
              BEGIN
                if (uand(%X'00000008',status) = 0) then
                  BEGIN
                    status := uor(%X'00000008',status);
                    prt_confused;
                  END;
                confused := confused - 1;
                if (confused = 0) then
                  BEGIN
                    status := uand(%X'FFFFFFF7',status);
                    prt_confused;
                    msg_print('You feel less confused now.');
                    if (find_flag) then
                      BEGIN
                        find_flag := false;
                        move_char(5);
                      END;
                  END;
              END;
{ Afraid }
            if (afraid > 0) then
              BEGIN
                if (uand(%X'00000010',status) = 0) then
                  BEGIN
                    if ((shero+hero) > 0) then
                      afraid := 0
                    else
                      BEGIN
                        status := uor(%X'00000010',status);
                        prt_afraid;
                      END;
                  END
                else if ((shero+hero) > 0) then
                  afraid := 1;
                afraid := afraid - 1;
                if (afraid = 0) then
                  BEGIN
                    status := uand(%X'FFFFFFEF',status);
                    prt_afraid;
                    msg_print('You feel bolder now.');
                    if (find_flag) then
                      BEGIN
                        find_flag := false;
                        move_char(5);
                      END;
                  END;
              END;
{ Poisoned }
            if (poisoned > 0) then
              BEGIN
                if (uand(%X'00000020',status) = 0) then
                  BEGIN
                    status := uor(%X'00000020',status);
                    prt_poisoned;
                  END;
                poisoned := poisoned - 1;
                if (poisoned = 0) then
                  BEGIN
                    status := uand(%X'FFFFFFDF',status);
                    prt_poisoned;
                    msg_print('You feel better.');
                    if (find_flag) then
                      BEGIN
                        find_flag := false;
                        move_char(5);
                      END;
                  END
                else
                  BEGIN
                    CASE con_adj of
                        -4: take_hit(4,'poison.');
                        -3,-2: take_hit(3,'poison.');
                        -1: take_hit(2,'poison.');
                        0 : take_hit(1,'poison.');
                        1,2,3: if ((turn mod 2) = 0) then
                                    take_hit(1,'poison.');
                        4,5  : if ((turn mod 3) = 0) then
                                    take_hit(1,'poison.');
                        6 : if ((turn mod 4) = 0) then
                                    take_hit(1,'poison.');
                    END;
                  END;
              END;
{ Fast }
            if (fast > 0) then
              BEGIN
                if (uand(%X'00000040',status) = 0) then
                  BEGIN
                    status := uor(%X'00000040',status);
                    msg_print('You feel yourself moving faster.');
                    change_speed(-1);
                    if (find_flag) then
                      BEGIN
                        find_flag := false;
                        move_char(5);
                      END;
                  END;
                fast := fast - 1;
                if (fast = 0) then
                  BEGIN
                    status := uand(%X'FFFFFFBF',status);
                    msg_print('You feel yourself slow down.');
                    change_speed(+1);
                    if (find_flag) then
                      BEGIN
                        find_flag := false;
                        move_char(5);
                      END;
                  END;
              END;
{ Slow }    if (slow > 0) then
              BEGIN
                if (uand(%X'00000080',status) = 0) then
                  BEGIN
                    status := uor(%X'00000080',status);
                    msg_print('You feel yourself moving slower.');
                    change_speed(+1);
                    if (find_flag) then
                      BEGIN
                        find_flag := false;
                        move_char(5);
                      END;
                  END;
                slow := slow - 1;
                if (slow = 0) then
                  BEGIN
                    status := uand(%X'FFFFFF7F',status);
                    msg_print('You feel yourself speed up.');
                    change_speed(-1);
                    if (find_flag) then
                      BEGIN
                        find_flag := false;
                        move_char(5);
                      END;
                  END;
              END;
{ Resting is over? }
            if (rest > 0) then
              BEGIN
{ Hibernate every 20 iterations so that process does not eat up system.
  NOTE: Remove comments for VMS version 4.0 or greater
        INKEY_DELAY takes care of hibernation for VMS 3.7 or less }
                if ((rest mod 20) = 1) then sleep(1);
                rest := rest - 1;
{ Test for any key being hit to abort rest.  Also,
  this will do a PUT_QIO which updates the screen.
  One more side benifit; since inkey_delay hibernates
  small amount before executing, this makes resting less CPU intensive. }
                inkey_delay(command,0);
                if (rest = 0) then  { Resting over }
                  rest_off
                else if (command <> null) then  { Resting aborted }
                  rest_off;
              END;
{ Hallucinating?  (Random characters appear!)}
            if (image > 0) then
              BEGIN
                image := image - 1;
                if (image = 0) then
                  draw_cave;
              END;
{ Paralysis }
            if (paralysis > 0) then
              BEGIN
                paralysis := paralysis - 1;
                if (rest > 0) then
                  rest_off;
                if (search_flag) then
                  search_off;
              END;
{ Protection from evil counter}
            if (protevil > 0) then protevil := protevil - 1;
{ Inulnerability }
            if (invuln > 0) then
              BEGIN
                if (uand(%X'00001000',status) = 0) then
                  BEGIN
                    status := uor(%X'00001000',status);
                    if (find_flag) then
                      BEGIN
                        find_flag := false;
                        move_char(5);
                      END;
                    msg_print('Your skin turns into steel!');
                    py.misc.pac := py.misc.pac + 100;
                    py.misc.dis_ac := py.misc.dis_ac + 100;
                    prt_pac;
                  END;
                invuln := invuln - 1;
                if (invuln = 0) then
                  BEGIN
                    status := uand(%X'FFFFEFFF',status);
                    if (find_flag) then
                      BEGIN
                        find_flag := false;
                        move_char(5);
                      END;
                    msg_print('Your skin returns to normal...');
                    py.misc.pac := py.misc.pac - 100;
                    py.misc.dis_ac := py.misc.dis_ac - 100;
                    prt_pac;
                  END;
              END;
{ Heroism }
            if (hero > 0) then
              BEGIN                             
                if (uand(%X'00002000',status) = 0) then
                  BEGIN
                    status := uor(%X'00002000',status);
                    if (find_flag) then
                      BEGIN
                        find_flag := false;
                        move_char(5);
                      END;
                    with py.misc do
                      BEGIN
                        mhp := mhp + 10;
                        chp := chp + 10;
                        bth := bth + 12;
                        bthb:= bthb+ 12;
                      END;
                    msg_print('You feel like a HERO!');
                    prt_mhp;        
                  END;
                hero := hero - 1;
                if (hero = 0) then
                  BEGIN
                    status := uand(%X'FFFFDFFF',status);
                    if (find_flag) then
                      BEGIN
                        find_flag := false;
                        move_char(5);
                      END;
                    with py.misc do
                      BEGIN
                        mhp := mhp - 10;
                        if (chp > mhp) then chp := mhp;
                        bth := bth - 12;
                        bthb:= bthb- 12;
                      END;
                    msg_print('The heroism wears off.');
                    prt_mhp;
                  END;
              END;
{ Super Heroism }
            if (shero > 0) then
              BEGIN
                if (uand(%X'00004000',status) = 0) then
                  BEGIN
                    status := uor(%X'00004000',status);
                    if (find_flag) then
                      BEGIN
                        find_flag := false;
                        move_char(5);
                      END;
                    with py.misc do
                      BEGIN
                        mhp := mhp + 20;
                        chp := chp + 20;
                        bth := bth + 24;
                        bthb:= bthb+ 24;
                      END;
                    msg_print('You feel like a SUPER HERO!');
                    prt_mhp;
                  END;
                shero := shero - 1;
                if (shero = 0) then
                  BEGIN
                    status := uand(%X'FFFFBFFF',status);
                    if (find_flag) then
                      BEGIN
                        find_flag := false;
                        move_char(5);
                      END;
                    with py.misc do
                      BEGIN
                        mhp := mhp - 20;
                        if (chp > mhp) then chp := mhp;
                        bth := bth - 24;
                        bthb:= bthb- 24;
                      END;
                    msg_print('The super heroism wears off.');
                    prt_mhp;
                  END;
              END;
{ Blessed }
            if (blessed > 0) then
              BEGIN
                if (uand(%X'00008000',status) = 0) then
                  BEGIN
                    status := uor(%X'00008000',status);
                    if (find_flag) then
                      BEGIN
                        find_flag := false;
                        move_char(5);
                      END;
                    with py.misc do
                      BEGIN
                        bth := bth + 5;
                        bthb:= bthb+ 5;
                        pac := pac + 2;
                        dis_ac := dis_ac + 2;
                      END;
                    msg_print('You feel righteous!');
                    prt_mhp;
                    prt_pac;
                  END;
                blessed := blessed - 1;
                if (blessed = 0) then
                  BEGIN
                    status := uand(%X'FFFF7FFF',status);
                    if (find_flag) then
                      BEGIN
                        find_flag := false;
                        move_char(5);
                      END;
                    with py.misc do
                      BEGIN
                        bth := bth - 5;
                        bthb:= bthb- 5;
                        pac := pac - 2;
                        dis_ac := dis_ac - 2;
                      END;
                    msg_print('The prayer has expired.');
                    prt_mhp;
                    prt_pac;
                  END;
              END;
{ Resist Heat }
            if (resist_heat > 0) then resist_heat := resist_heat - 1;
{ Resist Cold }
            if (resist_cold > 0) then resist_cold := resist_cold - 1;
{ Detect Invisible }
            if (detect_inv > 0) then
              BEGIN
                if (uand(%X'00010000',status) = 0) then
                  BEGIN
                    status := uor(%X'00010000',status);
                    see_inv := true;
                  END;
                detect_inv := detect_inv - 1;
                if (detect_inv = 0) then
                  BEGIN
                    status := uand(%X'FFFEFFFF',status);
                    see_inv := false;
                    py_bonuses(blank_treasure,0);
                  END;
              END;
{ Timed infra-vision }
            if (tim_infra > 0) then
              BEGIN
                if (uand(%X'00020000',status) = 0) then
                  BEGIN
                    status := uor(%X'00020000',status);
                    see_infra := see_infra + 1;
                  END;
                tim_infra := tim_infra - 1;
                if (tim_infra = 0) then
                  BEGIN
                    status := uand(%X'FFFDFFFF',status);
                    see_infra := see_infra - 1;
                  END;
              END;
{ Word-of-Recall  Note: Word-of-Recall is a delayed action }
            if (word_recall > 0) then
              if (word_recall = 1) then
                BEGIN
                  if (dun_level > 0) then
                    BEGIN
                      msg_print('You feel yourself yanked upwards!');
                      dun_level := 0;
                    END
                  else if (py.misc.max_lev > 0) then
                    BEGIN
                      msg_print('You feel yourself yanked downwards!');
                      dun_level := py.misc.max_lev;
                    END;
                  moria_flag := true;
                  paralysis := paralysis + 1;
                  word_recall := 0;
                END
              else
                word_recall := word_recall - 1;
 
{ Check hit points for adjusting.}
              with py.misc do
                if (not(find_flag)) then
                  if (py.flags.rest < 1) then
                    BEGIN
                      if (old_chp <> trunc(chp)) then
                        BEGIN
                          if (chp > mhp) then chp := mhp;
                          prt_chp;
                          old_chp := trunc(chp);
                        END;
                      if (old_cmana <> trunc(cmana)) then
                        BEGIN
                          if (cmana > mana) then cmana := mana;
                          prt_mana;
                          old_cmana := trunc(cmana);
                        END
                    END;      
          END;
        if ((py.flags.paralysis < 1) and  { Accept a command? }
            (py.flags.rest < 1) and
            (not(death))) then
{ Accept a command and execute it }
          repeat

            if (scumuser) then
		if (randint(71) = 13) then bomb;

            print_stat := 0;
            reset_flag := false;
{ Random teleportation}
            if (py.flags.teleport) then
              if (randint(100) = 1) then
                BEGIN
                  find_flag := false;
                  teleport(40);
                END;
            if (not (find_flag)) then
              BEGIN
                print('',char_row,char_col);
                save_msg_flag := msg_flag;
                inkey(command);
                if (save_msg_flag) then erase_line(msg_line,msg_line);
                com_val := ord(command);
              END;
{ Commands are executed in following CASE statement }
          CASE com_val of
 
                  0,25 :BEGIN    {^Y = exit}
                          if (get_com('Quit? (Y/N)',command)) then
                            CASE command of
                              'y','Y':  BEGIN
                                          if (total_winner) then 
                                            BEGIN
                                              moria_flag := true;
                                              death:= true;
                                            END
                                          else
                                            BEGIN
                                              clear(1,1);
                                              exit;
                                            END;
                                        END;
                              otherwise ;
                            END;
                          reset_flag := true;
                        END;
                13 :    BEGIN    {^M = repeat}
                          msg_print(old_msg);
                          reset_flag := true;
                        END;
                16 :    if (wizard) then  {^P = password}
                          BEGIN
                            msg_print('Wizard mode off.');
                            wizard := false;
                            reset_flag := true;                  
                            no_controly;
                          END
                        else
                          if (valid_user) then
                            BEGIN
                              msg_print('Wizard mode on.');
                              controly;
			      wizard := true;
                              reset_flag := true
                            END
                          else
                            BEGIN {poor sap}
                              mwkdum:= aggravate_monster(30);
                              prt('Type ''?'' for help...',1,1)
                            END;
                18 :    BEGIN    {^R = redraw}
                          draw_cave;
                          reset_flag := true;
                        END;
                26 :    BEGIN    {^Z = save}
                          if (total_winner) then
                            BEGIN
        msg_print('You are a Total Winner, your character must be retired...');
        msg_print('Use <Control>-Y to when you are ready to quit.');
                            END
                          else
                            BEGIN
                              if (search_flag) then search_off;
                              save_char;
                            END;
                        END;
                36 :    BEGIN   {$  = Shell }    
			if (wizard) THEN
			BEGIN
                          clear(1,1);
		          writeln('[Entering DCL shell, type "EOJ" to resume your game]');
                          writeln;
                          controly;
                          shell_out;
                          no_controly;
                          clear(1,1);
                          draw_cave;
                          reset_flag := true;      
			END             
			ELSE
		          msg_print ('Only wizards can spawn to Shell');	
                        END;
                46 :    BEGIN   {. = find }
                          y := char_row;
                          x := char_col;
                          if (get_dir('Which direction?',dir_val,
                                                        com_val,y,x)) then
                            BEGIN
                              find_flag := true;
                              move_char(dir_val);
                            END
                        END;
                47 :    BEGIN   {/ = identify }
                          ident_char;
                          reset_flag := true;
                        END;
                49 :    move_char(com_val - 48);  { Move dir 1 }
                50 :    move_char(com_val - 48);  { Move dir 2 }
                51 :    move_char(com_val - 48);  { Move dir 3 }
                52 :    move_char(com_val - 48);  { Move dir 4 }
                53 :    BEGIN      { Rest one turn }
                          move_char(com_val - 48);
                          sleep(0);  { Sleep 1/10 a second}
                          flush;
                        END;
                54 :    move_char(com_val - 48);  { Move dir 6 }
                55 :    move_char(com_val - 48);  { Move dir 7 }
                56 :    move_char(com_val - 48);  { Move dir 8 }
                57 :    move_char(com_val - 48);  { Move dir 9 }
                60 :    go_up;     {< = go up }
                62 :    go_down;   {> = go down}
                63 :    BEGIN      {? = help }
                          help;
                          reset_flag := true;   { Free move }
                        END;
  {       65 :    BEGIN   { Debug feature for weight
                          tmp1 := 0;
                          for i1 := 1 to inven_max-1 do
                            with inventory[i1] do
                              tmp1 := tmp1 + weight*number;
                          writev(out_val,inven_weight:1,' | ',tmp1:1);
                          msg_print(out_val);
                        END;}
                66 :    bash;   {B = bash }
                67 :    BEGIN   {C = character}
                          if (get_com('Print to file? (Y/N)',command)) then
                            CASE command of
                              'y','Y':  file_character;
                              'n','N':  BEGIN
                                          change_name;
                                          draw_cave;
                                        END;
                              otherwise ;
                            END;
                          reset_flag := true;   { Free move }
                        END;
                68 :    disarm_trap;   {D = disarm }
                69 :    eat;  {E = eat}
                70 :    refill_lamp;   {F = refill }
                76 :    BEGIN {L = location }
                          reset_flag := true;   { Free move }
                          if ((py.flags.blind > 0) or (no_light)) then
                            msg_print('You can''t see your map.')
                          else
                            BEGIN
                              writev(out_val,
                              'Section [',
                              (trunc((char_row-1)/outpage_height)+1):1,',',
                              (trunc((char_col-1)/outpage_width )+1):1,
                              ']; Location = [',char_row:1,',',char_col:1,']');
                              msg_print(out_val);
                            END;
                        END;
                77:     extra_cast;
                80:     BEGIN {P = print map}
                          reset_flag := true;   { Free move }
                          if ((py.flags.blind > 0) or (no_light)) then
                            msg_print('You can''t see to draw a map.')
                          else
                            print_map;
                        END;
                82 :    rest; {R = rest }
                83 :    if (search_flag) then   {S = srh mode }
                          BEGIN
                            search_off;
                            reset_flag := true; { Free move }
                          END
                        else if (py.flags.blind > 0) then
                  msg_print('You are incapable of searching while blind.')
                        else
                          BEGIN       
                            search_on;
                            reset_flag := true; { Free move }
                          END;
                84 :    tunnel;  {T = tunnel }
                92 :    mon_info; { \ = monster info utility - NBT }
                97 :    aim;  {a = aim }
                98 :    examine_book;  {b = browse }
                99 :    closeobject;   {c = close}
                100:    drop; {d = drop }
                101:    BEGIN {e = equipment}
                          reset_flag := true;   { Free move }
                          if (inven_command('e',0,0)) then draw_cave;
                        END;
                102:    throw_object;  {f = throw}
                104:    BEGIN {h = moria hlp}
                          moria_help('');
                          draw_cave;
                          reset_flag := true;   { Free move }
                        END;
                105:    BEGIN {i = inventory}
                          reset_flag := true;   { Free move }
                          if (inven_command('i',0,0)) then draw_cave;
                        END;
                106:    jamdoor; {j = jam}
                108:    BEGIN {l = look }
                          look;
                          reset_flag := true;   { Free move }
                        END;
                109:    cast; {m = magick }
                111:    openobject; {o = open }
                112:    pray; {p = pray }
                113:    quaff;   {q = quaff}
                114:    read; {r = read }
                115:    if (py.flags.blind > 0) then  {s = search }
                  msg_print('You are incapable of searching while blind.')
                        else
                          search(char_row,char_col,py.misc.srh);
                116:    BEGIN {t = unwear }
                          reset_flag := true;
                          if (inven_command('t',0,0)) then draw_cave;
                        END;
                117:    use;  {u = use staff}
                118:    game_version;  {v = version}
                119:    BEGIN {w = wear }
                          reset_flag := true;
                          if (inven_command('w',0,0)) then draw_cave;
                        END;
                120:    BEGIN {x = exchange }
                          reset_flag := true;
                          if (inven_command('x',0,0)) then draw_cave;
                        END;
                otherwise  if (wizard) then
                  BEGIN
                    reset_flag := true; { Wizard commands are free moves}
              CASE com_val of
                1  :    BEGIN {^A = Cure all}
                          remove_curse;
                          cure_blindness;
                          cure_confusion;
                          cure_poison;
                      {    remove_fear;    }
                          with py.stat do
                            BEGIN
                              cstr := str;
                              cint := int;
                              cwis := wis;
                              cdex := dex;
                              ccon := con;
                              cchr := chr;
                            END;
                          with py.flags do
                            BEGIN
                              if (slow >= 1) then
                                slow := 0;
                              if (image >= 1) then
                                image := 0;
			      if (afraid >= 1) then
				afraid := 0;
                            END;
                          Draw_cave;
			  reset_flag := true;
                        END;
                2  :    print_objects; {^B = objects }
                3  : {^C = Make nice character - mwk}
                     begin     
                       with py.misc do
                         begin
                           max_exp := 50000;
                           exp := max_exp;
                           au := 9999999;
                           lev := 28;
                           bth := 50;
                           mana := 5000;
                           mhp := 10000;
                           ptohit := 50;
                           ptodam := 50;
                           pac := 100;
                           ptoac := 100;
                           dis_th := 50;
                           dis_td := 50;
                           dis_tac := 100;
                           cmana := mana;
                           chp := mhp;
                         end;
                       with py.stat do
                         begin
                           str := 118; cstr := str;
                           int := 118; cint := str;
                           wis := 118; cwis := str;
                           dex := 118; cdex := str;
                           con := 118; ccon := str;
                           chr := 118; cchr := str;
                         end;
                       with py.flags do
                         begin
                           fire_resist := true;  cold_resist := true;
                           acid_resist := true;  regenerate  := true;
                           lght_resist := true;  free_act    := true;
                           sustain_str := true;  sustain_wis := true;
                           sustain_con := true;  sustain_dex := true;
                           see_inv     := true;  sustain_int := true;
                           slow_digest := true;  ffall       := true;
                         end;
		       draw_cave;
                     end;
                4  :    BEGIN {^D = up/down }
                          prt('Go to which level (0-1200) ? ',1,1);
                          get_string(tmp_str,1,31,10);
                          i1 := -1;
                          readv(tmp_str,i1,error:=continue);
                          if (i1 > -1) then
                            BEGIN
                              dun_level := i1;
                              if (dun_level > 1200) then
                                dun_level := 1200;
                              moria_flag := true;
                            END
                          else
                            erase_line(msg_line,msg_line);
                        END;
                8  :    wizard_help;   {^H = wizhelp }
                9  :    ident_spell;   {^I = identify}
                14 :    print_monsters;   {^N = mon map }
                12 :    wizard_light;  {^L = wizlight}
                20 :    teleport(100); {^T = teleport}
                22 :    restore_char;  {^V = restore }
                5  :    change_character; {^E = wizchar }
                6  :    mass_genocide; {^F = genocide}
                7  :    Begin
			   alloc_object(floor_set,5,10); {^G = treasure}
			   prt_map;
			End;
                10 :    BEGIN {^J = gain exp}
                          py.misc.exp := 2*py.misc.exp;
                          prt_experience;
                        END;
                11 :    BEGIN {^K = summon}
                          y := char_row;
                          x := char_col;
                          summon_monster(y,x,true);
                          creatures(false);
                        END;
                23 :    wizard_create; {^W = create}
                otherwise  prt('Type ''?'' for help...',1,1)
              END
              END
                else
                  prt('Type ''?'' for help...',1,1);
          END;
{ End of commands }
          until (not(reset_flag) or (moria_flag));
{ Teleport? }
        if (teleport_flag) then teleport(100);
{ Move the creatures }
        if (not moria_flag) then creatures(true);
{ Exit when moria_flag is set }
      until (moria_flag);
    END;
