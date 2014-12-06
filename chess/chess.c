/*
    C source for CHESS               Rev. 3-10-87

    Written by John Stanback (hplabs!hpfcla!hpisla!hpltca!jhs)

    Patches for BSD Unix by Rich Salz (rs@mirror.TMC.COM) - 5/3/87

*/ 

#include <stdio.h>
#include <curses.h>

#define DEF_TIME 10
#define neutral 0
#define white 1
#define black 2 
#define no_piece 0
#define pawn 1
#define knight 2
#define bishop 3
#define rook 4
#define queen 5
#define king 6
#define px " PNBRQK"
#define qx " pnbrqk"
#define rx "12345678"
#define cx "abcdefgh"
#define check 0x0001
#define capture 0x0002
#define draw 0x0004
#define promote 0x0010
#define incheck 0x0020
#define epmask 0x0040
#define exact 0x0100
#define pwnthrt 0x0200
#define up 'i'
#define down 'k'
#define left 'j'
#define right 'l'
#define true 1
#define false 0

struct leaf
  {
    short f,t,score,reply;
    unsigned short flags;
  };

char *alph[] = { 'a','b','c','d','e','f','g','h'};
char mvstr1[5],mvstr2[5];
struct leaf Tree[2000],*root;
short TrPnt[30];
short row[64],col[64],locn[8][8],Index[64],svalue[64];
short PieceList[3][16],PieceCnt[3];
short castld[3],kingmoved[3],mtl[3],pmtl[3],emtl[3],hung[3];
short mate,post,xkillr,ykillr,opponent,computer,Sdepth;
char start[10], end[10];
char buff_char;
int kb;
short aflag;
short h, v;
short allow;
long time0;
int response_time,extra_time,timeout,et,et0;
short quit,reverse,bothsides,InChk,player;
int NodeCnt,srate;
short atak[3][64],PawnCnt[3][8];
short ChkFlag[30],CptrFlag[30],PawnThreat[30],PPscore[30];
short BookSize,BookDepth;
short GameCnt,Game50,epsquare,lpost;
unsigned short GameList[240],Book[80][24];
short GameScore[240],GamePc[240],GameClr[240];
short value[8]={0,100,330,330,500,950,999};
short otherside[3]={0,2,1};
short passed_pawn1[8]={0,3,4,8,14,24,40,80};
short passed_pawn2[8]={0,2,3,4,6,9,13,80};
short passed_pawn3[8]={0,1,2,3,4,5,6,80};
short map[64]=
   {26,27,28,29,30,31,32,33,38,39,40,41,42,43,44,45,
    50,51,52,53,54,55,56,57,62,63,64,65,66,67,68,69,
    74,75,76,77,78,79,80,81,86,87,88,89,90,91,92,93,
    98,99,100,101,102,103,104,105,110,111,112,113,114,115,116,117};
short unmap[144]=
   {-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,
    -1,-1,0,1,2,3,4,5,6,7,-1,-1,-1,-1,8,9,10,11,12,13,14,15,-1,-1,
    -1,-1,16,17,18,19,20,21,22,23,-1,-1,-1,-1,24,25,26,27,28,29,30,31,-1,-1,
    -1,-1,32,33,34,35,36,37,38,39,-1,-1,-1,-1,40,41,42,43,44,45,46,47,-1,-1,
    -1,-1,48,49,50,51,52,53,54,55,-1,-1,-1,-1,56,57,58,59,60,61,62,63,-1,-1,
    -1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1};
short edge[64]=
   {0,1,2,3,3,2,1,0,1,2,3,4,4,3,2,1,2,3,4,5,5,4,3,2,3,4,5,6,6,5,4,3,
    3,4,5,6,6,5,4,3,2,3,4,5,5,4,3,2,1,2,3,4,4,3,2,1,0,1,2,3,3,2,1,0};
short pknight[64]=
   {0,6,11,14,14,11,6,0,6,12,22,25,25,22,12,6,
    11,20,30,36,36,30,20,11,14,25,36,44,44,36,25,14,
    14,25,36,44,44,36,25,14,11,20,30,36,36,30,20,11,
    6,12,22,25,25,22,12,6,0,6,11,14,14,11,6,0};
short pbishop[64]=
   {14,14,14,14,14,14,14,14,14,18,18,18,18,18,18,14,
    14,18,22,22,22,22,18,14,14,18,22,22,22,22,18,14,
    14,18,22,22,22,22,18,14,14,18,22,22,22,22,18,14,
    14,18,18,18,18,18,18,14,14,14,14,14,14,14,14,14};
short board[64]=
   {rook,knight,bishop,queen,king,bishop,knight,rook,
    pawn,pawn,pawn,pawn,pawn,pawn,pawn,pawn,
    0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,
    pawn,pawn,pawn,pawn,pawn,pawn,pawn,pawn,
    rook,knight,bishop,queen,king,bishop,knight,rook};
short color[64]=
   {white,white,white,white,white,white,white,white,
    white,white,white,white,white,white,white,white,
    0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,
    black,black,black,black,black,black,black,black,
    black,black,black,black,black,black,black,black};
short sweep[7]= {false,false,false,true,true,true,false};
short Dstpwn[3]={0,4,6};
short Dstart[7]={6,4,8,4,0,0,0};
short Dstop[7]={7,5,15,7,3,7,7};
short Dir[16]={1,12,-1,-12,11,13,-11,-13,10,-10,14,-14,23,-23,25,-25};
unsigned short PV,Swag1,Swag2,killr1[30],killr2[30],killr3[30],Qkillr[30];
unsigned short Ckillr[3],prvar[30];

readline(x, y, prompt, p)
    int x, y;
    char *prompt, *p;
{
    int f, t;
    char k;
    char *q;

/*    v = h = 0; */
    standout();
    move(y-1,x-1);
    printf( "%s", prompt);
    standend();
    getyx(stdscr, y, x);
    for (q = p; smg$read_keystroke(&kb,&k) != EOF;) {
	*p = k;
	switch (*p) {
	    default:
		if ( allow && strstr(prompt,"RETURN") == 0) return;
		p++;
		x++;
		break;
	    case up:
		if ( !allow) { p++; break;}
		if ( v < 7) v++;	
 		standout();
 		if ( px[board[h+(8*v)]] != ' ') DrawPiece(h+(8*v));
		else {
		   gotoXY(5+(5*h),18-(2*v)); printw(" X");
		}
		standend();
		DrawPiece(h+(8*(v-1)));
		break;
	    case down:
		if ( !allow) { p++; break;}
		if ( v > 0) v--;
 		standout();
 		if ( px[board[h+(8*v)]] != ' ') DrawPiece(h+(8*v));
		else {
		   gotoXY(5+(5*h),18-(2*v)); printw(" X");
		}
		standend();
		DrawPiece(h+(8*(v+1)));
		break;
	    case left:
		if ( !allow) { p++; break;}
		if ( h > 0) h--;
 		standout();
 		if ( px[board[h+(8*v)]] != ' ') DrawPiece(h+(8*v));
		else {
		   gotoXY(5+(5*h),18-(2*v)); printw(" X");
		}
		standend();
		DrawPiece((h+1)+(8*v));
		break;
 	    case right:
		if ( !allow) { p++; break;}
		if ( h < 7) h++;
 		standout();
 		if ( px[board[h+(8*v)]] != ' ') DrawPiece(h+(8*v));
		else {
		   gotoXY(5+(5*h),18-(2*v)); printw(" X");
		}
		standend();
		DrawPiece((h-1)+(8*v));
	 	break;
	    case 'c': 
		if ( !allow) { p++; break;}
		allow = false; 
	 	strcpy(p,"\0\0\0");
		gotoXY(1,1); 
		printw("Enter command or <return> to move piece."); 
		break;
	    case 18:
		ClrScreen();
		PrintBoard(white,0,0,1);
		break;
	    case 2:
		if ( GameCnt >= 0) {
          	f = GameList[GameCnt]>>8; t = GameList[GameCnt] & 0xFF;
          	board[f] = board[t]; color[f] = color[t];
          	board[t] = GamePc[GameCnt]; color[t] = GameClr[GameCnt];
          	GameCnt--;
	        PrintBoard(white,0,0,1);
          	InitializeStats();
		}
	  	break;
	    case 'L' & 037:
		touchwin(stdscr);
		refresh();
		break;
	    case '?': help(); break;
	    case '\n': case '\r':
		if ( allow) {
   		  if ( start[0] != '\0') sprintf( end,"%c%d",alph[h],v+1);
		  else sprintf( start,"%c%d",alph[h],v+1);
		  if ( start[0] != '\0' && end[0] != '\0') {
		    sprintf( p, "%s%s",start,end);
 		    gotoXY(1,1); ClrEoln();
		    return;
		  }
		  else break;
		}
		if ( strcmp(p,"o-o-o") == 0) aflag = 1;
		else if ( strcmp(p,"o-o") == 0) aflag = 0;
		else aflag = 2;
		move(y, x);
	        *p = '\0'; gotoXY(1,1); ClrEoln();
		return;
	    case '\b':
		if (p > q) {
		    p--;
		    x--;
		}
		break;
	    case 'U' & 037: case '\007': case '\033':
		p = q;
		x = 0;
		break;
	}
	move(y, x);
	ClrEoln(); 
    }
    *p = '\0';
}

