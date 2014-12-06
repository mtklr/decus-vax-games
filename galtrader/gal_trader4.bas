1   ! ----------------------------------------------------------------------
    !        Galactic Trader v. 4.55  by Stephan Meier    8/87
    !    (c) Copyright 1989,1990,1991 by Stephan Meier.  All rights reserved.
    ! ----------------------------------------------------------------------
    %IDENT "GT V4.55"

    %LET %SECURITY = %VARIANT
    %IF (%SECURITY = 0) %THEN 
      %PRINT "0 : LOW SECURITY    (superuser,override, debug)"
    %ELSE %IF (%SECURITY = 1) %THEN
      %PRINT "1 : MEDIUM SECURITY (superuser,no override, no debug)"
    %ELSE %IF (%SECURITY = 2) %THEN
      %PRINT "2 : HIGH SECURITY   (no superuser, no override, no debug)"
    %ELSE 
	%ABORT "Invalid Security Level specified"
    %END %IF
    %END %IF
    %END %IF

    a%=NOCTRLC
    option angle=degrees
    randomize
 
    ! ----------------------- Constants -------------------------------
    declare string  constant superusermode="10203040"  ! must be 8 chars
    declare string  constant policemode="54321"        ! must be 5 chars
    declare string  constant overridemode="xxxyyy"     
    declare integer constant ntequip=24
    declare integer constant ntcargo=10
    declare integer constant ntships=23
    declare integer constant maxships=200
    declare integer constant maxscores=10
    declare integer constant ntrank=10
    declare integer constant ntlegal=5
    declare integer constant bufsize=2000
    declare integer constant maxplayers=4
    declare integer constant maxevents=20
    declare integer constant startmoney=200150
    declare integer constant nactions=22
    declare integer constant timelimit=15
    declare integer constant ctrlclimit=1000
    declare integer constant maxplanets=200
    declare integer constant ECM_COST=2
    declare integer constant LSJ_COST=4
    declare integer constant CLOAK_COST=3
    declare integer constant TRUE=1
    declare integer constant FALSE=0
    ! ------------------------- Types ---------------------------------
    %include "gal-trader.h"
    
    ! --------------------- Variables --------------------------------
    declare equip_type e(ntequip)        ! info on equip sold on planet
    declare player_type pr               ! your info
    declare shipstats_type s(-1 to ntships)  ! general stats on ships
    declare event_type ev(maxevents)     ! Event queue
    declare SINGLE points(ntrank)        ! points needed to reach next rank
    declare long return_status
    declare string last_recipient	 ! last message recipient
    declare integer melt		 ! set if your drive melts
    declare integer l1			 ! temporary variable for ship pos
    dim rank$(ntrank)                    ! rank names
    dim legal$(ntlegal)                  ! legal status names
    dim tracomp%(maxplanets,13)		 ! trading computer data
    dim s0$(15),s1$(15),s2$(15),s3$(15),s4$(15) ! planet status descriptions
    dim xp(maxplanets), yp(maxplanets), zone(maxplanets) 
    dim name$(maxplanets)
    dim exist(maxships)                  ! valid targets array
    dim action_cmd$(20)			 ! commands to be parsed
    dim action_cost$(nactions,2)	 ! each action is move, combat, or free
    dim g_option$(6)			 ! current settings of game options
    
    ! --------------------- Map definitions ----------------------------
    map (planetmap) planetinfo_type pt      ! static stats on planet
    map (playermap) player_type op          ! other player info
    map (actionmap) string planetaction=15,SINGLE noship,    &
       targets_type t(maxships), cargo_type c(ntcargo)
    map (scoremap) integer dummy, score_type sc(maxscores)
    %include "common.h"			    ! common block with display
    common long timebuffer, fill1	    ! buffer for system time value
 
    ! ------------------- External Declarations ------------------------
    external sub lib$spawn (string)       ! used to execute dcl commands
    external sub lib$sys_trnlog(string by desc, INTEGER by ref, &
                 string by desc, INTEGER by ref, INTEGER by ref)
    external sub display(integer, string)
    external string function pnamegen(string by desc)
    external sub lib$put_screen(STRING by desc, INTEGER by ref, &
                INTEGER by ref, INTEGER by ref)
    external sub sys$gettim
    external long function lib$getjpi(LONG by ref, LONG by ref, STRING by desc &
		,LONG by ref, STRING by desc, WORD by desc)
    external long constant jpi$_username

    ! ------------------- correct atan function ------------------------
    def single atan(single x,y)
      angle=0
      if x<>0 then                                   
        angle=atn(abs(y)/abs(x))                     
        if sgn(x)+sgn(y)=0 then                      
          angle=angle+2*(90-angle)                   
  	end if
  	if sgn(y)=-1 or (sgn(y)=0 and sgn(x)=-1) then
    	  angle=angle+180                            
  	end if                                  
      else                                           
  	if sgn(y)=1 then                             
    	  angle=90                                   
  	else                                         
    	  angle=270                                  
  	end if                            
      end if
      atan=angle
    end def

    ! find the next available ship insertion point.
    !
    def integer next_ship
       l12%=1
       until (l12%=200 or t(l12%)::ship=0 or t(l12%)::ship = -1)
         l12%=l12%+1
       next
       next_ship = l12%
    end def

    ! Returns true if string is a  valid (signed) integer
    def integer integerp(string str_val$)
      integerp=TRUE
      if len(str_val$)=0 then integerp=FALSE end if
      for cic=1 to len(str_val$)	 
	if (cic=1 and mid$(str_val$,cic,1)="-" and len(str_val$)>1) then
	  iterate
	end if
        if ascii(mid$(str_val$,cic,1))<48 or ascii(mid$(str_val$,cic,1))>57 then
	  integerp=FALSE
        end if
      next cic
    end def


    def integer valid_id(string x)
      valid_id = 1
      if x <> "GPHQ" then
        when error in
	  find #2%, key #0% eq x, wait 60%
        use
  	  call display(33,"The trader id "+x+" is invalid.")
  	  valid_id = 0
        end when
	free #2%
      end if
    end def
    
    %IF (%SECURITY = 0)
    %THEN
    def integer valid_override()
      a = noecho(0%)
      input "Enter Override Password to proceed> ";a$
      a = echo(0%)
      a$=edit$(a$,32%)      
!      b$=date$(0%)
!      a=int((val(mid$(b$,1,2)+mid$(b$,8,2))-1)*val(mid$(b$,8,2)+ &
!	mid$(b$,1,2))/23+6)
!      if a=val(a$) then
      if a$=overridemode then
        valid_override = 1
      else
        valid_override = 0	! should be 0
      end if
    end def
    %ELSE %IF (%SECURITY = 1 or %SECURITY = 2)
      %THEN
      def integer valid_override()
        valid_override = 0
      end def
      %END %IF
    %END %IF
 
    ! checkint returns 1 if string is all integers, -1 otherwise
    def integer checkint(string str_val$)
      checkint=1
      for cic=1 to len(str_val$)
        if ascii(mid$(str_val$,cic,1))<48 or &
		ascii(mid$(str_val$,cic,1))>57 then
	  checkint=-1
        end if
      next cic
      checkint=intp
    end def
           

    ! ----------------------- Initializations --------------------------
    when error in
    melt = 0
    pr::time_owned = 1
    pr::chan1=1\pr::chan2=2
    pr::score=0\pr::thargoid=0\pr::escapes=0 ! player stats initialization
    pr::on_ground=1\pr::energy=0\pr::shiptype=0
    pr::kills=0\pr::moves=0\pr::credits=startmoney
    pr::legal=1\pr::rank=1\pr::scanrange=3\pr::shipnum=0\police_mode%=0
    pr::planet=int(numplanets*rnd+1)\pr::rpos=0  ! starting planet - check file
    pr::message=""\menumode$="none"
    pr::date(0) = 0
    pr::date(1) = 0
    pr::pmode = 0			  ! mode of player (god, police)
    nocheck=0				  ! timestamp checking enabled
    ecm_status%=0			  ! ecm (if present) is off
    super_user_mode%=0			  ! super_use_mode is off
    debug%=0                              ! debug%=1 for debug, 0 for normal
    last_recipient = ""			  ! no last message recipient
    g_option$(1)="OFF"\g_option$(2)="OFF" ! game_options
    g_option$(3)="OFF"\g_option$(4)="ON"
    g_option$(5)="OFF"\g_option$(6)="OFF"
    ! find and hash real ID
    return_status = lib$getjpi(jpi$_username,,,,n$,)
    n$=edit$(n$,128%)
    if len(n$)=3 then n$=n$+"X" end if
    n$=right$(n$,len(n$)-3)
    call lib$sys_trnlog("SYS$LOGIN",a%,a$,0%,0%)
    a$=edit$(a$,160%)			  ! convert to uppercase 
    a$=mid$(a$,len(a$)-4,4)
    if left$(a$,1)="[" then
      a$=mid$(a$,2,3)+"X"
    end if
    pr::username=a$ ! get username from log. name
    if left$(n$,4) <> left$(a$,4) then
      fake_id=1
    else
      fake_id=0
    end if
    numevents=0                           ! No events in event queue
    gal_flag=1				  ! Assume galaxy exists - check later
    restore
    for i=1 to 10\read s1$(i)\next i      ! read in planet desc messages
    for i=1 to 11\read s2$(i)\next i
    for i=1 to 12\read s3$(i)\next i
    for i=1 to 10\read s4$(i)\next i
    for i=1 to 10\read s0$(i)\next i
    for i=1 to ntequip\read e(i)::ename, e(i)::usedeprice\next i
    for i=1 to ntcargo
      read c(i)::trade, c(i)::tprice, c(i)::ttech, checksum, c(i)::unit
      if ((4*c(i)::tprice)^2+17*c(i)::ttech^3) <> checksum then
        goto 10000
      end if
    next i
    for i=1 to ntlegal\read legal$(i)\next i

    for i=1 to ntships
        read s(i)::sname, s(i)::menergy, s(i)::slaser, s(i)::mlaser, &
        s(i)::mcargo, s(i)::mmissile, s(i)::rarity, s(i)::cost, &
        s(i)::mdrive, s(i)::mfuel, s(i)::reliability, s(i)::resale,checksum
    next i

    for i=1 to ntrank
        read rank$(i), points(i)
    next i
    for i=1 to nactions
	read action_cost$(i,1),action_cost$(i,2)
    next i

    ! ---------------------------------------------------------------
    !                      Set up Files
    ! ---------------------------------------------------------------

    when error in
      open "gal_disk:gal-planets2.dat" as file #1%, organization indexed fixed, &
          allow modify, access modify, primary key pt::pname duplicates, &
          map planetmap, contiguous, filesize 100

      open "gal_disk:gal-players1.dat" as file #2%, organization indexed fixed, &
         allow modify, access modify, primary key op::username, &
         map playermap, contiguous, filesize 100
 
      open "gal_disk:gal-action3.dat" as file #3%, organization indexed fixed, &
         allow modify, access modify, primary key planetaction, &
         map actionmap, contiguous, filesize 100, extendsize 50
    use
      print "Error opening game files - See your game manager."
      continue 10000
    end when
    free #3%\free #1%
 
    when error in                     ! enable control C trapping
       restore #1%\get #1%, wait 60   ! check if galaxy exists
    use
       gal_flag = 0
    end when 
    when error in                    ! check if any players in game      
      restore #2%\get #2%, wait 60   ! eof error ==> create new gal
    use
      if gal_flag=1 then
	input "Previous Galaxy Saved.  Do you want to keep it (y/n) ";a$
	a$=edit$(a$,32%)
        if a$<>"N" then
	  continue 547	! keep galaxy
        end if
      end if
      continue 2000	! create new galaxy
    end when
547 free #2%\restore #1%
550 numplanets=0
    when error in
      while numplanets<maxplanets
        get #1%, wait 60
        free #1%
        numplanets=numplanets+1
        xp(numplanets)=pt::xp
        yp(numplanets)=pt::yp
        zone(numplanets)=pt::zone
        name$(numplanets)=pt::pname
      next
    use 
    end when
        
600  ! ---------------------------------------------------------------
     !                        Start Game
     ! ---------------------------------------------------------------
     no_save_file=0
     a$="gal_disk:gal-saves2.dat"
     open a$ as file #4%, organization indexed fixed, &
         allow modify, access modify, primary key op::username, &
         map playermap
     when error in
       get #4%, key #0% eq pr::username, wait 60
     use
       close #4%
       no_save_file=1
     end when
     if no_save_file=1 then
       ! check if player is already in game
       when error in 
	 get #2%, key #0% eq pr::username, wait 60
         print "Already in Game.  Enter N for a newgame, S to SU current game."
         print "Note:  Selecting S will result in your game being locked."
         input "N or S > ";sel$
         sel$=edit$(sel$,32%)
!         if op::date(1)<>0 then
!           a = noecho(0%)
!           print
!           input "You have a password set, Enter password: ";a$
	   a$=edit$(a$,32%)	! convert to uppercase
!           a = echo(0%)
           ! now decrypt
!           p = 0
!           for i=1 to len(a$)
!             p=p+ascii(mid$(a$,i,1))*i
!           next i
!           if p<>op::date(1) then goto bad_pass end if
!         end if
	 if sel$="N" or sel$="n" then
           print "Starting a new game."
           delete #2%
           free #2%
           goto init_planet
         else
	   pr = op
           print "SUing your game.  See your game manager to get it unlocked."
           pr::date(1)=11
           gosub 5100
           goto 8000
         end if
       use
         if fake_id=1 then
           print "You are not allowed to use an ID alias when creating"
           print "a character.  ID aliases may only be used to link to"
           print "an existing character."
           print
           if valid_override = 1 then
             continue init_planet
	   else
             continue 10000
           end if
	 else
           continue init_planet
	 end if
       end when
     else    ! player has a save file
       ! if player has a save file, and is already in game - ditch game
       when error in
	 find #2%, key #0% eq pr::username
	 delete #2%\free #2%
       use
	 free #2%
       end when
     end if
     pr = op
     print "Successful revival from suspended animation."
     if pr::energy <0 then
	print "You have DIED in suspended animation..."
	delete #4%
	goto 10000
     end if
     if pr::shiptype = 0 then
	print "No current ship.  Assigning a Yugo..."
	pr::shiptype = 23
	pr::energy = s(23)::menergy
	pr::credits = pr::credits - s(23)::cost
     end if
     if pr::date(1)=11 then
        call sys$gettim(timebuffer)
        ! if time is up, then allow revival
       if abs((fill1-pr::timestamp(2)))>ctrlclimit then
         print "Your CTRL-C lockout has been automatically purged."
         pr::date(1)=0
       else
         print "Your save file is locked due to use of CTRL-C.  Note that"
	 print "CTRL-C is *NOT* to be abused.  Your game will be automatically"
         print "freed in ";ctrlclimit-(fill1-pr::timestamp(2));" ticks."
         print
         goto bad_pass
       end if
     end if
     if pr::date(1)<>0 then
        print
        a = noecho(0%)
        input "You have a password set, Enter password: ";a$
	a$=edit$(a$,32%)	! convert to uppercase
        a = echo(0%)
        ! now decrypt
        p = 0
        for i=1 to len(a$)
          p=p+(ascii(mid$(a$,i,1))+1)*i
        next i
        if p<>pr::date(1) then 
          print "User authorization failure - incorrect password."
          goto bad_pass 
        end if
      end if
      goto 611
bad_pass:
    ! wrong password
    when error in
      if valid_override = 1 then
         pr::date(1)=0
        goto 611 
      end if
    use
    end when

    if fake_id = 0 then
      input "Do you want to DELETE this saved game?  (y/n)";a$
      if a$="y" or a$="Y" then
        delete #4%
        free #4%
        print "Saved Game DELETED.  Re-run GT to start a new game."   
      end if
    end if
    close #4%
    goto 10000

611 ! success revival from su
    delete #4%
    close #4%
    ! turn on scanner if player is in space
    if pr::rpos=1 then scanner_on=1\new_smg=1 end if
    revived$="OK"

init_planet:
    get #1%, key #0 eq name$(pr::planet), wait 60\free #1%
    gosub 1900
    gosub restore_options
    call display(2,)		      	       ! initialize screens
    call display(22,)			       ! display input window
    if revived$<>"OK" then
      gosub 7800                               ! initial display
      call display(18,)
      gosub 6000                               ! ship selection
    else
      call display(18,)
    end if
    call display(4,)
    op=pr
    gosub 1700  			       ! display status
    gosub timestamp
    put  #2				       ! update timestamp
    free #2 
    sender$="GPHQ"
    if revived$="OK" then
      m$=pr::username+ " has just been revived from suspended animation."
    else
      m$=pr::username+" has just been granted a trading license."
    end if
    chan=0
    gosub broadcast_message
    free #1%
 
    ! ----------------------------------------------------------------
    !                          Main Input Loop
    ! ----------------------------------------------------------------
    a%= CTRLC
    while 1=1
      get #2%, key #0% eq pr::username, wait 60\free #2%
      if mid$(op::message,1,1)<>" " then		! process incoming
        gosub 1200
      end if
      menumode$="main"
720   option$="MAIN> "\call display(1,option$)
      sender$=pr::username
      select option$
	   case "?","help"
               gosub help
           case "q"
               gosub 900
                  if quit=1 then
                  a$="You retire."
                  call display(23,a$)
                  goto 8000
               end if
           case "su"
               if pr::on_ground<>1 then
                 call display(33,"You have to land to suspend.")
               else
!                 if pr::date(1)=0 then
!                   a = noecho(0%)
!                   a$="Enter password> "
!		   call display(1,a$)
!		   a$=edit$(a$,32%)
!                   a = echo(0%)
                   ! now encrypt
!                   pr::date(1) = 0
!                   for i=1 to len(a$)
!                     pr::date(1)=pr::date(1)+ascii(mid$(a$,i,1))*i
!                   next i
!                 end if
                 gosub 5100
               end if
           case "ba"
               if pr::on_ground<>1 then
                 call display(33,"You have to land to bank.")
               else
                 gosub 1800
               end if
           case "w"
               gosub 1300
           case "p"
               gosub 2100
	       call display(17,)
	       call display(31,)
           case "c"
              gosub 2200
           case "j"
               gosub 2300
           case "l"
               gosub 2400
           case "t"
               gosub 2500
           case "o"
               gosub 2800
           case "s"
               gosub 1000
           case "b"
               gosub 1100
	   case "tu"
	       gosub tune_comlink
	   case ""
		! do nothing
           case else
               call display(33,"Invalid Command - Enter '?' for help")
               goto 720
      end select
      for i=1 to ntrank
        if pr::score>=points(i) then
          pr::rank=i
        end if
      next i
      get #2%, key #0% eq pr::username, wait 60
      gosub timestamp
      pr::timestamp(1) = op::timestamp(1)
      pr::timestamp(2) = op::timestamp(2)
      op::legal=pr::legal\op::rank=pr::rank\op::kills=pr::kills
      op::credits=pr::credits\op::planet=pr::planet\op::score=pr::score
      op::shiptype=pr::shiptype
      update #2%\free #2%
    next                                         ! end main loop

Timestamp:
    ! ----------------------- Timestamp ---------------------------
    call sys$gettim(op::timestamp(1))
    return

Checktime:
    ! ----------------------- Check time --------------------------
    when error in
      call sys$gettim(timebuffer)
      ! if time is up, then remove offending record
      if abs((fill1-op::timestamp(2)))>timelimit then
	if op::username<>pr::username then
	  get #2%, key #0% eq op::username, wait 60%
	  expired_planet=op::planet
	  gosub other_save		! try to save player
	  delete #2%
	  get #3%, key#0% eq name$(expired_planet), wait 60%
	  for i=1 to maxships
	    if t(i)::username=op::username then
	      t(i)::ship=-1
	      t(i)::sintent=-1
	      t(i)::player=0
	      t(i)::username="t up"
	    end if
	  next i
	  update #3%
	end if
      end if
    use
    end when
    free #2%\free #3%      
    return

tune_comlink:
     ! -------------- Tune comlink radio channels ------------------
     a$="Channel 1 setting (01 to 99) ["+str$(pr::chan1)+"]> "
     call display(1,a$)
     a = val(a$)
     if a<0 or a>99 or a<>int(a) then
       call display(33,"Invalid Channel Number")
       goto tune_comlink
     end if
     if a<>0 then
       pr::chan1 = a
     end if
tune_second:
     a$="Channel 2 setting (01 to 99) ["+str$(pr::chan2)+"]> "
     call display(1,a$)
     a = val(a$)
     if a<0 or a>99 or a<>int(a) then
       call display(33,"Invalid Channel Number")
       goto tune_second
     end if
     if a<>0 then
       pr::chan2 = a
     end if

! update channels and mode in the player record
update_player: 
     get #2%, key# 0% eq pr::username, wait 60%
     op::chan1 = pr::chan1
     op::chan2 = pr::chan2
     op::pmode = pr::pmode
     update #2%\free #2%

     return

900  ! -------------------------------------------------------------
     !                          Quit
     ! -------------------------------------------------------------
     p$= "REALLY QUIT? (Y/N) "\call display(1,p$)
     if p$="y" then
        quit=1\m$=pr::username+" has retired."\sender$="GPHQ"
        chan=0
        gosub broadcast_message
     else quit=0
     end if
     return
 
