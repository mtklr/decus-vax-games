[inherit('sys$library:starlet','srinit'),environment ('srsys')]

module srsys(input,output);

type
  $UQUAD = [QUAD,UNSAFE] RECORD
    L0,L1:UNSIGNED; END;

[ASYNCHRONOUS] FUNCTION lib$enable_ctrl (
	enable_mask : UNSIGNED;
	VAR old_mask : [VOLATILE] UNSIGNED := %IMMED 0) : INTEGER; EXTERNAL;

[ASYNCHRONOUS] FUNCTION lib$stat_timer (
	code : INTEGER;
	%REF value_argument : [VOLATILE,UNSAFE] ARRAY [$l2..$u2:INTEGER] OF $UBYTE;
	handle_address : $DEFPTR := %IMMED 0) : INTEGER; EXTERNAL;

[ASYNCHRONOUS] FUNCTION lib$cvtf_from_internal_time (
	operation : UNSIGNED;
	VAR resultant_time : [VOLATILE] SINGLE;
	input_time : $UQUAD) : INTEGER; EXTERNAL;

[ASYNCHRONOUS] FUNCTION lib$wait (
	seconds : SINGLE) : INTEGER; EXTERNAL;

[ASYNCHRONOUS] FUNCTION lib$getjpi (
	item_code : INTEGER;
	VAR process_id : [VOLATILE] UNSIGNED := %IMMED 0;
	process_name : [CLASS_S] PACKED ARRAY [$l3..$u3:INTEGER] OF CHAR := %IMMED 0;
	%REF resultant_value : [VOLATILE,UNSAFE] ARRAY [$l4..$u4:INTEGER] OF $UBYTE := %IMMED 0;
	VAR resultant_string : [CLASS_S,VOLATILE] PACKED ARRAY [$l5..$u5:INTEGER] OF CHAR := %IMMED 0;
	VAR resultant_length : [VOLATILE] $UWORD := %IMMED 0) : INTEGER; EXTERNAL;

[ASYNCHRONOUS] FUNCTION lib$init_timer (
	VAR context : [VOLATILE] UNSIGNED := %IMMED 0) : INTEGER; EXTERNAL;

[ASYNCHRONOUS] FUNCTION lib$disable_ctrl (
	disable_mask : UNSIGNED;
	VAR old_mask : [VOLATILE] UNSIGNED := %IMMED 0) : INTEGER; EXTERNAL;

[ASYNCHRONOUS] FUNCTION lib$enable_ctrl (
	enable_mask : UNSIGNED;
	VAR old_mask : [VOLATILE] UNSIGNED := %IMMED 0) : INTEGER; EXTERNAL;

[ASYNCHRONOUS] FUNCTION lib$get_symbol (
	symbol : [CLASS_S] PACKED ARRAY [$l1..$u1:INTEGER] OF CHAR;
	VAR resultant_string : [CLASS_S,VOLATILE] PACKED ARRAY [$l2..$u2:INTEGER] OF CHAR;
	VAR resultant_length : [VOLATILE] $UWORD := %IMMED 0;
	VAR table_type_indicator : [VOLATILE] INTEGER := %IMMED 0) : INTEGER; EXTERNAL;

[ASYNCHRONOUS] FUNCTION lib$set_symbol (
	symbol : [CLASS_S] PACKED ARRAY [$l1..$u1:INTEGER] OF CHAR;
	value_string : [CLASS_S] PACKED ARRAY [$l2..$u2:INTEGER] OF CHAR;
	table_type_indicator : INTEGER := %IMMED 0) : INTEGER; EXTERNAL;

