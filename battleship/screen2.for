C
C  SCREEN2.FOR
C
C  Ray Renteria
C  RR02026@SWTEXAS    ACM_CSA@SWTEXAS
C  Southwest Texas State University
C  (512) 396 - 7216
C
C  Contains:
C
C    AIM_AND_FIRE               Position cursor on prospective target and fire
C    HELP_ROUTINE               Displays a brief help window
C    HELP_WRITE                 Routine to display text onto the help window
C    WAIT                       Wait while your opponent aims and fires
C    DISPLAY_WHAT_WERE_DOING    Display what we're doing
C    DISPLAY_WHAT_THEYRE_DOING  Display what they're doing
C    SEND_CURSOR                Send your opponent's process your cursor pos.
C    FIRE                       Fire a shot against your opponent
C    MESSAGE                    Displays text at the bottom portion of the scrn.
C    MESSAGE_NOCR               Same as MESSAGE, only with no <CR>
C    ILN                        Returns the length of a string
C    WRITE                      Routine to display text on the general screen.
C    WRITE_REV_BOLD             Same as WRITE with REVERSE and BOLD attributes.
C    WRITE_REV                  Same as WRITE with REVERSE attribute.
C    WRITE_BOLD                 Same as WRITE with BOLD attribute.
C    INKEY                      Inkey function, returns integer code of kystrk.
C    SET_CURSOR                 Sets the cursor on your screen
C    ABORT_GAME                 Clears your screen, shuts down both processes
C    CANCELLED_THE_GAME         Displays exit message (credits)
C    THEY_WON_THE_GAME          Displays a defeat screen
C    THEY_LOST_THE_GAME         Displays a victorious screen
C    NOT_ALLOWED_TO_PLAY        Displays a not-allowed-to-play screen
C    NOT_A_SCHEDULED_TIME       When not scheduled to play <not implemented yet>
C    CENTER_DISP_REV_BOLD       WRITE function for exit screens. REV,BOLD
C    CENTER_DISP_BOLD           WRITE function for exit screens. BOLD
C    CENTER_DISP                WRITE function for exit screens. 
C

       SUBROUTINE AIM_AND_FIRE( II )
       INCLUDE   'BATTLE.INC'
       INTEGER    INKEY, TOUP
       LOGICAL    FIRED
       SAVE

       FIRED = .FALSE.

       DO WHILE( .NOT. FIRED )

         CALL SET_CURSOR ( IOUR_ROW, IOUR_COL )
         CALL SEND_CURSOR( IOUR_ROW, IOUR_COL-35 )

         IF ( II .EQ. 0 ) II = INKEY()
         II = TOUP( II )

         IF      ( II .EQ. 277 ) THEN    ! RIGHT ARROW
            IF ( IOUR_COL .LT. 66 ) THEN
               IOUR_COL = IOUR_COL + 2
            ELSE
               IOUR_COL = 39
            ENDIF

         ELSEIF ( II .EQ. 276 ) THEN     ! LEFT ARROW
            IF ( IOUR_COL .GT. 39 ) THEN
               IOUR_COL = IOUR_COL - 2
            ELSE
               IOUR_COL = 67
            ENDIF

         ELSEIF( II .EQ. 274 ) THEN      ! UP ARROW
            IF ( IOUR_ROW .GT. 2 ) THEN
               IOUR_ROW = IOUR_ROW - 1
            ELSE
               IOUR_ROW = 10
            ENDIF

         ELSEIF( II .EQ. 275 ) THEN      ! DOWN ARROW
            IF ( IOUR_ROW .LT. 10 ) THEN
               IOUR_ROW = IOUR_ROW + 1
            ELSE
               IOUR_ROW = 2
            ENDIF

         ELSEIF(( II .EQ. 32 ) .OR. (II .EQ. 13)) THEN

            FIRED = .TRUE.
            CALL MESSAGE( '*kerbloop* .. whhoooOFFFFSSssss....' )
            CALL FIRE( IOUR_ROW, IOUR_COL )
            CALL SYS$WAITFR( 1 )

         ELSEIF ( II .EQ. 16 ) THEN 
            CALL SPAWN_DCL

         ELSEIF ( II .EQ. 5 ) THEN
            CALL SEND_MESSAGE

         END IF

         II = 0

      END DO

      RETURN
      END


      SUBROUTINE HELP_ROUTINE
      INCLUDE    'BATTLE.INC'
      INTEGER    INKEY
      COMMON /HELP/ HELPID
      INCLUDE    '($SMGDEF)'
      IN_HELP = .TRUE.
      CALL SMG$CREATE_VIRTUAL_DISPLAY( 15, 50, HELPID, SMG$M_BORDER )
      CALL SMG$PASTE_VIRTUAL_DISPLAY( HELPID, PASTEID, 4, 15, )
      CALL SMG$LABEL_BORDER( HELPID, 'HELP' )
      CALL HELP_WRITE( '^W      Refresh screen'           ,1,4 )
      CALL HELP_WRITE( '^A, ^C  Abort, Cancel game'       ,2,4 )
      CALL HELP_WRITE( '^E      Send Message to opponent' ,3,4 )
      CALL HELP_WRITE( '^H      This Screen'              ,4,4 )
      CALL HELP_WRITE( '^P      Spawn to DCL'             ,5,4 )
      CALL HELP_WRITE( '[space] Fires a torpedo',          6,4 )
      CALL HELP_WRITE( 'Setup procedure: Press B,C,A,D,S, or P',7,4)
      CALL HELP_WRITE( 'to begin placing your ship, then use',8,10)
      CALL HELP_WRITE( 'arrows to place it.  ^Z aborts placing of',9,10)
      CALL HELP_WRITE( 'the current ship.',10,10 )
      CALL HELP_WRITE( '...press any key to exit help...',14,9 )
      CALL PURGE_TYPE_AHEAD
      IF ( .NOT. GETTING_INKEY ) II = INKEY()
      CALL SMG$DELETE_VIRTUAL_DISPLAY( HELPID )
      CALL SMG$SET_CURSOR_ABS( DISPID )
      IN_HELP = .FALSE.
      RETURN
      END
      
      SUBROUTINE HELP_WRITE( TEXT, I1, I2 )
      CHARACTER *(*) TEXT
      INCLUDE    'BATTLE.INC'
      INCLUDE    '($SMGDEF)'
      COMMON /HELP/ HELPID
      CALL SMG$PUT_CHARS( HELPID, TEXT, I1, I2 )
      RETURN
      END

      SUBROUTINE WAIT( II )
      INCLUDE    'BATTLE.INC'
      CHARACTER*1 ESC/27/
      INTEGER     INKEY

      DO WHILE ( THEIR_TURN )
         CALL SET_CURSOR( ITHEIR_ROW, ITHEIR_COL )
         II = INKEY()

         IF ( II .EQ. 5 ) THEN
            CALL SEND_MESSAGE
            II = 0

         ENDIF
      END DO

      RETURN
      END


      SUBROUTINE DISPLAY_WHAT_WERE_DOING( TEXT , I1, I2 )
      CHARACTER*(*) TEXT
      CALL WRITE_REV_BOLD( TEXT, 12, 15)
      CALL SET_CURSOR( I1, I2 )
      RETURN
      END

      SUBROUTINE DISPLAY_WHAT_THEYRE_DOING( TEXT, I1, I2 )
      CHARACTER*(*) TEXT
      CALL WRITE_REV_BOLD( TEXT, 12, 52)
      CALL SET_CURSOR( I1, I2 )
      RETURN
      END

      SUBROUTINE SEND_CURSOR( ROW, COL )
      INTEGER    ROW, COL
      CHARACTER*5 LINE
 1    FORMAT( 'C', I2, I2 )
      WRITE( LINE, 1 ) ROW, COL
      CALL WRITE_TO_MAILBOX( LINE )
      RETURN
      END

      SUBROUTINE FIRE( ROW, COL )
      INTEGER    ROW, COL
      CHARACTER*5 LINE
 1    FORMAT( 'F', I2, I2 )
      WRITE( LINE, 1 ) ROW, COL
      CALL WRITE_TO_MAILBOX( LINE )
      RETURN
      END

      SUBROUTINE    MESSAGE( TEXT )
      CHARACTER*(*) TEXT
      INCLUDE       '($SMGDEF)'
      INCLUDE       'BATTLE.INC'
      II = ILN( TEXT )
      CALL SMG$SCROLL_DISPLAY_AREA( DISPID2 )
      CALL SMG$PUT_CHARS( DISPID2, TEXT(1:II), 3 )
      RETURN
      END

      SUBROUTINE    MESSAGE_NOCR( TEXT )
      CHARACTER*(*) TEXT
      INCLUDE       '($SMGDEF)'
      INCLUDE       'BATTLE.INC'
      II   = ILN( TEXT )
      CALL SET_CURSOR( 3, 1 )
      CALL SMG$PUT_LINE( DISPID2, TEXT(1:II),,,, )
      RETURN
      END


      INTEGER FUNCTION ILN( TEXT )
      CHARACTER*(*) TEXT
      ILN = LEN(TEXT)
      DO WHILE(( TEXT(ILN:ILN) .EQ. ' ' ) .AND. (ILN .GT. 1))
         ILN = ILN - 1
      END DO
      RETURN
      END


      SUBROUTINE WRITE( TEXT, ROW, COL )
      CHARACTER*(*) TEXT
      INTEGER       STATUS, SMG$PUT_CHARS, ROW, COL
      INCLUDE       'BATTLE.INC'
      STATUS = SMG$PUT_CHARS( DISPID, TEXT, ROW, COL )
      IF ( .NOT. STATUS) CALL LIB$SIGNAL( %VAL( STATUS ))
      RETURN
      END



      SUBROUTINE WRITE_REV_BOLD( TEXT, ROW, COL )
      INCLUDE       '($SMGDEF)'
      CHARACTER*(*) TEXT
      INTEGER       STATUS, SMG$PUT_CHARS, ROW, COL
      INCLUDE       'BATTLE.INC'
      STATUS = SMG$PUT_CHARS( DISPID, TEXT, ROW, COL, ,
     _SMG$M_BOLD+SMG$M_REVERSE )
      IF ( .NOT. STATUS) CALL LIB$SIGNAL( %VAL( STATUS ))
      RETURN
      END

      SUBROUTINE WRITE_REV( TEXT, ROW, COL )
      INCLUDE       '($SMGDEF)'
      CHARACTER*(*) TEXT
      INTEGER       STATUS, SMG$PUT_CHARS, ROW, COL
      INCLUDE       'BATTLE.INC'
      STATUS = SMG$PUT_CHARS( DISPID, TEXT, ROW, COL, ,
     _SMG$M_REVERSE )
      IF ( .NOT. STATUS) CALL LIB$SIGNAL( %VAL( STATUS ))
      RETURN
      END



      SUBROUTINE WRITE_BOLD( TEXT, ROW, COL )
      INCLUDE       '($SMGDEF)'
      CHARACTER*(*) TEXT
      INTEGER       STATUS, SMG$PUT_CHARS, ROW, COL
      INCLUDE       'BATTLE.INC'
      STATUS = SMG$PUT_CHARS( DISPID, TEXT, ROW, COL, ,
     _SMG$M_BOLD )
      IF ( .NOT. STATUS) CALL LIB$SIGNAL( %VAL( STATUS ))
      RETURN
      END


      INTEGER FUNCTION INKEY()
      INCLUDE 'BATTLE.INC'
      GETTING_INKEY = .TRUE.
      CALL SMG$READ_KEYSTROKE(KEYBID, INKEY)
      GETTING_INKEY = .FALSE.
      RETURN
      END


      SUBROUTINE SET_CURSOR( ROW, COL )
      INTEGER ROW, COL
      INCLUDE 'BATTLE.INC'
      CALL SMG$SET_CURSOR_ABS( DISPID, ROW, COL )
      RETURN
      END


      SUBROUTINE    ABORT_GAME
      CHARACTER*132 MASTER_FILE
      INCLUDE 'BATTLE.INC'
      IF ( WAITING_FOR_COMLINK ) THEN
           II     = ILN( IMAGE_DEFAULT_DIR )
           IJ     = ILN( CURR_NODE )

           MASTER_FILE = IMAGE_DEFAULT_DIR(1:II)//
     _              'BATTLESHIP_'          //
     _              CURR_NODE(1:IJ)        //
     _              '.DAT'


         THEIR.MBX_NAME = ' '
  19     OPEN( FILE=MASTER_FILE, STATUS='OLD', UNIT=20, ERR=21 )
         WRITE( 20, * ) '                                        '
         CALL CANCELLED_THE_GAME

      ENDIF

      CALL WRITE_TO_MAILBOX( 'A' )
  21  CALL CANCELLED_THE_GAME

      RETURN
      END


      SUBROUTINE CANCELLED_THE_GAME
      INCLUDE    'BATTLE.INC'

      CALL SMG$DELETE_VIRTUAL_DISPLAY( DISPID2 )
      CALL SMG$ERASE_DISPLAY( DISPID  )
      CALL CENTER_DISP_REV_BOLD( 'VMS BattleShip V1.0' , 1 ) 
      CALL CENTER_DISP_BOLD( 'was written by' , 3 )
      CALL CENTER_DISP_BOLD( 'Ray Renteria' , 5 )
      CALL CENTER_DISP_BOLD( 'Copyright(C) 1989 IRONLOGIC(tm)', 7 )
      CALL CENTER_DISP_BOLD( 'Send suggestions or comments to',10)
      CALL CENTER_DISP_BOLD( 'RR02026@SWTEXAS' , 11 )
      CALL CENTER_DISP_BOLD( 'or', 12 )
      CALL CENTER_DISP_BOLD( 'ACM_CSA@SWTEXAS',13 )
      CALL CENTER_DISP_BOLD( '. . .press any key to continue. . .',17)
      CALL PURGE_TYPE_AHEAD
      IF ( .NOT. GETTING_INKEY ) II = INKEY()
      CALL SMG$DISABLE_BROADCAST_TRAPPING( PASTEID )
      CALL SYS$DELMBX( OUR.MBX_CHAN )
      CALL SYS$DASSGN( THEIR.MBX_CHAN )
      CALL SMG$DELETE_VIRTUAL_DISPLAY( DISPID )
      CALL EXIT
      RETURN
      END

      SUBROUTINE THEY_WON_THE_GAME
      INCLUDE 'BATTLE.INC'
      CALL SMG$DELETE_VIRTUAL_DISPLAY( DISPID2 )
      CALL SMG$ERASE_DISPLAY( DISPID  )
      CALL CENTER_DISP( 'I''m sorry to inform you '//
     _                           'that our NAVY was' ,5)
      CALL CENTER_DISP( 'unsuccessful in destroying the',6 )
      CALL CENTER_DISP( 'enemy.' ,7)
      CALL CENTER_DISP( 'We have walked away wiser. . .', 9 )
      CALL CENTER_DISP( 'and',10)
      CALL CENTER_DISP_BOLD( 'We shall return!', 11 )
      CALL CENTER_DISP( '. . .press any key to continue. . .', 17 )
      CALL PURGE_TYPE_AHEAD
      IF ( .NOT. GETTING_INKEY ) II = INKEY()
      GETTING_INKEY = .FALSE.
      CALL CANCELLED_THE_GAME
      RETURN
      END


      SUBROUTINE THEY_LOST_THE_GAME
      INCLUDE 'BATTLE.INC'
      CALL SMG$DELETE_VIRTUAL_DISPLAY( DISPID2 )
      CALL SMG$ERASE_DISPLAY( DISPID  )
      CALL CENTER_DISP( 'Your keen senses has led this' ,5)
      CALL CENTER_DISP( 'NAVY to victory!',6 )
      CALL CENTER_DISP_BOLD( 'Congratulations, sir!', 8 )
      CALL CENTER_DISP( '. . .press any key to continue. . .', 17 )
      CALL PURGE_TYPE_AHEAD
      IF ( .NOT. GETTING_INKEY ) II = INKEY()
      GETTING_INKEY = .FALSE.
      CALL CANCELLED_THE_GAME
      RETURN
      END



      SUBROUTINE NOT_ALLOWED_TO_PLAY
      INCLUDE 'BATTLE.INC'
      CALL SMG$DELETE_VIRTUAL_DISPLAY( DISPID2 )
      CALL SMG$ERASE_DISPLAY( DISPID  )
      CALL CENTER_DISP( 'Your username has been' ,5)
      CALL CENTER_DISP_BOLD( 'restricted',6 )
      CALL CENTER_DISP( 'from this game.', 8 )
      CALL CENTER_DISP( 'contact the operator of this game', 10 )
      CALL CENTER_DISP( 'if you have any questions.',12 )
      CALL CENTER_DISP( '. . .press any key to continue. . .', 17 )
      CALL PURGE_TYPE_AHEAD
      IF ( .NOT. GETTING_INKEY ) II = INKEY()
      GETTING_INKEY = .FALSE.
      CALL CANCELLED_THE_GAME
      RETURN
      END



      SUBROUTINE NOT_A_SCHEDULED_TIME
      INCLUDE 'BATTLE.INC'
      CALL SMG$DELETE_VIRTUAL_DISPLAY( DISPID2 )
      CALL SMG$ERASE_DISPLAY( DISPID  )
      CALL CENTER_DISP( 'You cannot play at this time' ,5)
      CALL CENTER_DISP( 'Contact the operator of this game', 10 )
      CALL CENTER_DISP( 'if you have any questions.',12 )
      CALL CENTER_DISP( '. . .press any key to continue. . .', 17 )
      CALL PURGE_TYPE_AHEAD
      IF ( .NOT. GETTING_INKEY ) II = INKEY()
      GETTING_INKEY = .FALSE.
      CALL CANCELLED_THE_GAME
      RETURN
      END


      SUBROUTINE CENTER_DISP_REV_BOLD( TEXT, ROW )
      CHARACTER*(*) TEXT
      INTEGER ROW
      ILN = LEN(TEXT)
      II  = 35 - (ILN/2)
      CALL WRITE_REV_BOLD( TEXT, ROW, II )
      RETURN
      END


      SUBROUTINE CENTER_DISP_BOLD( TEXT, ROW )
      CHARACTER*(*) TEXT
      INTEGER ROW
      ILN = LEN(TEXT)
      II  = 35 - (ILN/2)
      CALL WRITE_BOLD( TEXT, ROW, II )
      RETURN
      END


      SUBROUTINE CENTER_DISP( TEXT, ROW )
      CHARACTER*(*) TEXT
      INTEGER ROW
      ILN = LEN(TEXT)
      II  = 35 - (ILN/2)
      CALL WRITE( TEXT, ROW, II )
      RETURN
      END

