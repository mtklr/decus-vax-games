[global,PSECT(trade$code)] PROCEDURE enter_trading_post;

CONST

	display_size		= 12;
	acceptable_item_price	= 50;
	profit_from_bid		= 0.05;
	profit_from_sale	= 0.25;
	refund_on_bid		= 1.00 - profit_from_bid;
	refund_on_sale		= 1.00 - profit_from_sale;
	bid_increment_factor	= 1.05;
	take_the_money_and_run	= 0.90;
	bid_wait_days		= 0;
	bid_wait_hours		= 6;
	expire_time_days	= 4;
	expire_time_hours	= 0;


	%INCLUDE	'sys$library:passtatus.pas'

TYPE

	trade_types = ( profit_type, for_sale, cash );

	trade_record_type = RECORD
		time		: QUAD_TYPE;
		CASE trade_type : trade_types OF
			profit_type	:	(
				money		: INTEGER
						);
			for_sale	: 	(
				object		: treasure_type;
				seller		: ssn_type;	{ py.misc.ssn }
				bid_time	: QUAD_TYPE;
				best_bid	: INTEGER;
				best_bidder	: ssn_type
						);
			cash		:	(
				amount		: INTEGER;
				owner		: ssn_type;	{ py.misc.ssn }
						);
		END;

	inven_record = RECORD
		data	: trade_record_type;
		next	: ^inven_record;
		prev	: ^inven_record;
	END;

	inven_ptr = ^inven_record;

	trade_file_type = FILE of trade_record_type;
VAR

	exit_flag, entered	: BOOLEAN;
	sales			: trade_file_type;
	inv			: inven_ptr;
	cur_top			: inven_ptr;
	blegga			: inven_ptr;
	cur_display		: ARRAY [1..display_size] OF inven_ptr;
	cur_display_size	: INTEGER;
	shop_owner		: vtype;
	profits			: trade_record_type;
	full_ssn		: ssn_type;
	tics			: integer;


PROCEDURE open_trade_file;

	[EXTERNAL] FUNCTION net_open	(
			VAR	FAB	: FAB$TYPE;
			VAR	RAB	: RAB$TYPE;
			VAR	F	: trade_file_type
					) : INTEGER;
		EXTERN;

	BEGIN

	  msg_print ( 'You knock on the door to the Trading Post. . . ' ) ;
	  put_qio;
	  CASE randint(4) OF
1 : shop_owner := 'Ollie North          (arms)                Trading Post';
2 : shop_owner := 'Uncle Sam            (wasp)                Trading Post';
3 : shop_owner := 'Jimmy Hoffa          (missing link)        Trading Post';
4 : shop_owner := 'Gary Hart            (presidential)        Trading Post';
	  END;
	  OPEN (sales, FILE_NAME:=moria_trd, HISTORY:=OLD, SHARING:=NONE,
		ERROR:=CONTINUE);
	  if (py.misc.max_exp < 30+randint(30)) then
	    begin
		msg_print('"Hmmmm...we don''t need no novice adventurers hanging around here..."');
		msg_print('"Now GET LOST!!!"');
		msg_print('A couple of huge fighters appear from behind a curtain...');
		take_hit(damroll('2d6'),'some burly barbarians.');
		msg_print('They heave you unceremoniously outside.');
		exit_flag := TRUE;
	    end
	  else IF (STATUS(sales) <> 0) THEN
	    BEGIN
	      IF wizard1 AND ((STATUS(sales) = PAS$K_FILNOTFOU) or
			      (status(sales) = pas$k_recleninc)) THEN
		BEGIN
		  priv_switch(0);
		  OPEN( sales, FILE_NAME:=moria_trd,
			HISTORY:=NEW, SHARING:=NONE, ERROR:=CONTINUE);
		  IF (STATUS(sales) = 0) THEN
		    BEGIN
		      msg_print('Created '+moria_trd);
		      CLOSE( sales, ERROR:=CONTINUE );
		      exit_flag := TRUE;
		    END
		  ELSE
		    BEGIN
		      msg_print('Couldn''t create '+moria_trd);
		      exit_flag := TRUE;
		    END
		END
	      ELSE
		BEGIN
		  IF (STATUS(sales) = PAS$K_FILNOTFOU) THEN
		    msg_print( 'and the doors are locked.  ' +
			       'Only a moria wizard can open them.' )
		  ELSE
		    msg_print( 'but the storekeeper is helping someone else.' );
		  exit_flag := TRUE;
		END;
	    END
	END;

