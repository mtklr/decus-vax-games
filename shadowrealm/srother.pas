[inherit ('srinit','srsys','srio'),environment('srother')]

module srother;

[ASYNCHRONOUS] FUNCTION smg$repaste_virtual_display (
	display_id : UNSIGNED;
	pasteboard_id : UNSIGNED;
	pasteboard_row : INTEGER;
	pasteboard_column : INTEGER;
	top_display_id : UNSIGNED := %IMMED 0) : INTEGER; EXTERNAL;
 
[ASYNCHRONOUS] FUNCTION smg$end_pasteboard_update (
	pasteboard_id : UNSIGNED) : INTEGER; EXTERNAL;
 
[ASYNCHRONOUS] FUNCTION smg$begin_pasteboard_update (
	pasteboard_id : UNSIGNED) : INTEGER; EXTERNAL;

[ASYNCHRONOUS] FUNCTION smg$put_chars (
	display_id : UNSIGNED;
	text : [CLASS_S] PACKED ARRAY [$l2..$u2:INTEGER] OF CHAR;
	start_row : INTEGER := %IMMED 0;
	start_column : INTEGER := %IMMED 0;
	flags : UNSIGNED := %IMMED 0;
	rendition_set : UNSIGNED := %IMMED 0;
	rendition_complement : UNSIGNED := %IMMED 0;
	character_set : UNSIGNED := %IMMED 0) : INTEGER; EXTERNAL;

[ASYNCHRONOUS] FUNCTION smg$erase_display (
	display_id : UNSIGNED;
	start_row : INTEGER := %IMMED 0;
	start_column : INTEGER := %IMMED 0;
	end_row : INTEGER := %IMMED 0;
	end_column : INTEGER := %IMMED 0) : INTEGER; EXTERNAL;

[ASYNCHRONOUS] FUNCTION smg$label_border (
	display_id : UNSIGNED;
	text : [CLASS_S] PACKED ARRAY [$l2..$u2:INTEGER] OF CHAR := %IMMED 0;
	position_code : UNSIGNED := %IMMED 0;
	units : INTEGER := %IMMED 0;
	rendition_set : UNSIGNED := %IMMED 0;
	rendition_complement : UNSIGNED := %IMMED 0;
	character_set : UNSIGNED := %IMMED 0) : INTEGER; EXTERNAL;
 
procedure toggle_full_text(on:boolean; g_wind:boolean := true);
begin
  full_text := on;
  smg$begin_pasteboard_update(pasteboard);
  if full_text then
  smg$repaste_virtual_display(twind,pasteboard,2,2)
  else
  begin
    if g_wind then smg$repaste_virtual_display(gwind,pasteboard,2,2)
    else smg$repaste_virtual_display(ywind,pasteboard,2,2);
    smg$repaste_virtual_display(xwind,pasteboard,2,51);
  end;
  smg$end_pasteboard_update(pasteboard);
end;

procedure add_class(xname:shortstring; number,
  xa1,xa2,xa3,xa4,xa5,xa6,xa7,xa8,xa9,xa10,xa11,xa12,xa13,xa14,xa15,xa16,
  xa17,xa18,xa19,xa20,
  xpoints,xhealth,xmana,xwealth,
  xdelay_m,xsize,xheal_speed,
  xmana_speed,xnoise,xperception,xforce,xwind,xfire,xcold,xelectric,xmagic,
  xholy,xself,xweapon,xmissile:integer);
begin
  with class[number] do
  begin
    class_name[number] := xname;
    armor[1].chance	:= xa1;
    armor[1].magnitude	:= xa2;
    armor[2].chance	:= xa3;
    armor[2].magnitude	:= xa4;
    armor[3].chance	:= xa5;
    armor[3].magnitude	:= xa6;
    armor[4].chance	:= xa7;
    armor[4].magnitude	:= xa8;
    armor[5].chance	:= xa9;
    armor[5].magnitude	:= xa10;
    armor[6].chance	:= xa11;
    armor[6].magnitude	:= xa12;
    armor[7].chance	:= xa13;
    armor[7].magnitude	:= xa14;
    armor[8].chance	:= xa15;
    armor[8].magnitude	:= xa16;
    armor[9].chance	:= xa17;
    armor[9].magnitude	:= xa18;
    armor[10].chance	:= xa19;
    armor[10].magnitude	:= xa20;
    attrib[at_points]	:= xpoints;
    attrib[at_health]	:= xhealth;
    attrib[at_mana]	:= xmana;
    attrib[at_wealth]	:= xwealth;
    attrib[at_mv_delay]	:= xdelay_m;
    attrib[at_size]	:= xsize;
    attrib[at_heal_speed]:= xheal_speed;
    attrib[at_mana_speed]:= xmana_speed;
    attrib[at_noise]	:= xnoise;
    attrib[at_perception]:= xperception;
    proficiency[el_force]:= xforce;
    proficiency[el_wind] := xwind;
    proficiency[el_fire]:= xfire;
    proficiency[el_cold]:= xcold;
    proficiency[el_electric]:=xelectric;
    proficiency[el_magic]:= xmagic;
    proficiency[el_holy] := xholy;
    proficiency[el_self] := xself;
    proficiency[el_weapon] := xweapon;
    proficiency[el_missile] := xmissile;
  end;             
