{ This program was written by Richard Wicks of the University of Buffalo }
{ permission to copy, duplicate, spindle or mutilate this program is     }
{ hereby explicitly granted provided that this header remains intact.    }
{ Any other use constitutes copy right infiringement an will be dealt    }
{ in accordance with the full extent of the law.                         }

{ questions, comments, etc. should be directed to either:                }
{ V128LL9E @ UBVMS.CC.BUFFALO.EDU  *or*  MASRICH @ UBVMS.CC.BUFFALO.EDU  }

[inherit ('sys$library:starlet')]

program SHROOM (input, output);

const
  swidth   = 78; {max 78}
  sheight  = 21; {max 21}
  middle   = round (swidth/2); {for status display}
  rights   = swidth+2; {for status display}
  buf      = 300;
  lastlev  = 21; {this is the last level + 1 if you want more, change this #}
  prefixd  = 'disk$userdisk1:[mas0.maslib.games.shroom]';
             {this is the directory all files are kept in, change it if you   }
             {don't want to have to use the /directory qualifier all the time!} 

type
{foreign variable types}
  $UBYTE = [BYTE] 0..255;
  $UWORD = [WORD] 0..65535;

{local variable types}
  long     = packed array [1..30] of char;
  short    = packed array [1..4] of char;
  screen   = array [0..23] of boolean;
  string   = varying [80] of char;
  packed12 = packed array [1..12] of char;
  packed30 = packed array [1..30] of char;

  rstore   = record
    user  : [key(0)] packed12;
    level : integer;
    score : integer;
    lives : integer;
    x     : integer; {x of head of worm}
    y     : integer; {y of head of worm}
    mushx : integer; {x of shroom location}
    mushy : integer; {y of shroom location}
    cur   : integer; {current mushroom}
    point : integer; {pointer for stack of histx, and histy, points to tail}
    last  : char; {only used when saving, uses l,r,u,d for direction}
    lengw : integer; {length of worm}
    histx : array [1..buf] of integer;{all the x segments of the worm on screen}
    histy : array [1..buf] of integer;{all the y segments of the worm on screen}
  end;

var
{bogus variables}
  seed     : unsigned; {for random number generation}
  randomn  : real;
  show     : boolean; {to control showing of title, only want once per level}
  stored   : boolean; {for control when getting back old game}
  datestr  : string;
  loop     : integer;
  loop2    : integer;

{variables needed for the screen}
  keyboard : unsigned;
  pasty    : unsigned;
  display  : unsigned;
  stat     : unsigned;

{option variables}
  mapkey   : packed array [1..4] of char; {used for retrieving directional keys}
  clistat  : unsigned; {for the verb}
  wormseg  : char; {character of wormsegments, def o}
  wallseg  : char; {character of walls, def |}
  mushseg  : char; {character of shrooms, def @}
  prefix   : varying [100] of char; {the directory everything is kept in}
  high     : varying [100] of char; {highscore filename}
  s_game   : varying [100] of char; {file name for save file of games}

{movement variables, defined from mapkey}
  up       : integer; {hold ordinal numbers of direction keys}
  down     : integer;
  left     : integer;
  right    : integer;

{real variables}
  filename : varying [100] of char; {filename of current level}
  DEAD     : boolean; {tell if you were killed in action}
  temp     : [word] 0..65535; {contains the last key hit}
  lastkey  : [word] 0..65535; {contains the last direction key hit}

{important variables}
  w        : rstore; {contains everything needed to save a game, and to play}
  wf       : file of rstore; {for saving all these goodies}
  muno     : integer; {orriginal number of mushrooms}
  bump     : array [0..79] of screen; {used to let program know what areas safe}

{foreign functions and routines begin}

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

[ASYNCHRONOUS] FUNCTION smg$repaint_screen (
	pasteboard_id : UNSIGNED) : INTEGER; EXTERNAL;

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

[ASYNCHRONOUS] FUNCTION smg$draw_rectangle (
	display_id : UNSIGNED;
	start_row : INTEGER;
	start_column : INTEGER;
	end_row : INTEGER;
	end_column : INTEGER;
	rendition_set : UNSIGNED := %IMMED 0;
	rendition_complement : UNSIGNED := %IMMED 0) : INTEGER; EXTERNAL;

[ASYNCHRONOUS] FUNCTION smg$end_pasteboard_update (
	pasteboard_id : UNSIGNED) : INTEGER; EXTERNAL;

[ASYNCHRONOUS] FUNCTION smg$label_border (
	display_id : UNSIGNED;
	text : [CLASS_S] PACKED ARRAY [$l2..$u2:INTEGER] OF CHAR := %IMMED 0;
	position_code : UNSIGNED := %IMMED 0;
	units : INTEGER := %IMMED 0;
	rendition_set : UNSIGNED := %IMMED 0;
	rendition_complement : UNSIGNED := %IMMED 0;
	character_set : UNSIGNED := %IMMED 0) : INTEGER; EXTERNAL;

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

[ASYNCHRONOUS] FUNCTION smg$set_cursor_abs (
	display_id : UNSIGNED;
	start_row : INTEGER := %IMMED 0;
	start_column : INTEGER := %IMMED 0) : INTEGER; EXTERNAL;

[ASYNCHRONOUS] FUNCTION lib$date_time (
	VAR date_time_string : [CLASS_S,VOLATILE] PACKED ARRAY [$l1..$u1:INTEGER] OF CHAR) : INTEGER; EXTERNAL;

[ASYNCHRONOUS] FUNCTION lib$getjpi (
	item_code : INTEGER;
	VAR process_id : [VOLATILE] UNSIGNED := %IMMED 0;
	process_name : [CLASS_S] PACKED ARRAY [$l3..$u3:INTEGER] OF CHAR := %IMMED 0;
	%REF resultant_value : [VOLATILE,UNSAFE] ARRAY [$l4..$u4:INTEGER] OF $UBYTE := %IMMED 0;
	VAR resultant_string : [CLASS_S,VOLATILE] PACKED ARRAY [$l5..$u5:INTEGER] OF CHAR := %IMMED 0;
	VAR resultant_length : [VOLATILE] $UWORD := %IMMED 0) : INTEGER; EXTERNAL;

[ASYNCHRONOUS] FUNCTION lib$wait (
	seconds : SINGLE) : INTEGER; EXTERNAL;

[ASYNCHRONOUS] FUNCTION mth$random (
	VAR seed : [VOLATILE] UNSIGNED) : SINGLE; EXTERNAL;

{foreign functions and routines end}

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

function strint (b:string:= '0'):integer;

var
  a : integer;

begin
  a := 0;
  for loop := length (b) downto 1 do
    a := a+((ord(b[loop])-48)*(10**(length(b)-loop)));
  strint := a;
end;

function intstr (a:integer):short; {good only form numbers less than 10000}

var
  res   : integer;
  resc  : short;

begin
  resc := ' ';
  if a <= 0 then
  begin
    a := 0;
    loop2 := 1;
  end
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

procedure win;

var
  windis  : unsigned;

begin
  smg$create_virtual_display(2,23,windis,smg$m_border);
  smg$label_border(windis,'DUDE!');
  smg$paste_virtual_display(windis,pasty,2,round(swidth/2)-11);
  smg$put_line(windis,'    Cool, you won,',,smg$m_bold+smg$m_blink);
  smg$put_line(windis,'bonus = #lives left * 100');
  lib$wait (5);
  smg$delete_virtual_display(windis);
end;

procedure instruct;

var
  helpdis  : unsigned;

begin
  smg$create_virtual_display(18,45,helpdis,smg$m_border);
  smg$label_border(helpdis,'Instructions');
  smg$paste_virtual_display(helpdis,pasty,round(sheight/2)-7,round(swidth/2)-22);
  smg$put_line(helpdis,'The object of the game is to eat as many of');
  smg$put_line(helpdis,'shrooms ('+mushseg+') without running into any of the');
  smg$put_line(helpdis,'obstacles.    * obstacles are *');
  smg$put_line(helpdis,'                  walls ('+wallseg+')');
  smg$put_line(helpdis,'                  house (^)');
  smg$put_line(helpdis,'                 yourself ('+wormseg+')',2);
  smg$put_line(helpdis,'After you have eaten every shroom ('+mushseg+') another');
  smg$put_line(helpdis,'level will be loaded.  There are 20 levels');
  smg$put_line(helpdis,'total, so you may want to use ^Z (save).   ');
  smg$put_line(helpdis,'Now go get stoned!',2);
  smg$put_line(helpdis,'for more detailed instructions refer to the');
  smg$put_line(helpdis,'help file (maslib help shroom.)  They''re');
  smg$put_line(helpdis,'several features within this game that cannot');
  smg$put_line(helpdis,'easily be discussed here...',2);
  smg$put_line(helpdis,'           Hit a key to continue..');
  smg$read_keystroke(keyboard,temp,,);
  temp := smg$k_trm_lowercase_i;
  smg$delete_virtual_display(helpdis);
end;

procedure options; {note: SMG$MENU SUCKS THE DOG! *sigh*}

var
  optdis   : unsigned;
  position : integer;
  a        : array [1..9] of char;

begin
  writeln (chr(27),'[?25h');
  for position := 1 to 9 do
    a[position] := chr(32);
  a[1] := wallseg;
  a[2] := mushseg;
  a[3] := wormseg;
  if not (ord (a[4]) > smg$k_trm_delete) then
    begin
    a[4] := chr(up);
    a[5] := chr(left);
    a[6] := chr(right);
    a[7] := chr(down);
  end
  else
    begin
    a[4] := chr(32);
    a[5] := chr(32);
    a[6] := chr(32);
    a[7] := chr(32);
  end;

  if a[4] = chr (smg$k_trm_up) then a[8] := '*';
  if a[4] = chr (smg$k_trm_kp8) then a[9] := '*';
{end keyboard predefined definitions}
  smg$create_virtual_display(9,53,optdis,smg$m_border);
  smg$paste_virtual_display(optdis,pasty,round(sheight/2)-3,round(swidth/2)-25,);
  smg$label_border(optdis,'Options');
  smg$put_chars(optdis,'UP/DOWN keys to change selections',1,1,,smg$m_bold);
  smg$put_chars(optdis,'    Wall character   :',4,1);
  smg$put_chars(optdis,'    Shroom character :',5,1);
  smg$put_chars(optdis,'    Worm Character   :',6,1);
  smg$put_chars(optdis,'Use Keypad and Return. ^Z to exit',9,1,,smg$m_bold);
  smg$draw_rectangle(optdis,1,40,7,46);
  smg$draw_rectangle(optdis,3,35,5,51);
  smg$put_chars(optdis,'  (arrow keys) ',8,36);
  smg$put_chars(optdis,'(numeric keypad) ',9,36);
  position := 1;
  repeat
    smg$begin_pasteboard_update (pasty);
    smg$put_chars (optdis,a[1],4,24);
    smg$put_chars (optdis,a[2],5,24);
    smg$put_chars (optdis,a[3],6,24);
    smg$put_chars (optdis,a[4],2,43);
    smg$put_chars (optdis,a[5],4,37);
    smg$put_chars (optdis,a[6],4,49);
    smg$put_chars (optdis,a[7],6,43);
    smg$put_chars (optdis,a[8],8,35);
    smg$put_chars (optdis,a[9],9,35);
    if position = 8 then
      begin
      smg$put_chars(optdis,'  (arrow keys) ',8,36,,smg$m_bold);
    end
    else
      smg$put_chars(optdis,'  (arrow keys) ',8,36);
    if position = 9 then
      begin
      smg$put_chars(optdis,'(numeric keypad) ',9,36,,smg$m_bold);
    end
    else
      smg$put_chars(optdis,'(numeric keypad) ',9,36);
    smg$end_pasteboard_update (pasty);
    if position = 1 then smg$set_cursor_abs (optdis,4,24);
    if position = 2 then smg$set_cursor_abs (optdis,5,24);
    if position = 3 then smg$set_cursor_abs (optdis,6,24);
    if position = 4 then smg$set_cursor_abs (optdis,2,43);
    if position = 5 then smg$set_cursor_abs (optdis,4,37);
    if position = 6 then smg$set_cursor_abs (optdis,4,49);
    if position = 7 then smg$set_cursor_abs (optdis,6,43);
    if position = 8 then smg$set_cursor_abs (optdis,8,43);
    if position = 9 then smg$set_cursor_abs (optdis,9,43);
    smg$read_keystroke(keyboard,temp,,);
    if (temp > smg$k_trm_space) and (temp < smg$k_trm_delete) or (temp = smg$k_trm_ctrlm) then
      begin
      if not ((position = 9) or (position = 8)) then
      begin
        if not (temp = smg$k_trm_ctrlm) then a[position] := chr(temp);
        if not (temp = smg$k_trm_ctrlm ) and ((position > 3) and (position < 8)) then
          begin
          a[8] := ' ';
          a[9] := ' ';
        end;
      end
      else
        begin
        a[4] := ' ';
        a[5] := ' ';
        a[6] := ' ';
        a[7] := ' ';
        if position = 8 then
          begin
          a[8] := '*';
          a[9] := ' ';
        end
        else
          begin
          a[8] := ' ';
          a[9] := '*';
        end;          
      end;
    end;
    if temp = smg$k_trm_down then position := position + 1;
    if temp = smg$k_trm_up then position := position - 1;
    if position > 9 then position := 1;
    if position < 1 then position := 9;
  until temp = smg$k_trm_ctrlz;

{return to the program with new values....}
 wallseg := a[1];
  mushseg := a[2];
  wormseg := a[3];
  up := ord(a[4]);
  left := ord(a[5]);
  right := ord(a[6]);
  down := ord(a[7]);
  if a[8] = '*' then
    begin
    up := smg$k_trm_up;
    left := smg$k_trm_left;
    right := smg$k_trm_right;
    down := smg$k_trm_down;
  end;
  if a[9] = '*' then
    begin
    up := smg$k_trm_kp8;
    left := smg$k_trm_kp4;
    right := smg$k_trm_kp6;
    down := smg$k_trm_kp2;
  end;
  smg$delete_virtual_display (optdis);
  temp := smg$k_trm_lowercase_o;
  writeln (chr(27),'[?25l');
end; {if ANYBODY can make this routine significantly shorter, send it to me!}

procedure difficulty;

var
  diff     : integer;
  lev      : unsigned;

begin
  smg$create_virtual_display(6,14,lev,smg$m_border);
  smg$paste_virtual_display(lev,pasty,round(sheight/2)-2,round(swidth/2)-5,);
  smg$label_border(lev,'LEVEL');
  diff := 1;
  repeat
    smg$begin_pasteboard_update(pasty);
    smg$put_chars(lev,' easy       ',2,2);
    smg$put_chars(lev,' difficult  ',3,2);
    smg$put_chars(lev,' expert     ',4,2);
    smg$put_chars(lev,' impossible ',5,2);      
    if diff = 1 then smg$put_chars(lev,' easy       ',2,2,,smg$m_reverse);
    if diff = 2 then smg$put_chars(lev,' difficult  ',3,2,,smg$m_reverse);
    if diff = 3 then smg$put_chars(lev,' expert     ',4,2,,smg$m_reverse);
    if diff = 4 then smg$put_chars(lev,' impossible ',5,2,,smg$m_reverse);
    smg$end_pasteboard_update(pasty);
    smg$read_keystroke(keyboard,temp,,);
    if temp = smg$k_trm_up then diff := diff - 1;
    if temp = smg$k_trm_down then diff := diff + 1;
    if diff > 4 then diff := 1;
    if diff < 1 then diff := 4;
  until temp = smg$k_trm_ctrlm;
  smg$delete_virtual_display(lev);
  w.level := (diff-1)*5;
end;

procedure startup; {subprocedures: options, help, levels}

var
  start    : unsigned;
  select   : integer;

begin
  select := 1;
  smg$create_virtual_display(5,14,start,smg$m_border);
  smg$paste_virtual_display(start,pasty,round(sheight/2)-2,round(swidth/2)-5,);
  smg$label_border( start,'Select');
  repeat
    smg$begin_pasteboard_update (pasty);
    smg$put_chars(start,'Start Game!',2,2);
    smg$put_chars(start,'  Options  ',3,2);
    smg$put_chars(start,'   HELP!   ',4,2);
    if select = 1 then smg$put_chars(start,'Start Game!',2,2,,smg$m_reverse);
    if select = 2 then smg$put_chars(start,'  Options  ',3,2,,smg$m_reverse);
    if select = 3 then smg$put_chars(start,'   HELP!   ',4,2,,smg$m_reverse);
    smg$end_pasteboard_update (pasty);
    smg$read_keystroke(keyboard,temp,,);
    if temp = smg$k_trm_up then select := select - 1;
    if temp = smg$k_trm_down then select := select + 1;
    if select > 3 then select := 1;
    if select < 1 then select := 3;
    if (select = 2) and (temp = smg$k_trm_ctrlm) then options;
    if (select = 3) and (temp = smg$k_trm_ctrlm) then instruct;
  until (select = 1) and (temp = smg$k_trm_ctrlm);
  smg$delete_virtual_display (start);
end;

procedure center (var a : packed30);

var
  left     : integer;
  right    : integer;
  b        : packed30;
  c        : integer;
  d        : integer;

begin
  b := ' ';
  left := 0;
  right := 0; {string length}
  repeat
   left := left + 1;
  until not (a[left] = chr(32)) or (left = 30);
  left := left - 1;
  if not ((left = 29) and (a[left+1] = chr(32))) then
    begin
    repeat
     right := right + 1;
    until not (a[31-right] = chr(32));
    right := right - 1;
    c := trunc ((left+right)/2);
    for d := left+1 to 30-right do
      b[d-left+c] := a[d];
    a := b;
  end;
end;

procedure save; {save a game for later play}

begin
  smg$put_chars(stat,'Attempting to write to save file...',1,1,smg$m_erase_to_eol);
  s_game := prefix + 'saves.dat;';
  loop := 0;
  repeat
    loop := loop + 1;
    lib$wait (0.05);
    Open(wf,s_game,history:=unknown,
         access_method:=keyed,record_type:=fixed,organization:=indexed,
         sharing:=readwrite,error := continue)
  until (status (wf) = 0) or (loop = 100);
  if not (loop = 100) then 
    begin
    if lastkey    = up then w.last := 'u';
    if lastkey    = left then w.last := 'l';
    if lastkey    = down then w.last := 'd';  
    if lastkey    = right then w.last := 'r';
    if not ((lastkey = up) or (lastkey = left) or (lastkey = down) or (lastkey = right)) then w.last := '?';
    write (wf,w);
    close (wf);
    smg$put_chars (stat,'            Game has been successfully saved, see you next time                  ',1,1,,smg$m_blink+smg$m_reverse);
  end
  else
    smg$put_chars (stat,'             An error has occured!  Your game has been lost, sorry              ',1,1,,smg$m_blink+smg$m_reverse);
end;

procedure recall; {recall a game for current play}

var
  notify   : unsigned; 


begin
  s_game := prefix + 'saves.dat;';
  loop := 0;
  repeat
    loop := loop + 1;
    lib$wait(0.05);
    Open(wf,s_game,history:=unknown,
         access_method:=keyed,record_type:=fixed,organization:=indexed,
         sharing:=readwrite,error:=continue);
    until (status (wf) = 0) or (loop = 100);
  if not (loop=100) then
    begin
    repeat
      findk (wf,0,w.user,error := continue);
    until (status(wf) = 0);
    if not (UFB (wf)) then {i.e if there is a saved game}
      begin
      STORED := True;
      SHOW := False;
      w.score := wf^.score;
      w.lives := wf^.lives;
      w.x     := wf^.x;
      w.y     := wf^.y;
      w.mushx := wf^.mushx;
      w.mushy := wf^.mushy;
      w.cur   := wf^.cur;
      w.point := wf^.point;
      w.lengw := wf^.lengw;
      w.level := wf^.level;
      if wf^.last = 'u' then lastkey := up;
      if wf^.last = 'l' then lastkey := left;
      if wf^.last = 'r' then lastkey := right;
      if wf^.last = 'd' then lastkey := down;
      if wf^.last = '?' then lastkey := 1000;
      {delete old record; no cheating here!}
      delete (wf,error := continue);
      smg$create_virtual_display(2,39,notify,smg$m_border);
      smg$paste_virtual_display(notify,pasty,round(sheight/2)-1,round(swidth/2)-21,);
      smg$put_chars(notify,'You have a saved game, I retrieved it..',1,1);
      smg$put_chars(notify,'Go to [O]ptions or [S]tart? (def [S])',2,1);
      smg$read_keystroke(keyboard,temp,,);
      if (temp = smg$k_trm_uppercase_o) or (temp = smg$k_trm_lowercase_o) then options;
      smg$delete_virtual_display (notify);
      for loop := 1 to buf do {redraw worm}
        begin
        w.histx[loop] := wf^.histx[loop];
        w.histy[loop] := wf^.histy[loop]; 
        if not (w.histx[loop] = 0) and not (w.histy [loop] = 0) then
          begin
          smg$put_chars (display,wormseg,w.histy[loop],w.histx[loop]);
          bump [w.histx[loop],w.histy[loop]] := True;
        end;
      end;
      bump [round(swidth/2),round(sheight/2)] := True;
      smg$put_chars (display,'^',round(sheight/2),round(swidth/2));
      if lastkey = up then smg$put_chars(display,'^',w.y,w.x);
      if lastkey = down then smg$put_chars(display,'v',w.y,w.x);
      if lastkey = left then smg$put_chars(display,'<',w.y,w.x);
      if lastkey = right then smg$put_chars(display,'>',w.y,w.x);
    end;
    close (wf);
  end
  else
    begin
      smg$put_chars (stat,'          The save file could not be opened!  Possible corruption?              ',1,1,,smg$m_bold+smg$m_blink+smg$m_reverse);
      lib$wait(10);
      smg$put_chars (stat,'I will put you on level one anyhow....',1,1,smg$m_erase_to_eol);
      lib$wait(2);
      smg$erase_display(stat);
    end;
end;

procedure highscore; {this is a second attempt, using record format instead}
                     {this is spaghetti code, but the hell with it!}
const
  history  = 50; {how far back to log games & highscore}
                 {if you change this number: delete the highscore file!}
type
  rhigh    = record
    user   : packed12;
    score  : integer;
    alias  : packed30; {signature name}
    games  : integer;
    level  : integer;
  end;

var
{real variables}
  games    : integer;
  highdisp : unsigned; {screen variable}
  high_r   : array [1..history] of rhigh;
  player   : rhigh;
  high_f   : file of rhigh; {file variable}
  DEJAVU   : boolean; {checks to see if your old score is better than new}
  POST     : boolean; {tells if you got on the high score list}
  count    : integer; {see's how many in the top 10 you beat}

begin
  player.score := w.score;
  player.level := w.level;
  DEJAVU := False;
  POST := False;
  high := prefix + 'high.dat';
  loop := 0;
  repeat
    loop := loop + 1;
    lib$wait(0.05);
    open (high_f,high,history:=old,error:=continue);
  until (status (high_f) = 3) or (status (high_f) = 0) or (loop = 100);

  if not (loop = 100) then
    begin
    if status (high_f) = 3 then {if no existing file, create one}
      begin
      open (high_f,high,history:=new,error:=continue);
      rewrite (high_f);
      for loop := 1 to history do
        begin
        high_r[loop].score := 0;
        high_r[loop].games := 0;
        high_r[loop].level := 0;
        high_r[loop].alias := ' ';
        high_r[loop].user := ' ';
        write (high_f,high_r[loop]);
      end;
    end;
    player.games := 1;
    games := 1;

    reset (high_f);

    for loop := 1 to 30 do {initialize player.alias to null string}
      player.alias [loop] := chr(32);

    count := 0;
    for loop := 1 to history do {check to see if already on HS, add 1 to games}
      begin
      read (high_f,high_r[loop]);
      if (w.score > high_r[loop].score) and not (loop > 10) then
        count := count + 1;
      if high_r[loop].user = w.user then
        begin
        player.games := high_r[loop].games + 1;
        player.level := high_r[loop].level;
        player.score := high_r[loop].score;
        player.alias := high_r[loop].alias;
        games := high_r[loop].games + 1;
        if high_r[loop].score >= w.score then DEJAVU := True;
      end;
      if high_r[loop].score < w.score then POST := True;
    end;

    if not DEJAVU and POST and (count > 0) then
      POST := True
    else
      POST := False;

    if POST then
      begin
      close (high_f); {get the hell out so other people can put up their names}
      loop := 1;
      smg$create_virtual_display(5,30,highdisp,smg$m_border);
      smg$paste_virtual_display(highdisp,pasty,round((sheight-5)/2),round((swidth-30)/2),);
      smg$put_line (highdisp,'Hey You made it in the top 10!',2,smg$m_underline);
      smg$put_line (highdisp,'   Put in your name dude!',2,smg$m_blink);
      smg$put_line (highdisp,player.alias);
      smg$set_cursor_abs (highdisp,5,1);
      repeat
        smg$read_keystroke(keyboard,temp,,);
        smg$begin_pasteboard_update (pasty);
        if (temp > smg$k_trm_us) and (temp < smg$k_trm_delete) then
          begin
          if not (loop > 30) then player.alias [loop] := chr(temp);
          loop := loop + 1;
          if loop > 31 then loop := 31;
        end;
        if (temp = smg$k_trm_delete) or (temp = smg$k_trm_ctrlh) then
          begin
          if (loop-1) > 0 then player.alias [loop-1] := chr(32);
          loop := loop - 1;
          if loop < 1 then loop := 1;
        end;
        if (temp = smg$k_trm_right) then
          begin
          loop := loop + 1;
          if loop > 31 then loop := 31;
        end;
        if (temp = smg$k_trm_left) then
          begin
          loop := loop - 1;
          if loop < 1 then loop := 1;
        end;
      smg$put_chars (highdisp,player.alias,5,1);
      smg$end_pasteboard_update (pasty);
      smg$set_cursor_abs (highdisp,5,loop);
      until temp = smg$k_trm_ctrlm;
      center (player.alias);
      smg$delete_virtual_display(highdisp);
      repeat {reopen file to write}
        lib$wait(0.05);
        open (high_f,high,history:=old,error:=continue);
      until status (high_f) = 0;
      player.score := w.score;
      player.user  := w.user;
      player.level := w.level;
    end;
    player.user := w.user;

    reset (high_f);
    for loop := 1 to history do
      read (high_f,high_r[loop]);

    rewrite (high_f);
    loop := 0;
    repeat {write out higher scores, then his score}
      loop := loop + 1;
      if player.score > high_r[loop].score then
        write (high_f,player)
      else
        begin
        if not (high_r[loop].user = player.user) then
          write (high_f,high_r[loop]);
      end;
    until (loop = history) or (player.score > high_r[loop].score);

    for loop2 := loop to history do {finish off the rest}
      if not(player.user = high_r[loop2].user) then write (high_f,high_r[loop2]);

    reset (high_f); {now print out scores to screen}

    smg$create_virtual_display(14,54,highdisp,smg$m_border);
    smg$paste_virtual_display(highdisp,pasty,round((sheight-14)/2),round((swidth-54)/2),);
    smg$put_line (highdisp,'                  ...Psychedelic...',2,smg$m_blink);
    smg$put_line (highdisp,' score              alias              level account  ',2,smg$m_underline);
    for loop := 1 to 10 do
      begin
      read (high_f,player);
      smg$put_line (highdisp,intstr(player.score)+'    '+player.alias+intstr(player.level)+'   '+player.user,1);
    end;
    close (high_f);
    write (chr(27),'[22;1HYour score was: ',w.score:3);
    write (chr(27),'[23;1Hand your addiction is rated to be: ');
    if games < 5 then writeln ('not a habit, yet');
    if (games > 4) and (games < 10) then writeln ('just a social thing');
    if (games > 9) and (games < 15) then writeln ('physical dependancy');
    if (games > 14) and (games < 20) then writeln ('junkie');
    if (games > 19) and (games < 25) then writeln ('you like it better than sex');
    if (games > 24) and (games < 30) then writeln ('Betty Ford Clinic');
    if games > 29 then writeln ('Total Geek, GET A LIFE!!!');
  end
  else
    smg$put_chars(stat,'             Bummer!!  The high score file couldn''t be opened!!!               ',1,1,,smg$m_bold+smg$m_reverse)

end;

procedure levelup ( A : string );

var
  title1   : varying [19] of char;
  title2   : varying [19] of char;
  level_f  : text;
  charact  : varying [1] of char;
  tdisp    : unsigned;

begin
  muno := 0; {number of mushrooms}
  loop := 0;
  repeat
    lib$wait (0.05);
    loop := loop + 1;
    open (level_f,A,history:=old,error:=continue);
  until (status (level_f) = 0) or (loop = 100);
  if not (status (level_f) = 0) then
    begin
    smg$put_chars (stat,'           I am unable to access the file which contains the level!!!           ',1,1,,smg$m_blink+smg$m_reverse);
    lib$wait (4);
    smg$put_chars (stat,' I will attempt to make an ermergency save of your game, check the level file!! ',1,1,,smg$m_blink+smg$m_reverse);
    lib$wait (6);
    save;
    lib$wait (2);
    smg$put_chars (stat,' Ignore the errors procedding this.....',1,1,smg$m_erase_to_eol,smg$m_bold);
    writeln (chr(27),'[?25h');
  end;
  reset (level_f);
  readln (level_f,muno);
  if muno > 20 then muno := 20;
  smg$begin_pasteboard_update(pasty);
  for loop := 1 to sheight do
    begin
    for loop2 := 1 to swidth do
      begin
      read (level_f,charact);
      if charact = '#' then
        begin
        bump [loop2,loop] := True;
        smg$put_chars (display,wallseg,loop,loop2);
      end;
    end;
    writeln;
    readln (level_f);
  end;
  smg$end_pasteboard_update(pasty);
  if SHOW then
    begin
    readln (level_f,title1);
    readln (level_f,title2);
    smg$create_virtual_display(2,19,tdisp,smg$m_border);
    smg$paste_virtual_display(tdisp,pasty,(round((sheight-2)/2))+2,(round((swidth-20)/2))+2,);
    smg$put_line(tdisp,title1,1);
    smg$put_line(tdisp,title2,1);
    lib$wait(4);
    smg$delete_virtual_display (tdisp);
  end;
  close (level_f);
end;

procedure clean;

begin
  for loop := 1 to swidth do
    for loop2 := 1 to sheight do
      bump [loop,loop2] := False;
end;

procedure random ( var  a : integer;
                   var  b : integer );

begin
  repeat
    randomn := mth$random(seed);
    a := 1+(round (randomn*(swidth-1)));
    randomn := mth$random(seed);
    b := 1+(round (randomn*(sheight-1)));

  until not bump[w.mushx,w.mushy];
end;

procedure  erase;

begin
  w.point := w.point + 1;
  if w.point > buf then w.point := 1;
  w.histx[w.point] := w.x;
  w.histy[w.point] := w.y;
  if (w.point-w.lengw) > 0 then
    begin
    if (bump [w.histx[w.point-w.lengw],w.histy[w.point-w.lengw]]) then
      begin
      if not ((w.x = w.histx[(w.point-w.lengw)]) and (w.y = w.histy[(w.point-w.lengw)])) then
        smg$erase_chars (display,1,w.histy[w.point-w.lengw],w.histx[w.point-w.lengw]);
      bump [w.histx[w.point-w.lengw],w.histy[w.point-w.lengw]] := False;
      w.histx[w.point-w.lengw] := 0;
      w.histy[w.point-w.lengw] := 0;
    end;
  end
  else
    begin
    if (bump [w.histx[buf+(w.point-w.lengw)],w.histy[buf+(w.point-w.lengw)]]) and 
      not (w.histy[buf+(w.point-w.lengw)] = 0) and
      not (w.histx[buf+(w.point-w.lengw)] = 0) then
      begin
        if not ((w.x = w.histx[buf+(w.point-w.lengw)]) and (w.y = w.histy[buf+(w.point-w.lengw)])) then
           smg$erase_chars (display,1,w.histy[buf+(w.point-w.lengw)],w.histx[buf+(w.point-w.lengw)]);
        bump [w.histx[buf+(w.point-w.lengw)],w.histy[buf+(w.point-w.lengw)]] := False;
        w.histx [buf+(w.point-w.lengw)] := 0;
        w.histy [buf+(w.point-w.lengw)] := 0;
      end;
  end;
end;

procedure splat;

begin
  if bump [w.x,w.y] = True then DEAD := True;
  bump [w.x,w.y] := True;
end;

procedure yumyum;

begin
  if (w.mushx = w.x) and (w.mushy = w.y) then
    begin
    w.lengw := w.lengw + 10;
    w.cur := w.cur + 1;
    w.score := w.score + 10;
    smg$put_chars (stat,'SCORE: '+substr(intstr(w.score),2,2),1,1);
    smg$put_chars (stat,'SHROOMS TO EAT: '+substr(intstr(muno-w.cur),3,2),1,rights-18);
    if not (w.cur =  muno ) then
      begin
      random (w.mushx,w.mushy);
      smg$put_chars (display,mushseg,w.mushy,w.mushx);
    end;
  end;
end;

procedure main;

begin
  if not STORED then
    begin
    for loop := 1 to 100 do
      smg$read_keystroke(keyboard,temp,,0);
    w.cur := 0;
    w.lengw := 10;
    w.point := 0;
    lastkey := 1000;
    w.x := round (swidth/2);
    w.y := round (sheight/2);
    smg$put_chars (display,'^',w.y,w.x);
    bump [w.x,w.y] := True;
    random (w.mushx,w.mushy);
    for loop := 1 to buf do
      begin
      w.histy[loop] := 0;
      w.histx[loop] := 0;
    end;
  end;
  smg$put_chars (display,mushseg,w.mushy,w.mushx);
  smg$put_chars (stat,'SCORE: '+substr(intstr(w.score),2,2),1,1);
  smg$put_chars (stat,'SHROOMS TO EAT: '+substr(intstr(muno-w.cur),3,2),1,rights-18);

  repeat
    if (temp = smg$k_trm_ctrll) or (temp = smg$k_trm_ctrlw) then smg$repaint_screen (pasty);
    if STORED then
      begin
      lib$wait (1.5);
      if (round (swidth/2) = w.x) and (round (sheight/2) = w.y) then
        smg$put_chars (display,'^',w.y,w.x)
      else
        smg$put_chars (display,wormseg,w.y,w.x)
    end;
    STORED := False;
    if (lastkey = up) or (lastkey = down) then
      lib$wait (0.3)
    else
      lib$wait (0.2);
    smg$read_keystroke(keyboard,temp,,0);
    if (temp = left) or (temp = right) or (temp = up) or (temp = down) then
      lastkey := temp;
    if not (lastkey = 1000) and not (temp = smg$k_trm_ctrlz) then
      begin
      if lastkey = up then w.y := w.y-1;
      if lastkey = down then w.y := w.y+1;
      if lastkey = left then w.x := w.x-1;
      if lastkey = right then w.x := w.x+1;
      smg$begin_pasteboard_update(pasty);
      smg$put_chars (display,wormseg,w.y,w.x);
      erase;
      splat;
      yumyum;
      smg$end_pasteboard_update(pasty);
    end;
    if (w.x<1) or (w.y<1) or (w.x>swidth) or (w.y>sheight) then DEAD := True;
  until DEAD or (w.cur = muno) or (temp = smg$k_trm_ctrlz);
  if temp = 26 then
  begin
    save;
    w.lives := 0;
  end
  else
    begin
    if (w.x < 1) or (w.y < 1) or (w.x > swidth) or (w.y > sheight) then
      begin
      if w.x < 1 then w.x := 1;
      if w.y < 1 then w.y := 1;
      if w.x > swidth then w.x := swidth;
      if w.y > sheight then w.y := sheight;
      smg$put_chars (display,'*',w.y,w.x,,smg$m_bold);
      lib$wait(1);
    end
    else
      begin
      if DEAD then
        begin
        smg$put_chars (display,'X',w.y,w.x,,smg$m_bold);
        lib$wait(1);
      end
      else
        begin
        smg$put_chars (display,'URP!',w.y,w.x,,smg$m_bold);
        lib$wait(2);
      end;
    end;
  end;
end;

begin {this is not a procedure!}
  writeln (chr(27),'[?25l'); {turn the cursor off, smg$ is unreliable...}
  if (odd(cli$present('MAPKEY'))) then
  begin
    clistat := cli$get_value('MAPKEY',%descr mapkey);
    up := ord (mapkey[1]);
    right := ord (mapkey[2]);
    down := ord (mapkey[3]);
    left := ord (mapkey[4]);
  end
  else
    begin
    up := smg$k_trm_up;
    right := smg$k_trm_right;
    down := smg$k_trm_down;
    left := smg$k_trm_left;
  end;

  if (odd(cli$present('WALL'))) then
    clistat := cli$get_value('WALL',wallseg)
  else
    wallseg := '|';
  if (odd(cli$present('MUSHROOM'))) then
    clistat := cli$get_value('MUSHROOM',mushseg)
  else
    mushseg := '@';
  if (odd(cli$present('SEGMENT'))) then
    clistat := cli$get_value('SEGMENT',wormseg)
  else
    wormseg := 'o';
  if (odd(cli$present('DIRECTORY'))) then
    clistat := cli$get_value('DIRECTORY',%descr prefix)
  else
    prefix := prefixd;

{setup seed for random selection of shrooms}
  lib$date_time (%descr datestr);
  datestr := (substr(datestr,22,2))+(substr(datestr,19,2))+(substr(datestr,16,2));
  seed := 2*(strint (datestr))+1;
  w.level := 0;
  w.lives := 3;
  w.score := 0;
  DEAD := False;
  SHOW := True;
  lib$getjpi(jpi$_username,,,,%descr w.user);
  smg$create_virtual_keyboard(keyboard,,,);

  {display 1}
  smg$create_virtual_display(sheight,swidth,display,smg$m_border);
  smg$create_pasteboard(pasty,,,); 
  smg$paste_virtual_display(display,pasty,3,2,);
  smg$create_virtual_display(1,swidth+2,stat);
  smg$paste_virtual_display(stat,pasty,1,1);
  smg$put_chars (stat,'SCORE:   0',1,1);
  smg$put_chars (stat,'SHROOMS TO EAT:  ?',1,rights-18);
  recall; {find out if there is a saved games, if yes retrieve}
  if not stored then
    begin
    startup; {goto startup screen}
    difficulty; {get preferred starting levels}
  end;
{start real game}
  repeat
    if DEAD then
    begin
      SHOW := False;
      w.lives := w.lives - 1;
      if w.lives = 0 then
        begin
        smg$put_chars (stat,'   Toasted!   ',1,middle-7,,smg$m_bold+smg$m_reverse);
        lib$wait (3);
        smg$put_chars (stat,'              ',1,middle-7,,);
      end;
    end
    else
      begin
      if not STORED then
        begin
        w.level := w.level + 1;
        SHOW := True;
      end;
      if ((w.level rem 5) = 0) and not STORED then
        begin
        w.lives := w.lives + 1;
        smg$put_chars (stat,'* BONUS LIFE *',1,middle-7,,smg$m_bold+smg$m_reverse);
        lib$wait (5);
        smg$put_chars (stat,'              ',1,middle-7,,);
      end;
    end;
    if not (w.lives = 0) then
      begin
      smg$put_chars (stat,'Lives Left: '+substr(intstr(w.lives),3,2),1,middle-7,,smg$m_reverse+smg$m_blink);
      lib$wait (1);
    end;
    if not STORED then
      begin
      clean;
      smg$erase_display (display);
    end;
    if w.level > 9 then
      filename := prefix+'level'+substr (intstr(w.level),3,2)+'.txt;'
    else
      filename := prefix+'level'+substr (intstr(w.level),4,1)+'.txt;';
    if not (w.lives = 0) then
      begin
      DEAD := False;
      if (w.level = lastlev) then
        begin
        w.score := w.score + (w.lives*100);
        win;
      end;
      smg$set_cursor_abs (display,1,1); {you need this, smg's are wierd}
      if not (w.level = lastlev) then
        begin
        levelup (filename);
        smg$put_chars (stat,'   LEVEL:   '+substr(intstr(w.level),3,2),1,middle-7);
        main;
      end;
    end;
  until (w.lives = 0) or (w.level = lastlev);
  smg$delete_virtual_display(display);
  writeln (chr(27),'[?25h');
  if not (temp = smg$k_trm_ctrlz) then highscore;
end.
