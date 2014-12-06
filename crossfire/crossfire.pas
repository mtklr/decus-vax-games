[ Inherit ('INTERACT') ]

PROGRAM CROSSFIRE (picfile,screenfile);
 
CONST
  walls      = ['j'..'x'];
  greeblies  = ['O','#','*'];
  greeblieno = 24;
  topclass   = 3;
  topprize   = 2;
  ammopic    = '+';
  maxshots   = 5;
  space      = ' ';
  youpic     = '`';
  startlives = 3;
  bonus      = '$';

TYPE
  ammotype =  RECORD           (** Ammunition left in each of four weapons. **)
                u,d,l,r :INTEGER;
              END;
  boardline = ARRAY [10..40] OF CHAR;
  greeblietype = RECORD       (** One record for each greeblie. **)
                   pic           :1..topclass;
                   x             :0..39;
                   y             :0..23;
                   active,alive  :BOOLEAN;
                 END;
  greebliestart   = RECORD    (** One start position per greeblie. **)
                      x :11..39;
                      y :2..23;
                    END;
    directype        = (U,D,L,R,S);
    bulletype        = RECORD    (** Shot in motion. **)
                    x        :10..40;
                    y        :1..24;
                    aim        :directype;
                  END;
    drawstring  = VARYING [80] OF CHAR;
    outstring   = VARYING [255] OF CHAR;
    v_string    = VARYING [255] OF CHAR;
    score_type  = INTEGER;

VAR
    picfile,screenfile :TEXT;
    score                    :score_type;
    board                    :ARRAY [1..24] OF boardline;
    xpos, ammoX, bonusX            :11..39;
    ypos, ammoY, bonusY            :2..23;
    bonuslive, ammolive            :BOOLEAN;
    yourlives                    :INTEGER;
    ammo                    :ammotype;
    direction,newdirection  :directype;
    greeblie                    :ARRAY [1..greeblieno] OF greeblietype;
    startpos                    :ARRAY [1..greeblieno] OF greebliestart;
    pic                            :ARRAY [1..topclass] OF CHAR;
    greebvalue                    :ARRAY [1..topclass] OF INTEGER;
    shots                    :ARRAY [1..maxshots] OF bulletype;
    shotsgoing                    :0..maxshots;
    activegreeb,livingreeb  :0..greeblieno;
    Round_no                    :0..500;
    sleeptime :integer;
    maxactive    :UNSIGNED;
    Move_counter, efn            :INTEGER;
    exitordered                    :BOOLEAN;
 

(*** Main Display Routine. ***)

 PROCEDURE DRAWAT(y,x :INTEGER; string :drawstring; stringlength :INTEGER);
(*************************************************************************)
 BEGIN
   qio_Write(VT100_esc+'['+dec(y)+';'+dec(x)+'H'+string);
 END;

(** Draw a single character - co-ords always length 2. **)

 PROCEDURE DRAWCHAR(y,x :INTEGER; letter :CHAR);
(**********************************************)
 BEGIN
   qio_Write(VT100_esc+'['+dec(y)+';'+dec(x)+'H'+letter);
 END;


 PROCEDURE SHOWSCORE(score :score_type);
(**************************************)
 BEGIN
   qio_write (VT100_esc+'[4;2H'+dec(score,,7));
 END;


(** Draw ammo indicator - called whenever screen is updated. **)

 PROCEDURE DRAWAMMO;
(******************)
 BEGIN
   IF ammo.u > 10 THEN DrawChar(12,7,'x')
                  ELSE IF ammo.u > 0 THEN DrawChar(12,7,'.');
   IF ammo.d > 10 THEN DrawChar(14,7,'x')
                  ELSE IF ammo.d > 0 THEN DrawChar(14,7,'.');
   IF ammo.l > 10 THEN DrawChar(13,6,'q')
                  ELSE IF ammo.l > 0 THEN DrawChar(13,6,'.');
   IF ammo.r > 10 THEN DrawChar(13,8,'q')
                  ELSE IF ammo.r > 0 THEN DrawChar(13,8,'.');
 END; (* Draw Ammo indicator *)


