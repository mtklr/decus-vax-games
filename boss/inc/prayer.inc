        { Prayers ...                                     -RAK-   }
[psect(misc2$code)] procedure pray;
      var
                i1,i2,item_val,dir              : integer;
                choice,chance                   : integer;
                dumy,y_dumy,x_dumy              : integer;
                redraw                          : boolean;
      begin
        reset_flag := true;
        if (py.flags.blind > 0) then
          msg_print('You can''t see to read your prayer!')
        else if (no_light) then
          msg_print('You have no light to read by.')
        else if (py.flags.confused > 0) then
          msg_print('You are too confused...')
        else if (py.misc.pskill in [3,4]) then
          if (inven_ctr > 0) then
            begin
              if (find_range([91],i1,i2)) then
                begin
                  redraw := false;
                  if (get_item(item_val,'Use which holy book?',
                                                        redraw,i1,i2)) then
                    begin
                      if (use_skill('Recite which prayer?',item_val,
                                          choice,chance,redraw)) then
                        with skill_list[choice] do
                          begin
                            reset_flag := false;
                            if (randint(100) < chance) then
                              msg_print('You lost your concentration!')
                            else
                              begin
                                y_dumy := char_row;
                                x_dumy := char_col;
        { Prayers...                                    }
        case choice of
          1  :  detect_evil;
          2  :  hp_player(damroll('4d4')+1,'a prayer.');
          3  :  bless(randint(30)+12);
          4  :  remove_fear;
          5  :  light_area(char_row,char_col);
          6  :  detect_trap;
          7  :  detect_sdoor;
          8  :  slow_poison;
          9  :  if (get_dir('Which direction?',dir,dumy,y_dumy,x_dumy)) then
                  confuse_monster(dir,char_row,char_col);
          10 :  teleport(py.misc.lev*3);
          11 :  hp_player(damroll('8d4'),'a prayer.');
          12 :  bless(randint(60)+24);
          13 :  sleep_monsters2_3(char_row,char_col,2);
          14 :  create_food;
          15 :  begin
	          for i1 := 1 to inven_ctr do
                    with inventory[i1] do
                      flags := uand(flags,%X'7FFFFFFF');
	          for i1 := 23 to equip_max do
                    with equipment[i1] do
                      flags := uand(flags,%X'7FFFFFFF');
		end;
          16 :  with py.flags do
                  begin
                    resist_heat := resist_heat + randint(40) + 10;
                    resist_cold := resist_cold + randint(40) + 10;
                  end;
          17 :  cure_poison;
          18 :  if (get_dir('Which direction?',dir,dumy,y_dumy,x_dumy)) then
                  fire_ball(6,dir,char_row,char_col,
		     damroll('3d10')+py.misc.lev,3,false,'Black Sphere');
          19 :  hp_player(damroll('12d4'),'a prayer.');
          20 :  detect_inv2(randint(60)+24);
          21 :  protect_evil;
          22 :  earthquake;
          23 :  map_area;
          24 :  hp_player(damroll('16d4'),'a prayer.');
          25 :  turn_undead;
          26 :  bless(randint(100)+48);
          27 :  dispell_creature(%X'0008',3*py.misc.lev);
	  28 :  cure_disease;
          29 :  hp_player(200,'a prayer.');
          30 :  dispell_creature(%X'0004',3*py.misc.lev);
          31 :  warding_glyph;
          32 :  begin
                  dispell_creature(%X'0004',4*py.misc.lev);
                  cure_confusion;
                  remove_fear;
                  cure_poison;
                  cure_blindness;
                  hp_player(1000,'a prayer.');
                end;
          otherwise ;
        end;
        { End of prayers...                             }
                                if (not(reset_flag)) then
                                  with py.misc do
                                    begin
                                      exp := exp + sexp;
                                      prt_experience;
                                      sexp := 0;
                                    end
                              end;
                            with py.misc do
                              if (not(reset_flag)) then
                                begin
                                  if (smana > cmana) then
                                    begin
                                      msg_print('You faint from fatigue!');
                                      py.flags.paralysis :=
                                        randint(5*trunc(smana-cmana));
                                      cmana := 0;
                                      if (randint(3) = 1) then
                                begin
                                  msg_print('You have damaged your health!');
                                  py.stat.ccon := de_statp(py.stat.ccon);
                                  prt_constitution;
                                end;
                                    end
                                  else
                                    cmana := cmana - smana;
                                  prt_mana;
			          end;
			    if (randint(10)=1) then
			      reset_flag := true;
                          end
                    end
                  else
                    if (redraw) then draw_cave;
                end
              else
                msg_print('But you are not carrying any Holy Books!');
            end
          else
            msg_print('But you are not carrying any Holy Books!')
        else
          msg_print('Pray hard enough and your prayers may be answered.');
      end;
