cc = cc
link = link

#cc = cc/debug/noopt
#link = link/traceback/debug

all : aralu.exe

aralu.exe: aralu.obj play2.obj save.obj score.obj monsters.obj create.obj play.obj wizard.obj explode.obj windows.obj help.obj
	write sys$output "Linking."
	$(link) aralu,save,play,play2,score,windows,explode,create,monsters,wizard,help,o/opt
        write sys$output "Done."

aralu.obj: aralu.c aralu.h 
	write sys$output "Aralu.c"
	$(cc) aralu

create.obj: create.c aralu.h
	write sys$output "Create.c"
	$(cc) create

explode.obj: explode.c aralu.h
	write sys$output "Explode.c"
	$(cc) explode

help.obj: help.c aralu.h
	write sys$output "Help.c"
	$(cc) help

monsters.obj: monsters.c aralu.h
	write sys$output "Monsters.c"
	$(cc) monsters

play.obj: play.c aralu.h
	write sys$output "Play.c"
	$(cc) play

play2.obj: play2.c aralu.h
	write sys$output "Play2.c"
	$(cc) play2

save.obj: save.c aralu.h
	write sys$output "Save.c"
	$(cc) save

score.obj: score.c aralu.h
	write sys$output "Score.c"
	$(cc) score

windows.obj: windows.c aralu.h
	write sys$output "Windows.c"
	$(cc) windows

wizard.obj: wizard.c aralu.h 
	write sys$output "Wizard.c"
	$(cc) wizard
