	SUBROUTINE	HELP_SCREEN
C
	PARAMETER ESC = 27
	CHARACTER Line*256
        BYte REP
	INTEGER Len_Line,ErrNum
C
	CALL image_dir()
C
        Write(5,111)esc
111     Format(X,A1,'<')
1	OPEN(UNIT=4,FILE='IMAGE_DIR:SNAKE.SCN',ReadOnly,
	1 STATUS='OLD',IoStat=ErrNum)
        If (ERRNUM.EQ.30) Goto 50
        If (ERRNUM.NE.0 ) Goto 999
100     READ(4,110,END=200) LEN_LINE, LINE(:LEN_LINE)
110     FORMAT(Q,A)
        WRITE(5,120) LINE(:LEN_LINE)
120     FORMAT(1X,A)
        GOTO 100
200	close (unit = 4)
999	RETURN
C
50	Write(5,51),Esc,Esc
51      FORMAT(X,A1,'[2J',A1,'[1;1HPlease wait...')
        Call Sleep(4)
        Goto 1
C
        END
