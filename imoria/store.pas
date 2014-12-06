[inherit('moria.env','dungeon.env')] module store;

	{ Comments vary...					-RAK-	}
	{ Comment one : Finished haggling				}
[global,psect(store$code)] procedure prt_comment1;
      begin
	msg_flag := false;
	case randint(15) of
	  1  : msg_print('Done!');
	  2  : msg_print('Accepted!');
	  3  : msg_print('Fine...');
	  4  : msg_print('Agreed!');
	  5  : msg_print('Ok...');
	  6  : msg_print('Taken!');
	  7  : msg_print('You drive a hard bargain, but taken...');
	  8  : msg_print('You''ll force me bankrupt, but it''s a deal...');
	  9  : msg_print('Sigh...  I''ll take it...');
	 10  : msg_print('My poor sick children may starve, but done!');
	 11  : msg_print('Finally!  I accept...');
	 12  : msg_print('Robbed again...');
	 13  : msg_print('A pleasure to do business with you!');
	 14  : msg_print('My spouse shall skin me, but accepted.');
	 15  : msg_print('Fine! Just be that way!');
	end;
      end;

	{ %A1 is offer, %A2 is asking...		}
[global,psect(store$code)] procedure prt_comment2(offer,asking,final :integer);
      var
	comment				: vtype;
      begin
	if (final > 0) then
	  case randint(3) of
	    1 : comment := '%A2 is my final offer; take it or leave it...';
	    2 : comment := 'I''ll give you no more than %A2.';
	    3 : comment := 'My patience grows thin...  %A2 is final.';
	  end
	else
	  case randint(16) of
	    1 : comment := '%A1 for such a fine item?  HA!  No less than %A2.';
	    2 : comment := '%A1 is an insult!  Try %A2 gold pieces...';
	    3 : comment := '%A1???  Thou would rob my poor starving children?';
	    4 : comment := 'Why I''ll take no less than %A2 gold pieces.';
	    5 : comment := 'Ha!  No less than %A2 gold pieces.';
	    6 : comment := 'Thou blackheart!  No less than %A2 gold pieces.';
	    7 : comment := '%A1 is far too little, how about %A2?';
	    8 : comment := 'I paid more than %A1 for it myself, try %A2.';
	    9 : comment := '%A1?  Are you mad???  How about %A2 gold pieces?';
	   10 : comment := 'As scrap this would bring %A1.  Try %A2 in gold.';
	   11 : comment := 'May fleas of a 1000 orcs molest you.  I want %A2.';
	   12 : comment := 'My mother you can get for %A1, this costs %A2.';
	   13 : comment := 'May your chickens grow lips.  I want %A2 in gold!';
	   14 : comment := 'Sell this for such a pittance.  Give me %A2 gold.';
	   15 : comment := 'May the Balrog find you tasty!  %A2 gold pieces?';
	   16 : comment := 'Your mother was a Troll!  %A2 or I''ll tell...';
	  end;
	insert_num(comment,'%A1',offer,false);
	insert_num(comment,'%A2',asking,false);
	msg_print(comment);
      end;

