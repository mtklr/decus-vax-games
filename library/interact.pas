[
  Inherit
    ('SYS$LIBRARY:STARLET'),
  Environment
    ('INTERACT.PEN')
]


MODULE INTERACT;

%INCLUDE 'VT100_ESC_SEQS.PAS'

[HIDDEN]
TYPE
  $UWORD = [WORD] 0..65535;
  $DEFTYP = [UNSAFE] INTEGER;
  $DEFPTR = [UNSAFE] ^$DEFTYP;
  v_array = varying [256] of char;
  string  = varying [20] of char;
  date_time_type = array [1..7] of $uword;
  unknown_file = [UNSAFE,VOLATILE] File of char;
  fabptr = ^fab$type;
  rabptr = ^rab$type;

VAR
  date_time : [GLOBAL] date_time_type;
{Handler}
  desblk : [GLOBAL] Record
                      findlink   : integer;
                      proc       : integer;
                      arglist    : array [0..1] of integer;
                      exitreason : integer;
                    End;
  qio_write_speed : integer := 0;


[EXTERNAL]
PROCEDURE  check_status;
Extern;

[EXTERNAL]
PROCEDURE  Clear ( portiontype : v_array := 'SCREEN';
                   cleartype   : v_array := 'WHOLETHING' );
{
'SCREEN' or 'LINE'
'WHOLETHING', 'TO_START' or 'TO_END'
}
Extern;

[EXTERNAL]
PROCEDURE  Create_global_section
      (
        Section_name : v_array;
        Section_size : integer;
        var Section_ptr : $defptr;
        var Section_end : [TRUNCATE] $defptr
      );
Extern;

[EXTERNAL]
PROCEDURE  Create_event_flag_cluster (   name : v_array;
                                      cluster : v_array := '64-95' );
Extern;

[EXTERNAL]
FUNCTION  Day_num : integer;
Extern;

[EXTERNAL]
FUNCTION  Day_str ( day : integer ) : v_array;
Extern;

[EXTERNAL]
FUNCTION  Dec ( number    : integer;
                pad_char  : char := ' ';
                pad_len   : integer := 0
              ) : v_array;
Extern;

[EXTERNAL]
PROCEDURE  Delete_global_section ( Section_ptr, Section_end : $defptr );
Extern;

[EXTERNAL]
FUNCTION  Extract ( str : v_array;
                    start : integer ) : v_array;
Extern;

[EXTERNAL]
PROCEDURE  ERROR ( text : v_array );
Extern;

[EXTERNAL]
PROCEDURE  Force;
Extern;

[EXTERNAL]
PROCEDURE  Formated_read
 (VAR return_value   : v_array;
      picture_clause : v_array;
      x_posn         : integer;
      y_posn         : integer;
      default_value  : v_array := '';
      field_full_terminate : boolean := false;
      begin_brace    : v_array := '';
      end_brace      : v_array := ''
 );
Extern;

[EXTERNAL]
FUNCTION  Get_Clear ( portiontype : v_array := 'SCREEN';
                      cleartype   : v_array := 'WHOLETHING' ) : v_array;
Extern;

[EXTERNAL]
PROCEDURE  Get_Date_time;
Extern;

[EXTERNAL]
FUNCTION  Full_char ( character : char ) : v_array;
Extern;

[EXTERNAL]
FUNCTION  Get_jpi ( jpicode , retlen : integer ) : v_array;
Extern;

[EXTERNAL]
FUNCTION  Get_Posn ( x , y : integer ) : v_array;
Extern;

[EXTERNAL]
FUNCTION  Hex ( number , len : integer ) : v_array;
Extern;

[EXTERNAL]
PROCEDURE  Image_dir;
Extern;

[EXTERNAL]
PROCEDURE  KILL ( PID : [TRUNCATE] UNSIGNED );
Extern;

[EXTERNAL]
FUNCTION  Lower_case ( c : char ) : char;
Extern;

[EXTERNAL]
FUNCTION  Lower_string ( text : v_array ) : v_array;
Extern;

[EXTERNAL]
PROCEDURE  No_handler;
Extern;