1000 ! ------------------------------------------------------------
     !                         Send
     ! ------------------------------------------------------------
     sender$=pr::username
1020 if last_recipient = "" then
	u$="SEND TO> "
     else
	u$="SEND TO ("+last_recipient+") "
     end if
     call display(1,u$)
     u$=edit$(u$,32%)
     if u$="" and last_recipient <> "" then
	u$=last_recipient
     end if
     if pr::on_ground = 0 then
       for i=1 to noship
         if u$=edit$(t(i)::username,128%) and t(i)::player=0 then
           goto send_valid
         end if
       next i
     end if
     if valid_id(u$)=0 then 
       return
     end if
send_valid:
     last_recipient = u$

     m$="MESSAGE> "
     call display(34,m$)

     if m$ = "" then return end if
     if super_user_mode%=0 then
       if instr(1%,m$,"%%")<>0 or instr(1%,m$,"@")<>0 then 
         call display(33,"Control Characters not allowed.")
         goto 1020
       end if
     end if
     if u$="GPHQ" then
        if left$(m$,3)="who" then 
          goto 1300

	! police mode for Public Safety 
        else 
           if left$(m$,5)=policemode then
	    police_mode%=1
	  %IF (%SECURITY = 0 or %SECURITY = 1)
          %THEN
		! Super user mode for "testing"
	  else 
             if left$(m$,8)=superusermode then
	      if len(m$)>9 then			! get mode bits			
                pr::pmode = val(mid$(m$,10,5))
              else
                pr::pmode = 0
              end if
	      super_user_mode%=1
              gosub update_player
	    else					! else, clear it all
              police_mode%=0
              super_user_mode%=0
              pr::pmode = 0
              gosub update_player
            end if
	  %END %IF
          end if
          sender$="GPHQ"\u$=pr::username
          m$="Insufficient authorization - Get lost."
        end if
     end if
     if pr::on_ground =0 then
       for i=1 to noship
          if u$=edit$(t(i)::username,128%) and t(i)::player=0 then
             gosub 1400
             if u$="" then 
	       return
             end if
          end if
       next i
     end if
     m$ = " "+m$

send_message:
     when error in
       get #2%, key #0% eq u$, wait 60
       if mid$(op::message,1,1)=" " then
          op::message=sender$+":"+m$+"@"
       else
	  op::message=left$(op::message,instr(1,op::message,"@ "))+sender$ &
	   +":"+m$+"@"
       end if
       update #2%\free #2%
     use
       call display(33,"The trader id "+u$+" is invalid.")
       free #2%
     end when
     return
 
1100 ! -------------------------------------------------------------
     !                       Broadcast
     ! -------------------------------------------------------------     
     m$= "CHANNEL (RETURN for public)> "
     call display(34,m$)
     chan=val(m$)
     if chan<0 or chan>99 or chan<>int(chan) then
       call display(33,"Invalid channel Number.")
       goto 1100
     end if
     if chan<> 0 then
       m$="MESSAGE["+str$(chan)+"]> "
     else
       m$="MESSAGE> "
     end if
     call display(34,m$)
     if police_mode%=1 then
       sender$="GPHQ"
     else 
       sender$=pr::username
     end if
     if m$="" then return end if
     if super_user_mode%=0 then
       if instr(1%,m$,"%%")<>0 or instr(1%,m$,"@")<>0 then
         call display(33,"Control Characters not allowed.")
         return
       end if
     end if

broadcast_message:
     restore #2%
     u$="0000"
     if chan<>0 then
       m$="["+str$(chan)+"] '"+m$+"'"
     else
       m$ = " '"+m$+"'"
     end if
     when error in
       for j=1 to maxplayers
         get #2%, key #0 gt u$, wait 60
         u$=op::username
         if (op::chan1=chan or op::chan2=chan) or (chan=0) or (op::pmode>1)then
	   gosub checktime
           gosub send_message
         end if
         free #2%
       next j
     use
     end when
     return
 
1200 ! -------------------------------------------------------------
     !                      Print Messages
     ! -------------------------------------------------------------
     i% = 1

print_loop:
     e% = instr(i%,op::message,"@")
     if e%=0 then
	goto done_print
     else
      if mid$(op::message,i%+5,2)="%%" then        ! decode event + enqueue it
         if numevents<20 then numevents=numevents+1 end if
         ev(numevents)::event=mid$(op::message,i%+7,2)
         ev(numevents)::source=mid$(op::message,i%,4)
         select ev(numevents)::event
           case "ab"
           case "eb"
           case "mi","la","mo"
             ev(numevents)::dest=mid$(op::message,i%+9,4)
	     ev(numevents)::p1=val(mid$(op::message,i%+13,e%-i%-14))
         end select
      else					! not event, show it
	call display(23,mid$(op::message,i%,e%-i%))
      end if
     end if
     i% = e%+1					! i points to start of next
     goto print_loop

done_print:					! all done, clear incoming
     op::message = ""
     find #2%, key #0% eq pr::username, wait 60%
     update #2%
     free #2%
     return
 

1300 ! -------------------------------------------------------------
     !                      Galactic Report
     ! -------------------------------------------------------------
     if scanner_on=1 then call display(12,) end if
     call display(4,) 
     if pr::legal>1 then
        a$="Surrender to the nearest Galactic Police ship immediately."
	call display(24,a$)
     else
        u$="0000"
        a$="Galactic Police Status Report as of "+time$(0%)+" GST"
        call display(23,a$)
        a$="Trader ID       Commander       Legal Status     Rank" &
		+"       Kills      Planet"
        call display(24,a$)
        call display(24,"")
        when error in
          for j=1 to maxplayers
            get #2%, key #0 gt u$, wait 60
            free #2%\u$=op::username\a$=op::personalname
            m$=u$+space$(16-len(u$))+a$+space$(16-len(a$))
            a$=legal$(op::legal)
            if(op::pmode>100) then
	      b$ = "**GOD**"
            else
              b$=rank$(op::rank)
            end if
	    c$=str$(op::kills)
            m$=m$+a$+space$(17-len(a$))+b$+ &
               space$(14-len(b$))+c$+space$(8-len(c$))+name$(op::planet)
            call display(24,m$)
          next j
       use
         free #2%
	 continue 1320
       end when
     end if
1320 if scanner_on=1 then
	new_smg=1
	gosub 3000
     end if
     return
 
1400 ! ---------------------------------------------------------------
     !                Computer Controlled Ship Replies
     ! ---------------------------------------------------------------
     sender$=t(i)::username\u$=pr::username
     if t(i)::ship<>1 then
       if rnd>.6 and t(i)::ship<>10 then
          m$="Shut up or I'll E-Bomb you."
       else u$=""
       end if
       return
     end if
     if pr::legal=1 then m$="ComLink Abuse is a Galactic Offense." end if
     if pr::legal=2 then
       if (left$(m$,1)="a" or left$(m$,1)="A") then
          if menumode$="manual" then
            m$="Good.  I'm glad you've decided to cooperate.  Stand by for"
            m$=m$+" boarding."
            get #3%, key #0% eq name$(pr::planet), wait 60
            t(i)::sintent=15
            update #3%\free #3%
            pr::legal=1
          else
            m$="You are not authorized to respond from hyperspace, SCUM."
          end if
       else
          if left$(m$,1)="r" or left$(m$,1)="R" then
            m$="As you like it... You're doomed now."
            t(i)::sintent=2
            pr::legal=3
          else
            m$="Please Accept or Refuse boarding, this is your last chance."
          end if
       end if
     end if
     if pr::legal>2 then
        m$="It's too late for words now, you're going to PAY with your life.."
     end if
     return



     ! add a player to the current action file.  Note - this routine
     ! returns with the action file locked (if rec found) An update on it should
     ! be done as soon as possible following return from this code.       
add_player_to_action:
     ! print "Adding player to action record"
     new_action = 0
     when error in
       get #3%, key #0% eq name$(pr::planet), wait 60
     use
       if err=155 then
         new_action = 1
         ! no action record -> must create one 
         planetaction = name$(pr::planet)
         for i=1 to maxships
           t(i)::sintent=0\t(i)::player=0\t(i)::others(1)=0\t(i)::others(2)=0
           t(i)::ship=0\t(i)::smissile = 0
	   t(i)::special=0
         next i
         noship = 0
       else
         continue 9000
       end if
     end when

     i=next_ship
     ! print "Adding into slot ";i
     if i=200 then goto 9000 end if	! action file capacity exceeded
     if i > noship then
       noship = i
     end if
     pr::shipnum = i
     ! add record
     t(i)::username=pr::username\t(i)::senergy=pr::energy
     t(i)::smissile=pr::equip(13)\t(i)::sintent=0
     t(i)::spos=pr::rpos\t(i)::player=2\t(i)::others(1)=0
     t(i)::others(2)=0
     t(i)::ship=pr::shiptype
     ! cargo carried    cargo(1) is # of item, cargo(2) is amount
     t(i)::cargo(1)=0\t(i)::cargo(2)=0
     for a1=1 to ntcargo		! determine primary cargo
       if pr::cargo(a1)>t(i)::cargo(1) then
         t(i)::cargo(1)=a1
         t(i)::cargo(2)=pr::cargo(a1)
       end if
     next a1

     ! far away thargs appear when someone jumps into a WZ.
     if (pt::zone=1) and noship<140 then
       b=int(pr::thargoid*rnd+3)
     else 
       b=0
     end if
     where = int (50+50*rnd)
     for a1=1 to b
       if noship<150 then
         noship=noship+1
         t(noship)::ship=9
         t(noship)::spos=int(5*rnd + where)
         shipno=noship
         gosub 3100
         t(noship)::senergy=s(9)::menergy
         t(noship)::smissile=s(9)::mmissile
         t(noship)::username="TH"+str$(int(noship))
       end if
     next a1     
     return
     
delete_player_from_action:
     when error in
       get #3, key #0% eq name$(oldplanet), wait 60
     use
       if err=155 then
         ! print "Not in an old action record."
	 continue done_delete ! action record has disappeared
       else
       	 continue 9000		! can't handle error
       end if
     end when     
     ! print "Deleted from old action record"
     keep=0                     ! set keep if someone else there
     for i=1 to maxships
       if t(i)::player<>0 and t(i)::username<>pr::username then keep=1
       end if
       if t(i)::username=pr::username and (t(i)::player=1 or &
					  t(i)::player=2) then
          t(i)::ship=-1
	  t(i)::sintent=-1
          t(i)::username="GONE"
          t(i)::player=0
       end if
     next i
     if keep=1 then		! save action record (other player present)
       ! print "Saving the old action record"
       update #3%
       free #3%
     else			! trash action record
       ! print "Trashing the old action record - no one else there."
       delete #3%
       free #3%
     end if
done_delete:
     return
 
1700 ! -------------------- Display Status Line ---------------
     dpos=pr::rpos*2000\ddir=pr::direction\denergy=pr::energy\dfuel=pr::fuel
     dmissiles=pr::equip(13)\dcredits=pr::credits\call display(3,)
     cloak=pr::cloak\ lsj = pr::lsj\ecm = ecm_status%
     return
 
1800 ! ------------------------- Bank ---------------------------
     if scanner_on=1 then call display(12,) end if
     call display(4,)
     if pt::tech<3 then
        a$= "Banking facilities not available on "+edit$(pt::pname,128%)+"."
        call display(23,a$)
        return
     end if
     if revived$="OK" then
	a$= "The Bank is temporarily closed for restructuring."
        call display(23,a$)
	return
     end if
	call display(4,)
        a$= "Welcome to the local branch of the Galactic Bank."
	call display(24,a$)
        call display(24,"")
        a$= "1) Request a Loan."
	call display(24,a$)
        a$= "2) Repay a Loan."
	call display(24,a$)
        a$= "3) ComLink credits transfer."
	call display(24,a$)
        a$="Select option (0 to exit.)"
	call display(23,a$)	
1810    a$="OPTION> "
        call display(1,a$)\a=val(a$)
        select a
          case 1
	    if loan_reject=1 then
	      a$= "You've already been rejected.  Get Out!"
              call display(23,a$)
	      goto 1810
	    end if
            a$="Enter amount to borrow> "\call display(1,a$)\a=val(a$)
	    if a<=0 then
		call display(33,"Cancelled.")
		goto 1810 
	    end if
	    if a+int(a/2*rnd)>pr::credits*2 then goto reject end if
	    if pr::legal<>1 then goto reject end if
	    if pr::escapes>50 then goto reject end if
	    if pr::debt>0 then goto reject end if
	    pr::interest=20+int(10*rnd)
	    a$= "Congratulations - Your loan request has been approved."
            call display(23,a$)
	    a$= "You are hereby loaned "+str$(a)+&
		" credits at a per jump interest"
            call display(23,a$)
	    a$= "rate of "+str$(pr::interest)+ &
		"%.  The principal and interest are"
            call display(23,a$)
	    a$= "due after 5 jumps."
            call display(23,a$)
	    pr::due=pr::moves+5
	    pr::credits=pr::credits+a
	    gosub 1700
	    pr::debt=a
	    loan_reject = 1
	    goto 1810
reject:	    a$= "We regret to inform you that we cannot approve your loan."
            call display(23,a$)
	    loan_reject=1
	  case 2
	    a$= "You owe "+str$(pr::debt)+" due in "+str$(pr::due-pr::moves)+ &
		" jumps."
            call display(23,a$)
	    a$="Enter amount to repay> "\call display(1,a$)\a=val(a$)
	    if a<=0 or pr::credits-a < 0 then 
		call display(33,"Cancelled.")
		goto 1810 
	    end if
	    pr::credits=pr::credits-a
	    gosub 1700
	    pr::debt=pr::debt-a
	    a$= "Thank you for your payment."
            call display(23,a$)
	    if pr::debt<0 then pr::debt=0 end if
          case 3
            if pr::moves<5 and super_user_mode%=0 then
	      a$= "As a new trader, you are not authorized to transfer credits."
              call display(23,a$)
            else
	      u$ = "Enter beneficiary of transfer> "
              call display(1,u$)
              u$=edit$(u$,32%)
              if u$ = "" then
	        goto 1810
	      end if
	      if valid_id(u$) = 0 then
	        goto 1810
              end if
              a$= "Enter amount to be sent> "
              call display(1,a$)
              a=val(a$)
              if a<0 or a>pr::credits-pr::debt then
                call display(33,"Invalid amount.")
                goto 1810
              end if
	      if a>1000000 then
		call display(33,"Credit Transaction cannot be performed without Federation approval.")
		goto 1810
	      end if
              pr::credits=pr::credits-a
              get #2%, key #0% eq pr::username, wait 60
	      op::credits=pr::credits
              update #2%\free #2%
              gosub 1700
              sender$=pr::username
              m$="%%mo"+u$+str$(int(a*9/10))+"."
              a$= "Sending... Transaction charges: "+str$(int(a*1/10))
              call display(23,a$)
              gosub send_message
            end if
          case 0
            goto 1850
       end select
     goto 1810
1850 if scanner_on=1 then
        new_smg=1
        gosub 3000
     end if
     return

init_equipment:
     factor=1-(pt::tech*2)/100+(10-pt::population)/20
     fuelprice=int(5-pt::tech/2+int(2*rnd))
     for i=1 to 24
       e(i)::eprice=-1
     next i
     if pt::tech>8 then
       e(16)::eprice=int(15000*factor+2000*rnd)
       e(23)::eprice=int(6000*factor+1000*rnd)
       e(14)::eprice=int(60000*factor+6000*rnd)
       e(18)::eprice=int(18000*factor+3000*rnd)
     end if
     if pt::tech=10 then
       e(19)::eprice=int(40000*factor+2000*rnd)
       e(15)::eprice=int(70000*factor+5000*rnd)
       if rnd>.98 then e(22)::eprice=int(50000*factor+5000*rnd) end if
     end if
     if pt::tech>7 then
       e(5)::eprice=int(8000*factor+1000*rnd)
       e(6)::eprice=int(8000*factor+1000*rnd)
       e(9)::eprice=int(5000*factor+500*rnd)
       e(12)::eprice=800*factor
       e(24)::eprice=int(4000*factor+1000*rnd)
     end if
     if pt::tech>3 then
       e(3)::eprice=int(4000*factor+500*rnd)
       e(4)::eprice=int(4000*factor+500*rnd)
       e(7)::eprice=int(2000*factor+200*rnd)+int(1500+1000*rnd)*pr::escapes
       e(11)::eprice=int(5000*factor+200*rnd)
     end if
     e(1)::eprice=int(500*factor+100*rnd)
     e(2)::eprice=int(500*factor+100*rnd)
     e(8)::eprice=int(800*factor+200*rnd)
     e(10)::eprice=int(700*factor+100*rnd)
     e(13)::eprice=50
     shipsale=pt::tech+pt::population
     for i=1 to ntships
       s(i)::soldhere=0
       if ((shipsale*rnd*rnd)>=s(i)::rarity) and (s(i)::rarity<9) then
         s(i)::soldhere=1
       end if
       if i=9 and pt::zone<>4 then s(i)::soldhere=0 end if
       if pt::zone=1 and i=12 and rnd>.5 then s(i)::soldhere=1 end if
       s(i)::neg_cost = s(i)::cost
       s(i)::temperature = -1
     next i
     return

1900 ! ---------------------- Initialize Planet -------------------
     gosub init_equipment
     for i=1 to 10
        c(i)::pprice=int(c(i)::tprice*(.7+rnd/2))
        if pt::tech<c(i)::ttech then
          c(i)::qtrade=-1
        else
          c(i)::qtrade=pt::population*10+int(50*rnd)
        end if
        if pt::zone=1 and c(i)::qtrade<>-1 then c(i)::qtrade=c(i)::qtrade*2+ &
           int(100*rnd)
        end if
        if pt::zone=4 and c(i)::qtrade<>-1 then c(i)::qtrade=c(i)::qtrade*3
	end if
        if pt::zone=2 and c(i)::qtrade<>-1 then c(i)::qtrade=c(i)::qtrade+ &
           int(30*rnd)
	end if
      next i
 
      if pt::trade=1 then c(1)::qtrade=c(1)::qtrade+50+ &
         int(10*pt::population*rnd)
      end if
      if pt::trade=1 then c(9)::pprice=c(9)::pprice+int(10*rnd) end if
      if pt::trade=3 then c(9)::pprice=c(9)::pprice-int(10*rnd) end if
      if pt::trade=3 then c(9)::qtrade=c(9)::qtrade+int(50*rnd) end if
      if pt::trade=5 then c(6)::pprice=c(6)::pprice+int(20*rnd) end if
      if pt::tech>8 then c(8)::pprice=c(8)::pprice-int(15*rnd) end if
      if pt::government=10 or pt::government=5 then c(7)::pprice= &
         int(c(7)::pprice/2)
      end if
      if pt::population>7 then c(1)::pprice=c(1)::pprice+int(2*rnd+1) end if
      if pt::tech<5 then c(6)::pprice=c(6)::pprice-int(10*rnd+5) end if
      if pt::tech<5 then c(7)::pprice=c(7)::pprice-int(20*rnd) end if
      if pt::tech>8 then c(7)::pprice=c(7)::pprice+int(50*rnd+10) end if
      if pt::trade=10 then c(4)::pprice=int(c(4)::pprice/2) end if
      if pt::tech>6 then c(5)::pprice=c(5)::pprice+int(10*rnd+6) end if
      if pt::tech<4 then c(3)::pprice=c(3)::pprice-int(5*rnd+1) end if
      if pt::law<5 then c(2)::pprice=c(2)::pprice+int(10*rnd+10) end if
      if pt::trade<5 then c(1)::pprice=c(1)::pprice+int(2*rnd) end if
      if pt::trade=2 then c(1)::pprice=c(1)::pprice+int(2*rnd) end if
      if (pt::trade=6 and (c(2)::pprice>0)) then c(2)::pprice=c(2)::pprice- &
         int(3*rnd)
      end if
      c(10)::pprice=int(50*rnd+50)
      if c(3)::pprice=0 then c(3)::pprice=1 end if
      if pt::zone=1 then
        c(8)::pprice=c(8)::pprice*2+int(70*rnd+20)
        c(9)::pprice=c(9)::pprice*3
        c(6)::pprice=c(6)::pprice-int(60*rnd+50)
      end if
      ! set  base prices to initial current prices
      for i=1 to ntcargo
        c(i)::bprice = c(i)::pprice
      next i
      if pt::zone=4 then c(7)::pprice=int(c(7)::pprice/2) end if
      if pt::zone=3 then c(10)::pprice=c(10)::pprice-int(10*rnd+5) end if
      return
 
2000 ! --------------------------------------------------------------
     !                      Create New Galaxy
     ! --------------------------------------------------------------
     print "Please wait while I set off the Big Bang..."
     close #1%
     close #3%
     when error in
       kill "gal_disk:gal-planets2.dat"
       kill "gal_disk:gal-action3.dat"
       open "gal_disk:gal-planets2.dat" as file #1%, organization indexed fixed, &
          allow modify, access modify, primary key pt::pname duplicates, &
          map planetmap, contiguous, filesize 100
       open "gal_disk:gal-action3.dat" as file #3%, organization indexed fixed, &
          allow modify, access modify, primary key planetaction, &
          map actionmap, contiguous, filesize 100, extendsize 50
     use
       print "Insufficient Priv to initiate Big Bang - See your Game Manager."
       continue 10000
     end when
     restore #1%
     ! loop in which galaxy initialized
     numplanets = 100      ! 100 planets standard galaxy size
