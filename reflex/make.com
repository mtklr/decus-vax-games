$ write sys$output "Compiling..."
$ pascal/opt/nodebug misc, reflex
$ write sys$output "Linking..."
$ link/nodebug reflex, misc
$ write sys$output "Finished!"
