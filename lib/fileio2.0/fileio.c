/*******************************************************************************
    fileio.c - Verilog PLI code to implement the C file input/outout functions
    Grab the latest from http://chris.spear.net

    Copyright (C) 1995, 1996, 1997, 1998, 1999 Christian B. Spear
    Hey - let's not be formal, you can call me Chris!

    This program is free software; you can redistribute it and/or modify
    it under the terms of the GNU General Public License as published by
    the Free Software Foundation; either version 2 of the License, or
    (at your option) any later version.

    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU General Public License for more details.

    You should have received a copy of the GNU General Public License
    along with this program; if not, write to the Free Software
    Foundation, Inc., 675 Mass Ave, Cambridge, MA 02139, USA.

$Id: fileio.c,v 2.0 2000/01/11 15:11:29 spear Exp $

Edit history
Who When     Version What
hm   1/06/00  2.00   Add $scanf, $gets, $getc by Hans Mack,
ajk  1/06/00  2.00   Changed padding to be closer to Verilog than C
		     ie. %x > "0024", %0x > "24"
gg   1/06/00  1.15   Bounds check file_num in close_and_free
		     Add -Dscanf_task for people who do not want
		     $fscanf, $sscanf, $scanf to return a value
af  12/02/99  1.14   Many fixes for MTI including $save/$restart, plus 
                     formated printing of single 0, by Anders Fyhn
ms  11/03/99  1.13   Added $fflush, more MTI support for $restore, return vals
                     by Magnus Soderberg
ajk 10/01/99  1.12   Support %0b, %0d, %0o, %0x in sprintf, fprintf
                     by Adam Krolnik
crs  9/23/99  1.11   Inspired by Chris Starr, cleaned out workarea in $fopen
                     One $fopenr instance can now open a file more than once
cbs  8/30/99  1.10   Stop trashing fmt->string in sscanf %s
                     Magnus Soderberg added better MTI support
cbs  5/24/99  1.9    Open files with "rb", "wb", or "ab" for Windows
cbs  5/11/99  1.8    Clean up compile warnings on Windows
cbs  5/07/99  1.7    Clean up veriuser.c example
cbs  4/23/99  1.6    Initialize fprintf/sprintf buffer before use
cbs  4/20/99  1.5    Add FMT_BAD, memset after malloc, support %%
cbs  4/14/99  1.4    Allow $fopen(tf_readonly)
cbs  4/13/99  1.3    Added debug code for $fseek, $ftell
cbs  3/31/99  1.2    Added %m to $fprintf, $sprintf
cbs  3/22/99  1.1    Changed to fileio.c, added $fopenw, $fprintf, $fclosew
-----------------------------------------------------------------------------
cjc  3/05/99   2.9-00  Added sprintf
cbs  2/26/99   2.8-00  Merge in changes from Carl Crawford
                       Add leading white space to %[01XZ] to mimic real %d
		       Fix sscanf(FM_STRING) to handle multiple spaces
cbs 10/09/98   2.7-00  Fix sscanf for multiple spaces, thanks to John Providenza
                       In sscanf & fscanf, return arg count on EOF, not EOF
cbs  8/10/98   2.6-00  Add tweaks for MTI support,
                       Fix index in fread_call - make int, use correct bounds
cbs  7/23/98   2.5-00  Replace get_str_arg with tf_getcstringp
                       fread signed bytes correctly, get memory length right
cbs  3/13/98   2.4-00  Add NC-Verilog conditional compilation
                       Add $ferror, don't give error in $fopenr
		       Fscanf now returns # args actually read
cbs 10/06/97   2.3-00  Improve error msgs, g++ hooks
cbs  5/07/97   2.2-00  Fix printing of file name in error message ROPENE
cbs  3/12/97   2.1-00  Clean up some of the casts, and some acc_ calls
cbs  1/23/97   2.0-00  Release to everyone...
cbs 12/24/96   1.9-00  More string bugs
cbs 12/18/96   1.8-00  Fix my strcpy bug in build_fmt_list
cbs  8/07/96   1.7-00  Remove VCS_fopen, more debug for fgetc
cbs  2/08/96   1.6-00  Switch to VCS_fopen for VCS to work with $save
                       Cleanups to work with PC
cbs  2/08/96   1.5-00  Look for memory leaks, fix space in sscanf
cbs  2/02/96   1.4-00  Use int to copy strings in get_str_arg
cbs  1/24/96   1.3-00  Allow regs in file name for Alpha
cbs  1/22/96   1.2-00  Make $feof return integer result
cbs 12/28/96   1.1-00  Cleanup for general release
cbs 10/25/95   0.3-00  Allow regs in file name, ie $fopenr(my_file);
cbs  9/14/95   0.2-00  Changed to tf_putp(0,val) from acc_handle_tfinst
cbs  6/29/95   0.1-00  First release
cbs  5/25/95   0.0-00  Created



HOW TO USE fileio.c:

With VCS 4.x on a Sun or HP, compile fileio.c:
    cc -c fileio.c -I$VCS_HOME/`vcs -platform`/lib

With VCS on a Sparc, compile fileio.c with
    cc -c fileio.c -I$VCS_HOME/`vcs -platform`/lib -taso -xtaso_short

Then compile your model with:
    vcs my_model.v fileio.o -P fileio.tab

With Verilog-XL, compile with cr_vlog and add the -Dverilogxl switch
to the C compile. See the end of the file for the veriusertfs structure 
for veriuser.c.

With NC-Verilog compile with the -DNCVerilog switch to disable the routines
that use tf_nodeinfo, not supported by NC-Verilog

With Modelsim on Solaris:
    This is the short instruction, see Ch. 9 in the Modelsim manual for more info.
    (g)cc -c -DMTI -I<install_path>/include fileio.c
    ld -G -B symbolic -o fileio.so fileio.o
    cp fileio.so /<install_path>/sunos5/. 
    
    add fileio.so to the modelsim.ini file, like
    Veriuser = fileio.so

To turn $fscanf, $sscanf, and $scanf into tasks (no return value),
compile with this -Dscanf_task.  VCS users should use fileio_task.tab.
Cadence users should compile veriuser.c with -Dscanf_task

To debug problems with the code, recompile with the cc switch -DDEBUG
Use -DSAVE to turn on $save code, and -DRESET for $reset

STILL NEEDS TO BE DONE or HACKS & GOTCHAS:

- Add V2000 to switch to IEEE Verilog-2000 style
- sprintf / fprintf need to support %t
- sprintf / fprintf don't support quoting of % character - try it!
- fscanf returns -1 reading dec.txt
- Get $save / $restart working in Verilog-XL and open files in VCS
- If we were real smart, $fscanf and $sscanf would create a new format string
  and use fscanf/sscanf to write into an array of argument strings
- Some problems with gcc and VCS 3.1 on HPUX 9.05

*******************************************************************************/

#include <stdio.h>	  /* C I/O routines			              */
#ifdef verilogxl
#include "veriuser.h"	  /* OVI PLI definitions	                      */
#include "vxl_veriuser.h" /* Verilog-XL PLI definitions	                      */
#elif defined MTI
#include "veriuser.h"     /* MTI definitions                                  */
#else
#include "vcsuser.h"	  /* VCS Base Verilog PLI definitions	              */
#endif
#include "acc_user.h"	   /* Access routine definitions	              */
#include "malloc.h"        /* Malloc madness                                  */
#include "string.h"        /* Better string definitions                       */
#ifdef __cplusplus
#include "ctype.h"         /* Definitions for isdigit, tolower, isspace       */
#endif

/* Seek codes for 'wherefrom' in fseek - ANSI? These should be in stdio.h     */
#define SEEK_SET 0
#define SEEK_CUR 1
#define SEEK_END 2

/* Data arguments to tell difference between $fopena, $fopenr & $fopenw       */
#define DATA_BAD    0
#define DATA_APPEND 1
#define DATA_READ   2
#define DATA_WRITE  3


/* Read functions initialized?                                                */
bool fileio_initialized = FALSE;

/* Pointers to the open files.  Really should use SYS_OPEN instead of 8       */
/* File number 0 is reserved to catch errors                                  */
#define MAX_FILES 1000
FILE *file_streams[MAX_FILES];
char *fileio_name[MAX_FILES];
int  file_type[MAX_FILES];  /* DATA_READ, DATA_WRITE, ....                    */

/* Maximum string size - max length of strings and Verilog numbers            */
#define MAX_STRING_SIZE 1024

/* Arguments passed into a routine                                            */
#define ARG_RET 0
#define ARG1 1
#define ARG2 2
#define ARG3 3
#define ARG4 4


/*******************************************************************************
  The $fscanf statment has the form:
       $fscanf(strea, "format", args);
  The format string is parsed and broken up into a linked list of fmt items
  The PLI instance pointer then points to the head of this list

  Type of things found in a format string
  */
enum FMT_TYPE {
    FMT_BAD,            /* Capture initialization problems                    */
    FMT_B,              /* %b for a binary value                              */
    FMT_C,              /* %c for a single character                          */
    FMT_D,              /* %d for a decimal value                             */
    FMT_F,              /* %f for a floating point value (time)               */
    FMT_M,              /* %m scope instance, only for $fprintf, $sprintf     */
    FMT_O,              /* %o for an octal value                              */
    FMT_R,              /* %r for a radix'ed value 8'hFF                      */
    FMT_S,              /* %s for a string value                              */
    FMT_X,              /* %x for a hexidecimal value                         */
    FMT_SPACE,          /* White space in the format                          */
    FMT_STRING,         /* A string in the format                             */
    FMT_PERCENT         /* %% (Needed?)                                       */
};

typedef struct t_fmt
{
    enum FMT_TYPE type; /* Type of fmt item, see above                        */
    bool suppress;      /* Suppress assignment                                */
    int width;          /* Optional width for % formats                       */
    char *string;       /* Pointer to string for FMT_STRING                   */
    struct t_fmt *next_ele; /* Pointer to next element in this list           */
} s_fmt, *p_fmt;

/* 990226 - CJC printf format struct */
typedef struct t_pf_fmt
{
    enum FMT_TYPE type; /* Type of fmt item, see above (FMT_SPACE not needed) */
    char left;          /* Optional left justify flag (-)                     */
    char sign;          /* Optional sign display flag (+)                     */
    char spc;           /* Optional sign space holder flag (<sp>)             */
    char alt;           /* Optional alternate display flag (#)                */
    char pad;           /* Optional pad display flag (0)                      */
    int width;          /* Optional width for % formats                       */
    int precision;      /* Optional precision for % formats                   */
    char *string;       /* Pointer to string for FMT_STRING                   */
    struct t_pf_fmt *next_ele; /* Pointer to next element in this list        */
} s_pf_fmt, *p_pf_fmt;



int size32()
{
/*  Return a 32 bit value                                                     */
    return 32;
}




/******************************************************************************
 $fopen routines
******************************************************************************/
#ifdef __cplusplus
int fopen_check (int data, int reason)
#else
int fopen_check (data, reason)
    int data, reason;
#endif
{
/*  fopen_check checks for a single arg which could be either a string
    or reg that holds the file name.  It also initializes the data structures.
 */
    int i;
    char ftype;

    /* Is this a fopen for append, read, or write?                            */
    switch (data) {
    case DATA_APPEND: ftype = 'a'; break;
    case DATA_READ:   ftype = 'r'; break;
    case DATA_WRITE:  ftype = 'w'; break;
    default:
       tf_message (ERR_INTERNAL, "File", "BADDAT",
		   "Bad data value %d passed to fopen_check in fileio.c");
       return -1;
    } /* switch (data) */

    if (tf_nump() != 1) {
	tf_message (ERR_ERROR, "File", "ROPEN1",
		    "$fopen%c has only one argument - the file name, you gave %d",
		    ftype, tf_nump());
	return -1;
    }

    /* Allow almost any argument type */
    if (tf_typep(ARG1) != tf_string &&
	tf_typep(ARG1) != tf_readonly && 
	tf_typep(ARG1) != tf_readwrite) {
	tf_message (ERR_ERROR, "File", "ROBADA",
		    "Bad argument to $fopen%c, must be string or reg", ftype);
	return -1;
    }
#ifdef DEBUG
#ifndef NCVerilog
    {
        s_tfnodeinfo info;
        tf_nodeinfo(ARG1, &info);

    io_printf("fopen%c: node_type=%d, vec_size=%d\n",
              ftype, info.node_type, info.node_vec_size);
    }
#endif
#endif



    if (! fileio_initialized) {
	for (i=0; i<MAX_FILES; i++) {
	    file_streams[i] = NULL;
	    fileio_name[i] = '\0';
	    file_type[i] = DATA_BAD;
	}
	fileio_initialized = TRUE;
    }
    return 0;
} /* fopen_check */



#ifdef __cplusplus
int fopen_call (int data, int reason)
#else
int fopen_call (data, reason)
    int data, reason;
#endif
{
    int stream;
    char *fname, ftypec, ftypes[3];

    /* Is this a fopen for append, read, or write?                            */
    switch (data) {
    case DATA_APPEND: ftypec = 'a'; break;
    case DATA_READ:   ftypec = 'r'; break;
    case DATA_WRITE:  ftypec = 'w'; break;
    default:
       tf_message (ERR_INTERNAL, "File", "BADDAT",
		   "Bad data value %d passed to fopen_call in fileio.c");
       return -1;
    } /* switch (data) */
    ftypes[0] = ftypec;
    ftypes[1] = 'b';       /* Always use binary type (rb, wb, ab) for Windows */
    ftypes[2] = '\0';

    fname = tf_getcstringp(ARG1);               /* name of file to open       */
    if (fname == NULL) {
	tf_message(ERR_ERROR, "File", "ROPENN",
		   "Error file name is NULL");
	return -1;
    }

#ifdef DEBUG
    io_printf("fopen%c: '%s' (before fopen)\n", ftypec, fname);
#endif

    /* File 0 is reserved to catch errors                                     */
    for (stream = 1; ((file_streams[stream] != NULL) && (stream<MAX_FILES)); stream++) ;
    if (stream >= MAX_FILES) {
	tf_message(ERR_ERROR, "File", "ROPENM",
		   "Can not open any more files - all maxxed out at %d files", MAX_FILES);
        tf_putp(ARG_RET, -1);
	return -1;
    }


    /* Do the actual file open                                                */
    if ((file_streams[stream] = fopen(fname, ftypes))) {
	/* Save the file name for use in save / restart                       */
	fileio_name[stream] = strcpy((char *)malloc(strlen(fname)+1), fname);
    }
    else {
	/* There was an error opening the file - DON'T print an error,
	   just return stream 0, and let the user handle it. */
	stream = 0;
    }
    file_type[stream] = data;

#ifdef DEBUG
    io_printf("fopen%c: '%s' stream #%d\n", ftypec, fname, stream);
#endif

    /* Okay, we have successfully opened a file, or choked!
       Save the file number in the workarea for this instance of $fopenr,
       and return the file number                                             */
    tf_setworkarea ((char *) stream);
    tf_putp(ARG_RET, stream);

    return 0;
} /* fopen_call */



/*******************************************************************************
   Close a file and free any memory used                                      */
#ifdef __cplusplus
int close_and_free (int file_num)
#else
int close_and_free (file_num)
    int file_num;
