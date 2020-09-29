/*
** strobe_compare.c
**
** This is a simple pli implentation of system task $strobe_compare.
** It is not particularly efficient in that it accesses and processes
** values in string form.  A faster implementation can be done
** with the pli using tf_exprinfo() in place of tf_strgetp(),
** and a much faster non-pli implementation can be done for VCS
** if needed.  In the most common usage scenarios, however, the
** overhead of this task, as implemented here, will be minor.
** 
** pli table entry:
**   $strobe_compare call=sc_call misc=sc_misc check=sc_check
**
*/
 
#include "vcsuser.h"
 
#define maxValSize 4096+1
 
sc_call()
{
    tf_rosynchronize();
}
 
sc_misc(data, reason)
int data, reason;
{
    int nump, i;
    char buf[maxValSize], *val1, *val2;
 
    switch (reason) {
      case reason_rosynch:
        nump = tf_nump();
        for (i = 1; i<nump; i+=2) { 
            strcpy(buf, tf_strgetp(i,'b'));
            val1 = buf;
            val2 = tf_strgetp(i+1,'b');
            if (strcmp(val1, val2)) {
                tf_warning("Expected  (arg %d): %s\nSimulated (arg %d): %s",
                           i, val1, i+1, val2);
            }
        }
        break;
    }
}
 
sc_check()
{
    int nump = tf_nump(), i;
    
    if ((!nump) || (nump%2)) {
        tf_error("$strobe_compare requires an even number of arguments");
    }
    else
        for (i = 1; i<nump; i+=2) {
            int size1 = tf_sizep(i);
            int size2 = tf_sizep(i+1);
            if (size1 != size2)
                tf_error("$strobe_compare: args %d and %d of different sizes",
                         i, i+1, size1, size2);
            if (tf_sizep(i) > maxValSize) {
                tf_error("$strobe_compare: arg %d too big: %d (max:%d)",
                         i, maxValSize);
            }
        }
}
