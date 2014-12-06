[inherit ('srinit','srsys','srio','srother','sys$library:starlet'),
 environment('srmenu')]

module srmenu(input,output);

[ASYNCHRONOUS] FUNCTION lib$find_file (
	filespec : [CLASS_S] PACKED ARRAY [$l1..$u1:INTEGER] OF CHAR;
	VAR resultant_filespec : [CLASS_S,VOLATILE] PACKED ARRAY [$l2..$u2:INTEGER] OF CHAR;
	VAR context : [VOLATILE] UNSIGNED;
	default_filespec : [CLASS_S] PACKED ARRAY [$l4..$u4:INTEGER] OF CHAR := %IMMED 0;
	related_filespec : [CLASS_S] PACKED ARRAY [$l5..$u5:INTEGER] OF CHAR := %IMMED 0;
	VAR status_value : [VOLATILE] UNSIGNED := %IMMED 0;
	flags : UNSIGNED := %IMMED 0) : INTEGER; EXTERNAL;

[ASYNCHRONOUS] FUNCTION smg$put_chars (
	display_id : UNSIGNED;
	text : [CLASS_S] PACKED ARRAY [$l2..$u2:INTEGER] OF CHAR;
	start_row : INTEGER := %IMMED 0;
	start_column : INTEGER := %IMMED 0;
	flags : UNSIGNED := %IMMED 0;
	rendition_set : UNSIGNED := %IMMED 0;
	rendition_complement : UNSIGNED := %IMMED 0;
	character_set : UNSIGNED := %IMMED 0) : INTEGER; EXTERNAL;

[ASYNCHRONOUS] FUNCTION smg$begin_pasteboard_update (
	pasteboard_id : UNSIGNED) : INTEGER; EXTERNAL;

[ASYNCHRONOUS] FUNCTION smg$create_virtual_display (
	number_of_rows : INTEGER;
	number_of_columns : INTEGER;
	VAR display_id : [VOLATILE] UNSIGNED;
	display_attributes : UNSIGNED := %IMMED 0;
	video_attributes : UNSIGNED := %IMMED 0;
	character_set : UNSIGNED := %IMMED 0) : INTEGER; EXTERNAL;

[ASYNCHRONOUS] FUNCTION smg$paste_virtual_display (
	display_id : UNSIGNED;
	pasteboard_id : UNSIGNED;
	pasteboard_row : INTEGER;
	pasteboard_column : INTEGER;
	top_display_id : UNSIGNED := %IMMED 0) : INTEGER; EXTERNAL;

[ASYNCHRONOUS] FUNCTION smg$end_pasteboard_update (
	pasteboard_id : UNSIGNED) : INTEGER; EXTERNAL;

[ASYNCHRONOUS] FUNCTION smg$delete_virtual_display (
	display_id : UNSIGNED) : INTEGER; EXTERNAL;

[ASYNCHRONOUS] FUNCTION smg$repaste_virtual_display (
	display_id : UNSIGNED;
	pasteboard_id : UNSIGNED;
	pasteboard_row : INTEGER;
	pasteboard_column : INTEGER;
	top_display_id : UNSIGNED := %IMMED 0) : INTEGER; EXTERNAL;

procedure do_menu(help_file:string := '');
const
  m_length = 14;
var
  i,m_first,m_last:integer;
  done:boolean := false;
  sel,dum_dum:integer;
  context:unsigned := 0;
  s:string;

  procedure menu_help;
  var
    s:string;
  begin
    wl;
    wl('Q   - Quits            U - Scroll up          D - Scroll down');
    wl('t - toggle screen      v - view helpfile');
    wl('h/? - This menu        L - List various names/etc');
    writev(s,'Choose a number between 1 and ',mc:0,'.');
    wl(s);
  end;

  procedure draw_menu(line_num:integer := 0);
  var
    i:integer;
    s1,s2,s3:string;
    d_first,d_last:integer;
  begin
    if line_num = 0 then
    begin
      d_first := m_first;
      d_last := m_last;
    end
    else
    begin
      d_first := line_num;
      d_last := line_num;
    end;
    for i := d_first to d_last do
    begin
      writev(s1,i:2,') ',write_nice(a_menu[i].choice,24));
      case a_menu[i].kind of
        k_int	:writev(s2,a_menu[i].int_result:0);
        k_str,
        k_sst,
	k_ico	:s2 := a_menu[i].str_result;
	k_sta	:s2 := stat[a_menu[i].int_result];
        k_boo	:if a_menu[i].boo_result then s2 := 'True'
		else s2 := 'False';
	k_use,
	k_pla,
	k_roo,
	k_rac,
	k_spe,
	k_obj	:if a_menu[i].int_result = 0 then s2 := 'Unknown'
		 else s2 := name[a_menu[i].kind].id[a_menu[i].int_result];
	k_dsc	:s2 := a_menu[i].str_result;
      end;
      if length(s2) > 24 then s2 := substr(s2,1,24) + '+';
      writev(s3,s1,write_nice(s2,24));
      smg$put_chars(ywind,s3,1+i-m_first,1);
    end;
  end;

  procedure menu_check;
  begin
    if m_last > mc then m_last := mc;
  end;

  procedure menu_up;
  begin
    m_first := m_first - m_length;
    if m_first < 1 then m_first := 1;
    m_last := m_first + m_length;
    menu_check;
    draw_menu;
  end;

  procedure menu_down;
  begin
    m_last := m_last + m_length;
    menu_check;
    m_first := m_last - m_length;
    if m_first < 1 then m_first := 1;
    draw_menu;
  end;

