{ This program was written by Richard Wicks of the University of Buffalo }
{ permission to copy, duplicate, spindle or mutilate this program is     }
{ hereby explicitly granted provided that this header remains intact.    }
{ Any other use constitutes copy right infiringement an will be dealt    }
{ in accordance with the full extent of the law.                         }

{ questions, comments, etc. should be directed to either:                }
{ V128LL9E @ UBVMS.CC.BUFFALO.EDU  *or*  MASRICH @ UBVMS.CC.BUFFALO.EDU  }

[inherit ('sys$library:starlet')]

program LEVELR (input,output);

const
  prefixd = 'disk$userdisk1:[mas0.masrich.games]';
  sheight = 21;
  swidth  = 78;

type
  $UBYTE  = [BYTE] 0..255;
  $UWORD  = [WORD] 0..65535;
  short   = packed array [1..4] of char;
  liner   = array [1..sheight] of boolean;
  vshort  = packed array [1..19] of char;

var
{totally bogus variables}
  prefix    : varying [100] of char;
  QUIT      : boolean;
  loop      : integer;
  loop2     : integer;
  null      : varying [4] of char; {to change shroom string to integer}

{bogus screen variables}
  keyboard  : unsigned;
  pasty     : unsigned;
  helpdis   : unsigned;{helpscreen}
  stat      : unsigned;{status display}
  display   : unsigned;

{backup variables}
  t_time    : packed array [1..11] of char;{compare old and new, when diff save}
  t_time_o  : packed array [1..11] of char;
  AUTO      : boolean; {controlls if autosave backup feature is used or not}
  AUTOSAVE  : boolean; {controlls if there is a save needed}
  NOWRITE   : boolean; {controlls wether a file is saved or discarded}

{options for display}
  clistat   : unsigned;
  wallseg   : char;
  moveb     : boolean;

{variables for the copy command}
  leftx     : integer;
  rightx    : integer;
  lefty     : integer;
  righty    : integer;
  temp      : array [1..swidth] of liner;

{important variables}
  title     : array [1..2] of vshort;
  filename  : varying [100] of char;
  filen     : integer; {gets the level}
  screen    : array [1..swidth] of liner;
  lastdir   : [word] 0..65535;
  direction : [word] 0..65535;
  X         : integer;
  Y         : integer;
  muno      : integer;
  lastkey   : [word] 0..65535;

{external functions start}

[ASYNCHRONOUS] FUNCTION lib$delete_file (
	filespec : [CLASS_S] PACKED ARRAY [$l1..$u1:INTEGER] OF CHAR;
	default_filespec : [CLASS_S] PACKED ARRAY [$l2..$u2:INTEGER] OF CHAR := %IMMED 0;
	related_filespec : [CLASS_S] PACKED ARRAY [$l3..$u3:INTEGER] OF CHAR := %IMMED 0;
	%IMMED [UNBOUND, ASYNCHRONOUS] PROCEDURE user_success_procedure := %IMMED 0;
	%IMMED [UNBOUND, ASYNCHRONOUS] PROCEDURE user_error_procedure := %IMMED 0;
	%IMMED [UNBOUND, ASYNCHRONOUS] PROCEDURE user_confirm_procedure := %IMMED 0;
	%IMMED user_specified_argument : [UNSAFE] INTEGER := %IMMED 0;
	VAR resultant_name : [CLASS_S,VOLATILE] PACKED ARRAY [$l8..$u8:INTEGER] OF CHAR := %IMMED 0;
	VAR file_scan_context : [VOLATILE] UNSIGNED := %IMMED 0) : INTEGER; EXTERNAL;