[ASYNCHRONOUS] FUNCTION lib$find_file (
	filespec : [CLASS_S] PACKED ARRAY [$l1..$u1:INTEGER] OF CHAR;
	VAR resultant_filespec : [CLASS_S,VOLATILE] PACKED ARRAY [$l2..$u2:INTEGER] OF CHAR;
	VAR context : [VOLATILE] UNSIGNED;
	default_filespec : [CLASS_S] PACKED ARRAY [$l4..$u4:INTEGER] OF CHAR := %IMMED 0;
	related_filespec : [CLASS_S] PACKED ARRAY [$l5..$u5:INTEGER] OF CHAR := %IMMED 0;
	VAR status_value : [VOLATILE] UNSIGNED := %IMMED 0;
	flags : UNSIGNED := %IMMED 0) : INTEGER; EXTERNAL;

[ASYNCHRONOUS] FUNCTION smg$set_cursor_abs (
	display_id : UNSIGNED;
	start_row : INTEGER := %IMMED 0;
	start_column : INTEGER := %IMMED 0) : INTEGER; EXTERNAL;

[ASYNCHRONOUS] FUNCTION smg$scroll_display_area (
	display_id : UNSIGNED;
	start_row : INTEGER := %IMMED 0;
	start_column : INTEGER := %IMMED 0;
	height : INTEGER := %IMMED 0;
	width : INTEGER := %IMMED 0;
	direction : UNSIGNED := %IMMED 0;
	count : INTEGER := %IMMED 0) : INTEGER; EXTERNAL;

[ASYNCHRONOUS] FUNCTION smg$put_line (
	display_id : UNSIGNED;
	text : [CLASS_S] PACKED ARRAY [$l2..$u2:INTEGER] OF CHAR;
	line_advance : INTEGER := %IMMED 0;
	rendition_set : UNSIGNED := %IMMED 0;
	rendition_complement : UNSIGNED := %IMMED 0;
	flags : UNSIGNED := %IMMED 0;
	character_set : UNSIGNED := %IMMED 0;
	direction : UNSIGNED := %IMMED 0) : INTEGER; EXTERNAL;
 
[ASYNCHRONOUS] FUNCTION smg$read_keystroke (
	keyboard_id : UNSIGNED;
	VAR word_terminator_code : [VOLATILE] $UWORD;
	prompt_string : [CLASS_S] PACKED ARRAY [$l3..$u3:INTEGER] OF CHAR := %IMMED 0;
	timeout : INTEGER := %IMMED 0;
	display_id : UNSIGNED := %IMMED 0;
	rendition_set : UNSIGNED := %IMMED 0;
	rendition_complement : UNSIGNED := %IMMED 0) : INTEGER; EXTERNAL;

[ASYNCHRONOUS] FUNCTION smg$delete_chars (
	display_id : UNSIGNED;
	number_of_characters : INTEGER;
	start_row : INTEGER;
	start_column : INTEGER) : INTEGER; EXTERNAL;

[ASYNCHRONOUS] FUNCTION smg$erase_line (
	display_id : UNSIGNED;
	start_row : INTEGER := %IMMED 0;
	start_column : INTEGER := %IMMED 0) : INTEGER; EXTERNAL;

[ASYNCHRONOUS] FUNCTION smg$ring_bell (
	display_id : UNSIGNED;
	number_of_times : INTEGER := %IMMED 0) : INTEGER; EXTERNAL;

[ASYNCHRONOUS] FUNCTION smg$create_virtual_keyboard (
	VAR keyboard_id : [VOLATILE] UNSIGNED;
	input_device : [CLASS_S] PACKED ARRAY [$l2..$u2:INTEGER] OF CHAR := %IMMED 0;
	default_filespec : [CLASS_S] PACKED ARRAY [$l3..$u3:INTEGER] OF CHAR := %IMMED 0;
	VAR resultant_filespec : [CLASS_S,VOLATILE] PACKED ARRAY [$l4..$u4:INTEGER] OF CHAR := %IMMED 0;
	recall_size : $UBYTE := %IMMED 0) : INTEGER; EXTERNAL;

[ASYNCHRONOUS] FUNCTION smg$set_keypad_mode (
	keyboard_id : UNSIGNED;
	flags : UNSIGNED) : INTEGER; EXTERNAL;

