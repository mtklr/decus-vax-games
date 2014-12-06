[
  Inherit
    ('QIO_WRITE','QIO_READ','POSN','ERROR','FULL_CHAR','VT100'),
  Environment
    ('FORMATTED_READ.PEN')
]

MODULE FORMATTED_READ;

[HIDDEN]
TYPE
  v_array = varying [256] of char;


[Global]
PROCEDURE  Formated_read
 (VAR return_value   : v_array;
      picture_clause : v_array;
      x_posn         : integer;
      y_posn         : integer;
      default_value  : v_array := '';
      field_full_terminate : boolean := false;
      begin_brace    : v_array := '';
      end_brace      : v_array := ''
 );
VAR
  i : integer;
  ch : char;
  outline : v_array;


    PROCEDURE  Go_left;
    BEGIN
      IF ( i <> 1 ) then
        BEGIN
          REPEAT
            i := i - 1;
          UNTIL ( i = 1 ) or ( picture_clause[i] in ['9','X'] );
          IF not ( picture_clause[i] in ['9','X'] ) then
            BEGIN
              WHILE not ( picture_clause[i] in ['9','X'] ) do
                i := i + 1;
            END;
        END;
    END;


    PROCEDURE  Go_right;
    BEGIN
      IF ( i <> length(picture_clause) ) then
        BEGIN
          REPEAT
            i := i + 1;
          UNTIL ( i = length(picture_clause) ) or ( picture_clause[i] in ['9','X'] );
          IF not ( picture_clause[i] in ['9','X'] ) then
            BEGIN
              WHILE not ( picture_clause[i] in ['9','X'] ) do
                i := i - 1;
            END;
        END;
    END;


    PROCEDURE  Escape_sequence;
    BEGIN
      ch := qio_1_char;
      IF ( ch = '[' ) then
        BEGIN
          ch := qio_1_char;
          CASE ch of
            'C' : go_right;
            'D' : go_left;
            Otherwise
             qio_write (chr(7));                
          End;
        END
      ELSE
        qio_write (chr(7));                
    END;


    PROCEDURE  Delete;
    VAR
      last : integer;
    BEGIN
      IF ( i <> 1 ) then
        BEGIN
          last := length(picture_clause)+1;
          REPEAT
            last := last - 1;
          UNTIL ( last = 1 ) or ( picture_clause[last] in ['9','X'] );

          IF ( i <> last ) or ( return_value[i] = ' ' ) then
            REPEAT
              i := i - 1;
            UNTIL ( i = 1 ) or ( picture_clause[i] in ['9','X'] );

          IF not ( picture_clause[i] in ['9','X'] ) then
            BEGIN
              WHILE not ( picture_clause[i] in ['9','X'] ) do
                i := i + 1;
            END
          ELSE
            BEGIN
              posn (x_posn+i-1,y_posn);
               qio_write (' '+VT100_bs);
              return_value[i] := ' ';
            END;
        END;
    END;


    PROCEDURE  Key_control;
    BEGIN
      IF ( ch = chr(13) ) then
        BEGIN
          field_full_terminate := true;
          i := length(picture_clause) + 1;
        END
      ELSE
      IF ( ch = chr(27) ) then
        escape_sequence
      ELSE
      IF ( ch = chr(127) ) then
        delete
      ELSE
        qio_write (chr(7));                
    END;


BEGIN
  return_value := '';

{ get x & y if left out }

  FOR i := 1 to length(picture_clause) do
      CASE picture_clause[i] of
        '9' : IF length(default_value) < i then
                return_value := return_value + ' '
              ELSE
              IF ( default_value[i] in [' ','0'..'9'] ) then
                return_value := return_value + default_value[i]
              ELSE
                ERROR ('DEFAULT VALUE /'+default_value[i]+'/ DOES NOT MATCH PICTURE CLAUSE /'+picture_clause[i]+'/');
        'X' : IF length(default_value) < i then
                return_value := return_value + ' '
              ELSE
              IF ( default_value[i] in [' '..'~'] ) then
                return_value := return_value + default_value[i]
              ELSE
                ERROR ('%INTERACT-F-DVMM, DEFAULT VALUE /'+full_char(default_value[i])+'/ DOES NOT MATCH PICTURE CLAUSE /'+picture_clause[i]+'/');
       otherwise 
          return_value := return_value + picture_clause[i];
      End;

  outline := '';

  posn (x_posn,y_posn);
  IF length(begin_brace) > 0 then
    outline := outline + begin_brace;
  outline := outline + return_value;
  IF length(end_brace) > 0 then
    outline := outline + end_brace;

  qio_write (outline);

  IF length(begin_brace) > 0 then
    x_posn := x_posn + length(begin_brace);

  i := 1;
  REPEAT
    WHILE ( i <= length(picture_clause) ) do
      BEGIN
        posn (x_posn+i-1,y_posn);
        CASE picture_clause[i] of
          '9' : BEGIN
                  ch := qio_1_char;
                  IF ( ch in [' ','0'..'9'] ) then
                    BEGIN
                      return_value[i] := ch;
                      qio_write (ch);
                      i := i + 1;
                    END
                  ELSE
                    key_control;
                END;
          'X' : BEGIN
                  ch := qio_1_char;
                  IF ( ch in [' '..'~'] ) then
                    BEGIN
                      return_value[i] := ch;
                      qio_write (ch);
                      i := i + 1;
                    END
                  ELSE
                    key_control;
                END;
         otherwise 
            i := i + 1;
        End;
      END;
    IF ( i > length(picture_clause) ) and ( not field_full_terminate ) then
      i := length(picture_clause);
  UNTIL ( i > length(picture_clause) );
END;

END.