[global,psect(store$code)] procedure prt_comment3(offer,asking,final :integer);
      var
	comment				: vtype;
      begin
	if (final > 0) then
	  case randint(3) of
	    1 : comment := 'I''ll pay no more than %A1; take it or leave it.';
	    2 : comment := 'You''ll get no more than %A1 from me...';
	    3 : comment := '%A1 and that''s final.';
	  end
	else
	  case randint(15) of
	    1 : comment := '%A2 for that piece of junk?  No more than %A1';
	    2 : comment := 'For %A2 I could own ten of those.  Try %A1.';
	    3 : comment := '%A2?  NEVER!  %A1 is more like it...';
	    4 : comment :='Let''s be reasonable... How about %A1 gold pieces?';
	    5 : comment := '%A1 gold for that junk, no more...';
	    6 : comment := '%A1 gold pieces and be thankful for it!';
	    7 : comment := '%A1 gold pieces and not a copper more...';
	    8 : comment := '%A2 gold?  HA!  %A1 is more like it...';
	    9 : comment := 'Try about %A1 gold...';
	   10 : comment := 'I wouldn''t pay %A2 for your children, try %A1.';
	   11 : comment := '*CHOKE* For that!?  Let''s say %A1.';
	   12 : comment := 'How about %A1.';
	   13 : comment := 'That looks war surplus!  Say %A1 gold.';
	   14 : comment := 'I''ll buy it as scrap for %A1.';
	   15 : comment := '%A2 is too much, let us say %A1 gold.';
	  end;
	insert_num(comment,'%A1',offer,false);
	insert_num(comment,'%A2',asking,false);
	msg_print(comment);
      end;

	{ Kick 'da bum out...					-RAK-	}
[global,psect(store$code)] procedure prt_comment4;
      begin
	msg_flag := false;
	case randint(5) of
	  1 :	begin
		  msg_print('ENOUGH!  Thou hath abused me once too often!');
		  msg_print('Out of my place!');
		  msg_print(' ');
		end;
	  2 :	begin
		  msg_print('THAT DOES IT!  You shall waste my time no more!');
		  msg_print('out... Out... OUT!!!');
		  msg_print(' ');
		end;
	  3 :	begin
		  msg_print('This is getting no where...  I''m going home!');
		  msg_print('Come back tomorrow...');
		  msg_print(' ');
		end;
	  4 :	begin
		  msg_print('BAH!  No more shall you insult me!');
		  msg_print('Leave my place...  Begone!');
		  msg_print(' ');
		end;
	  5 :	begin
		  msg_print('Begone!  I have had enough abuse for one day.');
		  msg_print('Come back when thou art richer...');
		  msg_print(' ');
		end;
	end;
	msg_flag := false;
      end;

[global,psect(store$code)] procedure prt_comment5;
      begin
	case randint(10) of
	  1  :	msg_print('You will have to do better than that!');
	  2  :	msg_print('That''s an insult!');
	  3  :	msg_print('Do you wish to do business or not?');
	  4  :	msg_print('Hah!  Try again...');
	  5  :	msg_print('Ridiculous!');
	  6  :	msg_print('You''ve got to be kidding!');
	  7  :	msg_print('You better be kidding!!');
	  8  :	msg_print('You try my patience.');
	  9  :	msg_print('I don''t hear you.');
	 10  :	msg_print('Hmmm, nice weather we''re having...');
	end;
      end;


[global,psect(store$code)] procedure prt_comment6;
      begin
	case randint(5) of
	  1  :	msg_print('I must of heard you wrong...');
	  2  :	msg_print('What was that?');
	  3  :	msg_print('I''m sorry, say that again...');
	  4  :	msg_print('What did you say?');
	  5  :	msg_print('Sorry, what was that again?');
	end;
      end;


	{ Displays the set of commands				-RAK-	}
[global,psect(store$code)] procedure display_commands;
      begin
prt('You may:',21,1);
prt(' p/P) Purchase an item.          <space> browse store''s inventory.',22,1);
prt(' s/S) Sell an item.              i) Inventory and Equipment Lists.',23,1);
prt('  ^Z) Exit from Building.       ^R) Redraw the screen.',24,1);
      end;


	{ Displays the set of commands				-RAK-	}
[global,psect(store$code)] procedure haggle_commands(typ : integer);
      begin
	if (typ = -1) then
	  prt('Specify an asking-price in gold pieces.',22,1)
	else
	  prt('Specify an offer in gold pieces.',22,1);
	prt('^Z) Quit Haggling.',23,1);
	prt('',24,1);
      end;


	{ Displays a store's inventory				-RAK-	}
[global,psect(store$code)] procedure display_inventory(store_num,start : integer);
      var
	i1,i2,stop			: integer;
	out_val1,out_val2		: vtype;
      begin
	with store[store_num] do
	    begin
	      i1 := ((start-1) mod 12);
	      stop := (((start-1) div 12) + 1)*12;
	      if (stop > store_ctr) then stop := store_ctr;
	      while (start <= stop) do
	        begin
		  inven_temp^.data := store_inven[start].sitem;
		  with inven_temp^.data do
		    if ((subval > 255) and (subval < 512)) then
		      number := 1;
		  objdes(out_val1,inven_temp,true);
		  writev(out_val2,chr(97+i1),') ',out_val1);
		  prt(out_val2,i1+6,1);
		  if (store_inven[start].scost < 0) then
		    begin {quack}
		      i2 := abs(store_inven[start].scost);
		      i2 := i2 + trunc(i2*chr_adj);
		      writev(out_val2,((i2+gold$value-1) div gold$value):6);
		    end
		  else
		    writev(out_val2,(store_inven[start].scost div gold$value):6,' [Fixed]');
		  prt(out_val2,i1+6,60);
		  i1 := i1 + 1;
		  start := start + 1;
	        end;
	      if (i1 < 12) then
	        for i2 := 1 to (12 - i1 + 1) do
		  prt('',i2+i1+5,1);
	    end;
      end;


	{ Re-displays only a single cost			-RAK-	}
[global,psect(store$code)] procedure display_cost(store_num,pos : integer);
      var
	i1				: integer;
	out_val				: vtype;
      begin
	with store[store_num] do
	  begin
	    i1 := ((pos-1) mod 12);
	    if (store_inven[pos].scost < 0) then
	      begin
		i2 := abs(store_inven[pos].scost);
		i2 := i2 + trunc(i2*chr_adj);
		writev(out_val,(i2 div gold$value):6);
	      end
	    else
	      writev(out_val,(store_inven[pos].scost div gold$value):6,' [Fixed]');
	    prt(out_val,i1+6,60);
	  end;
      end;


	{ Displays players gold					-RAK-	}
[global,psect(store$code)] procedure store_prt_gold;
      var
	out_val			: vtype;
      begin
	writev(out_val,'Gold Remaining : ',py.misc.money[total$]:1);
        prt(out_val,19,18);
      end;


	{ Displays store					-RAK-	}
[global,psect(store$code)] procedure display_store(store_num,cur_top : integer);
      begin
	with store[store_num] do
	  begin
	    clear(1,1);
	    prt(owners[owner].owner_name,4,10);
	    prt('   Item',5,1);
	    prt('Asking Price',5,61);
	    store_prt_gold;
	    display_commands;
	    display_inventory(store_num,cur_top);
	  end;
      end;


	{ Get the ID of a store item and return its value	-RAK-	}
[global,psect(store$code)] function get_store_item(
				var com_val	: integer;
				pmt	 	: vtype;
				i1,i2		: integer) : boolean;
      var
		command 	: char;
		out_val		: vtype;
		flag		: boolean;
      begin
	com_val := 0;
	flag := true;
	writev(out_val,'(Items ',chr(i1+96),'-',chr(i2+96),
					', ^Z to exit) ',pmt);
	while (((com_val < i1) or (com_val > i2)) and (flag)) do
	  begin
	    prt(out_val,1,1);
	    inkey(command);
	    com_val := ord(command);
	    case com_val of
		3,25,26,27 :	flag := false;
		otherwise com_val := com_val - 96;
	    end;
	  end;
	msg_flag := false;
	erase_line(msg_line,msg_line);
	get_store_item := flag;
      end;

[global,psect(store$code)] procedure shut_store(store_num : integer);
    begin
      with store[store_num] do
       begin
	with py.misc.cur_age do
	  begin
	    store_open.year := year;
	    store_open.month := month;
	    store_open.day := day;
	    store_open.hour := hour;
	    store_open.secs := secs;
	  end;
	with store_open do
	  begin
	    day := day + 1;
	    hour := 6;
	    secs := randint(400) - 1;
	      if (day > 28) then
		begin
		  day := 1;
		  month := month + 1;
		    if (month > 13) then
		      begin
			month := 1;
			year := year + 1;
		      end;
		end;
	  end;
       end;
    end;

	{ Increase the insult counter and get pissed if too many -RAK-	}
[global,psect(store$code)] function increase_insults(store_num : integer) : boolean;
      begin
	increase_insults := false;
	with store[store_num] do
	  begin
	    insult_cur := insult_cur + 1;
	    if (insult_cur > owners[owner].insult_max) then
	      begin
		prt_comment4;
		insult_cur := 0;
		change_rep(-5);
		shut_store(store_num);
		increase_insults := true;
	      end;
	  end;
      end;


	{ Decrease insults					-RAK-	}
[global,psect(store$code)] procedure decrease_insults(store_num : integer);
      begin
	with store[store_num] do
	  begin
	    insult_cur := insult_cur - 2;
	    if (insult_cur < 0) then insult_cur := 0;
	  end;
      end;


	{ Have insulted while haggling				-RAK-	}
[global,psect(store$code)] function haggle_insults(store_num : integer) : boolean;
	begin
	  haggle_insults := false;
	  if (increase_insults(store_num)) then
	    haggle_insults := true
	  else
	    prt_comment5;
	end;

[global,psect(store$code)] function receive_offer(
				store_num		: integer;
				comment 		: vtype;
 				var new_offer 		: integer;
				last_offer,factor	: integer) : integer;
	var
		flag				: boolean;

	function get_haggle(comment : vtype; var num : integer) : boolean;
	  var
		i1,clen			: integer;
		out_val			: vtype;
		flag			: boolean;
	  begin
	    flag := true;
	    i1 := 0;
	    clen := length(comment) + 1;
	    repeat
	      msg_print(comment);
	      msg_flag := false;
	      if (not(get_string(out_val,1,clen,40))) then
		begin
	          flag := false;
		  erase_line(msg_line,msg_line);
		end;
	      readv(out_val,i1,error:=continue);
	    until((i1 <> 0) or not(flag));
	    if (flag) then num := i1;
	    get_haggle := flag;
	  end;

	begin
	  receive_offer := 0;
	  flag := false;
	  repeat
	    if (get_haggle(comment,new_offer)) then
	      begin
	        if (new_offer*factor >= last_offer*factor) then 
	          flag := true
	        else if (haggle_insults(store_num)) then
		  begin
		    receive_offer := 2;
		    flag := true;
		  end
	      end
	    else
	      begin
	        receive_offer := 1;
	        flag := true;
	      end;
	  until (flag);
        end;


	{ Haggling routine					-RAK-	}
[global,psect(store$code)] function purchase_haggle(
				store_num	: integer;
				var price	: integer;
				item		: treasure_type;
				blitz		: boolean) : integer;
      var
	max_sell,min_sell,max_buy		: integer;
	cost,cur_ask,final_ask,min_offer	: integer;
	last_offer,new_offer,final_flag,x3	: integer;
	delta					: integer;
	x1,x2					: real;
	min_per,max_per				: real;
	flag,loop_flag				: boolean;
	out_val,comment				: vtype;

      begin
	flag := false;
	purchase_haggle := 0;
	price := 0;
	final_flag := 0;
	msg_flag := false;
	with store[store_num] do
	  with owners[owner] do
	    begin
	      cost := sell_price(store_num,max_sell,min_sell,item);
	      max_sell := max_sell + trunc(max_sell*chr_adj);
	      if (max_sell < 0) then max_sell := 1;
	      min_sell := min_sell + trunc(min_sell*chr_adj);
	      if (min_sell < 0) then min_sell := 1;
	      max_buy  := trunc(cost*(1-max_inflate));
	      min_per  := haggle_per;
	      max_per  := min_per*3.0;
	    end;
	haggle_commands(1);
	cur_ask   := max_sell;
	final_ask := min_sell;
	min_offer := max_buy;
	last_offer := min_offer;
	comment := 'Asking : ';
	if (blitz) then
	  begin
	    delta := (max_sell - min_sell);
	    last_offer := min_sell + (delta div 4);
	    with store[store_num] do
price := last_offer + ((insult_cur * delta) DIV owners[owner].insult_max);
	    comment := 'In a hurry, eh?  It''s yours for a mere ';
	    writev(out_val,comment,price:1);
	    msg_print(out_val);
	    msg_print(' ');
	  end
	else { go ahead and haggle }
	repeat
	  repeat
	    loop_flag := true;
	    writev(out_val,comment,cur_ask:1);
	    put_buffer(out_val,2,1);
	    case receive_offer(store_num,'What do you offer? ',
			     new_offer,last_offer,1) of
	      1 : begin
		    purchase_haggle := 1;
		    flag   := true;
		  end;
	      2 : begin
		    purchase_haggle := 2;
		    flag   := true;
		  end;
	      otherwise if (new_offer > cur_ask) then
			  begin
			    prt_comment6;
			    loop_flag := false;
			  end
		        else if (new_offer = cur_ask) then
	                  begin
			    flag := true;
			    price := new_offer;
			  end;
	    end;
	  until ((flag) or (loop_flag));
	  if (not(flag)) then
	    begin
	      x1 := (new_offer - last_offer)/(cur_ask - last_offer);
	      if (x1 < min_per) then
		begin
		  flag := haggle_insults(store_num);
		  if (flag) then purchase_haggle := 2;
		end
	      else
		begin
		  if (x1 > max_per) then 
		    begin
		      x1 := x1*0.75;
		      if (x1 < max_per) then x1 := max_per;
		    end;
	          x2 := (x1 + (randint(5) - 3)/100.0);
	          x3 := trunc((cur_ask-new_offer)*x2) + 1;
		  cur_ask := cur_ask - x3;
		  if (cur_ask < final_ask) then
		    begin
		      cur_ask := final_ask;
		      comment := 'Final Offer : ';
		      final_flag := final_flag + 1;
		      if (final_flag > 3) then
			begin
			  if (increase_insults(store_num)) then
			    purchase_haggle := 2
			  else
			    purchase_haggle := 1;
			  flag := true;
			end;
		    end
		  else if (new_offer >= cur_ask) then
	            begin
		      flag := true;
		      price := new_offer;
		    end;
		  if (not(flag)) then
		    begin
	              last_offer := new_offer;
		      prt('',2,1);
	              writev(out_val,'Your last offer : ',last_offer:1);
	              put_buffer(out_val,2,40);
		      prt_comment2(last_offer,cur_ask,final_flag);
		    end;
	        end;
	    end;
	until (flag);
	prt('',2,1);
	display_commands;
      end;


	{ Haggling routine					-RAK-	}
	{ Return value shows the result of the haggling:
		0 = Sold, 2 = Aborted, 3 = Owner will not buy }
[global,psect(store$code)] function sell_haggle(
				store_num	: integer;
				var price	: integer;
				item		: treasure_type;
				blitz		: boolean) : integer;
      var
	max_sell,max_buy,min_buy		: integer;
	cost,cur_ask,final_ask,min_offer	: integer;
	last_offer,new_offer,final_flag,x3	: integer;
	max_gold,delta				: integer;
	x1,x2					: real;
	min_per,max_per				: real;
	flag,loop_flag				: boolean;
	comment,out_val				: vtype;
	temp_ptr				: treas_ptr;
	wgt					: integer;

      begin
	flag := false;
	sell_haggle := 0;
	price := 0;
	final_flag := 0;
	msg_flag := false;
	with store[store_num] do
	  begin
	    cost := item_value(item);
	    if (cost < 1) then
	      begin
		sell_haggle := 3;
		flag := true;
	      end
	    else
	      with owners[owner] do
	        begin
		  cost := cost - trunc(cost*chr_adj) -
			  trunc(cost*rgold_adj[owner_race,py.misc.prace]);
		  if (cost < 1) then cost := 1;
	          max_sell := trunc(cost*(1+max_inflate));
	          max_buy  := trunc(cost*(1-max_inflate));
	          min_buy  := trunc(cost*(1-min_inflate));
		  if (min_buy < max_buy) then min_buy := max_buy;
	          min_per  := haggle_per;
	          max_per  := min_per*3.0;
		  max_gold := max_cost;
	        end;
	  end;
	if (blitz) then
	  begin
	    delta := (min_buy - max_buy);
	    last_offer := min_buy - (delta div 7);
	    with store[store_num] do
price := last_offer - ((insult_cur * delta) DIV owners[owner].insult_max);
	    comment := 'Need cash quick?  I''ll pay you ';
	    writev(out_val,comment,price:1);
	    msg_print(out_val);
	    msg_print(' ');
	  end
	else {haggling}
	if (not(flag)) then
	  begin
	    haggle_commands(-1);
	    if (max_buy > max_gold) then
	      begin
		final_flag:= 1;
		comment   := 'Final offer : ';
	        cur_ask   := max_gold;
		final_ask := max_gold;
msg_print('I am sorry, but I have not the money to afford such a fine item.');
msg_print(' ');
	      end
	    else
	      begin
		cur_ask   := max_buy;
	        final_ask := min_buy;
		if (final_ask > max_gold) then
		  final_ask := max_gold;
	        comment := 'Offer : ';
	      end;
	    min_offer := max_sell;
	    last_offer := min_offer;
	    if (cur_ask < 1) then cur_ask := 1;
	    repeat
	      repeat
	        loop_flag := true;
	        writev(out_val,comment,cur_ask:1);
	        put_buffer(out_val,2,1);
	        case receive_offer(store_num,'What price do you ask? ',
				 new_offer,last_offer,-1) of
	          1 : begin
		        sell_haggle := 1;
		        flag   := true;
		      end;
	          2 : begin
		        sell_haggle := 2;
		        flag   := true;
		      end;
	          otherwise if (new_offer < cur_ask) then
	                      begin
				prt_comment6;
				loop_flag := false;
			      end
			    else if (new_offer = cur_ask) then
			      begin
			        flag := true;
			        price := new_offer;
			      end;
	        end;
	      until ((flag) or (loop_flag));
	      if (not(flag)) then
	        begin
		  msg_flag := false;
	          x1 := (last_offer - new_offer)/(last_offer - cur_ask);
	          if (x1 < min_per) then
		    begin
		      flag := haggle_insults(store_num);
		      if (flag) then sell_haggle := 2;
		    end
	          else
		    begin
		      if (x1 > max_per) then 
		        begin
		          x1 := x1*0.75;
		          if (x1 < max_per) then x1 := max_per;
		        end;
	              x2 := (x1 + (randint(5) - 3)/100.0);
	              x3 := trunc((new_offer-cur_ask)*x2) + 1;
		      cur_ask := cur_ask + x3;
		      if (cur_ask > final_ask) then
		        begin
		          cur_ask := final_ask;
		          comment := 'Final Offer : ';
		          final_flag := final_flag + 1;
		          if (final_flag > 3) then
			    begin
			      if (increase_insults(store_num)) then
			        sell_haggle := 2
			      else
			        sell_haggle := 1;
			      flag := true;
			    end;
		        end
		      else if (new_offer <= cur_ask) then
			begin
			  flag := true;
			  price := new_offer;
			end;

		      if (not(flag)) then
		        begin
	                  last_offer := new_offer;
		          prt('',2,1);
	                  writev(out_val,'Your last bid   : ',last_offer:1);
	                  put_buffer(out_val,2,40);
			  prt_comment3(cur_ask,last_offer,final_flag);
		        end;
	            end;
	        end;
	    until (flag);
	    prt('',2,1);
	    display_commands;
	  end;
      end;

{ if not whole_days then actually turns... }
[global,psect(store$code)] procedure spend_time (days_spent : integer;
		place : vtype; whole_days : boolean);

      var
	mornings,time_spent,turns_today : integer;
	regen_percent : real;
	new_screen : boolean;

      procedure reset_flag (VAR flag : integer);
      begin
	if flag > 1 then
	  begin
	    flag := flag - time_spent;
	    if flag < 1 then
	      flag := 1;
	  end;
      end; { reset_flag }

     begin
      with py.misc.cur_age do
       begin
	turns_today := hour*400 + secs;
	if (not whole_days) then
	  begin
	    time_spent := days_spent;
				 {if a 6:00 threshold is passed}
	    new_screen := (turns_today + time_spent + 2400) div 4800 >
		           (turns_today + 2400) div 4800;
	    mornings := (turns_today + time_spent - 2400) div 9600 -
			(turns_today - 2400) div 9600;
	    days_spent := 0;
	  end
	else
	  begin
	    time_spent := day_length * days_spent - turns_today;
	    new_screen := true;
	    mornings := days_spent;
	  end;
	case days_spent of
	    0 : begin
		  secs := secs + time_spent;
		  hour := hour + secs div 400;
		  secs := secs mod 400;
		  add_days(py.misc.cur_age,hour div 24);
		  hour := hour mod 24;
		end;
	    1 : if (hour < 6) then
		  begin
		    msg_print('You spend the remainder of the night '+place);
		    hour := 8;  {why get up before shops open?}
		    secs := randint(400) - 1;
		    time_spent := time_spent - day_length + 400*hour + secs;
		  end
		else 
		  begin
		    msg_print('You spend the night '+place);
		    hour := 8;
		    add_days(py.misc.cur_age,1);
		    secs := randint(400) - 1;
		    time_spent := time_spent + 400*hour + secs;
		  end;
	  7 : begin
		msg_print('You spend the week in the inn.');
		add_days(py.misc.cur_age,7);
		hour := 8 + randint(4);
		secs := randint(400) - 1;
		time_spent := time_spent + 400*hour + secs;
	      end;
	 3 : begin
		msg_print('You spend three days in the inn.');
		add_days(py.misc.cur_age,28+randint(3));
		hour := 8 + randint(4);
		secs := randint(400) - 1;
		time_spent := time_spent + 400*hour + secs;
	      end;
	end;
	put_qio;
	turn := turn + time_spent;
	turn_counter := turn_counter + quest_delay;

	if new_screen then
	  sleep(1);

	with py.flags do
	  begin
	    while (poisoned > 0) and (time_spent > 0) do
	      begin
		poisoned	:= poisoned	- 1;
		time_spent	:= time_spent	- 1;
		case con_adj of
		  -4	: take_hit(4,'poison.');
		  -3,-2	: take_hit(3,'poison.');
		  -1	: take_hit(1,'poison.');
		  0	: take_hit(1,'poison.');
		  1,2,3	: if ((turn mod 2) = 0) then take_hit(1,'poison.');
		  4,5	: if ((turn mod 3) = 0) then take_hit(1,'poison.');
		  6	: if ((turn mod 4) = 0) then take_hit(1,'poison.');
		end;	
		if (poisoned = 0) then
		  begin
		    status := uand(%X'FFFFFFDF',status);
		    msg_print('You feel better.');
		    put_qio;
		  end;
	      end;
	    reset_flag ( blind ) ;
	    reset_flag ( confused ) ;
	    reset_flag ( protection ) ;
	    reset_flag ( fast ) ;
	    reset_flag ( slow ) ;
	    reset_flag ( afraid ) ;
	    reset_flag ( image ) ;
	    reset_flag ( protevil ) ;
	    reset_flag ( invuln ) ;
	    reset_flag ( hero ) ;
	    reset_flag ( shero ) ;
	    reset_flag ( blessed ) ;
	    reset_flag ( resist_heat ) ;
	    reset_flag ( resist_cold	) ;
	    reset_flag ( detect_inv ) ;
	    reset_flag ( word_recall ) ;
	    reset_flag ( tim_infra ) ;
	    reset_flag ( resist_lght ) ;
	    reset_flag ( free_time ) ;
	    reset_flag ( ring_fire ) ;
	    reset_flag ( protmon ) ;
	    reset_flag ( hoarse ) ;
	    reset_flag ( magic_prot ) ;
	    reset_flag ( ring_ice ) ;
	    reset_flag ( temp_stealth ) ;
	    reset_flag ( resist_petri ) ;
	    reset_flag ( blade_ring ) ;
	    case days_spent of
	      0,1 : begin
		      food := food - time_spent;
		      if (food <= player_food_alert) then
			food := player_food_alert + 1;
		    end;
	      otherwise food := player_food_full - 1;
	    end;
	    confuse_monster := false;
	    for i1 := 1 to mornings do
	      store_maint;
	  end;

	with py.misc do
	  begin
	    regen_percent := regen_amount*2*time_spent;
            if regen_percent > 1.00 then regen_percent := 1.00;
	    if (chp < mhp) then regenhp(regen_percent);
	    if (chp > mhp) then chp := mhp;
	    if (cmana < mana) then regenmana(regen_percent);
	    if (cmana > mana) then cmana := mana;
	  end;
	if new_screen then
	  begin
	    moria_flag := true;
	    msg_print('');
	  end;
       end;
     end;

	{ Buy an item from a store				-RAK-	}
[global,psect(store$code)] function store_purchase(
			store_num 	: integer;
			var cur_top 	: integer;
			blitz		: boolean) : boolean;
      var
	i1,item_val,price,i3,to_bank,from_bank	: integer;
	choice					: integer;
	item_new				: treas_ptr;
	save_number				: integer;
	out_val,foo				: vtype;
	flag    				: boolean;
      begin
	store_purchase := false;
	item_new := nil;
	with store[store_num] do
	  begin
	    if (blitz)
	      then foo := 'BLITZ-PURCHASE item? '
	      else foo := 'Purchase which item? ';
		{ i1 = number of objects shown on screen	}
	    if (cur_top = 13) then
	      i1 := store_ctr - 12
	    else if (store_ctr > 12) then
	      i1 := 12
	    else
	      i1 := store_ctr;
	    if (store_ctr < 1) then
	      msg_print('I am currently out of stock.')
		{ Get the item number to be bought		}
	    else  if (get_store_item(item_val,
			{'Which item are you interested in? ',1,i1)) then}
			foo,1,i1)) then
	      begin
		item_val := item_val + cur_top - 1;	{ true item_val	}
		inven_temp^.data := store_inven[item_val].sitem;
		with inven_temp^.data do
		  if ((subval > 255) and (subval < 512)) then
		    begin
		      save_number := number;
		      number := 1;
		    end
		  else
		    save_number := 1;
		if (inven_check_weight or (store_num = 7)) then
		  if (inven_check_num or (store_num = 7)) then
		    begin
		      if (store_inven[item_val].scost > 0) then
			begin
			  price := store_inven[item_val].scost div gold$value;
			  choice := 0;
			end
		      else
	choice := purchase_haggle(store_num,price,inven_temp^.data,blitz);
		      case choice of
			0 : with py.misc do
			      begin
				flag := false;
				if (money[total$] >= price) then
				  begin
				    subtract_money(price*gold$value,true);
				    flag := true;
				  end
				else
				  begin
				    to_bank := price - money[total$];
				    flag := send_page(to_bank);
				  end;
				if (flag) then begin
				prt_comment1;
				decrease_insults(store_num);
				if (store_num = 7)
				  then
				    with store_inven[item_val] do
				      begin
					if (scost < 0) then scost := price * gold$value;
					spend_time(sitem.p1,'at the Inn.',true);
					if (sitem.subval=303) then
					  begin
					    spend_time(600,'eating.',false);
					    msg_print('You eat a leisurely meal of buckwheat cakes and bacon.');
					    py.flags.food := player_food_full;
					    py.flags.status := uand(%X'FFFFFFFC',py.flags.status);
					    msg_print(' ');
					  end;
					store_purchase := true;
				    end
				  else
				    begin
				      store_destroy(store_num,item_val,true);
				      item_new := inven_carry;
				      objdes(out_val,item_new,true);
				      out_val := 'You have ' + out_val;
				      msg_print(out_val);
				      if (cur_top > store_ctr) then
				        begin
				          cur_top := 1;
				          display_inventory(store_num,cur_top);
				        end
				      else
				        with store_inven[item_val] do
				          if (save_number > 1) then
				            begin
					      if (scost < 0) then
					        begin
				                  scost := price * gold$value;
					          display_cost(store_num,item_val);
					        end;
				            end
				          else
				            display_inventory(store_num,item_val);
				      store_prt_gold;
				    end
				  end
			        else
				  begin
				    if (increase_insults(store_num)) then
				      store_purchase := true
				    else
				      begin
					prt_comment1;
					msg_print('Liar!  You have not the gold!');
				      end;
				  end
			      end;
			2 : store_purchase := true;
			otherwise ;
		      end;
		      prt('',2,1);
		    end
		  else
		    prt('You cannot carry that many different items.',1,1)
		else
		  prt('You can not carry that much weight.',1,1);
	      end;
	  end;
      end;


	{ Sell an item to the store				-RAK-	}
