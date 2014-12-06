C
C  SYSTEM.FOR
C
C  Ray Renteria
C  RR02026@SWTEXAS    ACM_CSA@SWTEXAS
C  Southwest Texas State University
C  (512) 396 - 7216
C
C  Contains:
C
C    ASSIGN_CHANNEL              Assigns a channel to a specified device
C    CONTROL                     Set's an AST for specified control code
C    CREATE_MAILBOX              Create a temporary mailbox
C    DISABLE_CONTROL             Traps ^C and ^Y (has problems with F6)
C    ESC_7                       Set cursor with no <CR>
C    ESC_8                       Reset cursor with no <CR>
C    FILL_VARIABLE               Reads the contents of a string received via mbx
C    GET_JOB_PROCESS_INFORMATION Gets job process information of current process
C    GET_JPI                     Clean call to LIB$GET_JPI
C    GET_JPIL                    Same, except returns a longword.
C    GET_THEIR_INFO              Reads their information through mailbox channel
C    HIT                         Updates when a hit has been made
C    LOWER                       Converts a single character to lower case
C    PURGE_TYPE_AHEAD            Empties out the current type-ahead buffer
C    READ_MAILBOX                AST procedure to read and respond to mbx data.
C    SET_WRITE_ATTENTION         Sets a write attention on the tmpmbx
C    STATUS_CHECK                Performs a 'IF(.NOT.STATUS)CALL LIB$SIGNAL...
C    TRNLNM                      Returns the translation of a logical name.
C    UPPER                       Converts a single character to upper case.
C    WRITE_SYSOUTPUT_RAW         Writes text to your screen. No <CR> ($qio)
C    WRITE_TO_MAILBOX            Writes to your opponent's mailbox with a code.
C    WRITE_TO_MAILBOX_RAW        Writes to your opponent's mailbox w/out a code.
C
      SUBROUTINE    GET_JOB_PROCESS_INFORMATION
      INTEGER       INKEY
      CHARACTER*39  TRNLNM
      INCLUDE       '($JPIDEF)'
      INCLUDE       'BATTLE.INC'

      CALL GET_JPI( JPI$_USERNAME, OUR.UIC , OUR.UIC_LEN       )

      CALL GET_JPI( JPI$_PRCNAM,   OUR.NICKNAME , OUR.NICKNAME_LEN )

      CALL GET_JPI( JPI$_IMAGNAME, CURRENT_IMAGE_NAME , IDUMMY )
      II = INDEX( CURRENT_IMAGE_NAME, ']' )
      IMAGE_DEFAULT_DIR = CURRENT_IMAGE_NAME(1:II)

      CURR_NODE = TRNLNM( 'SYS$NODE', 'LNM$SYSTEM_TABLE' )
      II = INDEX( CURR_NODE, ':' ) - 1
      CURR_NODE(1:) = CURR_NODE(1:II)

      CALL CREATE_MAILBOX
      OUR.MBX_NAME = TRNLNM( 'BATTLE$MBX', 'LNM$TEMPORARY_MAILBOX')

      RETURN
      END


      SUBROUTINE DISABLE_CONTROL
      INTEGER    CTRL_MASK(2)
      EXTERNAL   ABORT_GAME
      COMMON     /SYSTEM_SERVICES/ MULTI_EXEC, INPUT_CHANNEL, 
     _           OUTPUT_CHANNEL
      LOGICAL    MULTI_EXEC/.FALSE./
      INCLUDE    '($IODEF)'

      IF (.NOT.MULTI_EXEC) THEN
         STATUS = SYS$ASSIGN('SYS$INPUT',INPUT_CHANNEL,,,,)
         CALL STATUS_CHECK( STATUS )

         STATUS = SYS$ASSIGN('SYS$OUTPUT',OUTPUT_CHANNEL,,,,)
         CALL STATUS_CHECK( STATUS )

         MULTI_EXEC = .TRUE.
      ENDIF

      CTRL_MASK(1) = 0
      CTRL_MASK(2) = 33554440

      STATUS = SYS$QIOW(,%VAL(INPUT_CHANNEL),
     _         %VAL(IO$_SETMODE+IO$M_OUTBAND),,,,
     _         ABORT_GAME,CTRL_MASK,,,,)
      CALL STATUS_CHECK( STATUS )

      RETURN
      END



      CHARACTER*(*) FUNCTION TRNLNM( LOGNAME, TABNAME )
      CHARACTER*(*) LOGNAME, TABNAME
      INTEGER       STATUS, SYS$TRNLNM
      CHARACTER*40  TEMPLOGNAME
      INCLUDE       '($LNMDEF)'
      STRUCTURE /ITMLST/
         UNION
            MAP
               INTEGER*2 BUFLEN
               INTEGER*2 CODE
               INTEGER*4 BUFADR
               INTEGER*4 RETLENADR
            END MAP
            MAP
               INTEGER*4 END_LIST
            END MAP
         END UNION
      END STRUCTURE

      RECORD /ITMLST/ LOGICAL_ITMLST(2)
      IIBUFLEN                    = LEN(TRNLNM)
      LOGICAL_ITMLST(1).BUFLEN    = IIBUFLEN
      LOGICAL_ITMLST(1).CODE      = LNM$_STRING
      LOGICAL_ITMLST(1).BUFADR    = %LOC(TEMPLOGNAME)
      LOGICAL_ITMLST(1).RETLENADR = %LOC(II)
      LOGICAL_ITMLST(2).END_LIST  = 0

      STATUS = SYS$TRNLNM(,%DESCR(TABNAME),%DESCR(LOGNAME)
     _         ,,LOGICAL_ITMLST)
      TRNLNM = TEMPLOGNAME
      CALL STATUS_CHECK( STATUS )
      RETURN
      END


      SUBROUTINE  GET_JPI(  CODE, RETVAL , II)
      INTEGER     STATUS, LIB$GETJPI, CODE
      CHARACTER*(*) RETVAL

      STATUS = LIB$GETJPI( CODE,,,,RETVAL, II )
      CALL STATUS_CHECK( STATUS )

      RETURN
      END


      SUBROUTINE  GET_JPIL(  CODE, RETVAL )
      INTEGER     STATUS, LIB$GETJPI, CODE
      REAL        RETVAL

      STATUS = LIB$GETJPI( CODE,,,RETVAL, )
      CALL STATUS_CHECK( STATUS )

      RETURN
      END


      SUBROUTINE  CREATE_MAILBOX
      INTEGER       STATUS
      INTEGER       SYS$CREMBX
      INCLUDE     'BATTLE.INC'

      STATUS = SYS$CREMBX(,%REF(OUR.MBX_CHAN),,,,,
     _         %DESCR('BATTLE$MBX'))
      CALL STATUS_CHECK(STATUS)

      RETURN
      END


      SUBROUTINE ASSIGN_CHANNEL( MAILBOX )
      INTEGER    STATUS
      INTEGER    SYS$ASSIGN
      CHARACTER*(*) MAILBOX
      INCLUDE    'BATTLE.INC'
      STATUS=SYS$ASSIGN(MAILBOX,THEIR.MBX_CHAN,,)
      CALL STATUS_CHECK( STATUS )
      RETURN
      END


      SUBROUTINE  SET_WRITE_ATTENTION
      INTEGER     STATUS,SYS$QIOW
      EXTERNAL    READ_MAILBOX
      INCLUDE     'BATTLE.INC'
      INCLUDE     '($IODEF)'

      STATUS=SYS$QIOW(,%VAL(OUR.MBX_CHAN)  ,
     _      %VAL(IO$_SETMODE+IO$M_WRTATTN) ,,,,
     _      %REF(READ_MAILBOX),OUR.MBX_CHAN,,,,)
      CALL STATUS_CHECK(STATUS)

      RETURN
      END


      SUBROUTINE    WRITE_TO_MAILBOX( TEXT )
      INTEGER       STATUS
      INTEGER       SYS$QIOW
      INTEGER       BUFLEN
      CHARACTER*(*) TEXT, LINE*99
      INCLUDE       'BATTLE.INC'
      INCLUDE       '($IODEF)'
 1    FORMAT( I2,A97 )
      BUFLEN = 99
      WRITE( LINE, 1 ) ILN( TEXT ), TEXT
      STATUS=SYS$QIOW(,%VAL(THEIR.MBX_CHAN), 
     _       %VAL(IO$_WRITEVBLK+IO$M_NOW)
     _       ,,,,%REF(LINE),%VAL(BUFLEN),,,,)
      CALL STATUS_CHECK(STATUS)

      RETURN
      END


      SUBROUTINE    WRITE_TO_MAILBOX_RAW( TEXT )
      INTEGER       STATUS
      INTEGER       SYS$QIOW
      INTEGER       BUFLEN
      CHARACTER*(*) TEXT, LINE*99
      INCLUDE       'BATTLE.INC'
      INCLUDE       '($IODEF)'
      BUFLEN = LEN(TEXT)
 
      STATUS=SYS$QIOW(,%VAL(THEIR.MBX_CHAN), 
     _       %VAL(IO$_WRITEVBLK+IO$M_NOW)
     _       ,,,,%REF(TEXT),%VAL(BUFLEN),,,,)
      CALL STATUS_CHECK(STATUS)

      RETURN
      END

      SUBROUTINE   GET_THEIR_INFO
      INTEGER       STATUS,SYS$QIOW,BUFLEN
      CHARACTER*99 TEXT 
   1  FORMAT( 1X, A12, 1X, A12, 1X, A15 )
      INCLUDE      'BATTLE.INC'
      INCLUDE      '($IODEF)'

      BUFLEN = 99
      TEXT = ' '
      STATUS=SYS$QIOW(,%VAL(OUR.MBX_CHAN),%VAL(IO$_READVBLK),,,,
     _             %REF(TEXT),%VAL(BUFLEN),,,,)
      CALL STATUS_CHECK(STATUS)

      READ( TEXT, 1 ) THEIR.MBX_NAME, THEIR.UIC, THEIR.NICKNAME

      RETURN
      END


      SUBROUTINE   READ_MAILBOX
      INTEGER      STATUS,SYS$QIOW,BUFLEN
      COMMON /SETUP/ ICOMMON_SETUP_ROW, ICOMMON_SETUP_COL
      LOGICAL      HIT
      CHARACTER*1  CH, TCH, LOWER, CCH, UPPER
      CHARACTER*99 TEXT 
      CHARACTER*97 STRING
      INCLUDE      'BATTLE.INC'
      INCLUDE      '($IODEF)'

  1   FORMAT( 1X, A1, I1 )
  2   FORMAT( 1X, I2, I2 )
  3   FORMAT( A1, A1, I1 , I2, I2 )
  4   FORMAT( 1X, A1, I1 , I2, I2 )

      BUFLEN = 99
      STATUS = SYS$QIOW(,%VAL(OUR.MBX_CHAN),
     _             %VAL(IO$_READVBLK+IO$M_NOW),,,,
     _             %REF(TEXT),%VAL(BUFLEN),,,,)
      CALL STATUS_CHECK(STATUS)
      CALL FILL_VARIABLE( STRING, TEXT, II )

