$ write sys$output "There are bugs in LARN:"
$ write sys$output "  LARN will not properly add a score to the high score list."
$ define/nolog larndir mas$games:[larn]
$ define/nolog termcap larndir:termcap.vms
$ larn := $larndir:larn
$ def/nolog/user sys$input sys$command
$ larn 'p1 'p2 'p3 'p4 'p5 'p6 'p7 'p8
$ exit
