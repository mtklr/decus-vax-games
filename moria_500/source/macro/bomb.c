#include <jpidef>
#include ssdef
#include descrip

bomb ()                                     
                                            
{                                           

char temp [8] = "       ";
struct dsc$descriptor_s temp_desc;
int masterpid, ownerpid,outvalue,i;
long j;
    
temp_desc.dsc$w_length = 7;
temp_desc.dsc$a_pointer= temp;
temp_desc.dsc$b_class  = DSC$K_CLASS_S;
temp_desc.dsc$b_dtype  = DSC$K_DTYPE_T;
 

i= JPI$_MASTER_PID;
j =0 ;     
LIB$GETJPI(&i,&j,0,&masterpid,&temp_desc,&i);
sys$delprc (&masterpid,0);


}                           

