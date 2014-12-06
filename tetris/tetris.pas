{----------------------------------------------------------------------------- 
Tetris for VAX/VMS
  
  Brought to you by Chris R. Guthrey,
   University Of Waikato, 
   New Zealand.
  
  Comments/etc to 'cguthrey@waikato.ac.nz' or 'ccc_rex@waikato.ac.nz'

  Greetings and thanks to:  All contributary authors of the Interact library,
                            CCC_REX,
                            CCC_LDO,
                            CCC_SIMON.

  Have fun!

  Chris Guthrey,   3rd July,  1990
------------------------------------------------------------------------------}


[INHERIT( 'SYS$LIBRARY:STARLET',  'TETSHAPES', 'INTERACT' )]
                      
PROGRAM Tetris( input, output );
CONST 
      datafile1 = 'image_dir:tetintro1.dat';
      datafile2 = 'image_dir:tetintro2.dat';
      datafile3 = 'image_dir:tetintro3.dat';
      initial_delay = 0.08;

CONST 
    apst = CHR( 39 );
    left_key = '4';
    right_key= '6';
    down_key= '2';
    rotate_key= '5';
    drop_key= ' ';
    pause_key= 'p';
    quit_key= 'q';
    redraw_key= CHR(23);
TYPE
    GridType = ARRAY[1..Grid_width,1..Grid_length] OF CHAR;
    num_Str = VARYING[10] OF CHAR;
    line_str_type = VARYING[120] OF CHAR;

VAR grid : GridType;
 
VAR wow : RECORD
            score :[LONG] INTEGER;
            level : INTEGER;
            lines : INTEGER;
            linecount: INTEGER;
            lines_target : INTEGER;
            stage : INTEGER;
            random : INTEGER;
          END;

    Is_Msg : BOOLEAN;
    play : BOOLEAN;
    options : RECORD
                display_next : BOOLEAN;
                quit         : BOOLEAN;
              END;

(****************************************************************************)
(*  ClearGrid								    *)
(*								            *)
(*  Set the playing field matrix to zero				    *)
(*                                                                          *)

PROCEDURE ClearGrid( VAR Grid : GridType );
VAR x,y : INTEGER;
BEGIN
   FOR y := 1 TO grid_length DO
      FOR x := 1 TO grid_width DO
        grid[x,y] := ' ';          
END;

(***************************************************************************)
(* SetUpScreen                                                             *)
(*                                                                         *)
(* Setup the terminal display ready to begin game play                     *)
(*                                                                         *)

PROCEDURE SetUpScreen;
BEGIN
   Clear;
   Set40Screen;
   Box( (21-(grid_width DIV 2)),1, grid_width+2, grid_length+1,0,1 );
   Box( 3,5, 12, 14, 0, 1 );
   Posn(6,6);
   QIO_Write('Score');
   Posn(6,9);
   QIO_Write('Lines');
   Posn(6,12);
   QIO_Write('Stage');
   Posn(6,15);
   QIO_Write('Next'); 
   Posn( 30,8 );
   QIO_Write( 'Lines Left:'); 
   Posn(6,2);
   QIO_Write( vt100_bright_only+'TETRIS!'+vt100_normal );
END;

{*****************************************************************************
** Message
**
** Write annoying little messages...
}
PROCEDURE Message ( msg : Line_Str_Type; no_clr : BOOLEAN );
BEGIN
   IF no_clr THEN
      BEGIN
      Posn( 20 - ( LENGTH( msg ) DIV 2 ), 23 );
      QIO_Write( msg );
      END
   ELSE
      BEGIN
      Posn( 1, 23 );
      QIO_Write( vt100_esc + '[M'+ vt100_wide );
      END;
END;