begin
  mc := mc - 1;
  m_first := 1;
  m_last := m_length + 1;
  smg$begin_pasteboard_update(pasteboard);
  smg$create_virtual_display(15,48,ywind,1);
  smg$paste_virtual_display(ywind,pasteboard,2,2);
  menu_check;
  draw_menu;
  smg$end_pasteboard_update(pasteboard);
  repeat
    repeat
      grab_line('Menu ',s);
      s := lowcase(s);
    until length(s) > 0;
    case s[1] of
      'q':done := true;
      'l':do_list;
      'u':menu_up;
      'd':menu_down;
      't':toggle_full_text(not full_text,false);
      'v':if help_file <> '' then
	  begin
	    wl('Opening '+help_file+'.');
	    typefile(helproot+help_file);
	    wl('Closing '+help_file+'.');
	  end
	  else wl('There is no help file for this menu.');
  'h','?':menu_help;
      otherwise if isnum(s) then
      begin
	sel := number(s);
	if sel in [1..mc] then
	begin
	  if a_menu[sel].help_menu <> 0 then do_list(a_menu[sel].help_menu);
	  case a_menu[sel].kind of
      k_int:grab_num(a_menu[sel].prompt,a_menu[sel].int_result,
	a_menu[sel].min_int,a_menu[sel].max_int,a_menu[sel].def_int);
      k_dsc:{if a_menu[sel].str_result = '' then}
	    begin
	      grab_line('[Filename] '+a_menu[sel].prompt,s);
	      if s = '' then s := a_menu[sel].str_result;
	      sysstatus := lib$find_file(root+s,%descr dum_dum,context);
	      if sysstatus = rms$_suc then
	      wl('File by that name already exists!')
	      else if edit(s,a_menu[sel].prompt) then
	      a_menu[sel].str_result := s;
	    end;
{	    else if not edit(a_menu[sel].str_result,a_menu[sel].prompt) then
		a_menu[sel].str_result := '';}
      k_sst:grab_short(a_menu[sel].prompt,a_menu[sel].str_result);
      k_ico:begin
	      grab_line(a_menu[sel].prompt,s);
	      if length(s) > 0 then a_menu[sel].str_result := s[1]
	      else a_menu[sel].str_result := '?';
	    end;
      k_sta:begin
	      grab_line(a_menu[sel].prompt,s);
	      lookup(attrib_name,s,a_menu[sel].int_result);
	    end;
      k_str:begin
	      wl('Currently reads :');
	      wl(a_menu[sel].str_result);
	      wl(a_menu[sel].prompt);
	      grab_line('',a_menu[sel].str_result);
	    end;
      k_boo:a_menu[sel].boo_result := not a_menu[sel].boo_result;
				     {grab_yes(a_menu[sel].prompt);}
      k_pla:get_name(name[na_player].id,a_menu[sel].prompt,a_menu[sel].int_result,
		a_menu[sel].def_int);
      k_obj:get_name(name[na_obj].id,a_menu[sel].prompt,a_menu[sel].int_result,
		a_menu[sel].def_int);
      k_roo:get_name(name[na_room].id,a_menu[sel].prompt,a_menu[sel].int_result,
		a_menu[sel].def_int);
      k_rac:get_name(name[na_race].id,a_menu[sel].prompt,a_menu[sel].int_result,
		a_menu[sel].def_int);
      k_spe:get_name(name[na_spell].id,a_menu[sel].prompt,a_menu[sel].int_result,
		a_menu[sel].def_int);
      k_use:get_name(name[na_user].id,a_menu[sel].prompt,a_menu[sel].int_result,
		a_menu[sel].def_int);
	  end;
	  draw_menu(sel);
	end
      end
      else wl('That is not a valid menu option.');
    end;
  until done;

  smg$begin_pasteboard_update(pasteboard);
  smg$delete_virtual_display(ywind);
  smg$repaste_virtual_display(gwind,pasteboard,2,2);
  smg$end_pasteboard_update(pasteboard);
  mc := 1;
end;

procedure set_menu(  in_choice:shortstring;
		     in_prompt:string := '';
		     in_kind:integer := k_int;
		     in_int_result:integer := 0;
		     in_str_result:string := '';
		     in_boo_result:boolean := false;
		     in_min_int:integer := 0;
		     in_max_int:integer := maxint div 2;
		     in_def_int:integer := 0;
		     in_help_menu:integer := 0);
begin
  with a_menu[mc] do
  begin
    choice	:= in_choice;
    if in_prompt = '' then prompt := in_choice
    else prompt	:= in_prompt;
    kind	:= in_kind;
    max_int	:= in_max_int;
    min_int	:= in_min_int;
    def_int	:= in_min_int;
    str_result	:= in_str_result;
    int_result	:= in_int_result;
    boo_result	:= in_boo_result;
    help_menu	:= in_help_menu;
  end;
  mc := mc + 1;
end;

procedure get_menu_int(var i:integer);
begin
  i := a_menu[mc].int_result;
  mc := mc + 1;
end;

procedure get_menu_str(var s:string);
begin
  s := a_menu[mc].str_result;
  mc := mc + 1;
end;

procedure get_menu_sst(var s:shortstring);
begin
  s := a_menu[mc].str_result;
  mc := mc + 1;
end;

procedure get_menu_ico(var s:char);
begin
  s := a_menu[mc].str_result[1];
  mc := mc + 1;
end;

procedure get_menu_boo(var b:boolean);
begin
  b := a_menu[mc].boo_result;
  mc := mc + 1;
end;

end.