main()
{
  smg$create_virtual_keyboard(&kb);
  initscr();
  NewGame();
  while (!(quit))
    {
      if (bothsides && !mate) select_move(opponent); else input_command();
      if (!quit && !mate) select_move(computer);
    }
  endwin();
}


OpeningBook(side)
short side;
{
short i,j,r0,pnt;
unsigned m,r;
  srand(time(0));
  r0 = m = 0;
  for (i = 0; i < BookSize; i++)
    {
      for (j = 0; j <= GameCnt; j++)
        if (GameList[j] != Book[i][j]) break;
      if (j > GameCnt)
        if ((r=rand()) > r0)
          {
            r0 = r; m = Book[i][GameCnt+1];
          }
    }
  for (pnt = TrPnt[1]; pnt < TrPnt[2]; pnt++)
    if ((Tree[pnt].f<<8) + Tree[pnt].t == m) Tree[pnt].score = 0;
  sort(TrPnt[1],TrPnt[2]-1);
  if (Tree[TrPnt[1]].score < 0) BookDepth = -1;
}


select_move(side)
short side;

/*
     Select a move by calling function search() at progressively deeper
     ply until time is up or a mate or draw is reached. An alpha-beta 
     window of -0, +75 points is set around the score returned from the
     previous iteration. 
*/

{
short i,alpha,beta,tempb,tempc;

  timeout = false; player = side;
  for (i = 0; i < 30; i++)
    prvar[i] = killr1[i] = killr2[i] = killr3[i] = 0;
  PPscore[0] = -5000;
  alpha = -9999; beta = 9999;
  NodeCnt = Sdepth = extra_time = 0;
  ataks(white,atak[white]); ataks(black,atak[black]);
  TrPnt[1] = 0; root = &Tree[0];
  MoveList(side,1);
  if (GameCnt < BookDepth) OpeningBook(side); else BookDepth = -1;
  if (BookDepth > 0) timeout = true;
  while (!timeout && Sdepth<30)
    {
      Sdepth++;
      gotoXY(70,1); printw("%d ",Sdepth); ClrEoln();
      search(side,1,Sdepth,alpha,beta,prvar);
      if (root->score < alpha)
        search(side,1,Sdepth,-12000,alpha,prvar);
      if (root->score > beta && !(root->flags & exact))
        {
          gotoXY(70,1); printw("%d+",Sdepth); ClrEoln();
          search(side,1,Sdepth,beta,12000,prvar);
        }
      beta = root->score+75;
      if (root->flags & exact) timeout = true;
    }
  if (root->score > -9999)
    {
      MakeMove(side,root,&tempb,&tempc);
      algbrnot(root->f,root->t);
      PrintBoard(side,root->f,root->t,0);
      gotoXY(50,16); printw("My move is: %s",mvstr1); ClrEoln();
    }
  ElapsedTime(1);
/*  gotoXY(18,23); printw("Nodes= %d",NodeCnt); ClrEoln();
  gotoXY(18,24); printw("Nodes/Sec= %d",srate); ClrEoln(); */
  gotoXY(50,13);
  if (root->flags & draw) printw("draw game!");
  if (root->score < -9000) printw("opponent will soon mate!");
  if (root->score > 9000)  printw("computer will soon mate!");
  if (root->score == -9999)
    {
      gotoXY(50,13);
      printw("opponent mates!!"); mate = true;
    }
  if (root->score == 9998)
    {
      gotoXY(50,13);
      printw("computer mates!!"); mate = true;
    }
  ClrEoln();
  if (post) post_move(root);
  if (root->f == 255 || root->t == 255) Game50 = GameCnt;
  else if (board[root->t] == pawn || (root->flags & capture)) 
    Game50 = GameCnt;
  GameScore[GameCnt] = root->score;
  if (GameCnt > 238) quit = true;
  player = otherside[side];
}


VerifyMove(s,ok,aflag)
char s[];
short *ok, aflag;

/*
    See if the opponents move is legal, if so, make it.
*/

