[global,psect(insure$code)] procedure buy_insurance;

  var
	exit_flag	: boolean;
	shop_owner	: vtype;
	out_val		: vtype;
	tics		: integer;

  procedure display_gold;
    var
	out_val	: vtype;
    begin
      writev(out_val,'Gold remaining : ',py.misc.money[total$]:1);
      prt(out_val,19,18);
    end;

  procedure display_commands;
    begin
      prt('You may:',21,1);
      prt(' i) Insure an item.          a) Insure all items.',22,1);
      prt(' e) Insure all equipment.    p) Insure person.',23,1);
      prt('^Z) Exit from building.     ^R) Redraw the screen.',24,1);
    end;

  procedure display_store;
    begin
      clear(1,1);
      prt(shop_owner,4,10);
      prt('(Protects character against most system failures.)',7,15);
      display_commands;
      display_gold;
    end;

  procedure insure_all_items;
    var
	tot_cost,temp,to_bank	: integer;
	ptr			: treas_ptr;
	flag			: boolean;
	out			: string;
    begin
      tot_cost := 0;
      ptr := inventory_list;
      while (ptr <> nil) do
	begin
	  if (uand(insured_bit,ptr^.data.flags2) = 0) then
	    begin
	      temp := trunc(abs(ptr^.data.cost * ptr^.data.number) / 40);
	      if (temp < (mithril$value div 10)) then temp := (mithril$value div 10);
	      tot_cost := tot_cost + temp;
	    end;
	  ptr := ptr^.next;
	end;
      if (tot_cost > 0) then
	begin
	  flag := false;
	  writev(out,'Do you wish to pay '+cost_str(tot_cost)+'?');
	  if (get_yes_no(out)) then
	    if ((py.misc.money[total$] * gold$value) >= tot_cost) then
	      begin
	        subtract_money(tot_cost,true);
	        flag := true;
	      end
	    else
	      msg_print('Get some more cash, you homo!');
	  if (flag) then
	    begin
	      ptr := inventory_list;
	      while (ptr <> nil) do
		begin
		  ptr^.data.flags2 := uor(ptr^.data.flags2,insured_bit);
		  ptr := ptr^.next;
		end;
	      display_gold;
	      msg_print('Your inventory is now insured');
	    end;
	end
      else
	msg_print('You have no inventory that needs to be insured.');
    end;

  procedure insure_item;
    var
	ptr			: treas_ptr;
	count,temp,to_bank	: integer;
	redraw,flag		: boolean;
	out			: string;
    begin
      count := 0;
      change_all_ok_stats(false,false);
      ptr := inventory_list;
      while (ptr <> nil) do
	begin
	  if (uand(ptr^.data.flags2,insured_bit) = 0) then
	    begin
	      ptr^.ok := true;
	      count := count + 1;
	    end;
	  ptr := ptr^.next;
	end;
      if (count > 0) then
       begin
	if (get_item(ptr,'Insure which item?',redraw,count,trash_char,false)) then
	  begin
	    temp := trunc(abs(ptr^.data.cost * ptr^.data.number) / 40);
	    if (temp < (mithril$value div 10)) then temp := (mithril$value div 10);
	    flag := false;
	    writev(out,'Do you wish to pay '+cost_str(temp)+'?');
	    if (get_yes_no(out)) then
	      if ((py.misc.money[total$] * gold$value) >= temp) then
	        begin
		  subtract_money(temp,true);
		  flag := true;
	        end
	      else
		msg_print('Why don''t you try again when you have more cash?');
	    if (flag) then
	      begin
		ptr^.data.flags2 := uor(ptr^.data.flags2,insured_bit);
		display_store;
		objdes(out_val,ptr,true);
		if (ptr^.data.number > 1) then
		  msg_print('Your '+out_val+' are now insured')
		else
		  msg_print('Your '+out_val+' is now insured');
	      end;
	  end
	else
	  display_store;
       end
	else
	  msg_print('None of your items need insurance');
    end;

	{ Returns the rate to rape the character at for insurance,
	  based on the number of times they have been restored in
	  the past.						-DMF-	}
	{ Change this after seeing how bad ppl get screwed		}
function death_adj : real;
  var
	temp		: real;
  begin
    with py.misc do
      begin
	premium := exp;
	if (premium < 100) then premium := 100;
	temp := 100 * sqrt(premium) + premium * deaths;
	premium := trunc(temp);
	death_adj := temp;
      end;
  end;

  procedure insure_person;
    var
	tot_cost,to_bank	: integer;
	flag			: boolean;
	out			: string;
        f1                      : text;
    begin
      if (py.flags.insured) then
	msg_print('Your person is already insured.')
      else if (py.misc.deaths>7) then
        msg_print('You are deemed a security risk.  We will not insure you.')
	else begin
	  tot_cost := trunc(death_adj);
	  if (tot_cost < (2*mithril$value)) then tot_cost := (2*mithril$value);
	  flag := false;
	  writev(out,'Do you wish to pay '+cost_str(tot_cost)+'?');
	  if (get_yes_no(out)) then
	    if ((py.misc.money[total$] * gold$value) >= tot_cost) then
	      begin
	        subtract_money(tot_cost,true);
	        flag := true;
	      end
	    else
	      msg_print('Nope, not enough cash with you.');
	  if (flag) then
	    begin
	      display_gold;
	      py.flags.insured := true;
	      msg_print('Your person is now insured');
	    end;
	end;
    end;

  procedure insure_all_equip;
    var
	i1,tot_cost,temp,to_bank: integer;
	flag			: boolean;
	out			: string;
    begin
      tot_cost := 0;
      for i1 := equipment_min to equip_max - 1 do
	with equipment[i1] do
	  if (tval > 0) then
	    if (uand(insured_bit,flags2) = 0) then
	      begin
		temp := trunc(abs(cost * number) / 40);
		if (temp < (mithril$value div 10)) then temp := (mithril$value div 10);
		tot_cost := tot_cost + temp;
	      end;
      if (tot_cost > 0) then
	begin
	  flag := false;
	  writev(out,'Do you wish to pay '+cost_str(tot_cost)+'?');
	  if (get_yes_no(out)) then
	    if ((py.misc.money[total$] * gold$value) >= tot_cost) then
	      begin
	        subtract_money(tot_cost,true);
	        flag := true;
	      end
	    else
	      msg_print('You don''t have enough money with you.  Maybe you should make a withdrawal.');
	  if (flag) then
	    begin
	      for i1 := equipment_min to equip_max - 1 do
		with equipment[i1] do
		  if (tval > 0) then
		    flags2 := uor(flags2,insured_bit);
	      display_gold;
	      msg_print('Your equipment is now insured');
	    end;
	end
      else
	msg_print('You have no equipment that needs to be insured.');
    end;

  procedure parse_command;
    var
	command		: char;
	com_val, which	: integer;
    begin
      if get_com('',command) then
	begin
	  com_val := ord(command);
	  case com_val of
	     18 : display_store;
	     97 : insure_all_items;
	    105 : if py.flags.insured then insure_item
                else prt('Insure your body first.',1,1);
	    112 : insure_person;
	    101 : if py.flags.insured then insure_all_equip
                else prt('Insure your body first.',1,1);
	    otherwise prt('Invalid Command.',1,1);
	  end;
	end
      else exit_flag := true;
    end;

  begin
    exit_flag := false;
    tics := 1;
    shop_owner := 'Mangy Dragon Flye        (Scum)       Insurance';
    display_store;
    repeat
      parse_command;
      adv_time(false);
      tics := tics + 1;
      check_kickout_time(tics,2);
    until(exit_flag);
  end;