2030 for i=1 to numplanets
        pt::pname=edit$(pnamegen(""),32%)
        pt::zone=int(10*rnd+1)
        pt::xp=int(60*rnd+1)+int(20*rnd+1)-40
        if sqr(pt::xp^2+pt::yp^2)<5 then pt::zone=5
        end if
        pt::population=int(10*rnd+1)
        if pt::zone=1 then pt::government=int(3*rnd)+8
        end if
        if pt::zone=2 then pt::government=int(4*rnd)+5
        end if
        if pt::zone=3 then
           pt::government=int(10*rnd+1)
        else
           if pt::zone=4 then pt::government=4
             else
                pt::government=int(4*rnd+1)
             end if
        end if
        pt::law=int(10*rnd+1)
        pt::trade=int(12*rnd+1)
        select pt::zone
	  case 1
	    pt::tech=int(5*rnd+3)
          case 2
	    pt::tech=int(4*rnd+7)
          case 3
            pt::tech=int(5*rnd+1)
          case 4
	    pt::tech=int(2*rnd+9)
	  case else
            pt::tech=int(9*rnd+1)
 	end select
        pt::yp=int(60*rnd+1)+int(20*rnd+1)-40
	put #1%
      next i
     free #1%
     goto 550   ! read in local galaxy data
 
2070 ! --------------- Generate Random Name -------------------
     letter=int(2*rnd)
     n$=''
     v$="AEIOU"
     c$="ABCDEFGHIJKLMNOPQRSTUVWXYZ"
     for j=1 to int(rnd*3+4)
        if letter=1 then
           a=int(5*rnd+1)\n$=n$+mid$(v$,a,1)\letter=0
        else
           a=int(26*rnd+1)\n$=n$+mid$(c$,a,1)\letter=1
        end if
     next j
     return
 
2100 ! ----------------- Describe Planet ---------------------
     call smg$begin_pasteboard_update(new_pid)
     if scanner_on=1 then call display(12,) end if
     call display(32,)
     call display(29,)
     call smg$end_pasteboard_update(new_pid)
     a$="Data on:         "+edit$(pt::pname,128%)
     call display(30,a$)
     r=sqr(pt::xp^2+pt::yp^2)
     ra=atan(pt::xp,pt::yp)
     a$=""
     call display(30,a$)
     a$="Classification:  "+s0$(pt::zone)
     call display(30,a$)
     a$="Galactic Coords. Ring:"+str$(int(r))+" Ray:"+ &
     str$(int(ra))
     call display(30,a$)
     a$="Population:      "+str$(pt::population)+" Billion"
     call display(30,a$)
     a$="Government:"
     call display(30,a$)
     a$="  "+s1$(pt::government)
     call display(30,a$)
     a$="Law Level:"
     call display(30,a$)
     a$="  "+s2$(pt::law)
     call display(30,a$)
     a$="Trade Class:"
     call display(30,a$)
     a$="  "+s3$(pt::trade)
     call display(30,a$)
     a$="Technical Level: "
     call display(30,a$)
     a$="  "+s4$(pt::tech)
     call display(30,a$)
     if scanner_on=1 then
       new_smg=1\gosub 3000
       call display(31,)
     end if
     return

update_prices:
     ! check whether prices on a planet are to be changed
     when error in
       get #3%, key#0% eq name$(pr::planet), wait 60%
       tp=75*(3+pt::population)
       for i=1 to ntcargo
         if c(i)::qtrade>tp then 
           c(i)::pprice=int(c(i)::bprice/2+EXP(-(c(i)::qtrade-tp)/(2*tp))* &
                 c(i)::bprice/2)
         else
           c(i)::pprice=c(i)::bprice
         end if
       next i
       update #3%\free #3%
     use
     end when
     return
 
2200 ! ----------------------- Status -------------------------
     call display(4,)
     if scanner_on=1 then call display(12,) end if
     a$="----- Commander "+edit$(pr::personalname,128%)+" ------"
     call display(24,a$)
     a$=""
     call display(24,a$)  
     a$="Rank:               "+rank$(pr::rank)
     call display(24,a$)  
     a$="Kills:              "+str$(pr::kills)
     call display(24,a$)
     a$="Legal Status:       "+legal$(pr::legal)
     call display(24,a$)  
     call display(24,"")
     call display(24,"------- Ship Status -------")
     a$="Type:               "+ edit$(s(pr::shiptype)::sname,128%)
     call display(24,a$)
     a$="Empty Cargo Space:  "+ str$(pr::maxcargo)+" units"
     call display(24,a$)
     a$="Jump Range:         "+ str$(pr::maxfuel)+" light years"
     call display(24,a$)
     a$="Maneuver Speed:    "+ str$((pr::speed)*2000)+" km/s"
     call display(24,a$)
     a$="Comlink1, Comlink2: "+str$(pr::chan1)+", "+str$(pr::chan2)
     call display(24,a$)
     call display(24,"")
     if pr::totcargo<>0 then
	col_pos=48
	row_pos=1
        a$="Cargo carried  Amount"
        call display(27,a$)
        n = 0
        for i=1 to ntcargo
          if pr::cargo(i)<>0 then
            n = n + 1
            a$=left$(c(i)::trade,13)+"  "+str$(pr::cargo(i))
            a$=a$+ " "+edit$(c(i)::unit,128%)+"s" 
	    row_pos=n + 2
            call display(27,a$)
          end if
       next i
     end if    
     call display(17,)
     call display(4,)
     a$="Equipment mounted"
     call display(24,a$)
     call display(24,"")
     for i=1 to ntequip
       if i<>13 and pr::equip(i)=1 then 
         a$=" - "+edit$(e(i)::ename,128%)
         call display(24,a$)
       end if
     next i
     if scanner_on=1 then
        new_smg=1
        gosub 3000
     end if
     return
 
2300 ! ------------------- Interplanetary Jump ----------------------
     if pr::on_ground=1 then melt=0 end if
     if melt=3 then
       a$="Your ionization reactor is shut down - No jump is possible."
       call display(23,a$)
       return
     end if
     if scanner_on=1 then call display(12,) end if
     call display(4,)
     call display(21,)
     a$="Worlds within jump range from "+edit$(pt::pname,128%)+ &
      " are listed above."
     call display(23,a$)
     a$="World          Distance    Ring   Ray      Zone"
     call display(24,a$)
     p_count=1
     for i=1 to numplanets
       ra=atan(xp(i),yp(i))
       r=sqr(xp(i)^2+yp(i)^2)
       d=sqr((xp(i)-pt::xp)^2+(yp(i)-pt::yp)^2)
       if d<=pr::fuel and pt::pname<>name$(i) then
         if p_count/14=int(p_count/14) then 
	   call display(17,)
           call display(4,)
         end if
         a1$=str$(int(d))
	 a2$=str$(int(r))
	 a3$=str$(int(ra))
         a$= name$(i)+a1$+space$(12-len(a1$))+a2$+space$(8-len(a2$))+ &
           a3$+space$(8-len(a3$))+s0$(zone(i))     
        p_count=p_count+1
	call display(24,a$)     
       end if
     next i
     call display(23,"")
2320 while 1=1
       b$=""
       a$="World to jump to> "\call display(1,a$)
       if a$="" then
         if scanner_on=1 then
           new_smg=1
           gosub 3000
         end if
         return
       end if
       b$=edit$(a$,32%)
       for i=1 to numplanets
         if b$=name$(i) then 
	   goto 2330 
         end if
       next i
       call display(33,"Planet name not found.")
     next
2330 newplanet=i\d=sqr((xp(newplanet)-pt::xp)^2+(yp(newplanet)-pt::yp)^2)
     if int(d)>pr::fuel and super_user_mode%=0 then
       call display(33,"That world is out of jump range.")
       goto 2320
     end if
     if pr::planet=newplanet then melt=2 end if
     call display(4,)
     pr::fuel=pr::fuel-int(d)
     oldplanet=pr::planet
     pr::planet=newplanet
     pr::moves=pr::moves+1
     a$="===== ENGAGING HYPERSPACE DRIVE ====="
     call display(24,a$)     
     if numevents>0 then gosub 5200 end if
     row_pos=3
     col_pos=1
     for i=3 to 1 step -1
       a$="HYPERDRIVE ACTIVATION INITIATING: "+str$(i)
       call display(27, a$)
       sleep 1
       if rnd*100>(s(pr::shiptype)::reliability) and melt=2 and &
							pr::on_ground=0 then
	 call display(24,"")
         a$="IONIZATION REACTOR OVERLOAD - EMERGENCY ABORT SEQUENCE ACTIVATED"
         call display(24,a$)
         melt=1
       end if
     next i
     if melt=1 and rnd>.5 then
       a$="ABORT PROCESS COMPLETE - REACTOR STABILIZED"
       call display(24,a$)
       pr::planet=oldplanet
       melt=3
     end if
     if melt=1 then
       a$="REACTOR SHUT DOWN FAILED" 
       call display(24,a$)
       condition$="RED"\call display(16,condition$)
     end if
     row_pos=5
     col_pos=1
     a$="===== HYPERSPACE DRIVE ENGAGED ====="
     call display(27,a$)
     call display(24,"")
     call display(24,"")
     pr::ban=0\pr::on_ground=0
     temp = 100 - pr::time_owned/50*s(pr::shiptype)::reliability
     if temp< s(pr::shiptype)::reliability then 
	temp = s(pr::shiptype)::reliability 
     end if
     if ((rnd*100>temp or melt=1) &
	and melt<>3 and super_user_mode%=0) then
       a$="MISJUMP - Your ship shakes and jerks wildly before stablizing !!!!"
       call display(24,a$)
       condition$="YEL"\call display(16,condition$)
       pr::planet=int(numplanets*rnd)+1
     end if
     ! update names to be displayed on scanner.
     pname=name$(pr::planet)
     ray=atan(xp(pr::planet),yp(pr::planet))
     ring=sqr(xp(pr::planet)^2+yp(pr::planet)^2)
     get #1%, key #0% eq name$(pr::planet), wait 60\free #1%
     a$="Jump completed - You are orbiting "+edit$(pt::pname,128%)+"."
     call display(24,a$)
     revived$=""
     gosub 4900\gosub 4800	! tharg messages, zone messages
     gosub 2100			! describe planet
     loan_reject=0		! free to apply again
     pr::debt=pr::debt+int(pr::debt*(pr::interest/100))
     if pr::due-pr::moves=0 and pr::debt>0 then
	m$= "Complete Loan repayment of "+str$(pr::debt)+" is due on landing."
	sender$="GBNK"
	u$=pr::username
	gosub send_message
     end if
     if pr::due-pr::moves<0 and pr::debt>0 then
	m$="You are OVERDUE on your loan repayment.  Your account has been@"+ &
		"turned over to the police for collection."
	sender$="GBNK"
	u$=pr::username
	gosub send_message
	pr::legal=2
     end if
     if pr::due-pr::moves<-10 and pr::debt>0 then pr::legal=3 end if
     pr::rpos=int(12*rnd+5)\pr::direction=1
     gosub delete_player_from_action	! delete from last planet
add_to_action:
     gosub add_player_to_action		! add to new planet action file

     if new_action = 0 then	! stuff already there - free up action file
       update #3%\free #3%
       gosub init_equipment
       gosub update_prices
       new_smg=1\gosub 3000
       return
     end if

     ! first player to arrive here - initialize everything....
     ! regenerate quantities available
     gosub 1900
     ! determine ships present on completing jump
     if (pt::zone=2 and rnd>.5) or (pt::zone=3 and rnd>.2) or (pt::zone=4) then
       goto 2381
     end if
     if pt::zone>4 and pt::population>3 and pt::tech>3 then
       ! starbase
       noship=noship+1
       t(noship)::ship=20
       t(noship)::senergy=s(20)::menergy
       t(noship)::spos=pt::population
       t(noship)::sintent=0
       t(noship)::smissile=130
       t(noship)::username="SB-1"
     end if
     for i=1 to pt::law
       a=rnd
       if a>.6 then
	  ! police ships
          noship=noship+1
          t(noship)::ship=1
          t(noship)::senergy=s(1)::menergy
          t(noship)::spos=int(15*rnd+1)
          t(noship)::sintent=0
          t(noship)::smissile=s(1)::mmissile
          t(noship)::username="GP"+STR$(noship)
       end if
     next i
2381 for i=1 to pt::government
       a=rnd
       if a>.7 then
	  ! arbitrary ships other than police
          noship=noship+1
          t(noship)::ship=int(9*rnd+2)
          if t(noship)::ship=10 then t(noship)::ship=19 end if
          t(noship)::spos=int(15*rnd+1)
          shipno=noship
          gosub 3100
          t(noship)::senergy=s(t(noship)::ship)::menergy
          if rnd>.97 and pr::moves>10 then 
	    t(noship)::senergy=t(noship)::senergy+100 
	  end if
          t(noship)::smissile=s(1)::mmissile
          t(noship)::username="S"+str$(noship)+str$(int(10*rnd))
       end if
       if a>.5 then
	  ! asteroids
          noship=noship+1
          t(noship)::ship=10
          t(noship)::spos=int(15*rnd+1)
          shipno=noship
          gosub 3100
          t(noship)::senergy=s(10)::menergy
          t(noship)::smissile=s(10)::mmissile
          t(noship)::username="-"
       end if
       if a>.7 then t(noship)::sintent=0
       end if
     next i
     a=rnd\where=5
     if (a>.9 and pt::zone>4) or (a>.3 and pt::zone=1) or (pt::zone=4) then
       b=int((pr::thargoid/1.5)*rnd+1)
     else b=0
     end if
     if b>3 and rnd>.78 then
       ! thargoid mothership
       noship=noship+1
       t(noship)::ship=21
       t(noship)::spos=int(10*rnd)
       shipno=noship
       gosub 3100
       t(noship)::senergy=s(21)::menergy
       t(noship)::smissile=s(21)::mmissile
       t(noship)::username="TMS1"
     else
       ! thargoid raid
       for i=1 to b
         noship=noship+1
         t(noship)::ship=9
         t(noship)::spos=int(5*rnd+where)
         shipno=noship
         gosub 3100
         t(noship)::senergy=s(9)::menergy
         t(noship)::smissile=s(9)::mmissile
         t(noship)::username="TH"+str$(int(noship))
       next i
     end if
     if pr::moves>25 or debug%=1 then
       if rnd>.965 or debug%=1 then
	 ! exotic ship encounter
         noship=noship+1
         t(noship)::ship=int(4*rnd+15)
         !t(noship)::ship = 15
	 t(noship)::spos = int(7*rnd + 5)
         shipno=noship
         gosub 3100
         t(noship)::senergy=s(t(noship)::ship)::menergy
         t(noship)::smissile=s(t(noship)::ship)::mmissile
         t(noship)::username="S"+str$(noship)+str$(int(10*rnd))
       end if
     end if
     if pt::zone=1 then gosub 4500 end if
     gosub galactic_fleet
     if pr::rank>3 and pr::legal>2 then gosub 4030 end if
     if pr::rank>1 and pr::legal>2 then gosub 4000 end if
     when error in
       put #3%\free #3%
     use
       if err=134 then		! retry adding record if duplicate key
         continue add_to_action
       end if
     end when
     new_smg=1\gosub 3000
     return
 
2400 ! ------------------- land on planet -----------------------
     ! check if already on the ground.
     jump_flag=0
     if pr::on_ground=1 then
        call display(33,"You're already on the planetary surface.")
        return
     end if
     ! display computer activated if in computer mode
     get #3%, key #0 eq name$(pr::planet), wait 60
     t(pr::shipnum)::player = 1
     update #3%\free #3%
     if g_option$(4)="ON" then
       a$="===== Landing Computer activated ====="
       call display(23,a$)
       call display(15,"ON ")
     end if
     ! 50% chance of you having the initiative if landing in manual.
     if g_option$(4)="OFF" and rnd>.5 then gosub 3300 end if

     ! main landing_loop - iterate until ground is reached
     if debug% = 1 then print "rpos: ";pr::rpos;" on_gnd ";pr::on_ground &
        ;" jump: ";jump_flag end if
     while (pr::rpos>0 and pr::on_ground=0 and jump_flag=0)
       if g_option$(4)="OFF" then
         a$="MANUAL landing mode active."
         call display(23,a$)
         call display(15,"OFF")
         gosub 3200
         iterate
       end if
       gosub 3300		! update surrounding ships
       ! check for comlink messages
       get #2%, key #0% eq pr::username, wait 60\free #2%
       if mid$(op::message,1,1)<>" " then
         gosub 1200
       end if
       gosub 1700               ! display status
       ! switch off landing comp if near something of significance
       if near_important=1 then gosub 2450 end if
       get #3%, key #0 eq name$(pr::planet), wait 60
       pr::rpos=pr::rpos-pr::speed
       if pr::rpos<0 then pr::rpos=0 end if
       update #3%\free #3%
     next
     ! check if player aborted landing sequnce by doing a combat jump
     if jump_flag=1 then
       return
     end if
     ! make sure player is on ground
     get #3%, key #0 eq name$(pr::planet), wait 60
     t(pr::shipnum)::spos = 0
     update #3%\free #3%
     call display(4,)\call display(12,)\scanner_on=0
     a$="===== Landing completed successfully ====="
     call display(24,a$)
     if (pr::cargo(2)+pr::cargo(7))<>0 and rnd>.7 and pr::legal=1 then
         pr::legal=2
     end if
     ! update trading computer, if installed
     if pr::equip(23)=1 then
       for i=1 to ntcargo
	 tracomp%(pr::planet,i)=tracomp%(pr::planet,i)*tracomp%(pr::planet, &
	   ntcargo+3)+c(i)::pprice
	 if tracomp%(pr::planet,ntcargo+3)<>0 then
           tracomp%(pr::planet,i)=int(tracomp%(pr::planet,i)/ &
	     (tracomp%(pr::planet,ntcargo+3)+1))
	 end if
       next i
       tracomp%(pr::planet,ntcargo+3)=tracomp%(pr::planet,ntcargo+3)+1
     end if
     pr::time_owned = pr::time_owned + 1
     a=(pr::maxfuel-pr::fuel)*fuelprice+10\melt=0\ecm_status%=0
     select int((pt::tech+pt::population)/2)
        case 1,2
          a$= "You land in a blackened, muddy clearing with wooden huts "+&
            "surrounding it."
        case 3,4
         a$= "You land at a small pre-fab spaceport with minimal facilities."
        case 5,6
          a$= "You arrive at a modest, but well-maintained spaceport."
        case 7,8
          a$= "You land at an extensive, up-to-date spacecenter."
        case 9,10
          a$="You land in a gleaming modern spaceport/trading center on "+ &
            edit$(pt::pname,128%)+"."
     end select
     call display(24,a$)
     if pt::tech<3 and pr::energy<pr::maxenergy and rnd>.4 then
        a$= "The energy recharging unit is out of service - Energy not "+ &
           "recharged."
        call display(24,a$)
     else
        if pr::energy<pr::maxenergy then
          a$="You recharge your energy unit to maximum capacity."
          call display(24,a$)
          pr::energy=pr::maxenergy
        end if
     end if
     if g_option$(5)="ON" and a<=pr::credits then
       a$="Refueling performed. Cost: "
       pr::fuel=pr::maxfuel
       pr::credits=pr::credits-a
       a$= a$+str$(a)+" Credits."
       call display(24,a$)
     end if
     if g_option$(6)="ON" then
        a=(pr::maxmissile-pr::equip(13))*50+10
        if a>pr::credits or a=10 then 
	  a$="No missiles purchased."
          call display(24,a$)
        else
          pr::credits=pr::credits-a
          a$= str$((a-10)/50)+" Missiles purchased. "+&
          "Cost:"+str$(a)+" credits."
           call display(24,a$)\pr::equip(13)=pr::maxmissile
        end if
     end if
     pr::on_ground=1\condition$="GRE"\call display(16,condition$)
     gosub 1700        !display status
     return
     
2450 !  Switch off landing computer - something interesting nearby
     a$="===== Ship detected nearby - Switching to manual ====="
     call display(23,a$)
     condition$="YEL"
     call display(16,condition$)
     call display(15,"OFF")
     gosub 3200
     ecm_status%=0
     pr::direction=1
     if jump_flag=1 then return end if		! combat jump
     if pr::rpos<>0 then
       call display(15,"ON ")
       condition$="GRE"\call display(16,condition$)
       a$="===== No ships in immediate vicinity - Reactivating landing" &
         +" computer ====="
       call display(23,a$)
     else
       a$="===== Surface reached - activating landing computer ====="
       call display(23,a$)
     end if
     return
 
2500 ! ------------------------ Trade --------------------------
     if pr::on_ground<>1 then
         call display(33,"You have to be on the surface to trade.")
         return
     end if
     call display(4,)
     call display(5,)\call display(6,a$)