[global,psect(store$code)] function store_sell(
		store_num	: integer;
		cur_top		: integer;
		blitz		: boolean) : boolean;
      var
	i1,count			: integer;
	item_ptr			: treas_ptr;
	item_pos,price			: integer;
	redraw				: boolean;
	out_val,foo			: vtype;
      begin
	if (blitz)
	  then foo := 'BLITZ-SELLING item? '
	  else foo := 'Which one? ';
	store_sell := false;
	with store[store_num] do
	  begin
	    redraw := false;
	    if (not(find_range(store_buy[store_num],false,item_ptr,count))) then
	      msg_print('You have nothing the store wishes to buy.')
{	    else if (get_item(item_ptr,'Which one? ',redraw,count,trash_char,false)) then}
	    else if (get_item(item_ptr,foo,redraw,count,trash_char,false)) then
	      begin
		if (redraw) then display_store(store_num,cur_top);
		inven_temp^.data := item_ptr^.data;
		with inven_temp^.data do
		  if ((subval > 255) and (subval < 512)) then
		    number := 1;		{But why????}
		objdes(out_val,inven_temp,true);
		out_val := 'Selling ' +out_val;
		msg_print(out_val);
		msg_print(' ');
		if (inven_temp^.data.tval in store_buy[store_num]) then
		  if (store_check_num(store_num)) then
		      case sell_haggle(store_num,price,inven_temp^.data,blitz) of
		       0 : begin
		            prt_comment1;
			    add_money(price*gold$value);
		            inven_destroy(item_ptr);
		            store_carry(store_num,item_pos);
			    if (item_pos > 0) then
			      if (item_pos < 13) then
			        if (cur_top < 13) then
				  display_inventory(store_num,item_pos)
			        else
				  display_inventory(store_num,cur_top)
			      else if (cur_top > 12) then
			        display_inventory(store_num,item_pos);
			    store_prt_gold;
			  end;
		       2 : store_sell := true;
		       3 : begin
			    msg_print('How dare you!');
			    msg_print('I will not buy that!');
			    store_sell := increase_insults(store_num);
		          end;
		       otherwise ;
		      end
		  else
		    prt('I have not the room in my store to keep it...',1,1)
		else
		  prt('I do not buy such items.',1,1);
	      end
	    else if (redraw) then
	      display_store(store_num,cur_top);
	  end;
      end;


	{ Entering a store					-RAK-	}