[ASYNCHRONOUS] FUNCTION smg$create_pasteboard (
	VAR pasteboard_id : [VOLATILE] UNSIGNED;
	output_device : [CLASS_S] PACKED ARRAY [$l2..$u2:INTEGER] OF CHAR := %IMMED 0;
	VAR number_of_pasteboard_rows : [VOLATILE] INTEGER := %IMMED 0;
	VAR number_of_pasteboard_columns : [VOLATILE] INTEGER := %IMMED 0;
	flags : UNSIGNED := %IMMED 0;
	VAR type_of_terminal : [VOLATILE] UNSIGNED := %IMMED 0) : INTEGER; EXTERNAL;

[ASYNCHRONOUS] FUNCTION smg$create_virtual_keyboard (
	VAR keyboard_id : [VOLATILE] UNSIGNED;
	input_device : [CLASS_S] PACKED ARRAY [$l2..$u2:INTEGER] OF CHAR := %IMMED 0;
	default_filespec : [CLASS_S] PACKED ARRAY [$l3..$u3:INTEGER] OF CHAR := %IMMED 0;
	VAR resultant_filespec : [CLASS_S,VOLATILE] PACKED ARRAY [$l4..$u4:INTEGER] OF CHAR := %IMMED 0;
	recall_size : $UBYTE := %IMMED 0) : INTEGER; EXTERNAL;

[ASYNCHRONOUS] FUNCTION smg$begin_pasteboard_update (
	pasteboard_id : UNSIGNED) : INTEGER; EXTERNAL;
 

[ASYNCHRONOUS] FUNCTION smg$create_virtual_display (
	number_of_rows : INTEGER;
	number_of_columns : INTEGER;
	VAR display_id : [VOLATILE] UNSIGNED;
	display_attributes : UNSIGNED := %IMMED 0;
	video_attributes : UNSIGNED := %IMMED 0;
	character_set : UNSIGNED := %IMMED 0) : INTEGER; EXTERNAL;

[ASYNCHRONOUS] FUNCTION smg$delete_virtual_display (
	display_id : UNSIGNED) : INTEGER; EXTERNAL;
 

[ASYNCHRONOUS] FUNCTION smg$end_pasteboard_update (
	pasteboard_id : UNSIGNED) : INTEGER; EXTERNAL;
 

[ASYNCHRONOUS] FUNCTION smg$erase_chars (
	display_id : UNSIGNED;
	number_of_characters : INTEGER;
	start_row : INTEGER;
	start_column : INTEGER) : INTEGER; EXTERNAL;

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

[ASYNCHRONOUS] FUNCTION smg$move_virtual_display (
	display_id : UNSIGNED;
	pasteboard_id : UNSIGNED;
	pasteboard_row : INTEGER;
	pasteboard_column : INTEGER;
	top_display_id : UNSIGNED := %IMMED 0) : INTEGER; EXTERNAL;

[ASYNCHRONOUS] FUNCTION smg$paste_virtual_display (
	display_id : UNSIGNED;
	pasteboard_id : UNSIGNED;
	pasteboard_row : INTEGER;
	pasteboard_column : INTEGER;
	top_display_id : UNSIGNED := %IMMED 0) : INTEGER; EXTERNAL;

[ASYNCHRONOUS] FUNCTION smg$put_chars (
	display_id : UNSIGNED;
	text : [CLASS_S] PACKED ARRAY [$l2..$u2:INTEGER] OF CHAR;
	start_row : INTEGER := %IMMED 0;
	start_column : INTEGER := %IMMED 0;
	flags : UNSIGNED := %IMMED 0;
	rendition_set : UNSIGNED := %IMMED 0;
	rendition_complement : UNSIGNED := %IMMED 0;
	character_set : UNSIGNED := %IMMED 0) : INTEGER; EXTERNAL;

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

[ASYNCHRONOUS] FUNCTION smg$repaint_screen (
	pasteboard_id : UNSIGNED) : INTEGER; EXTERNAL;

[ASYNCHRONOUS] FUNCTION smg$repaste_virtual_display (
	display_id : UNSIGNED;
	pasteboard_id : UNSIGNED;
	pasteboard_row : INTEGER;
	pasteboard_column : INTEGER;
	top_display_id : UNSIGNED := %IMMED 0) : INTEGER; EXTERNAL;

