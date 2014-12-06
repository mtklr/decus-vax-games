! ************************************************************************
! * Planet Name Generation Routine		N. Utzig  
! * Args:    1 dummy string
! * Returns: String (20 character max)
! * Uses external data list - should be independent of main prog DATA
! ************************************************************************

FUNCTION STRING Pnamegen( STRING Ptype )

! Returns Random Planet Name <pname>
! Ptype is a dummy variable, but could be used to alter the generation
! routine for things other than planet names (I made a random corporation
! name gen routine using this algorithm also)
! Ptype is also used in a recursive call procedure, below

 st_limit=170 ! planet-name-prefix data limit (increase as data added) 
 en_limit=160 ! planet-name-suffix data limit (increase as data added)
 sf_limit=30  ! optional ending planet name word

Redoit:
 RANDOMIZE
 RESTORE

 FOR x=1 to INT(st_limit*RND)+1   ! pick a random starting string
  READ d1$
 NEXT x

d4$=""
IF RND<.05 then			! 5% chance of concatinating another prefix
RESTORE				! to the planet name
 FOR x=1 to INT(st_limit*RND)+1
  READ d4$
 NEXT x
END IF

rloop1:
 READ x$
 if x$<>"***" then goto rloop1    ! skip to endings
 END IF



 FOR x=1 to INT(en_limit*RND)+1   ! pick a random ending
  READ d2$
 NEXT x

if Ptype="one" then goto skipit
END IF
if rnd<.05 then d2$=d2$+"-"+Pnamegen("one") ! 5% chance of hyphenated double
END IF					 ! planet name - genreated via a
					 ! recursive call to Pname

d3$=""
!IF RND<.05 then		        
					 ! 5% chance of optional ending
					 ! word such as 'world', 'base', etc.
!Rloop2:
! READ x$
! if x$<>"**2" then goto rloop2
! END IF
!
! FOR x=1 to INT(sf_limit*RND)+1
!  READ d3$
! NEXT x
!END IF

Skipit:
d0$=d1$+d4$+d2$+" "+d3$		  ! concatinate substrings into full name
if len(d0$)>10 then goto redoit   ! strings large than 20 chars thrown out
END IF
Pnamegen=d0$			  ! return Pname
!
! Planet name prefixes - ten per line can be modified to alter the
! distribution and flavor of the names
!
data alpha,beta,gamma,omega,tri,duo,spectra,bina,hydra,cano
data expo,mega,do,ma,bi,qua,pen,load,test,mono
data ursa,cepha,leo,aqua,tau,span,neo,sex,dra,dil
data poly,ban,ben,pre,excel,homo,tel,fru,micro,mini
data sim,cim,cut,cru,ja,ki,lar,bung,ever,god
data wonder,water,necro,win,sun,sola,luna,stella,o,i
data zo,zone,plane,top,out,off,in,other,xeno,thar
data bo,no,oni,uni,doo,boo,snea,tar,dia,yu
data en,eg,my,hol,jar,kli,kro,mole,pi,ro
data xero,ya,in,ib,cy,zy,by,rhino,anti,omni
data gli,cla,pro,re,spu,ana,fun,fore,ga,go
data pha,pho,terra,vo,vul,snow,blood,mar,ven,mer
data gore,aa,ee,ii,oo,uu,gna,who,bur,sala
data reci,reta,pyro,ultra,bul,ir,hemo,co,hyper,meso
data emi,dark,slave,narco,fighter,last,first,second,third,mid
data main,dog,cat,fish,sky,hunter,pitt,crown,king,queen
data flex,cor,proto,pola,equi,lata,longi,ad,at,ith
!
! planet name suffixes - ten per line
!
data ***
data con,lex,ni,peia,ces,cron,gus,tax,nor,ceros
data ris,sus,sos,sis,can,goid,star,num,nus,bis
data culum,culus,dar,dis,dun,don,dill,den,fu,fus
data vid,vun,xor,xon,zian,sian,scior,xior,sion,tion
data pus,-world,land,go,axx,star,a,i,o,y
data hole,pit,put,dud,du,pu,ono,unu,nu,home
data center,-one,ex,ox,ix,mania,manx,end,cross,jun
data ov,s,x,dolar,nius,as,less,bie,ker,di
data to,utu,ufi,obi,ab,ble,ree,some,pe,it
data shi,l,ne,le,re,ap,tron,eki,ki,cho
data gr,ikh,okka,zoa,era,na,th,ch,sh,tch
data angulum,rrus,alis,lios,line,tech,lf,stock,bar,bone
data mander,pori,c,k,nk,full,ot,rt,gle,glo
data vis,vane,ac,ack,new,dee,-planet,jip,gen,gan
data dock,port,-landing,harbor,bay,cove,-island,field,city,town
data vus,ibod,inor,ivin,haven,nest,pot,ng,gh,tk
!
! optional ending words to planet names - ten per line
!
data **2
data major,minor,prime,1,2,3,4,5,6,7
data port,base,ring,cluster,point,stop,8,9,outpost,nebula
data quasar,cloud,nova,cluster,prime,major,minor,base,outpost,landing
END FUNCTION