[global,psect(store$code)] procedure enter_store(store_num : integer);
      var
	com_val,cur_top,tics		: integer;
	command				: char;
	exit_flag			: boolean;
      begin
	tics := 1;
	with store[store_num] do
	  begin
	    exit_flag := false;
	    cur_top := 1;
	    display_store(store_num,cur_top);
	    repeat
	      if (get_com('',command)) then
		begin
		  msg_flag := false;
		  com_val := ord(command);
		  case com_val of
		    18      : display_store(store_num,cur_top);
		    73	    : begin	{ Selective Inventory	}
				if (inven_command('I',trash_ptr,'')) then
				  display_store(store_num,cur_top);
			      end;
		    32      : begin
				if (cur_top = 1) then
				  if (store_ctr > 12) then
				    begin
				      cur_top := 13;
				      display_inventory(store_num,cur_top);
				    end
				  else
				    prt('Entire inventory is shown.',1,1)
				else
				  begin
				    cur_top := 1;
				    display_inventory(store_num,cur_top);
				  end
			      end;
		    101     : begin	{ Equipment List	}
				if (inven_command('e',trash_ptr,'')) then
				  display_store(store_num,cur_top);
			      end;
		    105     : begin	{ Inventory		}
				if (inven_command('i',trash_ptr,'')) then
				  display_store(store_num,cur_top);
			      end;
		    116     : begin	{ Take off		}
				if (inven_command('t',trash_ptr,'')) then
				  display_store(store_num,cur_top);
			      end;
		    119     : begin	{ Wear			}
				if (inven_command('w',trash_ptr,'')) then
				  display_store(store_num,cur_top);
			      end;
		    120     : begin	{ Switch weapon		}
				if (inven_command('x',trash_ptr,'')) then
				  display_store(store_num,cur_top);
			      end;
		    112     : exit_flag := store_purchase(store_num,cur_top,false);
		     80	    : exit_flag := store_purchase(store_num,cur_top,true);
		    115     : exit_flag := store_sell(store_num,cur_top,false);
		     83	    : exit_flag := store_sell(store_num,cur_top,true);
		    otherwise prt('Invalid Command.',1,1);
		  end;
		end
	      else
		exit_flag := true;
	      adv_time(false);
	      tics := tics + 1;
	      check_kickout_time(tics,2);
	    until(exit_flag);
	    if moria_flag then
	      begin
		clear(1,1);
		prt_stat_block
	      end
	    else
	      draw_cave;
	  end
      end;

	{ Returns the value for any given object		-RAK-	}