2510 a$="TRADE> "\call display(1,a$)
     menumode$="trade"
     select a$
	case "q",""
	  return
	case "?","help"
	  gosub help
	case "x"
	  gosub 6000
	case "f"
	  gosub 2550
	case "e"
	  gosub 2570
	case "p"
	  gosub 2600
	case "b"
	  gosub 2650
	case "s"
	  gosub 2680
	case "c"
	  gosub 2200
        case "u"
	  if pr::equip(23)<>1 then 
	    call display(33,"Trading computer not fitted.")
	  else gosub 2530 end if
	case else
          call display(33,"Invalid Command - Enter '?' for help")
	  goto 2510
      end select
      goto 2510

2530 ! ---------------------- Use Trading Computer -------------------
     call display(5,)\call display(6,a$)\menumode$="comp"
2535 a$="QUERY COMPUTER> "\call display(1,a$)
     select a$
	case "?","help"
	  gosub help
	case "pl"
	  call display(4,)
	  a$= "Trade data is available on the following planets."
          call display(24,a$)	  
	  for i=1 to 100
	    if tracomp%(i,1)<>0 then 
	      a$= name$(i)
              call display(24,a$)
	    end if
	  next i
	case "p"
	  a$="PLANET> "\call display(1,a$)
	  a$=edit$(a$,32%)
	  for i=1 to numplanets
	    if name$(i)=a$ and tracomp%(i,1)<>0 then goto 2540 end if
          next i
	  call display(33,"No data available on "+a$+".")
	  goto 2535
2540	  call display(4,)
	  a$= "Trading Data on "+edit$(name$(i),32%)+":"
          call display(24,a$)
	  a$= "Item                estimated Price     Samples"
          call display(24,a$)
	  for j=1 to ntcargo
            a1$=str$(tracomp%(i,j))
	    a2$=str$(tracomp%(i,ntcargo+3))
	    a$=c(j)::trade+ a1$+space$(20-len(a1$))+ &
		a2$
	    call display(24,a$)
	  next j
	case "i"
	  a$= "Enter Number of item on which you want trading information."
          call display(23,a$)
2542	  a$="ITEM> "\call display(1,a$)
	  a=val(a$)\if a=0 then return end if
	  if a<1 or a>ntcargo then 
	    call display(33,"Invalid item number.")
	    goto 2542
	  end if
	  call display(4,)
	  pmax=0
	  pmin=10000
	  a$= "Planet              "+edit$(c(a)::trade,128%)+" price."
	  call display(24,a$)
	  for i=1 to 100
	    if tracomp%(i,a)<>0 then 
              a$= name$(i)+space$(20-len(name$(i)))+str$(tracomp%(i,a))
	      call display(24,a$)
	      if tracomp%(i,a)>pmax then
	        pmax=tracomp%(i,a)
	        psell$=name$(i)
	      end if
	      if tracomp%(i,a)<pmin then
	        pmin=tracomp%(i,a)
	        pbuy$=name$(i)
	      end if
	    end if
	  next i

	  a$= "The best place to buy "+edit$(c(a)::trade,128%)+" is "+pbuy$+&
		" (price = "+str$(pmin)+")"
	  call display(24,a$)
	  a$="and the best place to sell is "+psell$+" (price = "+str$(pmax)+")"
	  call display(24,a$)
	case "","q"
	  return
	case else
	  call display(33,"Invalid command - Enter '?' for help.")
     end select
     goto 2535
     
2550 ! buy fuel
     call display(4,)
     a$="Fuel is selling at "+str$(fuelprice)+" credits/lightyear."
     call display(24,a$)
     a$="How much do you want to purchase (max "+str$(pr::maxfuel-pr::fuel)+")"
     call display(24,a$)
2552 a$="FUEL> "\call display(1,a$)\a=val(a$)
     if a<0 then goto 2550 end if
     if a=0 then return end if
     if a+pr::fuel>pr::maxfuel then
         call display(33,"Your tanks won't hold that much.")
         goto 2552
     end if
     if (pr::credits-fuelprice*a)<0 then
         call display(33,"You don't have enough money for that!")
         goto 2552
     end if
     pr::credits=pr::credits-fuelprice*a\gosub 1700
     pr::fuel=pr::fuel+a
     gosub 1700			! update status
     a$= "You buy "+str$(a)+" lightyears of fuel."
     call display(24,a$)
     return

2570 ! equip ship
     call display(4,)
     a$="Item                     Price     Item                     Price"
     call display(24,a$)
     col_pos=36
     row_pos=2
     for i=1 to ntequip
         if e(i)::eprice<>-1 or super_user_mode% = 1 then
	    a1$=str$(e(i)::eprice)
            a$= str$(i)+space$(3-len(str$(i)))+e(i)::ename+"  "+a1$
	    if i>12 then 
	      call display(27,a$)
	      row_pos=row_pos+1	      
            else
              call display(24,a$)
	    end if
         end if
     next i
     call display(24,"")
     col_pos=1
     row_pos=14
     a$="Note: The purchase of an escape capsule includes ship destructi" &
		+"on insurance."
     call display(27,a$)
2583 a$= "Item to purchase> "
     call display(1,a$)
     if a$="" then return end if
     a=val(a$)
     if a=0 then return end if
     if a<0 or a>ntequip or a<>int(a) then
	call display(33,"Invalid item - re-enter")
	goto 2583
     end if
     if super_user_mode%=1 then goto 2590 end if
     if (pr::credits-e(a)::eprice)<0 then 
	call display(33,"You can't afford that!")
	goto 2583
     end if
     if ((a=1 or a=3 or a=5) and ((a+1)/2>s(pr::shiptype)::mlaser)) or &
	(a=14 and s(pr::shiptype)::mlaser<4) or (a=17 and &
	s(pr::shiptype)::mlaser<5) then
       a$="You can't fit that laser on a "+edit$(s(pr::shiptype)::sname,128%)
       call display(23,a$)
       goto 2583
     end if
     if ((a=2 or a=4 or a=6) and (a/2>s(pr::shiptype)::mlaser)) then
        a$="You can't fit that laser on a "+edit$(s(pr::shiptype)::sname,128)
        call display(23,a$)     
        goto 2583
     end if
     if e(a)::eprice=-1 then
	call display(33,"That is not sold on this world.")
	goto 2583 
     end if
     if a<>13 and pr::equip(a)=1 then
         call display(33,"You already have one of those!")
    	 goto 2583
     end if
     if a=13 and pr::equip(a)=pr::maxmissile then
         call display(23,"Your missile rack is full.")
         goto 2583
     end if
2590 if a=12 then pr::maxmissile=pr::maxmissile+3 end if
     if a<>13 then
        a$="You buy a "+edit$(e(a)::ename,128%)+ &
		" and install it in your ship."
        call display(23,a$)
        pr::credits=pr::credits-e(a)::eprice
        if a=16 then pr::scanrange=4.5 end if
        gosub 1700
     end if
     if a=1 or a=3 or a=5 or a=14 or a=17 then
         b=(pr::equip(1)+4*pr::equip(3)+8*pr::equip(5)+pr::equip(14)*16 &
		+ pr::equip(17)*40)*300
         a$="You get "+str$(b)+" Credits rebate for trading in your old laser."
         call display(23,a$)
         pr::credits=pr::credits+b
         gosub 1700
         pr::equip(1)=0
         pr::equip(3)=0
         pr::equip(5)=0
         pr::equip(14)=0
         pr::equip(17)=0
     end if
     if a=2 or a=4 or a=6 or a=10 then
         b=int(pr::equip(2)+4*pr::equip(4)+8*pr::equip(6)+pr::equip(10)/2)*300
         a$="You get "+str$(b)+" credits rebate for turning in your old laser."
         call display(23,a$)
         pr::credits=pr::credits+b\gosub 1700
         pr::equip(2)=0
         pr::equip(4)=0
         pr::equip(6)=0
         pr::equip(10)=0
     end if
     if a=13 then
        gosub 2900
     else
        pr::equip(a)=pr::equip(a)+1
        if a=8 then pr::maxcargo=pr::maxcargo*2 end if
        if a=11 then pr::maxenergy=pr::maxenergy+100 end if
     end if
     goto 2583

2600 ! see rates
     call smg$begin_display_update(trade_id)
     call display(4,)
     a$="The official trade rates on "+edit$(pt::pname,128%)+ &
	" are listed above."
     call display(23,a$)
     a$="Item                Price          Quantity"
     call display(24,a$)
     when error in 
       get #3%, key #0% eq name$(pr::planet), wait 60%\free #3%
     use
     end when
     for i=1 to ntcargo
       a1$=str$(c(i)::pprice)
       if c(i)::qtrade=-1 then a2$="Not available"
       else 
         a2$=str$(c(i)::qtrade)
	 a2$=a2$+space$(5-len(a2$))+edit$(c(i)::unit,128%)+"s"
       end if
       a$=str$(i)+space$(3-len(str$(i)))+c(i)::trade+a1$+space$(15-len(a1$))+a2$
       call display(24,a$)
     next i
     call display(24,"")
     a$="Note - the items marked (*) are classified as illegal by the" &
	 +" galactic police"
     call display(24,a$)     
     call smg$end_display_update(trade_id)
     return

2650 ! buy cargo
     if revived$="OK" then 
	a$= "The trading center is closed by government order."
        call display(23,a$)
        return
     end if
2657 gosub 2600    ! view prices

2667 a$="Item to purchase> "
     call display(1,a$)
     a=val(a$)
     if a=0 then return end if
     if a<0 or a>10 or a<>int(a) then 
	call display(33,"Re-enter")
        goto 2667
     end if
     if a=2 then 
	a$="Note that the slave trade is looked down upon by the" &
		+" Galactic Police"
        call display(23,a$)
      end if
     a$="<Can afford : "+str$(int(pr::credits/c(a)::pprice))+" "+ &
	edit$(c(a)::unit,128%)+ &
     "s of "+edit$(c(a)::trade,128%)+"  Can carry : "
     a$=a$+str$( pr::maxcargo-pr::totcargo)+" "+edit$(c(a)::unit,128%)+"s.>"
     call display(23,a$)
     if a=7 then
        a$="Narcotics are a risky business. Beware..."
	call display(23,a$)
     end if
     if (c(a)::qtrade = -1) then
        call display(33,"That item isn't available.")
        goto 2657
     end if
     a$="Amount to purchase> "\call display(1,a$)\q=val(a$)
     if q=0 then return end if
     if q<0 then
	call display(33,"Invalid amount - re-enter")
	goto 2667
     end if

     ! make sure quantity available has been updated
     when error in
       get #3%, key#0% eq name$(pr::planet), wait 60%
     use
     end when

     if q>c(a)::qtrade then 
	call display(33,"There isn't that much for sale.")
        free #3%
	goto 2667
     end if
     if q*c(a)::pprice>pr::credits then 
        a$="You can only afford up to "+ &
	str$(int(pr::credits/c(a)::pprice))+" of "+edit$(c(a)::trade,128%)+"."
	call display(23,a$)
        free #3%
        goto 2667
     end if 
     if (pr::totcargo+q>pr::maxcargo) then
        a$="You only have room for "+str$(pr::maxcargo-pr::totcargo)+" "+ &
           edit$(c(a)::unit,128%)+"s in your hold."
	call display(23,a$)
        free #3%
        goto 2667
     end if 
     pr::cargo(a)=pr::cargo(a)+q
     pr::totcargo=pr::totcargo+q
     if pr::legal=1 and (pr::cargo(2)+pr::cargo(7))*rnd>50*rnd then
         pr::legal=2
     end if
     c(a)::qtrade=c(a)::qtrade-q
     when error in
       update #3%\free #3%
     use
     end when
     pr::credits=pr::credits-q*c(a)::pprice\gosub 1700
     goto 2657

2680 ! sell cargo
     if revived$="OK" then 
	a$= "The trading center is closed by government order."
	call display(23,a$)
        return
     end if
     a$="The traders offer you the above rates per unit of cargo"
     call display(23,a$)
show_goods:
     call smg$begin_display_update(trade_id)
     call display(4,)	! clear 
     a$="Item                   Price          Quantity in hold"
     call display(24,a$)
     for i=1 to ntcargo
        a1$=str$(c(i)::pprice)
	a2$=str$(pr::cargo(i))
        if pr::cargo(i)<>0 then
          a$=str$(i)+space$(3-len(str$(i)))+c(i)::trade+a1$+ &
	     space$(15-len(a1$))+&
	     a2$+space$(5-len(a2$))+edit$(c(i)::unit,128%)+"s"
	  call display(24,a$)
       end if
     next i
     call smg$end_display_update(trade_id)
2691 a$="Item to sell> "\call display(1,a$)\a=val(a$)
     if a<0 or a>10 or a<>int(a) then goto 2691 else if a=0 then return end if
     a$="Quantity to sell> "\call display(1,a$)
     q=val(a$)
     if q=0 then return end if
     if q<0 then q=0 end if
     if pr::cargo(a)<q then 
	a$="You only have "+str$(pr::cargo(a))+" "+edit$(c(a)::unit,128%)+" "+ &
		edit$(c(a)::trade,128%)+"."
        call display(23,a$)
	goto 2691
     end if
     a$="You sell "+str$(q)+" "+edit$(c(a)::unit,128%)+"s of "+ &
	edit$(c(a)::trade,128%)+" and receive "+str$(c(a)::pprice*q)+" credits."
     call display(23,a$)
     when error in
       get #3%, key#0% eq name$(pr::planet), wait 60%
       c(a)::qtrade=c(a)::qtrade+q
       update #3%\free #3%
     use
       c(a)::qtrade=c(a)::qtrade+q
     end when
     pr::cargo(a)=pr::cargo(a)-q
     pr::credits=pr::credits+c(a)::pprice*q
     gosub 1700
     pr::totcargo=pr::totcargo-q
     if pr::totcargo<>0 then goto show_goods end if
     return
 
2800 ! ---------------------- Options ------------------------
     call smg$begin_pasteboard_update(new_pid)
     if scanner_on=1 then call display(12,) end if
     call display(4,)
     a$="             Toggle Controls"
     call display(24,a$)
     call display(24,"")
     a$="1) Ignore Police on Landing          "+g_option$(2)
     call display(24,a$)
     a$="2) Ignore Asteroids on Landing       "+g_option$(3)
     call display(24,a$)
     a$="3) Landing Computer                  "+g_option$(4)
     call display(24,a$)
     a$="4) Automatic Fuel Purchase           "+g_option$(5)
     call display(24,a$)
     a$="5) Automatic Missile Purchase        "+g_option$(6)
     call display(24,a$)
     a$="6) Save Options settings	      "
     call display(24,a$)
     call display(24,"")
     call display(24,"")
     a$="Enter number of feature you want to toggle or return to cancel"
     call display(24,a$)
     call smg$end_pasteboard_update(new_pid)
toggle_option:
     call display(26,a$)
     if a$="0" or a$=CR or a$=LF then
        if scanner_on=1 then
          new_smg=1
          gosub 3000
        end if
        return
     end if
     if a$<"1" or a$>"7" then goto toggle_option end if
     a=val(a$)
     select a
       %IF (%SECURITY = 0) %THEN
       case 7
! Only allow superusers to use debug mode
         if super_user_mode%=1 then debug%=1 end if
       %ELSE
       case 7
       %END %IF 
       case 6
         gosub save_options
       case else
         if g_option$(a+1)="ON" then g_option$(a+1)="OFF" 
         else g_option$(a+1)="ON" end if
     end select
     goto 2800

help:
     ! provide a list of relevant commands along with a 1 line description
     when error in
       open "gal_disk:gal-help.dat" for input as file #4%
       input #4%, a$
       while a$<>menumode$
	 input #4%,a$
       next
       call display(7,)
       call display(19,)
       ! display 21 lines of help text
       for a=1 to 21
         input #4%,a$
         call display(8,a$)
       next a
       call display(17,)
       call display(20,)
     use
	a$="An error has occured in HELP.  Check that gal-help.dat is"
	call display(23,a$)
	a$="present and up to date."
	call display(23,a$)
     end when
     close #4%
     return

restore_options:
     ! -------------------- Restore Menu Options ------------------
     saved_options=1
     when error in
       open "sys$login:"+pr::username+".OPT" for input as file #4%
       for i=2 to 6
         input #4%, g_option$(i)
       next i
     use
       saved_options=0
     end when
     close #4%
     return

save_options:
     ! ---------------------- Save Menu Options -------------------
     when error in
       open "sys$login:"+pr::username+".OPT" for output as file #4%
       for i=2 to 6
	 print #4%, g_option$(i)
       next i
       print #4%, pr::personalname
       a$="Current options saved."
       call display(23,a$)
     use
       a$="Error occured saving options: "+ert$(err)
       call display(23,a$)
     end when
     close #4%
     return

2900 ! ------------------------ Buy Missile -----------------------
     a$="You have room for "+str$(pr::maxmissile-pr::equip(a))+" missiles and "&
	+"can afford "+str$(int(pr::credits/50))+"."
     call display(23,a$)
2912 a$="Number of missiles to purchase> "\call display(1,a$)\b=val(a$)
     if b<0 or b<>int(b) then goto 2900 end if
     if b>pr::maxmissile-pr::equip(a) then  
	call display(33,"You don't have room for that many.")
	goto 2912
     end if
     if 50*b>pr::credits then 
	call display(33,"You can't afford that many.")
	goto 2912
     end if
     a$="You buy "+str$(b)+" missiles and install them in your ship."
     call display(23,a$)
     pr::equip(a)=pr::equip(a)+b
     pr::credits=pr::credits-b*50
     gosub 1700
     if pr::equip(a)=pr::maxmissile then 
	call display(23,"Your missile rack is now full.")
     return
 
3000 ! -------------- describe ships in vicinity ----------------
     if new_smg=1 then
        gosub damage_report
	call display(15," ")
        call display(17,)
	call display(13,)
        call display(10,)
	call display(31,)
        scanner_on=1
     end if
     call smg$begin_pasteboard_update(new_pid)
     nearest=50
     gosub 1700 !display status
     a=3\a$="                                      "
     call display(13,) 
     for i=1 to noship
        if t(i)::ship=-1 or t(i)::player=2 then iterate end if
        d=abs(t(i)::spos-pr::rpos)
        e=sgn((pr::rpos-t(i)::spos)*pr::direction)
        b$=str$(i)+": "+edit$(s(t(i)::ship)::sname,128%)
        if t(i)::ship<>10 or t(i)::ship<>14 then
          b$=b$+" ("+t(i)::username+") "
        end if
        if e=-1 then c$="-"
        else if e=1 then c$="+"
          else let c$=" " end if
        end if
        if d<nearest then nearest=d end if
        if debug%=0 and t(i)::username=pr::username then iterate end if
        if d<pr::scanrange then
          b$=b$+left$(a$,40-len(b$))+c$+str$(d*2000)+" km"
          if t(i)::sintent=3 or t(i)::sintent=2 or t(i)::sintent=8 &
		or t(i)::sintent=6 then
            b$=b$+"  *"
          end if
          if (t(i)::sintent=9 or t(i)::sintent < -1) then b$=b$+"  Ab" end if
	  if t(i)::special = 1 and rnd < (1-1/(d+1)) then iterate end if
          call display(11,b$)
        end if
     next i
     if nearest>=pr::scanrange then
       b$="Ship(s) further than "+ str$((pr::scanrange-1)*2000)+" km detected."
       call display(11,b$)
     end if
     call smg$end_pasteboard_update(new_pid)
     if new_smg=1 then new_smg=0 end if
     return

3100  ! ------------- Determine Other Ships Next Move ----------------
      if (t(shipno)::sintent=9 or t(shipno)::sintent<-1) or &
	t(shipno)::player<>0 then return end if
      if t(shipno)::ship=1 or t(shipno)::ship=18 then
	if pr::lsj = 0 or rnd > .9 then  
	   gosub police_action
	end if
      end if
      if t(shipno)::ship>10 and t(shipno)::ship<14 then 
	gosub fleet_action
      end if
      if t(shipno)::ship=4 or t(shipno)::ship=7 or t(shipno)::ship=8 or &
          t(shipno)::ship=17 or t(shipno)::ship=19 or t(shipno)::ship=16 then 
        gosub pirate_action
      end if
      if t(shipno)::others(1)=0 then t(shipno)::others(1)=shipnum end if
      if t(shipno)::ship=9 or t(shipno)::ship=21 then 
	t(shipno)::sintent=2
      end if
      if t(shipno)::ship=2 or t(shipno)::ship=3 or &
             t(shipno)::ship=6 then 
	gosub trader_action
      end if
      if t(shipno)::ship=5 or t(shipno)::ship=15 then 
	gosub scout_action
      end if
      if t(shipno)::ship=10 then t(shipno)::sintent=0 end if
      if t(shipno)::sintent=3 or t(shipno)::sintent=2 then
        if t(shipno)::sintent=2 and t(shipno)::senergy<s(t(shipno)::ship):: &
	menergy/3 and rnd>.6 and t(shipno)::ship<>1 and t(ship)::ship<>9 then 
	  t(shipno)::sintent=6		! wimp out
        end if
        if pr::moves>=5 then
          ! missile actions
          if pr::legal=5 and t(shipno)::ship=1 and rnd>.8 then 
	    t(shipno)::sintent=8\return
          end if
          if (t(shipno)::ship=2 or t(shipno)::ship=8) and rnd>.8 then 
	    t(shipno)::sintent=8\return
          end if
          if t(shipno)::ship=9 and pr::moves>20 and rnd>.85 then 
	    t(shipno)::sintent=8\return
          end if
          if (t(shipno)::ship=4 or t(shipno)::ship=7) and rnd>.9 then
	   t(shipno)::sintent=8\return
          end if
          if t(shipno)::ship=3 and rnd>.5 then t(shipno)::sintent=8 end if
         end if
       end if
     return

