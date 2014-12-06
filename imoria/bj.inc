var
        deal_bust                     : boolean;
        card5_save,card5              : boolean;
        dummy,dummyd                  : drawcard;
        dealerh,playerh               : hand;
        vald,valp,save                : integer;
        bust_flag,bust_save           : boolean;
        split_flag,already_split      : boolean;
        py_index                      : integer;
        hand_start                    : integer;
        win_draw                      : boolean;
        blackjack,blackjack_save      : boolean;
        pl_stay_flag                  : boolean;
        dl_ace_flag                   : boolean;
        double_flag,double_flag_save  : boolean;
 
 
procedure display_bj;
 
begin
  clear(21,1);
  display_gold;
  prt('You may:',22,2);
  prt(' p) place a bet.                         v) view the rules',23,2);
  prt('^Z) Exit blackjack.                     ^R) Redraw the screen.',24,2);
end;
 
 
procedure display_bj_game;
 
begin
  clear(21,1);
  prt('Your hand: ',5,1);
  prt('Dealer''s hand: ',12,1);
  display_gold;
  prt('You may: ',21,1);
  prt(' s) stand.                             h) hit.',22,2);
  prt(' d) double down.                       /) split.',23,2);
  prt('^R) Redraw the screen.                 v) view the rules. ',24,2);
end;
 
procedure opening_screen;
  (*     1         2         3         4         5         6               *)
begin(*890123456789012345678901234567890123456789012345678901234567890     *)
  prt(                                     '____',              2,45);
  prt(                                    '|A   | ____',        3,44);
  prt(           'XXX                      |    ||3   | ____',  4,19);
  prt(           'X  X  X                  |   A||    ||7   |', 5,19);
  prt(           'XXX   X     XX            ---- |   3||    |', 6,19);
  prt(           'X  X  X    X  X XXXX            ---- |   7|', 7,19);
  prt(           'XXX   X    XXXX X    X  X             ----',  8,19);
  prt(                 'XXXX X  X X    X X     X',              9,25);
  prt(                      'X  X X    XX      X  XX',          10,30);
  prt(     '____                  XXXX X X     X X  X XXXX',    11,13);
  prt(    '|A   | ____                 X  X X  X XXXX X    X  X',12,12);
  prt(    '|    ||J   |                     XXXX X  X X    X X',13,12);
  prt(    '|   A||    |                          X  X X    XX', 14,12);
  prt(     '---- |   J|                               XXXX X X',15,13);
  prt(           '----                                     X  X',16,19);
end;
 
 
 
procedure display_rules;
 
var
    command  : char;
    exit     : boolean;
 
begin
  clear(1,1);
  prt('MORIA   BLACKJACK   RULES ',2,21);
  prt('The object, of course, is to get as close as you can to 21 without',5,2);
  prt('going over.  Aces can count as either one or eleven, while all',6,2);
  prt('face cards count as ten.  The other cards are worth their face',7,2);
  prt('value.',8,2);
  prt('Once you have played your hand, the dealer will draw cards until',10,2);
  prt('he has at least 17.  However, if his total is 17 and he has an',11,2);
  prt('ace, he will hit. ',12,2);
  prt('Splitting and Doubling:',14,25);
  prt('After drawing your first two cards, you have the option of',16,2);
  prt('doubling your bet and taking one, and only one more card. ',17,2);
  prt('If your first two cards are the same, you may split, in which case',19,2);
  prt('you will then play out both hands, each with the same bet as the',20,2);
  prt('original hand.  Splitting is only allowed once per hand.',21,2);
    prt('[hit any key to continue]',24,23);
    exit := get_com('',command);
    clear(2,1);
  prt('A natural pays  3/2  times your bet, unless the dealer also has',3,2);
  prt('a blackjack, in which case you push.  The dealer will not offer ',4,2);
  prt('you insurance.',5,2);
  prt('If you draw five cards, without going over 21, you automatically',7,2);
  prt('win, regardless of the dealer''s hand.',8,2);
    prt('[hit any key to continue]',24,23);
    exit := get_com('',command);
end;
 
 
 
procedure initialize_hand;
  var
    i : integer;
 