#endif
{
    /* Look for possible fileio bug where tf_getworkarea returns a pointer */
    if (file_num <= 0 || file_num >= MAX_FILES) {
       tf_message (ERR_INTERNAL, "File", "CLAFR",
		   "Internal error in close_and_free, file_num = %d", file_num);
       return false;
    }

    /* Is the file currently open?                                            */
    if (file_streams[file_num]) {
	int retval = fclose (file_streams[file_num]);
	file_streams[file_num] = NULL;
	free (fileio_name[file_num]);
	fileio_name[file_num] = '\0';
	file_type[file_num] = DATA_BAD;
	return retval;
    }
    else return FALSE;

} /* close_and_free */




/*******************************************************************************
  fopen_misc:

   Save the file name and location for an open file during $save
   Reopen and fast forward the file for a $restart

   This routine saves four things into the save file:
         Once in a save file:
             "$fopenr save"
         Once for every $fopenr:
	     file open flag (true or false)
	     position of this file
	     size of the file

*/
#ifdef __cplusplus
int fopen_misc (int data, int reason)
#else
int fopen_misc (data, reason)
    int data, reason;
#endif
{

    static bool save_string_written;
    static bool save_string_read;
    static char save_string[16] = {"$fopenr save"};
    char restart_string[16],
	*fname,ftypec,ftypes[3];
    int file_num,
      position,
      file_size,
      file_open,
      tmp_file_type;

    switch (reason) {

#ifdef SAVE
    case reason_startofsave:
	save_string_written = FALSE;
	break;

    case reason_save:
#ifdef DEBUG
	io_printf("fopen_misc, instance %d, save\n", tf_getinstance());
#endif
	if (!save_string_written) {
	    tf_write_save(save_string, sizeof(save_string));
	    save_string_written = TRUE;
#ifdef DEBUG
	    io_printf("\tsave_string '%s'\n", save_string);
#endif
	}

	file_num = (int ) tf_getworkarea();
	if (file_streams[file_num]) {
	    /* The file is open, get position in the file and its size        */
	    file_open = TRUE;
	    position = ftell(file_streams[file_num]);
	    fseek(file_streams[file_num], 0L, SEEK_END);  /* Jump to end      */
	    file_size = ftell(file_streams[file_num]);    /* Get size         */
	    fseek(file_streams[file_num], position, SEEK_SET); /* Jump back   */
	}
	else {
	    file_open = FALSE;
	    position = 0;
	    file_size = 0;
	}
	io_printf("$fopen (misc) saving file [%d] '%s' pos=%d, size=%d\n",
		  file_num, fileio_name[file_num], position, file_size);
#if defined  (MTI)||(verilogxl)
	tf_write_save((char *)&file_open, sizeof(file_open));
	tf_write_save((char *)&position, sizeof(position));
	tf_write_save((char *)&file_size, sizeof(file_size));
	tf_write_save((char *)&file_type[file_num],sizeof(file_type[file_num]));
#else
	tf_write_save(&file_open, sizeof(file_open));
	tf_write_save(&position, sizeof(position));
	tf_write_save(&file_size, sizeof(file_size));
	tf_write_save(&file_type[file_num],sizeof(file_type[file_num]));
#endif
	break;
#endif


    case reason_finish:
	/* Close the current file if it is open                               */
#ifdef DEBUG
	file_num = (int ) tf_getworkarea();
	if (fileio_name[file_num]) {
	    io_printf("fopen_misc finish closing file [%d] '%s'\n",
		      file_num, fileio_name[file_num]);
	}
#endif
	close_and_free ((int ) tf_getworkarea());
	break;


#ifdef SAVE
    case reason_startofrestart:
	save_string_read = FALSE;
	/* Close the current file if it is open                               */
#ifdef DEBUG
	file_num = (int ) tf_getworkarea();
	io_printf("fopen_misc startofrestart closing file [%d] '%s'\n",
		  file_num, fileio_name[file_num]);
#endif
	close_and_free ((int ) tf_getworkarea());
	break;


    case reason_restart:
#ifdef DEBUG
	io_printf("fopen_misc, instance %d, restart\n", tf_getinstance());
#endif
	if (!save_string_read) {
	    tf_read_restart(restart_string, sizeof(save_string));
	    save_string_read = TRUE;
	    if (strncmp(restart_string, save_string, sizeof(save_string))) {
		tf_message (ERR_INTERNAL, "File", "RORIN",
			    "$fopenr internal error in $restart");
		return -1;
	    }
	}

	/* Read the file open flag, position, and file size                   */
#if defined  (MTI)||(verilogxl)
	tf_read_restart ((char *)&file_open, sizeof(file_open));
	tf_read_restart ((char *)&position, sizeof(position));
	tf_read_restart ((char *)&file_size, sizeof(file_size));
	tf_read_restart ((char *)&tmp_file_type,sizeof(tmp_file_type));
#else
	tf_read_restart (file_open, sizeof(file_open));
	tf_read_restart (position, sizeof(position));
	tf_read_restart (file_size, sizeof(file_size));
	tf_read_restart (tmp_file_type,sizeof(tmp_file_type));
#endif

	/* If the file name string length != 0, open the file.                */
	if (file_open) {
	    char *fname;
	    /* Loop though the file slots, looking for an unused one          */
	    /* File slot 0 reserved for debugging...                          */
	    for (file_num = 1;
		 (file_streams[file_num] && file_num <= MAX_FILES);
		 file_num++) ;

	    if (file_num >= MAX_FILES) {
		tf_message(ERR_ERROR, "File", "ROPENM",
			   "Can not open any more files - all maxxed out at %d files.", MAX_FILES);
		return -1;
	    }

	    fname = tf_getcstringp(ARG1);

	    switch (tmp_file_type) {
	    case DATA_APPEND: ftypec = 'a'; break;
	    case DATA_READ:   ftypec = 'r'; break;
	    case DATA_WRITE:  ftypec = 'a'; break; // Append write-files when restarting
	    default:
	      tf_message (ERR_INTERNAL, "File", "BADDAT",
			  "Bad data value %d passed to fopen_call in fileio.c");
	      return -1;
	    } /* switch (tmp_file_type) */
	    ftypes[0] = ftypec;
	    ftypes[1] = 'b';       /* Always use binary type (rb, wb, ab) for Windows */
	    ftypes[2] = '\0';

	    io_printf("$fopen%c opening file [%d] '%s' pos=%d, size=%d\n",
		      ftypec,file_num, fname,position,file_size);

	    if (!(file_streams[file_num] = fopen(fname, ftypes))) {
		tf_message(ERR_ERROR, "File", "ROPEER",
			   "Error %d opening file %s during $restart",
			   fname,
			   file_streams[file_num]);
		return -1;
	    }

	    /* Find the size of the file, and compare with the value from the
	       save file.  We really should get the timestamp of the file, but
	       that is too OS dependant.                                      */
	    fseek(file_streams[file_num], 0L, SEEK_END);       /* Jump to end */
	    if (ftell(file_streams[file_num]) != file_size) {
		tf_message(ERR_ERROR, "File", "RORSIZ",
			   "The size of file %s has changed since the $save",
			   fname);
		return -1;
	    }

	    fseek(file_streams[file_num], position, SEEK_SET); /* Jump back   */


	    fileio_name[file_num] = strcpy((char *)malloc(strlen(fname)+1), fname);
	    file_type[file_num] = tmp_file_type;

	    /* Save the file number in the instance pointer                   */
	    tf_setworkarea((char *) file_num);
	} /* if (file_open) */
	break;
#endif


#ifdef RESET
    case reason_reset:
	close_and_free ((int ) tf_getworkarea());
	break;
#endif

    default:
	break;

    } /* switch (reason) */

    return 0;
}
/* fopen_misc */

/*******************************************************************************
 $fflush routines
 ******************************************************************************/
#ifdef __cplusplus
int fflush_check (int data, int reason)
#else
int fflush_check (data, reason)
    int data, reason;
#endif
{
    if (tf_nump() != 1) {
	tf_message (ERR_ERROR, "File", "RCLOS1",
		    "$fflush has only one argument - the file number, you gave %d",
		    tf_nump());
	return -1;
    }

    if (tf_typep(ARG1) != tf_readonly &&
	tf_typep(ARG1) != tf_readwrite) {
	tf_message(ERR_ERROR, "File", "RCBADA",
		   "The file number in $fflush must be an expression or reg");
	return -1;
    }

    return 0;
} /* fflush_check */


#ifdef __cplusplus
int fflush_call (int data, int reason)
#else
int fflush_call (data, reason)
    int data, reason;
#endif
{
    int file_num = tf_getp(ARG1);               /* File number, aka. stream   */

#ifdef DEBUG
    io_printf("fflush: stream = %d\n", file_num);
#endif

    if (file_num <= 0 || file_num >= MAX_FILES) {
	tf_message(ERR_ERROR, "File", "FFLUSB",
		   "The file number %d is out of bounds.", file_num);
        tf_putp(ARG_RET, -1);
	return -1;
    }
   	
    if (file_streams[file_num] == NULL) {
	tf_message(ERR_ERROR, "File", "FFLUSN",
		   "File number %d is not currently open.", file_num);
        tf_putp(ARG_RET, -1);
	return -1;
    }

    tf_putp(ARG_RET, fflush(file_streams[file_num])); /* Return status EOF or 0    */

    return 0;
} /* fflush_call */



/*******************************************************************************
 $fclose routines
 ******************************************************************************/
#ifdef __cplusplus
int fclose_check (int data, int reason)
#else
int fclose_check (data, reason)
    int data, reason;
#endif
{
    char ftype;

    /* Is this a fopen for append, read, or write?                            */
    switch (data) {
    case DATA_APPEND: ftype = 'a'; break;
    case DATA_READ:   ftype = 'r'; break;
    case DATA_WRITE:  ftype = 'w'; break;
    default:
       tf_message (ERR_INTERNAL, "File", "BADDAT",
		   "Bad data value %d passed to fclose_check in fileio.c");
       return -1;
    } /* switch (data) */


    if (tf_nump() != 1) {
	tf_message (ERR_ERROR, "File", "RCLOS1",
		    "$fclose%c has only one argument - the file number, you gave %d",
		    ftype, tf_nump());
	return -1;
    }

    if (tf_typep(ARG1) != tf_readonly &&
	tf_typep(ARG1) != tf_readwrite) {
	tf_message(ERR_ERROR, "File", "RCBADA",
		   "The file number in $fclose%c must be an expression or reg",
		   ftype);
	return -1;
    }

    return 0;
} /* fclose_check */




int fclose_call()
{
    int file_num = tf_getp(ARG1);               /* File number, aka. stream   */

#ifdef DEBUG
    io_printf("fclose: stream = %d\n", file_num);
#endif

    if (file_num <= 0 || file_num >= MAX_FILES) {
	tf_message(ERR_ERROR, "File", "RCLOSB",
		   "The file number %d is out of bounds.", file_num);
        tf_putp(ARG_RET, -1);
	return -1;
    }
   	
    if (file_streams[file_num] == NULL) {
	tf_message(ERR_ERROR, "File", "RCLOSN",
		   "File number %d is not currently open.", file_num);
        tf_putp(ARG_RET, -1);
	return -1;
    }

    tf_putp(ARG_RET, close_and_free (file_num)); /* Return status EOF or 0    */
    return 0;
}





/******************************************************************************
 $fgets routines
******************************************************************************/

int fgets_check()
{
    if (tf_nump() != 3) {
	  tf_message (ERR_ERROR, "File", "RGETC1",
				  "$fgets has three arguments - string, n, and file number, you gave %d", tf_nump());
	  return -1;
    }

    if (tf_typep(ARG1) != tf_readonly &&
		tf_typep(ARG1) != tf_readwrite) {
	  tf_message(ERR_ERROR, "File", "RGARG1",
				 "The file number in $fgets must be an expression or reg");
	  return -1;
    }

    if (tf_typep(ARG2) != tf_readwrite &&
		tf_typep(ARG2) != tf_readonly) {
	  tf_message(ERR_ERROR, "File", "RGARG2",
				 "The second argument (string length) is the wrong type");
	  return -1;
    }

    if (tf_typep(ARG3) != tf_readwrite) {
	  tf_message(ERR_ERROR, "File", "RGARG3",
				 "The third argument (file number) must be a reg");
	  return -1;
    }

    return 0;
} /* fgets_check */


int fgets_call()
{
    int n = tf_getp(ARG2),                      /* String size, including null*/
	file_num = tf_getp(ARG3);               /* File number                */
    char string[MAX_STRING_SIZE],               /* String read from file      */
	*ptr;                                   /* Return value from fgets    */
    static s_acc_value avalue = {accStringVal}; /* Holds string               */
    static s_setval_delay delay_s = {{0}, accNoDelay};

    if (file_num <= 0 || file_num >= MAX_FILES) {
	tf_message(ERR_ERROR, "File", "RGETSB",
		   "The file number is out of bounds %d", file_num);
        tf_putp(ARG_RET, -1);
	return -1;
    }
   	
    if (file_streams[file_num] == NULL) {
	tf_message(ERR_ERROR, "File", "RGETSN",
		   "File number %d is not currently open.", file_num);
        tf_putp(ARG_RET, -1);
	return -1;
    }


    if (file_type[file_num] != DATA_READ) {
	tf_message(ERR_ERROR, "File", "RNOTR",
		   "File %d is not opened for read, can not do $fgets.",
		   file_num);
        tf_putp(ARG_RET, -1);
	return -1;
    }

    /* Read the string from the file, and write it into Verilog               */
    ptr = fgets(string, n, file_streams[file_num]);
#ifdef DEBUG
    io_printf("fgets: n=%d, s='%s', ptr=%x x\n", n, string, ptr);
#endif

    /* Was there any error reading the string?                                */
    if (ptr) {
	/* No error, write the sting back to Verilog and return a 1           */
	avalue.value.str = string;
	acc_set_value(acc_handle_tfarg(ARG1), &avalue, &delay_s);
        tf_putp(ARG_RET, 1);
    }
    else {
	/* There was an error, don't write anything back, and return a 0      */
        tf_putp(ARG_RET, 0);
    }

    return 0;
} /* fgets_call */




/******************************************************************************
 $gets routines
******************************************************************************/

int gets_check()
{
    if (tf_nump() != 1) {
	  tf_message (ERR_ERROR, "File", "RGETC1",
				  "$gets has one argument - string, you gave %d", tf_nump());
	  return -1;
    }

    if (tf_typep(ARG1) != tf_readonly &&
		tf_typep(ARG1) != tf_readwrite) {
	  tf_message(ERR_ERROR, "File", "RGARG1",
				 "The file number in $gets must be an expression or reg");
	  return -1;
    }

    return 0;
} /* gets_check */


int gets_call()
{
    char string[MAX_STRING_SIZE],               /* String read from file      */
	*ptr;                                   /* Return value from gets    */
    static s_acc_value avalue = {accStringVal}; /* Holds string               */
    static s_setval_delay delay_s = {{0}, accNoDelay};

    /* Read the string from the file, and write it into Verilog               */
    ptr = gets(string);
#ifdef DEBUG
    io_printf("gets: n=%d, s='%s', ptr=%x x\n", string, ptr);
#endif

    /* Was there any error reading the string?                                */
    if (ptr) {
	/* No error, write the sting back to Verilog and return a 1           */
	avalue.value.str = string;
	acc_set_value(acc_handle_tfarg(ARG1), &avalue, &delay_s);
        tf_putp(ARG_RET, 1);
    }
    else {
	/* There was an error, don't write anything back, and return a 0      */
        tf_putp(ARG_RET, 0);
    }

    return 0;
} /* gets_call */




