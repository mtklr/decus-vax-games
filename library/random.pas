[
  Inherit
    ('SYS$LIBRARY:STARLET'),
  Environment
    ('RANDOM.PEN')
]

MODULE RANDOM;

[HIDDEN]
VAR
  seed : integer;
  seed_initialized : boolean;


[GLOBAL]
PROCEDURE  Seed_initialize ( users_seed : [TRUNCATE] integer );
VAR
  time : packed array [0..1] of integer;
BEGIN
  seed_initialized := true;
  IF present(users_seed) then
    seed := users_seed
  ELSE
    BEGIN
      $gettim(time);
      seed := time[0];
    END;
END;


[GLOBAL]
FUNCTION  Random ( ub : integer ) : integer;
{ Produce random integer between 1 & ub inclusive }

        FUNCTION  Mth$Random ( VAR seed : integer ) : real;
          extern;

BEGIN
  If not seed_initialized then
    seed_initialize;
  Random := Trunc (( Mth$Random ( seed ) * ub ) + 1);
END; { Random }


[GLOBAL]
FUNCTION  Rnd ( lb, ub : integer ) : integer;
{ Produce random integer between lb & ub }

        FUNCTION  Mth$Random ( VAR seed : integer ) : real;
          extern;

BEGIN
  If not seed_initialized then
    seed_initialize;
  rnd := Trunc (( Mth$Random ( seed ) * (ub-lb+1) ) + lb );
END; { Random }

END.
