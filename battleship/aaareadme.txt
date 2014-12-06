                            VMS BATTLESHIP V1.0
                            ===================
                          Written by Ray Renteria
                             RR02026@SWTEXAS
                                    or
                             ACM_CSA@SWTEXAS
                       Southwest Texas State University
                              August 30, 1989
                       Copyright(C) 1989 IRONLOGIC(tm)
                            all rights reserved


   Included in this ZOO file:
   ==========================

              AAAREADME.TXT        - this file

              Executables ------------------------------

              BATTLE.EXE           - the game itself
              BATTLESHIP_MAINT.EXE - maintenance program to view/control
                                     users who have played the game.

              Source      ------------------------------
              (See headers within the files for descriptions)

              BATTLE.FOR           
              BATTLE.INC           
              BATTLESHIP_MAINT.FOR
              BATTLE_ARRAY.INC
              COMLINK.FOR
              LOGGER.FOR
              SCREEN1.FOR
              SCREEN2.FOR
              SYSTEM.FOR
              TIME.FOR

              Data files  ------------------------------

              BATTLESHIP_NYSSA.DAT - Sample mailbox exchange file 
              BATTLESHIP_TEGAN.DAT - Sample mailbox exchange file
              BATTLESHIP_TIMES.DAT - Scheduled times of allowed playing
              BATTLESHIP_UAF.DAT   - Battleship User Authorization File

   BATTLESHIP_MAINT:
   =================
   To set it up:

             $ RUN BATTLESHIP_MAINT
             BATTLESHIP-MAINT> INITIALIZE
             Enter the name of the node you wish to install
             and press [return].  Press [return] on an empty
             prompt when you have finished all nodes.
 
             Node: UHVAX1
             Node: ANOTHER_NODE
             Node: AS_MANY_NODES_AS_YOU_WANT
             Node: <CR>
             
   For help within BATTLESHIP_MAINT, type HElp, MEnu, or ?.  I have
   incorporated most of the options except for scheduled times and
   default flags.

   The flags are your way of controlling who gets to play the game.
   They are a four character bit pattern with each bit being significant
   for it's purpose. 
              
         '1111'
          ^^^^
          ||++---- these two are reserved for later use.
          |+--- When this is one, the user is allowed to play.
          +---- When this is one, the user can override the scheduled time

   Note:
   Please keep in mind that I just threw in LOGGER at the last minute of
   distribution and wrote BATTLESHIP_MAINT with little effort.  Please feel
   free to FINISH the maint routines. (just send me the updates  :)  )

   After you have INITialized the database, the protection settings will
   need to be as follows:

          BATTLESHIP_MAINT.EXE  (none)
          BATTLE.EXE            W:E
          BATTLESHIP_UAF.DAT    W:RW
          BATTLESHIP_UHVAX1.DAT W:RW
          BATTLESHIP_TIMES.DAT  W:RW

   BATTLE.EXE
   ==========

   BATTLE is a multi-user strategy game.  It uses a lot of ASTs and requires 
   the TMPMBX priv.  It exchanges mailbox names with the opponent via the 
   BATTLESHIP_node.DAT file - and the rest is done in system memory.

   An operator may decide the times users can play the game and even restrict
   problem users via BATTLESHIP_MAINT.EXE.


   Object:
   ======
   To destroy the opponent's ships before he destroys yours.  
   
   Waiting for opponent:
   ====================
   Upon execution of BATTLE, your process will be hibernated until an
   opponent on the same node RUNs BATTLE.  If you press ^C during this
   time, you will be gracefully escorted to DCL.


   Setting up:
   ==========
   Initially, you will set up your ships by:

         1. Pressing the first character of the ship you wish to
            place then
         2. move your arrows left, right, up or down to place that
            particular ship.  You will not be allowed to make any 'L'
            shaped ships.

        Before you have finished placing the ship, if you wish to relocate
        it, press ^Z and it will erase the portion of the ship you have
        placed and 


   Commands
   ========
       ^W      refreshes the screen
       ^E      sends a message to the opponent
       ^A      aborts game
       ^H      provides very brief help
       ^P      spawn to DCL
     arrows    aim
     [space]   fires a torpedo
       <CR>    fires a torpedo


   ----------------------------------------------------------------------
   If you find this program fun to use, or the code somewhat useful,
   please send a bag of cheetos and a Dr. Pepper via eMail to:

             BITNET%"ACM_CSA@SWTEXAS"
     or      BITNET%"RR02026@SWTEXAS"

   Have fun!

   Ray Renteria
   the MAD MEXICAN