[ASYNCHRONOUS] FUNCTION smg$create_pasteboard (
	VAR pasteboard_id : [VOLATILE] UNSIGNED;
	output_device : [CLASS_S] PACKED ARRAY [$l2..$u2:INTEGER] OF CHAR := %IMMED 0;
	VAR number_of_pasteboard_rows : [VOLATILE] INTEGER := %IMMED 0;
	VAR number_of_pasteboard_columns : [VOLATILE] INTEGER := %IMMED 0;
	flags : UNSIGNED := %IMMED 0;
	VAR type_of_terminal : [VOLATILE] UNSIGNED := %IMMED 0) : INTEGER; EXTERNAL;

[ASYNCHRONOUS] FUNCTION smg$create_virtual_display (
	number_of_rows : INTEGER;
	number_of_columns : INTEGER;
	VAR display_id : [VOLATILE] UNSIGNED;
	display_attributes : UNSIGNED := %IMMED 0;
	video_attributes : UNSIGNED := %IMMED 0;
	character_set : UNSIGNED := %IMMED 0) : INTEGER; EXTERNAL;

[ASYNCHRONOUS] FUNCTION smg$label_border (
	display_id : UNSIGNED;
	text : [CLASS_S] PACKED ARRAY [$l2..$u2:INTEGER] OF CHAR := %IMMED 0;
	position_code : UNSIGNED := %IMMED 0;
	units : INTEGER := %IMMED 0;
	rendition_set : UNSIGNED := %IMMED 0;
	rendition_complement : UNSIGNED := %IMMED 0;
	character_set : UNSIGNED := %IMMED 0) : INTEGER; EXTERNAL;

[ASYNCHRONOUS] FUNCTION smg$set_cursor_mode (
	pasteboard_id : UNSIGNED;
	flags : UNSIGNED) : INTEGER; EXTERNAL;

[ASYNCHRONOUS] FUNCTION smg$create_viewport (
	display_id : UNSIGNED;
	viewport_row_start : INTEGER;
	viewport_column_start : INTEGER;
	viewport_number_rows : INTEGER;
	viewport_number_columns : INTEGER) : INTEGER; EXTERNAL;

[ASYNCHRONOUS] FUNCTION smg$paste_virtual_display (
	display_id : UNSIGNED;
	pasteboard_id : UNSIGNED;
	pasteboard_row : INTEGER;
	pasteboard_column : INTEGER;
	top_display_id : UNSIGNED := %IMMED 0) : INTEGER; EXTERNAL;

[ASYNCHRONOUS] FUNCTION smg$delete_virtual_keyboard (
	keyboard_id : UNSIGNED) : INTEGER; EXTERNAL;

[ASYNCHRONOUS] FUNCTION smg$delete_pasteboard (
	pasteboard_id : UNSIGNED;
	flags : UNSIGNED := %IMMED 0) : INTEGER; EXTERNAL;
 
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

[ASYNCHRONOUS] FUNCTION smg$repaint_screen (
	pasteboard_id : UNSIGNED) : INTEGER; EXTERNAL;

[asynchronous]
procedure wl(s:$udata := ''; echo:boolean := true);
forward;

[asynchronous]
procedure read_mailbox;
forward;

function tpu$edit(%stdescr in_filename:strung; %stdescr out_filename:strung):unsigned;
external;

[asynchronous]
function unmask(the_mask,looking_for:integer):boolean;
begin
  if uand(the_mask,looking_for) = looking_for then unmask := true
  else unmask := false;
end;

[asynchronous]
function compress(a,b,c:integer := 0):integer;
{Compresses two signed integers +/-[0..999] or three positive integers [0..999]}
var
  count,signs:integer := 0;
  temp:integer;

  procedure safe(var i:integer);
  begin
    if i < 0 then
    begin
      signs := signs + 2**count;
      i := -i;
    end;
    if i > 999 then i := 999;
    count := count + 1;
  end;

begin
  safe(a);
  safe(b);
  safe(c);
  temp := a * 1000000 + b * 1000 + c;
  if c = 0 then temp := temp + 1000000000 + signs;
  compress := temp;