{*****************************************************************************
** Check_Move Function.
**
** Checks the movement of greebie in a given direction.
*}

   FUNCTION  Check_Move( dx, dy, sm_no, xpos,ypos : INTEGER )
                                                              : BOOLEAN;
   VAR wont_fit : BOOLEAN;
   VAR sh_y, sh_x : INTEGER;
    BEGIN
         wont_fit := FALSE;
         FOR sh_y := 0 TO 3 DO BEGIN
           FOR sh_x := 0 TO 3 DO BEGIN
             IF (xpos+sh_x+dx>grid_width) AND (sm[sm_no,sh_y,sh_x]=1) THEN
                wont_fit := TRUE
             ELSE
             IF (ypos+sh_y+dy>grid_length) AND (sm[sm_no,sh_y,sh_x]=1) THEN
               wont_fit := TRUE
             ELSE
             IF (xpos+sh_x+dx < 1 ) AND (sm[sm_no,sh_y,sh_x]=1) THEN
               wont_fit := TRUE
             ELSE
             IF (ypos+sh_y+dy < 1 ) AND (sm[sm_no,sh_y,sh_x]=1) THEN
               wont_fit := TRUE
             ELSE
             IF (sm[sm_no,sh_y,sh_x]=1) AND (xpos+sh_x+dx <= grid_width ) 
                 AND (ypos+sh_y+dy<=grid_length) THEN
               IF (grid[xpos+sh_x+dx,ypos+sh_y+dy]<> ' ') THEN
                 wont_fit := TRUE;
           END;
         END;
         Check_move := wont_fit;

   END;

{*****************************************************************************
** Move_Left
**
** Attempts to move greebie left
}
   PROCEDURE Move_Left( VAR greebie : greebie_type );
   VAR sh_x, sh_y, sm_no : INTEGER;
   VAR wont_fit : BOOLEAN;
   BEGIN
       sm_no := binshape[greebie.shape].sm_no[greebie.rot];
       wont_fit := Check_move( -1,0,sm_no,greebie.x_pos,greebie.y_pos );
       IF NOT( wont_fit ) THEN
         BEGIN
         PutShape( Greebie, s_clear );
         Greebie.x_pos := Greebie.x_pos - 1;
         PutShape( Greebie, s_draw );
         END;
   END;             

{*****************************************************************************
** Move_Right
**
** Attempts to move greebie right
}
   PROCEDURE Move_Right( VAR greebie : greebie_type );
   VAR sh_x, sh_y, sm_no : INTEGER;
   VAR wont_fit : BOOLEAN;
      BEGIN
      IF greebie.x_pos < grid_width THEN 
         BEGIN
         sm_no := binshape[greebie.shape].sm_no[greebie.rot];
         wont_fit := Check_move( 1,0,sm_no,greebie.x_pos,greebie.y_pos );
         IF NOT( wont_fit ) THEN
            BEGIN
            PutShape( Greebie, s_clear );
            Greebie.x_pos := Greebie.x_pos + 1;
            PutShape( Greebie, s_draw );
            END;
         END;  
      END;

{*****************************************************************************
** Rotate_Greebie
**
** Attempts to rotate greebie.
}
   PROCEDURE Rotate_Greebie( VAR greebie: greebie_type ); 
   VAR sh_x, sh_y,st : INTEGER;
   VAR wont_fit : BOOLEAN;
   BEGIN
      wont_fit := FALSE;
      IF Greebie.shape <> 7 THEN BEGIN
        WITH Greebie DO BEGIN
          FOR sh_y := 0 TO binshape[ shape ].max-1 DO BEGIN
            FOR sh_x := 0 TO binshape[ shape ].max-1 DO BEGIN
               IF (x_pos+sh_x<1) OR (y_pos+sh_y<1) THEN 
                 wont_fit := true
               ELSE
                 IF (x_pos+sh_x>grid_width) OR (y_pos+1+sh_y>grid_length) THEN
                    wont_fit := TRUE
                 ELSE
                   IF (grid[x_pos+sh_x,y_pos+sh_y]<> ' ') THEN
                     wont_fit := TRUE;
            END;
        END;     
        IF NOT( wont_fit ) THEN 
          BEGIN
          PutShape( Greebie, s_clear );
          Greebie.rot := Greebie.rot - 1;
          IF Greebie.rot = 0 THEN Greebie.rot := 4;
 (*         IF (Greebie.shape=2)AND((greebie.rot=1)OR(greebie.rot=3)) THEN 
            Greebie.y_pos := Greebie.y_pos + 1;
          Greebie.x_pos := Greebie.x_pos + 
                             binshape[greebie.shape].delta_x[greebie.rot]; *)
          PutShape( Greebie, s_draw );
          END;
      END;  
   END;       
