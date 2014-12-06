      Integer Function	Last_Score

      Implicit none
C
      Parameter 
     .	max_keep = 31 ! Max num Scores held + 1
      
      Byte
     .	Temp(12),
     .  Username(12,max_keep),
     .	Name(12,max_keep),
     .  Month_Username(12,12),
     .	Month_Name(12,12)

      Integer*4
     .  month_of_Year(12)

      Integer*2
     .  Date_Time(7)
     
      Integer
     .	This_Score,
     .  Prev_Score,
     .	Errnum,
     .  Month_now,
     .  Month_top,
     .	Year_now,
     .	num_games,
     .  month_Score(12),
     .  Games(max_keep),
     .	Score(max_keep),
     .  Me,
     .	I,
     .	J,
     .	K,
     .  M

      logical*1
     .	same

	
      Byte
     .	This_User(12)

      Integer*2
     .  Len_user

      Integer*2 
     .	Jpi_rec_Word(8)

      integer*4 
     .	Jpi_rec_Long(4)

      Equivalence (Jpi_rec_Word,Jpi_rec_Long)

C     Begin

      Len_User = 0 
      Jpi_rec_Word(1) = 12
      Jpi_rec_Word(2) = '202'X
      Jpi_rec_Long(2) = %loc(This_USer)
      Jpi_rec_Long(3) = %loc(len_user)
      Jpi_rec_Long(4) = 0
      Call sys$getjpi(%val(0),%val(0),%val(0),
     .		Jpi_rec_Long,
     .		%val(0),%val(0),%val(0))

       
1     Open(unit=4,file='Image_dir:Asteroids.acn',form='UNFORMATTED',
     .	recordtype='FIXED',Status='OLD',Recl=1024,IoStat=ErrNum,readonly)
      If (Errnum.eq.30) Goto 50
      If (Errnum.gt.1) Goto 999
      read(4) Num_games,month_top,
     .      		month_username,month_name,Month_Score
      read(4) username,name,score,games
      I = 0
      Same = .false.
      Do While (.Not.same.and.I.Lt.(max_keep-1)) 
        I = I + 1
        same = .true.
        J = 1
        do while (same.and.J.le.len_user)
           If (Username(J,I).ne.This_User(J)) Then 
             Same = .false.
           else
             J = J + 1
           endif
        enddo
      enddo
      If (same) Then 
         Last_Score = Score(I)
      Else
     	 Last_Score = 0
      endif
      Close(4)
      return

C
50    continue
      Call Sleep(4)
      Goto 1
C
C
C
999   last_score = 0
      return

      End