end;

[asynchronous]
procedure decompress(n:integer; var a,b,c:integer);
var
  signs,count:integer := 0;
  signed:boolean := false;
    
begin
  if n >= 1000000000 then
  begin
    n := n - 1000000000;
    signed := true;
  end;
  a := n div 1000000;
  b := n mod 1000000 div 1000;
  c := n mod 1000;

  if signed then
  begin
    if c > 1 then
    begin
      c := c - 2;
      b := -b;
    end;
    if c > 0 then a := -a;
  end;
end;

[asynchronous]
function int(i:integer):string;
var
  s:string;
begin
  writev(s,i:0);
  int := s;
end;

[asynchronous]
function boo(zok:boolean):char;
begin
  if zok then boo := '+'
  else boo := '-';
end;

[asynchronous]
procedure bug_out(s:$udata);
begin
  if debug then
  begin
    if human then wl('H> '+s)
    else writeln(outfile,'M> '+s);
  end;
end;

[asynchronous]
function syscheck(s:$udata; fatal:boolean := false):boolean;
begin
  if sysstatus <> 1 then
  begin
    writev(qpqp,'Error ',sysstatus:0,' in ');
    bug_out(qpqp+s);
    if fatal then
    begin
      if not human then close(outfile);
      halt;
    end;
  end;
  syscheck := (sysstatus = 1);
end;

[hidden,external,asynchronous]
procedure ping(lognum:integer);
external;

[hidden,external]
function getkey(key_mode:integer := 0):char;
external;

[hidden,external,asynchronous]
procedure handle_act;
external;

procedure disable_cursor;
begin
  writeln(chr(27),'[?25l');
end;

procedure enable_cursor;
begin
  writeln(chr(27),'[?25h');
end;

[asynchronous]
procedure disable_c;
forward;

[asynchronous]
procedure disable_y;
forward;

[asynchronous,unbound]
procedure handle_c(channel:integer);
begin
  sysstatus := $cancel(channel);
  wl('Whop!');
  disable_c;
end;

[asynchronous,unbound]
procedure handle_y(channel:integer);
begin
  sysstatus := $cancel(channel);
  if privlevel >= 10 then
  begin
    wl('One more time...');
    sysstatus := lib$enable_ctrl(save_dcl_ctrl);
  end
  else
  begin
    wl('Sorry, only privd people may ctrl-y out.');
    disable_y;
  end;
end;

procedure disable_y;
begin
  sysstatus := $qiow(
		chan := tt_chan,
		func := io$_setmode + io$m_ctrlyast,
		iosb := io_status,
		p1 := %immed handle_y,
		p2 := %ref tt_chan);
end;

procedure disable_c;
begin
  sysstatus := $qiow(
		chan := tt_chan,
		func := io$_setmode + io$m_ctrlcast,
		iosb := io_status,
		p1 := %immed handle_c,
		p2 := %ref tt_chan);
end;

[asynchronous]
function getticks:integer;
var
  timevalue:[unsafe, volatile] timetype;
  secs:real;
begin
  lib$stat_timer(1,timevalue,timercontext);
  lib$cvtf_from_internal_time(lib$k_delta_seconds_f,secs,timevalue);
  getticks:= trunc (10*secs);
end;

[external,asynchronous]
function mth$random(var seed:[volatile] integer):real;
external;

[asynchronous]
function random:real;
begin
  random := mth$random(seed);
end;

[asynchronous]
function rnd:integer;
begin
  rnd := round(mth$random(seed)*10000000);
end;

[asynchronous]
function rnum(num:integer):integer;
begin
  if num = 0 then rnum := 0
  else
  begin
    if num < 0 then rnum := - (1 + rnd mod abs(num))
    else rnum := 1 + rnd mod num;
  end;
end;

[asynchronous]
function bell(num:integer; cycles:integer := 3):integer;
var
  i,sum:integer := 0;
