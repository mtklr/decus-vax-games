[inherit('sys$library:starlet')]

Program Centiped(Input,Output,Help_File);

Const

   Screen_Row	= 23;
   Screen_Col   = 40;     

   Esc		=  Chr(27);
   Home_52	= ''(27)'H';
   Clear_52	= ''(27)'J';
   Graphics_52	= ''(27)'F';
   English_52   = ''(27)'G';
   VT52		= ''(27)'[?2l';
   VT100	= ''(27)'<';
   Large_100	= ''(27)'#6';
   Scroll_100	= ''(27)'[1;24r';
   Line		= ''(13)''(10)'';
   Home_100	= ''(27)'[H';
   Clear_100	= ''(27)'[2J';

   Init_Move_When  = 12; { Move once Every 10 Moves }
   Moves_per_Drop  = 51; { 100 moves Before Spider drops mush ( Must Be Odd )}
   Init_num_Mushs  = 20; { min 30 Mushrooms on sreen } 

Type 

   Ptr_Segment_rec = ^Segment_Rec;

   Segment_rec	= Record
     Prev	,
     Next	: Ptr_Segment_Rec;
     Row	,
     Col	: Integer;
   end;

   Ptr_Head_Tail_Rec = ^Head_Tail_Rec;

   Head_Tail_Rec = Record
      Prev	 ,
      Next	 : Ptr_Head_Tail_Rec;
      Head	 : Ptr_Segment_rec;
      Tail	 : Ptr_Segment_rec;
      Rel_Col	 : Integer;
   end;

   Screen_Objects = ( Blank, Weak_Mushroom, Strong_Mushroom,
   			  Weak_Mush_Seg , Strong_Mush_Seg ,
		  	  Cannon, Wall, Earth, Cent , Shot );

   Screen_Board	  = array [1..Screen_Row] of packed array [1..Screen_COl] of
   			Screen_Objects;   

   Buffer_st	= Packed array [1..256] of Char;

   Buffer_Rec	= Record
      Len       : Integer;
      String    : Buffer_st;
   end;