{
short x,pnt,cnt,tempb,tempc;
unsigned short nxtline[30];
struct leaf *node,*xnode;

  *ok = false; cnt = 0;
  MoveList(opponent,2);
  pnt = TrPnt[2];
  while (pnt < TrPnt[3])
    {
      node = &Tree[pnt]; pnt++;
      if ( aflag == 0) { node->f = 255; aflag = 2; castld[player] = true;}
      else if ( aflag == 1) { node->t = 255; aflag = 2; castld[player] = true;}
      algbrnot(node->f,node->t);
      if (strcmp(s,mvstr1) == 0 || strcmp(s,mvstr2) == 0)
        {
          xnode = node; cnt++;
        }
    }
  if (cnt == 1)
    {
      MakeMove(opponent,xnode,&tempb,&tempc);
      CaptureSearch(computer,opponent,3,1,-9999,9999,0,&x,nxtline);
      if (x == 10000) UnmakeMove(opponent,xnode,&tempb,&tempc);
      else
        {
          *ok = true; PrintBoard(opponent,xnode->f,xnode->t,0);
          if (xnode->f == 255 || xnode->t == 255) Game50 = GameCnt;
          else if (board[xnode->t] == pawn || (xnode->flags & capture)) 
            Game50 = GameCnt;
        } 
    }
    if ( *ok == false) {
/*	DrawPiece(h+(8*v)); */
	gotoXY(1,1); printw("Invalid - press '?' for help."); ClrEoln();
	printf("\007");
        lib$wait(&0.8);
        gotoXY(1,1); ClrEoln();  
    }
}

 
input_command()
{
short ok,i,f,t;
char s[20],fname[20];
FILE *fd;

  ok=quit=false;
  while (!(ok || quit))
    {
      allow = true;
      strcpy( start,"\0\0\0");
      strcpy( end,"\0\0\0");
      readline( 1,24," ",s);
      player = opponent;
      VerifyMove(s,&ok,aflag);
      standout();
      DrawPiece(h+(8*v));
      standend();
      if (strcmp(s,"prt") == 0)
        {
          ClrScreen();  PrintBoard(white,0,0,1);
        }
      if (strcmp(s,"quit") == 0) quit = true;
      if (strcmp(s,"post") == 0) post = !post;
      if (strcmp(s,"set") == 0) SetBoard();
      if (strcmp(s,"go") == 0) ok = true;
      if (strcmp(s,"help") == 0) help();
      if (strcmp(s, "redraw") == 0)
	{
	  ClrScreen();
	  PrintBoard(white,0,0,1);
	}
      if (strcmp(s,"hint") == 0)
        {
          algbrnot(prvar[2]>>8,prvar[2] & 0xFF);
          gotoXY(50,13); printw("try %5s",mvstr1); ClrEoln();
        }
      if (strcmp(s,"both") == 0)
        {
          bothsides = !bothsides;
          select_move(opponent);
          ok = true;
        }
      if (strcmp(s,"reverse") == 0)
        {
          reverse = !reverse;
          ClrScreen();
          PrintBoard(white,0,0,1);
        }
      if (strcmp(s,"switch") == 0)
        {
          computer = otherside[computer];
          opponent = otherside[opponent];
          ok = true;
        }
      if (strcmp(s,"save") == 0)
        {
	  readline(50, 21, "file name?  ", fname);
          SaveGame(fname);
        }
      if (strcmp(s,"get") == 0)
        {
	  readline(50, 21, "file name?  ", fname);
          GetGame(fname);
          InitializeStats();
          PrintBoard(white,0,0,1);
        }
      if (strcmp(s,"time") == 0)
        {
	  readline(50, 21, "enter time:  ", fname);
	  response_time = atoi(fname);
        }
      if (strcmp(s,"undo") == 0 && GameCnt > 0)
        {
          f = GameList[GameCnt]>>8; t = GameList[GameCnt] & 0xFF;
          board[f] = board[t]; color[f] = color[t];
          board[t] = GamePc[GameCnt]; color[t] = GameClr[GameCnt];
          GameCnt--;
          PrintBoard(white,0,0,1);
          InitializeStats();
        }
      if (strcmp(s,"list") == 0)
        {
          fd = fopen("chess.lst","w");
          for (i = 0; i <= GameCnt; i++)
            {
              f = GameList[i]>>8; t = (GameList[i] & 0xFF);
              algbrnot(f,t);
              if ((i % 2) == 0) fprintf(fd,"\n");
              fprintf(fd," %5s  %6d     ",mvstr1,GameScore[i]);
            }
          fprintf(fd,"\n");
          fclose(fd);
        }
    }
  ElapsedTime(1);
}


gotoXY(x,y)
short x,y;
{
  move(y-1,x-1);
}


ClrScreen()
{
  clear(); refresh();
}


ClrEoln()
{
  clrtoeol(); refresh();
}


algbrnot(f,t)
short f,t;
{
  if (f == 255)
    { strcpy(mvstr1,"o-o"); strcpy(mvstr2,"o-o"); }
  else if (t == 255)
    { strcpy(mvstr1,"o-o-o"); strcpy(mvstr2,"o-o"); }
  else
    {
      mvstr1[0] = cx[col[f]]; mvstr1[1] = rx[row[f]];
      mvstr1[2] = cx[col[t]]; mvstr1[3] = rx[row[t]];
      mvstr2[0] = qx[board[f]];
      mvstr2[1] = mvstr1[2]; mvstr2[2] = mvstr1[3];
      mvstr1[4] = '\0'; mvstr2[3] = '\0';
    }
}


parse(s,m)
unsigned short *m; char s[];
{
short r1,r2,c1,c2;
  if (s[4] == 'o') *m = 0x00FF;
  else if (s[0] == 'o') *m = 0xFF00;
  else
    {
      c1 = s[0] - 'a'; r1 = s[1] - '1';
      c2 = s[2] - 'a'; r2 = s[3] - '1';
      *m = (locn[r1][c1]<<8) + locn[r2][c2];
    }
}


GetOpenings()
{
FILE *fd;
int c,j;
char s[80],*p;
  fd = fopen("chess.opn","r");
  BookSize = 0; BookDepth = 24; j = -1; c = '?';
  while (c != EOF)
    {
      p = s;
      while ((c=getc(fd)) != EOF)
        if (c == '\n') break; else *(p++) = c;
      *p = '\0';
      if (c != EOF)
        if (s[0] == '!')
          {
            while (j < BookDepth) Book[BookSize][j++] = 0; 
            BookSize++; j = -1;
          }
        else if (j < 0) j++;
        else
          {
            parse(&s[0],&Book[BookSize][j]); j++;
            parse(&s[6],&Book[BookSize][j]); j++;
          } 
    }
  fclose(fd);
}


GetGame(fname)
char fname[20];
{
FILE *fd;
int c;
short loc;
unsigned short m;

  if (fname[0] == '\0') strcpy(fname,"chess.000");
  if ((fd = fopen(fname,"r")) != NULL)
    {
      fscanf(fd,"%hd%hd",&castld[white],&castld[black]);
      fscanf(fd,"%hd%hd",&kingmoved[white],&kingmoved[black]);
      for (loc = 0; loc < 64; loc++)
        {
          fscanf(fd,"%hd",&m); board[loc] = (m >> 8); color[loc] = (m & 0xFF);
        }
      GameCnt = -1; c = '?';
      while (c != EOF)
        c = fscanf(fd,"%hd%hd%hd%hd",&GameList[++GameCnt],&GameScore[GameCnt],
                   &GamePc[GameCnt],&GameClr[GameCnt]);
      fclose(fd);
    }
}


SaveGame(fname)
char fname[20];
{
FILE *fd;
short loc,i;

  if (fname[0] == '\0') strcpy(fname,"chess.000");
  fd = fopen(fname,"w");
  fprintf(fd,"%d %d\n",castld[white],castld[black]);
  fprintf(fd,"%d %d\n",kingmoved[white],kingmoved[black]);
  for (loc = 0; loc < 64; loc++)
    fprintf(fd,"%d\n",256*board[loc] + color[loc]);
  for (i = 0; i <= GameCnt; i++)
    fprintf(fd,"%d %d %d %d\n",GameList[i],GameScore[i],GamePc[i],GameClr[i]);
  fclose(fd);
}


ElapsedTime(iop)
short iop;
{
int minute,second;
  et = time(0) - time0;
  if (et < et0) et0 = 0;
  if (et > et0 || iop == 1)
    {
      if (et > response_time+extra_time) timeout = true;
      et0 = et;
      if (iop == 1)
        {
          et0 = 0; time0 = time(0);
        }
      minute = et/60; second = (et - 60*minute);
      if (player == computer) gotoXY(50,18); else gotoXY(50,23);
      printw("%d:%d",minute,second); ClrEoln();
      if (et > 0) srate = NodeCnt/et; else srate = 0;
/*      if (post)
        {
          gotoXY(18,24); printw("Nodes/Sec= %d",srate); ClrEoln();
        }*/
    }
}


post_move(node)
struct leaf *node;
{
short d,e,ply;
  d = 4; ply = 1;
  gotoXY(60,d); printw("%6d  ",node->score);
  while (prvar[ply] > 0)
    {
      algbrnot(prvar[ply]>>8,prvar[ply] & 0x00FF);
      gotoXY(50,d); printw("%5s",mvstr1);
      ply++; d++;
    }
  e = d;
  while (d < lpost)
    {
      gotoXY(50,d++); ClrEoln();
    }
  lpost = e;
  refresh();
}


