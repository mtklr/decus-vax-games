$ define/nolog root $1$dua12:[temp.maself]
! This is where the .pas files are to be kept.
$ set process/priority = 4
$ pn = "set proc/name = "
$ set def temp
! temp is a variable I have previously defined.  I keep the scratch work out
! of my regular account this way.  You might DEFINE TEMP SYS$SCRATCH or
! something like that.
$ if p1 .eqs. "D"
$ then
$ pas = "pascal/debug/noopt"
$ link = "link/debug"
$ endif
$ define makefile root:sr.make
! Place where the makefile is kept.  (W/ the .pas files...in my case).
$ make
$ write sys$output "Wowsers."
