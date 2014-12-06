!
!  BATTLE_ARRAY.INC
!
!  Contains the status messages of the ships as their strengths are
!  being changed.
!
!  Ray Renteria
!  RR62C22B@SWTEXAS    ACM_CSA@SWTEXAS
!  Southwest Texas State University
!  (512) 396 - 7216
!
!

      CHARACTER*9        BATTLESHIP( BAT_STRENGTH ),
     _                   CRUISER   ( CRU_STRENGTH ),
     _                   DESTROYER ( DES_STRENGTH ),
     _                   PT_BOAT   ( PT_STRENGTH  ),
     _                   SUBMARINE ( SUB_STRENGTH ),
     _                   CARRIER   ( CAR_STRENGTH )

      BATTLESHIP(1) = 'Critical'
      CRUISER(1)    = 'Critical'
      DESTROYER(1)  = 'Critical'
      PT_BOAT(1)    = 'Critical'
      SUBMARINE(1)  = 'Critical'
      CARRIER(1)    = 'Critical'

      BATTLESHIP(2) = 'Crippled'
      CRUISER(2)    = 'Nominal'
      DESTROYER(2)  = 'Crippled'
      PT_BOAT(2)    = 'Undamaged'
      SUBMARINE(2)  = 'Nominal'
      CARRIER(2)    = 'Crippled'  

      BATTLESHIP(3) = 'Nominal'
      CRUISER(3)    = 'Undamaged'
      DESTROYER(3)  = 'Damaged'
      SUBMARINE(3)  = 'Undamaged'
      CARRIER(3)    = 'Damaged'

      BATTLESHIP(4) = 'Damaged'
      DESTROYER(4)  = 'Undamaged'
      CARRIER(4)    = 'Undamaged'

      BATTLESHIP(5) = 'Undamaged'
