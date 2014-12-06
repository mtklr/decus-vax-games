      program sinister_island
      implicit none
      character *16 money_str,risk_str,answer
      character *8 item(21)
      real *16 money,risk
      real *4 value,wait
      integer *4 i,j,k,l,m,n,now(3),seed,number,disp,paste,keyb,status
      integer *4 odds(16),slot(3),winner,kind(6),length
      integer *4 mask,save
      data item/'  BAR   ',
     +          '  BELL  ','  BELL  ',
     +          ' ORANGE ',' ORANGE ',' ORANGE ',
     +          ' LEMON  ',' LEMON  ',' LEMON  ',' LEMON  ',
     +          ' BANANA ',' BANANA ',' BANANA ',' BANANA ',' BANANA ',
     +          ' CHERRY ',' CHERRY ',' CHERRY ',' CHERRY ',' CHERRY ',
     +          ' CHERRY '/
      data odds/15625,1875,550,231,125,66,2604,625,275,154,104,
     +          433,208,137,104,83/
      include '(lib$routines)'
      include '(mth$routines)'
      include '(smg$routines)'
      include '($libdef)'
      include '($smgdef)'
      include '($smgmsg)'
      include '($ssdef)'

      call ec(lib$disable_ctrl(mask,save))
      money = 100
      risk = 0
      call numstr(money,money_str)
      call numstr(risk,risk_str)
      call ec(smg$create_virtual_display(24,80,disp))
      call ec(smg$create_pasteboard(paste))
      call ec(smg$create_virtual_keyboard(keyb))
      call ec(smg$set_broadcast_trapping(paste))
      call ec(smg$begin_display_update(disp))
      call ec(smg$draw_rectangle(disp,6,5,8,14))
      call ec(smg$draw_rectangle(disp,6,35,8,44))
      call ec(smg$draw_rectangle(disp,6,65,8,74))
      call ec(smg$end_display_update(disp))
      call ec(smg$paste_virtual_display(disp,paste,1,1))
      call ec(smg$put_chars_highwide(disp,'SINISTER ISLAND',2,25))
      call ec(smg$put_chars_highwide(disp,'CASH: $'//money_str,11,5))
      call ec(smg$put_chars_highwide(disp,'RISK: $'//risk_str,13,5))

  5   call ec(smg$set_cursor_abs(disp,18,5))
      status = smg$read_string(keyb,answer,'How much money do you '//
     +  'wish to risk? ',,,,,length,,disp)
      if (status.eq.smg$_eof) goto 90
      call ec(status)
      read(answer(1:length),'(f16.0)',iostat=status) risk
      call ec(smg$erase_display(disp,13,2,22,78))
      if ((risk.lt.0).or.(risk.gt.money)) goto 5
      if (status.eq.0) then
        call numstr(risk,risk_str)
        call ec(smg$put_chars_highwide(disp,'RISK: $'//risk_str,13,5))
      else
        goto 5
      endif

      call time(now)
      seed = now(2)/2 + 1
      if (.not.seed) seed = seed + 1
      do i = 1,210
        do j = 1,3
 10       value = mth$random(seed) * 25.0
          number = value
          if ((number.lt.1).or.(number.gt.21)) goto 10
          if ((i.le.30).and.(j.eq.1)) then
            call ec(smg$put_chars(disp,item(number),7,6))
            slot(1) = number
          endif
          if ((i.le.81).and.(j.eq.2)) then
            call ec(smg$put_chars(disp,item(number),7,36))
            slot(2) = number
          endif
          if ((i.le.150).and.(j.eq.3)) then
            call ec(smg$put_chars(disp,item(number),7,66))
            slot(3) = number
          endif
        enddo
      enddo

      winner = 0
      do i = 1,3
        if (slot(i).eq.1) kind(i) = 1
      enddo
      do i = 1,3
        if ((slot(i).ge.2).and.(slot(i).le.3)) kind(i) = 2
      enddo
      do i = 1,3
        if ((slot(i).ge.4).and.(slot(i).le.6)) kind(i) = 3
      enddo
      do i = 1,3
        if ((slot(i).ge.7).and.(slot(i).le.10)) kind(i) = 4
      enddo
      do i = 1,3
        if ((slot(i).ge.11).and.(slot(i).le.15)) kind(i) = 5
      enddo
      do i = 1,3
        if ((slot(i).ge.16).and.(slot(i).le.21)) kind(i) = 6
      enddo

      if ((kind(1).eq.kind(2)).and.(kind(1).eq.kind(3)))
     +  winner = kind(1)
      if ((kind(1).eq.kind(2)).and.(kind(3).eq.6))
     +  winner = kind(1) + 6
      if ((kind(2).eq.kind(3)).and.(kind(3).eq.6))
     +  winner = kind(1) + 11

      if (winner.ne.0) then
        call ec(smg$ring_bell(disp,3))
        money = money + risk*odds(winner)
        if (money.gt.1e10) goto 80
        call ec(smg$put_chars_highwide(disp,'YOU WON!!',21,30))
      else
        money = money - risk
        call ec(smg$put_chars_highwide(disp,'YOU LOST!',21,30))
        if (money.eq.0) then
          call ec(lib$wait(5.0))
          goto 90
        endif
      endif

      risk = 0
      call numstr(money,money_str)
      call numstr(risk,risk_str)
      call ec(smg$put_chars_highwide(disp,'CASH: $'//money_str,11,5))
      call ec(smg$put_chars_highwide(disp,'RISK: $'//risk_str,13,5))
      goto 5

 80   risk = 0
      call numstr(money,money_str)
      call numstr(risk,risk_str)
      call ec(smg$put_chars_highwide(disp,'CASH: $'//money_str,11,5))
      call ec(smg$put_chars_highwide(disp,'RISK: $'//risk_str,13,5))
      call ec(smg$put_chars_highwide(disp,'YOU BROKE THE BANK!',
     +  21,20))
      call ec(smg$put_chars_highwide(disp,'ARRRRGGGGHHHHHHHHH!',
     +  23,20))
      call ec(lib$wait(5.0))

 90   call ec(smg$disable_broadcast_trapping(paste))
      call ec(smg$delete_pasteboard(paste))
      call ec(smg$delete_virtual_keyboard(keyb))
      call ec(smg$delete_virtual_display(disp))
      call ec(lib$enable_ctrl(save))
      end


      subroutine numstr (number,string)
      character *(*) string
      real *16 number
      write(string,'(f16.2)') number
      end


      subroutine ec (status)
      integer *4 status
      if (.not.status) call lib$signal(%val(status))
      end

********************************************************************************
*                                                                              *
*   Program:  SINISTER_ISLAND                                                  *
*   Author:   William W. Brennessel                                            *
*   BITNET:   MASMUMMY@UBVMS                                                   *
*   Internet: masmummy@ubvms.cc.buffalo.edu                                    *
*                                                                              *
*   This program was created for personal use, and may be copied and altered   *
*   under the condition that the author is not responsible for any problems    *
*   that may occur.  Comments and criticisms are always welcome.               *
*                                                                              *
********************************************************************************