/*******************************************************************************
 $fgetc routines
 ******************************************************************************/

int fgetc_check()
{
    if (tf_nump() != 1) {
	tf_message (ERR_ERROR, "File", "RGETC1",
		    "$fgetc has one argument - the file number");
	return -1;
    }

    if (tf_typep(ARG1) != tf_readonly &&
	tf_typep(ARG1) != tf_readwrite) {
	tf_message(ERR_ERROR, "File", "RGCARG1",
		   "The file number in $fgetc must be an expression or reg");
	return -1;
    } /* if */

    return 0;
} /* fgetc_check */



int fgetc_call()
{
    int file_num = tf_getp(ARG1),               /* File number                */
        ch;                                     /* Character read from file   */

    if (file_num <= 0 || file_num >= MAX_FILES) {
	tf_message(ERR_ERROR, "File", "RGETCB",
		   "The file number is out of bounds %d", file_num);
        tf_putp(ARG_RET, -1);
	return -1;
    }
   	
    if (file_streams[file_num] == NULL) {
	tf_message(ERR_ERROR, "File", "RGETCN",
		   "File number %d is not currently open.", file_num);
        tf_putp(ARG_RET, -1);
	return -1;
    }

    if (file_type[file_num] != DATA_READ) {
	tf_message(ERR_ERROR, "File", "RGETCN",
		   "File %d is not opened for read, can not do fgetc.",
		   file_num);
        tf_putp(ARG_RET, -1);
	return -1;
    }

    tf_putp(ARG_RET, ch = fgetc(file_streams[file_num]));  /* Return a char   */


#ifdef DEBUG
    io_printf("'%c'(%x) = fgetc(%d)\n", ch, ch, file_num);
#endif

    return 0;
} /* fgetc_call */




/*******************************************************************************
 $getchar routines
 ******************************************************************************/

int getchar_check()
{
    if (tf_nump() != 0) {
	tf_message (ERR_ERROR, "File", "RGETCHAR0",
		    "$getchar has no arguments");
	return -1;
    }

    return 0;
} /* getchar_check */



int getchar_call()
{
    int ch = getchar();                         /* Character read from stdin  */
    tf_putp(ARG_RET, ch);                       /* Return a char   */

#ifdef DEBUG
    io_printf("'%c'(%x) = getchar\n", ch, ch);
#endif

    return 0;
} /* getchar_call */




/******************************************************************************
 $ungetc routines
******************************************************************************/

int ungetc_check()
{
    if (tf_nump() != 2) {
	tf_message (ERR_ERROR, "File", "RUGET1",
		    "$ungetc has two arguments - a character and file number, you gave %d", tf_nump());
	return -1;
    }

    if (tf_typep(ARG1) != tf_readonly &&
	tf_typep(ARG1) != tf_readwrite) {
	tf_message(ERR_ERROR, "File", "RUBARG1",
		   "The first argument to $ungetc is the wrong type");
	return -1;
    }

    if (tf_typep(ARG2) != tf_readonly &&
	tf_typep(ARG2) != tf_readwrite) {
	tf_message(ERR_ERROR, "File", "RUGETS",
		   "The file number in $ungetc must be an expression or reg");
	return -1;
    }

    return 0;
} /* ungetc_check */



int ungetc_call()
{
    int ch       = tf_getp(ARG1),               /* Character to put back      */
	file_num = tf_getp(ARG2);               /* File number                */

#ifdef DEBUG
    io_printf("ungetc('%c', %d)\n", ch, file_num);
#endif

    if (file_num <= 0 || file_num >= MAX_FILES) {
	tf_message(ERR_ERROR, "File", "RUGETB",
		   "The file number is out of bounds %d", file_num);
        tf_putp(ARG_RET, -1);
	return -1;
    }
   	
    if (file_streams[file_num] == NULL) {
	tf_message(ERR_ERROR, "File", "RUGETN",
	 	   "File number %d not currently open.", file_num);
        tf_putp(ARG_RET, -1);
	return -1;
    }

    if (file_type[file_num] != DATA_READ) {
	tf_message(ERR_ERROR, "File", "RNOTR",
		   "File %d is not opened for read, can not do $ungetc.",
		   file_num);
        tf_putp(ARG_RET, -1);
	return -1;
    }

    tf_putp(ARG_RET, ungetc(ch, file_streams[file_num]));   /* Return a char  */

    return 0;
} /* ungetc_call */




/******************************************************************************
 $feof routines
******************************************************************************/

int feof_check()
{
    if (tf_nump() != 1) {
	tf_message (ERR_ERROR, "File", "REOF1",
		    "$feof has one argument - the file number, you gave %d", tf_nump());
	return -1;
    }

    if (tf_typep(ARG1) != tf_readonly &&
	tf_typep(ARG1) != tf_readwrite) {
	tf_message(ERR_ERROR, "File", "REOFS",
		   "The file number in $feof must be an expression or reg");
	return -1;
    }

    return 0;
} /* feof_check */



int feof_call()
{
    int file_num = tf_getp(ARG1);               /* File number                */

    if (file_num <= 0 || file_num >= MAX_FILES) {
	tf_message(ERR_ERROR, "File", "REOFB",
		   "The file number is out of bounds %d", file_num);
        tf_putp(ARG_RET, -1);
	return -1;
    }
   	
    if (file_streams[file_num] == NULL) {
	tf_message(ERR_ERROR, "File", "REOFN",
		   "File number %d is not currently open.", file_num);
        tf_putp(ARG_RET, -1);
	return -1;
    }
#ifdef DEBUG
    io_printf("feof(%d) = %x\n", file_num, feof(file_streams[file_num]));
#endif


    tf_putp(ARG_RET, feof(file_streams[file_num]));   /* Return 0 or non-zero */

    return 0;
} /* feof_call */



/******************************************************************************
 $ferror routines
******************************************************************************/

int ferror_check()
{
    if (tf_nump() != 1) {
	tf_message (ERR_ERROR, "File", "REOF1",
		    "$ferror has one argument - the file number, you gave %d", tf_nump());
	return -1;
    }

    if (tf_typep(ARG1) != tf_readonly &&
	tf_typep(ARG1) != tf_readwrite) {
	tf_message(ERR_ERROR, "File", "REOFS",
		   "The file number in $ferror must be an expression or reg");
	return -1;
    }

    return 0;
} /* ferror_check */



int ferror_call()
{
    int file_num = tf_getp(ARG1);               /* File number                */

    if (file_num <= 0 || file_num >= MAX_FILES) {
	tf_message(ERR_ERROR, "File", "REOFB",
		   "The file number is out of bounds %d", file_num);
        tf_putp(ARG_RET, -1);
	return -1;
    }
   	
    if (file_streams[file_num] == NULL) {
	tf_message(ERR_ERROR, "File", "REOFN",
		   "File number %d is not currently open.", file_num);
        tf_putp(ARG_RET, -1);
	return -1;
    }
#ifdef DEBUG
    io_printf("ferror(%d) = %x\n", file_num, ferror(file_streams[file_num]));
#endif

    tf_putp(ARG_RET, ferror(file_streams[file_num]));  /* Return an eror code */
    clearerr(file_streams[file_num]);                  /* Clear the eror code */

    return 0;
} /* ferror_call */



/*******************************************************************************
 $_scan_ support routines, for $fscanf, sscan, $scan
 ******************************************************************************/

/* This routine builds a list of format elements from a text string
   It is called from fscanf_check if the format string is a constant string
   It should be called from fscanf_call if the format is a reg,
   and from fscanf_misc for restarts
   */

#ifdef __cplusplus
p_fmt build_fmt_list(int format_arg_num)
#else
p_fmt build_fmt_list(format_arg_num)
	 int format_arg_num;
#endif
{
    char *format, *fmt_ptr;
    p_fmt fmt_head, fmt_tail;
    int arg_count;
   
    fmt_ptr = tf_getcstringp(format_arg_num);
    format = strcpy((char *)malloc(strlen(fmt_ptr)+1), fmt_ptr);   /* Format string   */
#ifdef DEBUG
    io_printf("fscanf format \"%s\"\n", format);
#endif

    /* Build a linked list of the elements of the format string               */
    fmt_ptr = format;
    fmt_head = fmt_tail = NULL;
    arg_count = format_arg_num;
    while (*fmt_ptr) {

	/* Create & a new fmt pointer                                         */
	p_fmt fmt = (p_fmt) malloc(sizeof(s_fmt));
	memset((void*)fmt, 0, sizeof(s_fmt));
	fmt->suppress = FALSE;
	fmt->width = -1;
	if (*fmt_ptr == '%') {
	    fmt_ptr++;
#ifdef DEBUG
	    io_printf("fmt\t%%");
#endif

	    /* Look for the * character to suppress assignment, %*d           */
	    if (*fmt_ptr == '*') {
		fmt->suppress = TRUE;
		fmt_ptr++;
#ifdef DEBUG
	    io_printf("*");
#endif

	    }

	    /* Look for a width specifier, %10d                               */
	    if(isdigit(*fmt_ptr)) {
		sscanf(fmt_ptr, "%d", &fmt->width);
		while (isdigit(*++fmt_ptr)) ;
#ifdef DEBUG
		io_printf("%d", fmt->width);
#endif
	    }

	    /* Decode the % specifier                                         */
	    /* Swallow the % for end-of-line, or unrecognized type            */
#ifdef DEBUG
	    io_printf("%c\n", *fmt_ptr);
#endif

	    switch (tolower(*fmt_ptr)) {
		case 'b':
		    fmt->type = FMT_B;
		    fmt_ptr++;
		    if (!fmt->suppress) {
			arg_count++;
			if (tf_typep(arg_count) != tf_readwrite) {
			tf_message(ERR_ERROR, "File", "RSCANF",
				   "Argument %d must be a writeable reg",
				   arg_count);		
                        free(format);
                        return NULL;
			}
		    }
		    break;
		case 'c':
		    fmt->type = FMT_C;
		    fmt_ptr++;
		    if (!fmt->suppress) {
			arg_count++;
			if (tf_typep(arg_count) != tf_readwrite) {
			tf_message(ERR_ERROR, "File", "RSCANF",
				   "Argument %d must be a writeable reg",
				   arg_count);
                        free(format);
			return NULL;
			}
		    }
		    break;
		case 'd':
		    fmt->type = FMT_D;
		    fmt_ptr++;
		    if (!fmt->suppress) {
			arg_count++;
			if (tf_typep(arg_count) != tf_readwrite) {
			tf_message(ERR_ERROR, "File", "RSCANF",
				   "Argument %d must be a writeable reg",
				   arg_count);
                        free(format);
			return NULL;
			}
		    }
		    break;

	        case 'e':
		case 'f':
	        case 'g':
		    fmt->type = FMT_F;
		    fmt_ptr++;
		    if (!fmt->suppress) {
			arg_count++;
			if (tf_typep(arg_count) != tf_readwritereal) {
			tf_message(ERR_ERROR, "File", "RSCANF",
				   "Argument %d must be a writeable real",
				   arg_count);
                        free(format);
			return NULL;
			}
		    }
		    break;
		case 'o':
		    fmt->type = FMT_O;
		    fmt_ptr++;
		    if (!fmt->suppress) {
			arg_count++;
			if (tf_typep(arg_count) != tf_readwrite) {
			tf_message(ERR_ERROR, "File", "RSCANF",
				   "Argument %d must be a writeable reg",
				   arg_count);
                        free(format);
			return NULL;
			}
		    }
		    break;
		case 'r':
		    fmt->type = FMT_R;
		    fmt_ptr++;
		    if (!fmt->suppress) {
			arg_count++;
			if (tf_typep(arg_count) != tf_readwrite) {
			tf_message(ERR_ERROR, "File", "RSCANF",
				   "Argument %d must be a writeable reg",
				   arg_count);
                        free(format);
			return NULL;
			}
		    }
		    break;
		case 's':
		    fmt->type = FMT_S;
		    fmt_ptr++;
		    if (!fmt->suppress) {
			arg_count++;
			if (tf_typep(arg_count) != tf_readwrite) {
			tf_message(ERR_ERROR, "File", "RSCANF",
				   "Argument %d must be a writeable reg",
				   arg_count);
                        free(format);
			return NULL;
			}
		    }
		    break;
	        case 'h':
		case 'x':
		    fmt->type = FMT_X;
		    fmt_ptr++;
		    if (!fmt->suppress) {
			arg_count++;
			if (tf_typep(arg_count) != tf_readwrite) {
			tf_message(ERR_ERROR, "File", "RSCANF",
				   "Argument %d must be a writeable reg",
				   arg_count);
                        free(format);
			return NULL;
			}
		    }
		    break;

	        case '%':
		    fmt->type = FMT_PERCENT;
		    fmt_ptr++;
		    break;

	        case '\0': 
		  /* ignore trailing %                                        */
		  break;

		default: 
		  /* printf(">>>> build_fmt_list default: %c\n", *fmt_ptr); */
		  break;
		} /* case fmt_ptr */

	    /* Back off the arg count if we have a suppress                   */

	} /* if '%' */

	else if (isspace(*fmt_ptr)) {
#ifdef DEBUG
	    io_printf("fmt\t<space>\n");
#endif
	    fmt->type = FMT_SPACE;
	    while (isspace(*++fmt_ptr) && *fmt_ptr) ;
	}

	else {
	    /* Copy the text string until the next white space or %           */
	    char *start = fmt_ptr++,
		*substr;
	    int len;

	    while (!isspace(*fmt_ptr) && *fmt_ptr != '%' && *fmt_ptr)
		fmt_ptr++;

	    len = (int) (fmt_ptr - start);
	    substr = strncpy ((char *)malloc(len+1), start, len);
	    substr[len] = 0;

#ifdef DEBUG
	    io_printf ("fmt\t'%s'\n", substr);
#endif

	    fmt->type = FMT_STRING;
	    fmt->string = substr;
	}

	/* Now link this format item into the list of elements                */
	if (fmt_tail) {
	    fmt_tail->next_ele = fmt;
	    fmt_tail = fmt;
	}
	else {
	    fmt_head = fmt_tail = fmt;
	}

	fmt->next_ele = NULL;
    } /* while */


    /* Check that the number of formatting commands such as %d, match the     */
    /* number of params passed to $fscanf, including stream and format string */
    if (arg_count != tf_nump()) {
	tf_message (ERR_ERROR, "File", "RSCANN",
		    "$fscanf was passed the wrong number of variables for the format string");
        free(format);
	return NULL;
    }

    free(format);

    /* Return the head of the format list                                     */
    return fmt_head;
} /* build_fmt_list */


#ifdef __cplusplus
void free_fmt_list (p_fmt fmt)
#else
void free_fmt_list (fmt)
    p_fmt fmt;
#endif
{
    p_fmt next;

    /* Free any format lists and strings from the old model                   */
    while (fmt) {
	next = fmt->next_ele;
	if (fmt->type == FMT_STRING)
	    free (fmt->string);
	free (fmt);
	fmt = next;
    }
} /* free_fmt_list */


/*******************************************************************************
 $fscanf routines
 ******************************************************************************/