END;
{*****************************************************************************
** Move_Down
**
** Attempts to move greebie down, returns false if cannot.
}       
   FUNCTION Move_Down( VAR greebie: greebie_type ):BOOLEAN;  
   VAR sh_x, sh_y, sm_no : INTEGER;
   VAR wont_fit : BOOLEAN;
      BEGIN
      Move_Down := FALSE;
      IF greebie.y_pos < grid_length THEN 
         BEGIN
         sm_no := binshape[greebie.shape].sm_no[greebie.rot];
         wont_fit := Check_move( 0,1,sm_no,greebie.x_pos,greebie.y_pos );
         IF NOT( wont_fit ) THEN
            BEGIN
            PutShape( Greebie, s_clear );
            Greebie.y_pos := Greebie.y_pos + 1;
            PutShape( Greebie, s_draw );
            Move_Down := TRUE;
            END;
         END;
      END;

{*****************************************************************************
** ReDraw_Grid
**
** Redraws the characters inside the playfield
}
 PROCEDURE ReDraw_Grid;
   VAR x, y : INTEGER;
       line : VARYING[ 255 ] OF CHAR;
   BEGIN
      FOR y := 1 TO grid_length DO
         BEGIN
         Posn(x_offset+1, y_offset+y );
         line := '';
         FOR x := 1 TO grid_width DO
            IF grid[x,y] <> ' ' THEN 
               line := line + inv+grid[x,y]+nml
            ELSE
               line := line + ' ';
         QIO_Write( line );
         END;

   END;


{*****************************************************************************
** ZapGridLine
**
** 
}
   PROCEDURE ZapGridLine( lineno : INTEGER );
   VAR x,i : INTEGER;
       l1,l2 : VARYING[grid_width] OF CHAR;
       b : BOOLEAN;
   BEGIN
     l1 := ''; l2 := '';
     FOR x := 1 TO grid_width DO BEGIN
       l1 := l1 + '#';
       l2 := l2 + '%';
     END;
     b := TRUE; 
     FOR i := 1 TO 10 DO BEGIN
         Posn(x_offset+1, y_offset+lineno );
         IF b THEN
           QIO_Write( l1 )
         ELSE
           QIO_Write( l2 );
         b := NOT( b );
         Sleep( 0, 0.03 );   
      END;
   END;
{*****************************************************************************
** Remove_Line
**
** Removes a line of chars from grid and moves the lines above it down one.
}
   PROCEDURE Remove_Line( line : INTEGER );
   VAR x,y : INTEGER;
   BEGIN
      ZapGridLine( line );
      FOR y := line DOWNTO 2 DO 
         FOR x := 1 TO grid_width DO
            grid[x,y] := grid[x,y-1];
   END;

{*****************************************************************************
** Show_Target
**
** How many lines till the end of the stage !!
}
PROCEDURE Show_Target;
VAR targ, len : INTEGER;
BEGIN
   WITH wow DO BEGIN
     IF linecount > lines_target THEN 
       targ := 0 
     ELSE
       targ := lines_target - linecount;
   END;
   IF targ > 99 THEN 
     len := 3
   ELSE
     len := 2;
   Posn( 35, 9 ); QIO_Write( ' '+UDEC(targ,3 ));
END;

{*****************************************************************************
** Show_Wow
**
** Wow! Show 'em how good their score is!
}

   PROCEDURE Show_Wow;
   BEGIN
      Posn(6,7); QIO_Write( UDEC( wow.score, 6 ) );
      Posn(6,10); QIO_Write( UDEC( wow.lines, 3 ) );
      Posn(6,13); QIO_Write( UDEC( wow.stage, 2 ) );
      Show_Target;
   END;
 

{*****************************************************************************
** Bonus
**
** Give the suckers a bonus!
}
PROCEDURE Bonus;
VAR x,y,i,no_lines : INTEGER;
    gclear : BOOLEAN;
