C
C  COMLINK.FOR
C
C  Ray Renteria
C  RR02026@SWTEXAS    ACM_CSA@SWTEXAS
C  Southwest Texas State University
C  (512) 396 - 7216
C
C  Contains:
C
C    CLOSE_LINK     Close communications link.  Empty transfer file of mbxnam.
C    LEFT_JUSTIFY   Left justify a character string.
C    LOOK_AT_FILE   Opens main xfer file to exchange mailbox names with opponent
C    MESSAGE_2      Displays a message when a successful file-open has occured
C    PAUSE_1        Displays an error message when primary file can't be opened.
C    SETUP_COMLINK  Exchanges mailbox names with opponent.
C

      SUBROUTINE   SETUP_COMLINK
      CHARACTER*42 LINE
      EXTERNAL     ABORT_GAME, HELP_ROUTINE
   1  FORMAT( '+', A12, 1X, A12, 1X, A15 )
      INCLUDE 'BATTLE.INC'
      INCLUDE '($SSDEF)'
      IIBAD_MAILBOX = 0
   2  CALL LOOK_AT_FILE
      IF ( WERE_FIRST ) THEN
         CALL SET_WRITE_ATTENTION
         CALL MESSAGE( 'Your challenge has been made, sir.'//
     _                 '  Waiting for an opponent. . .' )

         WAITING_FOR_COMLINK = .TRUE.
         CALL GET_THEIR_INFO
         WAITING_FOR_COMLINK = .FALSE.

         II = INDEX( THEIR.MBX_NAME, ':' )
         CALL ASSIGN_CHANNEL( THEIR.MBX_NAME(1:II) )
         II = ILN( THEIR.UIC )
         IJ = ILN( THEIR.NICKNAME )
         CALL MESSAGE( 'You have a challenger sir! It is '//
     _                 THEIR.UIC(1:II)//'!!' )


      ELSE
         CALL SET_WRITE_ATTENTION
         II = INDEX( THEIR.MBX_NAME, ':' )
         STATUS=SYS$ASSIGN(THEIR.MBX_NAME(1:II),THEIR.MBX_CHAN,,)
         IF ( STATUS .NE. SS$_NORMAL ) THEN
                IIBAD_MAILBOX = IIBAD_MAILBOX + 1
                IF ( IIBAD_MAILBOX .GT. 3 ) THEN
                     CALL MESSAGE('Sir, there seems to be a problem'//
     _                            ' initiating a communications' )
                     CALL MESSAGE('link.  We will have to abort. Pr'//
     _                            'ess any key to exit the game.' )
                     IIJ = INKEY()
                     CALL CANCELLED_THE_GAME
                ENDIF
                GOTO 2
         ENDIF

         WRITE ( LINE, 1 ) OUR.MBX_NAME, OUR.UIC, OUR.NICKNAME

         CALL WRITE_TO_MAILBOX_RAW( LINE )

         II = ILN( THEIR.UIC )
         IJ = ILN( THEIR.NICKNAME )
         CALL MESSAGE( 'Your opponent is '//THEIR.UIC(1:II)//
     _                 ', ('//THEIR.NICKNAME(1:IJ)//').' )

      ENDIF

      CALL CONTROL( 'A', ABORT_GAME   )
      CALL CONTROL( 'H', HELP_ROUTINE )
      RETURN
      END

      SUBROUTINE    LOOK_AT_FILE
      INCLUDE       'BATTLE.INC'
      CHARACTER*100  MASTER_FILE
   1  FORMAT( 1X, A12, 1X, A12, 1X, A15 )
      II     = ILN( IMAGE_DEFAULT_DIR )
      IJ     = ILN( CURR_NODE )
      ICOUNT = 0

      MASTER_FILE = IMAGE_DEFAULT_DIR(1:II)//
     _              'BATTLESHIP_'          //
     _              CURR_NODE(1:IJ)        //
     _              '.DAT'


      THEIR.MBX_NAME = ' '
  19  OPEN( FILE=MASTER_FILE, STATUS='OLD', UNIT=20, ERR=21 )
      CALL MESSAGE_2( ICOUNT )

      READ( 20, 1, END=20 ) THEIR.MBX_NAME, THEIR.UIC, THEIR.NICKNAME
      CALL LEFT_JUSTIFY( THEIR.MBX_NAME )
      CALL LEFT_JUSTIFY( THEIR.UIC      )

  20  IF ( THEIR.MBX_NAME(1:1) .EQ. ' ' ) THEN
           REWIND(20)
           WRITE( 20, 1 ) OUR.MBX_NAME, OUR.UIC, OUR.NICKNAME
           WERE_FIRST = .TRUE.

      ELSE
           REWIND(20)
           WRITE( 20, 1 ) ' ', ' ', ' '
           WERE_FIRST = .FALSE.

      ENDIF
      CLOSE(20)
      RETURN  

  21  ICOUNT = ICOUNT + 1
      CALL PAUSE_1( ICOUNT )
      GOTO 19

      END

      SUBROUTINE LEFT_JUSTIFY( STRING )
      CHARACTER*(*) STRING
      II = LEN( STRING )
      IJ = 1
      DO WHILE(( STRING(IJ:IJ) .EQ. ' ' ) .AND. ( IJ .LT. II ))
          IJ = IJ + 1
      END DO
      STRING(1:) = STRING(IJ:)
      RETURN
      END

      SUBROUTINE PAUSE_1( ICOUNT )
      IF     ( ICOUNT .EQ. 1 ) THEN
         CALL MESSAGE( 'Could not open primary datafile, sir!' )
         CALL LIB$WAIT( 1.0 )
         CALL MESSAGE( 'Trying again. . .' )
         CALL LIB$WAIT( 0.2 )

      ELSEIF ( ICOUNT .EQ. 2 ) THEN
         CALL MESSAGE( 'Sir! We still can''t get it open!' )
         CALL LIB$WAIT( 1.0 )
         CALL MESSAGE( 'We''re going to attempt it again, sir!')
         CALL LIB$WAIT( 0.2 )

      ELSEIF ( ICOUNT .EQ. 3 ) THEN
            CALL MESSAGE( 'We''re still trying to pry it open!' )
            
      ELSE
         CALL MESSAGE( 'Sir, I regret to inform you that after '//
     _                    'all our efforts, ' )
         CALL MESSAGE( 'we could not open the primary comlink.' )
         CALL EXIT
      ENDIF
      RETURN
      END


      SUBROUTINE MESSAGE_2( ICOUNT )
      IF ( ICOUNT .EQ. 1 ) THEN
          CALL MESSAGE( 'GOT IT, SIR! We opened the data file!' )
      ELSEIF( ICOUNT .EQ. 2 ) THEN
          CALL MESSAGE( 'Sir!  The data file gave way, we''re in!')
      ELSEIF( ICOUNT .EQ. 3 ) THEN
          CALL MESSAGE( 'IT''S A MIRACLE! WE''VE PENETATED!' )
      ENDIF
      RETURN
      END


      SUBROUTINE CLOSE_LINK
      INCLUDE 'BATTLE.INC'
      CALL SMG$DISABLE_BROADCAST_TRAPPING( PASTEID )
      CALL SYS$DELMBX(%DESCR('BATTLE$MBX'))
      CALL SMG$DELETE_PASTEBOARD( PASTEID )
      CALL EXIT
      END

