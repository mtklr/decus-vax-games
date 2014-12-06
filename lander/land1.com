$ if p1 .nes. "C" then goto l1
$ cc land
$ cc move
$ cc score
$ cc screen
$ l1:
$ link land,move,score,screen,land.opt/opt
$ exit