C------------------------------------------------------------------
      IF    ( STRING(1:1) .EQ. '=' ) THEN        ! A SENT MESSAGE
          CALL ESC_7
          CALL MESSAGE( STRING(2:II) )
          INSERT_CR = .TRUE.
          CALL ESC_8

C------------------------------------------------------------------
      ELSEIF( STRING(1:1) .EQ. '+' ) THEN        ! THEIR SHIP'S STATUS 
          READ( STRING, 1 ) CH, ISTR
          CALL THEIR_UPDATE( CH, ISTR )


C------------------------------------------------------------------
      ELSEIF( STRING(1:1) .EQ. 'C' ) THEN        ! THEIR CURSOR IS MOVING
          READ( STRING, 2 ) ITHEIR_ROW, ITHEIR_COL
          IF (( .NOT. AT_COMMAND_LINE )  .AND. ( .NOT. IN_HELP ))
     _          CALL SET_CURSOR( ITHEIR_ROW, ITHEIR_COL )


C------------------------------------------------------------------
      ELSEIF( STRING(1:1) .EQ. 'R' ) THEN        ! THEY'VE RESPONDED.
          CALL SYS$WAKE(,OUR.NICKNAME(1:OUR.NICKNAME_LEN))
          

C------------------------------------------------------------------
      ELSEIF( STRING(1:1) .EQ. '-' ) THEN        ! THEY'VE FINISHED SETTING UP
          IF( IM_FINISHED ) THEN   
              CALL SYS$WAKE(,OUR.NICKNAME(1:OUR.NICKNAME_LEN))! WE'VE BEEN WAITING FOR THEM
              THEYRE_FINISHED = .TRUE.
          ELSE
              CALL DISPLAY_WHAT_THEYRE_DOING( 'waiting...           ',
     _             ICOMMON_SETUP_ROW, ICOMMON_SETUP_COL )
              THEYRE_FINISHED = .TRUE.! WE'RE STILL SETTING UP

          ENDIF