[global,psect(store$code)] function item_value(item : treasure_type) : integer;

      function search_list(x1,x2 : integer) : integer;
	var
	  i1,i2		: integer;
	begin
	  i1 := 0;
	  i2 := 0;
	  repeat
	    i1 := i1 + 1;
	    with object_list[i1] do
	      if ((tval = x1) and (subval = x2)) then
		i2 := cost;
	  until ((i1 = max_objects) or (i2 > 0));
	  search_list := i2 div gold$value;
	end;

      begin
	with item do
	  begin
	    item_value := cost div gold$value;
	    if (tval in [bow_crossbow_or_sling,hafted_weapon,pole_arm,
			 sword,dagger,maul,boots,gloves_and_gauntlets,gem_helm,
			 Cloak,helm,shield,hard_armor,soft_armor]) then
	      begin	{ Weapons and armor	}
		if (index(name,'^') > 0) then
		  item_value := search_list(tval,subval)*number
		else if (tval in [bow_crossbow_or_sling,hafted_weapon,
				  pole_arm,sword,dagger,maul]) then
		  begin
		    if (tohit < 0) then
		      item_value := 0
		    else if (todam < 0) then
		      item_value := 0
		    else if (toac < 0) then
		      item_value := 0
		    else
		      item_value := (cost div gold$value +(tohit+todam+toac)*100)*number;
		  end
		else
		  begin
		    if (toac < 0) then
		      item_value := 0
		    else
		      item_value := (cost div gold$value +toac*100)*number;
		  end;
	      end
	    else if (tval in [sling_ammo,bolt,arrow,spike]) then
	      begin	{ Ammo			}
		if (index(name,'^') > 0) then
		  item_value := search_list(tval,1)*number
		else
		  begin
		    if (tohit < 0) then
		      item_value := 0
		    else if (todam < 0) then
		      item_value := 0
		    else if (toac < 0) then
		      item_value := 0
		    else
		      item_value := (cost div gold$value +(tohit+todam+toac)*10)*number;
		  end;
	      end
	    else if (tval in [scroll1,scroll2,potion1,potion2,food]) then
	      begin	{ Potions, Scrolls, and Food	}
		if (index(name,'|') > 0) then
		  case tval of
			scroll1,scroll2	: item_value :=  20;
			potion1,potion2	: item_value :=  20;
			food		: item_value :=   1;
		    otherwise ;
		  end
	      end
	    else if (tval in [amulet,ring]) then
	      begin	{ Rings and amulets	}
		if (index(name,'|') > 0) then
		  case tval of
			amulet	: item_value := 45;
			ring	: item_value := 45;
		    otherwise ;
		  end
		else if (index(name,'^') > 0) then
		  item_value := (cost div gold$value) * ord(cost > 0);
	      end
	    else if (tval in [chime,horn]) then
	      begin	{ Horns and Chimes	}
		if (index(name,'|') > 0) then
		  case tval of
			chime	: item_value := 50;
			horn	: item_value := 80;
			otherwise ;
		  end
		else if (index(name,'^') = 0) then
		  begin
		    item_value := (cost div gold$value) + trunc(cost/cost_adj/20.0)*p1;
		  end;
	      end
	    else if (tval in [staff,rod,wand]) then
	      begin	{ Wands rods, and staffs}
		if (index(name,'|') > 0) then
		  case tval of
			staff	: item_value := 70;
			rod	: item_value := 60;
			wand	: item_value := 50;
		    otherwise ;
		  end
		else if (index(name,'^') = 0) then
		  begin
		    item_value := (cost div gold$value) + trunc(cost/cost_adj/20.0)*p1;
		  end;
	      end
	    else if (tval in [valuable_jewelry,valuable_gems]) then
	      begin       {Gems and jewelry of all types}
		if (index(name,'|') > 0) then
		  case tval of 
			valuable_jewelry  : item_value := 20;
			valuable_gems	  : item_value := 20;
		  otherwise ;
		end
		else if (index(name,'^') = 0) then
		  begin
			item_value := (cost div gold$value);
		  end;
        	end;
	  end;
      end;


	{ Asking price for an item				-RAK-	}