end;

[asynchronous]
function obj_effect(effectnum:integer):integer;
var
  i:integer := 1;
  found:boolean := false;
begin
  obj_effect := 0;
  while (i <= maxparm) and not found do
  if obj.parm[i] = effectnum then
  begin
    found := true;
    obj_effect := obj.mag[i];
  end
  else i := i + 1;
end;

[asynchronous]
procedure free_space(var x,y:integer);
var
  i,tries:integer := 1;
  ok:boolean;
begin
  repeat
    ok := true;
    tries := tries + 1;
    x := rnum(here.size.x);
    y := rnum(here.size.y);
    for i := 1 to fg_layers do if fg.map[x,y,i] <> 0 then ok := false;
  until (tries > 1000) or ok;
  if not ok then
  begin
    x := 0;
    y := 1;
    while (x < here.size.x) and (not ok) do
    begin
      x := x + 1;
      while (y < here.size.y) and (not ok) do
      for i := 1 to fg_layers do if fg.map[x,y,i] = 0 then ok := true
      else y := y + 1;
    end;
  end;
end;

[asynchronous]
function write_nice(s:string; l:integer):string;
var
  i:integer;
  srt:string;
begin
  if l >= length(s) + 1 then
  for i := length(s) + 1 to l do s := s +(' ');
  write_nice := s;
end;

[asynchronous]
function adverb:string;
begin
  case rnum(10) of
1:adverb := 'terrific';
2:adverb := 'spectacular';
3:adverb := 'graceful';
4:adverb := 'clumsly';
5:adverb := 'awesome';
6:adverb := 'cunning';
7:adverb := 'elegant';
8:adverb := 'truly gifted';
9:adverb := 'most impressive';
10:adverb := 'godlike';
  end;
end;

[asynchronous]
function checkprivs(level:integer := 0; echo:boolean := false):boolean;
begin
  if privlevel >= level then checkprivs := true
  else
  begin
    checkprivs := false;
    if echo then
    begin
      writev(qpqp,'That operation requires level ',level:0,' privs.');
      wl(qpqp);
    end;
  end;
end;

[asynchronous]
procedure draw_x(line_num:integer := 0);
var
  i,y_coord,d_first,d_last:integer;
  ok:boolean := false;
begin
  if line_num = 0 then
  begin
    ok := true;
    d_first := x_start;
    d_last := x_end;
  end
  else if line_num in [x_start..x_end] then
  begin
    ok := true;
    d_first := line_num;
    d_last := line_num;
  end;
  if ok then
  for i := d_first to d_last do
  begin
    y_coord := 1 + i - x_start;
    smg$put_chars(xwind,x_window[i],y_coord,1);
  end;
end;

[asynchronous]
procedure purge_x;
var
  i:integer;
begin
  smg$erase_display(xwind,1,1,15,29);
  for i := 1 to x_max do x_window[i] := '';
  x_start := 1;
  x_last := 0;
  x_end := 0;
end;

[asynchronous]
procedure set_xsize(var s:string);
begin
  if length(s) > 29 then s := substr(s,1,29)
  else s := write_nice(s,29);
end;

[asynchronous]
procedure change_x(old_s,new_s:string; draw:boolean := true);
var
  i:integer := 1;
  done:boolean := false;
begin
  set_xsize(old_s);
  set_xsize(new_s);
  while (not done) and (i <= x_last) do
  if x_window[i] = old_s then
  begin
    x_window[i] := new_s;
    done := true;
  end
  else i := i + 1;
  draw_x(i);
end;

[asynchronous]
procedure add_x(s:string; draw:boolean := false);
begin
  set_xsize(s);
  if x_last < x_max then
  begin
    x_last := x_last + 1;
    x_window[x_last] := s;
    if x_last - x_start < x_length then x_end := x_last;
  end;
  if draw then draw_x;
end;

[asynchronous]
procedure x_check;
begin
  if x_end > x_last then x_end := x_last;
end;

[asynchronous,global]
procedure remove_x(s:string; draw:boolean := false);
var
  i,j:integer;