DrawPiece(loc)
short loc;
{
short r,c; char x;
  if (reverse) r = 7-row[loc]; else r = row[loc];
  if (reverse) c = 7-col[loc]; else c = col[loc];
  if (color[loc] == black) x = '*'; else x = ' ';
  gotoXY(5+5*c,4+2*(7-r)); printw("%c%c",x,px[board[loc]]," ");
}


PrintBoard(side,f,t,flag)
short side,f,t,flag;
{
short i,l,c,z; 

  if (side == white) c = 0; else c = 56;
  if (flag)
    {
      i = 2;
      gotoXY(3,++i);
      printw("|----|----|----|----|----|----|----|----|");
      while (i<19)
        {
          gotoXY(1,++i);
          if (reverse) z = (i/2)-1; else z = 10-(i/2);
          printw("%d |    |    |    |    |    |    |    |    |",z);
          gotoXY(3,++i);
          printw("|----|----|----|----|----|----|----|----|");
        }
      gotoXY(3,20);
      if (reverse) printw("   h    g    f    e    d    c    b    a");
              else printw("   a    b    c    d    e    f    g    h");
      for (l = 0; l < 64; l++) DrawPiece(l);
    }
  else if (f == 255)
    {
      DrawPiece(c+4); DrawPiece(c+6);
      DrawPiece(c+7); DrawPiece(c+5);
    }
  else if (t == 255)
    {
      DrawPiece(c+4); DrawPiece(c+2);
      DrawPiece(c); DrawPiece(c+3);
    }
  else
    {
      DrawPiece(f); DrawPiece(t);
    }
  refresh();
}


SetBoard()
{
short a,r,c,loc;
char s[20];

  ClrScreen(); PrintBoard(white,0,0,1);
  a = white;
  do
  {
    gotoXY(50,2); printw(".    Exit to Main");
    gotoXY(50,3); printw("#    Clear Board");
    readline(49,5, "Enter piece & location: ", s);
    if (s[0] == '#')
      {
        for (loc = 0; loc < 64; loc++)
          { board[loc] = no_piece; color[loc] = neutral; }
        PrintBoard(white,0,0,1);
      }
    if (s[0] == 'c' || s[0] == 'C') a = otherside[a];
    c = s[1]-'a'; r = s[2]-'1';
    if ((c >= 0) && (c < 8) && (r >= 0) && (r < 8))
      {
        loc = locn[r][c];
        color[loc] = a;
        if (s[0] == 'p') board[loc] = pawn;
        else if (s[0] == 'n') board[loc] = knight;
        else if (s[0] == 'b') board[loc] = bishop;
        else if (s[0] == 'r') board[loc] = rook;
        else if (s[0] == 'q') board[loc] = queen;
        else if (s[0] == 'k') board[loc] = king;
        else { board[loc] = no_piece; color[loc] = neutral; }
        DrawPiece(loc); refresh();
      }
  }
  while (s[0] != '.');
  if (board[4] != king) kingmoved[white] = 10;
  if (board[61] != king) kingmoved[black] = 10;
  GameCnt = -1; Game50 = -1; BookDepth = 0;
  InitializeStats(); ClrScreen(); PrintBoard(white,0,0,1);
}
  

NewGame()
{
short l,r,c;
char buff[20];

  mate = quit = reverse = bothsides = post = false;
  lpost =  NodeCnt = epsquare = xkillr = 0;
  GameCnt = Game50 = -1;
  castld[white] = castld[black] = false;
  kingmoved[white] = kingmoved[black] = 0;
  opponent = white; computer = black;
  for (r = 0; r < 8; r++)
    for (c = 0; c < 8; c++)
      {
        l = 8*r+c; locn[r][c] = l;
        row[l] = r; col[l] = c;
      }
  ClrScreen();
  readline(1, 20, "enter response time (or RETURN for default): ", buff);
  response_time = buff[0] ? atoi(buff) : DEF_TIME;
  ClrScreen(); PrintBoard(white,0,0,1);
  InitializeStats();
  ElapsedTime(1);
  GetOpenings();
}


help()
{
char c;
char buff[10];

ClrScreen();
printw("\n");
printw("This program attempts to play CHESS\n\n");
printw("To make a move, move the cursor onto the piece you wish to move using\n");
printw("the keys i,j,k,l so that it is highlighted.  Press return, then move the cursor\n");
printw("onto the space you wish to move to, then press return again.\n");
printw("Press 'c' to enter one of these other commands:\n");
printw("o-o           castle king side\n");
printw("o-o-o         castle queen side\n");
printw("set           set up a board position\n");
printw("switch        switch sides with computer\n");
printw("go            skip your move\n");
printw("reverse       reverse board display\n");
printw("redraw (^R)   re-paint display\n");
printw("undo   (^B)   undo last move\n");
printw("both          computer plays both sides\n");
printw("time          change response time\n");
printw("post          post best line of play\n");
printw("hint          computer suggests your move\n");
printw("list          list moves to file chess.lst\n");
printw("save          save game to disk\n");
printw("get           get game from disk\n");
printw("quit          exit CHESS\n");
refresh();
printw("Type return:");
smg$read_keystroke(&kb,&buff_char);
ClrScreen();
PrintBoard(white,0,0,1);
}


UpdatePieceList(side,loc,iop)
short side,loc,iop;

/*
    Array PieceList[side][indx] contains the location of all the pieces of
    either side. Array Index[loc] contains the indx into PieceList for a
    given square.
*/

{
register short i;
  if (iop == 1)
    {
      PieceCnt[side]--;
      for (i = Index[loc]; i <= PieceCnt[side]; i++)
        {
          PieceList[side][i] = PieceList[side][i+1];
          Index[PieceList[side][i]] = i;
        }
    }
  else
    {
      PieceCnt[side]++;
      PieceList[side][PieceCnt[side]] = loc;
      Index[loc] = PieceCnt[side];
    }
}


InitializeStats()
{
register short i,loc;
  for (i = 0; i < 8; i++)
    PawnCnt[white][i] = PawnCnt[black][i] = 0;
  mtl[white] = mtl[black] = pmtl[white] = pmtl[black]=0;
  PieceCnt[white] = PieceCnt[black] = 0;
  for (loc = 0; loc < 64; loc++)
    if (color[loc] != neutral)
      {
        mtl[color[loc]] += value[board[loc]];
        if (board[loc] == pawn)
          {
            pmtl[color[loc]] += value[pawn];
            ++PawnCnt[color[loc]][col[loc]];
          }
        if (board[loc] == king) Index[loc] = 0;
          else Index[loc] = ++PieceCnt[color[loc]];
        PieceList[color[loc]][Index[loc]] = loc;
      }
}


sort(p1,p2)
short p1,p2;
{
register short p,p0,s;
struct leaf temp;

  s = 32000;
  while (p1 < p2)
    if (Tree[p1].score >= s) p1++;
    else
      {
        s = Tree[p1].score; p0 = p1;
        for (p = p1+1; p <= p2; p++)
          if (Tree[p].score > s)
            {
              s = Tree[p].score; p0 = p;
            }
        temp = Tree[p1]; Tree[p1] = Tree[p0]; Tree[p0] = temp;
        p1++;
      }
}


repetition(node)
struct leaf *node;

/*
    Check for draw by threefold repetition or 50 move rule.
*/

