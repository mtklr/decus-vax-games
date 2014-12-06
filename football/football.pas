[inherit('sys$library:starlet','sys$library:pascal$lib_routines',
         'sys$library:pascal$smg_routines','sys$library:pascal$mth_routines',
         'sys$library:pascal$str_routines')]

program maslib_football (input,output);

%include 'football.inc'
%include 'rms.inc'

procedure finitiate; forward;

function cv (line: integer): integer;
var
  tmp : integer;
begin
  tmp := round(line*6.0/10.0+9.0);
  if (tmp < 1) then
    cv := 1
  else
    cv := tmp;
end;

function trim (instr: string; var outstr: vartwe): integer;
begin
  writev(outstr,instr);
  for k := 1 to 20 do begin
    if (lib$ichar(substr(outstr,k,1)) <> 32) then trim := k;
  end;
end;

procedure ctrim (var instr: fifstr; var slen : $uword);
var
  outstr : fifstr;
begin
  str$trim(outstr,instr,slen);
  instr := outstr;
end;

function slead(s : varstr): varstr;
var i : $uword; done : boolean := false;
begin
  i := 0;
  while not done do begin
    i := i + 1;
    if i > s.length then done := true
    else done := ( (s[i] <> ' ') and (s[i] <> chr(9)) );
  end;
  if i > s.length then slead := ''
  else slead := substr(s, i, s.length - i + 1);
end;

procedure convert (num: integer; var str: varstr; var slen: integer);
begin
  writev(str,num);
  str := slead(str);
  slen := str.length;
end;

procedure arrow;
begin
  if (dir) then
    smg$put_chars_wide(disp[1],'====>',6,36,smg$m_bold)
  else
    smg$put_chars_wide(disp[1],'<====',6,36,smg$m_bold);
end;

procedure turnover;
begin
  mestart := not(mestart);
  arrow;
  lib$wait(2.0);
end;

procedure statistic (line: fifstr; pos : integer);
var
  statstr : varstr := ' ';
begin
  convert(stat,statstr,xlen);
  if (xlen = 1) then statstr := ' '+statstr;
  smg$put_chars(disp[1],'                   ',pos,36);
  smg$put_chars(disp[1],line+statstr,pos,36);
end;

procedure showdown;
var
  dwnstr : varstr;
begin
  if (down < 5) then begin
    convert(down,dwnstr,xlen);
    smg$put_chars(disp[1],'DOWN:           '+dwnstr,1,36);
  end else
    smg$put_chars(disp[1],'DOWN:           1',1,36);
end;

procedure comment (line: fifstr);
begin
  smg$put_chars_wide(disp[1],line,6,50,smg$m_bold);
end;

procedure message (line: istring);
begin
  smg$create_virtual_display(5,25,disp[4],smg$m_border);
  smg$paste_virtual_display(disp[4],paste,10,27);
  smg$put_line(disp[4],line,,,,smg$m_wrap_word);
  lib$wait(2.0);
  smg$delete_virtual_display(disp[4]);
end;

procedure info (line: istring);
var
  exist : [static] boolean := false;
begin
  if line.length > 0 then begin
    if not exist then begin
      smg$create_virtual_display(4,33,disp[5],smg$m_border);
      smg$paste_virtual_display(disp[5],paste,2,2);
      exist := true;
    end;
    smg$put_line(disp[5],line,,,,smg$m_wrap_word);
  end else begin
    smg$delete_virtual_display(disp[5]);
    exist := false;
  end;
end;

procedure winner;
var
  scorestr : varstr := ' ';
begin
  smg$create_virtual_display(22,78,disp[1]);
  smg$create_pasteboard(paste);
  smg$set_cursor_mode(paste,smg$m_cursor_off);
  smg$set_broadcast_trapping(paste);
  smg$paste_virtual_display(disp[1],paste,2,2);
  if (myscore > yourscore) then begin
    smg$put_chars_highwide(disp[1],me.city,2,20,smg$m_blink);
    smg$put_chars_highwide(disp[1],me.name,4,20,smg$m_blink);
    smg$put_chars_highwide(disp[1],you.city,14,20);
    smg$put_chars_highwide(disp[1],you.name,16,20);
    convert(myscore,scorestr,xlen);
    smg$put_chars_highwide(disp[1],scorestr,4,8,smg$m_blink);
    convert(yourscore,scorestr,xlen);
    smg$put_chars_highwide(disp[1],scorestr,16,8);
  end else if (yourscore > myscore ) then begin
    smg$put_chars_highwide(disp[1],you.city,2,20,smg$m_blink);
    smg$put_chars_highwide(disp[1],you.name,4,20,smg$m_blink);
    smg$put_chars_highwide(disp[1],me.city,14,20);
    smg$put_chars_highwide(disp[1],me.name,16,20);
    convert(yourscore,scorestr,xlen);
    smg$put_chars_highwide(disp[1],scorestr,4,8,smg$m_blink);
    convert(myscore,scorestr,xlen);
    smg$put_chars_highwide(disp[1],scorestr,16,8);
  end else begin
    smg$put_chars_highwide(disp[1],me.city,2,20,smg$m_blink);
    smg$put_chars_highwide(disp[1],me.name,4,20,smg$m_blink);
    smg$put_chars_highwide(disp[1],you.city,14,20,smg$m_blink);
    smg$put_chars_highwide(disp[1],you.name,16,20,smg$m_blink);
    convert(yourscore,scorestr,xlen);
    smg$put_chars_highwide(disp[1],scorestr,4,8,smg$m_blink);
    convert(myscore,scorestr,xlen);
    smg$put_chars_highwide(disp[1],scorestr,16,8,smg$m_blink);
  end;
  lib$wait(7.5);
  smg$set_cursor_mode(paste,smg$m_cursor_on);
  smg$delete_virtual_display(disp[1]);
  smg$delete_pasteboard(paste);