begin
  for i := 1 to x_last do
  if x_window[i] = s then
  begin
    for j := i to x_last do
    x_window[j] := x_window[j+1];
    x_last := x_last - 1;
    x_check;
    if (x_end = x_last) and ((x_end - x_start) < 14) then
    smg$put_chars(xwind,write_nice('',27),2 + x_end - x_start,1);
  end;
  if draw then draw_x;
end;

procedure x_up;
begin
  x_start := x_start - x_length;
  if x_start < 1 then x_start := 1;
  x_end := x_start + x_length -1;
  x_check;
  draw_x;
end;

procedure x_down;
begin
  x_end := x_end + x_length;
  x_check;
  x_start := 1 + x_end - x_length;
  if x_start < 1 then x_start := 1;
  draw_x;
end;

[asynchronous]
procedure change_stat(statnum,change_to:integer; max_stat:boolean := false);
var
  old_s,new_s:string;
begin
  if window_name = name[na_player].id[plr[now].log] then
  begin
    writev(old_s,write_nice(attrib_name[statnum],16),':',
	pl[now].attrib[statnum]:0,'/',pl[now].attrib_max[statnum]:0);
    if max_stat then writev(new_s,write_nice(attrib_name[statnum],16),':',
	pl[now].attrib[statnum]:0,'/',change_to:0)
    else writev(new_s,write_nice(attrib_name[statnum],16),':',
	change_to:0,'/',pl[now].attrib_max[statnum]:0);
    change_x(old_s,new_s);
  end;
  if max_stat then pl[now].attrib_max[statnum] := change_to
  else pl[now].attrib[statnum] := change_to;
end;

[asynchronous]
procedure change_stat_ex(statnum,change_to:integer);
var
  old_s,new_s:string;
begin
  if pl[now].attrib_ex[statnum] <> change_to then
  begin
    if window_name = name[na_player].id[plr[now].log] then
    begin
      writev(old_s,write_nice(attrib_ex_name[statnum],16),':',
	pl[now].attrib_ex[statnum]:0);
      writev(new_s,write_nice(attrib_ex_name[statnum],16),':',
	change_to:0);
      change_x(old_s,new_s);
    end;
    pl[now].attrib_ex[statnum] := change_to;
  end;
end;

[asynchronous]
procedure x_label(s:string);
begin
  window_name := s;
  smg$label_border(xwind,window_name);
end;

procedure x_write_array(an_array:[unsafe] array[first..last:whole] of shortstring;
			add_numbers:boolean := false; new_name:string := '';
			count:integer := 0; indexnum:integer := 0);
var
  i:integer;
  s:string;
begin
  if (new_name <> window_name) or (new_name = '') then
  begin
    x_label(new_name);
    purge_x;
    for i := first to last do
    begin
      if an_array[i] <> '' then
      begin
        s := '';
	if add_numbers then writev(s,count:2,') ');
	if indexnum <> 0 then s := s + boo(indx[indexnum].on[i+1]) + ' ';
	s := s + an_array[i];
	add_x(s);
      end;
      count := count + 1;
    end;
    draw_x;
  end;
end;

function lookup(an_array:[unsafe] array [first..last:counting] of shortstring;
		looking_for:string; var result:integer; echo:boolean := false)
		:boolean;
var
  i,poss,maybe,num:integer := 0;
  s:string;
begin
  result := 0;
  if looking_for = '' then result := 0
  else if isnum(looking_for) then result := number(looking_for)
  else
  begin
    looking_for := lowcase(looking_for);
    for i := first to last do
    begin
      an_array[i] := lowcase(an_array[i]);
      if looking_for = an_array[i] then num := i
      else if index(an_array[i],looking_for) = 1 then
      begin
	maybe := maybe + 1;
	poss := i;
      end;
    end;
    if num <> 0 then result := num
    else if maybe = 1 then result := poss
    else if maybe > 1 then result := 0
    else result := 0;
  end;
  lookup := result <> 0;
  if echo then
  if checkprivs(4) then
  begin
    if grab_yes('Show lookup_array') then
	x_write_array(an_array,true,'Lookup array',1);
  end
  else wl('No such luck.')
end;

function exact_name(nametype:integer; var n:integer; s:string):boolean;
begin
  exact_name := false;
  if lookup(name[nametype].id,s,n) then
  if lowcase(name[nametype].id[n]) = lowcase(s) then exact_name := true
end;

function get_name(an_array:[unsafe] array [first..last:counting] of shortstring;
		prompt:string := 'Enter name:'; var result:integer;
		def,indexnum:integer := 0; count:integer := 1):boolean;
