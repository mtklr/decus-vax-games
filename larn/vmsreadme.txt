This is a VMS version of LARN 12.3.  To run it, larndir must be defined as a 
logical name that points to the directory containing the support files 
(LARN.MAZ, LARN.HLP, etc).  Larn looks for LARN.OPT in SYS$LOGIN.  VMS Version 
5.x may be required.

The first entry in the larn.pid file (1000) can be the wizard if the password is
known (same password as in MS-DOS edition; see LARN122.DOC).

The sources have been compiled with termcap.  It will look for the
termcap file either through the logical name "termcap", in the current
directory as "termcap.", or as "sys$library:termcap."   If there is
a symbol or logical called "term" then the value of that will
be used for the terminal, otherwise the value from "terminal" will be
used.

This version includes VMS Keypad support on VT class terminals.  The keypad
keys must be set to application mode (SET TERM/APPLICATION) in order for LARN
to recognise the keys.  It is not necessary to set the KEYPAD option in the
LARN.OPT file.  The key mappings are:

				PF1	PF2	PF3	PF4
							'@'
				KP7	KP8	KP9	KP-
				'y'	'k'	'u'
				KP4	KP5	KP6	KP,
				'h'	'.'	'l'	','
		 ^		KP1	KP2	KP3	KP
		'K'		'b'	'j'	'n'	Enter
	 <	 v	 >	KP0	KP.
	'H'	'J'	'L'	'i'	'.'

Keypad mode occasionally seems flakey, especially on DECTerms.  Until I can
re-work it, this will have to do.  Customization of the keypad is not 
currently supported.  

	Kevin Routley
