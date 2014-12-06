[psect(bank$code)] procedure enter_bank;
 
var
        exit_flag       : boolean;
        shop_owner      : vtype;
        out_val         : vtype;
 	tics		: integer;
	coin$name	: array [4..6] of vtype;


{ Display their money    ADW}
procedure display_money;
  var
        out_val : vtype;
  begin
    writev(out_val,' Gold remaining : ',(py.misc.money[total$]):1);
    prt(out_val,18,18);
    writev(out_val,' Account : ',(py.misc.account):1);	
    prt(out_val,16,20);
    with py.misc do begin
      writev(out_val, 'You have ');
      put_buffer(out_val, 6, 25);
      writev(out_val, 'Mithril  : ',money[6]:10);
      put_buffer(out_val, 8, 25);
      writev(out_val, 'Platinum : ',money[5]:10);
      put_buffer(out_val, 9, 25);
      writev(out_val, 'Gold     : ',money[4]:10);
      put_buffer(out_val, 10, 25);
      writev(out_val, 'Silver   : ',money[3]:10);
      put_buffer(out_val, 12, 25);
      writev(out_val, 'Copper   : ',money[2]:10);
      put_buffer(out_val, 13, 25);
      writev(out_val, 'Iron     : ',money[1]:10);
      put_buffer(out_val, 14, 25);
    end;
    if(wizard2) then begin
      put_buffer('Bank has ', 6, 50);
      writev(out_val,bank[mithril]:10);
      put_buffer(out_val, 8, 50);
      writev(out_val,bank[platinum]:10);
      put_buffer(out_val, 9, 50);
      writev(out_val,bank[gold]:10);
      put_buffer(out_val, 10, 50);
    end;
    put_qio;
end;
 
{Clear the screen and display the bank.} 
procedure display_store;
  begin
    clear(1,1);
    prt(shop_owner,4,10);
    display_money;
    prt('You may:',19,1);
    prt(' d) Deposit money.             w) Withdraw money.',20,1);
    prt(' c) Change small currency.     i) Buy insurance.',21,1);
    prt('^Z) Exit from building.       ^R) Redraw the screen.',22,1);
    prt(' p) Put item in vault.         r) Remove item from vault.',23,1);
  end;
 
{ Returns true if a number >= 0 is entered, false if escaped, }
{ negative numbers not permitted.                      -MKC-  }
function get_entry(comment : vtype; var num : integer) : boolean;
  var
        in_val                  : vtype;
        valid                   : boolean;
  begin
    num:=-1;
    repeat
      valid:=true;
      msg_print(comment);
      msg_flag := false;
      if get_string(in_val,1,length(comment)+2,40) then begin
        readv(in_val,num,error:=continue);
        if (num>=0) then get_entry:=true
          else begin
            msg_print('Invalid entry.');
            valid:=false
          end
      end else begin       {user escaped out}
        erase_line(msg_line,msg_line);
        get_entry:=false;
      end;
    until valid;
  end;
 
{ Deposit a given number of mithril, platinum, and gold in the bank, }
{ but the bank takes its percentage                      -ADW-MKC-   } 
procedure deposit_money;
  var
        deposit                 : integer;

  procedure dep_munny(mon_type : integer);
    var deposit : integer;
    begin
     with py.misc do
      if (money[mon_type] > 0) then begin
	repeat
	  if (get_entry('How much '+coin$name[mon_type]+' to deposit?',
			deposit)) then
	    if (deposit > money[mon_type]) then
	      msg_print('You do not have that much '+name+'!');
	until (deposit <= money[mon_type]);
	if (deposit>0) then begin
	  bank[mon_type] := bank[mon_type] + deposit;
	  money[mon_type] := money[mon_type] - deposit;
	  inven_weight := inven_weight - coin$weight * deposit;
	  account := account + trunc(deposit*bank_skim*coin$value[mon_type])
		div gold$value;
	  display_money;
	end;
      end;
    end;

  begin
    dep_munny(mithril);
    dep_munny(platinum);
    dep_munny(gold);
    reset_total_cash;
  end;
 
