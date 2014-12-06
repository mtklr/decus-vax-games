	! ------------------- display.e ----------------------------
	
	external long ast_refresh
        external long ast_broadcast
	external long function smg$erase_pasteboard(long by ref)
	external long function smg$repaint_line(long by ref, long by ref, &
		long by ref)
        external long function smg$create_pasteboard(LONG by ref, &
                STRING by desc, LONG by ref, LONG by ref, LONG by ref)
        external long function smg$create_virtual_display(LONG by ref, &
                LONG by ref, LONG by ref, LONG by ref, LONG by ref, &
                LONG by ref)
        external long function smg$paste_virtual_display(LONG by ref, &
                LONG by ref, LONG by ref, LONG by ref)
        external long function smg$put_line(LONG by ref, STRING by desc, &
                LONG by ref, LONG by ref, LONG by ref, LONG by ref, &
                LONG by ref, LONG by ref)
        external long function smg$return_cursor_pos(LONG,LONG,LONG)
        external long function smg$erase_display(LONG, LONG, LONG, LONG, LONG)
        external long function smg$unpaste_virtual_display(LONG, LONG)
        external long function smg$repaste_virtual_display(LONG,LONG,LONG,LONG)
        external long function smg$repaint_screen(LONG by ref)
        external long function smg$set_display_scroll_region(LONG, LONG, LONG)
        external long function smg$delete_pasteboard (LONG by ref, LONG by ref)
        external long constant smg$m_border, smg$m_reverse, smg$m_bold, &
                smg$m_blink
        external long function smg$label_border(LONG,STRING by desc, LONG, &
                LONG, LONG, LONG)
        external long function smg$put_line(LONG,STRING by desc, LONG, LONG, &
                LONG, LONG, LONG, LONG)
        external long function smg$put_with_scroll(LONG,STRING by desc,LONG)
        external long function smg$set_cursor_abs(LONG,LONG,LONG)
        external long function smg$set_cursor_rel(LONG,LONG,LONG)
        external long function smg$set_display_scroll_region(LONG,LONG,LONG)
        external long function smg$put_chars(LONG,STRING by desc,LONG,LONG, &
        	LONG,LONG,LONG,LONG)
        external long function smg$ring_bell(LONG,LONG)

	! ast functions
	external long function smg$enable_unsolicited_input(LONG,LONG,LONG)
	external long function smg$set_broadcast_trapping(long by ref, &
		long by ref, long by value)
        external long function smg$set_out_of_band_asts(long by ref, &
		long by ref, long by ref, long by value)
	external long function smg$get_broadcast_message(long by ref, &
		string by desc, word by ref, word by ref)

        ! virtual keyboard stuff
        external long function smg$create_virtual_keyboard(LONG)
        external long function smg$delete_virtual_keyboard(LONG)
        external long function smg$read_string(LONG,STRING by desc,STRING &
        	by desc,LONG,LONG,LONG,STRING by desc,LONG,LONG,LONG)
        external long function smg$read_keystroke(LONG by ref,long by ref, &
		string by desc, long by ref, long by ref, long by ref, &
		long by ref)
     
        ! constants
        external long constant smg$m_blink,smg$m_bold,smg$m_reverse
