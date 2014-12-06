srgod.exe: srgod.obj
	pn "g_linking"
	link srgod,srinit,srsys,srio,srother,srgodact,srcom,srop,srtime,srmap,srmove,srmisc,srmenu
srgod.obj: root:srgod.pas root:srclass.pas srinit.obj srsys.obj srio.obj srother.obj srmisc.obj srmenu.obj srmap.obj srmove.obj srop.obj srcom.obj srgodact.obj srtime.obj
	pn "srgod"
	pas root:srgod
srinit.obj: root:srinit.pas
	pn "srinit"
	pas root:srinit
srsys.obj: srinit.obj root:srsys.pas
	pn "srsys"
	pas root:srsys
srio.obj: srsys.obj root:srio.pas
	pn "srio"
	pas root:srio
srother.obj: srio.obj root:srother.pas
	pn "srother"
	pas root:srother
srmisc.obj: srother.obj root:srmisc.pas
	pn "srmisc"
	pas root:srmisc
srmenu.obj: srother.obj root:srmenu.pas
	pn "srmenu"
	pas root:srmenu
srmap.obj: srmisc.obj root:srmap.pas
	pn "srmap"
	pas root:srmap
srmove.obj: srmap.obj root:srmove.pas
	pn "srmove"
	pas root:srmove
srop.obj: srmisc.obj srmenu.obj root:srop.pas
	pn "srop"
	pas root:srop
srcom.obj: srmove.obj root:srcom.pas
	pn "srcom"
	pas root:srcom
srgodact.obj: srmove.obj root:srgodact.pas
	pn "srgodact"
	pas root:srgodact
srtime.obj: srmove.obj root:srtime.pas
	pn "srtime"
	pas root:srtime