int fscanf_check()
{
    if (tf_nump() < 2) {
	tf_message (ERR_ERROR, "File", "RSCANF",
		    "$fscanf must have at least two arguments - the file number and format, you gave %d", tf_nump());
	return -1;
    }

    if (tf_typep(ARG1) != tf_readonly &&
	tf_typep(ARG1) != tf_readwrite) {
	tf_message(ERR_ERROR, "File", "RSCANS",
		   "The file number in $fscanf must be an expression or reg");
	return -1;
    }

    if (tf_typep(ARG2) != tf_string &&
	tf_typep(ARG2) != tf_readwrite) {
	tf_message(ERR_ERROR, "File", "RSCANF",
		   "The format must be a string or a constant");
	return -1;
    }


    /* Store the head of the format list in the workarea for this instance    */
    if (tf_typep(ARG2) == tf_string) {
	tf_setworkarea ((char *) build_fmt_list(ARG2));
    }
    else tf_setworkarea ((char *) 0);

    return 0;
} /* fscanf_check */





/*******************************************************************************
   Scan through the input line, and assign to the arguments to the $fscanf
   task.  Note that arg_count starts at 2 to skip over the stream and
   format string.
   */
int fscanf_call()
{
    p_fmt fmt = (p_fmt) tf_getworkarea(),       /* Format list fscanf_check   */
	fmt_head;
    char fmt_str[20];                           /* Holds format for fscanf    */
    int arg_count,                              /* Arg number + 2             */
	retval;                                 /* Return value from fscanf   */
    static char arg[MAX_STRING_SIZE] = {"0"};   /* String from fscanf         */
    float argf;                                 /* Floating point argument    */
    static s_acc_value avalue = {accIntVal};    /* Holds argument value       */
    static s_setval_delay delay_s = {{0}, accNoDelay};
    int file_num = tf_getp(ARG1);               /* File stream number         */


    if (file_num <= 0 || file_num >= MAX_FILES) {
	tf_message(ERR_ERROR, "File", "REOFB",
		   "The file number is out of bounds %d", file_num);
#ifndef scanf_task
        tf_putp(ARG_RET, -1);
#endif
	return -1;
    }
   	
    if (file_streams[file_num] == NULL) {
	tf_message(ERR_ERROR, "File", "REOFN",
		   "File number %d is not currently open.", file_num);
#ifndef scanf_task
        tf_putp(ARG_RET, -1);
#endif
	return -1;
    }

    if (file_type[file_num] != DATA_READ) {
	tf_message(ERR_ERROR, "File", "RNOTR",
		   "File %d is not opened for read, can not do $fscanf.",
		   file_num);
#ifndef scanf_task
        tf_putp(ARG_RET, -1);
#endif
	return -1;
    }

    /* If the format string is stored in a reg, build the fmt list on the fly */
    if (tf_typep(ARG2) == tf_readwrite) {
	fmt = fmt_head = build_fmt_list(ARG2);
    }


    /* Loop though the pre-digested format string and scan away...            */
    avalue.value.str = arg;
    arg_count = 2;
    while (fmt) {

	/* What type of format argument is this?                              */
	switch (fmt->type) {

	case FMT_B: /* Binary */
	    /* Read in the next argument from the file                        */
	    /* If the argument has a width, %5b, create a special format      */
	    /* Leading white space in input stream must be explicitly skipped
                when scanning with %[] */
	    if (fmt->width == -1)
		retval = fscanf(file_streams[file_num], " %[01xXzZ?_]", arg);
	    else {
		sprintf(fmt_str, " %%%d[01xXzZ??_]", fmt->width);
		retval = fscanf(file_streams[file_num], fmt_str, arg);
	    }
#ifdef DEBUG
	    io_printf("\t%%B %d: %s\n", arg_count, arg);
#endif
	    /* If we are not suppressing assignment, as in %*b,
	       and fscanf actually found something, write to the arg         */
	    if (!fmt->suppress && retval > 0) {
		avalue.format = accBinStrVal;
		acc_set_value(acc_handle_tfarg(++arg_count), &avalue, &delay_s);
	    }
	    break;


	case FMT_C:
	    if (fmt->width == -1)
		retval = fscanf(file_streams[file_num], "%c", arg);
	    else {
		sprintf(fmt_str, "%%%dc", fmt->width);
		retval = fscanf(file_streams[file_num], fmt_str, arg);
	    }
#ifdef DEBUG
	    io_printf("\t%%C %d: '%c'=%x\n", arg_count, arg, *arg);
#endif
	    if (!fmt->suppress && retval > 0) {
		avalue.format = accStringVal;
		/* Add a 0 after the last char as the above fscanf("%c")
		   doesn't. Can't use %s above as it skips initial whitespace */
		if (fmt->width == -1) arg[1] = '\0';
		else arg[fmt->width] = '\0';
		acc_set_value(acc_handle_tfarg(++arg_count), &avalue, &delay_s);
	    }
	    break;


	case FMT_D:
	    /* Z & X not allowed in decimal numbers but +/- are               */
	    /* Leading white space in input stream must be explicitly skipped
                when scanning with %[] */
	    if (fmt->width == -1)
		retval = fscanf(file_streams[file_num], " %[-+0-9_]", arg);
	    else {
		sprintf(fmt_str, " %%%d[+-0-9_]", fmt->width);
		retval = fscanf(file_streams[file_num], fmt_str, arg);
	    }
#ifdef DEBUG
	    io_printf("\t%%D %d: '%s', r = %d\n", arg_count, arg, retval);
#endif
	    if (!fmt->suppress && retval > 0) {
		avalue.format = accDecStrVal;
		acc_set_value(acc_handle_tfarg(++arg_count), &avalue, &delay_s);
	    }
	    break;


	case FMT_F:
	    if (fmt->width == -1)
		retval = fscanf(file_streams[file_num], "%f", &argf);
	    else {
		sprintf(fmt_str, "%%%df", fmt->width);
		retval = fscanf(file_streams[file_num], fmt_str, &argf);
	    }

#ifdef DEBUG
	    io_printf("\t%%F %d: %f, r = %d\n", arg_count, argf, retval);
#endif
	    if (!fmt->suppress && retval > 0) {
		avalue.format = accRealVal;
		avalue.value.real = argf;
		acc_set_value(acc_handle_tfarg(++arg_count), &avalue, &delay_s);
		/* Set the value block back to pointing to string             */
		avalue.value.str = arg;
	    }
	    break;


	case FMT_O:
	    if (fmt->width == -1)
		retval = fscanf(file_streams[file_num], " %[0-7xXzZ?_]", arg);
	    else {
		sprintf(fmt_str, " %%%d[0-7xXzZ?_]", fmt->width);
		retval = fscanf(file_streams[file_num], fmt_str, arg);
	    }
#ifdef DEBUG
	    io_printf("\t%%O %d: %s\n", arg_count, arg);
#endif
	    if (!fmt->suppress && retval > 0) {
		avalue.format = accOctStrVal;
		acc_set_value(acc_handle_tfarg(++arg_count), &avalue, &delay_s);
	    }
	    break;

	case FMT_R:
	    arg_count++;
	    /* Not yet implemented, will read 32'hABCD_XZ01 */
	    break;


	case FMT_S:
	    if (fmt->width == -1)
		retval = fscanf(file_streams[file_num], "%s", arg);
	    else {
		sprintf(fmt_str, "%%%ds", fmt->width);
		retval = fscanf(file_streams[file_num], fmt_str, arg);
	    }

#ifdef DEBUG
	    io_printf("\t%%S %d: %s\n", arg_count, arg);
#endif
	    if (!fmt->suppress && retval > 0) {
		avalue.format = accStringVal;
		acc_set_value(acc_handle_tfarg(++arg_count), &avalue, &delay_s);
	    }
	    break;

	case FMT_X:
	    if (fmt->width == -1)
		retval = fscanf(file_streams[file_num], " %[0-9a-fA-FxXzZ?_]", arg);
	    else {
		sprintf(fmt_str, " %%%d[0-9a-fA-FxXzZ?_]", fmt->width);
		retval = fscanf(file_streams[file_num], fmt_str, arg);
	    }
#ifdef DEBUG
	    io_printf("\t%%X %d: %s\n",  arg_count, arg);
#endif
	    if (!fmt->suppress && retval > 0) {
		avalue.format = accHexStrVal;
		acc_set_value(acc_handle_tfarg(++arg_count), &avalue, &delay_s);
	    }
	    break;

	case FMT_SPACE:
	    retval = fscanf(file_streams[file_num], " ");
	    /* Set retval to look like a successful assignment                */
#ifdef MTI
	    retval = 1;  /* MTI on PC reads past whitespace to EOF            */
#else
	    if (retval != EOF) retval = 1;
#endif
#ifdef DEBUG
	    io_printf("\t<Space>\n");
#endif
	    break;

	case FMT_STRING:
	    retval = fscanf(file_streams[file_num], fmt->string, arg);
	    /* Set retval to look like a successful assignment                */
	    if (retval != EOF) retval = 1;
#ifdef DEBUG
	    io_printf("\tStr: '%s'\n", arg);
#endif
	    break;

	default:
	    /* Internal error - unknown format type                           */
	    tf_message(ERR_INTERNAL, "File", "FSCANI",
		       "Unknown $fscanf format type = %d.", fmt->type);
	    return -1;

	} /* switch */

	/* If EOF, return prematurely with the number of args read            */
	if (retval == EOF) {
#ifdef DEBUG
	    io_printf("fscanf hit EOF\n");
#endif
	    break;
	}

	/* If fscanf failed (ie. %d from 'ABC'), break & return # args read  */
	if (retval == 0) {
#ifdef DEBUG
	    io_printf("fscanf returned early = %d\n", retval);
#endif
	    break;
	}

	fmt = fmt->next_ele;
    } /* while */

    /* If the format string is stored in a reg, free the fmt list             */
    if (tf_typep(ARG2) == tf_readwrite) {
	free_fmt_list(fmt_head);
    }

#ifdef DEBUG
    io_printf("fscanf returns %d\n", arg_count - 2);
#endif
#ifndef scanf_task
    tf_putp(ARG_RET, arg_count - 2);        /* Return argment count           */
#endif

    return 0;
} /* fscanf_call */




#ifdef __cplusplus
int fscanf_misc (int data, int reason)
#else
int fscanf_misc (data, reason)
    int data, reason;
#endif
{
#ifdef SAVE
    switch (reason) {

    case reason_startofrestart:
#ifdef DEBUG
	io_printf("fscanf_misc startofrestart instance %d\n", tf_getinstance());
#endif
	/* Free any format lists and strings from the old model               */
	free_fmt_list((p_fmt) tf_getworkarea());
	break;


    case reason_restart:
#ifdef DEBUG
	io_printf("fscanf_misc, restart, instance %d\n", tf_getinstance());
#endif
	/* Store the head of the format list in the workarea for this
	   instance of $fscanf in the new model                               */
	if (tf_typep(ARG2) == tf_string) {
	    tf_setworkarea ((char *) build_fmt_list(ARG2));
	}
	break;

    } /* switch (reason) */

#endif

    return 0;
}
/* fscanf_misc */














/*******************************************************************************
 $sscanf routines
 ******************************************************************************/

int sscanf_check()
{
    if (tf_nump() < 2) {
	tf_message (ERR_ERROR, "File", "RSSA2",
		    "$sscanf must have at least two arguments - the string and format, you gave %d", tf_nump());
	return -1;
    }

    if (tf_typep(ARG1) != tf_readonly &&
	tf_typep(ARG1) != tf_readwrite &&
	tf_typep(ARG1) != tf_string) {
	tf_message(ERR_ERROR, "File", "RSSS",
		   "The string argument must be a reg, expression, or string");
	return -1;
    }

    if (tf_typep(ARG2) != tf_string &&
	tf_typep(ARG2) != tf_readwrite) {
	tf_message(ERR_ERROR, "File", "RSSF",
		   "The format must be a string or a constant");
	return -1;
    }


    /* Store the head of the format list in the workarea for this instance    */
    if (tf_typep(ARG2) == tf_string) {
	tf_setworkarea ((char *) build_fmt_list(ARG2));
    }
    else tf_setworkarea ((char *) 0);

    return 0;
} /* sscanf_check */






/*******************************************************************************
   Scan through the string, and assign to the arguments to the $sscanf
   task.  Note that arg_count starts at 2 to skip over the stream and
   format string.
   */
