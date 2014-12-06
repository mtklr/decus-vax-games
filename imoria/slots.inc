var
   pos : slot;
 
 
procedure display_slot_options;
 
begin
  prt(' -------------------------------------------           ',2,11);
  prt('|                                           |   _-_     ', 3,11);
  prt('|                                           |  /   \     ',4,11);
  prt('| XXXXXXXXXXXXX XXXXXXXXXXXXX XXXXXXXXXXXXX | (     )    ',5,11);
  prt('| X           X X           X X           X |  \ _ /     ',6,11);
  prt('| X           X X           X X           X |   | |      ',7,11);
  prt('| X           X X           X X           X |   | |      ',8,11);
  prt('| XXXXXXXXXXXXX XXXXXXXXXXXXX XXXXXXXXXXXXX |   | |      ',09,11);
  prt('|                                           |   | |      ',10,11);
  prt('|      X              X             X       |   | |      ',11,11);
  prt('|     XXX            XXX           XXX      |__/  |      ',12,11);
  prt('|      X              X             X       |     |      ',13,11);
  prt('|                                           |____/       ',14,11);
  prt('|                                           |             ',15,11);
  prt('|                                           |             ',16,11);
  prt('|                                           |             ',17,11);
  prt(' -------------------------------------------',18,11);
 
  prt('You may:',21,1);
  prt(' p) pull lever.                   d) display prizes.',22,2);
  prt('^Z) Return to main menu.         ^R) Redraw the screen.',23,2);
end;
 
 
(*  Centers slots in middle of box *)
procedure position_adjust(var c1,c2,c3 : integer);
 
begin
  c1 := 15;
  c2 := 29;
  c3 := 43;
  if (ord(pos[1]) > 2) then c1 := 14;
  if (ord(pos[2]) > 2) then c2 := 28;
  if (ord(pos[3]) > 2) then c3 := 42;
end;
 
 
 
procedure display_slots;
  var
    out_val  : vtype;
    c1,c2,c3 : integer;
 
begin
   clear(1,1);
   display_slot_options;
   position_adjust(c1,c2,c3);
    writev(out_val,pos[1]);
    put_buffer(out_val,7,c1);
    writev(out_val,pos[2]);
    put_buffer(out_val,7,c2);
    writev(out_val,pos[3]);
    put_buffer(out_val,7,c3);
   display_gold;
end;
 
 
 
procedure display_prizes;
  var
    command    : char;
    exit       : boolean;
 
begin
clear(1,1);
prt('                                1     2      5     10     25     50 ',4,1);
prt('jackpot  jackpot  jackpot     1000  2000   5000   1000  25000  50000',6,1);
prt('  bar      bar      bar         30    60    150    300    750   1500',7,1);
prt('  bell     bell     bell        15    30     75    150    375    750',8,1);
prt(' orange   orange   orange        8    16     40     80    200    400',9,1);
prt(' cherry   cherry   cherry        4     8     20     40    100    200',10,1);
prt(' bell      ---      bell         4     8     20     40    100    200',11,1);
prt('  ---      bar      bar          4     8     20     40    100    200',12,1);
prt('  ---    orange   orange         2     4     10     20     50    100',13,1);
prt(' jackpot   ---      ---          2     4     10     20     50    100',14,1);
prt(' cherry   cherry    ---          1     2      5     10     25     50',15,1);
prt('[hit any key to continue]',22,27);
exit :=  get_com('',command);
display_slots
end;
 
 
 
 
procedure get_slots;
 
begin
       case randint(20) of
          20                 :  pos[1] := jackpot;
          19,18,17           :  pos[1] := bar;
          16,15,14,13        :  pos[1] := bell;              (*  Wheel one  *)
          12,11,10,9,8       :  pos[1] := orange;
          7,6,5,4,3,2,1      :  pos[1] := cherry;
          end;
 
       case randint(20) of
          20                 :  pos[2] := jackpot;
          19,18,17           :  pos[2] := bar;
          16,15,14,13,12,11  :  pos[2] := bell;              (*   Wheel two  *)
          10,9,8,7           :  pos[2] := orange;
          6,5,4,3,2,1        :  pos[2] := cherry;
          end;
 
       case randint(20) of
          20                 :  pos[3] := jackpot;
          19,18,17,16        :  pos[3] := bar;
          15,14,13           :  pos[3] := bell;             (*  Wheel three  *)
          12,11,10,9,8,7     :  pos[3] := orange;
          6,5,4,3,2,1        :  pos[3] := cherry;
          end;
end;
 
 
(*  clears a line of slots *)
procedure clearslots(line  : integer);
var
   killpos     : vtype;
 
begin
    killpos  := '        ';
    put_buffer(killpos,line,15);
    put_buffer(killpos,line,29);
    put_buffer(killpos,line,43);
