[INHERIT ('MORIA.ENV','SYS$SHARE:STARLET')]

MODULE net_open;

TYPE

	trade_types = ( profit_type, for_sale, cash );

	trade_record_type = RECORD
		time		: quad_type;
		CASE trade_type : trade_types OF
			profit_type	:	(
				money		: INTEGER
						);
			for_sale	: 	(
				object		: treasure_type;
				seller		: ssn_type;
				bid_time	: quad_type;
				best_bid	: INTEGER;
				best_bidder	: ssn_type
						);
			cash		:	(
				amount		: INTEGER;
				owner		: ssn_type;
						);
		END;

	trade_file_type = FILE OF trade_record_type;

[GLOBAL,PSECT(trade$code)] FUNCTION net_open	(
			VAR	FAB	: FAB$TYPE;
			VAR	RAB	: RAB$TYPE;
			VAR	F	: trade_file_type
					) : INTEGER;
	VAR

		status		: INTEGER;

	BEGIN

		FAB.FAB$V_SQO := FALSE;
		status := $OPEN (FAB);
		IF ODD (status) THEN status := $CONNECT (RAB);
		net_open := status;

	END;

END.