police_action:
     if (t(shipno)::sintent=12 or t(shipno)::sintent=7) and pr::legal=2 then
	 return
     end if
     if (t(shipno)::sintent=15 or t(shipno)::sintent=7) then return end if
     if pr::legal<=2 then t(shipno)::sintent=pr::legal-1 
     else t(shipno)::sintent=2
     end if
     return

pirate_action:
     if t(shipno)::sintent=0 and rnd>.4 then t(shipno)::sintent=3
     else
	if rnd>.4 then t(shipno)::sintent=2 end if
     end if
     if t(shipno)::sintent=0 then
	if rnd>.5 then t(shipno)::sintent=6
	else t(shipno)::sintent=4
	end if
     end if
     return

trader_action:
     ! if ship is not a transport then there is chance it will sit and attack
     if t(shipno)::sintent=0 and t(shipno)::ship<>3 then
	if rnd>.3 then t(shipno)::sintent=3 end if
     end if
     if t(shipno)::sintent=0 then 
	if rnd>.5 then t(shipno)::sintent=4 end if
     end if
     if t(shipno)::sintent=0 then 
	if rnd>.5 then t(shipno)::sintent=5 end if
     end if
     return

scout_action:
     if t(shipno)::sintent=0 then
       if rnd>.4 then t(shipno)::sintent=2
       else t(shipno)::sintent=5
       end if
     end if
     return

fleet_action:
     if t(shipno)::sintent=0 then 
	if rnd>.5 then t(shipno)::sintent=4 
	else t(shipno)::sintent=5
        end if
     end if
     if pr::legal=5 then t(shipno)::sintent=2 end if
     return
 
3200 ! ----------------------- Manual Mode ----------------------------
     pr::dodge=0
     gosub 3000
     get #2%, key #0% eq pr::username, wait 60\free #2%
     if mid$(op::message,1,1)<>" " then
       gosub 1200
     end if
     if numevents>0 then gosub 5200 end if       ! process events
     call display(5,)\call display(6,a$)\menumode$="manual"
3215 a$="~"
     while a$="~" or len(a$)>20
       a$="ACTION> "\call display(1,a$)
       a$=a$+"~"
     next
     oops_flag=0
     action_move=0
     action_free=0
     action_combat=0
     num_moves=1
     a=1
     i=1
     while mid$(a$,i,1)<>"~"
        if mid$(a$,i,1)=" " then
          action_cmd$(num_moves)=mid$(a$,a,i-a)
	  a=i+1
	  num_moves=num_moves+1
        end if
	i=i+1
     next
     action_cmd$(num_moves)=mid$(a$,a,i-a)
     action_cmd$(num_moves+1)="$$$"
     for i=1 to num_moves
       for j=1 to nactions
	 if action_cmd$(i)=action_cost$(j,1) then
	    select action_cost$(j,2)
	      case "m"
		action_move=action_move+1
	      case "f"
		action_free=action_free+1
 	      case "c"
		action_combat=action_combat+1
	    end select
	  end if
	next j
     next i
     if action_move+action_free+action_combat=0 then
       call display(33,"Invalid command sequence. Enter '?' for help.")
       goto 3215
     end if
     ! check that requested moves are legal
     if pr::equip(22)=1 then
	if action_combat>2 or action_move>1 then
	  oops_flag=1
        end if
     else
        if action_combat+action_move>1 then
	  oops_flag=1
	end if
     end if
     if oops_flag=1 then
       a$= "You aren't allowed that combination of moves in a turn."
       call display(23,a$)
       goto 3215
     end if
     ! main move processing loop
     for move_count=1 to num_moves
       jump_flag=0
       select action_cmd$(move_count)
	    case "j"
		a$= "WARNING:  Re-activation of the Ionization reactor is "+&
			"unpredictable."
                call display(23,a$)
		a$="PROCEED> (Y/N)"\call display(1,a$)
		if a$="n" then
		  action_move=action_move-1
		else
		  a$= "IONIZATION CONTROL RODS REMOVED - ION GENERATION "+&
			"RESUMING."
                  call display(23,a$)
		  gosub 3300
		  if rnd>(.4+.4*s(pr::shiptype)::reliability/100) then
		    a$= "REACTOR STABILITY ALERT: CAN'T ACHIEVE ION EQUIL"+&
			"BRIUM."
                    call display(23,a$)
		    if rnd>(.3+.4*s(pr::shiptype)::reliability/100) then
		      a$= "SCRAMING! REACTOR STABILIZED - JUMP ABORTED."
	              call display(23,a$)
		    else
		      a$= "SCRAM FAILURE!  IONIZATION CHAMBER OVERLOAD!"
	              call display(23,a$)
		      a$= "BBOOOOMMMMMMM!!!!!  You've been VAPORIZED."
	              call display(23,a$)	
		      sleep(1%)
		      goto 8000
		    end if
		  else
		    a$= "RE-IONIZATION ACHEIVED"
	            call display(23,a$)
		    jump_flag=1
		  end if
		end if
	    case "?","help"
		gosub help
	    case "re"
		gosub 3000
            case "ah"
		gosub 3240
            case "ab"
                gosub 3800
                if pr::on_ground=1 then return
                end if
            case "a"
	        gosub 3231
            case "c"
                gosub 2200
            case "t"
                pr::direction=pr::direction*-1
                a$="You fire your maneouver rockets and swing through a "
                a$=a$+"tight semicircle."
                call display(23,a$)
            case "o"
                gosub 2800
            case "m"
                gosub 3600
            case "r","f"
		gosub 3500
            case "b"
                gosub 1100
            case "d"
                pr::dodge=1
            case "e"
                gosub 3700
            case "s"
                gosub 1000
            case "bo"
                gosub 3900
            case "fl"
                a$="Cargo hold flushed - All cargo except gold discarded."
                call display(23,a$)
                for k=1 to 9\pr::cargo(k)=0\next k\pr::totcargo=pr::cargo(10)
            case "sa"
                gosub sand_blaster
	    case "cl"
		if pr::equip(21)=0 then 
		  call display(33,"Your ship is not fitted with a cloak.")
		  action_combat = action_combat - 1
		else
		  if pr::cloak = 1 then 
		    pr::cloak = 0 
		  else 
		    pr::cloak = 1
		  end if
		  gosub 1700
		end if
	    case "ls"
		if pr::equip(20)=0 then 
		  call display(33,"Your ship is not fitted with a LSJ.")
		  action_combat = action_combat - 1
		else
		  if pr::lsj = 1 then 
		    pr::lsj = 0
		  else 
		    pr::lsj = 1
		  end if
		  call display(23,a$)
		  gosub 1700
		end if
	    case "ec"
		if pr::equip(19)=0 then
		  call display(33,"Your ship is not fitted with ECM.")
		  action_combat=action_combat-1		  
		else
		  if ecm_status%=1 then ecm_status%=0 else ecm_status%=1 end if
		  gosub 1700
		end if
            case else
                call display(33,"Invalid command - Enter '?' for help")
       end select
       if jump_flag=1 then return end if
     next move_count
     if action_move+action_combat=0 then goto 3200 end if
     gosub 3300
     if pr::rpos<0 then pr::rpos=0 end if
     if g_option$(4)="OFF" and pr::rpos<>0 then goto 3200 end if
     if near_important=0 or pr::rpos=0 then return end if
     goto 3200

3231 ! ahead full
     pr::rpos=pr::rpos-pr::speed*pr::direction
     select pr::speed
       case .75
         a$="C"
       case 1
         a$="B"
       case 1.25
         a$="A"
       case 1.5
         a$="A ultra"
     end select
     a$="Your Delison class "+a$+" drive puts out maximum power."
     call display(23,a$)
     return

3240 ! ahead slow
     a$="Enter distance to advance> "\call display(1,a$)\a=val(a$)
     if a=0 then return end if
     if a/2000>pr::speed then 
	call display(33,"Your drive can't go fast enough.")
        goto 3240
     end if
     if a<0 then 3240 end if
     a=int(a/500)/4\pr::rpos=pr::rpos-a*pr::direction
     a$="You advance "+str$(a*2000)+" km."
     call display(23,a$)
     if pr::rpos<0 then pr::rpos=0 end if
     return
 
 
3300 ! --------------- Update Ships and Calculate Nearest ------------
     gosub 3650         	! check for missile hit
     nearest=50
     near_important=0
     d=50
     get #3%, key #0% eq name$(pr::planet), wait 60
     pr::energy=t(pr::shipnum)::senergy
     if pr::cloak = 1 and pr::energy > CLOAK_COST then
       pr::energy = pr::energy - CLOAK_COST
     else 
       if pr::cloak = 1 then
         a$="Insufficient energy for Cloaking device - Deactivating."
         call display(23,a$)
         pr::cloak = 0
       end if
     end if
     if pr::lsj = 1 and pr::energy > LSJ_COST then
       pr::energy = pr::energy - LSJ_COST
     else 
       if pr::lsj = 1 then
	 a$="Insufficient energy for LSJ - Deactivating."
	 call display(23,a$)
	 pr::lsj = 0
       end if
     end if
     t(pr::shipnum)::special = pr::cloak
     if ecm_status%=1 and pr::energy > ECM_COST then
        pr::energy=pr::energy - ECM_COST
     else if ecm_status%=1 then
	 a$="Insufficient energy for ECM - switching to standby mode."
         call display(23,a$)
         ecm_status%=0
       end if
     end if
     for i=1 to noship
       if t(i)::ship=-1 or i=pr::shipnum then iterate end if
       if t(i)::spos>0 or t(i)::player<>0 then d=abs(t(i)::spos-pr::rpos) end if
       if d<nearest then nearest=d end if
       shipno=i
       if d<=pr::scanrange then
         if t(i)::ship=1 and (g_option$(2)="OFF" or pr::legal<>1) then
            near_important=1
         end if
         if t(i)::ship=10 and g_option$(3)="OFF" then near_important=1 end if
         if t(i)::ship<>1 and t(i)::ship<>10 and t(i)::ship<>-1 and &
		t(i)::player<>2 then
            near_important=1
         end if
       end if
       if t(i)::player=0 then
         ! don't determine action for human players
         if t(i)::others(2)=pr::shipnum and t(i)::ship<>14 then
           if rnd>.7 then
             a=t(i)::others(1)
             t(i)::others(1)=t(i)::others(2)
             t(i)::others(2)=a
           end if
         end if
         me=0
         if t(i)::others(1)=pr::shipnum or t(i)::others(1)=0 then
           ! if ship is responding to player or free - can change sintent
               gosub 3100\me=1
         end if
        ! note: me is set if ship is responding to current player
        if me=1 then
          if t(i)::sintent=6 and t(i)::spos>0 then gosub 3420 end if
          if t(i)::sintent=7 then gosub 3380 end if
          if t(i)::sintent=4 and t(i)::spos>0 then
            t(i)::spos=t(i)::spos-s(t(i)::ship)::mdrive
            if t(i)::spos<0 then t(i)::spos=0 end if
          end if
          if t(i)::sintent=5 then
            t(i)::spos=t(i)::spos+s(t(i)::ship)::mdrive
          end if
          if t(i)::sintent=15 then
            t(i)::sintent=7
          end if
          if (t(i)::sintent=1 or t(i)::sintent=12) and d<3 then
            gosub 3390
          end if
          if t(i)::sintent=3 and d<3 then gosub attack_player end if
          if t(i)::sintent=2 then gosub move_attack_player end if
          if t(i)::sintent=8 and d<3 and t(i)::smissile > 0 then 
            gosub 3440 
          end if
        end if                  ! end of me=1 cases
        if me=0 and t(i)::others(1)=-1 then
          t(i)::others(1)=t(i)::others(2)
          if t(i)::others(2)=-1 then t(i)::others(1)=0 end if
        end if
        ! responsible for moving missiles that you fired at non-players
        ! others(1) is target, others(2) is sender
        ! sintent=11 for just fired, 10 for missile tracking active
        if t(t(i)::others(1))::player=0 then
          if t(i)::sintent=10 and t(i)::others(2)=pr::shipnum then
            gosub 3480
          end if
          if t(i)::sintent=11 and t(i)::others(2)=pr::shipnum then
            t(i)::sintent=10
          end if
        end if
        ! also responsible for moving missiles targeted at oneself
        if t(i)::others(1)=pr::shipnum then
          if t(i)::sintent=10 then
            gosub 3480
          end if
          if t(i)::sintent=11 then
            t(i)::sintent=10
          end if
        end if
       end if
     next i
     t(pr::shipnum)::senergy=pr::energy\t(pr::shipnum)::spos=pr::rpos
     update #3%\free #3%
     return
 
move_attack_player:
     ! attack routine
     if t(pr::shipnum)::special = 1 then ! player has cloak up
	if rnd < (1 -  1/(1+d)) then    ! if detect fails, move randomly
	  t(i)::spos = t(i)::spos + int(3*rnd-1)*s(t(i)::ship)::mdrive
	  if t(i)::spos < 0 then t(i)::spos = 0 end if
	  return
	end if
     end if
     if d<s(t(i)::ship)::mdrive then 
       t(i)::spos=pr::rpos
     else
       if t(i)::spos>pr::rpos then
         t(i)::spos=t(i)::spos-s(t(i)::ship)::mdrive
       else
         if t(i)::spos<pr::rpos then 
	   t(i)::spos=t(i)::spos+s(t(i)::ship)::mdrive
         end if
       end if
     end if
     if t(i)::ship=14 or t(i)::ship=-1 then return end if
     if abs(t(i)::spos-pr::rpos)<3 then
       if t(i)::ship=20 then		! starbase attack - launch defenders
	 if (t(i)::smissile > 100) then
	   for a1 = 1 to 15
             a$= "Commando launched from Starbase " + &
		" ("+t(i)::username+")    Range: "+str$(d*2000)+" km"
             call display(23,a$)

	     l1 = next_ship
	     if (l1>noship) then noship = noship+1 end if
	     t(l1)::ship = 18
             t(l1)::spos=t(i)::spos
             t(l1)::senergy=s(t(l1)::ship)::menergy
	     t(l1)::smissile = s(t(l1)::ship)::mmissile
             t(l1)::sintent=2
             t(l1)::others(1)=pr::shipnum
             t(l1)::others(2)=0
             t(l1)::player=0
             t(l1)::username=left$(t(i)::username,2)+"C"+str$(a1)
	   next a1
	   t(i)::smissile = t(i)::smissile - 15
	 else 
	   if (t(i)::smissile > 0) then
	     for mi_l = 1 to 10
               gosub 3440
	     next mi_l
	   end if
	 end if
       end if
       if t(i)::ship<>17 and t(i)::ship<>16 then
	 if (t(i)::ship = 21 and rnd>.4 and t(i)::smissile> 0) then
           a$= "Thargoid launched from Mothership " + &
		" ("+t(i)::username+")    Range: "+str$(d*2000)+" km"
           call display(23,a$)
	   l1 = next_ship
	   if (l1>noship) then noship=noship+1 end if
	   t(i)::smissile = t(i)::smissile -1	! 1 less thargoid
           t(l1)::ship=9
           t(l1)::spos=t(i)::spos
           t(l1)::senergy=s(t(l1)::ship)::menergy
	   t(l1)::smissile = s(t(l1)::ship)::mmissile
           t(l1)::sintent=2
           t(l1)::others(1)=pr::shipnum
           t(l1)::others(2)=i
           t(l1)::player=0
           t(l1)::username=left$(t(i)::username,3)+"T"
	 else 
           if (t(i)::ship = 15 and t(i)::senergy< 150 and &
			rnd > .7) then
	     bomber = i
	     gosub launch_ebomb
           else
             gosub attack_player
           end if
         end if
       else     ! death star or battle platform attack
         if rnd>.6 and t(i)::smissile > 0 then
           ! launch a Krait or Adder attack
           a$= "Fighter launched from "+edit$(s(t(i)::ship)::sname,128%) + &
		 " ("+t(i)::username+")    Range: "+str$(d*2000)+" km"
           call display(23,a$)
	   l1 = next_ship
           if (l1>noship) then noship=noship+1 end if
	   t(i)::smissile = t(i)::smissile -1	! 1 less ship to launch
           t(l1)::ship=4
           if rnd>.5 then t(l1)::ship=7 end if
           t(l1)::spos=t(i)::spos
           t(l1)::senergy=s(t(l1)::ship)::menergy
           t(l1)::smissile=s(t(l1)::ship)::mmissile
           t(l1)::sintent=2
           t(l1)::others(1)=pr::shipnum
           t(l1)::others(2)=i
           t(l1)::player=0
           t(l1)::username=left$(t(i)::username,3)+"F"
         else
           if t(i)::ship=16 then
	     if rnd>.4 then
	       gosub attack_player
             else
	       if t(i)::smissile>0 then
		 for mi_l =1 to 3
	           gosub 3440
		 next mi_l
	       end if
             end if
           else
             if t(i)::smissile>0 then
	       for mi_l = 1 to 3
                 gosub 3440
	       next mi_l
             else
               if rnd>.8 then
		 bomber = i
	         gosub launch_ebomb
               end if
             end if
           end if
         end if
       end if
     end if
     return

launch_ebomb:
     for ii=1 to noship
      if t(ii)::ship=-1 or t(ii)::ship=20 or t(ii)::ship=17 then iterate end if
      if ii=bomber then iterate end if
      if abs(t(ii)::spos-t(bomber)::spos)<4 then
	if (t(ii)::player=0) then
          a$ = edit$(s(t(ii)::ship)::sname,128%)+" VAPORIZED."
	  call display(23,a$)
          t(ii)::ship=-1
          t(ii)::senergy=-1
          t(ii)::sintent=-1
        else
	  if (t(ii)::player=1) then
            m$="%%eb"
            sender$=t(bomber)::username
            u$=t(ii)::username
            isave=i
            gosub send_message
            i=isave
	  end if
        end if
      end if
     next ii
     return
 
attack_player:
     ! ---------------------- attack ----------------------------
     condition$="RED"\call display(16,condition$)
     a$="LASER ATTACK!  Ship: "+edit$(s(t(i)::ship)::sname,128%)+" ("+ &
	t(i)::username+")    Range: "+str$(d*2000)+" Km"
     call display(23,a$)
     hit=((3-d)+s(t(i)::ship)::slaser)/2+((3-d)+s(t(i)::ship)::slaser)*rnd/2
     damage=0\hit=hit-pr::dodge
     if hit>2.4 then
        damage=int(10*s(t(i)::ship)::slaser*rnd+s(t(i)::ship)::slaser*3)
     end if
3369 for ii=1 to noship
       if t(ii)::spos=pr::rpos and t(ii)::ship=22 then
          damage=damage*(.66)
       end if
     next ii
     if damage=0 then
        a$="The laser beam skims past your ship, missing by a narrow margin"
      else
        if damage<10 then
          a$="You feel your ship shudder as it takes relatively minor damage."
        end if
      end if
     if damage<20 and damage>9 then
        a$="MAJOR LASER BURN! Your ship shakes wildly prior to stabilizing."
     end if
     if damage>19 then
        a$="DIRECT HIT! You black out momentarily as your ship spins madly."
     end if
     call display(23,a$)
     if damage>25 and rnd>.9 then
       gosub 4400 
       pr::energy = pr::energy - int(0.7 * damange)
     else
       pr::energy=pr::energy - damage
     end if
     gosub 1700 ! display status
     gosub damage_report ! damage report
     if pr::energy<0 then goto 8000 end if
     return
 
3380 ! -------------------- Police Boarding --------------------
     t(i)::sintent=0\t(i)::spos=pr::rpos
     a$="The Viper docks and two galpol toughs board your ship."
     call display(23,a$)
     if pr::cargo(2)<>0 then 
       a$="They confiscate all your slaves and lecture you on the evils of "
       call display(23,a$)
       a$="selling sentient beings."
       call display(23,a$)
     end if
     if pr::cargo(7)<>0 then
	 a$="An electronic 'sniffer' tracks down your cargo of narcotics " &
		+"which the two"
         call display(23,a$)
	 a$= "galpol agents proceed to destroy."
         call display(23,a$)
     end if
     if pr::cargo(2)=0 and pr::cargo(7)=0 then
	a$="Well, we haven't caught you red handed but we know of your " &
		+"illicit dealing."
        call display(23,a$)
	a$="You'll be fined accordingly."
        call display(23,a$)
     end if
     a=0
     if pr::debt>0 and pr::due<pr::moves then
	a$= "You are fined "+str$(pr::debt*2)+" for an overdue loan."
        call display(23,a$)
	a=pr::debt*2
	pr::debt=0
     end if
     a=a+int(pr::cargo(2)*80+pr::cargo(7)*190*(rnd+0.5))
     if (a<>0) then
       a$="You are fined - "+str$(a)+" credits."
     else
       a$="No fine this time.  Next time we won't be so nice to you, SCUM."
     end if
     call display(23,a$)
     pr::totcargo=pr::totcargo-pr::cargo(2)-pr::cargo(7)
     pr::cargo(2)=0\pr::cargo(7)=0
     pr::credits=pr::credits-a
     if pr::legal=2 then pr::legal=1 end if
     gosub 1700
     return
 