PROCEDURE display_gold;
	VAR
		out_val		: vtype;
	BEGIN
		WRITEV( out_val, 'Gold Remaining : ', py.misc.money[total$]:1);
		prt( out_val, 19, 18 );
	END;

PROCEDURE display_commands;
	BEGIN
prt('You may:',21,1);
prt(' p) Bid on an item.             <space> browse store''s inventory.',22,1);
prt(' s) Put an item up for bid.     i) Inventory and Equipment Lists.',23,1);
prt('^Z) Exit from Building.        ^R) Redraw the screen.',		24,1);
	END;


PROCEDURE read_inv;

	VAR

		item		: inven_ptr;
		first		: BOOLEAN;

	BEGIN

	  RESET( sales );
	  first := TRUE;
	  inv := NIL;
	  cur_top := NIL;
	  profits.trade_type := profit_type;
	  profits.money := 0;
	  WHILE NOT EOF( sales ) DO
	    BEGIN
	      NEW( item );
	      READ( sales, item^.data, ERROR:=continue );
	      IF ( status(sales) > 0 ) THEN IF uw$id THEN
		BEGIN
		  WRITEV( out_val, 'Error #', status(sales):1,
			' reading inventory.',
			'Please report (via MAIL) to MAX::GAMES' );
		  msg_print( out_val );
		  msg_print( '' );
		END;
	      IF( item^.data.trade_type = profit_type ) THEN
		begin
		  profits.money := item^.data.money;
		  dispose(item);
		end
	      ELSE IF( first ) THEN
		BEGIN
		  item^.prev := NIL;
		  inv := item;
		  cur_top := item;
		  first := FALSE;
		END
	      ELSE
		BEGIN
	          cur_top^.next := item;
		  item^.prev := cur_top;
	          cur_top := item;
		END
	    END;
	  IF cur_top <> NIL THEN cur_top^.next := NIL;
	  cur_top := inv;

	END;

procedure clear_display; forward;

PROCEDURE write_inv;

	VAR

		out_val		: vtype;
		dead, item	: inven_ptr;

	BEGIN

	  REWRITE( sales );
	  WRITE( sales, profits, ERROR:=CONTINUE );
	  item := inv;
	  inv := nil;
	  cur_top := nil;
	  blegga := nil;
	  clear_display;
	  WHILE( item <> NIL ) DO
	    BEGIN
	      WRITE( sales, item^.data, ERROR:=CONTINUE );
	      IF ( status(sales) > 0 ) THEN IF uw$id THEN
		BEGIN
		  WRITEV( out_val, 'Error #', status(sales):1,
			' writing inventory.',
			'Please report (via MAIL) to MAX::GAMES.' );
		  msg_print( out_val );
		  msg_print( '' );
		END;
	      dead := item;
	      item := item^.next;
	      dead^.next := nil;
	      if item <> nil then item^.prev := nil;
	      DISPOSE( dead );
	    END;

	END;