[ASYNCHRONOUS] FUNCTION smg$set_cursor_abs (
	display_id : UNSIGNED;
	start_row : INTEGER := %IMMED 0;
	start_column : INTEGER := %IMMED 0) : INTEGER; EXTERNAL;

{external functions end}

{verb garbage begin}

[asynchronous,external]
function cli$present (
        inval: [class_s,volatile] packed array [$l1..$u1:integer] of char):
unsigned; external;
 
[asynchronous,external]
function cli$get_value (
        inval: [class_s,volatile] packed array [$l1..$u1:integer] of char;
        var outval: [class_s] char;
        var outlen: unsigned := %immed 0):
unsigned; external;

{verb garbage end}


function strint (b:string:='0'):integer;

var
  a : integer;

begin
  a := 0;
  for loop := length (b) downto 1 do
    if (ord(b[loop]) > 47) and (ord(b[loop]) < 58) then
      a := a+( (ord(b[loop])-48) * (10**(length(b)-loop)) );
  strint := a;
end;

function intstr (a:integer):short; {good only form numbers less than 10000}

var
  res   : integer;
  resc  : short;

begin
  resc := ' ';
  if a = 0 then
    loop2 := 1
  else
    loop2 := trunc (ln(a)/ln(10))+1;

  for loop := loop2 downto 1 do
    begin
    res :=  (a mod (10**loop))-(a mod (10**(loop-1)));
    res := res div (10**(loop-1));
    resc[4-loop+1] := chr (48+res);
  end;
  intstr := resc
end;

function center (a : vshort):vshort;

var
  left  : integer;
  right : integer;
  b     : vshort;
  c     : integer;
  d     : integer;

begin
  b := ' ';
  left := 0;
  right := 0; {string length}
  repeat
   left := left + 1;
  until not (a[left] = chr(32)) or (left = 19);
  left := left - 1;
  if not ((left = 18) and (a[left+1] = chr(32))) then
    begin
    repeat
     right := right + 1;
    until not (a[20-right] = chr(32));
    right := right - 1;
    c := trunc ((left+right)/2);
    for d := left+1 to 19-right do
      b[d-left+c] := a[d];
  end;
  center := b;
end;

procedure verify;

var
  yesno     : unsigned;

begin
  loop := 1;
  smg$create_virtual_display (3,18,yesno,smg$m_border);
  smg$paste_virtual_display (yesno,pasty,round((sheight)/2),round((swidth-14)/2));
  smg$label_border(yesno,'LOOSE CHANGES???',,,smg$m_bold);
  repeat
    smg$begin_pasteboard_update (pasty);
    if loop = 1 then
      begin
      smg$put_chars (yesno,'  NO!  ',2,2,,smg$m_reverse);
      smg$put_chars (yesno,'  yes  ',2,11);
    end;
    if loop = 2 then
      begin
      smg$put_chars (yesno,'  NO!  ',2,2);
      smg$put_chars (yesno,'  yes  ',2,11,,smg$m_reverse);
    end;
    smg$end_pasteboard_update (pasty);
    smg$read_keystroke (keyboard,lastkey,,,);
    if lastkey = smg$k_trm_up then loop := loop-1;
    if lastkey = smg$k_trm_down then loop := loop+1;
    if lastkey = smg$k_trm_left then loop := loop-1;
    if lastkey = smg$k_trm_right then loop := loop+1;
    if loop < 1 then loop := 2;
    if loop > 2 then loop := 1;
  until (lastkey = smg$k_trm_ctrlm);
  if loop = 1 then
    NOWRITE := False
  else
    NOWRITE := True;
  smg$delete_virtual_display (yesno);
end;

procedure writefile;

var
  fileout   : text;
  backup    : varying [100] of char;

