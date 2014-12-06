(****************************************************************************
 ****************************************************************************
 **
 **  Reflex.  Written By Chris Guthrey, 1991. 
 **  This code copyright, University Of Waikato. 
 **  No warranty of any kind is supplied.
 **
 **  Based on an old CP/M game. I don't know who created original concept.
 **
 **  email: CGUTHREY@WAIKATO.AC.NZ
 **
 ** This was written specifically for the Waikato University games library.
 ** It may or may not work on any other VAX system without modification.
 **)

[INHERIT('misc')]
PROGRAM Reflex;

(*****************************
 * Display Characters
 *)
CONST           
  player_C = 'O';
  enemy_C  = '@';
  target_C = '$';
  mines_C  = '+';
  hyper_C  = 'H';
  left_deflect_C  = '/';
  right_deflect_C = '\';
  carriage_return = CHR(13);
(********************
 * keyboard control characters
 *)
  kbd_left = '4';
  kbd_right= '6';
  kbd_delete='5';
  kbd_quit = 'Q';
  kbd_redraw = 'R';

(*******************
 * game constants
 *)
  x_ofs = 1;
  y_ofs = 1;
  pf_width = 38;
  pf_length = 21;
  start_delay = 0.160;
  delay_decrement = 0.02;
(********************
 * type decls
 *)
TYPE
  directions  = (up,down,left,right);
  game_states = (_playing, _quit, _dead, _hit_target, _hit_mine, _hit_hyper, 
                 _hit_enemy, _hit_left, _hit_right );

  player_type = RECORD
                  c      : CHAR;
                  x, y   : INTEGER;
                  _x,_y  : INTEGER;
                  state  : game_states;
                  dir    : directions;
                  score  : INTEGER;
                  level  : INTEGER; 
                  delete : BOOLEAN;
                  delay  : REAL;
                  moving : BOOLEAN;
               END;

  enemy_type  = RECORD
                  active : BOOLEAN;
                  c      : CHAR;
                  state  : game_states;
                  x, y   : INTEGER;
                  _x,_y  : INTEGER;
                  dir    : directions;
                  speed  : INTEGER;
                END; 

  target_type = RECORD
                  c        : CHAR; 
                  x, y     : INTEGER;
                  timeleft : REAL;
                END;                 
(*******************
 * Game Global Vars
 *)
VAR
  PlayField : ARRAY[0..pf_width,0..pf_length] OF CHAR := ZERO;
  sp_init : BOOLEAN := TRUE;
  player  : player_type;
  enemy   : enemy_type;
  target  : target_type;   
  mines   : INTEGER := 0;
  cx,cy   : INTEGER := 0; (* Global current x and y pos *)
  level_jump : INTEGER := 10;

PROCEDURE WriteScoreBoard;
BEGIN
   
  QIO_Write( Get_Posn( 7,24 )+ UDEC( player.score,6 ) );
  QIO_Write( Get_Posn( 22,24 )+ UDEC( player.level,2 ) );
  QIO_Write( Get_Posn( 37,24 ) + UDEC( TRUNC(target.timeleft),3 ) );
END;

PROCEDURE RepositionTarget;
VAR x,y,i : INTEGER;
BEGIN
  REPEAT
    target.x := Rnd(1, pf_width ); target.y := Rnd( 1,pf_length );
  UNTIL (player.x <> target.x) AND (player.y<>target.y);
  target.timeleft := 200.0;
  PlayField[target.x,target.y] := target_C;
  qio_write( Get_Posn( x_ofs+target.x, y_ofs+target.y ) + target.c ); 
  FOR i := 1 TO mines DO BEGIN
    REPEAT
      x := Rnd( 1,pf_width )-1; y := Rnd( 1,pf_length );
    UNTIL PlayField[x,y] = ' ';
    PlayField[x,y] := mines_C;
    Qio_Write( Get_Posn( x_ofs+x, y_ofs+y ) + mines_C ); 
  END;
END;

PROCEDURE Draw_Screen;
VAR x,y : INTEGER;
BEGIN
  Clear;
  FOR y := 1 TO 24 DO BEGIN
    QIO_Write( Get_Posn( 1,y ) + VT100_wide );
  END;
  Square( 1,1, pf_width +2, pf_length+2 );
  QIO_Write( Get_Posn( 1,24 ) + 'SCORE:         LEVEL:     TIME LEFT:');
  WriteScoreBoard;
