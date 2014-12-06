[
 ENVIRONMENT, INHERIT(
                      'INTERACT'
                     )
]

MODULE TetShapes( output );
{****************************************************************************
Inits, and draw shapes
****************************************************************************}

CONST 
      	ShapesMax = 18;
      	e = CHR(27);
      	inv = e+'[7m';
	nml = e+'[m';
        up  = e+'[A';
	up2 = e+'[2A';
	dn  = e+'[B';
        dn2 = e+'[2B';
	le  = e+'[D';
        le2 = e+'[2D';
        ri  = e+'[C';
        ri2 = e+'[2C';

CONST
        s_clear = 1;
        s_draw  = 0; 
        Grid_width = 10;
        Grid_length = 20;
        x_offset = 16;
        y_offset = 1;
        max_str_len = 255;

TYPE
        $ubyte = [BYTE] 0..255;
      	ShapeString = VARYING[30] OF CHAR;
        smArrayT    = ARRAY[0..3,0..3] OF $ubyte;

    shape_table = RECORD 
             ch : CHAR;
             max: INTEGER;
             pointv : ARRAY[0..4] OF INTEGER;
             sm_no : ARRAY[0..4] OF INTEGER;
             delta_x : ARRAY[0..4] OF INTEGER;
             END;


Greebie_Type = RECORD
                shape : INTEGER;
                rot   : INTEGER;
                x_pos, y_pos : INTEGER;
             END;

VAR 
        binshape : ARRAY [0..7] OF shape_table;
 
      	Shape  : ARRAY[1..7,1..4,0..1] OF ShapeString;
        sm     : ARRAY[0..18] OF smArrayT :=
                 ( ( (1,1,1,0),     
                     (0,1,0,0),     { object 0, shape 0 }
                     (0,0,0,0),     { *** }
                     (0,0,0,0) ),   {  *  }

                   ( (0,0,1,0),     {1 * }
		             (0,1,1,0),     { ** }
		             (0,0,1,0),     {  * }
                     (0,0,0,0) ),

                   ( (0,1,0,0),    {2  *  }
                     (1,1,1,0),    {  *** }
                     (0,0,0,0),
                     (0,0,0,0) ),

                   ( (1,0,0,0),    { *  3 }
                     (1,1,0,0),    { **   }
                     (1,0,0,0),    { *    }
                     (0,0,0,0) ),

                   ( (0,0,0,0),
                     (1,1,1,1),   
                     (0,0,0,0),   {object 1 4}
                     (0,0,0,0) ), { **** }

                   ( (0,1,0,0),    {5 * }
                     (0,1,0,0),    {  * }
                     (0,1,0,0),    {  * }
                     (0,1,0,0) ),  {  * }

                   ( (1,1,0,0),   
                     (0,1,1,0),   {object 2}
                     (0,0,0,0),   { 6 **  }
                     (0,0,0,0) ), {    ** }

                   ( (0,1,0,0),   {7  * }
                     (1,1,0,0),   {  ** }
                     (1,0,0,0),   {  *  }
                     (0,0,0,0) ),

                   ( (0,1,1,0),
                     (1,1,0,0), {object 3}
                     (0,0,0,0),   { 8   ** }
                     (0,0,0,0) ), {    **  }

                   ( (1,0,0,0),   {9  *  }
                     (1,1,0,0),   {   ** }
                     (0,1,0,0),   {    * }
                     (0,0,0,0) ),

                   ( (1,1,1,0),  {object 4}
                     (0,0,1,0), 
                     (0,0,0,0),  { 10 *** }
                     (0,0,0,0) ),{      * }

                   ( (0,0,1,0),  {11  * }
                     (0,0,1,0),  {    * }
                     (0,1,1,0),  {   ** }
                     (0,0,0,0) ),

                   ( (1,0,0,0), {12  *   }
                     (1,1,1,0), {    *** }
                     (0,0,0,0),
                     (0,0,0,0) ),

        		   ( (1,1,0,0),
                     (1,0,0,0),
                     (1,0,0,0),
                     (0,0,0,0) ),

        		   ( (1,1,1,0),   { Object 5 }
                     (1,0,0,0),
                     (0,0,0,0),
                     (0,0,0,0) ),

        		   ( (0,1,1,0),
                     (0,0,1,0),
                     (0,0,1,0),
                     (0,0,0,0) ),  

                   ( (0,0,1,0),
                     (1,1,1,0),
                     (0,0,0,0),
                     (0,0,0,0) ),

                   ( (1,0,0,0),
                     (1,0,0,0),
                     (1,1,0,0),
                     (0,0,0,0) ),

                   ( (1,1,0,0),
                     (1,1,0,0),
                     (0,0,0,0),
                     (0,0,0,0) ) );