3390 ! --------------------- police warning -----------------------
     m$="Surrender your cargo immediately and consider yourself under arrest."
     m$=m$+"@Please accept or refuse boarding.  Reply IMMEDIATELY or risk " &
	+"attack"
     sender$=t(i)::username\u$=pr::username\save=i\gosub send_message\i=save
     if t(i)::sintent=12 then
        if rnd>.5 then 
           t(i)::sintent=2
	   if rnd>.8 then
             pr::legal=3 
	   end if
        end if
     end if
     if t(i)::sintent=1 then t(i)::sintent=12 end if
     return
 
3420 ! ------------------------- run away ---------------------------
     if t(i)::spos>pr::rpos then 
	t(i)::spos=t(i)::spos+1 
     else 
	t(i)::spos=t(i)::spos-1
     end if
     if abs(t(i)::spos-pr::rpos)<3 then gosub attack_player end if
     return

3440 ! ---------------------- enemy missile fire ---------------------
     if t(i)::smissile > 0 then t(i)::smissile = t(i)::smissile -1 end if 
     a$="INCOMING MISSILE detected from "+edit$(s(t(i)::ship)::sname,128%)+ &
        " ("+t(i)::username+")  Range: "+str$(d*2000)+"km"
     call display(23,a$)
     condition$="RED"\call display(16,condition$)
     !   firer of missile now goes back to regular attack
     if t(i)::player=0 then t(i)::sintent=2 end if
     l1 = next_ship
     if (l1 > noship) then noship=noship+1 end if
     t(l1)::ship=14
     t(l1)::spos=t(i)::spos
     t(l1)::senergy=s(t(l1)::ship)::menergy
     t(l1)::sintent=11
     t(l1)::others(1)=pr::shipnum
     t(l1)::others(2)=i
     t(l1)::player=0
     t(l1)::username=left$(t(i)::username,3)+"M"
     t(l1)::special=0
     return
 
3480 ! ------------------- Update Missiles --------------------------
     if ecm_status%=1 and rnd>.4 then
       a$= "ECM frequency lock on achieved - Missile DESTROYED."
       call display(23,a$)
       t(i)::ship=-1
       t(i)::sintent=-1
     end if
     if abs(t(i)::spos-t(t(i)::others(1))::spos)<1 then
        t(i)::spos=t(t(i)::others(1))::spos
     end if
     if t(i)::spos>t(t(i)::others(1))::spos then
        t(i)::spos=t(i)::spos-1
     else
        if t(i)::spos<t(t(i)::others(1))::spos then
          t(i)::spos=t(i)::spos+1
	end if
     end if
     if t(i)::spos=0 then
        t(i)::ship=-1
        t(i)::sintent=-1
        if abs(t(i)::spos-pr::rpos)<pr::scanrange then
           a$="The missile burns up in the atmosphere."
           call display(23,a$)
        end if
     end if
     update #3%
     gosub 3650                 ! check for missile hit
     ! need to have a current record
     get #3%, key #0 eq name$(pr::planet), wait 60
     return

3500 ! ------------------------- Laser Fire -----------------------------
     if action_cmd$(move_count)="r" then 
	a=pr::equip(2)+pr::equip(10)+2*pr::equip(4)+3*pr::equip(6)\d$="rear"
     end if
     if action_cmd$(move_count)="f" then 
	a=pr::equip(1)+2*pr::equip(3)+3*pr::equip(5)+4*pr::equip(14) + &
	+5*pr::equip(17)\d$="front"
     end if
     if a=0 then
	a$="You don't have a "+d$+" laser."
        call display(23,a$)
	action_combat=action_combat-1
	return 
     end if
     for i=1 to maxships\exist(i)=0\next i
     for i=1 to noship
       if t(i)::ship=-1 or t(i)::username=pr::username then
         iterate
       end if
       d=abs(t(i)::spos-pr::rpos)
       e=sgn((pr::rpos-t(i)::spos)*pr::direction)
       b$=edit$(s(t(i)::ship)::sname,128%)
       exist(i)=0
       if d<pr::scanrange and action_cmd$(move_count)="f" and (e=0 or e=1) then
	  exist(i)=1 
       end if
       if d<pr::scanrange and action_cmd$(move_count)="r" and (e=0 or e=-1) &
	  then exist(i)=1
       end if
     next i

3540 d$="Number of target ship> "\call display(1,d$)\b=val(d$)
     if b=0 then 
	a$="Laser firing aborted."
        call display(23,a$)
	action_combat=action_combat-1
	return 
     end if
     if b<0 or b>noship or b<>int(b) then goto 3540 end if
     if (exist(b)=0 and b<>0) or (t(b)::player=2) then 
	call display(33,"That object is not in laser range.")
	goto 3540 
     end if
     if t(b)::ship=22 then
       call display(33,"Can't target a sand cloud.")
       goto 3540
     end if
     if t(b)::ship>10 and t(b)::ship<14 and t(b)::player=0 then 
	pr::legal=5
     end if
     if (t(b)::ship=2 or t(b)::ship=3) and rnd>.7 and t(b)::player=0 then
       get #3%, key #0 eq name$(pr::planet), wait 60
       t(b)::sintent=6
       t(b)::others(2)=t(b)::others(1)
       t(b)::others(1)=pr::shipnum
       update #3%\free #3%
     end if
3545 b$=edit$(s(t(b)::ship)::sname,128%)
     if pr::legal=5 then goto 3547 end if
     if t(b)::ship=1 then
       pr::legal = 4
       t(pr::shipnum)::others(2)=t(pr::shipnum)::others(1)
       t(pr::shipnum)::others(1)=b
       t(pr::shipnum)::sintent=2
     end if
 3546 if (t(b)::ship<>10 and t(b)::ship<>14 and (t(b)::sintent<>2 and &
       	  t(b)::sintent<>3 and t(b)::sintent<>18 and &
          t(b)::sintent<>6 and t(b)::sintent<>9 and t(b)::sintent<-1))&
		 and t(b)::player=0 then
       pr::legal=4-(t(b)::ship>10)
       t(pr::shipnum)::others(2)=t(pr::shipnum)::others(1)
       t(pr::shipnum)::others(1)=b
       t(pr::shipnum)::sintent=2
     end if
3547 d=abs(t(b)::spos-pr::rpos)
     pr::energy=pr::energy-a
     get #3%, key #0% eq name$(pr::planet), wait 60
     t(pr::shipnum)::senergy=t(pr::shipnum)::senergy-a
     update #3%\free #3%
     if pr::energy<0 then
       a$= "Your laser drained your last energy units, shutting off LIFE " &
	+"SUPPORT..."
       call display(23,a$)
       goto 8000
     end if
3548 if t(b)::ship<>10 and t(b)::sintent<>9 and t(b)::sintent<>6 and &
	t(b)::player=0 then
       get #3%, key #0% eq name$(pr::planet), wait 60
       t(b)::others(2)=t(b)::others(1)
       t(b)::others(1)=pr::shipnum\t(b)::sintent=2\update #3%\free #3%
     end if
3549 if (a=1 and pr::equip(10)=1 and t(b)::ship=10 and action_cmd$(move_count) &
		="r") then
        a$="You fire the mining laser at the asteroid."
        call display(23,a$)
	mine=1
	goto 3554
     end if
     select a
	case 1
          a$="You send a stream of energy pulses at the "+b$+"."
  	case 2
          a$="You fire a continuous high energy beam at the "+b$+"."
  	case 3
          a$="You blast the "+b$+" with a precision focused energy beam."
	case 4
          a$="You loose an ultra-coherent beam of UV radiation at the "+b$+"."
        case 5
          a$="Stimulated emission ultra high Q X-rays blast the "+b$+"."
     end select
     call display(23,a$)
     if t(b)::spos <=0 and pt::trade<>9 and pt::trade<>10 then
        a$= "Your laser beam disperses harmlessly in the atmosphere."
        call display(23,a$)
        mine=0
        return
     end if
3554 hit=((3.3-d)+a)/2+((3.3-d)*rnd/2)
     if hit>2.2 then
	if a>3 then a=a+1 end if
        damage=int((15*a)*rnd+a*6-(a>3)*15) else damage=0
     end if
     for ii=1 to noship
        if t(ii)::spos=pr::rpos and t(ii)::ship=22 then
          damage = int(damage*.66)
        end if
     next ii
     if t(b)::player=1 then
        m$="%%la"+t(b)::username+str$(damage)+"."
        u$=t(b)::username
        gosub 5000
     end if
3555 if damage=0 then
        a$="Your laser narrowly misses the "+b$+"."
        call display(23,a$)
	mine=0
	return
     end if
3556 tar=b              ! use missile hit routine
3558 if mine=1 then
        get #3%, key #0% eq name$(pr::planet), wait 60
        t(b)::ship=-1
        t(b)::senergy=-1
        update #3%\free #3%
        b=int(15*rnd+5)\c=4
        if rnd>.98 then c=10 end if
        if c=4 then 
	  a$="The asteroid is reduced to "+str$(b)+" tons of minerals."
          call display(23,a$)
        else 
	  a$= "You find "+str$(b)+" kilos of GOLD!" 
          call display(23,a$)
	end if
        gosub 3935
        return
     end if
3559 if t(b)::ship=10 then
        a$="Your laser hits the asteroid and destroys it totally."
        call display(23,a$)
        get #3%, key #0% eq name$(pr::planet), wait 60
        t(b)::ship=-1
        t(b)::senergy=-1
        update #3%\free #3%
        return
     end if
3560 a$="You see a red flash on "+b$+"'s hull indicating you hit."
     call display(23,a$)
3562 gosub 3690
3594 return
 
3600 ! -------------------- Fire Missiles ------------------------
3601 if pr::equip(13)=0 then 
	call display(33,"You're out of missiles!")
	action_combat=action_combat-1
	return
     end if
3602 a$="Targeting computer engaged - Please select missile target"
     call display(23,a$)
3603 for i=1 to maxships\exist=0\next i
3604 for i=1 to noship
       if t(i)::ship=-1 or t(i)::username=pr::username then
         iterate
       end if
       if abs(t(i)::spos-pr::rpos)<pr::scanrange then exist(i)=1 end if
     next i
3613 if pr::equip(15)=1 then gosub 4300\return

3614 a$="Target ship> "\call display(1,a$)\a=val(a$)
     if a=0 then 
	a$="Firing aborted."
        call display(23,a$)
        action_combat=action_combat-1
	return
     end if
3615 if a<1 or a>noship or a<>int(a) then 
        call display(33,"Invalid target - re-enter")
        goto 3614 
     end if
     if exist(a)=0 or t(a)::player=2 then
        call display(33,"Out of Range")
	goto 3614
     end if
     if t(a)::ship=22 then
        a$= "Target Lock in Failure - Can't enable tracking system."
         call display(23,a$)
       goto 3614
     end if
3616 if (t(a)::ship=2 or t(a)::ship=3) and rnd>.7 and t(a)::player=0 then
	! change response to new attacking player
        get #3%, key #0% eq name$(pr::planet), wait 60
        t(a)::sintent=6\t(a)::others(2)=t(a)::others(1)
        t(a)::others(1)=pr::shipnum\update #3%\free #3%
     end if
3617 if pr::legal<4 then
       if (t(a)::ship<>10 and t(a)::ship<>14 and (t(a)::sintent=0 or &
          t(a)::sintent=1 or t(a)::sintent=15 or t(a)::sintent=7 or &
	  t(a)::sintent=12 or t(a)::sintent=18 or &
          t(a)::sintent=5 or t(a)::sintent=4)) and t(a)::player=0 then
             pr::legal=4-(t(a)::ship>10)
       end if
     end if
     pr::equip(13)=pr::equip(13)-1\if t(a)::ship>10 and t(a)::ship<14 &
          and t(a)::player=0 then pr::legal=5 end if
     if t(a)::sintent<>9 and t(a)::ship<>10 and t(a)::sintent<>6 and &
	  t(a)::player=0 then
        get #3%, key #0% eq name$(pr::planet), wait 60
        t(a)::sintent=2\t(a)::others(2)=t(a)::others(1)
        t(a)::others(1)=pr::shipnum\update #3%\free #3%
     end if
     a$="Targetcom programmed - Xionite warhead armed   5 4 3 2 1 Ignition!"
      call display(23,a$)
     a$="The sleek Demon Mark II missile begins tracking the "+ &
	  edit$(s(t(a)::ship)::sname,128%)
     call display(23,a$)
     if t(a)::player=1 then
        m$="%%mi"+t(a)::username+str$(noship)+"."
        asave=a
        gosub 5000
        a=asave
     end if
3630 get #3%, key #0% eq name$(pr::planet), wait 60
     l1 = next_ship
     if (l1 > noship) then noship=noship+1 end if
     t(l1)::ship=14\t(l1)::spos=pr::rpos\t(l1)::senergy=5
     t(l1)::sintent=11\t(l1)::others(1)=a
     t(l1)::others(2)=pr::shipnum\t(l1)::player=0
     t(l1)::username=left$(pr::username,3)+"M"
     update #3%\free #3%
 
3650 ! --------------- check for missile hit -------------
     i1=i
     for i=1 to noship
       if t(i)::ship=14 and t(i)::spos=t(t(i)::others(1))::spos  &
        and (t(t(i)::others(1))::player=0 or (t(t(i)::others(1))::player=1 &
        and t(i)::others(1)=pr::shipnum)) then gosub 3680
       end if
     next i
     i=i1
     return
 
3680 ! ----------------- missile hit -------------------
     get #3%, key #0% eq name$(pr::planet), wait 60
     t(i)::ship=-1\t(i)::sintent=-1
     update #3%\free #3%
     if t(t(i)::others(1))::ship=-1 then
       a$= "Target lost - missile self-destructing."
       call display(23,a$)
       return
     end if
     if t(i)::others(1)=pr::shipnum then
       ! you have taken a missile hit
       a$= "MISSILE HIT!  The Xionite explosion sends your ship into a spin!"
       call display(23,a$)
     else
       a$="You see a blinding flash, as a missile strikes the "+ &
       edit$(s(t(t(i)::others(1))::ship)::sname,128%)+"."
       call display(23,a$)
     end if
     damage=int(50*rnd)+50
     tar=t(i)::others(1)
     if tar=pr::shipnum then
       pr::energy=pr::energy-damage
       gosub 1700\gosub damage_report
       m$="%%mh"
       gosub 5000
       if pr::energy<0 then goto 8000 end if
     end if
     ! laser hit routine jumps to here
3690 get #3%, key #0% eq name$(pr::planet), wait 60
     t(tar)::senergy=t(tar)::senergy-damage
     if t(tar)::ship=10 then
       t(tar)::ship=-1
       update #3%\free #3%
       return
     end if
     if t(tar)::senergy=<0 and t(tar)::player=0 and t(tar)::ship<>-1 then
         a$="The "+edit$(s(t(tar)::ship)::sname,128%)+&
         " becomes a huge fireball, instantly vaporizing."
         call display(23,a$)
         pr::score=pr::score+s(t(tar)::ship)::menergy
         if t(tar)::ship<>14 then pr::kills=pr::kills+1 end if
         t(tar)::ship=-1\t(tar)::sintent=-1\update #3%\free #3%
         return
      end if
      if t(tar)::player=0 and s(t(tar)::ship)::menergy<>0 then 
        if t(tar)::senergy/s(t(tar)::ship)::menergy<.27 and rnd>.2 and &
	     t(tar)::sintent<>9 and t(tar)::ship<>14 then
          a$="Escape capsule launch detected from "+ &
          edit$(s(t(tar)::ship)::sname,128%)+"."
          call display(23,a$)
          t(tar)::sintent=9
        end if
      end if
     update #3%\free #3%
     return
 
3700 ! ------------------- energy bomb ---------------------
     if pr::equip(9)=0 then 
	call display(33,"Wishful thinking! You don't have one.")
	action_combat=action_combat-1
	return
     end if
     a$="The consequences of this action could be unimmaginable:"
     call display(23,a$)
     a$="PROCEED? (Y/N) "\call display(1,a$)
     if a$<>"y" and a$<>"Y" then 
	a$="Abort sequence initiated - disarm countdown in process."
        call display(23,a$)
	return
     end if
     a$="Energy shield created - Antimatter expansion initiated"
     call display(23,a$)
     pr::equip(9)=0
     get #3%, key #0% eq name$(pr::planet), wait 60
     for i=1 to noship
      if t(i)::ship=-1 then iterate end if
      if i=pr::shipnum then iterate end if
      if t(i)::ship=20 then
         t(i)::sintent=20
         if abs(t(i)::spos-pr::rpos)<pr::scanrange then
           a$= "Energy bomb shield activation detected from Star Base."
           call display(23,a$)
         end if
         iterate
      end if
      if abs(t(i)::spos-pr::rpos)<4 then
        a$= edit$(s(t(i)::ship)::sname,128%)+" VAPORIZED."
        call display(23,a$)
        pr::kills=pr::kills+1
        pr::score=pr::score+int(s(t(i)::ship)::menergy/10)
        if t(i)::player=0 then
          t(i)::ship=-1
          t(i)::senergy=-1
          t(i)::sintent=-1
        else 
          if (t(i)::player = 1) then
            m$="%%eb"
            sender$=pr::username
            u$=t(i)::username
            isave=i
            gosub send_message
            i=isave
          end if
        end if
      end if
     next i
     update #3%\free #3%
     if pt::zone<>4 and pt::zone<>3 then pr::legal=5 end if
     if rnd<.12 then
       a$="You sense something is wrong - the matter/anti-matter chain" &
	  +" reaction is running wild!! - It's totally out of control!"
       call display(23,a$)
       a$= edit$(pt::pname,128%)+" Vaporized!!!! You just wiped a "&
	  +"world off the map."
       call display(23,a$)
       a$="Energy expansion stabilizing - Oh no!  Energy recession is"&
	  +" out of control!!!"
       call display(23,a$)
       call display(23,"")
       a$="BBBBBBBBOOOOOOOOOMMMMMMMMMMMMMMMM!!!!!!!"
       call display(23,a$)
       goto 8000
     else
       call display(23,"")
       a$="Antimatter field receeding - It worked!!!!"
       call display(23,a$)
     end if
     return
 

3800 ! ***** escape capsule *****
     if pr::equip(7)<>1 then 
	a$="You'll have to go down with your ship! - "&
	+"You don't have an escape capsule!!!"
        call display(23,a$)
        action_move=action_move-1
	return
     end if
     a$= "Are you sure you want to abandon ship (You'll lose all except" &
         +" your gold and"
     call display(23,a$)
     a$="money, and your replacement ship will have no optional equipment):"
     call display(23,a$)
     a$="ABANDON? (Y/N)"\call display(1,a$)
     if a$="n" or a$="N" then
	action_move=action_move-1
	return
     end if
     get #3%, key #0% eq name$(pr::planet), wait 60
     t(pr::shipnum)::sintent=9\t(pr::shipnum)::player=0\update #3%\free #3%
     call display(23,"")
     a$="Escape sequence initiated."
     call display(23,"")
     a$="You are thrown clear of your ship and hurtle towards the planet"
     call display(23,a$)
     m$="%%ab"
     gosub 5000                         ! check if any players in range
     pr::escapes=pr::escapes+int(pr::time_owned/10)
     call display(4,)			! erase trading window
     call display(12,)\scanner_on=0
     a$="Soon you enter the atmosphere, your recovery shutes open,"&
	+" and you float down"
     call display(24,a$)
     a$= "and land near the spaceport"
     call display(24,a$)
     if pt::zone=4 then 
	a$="You are captured by Thargoids and literally " &
	+"ripped apart on the spot."
        call display(24,a$)
        quit=2\goto 8000
     end if
     if pt::zone<>1 then 
	a$="You spend a month on "+edit$(pt::pname,128%)+ &
	" while you claim insurance on your ship."
        call display(24,a$)
	goto 3830
     end if
     a$="When you try to claim insurance on your ship, the friendly local"&
	+" representative"
     call display(24,a$)
     a$="of the Galactic Insurance Co. smiles and points to clause C.4 of"&
	+" your policy"
     call display(24,a$)
     a$="which reads 'Coverage Limitations and Exclusions. We will not pay"&
	+" for direct or"
     call display(24,a$)
     a$="indirect loss in these cases A) War  B) Nuclear Hazard  C) Sabotage"
     call display(24,a$)
     if pr::credits>200000 then 
	a$="You'll have to pay for a new ship yourself." 
        call display(24,a$)
	goto get_new
     else 
	a$= "You retire."
        call display(24,a$)
	quit=1
	goto 8000
     end if
3830 a$="The insurance policy will cover replacement cost of your ship.  Note"
     call display(24,a$)
     a$="that equipment is NOT covered."
     call display(24,a$)
     pr::credits=pr::credits+s(pr::shiptype)::cost
     gosub 1700		! update status