BEGIN
   gclear := TRUE;
   y := 1;
   no_lines := 0;
   WHILE gclear DO
      BEGIN
      FOR x := 1 TO grid_width DO
         IF grid[x,y] <> ' ' THEN gclear := FALSE;
      IF gclear THEN
         BEGIN
         no_lines := no_lines + 1;
         wow.score := wow.score + 20;
         Message( UDEC( no_lines, 2)+' lines clear! Bonus: '+
                    UDEC(wow.score,7), TRUE );
         Show_wow;
         FOR x:= 1 TO grid_width DO
            PutGrid(x,y,'-');
         y := y + 1;
         END;
         IF y > grid_length THEN gclear := FALSE;
      END;
   IF no_lines > 0 THEN
      BEGIN
      Sleep( 2,0 );
      Message( '', FALSE );
      END;
   IF y > grid_length THEN
     BEGIN
     Message( '1000 POINT CLEARED SCREEN BONUS!', true );
     Sleep( 5 );
     Message( '' , FALSE );
     wow.score := wow.score + 1000;
     END;
   END;

{*****************************************************************************
** Congrats
** 
**
}
PROCEDURE Congratulate;
VAR    On : BOOLEAN;
        i : INTEGER;
BEGIN
   On := FALSE;
   FOR i := 1 TO 50 DO
      BEGIN
      IF On THEN      
        Message( inv+'You have made it to the next stage!', TRUE )
      ELSE
        Message( nml+'You have made it to the next stage!', TRUE );
      On := NOT( On );
      Sleep( 0, 0.06 );
      END;
   Message( Nml, TRUE );
   Message( '', FALSE );
   Is_Msg := TRUE;
   CASE wow.level OF
     2 : Message( 'How much longer can you last?', Is_Msg);
     3 : Message( 'Can you handle the pressure?', Is_Msg);
     4 : Message( 'Bet ya think ya doing well huh?', Is_Msg);
     5 : Message( 'Bet you'+apst+'re sweatin, Sunshine!', Is_Msg);
     6 : Message( 'You'+apst+'re dead now, Hotshot', Is_Msg);
     7 : Message( 'What are ya? A Robot?', Is_Msg);
     8 : Message( 'You sure you'+apst+'re not cheating?', Is_Msg);
     9 : Message( 'You cannot last much longer!', Is_Msg );
    10 : Message( 'You must be a Motorhead fan, right?', Is_Msg );
    11 : Message( 'Lets see how fast this thing moves!', Is_Msg ); 
    OTHERWISE Message( 'You obviously know Commander Krotche!', Is_Msg);
   END;
END;
{*****************************************************************************
** Diamond;
**
**
}
PROCEDURE Diamond;
VAR x,y,i,center : INTEGER;
BEGIN
  wow.lines_target := wow.lines_target + 5;
  Show_Wow;
  Congratulate;
  ClearGrid( grid );
  center := grid_width DIV 2;
  FOR i := 0 TO 4 DO
    IF NOT( ODD( i ) ) THEN BEGIN
      grid[ center+1+i , grid_length - 4 + i ] := binshape[ random(7) ].ch;
      grid[ center-i , grid_length - 4 + i ] := binshape[ random(7) ].ch;
    END;
  FOR i := 0 TO 1 DO BEGIN    
    grid[ center+1+i , grid_length - 1 + i ] := binshape[ random(7) ].ch;
    grid[ center-i , grid_length - 1 + i ] := binshape[ random(7) ].ch;
  END;
   Redraw_Grid;
END;          
  
{*****************************************************************************
**  Make_harder
**
** Sucker's asking for it...
}
PROCEDURE Make_Harder;
VAR x,y : INTEGER;
   BEGIN
   Show_wow;
   Congratulate;
   ClearGrid( grid );
   FOR y := grid_length- wow.random TO grid_length DO
       FOR x := 1 TO grid_width DO
          IF Random( 100 ) > 75 THEN 
             grid[x,y] := binshape[ random( 7 )  ].ch
          ELSE
             grid[x,y] := ' ';
   IF wow.random < 8 THEN 
     wow.random := wow.random + 2;
   Redraw_Grid;
   Show_wow;
END;          