[global,psect(store$code)] function sell_price (snum 	: integer;
			 var max_sell,min_sell 	: integer;
			 item 			: treasure_type
					) : integer;
      var
	i1			: integer;
      begin
	with store[snum] do
	  begin
	    i1 := item_value(item);
	    if (item.cost > 0) then
	      begin
	        i1 := i1 +
		   trunc(i1*rgold_adj[owners[owner].owner_race,py.misc.prace]);
	        if (i1 < 1) then i1 := 1;
	        max_sell := trunc(i1*(1+owners[owner].max_inflate));
	        min_sell := trunc(i1*(1+owners[owner].min_inflate));
	        if (min_sell > max_sell) then min_sell := max_sell;
	        sell_price := i1;
	      end
	    else {quack}
	      begin
		max_sell := 0;
		min_sell := 0;
		sell_price := 0;
	      end;
	  end;
      end;


	{ Check to see if he will be carrying too many objects	-RAK-	}
[global,psect(store$code)] function store_check_num(store_num : integer) : boolean;
      var
	item_num,i1			: integer;
	flag				: boolean;
      begin
	store_check_num := false;
	with store[store_num] do
	  if (store_ctr < store_inven_max) then
	    store_check_num := true
	  else if ((inven_temp^.data.subval > 255) and 
		   (inven_temp^.data.subval < 512)) then
	    for i1 := 1 to store_ctr do
	      with store_inven[i1].sitem do
	        if (tval = inven_temp^.data.tval) then
		  if (subval = inven_temp^.data.subval) then
		    store_check_num := true;
      end;


	{ Add the item in INVEN_MAX to stores inventory.	-RAK-	}
