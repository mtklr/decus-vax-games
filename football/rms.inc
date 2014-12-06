const
  puntbase = 35;
  kickbase = 45;
  fgbase = 30;
  rbbase = 10;
  boothfile = '$1$DUA12:[TEMP.MASMUMMY]FOOTBALL.BOOTH';
  helplib = '$1$DUA12:[TEMP.MASMUMMY]FOOTBALL.HLB';
  gametime = 1500;

type
  $word = [WORD] -32768..32767;
  $byte = [BYTE] -128..127;
  $uword = [WORD] 0..65535;
  $uquad = [QUAD,UNSAFE] record
             long_1 : unsigned;
             long_2 : unsigned;
           end;
  unsafe_file = [unsafe] file of char;
  ptr_to_fab  = ^fab$type;
  ptr_to_rab  = ^rab$type;
  ident = packed array [1..12] of char;
  varstr = varying [10] of char;
  datetime = packed array [1..23] of char;
  istring = varying [1024] of char;
  fifstr = packed array [1..15] of char;
  vartwe = varying [20] of char;

  players = record
    userid      : [key(0)] ident;   { The username of the player }
    pid         : unsigned;         { Process ID }
    formation   : integer;          { The formation }
    play        : integer;          { The play action }
    count       : integer;          { Determines who is to receive information }
    time        : integer;          { Actual time in game }
    pos         : integer;          { Absolute position on field (1-100) }
    city        : fifstr;           { Team's city }
    name        : fifstr;           { Team's name }
    gained      : integer;          { Actual number of yards gained }
    ydstogo     : integer;          { Yards to go for first down }
    quarter     : integer;          { Quarter }
    down        : integer;          { Down }
    score       : integer;          { Score (non accumlative) }
    dokickoff   : boolean;          { Do kickoff }
    iswaiting   : boolean;          { If player is waiting for another }
    first       : boolean;          { Who received first }
    dir         : boolean;          { Direction of play on field }
    intercepted : boolean;          { Interception }
    fumble      : boolean;          { Fumble } 
  end;

  playlist = file of players;

var
  rmsstatus : unsigned := 1;
  huddle : integer := 1;
  ksz : $byte := 12;       { All key sizes are 12 }
  usz,rsz : $word := 92;   { The recordsize of the playerfile }
  ubf,kbf,rbf : $uword;
  playfile : playlist;
  me,you : players;
  disp : array [1..10] of unsigned;
  paste,keyb : unsigned;
  alen : $uword;
  playstr : vartwe;
  i,j,k,l,old_where,where,who,xlen,stat,wait : integer := 0;
  myform,myact,quarter,gtime,down,ydstogo,score : integer := 0;
  myscore,yourscore : integer := 0;
  dir,dokickoff,istarted : boolean := true;
  gameover,newhalf,newquarter,mestart,fumble,interception,
  passing, running : boolean := false;
  football_ghosted,football_absent,football_playing,
  football_badrecord,football_notspawn,football_lonely,
  football_baduser : [external] unsigned;


[external]
function pas$fab(var f : unsafe_file) : ptr_to_fab; extern;

[external]
function pas$rab(var f : unsafe_file) : ptr_to_rab; extern;

function rms_open (var fab : fab$type;
                   var rab : rab$type;
                   var f : playlist) : unsigned;
begin
  fab.fab$l_fop := fab$m_cif;
  rab.rab$l_fab := iaddress(fab);
  rmsstatus := $create(fab);
  if (odd(rmsstatus)) then
    rmsstatus := $connect(rab);
  rms_open := rmsstatus;
end;

function rms_put(var rab: rab$type) : unsigned;
begin
  rab.rab$b_rac := rab$c_key;
  rab.rab$b_tmo := 10;                    { timeout period of 10 seconds }
  rab.rab$w_rsz := rsz;                   { record size }
  rab.rab$l_rbf := rbf;                   { address of the record buffer }
  rab.rab$l_rop := rab$m_tmo + rab$m_wat + rab$m_uif;
  rms_put := $put(rab);                   { write the new record }
end;

function rms_get(var rab: rab$type; lock: boolean) : unsigned;
begin
  rab.rab$b_rac := rab$c_key;               { keyed access }
  rab.rab$b_ksz := ksz;                     { size of the key }
  rab.rab$l_kbf := kbf;                     { address of the key buffer }
  rab.rab$w_usz := usz;                     { size of the record }
  rab.rab$b_tmo := 10;                      { timeout period of 10 seconds }
  rab.rab$l_ubf := ubf;                     { address of the record buffer }
  if (lock) then
    rab.rab$l_rop := rab$m_tmo + rab$m_wat
  else
    rab.rab$l_rop := rab$m_tmo + rab$m_wat + rab$m_nlk;
  rms_get := $get(rab);                     { get the record }
end;

function rms_update(var rab : rab$type) : unsigned;
begin
  rms_update := $update(rab);             { update the locked record }
end;

function rms_delete(var rab : rab$type) : unsigned;
begin
  rms_delete := $delete(rab);             { delete the locked record }
end;
