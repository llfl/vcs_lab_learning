#include "veriuser.h"	/* Base Verilog PLI definitions		*/
#ifdef verilogxl
#include "vxl_veriuser.h"
#endif

char *veriuser_version_str = "<< File read functions are linked in >>\n";

int (*endofcompile_routines[])() = 
{
    0 /*** final entry must be 0 ***/
};

bool err_intercept(level,facility,code)
int level; char *facility; char *code;
{ return(true); }


extern int fopen_check();
extern int fopen_call();
extern int fopen_misc();
extern int fclose_check();
extern int fclose_call();
extern int fclose_misc();
extern int fgets_check();
extern int fgets_call();
extern int gets_check();
extern int gets_call();
extern int fgetc_check();
extern int fgetc_call();
extern int getchar_check();
extern int getchar_call();
extern int ungetc_check();
extern int ungetc_call();
extern int feof_check();
extern int feof_call();
extern int ferror_check();
extern int ferror_call();
extern int fscanf_check();
extern int fscanf_call();
extern int fscanf_misc();
extern int sscanf_check();
extern int sscanf_call();
extern int sscanf_misc();
extern int scanf_check();
extern int scanf_call();
extern int scanf_misc();
extern int ftell_check();
extern int ftell_call();
extern int fseek_check();
extern int fseek_call();
extern int fread_check();
extern int fread_call();
extern int sprintf_check();
extern int sprintf_call();
extern int sprintf_misc();
extern int fprintf_check();
extern int fprintf_call();
extern int fprintf_misc();


/******************************************************************************
 veriusertfs structure
******************************************************************************/

s_tfcell veriusertfs[] = {
  /*** Template for an entry:
    { usertask|userfunction, data,
        checktf(), sizetf(), calltf(), misctf(),
        "$tfname", forwref?, Vtool?, ErrMsg? },
    Example:
    { usertask, 0, my_check, 0, my_func, my_misctf, "$my_task" },
    ***/
    {userfunction, 1, fopen_check,   size32, fopen_call,   fopen_misc, "$fopena"},
    {userfunction, 2, fopen_check,   size32, fopen_call,   fopen_misc, "$fopenr"},
    {userfunction, 3, fopen_check,   size32, fopen_call,   fopen_misc, "$fopenw"},
    {userfunction, 1, fclose_check,  size32, fclose_call,  0, "$fclosea"},
    {userfunction, 2, fclose_check,  size32, fclose_call,  0, "$fcloser"},
    {userfunction, 3, fclose_check,  size32, fclose_call,  0, "$fclosew"},
    {userfunction, 0, fgets_check,   size32, fgets_call,   0, "$fgets"},
    {userfunction, 0, gets_check,    size32, gets_call,    0, "$gets"},
    {userfunction, 0, fgetc_check,   size32, fgetc_call,   0, "$fgetc"},
    {userfunction, 0, getchar_check, size32, getchar_call, 0, "$getchar"},
    {userfunction, 0, ungetc_check,  size32, ungetc_call,  0, "$ungetc"},
    {userfunction, 0, feof_check,    size32, feof_call,    0, "$feof"},
    {userfunction, 0, ferror_check,  size32, ferror_call,  0, "$ferror"},
#ifdef scanf_task
    {userfunction, 0, fscanf_check,  0,      fscanf_call,  fscanf_misc, "$fscanf"},
    {userfunction, 0, sscanf_check,  0,      sscanf_call,  sscanf_misc, "$sscanf"},
    {userfunction, 0, scanf_check,   0,      scanf_call,   scanf_misc, "$scanf"},
#else
    {userfunction, 0, fscanf_check,  size32, fscanf_call,  fscanf_misc, "$fscanf"},
    {userfunction, 0, sscanf_check,  size32, sscanf_call,  sscanf_misc, "$sscanf"},
    {userfunction, 0, scanf_check,   size32, scanf_call,   scanf_misc, "$scanf"},
#endif
    {userfunction, 0, ftell_check,   size32, ftell_call,   0, "$ftell"},
    {userfunction, 0, fseek_check,   size32, fseek_call,   0, "$fseek"},
    {userfunction, 0, fread_check,   size32, fread_call,   0, "$fread"},
    {userfunction, 0, sprintf_check, size32, sprintf_call, sprintf_misc, "$sprintf"},
    {userfunction, 0, fprintf_check, size32, fprintf_call, fprintf_misc, "$fprintf"},
    {0}                           /*** final entry must be 0 ***/
};


#ifdef MTI
void init_usertfs() {
  p_tfcell usertf;
  for (usertf = veriusertfs; usertf; usertf++) {
    if (usertf->type == 0)
      return;
    mti_RegisterUserTF(usertf);
  }
}
#endif