[global,psect(store$code)] procedure store_carry(    store_num : integer;
					  var ipos 	: integer);
      var
	item_num,item_val		: integer;
	typ,subt,icost,dummy		: integer;
	flag				: boolean;

	{ Insert INVEN_MAX at given location	}
      procedure insert(store_num,pos,icost : integer);
        var
		i1	: integer;
        begin
	  with store[store_num] do
	    begin
	      for i1 :=  store_ctr downto pos do
	        store_inven[i1+1] := store_inven[i1];
	      store_inven[pos].sitem := inven_temp^.data;
	      store_inven[pos].scost := -icost * gold$value;
	      store_ctr := store_ctr + 1;
	    end;
        end;

	{ Store_carry routine			}
      begin
	ipos := 0;
	identify(inven_temp^.data);
	unquote(inven_temp^.data.name);
	known1(inven_temp^.data.name);
	known2(inven_temp^.data.name);
	sell_price(store_num,icost,dummy,inven_temp^.data);
	if (icost > 0) then
	  begin
	    with inven_temp^.data do
	      with store[store_num] do
	        begin
	          item_val := 0;
	          item_num := number;
	          flag := false;
	          typ  := tval;
	          subt := subval;
	          repeat
	            item_val := item_val + 1;
	            with store_inven[item_val].sitem do
		      if (typ = tval) then
		        begin
		          if (subt = subval) then{ Adds to other item	}
		            if (subt > 255) then
			      begin
				if (number < 24) then 
				  number := number + item_num;
			        flag := true;
			      end
		        end
		      else if (typ > tval) then
		        begin		{ Insert into list		}
		          insert(store_num,item_val,icost);
		          flag := true;
			  ipos := item_val;
		        end;
	          until ((item_val >= store_ctr) or (flag));
	          if (not(flag)) then	{ Becomes last item in list	}
		    begin
		      insert(store_num,store_ctr+1,icost);
		      ipos := store_ctr;
		    end;
	        end;
	  end;
      end;



	{ Destroy an item in the stores inventory.  Note that if	}
	{ 'one_of' is false, an entire slot is destroyed	-RAK-	}