end;

procedure teamlight;
begin
  if (mestart) then begin
    smg$put_chars(disp[1],me.city,1,9,,smg$m_bold);
    smg$put_chars(disp[1],me.name,2,9,,smg$m_bold);
    smg$put_chars(disp[1],you.city,4,9);
    smg$put_chars(disp[1],you.name,5,9);
  end else begin
    smg$put_chars(disp[1],me.city,1,9);
    smg$put_chars(disp[1],me.name,2,9);
    smg$put_chars(disp[1],you.city,4,9,,smg$m_bold);
    smg$put_chars(disp[1],you.name,5,9,,smg$m_bold);
  end;
end;

procedure printscore;
var
  str1, str2 : varying[6] of char;
begin
  writev(str1, myscore:0);
  writev(str2, yourscore:0);
  if (mestart) then begin
    smg$put_chars(disp[1],str1,2,2,,smg$m_bold);
    smg$put_chars(disp[1],str2,5,2);
  end else begin
    smg$put_chars(disp[1],str1,2,2);
    smg$put_chars(disp[1],str2,5,2,,smg$m_bold);
  end;
end;  

procedure place (loc: integer);
begin
  smg$put_chars(disp[2],'0',8,cv(loc),,smg$m_bold)
end;

procedure restore (loc: integer);
begin
  case (loc) of
    0,10,20,30,40,50,60,70,80,90,100:
        smg$draw_line(disp[2],7,cv(loc),8,cv(loc));
    otherwise
        smg$put_chars(disp[2],' ',8,cv(loc));
  end;
end;
 
procedure menu_select(num: integer; var option: integer);
var
  choice : $uword;
begin
  if (num=1) then begin
    smg$create_virtual_display(max_of,25,disp[3],smg$m_block_border);
    smg$paste_virtual_display(disp[3],paste,9,27);
    smg$create_menu(disp[3],%descr of_table,smg$k_vertical);
  end else if (num=2) then begin
    smg$create_virtual_display(max_op,25,disp[3],smg$m_block_border);
    smg$paste_virtual_display(disp[3],paste,9,27);
    smg$create_menu(disp[3],%descr op_table,smg$k_vertical);
  end else if (num=3) then begin
    smg$create_virtual_display(max_df,25,disp[3],smg$m_block_border);
    smg$paste_virtual_display(disp[3],paste,9,27);
    smg$create_menu(disp[3],%descr df_table,smg$k_vertical);
  end else if (num=4) then begin
    smg$create_virtual_display(max_dp,25,disp[3],smg$m_block_border);
    smg$paste_virtual_display(disp[3],paste,9,27);
    smg$create_menu(disp[3],%descr dp_table,smg$k_vertical);
  end;
  smg$select_from_menu(keyb,disp[3],choice,,,%descr helplib,,,,smg$m_bold);
  smg$delete_virtual_display(disp[3]);
  option := choice;
end;

procedure create_screen;
var
  yrdstr : varstr := ' ';
begin
  smg$create_virtual_display(6,78,disp[1]);
  smg$create_virtual_display(15,77,disp[2],smg$m_block_border);
  smg$create_pasteboard(paste);
  smg$create_virtual_keyboard(keyb);
  smg$set_cursor_mode(paste,smg$m_cursor_off);
  smg$set_broadcast_trapping(paste);
  smg$paste_virtual_display(disp[1],paste,2,2);
  smg$paste_virtual_display(disp[2],paste,9,2);

  smg$put_chars(disp[1],me.city,1,9);
  smg$put_chars(disp[1],me.name,2,9);
  smg$put_chars(disp[1],you.city,4,9);
  smg$put_chars(disp[1],you.name,5,9);
  smg$put_chars(disp[1],'0',2,2);
  smg$put_chars(disp[1],'0',5,2);

  for i := 1 to 77 do begin
    if (odd(i)) then begin
      smg$put_chars(disp[2],'_',5,i);
      smg$put_chars(disp[2],'_',10,i);
    end else begin
      smg$put_chars(disp[2],' ',5,i);
      smg$put_chars(disp[2],' ',10,i);
    end;
  end;
  smg$draw_line(disp[2],1,9,15,9);
  smg$put_chars(disp[2],'G',14,8);
  for i := 1 to 9 do begin
    smg$draw_line(disp[2],1,9+i*6,15,9+i*6);
    if (i<6) then
      convert(i,yrdstr,xlen)
    else
      convert(10-i,yrdstr,xlen);
    smg$put_chars(disp[2],yrdstr,14,cv(i*10-1));
    smg$put_chars(disp[2],chr(48),14,cv(i*10+1));
  end;
  smg$draw_line(disp[2],1,69,15,69);
  smg$put_chars(disp[2],'G',14,70);