int sscanf_call()
{
    p_fmt fmt = (p_fmt) tf_getworkarea(),       /* Format list sscanf_check   */
	fmt_head;
    char fmt_str[20];                           /* Holds format for sscanf    */
    int arg_count,                              /* Arg number + 2             */
	retval;                                 /* Return value from sscanf   */
    static char arg[MAX_STRING_SIZE];           /* String from sscanf         */
    static s_acc_value avalue = {accIntVal};    /* Holds argument value       */
    static s_setval_delay delay_s = {{0}, accNoDelay};
    char *s = tf_getcstringp(ARG1),             /* String to be parsed        */
	*ptr, *original;
	
    /* Copy the string to be parsed as further acc calls may overwrite it     */
    original = ptr = strcpy ((char *)malloc (strlen (s) + 1), s);

    /* If the format string is stored in a reg, build the fmt list on the fly */
    if (tf_typep(ARG2) == tf_readwrite) {
	fmt = fmt_head = build_fmt_list(ARG2);
    }

    /* Loop though the pre-digested format string and scan away...            */
    avalue.value.str = arg;
    arg_count = 2;
    while (fmt) {

        /* Do not advance string ptr if we don't match                        */
        *arg = 0;

	/* What type of format argument is this?                              */
	switch (fmt->type) {

	case FMT_B: /* Binary */
	    /* Read in the next argument from the file                        */
	    /* If the argument has a width, %5b, create a special format      */
	    /* Leading white space in input stream must be explicitly skipped
                when scanning with %[] */
	    if (fmt->width == -1)
		retval = sscanf(ptr, " %[01xXzZ?_]", arg);
	    else {
		sprintf(fmt_str, " %%%d[01xXzZ?_]", fmt->width);
		retval = sscanf(ptr, fmt_str, arg);
	    }
	    /* Advance the string pointer by the size of what we just read    */
	    ptr = ptr + strlen(arg);
#ifdef DEBUG
	    io_printf("B %d: %s\n", arg_count, arg);
#endif
	    /* If we are not suppressing assignment, as in %*b,
	       and sscanf actually found something, write to the arg          */
	    if (!fmt->suppress && retval > 0) {
		avalue.format = accBinStrVal;
		acc_set_value(acc_handle_tfarg(++arg_count), &avalue, &delay_s);
	    }
	    break;


	case FMT_C:
	    if (fmt->width == -1)
		retval = sscanf(ptr, "%c", arg);
	    else {
		sprintf(fmt_str, "%%%dc", fmt->width);
		retval = sscanf(ptr, fmt_str, arg);
	    }
	    ptr = ptr + strlen(arg);
#ifdef DEBUG
	    io_printf("C %d: %c\n", arg_count, arg);
#endif
	    if (!fmt->suppress && retval > 0) {
		avalue.format = accStringVal;
		/* Add a 0 after the last char as the above fscanf("%c")
		   doesn't. Can't use %s above as it skips initial whitespace */
		if (fmt->width == -1) arg[1] = '\0';
		else arg[fmt->width] = '\0';
		acc_set_value(acc_handle_tfarg(++arg_count), &avalue, &delay_s);
	    }
	    break;


	case FMT_D:
	    /* Z & X not allowed in decimal numbers                           */
	    /* Leading white space in input stream must be explicitly skipped
                when scanning with %[] */
	    if (fmt->width == -1)
		retval = sscanf(ptr, " %[+-0-9_]", arg);
	    else {
		sprintf(fmt_str, " %%%d[+-0-9_]", fmt->width);
		retval = sscanf(ptr, fmt_str, arg);
	    }
	    ptr = ptr + strlen(arg);
#ifdef DEBUG
	    io_printf("%d %%D: '%s', r = %d\n", arg_count, arg, retval);
#endif
	    if (!fmt->suppress && retval > 0) {
		avalue.format = accDecStrVal;
		acc_set_value(acc_handle_tfarg(++arg_count), &avalue, &delay_s);
	    }
	    break;


	case FMT_F:
	    /* We don't support %f in $sscan as I can not figure how big
	       the field is.  If I converted the $sscanf into one big sscanf
	       I wouldn't have this problem.                                  */
	    tf_message(ERR_ERROR, "File", "SSFNOS",
		       "$sscanf does not support %%f.");
	    return -1;


	case FMT_O:
	    if (fmt->width == -1)
		retval = sscanf(ptr, " %[0-7xXzZ?_]", arg);
	    else {
		sprintf(fmt_str, " %%%d[0-7xXzZ?_]", fmt->width);
		retval = sscanf(ptr, fmt_str, arg);
	    }
	    ptr = ptr + strlen(arg);
#ifdef DEBUG
	    io_printf("O %d: %s\n", arg_count, arg);
#endif
	    if (!fmt->suppress && retval > 0) {
		avalue.format = accOctStrVal;
		acc_set_value(acc_handle_tfarg(++arg_count), &avalue, &delay_s);
	    }
	    break;

	case FMT_R:
	    arg_count++;
	    /* Not yet implemented, will read 32'hABCD_XZ01 */
	    break;


	case FMT_S:
	    if (fmt->width == -1)
		retval = sscanf(ptr, "%s", arg);
	    else {
		sprintf(fmt_str, "%%%ds", fmt->width);
		retval = sscanf(ptr, fmt_str, arg);
	    }
	    ptr = ptr + strlen(arg);
#ifdef DEBUG
	    io_printf("S %d: %s\n", arg_count, arg);
#endif
	    if (!fmt->suppress && retval > 0) {
		avalue.format = accStringVal;
		acc_set_value(acc_handle_tfarg(++arg_count), &avalue, &delay_s);
	    }
	    break;

	case FMT_X:
	    if (fmt->width == -1)
		retval = sscanf(ptr, " %[0-9a-fA-FxXzZ?_]", arg);
	    else {
		sprintf(fmt_str, " %%%d[0-9a-fA-FxXzZ?_]", fmt->width);
		retval = sscanf(ptr, fmt_str, arg);
	    }
	    ptr = ptr + strlen(arg);
#ifdef DEBUG
	    io_printf("X %d: %s\n",  arg_count, arg);
#endif
	    if (!fmt->suppress && retval > 0) {
		avalue.format = accHexStrVal;
		acc_set_value(acc_handle_tfarg(++arg_count), &avalue, &delay_s);
	    }
	    break;

	case FMT_SPACE:
	    if (*ptr && isspace(*ptr) ) {
	       retval = 1;
	       while (*ptr && isspace(*ptr) ) ptr++ ;
            }
	    else retval = EOF;
#ifdef DEBUG
	    io_printf("Space\n");
#endif
	    break;

	case FMT_STRING:
            if (*ptr && *fmt->string) {
	      char *fstr = fmt->string;
               retval = 1;
               while(*ptr && (*ptr == *fstr)) {
                  ++ptr;
                  ++fstr;
               }
            }
            else retval = EOF;
#ifdef DEBUG
	    io_printf("Str: %s\n", ptr);
#endif
	    break;

	default:
	    /* Internal error - unknown format type                           */
	    tf_message(ERR_INTERNAL, "File", "SSCANI",
		       "Unknown $sscanf format type = %d.", fmt->type);
	    return -1;

	} /* switch */

	/* If EOF, return prematurely with the number of args read            */
	if (retval == EOF) {
#ifdef DEBUG
	    io_printf("sscanf hit EOF\n");
#endif
	    break;
	}

	/* If sscanf failed (ie. %d from 'ABC'), break & return # args read  */
	if (retval == 0) {
#ifdef DEBUG
	    io_printf("sscanf returned early = %d\n", retval);
#endif
	    break;
	}


	fmt = fmt->next_ele;
    } /* while */

    /* If the format string is stored in a reg, free the fmt list             */
    if (tf_typep(ARG2) == tf_readwrite) {
	free_fmt_list(fmt_head);
    }

    /* Free the memory used to store the input string                         */
    free(original);

#ifdef DEBUG
    io_printf("sscanf returns %d\n", arg_count - 2);
#endif
#ifndef scanf_task
    tf_putp(ARG_RET, arg_count - 2);        /* Return argment count           */
#endif

    return 0;
} /* sscanf_call */




#ifdef __cplusplus
int sscanf_misc (int data, int reason)
#else
int sscanf_misc (data, reason)
    int data, reason;
#endif
{
#ifdef SAVE
    switch (reason) {

    case reason_startofrestart:
#ifdef DEBUG
	io_printf("sscanf_misc startofrestart instance %d\n", tf_getinstance());
#endif
	/* Free any format lists and strings from the old model               */
	free_fmt_list((p_fmt) tf_getworkarea());
	break;


    case reason_restart:
#ifdef DEBUG
	io_printf("sscanf_misc, restart, instance %d\n", tf_getinstance());
#endif
	/* Store the head of the format list in the workarea for this
	   instance of $sscanf in the new model                               */
	if (tf_typep(ARG2) == tf_string) {
	    tf_setworkarea ((char *) build_fmt_list(ARG2));
	}
	break;



    } /* switch (reason) */
#endif

    return 0;
} /* sscanf_misc */





/*******************************************************************************
 $scanf routines
 ******************************************************************************/

int scanf_check()
{
    if (tf_nump() < 1) {
	tf_message (ERR_ERROR, "File", "RSCANF",
		    "$scanf must have at least one argument - the format, you gave %d", tf_nump());
	return -1;
    }

    if (tf_typep(ARG1) != tf_string &&
	tf_typep(ARG1) != tf_readwrite) {
	tf_message(ERR_ERROR, "File", "RSCANF",
		   "The format must be a string or a constant");
	return -1;
    }


    /* Store the head of the format list in the workarea for this instance    */
    if (tf_typep(ARG1) == tf_string) {
	tf_setworkarea ((char *) build_fmt_list(ARG1));
    }
    else tf_setworkarea ((char *) 0);

	return 0;
} /* scanf_check */



/*******************************************************************************
   Scan through the input line, and assign to the arguments to the $scanf
   task.  Note that arg_count starts at 1 to skip over the format string.
   */
int scanf_call()
{
    p_fmt fmt = (p_fmt) tf_getworkarea(),       /* Format list scanf_check   */
	fmt_head;
    char fmt_str[20];                           /* Holds format for scanf    */
    int arg_count,                              /* Arg number + 1             */
	retval;                                 /* Return value from scanf   */
    static char arg[MAX_STRING_SIZE] = {"0"};   /* String from scanf         */
    float argf;                                 /* Floating point argument    */
    static s_acc_value avalue = {accIntVal};    /* Holds argument value       */
    static s_setval_delay delay_s = {{0}, accNoDelay};

    /* If the format string is stored in a reg, build the fmt list on the fly */
    if (tf_typep(ARG1) == tf_readwrite) {
	fmt = fmt_head = build_fmt_list(ARG1);
    }


    /* Loop though the pre-digested format string and scan away...            */
    avalue.value.str = arg;
    arg_count = 1;
    while (fmt) {

	/* What type of format argument is this?                              */
	switch (fmt->type) {

	case FMT_B: /* Binary */
	    /* Read in the next argument from the file                        */
	    /* If the argument has a width, %5b, create a special format      */
	    /* Leading white space in input stream must be explicitly skipped
                when scanning with %[] */
	    if (fmt->width == -1)
		retval = scanf(" %[01xXzZ?_]", arg);
	    else {
		sprintf(fmt_str, " %%%d[01xXzZ??_]", fmt->width);
		retval = scanf(fmt_str, arg);
	    }
#ifdef DEBUG
	    io_printf("\t%%B %d: %s\n", arg_count, arg);
#endif
	    /* If we are not suppressing assignment, as in %*b,
	       and scanf actually found something, write to the arg         */
	    if (!fmt->suppress && retval > 0) {
		avalue.format = accBinStrVal;
		acc_set_value(acc_handle_tfarg(++arg_count), &avalue, &delay_s);
	    }
	    break;


	case FMT_C:
	    if (fmt->width == -1)
		retval = scanf("%c", arg);
	    else {
		sprintf(fmt_str, "%%%dc", fmt->width);
		retval = scanf(fmt_str, arg);
	    }
#ifdef DEBUG
	    io_printf("\t%%C %d: '%c'=%x\n", arg_count, arg, *arg);
#endif
	    if (!fmt->suppress && retval > 0) {
		avalue.format = accStringVal;
		/* Add a 0 after the last char as the above scanf("%c")
		   doesn't. Can't use %s above as it skips initial whitespace */
		if (fmt->width == -1) arg[1] = '\0';
		else arg[fmt->width] = '\0';
		acc_set_value(acc_handle_tfarg(++arg_count), &avalue, &delay_s);
	    }
	    break;


	case FMT_D:
	    /* Z & X not allowed in decimal numbers but +/- are               */
	    /* Leading white space in input stream must be explicitly skipped
                when scanning with %[] */
	    if (fmt->width == -1)
		retval = scanf(" %[+-0-9_]", arg);
	    else {
		sprintf(fmt_str, " %%%d[+-0-9_]", fmt->width);
		retval = scanf(fmt_str, arg);
	    }
#ifdef DEBUG
	    io_printf("\t%%D %d: '%s', r = %d\n", arg_count, arg, retval);
#endif
	    if (!fmt->suppress && retval > 0) {
		avalue.format = accDecStrVal;
		acc_set_value(acc_handle_tfarg(++arg_count), &avalue, &delay_s);
	    }
	    break;


	case FMT_F:
	    if (fmt->width == -1)
		retval = scanf("%f", &argf);
	    else {
		sprintf(fmt_str, "%%%df", fmt->width);
		retval = scanf(fmt_str, &argf);
	    }

#ifdef DEBUG
	    io_printf("\t%%F %d: %f, r = %d\n", arg_count, argf, retval);
#endif
	    if (!fmt->suppress && retval > 0) {
		avalue.format = accRealVal;
		avalue.value.real = argf;
		acc_set_value(acc_handle_tfarg(++arg_count), &avalue, &delay_s);
		/* Set the value block back to pointing to string             */
		avalue.value.str = arg;
	    }
	    break;


	case FMT_O:
	    if (fmt->width == -1)
		retval = scanf(" %[0-7xXzZ?_]", arg);
	    else {
		sprintf(fmt_str, " %%%d[0-7xXzZ?_]", fmt->width);
		retval = scanf(fmt_str, arg);
	    }
#ifdef DEBUG
	    io_printf("\t%%O %d: %s\n", arg_count, arg);
#endif
	    if (!fmt->suppress && retval > 0) {
		avalue.format = accOctStrVal;
		acc_set_value(acc_handle_tfarg(++arg_count), &avalue, &delay_s);
	    }
	    break;

	case FMT_R:
	    arg_count++;
	    /* Not yet implemented, will read 32'hABCD_XZ01 */
	    break;


	case FMT_S:
	    if (fmt->width == -1)
		retval = scanf("%s", arg);
	    else {
		sprintf(fmt_str, "%%%ds", fmt->width);
		retval = scanf(fmt_str, arg);
	    }

#ifdef DEBUG
	    io_printf("\t%%S %d: %s\n", arg_count, arg);
#endif
	    if (!fmt->suppress && retval > 0) {
		avalue.format = accStringVal;
		acc_set_value(acc_handle_tfarg(++arg_count), &avalue, &delay_s);
	    }
	    break;

	case FMT_X:
	    if (fmt->width == -1)
		retval = scanf(" %[0-9a-fA-FxXzZ?_]", arg);
	    else {
		sprintf(fmt_str, " %%%d[0-9a-fA-FxXzZ?_]", fmt->width);
		retval = scanf(fmt_str, arg);
	    }
#ifdef DEBUG
	    io_printf("\t%%X %d: %s\n",  arg_count, arg);
#endif
	    if (!fmt->suppress && retval > 0) {
		avalue.format = accHexStrVal;
		acc_set_value(acc_handle_tfarg(++arg_count), &avalue, &delay_s);
	    }
	    break;

	case FMT_SPACE:
	    retval = scanf(" ");
	    /* Set retval to look like a successful assignment                */
#ifdef MTI
	    retval = 1;  /* MTI on PC reads past whitespace to EOF            */
#else
	    if (retval != EOF) retval = 1;
#endif
#ifdef DEBUG
	    io_printf("\t<Space>\n");
#endif
	    break;

	case FMT_STRING:
	    retval = scanf(fmt->string, arg);
	    /* Set retval to look like a successful assignment                */
	    if (retval != EOF) retval = 1;
#ifdef DEBUG
	    io_printf("\tStr: '%s'\n", arg);
#endif
	    break;

	default:
	    /* Internal error - unknown format type                           */
	    tf_message(ERR_INTERNAL, "File", "FSCANI",
		       "Unknown $scanf format type = %d.", fmt->type);
	    return -1;

	} /* switch */

	/* If EOF, return prematurely with the number of args read            */
	if (retval == EOF) {
#ifdef DEBUG
	    io_printf("scanf hit EOF\n");
#endif
	    break;
	}

	/* If scanf failed (ie. %d from 'ABC'), break & return # args read  */
	if (retval == 0) {
#ifdef DEBUG
	    io_printf("scanf returned early = %d\n", retval);
#endif
	    break;
	}

	fmt = fmt->next_ele;
    } /* while */

    /* If the format string is stored in a reg, free the fmt list             */
    if (tf_typep(ARG1) == tf_readwrite) {
	free_fmt_list(fmt_head);
    }

#ifdef DEBUG
    io_printf("scanf returns %d\n", arg_count - 1);
#endif
#ifndef scanf_task
    tf_putp(ARG_RET, arg_count - 1);        /* Return argment count           */
#endif

	return 0;
} /* scanf_call */




#ifdef __cplusplus
int scanf_misc (int data, int reason)
#else
int scanf_misc (data, reason)
    int data, reason;
#endif
{
#ifdef SAVE
    switch (reason) {

    case reason_startofrestart:
#ifdef DEBUG
	io_printf("scanf_misc startofrestart instance %d\n", tf_getinstance());
#endif
	/* Free any format lists and strings from the old model               */
	free_fmt_list((p_fmt) tf_getworkarea());
	break;


    case reason_restart:
#ifdef DEBUG
	io_printf("scanf_misc, restart, instance %d\n", tf_getinstance());
#endif
	/* Store the head of the format list in the workarea for this
	   instance of $scanf in the new model                               */
	if (tf_typep(ARG1) == tf_string) {
	    tf_setworkarea ((char *) build_fmt_list(ARG1));
	}
	break;

    } /* switch (reason) */

#endif

	return 0;
}
/* scanf_misc */