begin
  if cycles = 0 then cycles := 1;
  if cycles > 50 then
  begin
    bug_out('Too many bell cycles');
    cycles := 50;
  end;
  for i := 1 to cycles do
  sum := sum + rnum(num);
  bell := sum div cycles;
end;

[asynchronous]
function rnd100:integer;       { random int between 0 & 100, maybe }
begin
  rnd100 := round(mth$random(seed)*100);
end;

function rdice(dice,num_dice:integer):integer;
var
  i,sum:integer := 0;
begin
  if num_dice <> 0 then
  for i := 1 to num_dice do
  sum := sum + rnd mod dice;
  rdice := sum;
end;

[asynchronous]
procedure wait(seconds:real);
begin
  sysstatus := lib$wait(seconds);
end;

procedure get_node(var node:lpack; var len:$uword);
var
  list :array [1..2] of item_list_3;
begin
  list[1].buf_len := length(node);
  list[1].it_code := syi$_nodename;
  list[1].buf_adr := iaddress(node);
  list[1].len_adr := iaddress(len);
  list[2] := zero;
  sysstatus := $getsyi(,,,list,,,);
end;
      
function netpriv:boolean;
var
  str:string;
begin
  netpriv := false;
  sysstatus := lib$getjpi(jpi$_curpriv,,,,%descr str);
  if (index(str,'NETMBX')<>0) then netpriv := true;
end;

procedure get_logical(logical:mpack; var dev:[volatile] mpack);
var
  str	:string;
  func	:$uword;
  list  :array[1..2] of item_list_3;
  len   :unsigned;
begin
  list[1].buf_len := length(dev);
  list[1].it_code := lnm$_string;
  list[1].buf_adr := iaddress(dev);
  list[1].len_adr := iaddress(len);
  list[2] := zero;
  func := lnm$m_case_blind;
  sysstatus := $trnlnm(func,'LNM$JOB',logical,,list);
end;

[asynchronous]
procedure act_out(send,act,x,y,p1,p2,p3,p4:integer := 0;
		  msg,note:$udata := '';
		  allrooms:boolean := false;
		  def_channel:$uword := 0);
var
  i:integer;
  func: $uword;
  buf_len: integer;
  mbx_data,debug_data:$udata;
begin
  writev(mbx_data,send:0,' ',act:0,' ',x:0,' ',y:0,' ',p1:0,' ',p2:0,' ',
	p3:0,' ',p4:0,' ',msg,chr(0),note,chr(1));
  func := io$_writevblk + io$m_norswait + io$m_now;
  buf_len := length(mbx_data) + 2;
  if (def_channel <> 0) then
  begin
    writev(debug_data,length(mbx_data):3,'O> [',def_channel:0,'] ',mbx_data);
    bug_out(debug_data);
    sysstatus := $qiow(,def_channel,func,,,,%ref mbx_data,
		%immed(buf_len),,,,);
    if (sysstatus <> 1) then
    begin
      writev(qpqp,'Act out error ',sysstatus:0,' ',mbx_data);
      bug_out(qpqp);
    end;
  end
  else
  begin
    if not human then sysstatus := $qiow(,mychannel,func,,,,%ref mbx_data,
    %immed(buf_len),,,,);

    for i := 1 to maxplayers do
    if (person[i].here or allrooms) and
     (indx[i_ingame].on[i]) and 
     (not indx[i_npc].on[i]) then
    begin
      writev(debug_data,'O> [',i:0,'] ',mbx_data);
      bug_out(debug_data);
      sysstatus := $qiow(,person[i].channel,func,,,,
      %ref mbx_data,%immed(buf_len),,,,);
      if (sysstatus <> 1) then
      begin
        writev(debug_data,'Act out error ',sysstatus:0,' ',mbx_data);
        bug_out(debug_data);
        ping(i);
      end;
    end;
  end;
end;

[asynchronous]
procedure set_mbx_ast;
var
  io_status:iosb_type;