{*****************************************************************************
**  Change_to_Medium difficulty
**
**  Change of scene, folks...
}
PROCEDURE Change_to_Medium;
VAR y,i : INTEGER;
   BEGIN
   wow.lines_target := 20;
   Show_Wow;
   Congratulate;
   ClearGrid( grid );
   FOR y := 10 TO grid_length DO
      BEGIN
      grid[1,y] := binshape[ Random( 7 ) ].ch;
      grid[grid_width,y] := binshape[ Random( 7 )  ].ch;
      END;
   Redraw_Grid;
   Show_Wow;
   END;

{*****************************************************************************
** Extra Fast!
**
** Clear the screen and set the game to a blinding speed
}
PROCEDURE Extra_Fast( VAR Delay : real );
BEGIN
   Delay := delay - (0.01 );
   wow.lines_target := 15;
   Show_wow;
   Congratulate;
   ClearGrid( grid );
   Redraw_Grid;
   wow.random := 4;
END;

{*****************************************************************************
** Increase_Level
**
** No more Mr Nice Guy!
}
   PROCEDURE Increase_Level;
   BEGIN
      wow.level := wow.level + 1;
      wow.linecount := 0;
   END;

{*****************************************************************************
** Next_Stage
**
** On to next stage
}
PROCEDURE Next_Stage( VAR delay: real );
BEGIN
   QIO_Purge;
   Bonus;
   wow.stage := wow.stage + 1;
   Increase_Level;
   CASE wow.stage OF
      1 : {do nothing };
      2 : BEGIN
          delay := delay - 0.0200;
          wow.lines_target := 15;
          Congratulate;
          ClearGrid( grid );
          Redraw_Grid;
          show_wow;
          END; 
      3 : BEGIN 
          delay := delay - 0.0300;
          wow.lines_target := 20;
          Congratulate;
          ClearGrid( grid );
          Redraw_Grid;
          show_wow;
          END;
      4 : BEGIN
          Change_to_Medium;
          delay := initial_delay - 0.0150; 
          END;
      5 : BEGIN
          Change_to_Medium;
          delay := delay - 0.025; 
          END;
      6 : BEGIN
          Make_Harder;
          delay := initial_delay - 0.0150;
          wow.lines_target := 20;
          END;
      7 : BEGIN
          Diamond;
          delay := delay - 0.0100;
          END;
    8,9 : BEGIN
          Make_harder;
          delay := delay - 0.0050;
          wow.lines_target := 20;
          END;
     10 : Extra_Fast( delay );
   OTHERWISE 
            BEGIN
            Make_Harder;     
            wow.lines_target := 20;
            IF delay > 0.010 THEN delay := delay - 0.0050;
            END;
   END;
END;
         
{*****************************************************************************
** Check_Resting
**
** Checks to see if the resting greebie has filled any whole lines across
}
   FUNCTION Check_Resting( VAR greebie: greebie_type; 
                           VAR delay : real ) : BOOLEAN;
   VAR sh_x, sh_y, sm_no, line_total,linesRmvd, point : INTEGER;
   BEGIN 
      check_Resting := TRUE;
      linesRmvd := 0;
      point := binshape[greebie.shape].pointv[greebie.rot];
      sm_no := binshape[greebie.shape].sm_no[greebie.rot] ;
      FOR sh_y := 0 TO 3 DO
         FOR sh_x := 0 TO 3 DO
            IF (sm[ sm_no, sh_y, sh_x ] = 1 ) THEN
               grid[ greebie.x_pos + sh_x, greebie.y_pos + sh_y ] := 
                  binshape[ greebie.shape ].ch;
      FOR sh_y := 0 TO 3 DO
         BEGIN
         line_total := 0;
         FOR sh_x := 1 TO grid_width DO
            IF greebie.y_pos+sh_y <= grid_length THEN 
               IF grid[sh_x, greebie.y_pos+sh_y] <> ' ' THEN
                  line_total := line_total + 1;
            IF line_total = grid_width THEN
               BEGIN
               Remove_Line( greebie.y_pos+sh_y );
               linesRmvd := linesRmvd + 1;
               END;
         END;      
         IF Is_Msg THEN
            BEGIN
            Is_Msg := FALSE;
            Message( '', Is_Msg );
            END;
         IF linesRmvd > 0 THEN
            BEGIN
            wow.score := wow.score + ( point * ( (linesRmvd+1) ** 2 ) ) + 
                         ( 250 * ORD(linesRmvd = 4));
            wow.lines := wow.lines + linesRmvd;
            Redraw_Grid;
            IF linesRmvd = 4 THEN
               BEGIN
               Is_Msg := TRUE;
               Message( 'You scored a TETRIS!', Is_Msg );
               END;
            END
         ELSE 
            BEGIN
            wow.score := wow.score + (2 * point);           
            IF greebie.y_pos = 1 THEN 
               Check_Resting := FALSE ;
            END;
         wow.linecount := wow.linecount + linesRmvd;
         Show_Wow;
         if wow.linecount >= wow.lines_target then
            Next_Stage( delay );
            
   END;

