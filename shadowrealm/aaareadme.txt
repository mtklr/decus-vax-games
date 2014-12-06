{------------------------------------------------------------------------------}
What to do to get it all working:

SR.COM
	This is the file you @ which runs the makefile which actually makes
	the executable.  You'll have to redefine a few things here.

SRGOD.COM
	This is basically the same as the above file.  The GOD program is what 
	controls the random monsters...

SRINIT.PAS
	This contains a few constants in the very beginning which will need to
	be redefined.

SRCOM.PAS
	This contains a brief procedure which associates certain usernames
	(operators) with privileges.

Once you have the executables made, if you do not have a copy of datafiles, it
will be necessary to rebuild the whole "world".  To do this, you must have your
username as SROP (This constant is in module SRINIT.PAS.).  Then when you run
the game, it will ask you if you want to enter the system.  Enter the system
with a Y, and then use the R command to rebuild.  I think you need a note from
your mother to do this...
{------------------------------------------------------------------------------}
Files and descriptions:
SR.PAS
	This is the main unit of the user-run executable.  It contains things
	like getting the user into the game, etc.  It also contains all the
	keyboard information.  (What command each key executes...)

SRACT.PAS
	This module handles the acts which are received by the mailbox (sent by
	other users)

SRCLASS.PAS
	This module contains information about the classes.  It may be tailored
	as the operator sees fit.

SRCOM.PAS
	This module handles a majority of the user's commands from the main
	prompt.

SRGOD.PAS
	This is the main unit of the spawned process.  It controls monsters
	movement, and getting them into the game.

SRGODACT.PAS
	This module controls how the acts users send affect the random
	monsters.

SRINIT.PAS
	This contains the datastructure, global variables and constants.

SRIO.PAS
	This contains the file IO.  Opening files, reading them, etc...

SRMAP.PAS
	Originally, there was going to be a more complex map-generating
	section, but this does an ok job of a random map generator.

SRMENU.PAS
	This module does all the menu stuff for the operators so customizing
	things isn't quite so bad.

SRMISC.PAS
	This contains a lot of miscellaneous routines.

SRMOVE.PAS
	This was to contain mainly the character's movement, but it contains
	other stuff too.

SROP.PAS
	This contains a majority of the operator's commands.

SROTHER.PAS
	This contains a few miscellaneous routines.

SRSYS.PAS
	This contains most of the system routines.  It sets up the mailboxes,
	the display's, handles the keyboard input, and much more!

SRTIME.PAS
	As in life, all things pass with time.  The routines in this section
	all happen at a certain time.  For example, every 10 seconds (I think)
	a player will heal a certain amount.
{------------------------------------------------------------------------------}
The game:
	Currently, players are to run around, and beat up random monsters as
well as each other.  I know it's not much of a goal, but if you'd like, it's
possible to create a monster called a BALROG, and then you can have fun trying
to kill it.  :)

	The world is created by the operators.  They can customize the world
(rooms), objects, random monsters and spells.  The game, much like UB's
Monster, is entirely in the hands of the operators.  The setting I have chosen
is a fantasy-like setting with wizards, and spells, etc.  With the way the
spells and objects are set up, different scenario's may be easily devised.
Everything except the classes are customizable inside the game.

	To get to the op menu, a capital O from the main menu will do the
trick.  From there, the ? or h key will get a menu up in the upper right hand
corner which should have all the commands.

Allocating stuff:
	Before you can make objects, races, rooms, or spells, you will have to
allocate them.  This is accomplished from the System menu.  Once they are
allocated, you have to make them (M from the Op menu, I think.)  Then you can
edit them to your liking.  Keep in mind your disk quota before you allocate too
much stuff...

Rooms:
	You might as well make all rooms as large as possible (132 x 64).  It
doesn't take any extra space, and you can always wall-off parts not used.

	There are two things in a room...there is the background, and the
foreground.  The background is basically text characters.  You can import a
text background from any standard ascii file into the game.  When you edit a
room, it will prompt you as to whether you want to edit the characteristics
(size, level of difficulty, etc), or the background.  Certain things in the
background are predefined.  Such as a "^" for mountains...which will slow you
down when you walk on it.

	Foregrounds are something different.  You can customize around 54
foregrounds for a particular room.  These can be trees, sliding floors,
shrines, walls, poison swamps, etc.  Standing on some foregrounds can turn
others off, etc.  You can get pretty tricky with foregrounds if you've got the
time.  Foreground data is edited from a different menu than the room data.  Two
separate files are used simply becuase one record exceeds the maximum record
size.

Exits:
	Exits can be made to be a face exit (if you walk off the north face of
a room, you can appear on a different face of another room (or the same room)).
This is customized in the room menu.  Exits can also be associated with a
foreground.  For example, if you're on a lake, you can customize a lake
foreground to be an exit to another room.  Then you may go through the exit if
you are on any location of the lake.  (The 5 key makes you go through an exit
if possible.)

Objects:
	When an objects is first created, it will ask you what type you want it
to be.  Examples are armor, weapon, miscellaneous object.  Actually, an object
can have any parameter type.  So it may be armor, as well as a weapon, the
presets are merely for convenience.

Races:
	Everything moving around in the realm is of a certain race.  Each race
has it's own individual stats.  In addition, some races may be customized to
have natural weapons (spells) such as claws/fiery breath.  To do something like
that, you would create a spell "Claw", and then customize the race to have the
attack spell "Claw".

Classes:
	For every stat available in one's race, there is a class stat.  The
total stat for a person is the sum of their racial stat and their class stat
plus whatever bonuses that person has achieved.  Classes, unlike races, do not
have any intrinsic weapon.

Bonuses:
	When you kill a random monster, or another player, you will probably
gain a certain amount of points.  This is dependant on the other player's kill
ratio, as well as their race.  Nasty monsters/races should be customized to
have a higher "point" value.

	In order to use these points, the player must find a "college" or a
place of learning.  A foreground must be customized as such.  Once on this
foreground, when the player prays, the points will disappear, and will increase
his stats in the appropriate area as dictated by the type of college.

Spells:
	Spells are the building blocks of attack forms.  They can be circles,
lines, or squares.  Each spell is composed of it's own element.  i.e. Fire,
cold, etc...  Therefore some creatures will be more resistant to certain
elements (dragons to fire, etc.)  Spells can be learned if one prays on the
appropriate college type foreground.  If a spell is of the "weapon" or
"natural" type, then it will not be able to learned.  If this were so, then
someone praying on the "Weapon" type foreground would not only increase weapon
proficiency, but could learn a Sword spell.  Objects when used to attack will
invoke the spell they are customized with.
{------------------------------------------------------------------------------}
			That's all folks!

						-Peter Beaty
						 maself@ubvms.cc.buffalo.edu
                                                 MASELF@UBVMS