end;

function pid_check (pid : unsigned): boolean;
var
  sysstatus : integer := 1;
  dummy : unsigned := 1;
begin
  sysstatus := lib$getjpi(jpi$_pid,pid,,dummy);
  case (sysstatus) of
    ss$_nopriv  : pid_check := true;   { Process exists, no privilege to view }
    ss$_nonexpr : pid_check := false;  { Process no longer exists }
    ss$_normal  : pid_check := true;   { Process exists, privilege to view }
  otherwise
    lib$signal(sysstatus);
  end;
end;

procedure initiate;
var
  master_pid : unsigned;
  hudstr : packed array [1..1] of char;
begin
  writeln(chr(27)+'[2J'+chr(27)+'[1;1H');
  lib$get_foreign(you.userid,,alen);
  if ((alen = 0) or (you.userid = ' ')) then begin
    repeat
      lib$get_input(you.userid,'What is the username of your opponent? ',alen);
    until ((alen > 0) and (you.userid <> ' '));
    if (not(odd($asctoid(you.userid,,)))) then
      lib$signal(iaddress(football_baduser));
  end;
  lib$getjpi(jpi$_username,,,,me.userid);
  lib$getjpi(jpi$_master_pid,,,master_pid);
  lib$getjpi(jpi$_pid,,,me.pid);
  str$upcase(you.userid,you.userid);
  str$upcase(me.userid,me.userid);
  if (master_pid = me.pid) then lib$signal(iaddress(football_notspawn));
  if (you.userid = me.userid) then lib$signal(iaddress(football_lonely));

  (* Open the playerfile and  write your record *)

  open(playfile, boothfile, history := unknown, access_method := keyed,
    organization := indexed, record_type := fixed,
    sharing := readwrite, user_action := rms_open);
  lib$get_input(%descr me.city,%stdescr 'What city is your team from? ');
  lib$get_input(%descr me.name,%stdescr 'What is the name of your team? ');
  str$upcase(me.name,me.name);
  str$upcase(me.city,me.city);
  writeln(' ');
  me.formation := 0;
  me.play := 0;
  me.count := 0;
  me.time := gametime;
  me.pos := 0;
  me.gained := 0;
  me.quarter := 1;
  me.down := 1;
  me.iswaiting := true;
  me.dir := true;
  rbf := iaddress(me);
  rmsstatus := rms_put(pas$rab(playfile)^);
  if (not(odd(rmsstatus))) then lib$signal(rmsstatus);

  (* Get the other player's record from the player file *)

  kbf := iaddress(you.userid);
  ubf := iaddress(you);
  rmsstatus := rms_get(pas$rab(playfile)^,false);
  if (rmsstatus = rms$_rnf) then begin
    repeat
      lib$wait(4.0);
      wait := wait + 1;
      rmsstatus := rms_get(pas$rab(playfile)^,false);
    until ((odd(rmsstatus)) or (wait >= 10));
  end;

  (* The other player's record was not found - timeout period reached *)

  if (not(odd(rmsstatus))) then begin
 
    (* Delete my record *)

    kbf := iaddress(me.userid);
    ubf := iaddress(me);
    rmsstatus := rms_get(pas$rab(playfile)^,true);
    if (not(odd(rmsstatus))) then lib$signal(rmsstatus);
    rmsstatus := rms_delete(pas$rab(playfile)^);
    if (not(odd(rmsstatus))) then lib$signal(rmsstatus);
    lib$signal(iaddress(football_absent));
  end;

  (* Other player's record was found - check to see if current *)

  if (not(pid_check(you.pid))) then begin

    (* Delete my record *)

    kbf := iaddress(me.userid);
    ubf := iaddress(me);
    rmsstatus := rms_get(pas$rab(playfile)^,true);
    if (not(odd(rmsstatus))) then lib$signal(rmsstatus);
    rmsstatus := rms_delete(pas$rab(playfile)^);
    if (not(odd(rmsstatus))) then lib$signal(rmsstatus);

    (* Delete other record *)

    kbf := iaddress(you.userid);
    ubf := iaddress(you);
    rmsstatus := rms_get(pas$rab(playfile)^,true);
    if (not(odd(rmsstatus))) then lib$signal(rmsstatus);
    rmsstatus := rms_delete(pas$rab(playfile)^);
    if (not(odd(rmsstatus))) then lib$signal(rmsstatus);
    lib$signal(iaddress(football_badrecord));
  end;

  (* Other player unghosted - is he playing or waiting to play? *)

  if (not(you.iswaiting)) then begin

    (* Delete my record *)

    kbf := iaddress(me.userid);
    ubf := iaddress(me);
    rmsstatus := rms_get(pas$rab(playfile)^,true);
    if (not(odd(rmsstatus))) then lib$signal(rmsstatus);
    rmsstatus := rms_delete(pas$rab(playfile)^);
    if (not(odd(rmsstatus))) then lib$signal(rmsstatus);
    lib$signal(iaddress(football_playing));
  end;

  (* The other player is waiting for me - set his ISWAITING to false *)

  kbf := iaddress(you.userid);
  ubf := iaddress(you);
  rmsstatus := rms_get(pas$rab(playfile)^,true);
  if (not(odd(rmsstatus))) then lib$signal(rmsstatus);
  you.iswaiting := false;
  rmsstatus := rms_update(pas$rab(playfile)^);
  if (not(odd(rmsstatus))) then lib$signal(rmsstatus);

  (* One of these people has to go first - compare entry times *)

  if (you.pid > me.pid) then
    istarted := true
  else
    istarted := false;
  if (istarted) then begin
    kbf := iaddress(me.userid);
    ubf := iaddress(me);
    rmsstatus := rms_get(pas$rab(playfile)^,true);
    if (not(odd(rmsstatus))) then lib$signal(rmsstatus);
    mestart := true;
    me.first := true;
    rmsstatus := rms_update(pas$rab(playfile)^);
    if (not(odd(rmsstatus))) then lib$signal(rmsstatus);
  end else begin
    kbf := iaddress(me.userid);
    ubf := iaddress(me);
    rmsstatus := rms_get(pas$rab(playfile)^,true);
    if (not(odd(rmsstatus))) then lib$signal(rmsstatus);
    you.first := true;
    rmsstatus := rms_update(pas$rab(playfile)^);
    if (not(odd(rmsstatus))) then lib$signal(rmsstatus);
  end;

  (* Find out each player's offensive strategy *)

  writeln('OFFENSIVE STRATEGIES');
  writeln;
  writeln('1) No huddle (very long game)');
  writeln('2) Short huddle (long game)');
  writeln('3) Regular huddle (short game)');
  writeln('4) Long huddle (very short game)');
  writeln;
  repeat  
    lib$get_input(hudstr,'Choice> ',alen);
    readv(hudstr,huddle,error:=continue);
  until (statusv = 0) and (huddle >= 1) and (huddle <= 4);
  writeln;

  writeln('TEAM STRENGTH');
  writeln;
  writeln('1) running');
  writeln('2) passing');
  writeln;
  repeat  
    lib$get_input(hudstr,'Choice> ',alen);
    readv(hudstr,huddle,error:=continue);
  until (statusv = 0) and (huddle >= 1) and (huddle <= 2);
  if (huddle = 1) then
    running := true
  else if (huddle = 2) then
    passing := true;
  writeln;

  (* Coin toss - means absolutely nothing, and is totally fake *)
 
  if (rnd(100) > 50) then
    writeln('Heads has won the toss, I think.')
  else
    writeln('Tails has won the toss, I think.');
  if (mestart) then begin
    ctrim(me.city,alen);
    writeln(substr(me.city,1,alen)+' will receive the ball first!');
  end else begin
    ctrim(you.city,alen);
    writeln(substr(you.city,1,alen)+' will receive the ball first!');
  end;
  lib$wait(3.0);
end;

procedure finitiate;
begin
  kbf := iaddress(me.userid);
  ubf := iaddress(me);
  rmsstatus := rms_get(pas$rab(playfile)^,true);
  if (not(odd(rmsstatus))) then lib$signal(rmsstatus);
  rmsstatus := rms_delete(pas$rab(playfile)^);
  if (not(odd(rmsstatus))) then lib$signal(rmsstatus);
  smg$set_cursor_mode(paste,smg$m_cursor_on);
  smg$delete_virtual_keyboard(keyb);
  smg$delete_virtual_display(disp[1]);
  smg$delete_virtual_display(disp[2]);
  smg$delete_pasteboard(paste);
  close(playfile);
end;

procedure statcard;
var
  xstr : varstr;
begin
  convert(gtime,xstr,xlen);
  if (gtime >= 1000) then
    xstr := substr(xstr,1,2)+'.'+substr(xstr,3,2)
  else if (gtime >= 100) then
    xstr := ' '+substr(xstr,1,1)+'.'+substr(xstr,2,2)
  else if (gtime >= 10) then
    xstr := '  .'+xstr
  else
    xstr := '  .0'+xstr;
  smg$put_chars(disp[1],'               ',1,60);
  smg$put_chars(disp[1],'TIME:       '+xstr,1,60);
  convert(quarter,xstr,xlen);
  smg$put_chars(disp[1],'QUARTER:        '+xstr,2,60);
  if (where < 51) then
    convert(where,xstr,xlen)
  else
    convert(100-where,xstr,xlen);
  smg$put_chars(disp[1],'                    ',3,60);
  if (xstr.length = 1) then
    smg$put_chars(disp[1],'BALL ON:        '+xstr,3,60)
  else
    smg$put_chars(disp[1],'BALL ON:       '+xstr,3,60);
  convert(ydstogo,xstr,xlen);
  smg$put_chars(disp[1],'                    ',4,60);
  if (xstr.length = 1) then
    smg$put_chars(disp[1],'YARDS TO GO:    '+xstr,4,60)
  else
    smg$put_chars(disp[1],'YARDS TO GO:   '+xstr,4,60);
  statistic('YARDS GAINED: ',4);
  showdown;
end;

procedure receiveplay;
begin
  repeat
    kbf := iaddress(you.userid);
    ubf := iaddress(you);
    rmsstatus := rms_get(pas$rab(playfile)^,false);
    if (not(odd(rmsstatus))) then lib$signal(rmsstatus);
    if (not(pid_check(you.pid))) then begin
      mestart := true;
      finitiate;
      lib$signal(iaddress(football_ghosted));
    end;
    lib$wait(0.4);
  until (me.count < you.count);
  kbf := iaddress(me.userid);
  ubf := iaddress(me);
  rmsstatus := rms_get(pas$rab(playfile)^,true);
  if (not(odd(rmsstatus))) then lib$signal(rmsstatus);
  me.count := you.count;
  rmsstatus := rms_update(pas$rab(playfile)^);
  if (not(odd(rmsstatus))) then lib$signal(rmsstatus);  
end;

procedure sendplay;
var
  now : datetime;
begin
  kbf := iaddress(you.userid);
  ubf := iaddress(you);
  repeat
    rmsstatus := rms_get(pas$rab(playfile)^,false);
  until (rmsstatus <> rms$_busy);
  if (not(odd(rmsstatus))) then lib$signal(rmsstatus);
  kbf := iaddress(me.userid);
  ubf := iaddress(me);
  repeat
    rmsstatus := rms_get(pas$rab(playfile)^,true);
  until (rmsstatus <> rms$_busy);
  if (not(odd(rmsstatus))) then lib$signal(rmsstatus);
  me.formation := myform;
  me.play := myact;
  me.pos := where;
  me.count := you.count + 1;
  me.time := gtime;
  me.gained := stat;
  me.quarter := quarter;
  me.down := down;
  me.dir := dir;
  me.ydstogo := ydstogo;
  me.dokickoff := dokickoff;
  me.score := score;
  me.intercepted := interception;
  me.fumble := fumble;
  rmsstatus := rms_update(pas$rab(playfile)^);
  if (not(odd(rmsstatus))) then lib$signal(rmsstatus);
end;

procedure timer (lost: integer);
begin
  if (not(newquarter)) and (not(newhalf)) and (not(gameover)) then begin
    lost := lost * huddle;
    if (mestart) then begin
      gtime := gtime - lost;
      if (gtime < 0) then begin
        gtime := gametime;
        quarter := quarter + 1;
        newquarter := true;
        if (quarter = 3) then
          newhalf := true
        else if (quarter = 5) then
          gameover := true;
      end;
      sendplay;
      receiveplay;
    end else begin
      receiveplay;
      sendplay;
      gtime := you.time;
      if (quarter < you.quarter) then begin
        quarter := you.quarter;
        newquarter := true;
        if (quarter = 3) then
          newhalf := true
        else if (quarter = 5) then
          gameover := true;
      end;
    end;
  end;
end;

procedure moveball (fromspot, tospot : integer);
begin
  if (tospot > fromspot) then
    for i := fromspot to tospot - 1 do begin
      restore(i);
      place(i+1);
    end
  else
    for i := fromspot downto tospot + 1 do begin
      restore(i);
      place(i-1);
    end;
end;

procedure runplay;
var
  mag : integer;
  outstr : string;
  completepass : boolean := false;
begin
  if (mestart) then begin           (*  run the play  *)
    xlen := trim(dp_table[you.play],playstr);
    info('The defense ran a '+substr(playstr,1,xlen)+'! ');
    mag := roll_play(me.formation, me.play, you.formation, you.play);
    if ispass(me.play) then begin
      if (mag < 0) then begin
        stat := mag;
        info('You are sacked for a big loss! ');
      end else if (isdeeppass(me.play)) then begin
        if passing then
          completepass := (rnd(100) > 60)
        else
          completepass := (rnd(100) > 70);
        if completepass then begin
          if (rnd(100) <= 15) then interception := true;
          stat := 10+mag*rnd(6);
          if (not(interception)) then
            info('You complete the long bomb for big yardage! ');
        end else
          stat := 0;
      end else if (iseasypass(me.play)) then begin
        if passing then
          completepass := (rnd(100) > 20)
        else
          completepass := (rnd(100) > 25);
        if completepass then begin
          if (rnd(100) <= 5) then interception := true;
          stat := rnd(mag)*rnd(2) + 1;
          if (not(interception)) then
            info('You completed the pass! ');
        end else
          stat := 0;
      end else begin
        if passing then
          completepass := (rnd(100) > 40)
        else
          completepass := (rnd(100) > 50);
        if completepass then begin
          if (rnd(100) <= 8) then interception := true;
          stat := rnd(mag)*rnd(4)  + 1;
          if (not(interception)) then
            info('You completed the pass! ');
        end else
          stat := 0;
      end;
      if (stat = 0) and (not(interception)) then
        info('The pass was incomplete. ');
    end else begin
      if (rnd(100) <= 5) then fumble := true;
      if running then
        stat := rnd(mag+5) - 1
      else
        stat := rnd(mag+4) - 2;
      if (not(fumble)) then begin
        if (stat <= 1) then
          info('You were stopped cold! ')
        else if (stat >= 6) then
          info('You blew away the defense! ')
        else
          info('You ran into the defensive front! ');
      end;
    end;
    old_where := where;
    if (dir) then
      where := where + stat
    else
      where := where - stat;
    moveball(old_where, where);  (* old_where and where is handled here *)

    if (interception) then info('The ball was intercepted!');
    if (fumble) then info('The runningback fumbled the ball!');

    if (not(fumble)) and (not(interception)) then begin

      (* are we in end zone? *)
 
      if (((dir) and (where >= 100)) or
          (not(dir) and (where <= 0))) then
        score := 7
      else if (((dir) and (where <= 0)) or
               (not(dir) and (where >= 100))) then (* Safety! *)
        score := -2

      (* we only care about downs when there is no score! *)

      else begin 
        if (ydstogo <= stat) then begin
          down := 1;
          ydstogo := 10;
          comment('FIRST DOWN!');
        end else begin
          down := down + 1;
          ydstogo := ydstogo - stat;
        end;
      end;
    end else begin
      down := 1;
      ydstogo := 10;
      if (interception) then comment('INTERCEPTION!');
      if (fumble) then comment('FUMBLE!');
      dir := not(dir);
      turnover;
    end;
    statcard;
    sendplay;
    receiveplay;
  end
  else begin  (*  not mestart  *)
    receiveplay;
    sendplay;
    stat := you.gained;
    interception := you.intercepted;
    fumble := you.fumble;
    xlen := trim(op_table[you.play],playstr);
    info('The offense ran a '+substr(playstr,1,xlen)+'! ');

    if (not(fumble)) and (not(interception)) then begin
      if ispass(you.play) then begin
        if (stat < 0) then
          info('You sacked the quarterback for a big loss! ')
        else if (isdeeppass(you.play)) then begin
          if (stat > 0) then
            info('The receiver snags the long bomb! Completed pass! ');
        end else begin
          if (stat > 0) then
            info('The pass was complete! ');
        end;
        if (stat = 0) then
            info('The pass was incomplete. ');
      end else begin
        if (stat <= 1) then
          info('You stopped them cold! ')
        else if (stat >= 6) then
          info('The offensive line blew you away! ')
        else
          info('The defensive front contained the running back! ');
      end;
    end else begin
      if (interception) then info('The ball was intercepted!');
      if (fumble) then info('The runningback fumbled the ball!');
    end;

    old_where := where;
    where := you.pos;
    moveball(old_where, where);   (* old_where and where is handled here *)

    if (fumble) or (interception) then begin
      down := 1;
      ydstogo := 10;
      if (interception) then comment('INTERCEPTION!');
      if (fumble) then comment('FUMBLE!');
      dir := not(dir);
      turnover;
    end;

    score := you.score;
    down := you.down;
    ydstogo := you.ydstogo;
    statcard;
  end;
end;

procedure handlescore;
begin
  if (mestart) then begin        (*  Any Score?  *)
    if (score <> 0) then begin
      old_where := where;
      if (score = 7) then begin
        if (dir) then
          where := 35
        else
          where := 65;
        myscore := myscore + 7;
        comment('TOUCHDOWN!');
      end else if (score = -2) then begin
        if (dir) then
          where := 15
        else
          where := 85;
        yourscore := yourscore + 2;
        comment('SAFETY!');
      end else if (score = 3) then begin
        if (dir) then
          where := 35
        else
          where := 65;
        myscore := myscore + 3;
        comment('FIELD GOAL!');
      end;
      restore(old_where);  (* take care old_where and where now! *)
      place(where);
      dokickoff := true;
      smg$ring_bell(disp[1],3);
      turnover;
    end;
    sendplay;
    receiveplay;
  end else begin      (*  not mestart  *)
    receiveplay;
    sendplay;
    if (score <> 0) then begin
      old_where := where;
      where := you.pos;
      score := you.score;
      if (score = 7) then begin
        yourscore := yourscore + 7;
        comment('TOUCHDOWN!');
      end else if (score = -2) then begin
        myscore := myscore + 2;
        comment('SAFETY!');
      end else if (score = 3) then begin
        yourscore := yourscore + 3;
        comment('FIELD GOAL! ');
      end;
      restore(old_where);   (* take care old_where and where now! *)
      place(where);
      dokickoff := you.dokickoff;
      smg$ring_bell(disp[1],3);
      turnover;
    end;
  end;
  teamlight;
  printscore;
end;

procedure handletime;
begin
  if (mestart) then begin      (* Change of quarter  *)
    if gameover then begin
      comment('GAME OVER!');
      lib$wait(2.0);
      (* Disney world for me!! *)
    end
    else if newhalf then begin
      (* change offense here ..could be tricky *)
      dir := not(dir);
      restore(old_where);
      old_where := where;
      if (dir) then
        where := 35
      else
        where := 65;
      ydstogo := 10;
      dokickoff := true;   (* old_where and where will be handled in kickoff *)
      comment('SECOND HALF!');
      mestart := not(istarted);
      arrow;
      lib$wait(2.0);
    end else if newquarter then begin
      dir := not(dir);
      old_where := where;
      where := 100 - where;
      restore(old_where);
      place(where);
      comment('NEW QUARTER!');
      arrow;
    end;
    sendplay;
    receiveplay;
  end
  else begin            (*  not mestart  *)
    receiveplay;
    sendplay;
    dir := you.dir;
    old_where := where;
    where := you.pos;
    dokickoff := you.dokickoff;
    (* change offense here  ..could be tricky *)
    (*  will read from mail box  *)
    if gameover then begin
      comment('GAME OVER!');
      lib$wait(2.0);
      (* Disney world for me!! *)
    end else if newhalf then begin
      ydstogo := 10;
      comment('SECOND HALF!');
      mestart := not(istarted);
      arrow;
      lib$wait(2.0);
    end else if newquarter then begin
      restore(old_where);
      place(where);
      comment('NEW QUARTER!');
      arrow;
    end;
  end;
end;

procedure handledown;
begin
  if not(newhalf) and not(gameover) then begin
    if (mestart) then begin    (*  5th down?  *)
      if (down > 4) then begin
        ydstogo := 10;
        dir := not(dir);
        comment('NEW OFFENSE! ');
        turnover;
      end;
      sendplay;
      receiveplay; 
    end
    else begin            (*  not mestart..that will be changed  *)
      receiveplay;
      sendplay;
      if (you.down = 1) and not(fumble) and not(interception) then
        comment('FIRST DOWN!');
      down := you.down;
      ydstogo := you.ydstogo;
      dir := you.dir;
      if (down > 4) then begin
        comment('NEW OFFENSE! ');
        turnover;
      end;
    end;
  end;

  if (down > 4) then begin  (* must be done here..or receiver will miss it *)
    down := 1;
    showdown;
  end;
end;

procedure handlekick;
var
  scored : boolean := false;
begin
  if (mestart) then begin
    if (dir) then
      scored := ((100-where) < rnd(50))
    else
      scored := (where < rnd(50));
    if scored then begin
      score := 3;
      info('The kick was good!');
    end else begin
      dir := not(dir);
      info('The kick missed the uprights!');
      comment('NEW OFFENSE!');
    end;
    down := 1;
    ydstogo := 10;
    sendplay;
    receiveplay;
  end else begin
    receiveplay;
    sendplay;
    score := you.score;
    if (score = 3) then begin
      info('The kick was good!');
    end else begin
      dir := you.dir;
      info('The kick missed the uprights!');
      comment('NEW OFFENSE!');
    end;
    down := you.down;
    ydstogo := you.ydstogo;
  end;
end;

procedure handlepunt;
begin
  old_where := where;
  if (mestart) then begin
    stat := kickbase + rnd(20);
    if (dir) then
      where := where + stat
    else
      where := where - stat;
    sendplay;
    receiveplay;
  end else begin
    receiveplay;
    sendplay;
    where := you.pos;
    stat := you.gained;
  end;
  dir := not(dir);
  moveball(old_where, where);
  statistic('PUNT:          ',2);
end;

procedure handlekickoff;
begin
  dokickoff := false;
  restore(old_where);
  old_where := where;
  if (mestart) then begin
    stat := kickbase + rnd(30);
    if (dir) then
      where := where + stat
    else
      where := where - stat;
    sendplay;
    receiveplay;
  end else begin
    receiveplay;
    sendplay;
    where := you.pos;
    stat := you.gained;
  end;
  moveball(old_where,where);
  statistic('KICKOFF:       ',2);
  dir := not(dir);
end;

procedure handlerunback;
begin
  old_where := where;
  if (mestart) then begin
    if ((where > 100) or (where < 0)) then begin
      if (where > 100) then
        where := 80
      else
        where := 20;
      restore(old_where);
      place(where);
      comment('TOUCHBACK!');
    end else begin
      if (not(interception)) and (not(fumble)) then begin
        comment('RUNBACK!');
        stat := rbbase + rnd(20);
      end else if (fumble) then begin
        stat := rnd(15);
      end else if (interception) then begin
        case (rnd(100)) of
          1..30   : stat := 0;
          31..70  : stat := rnd(20);
          71..100 : stat := rnd(100);
        end;
      end;
        
      if (dir) then
        where := where + stat
      else
        where := where - stat;
      moveball(old_where,where);
      statistic('RUNBACK:      ',3);

      (* are we in end zone? *)

      if (((dir) and (where >= 100)) or (not(dir) and (where <= 0))) then
        score := 7;
    end;
    sendplay;
    receiveplay;
  end else begin
    receiveplay;
    sendplay;
    if ((where > 100) or (where < 0)) then begin
      where := you.pos;
      restore(old_where);
      place(where);
      comment('TOUCHBACK!');
    end else begin
      if (not(interception)) and (not(fumble)) then comment('RUNBACK!');
      where := you.pos;
      stat := you.gained;
      score := you.score;
      moveball(old_where, where);
      stat := you.gained;
      statistic('RUNBACK:      ',3);
    end;
  end;
  down := 1;
  ydstogo := 10;
end;

procedure perform;
begin
  timer(rnd(25)+20);
  runplay;
  if (interception) or (fumble) then handlerunback;
  handlescore;
  handletime;
  handledown;
  statcard;
  if (not(gameover)) then begin
    teamlight;
    printscore;
  end;
  info('');
end;

procedure kickoff;
begin
  timer(10+rnd(10));
  comment('KICKOFF!');
  handlekickoff;
  arrow;
  handlerunback;
  handletime;
  statcard;
  if (not(gameover)) then begin
    teamlight;
    printscore;
  end;
  info('');
end;

procedure kick;
begin
  timer(10+rnd(10));
  handlekick;
  handlescore;       { If score does not equal zero turnover happens here }
  handletime;
  if (score = 0) then turnover;
  statcard;
  if (not(gameover)) then begin
    teamlight;
    printscore;
  end;
  info('');
end;

procedure punt;
begin
  timer(10+rnd(10));
  comment('PUNT!');
  handlepunt;
  handlerunback;
  handletime;
  if (not(newhalf)) then turnover;
  statcard;
  if (not(gameover)) then begin
    teamlight;
    printscore;
  end;
  info('');
end;

begin
  $setpri(,,4,);
  quarter := 1;
  down := 1;
  gtime := gametime;
  ydstogo := 10;
  initiate;
  create_screen;
  where := 35;
  old_where := 35;
  timer(0);
  statcard;
  repeat
    score := 0;  (*  let's make sure no score will carry over! *)
    interception := false;
    fumble := false;
    newhalf := false;
    newquarter := false;
    gameover := false;
    if (dokickoff) then begin
      lib$wait(2.0);
      kickoff;
    end;
    if (mestart) then begin
      repeat
        menu_select(1,myform);
        menu_select(2,myact);
        if not offenformflags[myform, myact] then
          message('You can''t choose that play in such formation! ');
      until offenformflags[myform, myact];
      comment('          ');
      sendplay;
      receiveplay;
      if (myact = op_punt) then
        punt
      else if (myact = op_kick) then
        kick
      else
        perform;
    end else begin
      receiveplay;
      info('Offensive formation: ');
      info(of_table[you.formation]);
      repeat
        menu_select(3,myform);
        menu_select(4,myact);
        if not defformflags[myform, myact] then
          message('You can''t choose that play from that formation! ');
      until defformflags[myform, myact];
      comment('          ');
      sendplay;
      info('');
      if (you.play = op_punt) then
        punt
      else if (you.play = op_kick) then
        kick
      else 
        perform;
    end;
  until (gameover);
  finitiate;
  winner;
end.
{
********************************************************************************
*                                                                              *
*   Program:   MASLIB_FOOTBALL                                                 *
*   Co-Author: Xiaomu Zeng                                                     *
*   BITNET:    MASWINDY@UBVMS                                                  *
*   Internet:  maswindy@ubvms.cc.buffalo.edu                                   *
*   Co-Author: William W. Brennessel                                           *
*   BITNET:    MASMUMMY@UBVMS                                                  *
*   Internet:  masmummy@ubvms.cc.buffalo.edu                                   *
*                                                                              *
*   This program was created for personal use, and may be copied and altered   *
*   under the condition that the authors are not responsible for any problems  *
*   that may occur.  Comments and criticisms are always welcome.               *
*                                                                              *
********************************************************************************
}