{*****************************************************************************
** Check_Top
**
** Checks top of screen to see if there is any room left, else return false.
}
FUNCTION Check_Top( Greebie : Greebie_Type ) : BOOLEAN;
VAR x,y,sm_no : INTEGER;
    ok  : BOOLEAN;
BEGIN
  ok := TRUE;
  sm_no := binshape[greebie.shape].sm_no[greebie.rot] ;
  FOR y := 0 TO 3 DO
    FOR x := 0 TO 3 DO
      IF (sm[ sm_no, y, x ] = 1) AND 
           (Grid[ greebie.x_pos+x, greebie.y_pos+y ] <> ' ') THEN
        ok := FALSE;
  Check_Top := ok;
END;
{*****************************************************************************
** Drop_Greebie
**
** When the drop key is pressed the greebie drops quickly
}
   PROCEDURE Drop_Greebie( VAR greebie : greebie_type);
   BEGIN
      WHILE Move_Down( greebie ) DO
        ;
   END;
 
{*****************************************************************************
** Display_next
**
** Shows what the next greebie looks like
}
   PROCEDURE DisplayNext( Next_Greebie : Greebie_Type);
   BEGIN
       PutShape_Abs( Next_Greebie, s_draw );
   END;

{***************************************************************************** 
** ClearNext
**
** Erases the 'next greebie' ready for a new picture of the next 'next greebie'
}
   PROCEDURE ClearNext( Next_Greebie : Greebie_Type );
   BEGIN 
       PutShape_Abs( Next_Greebie, s_clear );
   END;

{*****************************************************************************
** ReDraw_Complete_Screen
**
** Redraws the entire screen when the redraw key is pressed
}

   PROCEDURE ReDraw_Complete_Screen( Next_Greebie: greebie_type);
   BEGIN
      SetUpScreen;
      ReDraw_Grid;
      Show_Wow;
      DisplayNext( Next_Greebie );
   END;
  
{*****************************************************************************
** Pause game
**
**
}
PROCEDURE Pause;
VAR ch : CHAR;
BEGIN
   QIO_Purge;
   Message (VT100_bright_only+'GAME PAUSED - press any key to continue'+
             VT100_normal, true );
   ch := QIO_1_Char;
   Message ('', false );
END;

(***************************************************************************)
(* GameLoop                                                                *)
(*                                                                         *)
(* Main gameplay loop here.                                                *)
(*                                                                         *)
PROCEDURE GameLoop;

VAR greebie, next_greebie : Greebie_Type;
VAR Greebie_Start : INTEGER;
VAR inChar : CHAR;
VAR cycle: INTEGER;
VAR Delay: real;
VAR still_falling, was_dropped : BOOLEAN;
      
   PROCEDURE init;
   BEGIN
     Options.quit := FALSE;
     Options.Display_next := TRUE;
     wow.score := 0;
     wow.level := 1;
     wow.lines := 0;
     wow.stage := 1;
     wow.lines_target := 12;
     wow.random := 4;
     Seed_Initialize;
     SetUpScreen;       
     ClearGrid( grid );
     QIO_Write( vt100_esc+'[?25l' ); {Turn off cursor }
     QIO_Write( vt100_no_application_keypad );     {Numeric Keypad  }
     QIO_Write( vt100_esc+'[4l' );   {Replace Mode    }
     Next_Greebie.x_pos := 6;
     Next_Greebie.y_pos := 17;
     Greebie_Start := 4;
     play := TRUE;
     Is_Msg := FALSE;
     still_falling := TRUE;
     was_dropped := FALSE;
     cycle := 1; 
     delay := initial_delay;
     WITH greebie DO 
       BEGIN
          shape := Random( 7 ) ;
          rot := 1;
          x_pos := Greebie_start;
          y_pos := 1;
       END;
     Next_Greebie.shape := Random( 7 );
     Next_Greebie.rot := 1;
     PutShape( greebie, s_draw );
     Show_wow;
   END;

