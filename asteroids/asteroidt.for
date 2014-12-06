      Subroutine 	Top_Ten(This_Score)

      Implicit none
C
      Parameter 
     . 	Esc = 27,
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
     .	sorted

	
      Byte
     .	This_User(12)

      Integer
     .  Len_user

      Integer*2 
     .	Jpi_rec_Word(8)

      integer*4 
     .	Jpi_rec_Long(4)

      Equivalence (Jpi_rec_Word,Jpi_rec_Long)

      Data month_of_year/
     .			'Jan ',
     .			'Feb ',
     .			'Mar ',
     .			'Apr ',
     .			'May ',
     .			'Jun ',
     .			'Jul ',
     .			'Aug ',
     .			'Sep ',
     .			'Oct ',
     .			'Nov ',
     .			'Dec '/

C     Begin

      Type 100,Esc,Esc,Esc,Esc
100   Format(X,A1,'<',A1,'[1;24r',A1,'[H',A1,'[2JPlease Wait ...')
      Jpi_rec_Word(1) = 12
      Jpi_rec_Word(2) = '202'X
      Jpi_rec_Long(2) = %loc(This_USer)
      Jpi_rec_Long(3) = %loc(len_user)
      Jpi_rec_Long(4) = 0
      Call sys$getjpi(%val(0),%val(0),%val(0),
     .		Jpi_rec_Long,
     .		%val(0),%val(0),%val(0))

      Call sys$numTim(date_time,%val(0))
      Year_now  = date_Time(1)
      Month_now  = date_Time(2)

       
1     Open(unit=4,file='Image_dir:Asteroids.acn',form='UNFORMATTED',
     .	recordtype='FIXED',Status='OLD',Recl=1024,IoStat=ErrNum)
      If (Errnum.eq.30) Goto 50
      If (Errnum.gt.1) Goto 999
      read(4) Num_games,month_top,
     .      		month_username,month_name,Month_Score
      read(4) username,name,score,games
      num_games = num_games + 1
      If (Month_top.ne.month_now) Then ! Clear Month
        If (month_top.ne.0) Then 
	   Do J = 1,12 
	     month_username(J,month_top) = Username(J,1)
	     month_name(J,month_top) = name(J,1)
	   enddo
	   month_Score(month_top) = Score(1)
      	endif
	Do I = 1,max_keep
	   Do J = 1,12 
	     username(J,I) = ' '
	     name(J,I) = ' '
	   enddo
	   Score(i) = 0
   	   games(i) = 0
	enddo
	Month_top = Month_now
      endif	  
      I = 1
      J = 0
      Score(max_keep) = 0
      do while ((J.lt.12).and.(Score(I).ne.0))
  	J = 1
   	do While (( Username(J,I).eq.This_User(J)).and.(J.lt.12))
   	  J = J + 1
   	enddo
  	I = I + 1
      enddo
      If ( J.eq.12 ) Then ! if the same username 
     	 I = I - 1
      endif
      Me = I
      If (score(I).eq.0) Then 
      	 Do J = 1,12 
      	   Username(J,I) = this_user(J)
      	   name(J,I) = ' '
         enddo
   	 If ( This_Score.lt.0 ) This_Score = 10
   	 Prev_Score = 0
         Score(I) = This_Score
   	 Games(I) = 1
      Else
         Prev_Score = Score(I)
         Score(I) = Max(Score(I),this_Score)
   	 Games(i) = Games(i) + 1
      endif
      sorted = .false.
      do while (.not.sorted) 
  	sorted = .true.
	Do I=1,max_keep-1
	  IF ( Score(I).Lt.Score(I+1)) Then 
  	      Sorted = .false.
   	      IF (I+1.eq.me) me = Me - 1
	      K=Score(I)
	      Score(I)=Score(I+1)
	      Score(I+1)=K
	      K=games(I)
	      Games(I)=Games(I+1)
	      Games(I+1)=K
	      Do J=1,12
		Temp(J)=name(J,I)
		Name(J,I)=name(J,I+1)
		Name(J,I+1)=Temp(J)
	      enddo
	      Do J=1,12 
		Temp(J)=username(J,I)
		UserName(J,I)=username(J,I+1)
		UserName(J,I+1)=Temp(J)
	      enddo
	  endif
	enddo
      enddo