begin
  sysstatus := $qiow(
		chan := mychannel,
		func := io$_setmode + io$m_wrtattn,
		iosb := io_status,
		p1 := %immed read_mailbox);
  syscheck('set_mbx_ast');
end;

procedure read_mailbox;
var
  mbx_data,textline,debug_data:$udata;
  io_status:iosb_type;
  point,point1:integer;
begin
  sysstatus := $qiow(chan := mychannel,
		func := io$_readvblk + {io$m_norswait + }io$m_now,
		iosb := io_status,
		p1 := %ref mbx_data,
		p2 := size(mbx_data));
  if length(mbx_data) > 0 then
  begin
    writev(debug_data,length(mbx_data):3,'I> '+mbx_data);
    bug_out(debug_data);
    with act do
    readv(mbx_data,sender,action,xloc,yloc,parm1,parm2,parm3,parm4,textline);
    point := index(textline,chr(0));
    point1:= index(textline,chr(1));
    act.msg := substr(textline,2,point-2);
    act.note := substr(textline,point+1,point1-point-1);
    handle_act;
  end;
  set_mbx_ast;
end;

function create_mymbx(logical:mpack):boolean;
var
  node:lpack;
  len :$uword;
begin
  create_mymbx := true;
  sysstatus := $crembx(,mychannel,,4000,,,logical);
  syscheck('create_mymbx',true);
  get_logical(logical,mymbx);
  get_node(node,len);
  if (substr(node,1,len)<>game_node) then
  begin
    writeln('You must be on node '+game_node+' to run this program.');
    create_mymbx := false;
  end;
end;

[asynchronous]
function assign_channel(dev:mpack; var channel:[volatile] $uword):boolean;
begin
  sysstatus := $assign(dev,channel,,);
  assign_channel := (sysstatus = 1);
  syscheck('Assign channel to '+dev);
end;

[asynchronous]
procedure deassign_channel(channel:$uword);
begin
  sysstatus := $dassgn(channel);
  bug_out('Deassigned channel...');
  syscheck('Deassign channel');
end;

function get_userid:string;
var
  uname:ident;
begin
  sysstatus := lib$getjpi(jpi$_username,,,,uname);
  get_userid := uname;
end;

[asynchronous]
procedure add_acl(f_name:string; aclstr:$udata);
var
  aclent:string;
  list  :array [1..2] of item_list_3;
  objtyp:$uword;
  con	:unsigned;
begin
  sysstatus := $parse_acl(aclstr,%descr aclent,,);
  list[1].buf_len := size(aclent);
  list[1].it_code := acl$c_addaclent;
  list[1].buf_adr := iaddress(aclent);
  list[1].len_adr := 0;
  list[2] := zero;
  objtyp := acl$c_file;
  con := 0;
  sysstatus := $change_acl(,objtyp,f_name,list,,,con);
end;

[asynchronous]
procedure setprompt;
begin
  smg$set_cursor_abs(twind,22,pos+1);
end;

[asynchronous]
procedure scroll_screen;
begin
  smg$scroll_display_area(twind,1,1,21,78,smg$m_up);
end;

[asynchronous]
procedure wr(s:string := ''; echo:boolean := true);
begin
  if echo and human then
  begin
    if wpos = 1 then scroll_screen;
    smg$set_cursor_abs(twind,21,wpos);
    smg$put_chars(twind,s);
    wpos := wpos + length(s);
  end;
end;

procedure wl{(s:$udata := ''; echo:boolean := true)};
var
  row:integer := 21;
begin
  if echo and human then
  begin
    if length(s) > 78 then
    begin
      scroll_screen;
      row :=20;
    end;
    if wpos = 1 then scroll_screen;
    smg$set_cursor_abs(twind,row,wpos);
    smg$put_line(twind,s,,,,smg$m_wrap_word);
    setprompt;
    wpos := 1;
  end
  else if debug and (not human) then bug_out(s);
end;

function isnum(s:string):boolean;
var
  i,temp:integer;
  good:boolean;
