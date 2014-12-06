 
{ Initialize, restore, and get the ball rolling.
  Read in the critters' flags and convert them.  -Opusii}
       
PROCEDURE gethex(var num:unsigned);
const mult=7;
var i,chnum,jindex,qcntr:integer;
    ch:char;
    number : packed array [1..12] of char;
BEGIN
num:=0;
qcntr := 0;
jindex := 1;
readln(opusii,number);
repeat
  if((number[jindex]>='A')and(number[jindex]<='F'))
    then
      chnum:=ord(number[jindex])-ord('A')+10
    else
      chnum:=ord(number[jindex])-ord('0');
if (number[jindex]='''') then
    qcntr := qcntr + 1;
  if(qcntr>0)and(((jindex-4)>=0)and((jindex-4)<=7))then
   num:=num+(16**(mult-(jindex-4)))*chnum;
  jindex := jindex + 1;
until(qcntr=2)
end;

                        

procedure read_creatures ;                
          
BEGIN
{read creatures from external file}
      open (Opusii,MORIA_MON,readonly);
      reset(Opusii);
      readln(Opusii,max_creatures);
      for Opusii_cnt := 1 to max_creatures do
        with c_list[Opusii_cnt] do
          BEGIN
            readln(Opusii,name);
            for indx := 1 to 3 do
              BEGIN
                gethex(hexnum);
                CASE indx OF
                 1 : cmove := hexnum;
                 2 : spells := hexnum;
                 3 : cdefense := hexnum
                END        
              END;
            readln(Opusii,sleep,mexp,aaf,ac,speed);
            readln(Opusii,cchar);
            readln(Opusii,hd);
            readln(Opusii,damage);
            readln(Opusii,level);
          END;
      close(Opusii);
END;


procedure read_data;

BEGIN
read_creatures;
END;