END;

PROCEDURE ReDraw_PlayField;
VAR x,y : INTEGER;
    s   : VARYING[80] OF CHAR;
BEGIN
  Draw_Screen;
  FOR y := 1 TO pf_length DO BEGIN
    s := '';
    FOR x := 1 TO pf_width DO 
      s := s + PlayField[x,y];
    QIO_Write( Get_Posn( x_ofs+1,y_ofs+y)+s );
  END;
END;

PROCEDURE ReDraw_Screen;
BEGIN
  Draw_Screen;
  ReDraw_PlayField;
END;

PROCEDURE Clear_PlayField;
VAR x,y :INTEGER;
BEGIN
  FOR y := 1 TO pf_length DO
    FOR x := 1 TO pf_width DO
      PlayField[x,y] := ' ';
  ReDraw_PlayField;
  player.x := pf_width DIV 2;  player.y := pf_length DIV 2;
  player.c := Player_C;
  player.moving := false;
  player.state := _playing;
  player._x := player.x;  player._y := player.y;
  qio_write( Get_Posn( x_ofs+player.x, y_ofs+player.y ) + player.c );
  target.c := Target_C;
  RepositionTarget;
END;

PROCEDURE SetUp_PlayField_Players;
VAR x,y :INTEGER;
BEGIN
  Draw_Screen;
  sp_init := TRUE;
  FOR y := 1 TO pf_length DO
    FOR x := 1 TO pf_width DO
      PlayField[x,y] := ' ';
  Seed_Initialize;
  player.x := pf_width DIV 2;  player.y := pf_length DIV 2;
  player.c := Player_C;
  player.state := _playing;
  player.moving := false;
  player._x := player.x;  player._y := player.y;
  qio_write(Get_Posn( x_ofs+player.x, y_ofs+player.y ) +  player.c );
  target.c := Target_C;
  RepositionTarget;
END;

PROCEDURE UpDatePlayerDisplay;
BEGIN
  IF player.moving THEN BEGIN
    CASE player.dir OF
    right: IF player.x > 1 THEN BEGIN
             QIO_Write( Get_Posn( x_ofs+player._x, y_ofs+player._y ) + 
                PlayField[player._x, player._y]+player.c );
           END;
    left : IF player.x < pf_width THEN BEGIN
             QIO_Write( Get_Posn( x_ofs+player.x, y_ofs+player.y ) + 
                player.c+PlayField[player._x, player._y] );
           END;
    OTHERWISE 
      BEGIN
        QIO_Write( Get_Posn( x_ofs+player.x, y_ofs+player.y ) + player.c );
        QIO_Write( Get_Posn( x_ofs+player._x, y_ofs+player._y ) + 
            PlayField[player._x, player._y]);
      END;
    END;
    QIO_Write( Carriage_Return );
    player._x := player.x; player._y := player.y;
  END;
END; 

PROCEDURE NormalMovePlayer;
BEGIN
  IF player.moving THEN
    CASE player.dir OF
    up    : IF player.y > 1 THEN
              player.y := player.y -1
            ELSE BEGIN
              player.dir := down;
            END;
    down  : IF player.y < pf_length THEN
              player.y := player.y +1
            ELSE BEGIN
              player.dir := up;
            END;
    left  : IF player.x > 1 THEN
              player.x := player.x -1
            ELSE BEGIN
              player.dir := right;
            END;
    right : IF player.x < pf_width THEN
              player.x := player.x +1
            ELSE BEGIN
              player.dir := left;
            END;
    END;
END; {NormalMovePlayer}

PROCEDURE ReflexLeft;  {/}
BEGIN
  IF player.delete THEN BEGIN 

    PlayField[player.x,player.y] := ' ';
    player.delete := FALSE;
    player.score := player.score - 100;
    IF player.score < 0 THEN player.score :=0;
    END
  ELSE BEGIN    
    CASE player.dir OF
      up   : player.dir := right;
      down : player.dir := left;
      left : player.dir := down;
      right: player.dir := up;
    END;
  END;
  player.state := _playing;
  NormalMovePlayer;
  UpdatePlayerDisplay;
END;    