begin
  if AUTOSAVE then
  begin
    backup := filename+'bkup';
    open (fileout,backup,history:=unknown,error:=continue);
    backup := filename+'bkup';
    AUTOSAVE := False;
  end
  else
    open (fileout,filename,history:=new,error:=continue);
  rewrite (fileout);
  writeln (fileout,muno);
  for loop := 1 to sheight do
    begin
    for loop2 := 1 to swidth do
      if screen [loop2,loop] then
        write (fileout,'#')
      else
        write (fileout,' '); 
    writeln (fileout);
  end;
  writeln (fileout,title[1]);
  writeln (fileout,title[2]);
  close (fileout);
end;

procedure readfile;

var
  a         : varying [1] of char;
  filein    : text;

begin
  open (filein,filename,history:=unknown,error:=continue);
  reset (filein);
  smg$begin_pasteboard_update (pasty);
  if status (filein) = 0 then
    begin
    readln (filein,muno);
    for loop := 1 to sheight do
      begin
      for loop2 := 1 to swidth do
        begin
        read (filein,a);
        if a = '#' then
          begin
          smg$put_chars (display,wallseg,loop,loop2);
          screen [loop2,loop] := True;
        end
      end;
      readln (filein);
    end;
    readln (filein,title[1]);
    readln (filein,title[2]);
    close (filein);
  end;
  smg$end_pasteboard_update (pasty);
end;

procedure titlescreen;

var
  tdisp  : unsigned;

begin
  loop2 := 1;
  loop := 1;
  smg$create_virtual_display(2,length(title[1]),tdisp,smg$m_border);
  smg$paste_virtual_display(tdisp,pasty,(round((sheight-2)/2))+2,(round((swidth-19)/2)+2),);
  smg$label_border(tdisp,'TITLE',,,smg$m_bold);
  smg$put_line(tdisp,title[1],1);
  smg$put_line(tdisp,title[2],1);
  smg$set_cursor_abs (tdisp,1,1);
  repeat
    if lastkey = smg$k_trm_ctrlm then
      begin
      smg$set_cursor_abs (tdisp,2,1);
      loop := 1;
      loop2 := loop2 + 1;
    end;
    smg$read_keystroke(keyboard,lastkey,,);
    smg$begin_pasteboard_update (pasty);
    if (lastkey > smg$k_trm_us) and (lastkey < smg$k_trm_delete) then
      begin
      if  not (loop > length(title[loop2])) then title[loop2,loop] := chr(lastkey);
      loop := loop + 1;
      if loop > length(title[loop2])+1 then loop := length(title[loop2])+1;
    end;
    if (lastkey = smg$k_trm_delete) or (lastkey = smg$k_trm_ctrlh) then
      begin
      if (loop-1) > 0 then title[loop2,loop-1] := chr(32);
      loop := loop - 1;
      if loop < 1 then loop := 1;
    end;
    if (lastkey = smg$k_trm_right) then
      begin
      loop := loop + 1;
      if loop > length(title[loop2])+1 then loop := length(title[loop2])+1;
    end;
    if (lastkey = smg$k_trm_left) then
      begin
      loop := loop - 1;
      if loop < 1 then loop := 1;
    end;
    smg$put_chars (tdisp,title[loop2],loop2,1,smg$m_erase_to_eol);
    smg$end_pasteboard_update (pasty);
    smg$set_cursor_abs (tdisp,loop2,loop);
  until (loop2 = 2) and (lastkey = smg$k_trm_ctrlm);
  title[1] := center(title[1]);
  title[2] := center(title[2]);
  smg$delete_virtual_display(tdisp);
end;

procedure getlevel;

