$   set on
$   on warning then goto  bad_build
$   on error then goto bad_build
$   on severe then goto bad_build
$   pascal = "pascal/optimization/nocheck/nolist"
$   link = "link/notrace/nomap"
$   if p1.eqs."LINK" then goto link_stage
$   write sys$output ""
$   write sys$output "==> Compiling MACROS."
$   write sys$output ""
$   macro bit_pos
$   write sys$output "BIT_POS compiled."
$   macro distance
$   write sys$output "DISTANCE compiled."
$   macro get_account
$   write sys$output "GET_ACCOUNT compiled."
$   macro insert
$   write sys$output "INSERT compiled."
$   macro maxmin
$   write sys$output "MAXMIN compiled."
$   macro minmax
$   write sys$output "MINMAX compiled."
$   macro putqio
$   write sys$output "PUTQIO compiled."
$   macro randint
$   write sys$output "RANDINT compiled."
$   macro randrep
$   write sys$output "RANDREP compiled."
$   macro subquad
$   write sys$output "SUBQUAD compiled."
$   macro users
$   write sys$output "USERS compiled."
$   write sys$output ""
$   write sys$output "==> Compiling FORTRAN files."
$   fortran/extended_source/continuations\=99/nolist bit_pos64
$   write sys$output "BIT_POS64 compiled."
$   fortran/extended_source/continuations\=99/nolist uw_id
$   write sys$output "UW_ID compiled."
$   write sys$output ""
$   write sys$output "==> Creating CDU object file."
$   set command/obj=moriadef moriadef
$   write sys$output "MORIADEF created."
$   write sys$output ""
$   write sys$output "==> Creating MORIALIB.OLB."
$   library/create=(blocks:0,globals:12,history:0,-
    keysize:31,modules:12) morialib.olb 
$   library morialib bit_pos
$   library morialib get_account
$   library morialib distance
$   library morialib insert
$   library morialib maxmin
$   library morialib minmax
$   library morialib putqio
$   library morialib randint
$   library morialib randrep
$   library morialib subquad
$   library morialib users
$   library morialib bit_pos64
$   write sys$output "MORIALIB.OLB created."
$   write sys$output ""
$   write sys$output "==> Creating help library."
$   runoff moriahlp.rnh
$   library/create/help moriahlp.hlb moriahlp.hlp
$   write sys$output "MORIAHLP.HLB created."
$   write sys$output ""
$   write sys$output "==> Compiling MAIN module."
$   pascal moria/env=moria.env
$   write sys$output "MAIN module compiled."
$   write sys$output ""
$   write sys$output "==> Compiling PASCAL files."
$   write sys$output ""
$   pascal dungeon/env=dungeon.env
$   write sys$output "DUNGEON compiled."
$   pascal casino
$   write sys$output "CASINO compiled."
$   pascal create
$   write sys$output "CREATE compiled."
$   pascal creature
$   write sys$output "CREATURE compiled."
$   pascal death
$   write sys$output "DEATH compiled."
$   pascal desc
$   write sys$output "DESC compiled."
$   pascal files
$   write sys$output "FILES compiled."
$   pascal generate
$   write sys$output "GENERATE compiled."
$   pascal help
$   write sys$output "HELP compiled."
$   pascal inven
$   write sys$output "INVEN compiled."
$   pascal io
$   write sys$output "IO compiled."
$   pascal misc
$   write sys$output "MISC compiled."
$   pascal netopen
$   write sys$output "NETOPEN compiled."
$   pascal player
$   write sys$output "PLAYER compiled."
$   pascal quest
$   write sys$output "QUEST compiled."
$   pascal save
$   write sys$output "SAVE compiled."
$   pascal screen
$   write sys$output "SCREEN compiled."
$   pascal store
$   write sys$output "STORE compiled."
$   pascal termdef
$   write sys$output "TERMDEF compiled."
$   pascal wizard
$   write sys$output "WIZARD compiled."
$   write sys$output ""
$ LINK_STAGE:
$   write sys$output "==> Linking the files."
$   link/exe=imoria moria,moriadef,casino,create,death,desc,-
    files,generate,help,io,misc,netopen,save,termdef,dungeon,-
    creature,inven,player,screen,store,wizard,quest,uw_id,-
    morialib/lib,sys$system:sys.stb/selective
$   write sys$output ""
$   write sys$output "IMORIA.EXE is now ready for use."
$   goto bye
$ bad_build:
$   write sys$output "An error was encountered. Try again."
$ bye:
$   if f$search("*.OBJ;*") .nes. "" then delete/noconf *.obj;*
$   if f$search("*.ENV;*") .nes. "" then delete/noconf *.env;*
$   if f$search("*.OLB;*") .nes. "" then delete/noconf *.olb;*
$   exit