{
register short i,f,t,c;
short r,b[64];
unsigned short m;
  r = c = 0;
#ifdef	BSD
  bzero((char *)b, sizeof b);
#else
  memset(b,0,64*sizeof(short));
#endif	/* BSD */
  for (i = GameCnt; i > Game50; i--)
    {
      m = GameList[i]; f = m>>8; t = m & 0xFF;
      if (t != 255 && f != 255)
        {
          b[f]++; b[t]--;
          if (b[f] == 0) c--; else c++;
          if (b[t] == 0) c--; else c++;
          if (c == 0) r++;
        }
    }
  if (r == 1)
    if (node->score > 0) node->score -= 20;
    else node->score += 20;
  if (GameCnt-Game50 > 99 || r == 2)
    {
      node->score = 0;
      node->flags |= exact;
      node->flags |= draw;
    }
}


ataks(side,a)
short side,a[];

/*
    Place the lowest value piece attacking a square into array atak[][].
*/

{
register short m,u,d,j;
short piece,i,m0,*aloc,*s;
 
#ifdef	BSD
  bzero((char *)a, sizeof a);
#else
  a = (short *)memset(a,0,64*sizeof(short));
#endif	/* BSD */
  Dstart[pawn] = Dstpwn[side]; Dstop[pawn] = Dstart[pawn] + 1;
  aloc = &PieceList[side][0];
  for (i = 0; i <= PieceCnt[side]; i++)
    {
      piece = board[*aloc]; m0 = map[*aloc];
      s = &svalue[*aloc]; *s = 0;
      aloc++;
      if (sweep[piece])
        for (j = Dstart[piece]; j <= Dstop[piece]; j++)
          {
            d = Dir[j]; m = m0+d; u = unmap[m];
            while (u >= 0)
              {
                *s += 2;
                if (a[u] == 0 || piece < a[u]) a[u] = piece;
                if (color[u] == neutral)
                  {
                    m += d; u = unmap[m];
                  }
                else u = -1;
              }
          }
      else
        {
          for (j = Dstart[piece]; j <= Dstop[piece]; j++)
            if ((u = unmap[m0+Dir[j]]) >= 0)
              if (a[u] == 0 || piece < a[u]) a[u] = piece;
        }
    }
}

  
castle(side,f,t,iop,ok)
short side,f,t,iop,*ok;
{
short i,e,k1,k2,r1,r2,c1,c2,t0,xside;

  xside = otherside[side];
  if (side == white) e = 0; else e = 56;
  if (f == 255)
    {
      k1 = e+4; k2 = e+6; r1 = e+7; r2 = e+5; c1 = k1; c2 = r1;
    }
  else
    {
      k1 = e+4; k2 = e+2; r1 = e; r2 = e+3; c1 = r1; c2 = k1;
    }
  if (iop == 0)
    {
      *ok = false;
      if (board[k1] == king && board[r1] == rook) *ok = true;
      for (i = c1; i <= c2; i++)
        if (atak[xside][i] > 0) *ok = false; 
      for (i = c1+1; i < c2; i++)
        if (color[i] != neutral) *ok = false;
    }
  else
    {
      if (iop == 1) castld[side] = true; else castld[side] = false;
      if (iop == 2)
        {
          t0 = k1; k1 = k2; k2 = t0;
          t0 = r1; r1 = r2; r2 = t0;
        }
      board[k2] = king; color[k2] = side; Index[k2] = 0;
      board[k1] = no_piece; color[k1] = neutral;
      board[r2] = rook; color[r2] = side; Index[r2] = Index[r1];
      board[r1] = no_piece; color[r1] = neutral;
      PieceList[side][Index[k2]] = k2;
      PieceList[side][Index[r2]] = r2;
    }
}


en_passant(side,xside,f,t,iop)
short side,f,t,iop;
{
short l;
  if (t > f) l = t-8; else l = t+8;
  if (iop == 1)
    {
      board[l] = no_piece; color[l] = neutral;
    }
  else 
    {
      board[l] = pawn; color[l] = xside;
    }
  InitializeStats();
}


LinkMove(ply,f,t,side,xside)
short ply,f,t,side,xside;
{

/*
    Add a move to the tree.  Assign a bonus (in an attempt to
    improve move ordering) if move is a
    principle variation, "killer", or capturing move.
*/

register short s;
unsigned short mv;
struct leaf *node;

  node = &Tree[TrPnt[ply+1]];
  ++TrPnt[ply+1];
  node->flags = node->reply = 0;
  node->f = f; node->t = t; mv = (f<<8) + t;
  if (f == 255 || t == 255) s = 100;
  else
    {
      s = 0;
      if (mv == PV) s = 150;
      else if (mv == killr1[ply]) s = 90;
      else if (mv == killr2[ply]) s = 70;
      else if (mv == killr3[ply]) s = 50;
      else if (mv == Swag1) s = 30;
      else if (mv == Swag2) s = 20;
      if (color[t] != neutral)
        {
          node->flags |= capture;
          if (t == xkillr) s += 400;
          if (atak[xside][t] == 0) s += value[board[t]]-board[f];
          else if (board[t] > board[f]) s += value[board[t]]-value[board[f]];
          else s += 15;
        }
      if (board[f] == pawn)
        {
          if (row[t] == 0 || row[t] == 7) node->flags |= promote;
          else if (row[t] == 1 || row[t] == 6) node->flags |= pwnthrt;
          else if (t == epsquare) node->flags |= epmask;
        }
      if (atak[xside][f] > 0) s += 15;
      if (atak[xside][t] > 0) s -= 20;
      if (InChk)
        {
          if (board[f] == king && atak[xside][t] == 0) s += 600;  
          if (mv == Qkillr[ply]) s += 100;
        }
    }
  node->score = s-20000;
}


GenMoves(ply,loc,side,xside)
short ply,loc,side,xside;

/*
     Generate moves for a piece. The from square is mapped onto a 12 by 
     12 board and offsets (taken from array Dir[]) are added to the 
     mapped location. Array unmap[] maps the move back onto array 
     board[] (yielding a value of -1 if the to square is off the board). 
     This process is repeated for bishops, rooks, and queens until a 
     piece is encountered or the the move falls off the board. Legal 
     moves are then linked into the tree. 
*/
    
{
register short m,u,d;
short i,m0,piece; 

  piece = board[loc]; m0 = map[loc];
  if (sweep[piece])
    {
      for (i = Dstart[piece]; i <= Dstop[piece]; i++)
        {
          d = Dir[i]; m = m0+d; u = unmap[m];
          while (u >= 0)
            if (color[u] == neutral)
              {
                LinkMove(ply,loc,u,side,xside);
                m += d; u = unmap[m];
              }
            else if (color[u] == xside)
              {
                LinkMove(ply,loc,u,side,xside);
                u = -1;
              }
            else u = -1;
        }
    }
  else if (piece == pawn)
    {
      if (side == white && color[loc+8] == neutral)
        {
          LinkMove(ply,loc,loc+8,side,xside);
          if (row[loc] == 1)
            if (color[loc+16] == neutral)
              LinkMove(ply,loc,loc+16,side,xside);
        }
      else if (side == black && color[loc-8] == neutral)
        {
          LinkMove(ply,loc,loc-8,side,xside);
          if (row[loc] == 6)
            if (color[loc-16] == neutral)
              LinkMove(ply,loc,loc-16,side,xside);
        }
      for (i = Dstart[piece]; i <= Dstop[piece]; i++)
        if ((u = unmap[m0+Dir[i]]) >= 0)
          if (color[u] == xside || u == epsquare)
            LinkMove(ply,loc,u,side,xside);
    }
  else
    {
      for (i = Dstart[piece]; i <= Dstop[piece]; i++)
        if ((u = unmap[m0+Dir[i]]) >= 0)
          if (color[u] != side)
            LinkMove(ply,loc,u,side,xside);
    }
}



MoveList(side,ply)
short side,ply;