Var 
   Screen	  : Screen_Board;
   You_Col	  ,
   num_MOves	  ,
   Last_Row	  ,
   Last_Col	  : Integer;

   Help_File	  : Text;

   Seed 	  : Real ;

   Shot_Going	  : Boolean;

   Score	  , 
   Lives	  , 
   num_Mush	  ,
   Num_Cent       , 
   Move_When	  , 
   Spider_Row	  ,
   Spider_Col	  ,
   Spider_DCol    ,
   Spider_DRow	  ,
   Shot_Row	  ,
   Shot_Col	  : Integer;

   Exit	    	  : boolean;
   Out 		  : Buffer_rec;
   
   Cent_List	  : Ptr_Head_Tail_Rec;
   

   (*****************************************)

   procedure Write_5( ch1,ch2,ch3,ch4,ch5 : CHar);
   
   Begin
    Out.len := Out.len + 1;
    Out.String[Out.len] := Ch1;
    Out.len := Out.len + 1;
    Out.String[Out.len] := Ch2;
    Out.len := Out.len + 1;
    Out.String[Out.len] := Ch3;
    Out.len := Out.len + 1;
    Out.String[Out.len] := Ch4;
    Out.len := Out.len + 1;
    Out.String[Out.len] := Ch5;
   end;
   

   procedure Write_4( ch1,ch2,ch3,ch4 : CHar);
   
   Begin
    Out.len := Out.len + 1;
    Out.String[Out.len] := Ch1;
    Out.len := Out.len + 1;
    Out.String[Out.len] := Ch2;
    Out.len := Out.len + 1;
    Out.String[Out.len] := Ch3;
    Out.len := Out.len + 1;
    Out.String[Out.len] := Ch4;
   end;
   


   procedure Write_3( ch1,ch2,ch3 : CHar);
   
   Begin
    Out.len := Out.len + 1;
    Out.String[Out.len] := Ch1;
    Out.len := Out.len + 1;
    Out.String[Out.len] := Ch2;
    Out.len := Out.len + 1;
    Out.String[Out.len] := Ch3;
   end;
   


   procedure Write_2( ch1,ch2 : CHar);
   
   Begin
    Out.len := Out.len + 1;
    Out.String[Out.len] := Ch1;
    Out.len := Out.len + 1;
    Out.String[Out.len] := Ch2;
   end;
   


   procedure Write_1( ch1 : CHar);
   
   Begin
    Out.len := Out.len + 1;
    Out.String[Out.len] := Ch1;
   end;
   



   Procedure Sleep( VAR Sec : [READONLY] integer );extern;

   Procedure Sleep_Set( VAR Efn , sec : [READONLY] integer );extern;

   Procedure Sleep_start;extern;

   Procedure Sleep_Wait;extern;

   [asynchronous,unbound] 

   Procedure tt_write( var buff : buffer_st ;
				var len : [READONLY] integer );extern; 
      
   Procedure  image_dir; extern;


   procedure At(Row,Col:Integer);
   
   Begin 
      If ( Abs(Row-Last_Row) <= 2 ) and ( Abs(Col-Last_Col) <= 2 ) Then Begin 
	 Case ( Row - Last_Row )*5 + ( Col - Last_Col)  of 
	  { Up  ,       -2, 0  } -10 : Write_4(Esc,'Y',Chr(31+Row),Chr(31+Col));
	  { Up  ,LEft   -2,-1  } -11 : Write_4(Esc,'Y',Chr(31+Row),Chr(31+Col));
	  { Up  ,LEft   -2,-2  } -12 : Write_4(Esc,'Y',Chr(31+Row),Chr(31+Col));
	  { Up  ,Right  -2, 1  }  -9 : Write_4(Esc,'Y',Chr(31+Row),Chr(31+Col));
	  { Up  ,Right  -2, 2  }  -8 : Write_4(Esc,'Y',Chr(31+Row),Chr(31+Col));
	  { Up  ,LEft   -1,-2  }  -7 : Write_4(Esc,'Y',Chr(31+Row),Chr(31+Col));
	  { Up  ,LEft   -1,-1  }  -6 : write_3(Esc,'A',chr(8));
	  { Up  ,       -1, 0  }  -5 : write_2(Esc,'A');
	  { Up  ,Right  -1, 1  }  -4 : Write_4(Esc,'Y',Chr(31+Row),Chr(31+Col));
	  { Up  ,Right  -1, 2  }  -3 : Write_4(Esc,'Y',Chr(31+Row),Chr(31+Col));
	  {     ,Left    0,-2  }  -2 : write_2(chr(8),chr(8));
	  {     ,Left    0,-1  }  -1 : write_1(chr(8));
	  {     ,        0, 0  }   0 : ; 
	  {     ,Right   0, 1  }   1 : write_2(Esc,'C');
	  {     ,Right   0, 2  }   2 : Write_4(Esc,'Y',Chr(31+Row),Chr(31+Col));
	  { Down,Left    1,-2  }   3 : write_3(Chr(10),Chr(8),chr(8));
	  { Down,Left    1,-1  }   4 : write_2(Chr(10),Chr(8));
	  { Down         1, 0  }   5 : Write_1(Chr(10));
	  { Down,Right   1, 1  }   6 : Write_3(Chr(10),Esc,'C');
	  { Down,Right   1, 2  }   7 : Write_4(Esc,'Y',Chr(31+Row),Chr(31+Col));
	  { Down,Left    2,-2  }   8 : Write_4(Esc,'Y',Chr(31+Row),Chr(31+Col));
	  { Down,Left    2,-1  }   9 : write_3(Chr(10),chr(10),Chr(8));
	  { Down         2, 0  }  10 : Write_2(Chr(10),chr(10));
	  { Down,Right   2, 1  }  11 : Write_4(Esc,'Y',Chr(31+Row),Chr(31+Col));
	  { Down,Right   2, 2  }  12 : Write_4(Esc,'Y',Chr(31+Row),Chr(31+Col));
	 end;
      end else  Begin
	 Write_4(Esc,'Y',Chr(31+Row),Chr(31+Col));
      end;
      Last_Row := Row;
      Last_Col := Col;
      If Col >= 40 Then 
	  Last_Col := 40;
   end;
   

   Procedure Break;
   
   Begin
    TT_write(Out.String,Out.Len); 
    Out.Len := 0;
   end;

   Procedure Write_st( Write_String : Packed array [lb..ub:Integer] of char );

   Var Pos : Integer;

   Begin { Write_St }
      For  Pos := 1 to ub do 
        Out.String[Out.Len+pos] := Write_String[pos];
      Out.Len := Out.Len + ub;
      Last_Col := 8888;
   End; { Write_St }



   Procedure Write_sub_st( Write_String : Packed array [lb..ub:Integer] of char ; Len : Integer);

   Var Pos : Integer;

   Begin { Write_sub_St }
      For  Pos := 1 to Len do 
        Out.String[Out.Len+pos] := Write_String[pos];
      Out.Len := Out.Len + Len;
      Last_Col := 8888;
   End; { Write_sub_St }


   Procedure Write_ch( Row,Col : Integer ; Ch : Char );

   Var Pos : Integer;

   Begin { Write_CH }
      At(Row,Col);
      Out.Len := Out.Len + 1;
      Out.String[Out.Len] := Ch;
      Last_Col := Last_Col + 1;
      If Col >= 40 Then 
	  Last_Col := 888;
   End; { Write_ch }




   procedure TT_init( one : integer );extern;
   


   Function TT_1_Char_now:Char;extern;

   Function TT_1_Char:Char;extern;
   


   Procedure TT_Cancel;extern;
   

   Function Random( lb,ub : Integer):integer;

     Function Mth$Random( Var Seed : Real):Real;extern;

   Begin
     Random := lb + Trunc(Mth$Random(Seed)*(ub-lb+1));
   end;

   (*****************************************)

   Procedure Delete_Segment( var Shot_Row, Shot_Col : integer );

   var 
      Cent_Segment  : Ptr_Segment_rec;
      New_Cent	    ,
      Cent_Search   : Ptr_Head_Tail_rec;   
      Found         : Boolean;


   Begin { Delete_Segment }
       Write_ch(Shot_Row,Shot_Col,'O');
       Screen[Shot_Row,Shot_Col] := Strong_Mush_Seg;
      { Now to Find What Snake Hit }
      Found := false;
      Cent_Search := Cent_list;
      While ( Not Found ) and ( Cent_Search <> nil ) Do begin
	With Cent_Search^ do 
	 If ( Shot_Row = Head^.Row ) and ( Shot_Col = Head^.Col ) Then Begin
	    If Head^.Next = nil Then begin { Zapped Whole Cent }
	       If Cent_List = Cent_Search Then Begin 
		  Dispose(Head);
		  Cent_list := Cent_list^.next;
		  dispose(Cent_Search);
		  Found := true;
	       end else begin 
		  Dispose(Head);
		  Cent_Search^.Prev^.Next := Cent_Search^.Next;
		  If Cent_Search^.Next <> nil Then 
		    Cent_Search^.next^.Prev := Cent_Search^.Prev;
		  Dispose(Cent_Search);			
		  Found := true;
	       end;		  		     	    
	    end else Begin { Head <> nil }
	       Cent_Segment := Head;
	       Head := Head^.Next;
	       Head^.Prev := nil;
	       Dispose(Cent_Segment);
	    end;
	 end Else 
	    If ( Shot_Col = Tail^.Col ) and ( Shot_Row = Tail^.Row ) Then Begin
	       Cent_Segment := Tail;
	       Tail := Tail^.Prev;
	       Tail^.Next := nil;
	       Dispose(Cent_Segment);
	    end Else Begin { Might Have Shot in 1/2 }
	       Cent_Segment := Head^.Next;
	       While ( Cent_Segment <> nil ) and ( Not Found ) Do Begin
		  If ( Cent_Segment^.Row = Shot_Row ) and 
		     ( Cent_Segment^.Col = Shot_Col ) Then Begin
   		     Move_When := Move_When - 1;
   		     If MOve_When <= 1 Then 
   		        Move_When := 2;
		     Found := true;
		     New(new_Cent);
		     New_Cent^.Next := Cent_Search^.Next;
		     New_Cent^.Prev := Cent_Search;
		     Cent_Search^.Next := New_Cent;
		     If New_Cent^.Next <> nil then 
		       New_Cent^.Next^.Prev := New_Cent;
   
		     New_Cent^.Head := Cent_Segment^.Next;
		     New_Cent^.Head^.Prev := nil;
		     New_Cent^.Tail := Cent_Search^.Tail;
   		     If Screen[New_Cent^.Head^.Row,New_Cent^.Head^.Col+1] = Strong_Mushroom Then 
		       New_Cent^.Rel_Col := 1
   		     else
		       New_Cent^.Rel_Col := -1;
		     Cent_Search^.Tail := Cent_Segment^.Prev;
		     Cent_Search^.Tail^.Next := nil;
		     Dispose(Cent_Segment);
		  end Else
		   Cent_segment := Cent_Segment^.Next;
	       end;
	    end;		     
	  Cent_Search := Cent_Search^.Next;
       end;
   end; { Delete_Segment }

   (*****************************************)

   Procedure Move_Cent;
	    
   Const 

      Base_Head_Row = 2;
      base_Head_Col = 39;	    
      init_Len_Cent = 12;
      
   Var
 
      Prev_Segment ,		  
      New_Head	   ,
      segment      : Ptr_Segment_rec;   
      Cent_to_Move : Ptr_Head_Tail_Rec;
      Cnt	   : Integer;
      Len_Cent ,
      Head_Row, Head_Col : integer;	 	    	 



		  
      Procedure Add_Head( Row, Col : integer);
			      
      Var 
	 Segment : Ptr_Segment_rec;

      begin
	 New(Segment);
	 With Cent_to_move^ Do Begin
	    Segment^.Row := Row;
	    Segment^.Col := Col;
	    Segment^.Next := head;
	    Head^.Prev := Segment;
	    Segment^.Prev := nil;
	    Head := Head^.Prev;
   	    Screen[Tail^.Row,Tail^.Col] := Blank;
	    Write_Ch(Tail^.Row,Tail^.Col,'~');
	    Segment := Tail;
	    Tail := Tail^.Prev;
   	    Tail^.Next := nil;
	    Dispose(Segment);
	    Write_ch(Head^.Row,Head^.Col,'a');
   	    Screen[Head^.Row,Head^.Col] := Cent;
	 end;      	 	 
      end;      		  

      Procedure Move_this_Cent( Var Cent_to_move : Ptr_Head_tail_Rec );
   
      Var Dir : Integer;

      begin 
	 With Cent_to_move^ Do begin 
	    Case Screen[Head^.Row,Head^.Col+Rel_Col] of 
	       Blank 	     : 
		  Add_Head( Head^.Row, Head^.Col+Rel_Col);
	       Wall	     ,
	       Cent	     , 
   	       Weak_Mush_Seg ,
   	       Strong_Mush_Seg ,
	       Weak_Mushroom   ,
	       Strong_Mushroom : Begin   		
		  Case Screen[Head^.Row+1,Head^.Col] Of 
   	             Weak_Mush_Seg ,
   	             Strong_Mush_Seg ,
		     Weak_Mushroom   ,
		     Strong_Mushroom : Begin
   		       If Screen[Head^.Row+1,Head^.Col+Rel_Col] 
   			   = Blank  Then 
   		         Add_Head( Head^.Row+1,Head^.Col+Rel_Col )
   		       else Begin
   			 Rel_Col := Rel_Col * ( -1 );
   		         If Screen[Head^.Row+1,Head^.Col+Rel_Col] 
   			      = Blank Then 
   		           Add_Head( Head^.Row+1,Head^.Col+Rel_Col )
   		         Else Begin 
   			   Case Random(1,3) of 
   			     1 : Dir := 1;
   			     2 : Dir := -1;
   			     3 : Dir := 0;
   			   end;
   			   If Screen[ Head^.Row + 1, Head^.Col + Dir ] in 
   				[ Strong_Mushroom, Weak_Mushroom , 
     				  Weak_Mush_Seg ,Strong_Mush_Seg ] Then Begin
   			     If Screen[ Head^.Row + 1, Head^.Col + Dir ] in 
   				[ Strong_Mushroom, Weak_Mushroom ] Then 
   			        num_Mush := Num_Mush - 1;
		              Add_Head( Head^.Row + 1, Head^.Col+Dir);
   			   end;
   			 End;
   		       end;
		     end;
		     Blank	 : Begin
			Rel_Col := Rel_Col * ( -1 );
			Add_Head( Head^.Row + 1, Head^.Col);
		     End;
		     Cannon	 , 
		     Earth	 : Exit := true;
		  otherwise
		     { Nothonmg } ;
		  end; { case }			   
   	       end;
	       Cannon	     ,
	       Earth	     : 
		  exit := true;			
	    Otherwise 
	      { Nothong };
	    end; { case } 
	 end;      
      end;

   Begin { Update_Cents }
      If Cent_List = nil Then Begin  { no More Cents }
	 New(Cent_List);
	 With Cent_List^ do Begin 
   	    Num_Cent := Num_Cent + 1;
   	    Move_When := Init_Move_When - Num_Cent;
   	    If Move_When <= 1 Then 
  		Move_When := 2;
   	    Len_Cent  := init_len_Cent + num_Cent;
   	    IF Len_Cent >= Base_Head_Col Then   	    
   		Len_Cent := Base_Head_Col - 2;
	    Next := nil;
	    Head := nil;
	    Prev := nil;
	    Tail := nil;
	    Rel_Col := -1; 	    
	    Prev_Segment := nil;	    
	    For Cnt := 1 to Len_Cent do begin 
	       New(segment);
	       If Head = nil Then Begin
		  Head := segment;
	       end; { if }		  
	       With segment^ Do begin 
		  Row := base_Head_Row;
	          Col := Base_Head_Col - Len_Cent + Cnt - 1;
   		  Screen[Row,Col] := Cent;
	    	  Write_Ch(Row,Col,'a');
	    	  Segment^.Next := nil;
	    	  Segment^.Prev := Prev_segment;
	    	  If Prev_Segment <> nil Then 
	    	     Prev_segment^.Next := segment;
	       end;{ With }
               Prev_Segment := Segment;
	    end;{ For } 
	    Tail := segment;   
	 End { With }	    	       
      End Else Begin 
	 Cent_to_Move := Cent_list;
	 While Cent_to_Move <> nil Do begin 
	    Cnt := 0;
	    While ( Cnt < ( num_Moves Mod Move_When ) ) And 
	 	  ( Cent_to_Move <> nil ) Do Begin
	      Cent_to_Move := Cent_to_move^.next;
	      Cnt := Cnt + 1;
	    End;
	    If Cent_to_Move <> nil Then Begin
   	       MOve_this_Cent( Cent_to_move );
   	       While ( Cnt < move_When ) and ( Cent_to_Move <> nil ) Do Begin 
   	         Cent_to_move := Cent_to_move^.NExt;
   		 Cnt := Cnt + 1;
   	       End;
   	    end;
	 end;
      End;
   End; { Move_Cents }

   Procedure Set_up;
      
   Var len,Cnt,Row,Col : Integer;
       Help_Line   : Varying [256] of Char;


   Begin { Set_up }
     TT_init(1);
     Image_Dir;
     Out.len := 0;
     OPen(Help_FIle,'IMAGE_DIR:Centipede.Scn', 
   	History := Readonly, error := continue);
     If Status(Help_File) = 0 Then Begin
      Reset(Help_File);
      While Not Eof(Help_File) Do Begin
        Readln(Help_File,Help_Line);
        Len := Help_Line.Length;
        TT_Write(Help_Line.Body,Len);	    
      End;
     End Else Begin
      Write_st(' Can''t find help screen. Type <Return> to play ');
      Break;
     End;
     TT_1_Char; { Wait til hit a char }
     Seed := Clock;
     Score := 50;
     Lives := 3;
     num_MOves := 1;     
     num_Cent := 0;
     Write_St(Vt100);
     Write_St(Scroll_100);
     Write_st(home_100);
     Write_st(clear_100);
     For Row := 1 to ( Screen_Row + 1 ) Do Begin
       Write_st(Large_100); 
       Write_st(line);
     end;
     Write_st(Large_100); 
     Write_st(Vt52);
     Break;
     Write_st(Home_52);
     Write_st(Graphics_52); 
     Write_st('lqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqk');
     Write_st(Line);
     Break;

     For Col := 1 to Screen_Col do Begin
      Screen[1,Col] := Wall;
      Screen[Screen_Row,Col] := Earth;
     end;     

     For Row := 2 to Screen_Row - 1 do begin
      Screen[Row,1] := Wall;
      Screen[Row,Screen_Col] := Wall;
      For Col := 2 to Screen_Col - 1 do 
	 Screen[Row,Col] := Blank;
      Write_st('x~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~x');
      Write_st(line);
      Break;
     end;
     Write_st('mqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqj');
     Write_st(Home_52);
     At(Screen_Row+1,1);
     Write_st(' aq aq ');
     Break;
     For Cnt := 1 to init_num_Mushs Do begin
	 Row := Random(2,Screen_Row-2);
	 Col := Random(2,Screen_Col-1);
	 Screen[Row,Col] := Strong_Mushroom;
	 Write_ch(Row,Col,'O');
   	 Break;
     end;
     You_Col := 20;
     Write_Ch(Screen_Row-1,You_Col,'x');
     Write_Ch(Screen_Row,You_Col,'a');
     Screen[Screen_Row-1,You_Col] := Cannon;
     Spider_Row  := 2;
     Spider_Col  := 10;
     Spider_DRow := 1;
     Spider_DCol := 1;
     Write_Ch(2,10,'*');
     num_mush := init_num_Mushs;
     Break;
   end; { Set_up }	    

   Procedure Move_You;

   var 
     Move : integer;

   begin
     Move := 0;
     case TT_1_Char_Now of 
   	'1','<',',' : Move := -1;
   	'3','>','.' : Move := 1;
        '4'  : Move := -2;
   	'6'  : MOve :=  2;
        '7'  : Move := -3;
        '9'  : Move :=  3;
        'e','E','q','Q' : Exit := true;
        '2','5','8',' '     : If Not Shot_Going Then begin
		      Shot_Going := true;
		      Shot_Row    := Screen_Row - 1;
		      Shot_Col    := You_Col;
      		      Score := Score - 2;
   		  End;
     Otherwise 
       { Nothing };
     end;
     If Move <> 0 Then 
       If ( You_Col+Move  >  1 	        ) and 
   	  ( You_Col+Move  <  Screen_Col ) Then Begin
          Write_Ch(Screen_Row-1,You_Col,'~');
          Write_Ch(Screen_Row,You_Col,'q');
   	  Screen[Screen_Row-1,You_Col] := blank;
   	  Screen[Screen_Row,You_Col] := Earth;
   	  You_Col := You_Col + Move;
   	  Screen[Screen_Row,You_Col] := Cannon;
   	  Screen[Screen_Row-1,You_Col] := Cannon;
          Write_Ch(Screen_Row-1,You_Col,'x');
          Write_Ch(Screen_Row,You_Col,'a');
        end;
   end;

   Procedure Add_score( Num : Integer );

   var 
      Score_String : Packed array [1..30] of char;
      Len 	   : [word] 0..65535; 

   Begin 
     Score := Score + num;
     $FAO( ctrstr := '[!UL]', outlen := len , outbuf := score_string, 
       p1 := %immed Score );
     Last_Col := 8888;
     At( 1 , ( Screen_Col - Len ) Div 2 + 1);     
     Write_Sub_st( Score_String , Len );
   end;

   Procedure Move_Shot;

   Const Speed_Shot = 2;     

   Var
      Cnt : integer;

   Begin { Move_Shot }
     For Cnt := 1 to Speed_Shot Do 
      If Shot_Going then begin
   	If Screen[Shot_Row,Shot_Col] = Shot Then Begin
   	  Screen[Shot_Row,Shot_Col] := Blank;
   	  Write_ch(Shot_Row,Shot_Col,'~');
        end;
   	Shot_Row := Shot_Row - 1;
        Case Screen[Shot_Row,Shot_Col] of 
   	  Blank         : begin
	    Screen[Shot_Row,Shot_Col] := Shot;
	    Write_ch(Shot_Row,Shot_Col,'x');
	  end;
   	  Weak_Mush_Seg  : Begin
	    Screen[Shot_Row,Shot_Col] := Blank;
	    Write_ch(Shot_Row,Shot_Col,'~');
   	    Shot_going := false;
      	    Add_Score(10);
   	  end;
   	  Weak_Mushroom  : Begin
   	    num_Mush := num_Mush - 1;
	    Screen[Shot_Row,Shot_Col] := Blank;
	    Write_ch(Shot_Row,Shot_Col,'~');
   	    Shot_going := false;
      	    Add_Score(10);
	  end;
	  Strong_Mushroom : Begin 
	    Screen[Shot_Row,Shot_Col] := Weak_Mushroom;
	    Shot_Going := false;
	  end;
   	  Strong_Mush_Seg : Begin
	    Screen[Shot_Row,Shot_Col] := Weak_Mush_Seg;
	    Shot_Going := false;
   	  end;
	  Cent	: begin
      	    Add_Score(100);
   	    Delete_Segment(Shot_Row,Shot_Col);
	    Shot_Going := false;
	  end;
       Otherwise 
	  Shot_Going := false;
       end;	    
     end;
   end; { move_Shot }

   Procedure Move_Spider;

      Procedure Loose_Life;

      Begin { Loose_Life }
       Lives := lives - 1;
       If Lives > 0 Then Begin 
	  At(Screen_Row + 1,1+(Lives-1)*3);
	  Write_st('   ');
	  Write_Ch(1,1,Chr(7));
	  Write_Ch(1,1,Chr(7));
	  Break;
          Spider_Row  := 2;
	  Spider_Col  := 10;
	  Spider_DRow := 1;
	  Spider_DCol := 1;
	  Write_Ch(2,10,'*');
	  Sleep(1);
       end else 
   	 Exit := true;
      end; { Loose_life }
   
   Begin { move_Spider }   
   Case Screen[Spider_Row , Spider_Col ] OF 
      Cent            : Write_Ch(Spider_Row,Spider_Col,'a');
      Strong_Mush_Seg ,
      Weak_Mush_Seg   ,
      Strong_Mushroom ,
      Weak_Mushroom   : Write_Ch(Spider_Row,Spider_Col,'O');
      Blank	      : Begin 
	 If  ( Spider_Row < Screen_Row - 1 ) and 
   	     ( Spider_Row > ( Screen_Row Div 3 ) ) and 
   	     ( Num_Mush < Init_num_Mushs  ) then Begin
   	  If ( Random(1, 
                  Screen_Row - Spider_Row ) = 1 ) Then Begin
	     Screen[Spider_Row,Spider_Col] := Strong_Mushroom;
	     Write_Ch(Spider_Row,Spider_Col,'O');	   
	     Num_Mush := num_Mush + 1;
   	   end else 
	     Write_Ch(Spider_Row,Spider_Col,'~');
	 End else 
	   Write_Ch(Spider_Row,Spider_Col,'~');
      end;
      Cannon	      : Loose_Life;
     Otherwise ;  
   end; { case }
   Case Screen[Spider_Row + Spider_DRow ,Spider_Col + Spider_DCol] Of       
      Cent            ,
      Strong_Mush_Seg ,
      Weak_Mush_Seg   ,
      Strong_Mushroom ,
      Weak_Mushroom   ,
      Blank	      : Begin 
      	Spider_Row := Spider_Row + Spider_DRow;
      	Spider_Col := Spider_Col + Spider_DCol;
      	Write_Ch(Spider_Row,Spider_Col,'*');
      end;
      Wall, Earth     : Begin
	 If ( Spider_Row + Spider_DRow = Screen_Row ) or 
	    ( Spider_Row + Spider_DRow = 1 )  Then 
	   Spider_DRow := Spider_DRow * ( -1 );
	 If ( Spider_Col + Spider_DCol = Screen_Col ) or 
	    ( Spider_Col + Spider_DCol = 1 )  Then 
	   Spider_DCol := Spider_DCol * ( -1 );
      end;
      Cannon	      : Loose_LIfe;
    Otherwise ; 
   End; { case }
   end; { move_Spider }

   Procedure Top_Ten( Var Score : Integer );extern;

Begin { mainline }
 Set_up;
 Sleep_Set( 1, 20 );
 While not exit do begin 
   Sleep_Start;
   num_Moves := num_Moves + 1;
   Move_Cent;
   If Odd(num_Moves) Then 
     Move_Spider;
   Break;	 
   Move_You;
   If Shot_Going THen 
     Move_Shot;
   Sleep_wait;
 end;
 Write_Ch(1,1,Chr(7));
 Write_Ch(1,1,Chr(7));
 Write_Ch(1,1,Chr(7));
 Break;   
 Sleep(1);
 TT_Cancel;
 Top_Ten(Score);
end.
