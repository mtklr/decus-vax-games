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
C     LOGUSER         Logs the user's attempt to play the game.
C     FILL_STRUCTURE  Fills the /USR/ structure with miscellaneous information.
C
      SUBROUTINE    LOGUSER
      CHARACTER*120 DATAFILE
      CHARACTER*15  KEY_FIELD
      LOGICAL       TIME_OKAY

      INCLUDE      'BATTLE.INC'

      STRUCTURE /USR/
         CHARACTER*15 USERNAME
         CHARACTER*15 PNAME
         CHARACTER*23 DATE_TIME
         CHARACTER*4  FLAGS
         INTEGER  *4  TIMES
      END STRUCTURE
      RECORD /USR/ USER_STRUCTURE
          
      CALL FILL_STRUCTURE( USER_STRUCTURE )

      II       = ILN( IMAGE_DEFAULT_DIR )
      DATAFILE = IMAGE_DEFAULT_DIR(1:II)//'BATTLESHIP_UAF.DAT'

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
     _     SHARED                        ,
     _     IOSTAT      = IOS)

      IOS=0
      KEY_FIELD        = USER_STRUCTURE.USERNAME

      READ(UNIT        = 20              ,
     _     IOSTAT      = IOS             ,
     _     KEY         = KEY_FIELD       ,
     _     ERR         = 2 )
     _USER_STRUCTURE

 2    IF    (IOS.EQ.0) THEN
         USER_STRUCTURE.TIMES  = USER_STRUCTURE.TIMES + 1
         CALL LIB$DATE_TIME(     USER_STRUCTURE.DATE_TIME )
         REWRITE(UNIT=20,ERR=21) USER_STRUCTURE

      ELSEIF(IOS.EQ.36) THEN
         USER_STRUCTURE.TIMES  = 1
         WRITE(UNIT=20,  ERR=21) USER_STRUCTURE

      ENDIF
 21   CLOSE(21)
      IF(USER_STRUCTURE.FLAGS(2:2) .NE. '1' ) THEN
         CALL NOT_ALLOWED_TO_PLAY
      ENDIF
    
      IF (.NOT. TIME_OKAY(IDUMMY)) THEN
         IF (USER_STRUCTURE.FLAGS(1:1) .NE. '1') THEN
             CALL NOT_A_SCHEDULED_TIME
         ENDIF
      ENDIF

 22   RETURN
      END


      SUBROUTINE FILL_STRUCTURE( USER_STRUCTURE )
      INCLUDE      'BATTLE.INC'

      STRUCTURE /USR/
         CHARACTER*15 USERNAME
         CHARACTER*15 PNAME
         CHARACTER*23 DATE_TIME
         CHARACTER*4  FLAGS
         INTEGER  *4  TIMES
      END STRUCTURE
      RECORD /USR/ USER_STRUCTURE

      USER_STRUCTURE.USERNAME = OUR.UIC
      USER_STRUCTURE.PNAME    = OUR.NICKNAME
      USER_STRUCTURE.FLAGS    = '0100'
      USER_STRUCTURE.TIMES    = 0

      CALL LIB$DATE_TIME( USER_STRUCTURE.DATE_TIME )

      RETURN
      END