get_new:
     a$="You can now choose your next ship."
     call display(24,a$)
     call display(17,)
     for i=1 to 9\pr::cargo(i)=0\next i		!clear all cargo except gold
     pr::totcargo=pr::cargo(10)
     pr::energy=0
     pr::rpos=0
     pr::on_ground = 1
     pr::lsj = 0\pr::cloak = 0
     pr::legal=1
     pr::shiptype = 0
     gosub 6000
     find #2%, key #0% eq pr::username, wait 60\update #2%\free #2%
     mine=0
     return

3900 ! -------------------- board abandoned ship --------------------
     mine=0
     ! check if you are right above a ship, if yes ==> board
     get #3%, key #0% eq name$(pr::planet), wait 60

     for i=1 to noship
       if t(i)::ship<>-1 and abs(t(i)::spos-pr::rpos)=0 and (t(i)::sintent=9 &
	 	or t(i)::sintent < -1) then
	   ! big ships allow more than 1 person to board
           a$="You board the badly damaged "+edit$(s(t(i)::ship)::sname,128%)+ &
	      " and check out the cargo hold."
           call display(23,a$)

	   if t(i)::sintent > 0 then
	     select t(i)::ship
	       case 20
		 t(i)::sintent = -10
	       case 17
	         t(i)::sintent = -5
	       case 21
		 t(i)::sintent = -3
	       case 13,15,16
		 t(i)::sintent = -2
	       case else
		 t(i)::sintent = -1
                 pr::score=pr::score+s(t(i)::ship)::menergy
                 pr::kills=pr::kills+1
		 t(i)::ship = -1
		 t(i)::senergy=-1
	     end select
           else
	     ! if more than one person on board, up count by one
	     if t(i)::sintent < -1 then
		t(i)::sintent = t(i)::sintent + 1
                pr::score=pr::score+s(t(i)::ship)::menergy
                pr::kills=pr::kills+1
                if t(i)::sintent = -1 then
		  t(i)::ship = -1
		  t(i)::senergy=-1
		end if
	     end if
         end if
         goto 3910
       end if
     next i
     free #3%
     ! check if a starbase in docking range
     for i=1 to noship
       if t(i)::ship=20 and abs(t(i)::spos-pr::rpos)<2 then goto 3970 end if
     next i
     call display(33,"There is no abandoned ship right above you.")
     action_move=action_move-1
     return

3910 update #3%\free #3%
     if rnd>.8 then 
        a$="You find that the cargo hold has been totally"&
	+" consumed by intense fire."
        call display(23,a$)
        goto 3940
     end if
      if t(i)::player=1 then
	c=t(i)::cargo(1)	! cargo item
        b=t(i)::cargo(2)	! amount carried
	goto 3930
      else
        a=t(i)::ship
	select a
	  case 1
	    b=int(10*rnd+10)
	    if rnd>.5 then c=10 else c=5 end if
	  case 2,8,6
	    b=int(50*rnd+50)
	    c=int(9*rnd+1)
	  case 4,5,7
	    b=int(20*rnd+1)
	    c=int(9*rnd+1)
	  case 3
	    b=int(200*rnd+100)
	    c=int(9*rnd+1)
	  case 9
	    b=int(50*rnd+5)
	    if rnd>.5 then 
	      c=8
	    else
              if rnd>.5 then c=2
              else c=9
	      end if
	    end if
	  case 11,15
	    b=16
	    c=-1
	  case 12
	    b=14
	    c=-1	    
	  case 13
	    b=15
	    c=-1
	  case 16
	    b=19
	    c=-1
	  case 17
	    if rnd>.96 then
	      b=17	
	      c=-1
	    else 
	      if rnd<.70 then
	        b=int(450*rnd+320)
	        c=10
	      else
	        b=20
	        c=-1
	      end if
	    end if
	  case 18
	    b=int(50*rnd+1)
	    c=10
	  case 19	! boa 
	    if rnd>.95 then
	      b=21
	      c=-1
            else
	      b=int(400*rnd+5)
	      c=int(4*rnd+1)
	    end if
	  case 20	! starbase
	    if rnd> .5 then
	      b=int(100*rnd+300)
	      c=10
	    else
	      b=21
	      c=-1
	    end if
	  case 21
	    if rnd>.50 then
	      b=22
	      c=-1
	    else
	      b=int(400*rnd+100)
	      c=int(3*rnd+4)
	    end if
          case else
 	    b=int(100*rnd+1)
	    c=int(10*rnd+1)
        end select
     end if
3930 if c=-1 then goto found_equipment end if
       a$="You find "+str$(b)+" "+edit$(c(c)::unit,128%)+"s of "+ &
  	 edit$(c(c)::trade,128%)+"."
       call display(23,a$)
       a$="n"
       if (pr::totcargo+b)>pr::maxcargo then
         a$="You won't be able to take it all."
         call display(23,a$)
         a$= "FLUSH CARGO HOLD? (Y/N)"
         call display(1,a$)
       end if
       if a$<>"y" and a$<>"Y" then goto 3935 end if
       a$="Cargo hold flushed.  All cargo except your gold has been discarded."
       call display(23,a$)
       for k=1 to 9\pr::cargo(k)=0\next k
       pr::totcargo=pr::cargo(10)
3935   a$="How much do you want to take?"
       call display(23,a$)
       a$="QUANTITY> "\call display(1,a$) 
       a=abs(val(a$))
       if (pr::totcargo+a)>pr::maxcargo then 
	 a$="You only have room for "+str$(pr::maxcargo-pr::totcargo)+" tonnes."
         call display(23,a$)
	 goto 3935
       end if
3938   if a>b then 
 	 call display(33,"There isn't that much here!")
         goto 3935 
       end if
       pr::cargo(c)=pr::cargo(c)+a\pr::totcargo=pr::totcargo+a
       a$="You load "+str$(a)+" "+edit$(c(c)::unit,128%)+"s of "+ &
	 edit$(c(c)::trade,128%)+" into your hold."
       call display(23,a$)
3940   if mine=0 then
	 if t(i)::ship = -1 then
           a$="You return to your ship.  As you uncouple with the wrecked"+ &
              " ship, the strain"
           call display(23,a$)
           a$="causes the wreck to break up and disintegrate."
           call display(23,a$)
	 else
	   a$="While uncoupling, you note that the damaged ship has " + &
	      "another docking port."
	   call display(23,a$)
       else
         ! operation was mining
         mine=0
       end if
       return

3970 ! board starbase
     if t(i)::sintent<>0 then
       a$= "STARBASE DOCKING REQUEST DENIED."
       call display(23,a$)
       return
     end if
     a$="STARBASE DOCKING PROGRAM ACTIVATED - Docking maneouver completed."
     call display(23,a$)
     clean=(pr::legal-1)^4*1000
     clean=clean+int(clean*rnd)
     if clean<>0 and pr::credits>clean then
       a$= "For "+str$(clean)+" credits, you can be clean again..."
       call display(23,a$)
       a$="PAY IT? (Y/N)"\call display (1,a$)
       if a$="n" then goto 3975 end if
       pr::credits=pr::credits-clean\pr::legal=1\clean=0
     end if
     if clean<>0 then
       a$= "A junior official throws you off the base, mumbling about how"
       call display(23,a$)
       a$= "he would have you arrested if it wasn't for all the paperwork."
       call display(23,a$)
       goto 3975
     end if
     if pr::credits<1000 then
       a$= "Your credit rating isn't good - thrown out."
       call display(23,a$)
       goto 3975
     end if
     a$="Energy recharged and Missiles replenished.  Service Fee: CR 1000"
     call display(23,a$)
     pr::energy=pr::maxenergy
     get #3%, key #0% eq name$(pr::planet), wait 60
     t(pr::shipnum)::senergy=pr::maxenergy
     update #3%\free #3%
     pr::equip(13)=pr::maxmissile
     pr::credits=pr::credits-1000
3975 a$="DEPARTURE SEQUENCE INITIATED - Successful release from starbase."
     call display(23,a$)
     return
    
found_equipment:
     ! ----------------- Found a piece of equipment -----------------
     a$= "You find a working "+edit$(e(b)::ename,128%)+"."
     call display(23,a$)
     a$="Do you want to install it? (Y/N)"\call display(1,a$)
     if a$="n" then goto 3940 end if
     if b=14 then      ! excimer=14 / x-ray=17
       if s(pr::shiptype)::mlaser<4 then a$="Sorry, your "+ &
	  edit$(s(pr::shiptype)::sname,128%)+ &
	  " just doesn't have a strong enough mount."
          call display(23,a$)
          return
       else
         pr::equip(1)=0\pr::equip(3)=0\pr::equip(5)=0\pr::equip(17)=0
       end if
     end if
     if b=17 then
       if s(pr::shiptype)::mlaser<5 then a$="Sorry, your "+ &
	  edit$(s(pr::shiptype)::sname,128%)+ &
	  " just doesn't have a strong enough mount."
          call display(23,a$)
          return
       else
         pr::equip(1)=0\pr::equip(3)=0\pr::equip(5)=0\pr::equip(14)=0
       end if
     end if
     if b=13 then pr::scanrange=5 end if
     pr::equip(b)=1
     a$= "You install the "+edit$(e(b)::ename,128%)+" in your ship."
     call display(23,a$)
     goto 3940

4000 ! -------------------- Police Trap -----------------------------
     if pt::law>6 and rnd>.8 and pr::moves>10 then gosub 4030 end if
     if pr::legal=4 and rnd<.95 then return end if
     if pr::legal=5 and rnd<.85 then return end if
     a=int(10*rnd+8)
     for i=noship+1 to noship+a
        t(i)::ship=1
        t(i)::senergy=s(1)::menergy
	t(i)::smissile=s(1)::mmissile
        t(i)::spos=int(rnd*5+2)
        t(i)::sintent=0
        t(i)::username="GP"+str$(i)
     next i
     noship=noship+a
     return
 
4030 ! ---------------- Galactic Commando ships --------------------
     b=int(20*rnd+5)
     if rnd>.3 then 
       a=1 
     else 
       if rnd>.5 then 
         a=2 
       else 
         a=3 
       end if
     end if
     for i=1 to a
       noship=noship+1
       t(noship)::ship=18
       t(noship)::senergy=s(18)::menergy
       t(noship)::smissile=s(18)::mmissile
       t(noship)::spos=b+int(5*rnd-2)
       t(noship)::sintent=0
       t(noship)::username="GC"+str$(noship)
     next i
     return

 sand_blaster:
     ! ---------------------- Sand blaster ------------------------
     if pr::equip(24)<>1 then
        a$= "Not Mounted"
        call display(23,a$)
	action_combat=action_combat-1
        return
     end if
     a$= "Sand Discharge initiated:  Millions of tiny particles envelop"&
	+" your ship."
     call display(23,a$)
     get #3%, key #0% eq name$(pr::planet), wait 60
     l1 = next_ship
     if (l1 > noship) then noship=noship+1 end if
     t(l1)::ship=22
     t(l1)::senergy=s(22)::menergy
     t(l1)::spos=pr::rpos
     t(l1)::sintent=0
     t(l1)::username=" -  "
     update #3%\free #3%
     return

damage_report:
     ! -------------------- damage report -----------------------
     a=pr::energy/pr::maxenergy
     dmg$="ENERGY FAILING"
     if a>.2 then dmg$="ENERGY LOW." end if
     if a>.4 then dmg$="Major energy loss." end if
     if a>.7 then dmg$="Minor energy loss." end if
     if a=1 then dmg$="Ship undamaged." end if
     call display(14,dmg$)
     return

 galactic_fleet:
     ! -------------------- Galactic Fleet ----------------------
     if pt::zone=4 or (pt::zone=2 and rnd>.2) then return end if
     if rnd>.3 then return end if
     fleetsize=int(pr::moves/10*rnd+1)\fleetpos=int(10*rnd+5)
     if fleetsize>30 then fleetsize=30 end if
     for i=11 to 10+fleetsize
       noship=noship+1
       if i<14 then t(noship)::ship=i else t(noship)::ship=int(3*rnd+11)
       end if
       t(noship)::spos=int(3*rnd-1)+fleetpos
       shipno=noship\gosub 3100
       t(noship)::senergy=s(t(noship)::ship)::menergy
       t(noship)::smissile=s(t(noship)::ship)::mmissile
       t(noship)::username="GF"+str$(noship)
     next i
     return
 
4300 ! ------------------ multi-fire missile rack -------------------
     simult=3		! default firing is 3 missiles
     if pr::equip(13)<3 then simult=pr::equip(13) end if
     a$="You can fire up to "+str$(simult)+" missiles - Press return when done."
     call display(23,a$)
     for k=1 to simult
       gosub 3614
       if action_combat=0 and k<>1 then 
         action_combat= 1
         return 
       end if
     next k
     return
 
4400 ! -------------------- Equipment Destroyed ---------------------
     a=int(ntequip*rnd+1)
     if pr::equip(a)=1 then
       a$= edit$(e(a)::ename,128%)+" DESTROYED!"
       call display(23,a$)
       pr::equip(a)=0
       select a
	case 8
	  pr::maxcargo=s(pr::shiptype)::mcargo
          if pr::totcargo>pr::maxcargo then 
	    pr::totcargo=0
	    for j=1 to 10
	      pr::cargo(j)=int(pr::cargo(j)/3)
              pr::totcargo=pr::totcargo+pr::cargo(j)
            next j
            a$="Some of your cargo has been lost into space."
            call display(23,a$)
	    return
          end if
	case 11
          pr::maxenergy=s(pr::shiptype)::menergy
          if pr::energy>pr::maxenergy then 
            pr::energy=pr::maxenergy
            a$="Some of your energy has been lost."
            call display(23,a$)
          end if
	case 12
          pr::maxmissile=s(pr::shiptype)::mmissile
          if pr::equip(13)>pr::maxmissile then 
            pr::equip(13)=pr::maxmissile
            a$="Some of your missiles were destroyed."
            call display(23,a$)
          end if
	case 16
	  pr::scanrange=2
      end select
     end if
     return
 
4500 ! ---------------------- war zone ------------------------------
     fighters=int(pr::moves/8*rnd+4)+int(5*rnd)\fightpos=int(5*rnd+5)
     if fighters>40 then fighters=40 end if
     for i=1 to fighters
       noship=noship+1
       t(noship)::spos=int(3*rnd-1)+fightpos
       shipno=noship\gosub 3100
       if rnd>.5 then t(noship)::ship=4 else t(noship)::ship=7
       end if
       t(noship)::senergy=s(t(noship)::ship)::menergy
       t(noship)::smissile=s(t(noship)::ship)::mmissile
       t(noship)::username="S"+str$(noship)+str$(int(10*rnd))
     next i
     return
 
4800 ! -------------------- Zone messages --------------------------
     if pr::legal<=2 then
       select pt::zone
	 case 1
	   m$="WARNING! You are in a War Zone - Proceed at your own risk."
	   sender$="GPHQ"\u$=pr::username\gosub send_message
     	 case 3
	   m$="ATTENTION: This world is unclassified - proceed with caution."
	   sender$="GPHQ"\u$=pr::username\gosub send_message
	 case 4
           m$="ALERT! Your trading permit is not recognized here - LEAVE AT" &
		+" ONCE."
           sender$="GPHQ"\u$=pr::username\gosub send_message
        end select
     end if
     return

4900 ! -----------------  messages for thargoids ------------------
     if pr::legal<=2 then
       pr::thargoid=int(pr::moves/10)
       sender$="GPHQ"\u$=pr::username\m$=""
       select pr::moves
	 case 10
           m$="WARNING: Increased Thargoid presence reported in your area."
	 case 20
           m$="ALERT: Thargoid raids believed probable in your area."
	 case 30
           m$="EMERGENCY WARNING! Thargoid invasion of this world expected."
	 case 40
           m$="CONDITION RED! Thargoid invasion zone. Seek shelter."
	 case 50
           m$="FINAL MESSAGE!  Local Thargoid presence has forced temporary"&
            +"@surrender of Gal Pol forces - The situation is out of control."
     	end select
        if m$<>"" then gosub send_message end if
     end if
     return
 
5000 ! -----------Send to nearby player ships m$ -------------------
     when error in
       for i=1 to noship
         if t(i)::player=1 and abs(t(i)::spos-pr::rpos)<pr::scanrange then
           find #2%, key #0% eq t(i)::username, wait 60\free #2%
           sender$=pr::username
           u$=t(i)::username
           gosub send_message
         end if
       next i
     use
       call display(23, "The 'ghost' disappears from your scanner.")
       free #2%
       get #3%, key #0% eq name$(pr::planet), wait 60
       t(i)::ship=-1\t(i)::sintent=-1
       update #3%\free #3%
       continue
     end when
     return
 
5100 ! ----------------- Save current game state -------------------
     when error in
       a$= "Entering suspended animation..."
       call display(23,a$)
       free #1%\free #2%\free #3%
       pr::message = ""
       op = pr
       a$="gal_disk:gal-saves2.dat"
       open a$ as file #4%, organization indexed fixed, &
           allow modify, access modify, primary key op::username, &
           map playermap
       put #4%
       close #4%
       m$=pr::username+ " has entered suspended animation."
       sender$="GPHQ"\chan=0\gosub broadcast_message
       free #1%\free #2%\free #3%
       oldplanet=pr::planet\gosub delete_player_from_action
       find #2%, key #0% eq pr::username, wait 60%
       delete #2%\free #2%
       a$= "Suspension completed."
       call display(23,a$)
     use
       print "Sorry... An error has occured writing the suspend file."
       print "Error is "+ert$(err)
     end when
     goto 10000

other_save: 
     ! ------------ Dump another player into SU ------------------
     when error in
       op::date(1) = 11		! set CTRL-C lockout
       op::message = ""
       a$="gal_disk:gal-saves2.dat"
       open a$ as file #4%, organization indexed fixed, &
           allow modify, access modify, primary key op::username, &
           map playermap
       put #4%
       close #4%
     use
       free #4%\close #4%
     end when
     return
 
5200 ! ------------------ Process event queue --------------------
     for i=1 to numevents
       if ev(i)::source <> pr::username then
       select ev(i)::event
         case "ab"
           a$= ev(i)::source+" has abandonned ship."
	   call display(23,a$)
         case "eb"
           a$= "ENERGY BOMB LAUNCH DETECTED FROM "+ev(i)::source+"."
	   call display(23,a$)
           if pr::equip(18)=1 then
             a$= "ENERGY BOMB SHIELD UP - ANTI-MATTER SAFELY DISPERSED."
	     call display(23,a$)
           else
             a$= "EVERY ATOM IN YOUR BODY IS CONVERTED TO PURE ENERGY..."
	     call display(23,a$)
             goto 8000
           end if
         case "mi"
           if ev(i)::dest=pr::username then
             a$= "INCOMING MISSILE detected from "+ev(i)::source+"."
	     call display(23,a$)
           else
             a$= ev(i)::source+" fired a missile at "+ev(i)::dest+"."
	     call display(23,a$)
           end if
         case "la"
           if ev(i)::dest=pr::username then
             a$= "LASER ATTACK!  Attacking ship: "+ev(i)::source+"."
	     call display(23,a$)
             damage=ev(i)::p1
             gosub 3369
           else
             a$=ev(i)::source+" fired it's laser at "+ev(i)::dest+"."
	     call display(23,a$)
           end if
         case "mo"
           call display(23,"--- GALACTIC BANK TRANSACTION NOTICE ----")
           a$= str$(ev(i)::p1)+" credits received from "+ev(i)::source+"."
	   call display(23,a$)
           pr::credits=pr::credits+ev(i)::p1
         case "mh"
           a$=ev(i)::source+" shakes from the blast of a missile hit."
	   call display(23,a$)
         end select
       end if
     next i
     numevents=0
     return
 