PROCEDURE ReflexRight; {\}
BEGIN
  IF player.delete THEN BEGIN
    PlayField[player.x,player.y] := ' ';
    player.delete := FALSE;
    player.score := player.score - 100;
    IF player.score < 0 THEN player.score :=0;
    END
  ELSE BEGIN    
    CASE player.dir OF
      up   : player.dir := left;
      down : player.dir := right;
      left : player.dir := up;
      right: player.dir := down;
    END;
  END;
  player.state := _playing;
  NormalMovePlayer;
  UpdatePlayerDisplay;
END;

PROCEDURE NextLevel;
VAR i : INTEGER;
BEGIN
  player.level := player.level + 1;
  IF player.level mod level_jump = 0 THEN BEGIN (* clear screen, inc. speed *)
    IF player.delay > 0.0 THEN          
      player.delay := player.delay - delay_decrement;
      if player.delay < 0.0 then player.delay := 0.0;
    mines := player.level div level_jump;
    Clear_PlayField;
  END ELSE BEGIN
    (*mines := mines + 1;*)
    PlayField[target.x,target.y] := ' ';
    RepositionTarget;
  END;
  player.state := _playing;
  FOR i := 1 TO (TRUNC(target.timeleft) DIV 10) DO BEGIN
    player.score := player.score + 10+player.level;
    WriteScoreBoard;
    sleep(0,0.025);
  END;
END;

PROCEDURE DieFool;
VAR i  : INTEGER;
BEGIN
  player.state := _dead;
  FOR i := 32 TO 96 DO BEGIN
    Posn( x_ofs+player.x, y_ofs+player.y);
    Qio_Write( CHR(i) );
  END;
  FOR i := 95 DOWNTO 32 DO BEGIN
    Posn( x_ofs+player.x, y_ofs+player.y);
    Qio_Write( CHR(i) );
  END;
END;  

PROCEDURE GameLoop;
VAR ch : CHAR;
    oldtime : INTEGER;
BEGIN
  WHILE (player.state = _playing) DO BEGIN
    (* check player space *)
    CASE PlayField[player.x,player.y] OF
      enemy_C : player.state := _hit_enemy;
      target_C: player.state := _hit_target;
      mines_C : player.state := _hit_mine;
      hyper_C : player.state := _hit_hyper;
      left_deflect_C : player.state := _hit_left;
      right_deflect_C : player.state := _hit_right;
    END;   

    IF (player.moving) THEN BEGIN
      oldtime := TRUNC( target.timeleft );
      target.timeleft := target.timeleft - player.delay;
      IF oldtime <> TRUNC( target.timeleft ) THEN
        WriteScoreBoard;
      IF target.timeleft <= 0 THEN player.state := _dead;
    END;

      (* get player input *)
    ch := Upper_Case( QIO_1_Char_Now );
    IF (player.state = _playing) OR (player.state= _hit_right)
       OR (player.state = _hit_left) THEN BEGIN    
      CASE ch OF
        kbd_left : BEGIN
                     PlayField[player.x,player.y] := left_deflect_C;
                     player.state := _hit_left;
                     if not player.moving then player.moving := true;
                   END;
        kbd_right: BEGIN 
                     PlayField[player.x,player.y] := right_deflect_C;
                     player.state := _hit_right;
                     if not player.moving then player.moving := true;
                   END;
      END;{case}
    END;{if}

    CASE ch OF
      kbd_delete: IF player.moving THEN player.delete:= TRUE;
      kbd_quit : player.state := _quit;
      kbd_redraw : Redraw_Screen;
    END;
  
    CASE player.state OF
      _playing    : BEGIN
                      NormalMovePlayer;
                      UpDatePlayerDisplay;
                      Sleep( 0, player.delay );
                    END;
      _hit_target : NextLevel;
      _hit_mine   : DieFool;
      _hit_hyper  : {HyperJump};
      _hit_enemy  : DieFool;
      _hit_left   : ReflexLeft;
      _hit_right  : ReflexRight;
    END;
  END;
  Top_Ten( player.score );
END;


PROCEDURE ExitHandler;
BEGIN
  Reset_Screen;
  Posn( 1,21 );
END;

BEGIN 
  Initialize_Channel;
  Setup_Handler( iaddress( ExitHandler ) );
  Force;
  mines := 0;
  player.delay := start_delay;
  player.score := 0;
  enemy.active := FALSE; (* no enemies yet *)
  Show_graphedt( 'REFLEX.PIC', true );
  Increment_Game_Count;
  SetUp_PlayField_Players;
  GameLoop;
END.