begin
 for i := 1 to 10 do
  begin
   dealerh[i] := 0;
   dummy[i] := ' ';
   playerh[i] := 0;
   dummyd[i]  := ' ';
 end;
 bust_flag := false;
 hand_start := 1;
 pl_stay_flag := false;
 card5 := false;
 blackjack := false;
 py_index := 2;
 win_draw := false;
 already_split := false;
 split_flag := false;
 double_flag := false;
end;
 
 
 
procedure evaluate_pl_hand;
  var
    i    : integer;
    py_ace_flag : boolean;
 
begin
  bust_flag := false;
  py_ace_flag := false;
  valp := 0;
  for i := hand_start to hand_start + 4 do
    begin
      if (playerh[i] > 10) then valp := valp + 10
      else valp := playerh[i] + valp;
      if (playerh[i] = 14) then
         begin
           valp := valp - 9;
           py_ace_flag := true;
         end;
    end;
    if (valp < 12) and (py_ace_flag) then valp := valp + 10;
    if (valp > 21) then bust_flag := true;
end;
 
 
 
procedure evaluate_dl_hand(index : integer);
  var
    i   : integer;
 
begin
  deal_bust := false;
  dl_ace_flag := false;
  vald := 0;
  for i := 1 to index do
    begin
      if (dealerh[i] > 10)  then vald := vald + 10
      else vald := dealerh[i] + vald;
      if (dealerh[i] = 14) then vald := vald - 9;
      if (dealerh[i] = 14) and  (vald < 12) then
         begin
           dl_ace_flag := true;
           vald := vald + 10
         end;
      if (vald > 21) and dl_ace_flag then
         begin
           vald := vald - 10;
           dl_ace_flag := false;
         end
    end;
    if vald > 21 then deal_bust := true;
end;
 
 
 
procedure hand_save;
 
begin
      save := valp;
      evaluate_pl_hand;
      pl_stay_flag := false;
      card5_save:= card5;
      card5 := false;
      if double_flag then bet := bet div 2;
      double_flag_save := double_flag;
      double_flag := false;
      blackjack_save := blackjack;
      blackjack := false;
      hand_start := 6;
      already_split := true;
      py_index := 7;
      bust_save := bust_flag;
      bust_flag := false;
end;
 
 
 
procedure check_exit(var exit_flag : boolean);
 
begin
  if double_flag then exit_flag := true;
  if (valp = 21) and ((py_index = 2) or (py_index = 7)) then begin
        exit_flag := true;
        blackjack := true;
     end;
  if pl_stay_flag then exit_flag := true;
  if (py_index = 5) or (py_index = 10) then begin
     exit_flag := true;
     card5 := true;
    end;
  if bust_flag then exit_flag := true;
  if split_flag and (exit_flag) and not(already_split) then
    begin
      hand_save;
      msg_print('Now play the hand on the right.');
      exit_flag := false;
    end;
end;
 
 
procedure get_first_dealc;
  var
    c    : integer;
    draw : vtype;
 
begin
  draw := ' ____';
  writev(out_val,draw);
  put_buffer(out_val,13,8);
  draw := '|\  /|';
  writev(out_val,draw);
  put_buffer(out_val,14,8);
  draw := '|-**-|';
  writev(out_val,draw);
  put_buffer(out_val,15,8);
  draw := '|/  \|';
  writev(out_val,draw);
  put_buffer(out_val,16,8);
  draw := ' ----';
  writev(out_val,draw);
  put_buffer(out_val,17,8);
end;
 
 
procedure card_draw (index,r : integer;card: vtype);
  var
    c    : integer;
    draw : vtype;
 
begin
if not(card = ' ') then
  begin
  if ((r = 13) and (index = 1) and (win_draw = false)) then get_first_dealc
  else
    begin
      c := 1 + 7*index;
      draw := ' ____';
      writev(out_val,draw);
      put_buffer(out_val,r,c);
      draw := '|    |';
      writev(out_val,draw);
      put_buffer(out_val,r+1,c);
      draw := '|    |';
      writev(out_val,draw);
      put_buffer(out_val,r+2,c);
      draw := '|    |';
      writev(out_val,draw);
      put_buffer(out_val,r+3,c);
      draw := ' ----';
      writev(out_val,draw);
      put_buffer(out_val,r+4,c);
      writev(out_val,card);
      put_buffer(out_val,r+1,c+1);
      if (card = '10') then put_buffer(out_val,r+3,c+3)
      else put_buffer(out_val,r+3,c+4)
    end
  end
