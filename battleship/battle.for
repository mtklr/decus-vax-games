      PROGRAM BATTLE
C
C  BATTLESHIP
C 
C  Written by Ray Renteria         
C  IRONLOGIC(tm) 1989
C  ACM_CSA@SWTEXAS, RR02026@SWTEXAS
C  Southwest Texas State University
C
C  Comment:
C 
C    If you get this program, please send me a brief mail message
C    so that I can know who to send updates to.
C
C  Disclaimer:
C
C    If it crashes your system or environment, DONT BLAME ME!
C
C  ShareWare note:
C
C    If you find this program entertaining, or helpful with finding
C    certain system service or smg routines, please send a bag of cheetos
C    and a coke to ACM_CSA@SWTEXAS or RR02026@SWTEXAS.  Thank you
C    for your support.
C
C  Known bugs:
C     
C  * Cursor placement:  During a Msg> read, if no text is on the
C    command line, and the opponent moves the cursor on the screen,
C    the cursor will move to and remain at the position the opponent just
C    moved to.  Result:  Message text is entered from the middle of
C    the screen.  Note: <ESC>7 and <ESC>8 are reserved by SMG$ and can not
C    be used (in this particular instance).
C
C     
C  Modifications:
C
C     Please send me an updated version when modification is made to this
C     program.  Thanks.
C
C  Initials  Date       Description
C  ---------+----------+-----------------------------------------------
C  RR       |08/30/89  | Corrected a problem of ^C during a wait-for-opponent
C  CM       |09/14/89  | Added a time flag to eliminate off hours of playing
C

      LOGICAL THEY_WON
      INCLUDE 'BATTLE.INC'

      CALL INIT
      CALL GET_JOB_PROCESS_INFORMATION
      CALL LOGUSER

      CALL DRAW_BOARD
      CALL SETUP_COMLINK

      CALL DISPLAY_WHAT_WERE_DOING  ( 'setting up' , 2, 4 )
      CALL DISPLAY_WHAT_THEYRE_DOING( 'setting up' , 2, 4 )
      CALL SETUP_SHIPS

      IM_FINISHED = .TRUE.
      PLAYING     = .TRUE.
      IF ( THEYRE_FINISHED ) THEN                      ! They finished first.

           CALL WRITE_TO_MAILBOX( '-' )
           CALL MESSAGE( 'Its their first move, sir.' )
           THEIR_TURN = .TRUE.

      ELSE
           CALL WRITE_TO_MAILBOX( '-' )
           CALL MESSAGE( 'You get to go first, sir. They''re still'//
     _                    ' setting up.' )
           CALL DISPLAY_WHAT_WERE_DOING  ( 'waiting...           ',2,39)
           GETTING_INKEY = .TRUE.                     ! GETTING_INKEY is for
                                                      ! AST purposes
           CALL SYS$HIBER()
           THEIR_TURN = .FALSE.
           CALL MESSAGE( 'They''re finished setting up!' )

      ENDIF


!-------------------------------------------------------------------------------
! AND NOW FOR THE GAME
!-------------------------------------------------------------------------------
C These are fairly self-explanatory, so I'll spare you the comments.
C
      CALL SET_CURSOR( 2, 4 )

      THEIR.SHIPS_DESTROYED = 0
      OUR.SHIPS_DESTROYED   = 0

      DO WHILE( PLAYING )

         IF ( THEIR_TURN ) THEN

             CALL DISPLAY_WHAT_THEYRE_DOING( 'aiming to fire.      ',
     _            ITHEIR_ROW, ITHEIR_COL )
             CALL DISPLAY_WHAT_WERE_DOING  ( 'watching their target',
     _            ITHEIR_ROW, ITHEIR_COL )

             CALL WAIT(II)
             THEIR_TURN = .FALSE.

         ELSE

             CALL PURGE_TYPE_AHEAD
             CALL SET_CURSOR( IOUR_ROW, IOUR_COL )
             CALL AIM_AND_FIRE(II)
             THEIR_TURN = .TRUE.

         ENDIF

      END DO

      END

      INCLUDE 'SCREEN1.FOR'           ! Smg stuff
      INCLUDE 'SCREEN2.FOR'           ! Smg stuff
      INCLUDE 'SYSTEM.FOR'            ! System Service stuff
      INCLUDE 'COMLINK.FOR'           ! Initialization stuff
      INCLUDE 'LOGGER.FOR'            ! Event logging stuff
      INCLUDE 'TIME.FOR'              ! Access times routine stuff