begin
  write (chr(27),'<',chr(27),'[1;1f',chr(27),'[J');
  write (chr(27),'[9;30H use cursor keys to');
  write (chr(27),'[10;30Hselect level to edit');
  write (chr(27),'[14;30HHit Return when done');
  write (chr(27),'[15;30HHit Q to exit editor');
  repeat
    if (lastkey = smg$k_trm_ctrll) or (lastkey = smg$k_trm_ctrlw) then
    begin
      write (chr(27),'<',chr(27),'[1;1f',chr(27),'[J');
      write (chr(27),'[9;31Huse cursor keys to');
      write (chr(27),'[10;30Hselect level to edit');
      write (chr(27),'[14;30HHit Return when done');
      write (chr(27),'[15;30HHit Q to exit editor');
    end;
    if (filen - 1) > 0 then
      write (chr(27),'[11;39H',filen-1:1,' ')
    else
      write (chr(27),'[11;39H ');
    write (chr(27),'[7m',chr(27),'[12;38H ',filen:1,' ',chr(27),'[0m ');
    if (filen + 1) < 100 then
      write (chr(27),'[13;39H',filen+1:1,' ')
    else
      write (chr(27),'[13;39H   ');
    writeln;
    smg$read_keystroke(keyboard,lastkey,,);
    if lastkey = smg$k_trm_up then filen := filen-1;
    if lastkey = smg$k_trm_down then filen := filen+1;
    if lastkey = smg$k_trm_left then filen := filen-1;
    if lastkey = smg$k_trm_right then filen := filen+1;
    if filen < 1 then filen := 1;
    if filen > 99 then filen := 99;
  until (lastkey = smg$k_trm_uppercase_q) or (lastkey = smg$k_trm_lowercase_q) or (lastkey = smg$k_trm_ctrlm);
  if (lastkey = smg$k_trm_uppercase_q) or (lastkey = smg$k_trm_lowercase_q) then QUIT := True;
  if filen > 9 then
    filename := prefix+'level'+substr (intstr(filen),3,2)+'.txt'
  else
    filename := prefix+'level'+substr (intstr(filen),4,1)+'.txt';
  writeln (chr(27),'<',chr(27),'[1;1f',chr(27),'[J');
end;

procedure copy;

var
  mover     : unsigned;
  newx      : integer;
  newy      : integer;
  prev      : unsigned;

begin
  smg$put_chars (stat,'Now move box to any position, ENTER when done, ^P to preview, F to cancel...',1,1); 
  newx := leftx;
  newy := lefty;
  if moveb then
    smg$create_virtual_display(righty-lefty+1,rightx-leftx+1,mover,smg$m_border)
  else
    smg$create_virtual_display(righty-lefty+1,rightx-leftx+1,mover,);
  smg$paste_virtual_display(mover,pasty,2+newy,1+newx);
  smg$begin_pasteboard_update (pasty);
  for loop := lefty to righty do
    for loop2 := leftx to rightx do
      if temp [loop2,loop] then
        begin
        if moveb then
          smg$put_chars (mover,wallseg,loop-lefty+1,loop2-leftx+1)
        else
          smg$put_chars (mover,wallseg,loop-lefty+1,loop2-leftx+1,,smg$m_bold);
      end;
  smg$end_pasteboard_update (pasty);

  repeat
    smg$read_keystroke(keyboard,lastkey,,);
    if lastkey = smg$k_trm_ctrlp then {preview screen}
      begin
      smg$begin_pasteboard_update (pasty);
      smg$repaste_virtual_display(display,pasty,3,2);
      smg$create_virtual_display(righty-lefty+1,rightx-leftx+1,prev,);
      smg$paste_virtual_display(prev,pasty,2+newy,1+newx,);
      for loop := leftx to rightx do
        for loop2 := lefty to righty do
          if temp [loop,loop2] then
            smg$put_chars (prev,wallseg,loop2-lefty+1,loop-leftx+1);
      smg$end_pasteboard_update (pasty);
      smg$read_keystroke(keyboard,lastkey,,);
      smg$begin_pasteboard_update (pasty);
      smg$delete_virtual_display(prev);
      smg$repaste_virtual_display(mover,pasty,2+newy,1+newx);
      smg$end_pasteboard_update (pasty);
    end;
    if (lastkey = smg$k_trm_ctrll) or (lastkey = smg$k_trm_ctrlw) then smg$repaint_screen (pasty);
    if lastkey = smg$k_trm_up then newy := newy-1;
    if lastkey = smg$k_trm_down then newy := newy+1;
    if lastkey = smg$k_trm_left then newx := newx-1;
    if lastkey = smg$k_trm_right then newx := newx+1;
    if newx < 1 then newx := 1;
    if newx > swidth-(rightx-leftx) then newx := swidth-(rightx-leftx);
    if newy < 1 then newy := 1;
    if newy > sheight-(righty-lefty) then newy := sheight-(righty-lefty);
    smg$move_virtual_display(mover,pasty,2+newy,1+newx);
  until (lastkey = smg$k_trm_enter) or (lastkey = smg$k_trm_uppercase_f) or (lastkey = smg$k_trm_lowercase_f);
  smg$delete_virtual_display(mover);
  smg$erase_display(stat);
  smg$put_chars (stat,'Press control M for help...',1,1);
{paste contents}
  if not ((lastkey = smg$k_trm_uppercase_f) or (lastkey = smg$k_trm_lowercase_f)) then
    begin
    smg$begin_pasteboard_update (pasty);
    for loop := leftx to rightx do
      for loop2 := lefty to righty do
        begin
        if temp [loop,loop2] then
          begin
          screen [loop-leftx+newx,loop2-lefty+newy] := True;
          smg$put_chars (display,wallseg,loop2-lefty+newy,loop-leftx+newx);
          end
        else
          begin
          screen [loop-leftx+newx,loop2-lefty+newy] := False;
          smg$put_chars (display,' ',loop2-lefty+newy,loop-leftx+newx);
        end;
      end;
    screen [round(swidth/2),round(sheight/2)] := False;
    smg$end_pasteboard_update (pasty);
  end;
