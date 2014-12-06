[psect(misc2$code)] procedure ident_char;
    var
        command         : char;
    begin
      if (get_com('Enter character to be identified :',command)) then
        case command of
          ' ' : prt('  - An open pit.',1,1);
          '!' : prt('! - A potion.',1,1);
          '"' : prt('" - An amulet, periapt, or necklace.',1,1);
          '#' : prt('# - A stone wall.',1,1);
          '$' : prt('$ - Treasure.',1,1);
         {'%' : prt('% - Not used.',1,1);}
          '&' : prt('& - Treasure chest.',1,1);
          '''': prt(''' - An open door.',1,1);
          '(' : prt('( - Soft armor.',1,1);
          ')' : prt(') - A shield.',1,1);
          '*' : prt('* - Gems.',1,1); 
          '+' : prt('+ - A closed door.',1,1);
          ',' : prt(', - Food.',1,1);
          '-' : prt('- - A wand',1,1);
          '.' : prt('. - Floor.',1,1);
          '/' : prt('/ - A pole weapon.',1,1);
         {'0' : prt('0 - Not used.',1,1);}
          '1' : prt('1 - Entrance to General Store.',1,1);
          '2' : prt('2 - Entrance to Armory.',1,1);
          '3' : prt('3 - Entrance to Weaponsmith.',1,1);
          '4' : prt('4 - Entrance to Temple.',1,1);
          '5' : prt('5 - Entrance to Alchemy shop.',1,1);
          '6' : prt('6 - Entrance to Magic-Users store.',1,1);
          '7' : prt('7 - Entrance to Black Market.',1,1);
         {'8' : prt('8 - Not used.',1,1);}
         {'9' : prt('9 - Not used.',1,1);}
          ':' : prt(': - Rubble.',1,1);
          ';' : prt('; - A loose rock.',1,1);
          '<' : prt('< - An up staircase.',1,1);
          '=' : prt('= - A ring.',1,1);
          '>' : prt('> - A down staircase.',1,1);
          '?' : prt('? - A scroll.',1,1);
          '@' : prt(py.misc.name,1,1);
          'A' : prt('A - Ant Lion.',1,1);
          'B' : prt('B - Beetle.',1,1);
          'C' : prt('C - Gelatanious Cube.',1,1);
          'D' : prt('D - The Balrog (a Demon).',1,1);
          'E' : prt('E - Elemental.',1,1);
          'F' : prt('F - Mind Flayer or Fly.',1,1);
          'G' : prt('G - Ghost.',1,1);
          'H' : prt('H - Hell Hound or Hell Horse.',1,1);
          'I' : prt('I - Invisible Stalker.',1,1);
          'J' : prt('J - Jelly.',1,1);
         {'K' : prt('K - Not used.',1,1);}
          'L' : prt('L - Lamia or Lich.',1,1);
          'M' : prt('M - Manticore, Minotaur, or Mummy.',1,1);
         {'N' : prt('N - Not used.',1,1);}
          'O' : prt('O - Ooze.',1,1);
          'P' : prt('P - Giant humanoid.',1,1);
         {'Q' : prt('Q - Not used.',1,1);}
          'R' : prt('R - Roper or Reptile.',1,1);
          'S' : prt('S - Giant Scorpion.',1,1);
          'T' : prt('T - Troll.',1,1);
          'U' : prt('U - Umber Hulk.',1,1);
          'V' : prt('V - Vampire.',1,1);
          'W' : prt('W - Wight or Wraith.',1,1);
          'X' : prt('X - Xorn.',1,1);
          'Y' : prt('Y - Yeth Hound.',1,1);
         {'Z' : prt('Z - Not used.',1,1);}
          '[' : prt('[ - Hard armor.',1,1);
          '\' : prt('\ - A hafted weapon.',1,1);
          ']' : prt('] - Misc. armor.',1,1);
          '^' : prt('^ - A trap.',1,1);
          '_' : prt('_ - A staff.',1,1);
         {'`' : prt('` - Not used.',1,1);}
          'a' : prt('a - Ant.',1,1);
          'b' : prt('b - Bat or Cockatrice.',1,1);
          'c' : prt('c - Centipede.',1,1);
          'd' : prt('d - Dragon.',1,1);
          'e' : prt('e - Floating Eye.',1,1);
          'f' : prt('f - Frog',1,1);
          'g' : prt('g - Gargoyle or Golem.',1,1);
          'h' : prt('h - Harpy.',1,1);
          'i' : prt('i - Icky Thing.',1,1);
          'j' : prt('j - Jackal.',1,1);
          'k' : prt('k - Kobold.',1,1);
          'l' : prt('l - Lice.',1,1);
          'm' : prt('m - Mold or Mushroom.',1,1);
          'n' : prt('n - Naga.',1,1);
          'o' : prt('o - Orc, Ogre, or Hobgoblin.',1,1);
          'p' : prt('p - Person (Humanoid).',1,1);
          'q' : prt('q - Quasit.',1,1);
          'r' : prt('r - Rodent.',1,1);
          's' : prt('s - Skeleton.',1,1);
          't' : prt('t - Tick.',1,1);
         {'u' : prt('u - Not used.',1,1);}
          'v' : prt('v - Vargouille.',1,1);
          'w' : prt('w - Worm(s).',1,1);
         {'x' : prt('x - Not used.',1,1);}
          'y' : prt('y - Yeek.',1,1);
          'z' : prt('z - Zombie.',1,1);
          '{' : prt('{ - Arrow, bolt, or bullet.',1,1);
          '|' : prt('| - A sword or dagger.',1,1);
          '}' : prt('} - Bow, crossbow, or sling.',1,1);
          '~' : prt('~ - Miscellaneous item.',1,1);
          otherwise prt('Not Used.',1,1);
        end
    end;
 
 
        { Help for available commands                                   }
