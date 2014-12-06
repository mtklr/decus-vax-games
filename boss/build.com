$!
$!  BOSS build command file:   example of how to build a boss executable
$!      from the source.  Note that in this example boss is built with
$!      no error checking on.  This greatly increases the efficiency of
$!      the program, but should only be used with de-bugged versions.
$!
$!
$ Setup:
$       on warning then continue
$       on error then goto error_trap
$!
$ Build_paths:
$       cur_path        := 'f$directory()'
$       path_dist       := 'cur_path'
$       cur_len          = 'f$length(cur_path)' - 1
$	cur_path	:= 'f$extract(0,cur_len,cur_path)'
$!       cur_path        := 
$! write sys$output cur_path
$       path_source     := 'cur_path]'
$       path_include    := 'cur_path.inc]'
$       path_macro      := 'cur_path.mar]'
$       path_data       := 'cur_path.dat]'
$       path_execute    := 'cur_path]'
$
$ define_logicals:
$       define/nolog boss_main           'path_dist'
$       define/nolog boss_source         'path_source'
$       define/nolog boss_include        'path_include'
$       define/nolog boss_macro          'path_macro'
$       define/nolog boss_data           'path_data'
$       define/nolog boss_execute        'path_execute'
$!
$ START:
$       if p1.eqs."?"           then goto HELP
$	if p1.eqs."LIBRARY"	then goto HELP_LIBRARY
$       if p1.eqs."LINK"        then goto LINK_STEP
$       if p1.eqs."TERMDEF"     then goto COMPILE_TERMDEF
$       if p1.eqs."MACROS"      then goto COMPILE_MACROS
$       if p1.eqs."BOSS"        then goto COMPILE_BOSS
$       if p1.eqs.""            then goto COMPILE_BOSS
$!
$ BAD_PARAM:
$       write sys$output "Unrecognized parameter : ",p1
$       exit
$!
$ HELP:
$       type sys$input
BUILD.COM :     Accepts one optional parameter.  By default, all steps are
                executed.  If parameter is used, only certain steps are
                executed.
 
        Parameters:     P1
                        ?       - display this help
                                - Compile all source, re-link boss
                        LINK    - re-link boss
                        MACROS  - compile all macro routines, re-link boss
                        BOSS    - compile boss & termdef, re-link boss
 
$       exit
$!
$ COMPILE_BOSS:
$       set def boss_source
$       write sys$output "Compiling BOSS.PAS."
$       pascal boss.pas /nocheck/nodebug
$       write sys$output "BOSS.PAS compiled."
$!
$ COMPILE_MACROS:
$       set def boss_macro
$       write sys$output "Compiling MACROS."
$       macro bitpos/nodebug/nolist
$       write sys$output "BITPOS compiled."
$       macro distance/nodebug/nolist
$       write sys$output "DISTANCE compiled."
$       macro insert/nodebug/nolist
$       write sys$output "INSERT compiled."
$       macro maxmin/nodebug/nolist
$       write sys$output "MAXMIN compiled."
$       macro minmax/nodebug/nolist
$       write sys$output "MINMAX compiled."
$       macro putqio/nodebug/nolist
$       write sys$output "PUTQIO compiled."
$       macro randint/nodebug/nolist
$       write sys$output "RANDINT compiled."
$       macro randrep/nodebug/nolist
$       write sys$output "RANDREP compiled."
$       library/create/object bosslib.olb
$       library/ins bosslib bitpos
$       library/ins bosslib distance
$       library/ins bosslib insert
$       library/ins bosslib maxmin
$       library/ins bosslib minmax
$       library/ins bosslib putqio
$       library/ins bosslib randint
$       library/ins bosslib randrep
$       write sys$output "BOSSLIB.OLB built."
$!
$ LINK_STEP:
$       set def boss_source
$       write sys$output "Linking."
$       link/sysshr/notrace/nodebug boss_execute:boss,boss_macro:bosslib/library
$       write sys$output "BOSS linked."
$!
$!
$ HELP_LIBRARY:
$       set def boss_data
$	if (f$search("bosshlp.hlb") .EQS. "") 
$       then 
$         library/create/help bosshlp bosshlp
$	  write sys$output "Help Library Created."
$	endif	
$!
$ THE_END:
$       set def boss_main
$       exit
$!
$ ERROR_TRAP:
$       write sys$output "***Error resulted in termination***"
$       set def boss_main
$ exit