end;
 
 
 
procedure re_draw;
  var
    i : integer;
 
begin
clear(1,1);
prt('Your hand:',5,1);
prt('Dealer''s hand: ',12,1);
for i := 1 to 10 do
 begin
  card_draw(i,6,dummy[i]);
  card_draw(i,13,dummyd[i]);
 end;
if bet>0 then display_bj_game
else display_bj;
end;
 
 
procedure get_dealer_card(i : integer);
 
begin
  dealerh[i] := randint(13)+1;
    case (dealerh[i]) of
      2 :  dummyd[I] := '2';
      3 :  dummyd[I] := '3';
      4 :  dummyd[I] := '4';
      5 :  dummyd[I] := '5';
      6 :  dummyd[I] := '6';
      7 :  dummyd[I] := '7';
      8 :  dummyd[I] := '8';
      9 :  dummyd[I] := '9';
     10 :  dummyd[I] := '10';
     11 :  dummyd[i] := 'J';
     12 :  dummyd[I] := 'Q';
     13 :  dummyd[I] := 'K';
     14 :  dummyd[I] := 'A';
    end;
  card_draw(i,13,dummyd[i]);
  evaluate_dl_hand(i)
end;
 
 
 
procedure get_player_card(i : integer);
 
begin
  playerh[i] := randint(13)+1;
    case (playerh[i]) of
      2 :  dummy[I] := '2';
      3 :  dummy[I] := '3';
      4 :  dummy[I] := '4';
      5 :  dummy[I] := '5';
      6 :  dummy[I] := '6';
      7 :  dummy[I] := '7';
      8 :  dummy[I] := '8';
      9 :  dummy[I] := '9';
     10 :  dummy[I] := '10';
     11 :  dummy[I] := 'J';
     12 :  dummy[I] := 'Q';
     13 :  dummy[I] := 'K';
     14 :  dummy[I] := 'A';
    end;
  card_draw(i,6,dummy[i]);
  evaluate_pl_hand;
end;
 
 
 
procedure get_dealer_hand;
 
begin
    get_dealer_card(1);
    get_dealer_card(2);
end;
 
 
procedure get_player_hand;
 
begin
    get_player_card(1);
    py_index := 2;
    get_player_card(2);
end;
 
 
procedure get_winning;
 
var
  i     : integer;
 
begin
     if (deal_bust)  then
       begin
         gld := gld + 2*bet;
         case (randint(4)) of
             1,2,3 : msg_print('The dealer busts, you win.');
                 4 : msg_print('The dealer busts.');
         end
       end
     else
        begin
           if ((vald > valp) and (vald <> valp)) then
              begin
                case (randint(5)) of
               1,2,3 : msg_print('You lose.');
                   4 : msg_print('Now you know why gambling is illegal.');
                   5 : msg_print('If you had just taken one more card...');
                end;
              end;
           if vald = valp then begin
                 msg_print('You push');
                 gld := gld + bet;
                 end;
           if valp > vald then begin
                 case (randint(4)) of
                   1,2,3  : msg_print('You win.');
                       4  : msg_print('You''re not card-counting are you?');
                 end;
                 gld := gld + bet*2;
              end;
        end;
end;
 
 
procedure play_dealer_hand;
  var
    i : integer;
    stay_flag : boolean;
 
begin
stay_flag := false;
win_draw := true;
card_draw(1,13,dummyd[1]);
   i := 3;
   if ((vald = 17) and (dl_ace_flag)) or (vald < 17) then
       begin
         repeat
          get_dealer_card(i);
          i := i + 1;
          if vald > 16 then stay_flag := true;
          if (vald = 17) and (dl_ace_flag) then stay_flag := false;
          if i > 9 then stay_flag := true;
         until (stay_flag);
       end;
  get_winning;
end;
 
 
 
procedure double;
 
begin
bet := bet*2;
py_index := py_index + 1;
get_player_card(py_index);
double_flag := true;
end;
 
 
 
procedure split;
 
begin
  playerh[6] := playerh[1];
  dummy[6]:= dummy[1];
  card_draw(6,6,dummy[6]);
  get_player_card(2);
  get_player_card(7);
  split_flag := true;
end;
 
 
 
 
procedure get_game_command;
  var
    command            : char;
    com_val            : integer;
    n                  : integer;
 
