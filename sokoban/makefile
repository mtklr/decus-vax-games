WS = write sys$output

all: sok.exe
  $(WS) "All done."

sok.exe: sok.obj play.obj readscreen.obj save.obj score.obj showscreen.obj
  $(WS) "Linking."
  link sok,play,readscreen,save,score,showscreen,o/opt

sok.obj: sokoban.h sok.c
  $(WS) "Compiling sok.c"
  cc sok

play.obj: sokoban.h play.c
  $(WS) "Compiling play.c"
  cc play

readscreen.obj: sokoban.h readscreen.c
  $(WS) "Compiling readscreen.c"
  cc readscreen

save.obj: sokoban.h save.c
  $(WS) "Compiling save.c"
  cc save

score.obj: sokoban.h score.c
  $(WS) "Compiling score.c"
  cc score

showscreen.obj: sokoban.h showscreen.c
  $(WS) "Compiling showscreen.c"
  cc showscreen

install:
  $(WS) "Installing."
  rename sok.exe [-]