C
C     Now To display The Top Players Of The Year 
C      
      type 110,Esc,Esc,Year_now-1,Year_now,Esc,Esc
110   Format(X,A1,'[H',A1,'[2J'
     .        ,'Immortal Players For ',I4,' - ',I4,A1,'(0',/
     .	     X,'oooooooooooooooooooooooooooooooooo',A1,'(B',/
     .	     X,'Month  Username  Name         Score',/)
       If (month_now.eq.1) month_now = 13
   	
       Do M = month_now - 1 ,1,-1
         If ( Month_Score(M).gt.0) Then 
      	   type 120,Month_of_year(M),
     .		(Month_username(K,M),K=1,10),
     .		(month_name(K,M),K=1,12),month_Score(m)
      	 endif
       enddo
       Do M = 12 ,month_now,-1
         If ( Month_Score(M).gt.0) Then 
      	   type 120,Month_of_year(M),
     .		(Month_username(K,M),K=1,10),
     .		(month_name(K,M),K=1,12),month_Score(m)
      	 endif
       enddo
120   Format(2X,A4,2X,10A1,12A1,I6)

      type 210,Esc,Esc,Month_of_year(Month_top),
     .		Esc,num_games,Esc,Esc,Esc,Esc,Esc
210   Format(X,A1,'[H',A1,'[40C       Top Players For ',A4,
     .		A1,'[1m',I6,' Games',A1,'[0m',/
     .	        X,A1,'[40C       ',A1,
     .		'(0ooooooooooooooooooo',A1,'(B',/
     .	        X,A1,'[40CNum Username  Name         Score   Games'/)
      Do I = 1,12
         If ( Score(I).ne.0) Then 
      	   type 220,Esc,I,(username(K,I),K=1,10),
     .		(name(K,I),K=1,12),Score(I),
     .		Games(I)
        endif
      enddo
220   Format(X,A1,'[40C',I3,X,10A1,12A1,I6,I6)
      
      If ( This_Score.Ge.Prev_Score.and.Me.le.12) Then 
         Type 311,Esc,Me,Prev_Score,Esc,Esc,This_Score
      else
         Type 312,Esc,Me,Prev_Score,This_Score
      endif
311   Format(X,A1,'[18;1H',
     .     4X,'You Are Seated At ',I2,' In Asteroids    ',
     .     6X,'Previous Score ',I6,//,X,
     .     4X,A1,'[1m','Enter Your Name [ Return to leave ]  ',
     .     A1,'[0m',6X,'Current  Score ',I6)
312   Format(X,A1,'[18;1H',
     .     4X,'You Are Seated At ',I2,' In Asteroids    ',
     .     6X,'Previous Score ',I6,//,X,
     .     4X,'Not The Best ....                    ',
     .     6X,'Current  Score ',I6)
      If ( Me.LE.12.and.This_Score.GE.Prev_Score) then 
	 If ( Me + 4.ge.10) then 
	   Type 320,Esc,Me + 4                 
320	   Format(X,A1,'[',I2,';55H',$)
	 else 
	   Type 321,Esc,me + 4
321	   Format(X,A1,'[',I1,';55H',$)
	 endif
	 Accept 323, I, ( Name(K,Me),K = 1 ,I )
323	 Format(Q,<I>A1)
      Endif
      Type 324,Esc
324   Format(X,A1,'[22;1H')
      rewind(4)
      write(4) Num_games,month_top,
     .     month_username,month_name,Month_Score
      write(4) username,name,score,Games
      Close (4)
      Return
C
C

C
50    type 51,Esc,Esc,Esc
51    Format(X,A1,'<',A1,'[2J',A1,'[1;1HPlease Wait ...')
      Call Sleep(4)
      Goto 1
C
C
C
999   type 1000
1000  Format(X,'Can''t Find Asteroids.Acn Creating New File')
      Open(unit=4,file='Image_dir:Asteroids.Acn',form='UNFORMATTED',
     .	recordtype='FIXED',Status='New',Recl=1024,IoStat=ErrNum)
      num_games = 0
      Do I = 1,12
        Do J = 1,12 
            month_username(J,I) = ' '
	    month_name(J,I) = ' '
	  enddo
	  month_Score(i) = 0
      enddo
      Month_top = 0
      write(4) Num_games,month_top,
     .		month_username,month_name,Month_Score
      write(4) Username,name,score,Games
      close(4)
      goto 1
      End
