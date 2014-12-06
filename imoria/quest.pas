[inherit('moria.env')] module quest;
 
[global,psect(quest$code)] procedure enter_fortress;

{
procedure change_money;
  var
    amount : integer;

begin
  amount := abs(py.misc.money[total$] - gld)*gold$value;
  if (gld > py.misc.money[total$]) then add_money(amount)
  else subtract_money(amount,true);
end;

procedure display_gold;
   var
     out_val  : vtype;
 
begin
   writev(out_val, 'gold remaining : ',gld:1);
   prt( out_val, 19, 22)
end;
}
procedure reward_quest;

	var
	  reward		: integer;

	begin
  	  reward := c_list[py.misc.cur_quest].mexp * (randint(3)+5) +
	    py.misc.lev * (randint(2)* 100) +
	    (randint(100) + py.stat.c[5]) * 2 +
	    py.stat.c[1] * randint(50) + 200;
	  msg_print('Ah... '+py.misc.name+', I was expecting you.');
	  msg_print('I see you''ve killed the '+c_list[py.misc.cur_quest].name+'. That''s good.');
	  msg_print('I''ve sent your reward with a page to the bank.');
	  msg_print('He deposited '+itos(reward)+' gold pieces under your name.');
	  py.misc.account := py.misc.account + reward;
	  msg_print('Have a good day.  Perhaps you should rest a night at the inn.');
          msg_print(' ');
	  py.misc.rep := py.misc.rep + randint(5) + 2;
	  if (py.misc.rep > 50) then py.misc.rep := 50;
          py.misc.cur_quest := 0;
	  py.flags.quested := false;
	  turn_counter := quest_delay;
	  prt_quested;
          clear(1,1);
          draw_cave;
	end;
function select_quest : integer; 
	var 
	  count		: integer;
	  exit_flag	: boolean;
	  tmp_select	: integer;

	begin
	  exit_flag := false;
	  count := 0;
	  repeat
	    count := count + 1;
	    if (c_list[count].level > py.misc.lev) then
	      begin
		exit_flag := true;
		repeat
		  tmp_select := count + randint(80);
	        until (uand(c_list[tmp_select].cmove,%X'00008000') = 0); 
	        if (tmp_select>max_creatures) then tmp_select:=max_creatures-1;
	      end;
	    if (count = max_creatures) then
	      begin
		tmp_select := max_creatures - 1;
		exit_flag := true;
	      end;
	  until exit_flag;
	  select_quest := tmp_select;
	end;

procedure draw_fortress (enter_flag : boolean);
  var
    shop_owner  		: vtype;
    count,count2,count3		: integer;
    exit_flag			: boolean;

begin
  if (not enter_flag) then
  begin
  for count := 1 to num_quests do
  begin
    count3 := 0;
    exit_flag := true;
    repeat
      count3 := count3 + 1;   
      quest[count] := select_quest;
      for count2 := 1 to count-1 do
	  if (quest[count] = quest[count2]) then exit_flag := false;
      if (count3 > 100) then exit_flag := true;
    until exit_flag;
  end;
  end;
  clear(1,1);
  shop_owner := 'Leckin           (Arch-Mage)            Quests';
  prt(shop_owner, 4, 10);
  for count := 1 to num_quests do
    prt(chr(count+96) + ')' + '     ' + c_list[quest[count]].name ,5+count,20);
      {                      display_gold;}
  prt('You may:',21,1);
  prt(' p) Pick a quest.                 i) Info on a quest.',22,2);
  prt('^Z) Exit from building.          ^R) Redraw the screen.' ,23,2);
end;

function completed_quest : boolean;
var out_val : vtype;
begin
if (not py.flags.quested) and (py.misc.cur_quest<>0)
    then begin
	   completed_quest := true;		  { return value             }
	   py.flags.quested := false;		  { not under quest          }
	   py.misc.quests := py.misc.quests + 1;  { one more is now complete }
	 end
    else completed_quest := false;
end;

function evaluate_char : boolean;
begin
    if (py.flags.quested) or (py.misc.lev > py.misc.quests) then
      evaluate_char := true
    else 
      evaluate_char := false;
end;

procedure reject_char;
begin
  msg_print('A guard meets you at the entrance and says:');
  case randint(4) of
    1 : msg_print('"M''lord, the Arch-Mage does not wish to be disturbed."');
    2 : msg_print('"My master has other business at the present time."');
    3 : msg_print('"Piss off you inexperienced peon."');
    4 : msg_print('"You have yet to prove yourself worthy."');
  end;
  msg_print('The guard escorts you back outside and locks the door.');
  msg_print('');