/*
    Fill the array Tree[] with all available moves for side to
    play. Array TrPnt[ply] contains the index into Tree[]
    of the first move at a ply.
*/
    
{
register short i;
short ok,xside;

  xside = otherside[side];
  TrPnt[ply+1] = TrPnt[ply];
  Dstart[pawn] = Dstpwn[side]; Dstop[pawn] = Dstart[pawn] + 1;
  for (i = 0; i <= PieceCnt[side]; i++)
    GenMoves(ply,PieceList[side][i],side,xside);
  if (kingmoved[side] == 0)
    {
      castle(side,255,0,0,&ok);
      if (ok) LinkMove(ply,255,0,side,xside);
      castle(side,0,255,0,&ok);
      if (ok) LinkMove(ply,0,255,side,xside);
    }
  sort(TrPnt[ply],TrPnt[ply+1]-1);
}


MakeMove(side,node,tempb,tempc)
short side,*tempc,*tempb;
struct leaf *node;

/*
    Update Arrays board[], color[], and Index[] to reflect the new
    board position obtained after making the move pointed to by
    node.  Also update miscellaneous stuff that changes when a move
    is made.
*/
    
{
register short f,t;
short ok,xside;

  xside = otherside[side];
  f = node->f; t = node->t; epsquare = -1; xkillr = t;
  GameList[++GameCnt] = (f<<8) + t;
  if (f == 255 || t == 255)
    {
      GamePc[GameCnt] = no_piece; GameClr[GameCnt] = neutral;
      castle(side,f,t,1,&ok);
    }
  else
    {
      *tempc = color[t]; *tempb = board[t];
      GamePc[GameCnt] = *tempb; GameClr[GameCnt] = *tempc;
      if (*tempc != neutral)
        {
          UpdatePieceList(*tempc,t,1);
          if (*tempb == pawn) --PawnCnt[*tempc][col[t]];
          if (board[f] == pawn)
            {
              --PawnCnt[side][col[f]];
              ++PawnCnt[side][col[t]];
            }
          mtl[xside] -= value[*tempb];
          if (*tempb == pawn) pmtl[xside] -= value[pawn];
        }
      color[t] = color[f]; board[t] = board[f];
      Index[t] = Index[f]; PieceList[side][Index[t]] = t;
      color[f] = neutral; board[f] = no_piece;
      if (board[t] == pawn)
        if (t-f == 16) epsquare = f+8;
        else if (f-t == 16) epsquare = f-8;
      if (node->flags & promote)
        {
          board[t] = queen;
          mtl[side] += value[queen] - value[pawn];
          pmtl[side] -= value[pawn];
        } 
      if (board[t] == king) ++kingmoved[side];
      if (node->flags & epmask) en_passant(side,xside,f,t,1);
    }
}


UnmakeMove(side,node,tempb,tempc)
short side,*tempc,*tempb;
struct leaf *node;

/*
    Take back the move pointed to by node.
*/

{
register short f,t;
short ok,xside;

  xside = otherside[side];
  f = node->f; t = node->t; epsquare = -1;
  GameCnt--;
  if (f == 255 || t == 255) castle(side,f,t,2,&ok);
  else
    {
      color[f] = color[t]; board[f] = board[t];
      Index[f] = Index[t]; PieceList[side][Index[f]] = f;
      color[t] = *tempc; board[t] = *tempb;
      if (*tempc != neutral)
        {
          UpdatePieceList(*tempc,t,2);
          if (*tempb == pawn) ++PawnCnt[*tempc][col[t]];
          if (board[f] == pawn)
            {
              --PawnCnt[side][col[t]];
              ++PawnCnt[side][col[f]];
            }
          mtl[xside] += value[*tempb];
          if (*tempb == pawn) pmtl[xside] += value[pawn];
        }
      if (node->flags & promote)
        {
          board[f] = pawn;
          mtl[side] += value[pawn] - value[queen];
          pmtl[side] += value[pawn];
        } 
      if (board[f] == king) --kingmoved[side];
      if (node->flags & epmask) en_passant(side,xside,f,t,2);
    }
}


LinkCapture(ply,f,t,ck)
short ply,f,t,ck;
{
struct leaf *node;

  node = &Tree[TrPnt[ply+1]];
  ++TrPnt[ply+1];
  node->flags = node->reply = 0;
  node->f = f; node->t = t;
  if (t == ykillr || t == ck) node->score = value[board[t]]-board[f];
  else node->score = value[board[t]]-value[board[f]];
}


CaptureList(side,xside,ply)
short side,xside,ply;

/*
    Generate a list of captures similiarly to GenMoves.
*/

{
register short m,u,d;
short i,j,m0,piece,ck,*aloc;

  ck = Ckillr[side] & 0x00FF;
  TrPnt[ply+1] = TrPnt[ply];
  Dstart[pawn] = Dstpwn[side]; Dstop[pawn] = Dstart[pawn] + 1;
  aloc = &PieceList[side][0];
  for (i = 0; i <= PieceCnt[side]; i++)
    { 
      piece = board[*aloc]; m0 = map[*aloc];
      if (sweep[piece])
        for (j = Dstart[piece]; j <= Dstop[piece]; j++)
          {
            d = Dir[j]; m = m0+d; u = unmap[m];
            while (u >= 0)
              if (color[u] == neutral)
                {
                  m += d; u = unmap[m];
                }
              else
                {
                  if (color[u] == xside) LinkCapture(ply,*aloc,u,ck);
                  u = -1;
                }
          }
      else
        for (j = Dstart[piece]; j <= Dstop[piece]; j++)
          if ((u = unmap[m0+Dir[j]]) >= 0)
            if (color[u] == xside) LinkCapture(ply,*aloc,u,ck);
      aloc++;
    }
  sort(TrPnt[ply],TrPnt[ply+1]-1);
}


distance(a,b)
short a,b;
{
short d1,d2;

  d1 = col[a]-col[b]; if (d1 < 0) d1 = -d1;
  d2 = row[a]-row[b]; if (d2 < 0) d2 = -d2;
  if (d1 > d2) return(d1); else return(d2);
}


ScorePosition(side,score)
short side,*score;

/*
  Calculate a positional score for each piece as follows:
    pawns:
      material value     : 100 pts
      d,e file, not moved: -10 pts
           & also blocked: -10 pts
      doubled            : -12 pts (each pawn)
      isolated           : -24 pts
      backward           : -8  pts
         & attacked      : -6  pts
      passed             : depends on rank, material balance,
                           position of opponents king, blocked
    knights:
      material value     : 330 pts
      centre proximity   : array pknight 
    bishops:
      material value     : 330 pts
      discourage edges   : array pbishop
      mobility           : +2 pts per move  
    rooks:
      material value     : 500 pts
      mobility           : +2 pts per move
      open file          : +12 pts
      half open          : +6 pts
    queen:
      material value     : 950 pts
    king:
      castled            : ~ +10 pts (depends on material)
      king moved         : ~ -15 pts (depends on material)
      adjacent pawn      : +5 pts before endgame
      attacks to         : -5 pts each if more than 1 attack
      adjacent square        before endgame
      pawn missing from  : -10 pts before endgame
      adjacent column
      centre proximity   : -2 pts before endgame, during endgame
                           switches to a bonus for center proximity
                           dependent on opponents control of adjacent
                           squares
                           
    "hung" pieces        : -8  (1 hung piece)
                           -24 (more than 1)
*/