PROCEDURE InitShapes;
{*****************************************************************************
Initialises shapes string
****************************************************************************}
BEGIN
	shape[1,1,0]:='. .'+dn+le2+'.';
	shape[1,2,0]:=ri2+'.'+dn+le2+'..'+dn+le+'.';
	shape[1,3,0]:=ri+'.'+dn+le2+'...';
	shape[1,4,0]:='.'+dn+le+'..'+dn+le2+'.';
	
	shape[2,1,0]:=dn+'////';
	shape[2,2,0]:=ri+'/'+dn+le+'/'+dn+le+'/'+dn+le+'/';
	shape[2,3,0]:=dn+'////';
	shape[2,4,0]:=ri+'/'+dn+le+'/'+dn+le+'/'+dn+le+'/';

	shape[3,1,0]:='--'+dn+le+'--';
	shape[3,2,0]:=ri+'-'+dn+le2+'--'+dn+le2+'-';
	shape[3,3,0]:='--'+dn+le+'--';
	shape[3,4,0]:=ri+'-'+dn+le2+'--'+dn+le2+'-';

	shape[4,1,0]:=ri+'``'+dn+le2+le+'``';
        shape[4,2,0]:='`'+dn+le+'``'+dn+le+'`';
	shape[4,3,0]:=ri+'``'+dn+le2+le+'``';
        shape[4,4,0]:='`'+dn+le+'``'+dn+le+'`';

	shape[5,1,0]:='[[['+dn+le+'[';
	shape[5,2,0]:=ri2+'['+dn+le+'['+dn+le2+'[[';
	shape[5,3,0]:='['+dn+le+'[[[';
	shape[5,4,0]:='[['+dn+le2+'['+dn+le+'[';

	shape[6,1,0]:=':::'+dn+le2+le+':';
	shape[6,2,0]:=ri+'::'+dn+le+':'+dn+le+':';
	shape[6,3,0]:=ri2+':'+dn+le2+le+':::';
	shape[6,4,0]:=':'+dn+le+':'+dn+le+'::';

	shape[7,1,0]:='++'+dn+le2+'++';
	shape[7,2,0]:='++'+dn+le2+'++';
	shape[7,3,0]:='++'+dn+le2+'++';
	shape[7,4,0]:='++'+dn+le2+'++';

	shape[1,1,1]:='   '+dn+le2+' ';
	shape[1,2,1]:=ri2+' '+dn+le2+'  '+dn+le+' ';
	shape[1,3,1]:=ri+' '+dn+le2+'   ';
	shape[1,4,1]:=' '+dn+le+'  '+dn+le2+' ';
	
	shape[2,1,1]:=dn+'    ';
	shape[2,2,1]:=ri+' '+dn+le+' '+dn+le+' '+dn+le+' ';
	shape[2,3,1]:=dn+'    ';
	shape[2,4,1]:=ri+' '+dn+le+' '+dn+le+' '+dn+le+' ';

	shape[3,1,1]:='  '+dn+le+'  ';
	shape[3,2,1]:=ri+' '+dn+le2+'  '+dn+le2+' ';
	shape[3,3,1]:='  '+dn+le+'  ';
	shape[3,4,1]:=ri+' '+dn+le2+'  '+dn+le2+' ';

	shape[4,1,1]:=ri+'  '+dn+le2+le+'  ';
        shape[4,2,1]:=' '+dn+le+'  '+dn+le+' ';
	shape[4,3,1]:=ri+'  '+dn+le2+le+'  ';
        shape[4,4,1]:=' '+dn+le+'  '+dn+le+' ';

	shape[5,1,1]:='   '+dn+le+' ';
	shape[5,2,1]:=ri2+' '+dn+le+' '+dn+le2+'  ';
	shape[5,3,1]:=' '+dn+le+'   ';
	shape[5,4,1]:='  '+dn+le2+' '+dn+le+' ';

	shape[6,1,1]:='   '+dn+le2+le+' ';
	shape[6,2,1]:=ri+'  '+dn+le+' '+dn+le+' ';
	shape[6,3,1]:=ri2+' '+dn+le2+le+'   ';
	shape[6,4,1]:=' '+dn+le+' '+dn+le+'  ';

	shape[7,1,1]:='  '+dn+le2+'  ';
	shape[7,2,1]:='  '+dn+le2+'  ';
  
   	shape[7,3,1]:='  '+dn+le2+'  ';
	shape[7,4,1]:='  '+dn+le2+'  ';

