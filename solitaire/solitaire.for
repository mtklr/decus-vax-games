      program solitaire
      implicit none
      character *65 message,verify
      character *4 sc_str
      character *3 card(52)
      integer *4 lib$disable_ctrl,length,sys$setpri,i,j,win,nn,mm
      integer *4 disp,paste,keyb,memory(52),tm_code,lib$wait,mask,old
      integer *4 from,to,pile(24),board(7,13),top(6,6),save(4,1),send
      integer *4 lib$get_foreign,score,run,seed,lib$enable_ctrl,status
      logical *4 compare_save,compare_board,quit/.false./
      include '($smgdef)'
      include '($smgmsg)'
      include '($libclidef)'
      include '(smg$routines)'

      mask = lib$m_cli_ctrly
      call ec(lib$disable_ctrl(mask,old))
      run = 1

      card(01) = 'A S'
      card(02) = '2 S'
      card(03) = '3 S'
      card(04) = '4 S'
      card(05) = '5 S'
      card(06) = '6 S'
      card(07) = '7 S'
      card(08) = '8 S'
      card(09) = '9 S'
      card(10) = '10S'
      card(11) = 'J S'
      card(12) = 'Q S'
      card(13) = 'K S'
      card(14) = 'A C'
      card(15) = '2 C'
      card(16) = '3 C'
      card(17) = '4 C'
      card(18) = '5 C'
      card(19) = '6 C'
      card(20) = '7 C'
      card(21) = '8 C'
      card(22) = '9 C'
      card(23) = '10C'
      card(24) = 'J C'
      card(25) = 'Q C'
      card(26) = 'K C'
      card(27) = 'A H'
      card(28) = '2 H'
      card(29) = '3 H'
      card(30) = '4 H'
      card(31) = '5 H'
      card(32) = '6 H'
      card(33) = '7 H'
      card(34) = '8 H'
      card(35) = '9 H'
      card(36) = '10H'
      card(37) = 'J H'
      card(38) = 'Q H'
      card(39) = 'K H'
      card(40) = 'A D'
      card(41) = '2 D'
      card(42) = '3 D'
      card(43) = '4 D'
      card(44) = '5 D'
      card(45) = '6 D'
      card(46) = '7 D'
      card(47) = '8 D'
      card(48) = '9 D'
      card(49) = '10D'
      card(50) = 'J D'
      card(51) = 'Q D'
      card(52) = 'K D'


 3    call ec(smg$create_virtual_display(24,80,disp))
      call ec(smg$create_pasteboard(paste))
      call ec(smg$create_virtual_keyboard(keyb))
      call ec(smg$set_broadcast_trapping(paste))
      call ec(smg$begin_display_update(disp))
      call ec(smg$draw_rectangle(disp,3,1,17,7))
      call ec(smg$draw_rectangle(disp,3,10,17,16))
      call ec(smg$draw_rectangle(disp,3,19,17,25))
      call ec(smg$draw_rectangle(disp,3,28,17,34))
      call ec(smg$draw_rectangle(disp,3,37,17,43))
      call ec(smg$draw_rectangle(disp,3,46,17,52))
      call ec(smg$draw_rectangle(disp,3,55,17,61))
      call ec(smg$draw_rectangle(disp,1,66,4,70))
      call ec(smg$draw_rectangle(disp,7,66,10,70))
      call ec(smg$draw_rectangle(disp,13,66,16,70))
      call ec(smg$draw_rectangle(disp,19,66,22,70))
      call ec(smg$draw_rectangle(disp,20,53,22,59))
      call ec(smg$draw_rectangle(disp,20,45,22,51))
      call ec(smg$put_chars(disp,'1',18,4))
      call ec(smg$put_chars(disp,'2',18,13))
      call ec(smg$put_chars(disp,'3',18,22))
      call ec(smg$put_chars(disp,'4',18,31))
      call ec(smg$put_chars(disp,'5',18,40))
      call ec(smg$put_chars(disp,'6',18,49))
      call ec(smg$put_chars(disp,'7',18,58))
      call ec(smg$put_chars(disp,'S',2,72))
      call ec(smg$put_chars(disp,'D',8,72))
      call ec(smg$put_chars(disp,'H',14,72))
      call ec(smg$put_chars(disp,'C',20,72))
      call ec(smg$put_chars(disp,'Stack',23,54))
      call ec(smg$put_chars(disp,'Score',23,46))
      call ec(smg$put_chars(disp,'     ',2,11,,smg$m_reverse))
      call ec(smg$put_chars(disp,'     ',2,20,,smg$m_reverse))
      call ec(smg$put_chars(disp,'     ',2,29,,smg$m_reverse))
      call ec(smg$put_chars(disp,'     ',2,38,,smg$m_reverse))
      call ec(smg$put_chars(disp,'     ',2,47,,smg$m_reverse))
      call ec(smg$put_chars(disp,'     ',2,56,,smg$m_reverse))
      call ec(smg$put_chars(disp,'   ',21,55,,smg$m_reverse))
      call ec(smg$end_display_update(disp))
      call ec(smg$paste_virtual_display(disp,paste,1,1))
      call shuffle(pile,board,top,run,seed)
      call ec(smg$begin_display_update(disp))
      j = 0
      do i = 3,57,9
        j = j + 1
        if (board(j,1).lt.27) then
          call ec(smg$put_chars(disp,card(board(j,1)),4,i,,
     +      smg$m_reverse))
        else
          call ec(smg$put_chars(disp,card(board(j,1)),4,i))
        endif
      enddo
      call ec(smg$put_chars(disp,'Move> ',22,4))
      call ec(smg$end_display_update(disp))