/*******************************************************************************
 $ftell routines
 ******************************************************************************/

int ftell_check()
{
    if (tf_nump() != 1) {
	tf_message (ERR_ERROR, "File", "RTELL1",
		    "$ftell has one argument - the file number, you gave %d", tf_nump());
	return -1;
    }

    if (tf_typep(ARG1) != tf_readonly &&
	tf_typep(ARG1) != tf_readwrite) {
	tf_message(ERR_ERROR, "File", "RTARG1",
		   "The file number in $ftell must be an expression or reg");
	return -1;
    } /* if */

    return 0;
} /* ftell_check */



int ftell_call()
{
    int file_num = tf_getp(ARG1),
      position;

    if (file_num <= 0 || file_num >= MAX_FILES) {
	tf_message(ERR_ERROR, "File", "RTELLB",
		   "The file number is out of bounds %d", file_num);
        tf_putp(ARG_RET, -1);
	return -1;
    }
   	
    if (file_streams[file_num] == NULL) {
	tf_message(ERR_ERROR, "File", "RTELLN",
		   "File number %d is not currently open.", file_num);
        tf_putp(ARG_RET, -1);
	return -1;
    }

    if (file_type[file_num] != DATA_READ) {
	tf_message(ERR_ERROR, "File", "RNOTR",
		   "File %d is not opened for read, can not do $ftell.",
		   file_num);
        tf_putp(ARG_RET, -1);
	return -1;
    }

    position = ftell(file_streams[file_num]);  /* Find file position */

#ifdef DEBUG
    io_printf("%d = $ftell(file:%d)\n", position, file_num);
#endif

    tf_putp(ARG_RET, position);  /* Return file position */


    return 0;
} /* ftell_call */



/*******************************************************************************
 $fseek routines
 ******************************************************************************/

int fseek_check()
{
    if (tf_nump() != 3) {
	tf_message (ERR_ERROR, "File", "RSEEK3",
		    "$fseek has three arguments - the file number, position, and wherefrom, you gave %d", tf_nump());
	return -1;
    }

    if (tf_typep(ARG1) != tf_readonly &&
	tf_typep(ARG1) != tf_readwrite) {
	tf_message(ERR_ERROR, "File", "RTARG1",
		   "The file number in $fseek must be an expression or reg");
	return -1;
    } /* if */

    if (tf_typep(ARG2) != tf_readonly &&
	tf_typep(ARG2) != tf_readwrite) {
	tf_message(ERR_ERROR, "File", "RTARG1",
		   "The position for $fseek must be an expression or reg");
	return -1;
    } /* if */

    if (tf_typep(ARG3) != tf_readonly &&
	tf_typep(ARG3) != tf_readwrite) {
	tf_message(ERR_ERROR, "File", "RTARG1",
		   "The wherefrom for $fseek must be an expression or reg");
	return -1;
    } /* if */

    return 0;
} /* fseek_check */





int fseek_call()
{
    int file_num = tf_getp(ARG1),
	position = tf_getp(ARG2),
	wherefrom = tf_getp(ARG3),
        retval;

    if (file_num <= 0 || file_num >= MAX_FILES) {
	tf_message(ERR_ERROR, "File", "RSEEKB",
		   "The file number is out of bounds %d", file_num);
        tf_putp(ARG_RET, -1);
	return -1;
    }
   	
    if (file_streams[file_num] == NULL) {
	tf_message(ERR_ERROR, "File", "RSEEKN",
		   "File number %d is not currently open.", file_num);
        tf_putp(ARG_RET, -1);
	return -1;
    }

    if (file_type[file_num] != DATA_READ) {
	tf_message(ERR_ERROR, "File", "RNOTR",
		   "File %d is not opened for read, can not do $fseek.",
		   file_num);
        tf_putp(ARG_RET, -1);
	return -1;
    }

    if (wherefrom < 0 || wherefrom > 2) {
	tf_message(ERR_ERROR, "File", "RSWOOB",
		   "The wherefrom value (%d) is out of bounds (0,1,2).",
		   wherefrom);
        tf_putp(ARG_RET, -1);
	return -1;
    }

    retval = fseek(file_streams[file_num], position, wherefrom);

#ifdef DEBUG
    io_printf("%0d = $fseek(file:%d, pos:%d, where:%d)\n", 
	      retval, file_num, position, wherefrom);
#endif


    tf_putp(ARG_RET, retval);

    return 0;
} /* fseek_call */




/*******************************************************************************
 $fread routines
 r = $fread(stream, mem[0] <, start, <count>>);
 ******************************************************************************/

int fread_check()
{
    int nbytes;
    s_tfnodeinfo info;

#ifdef NCVerilog

    tf_message(ERR_ERROR, "File", "NCBAD",
	       "$fread is not supported with NC-Verilog");
    return -1;
#else

    if (tf_nump() < 2) {
	tf_message (ERR_ERROR, "File", "RREAD24",
		    "$fread has 2 required arguments - file number and memory, you gave %d", tf_nump());
    }

    if (tf_nump() > 4) {
	tf_message (ERR_ERROR, "File", "RREAD24",
		    "$fread has a max of 4 arguments - file number, memory, start and count, you gave %d", tf_nump());
    }

    if (tf_typep(ARG1) != tf_readonly &&
	tf_typep(ARG1) != tf_readwrite) {
	tf_message(ERR_ERROR, "File", "RTARG1",
		   "The file number in $fread must be an expression or reg");
    }

    /* Check the memory / reg argument                                        */
    if (tf_typep(ARG2) != tf_readwrite) {
	tf_message(ERR_ERROR, "File", "RTARG2",
		   "The first argument in $fread must be a register or memory");
	return -1;
    }

    if (!tf_nodeinfo (ARG2, &info)) {
	tf_message (ERR_INTERNAL, "File", "RENOIN",
		    "Error in getting nodeinfo");
	return -1;
    }

    /* Get the width of the reg or memory                                     */
    if (info.node_type == tf_reg_node || info.node_type == tf_integer_node)
	nbytes = (acc_fetch_size(acc_handle_tfarg(ARG2)) + 7) / 8;
    else nbytes = (info.node_vec_size + 7) / 8;
    if (nbytes >= MAX_STRING_SIZE) {
	tf_message(ERR_ERROR, "File", "RFTOOB",
		   "The destination of $fread must be less than %d bits wide",
		   MAX_STRING_SIZE * 8);
    }
    if (info.node_vec_size % 8 != 0) {
	tf_message(ERR_MESSAGE, "File", "RFBYTE",
		   "%s's width is not divisable by 8, results unpredicatble",
		   info.node_symbol);
    }

    tf_setworkarea((char *) nbytes);


    /* Check the start argument                                               */
    if (tf_typep(ARG3) != tf_nullparam &&
	tf_typep(ARG3) != tf_readonly &&
	tf_typep(ARG3) != tf_readwrite) {
	tf_message(ERR_ERROR, "File", "RTARG3",
		   "The optional start argument in $fread must be an expression or reg");
    }

    /* Check the count argument                                               */
    if (tf_typep(ARG4) != tf_nullparam &&
	tf_typep(ARG4) != tf_readonly &&
	tf_typep(ARG4) != tf_readwrite) {
	tf_message(ERR_ERROR, "File", "RTARG4",
		   "The optional count argument in $fread must be an expression or reg");
    }
#endif

    return 0;
} /* fread_check */



int fread_call()
{
    int file_num = tf_getp(ARG1),               /* File number                */
	start = tf_getp(ARG3),                  /* Starting location in memory*/
	count = tf_getp(ARG4),                  /* Count of locations to read */
	nbytes = (int) tf_getworkarea(),        /* Size of mem word in bytes  */
	locations_read;                         /* Locations read by $fread   */
    static s_acc_value avalue = {accHexStrVal}; /* Holds argument value       */
    static s_setval_delay delay_s = {{0}, accNoDelay};
    s_tfnodeinfo info;
    char data_in[MAX_STRING_SIZE];              /* Holds binary data read in  */

    locations_read = 0;

    /* Check the file number argument                                         */
    if (file_num <= 0 || file_num >= MAX_FILES) {
	tf_message(ERR_ERROR, "File", "RREADB",
		   "The file number is out of bounds %d", file_num);
	/* Return zip */
    }
   	
    else if (file_streams[file_num] == NULL) {
	tf_message(ERR_ERROR, "File", "RREADN",
		   "File number %d is not currently open.", file_num);
	/* Return zip */
    }

    if (file_type[file_num] != DATA_READ) {
	tf_message(ERR_ERROR, "File", "RNOTR",
		   "File %d is not opened for read, can not do $fread.",
		   file_num);
        tf_putp(ARG_RET, -1);
	return -1;
    }


#ifdef NCVerilog
    /* We will never get here with NC-Verilog as there is an error
       given in fread_check, so do nothing... */
#else

    else if (!tf_nodeinfo (ARG2, &info)) {
	tf_message (ERR_INTERNAL, "File", "RENOIN",
		    "Error in getting nodeinfo");
	/* Return zip */
    }
#endif
    else if ((info.node_type == tf_reg_node) ||
	     (info.node_type == tf_integer_node)) {
	/* This is a register or integer. Just read one location from the
	   binary file.  Ignore start, count                                  */
	char data_str[MAX_STRING_SIZE];
	unsigned int i, j;

	locations_read = fread(data_in, nbytes, 1, file_streams[file_num]);
	if (locations_read) {
	    /* Successful read, convert data to string, then write in Verilog */
	    for (i = 0; i < nbytes; i++) {
		j =  (unsigned int) data_in[i] & 0xff;
		sprintf(&data_str[i*2], "%02x", j);
	    } /* for i */
	    data_str[nbytes*2] = '\0';
	    avalue.value.str = data_str;
	    acc_set_value(acc_handle_tfarg(ARG2), &avalue, &delay_s);
#ifdef DEBUG
	io_printf("fread %x, '%s', #=%d\n",
		  (unsigned int) data_in[0], data_str, nbytes);
#endif
	} /* if locations_read */
    } /* If reg or int */


    else {
	/* This is a memory, read many locations from the file.
	   Start by getting the start and count parameters                    */
	char *a, *b, *d;               /* Pointers to a, b bits in reg        */
	int index, j;

	/* If start was null, it will be set to 0, the default for $fread
	   If count was null, we need to look up the depth of the memory      */
	if (tf_typep(ARG4) == tf_nullparam) {
	    count = info.node_mem_size - start;
	}
	else if (count + start > info.node_mem_size) {
	    tf_message (ERR_MESSAGE, "File", "RFRCOB",
			"The value of count plus size (%d., %d.) are greater than the memory size (%d.)",
			count, start, info.node_mem_size);
	    count = info.node_mem_size - start;
	}
#ifdef DEBUG
	io_printf("fread %s[%d:+%d]\n", info.node_symbol, start, count);
#endif

	/* Setup the pointers at mem[start]                                  */
	a = &info.node_value.memoryval_p[0] + (info.node_ngroups * 2 * start);
	b = &info.node_value.memoryval_p[info.node_ngroups] + (info.node_ngroups * 2 * start);
	locations_read = 0;

	/* Loop through memory, freading values, and bailing out if error     */
	for (index=start; index < start+count ; index++) {
	    if (!fread(data_in, nbytes, 1, file_streams[file_num]))
		break;
	    /* We read another data value, copy it over into the memory       */
#ifdef DEBUG
	    io_printf("fread %s[%d]=%x\n",
		      info.node_symbol, index, (int) data_in[0]);
#endif
	    locations_read++;
	    d = (char *) &data_in[nbytes - 1];
	    for (j=0; j < info.node_ngroups; j++) {
		*a++ = *d--;
		*b++ = 0;
	    }
	    a += info.node_ngroups;                   /* Skip over the b bits */
	    b += info.node_ngroups;                   /* Skip over the a bits */
	} /* for index */
    } /* If reg or int */


    tf_putp(ARG_RET, locations_read);      /* Return count or 0 for error */
#ifdef DEBUG
    io_printf("fread returns %d\n", locations_read);
#endif

    return 0;
} /* fread_call */




/*******************************************************************************
 $sprintf routines
 ******************************************************************************/

/* This routine builds a list of format elements from a text string
   It is called from sprintf_check if the format string is a constant string
   It should be called from sprintf_call if the format is a reg,
   and from sprintf_misc for restarts
   */

