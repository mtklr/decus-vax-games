!
!  Notice: The game operator's username is hard coded in function
!          IsWindy in module M4.Pas. You should change it to your
!          username so you can actually build.
!
!          Temp is where the mon.exe is placed upon completion of
!          Xbuild.com. Change it to something else to fit your need.
!
$ del *.obj.*
$ del *.pen.*
$ del temp:*.exe.*
$ @xpas
$ @xlink
$ lm
$ exit