end;

procedure move; {this is a mess, I know, but hell: It works}

var
  newx      : integer;
  newy      : integer;
  select    : array [1..swidth] of liner;

begin
  smg$put_chars(stat,'Select box with arrow keys, press ENTER when done...',1,1);
  for loop := 1 to swidth do
    for loop2 := 1 to sheight do
      begin
      select [loop,loop2] := False;
      temp [loop,loop2] := screen [loop,loop2];
    end;
  leftx := x;
  lefty := y;
  rightx := x;
  righty := y;
  select [leftx,lefty] := True;

  if screen [leftx,lefty] then
    smg$put_chars(display,wallseg,lefty,leftx,,smg$m_reverse)
  else
    smg$put_chars(display,' ',lefty,leftx,,smg$m_reverse);
{select box}
  repeat
    smg$set_cursor_abs (display,lefty,leftx);
    smg$read_keystroke(keyboard,lastkey,,);
    if (lastkey = smg$k_trm_ctrll) or (lastkey = smg$k_trm_ctrlw) then smg$repaint_screen (pasty);
    if lastkey = smg$k_trm_up then righty := righty-1;
    if lastkey = smg$k_trm_down then righty := righty+1;
    if lastkey = smg$k_trm_left then rightx := rightx-1;
    if lastkey = smg$k_trm_right then rightx := rightx+1;
    if righty < lefty then
      begin
      lastkey := 0;
      righty := lefty;
    end;
    if rightx < leftx then
      begin
      lastkey := 0;
      rightx := leftx;
    end;
    if righty > sheight then righty := sheight;
    if rightx > swidth then rightx := swidth;

    if lastkey = smg$k_trm_up then {righty decreased}
      begin
      smg$begin_pasteboard_update (pasty);
      for loop := leftx to rightx do
         begin
         if temp [loop,righty+1] then
           smg$put_chars (display,wallseg,righty+1,loop)
         else
           smg$put_chars (display,' ',righty+1,loop);
         select [loop,righty+1] := False;
      end;
      smg$end_pasteboard_update (pasty);
    end;
 
    if lastkey = smg$k_trm_down then {righty increased}
      begin
      smg$begin_pasteboard_update (pasty);
      for loop := leftx to rightx do
         begin
         if temp [loop,righty] then
           smg$put_chars (display,wallseg,righty,loop,,smg$m_reverse)
         else
           smg$put_chars (display,' ',righty,loop,,smg$m_reverse);
         select [loop,righty] := True;
      end;
      smg$end_pasteboard_update (pasty);
    end;
 
    if lastkey = smg$k_trm_left then {righty decreased}
      begin
      smg$begin_pasteboard_update (pasty);
      for loop := lefty to righty do
         begin
         if temp [rightx+1,loop] then
             smg$put_chars (display,wallseg,loop,rightx+1)
         else
           smg$put_chars (display,' ',loop,rightx+1);
         select [rightx+1,loop] := False;
      end;
      smg$end_pasteboard_update (pasty);
    end;
 
    if lastkey = smg$k_trm_right then {righty increased}
      begin
      smg$begin_pasteboard_update (pasty);
      for loop := lefty to righty do
         begin
         if temp [rightx,loop] then
           smg$put_chars (display,wallseg,loop,rightx,,smg$m_reverse)
         else
           smg$put_chars (display,' ',loop,rightx,,smg$m_reverse);
         select [rightx,loop] := True;
      end;
      smg$end_pasteboard_update (pasty);
    end;

  until lastkey = smg$k_trm_enter;