p_pf_fmt build_pf_fmt_list()
{
    char *format, *fmt_ptr, flag;
    p_pf_fmt fmt_head, fmt_tail;
    int arg_count;
   
    fmt_ptr = tf_getcstringp(ARG2);
    format = strcpy((char *)malloc(strlen(fmt_ptr)+1), fmt_ptr); /* Format string */
#ifdef DEBUG
    io_printf("printf format \"%s\"\n", format);
#endif

    /* Build a linked list of the elements of the format string               */
    fmt_ptr = format;
    fmt_head = fmt_tail = NULL;
    arg_count = 2;
    while (*fmt_ptr) {

	/* Create & a new fmt pointer                                         */
	p_pf_fmt fmt = (p_pf_fmt) malloc(sizeof(s_pf_fmt));
	memset((void*)fmt, 0, sizeof(s_pf_fmt));
	fmt->left = '\0';
	fmt->sign = '\0';
	fmt->spc = '\0';
	fmt->alt = '\0';
	fmt->pad = '0';  /* Be like Verilog, pad %x */
	fmt->string = NULL;
	fmt->width = -1;
	fmt->precision = -1;
	if (*fmt_ptr == '%') {
	    bool leading_zero;

	    leading_zero = FALSE;
	    fmt_ptr++;
#ifdef DEBUG
	    io_printf("fmt\t%%");
#endif

            /* check for flags (in ANY order) */
            while(*fmt_ptr=='-' || *fmt_ptr=='+' || *fmt_ptr==' ' || *fmt_ptr=='#' || *fmt_ptr=='0'){
                switch(*fmt_ptr) {
                    case '-':
                        /* left-justify assignment, %-d */
		        fmt->left = '-';
                        break;

                    case ' ':
                        /* sign place holder assignment, % d */
		        fmt->spc = ' ';
                        break;

                    case '+':
                        /* sign assignment, %+d */
		        fmt->sign = '+';
                        break;

                    case '#':
                        /* alternate assignment, %#x */
		        fmt->alt = '#';
                        break;

                    case '0':
                        /* pad assignment, %02d, but not %0d */
		        fmt->pad = '\0';
			leading_zero = TRUE;
                        break;
                }

#ifdef DEBUG
	        io_printf("%c", *fmt_ptr);
#endif

                fmt_ptr++;

            } /* while */

	    /* Look for a width specifier, %10d                               */
	    if(isdigit(*fmt_ptr)) {
		sscanf(fmt_ptr, "%d", &fmt->width);
		while (isdigit(*++fmt_ptr)) ;
		fmt->pad = '\0';
#ifdef DEBUG
		io_printf("%d", fmt->width);
#endif
	    }
	    /* Pad unless this is %0x */
	    else if (!leading_zero) fmt->pad = '0';

	    /* Look for precision specifier, %0.10x                           */
	    if (*fmt_ptr == '.') {
                fmt_ptr++;
	        if(isdigit(*fmt_ptr)) {
		    sscanf(fmt_ptr, "%d", &fmt->precision);
		    while (isdigit(*++fmt_ptr)) ;
#ifdef DEBUG
		    io_printf(".%d", fmt->precision);
#endif
                }
	    }

	    /* Decode the % specifier                                         */
	    /* Swallow the % for end-of-line, or unrecognized type            */
#ifdef DEBUG
	    io_printf("%c\n", *fmt_ptr);
#endif

	    switch (tolower(*fmt_ptr)) {
		case 'b':
		    fmt->type = FMT_B;
		    fmt_ptr++;
		    arg_count++;
		    break;
		case 'c':
		    fmt->type = FMT_C;
		    fmt_ptr++;
		    arg_count++;
		    break;
		case 'd':
		    fmt->type = FMT_D;
		    fmt_ptr++;
		    arg_count++;
		    break;
	        case 'e':
		case 'f':
	        case 'g':
		    fmt->type = FMT_F;
		    fmt_ptr++;
		    arg_count++;
		    break;
	        case 'm':
		    fmt->type = FMT_M;
		    fmt_ptr++;
		    break;
		case 'o':
		    fmt->type = FMT_O;
		    fmt_ptr++;
		    arg_count++;
		    break;
		case 'r':
		    fmt->type = FMT_R;
		    fmt_ptr++;
		    break;
		case 's':
		    fmt->type = FMT_S;
		    fmt_ptr++;
		    arg_count++;
		    break;
	        case 'h':
		case 'x':
		    fmt->type = FMT_X;
		    fmt_ptr++;
		    arg_count++;
		    break;		    
		case '%':
		    fmt->type = FMT_PERCENT;
		    fmt_ptr++;
		    break;
	        case '\0': 
		  /* ignore trailing %                                 */
		  break;
		default: 
		  printf(">>>> build_fmt_list default: %c\n", *fmt_ptr);
		  break;
		} /* case fmt_ptr */

	} /* if '%' */

	else {
	    /* Copy the text string until the next %
                (white space is treated like part of the string for printf    */
	    char *start = fmt_ptr++,
		*substr;
	    int len;

	    while (*fmt_ptr != '%' && *fmt_ptr)
		fmt_ptr++;

	    len = (int) (fmt_ptr - start);
	    substr = strncpy ((char *)malloc(len+1), start, len);
	    substr[len] = 0;

#ifdef DEBUG
	    io_printf ("fmt\t'%s'\n", substr);
#endif

	    fmt->type = FMT_STRING;
	    fmt->string = substr;
	}

	/* Now link this format item into the list of elements                */
	if (fmt_tail) {
	    fmt_tail->next_ele = fmt;
	    fmt_tail = fmt;
	}
	else {
	    fmt_head = fmt_tail = fmt;
	}

	fmt->next_ele = NULL;
    } /* while */


    /* Check that the number of formatting commands such as %d, match the     */
    /* number of params passed to $printf, including stream and format string */
    if (arg_count != tf_nump()) {
	tf_message (ERR_ERROR, "File", "RSCANN",
		    "$printf was passed the wrong number of variables for the format string");
        free(format);
	return NULL;
    }

    free(format);

    /* Return the head of the format list                                     */
    return fmt_head;
} /* build_pf_fmt_list */


#ifdef __cplusplus
void free_pf_fmt_list (p_pf_fmt fmt)
#else
void free_pf_fmt_list (fmt)
    p_pf_fmt fmt;
#endif
{
    p_pf_fmt next;

    /* Free any format lists and strings from the old model                   */
    while (fmt) {
	next = fmt->next_ele;
	if (fmt->type == FMT_STRING)
	    free (fmt->string);
	free (fmt);
	fmt = next;
    }
} /* free_fmt_list */



/*******************************************************************************
 $sprintf routines
 ******************************************************************************/

int sprintf_check()
{
    if (tf_nump() < 2) {
	tf_message (ERR_ERROR, "File", "RSPA2",
		    "$sprintf must have at least two arguments - the string and format, you gave %d", tf_nump());
	return -1;
    }

    if (tf_typep(ARG1) != tf_readwrite)  {
	tf_message(ERR_ERROR, "File", "RSPS",
		   "The first argument must be a reg, expression");
	return -1;
    }

    if (tf_typep(ARG2) != tf_string &&
	tf_typep(ARG2) != tf_readwrite) {
	tf_message(ERR_ERROR, "File", "RSPF",
		   "The format must be a string or a constant");
	return -1;
    }


    /* Store the head of the format list in the workarea for this instance    */
    if (tf_typep(ARG2) == tf_string) {
	tf_setworkarea ((char *) build_pf_fmt_list());
    }
    else tf_setworkarea ((char *) 0);

    return 0;
} /* sprintf_check */





/*******************************************************************************
   Scan through the formats, and assign to the string the args to the $sprintf
   task.  Note that arg_count starts at 2 to skip over the string and
   format string.
   */
int sprintf_call()
{
    p_pf_fmt fmt = (p_pf_fmt) tf_getworkarea(), /* Format list sprintf_check  */
	fmt_head;
    char fmt_str[MAX_STRING_SIZE], *fmt_p;      /* Holds format for sprintf   */
    int arg_count = 3,                          /* Arg number + 2             */
	retval;                                 /* Return value from sprintf  */
    static char s[MAX_STRING_SIZE];             /* String for sprintf         */
    static s_acc_value avalue = {accStringVal}; /* Holds argument value       */
    static s_setval_delay delay_s = {{0}, accNoDelay};
    char *ptr, *arg, *p_arg;

    /* Initialize and point to our receiving string space                      */
    s[0] = '\0';
    ptr = s;

    /* If the format string is stored in a reg, build the fmt list on the fly */
    if (tf_typep(ARG2) == tf_readwrite) {
	fmt = fmt_head = build_pf_fmt_list();
    }

    /* Loop though the pre-digested format string and print away...           */
    while (fmt) {

        /* pointer to our format string */
        fmt_p = fmt_str;
        *fmt_p = '\0';

        /* build up a format string */
        sprintf(fmt_p, "%%");
        fmt_p += strlen(fmt_p);
	if (fmt->left) {
            sprintf(fmt_p, "%c", fmt->left);
            fmt_p += strlen(fmt_p);
        }
	if (fmt->sign) {
            sprintf(fmt_p, "%c", fmt->sign);
            fmt_p += strlen(fmt_p);
        }
	if (fmt->spc) {
            sprintf(fmt_p, "%c", fmt->spc);
            fmt_p += strlen(fmt_p);
        }
	if (fmt->alt) {
            sprintf(fmt_p, "%c", fmt->alt);
            fmt_p += strlen(fmt_p);
        }
	if (fmt->pad) {
            sprintf(fmt_p, "%c", fmt->pad);
            fmt_p += strlen(fmt_p);
        }
	if (fmt->width != -1) {
            sprintf(fmt_p, "%d", fmt->width);
            fmt_p += strlen(fmt_p);
        }
	if (fmt->precision != -1) {
            sprintf(fmt_p, ".%d", fmt->precision);
            fmt_p += strlen(fmt_p);
        }

	/* What type of format argument is this?                              */
	switch (fmt->type) {

	case FMT_B: /* Binary */
	    /* Read in the next argument as binary string (despaced)          */
            p_arg = (char *)tf_strgetp(arg_count, 'b');
            p_arg += strspn(p_arg, " ");
	    if (!fmt->pad) {
	      if(strspn(p_arg,"0") == strlen(p_arg))
		p_arg += strspn(p_arg,"0") - 1;
	      else
		p_arg += strspn(p_arg,"0");
	    }
            sprintf(fmt_p, "s");
            retval = (int) sprintf(ptr, fmt_str, p_arg);

	    /* Advance the string pointer by the size of what we just printed */
	    ptr += strlen(ptr);
#ifdef DEBUG
	    io_printf("B %d: %s\n", arg_count, p_arg);
#endif
            /* Next Arg */
	    arg_count++;
	   
            break;

	case FMT_C:
	    /* Read in the next argument as binary string (despaced)          */
            sprintf(fmt_p, "c");
            retval = (int) sprintf(ptr, fmt_str, tf_getp(arg_count));

	    /* Advance the string pointer by the size of what we just printed */
	    ptr += strlen(ptr);
#ifdef DEBUG
	    io_printf("C %d: %c\n", arg_count, tf_getp(arg_count));
#endif
            /* Next Arg */
	    arg_count++;
	    break;

	case FMT_D:
	    /* Read in the next argument as decimal string (despaced)         */
            p_arg = (char *)tf_strgetp(arg_count, 'd');
            p_arg += strspn(p_arg, " ");
            sprintf(fmt_p, "s");
            retval = (int) sprintf(ptr, fmt_str, p_arg);

	    /* Advance the string pointer by the size of what we just printed */
	    ptr += strlen(ptr);
#ifdef DEBUG
	    io_printf("D %d: %s %s\n", arg_count, fmt_str, p_arg);
#endif
            /* Next Arg */
	    arg_count++;
	   
	    break;

	case FMT_F:
	    /* Read in the next argument as real                              */
            sprintf(fmt_p, "f");
#ifdef DEBUG
	    io_printf("F1 %d: %s\n", arg_count, fmt_str);
#endif
            retval = (int) sprintf(ptr, fmt_str, tf_getrealp(arg_count));
	    /* Advance the string pointer by the size of what we just printed */
	    ptr += strlen(ptr);
#ifdef DEBUG
	    io_printf("F2 %d: %f\n", arg_count, tf_getrealp(arg_count));
#endif
            /* Next Arg */
	    arg_count++;
	    break;


	case FMT_M:
	    /* Tack on the current scope to the string */
	    arg = tf_spname();
	    strcat(ptr, arg);
	    ptr += strlen(arg);

#ifdef DEBUG
	    io_printf("M: %s\n", arg);
#endif
            break;

	case FMT_O:
	    /* Read in the next argument as octal string (despaced)           */
            p_arg = (char *)tf_strgetp(arg_count, 'o');
            p_arg += strspn(p_arg, " ");
	    if (!fmt->pad) {
	      if(strspn(p_arg,"0") == strlen(p_arg))
		p_arg += strspn(p_arg,"0") - 1;
	      else
		p_arg += strspn(p_arg,"0");
	    }
            sprintf(fmt_p, "s");
            retval = (int) sprintf(ptr, fmt_str, p_arg);

	    /* Advance the string pointer by the size of what we just printed */
	    ptr += strlen(ptr);
#ifdef DEBUG
	    io_printf("O %d: %s\n", arg_count, p_arg);
#endif
            /* Next Arg */
	    arg_count++;
	   
            break;

	case FMT_R:
	    arg_count++;
	    /* Not yet implemented, will print 32'hABCD_XZ01 */
	    break;


	case FMT_S:
	    /* Read in the next argument as a string                          */
            sprintf(fmt_p, "s");
            retval = (int) sprintf(ptr, fmt_str, tf_getcstringp(arg_count));
	    /* Advance the string pointer by the size of what we just printed */
	    ptr += strlen(ptr);
#ifdef DEBUG
	    io_printf("S %d: %s\n", arg_count, tf_getcstringp(arg_count));
#endif
            /* Next Arg */
	    arg_count++;
	    break;

	case FMT_X:
	    /* Read in the next argument as hex string (despaced)             */
            p_arg = (char *)tf_strgetp(arg_count, 'h');
            p_arg += strspn(p_arg, " ");
	    if (!fmt->pad) {
	      if(strspn(p_arg,"0") == strlen(p_arg))
		p_arg += strspn(p_arg,"0") - 1;
	      else
		p_arg += strspn(p_arg,"0");
	    }
            sprintf(fmt_p, "s");
            retval = (int) sprintf(ptr, fmt_str, p_arg);

	    /* Advance the string pointer by the size of what we just printed */
	    ptr += strlen(ptr);
#ifdef DEBUG
	    io_printf("X %d: %s\n", arg_count, p_arg);
#endif
            /* Next Arg */
	    arg_count++;
	   
            break;

	case FMT_STRING:
	    retval = (int) sprintf(ptr, "%s", fmt->string);
	    ptr += strlen(ptr);
#ifdef DEBUG
            io_printf("Str '%s'\n", fmt->string);
#endif
	    break;


	case FMT_PERCENT:
	    retval = (int) sprintf(ptr, "%%");
	    ptr += strlen(ptr);
#ifdef DEBUG
            io_printf("Percent %%\n");
#endif
	    break;


	default:
	    /* Internal error - unknown format type                           */
	    tf_message(ERR_INTERNAL, "File", "SPRINTI",
		       "Unknown $sprintf format type = %d.", fmt->type);
	    return -1;

	} /* switch */

	/* If sprintf failed (ie. %d from 'ABC'), break & return # args read  */
	if (retval == 0) {
#ifdef DEBUG
	    io_printf("sprintf returned early = %d\n", retval);
#endif
	    break;
	}


	fmt = fmt->next_ele;

    } /* while */

    /* If the format string is stored in a reg, free the fmt list             */
    if (tf_typep(ARG2) == tf_readwrite) {
	free_pf_fmt_list(fmt_head);
    }

    /* put the results into the string reg, ARG1 */
#ifdef DEBUG
    io_printf("sprintf string: %s\n", s);
#endif
    avalue.value.str = s;
    acc_set_value(acc_handle_tfarg(ARG1), &avalue, &delay_s);

#ifdef DEBUG
    io_printf("sprintf returns %d\n", strlen(s));
#endif
    tf_putp(ARG_RET, strlen(s));        /* Return argment count           */

    return 0;
} /* sprintf_call */




#ifdef __cplusplus
int sprintf_misc (int data, int reason)
#else
int sprintf_misc (data, reason)
    int data, reason;
#endif
{
#ifdef SAVE
    switch (reason) {

    case reason_startofrestart:
#ifdef DEBUG
	io_printf("sprintf_misc startofrestart instance %d\n", tf_getinstance());
#endif
	/* Free any format lists and strings from the old model               */
	free_pf_fmt_list((p_pf_fmt) tf_getworkarea());
	break;


    case reason_restart:
#ifdef DEBUG
	io_printf("sscanf_misc, restart, instance %d\n", tf_getinstance());
#endif
	/* Store the head of the format list in the workarea for this
	   instance of $sprintf in the new model                              */
	if (tf_typep(ARG2) == tf_string) {
	    tf_setworkarea ((char *) build_pf_fmt_list());
	}
	break;


    } /* switch (reason) */
#endif

    return 0;
} /* sprintf_misc */




/*******************************************************************************
 $fprintf routines
 ******************************************************************************/

int fprintf_check()
{
    if (tf_nump() < 2) {
	tf_message (ERR_ERROR, "File", "RSPA2",
		    "$fprintf must have at least two arguments - the string and format, you gave %d", tf_nump());
	return -1;
    }

    if (tf_typep(ARG1) != tf_readwrite)  {
	tf_message(ERR_ERROR, "File", "RSPS",
		   "The first argument must be a reg, expression");
	return -1;
    }

    if (tf_typep(ARG2) != tf_string &&
	tf_typep(ARG2) != tf_readwrite) {
	tf_message(ERR_ERROR, "File", "RSPF",
		   "The format must be a string or a constant");
	return -1;
    }


    /* Store the head of the format list in the workarea for this instance    */
    if (tf_typep(ARG2) == tf_string) {
	tf_setworkarea ((char *) build_pf_fmt_list());
    }
    else tf_setworkarea ((char *) 0);

    return 0;
} /* fprintf_check */





