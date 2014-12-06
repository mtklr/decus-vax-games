[Inherit('Moria.Env','Sys$Library:Starlet')] Module Help;

[asynchronous] function lib$get_input(
     var resultant_string:
     [class_s,volatile] packed array [$l1..$u1:integer] of char;
     prompt_string:
     [class_s] packed array [$l2..$u2:integer] of char := %immed 0;
     var resultant_length:
     [volatile] wordint := %immed 0):
integer; external;

[asynchronous] function lib$put_output(
     message_string:
     [class_s] packed array [$l1..$u1:integer] of char):
integer; external;

[external,asynchronous]
function lbr$output_help(
     %immed [unbound] function routine1: unsigned := %immed 0;
     length: integer := %immed 0;
     ifile,topic: [class_s] packed array [l3..u3:integer] of char;
     flags: array [l4..u4:integer] of integer;
     %immed [unbound] function routine2: unsigned := %immed 0):
unsigned; extern;

[global,psect(misc2$code)] procedure ident_char;
    var
	command			: char;
	exit_flag,bleah_flag	: boolean;
    begin
      repeat
	exit_flag := false;
	bleah_flag := true;
	msg_print('Identify letter for what environ? (<t>own, <d>ungeon, <w>ater) ');
	if (get_com('',command)) then
	  case command of
	    't','d','w' : exit_flag := true;
	  end
	else
	  begin
	    bleah_flag := false;
	    exit_flag := true;
	  end;
      until (exit_flag);
      if (bleah_flag) then
	case command of
	  't' : if (get_com('Enter character to be identified : ',command)) then
		  case command of
		    '#' : prt('# - A stone wall.',1,1);
		    '+' : prt('+ - Entrance to a building.',1,1);
		    '.' : prt('. - Ground.',1,1);
		    '>' : prt('> - A down staircase.',1,1);
		    '@' : prt(py.misc.name,1,1);
		    'p' : prt('p - A townsperson.',1,1);
		    'A' : prt('A - Alchemy Shop.',1,1);
		    'B' : prt('B - First Moria National Bank.',1,1);
		    'C' : prt('C - Casino.',1,1);
		    'D' : prt('D - All-Nite Deli',1,1);
		    'G' : prt('G - General Store.',1,1);
		    'I' : prt('I - Inn.',1,1);
		    'J' : prt('J - Gem and Jewelry Store.',1,1);
		    'L' : prt('L - Library.',1,1);
		    'M' : prt('M - Magic Shop.',1,1);
		    'N' : prt('N - Insurance Shop.',1,1);
		    'P' : prt('P - Trading Post.',1,1);
                    'Q' : prt('Q - Home of the Questor.',1,1);
		    'R' : prt('R - Armory.',1,1);
		    'T' : prt('T - Temple.',1,1);
		    'U' : prt('U - Music Shop.',1,1);
		    'W' : prt('W - Weapon Smith.',1,1);
		    'X' : prt('X - Money Exchange.',1,1);
		    otherwise prt('Not normally used.',1,1);
		  end;
	  'd' : if (get_com('Enter character to be identified : ',command)) then
		  case command of
		    ' ' : prt('  - An open pit.',1,1);
		    '!' : prt('! - A potion.',1,1);
		    '"' : prt('" - An amulet, periapt, or necklace.',1,1);
		    '#' : prt('# - A stone wall.',1,1);
		    '$' : prt('$ - Treasure.',1,1);
		    '%' : prt('% - A musical instrument or song book.',1,1);
		    '&' : prt('& - Treasure chest.',1,1);
		    '''': prt(''' - An open door.',1,1);
		    '(' : prt('( - Soft armor.',1,1);
		    ')' : prt(') - A shield.',1,1);
		    '*' : prt('* - Gems or Jewelry.',1,1);
		    '+' : prt('+ - A closed door.',1,1);
		    ',' : prt(', - Food or mushroom patch.',1,1);
		    '-' : prt('- - A wand',1,1);
		    '.' : prt('. - Floor.',1,1);
		    '/' : prt('/ - A pole weapon.',1,1);
		    ':' : prt(': - Rubble.',1,1);
		    ';' : prt('; - A loose rock.',1,1);
		    '<' : prt('< - An up staircase.',1,1);
		    '=' : prt('= - A ring.',1,1);
		    '>' : prt('> - A down staircase.',1,1);
		    '?' : prt('? - A scroll.',1,1);
		    '@' : prt(py.misc.name,1,1);
		    'A' : prt('A - Giant Ant Lion.',1,1);
		    'B' : prt('B - Demon.',1,1);
		    'C' : prt('C - Gelentanious Cube.',1,1);
		    'D' : prt('D - An Ancient Dragon (Beware).',1,1);
		    'E' : prt('E - Elemental.',1,1);
		    'F' : prt('F - Giant Fly or Faerie Dragon.',1,1);
		    'G' : prt('G - Ghost.',1,1);
		    'H' : prt('H - Hobgoblin.',1,1);
		    'J' : prt('J - Jelly.',1,1);
		    'K' : prt('K - Killer Beetle.',1,1);
		    'L' : prt('L - Lich.',1,1);
		    'M' : prt('M - Mummy.',1,1);
		    'N' : prt('N - Nymph',1,1);
		    'O' : prt('O - Ooze.',1,1);
		    'P' : prt('P - Giant humanoid.',1,1);
		    'Q' : prt('Q - Quylthulg (Pulsing Flesh Mound).',1,1);
		    'R' : prt('R - Reptile.',1,1);
		    'S' : prt('S - Giant Scorpion/Sandgorgon.',1,1);
		    'T' : prt('T - Troll.',1,1);
		    'U' : prt('U - Umber Hulk.',1,1);
		    'V' : prt('V - Vampire.',1,1);
		    'W' : prt('W - Wight or Wraith.',1,1);
		    'X' : prt('X - Xorn.',1,1);
		    'Y' : prt('Y - Yeti.',1,1);
		    'Z' : prt('Z - Nazgul',1,1);
		    '[' : prt('[ - Hard armor.',1,1);
		    '\' : prt('\ - A hafted weapon.',1,1);
		    ']' : prt('] - Misc. armor.',1,1);
		    '^' : prt('^ - A trap.',1,1);
		    '_' : prt('_ - A staff.',1,1);
		    '`' : prt('` - Water.',1,1);
		    'a' : prt('a - Amphibian.',1,1);
		    'b' : prt('b - Giant Bat.',1,1);
		    'c' : prt('c - Insect.',1,1);
		    'd' : prt('d - Dragon.',1,1);
		    'e' : prt('e - Floating Eye.',1,1);
		    'f' : prt('f - Fish.',1,1);
		    'g' : prt('g - Golem.',1,1);
		    'h' : prt('h - Harpy.',1,1);
		    'i' : prt('i - Icky Thing.',1,1);
		    'j' : prt('j - Canine.',1,1);
		    'k' : prt('k - Kobold.',1,1);
		    'l' : prt('l - Giant Lice.',1,1);
		    'm' : prt('m - Mold.',1,1);
		    'n' : prt('n - Naga.',1,1);
		    'o' : prt('o - Orc or Ogre.',1,1);
		    'p' : prt('p - Person (Humanoid).',1,1);
		    'q' : prt('q - Quasit.',1,1);
		    'r' : prt('r - Rodent.',1,1);
		    's' : prt('s - Skeleton.',1,1);
		    't' : prt('t - Giant tick.',1,1);
		    'v' : prt('v - Swirling Vapor.',1,1);
		    'w' : prt('w - Worm(s).',1,1);
		    'x' : prt('x - Spider.',1,1);
		    'y' : prt('y - Yeek.',1,1);
		    'z' : prt('z - Zombie.',1,1);
		    '{' : prt('{ - Arrow, bolt, or bullet.',1,1);
		    '|' : prt('| - A sword or dagger.',1,1);
		    '}' : prt('} - Bow, crossbow, or sling.',1,1);
		    '~' : prt('~ - Miscellaneous item.',1,1);
		    otherwise prt('Not Used.',1,1);
		  end;
	end
    end;


	{ Help for available commands					}