{--------------------------------------------------------------------------}
    { begin shape 1 definition, four rotations }

    binshape[1].ch := '.';
    binshape[1].max := 3;

    binshape[1].pointv[3] := 5; 
    binshape[1].sm_no[3] := 2;
    binshape[1].delta_x[3] := 0;

    binshape[1].pointv[4] := 5; 
    binshape[1].sm_no[4] := 3;
    binshape[1].delta_x[4] := 1;

    binshape[1].pointv[1] := 6; 
    binshape[1].sm_no[1] := 0;
    binshape[1].delta_x[1] := 0;

    binshape[1].pointv[2] := 5; 
    binshape[1].sm_no[2] := 1;
    binshape[1].delta_x[2] := 0;
   
    { begin shape 2 definition, four rotations }

    binshape[2].ch := '/';
    binshape[2].max := 4;

    binshape[2].pointv[1] := 5; 
    binshape[2].sm_no[1] := 4;
    binshape[2].delta_x[1] := 0;

    binshape[2].pointv[2] := 8; 
    binshape[2].sm_no[2] := 5;
    binshape[2].delta_x[2] := 0;

    binshape[2].pointv[3] := 5; 
    binshape[2].sm_no[3] := 4;
    binshape[2].delta_x[3] := 0;

    binshape[2].pointv[4] := 8; 
    binshape[2].sm_no[4] := 5;
    binshape[2].delta_x[4] := 0;


    { begin shape 3 definition, four rotations }

    binshape[3].ch := '-';
    binshape[3].max := 3;

    binshape[3].pointv[1] := 6; 
    binshape[3].sm_no[1] := 6;
    binshape[3].delta_x[1] := 0;

    binshape[3].pointv[2] := 7; 
    binshape[3].sm_no[2] := 7;
    binshape[3].delta_x[2] := 0;

    binshape[3].pointv[3] := 6; 
    binshape[3].sm_no[3] := 6;
    binshape[3].delta_x[3] := 0;

    binshape[3].pointv[4] := 7; 
    binshape[3].sm_no[4] := 7;
    binshape[3].delta_x[4] := 0;

   
    { begin shape 4 definition, four rotations }

    binshape[4].ch := '`';
    binshape[4].max := 3;

    binshape[4].pointv[1] := 6; 
    binshape[4].sm_no[1] := 8;
    binshape[4].delta_x[1] := 0;

    binshape[4].pointv[2] := 7; 
    binshape[4].sm_no[2] := 9;
    binshape[4].delta_x[2] := 0;

    binshape[4].pointv[3] := 6; 
    binshape[4].sm_no[3] := 8;
    binshape[4].delta_x[3] := 0;

    binshape[4].pointv[4] := 7; 
    binshape[4].sm_no[4] := 9;
    binshape[4].delta_x[4] := 0;


    { begin shape 5 definition, four rotations }

    binshape[5].ch := '[';
    binshape[5].max := 3;

    binshape[5].pointv[1] := 6;
    binshape[5].sm_no[1] := 10;
    binshape[5].delta_x[1] := 0;
   
    binshape[5].pointv[2] := 7; 
    binshape[5].sm_no[2] := 11;
    binshape[5].delta_x[2] := 1;

    binshape[5].pointv[3] := 6;
    binshape[5].sm_no[3] := 12;
    binshape[5].delta_x[3] := 0;

    binshape[5].pointv[4] := 7; 
    binshape[5].sm_no[4] := 13;
    binshape[5].delta_x[4] := 0;


    { begin shape 6 definition, four rotations }

    binshape[6].ch := ':';
    binshape[6].max := 3;

    binshape[6].pointv[3] := 6; 
    binshape[6].sm_no[3] := 16;
    binshape[6].delta_x[3] := 0;

    binshape[6].pointv[4] := 7; 
    binshape[6].sm_no[4] := 17;
    binshape[6].delta_x[4] := 0;

    binshape[6].pointv[1] := 6;
    binshape[6].sm_no[1] := 14;
    binshape[6].delta_x[1] := 0;
   
    binshape[6].pointv[2] := 7; 
    binshape[6].sm_no[2] := 15;
    binshape[6].delta_x[2] := 1;

    { begin shape 7 definition, four rotations }
   
    binshape[7].ch := '+';
    binshape[7].max := 2;

    binshape[7].pointv[4] := 6; 
    binshape[7].sm_no[4] := 18;
    binshape[7].delta_x[4] := 0;

    binshape[7].pointv[1] := 6; 
    binshape[7].sm_no[1] := 18;
    binshape[7].delta_x[1] := 0;

    binshape[7].pointv[2] := 6; 
    binshape[7].sm_no[2] := 18;
    binshape[7].delta_x[2] := 0;

    binshape[7].pointv[3] := 6; 
    binshape[7].sm_no[3] := 18;
    binshape[7].delta_x[3] := 0;