C------------------------------------------------------------------
      ELSEIF( STRING(1:1) .EQ. '@' ) THEN        ! WE HIT THEM!
          CALL SYS$SETEF( 1 )
          READ( STRING, 4 ) CH, ISTR, I1, I2
          CALL MESSAGE( '-=* BLAM *=- ...whooOOOOSH! Direct hit, sir!' )
          CH = LOWER(CH)
          CALL WRITE_REV_BOLD( CH, I1, I2 )
          CALL SET_CURSOR( ITHEIR_ROW, ITHEIR_COL )


      ELSEIF( STRING(1:1) .EQ. '#' ) THEN        ! WE MISSED THEM!
          READ( STRING, 4 ) CH, ISTR, I1, I2
          CALL SYS$SETEF( 1 )
          CALL MESSAGE( '*WHOOSH!* Sorry, sir; but the'//
     _                       ' torpedo missed.' )
          CH = LOWER(CH)
          IF (( CH .EQ. '+' ) .OR. ( CH .EQ. '.' )) THEN
               CALL WRITE_BOLD( CH, I1, I2 )

          ELSE
               CALL WRITE_REV_BOLD( CH, I1, I2 )

          ENDIF
          CALL SET_CURSOR( ITHEIR_ROW, ITHEIR_COL )