[global,psect(misc2$code)] procedure help;
    label
	bye,bye2,page2;
    var
	command	: char;
    begin
      inkey_delay(command,0);
      if (command <> null) then goto bye2;
      clear(1,1);
prt('A       Age of character.     |  h       Hurl an item.',1,1);
prt('B <Dir> Bash (object/creature)|  i       Inventory list.',2,1);
prt('C       Display character.    |  j <Dir> Jam a door with spike.',3,1);
inkey_delay(command,0); if (command <> null) then goto page2;
prt('D <Dir> Disarm a trap/chest.  |  l <Dir> Look given direction.',4,1);
prt('E       Eat some food.        |  m       Cast a magic spell.',5,1);
prt('F       Fill lamp with oil.   |  m       Use a music book.',6,1);
inkey_delay(command,0); if (command <> null) then goto page2;
prt('G       Game time and date    |  o <Dir> Open a door/chest.',7,1);
prt('H       Help                  |  p       Read a prayer.',8,1);
prt('I       Inven of one item type|  p       Play an instrument.',9,1);
inkey_delay(command,0); if (command <> null) then goto page2;
prt('L       Current location.     |  q       Quaff a potion.',10,1);
prt('M       Money.                |  r       Read a scroll.',11,1);
prt('P       Print map.            |  s       Search for hidden doors.',12,1);
inkey_delay(command,0); if (command <> null) then goto page2;
prt('R       Rest for a period.    |  t       Take off an item.',13,1);
prt('S       Search Mode.          |  u       Use a staff.',14,1);
prt('T <Dir> Tunnel.               |  v       Version and credits.',15,1);
inkey_delay(command,0); if (command <> null) then goto page2;
prt('U       Use miscellaneous item|  w       Wear/Wield an item.',16,1);
prt('W       Current time and date |  x       Exchange weapon.',17,1);
prt('a       Aim and fire a wand.  |  c <inv> Clean inventory.',18,1);
inkey_delay(command,0); if (command <> null) then goto page2;
prt('b       Browse a book.        |  $       Shell out of game.',19,1);
prt('c <Dir> Close a door.         |  +       Experience for levels.',20,1);
prt('d       Drop an item.         |  . <Dir> Move in direction.',21,1);
inkey_delay(command,0); if (command <> null) then goto page2;
prt('e       Equipment list.       |  /       Identify a character.',22,1);
prt('f       Fire Projectile.      |',23,1);

      pause(24);
