[INHERIT 
        (
        'SYS$LIBRARY:STARLET',
        'INTERACT'
        )
        ]

Program Mushroom( Input, output, infile );

        { 
MAULER 131 - 
        Mushrooms, a game of skill, patience and hard work.
        You must tour around the mushroom field, eating all the mushrooms
        you can, and not starving. 
        Beware !

        ^ = normal mushroom
        - = poison mushroom
        * = magic mushroom
        
        You tend to feel better after a normal mushroom,
         "   "   "   "   dead     "   " poison    "
         "   "   "  go berserk    "   " magic     "

        Simon Travaglia, Waikato University 1985
        }

CONST        linefeed        = chr(10);
        ctrl_z                = chr(26);
        esc                = chr(27);
        magic_mushroom        = 42;
        poison_mushroom        = 45;
        mushroom_char        = 94;

TYPE        screenline        = varying [127] of char;

VAR
        infile        : text;
        berserk        : boolean;
        x_pos        : integer;
        y_pos        : integer;
        lives        : integer;                {not used}
        score        : integer;
        x_move        : integer;
        y_move        : integer;
        screen        : packed array [1..23, 1..40] of integer;
        dummy        : integer;
        dummy_2        : integer;
        sleep_time        : integer;
        mushy_char        : char;
        char_input        : integer;
        mushy_x_pos        : integer;
        mushy_y_pos        : integer;
        old_x_pos        : integer;
        old_y_pos        : integer;
        total_mushrooms        : integer;
        dead_meat        : boolean;
        game_over        : boolean;
        current_obj        : integer;
        berserk_time        : integer;
        max_berserk_time        : integer;
        game_start_screen        : screenline;


procedure write_score;
        begin;
        writeln( esc, 'Y  ', score:1, esc, '  ');
        end;

procedure beep;
        begin
        writeln( chr(7) );
        end;

procedure put_mushy;
        begin
        writeln( esc,'Y',chr(mushy_x_pos+31),chr(mushy_y_pos+31),mushy_char
                        , esc, 'Y  ');
                                        {place mushroom then home cursor,
                                        otherwise the region could scroll }

        screen[mushy_x_pos, mushy_y_pos] := ord(mushy_char);
        end;

procedure make_mushies;
        BEGIN
                mushy_char := '^';
                for dummy := 1 to 40 do
                begin
                mushy_x_pos := RANDOM(23);
                mushy_y_pos := RANDOM(40);
                if screen[mushy_x_pos, mushy_y_pos] = 32 then
                        put_mushy;
                end;

                mushy_char := '*';
                for dummy := 1 to 5 do
                begin
                mushy_x_pos := RANDOM(23);
                mushy_y_pos := RANDOM(40);
                if screen[mushy_x_pos, mushy_y_pos] = 32 then
                        put_mushy;
                end;

                mushy_char := '-';
                for dummy := 1 to 5 do
                begin
                mushy_x_pos := RANDOM(23);
                mushy_y_pos := RANDOM(40);
                if screen[mushy_x_pos, mushy_y_pos] = 32 then
                        put_mushy;
                end;

                max_berserk_time := max_berserk_time + 2;  
                                {the effects last longer !!!}
        END;

procedure init_game;
        begin
                FOR dummy := 1 to 23 do
                        FOR dummy_2 := 1 to 40 do
                        screen[dummy, dummy_2] := 32;

        max_berserk_time := 15;                {15 berserk_moves}
        x_pos        := 12;
        y_pos        := 20;
        lives        := 1;
        sleep_time        := 1000000;        {set up 1 sec sleep between move}
        show_graphedt ('mushroom.scn');
        show_graphedt ('mushroom.sc2',wait:=false);
        write (esc+'[?2l');
        make_mushies;                        {place mushrooms}
        total_mushrooms := 30;                {set number to be less...}
        end;

procedure check_mushrooms;
        Begin
          if total_mushrooms < 6 then 
                begin
                make_mushies;
                sleep_time := sleep_time - 4000;        {make it interesting}
                total_mushrooms := 46;
                end;
        end;

procedure get_input;
        BEGIN
        char_input := ord(qio_1_char_now);
        END;

Procedure do_nothing;
        begin;
        {self explanitary, it does nothing}
        end;

Procedure go_berserk;
        begin;
        char_input := random(4);                {some random number}
        char_input := 48 + (char_input * 2);        {simulate a key stroke}
        berserk_time := berserk_time - 1;
        if berserk_time < 10 then berserk := false;
        end;


Procedure What_am_i_on;
        BEGIN;
        current_obj        := screen[x_pos, y_pos];
        screen[x_pos, y_pos] := 32;
        
        CASE current_obj of
                42        : BEGIN
                                        score := score + 20;
                                        write_score;
                                        total_mushrooms := total_mushrooms - 2;
                                        check_mushrooms;
                                        berserk := true;
                                        berserk_time := max_berserk_time;
                          END;

                94        : BEGIN
                                        score := score + 10;
                                        write_score;
                                        total_mushrooms := total_mushrooms - 1;
                                        check_mushrooms;
                          END;

                45        : dead_meat := true;

                32        :        do_nothing;

                OTHERWISE
                begin
                beep;
                beep;
                Writeln( 'Game consistancy failure.');
                Writeln( 'Position X=',x_pos,' Y=',y_pos,'  Character=',current_obj);
                game_over := true;
                end;
                End;
        END;

procedure place_man;
        BEGIN
        writeln( esc, 'Y', chr(old_x_pos+31), chr(old_y_pos+31), ' ');
        writeln( esc, 'Y', chr(x_pos+31), chr(y_pos+31), '@');
        what_am_i_on;
        END;

procedure lite_man;
          BEGIN
        writeln( esc, 'Y', chr(x_pos+31), chr(y_pos+31), '*');
        writeln( esc, 'Y', chr(x_pos+31), chr(y_pos+31), '@');
        writeln( esc, 'Y', chr(x_pos+31), chr(y_pos+31), '*');
        END;

procedure move_man;
        BEGIN
        case char_input of
        81,113,26,69,101 : begin
                          dead_meat := true;
                          game_over := true;
                          end;

                50        : begin
                          x_move := 1;
                          y_move := 0;
                          end;

                52        : begin
                          y_move := -1;
                          x_move := 0;
                          end;

                54        : begin
                          y_move := 1;
                          x_move := 0;
                          end;

                56        : begin
                          x_move := -1;
                          y_move := 0;
                          end;
        otherwise;
        end;

        old_x_pos := x_pos;
        old_y_pos := y_pos;
        x_pos := x_pos + x_move;
        y_pos := y_pos + y_move;
        if y_pos > 40 then y_pos := 1;
        if y_pos < 1 then y_pos := 40;
        if x_pos > 23 then x_pos := 1;
        if x_pos < 1 then x_pos := 23;
        place_man;
        END;



BEGIN        {main game}
        image_dir;
        INIT_GAME;
        beep;
                While (not game_over) and (lives > 0) do 
                        BEGIN;
                        while not dead_meat do
                                BEGIN;
                                if berserk then go_berserk
                                else Get_input;
                                move_man;
                                sleep( 0, sleep_time / 10000000 );
                                END;
                        lives := lives - 1;
                        beep;
                        END;
        top_ten( score);
END.