(** Draw screen and set graphics mode. **)

 PROCEDURE INITSCREEN;
(********************)

 VAR inline                :v_string;
     boardindex,lineindex,
     counter                :INTEGER;
     sparemen                :PACKED ARRAY [1..5] OF CHAR;

 BEGIN
   OPEN(screenfile,'IMAGE_DIR:Crossfire.scn',history := readonly);
   RESET(screenfile);
   counter := 0;
   READLN(screenfile,inline);   (*** First line does screen init. ***)
   qio_Write(inline);
   REPEAT
     READLN(screenfile,inline);
     qio_Write(inline);
     counter := counter + 1;
     lineindex := 0;
     REPEAT
       lineindex := lineindex + 1;
     UNTIL ((inline.body[lineindex] = '#') AND (inline.body[lineindex+1] = '6'));
     lineindex := lineindex + 11;
     boardindex := 10;
     WHILE NOT (lineindex > inline.length) DO BEGIN
       board[counter][boardindex] := inline.body[lineindex];
       boardindex := boardindex + 1;
       lineindex := lineindex + 1;
     END; (** while on current line **)
   UNTIL EOF(screenfile);
   CLOSE(screenfile);
   ShowScore(score);
   qio_write (VT100_esc+'[9;4H'+dec(Round_no,,2));
   DrawAmmo;

   Bonuslive := FALSE;        AmmoLive := FALSE;

   (** Draw row of waiting extra lives. **)

   sparemen := '~~~~~';
   IF yourlives > 1 THEN
     FOR counter := 1 TO (yourlives - 1) DO
       sparemen[counter] := youpic;
   qio_write (VT100_esc+'[12;1H'+sparemen);

   Drawchar(ypos,xpos,youpic);
   FOR counter := 1 TO greeblieno DO
     IF greeblie[counter].alive THEN
       Drawchar(greeblie[counter].y,greeblie[counter].x,pic[greeblie[counter].pic]);
 END; (** Initscreen **)


(*** Called once - at the start of each game. ***) 

 PROCEDURE INITGAME;
(******************)

 VAR        counter        :INTEGER;


  PROCEDURE DRAWTITLE;
  VAR
    inchar : char;
    Inline : varying [255] of char;
  BEGIN
    Image_dir;
    OPEN(picfile,'IMAGE_DIR:Crossfire_start.pic', History := readonly);
    RESET(picfile);
    WHILE NOT EOF(picfile) DO BEGIN
      readln (picfile,Inline);
      qio_writeln (Inline);
    END;
    CLOSE(picfile);
    IF upper_case(qio_1_Char) = 'I' THEN 
      show_graphedt ('Crossfire_help.pic');
  END; (* draw title page *)


 BEGIN
   drawtitle;
   efn := 21;        (* No. of event flag used by sleeps. *)
   exitordered := FALSE;
   yourlives := startlives;
   Round_no := 0;
   Move_counter := 0;
   pic[1] := 'O'; pic[2] := '#'; pic[3] := '*';
   greebvalue[1] := 10; greebvalue[2] := 25; greebvalue[3] := 50;
   ammo.u := 25; ammo.d := 25; ammo.l := 25; ammo.r := 25;
   FOR counter := 1 TO greeblieno DO BEGIN
     CASE counter OF
       1,2,3,4,5,6,
       7        :BEGIN
                   startpos[counter].x := 9 + 4 * counter;
                   startpos[counter].y := 2
                 END;
       8,9,10,11,
       12        :BEGIN
                   startpos[counter].x := 39;
                   startpos[counter].y := 4 * (counter - 7);
                 END;
       13,14,15,16,17,18,
       19        :BEGIN
                   startpos[counter].x := 37 - 4 * (counter - 13);
                   startpos[counter].y := 22;
                 END;
       20,21,22,23,
       24        :BEGIN
                   startpos[counter].x := 11;
                   startpos[counter].y := 20 - 4 * (counter - 20);
                 END;
     END; (** case counter **)
   END; (** FOR counter **)
 END; (** Initialise Game **)


