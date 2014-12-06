$ Facility_Name=	"HI-Q"
$ Facility_Version=	"V-1.00 18-Mar-1988"
$ Verify=F$Verify(F$TRNLNM("COMMAND_DEBUG"))
$ On Control_Y then goto Exit
$ Set Symbol/Scope=NoGlobal
$!
$! Copyright © (c) 1988, by Michael Bednarek
$! The distribution of this file is unrestricted as long as this notice
$! remains intact.
$!
$! Michael Bednarek, Institute of Applied Economic and Social Research (IAESR)
$!    //  Melbourne University,Parkville 3052, AUSTRALIA, Phone:+61 3 344 5744
$!  \X/   Domain:u3369429@{murdu.oz.au | ucsvc.dn.mu.oz.au} | mb@munnari.oz.au
$!        "bang":...UUNET!munnari!murdu!u3369429     PSI%23343000301::U3369429
$!
$ Say="Write SYS$Output"
$ Ask="Inquire/NoPunctuation"
$!
$ Gosub Intro
$ Say "Initializing ..."
$ On Control_Y then goto EndGame
$ Gosub Init
$NewGame: Gosub InitTable
$ Gosub DrawBoard
$!
$GetInput:
$ Say CSI,"1;1H"	! set the cursor always at the top to prevent scrolling
$ Ask Command ""
$ Cmd=Command-"J"
$ Jump=Cmd.nes.Command
$ If F$Locate(".''Cmd'.",Commands).ne.lCommands then gosub 'Cmd
$ Goto GetInput
$EndGame: Set Key/State=DEFAULT/NoLog
$ Delete/Key/NoLog/All/State=(Curious,Curiouser)
$ Set Terminal/NoApplication_Keypad/Line_Editing/Echo
$ Say A,CSI,"23;1H",CSI,"?25h"	! exit on last line, cursor on
$Exit:
$ Exit 0*F$Verify(Verify)+1
$!----------------------------------------------------------------------------
$Intro:
$ Say Facility_Name," ",Facility_Version
$ Type SYS$Input

A well known one-player game, once implemented by Bill Conley for MS-DOS,
here presented by Michael Bednarek, entirely in Vax/VMS DCL.

A version in AmigaBasic is also available.

   //
 \X/   u3369429@{murdu.oz.au | ucsvc.dn.mu.oz.au} | mb@munnari.oz.au
$ Ask Yes "Do you want help? "
$ If .not.Yes then Return
$ShowHelp: Type SYS$Input

The game is played on a board with 33 holes arranged in a cross pattern
and begins with all except the center hole being filled with a peg.

The object of the game is to remove as many pegs as possible by jumping pegs
either horizontally or vertically and removing pegs that are jumped over.
No diagonal moves or moves without jumping are allowed.

You move around the board using the numeric keypad keys:

	 8 = Up
 4 Left		 6 = Right
	 2 = Down

You jump by pressing PF1 plus a keypad key, e.g. to jump upwards press PF1 KP8.
Press PF1 twice to exit the game (or F10 on a VT200).
Note: pressing CTRL/Z will not end the game!
PF2 will produce this page again, and PF4 will reset the board.

Good luck.
$ Read/End_of_File=Exit/Error=Return/Prompt="Hit RETURN to continue"-
	/Time_Out=30 SYS$Command Yes
