        sub display (INTEGER dmode, STRING dtext)
        ! ---------------------------------------------------------
        !                  Subroutine Display
        !            Written by: Stephan Meier  10/87
        ! ---------------------------------------------------------
        !
        !     dmode is an integer specifying the display operation
        !     dtext is a string containing text to be displayed
        !
        ! ---------------------- Externals ------------------------
        %include "common.h"
   	%include "display.e"

	! ---------------------- Variables ------------------------
        declare long keycode,text_len, prompt_len
	declare integer constant char_mask = 262144
        ! ---------------------------------------------------------
        !                  Perform requested operation
        ! ---------------------------------------------------------
        select dmode
          case 1
            !   get input + return in dtext
            rs=smg$erase_display(io_id,,,,)
            rs=smg$set_cursor_abs(io_id,1,1)
            rs=smg$put_line(io_id,dtext,,,,,,)
	    prompt_len = len(dtext) + 1
	    text_len = prompt_len
	    dtext=""
            rs=smg$set_cursor_abs(io_id,1,text_len)
	    rs=smg$read_keystroke(keyboard_id,keycode,,,io_id,,)
	    while (keycode<>13 and text_len<40)
	      call handle_key(keycode,dtext,text_len,prompt_len)
	      rs=smg$read_keystroke(keyboard_id,keycode,,,io_id,,)
	    next
            dtext=edit$(dtext,152%)    ! remove excess spaces, tab
	    if pending_error = 1 then
	      rs=smg$erase_display(error_id,,,,)
	      pending_error = 0
	    end if
            scroll_ok=0
          case 2
            ! set up smg environment
	    pending_error = 0
            rs=smg$create_pasteboard(new_pid,,,,)
            rs=smg$create_virtual_keyboard(keyboard_id)
            rs=smg$create_virtual_display(11,58,scanner_id, &
                smg$m_border,smg$m_reverse,)
	    rs=smg$erase_pasteboard(new_pid)
            rs=smg$label_border(scanner_id,"Scanner Display",,, &
                smg$m_bold, smg$m_reverse)
            rs=smg$create_virtual_display(11,19,control_id, &
                smg$m_border,,)
            rs=smg$put_line(control_id,"CONDTION:",,,,,,)
            rs=smg$put_line(control_id,"LANDING COMP:",,,,,,)
            rs=smg$put_line(control_id,"DAMAGE REPORT:",,,,,,)
            rs=smg$put_line(control_id,"",,,,,,)
            rs=smg$put_line(control_id,"",,,,,,)
            rs=smg$put_line(control_id,"PLANET:",,,,,,)
            rs=smg$put_line(control_id,"RING:",,,,,,)
            rs=smg$put_line(control_id,"RAY:",,,,,,)
	    rs=smg$put_line(control_id,"CLOAK:",,,,,,)
	    rs=smg$put_line(control_id,"LSJ:",,,,,,)
	    rs=smg$put_line(control_id,"ECM:",,,,,,)
            rs=smg$label_border(control_id,"Control",,, &
                smg$m_bold,)
            rs=smg$create_virtual_display(1,80,status_id,,smg$m_reverse,)
            rs=smg$create_virtual_display(14,78,trade_id, &
                smg$m_border,,)
            rs=smg$create_virtual_display(14,32,planet_id,smg$m_border,,)
            rs=smg$label_border(planet_id,"Planet Info",,,smg$m_bold,)
            rs=smg$create_virtual_display(5,80,text_id,,,)
            rs=smg$create_virtual_display(8,80,manual_id,,,)
            rs=smg$create_virtual_display(21,80,big_id,,,)
            rs=smg$create_virtual_display(2,80,io_id,,,)
            rs=smg$create_virtual_display(1,40,error_id,,,)
	    rs=smg$set_out_of_band_asts(new_pid by ref,char_mask by ref, &
		ast_refresh,0)
	    rs=smg$set_broadcast_trapping(new_pid, ast_broadcast,0)
          case 3
            !   display status line
            k=6-len(str$(dpos))
            l=4-len(str$(denergy))
            m=4-len(str$(ddir))
            n=7-len(str$(dcredits))
            p=5-len(str$(dfuel))
            q=5-len(str$(dmissiles))
            b$="        "
            if k>0 then c$=left$(b$,k) else c$="" end if
            if l>0 then d$=left$(b$,l) else d$="" end if
            if m>0 then e$=left$(b$,m) else e$="" end if
            if n>0 then f$=left$(b$,n) else f$="" end if
            a$="Pos: "+str$(dpos)+ c$+" Dir: "+str$(ddir)+e$+ &
                " Energy: "+str$(denergy)+d$+" Missiles: "+str$(dmissiles)+ &
                space$(q)+" Fuel: "+str$(dfuel)+space$(p)+"  Credits: "+ &
                str$(dcredits)+f$
            rs=smg$set_cursor_abs(status_id,1,1)
            rs=smg$put_line(status_id,a$,,,,,,)
	    if cloak = 1 then a$="ON" else a$= "OFF" end if
            rs=smg$set_cursor_abs(control_id,9,12)
            rs=smg$put_line(control_id,a$,,,,,,)
	    if lsj = 1 then a$="ON" else a$="OFF" end if
            rs=smg$set_cursor_abs(control_id,10,12)
            rs=smg$put_line(control_id,a$,,,,,,)
	    if ecm = 1 then a$="ON" else a$="OFF" end if
            rs=smg$set_cursor_abs(control_id,11,12)
            rs=smg$put_line(control_id,a$,,,,,,)
          case 4
            !   erase trading window and set cursor to home
            rs=smg$erase_display(trade_id,,,,)
          case 5
            !   clear menu window
            rs=smg$erase_display(menu_id,,,,)
          case 6
            !   print menu line
            rs=smg$put_line(menu_id,dtext,,,,,,)
          case 7
            !   erase big window and set cursor to home
            rs=smg$erase_display(big_id,,,,)
          case 8
            !   print line in big window
            rs=smg$put_line(big_id,dtext,,,,,,)
          case 9
            !   clear input window
            rs=smg$erase_display(io_id,,,,)
          case 10
            !  bring up scanner + control
            scanner_displayed=1
            rs=smg$begin_pasteboard_update(new_pid)
            rs=smg$erase_display(scanner_id,,,,)
            rs=smg$paste_virtual_display(scanner_id,new_pid,3,2)
            rs=smg$paste_virtual_display(control_id,new_pid,3,61)
            rs=smg$paste_virtual_display(manual_id,new_pid,15,1)
            rs=smg$unpaste_virtual_display(trade_id,new_pid)
            rs=smg$end_pasteboard_update(new_pid)
          case 11
            ! print line to scanner
            rs= smg$put_line(scanner_id,dtext,,,,,,)
          case 12
    	    ! remove scanner and control displays
            rs=smg$begin_pasteboard_update(new_pid)
            rs=smg$paste_virtual_display(trade_id,new_pid,3,2)
            rs=smg$unpaste_virtual_display(scanner_id,new_pid)
            rs=smg$unpaste_virtual_display(control_id,new_pid)
            rs=smg$unpaste_virtual_display(manual_id,new_pid)
            rs=smg$erase_display(trade_id,,,,)
            rs=smg$end_pasteboard_update(new_pid)
            scanner_displayed=0
          case 13
            ! clear scanner
            rs=smg$erase_display(scanner_id,,,,)
          case 14
            ! display damage report
            rs=smg$set_cursor_abs(control_id,4,1)
            if dtext="ENERGY FAILING" then
              rs=smg$put_line(control_id,dtext,,smg$m_blink,,,,)
            else if dtext="ENERGY LOW." then
                  rs=smg$put_line(control_id,dtext,,smg$m_reverse,,,,)
                 else
                  rs=smg$put_line(control_id,dtext,,,,,,)
                end if
            end if
          case 15
            ! display landing computer
            rs=smg$set_cursor_abs(control_id,2,15)
            rs=smg$put_line(control_id,dtext,,,,,,)
            rs=smg$set_cursor_abs(control_id,6,12)
            rs=smg$put_line(control_id,pname,,,,,,)
            rs=smg$set_cursor_abs(control_id,7,12)
            rs=smg$put_line(control_id,str$(ring),,,,,,)
            rs=smg$set_cursor_abs(control_id,8,12)
            rs=smg$put_line(control_id,str$(ray),,,,,,)
          case 16
            ! display condtion
            rs=smg$set_cursor_abs(control_id,1,15)
            if dtext="RED" then
                rs=smg$put_line(control_id,dtext,,smg$m_blink,,,,)
            else
                rs=smg$put_line(control_id,dtext,,,,,,)
            end if
          case 17
            ! Hit any key to continue
            rs=smg$set_cursor_abs(io_id,2,1)
            rs=smg$put_line(io_id,"--More--",,smg$m_reverse,,,,)
            rs=smg$read_keystroke(keyboard_id,keycode,,,,,)
            rs=smg$erase_display(io_id,,,,)
          case 18
            ! set up normal display
            rs=smg$paste_virtual_display(text_id,new_pid,18,1)
            rs=smg$paste_virtual_display(trade_id,new_pid,3,2)
            rs=smg$paste_virtual_display(status_id,new_pid,1,1)
          case 19
            ! set up big display
            rs=smg$paste_virtual_display(big_id,new_pid,2,1)
          case 20
            ! remove big display
            rs=smg$unpaste_virtual_display(big_id,new_pid)
          case 21
            ! clear text window
            rs=smg$erase_display(text_id,,,,)
            rs=smg$erase_display(manual_id,,,,)
          case 22
            ! set up io + error window
            rs=smg$paste_virtual_display(io_id,new_pid,23,1)
            rs=smg$paste_virtual_display(error_id,new_pid,23,40)
          case 23
            ! print a line in text window
            if scanner_displayed=0 then
              rs=smg$put_line(text_id,dtext,,,,,,)
            else
               if scroll_ok=7 then
                 scroll_ok=-1
                 rs=smg$set_cursor_abs(io_id,2,1)
                 rs=smg$put_line(io_id,"--More--"&
		     ,,smg$m_reverse,,,,)
                 rs=smg$read_keystroke(keyboard_id,keycode,,,,,)
                 rs=smg$erase_display(io_id,,,,)
                 rs=smg$erase_display(manual_id,,,,)
               end if
               scroll_ok=scroll_ok+1
               rs=smg$put_line(manual_id,dtext,,,,,,)
            end if
          case 24
            ! print a line in trade window
            rs=smg$put_line(trade_id,dtext,,,,,,)
          case 25
            ! print a line in io window
            rs=smg$put_line(io_id,dtext,,,,,,)
          case 26
            ! read a single key
            rs=smg$read_keystroke(keyboard_id,keycode,,,,,)
            dtext=chr$(keycode)
          case 27
            ! print text at specified position in trade window
            rs=smg$put_chars(trade_id,dtext,row_pos,col_pos,,,,)
          case 28
            ! display flashing title
            rs=smg$put_chars(big_id,dtext,5,28,,smg$m_bold,,)
          case 29
            ! bring up planet info window
            rs=smg$paste_virtual_display(planet_id,new_pid,3,48)
          case 30
            ! print info in planet display
            rs=smg$put_line(planet_id,dtext,,,,,,)
          case 31
            ! remove planet info window
            rs=smg$unpaste_virtual_display(planet_id,new_pid)
          case 32
            ! clear planet info window
            rs=smg$erase_display(planet_id,,,,)
          case 33
	    ! display a line in error window
	    rs=smg$ring_bell(error_id,1)	    
            rs=smg$put_line(error_id,dtext,,,,,,)
	    pending_error = 1
	  case 34
            !   get long input + return in dtext
	    rs=smg$repaste_virtual_display(io_id,new_pid,23,1)
            rs=smg$erase_display(io_id,,,,)
            rs=smg$set_cursor_abs(io_id,1,1)
            rs=smg$put_line(io_id,dtext,,,,,,)
	    prompt_len = len(dtext) + 1
	    text_len = prompt_len
	    dtext=""
            rs=smg$set_cursor_abs(io_id,1,text_len)
	    rs=smg$read_keystroke(keyboard_id,keycode,,,io_id,,)
	    while (keycode<>13 and text_len<80)
	      call handle_key(keycode,dtext,text_len,prompt_len)
	      rs=smg$read_keystroke(keyboard_id,keycode,,,io_id,,)
	    next
            dtext=edit$(dtext,152%)    ! remove excess spaces, tab
	    re=smg$repaste_virtual_display(error_id,new_pid,23,40)
            scroll_ok=0
        end select
     end sub

    ! routine to handle keystroke
    sub handle_key(long keycode, string text_buffer, long text_len, prompt_len)
    %include "common.h"
    %include "display.e"

    select keycode
      case 127
        if text_len > prompt_len then
	  text_len = text_len - 1
	  text_buffer = left$(text_buffer,(text_len-prompt_len))
	  rs = smg$put_chars(io_id," ",1,text_len,,,,)
	  rs = smg$put_chars(io_id,"",1,text_len,,,,)
        end if
      case else
	text_buffer = text_buffer + chr$(keycode)
        rs=smg$put_chars(io_id,chr$(keycode),1,text_len,,,,)
	text_len = text_len + 1
    end select
    end sub

    ! ast_refresh routine to asynchrounously refresh screen. 
    sub ast_refresh(long a,b,c,d,e by ref)

    %include "display.e"
    %include "common.h"
    declare integer rs

    rs = smg$repaint_screen(new_pid)
    rs = smg$repaint_line(new_pid,23,1)
    end sub

    ! display unsolicited input
    sub ast_broadcast(long a,b,c,d,e by ref)

    %include "display.e"
    %include "common.h"
    declare word m_len
    declare string m_text
    rs = smg$get_broadcast_message(new_pid, m_text, m_len,)
    rs = smg$set_cursor_abs(io_id,2,1)
    rs = smg$put_line(io_id,m_text,,,,,,)
    
    end sub