C-------------------------------------------------------------------------------
      ELSEIF( STRING(1:1) .EQ. 'A' ) THEN
          THEY_ABORTED = .TRUE.
          PLAYING      = .FALSE.
          CALL MESSAGE( 'Your opponent has requested the '//
     _                  'cancellation of the game, sir.' )
          CALL CANCELLED_THE_GAME

C-------------------------------------------------------------------------------
      ELSEIF( STRING(1:1) .EQ. '*' ) THEN
          CALL THEY_WON_THE_GAME


C------------------------------------------------------------------
      ELSEIF( STRING(1:1) .EQ. 'F' ) THEN        ! THEY'VE FIRED!
          READ( STRING, 2 ) IFIRE_ROW, IFIRE_COL
          TCH = M_GRID(IFIRE_ROW-1,((IFIRE_COL-35)/2)-1)

          CALL SET_CURSOR( IOUR_ROW, IOUR_COL )

          IF ( HIT(TCH, ISTR, CCH) ) THEN             !THEY HIT US!

              IF ( ISTR .EQ. 0 ) THEN
                 CALL MESSAGE( 'SIR! One of our ships has been '//
     _                         'destroyed!' )
              ELSE
                 CALL MESSAGE( 'WE''VE BEEN HIT, SIR!' )

              ENDIF

              WRITE( STRING, 3 ) '@',TCH,ISTR,IFIRE_ROW, IFIRE_COL
              CALL OUR_UPDATE( TCH , ISTR )
              TCH = LOWER(TCH)
              M_GRID(IFIRE_ROW-1,((IFIRE_COL-35)/2)-1) = TCH

              CALL WRITE_BOLD( TCH, IFIRE_ROW, IFIRE_COL-35 )
              CALL WRITE_TO_MAILBOX( STRING )   !TELL THEM THEY HIT US

          ELSE                                  ! THEY MISSED US
              M_GRID(IFIRE_ROW-1,((IFIRE_COL-35)/2)-1) = '+'
              CALL WRITE_BOLD( '+', IFIRE_ROW, IFIRE_COL-35 )
              CALL MESSAGE( 'Sir, it is your turn.' )

              WRITE( STRING, 3 ) '#',CCH,ISTR,IFIRE_ROW, IFIRE_COL
              CALL WRITE_TO_MAILBOX( STRING )      ! TELL THEM THEY MISSED US

          ENDIF

          CALL SYS$WAKE(,OUR.NICKNAME(1:OUR.NICKNAME_LEN))! WE'VE BEEN WAITING FOR THEM
          CALL DISPLAY_WHAT_THEYRE_DOING( 'watching our target  ',
     _                 IOUR_ROW, IOUR_COL )
          CALL DISPLAY_WHAT_WERE_DOING  ( 'aiming to fire       ',
     _                 IOUR_ROW, IOUR_COL )

          THEIR_TURN = .FALSE.

      ENDIF

      CALL SET_WRITE_ATTENTION

      RETURN
      END



      CHARACTER*1 FUNCTION LOWER( CH )
      CHARACTER*1 CH
      II = ICHAR( CH ) 
      IF (II .GE. 65 .AND. II .LE. 90) II = II + 32
      LOWER = CHAR(II)
      RETURN
      END
      

      CHARACTER*1 FUNCTION UPPER( CH )
      CHARACTER*1 CH
      II = ICHAR( CH ) 
      IF (II .GE. 65 .AND. II .LE. 90) II = II - 32
      UPPER = CHAR(II)
      RETURN
      END
      

      LOGICAL FUNCTION HIT( CH, II , CCH )
      CHARACTER*1 CH, CCH
      INCLUDE 'BATTLE.INC'
      INT = ICHAR(CH)

      IF ( CH .EQ. '.' ) THEN
           HIT = .FALSE.
           CCH = '+'
           RETURN

      ELSEIF (INT .GE. 97 .AND. INT .LE. 122) THEN
          HIT = .FALSE.
          CCH = CH
          RETURN

      ELSE
           IF    ( CH .EQ. 'B' ) THEN
               OUR.BATTLESHIP = OUR.BATTLESHIP- 1
               II  = OUR.BATTLESHIP
               HIT = .TRUE.

           ELSEIF( CH .EQ. 'A' ) THEN
               OUR.CARRIER    = OUR.CARRIER   - 1
               II  = OUR.CARRIER
               HIT = .TRUE.

           ELSEIF( CH .EQ. 'D' ) THEN
               OUR.DESTROYER  = OUR.DESTROYER - 1
               II  = OUR.DESTROYER
               HIT = .TRUE.

           ELSEIF( CH .EQ. 'C' ) THEN
               OUR.CRUISER    = OUR.CRUISER   - 1
               II  = OUR.CRUISER
               HIT = .TRUE.

           ELSEIF( CH .EQ. 'S' ) THEN
               OUR.SUBMARINE  = OUR.SUBMARINE - 1
               II  = OUR.SUBMARINE
               HIT = .TRUE.

           ELSEIF( CH .EQ. 'P' ) THEN
               OUR.PT_BOAT    = OUR.PT_BOAT   - 1
               II  = OUR.PT_BOAT
               HIT = .TRUE.

           ELSE
               CCH = CH
               HIT = .FALSE.

           ENDIF

      ENDIF
      RETURN
      END

      SUBROUTINE FILL_VARIABLE( STRING, TEXT, II )
   1  FORMAT( I2, A97 )
      CHARACTER*99 TEXT
      CHARACTER*97  STRING
      READ( TEXT, 1 ) II,STRING
      CALL LEFT_JUSTIFY( STRING )
      RETURN
      END


      SUBROUTINE    WRITE_SYSOUTPUT_RAW( TEXT )
      CHARACTER*(*) TEXT
      INTEGER       STATUS, SYS$QIOW, SYS$ASSIGN, OUTPUT_CHANNEL, BUFLEN
      COMMON     /SYSTEM_SERVICES/ MULTI_EXEC, INPUT_CHANNEL, 
     _           OUTPUT_CHANNEL
      LOGICAL    MULTI_EXEC/.FALSE./
      INCLUDE       'BATTLE.INC'
      INCLUDE    '($IODEF)'
      BUFLEN = LEN(TEXT)

      IF (.NOT.MULTI_EXEC) THEN
         STATUS = SYS$ASSIGN('SYS$INPUT',INPUT_CHANNEL,,,,)
         CALL STATUS_CHECK( STATUS )

         STATUS = SYS$ASSIGN('SYS$OUTPUT',OUTPUT_CHANNEL,,,,)
         CALL STATUS_CHECK( STATUS )
         MULTI_EXEC = .TRUE.
      ENDIF

      STATUS=SYS$QIOW(,%VAL(OUTPUT_CHANNEL),%VAL(IO$_WRITEVBLK+IO$M_NOW)
     _       ,,,,%REF(TEXT),%VAL(BUFLEN),,,,)
      CALL STATUS_CHECK( STATUS )

      RETURN
      END


      SUBROUTINE PURGE_TYPE_AHEAD
      INTEGER     STATUS, SYS$QIOW, SYS$ASSIGN, OUTPUT_CHANNEL
      COMMON     /SYSTEM_SERVICES/ MULTI_EXEC, INPUT_CHANNEL, 
     _           OUTPUT_CHANNEL
      LOGICAL    MULTI_EXEC/.FALSE./
      INCLUDE    '($IODEF)'

      IF (.NOT.MULTI_EXEC) THEN
         STATUS = SYS$ASSIGN('SYS$INPUT',INPUT_CHANNEL,,,,)
         CALL STATUS_CHECK( STATUS )

         STATUS = SYS$ASSIGN('SYS$OUTPUT',OUTPUT_CHANNEL,,,,)
         CALL STATUS_CHECK( STATUS )
         MULTI_EXEC = .TRUE.
      ENDIF

      STATUS = SYS$QIOW(,%VAL(INPUT_CHANNEL),
     _               %VAL(IO$_READVBLK+IO$M_PURGE),,,,,,,,,)
      CALL STATUS_CHECK( STATUS )

      END


      SUBROUTINE    STATUS_CHECK( STATUS )
      INTEGER       STATUS
      CHARACTER*100 MSG
      INCLUDE '($SSDEF)'

      IF (.NOT.STATUS)  THEN
           CALL SYS$GETMSG( %VAL(STATUS), IMSG_LEN , MSG, 
     _                          %VAL(1), )
           CALL MESSAGE( 'Error: '//MSG(1:IMSG_LEN) )
      ENDIF

      RETURN
      END


      SUBROUTINE ESC_7
      CHARACTER*1 ESC/27/
      CALL WRITE_SYSOUTPUT_RAW( ESC//'7' )
      RETURN
      END

      SUBROUTINE ESC_8
      CHARACTER*1 ESC/27/
      CALL WRITE_SYSOUTPUT_RAW( ESC//'8' )
      RETURN
      END


	SUBROUTINE CONTROL(CHARACTER,ROUTINE)

	IMPLICIT INTEGER (A-Z)

	PARAMETER ( IO$_SETMODE  = '23'X )
	PARAMETER ( IO$M_OUTBAND = '400'X )

	CHARACTER*(*) CHARACTER
	CHARACTER*1 C
	INTEGER MASK(2)
	INTEGER*2 CHAN,IOSB(4)
	EXTERNAL ROUTINE

	DATA MASK / 2*0 /

	C = CHARACTER

	IF (LEN(CHARACTER).NE.1 .OR. C.EQ.'C' .OR. C.EQ.'Y'
	1	.OR. C.LT.'A' .OR. C.GT.'Z') CALL EXIT('10000004'X)

	MASK(2) = ISHFT(1,ICHAR(C)-ICHAR('A')+1)

	STATUS = SYS$ASSIGN('TT',CHAN,,)	! Must assign new channel for
						! 	 each call to CONTROL
	IF (.NOT.STATUS) CALL LIB$STOP(%VAL(STATUS))

	STATUS = SYS$QIOW(,%VAL(CHAN),%VAL(IO$_SETMODE+IO$M_OUTBAND),
	1					IOSB,,,ROUTINE,MASK,,,,)

	IF (.NOT.STATUS) CALL LIB$STOP(%VAL(STATUS))

	IF (.NOT.IOSB(1)) CALL LIB$STOP(%VAL(IOSB(1)))

	END