end;
 
 
(* Simulates wheel spinning  *)
procedure print_slots;
 
var
   i          :  integer;
   c1,c2,c3   :  integer;
 
begin
get_slots;                                    {get new slots}
for i := 1 to 9 do
  begin
   clearslots(7);                            {clear middle row}
    position_adjust(c1,c2,c3);                {center bar and bell}
 
    writev(out_val,pos[1]);
    put_buffer(out_val,8,c1);
    writev(out_val,pos[2]);
    put_buffer(out_val,8,c2);                 {print bottom}
    writev(out_val,pos[3]);
    put_buffer(out_val,8,c3);
 
    get_slots;                                {get new slots}
    position_adjust(c1,c2,c3);
 
    writev(out_val,pos[1]);
    put_buffer(out_val,6,c1);
    writev(out_val,pos[2]);                     {print top row}
    put_buffer(out_val,6,c2);
    writev(out_val,pos[3]);
    put_buffer(out_val,6,c3);
 
    clearslots(6);                              {clear top row}
    clearslots(8);                              {clear bottom row}
 
    writev(out_val,pos[1]);
    put_buffer(out_val,7,c1);
    writev(out_val,pos[2]);                      {print middle row}
    put_buffer(out_val,7,c2);
    writev(out_val,pos[3]);
    put_buffer(out_val,7,c3)
 
  end
end;
 
(* calculates the amount won *)       (* Currently, odds slightly favor   *)
                                      (* the user.   Return of 101% *)
procedure winnings;
 
var
   out_val                        : vtype;
   comment,comment1               : vtype;
   winning                        : integer;
 
begin
  comment  := 'You have won ';
  comment1 := ' gold pieces!';
  winning  := 0;
  if (pos[1]=pos[2]) and (pos[1]=cherry) then winning := bet;
  if (pos[1]=jackpot) then winning := bet*2;
  if (pos[2]=pos[3]) and (pos[2]=orange) then winning := 2*bet;
  if (pos[1]=pos[3]) and (pos[1]=bell) then winning := 4*bet;
  if (pos[2]=pos[3]) and (pos[2]=bar) then winning := 4*bet;
 
  if (pos[1]=pos[2]) and (pos[1]=pos[3]) then
           begin
               case (pos[1]) of
                    jackpot              : winning  := 1000*bet;
                    cherry               : winning  := 4*bet;
                    orange               : winning  := 8*bet;
                    bell                 : winning  := 15*bet;
                    bar                  : winning  := 30*bet
               end;
           end;
  if (winning = 0) then
   begin
    case randint(5) of
     1 : msg_print('You lose.                              ');
     2 : msg_print('Your money pouch feels a little lighter.');
     3 : msg_print('Rats!  Lost again!                     ');
     4 : msg_print('The casino owner becomes richer.       ');
     5 : msg_print('Apparently you don''t know the secret to winning at slots.');
     end
   end
  else  begin
           if winning > bet then begin
               case randint( 5) of
                  1 : msg_print('Hmmm...Maybe this system really works...');
                  2 : msg_print('Maybe you should quit while you''re ahead.');
                  3 : msg_print('Coins begin to pour out of the machine.');
                  4 : msg_print('You''re not cheating, are you?');
                  5 : msg_print('Be sure to report your winnings!');
               end;
                 writev(out_val, comment, winning:1, comment1);
                 msg_print(out_val);
           end
               else msg_print('You break even.');
     end;
  gld := gld + winning
end;
 
 
 
procedure get_slots_bet;
  var
    comment      : vtype;
    num          : integer;
    exit_flag    : boolean;
 
begin
  exit_flag := false;
  comment := 'Which machine (1 to 10000 gp)? ';
  repeat
    if get_response(comment, num) then
      begin
        bet := num;
          if (bet>0) and (bet<10001) then exit_flag :=true
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
end;
 
 
procedure slot_commands;
  var
    command     : char;
    exit_flag   : boolean;
 
begin
  bet := 0;
  exit_flag   := false;
  repeat
  if get_com('', command) then
     begin
       case (ord(command))  of
         112  :    get_slots_bet;
         18   :    display_slots;
         100  :    display_prizes;
         otherwise prt('Invalid Command.',1,1);
       end
     end
  else exit_flag  := true;
  if bet > 0 then
     begin
       gld := gld - bet;
       print_slots;
       winnings;
       bet := 0;
       display_gold
     end;
  check_casino_kickout;
  until (exit_flag)
end;
 
        (*****       slots    main      *****)
 
procedure game_slots;
 
begin
      clear(1,1);
      pos[1] := JACKPOT;
      pos[2] := JACKPOT;
      pos[3] := JACKPOT;
      display_slots;
      prt('You are standing in front of a row of odd looking machines.',1,1);
      slot_commands;
end;
 
 
 
