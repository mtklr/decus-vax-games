!
!  BATTLE.INC
!
!  Contains necessary common blocks for job process (uic, process name),
!  system services (mailbox, channel, etc.), and SMG$ information.
!
!  Ray Renteria
!  RR62C22B@SWTEXAS    ACM_CSA@SWTEXAS
!  Southwest Texas State University
!  (512) 396 - 7216
!
!
      PARAMETER          PT_STRENGTH = 2
      PARAMETER          SUB_STRENGTH= 3
      PARAMETER          CAR_STRENGTH= 4
      PARAMETER          BAT_STRENGTH= 5
      PARAMETER          CRU_STRENGTH= 3
      PARAMETER          DES_STRENGTH= 4

      COMMON /PLS/       M_GRID            ,
     +                   OUR               ,
     _                   THEIR             ,
     +                   WERE_FIRST        ,
     +                   THEYRE_FINISHED   , 
     _                   PLAYING           , 
     _                   IM_FINISHED       ,
     _                   WE_CANCELLED_THE_GAME,
     _                   GETTING_INKEY     ,
     _                   WAITING_FOR_COMLINK,
     _                   IN_HELP           
      COMMON /JPI/       CURRENT_IMAGE_NAME, 
     _                   IMAGE_DEFAULT_DIR ,
     +                   CURR_NODE
      COMMON /SMG/       DISPID            , 
     _                   DISPID2           , 
     _                   PASTEID           , 
     _                   KEYBID            , 
     _                   INSERT_CR         ,
     _                   ITHEIR_ROW        , 
     _                   ITHEIR_COL        ,  
     _                   THEIR_TURN        , 
     _                   AT_COMMAND_LINE   , 
     _                   IOUR_ROW          , 
     _                   IOUR_COL

      STRUCTURE /INFO/
           INTEGER       BATTLESHIP        , 
     _                   SUBMARINE         , 
     _                   PT_BOAT           ,
     _                   DESTROYER         , 
     _                   CRUISER           , 
     _                   CARRIER           ,
     _                   MBX_CHAN          , 
     _                   NICKNAME_LEN      , 
     _                   SHIPS_DESTROYED   ,
     _                   UIC_LEN
           CHARACTER*12  MBX_NAME          , 
     _                   UIC
           CHARACTER*15  NICKNAME
      END STRUCTURE

      RECORD /INFO/      OUR, THEIR

      REAL               DISPID            , 
     _                   PASTEID           ,  
     _                   KEYBID            , 
     _                   DISPID2
      LOGICAL            WERE_FIRST        , 
     _                   INSERT_CR         , 
     _                   THEIR_TURN        ,
     _                   PLAYING           , 
     _                   THEYRE_FINISHED   , 
     _                   IM_FINISHED       ,
     _                   AT_COMMAND_LINE   ,
     _                   WE_CANCELLED_THE_GAME/.FALSE./,
     _                   THEY_CANCELLED_THE_GAME/.FALSE./,
     _                   GETTING_INKEY/.FALSE./,
     _                   WAITING_FOR_COMLINK,
     _                   IN_HELP
      CHARACTER*1        M_GRID( 9, 15 )
      INTEGER            ITHEIR_ROW/2/     ,
     _                   ITHEIR_COL/4/     , 
     _                   IOUR_ROW  /2/     , 
     _                   IOUR_COL  /39/
      CHARACTER*39       CURRENT_IMAGE_NAME, 
     _                   IMAGE_DEFAULT_DIR ,
     +                   CURR_NODE