[psect(misc2$code)] procedure help;
    begin
      clear(1,1);
prt('B <Dir> Bash (object/creature)|  q        Quaff a potion.',1,1);
prt('C       Display character.    |  r        Read a scroll.',2,1);
prt('D <Dir> Disarm a trap/chest.  |  s        Search for hidden doors.',3,1);
prt('E       Eat some food.        |  t        Take off an item.',4,1);
prt('F       Fill lamp with oil.   |  u        Use a staff.',5,1);
prt('L       Current location.     |  v        Version and credits.',6,1);
prt('P       Print map.            |  w        Wear/Wield an item.',7,1);
prt('R       Rest for a period.    |  x        Exchange weapon.',8,1);
prt('S       Search Mode.          |  /        Identify a character.',9,1);
prt('T <Dir> Tunnel.               |  ?        Display this panel.',10,1);
prt('a       Aim and fire a wand.  |  \        Retreive info on a creature.',
   11,1);
prt('b       Browse a book.        |',12,1);
prt('c <Dir> Close a door.         |  ^M       Repeat the last message.',13,1);
prt('d       Drop an item.         |  ^R       Redraw the screen.',14,1);
prt('e       Equipment list.       |  ^Y       Quit the game.',15,1);
prt('f       Fire/Throw an item.   |  ^Z       Save character and quit.',16,1);
prt('h       Help on key commands. |',17,1);
prt('i       Inventory list.       |  < Go up an up-staircase.',18,1);
prt('j <Dir> Jam a door with spike.|  > Go down a down-staircase.',19,1);
prt('l <Dir> Look given direction. |  . <Dir>  Move in direction.',20,1);
prt('m       Cast a magic spell.   |  Movement: 7  8  9',21,1);
prt('o <Dir> Open a door/chest.    |            4     6    5 = Rest',22,1);
prt('p       Read a prayer.        |            1  2  3',23,1);
      pause(24);
      draw_cave;
    end;
 

{Displays the list of all the monsters -NBT}
[psect(misc2$code)] procedure do_all_mons;

Begin
   Clear(1,1);