begin
  isnum := true;
  if length(s) < 1 then isnum := false
  else
  begin
    i := 1;
    good := true;
    while (i<= length(s)) and good do
    if not (s[i] in ['0'..'9','+','-']) then good := false
    else i := i + 1;
    readv(s,temp,error := continue);
    isnum := good and (statusv = 0);
  end;
end;

function number(s:string):integer;
var
  i:integer;
begin
  if (length(s) < 1) or not(s[1] in ['0'..'9','-','+']) then number := 0
  else
  begin
    readv(s,i, error := continue);
    number := i;
  end;
end;

function keyget:$uword;
var
  key:$uword := 0;
  i:integer;
begin
  sysstatus := smg$read_keystroke(keyboard,key,,1);
  if sysstatus = 0 then keyget:= 0
  else keyget := key;
end;

[asynchronous]
function new_prompt(prompt:string):string;
begin
  if prompt <> '' then
  begin
    if prompt[length(prompt)] in ['A'..'Z','a'..'z'] then
    prompt := prompt + '? ';
    if prompt[length(prompt)] in ['0'..'9','?','>','!',':'] then
    prompt := prompt + ' ';
  end;
  if prompt <> old_prompt then
  begin
    old_prompt := prompt;
    smg$put_chars(twind,prompt,22,1,smg$m_erase_to_eol);
  end;
  new_prompt := prompt;
end;

function grab_key(prompt:string := ''; keymode:integer := 0):char;
begin
  prompt := new_prompt(prompt);
  grab_key := getkey(keymode);
end;
                          
procedure grab_line(prompt:string := '';
		    var s:string;
		    keymode:integer := 0;
		    echo:boolean := true);
var
  ch:char;
  i:integer;
begin
  prompt := new_prompt(prompt);
  line := '';
  pos := length(prompt);
  ch := getkey(keymode);
  while (ch <> chr(13)) and (ch <> chr(26)) do
  begin
    if (ch = chr(8)) or (ch = chr(127)) then
    begin { del char }
      case length(line) of
	0:ch := getkey(keymode);
	1:begin
	    line := '';
	    if echo then smg$delete_chars(twind,1,22,pos);
	    pos := pos - 1;
	    ch := getkey(keymode);
	  end;
	otherwise
	  begin
	    if echo then smg$delete_chars(twind,1,22,pos);
	    line := substr(line,1,length(line)-1);
	    pos := pos - 1;
	    ch := getkey(keymode);
	  end;
      end;
    end
    else if ch = chr(21) then
    begin
      if echo then smg$erase_line(twind,22,length(prompt)+1);
      line := '';
      pos := length(prompt);
      ch := getkey(keymode);
    end
    else if length(line) + length(prompt) > 78 then
    begin
      smg$ring_bell(twind);
      ch := getkey(keymode);
    end
    else if ((ord(ch) > 31) and (ord(ch) < 127)) then
    begin {no ctrls}
      line := line + ch;
      pos := pos + 1;
      if echo then smg$put_chars(twind,ch);
      ch := getkey(keymode);
    end
    else ch := getkey(keymode);
  end;
  if ch = chr(26) then s := chr(26)
  else s := line;
  if echo then smg$erase_line(twind,22,length(prompt)+1);
end;

procedure grab_short(prompt:string := '';
		    var s:string;
		    keymode:integer := 0);
begin
  grab_line(prompt,s,keymode);
  if length(s) > 20 then
  begin
    wl('String too long.  Truncated.');
    s := substr(s,1,20);
  end;
end;

function lowcase(s:string):string;
var
  sprime:string;
  i:integer;
begin
  if length(s) = 0 then lowcase := ''
  else
  begin
    sprime := s;
    for i := 1 to length(s) do
    if sprime[i] in ['A'..'Z'] then
    sprime[i] := chr(ord('a')+(ord(sprime[i])-ord('A')));
    lowcase := sprime;
  end;
end;

procedure grab_num(prompt:string; var n:integer;
		   min:integer := -maxint div 2;
		   max:integer := maxint div 2;
		   default:integer := 0);
