[
  Inherit
    ('SYS$LIBRARY:STARLET','RANDOM'),
  Environment
    ('RANDOMIZE.PEN')
]

MODULE RANDOMIZE;

[HIDDEN]
TYPE
  r_number_pointer = ^r_numbers;
  r_numbers        = Record
                       Number : integer;
                       Next   : r_number_pointer;
                     End;
[HIDDEN]
VAR
  random_number_ub : integer;
  random_number_count : integer;
  head_random_number : r_number_pointer;
  this_random_number : r_number_pointer;
  stack_random_number : r_number_pointer;


[GLOBAL]
PROCEDURE  Reset_randomizer;
BEGIN
  random_number_ub := 0;
  random_number_count := 0;
  this_random_number := head_random_number;;
  WHILE ( this_random_number <> nil ) do
    BEGIN
      this_random_number := this_random_number^.next;
      head_random_number^.next := stack_random_number;
      stack_random_number := head_random_number;
      head_random_number := this_random_number;
    END;
END;


[GLOBAL]
FUNCTION  Randomize ( ub : integer ) : integer;
VAR
  temp : integer;
  add  : integer;

    PROCEDURE  Insert_random_number ( temp : integer );
    VAR
      hold : r_number_pointer;
      linked : boolean;
    BEGIN
      this_random_number := head_random_number;
      IF ( this_random_number = nil ) then
        BEGIN
          IF ( stack_random_number = nil ) then
            NEW (head_random_number)
          ELSE
            BEGIN
              head_random_number := stack_random_number;
              stack_random_number := stack_random_number^.next;
            END;
          head_random_number^.number := temp;
          head_random_number^.next := nil;
        END
      ELSE
      IF ( this_random_number^.number > temp ) then
        BEGIN
          IF ( stack_random_number = nil ) then
            NEW (this_random_number)
          ELSE
            BEGIN
              this_random_number := stack_random_number;
              stack_random_number := stack_random_number^.next;
            END;
          this_random_number^.number := temp;
          this_random_number^.next := head_random_number;
          head_random_number := this_random_number;
        END
      ELSE
        BEGIN
          IF ( stack_random_number = nil ) then
            NEW (hold)
          ELSE
            BEGIN
              hold := stack_random_number;
              stack_random_number := stack_random_number^.next;
            END;
          hold^.number := temp;
          hold^.next := nil;
          linked := false;
          WHILE ( this_random_number^.next <> nil ) do
            BEGIN
              IF ( this_random_number^.number < temp ) and
                 ( this_random_number^.next^.number > temp ) then
                BEGIN
                  hold^.next := this_random_number^.next;
                  this_random_number^.next := hold;
                  linked := true;
                END;
              this_random_number := this_random_number^.next;
            END;
          IF not linked then
            this_random_number^.next := hold;
        END;
    END;

BEGIN
  IF ( random_number_ub <> ub ) then
    BEGIN
      random_number_ub := ub;
      random_number_count := ub;
    END
  ELSE
    random_number_count := random_number_count - 1;

  IF ( random_number_count <= 0 ) then
    Randomize := 0
  ELSE
    BEGIN
      temp := Random (random_number_count);
      add := 0;

      this_random_number := head_random_number;
      WHILE ( this_random_number <> nil ) do
        BEGIN
          IF ( this_random_number^.number < temp ) then
            add := add + 1;
          this_random_number:= this_random_number^.next;
        END;

      this_random_number := head_random_number;
      WHILE ( this_random_number <> nil ) do
        BEGIN
          IF ( this_random_number^.number = temp ) then
            temp := temp + 1;
          IF ( this_random_number^.number > temp ) and ( add > 0 ) then
            BEGIN
              add := add - 1;
              temp := temp + 1;
            END
          ELSE
            this_random_number := this_random_number^.next;
        END;
      temp := temp + add;
      randomize := temp;
      Insert_random_number ( temp );
    END;
END;

END.
