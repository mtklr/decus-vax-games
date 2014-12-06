{ The money changer will change the person's money, taking 5% off the top }
{ and then giving change to the nearest integer value below the actual    }
{ value.                                                                  }

[psect(changer$code)] procedure enter_changer;

var

        exit_flag       : boolean;
        shop_owner      : vtype;
        out_val         : vtype;
        tics            : integer;



  procedure change_some_money;
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
	  coin_stuff(key_in,type_from);
	  key_in := chr(get_money_type('Change to? ',change_flag,true));
	end;
      if change_flag then
        begin
	  coin_stuff(key_in,type_to);
          writev(prompt,'Number of coins to change? (1-',
		money[type_from]:1,'), ^Z to exit : ');
          change_flag := get_entry(prompt,amount_from);
        end;
        if (change_flag) then
	 begin
          amount_to := (amount_from * coin$value[type_from]) div
			coin$value[type_to]; {NO surcharge}
	  if (amount_to = 0) then
	    msg_print('You don''t have enough to trade for that type of coin!')
	  else if (amount_to > bank[type_to]) then
	    msg_print('The bank doesn''t have enough of that kind of coin!')
	  else if (money[type_from] < amount_from) then
	    msg_print('You don''t have enough of that coin!')
          else if (inven_weight + coin$weight*(amount_to-amount_from)
		 > weight_limit*100) then
            msg_print('You can''t carry that much weight.')
	  else
	    with py.misc do
	      begin	      
		money[type_from] := money[type_from] - amount_from;
		bank[type_from] := bank[type_from] + amount_from;
		money[type_to] := money[type_to] + amount_to;
		bank[type_to] := bank[type_to] - amount_to;
		inven_weight:=inven_weight+coin$weight*(amount_to-amount_from);
	        msg_print('The money changer hands you your money.');
            end;
        end;
    end;
  