6000 ! ----------------------- select ship -----------------------
     if revived$="OK" then 
       call display(23,"The ship dealer is closed by government order.")
       return
     end if
     call display(21,)	! clear text window
     call display(4,)	! clear trade window
     if pr::ban=TRUE then
       call display(23,"A security guard throws you out of the building.")
       return
     end if
     if pr::shiptype = 23 and s(23)::soldhere=0 and rnd > .5 then
       call display(23, "You'll have to sell that piece of !*?* Yugo elsewhere.")
       pr::ban=TRUE
       return
     end if
     tradein% = 0
     if  pr::shiptype<>0 then
       ! assess value of old ship
       a$="We access the total value of the options on your ship as shown."
       call display(23,a$)
       oldevalue% = 0
       for i=7 to ntequip
         if pr::equip(i) = 1 then 
           oldevalue% = oldevalue% + int(e(i)::usedeprice*factor*pr::equip(i))
	   a$=str$(pr::equip(i))+" "+edit$(e(i)::ename,128%)+": "+ &
	  	str$(int(e(i)::usedeprice*factor))
           call display(24,a$)
         end if
       next i
       a$= "Total equipment value = "+str$(oldevalue%)
       call display(24,a$)
       call display(24,"")
       tradein% = s(pr::shiptype)::cost - int((pr::time_owned * &
	(1- s(pr::shiptype)::resale/100) / 50%)*s(pr::shiptype)::cost) &
	- s(pr::shiptype)::cost/500
       if tradein% < 5000 then tradein% = 5000 end if
       a$ = "Value of a used "+edit$(s(pr::shiptype)::sname,128%)+ " = " + &
				    	str$(tradein%)
       call display(24,a$)
       call display(17,)		! wait for key
       call display(4,)
       call display(21,)
     end if
     a$="The above ships are for sale at the spaceport on "+ &
	edit$(pt::pname,128%)+"."
     call display(23,a$)
     a$="Ship"+space$(34)+"Cost    Energy  Cargo   Laser   Missiles"
     call display(24,a$)
     for i=1 to ntships
       b$=space$(20)
       if s(i)::soldhere=0 and super_user_mode%=0 then iterate end if
       a1$=str$(s(i)::neg_cost)
       a2$=str$(s(i)::menergy)
       a3$=str$(s(i)::mcargo)
       select s(i)::slaser
	 case 0
	   a4$="None"
	 case 1
	   a4$="Pulse"
	 case 2
	   a4$="Beam"
	 case 3
	   a4$="Mil."
	 case 4
	   a4$="Excmr"
	 case 5
	   a4$="X-ray"
	 case else
	   a4$="Mega"
       end select
       a5$=str$(s(i)::mmissile)
       a$=str$(i)+space$(3-len(str$(i)))+left$(s(i)::sname,36)+ a1$ + &
	   space$(8-len(a1$)) + &
	   a2$+space$(8-len(a2$))+a3$+space$(8-len(a3$))+a4$+ &
	   space$(8-len(a4$))+a5$+space$(8-len(a5$))
       call display(24,a$)
     next i

select_ship:
     a$="Ship to purchase> "\call display(1,a$)\b=val(a$)
     if b<0 or b>ntships then goto select_ship end if
     if b=0 and pr::energy<>0 then return end if
     if super_user_mode%=1 then
       pr::credits=10000000
       goto 6081
     end if
     if b=0 and pr::shiptype=0 then 
	call display(23,"Are you planning on trading in a bathtub or what?!?")
	goto select_ship
     end if
     if s(b)::soldhere=0 then
	call display(33,"Not Available here.")
	goto select_ship
     end if

     if (s(b)::temperature = -1) then
       temp% =  (100 - s(b)::resale)   ! starting temp = % below can accept
       if tradein%=0 then temp% = int(temp%/10) end if
     else
       temp% = s(b)::temperature
     end if
     interested% = 1
     while (interested% > 0)
       cost% = s(b)::neg_cost - oldevalue% - tradein%
       call display(23, "List price : "+str$(s(b)::neg_cost))
       call display(23, "Your cost  : "+str$(cost%))
       a$="Your Offer> (0 to abort) "
       call display(1,a$)
       if (integerp(a$) = TRUE) then
         offer=val(a$)
       else
	 offer=0
       end if
       if s(b)::cost = 0 then s(b)::cost = -1 end if
       real_offer = offer+oldevalue%+tradein%
       if offer=0 then 
         interested%=0 
       else 
           if (abs (( s(b)::neg_cost - real_offer) &
		 /s(b)::neg_cost)*100) > ((rnd*0.3*temp%)+ (0.1*temp%)) then
	     call display(23,"That offer is so low you CAN'T be interested.")
             temp% = temp% * 0.5 
           else 
             if (real_offer /s(b)::neg_cost > &
	              (s(b)::neg_cost -s(b)::neg_cost*(temp%/(10000.0+ &
	              int(3000*rnd))))/s(b)::neg_cost) then
	       a$ = "The ship is yours at " + str$(offer) + " credits."
               call display(23,a$)
               a$ = "Buy it? (y/n)"
               call display(1, a$)
               if ((a$ = "y") or (a$ = "Y")) then
                 interested% = -1
               end if
               temp% = temp% * 0.7
               s(b)::neg_cost = offer+oldevalue%+tradein%
             else
               s(b)::neg_cost = int(s(b)::neg_cost - (s(b)::neg_cost - &
			real_offer)*temp% *(rnd*.8+.2)/ (1+temp%))
               a$ = "You can have the ship for " + str$(s(b)::neg_cost - &
			oldevalue% - tradein%)+"."
               call display(23,a$)
               a$ = "Buy it? (y/n)"
               call display(1, a$)
               if ((a$ = "y") or (a$ = "Y")) then
                 interested% = -1 
	       end if
               temp% = temp% * (0.4 + rnd*0.3)
             end if
           end if
       end if
     next
     cost% = s(b)::neg_cost - oldevalue% - tradein%
     s(b)::temperature = temp%

     if pr::shiptype=0 and interested%=0 then 
	call display(23,"Are you planning on trading in a bathtub or what?!?")
	goto select_ship
     end if
     if interested%=0 then 
       return
     end if
     if pr::totcargo>s(b)::mcargo and pr::energy=0 then 
	pr::totcargo=s(b)::mcargo\pr::cargo(10)=pr::totcargo
	call display(33,"Excess gold dumped.")
     end if
     if pr::totcargo>s(b)::mcargo then 
       a$="You'll have to sell some cargo first - there isn't room for"&
	+" it all."
       call display(23,a$)
       return
     end if
     if s(pr::shiptype)::slaser>1 and pr::equip(1)=1 and rnd>.6 then 
	call display(23,"Trying to pull a fast one huh! Forget it." )
	c=int(3000*rnd+500)
	a$="Surcharge for damage: "+str$(c)+"."
	call display(23,a$)
	pr::ban=TRUE
        if pr::credits-c>0 then 
	  pr::credits=pr::credits-c 
	else 
	  call display(23,"Kicked out!")
	  return
        end if
     end if
     if (pr::credits-cost%)<0 then
       call display(33,"You don't have enough credits.")
       goto select_ship
     end if
6081 for i=1 to ntequip\pr::equip(i)=0\next i
     call display(23,"")
     a$="You buy a used "+edit$(s(b)::sname,128%)+"."
     call display(23,a$)
     if pr::fuel>s(b)::mfuel then pr::fuel=s(b)::mfuel end if
     s(b)::soldhere=0
     if pr::energy=0 then pr::fuel=s(b)::mfuel end if
     pr::time_owned = 1
     pr::energy=s(b)::menergy\pr::maxenergy=pr::energy
     pr::equip(13)=s(b)::mmissile-1
     pr::equip(s(b)::slaser*2-1)=1\pr::maxmissile=s(b)::mmissile
     pr::maxcargo=s(b)::mcargo
     pr::credits=pr::credits-cost%
     call display(3,)
     pr::lsj = 0\pr::cloak=0
     ecm_status%=0			  ! ecm (if present) is off
     pr::chan1=1
     pr::chan2=2
     pr::legal=1
     pr::shiptype=b
     pr::scanrange=3
     pr::maxfuel=s(b)::mfuel\pr::speed=s(b)::mdrive
     gosub 1700
     return

 
7800 ! -------------------- Initial Display ---------------------
     call display(19,)	! set up big window
     call display(28,"GALACTIC  TRADER")
     call display(8,"")
     call display(8,"")
     call display(8,"                                v. 4.55")
     call display(8,"")
     call display(8,"                       Written by: Stephan Meier")
     call display(8,"")
     call display(8,"                          Cornell University")
     call display(8,"")
     call display(8,"                             Playtested by:")
     call display(8,"")
     call display(8,"                 Elias Michaelides, Cam Haugen, Ben Lee,")
     call display(8,"               Mike Ahn, Hyung Paek, Sunil William Savkar")
     call display(8,"")
     call display(8,"     (c) Copyright 1989 by Stephan Meier.  All rights reserved.")

     p$="Enter your name, Commander> "
     call display(1,p$)
     pr::personalname=p$
     call display(9,)   	! erase input
 
7900 ! ------------------------------------------------------------
     !                Introductory Blurb
     ! ------------------------------------------------------------
     call display(7,)		! clear big window

     a$= " ---------  CONGRATULATIONS COMMANDER "+edit$(pr::personalname, &
		128%)+"  ----------"
     call display(8,a$)
     call display(8,"")
     a$= "The democratic government of "+edit$(name$(pr::planet),128)+ &
	" is pleased to inform you"
     call display(8,a$)
     a$="That your request for a Trading Permit has been approved.  " &
	+"You are one of "
     call display(8,a$)
     a$="a select few who will have the opportunity to reap the profits" &
	 +" and fame"
     call display(8,a$)
     a$= "associated with the successful trader.  Please note that your "&
	+"Trading Permit"
     call display(8,a$)
     a$= "may be revoked at any time for conduct in violation of the Code"&
	+" of Statutes."
     call display(8,a$)
     a$= "The following is a noncomprehensive list of offences punishable"&
	+" by the above: "
     call display(8,a$)
     call display(8,"")
     call display(8,"  - Use of Anti-matter weapons against Federation ships.")
     call display(8,"  - Excessive overdue taxes.")
     call display(8,"  - Violation of the spirit of Free and Fair Trade.")
     call display(8,"")
     a$="You have managed to amass the 200,000 credits necessary to" &
	+" purchase"
     call display(8,a$)
     a$="get a used Cobra class Trader at list price."
     call display(8,a$)
     a$= "On behalf of the government of "+ &
	edit$(name$(pr::planet),128)+" we wish you a profitable"
     call display(8,a$)
     call display(8,"and rewarding career.")
     call display(17,)
     return

7980 ! ------------------ Delete Dead ship ----------------------
     free #1%\free #2%\free #3%
     oldplanet=pr::planet\gosub delete_player_from_action
     find #2%, key #0% eq pr::username, wait 60%\delete #2%\free #2%

8000 ! -------------------- Game Over --------------------------
     if quit=0 then
       m$="ARGG!! She's breaking up... I can't hold her..."
       chan=0
       gosub broadcast_message
       call display(21,"")
       call display(21,"")
       call display(21,"Captain, we're breakin' up...ARGH!!!!")
     end if
     call display(17,)\scanner_on=0
     call display(9,)	! clear io
     call display(7,)   ! clear big window
     call display(19,)  ! fetch big window
     if quit=0 or quit=2 then
       call display(8,"")
       call display(8,"")
       a$="      REST IN PEACE COMMANDER "+edit$(pr::personalname,128%)
       call display(8,a$)
     end if
     call display(8,"")
     call display(8,"")
     call display(8,"")
     call display(8,"      Ships Destroyed: "+str$(pr::kills))
     call display(8,"")
     call display(8,"      Final Score:     "+str$(pr::score))
     call display(8,"")
     call display(8,"      Final Rank:      "+rank$(pr::rank))
     call display(8,"")
     wealth=pr::credits-pr::debt+s(pr::shiptype)::cost
     call display(8,"      Final Assets:    "+str$(wealth))
     call display(8,"")
     call display(8,"")
     free #1%\free #2%\free #3%
     if done<>1 then
       oldplanet=pr::planet\gosub delete_player_from_action
       find #2%, key #0% eq pr::username, wait 60%\delete #2%\free #2%
     end if
     menumode$="dead"
     
8050 ! -------------- Update Hall of Fame --------------------
     close #4%
     open "gal_disk:gal-scores.dat" as file #4%, organization indexed fixed, &
         allow modify, access modify, primary key dummy, &
         map scoremap
     when error in
       restore #4%
       get #4%, wait 60
     use
       put #4%
     end when
     p=11
     for i=10 to 1 step -1
       if pr::score>sc(i)::score then p=i end if
     next i
     if p=11 then
       select pr::rank
         case 1
           a$="You SUCK big time!  Play again rookie"
         case 2
           a$="Pretty USELESS peformance!"
         case 3
           a$="Not bad - but not good either - just another average trader."
         case 4
           a$="Acceptable - but plenty of room for improvement."
         case 5
           a$="Good fighting!  You had the Thargoids scared for a moment."
         case else
           a$="Excellent! Too bad others were better..."
       end select
       call display(8,a$)
     else
       for i=9 to p step -1
         sc(i+1)=sc(i)
       next i
       sc(p)::sname=pr::personalname
       sc(p)::rank=rank$(pr::rank)
       sc(p)::score=pr::score
       sc(p)::money=wealth
       sc(p)::ships=pr::kills
       if p=1 then
         if pr::energy>0 then
            a$="WOW... A true master Trader!!"
	    call display(8,a$)
            a$="A boring life of gardening and cooking awaits you now..."
	    call display(8,a$)
         else
            call display(8,"")
            a$="Quite Impressive... But don't go thinking you're master of" &
               +" the universe"
	    call display(8,a$)
            a$="as you're DEAD.  Still, even death is a small price to pay" &
               +" for 1st place on"
	    call display(8,a$)
            a$= "the Galactic Hall of Fame."
	    call display(8,a$)
         end if
       else
         a$="Not bad... you ranked "+str$(p)+" out of 10 on the Galactic Hall"&
               +"  of Fame."
	 call display(8,a$)
       end if
     end if
     update #4%\free #4%
8300 ! a$= hall of fame
     call display(17,)
     call display(7,)
     call display(8,"")
     call display(8,"")
     call display(8,"")
     a$="    *********************************************************"
     call display(8,a$)
     a$="    *         GALACTIC TRADER     HALL OF FAME              *"
     call display(8,a$)
     a$="    *********************************************************"
     call display(8,a$)
     call display(8,"")
     a$="Commander     Score        Rank           Kills      Assets"
     call display(8,a$)
     a$="-----------------------------------------------------------"
     call display(8,a$)
     for i=1 to 10
       a1$=str$(sc(i)::score)
       a2$=str$(sc(i)::ships)
       if len(edit$(sc(i)::sname,132)) <> 0 then
         a$=sc(i)::sname+space$(5)+a1$+space$(12-len(a1$))+ &
            sc(i)::rank+"   "+a2$+space$(12-len(a2$))+str$(sc(i)::money)
         call display(8,a$)
       end if
     next i
     close #4%
     call display(8,"")

     ! --------------------- Program Data ---------------------
9000 data"Company/Corporation.","Participating Democracy.", &
        "Representative Democracy.","Impersonal Bureaucracy", &
        "Communist State","Feudal Technocracy","Religious Dictatorship"
     data"Balkanization","No Government Structure","Total Anarchy"
     data "No prohibitions","Explosives prohibited", &
        "Energy weapons prohibited","Military weapons prohibited", &
        "Light assault weapons prohibited", &
        "Concealable weapons prohibited", &
        "All firearms prohibited"
     data"Shotguns prohibited","Long bladed weapons controlled", &
        "Lethal weapons outlawed","All weapons outlawed"
     data"Agricultural","Non-Agricultural","Industrial","Non-Industrial", &
        "Rich","Poor","Water World","Desert World","Vacuum World", &
        "Asteroid Belt","Ice-capped","Subsector Capital"
     data"Stone Age","Bronze Age","Middle Age","Pre Industrial", &
        "Early Industrial (Steam Age)","Middle Industrial", &
        "Nuclear Age","Computer Age","Space Age","Galactic Age"
     data"War Zone","Independent","Unclassified","Alien","Federation", &
        "Federation","Federation","Federation","Federation"
     data"Federation"
     data"Front Pulse Laser",300,"Rear Pulse Laser",300,"Front Beam Laser", &
	 600,"Rear Beam Laser",600,"Front Military Laser",1200, &
         "Rear Military Laser",1100,"Escape Capsule",400, &
	 "Large Cargo hold",300,"Energy Bomb",50,"Rear Mining Laser",330,&
         "Energy Unit",400,"Extra Missile Rack",100,"Missile",5, &
         "Front Excimer Laser",2300,"Multi-Fire Racks",3100, &
         "Long Range Scanner",2900,"Front X-Ray Laser",5300, &
         "Energy Bomb Shield",1130,"ECM System",1540,"LSJ System",2300, &
         "Cloaking Device",3600,"Fire-Control Comp.",7500, &
	 "Trading Computer",60, "Sand Blaster", 750
     data "food",2,1,81,"tonne","slaves (*)",20,1,6417,"head","textiles", &
	8,2,1160, &
        "tonne","minerals",15,1,3617,"tonne","alloys",20,4,7488,"tonne"
     data "luxuries",200,1,640017,"tonne","narcotics (*)",150,1,360017,"kilo"
     data "computers",100,8,168704,"unit","machinery",60,7,63431,"unit", &
	"gold",80,1,102417,"kilo"
     data "clean","mild offender","offender","fugitive","outlaw"
     data "Viper class GalPol ship",70,2,3,50,3,9,200000,1,8,85,70,-75181, &
        "Cobra Class free trader",100,1,5,200,3,0,200000,1,10,95,85,-66898
     data "Python class transport",95,1,2,350,2,3,200000,.75,12,95,80,9150, &
        "Adder class fighter",50,2,5,50,4,200500,-500,1.25,8,90,65,80116872
     data "Ophidion class scout ship",110,2,4,100,4,7,204000,1.5,15,95,90, &
      -115908, "Asp class luxury yacht",120,2,4,150,3,5,205000,1,10,83,70,-27437
     data"Krait class fighter",30,3,5,50,4,6,199950,1.25,7,80,70,-62742, &
        "Fer de Lance",150,3,5,130,4,7,400000,1.25,12,95,90,-102452
     data"Thargoid ship",250,3,5,100,4,8.5,500000,1,10,80,90,-65094, &
        "Asteroid",5,0,0,0,0,9,0,0,0,0,0,3615, &
        "Imperial Destroyer",200,3,5,170,5,8,450000,1,12,80,70,-8618
     data"Imperial Cruiser",300,4,5,400,6,8.8,1200000,1.25,13,80,70,93865, &
        "Imperial Battlestar",420,5,5,1000,9,8.95,5200000,1.25,14,80,70,358544
     data"Missile",5,0,0,0,0,9,0,1.5,0,0,0,4927
     data"Exploration ship",340,4,5,200,8,8.9,2200000,1.5,14,99,93,-88484, &
         "Heavy Battle Carrier",650,2,3,100,3,8.7,1700000,.75,10,82,80,-57646
     data"Death Star",3000,5,20,500,20,9,9200000,.75,15,65,50,201231, &
         "GalPol Commando ship",230,3,6,200,6,9,500000,1,11,80,85,-14333, &
         "Boa Class Bounty Hunter",135,2,5,400,3,4,225000,1.25,12,55,55,160360,&
         "Federation Starbase",50000,7,50,10000,5,9,10200000,0,0,90,50,4465027,&
         "Thargoid Mothership",850,6,20,1000,6,9,6000000,1,10,98,92,270071, &
         "Sand Cloud",1000,0,0,0,0,9,0,0,0,0,0, 6600,&
	 "Yugo class Rescue ship",15,1,1,8,1,6,195000,.75,5,80,35,-37819
     data"Rookie",0,"Novice",250,"Average",800,"Dangerous",2000, &
         "Deadly",5000,"ELITE",12000
     data"MASTER",30000,"SUPREME",60000,"ULTIMATE",150000,"GAL GOD",500000
     data"j","m","re","f","ah","m","ab","m","a","m","c","f","t","m", &
	 "o","f","m","c","r","c","f","c","bo","m","d","m","e","c","s", &
	 "f","b","f","fl","m","sa","c","ec","c","?","f","cl","c","ls","c"
     

     use    ! *************** GLOBAL ERROR HANDLER *******************
       if debug%=1 then 
	 a$= "ERR:"+str$(err) 
	 call display(23,a$)
       end if
       if err=52 or err=50 then
         call display(23, "Numeric input expected - Re-enter.")
         a$="0"
	 b=0
	 a=0
         continue
       end if
       if err=28 then
         call display(23,"CTRL-C TRAP!  Auto-SUing game.")
         aa$="s"
!        call display(23,"Q) Quit   - Terminate game immediately")
!         call display(23,"S) SU     - Suspend game and DISABLE IT FOR A WEEK")
!         call display(23,"R) Resume - Resume play at current point")
!         aa$ = "Enter Q,S or R >"
!         while (aa$<>"Q" and aa$<>"S" and aa$<>"R")
!           call display(1,aa$)
!         next
         select aa$
           case "q"
	     quit=1
             continue 8000
           case "r"
	     continue
           case "s"
             pr::date(1)=11
             continue 5100
         end select
       end if

       ! error cannot be recovered from - attempt to save situation
       if err=15 then
         a$="A File Lock condition has been detected for 60 seconds."
	 call display(23,a$)
         a$="SUing game and exiting - please wait a while and try again."
         call display(23,a$)
       end if
       call display(23,"******************************************************")
       call display(23,"*  FATAL ELECTRONICS ERROR - LIFE SUPPORT GONE       *")
       call display(23,"*  CRYOSTAT ACTIVATED - SUSPENDED ANIMATION ACHIEVED *")
       call display(23,"*        ERRORS WRITTEN TO GAL-TRADER.DMP            *")
       call display(23,"******************************************************")
       open "gal-trader.dmp" for output as file #5%
       print #5%;"Gal-Trader v. 4.55 crash log "+date$(0%)+" "+time$(0%)+"."
       print #5%;"Error =";err;" Loc = ";erl;" Module = ";ern$;"."
       print #5%;ert$(err)
       print #5%
       print #5%;"Please send this file to HONY@CRNLVAX5.BITNET if you expect "
       print #5%;"it to be useful for debugging purposes."
       continue 5100
     end when

10000 close #1%\close #2%\close #3%\close #4%\close #5%

      end program
