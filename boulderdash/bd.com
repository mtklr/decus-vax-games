$  write sys$output "Terminal/Port auf 19200 Baud stellen!"
$  write sys$output "You *MUST* be on a VT200 or higher to run this well"
$  wait 00:00:01
$flag:
$  read/prompt="Are you on a VT[1m[7m2[0m00 or VT[1m[7m3[0m00? "/end=flag sys$command terminal_type
$  tt = f$extract (0,1,terminal_type)
$  if tt .nes. "2" .and. tt .nes. "3"
$  then
$   write sys$output "please type [1m[4m2[0m or [1m[4m3[0m to answer, when in doubt type 2"
$   write sys$output "[A[A[A
$   goto flag
$  endif
$  if tt .eqs. "2" then set term/dev=vt200/speed=19200
$  if tt .eqs. "3" then set term/dev=vt300/speed=19200
$  define/nolog b$dash_in mas$games:[boulderdash]bd.pointer
$  define/nolog b$dash mas$games:[boulderdash]
$  bd = "$mas$games:[boulderdash]bd"
$  define/user sys$input sys$command
$  bd 'p1 'p2 'p3 'p4 'p5 'p6 'p7 'p8
$  exit