end;

function new_victim : boolean;
begin
  new_victim := (py.misc.cur_quest=0) and (py.misc.quests=0) and not(py.flags.quested);
end;

procedure explain_quests;

var
	in_char		: char;
	
begin
  clear(1,1);
  prt('Home of Leckin the Arch-Mage',2,26);
  prt('Greetings, adventurer, and welcome to my humble quarters.',6,10);
  prt('I see that you have come, like many before you, in an effort to',8,10);
prt('defeat the great evil that lies deep within the darkest bowels of',9,10);
prt('the caves of Moria.  As you well know, none have yet succeeded.',10,10);
prt('You, however . . . I feel that you are going to be different than',12,10);
prt('the rest.  You have it within you to defeat the accursed Balrog,',13,10);
prt('and restore peace and happiness to the people of this fair town.',14,10);
prt('But you cannot do it alone.  You will need someone to guide you.',15,10);
prt('I am willing to be that person, if you will have me.  I will aid',17,10);
prt('you in your quest to defeat the Balrog.  But in return, you must',18,10);
prt('complete many other, simpler quests.  These will strengthen you',19,10);
prt('and prepare you for your final conflict, many moons hence.',20,10);
  prt('[Hit space to continue]',24,28);
  inkey(in_char);
  clear(1,1);
prt('Home of Leckin the Arch-Mage',2,26);
prt('I will give you a cash reward for the completion of each quest,',6,10);
prt('to provide incentive for you.  In addition, I may occasionally',7,10);
prt('give you an item that will aid you in your overall quest.',8,10);
prt('If you agree to these conditions, then select one of the following',9,10);
prt('quests.  Either way, I wish you the best of luck.',10,10);
  prt('[Hit space to continue]',24,28);
  inkey(in_char);
end;

procedure repeat_quest;

begin
  msg_print('Hmmm. . .  I see you haven''t completed your quest.');
  msg_print('Have you forgotten it already?');
  msg_print('Go kill a ' + c_list[py.misc.cur_quest].name + '!');
  msg_print('');
end;

procedure parse_command(enter_flag : boolean);
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
 97, 98, 99, 100, 101:  {a,b,c,d,e}
	       begin
		 if ((turn_counter < quest_delay) and (not wizard1)) then
		   begin
		     msg_print('You were just in here... Come back later.');
		     msg_print(' ')
		   end
	  	 else
		   begin
		     if ((turn_counter < quest_delay) and wizard1) then
		     begin
msg_print('Being a Wizard you choose a quest regardless of the turn_counter.');
		       msg_print(' ');
		     end;
	             py.misc.cur_quest := quest[com_val-96];
		     py.flags.quested := true;
		     exit_flag := true;
		   end;
	       end;
{p}      112 : msg_print('Which quest would you like? [a-e]  ');
{i}      105 : msg_print('Kill ''em, of course!');
{^R}     18  : draw_fortress(enter_flag);
{^Z}	 26  : exit_flag := true;
         otherwise prt('Invalid Command.',1,1)
       end;
     end
  else exit_flag := true;
  until (exit_flag);
end;

var
	complete_flag 	: boolean;
	enter_flag	: boolean;

begin
  enter_flag := false;
  seed := get_seed;
  complete_flag := false;
  {gld := py.misc.money[total$];}
  msg_line := 1;
  if (py.misc.quests <= max_quests) then
  if evaluate_char
    then begin
	   if completed_quest then 
	   begin
	     reward_quest;
	     complete_flag := true;
	   end
	   else
	   begin
	     if new_victim then explain_quests;
	     if ((new_victim) or (py.misc.cur_quest < 1)) then	     
             begin
	       draw_fortress(enter_flag);
	       enter_flag := true;
	       parse_command(enter_flag);
  	       clear(1,1);
  	       draw_cave;
	     end
	     else 
	     repeat_quest;
	   end;
	 end
  else
    begin
      reject_char;
      complete_flag := true;
    end;
  if ((not complete_flag) and (turn_counter > quest_delay)) 
    then turn_counter := 0;
end;

[global,psect(quest$code)] function itos (i : integer): ctype;

	var
	  tmp_str		: ctype;
	  exit_flag		: boolean;

	begin
	  writev(tmp_str, i);
	  exit_flag := false;
	  repeat
	    if(tmp_str[1] in ['1','2','3','4','5','6','7','8','9','0'])then 
	      exit_flag := true
	    else
	      tmp_str := substr(tmp_str,2,length(tmp_str)-1);
	  until exit_flag;
	  itos := tmp_str;
	end;
end.
