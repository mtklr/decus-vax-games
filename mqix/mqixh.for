			SUBROUTINE	Help_Screen
C
	PARAMETER ESC = 27
	CHARACTER Line*256
	BYTE LINEL(256)
	EQUIVALENCE (LINE, LINEL)
        BYte REP
	INTEGER Len_Line,ErrNum
C
        type 111, esc
111     Format(X,A1,'<')
1	OPEN( UNIT=4, FILE='Games:MQixH.Scn', ReadOnly,
	1 STATUS='OLD',IoStat=ErrNum)
        If (ERRNUM.EQ.30) Goto 50
        If (ERRNUM.NE.0 ) Goto 999
100     READ(4,110,END=200) LEN_LINE, LINE(:LEN_LINE)
110     FORMAT(Q,A)
	Call Snake_write(%ref(LIne(:len_line)),Len_line)
        GOTO 100
200	close (unit = 4)
999	RETURN
C
50	write(Line,51),Esc,Esc
51      FORMAT(X,A1,'[2J',A1,'[1;1HPlease wait...')
        Call Snake_Write(%ref(Line(1:25)),25)
	Call Sleep(4)
        Goto 1
        END
