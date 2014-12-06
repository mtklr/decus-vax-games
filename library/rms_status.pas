[ 
  Inherit 
    ('SYS$LIBRARY:STARLET'),
  Environment 
    ('RMS_STATUS.PEN') 
]

MODULE RMS_STATUS;

[HIDDEN]
TYPE
  unknown_file = [UNSAFE,VOLATILE] File of char;
  fabptr = ^fab$type;
  rabptr = ^rab$type;

[HIDDEN]
VAR
  glo_fab    : fabptr;
  glo_fabsts : unsigned;
  glo_fabstv : unsigned;
  glo_rab    : rabptr;
  glo_rabsts : unsigned;
  glo_rabstv : unsigned;


[EXTERNAL]
FUNCTION  PAS$FAB ( VAR file_var : unknown_file ) : fabptr;
Extern;

[EXTERNAL]
FUNCTION  PAS$RAB ( VAR file_var : unknown_file ) : rabptr;
Extern;

[GLOBAL]
PROCEDURE  RMS_signal;
VAR
  item_list : array [0..2] of unsigned;
BEGIN
  item_list[0] := 2; { No. arguements }
  IF glo_fab = nil then
    item_list[1] := glo_fabsts
  ELSE
    item_list[1] := glo_fab^.fab$l_sts;
  IF glo_fab = nil then
    item_list[2] := glo_fabstv
  ELSE
    item_list[2] := glo_fab^.fab$l_stv;
  IF odd(item_list[1]) then
    BEGIN
      IF glo_rab = nil then
        item_list[1] := glo_rabsts
      ELSE
        item_list[1] := glo_rab^.rab$l_sts;
      IF glo_rab = nil then
        item_list[2] := glo_rabstv
      ELSE
        item_list[2] := glo_rab^.rab$l_stv;
    END;
  $putmsg (item_list);
END;

[GLOBAL]
FUNCTION  RMS_Status : integer;
VAR
  temp : unsigned;
BEGIN
  IF glo_fab = nil then
    temp := glo_fabsts
  ELSE
    temp := glo_fab^.fab$l_sts;
  IF odd(temp) then
  IF glo_rab = nil then
    temp := glo_rabsts
  ELSE
    temp := glo_rab^.rab$l_sts;
  RMS_status := temp::integer;
END;


[GLOBAL]
FUNCTION  Open_status_new ( VAR Fab : fab$type;
                            VAR Rab : rab$type;
                        VAR Filevar : unknown_file ) : integer;
VAR
  status : integer;
BEGIN
  Status := $create(fab);
  If odd(status) then
    Status := $connect(rab);
  open_status_new := status;
  glo_fab    := PAS$FAB ( filevar );
  glo_fabsts := fab.fab$l_sts;
  glo_fabstv := fab.fab$l_stv;
  glo_rab    := PAS$RAB ( filevar );
  glo_rabsts := rab.rab$l_sts;
  glo_rabstv := rab.rab$l_stv;
END;

[GLOBAL]
FUNCTION  Open_status_old ( VAR Fab : fab$type;
                            VAR Rab : rab$type;
                        VAR Filevar : unknown_file ) : integer;
VAR
  status : integer;
BEGIN
  Status := $open(fab);
  If odd(status) then
    Status := $connect(rab);
  open_status_old := status;
  glo_fab    := PAS$FAB ( filevar );
  glo_fabsts := fab.fab$l_sts;
  glo_fabstv := fab.fab$l_stv;
  glo_rab    := PAS$RAB ( filevar );
  glo_rabsts := rab.rab$l_sts;
  glo_rabstv := rab.rab$l_stv;
END;

[GLOBAL]
PROCEDURE  check_status;
BEGIN
  IF not odd(rms_status) then
    BEGIN
      rms_signal;
      $exit(1);
    END;
END;

END.