var
  s:string;
begin
  grab_line(prompt,s);
  if isnum(s) then
  begin
    n := number(s);
    if privlevel <= 10 then
    if (n < min) or (n > max) then n := default;
  end
  else n := default;    
end;

[asynchronous]
function grab_yes(prompt:string):boolean;
var
  key:$uword := 0;
  i:integer;
begin
  grab_yes := false;
  sysstatus := 0;
  prompt := new_prompt(prompt);
  while sysstatus <> 1 do
    sysstatus := smg$read_keystroke(keyboard,key,,10);
  if chr(key) in ['Y','y','T','t','+','1'] then grab_yes := true;
end;

procedure setup_display;
var
  io_status:iosb_type;
  border:unsigned;
  rows,cols:integer;
  mask:unsigned;
begin
  now := 1;
  seed := clock;
  disable_cursor;
  smg$create_virtual_keyboard(keyboard);
  smg$set_keypad_mode(keyboard,1);
  smg$create_pasteboard(pasteboard);
  smg$create_virtual_display(15,29,xwind,smg$m_border);
  smg$create_virtual_display(64,132,gwind,smg$m_border);
  smg$label_border(xwind,game_name);
  smg$create_virtual_display(22,78,twind,smg$m_border);
  smg$set_cursor_mode(pasteboard,smg$m_cursor_off);
  smg$create_viewport(gwind,1,1,15,48);
  smg$begin_pasteboard_update(pasteboard);
  smg$paste_virtual_display(gwind,pasteboard,2,2);
  smg$paste_virtual_display(twind,pasteboard,2,2);
  smg$paste_virtual_display(xwind,pasteboard,2,51);
  smg$end_pasteboard_update(pasteboard);
  sysstatus := $assign(devnam := 'sys$command', chan := tt_chan);
  disable_c;
  disable_y;
  lib$init_timer(timercontext);
  mask := lib$m_cli_ctrly + lib$m_cli_ctrlt;
  sysstatus := lib$disable_ctrl(mask,save_dcl_ctrl);
end;

procedure remove_display;
begin
  sysstatus := lib$enable_ctrl(save_dcl_ctrl);
  smg$delete_virtual_keyboard(keyboard);
  smg$delete_pasteboard(pasteboard);
  enable_cursor;
end;

[asynchronous]
function frozen:boolean;
begin
  frozen := (getticks < plr[now].awake);
end;

[asynchronous]
procedure freeze(secs:real);
begin
  if (secs > 0) then
  if plr[now].awake < getticks then plr[now].awake := trunc(getticks + secs* 10)
  else plr[now].awake := plr[now].awake + trunc(secs * 10);
end;

function edit(file_name,definition:string := ''):boolean;
var
  dummy:string;
  con:unsigned := 0;
  old_symbol,s:string;
  editor:tinystring := 'edit/tpu';
begin
  enable_cursor;
  edit := false;
  if definition <> '' then wl('Editing the '+definition+' description.');
  grab_line('Would you prefer EDT or TPU ',s);
  if length(s) > 0 then
  if s[1] in ['e','E'] then editor := 'edit/edt';
  sysstatus := lib$get_symbol(%descr 'edit',%descr old_symbol);
  sysstatus := lib$set_symbol('edit','edit'+editor);
  sysstatus := tpu$edit(%stdescr helproot+file_name,%stdescr helproot+file_name);
  con := 0;
  sysstatus := lib$find_file(helproot+file_name,%descr dummy,con);
  if sysstatus = rms$_suc then
  begin
    edit := true;
    add_acl(helproot+file_name,'(identifier=[mas$user7],access=read+write)');
    add_acl(helproot+file_name,'(identifier=[v130kbnj],access=read+write)');
    add_acl(helproot+file_name,'(identifier=[v119matc],access=read+write)');
  end;
  sysstatus := lib$set_symbol(%descr 'edit',%descr old_symbol);
  smg$repaint_screen(pasteboard);
  disable_cursor;
end;

end.