[EXTERNAL] { user action procedure }
FUNCTION  Open_status_new ( VAR Fab : fab$type;
                            VAR Rab : rab$type;
                        VAR Filevar : unknown_file ) : integer;
Extern;

[EXTERNAL] { user action procedure }
FUNCTION  Open_status_old ( VAR Fab : fab$type;
                            VAR Rab : rab$type;
                        VAR Filevar : unknown_file ) : integer;
Extern;

[EXTERNAL]
PROCEDURE  Posn ( x , y : integer );
Extern;

[EXTERNAL]
FUNCTION  QIO_1_char : char;
Extern;

[EXTERNAL]
FUNCTION  QIO_1_char_now : char;
Extern;

[EXTERNAL]
FUNCTION  QIO_1_char_timed ( delay : integer ) : char;
Extern;

[EXTERNAL]
PROCEDURE  QIO_purge;
Extern;

[EXTERNAL]
FUNCTION  QIO_read_integer : integer;
Extern;

[EXTERNAL]
FUNCTION  QIO_read_varying ( chars : integer := 80 ) : v_array;
Extern;

[EXTERNAL]
FUNCTION  QIO_readln ( characters : integer ) : v_array;
Extern;

[EXTERNAL]
PROCEDURE  QIO_Write ( text : v_array );
Extern;

[EXTERNAL]
PROCEDURE  QIO_writeln ( text : [TRUNCATE] v_array );
Extern;

[EXTERNAL]
FUNCTION  Random ( ub : integer ) : integer;
Extern;

[EXTERNAL]
FUNCTION  Randomize ( ub : integer ) : integer;
{ produce a random number between 1 and ub inclusive }
Extern;

[EXTERNAL]
PROCEDURE  Reset_randomizer;
Extern;

[EXTERNAL]
PROCEDURE  Reset_screen;
Extern;

[EXTERNAL]
PROCEDURE  RMS_signal;
Extern;

[EXTERNAL]
FUNCTION  RMS_Status : integer;
Extern;

[EXTERNAL]
FUNCTION  Rnd ( lb, ub : integer ) : integer;
{ produce a random number between lb and ub inclusive }
Extern;

[EXTERNAL]
PROCEDURE  Seed_initialize ( users_seed : [TRUNCATE] integer );
Extern;

[EXTERNAL]
PROCEDURE Setup_handler ( handler_address : integer );
Extern;

[EXTERNAL]
PROCEDURE  Show_graphedt ( filename : string; wait : boolean := true );
Extern;

[EXTERNAL]
FUNCTION  Sign ( n : integer ) : integer;
Extern;

[EXTERNAL]
PROCEDURE  Sleep ( sec : integer := 0; frac : [TRUNCATE] real );
Extern;

[EXTERNAL]
PROCEDURE  Sleep_start ( interval : integer );
Extern;

[EXTERNAL]
PROCEDURE  Sleep_wait;
Extern;

[EXTERNAL]
PROCEDURE  Smart_Posn ( to_x, to_y : integer; VAR init : boolean );
Extern;

[EXTERNAL]
PROCEDURE  Smart_qio_write ( str : v_array );
Extern;

[EXTERNAL]
PROCEDURE  Smart_shift ( i : integer );
Extern;

[EXTERNAL]
PROCEDURE  Square ( x1 , y1 , x2 , y2 : integer );
Extern;

[EXTERNAL]
PROCEDURE  Start_stopwatch;
Extern;

[EXTERNAL]
FUNCTION  Stop_stopwatch : v_array;
Extern;

[EXTERNAL]
PROCEDURE  Swap ( VAR i, j : integer );
Extern;

[EXTERNAL]
PROCEDURE  TERMINATE ( code : integer := 1 );
Extern;

[EXTERNAL]
PROCEDURE  Top_ten ( this_score : integer );
Extern;

[EXTERNAL]
FUNCTION  Trim ( text : v_array ) : v_array;
Extern;

[EXTERNAL]
FUNCTION  Upper_case ( c : char ) : char;
Extern;
    
[EXTERNAL]
FUNCTION  Upper_string ( text : v_array ) : v_array;
Extern;

END.
