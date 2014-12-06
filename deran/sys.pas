[inherit ('sys$library:starlet')]
 
module guts(input,output);
 
const
        SHORT_WAIT = 0.1;
        LONG_WAIT = 0.2;
        maxcycle = 15;          { attempting to fine tune nextkey }
 
type
	$UBYTE = [BYTE] 0..255;
        $uword = [word] 0 .. 65535;
	$UQUAD = [QUAD,UNSAFE] RECORD
		L0,L1:UNSIGNED; END;
        string = varying[80] of char;
        ident = packed array[1..12] of char;
 
        iosb_type = record
                cond: $uword;
                trans: $uword;
                junk: unsigned; {longword}
        end;
 
        il3 = record
             buflen : $uword;
             itm    : $uword;
             baddr  : unsigned;
             laddr  : unsigned;
        end;
 
 
var
        pbrd_id:        unsigned;       { pasteboard id    }
        kbrd_id:        unsigned;
        pbrd_volatile:  [volatile] unsigned;
        mbx:            [volatile] packed array[1..132] of char;
        mbx_in,                                 { channels for input and   }
        mbx_out:        [volatile] $uword;      { output to the subprocess }
        pid:            integer;
        iosb:           [volatile] iosb_type;   { i/o status block         }
        status:         [volatile] unsigned;
        save_dcl_ctrl:  unsigned;
        trap_flag:      [global,volatile] boolean;
        trap_msg:       [global,volatile] string;
        out_chan:       $uword;
        vaxid:          [global] packed array[1..12] of char;
        advise:         [external] string;
        line:           [global] string;
        old_prompt: [global] string;
 
        seed: integer;
 
        user,uname:varying[31] of char;
        sts:integer;
        il:array[1..2] of il3;
        key:$uword;
 
        userident: [global] ident;
 
 
[asynchronous, external (lib$signal)]
function lib$signal (
   %ref status : [unsafe] unsigned) : unsigned; external;
 
[asynchronous, external (str$trim)]
function str$trim (
   destination_string : [class_s] packed array [$l1..$u1:integer] of char;
   source_string : [class_s] packed array [$l2..$u2:integer] of char;
   %ref resultant_length : $uword) : unsigned; external;
 
[asynchronous, external (smg$read_keystroke)]
function smg$read_keystroke (
    %ref keyboard_id : unsigned;
    %ref word_integer_terminator_code : $uword;
    prompt_string : [class_s] packed array [$l3..$u3:integer] of char := %immed
0;
    %ref timeout : unsigned := %immed 0;
    %ref display_id : unsigned := %immed 0;
    %ref rendition_set : unsigned := %immed 0;
    %ref rendition_complement : unsigned := %immed 0) : unsigned; external;
 
[asynchronous, external (smg$create_virtual_keyboard)]
function smg$create_virtual_keyboard (
    %ref keyboard_id : unsigned;
    filespec : [class_s] packed array [$l2..$u2:integer] of char := %immed 0;
    default_filespec : [class_s] packed array [$l3..$u3:integer] of char := %immed 0;
    resultant_filespec : [class_s]
    packed array [$l4..$u4:integer] of char := %immed 0) : unsigned; external;
 
[asynchronous, external (lib$disable_ctrl)]
function lib$disable_ctrl (
    %ref disable_mask : unsigned;
    %ref old_mask : unsigned := %immed 0) : unsigned; external;
 
[asynchronous, external (lib$enable_ctrl)]
function lib$enable_ctrl (
    %ref enable_mask : unsigned;
    %ref old_mask : unsigned := %immed 0) : unsigned; external;
 
 
[ASYNCHRONOUS,EXTERNAL(SYS$GETJPIW)]
 FUNCTION $GETJPIW (
	%IMMED EFN : UNSIGNED := %IMMED 0;
	VAR PIDADR : [VOLATILE] UNSIGNED := %IMMED 0;
	PRCNAM : [CLASS_S] PACKED ARRAY [$l3..$u3:INTEGER] OF CHAR := %IMMED 0;
	%REF ITMLST : [UNSAFE] ARRAY [$l4..$u4:INTEGER] OF $UBYTE;
	VAR IOSB : [VOLATILE] $UQUAD := %IMMED 0;
	%IMMED [UNBOUND, ASYNCHRONOUS] PROCEDURE ASTADR := %IMMED 0;
	%IMMED ASTPRM : UNSIGNED := %IMMED 0) : INTEGER; EXTERNAL;

procedure syscall( s: [unsafe] unsigned );
 
begin
   if not odd( s ) then begin
      lib$signal( s );
   end;
end;
 
[global]
function get_userid: string;
 
begin
  il:=zero;
  il[1].itm    := jpi$_username;
  il[1].buflen := size(user.body);
  il[1].baddr  := iaddress(user.body);
  il[1].laddr  := iaddress(user.length);
  syscall($getjpiw(,,,il));
  syscall( str$trim(uname.body,user,uname.length) );
  userident := user;
  get_userid := uname;
end;

end.