begin
  if get_com( '', command) then
     begin
       com_val   := ord(command);
       case com_val of
          104 : begin                                    (* hit *)
                  py_index := py_index + 1;
                  get_player_card(py_index);
                end;
          115 : pl_stay_flag := true;                      (* stay *)
           18 : re_draw;
          118 : begin
                  display_rules;
                  re_draw;
                end;
          100 : begin                                    (* double *)
                if (gld >= bet) then begin
                  if (py_index = 2) or (py_index = 7) then begin
                        gld := gld - bet;
                        display_gold;
                        double;
                      end;
                  end;
                end;
           47 : begin                                     (* split *)
                if not(split_flag) and (gld >= bet) and
                   (py_index = 2) and (playerh[1] = playerh[2]) then  begin
                        gld := gld - bet;
                        display_gold;
                        split;
                        msg_print('First play your hand on the left.');
                     end;
                 end;
         otherwise prt('Invalid Command.',1,1)
       end;
       end;
end;
 
 
procedure play_hand;
  var
    num,i       : integer;
 
begin
    num := 1;
    if (split_flag) then
    begin
      msg_print('As for your second hand...');
      num := 2;
    end;
for i := 1 to num do
  begin
  if (i = 2) then msg_print ('As for your first hand...');
  if (i = 2) and (double_flag) then bet := bet div 2;
  if (i = 2) and (double_flag_save) then bet := bet*2;
  if not(card5 or bust_flag or blackjack) then play_dealer_hand
  else  begin
      if card5 and not(bust_flag) then begin
         gld := gld + 2*bet;
         msg_print('Five cards, you win.');
         end;
      if bust_flag then begin
         case (randint(3)) of
           1,3 :  msg_print('You bust.');
           2   :  msg_print('You should have stood.');
         end
        end;
      if blackjack then begin
         msg_print('Blackjack!');
         win_draw := true;
         card_draw(1,13,dummyd[1]);
         if vald = 21 then begin
             msg_print('The dealer also has 21 ... You push.');
             gld := gld + bet;
             end
         else gld := gld + 2*bet + bet div 2;
      end;
  end;
  valp := save;
  bust_flag := bust_save;
  blackjack := blackjack_save;
  card5 := card5_save;
  display_gold;
end;
  clear(21,1);
  bet := 0;
end;
 
 
procedure play_bj;
  var
    exit_flag   : boolean;
 
begin
  exit_flag := false;
  clear(1,1);
  display_bj_game;
  initialize_hand;
  get_dealer_hand;
  get_player_hand;
  repeat
    if not((valp=21) and ((py_index=2)or(py_index=7))) then get_game_command;
    check_exit(exit_flag);
  until exit_flag;
  play_hand;
end;
 
 
 
procedure get_bj_bet;
  var
    comment      : vtype;
    num          : integer;
        exit_flag    : boolean;
  begin
      exit_flag := false;
      comment := 'How much would you like to bet(50 to 1000 gp)? ';
      repeat
      if get_response(comment, num) then
      begin
        bet := num;
          if (bet>49) and (bet<1001) then exit_flag := true
          else prt('Improper value.',1,1)
      end
    else
      begin
         exit_flag := true;
         bet := 0
      end;
  until (exit_flag);
    if bet > gld then
       begin
         prt('You have not the gold!',1,1);
         bet := 0;
       end;
  gld := gld - bet;
  display_gold
end;
 
 
 
procedure blackjack_commands;
  var
    command     : char;
    exit_flag   : boolean;
    n           : integer;
 
begin
  bet := 0;
  win_draw := false;
  exit_flag   := false;
  repeat
  if get_com('', command) then
     begin
       case (ord(command))  of
          112   :   begin
                      get_bj_bet;
                      if bet >0 then
                          begin
                            play_bj;
                            display_bj;
                          end
                    end;
           118  :   begin
                      display_rules;
                      re_draw;
                    end;
            18  :   begin
                      clear(1,1);
                      re_draw;
                    end;
         otherwise prt('Invalid Command.',1,1);
       end
     end
  else exit_flag  := true;
  check_casino_kickout;
  until (exit_flag)
end;
 
 
procedure game_blackjack;
 
begin
      clear(1,1);
      display_bj;
      initialize_hand;
      opening_screen;
      prt('The dealer awaits your bet.',1,1);
      blackjack_commands
end;
 
 
 