{erase highlight box, and everything in it}
  smg$end_pasteboard_update (pasty);
  smg$erase_display(stat);
  smg$begin_pasteboard_update (pasty);
    for loop2 := lefty to righty do
      for loop := leftx to rightx do
        begin
        smg$put_chars (display,' ',loop2,loop);
        screen [loop,loop2] := False;
      end;
  smg$end_pasteboard_update (pasty);

{use copy to put it somewhere now....}
  copy;
end;

procedure print;

begin
  direction := 0;
  smg$put_chars (stat,'Press control M for help...',1,1);
  repeat
    if lastdir = direction then
    begin
      if direction = smg$k_trm_up then Y := Y-1;
      if direction = smg$k_trm_down then Y := Y+1;
      if direction = smg$k_trm_left then X := X-1;
      if direction = smg$k_trm_right then X := X+1;
      if X > swidth then X := 1;
    end
    else
      begin
      if direction = smg$k_trm_up then smg$put_chars (display,'^',round(sheight/2),round(swidth/2));
      if direction = smg$k_trm_down then smg$put_chars (display,'v',round(sheight/2),round(swidth/2));
      if direction = smg$k_trm_left then smg$put_chars (display,'<',round(sheight/2),round(swidth/2));
      if direction = smg$k_trm_right then smg$put_chars (display,'>',round(sheight/2),round(swidth/2));
    end;
    if Y > sheight then Y := 1;
    if X < 1 then X := swidth;
    if Y < 1 then Y := sheight;
    lastdir := direction;
    smg$set_cursor_abs (display,Y,X);
    t_time_o := t_time;
    smg$read_keystroke(keyboard,lastkey,,);
    time (t_time);
    if not (substr (t_time,1,5) = substr (t_time_o,1,5)) and AUTO then
      begin
      AUTOSAVE := True;
      writefile;
    end;
    if (lastkey >= smg$k_trm_up) and (lastkey <= smg$k_trm_right) then direction := lastkey;
    if (lastkey  = smg$k_trm_space) and
    not ((y = round(sheight/2)) and (x = round(swidth/2))) then
      begin
      screen [X,Y] := True;
      smg$put_chars (display,wallseg,Y,X);
    end;
    if ((lastkey  = smg$k_trm_delete) or (lastkey = smg$k_trm_ctrlh)) and
    not ((y = round(sheight/2)) and (x = round(swidth/2))) then
      begin
      screen [X,Y] := False;
      smg$erase_chars (display,1,Y,X);
    end;
    if lastkey = smg$k_trm_ctrli then
      begin
      smg$erase_display (stat);
      if muno < 10 then
        smg$put_chars(stat,'Number of Shrooms ('+substr(intstr(muno),4,1)+') ',1,1)
      else
        smg$put_chars(stat,'Number of Shrooms ('+substr(intstr(muno),3,2)+') ',1,1);
      readln (null);
      muno := strint (null);
      if muno < 1 then muno := 1;
      if muno > 20 then muno := 20;
      smg$erase_display (stat);
      smg$put_chars (stat,'Press control M for help...',1,1);
    end;
    if lastkey = smg$k_trm_ctrlm then
      begin
      smg$create_virtual_display(11,60,helpdis,smg$m_border);
      smg$paste_virtual_display(helpdis,pasty,round(sheight/2)-3,round(swidth/2)-28,);  
      smg$put_line(helpdis,'  Period     :  to select left upper of box, used to copy');
      smg$put_line(helpdis,'  control N  :  to name or title the level');
      smg$put_line(helpdis,'  control I  :  to select number of mushrooms for level');
      smg$put_line(helpdis,'  control D  :  to move a duplicate of buffer, use with .');
      smg$put_line(helpdis,'  control M  :  to get this screen (more)');
      smg$put_line(helpdis,'  control Z  :  to save edited level to file');
      smg$put_line(helpdis,'  Q or q     :  to quit (loose al changes)');
      smg$put_line(helpdis,'  Arrow Keys :  to change arrow direction');
      smg$put_line(helpdis,'  Space      :  to draw walls in direction of arrow');
      smg$put_line(helpdis,'  Delete     :  to erase walls in direction of arrow');
      smg$put_line(helpdis,'        press any key to go back to editor...',,smg$m_blink);
      smg$read_keystroke(keyboard,lastkey,,);
      smg$delete_virtual_display(helpdis);
    end;
    if lastkey = smg$k_trm_ctrln then titlescreen;
    if (lastkey = smg$k_trm_ctrll) or (lastkey = smg$k_trm_ctrlw) then smg$repaint_screen (pasty);
    if (lastkey = smg$k_trm_period) or (lastkey = smg$k_trm_dot) then move;
    if lastkey = smg$k_trm_ctrld then copy;
    if (lastkey = smg$k_trm_uppercase_q) or (lastkey = smg$k_trm_lowercase_q) then verify;
  until (lastkey = smg$k_trm_ctrlz) or nowrite;
  AUTOSAVE := False;
  if not NOWRITE then writefile;
  NOWRITE := False;
  if AUTO then lib$delete_file (filename+'bkup;*');