PROCEDURE display_inv( start : inven_ptr );

	VAR

		count, old_display_size	: INTEGER;
		out_val1, out_val2	: vtype;

	BEGIN
	  old_display_size := cur_display_size;
	  count := 0;
	  WHILE ( start <> NIL ) and ( count < display_size ) DO
	    BEGIN
	      IF ( start^.data.trade_type = for_sale ) THEN
		BEGIN
		  count := count + 1;
		  IF cur_display[count] <> start THEN
		    BEGIN
		      cur_display[count] := start;
		      inven_temp^.data := start^.data.object;
		      objdes( out_val1, inven_temp, true );
		      WRITEV( out_val2, chr(96+count), ') ', out_val1 );
		      prt( out_val2, count+5, 1 );
		      WRITEV( out_val2, start^.data.best_bid );
		      prt( out_val2, count+5, 60 );
		      IF wizard2 THEN
			BEGIN
			  WRITEV( out_val2, item_value( start^.data.object ):9,
				error := continue );
			  prt( out_val2, count+5, 71 );
			END
		      ELSE IF ( start^.data.seller = py.misc.ssn ) THEN
			prt( 'your sale!', count+5, 71 )
		      ELSE IF ( start^.data.best_bidder = py.misc.ssn ) THEN
		        prt( 'your bid!', count+5, 71 );
                    END;
		END;
	      start := start^.next;
	    END;
	  cur_display_size := count;
	  WHILE old_display_size > cur_display_size DO
	    BEGIN
	      erase_line( old_display_size+5, 1 );
	      cur_display[old_display_size] := NIL;
	      old_display_size := old_display_size - 1;
	    END;
	  IF (start = NIL)
	    THEN blegga := inv
	    ELSE blegga := start
	END;

PROCEDURE clear_display;

	VAR

		index		: INTEGER;

	BEGIN
		cur_display_size := 0;
		FOR index := 1 TO display_size DO cur_display[index] := NIL;
	END;

PROCEDURE display_store;

	BEGIN

		clear( 1, 1 );
		prt( shop_owner,	4, 10);
		prt( '   Item',		5, 1);
		prt( 'Top bid',		5, 63 );
		IF wizard2 THEN prt( 'Value', 5, 75 );
		display_gold;
		display_commands;
		clear_display;
		display_inv(cur_top);

	END;

FUNCTION find_money_order( owner : ssn_type; var item : inven_ptr ) : BOOLEAN;

	VAR

		looking		: BOOLEAN;

	BEGIN
	  looking := TRUE;
	  item := inv;
	  WHILE looking DO
	    IF item = NIL
	      THEN looking := FALSE
	      ELSE IF ( item^.data.trade_type = cash ) AND
		      ( item^.data.owner = owner )
		      THEN looking := FALSE
		      ELSE item := item^.next;
	  find_money_order := item <> NIL;
	END;

PROCEDURE send_money	(
		owner	: ssn_type;
		amount	: INTEGER
			);
	VAR

		item		: inven_ptr;

	BEGIN
	  IF find_money_order( owner, item ) THEN
	    item^.data.amount := item^.data.amount + amount
	  ELSE BEGIN
	    NEW( item );
	    item^.prev := NIL;
	    item^.next := inv;
	    item^.data.trade_type := cash;
	    item^.data.owner := owner;
	    item^.data.amount := amount;
	    inv^.prev := item;
	    inv := item;
	  END;
	  SYS$GETTIM( item^.data.time );
	END;

