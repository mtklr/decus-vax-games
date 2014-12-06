(* DIGITAL VT100 Terminal Control Codes. 
 *
 * * This file is a component of the INTERACT Pascal Games Library * *
 *       ** from Waikato University, Hamilton, NEW ZEALAND **
 *
 *  Written by Paul Denize (PDENIZE@WAIKATO.AC.NZ) 
 *
 *  Contributing authors: Rex Croft (CCC_REX@WAIKATO.AC.NZ)
 *                        Lawrence D'Oliviero (LDO@WAIKATO.AC.NZ)
 *                        Chris Guthrey (CGUTHREY@WAIKATO.AC.NZ)
 *)
CONST
  VT100_ESC  = chr(27);

  VT100_top      = ''(27)'#3';
  VT100_bottom   = ''(27)'#4';
  VT100_wide     = ''(27)'#6';

  VT100_normal   = ''(27)'[m';
  VT100_bright   = ''(27)'[1m';
  VT100_flash    = ''(27)'[5m';
  VT100_inverse  = ''(27)'[7m';

  VT100_bright_only  = ''(27)'[0;1m';
  VT100_flash_only   = ''(27)'[0;5m';
  VT100_inverse_only = ''(27)'[0;7m';

  VT100_store    = ''(27)'7';
  VT100_restore  = ''(27)'8';

  VT100_graphics_on  = ''(27)'(0';
  VT100_graphics_off = ''(27)'(B';
  VT100_Alternate_graphics = ''(27)')0';

  VT100_normal_scroll = ''(27)'[0;24r';
  VT100               = ''(27)'<';

  VT100_application_keypad    = ''(27)'=';
  VT100_no_application_keypad = ''(27)'>';

  VT100_bell = chr(7);
  VT100_bs   = chr(8);
  VT100_lf   = chr(10);
  VT100_cr   = chr(13);
  VT100_si   = chr(14);
  VT100_so   = chr(15);

  (* VT320 Specific Codes added by Chris Guthrey (10 March 93) *)

  VT320_G1_Char_Set = chr( 14 );
  VT320_G0_Char_Set = chr( 15 );

  VT320_VT100_Mode = ''(27)'[61"p';
  VT320_8bit_Mode = ''(27)'[62"p';
  VT320_7bit_Mode = ''(27)'[63;1"p';   (* default Vt320 mode *)