prt(' Note: A "*" in front of the symbol denotes that more than one',3,1);
prt('       type of creature uses that symbol.',4,1);
prt('*$ Coins                   *a Ant                      *b Bat, Cockatrice',6,1);
prt('*c Centipede(s)            *d Dragon                   *e Eye ',7,1);
prt('*f Frog                    *g Gargoyle, Golem          *h Harpy',8,1);
prt('*i Icky thing               j Jackal                    k Kobold',9,1);
prt('*l Louse                   *m Mold, Mushroom           *n Naga',10,1);
prt('*o Orc, Ogre, Hobgoblin    *p Humanoid                  q Quasit',11,1);
prt('*r Rodent                  *s Skeleton                 *t Tick',12,1);
prt(' v Vargouille              *w Worm(s)                  *y Yeek',13,1);
prt('*z Zombie                  *| Evil Sword               *A Ant Lion',14,1);
prt('*B Beetle                   C Gelatainous Cube          D The Balrog',15,1);
prt('*E Elemental               *F Fly, Mind Flayer         *G Ghost',16,1);
prt('*H Hell Hound, Hell Horse   I Invisible Stalker        *J Jelly',17,1);
prt('*L Lich, Lamia             *M Manticore, Mummy, Minotaur',18,1);
prt('*O Ooze                    *P Giant Humanoid           *R Roper, Reptile',19,1);
prt('*S Giant Scorpion          *T Troll                     U Umber Hulk',20,1);
prt('*V Vampire                 *W Wight or Wraith           X Xorn',21,1);
prt(' Y Yeth Hound',22,1);
   End;

