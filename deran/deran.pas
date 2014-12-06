PROGRAM De_doo_ranranran(input,output,high);

  { Written 11/89 by Eric Olson }

const xmax = 61;
      ymax = 21;
      hsmax = 60;
      maxbots = 50;
      version = '3.1';
      maxold = 5;
      hsfile = 'deran_data:deranhgh.dat';

type {}
     oldaray  = array[1..maxold] of integer;
     string   = varying [80] of char;
     thing    = (the_hero,a_robot,nothing,rubble);
     robotype = array[1..maxbots] of integer;
     gridtype = array[0..xmax+1,0..ymax+1] of thing;
     str      = varying[8] of char;
     hscore = record
                uname:str;
                score:integer;
              end;

var highscore:array[1..hsmax] of hscore;
    c:char;
    highest:str;
    high:file of hscore;
    botscount:0..maxbots;
    score:integer;
    username,prompt:string;
    kb_id,tc:unsigned;
    timeout:integer;
    may_play:boolean;

[external,asynchronous] function mth$random (var seed:integer):real; extern;

[external(smg$create_virtual_keyboard)] function create_virtual_keyboard(
                %ref new_kb:unsigned;
                %descr filespec:[truncate] varying [u1] of char := %immed 0;
                %descr default :[truncate] varying [u2] of char := %immed 0;
                %descr result:[truncate] varying [u3] of char := %immed 0;
                %ref recall:unsigned := %immed 0):unsigned;
        external;

[external(smg$read_keystroke)] function read_keystroke(
                        %ref kb_id:unsigned;
                        %ref tc:unsigned;
                        %descr prompt:varying [u3] of char := %immed 0;
                        %ref disp_id:unsigned := %immed 0;
                        %ref rend_set:unsigned := %immed 0;
                        %ref rend_comp:unsigned := %immed 0):unsigned;
        external;

function get_userid:string; extern;