(*** Called each time you lose a life. ***)

 PROCEDURE RESTART_PLAY;
(**********************)

 VAR        counter        :INTEGER;

 BEGIN
   xpos := 28; ypos := 12; 
   shotsgoing := 0;
   FOR counter := 1 TO maxshots DO
     shots[counter].aim := S;
   activegreeb := 0;
   FOR counter := 1 TO greeblieno DO BEGIN
     IF greeblie[counter].active THEN BEGIN
       greeblie[counter].x := startpos[counter].x;
       greeblie[counter].y := startpos[counter].y;
     END; (** Send active greeblies home. **)
     greeblie[counter].active := FALSE;
   END; (** FOR counter **)
 END; (** Restart play **)


 PROCEDURE YOUREDEAD(VAR lives :INTEGER);
(***************************************)

 BEGIN
   qio_write (vt100_BELL);
   qio_purge;
   lives := lives - 1;
   IF lives > 0 THEN BEGIN
     Restart_Play;
     InitScreen;
   END; (** IF lives > 0 **)
 END; (*** You're Dead ***)


(*** Called at the start of each round. ***)

 PROCEDURE INITROUND;
(*******************)

 VAR        counter        :INTEGER;

 BEGIN
   Round_no := Round_no + 1;
   CASE (Round_no MOD 11) OF
        1        :BEGIN sleeptime := 30; maxactive := 2; END;
        2        :BEGIN sleeptime := 24; maxactive := 2; END;
        3        :BEGIN sleeptime := 18; maxactive := 2; END;
        4        :BEGIN sleeptime := 28; maxactive := 3; END;
        5        :BEGIN sleeptime := 22; maxactive := 3; END;
        6        :BEGIN sleeptime := 16; maxactive := 3; END;
        7        :BEGIN sleeptime := 30; maxactive := 4; END;
        8        :BEGIN sleeptime := 25; maxactive := 4; END;
        9        :BEGIN sleeptime := 30; maxactive := 5; END;
        10        :BEGIN sleeptime := 25;        maxactive := 5;        END;
        0        :BEGIN sleeptime := 20;        maxactive := 5;        END;
   END; (** Case round_no mod 10 **)
   yourlives := min(5,yourlives + 1);
   xpos := 28; ypos := 12; 
   direction := R;
   newdirection := R;
   shotsgoing := 0;
   FOR counter := 1 TO maxshots DO
     shots[counter].aim := S;
   activegreeb := 0;
   livingreeb := greeblieno;
   FOR counter := 1 TO greeblieno DO BEGIN
     greeblie[counter].active := FALSE;
     greeblie[counter].alive  := TRUE;
     greeblie[counter].pic := 1;
     greeblie[counter].x := startpos[counter].x;
     greeblie[counter].y := startpos[counter].y;
   END; (** FOR counter **)
 END; (** Initialise round **)


 (*** Carried out at end of each round. ***)

 PROCEDURE ROUNDOVER;
(*******************)

 VAR 
        counter                        :1..23;
        round_bonus, ammo_bonus,
        life_bonus, total_bonus        :INTEGER;
        inchar                        :CHAR;

 BEGIN
   FOR counter := 1 TO 23 DO
     Drawat(counter,10,VT100_esc+'[K',3);
   qio_write (VT100_graphics_off);
   posn (15,2);
   qio_write ('ROUND '+dec(round_no)+' COMPLETED');
   round_bonus := round_no * 100;
   posn (15,14);
   qio_write ('Victory Bonus :'+dec(round_bonus,,4));
   life_bonus := yourlives * 50 * round_no;
   posn (15,15);
   qio_write ('Lives   Bonus :'+dec(life_bonus,,4));
   ammo_bonus := ammo.u + ammo.d + ammo.l + ammo.r;
   posn (15,16);
   qio_write ('Ammo.   Bonus :'+dec(ammo_bonus,,4));
   total_bonus := ammo_bonus + life_bonus + round_bonus;
   posn (29,17);
   qio_write (VT100_graphics_on+'qqqqqq'+VT100_graphics_off);
   posn (30,18);
   qio_write (dec(total_bonus,,4));
   score := score + total_bonus;
   Showscore(score);
   posn (11,23);
   qio_write ('[Press a key to begin round.]'+VT100_graphics_on);
   qio_purge;
   inchar := qio_1_Char;
 END;


 PROCEDURE MOVESHOT(VAR shot:bulletype);
(**************************************)

 VAR
        count        :1..greeblieno;

  PROCEDURE CHECKSHOT(VAR shot:bulletype);
 (*=====================================*)
  BEGIN
    FOR count := 1 TO greeblieno DO
      IF ((greeblie[count].x = shot.x) AND (greeblie[count].y = shot.y)) THEN BEGIN
        (** Without following check, can subtract same shot more than once. **)
        IF NOT (shot.aim = S) THEN   
          shotsgoing := shotsgoing - 1;
        shot.aim := S;
        IF greeblie[count].active THEN activegreeb := activegreeb - 1;
        score := score + greebvalue[greeblie[count].pic];
        Drawchar(shot.y,shot.x,' ');
        Showscore(score);
        IF (greeblie[count].pic = topclass) THEN BEGIN
          greeblie[count].x := 0;
          greeblie[count].y := 0;
          greeblie[count].alive := FALSE;
          livingreeb := livingreeb - 1;
        END
        ELSE BEGIN
          greeblie[count].x := startpos[count].x;
          greeblie[count].y := startpos[count].y;
          greeblie[count].active := FALSE;
          greeblie[count].pic := greeblie[count].pic + 1;
          Drawchar(greeblie[count].y,greeblie[count].x,pic[greeblie[count].pic]);
        END; (*** If can be upgraded ***)
      END; (** If right greeblie **)        
  END;


 BEGIN (** Move Shots **)
   Checkshot(shot);
   CASE shot.aim OF
     U        :IF (board[shot.y-1][shot.x] IN walls) THEN BEGIN
               shot.aim := S;
               shotsgoing := shotsgoing - 1;
               IF NOT ((shot.x = xpos) AND (shot.y = ypos)) THEN
                 Drawchar(shot.y,shot.x,space);
         END
         ELSE
           IF ((shot.x = xpos) AND (shot.y = ypos)) THEN BEGIN
             shot.y := shot.y - 1;
             Drawchar(shot.y,shot.x,'.');
           END
           ELSE BEGIN
             Drawat(shot.y,shot.x,space+VT100_esc+'[D'+VT100_esc+'[A.',8);
             shot.y := shot.y - 1;
           END;
     D :IF (board[shot.y+1][shot.x] IN walls) THEN BEGIN
               shot.aim := S;
               shotsgoing := shotsgoing - 1;
               IF NOT ((shot.y = ypos) AND (shot.x = xpos)) THEN
                 Drawchar(shot.y,shot.x,space);
        END
        ELSE
          IF ((shot.x = xpos) AND (shot.y = ypos)) THEN BEGIN
             shot.y := shot.y + 1;
             Drawchar(shot.y,shot.x,'.');
           END
           ELSE BEGIN
               Drawat(shot.y,shot.x,space+VT100_esc+'[D'+VT100_esc+'[B.',8);
               shot.y := shot.y + 1;
           END;
     L :IF (board[shot.y][shot.x-1] IN walls) THEN  BEGIN
               shot.aim := S;
               shotsgoing := shotsgoing - 1;
               IF NOT ((shot.y = ypos) AND (shot.x = xpos)) THEN
                 Drawchar(shot.y,shot.x,space);
        END
        ELSE
          IF ((shot.x = xpos) AND (shot.y = ypos)) THEN BEGIN
             shot.x := shot.x - 1;
             Drawchar(shot.y,shot.x,'.');
           END
           ELSE BEGIN
               shot.x := shot.x - 1;
               Drawat(shot.y,shot.x,'.'+space,2);
           END;
     R :IF (board[shot.y][shot.x+1] IN walls) THEN BEGIN
               shot.aim := S;
               shotsgoing := shotsgoing - 1;
               IF NOT ((shot.y = ypos) AND (shot.x = xpos)) THEN
                 Drawchar(shot.y,shot.x,space);
        END
         ELSE
           IF ((shot.x = xpos) AND (shot.y = ypos)) THEN BEGIN
             shot.x := shot.x + 1;
             Drawchar(shot.y,shot.x,'.');
           END
           ELSE BEGIN
               Drawat(shot.y,shot.x,space+'.',2);
               shot.x := shot.x + 1;
           END;
     S :;
   END; (** case aim **)

(*** If shot still going ***)

   IF NOT (shot.aim = S) THEN checkshot(shot);
 END;


 PROCEDURE MOVESHOTS;
(*******************)
 VAR counter        :1..maxshots;

 BEGIN
   FOR counter := 1 TO maxshots DO
     IF NOT (shots[counter].aim = S) THEN moveshot(shots[counter]);
 END; (** Moveshots **)


 PROCEDURE FIRE(x,y:INTEGER; aim:directype);
(******************************************)

 VAR        shotcount        :1..maxshots;
        ammoleft        :INTEGER;
        string1,string2        :v_string;
    
 BEGIN
   IF NOT (shotsgoing = maxshots) THEN BEGIN
     shotcount := 1;
     WHILE NOT (shots[shotcount].aim = S) DO
       shotcount := shotcount + 1;
     CASE aim OF
       U:ammoleft := ammo.u;
       D:ammoleft := ammo.d;
       L:ammoleft := ammo.l;
       R:ammoleft := ammo.r;
     END; (*** Case aim ***)
     IF (ammoleft > 0) THEN BEGIN
       CASE aim OF
         U:BEGIN
             ammo.u := ammo.u - 1;
             IF (ammo.u = 10) THEN 
               qio_Write(VT100_esc+'[12;7H.')
             ELSE 
             IF (ammo.u = 0) THEN 
               qio_Write(VT100_esc+'[12;7H ');
           END;
         D:BEGIN
             ammo.d := ammo.d - 1;
             IF (ammo.d = 10) THEN qio_Write(VT100_esc+'[14;7H.')
               ELSE IF (ammo.d = 0) THEN qio_Write(VT100_esc+'[14;7H ');
           END;
         L:BEGIN
             ammo.l := ammo.l - 1;
             IF (ammo.l = 10) THEN qio_Write(VT100_esc+'[13;6H.')
               ELSE IF (ammo.l = 0) THEN qio_Write(VT100_esc+'[13;6H ');
           END;
         R:BEGIN
             ammo.r := ammo.r - 1;
             IF (ammo.r = 10) THEN qio_Write(VT100_esc+'[13;8H.')
               ELSE IF (ammo.r = 0) THEN qio_Write(VT100_esc+'[13;8H ');
           END;
       END; (*** Case aim ***)       
       shots[shotcount].aim := aim;
       shots[shotcount].x := x;
       shots[shotcount].y := y;
       shotsgoing := shotsgoing + 1;
     END; (** If relevant gun has ammo left **)
   END; (** If room for more shots. **)
 END; (*** fire ***)


  PROCEDURE RELOAD(VAR Ammolive :BOOLEAN);
 (***************************************)
  BEGIN
    IF Ammolive THEN BEGIN
      ammo.u := ammo.u + 20;
      ammo.d := ammo.d + 20;
      ammo.l := ammo.l + 20;
      ammo.r := ammo.r + 20;
      DrawAmmo;
      Ammolive := FALSE;
   END; (* if *)
  END;


  PROCEDURE PAYOUT(VAR Score :INTEGER; VAR Bonuslive :BOOLEAN);
 (************************************************************)
  BEGIN
    IF bonuslive THEN BEGIN
      Score := Score + Round_no * 100;
      ShowScore(Score);
      Bonuslive := FALSE;
    END; (* if *)
  END;


 PROCEDURE MOVEPLAYER;
(********************)

 VAR        index :1..greeblieno;

 BEGIN
   IF NOT(newdirection = direction) THEN
     CASE newdirection OF
       U :IF NOT (board[ypos-1][xpos] IN walls) THEN direction := U;
       D :IF NOT (board[ypos+1][xpos] IN walls) THEN direction := D;
       L :IF NOT (board[ypos][xpos-1] IN walls) THEN direction := L;
       R :IF NOT (board[ypos][xpos+1] IN walls) THEN direction := R;
     END; (** case newdirection**)
   
   CASE direction OF
     U :IF (board[ypos-1][xpos] IN walls) THEN direction := S
        ELSE BEGIN
               Drawat(ypos,xpos,space+VT100_esc+'[D'+VT100_esc+'[A'+youpic,8);
               ypos := ypos - 1;
             END;
     D :IF (board[ypos+1][xpos] IN walls) THEN direction := S
        ELSE BEGIN
               Drawat(ypos,xpos,space+VT100_esc+'[D'+VT100_esc+'[B'+youpic,8);
               ypos := ypos + 1;
             END;
     L :IF (board[ypos][xpos-1] IN walls) THEN direction := S
        ELSE BEGIN
               xpos := xpos - 1;
               Drawat(ypos,xpos,youpic+space,2);
             END;
     R :IF (board[ypos][xpos+1] IN walls) THEN direction := S
        ELSE BEGIN
               Drawat(ypos,xpos,space+youpic,2);
               xpos := xpos + 1;
             END;
     S :;
   END; (** case direction**)

   IF (xpos = ammoX) AND (ypos = ammoY) THEN Reload(ammolive)
   ELSE IF (xpos = bonusX) AND (ypos = bonusY) THEN Payout(score, bonuslive);

   FOR index := 1 TO greeblieno DO
     IF (greeblie[index].alive)
        AND (greeblie[index].x = xpos) AND (greeblie[index].y = ypos) THEN
        youredead(yourlives);
 END;


 PROCEDURE PLAYERMOVE;
(********************)
 VAR    inchar :CHAR;
 BEGIN
   inchar := qio_1_char_now;
   CASE inchar OF
     CHR(5)                :exitordered := TRUE;        (* CTRL-E *)
     'i','I','8'        :newdirection := U;
     'j','J','4'        :newdirection := L;
     'k','K','m','M','2':newdirection := D;
     'l','L','6'        :newdirection := R;
     'w','W'                :Fire(xpos,ypos,U);
     's','S','x','X'        :Fire(xpos,ypos,D);
     'a','A'                :Fire(xpos,ypos,L);
     'd','D'                :Fire(xpos,ypos,R);
     'r','R'                :Initscreen;
     OTHERWISE ;
   END; (** case **)
   Moveplayer;
 END;


 PROCEDURE MOVEGREEBLIES;
(***********************)

 VAR
        index        :1..greeblieno;

  PROCEDURE MOVEGREEB(VAR greeb: Greeblietype);
 (*==========================================*)

  VAR moveno :0..4;

  BEGIN
    moveno := 0;
    IF ((greeb.y = ypos) AND (greeb.x = xpos)) THEN youredead(yourlives);
    IF ((greeb.y > ypos) AND NOT (board[greeb.y-1][greeb.x] IN walls)) THEN
      moveno := 1;
    IF ((greeb.y < ypos) AND NOT (board[greeb.y+1][greeb.x] IN walls)) THEN
      moveno := 2;
    IF ( random(10) <= 5) THEN BEGIN
      IF ((greeb.x > xpos) AND NOT (board[greeb.y][greeb.x-1] IN walls)) THEN
        moveno := 3;
      IF ((greeb.x < xpos) AND NOT (board[greeb.y][greeb.x+1] IN walls)) THEN
        moveno := 4;
    END; (*** 50% chance ***)
    IF yourlives > 0 THEN
      CASE moveno OF
       1 :BEGIN
            Drawat(greeb.y,greeb.x,space+VT100_esc+'[D'+VT100_esc+'[A'+pic[greeb.pic],8);
            greeb.y := greeb.y - 1;
          END;
       2 :BEGIN
            Drawat(greeb.y,greeb.x,space+VT100_esc+'[D'+VT100_esc+'[B'+pic[greeb.pic],8);
            greeb.y := greeb.y + 1;
          END;
       3 :BEGIN
            greeb.x := greeb.x - 1;
            Drawat(greeb.y,greeb.x,pic[greeb.pic]+space,2);
          END;
       4 :BEGIN
            Drawat(greeb.y,greeb.x,space+pic[greeb.pic],2);
            greeb.x := greeb.x + 1;
          END;
       OTHERWISE ;
      END; (*** Case moveno ***)
    IF ((greeb.y = ypos) AND (greeb.x = xpos)) THEN youredead(yourlives)
    ELSE
      IF (greeb.y = bonusY) AND (greeb.x = bonusX) THEN bonuslive := FALSE;
  END;


 BEGIN
   IF (activegreeb < maxactive) THEN BEGIN
     index := random(greeblieno);
     IF (greeblie[index].alive AND NOT(greeblie[index].active)) THEN BEGIN
       greeblie[index].active := TRUE;
       activegreeb := activegreeb + 1;
     END; (*** IF inactive ***)
   END; (*** If room for more ***)

   IF (activegreeb > 0) THEN
     FOR index := 1 TO greeblieno DO
       IF (greeblie[index].active AND greeblie[index].alive) THEN
         movegreeb(greeblie[index]);
 END;


(***** Main Program *****)

BEGIN
  InitGame;
  REPEAT
    InitRound;
    Initscreen;
    REPEAT
      Sleep_start(sleeptime);
      Playermove;
      IF NOT exitordered THEN BEGIN
          Moveshots;
        Moveshots;
        Movegreeblies;
        Sleep_wait;
        Move_counter := Move_counter + 1;
        IF Ammolive THEN Drawchar(ammoY,ammoX,ammopic);
        CASE Move_counter OF
              100        :BEGIN
                         IF Ammolive THEN BEGIN
                           DrawChar(ammoY,ammoX,space);
                           Ammolive := FALSE;
                         END; (* else *)
                       END;
             300        :BEGIN
                         ammoX := xpos;
                          ammoY := ypos;
                       END;
              320        :BEGIN
                         bonusX := xpos;
                         bonusY := ypos;
                       END;
              375        :BEGIN
                           qio_write (VT100_bell);
                          Drawchar(bonusY,bonusX,bonus);
                        Bonuslive := TRUE;
                       END;
             400        :BEGIN
                          qio_write (VT100_bell);
                         Ammolive := TRUE;
                           Move_counter := 0;
                       END;
              OTHERWISE;
        END; (** case **)
      END; (** If not exitordered **)
   UNTIL (yourlives <= 0) OR (livingreeb = 0) OR exitordered;
   IF (yourlives > 0) AND NOT exitordered THEN Roundover;
  UNTIL (yourlives <= 0) OR exitordered;
  qio_write (VT100_graphics_off);
  Top_Ten(Score);
END.
