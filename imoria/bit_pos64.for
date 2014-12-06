	integer function bit_pos64( high, low )

!-----
!
!	This is the 64-bit version of bit_pos
!
!-----

	integer		bit_pos
	integer		pos
	integer		high, low

	pos = bit_pos( low )
	if( pos.eq.0 ) then
		pos = bit_pos( high )
		if( pos.ne.0 ) pos = pos + 32
	end if
	bit_pos64 = pos
	return

	end