var
  g:string;
begin
  get_name := true;
  if def <> 0 then wl('Enter * for default');
  grab_line(prompt,g);
  if (g = '?') or (g = '') then
  begin
    window_name := '';
    x_write_array(an_array,true,'Enter a name',count,indexnum);
    grab_line(prompt,g);
  end;
  if g = '*' then result := def
  else if not lookup(an_array,g,result) then get_name := false;
  if result > last then result := last;
end;

procedure do_list(kind:integer := 0);

  procedure list_prime;
  begin
    case kind of
    1..na_max	:x_write_array(name[kind].id,true,names[kind],1);
    na_foreground:x_write_array(fg.name,true,names[kind],1);
    na_fg_type	:x_write_array(fg_type,true,names[kind],0);
    na_weapon	:x_write_array(stat,true,names[kind],0);
    na_attribute:x_write_array(attrib_name,true,names[kind],1);
    na_spell_ef	:x_write_array(spell_effects,true,names[kind],0);
    na_elements	:x_write_array(element,true,names[kind],0);
    na_equipment:x_write_array(equipment,true,names[kind],1);
    na_classes	:x_write_array(class_name,true,names[kind],1);
    end;
  end;

begin
  if kind <> 0 then list_prime
  else if get_name(names,,kind) then list_prime;
end;

function valid_name(nametype:integer; s:string):boolean;
var
  dummy:integer;
begin
  valid_name := false;
  if (s = '') then wl('Name too short.')
  else if length(s) > 20 then wl('The name must be less than 21 characters.')
  else if exact_name(nametype,dummy,s) then wl(s+' is not a unique name.')
  else valid_name := true;
end;

[asynchronous]
function show_condition(condition:integer):string;
begin
  case condition of
  -maxint..0:show_condition := 'Useless';
   1..10:show_condition := 'Nearly useless';
  11..20:show_condition := 'Terrible';
  21..30:show_condition := 'Bad';
  31..40:show_condition := 'Poor';
  41..60:show_condition := 'Fair';
  61..70:show_condition := 'Good';
  71..80:show_condition := 'Very Good';
  81..90:show_condition := 'Excellent';
  91..100:show_condition := 'Exceptional';
  101..125:show_condition := 'Truly magnificent';
  126..150:show_condition := 'Hoopy';
  151..200:show_condition := 'Tremendous';
  201..1000:show_condition := 'Ludicrous';
  1001..maxint:show_condition := 'Godlike';
  end;
end;

[asynchronous]
function a_an(name_type:integer):string;
begin
  case name_type of
    1:a_an := 'a';
    2:a_an := 'an';
    3:a_an := 'some';
    4:a_an := 'the';
    otherwise a_an := '';
  end;
end;

[asynchronous]
function object_name(objnum:integer):string;
begin
  read_object(objnum);
  object_name := a_an(obj.howprint)+' '+name[na_obj].id[objnum];
end;

[asynchronous]
procedure print(file_name:string := '';
		default_string:string := '';
		subs1:shortstring := '';
		icon1:char := '#';
		subs2:shortstring := '';
		icon2:char := '#');
var
  textfile:text;
  aline,str,q,p:string;
  icon:char;
  count:integer := 0;
  more:boolean;
  error:boolean := false;

  function subs_parm(s,parm:string; icon:char):string;

    function left_half(s:string):string;
    var
      i:integer;
    begin
      i := index(s,icon);
      if i > 0 then left_half := substr(s,1,i-1)
      else left_half := '';
    end;

    function right_half(s:string):string;
    var
      i:integer;
    begin
      i := index(s,icon);
      if i > 0 then right_half := substr(s,i+1,length(s)-i)
      else right_half := s;
    end;

  begin
    if (length(s) + length(parm) <= 80) and (index(s,icon) > 0) then
    subs_parm := left_half(s) + parm + right_half(s)
    else subs_parm := s;
  end;

begin
  if human then
  begin
    if file_name = '' then
    begin
      p := subs_parm(default_string,subs1,icon1);
      q := subs_parm(p,subs2,icon2);
      if q <> '' then wl(q);
    end
    else
    begin
      open(textfile,helproot+file_name,history := old,sharing := readonly,
	error := continue);
      reset(textfile);
      repeat
	count := count + 1;
	readln(textfile,aline);
	p := subs_parm(aline,subs1,icon1);
	q := subs_parm(p,subs2,icon2);
	wl(q);
        if full_text then more := (count = 20)
        else more := (count = 6);
        if more then
	begin
	  count := 0;
	  grab_yes('[More]');
	end;
      until eof (textfile);
      close(textfile);
    end;
  end;
end;

end.