{ Withdraw a given amount, in gold pieces, teller makes change. }
{ Bank may not have enough!                              -MKC-  } 
procedure withdraw_money;
  var
        deliver,is_some			: boolean;
	amt_given			: array[gold..mithril] of integer;
        mon_type,withdraw,weight_left	: integer;
	out_val				: vtype;
      
  begin
    with py.misc do begin
      repeat  { get amount to withdraw }
        if get_entry('How much money to withdraw (in gold)?',withdraw) then
          if(withdraw > account) then begin
            msg_print('You do not have that much!');
            msg_print('You should keep better track of your account!');
          end;
      until (withdraw<=account);
{ The amount actually given is the minimum of how much the user wants, }
{ how much the bank has, and how much the user can carry.              }
      if(withdraw>0) then begin
	weight_left := weight_limit*100-inven_weight;
	for mon_type := gold to mithril do
	  begin
	   amt_given[mon_type] := min((withdraw * gold$value) div
	     coin$value[mon_type],bank[mon_type],weight_left div coin$weight);
	   weight_left:=weight_left - amt_given[mon_type]*coin$weight;
	   withdraw:=withdraw-amt_given[mon_type]*(coin$value[mon_type]
		 div gold$value);
	  end;
        deliver:=true;
	is_some := amt_given[mithril]+amt_given[platinum]+amt_given[gold]>0;
	if (withdraw>0) then  { if unable to give the entire amount }
	  if (weight_left>0) then  { they can't carry it all }
	    if (is_some) then
	     begin
	      msg_print('You cannot carry it all.');
	      deliver:=get_yes_no('Do you want as much as you can carry?')
	     end
	    else
	     begin
	      msg_print('You cannot carry any more money.');
	      deliver:=false;
	    end
	  else begin { the bank doesn't have enough money }
	    if (is_some) then begin
	      msg_print('We are rather short of cash today.');
	      deliver:=get_yes_no('Do you want as much as you can get?')
	    end
	    else begin
	      msg_print('We do not have the cash to give you.');
	      msg_print('Try again tomorrow.');
	      deliver:=false;
	    end;
          end;
	if deliver then begin
	  for mon_type := gold to mithril do
	    begin
	      if (amt_given[mon_type] > 0) then
		begin
		  writev(out_val,'The teller gives you ',amt_given[mon_type]:1,
			' '+coin$name[mon_type]+' pieces.');
		  msg_print(out_val);
		  money[mon_type] := money[mon_type] + amt_given[mon_type];
		  bank[mon_type] := bank[mon_type] - amt_given[mon_type];
		  account := account-amt_given[mon_type]*coin$value[mon_type]
			div gold$value;
		end;
	    end;
	  inven_weight := weight_limit*100-weight_left;
          reset_total_cash;
          display_money;
	end;  {deliver}
      end;  {withdraw}
    end;  {with}
  end;  {withdraw_money}

   {  characters can put items in storage  }
  procedure safe_deposit (deposit : boolean);


	var
	  junk_list		: array[1..20] of vtype;
	  count			: integer;
	  com_ptr		: treas_ptr;
	  out_val       	: vtype;
	  temp			: integer;
	  f1			: text;
	  f2			: text;
	  in_char		: char;
	  i1			: integer;
	  redraw		: boolean;

  begin
    redraw := false;
    with py.misc do
    if (deposit) then
      if (inven_ctr > 0) then
      begin
	count := change_all_ok_stats(true,false);
	com_ptr := inventory_list;
	while (com_ptr <> nil) do
	begin
	  if(com_ptr^.data.tval=bag_or_sack) and (com_ptr^.insides<>0) then
	  begin
	    com_ptr^.ok := false;
	    count := count - 1;
	  end;
	  com_ptr := com_ptr^.next;
	end;
	if (get_item(com_ptr,'Deposit?',redraw,count,in_char,false)) then
	begin
	  if (com_ptr^.data.cost > 10000) then
	  begin
	    open(f1,file_name:='Moria_Bnk',history:=unknown,error:=continue);
	    if (status(f1) = 0) then
	    begin
	      extend(f1);
	      objdes(out_val,com_ptr,true);
	      msg_print('Deposited ' + out_val + '.');
	      msg_print(' ');
	      writeln(f1,py.misc.ssn);
	      with com_ptr^.data do
 	      begin
		writeln(f1,name);
		writeln(f1,tval);
		writeln(f1,tchar);
		writeln(f1,flags2);
		writeln(f1,flags);
		writeln(f1,p1);
		writeln(f1,cost);
		writeln(f1,subval);
		writeln(f1,weight);
		writeln(f1,number);
		writeln(f1,tohit);
		writeln(f1,todam);
		writeln(f1,ac);
		writeln(f1,toac);
		writeln(f1,damage);
		writeln(f1,level);
	      end;
	      writeln(f1,com_ptr^.ok);
	      inven_destroy(com_ptr);
	      close(f1);
	    end;
	  end
	else
	  begin
	    msg_print('Put that back in your pack.  We only allow *valued* items in our vault');
	    msg_print(' ');
	  end;
	end;
      end
      else
        prt('But you aren''t carrying anything.',1,1)
    else
      begin
        open(f1,file_name:='Moria_bnk',history:=old,error:=continue);
        if (status(f1) <> 0) then
        begin
	  count := 0;
	  repeat
	    count := count + 1;
	    readln(f1,out_val);
	    if (out_val = py.misc.ssn) then
	    begin
	      readln(f1,junk_list[count]);
	      for i1 :=1 to 16 do readln(f1,out_val);		
	    end
	    else
	      for i1 :=1 to 17 do readln(f1,out_val);
	  until (eof or (count > 19));
	  close(f1);
        end;
	prt('Remove which one?',1,1);
	for i1 := 1 to count do
          prt(chr(i1+96)+') '+junk_list[i1],i1+2,1);
      end;  
      display_store;
    end;

  procedure change_money;
{  Changes money of one type to money of another type.        -JPS- }
    var 
        change_flag     : boolean;   { Did they enter a valid entry? }
        amount_from     : integer;   { Amount before changing. }
        amount_to       : integer;   { Amount remaining after changing. }
	key_in		: char;	     { input character }
        typ_from,typ_to : integer;   { Types of money }
        prompt          : string;    { Prompt used.}

    begin
    with py.misc do
     begin
      key_in := chr(get_money_type('Change what coin? ',change_flag,false));
      if change_flag then
	begin
	  coin_stuff(key_in,typ_from);
	  key_in := chr(get_money_type('Change to? ',change_flag,true));
	end;
      if change_flag then
        begin
	  coin_stuff(key_in,typ_to);
          writev(prompt,'Number of coins to change? (1-',
		money[typ_from]:1,'), ^Z to exit : ');
          change_flag := get_entry(prompt,amount_from);
        end;
      if (change_flag) then
	begin
          amount_to := (amount_from * coin$value[typ_from]) div
			coin$value[typ_to]; {NO surcharge}
	  if (amount_to = 0) then
	    msg_print('You don''t have enough to trade for that type of coin!')
	  else if (amount_to > bank[typ_to]) then
	    msg_print('The bank doesn''t have enough of that kind of coin!')
	  else if (money[typ_from] < amount_from) then
	    msg_print('You don''t have enough of that coin!')
          else if (inven_weight + coin$weight*(amount_to-amount_from)
		 > weight_limit*100) then
            msg_print('You can''t carry that much weight.')
	  else
	    with py.misc do
	      begin	      
		money[typ_from] := money[typ_from] - amount_from;
		bank[typ_from] := bank[typ_from] + amount_from;
		money[typ_to] := money[typ_to] + amount_to;
		bank[typ_to] := bank[typ_to] - amount_to;
		inven_weight:=inven_weight+coin$weight*(amount_to-amount_from);
	        msg_print('The money changer hands you your money.');
		display_money;
	      end;
        end;
     end;
    end;

 
procedure parse_command;
  var
        command : char;
  begin
    if get_com( '', command ) then
      case command of
        ctrl_R : display_store;
           'd' : deposit_money;
           'w' : withdraw_money;
	   'c' : change_money;
	   'i' : prt('The insurance shop has gone out of business.',1,1);
	   'p' : if (wizard1) then
		   safe_deposit(true)
		 else
		   prt('The dwarves are still installing it, sorry.',1,1);
	   'r' : if (wizard1) then
		   safe_deposit(false)
		 else
		   prt('The dwarves are still installing it, sorry.',1,1);
        otherwise prt( 'Invalid Command.', 1, 1 );
      end  {case}
    else exit_flag := true;
  end;  {parse_command}
 
begin   { Main loop of bank     }
  coin$name[4]:='gold'; coin$name[5]:='platinum'; coin$name[6]:='mithril';
  exit_flag := false;
  tics := 1;
  case randint(7) of
    1 : shop_owner := 'Milton Drysdale      (tightwad)      Bank';
    2 : shop_owner := 'Mr. Potter           (slumlord)      Bank';
    3 : shop_owner := 'Ebeneezer Scrooge    (broker)        Bank';
    4 : shop_owner := 'Scrooge McDuck       (avian)         Bank';
    5 : shop_owner := 'Andrew Mellon        (treasury)      Bank';
    6 : shop_owner := 'Loony Looby          (pizza!)        Bank';
    7 : shop_owner := 'Ram the Booger Eater (Nosepicker)    Bank';
  end;
  display_store;

  repeat
    parse_command;
    adv_time(false);
    tics := tics + 1;
    check_kickout_time(tics,2);
  until(exit_flag);
  draw_cave;
end;  {enter_bank}






