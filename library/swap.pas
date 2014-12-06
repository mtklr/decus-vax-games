[
  Inherit
    ('SYS$LIBRARY:STARLET'),
  Environment
    ('SWAP.PEN')
]

MODULE SWAP;

[GLOBAL]
PROCEDURE  Swap ( VAR i, j : integer );
VAR
  temp : integer;
BEGIN
  temp := j;
  j := i;
  i := temp;
END;

END.