end;

begin
  if (odd(cli$present('BRIGHT'))) then
    MOVEB := False
  else
    MOVEB := True;
  if (odd(cli$present('NOBACKUP'))) then
    AUTO := False
  else
    AUTO := True;
  if (odd(cli$present('WALL'))) then
    clistat := cli$get_value('WALL',wallseg)
  else
    wallseg := '|';
  if (odd(cli$present('DIRECTORY'))) then
    clistat := cli$get_value('DIRECTORY',%descr prefix)
  else
    prefix := prefixd;
  title [1] := ' ';
  title [2] := ' ';
  Quit := False;
  filen := 1;
  smg$create_virtual_keyboard(keyboard,,,);
  smg$create_pasteboard(pasty,,,); 
  smg$create_virtual_display(1,80,stat);
  smg$paste_virtual_display(stat,pasty,1,1);
  repeat
    smg$create_virtual_display(sheight,swidth,display,smg$m_border);
    muno := 5;
    for loop := 1 to sheight do
      for loop2 := 1 to swidth do
        screen [loop2,loop] := False;
    X := 1;
    Y := 1;
    getlevel;
    if not QUIT then
      begin
      smg$paste_virtual_display(display,pasty,3,2,);  
      smg$put_chars (display,'^',round(sheight/2),round(swidth/2));
      readfile;
      print;
      smg$delete_virtual_display(display);
    end;
  until QUIT;
end.