*
* The cards have been distributed and the board has been set.
* It is now time to proceed with the interactive game.
*


 50   call ec(sys$setpri(,,%val(4),))
      call num_to_str(score,sc_str,length)
      call ec(smg$put_chars(disp,sc_str(1:length),21,46+4-length))
      call ec(smg$get_broadcast_message(paste,message,length))
      if (length.ne.0) then
        call ec(smg$ring_bell(disp,2))
        call ec(smg$put_chars(disp,message,1,1))
      endif
      win = 0
      do i = 1,4
        if (index(card(save(i,1)),'K').ne.0) win = win + 1
      enddo
      if (win.eq.4) go to 96
      call ec(smg$set_cursor_abs(disp,22,10))
      status = smg$read_keystroke(keyb,tm_code)
      if ((.not.status).and.(status.ne.smg$_eof)) call ec(status)
      if (tm_code.eq.smg$k_trm_lowercase_r) then
        call ec(smg$erase_chars(disp,65,1,1))
        call ec(smg$repaint_screen(paste))
        go to 50
      endif
      if (tm_code.eq.smg$k_trm_lowercase_q) go to 98
      if ((tm_code.eq.smg$k_trm_one).or.(tm_code.eq.smg$k_trm_kp1))
     +  then
        from = 1
        call ec(smg$put_chars(disp,'1'))
        go to 55
      endif
      if ((tm_code.eq.smg$k_trm_two).or.(tm_code.eq.smg$k_trm_kp2))
     +  then
        from = 2
        call ec(smg$put_chars(disp,'2'))
        go to 55
      endif
      if ((tm_code.eq.smg$k_trm_three).or.(tm_code.eq.smg$k_trm_kp3))
     +  then
        from = 3
        call ec(smg$put_chars(disp,'3'))
        go to 55
      endif
      if ((tm_code.eq.smg$k_trm_four).or.(tm_code.eq.smg$k_trm_kp4))
     +  then
        from = 4
        call ec(smg$put_chars(disp,'4'))
        go to 55
      endif
      if ((tm_code.eq.smg$k_trm_five).or.(tm_code.eq.smg$k_trm_kp5))
     +  then
        from = 5
        call ec(smg$put_chars(disp,'5'))
        go to 55
      endif
      if ((tm_code.eq.smg$k_trm_six).or.(tm_code.eq.smg$k_trm_kp6))
     +  then
        from = 6
        call ec(smg$put_chars(disp,'6'))
        go to 55
      endif
      if ((tm_code.eq.smg$k_trm_seven).or.(tm_code.eq.smg$k_trm_kp7))
     +  then
        from = 7
        call ec(smg$put_chars(disp,'7'))
        go to 55
      endif
      if ((tm_code.eq.smg$k_trm_pf1).or.(tm_code.eq.smg$k_trm_f18)) then
        from = 9 !draw option
        call ec(smg$put_chars(disp,'Draw'))
        call draw_card(pile)
        if (pile(1).lt.27) then
          call ec(smg$put_chars(disp,card(pile(1)),21,55,,
     +      smg$m_reverse))
        else
          call ec(smg$put_chars(disp,card(pile(1)),21,55))
        endif
        call ec(smg$put_chars(disp,'    ',22,10))
        go to 50
      endif
      if ((tm_code.eq.smg$k_trm_pf2).or.
     +  (tm_code.eq.smg$k_trm_question_mark)) then
        call help(paste,keyb)
        go to 50
      endif
      if ((tm_code.eq.smg$k_trm_pf3).or.(tm_code.eq.smg$k_trm_f19)) then
        from = 0 !from option
        call ec(smg$put_chars(disp,'Stack'))
        go to 55
      endif
      if ((tm_code.eq.smg$k_trm_pf4).or.(tm_code.eq.smg$k_trm_f20)) then
        from = 8 !save option
        call ec(smg$put_chars(disp,'Save'))
        go to 55
      endif
      call ec(smg$put_chars(disp,'Type "?" for help',24,6))
      call ec(lib$wait(1.0))
      call ec(smg$put_chars(disp,'                  ',22,10))
      call ec(smg$put_chars(disp,'                 ',24,6))
      call ec(smg$set_cursor_abs(disp,22,10))
      go to 50

 55   call ec(smg$put_chars(disp,' to '))
      call ec(smg$read_keystroke(keyb,tm_code))
      if ((tm_code.eq.smg$k_trm_one).or.(tm_code.eq.smg$k_trm_kp1))
     +  then
        to = 1
        call ec(smg$put_chars(disp,'1'))
        go to 60
      endif
      if ((tm_code.eq.smg$k_trm_two).or.(tm_code.eq.smg$k_trm_kp2))
     +  then
        to = 2
        call ec(smg$put_chars(disp,'2'))
        go to 60
      endif
      if ((tm_code.eq.smg$k_trm_three).or.(tm_code.eq.smg$k_trm_kp3))
     +  then
        to = 3
        call ec(smg$put_chars(disp,'3'))
        go to 60
      endif
      if ((tm_code.eq.smg$k_trm_four).or.(tm_code.eq.smg$k_trm_kp4))
     +  then
        to = 4
        call ec(smg$put_chars(disp,'4'))
        go to 60
      endif
      if ((tm_code.eq.smg$k_trm_five).or.(tm_code.eq.smg$k_trm_kp5))
     +  then
        to = 5
        call ec(smg$put_chars(disp,'5'))
        go to 60
      endif
      if ((tm_code.eq.smg$k_trm_six).or.(tm_code.eq.smg$k_trm_kp6))
     +  then
        to = 6
        call ec(smg$put_chars(disp,'6'))
        go to 60
      endif
      if ((tm_code.eq.smg$k_trm_seven).or.(tm_code.eq.smg$k_trm_kp7))
     +  then
        to = 7
        call ec(smg$put_chars(disp,'7'))
        go to 60
      endif
      if ((tm_code.eq.smg$k_trm_pf3).or.(tm_code.eq.smg$k_trm_f19)) then
        to = 0
        call ec(smg$put_chars(disp,'Stack'))
        go to 60
      endif
      if ((tm_code.eq.smg$k_trm_pf4).or.(tm_code.eq.smg$k_trm_f20)) then
        to = 8
        call ec(smg$put_chars(disp,'Save'))
        go to 60
      endif
      call ec(smg$put_chars(disp,'Type "?" for help',24,6))
      call ec(lib$wait(1.0))
      call ec(smg$put_chars(disp,'                  ',22,10))
      call ec(smg$put_chars(disp,'                 ',24,6))
      call ec(smg$set_cursor_abs(disp,22,10))
      go to 50

 60   if ((from.eq.8).or.(to.eq.0)) then
        call illegal(disp)
        go to 50
      endif
      if (from.eq.to) then
        call illegal(disp)
        go to 50
      endif
      if (from.eq.0) then
        if (to.eq.8) then
          if (index(card(pile(1)),'S').ne.0) send = save(1,1)
          if (index(card(pile(1)),'D').ne.0) send = save(2,1)
          if (index(card(pile(1)),'H').ne.0) send = save(3,1)
          if (index(card(pile(1)),'C').ne.0) send = save(4,1)
          if (not(compare_save(card(pile(1)),card(send),
     +      pile(1),send))) then
            call illegal(disp)
            go to 50
           else
            call save_gain(disp,card,save,pile,board,0,0)
            score = score + 12
            call pile_loss(disp,card,pile)
          endif
        elseif ((to.gt.0).and.(to.lt.8)) then
          do i = 1,13
            if (board(to,i).ne.0) nn = i
          enddo
          if (not(compare_board(board,card(pile(1)),card(board(to,nn)),
     +      to))) then
            call illegal(disp)
            go to 50
          else
            call board_gain_single(disp,card,pile,board,to,nn)
            score = score + 5
            call pile_loss(disp,card,pile)
          endif
        endif
        call ec(smg$put_chars(disp,'                 ',22,10))
        call ec(smg$set_cursor_abs(disp,22,10))
        go to 50
      elseif ((from.gt.0).and.(from.lt.8)) then
        do i = 1,13
          if (board(from,i).ne.0) mm = i
        enddo
        if (to.eq.8) then
          if (index(card(board(from,mm)),'S').ne.0) send = save(1,1)
          if (index(card(board(from,mm)),'D').ne.0) send = save(2,1)
          if (index(card(board(from,mm)),'H').ne.0) send = save(3,1)
          if (index(card(board(from,mm)),'C').ne.0) send = save(4,1)
          if (not(compare_save(card(board(from,mm)),card(send),
     +      board(from,mm),send))) then
            call illegal(disp)
            go to 50
          else
            call save_gain(disp,card,save,pile,board,from,mm)
            score = score + 5
            call board_loss_single(disp,card,board,from,mm,top,score)
          endif
        elseif ((to.gt.0).and.(to.lt.8)) then
          do i = 1,13
            if (board(from,i).ne.0) mm = i
            if (board(to,i).ne.0) nn = i
          enddo
          if (not(compare_board(board,card(board(from,1)),
     +      card(board(to,nn)),to))) then
            call illegal(disp)
            go to 50
          else
            call board_gain_whole(disp,card,board,from,mm,to,nn)
            call board_loss_whole(disp,card,board,from,mm,top,score)
          endif
        endif
        call ec(smg$put_chars(disp,'                ',22,10))
        call ec(smg$set_cursor_abs(disp,22,10))
        go to 50
      endif


 96   call ec(smg$erase_display(disp,1,1,24,80))
      call ec(smg$put_chars_highwide(disp,'**************',
     +  9,27,,smg$m_blink))
      call ec(smg$put_chars_highwide(disp,'*  YOU WON!  *',
     +  11,27,,smg$m_blink))
      call ec(smg$put_chars_highwide(disp,'**************',
     +  13,27,,smg$m_blink))
      call ec(smg$ring_bell(disp,3))
      call ec(smg$set_cursor_abs(disp,23,1))
      score = score + 25
      run = run + 1
      call ec(lib$wait(3.0))
      call ec(smg$delete_virtual_keyboard(keyb))
      call ec(smg$delete_pasteboard(paste))
      call ec(smg$delete_virtual_display(disp))
      go to 97
 
 98   call ec(smg$delete_virtual_keyboard(keyb))
      call ec(smg$delete_pasteboard(paste))
      call ec(smg$delete_virtual_display(disp))
      call score_list(score,run)
      print*
      write(*,100)
      read(*,'(a)') verify
      if ((index(verify,'y').eq.0).and.(index(verify,'Y').eq.0)) then
        quit = .true.
      else
        score = 0
        run = 1
      endif
 97   if (not(quit)) then
        do i = 1,4
          save(i,1) = 0
        enddo
        do i = 1,7
          do j = 1,13
            board(i,j) = 0
          enddo
        enddo
        do i = 1,6
          do j = 1,6
            top(i,j) = 0
          enddo
        enddo
        go to 3
      endif
      call ec(lib$enable_ctrl(old))
 100  format('$Do you wish to play again? ')
      end


      subroutine score_list (score,run)
      implicit none
      integer *4 score,num(15),ntmp(16),run,brd(15),btmp(15)
      integer *4 i,j,lib$wait,lib$getjpi,status
      character *12 userid,id(15),itmp(16)
      integer *4 attempts
      logical *4 change
      include '($jpidef)'

      change = .false.
      attempts = 0
      call ec(lib$getjpi(jpi$_username,,,,userid))
