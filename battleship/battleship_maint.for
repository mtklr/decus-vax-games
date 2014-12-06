
C
C This routine was just a last minute kick in (so was LOGGER.FOR) so that
C I could keep track and control those who played this game. 
C
C It is not complete - currently, the most it can do is restrict certain
C users from playing the game.  You can also view all thos who have played
C it and how many times.
C
      PROGRAM      BATTLE_MAINT
      CHARACTER*15 USER
      CHARACTER*80 COMMAND, DEF_DIR
      COMMAND(1:2) = '  '
      DO WHILE( COMMAND(1:2) .NE. '.E' )
           CALL LIB$GET_INPUT( COMMAND, 'BATTLE-MAINT> ', II )
           CALL STR$UPCASE   ( COMMAND, COMMAND )

           IF ( COMMAND(1:4) .EQ. 'INIT' ) THEN
                CALL INITIALIZE_DATAFILE

           ELSEIF ((COMMAND(1:2) .EQ. 'ME' ) .OR.
     _            ( COMMAND(1:2) .EQ. 'HE' ) .OR.
     _            ( COMMAND(1:1) .EQ. '?'  )) THEN
                CALL DRAW_MENU

           ELSEIF ( COMMAND(1:2) .EQ. 'VA' ) THEN
                CALL VIEW_ALL_USERS

           ELSEIF ( COMMAND(1:2) .EQ. 'LA' ) THEN
                CALL LIST_ALL_USERS

           ELSEIF ( COMMAND(1:2) .EQ. 'LT' ) THEN
                CALL LIST_TODAYS_USERS

           ELSEIF ( COMMAND(1:2) .EQ. 'CA' ) THEN
                CALL CHANGE_ALL_USERS

           ELSEIF ( COMMAND(1:2) .EQ. 'VS' ) THEN
                CALL LIB$GET_INPUT( USER, '_User: ', I1 )
                CALL STR$UPCASE( USER, USER )
                CALL VIEW_USER( USER )

           ELSEIF ( COMMAND(1:2) .EQ. 'CS' ) THEN
                CALL LIB$GET_INPUT( USER, '_User: ', I1 )
                CALL STR$UPCASE( USER, USER )
                CALL CHANGE_USER( USER )

           ENDIF
      END DO           

      END

      SUBROUTINE    VIEW_USER( USER )
      CHARACTER*14  SP/'              '/
      CHARACTER*80  DATA_DIR
      CHARACTER*132 DATAFILE
      CHARACTER*15  USER, KEY_FIELD
      INCLUDE       '($JPIDEF)'
      STRUCTURE /USR/
         CHARACTER*15 USERNAME
         CHARACTER*15 PNAME
         CHARACTER*23 DATE_TIME
         CHARACTER*4  FLAGS
         INTEGER  *4  TIMES
      END STRUCTURE
      RECORD /USR/ USER_STRUCTURE

 11   FORMAT( 1X, '%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%' )
 12   FORMAT( 1X, 'User        : ',A15,20X,'(',A15,')')
 13   FORMAT( 1X, 'Times played: ',I4  )
 14   FORMAT( 1X, 'Last played : ',A23 )
 15   FORMAT( 1X, 'Priv. Flags : ',A4  )
 16   FORMAT( 1X, 'Flag translation follows:' )
 18   FORMAT( 1X, 'User ',A15,' is not listed in the BATTLESHIP UAF.')

      CALL GET_JPI( JPI$_IMAGNAME, DATA_DIR , IDUMMY )
      DATAFILE = DATA_DIR(1:II)//'BATTLESHIP_UAF.DAT'

      OPEN(FILE        = DATAFILE        ,
     _     STATUS      = 'OLD'           ,
     _     ORGANIZATION= 'INDEXED'       ,
     _     ACCESS      = 'KEYED'         ,
     _     RECORDTYPE  = 'VARIABLE'      ,
     _     FORM        = 'UNFORMATTED'   ,
     _     CARRIAGECONTROL = 'NONE'      ,
     _     RECL        = 61              ,
     _     KEY         = (1:15:CHARACTER),
     _     ERR         = 22              ,
     _     UNIT        = 20              ,
     _     IOSTAT      = IOS)

      KEY_FIELD        = USER

      READ(UNIT        = 20              ,
     _     IOSTAT      = IOS             ,
     _     KEY         = KEY_FIELD       ,
     _     ERR         = 2 )
     _USER_STRUCTURE

 2    IF    (IOS.EQ.0) THEN
          WRITE(*,11)
          WRITE(*,12) USER_STRUCTURE.USERNAME, USER_STRUCTURE.PNAME
          WRITE(*,13) USER_STRUCTURE.TIMES
          WRITE(*,14) USER_STRUCTURE.DATE_TIME
          WRITE(*,15) USER_STRUCTURE.FLAGS
          WRITE(*,16)
          IF (USER_STRUCTURE.FLAGS(1:1) .EQ. '1' ) THEN
              WRITE (*,*) SP//'User may override scheduled times.'
          ELSE
              WRITE (*,*) SP//'User may not override scheduled times.'
          ENDIF

          IF (USER_STRUCTURE.FLAGS(2:2) .EQ. '1' ) THEN
              WRITE (*,*) SP//'User is allowed to play.'
          ELSE
              WRITE (*,*) SP//'User is not allowed to play.'
          ENDIF

          WRITE (*,*) SP//'(3rd flag reserved for future use)'
          WRITE (*,*) SP//'(4th flag reserved for future use)'
          WRITE(*,11)

      ELSEIF(IOS.EQ.36) THEN
          WRITE (*,18) USER

      ENDIF
 21   CLOSE(20)
 22   RETURN
      END




      SUBROUTINE    CHANGE_USER( USER )
      CHARACTER*14  SP/'              '/
      CHARACTER*4   FLAGS
      CHARACTER*80  DATA_DIR
      CHARACTER*132 DATAFILE
      CHARACTER*15  USER, KEY_FIELD
      INCLUDE       '($JPIDEF)'
      STRUCTURE /USR/
         CHARACTER*15 USERNAME
         CHARACTER*15 PNAME
         CHARACTER*23 DATE_TIME
         CHARACTER*4  FLAGS
         INTEGER  *4  TIMES
      END STRUCTURE
      RECORD /USR/ USER_STRUCTURE

 11   FORMAT( 1X, '%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%' )
 12   FORMAT( 1X, 'User        : ',A15,20X,'(',A15,')')
 13   FORMAT( 1X, 'Times played: ',I4  )
 14   FORMAT( 1X, 'Last played : ',A23 )
 15   FORMAT( 1X, 'Priv. Flags : ',A4  )
 16   FORMAT( 1X, 'Flag translation follows:' )
 17   FORMAT( 1X, 'Press [RETURN] to cancel operation.' )
 18   FORMAT( 1X, 'User ',A15,' is not listed in the BATTLESHIP UAF.')

      CALL GET_JPI( JPI$_IMAGNAME, DATA_DIR , IDUMMY )
      DATAFILE = DATA_DIR(1:II)//'BATTLESHIP_UAF.DAT'

      OPEN(FILE        = DATAFILE        ,
     _     STATUS      = 'OLD'           ,
     _     ORGANIZATION= 'INDEXED'       ,
     _     ACCESS      = 'KEYED'         ,
     _     RECORDTYPE  = 'VARIABLE'      ,
     _     FORM        = 'UNFORMATTED'   ,
     _     CARRIAGECONTROL = 'NONE'      ,
     _     RECL        = 61              ,
     _     KEY         = (1:15:CHARACTER),
     _     ERR         = 22              ,
     _     UNIT        = 20              ,
     _     IOSTAT      = IOS)

      KEY_FIELD        = USER

      READ(UNIT        = 20              ,
     _     IOSTAT      = IOS             ,
     _     KEY         = KEY_FIELD       ,
     _     ERR         = 2 )
     _USER_STRUCTURE
      FLAGS            = '    '
 2    IF    (IOS.EQ.0) THEN
          WRITE (*,17)
          CALL LIB$GET_INPUT( FLAGS, 'New flag setting: ',IID )
          IF ( IID .NE. 0 ) THEN
              DO I = 1, 4, 1
                 IF((FLAGS(I:I).NE.'0').AND.(FLAGS(I:I).NE.'1'))
     _           FLAGS(I:I)='0'
              END DO

              USER_STRUCTURE.FLAGS = FLAGS
              REWRITE(UNIT=20,ERR=21) USER_STRUCTURE
          ENDIF

      ELSEIF(IOS.EQ.36) THEN
          WRITE (*,18) USER

      ENDIF
 21   CLOSE(20)
 22   RETURN
      END



      SUBROUTINE    VIEW_ALL_USERS
      CHARACTER     DUMMY
      CHARACTER*80  DATA_DIR
      CHARACTER*132 DATAFILE
      INCLUDE       '($JPIDEF)'
      STRUCTURE /USR/
         CHARACTER*15 USERNAME
         CHARACTER*15 PNAME
         CHARACTER*23 DATE_TIME
         CHARACTER*4  FLAGS
         INTEGER  *4  TIMES
      END STRUCTURE
      RECORD /USR/ USER_STRUCTURE

 11   FORMAT( 1X, '%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%' )
 12   FORMAT( 1X, 'User        : ',A15,20X,'(',A15,')')
 13   FORMAT( 1X, 'Times played: ',I4  )
 14   FORMAT( 1X, 'Last played : ',A23 )
 15   FORMAT( 1X, 'Priv. Flags : ',A4  )
 16   FORMAT( 1X, 'BATTLESHIP has been played ',I4,' times.' )
 18   FORMAT( 1X, 'There are ',I3,' users listed in the database.' )
      CALL GET_JPI( JPI$_IMAGNAME, DATA_DIR , IDUMMY )
      DATAFILE = DATA_DIR(1:II)//'BATTLESHIP_UAF.DAT'
      INUM_USERS       = 0
      INUM_TIMES       = 0
      OPEN(FILE        = DATAFILE        ,
     _     STATUS      = 'OLD'           ,
     _     ORGANIZATION= 'INDEXED'       ,
     _     ACCESS      = 'KEYED'         ,
     _     RECORDTYPE  = 'VARIABLE'      ,
     _     FORM        = 'UNFORMATTED'   ,
     _     CARRIAGECONTROL = 'NONE'      ,
     _     RECL        = 61              ,
     _     KEY         = (1:15:CHARACTER),
     _     ERR         = 22              ,
     _     UNIT        = 20              ,
     _     IOSTAT      = IOS)
      KEY_FIELD        = USER
      IOS              = 0
      DO WHILE( IOS .EQ. 0 )
          READ(UNIT    = 20              ,
     _          IOSTAT = IOS             ,
     _          ERR    = 2 )
     _    USER_STRUCTURE

          WRITE(*,11)
          WRITE(*,12) USER_STRUCTURE.USERNAME, USER_STRUCTURE.PNAME
          WRITE(*,13) USER_STRUCTURE.TIMES
          WRITE(*,14) USER_STRUCTURE.DATE_TIME
          WRITE(*,15) USER_STRUCTURE.FLAGS
          WRITE(*,* ) ' '
          INUM_USERS = INUM_USERS + 1
          INUM_TIMES = INUM_TIMES + USER_STRUCTURE.TIMES
          IICNT = IICNT + 1
          IF ( IICNT .EQ. 3 ) THEN
             CALL LIB$GET_INPUT( DUMMY, '[press RETURN to continue]',I)
             IICNT = 0
          ENDIF

      END DO
  2   CONTINUE
 21   CLOSE(20)
      WRITE (*,16) INUM_TIMES
      WRITE (*,18) INUM_USERS
 22   RETURN
      END


      SUBROUTINE    LIST_ALL_USERS
      CHARACTER     DUMMY
      CHARACTER*80  DATA_DIR
      CHARACTER*132 DATAFILE
      INCLUDE       '($JPIDEF)'
      STRUCTURE /USR/
         CHARACTER*15 USERNAME
         CHARACTER*15 PNAME
         CHARACTER*23 DATE_TIME
         CHARACTER*4  FLAGS
         INTEGER  *4  TIMES
      END STRUCTURE
      RECORD /USR/ USER_STRUCTURE

 13   FORMAT( 1X, 'Username        P.Name          Last Played  ',
     _            '          #XPld Flags')
 14   FORMAT( 1X, A15,1X,A15,1X,A23,1X,I4,1X,A4)
 16   FORMAT( 1X, 'BATTLESHIP has been played ',I4,' times.' )
 17   FORMAT( 1X, '----------------------------------------',
     _            '----------------------------------------')
 18   FORMAT( 1X, 'There are ',I3,' users listed in the database.' )
      CALL GET_JPI( JPI$_IMAGNAME, DATA_DIR , IDUMMY )
      DATAFILE = DATA_DIR(1:II)//'BATTLESHIP_UAF.DAT'
      INUM_USERS       = 0
      INUM_TIMES       = 0
      OPEN(FILE        = DATAFILE        ,
     _     STATUS      = 'OLD'           ,
     _     ORGANIZATION= 'INDEXED'       ,
     _     ACCESS      = 'KEYED'         ,
     _     RECORDTYPE  = 'VARIABLE'      ,
     _     FORM        = 'UNFORMATTED'   ,
     _     CARRIAGECONTROL = 'NONE'      ,
     _     RECL        = 61              ,
     _     KEY         = (1:15:CHARACTER),
     _     ERR         = 22              ,
     _     UNIT        = 20              ,
     _     IOSTAT      = IOS)
      KEY_FIELD        = USER
      IOS              = 0
      WRITE (*,13)
      WRITE (*,17)
      DO WHILE( IOS .EQ. 0 )
          READ(UNIT    = 20              ,
     _          IOSTAT = IOS             ,
     _          ERR    = 2 )
     _    USER_STRUCTURE

          WRITE(*,14) USER_STRUCTURE.USERNAME, USER_STRUCTURE.PNAME,
     _                USER_STRUCTURE.DATE_TIME,USER_STRUCTURE.TIMES,
     _                USER_STRUCTURE.FLAGS

          INUM_USERS = INUM_USERS + 1
          INUM_TIMES = INUM_TIMES + USER_STRUCTURE.TIMES
          IICNT = IICNT + 1
          IF ( IICNT .EQ. 20 ) THEN
             CALL LIB$GET_INPUT( DUMMY, '[press RETURN to continue]',I)
             IICNT = 0
          ENDIF

      END DO
  2   CONTINUE
 21   CLOSE(20)
      WRITE (*,17)
      WRITE (*,16) INUM_TIMES
      WRITE (*,18) INUM_USERS
 22   RETURN
      END



      OPTIONS      /EXTEND_SOURCE
      SUBROUTINE    LIST_TODAYS_USERS
      CHARACTER     DUMMY
      CHARACTER*80  DATA_DIR
      CHARACTER*132 DATAFILE
      CHARACTER*23  TODAYS_DATE
      INCLUDE       '($JPIDEF)'
      STRUCTURE /USR/
         CHARACTER*15 USERNAME
         CHARACTER*15 PNAME
         CHARACTER*23 DATE_TIME
         CHARACTER*4  FLAGS
         INTEGER  *4  TIMES
      END STRUCTURE
      RECORD /USR/ USER_STRUCTURE
 11   FORMAT( 1X, 'Todays date is ',A12)
 13   FORMAT( 1X, 'Username        P.Name          Last Played  ',
     _            '          #XPld Flags')
 14   FORMAT( 1X, A15,1X,A15,1X,A23,1X,I4,1X,A4)
 17   FORMAT( 1X, '----------------------------------------',
     _            '----------------------------------------')
 18   FORMAT( 1X, 'There are ',I3,' users who played today.' )
      CALL GET_JPI( JPI$_IMAGNAME, DATA_DIR , IDUMMY )
      DATAFILE = DATA_DIR(1:II)//'BATTLESHIP_UAF.DAT'
      INUM_USERS       = 0
      INUM_TIMES       = 0
      OPEN(FILE        = DATAFILE        ,
     _     STATUS      = 'OLD'           ,
     _     ORGANIZATION= 'INDEXED'       ,
     _     ACCESS      = 'KEYED'         ,
     _     RECORDTYPE  = 'VARIABLE'      ,
     _     FORM        = 'UNFORMATTED'   ,
     _     CARRIAGECONTROL = 'NONE'      ,
     _     RECL        = 61              ,
     _     KEY         = (1:15:CHARACTER),
     _     ERR         = 22              ,
     _     UNIT        = 20              ,
     _     IOSTAT      = IOS)
      KEY_FIELD        = USER
      IOS              = 0
      CALL LIB$DATE_TIME( TODAYS_DATE )
      WRITE (*,11) TODAYS_DATE(1:12)
      WRITE (*,13)
      WRITE (*,17)
      DO WHILE( IOS .EQ. 0 )
          READ(UNIT    = 20              ,
     _          IOSTAT = IOS             ,
     _          ERR    = 2 )
     _    USER_STRUCTURE
          IF (USER_STRUCTURE.DATE_TIME(1:12) .EQ. TODAYS_DATE(1:12)) THEN
               WRITE(*,14) USER_STRUCTURE.USERNAME, USER_STRUCTURE.PNAME,
     _                     USER_STRUCTURE.DATE_TIME,USER_STRUCTURE.TIMES,
     _                     USER_STRUCTURE.FLAGS

               INUM_USERS = INUM_USERS + 1
               INUM_TIMES = INUM_TIMES + USER_STRUCTURE.TIMES
               IICNT = IICNT + 1
               IF ( IICNT .EQ. 20 ) THEN
                  CALL LIB$GET_INPUT( DUMMY, '[press RETURN to continue]',I)
                  IICNT = 0
               ENDIF
          ENDIF
      END DO
  2   CONTINUE
 21   CLOSE(20)
      WRITE (*,17)
      WRITE (*,18) INUM_USERS
 22   RETURN
      END





      SUBROUTINE    CHANGE_ALL_USERS
      CHARACTER*4   FLAGS
      CHARACTER*80  DATA_DIR
      CHARACTER*132 DATAFILE
      INCLUDE       '($JPIDEF)'
      STRUCTURE /USR/
         CHARACTER*15 USERNAME
         CHARACTER*15 PNAME
         CHARACTER*23 DATE_TIME
         CHARACTER*4  FLAGS
         INTEGER  *4  TIMES
      END STRUCTURE
      RECORD /USR/ USER_STRUCTURE

      CALL GET_JPI( JPI$_IMAGNAME, DATA_DIR , IDUMMY )
      DATAFILE = DATA_DIR(1:II)//'BATTLESHIP_UAF.DAT'

      OPEN(FILE        = DATAFILE        ,
     _     STATUS      = 'OLD'           ,
     _     ORGANIZATION= 'INDEXED'       ,
     _     ACCESS      = 'KEYED'         ,
     _     RECORDTYPE  = 'VARIABLE'      ,
     _     FORM        = 'UNFORMATTED'   ,
     _     CARRIAGECONTROL = 'NONE'      ,
     _     RECL        = 61              ,
     _     KEY         = (1:15:CHARACTER),
     _     ERR         = 22              ,
     _     UNIT        = 20              ,
     _     IOSTAT      = IOS)
      KEY_FIELD        = USER
      IOS              = 0
      CALL LIB$GET_INPUT( FLAGS, 'New flag setting: ',IID )
      IF ( IID .NE. 0 ) THEN
           DO I = 1, 4, 1
                 IF((FLAGS(I:I).NE.'0').AND.(FLAGS(I:I).NE.'1'))
     _           FLAGS(I:I)='0'
           END DO
      ELSE
           IOS = -1

      ENDIF

      DO WHILE( IOS .EQ. 0 )
          READ(UNIT    = 20              ,
     _          IOSTAT = IOS             ,
     _          ERR    = 2 )
     _    USER_STRUCTURE


          USER_STRUCTURE.FLAGS = FLAGS
          REWRITE(UNIT=20,ERR=21) USER_STRUCTURE

      END DO
  2   CONTINUE
 21   CLOSE(20)
 22   RETURN
      END





      SUBROUTINE    DRAW_MENU
      WRITE (*,*) ' Command       Description '
      WRITE (*,*) ' --------------------------------------------------'
      WRITE (*,*) ' INITialize  - 1) Initializes new user access file.'
      WRITE (*,*) '                  All existing records will be '//
     _                               'erased.'
      WRITE (*,*) '               2) Creates files necessary for mailb'
     _                               //'ox'
      WRITE (*,*) '                   name exchange.'
      WRITE (*,*) ' VSingle     - View stats for a single user.'
      WRITE (*,*) ' CSingle     - Change the flags for a single user.'
      WRITE (*,*) ' VAll        - View the stats for all users.'
      WRITE (*,*) ' CAll        - Change the flags for all users.'
      WRITE (*,*) ' VFlags      - View the default flags for new users.'
      WRITE (*,*) ' CFlags      - Change the default flags for new '//
     _                            'users.'
      WRITE (*,*) ' VTime       - View the current times the game can'
      WRITE (*,*) '               be played.'
      WRITE (*,*) ' CTime         Change the times the game can be '//
     _                            'played.'
      WRITE (*,*) ' .E          - Exits BATTLESHIP UAF utility.'
      WRITE (*,*) ' '
      WRITE (*,*) ' MEnu, ?, HElp provides you with this listing. '
      WRITE (*,*) ' --------------------------------------------------'
      RETURN
      END


      SUBROUTINE    INITIALIZE_DATAFILE
      CHARACTER*12  NODE
      CHARACTER*80  DATA_DIR
      CHARACTER*132 DATAFILE
      INCLUDE       '($JPIDEF)'
      STRUCTURE /USR/
         CHARACTER*15 USERNAME
         CHARACTER*15 PNAME
         CHARACTER*23 DATE_TIME
         CHARACTER*4  FLAGS
         INTEGER  *4  TIMES
      END STRUCTURE
      RECORD /USR/ USER_STRUCTURE
 1    FORMAT( 1X, 'User Access File has been created.' )
 2    FORMAT( 1X, 'Could not create ',A<IIJ> )          
 3    FORMAT( 1X, 'Enter the name of the node you wish to install'  )
 4    FORMAT( 1X, 'and press [return].  Press [return] on an empty' )
 5    FORMAT( 1X, 'prompt when you have finished all nodes.'        )
      CALL GET_JPI( JPI$_IMAGNAME, DATA_DIR , IDUMMY )
      DATAFILE = DATA_DIR(1:II)//'BATTLESHIP_UAF.DAT'

      OPEN(FILE        = DATAFILE        ,
     _     STATUS      = 'NEW'           ,
     _     ORGANIZATION= 'INDEXED'       ,
     _     ACCESS      = 'KEYED'         ,
     _     RECORDTYPE  = 'VARIABLE'      ,
     _     FORM        = 'UNFORMATTED'   ,
     _     CARRIAGECONTROL = 'NONE'      ,
     _     RECL        = 61              ,
     _     KEY         = (1:15:CHARACTER),
     _     ERR         = 22              ,
     _     UNIT        = 20              ,
     _     IOSTAT      = IOS)

      
      WRITE (*,3)
      WRITE (*,4)
      WRITE (*,5)
      WRITE (*,*) ' '
      IID = 1
      DO WHILE( IID .NE. 0 )
         CALL LIB$GET_INPUT( NODE, 'Node: ', IID )
         CALL STR$UPCASE( NODE, NODE )
         IF ( IID .NE. 0 ) THEN
         OPEN(FILE=DATA_DIR(1:II)//'BATTLESHIP_'//NODE(1:IID)//'.DAT',
     _        UNIT=1,STATUS='NEW')
          CLOSE(UNIT=1)
         ENDIF
      END DO
      RETURN
 22   IIJ = INDEX( DATAFILE, ' ' )
      WRITE (*,2) 'Could not create '//DATAFILE(1:IIJ-1)
      END


      SUBROUTINE  GET_JPI(  CODE, RETVAL , II)
      INTEGER     STATUS, LIB$GETJPI, CODE
      CHARACTER*(*) RETVAL

      STATUS = LIB$GETJPI( CODE,,,,RETVAL, II )
      IF (.NOT. STATUS ) CALL LIB$SIGNAL( %VAL(STATUS) )

      RETURN
      END