page2: clear(1,1);
inkey_delay(command,0); if (command <> null) then goto bye;
prt('<       Go up an up-staircase.|   >      Go down a down-staircase.',1,1);
prt('?       Display this panel.   |  ^M      Repeat the last message.',2,1);
prt(']       Armor list.           |  ^R      Redraw the screen.',3,1);
inkey_delay(command,0); if (command <> null) then goto bye;
prt('|       Weapon list.          |  ^Y      Quit the game.',4,1);
prt('                                 ^Z      Save character and quit.',5,1);
prt('Movement:',7,1);
inkey_delay(command,0); if (command <> null) then goto bye;
prt('          7  8  9',8,1);
prt('          4     6    5 = Rest',9,1);
prt('          1  2  3',10,1);
inkey_delay(command,0); if (command <> null) then goto bye;
prt('Directory of Shops:',12,1);
prt('     A   Alchemy Shop                M   Magic Shop',13,1);
prt('     B   Bank                        P   Trading Post',14,1);
inkey_delay(command,0); if (command <> null) then goto bye;
prt('     C   Casino                      Q   Questor''s Home',15,1);
prt('     D   All-Nite Deli               R   Armory',16,1);
prt('     G   General Store               T   Temple',17,1);
inkey_delay(command,0); if (command <> null) then goto bye;
prt('     I   Inn                         U   Music Shop',18,1);
prt('     J   Gem Shop                    W   Weapon Smith',19,1);
prt('     L   Library                     X   Money Exchange',20,1);
prt('     +   Unknown',21,1);
      pause(24);
bye:  draw_cave;
bye2:
    end;



	{ Help for available wizard commands				}
[global,psect(wizard$code)] procedure wizard_help;
    begin
      clear(1,1);
      prt('^A -  Remove Curse and Cure all maladies.',1,1);
      prt('^B -  Print random objects sample.',2,1);
      prt('^D -  Down/Up n levels.',3,1);
      prt('^E - *Change character.',4,1);
      prt('^F - *Delete monsters.',5,1); 
      prt('^G - *Allocate treasures.',6,1);
      prt('^H -  Wizard Help.',7,1);
      prt('^I -  Identify.',8,1);
      prt('^J - *Gain experience.',9,1);
      prt('^K - *Summon monster.',10,1);
      prt('^L -  Wizard light.',11,1);
      prt('^N -  Print monster dictionary.',12,1);
      prt('^O - *Summon monster by its name.',13,1);
      prt('^P -  Wizard password on/off.',14,1);
      prt(' s - *Statistics on item (in inventory screen).',15,1);
      prt('^T -  Teleport player.',16,1);
      prt('^U - *Roll up an item.',17,1);
      prt('^V -  Restore lost character.',18,1);
      prt('^W - *Create any object *CAN CAUSE FATAL ERROR*',19,1);
      prt('^X - *Edit high score file',20,1);
      pause(24);
      draw_cave;
    end;

{ Since MASLIB does not take well to spawned processes, the utility
  routine LBR$OUTPUT_HELP was used as a replacement. -WWB }

[global,psect(misc2$code)] procedure moria_help(help_level : vtype);

    begin
      help_level := help_level+' IMORIA';
      lbr$output_help(%immed lib$put_output,,help_level,
      %stdescr 'mas$library:[help]:moriahlp',%ref hlp$m_prompt,
      %immed lib$get_input);
    end;

End.