{
register short i,j,a;
short loc,e,m0,u,piece,wking,bking,cwking,cbking;
short r,db,dw,s,stage1,stage2,c1,c2,a1,a2;
short pscore[3],xside,rank,column,in_square;

  xside = otherside[side];
  pscore[white] = pscore[black] = 0;
  emtl[white] = mtl[white] - pmtl[white] - value[king];
  emtl[black] = mtl[black] - pmtl[black] - value[king];
  wking = PieceList[white][0]; bking = PieceList[black][0];
  cwking = col[wking]; cbking = col[bking];
  stage1 = 10 - (emtl[white]+emtl[black]) / 670;
  stage2 = (stage1*stage1) / 10;

  for (c1 = white; c1 <= black; c1++)
  {
    c2 = otherside[c1];
    for (i = 0; i <= PieceCnt[c1]; i++)
      {
        loc = PieceList[c1][i]; piece = board[loc];
        a1 = atak[c1][loc]; a2 = atak[c2][loc];
        rank = row[loc]; column = col[loc];
        s = svalue[loc];

        if (piece == pawn && c1 == white)
          {
            if (column == 3 || column == 4)
              if (rank == 1)
                {
                  s -= 10;
                  if (color[loc+8] == white) s -=10;
                }
              else if (rank == 4 && a1 == pawn) s += 8;
            if (column-cwking > 1 || cwking-column > 1) s += stage1*rank;
            if (PawnCnt[white][column] > 1) s -= 12;
            if (column > 0 && PawnCnt[white][column-1] == 0 &&
                column < 7 && PawnCnt[white][column+1] == 0) s -= 24;
            if (a1 != pawn && atak[c1][loc+8] != pawn)
              {
                s -= 8;
                if (a2 > 0) s -= 6;
              }
            if (PawnCnt[black][column] == 0)
              {
                dw = distance(loc,wking);
                db = distance(loc,bking);
                s += stage2*(db-dw);
                if (side == white) r = rank-1; else r = rank;
                if (row[bking] >= r && db < 8-r) in_square = true;
                  else in_square = false;
                e = 0; 
                for (a = loc+8; a < 64; a += 8)
                  if (atak[black][a] == pawn) a = 99;
                  else if (atak[black][a] > 0 || color[a] != neutral) e = 1; 
                if (a == 99) s += stage1*passed_pawn3[rank];
                else if (in_square || e == 1) s += stage1*passed_pawn2[rank];
                else s += stage1*passed_pawn1[rank];
              }
          }
        else if (piece == pawn && c1 == black)
          {
            if (column == 3 || column == 4)
              if (rank == 6)
                {
                  s -= 10;
                  if (color[loc-8] == black) s -= 10;
                }
              else if (rank == 3 && a1 == pawn) s += 8;
            if (column-cbking > 1 || cbking-column > 1) s += stage1*(7-rank);
            if (PawnCnt[black][column] > 1) s -= 12;
            if (column > 0 && PawnCnt[black][column-1] == 0 &&
                column < 7 && PawnCnt[black][column+1] == 0) s -= 24;
            if (a1 != pawn && atak[c1][loc-8] != pawn)
              {
                s -= 8;
                if (a2 > 0) s -= 6;
              }
            if (PawnCnt[white][column] == 0)
              {
                dw = distance(loc,wking);
                db = distance(loc,bking);
                s += stage2*(dw-db);
                if (side == black) r = rank+1; else r = rank;
                if (row[wking] <= r && dw < r+1) in_square = true;
                  else in_square = false;
                e = 0; 
                for (a = loc-8; a >= 0 ; a -= 8)
                  if (atak[white][a] == pawn) a = -99;
                  else if (atak[white][a] > 0 || color[a] != neutral) e = 1; 
                if (a == -99) s += stage1*passed_pawn3[7-rank];
                else if (in_square || e == 1) s += stage1*passed_pawn2[7-rank];
                else s += stage1*passed_pawn1[7-rank];
              }
          }
        else if (piece == knight)
          {
            s = pknight[loc];
          }
        else if (piece == bishop)
          {
            s += pbishop[loc];
          }
        else if (piece == rook)
          {
            if (PawnCnt[white][column] == 0) s += 6;
            if (PawnCnt[black][column] == 0) s += 6;
          }
        else if (piece == queen)
          {
            s = s/3;
          }
        else if (piece == king)
          {
            m0 = map[loc];
            if (castld[c1]) s += (20/(stage1+1));
            else if (kingmoved[c1] > 0) s -= (30/(stage1+1));
            if (emtl[c1] > 1300)
              {
                s -= 2*edge[loc]; a = 0;
                for (j = Dstart[king]; j <= Dstop[king]; j++)
                  if ((u = unmap[m0+Dir[j]]) >= 0)
                    {
                      if (atak[c2][u] > 0) a++;
                      if (board[u] == pawn) s += 5;
                    }
                if (a > 1) s -= 5*a; 
                if (column > 0 && PawnCnt[c1][column-1] == 0) s -= 10;
                if (column < 7 && PawnCnt[c1][column+1] == 0) s -= 10;
                if (PawnCnt[c1][column] == 0) s -= 12;
              }
            else
              {
                e = edge[loc];
                for (j = Dstart[king]; j <= Dstop[king]; j++)
                  if ((u=unmap[m0+Dir[j]]) >= 0)
                    if (atak[c2][u] == 0) e += edge[u];
                s += (e*((1300-emtl[c1])/100))/8;
              }
            if (mtl[c1]<1000 && mtl[c2]<1990 && distance(wking,bking)==2
                && e<12) s -= 30;
          }
        if (a2 > 0 && (a1 == 0 || a2 < piece)) ++hung[c1];
        if (a2 > 0) s -= 3;
        pscore[c1] += s; svalue[loc] = s;
      }
  }
  if (hung[side] > 1) pscore[side] -= 12;
  if (hung[xside] == 1) pscore[xside] -= 8;
  if (hung[xside] > 1) pscore[xside] -= 24;
  *score = mtl[side] - mtl[xside] + pscore[side] - pscore[xside] - 5;
  if (*score > 0 && pmtl[side] == 0 && emtl[side] <= value[bishop])
    *score = 0;
  if (*score < 0 && pmtl[xside] == 0 && emtl[xside] <= value[bishop])
    *score = 0;
}


CaptureSearch(side,xside,ply,depth,alpha,beta,qscore,best,bstline)
short side,xside,ply,depth,alpha,beta,qscore,*best;
unsigned short bstline[];

/*
    Perform alpha-beta search on captures up to 9 ply past
    nominal search depth.
*/

{
register short j,f,t;
short v,q,pnt,tempb,tempc,pbst,sv;
unsigned short nxtline[30];
struct leaf *node;

  *best = -qscore; bstline[ply] = 0;
  CaptureList(side,xside,ply);
  pnt = TrPnt[ply]; pbst = 0;
  while (pnt < TrPnt[ply+1] && *best <= beta)
    {
      node = &Tree[pnt]; pnt++;
      f = node->f; t = node->t;
      v = value[board[t]]-qscore+svalue[t]; 
      if (v > alpha)
        {
          if (board[t] == king) node->score = 10000;
          else if (depth == 1) node->score = v;
          else
            {
              ykillr = t; NodeCnt++;
              sv = svalue[t]; svalue[t] = svalue[f];
              tempb = board[t]; tempc = color[t];
              UpdatePieceList(tempc,t,1);
              board[t] = board[f]; color[t] = color[f];
              Index[t] = Index[f]; PieceList[side][Index[t]] = t;
              board[f] = no_piece; color[f] = neutral;
              CaptureSearch(xside,side,ply+1,depth-1,-beta,-alpha,v,
                            &q,nxtline);
              node->score = -q;
              board[f] = board[t]; color[f] = color[t];
              Index[f] = Index[t]; PieceList[side][Index[f]] = f;
              board[t] = tempb; color[t] = tempc;
              UpdatePieceList(xside,t,2);
              svalue[f] = svalue[t]; svalue[t] = sv;
            }
        if (node->score > *best)
          {
            pbst = pnt;
            *best = node->score;
            if (*best > alpha) alpha = *best;
            for (j = ply; j < 30; j++) bstline[j] = nxtline[j];
            bstline[ply] = (f<<8) + t;
          } 
        }
    }
  if (pbst == 0) Ckillr[side] = -1;
    else Ckillr[side] = (Tree[pbst].f<<8) + Tree[pbst].t;
}