/*******************************************************************************
   Scan through the formats, and assign to the string the args to the $fprintf
   task.  Note that arg_count starts at 2 to skip over the string and
   format string.
   */
int fprintf_call()
{
    p_pf_fmt fmt = (p_pf_fmt) tf_getworkarea(), /* Format list fprintf_check  */
	fmt_head;
    char fmt_str[MAX_STRING_SIZE], *fmt_p;      /* Holds format for fprintf   */
    int arg_count = 3,                          /* Arg number + 2             */
	retval;                                 /* Return value from fprintf  */
    static char s[MAX_STRING_SIZE];             /* String for fprintf         */
    static s_acc_value avalue = {accStringVal}; /* Holds argument value       */
    static s_setval_delay delay_s = {{0}, accNoDelay};
    int file_num = tf_getp(ARG1);               /* File stream number         */
    char *ptr, *arg, *p_arg;


    if (file_num <= 0 || file_num >= MAX_FILES) {
	tf_message(ERR_ERROR, "File", "REOFB",
		   "The file number is out of bounds %d", file_num);
        tf_putp(ARG_RET, -1);
	return -1;
    }
   	
    if (file_streams[file_num] == NULL) {
	tf_message(ERR_ERROR, "File", "REOFN",
		   "File number %d is not currently open.", file_num);
        tf_putp(ARG_RET, -1);
	return -1;
    }

    if (file_type[file_num] != DATA_WRITE) {
	tf_message(ERR_ERROR, "File", "RNOTW",
		   "File %d is not opened for write, can not do $fprintf. (%d)",
		   file_num, file_type[file_num]);
        tf_putp(ARG_RET, -1);
	return -1;
    }

    /* Initialize and point to our receiving string space                      */
    s[0] = '\0';
    ptr = s;

    /* If the format string is stored in a reg, build the fmt list on the fly */
    if (tf_typep(ARG2) == tf_readwrite) {
	fmt = fmt_head = build_pf_fmt_list();
    }

    /* Loop though the pre-digested format string and print away...            */
    while (fmt) {

        /* pointer to our format string */
        fmt_p = fmt_str;
        *fmt_p = '\0';

        /* build up a format string */
        sprintf(fmt_p, "%%");
        fmt_p += strlen(fmt_p);
	if (fmt->left) {
            sprintf(fmt_p, "%c", fmt->left);
            fmt_p += strlen(fmt_p);
        }
	if (fmt->sign) {
            sprintf(fmt_p, "%c", fmt->sign);
            fmt_p += strlen(fmt_p);
        }
	if (fmt->spc) {
            sprintf(fmt_p, "%c", fmt->spc);
            fmt_p += strlen(fmt_p);
        }
	if (fmt->alt) {
            sprintf(fmt_p, "%c", fmt->alt);
            fmt_p += strlen(fmt_p);
        }
	if (fmt->pad) {
            sprintf(fmt_p, "%c", fmt->pad);
            fmt_p += strlen(fmt_p);
        }
	if (fmt->width != -1) {
            sprintf(fmt_p, "%d", fmt->width);
            fmt_p += strlen(fmt_p);
        }
	if (fmt->precision != -1) {
            sprintf(fmt_p, ".%d", fmt->precision);
            fmt_p += strlen(fmt_p);
        }

	/* What type of format argument is this?                              */
	switch (fmt->type) {

	case FMT_B: /* Binary */
	    /* Read in the next argument as binary string (despaced)          */
            p_arg = (char *)tf_strgetp(arg_count, 'b');
            p_arg += strspn(p_arg, " ");
	    if (!fmt->pad) {
	      if(strspn(p_arg,"0") == strlen(p_arg))
		p_arg += strspn(p_arg,"0") - 1;
	      else
		p_arg += strspn(p_arg,"0");
	    }
            sprintf(fmt_p, "s");
            retval = (int) sprintf(ptr, fmt_str, p_arg);

	    /* Advance the string pointer by the size of what we just printed */
	    ptr += strlen(ptr);
#ifdef DEBUG
	    io_printf("B %d: %s\n", arg_count, p_arg);
#endif
            /* Next Arg */
	    arg_count++;
	   
            break;

	case FMT_C:
	    /* Read in the next argument as binary string (despaced)          */
            sprintf(fmt_p, "c");
            retval = (int) sprintf(ptr, fmt_str, tf_getp(arg_count));

	    /* Advance the string pointer by the size of what we just printed */
	    ptr += strlen(ptr);
#ifdef DEBUG
	    io_printf("C %d: %c\n", arg_count, tf_getp(arg_count));
#endif
            /* Next Arg */
	    arg_count++;
	    break;

	case FMT_D:
	    /* Read in the next argument as decimal string (despaced)         */
            p_arg = (char *)tf_strgetp(arg_count, 'd');
            p_arg += strspn(p_arg, " ");
            sprintf(fmt_p, "s");
            retval = (int) sprintf(ptr, fmt_str, p_arg);

	    /* Advance the string pointer by the size of what we just printed */
	    ptr += strlen(ptr);
#ifdef DEBUG
	    io_printf("D %d: %s %s\n", arg_count, fmt_str, p_arg);
#endif
            /* Next Arg */
	    arg_count++;
	   
	    break;

	case FMT_F:
	    /* Read in the next argument as real                              */
            sprintf(fmt_p, "f");
#ifdef DEBUG
	    io_printf("F1 %d: %s\n", arg_count, fmt_str);
#endif
            retval = (int) sprintf(ptr, fmt_str, tf_getrealp(arg_count));
	    /* Advance the string pointer by the size of what we just printed */
	    ptr += strlen(ptr);
#ifdef DEBUG
	    io_printf("F2 %d: %f\n", arg_count, tf_getrealp(arg_count));
#endif
            /* Next Arg */
	    arg_count++;
	    break;


	case FMT_M:
	    /* Tack on the current scope to the string */
	    arg = tf_spname();
	    strcat(ptr, arg);
	    ptr += strlen(arg);

#ifdef DEBUG
	    io_printf("M: %s\n", arg);
#endif
            break;


	case FMT_O:
	    /* Read in the next argument as octal string (despaced)           */
            p_arg = (char *)tf_strgetp(arg_count, 'o');
            p_arg += strspn(p_arg, " ");
	    if (!fmt->pad) {
	      if(strspn(p_arg,"0") == strlen(p_arg))
		p_arg += strspn(p_arg,"0") - 1;
	      else
		p_arg += strspn(p_arg,"0");
	    }
            sprintf(fmt_p, "s");
            retval = (int) sprintf(ptr, fmt_str, p_arg);

	    /* Advance the string pointer by the size of what we just printed */
	    ptr += strlen(ptr);
#ifdef DEBUG
	    io_printf("O %d: %s\n", arg_count, p_arg);
#endif
            /* Next Arg */
	    arg_count++;
	   
            break;

	case FMT_R:
	    arg_count++;
	    /* Not yet implemented, will print 32'hABCD_XZ01 */
	    break;


	case FMT_S:
	    /* Read in the next argument as a string                          */
            sprintf(fmt_p, "s");
            retval = (int) sprintf(ptr, fmt_str, tf_getcstringp(arg_count));
	    /* Advance the string pointer by the size of what we just printed */
	    ptr += strlen(ptr);
#ifdef DEBUG
	    io_printf("S %d: %s\n", arg_count, tf_getcstringp(arg_count));
#endif
            /* Next Arg */
	    arg_count++;
	    break;

	case FMT_X:
	    /* Read in the next argument as hex string (despaced)             */
            p_arg = (char *)tf_strgetp(arg_count, 'h');
            p_arg += strspn(p_arg, " ");
	    if (!fmt->pad) {
	      if(strspn(p_arg,"0") == strlen(p_arg))
		p_arg += strspn(p_arg,"0") - 1;
	      else
		p_arg += strspn(p_arg,"0");
	    }
            sprintf(fmt_p, "s");
            retval = (int) sprintf(ptr, fmt_str, p_arg);

	    /* Advance the string pointer by the size of what we just printed */
	    ptr += strlen(ptr);
#ifdef DEBUG
	    io_printf("X %d: %s\n", arg_count, p_arg);
#endif
            /* Next Arg */
	    arg_count++;
	   
            break;

	case FMT_STRING:
	    retval = (int) sprintf(ptr, "%s", fmt->string);
	    ptr += strlen(ptr);
#ifdef DEBUG
            io_printf("Str %s\n", fmt->string);
#endif
	    break;

	case FMT_PERCENT:
	    retval = (int) sprintf(ptr, "%%");
	    ptr += strlen(ptr);
#ifdef DEBUG
            io_printf("Percent %%\n");
#endif
	    break;

	default:
	    /* Internal error - unknown format type                           */
	    tf_message(ERR_INTERNAL, "File", "SPRINTI",
		       "Unknown $fprintf format type = %d.", fmt->type);
	    return -1;

	} /* switch */

	/* If sprintf failed (ie. %d from 'ABC'), break & return # args read  */
	if (retval == 0) {
#ifdef DEBUG
	    io_printf("fprintf returned early = %d\n", retval);
#endif
	    break;
	}


	fmt = fmt->next_ele;

    } /* while */

    /* If the format string is stored in a reg, free the fmt list             */
    if (tf_typep(ARG2) == tf_readwrite) {
	free_pf_fmt_list(fmt_head);
    }

    /* put the results into the string reg, ARG1 */
#ifdef DEBUG
    io_printf("fprintf string: %s\n", s);
#endif
    retval = fprintf(file_streams[file_num], "%s", s);

#ifdef DEBUG
    io_printf("fprintf returns %d\n", retval);
#endif
    tf_putp(ARG_RET, retval);              /* Return argument count           */

    return 0;
} /* fprintf_call */




#ifdef __cplusplus
int fprintf_misc (int data, int reason)
#else
int fprintf_misc (data, reason)
    int data, reason;
#endif
{
#ifdef SAVE
    switch (reason) {

    case reason_startofrestart:
#ifdef DEBUG
	io_printf("fprintf_misc startofrestart instance %d\n", tf_getinstance());
#endif
	/* Free any format lists and strings from the old model               */
	free_pf_fmt_list((p_pf_fmt) tf_getworkarea());
	break;


    case reason_restart:
#ifdef DEBUG
	io_printf("fprintf_misc, restart, instance %d\n", tf_getinstance());
#endif
	/* Store the head of the format list in the workarea for this
	   instance of $fprintf in the new model                              */
	if (tf_typep(ARG2) == tf_string) {
	    tf_setworkarea ((char *) build_pf_fmt_list());
	}
	break;


    } /* switch (reason) */
#endif
    return 0;
} /* fprintf_misc */



#ifdef MTI
/* stuff for building a shared library for Modelsim
   stolen from bpeldo_verilog */

s_tfcell veriusertfs[] = {
  /*** Template for an entry:
    { usertask|userfunction, data,
        checktf(), sizetf(), calltf(), misctf(),
        "$tfname", forwref?, Vtool?, ErrMsg? },
    Example:
    { usertask, 0, my_check, 0, my_func, my_misctf, "$my_task" },
    ***/
    {userfunction, 1, (p_tffn)fopen_check,   size32, (p_tffn)fopen_call,   (p_tffn)fopen_misc,   "$fopena"},
    {userfunction, 2, (p_tffn)fopen_check,   size32, (p_tffn)fopen_call,   (p_tffn)fopen_misc,   "$fopenr"},
    {userfunction, 3, (p_tffn)fopen_check,   size32, (p_tffn)fopen_call,   (p_tffn)fopen_misc,   "$fopenw"},
    {userfunction, 1, (p_tffn)fclose_check,  size32, (p_tffn)fclose_call,  (p_tffn)0,            "$fclosea"},
    {userfunction, 2, (p_tffn)fclose_check,  size32, (p_tffn)fclose_call,  (p_tffn)0,            "$fcloser"},
    {userfunction, 3, (p_tffn)fclose_check,  size32, (p_tffn)fclose_call,  (p_tffn)0,            "$fclosew"},
    {userfunction, 0, (p_tffn)fgets_check,   size32, (p_tffn)fgets_call,   (p_tffn)0,            "$fgets"},
    {userfunction, 0, (p_tffn)gets_check,    size32, (p_tffn)gets_call,    (p_tffn)0,            "$gets"},
    {userfunction, 0, (p_tffn)fgetc_check,   size32, (p_tffn)fgetc_call,   (p_tffn)0,            "$fgetc"},
    {userfunction, 0, (p_tffn)getchar_check, size32, (p_tffn)getchar_call, (p_tffn)0,            "$getchar"},
    {userfunction, 0, (p_tffn)ungetc_check,  size32, (p_tffn)ungetc_call,  (p_tffn)0,            "$ungetc"},
    {userfunction, 0, (p_tffn)feof_check,    size32, (p_tffn)feof_call,    (p_tffn)0,            "$feof"},
    {userfunction, 0, (p_tffn)ferror_check,  size32, (p_tffn)ferror_call,  (p_tffn)0,            "$ferror"},
#ifdef scanf_task
    {userfunction, 0, (p_tffn)fscanf_check,  0,      (p_tffn)fscanf_call,  (p_tffn)fscanf_misc,  "$fscanf"},
    {userfunction, 0, (p_tffn)sscanf_check,  0,      (p_tffn)sscanf_call,  (p_tffn)sscanf_misc,  "$sscanf"},
    {userfunction, 0, (p_tffn)scanf_check,   0,      (p_tffn)scanf_call,   (p_tffn)scanf_misc,   "$scanf"},
#else
    {userfunction, 0, (p_tffn)fscanf_check,  size32, (p_tffn)fscanf_call,  (p_tffn)fscanf_misc,  "$fscanf"},
    {userfunction, 0, (p_tffn)sscanf_check,  size32, (p_tffn)sscanf_call,  (p_tffn)sscanf_misc,  "$sscanf"},
    {userfunction, 0, (p_tffn)scanf_check,   size32, (p_tffn)scanf_call,   (p_tffn)scanf_misc,   "$scanf"},
#endif
    {userfunction, 0, (p_tffn)ftell_check,   size32, (p_tffn)ftell_call,   (p_tffn)0,            "$ftell"},
    {userfunction, 0, (p_tffn)fseek_check,   size32, (p_tffn)fseek_call,   (p_tffn)0,            "$fseek"},
    {userfunction, 0, (p_tffn)fread_check,   size32, (p_tffn)fread_call,   (p_tffn)0,            "$fread"},
    {userfunction, 0, (p_tffn)sprintf_check, size32, (p_tffn)sprintf_call, (p_tffn)sprintf_misc, "$sprintf"},
    {userfunction, 0, (p_tffn)fprintf_check, size32, (p_tffn)fprintf_call, (p_tffn)fprintf_misc, "$fprintf"},
    {userfunction, 0, (p_tffn)fflush_check,  size32,  (p_tffn)fflush_call,  (p_tffn)0,            "$fflush"},
    {0}                           /*** final entry must be 0 ***/
};

void init_usertfs()
{
  p_tfcell usertf;
  
  for (usertf = veriusertfs;usertf;usertf++) {
    if (usertf->type == 0)
      return;
    mti_RegisterUserTF(usertf);
  }
}
#endif MTI