END;

PROCEDURE PutShape( Greebie : Greebie_Type; Clr : INTEGER );
BEGIN
   Posn( x_offset + Greebie.x_pos, y_offset+Greebie.y_pos );
   IF clr = s_draw THEN QIO_Write( Inv );
   QIO_Write( Shape[ Greebie.shape, Greebie.rot, clr ] );
   QIO_Write( Nml );
END;

PROCEDURE PutShape_Abs( Greebie : Greebie_Type; Clr : INTEGER );
BEGIN
   Posn( Greebie.x_pos, Greebie.y_pos );
   IF clr = s_draw THEN QIO_Write( Inv );
   QIO_Write( Shape[ Greebie.shape, Greebie.rot, clr ] );
   QIO_Write( Nml );
END;

PROCEDURE PutGrid( x,y: INTEGER; str : VARYING[ max_str_len ] OF CHAR );
BEGIN
   Posn( x_offset + x, y_offset + y );
   QIO_Write( str );
END;

PROCEDURE DrawHoriz ( InCh : CHAR; Length : INTEGER );
VAR  Str : VARYING[81] OF CHAR;
     I, J : integer;
BEGIN
   Str := '';
   Str := PAD( Str, InCh, length );
   QIO_Write( Str );
END;

{***************************************************************************
PROCEDURE BOX:
UpLCnrX    - X upper left
UpLCnrY    - Y upper left
width      - width of box
length     - length of box
Clr        - Clear inside of box
State      - 0= clear box border
             1= draw box border
***************************************************************************}
PROCEDURE BOX ( UpLCnrX, UpLCnrY, width, length, Clr : integer; 
                State : INTEGER  );

VAR  Str : VARYING[81] OF CHAR;
     ChrAr: ARRAY[1..6,0..1] OF CHAR;
     x, y : integer;
     i : INTEGER;
BEGIN
   ChrAr[1,1] := 'x'; 
   ChrAr[2,1] := 'q';
   ChrAr[3,1] := 'l';
   ChrAr[4,1] := 'k';
   ChrAr[5,1] := 'm';
   ChrAr[6,1] := 'j';
   FOR i := 1 TO 6 DO
      ChrAr[i,0] := ' '; 
   Posn( UpLCnrX, UpLCnrY );
   QIO_Write ( VT100_esc+'(0'+ChrAr[3,State] );
   DrawHoriz( ChrAr[2,State], width-2 );
   QIO_Write ( ChrAr[4,State] );
   FOR y := 1 TO (Length -1 ) DO BEGIN 
          Posn( UpLCnrX, UpLCnrY + y ); 
          QIO_Write( ChrAr[1,State] );
          IF Clr = -1 THEN 
               DrawHoriz (' ', width-2 )
          ELSE
               Posn(UpLCnrX + width -1, UpLCnrY + y );
          QIO_Write( ChrAr[1,State] );
      END;
   Posn( UpLCnrX, UpLCnrY + length );
   QIO_Write ( ChrAr[5,State] );
   DrawHoriz( ChrAr[2,State], width -2);
   QIO_Write ( ChrAr[6,State]+ VT100_esc + '(B' );
END;               


PROCEDURE Set40Screen;
VAR i : integer;
BEGIN
  FOR i := 1 TO 24 DO BEGIN
     Posn( 1, i );
     QIO_Write( VT100_esc+'#6' );
  END;
END;


END.