expand(side,node,depth,ply,alpha,beta,nxtline)
short side,depth,alpha,beta,ply;
unsigned short nxtline[];
struct leaf *node;

/*
    Generate a score for current position by calling search routine
    to generate opponents best response.
*/

{
short s,xside;
struct leaf *reply;

  xside = otherside[side];
  nxtline[ply] = (node->f<<8) + node->t;
  nxtline[ply+1] = node->reply;
  search(xside,ply+1,depth-1,-beta,-alpha,nxtline);
  if (!timeout)
    {
      reply = &Tree[TrPnt[ply+1]];
      s = -reply->score;
      if (s >= alpha && s <= beta) node->score = s;
      else if (s < alpha && s < node->score) node->score = s;
      else if (s > beta && s > node->score) node->score = s;
      if ((reply->flags & incheck) && !(node->flags & check))
        {
          node->flags |= draw; node->score = 0;
        }
      if ((node->flags & draw) || (node->score <= -9000) ||
          (node->score >= 9000)) node->flags |= exact;
      node->reply = nxtline[ply+1];
    }
}


evaluate(side,node,ply,depth,alpha,beta,nxtline)
short side,ply,alpha,beta;
unsigned short nxtline[];
struct leaf *node;

/*
    See if either king is in check.  If positional score estimate
    passed forward from previous ply warrants, score the position.
    If positional score is greater than alpha, perform CaptureSearch
    to modify score based on ensuing capture sequence.
*/

{
short xside,s,x,t;

  hung[white] = hung[black] = 0;
  xside = otherside[side];
  ataks(xside,atak[xside]);
  if (atak[xside][PieceList[side][0]] > 0)
    {
      node->score = ply-10000;
      node->flags |= incheck;
      node->flags |= exact;
    }
  else
    {
      ataks(side,atak[side]);
      if (atak[side][PieceList[xside][0]]) node->flags |= check;
      if (ply > Sdepth) t = 0; else t = 90;
      s = -PPscore[ply-1]+mtl[side]-mtl[xside];
      if (s+t > alpha || (node->flags & check) ||
        (node->flags & pwnthrt)) ScorePosition(side,&s);
      PPscore[ply] = s-mtl[side]+mtl[xside];
      if (s < alpha || depth > 1)
        {
          if (node->score < -12000) node->score = s;
        }
      else
        {
          ykillr = xkillr;
          CaptureSearch(xside,side,ply+1,9,-s-1,-alpha,s,&x,nxtline);
          node->score = -x;
          node->reply = nxtline[ply+1];
        }
      repetition(node);
    }
}


search(side,ply,depth,alpha,beta,bstline)
short side,ply,depth,alpha,beta;
unsigned short bstline[];

/*
    Perform the main alpha-beta search.  Extensions up to 3 ply
    beyond the nominal iterative search depth MAY occur for checks,
    check evasions, pawn promotion threats, and threats to multiple
    pieces.  
*/

{
register short j;
short best,tempb,tempc,xside,pnt,pbst,hhh,d;
unsigned short mv,nxtline[30];
struct leaf *node;

  xside = otherside[side];
  if (ply == 1) InChk = false; else InChk = ChkFlag[ply-1];
  PV = bstline[ply];
  if (ply < 3)
    {
      Swag1 = Swag2 = 0;
    }
  else
    {
      Swag1 = (Tree[TrPnt[ply-2]].f<<8) + Tree[TrPnt[ply-2]].t;
      Swag2 = (Tree[TrPnt[ply-2]+1].f<<8) + Tree[TrPnt[ply-2]+1].t;
    }
  if (ply > 1) MoveList(side,ply);
  best = -12000; PPscore[ply] = -PPscore[ply-1];
  pnt = TrPnt[ply]; pbst = pnt;
  while (pnt < TrPnt[ply+1] && best<=beta && !timeout)
    {
      node = &Tree[pnt]; NodeCnt++;
      nxtline[ply+1] = 0;
      if (ply == 1)
        {
          d = node->score-best;
          if (pnt == TrPnt[ply]) extra_time = 0;
          else if (d < -50) extra_time = -response_time/3;
          else if (d < 20) extra_time = 0;
          else if (d < 60) extra_time = response_time/3;
          else if (d < 200) extra_time = response_time;
          else extra_time = 2*response_time;
        }
      if (node->flags & capture) CptrFlag[ply] = true;
        else CptrFlag[ply] = false;
      if (node->flags & pwnthrt) PawnThreat[ply] = true;
        else PawnThreat[ply] = false;
      if (ply == 1 && post)
        {
          algbrnot(node->f,node->t);
          gotoXY(50,2); printw("%5s",mvstr1,' '); ClrEoln();
        }
      if ((node->flags & exact) == 0)
      {
        MakeMove(side,node,&tempb,&tempc);
        evaluate(side,node,ply,depth,alpha,beta,nxtline);
        if (hung[xside] > 1 && ply <= Sdepth) hhh = true;
          else hhh = false;
        if (node->flags & check) ChkFlag[ply] = true; 
          else ChkFlag[ply] = false;
        if ((node->flags & exact) == 0)
          {
            if (depth > 1) expand(side,node,depth,ply,alpha,beta,nxtline);
            if (node->score <= beta && (PawnThreat[ply] ||
               ((ChkFlag[ply] || hhh) && depth == 1)))
              expand(side,node,depth+1,ply,alpha,beta,nxtline);
            else if ((ChkFlag[ply-1] || PawnThreat[ply-1]) &&
                     ply<=Sdepth+2 && Sdepth>1 &&
                     (ply>Sdepth || CptrFlag[ply-1] ||
                     (ply>3 && (ChkFlag[ply-3] || CptrFlag[ply-3])) ||
                     (hung[side] > 1)))
              expand(side,node,depth+1,ply,alpha,beta,nxtline);
          }
        UnmakeMove(side,node,&tempb,&tempc);
      }
      if (node->score > best && !timeout)
        {
          if (ply == 1 && depth > 1 && node->score>alpha &&
            (node->flags & exact) == 0) node->score += 5;
          best = node->score; pbst = pnt;
          if (best > alpha) alpha = best;
          for (j = ply; j < 30; j++) bstline[j] = nxtline[j];
          bstline[ply] = (node->f<<8) + node->t;
          if (ply == 1 && post) post_move(node);
        }
      if ((pnt % 5) == 0) ElapsedTime(0);
      pnt++;
      if (best > 9000) beta = 0;
    }
  if (timeout) pnt--;
  if (ply == 1) sort(TrPnt[ply],pnt-1);
  else Tree[TrPnt[ply]] = Tree[pbst];
  node = &Tree[TrPnt[ply]];
  mv = (node->f<<8) + node->t;
  if (node->t != (GameList[GameCnt] & 0x00FF))
    if (best > beta) killr1[ply] = mv;
    else if (mv != killr2[ply])
      {
        killr3[ply] = killr2[ply];
        killr2[ply] = mv;
      }
  if (InChk && best > -9000) Qkillr[ply] = mv;
}