PROCEDURE made_profit( amount : INTEGER );
	BEGIN
{ Try to trap so there isn't INTEGER overflow }
	  IF MAXINT - profits.money < amount THEN
	     profits.money := MAXINT
	  ELSE
	     profits.money := profits.money + amount;
	END;

PROCEDURE delete_item( VAR item : inven_ptr );

	VAR

		next			: inven_ptr;

	BEGIN
	  next := item^.next;
	  IF item^.prev <> NIL
	    THEN item^.prev^.next := next
	    ELSE IF inv = item
		 THEN inv := next
		 ELSE IF uw$id
		      THEN BEGIN
			  msg_print( 'Something truly bizarre happened in delete_item.' );
			  msg_print( 'Please report (via MAIL) to MAX::GAMES.  Thanks.' );
			  msg_print( '' );
			END;
	  IF next <> NIL THEN next^.prev := item^.prev;
	  IF cur_top = item THEN cur_top := next;
	  item^.prev := nil;
	  item^.next := nil;
	  DISPOSE( item );
	  item := next;
	END;

PROCEDURE deliver;

	VAR

		weight_changed, gold_changed	: BOOLEAN;
 		item, next			: inven_ptr;
		temp_ptr			: treas_ptr;
		out_val1, out_val2		: vtype;
		redisplay			: boolean;

	FUNCTION enough_time		(
			sale_time	: QUAD_TYPE;
			waiting_days	: INTEGER;
			waiting_hours	: INTEGER
					) : BOOLEAN;

		VAR

			out_val1, out_val2		: vtype;
			current_time, delta_time	: QUAD_TYPE;
			time				: time_type;

		[external] PROCEDURE sub_quadtime(
				a, b, c : [REFERENCE] QUAD_TYPE
						); extern;

		BEGIN
		  SYS$GETTIM( current_time );
		  sub_quadtime( current_time, sale_time, delta_time );
		  SYS$NUMTIM( time, delta_time );
		  enough_time := (time.days > waiting_days) or
				 ((time.days = waiting_days) and
				  (time.hours >= waiting_hours));
		END;

	BEGIN
	  weight_changed := FALSE;
	  gold_changed := FALSE;
	  redisplay := false;
	  item := inv;
	  WHILE (NOT exit_flag) AND (item <> NIL) DO BEGIN
            IF( enough_time( item^.data.time, expire_time_days,
			     expire_time_hours ) )
	    THEN
	      BEGIN
		IF ( item^.data.trade_type = for_sale ) THEN
		  BEGIN
		    send_money( item^.data.seller, ROUND( item_value(
			item^.data.object ) * refund_on_sale ) );
		    made_profit( ROUND( item_value( item^.data.object ) *
			profit_from_sale ) );
		    redisplay := true;
		  END;
		delete_item( item );
	      END
	    ELSE IF	( item^.data.trade_type = for_sale ) THEN BEGIN
	      IF	( item^.data.best_bidder = py.misc.ssn ) AND
			( enough_time( item^.data.time, bid_wait_days,
				       bid_wait_hours ) ) THEN
	        BEGIN
		  IF (item^.data.best_bid <
			ROUND(	take_the_money_and_run *
				item_value( item^.data.object ) ) )
		  THEN

{	The best bidder bid less than 90% of the value of the object, so
	the storekeeper will bid 5% more than the best_bidder, sell the
	object to a "store", and make a nice profit.			}

		    BEGIN
		      send_money( item^.data.best_bidder,
			ROUND(	refund_on_bid * item^.data.best_bid ) );
		      item^.data.best_bid :=
			ROUND(	item^.data.best_bid * bid_increment_factor *
				refund_on_sale );
		      send_money( item^.data.seller,
			ROUND(	refund_on_sale * item^.data.best_bid ) );
		      made_profit(item_value(item^.data.object) -
				item^.data.best_bid );
		      redisplay := true;
		      delete_item( item );
		    END
		  ELSE
		    BEGIN
		      msg_print( 'Hmm, you''re supposed to get something.' );
		      inven_temp^.data := item^.data.object;
		      IF (inven_check_num AND inven_check_weight) THEN
			BEGIN
			  temp_ptr := inven_carry;
			  msg_print( 'You are now the proud owner of' );
			  objdes( out_val1, temp_ptr, true );
			  msg_print( out_val1 + '.' );
			  send_money( item^.data.seller,
				ROUND( refund_on_sale * item^.data.best_bid ) );
			  made_profit( ROUND(	profit_from_sale *
						item^.data.best_bid ) );
			  delete_item( item );
			  redisplay := true;
			  weight_changed := TRUE;
			END
		      ELSE
			BEGIN
			  msg_print( 'The shopkeeper had something to give you, but' );
			  msg_print( 'you couldn''t carry it.  Come back when you can.' );
			  exit_flag := TRUE;
			END;
		  END;
	        END
	      ELSE item := item^.next END
	    ELSE item := item^.next;
	  END;
	  WHILE find_money_order( py.misc.ssn, item ) DO
	    BEGIN
	      add_money(item^.data.amount*gold$value);
	      WRITEV( out_val2, 'The shopkeeper gave you ', item^.data.amount:1,
			' gold pieces.' );
	      msg_print( out_val2 );
	      delete_item( item );
	      gold_changed := TRUE;
	    END;
	  IF exit_flag THEN
	    BEGIN
	      IF weight_changed THEN prt_weight;
	      IF gold_changed THEN prt_gold;
	    END
	  ELSE
	    BEGIN
	      if redisplay then cur_top := inv;
	      IF gold_changed OR weight_changed THEN msg_print( ' ' );
	    END;
	END;

	{ Get the ID of a store item and return it's value	-RAK-	}
[psect(store$code)] function get_store_item(
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

PROCEDURE dump( filename : vtype );

	VAR

		dump	: TEXT;
		item	: inven_ptr;
		out_val	: vtype;

	BEGIN
	  OPEN( dump, FILE_NAME:=filename, ERROR:=CONTINUE );
	  IF STATUS(dump) = 0 THEN
	    BEGIN
	      if filename <> 'NL:' then msg_print('Dumping to '+filename);
	      REWRITE(dump);
	      item := inv;
 	      WHILE item <> NIL DO
		WITH item^.data DO BEGIN
		  CASE item^.data.trade_type OF
		    for_sale :
		      BEGIN
			writeln( dump, 'for sale:' );
			SYS$ASCTIM( out_val.length, out_val.body, time, );
			writeln( dump, '  time:        ', out_val );
			inven_temp^.data := object;
			objdes( out_val, inven_temp, true );
			writeln( dump, '  object:      ', out_val );
			writeln( dump, '  seller:      ', seller );
			SYS$ASCTIM( out_val.length, out_val.body, bid_time, );
			writeln( dump, '  bid time:    ', out_val );
			writeln( dump, '  best bid:    ', best_bid:1 );
			writeln( dump, '  best bidder: ', best_bidder );
		      END;
		    cash :
		      BEGIN
			writeln( dump, 'cash:' );
			SYS$ASCTIM( out_val.length, out_val.body, time, );
			writeln( dump, '  time:   ', out_val );
			writeln( dump, '  amount: ', amount:1 );
			writeln( dump, '  owner:  ', owner );
		      END;
		  END;
		  item := item^.next;
		END;
	      CLOSE( dump )
	    END
	  ELSE
	    msg_print( 'Error opening TRADE.DUMP' );
	  if (filename <> 'NL:') then msg_print( '' );
	END;

PROCEDURE bid;

	VAR

		offer,to_bank,which		: INTEGER;
		item				: inven_ptr;
		flag				: boolean;

	BEGIN
	  IF (cur_display_size > 0) THEN
	  IF get_store_item( which, 'Which one?', 1, cur_display_size ) THEN
	    BEGIN
	      msg_print( 'How much do you offer? ' );
	      IF NOT get_string( out_val, 1, 24, 40) THEN erase_line( 1, 1 )
	      ELSE
		BEGIN
		  READV( out_val, offer, ERROR:=CONTINUE );
		  IF offer <= (	cur_display[which]^.data.best_bid *
				bid_increment_factor ) THEN
		    msg_print('You''ll have to do better than that!')
		  ELSE
		    begin
		      flag := false;
		      if (py.misc.money[total$] >= offer) then
			begin
			  subtract_money(offer*gold$value,true);
			  flag := true;
			end
		      else
			begin
			  to_bank := offer - py.misc.money[total$];
			  flag := send_page(to_bank);
			end;
		      if (flag) then begin
		      item := cur_display[which];
		      if item^.data.best_bid > 0 THEN
			BEGIN
			  send_money(item^.data.best_bidder,
				     ROUND(refund_on_bid * item^.data.best_bid) );
			  dump('NL:');
			  made_profit(ROUND(profit_from_bid *
				      item^.data.best_bid ) );
			END;
		      item^.data.best_bidder := py.misc.ssn;
		      item^.data.best_bid := offer;
		      SYS$GETTIM( item^.data.bid_time );
		      cur_display[which] := NIL;
		      item := nil;
		      deliver;
		      display_inv( cur_top );
		      display_gold;
		      end;
		    END;
		END;
	    END;
	END;

PROCEDURE sell;

	VAR

		i1				: INTEGER;
		item_ptr			: treas_ptr;
		redraw				: BOOLEAN;
		item				: inven_ptr;
		response			: vtype;
		wgt				: integer;
		temp_ptr			: treas_ptr;

	BEGIN
	  redraw := FALSE;
	  response := '';
	  change_all_ok_stats(true,true);
	  IF get_item(item_ptr,'Which one? ',redraw,inven_ctr,trash_char,false) THEN
	    BEGIN
	      wgt := 0;
	      temp_ptr := item_ptr^.next;
	      if (uand(item_ptr^.data.flags2,holding_bit) <> 0) then
		begin
		  while ((temp_ptr <> nil) and (temp_ptr^.is_in)) do
		  begin
		    wgt := wgt + temp_ptr^.data.weight * temp_ptr^.data.number;
		    temp_ptr := temp_ptr^.next;
		  end;
		end;
	      IF ( index( item_ptr^.data.name, '|' ) > 0 ) OR
		 ( index( item_ptr^.data.name, '^' ) > 0 ) THEN
		  response := 'I can''t sell that!  Identify it first!'
	      else if (wgt <> 0) then
		response := 'Hey that bag is full of items! Empty it first.'
	      else if (item_ptr^.is_in) then
		response := 'You can''t sell an item *IN* a bag of holding.'
	      ELSE IF	item_value( item_ptr^.data ) <
			acceptable_item_price THEN
		  response := 'What is THAT?  I won''t have that in my shop!'
	      ELSE
		BEGIN
		  NEW( item );
		  item^.next := inv;
		  item^.prev := NIL;
		  item^.data.trade_type := for_sale;
		  item^.data.seller := py.misc.ssn;
		  item^.data.object := item_ptr^.data;
		  item^.data.object.number := 1;
		  item^.data.best_bid := 0;
		  SYS$GETTIM( item^.data.time );
		  if (inv <> nil) then inv^.prev := item;
		  inv := item;
		  cur_top := inv;
		  inven_weight := inven_weight - item_ptr^.data.weight;
		  item_ptr^.data.number := item_ptr^.data.number - 1;
		  if item_ptr^.data.number <= 0 then
		    delete_inven_item(item_ptr);
		  response := 'Remember to come pick up your cash when it sells.';
	        END;
	    END;
	  IF redraw
	    THEN display_store
	    ELSE display_inv( cur_top );
	  msg_print( response );
	END;

PROCEDURE parse_command;

	VAR

		command			: CHAR;
		com_val,which		: INTEGER;
		out_val			: vtype;
		ssn			: ssn_type;
		item			: inven_ptr;

	BEGIN
	  IF get_com( '', command ) THEN
	    BEGIN
	      com_val := ORD( command );
	      CASE com_val OF
{ctrl-d}	4	: IF wizard2 THEN
			    BEGIN
			      IF (cur_display_size > 0) THEN
			      IF get_store_item( which, 'Delete which one?',
					1, cur_display_size ) THEN
				BEGIN
				  IF get_com( 'Refund money? (Y/N)', command ) THEN
				    CASE command OF
				      'y', 'Y'	: WITH cur_display[which]^.data
					DO BEGIN
					  send_money( best_bidder, ROUND(
						refund_on_bid * best_bid ) );
					  made_profit( ROUND( profit_from_bid *
						best_bid ) );
					  send_money( seller, ROUND( item_value(
						object ) * refund_on_sale ) );
					  made_profit( -ROUND( item_value(
						object ) * refund_on_sale ) );
					END;
				      OTHERWISE ;
				    END;
				  delete_item( cur_display[which] );
				  cur_display[which] := NIL;
				  display_inv( cur_top );
				END;
			    END;
{ctrl-e}	5	: IF wizard2 THEN dump( 'TRADE.DUMP' );
{ctrl-i}	9	: IF wizard2 THEN
			    BEGIN
			      IF (cur_display_size > 0) THEN
			      IF get_store_item( which, 'Info on which?',
					1, cur_display_size ) THEN
				WITH cur_display[which]^.data DO BEGIN
				  erase_line(  8+6, 1 );
				  erase_line(  9+6, 1 );
				  erase_line( 10+6, 1 );
				  erase_line( 11+6, 1 );
				  erase_line( 12+6, 1 );
				  SYS$ASCTIM( out_val.length, out_val.body,
					time, );
				  prt( 'Sale time : ' + out_val, 9+6, 1 );
				  WRITEV( out_val, item_value( object ):1 );
				  prt( 'Item value : ' + out_val, 9+6, 60 );
				  prt( 'Seller : ' + seller, 10+6, 1 );
				  prt( 'Bidder : ' + best_bidder, 11+6, 1 );
				  msg_print( 'Press <space> to continue' );
				  msg_print( '' );
				  cur_display_size := 12;
				  cur_display[ 8] := NIL;
				  cur_display[ 9] := NIL;
				  cur_display[10] := NIL;
				  cur_display[11] := NIL;
				  cur_display[12] := NIL;
				  display_inv( cur_top );
				END;
			    END;
{ctrl-p}	16	: IF wizard2 THEN
			    BEGIN
			      WRITEV( out_val, 'Profits made to date: ',
				profits.money:1 );
			      msg_print( out_val );
			    END;
{ctrl-r}	18	: display_store;
		32	: BEGIN
			    IF cur_top = blegga THEN
			      prt( 'Entire inventory is displayed.', 1, 1 )
			    ELSE
			      BEGIN
				cur_top := blegga;
				display_inv(cur_top);
			      END;
			  END;
		101	: IF inven_command( 'e', trash_ptr, '') THEN display_store;
		105	: IF inven_command( 'i', trash_ptr,'') THEN display_store;
		116	: IF inven_command( 't', trash_ptr,'') THEN display_store;
		119	: IF inven_command( 'w', trash_ptr,'') THEN display_store;
		120	: IF inven_command( 'x', trash_ptr,'') THEN display_store;
		112     : IF NOT (py.misc.cheated or total_winner) THEN bid;
		115     : IF NOT (py.misc.cheated or total_winner) THEN sell;
		OTHERWISE prt( 'Invalid Command.', 1, 1 );
	      END;
	    END
	  ELSE exit_flag := TRUE;
	
	END;

BEGIN
  tics := 1;
  exit_flag := FALSE;
  entered := FALSE;
  open_trade_file;
  IF NOT exit_flag THEN
    BEGIN
      full_ssn := py.misc.ssn; py.misc.ssn[70] := ' ';
      read_inv;
      deliver;
      IF NOT exit_flag THEN
	BEGIN
	  display_store;
	  entered := TRUE;
	  WHILE NOT exit_flag DO
	    begin
	      parse_command;
	      adv_time(false);
	      tics := tics + 1;
	      check_kickout_time(tics,2);
	    end;
	END;
      write_inv;
      py.misc.ssn := full_ssn;
      msg_print( 'The storekeeper says "Come again. . ."' ); put_qio;
      CLOSE( sales, ERROR:=CONTINUE );
      IF entered THEN draw_cave;
    END;

END;