{Displays a particular monster's "character sheet" -NBT}
[psect(misc2$code)] procedure do_mon_out (moncode : integer);

Var nbt_out_val, attstr, attx : vtype;
    cur_line, xpos, atype, adesc,i : integer;
    damstr : dtype;

BEGIN
   clear (1,1);
   with c_list[moncode] do
   BEGIN
      prt (name,1,1);
      prt ('Screen Code:',1,60);
      prt (cchar,1,72);
      prt_num ('Speed =',speed,2,3);
      prt_num ('Level =',level,2,13);
      prt_num ('Exp =',mexp,2,24);
      prt_num ('AC =',ac,2,36);
      prt_num ('Eye-sight =',aaf,2,44);
      nbt_out_val := 'HD = ' + hd;
      prt (nbt_out_val,2,58);
      cur_line := 5;
      if (uand(%X'80000000',cmove) <> 0) then
        begin
         cur_line := 7;
         prt ('This creature is a ***Win Creature***',3,20);
        end;
      if (uand(%X'00080000',cmove) <> 0) then
        begin
         prt('Creature eats/kills other creatures.',((cur_line + 1) div 2),
            (41 - 40*(cur_line mod 2)));
         cur_line := cur_line + 1;
        end;
      if (uand(%X'0001',cdefense) <> 0) then
        begin
         prt('Creature is a dragon.',((cur_line + 1) div 2),
            (41 - 40*(cur_line mod 2)));
         cur_line := cur_line + 1;
        end;
      if (uand(%X'0002',cdefense) <> 0) then
        begin
         prt('Creature is a monster.',((cur_line + 1) div 2),
            (41 - 40*(cur_line mod 2)));
         cur_line := cur_line + 1;
        end;
      if (uand(%X'0004',cdefense) <> 0) then
        begin
         prt('Creature is evil.',((cur_line + 1) div 2),(41 - 40*(cur_line mod 2)));
         cur_line := cur_line + 1;
        end;
      if (uand(%X'0008',cdefense) <> 0) then
        begin
         prt('Creature is undead.',((cur_line + 1) div 2),(41 - 40*(cur_line mod 2)));
         cur_line := cur_line + 1;
        end;
      if (uand(%X'0010',cdefense) <> 0) then
        begin
         prt('Creature harmed by cold.',((cur_line + 1) div 2),
             (41 - 40*(cur_line mod 2)));
         cur_line := cur_line + 1;
        end;
      if (uand(%X'0020',cdefense) <> 0) then
        begin
         prt('Creature harmed by fire.',((cur_line + 1) div 2),
            (41 - 40*(cur_line mod 2)));
         cur_line := cur_line + 1;
        end;
      if (uand(%X'0040',cdefense) <> 0) then
        begin
         prt('Creature harmed by poison.',((cur_line + 1) div 2),
            (41 - 40*(cur_line mod 2)));
         cur_line := cur_line + 1;
        end;
      if (uand(%X'0080',cdefense) <> 0) then
        begin
         prt('Creature harmed by acid.',((cur_line + 1) div 2),
            (41 - 40*(cur_line mod 2)));
         cur_line := cur_line + 1;
        end;
      if (uand(%X'0100',cdefense) <> 0) then
        begin
         prt('Creature harmed by blue light.',((cur_line + 1) div 2),
            (41 - 40*(cur_line mod 2)));
         cur_line := cur_line + 1;
        end;
      if (uand(%X'0200',cdefense) <> 0) then
        begin
         prt('Creature harmed by stone-to-mud.',((cur_line + 1) div 2),
            (41 - 40*(cur_line mod 2)));
         cur_line := cur_line + 1;
        end;
      if (uand(%X'1000',cdefense) <> 0) then
        begin
         prt('Creature can''t be charmed/slept.',((cur_line + 1) div 2),
             (41 - 40*(cur_line mod 2)));
         cur_line := cur_line + 1;
        end;
      if (uand(%X'2000',cdefense) <> 0) then
        begin
         prt('Creature seen with Infra-Vision.',((cur_line + 1) div 2),
            (41 - 40*(cur_line mod 2)));
         cur_line := cur_line + 1;
        end;
      if (uand(%X'4000',cdefense) <> 0) then
        begin
         prt('hit points',2,69);
         prt('Creature has MAX hit points',((cur_line + 1) div 2),
            (41 - 40*(cur_line mod 2)));
         cur_line := cur_line + 1;
        end;
      if (cur_line mod 2) = 0 then cur_line := cur_line + 1;
      if (uand(%X'00010000',cmove) <> 0) then
        begin
         prt('Creature is invisible.',((cur_line + 1) div 2),
            (41 - 40*(cur_line mod 2)));
         cur_line := cur_line + 1;
        end;
      if (uand(%X'00100000',cmove) <> 0) then
        begin
         prt('Creature picks up objects.',((cur_line + 1) div 2),
            (41 - 40*(cur_line mod 2)));
         cur_line := cur_line + 1;
        end;
      if (uand(%X'00200000',cmove) <> 0) then
        begin
         prt('Creature multiplies.',((cur_line + 1) div 2),(41 - 40*(cur_line mod 2)));
         cur_line := cur_line + 1;
        end;
      if (uand(%X'01000000',cmove) <> 0) then
        begin
         prt('Creature carries objects.',((cur_line + 1) div 2),
            (41 - 40*(cur_line mod 2)));
         cur_line := cur_line + 1;
        end;
      if (uand(%X'02000000',cmove) <> 0) then
        begin
         prt('Creature carries gold, gems, etc.',((cur_line + 1) div 2),
            (41 - 40*(cur_line mod 2)));
         cur_line := cur_line + 1;
        end;
      if (uand(%X'04000000',cmove) <> 0) then
        begin
         prt('Has object/gold 60% of time.',((cur_line + 1) div 2),
            (41 - 40*(cur_line mod 2)));
         cur_line := cur_line + 1;
        end;
      if (uand(%X'08000000',cmove) <> 0) then
        begin
         prt('Has object/gold 90% of time.',((cur_line + 1) div 2),
            (41 - 40*(cur_line mod 2)));
         cur_line := cur_line + 1;
        end;
      if (uand(%X'10000000',cmove) <> 0) then
        begin
         prt('Has 1d2 object(s)/gold.',((cur_line + 1) div 2),
            (41 - 40*(cur_line mod 2)));
         cur_line := cur_line + 1;
        end;
      if (uand(%X'20000000',cmove) <> 0) then
        begin
         prt('Has 2d2 object(s)/gold.',((cur_line + 1) div 2),
            (41 - 40*(cur_line mod 2)));
         cur_line := cur_line + 1;
       end;
      if (uand(%X'40000000',cmove) <> 0) then
        begin
         prt('Has 4d2 object(s)/gold.',((cur_line + 1) div 2),
            (41 - 40*(cur_line mod 2)));
         cur_line := cur_line + 1;
       end;
      if (cur_line mod 2) = 0 then cur_line := cur_line + 1;
      prt('-- Spells / Dragon Breath:',((cur_line + 1) div 2),1);
      cur_line := cur_line + 2;
      nbt_out_val := '    Casts spells 1 out of every   turns.';
      prt(nbt_out_val,((cur_line + 1) div 2),1);
      prt_num('',int(uand(%X'F',spells)),((cur_line + 1) div 2),33);
      cur_line := cur_line + 2;
      if (uand(%X'00000010',spells) <> 0) then
        begin
         prt('Can teleport short.',((cur_line + 1) div 2),
            (41 - 40*(cur_line mod 2)));
         cur_line := cur_line + 1;
        end;
      if (uand(%X'00000020',spells) <> 0) then
        begin
         prt('Can teleport long.',((cur_line + 1) div 2),
            (41 - 40*(cur_line mod 2)));
         cur_line := cur_line + 1;
        end;
      if (uand(%X'00000040',spells) <> 0) then
        begin
         prt('Teleport player to itself.',((cur_line + 1) div 2),
            (41 - 40*(cur_line mod 2)));
         cur_line := cur_line + 1;
        end;
      if (uand(%X'00000080',spells) <> 0) then
        begin
         prt('Cause light wounds.',((cur_line + 1) div 2),
            (41 - 40*(cur_line mod 2)));
         cur_line := cur_line + 1;
        end;
      if (uand(%X'00000100',spells) <> 0) then
        begin
         prt('Cause serious wounds.',((cur_line + 1) div 2),
            (41 - 40*(cur_line mod 2)));
         cur_line := cur_line + 1;
        end;
      if (uand(%X'00000200',spells) <> 0) then
        begin
         prt('Hold person.',((cur_line + 1) div 2),
            (41 - 40*(cur_line mod 2)));
         cur_line := cur_line + 1;
        end;
      if (uand(%X'00000400',spells) <> 0) then
        begin
         prt('Cause blindness.',((cur_line + 1) div 2),
            (41 - 40*(cur_line mod 2)));
         cur_line := cur_line + 1;
        end;
      if (uand(%X'00000800',spells) <> 0) then
        begin
         prt('Cause confusion.',((cur_line + 1) div 2),
            (41 - 40*(cur_line mod 2)));
         cur_line := cur_line + 1;
        end;
      if (uand(%X'00001000',spells) <> 0) then
        begin
         prt('Cause fear.',((cur_line + 1) div 2),
            (41 - 40*(cur_line mod 2)));
         cur_line := cur_line + 1;
        end;
      if (uand(%X'00002000',spells) <> 0) then
        begin
         prt('Summon a monster.',((cur_line + 1) div 2),
            (41 - 40*(cur_line mod 2)));
         cur_line := cur_line + 1;
        end;
      if (uand(%X'00004000',spells) <> 0) then
        begin
         prt('Summon an undead.',((cur_line + 1) div 2),
            (41 - 40*(cur_line mod 2)));
         cur_line := cur_line + 1;
        end;
      if (uand(%X'00008000',spells) <> 0) then
        begin
         prt('Slow person.',((cur_line + 1) div 2),
            (41 - 40*(cur_line mod 2)));
         cur_line := cur_line + 1;
        end;
      if (uand(%X'00010000',spells) <> 0) then
        begin
         prt('Drains mana for healing.',((cur_line + 1) div 2),
            (41 - 40*(cur_line mod 2)));
         cur_line := cur_line + 1;
        end;
      if (uand(%X'00020000',spells) <> 0) then
        begin
         prt('**Unknown spell value**',((cur_line + 1) div 2),
            (41 - 40*(cur_line mod 2)));
         cur_line := cur_line + 1;
        end;
      if (uand(%X'00040000',spells) <> 0) then
        begin
         prt('**Unknown spell value**',((cur_line + 1) div 2),
            (41 - 40*(cur_line mod 2)));
         cur_line := cur_line + 1;
        end;
      if (uand(%X'00080000',spells) <> 0) then
        begin
         prt('Breathes Lightning Dragon Breath.',((cur_line + 1) div 2),
            (41 - 40*(cur_line mod 2)));
         cur_line := cur_line + 1;
        end;
      if (uand(%X'00100000',spells) <> 0) then
        begin
         prt('Breathes Gas Dragon Breath.',((cur_line + 1) div 2),
            (41 - 40*(cur_line mod 2)));
         cur_line := cur_line + 1;
        end;
      if (uand(%X'00200000',spells) <> 0) then
        begin
         prt('Breathes Acid Dragon Breath.',((cur_line + 1) div 2),
            (41 - 40*(cur_line mod 2)));
         cur_line := cur_line + 1;
        end;
      if (uand(%X'00400000',spells) <> 0) then
        begin
         prt('Breathes Frost Dragon Breath.',((cur_line + 1) div 2),
            (41 - 40*(cur_line mod 2)));
         cur_line := cur_line + 1;
        end;
      if (uand(%X'00800000',spells) <> 0) then
        begin
         prt('Breathes Fire Dragon Breath.',((cur_line + 1) div 2),
            (41 - 40*(cur_line mod 2)));
         cur_line := cur_line + 1;
        end;
      if (cur_line mod 2) = 0 then cur_line := cur_line + 1;
      prt('-- Movement:',((cur_line + 1) div 2),1);
      cur_line := cur_line + 2;
      if (uand(%X'00000001',cmove) <> 0) then
        begin
         prt('Moves only to attack.',((cur_line + 1) div 2),
            (41 - 40*(cur_line mod 2)));
         cur_line := cur_line + 1;
        end;
      if (uand(%X'00000002',cmove) <> 0) then
        begin
         prt('Moves and attacks normally.',((cur_line + 1) div 2),
            (41 - 40*(cur_line mod 2)));
         cur_line := cur_line + 1;
        end;
      if (uand(%X'00000008',cmove) <> 0) then
        begin
         prt('20% random movement.',((cur_line + 1) div 2),
            (41 - 40*(cur_line mod 2)));
         cur_line := cur_line + 1;
        end;
      if (uand(%X'00000010',cmove) <> 0) then
        begin
         prt('40% random movement.',((cur_line + 1) div 2),
            (41 - 40*(cur_line mod 2)));
         cur_line := cur_line + 1;
        end;
      if (uand(%X'00000020',cmove) <> 0) then
        begin
         prt('75% random movement.',((cur_line + 1) div 2),
            (41 - 40*(cur_line mod 2)));
         cur_line := cur_line + 1;
        end;
      if (uand(%X'00020000',cmove) <> 0) then
        begin
         prt('Can open doors.',((cur_line + 1) div 2),
            (41 - 40*(cur_line mod 2)));
         cur_line := cur_line + 1;
        end;
      if (uand(%X'00040000',cmove) <> 0) then
        begin
         prt('Can phase through walls.',((cur_line + 1) div 2),
            (41 - 40*(cur_line mod 2)));
         cur_line := cur_line + 1;
        end;
      if (cur_line mod 2) = 0 then cur_line := cur_line + 1;
     prt('-- Creature attacks:',((cur_line + 1) div 2),1);
     cur_line := cur_line + 2;
     attstr := damage;
     while (length(attstr) > 0) do
       begin
        xpos := index(attstr,'|');
        if (xpos > 0) then
          begin
           attx := substr(attstr,1,xpos-1);
           attstr := substr(attstr,xpos+1,length(attstr)-xpos);
          end
        else
          begin
           attx := attstr;
           attstr := '';
          end;
        readv(attx,atype,adesc,damstr);
        nbt_out_val := '';
    CASE adesc of
        1 :  nbt_out_val := '       Hits for ';
        2 :  nbt_out_val := '       Bites for ';
        3 :  nbt_out_val := '       Claws for ';
        4 :  nbt_out_val := '       Stings for ';
        5 :  nbt_out_val := '       Touches for ';
        6 :  nbt_out_val := '       Kicks for ';
        7 :  nbt_out_val := '       Gazes for ';
        8 :  nbt_out_val := '       Breathes for ';
        9 :  nbt_out_val := '       Spits for ';
        10:  nbt_out_val := '       Wails for ';
        11:  nbt_out_val := '       Embraces for ';
        12:  nbt_out_val := '       Crawls on you for ';
        13:  nbt_out_val := '       Shoots spores for ';
        14:  nbt_out_val := '       Begs for money for ';
        15:  nbt_out_val := '       Slimes you for ';
        16:  nbt_out_val := '       Crushes you for ';
        17:  nbt_out_val := '       Tramples you for ';
        18:  nbt_out_val := '       Drools on you for ';
	19:  nbt_out_val := '       "Iggy attacks" you for ';
	20:  nbt_out_val := '       Touches you with its tentacles for ';
        99:  nbt_out_val := '       Is repelled...';
        otherwise nbt_out_val := '     **Unknown description** ';
    END;
    CASE atype of
{Normal attack  }     1  : nbt_out_val := nbt_out_val + 'normal damage.';
{Poison Strength}     2  : nbt_out_val := nbt_out_val + 'lowering strength.';
{Confusion attack}    3  : nbt_out_val := nbt_out_val + 'confusion.';
{Fear attack    }     4  : nbt_out_val := nbt_out_val + 'fear.';
{Fire attack    }     5  : nbt_out_val := nbt_out_val + 'fire damage.';
{Acid attack    }     6  : nbt_out_val := nbt_out_val + 'acid damage.';
{Cold attack    }     7  : nbt_out_val := nbt_out_val + 'cold damage.';
{Lightning attack}    8  : nbt_out_val := nbt_out_val + 'lightning damage.';
{Corrosion attack}    9  : nbt_out_val := nbt_out_val + 'corrosion damage.';
{Blindness attack}    10 : nbt_out_val := nbt_out_val + 'blindness.';
{Paralysis attack}    11 : nbt_out_val := nbt_out_val + 'paralyzation.';
{Steal Money    }     12 : nbt_out_val := nbt_out_val + 'stealing money.';
{Steal Object   }     13 : nbt_out_val := nbt_out_val + 'stealing object.';
{Poison         }     14 : nbt_out_val := nbt_out_val + 'poison damage.';
{Lose Dex       }     15 : nbt_out_val := nbt_out_val + 'lose dexterity.';
{Lose Con       }     16 : nbt_out_val := nbt_out_val + 'lose constitution.';
{Lose Int       }     17 : nbt_out_val := nbt_out_val + 'lose intelligence.';
{Lose Wis       }     18 : nbt_out_val := nbt_out_val + 'lose wisdom.';
{Lose Exp       }     19 : nbt_out_val := nbt_out_val + 'lose experience.';
{Aggravation    }     20 : nbt_out_val := nbt_out_val + 'aggravates monsters.';
{Disenchant     }     21 : nbt_out_val := nbt_out_val + 'disenchants objects.';
{Eats food      }     22 : nbt_out_val := nbt_out_val + 'eating food.';
{Eats light     }     23 : nbt_out_val := nbt_out_val + 'eating light source.';
{Eats charges   }     24 : nbt_out_val := nbt_out_val + 'absorbing charges.';
{Vampire Bite   }     25 : nbt_out_val := nbt_out_val +
 'losing strength and experience';
{Turn to Stone  }     26 : nbt_out_val := nbt_out_val + 'turning to stone.';
{Mind Flayer    }     27 : nbt_out_val := nbt_out_val + 'sucking your brain out.';
{Hell Horse	}     28 : nbt_out_val := nbt_out_val + 'NightMare blindness.';
{Vargouille	}     29 : nbt_out_val := nbt_out_val + 'draining max hit points.';
{ Special       }     99 : nbt_out_val := nbt_out_val + 'blank message.';
                      otherwise nbt_out_val := nbt_out_val + '**Unknown value**';
   end;
   nbt_out_val := nbt_out_val + ' (' + damstr + ')';
   prt(nbt_out_val,((cur_line + 1) div 2),1);
   cur_line := cur_line + 2;
  end;
end;
pause(24);
Draw_cave;
end;

{Displays info about monsters -NBT}
[psect(misc2$code)] procedure mon_info;

Var choice : char;
    quitflag : boolean;
    howmany,i,j,moncode,aux_code : integer;
    namestr,dummy : vtype;

Begin
   choice := ' ';
   quitflag := true;
   Repeat
      if (get_com
('Enter creature code for information, ? for the list, or <Esc> to abort: '
         ,choice)) then
        begin
         quitflag := false;
         if choice = '?' then do_all_mons;
        end;
   Until ((choice <> '?') or quitflag);
   If not(quitflag) then
   Begin
      clear (1,1);
      howmany := 0;
      for i := 1 to max_creatures do
         if c_list[i].cchar = choice then howmany := howmany + 1;
      if howmany = 0 then
        Begin
         prt ('That character is not used for any creatures.',12,1);
         pause (24);
	 draw_cave;
        end
       else
        if howmany = 1 then
          begin
             for i := 1 to max_creatures do
                if c_list[i].cchar = choice then moncode := i;
             do_mon_out(moncode);
          end
        else
          begin { there's more than one creature in the list using that code }
	     howmany := 0;
	     j := 1;
	     for i := 1 to max_creatures do
	       if c_list[i].cchar = choice then
 		begin
                   namestr := '';
		   namestr := '    ' + c_list[i].name +
                           '                       ';
		   prt(namestr,(4+(howmany div 2)),(1+(40*(howmany mod 2))));
		   prt_num ( '',j,(4+(howmany div 2)),(1+40*(howmany mod 2)));
		   howmany := howmany + 1;
		   j := j + 1;
		end;
	     Repeat
		erase_line(msg_line,msg_line);
		msg_print('Enter the number for your choice:');
		get_string(dummy,1,36,10);
		aux_code := 999;
		readv(dummy,aux_code,error:=continue);
	     Until ((aux_code > 0) and (aux_code <= howmany));
	     howmany := 0;
	     i := 0;
	     while howmany <> aux_code do
               Begin
		i := i + 1;
		if c_list[i].cchar = choice then howmany := howmany + 1;
	       end;
	     moncode := i;
	     do_mon_out(moncode);
	  end;
   end;
end;


{Help for available wizard commands}
[psect(wizard$code)] procedure wizard_help;
    begin
      clear(1,1);
          prt('^A - Remove Curse and Cure all maladies.',1,1);
          prt('^B - Print random objects sample.',2,1);
          prt('^C - Make nice character.',3,1);
          prt('^D - Down/Up n levels.',4,1);
          prt('^E - Change character.',5,1);
          prt('^F - Delete monsters.',6,1);
          prt('^G - Allocate treasures.',7,1);
          prt('^H - Wizard Help.',8,1);
          prt('^I - Identify.',9,1);
          prt('^J - Gain experience.',10,1);
          prt('^K - Summon monster.',11,1);
          prt('^L - Wizard light.',12,1);
          prt('^N - Print monster dictionary.',13,1);
          prt('^P - Wizard password on/off.',14,1);
          prt('^T - Teleport player.',15,1);
          prt('^V - Restore lost character.',16,1);
          prt('^W - Create any object *CAN CAUSE FATAL ERROR*',17,1);
      pause(24);
      draw_cave;
    end;
 
 
 
{Spawn a process to use HELP utility on the MORIA help library -RAK-}
[psect(misc2$code)] procedure moria_help(help_level : vtype);
    var                         
        dcl_command                     : varying [120] of char;
        flag_bits                       : unsigned;
 
        { Spawn a shell and execute DCL command                 -RAK-   }
    [external(LIB$SPAWN)] function dcl(
        %DESCR command  : varying [a] of char;
            dum2        : integer := %immed 0;
            dum3        : integer := %immed 0;
        %REF flags      : unsigned;
            dum5        : integer := %immed 0;
            dum6        : integer := %immed 0;
            dum7        : integer := %immed 0;
            dum8        : integer := %immed 0;
            dum9        : integer := %immed 0;
            dum10       : integer := %immed 0 ) : integer;
        external;
 
    begin
      flag_bits := %X'00000006';
      prt('[Entering Moria Help Library, Use ^Z to resume game]',1,1);
      put_qio;
      dcl_command := 'HELP/PAGE/NOLIBLIST/LIBRARY='+MORIA_HLP;
      dcl_command := dcl_command + ' ' + help_level;
      dcl(dcl_command,flags:=flag_bits);
    end;



[psect(misc2$code)] procedure moria_help_lbr(help_level : vtype);
    [external(LBR$OUTPUT_HELP)] function output_help(
	%REF output_routine : unsigned;
	%REF output_width   : unsigned;
	%DESCR line_desc    : varying [a] of char;
	%DESCR library_name : varying [b] of char;
        %REF flags      : unsigned) : integer;
        external;
 
    begin
    end;



