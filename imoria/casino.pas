[inherit('moria.env')] module casino;
 
  const
        max_horse_names = 55;
	races_per_day	= 10;
 
  var
        out_val         : vtype;
	tics		: integer;
 
[global,psect(casino$code)] procedure enter_casino;
 
  type
        stype		= (jackpot,cherry,orange,bell,bar);
        slot		= array[1..3] of stype;
        hand		= array[1..15] of integer;
        drawcard	= array[1..15] of vtype;
        h_name		= array[1..max_horse_names] of vtype;
        h_stat		= array[1..max_horse_names] of integer;
	h_bool		= array[1..max_horse_names] of boolean;
	statr           = array[1..10] of real;
 
  var
        msg_flag        : boolean;
        msg_line        : integer;
        str_buff        : varying[20] of char;
        old_msg         : vtype;
        gld		: integer;
        bet             : integer;
        horsename       : [static] h_name;
        horsestat       : [static] h_stat;
	closed		: boolean;
 
 
value
       horsename := ('Man ''o War','Secretariat','Seattle Slew','Moksha',
                 'Beast Master','Prince of Darkness','Beelzebub',
                 'Black Shadow','Gargle Blaster','George Jetson','Covenant',
                 'Turiya','Neysa','Sure Thing','Battle Cruiser','Mobie',
                 'Arthur Dent','Mr. Creosote','Shadowfax','Bet Twice',
                 'I''m a Lumberjack','Dr. Science','Harry The Horse',
                 'Tiberius','Hellfire','Mephistopheles','Belial','Pluto',
                 'Firesweeper','Cloudminder','Spectacular Bid','Noor',
                 'Affirmed','Citation','Dr. Fagen','War Admiral','Epitaph',
                 'Not A Chance','Death Pizza','Relay(Cop''s)Horse','Nightmare',
                 'Excelsior','Paul Revere','Myxilplick','Mercury','Robohorse',
                 'Hellfire','Bladerunner','Arch Mage','Shadow Runner',
                 'Golden Hoof','Necromancer','Heirophant','Jehannum','Transwarp');
 
 
       horsestat := (25,30,28,22,21,24,23,22,23,20,26,23,30,23,19,23,22,19,27,
                     25,23,28,24,26,22,25,21,22,26,24,28,27,29,29,28,26,26,17,
                     25,18,26,31,28,23,28,26,25,27,29,25,23,26,27,26,27);

 
procedure change_money;
  var
    amount : integer;
begin
  amount := abs(py.misc.money[total$] - gld)*gold$value;
  if (gld > py.misc.money[total$]) then add_money(amount)
  else subtract_money(amount,true);
end;
 
procedure check_casino_kickout;
  begin
    if ((tics mod 2) = 1) then
      if (check_kickout) then
	begin
	  msg_print('A new version of IMoria is being installed.');
	  msg_print('After your character is saved, wait a few minutes,');
	  msg_print('And then try to run the game.');
	  msg_print('');
	  change_money;
	  repeat
	    py.flags.dead := false;
	    save_char(true);
	  until(false);
	end;
    tics := tics + 1;
  end;
 
function get_response(comment : vtype; var num : integer) : boolean;
 
var
    i1, clen             : integer;
    out_val              : vtype;
    flag                 : boolean;
 
begin
      flag := true;
      i1 := 0;
      clen := length(comment) + 2;
      repeat;
        prt(comment,1,1);
        msg_flag := false;
        if (not(get_string(out_val,1,clen,40))) then
               begin
                    flag := false;
                    erase_line(msg_line,msg_line);
               end;
      readv(out_val,i1,error:=continue);
   until((i1 <> 0) or not(flag));
   if (flag) then num := i1;
   get_response := flag
end;
 
 
procedure display_gold;
   var
     out_val  : vtype;
 
begin
   writev(out_val, 'gold remaining : ',gld:1);
   prt( out_val, 19, 22)
end;
 
 
procedure   display_casino;
  var
    shop_owner : vtype;
begin
  clear(1,1);
  shop_owner := 'Darkon           (Master-Hacker)            Casino';
  prt(shop_owner, 4, 10);
  prt('Game:                                                  Max Bet',6,4);
  prt('a) slots                                                  10000', 7,1);
  prt('b) blackjack                                               1000', 8,1);
  prt('c) horse racing                                            1000', 9,1);
                            display_gold;
  prt('You may:',21,1);
  prt(' p) Play a game.                  h) Help on game rules.',22,2);
  prt('^Z) Exit from building.          ^R) Redraw the screen.' ,23,2);
end;
 
        %INCLUDE 'bj.inc'
        %INCLUDE 'slots.inc'
        %INCLUDE 'horse.inc'
 
procedure play_game;
  var
    game          : char;
    com_val       : integer;
    exit_flag     : boolean;
begin
  exit_flag := false;
  repeat
  msg_print('Which game do you want to play?      ');
  if get_com('', game) then
     begin
       com_val   := ord(game);
       case com_val of
          97     :  begin
                      game_slots;
                      exit_flag := true;
                      display_casino
                    end;
          98     :  begin
                      game_blackjack;
                      exit_flag := true;
                      display_casino
                    end;
          99     :  begin
                      game_horse;
                      exit_flag := true;
                      display_casino
                    end;
          otherwise prt('That game does not exist, try again.',1,1);
       end;
     end
  else exit_flag := true;
  until(exit_flag)
end;
 
procedure exit_messages;
begin
  if (gld > 2*py.misc.money[total$] + 1000) then begin
      case randint(3) of
        1 :  msg_print('Quitting while you''re ahead, huh?');
        2 :  msg_print('Lady luck must be on you side.');
        3 :  msg_print('A pair of heavily armed thugs show you to the door.');
      end
    end
  else if (gld < py.misc.money[total$] - 1000) then begin
       case randint(4) of
         1 : msg_print('KC thanks you for your patronage.');
         2 : msg_print('KC personally escorts you to the door.');
         3 : msg_print('Better luck next time.');
         4 : msg_print('You leave a sadder and wiser man.');
       end
    end
  else msg_print('Bye.');
  msg_print(' ');
end;
 
 
procedure parse_command;
  var
    command        : char;
    com_val        : integer;
    exit_flag      : boolean;
begin
  exit_flag := false;
  repeat
  if get_com( '', command) then
     begin
       com_val   := ord(command);
       case com_val of
         112 : play_game;
         18  : display_casino;
         otherwise prt('Invalid Command.',1,1)
       end;
     end
  else exit_flag := true;
  until (exit_flag) or (closed);
end;
 
begin
  closed := false;
  tics := 1;
  seed := get_seed;
  gld := py.misc.money[total$];
  msg_line := 1;
  display_casino;
  parse_command;
  exit_messages;
  change_money;
  clear(1,1);
  draw_cave;
end;
 
end.