$Return: Return
$!----------------------------------------------------------------------------
$UP:
$ y=CurY-1
$ x=CurX
$ Goto Play
$RIGHT:
$ y=CurY
$ x=CurX+1
$ Goto Play
$LEFT:
$ y=CurY
$ x=CurX-1
$ Goto Play
$DOWN:
$ y=CurY+1
$ x=CurX
$Play:
$ If F$Type(Table'y''x).nes."" then goto Play1
$Error:
$ Say BEL
$ Return
$Play1:
$ If Jump then goto Jump
$ Call DrawOne 'F$Integer(CurY*3-2) 'F$Integer(CurX*5+19) 0 &Table'CurY''CurX
$ CurY=y
$ CurX=x
$ Call DrawOne 'F$Integer(CurY*3-2) 'F$Integer(CurX*5+19) 7 &Table'CurY''CurX
$ Return
$Jump:
$ If Table'CurY''CurX'.ne."1" then goto Error	! Currently on a peg?
$ If Table'y''x'.ne."1" then goto Error		! Jumping over a peg?
$ jy=CurY+(y-CurY)*2
$ jx=CurX+(x-CurX)*2
$ If F$Type(Table'y''x).eqs."" then goto Error	! Out of bounds?
$ If Table'jy''jx'.ne."0" then goto Error	! Target empty?
$ Table'CurY''CurX'="0"	! The current position becomes empty & un-highlighted
$ Call DrawOne 'F$Integer(CurY*3-2) 'F$Integer(CurX*5+19) 0 0
$ Table'y''x'="0"	! The skipped position becomes empty, too.
$ Call DrawOne 'F$Integer(y*3-2) 'F$Integer(x*5+19) 0 0
$ Table'jy''jx'="1"	! The target position becomes filled & highlighted
$ Call DrawOne 'F$Integer(jy*3-2) 'F$Integer(jx*5+19) 7 1
$ CurY=jy
$ CurX=jx
$ nPegs=nPegs-1
$ Gosub DrawScore
$Return
$!----------------------------------------------------------------------------
$Help:
$ Say A,CLS
$ Gosub ShowHelp
$ Gosub DrawBoard
$ Return
$!----------------------------------------------------------------------------
$Init:
$ If F$GetDVI("TT","TT_DECCRT") then goto Start0
$ Say "Sorry, HI-Q needs a DEC CRT terminal."
$ Goto Exit
$Start0:If F$Mode().nes."BATCH" then goto Init0
$ Say "You can't play HI-Q in batch."
$ Goto Exit
$!
$Init0:
$ BEL[0,8]=7
$ ESC[0,8]=27
$ CSI=ESC+"["
$ CLS=CSI+"2J"+CSI+"1;1H"	! Clear Screen & Home
$ G=ESC+"(0"			! DEC Special Graphics character set
$ A=ESC+"(B"			! ASCII character set
$!
$ Set Terminal/Application_Keypad/NoLine_Editing/NoEcho
$ Define/Key/NoLog PF1 ""/Set_State=Curiouser/If_State=Curious
$ Define/Key/NoLog PF2 HELP/Terminate/NoEcho/If_State=Curious
$ Define/Key/NoLog HELP HELP/Terminate/NoEcho/If_State=Curious
$ Define/Key/NoLog PF4 NEWGAME/Terminate/NoEcho/If_State=Curious
$ Define/Key/NoLog KP8 UP/Terminate/NoEcho/If_State=Curious
$ Define/Key/NoLog KP6 RIGHT/Terminate/NoEcho/If_State=Curious
$ Define/Key/NoLog KP4 LEFT/Terminate/NoEcho/If_State=Curious
$ Define/Key/NoLog KP2 DOWN/Terminate/NoEcho/If_State=Curious
$ Define/Key/NoLog F10 EndGame/Terminate/NoEcho/If_State=Curious
$ Set Key/State=Curious/NoLog
$ Define/Key/NoLog KP8 JUP/Terminate/NoEcho/If_State=Curiouser
$ Define/Key/NoLog KP6 JRIGHT/Terminate/NoEcho/If_State=Curiouser
$ Define/Key/NoLog KP4 JLEFT/Terminate/NoEcho/If_State=Curiouser
$ Define/Key/NoLog KP2 JDOWN/Terminate/NoEcho/If_State=Curiouser
$ Define/Key/NoLog PF1 EndGame/Terminate/NoEcho/If_State=Curiouser
$!
$ Commands=".UP.RIGHT.LEFT.DOWN.ENDGAME.HELP.NEWGAME.CHEAT."
$ lCommands=F$Length(Commands)
$ Cmd=""
$ nGames=-1
$ nPegs=32
$ BestResult=32
$ Say CSI,"?25l"	! Cursor Off
$Return
$!----------------------------------------------------------------------------
$Cheat:
$InitTable:
$ CurY=0
$iNextRow: CurX=0
$ CurY=CurY+1
$ If CurY.le.7 then goto iNextCol
$ Table44="0"
$ CurY=6
$ CurX=4
$ If nPegs.lt.BestResult then BestResult=nPegs
$ nGames=nGames+1
$ nPegs=32
$ If Cmd.nes."CHEAT" then Return
$ Table52="1"
$ Table53="1"
$ Table64="1"
$ CurY=5
$ CurX=2
$ nPegs=3
$ Return
$iNextCol: CurX=CurX+1
$ If CurX.gt.7 then goto iNextRow
$ If (CurY.lt.3 .or. CurY.gt.5).and.(CurX.lt.3 .or. CurX.gt.5) -
	.or. CurY.eq.4 .and. CurX.eq.4 then goto iNextCol
$ Table'CurY''CurX="1"
$ If Cmd.nes."CHEAT" then goto iNextCol
$ Table'CurY''CurX="0"
$ Goto iNextCol
$!----------------------------------------------------------------------------
$DrawBoard:
$Say CLS
$ y=0
$NextRow: x=0
$ y=y+1
$ If y.le.7 then goto NextCol
$!
$ Say A,CSI,"3;54H",F$FAO("!SL game!%S played",nGames),CSI,"K"
$ Say   CSI,"4;54HBest result was ",BestResult
$ Say   CSI,"17;2HKP8 = Up     Precede",CSI,"17;54H6 or more left .. nice try"
$ Say   CSI,"18;2HKP6 = Right  with",	CSI,"18;54H5 left .............. good"
$ Say   CSI,"19;2HKP4 = Left   PF1",	CSI,"19;54H4 left ............ better"
$ Say   CSI,"20;2HKP2 = Down   to jump",CSI,"20;54H3 left ..... really clever"
$ Say					CSI,"21;54H2 left ........ a sharpie!"
$ Say   CSI,"22;2HPF2 = Help",		CSI,"22;54H1 left ... take a deep bow"
$ Say   CSI,"23;2HPF4 = Reset",		CSI,"23;54H1 left in center...perfect"
$ Say   CSI,"23;15HPress PF1 twice to exit"
$ Gosub DrawScore
$Return
$NextCol: x=x+1
$ If x.gt.7 then goto NextRow
$ If F$Type(Table'y''x).eqs."" then goto NextCol
$ Attr=(y.eq.CurY .and. x.eq.CurX)*7
$ Call DrawOne 'F$Integer(y*3-2) 'F$Integer(x*5+19) 'Attr &Table'y''x
$ Goto NextCol
$!----------------------------------------------------------------------------
$DrawOne: Subroutine
$! Draws a box, either filled or empty, highlighted or plain.
$! P1 = Row number		P2 = Column number
$! P3 = Attributes for SGR	P4 = Empty (0) /filled (1)
$ P1=F$Integer(P1)	! Necessary because of "P1+1" below
$! The next line not only works if P4="0"|"1", but also if P4="TABLE44" and
$! TABLE44="0"|"1".
$ P4=F$Element(F$Integer('P4),",","Hx  x,Hxaax")
$ Say G,CSI,P3,"m",-
      CSI,P1,";",P2,"Hlqqk",CSI,P1+1,";",P2,P4,CSI,P1+2,";",P2,"Hmqqj",-
      CSI,"0m",A
$EndSubroutine
$!----------------------------------------------------------------------------
$DrawScore:
$ Say A,CSI,"11;63H",F$FAO("!2SL peg!%S remaining",nPegs),CSI,"K"
$ If nPegs.eq.1 then goto Finish
$! Check whether the player is stuck
$ y=0
$cNextRow: x=0
$ y=y+1
$ If y.le.7 then goto cNextCol
$Finish: Say CSI,"23;2H",CSI,"5;7mPF4 = Reset"
$ Say CSI,"23;15HPress PF1 twice to exit",CSI,"0m",BEL
$ Goto Illuminate
$cNextCol: x=x+1
$ If x.gt.7 then goto cNextRow
$ If F$Type(Table'y''x).eqs."" then goto cNextCol
$! Look at 3 boxes horizontally and vertically at once
$ If F$Type(Table'y''F$Integer(x+2)).eqs."" then goto cCol
$ Check=Table'y''x+Table'y''F$Integer(x+1)+Table'y''F$Integer(x+2)
$ If Check.eqs."110" .or. Check.eqs."011" then goto Illuminate
$cCol:
$ If F$Type(Table'F$Integer(y+2)''x).eqs."" then goto cNextCol
$ Check=Table'y''x+Table'F$Integer(y+1)''x+Table'F$Integer(y+2)''x
$ If Check.nes."110" .and. Check.nes."011" then goto cNextCol
$Illuminate:
$ If nPegs.gt.6 then Return
$ Goto Illuminate'nPegs
$Illuminate6:
$ Say A,CSI,"17;54H",CSI,"7m6 or more left .. nice try",CSI,"0m"
$ Return
$Illuminate5:
$ Say A,CSI,"17;54H6 or more left .. nice try"
$ Say A,CSI,"18;54H",CSI,"7m5 left .............. good",CSI,"0m"
$ Return
$Illuminate4:
$ Say A,CSI,"18;54H5 left .............. good"
$ Say A,CSI,"19;54H",CSI,"7m4 left ............ better",CSI,"0m"
$ Return
$Illuminate3:
$ Say A,CSI,"19;54H4 left ............ better"
$ Say A,CSI,"20;54H",CSI,"7m3 left ..... really clever",CSI,"0m"
$ Return
$Illuminate2:
$ Say A,CSI,"20;54H3 left ..... really clever"
$ Say A,CSI,"21;54H",CSI,"7m2 left ........ a sharpie!",CSI,"0m"
$ Return
$Illuminate1:
$ Say A,CSI,"21;54H2 left ........ a sharpie!"
$ If Table44.eqs."1" then goto Illuminate0
$ Say A,CSI,"22;54H",CSI,"7m1 left ... take a deep bow",CSI,"0m"
$ Return
$Illuminate0:
$ Say A,CSI,"23;54H",CSI,"7m1 left in center...perfect",CSI,"0m"
$ Return