10    attempts = attempts + 1
      open(11,
     +  file='disk$userdisk1:[mas0.maslib.games.solitaire]list.high',
     +  status='unknown',iostat=status,shared)
      if (status.ne.0) then
        call ec(lib$wait(2.0))
        if (attempts.gt.10) then
          print*,'ERROR opening scores list!'
          stop
        endif
        go to 10
      endif
      do i = 1,15
        read(11,80,end=60) ntmp(i),itmp(i),btmp(i)
      enddo
 60   do i = 1,15
        if (score.gt.ntmp(i)) then
          change = .true.
          num(i) = score
          id(i) = userid
          brd(i) = run
          do j = i+1,15
            num(j) = ntmp(j-1)
            id(j) = itmp(j-1)
            brd(j) = btmp(j-1)
          enddo
          go to 62
        endif
        num(i) = ntmp(i)
        id(i) = itmp(i)
        brd(i) = btmp(i)
      enddo
 62   if (change) then
        rewind(11)
        do i = 1,15
          write(11,80) num(i),id(i),brd(i)
        enddo
      endif
      rewind(11)
      print*,' RANK     USERNAME     SCORE     BOARD'
      print*,' ====     ========     =====     ====='
      print*
      do i = 1,15
        read(11,80,end=95) num(i),id(i),brd(i)
        if (num(i).eq.0) go to 95
        write(*,82) i,id(i),num(i),brd(i)
      enddo
 80   format(i4,a12,i4)
 82   format(' ',i4,6x,a12,1x,i4,6x,i4)
 95   close(11)
      end


      logical *4 function compare_save(cardf,cardt,from,to)
      implicit none
      character *(*) cardf,cardt
      integer *4 from,to

      compare_save = .false.
      if ((cardf(3:3).eq.cardt(3:3)).and.(from.eq.to+1))
     +  compare_save = .true.
      if ((to.eq.0).and.(index(cardf(1:1),'A').ne.0))
     +  compare_save = .true.
      end


      logical *4 function compare_board(board,cardf,cardt,to)
      implicit none
      character *(*) cardf,cardt
      integer *4 board(7,13),to,cardf_val,cardt_val
     
      if (index(cardf,'A').ne.0) cardf_val = 1
      if (index(cardf,'2').ne.0) cardf_val = 2
      if (index(cardf,'3').ne.0) cardf_val = 3
      if (index(cardf,'4').ne.0) cardf_val = 4
      if (index(cardf,'5').ne.0) cardf_val = 5
      if (index(cardf,'6').ne.0) cardf_val = 6
      if (index(cardf,'7').ne.0) cardf_val = 7
      if (index(cardf,'8').ne.0) cardf_val = 8
      if (index(cardf,'9').ne.0) cardf_val = 9
      if (index(cardf,'0').ne.0) cardf_val = 10
      if (index(cardf,'J').ne.0) cardf_val = 11
      if (index(cardf,'Q').ne.0) cardf_val = 12
      if (index(cardf,'K').ne.0) cardf_val = 13

      if (index(cardt,'A').ne.0) cardt_val = 1
      if (index(cardt,'2').ne.0) cardt_val = 2
      if (index(cardt,'3').ne.0) cardt_val = 3
      if (index(cardt,'4').ne.0) cardt_val = 4
      if (index(cardt,'5').ne.0) cardt_val = 5
      if (index(cardt,'6').ne.0) cardt_val = 6
      if (index(cardt,'7').ne.0) cardt_val = 7
      if (index(cardt,'8').ne.0) cardt_val = 8
      if (index(cardt,'9').ne.0) cardt_val = 9
      if (index(cardt,'0').ne.0) cardt_val = 10
      if (index(cardt,'J').ne.0) cardt_val = 11
      if (index(cardt,'Q').ne.0) cardt_val = 12
      if (index(cardt,'K').ne.0) cardt_val = 13

      compare_board = .false.
      if ((board(to,1).eq.0).and.(index(cardf,'K').ne.0))
     +  compare_board = .true.
      if ((index(cardf,'D').ne.0).or.(index(cardf,'H').ne.0)) then
        if ((index(cardt,'S').ne.0).or.(index(cardt,'C').ne.0)) then
          if (cardt_val.eq.cardf_val+1) then
            compare_board = .true.
          endif
        endif
      endif
      if ((index(cardf,'S').ne.0).or.(index(cardf,'C').ne.0)) then
        if ((index(cardt,'D').ne.0).or.(index(cardt,'H').ne.0)) then
          if (cardt_val.eq.cardf_val+1) then
            compare_board = .true.
          endif
        endif
      endif
      end


      subroutine pile_loss(disp,card,pile)
      implicit none
      character *3 card(52)
      integer *4 i,j,disp,smg$put_chars,pile(24),tmp(25)
      include '($smgdef)'

      do i = 1,24
        tmp(i) = pile(i)
      enddo
      tmp(25) = 0
      do j = 1,24
        pile(j) = tmp(j+1)
      enddo
      if (pile(1).eq.0) then
        call ec(smg$put_chars(disp,'---',21,55))
        return
      endif
      if (pile(1).lt.27) then
        call ec(smg$put_chars(disp,card(pile(1)),21,55,,smg$m_reverse))
      else
        call ec(smg$put_chars(disp,card(pile(1)),21,55))
      endif
      end


      subroutine board_loss_single(disp,card,board,from,mm,top,score)
      implicit none
      character *3 card(52)
      integer *4 disp,board(7,13),from,mm,top(6,6),smg$put_chars
      integer *4 score

      if (mm.le.1) then
        call ec(smg$put_chars(disp,'   ',4,3+9*(from-1)))
        board(from,1) = 0
        if (from.ne.1) call top_loss(disp,card,board,top,from,score)
      else
        call ec(smg$put_chars(disp,'   ',3+mm,3+9*(from-1)))
        board(from,mm) = 0
      endif
      end


      subroutine board_gain_single(disp,card,pile,board,to,nn)
      implicit none
      character *3 card(52)
      integer *4 disp,board(7,13),pile(24),to,nn,smg$put_chars
      include '($smgdef)'

      if (board(to,1).eq.0) nn = 0
      if (pile(1).lt.27) then
        call ec(smg$put_chars(disp,card(pile(1)),
     +    3+nn+1,3+9*(to-1),,smg$m_reverse))
      else
        call ec(smg$put_chars(disp,card(pile(1)),
     +    3+nn+1,3+9*(to-1)))
      endif
      board(to,nn+1) = pile(1)
      end


      subroutine board_gain_whole (disp,card,board,from,mm,to,nn)
      implicit none
      character *3 card(52)
      integer *4 i,disp,board(7,13),from,mm,to,nn,smg$put_chars
      include '($smgdef)'

      if (board(to,1).eq.0) nn = 0
      do i = 1,13
        if (board(from,i).eq.0) return
        if (board(from,i).lt.27) then
          call ec(smg$put_chars(disp,card(board(from,i)),
     +      3+nn+i,3+9*(to-1),,smg$m_reverse))
        else
          call ec(smg$put_chars(disp,card(board(from,i)),
     +      3+nn+i,3+9*(to-1)))
        endif
        board(to,nn+i) = board(from,i)
      enddo
      end


      subroutine board_loss_whole(disp,card,board,from,mm,top,score)
      implicit none
      character *3 card(52)
      integer *4 i,disp,board(7,13),from,mm,top(6,6),smg$put_chars,score

      do i = 1,mm
        call ec(smg$put_chars(disp,'   ',3+i,3+9*(from-1)))
        board(from,i) = 0
      enddo
      if (from.eq.1) return
      if (top(from-1,1).ne.0) call top_loss(disp,card,board,top,from,
     +  score)
      end


      subroutine save_gain(disp,card,save,pile,board,from,mm)
      implicit none
      character *3 card(52)
      integer *4 disp,save(4,1),smg$put_chars,pile(24),from
      integer *4 board(7,13),mm
      include '($smgdef)'
      
      if (((index(card(pile(1)),'S').ne.0).and.(from.eq.0)).or.
     +  ((index(card(board(from,mm)),'S').ne.0).and.(from.ne.0))) then
        if (from.eq.0) then
          save(1,1) = pile(1)
        else
          save(1,1) = board(from,mm)
        endif
        if (save(1,1).lt.27) then
          call ec(smg$put_chars(disp,card(save(1,1)),2,67,,
     +      smg$m_reverse))
        else
          call ec(smg$put_chars(disp,card(save(1,1)),2,67))
        endif
      endif
      if (((index(card(pile(1)),'D').ne.0).and.(from.eq.0)).or.
     +  ((index(card(board(from,mm)),'D').ne.0).and.(from.ne.0))) then
        if (from.eq.0) then
          save(2,1) = pile(1)
        else
          save(2,1) = board(from,mm)
        endif
        if (save(2,1).lt.27) then
          call ec(smg$put_chars(disp,card(save(2,1)),8,67,,
     +      smg$m_reverse))
        else
          call ec(smg$put_chars(disp,card(save(2,1)),8,67))
        endif
      endif
      if (((index(card(pile(1)),'H').ne.0).and.(from.eq.0)).or.
     +  ((index(card(board(from,mm)),'H').ne.0).and.(from.ne.0))) then
        if (from.eq.0) then
          save(3,1) = pile(1)
        else
          save(3,1) = board(from,mm)
        endif
        if (save(3,1).lt.27) then
          call ec(smg$put_chars(disp,card(save(3,1)),14,67,,
     +      smg$m_reverse))
        else
          call ec(smg$put_chars(disp,card(save(3,1)),14,67))
        endif
      endif
      if (((index(card(pile(1)),'C').ne.0).and.(from.eq.0)).or.
     +  ((index(card(board(from,mm)),'C').ne.0).and.(from.ne.0))) then
        if (from.eq.0) then
          save(4,1) = pile(1)
        else
          save(4,1) = board(from,mm)
        endif
        if (save(4,1).lt.27) then
          call ec(smg$put_chars(disp,card(save(4,1)),20,67,,
     +      smg$m_reverse))
        else
          call ec(smg$put_chars(disp,card(save(4,1)),20,67))
        endif
      endif
      end


      subroutine top_loss(disp,card,board,top,from,score)
      implicit none
      character *3 card(52)
      integer *4 i,j,disp,top(6,6),smg$put_chars,from,tmp(6,7)
      integer *4 board(7,13),score
      include '($smgdef)'

      if (top(from-1,1).eq.0) then
        return
      else
        if (top(from-1,1).lt.27) then
          call ec(smg$put_chars(disp,card(top(from-1,1)),4,
     +      3+9*(from-1),,smg$m_reverse))
        else
          call ec(smg$put_chars(disp,card(top(from-1,1)),4,
     +      3+9*(from-1)))
        endif
      endif
      board(from,1) = top(from-1,1)
      do i = 1,6
        tmp(from-1,i) = top(from-1,i)
      enddo
      tmp(6,7) = 0
      do j = 1,6
        top(from-1,j) = tmp(from-1,j+1)
      enddo
      if (top(from-1,1).eq.0) then
        call ec(smg$put_chars(disp,'     ',2,11+9*(from-2)))
        score = score + 8
      endif
      end


      subroutine shuffle(pile,board,top,run,seed)
      implicit none
      character *3 card(52)
      real *4 value
      integer *4 i,j,out(3),number,memory(52),count,seed,run
      integer *4 pile(24),board(7,13),top(6,6)

      do i = 1,52
        memory(i) = 0
      enddo
      if (run.eq.1) then
        call time(out)
        seed = out(2)/2 + 1
        value = ran(seed) * 100
      endif
 10   value = ran(seed) * 100
      number = value
      if (number.gt.52) go to 10
      do i = 1,52
        if (memory(i).eq.number) go to 10
        if (memory(i).eq.0) go to 60
      enddo
 60   memory(i) = number
      if (memory(52).ne.0) go to 90
      go to 10
 90   count = 0
      do i = 1,7
        count = count + 1
        board(i,1) = memory(count)
      enddo
      do i = 1,6
        do j = 1,i
          count = count + 1
          top(i,j) = memory(count)
        enddo
      enddo
      do i = 1,24
        count = count + 1
        pile(i) = memory(count)
      enddo
      end


      subroutine draw_card(pile)
      implicit none
      integer *4 i,j,pile(24),tmp(24)

      do i = 1,24
        if (pile(i).eq.0) go to 60
        tmp(i) = pile(i)
      enddo
 60   if (i.le.4) then
        do j = 1,i-1
          pile(j) = tmp(j+1)
        enddo
        pile(i-1) = tmp(1)
        return
      endif
      do j = 1,i-1
        pile(j) = tmp(j+2)
      enddo
      pile(i-2) = tmp(1)
      pile(i-1) = tmp(2)
      end


      subroutine help (paste,keyb)
      implicit none
      integer *4 hdisp,smg$create_virtual_display,smg$put_chars
      integer *4 smg$paste_virtual_display,smg$read_keystroke
      integer *4 smg$delete_virtual_display,paste,keyb,stroke,status
      include '($smgdef)'

      call ec(smg$create_virtual_display(11,60,hdisp,
     +  smg$m_block_border))
      call ec(smg$paste_virtual_display(hdisp,paste,5,5))
      call ec(smg$put_chars(hdisp,
     +  ' PF1,F18,L8  - Places a new card on top of the stack.',2,1))
      call ec(smg$put_chars(hdisp,
     +  ' PF2,?       - This help menu.',3,1))
      call ec(smg$put_chars(hdisp,
     +  ' PF3,F19,L9  - Play a card from the stack.',4,1))
      call ec(smg$put_chars(hdisp,
     +  ' PF4,F20,L10 - Move a card to the "save" stacks.',5,1))
      call ec(smg$put_chars(hdisp,
     +  ' q           - Quits the game.',6,1))
      call ec(smg$put_chars(hdisp,
     +  ' 1-7         - Moves a card to or from the selected column.',
     +  7,1))
      call ec(smg$put_chars(hdisp,
     +  ' r           - Redraws the screen.',8,1))
      call ec(smg$put_chars(hdisp,
     +  '               [Press any key to continue]',10,1))
      status = smg$read_keystroke(keyb,stroke)
      call ec(smg$delete_virtual_display(hdisp))
      end


      subroutine illegal (disp)
      implicit none
      integer *4 smg$put_chars,smg$set_cursor_abs,disp,lib$wait

      call ec(smg$put_chars(disp,'ILLEGAL MOVE!',24,6))
      call ec(lib$wait(1.0))
      call ec(smg$put_chars(disp,'             ',24,6))
      call ec(smg$put_chars(disp,'               ',22,10))
      call ec(smg$set_cursor_abs(disp,22,10))
      end


      subroutine num_to_str(num,str,length)
      implicit none
      character *(*) str
      integer *4 i,num,length

      write(str,'(i4)') num
      do i = 1,4
        if (str(i:i).ne.' ') go to 60
      enddo
 60   length = 5 - i
      str(1:4) = str(i:4)
      end

      subroutine ec (status)
      implicit none
      integer *4 status

      if (.not.status) call lib$signal(%val(status))
      end

********************************************************************************
*                                                                              *
*   Program:  SOLITAIRE                                                        *
*   Author:   William W. Brennessel                                            *
*   BITNET:   MASMUMMY@UBVMS                                                   *
*   Internet: masmummy@ubvms.cc.buffalo.edu                                    *
*                                                                              *
*   This program was created for personal use, and may be copied and altered   *
*   under the condition that the author is not responsible for any problems    *
*   that may occur.  Comments and criticisms are always welcome.               *
*                                                                              *
********************************************************************************