[external(smg$delete_virtual_keyboard)] function delete_virtual_keyboard(
                        %ref kb_id:unsigned):unsigned;
        external;

  function _getch:char; external;

  procedure clearscreen;
    begin
      writeln (chr(27),'[2J');
    end; {procedure clearscrean}

  procedure gotoxy (x,y:integer);
    begin
      write (chr(27),'[',y:0,';',x:0,'H');
    end; {procedure gotoxy}

  procedure showcommands;
    var t:integer;
    begin  {procedure showcommands }
      t := xmax+5;
      gotoxy(t,2); WriteLn ('SCORE =');
      gotoxy(t,3); WriteLn ('WAVE');
      gotoxy(t,6); WriteLn ('ZOBOS =');
      gotoxy(t+3,8); WriteLn ('7 8 9');
      gotoxy(t+4,9); WriteLn ('\|/');
      gotoxy(t+3,10); WriteLn ('4-5-6');
      gotoxy(t+4,11); WriteLn ('/|\');
      gotoxy(t+3,12); WriteLn ('1 2 3');
      gotoxy(t,14); WriteLn ('T - teleport');
      gotoxy(t,15); WriteLn ('B -');
      gotoxy(t,16); WriteLn ('W - wait');
      gotoxy(t,17); WriteLn ('R - redraw');
      gotoxy(t,19); WriteLn ('DERAN ',version,' by');
      gotoxy(t,20); WriteLn ('Eric Olson');
      gotoxy(t,21); WriteLn ('Modified by');
      gotoxy(t,22); WriteLn ('Karl Lohner');
    end;

  procedure gridxy (x,y:integer);
    begin
      gotoxy(x+1,y+1);
    end; {gridxy}

  procedure play;
    var grid,ogrid:gridtype;
        wholething,blasted,h_dead:boolean;
        wave,rval,numbots,x,y,seed:integer;
        robx,roby:robotype;

     procedure initialize; {in play}
       var bogus:real;
           i,j:integer;
       begin  {procedure initialize in play}
         seed := ((clock div 100)*43);
         wholething := false;
         wave := 0;
         x := 0;
         y := 0;
         h_dead := false;
         numbots := 5;
         score := 0;
         for i := 0 to xmax+1 do
           for j := 0 to ymax+1 do
             begin
               ogrid[i,j] := nothing;
             end;
       end;  {procedure initialize in play}

     procedure display;
       var x,y:integer;
          what:thing;
       begin              {procedure display in play}
         if wholething then
           begin  {in wholething}
             for y := 1 to ymax do
               begin
                 for x := 1 to xmax do
                  begin
                   what:=grid[x,y];
                   if what=a_robot then begin gridxy(x,y); writeln ('O'); end;
                   if what=the_hero then begin gridxy(x,y); writeln ('+'); end;
                   if what=rubble then begin gridxy(x,y); writeln ('*'); end;
                   ogrid[x,y] := grid[x,y];
                  end;
               end;
               wholething := false;
           end
         else   {if not wholething}
           for x := 1 to xmax do for y := 1 to ymax do
             if not (grid[x,y]=ogrid[x,y]) then
               begin
                 gridxy(x,y);
                 case grid[x,y] of
                   nothing:writeln (' ');
                   a_robot:writeln ('O');
                   the_hero:writeln('+');
                   rubble:writeln ('*');
                 end;
                 ogrid[x,y] := grid[x,y];
               end;
       end;    {procedure display in play}

     procedure border;
       var i,j:integer;
       begin
         gridxy(0,0);
         write('+');
         for i := 1 to xmax do write ('-');
         writeln('+');
         for j := 1 to ymax do
           begin
             write('|');
             gridxy(xmax+1,j);
             writeln('|');
           end;
         write('+');
         for i := 1 to xmax do write ('-');
         writeln('+');
       end;

     procedure redraw; {has a bug: leaves a + behind.  but you can move}
       var i,j:integer;{through it, so it's not a real bug, so i'm ignoring}
       begin           {it.}
         clearscreen;
         showcommands;
         if not blasted then
           gotoxy(xmax+9,15); writeln ('blast');
         wholething := true;
         display;
         border;
         gotoxy(xmax+13,2); writeln (score:4);
         gotoxy(xmax+10,3); writeln (wave:3);
         gotoxy(xmax+16,6); writeln (botscount:3);
       end;   {procedure redraw in play}

     procedure init_array(n:integer); {n is the number of robots.}
       var i,j,k:integer;             {x,y are the hero's coords}
       begin  {init_array in play}
         blasted := false;
         wave := wave + 1;
         botscount := n;
         gotoxy(xmax+13,2); writeln (score:4);
         gotoxy(xmax+10,3); writeln (wave:3);
         gotoxy(xmax+16,6); writeln (botscount:3);
            rval := 1;
         for i := 0 to xmax+1 do
           for j := 0 to ymax+1 do
               grid[i,j] := nothing;
         grid[x,y] := the_hero;
         gotoxy(xmax+9,15); writeln ('blast');
         for k := 1 to n do
           begin
             repeat
               i := trunc(mth$random(seed)*xmax)+1;
               j := trunc(mth$random(seed)*ymax)+1;
             until grid[i,j] = nothing;
             grid[i,j] := a_robot;
             robx[k] := i; roby[k] := j;
           end;
         if x=0 then
           begin
             repeat
               x := trunc(mth$random(seed)*xmax)+1;
               y := trunc(mth$random(seed)*ymax)+1;
             until grid[x,y] = nothing;
             grid[x,y] := the_hero;
           end;
         display;
       end;    {procedure init_array in play}

     function safeway(x,y:integer):boolean;
       var dx,dy:integer;
           r:boolean;

       function safe(x,y,dx,dy:integer):boolean;
         var zx:boolean;
         begin
          zx := false;
          if (x<1) or (y<1) or (x>xmax) or (y>ymax) or (grid[x,y]=rubble)
           then zx := true
           else if grid[x,y]=a_robot then zx := false
            else if dx*dy<>0 then zx := safe(x+dx,y+dy,dx,dy)
             else if dx=0 then
              if dy=1 then zx := safe(x,y+1,0,1) and safe(x-1,y+1,-1,1)
                             and safe(x+1,y+1,1,1)
                      else zx := safe(x,y-1,0,-1) and safe(x-1,y-1,-1,-1)
                             and safe(x+1,y-1,1,-1)
             else if dy=0 then
               if dx=1 then zx := safe(x+1,y,1,0) and safe(x+1,y-1,1,-1)
                              and safe(x+1,y+1,1,1)
                       else zx := safe(x-1,y,-1,0) and safe(x-1,y-1,-1,-1)
                              and safe(x-1,y+1,1,-1);
           safe := zx;
         end;

       begin
         r := true;
         for dx := -1 to 1 do
           for dy := -1 to 1 do
             if (dx<>0) or (dy<>0) then
               r := r and safe(x,y,dx,dy);
         safeway := r;
       end;

     function botsleft:boolean; {also moves the bots}
       var i,j:integer;
           dead,b:boolean;
       begin   {function botsleft in play}
         for i := 1 to numbots do
          begin
           if robx[i]<>0 then
             begin
               grid[robx[i],roby[i]] := nothing;
               if robx[i]<x then robx[i] := robx[i] + 1
                 else if robx[i]>x then robx[i] := robx[i] - 1;
               if roby[i]<y then roby[i] := roby[i] + 1
                 else if roby[i]>y then roby[i] := roby[i] - 1;
             end;
          end;
         for i := 1 to numbots-1 do
          if robx[i]<>0 then
            begin
              for j := i+1 to numbots do
                if (robx[i]<>0) and
                  ((robx[i]=robx[j]) and (roby[i]=roby[j])) then
                  begin
                    grid[robx[j],roby[j]] := rubble;
                    robx[i] := 0;
                    robx[j] := 0;
                    score := score + rval + rval;
                    botscount := botscount - 2;
                    gotoxy(xmax+16,6); writeln (botscount:3);
                    gotoxy(xmax+13,2); writeln (score:4);
                  end;
            end;
         for i := 1 to numbots do
           if robx[i]<>0 then
           if (grid[robx[i],roby[i]] = rubble)
             then begin
               robx[i] := 0;
               score := score + rval;
               botscount := botscount - 1;
               gotoxy(xmax+16,6); writeln (botscount:3);
               gotoxy(xmax+13,2); writeln (score:4);
             end;
         for i := 1 to numbots do
           if robx[i]<>0 then grid[robx[i],roby[i]]:=a_robot;
         botsleft := botscount<>0;
         display;
       end;

     function hero_dead:boolean; {also moves the hero}
       var c:char;
           i,ox,oy:integer;
           made_a_move:boolean;

       function botsthere:boolean;  {function botsthere in hero_dead in play}
         var i,j:integer;
             b:boolean;
         begin   {function botsthere in hero_dead in play}
           b := false;
           for i := -1 to 1 do
             for j := -1 to 1 do
               b := b or (grid[x+i,y+j]=a_robot);
           botsthere := b;
         end;  {function botsthere in hero_dead in play}

       procedure blast;
         var i,j,n:integer;
         begin          {procedure blast in hero_dead in play}
           if not blasted then
             begin
               for i := -1 to 1 do
                 for j := -1 to 1 do
                   for n := 1 to numbots do
                     if robx[n]>0 then
                       if (robx[n]=x+i) and (roby[n]=y+j)
                         then begin
                                robx[n] := 0;
                                grid[x+i,y+j] := nothing;
                                botscount := botscount - 1;
                                gotoxy(xmax+16,6); writeln (botscount:3);
                              end;
               made_a_move := true;
               blasted := true;
               gotoxy(xmax+9,15); writeln ('     ');
             end;
         end;   {procedure blast in hero_dead in play}

       procedure teleport;
         begin    {procedure teleport in hero_dead in play}
           repeat
             x := trunc(mth$random(seed)*xmax)+1;
             y := trunc(mth$random(seed)*ymax)+1;
           until (grid[x,y] = nothing);{ and (not botsthere);}
           made_a_move := true;
         end;   {procedure teleport in hero_dead in play}

       procedure last_stand;
         begin   {last stand (wait) in hero_dead in play}
           rval := 2;
           made_a_move := true;
           while (not botsthere) and (not (botscount=0)) do
             botsleft;
         end;   {  last stand (wait) in hero_dead in play}

    begin {hero_dead in play}
      ox := x; oy := y;
      h_dead := false;
      made_a_move := false;
      repeat
        read_keystroke(kb_id,tc,chr(0));
        c:=chr(tc mod 256);
        if (c='1')or(c='4')or(c='7')or(tc=276)then x:= x-1;
        if (c='3')or(c='6')or(c='9')or(tc=277)then x:= x+1;
        if (c='1')or(c='2')or(c='3')or(tc=275)then y:= y+1;
        if (c='7')or(c='8')or(c='9')or(tc=274)then y:= y-1;
        if (c='r')or(c='r') then redraw;
        if (c='5')or(c='i') then made_a_move := true;
        if (c='w')or(c='w') then last_stand;
        if (c='b')or(c='b') then blast;
        if x<1 then x := 1;
        if x>xmax then x := xmax;
        if y<1 then y := 1;
        if y>ymax then y := ymax;
        if botsthere or not (grid[x,y]=nothing) then begin x := ox; y := oy end;
        if (x<>ox) or (y<>oy) then made_a_move := true;
        if (c='t')or(c='t') then teleport;
        gotoxy(xmax+13,20); if safeway(x,y) then writeln ('e') else writeln ('o');
      until made_a_move;
      grid[ox,oy] := nothing;
      gridxy(ox,oy); writeln (' ');
      grid[x,y] := the_hero;
      gridxy(x,y); writeln ('+');
      h_dead:=botsthere;
      hero_dead:=h_dead;
    end;   {end hero_dead in play}

begin  {procedure play}
  initialize;
  border;
  showcommands;
  repeat
    init_array(numbots);
    repeat until hero_dead or not botsleft;
    numbots := numbots + 5;
    if numbots>maxbots then numbots := maxbots;
  until h_dead;
  gridxy(x,y);
  writeln(chr(27),'[1mX',chr(27),'[0m');
end;   {procedure play}

procedure read_hi;
  var i:integer;
  begin   {procedure read_hi}
    open (high,hsfile,history := old, sharing := readwrite);
    reset (high);
    for i := 1 to hsmax do
      begin
        highscore[i].uname := '';
        highscore[i].score := 0;
      end;
    for i := 1 to hsmax do
     if not eof(high) then
      begin
        highscore[i] := high^;
        get(high);
      end;
    close(high);
  end;   {procedure read_hi}

procedure write_hi;
  var i:integer;
  begin    {procedure write_hi}
    open(high,hsfile,history := old, sharing := readwrite);
    rewrite (high);
    for i := 1 to hsmax do
      begin
        high^ := highscore[i];
        put(high);
      end;
    close(high);
  end;   {procedure write_hi}

procedure checkhi;
  var i,p,old:integer;
      name:string;
      older:oldaray;

  procedure untriche(score:integer; name:string);
    var i:integer;
    procedure revbump(x:integer);
      begin
        if x<hsmax then
          begin
            highscore[x] := highscore[x+1];
            revbump(x+1);
          end
        else
          begin
            highscore[x].score := 0;
            highscore[x].uname := '';
          end;
      end;
    begin
      for i := 1 to hsmax do
        if (score=highscore[i].score) and (name=highscore[i].uname)
          then revbump(i);
    end;

  procedure bump(x:integer);
    begin     {procedure bump in checkhi}
      if x<hsmax then
        begin
          bump(x+1);
          highscore[x+1] := highscore[x];
        end;
    end; {procedure bump in checkhi}

  function harharhar(var x:oldaray;i:integer):integer;
    var j:integer;
    begin
      for j := maxold downto 2 do
        x[j] := x[j-1];
      x[1] := i;
      harharhar := x[maxold];
    end;

  begin   {procedure checkhi}
    name := get_userid;
    read_hi;
    for i := 1 to maxold do older[i] := hsmax+1;
    for i := hsmax downto 1 do
      if highscore[i].uname=name then old := harharhar(older,i);
    p := hsmax+1;
    for i := hsmax downto 1 do
      if score>highscore[i].score then p := i;
    if (p<hsmax + 1) and (p<=old) then
      begin
        if (old<=hsmax)
         then old := highscore[old].score
         else old := 0;
        if (old>0) then untriche(old,name);
        bump(p);
        highscore[p].score := score;
        highscore[p].uname := name;
        write_hi;
      end;
  end;  {procedure checkhi}

procedure show_hi;
  var i:integer;

  function highestof(h:hscore):boolean;
    var i,x:integer;
    begin
      for i := hsmax downto 1 do
        if highscore[i].uname=h.uname then x := i;
      highestof := (h.score>0) and (h.score=highscore[x].score);
    end;

  function lowestof(h:hscore):boolean;
    var i,x:integer;
    begin
      for i := 1 to hsmax do
        if highscore[i].uname=h.uname then x := i;
      lowestof := (h.score>0) and (h.score=highscore[x].score);
    end;

  begin   {procedure show_hi}
    read_hi;
    clearscreen;
    gotoxy(28,1);
    writeln (''(27),'[1m  High Scorers at DERAN  ',''(27),'[0m');
    for i := 1 to 20 do
      begin
        if (score>0) and (highscore[i].score=score) then write (chr(27),'[1m');
        gotoxy (1,i+1);
        if highestof(highscore[i])
          then writeln ('  #',i:2,':+',highscore[i].uname)
          else if lowestof(highscore[i])
            then writeln ('  #',i:2,':-',highscore[i].uname)
            else writeln ('  #',i:2,': ',highscore[i].uname);
        gotoxy(17,i+1); writeln (highscore[i].score:4);
        writeln (chr(27),'[0m');
      end;
    for i := 21 to 40 do
      begin
        if (score>0) and (highscore[i].score=score) then write (chr(27),'[1m');
        gotoxy (26,i-19);
        if highestof(highscore[i])
          then writeln ('  #',i:2,':+',highscore[i].uname)
          else if lowestof(highscore[i])
            then writeln ('  #',i:2,':-',highscore[i].uname)
            else writeln ('  #',i:2,': ',highscore[i].uname);
        gotoxy(43,i-19); writeln (highscore[i].score:4);
        writeln (chr(27),'[0m');
      end;
    for i := 41 to 60 do
      begin
        if (score>0) and (highscore[i].score=score) then write (chr(27),'[1m');
        gotoxy (52,i-39);
        if highestof(highscore[i])
          then writeln ('  #',i:2,':+',highscore[i].uname)
          else if lowestof(highscore[i])
            then writeln ('  #',i:2,':-',highscore[i].uname)
            else writeln ('  #',i:2,': ',highscore[i].uname);
        gotoxy(69,i-39); writeln (highscore[i].score:4);
        writeln (chr(27),'[0m');
      end;
    writeln;
    prompt:='Press ''P'' to play or ''Q'' to quit ';
    if not may_play then prompt := 'Sorry, Deran may not be played during peak hours. ->';
  end;   {procedure showhi}

begin  {main program}
  write (chr(27),'>');
  create_virtual_keyboard(kb_id,'SYS$COMMAND');
  read_hi;
  repeat
    may_play := true;
    show_hi;
    repeat
     if may_play then
       begin
         read_keystroke(kb_id,tc,prompt);
         c:=chr(tc mod 256);
       end
        else
       begin
         read_keystroke(kb_id,tc,prompt);
         c := 'Q';
       end;
    until ((c in ['p','P','q','Q']) or (not may_play));
    if (c in ['p','P']) and (may_play)
      then begin
             clearscreen;
             play;
             checkhi
           end;
  until (c in ['q','Q']) or (not may_play);
  delete_virtual_keyboard(kb_id);
  clearscreen;
  writeln (chr(27),'[H');
end.  {main program}
