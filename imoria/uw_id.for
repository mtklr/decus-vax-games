	logical function uw_id

	implicit integer (a-z)

	integer		name_code*2,
	1		name_length*2,
	1		name_addr*4,
	1		ret_addr*4,
	1		end_list*2	/ 0 /
	common	/get_lnm_list/
	1		name_length,
	1		name_code,
	1		name_addr,
	1		ret_addr,
	1		end_list
	common	/net_trade/	remote
	logical*1		remote

	character*10	trans
	integer		length

	include '($lnmdef)'

	name_code = lnm$_string
	name_addr = %loc(trans)
	name_length = len(trans)
	ret_addr = %loc(length)
	status = sys$trnlnm( lnm$m_case_blind,
	1			'LNM$FILE_DEV',
	1			'UW$ID',,
	1			name_length )

	if( .not. status ) then
		uw_id = .false.
	else
		uw_id = .true.
		remote = trans(2:4) .ne. 'MAX'
	end if

	status = sys$trnlnm( lnm$m_case_blind,
	1			'LNM$FILE_DEV',
	1			'SYS$NODE',,
	1			name_length )
	remote = remote .or. ( index( trans, 'CPAC' ) .ne. 0 )

	return

	end

	logical function net_trade

	common	/net_trade/	remote
	logical*1		remote

	net_trade = remote
	return

	end

	logical function already_playing

	common /info/	uaccount, uusername
	common /result/	already computed, answer

	integer*4	who
	integer*4	pid, upid
	character*8	account, uaccount
	character*12	username, uusername
	character*15	prcnam, uprcnam
	character*39	image, uimage
	integer*4	status, state
	integer*2	jpi_list(25)
	common	/jpi/	jpi_list
	integer*4	sys$getjpi
	integer		l
	character*79	line
	integer		l2
	character*79	line2
	logical		already computed /.false./
	logical		answer

	external	ss$_nomoreproc
	external	ss$_nopriv
	external	ss$_suspended

	call setup_jpi( upid, uaccount, uusername, uprcnam, uimage )
	call sys$getjpiw( , , , jpi_list, status, , )

	who = -1
	call setup_jpi( pid, account, username, prcnam, image )
10	call sys$getjpiw( , who, , jpi_list, status, , )
	if( status .eq. %loc( ss$_nomoreproc ) ) goto 80
	if(	status .eq. %loc( ss$_suspended )
	1	.or. status .eq. %loc( ss$_nopriv )
	1	.or. pid .eq. upid
	1	.or. account .ne. uaccount
	1	.or. index( image, '[GM99.' ).eq.0
	1		) goto 10

	answer = .true.
	goto 90

80	answer = .false.

90	already computed = .true.
	already_playing = .false. !answer
	return

	end

	subroutine	setup_jpi( pid, account, username, prcnam, image )

	integer*2	jpi_list(32)
	common	/jpi/	jpi_list

	integer*2	jpi_1length	, jpi_1function
	integer*4	jpi_1buffer	, jpi_1extra
	integer*2	jpi_2length	, jpi_2function
	integer*4	jpi_2buffer	, jpi_2extra
	integer*2	jpi_3length	, jpi_3function
	integer*4	jpi_3buffer	, jpi_3extra

	integer*4	jpi_end

	equivalence	(jpi_list( 1) , jpi_1length   )
	equivalence	(jpi_list( 2) , jpi_1function )
	equivalence	(jpi_list( 3) , jpi_1buffer   )
	equivalence	(jpi_list( 5) , jpi_1extra    )

	equivalence	(jpi_list( 7) , jpi_2length   )
	equivalence	(jpi_list( 8) , jpi_2function )
	equivalence	(jpi_list( 9) , jpi_2buffer   )
	equivalence	(jpi_list(11) , jpi_2extra    )

	equivalence	(jpi_list(13) , jpi_3length   )
	equivalence	(jpi_list(14) , jpi_3function )
	equivalence	(jpi_list(15) , jpi_3buffer   )
	equivalence	(jpi_list(17) , jpi_3extra    )

	equivalence	(jpi_list(19) , jpi_4length   )
	equivalence	(jpi_list(20) , jpi_4function )
	equivalence	(jpi_list(21) , jpi_4buffer   )
	equivalence	(jpi_list(23) , jpi_4extra    )

	equivalence	(jpi_list(25) , jpi_5length   )
	equivalence	(jpi_list(26) , jpi_5function )
	equivalence	(jpi_list(27) , jpi_5buffer   )
	equivalence	(jpi_list(29) , jpi_5extra    )

	equivalence	(jpi_list(31) , jpi_end      )

	external	jpi$_pid
	external	jpi$_account
	external	jpi$_username
	external	jpi$_prcnam
	external	jpi$_imagname

	integer*4	pid
	character*8	account
	character*12	username
	character*15	prcnam
	character*39	image

	jpi_1length   = 4
	jpi_1function = %loc( jpi$_pid      )
	jpi_1buffer   = %loc( pid           )
	jpi_1extra    = 0

	jpi_2length   = 8
	jpi_2function = %loc( jpi$_account  )
	jpi_2buffer   = %loc( account       )
	jpi_2extra    = 0

	jpi_3length   = 12
	jpi_3function = %loc( jpi$_username )
	jpi_3buffer   = %loc( username      )
	jpi_3extra    = 0

	jpi_4length   = 15
	jpi_4function = %loc( jpi$_prcnam )
	jpi_4buffer   = %loc( prcnam      )
	jpi_4extra    = 0

	jpi_5length   = 39
	jpi_5function = %loc( jpi$_imagname )
	jpi_5buffer   = %loc( image         )
	jpi_5extra    = 0

	jpi_end       = 0

	return
	end
