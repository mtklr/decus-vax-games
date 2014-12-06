If you FTP any of the programs mentioned below, please include this help file!

There are two help files included here, one for shroom (a game) and one
for levelr (a utility to create levels).  Have fun with both!

NOTE: both programs have been setup as verbs, to run these you must first type: 
                     SET COMMAND SHROOM  and SET COMMAND LEVELR
            after that just type LEVELR and SHROOM to run the programs.

       For those unfamiliar with verbs, the .cld programms are essential for
       the operation of the programs!  These are the files that set command
       looks for and reads.  You will HAVE to change the "image" name to the
       the ENTIRE path name.  Mine is disk$userdisk1:[mas0.masrich.games]shroom
       It is a pain, but verbs are VERY handy and easy to use.  Almost all
       the programs on VAX (delete, directory, show, set, etc) are verbs.

       Also, change the PREFIXD constants in both LEVELR and SHROOM.  This
       is the directory path only.  For example, mine is:
             disk$userdisk1:[mas0.masrich.games]

*******************************shroom help file*******************************

The game of shroom is a strategy/skill game.  It's a fairly simply concept:
You (the worm) must eat all the shrooms on the board in order to complete
the level and go on to the next stage.  There are 20 levels in all.

Each shroom eaten adds 10 more segments to the worms length.  If you hit
a wall, yourself or the house, you die.  Three lives are initially given with
a bonus life every 5 levels completed.

The worm is controlled with the cursor keys but this can be changed with the
/mapkey qualifier or within the program with OPTIONS.

The worm looks like this : ooooooooooooo
The walls look like this : |||||||||||||
the house is             : ^
and the shroom is        : @

Additional information Avaliable, for customization:

/MAPKEY=
   This qualifier can be used to remap the cursor keys to any other set of 
   keys on the keyboard.  Usage is shroom/mapkey=uldr, where u is up, l is
   left, d is down, and r is right.

   NOTE:  Because Vax CLI will automatically convert all letters to uppercase
          you should enclode the "udlr" in quotes.  So format is really:
          shroom/mapkey="udlr".  As an alternative, use the OPTIONS menu
          within shroom.  It is much more userfriendly, and is the only way
          to specify the numeric keypad for movement controll.

/SEGMENT=
   This is used to select what character will be used as the segment of the
   worm.  The default is a lowercase "o".  Usage is shroom/segment={character}
   
   Again, enclose the character in quotes.

/MUSHROOM=
   This is used to select what character will be used as the mushroom.  The
   default is "@".  Usage is shroom/mushroom={character}.

   Again, use quotes around the character.

/WALL=
   This is used to select what character will be used as the mushroom.  The
   default is "|".  Usage is shroom/wall={character}.

   Again, enclose the character in quotes.
 
/DIRECTORY=
   This feature allows you to specify the directory without modifying any
   of the code.  This will overide the value of PREFIXD (declared as a constant)
   in the header of shroom.  All levels and other files (high score, save file)
   will be stored in this directory as well.

*****************************levelr help file********************************

/DIRECTORY=
   This is to set the directory of where the levels will be stored.  Of course,
   you must you the same directory for both shroom and levelr.  You can change
   the default directory by editing the source code:  You will need to change
   the constant PREFIXD (default prefix for the directory).

/WALL=
   This is to set the character for the WALL, the default is "|".  Usage is
   levelr/wall={character}  NOTE be sure to inclose the character in quotes,
   since all letters are converted to uppercase if they are not enclosed.

/BRIGHT
   This is a simple qualifier.  When you cut and paste, you can either specify
   a border to surround the characters to be moved, or them to be highligted.
   
/NOBACKUP
   This is used to specify that you DON'T want a backup files created.  Other-
   wise a backup file will be created automatically every time you swith to 
   edit another level.  This is to prevent loss of work if the system crashes
   like it does here all the time.  All backup files will be automatically 
   deleted after you exit from editing a level, by either Quiting or Saving.

   Backups are created every minute, so you may loose some work, although
   the amount lost will be somewhat trivial.


   If you have any questions, please mail me.

   Thank you,
   Rich Wicks
   MASRICH@UBVMS, masrich@ubvms.cc.buffalo.edu
