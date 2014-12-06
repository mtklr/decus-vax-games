C
C  SCREEN1.FOR
C
C  Ray Renteria
C  RR02026@SWTEXAS    ACM_CSA@SWTEXAS
C  Southwest Texas State University
C  (512) 396 - 7216
C
C  Contains:
C
C    SETUP_SHIPS        User procedure for placement of ships on screen
C    SEND_UPDATE        System procedure for sending ship strength to opponent
C    REPAINT_SCREEN     AST procedure for refreshing the screen
C    ANNOUNCE           Displays message on current ship's status while placing
C    ENTER              Interface for placing a ship.
C    OUR_UPDATE         Display to our screen our ship's status'
C    THEIR_UPDATE       Display to their screen our ship's status'
C    ABORT              Removes the current ship from the screen while placing
C    TOUP               Converts a single character to upper case
C    TRAP_MESSAGES      AST procedure for trapping a broadcast message
C    INIT               Initializes smg display id's, keyboard etc.
C    SPAWN_DCL          Envokes a spawn and notifies opponent.
C    SEND_MESSAGE       Accepts input for message to be sent to opponent
C    GET_INPUT          Interface for SEND_MESSAGE
C    DRAW_BOARD         Draws the screen
C
      SUBROUTINE     SETUP_SHIPS
      INTEGER        TOUP
      LOGICAL        FINISHED
      COMMON /SETUP/ ICOMMON_SETUP_ROW, ICOMMON_SETUP_COL
      STRUCTURE /ALLOW/
            LOGICAL BATTLESHIP/.TRUE./, 
     _              SUBMARINE /.TRUE./, 
     _              PT_BOAT   /.TRUE./, 
     _              CARRIER   /.TRUE./,
     _              CRUISER   /.TRUE./, 
     _              DESTROYER /.TRUE./
      END STRUCTURE
      RECORD /ALLOW/ ALLOWING
      INCLUDE       'BATTLE.INC'
      INUMPLACED = 0
      FINISHED = .FALSE.
      CALL MESSAGE( 'Place your ships, sir.  '//
     _              'Type B, C, D, S, P, or A to place.' )

      CALL OUR_UPDATE  ('B', 0 )
      CALL THEIR_UPDATE('B', 0 )
      CALL OUR_UPDATE  ('C', 0 )
      CALL THEIR_UPDATE('C', 0 )
      CALL OUR_UPDATE('D', 0 )
      CALL THEIR_UPDATE('D', 0 )
      CALL OUR_UPDATE('S', 0 )
      CALL THEIR_UPDATE('S', 0 )
      CALL OUR_UPDATE('P', 0 )
      CALL THEIR_UPDATE('P', 0 )
      CALL OUR_UPDATE('A', 0 )
      CALL THEIR_UPDATE('A', 0 )

      IROW = 2
      ICOL = 4

      DO WHILE ( INUMPLACED .LT. 6 )
         CALL SET_CURSOR( IROW, ICOL )
         ICOMMON_SETUP_ROW = IROW
         ICOMMON_SETUP_COL = ICOL
         II = INKEY()
         II = TOUP( II )
         IF      ( II .EQ. 277 ) THEN    ! RIGHT ARROW
            IF ( ICOL .LT. 32 ) THEN
               ICOL = ICOL + 2
            ELSE
               ICOL = 4
            ENDIF

         ELSEIF ( II .EQ. 276 ) THEN     ! LEFT ARROW
            IF ( ICOL .GT. 4 ) THEN
               ICOL = ICOL - 2
            ELSE
               ICOL = 32
            ENDIF

         ELSEIF( II .EQ. 274 ) THEN      ! UP ARROW
            IF ( IROW .GT. 2 ) THEN
               IROW = IROW - 1
            ELSE
               IROW = 10
            ENDIF

         ELSEIF( II .EQ. 275 ) THEN      ! DOWN ARROW
            IF ( IROW .LT. 10 ) THEN
               IROW = IROW + 1
            ELSE
               IROW = 2
            ENDIF

         ELSEIF( II .EQ. 65 ) THEN
            IF ( ALLOWING.CARRIER ) THEN
                CALL MESSAGE( 'Place your carrier, sir!' )
                CALL ENTER( ALLOWING.CARRIER, CAR_STRENGTH, 
     _                      CHAR(II), IROW, ICOL )

                CALL ANNOUNCE( ALLOWING.CARRIER, 'Carrier',
     -                      INUMPLACED)
            ELSE
                CALL MESSAGE( 'You have already placed your carrier,'
     _                        //' sir.' )
            END IF

         ELSEIF( II .EQ. 66 ) THEN
            IF ( ALLOWING.BATTLESHIP ) THEN
                CALL MESSAGE( 'Place your battleship, sir!' )
                CALL ENTER( ALLOWING.BATTLESHIP, BAT_STRENGTH, 
     _                      CHAR(II), IROW, ICOL )
                CALL ANNOUNCE( ALLOWING.BATTLESHIP, 'Battleship',
     _                         INUMPLACED)

            ELSE
                CALL MESSAGE( 'You have already placed your '//
     _                        'battleship, sir.' )
            ENDIF

         ELSEIF( II .EQ. 67 ) THEN
            IF ( ALLOWING.CRUISER ) THEN
                CALL MESSAGE( 'Place your cruiser, sir!' )
                CALL ENTER( ALLOWING.CRUISER, CRU_STRENGTH, 
     _                      CHAR(II), IROW, ICOL )
                CALL ANNOUNCE( ALLOWING.CRUISER, 'Cruiser',
     _                      INUMPLACED)

            ELSE
                CALL MESSAGE( 'You have already placed your cruiser,'
     _                        //' sir.' )
            ENDIF
 
         ELSEIF( II .EQ. 68 ) THEN
            IF ( ALLOWING.DESTROYER ) THEN
                CALL MESSAGE( 'Place your destroyer, sir!' )
                CALL ENTER( ALLOWING.DESTROYER, DES_STRENGTH, 
     _                      CHAR(II), IROW, ICOL )
                CALL ANNOUNCE( ALLOWING.DESTROYER, 'Destroyer',
     _                      INUMPLACED)

            ELSE
                CALL MESSAGE( 'You have already placed your destroyer,'
     _                        //' sir.' )
            ENDIF

         ELSEIF( II .EQ. 83 ) THEN
            IF ( ALLOWING.SUBMARINE ) THEN
                CALL MESSAGE( 'Place your submarine, sir!' )
                CALL ENTER( ALLOWING.SUBMARINE, SUB_STRENGTH, 
     +                      CHAR(II), IROW, ICOL )
                CALL ANNOUNCE( ALLOWING.SUBMARINE, 'Submarine',
     _                      INUMPLACED)
                
            ELSE
                CALL MESSAGE( 'You have already placed your submarine,'
     _                        //' sir.' )
            ENDIF

         ELSEIF( II .EQ. 80 ) THEN
            IF ( ALLOWING.PT_BOAT ) THEN
                CALL MESSAGE( 'Place your PT boat, sir!' )
                CALL ENTER( ALLOWING.PT_BOAT, PT_STRENGTH, 
     _                       CHAR(II), IROW, ICOL )
                CALL ANNOUNCE( ALLOWING.PT_BOAT, 'PT Boat',
     _                       INUMPLACED)

            ELSE
                CALL MESSAGE( 'You have already placed your pt boat,'
     _                        //' sir.' )
            ENDIF

         ELSEIF ( II .EQ. 16 ) THEN 
            CALL SPAWN_DCL

         ELSEIF ( II .EQ. 5 ) THEN
            CALL SEND_MESSAGE

         ENDIF
      END DO

      RETURN
      END


      SUBROUTINE SEND_UPDATE( CH, STRENGTH )
      CHARACTER*1 CH
      CHARACTER*3 LINE
      INTEGER     STRENGTH
  1   FORMAT( '+',A1,I1 )
      WRITE( LINE, 1 ) CH, STRENGTH
      CALL WRITE_TO_MAILBOX( LINE )
      RETURN
      END


      SUBROUTINE    REPAINT_SCREEN
      INCLUDE       'BATTLE.INC'
      CALL SMG$REPAINT_SCREEN(PASTEID)
      RETURN
      END

      SUBROUTINE    ANNOUNCE( LOG, BOAT,II )
      LOGICAL       LOG
      CHARACTER*(*) BOAT

      IF ( LOG ) THEN
         CALL MESSAGE( 'Your '//BOAT//' still needs'//
     +                             ' to be placed, sir!')

      ELSE
         CALL MESSAGE( 'Your '//BOAT//' has been placed,'//
     _                             ' sir!' )
         II = II + 1
      ENDIF
      RETURN
      END

      SUBROUTINE  ENTER( LOG, NUM_HITS, CH, IROW, ICOL )
      INTEGER     NUM_HITS, IROW, ICOL
      LOGICAL     FINISHED, ALLOWING_VERT, ALLOWING_HOR, LOG
      CHARACTER*1 CH
      INCLUDE     'BATTLE.INC'

      FINISHED      = .FALSE.
      ALLOWING_VERT = .TRUE.
      ALLOWING_HOR  = .TRUE.
      ICOUNT        = 0
      LOG           = .FALSE.

      IF (M_GRID(IROW-1,(ICOL/2)-1).EQ.'.') THEN

          CALL WRITE( CH, IROW, ICOL )      
          M_GRID( IROW - 1,(ICOL/2) - 1 ) = CH
          ICOUNT = ICOUNT + 1
          IF (ICOUNT .EQ. NUM_HITS ) FINISHED = .TRUE.
          CALL OUR_UPDATE( CH, ICOUNT )

      ELSEIF(M_GRID(IROW-1,(ICOL/2)-1) .NE. CH ) THEN
          CALL MESSAGE('This position is already occupied, sir.')
          LOG = .TRUE.
          RETURN

      ENDIF


      DO WHILE ( .NOT. FINISHED )
        
         CALL SET_CURSOR( IROW, ICOL )
         IOLDROW = IROW
         IOLDCOL = ICOL
         II = INKEY()

         IF      (( II .EQ. 277 ) .AND. (ALLOWING_HOR)) THEN    ! RIGHT ARROW
            ALLOWING_VERT = .FALSE.
            IF ( ICOL .LT. 32 ) THEN
               ICOL = ICOL + 2
            ELSE
               ICOL = 4
            ENDIF

         ELSEIF (( II .EQ. 276 ) .AND. (ALLOWING_HOR)) THEN     ! LEFT ARROW
            ALLOWING_VERT = .FALSE.
            IF ( ICOL .GT. 4 ) THEN
               ICOL = ICOL - 2
            ELSE
               ICOL = 32
            ENDIF

         ELSEIF(( II .EQ. 274 ) .AND. (ALLOWING_VERT)) THEN      ! UP ARROW
            ALLOWING_HOR = .FALSE.
            IF ( IROW .GT. 2 ) THEN
               IROW = IROW - 1
            ELSE
               IROW = 10
            ENDIF

         ELSEIF(( II .EQ. 275 ) .AND. (ALLOWING_VERT)) THEN      ! DOWN ARROW
            ALLOWING_HOR = .FALSE.
            IF ( IROW .LT. 10 ) THEN
               IROW = IROW + 1
            ELSE
               IROW = 2
            ENDIF
         
         ELSEIF ( II .EQ. 26 ) THEN
            CALL MESSAGE( 'Aborting placement of this ship, sir!' )
            CALL ABORT( CH )
            LOG = .TRUE.
            CALL OUR_UPDATE( CH, 0)
            RETURN
           
         ENDIF

         IF(ICOUNT .LE. NUM_HITS) THEN

           IF (M_GRID(IROW-1,(ICOL/2)-1).EQ.'.') THEN

              CALL WRITE( CH, IROW, ICOL )      
              M_GRID( IROW - 1,(ICOL/2) - 1 ) = CH
              ICOUNT = ICOUNT + 1
              IF (ICOUNT .EQ. NUM_HITS ) FINISHED = .TRUE.
              CALL OUR_UPDATE( CH, ICOUNT )

           ELSEIF(M_GRID(IROW-1,(ICOL/2)-1) .NE. CH ) THEN
              CALL MESSAGE('This position is already occupied, sir.')
              IROW = IOLDROW
              ICOL = IOLDCOL

           ENDIF
      ENDIF

      END DO
      LOG           = .FALSE.
      RETURN
      END


      SUBROUTINE   OUR_UPDATE( CH, ISTRENGTH )
      INTEGER      STRENGTH, PERCENTAGE
      CHARACTER*20 TEXT
      CHARACTER*9  STREN
      CHARACTER*1  CH
      INCLUDE      'BATTLE.INC'
 1    FORMAT( 1X,I1, 2X, '(',A9,')',1X,I3,'%' )
      INCLUDE    'BATTLE_ARRAY.INC'

      CALL SEND_UPDATE( CH, ISTRENGTH )

      STRENGTH = ISTRENGTH
      IMARK    = 1

      IF ( STRENGTH .EQ. 0 ) THEN
                 IMARK = - 1
                 STRENGTH = 1
      ENDIF
       
      IF     ( CH .EQ. 'C' ) THEN
               OUR.CRUISER = STRENGTH
               STREN = CRUISER(STRENGTH)
               PERCENTAGE = STRENGTH*(100/CRU_STRENGTH)
               IROW = 17

      ELSEIF ( CH .EQ. 'A' ) THEN
               OUR.CARRIER = STRENGTH
               STREN = CARRIER(STRENGTH)
               PERCENTAGE = STRENGTH*(100/CAR_STRENGTH)
               IROW = 18

      ELSEIF ( CH .EQ. 'P' ) THEN
               OUR.PT_BOAT = STRENGTH  
               STREN = PT_BOAT(STRENGTH)
               PERCENTAGE = STRENGTH*(100/PT_STRENGTH)
               IROW = 15

      ELSEIF ( CH .EQ. 'D' ) THEN
               OUR.DESTROYER = STRENGTH
               STREN = DESTROYER(STRENGTH)
               PERCENTAGE = STRENGTH*(100/DES_STRENGTH)
               IROW = 16

      ELSEIF ( CH .EQ. 'S' ) THEN
               OUR.SUBMARINE = STRENGTH
               STREN = SUBMARINE(STRENGTH)
               PERCENTAGE = STRENGTH*(100/SUB_STRENGTH)
               IROW = 14

      ELSEIF ( CH .EQ. 'B' ) THEN
               OUR.BATTLESHIP = STRENGTH
               STREN = BATTLESHIP(STRENGTH)
               PERCENTAGE = STRENGTH*(100/BAT_STRENGTH)
               IROW = 13

      ENDIF

      IF ( IMARK .LT. 0 ) THEN
           STRENGTH = 0
           STREN    = 'Destroyed'
           PERCENTAGE= 0
           CALL WRITE( '>', IROW, 3 )
      ELSE
           CALL WRITE( ' ', IROW, 3 )
      ENDIF

      WRITE ( TEXT, 1 ) STRENGTH, STREN, PERCENTAGE
      CALL WRITE( TEXT, IROW, 15 )

      RETURN
      END



      SUBROUTINE   THEIR_UPDATE( CH, ISTRENGTH )
      INTEGER      STRENGTH, PERCENTAGE
      CHARACTER*20 TEXT
      CHARACTER*9  STREN
      CHARACTER*1  CH
      INCLUDE     'BATTLE.INC'
 1    FORMAT( 1X, I1, 2X, '(', A9, ')', 1X, I3, '%' )
      INCLUDE    'BATTLE_ARRAY.INC'

      STRENGTH = ISTRENGTH
      IMARK = 1
      CALL ESC_7

      IF ( STRENGTH .EQ. 0 ) THEN
               IMARK = - 1
               STRENGTH = 1
      ENDIF

      IF     ( CH .EQ. 'C' ) THEN
               THEIR.CRUISER = STRENGTH
               STREN = CRUISER(STRENGTH)
               PERCENTAGE = STRENGTH*(100/CRU_STRENGTH)
               IIROW = 17

      ELSEIF ( CH .EQ. 'A' ) THEN
               THEIR.CARRIER = STRENGTH
               STREN = CARRIER(STRENGTH)
               PERCENTAGE = STRENGTH*(100/CAR_STRENGTH)
               IIROW = 18

      ELSEIF ( CH .EQ. 'P' ) THEN
               THEIR.PT_BOAT = STRENGTH  
               STREN = PT_BOAT(STRENGTH)
               PERCENTAGE = STRENGTH*(100/PT_STRENGTH)
               IIROW = 15

      ELSEIF ( CH .EQ. 'D' ) THEN
               THEIR.DESTROYER = STRENGTH
               STREN = DESTROYER(STRENGTH)
               PERCENTAGE = STRENGTH*(100/DES_STRENGTH)
               IIROW = 16

      ELSEIF ( CH .EQ. 'S' ) THEN
               THEIR.SUBMARINE = STRENGTH
               STREN = SUBMARINE(STRENGTH)
               PERCENTAGE = STRENGTH*(100/SUB_STRENGTH)
               IIROW = 14

      ELSEIF ( CH .EQ. 'B' ) THEN
               THEIR.BATTLESHIP = STRENGTH
               STREN = BATTLESHIP(STRENGTH)
               PERCENTAGE = STRENGTH*(100/BAT_STRENGTH)
               IIROW = 13

      ENDIF

      IF ( IMARK .LT. 0 ) THEN
           STRENGTH = 0
           STREN    = 'Destroyed'
           PERCENTAGE= 0
           CALL WRITE( '>', IIROW, 38 )
           THEIR.SHIPS_DESTROYED = THEIR.SHIPS_DESTROYED + 1
           IF((THEIR.SHIPS_DESTROYED.EQ.6) .AND.
     _         THEYRE_FINISHED) THEN
               CALL WRITE_TO_MAILBOX( '*' )
               CALL THEY_LOST_THE_GAME
           ENDIF
      ELSE
           CALL WRITE( ' ', IIROW, 38 )

      ENDIF
      WRITE ( TEXT, 1 ) STRENGTH, STREN, PERCENTAGE
      CALL WRITE( TEXT, IIROW, 50 )
      CALL ESC_8

      RETURN
      END



      SUBROUTINE ABORT( CH )
      CHARACTER*1 CH
      INCLUDE 'BATTLE.INC'
      DO I = 1, 9
        DO J = 1, 15
           IF (M_GRID(I,J) .EQ. CH) THEN
               M_GRID(I,J) = '.'
               CALL WRITE( '.', I+1, (J*2) + 2 )
           END IF
        END DO
      END DO
      RETURN
      END

      INTEGER FUNCTION TOUP( INT )
      TOUP = INT
      IF (INT .GE. 97 .AND. INT .LE. 122) TOUP = INT - 32
      RETURN
      END


      SUBROUTINE    TRAP_MESSAGES
      CHARACTER*200  MSG
      INCLUDE       'BATTLE.INC'
      CALL SMG$GET_BROADCAST_MESSAGE(PASTEID, MSG, ILN )
      CALL MESSAGE( MSG(1:ILN) )
      CALL SMG$SET_CURSOR_ABS( DISPID )
      RETURN
      END


      SUBROUTINE    INIT
      INCLUDE       '($SMGDEF)'
      EXTERNAL      TRAP_MESSAGES, REPAINT_SCREEN, SEND_MESSAGE,
     _              SPAWN_DCL
      INCLUDE       'BATTLE.INC'
      CALL SMG$CREATE_VIRTUAL_DISPLAY( 18, 70, DISPID , SMG$M_BORDER )
      CALL SMG$CREATE_VIRTUAL_DISPLAY(  3, 70, DISPID2, SMG$M_BORDER )
      CALL SMG$CREATE_PASTEBOARD( PASTEID )
      CALL SMG$SET_BROADCAST_TRAPPING( PASTEID, TRAP_MESSAGES )
      CALL SMG$CREATE_VIRTUAL_KEYBOARD( KEYBID )
      CALL SMG$PASTE_VIRTUAL_DISPLAY( DISPID, PASTEID,  2, 5, )
      CALL SMG$PASTE_VIRTUAL_DISPLAY( DISPID2, PASTEID, 21, 5, )
      CALL SMG$LABEL_BORDER( DISPID, 'You sank my BATTLESHIP!',
     _SMG$K_TOP,,SMG$M_BOLD )
      DO I = 1, 15
         DO J = 1, 9
            M_GRID( J,I ) = '.'
         END DO
      END DO
      CALL DISABLE_CONTROL
      CALL CONTROL('W',REPAINT_SCREEN)
      RETURN
      END

      SUBROUTINE    SPAWN_DCL
      INCLUDE      '($SMGDEF)'
      EXTERNAL      TRAP_MESSAGES
      INCLUDE       'BATTLE.INC'

      CALL WRITE_TO_MAILBOX('=Opponent is going to DCL.')
      CALL SMG$DISABLE_BROADCAST_TRAPPING( PASTEID )
      CALL SMG$UNPASTE_VIRTUAL_DISPLAY( DISPID , PASTEID )
      CALL SMG$UNPASTE_VIRTUAL_DISPLAY( DISPID2, PASTEID )

      CALL LIB$ERASE_PAGE(1,1)
      WRITE (*,*) 'Spawning to DCL. . .'
      WRITE (*,*) 'Type EOJ to return to game.' 
      CALL LIB$SPAWN(,,,,,,,,,,'BattleShip> ')

      CALL SMG$PASTE_VIRTUAL_DISPLAY( DISPID, PASTEID,  2, 5, )
      CALL SMG$PASTE_VIRTUAL_DISPLAY( DISPID2, PASTEID, 21, 5, )
      CALL SMG$SET_BROADCAST_TRAPPING( PASTEID, TRAP_MESSAGES )
      CALL REPAINT_SCREEN
      CALL WRITE_TO_MAILBOX('=Opponent has returned from DCL.')
      CALL MESSAGE( 'Welcome back, sir!' )
      RETURN
      END

      SUBROUTINE SEND_MESSAGE
      INCLUDE    'BATTLE.INC'
      CHARACTER*70 STRING

      I1 = ILN( OUR.UIC )
      IF ( INSERT_CR ) THEN
          CALL MESSAGE_NOCR( ' ' )
          INSERT_CR = .FALSE.
      ENDIF

      CALL GET_INPUT( 'Msg> ', STRING, II )
      CALL WRITE_TO_MAILBOX( '='//OUR.UIC(1:I1)//'> '//STRING(1:II) )
      CALL REDRAW_BOTTOM_WINDOW
      CALL SMG$SET_CURSOR_ABS( DISPID )

      RETURN
      END


      SUBROUTINE GET_INPUT( PROMPT, STRING, II )
      INCLUDE 'BATTLE.INC'
      CHARACTER*(*) PROMPT, STRING
      IMAX_LEN = 69 - LEN(PROMPT)
      AT_COMMAND_LINE = .TRUE.
      CALL SMG$READ_STRING( KEYBID, STRING, PROMPT, IMAX_LEN
     _     ,,,,II,,DISPID2)
      AT_COMMAND_LINE = .FALSE.
      RETURN
      END


      SUBROUTINE REDRAW_BOTTOM_WINDOW
      INCLUDE 'BATTLE.INC'
      CALL SMG$REPAINT_LINE( PASTEID, 21, 3 )
      RETURN
      END



      SUBROUTINE    DRAW_BOARD
      INCLUDE       '($SMGDEF)'
      INCLUDE       'BATTLE.INC'

      CALL SMG$DRAW_RECTANGLE( DISPID, 1,  2, 11, 34 )
      CALL SMG$DRAW_RECTANGLE( DISPID, 1, 37, 11, 69 )

      DO I = 1, 9
         CALL WRITE_BOLD( CHAR(I+48), I+1, 2 )
         CALL WRITE( '. . . . . . . . . . . . . . .',I+1,4)
         CALL WRITE_REV_BOLD( ' ', I+1, 35 )

         CALL WRITE_BOLD( CHAR(I+48), I+1, 37 )
         CALL WRITE( '. . . . . . . . . . . . . . .',I+1,39)
         CALL WRITE_REV_BOLD( ' ', I+1, 70 )
      END DO

      CALL WRITE_BOLD( 'A B C D E F G H I J K L M N O', 11, 39 )
      CALL WRITE_BOLD( 'A B C D E F G H I J K L M N O', 11, 4 )

      CALL WRITE_REV_BOLD('                                 ', 12, 3 )
      CALL WRITE_REV_BOLD( ' ', I+1, 35 )
      CALL WRITE_REV_BOLD('Our NAVY is ',12,3)

      CALL WRITE_REV_BOLD( ' ', I+1, 70 )
      CALL WRITE_REV_BOLD('                                 ', 12, 38)
      CALL WRITE_REV_BOLD('Their NAVY is ',12,38)

      CALL WRITE( 'Battleship: ', 13, 4 )
      CALL WRITE( 'Battleship: ', 13, 39 )
      CALL WRITE_BOLD( 'B', 13,4)
      CALL WRITE_BOLD( 'B', 13,39)

      CALL WRITE( 'Submarine : ', 14, 4 )
      CALL WRITE( 'Submarine : ', 14, 39 )
      CALL WRITE_BOLD( 'S', 14,4)
      CALL WRITE_BOLD( 'S', 14,39)

      CALL WRITE( 'Pt Boat   : ', 15, 4 )
      CALL WRITE( 'Pt Boat   : ', 15, 39 )
      CALL WRITE_BOLD( 'P', 15, 4)
      CALL WRITE_BOLD( 'P', 15, 39)

      CALL WRITE( 'Destroyer : ', 16, 4 )
      CALL WRITE( 'Destroyer : ', 16, 39 )
      CALL WRITE_BOLD( 'D', 16,4)
      CALL WRITE_BOLD( 'D', 16, 39)

      CALL WRITE( 'Cruiser   : ', 17, 4 )
      CALL WRITE( 'Cruiser   : ', 17, 39 )
      CALL WRITE_BOLD( 'C', 17,4)
      CALL WRITE_BOLD( 'C', 17,39)

      CALL WRITE( 'cArrier   : ', 18, 4 )
      CALL WRITE( 'cArrier   : ', 18, 39 )
      CALL WRITE_BOLD( 'A', 18,5)
      CALL WRITE_BOLD( 'A', 18,40)
      RETURN
      END