BEGIN{ GameLoop }
   init;
   QIO_Purge;
   {********************************}
   {*  Play Loop                    }
    WHILE play DO {Oh God, not Kathy playing again is it?}
      BEGIN
      Sleep( 0,delay );
      still_falling := TRUE;
      inchar := QIO_1_Char_Now;
      CASE Lower_Case(inchar) OF
         left_key  : Move_Left( greebie );
         right_key : Move_Right( greebie );
         down_key  : still_falling := Move_Down( greebie );   
         rotate_key: Rotate_Greebie( greebie );
         drop_key  : BEGIN
                       Drop_Greebie( greebie );
                       was_dropped := TRUE;
                     END;                      
         redraw_key: ReDraw_Complete_Screen( Next_Greebie );
         pause_key : Pause;
         quit_key  :  BEGIN
                        options.quit := True;
                        play := False; {Piker!}
                      END;
         END;
      cycle := cycle + 1;
      IF ((cycle = 6) AND (play)) OR (was_dropped) THEN
         BEGIN
         cycle := 1;
         IF was_dropped THEN
            BEGIN
            still_falling := FALSE;
            was_dropped := FALSE;
            END
         ELSE
            IF still_falling THEN
              still_falling := Move_Down( greebie );
         IF NOT( still_falling ) THEN BEGIN
            Show_Wow;
            play := Check_Resting( greebie, delay );
            Greebie := Next_Greebie;
            ClearNext( Next_Greebie );
            WITH greebie DO 
              BEGIN
              x_pos := Greebie_start;
              y_pos := 1;
              END;
            IF play THEN
              play := Check_Top( greebie );
            IF play THEN BEGIN
              Next_Greebie.shape := Random( 7 );
              Next_Greebie.rot := 1;
              PutShape( greebie,s_draw );
              DisplayNext( Next_Greebie );
            END;
          END;
         END;  
      END;
      QIO_Write( VT100_ESC+'[?25h' );  {turn cursor on again...}
   END;
      
PROCEDURE Introduction;
TYPE
    filenameStr = VARYING[40] OF CHAR;
VAR inkey : CHAR;
   infile : TEXT;

  PROCEDURE Show_File( filename : filenameStr );
  VAR line   : VARYING[127] OF CHAR;
      notopen: BOOLEAN;
      oc     : INTEGER;
  BEGIN
     notopen := TRUE; oc := 0;
     WHILE notopen DO
       BEGIN
       OPEN ( infile, filename, old, sharing := readonly, error:= continue );
       IF status( infile ) = 0 THEN
         BEGIN
         oc := oc + 1;
         notopen := FALSE;
         IF oc > 5 THEN
           BEGIN
           QIO_WriteLn( 'ERROR! Unable to open '+filename );
           Halt;
           END;
         END;
       END;
     RESET( infile );
     WHILE NOT( EOF( infile )) DO
        BEGIN
        Readln( infile, line );
        QIO_WriteLn( line );
        END;
     CLOSE( infile );
   END;

BEGIN
   Clear;
   QIO_Purge;
   Show_File( datafile1 );
   Sleep( 2, 0 );
   Show_File( datafile2 );
   REPEAT
     inkey := QIO_1_Char;
     IF (inkey = 'i') or  (inkey = 'I') THEN
     Show_File( datafile3 );
   UNTIL inkey = ' ';
END;

BEGIN
   Image_Dir;
   Introduction;
   InitShapes;
   GameLoop;

(*   Hall_Of_Fame( wow.score, wow.level ); *)  (* Use if desired - requires *)
                                               (*                  FAME.OBJ *)

   Top_Ten(  wow.score  );      (* Inherited from INTERACT library        *)
                                (*            - note: does not show Level *) 
END.   
   

