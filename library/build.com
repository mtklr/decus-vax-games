$! Command file to create the INTERACT and UTIL object libraries.
$!
$ IF P1 .EQS. "UTIL" THEN GOTO UTIL
$!
$! Interact library
$! ----------------
$!
$ PAS/NOOBJ INTERACT
$ LIBRARY/CREATE INTERACT.OLB
$ MACRO DEBUG_FLAG
$ LIBRARY/INSERT INTERACT.OLB DEBUG_FLAG
$ MACRO MAP
$ LIBRARY/INSERT INTERACT.OLB MAP
$ PAS CRESEC
$ LIBRARY/INSERT INTERACT.OLB CRESEC
$ PAS DAY
$ LIBRARY/INSERT INTERACT.OLB DAY
$ PAS DAYTIME
$ LIBRARY/INSERT INTERACT.OLB DAYTIME
$ PAS DEC
$ LIBRARY/INSERT INTERACT.OLB DEC
$ PAS EXTRACT
$ LIBRARY/INSERT INTERACT.OLB EXTRACT
$ PAS GET_JPI
$ LIBRARY/INSERT INTERACT.OLB GET_JPI
$ PAS HEX
$ LIBRARY/INSERT INTERACT.OLB HEX
$ PAS IMAGE_DIR
$ LIBRARY/INSERT INTERACT.OLB IMAGE_DIR
$ PAS RANDOM
$ LIBRARY/INSERT INTERACT.OLB RANDOM
$ PAS RANDOMIZE
$ LIBRARY/INSERT INTERACT.OLB RANDOMIZE
$ PAS RMS_STATUS
$ LIBRARY/INSERT INTERACT.OLB RMS_STATUS
$ PAS SIGN
$ LIBRARY/INSERT INTERACT.OLB SIGN
$ PAS STOPWATCH
$ LIBRARY/INSERT INTERACT.OLB STOPWATCH
$ PAS SWAP
$ LIBRARY/INSERT INTERACT.OLB SWAP
$ PAS SYSCALL
$ LIBRARY/INSERT INTERACT.OLB SYSCALL
$ PAS TRIM
$ LIBRARY/INSERT INTERACT.OLB TRIM
$ PAS VT100
$ LIBRARY/INSERT INTERACT.OLB VT100
$ PAS CASE_CONVERT
$ LIBRARY/INSERT INTERACT.OLB CASE_CONVERT
$ PAS ERROR
$ LIBRARY/INSERT INTERACT.OLB ERROR
$ PAS FULL_CHAR
$ LIBRARY/INSERT INTERACT.OLB FULL_CHAR
$ PAS GET_POSN
$ LIBRARY/INSERT INTERACT.OLB GET_POSN
$ PAS CREEFC
$ LIBRARY/INSERT INTERACT.OLB CREEFC
$ PAS HANDLER
$ LIBRARY/INSERT INTERACT.OLB HANDLER
$ PAS DEBUG
$ LIBRARY/INSERT INTERACT.OLB DEBUG
$ PAS QIO_READ
$ LIBRARY/INSERT INTERACT.OLB QIO_READ
$ PAS QIO_WRITE
$ LIBRARY/INSERT INTERACT.OLB QIO_WRITE
$ PAS SLEEP
$ LIBRARY/INSERT INTERACT.OLB SLEEP
$ PAS CLEAR
$ LIBRARY/INSERT INTERACT.OLB CLEAR
$ PAS GET_CLEAR
$ LIBRARY/INSERT INTERACT.OLB GET_CLEAR
$ PAS POSN
$ LIBRARY/INSERT INTERACT.OLB POSN
$ PAS RESET_SCREEN
$ LIBRARY/INSERT INTERACT.OLB RESET_SCREEN
$ PAS SMART_POSN
$ LIBRARY/INSERT INTERACT.OLB SMART_POSN
$ PAS SQUARE
$ LIBRARY/INSERT INTERACT.OLB SQUARE
$ PAS FORMATTED_READ
$ LIBRARY/INSERT INTERACT.OLB FORMATTED_READ
$ PAS QIO_READ_INTEGER
$ LIBRARY/INSERT INTERACT.OLB QIO_READ_INTEGER
$ PAS QIO_READ_VARYING
$ LIBRARY/INSERT INTERACT.OLB QIO_READ_VARYING
$ PAS TOPTEN
$ LIBRARY/INSERT INTERACT.OLB TOPTEN
$ PAS SHOW_GRAPHEDT
$ LIBRARY/INSERT INTERACT.OLB SHOW_GRAPHEDT
$!
$! Util library
$! ------------
$!
$UTIL:
$ MACRO TTIO
$ MACRO SLEEP
$ MACRO IMAGEDIR
$ LIBRARY/CREATE UTIL.OLB
$ LIBRARY/INSERT UTIL.OLB TTIO,SLEEP,IMAGEDIR
$ SET FILE/TRUNC UTIL.OLB
$!
$! Cleanup
$!
$ DELETE/NOCONFIRM *.OBJ;*
$ DELETE/NOCONFIRM/EXCLUDE=INTERACT.PEN *.PEN;*
$!
$ EXIT