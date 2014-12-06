$ pascal football
$ message footmsg/obj=footmsg
$ link/notrace football,footmsg
$ if f$search("*.OBJ;*") .nes. "" then delete/noconfirm *.obj;*
$ lib/cre/help football.hlb
$ lib/ins football.hlb dforms,dplays,oforms,oplays
$ exit
