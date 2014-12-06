[
  Inherit
    ('SYS$LIBRARY:STARLET','SYS$LIBRARY:PASCAL$LIB_ROUTINES'),
  Environment
    ('DAYTIME.PEN')
]

MODULE DAYTIME;

[HIDDEN]
TYPE
  $UWORD = [WORD] 0..65535;
  date_time_type = array [1..7] of $uword;  
  $QUAD = [QUAD,UNSAFE] RECORD
     L0:UNSIGNED; L1:INTEGER; END;

VAR
  date_time : [GLOBAL] date_time_type;


[ASYNCHRONOUS, EXTERNAL(LIB$DAY_OF_WEEK)]
FUNCTION  $Day_of_week
    (
        time     : $quad := %IMMED 0;
    VAR day_num  : integer
    ) : integer;
Extern;


[GLOBAL]
PROCEDURE  Get_Date_time;
VAR
  ret_status : integer;
BEGIN
  ret_status := $numtim (date_time);
  IF not odd(ret_status) then
    LIB$SIGNAL(ret_status);
END;


[GLOBAL]
FUNCTION  Day_num : integer;
VAR
  temp : integer;
  q : $quad;
  ret_status : integer;
BEGIN
  ret_status := $gettim(q);
  IF not odd(ret_status) then
    LIB$SIGNAL(ret_status);
  ret_status := $day_of_week(q,temp);
  IF not odd(ret_status) then
    LIB$SIGNAL(ret_status);
  day_num := temp;
END;

END.