[global,psect(store$code)] procedure store_destroy(
			store_num,item_val 	: integer; 
			one_of 			: boolean);
      var
		i2 	: integer;
      begin
	with store[store_num] do
	  begin
	    inven_temp^.data := store_inven[item_val].sitem;
	    with store_inven[item_val].sitem do
	      begin
	        if ((number > 1) and (subval < 512) and (one_of))  then
	          begin
	            number := number - 1;
		    inven_temp^.data.number := 1;
	          end
	        else
	          begin
		    for i2 := item_val to store_ctr-1 do
		      store_inven[i2] := store_inven[i2+1];
		    store_inven[store_ctr].sitem := blank_treasure;
		    store_inven[store_ctr].scost := 0;
		    store_ctr := store_ctr - 1;
	          end;
              end
	  end;
      end;



	{ Initializes the stores with owners			-RAK-	}
[global,psect(setup$code)] procedure store_init;
      var
	i1,i2,i3			: integer;
      begin
	i1 := max_owners div max_stores;
	for i2 := 1 to max_stores do
	  with store[i2] do
	    begin
	      owner := max_stores*(randint(i1)-1) + i2;
	      insult_cur := 0;
	      store_open.year := 0;
	      store_open.month := 0;
	      store_open.day := 0;
	      store_open.hour := 0;
	      store_open.secs := 0;
	      store_ctr  := 0;
	      for i3 := 1 to store_inven_max do 
		begin
		  store_inven[i3].sitem := blank_treasure;
		  store_inven[i3].scost := 0;
		end;
	    end;
      end;


	{ Initialize the bank					-DMF-	}
[global,psect(setup$code)] procedure bank_init;
      var
	starting,type_num	: integer;
      begin
	starting := (randint(2000) + 1000) * 1000;
	bank[iron] := starting div 8;
	bank[copper] := starting div 30;
	bank[silver] := starting div 50;
	bank[gold] := starting div 250;
	bank[platinum] := starting div 5000;
	bank[mithril] := starting div 100000;
	bank[total$] := (bank[mithril] * coin$value[mithril] + bank[platinum] *
		coin$value[platinum]) div gold$value + bank[gold];
      end;


	{ Creates an item and inserts it into store's inven	-RAK-	}
[global,psect(store$code)] procedure store_create(store_num : integer);
      var
	i1,tries,cur_pos,dummy			: integer;
      begin
	tries := 0;
	popt(cur_pos);
	with store[store_num] do
	  repeat
	    i1 := store_choice[store_num,randint(store$choices)];
	    t_list[cur_pos] := inventory_init[i1];
	    magic_treasure(cur_pos,obj_town_level);
	    inven_temp^.data := t_list[cur_pos];
	    if (store_check_num(store_num)) then
	      with t_list[cur_pos] do
	        if (cost > 0) then	{ Item must be good	}
		  if (cost < (owners[owner].max_cost * gold$value)) then
		    begin
		      store_carry(store_num,dummy);
		      tries := 10;
		    end;
	    tries := tries + 1;
	  until(tries > 3);
	pusht(cur_pos);
      end;


	{ Initialize and up-keep the store's inventory.		-RAK-	}
[global,psect(store$code)] procedure store_maint;
      var
	i1,i2,dummy		: integer;

      procedure rndcash(var amt : integer; target : integer);
	begin
	  amt := (199*amt+randint(2*target)) div 200;
        end;

      begin
	for i1 := 1 to max_stores do
	  with store[i1] do
	    begin
	      insult_cur := 0;
	      if (store_ctr > store$max_inven) then
	        for i2 := 1 to (store_ctr-store$max_inven+2) do
		  store_destroy(i1,randint(store_ctr),false)
	      else if (store_ctr < store$min_inven) then
		begin
	          for i2 := 1 to (store$min_inven-store_ctr+2) do
		    store_create(i1);
		end
	      else
		begin
		  for i2 := 1 to (1+randint(store$turn_around)) do
		    store_destroy(i1,randint(store_ctr),true);
		  for i2 := 1 to (1+randint(store$turn_around)) do
		    store_create(i1);
		end;
	      if (i1 = 7) then
		begin
		  if (randint(8) = 1) then
		    begin
		      for i2 := 1 to store_ctr do
			store_destroy(i1,i2,false);
		      for i2 := 1 to store$min_inven+2 do
			store_create(i1);
		    end
		end;
	    end;
	rndcash(bank[iron],500000);
	rndcash(bank[copper],200000);
	rndcash(bank[silver],100000);
	rndcash(bank[gold],50000);
	rndcash(bank[platinum],5000);
	rndcash(bank[mithril],1000);
	bank[total$] := (bank[mithril] * mithril$value + bank[platinum] *
		platinum$value) div gold$value + bank[gold];
      end;

End.
