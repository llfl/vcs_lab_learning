//*********************************************************************
//            Synopsys Standard Cell Library Verilog Models
//              Licensed Software - Synopsys Confidential
//        Copyright (C) 1991-2000 Synopsys. All rights reserved.
//*********************************************************************
// Tools Version: LA 3.4.9
// Generate time: Fri Jun  2 09:49:23 PDT 2000
//*********************************************************************
`timescale 1 ns / 10 ps

primitive ff(qout, data, clock, preset, clear, notifier);
    output qout;
    reg qout;
    input data, clock, preset, clear, notifier;
    table
    // data clock  p c notifier state  qout 
    // ------------------------------------
         ?    n    ? 0    ?    :  1  :  - ; //If the previous state was 1 then the next state
                                            //will also be 1.
         ?    n    0 ?    ?    :  0  :  - ; //If the previous state was 0 then the next state
                                            //will also be 0.
         0    r    0 0    ?    :  ?  :  0 ; // posedge clock
         1    r    0 0    ?    :  ?  :  1 ;
         1    p    ? 0    ?    :  1  :  1 ; 
         0    p    0 ?    ?    :  0  :  0 ; 
         ?    n    0 0    ?    :  ?  :  - ; // ignore negedge clock
         *    ?    0 0    ?    :  ?  :  - ; // ignore data changes on steady clock 
         ?    ?    1 0    ?    :  ?  :  1 ; // preset logic
         ?    ?    * 0    ?    :  1  :  1 ;
         ?    ?    0 1    ?    :  ?  :  0 ; // clear logic 
         ?    ?    0 *    ?    :  0  :  0 ;
         ?    ?    1 1    ?    :  ?  :  x ; // illegal condition
         ?    ?    ? ?    *    :  ?  :  x ; // timing checks error, qout set to x 
    endtable
endprimitive

primitive dlatch(qout, data, gate, preset, clear, error_flag);
    output qout;
    reg qout;
    input data, gate, preset, clear, error_flag;
    table
    // data gate   p c  error_flag  state  qout
    // ---------------------------------------
         ?    ?    ? ?      0      :  ?  :  x ; // timing violation condition when the error_flag is 1
         0    1    0 0      x      :  ?  :  0 ; // high level at gate
         1    1    0 0      x      :  ?  :  1 ; // high level at gate
         x    1    0 0      x      :  ?  :  x ; // high level at gate
         ?    0    0 0      x      :  ?  :  - ; // low level at gate, no change on qout
         1    x    ? 0      x      :  1  :  1 ; // ignore preset level when data equals 1
         0    x    0 ?      x      :  0  :  0 ; // ignore clear  level when data equals 0
         ?    ?    1 0      x      :  ?  :  1 ; // preset logic
         ?    ?    * 0      x      :  1  :  1 ;
         ?    ?    0 1      x      :  ?  :  0 ; // clear logic
         ?    ?    0 *      x      :  0  :  0 ;
         ?    ?    1 1      x      :  ?  :  x ; // illegal condition
    endtable
endprimitive
 
primitive notifier_gen(error_flag, data, gate, preset, clear, notifier);
    output error_flag;
    reg error_flag;
    input notifier,data, gate, preset, clear;
    table
    // data gate   p c notifier state  error_flag
    // ------------------------------------
         ?    ?    ? ?    *    :  ?  :  0 ; // timing checks error, nout set to 0
    endtable
endprimitive
 
 
module dl(qout, data, gate, preset, clear, notifier);
    output qout;
    wire error_flag;
    input data, gate, preset, clear, notifier;
 
    dlatch       g1(qout, data, gate, preset, clear, error_flag);
    notifier_gen g2(error_flag, data, gate, preset, clear, notifier);
endmodule
primitive mux(y, s0, d1, d0);
    output y;
    input s0, d1, d0;
    table
    // s0 d1 d0 : y
       0  ?  0  : 0;
       0  ?  1  : 1;
       1  0  ?  : 0;
       1  1  ?  : 1;
       x  0  0  : 0;
       x  1  1  : 1;
    endtable
endprimitive
 
primitive twr(y, s0, d1, d0);
    output y;
    input s0, d1, d0;
    table
    // s0 d1 d0 : y
       0  ?  0  : 0;
       0  ?  1  : 1;
       ?  ?  x  : x;
       1  x  ?  : x;
       1  1  0  : x;
       1  0  1  : x;
       1  0  0  : 0;
       1  1  1  : 1;
    endtable
endprimitive

// udp for ram model
primitive bufx(y, a, b);
    output y;
    reg y;
    input  a, b;
    table
    // a     b    : state : y
       x     *    :   ?   : x; // a = x, y = x. Otherwise,
       r     0    :   ?   : 1; // y follows a and b changes
       r     1    :   ?   : 1;
       (x1)  0    :   ?   : 1;
       (x1)  1    :   ?   : 1;
       (x1)  x    :   ?   : 1;
       f     0    :   ?   : 0;
       f     1    :   ?   : 0;
       (x0)  0    :   ?   : 0;
       (x0)  1    :   ?   : 0;
       (x0)  x    :   ?   : 0;
       0     r    :   ?   : 1;
       1     r    :   ?   : 1;
       0     (x1) :   ?   : 1;
       1     (x1) :   ?   : 1;
       0     f    :   ?   : 0;
       1     f    :   ?   : 0;
       0     (x0) :   ?   : 0;
       1     (x0) :   ?   : 0;
    endtable
endprimitive

primitive ddl(qout, data, gate, si, sigate, clear, preset, notifier);
   output qout;
   reg qout;
   input data, gate, si, sigate, clear, preset, notifier;
   table
   // d	g si sig clr pre notifier state qout
   // ---------------------------------------
      0 1  ?  0   0   0     ?    :  ? :  0 ;	// transparent high gate
      1 1  ?  0   0   0     ?    :  ? :  1 ;
      ? 0  ?  0   0   0     ?    :  ? :  - ;  	// no change in d
      1 x  ?  0   0   ?	    ?	 :  1 :  1 ;	// ignore gate when state=d
      0 x  ?  0	  ?   0	    ?	 :  0 :	 0 ;
      ?	0  0  1	  0   0	    ?	 :  ? :	 0 ;	// transparent high si gate
      ? 0  1  1	  0   0	    ?	 :  ? :	 1 ;
      ? 0  1  ?	  0   ?	    ?	 :  1 :	 1 ;	// ignore sig when state=sig
      ?	0  0  ?	  ?   0	    ?	 :  0 :	 0 ;	
      1	1  1  1	  0   ?	    ?	 :  ? :	 1 ;	// open both d and si paths
      0 1  0  1	  ?   0	    ?	 :  ? :	 0 ;	
      1 1  0  1	  0   0	    ?	 :  ? :	 x ;	// illegal conditions
      0	1  1  1	  0   0	    ?	 :  ? :	 x ;	
      ?	?  ?  ?	  0   1	    ?	 :  ? :	 1 ;	// active high preset logic
      ?	?  ?  ?	  0   *	    ?	 :  1 :	 1 ;	// ???
      ?	?  ?  ?	  1   0	    ?	 :  ? :	 0 ;	// active high clear logic
      ?	?  ?  ?	  *   0	    ?	 :  0 :	 0 ;	// ???
      ?	?  ?  ?	  1   1	    ?	 :  ? :	 x ;	// preset and clear active
      ?	?  ?  ?	  ?   ?	    *	 :  ? :	 x ;	// timing checks error
   endtable
endprimitive

primitive lsrq(qout, s, r, notifier);
    output qout;
    reg qout;
    input s, r, notifier;
    table
    //   s    r  notifier state  qout
    // -------------------------------
         0    0     ?    :  ?  :  - ;
         0    1     ?    :  ?  :  0 ;
         1    0     ?    :  ?  :  1 ;
         1    1     ?    :  ?  :  1 ;
         ?    ?     *    :  ?  :  x ;
    endtable
endprimitive

primitive lsrqn(qnout, s, r, notifier);
    output qnout;
    reg qnout;
    input s, r, notifier;
    table
    //   s    r  notifier state qnout
    // -------------------------------
         0    0     ?    :  ?  :  - ;
         0    1     ?    :  ?  :  1 ;
         1    0     ?    :  ?  :  0 ;
         1    1     ?    :  ?  :  1 ;
         ?    ?     *    :  ?  :  x ;
    endtable
endprimitive

primitive xproc(y, a, dummy);
    input  a, dummy;
    output y;
 
    table
    // a dummy : y
    //--------------
       0   1   : 0;
       1   1   : 1;
       x   1   : 1;
    endtable
endprimitive
 
module  xtc_or(Y, A, B);
    input  A, B;
    output Y;
    wire   wr1;
 
    or    g1(wr1, A, B);
    xproc g2(Y, wr1, 1'b1);
endmodule
 
module  xtc_xor(Y, A, B);
    input  A, B;
    output Y;
    wire   wr1;
 
    xor   g1(wr1, A, B);
    xproc g2(Y, wr1, 1'b1);
endmodule
 
module  xtc_nand(Y, A, B);
    input  A, B;
    output Y;
    wire   wr1;
 
    nand  g1(wr1, A, B);
    xproc g2(Y, wr1, 1'b1);
endmodule
 
module  xtc_and(Y, A, B);
    input  A, B;
    output Y;
    wire   wr1;
 
    and   g1(wr1, A, B);
    xproc g2(Y, wr1, 1'b1);
endmodule
 
module  xtc_nor(Y, A, B);
    input  A, B;
    output Y;
    wire   wr1;
 
    nor   g1(wr1, A, B);
    xproc g2(Y, wr1, 1'b1);
endmodule
 
module  xtc_not(Y, A);
    input  A;
    output Y;
    wire   wr1;
 
    not   g1(wr1, A);
    xproc g2(Y, wr1, 1'b1);
endmodule
 
module  xtc_buf(Y, A);
    input  A;
    output Y;
    wire   wr1;
 
    buf   g1(wr1, A);
    xproc g2(Y, wr1, 1'b1);
endmodule
 
module  xtc_mux(Y, S, D1, D0);
    input S, D1, D0;
    output Y;
    wire   wr1;
 
    mux   g1(wr1, S, D1, D0);
    xproc g2(Y, wr1, 1'b1);
endmodule
 
module  xtc_bufif1(Y, IN, CTL);
    input  IN, CTL;
    output Y;
    wire   wr1;
 
    bufif1 g1(wr1, IN, CTL);
    xproc  g2(Y, wr1, 1'b1);
endmodule
 
`timescale 1 ns / 10 ps
`celldefine

module and2a1(Y, A, B);
        output Y;
        input  A, B;
        and g1(Y, A, B);
        // SPECIFY BLOCK
        specify
                specparam A_LH_Y = 0, A_HL_Y = 0 ;
                specparam B_LH_Y = 0, B_HL_Y = 0 ;
                (A *> Y) = (A_LH_Y, A_HL_Y) ;
                (B *> Y) = (B_LH_Y, B_HL_Y) ;
        endspecify
endmodule

module and2a15(Y, A, B);
        output Y;
        input  A, B;
        and g1(Y, A, B);
        // SPECIFY BLOCK
        specify
                specparam A_LH_Y = 0, A_HL_Y = 0 ;
                specparam B_LH_Y = 0, B_HL_Y = 0 ;
                (A *> Y) = (A_LH_Y, A_HL_Y) ;
                (B *> Y) = (B_LH_Y, B_HL_Y) ;
        endspecify
endmodule

module and2a2(Y, A, B);
        output Y;
        input  A, B;
        and g1(Y, A, B);
        // SPECIFY BLOCK
        specify
                specparam A_LH_Y = 0, A_HL_Y = 0 ;
                specparam B_LH_Y = 0, B_HL_Y = 0 ;
                (A *> Y) = (A_LH_Y, A_HL_Y) ;
                (B *> Y) = (B_LH_Y, B_HL_Y) ;
        endspecify
endmodule

module and2a3(Y, A, B);
        output Y;
        input  A, B;
        and g1(Y, A, B);
        // SPECIFY BLOCK
        specify
                specparam A_LH_Y = 0, A_HL_Y = 0 ;
                specparam B_LH_Y = 0, B_HL_Y = 0 ;
                (A *> Y) = (A_LH_Y, A_HL_Y) ;
                (B *> Y) = (B_LH_Y, B_HL_Y) ;
        endspecify
endmodule

module and2a6(Y, A, B);
        output Y;
        input  A, B;
        and g1(Y, A, B);
        // SPECIFY BLOCK
        specify
                specparam A_LH_Y = 0, A_HL_Y = 0 ;
                specparam B_LH_Y = 0, B_HL_Y = 0 ;
                (A *> Y) = (A_LH_Y, A_HL_Y) ;
                (B *> Y) = (B_LH_Y, B_HL_Y) ;
        endspecify
endmodule

module and2a9(Y, A, B);
        output Y;
        input  A, B;
        and g1(Y, A, B);
        // SPECIFY BLOCK
        specify
                specparam A_LH_Y = 0, A_HL_Y = 0 ;
                specparam B_LH_Y = 0, B_HL_Y = 0 ;
                (A *> Y) = (A_LH_Y, A_HL_Y) ;
                (B *> Y) = (B_LH_Y, B_HL_Y) ;
        endspecify
endmodule

module and2b1(Y, A, B);
        output Y;
        input  A, B;
        not g1(N1, A);
        and g2(Y, N1, B);
        // SPECIFY BLOCK
        specify
                specparam A_LH_Y = 0, A_HL_Y = 0 ;
                specparam B_LH_Y = 0, B_HL_Y = 0 ;
                (A *> Y) = (A_LH_Y, A_HL_Y) ;
                (B *> Y) = (B_LH_Y, B_HL_Y) ;
        endspecify
endmodule

module and2b15(Y, A, B);
        output Y;
        input  A, B;
        not g1(N1, A);
        and g2(Y, N1, B);
        // SPECIFY BLOCK
        specify
                specparam A_LH_Y = 0, A_HL_Y = 0 ;
                specparam B_LH_Y = 0, B_HL_Y = 0 ;
                (A *> Y) = (A_LH_Y, A_HL_Y) ;
                (B *> Y) = (B_LH_Y, B_HL_Y) ;
        endspecify
endmodule

module and2b2(Y, A, B);
        output Y;
        input  A, B;
        not g1(N1, A);
        and g2(Y, N1, B);
        // SPECIFY BLOCK
        specify
                specparam A_LH_Y = 0, A_HL_Y = 0 ;
                specparam B_LH_Y = 0, B_HL_Y = 0 ;
                (A *> Y) = (A_LH_Y, A_HL_Y) ;
                (B *> Y) = (B_LH_Y, B_HL_Y) ;
        endspecify
endmodule

module and2b3(Y, A, B);
        output Y;
        input  A, B;
        not g1(N1, A);
        and g2(Y, N1, B);
        // SPECIFY BLOCK
        specify
                specparam A_LH_Y = 0, A_HL_Y = 0 ;
                specparam B_LH_Y = 0, B_HL_Y = 0 ;
                (A *> Y) = (A_LH_Y, A_HL_Y) ;
                (B *> Y) = (B_LH_Y, B_HL_Y) ;
        endspecify
endmodule

module and2b6(Y, A, B);
        output Y;
        input  A, B;
        not g1(N1, A);
        and g2(Y, N1, B);
        // SPECIFY BLOCK
        specify
                specparam A_LH_Y = 0, A_HL_Y = 0 ;
                specparam B_LH_Y = 0, B_HL_Y = 0 ;
                (A *> Y) = (A_LH_Y, A_HL_Y) ;
                (B *> Y) = (B_LH_Y, B_HL_Y) ;
        endspecify
endmodule

module and2b9(Y, A, B);
        output Y;
        input  A, B;
        not g1(N1, A);
        and g2(Y, N1, B);
        // SPECIFY BLOCK
        specify
                specparam A_LH_Y = 0, A_HL_Y = 0 ;
                specparam B_LH_Y = 0, B_HL_Y = 0 ;
                (A *> Y) = (A_LH_Y, A_HL_Y) ;
                (B *> Y) = (B_LH_Y, B_HL_Y) ;
        endspecify
endmodule

module and2c1(Y, A, B);
        output Y;
        input  A, B;
        not g1(N1, A);
        not g2(N2, B);
        and g3(Y, N1, N2);
        // SPECIFY BLOCK
        specify
                specparam A_LH_Y = 0, A_HL_Y = 0 ;
                specparam B_LH_Y = 0, B_HL_Y = 0 ;
                (A *> Y) = (A_LH_Y, A_HL_Y) ;
                (B *> Y) = (B_LH_Y, B_HL_Y) ;
        endspecify
endmodule

module and2c15(Y, A, B);
        output Y;
        input  A, B;
        not g1(N1, A);
        not g2(N2, B);
        and g3(Y, N1, N2);
        // SPECIFY BLOCK
        specify
                specparam A_LH_Y = 0, A_HL_Y = 0 ;
                specparam B_LH_Y = 0, B_HL_Y = 0 ;
                (A *> Y) = (A_LH_Y, A_HL_Y) ;
                (B *> Y) = (B_LH_Y, B_HL_Y) ;
        endspecify
endmodule

module and2c2(Y, A, B);
        output Y;
        input  A, B;
        not g1(N1, A);
        not g2(N2, B);
        and g3(Y, N1, N2);
        // SPECIFY BLOCK
        specify
                specparam A_LH_Y = 0, A_HL_Y = 0 ;
                specparam B_LH_Y = 0, B_HL_Y = 0 ;
                (A *> Y) = (A_LH_Y, A_HL_Y) ;
                (B *> Y) = (B_LH_Y, B_HL_Y) ;
        endspecify
endmodule

module and2c3(Y, A, B);
        output Y;
        input  A, B;
        not g1(N1, A);
        not g2(N2, B);
        and g3(Y, N1, N2);
        // SPECIFY BLOCK
        specify
                specparam A_LH_Y = 0, A_HL_Y = 0 ;
                specparam B_LH_Y = 0, B_HL_Y = 0 ;
                (A *> Y) = (A_LH_Y, A_HL_Y) ;
                (B *> Y) = (B_LH_Y, B_HL_Y) ;
        endspecify
endmodule

module and2c6(Y, A, B);
        output Y;
        input  A, B;
        not g1(N1, A);
        not g2(N2, B);
        and g3(Y, N1, N2);
        // SPECIFY BLOCK
        specify
                specparam A_LH_Y = 0, A_HL_Y = 0 ;
                specparam B_LH_Y = 0, B_HL_Y = 0 ;
                (A *> Y) = (A_LH_Y, A_HL_Y) ;
                (B *> Y) = (B_LH_Y, B_HL_Y) ;
        endspecify
endmodule

module and2c9(Y, A, B);
        output Y;
        input  A, B;
        not g1(N1, A);
        not g2(N2, B);
        and g3(Y, N1, N2);
        // SPECIFY BLOCK
        specify
                specparam A_LH_Y = 0, A_HL_Y = 0 ;
                specparam B_LH_Y = 0, B_HL_Y = 0 ;
                (A *> Y) = (A_LH_Y, A_HL_Y) ;
                (B *> Y) = (B_LH_Y, B_HL_Y) ;
        endspecify
endmodule

module and3a1(Y, A, B, C);
        output Y;
        input  A, B, C;
        and g1(Y, B, C, A);
        // SPECIFY BLOCK
        specify
                specparam A_LH_Y = 0, A_HL_Y = 0 ;
                specparam B_LH_Y = 0, B_HL_Y = 0 ;
                specparam C_LH_Y = 0, C_HL_Y = 0 ;
                (A *> Y) = (A_LH_Y, A_HL_Y) ;
                (B *> Y) = (B_LH_Y, B_HL_Y) ;
                (C *> Y) = (C_LH_Y, C_HL_Y) ;
        endspecify
endmodule

module and3a15(Y, A, B, C);
        output Y;
        input  A, B, C;
        and g1(Y, B, C, A);
        // SPECIFY BLOCK
        specify
                specparam A_LH_Y = 0, A_HL_Y = 0 ;
                specparam B_LH_Y = 0, B_HL_Y = 0 ;
                specparam C_LH_Y = 0, C_HL_Y = 0 ;
                (A *> Y) = (A_LH_Y, A_HL_Y) ;
                (B *> Y) = (B_LH_Y, B_HL_Y) ;
                (C *> Y) = (C_LH_Y, C_HL_Y) ;
        endspecify
endmodule

module and3a2(Y, A, B, C);
        output Y;
        input  A, B, C;
        and g1(Y, B, C, A);
        // SPECIFY BLOCK
        specify
                specparam A_LH_Y = 0, A_HL_Y = 0 ;
                specparam B_LH_Y = 0, B_HL_Y = 0 ;
                specparam C_LH_Y = 0, C_HL_Y = 0 ;
                (A *> Y) = (A_LH_Y, A_HL_Y) ;
                (B *> Y) = (B_LH_Y, B_HL_Y) ;
                (C *> Y) = (C_LH_Y, C_HL_Y) ;
        endspecify
endmodule

module and3a3(Y, A, B, C);
        output Y;
        input  A, B, C;
        and g1(Y, B, C, A);
        // SPECIFY BLOCK
        specify
                specparam A_LH_Y = 0, A_HL_Y = 0 ;
                specparam B_LH_Y = 0, B_HL_Y = 0 ;
                specparam C_LH_Y = 0, C_HL_Y = 0 ;
                (A *> Y) = (A_LH_Y, A_HL_Y) ;
                (B *> Y) = (B_LH_Y, B_HL_Y) ;
                (C *> Y) = (C_LH_Y, C_HL_Y) ;
        endspecify
endmodule

module and3a6(Y, A, B, C);
        output Y;
        input  A, B, C;
        and g1(Y, B, C, A);
        // SPECIFY BLOCK
        specify
                specparam A_LH_Y = 0, A_HL_Y = 0 ;
                specparam B_LH_Y = 0, B_HL_Y = 0 ;
                specparam C_LH_Y = 0, C_HL_Y = 0 ;
                (A *> Y) = (A_LH_Y, A_HL_Y) ;
                (B *> Y) = (B_LH_Y, B_HL_Y) ;
                (C *> Y) = (C_LH_Y, C_HL_Y) ;
        endspecify
endmodule

module and3a9(Y, A, B, C);
        output Y;
        input  A, B, C;
        and g1(Y, B, C, A);
        // SPECIFY BLOCK
        specify
                specparam A_LH_Y = 0, A_HL_Y = 0 ;
                specparam B_LH_Y = 0, B_HL_Y = 0 ;
                specparam C_LH_Y = 0, C_HL_Y = 0 ;
                (A *> Y) = (A_LH_Y, A_HL_Y) ;
                (B *> Y) = (B_LH_Y, B_HL_Y) ;
                (C *> Y) = (C_LH_Y, C_HL_Y) ;
        endspecify
endmodule

module and3b1(Y, A, B, C);
        output Y;
        input  A, B, C;
        not g1(N1, A);
        and g2(Y, B, C, N1);
        // SPECIFY BLOCK
        specify
                specparam A_LH_Y = 0, A_HL_Y = 0 ;
                specparam B_LH_Y = 0, B_HL_Y = 0 ;
                specparam C_LH_Y = 0, C_HL_Y = 0 ;
                (A *> Y) = (A_LH_Y, A_HL_Y) ;
                (B *> Y) = (B_LH_Y, B_HL_Y) ;
                (C *> Y) = (C_LH_Y, C_HL_Y) ;
        endspecify
endmodule

module and3b15(Y, A, B, C);
        output Y;
        input  A, B, C;
        not g1(N1, A);
        and g2(Y, B, C, N1);
        // SPECIFY BLOCK
        specify
                specparam A_LH_Y = 0, A_HL_Y = 0 ;
                specparam B_LH_Y = 0, B_HL_Y = 0 ;
                specparam C_LH_Y = 0, C_HL_Y = 0 ;
                (A *> Y) = (A_LH_Y, A_HL_Y) ;
                (B *> Y) = (B_LH_Y, B_HL_Y) ;
                (C *> Y) = (C_LH_Y, C_HL_Y) ;
        endspecify
endmodule

module and3b2(Y, A, B, C);
        output Y;
        input  A, B, C;
        not g1(N1, A);
        and g2(Y, B, C, N1);
        // SPECIFY BLOCK
        specify
                specparam A_LH_Y = 0, A_HL_Y = 0 ;
                specparam B_LH_Y = 0, B_HL_Y = 0 ;
                specparam C_LH_Y = 0, C_HL_Y = 0 ;
                (A *> Y) = (A_LH_Y, A_HL_Y) ;
                (B *> Y) = (B_LH_Y, B_HL_Y) ;
                (C *> Y) = (C_LH_Y, C_HL_Y) ;
        endspecify
endmodule

module and3b3(Y, A, B, C);
        output Y;
        input  A, B, C;
        not g1(N1, A);
        and g2(Y, B, C, N1);
        // SPECIFY BLOCK
        specify
                specparam A_LH_Y = 0, A_HL_Y = 0 ;
                specparam B_LH_Y = 0, B_HL_Y = 0 ;
                specparam C_LH_Y = 0, C_HL_Y = 0 ;
                (A *> Y) = (A_LH_Y, A_HL_Y) ;
                (B *> Y) = (B_LH_Y, B_HL_Y) ;
                (C *> Y) = (C_LH_Y, C_HL_Y) ;
        endspecify
endmodule

module and3b6(Y, A, B, C);
        output Y;
        input  A, B, C;
        not g1(N1, A);
        and g2(Y, B, C, N1);
        // SPECIFY BLOCK
        specify
                specparam A_LH_Y = 0, A_HL_Y = 0 ;
                specparam B_LH_Y = 0, B_HL_Y = 0 ;
                specparam C_LH_Y = 0, C_HL_Y = 0 ;
                (A *> Y) = (A_LH_Y, A_HL_Y) ;
                (B *> Y) = (B_LH_Y, B_HL_Y) ;
                (C *> Y) = (C_LH_Y, C_HL_Y) ;
        endspecify
endmodule

module and3b9(Y, A, B, C);
        output Y;
        input  A, B, C;
        not g1(N1, A);
        and g2(Y, B, C, N1);
        // SPECIFY BLOCK
        specify
                specparam A_LH_Y = 0, A_HL_Y = 0 ;
                specparam B_LH_Y = 0, B_HL_Y = 0 ;
                specparam C_LH_Y = 0, C_HL_Y = 0 ;
                (A *> Y) = (A_LH_Y, A_HL_Y) ;
                (B *> Y) = (B_LH_Y, B_HL_Y) ;
                (C *> Y) = (C_LH_Y, C_HL_Y) ;
        endspecify
endmodule

module and3c1(Y, A, B, C);
        output Y;
        input  A, B, C;
        not g1(N1, B);
        not g2(N2, A);
        and g3(Y, N1, C, N2);
        // SPECIFY BLOCK
        specify
                specparam A_LH_Y = 0, A_HL_Y = 0 ;
                specparam B_LH_Y = 0, B_HL_Y = 0 ;
                specparam C_LH_Y = 0, C_HL_Y = 0 ;
                (A *> Y) = (A_LH_Y, A_HL_Y) ;
                (B *> Y) = (B_LH_Y, B_HL_Y) ;
                (C *> Y) = (C_LH_Y, C_HL_Y) ;
        endspecify
endmodule

module and3c15(Y, A, B, C);
        output Y;
        input  A, B, C;
        not g1(N1, B);
        not g2(N2, A);
        and g3(Y, N1, C, N2);
        // SPECIFY BLOCK
        specify
                specparam A_LH_Y = 0, A_HL_Y = 0 ;
                specparam B_LH_Y = 0, B_HL_Y = 0 ;
                specparam C_LH_Y = 0, C_HL_Y = 0 ;
                (A *> Y) = (A_LH_Y, A_HL_Y) ;
                (B *> Y) = (B_LH_Y, B_HL_Y) ;
                (C *> Y) = (C_LH_Y, C_HL_Y) ;
        endspecify
endmodule

module and3c2(Y, A, B, C);
        output Y;
        input  A, B, C;
        not g1(N1, B);
        not g2(N2, A);
        and g3(Y, N1, C, N2);
        // SPECIFY BLOCK
        specify
                specparam A_LH_Y = 0, A_HL_Y = 0 ;
                specparam B_LH_Y = 0, B_HL_Y = 0 ;
                specparam C_LH_Y = 0, C_HL_Y = 0 ;
                (A *> Y) = (A_LH_Y, A_HL_Y) ;
                (B *> Y) = (B_LH_Y, B_HL_Y) ;
                (C *> Y) = (C_LH_Y, C_HL_Y) ;
        endspecify
endmodule

module and3c3(Y, A, B, C);
        output Y;
        input  A, B, C;
        not g1(N1, B);
        not g2(N2, A);
        and g3(Y, N1, C, N2);
        // SPECIFY BLOCK
        specify
                specparam A_LH_Y = 0, A_HL_Y = 0 ;
                specparam B_LH_Y = 0, B_HL_Y = 0 ;
                specparam C_LH_Y = 0, C_HL_Y = 0 ;
                (A *> Y) = (A_LH_Y, A_HL_Y) ;
                (B *> Y) = (B_LH_Y, B_HL_Y) ;
                (C *> Y) = (C_LH_Y, C_HL_Y) ;
        endspecify
endmodule

module and3c6(Y, A, B, C);
        output Y;
        input  A, B, C;
        not g1(N1, B);
        not g2(N2, A);
        and g3(Y, N1, C, N2);
        // SPECIFY BLOCK
        specify
                specparam A_LH_Y = 0, A_HL_Y = 0 ;
                specparam B_LH_Y = 0, B_HL_Y = 0 ;
                specparam C_LH_Y = 0, C_HL_Y = 0 ;
                (A *> Y) = (A_LH_Y, A_HL_Y) ;
                (B *> Y) = (B_LH_Y, B_HL_Y) ;
                (C *> Y) = (C_LH_Y, C_HL_Y) ;
        endspecify
endmodule

module and3c9(Y, A, B, C);
        output Y;
        input  A, B, C;
        not g1(N1, B);
        not g2(N2, A);
        and g3(Y, N1, C, N2);
        // SPECIFY BLOCK
        specify
                specparam A_LH_Y = 0, A_HL_Y = 0 ;
                specparam B_LH_Y = 0, B_HL_Y = 0 ;
                specparam C_LH_Y = 0, C_HL_Y = 0 ;
                (A *> Y) = (A_LH_Y, A_HL_Y) ;
                (B *> Y) = (B_LH_Y, B_HL_Y) ;
                (C *> Y) = (C_LH_Y, C_HL_Y) ;
        endspecify
endmodule

module and3d1(Y, A, B, C);
        output Y;
        input  A, B, C;
        not g1(N1, B);
        not g2(N2, C);
        not g3(N3, A);
        and g4(Y, N1, N2, N3);
        // SPECIFY BLOCK
        specify
                specparam A_LH_Y = 0, A_HL_Y = 0 ;
                specparam B_LH_Y = 0, B_HL_Y = 0 ;
                specparam C_LH_Y = 0, C_HL_Y = 0 ;
                (A *> Y) = (A_LH_Y, A_HL_Y) ;
                (B *> Y) = (B_LH_Y, B_HL_Y) ;
                (C *> Y) = (C_LH_Y, C_HL_Y) ;
        endspecify
endmodule

module and3d15(Y, A, B, C);
        output Y;
        input  A, B, C;
        not g1(N1, B);
        not g2(N2, C);
        not g3(N3, A);
        and g4(Y, N1, N2, N3);
        // SPECIFY BLOCK
        specify
                specparam A_LH_Y = 0, A_HL_Y = 0 ;
                specparam B_LH_Y = 0, B_HL_Y = 0 ;
                specparam C_LH_Y = 0, C_HL_Y = 0 ;
                (A *> Y) = (A_LH_Y, A_HL_Y) ;
                (B *> Y) = (B_LH_Y, B_HL_Y) ;
                (C *> Y) = (C_LH_Y, C_HL_Y) ;
        endspecify
endmodule

module and3d2(Y, A, B, C);
        output Y;
        input  A, B, C;
        not g1(N1, B);
        not g2(N2, C);
        not g3(N3, A);
        and g4(Y, N1, N2, N3);
        // SPECIFY BLOCK
        specify
                specparam A_LH_Y = 0, A_HL_Y = 0 ;
                specparam B_LH_Y = 0, B_HL_Y = 0 ;
                specparam C_LH_Y = 0, C_HL_Y = 0 ;
                (A *> Y) = (A_LH_Y, A_HL_Y) ;
                (B *> Y) = (B_LH_Y, B_HL_Y) ;
                (C *> Y) = (C_LH_Y, C_HL_Y) ;
        endspecify
endmodule

module and3d3(Y, A, B, C);
        output Y;
        input  A, B, C;
        not g1(N1, B);
        not g2(N2, C);
        not g3(N3, A);
        and g4(Y, N1, N2, N3);
        // SPECIFY BLOCK
        specify
                specparam A_LH_Y = 0, A_HL_Y = 0 ;
                specparam B_LH_Y = 0, B_HL_Y = 0 ;
                specparam C_LH_Y = 0, C_HL_Y = 0 ;
                (A *> Y) = (A_LH_Y, A_HL_Y) ;
                (B *> Y) = (B_LH_Y, B_HL_Y) ;
                (C *> Y) = (C_LH_Y, C_HL_Y) ;
        endspecify
endmodule

module and3d6(Y, A, B, C);
        output Y;
        input  A, B, C;
        not g1(N1, B);
        not g2(N2, C);
        not g3(N3, A);
        and g4(Y, N1, N2, N3);
        // SPECIFY BLOCK
        specify
                specparam A_LH_Y = 0, A_HL_Y = 0 ;
                specparam B_LH_Y = 0, B_HL_Y = 0 ;
                specparam C_LH_Y = 0, C_HL_Y = 0 ;
                (A *> Y) = (A_LH_Y, A_HL_Y) ;
                (B *> Y) = (B_LH_Y, B_HL_Y) ;
                (C *> Y) = (C_LH_Y, C_HL_Y) ;
        endspecify
endmodule

module and3d9(Y, A, B, C);
        output Y;
        input  A, B, C;
        not g1(N1, B);
        not g2(N2, C);
        not g3(N3, A);
        and g4(Y, N1, N2, N3);
        // SPECIFY BLOCK
        specify
                specparam A_LH_Y = 0, A_HL_Y = 0 ;
                specparam B_LH_Y = 0, B_HL_Y = 0 ;
                specparam C_LH_Y = 0, C_HL_Y = 0 ;
                (A *> Y) = (A_LH_Y, A_HL_Y) ;
                (B *> Y) = (B_LH_Y, B_HL_Y) ;
                (C *> Y) = (C_LH_Y, C_HL_Y) ;
        endspecify
endmodule

module and4a15(Y, A, B, C, D);
        output Y;
        input  A, B, C, D;
        and g1(Y, C, D, B, A);
        // SPECIFY BLOCK
        specify
                specparam A_LH_Y = 0, A_HL_Y = 0 ;
                specparam B_LH_Y = 0, B_HL_Y = 0 ;
                specparam C_LH_Y = 0, C_HL_Y = 0 ;
                specparam D_LH_Y = 0, D_HL_Y = 0 ;
                (A *> Y) = (A_LH_Y, A_HL_Y) ;
                (B *> Y) = (B_LH_Y, B_HL_Y) ;
                (C *> Y) = (C_LH_Y, C_HL_Y) ;
                (D *> Y) = (D_LH_Y, D_HL_Y) ;
        endspecify
endmodule

module and4a3(Y, A, B, C, D);
        output Y;
        input  A, B, C, D;
        and g1(Y, C, D, B, A);
        // SPECIFY BLOCK
        specify
                specparam A_LH_Y = 0, A_HL_Y = 0 ;
                specparam B_LH_Y = 0, B_HL_Y = 0 ;
                specparam C_LH_Y = 0, C_HL_Y = 0 ;
                specparam D_LH_Y = 0, D_HL_Y = 0 ;
                (A *> Y) = (A_LH_Y, A_HL_Y) ;
                (B *> Y) = (B_LH_Y, B_HL_Y) ;
                (C *> Y) = (C_LH_Y, C_HL_Y) ;
                (D *> Y) = (D_LH_Y, D_HL_Y) ;
        endspecify
endmodule

module and4a6(Y, A, B, C, D);
        output Y;
        input  A, B, C, D;
        and g1(Y, C, D, B, A);
        // SPECIFY BLOCK
        specify
                specparam A_LH_Y = 0, A_HL_Y = 0 ;
                specparam B_LH_Y = 0, B_HL_Y = 0 ;
                specparam C_LH_Y = 0, C_HL_Y = 0 ;
                specparam D_LH_Y = 0, D_HL_Y = 0 ;
                (A *> Y) = (A_LH_Y, A_HL_Y) ;
                (B *> Y) = (B_LH_Y, B_HL_Y) ;
                (C *> Y) = (C_LH_Y, C_HL_Y) ;
                (D *> Y) = (D_LH_Y, D_HL_Y) ;
        endspecify
endmodule

module and4a9(Y, A, B, C, D);
        output Y;
        input  A, B, C, D;
        and g1(Y, C, D, B, A);
        // SPECIFY BLOCK
        specify
                specparam A_LH_Y = 0, A_HL_Y = 0 ;
                specparam B_LH_Y = 0, B_HL_Y = 0 ;
                specparam C_LH_Y = 0, C_HL_Y = 0 ;
                specparam D_LH_Y = 0, D_HL_Y = 0 ;
                (A *> Y) = (A_LH_Y, A_HL_Y) ;
                (B *> Y) = (B_LH_Y, B_HL_Y) ;
                (C *> Y) = (C_LH_Y, C_HL_Y) ;
                (D *> Y) = (D_LH_Y, D_HL_Y) ;
        endspecify
endmodule

module and4e15(Y, A, B, C, D);
        output Y;
        input  A, B, C, D;
        not g1(N1, C);
        not g2(N2, D);
        not g3(N3, B);
        not g4(N4, A);
        and g5(Y, N1, N2, N3, N4);
        // SPECIFY BLOCK
        specify
                specparam A_LH_Y = 0, A_HL_Y = 0 ;
                specparam B_LH_Y = 0, B_HL_Y = 0 ;
                specparam C_LH_Y = 0, C_HL_Y = 0 ;
                specparam D_LH_Y = 0, D_HL_Y = 0 ;
                (A *> Y) = (A_LH_Y, A_HL_Y) ;
                (B *> Y) = (B_LH_Y, B_HL_Y) ;
                (C *> Y) = (C_LH_Y, C_HL_Y) ;
                (D *> Y) = (D_LH_Y, D_HL_Y) ;
        endspecify
endmodule

module and4e3(Y, A, B, C, D);
        output Y;
        input  A, B, C, D;
        not g1(N1, C);
        not g2(N2, D);
        not g3(N3, B);
        not g4(N4, A);
        and g5(Y, N1, N2, N3, N4);
        // SPECIFY BLOCK
        specify
                specparam A_LH_Y = 0, A_HL_Y = 0 ;
                specparam B_LH_Y = 0, B_HL_Y = 0 ;
                specparam C_LH_Y = 0, C_HL_Y = 0 ;
                specparam D_LH_Y = 0, D_HL_Y = 0 ;
                (A *> Y) = (A_LH_Y, A_HL_Y) ;
                (B *> Y) = (B_LH_Y, B_HL_Y) ;
                (C *> Y) = (C_LH_Y, C_HL_Y) ;
                (D *> Y) = (D_LH_Y, D_HL_Y) ;
        endspecify
endmodule

module and4e6(Y, A, B, C, D);
        output Y;
        input  A, B, C, D;
        not g1(N1, C);
        not g2(N2, D);
        not g3(N3, B);
        not g4(N4, A);
        and g5(Y, N1, N2, N3, N4);
        // SPECIFY BLOCK
        specify
                specparam A_LH_Y = 0, A_HL_Y = 0 ;
                specparam B_LH_Y = 0, B_HL_Y = 0 ;
                specparam C_LH_Y = 0, C_HL_Y = 0 ;
                specparam D_LH_Y = 0, D_HL_Y = 0 ;
                (A *> Y) = (A_LH_Y, A_HL_Y) ;
                (B *> Y) = (B_LH_Y, B_HL_Y) ;
                (C *> Y) = (C_LH_Y, C_HL_Y) ;
                (D *> Y) = (D_LH_Y, D_HL_Y) ;
        endspecify
endmodule

module and4e9(Y, A, B, C, D);
        output Y;
        input  A, B, C, D;
        not g1(N1, C);
        not g2(N2, D);
        not g3(N3, B);
        not g4(N4, A);
        and g5(Y, N1, N2, N3, N4);
        // SPECIFY BLOCK
        specify
                specparam A_LH_Y = 0, A_HL_Y = 0 ;
                specparam B_LH_Y = 0, B_HL_Y = 0 ;
                specparam C_LH_Y = 0, C_HL_Y = 0 ;
                specparam D_LH_Y = 0, D_HL_Y = 0 ;
                (A *> Y) = (A_LH_Y, A_HL_Y) ;
                (B *> Y) = (B_LH_Y, B_HL_Y) ;
                (C *> Y) = (C_LH_Y, C_HL_Y) ;
                (D *> Y) = (D_LH_Y, D_HL_Y) ;
        endspecify
endmodule

module and6a15(Y, A, B, C, D, E, F);
        output Y;
        input  A, B, C, D, E, F;
        and g1(Y, E, F, D, C, B, A);
        // SPECIFY BLOCK
        specify
                specparam A_LH_Y = 0, A_HL_Y = 0 ;
                specparam B_LH_Y = 0, B_HL_Y = 0 ;
                specparam C_LH_Y = 0, C_HL_Y = 0 ;
                specparam D_LH_Y = 0, D_HL_Y = 0 ;
                specparam E_LH_Y = 0, E_HL_Y = 0 ;
                specparam F_LH_Y = 0, F_HL_Y = 0 ;
                (A *> Y) = (A_LH_Y, A_HL_Y) ;
                (B *> Y) = (B_LH_Y, B_HL_Y) ;
                (C *> Y) = (C_LH_Y, C_HL_Y) ;
                (D *> Y) = (D_LH_Y, D_HL_Y) ;
                (E *> Y) = (E_LH_Y, E_HL_Y) ;
                (F *> Y) = (F_LH_Y, F_HL_Y) ;
        endspecify
endmodule

module and6a3(Y, A, B, C, D, E, F);
        output Y;
        input  A, B, C, D, E, F;
        and g1(Y, E, F, D, C, B, A);
        // SPECIFY BLOCK
        specify
                specparam A_LH_Y = 0, A_HL_Y = 0 ;
                specparam B_LH_Y = 0, B_HL_Y = 0 ;
                specparam C_LH_Y = 0, C_HL_Y = 0 ;
                specparam D_LH_Y = 0, D_HL_Y = 0 ;
                specparam E_LH_Y = 0, E_HL_Y = 0 ;
                specparam F_LH_Y = 0, F_HL_Y = 0 ;
                (A *> Y) = (A_LH_Y, A_HL_Y) ;
                (B *> Y) = (B_LH_Y, B_HL_Y) ;
                (C *> Y) = (C_LH_Y, C_HL_Y) ;
                (D *> Y) = (D_LH_Y, D_HL_Y) ;
                (E *> Y) = (E_LH_Y, E_HL_Y) ;
                (F *> Y) = (F_LH_Y, F_HL_Y) ;
        endspecify
endmodule

module and6a6(Y, A, B, C, D, E, F);
        output Y;
        input  A, B, C, D, E, F;
        and g1(Y, E, F, D, C, B, A);
        // SPECIFY BLOCK
        specify
                specparam A_LH_Y = 0, A_HL_Y = 0 ;
                specparam B_LH_Y = 0, B_HL_Y = 0 ;
                specparam C_LH_Y = 0, C_HL_Y = 0 ;
                specparam D_LH_Y = 0, D_HL_Y = 0 ;
                specparam E_LH_Y = 0, E_HL_Y = 0 ;
                specparam F_LH_Y = 0, F_HL_Y = 0 ;
                (A *> Y) = (A_LH_Y, A_HL_Y) ;
                (B *> Y) = (B_LH_Y, B_HL_Y) ;
                (C *> Y) = (C_LH_Y, C_HL_Y) ;
                (D *> Y) = (D_LH_Y, D_HL_Y) ;
                (E *> Y) = (E_LH_Y, E_HL_Y) ;
                (F *> Y) = (F_LH_Y, F_HL_Y) ;
        endspecify
endmodule

module and6a9(Y, A, B, C, D, E, F);
        output Y;
        input  A, B, C, D, E, F;
        and g1(Y, E, F, D, C, B, A);
        // SPECIFY BLOCK
        specify
                specparam A_LH_Y = 0, A_HL_Y = 0 ;
                specparam B_LH_Y = 0, B_HL_Y = 0 ;
                specparam C_LH_Y = 0, C_HL_Y = 0 ;
                specparam D_LH_Y = 0, D_HL_Y = 0 ;
                specparam E_LH_Y = 0, E_HL_Y = 0 ;
                specparam F_LH_Y = 0, F_HL_Y = 0 ;
                (A *> Y) = (A_LH_Y, A_HL_Y) ;
                (B *> Y) = (B_LH_Y, B_HL_Y) ;
                (C *> Y) = (C_LH_Y, C_HL_Y) ;
                (D *> Y) = (D_LH_Y, D_HL_Y) ;
                (E *> Y) = (E_LH_Y, E_HL_Y) ;
                (F *> Y) = (F_LH_Y, F_HL_Y) ;
        endspecify
endmodule

module ao1a1(Y, A, B, C);
        output Y;
        input  A, B, C;
        and g1(N1, A, B);
        or g2(Y, N1, C);
        // SPECIFY BLOCK
        specify
                specparam A_LH_Y = 0, A_HL_Y = 0 ;
                specparam B_LH_Y = 0, B_HL_Y = 0 ;
                specparam C_LH_Y = 0, C_HL_Y = 0 ;
                (A *> Y) = (A_LH_Y, A_HL_Y) ;
                (B *> Y) = (B_LH_Y, B_HL_Y) ;
                (C *> Y) = (C_LH_Y, C_HL_Y) ;
        endspecify
endmodule

module ao1a15(Y, A, B, C);
        output Y;
        input  A, B, C;
        and g1(N1, A, B);
        or g2(Y, N1, C);
        // SPECIFY BLOCK
        specify
                specparam A_LH_Y = 0, A_HL_Y = 0 ;
                specparam B_LH_Y = 0, B_HL_Y = 0 ;
                specparam C_LH_Y = 0, C_HL_Y = 0 ;
                (A *> Y) = (A_LH_Y, A_HL_Y) ;
                (B *> Y) = (B_LH_Y, B_HL_Y) ;
                (C *> Y) = (C_LH_Y, C_HL_Y) ;
        endspecify
endmodule

module ao1a2(Y, A, B, C);
        output Y;
        input  A, B, C;
        and g1(N1, A, B);
        or g2(Y, N1, C);
        // SPECIFY BLOCK
        specify
                specparam A_LH_Y = 0, A_HL_Y = 0 ;
                specparam B_LH_Y = 0, B_HL_Y = 0 ;
                specparam C_LH_Y = 0, C_HL_Y = 0 ;
                (A *> Y) = (A_LH_Y, A_HL_Y) ;
                (B *> Y) = (B_LH_Y, B_HL_Y) ;
                (C *> Y) = (C_LH_Y, C_HL_Y) ;
        endspecify
endmodule

module ao1a3(Y, A, B, C);
        output Y;
        input  A, B, C;
        and g1(N1, A, B);
        or g2(Y, N1, C);
        // SPECIFY BLOCK
        specify
                specparam A_LH_Y = 0, A_HL_Y = 0 ;
                specparam B_LH_Y = 0, B_HL_Y = 0 ;
                specparam C_LH_Y = 0, C_HL_Y = 0 ;
                (A *> Y) = (A_LH_Y, A_HL_Y) ;
                (B *> Y) = (B_LH_Y, B_HL_Y) ;
                (C *> Y) = (C_LH_Y, C_HL_Y) ;
        endspecify
endmodule

module ao1a6(Y, A, B, C);
        output Y;
        input  A, B, C;
        and g1(N1, A, B);
        or g2(Y, N1, C);
        // SPECIFY BLOCK
        specify
                specparam A_LH_Y = 0, A_HL_Y = 0 ;
                specparam B_LH_Y = 0, B_HL_Y = 0 ;
                specparam C_LH_Y = 0, C_HL_Y = 0 ;
                (A *> Y) = (A_LH_Y, A_HL_Y) ;
                (B *> Y) = (B_LH_Y, B_HL_Y) ;
                (C *> Y) = (C_LH_Y, C_HL_Y) ;
        endspecify
endmodule

module ao1a9(Y, A, B, C);
        output Y;
        input  A, B, C;
        and g1(N1, A, B);
        or g2(Y, N1, C);
        // SPECIFY BLOCK
        specify
                specparam A_LH_Y = 0, A_HL_Y = 0 ;
                specparam B_LH_Y = 0, B_HL_Y = 0 ;
                specparam C_LH_Y = 0, C_HL_Y = 0 ;
                (A *> Y) = (A_LH_Y, A_HL_Y) ;
                (B *> Y) = (B_LH_Y, B_HL_Y) ;
                (C *> Y) = (C_LH_Y, C_HL_Y) ;
        endspecify
endmodule

module ao1b1(Y, A, B, C);
        output Y;
        input  A, B, C;
        not g1(N2, A);
        and g2(N1, N2, B);
        or g3(Y, N1, C);
        // SPECIFY BLOCK
        specify
                specparam A_LH_Y = 0, A_HL_Y = 0 ;
                specparam B_LH_Y = 0, B_HL_Y = 0 ;
                specparam C_LH_Y = 0, C_HL_Y = 0 ;
                (A *> Y) = (A_LH_Y, A_HL_Y) ;
                (B *> Y) = (B_LH_Y, B_HL_Y) ;
                (C *> Y) = (C_LH_Y, C_HL_Y) ;
        endspecify
endmodule

module ao1b15(Y, A, B, C);
        output Y;
        input  A, B, C;
        not g1(N2, A);
        and g2(N1, N2, B);
        or g3(Y, N1, C);
        // SPECIFY BLOCK
        specify
                specparam A_LH_Y = 0, A_HL_Y = 0 ;
                specparam B_LH_Y = 0, B_HL_Y = 0 ;
                specparam C_LH_Y = 0, C_HL_Y = 0 ;
                (A *> Y) = (A_LH_Y, A_HL_Y) ;
                (B *> Y) = (B_LH_Y, B_HL_Y) ;
                (C *> Y) = (C_LH_Y, C_HL_Y) ;
        endspecify
endmodule

module ao1b2(Y, A, B, C);
        output Y;
        input  A, B, C;
        not g1(N2, A);
        and g2(N1, N2, B);
        or g3(Y, N1, C);
        // SPECIFY BLOCK
        specify
                specparam A_LH_Y = 0, A_HL_Y = 0 ;
                specparam B_LH_Y = 0, B_HL_Y = 0 ;
                specparam C_LH_Y = 0, C_HL_Y = 0 ;
                (A *> Y) = (A_LH_Y, A_HL_Y) ;
                (B *> Y) = (B_LH_Y, B_HL_Y) ;
                (C *> Y) = (C_LH_Y, C_HL_Y) ;
        endspecify
endmodule

module ao1b3(Y, A, B, C);
        output Y;
        input  A, B, C;
        not g1(N2, A);
        and g2(N1, N2, B);
        or g3(Y, N1, C);
        // SPECIFY BLOCK
        specify
                specparam A_LH_Y = 0, A_HL_Y = 0 ;
                specparam B_LH_Y = 0, B_HL_Y = 0 ;
                specparam C_LH_Y = 0, C_HL_Y = 0 ;
                (A *> Y) = (A_LH_Y, A_HL_Y) ;
                (B *> Y) = (B_LH_Y, B_HL_Y) ;
                (C *> Y) = (C_LH_Y, C_HL_Y) ;
        endspecify
endmodule

module ao1b6(Y, A, B, C);
        output Y;
        input  A, B, C;
        not g1(N2, A);
        and g2(N1, N2, B);
        or g3(Y, N1, C);
        // SPECIFY BLOCK
        specify
                specparam A_LH_Y = 0, A_HL_Y = 0 ;
                specparam B_LH_Y = 0, B_HL_Y = 0 ;
                specparam C_LH_Y = 0, C_HL_Y = 0 ;
                (A *> Y) = (A_LH_Y, A_HL_Y) ;
                (B *> Y) = (B_LH_Y, B_HL_Y) ;
                (C *> Y) = (C_LH_Y, C_HL_Y) ;
        endspecify
endmodule

module ao1b9(Y, A, B, C);
        output Y;
        input  A, B, C;
        not g1(N2, A);
        and g2(N1, N2, B);
        or g3(Y, N1, C);
        // SPECIFY BLOCK
        specify
                specparam A_LH_Y = 0, A_HL_Y = 0 ;
                specparam B_LH_Y = 0, B_HL_Y = 0 ;
                specparam C_LH_Y = 0, C_HL_Y = 0 ;
                (A *> Y) = (A_LH_Y, A_HL_Y) ;
                (B *> Y) = (B_LH_Y, B_HL_Y) ;
                (C *> Y) = (C_LH_Y, C_HL_Y) ;
        endspecify
endmodule

module ao1c1(Y, A, B, C);
        output Y;
        input  A, B, C;
        not g1(N2, A);
        not g2(N3, B);
        and g3(N1, N2, N3);
        or g4(Y, N1, C);
        // SPECIFY BLOCK
        specify
                specparam A_LH_Y = 0, A_HL_Y = 0 ;
                specparam B_LH_Y = 0, B_HL_Y = 0 ;
                specparam C_LH_Y = 0, C_HL_Y = 0 ;
                (A *> Y) = (A_LH_Y, A_HL_Y) ;
                (B *> Y) = (B_LH_Y, B_HL_Y) ;
                (C *> Y) = (C_LH_Y, C_HL_Y) ;
        endspecify
endmodule

module ao1c15(Y, A, B, C);
        output Y;
        input  A, B, C;
        not g1(N2, A);
        not g2(N3, B);
        and g3(N1, N2, N3);
        or g4(Y, N1, C);
        // SPECIFY BLOCK
        specify
                specparam A_LH_Y = 0, A_HL_Y = 0 ;
                specparam B_LH_Y = 0, B_HL_Y = 0 ;
                specparam C_LH_Y = 0, C_HL_Y = 0 ;
                (A *> Y) = (A_LH_Y, A_HL_Y) ;
                (B *> Y) = (B_LH_Y, B_HL_Y) ;
                (C *> Y) = (C_LH_Y, C_HL_Y) ;
        endspecify
endmodule

module ao1c2(Y, A, B, C);
        output Y;
        input  A, B, C;
        not g1(N2, A);
        not g2(N3, B);
        and g3(N1, N2, N3);
        or g4(Y, N1, C);
        // SPECIFY BLOCK
        specify
                specparam A_LH_Y = 0, A_HL_Y = 0 ;
                specparam B_LH_Y = 0, B_HL_Y = 0 ;
                specparam C_LH_Y = 0, C_HL_Y = 0 ;
                (A *> Y) = (A_LH_Y, A_HL_Y) ;
                (B *> Y) = (B_LH_Y, B_HL_Y) ;
                (C *> Y) = (C_LH_Y, C_HL_Y) ;
        endspecify
endmodule

module ao1c3(Y, A, B, C);
        output Y;
        input  A, B, C;
        not g1(N2, A);
        not g2(N3, B);
        and g3(N1, N2, N3);
        or g4(Y, N1, C);
        // SPECIFY BLOCK
        specify
                specparam A_LH_Y = 0, A_HL_Y = 0 ;
                specparam B_LH_Y = 0, B_HL_Y = 0 ;
                specparam C_LH_Y = 0, C_HL_Y = 0 ;
                (A *> Y) = (A_LH_Y, A_HL_Y) ;
                (B *> Y) = (B_LH_Y, B_HL_Y) ;
                (C *> Y) = (C_LH_Y, C_HL_Y) ;
        endspecify
endmodule

module ao1c6(Y, A, B, C);
        output Y;
        input  A, B, C;
        not g1(N2, A);
        not g2(N3, B);
        and g3(N1, N2, N3);
        or g4(Y, N1, C);
        // SPECIFY BLOCK
        specify
                specparam A_LH_Y = 0, A_HL_Y = 0 ;
                specparam B_LH_Y = 0, B_HL_Y = 0 ;
                specparam C_LH_Y = 0, C_HL_Y = 0 ;
                (A *> Y) = (A_LH_Y, A_HL_Y) ;
                (B *> Y) = (B_LH_Y, B_HL_Y) ;
                (C *> Y) = (C_LH_Y, C_HL_Y) ;
        endspecify
endmodule

module ao1c9(Y, A, B, C);
        output Y;
        input  A, B, C;
        not g1(N2, A);
        not g2(N3, B);
        and g3(N1, N2, N3);
        or g4(Y, N1, C);
        // SPECIFY BLOCK
        specify
                specparam A_LH_Y = 0, A_HL_Y = 0 ;
                specparam B_LH_Y = 0, B_HL_Y = 0 ;
                specparam C_LH_Y = 0, C_HL_Y = 0 ;
                (A *> Y) = (A_LH_Y, A_HL_Y) ;
                (B *> Y) = (B_LH_Y, B_HL_Y) ;
                (C *> Y) = (C_LH_Y, C_HL_Y) ;
        endspecify
endmodule

module ao1d1(Y, A, B, C);
        output Y;
        input  A, B, C;
        and g1(N1, A, B);
        not g2(N2, C);
        or g3(Y, N1, N2);
        // SPECIFY BLOCK
        specify
                specparam A_LH_Y = 0, A_HL_Y = 0 ;
                specparam B_LH_Y = 0, B_HL_Y = 0 ;
                specparam C_LH_Y = 0, C_HL_Y = 0 ;
                (A *> Y) = (A_LH_Y, A_HL_Y) ;
                (B *> Y) = (B_LH_Y, B_HL_Y) ;
                (C *> Y) = (C_LH_Y, C_HL_Y) ;
        endspecify
endmodule

module ao1d15(Y, A, B, C);
        output Y;
        input  A, B, C;
        and g1(N1, A, B);
        not g2(N2, C);
        or g3(Y, N1, N2);
        // SPECIFY BLOCK
        specify
                specparam A_LH_Y = 0, A_HL_Y = 0 ;
                specparam B_LH_Y = 0, B_HL_Y = 0 ;
                specparam C_LH_Y = 0, C_HL_Y = 0 ;
                (A *> Y) = (A_LH_Y, A_HL_Y) ;
                (B *> Y) = (B_LH_Y, B_HL_Y) ;
                (C *> Y) = (C_LH_Y, C_HL_Y) ;
        endspecify
endmodule

module ao1d2(Y, A, B, C);
        output Y;
        input  A, B, C;
        and g1(N1, A, B);
        not g2(N2, C);
        or g3(Y, N1, N2);
        // SPECIFY BLOCK
        specify
                specparam A_LH_Y = 0, A_HL_Y = 0 ;
                specparam B_LH_Y = 0, B_HL_Y = 0 ;
                specparam C_LH_Y = 0, C_HL_Y = 0 ;
                (A *> Y) = (A_LH_Y, A_HL_Y) ;
                (B *> Y) = (B_LH_Y, B_HL_Y) ;
                (C *> Y) = (C_LH_Y, C_HL_Y) ;
        endspecify
endmodule

module ao1d3(Y, A, B, C);
        output Y;
        input  A, B, C;
        and g1(N1, A, B);
        not g2(N2, C);
        or g3(Y, N1, N2);
        // SPECIFY BLOCK
        specify
                specparam A_LH_Y = 0, A_HL_Y = 0 ;
                specparam B_LH_Y = 0, B_HL_Y = 0 ;
                specparam C_LH_Y = 0, C_HL_Y = 0 ;
                (A *> Y) = (A_LH_Y, A_HL_Y) ;
                (B *> Y) = (B_LH_Y, B_HL_Y) ;
                (C *> Y) = (C_LH_Y, C_HL_Y) ;
        endspecify
endmodule

module ao1d6(Y, A, B, C);
        output Y;
        input  A, B, C;
        and g1(N1, A, B);
        not g2(N2, C);
        or g3(Y, N1, N2);
        // SPECIFY BLOCK
        specify
                specparam A_LH_Y = 0, A_HL_Y = 0 ;
                specparam B_LH_Y = 0, B_HL_Y = 0 ;
                specparam C_LH_Y = 0, C_HL_Y = 0 ;
                (A *> Y) = (A_LH_Y, A_HL_Y) ;
                (B *> Y) = (B_LH_Y, B_HL_Y) ;
                (C *> Y) = (C_LH_Y, C_HL_Y) ;
        endspecify
endmodule

module ao1d9(Y, A, B, C);
        output Y;
        input  A, B, C;
        and g1(N1, A, B);
        not g2(N2, C);
        or g3(Y, N1, N2);
        // SPECIFY BLOCK
        specify
                specparam A_LH_Y = 0, A_HL_Y = 0 ;
                specparam B_LH_Y = 0, B_HL_Y = 0 ;
                specparam C_LH_Y = 0, C_HL_Y = 0 ;
                (A *> Y) = (A_LH_Y, A_HL_Y) ;
                (B *> Y) = (B_LH_Y, B_HL_Y) ;
                (C *> Y) = (C_LH_Y, C_HL_Y) ;
        endspecify
endmodule

module ao1e1(Y, A, B, C);
        output Y;
        input  A, B, C;
        not g1(N2, A);
        and g2(N1, N2, B);
        not g3(N3, C);
        or g4(Y, N1, N3);
        // SPECIFY BLOCK
        specify
                specparam A_LH_Y = 0, A_HL_Y = 0 ;
                specparam B_LH_Y = 0, B_HL_Y = 0 ;
                specparam C_LH_Y = 0, C_HL_Y = 0 ;
                (A *> Y) = (A_LH_Y, A_HL_Y) ;
                (B *> Y) = (B_LH_Y, B_HL_Y) ;
                (C *> Y) = (C_LH_Y, C_HL_Y) ;
        endspecify
endmodule

module ao1e15(Y, A, B, C);
        output Y;
        input  A, B, C;
        not g1(N2, A);
        and g2(N1, N2, B);
        not g3(N3, C);
        or g4(Y, N1, N3);
        // SPECIFY BLOCK
        specify
                specparam A_LH_Y = 0, A_HL_Y = 0 ;
                specparam B_LH_Y = 0, B_HL_Y = 0 ;
                specparam C_LH_Y = 0, C_HL_Y = 0 ;
                (A *> Y) = (A_LH_Y, A_HL_Y) ;
                (B *> Y) = (B_LH_Y, B_HL_Y) ;
                (C *> Y) = (C_LH_Y, C_HL_Y) ;
        endspecify
endmodule

module ao1e2(Y, A, B, C);
        output Y;
        input  A, B, C;
        not g1(N2, A);
        and g2(N1, N2, B);
        not g3(N3, C);
        or g4(Y, N1, N3);
        // SPECIFY BLOCK
        specify
                specparam A_LH_Y = 0, A_HL_Y = 0 ;
                specparam B_LH_Y = 0, B_HL_Y = 0 ;
                specparam C_LH_Y = 0, C_HL_Y = 0 ;
                (A *> Y) = (A_LH_Y, A_HL_Y) ;
                (B *> Y) = (B_LH_Y, B_HL_Y) ;
                (C *> Y) = (C_LH_Y, C_HL_Y) ;
        endspecify
endmodule

module ao1e3(Y, A, B, C);
        output Y;
        input  A, B, C;
        not g1(N2, A);
        and g2(N1, N2, B);
        not g3(N3, C);
        or g4(Y, N1, N3);
        // SPECIFY BLOCK
        specify
                specparam A_LH_Y = 0, A_HL_Y = 0 ;
                specparam B_LH_Y = 0, B_HL_Y = 0 ;
                specparam C_LH_Y = 0, C_HL_Y = 0 ;
                (A *> Y) = (A_LH_Y, A_HL_Y) ;
                (B *> Y) = (B_LH_Y, B_HL_Y) ;
                (C *> Y) = (C_LH_Y, C_HL_Y) ;
        endspecify
endmodule

module ao1e6(Y, A, B, C);
        output Y;
        input  A, B, C;
        not g1(N2, A);
        and g2(N1, N2, B);
        not g3(N3, C);
        or g4(Y, N1, N3);
        // SPECIFY BLOCK
        specify
                specparam A_LH_Y = 0, A_HL_Y = 0 ;
                specparam B_LH_Y = 0, B_HL_Y = 0 ;
                specparam C_LH_Y = 0, C_HL_Y = 0 ;
                (A *> Y) = (A_LH_Y, A_HL_Y) ;
                (B *> Y) = (B_LH_Y, B_HL_Y) ;
                (C *> Y) = (C_LH_Y, C_HL_Y) ;
        endspecify
endmodule

module ao1e9(Y, A, B, C);
        output Y;
        input  A, B, C;
        not g1(N2, A);
        and g2(N1, N2, B);
        not g3(N3, C);
        or g4(Y, N1, N3);
        // SPECIFY BLOCK
        specify
                specparam A_LH_Y = 0, A_HL_Y = 0 ;
                specparam B_LH_Y = 0, B_HL_Y = 0 ;
                specparam C_LH_Y = 0, C_HL_Y = 0 ;
                (A *> Y) = (A_LH_Y, A_HL_Y) ;
                (B *> Y) = (B_LH_Y, B_HL_Y) ;
                (C *> Y) = (C_LH_Y, C_HL_Y) ;
        endspecify
endmodule

module ao1f1(Y, A, B, C);
        output Y;
        input  A, B, C;
        not g1(N2, A);
        not g2(N3, B);
        and g3(N1, N2, N3);
        not g4(N4, C);
        or g5(Y, N1, N4);
        // SPECIFY BLOCK
        specify
                specparam A_LH_Y = 0, A_HL_Y = 0 ;
                specparam B_LH_Y = 0, B_HL_Y = 0 ;
                specparam C_LH_Y = 0, C_HL_Y = 0 ;
                (A *> Y) = (A_LH_Y, A_HL_Y) ;
                (B *> Y) = (B_LH_Y, B_HL_Y) ;
                (C *> Y) = (C_LH_Y, C_HL_Y) ;
        endspecify
endmodule

module ao1f15(Y, A, B, C);
        output Y;
        input  A, B, C;
        not g1(N2, A);
        not g2(N3, B);
        and g3(N1, N2, N3);
        not g4(N4, C);
        or g5(Y, N1, N4);
        // SPECIFY BLOCK
        specify
                specparam A_LH_Y = 0, A_HL_Y = 0 ;
                specparam B_LH_Y = 0, B_HL_Y = 0 ;
                specparam C_LH_Y = 0, C_HL_Y = 0 ;
                (A *> Y) = (A_LH_Y, A_HL_Y) ;
                (B *> Y) = (B_LH_Y, B_HL_Y) ;
                (C *> Y) = (C_LH_Y, C_HL_Y) ;
        endspecify
endmodule

module ao1f2(Y, A, B, C);
        output Y;
        input  A, B, C;
        not g1(N2, A);
        not g2(N3, B);
        and g3(N1, N2, N3);
        not g4(N4, C);
        or g5(Y, N1, N4);
        // SPECIFY BLOCK
        specify
                specparam A_LH_Y = 0, A_HL_Y = 0 ;
                specparam B_LH_Y = 0, B_HL_Y = 0 ;
                specparam C_LH_Y = 0, C_HL_Y = 0 ;
                (A *> Y) = (A_LH_Y, A_HL_Y) ;
                (B *> Y) = (B_LH_Y, B_HL_Y) ;
                (C *> Y) = (C_LH_Y, C_HL_Y) ;
        endspecify
endmodule

module ao1f3(Y, A, B, C);
        output Y;
        input  A, B, C;
        not g1(N2, A);
        not g2(N3, B);
        and g3(N1, N2, N3);
        not g4(N4, C);
        or g5(Y, N1, N4);
        // SPECIFY BLOCK
        specify
                specparam A_LH_Y = 0, A_HL_Y = 0 ;
                specparam B_LH_Y = 0, B_HL_Y = 0 ;
                specparam C_LH_Y = 0, C_HL_Y = 0 ;
                (A *> Y) = (A_LH_Y, A_HL_Y) ;
                (B *> Y) = (B_LH_Y, B_HL_Y) ;
                (C *> Y) = (C_LH_Y, C_HL_Y) ;
        endspecify
endmodule

module ao1f6(Y, A, B, C);
        output Y;
        input  A, B, C;
        not g1(N2, A);
        not g2(N3, B);
        and g3(N1, N2, N3);
        not g4(N4, C);
        or g5(Y, N1, N4);
        // SPECIFY BLOCK
        specify
                specparam A_LH_Y = 0, A_HL_Y = 0 ;
                specparam B_LH_Y = 0, B_HL_Y = 0 ;
                specparam C_LH_Y = 0, C_HL_Y = 0 ;
                (A *> Y) = (A_LH_Y, A_HL_Y) ;
                (B *> Y) = (B_LH_Y, B_HL_Y) ;
                (C *> Y) = (C_LH_Y, C_HL_Y) ;
        endspecify
endmodule

module ao1f9(Y, A, B, C);
        output Y;
        input  A, B, C;
        not g1(N2, A);
        not g2(N3, B);
        and g3(N1, N2, N3);
        not g4(N4, C);
        or g5(Y, N1, N4);
        // SPECIFY BLOCK
        specify
                specparam A_LH_Y = 0, A_HL_Y = 0 ;
                specparam B_LH_Y = 0, B_HL_Y = 0 ;
                specparam C_LH_Y = 0, C_HL_Y = 0 ;
                (A *> Y) = (A_LH_Y, A_HL_Y) ;
                (B *> Y) = (B_LH_Y, B_HL_Y) ;
                (C *> Y) = (C_LH_Y, C_HL_Y) ;
        endspecify
endmodule

module ao2a1(Y, A, B, C, D);
        output Y;
        input  A, B, C, D;
        and g1(N1, A, B);
        or g2(Y, C, D, N1);
        // SPECIFY BLOCK
        specify
                specparam A_LH_Y = 0, A_HL_Y = 0 ;
                specparam B_LH_Y = 0, B_HL_Y = 0 ;
                specparam C_LH_Y = 0, C_HL_Y = 0 ;
                specparam D_LH_Y = 0, D_HL_Y = 0 ;
                (A *> Y) = (A_LH_Y, A_HL_Y) ;
                (B *> Y) = (B_LH_Y, B_HL_Y) ;
                (C *> Y) = (C_LH_Y, C_HL_Y) ;
                (D *> Y) = (D_LH_Y, D_HL_Y) ;
        endspecify
endmodule

module ao2a15(Y, A, B, C, D);
        output Y;
        input  A, B, C, D;
        and g1(N1, A, B);
        or g2(Y, C, D, N1);
        // SPECIFY BLOCK
        specify
                specparam A_LH_Y = 0, A_HL_Y = 0 ;
                specparam B_LH_Y = 0, B_HL_Y = 0 ;
                specparam C_LH_Y = 0, C_HL_Y = 0 ;
                specparam D_LH_Y = 0, D_HL_Y = 0 ;
                (A *> Y) = (A_LH_Y, A_HL_Y) ;
                (B *> Y) = (B_LH_Y, B_HL_Y) ;
                (C *> Y) = (C_LH_Y, C_HL_Y) ;
                (D *> Y) = (D_LH_Y, D_HL_Y) ;
        endspecify
endmodule

module ao2a2(Y, A, B, C, D);
        output Y;
        input  A, B, C, D;
        and g1(N1, A, B);
        or g2(Y, C, D, N1);
        // SPECIFY BLOCK
        specify
                specparam A_LH_Y = 0, A_HL_Y = 0 ;
                specparam B_LH_Y = 0, B_HL_Y = 0 ;
                specparam C_LH_Y = 0, C_HL_Y = 0 ;
                specparam D_LH_Y = 0, D_HL_Y = 0 ;
                (A *> Y) = (A_LH_Y, A_HL_Y) ;
                (B *> Y) = (B_LH_Y, B_HL_Y) ;
                (C *> Y) = (C_LH_Y, C_HL_Y) ;
                (D *> Y) = (D_LH_Y, D_HL_Y) ;
        endspecify
endmodule

module ao2a3(Y, A, B, C, D);
        output Y;
        input  A, B, C, D;
        and g1(N1, A, B);
        or g2(Y, C, D, N1);
        // SPECIFY BLOCK
        specify
                specparam A_LH_Y = 0, A_HL_Y = 0 ;
                specparam B_LH_Y = 0, B_HL_Y = 0 ;
                specparam C_LH_Y = 0, C_HL_Y = 0 ;
                specparam D_LH_Y = 0, D_HL_Y = 0 ;
                (A *> Y) = (A_LH_Y, A_HL_Y) ;
                (B *> Y) = (B_LH_Y, B_HL_Y) ;
                (C *> Y) = (C_LH_Y, C_HL_Y) ;
                (D *> Y) = (D_LH_Y, D_HL_Y) ;
        endspecify
endmodule

module ao2a6(Y, A, B, C, D);
        output Y;
        input  A, B, C, D;
        and g1(N1, A, B);
        or g2(Y, C, D, N1);
        // SPECIFY BLOCK
        specify
                specparam A_LH_Y = 0, A_HL_Y = 0 ;
                specparam B_LH_Y = 0, B_HL_Y = 0 ;
                specparam C_LH_Y = 0, C_HL_Y = 0 ;
                specparam D_LH_Y = 0, D_HL_Y = 0 ;
                (A *> Y) = (A_LH_Y, A_HL_Y) ;
                (B *> Y) = (B_LH_Y, B_HL_Y) ;
                (C *> Y) = (C_LH_Y, C_HL_Y) ;
                (D *> Y) = (D_LH_Y, D_HL_Y) ;
        endspecify
endmodule

module ao2a9(Y, A, B, C, D);
        output Y;
        input  A, B, C, D;
        and g1(N1, A, B);
        or g2(Y, C, D, N1);
        // SPECIFY BLOCK
        specify
                specparam A_LH_Y = 0, A_HL_Y = 0 ;
                specparam B_LH_Y = 0, B_HL_Y = 0 ;
                specparam C_LH_Y = 0, C_HL_Y = 0 ;
                specparam D_LH_Y = 0, D_HL_Y = 0 ;
                (A *> Y) = (A_LH_Y, A_HL_Y) ;
                (B *> Y) = (B_LH_Y, B_HL_Y) ;
                (C *> Y) = (C_LH_Y, C_HL_Y) ;
                (D *> Y) = (D_LH_Y, D_HL_Y) ;
        endspecify
endmodule

module ao2e1(Y, A, B, C, D);
        output Y;
        input  A, B, C, D;
        not g1(N1, C);
        not g2(N3, A);
        and g3(N2, N3, B);
        or g4(Y, N1, D, N2);
        // SPECIFY BLOCK
        specify
                specparam A_LH_Y = 0, A_HL_Y = 0 ;
                specparam B_LH_Y = 0, B_HL_Y = 0 ;
                specparam C_LH_Y = 0, C_HL_Y = 0 ;
                specparam D_LH_Y = 0, D_HL_Y = 0 ;
                (A *> Y) = (A_LH_Y, A_HL_Y) ;
                (B *> Y) = (B_LH_Y, B_HL_Y) ;
                (C *> Y) = (C_LH_Y, C_HL_Y) ;
                (D *> Y) = (D_LH_Y, D_HL_Y) ;
        endspecify
endmodule

module ao2e15(Y, A, B, C, D);
        output Y;
        input  A, B, C, D;
        not g1(N1, C);
        not g2(N3, A);
        and g3(N2, N3, B);
        or g4(Y, N1, D, N2);
        // SPECIFY BLOCK
        specify
                specparam A_LH_Y = 0, A_HL_Y = 0 ;
                specparam B_LH_Y = 0, B_HL_Y = 0 ;
                specparam C_LH_Y = 0, C_HL_Y = 0 ;
                specparam D_LH_Y = 0, D_HL_Y = 0 ;
                (A *> Y) = (A_LH_Y, A_HL_Y) ;
                (B *> Y) = (B_LH_Y, B_HL_Y) ;
                (C *> Y) = (C_LH_Y, C_HL_Y) ;
                (D *> Y) = (D_LH_Y, D_HL_Y) ;
        endspecify
endmodule

module ao2e2(Y, A, B, C, D);
        output Y;
        input  A, B, C, D;
        not g1(N1, C);
        not g2(N3, A);
        and g3(N2, N3, B);
        or g4(Y, N1, D, N2);
        // SPECIFY BLOCK
        specify
                specparam A_LH_Y = 0, A_HL_Y = 0 ;
                specparam B_LH_Y = 0, B_HL_Y = 0 ;
                specparam C_LH_Y = 0, C_HL_Y = 0 ;
                specparam D_LH_Y = 0, D_HL_Y = 0 ;
                (A *> Y) = (A_LH_Y, A_HL_Y) ;
                (B *> Y) = (B_LH_Y, B_HL_Y) ;
                (C *> Y) = (C_LH_Y, C_HL_Y) ;
                (D *> Y) = (D_LH_Y, D_HL_Y) ;
        endspecify
endmodule

module ao2e3(Y, A, B, C, D);
        output Y;
        input  A, B, C, D;
        not g1(N1, C);
        not g2(N3, A);
        and g3(N2, N3, B);
        or g4(Y, N1, D, N2);
        // SPECIFY BLOCK
        specify
                specparam A_LH_Y = 0, A_HL_Y = 0 ;
                specparam B_LH_Y = 0, B_HL_Y = 0 ;
                specparam C_LH_Y = 0, C_HL_Y = 0 ;
                specparam D_LH_Y = 0, D_HL_Y = 0 ;
                (A *> Y) = (A_LH_Y, A_HL_Y) ;
                (B *> Y) = (B_LH_Y, B_HL_Y) ;
                (C *> Y) = (C_LH_Y, C_HL_Y) ;
                (D *> Y) = (D_LH_Y, D_HL_Y) ;
        endspecify
endmodule

module ao2e6(Y, A, B, C, D);
        output Y;
        input  A, B, C, D;
        not g1(N1, C);
        not g2(N3, A);
        and g3(N2, N3, B);
        or g4(Y, N1, D, N2);
        // SPECIFY BLOCK
        specify
                specparam A_LH_Y = 0, A_HL_Y = 0 ;
                specparam B_LH_Y = 0, B_HL_Y = 0 ;
                specparam C_LH_Y = 0, C_HL_Y = 0 ;
                specparam D_LH_Y = 0, D_HL_Y = 0 ;
                (A *> Y) = (A_LH_Y, A_HL_Y) ;
                (B *> Y) = (B_LH_Y, B_HL_Y) ;
                (C *> Y) = (C_LH_Y, C_HL_Y) ;
                (D *> Y) = (D_LH_Y, D_HL_Y) ;
        endspecify
endmodule

module ao2e9(Y, A, B, C, D);
        output Y;
        input  A, B, C, D;
        not g1(N1, C);
        not g2(N3, A);
        and g3(N2, N3, B);
        or g4(Y, N1, D, N2);
        // SPECIFY BLOCK
        specify
                specparam A_LH_Y = 0, A_HL_Y = 0 ;
                specparam B_LH_Y = 0, B_HL_Y = 0 ;
                specparam C_LH_Y = 0, C_HL_Y = 0 ;
                specparam D_LH_Y = 0, D_HL_Y = 0 ;
                (A *> Y) = (A_LH_Y, A_HL_Y) ;
                (B *> Y) = (B_LH_Y, B_HL_Y) ;
                (C *> Y) = (C_LH_Y, C_HL_Y) ;
                (D *> Y) = (D_LH_Y, D_HL_Y) ;
        endspecify
endmodule

module ao2h1(Y, A, B, C, D);
        output Y;
        input  A, B, C, D;
        not g1(N1, C);
        not g2(N2, D);
        not g3(N4, A);
        and g4(N3, N4, B);
        or g5(Y, N1, N2, N3);
        // SPECIFY BLOCK
        specify
                specparam A_LH_Y = 0, A_HL_Y = 0 ;
                specparam B_LH_Y = 0, B_HL_Y = 0 ;
                specparam C_LH_Y = 0, C_HL_Y = 0 ;
                specparam D_LH_Y = 0, D_HL_Y = 0 ;
                (A *> Y) = (A_LH_Y, A_HL_Y) ;
                (B *> Y) = (B_LH_Y, B_HL_Y) ;
                (C *> Y) = (C_LH_Y, C_HL_Y) ;
                (D *> Y) = (D_LH_Y, D_HL_Y) ;
        endspecify
endmodule

module ao2h15(Y, A, B, C, D);
        output Y;
        input  A, B, C, D;
        not g1(N1, C);
        not g2(N2, D);
        not g3(N4, A);
        and g4(N3, N4, B);
        or g5(Y, N1, N2, N3);
        // SPECIFY BLOCK
        specify
                specparam A_LH_Y = 0, A_HL_Y = 0 ;
                specparam B_LH_Y = 0, B_HL_Y = 0 ;
                specparam C_LH_Y = 0, C_HL_Y = 0 ;
                specparam D_LH_Y = 0, D_HL_Y = 0 ;
                (A *> Y) = (A_LH_Y, A_HL_Y) ;
                (B *> Y) = (B_LH_Y, B_HL_Y) ;
                (C *> Y) = (C_LH_Y, C_HL_Y) ;
                (D *> Y) = (D_LH_Y, D_HL_Y) ;
        endspecify
endmodule

module ao2h2(Y, A, B, C, D);
        output Y;
        input  A, B, C, D;
        not g1(N1, C);
        not g2(N2, D);
        not g3(N4, A);
        and g4(N3, N4, B);
        or g5(Y, N1, N2, N3);
        // SPECIFY BLOCK
        specify
                specparam A_LH_Y = 0, A_HL_Y = 0 ;
                specparam B_LH_Y = 0, B_HL_Y = 0 ;
                specparam C_LH_Y = 0, C_HL_Y = 0 ;
                specparam D_LH_Y = 0, D_HL_Y = 0 ;
                (A *> Y) = (A_LH_Y, A_HL_Y) ;
                (B *> Y) = (B_LH_Y, B_HL_Y) ;
                (C *> Y) = (C_LH_Y, C_HL_Y) ;
                (D *> Y) = (D_LH_Y, D_HL_Y) ;
        endspecify
endmodule

module ao2h3(Y, A, B, C, D);
        output Y;
        input  A, B, C, D;
        not g1(N1, C);
        not g2(N2, D);
        not g3(N4, A);
        and g4(N3, N4, B);
        or g5(Y, N1, N2, N3);
        // SPECIFY BLOCK
        specify
                specparam A_LH_Y = 0, A_HL_Y = 0 ;
                specparam B_LH_Y = 0, B_HL_Y = 0 ;
                specparam C_LH_Y = 0, C_HL_Y = 0 ;
                specparam D_LH_Y = 0, D_HL_Y = 0 ;
                (A *> Y) = (A_LH_Y, A_HL_Y) ;
                (B *> Y) = (B_LH_Y, B_HL_Y) ;
                (C *> Y) = (C_LH_Y, C_HL_Y) ;
                (D *> Y) = (D_LH_Y, D_HL_Y) ;
        endspecify
endmodule

module ao2h6(Y, A, B, C, D);
        output Y;
        input  A, B, C, D;
        not g1(N1, C);
        not g2(N2, D);
        not g3(N4, A);
        and g4(N3, N4, B);
        or g5(Y, N1, N2, N3);
        // SPECIFY BLOCK
        specify
                specparam A_LH_Y = 0, A_HL_Y = 0 ;
                specparam B_LH_Y = 0, B_HL_Y = 0 ;
                specparam C_LH_Y = 0, C_HL_Y = 0 ;
                specparam D_LH_Y = 0, D_HL_Y = 0 ;
                (A *> Y) = (A_LH_Y, A_HL_Y) ;
                (B *> Y) = (B_LH_Y, B_HL_Y) ;
                (C *> Y) = (C_LH_Y, C_HL_Y) ;
                (D *> Y) = (D_LH_Y, D_HL_Y) ;
        endspecify
endmodule

module ao2h9(Y, A, B, C, D);
        output Y;
        input  A, B, C, D;
        not g1(N1, C);
        not g2(N2, D);
        not g3(N4, A);
        and g4(N3, N4, B);
        or g5(Y, N1, N2, N3);
        // SPECIFY BLOCK
        specify
                specparam A_LH_Y = 0, A_HL_Y = 0 ;
                specparam B_LH_Y = 0, B_HL_Y = 0 ;
                specparam C_LH_Y = 0, C_HL_Y = 0 ;
                specparam D_LH_Y = 0, D_HL_Y = 0 ;
                (A *> Y) = (A_LH_Y, A_HL_Y) ;
                (B *> Y) = (B_LH_Y, B_HL_Y) ;
                (C *> Y) = (C_LH_Y, C_HL_Y) ;
                (D *> Y) = (D_LH_Y, D_HL_Y) ;
        endspecify
endmodule

module ao2i1(Y, A, B, C, D);
        output Y;
        input  A, B, C, D;
        not g1(N1, C);
        not g2(N2, D);
        not g3(N4, A);
        not g4(N5, B);
        and g5(N3, N4, N5);
        or g6(Y, N1, N2, N3);
        // SPECIFY BLOCK
        specify
                specparam A_LH_Y = 0, A_HL_Y = 0 ;
                specparam B_LH_Y = 0, B_HL_Y = 0 ;
                specparam C_LH_Y = 0, C_HL_Y = 0 ;
                specparam D_LH_Y = 0, D_HL_Y = 0 ;
                (A *> Y) = (A_LH_Y, A_HL_Y) ;
                (B *> Y) = (B_LH_Y, B_HL_Y) ;
                (C *> Y) = (C_LH_Y, C_HL_Y) ;
                (D *> Y) = (D_LH_Y, D_HL_Y) ;
        endspecify
endmodule

module ao2i15(Y, A, B, C, D);
        output Y;
        input  A, B, C, D;
        not g1(N1, C);
        not g2(N2, D);
        not g3(N4, A);
        not g4(N5, B);
        and g5(N3, N4, N5);
        or g6(Y, N1, N2, N3);
        // SPECIFY BLOCK
        specify
                specparam A_LH_Y = 0, A_HL_Y = 0 ;
                specparam B_LH_Y = 0, B_HL_Y = 0 ;
                specparam C_LH_Y = 0, C_HL_Y = 0 ;
                specparam D_LH_Y = 0, D_HL_Y = 0 ;
                (A *> Y) = (A_LH_Y, A_HL_Y) ;
                (B *> Y) = (B_LH_Y, B_HL_Y) ;
                (C *> Y) = (C_LH_Y, C_HL_Y) ;
                (D *> Y) = (D_LH_Y, D_HL_Y) ;
        endspecify
endmodule

module ao2i2(Y, A, B, C, D);
        output Y;
        input  A, B, C, D;
        not g1(N1, C);
        not g2(N2, D);
        not g3(N4, A);
        not g4(N5, B);
        and g5(N3, N4, N5);
        or g6(Y, N1, N2, N3);
        // SPECIFY BLOCK
        specify
                specparam A_LH_Y = 0, A_HL_Y = 0 ;
                specparam B_LH_Y = 0, B_HL_Y = 0 ;
                specparam C_LH_Y = 0, C_HL_Y = 0 ;
                specparam D_LH_Y = 0, D_HL_Y = 0 ;
                (A *> Y) = (A_LH_Y, A_HL_Y) ;
                (B *> Y) = (B_LH_Y, B_HL_Y) ;
                (C *> Y) = (C_LH_Y, C_HL_Y) ;
                (D *> Y) = (D_LH_Y, D_HL_Y) ;
        endspecify
endmodule

module ao2i3(Y, A, B, C, D);
        output Y;
        input  A, B, C, D;
        not g1(N1, C);
        not g2(N2, D);
        not g3(N4, A);
        not g4(N5, B);
        and g5(N3, N4, N5);
        or g6(Y, N1, N2, N3);
        // SPECIFY BLOCK
        specify
                specparam A_LH_Y = 0, A_HL_Y = 0 ;
                specparam B_LH_Y = 0, B_HL_Y = 0 ;
                specparam C_LH_Y = 0, C_HL_Y = 0 ;
                specparam D_LH_Y = 0, D_HL_Y = 0 ;
                (A *> Y) = (A_LH_Y, A_HL_Y) ;
                (B *> Y) = (B_LH_Y, B_HL_Y) ;
                (C *> Y) = (C_LH_Y, C_HL_Y) ;
                (D *> Y) = (D_LH_Y, D_HL_Y) ;
        endspecify
endmodule

module ao2i6(Y, A, B, C, D);
        output Y;
        input  A, B, C, D;
        not g1(N1, C);
        not g2(N2, D);
        not g3(N4, A);
        not g4(N5, B);
        and g5(N3, N4, N5);
        or g6(Y, N1, N2, N3);
        // SPECIFY BLOCK
        specify
                specparam A_LH_Y = 0, A_HL_Y = 0 ;
                specparam B_LH_Y = 0, B_HL_Y = 0 ;
                specparam C_LH_Y = 0, C_HL_Y = 0 ;
                specparam D_LH_Y = 0, D_HL_Y = 0 ;
                (A *> Y) = (A_LH_Y, A_HL_Y) ;
                (B *> Y) = (B_LH_Y, B_HL_Y) ;
                (C *> Y) = (C_LH_Y, C_HL_Y) ;
                (D *> Y) = (D_LH_Y, D_HL_Y) ;
        endspecify
endmodule

module ao2i9(Y, A, B, C, D);
        output Y;
        input  A, B, C, D;
        not g1(N1, C);
        not g2(N2, D);
        not g3(N4, A);
        not g4(N5, B);
        and g5(N3, N4, N5);
        or g6(Y, N1, N2, N3);
        // SPECIFY BLOCK
        specify
                specparam A_LH_Y = 0, A_HL_Y = 0 ;
                specparam B_LH_Y = 0, B_HL_Y = 0 ;
                specparam C_LH_Y = 0, C_HL_Y = 0 ;
                specparam D_LH_Y = 0, D_HL_Y = 0 ;
                (A *> Y) = (A_LH_Y, A_HL_Y) ;
                (B *> Y) = (B_LH_Y, B_HL_Y) ;
                (C *> Y) = (C_LH_Y, C_HL_Y) ;
                (D *> Y) = (D_LH_Y, D_HL_Y) ;
        endspecify
endmodule

module ao4a1(Y, A, B, C, D);
        output Y;
        input  A, B, C, D;
        and g1(N1, A, B);
        and g2(N2, C, D);
        or g3(Y, N1, N2);
        // SPECIFY BLOCK
        specify
                specparam A_LH_Y = 0, A_HL_Y = 0 ;
                specparam B_LH_Y = 0, B_HL_Y = 0 ;
                specparam C_LH_Y = 0, C_HL_Y = 0 ;
                specparam D_LH_Y = 0, D_HL_Y = 0 ;
                (A *> Y) = (A_LH_Y, A_HL_Y) ;
                (B *> Y) = (B_LH_Y, B_HL_Y) ;
                (C *> Y) = (C_LH_Y, C_HL_Y) ;
                (D *> Y) = (D_LH_Y, D_HL_Y) ;
        endspecify
endmodule

module ao4a15(Y, A, B, C, D);
        output Y;
        input  A, B, C, D;
        and g1(N1, A, B);
        and g2(N2, C, D);
        or g3(Y, N1, N2);
        // SPECIFY BLOCK
        specify
                specparam A_LH_Y = 0, A_HL_Y = 0 ;
                specparam B_LH_Y = 0, B_HL_Y = 0 ;
                specparam C_LH_Y = 0, C_HL_Y = 0 ;
                specparam D_LH_Y = 0, D_HL_Y = 0 ;
                (A *> Y) = (A_LH_Y, A_HL_Y) ;
                (B *> Y) = (B_LH_Y, B_HL_Y) ;
                (C *> Y) = (C_LH_Y, C_HL_Y) ;
                (D *> Y) = (D_LH_Y, D_HL_Y) ;
        endspecify
endmodule

module ao4a2(Y, A, B, C, D);
        output Y;
        input  A, B, C, D;
        and g1(N1, A, B);
        and g2(N2, C, D);
        or g3(Y, N1, N2);
        // SPECIFY BLOCK
        specify
                specparam A_LH_Y = 0, A_HL_Y = 0 ;
                specparam B_LH_Y = 0, B_HL_Y = 0 ;
                specparam C_LH_Y = 0, C_HL_Y = 0 ;
                specparam D_LH_Y = 0, D_HL_Y = 0 ;
                (A *> Y) = (A_LH_Y, A_HL_Y) ;
                (B *> Y) = (B_LH_Y, B_HL_Y) ;
                (C *> Y) = (C_LH_Y, C_HL_Y) ;
                (D *> Y) = (D_LH_Y, D_HL_Y) ;
        endspecify
endmodule

module ao4a3(Y, A, B, C, D);
        output Y;
        input  A, B, C, D;
        and g1(N1, A, B);
        and g2(N2, C, D);
        or g3(Y, N1, N2);
        // SPECIFY BLOCK
        specify
                specparam A_LH_Y = 0, A_HL_Y = 0 ;
                specparam B_LH_Y = 0, B_HL_Y = 0 ;
                specparam C_LH_Y = 0, C_HL_Y = 0 ;
                specparam D_LH_Y = 0, D_HL_Y = 0 ;
                (A *> Y) = (A_LH_Y, A_HL_Y) ;
                (B *> Y) = (B_LH_Y, B_HL_Y) ;
                (C *> Y) = (C_LH_Y, C_HL_Y) ;
                (D *> Y) = (D_LH_Y, D_HL_Y) ;
        endspecify
endmodule

module ao4a6(Y, A, B, C, D);
        output Y;
        input  A, B, C, D;
        and g1(N1, A, B);
        and g2(N2, C, D);
        or g3(Y, N1, N2);
        // SPECIFY BLOCK
        specify
                specparam A_LH_Y = 0, A_HL_Y = 0 ;
                specparam B_LH_Y = 0, B_HL_Y = 0 ;
                specparam C_LH_Y = 0, C_HL_Y = 0 ;
                specparam D_LH_Y = 0, D_HL_Y = 0 ;
                (A *> Y) = (A_LH_Y, A_HL_Y) ;
                (B *> Y) = (B_LH_Y, B_HL_Y) ;
                (C *> Y) = (C_LH_Y, C_HL_Y) ;
                (D *> Y) = (D_LH_Y, D_HL_Y) ;
        endspecify
endmodule

module ao4a9(Y, A, B, C, D);
        output Y;
        input  A, B, C, D;
        and g1(N1, A, B);
        and g2(N2, C, D);
        or g3(Y, N1, N2);
        // SPECIFY BLOCK
        specify
                specparam A_LH_Y = 0, A_HL_Y = 0 ;
                specparam B_LH_Y = 0, B_HL_Y = 0 ;
                specparam C_LH_Y = 0, C_HL_Y = 0 ;
                specparam D_LH_Y = 0, D_HL_Y = 0 ;
                (A *> Y) = (A_LH_Y, A_HL_Y) ;
                (B *> Y) = (B_LH_Y, B_HL_Y) ;
                (C *> Y) = (C_LH_Y, C_HL_Y) ;
                (D *> Y) = (D_LH_Y, D_HL_Y) ;
        endspecify
endmodule

module ao4b1(Y, A, B, C, D);
        output Y;
        input  A, B, C, D;
        not g1(N2, A);
        and g2(N1, N2, B);
        and g3(N3, C, D);
        or g4(Y, N1, N3);
        // SPECIFY BLOCK
        specify
                specparam A_LH_Y = 0, A_HL_Y = 0 ;
                specparam B_LH_Y = 0, B_HL_Y = 0 ;
                specparam C_LH_Y = 0, C_HL_Y = 0 ;
                specparam D_LH_Y = 0, D_HL_Y = 0 ;
                (A *> Y) = (A_LH_Y, A_HL_Y) ;
                (B *> Y) = (B_LH_Y, B_HL_Y) ;
                (C *> Y) = (C_LH_Y, C_HL_Y) ;
                (D *> Y) = (D_LH_Y, D_HL_Y) ;
        endspecify
endmodule

module ao4b15(Y, A, B, C, D);
        output Y;
        input  A, B, C, D;
        not g1(N2, A);
        and g2(N1, N2, B);
        and g3(N3, C, D);
        or g4(Y, N1, N3);
        // SPECIFY BLOCK
        specify
                specparam A_LH_Y = 0, A_HL_Y = 0 ;
                specparam B_LH_Y = 0, B_HL_Y = 0 ;
                specparam C_LH_Y = 0, C_HL_Y = 0 ;
                specparam D_LH_Y = 0, D_HL_Y = 0 ;
                (A *> Y) = (A_LH_Y, A_HL_Y) ;
                (B *> Y) = (B_LH_Y, B_HL_Y) ;
                (C *> Y) = (C_LH_Y, C_HL_Y) ;
                (D *> Y) = (D_LH_Y, D_HL_Y) ;
        endspecify
endmodule

module ao4b2(Y, A, B, C, D);
        output Y;
        input  A, B, C, D;
        not g1(N2, A);
        and g2(N1, N2, B);
        and g3(N3, C, D);
        or g4(Y, N1, N3);
        // SPECIFY BLOCK
        specify
                specparam A_LH_Y = 0, A_HL_Y = 0 ;
                specparam B_LH_Y = 0, B_HL_Y = 0 ;
                specparam C_LH_Y = 0, C_HL_Y = 0 ;
                specparam D_LH_Y = 0, D_HL_Y = 0 ;
                (A *> Y) = (A_LH_Y, A_HL_Y) ;
                (B *> Y) = (B_LH_Y, B_HL_Y) ;
                (C *> Y) = (C_LH_Y, C_HL_Y) ;
                (D *> Y) = (D_LH_Y, D_HL_Y) ;
        endspecify
endmodule

module ao4b3(Y, A, B, C, D);
        output Y;
        input  A, B, C, D;
        not g1(N2, A);
        and g2(N1, N2, B);
        and g3(N3, C, D);
        or g4(Y, N1, N3);
        // SPECIFY BLOCK
        specify
                specparam A_LH_Y = 0, A_HL_Y = 0 ;
                specparam B_LH_Y = 0, B_HL_Y = 0 ;
                specparam C_LH_Y = 0, C_HL_Y = 0 ;
                specparam D_LH_Y = 0, D_HL_Y = 0 ;
                (A *> Y) = (A_LH_Y, A_HL_Y) ;
                (B *> Y) = (B_LH_Y, B_HL_Y) ;
                (C *> Y) = (C_LH_Y, C_HL_Y) ;
                (D *> Y) = (D_LH_Y, D_HL_Y) ;
        endspecify
endmodule

module ao4b6(Y, A, B, C, D);
        output Y;
        input  A, B, C, D;
        not g1(N2, A);
        and g2(N1, N2, B);
        and g3(N3, C, D);
        or g4(Y, N1, N3);
        // SPECIFY BLOCK
        specify
                specparam A_LH_Y = 0, A_HL_Y = 0 ;
                specparam B_LH_Y = 0, B_HL_Y = 0 ;
                specparam C_LH_Y = 0, C_HL_Y = 0 ;
                specparam D_LH_Y = 0, D_HL_Y = 0 ;
                (A *> Y) = (A_LH_Y, A_HL_Y) ;
                (B *> Y) = (B_LH_Y, B_HL_Y) ;
                (C *> Y) = (C_LH_Y, C_HL_Y) ;
                (D *> Y) = (D_LH_Y, D_HL_Y) ;
        endspecify
endmodule

module ao4b9(Y, A, B, C, D);
        output Y;
        input  A, B, C, D;
        not g1(N2, A);
        and g2(N1, N2, B);
        and g3(N3, C, D);
        or g4(Y, N1, N3);
        // SPECIFY BLOCK
        specify
                specparam A_LH_Y = 0, A_HL_Y = 0 ;
                specparam B_LH_Y = 0, B_HL_Y = 0 ;
                specparam C_LH_Y = 0, C_HL_Y = 0 ;
                specparam D_LH_Y = 0, D_HL_Y = 0 ;
                (A *> Y) = (A_LH_Y, A_HL_Y) ;
                (B *> Y) = (B_LH_Y, B_HL_Y) ;
                (C *> Y) = (C_LH_Y, C_HL_Y) ;
                (D *> Y) = (D_LH_Y, D_HL_Y) ;
        endspecify
endmodule

module ao4c1(Y, A, B, C, D);
        output Y;
        input  A, B, C, D;
        not g1(N2, A);
        not g2(N3, B);
        and g3(N1, N2, N3);
        and g4(N4, C, D);
        or g5(Y, N1, N4);
        // SPECIFY BLOCK
        specify
                specparam A_LH_Y = 0, A_HL_Y = 0 ;
                specparam B_LH_Y = 0, B_HL_Y = 0 ;
                specparam C_LH_Y = 0, C_HL_Y = 0 ;
                specparam D_LH_Y = 0, D_HL_Y = 0 ;
                (A *> Y) = (A_LH_Y, A_HL_Y) ;
                (B *> Y) = (B_LH_Y, B_HL_Y) ;
                (C *> Y) = (C_LH_Y, C_HL_Y) ;
                (D *> Y) = (D_LH_Y, D_HL_Y) ;
        endspecify
endmodule

module ao4c15(Y, A, B, C, D);
        output Y;
        input  A, B, C, D;
        not g1(N2, A);
        not g2(N3, B);
        and g3(N1, N2, N3);
        and g4(N4, C, D);
        or g5(Y, N1, N4);
        // SPECIFY BLOCK
        specify
                specparam A_LH_Y = 0, A_HL_Y = 0 ;
                specparam B_LH_Y = 0, B_HL_Y = 0 ;
                specparam C_LH_Y = 0, C_HL_Y = 0 ;
                specparam D_LH_Y = 0, D_HL_Y = 0 ;
                (A *> Y) = (A_LH_Y, A_HL_Y) ;
                (B *> Y) = (B_LH_Y, B_HL_Y) ;
                (C *> Y) = (C_LH_Y, C_HL_Y) ;
                (D *> Y) = (D_LH_Y, D_HL_Y) ;
        endspecify
endmodule

module ao4c2(Y, A, B, C, D);
        output Y;
        input  A, B, C, D;
        not g1(N2, A);
        not g2(N3, B);
        and g3(N1, N2, N3);
        and g4(N4, C, D);
        or g5(Y, N1, N4);
        // SPECIFY BLOCK
        specify
                specparam A_LH_Y = 0, A_HL_Y = 0 ;
                specparam B_LH_Y = 0, B_HL_Y = 0 ;
                specparam C_LH_Y = 0, C_HL_Y = 0 ;
                specparam D_LH_Y = 0, D_HL_Y = 0 ;
                (A *> Y) = (A_LH_Y, A_HL_Y) ;
                (B *> Y) = (B_LH_Y, B_HL_Y) ;
                (C *> Y) = (C_LH_Y, C_HL_Y) ;
                (D *> Y) = (D_LH_Y, D_HL_Y) ;
        endspecify
endmodule

module ao4c3(Y, A, B, C, D);
        output Y;
        input  A, B, C, D;
        not g1(N2, A);
        not g2(N3, B);
        and g3(N1, N2, N3);
        and g4(N4, C, D);
        or g5(Y, N1, N4);
        // SPECIFY BLOCK
        specify
                specparam A_LH_Y = 0, A_HL_Y = 0 ;
                specparam B_LH_Y = 0, B_HL_Y = 0 ;
                specparam C_LH_Y = 0, C_HL_Y = 0 ;
                specparam D_LH_Y = 0, D_HL_Y = 0 ;
                (A *> Y) = (A_LH_Y, A_HL_Y) ;
                (B *> Y) = (B_LH_Y, B_HL_Y) ;
                (C *> Y) = (C_LH_Y, C_HL_Y) ;
                (D *> Y) = (D_LH_Y, D_HL_Y) ;
        endspecify
endmodule

module ao4c6(Y, A, B, C, D);
        output Y;
        input  A, B, C, D;
        not g1(N2, A);
        not g2(N3, B);
        and g3(N1, N2, N3);
        and g4(N4, C, D);
        or g5(Y, N1, N4);
        // SPECIFY BLOCK
        specify
                specparam A_LH_Y = 0, A_HL_Y = 0 ;
                specparam B_LH_Y = 0, B_HL_Y = 0 ;
                specparam C_LH_Y = 0, C_HL_Y = 0 ;
                specparam D_LH_Y = 0, D_HL_Y = 0 ;
                (A *> Y) = (A_LH_Y, A_HL_Y) ;
                (B *> Y) = (B_LH_Y, B_HL_Y) ;
                (C *> Y) = (C_LH_Y, C_HL_Y) ;
                (D *> Y) = (D_LH_Y, D_HL_Y) ;
        endspecify
endmodule

module ao4c9(Y, A, B, C, D);
        output Y;
        input  A, B, C, D;
        not g1(N2, A);
        not g2(N3, B);
        and g3(N1, N2, N3);
        and g4(N4, C, D);
        or g5(Y, N1, N4);
        // SPECIFY BLOCK
        specify
                specparam A_LH_Y = 0, A_HL_Y = 0 ;
                specparam B_LH_Y = 0, B_HL_Y = 0 ;
                specparam C_LH_Y = 0, C_HL_Y = 0 ;
                specparam D_LH_Y = 0, D_HL_Y = 0 ;
                (A *> Y) = (A_LH_Y, A_HL_Y) ;
                (B *> Y) = (B_LH_Y, B_HL_Y) ;
                (C *> Y) = (C_LH_Y, C_HL_Y) ;
                (D *> Y) = (D_LH_Y, D_HL_Y) ;
        endspecify
endmodule

module ao4d1(Y, A, B, C, D);
        output Y;
        input  A, B, C, D;
        not g1(N2, A);
        and g2(N1, N2, B);
        not g3(N4, C);
        and g4(N3, N4, D);
        or g5(Y, N1, N3);
        // SPECIFY BLOCK
        specify
                specparam A_LH_Y = 0, A_HL_Y = 0 ;
                specparam B_LH_Y = 0, B_HL_Y = 0 ;
                specparam C_LH_Y = 0, C_HL_Y = 0 ;
                specparam D_LH_Y = 0, D_HL_Y = 0 ;
                (A *> Y) = (A_LH_Y, A_HL_Y) ;
                (B *> Y) = (B_LH_Y, B_HL_Y) ;
                (C *> Y) = (C_LH_Y, C_HL_Y) ;
                (D *> Y) = (D_LH_Y, D_HL_Y) ;
        endspecify
endmodule

module ao4d15(Y, A, B, C, D);
        output Y;
        input  A, B, C, D;
        not g1(N2, A);
        and g2(N1, N2, B);
        not g3(N4, C);
        and g4(N3, N4, D);
        or g5(Y, N1, N3);
        // SPECIFY BLOCK
        specify
                specparam A_LH_Y = 0, A_HL_Y = 0 ;
                specparam B_LH_Y = 0, B_HL_Y = 0 ;
                specparam C_LH_Y = 0, C_HL_Y = 0 ;
                specparam D_LH_Y = 0, D_HL_Y = 0 ;
                (A *> Y) = (A_LH_Y, A_HL_Y) ;
                (B *> Y) = (B_LH_Y, B_HL_Y) ;
                (C *> Y) = (C_LH_Y, C_HL_Y) ;
                (D *> Y) = (D_LH_Y, D_HL_Y) ;
        endspecify
endmodule

module ao4d2(Y, A, B, C, D);
        output Y;
        input  A, B, C, D;
        not g1(N2, A);
        and g2(N1, N2, B);
        not g3(N4, C);
        and g4(N3, N4, D);
        or g5(Y, N1, N3);
        // SPECIFY BLOCK
        specify
                specparam A_LH_Y = 0, A_HL_Y = 0 ;
                specparam B_LH_Y = 0, B_HL_Y = 0 ;
                specparam C_LH_Y = 0, C_HL_Y = 0 ;
                specparam D_LH_Y = 0, D_HL_Y = 0 ;
                (A *> Y) = (A_LH_Y, A_HL_Y) ;
                (B *> Y) = (B_LH_Y, B_HL_Y) ;
                (C *> Y) = (C_LH_Y, C_HL_Y) ;
                (D *> Y) = (D_LH_Y, D_HL_Y) ;
        endspecify
endmodule

module ao4d3(Y, A, B, C, D);
        output Y;
        input  A, B, C, D;
        not g1(N2, A);
        and g2(N1, N2, B);
        not g3(N4, C);
        and g4(N3, N4, D);
        or g5(Y, N1, N3);
        // SPECIFY BLOCK
        specify
                specparam A_LH_Y = 0, A_HL_Y = 0 ;
                specparam B_LH_Y = 0, B_HL_Y = 0 ;
                specparam C_LH_Y = 0, C_HL_Y = 0 ;
                specparam D_LH_Y = 0, D_HL_Y = 0 ;
                (A *> Y) = (A_LH_Y, A_HL_Y) ;
                (B *> Y) = (B_LH_Y, B_HL_Y) ;
                (C *> Y) = (C_LH_Y, C_HL_Y) ;
                (D *> Y) = (D_LH_Y, D_HL_Y) ;
        endspecify
endmodule

module ao4d6(Y, A, B, C, D);
        output Y;
        input  A, B, C, D;
        not g1(N2, A);
        and g2(N1, N2, B);
        not g3(N4, C);
        and g4(N3, N4, D);
        or g5(Y, N1, N3);
        // SPECIFY BLOCK
        specify
                specparam A_LH_Y = 0, A_HL_Y = 0 ;
                specparam B_LH_Y = 0, B_HL_Y = 0 ;
                specparam C_LH_Y = 0, C_HL_Y = 0 ;
                specparam D_LH_Y = 0, D_HL_Y = 0 ;
                (A *> Y) = (A_LH_Y, A_HL_Y) ;
                (B *> Y) = (B_LH_Y, B_HL_Y) ;
                (C *> Y) = (C_LH_Y, C_HL_Y) ;
                (D *> Y) = (D_LH_Y, D_HL_Y) ;
        endspecify
endmodule

module ao4d9(Y, A, B, C, D);
        output Y;
        input  A, B, C, D;
        not g1(N2, A);
        and g2(N1, N2, B);
        not g3(N4, C);
        and g4(N3, N4, D);
        or g5(Y, N1, N3);
        // SPECIFY BLOCK
        specify
                specparam A_LH_Y = 0, A_HL_Y = 0 ;
                specparam B_LH_Y = 0, B_HL_Y = 0 ;
                specparam C_LH_Y = 0, C_HL_Y = 0 ;
                specparam D_LH_Y = 0, D_HL_Y = 0 ;
                (A *> Y) = (A_LH_Y, A_HL_Y) ;
                (B *> Y) = (B_LH_Y, B_HL_Y) ;
                (C *> Y) = (C_LH_Y, C_HL_Y) ;
                (D *> Y) = (D_LH_Y, D_HL_Y) ;
        endspecify
endmodule

module ao4e1(Y, A, B, C, D);
        output Y;
        input  A, B, C, D;
        not g1(N2, A);
        and g2(N1, N2, B);
        not g3(N4, C);
        not g4(N5, D);
        and g5(N3, N4, N5);
        or g6(Y, N1, N3);
        // SPECIFY BLOCK
        specify
                specparam A_LH_Y = 0, A_HL_Y = 0 ;
                specparam B_LH_Y = 0, B_HL_Y = 0 ;
                specparam C_LH_Y = 0, C_HL_Y = 0 ;
                specparam D_LH_Y = 0, D_HL_Y = 0 ;
                (A *> Y) = (A_LH_Y, A_HL_Y) ;
                (B *> Y) = (B_LH_Y, B_HL_Y) ;
                (C *> Y) = (C_LH_Y, C_HL_Y) ;
                (D *> Y) = (D_LH_Y, D_HL_Y) ;
        endspecify
endmodule

module ao4e15(Y, A, B, C, D);
        output Y;
        input  A, B, C, D;
        not g1(N2, A);
        and g2(N1, N2, B);
        not g3(N4, C);
        not g4(N5, D);
        and g5(N3, N4, N5);
        or g6(Y, N1, N3);
        // SPECIFY BLOCK
        specify
                specparam A_LH_Y = 0, A_HL_Y = 0 ;
                specparam B_LH_Y = 0, B_HL_Y = 0 ;
                specparam C_LH_Y = 0, C_HL_Y = 0 ;
                specparam D_LH_Y = 0, D_HL_Y = 0 ;
                (A *> Y) = (A_LH_Y, A_HL_Y) ;
                (B *> Y) = (B_LH_Y, B_HL_Y) ;
                (C *> Y) = (C_LH_Y, C_HL_Y) ;
                (D *> Y) = (D_LH_Y, D_HL_Y) ;
        endspecify
endmodule

module ao4e2(Y, A, B, C, D);
        output Y;
        input  A, B, C, D;
        not g1(N2, A);
        and g2(N1, N2, B);
        not g3(N4, C);
        not g4(N5, D);
        and g5(N3, N4, N5);
        or g6(Y, N1, N3);
        // SPECIFY BLOCK
        specify
                specparam A_LH_Y = 0, A_HL_Y = 0 ;
                specparam B_LH_Y = 0, B_HL_Y = 0 ;
                specparam C_LH_Y = 0, C_HL_Y = 0 ;
                specparam D_LH_Y = 0, D_HL_Y = 0 ;
                (A *> Y) = (A_LH_Y, A_HL_Y) ;
                (B *> Y) = (B_LH_Y, B_HL_Y) ;
                (C *> Y) = (C_LH_Y, C_HL_Y) ;
                (D *> Y) = (D_LH_Y, D_HL_Y) ;
        endspecify
endmodule

module ao4e3(Y, A, B, C, D);
        output Y;
        input  A, B, C, D;
        not g1(N2, A);
        and g2(N1, N2, B);
        not g3(N4, C);
        not g4(N5, D);
        and g5(N3, N4, N5);
        or g6(Y, N1, N3);
        // SPECIFY BLOCK
        specify
                specparam A_LH_Y = 0, A_HL_Y = 0 ;
                specparam B_LH_Y = 0, B_HL_Y = 0 ;
                specparam C_LH_Y = 0, C_HL_Y = 0 ;
                specparam D_LH_Y = 0, D_HL_Y = 0 ;
                (A *> Y) = (A_LH_Y, A_HL_Y) ;
                (B *> Y) = (B_LH_Y, B_HL_Y) ;
                (C *> Y) = (C_LH_Y, C_HL_Y) ;
                (D *> Y) = (D_LH_Y, D_HL_Y) ;
        endspecify
endmodule

module ao4e6(Y, A, B, C, D);
        output Y;
        input  A, B, C, D;
        not g1(N2, A);
        and g2(N1, N2, B);
        not g3(N4, C);
        not g4(N5, D);
        and g5(N3, N4, N5);
        or g6(Y, N1, N3);
        // SPECIFY BLOCK
        specify
                specparam A_LH_Y = 0, A_HL_Y = 0 ;
                specparam B_LH_Y = 0, B_HL_Y = 0 ;
                specparam C_LH_Y = 0, C_HL_Y = 0 ;
                specparam D_LH_Y = 0, D_HL_Y = 0 ;
                (A *> Y) = (A_LH_Y, A_HL_Y) ;
                (B *> Y) = (B_LH_Y, B_HL_Y) ;
                (C *> Y) = (C_LH_Y, C_HL_Y) ;
                (D *> Y) = (D_LH_Y, D_HL_Y) ;
        endspecify
endmodule

module ao4e9(Y, A, B, C, D);
        output Y;
        input  A, B, C, D;
        not g1(N2, A);
        and g2(N1, N2, B);
        not g3(N4, C);
        not g4(N5, D);
        and g5(N3, N4, N5);
        or g6(Y, N1, N3);
        // SPECIFY BLOCK
        specify
                specparam A_LH_Y = 0, A_HL_Y = 0 ;
                specparam B_LH_Y = 0, B_HL_Y = 0 ;
                specparam C_LH_Y = 0, C_HL_Y = 0 ;
                specparam D_LH_Y = 0, D_HL_Y = 0 ;
                (A *> Y) = (A_LH_Y, A_HL_Y) ;
                (B *> Y) = (B_LH_Y, B_HL_Y) ;
                (C *> Y) = (C_LH_Y, C_HL_Y) ;
                (D *> Y) = (D_LH_Y, D_HL_Y) ;
        endspecify
endmodule

module ao4f1(Y, A, B, C, D);
        output Y;
        input  A, B, C, D;
        not g1(N2, A);
        not g2(N3, B);
        and g3(N1, N2, N3);
        not g4(N5, C);
        not g5(N6, D);
        and g6(N4, N5, N6);
        or g7(Y, N1, N4);
        // SPECIFY BLOCK
        specify
                specparam A_LH_Y = 0, A_HL_Y = 0 ;
                specparam B_LH_Y = 0, B_HL_Y = 0 ;
                specparam C_LH_Y = 0, C_HL_Y = 0 ;
                specparam D_LH_Y = 0, D_HL_Y = 0 ;
                (A *> Y) = (A_LH_Y, A_HL_Y) ;
                (B *> Y) = (B_LH_Y, B_HL_Y) ;
                (C *> Y) = (C_LH_Y, C_HL_Y) ;
                (D *> Y) = (D_LH_Y, D_HL_Y) ;
        endspecify
endmodule

module ao4f15(Y, A, B, C, D);
        output Y;
        input  A, B, C, D;
        not g1(N2, A);
        not g2(N3, B);
        and g3(N1, N2, N3);
        not g4(N5, C);
        not g5(N6, D);
        and g6(N4, N5, N6);
        or g7(Y, N1, N4);
        // SPECIFY BLOCK
        specify
                specparam A_LH_Y = 0, A_HL_Y = 0 ;
                specparam B_LH_Y = 0, B_HL_Y = 0 ;
                specparam C_LH_Y = 0, C_HL_Y = 0 ;
                specparam D_LH_Y = 0, D_HL_Y = 0 ;
                (A *> Y) = (A_LH_Y, A_HL_Y) ;
                (B *> Y) = (B_LH_Y, B_HL_Y) ;
                (C *> Y) = (C_LH_Y, C_HL_Y) ;
                (D *> Y) = (D_LH_Y, D_HL_Y) ;
        endspecify
endmodule

module ao4f2(Y, A, B, C, D);
        output Y;
        input  A, B, C, D;
        not g1(N2, A);
        not g2(N3, B);
        and g3(N1, N2, N3);
        not g4(N5, C);
        not g5(N6, D);
        and g6(N4, N5, N6);
        or g7(Y, N1, N4);
        // SPECIFY BLOCK
        specify
                specparam A_LH_Y = 0, A_HL_Y = 0 ;
                specparam B_LH_Y = 0, B_HL_Y = 0 ;
                specparam C_LH_Y = 0, C_HL_Y = 0 ;
                specparam D_LH_Y = 0, D_HL_Y = 0 ;
                (A *> Y) = (A_LH_Y, A_HL_Y) ;
                (B *> Y) = (B_LH_Y, B_HL_Y) ;
                (C *> Y) = (C_LH_Y, C_HL_Y) ;
                (D *> Y) = (D_LH_Y, D_HL_Y) ;
        endspecify
endmodule

module ao4f3(Y, A, B, C, D);
        output Y;
        input  A, B, C, D;
        not g1(N2, A);
        not g2(N3, B);
        and g3(N1, N2, N3);
        not g4(N5, C);
        not g5(N6, D);
        and g6(N4, N5, N6);
        or g7(Y, N1, N4);
        // SPECIFY BLOCK
        specify
                specparam A_LH_Y = 0, A_HL_Y = 0 ;
                specparam B_LH_Y = 0, B_HL_Y = 0 ;
                specparam C_LH_Y = 0, C_HL_Y = 0 ;
                specparam D_LH_Y = 0, D_HL_Y = 0 ;
                (A *> Y) = (A_LH_Y, A_HL_Y) ;
                (B *> Y) = (B_LH_Y, B_HL_Y) ;
                (C *> Y) = (C_LH_Y, C_HL_Y) ;
                (D *> Y) = (D_LH_Y, D_HL_Y) ;
        endspecify
endmodule

module ao4f6(Y, A, B, C, D);
        output Y;
        input  A, B, C, D;
        not g1(N2, A);
        not g2(N3, B);
        and g3(N1, N2, N3);
        not g4(N5, C);
        not g5(N6, D);
        and g6(N4, N5, N6);
        or g7(Y, N1, N4);
        // SPECIFY BLOCK
        specify
                specparam A_LH_Y = 0, A_HL_Y = 0 ;
                specparam B_LH_Y = 0, B_HL_Y = 0 ;
                specparam C_LH_Y = 0, C_HL_Y = 0 ;
                specparam D_LH_Y = 0, D_HL_Y = 0 ;
                (A *> Y) = (A_LH_Y, A_HL_Y) ;
                (B *> Y) = (B_LH_Y, B_HL_Y) ;
                (C *> Y) = (C_LH_Y, C_HL_Y) ;
                (D *> Y) = (D_LH_Y, D_HL_Y) ;
        endspecify
endmodule

module ao4f9(Y, A, B, C, D);
        output Y;
        input  A, B, C, D;
        not g1(N2, A);
        not g2(N3, B);
        and g3(N1, N2, N3);
        not g4(N5, C);
        not g5(N6, D);
        and g6(N4, N5, N6);
        or g7(Y, N1, N4);
        // SPECIFY BLOCK
        specify
                specparam A_LH_Y = 0, A_HL_Y = 0 ;
                specparam B_LH_Y = 0, B_HL_Y = 0 ;
                specparam C_LH_Y = 0, C_HL_Y = 0 ;
                specparam D_LH_Y = 0, D_HL_Y = 0 ;
                (A *> Y) = (A_LH_Y, A_HL_Y) ;
                (B *> Y) = (B_LH_Y, B_HL_Y) ;
                (C *> Y) = (C_LH_Y, C_HL_Y) ;
                (D *> Y) = (D_LH_Y, D_HL_Y) ;
        endspecify
endmodule

module buf1a1(Y, A);
        output Y;
        input  A;
        buf g1(Y, A);
        // SPECIFY BLOCK
        specify
                specparam A_LH_Y = 0, A_HL_Y = 0 ;
                (A *> Y) = (A_LH_Y, A_HL_Y) ;
        endspecify
endmodule

module buf1a15(Y, A);
        output Y;
        input  A;
        buf g1(Y, A);
        // SPECIFY BLOCK
        specify
                specparam A_LH_Y = 0, A_HL_Y = 0 ;
                (A *> Y) = (A_LH_Y, A_HL_Y) ;
        endspecify
endmodule

module buf1a2(Y, A);
        output Y;
        input  A;
        buf g1(Y, A);
        // SPECIFY BLOCK
        specify
                specparam A_LH_Y = 0, A_HL_Y = 0 ;
                (A *> Y) = (A_LH_Y, A_HL_Y) ;
        endspecify
endmodule

module buf1a27(Y, A);
        output Y;
        input  A;
        buf g1(Y, A);
        // SPECIFY BLOCK
        specify
                specparam A_LH_Y = 0, A_HL_Y = 0 ;
                (A *> Y) = (A_LH_Y, A_HL_Y) ;
        endspecify
endmodule

module buf1a3(Y, A);
        output Y;
        input  A;
        buf g1(Y, A);
        // SPECIFY BLOCK
        specify
                specparam A_LH_Y = 0, A_HL_Y = 0 ;
                (A *> Y) = (A_LH_Y, A_HL_Y) ;
        endspecify
endmodule

module buf1a6(Y, A);
        output Y;
        input  A;
        buf g1(Y, A);
        // SPECIFY BLOCK
        specify
                specparam A_LH_Y = 0, A_HL_Y = 0 ;
                (A *> Y) = (A_LH_Y, A_HL_Y) ;
        endspecify
endmodule

module buf1a9(Y, A);
        output Y;
        input  A;
        buf g1(Y, A);
        // SPECIFY BLOCK
        specify
                specparam A_LH_Y = 0, A_HL_Y = 0 ;
                (A *> Y) = (A_LH_Y, A_HL_Y) ;
        endspecify
endmodule

module clk1a15(Y, A);
        output Y;
        input  A;
        buf g1(Y, A);
        // SPECIFY BLOCK
        specify
                specparam A_LH_Y = 0, A_HL_Y = 0 ;
                (A *> Y) = (A_LH_Y, A_HL_Y) ;
        endspecify
endmodule

module clk1a2(Y, A);
        output Y;
        input  A;
        buf g1(Y, A);
        // SPECIFY BLOCK
        specify
                specparam A_LH_Y = 0, A_HL_Y = 0 ;
                (A *> Y) = (A_LH_Y, A_HL_Y) ;
        endspecify
endmodule

module clk1a27(Y, A);
        output Y;
        input  A;
        buf g1(Y, A);
        // SPECIFY BLOCK
        specify
                specparam A_LH_Y = 0, A_HL_Y = 0 ;
                (A *> Y) = (A_LH_Y, A_HL_Y) ;
        endspecify
endmodule

module clk1a3(Y, A);
        output Y;
        input  A;
        buf g1(Y, A);
        // SPECIFY BLOCK
        specify
                specparam A_LH_Y = 0, A_HL_Y = 0 ;
                (A *> Y) = (A_LH_Y, A_HL_Y) ;
        endspecify
endmodule

module clk1a54(Y, A);
        output Y;
        input  A;
        buf g1(Y, A);
        // SPECIFY BLOCK
        specify
                specparam A_LH_Y = 0, A_HL_Y = 0 ;
                (A *> Y) = (A_LH_Y, A_HL_Y) ;
        endspecify
endmodule

module clk1a6(Y, A);
        output Y;
        input  A;
        buf g1(Y, A);
        // SPECIFY BLOCK
        specify
                specparam A_LH_Y = 0, A_HL_Y = 0 ;
                (A *> Y) = (A_LH_Y, A_HL_Y) ;
        endspecify
endmodule

module clk1a9(Y, A);
        output Y;
        input  A;
        buf g1(Y, A);
        // SPECIFY BLOCK
        specify
                specparam A_LH_Y = 0, A_HL_Y = 0 ;
                (A *> Y) = (A_LH_Y, A_HL_Y) ;
        endspecify
endmodule

module clk1b15(Y, A);
        output Y;
        input  A;
        not g1(Y, A);
        // SPECIFY BLOCK
        specify
                specparam A_LH_Y = 0, A_HL_Y = 0 ;
                (A *> Y) = (A_LH_Y, A_HL_Y) ;
        endspecify
endmodule

module clk1b2(Y, A);
        output Y;
        input  A;
        not g1(Y, A);
        // SPECIFY BLOCK
        specify
                specparam A_LH_Y = 0, A_HL_Y = 0 ;
                (A *> Y) = (A_LH_Y, A_HL_Y) ;
        endspecify
endmodule

module clk1b27(Y, A);
        output Y;
        input  A;
        not g1(Y, A);
        // SPECIFY BLOCK
        specify
                specparam A_LH_Y = 0, A_HL_Y = 0 ;
                (A *> Y) = (A_LH_Y, A_HL_Y) ;
        endspecify
endmodule

module clk1b3(Y, A);
        output Y;
        input  A;
        not g1(Y, A);
        // SPECIFY BLOCK
        specify
                specparam A_LH_Y = 0, A_HL_Y = 0 ;
                (A *> Y) = (A_LH_Y, A_HL_Y) ;
        endspecify
endmodule

module clk1b54(Y, A);
        output Y;
        input  A;
        not g1(Y, A);
        // SPECIFY BLOCK
        specify
                specparam A_LH_Y = 0, A_HL_Y = 0 ;
                (A *> Y) = (A_LH_Y, A_HL_Y) ;
        endspecify
endmodule

module clk1b6(Y, A);
        output Y;
        input  A;
        not g1(Y, A);
        // SPECIFY BLOCK
        specify
                specparam A_LH_Y = 0, A_HL_Y = 0 ;
                (A *> Y) = (A_LH_Y, A_HL_Y) ;
        endspecify
endmodule

module clk1b9(Y, A);
        output Y;
        input  A;
        not g1(Y, A);
        // SPECIFY BLOCK
        specify
                specparam A_LH_Y = 0, A_HL_Y = 0 ;
                (A *> Y) = (A_LH_Y, A_HL_Y) ;
        endspecify
endmodule

module fa1a1(S, CO, A, B, CI);
        output S, CO;
        input  A, B, CI;
        xor g1(S, B, CI, A);
        and g2(N2, A, CI);
        and g3(N3, B, CI);
        and g4(N4, A, B);
        or g5(CO, N2, N3, N4);
        // SPECIFY BLOCK
        specify
                specparam A_01_LH_S = 0, A_01_HL_S = 0 ;
                specparam A_10_LH_S = 0, A_10_HL_S = 0 ;
                specparam B_01_LH_S = 0, B_01_HL_S = 0 ;
                specparam B_10_LH_S = 0, B_10_HL_S = 0 ;
                specparam CI_01_LH_S = 0, CI_01_HL_S = 0 ;
                specparam CI_10_LH_S = 0, CI_10_HL_S = 0 ;
                specparam A_LH_CO = 0, A_HL_CO = 0 ;
                specparam B_LH_CO = 0, B_HL_CO = 0 ;
                specparam CI_LH_CO = 0, CI_HL_CO = 0 ;
                (posedge A *> (S : 1'b1)) = (A_01_LH_S, A_01_HL_S) ;
                (negedge A *> (S : 1'b1)) = (A_10_LH_S, A_10_HL_S) ;
                (posedge B *> (S : 1'b1)) = (B_01_LH_S, B_01_HL_S) ;
                (negedge B *> (S : 1'b1)) = (B_10_LH_S, B_10_HL_S) ;
                (posedge CI *> (S : 1'b1)) = (CI_01_LH_S, CI_01_HL_S) ;
                (negedge CI *> (S : 1'b1)) = (CI_10_LH_S, CI_10_HL_S) ;
                (A *> CO) = (A_LH_CO, A_HL_CO) ;
                (B *> CO) = (B_LH_CO, B_HL_CO) ;
                (CI *> CO) = (CI_LH_CO, CI_HL_CO) ;
        endspecify
endmodule

module fa1a2(S, CO, A, B, CI);
        output S, CO;
        input  A, B, CI;
        xor g1(S, B, CI, A);
        and g2(N2, A, CI);
        and g3(N3, B, CI);
        and g4(N4, A, B);
        or g5(CO, N2, N3, N4);
        // SPECIFY BLOCK
        specify
                specparam A_01_LH_S = 0, A_01_HL_S = 0 ;
                specparam A_10_LH_S = 0, A_10_HL_S = 0 ;
                specparam B_01_LH_S = 0, B_01_HL_S = 0 ;
                specparam B_10_LH_S = 0, B_10_HL_S = 0 ;
                specparam CI_01_LH_S = 0, CI_01_HL_S = 0 ;
                specparam CI_10_LH_S = 0, CI_10_HL_S = 0 ;
                specparam A_LH_CO = 0, A_HL_CO = 0 ;
                specparam B_LH_CO = 0, B_HL_CO = 0 ;
                specparam CI_LH_CO = 0, CI_HL_CO = 0 ;
                (posedge A *> (S : 1'b1)) = (A_01_LH_S, A_01_HL_S) ;
                (negedge A *> (S : 1'b1)) = (A_10_LH_S, A_10_HL_S) ;
                (posedge B *> (S : 1'b1)) = (B_01_LH_S, B_01_HL_S) ;
                (negedge B *> (S : 1'b1)) = (B_10_LH_S, B_10_HL_S) ;
                (posedge CI *> (S : 1'b1)) = (CI_01_LH_S, CI_01_HL_S) ;
                (negedge CI *> (S : 1'b1)) = (CI_10_LH_S, CI_10_HL_S) ;
                (A *> CO) = (A_LH_CO, A_HL_CO) ;
                (B *> CO) = (B_LH_CO, B_HL_CO) ;
                (CI *> CO) = (CI_LH_CO, CI_HL_CO) ;
        endspecify
endmodule

module fa1a3(S, CO, A, B, CI);
        output S, CO;
        input  A, B, CI;
        xor g1(S, B, CI, A);
        and g2(N2, A, CI);
        and g3(N3, B, CI);
        and g4(N4, A, B);
        or g5(CO, N2, N3, N4);
        // SPECIFY BLOCK
        specify
                specparam A_01_LH_S = 0, A_01_HL_S = 0 ;
                specparam A_10_LH_S = 0, A_10_HL_S = 0 ;
                specparam B_01_LH_S = 0, B_01_HL_S = 0 ;
                specparam B_10_LH_S = 0, B_10_HL_S = 0 ;
                specparam CI_01_LH_S = 0, CI_01_HL_S = 0 ;
                specparam CI_10_LH_S = 0, CI_10_HL_S = 0 ;
                specparam A_LH_CO = 0, A_HL_CO = 0 ;
                specparam B_LH_CO = 0, B_HL_CO = 0 ;
                specparam CI_LH_CO = 0, CI_HL_CO = 0 ;
                (posedge A *> (S : 1'b1)) = (A_01_LH_S, A_01_HL_S) ;
                (negedge A *> (S : 1'b1)) = (A_10_LH_S, A_10_HL_S) ;
                (posedge B *> (S : 1'b1)) = (B_01_LH_S, B_01_HL_S) ;
                (negedge B *> (S : 1'b1)) = (B_10_LH_S, B_10_HL_S) ;
                (posedge CI *> (S : 1'b1)) = (CI_01_LH_S, CI_01_HL_S) ;
                (negedge CI *> (S : 1'b1)) = (CI_10_LH_S, CI_10_HL_S) ;
                (A *> CO) = (A_LH_CO, A_HL_CO) ;
                (B *> CO) = (B_LH_CO, B_HL_CO) ;
                (CI *> CO) = (CI_LH_CO, CI_HL_CO) ;
        endspecify
endmodule

module fa1b1(S, CO, A, B, CI);
        output S, CO;
        input  A, B, CI;
        not g1(N1, CI);
        xor g2(S, B, N1, A);
        not g3(N4, CI);
        and g4(N3, A, N4);
        not g5(N6, CI);
        and g6(N5, B, N6);
        and g7(N7, A, B);
        or g8(CO, N3, N5, N7);
        // SPECIFY BLOCK
        specify
                specparam A_01_LH_S = 0, A_01_HL_S = 0 ;
                specparam A_10_LH_S = 0, A_10_HL_S = 0 ;
                specparam B_01_LH_S = 0, B_01_HL_S = 0 ;
                specparam B_10_LH_S = 0, B_10_HL_S = 0 ;
                specparam CI_01_LH_S = 0, CI_01_HL_S = 0 ;
                specparam CI_10_LH_S = 0, CI_10_HL_S = 0 ;
                specparam A_LH_CO = 0, A_HL_CO = 0 ;
                specparam B_LH_CO = 0, B_HL_CO = 0 ;
                specparam CI_LH_CO = 0, CI_HL_CO = 0 ;
                (posedge A *> (S : 1'b1)) = (A_01_LH_S, A_01_HL_S) ;
                (negedge A *> (S : 1'b1)) = (A_10_LH_S, A_10_HL_S) ;
                (posedge B *> (S : 1'b1)) = (B_01_LH_S, B_01_HL_S) ;
                (negedge B *> (S : 1'b1)) = (B_10_LH_S, B_10_HL_S) ;
                (posedge CI *> (S : 1'b1)) = (CI_01_LH_S, CI_01_HL_S) ;
                (negedge CI *> (S : 1'b1)) = (CI_10_LH_S, CI_10_HL_S) ;
                (A *> CO) = (A_LH_CO, A_HL_CO) ;
                (B *> CO) = (B_LH_CO, B_HL_CO) ;
                (CI *> CO) = (CI_LH_CO, CI_HL_CO) ;
        endspecify
endmodule

module fa1b2(S, CO, A, B, CI);
        output S, CO;
        input  A, B, CI;
        not g1(N1, CI);
        xor g2(S, B, N1, A);
        not g3(N4, CI);
        and g4(N3, A, N4);
        not g5(N6, CI);
        and g6(N5, B, N6);
        and g7(N7, A, B);
        or g8(CO, N3, N5, N7);
        // SPECIFY BLOCK
        specify
                specparam A_01_LH_S = 0, A_01_HL_S = 0 ;
                specparam A_10_LH_S = 0, A_10_HL_S = 0 ;
                specparam B_01_LH_S = 0, B_01_HL_S = 0 ;
                specparam B_10_LH_S = 0, B_10_HL_S = 0 ;
                specparam CI_01_LH_S = 0, CI_01_HL_S = 0 ;
                specparam CI_10_LH_S = 0, CI_10_HL_S = 0 ;
                specparam A_LH_CO = 0, A_HL_CO = 0 ;
                specparam B_LH_CO = 0, B_HL_CO = 0 ;
                specparam CI_LH_CO = 0, CI_HL_CO = 0 ;
                (posedge A *> (S : 1'b1)) = (A_01_LH_S, A_01_HL_S) ;
                (negedge A *> (S : 1'b1)) = (A_10_LH_S, A_10_HL_S) ;
                (posedge B *> (S : 1'b1)) = (B_01_LH_S, B_01_HL_S) ;
                (negedge B *> (S : 1'b1)) = (B_10_LH_S, B_10_HL_S) ;
                (posedge CI *> (S : 1'b1)) = (CI_01_LH_S, CI_01_HL_S) ;
                (negedge CI *> (S : 1'b1)) = (CI_10_LH_S, CI_10_HL_S) ;
                (A *> CO) = (A_LH_CO, A_HL_CO) ;
                (B *> CO) = (B_LH_CO, B_HL_CO) ;
                (CI *> CO) = (CI_LH_CO, CI_HL_CO) ;
        endspecify
endmodule

module fa1b3(S, CO, A, B, CI);
        output S, CO;
        input  A, B, CI;
        not g1(N1, CI);
        xor g2(S, B, N1, A);
        not g3(N4, CI);
        and g4(N3, A, N4);
        not g5(N6, CI);
        and g6(N5, B, N6);
        and g7(N7, A, B);
        or g8(CO, N3, N5, N7);
        // SPECIFY BLOCK
        specify
                specparam A_01_LH_S = 0, A_01_HL_S = 0 ;
                specparam A_10_LH_S = 0, A_10_HL_S = 0 ;
                specparam B_01_LH_S = 0, B_01_HL_S = 0 ;
                specparam B_10_LH_S = 0, B_10_HL_S = 0 ;
                specparam CI_01_LH_S = 0, CI_01_HL_S = 0 ;
                specparam CI_10_LH_S = 0, CI_10_HL_S = 0 ;
                specparam A_LH_CO = 0, A_HL_CO = 0 ;
                specparam B_LH_CO = 0, B_HL_CO = 0 ;
                specparam CI_LH_CO = 0, CI_HL_CO = 0 ;
                (posedge A *> (S : 1'b1)) = (A_01_LH_S, A_01_HL_S) ;
                (negedge A *> (S : 1'b1)) = (A_10_LH_S, A_10_HL_S) ;
                (posedge B *> (S : 1'b1)) = (B_01_LH_S, B_01_HL_S) ;
                (negedge B *> (S : 1'b1)) = (B_10_LH_S, B_10_HL_S) ;
                (posedge CI *> (S : 1'b1)) = (CI_01_LH_S, CI_01_HL_S) ;
                (negedge CI *> (S : 1'b1)) = (CI_10_LH_S, CI_10_HL_S) ;
                (A *> CO) = (A_LH_CO, A_HL_CO) ;
                (B *> CO) = (B_LH_CO, B_HL_CO) ;
                (CI *> CO) = (CI_LH_CO, CI_HL_CO) ;
        endspecify
endmodule

module fa2a1(S, CO, A, B, CI);
        output S, CO;
        input  A, B, CI;
        xor g1(S, B, CI, A);
        and g2(N2, A, CI);
        and g3(N3, B, CI);
        and g4(N4, A, B);
        nor g5(CO, N2, N3, N4);
        // SPECIFY BLOCK
        specify
                specparam A_01_LH_S = 0, A_01_HL_S = 0 ;
                specparam A_10_LH_S = 0, A_10_HL_S = 0 ;
                specparam B_01_LH_S = 0, B_01_HL_S = 0 ;
                specparam B_10_LH_S = 0, B_10_HL_S = 0 ;
                specparam CI_01_LH_S = 0, CI_01_HL_S = 0 ;
                specparam CI_10_LH_S = 0, CI_10_HL_S = 0 ;
                specparam A_LH_CO = 0, A_HL_CO = 0 ;
                specparam B_LH_CO = 0, B_HL_CO = 0 ;
                specparam CI_LH_CO = 0, CI_HL_CO = 0 ;
                (posedge A *> (S : 1'b1)) = (A_01_LH_S, A_01_HL_S) ;
                (negedge A *> (S : 1'b1)) = (A_10_LH_S, A_10_HL_S) ;
                (posedge B *> (S : 1'b1)) = (B_01_LH_S, B_01_HL_S) ;
                (negedge B *> (S : 1'b1)) = (B_10_LH_S, B_10_HL_S) ;
                (posedge CI *> (S : 1'b1)) = (CI_01_LH_S, CI_01_HL_S) ;
                (negedge CI *> (S : 1'b1)) = (CI_10_LH_S, CI_10_HL_S) ;
                (A *> CO) = (A_LH_CO, A_HL_CO) ;
                (B *> CO) = (B_LH_CO, B_HL_CO) ;
                (CI *> CO) = (CI_LH_CO, CI_HL_CO) ;
        endspecify
endmodule

module fa2a2(S, CO, A, B, CI);
        output S, CO;
        input  A, B, CI;
        xor g1(S, B, CI, A);
        and g2(N2, A, CI);
        and g3(N3, B, CI);
        and g4(N4, A, B);
        nor g5(CO, N2, N3, N4);
        // SPECIFY BLOCK
        specify
                specparam A_01_LH_S = 0, A_01_HL_S = 0 ;
                specparam A_10_LH_S = 0, A_10_HL_S = 0 ;
                specparam B_01_LH_S = 0, B_01_HL_S = 0 ;
                specparam B_10_LH_S = 0, B_10_HL_S = 0 ;
                specparam CI_01_LH_S = 0, CI_01_HL_S = 0 ;
                specparam CI_10_LH_S = 0, CI_10_HL_S = 0 ;
                specparam A_LH_CO = 0, A_HL_CO = 0 ;
                specparam B_LH_CO = 0, B_HL_CO = 0 ;
                specparam CI_LH_CO = 0, CI_HL_CO = 0 ;
                (posedge A *> (S : 1'b1)) = (A_01_LH_S, A_01_HL_S) ;
                (negedge A *> (S : 1'b1)) = (A_10_LH_S, A_10_HL_S) ;
                (posedge B *> (S : 1'b1)) = (B_01_LH_S, B_01_HL_S) ;
                (negedge B *> (S : 1'b1)) = (B_10_LH_S, B_10_HL_S) ;
                (posedge CI *> (S : 1'b1)) = (CI_01_LH_S, CI_01_HL_S) ;
                (negedge CI *> (S : 1'b1)) = (CI_10_LH_S, CI_10_HL_S) ;
                (A *> CO) = (A_LH_CO, A_HL_CO) ;
                (B *> CO) = (B_LH_CO, B_HL_CO) ;
                (CI *> CO) = (CI_LH_CO, CI_HL_CO) ;
        endspecify
endmodule

module fa2a3(S, CO, A, B, CI);
        output S, CO;
        input  A, B, CI;
        xor g1(S, B, CI, A);
        and g2(N2, A, CI);
        and g3(N3, B, CI);
        and g4(N4, A, B);
        nor g5(CO, N2, N3, N4);
        // SPECIFY BLOCK
        specify
                specparam A_01_LH_S = 0, A_01_HL_S = 0 ;
                specparam A_10_LH_S = 0, A_10_HL_S = 0 ;
                specparam B_01_LH_S = 0, B_01_HL_S = 0 ;
                specparam B_10_LH_S = 0, B_10_HL_S = 0 ;
                specparam CI_01_LH_S = 0, CI_01_HL_S = 0 ;
                specparam CI_10_LH_S = 0, CI_10_HL_S = 0 ;
                specparam A_LH_CO = 0, A_HL_CO = 0 ;
                specparam B_LH_CO = 0, B_HL_CO = 0 ;
                specparam CI_LH_CO = 0, CI_HL_CO = 0 ;
                (posedge A *> (S : 1'b1)) = (A_01_LH_S, A_01_HL_S) ;
                (negedge A *> (S : 1'b1)) = (A_10_LH_S, A_10_HL_S) ;
                (posedge B *> (S : 1'b1)) = (B_01_LH_S, B_01_HL_S) ;
                (negedge B *> (S : 1'b1)) = (B_10_LH_S, B_10_HL_S) ;
                (posedge CI *> (S : 1'b1)) = (CI_01_LH_S, CI_01_HL_S) ;
                (negedge CI *> (S : 1'b1)) = (CI_10_LH_S, CI_10_HL_S) ;
                (A *> CO) = (A_LH_CO, A_HL_CO) ;
                (B *> CO) = (B_LH_CO, B_HL_CO) ;
                (CI *> CO) = (CI_LH_CO, CI_HL_CO) ;
        endspecify
endmodule

module fdef1a1(Q, D, E, CLK);
        output Q;
        input  D, E, CLK;
        supply0 PRESET, CLEAR;
        reg NOTIFIER;
        mux g1(DATA, E, D, Q);
        buf g2(Q, QOUT);
        ff g3(QOUT, DATA, CLK, PRESET, CLEAR, NOTIFIER);
        // EXTERNAL TIMING CHECK SIGNALS
        xtc_xor g4(xcheck1, Q, D);
        xtc_buf g6(xcheck2, E);
        // SPECIFY BLOCK
        specify
                specparam tSUd = 0 ;
                specparam tHDd = 0 ;
                specparam tPWclk = 0 ;
                specparam CLK_01_LH_Q = 0, CLK_01_HL_Q = 0 ;
                (posedge CLK *> (Q : 1'b1)) = (CLK_01_LH_Q, CLK_01_HL_Q) ;
                $setup(posedge E &&& xcheck1, posedge CLK, tSUd, NOTIFIER);
                $setup(negedge E &&& xcheck1, posedge CLK, tSUd, NOTIFIER);
                $setup(posedge D &&& xcheck2, posedge CLK, tSUd, NOTIFIER);
                $setup(negedge D &&& xcheck2, posedge CLK, tSUd, NOTIFIER);
                $hold(posedge CLK, posedge E &&& xcheck1, tHDd, NOTIFIER);
                $hold(posedge CLK, negedge E &&& xcheck1, tHDd, NOTIFIER);
                $hold(posedge CLK, posedge D &&& xcheck2, tHDd, NOTIFIER);
                $hold(posedge CLK, negedge D &&& xcheck2, tHDd, NOTIFIER);
                $width(posedge CLK, tPWclk, 0, NOTIFIER);
                $width(negedge CLK, tPWclk, 0, NOTIFIER);
        endspecify
endmodule

module fdef1a15(Q, D, E, CLK);
        output Q;
        input  D, E, CLK;
        supply0 PRESET, CLEAR;
        reg NOTIFIER;
        mux g1(DATA, E, D, Q);
        buf g2(Q, QOUT);
        ff g3(QOUT, DATA, CLK, PRESET, CLEAR, NOTIFIER);
        // EXTERNAL TIMING CHECK SIGNALS
        xtc_xor g4(xcheck1, Q, D);
        xtc_buf g6(xcheck2, E);
        // SPECIFY BLOCK
        specify
                specparam tSUd = 0 ;
                specparam tHDd = 0 ;
                specparam tPWclk = 0 ;
                specparam CLK_01_LH_Q = 0, CLK_01_HL_Q = 0 ;
                (posedge CLK *> (Q : 1'b1)) = (CLK_01_LH_Q, CLK_01_HL_Q) ;
                $setup(posedge E &&& xcheck1, posedge CLK, tSUd, NOTIFIER);
                $setup(negedge E &&& xcheck1, posedge CLK, tSUd, NOTIFIER);
                $setup(posedge D &&& xcheck2, posedge CLK, tSUd, NOTIFIER);
                $setup(negedge D &&& xcheck2, posedge CLK, tSUd, NOTIFIER);
                $hold(posedge CLK, posedge E &&& xcheck1, tHDd, NOTIFIER);
                $hold(posedge CLK, negedge E &&& xcheck1, tHDd, NOTIFIER);
                $hold(posedge CLK, posedge D &&& xcheck2, tHDd, NOTIFIER);
                $hold(posedge CLK, negedge D &&& xcheck2, tHDd, NOTIFIER);
                $width(posedge CLK, tPWclk, 0, NOTIFIER);
                $width(negedge CLK, tPWclk, 0, NOTIFIER);
        endspecify
endmodule

module fdef1a2(Q, D, E, CLK);
        output Q;
        input  D, E, CLK;
        supply0 PRESET, CLEAR;
        reg NOTIFIER;
        mux g1(DATA, E, D, Q);
        buf g2(Q, QOUT);
        ff g3(QOUT, DATA, CLK, PRESET, CLEAR, NOTIFIER);
        // EXTERNAL TIMING CHECK SIGNALS
        xtc_xor g4(xcheck1, Q, D);
        xtc_buf g6(xcheck2, E);
        // SPECIFY BLOCK
        specify
                specparam tSUd = 0 ;
                specparam tHDd = 0 ;
                specparam tPWclk = 0 ;
                specparam CLK_01_LH_Q = 0, CLK_01_HL_Q = 0 ;
                (posedge CLK *> (Q : 1'b1)) = (CLK_01_LH_Q, CLK_01_HL_Q) ;
                $setup(posedge E &&& xcheck1, posedge CLK, tSUd, NOTIFIER);
                $setup(negedge E &&& xcheck1, posedge CLK, tSUd, NOTIFIER);
                $setup(posedge D &&& xcheck2, posedge CLK, tSUd, NOTIFIER);
                $setup(negedge D &&& xcheck2, posedge CLK, tSUd, NOTIFIER);
                $hold(posedge CLK, posedge E &&& xcheck1, tHDd, NOTIFIER);
                $hold(posedge CLK, negedge E &&& xcheck1, tHDd, NOTIFIER);
                $hold(posedge CLK, posedge D &&& xcheck2, tHDd, NOTIFIER);
                $hold(posedge CLK, negedge D &&& xcheck2, tHDd, NOTIFIER);
                $width(posedge CLK, tPWclk, 0, NOTIFIER);
                $width(negedge CLK, tPWclk, 0, NOTIFIER);
        endspecify
endmodule

module fdef1a3(Q, D, E, CLK);
        output Q;
        input  D, E, CLK;
        supply0 PRESET, CLEAR;
        reg NOTIFIER;
        mux g1(DATA, E, D, Q);
        buf g2(Q, QOUT);
        ff g3(QOUT, DATA, CLK, PRESET, CLEAR, NOTIFIER);
        // EXTERNAL TIMING CHECK SIGNALS
        xtc_xor g4(xcheck1, Q, D);
        xtc_buf g6(xcheck2, E);
        // SPECIFY BLOCK
        specify
                specparam tSUd = 0 ;
                specparam tHDd = 0 ;
                specparam tPWclk = 0 ;
                specparam CLK_01_LH_Q = 0, CLK_01_HL_Q = 0 ;
                (posedge CLK *> (Q : 1'b1)) = (CLK_01_LH_Q, CLK_01_HL_Q) ;
                $setup(posedge E &&& xcheck1, posedge CLK, tSUd, NOTIFIER);
                $setup(negedge E &&& xcheck1, posedge CLK, tSUd, NOTIFIER);
                $setup(posedge D &&& xcheck2, posedge CLK, tSUd, NOTIFIER);
                $setup(negedge D &&& xcheck2, posedge CLK, tSUd, NOTIFIER);
                $hold(posedge CLK, posedge E &&& xcheck1, tHDd, NOTIFIER);
                $hold(posedge CLK, negedge E &&& xcheck1, tHDd, NOTIFIER);
                $hold(posedge CLK, posedge D &&& xcheck2, tHDd, NOTIFIER);
                $hold(posedge CLK, negedge D &&& xcheck2, tHDd, NOTIFIER);
                $width(posedge CLK, tPWclk, 0, NOTIFIER);
                $width(negedge CLK, tPWclk, 0, NOTIFIER);
        endspecify
endmodule

module fdef1a6(Q, D, E, CLK);
        output Q;
        input  D, E, CLK;
        supply0 PRESET, CLEAR;
        reg NOTIFIER;
        mux g1(DATA, E, D, Q);
        buf g2(Q, QOUT);
        ff g3(QOUT, DATA, CLK, PRESET, CLEAR, NOTIFIER);
        // EXTERNAL TIMING CHECK SIGNALS
        xtc_xor g4(xcheck1, Q, D);
        xtc_buf g6(xcheck2, E);
        // SPECIFY BLOCK
        specify
                specparam tSUd = 0 ;
                specparam tHDd = 0 ;
                specparam tPWclk = 0 ;
                specparam CLK_01_LH_Q = 0, CLK_01_HL_Q = 0 ;
                (posedge CLK *> (Q : 1'b1)) = (CLK_01_LH_Q, CLK_01_HL_Q) ;
                $setup(posedge E &&& xcheck1, posedge CLK, tSUd, NOTIFIER);
                $setup(negedge E &&& xcheck1, posedge CLK, tSUd, NOTIFIER);
                $setup(posedge D &&& xcheck2, posedge CLK, tSUd, NOTIFIER);
                $setup(negedge D &&& xcheck2, posedge CLK, tSUd, NOTIFIER);
                $hold(posedge CLK, posedge E &&& xcheck1, tHDd, NOTIFIER);
                $hold(posedge CLK, negedge E &&& xcheck1, tHDd, NOTIFIER);
                $hold(posedge CLK, posedge D &&& xcheck2, tHDd, NOTIFIER);
                $hold(posedge CLK, negedge D &&& xcheck2, tHDd, NOTIFIER);
                $width(posedge CLK, tPWclk, 0, NOTIFIER);
                $width(negedge CLK, tPWclk, 0, NOTIFIER);
        endspecify
endmodule

module fdef1a9(Q, D, E, CLK);
        output Q;
        input  D, E, CLK;
        supply0 PRESET, CLEAR;
        reg NOTIFIER;
        mux g1(DATA, E, D, Q);
        buf g2(Q, QOUT);
        ff g3(QOUT, DATA, CLK, PRESET, CLEAR, NOTIFIER);
        // EXTERNAL TIMING CHECK SIGNALS
        xtc_xor g4(xcheck1, Q, D);
        xtc_buf g6(xcheck2, E);
        // SPECIFY BLOCK
        specify
                specparam tSUd = 0 ;
                specparam tHDd = 0 ;
                specparam tPWclk = 0 ;
                specparam CLK_01_LH_Q = 0, CLK_01_HL_Q = 0 ;
                (posedge CLK *> (Q : 1'b1)) = (CLK_01_LH_Q, CLK_01_HL_Q) ;
                $setup(posedge E &&& xcheck1, posedge CLK, tSUd, NOTIFIER);
                $setup(negedge E &&& xcheck1, posedge CLK, tSUd, NOTIFIER);
                $setup(posedge D &&& xcheck2, posedge CLK, tSUd, NOTIFIER);
                $setup(negedge D &&& xcheck2, posedge CLK, tSUd, NOTIFIER);
                $hold(posedge CLK, posedge E &&& xcheck1, tHDd, NOTIFIER);
                $hold(posedge CLK, negedge E &&& xcheck1, tHDd, NOTIFIER);
                $hold(posedge CLK, posedge D &&& xcheck2, tHDd, NOTIFIER);
                $hold(posedge CLK, negedge D &&& xcheck2, tHDd, NOTIFIER);
                $width(posedge CLK, tPWclk, 0, NOTIFIER);
                $width(negedge CLK, tPWclk, 0, NOTIFIER);
        endspecify
endmodule

module fdef2a1(Q, D, E, CLK, CLR);
        output Q;
        input  D, E, CLK, CLR;
        supply0 PRESET;
        reg NOTIFIER;
        mux g1(DATA, E, D, Q);
        not g2(CLEAR, CLR);
        buf g3(Q, QOUT);
        ff g4(QOUT, DATA, CLK, PRESET, CLEAR, NOTIFIER);
        // CONDITIONAL TIMING CHECK SIGNALS
        not g5(check1, CLEAR);
        buf g6(check2, DATA);
        // EXTERNAL TIMING CHECK SIGNALS
        xor     g7(sstz1, Q, D);
        xtc_and g8(xcheck1, check1, sstz1);
        xtc_and g10(xcheck2, check1, E);
        // SPECIFY BLOCK
        specify
                specparam tSUd = 0 ;
                specparam tHDd = 0 ;
                specparam tRECclr = 0 ;
                specparam tPWclk = 0 ;
                specparam tHDclr = 0 ;
                specparam tPWclr = 0 ;
                specparam CLK_01_LH_Q = 0, CLK_01_HL_Q = 0 ;
                specparam CLR_10_LH_Q = 0, CLR_10_HL_Q = 0 ;
                (posedge CLK *> (Q : 1'b1)) = (CLK_01_LH_Q, CLK_01_HL_Q) ;
                (negedge CLR *> (Q : 1'b1)) = (CLR_10_LH_Q, CLR_10_HL_Q) ;
                $setup(posedge E &&& xcheck1, posedge CLK, tSUd, NOTIFIER);
                $setup(negedge E &&& xcheck1, posedge CLK, tSUd, NOTIFIER);
                $setup(posedge D &&& xcheck2, posedge CLK, tSUd, NOTIFIER);
                $setup(negedge D &&& xcheck2, posedge CLK, tSUd, NOTIFIER);
                $hold(posedge CLK, posedge E &&& xcheck1, tHDd, NOTIFIER);
                $hold(posedge CLK, negedge E &&& xcheck1, tHDd, NOTIFIER);
                $hold(posedge CLK, posedge D &&& xcheck2, tHDd, NOTIFIER);
                $hold(posedge CLK, negedge D &&& xcheck2, tHDd, NOTIFIER);
                $recovery(posedge CLR, posedge CLK &&& check2, tRECclr, NOTIFIER);
                $width(posedge CLK &&& check1, tPWclk, 0, NOTIFIER);
                $width(negedge CLK &&& check1, tPWclk, 0, NOTIFIER);
                $hold(posedge CLK, posedge CLR &&& check2, tHDclr, NOTIFIER);
                $hold(posedge CLK, negedge CLR &&& check2, tHDclr, NOTIFIER);
                $width(negedge CLR, tPWclr, 0, NOTIFIER);
        endspecify
endmodule

module fdef2a15(Q, D, E, CLK, CLR);
        output Q;
        input  D, E, CLK, CLR;
        supply0 PRESET;
        reg NOTIFIER;
        mux g1(DATA, E, D, Q);
        not g2(CLEAR, CLR);
        buf g3(Q, QOUT);
        ff g4(QOUT, DATA, CLK, PRESET, CLEAR, NOTIFIER);
        // CONDITIONAL TIMING CHECK SIGNALS
        not g5(check1, CLEAR);
        buf g6(check2, DATA);
        // EXTERNAL TIMING CHECK SIGNALS
        xor     g7(sstz1, Q, D);
        xtc_and g8(xcheck1, check1, sstz1);
        xtc_and g10(xcheck2, check1, E);
        // SPECIFY BLOCK
        specify
                specparam tSUd = 0 ;
                specparam tHDd = 0 ;
                specparam tRECclr = 0 ;
                specparam tPWclk = 0 ;
                specparam tHDclr = 0 ;
                specparam tPWclr = 0 ;
                specparam CLK_01_LH_Q = 0, CLK_01_HL_Q = 0 ;
                specparam CLR_10_LH_Q = 0, CLR_10_HL_Q = 0 ;
                (posedge CLK *> (Q : 1'b1)) = (CLK_01_LH_Q, CLK_01_HL_Q) ;
                (negedge CLR *> (Q : 1'b1)) = (CLR_10_LH_Q, CLR_10_HL_Q) ;
                $setup(posedge E &&& xcheck1, posedge CLK, tSUd, NOTIFIER);
                $setup(negedge E &&& xcheck1, posedge CLK, tSUd, NOTIFIER);
                $setup(posedge D &&& xcheck2, posedge CLK, tSUd, NOTIFIER);
                $setup(negedge D &&& xcheck2, posedge CLK, tSUd, NOTIFIER);
                $hold(posedge CLK, posedge E &&& xcheck1, tHDd, NOTIFIER);
                $hold(posedge CLK, negedge E &&& xcheck1, tHDd, NOTIFIER);
                $hold(posedge CLK, posedge D &&& xcheck2, tHDd, NOTIFIER);
                $hold(posedge CLK, negedge D &&& xcheck2, tHDd, NOTIFIER);
                $recovery(posedge CLR, posedge CLK &&& check2, tRECclr, NOTIFIER);
                $width(posedge CLK &&& check1, tPWclk, 0, NOTIFIER);
                $width(negedge CLK &&& check1, tPWclk, 0, NOTIFIER);
                $hold(posedge CLK, posedge CLR &&& check2, tHDclr, NOTIFIER);
                $hold(posedge CLK, negedge CLR &&& check2, tHDclr, NOTIFIER);
                $width(negedge CLR, tPWclr, 0, NOTIFIER);
        endspecify
endmodule

module fdef2a2(Q, D, E, CLK, CLR);
        output Q;
        input  D, E, CLK, CLR;
        supply0 PRESET;
        reg NOTIFIER;
        mux g1(DATA, E, D, Q);
        not g2(CLEAR, CLR);
        buf g3(Q, QOUT);
        ff g4(QOUT, DATA, CLK, PRESET, CLEAR, NOTIFIER);
        // CONDITIONAL TIMING CHECK SIGNALS
        not g5(check1, CLEAR);
        buf g6(check2, DATA);
        // EXTERNAL TIMING CHECK SIGNALS
        xor     g7(sstz1, Q, D);
        xtc_and g8(xcheck1, check1, sstz1);
        xtc_and g10(xcheck2, check1, E);
        // SPECIFY BLOCK
        specify
                specparam tSUd = 0 ;
                specparam tHDd = 0 ;
                specparam tRECclr = 0 ;
                specparam tPWclk = 0 ;
                specparam tHDclr = 0 ;
                specparam tPWclr = 0 ;
                specparam CLK_01_LH_Q = 0, CLK_01_HL_Q = 0 ;
                specparam CLR_10_LH_Q = 0, CLR_10_HL_Q = 0 ;
                (posedge CLK *> (Q : 1'b1)) = (CLK_01_LH_Q, CLK_01_HL_Q) ;
                (negedge CLR *> (Q : 1'b1)) = (CLR_10_LH_Q, CLR_10_HL_Q) ;
                $setup(posedge E &&& xcheck1, posedge CLK, tSUd, NOTIFIER);
                $setup(negedge E &&& xcheck1, posedge CLK, tSUd, NOTIFIER);
                $setup(posedge D &&& xcheck2, posedge CLK, tSUd, NOTIFIER);
                $setup(negedge D &&& xcheck2, posedge CLK, tSUd, NOTIFIER);
                $hold(posedge CLK, posedge E &&& xcheck1, tHDd, NOTIFIER);
                $hold(posedge CLK, negedge E &&& xcheck1, tHDd, NOTIFIER);
                $hold(posedge CLK, posedge D &&& xcheck2, tHDd, NOTIFIER);
                $hold(posedge CLK, negedge D &&& xcheck2, tHDd, NOTIFIER);
                $recovery(posedge CLR, posedge CLK &&& check2, tRECclr, NOTIFIER);
                $width(posedge CLK &&& check1, tPWclk, 0, NOTIFIER);
                $width(negedge CLK &&& check1, tPWclk, 0, NOTIFIER);
                $hold(posedge CLK, posedge CLR &&& check2, tHDclr, NOTIFIER);
                $hold(posedge CLK, negedge CLR &&& check2, tHDclr, NOTIFIER);
                $width(negedge CLR, tPWclr, 0, NOTIFIER);
        endspecify
endmodule

module fdef2a3(Q, D, E, CLK, CLR);
        output Q;
        input  D, E, CLK, CLR;
        supply0 PRESET;
        reg NOTIFIER;
        mux g1(DATA, E, D, Q);
        not g2(CLEAR, CLR);
        buf g3(Q, QOUT);
        ff g4(QOUT, DATA, CLK, PRESET, CLEAR, NOTIFIER);
        // CONDITIONAL TIMING CHECK SIGNALS
        not g5(check1, CLEAR);
        buf g6(check2, DATA);
        // EXTERNAL TIMING CHECK SIGNALS
        xor     g7(sstz1, Q, D);
        xtc_and g8(xcheck1, check1, sstz1);
        xtc_and g10(xcheck2, check1, E);
        // SPECIFY BLOCK
        specify
                specparam tSUd = 0 ;
                specparam tHDd = 0 ;
                specparam tRECclr = 0 ;
                specparam tPWclk = 0 ;
                specparam tHDclr = 0 ;
                specparam tPWclr = 0 ;
                specparam CLK_01_LH_Q = 0, CLK_01_HL_Q = 0 ;
                specparam CLR_10_LH_Q = 0, CLR_10_HL_Q = 0 ;
                (posedge CLK *> (Q : 1'b1)) = (CLK_01_LH_Q, CLK_01_HL_Q) ;
                (negedge CLR *> (Q : 1'b1)) = (CLR_10_LH_Q, CLR_10_HL_Q) ;
                $setup(posedge E &&& xcheck1, posedge CLK, tSUd, NOTIFIER);
                $setup(negedge E &&& xcheck1, posedge CLK, tSUd, NOTIFIER);
                $setup(posedge D &&& xcheck2, posedge CLK, tSUd, NOTIFIER);
                $setup(negedge D &&& xcheck2, posedge CLK, tSUd, NOTIFIER);
                $hold(posedge CLK, posedge E &&& xcheck1, tHDd, NOTIFIER);
                $hold(posedge CLK, negedge E &&& xcheck1, tHDd, NOTIFIER);
                $hold(posedge CLK, posedge D &&& xcheck2, tHDd, NOTIFIER);
                $hold(posedge CLK, negedge D &&& xcheck2, tHDd, NOTIFIER);
                $recovery(posedge CLR, posedge CLK &&& check2, tRECclr, NOTIFIER);
                $width(posedge CLK &&& check1, tPWclk, 0, NOTIFIER);
                $width(negedge CLK &&& check1, tPWclk, 0, NOTIFIER);
                $hold(posedge CLK, posedge CLR &&& check2, tHDclr, NOTIFIER);
                $hold(posedge CLK, negedge CLR &&& check2, tHDclr, NOTIFIER);
                $width(negedge CLR, tPWclr, 0, NOTIFIER);
        endspecify
endmodule

module fdef2a6(Q, D, E, CLK, CLR);
        output Q;
        input  D, E, CLK, CLR;
        supply0 PRESET;
        reg NOTIFIER;
        mux g1(DATA, E, D, Q);
        not g2(CLEAR, CLR);
        buf g3(Q, QOUT);
        ff g4(QOUT, DATA, CLK, PRESET, CLEAR, NOTIFIER);
        // CONDITIONAL TIMING CHECK SIGNALS
        not g5(check1, CLEAR);
        buf g6(check2, DATA);
        // EXTERNAL TIMING CHECK SIGNALS
        xor     g7(sstz1, Q, D);
        xtc_and g8(xcheck1, check1, sstz1);
        xtc_and g10(xcheck2, check1, E);
        // SPECIFY BLOCK
        specify
                specparam tSUd = 0 ;
                specparam tHDd = 0 ;
                specparam tRECclr = 0 ;
                specparam tPWclk = 0 ;
                specparam tHDclr = 0 ;
                specparam tPWclr = 0 ;
                specparam CLK_01_LH_Q = 0, CLK_01_HL_Q = 0 ;
                specparam CLR_10_LH_Q = 0, CLR_10_HL_Q = 0 ;
                (posedge CLK *> (Q : 1'b1)) = (CLK_01_LH_Q, CLK_01_HL_Q) ;
                (negedge CLR *> (Q : 1'b1)) = (CLR_10_LH_Q, CLR_10_HL_Q) ;
                $setup(posedge E &&& xcheck1, posedge CLK, tSUd, NOTIFIER);
                $setup(negedge E &&& xcheck1, posedge CLK, tSUd, NOTIFIER);
                $setup(posedge D &&& xcheck2, posedge CLK, tSUd, NOTIFIER);
                $setup(negedge D &&& xcheck2, posedge CLK, tSUd, NOTIFIER);
                $hold(posedge CLK, posedge E &&& xcheck1, tHDd, NOTIFIER);
                $hold(posedge CLK, negedge E &&& xcheck1, tHDd, NOTIFIER);
                $hold(posedge CLK, posedge D &&& xcheck2, tHDd, NOTIFIER);
                $hold(posedge CLK, negedge D &&& xcheck2, tHDd, NOTIFIER);
                $recovery(posedge CLR, posedge CLK &&& check2, tRECclr, NOTIFIER);
                $width(posedge CLK &&& check1, tPWclk, 0, NOTIFIER);
                $width(negedge CLK &&& check1, tPWclk, 0, NOTIFIER);
                $hold(posedge CLK, posedge CLR &&& check2, tHDclr, NOTIFIER);
                $hold(posedge CLK, negedge CLR &&& check2, tHDclr, NOTIFIER);
                $width(negedge CLR, tPWclr, 0, NOTIFIER);
        endspecify
endmodule

module fdef2a9(Q, D, E, CLK, CLR);
        output Q;
        input  D, E, CLK, CLR;
        supply0 PRESET;
        reg NOTIFIER;
        mux g1(DATA, E, D, Q);
        not g2(CLEAR, CLR);
        buf g3(Q, QOUT);
        ff g4(QOUT, DATA, CLK, PRESET, CLEAR, NOTIFIER);
        // CONDITIONAL TIMING CHECK SIGNALS
        not g5(check1, CLEAR);
        buf g6(check2, DATA);
        // EXTERNAL TIMING CHECK SIGNALS
        xor     g7(sstz1, Q, D);
        xtc_and g8(xcheck1, check1, sstz1);
        xtc_and g10(xcheck2, check1, E);
        // SPECIFY BLOCK
        specify
                specparam tSUd = 0 ;
                specparam tHDd = 0 ;
                specparam tRECclr = 0 ;
                specparam tPWclk = 0 ;
                specparam tHDclr = 0 ;
                specparam tPWclr = 0 ;
                specparam CLK_01_LH_Q = 0, CLK_01_HL_Q = 0 ;
                specparam CLR_10_LH_Q = 0, CLR_10_HL_Q = 0 ;
                (posedge CLK *> (Q : 1'b1)) = (CLK_01_LH_Q, CLK_01_HL_Q) ;
                (negedge CLR *> (Q : 1'b1)) = (CLR_10_LH_Q, CLR_10_HL_Q) ;
                $setup(posedge E &&& xcheck1, posedge CLK, tSUd, NOTIFIER);
                $setup(negedge E &&& xcheck1, posedge CLK, tSUd, NOTIFIER);
                $setup(posedge D &&& xcheck2, posedge CLK, tSUd, NOTIFIER);
                $setup(negedge D &&& xcheck2, posedge CLK, tSUd, NOTIFIER);
                $hold(posedge CLK, posedge E &&& xcheck1, tHDd, NOTIFIER);
                $hold(posedge CLK, negedge E &&& xcheck1, tHDd, NOTIFIER);
                $hold(posedge CLK, posedge D &&& xcheck2, tHDd, NOTIFIER);
                $hold(posedge CLK, negedge D &&& xcheck2, tHDd, NOTIFIER);
                $recovery(posedge CLR, posedge CLK &&& check2, tRECclr, NOTIFIER);
                $width(posedge CLK &&& check1, tPWclk, 0, NOTIFIER);
                $width(negedge CLK &&& check1, tPWclk, 0, NOTIFIER);
                $hold(posedge CLK, posedge CLR &&& check2, tHDclr, NOTIFIER);
                $hold(posedge CLK, negedge CLR &&& check2, tHDclr, NOTIFIER);
                $width(negedge CLR, tPWclr, 0, NOTIFIER);
        endspecify
endmodule

module fdef2c1(QN, D, E, CLK, CLR);
        output QN;
        input  D, E, CLK, CLR;
        supply0 PRESET;
        reg NOTIFIER;
        not g1(N1, QN);
        mux g2(DATA, E, D, N1);
        not g3(CLEAR, CLR);
        not g4(QN, QOUT);
        ff g5(QOUT, DATA, CLK, PRESET, CLEAR, NOTIFIER);
        // CONDITIONAL TIMING CHECK SIGNALS
        not g6(check1, CLEAR);
        buf g7(check2, DATA);
        // EXTERNAL TIMING CHECK SIGNALS
        xor     g8_2(sstz1, D, N1);
        xtc_and g9(xcheck1, check1, sstz1);
        xtc_and g11(xcheck2, check1, E);
        // SPECIFY BLOCK
        specify
                specparam tSUd = 0 ;
                specparam tHDd = 0 ;
                specparam tRECclr = 0 ;
                specparam tPWclk = 0 ;
                specparam tHDclr = 0 ;
                specparam tPWclr = 0 ;
                specparam CLK_01_LH_QN = 0, CLK_01_HL_QN = 0 ;
                specparam CLR_10_LH_QN = 0, CLR_10_HL_QN = 0 ;
                (posedge CLK *> (QN : 1'b1)) = (CLK_01_LH_QN, CLK_01_HL_QN) ;
                (negedge CLR *> (QN : 1'b1)) = (CLR_10_LH_QN, CLR_10_HL_QN) ;
                $setup(posedge E &&& xcheck1, posedge CLK, tSUd, NOTIFIER);
                $setup(negedge E &&& xcheck1, posedge CLK, tSUd, NOTIFIER);
                $setup(posedge D &&& xcheck2, posedge CLK, tSUd, NOTIFIER);
                $setup(negedge D &&& xcheck2, posedge CLK, tSUd, NOTIFIER);
                $hold(posedge CLK, posedge E &&& xcheck1, tHDd, NOTIFIER);
                $hold(posedge CLK, negedge E &&& xcheck1, tHDd, NOTIFIER);
                $hold(posedge CLK, posedge D &&& xcheck2, tHDd, NOTIFIER);
                $hold(posedge CLK, negedge D &&& xcheck2, tHDd, NOTIFIER);
                $recovery(posedge CLR, posedge CLK &&& check2, tRECclr, NOTIFIER);
                $width(posedge CLK &&& check1, tPWclk, 0, NOTIFIER);
                $width(negedge CLK &&& check1, tPWclk, 0, NOTIFIER);
                $hold(posedge CLK, posedge CLR &&& check2, tHDclr, NOTIFIER);
                $hold(posedge CLK, negedge CLR &&& check2, tHDclr, NOTIFIER);
                $width(negedge CLR, tPWclr, 0, NOTIFIER);
        endspecify
endmodule

module fdef2c15(QN, D, E, CLK, CLR);
        output QN;
        input  D, E, CLK, CLR;
        supply0 PRESET;
        reg NOTIFIER;
        not g1(N1, QN);
        mux g2(DATA, E, D, N1);
        not g3(CLEAR, CLR);
        not g4(QN, QOUT);
        ff g5(QOUT, DATA, CLK, PRESET, CLEAR, NOTIFIER);
        // CONDITIONAL TIMING CHECK SIGNALS
        not g6(check1, CLEAR);
        buf g7(check2, DATA);
        // EXTERNAL TIMING CHECK SIGNALS
        xor     g8_2(sstz1, D, N1);
        xtc_and g9(xcheck1, check1, sstz1);
        xtc_and g11(xcheck2, check1, E);
        // SPECIFY BLOCK
        specify
                specparam tSUd = 0 ;
                specparam tHDd = 0 ;
                specparam tRECclr = 0 ;
                specparam tPWclk = 0 ;
                specparam tHDclr = 0 ;
                specparam tPWclr = 0 ;
                specparam CLK_01_LH_QN = 0, CLK_01_HL_QN = 0 ;
                specparam CLR_10_LH_QN = 0, CLR_10_HL_QN = 0 ;
                (posedge CLK *> (QN : 1'b1)) = (CLK_01_LH_QN, CLK_01_HL_QN) ;
                (negedge CLR *> (QN : 1'b1)) = (CLR_10_LH_QN, CLR_10_HL_QN) ;
                $setup(posedge E &&& xcheck1, posedge CLK, tSUd, NOTIFIER);
                $setup(negedge E &&& xcheck1, posedge CLK, tSUd, NOTIFIER);
                $setup(posedge D &&& xcheck2, posedge CLK, tSUd, NOTIFIER);
                $setup(negedge D &&& xcheck2, posedge CLK, tSUd, NOTIFIER);
                $hold(posedge CLK, posedge E &&& xcheck1, tHDd, NOTIFIER);
                $hold(posedge CLK, negedge E &&& xcheck1, tHDd, NOTIFIER);
                $hold(posedge CLK, posedge D &&& xcheck2, tHDd, NOTIFIER);
                $hold(posedge CLK, negedge D &&& xcheck2, tHDd, NOTIFIER);
                $recovery(posedge CLR, posedge CLK &&& check2, tRECclr, NOTIFIER);
                $width(posedge CLK &&& check1, tPWclk, 0, NOTIFIER);
                $width(negedge CLK &&& check1, tPWclk, 0, NOTIFIER);
                $hold(posedge CLK, posedge CLR &&& check2, tHDclr, NOTIFIER);
                $hold(posedge CLK, negedge CLR &&& check2, tHDclr, NOTIFIER);
                $width(negedge CLR, tPWclr, 0, NOTIFIER);
        endspecify
endmodule

module fdef2c2(QN, D, E, CLK, CLR);
        output QN;
        input  D, E, CLK, CLR;
        supply0 PRESET;
        reg NOTIFIER;
        not g1(N1, QN);
        mux g2(DATA, E, D, N1);
        not g3(CLEAR, CLR);
        not g4(QN, QOUT);
        ff g5(QOUT, DATA, CLK, PRESET, CLEAR, NOTIFIER);
        // CONDITIONAL TIMING CHECK SIGNALS
        not g6(check1, CLEAR);
        buf g7(check2, DATA);
        // EXTERNAL TIMING CHECK SIGNALS
        xor     g8_2(sstz1, D, N1);
        xtc_and g9(xcheck1, check1, sstz1);
        xtc_and g11(xcheck2, check1, E);
        // SPECIFY BLOCK
        specify
                specparam tSUd = 0 ;
                specparam tHDd = 0 ;
                specparam tRECclr = 0 ;
                specparam tPWclk = 0 ;
                specparam tHDclr = 0 ;
                specparam tPWclr = 0 ;
                specparam CLK_01_LH_QN = 0, CLK_01_HL_QN = 0 ;
                specparam CLR_10_LH_QN = 0, CLR_10_HL_QN = 0 ;
                (posedge CLK *> (QN : 1'b1)) = (CLK_01_LH_QN, CLK_01_HL_QN) ;
                (negedge CLR *> (QN : 1'b1)) = (CLR_10_LH_QN, CLR_10_HL_QN) ;
                $setup(posedge E &&& xcheck1, posedge CLK, tSUd, NOTIFIER);
                $setup(negedge E &&& xcheck1, posedge CLK, tSUd, NOTIFIER);
                $setup(posedge D &&& xcheck2, posedge CLK, tSUd, NOTIFIER);
                $setup(negedge D &&& xcheck2, posedge CLK, tSUd, NOTIFIER);
                $hold(posedge CLK, posedge E &&& xcheck1, tHDd, NOTIFIER);
                $hold(posedge CLK, negedge E &&& xcheck1, tHDd, NOTIFIER);
                $hold(posedge CLK, posedge D &&& xcheck2, tHDd, NOTIFIER);
                $hold(posedge CLK, negedge D &&& xcheck2, tHDd, NOTIFIER);
                $recovery(posedge CLR, posedge CLK &&& check2, tRECclr, NOTIFIER);
                $width(posedge CLK &&& check1, tPWclk, 0, NOTIFIER);
                $width(negedge CLK &&& check1, tPWclk, 0, NOTIFIER);
                $hold(posedge CLK, posedge CLR &&& check2, tHDclr, NOTIFIER);
                $hold(posedge CLK, negedge CLR &&& check2, tHDclr, NOTIFIER);
                $width(negedge CLR, tPWclr, 0, NOTIFIER);
        endspecify
endmodule

module fdef2c3(QN, D, E, CLK, CLR);
        output QN;
        input  D, E, CLK, CLR;
        supply0 PRESET;
        reg NOTIFIER;
        not g1(N1, QN);
        mux g2(DATA, E, D, N1);
        not g3(CLEAR, CLR);
        not g4(QN, QOUT);
        ff g5(QOUT, DATA, CLK, PRESET, CLEAR, NOTIFIER);
        // CONDITIONAL TIMING CHECK SIGNALS
        not g6(check1, CLEAR);
        buf g7(check2, DATA);
        // EXTERNAL TIMING CHECK SIGNALS
        xor     g8_2(sstz1, D, N1);
        xtc_and g9(xcheck1, check1, sstz1);
        xtc_and g11(xcheck2, check1, E);
        // SPECIFY BLOCK
        specify
                specparam tSUd = 0 ;
                specparam tHDd = 0 ;
                specparam tRECclr = 0 ;
                specparam tPWclk = 0 ;
                specparam tHDclr = 0 ;
                specparam tPWclr = 0 ;
                specparam CLK_01_LH_QN = 0, CLK_01_HL_QN = 0 ;
                specparam CLR_10_LH_QN = 0, CLR_10_HL_QN = 0 ;
                (posedge CLK *> (QN : 1'b1)) = (CLK_01_LH_QN, CLK_01_HL_QN) ;
                (negedge CLR *> (QN : 1'b1)) = (CLR_10_LH_QN, CLR_10_HL_QN) ;
                $setup(posedge E &&& xcheck1, posedge CLK, tSUd, NOTIFIER);
                $setup(negedge E &&& xcheck1, posedge CLK, tSUd, NOTIFIER);
                $setup(posedge D &&& xcheck2, posedge CLK, tSUd, NOTIFIER);
                $setup(negedge D &&& xcheck2, posedge CLK, tSUd, NOTIFIER);
                $hold(posedge CLK, posedge E &&& xcheck1, tHDd, NOTIFIER);
                $hold(posedge CLK, negedge E &&& xcheck1, tHDd, NOTIFIER);
                $hold(posedge CLK, posedge D &&& xcheck2, tHDd, NOTIFIER);
                $hold(posedge CLK, negedge D &&& xcheck2, tHDd, NOTIFIER);
                $recovery(posedge CLR, posedge CLK &&& check2, tRECclr, NOTIFIER);
                $width(posedge CLK &&& check1, tPWclk, 0, NOTIFIER);
                $width(negedge CLK &&& check1, tPWclk, 0, NOTIFIER);
                $hold(posedge CLK, posedge CLR &&& check2, tHDclr, NOTIFIER);
                $hold(posedge CLK, negedge CLR &&& check2, tHDclr, NOTIFIER);
                $width(negedge CLR, tPWclr, 0, NOTIFIER);
        endspecify
endmodule

module fdef2c6(QN, D, E, CLK, CLR);
        output QN;
        input  D, E, CLK, CLR;
        supply0 PRESET;
        reg NOTIFIER;
        not g1(N1, QN);
        mux g2(DATA, E, D, N1);
        not g3(CLEAR, CLR);
        not g4(QN, QOUT);
        ff g5(QOUT, DATA, CLK, PRESET, CLEAR, NOTIFIER);
        // CONDITIONAL TIMING CHECK SIGNALS
        not g6(check1, CLEAR);
        buf g7(check2, DATA);
        // EXTERNAL TIMING CHECK SIGNALS
        xor     g8_2(sstz1, D, N1);
        xtc_and g9(xcheck1, check1, sstz1);
        xtc_and g11(xcheck2, check1, E);
        // SPECIFY BLOCK
        specify
                specparam tSUd = 0 ;
                specparam tHDd = 0 ;
                specparam tRECclr = 0 ;
                specparam tPWclk = 0 ;
                specparam tHDclr = 0 ;
                specparam tPWclr = 0 ;
                specparam CLK_01_LH_QN = 0, CLK_01_HL_QN = 0 ;
                specparam CLR_10_LH_QN = 0, CLR_10_HL_QN = 0 ;
                (posedge CLK *> (QN : 1'b1)) = (CLK_01_LH_QN, CLK_01_HL_QN) ;
                (negedge CLR *> (QN : 1'b1)) = (CLR_10_LH_QN, CLR_10_HL_QN) ;
                $setup(posedge E &&& xcheck1, posedge CLK, tSUd, NOTIFIER);
                $setup(negedge E &&& xcheck1, posedge CLK, tSUd, NOTIFIER);
                $setup(posedge D &&& xcheck2, posedge CLK, tSUd, NOTIFIER);
                $setup(negedge D &&& xcheck2, posedge CLK, tSUd, NOTIFIER);
                $hold(posedge CLK, posedge E &&& xcheck1, tHDd, NOTIFIER);
                $hold(posedge CLK, negedge E &&& xcheck1, tHDd, NOTIFIER);
                $hold(posedge CLK, posedge D &&& xcheck2, tHDd, NOTIFIER);
                $hold(posedge CLK, negedge D &&& xcheck2, tHDd, NOTIFIER);
                $recovery(posedge CLR, posedge CLK &&& check2, tRECclr, NOTIFIER);
                $width(posedge CLK &&& check1, tPWclk, 0, NOTIFIER);
                $width(negedge CLK &&& check1, tPWclk, 0, NOTIFIER);
                $hold(posedge CLK, posedge CLR &&& check2, tHDclr, NOTIFIER);
                $hold(posedge CLK, negedge CLR &&& check2, tHDclr, NOTIFIER);
                $width(negedge CLR, tPWclr, 0, NOTIFIER);
        endspecify
endmodule

module fdef2c9(QN, D, E, CLK, CLR);
        output QN;
        input  D, E, CLK, CLR;
        supply0 PRESET;
        reg NOTIFIER;
        not g1(N1, QN);
        mux g2(DATA, E, D, N1);
        not g3(CLEAR, CLR);
        not g4(QN, QOUT);
        ff g5(QOUT, DATA, CLK, PRESET, CLEAR, NOTIFIER);
        // CONDITIONAL TIMING CHECK SIGNALS
        not g6(check1, CLEAR);
        buf g7(check2, DATA);
        // EXTERNAL TIMING CHECK SIGNALS
        xor     g8_2(sstz1, D, N1);
        xtc_and g9(xcheck1, check1, sstz1);
        xtc_and g11(xcheck2, check1, E);
        // SPECIFY BLOCK
        specify
                specparam tSUd = 0 ;
                specparam tHDd = 0 ;
                specparam tRECclr = 0 ;
                specparam tPWclk = 0 ;
                specparam tHDclr = 0 ;
                specparam tPWclr = 0 ;
                specparam CLK_01_LH_QN = 0, CLK_01_HL_QN = 0 ;
                specparam CLR_10_LH_QN = 0, CLR_10_HL_QN = 0 ;
                (posedge CLK *> (QN : 1'b1)) = (CLK_01_LH_QN, CLK_01_HL_QN) ;
                (negedge CLR *> (QN : 1'b1)) = (CLR_10_LH_QN, CLR_10_HL_QN) ;
                $setup(posedge E &&& xcheck1, posedge CLK, tSUd, NOTIFIER);
                $setup(negedge E &&& xcheck1, posedge CLK, tSUd, NOTIFIER);
                $setup(posedge D &&& xcheck2, posedge CLK, tSUd, NOTIFIER);
                $setup(negedge D &&& xcheck2, posedge CLK, tSUd, NOTIFIER);
                $hold(posedge CLK, posedge E &&& xcheck1, tHDd, NOTIFIER);
                $hold(posedge CLK, negedge E &&& xcheck1, tHDd, NOTIFIER);
                $hold(posedge CLK, posedge D &&& xcheck2, tHDd, NOTIFIER);
                $hold(posedge CLK, negedge D &&& xcheck2, tHDd, NOTIFIER);
                $recovery(posedge CLR, posedge CLK &&& check2, tRECclr, NOTIFIER);
                $width(posedge CLK &&& check1, tPWclk, 0, NOTIFIER);
                $width(negedge CLK &&& check1, tPWclk, 0, NOTIFIER);
                $hold(posedge CLK, posedge CLR &&& check2, tHDclr, NOTIFIER);
                $hold(posedge CLK, negedge CLR &&& check2, tHDclr, NOTIFIER);
                $width(negedge CLR, tPWclr, 0, NOTIFIER);
        endspecify
endmodule

module fdef3a1(Q, D, E, CLK, PRE);
        output Q;
        input  D, E, CLK, PRE;
        supply0 CLEAR;
        reg NOTIFIER;
        mux g1(DATA, E, D, Q);
        not g2(PRESET, PRE);
        buf g3(Q, QOUT);
        ff g4(QOUT, DATA, CLK, PRESET, CLEAR, NOTIFIER);
        // CONDITIONAL TIMING CHECK SIGNALS
        not g5(check1, PRESET);
        not g6(check2, DATA);
        // EXTERNAL TIMING CHECK SIGNALS
        xor     g7(sstz1, Q, D);
        xtc_and g8(xcheck1, check1, sstz1);
        xtc_and g10(xcheck2, check1, E);
        // SPECIFY BLOCK
        specify
                specparam tSUd = 0 ;
                specparam tHDd = 0 ;
                specparam tRECpre = 0 ;
                specparam tPWclk = 0 ;
                specparam tHDpre = 0 ;
                specparam tPWpre = 0 ;
                specparam CLK_01_LH_Q = 0, CLK_01_HL_Q = 0 ;
                specparam PRE_10_LH_Q = 0, PRE_10_HL_Q = 0 ;
                (posedge CLK *> (Q : 1'b1)) = (CLK_01_LH_Q, CLK_01_HL_Q) ;
                (negedge PRE *> (Q : 1'b1)) = (PRE_10_LH_Q, PRE_10_HL_Q) ;
                $setup(posedge E &&& xcheck1, posedge CLK, tSUd, NOTIFIER);
                $setup(negedge E &&& xcheck1, posedge CLK, tSUd, NOTIFIER);
                $setup(posedge D &&& xcheck2, posedge CLK, tSUd, NOTIFIER);
                $setup(negedge D &&& xcheck2, posedge CLK, tSUd, NOTIFIER);
                $hold(posedge CLK, posedge E &&& xcheck1, tHDd, NOTIFIER);
                $hold(posedge CLK, negedge E &&& xcheck1, tHDd, NOTIFIER);
                $hold(posedge CLK, posedge D &&& xcheck2, tHDd, NOTIFIER);
                $hold(posedge CLK, negedge D &&& xcheck2, tHDd, NOTIFIER);
                $recovery(posedge PRE, posedge CLK &&& check2, tRECpre, NOTIFIER);
                $width(posedge CLK &&& check1, tPWclk, 0, NOTIFIER);
                $width(negedge CLK &&& check1, tPWclk, 0, NOTIFIER);
                $hold(posedge CLK, posedge PRE &&& check2, tHDpre, NOTIFIER);
                $hold(posedge CLK, negedge PRE &&& check2, tHDpre, NOTIFIER);
                $width(negedge PRE, tPWpre, 0, NOTIFIER);
        endspecify
endmodule

module fdef3a15(Q, D, E, CLK, PRE);
        output Q;
        input  D, E, CLK, PRE;
        supply0 CLEAR;
        reg NOTIFIER;
        mux g1(DATA, E, D, Q);
        not g2(PRESET, PRE);
        buf g3(Q, QOUT);
        ff g4(QOUT, DATA, CLK, PRESET, CLEAR, NOTIFIER);
        // CONDITIONAL TIMING CHECK SIGNALS
        not g5(check1, PRESET);
        not g6(check2, DATA);
        // EXTERNAL TIMING CHECK SIGNALS
        xor     g7(sstz1, Q, D);
        xtc_and g8(xcheck1, check1, sstz1);
        xtc_and g10(xcheck2, check1, E);
        // SPECIFY BLOCK
        specify
                specparam tSUd = 0 ;
                specparam tHDd = 0 ;
                specparam tRECpre = 0 ;
                specparam tPWclk = 0 ;
                specparam tHDpre = 0 ;
                specparam tPWpre = 0 ;
                specparam CLK_01_LH_Q = 0, CLK_01_HL_Q = 0 ;
                specparam PRE_10_LH_Q = 0, PRE_10_HL_Q = 0 ;
                (posedge CLK *> (Q : 1'b1)) = (CLK_01_LH_Q, CLK_01_HL_Q) ;
                (negedge PRE *> (Q : 1'b1)) = (PRE_10_LH_Q, PRE_10_HL_Q) ;
                $setup(posedge E &&& xcheck1, posedge CLK, tSUd, NOTIFIER);
                $setup(negedge E &&& xcheck1, posedge CLK, tSUd, NOTIFIER);
                $setup(posedge D &&& xcheck2, posedge CLK, tSUd, NOTIFIER);
                $setup(negedge D &&& xcheck2, posedge CLK, tSUd, NOTIFIER);
                $hold(posedge CLK, posedge E &&& xcheck1, tHDd, NOTIFIER);
                $hold(posedge CLK, negedge E &&& xcheck1, tHDd, NOTIFIER);
                $hold(posedge CLK, posedge D &&& xcheck2, tHDd, NOTIFIER);
                $hold(posedge CLK, negedge D &&& xcheck2, tHDd, NOTIFIER);
                $recovery(posedge PRE, posedge CLK &&& check2, tRECpre, NOTIFIER);
                $width(posedge CLK &&& check1, tPWclk, 0, NOTIFIER);
                $width(negedge CLK &&& check1, tPWclk, 0, NOTIFIER);
                $hold(posedge CLK, posedge PRE &&& check2, tHDpre, NOTIFIER);
                $hold(posedge CLK, negedge PRE &&& check2, tHDpre, NOTIFIER);
                $width(negedge PRE, tPWpre, 0, NOTIFIER);
        endspecify
endmodule

module fdef3a2(Q, D, E, CLK, PRE);
        output Q;
        input  D, E, CLK, PRE;
        supply0 CLEAR;
        reg NOTIFIER;
        mux g1(DATA, E, D, Q);
        not g2(PRESET, PRE);
        buf g3(Q, QOUT);
        ff g4(QOUT, DATA, CLK, PRESET, CLEAR, NOTIFIER);
        // CONDITIONAL TIMING CHECK SIGNALS
        not g5(check1, PRESET);
        not g6(check2, DATA);
        // EXTERNAL TIMING CHECK SIGNALS
        xor     g7(sstz1, Q, D);
        xtc_and g8(xcheck1, check1, sstz1);
        xtc_and g10(xcheck2, check1, E);
        // SPECIFY BLOCK
        specify
                specparam tSUd = 0 ;
                specparam tHDd = 0 ;
                specparam tRECpre = 0 ;
                specparam tPWclk = 0 ;
                specparam tHDpre = 0 ;
                specparam tPWpre = 0 ;
                specparam CLK_01_LH_Q = 0, CLK_01_HL_Q = 0 ;
                specparam PRE_10_LH_Q = 0, PRE_10_HL_Q = 0 ;
                (posedge CLK *> (Q : 1'b1)) = (CLK_01_LH_Q, CLK_01_HL_Q) ;
                (negedge PRE *> (Q : 1'b1)) = (PRE_10_LH_Q, PRE_10_HL_Q) ;
                $setup(posedge E &&& xcheck1, posedge CLK, tSUd, NOTIFIER);
                $setup(negedge E &&& xcheck1, posedge CLK, tSUd, NOTIFIER);
                $setup(posedge D &&& xcheck2, posedge CLK, tSUd, NOTIFIER);
                $setup(negedge D &&& xcheck2, posedge CLK, tSUd, NOTIFIER);
                $hold(posedge CLK, posedge E &&& xcheck1, tHDd, NOTIFIER);
                $hold(posedge CLK, negedge E &&& xcheck1, tHDd, NOTIFIER);
                $hold(posedge CLK, posedge D &&& xcheck2, tHDd, NOTIFIER);
                $hold(posedge CLK, negedge D &&& xcheck2, tHDd, NOTIFIER);
                $recovery(posedge PRE, posedge CLK &&& check2, tRECpre, NOTIFIER);
                $width(posedge CLK &&& check1, tPWclk, 0, NOTIFIER);
                $width(negedge CLK &&& check1, tPWclk, 0, NOTIFIER);
                $hold(posedge CLK, posedge PRE &&& check2, tHDpre, NOTIFIER);
                $hold(posedge CLK, negedge PRE &&& check2, tHDpre, NOTIFIER);
                $width(negedge PRE, tPWpre, 0, NOTIFIER);
        endspecify
endmodule

module fdef3a3(Q, D, E, CLK, PRE);
        output Q;
        input  D, E, CLK, PRE;
        supply0 CLEAR;
        reg NOTIFIER;
        mux g1(DATA, E, D, Q);
        not g2(PRESET, PRE);
        buf g3(Q, QOUT);
        ff g4(QOUT, DATA, CLK, PRESET, CLEAR, NOTIFIER);
        // CONDITIONAL TIMING CHECK SIGNALS
        not g5(check1, PRESET);
        not g6(check2, DATA);
        // EXTERNAL TIMING CHECK SIGNALS
        xor     g7(sstz1, Q, D);
        xtc_and g8(xcheck1, check1, sstz1);
        xtc_and g10(xcheck2, check1, E);
        // SPECIFY BLOCK
        specify
                specparam tSUd = 0 ;
                specparam tHDd = 0 ;
                specparam tRECpre = 0 ;
                specparam tPWclk = 0 ;
                specparam tHDpre = 0 ;
                specparam tPWpre = 0 ;
                specparam CLK_01_LH_Q = 0, CLK_01_HL_Q = 0 ;
                specparam PRE_10_LH_Q = 0, PRE_10_HL_Q = 0 ;
                (posedge CLK *> (Q : 1'b1)) = (CLK_01_LH_Q, CLK_01_HL_Q) ;
                (negedge PRE *> (Q : 1'b1)) = (PRE_10_LH_Q, PRE_10_HL_Q) ;
                $setup(posedge E &&& xcheck1, posedge CLK, tSUd, NOTIFIER);
                $setup(negedge E &&& xcheck1, posedge CLK, tSUd, NOTIFIER);
                $setup(posedge D &&& xcheck2, posedge CLK, tSUd, NOTIFIER);
                $setup(negedge D &&& xcheck2, posedge CLK, tSUd, NOTIFIER);
                $hold(posedge CLK, posedge E &&& xcheck1, tHDd, NOTIFIER);
                $hold(posedge CLK, negedge E &&& xcheck1, tHDd, NOTIFIER);
                $hold(posedge CLK, posedge D &&& xcheck2, tHDd, NOTIFIER);
                $hold(posedge CLK, negedge D &&& xcheck2, tHDd, NOTIFIER);
                $recovery(posedge PRE, posedge CLK &&& check2, tRECpre, NOTIFIER);
                $width(posedge CLK &&& check1, tPWclk, 0, NOTIFIER);
                $width(negedge CLK &&& check1, tPWclk, 0, NOTIFIER);
                $hold(posedge CLK, posedge PRE &&& check2, tHDpre, NOTIFIER);
                $hold(posedge CLK, negedge PRE &&& check2, tHDpre, NOTIFIER);
                $width(negedge PRE, tPWpre, 0, NOTIFIER);
        endspecify
endmodule

module fdef3a6(Q, D, E, CLK, PRE);
        output Q;
        input  D, E, CLK, PRE;
        supply0 CLEAR;
        reg NOTIFIER;
        mux g1(DATA, E, D, Q);
        not g2(PRESET, PRE);
        buf g3(Q, QOUT);
        ff g4(QOUT, DATA, CLK, PRESET, CLEAR, NOTIFIER);
        // CONDITIONAL TIMING CHECK SIGNALS
        not g5(check1, PRESET);
        not g6(check2, DATA);
        // EXTERNAL TIMING CHECK SIGNALS
        xor     g7(sstz1, Q, D);
        xtc_and g8(xcheck1, check1, sstz1);
        xtc_and g10(xcheck2, check1, E);
        // SPECIFY BLOCK
        specify
                specparam tSUd = 0 ;
                specparam tHDd = 0 ;
                specparam tRECpre = 0 ;
                specparam tPWclk = 0 ;
                specparam tHDpre = 0 ;
                specparam tPWpre = 0 ;
                specparam CLK_01_LH_Q = 0, CLK_01_HL_Q = 0 ;
                specparam PRE_10_LH_Q = 0, PRE_10_HL_Q = 0 ;
                (posedge CLK *> (Q : 1'b1)) = (CLK_01_LH_Q, CLK_01_HL_Q) ;
                (negedge PRE *> (Q : 1'b1)) = (PRE_10_LH_Q, PRE_10_HL_Q) ;
                $setup(posedge E &&& xcheck1, posedge CLK, tSUd, NOTIFIER);
                $setup(negedge E &&& xcheck1, posedge CLK, tSUd, NOTIFIER);
                $setup(posedge D &&& xcheck2, posedge CLK, tSUd, NOTIFIER);
                $setup(negedge D &&& xcheck2, posedge CLK, tSUd, NOTIFIER);
                $hold(posedge CLK, posedge E &&& xcheck1, tHDd, NOTIFIER);
                $hold(posedge CLK, negedge E &&& xcheck1, tHDd, NOTIFIER);
                $hold(posedge CLK, posedge D &&& xcheck2, tHDd, NOTIFIER);
                $hold(posedge CLK, negedge D &&& xcheck2, tHDd, NOTIFIER);
                $recovery(posedge PRE, posedge CLK &&& check2, tRECpre, NOTIFIER);
                $width(posedge CLK &&& check1, tPWclk, 0, NOTIFIER);
                $width(negedge CLK &&& check1, tPWclk, 0, NOTIFIER);
                $hold(posedge CLK, posedge PRE &&& check2, tHDpre, NOTIFIER);
                $hold(posedge CLK, negedge PRE &&& check2, tHDpre, NOTIFIER);
                $width(negedge PRE, tPWpre, 0, NOTIFIER);
        endspecify
endmodule

module fdef3a9(Q, D, E, CLK, PRE);
        output Q;
        input  D, E, CLK, PRE;
        supply0 CLEAR;
        reg NOTIFIER;
        mux g1(DATA, E, D, Q);
        not g2(PRESET, PRE);
        buf g3(Q, QOUT);
        ff g4(QOUT, DATA, CLK, PRESET, CLEAR, NOTIFIER);
        // CONDITIONAL TIMING CHECK SIGNALS
        not g5(check1, PRESET);
        not g6(check2, DATA);
        // EXTERNAL TIMING CHECK SIGNALS
        xor     g7(sstz1, Q, D);
        xtc_and g8(xcheck1, check1, sstz1);
        xtc_and g10(xcheck2, check1, E);
        // SPECIFY BLOCK
        specify
                specparam tSUd = 0 ;
                specparam tHDd = 0 ;
                specparam tRECpre = 0 ;
                specparam tPWclk = 0 ;
                specparam tHDpre = 0 ;
                specparam tPWpre = 0 ;
                specparam CLK_01_LH_Q = 0, CLK_01_HL_Q = 0 ;
                specparam PRE_10_LH_Q = 0, PRE_10_HL_Q = 0 ;
                (posedge CLK *> (Q : 1'b1)) = (CLK_01_LH_Q, CLK_01_HL_Q) ;
                (negedge PRE *> (Q : 1'b1)) = (PRE_10_LH_Q, PRE_10_HL_Q) ;
                $setup(posedge E &&& xcheck1, posedge CLK, tSUd, NOTIFIER);
                $setup(negedge E &&& xcheck1, posedge CLK, tSUd, NOTIFIER);
                $setup(posedge D &&& xcheck2, posedge CLK, tSUd, NOTIFIER);
                $setup(negedge D &&& xcheck2, posedge CLK, tSUd, NOTIFIER);
                $hold(posedge CLK, posedge E &&& xcheck1, tHDd, NOTIFIER);
                $hold(posedge CLK, negedge E &&& xcheck1, tHDd, NOTIFIER);
                $hold(posedge CLK, posedge D &&& xcheck2, tHDd, NOTIFIER);
                $hold(posedge CLK, negedge D &&& xcheck2, tHDd, NOTIFIER);
                $recovery(posedge PRE, posedge CLK &&& check2, tRECpre, NOTIFIER);
                $width(posedge CLK &&& check1, tPWclk, 0, NOTIFIER);
                $width(negedge CLK &&& check1, tPWclk, 0, NOTIFIER);
                $hold(posedge CLK, posedge PRE &&& check2, tHDpre, NOTIFIER);
                $hold(posedge CLK, negedge PRE &&& check2, tHDpre, NOTIFIER);
                $width(negedge PRE, tPWpre, 0, NOTIFIER);
        endspecify
endmodule

module fdesf1a1(Q, D0, D1, S, E, CLK);
        output Q;
        input  D0, D1, S, E, CLK;
        supply0 PRESET, CLEAR;
        reg NOTIFIER;
        mux g1(N1, E, D0, Q);
        mux g2(DATA, S, D1, N1);
        buf g3(Q, QOUT);
        ff g4(QOUT, DATA, CLK, PRESET, CLEAR, NOTIFIER);
        // EXTERNAL TIMING CHECK SIGNALS
        xtc_xor g5_2(xcheck1, D1, N1);
        xtc_buf g7(xcheck2, S);
        xor     g9_1(g9_1_out, D0, Q);
        not     g9_2(g9_2_out, S);
        xtc_and g9_3(xcheck3, g9_1_out, g9_2_out);
        not     g11_1(g11_1_out, S);
        xtc_and g11_2(xcheck4, E, g11_1_out);
        // SPECIFY BLOCK
        specify
                specparam tSUd = 0 ;
                specparam tHDd = 0 ;
                specparam tPWclk = 0 ;
                specparam CLK_01_LH_Q = 0, CLK_01_HL_Q = 0 ;
                (posedge CLK *> (Q : 1'b1)) = (CLK_01_LH_Q, CLK_01_HL_Q) ;
                $setup(posedge S &&& xcheck1, posedge CLK, tSUd, NOTIFIER);
                $setup(negedge S &&& xcheck1, posedge CLK, tSUd, NOTIFIER);
                $setup(posedge D1 &&& xcheck2, posedge CLK, tSUd, NOTIFIER);
                $setup(negedge D1 &&& xcheck2, posedge CLK, tSUd, NOTIFIER);
                $setup(posedge E &&& xcheck3, posedge CLK, tSUd, NOTIFIER);
                $setup(negedge E &&& xcheck3, posedge CLK, tSUd, NOTIFIER);
                $setup(posedge D0 &&& xcheck4, posedge CLK, tSUd, NOTIFIER);
                $setup(negedge D0 &&& xcheck4, posedge CLK, tSUd, NOTIFIER);
                $hold(posedge CLK, posedge S &&& xcheck1, tHDd, NOTIFIER);
                $hold(posedge CLK, negedge S &&& xcheck1, tHDd, NOTIFIER);
                $hold(posedge CLK, posedge D1 &&& xcheck2, tHDd, NOTIFIER);
                $hold(posedge CLK, negedge D1 &&& xcheck2, tHDd, NOTIFIER);
                $hold(posedge CLK, posedge E &&& xcheck3, tHDd, NOTIFIER);
                $hold(posedge CLK, negedge E &&& xcheck3, tHDd, NOTIFIER);
                $hold(posedge CLK, posedge D0 &&& xcheck4, tHDd, NOTIFIER);
                $hold(posedge CLK, negedge D0 &&& xcheck4, tHDd, NOTIFIER);
                $width(posedge CLK, tPWclk, 0, NOTIFIER);
                $width(negedge CLK, tPWclk, 0, NOTIFIER);
        endspecify
endmodule

module fdesf1a15(Q, D0, D1, S, E, CLK);
        output Q;
        input  D0, D1, S, E, CLK;
        supply0 PRESET, CLEAR;
        reg NOTIFIER;
        mux g1(N1, E, D0, Q);
        mux g2(DATA, S, D1, N1);
        buf g3(Q, QOUT);
        ff g4(QOUT, DATA, CLK, PRESET, CLEAR, NOTIFIER);
        // EXTERNAL TIMING CHECK SIGNALS
        xtc_xor g5_2(xcheck1, D1, N1);
        xtc_buf g7(xcheck2, S);
        xor     g9_1(g9_1_out, D0, Q);
        not     g9_2(g9_2_out, S);
        xtc_and g9_3(xcheck3, g9_1_out, g9_2_out);
        not     g11_1(g11_1_out, S);
        xtc_and g11_2(xcheck4, E, g11_1_out);
        // SPECIFY BLOCK
        specify
                specparam tSUd = 0 ;
                specparam tHDd = 0 ;
                specparam tPWclk = 0 ;
                specparam CLK_01_LH_Q = 0, CLK_01_HL_Q = 0 ;
                (posedge CLK *> (Q : 1'b1)) = (CLK_01_LH_Q, CLK_01_HL_Q) ;
                $setup(posedge S &&& xcheck1, posedge CLK, tSUd, NOTIFIER);
                $setup(negedge S &&& xcheck1, posedge CLK, tSUd, NOTIFIER);
                $setup(posedge D1 &&& xcheck2, posedge CLK, tSUd, NOTIFIER);
                $setup(negedge D1 &&& xcheck2, posedge CLK, tSUd, NOTIFIER);
                $setup(posedge E &&& xcheck3, posedge CLK, tSUd, NOTIFIER);
                $setup(negedge E &&& xcheck3, posedge CLK, tSUd, NOTIFIER);
                $setup(posedge D0 &&& xcheck4, posedge CLK, tSUd, NOTIFIER);
                $setup(negedge D0 &&& xcheck4, posedge CLK, tSUd, NOTIFIER);
                $hold(posedge CLK, posedge S &&& xcheck1, tHDd, NOTIFIER);
                $hold(posedge CLK, negedge S &&& xcheck1, tHDd, NOTIFIER);
                $hold(posedge CLK, posedge D1 &&& xcheck2, tHDd, NOTIFIER);
                $hold(posedge CLK, negedge D1 &&& xcheck2, tHDd, NOTIFIER);
                $hold(posedge CLK, posedge E &&& xcheck3, tHDd, NOTIFIER);
                $hold(posedge CLK, negedge E &&& xcheck3, tHDd, NOTIFIER);
                $hold(posedge CLK, posedge D0 &&& xcheck4, tHDd, NOTIFIER);
                $hold(posedge CLK, negedge D0 &&& xcheck4, tHDd, NOTIFIER);
                $width(posedge CLK, tPWclk, 0, NOTIFIER);
                $width(negedge CLK, tPWclk, 0, NOTIFIER);
        endspecify
endmodule

module fdesf1a2(Q, D0, D1, S, E, CLK);
        output Q;
        input  D0, D1, S, E, CLK;
        supply0 PRESET, CLEAR;
        reg NOTIFIER;
        mux g1(N1, E, D0, Q);
        mux g2(DATA, S, D1, N1);
        buf g3(Q, QOUT);
        ff g4(QOUT, DATA, CLK, PRESET, CLEAR, NOTIFIER);
        // EXTERNAL TIMING CHECK SIGNALS
        xtc_xor g5_2(xcheck1, D1, N1);
        xtc_buf g7(xcheck2, S);
        xor     g9_1(g9_1_out, D0, Q);
        not     g9_2(g9_2_out, S);
        xtc_and g9_3(xcheck3, g9_1_out, g9_2_out);
        not     g11_1(g11_1_out, S);
        xtc_and g11_2(xcheck4, E, g11_1_out);
        // SPECIFY BLOCK
        specify
                specparam tSUd = 0 ;
                specparam tHDd = 0 ;
                specparam tPWclk = 0 ;
                specparam CLK_01_LH_Q = 0, CLK_01_HL_Q = 0 ;
                (posedge CLK *> (Q : 1'b1)) = (CLK_01_LH_Q, CLK_01_HL_Q) ;
                $setup(posedge S &&& xcheck1, posedge CLK, tSUd, NOTIFIER);
                $setup(negedge S &&& xcheck1, posedge CLK, tSUd, NOTIFIER);
                $setup(posedge D1 &&& xcheck2, posedge CLK, tSUd, NOTIFIER);
                $setup(negedge D1 &&& xcheck2, posedge CLK, tSUd, NOTIFIER);
                $setup(posedge E &&& xcheck3, posedge CLK, tSUd, NOTIFIER);
                $setup(negedge E &&& xcheck3, posedge CLK, tSUd, NOTIFIER);
                $setup(posedge D0 &&& xcheck4, posedge CLK, tSUd, NOTIFIER);
                $setup(negedge D0 &&& xcheck4, posedge CLK, tSUd, NOTIFIER);
                $hold(posedge CLK, posedge S &&& xcheck1, tHDd, NOTIFIER);
                $hold(posedge CLK, negedge S &&& xcheck1, tHDd, NOTIFIER);
                $hold(posedge CLK, posedge D1 &&& xcheck2, tHDd, NOTIFIER);
                $hold(posedge CLK, negedge D1 &&& xcheck2, tHDd, NOTIFIER);
                $hold(posedge CLK, posedge E &&& xcheck3, tHDd, NOTIFIER);
                $hold(posedge CLK, negedge E &&& xcheck3, tHDd, NOTIFIER);
                $hold(posedge CLK, posedge D0 &&& xcheck4, tHDd, NOTIFIER);
                $hold(posedge CLK, negedge D0 &&& xcheck4, tHDd, NOTIFIER);
                $width(posedge CLK, tPWclk, 0, NOTIFIER);
                $width(negedge CLK, tPWclk, 0, NOTIFIER);
        endspecify
endmodule

module fdesf1a3(Q, D0, D1, S, E, CLK);
        output Q;
        input  D0, D1, S, E, CLK;
        supply0 PRESET, CLEAR;
        reg NOTIFIER;
        mux g1(N1, E, D0, Q);
        mux g2(DATA, S, D1, N1);
        buf g3(Q, QOUT);
        ff g4(QOUT, DATA, CLK, PRESET, CLEAR, NOTIFIER);
        // EXTERNAL TIMING CHECK SIGNALS
        xtc_xor g5_2(xcheck1, D1, N1);
        xtc_buf g7(xcheck2, S);
        xor     g9_1(g9_1_out, D0, Q);
        not     g9_2(g9_2_out, S);
        xtc_and g9_3(xcheck3, g9_1_out, g9_2_out);
        not     g11_1(g11_1_out, S);
        xtc_and g11_2(xcheck4, E, g11_1_out);
        // SPECIFY BLOCK
        specify
                specparam tSUd = 0 ;
                specparam tHDd = 0 ;
                specparam tPWclk = 0 ;
                specparam CLK_01_LH_Q = 0, CLK_01_HL_Q = 0 ;
                (posedge CLK *> (Q : 1'b1)) = (CLK_01_LH_Q, CLK_01_HL_Q) ;
                $setup(posedge S &&& xcheck1, posedge CLK, tSUd, NOTIFIER);
                $setup(negedge S &&& xcheck1, posedge CLK, tSUd, NOTIFIER);
                $setup(posedge D1 &&& xcheck2, posedge CLK, tSUd, NOTIFIER);
                $setup(negedge D1 &&& xcheck2, posedge CLK, tSUd, NOTIFIER);
                $setup(posedge E &&& xcheck3, posedge CLK, tSUd, NOTIFIER);
                $setup(negedge E &&& xcheck3, posedge CLK, tSUd, NOTIFIER);
                $setup(posedge D0 &&& xcheck4, posedge CLK, tSUd, NOTIFIER);
                $setup(negedge D0 &&& xcheck4, posedge CLK, tSUd, NOTIFIER);
                $hold(posedge CLK, posedge S &&& xcheck1, tHDd, NOTIFIER);
                $hold(posedge CLK, negedge S &&& xcheck1, tHDd, NOTIFIER);
                $hold(posedge CLK, posedge D1 &&& xcheck2, tHDd, NOTIFIER);
                $hold(posedge CLK, negedge D1 &&& xcheck2, tHDd, NOTIFIER);
                $hold(posedge CLK, posedge E &&& xcheck3, tHDd, NOTIFIER);
                $hold(posedge CLK, negedge E &&& xcheck3, tHDd, NOTIFIER);
                $hold(posedge CLK, posedge D0 &&& xcheck4, tHDd, NOTIFIER);
                $hold(posedge CLK, negedge D0 &&& xcheck4, tHDd, NOTIFIER);
                $width(posedge CLK, tPWclk, 0, NOTIFIER);
                $width(negedge CLK, tPWclk, 0, NOTIFIER);
        endspecify
endmodule

module fdesf1a6(Q, D0, D1, S, E, CLK);
        output Q;
        input  D0, D1, S, E, CLK;
        supply0 PRESET, CLEAR;
        reg NOTIFIER;
        mux g1(N1, E, D0, Q);
        mux g2(DATA, S, D1, N1);
        buf g3(Q, QOUT);
        ff g4(QOUT, DATA, CLK, PRESET, CLEAR, NOTIFIER);
        // EXTERNAL TIMING CHECK SIGNALS
        xtc_xor g5_2(xcheck1, D1, N1);
        xtc_buf g7(xcheck2, S);
        xor     g9_1(g9_1_out, D0, Q);
        not     g9_2(g9_2_out, S);
        xtc_and g9_3(xcheck3, g9_1_out, g9_2_out);
        not     g11_1(g11_1_out, S);
        xtc_and g11_2(xcheck4, E, g11_1_out);
        // SPECIFY BLOCK
        specify
                specparam tSUd = 0 ;
                specparam tHDd = 0 ;
                specparam tPWclk = 0 ;
                specparam CLK_01_LH_Q = 0, CLK_01_HL_Q = 0 ;
                (posedge CLK *> (Q : 1'b1)) = (CLK_01_LH_Q, CLK_01_HL_Q) ;
                $setup(posedge S &&& xcheck1, posedge CLK, tSUd, NOTIFIER);
                $setup(negedge S &&& xcheck1, posedge CLK, tSUd, NOTIFIER);
                $setup(posedge D1 &&& xcheck2, posedge CLK, tSUd, NOTIFIER);
                $setup(negedge D1 &&& xcheck2, posedge CLK, tSUd, NOTIFIER);
                $setup(posedge E &&& xcheck3, posedge CLK, tSUd, NOTIFIER);
                $setup(negedge E &&& xcheck3, posedge CLK, tSUd, NOTIFIER);
                $setup(posedge D0 &&& xcheck4, posedge CLK, tSUd, NOTIFIER);
                $setup(negedge D0 &&& xcheck4, posedge CLK, tSUd, NOTIFIER);
                $hold(posedge CLK, posedge S &&& xcheck1, tHDd, NOTIFIER);
                $hold(posedge CLK, negedge S &&& xcheck1, tHDd, NOTIFIER);
                $hold(posedge CLK, posedge D1 &&& xcheck2, tHDd, NOTIFIER);
                $hold(posedge CLK, negedge D1 &&& xcheck2, tHDd, NOTIFIER);
                $hold(posedge CLK, posedge E &&& xcheck3, tHDd, NOTIFIER);
                $hold(posedge CLK, negedge E &&& xcheck3, tHDd, NOTIFIER);
                $hold(posedge CLK, posedge D0 &&& xcheck4, tHDd, NOTIFIER);
                $hold(posedge CLK, negedge D0 &&& xcheck4, tHDd, NOTIFIER);
                $width(posedge CLK, tPWclk, 0, NOTIFIER);
                $width(negedge CLK, tPWclk, 0, NOTIFIER);
        endspecify
endmodule

module fdesf1a9(Q, D0, D1, S, E, CLK);
        output Q;
        input  D0, D1, S, E, CLK;
        supply0 PRESET, CLEAR;
        reg NOTIFIER;
        mux g1(N1, E, D0, Q);
        mux g2(DATA, S, D1, N1);
        buf g3(Q, QOUT);
        ff g4(QOUT, DATA, CLK, PRESET, CLEAR, NOTIFIER);
        // EXTERNAL TIMING CHECK SIGNALS
        xtc_xor g5_2(xcheck1, D1, N1);
        xtc_buf g7(xcheck2, S);
        xor     g9_1(g9_1_out, D0, Q);
        not     g9_2(g9_2_out, S);
        xtc_and g9_3(xcheck3, g9_1_out, g9_2_out);
        not     g11_1(g11_1_out, S);
        xtc_and g11_2(xcheck4, E, g11_1_out);
        // SPECIFY BLOCK
        specify
                specparam tSUd = 0 ;
                specparam tHDd = 0 ;
                specparam tPWclk = 0 ;
                specparam CLK_01_LH_Q = 0, CLK_01_HL_Q = 0 ;
                (posedge CLK *> (Q : 1'b1)) = (CLK_01_LH_Q, CLK_01_HL_Q) ;
                $setup(posedge S &&& xcheck1, posedge CLK, tSUd, NOTIFIER);
                $setup(negedge S &&& xcheck1, posedge CLK, tSUd, NOTIFIER);
                $setup(posedge D1 &&& xcheck2, posedge CLK, tSUd, NOTIFIER);
                $setup(negedge D1 &&& xcheck2, posedge CLK, tSUd, NOTIFIER);
                $setup(posedge E &&& xcheck3, posedge CLK, tSUd, NOTIFIER);
                $setup(negedge E &&& xcheck3, posedge CLK, tSUd, NOTIFIER);
                $setup(posedge D0 &&& xcheck4, posedge CLK, tSUd, NOTIFIER);
                $setup(negedge D0 &&& xcheck4, posedge CLK, tSUd, NOTIFIER);
                $hold(posedge CLK, posedge S &&& xcheck1, tHDd, NOTIFIER);
                $hold(posedge CLK, negedge S &&& xcheck1, tHDd, NOTIFIER);
                $hold(posedge CLK, posedge D1 &&& xcheck2, tHDd, NOTIFIER);
                $hold(posedge CLK, negedge D1 &&& xcheck2, tHDd, NOTIFIER);
                $hold(posedge CLK, posedge E &&& xcheck3, tHDd, NOTIFIER);
                $hold(posedge CLK, negedge E &&& xcheck3, tHDd, NOTIFIER);
                $hold(posedge CLK, posedge D0 &&& xcheck4, tHDd, NOTIFIER);
                $hold(posedge CLK, negedge D0 &&& xcheck4, tHDd, NOTIFIER);
                $width(posedge CLK, tPWclk, 0, NOTIFIER);
                $width(negedge CLK, tPWclk, 0, NOTIFIER);
        endspecify
endmodule

module fdesf2a1(Q, D0, D1, S, E, CLK, CLR);
        output Q;
        input  D0, D1, S, E, CLK, CLR;
        supply0 PRESET;
        reg NOTIFIER;
        mux g1(N1, E, D0, Q);
        mux g2(DATA, S, D1, N1);
        not g3(CLEAR, CLR);
        buf g4(Q, QOUT);
        ff g5(QOUT, DATA, CLK, PRESET, CLEAR, NOTIFIER);
        // CONDITIONAL TIMING CHECK SIGNALS
        not g6(check1, CLEAR);
        buf g7(check2, DATA);
        // EXTERNAL TIMING CHECK SIGNALS
        xor     g8_2(sstz1, D1, N1);
        xtc_and g9(xcheck1, check1, sstz1);
        xtc_and g11(xcheck2, check1, S);
        xor     g12_1(g12_1_out, D0, Q);
        not     g12_2(g12_2_out, S);
        and     g12_3(sstz3, g12_1_out, g12_2_out);
        xtc_and g13(xcheck3, check1, sstz3);
        not     g14_1(g14_1_out, S);
        and     g14_2(sstz4, E, g14_1_out);
        xtc_and g15(xcheck4, sstz4, check1);
        // SPECIFY BLOCK
        specify
                specparam tSUd = 0 ;
                specparam tHDd = 0 ;
                specparam tRECclr = 0 ;
                specparam tPWclk = 0 ;
                specparam tHDclr = 0 ;
                specparam tPWclr = 0 ;
                specparam CLK_01_LH_Q = 0, CLK_01_HL_Q = 0 ;
                specparam CLR_10_LH_Q = 0, CLR_10_HL_Q = 0 ;
                (posedge CLK *> (Q : 1'b1)) = (CLK_01_LH_Q, CLK_01_HL_Q) ;
                (negedge CLR *> (Q : 1'b1)) = (CLR_10_LH_Q, CLR_10_HL_Q) ;
                $setup(posedge S &&& xcheck1, posedge CLK, tSUd, NOTIFIER);
                $setup(negedge S &&& xcheck1, posedge CLK, tSUd, NOTIFIER);
                $setup(posedge D1 &&& xcheck2, posedge CLK, tSUd, NOTIFIER);
                $setup(negedge D1 &&& xcheck2, posedge CLK, tSUd, NOTIFIER);
                $setup(posedge E &&& xcheck3, posedge CLK, tSUd, NOTIFIER);
                $setup(negedge E &&& xcheck3, posedge CLK, tSUd, NOTIFIER);
                $setup(posedge D0 &&& xcheck4, posedge CLK, tSUd, NOTIFIER);
                $setup(negedge D0 &&& xcheck4, posedge CLK, tSUd, NOTIFIER);
                $hold(posedge CLK, posedge S &&& xcheck1, tHDd, NOTIFIER);
                $hold(posedge CLK, negedge S &&& xcheck1, tHDd, NOTIFIER);
                $hold(posedge CLK, posedge D1 &&& xcheck2, tHDd, NOTIFIER);
                $hold(posedge CLK, negedge D1 &&& xcheck2, tHDd, NOTIFIER);
                $hold(posedge CLK, posedge E &&& xcheck3, tHDd, NOTIFIER);
                $hold(posedge CLK, negedge E &&& xcheck3, tHDd, NOTIFIER);
                $hold(posedge CLK, posedge D0 &&& xcheck4, tHDd, NOTIFIER);
                $hold(posedge CLK, negedge D0 &&& xcheck4, tHDd, NOTIFIER);
                $recovery(posedge CLR, posedge CLK &&& check2, tRECclr, NOTIFIER);
                $width(posedge CLK &&& check1, tPWclk, 0, NOTIFIER);
                $width(negedge CLK &&& check1, tPWclk, 0, NOTIFIER);
                $hold(posedge CLK, posedge CLR &&& check2, tHDclr, NOTIFIER);
                $hold(posedge CLK, negedge CLR &&& check2, tHDclr, NOTIFIER);
                $width(negedge CLR, tPWclr, 0, NOTIFIER);
        endspecify
endmodule

module fdesf2a15(Q, D0, D1, S, E, CLK, CLR);
        output Q;
        input  D0, D1, S, E, CLK, CLR;
        supply0 PRESET;
        reg NOTIFIER;
        mux g1(N1, E, D0, Q);
        mux g2(DATA, S, D1, N1);
        not g3(CLEAR, CLR);
        buf g4(Q, QOUT);
        ff g5(QOUT, DATA, CLK, PRESET, CLEAR, NOTIFIER);
        // CONDITIONAL TIMING CHECK SIGNALS
        not g6(check1, CLEAR);
        buf g7(check2, DATA);
        // EXTERNAL TIMING CHECK SIGNALS
        xor     g8_2(sstz1, D1, N1);
        xtc_and g9(xcheck1, check1, sstz1);
        xtc_and g11(xcheck2, check1, S);
        xor     g12_1(g12_1_out, D0, Q);
        not     g12_2(g12_2_out, S);
        and     g12_3(sstz3, g12_1_out, g12_2_out);
        xtc_and g13(xcheck3, check1, sstz3);
        not     g14_1(g14_1_out, S);
        and     g14_2(sstz4, E, g14_1_out);
        xtc_and g15(xcheck4, sstz4, check1);
        // SPECIFY BLOCK
        specify
                specparam tSUd = 0 ;
                specparam tHDd = 0 ;
                specparam tRECclr = 0 ;
                specparam tPWclk = 0 ;
                specparam tHDclr = 0 ;
                specparam tPWclr = 0 ;
                specparam CLK_01_LH_Q = 0, CLK_01_HL_Q = 0 ;
                specparam CLR_10_LH_Q = 0, CLR_10_HL_Q = 0 ;
                (posedge CLK *> (Q : 1'b1)) = (CLK_01_LH_Q, CLK_01_HL_Q) ;
                (negedge CLR *> (Q : 1'b1)) = (CLR_10_LH_Q, CLR_10_HL_Q) ;
                $setup(posedge S &&& xcheck1, posedge CLK, tSUd, NOTIFIER);
                $setup(negedge S &&& xcheck1, posedge CLK, tSUd, NOTIFIER);
                $setup(posedge D1 &&& xcheck2, posedge CLK, tSUd, NOTIFIER);
                $setup(negedge D1 &&& xcheck2, posedge CLK, tSUd, NOTIFIER);
                $setup(posedge E &&& xcheck3, posedge CLK, tSUd, NOTIFIER);
                $setup(negedge E &&& xcheck3, posedge CLK, tSUd, NOTIFIER);
                $setup(posedge D0 &&& xcheck4, posedge CLK, tSUd, NOTIFIER);
                $setup(negedge D0 &&& xcheck4, posedge CLK, tSUd, NOTIFIER);
                $hold(posedge CLK, posedge S &&& xcheck1, tHDd, NOTIFIER);
                $hold(posedge CLK, negedge S &&& xcheck1, tHDd, NOTIFIER);
                $hold(posedge CLK, posedge D1 &&& xcheck2, tHDd, NOTIFIER);
                $hold(posedge CLK, negedge D1 &&& xcheck2, tHDd, NOTIFIER);
                $hold(posedge CLK, posedge E &&& xcheck3, tHDd, NOTIFIER);
                $hold(posedge CLK, negedge E &&& xcheck3, tHDd, NOTIFIER);
                $hold(posedge CLK, posedge D0 &&& xcheck4, tHDd, NOTIFIER);
                $hold(posedge CLK, negedge D0 &&& xcheck4, tHDd, NOTIFIER);
                $recovery(posedge CLR, posedge CLK &&& check2, tRECclr, NOTIFIER);
                $width(posedge CLK &&& check1, tPWclk, 0, NOTIFIER);
                $width(negedge CLK &&& check1, tPWclk, 0, NOTIFIER);
                $hold(posedge CLK, posedge CLR &&& check2, tHDclr, NOTIFIER);
                $hold(posedge CLK, negedge CLR &&& check2, tHDclr, NOTIFIER);
                $width(negedge CLR, tPWclr, 0, NOTIFIER);
        endspecify
endmodule

module fdesf2a2(Q, D0, D1, S, E, CLK, CLR);
        output Q;
        input  D0, D1, S, E, CLK, CLR;
        supply0 PRESET;
        reg NOTIFIER;
        mux g1(N1, E, D0, Q);
        mux g2(DATA, S, D1, N1);
        not g3(CLEAR, CLR);
        buf g4(Q, QOUT);
        ff g5(QOUT, DATA, CLK, PRESET, CLEAR, NOTIFIER);
        // CONDITIONAL TIMING CHECK SIGNALS
        not g6(check1, CLEAR);
        buf g7(check2, DATA);
        // EXTERNAL TIMING CHECK SIGNALS
        xor     g8_2(sstz1, D1, N1);
        xtc_and g9(xcheck1, check1, sstz1);
        xtc_and g11(xcheck2, check1, S);
        xor     g12_1(g12_1_out, D0, Q);
        not     g12_2(g12_2_out, S);
        and     g12_3(sstz3, g12_1_out, g12_2_out);
        xtc_and g13(xcheck3, check1, sstz3);
        not     g14_1(g14_1_out, S);
        and     g14_2(sstz4, E, g14_1_out);
        xtc_and g15(xcheck4, sstz4, check1);
        // SPECIFY BLOCK
        specify
                specparam tSUd = 0 ;
                specparam tHDd = 0 ;
                specparam tRECclr = 0 ;
                specparam tPWclk = 0 ;
                specparam tHDclr = 0 ;
                specparam tPWclr = 0 ;
                specparam CLK_01_LH_Q = 0, CLK_01_HL_Q = 0 ;
                specparam CLR_10_LH_Q = 0, CLR_10_HL_Q = 0 ;
                (posedge CLK *> (Q : 1'b1)) = (CLK_01_LH_Q, CLK_01_HL_Q) ;
                (negedge CLR *> (Q : 1'b1)) = (CLR_10_LH_Q, CLR_10_HL_Q) ;
                $setup(posedge S &&& xcheck1, posedge CLK, tSUd, NOTIFIER);
                $setup(negedge S &&& xcheck1, posedge CLK, tSUd, NOTIFIER);
                $setup(posedge D1 &&& xcheck2, posedge CLK, tSUd, NOTIFIER);
                $setup(negedge D1 &&& xcheck2, posedge CLK, tSUd, NOTIFIER);
                $setup(posedge E &&& xcheck3, posedge CLK, tSUd, NOTIFIER);
                $setup(negedge E &&& xcheck3, posedge CLK, tSUd, NOTIFIER);
                $setup(posedge D0 &&& xcheck4, posedge CLK, tSUd, NOTIFIER);
                $setup(negedge D0 &&& xcheck4, posedge CLK, tSUd, NOTIFIER);
                $hold(posedge CLK, posedge S &&& xcheck1, tHDd, NOTIFIER);
                $hold(posedge CLK, negedge S &&& xcheck1, tHDd, NOTIFIER);
                $hold(posedge CLK, posedge D1 &&& xcheck2, tHDd, NOTIFIER);
                $hold(posedge CLK, negedge D1 &&& xcheck2, tHDd, NOTIFIER);
                $hold(posedge CLK, posedge E &&& xcheck3, tHDd, NOTIFIER);
                $hold(posedge CLK, negedge E &&& xcheck3, tHDd, NOTIFIER);
                $hold(posedge CLK, posedge D0 &&& xcheck4, tHDd, NOTIFIER);
                $hold(posedge CLK, negedge D0 &&& xcheck4, tHDd, NOTIFIER);
                $recovery(posedge CLR, posedge CLK &&& check2, tRECclr, NOTIFIER);
                $width(posedge CLK &&& check1, tPWclk, 0, NOTIFIER);
                $width(negedge CLK &&& check1, tPWclk, 0, NOTIFIER);
                $hold(posedge CLK, posedge CLR &&& check2, tHDclr, NOTIFIER);
                $hold(posedge CLK, negedge CLR &&& check2, tHDclr, NOTIFIER);
                $width(negedge CLR, tPWclr, 0, NOTIFIER);
        endspecify
endmodule

module fdesf2a3(Q, D0, D1, S, E, CLK, CLR);
        output Q;
        input  D0, D1, S, E, CLK, CLR;
        supply0 PRESET;
        reg NOTIFIER;
        mux g1(N1, E, D0, Q);
        mux g2(DATA, S, D1, N1);
        not g3(CLEAR, CLR);
        buf g4(Q, QOUT);
        ff g5(QOUT, DATA, CLK, PRESET, CLEAR, NOTIFIER);
        // CONDITIONAL TIMING CHECK SIGNALS
        not g6(check1, CLEAR);
        buf g7(check2, DATA);
        // EXTERNAL TIMING CHECK SIGNALS
        xor     g8_2(sstz1, D1, N1);
        xtc_and g9(xcheck1, check1, sstz1);
        xtc_and g11(xcheck2, check1, S);
        xor     g12_1(g12_1_out, D0, Q);
        not     g12_2(g12_2_out, S);
        and     g12_3(sstz3, g12_1_out, g12_2_out);
        xtc_and g13(xcheck3, check1, sstz3);
        not     g14_1(g14_1_out, S);
        and     g14_2(sstz4, E, g14_1_out);
        xtc_and g15(xcheck4, sstz4, check1);
        // SPECIFY BLOCK
        specify
                specparam tSUd = 0 ;
                specparam tHDd = 0 ;
                specparam tRECclr = 0 ;
                specparam tPWclk = 0 ;
                specparam tHDclr = 0 ;
                specparam tPWclr = 0 ;
                specparam CLK_01_LH_Q = 0, CLK_01_HL_Q = 0 ;
                specparam CLR_10_LH_Q = 0, CLR_10_HL_Q = 0 ;
                (posedge CLK *> (Q : 1'b1)) = (CLK_01_LH_Q, CLK_01_HL_Q) ;
                (negedge CLR *> (Q : 1'b1)) = (CLR_10_LH_Q, CLR_10_HL_Q) ;
                $setup(posedge S &&& xcheck1, posedge CLK, tSUd, NOTIFIER);
                $setup(negedge S &&& xcheck1, posedge CLK, tSUd, NOTIFIER);
                $setup(posedge D1 &&& xcheck2, posedge CLK, tSUd, NOTIFIER);
                $setup(negedge D1 &&& xcheck2, posedge CLK, tSUd, NOTIFIER);
                $setup(posedge E &&& xcheck3, posedge CLK, tSUd, NOTIFIER);
                $setup(negedge E &&& xcheck3, posedge CLK, tSUd, NOTIFIER);
                $setup(posedge D0 &&& xcheck4, posedge CLK, tSUd, NOTIFIER);
                $setup(negedge D0 &&& xcheck4, posedge CLK, tSUd, NOTIFIER);
                $hold(posedge CLK, posedge S &&& xcheck1, tHDd, NOTIFIER);
                $hold(posedge CLK, negedge S &&& xcheck1, tHDd, NOTIFIER);
                $hold(posedge CLK, posedge D1 &&& xcheck2, tHDd, NOTIFIER);
                $hold(posedge CLK, negedge D1 &&& xcheck2, tHDd, NOTIFIER);
                $hold(posedge CLK, posedge E &&& xcheck3, tHDd, NOTIFIER);
                $hold(posedge CLK, negedge E &&& xcheck3, tHDd, NOTIFIER);
                $hold(posedge CLK, posedge D0 &&& xcheck4, tHDd, NOTIFIER);
                $hold(posedge CLK, negedge D0 &&& xcheck4, tHDd, NOTIFIER);
                $recovery(posedge CLR, posedge CLK &&& check2, tRECclr, NOTIFIER);
                $width(posedge CLK &&& check1, tPWclk, 0, NOTIFIER);
                $width(negedge CLK &&& check1, tPWclk, 0, NOTIFIER);
                $hold(posedge CLK, posedge CLR &&& check2, tHDclr, NOTIFIER);
                $hold(posedge CLK, negedge CLR &&& check2, tHDclr, NOTIFIER);
                $width(negedge CLR, tPWclr, 0, NOTIFIER);
        endspecify
endmodule

module fdesf2a6(Q, D0, D1, S, E, CLK, CLR);
        output Q;
        input  D0, D1, S, E, CLK, CLR;
        supply0 PRESET;
        reg NOTIFIER;
        mux g1(N1, E, D0, Q);
        mux g2(DATA, S, D1, N1);
        not g3(CLEAR, CLR);
        buf g4(Q, QOUT);
        ff g5(QOUT, DATA, CLK, PRESET, CLEAR, NOTIFIER);
        // CONDITIONAL TIMING CHECK SIGNALS
        not g6(check1, CLEAR);
        buf g7(check2, DATA);
        // EXTERNAL TIMING CHECK SIGNALS
        xor     g8_2(sstz1, D1, N1);
        xtc_and g9(xcheck1, check1, sstz1);
        xtc_and g11(xcheck2, check1, S);
        xor     g12_1(g12_1_out, D0, Q);
        not     g12_2(g12_2_out, S);
        and     g12_3(sstz3, g12_1_out, g12_2_out);
        xtc_and g13(xcheck3, check1, sstz3);
        not     g14_1(g14_1_out, S);
        and     g14_2(sstz4, E, g14_1_out);
        xtc_and g15(xcheck4, sstz4, check1);
        // SPECIFY BLOCK
        specify
                specparam tSUd = 0 ;
                specparam tHDd = 0 ;
                specparam tRECclr = 0 ;
                specparam tPWclk = 0 ;
                specparam tHDclr = 0 ;
                specparam tPWclr = 0 ;
                specparam CLK_01_LH_Q = 0, CLK_01_HL_Q = 0 ;
                specparam CLR_10_LH_Q = 0, CLR_10_HL_Q = 0 ;
                (posedge CLK *> (Q : 1'b1)) = (CLK_01_LH_Q, CLK_01_HL_Q) ;
                (negedge CLR *> (Q : 1'b1)) = (CLR_10_LH_Q, CLR_10_HL_Q) ;
                $setup(posedge S &&& xcheck1, posedge CLK, tSUd, NOTIFIER);
                $setup(negedge S &&& xcheck1, posedge CLK, tSUd, NOTIFIER);
                $setup(posedge D1 &&& xcheck2, posedge CLK, tSUd, NOTIFIER);
                $setup(negedge D1 &&& xcheck2, posedge CLK, tSUd, NOTIFIER);
                $setup(posedge E &&& xcheck3, posedge CLK, tSUd, NOTIFIER);
                $setup(negedge E &&& xcheck3, posedge CLK, tSUd, NOTIFIER);
                $setup(posedge D0 &&& xcheck4, posedge CLK, tSUd, NOTIFIER);
                $setup(negedge D0 &&& xcheck4, posedge CLK, tSUd, NOTIFIER);
                $hold(posedge CLK, posedge S &&& xcheck1, tHDd, NOTIFIER);
                $hold(posedge CLK, negedge S &&& xcheck1, tHDd, NOTIFIER);
                $hold(posedge CLK, posedge D1 &&& xcheck2, tHDd, NOTIFIER);
                $hold(posedge CLK, negedge D1 &&& xcheck2, tHDd, NOTIFIER);
                $hold(posedge CLK, posedge E &&& xcheck3, tHDd, NOTIFIER);
                $hold(posedge CLK, negedge E &&& xcheck3, tHDd, NOTIFIER);
                $hold(posedge CLK, posedge D0 &&& xcheck4, tHDd, NOTIFIER);
                $hold(posedge CLK, negedge D0 &&& xcheck4, tHDd, NOTIFIER);
                $recovery(posedge CLR, posedge CLK &&& check2, tRECclr, NOTIFIER);
                $width(posedge CLK &&& check1, tPWclk, 0, NOTIFIER);
                $width(negedge CLK &&& check1, tPWclk, 0, NOTIFIER);
                $hold(posedge CLK, posedge CLR &&& check2, tHDclr, NOTIFIER);
                $hold(posedge CLK, negedge CLR &&& check2, tHDclr, NOTIFIER);
                $width(negedge CLR, tPWclr, 0, NOTIFIER);
        endspecify
endmodule

module fdesf2a9(Q, D0, D1, S, E, CLK, CLR);
        output Q;
        input  D0, D1, S, E, CLK, CLR;
        supply0 PRESET;
        reg NOTIFIER;
        mux g1(N1, E, D0, Q);
        mux g2(DATA, S, D1, N1);
        not g3(CLEAR, CLR);
        buf g4(Q, QOUT);
        ff g5(QOUT, DATA, CLK, PRESET, CLEAR, NOTIFIER);
        // CONDITIONAL TIMING CHECK SIGNALS
        not g6(check1, CLEAR);
        buf g7(check2, DATA);
        // EXTERNAL TIMING CHECK SIGNALS
        xor     g8_2(sstz1, D1, N1);
        xtc_and g9(xcheck1, check1, sstz1);
        xtc_and g11(xcheck2, check1, S);
        xor     g12_1(g12_1_out, D0, Q);
        not     g12_2(g12_2_out, S);
        and     g12_3(sstz3, g12_1_out, g12_2_out);
        xtc_and g13(xcheck3, check1, sstz3);
        not     g14_1(g14_1_out, S);
        and     g14_2(sstz4, E, g14_1_out);
        xtc_and g15(xcheck4, sstz4, check1);
        // SPECIFY BLOCK
        specify
                specparam tSUd = 0 ;
                specparam tHDd = 0 ;
                specparam tRECclr = 0 ;
                specparam tPWclk = 0 ;
                specparam tHDclr = 0 ;
                specparam tPWclr = 0 ;
                specparam CLK_01_LH_Q = 0, CLK_01_HL_Q = 0 ;
                specparam CLR_10_LH_Q = 0, CLR_10_HL_Q = 0 ;
                (posedge CLK *> (Q : 1'b1)) = (CLK_01_LH_Q, CLK_01_HL_Q) ;
                (negedge CLR *> (Q : 1'b1)) = (CLR_10_LH_Q, CLR_10_HL_Q) ;
                $setup(posedge S &&& xcheck1, posedge CLK, tSUd, NOTIFIER);
                $setup(negedge S &&& xcheck1, posedge CLK, tSUd, NOTIFIER);
                $setup(posedge D1 &&& xcheck2, posedge CLK, tSUd, NOTIFIER);
                $setup(negedge D1 &&& xcheck2, posedge CLK, tSUd, NOTIFIER);
                $setup(posedge E &&& xcheck3, posedge CLK, tSUd, NOTIFIER);
                $setup(negedge E &&& xcheck3, posedge CLK, tSUd, NOTIFIER);
                $setup(posedge D0 &&& xcheck4, posedge CLK, tSUd, NOTIFIER);
                $setup(negedge D0 &&& xcheck4, posedge CLK, tSUd, NOTIFIER);
                $hold(posedge CLK, posedge S &&& xcheck1, tHDd, NOTIFIER);
                $hold(posedge CLK, negedge S &&& xcheck1, tHDd, NOTIFIER);
                $hold(posedge CLK, posedge D1 &&& xcheck2, tHDd, NOTIFIER);
                $hold(posedge CLK, negedge D1 &&& xcheck2, tHDd, NOTIFIER);
                $hold(posedge CLK, posedge E &&& xcheck3, tHDd, NOTIFIER);
                $hold(posedge CLK, negedge E &&& xcheck3, tHDd, NOTIFIER);
                $hold(posedge CLK, posedge D0 &&& xcheck4, tHDd, NOTIFIER);
                $hold(posedge CLK, negedge D0 &&& xcheck4, tHDd, NOTIFIER);
                $recovery(posedge CLR, posedge CLK &&& check2, tRECclr, NOTIFIER);
                $width(posedge CLK &&& check1, tPWclk, 0, NOTIFIER);
                $width(negedge CLK &&& check1, tPWclk, 0, NOTIFIER);
                $hold(posedge CLK, posedge CLR &&& check2, tHDclr, NOTIFIER);
                $hold(posedge CLK, negedge CLR &&& check2, tHDclr, NOTIFIER);
                $width(negedge CLR, tPWclr, 0, NOTIFIER);
        endspecify
endmodule

module fdesf2c1(QN, D0, D1, S, E, CLK, CLR);
        output QN;
        input  D0, D1, S, E, CLK, CLR;
        supply0 PRESET;
        reg NOTIFIER;
        not g1(N2, QN);
        mux g2(N1, E, D0, N2);
        mux g3(DATA, S, D1, N1);
        not g4(CLEAR, CLR);
        not g5(QN, QOUT);
        ff g6(QOUT, DATA, CLK, PRESET, CLEAR, NOTIFIER);
        // CONDITIONAL TIMING CHECK SIGNALS
        not g7(check1, CLEAR);
        buf g8(check2, DATA);
        // EXTERNAL TIMING CHECK SIGNALS
        mux     g9_2(g9_2_out, E, D0, N2);
        xor     g9_3(sstz1, D1, g9_2_out);
        xtc_and g10(xcheck1, check1, sstz1);
        xtc_and g12(xcheck2, check1, S);
        xor     g13_2(g13_2_out, D0, N2);
        not     g13_3(g13_3_out, S);
        and     g13_4(sstz3, g13_2_out, g13_3_out);
        xtc_and g14(xcheck3, check1, sstz3);
        not     g15_1(g15_1_out, S);
        and     g15_2(sstz4, E, g15_1_out);
        xtc_and g16(xcheck4, sstz4, check1);
        // SPECIFY BLOCK
        specify
                specparam tSUd = 0 ;
                specparam tHDd = 0 ;
                specparam tRECclr = 0 ;
                specparam tPWclk = 0 ;
                specparam tHDclr = 0 ;
                specparam tPWclr = 0 ;
                specparam CLK_01_LH_QN = 0, CLK_01_HL_QN = 0 ;
                specparam CLR_10_LH_QN = 0, CLR_10_HL_QN = 0 ;
                (posedge CLK *> (QN : 1'b1)) = (CLK_01_LH_QN, CLK_01_HL_QN) ;
                (negedge CLR *> (QN : 1'b1)) = (CLR_10_LH_QN, CLR_10_HL_QN) ;
                $setup(posedge S &&& xcheck1, posedge CLK, tSUd, NOTIFIER);
                $setup(negedge S &&& xcheck1, posedge CLK, tSUd, NOTIFIER);
                $setup(posedge D1 &&& xcheck2, posedge CLK, tSUd, NOTIFIER);
                $setup(negedge D1 &&& xcheck2, posedge CLK, tSUd, NOTIFIER);
                $setup(posedge E &&& xcheck3, posedge CLK, tSUd, NOTIFIER);
                $setup(negedge E &&& xcheck3, posedge CLK, tSUd, NOTIFIER);
                $setup(posedge D0 &&& xcheck4, posedge CLK, tSUd, NOTIFIER);
                $setup(negedge D0 &&& xcheck4, posedge CLK, tSUd, NOTIFIER);
                $hold(posedge CLK, posedge S &&& xcheck1, tHDd, NOTIFIER);
                $hold(posedge CLK, negedge S &&& xcheck1, tHDd, NOTIFIER);
                $hold(posedge CLK, posedge D1 &&& xcheck2, tHDd, NOTIFIER);
                $hold(posedge CLK, negedge D1 &&& xcheck2, tHDd, NOTIFIER);
                $hold(posedge CLK, posedge E &&& xcheck3, tHDd, NOTIFIER);
                $hold(posedge CLK, negedge E &&& xcheck3, tHDd, NOTIFIER);
                $hold(posedge CLK, posedge D0 &&& xcheck4, tHDd, NOTIFIER);
                $hold(posedge CLK, negedge D0 &&& xcheck4, tHDd, NOTIFIER);
                $recovery(posedge CLR, posedge CLK &&& check2, tRECclr, NOTIFIER);
                $width(posedge CLK &&& check1, tPWclk, 0, NOTIFIER);
                $width(negedge CLK &&& check1, tPWclk, 0, NOTIFIER);
                $hold(posedge CLK, posedge CLR &&& check2, tHDclr, NOTIFIER);
                $hold(posedge CLK, negedge CLR &&& check2, tHDclr, NOTIFIER);
                $width(negedge CLR, tPWclr, 0, NOTIFIER);
        endspecify
endmodule

module fdesf2c15(QN, D0, D1, S, E, CLK, CLR);
        output QN;
        input  D0, D1, S, E, CLK, CLR;
        supply0 PRESET;
        reg NOTIFIER;
        not g1(N2, QN);
        mux g2(N1, E, D0, N2);
        mux g3(DATA, S, D1, N1);
        not g4(CLEAR, CLR);
        not g5(QN, QOUT);
        ff g6(QOUT, DATA, CLK, PRESET, CLEAR, NOTIFIER);
        // CONDITIONAL TIMING CHECK SIGNALS
        not g7(check1, CLEAR);
        buf g8(check2, DATA);
        // EXTERNAL TIMING CHECK SIGNALS
        mux     g9_2(g9_2_out, E, D0, N2);
        xor     g9_3(sstz1, D1, g9_2_out);
        xtc_and g10(xcheck1, check1, sstz1);
        xtc_and g12(xcheck2, check1, S);
        xor     g13_2(g13_2_out, D0, N2);
        not     g13_3(g13_3_out, S);
        and     g13_4(sstz3, g13_2_out, g13_3_out);
        xtc_and g14(xcheck3, check1, sstz3);
        not     g15_1(g15_1_out, S);
        and     g15_2(sstz4, E, g15_1_out);
        xtc_and g16(xcheck4, sstz4, check1);
        // SPECIFY BLOCK
        specify
                specparam tSUd = 0 ;
                specparam tHDd = 0 ;
                specparam tRECclr = 0 ;
                specparam tPWclk = 0 ;
                specparam tHDclr = 0 ;
                specparam tPWclr = 0 ;
                specparam CLK_01_LH_QN = 0, CLK_01_HL_QN = 0 ;
                specparam CLR_10_LH_QN = 0, CLR_10_HL_QN = 0 ;
                (posedge CLK *> (QN : 1'b1)) = (CLK_01_LH_QN, CLK_01_HL_QN) ;
                (negedge CLR *> (QN : 1'b1)) = (CLR_10_LH_QN, CLR_10_HL_QN) ;
                $setup(posedge S &&& xcheck1, posedge CLK, tSUd, NOTIFIER);
                $setup(negedge S &&& xcheck1, posedge CLK, tSUd, NOTIFIER);
                $setup(posedge D1 &&& xcheck2, posedge CLK, tSUd, NOTIFIER);
                $setup(negedge D1 &&& xcheck2, posedge CLK, tSUd, NOTIFIER);
                $setup(posedge E &&& xcheck3, posedge CLK, tSUd, NOTIFIER);
                $setup(negedge E &&& xcheck3, posedge CLK, tSUd, NOTIFIER);
                $setup(posedge D0 &&& xcheck4, posedge CLK, tSUd, NOTIFIER);
                $setup(negedge D0 &&& xcheck4, posedge CLK, tSUd, NOTIFIER);
                $hold(posedge CLK, posedge S &&& xcheck1, tHDd, NOTIFIER);
                $hold(posedge CLK, negedge S &&& xcheck1, tHDd, NOTIFIER);
                $hold(posedge CLK, posedge D1 &&& xcheck2, tHDd, NOTIFIER);
                $hold(posedge CLK, negedge D1 &&& xcheck2, tHDd, NOTIFIER);
                $hold(posedge CLK, posedge E &&& xcheck3, tHDd, NOTIFIER);
                $hold(posedge CLK, negedge E &&& xcheck3, tHDd, NOTIFIER);
                $hold(posedge CLK, posedge D0 &&& xcheck4, tHDd, NOTIFIER);
                $hold(posedge CLK, negedge D0 &&& xcheck4, tHDd, NOTIFIER);
                $recovery(posedge CLR, posedge CLK &&& check2, tRECclr, NOTIFIER);
                $width(posedge CLK &&& check1, tPWclk, 0, NOTIFIER);
                $width(negedge CLK &&& check1, tPWclk, 0, NOTIFIER);
                $hold(posedge CLK, posedge CLR &&& check2, tHDclr, NOTIFIER);
                $hold(posedge CLK, negedge CLR &&& check2, tHDclr, NOTIFIER);
                $width(negedge CLR, tPWclr, 0, NOTIFIER);
        endspecify
endmodule

module fdesf2c2(QN, D0, D1, S, E, CLK, CLR);
        output QN;
        input  D0, D1, S, E, CLK, CLR;
        supply0 PRESET;
        reg NOTIFIER;
        not g1(N2, QN);
        mux g2(N1, E, D0, N2);
        mux g3(DATA, S, D1, N1);
        not g4(CLEAR, CLR);
        not g5(QN, QOUT);
        ff g6(QOUT, DATA, CLK, PRESET, CLEAR, NOTIFIER);
        // CONDITIONAL TIMING CHECK SIGNALS
        not g7(check1, CLEAR);
        buf g8(check2, DATA);
        // EXTERNAL TIMING CHECK SIGNALS
        mux     g9_2(g9_2_out, E, D0, N2);
        xor     g9_3(sstz1, D1, g9_2_out);
        xtc_and g10(xcheck1, check1, sstz1);
        xtc_and g12(xcheck2, check1, S);
        xor     g13_2(g13_2_out, D0, N2);
        not     g13_3(g13_3_out, S);
        and     g13_4(sstz3, g13_2_out, g13_3_out);
        xtc_and g14(xcheck3, check1, sstz3);
        not     g15_1(g15_1_out, S);
        and     g15_2(sstz4, E, g15_1_out);
        xtc_and g16(xcheck4, sstz4, check1);
        // SPECIFY BLOCK
        specify
                specparam tSUd = 0 ;
                specparam tHDd = 0 ;
                specparam tRECclr = 0 ;
                specparam tPWclk = 0 ;
                specparam tHDclr = 0 ;
                specparam tPWclr = 0 ;
                specparam CLK_01_LH_QN = 0, CLK_01_HL_QN = 0 ;
                specparam CLR_10_LH_QN = 0, CLR_10_HL_QN = 0 ;
                (posedge CLK *> (QN : 1'b1)) = (CLK_01_LH_QN, CLK_01_HL_QN) ;
                (negedge CLR *> (QN : 1'b1)) = (CLR_10_LH_QN, CLR_10_HL_QN) ;
                $setup(posedge S &&& xcheck1, posedge CLK, tSUd, NOTIFIER);
                $setup(negedge S &&& xcheck1, posedge CLK, tSUd, NOTIFIER);
                $setup(posedge D1 &&& xcheck2, posedge CLK, tSUd, NOTIFIER);
                $setup(negedge D1 &&& xcheck2, posedge CLK, tSUd, NOTIFIER);
                $setup(posedge E &&& xcheck3, posedge CLK, tSUd, NOTIFIER);
                $setup(negedge E &&& xcheck3, posedge CLK, tSUd, NOTIFIER);
                $setup(posedge D0 &&& xcheck4, posedge CLK, tSUd, NOTIFIER);
                $setup(negedge D0 &&& xcheck4, posedge CLK, tSUd, NOTIFIER);
                $hold(posedge CLK, posedge S &&& xcheck1, tHDd, NOTIFIER);
                $hold(posedge CLK, negedge S &&& xcheck1, tHDd, NOTIFIER);
                $hold(posedge CLK, posedge D1 &&& xcheck2, tHDd, NOTIFIER);
                $hold(posedge CLK, negedge D1 &&& xcheck2, tHDd, NOTIFIER);
                $hold(posedge CLK, posedge E &&& xcheck3, tHDd, NOTIFIER);
                $hold(posedge CLK, negedge E &&& xcheck3, tHDd, NOTIFIER);
                $hold(posedge CLK, posedge D0 &&& xcheck4, tHDd, NOTIFIER);
                $hold(posedge CLK, negedge D0 &&& xcheck4, tHDd, NOTIFIER);
                $recovery(posedge CLR, posedge CLK &&& check2, tRECclr, NOTIFIER);
                $width(posedge CLK &&& check1, tPWclk, 0, NOTIFIER);
                $width(negedge CLK &&& check1, tPWclk, 0, NOTIFIER);
                $hold(posedge CLK, posedge CLR &&& check2, tHDclr, NOTIFIER);
                $hold(posedge CLK, negedge CLR &&& check2, tHDclr, NOTIFIER);
                $width(negedge CLR, tPWclr, 0, NOTIFIER);
        endspecify
endmodule

module fdesf2c3(QN, D0, D1, S, E, CLK, CLR);
        output QN;
        input  D0, D1, S, E, CLK, CLR;
        supply0 PRESET;
        reg NOTIFIER;
        not g1(N2, QN);
        mux g2(N1, E, D0, N2);
        mux g3(DATA, S, D1, N1);
        not g4(CLEAR, CLR);
        not g5(QN, QOUT);
        ff g6(QOUT, DATA, CLK, PRESET, CLEAR, NOTIFIER);
        // CONDITIONAL TIMING CHECK SIGNALS
        not g7(check1, CLEAR);
        buf g8(check2, DATA);
        // EXTERNAL TIMING CHECK SIGNALS
        mux     g9_2(g9_2_out, E, D0, N2);
        xor     g9_3(sstz1, D1, g9_2_out);
        xtc_and g10(xcheck1, check1, sstz1);
        xtc_and g12(xcheck2, check1, S);
        xor     g13_2(g13_2_out, D0, N2);
        not     g13_3(g13_3_out, S);
        and     g13_4(sstz3, g13_2_out, g13_3_out);
        xtc_and g14(xcheck3, check1, sstz3);
        not     g15_1(g15_1_out, S);
        and     g15_2(sstz4, E, g15_1_out);
        xtc_and g16(xcheck4, sstz4, check1);
        // SPECIFY BLOCK
        specify
                specparam tSUd = 0 ;
                specparam tHDd = 0 ;
                specparam tRECclr = 0 ;
                specparam tPWclk = 0 ;
                specparam tHDclr = 0 ;
                specparam tPWclr = 0 ;
                specparam CLK_01_LH_QN = 0, CLK_01_HL_QN = 0 ;
                specparam CLR_10_LH_QN = 0, CLR_10_HL_QN = 0 ;
                (posedge CLK *> (QN : 1'b1)) = (CLK_01_LH_QN, CLK_01_HL_QN) ;
                (negedge CLR *> (QN : 1'b1)) = (CLR_10_LH_QN, CLR_10_HL_QN) ;
                $setup(posedge S &&& xcheck1, posedge CLK, tSUd, NOTIFIER);
                $setup(negedge S &&& xcheck1, posedge CLK, tSUd, NOTIFIER);
                $setup(posedge D1 &&& xcheck2, posedge CLK, tSUd, NOTIFIER);
                $setup(negedge D1 &&& xcheck2, posedge CLK, tSUd, NOTIFIER);
                $setup(posedge E &&& xcheck3, posedge CLK, tSUd, NOTIFIER);
                $setup(negedge E &&& xcheck3, posedge CLK, tSUd, NOTIFIER);
                $setup(posedge D0 &&& xcheck4, posedge CLK, tSUd, NOTIFIER);
                $setup(negedge D0 &&& xcheck4, posedge CLK, tSUd, NOTIFIER);
                $hold(posedge CLK, posedge S &&& xcheck1, tHDd, NOTIFIER);
                $hold(posedge CLK, negedge S &&& xcheck1, tHDd, NOTIFIER);
                $hold(posedge CLK, posedge D1 &&& xcheck2, tHDd, NOTIFIER);
                $hold(posedge CLK, negedge D1 &&& xcheck2, tHDd, NOTIFIER);
                $hold(posedge CLK, posedge E &&& xcheck3, tHDd, NOTIFIER);
                $hold(posedge CLK, negedge E &&& xcheck3, tHDd, NOTIFIER);
                $hold(posedge CLK, posedge D0 &&& xcheck4, tHDd, NOTIFIER);
                $hold(posedge CLK, negedge D0 &&& xcheck4, tHDd, NOTIFIER);
                $recovery(posedge CLR, posedge CLK &&& check2, tRECclr, NOTIFIER);
                $width(posedge CLK &&& check1, tPWclk, 0, NOTIFIER);
                $width(negedge CLK &&& check1, tPWclk, 0, NOTIFIER);
                $hold(posedge CLK, posedge CLR &&& check2, tHDclr, NOTIFIER);
                $hold(posedge CLK, negedge CLR &&& check2, tHDclr, NOTIFIER);
                $width(negedge CLR, tPWclr, 0, NOTIFIER);
        endspecify
endmodule

module fdesf2c6(QN, D0, D1, S, E, CLK, CLR);
        output QN;
        input  D0, D1, S, E, CLK, CLR;
        supply0 PRESET;
        reg NOTIFIER;
        not g1(N2, QN);
        mux g2(N1, E, D0, N2);
        mux g3(DATA, S, D1, N1);
        not g4(CLEAR, CLR);
        not g5(QN, QOUT);
        ff g6(QOUT, DATA, CLK, PRESET, CLEAR, NOTIFIER);
        // CONDITIONAL TIMING CHECK SIGNALS
        not g7(check1, CLEAR);
        buf g8(check2, DATA);
        // EXTERNAL TIMING CHECK SIGNALS
        mux     g9_2(g9_2_out, E, D0, N2);
        xor     g9_3(sstz1, D1, g9_2_out);
        xtc_and g10(xcheck1, check1, sstz1);
        xtc_and g12(xcheck2, check1, S);
        xor     g13_2(g13_2_out, D0, N2);
        not     g13_3(g13_3_out, S);
        and     g13_4(sstz3, g13_2_out, g13_3_out);
        xtc_and g14(xcheck3, check1, sstz3);
        not     g15_1(g15_1_out, S);
        and     g15_2(sstz4, E, g15_1_out);
        xtc_and g16(xcheck4, sstz4, check1);
        // SPECIFY BLOCK
        specify
                specparam tSUd = 0 ;
                specparam tHDd = 0 ;
                specparam tRECclr = 0 ;
                specparam tPWclk = 0 ;
                specparam tHDclr = 0 ;
                specparam tPWclr = 0 ;
                specparam CLK_01_LH_QN = 0, CLK_01_HL_QN = 0 ;
                specparam CLR_10_LH_QN = 0, CLR_10_HL_QN = 0 ;
                (posedge CLK *> (QN : 1'b1)) = (CLK_01_LH_QN, CLK_01_HL_QN) ;
                (negedge CLR *> (QN : 1'b1)) = (CLR_10_LH_QN, CLR_10_HL_QN) ;
                $setup(posedge S &&& xcheck1, posedge CLK, tSUd, NOTIFIER);
                $setup(negedge S &&& xcheck1, posedge CLK, tSUd, NOTIFIER);
                $setup(posedge D1 &&& xcheck2, posedge CLK, tSUd, NOTIFIER);
                $setup(negedge D1 &&& xcheck2, posedge CLK, tSUd, NOTIFIER);
                $setup(posedge E &&& xcheck3, posedge CLK, tSUd, NOTIFIER);
                $setup(negedge E &&& xcheck3, posedge CLK, tSUd, NOTIFIER);
                $setup(posedge D0 &&& xcheck4, posedge CLK, tSUd, NOTIFIER);
                $setup(negedge D0 &&& xcheck4, posedge CLK, tSUd, NOTIFIER);
                $hold(posedge CLK, posedge S &&& xcheck1, tHDd, NOTIFIER);
                $hold(posedge CLK, negedge S &&& xcheck1, tHDd, NOTIFIER);
                $hold(posedge CLK, posedge D1 &&& xcheck2, tHDd, NOTIFIER);
                $hold(posedge CLK, negedge D1 &&& xcheck2, tHDd, NOTIFIER);
                $hold(posedge CLK, posedge E &&& xcheck3, tHDd, NOTIFIER);
                $hold(posedge CLK, negedge E &&& xcheck3, tHDd, NOTIFIER);
                $hold(posedge CLK, posedge D0 &&& xcheck4, tHDd, NOTIFIER);
                $hold(posedge CLK, negedge D0 &&& xcheck4, tHDd, NOTIFIER);
                $recovery(posedge CLR, posedge CLK &&& check2, tRECclr, NOTIFIER);
                $width(posedge CLK &&& check1, tPWclk, 0, NOTIFIER);
                $width(negedge CLK &&& check1, tPWclk, 0, NOTIFIER);
                $hold(posedge CLK, posedge CLR &&& check2, tHDclr, NOTIFIER);
                $hold(posedge CLK, negedge CLR &&& check2, tHDclr, NOTIFIER);
                $width(negedge CLR, tPWclr, 0, NOTIFIER);
        endspecify
endmodule

module fdesf2c9(QN, D0, D1, S, E, CLK, CLR);
        output QN;
        input  D0, D1, S, E, CLK, CLR;
        supply0 PRESET;
        reg NOTIFIER;
        not g1(N2, QN);
        mux g2(N1, E, D0, N2);
        mux g3(DATA, S, D1, N1);
        not g4(CLEAR, CLR);
        not g5(QN, QOUT);
        ff g6(QOUT, DATA, CLK, PRESET, CLEAR, NOTIFIER);
        // CONDITIONAL TIMING CHECK SIGNALS
        not g7(check1, CLEAR);
        buf g8(check2, DATA);
        // EXTERNAL TIMING CHECK SIGNALS
        mux     g9_2(g9_2_out, E, D0, N2);
        xor     g9_3(sstz1, D1, g9_2_out);
        xtc_and g10(xcheck1, check1, sstz1);
        xtc_and g12(xcheck2, check1, S);
        xor     g13_2(g13_2_out, D0, N2);
        not     g13_3(g13_3_out, S);
        and     g13_4(sstz3, g13_2_out, g13_3_out);
        xtc_and g14(xcheck3, check1, sstz3);
        not     g15_1(g15_1_out, S);
        and     g15_2(sstz4, E, g15_1_out);
        xtc_and g16(xcheck4, sstz4, check1);
        // SPECIFY BLOCK
        specify
                specparam tSUd = 0 ;
                specparam tHDd = 0 ;
                specparam tRECclr = 0 ;
                specparam tPWclk = 0 ;
                specparam tHDclr = 0 ;
                specparam tPWclr = 0 ;
                specparam CLK_01_LH_QN = 0, CLK_01_HL_QN = 0 ;
                specparam CLR_10_LH_QN = 0, CLR_10_HL_QN = 0 ;
                (posedge CLK *> (QN : 1'b1)) = (CLK_01_LH_QN, CLK_01_HL_QN) ;
                (negedge CLR *> (QN : 1'b1)) = (CLR_10_LH_QN, CLR_10_HL_QN) ;
                $setup(posedge S &&& xcheck1, posedge CLK, tSUd, NOTIFIER);
                $setup(negedge S &&& xcheck1, posedge CLK, tSUd, NOTIFIER);
                $setup(posedge D1 &&& xcheck2, posedge CLK, tSUd, NOTIFIER);
                $setup(negedge D1 &&& xcheck2, posedge CLK, tSUd, NOTIFIER);
                $setup(posedge E &&& xcheck3, posedge CLK, tSUd, NOTIFIER);
                $setup(negedge E &&& xcheck3, posedge CLK, tSUd, NOTIFIER);
                $setup(posedge D0 &&& xcheck4, posedge CLK, tSUd, NOTIFIER);
                $setup(negedge D0 &&& xcheck4, posedge CLK, tSUd, NOTIFIER);
                $hold(posedge CLK, posedge S &&& xcheck1, tHDd, NOTIFIER);
                $hold(posedge CLK, negedge S &&& xcheck1, tHDd, NOTIFIER);
                $hold(posedge CLK, posedge D1 &&& xcheck2, tHDd, NOTIFIER);
                $hold(posedge CLK, negedge D1 &&& xcheck2, tHDd, NOTIFIER);
                $hold(posedge CLK, posedge E &&& xcheck3, tHDd, NOTIFIER);
                $hold(posedge CLK, negedge E &&& xcheck3, tHDd, NOTIFIER);
                $hold(posedge CLK, posedge D0 &&& xcheck4, tHDd, NOTIFIER);
                $hold(posedge CLK, negedge D0 &&& xcheck4, tHDd, NOTIFIER);
                $recovery(posedge CLR, posedge CLK &&& check2, tRECclr, NOTIFIER);
                $width(posedge CLK &&& check1, tPWclk, 0, NOTIFIER);
                $width(negedge CLK &&& check1, tPWclk, 0, NOTIFIER);
                $hold(posedge CLK, posedge CLR &&& check2, tHDclr, NOTIFIER);
                $hold(posedge CLK, negedge CLR &&& check2, tHDclr, NOTIFIER);
                $width(negedge CLR, tPWclr, 0, NOTIFIER);
        endspecify
endmodule

module fdesf3a1(Q, D0, D1, S, E, CLK, PRE);
        output Q;
        input  D0, D1, S, E, CLK, PRE;
        supply0 CLEAR;
        reg NOTIFIER;
        mux g1(N1, E, D0, Q);
        mux g2(DATA, S, D1, N1);
        not g3(PRESET, PRE);
        buf g4(Q, QOUT);
        ff g5(QOUT, DATA, CLK, PRESET, CLEAR, NOTIFIER);
        // CONDITIONAL TIMING CHECK SIGNALS
        not g6(check1, PRESET);
        not g7(check2, DATA);
        // EXTERNAL TIMING CHECK SIGNALS
        xor     g8_2(sstz1, D1, N1);
        xtc_and g9(xcheck1, check1, sstz1);
        xtc_and g11(xcheck2, check1, S);
        xor     g12_1(g12_1_out, D0, Q);
        not     g12_2(g12_2_out, S);
        and     g12_3(sstz3, g12_1_out, g12_2_out);
        xtc_and g13(xcheck3, check1, sstz3);
        not     g14_1(g14_1_out, S);
        and     g14_2(sstz4, E, g14_1_out);
        xtc_and g15(xcheck4, sstz4, check1);
        // SPECIFY BLOCK
        specify
                specparam tSUd = 0 ;
                specparam tHDd = 0 ;
                specparam tRECpre = 0 ;
                specparam tPWclk = 0 ;
                specparam tHDpre = 0 ;
                specparam tPWpre = 0 ;
                specparam CLK_01_LH_Q = 0, CLK_01_HL_Q = 0 ;
                specparam PRE_10_LH_Q = 0, PRE_10_HL_Q = 0 ;
                (posedge CLK *> (Q : 1'b1)) = (CLK_01_LH_Q, CLK_01_HL_Q) ;
                (negedge PRE *> (Q : 1'b1)) = (PRE_10_LH_Q, PRE_10_HL_Q) ;
                $setup(posedge S &&& xcheck1, posedge CLK, tSUd, NOTIFIER);
                $setup(negedge S &&& xcheck1, posedge CLK, tSUd, NOTIFIER);
                $setup(posedge D1 &&& xcheck2, posedge CLK, tSUd, NOTIFIER);
                $setup(negedge D1 &&& xcheck2, posedge CLK, tSUd, NOTIFIER);
                $setup(posedge E &&& xcheck3, posedge CLK, tSUd, NOTIFIER);
                $setup(negedge E &&& xcheck3, posedge CLK, tSUd, NOTIFIER);
                $setup(posedge D0 &&& xcheck4, posedge CLK, tSUd, NOTIFIER);
                $setup(negedge D0 &&& xcheck4, posedge CLK, tSUd, NOTIFIER);
                $hold(posedge CLK, posedge S &&& xcheck1, tHDd, NOTIFIER);
                $hold(posedge CLK, negedge S &&& xcheck1, tHDd, NOTIFIER);
                $hold(posedge CLK, posedge D1 &&& xcheck2, tHDd, NOTIFIER);
                $hold(posedge CLK, negedge D1 &&& xcheck2, tHDd, NOTIFIER);
                $hold(posedge CLK, posedge E &&& xcheck3, tHDd, NOTIFIER);
                $hold(posedge CLK, negedge E &&& xcheck3, tHDd, NOTIFIER);
                $hold(posedge CLK, posedge D0 &&& xcheck4, tHDd, NOTIFIER);
                $hold(posedge CLK, negedge D0 &&& xcheck4, tHDd, NOTIFIER);
                $recovery(posedge PRE, posedge CLK &&& check2, tRECpre, NOTIFIER);
                $width(posedge CLK &&& check1, tPWclk, 0, NOTIFIER);
                $width(negedge CLK &&& check1, tPWclk, 0, NOTIFIER);
                $hold(posedge CLK, posedge PRE &&& check2, tHDpre, NOTIFIER);
                $hold(posedge CLK, negedge PRE &&& check2, tHDpre, NOTIFIER);
                $width(negedge PRE, tPWpre, 0, NOTIFIER);
        endspecify
endmodule

module fdesf3a15(Q, D0, D1, S, E, CLK, PRE);
        output Q;
        input  D0, D1, S, E, CLK, PRE;
        supply0 CLEAR;
        reg NOTIFIER;
        mux g1(N1, E, D0, Q);
        mux g2(DATA, S, D1, N1);
        not g3(PRESET, PRE);
        buf g4(Q, QOUT);
        ff g5(QOUT, DATA, CLK, PRESET, CLEAR, NOTIFIER);
        // CONDITIONAL TIMING CHECK SIGNALS
        not g6(check1, PRESET);
        not g7(check2, DATA);
        // EXTERNAL TIMING CHECK SIGNALS
        xor     g8_2(sstz1, D1, N1);
        xtc_and g9(xcheck1, check1, sstz1);
        xtc_and g11(xcheck2, check1, S);
        xor     g12_1(g12_1_out, D0, Q);
        not     g12_2(g12_2_out, S);
        and     g12_3(sstz3, g12_1_out, g12_2_out);
        xtc_and g13(xcheck3, check1, sstz3);
        not     g14_1(g14_1_out, S);
        and     g14_2(sstz4, E, g14_1_out);
        xtc_and g15(xcheck4, sstz4, check1);
        // SPECIFY BLOCK
        specify
                specparam tSUd = 0 ;
                specparam tHDd = 0 ;
                specparam tRECpre = 0 ;
                specparam tPWclk = 0 ;
                specparam tHDpre = 0 ;
                specparam tPWpre = 0 ;
                specparam CLK_01_LH_Q = 0, CLK_01_HL_Q = 0 ;
                specparam PRE_10_LH_Q = 0, PRE_10_HL_Q = 0 ;
                (posedge CLK *> (Q : 1'b1)) = (CLK_01_LH_Q, CLK_01_HL_Q) ;
                (negedge PRE *> (Q : 1'b1)) = (PRE_10_LH_Q, PRE_10_HL_Q) ;
                $setup(posedge S &&& xcheck1, posedge CLK, tSUd, NOTIFIER);
                $setup(negedge S &&& xcheck1, posedge CLK, tSUd, NOTIFIER);
                $setup(posedge D1 &&& xcheck2, posedge CLK, tSUd, NOTIFIER);
                $setup(negedge D1 &&& xcheck2, posedge CLK, tSUd, NOTIFIER);
                $setup(posedge E &&& xcheck3, posedge CLK, tSUd, NOTIFIER);
                $setup(negedge E &&& xcheck3, posedge CLK, tSUd, NOTIFIER);
                $setup(posedge D0 &&& xcheck4, posedge CLK, tSUd, NOTIFIER);
                $setup(negedge D0 &&& xcheck4, posedge CLK, tSUd, NOTIFIER);
                $hold(posedge CLK, posedge S &&& xcheck1, tHDd, NOTIFIER);
                $hold(posedge CLK, negedge S &&& xcheck1, tHDd, NOTIFIER);
                $hold(posedge CLK, posedge D1 &&& xcheck2, tHDd, NOTIFIER);
                $hold(posedge CLK, negedge D1 &&& xcheck2, tHDd, NOTIFIER);
                $hold(posedge CLK, posedge E &&& xcheck3, tHDd, NOTIFIER);
                $hold(posedge CLK, negedge E &&& xcheck3, tHDd, NOTIFIER);
                $hold(posedge CLK, posedge D0 &&& xcheck4, tHDd, NOTIFIER);
                $hold(posedge CLK, negedge D0 &&& xcheck4, tHDd, NOTIFIER);
                $recovery(posedge PRE, posedge CLK &&& check2, tRECpre, NOTIFIER);
                $width(posedge CLK &&& check1, tPWclk, 0, NOTIFIER);
                $width(negedge CLK &&& check1, tPWclk, 0, NOTIFIER);
                $hold(posedge CLK, posedge PRE &&& check2, tHDpre, NOTIFIER);
                $hold(posedge CLK, negedge PRE &&& check2, tHDpre, NOTIFIER);
                $width(negedge PRE, tPWpre, 0, NOTIFIER);
        endspecify
endmodule

module fdesf3a2(Q, D0, D1, S, E, CLK, PRE);
        output Q;
        input  D0, D1, S, E, CLK, PRE;
        supply0 CLEAR;
        reg NOTIFIER;
        mux g1(N1, E, D0, Q);
        mux g2(DATA, S, D1, N1);
        not g3(PRESET, PRE);
        buf g4(Q, QOUT);
        ff g5(QOUT, DATA, CLK, PRESET, CLEAR, NOTIFIER);
        // CONDITIONAL TIMING CHECK SIGNALS
        not g6(check1, PRESET);
        not g7(check2, DATA);
        // EXTERNAL TIMING CHECK SIGNALS
        xor     g8_2(sstz1, D1, N1);
        xtc_and g9(xcheck1, check1, sstz1);
        xtc_and g11(xcheck2, check1, S);
        xor     g12_1(g12_1_out, D0, Q);
        not     g12_2(g12_2_out, S);
        and     g12_3(sstz3, g12_1_out, g12_2_out);
        xtc_and g13(xcheck3, check1, sstz3);
        not     g14_1(g14_1_out, S);
        and     g14_2(sstz4, E, g14_1_out);
        xtc_and g15(xcheck4, sstz4, check1);
        // SPECIFY BLOCK
        specify
                specparam tSUd = 0 ;
                specparam tHDd = 0 ;
                specparam tRECpre = 0 ;
                specparam tPWclk = 0 ;
                specparam tHDpre = 0 ;
                specparam tPWpre = 0 ;
                specparam CLK_01_LH_Q = 0, CLK_01_HL_Q = 0 ;
                specparam PRE_10_LH_Q = 0, PRE_10_HL_Q = 0 ;
                (posedge CLK *> (Q : 1'b1)) = (CLK_01_LH_Q, CLK_01_HL_Q) ;
                (negedge PRE *> (Q : 1'b1)) = (PRE_10_LH_Q, PRE_10_HL_Q) ;
                $setup(posedge S &&& xcheck1, posedge CLK, tSUd, NOTIFIER);
                $setup(negedge S &&& xcheck1, posedge CLK, tSUd, NOTIFIER);
                $setup(posedge D1 &&& xcheck2, posedge CLK, tSUd, NOTIFIER);
                $setup(negedge D1 &&& xcheck2, posedge CLK, tSUd, NOTIFIER);
                $setup(posedge E &&& xcheck3, posedge CLK, tSUd, NOTIFIER);
                $setup(negedge E &&& xcheck3, posedge CLK, tSUd, NOTIFIER);
                $setup(posedge D0 &&& xcheck4, posedge CLK, tSUd, NOTIFIER);
                $setup(negedge D0 &&& xcheck4, posedge CLK, tSUd, NOTIFIER);
                $hold(posedge CLK, posedge S &&& xcheck1, tHDd, NOTIFIER);
                $hold(posedge CLK, negedge S &&& xcheck1, tHDd, NOTIFIER);
                $hold(posedge CLK, posedge D1 &&& xcheck2, tHDd, NOTIFIER);
                $hold(posedge CLK, negedge D1 &&& xcheck2, tHDd, NOTIFIER);
                $hold(posedge CLK, posedge E &&& xcheck3, tHDd, NOTIFIER);
                $hold(posedge CLK, negedge E &&& xcheck3, tHDd, NOTIFIER);
                $hold(posedge CLK, posedge D0 &&& xcheck4, tHDd, NOTIFIER);
                $hold(posedge CLK, negedge D0 &&& xcheck4, tHDd, NOTIFIER);
                $recovery(posedge PRE, posedge CLK &&& check2, tRECpre, NOTIFIER);
                $width(posedge CLK &&& check1, tPWclk, 0, NOTIFIER);
                $width(negedge CLK &&& check1, tPWclk, 0, NOTIFIER);
                $hold(posedge CLK, posedge PRE &&& check2, tHDpre, NOTIFIER);
                $hold(posedge CLK, negedge PRE &&& check2, tHDpre, NOTIFIER);
                $width(negedge PRE, tPWpre, 0, NOTIFIER);
        endspecify
endmodule

module fdesf3a3(Q, D0, D1, S, E, CLK, PRE);
        output Q;
        input  D0, D1, S, E, CLK, PRE;
        supply0 CLEAR;
        reg NOTIFIER;
        mux g1(N1, E, D0, Q);
        mux g2(DATA, S, D1, N1);
        not g3(PRESET, PRE);
        buf g4(Q, QOUT);
        ff g5(QOUT, DATA, CLK, PRESET, CLEAR, NOTIFIER);
        // CONDITIONAL TIMING CHECK SIGNALS
        not g6(check1, PRESET);
        not g7(check2, DATA);
        // EXTERNAL TIMING CHECK SIGNALS
        xor     g8_2(sstz1, D1, N1);
        xtc_and g9(xcheck1, check1, sstz1);
        xtc_and g11(xcheck2, check1, S);
        xor     g12_1(g12_1_out, D0, Q);
        not     g12_2(g12_2_out, S);
        and     g12_3(sstz3, g12_1_out, g12_2_out);
        xtc_and g13(xcheck3, check1, sstz3);
        not     g14_1(g14_1_out, S);
        and     g14_2(sstz4, E, g14_1_out);
        xtc_and g15(xcheck4, sstz4, check1);
        // SPECIFY BLOCK
        specify
                specparam tSUd = 0 ;
                specparam tHDd = 0 ;
                specparam tRECpre = 0 ;
                specparam tPWclk = 0 ;
                specparam tHDpre = 0 ;
                specparam tPWpre = 0 ;
                specparam CLK_01_LH_Q = 0, CLK_01_HL_Q = 0 ;
                specparam PRE_10_LH_Q = 0, PRE_10_HL_Q = 0 ;
                (posedge CLK *> (Q : 1'b1)) = (CLK_01_LH_Q, CLK_01_HL_Q) ;
                (negedge PRE *> (Q : 1'b1)) = (PRE_10_LH_Q, PRE_10_HL_Q) ;
                $setup(posedge S &&& xcheck1, posedge CLK, tSUd, NOTIFIER);
                $setup(negedge S &&& xcheck1, posedge CLK, tSUd, NOTIFIER);
                $setup(posedge D1 &&& xcheck2, posedge CLK, tSUd, NOTIFIER);
                $setup(negedge D1 &&& xcheck2, posedge CLK, tSUd, NOTIFIER);
                $setup(posedge E &&& xcheck3, posedge CLK, tSUd, NOTIFIER);
                $setup(negedge E &&& xcheck3, posedge CLK, tSUd, NOTIFIER);
                $setup(posedge D0 &&& xcheck4, posedge CLK, tSUd, NOTIFIER);
                $setup(negedge D0 &&& xcheck4, posedge CLK, tSUd, NOTIFIER);
                $hold(posedge CLK, posedge S &&& xcheck1, tHDd, NOTIFIER);
                $hold(posedge CLK, negedge S &&& xcheck1, tHDd, NOTIFIER);
                $hold(posedge CLK, posedge D1 &&& xcheck2, tHDd, NOTIFIER);
                $hold(posedge CLK, negedge D1 &&& xcheck2, tHDd, NOTIFIER);
                $hold(posedge CLK, posedge E &&& xcheck3, tHDd, NOTIFIER);
                $hold(posedge CLK, negedge E &&& xcheck3, tHDd, NOTIFIER);
                $hold(posedge CLK, posedge D0 &&& xcheck4, tHDd, NOTIFIER);
                $hold(posedge CLK, negedge D0 &&& xcheck4, tHDd, NOTIFIER);
                $recovery(posedge PRE, posedge CLK &&& check2, tRECpre, NOTIFIER);
                $width(posedge CLK &&& check1, tPWclk, 0, NOTIFIER);
                $width(negedge CLK &&& check1, tPWclk, 0, NOTIFIER);
                $hold(posedge CLK, posedge PRE &&& check2, tHDpre, NOTIFIER);
                $hold(posedge CLK, negedge PRE &&& check2, tHDpre, NOTIFIER);
                $width(negedge PRE, tPWpre, 0, NOTIFIER);
        endspecify
endmodule

module fdesf3a6(Q, D0, D1, S, E, CLK, PRE);
        output Q;
        input  D0, D1, S, E, CLK, PRE;
        supply0 CLEAR;
        reg NOTIFIER;
        mux g1(N1, E, D0, Q);
        mux g2(DATA, S, D1, N1);
        not g3(PRESET, PRE);
        buf g4(Q, QOUT);
        ff g5(QOUT, DATA, CLK, PRESET, CLEAR, NOTIFIER);
        // CONDITIONAL TIMING CHECK SIGNALS
        not g6(check1, PRESET);
        not g7(check2, DATA);
        // EXTERNAL TIMING CHECK SIGNALS
        xor     g8_2(sstz1, D1, N1);
        xtc_and g9(xcheck1, check1, sstz1);
        xtc_and g11(xcheck2, check1, S);
        xor     g12_1(g12_1_out, D0, Q);
        not     g12_2(g12_2_out, S);
        and     g12_3(sstz3, g12_1_out, g12_2_out);
        xtc_and g13(xcheck3, check1, sstz3);
        not     g14_1(g14_1_out, S);
        and     g14_2(sstz4, E, g14_1_out);
        xtc_and g15(xcheck4, sstz4, check1);
        // SPECIFY BLOCK
        specify
                specparam tSUd = 0 ;
                specparam tHDd = 0 ;
                specparam tRECpre = 0 ;
                specparam tPWclk = 0 ;
                specparam tHDpre = 0 ;
                specparam tPWpre = 0 ;
                specparam CLK_01_LH_Q = 0, CLK_01_HL_Q = 0 ;
                specparam PRE_10_LH_Q = 0, PRE_10_HL_Q = 0 ;
                (posedge CLK *> (Q : 1'b1)) = (CLK_01_LH_Q, CLK_01_HL_Q) ;
                (negedge PRE *> (Q : 1'b1)) = (PRE_10_LH_Q, PRE_10_HL_Q) ;
                $setup(posedge S &&& xcheck1, posedge CLK, tSUd, NOTIFIER);
                $setup(negedge S &&& xcheck1, posedge CLK, tSUd, NOTIFIER);
                $setup(posedge D1 &&& xcheck2, posedge CLK, tSUd, NOTIFIER);
                $setup(negedge D1 &&& xcheck2, posedge CLK, tSUd, NOTIFIER);
                $setup(posedge E &&& xcheck3, posedge CLK, tSUd, NOTIFIER);
                $setup(negedge E &&& xcheck3, posedge CLK, tSUd, NOTIFIER);
                $setup(posedge D0 &&& xcheck4, posedge CLK, tSUd, NOTIFIER);
                $setup(negedge D0 &&& xcheck4, posedge CLK, tSUd, NOTIFIER);
                $hold(posedge CLK, posedge S &&& xcheck1, tHDd, NOTIFIER);
                $hold(posedge CLK, negedge S &&& xcheck1, tHDd, NOTIFIER);
                $hold(posedge CLK, posedge D1 &&& xcheck2, tHDd, NOTIFIER);
                $hold(posedge CLK, negedge D1 &&& xcheck2, tHDd, NOTIFIER);
                $hold(posedge CLK, posedge E &&& xcheck3, tHDd, NOTIFIER);
                $hold(posedge CLK, negedge E &&& xcheck3, tHDd, NOTIFIER);
                $hold(posedge CLK, posedge D0 &&& xcheck4, tHDd, NOTIFIER);
                $hold(posedge CLK, negedge D0 &&& xcheck4, tHDd, NOTIFIER);
                $recovery(posedge PRE, posedge CLK &&& check2, tRECpre, NOTIFIER);
                $width(posedge CLK &&& check1, tPWclk, 0, NOTIFIER);
                $width(negedge CLK &&& check1, tPWclk, 0, NOTIFIER);
                $hold(posedge CLK, posedge PRE &&& check2, tHDpre, NOTIFIER);
                $hold(posedge CLK, negedge PRE &&& check2, tHDpre, NOTIFIER);
                $width(negedge PRE, tPWpre, 0, NOTIFIER);
        endspecify
endmodule

module fdesf3a9(Q, D0, D1, S, E, CLK, PRE);
        output Q;
        input  D0, D1, S, E, CLK, PRE;
        supply0 CLEAR;
        reg NOTIFIER;
        mux g1(N1, E, D0, Q);
        mux g2(DATA, S, D1, N1);
        not g3(PRESET, PRE);
        buf g4(Q, QOUT);
        ff g5(QOUT, DATA, CLK, PRESET, CLEAR, NOTIFIER);
        // CONDITIONAL TIMING CHECK SIGNALS
        not g6(check1, PRESET);
        not g7(check2, DATA);
        // EXTERNAL TIMING CHECK SIGNALS
        xor     g8_2(sstz1, D1, N1);
        xtc_and g9(xcheck1, check1, sstz1);
        xtc_and g11(xcheck2, check1, S);
        xor     g12_1(g12_1_out, D0, Q);
        not     g12_2(g12_2_out, S);
        and     g12_3(sstz3, g12_1_out, g12_2_out);
        xtc_and g13(xcheck3, check1, sstz3);
        not     g14_1(g14_1_out, S);
        and     g14_2(sstz4, E, g14_1_out);
        xtc_and g15(xcheck4, sstz4, check1);
        // SPECIFY BLOCK
        specify
                specparam tSUd = 0 ;
                specparam tHDd = 0 ;
                specparam tRECpre = 0 ;
                specparam tPWclk = 0 ;
                specparam tHDpre = 0 ;
                specparam tPWpre = 0 ;
                specparam CLK_01_LH_Q = 0, CLK_01_HL_Q = 0 ;
                specparam PRE_10_LH_Q = 0, PRE_10_HL_Q = 0 ;
                (posedge CLK *> (Q : 1'b1)) = (CLK_01_LH_Q, CLK_01_HL_Q) ;
                (negedge PRE *> (Q : 1'b1)) = (PRE_10_LH_Q, PRE_10_HL_Q) ;
                $setup(posedge S &&& xcheck1, posedge CLK, tSUd, NOTIFIER);
                $setup(negedge S &&& xcheck1, posedge CLK, tSUd, NOTIFIER);
                $setup(posedge D1 &&& xcheck2, posedge CLK, tSUd, NOTIFIER);
                $setup(negedge D1 &&& xcheck2, posedge CLK, tSUd, NOTIFIER);
                $setup(posedge E &&& xcheck3, posedge CLK, tSUd, NOTIFIER);
                $setup(negedge E &&& xcheck3, posedge CLK, tSUd, NOTIFIER);
                $setup(posedge D0 &&& xcheck4, posedge CLK, tSUd, NOTIFIER);
                $setup(negedge D0 &&& xcheck4, posedge CLK, tSUd, NOTIFIER);
                $hold(posedge CLK, posedge S &&& xcheck1, tHDd, NOTIFIER);
                $hold(posedge CLK, negedge S &&& xcheck1, tHDd, NOTIFIER);
                $hold(posedge CLK, posedge D1 &&& xcheck2, tHDd, NOTIFIER);
                $hold(posedge CLK, negedge D1 &&& xcheck2, tHDd, NOTIFIER);
                $hold(posedge CLK, posedge E &&& xcheck3, tHDd, NOTIFIER);
                $hold(posedge CLK, negedge E &&& xcheck3, tHDd, NOTIFIER);
                $hold(posedge CLK, posedge D0 &&& xcheck4, tHDd, NOTIFIER);
                $hold(posedge CLK, negedge D0 &&& xcheck4, tHDd, NOTIFIER);
                $recovery(posedge PRE, posedge CLK &&& check2, tRECpre, NOTIFIER);
                $width(posedge CLK &&& check1, tPWclk, 0, NOTIFIER);
                $width(negedge CLK &&& check1, tPWclk, 0, NOTIFIER);
                $hold(posedge CLK, posedge PRE &&& check2, tHDpre, NOTIFIER);
                $hold(posedge CLK, negedge PRE &&& check2, tHDpre, NOTIFIER);
                $width(negedge PRE, tPWpre, 0, NOTIFIER);
        endspecify
endmodule

module fdf1a1(Q, D, CLK);
        output Q;
        input  D, CLK;
        supply0 PRESET, CLEAR;
        reg NOTIFIER;
        buf g1(Q, QOUT);
        ff g2(QOUT, D, CLK, PRESET, CLEAR, NOTIFIER);
        // EXTERNAL TIMING CHECK SIGNALS
        // SPECIFY BLOCK
        specify
                specparam tSUd = 0 ;
                specparam tHDd = 0 ;
                specparam tPWclk = 0 ;
                specparam CLK_01_LH_Q = 0, CLK_01_HL_Q = 0 ;
                (posedge CLK *> (Q : 1'b1)) = (CLK_01_LH_Q, CLK_01_HL_Q) ;
                $setup(posedge D, posedge CLK, tSUd, NOTIFIER);
                $setup(negedge D, posedge CLK, tSUd, NOTIFIER);
                $hold(posedge CLK, posedge D, tHDd, NOTIFIER);
                $hold(posedge CLK, negedge D, tHDd, NOTIFIER);
                $width(posedge CLK, tPWclk, 0, NOTIFIER);
                $width(negedge CLK, tPWclk, 0, NOTIFIER);
        endspecify
endmodule

module fdf1a15(Q, D, CLK);
        output Q;
        input  D, CLK;
        supply0 PRESET, CLEAR;
        reg NOTIFIER;
        buf g1(Q, QOUT);
        ff g2(QOUT, D, CLK, PRESET, CLEAR, NOTIFIER);
        // EXTERNAL TIMING CHECK SIGNALS
        // SPECIFY BLOCK
        specify
                specparam tSUd = 0 ;
                specparam tHDd = 0 ;
                specparam tPWclk = 0 ;
                specparam CLK_01_LH_Q = 0, CLK_01_HL_Q = 0 ;
                (posedge CLK *> (Q : 1'b1)) = (CLK_01_LH_Q, CLK_01_HL_Q) ;
                $setup(posedge D, posedge CLK, tSUd, NOTIFIER);
                $setup(negedge D, posedge CLK, tSUd, NOTIFIER);
                $hold(posedge CLK, posedge D, tHDd, NOTIFIER);
                $hold(posedge CLK, negedge D, tHDd, NOTIFIER);
                $width(posedge CLK, tPWclk, 0, NOTIFIER);
                $width(negedge CLK, tPWclk, 0, NOTIFIER);
        endspecify
endmodule

module fdf1a2(Q, D, CLK);
        output Q;
        input  D, CLK;
        supply0 PRESET, CLEAR;
        reg NOTIFIER;
        buf g1(Q, QOUT);
        ff g2(QOUT, D, CLK, PRESET, CLEAR, NOTIFIER);
        // EXTERNAL TIMING CHECK SIGNALS
        // SPECIFY BLOCK
        specify
                specparam tSUd = 0 ;
                specparam tHDd = 0 ;
                specparam tPWclk = 0 ;
                specparam CLK_01_LH_Q = 0, CLK_01_HL_Q = 0 ;
                (posedge CLK *> (Q : 1'b1)) = (CLK_01_LH_Q, CLK_01_HL_Q) ;
                $setup(posedge D, posedge CLK, tSUd, NOTIFIER);
                $setup(negedge D, posedge CLK, tSUd, NOTIFIER);
                $hold(posedge CLK, posedge D, tHDd, NOTIFIER);
                $hold(posedge CLK, negedge D, tHDd, NOTIFIER);
                $width(posedge CLK, tPWclk, 0, NOTIFIER);
                $width(negedge CLK, tPWclk, 0, NOTIFIER);
        endspecify
endmodule

module fdf1a3(Q, D, CLK);
        output Q;
        input  D, CLK;
        supply0 PRESET, CLEAR;
        reg NOTIFIER;
        buf g1(Q, QOUT);
        ff g2(QOUT, D, CLK, PRESET, CLEAR, NOTIFIER);
        // EXTERNAL TIMING CHECK SIGNALS
        // SPECIFY BLOCK
        specify
                specparam tSUd = 0 ;
                specparam tHDd = 0 ;
                specparam tPWclk = 0 ;
                specparam CLK_01_LH_Q = 0, CLK_01_HL_Q = 0 ;
                (posedge CLK *> (Q : 1'b1)) = (CLK_01_LH_Q, CLK_01_HL_Q) ;
                $setup(posedge D, posedge CLK, tSUd, NOTIFIER);
                $setup(negedge D, posedge CLK, tSUd, NOTIFIER);
                $hold(posedge CLK, posedge D, tHDd, NOTIFIER);
                $hold(posedge CLK, negedge D, tHDd, NOTIFIER);
                $width(posedge CLK, tPWclk, 0, NOTIFIER);
                $width(negedge CLK, tPWclk, 0, NOTIFIER);
        endspecify
endmodule

module fdf1a6(Q, D, CLK);
        output Q;
        input  D, CLK;
        supply0 PRESET, CLEAR;
        reg NOTIFIER;
        buf g1(Q, QOUT);
        ff g2(QOUT, D, CLK, PRESET, CLEAR, NOTIFIER);
        // EXTERNAL TIMING CHECK SIGNALS
        // SPECIFY BLOCK
        specify
                specparam tSUd = 0 ;
                specparam tHDd = 0 ;
                specparam tPWclk = 0 ;
                specparam CLK_01_LH_Q = 0, CLK_01_HL_Q = 0 ;
                (posedge CLK *> (Q : 1'b1)) = (CLK_01_LH_Q, CLK_01_HL_Q) ;
                $setup(posedge D, posedge CLK, tSUd, NOTIFIER);
                $setup(negedge D, posedge CLK, tSUd, NOTIFIER);
                $hold(posedge CLK, posedge D, tHDd, NOTIFIER);
                $hold(posedge CLK, negedge D, tHDd, NOTIFIER);
                $width(posedge CLK, tPWclk, 0, NOTIFIER);
                $width(negedge CLK, tPWclk, 0, NOTIFIER);
        endspecify
endmodule

module fdf1a9(Q, D, CLK);
        output Q;
        input  D, CLK;
        supply0 PRESET, CLEAR;
        reg NOTIFIER;
        buf g1(Q, QOUT);
        ff g2(QOUT, D, CLK, PRESET, CLEAR, NOTIFIER);
        // EXTERNAL TIMING CHECK SIGNALS
        // SPECIFY BLOCK
        specify
                specparam tSUd = 0 ;
                specparam tHDd = 0 ;
                specparam tPWclk = 0 ;
                specparam CLK_01_LH_Q = 0, CLK_01_HL_Q = 0 ;
                (posedge CLK *> (Q : 1'b1)) = (CLK_01_LH_Q, CLK_01_HL_Q) ;
                $setup(posedge D, posedge CLK, tSUd, NOTIFIER);
                $setup(negedge D, posedge CLK, tSUd, NOTIFIER);
                $hold(posedge CLK, posedge D, tHDd, NOTIFIER);
                $hold(posedge CLK, negedge D, tHDd, NOTIFIER);
                $width(posedge CLK, tPWclk, 0, NOTIFIER);
                $width(negedge CLK, tPWclk, 0, NOTIFIER);
        endspecify
endmodule

module fdf1b1(Q, D, CLK);
        output Q;
        input  D, CLK;
        supply0 PRESET, CLEAR;
        reg NOTIFIER;
        not g1(CLOCK, CLK);
        buf g2(Q, QOUT);
        ff g3(QOUT, D, CLOCK, PRESET, CLEAR, NOTIFIER);
        // EXTERNAL TIMING CHECK SIGNALS
        // SPECIFY BLOCK
        specify
                specparam tSUd = 0 ;
                specparam tHDd = 0 ;
                specparam tPWclk = 0 ;
                specparam CLK_10_LH_Q = 0, CLK_10_HL_Q = 0 ;
                (negedge CLK *> (Q : 1'b1)) = (CLK_10_LH_Q, CLK_10_HL_Q) ;
                $setup(posedge D, negedge CLK, tSUd, NOTIFIER);
                $setup(negedge D, negedge CLK, tSUd, NOTIFIER);
                $hold(negedge CLK, posedge D, tHDd, NOTIFIER);
                $hold(negedge CLK, negedge D, tHDd, NOTIFIER);
                $width(negedge CLK, tPWclk, 0, NOTIFIER);
                $width(posedge CLK, tPWclk, 0, NOTIFIER);
        endspecify
endmodule

module fdf1b15(Q, D, CLK);
        output Q;
        input  D, CLK;
        supply0 PRESET, CLEAR;
        reg NOTIFIER;
        not g1(CLOCK, CLK);
        buf g2(Q, QOUT);
        ff g3(QOUT, D, CLOCK, PRESET, CLEAR, NOTIFIER);
        // EXTERNAL TIMING CHECK SIGNALS
        // SPECIFY BLOCK
        specify
                specparam tSUd = 0 ;
                specparam tHDd = 0 ;
                specparam tPWclk = 0 ;
                specparam CLK_10_LH_Q = 0, CLK_10_HL_Q = 0 ;
                (negedge CLK *> (Q : 1'b1)) = (CLK_10_LH_Q, CLK_10_HL_Q) ;
                $setup(posedge D, negedge CLK, tSUd, NOTIFIER);
                $setup(negedge D, negedge CLK, tSUd, NOTIFIER);
                $hold(negedge CLK, posedge D, tHDd, NOTIFIER);
                $hold(negedge CLK, negedge D, tHDd, NOTIFIER);
                $width(negedge CLK, tPWclk, 0, NOTIFIER);
                $width(posedge CLK, tPWclk, 0, NOTIFIER);
        endspecify
endmodule

module fdf1b2(Q, D, CLK);
        output Q;
        input  D, CLK;
        supply0 PRESET, CLEAR;
        reg NOTIFIER;
        not g1(CLOCK, CLK);
        buf g2(Q, QOUT);
        ff g3(QOUT, D, CLOCK, PRESET, CLEAR, NOTIFIER);
        // EXTERNAL TIMING CHECK SIGNALS
        // SPECIFY BLOCK
        specify
                specparam tSUd = 0 ;
                specparam tHDd = 0 ;
                specparam tPWclk = 0 ;
                specparam CLK_10_LH_Q = 0, CLK_10_HL_Q = 0 ;
                (negedge CLK *> (Q : 1'b1)) = (CLK_10_LH_Q, CLK_10_HL_Q) ;
                $setup(posedge D, negedge CLK, tSUd, NOTIFIER);
                $setup(negedge D, negedge CLK, tSUd, NOTIFIER);
                $hold(negedge CLK, posedge D, tHDd, NOTIFIER);
                $hold(negedge CLK, negedge D, tHDd, NOTIFIER);
                $width(negedge CLK, tPWclk, 0, NOTIFIER);
                $width(posedge CLK, tPWclk, 0, NOTIFIER);
        endspecify
endmodule

module fdf1b3(Q, D, CLK);
        output Q;
        input  D, CLK;
        supply0 PRESET, CLEAR;
        reg NOTIFIER;
        not g1(CLOCK, CLK);
        buf g2(Q, QOUT);
        ff g3(QOUT, D, CLOCK, PRESET, CLEAR, NOTIFIER);
        // EXTERNAL TIMING CHECK SIGNALS
        // SPECIFY BLOCK
        specify
                specparam tSUd = 0 ;
                specparam tHDd = 0 ;
                specparam tPWclk = 0 ;
                specparam CLK_10_LH_Q = 0, CLK_10_HL_Q = 0 ;
                (negedge CLK *> (Q : 1'b1)) = (CLK_10_LH_Q, CLK_10_HL_Q) ;
                $setup(posedge D, negedge CLK, tSUd, NOTIFIER);
                $setup(negedge D, negedge CLK, tSUd, NOTIFIER);
                $hold(negedge CLK, posedge D, tHDd, NOTIFIER);
                $hold(negedge CLK, negedge D, tHDd, NOTIFIER);
                $width(negedge CLK, tPWclk, 0, NOTIFIER);
                $width(posedge CLK, tPWclk, 0, NOTIFIER);
        endspecify
endmodule

module fdf1b6(Q, D, CLK);
        output Q;
        input  D, CLK;
        supply0 PRESET, CLEAR;
        reg NOTIFIER;
        not g1(CLOCK, CLK);
        buf g2(Q, QOUT);
        ff g3(QOUT, D, CLOCK, PRESET, CLEAR, NOTIFIER);
        // EXTERNAL TIMING CHECK SIGNALS
        // SPECIFY BLOCK
        specify
                specparam tSUd = 0 ;
                specparam tHDd = 0 ;
                specparam tPWclk = 0 ;
                specparam CLK_10_LH_Q = 0, CLK_10_HL_Q = 0 ;
                (negedge CLK *> (Q : 1'b1)) = (CLK_10_LH_Q, CLK_10_HL_Q) ;
                $setup(posedge D, negedge CLK, tSUd, NOTIFIER);
                $setup(negedge D, negedge CLK, tSUd, NOTIFIER);
                $hold(negedge CLK, posedge D, tHDd, NOTIFIER);
                $hold(negedge CLK, negedge D, tHDd, NOTIFIER);
                $width(negedge CLK, tPWclk, 0, NOTIFIER);
                $width(posedge CLK, tPWclk, 0, NOTIFIER);
        endspecify
endmodule

module fdf1b9(Q, D, CLK);
        output Q;
        input  D, CLK;
        supply0 PRESET, CLEAR;
        reg NOTIFIER;
        not g1(CLOCK, CLK);
        buf g2(Q, QOUT);
        ff g3(QOUT, D, CLOCK, PRESET, CLEAR, NOTIFIER);
        // EXTERNAL TIMING CHECK SIGNALS
        // SPECIFY BLOCK
        specify
                specparam tSUd = 0 ;
                specparam tHDd = 0 ;
                specparam tPWclk = 0 ;
                specparam CLK_10_LH_Q = 0, CLK_10_HL_Q = 0 ;
                (negedge CLK *> (Q : 1'b1)) = (CLK_10_LH_Q, CLK_10_HL_Q) ;
                $setup(posedge D, negedge CLK, tSUd, NOTIFIER);
                $setup(negedge D, negedge CLK, tSUd, NOTIFIER);
                $hold(negedge CLK, posedge D, tHDd, NOTIFIER);
                $hold(negedge CLK, negedge D, tHDd, NOTIFIER);
                $width(negedge CLK, tPWclk, 0, NOTIFIER);
                $width(posedge CLK, tPWclk, 0, NOTIFIER);
        endspecify
endmodule

module fdf1c1(QN, D, CLK);
        output QN;
        input  D, CLK;
        supply0 PRESET, CLEAR;
        reg NOTIFIER;
        not g1(QN, QOUT);
        ff g2(QOUT, D, CLK, PRESET, CLEAR, NOTIFIER);
        // EXTERNAL TIMING CHECK SIGNALS
        // SPECIFY BLOCK
        specify
                specparam tSUd = 0 ;
                specparam tHDd = 0 ;
                specparam tPWclk = 0 ;
                specparam CLK_01_LH_QN = 0, CLK_01_HL_QN = 0 ;
                (posedge CLK *> (QN : 1'b1)) = (CLK_01_LH_QN, CLK_01_HL_QN) ;
                $setup(posedge D, posedge CLK, tSUd, NOTIFIER);
                $setup(negedge D, posedge CLK, tSUd, NOTIFIER);
                $hold(posedge CLK, posedge D, tHDd, NOTIFIER);
                $hold(posedge CLK, negedge D, tHDd, NOTIFIER);
                $width(posedge CLK, tPWclk, 0, NOTIFIER);
                $width(negedge CLK, tPWclk, 0, NOTIFIER);
        endspecify
endmodule

module fdf1c15(QN, D, CLK);
        output QN;
        input  D, CLK;
        supply0 PRESET, CLEAR;
        reg NOTIFIER;
        not g1(QN, QOUT);
        ff g2(QOUT, D, CLK, PRESET, CLEAR, NOTIFIER);
        // EXTERNAL TIMING CHECK SIGNALS
        // SPECIFY BLOCK
        specify
                specparam tSUd = 0 ;
                specparam tHDd = 0 ;
                specparam tPWclk = 0 ;
                specparam CLK_01_LH_QN = 0, CLK_01_HL_QN = 0 ;
                (posedge CLK *> (QN : 1'b1)) = (CLK_01_LH_QN, CLK_01_HL_QN) ;
                $setup(posedge D, posedge CLK, tSUd, NOTIFIER);
                $setup(negedge D, posedge CLK, tSUd, NOTIFIER);
                $hold(posedge CLK, posedge D, tHDd, NOTIFIER);
                $hold(posedge CLK, negedge D, tHDd, NOTIFIER);
                $width(posedge CLK, tPWclk, 0, NOTIFIER);
                $width(negedge CLK, tPWclk, 0, NOTIFIER);
        endspecify
endmodule

module fdf1c2(QN, D, CLK);
        output QN;
        input  D, CLK;
        supply0 PRESET, CLEAR;
        reg NOTIFIER;
        not g1(QN, QOUT);
        ff g2(QOUT, D, CLK, PRESET, CLEAR, NOTIFIER);
        // EXTERNAL TIMING CHECK SIGNALS
        // SPECIFY BLOCK
        specify
                specparam tSUd = 0 ;
                specparam tHDd = 0 ;
                specparam tPWclk = 0 ;
                specparam CLK_01_LH_QN = 0, CLK_01_HL_QN = 0 ;
                (posedge CLK *> (QN : 1'b1)) = (CLK_01_LH_QN, CLK_01_HL_QN) ;
                $setup(posedge D, posedge CLK, tSUd, NOTIFIER);
                $setup(negedge D, posedge CLK, tSUd, NOTIFIER);
                $hold(posedge CLK, posedge D, tHDd, NOTIFIER);
                $hold(posedge CLK, negedge D, tHDd, NOTIFIER);
                $width(posedge CLK, tPWclk, 0, NOTIFIER);
                $width(negedge CLK, tPWclk, 0, NOTIFIER);
        endspecify
endmodule

module fdf1c3(QN, D, CLK);
        output QN;
        input  D, CLK;
        supply0 PRESET, CLEAR;
        reg NOTIFIER;
        not g1(QN, QOUT);
        ff g2(QOUT, D, CLK, PRESET, CLEAR, NOTIFIER);
        // EXTERNAL TIMING CHECK SIGNALS
        // SPECIFY BLOCK
        specify
                specparam tSUd = 0 ;
                specparam tHDd = 0 ;
                specparam tPWclk = 0 ;
                specparam CLK_01_LH_QN = 0, CLK_01_HL_QN = 0 ;
                (posedge CLK *> (QN : 1'b1)) = (CLK_01_LH_QN, CLK_01_HL_QN) ;
                $setup(posedge D, posedge CLK, tSUd, NOTIFIER);
                $setup(negedge D, posedge CLK, tSUd, NOTIFIER);
                $hold(posedge CLK, posedge D, tHDd, NOTIFIER);
                $hold(posedge CLK, negedge D, tHDd, NOTIFIER);
                $width(posedge CLK, tPWclk, 0, NOTIFIER);
                $width(negedge CLK, tPWclk, 0, NOTIFIER);
        endspecify
endmodule

module fdf1c6(QN, D, CLK);
        output QN;
        input  D, CLK;
        supply0 PRESET, CLEAR;
        reg NOTIFIER;
        not g1(QN, QOUT);
        ff g2(QOUT, D, CLK, PRESET, CLEAR, NOTIFIER);
        // EXTERNAL TIMING CHECK SIGNALS
        // SPECIFY BLOCK
        specify
                specparam tSUd = 0 ;
                specparam tHDd = 0 ;
                specparam tPWclk = 0 ;
                specparam CLK_01_LH_QN = 0, CLK_01_HL_QN = 0 ;
                (posedge CLK *> (QN : 1'b1)) = (CLK_01_LH_QN, CLK_01_HL_QN) ;
                $setup(posedge D, posedge CLK, tSUd, NOTIFIER);
                $setup(negedge D, posedge CLK, tSUd, NOTIFIER);
                $hold(posedge CLK, posedge D, tHDd, NOTIFIER);
                $hold(posedge CLK, negedge D, tHDd, NOTIFIER);
                $width(posedge CLK, tPWclk, 0, NOTIFIER);
                $width(negedge CLK, tPWclk, 0, NOTIFIER);
        endspecify
endmodule

module fdf1c9(QN, D, CLK);
        output QN;
        input  D, CLK;
        supply0 PRESET, CLEAR;
        reg NOTIFIER;
        not g1(QN, QOUT);
        ff g2(QOUT, D, CLK, PRESET, CLEAR, NOTIFIER);
        // EXTERNAL TIMING CHECK SIGNALS
        // SPECIFY BLOCK
        specify
                specparam tSUd = 0 ;
                specparam tHDd = 0 ;
                specparam tPWclk = 0 ;
                specparam CLK_01_LH_QN = 0, CLK_01_HL_QN = 0 ;
                (posedge CLK *> (QN : 1'b1)) = (CLK_01_LH_QN, CLK_01_HL_QN) ;
                $setup(posedge D, posedge CLK, tSUd, NOTIFIER);
                $setup(negedge D, posedge CLK, tSUd, NOTIFIER);
                $hold(posedge CLK, posedge D, tHDd, NOTIFIER);
                $hold(posedge CLK, negedge D, tHDd, NOTIFIER);
                $width(posedge CLK, tPWclk, 0, NOTIFIER);
                $width(negedge CLK, tPWclk, 0, NOTIFIER);
        endspecify
endmodule

module fdf1d1(QN, D, CLK);
        output QN;
        input  D, CLK;
        supply0 PRESET, CLEAR;
        reg NOTIFIER;
        not g1(CLOCK, CLK);
        not g2(QN, QOUT);
        ff g3(QOUT, D, CLOCK, PRESET, CLEAR, NOTIFIER);
        // EXTERNAL TIMING CHECK SIGNALS
        // SPECIFY BLOCK
        specify
                specparam tSUd = 0 ;
                specparam tHDd = 0 ;
                specparam tPWclk = 0 ;
                specparam CLK_10_LH_QN = 0, CLK_10_HL_QN = 0 ;
                (negedge CLK *> (QN : 1'b1)) = (CLK_10_LH_QN, CLK_10_HL_QN) ;
                $setup(posedge D, negedge CLK, tSUd, NOTIFIER);
                $setup(negedge D, negedge CLK, tSUd, NOTIFIER);
                $hold(negedge CLK, posedge D, tHDd, NOTIFIER);
                $hold(negedge CLK, negedge D, tHDd, NOTIFIER);
                $width(negedge CLK, tPWclk, 0, NOTIFIER);
                $width(posedge CLK, tPWclk, 0, NOTIFIER);
        endspecify
endmodule

module fdf1d15(QN, D, CLK);
        output QN;
        input  D, CLK;
        supply0 PRESET, CLEAR;
        reg NOTIFIER;
        not g1(CLOCK, CLK);
        not g2(QN, QOUT);
        ff g3(QOUT, D, CLOCK, PRESET, CLEAR, NOTIFIER);
        // EXTERNAL TIMING CHECK SIGNALS
        // SPECIFY BLOCK
        specify
                specparam tSUd = 0 ;
                specparam tHDd = 0 ;
                specparam tPWclk = 0 ;
                specparam CLK_10_LH_QN = 0, CLK_10_HL_QN = 0 ;
                (negedge CLK *> (QN : 1'b1)) = (CLK_10_LH_QN, CLK_10_HL_QN) ;
                $setup(posedge D, negedge CLK, tSUd, NOTIFIER);
                $setup(negedge D, negedge CLK, tSUd, NOTIFIER);
                $hold(negedge CLK, posedge D, tHDd, NOTIFIER);
                $hold(negedge CLK, negedge D, tHDd, NOTIFIER);
                $width(negedge CLK, tPWclk, 0, NOTIFIER);
                $width(posedge CLK, tPWclk, 0, NOTIFIER);
        endspecify
endmodule

module fdf1d2(QN, D, CLK);
        output QN;
        input  D, CLK;
        supply0 PRESET, CLEAR;
        reg NOTIFIER;
        not g1(CLOCK, CLK);
        not g2(QN, QOUT);
        ff g3(QOUT, D, CLOCK, PRESET, CLEAR, NOTIFIER);
        // EXTERNAL TIMING CHECK SIGNALS
        // SPECIFY BLOCK
        specify
                specparam tSUd = 0 ;
                specparam tHDd = 0 ;
                specparam tPWclk = 0 ;
                specparam CLK_10_LH_QN = 0, CLK_10_HL_QN = 0 ;
                (negedge CLK *> (QN : 1'b1)) = (CLK_10_LH_QN, CLK_10_HL_QN) ;
                $setup(posedge D, negedge CLK, tSUd, NOTIFIER);
                $setup(negedge D, negedge CLK, tSUd, NOTIFIER);
                $hold(negedge CLK, posedge D, tHDd, NOTIFIER);
                $hold(negedge CLK, negedge D, tHDd, NOTIFIER);
                $width(negedge CLK, tPWclk, 0, NOTIFIER);
                $width(posedge CLK, tPWclk, 0, NOTIFIER);
        endspecify
endmodule

module fdf1d3(QN, D, CLK);
        output QN;
        input  D, CLK;
        supply0 PRESET, CLEAR;
        reg NOTIFIER;
        not g1(CLOCK, CLK);
        not g2(QN, QOUT);
        ff g3(QOUT, D, CLOCK, PRESET, CLEAR, NOTIFIER);
        // EXTERNAL TIMING CHECK SIGNALS
        // SPECIFY BLOCK
        specify
                specparam tSUd = 0 ;
                specparam tHDd = 0 ;
                specparam tPWclk = 0 ;
                specparam CLK_10_LH_QN = 0, CLK_10_HL_QN = 0 ;
                (negedge CLK *> (QN : 1'b1)) = (CLK_10_LH_QN, CLK_10_HL_QN) ;
                $setup(posedge D, negedge CLK, tSUd, NOTIFIER);
                $setup(negedge D, negedge CLK, tSUd, NOTIFIER);
                $hold(negedge CLK, posedge D, tHDd, NOTIFIER);
                $hold(negedge CLK, negedge D, tHDd, NOTIFIER);
                $width(negedge CLK, tPWclk, 0, NOTIFIER);
                $width(posedge CLK, tPWclk, 0, NOTIFIER);
        endspecify
endmodule

module fdf1d6(QN, D, CLK);
        output QN;
        input  D, CLK;
        supply0 PRESET, CLEAR;
        reg NOTIFIER;
        not g1(CLOCK, CLK);
        not g2(QN, QOUT);
        ff g3(QOUT, D, CLOCK, PRESET, CLEAR, NOTIFIER);
        // EXTERNAL TIMING CHECK SIGNALS
        // SPECIFY BLOCK
        specify
                specparam tSUd = 0 ;
                specparam tHDd = 0 ;
                specparam tPWclk = 0 ;
                specparam CLK_10_LH_QN = 0, CLK_10_HL_QN = 0 ;
                (negedge CLK *> (QN : 1'b1)) = (CLK_10_LH_QN, CLK_10_HL_QN) ;
                $setup(posedge D, negedge CLK, tSUd, NOTIFIER);
                $setup(negedge D, negedge CLK, tSUd, NOTIFIER);
                $hold(negedge CLK, posedge D, tHDd, NOTIFIER);
                $hold(negedge CLK, negedge D, tHDd, NOTIFIER);
                $width(negedge CLK, tPWclk, 0, NOTIFIER);
                $width(posedge CLK, tPWclk, 0, NOTIFIER);
        endspecify
endmodule

module fdf1d9(QN, D, CLK);
        output QN;
        input  D, CLK;
        supply0 PRESET, CLEAR;
        reg NOTIFIER;
        not g1(CLOCK, CLK);
        not g2(QN, QOUT);
        ff g3(QOUT, D, CLOCK, PRESET, CLEAR, NOTIFIER);
        // EXTERNAL TIMING CHECK SIGNALS
        // SPECIFY BLOCK
        specify
                specparam tSUd = 0 ;
                specparam tHDd = 0 ;
                specparam tPWclk = 0 ;
                specparam CLK_10_LH_QN = 0, CLK_10_HL_QN = 0 ;
                (negedge CLK *> (QN : 1'b1)) = (CLK_10_LH_QN, CLK_10_HL_QN) ;
                $setup(posedge D, negedge CLK, tSUd, NOTIFIER);
                $setup(negedge D, negedge CLK, tSUd, NOTIFIER);
                $hold(negedge CLK, posedge D, tHDd, NOTIFIER);
                $hold(negedge CLK, negedge D, tHDd, NOTIFIER);
                $width(negedge CLK, tPWclk, 0, NOTIFIER);
                $width(posedge CLK, tPWclk, 0, NOTIFIER);
        endspecify
endmodule

module fdf2a1(Q, D, CLK, CLR);
        output Q;
        input  D, CLK, CLR;
        supply0 PRESET;
        reg NOTIFIER;
        not g1(CLEAR, CLR);
        buf g2(Q, QOUT);
        ff g3(QOUT, D, CLK, PRESET, CLEAR, NOTIFIER);
        // CONDITIONAL TIMING CHECK SIGNALS
        not g4(check1, CLEAR);
        buf g5(check2, D);
        // EXTERNAL TIMING CHECK SIGNALS
        // SPECIFY BLOCK
        specify
                specparam tSUd = 0 ;
                specparam tHDd = 0 ;
                specparam tRECclr = 0 ;
                specparam tPWclk = 0 ;
                specparam tHDclr = 0 ;
                specparam tPWclr = 0 ;
                specparam CLK_01_LH_Q = 0, CLK_01_HL_Q = 0 ;
                specparam CLR_10_LH_Q = 0, CLR_10_HL_Q = 0 ;
                (posedge CLK *> (Q : 1'b1)) = (CLK_01_LH_Q, CLK_01_HL_Q) ;
                (negedge CLR *> (Q : 1'b1)) = (CLR_10_LH_Q, CLR_10_HL_Q) ;
                $setup(posedge D &&& check1, posedge CLK, tSUd, NOTIFIER);
                $setup(negedge D &&& check1, posedge CLK, tSUd, NOTIFIER);
                $hold(posedge CLK, posedge D &&& check1, tHDd, NOTIFIER);
                $hold(posedge CLK, negedge D &&& check1, tHDd, NOTIFIER);
                $recovery(posedge CLR, posedge CLK &&& check2, tRECclr, NOTIFIER);
                $width(posedge CLK &&& check1, tPWclk, 0, NOTIFIER);
                $width(negedge CLK &&& check1, tPWclk, 0, NOTIFIER);
                $hold(posedge CLK, posedge CLR &&& check2, tHDclr, NOTIFIER);
                $hold(posedge CLK, negedge CLR &&& check2, tHDclr, NOTIFIER);
                $width(negedge CLR, tPWclr, 0, NOTIFIER);
        endspecify
endmodule

module fdf2a15(Q, D, CLK, CLR);
        output Q;
        input  D, CLK, CLR;
        supply0 PRESET;
        reg NOTIFIER;
        not g1(CLEAR, CLR);
        buf g2(Q, QOUT);
        ff g3(QOUT, D, CLK, PRESET, CLEAR, NOTIFIER);
        // CONDITIONAL TIMING CHECK SIGNALS
        not g4(check1, CLEAR);
        buf g5(check2, D);
        // EXTERNAL TIMING CHECK SIGNALS
        // SPECIFY BLOCK
        specify
                specparam tSUd = 0 ;
                specparam tHDd = 0 ;
                specparam tRECclr = 0 ;
                specparam tPWclk = 0 ;
                specparam tHDclr = 0 ;
                specparam tPWclr = 0 ;
                specparam CLK_01_LH_Q = 0, CLK_01_HL_Q = 0 ;
                specparam CLR_10_LH_Q = 0, CLR_10_HL_Q = 0 ;
                (posedge CLK *> (Q : 1'b1)) = (CLK_01_LH_Q, CLK_01_HL_Q) ;
                (negedge CLR *> (Q : 1'b1)) = (CLR_10_LH_Q, CLR_10_HL_Q) ;
                $setup(posedge D &&& check1, posedge CLK, tSUd, NOTIFIER);
                $setup(negedge D &&& check1, posedge CLK, tSUd, NOTIFIER);
                $hold(posedge CLK, posedge D &&& check1, tHDd, NOTIFIER);
                $hold(posedge CLK, negedge D &&& check1, tHDd, NOTIFIER);
                $recovery(posedge CLR, posedge CLK &&& check2, tRECclr, NOTIFIER);
                $width(posedge CLK &&& check1, tPWclk, 0, NOTIFIER);
                $width(negedge CLK &&& check1, tPWclk, 0, NOTIFIER);
                $hold(posedge CLK, posedge CLR &&& check2, tHDclr, NOTIFIER);
                $hold(posedge CLK, negedge CLR &&& check2, tHDclr, NOTIFIER);
                $width(negedge CLR, tPWclr, 0, NOTIFIER);
        endspecify
endmodule

module fdf2a2(Q, D, CLK, CLR);
        output Q;
        input  D, CLK, CLR;
        supply0 PRESET;
        reg NOTIFIER;
        not g1(CLEAR, CLR);
        buf g2(Q, QOUT);
        ff g3(QOUT, D, CLK, PRESET, CLEAR, NOTIFIER);
        // CONDITIONAL TIMING CHECK SIGNALS
        not g4(check1, CLEAR);
        buf g5(check2, D);
        // EXTERNAL TIMING CHECK SIGNALS
        // SPECIFY BLOCK
        specify
                specparam tSUd = 0 ;
                specparam tHDd = 0 ;
                specparam tRECclr = 0 ;
                specparam tPWclk = 0 ;
                specparam tHDclr = 0 ;
                specparam tPWclr = 0 ;
                specparam CLK_01_LH_Q = 0, CLK_01_HL_Q = 0 ;
                specparam CLR_10_LH_Q = 0, CLR_10_HL_Q = 0 ;
                (posedge CLK *> (Q : 1'b1)) = (CLK_01_LH_Q, CLK_01_HL_Q) ;
                (negedge CLR *> (Q : 1'b1)) = (CLR_10_LH_Q, CLR_10_HL_Q) ;
                $setup(posedge D &&& check1, posedge CLK, tSUd, NOTIFIER);
                $setup(negedge D &&& check1, posedge CLK, tSUd, NOTIFIER);
                $hold(posedge CLK, posedge D &&& check1, tHDd, NOTIFIER);
                $hold(posedge CLK, negedge D &&& check1, tHDd, NOTIFIER);
                $recovery(posedge CLR, posedge CLK &&& check2, tRECclr, NOTIFIER);
                $width(posedge CLK &&& check1, tPWclk, 0, NOTIFIER);
                $width(negedge CLK &&& check1, tPWclk, 0, NOTIFIER);
                $hold(posedge CLK, posedge CLR &&& check2, tHDclr, NOTIFIER);
                $hold(posedge CLK, negedge CLR &&& check2, tHDclr, NOTIFIER);
                $width(negedge CLR, tPWclr, 0, NOTIFIER);
        endspecify
endmodule

module fdf2a3(Q, D, CLK, CLR);
        output Q;
        input  D, CLK, CLR;
        supply0 PRESET;
        reg NOTIFIER;
        not g1(CLEAR, CLR);
        buf g2(Q, QOUT);
        ff g3(QOUT, D, CLK, PRESET, CLEAR, NOTIFIER);
        // CONDITIONAL TIMING CHECK SIGNALS
        not g4(check1, CLEAR);
        buf g5(check2, D);
        // EXTERNAL TIMING CHECK SIGNALS
        // SPECIFY BLOCK
        specify
                specparam tSUd = 0 ;
                specparam tHDd = 0 ;
                specparam tRECclr = 0 ;
                specparam tPWclk = 0 ;
                specparam tHDclr = 0 ;
                specparam tPWclr = 0 ;
                specparam CLK_01_LH_Q = 0, CLK_01_HL_Q = 0 ;
                specparam CLR_10_LH_Q = 0, CLR_10_HL_Q = 0 ;
                (posedge CLK *> (Q : 1'b1)) = (CLK_01_LH_Q, CLK_01_HL_Q) ;
                (negedge CLR *> (Q : 1'b1)) = (CLR_10_LH_Q, CLR_10_HL_Q) ;
                $setup(posedge D &&& check1, posedge CLK, tSUd, NOTIFIER);
                $setup(negedge D &&& check1, posedge CLK, tSUd, NOTIFIER);
                $hold(posedge CLK, posedge D &&& check1, tHDd, NOTIFIER);
                $hold(posedge CLK, negedge D &&& check1, tHDd, NOTIFIER);
                $recovery(posedge CLR, posedge CLK &&& check2, tRECclr, NOTIFIER);
                $width(posedge CLK &&& check1, tPWclk, 0, NOTIFIER);
                $width(negedge CLK &&& check1, tPWclk, 0, NOTIFIER);
                $hold(posedge CLK, posedge CLR &&& check2, tHDclr, NOTIFIER);
                $hold(posedge CLK, negedge CLR &&& check2, tHDclr, NOTIFIER);
                $width(negedge CLR, tPWclr, 0, NOTIFIER);
        endspecify
endmodule

module fdf2a6(Q, D, CLK, CLR);
        output Q;
        input  D, CLK, CLR;
        supply0 PRESET;
        reg NOTIFIER;
        not g1(CLEAR, CLR);
        buf g2(Q, QOUT);
        ff g3(QOUT, D, CLK, PRESET, CLEAR, NOTIFIER);
        // CONDITIONAL TIMING CHECK SIGNALS
        not g4(check1, CLEAR);
        buf g5(check2, D);
        // EXTERNAL TIMING CHECK SIGNALS
        // SPECIFY BLOCK
        specify
                specparam tSUd = 0 ;
                specparam tHDd = 0 ;
                specparam tRECclr = 0 ;
                specparam tPWclk = 0 ;
                specparam tHDclr = 0 ;
                specparam tPWclr = 0 ;
                specparam CLK_01_LH_Q = 0, CLK_01_HL_Q = 0 ;
                specparam CLR_10_LH_Q = 0, CLR_10_HL_Q = 0 ;
                (posedge CLK *> (Q : 1'b1)) = (CLK_01_LH_Q, CLK_01_HL_Q) ;
                (negedge CLR *> (Q : 1'b1)) = (CLR_10_LH_Q, CLR_10_HL_Q) ;
                $setup(posedge D &&& check1, posedge CLK, tSUd, NOTIFIER);
                $setup(negedge D &&& check1, posedge CLK, tSUd, NOTIFIER);
                $hold(posedge CLK, posedge D &&& check1, tHDd, NOTIFIER);
                $hold(posedge CLK, negedge D &&& check1, tHDd, NOTIFIER);
                $recovery(posedge CLR, posedge CLK &&& check2, tRECclr, NOTIFIER);
                $width(posedge CLK &&& check1, tPWclk, 0, NOTIFIER);
                $width(negedge CLK &&& check1, tPWclk, 0, NOTIFIER);
                $hold(posedge CLK, posedge CLR &&& check2, tHDclr, NOTIFIER);
                $hold(posedge CLK, negedge CLR &&& check2, tHDclr, NOTIFIER);
                $width(negedge CLR, tPWclr, 0, NOTIFIER);
        endspecify
endmodule

module fdf2a9(Q, D, CLK, CLR);
        output Q;
        input  D, CLK, CLR;
        supply0 PRESET;
        reg NOTIFIER;
        not g1(CLEAR, CLR);
        buf g2(Q, QOUT);
        ff g3(QOUT, D, CLK, PRESET, CLEAR, NOTIFIER);
        // CONDITIONAL TIMING CHECK SIGNALS
        not g4(check1, CLEAR);
        buf g5(check2, D);
        // EXTERNAL TIMING CHECK SIGNALS
        // SPECIFY BLOCK
        specify
                specparam tSUd = 0 ;
                specparam tHDd = 0 ;
                specparam tRECclr = 0 ;
                specparam tPWclk = 0 ;
                specparam tHDclr = 0 ;
                specparam tPWclr = 0 ;
                specparam CLK_01_LH_Q = 0, CLK_01_HL_Q = 0 ;
                specparam CLR_10_LH_Q = 0, CLR_10_HL_Q = 0 ;
                (posedge CLK *> (Q : 1'b1)) = (CLK_01_LH_Q, CLK_01_HL_Q) ;
                (negedge CLR *> (Q : 1'b1)) = (CLR_10_LH_Q, CLR_10_HL_Q) ;
                $setup(posedge D &&& check1, posedge CLK, tSUd, NOTIFIER);
                $setup(negedge D &&& check1, posedge CLK, tSUd, NOTIFIER);
                $hold(posedge CLK, posedge D &&& check1, tHDd, NOTIFIER);
                $hold(posedge CLK, negedge D &&& check1, tHDd, NOTIFIER);
                $recovery(posedge CLR, posedge CLK &&& check2, tRECclr, NOTIFIER);
                $width(posedge CLK &&& check1, tPWclk, 0, NOTIFIER);
                $width(negedge CLK &&& check1, tPWclk, 0, NOTIFIER);
                $hold(posedge CLK, posedge CLR &&& check2, tHDclr, NOTIFIER);
                $hold(posedge CLK, negedge CLR &&& check2, tHDclr, NOTIFIER);
                $width(negedge CLR, tPWclr, 0, NOTIFIER);
        endspecify
endmodule

module fdf2b1(Q, D, CLK, CLR);
        output Q;
        input  D, CLK, CLR;
        supply0 PRESET;
        reg NOTIFIER;
        not g1(CLOCK, CLK);
        not g2(CLEAR, CLR);
        buf g3(Q, QOUT);
        ff g4(QOUT, D, CLOCK, PRESET, CLEAR, NOTIFIER);
        // CONDITIONAL TIMING CHECK SIGNALS
        not g5(check1, CLEAR);
        buf g6(check2, D);
        // EXTERNAL TIMING CHECK SIGNALS
        // SPECIFY BLOCK
        specify
                specparam tSUd = 0 ;
                specparam tHDd = 0 ;
                specparam tRECclr = 0 ;
                specparam tPWclk = 0 ;
                specparam tHDclr = 0 ;
                specparam tPWclr = 0 ;
                specparam CLK_10_LH_Q = 0, CLK_10_HL_Q = 0 ;
                specparam CLR_10_LH_Q = 0, CLR_10_HL_Q = 0 ;
                (negedge CLK *> (Q : 1'b1)) = (CLK_10_LH_Q, CLK_10_HL_Q) ;
                (negedge CLR *> (Q : 1'b1)) = (CLR_10_LH_Q, CLR_10_HL_Q) ;
                $setup(posedge D &&& check1, negedge CLK, tSUd, NOTIFIER);
                $setup(negedge D &&& check1, negedge CLK, tSUd, NOTIFIER);
                $hold(negedge CLK, posedge D &&& check1, tHDd, NOTIFIER);
                $hold(negedge CLK, negedge D &&& check1, tHDd, NOTIFIER);
                $recovery(posedge CLR, negedge CLK &&& check2, tRECclr, NOTIFIER);
                $width(negedge CLK &&& check1, tPWclk, 0, NOTIFIER);
                $width(posedge CLK &&& check1, tPWclk, 0, NOTIFIER);
                $hold(negedge CLK, posedge CLR &&& check2, tHDclr, NOTIFIER);
                $hold(negedge CLK, negedge CLR &&& check2, tHDclr, NOTIFIER);
                $width(negedge CLR, tPWclr, 0, NOTIFIER);
        endspecify
endmodule

module fdf2b15(Q, D, CLK, CLR);
        output Q;
        input  D, CLK, CLR;
        supply0 PRESET;
        reg NOTIFIER;
        not g1(CLOCK, CLK);
        not g2(CLEAR, CLR);
        buf g3(Q, QOUT);
        ff g4(QOUT, D, CLOCK, PRESET, CLEAR, NOTIFIER);
        // CONDITIONAL TIMING CHECK SIGNALS
        not g5(check1, CLEAR);
        buf g6(check2, D);
        // EXTERNAL TIMING CHECK SIGNALS
        // SPECIFY BLOCK
        specify
                specparam tSUd = 0 ;
                specparam tHDd = 0 ;
                specparam tRECclr = 0 ;
                specparam tPWclk = 0 ;
                specparam tHDclr = 0 ;
                specparam tPWclr = 0 ;
                specparam CLK_10_LH_Q = 0, CLK_10_HL_Q = 0 ;
                specparam CLR_10_LH_Q = 0, CLR_10_HL_Q = 0 ;
                (negedge CLK *> (Q : 1'b1)) = (CLK_10_LH_Q, CLK_10_HL_Q) ;
                (negedge CLR *> (Q : 1'b1)) = (CLR_10_LH_Q, CLR_10_HL_Q) ;
                $setup(posedge D &&& check1, negedge CLK, tSUd, NOTIFIER);
                $setup(negedge D &&& check1, negedge CLK, tSUd, NOTIFIER);
                $hold(negedge CLK, posedge D &&& check1, tHDd, NOTIFIER);
                $hold(negedge CLK, negedge D &&& check1, tHDd, NOTIFIER);
                $recovery(posedge CLR, negedge CLK &&& check2, tRECclr, NOTIFIER);
                $width(negedge CLK &&& check1, tPWclk, 0, NOTIFIER);
                $width(posedge CLK &&& check1, tPWclk, 0, NOTIFIER);
                $hold(negedge CLK, posedge CLR &&& check2, tHDclr, NOTIFIER);
                $hold(negedge CLK, negedge CLR &&& check2, tHDclr, NOTIFIER);
                $width(negedge CLR, tPWclr, 0, NOTIFIER);
        endspecify
endmodule

module fdf2b2(Q, D, CLK, CLR);
        output Q;
        input  D, CLK, CLR;
        supply0 PRESET;
        reg NOTIFIER;
        not g1(CLOCK, CLK);
        not g2(CLEAR, CLR);
        buf g3(Q, QOUT);
        ff g4(QOUT, D, CLOCK, PRESET, CLEAR, NOTIFIER);
        // CONDITIONAL TIMING CHECK SIGNALS
        not g5(check1, CLEAR);
        buf g6(check2, D);
        // EXTERNAL TIMING CHECK SIGNALS
        // SPECIFY BLOCK
        specify
                specparam tSUd = 0 ;
                specparam tHDd = 0 ;
                specparam tRECclr = 0 ;
                specparam tPWclk = 0 ;
                specparam tHDclr = 0 ;
                specparam tPWclr = 0 ;
                specparam CLK_10_LH_Q = 0, CLK_10_HL_Q = 0 ;
                specparam CLR_10_LH_Q = 0, CLR_10_HL_Q = 0 ;
                (negedge CLK *> (Q : 1'b1)) = (CLK_10_LH_Q, CLK_10_HL_Q) ;
                (negedge CLR *> (Q : 1'b1)) = (CLR_10_LH_Q, CLR_10_HL_Q) ;
                $setup(posedge D &&& check1, negedge CLK, tSUd, NOTIFIER);
                $setup(negedge D &&& check1, negedge CLK, tSUd, NOTIFIER);
                $hold(negedge CLK, posedge D &&& check1, tHDd, NOTIFIER);
                $hold(negedge CLK, negedge D &&& check1, tHDd, NOTIFIER);
                $recovery(posedge CLR, negedge CLK &&& check2, tRECclr, NOTIFIER);
                $width(negedge CLK &&& check1, tPWclk, 0, NOTIFIER);
                $width(posedge CLK &&& check1, tPWclk, 0, NOTIFIER);
                $hold(negedge CLK, posedge CLR &&& check2, tHDclr, NOTIFIER);
                $hold(negedge CLK, negedge CLR &&& check2, tHDclr, NOTIFIER);
                $width(negedge CLR, tPWclr, 0, NOTIFIER);
        endspecify
endmodule

module fdf2b3(Q, D, CLK, CLR);
        output Q;
        input  D, CLK, CLR;
        supply0 PRESET;
        reg NOTIFIER;
        not g1(CLOCK, CLK);
        not g2(CLEAR, CLR);
        buf g3(Q, QOUT);
        ff g4(QOUT, D, CLOCK, PRESET, CLEAR, NOTIFIER);
        // CONDITIONAL TIMING CHECK SIGNALS
        not g5(check1, CLEAR);
        buf g6(check2, D);
        // EXTERNAL TIMING CHECK SIGNALS
        // SPECIFY BLOCK
        specify
                specparam tSUd = 0 ;
                specparam tHDd = 0 ;
                specparam tRECclr = 0 ;
                specparam tPWclk = 0 ;
                specparam tHDclr = 0 ;
                specparam tPWclr = 0 ;
                specparam CLK_10_LH_Q = 0, CLK_10_HL_Q = 0 ;
                specparam CLR_10_LH_Q = 0, CLR_10_HL_Q = 0 ;
                (negedge CLK *> (Q : 1'b1)) = (CLK_10_LH_Q, CLK_10_HL_Q) ;
                (negedge CLR *> (Q : 1'b1)) = (CLR_10_LH_Q, CLR_10_HL_Q) ;
                $setup(posedge D &&& check1, negedge CLK, tSUd, NOTIFIER);
                $setup(negedge D &&& check1, negedge CLK, tSUd, NOTIFIER);
                $hold(negedge CLK, posedge D &&& check1, tHDd, NOTIFIER);
                $hold(negedge CLK, negedge D &&& check1, tHDd, NOTIFIER);
                $recovery(posedge CLR, negedge CLK &&& check2, tRECclr, NOTIFIER);
                $width(negedge CLK &&& check1, tPWclk, 0, NOTIFIER);
                $width(posedge CLK &&& check1, tPWclk, 0, NOTIFIER);
                $hold(negedge CLK, posedge CLR &&& check2, tHDclr, NOTIFIER);
                $hold(negedge CLK, negedge CLR &&& check2, tHDclr, NOTIFIER);
                $width(negedge CLR, tPWclr, 0, NOTIFIER);
        endspecify
endmodule

module fdf2b6(Q, D, CLK, CLR);
        output Q;
        input  D, CLK, CLR;
        supply0 PRESET;
        reg NOTIFIER;
        not g1(CLOCK, CLK);
        not g2(CLEAR, CLR);
        buf g3(Q, QOUT);
        ff g4(QOUT, D, CLOCK, PRESET, CLEAR, NOTIFIER);
        // CONDITIONAL TIMING CHECK SIGNALS
        not g5(check1, CLEAR);
        buf g6(check2, D);
        // EXTERNAL TIMING CHECK SIGNALS
        // SPECIFY BLOCK
        specify
                specparam tSUd = 0 ;
                specparam tHDd = 0 ;
                specparam tRECclr = 0 ;
                specparam tPWclk = 0 ;
                specparam tHDclr = 0 ;
                specparam tPWclr = 0 ;
                specparam CLK_10_LH_Q = 0, CLK_10_HL_Q = 0 ;
                specparam CLR_10_LH_Q = 0, CLR_10_HL_Q = 0 ;
                (negedge CLK *> (Q : 1'b1)) = (CLK_10_LH_Q, CLK_10_HL_Q) ;
                (negedge CLR *> (Q : 1'b1)) = (CLR_10_LH_Q, CLR_10_HL_Q) ;
                $setup(posedge D &&& check1, negedge CLK, tSUd, NOTIFIER);
                $setup(negedge D &&& check1, negedge CLK, tSUd, NOTIFIER);
                $hold(negedge CLK, posedge D &&& check1, tHDd, NOTIFIER);
                $hold(negedge CLK, negedge D &&& check1, tHDd, NOTIFIER);
                $recovery(posedge CLR, negedge CLK &&& check2, tRECclr, NOTIFIER);
                $width(negedge CLK &&& check1, tPWclk, 0, NOTIFIER);
                $width(posedge CLK &&& check1, tPWclk, 0, NOTIFIER);
                $hold(negedge CLK, posedge CLR &&& check2, tHDclr, NOTIFIER);
                $hold(negedge CLK, negedge CLR &&& check2, tHDclr, NOTIFIER);
                $width(negedge CLR, tPWclr, 0, NOTIFIER);
        endspecify
endmodule

module fdf2b9(Q, D, CLK, CLR);
        output Q;
        input  D, CLK, CLR;
        supply0 PRESET;
        reg NOTIFIER;
        not g1(CLOCK, CLK);
        not g2(CLEAR, CLR);
        buf g3(Q, QOUT);
        ff g4(QOUT, D, CLOCK, PRESET, CLEAR, NOTIFIER);
        // CONDITIONAL TIMING CHECK SIGNALS
        not g5(check1, CLEAR);
        buf g6(check2, D);
        // EXTERNAL TIMING CHECK SIGNALS
        // SPECIFY BLOCK
        specify
                specparam tSUd = 0 ;
                specparam tHDd = 0 ;
                specparam tRECclr = 0 ;
                specparam tPWclk = 0 ;
                specparam tHDclr = 0 ;
                specparam tPWclr = 0 ;
                specparam CLK_10_LH_Q = 0, CLK_10_HL_Q = 0 ;
                specparam CLR_10_LH_Q = 0, CLR_10_HL_Q = 0 ;
                (negedge CLK *> (Q : 1'b1)) = (CLK_10_LH_Q, CLK_10_HL_Q) ;
                (negedge CLR *> (Q : 1'b1)) = (CLR_10_LH_Q, CLR_10_HL_Q) ;
                $setup(posedge D &&& check1, negedge CLK, tSUd, NOTIFIER);
                $setup(negedge D &&& check1, negedge CLK, tSUd, NOTIFIER);
                $hold(negedge CLK, posedge D &&& check1, tHDd, NOTIFIER);
                $hold(negedge CLK, negedge D &&& check1, tHDd, NOTIFIER);
                $recovery(posedge CLR, negedge CLK &&& check2, tRECclr, NOTIFIER);
                $width(negedge CLK &&& check1, tPWclk, 0, NOTIFIER);
                $width(posedge CLK &&& check1, tPWclk, 0, NOTIFIER);
                $hold(negedge CLK, posedge CLR &&& check2, tHDclr, NOTIFIER);
                $hold(negedge CLK, negedge CLR &&& check2, tHDclr, NOTIFIER);
                $width(negedge CLR, tPWclr, 0, NOTIFIER);
        endspecify
endmodule

module fdf2c1(QN, D, CLK, CLR);
        output QN;
        input  D, CLK, CLR;
        supply0 PRESET;
        reg NOTIFIER;
        not g1(CLEAR, CLR);
        not g2(QN, QOUT);
        ff g3(QOUT, D, CLK, PRESET, CLEAR, NOTIFIER);
        // CONDITIONAL TIMING CHECK SIGNALS
        not g4(check1, CLEAR);
        buf g5(check2, D);
        // EXTERNAL TIMING CHECK SIGNALS
        // SPECIFY BLOCK
        specify
                specparam tSUd = 0 ;
                specparam tHDd = 0 ;
                specparam tRECclr = 0 ;
                specparam tPWclk = 0 ;
                specparam tHDclr = 0 ;
                specparam tPWclr = 0 ;
                specparam CLK_01_LH_QN = 0, CLK_01_HL_QN = 0 ;
                specparam CLR_10_LH_QN = 0, CLR_10_HL_QN = 0 ;
                (posedge CLK *> (QN : 1'b1)) = (CLK_01_LH_QN, CLK_01_HL_QN) ;
                (negedge CLR *> (QN : 1'b1)) = (CLR_10_LH_QN, CLR_10_HL_QN) ;
                $setup(posedge D &&& check1, posedge CLK, tSUd, NOTIFIER);
                $setup(negedge D &&& check1, posedge CLK, tSUd, NOTIFIER);
                $hold(posedge CLK, posedge D &&& check1, tHDd, NOTIFIER);
                $hold(posedge CLK, negedge D &&& check1, tHDd, NOTIFIER);
                $recovery(posedge CLR, posedge CLK &&& check2, tRECclr, NOTIFIER);
                $width(posedge CLK &&& check1, tPWclk, 0, NOTIFIER);
                $width(negedge CLK &&& check1, tPWclk, 0, NOTIFIER);
                $hold(posedge CLK, posedge CLR &&& check2, tHDclr, NOTIFIER);
                $hold(posedge CLK, negedge CLR &&& check2, tHDclr, NOTIFIER);
                $width(negedge CLR, tPWclr, 0, NOTIFIER);
        endspecify
endmodule

module fdf2c15(QN, D, CLK, CLR);
        output QN;
        input  D, CLK, CLR;
        supply0 PRESET;
        reg NOTIFIER;
        not g1(CLEAR, CLR);
        not g2(QN, QOUT);
        ff g3(QOUT, D, CLK, PRESET, CLEAR, NOTIFIER);
        // CONDITIONAL TIMING CHECK SIGNALS
        not g4(check1, CLEAR);
        buf g5(check2, D);
        // EXTERNAL TIMING CHECK SIGNALS
        // SPECIFY BLOCK
        specify
                specparam tSUd = 0 ;
                specparam tHDd = 0 ;
                specparam tRECclr = 0 ;
                specparam tPWclk = 0 ;
                specparam tHDclr = 0 ;
                specparam tPWclr = 0 ;
                specparam CLK_01_LH_QN = 0, CLK_01_HL_QN = 0 ;
                specparam CLR_10_LH_QN = 0, CLR_10_HL_QN = 0 ;
                (posedge CLK *> (QN : 1'b1)) = (CLK_01_LH_QN, CLK_01_HL_QN) ;
                (negedge CLR *> (QN : 1'b1)) = (CLR_10_LH_QN, CLR_10_HL_QN) ;
                $setup(posedge D &&& check1, posedge CLK, tSUd, NOTIFIER);
                $setup(negedge D &&& check1, posedge CLK, tSUd, NOTIFIER);
                $hold(posedge CLK, posedge D &&& check1, tHDd, NOTIFIER);
                $hold(posedge CLK, negedge D &&& check1, tHDd, NOTIFIER);
                $recovery(posedge CLR, posedge CLK &&& check2, tRECclr, NOTIFIER);
                $width(posedge CLK &&& check1, tPWclk, 0, NOTIFIER);
                $width(negedge CLK &&& check1, tPWclk, 0, NOTIFIER);
                $hold(posedge CLK, posedge CLR &&& check2, tHDclr, NOTIFIER);
                $hold(posedge CLK, negedge CLR &&& check2, tHDclr, NOTIFIER);
                $width(negedge CLR, tPWclr, 0, NOTIFIER);
        endspecify
endmodule

module fdf2c2(QN, D, CLK, CLR);
        output QN;
        input  D, CLK, CLR;
        supply0 PRESET;
        reg NOTIFIER;
        not g1(CLEAR, CLR);
        not g2(QN, QOUT);
        ff g3(QOUT, D, CLK, PRESET, CLEAR, NOTIFIER);
        // CONDITIONAL TIMING CHECK SIGNALS
        not g4(check1, CLEAR);
        buf g5(check2, D);
        // EXTERNAL TIMING CHECK SIGNALS
        // SPECIFY BLOCK
        specify
                specparam tSUd = 0 ;
                specparam tHDd = 0 ;
                specparam tRECclr = 0 ;
                specparam tPWclk = 0 ;
                specparam tHDclr = 0 ;
                specparam tPWclr = 0 ;
                specparam CLK_01_LH_QN = 0, CLK_01_HL_QN = 0 ;
                specparam CLR_10_LH_QN = 0, CLR_10_HL_QN = 0 ;
                (posedge CLK *> (QN : 1'b1)) = (CLK_01_LH_QN, CLK_01_HL_QN) ;
                (negedge CLR *> (QN : 1'b1)) = (CLR_10_LH_QN, CLR_10_HL_QN) ;
                $setup(posedge D &&& check1, posedge CLK, tSUd, NOTIFIER);
                $setup(negedge D &&& check1, posedge CLK, tSUd, NOTIFIER);
                $hold(posedge CLK, posedge D &&& check1, tHDd, NOTIFIER);
                $hold(posedge CLK, negedge D &&& check1, tHDd, NOTIFIER);
                $recovery(posedge CLR, posedge CLK &&& check2, tRECclr, NOTIFIER);
                $width(posedge CLK &&& check1, tPWclk, 0, NOTIFIER);
                $width(negedge CLK &&& check1, tPWclk, 0, NOTIFIER);
                $hold(posedge CLK, posedge CLR &&& check2, tHDclr, NOTIFIER);
                $hold(posedge CLK, negedge CLR &&& check2, tHDclr, NOTIFIER);
                $width(negedge CLR, tPWclr, 0, NOTIFIER);
        endspecify
endmodule

module fdf2c3(QN, D, CLK, CLR);
        output QN;
        input  D, CLK, CLR;
        supply0 PRESET;
        reg NOTIFIER;
        not g1(CLEAR, CLR);
        not g2(QN, QOUT);
        ff g3(QOUT, D, CLK, PRESET, CLEAR, NOTIFIER);
        // CONDITIONAL TIMING CHECK SIGNALS
        not g4(check1, CLEAR);
        buf g5(check2, D);
        // EXTERNAL TIMING CHECK SIGNALS
        // SPECIFY BLOCK
        specify
                specparam tSUd = 0 ;
                specparam tHDd = 0 ;
                specparam tRECclr = 0 ;
                specparam tPWclk = 0 ;
                specparam tHDclr = 0 ;
                specparam tPWclr = 0 ;
                specparam CLK_01_LH_QN = 0, CLK_01_HL_QN = 0 ;
                specparam CLR_10_LH_QN = 0, CLR_10_HL_QN = 0 ;
                (posedge CLK *> (QN : 1'b1)) = (CLK_01_LH_QN, CLK_01_HL_QN) ;
                (negedge CLR *> (QN : 1'b1)) = (CLR_10_LH_QN, CLR_10_HL_QN) ;
                $setup(posedge D &&& check1, posedge CLK, tSUd, NOTIFIER);
                $setup(negedge D &&& check1, posedge CLK, tSUd, NOTIFIER);
                $hold(posedge CLK, posedge D &&& check1, tHDd, NOTIFIER);
                $hold(posedge CLK, negedge D &&& check1, tHDd, NOTIFIER);
                $recovery(posedge CLR, posedge CLK &&& check2, tRECclr, NOTIFIER);
                $width(posedge CLK &&& check1, tPWclk, 0, NOTIFIER);
                $width(negedge CLK &&& check1, tPWclk, 0, NOTIFIER);
                $hold(posedge CLK, posedge CLR &&& check2, tHDclr, NOTIFIER);
                $hold(posedge CLK, negedge CLR &&& check2, tHDclr, NOTIFIER);
                $width(negedge CLR, tPWclr, 0, NOTIFIER);
        endspecify
endmodule

module fdf2c6(QN, D, CLK, CLR);
        output QN;
        input  D, CLK, CLR;
        supply0 PRESET;
        reg NOTIFIER;
        not g1(CLEAR, CLR);
        not g2(QN, QOUT);
        ff g3(QOUT, D, CLK, PRESET, CLEAR, NOTIFIER);
        // CONDITIONAL TIMING CHECK SIGNALS
        not g4(check1, CLEAR);
        buf g5(check2, D);
        // EXTERNAL TIMING CHECK SIGNALS
        // SPECIFY BLOCK
        specify
                specparam tSUd = 0 ;
                specparam tHDd = 0 ;
                specparam tRECclr = 0 ;
                specparam tPWclk = 0 ;
                specparam tHDclr = 0 ;
                specparam tPWclr = 0 ;
                specparam CLK_01_LH_QN = 0, CLK_01_HL_QN = 0 ;
                specparam CLR_10_LH_QN = 0, CLR_10_HL_QN = 0 ;
                (posedge CLK *> (QN : 1'b1)) = (CLK_01_LH_QN, CLK_01_HL_QN) ;
                (negedge CLR *> (QN : 1'b1)) = (CLR_10_LH_QN, CLR_10_HL_QN) ;
                $setup(posedge D &&& check1, posedge CLK, tSUd, NOTIFIER);
                $setup(negedge D &&& check1, posedge CLK, tSUd, NOTIFIER);
                $hold(posedge CLK, posedge D &&& check1, tHDd, NOTIFIER);
                $hold(posedge CLK, negedge D &&& check1, tHDd, NOTIFIER);
                $recovery(posedge CLR, posedge CLK &&& check2, tRECclr, NOTIFIER);
                $width(posedge CLK &&& check1, tPWclk, 0, NOTIFIER);
                $width(negedge CLK &&& check1, tPWclk, 0, NOTIFIER);
                $hold(posedge CLK, posedge CLR &&& check2, tHDclr, NOTIFIER);
                $hold(posedge CLK, negedge CLR &&& check2, tHDclr, NOTIFIER);
                $width(negedge CLR, tPWclr, 0, NOTIFIER);
        endspecify
endmodule

module fdf2c9(QN, D, CLK, CLR);
        output QN;
        input  D, CLK, CLR;
        supply0 PRESET;
        reg NOTIFIER;
        not g1(CLEAR, CLR);
        not g2(QN, QOUT);
        ff g3(QOUT, D, CLK, PRESET, CLEAR, NOTIFIER);
        // CONDITIONAL TIMING CHECK SIGNALS
        not g4(check1, CLEAR);
        buf g5(check2, D);
        // EXTERNAL TIMING CHECK SIGNALS
        // SPECIFY BLOCK
        specify
                specparam tSUd = 0 ;
                specparam tHDd = 0 ;
                specparam tRECclr = 0 ;
                specparam tPWclk = 0 ;
                specparam tHDclr = 0 ;
                specparam tPWclr = 0 ;
                specparam CLK_01_LH_QN = 0, CLK_01_HL_QN = 0 ;
                specparam CLR_10_LH_QN = 0, CLR_10_HL_QN = 0 ;
                (posedge CLK *> (QN : 1'b1)) = (CLK_01_LH_QN, CLK_01_HL_QN) ;
                (negedge CLR *> (QN : 1'b1)) = (CLR_10_LH_QN, CLR_10_HL_QN) ;
                $setup(posedge D &&& check1, posedge CLK, tSUd, NOTIFIER);
                $setup(negedge D &&& check1, posedge CLK, tSUd, NOTIFIER);
                $hold(posedge CLK, posedge D &&& check1, tHDd, NOTIFIER);
                $hold(posedge CLK, negedge D &&& check1, tHDd, NOTIFIER);
                $recovery(posedge CLR, posedge CLK &&& check2, tRECclr, NOTIFIER);
                $width(posedge CLK &&& check1, tPWclk, 0, NOTIFIER);
                $width(negedge CLK &&& check1, tPWclk, 0, NOTIFIER);
                $hold(posedge CLK, posedge CLR &&& check2, tHDclr, NOTIFIER);
                $hold(posedge CLK, negedge CLR &&& check2, tHDclr, NOTIFIER);
                $width(negedge CLR, tPWclr, 0, NOTIFIER);
        endspecify
endmodule

module fdf3a1(Q, D, CLK, PRE);
        output Q;
        input  D, CLK, PRE;
        supply0 CLEAR;
        reg NOTIFIER;
        not g1(PRESET, PRE);
        buf g2(Q, QOUT);
        ff g3(QOUT, D, CLK, PRESET, CLEAR, NOTIFIER);
        // CONDITIONAL TIMING CHECK SIGNALS
        not g4(check1, PRESET);
        not g5(check2, D);
        // EXTERNAL TIMING CHECK SIGNALS
        // SPECIFY BLOCK
        specify
                specparam tSUd = 0 ;
                specparam tHDd = 0 ;
                specparam tRECpre = 0 ;
                specparam tPWclk = 0 ;
                specparam tHDpre = 0 ;
                specparam tPWpre = 0 ;
                specparam CLK_01_LH_Q = 0, CLK_01_HL_Q = 0 ;
                specparam PRE_10_LH_Q = 0, PRE_10_HL_Q = 0 ;
                (posedge CLK *> (Q : 1'b1)) = (CLK_01_LH_Q, CLK_01_HL_Q) ;
                (negedge PRE *> (Q : 1'b1)) = (PRE_10_LH_Q, PRE_10_HL_Q) ;
                $setup(posedge D &&& check1, posedge CLK, tSUd, NOTIFIER);
                $setup(negedge D &&& check1, posedge CLK, tSUd, NOTIFIER);
                $hold(posedge CLK, posedge D &&& check1, tHDd, NOTIFIER);
                $hold(posedge CLK, negedge D &&& check1, tHDd, NOTIFIER);
                $recovery(posedge PRE, posedge CLK &&& check2, tRECpre, NOTIFIER);
                $width(posedge CLK &&& check1, tPWclk, 0, NOTIFIER);
                $width(negedge CLK &&& check1, tPWclk, 0, NOTIFIER);
                $hold(posedge CLK, posedge PRE &&& check2, tHDpre, NOTIFIER);
                $hold(posedge CLK, negedge PRE &&& check2, tHDpre, NOTIFIER);
                $width(negedge PRE, tPWpre, 0, NOTIFIER);
        endspecify
endmodule

module fdf3a15(Q, D, CLK, PRE);
        output Q;
        input  D, CLK, PRE;
        supply0 CLEAR;
        reg NOTIFIER;
        not g1(PRESET, PRE);
        buf g2(Q, QOUT);
        ff g3(QOUT, D, CLK, PRESET, CLEAR, NOTIFIER);
        // CONDITIONAL TIMING CHECK SIGNALS
        not g4(check1, PRESET);
        not g5(check2, D);
        // EXTERNAL TIMING CHECK SIGNALS
        // SPECIFY BLOCK
        specify
                specparam tSUd = 0 ;
                specparam tHDd = 0 ;
                specparam tRECpre = 0 ;
                specparam tPWclk = 0 ;
                specparam tHDpre = 0 ;
                specparam tPWpre = 0 ;
                specparam CLK_01_LH_Q = 0, CLK_01_HL_Q = 0 ;
                specparam PRE_10_LH_Q = 0, PRE_10_HL_Q = 0 ;
                (posedge CLK *> (Q : 1'b1)) = (CLK_01_LH_Q, CLK_01_HL_Q) ;
                (negedge PRE *> (Q : 1'b1)) = (PRE_10_LH_Q, PRE_10_HL_Q) ;
                $setup(posedge D &&& check1, posedge CLK, tSUd, NOTIFIER);
                $setup(negedge D &&& check1, posedge CLK, tSUd, NOTIFIER);
                $hold(posedge CLK, posedge D &&& check1, tHDd, NOTIFIER);
                $hold(posedge CLK, negedge D &&& check1, tHDd, NOTIFIER);
                $recovery(posedge PRE, posedge CLK &&& check2, tRECpre, NOTIFIER);
                $width(posedge CLK &&& check1, tPWclk, 0, NOTIFIER);
                $width(negedge CLK &&& check1, tPWclk, 0, NOTIFIER);
                $hold(posedge CLK, posedge PRE &&& check2, tHDpre, NOTIFIER);
                $hold(posedge CLK, negedge PRE &&& check2, tHDpre, NOTIFIER);
                $width(negedge PRE, tPWpre, 0, NOTIFIER);
        endspecify
endmodule

module fdf3a2(Q, D, CLK, PRE);
        output Q;
        input  D, CLK, PRE;
        supply0 CLEAR;
        reg NOTIFIER;
        not g1(PRESET, PRE);
        buf g2(Q, QOUT);
        ff g3(QOUT, D, CLK, PRESET, CLEAR, NOTIFIER);
        // CONDITIONAL TIMING CHECK SIGNALS
        not g4(check1, PRESET);
        not g5(check2, D);
        // EXTERNAL TIMING CHECK SIGNALS
        // SPECIFY BLOCK
        specify
                specparam tSUd = 0 ;
                specparam tHDd = 0 ;
                specparam tRECpre = 0 ;
                specparam tPWclk = 0 ;
                specparam tHDpre = 0 ;
                specparam tPWpre = 0 ;
                specparam CLK_01_LH_Q = 0, CLK_01_HL_Q = 0 ;
                specparam PRE_10_LH_Q = 0, PRE_10_HL_Q = 0 ;
                (posedge CLK *> (Q : 1'b1)) = (CLK_01_LH_Q, CLK_01_HL_Q) ;
                (negedge PRE *> (Q : 1'b1)) = (PRE_10_LH_Q, PRE_10_HL_Q) ;
                $setup(posedge D &&& check1, posedge CLK, tSUd, NOTIFIER);
                $setup(negedge D &&& check1, posedge CLK, tSUd, NOTIFIER);
                $hold(posedge CLK, posedge D &&& check1, tHDd, NOTIFIER);
                $hold(posedge CLK, negedge D &&& check1, tHDd, NOTIFIER);
                $recovery(posedge PRE, posedge CLK &&& check2, tRECpre, NOTIFIER);
                $width(posedge CLK &&& check1, tPWclk, 0, NOTIFIER);
                $width(negedge CLK &&& check1, tPWclk, 0, NOTIFIER);
                $hold(posedge CLK, posedge PRE &&& check2, tHDpre, NOTIFIER);
                $hold(posedge CLK, negedge PRE &&& check2, tHDpre, NOTIFIER);
                $width(negedge PRE, tPWpre, 0, NOTIFIER);
        endspecify
endmodule

module fdf3a3(Q, D, CLK, PRE);
        output Q;
        input  D, CLK, PRE;
        supply0 CLEAR;
        reg NOTIFIER;
        not g1(PRESET, PRE);
        buf g2(Q, QOUT);
        ff g3(QOUT, D, CLK, PRESET, CLEAR, NOTIFIER);
        // CONDITIONAL TIMING CHECK SIGNALS
        not g4(check1, PRESET);
        not g5(check2, D);
        // EXTERNAL TIMING CHECK SIGNALS
        // SPECIFY BLOCK
        specify
                specparam tSUd = 0 ;
                specparam tHDd = 0 ;
                specparam tRECpre = 0 ;
                specparam tPWclk = 0 ;
                specparam tHDpre = 0 ;
                specparam tPWpre = 0 ;
                specparam CLK_01_LH_Q = 0, CLK_01_HL_Q = 0 ;
                specparam PRE_10_LH_Q = 0, PRE_10_HL_Q = 0 ;
                (posedge CLK *> (Q : 1'b1)) = (CLK_01_LH_Q, CLK_01_HL_Q) ;
                (negedge PRE *> (Q : 1'b1)) = (PRE_10_LH_Q, PRE_10_HL_Q) ;
                $setup(posedge D &&& check1, posedge CLK, tSUd, NOTIFIER);
                $setup(negedge D &&& check1, posedge CLK, tSUd, NOTIFIER);
                $hold(posedge CLK, posedge D &&& check1, tHDd, NOTIFIER);
                $hold(posedge CLK, negedge D &&& check1, tHDd, NOTIFIER);
                $recovery(posedge PRE, posedge CLK &&& check2, tRECpre, NOTIFIER);
                $width(posedge CLK &&& check1, tPWclk, 0, NOTIFIER);
                $width(negedge CLK &&& check1, tPWclk, 0, NOTIFIER);
                $hold(posedge CLK, posedge PRE &&& check2, tHDpre, NOTIFIER);
                $hold(posedge CLK, negedge PRE &&& check2, tHDpre, NOTIFIER);
                $width(negedge PRE, tPWpre, 0, NOTIFIER);
        endspecify
endmodule

module fdf3a6(Q, D, CLK, PRE);
        output Q;
        input  D, CLK, PRE;
        supply0 CLEAR;
        reg NOTIFIER;
        not g1(PRESET, PRE);
        buf g2(Q, QOUT);
        ff g3(QOUT, D, CLK, PRESET, CLEAR, NOTIFIER);
        // CONDITIONAL TIMING CHECK SIGNALS
        not g4(check1, PRESET);
        not g5(check2, D);
        // EXTERNAL TIMING CHECK SIGNALS
        // SPECIFY BLOCK
        specify
                specparam tSUd = 0 ;
                specparam tHDd = 0 ;
                specparam tRECpre = 0 ;
                specparam tPWclk = 0 ;
                specparam tHDpre = 0 ;
                specparam tPWpre = 0 ;
                specparam CLK_01_LH_Q = 0, CLK_01_HL_Q = 0 ;
                specparam PRE_10_LH_Q = 0, PRE_10_HL_Q = 0 ;
                (posedge CLK *> (Q : 1'b1)) = (CLK_01_LH_Q, CLK_01_HL_Q) ;
                (negedge PRE *> (Q : 1'b1)) = (PRE_10_LH_Q, PRE_10_HL_Q) ;
                $setup(posedge D &&& check1, posedge CLK, tSUd, NOTIFIER);
                $setup(negedge D &&& check1, posedge CLK, tSUd, NOTIFIER);
                $hold(posedge CLK, posedge D &&& check1, tHDd, NOTIFIER);
                $hold(posedge CLK, negedge D &&& check1, tHDd, NOTIFIER);
                $recovery(posedge PRE, posedge CLK &&& check2, tRECpre, NOTIFIER);
                $width(posedge CLK &&& check1, tPWclk, 0, NOTIFIER);
                $width(negedge CLK &&& check1, tPWclk, 0, NOTIFIER);
                $hold(posedge CLK, posedge PRE &&& check2, tHDpre, NOTIFIER);
                $hold(posedge CLK, negedge PRE &&& check2, tHDpre, NOTIFIER);
                $width(negedge PRE, tPWpre, 0, NOTIFIER);
        endspecify
endmodule

module fdf3a9(Q, D, CLK, PRE);
        output Q;
        input  D, CLK, PRE;
        supply0 CLEAR;
        reg NOTIFIER;
        not g1(PRESET, PRE);
        buf g2(Q, QOUT);
        ff g3(QOUT, D, CLK, PRESET, CLEAR, NOTIFIER);
        // CONDITIONAL TIMING CHECK SIGNALS
        not g4(check1, PRESET);
        not g5(check2, D);
        // EXTERNAL TIMING CHECK SIGNALS
        // SPECIFY BLOCK
        specify
                specparam tSUd = 0 ;
                specparam tHDd = 0 ;
                specparam tRECpre = 0 ;
                specparam tPWclk = 0 ;
                specparam tHDpre = 0 ;
                specparam tPWpre = 0 ;
                specparam CLK_01_LH_Q = 0, CLK_01_HL_Q = 0 ;
                specparam PRE_10_LH_Q = 0, PRE_10_HL_Q = 0 ;
                (posedge CLK *> (Q : 1'b1)) = (CLK_01_LH_Q, CLK_01_HL_Q) ;
                (negedge PRE *> (Q : 1'b1)) = (PRE_10_LH_Q, PRE_10_HL_Q) ;
                $setup(posedge D &&& check1, posedge CLK, tSUd, NOTIFIER);
                $setup(negedge D &&& check1, posedge CLK, tSUd, NOTIFIER);
                $hold(posedge CLK, posedge D &&& check1, tHDd, NOTIFIER);
                $hold(posedge CLK, negedge D &&& check1, tHDd, NOTIFIER);
                $recovery(posedge PRE, posedge CLK &&& check2, tRECpre, NOTIFIER);
                $width(posedge CLK &&& check1, tPWclk, 0, NOTIFIER);
                $width(negedge CLK &&& check1, tPWclk, 0, NOTIFIER);
                $hold(posedge CLK, posedge PRE &&& check2, tHDpre, NOTIFIER);
                $hold(posedge CLK, negedge PRE &&& check2, tHDpre, NOTIFIER);
                $width(negedge PRE, tPWpre, 0, NOTIFIER);
        endspecify
endmodule

module fdf3b1(Q, D, CLK, PRE);
        output Q;
        input  D, CLK, PRE;
        supply0 CLEAR;
        reg NOTIFIER;
        not g1(CLOCK, CLK);
        not g2(PRESET, PRE);
        buf g3(Q, QOUT);
        ff g4(QOUT, D, CLOCK, PRESET, CLEAR, NOTIFIER);
        // CONDITIONAL TIMING CHECK SIGNALS
        not g5(check1, PRESET);
        not g6(check2, D);
        // EXTERNAL TIMING CHECK SIGNALS
        // SPECIFY BLOCK
        specify
                specparam tSUd = 0 ;
                specparam tHDd = 0 ;
                specparam tRECpre = 0 ;
                specparam tPWclk = 0 ;
                specparam tHDpre = 0 ;
                specparam tPWpre = 0 ;
                specparam CLK_10_LH_Q = 0, CLK_10_HL_Q = 0 ;
                specparam PRE_10_LH_Q = 0, PRE_10_HL_Q = 0 ;
                (negedge CLK *> (Q : 1'b1)) = (CLK_10_LH_Q, CLK_10_HL_Q) ;
                (negedge PRE *> (Q : 1'b1)) = (PRE_10_LH_Q, PRE_10_HL_Q) ;
                $setup(posedge D &&& check1, negedge CLK, tSUd, NOTIFIER);
                $setup(negedge D &&& check1, negedge CLK, tSUd, NOTIFIER);
                $hold(negedge CLK, posedge D &&& check1, tHDd, NOTIFIER);
                $hold(negedge CLK, negedge D &&& check1, tHDd, NOTIFIER);
                $recovery(posedge PRE, negedge CLK &&& check2, tRECpre, NOTIFIER);
                $width(negedge CLK &&& check1, tPWclk, 0, NOTIFIER);
                $width(posedge CLK &&& check1, tPWclk, 0, NOTIFIER);
                $hold(negedge CLK, posedge PRE &&& check2, tHDpre, NOTIFIER);
                $hold(negedge CLK, negedge PRE &&& check2, tHDpre, NOTIFIER);
                $width(negedge PRE, tPWpre, 0, NOTIFIER);
        endspecify
endmodule

module fdf3b15(Q, D, CLK, PRE);
        output Q;
        input  D, CLK, PRE;
        supply0 CLEAR;
        reg NOTIFIER;
        not g1(CLOCK, CLK);
        not g2(PRESET, PRE);
        buf g3(Q, QOUT);
        ff g4(QOUT, D, CLOCK, PRESET, CLEAR, NOTIFIER);
        // CONDITIONAL TIMING CHECK SIGNALS
        not g5(check1, PRESET);
        not g6(check2, D);
        // EXTERNAL TIMING CHECK SIGNALS
        // SPECIFY BLOCK
        specify
                specparam tSUd = 0 ;
                specparam tHDd = 0 ;
                specparam tRECpre = 0 ;
                specparam tPWclk = 0 ;
                specparam tHDpre = 0 ;
                specparam tPWpre = 0 ;
                specparam CLK_10_LH_Q = 0, CLK_10_HL_Q = 0 ;
                specparam PRE_10_LH_Q = 0, PRE_10_HL_Q = 0 ;
                (negedge CLK *> (Q : 1'b1)) = (CLK_10_LH_Q, CLK_10_HL_Q) ;
                (negedge PRE *> (Q : 1'b1)) = (PRE_10_LH_Q, PRE_10_HL_Q) ;
                $setup(posedge D &&& check1, negedge CLK, tSUd, NOTIFIER);
                $setup(negedge D &&& check1, negedge CLK, tSUd, NOTIFIER);
                $hold(negedge CLK, posedge D &&& check1, tHDd, NOTIFIER);
                $hold(negedge CLK, negedge D &&& check1, tHDd, NOTIFIER);
                $recovery(posedge PRE, negedge CLK &&& check2, tRECpre, NOTIFIER);
                $width(negedge CLK &&& check1, tPWclk, 0, NOTIFIER);
                $width(posedge CLK &&& check1, tPWclk, 0, NOTIFIER);
                $hold(negedge CLK, posedge PRE &&& check2, tHDpre, NOTIFIER);
                $hold(negedge CLK, negedge PRE &&& check2, tHDpre, NOTIFIER);
                $width(negedge PRE, tPWpre, 0, NOTIFIER);
        endspecify
endmodule

module fdf3b2(Q, D, CLK, PRE);
        output Q;
        input  D, CLK, PRE;
        supply0 CLEAR;
        reg NOTIFIER;
        not g1(CLOCK, CLK);
        not g2(PRESET, PRE);
        buf g3(Q, QOUT);
        ff g4(QOUT, D, CLOCK, PRESET, CLEAR, NOTIFIER);
        // CONDITIONAL TIMING CHECK SIGNALS
        not g5(check1, PRESET);
        not g6(check2, D);
        // EXTERNAL TIMING CHECK SIGNALS
        // SPECIFY BLOCK
        specify
                specparam tSUd = 0 ;
                specparam tHDd = 0 ;
                specparam tRECpre = 0 ;
                specparam tPWclk = 0 ;
                specparam tHDpre = 0 ;
                specparam tPWpre = 0 ;
                specparam CLK_10_LH_Q = 0, CLK_10_HL_Q = 0 ;
                specparam PRE_10_LH_Q = 0, PRE_10_HL_Q = 0 ;
                (negedge CLK *> (Q : 1'b1)) = (CLK_10_LH_Q, CLK_10_HL_Q) ;
                (negedge PRE *> (Q : 1'b1)) = (PRE_10_LH_Q, PRE_10_HL_Q) ;
                $setup(posedge D &&& check1, negedge CLK, tSUd, NOTIFIER);
                $setup(negedge D &&& check1, negedge CLK, tSUd, NOTIFIER);
                $hold(negedge CLK, posedge D &&& check1, tHDd, NOTIFIER);
                $hold(negedge CLK, negedge D &&& check1, tHDd, NOTIFIER);
                $recovery(posedge PRE, negedge CLK &&& check2, tRECpre, NOTIFIER);
                $width(negedge CLK &&& check1, tPWclk, 0, NOTIFIER);
                $width(posedge CLK &&& check1, tPWclk, 0, NOTIFIER);
                $hold(negedge CLK, posedge PRE &&& check2, tHDpre, NOTIFIER);
                $hold(negedge CLK, negedge PRE &&& check2, tHDpre, NOTIFIER);
                $width(negedge PRE, tPWpre, 0, NOTIFIER);
        endspecify
endmodule

module fdf3b3(Q, D, CLK, PRE);
        output Q;
        input  D, CLK, PRE;
        supply0 CLEAR;
        reg NOTIFIER;
        not g1(CLOCK, CLK);
        not g2(PRESET, PRE);
        buf g3(Q, QOUT);
        ff g4(QOUT, D, CLOCK, PRESET, CLEAR, NOTIFIER);
        // CONDITIONAL TIMING CHECK SIGNALS
        not g5(check1, PRESET);
        not g6(check2, D);
        // EXTERNAL TIMING CHECK SIGNALS
        // SPECIFY BLOCK
        specify
                specparam tSUd = 0 ;
                specparam tHDd = 0 ;
                specparam tRECpre = 0 ;
                specparam tPWclk = 0 ;
                specparam tHDpre = 0 ;
                specparam tPWpre = 0 ;
                specparam CLK_10_LH_Q = 0, CLK_10_HL_Q = 0 ;
                specparam PRE_10_LH_Q = 0, PRE_10_HL_Q = 0 ;
                (negedge CLK *> (Q : 1'b1)) = (CLK_10_LH_Q, CLK_10_HL_Q) ;
                (negedge PRE *> (Q : 1'b1)) = (PRE_10_LH_Q, PRE_10_HL_Q) ;
                $setup(posedge D &&& check1, negedge CLK, tSUd, NOTIFIER);
                $setup(negedge D &&& check1, negedge CLK, tSUd, NOTIFIER);
                $hold(negedge CLK, posedge D &&& check1, tHDd, NOTIFIER);
                $hold(negedge CLK, negedge D &&& check1, tHDd, NOTIFIER);
                $recovery(posedge PRE, negedge CLK &&& check2, tRECpre, NOTIFIER);
                $width(negedge CLK &&& check1, tPWclk, 0, NOTIFIER);
                $width(posedge CLK &&& check1, tPWclk, 0, NOTIFIER);
                $hold(negedge CLK, posedge PRE &&& check2, tHDpre, NOTIFIER);
                $hold(negedge CLK, negedge PRE &&& check2, tHDpre, NOTIFIER);
                $width(negedge PRE, tPWpre, 0, NOTIFIER);
        endspecify
endmodule

module fdf3b6(Q, D, CLK, PRE);
        output Q;
        input  D, CLK, PRE;
        supply0 CLEAR;
        reg NOTIFIER;
        not g1(CLOCK, CLK);
        not g2(PRESET, PRE);
        buf g3(Q, QOUT);
        ff g4(QOUT, D, CLOCK, PRESET, CLEAR, NOTIFIER);
        // CONDITIONAL TIMING CHECK SIGNALS
        not g5(check1, PRESET);
        not g6(check2, D);
        // EXTERNAL TIMING CHECK SIGNALS
        // SPECIFY BLOCK
        specify
                specparam tSUd = 0 ;
                specparam tHDd = 0 ;
                specparam tRECpre = 0 ;
                specparam tPWclk = 0 ;
                specparam tHDpre = 0 ;
                specparam tPWpre = 0 ;
                specparam CLK_10_LH_Q = 0, CLK_10_HL_Q = 0 ;
                specparam PRE_10_LH_Q = 0, PRE_10_HL_Q = 0 ;
                (negedge CLK *> (Q : 1'b1)) = (CLK_10_LH_Q, CLK_10_HL_Q) ;
                (negedge PRE *> (Q : 1'b1)) = (PRE_10_LH_Q, PRE_10_HL_Q) ;
                $setup(posedge D &&& check1, negedge CLK, tSUd, NOTIFIER);
                $setup(negedge D &&& check1, negedge CLK, tSUd, NOTIFIER);
                $hold(negedge CLK, posedge D &&& check1, tHDd, NOTIFIER);
                $hold(negedge CLK, negedge D &&& check1, tHDd, NOTIFIER);
                $recovery(posedge PRE, negedge CLK &&& check2, tRECpre, NOTIFIER);
                $width(negedge CLK &&& check1, tPWclk, 0, NOTIFIER);
                $width(posedge CLK &&& check1, tPWclk, 0, NOTIFIER);
                $hold(negedge CLK, posedge PRE &&& check2, tHDpre, NOTIFIER);
                $hold(negedge CLK, negedge PRE &&& check2, tHDpre, NOTIFIER);
                $width(negedge PRE, tPWpre, 0, NOTIFIER);
        endspecify
endmodule

module fdf3b9(Q, D, CLK, PRE);
        output Q;
        input  D, CLK, PRE;
        supply0 CLEAR;
        reg NOTIFIER;
        not g1(CLOCK, CLK);
        not g2(PRESET, PRE);
        buf g3(Q, QOUT);
        ff g4(QOUT, D, CLOCK, PRESET, CLEAR, NOTIFIER);
        // CONDITIONAL TIMING CHECK SIGNALS
        not g5(check1, PRESET);
        not g6(check2, D);
        // EXTERNAL TIMING CHECK SIGNALS
        // SPECIFY BLOCK
        specify
                specparam tSUd = 0 ;
                specparam tHDd = 0 ;
                specparam tRECpre = 0 ;
                specparam tPWclk = 0 ;
                specparam tHDpre = 0 ;
                specparam tPWpre = 0 ;
                specparam CLK_10_LH_Q = 0, CLK_10_HL_Q = 0 ;
                specparam PRE_10_LH_Q = 0, PRE_10_HL_Q = 0 ;
                (negedge CLK *> (Q : 1'b1)) = (CLK_10_LH_Q, CLK_10_HL_Q) ;
                (negedge PRE *> (Q : 1'b1)) = (PRE_10_LH_Q, PRE_10_HL_Q) ;
                $setup(posedge D &&& check1, negedge CLK, tSUd, NOTIFIER);
                $setup(negedge D &&& check1, negedge CLK, tSUd, NOTIFIER);
                $hold(negedge CLK, posedge D &&& check1, tHDd, NOTIFIER);
                $hold(negedge CLK, negedge D &&& check1, tHDd, NOTIFIER);
                $recovery(posedge PRE, negedge CLK &&& check2, tRECpre, NOTIFIER);
                $width(negedge CLK &&& check1, tPWclk, 0, NOTIFIER);
                $width(posedge CLK &&& check1, tPWclk, 0, NOTIFIER);
                $hold(negedge CLK, posedge PRE &&& check2, tHDpre, NOTIFIER);
                $hold(negedge CLK, negedge PRE &&& check2, tHDpre, NOTIFIER);
                $width(negedge PRE, tPWpre, 0, NOTIFIER);
        endspecify
endmodule

module fdmf1a1(Q, D0, D1, S, CLK);
        output Q;
        input  D0, D1, S, CLK;
        supply0 PRESET, CLEAR;
        reg NOTIFIER;
        mux g1(DATA, S, D1, D0);
        buf g2(Q, QOUT);
        ff g3(QOUT, DATA, CLK, PRESET, CLEAR, NOTIFIER);
        // EXTERNAL TIMING CHECK SIGNALS
        xtc_xor g4(xcheck1, D0, D1);
        xtc_buf g6(xcheck2, S);
        xtc_not g8(xcheck3, S);
        // SPECIFY BLOCK
        specify
                specparam tSUd = 0 ;
                specparam tHDd = 0 ;
                specparam tPWclk = 0 ;
                specparam CLK_01_LH_Q = 0, CLK_01_HL_Q = 0 ;
                (posedge CLK *> (Q : 1'b1)) = (CLK_01_LH_Q, CLK_01_HL_Q) ;
                $setup(posedge S &&& xcheck1, posedge CLK, tSUd, NOTIFIER);
                $setup(negedge S &&& xcheck1, posedge CLK, tSUd, NOTIFIER);
                $setup(posedge D1 &&& xcheck2, posedge CLK, tSUd, NOTIFIER);
                $setup(negedge D1 &&& xcheck2, posedge CLK, tSUd, NOTIFIER);
                $setup(posedge D0 &&& xcheck3, posedge CLK, tSUd, NOTIFIER);
                $setup(negedge D0 &&& xcheck3, posedge CLK, tSUd, NOTIFIER);
                $hold(posedge CLK, posedge S &&& xcheck1, tHDd, NOTIFIER);
                $hold(posedge CLK, negedge S &&& xcheck1, tHDd, NOTIFIER);
                $hold(posedge CLK, posedge D1 &&& xcheck2, tHDd, NOTIFIER);
                $hold(posedge CLK, negedge D1 &&& xcheck2, tHDd, NOTIFIER);
                $hold(posedge CLK, posedge D0 &&& xcheck3, tHDd, NOTIFIER);
                $hold(posedge CLK, negedge D0 &&& xcheck3, tHDd, NOTIFIER);
                $width(posedge CLK, tPWclk, 0, NOTIFIER);
                $width(negedge CLK, tPWclk, 0, NOTIFIER);
        endspecify
endmodule

module fdmf1a15(Q, D0, D1, S, CLK);
        output Q;
        input  D0, D1, S, CLK;
        supply0 PRESET, CLEAR;
        reg NOTIFIER;
        mux g1(DATA, S, D1, D0);
        buf g2(Q, QOUT);
        ff g3(QOUT, DATA, CLK, PRESET, CLEAR, NOTIFIER);
        // EXTERNAL TIMING CHECK SIGNALS
        xtc_xor g4(xcheck1, D0, D1);
        xtc_buf g6(xcheck2, S);
        xtc_not g8(xcheck3, S);
        // SPECIFY BLOCK
        specify
                specparam tSUd = 0 ;
                specparam tHDd = 0 ;
                specparam tPWclk = 0 ;
                specparam CLK_01_LH_Q = 0, CLK_01_HL_Q = 0 ;
                (posedge CLK *> (Q : 1'b1)) = (CLK_01_LH_Q, CLK_01_HL_Q) ;
                $setup(posedge S &&& xcheck1, posedge CLK, tSUd, NOTIFIER);
                $setup(negedge S &&& xcheck1, posedge CLK, tSUd, NOTIFIER);
                $setup(posedge D1 &&& xcheck2, posedge CLK, tSUd, NOTIFIER);
                $setup(negedge D1 &&& xcheck2, posedge CLK, tSUd, NOTIFIER);
                $setup(posedge D0 &&& xcheck3, posedge CLK, tSUd, NOTIFIER);
                $setup(negedge D0 &&& xcheck3, posedge CLK, tSUd, NOTIFIER);
                $hold(posedge CLK, posedge S &&& xcheck1, tHDd, NOTIFIER);
                $hold(posedge CLK, negedge S &&& xcheck1, tHDd, NOTIFIER);
                $hold(posedge CLK, posedge D1 &&& xcheck2, tHDd, NOTIFIER);
                $hold(posedge CLK, negedge D1 &&& xcheck2, tHDd, NOTIFIER);
                $hold(posedge CLK, posedge D0 &&& xcheck3, tHDd, NOTIFIER);
                $hold(posedge CLK, negedge D0 &&& xcheck3, tHDd, NOTIFIER);
                $width(posedge CLK, tPWclk, 0, NOTIFIER);
                $width(negedge CLK, tPWclk, 0, NOTIFIER);
        endspecify
endmodule

module fdmf1a2(Q, D0, D1, S, CLK);
        output Q;
        input  D0, D1, S, CLK;
        supply0 PRESET, CLEAR;
        reg NOTIFIER;
        mux g1(DATA, S, D1, D0);
        buf g2(Q, QOUT);
        ff g3(QOUT, DATA, CLK, PRESET, CLEAR, NOTIFIER);
        // EXTERNAL TIMING CHECK SIGNALS
        xtc_xor g4(xcheck1, D0, D1);
        xtc_buf g6(xcheck2, S);
        xtc_not g8(xcheck3, S);
        // SPECIFY BLOCK
        specify
                specparam tSUd = 0 ;
                specparam tHDd = 0 ;
                specparam tPWclk = 0 ;
                specparam CLK_01_LH_Q = 0, CLK_01_HL_Q = 0 ;
                (posedge CLK *> (Q : 1'b1)) = (CLK_01_LH_Q, CLK_01_HL_Q) ;
                $setup(posedge S &&& xcheck1, posedge CLK, tSUd, NOTIFIER);
                $setup(negedge S &&& xcheck1, posedge CLK, tSUd, NOTIFIER);
                $setup(posedge D1 &&& xcheck2, posedge CLK, tSUd, NOTIFIER);
                $setup(negedge D1 &&& xcheck2, posedge CLK, tSUd, NOTIFIER);
                $setup(posedge D0 &&& xcheck3, posedge CLK, tSUd, NOTIFIER);
                $setup(negedge D0 &&& xcheck3, posedge CLK, tSUd, NOTIFIER);
                $hold(posedge CLK, posedge S &&& xcheck1, tHDd, NOTIFIER);
                $hold(posedge CLK, negedge S &&& xcheck1, tHDd, NOTIFIER);
                $hold(posedge CLK, posedge D1 &&& xcheck2, tHDd, NOTIFIER);
                $hold(posedge CLK, negedge D1 &&& xcheck2, tHDd, NOTIFIER);
                $hold(posedge CLK, posedge D0 &&& xcheck3, tHDd, NOTIFIER);
                $hold(posedge CLK, negedge D0 &&& xcheck3, tHDd, NOTIFIER);
                $width(posedge CLK, tPWclk, 0, NOTIFIER);
                $width(negedge CLK, tPWclk, 0, NOTIFIER);
        endspecify
endmodule

module fdmf1a3(Q, D0, D1, S, CLK);
        output Q;
        input  D0, D1, S, CLK;
        supply0 PRESET, CLEAR;
        reg NOTIFIER;
        mux g1(DATA, S, D1, D0);
        buf g2(Q, QOUT);
        ff g3(QOUT, DATA, CLK, PRESET, CLEAR, NOTIFIER);
        // EXTERNAL TIMING CHECK SIGNALS
        xtc_xor g4(xcheck1, D0, D1);
        xtc_buf g6(xcheck2, S);
        xtc_not g8(xcheck3, S);
        // SPECIFY BLOCK
        specify
                specparam tSUd = 0 ;
                specparam tHDd = 0 ;
                specparam tPWclk = 0 ;
                specparam CLK_01_LH_Q = 0, CLK_01_HL_Q = 0 ;
                (posedge CLK *> (Q : 1'b1)) = (CLK_01_LH_Q, CLK_01_HL_Q) ;
                $setup(posedge S &&& xcheck1, posedge CLK, tSUd, NOTIFIER);
                $setup(negedge S &&& xcheck1, posedge CLK, tSUd, NOTIFIER);
                $setup(posedge D1 &&& xcheck2, posedge CLK, tSUd, NOTIFIER);
                $setup(negedge D1 &&& xcheck2, posedge CLK, tSUd, NOTIFIER);
                $setup(posedge D0 &&& xcheck3, posedge CLK, tSUd, NOTIFIER);
                $setup(negedge D0 &&& xcheck3, posedge CLK, tSUd, NOTIFIER);
                $hold(posedge CLK, posedge S &&& xcheck1, tHDd, NOTIFIER);
                $hold(posedge CLK, negedge S &&& xcheck1, tHDd, NOTIFIER);
                $hold(posedge CLK, posedge D1 &&& xcheck2, tHDd, NOTIFIER);
                $hold(posedge CLK, negedge D1 &&& xcheck2, tHDd, NOTIFIER);
                $hold(posedge CLK, posedge D0 &&& xcheck3, tHDd, NOTIFIER);
                $hold(posedge CLK, negedge D0 &&& xcheck3, tHDd, NOTIFIER);
                $width(posedge CLK, tPWclk, 0, NOTIFIER);
                $width(negedge CLK, tPWclk, 0, NOTIFIER);
        endspecify
endmodule

module fdmf1a6(Q, D0, D1, S, CLK);
        output Q;
        input  D0, D1, S, CLK;
        supply0 PRESET, CLEAR;
        reg NOTIFIER;
        mux g1(DATA, S, D1, D0);
        buf g2(Q, QOUT);
        ff g3(QOUT, DATA, CLK, PRESET, CLEAR, NOTIFIER);
        // EXTERNAL TIMING CHECK SIGNALS
        xtc_xor g4(xcheck1, D0, D1);
        xtc_buf g6(xcheck2, S);
        xtc_not g8(xcheck3, S);
        // SPECIFY BLOCK
        specify
                specparam tSUd = 0 ;
                specparam tHDd = 0 ;
                specparam tPWclk = 0 ;
                specparam CLK_01_LH_Q = 0, CLK_01_HL_Q = 0 ;
                (posedge CLK *> (Q : 1'b1)) = (CLK_01_LH_Q, CLK_01_HL_Q) ;
                $setup(posedge S &&& xcheck1, posedge CLK, tSUd, NOTIFIER);
                $setup(negedge S &&& xcheck1, posedge CLK, tSUd, NOTIFIER);
                $setup(posedge D1 &&& xcheck2, posedge CLK, tSUd, NOTIFIER);
                $setup(negedge D1 &&& xcheck2, posedge CLK, tSUd, NOTIFIER);
                $setup(posedge D0 &&& xcheck3, posedge CLK, tSUd, NOTIFIER);
                $setup(negedge D0 &&& xcheck3, posedge CLK, tSUd, NOTIFIER);
                $hold(posedge CLK, posedge S &&& xcheck1, tHDd, NOTIFIER);
                $hold(posedge CLK, negedge S &&& xcheck1, tHDd, NOTIFIER);
                $hold(posedge CLK, posedge D1 &&& xcheck2, tHDd, NOTIFIER);
                $hold(posedge CLK, negedge D1 &&& xcheck2, tHDd, NOTIFIER);
                $hold(posedge CLK, posedge D0 &&& xcheck3, tHDd, NOTIFIER);
                $hold(posedge CLK, negedge D0 &&& xcheck3, tHDd, NOTIFIER);
                $width(posedge CLK, tPWclk, 0, NOTIFIER);
                $width(negedge CLK, tPWclk, 0, NOTIFIER);
        endspecify
endmodule

module fdmf1a9(Q, D0, D1, S, CLK);
        output Q;
        input  D0, D1, S, CLK;
        supply0 PRESET, CLEAR;
        reg NOTIFIER;
        mux g1(DATA, S, D1, D0);
        buf g2(Q, QOUT);
        ff g3(QOUT, DATA, CLK, PRESET, CLEAR, NOTIFIER);
        // EXTERNAL TIMING CHECK SIGNALS
        xtc_xor g4(xcheck1, D0, D1);
        xtc_buf g6(xcheck2, S);
        xtc_not g8(xcheck3, S);
        // SPECIFY BLOCK
        specify
                specparam tSUd = 0 ;
                specparam tHDd = 0 ;
                specparam tPWclk = 0 ;
                specparam CLK_01_LH_Q = 0, CLK_01_HL_Q = 0 ;
                (posedge CLK *> (Q : 1'b1)) = (CLK_01_LH_Q, CLK_01_HL_Q) ;
                $setup(posedge S &&& xcheck1, posedge CLK, tSUd, NOTIFIER);
                $setup(negedge S &&& xcheck1, posedge CLK, tSUd, NOTIFIER);
                $setup(posedge D1 &&& xcheck2, posedge CLK, tSUd, NOTIFIER);
                $setup(negedge D1 &&& xcheck2, posedge CLK, tSUd, NOTIFIER);
                $setup(posedge D0 &&& xcheck3, posedge CLK, tSUd, NOTIFIER);
                $setup(negedge D0 &&& xcheck3, posedge CLK, tSUd, NOTIFIER);
                $hold(posedge CLK, posedge S &&& xcheck1, tHDd, NOTIFIER);
                $hold(posedge CLK, negedge S &&& xcheck1, tHDd, NOTIFIER);
                $hold(posedge CLK, posedge D1 &&& xcheck2, tHDd, NOTIFIER);
                $hold(posedge CLK, negedge D1 &&& xcheck2, tHDd, NOTIFIER);
                $hold(posedge CLK, posedge D0 &&& xcheck3, tHDd, NOTIFIER);
                $hold(posedge CLK, negedge D0 &&& xcheck3, tHDd, NOTIFIER);
                $width(posedge CLK, tPWclk, 0, NOTIFIER);
                $width(negedge CLK, tPWclk, 0, NOTIFIER);
        endspecify
endmodule

module fdmf1b1(Q, D0, D1, S, CLK);
        output Q;
        input  D0, D1, S, CLK;
        supply0 PRESET, CLEAR;
        reg NOTIFIER;
        mux g1(DATA, S, D1, D0);
        not g2(CLOCK, CLK);
        buf g3(Q, QOUT);
        ff g4(QOUT, DATA, CLOCK, PRESET, CLEAR, NOTIFIER);
        // EXTERNAL TIMING CHECK SIGNALS
        xtc_xor g5(xcheck1, D0, D1);
        xtc_buf g7(xcheck2, S);
        xtc_not g9(xcheck3, S);
        // SPECIFY BLOCK
        specify
                specparam tSUd = 0 ;
                specparam tHDd = 0 ;
                specparam tPWclk = 0 ;
                specparam CLK_10_LH_Q = 0, CLK_10_HL_Q = 0 ;
                (negedge CLK *> (Q : 1'b1)) = (CLK_10_LH_Q, CLK_10_HL_Q) ;
                $setup(posedge S &&& xcheck1, negedge CLK, tSUd, NOTIFIER);
                $setup(negedge S &&& xcheck1, negedge CLK, tSUd, NOTIFIER);
                $setup(posedge D1 &&& xcheck2, negedge CLK, tSUd, NOTIFIER);
                $setup(negedge D1 &&& xcheck2, negedge CLK, tSUd, NOTIFIER);
                $setup(posedge D0 &&& xcheck3, negedge CLK, tSUd, NOTIFIER);
                $setup(negedge D0 &&& xcheck3, negedge CLK, tSUd, NOTIFIER);
                $hold(negedge CLK, posedge S &&& xcheck1, tHDd, NOTIFIER);
                $hold(negedge CLK, negedge S &&& xcheck1, tHDd, NOTIFIER);
                $hold(negedge CLK, posedge D1 &&& xcheck2, tHDd, NOTIFIER);
                $hold(negedge CLK, negedge D1 &&& xcheck2, tHDd, NOTIFIER);
                $hold(negedge CLK, posedge D0 &&& xcheck3, tHDd, NOTIFIER);
                $hold(negedge CLK, negedge D0 &&& xcheck3, tHDd, NOTIFIER);
                $width(negedge CLK, tPWclk, 0, NOTIFIER);
                $width(posedge CLK, tPWclk, 0, NOTIFIER);
        endspecify
endmodule

module fdmf1b15(Q, D0, D1, S, CLK);
        output Q;
        input  D0, D1, S, CLK;
        supply0 PRESET, CLEAR;
        reg NOTIFIER;
        mux g1(DATA, S, D1, D0);
        not g2(CLOCK, CLK);
        buf g3(Q, QOUT);
        ff g4(QOUT, DATA, CLOCK, PRESET, CLEAR, NOTIFIER);
        // EXTERNAL TIMING CHECK SIGNALS
        xtc_xor g5(xcheck1, D0, D1);
        xtc_buf g7(xcheck2, S);
        xtc_not g9(xcheck3, S);
        // SPECIFY BLOCK
        specify
                specparam tSUd = 0 ;
                specparam tHDd = 0 ;
                specparam tPWclk = 0 ;
                specparam CLK_10_LH_Q = 0, CLK_10_HL_Q = 0 ;
                (negedge CLK *> (Q : 1'b1)) = (CLK_10_LH_Q, CLK_10_HL_Q) ;
                $setup(posedge S &&& xcheck1, negedge CLK, tSUd, NOTIFIER);
                $setup(negedge S &&& xcheck1, negedge CLK, tSUd, NOTIFIER);
                $setup(posedge D1 &&& xcheck2, negedge CLK, tSUd, NOTIFIER);
                $setup(negedge D1 &&& xcheck2, negedge CLK, tSUd, NOTIFIER);
                $setup(posedge D0 &&& xcheck3, negedge CLK, tSUd, NOTIFIER);
                $setup(negedge D0 &&& xcheck3, negedge CLK, tSUd, NOTIFIER);
                $hold(negedge CLK, posedge S &&& xcheck1, tHDd, NOTIFIER);
                $hold(negedge CLK, negedge S &&& xcheck1, tHDd, NOTIFIER);
                $hold(negedge CLK, posedge D1 &&& xcheck2, tHDd, NOTIFIER);
                $hold(negedge CLK, negedge D1 &&& xcheck2, tHDd, NOTIFIER);
                $hold(negedge CLK, posedge D0 &&& xcheck3, tHDd, NOTIFIER);
                $hold(negedge CLK, negedge D0 &&& xcheck3, tHDd, NOTIFIER);
                $width(negedge CLK, tPWclk, 0, NOTIFIER);
                $width(posedge CLK, tPWclk, 0, NOTIFIER);
        endspecify
endmodule

module fdmf1b2(Q, D0, D1, S, CLK);
        output Q;
        input  D0, D1, S, CLK;
        supply0 PRESET, CLEAR;
        reg NOTIFIER;
        mux g1(DATA, S, D1, D0);
        not g2(CLOCK, CLK);
        buf g3(Q, QOUT);
        ff g4(QOUT, DATA, CLOCK, PRESET, CLEAR, NOTIFIER);
        // EXTERNAL TIMING CHECK SIGNALS
        xtc_xor g5(xcheck1, D0, D1);
        xtc_buf g7(xcheck2, S);
        xtc_not g9(xcheck3, S);
        // SPECIFY BLOCK
        specify
                specparam tSUd = 0 ;
                specparam tHDd = 0 ;
                specparam tPWclk = 0 ;
                specparam CLK_10_LH_Q = 0, CLK_10_HL_Q = 0 ;
                (negedge CLK *> (Q : 1'b1)) = (CLK_10_LH_Q, CLK_10_HL_Q) ;
                $setup(posedge S &&& xcheck1, negedge CLK, tSUd, NOTIFIER);
                $setup(negedge S &&& xcheck1, negedge CLK, tSUd, NOTIFIER);
                $setup(posedge D1 &&& xcheck2, negedge CLK, tSUd, NOTIFIER);
                $setup(negedge D1 &&& xcheck2, negedge CLK, tSUd, NOTIFIER);
                $setup(posedge D0 &&& xcheck3, negedge CLK, tSUd, NOTIFIER);
                $setup(negedge D0 &&& xcheck3, negedge CLK, tSUd, NOTIFIER);
                $hold(negedge CLK, posedge S &&& xcheck1, tHDd, NOTIFIER);
                $hold(negedge CLK, negedge S &&& xcheck1, tHDd, NOTIFIER);
                $hold(negedge CLK, posedge D1 &&& xcheck2, tHDd, NOTIFIER);
                $hold(negedge CLK, negedge D1 &&& xcheck2, tHDd, NOTIFIER);
                $hold(negedge CLK, posedge D0 &&& xcheck3, tHDd, NOTIFIER);
                $hold(negedge CLK, negedge D0 &&& xcheck3, tHDd, NOTIFIER);
                $width(negedge CLK, tPWclk, 0, NOTIFIER);
                $width(posedge CLK, tPWclk, 0, NOTIFIER);
        endspecify
endmodule

module fdmf1b3(Q, D0, D1, S, CLK);
        output Q;
        input  D0, D1, S, CLK;
        supply0 PRESET, CLEAR;
        reg NOTIFIER;
        mux g1(DATA, S, D1, D0);
        not g2(CLOCK, CLK);
        buf g3(Q, QOUT);
        ff g4(QOUT, DATA, CLOCK, PRESET, CLEAR, NOTIFIER);
        // EXTERNAL TIMING CHECK SIGNALS
        xtc_xor g5(xcheck1, D0, D1);
        xtc_buf g7(xcheck2, S);
        xtc_not g9(xcheck3, S);
        // SPECIFY BLOCK
        specify
                specparam tSUd = 0 ;
                specparam tHDd = 0 ;
                specparam tPWclk = 0 ;
                specparam CLK_10_LH_Q = 0, CLK_10_HL_Q = 0 ;
                (negedge CLK *> (Q : 1'b1)) = (CLK_10_LH_Q, CLK_10_HL_Q) ;
                $setup(posedge S &&& xcheck1, negedge CLK, tSUd, NOTIFIER);
                $setup(negedge S &&& xcheck1, negedge CLK, tSUd, NOTIFIER);
                $setup(posedge D1 &&& xcheck2, negedge CLK, tSUd, NOTIFIER);
                $setup(negedge D1 &&& xcheck2, negedge CLK, tSUd, NOTIFIER);
                $setup(posedge D0 &&& xcheck3, negedge CLK, tSUd, NOTIFIER);
                $setup(negedge D0 &&& xcheck3, negedge CLK, tSUd, NOTIFIER);
                $hold(negedge CLK, posedge S &&& xcheck1, tHDd, NOTIFIER);
                $hold(negedge CLK, negedge S &&& xcheck1, tHDd, NOTIFIER);
                $hold(negedge CLK, posedge D1 &&& xcheck2, tHDd, NOTIFIER);
                $hold(negedge CLK, negedge D1 &&& xcheck2, tHDd, NOTIFIER);
                $hold(negedge CLK, posedge D0 &&& xcheck3, tHDd, NOTIFIER);
                $hold(negedge CLK, negedge D0 &&& xcheck3, tHDd, NOTIFIER);
                $width(negedge CLK, tPWclk, 0, NOTIFIER);
                $width(posedge CLK, tPWclk, 0, NOTIFIER);
        endspecify
endmodule

module fdmf1b6(Q, D0, D1, S, CLK);
        output Q;
        input  D0, D1, S, CLK;
        supply0 PRESET, CLEAR;
        reg NOTIFIER;
        mux g1(DATA, S, D1, D0);
        not g2(CLOCK, CLK);
        buf g3(Q, QOUT);
        ff g4(QOUT, DATA, CLOCK, PRESET, CLEAR, NOTIFIER);
        // EXTERNAL TIMING CHECK SIGNALS
        xtc_xor g5(xcheck1, D0, D1);
        xtc_buf g7(xcheck2, S);
        xtc_not g9(xcheck3, S);
        // SPECIFY BLOCK
        specify
                specparam tSUd = 0 ;
                specparam tHDd = 0 ;
                specparam tPWclk = 0 ;
                specparam CLK_10_LH_Q = 0, CLK_10_HL_Q = 0 ;
                (negedge CLK *> (Q : 1'b1)) = (CLK_10_LH_Q, CLK_10_HL_Q) ;
                $setup(posedge S &&& xcheck1, negedge CLK, tSUd, NOTIFIER);
                $setup(negedge S &&& xcheck1, negedge CLK, tSUd, NOTIFIER);
                $setup(posedge D1 &&& xcheck2, negedge CLK, tSUd, NOTIFIER);
                $setup(negedge D1 &&& xcheck2, negedge CLK, tSUd, NOTIFIER);
                $setup(posedge D0 &&& xcheck3, negedge CLK, tSUd, NOTIFIER);
                $setup(negedge D0 &&& xcheck3, negedge CLK, tSUd, NOTIFIER);
                $hold(negedge CLK, posedge S &&& xcheck1, tHDd, NOTIFIER);
                $hold(negedge CLK, negedge S &&& xcheck1, tHDd, NOTIFIER);
                $hold(negedge CLK, posedge D1 &&& xcheck2, tHDd, NOTIFIER);
                $hold(negedge CLK, negedge D1 &&& xcheck2, tHDd, NOTIFIER);
                $hold(negedge CLK, posedge D0 &&& xcheck3, tHDd, NOTIFIER);
                $hold(negedge CLK, negedge D0 &&& xcheck3, tHDd, NOTIFIER);
                $width(negedge CLK, tPWclk, 0, NOTIFIER);
                $width(posedge CLK, tPWclk, 0, NOTIFIER);
        endspecify
endmodule

module fdmf1b9(Q, D0, D1, S, CLK);
        output Q;
        input  D0, D1, S, CLK;
        supply0 PRESET, CLEAR;
        reg NOTIFIER;
        mux g1(DATA, S, D1, D0);
        not g2(CLOCK, CLK);
        buf g3(Q, QOUT);
        ff g4(QOUT, DATA, CLOCK, PRESET, CLEAR, NOTIFIER);
        // EXTERNAL TIMING CHECK SIGNALS
        xtc_xor g5(xcheck1, D0, D1);
        xtc_buf g7(xcheck2, S);
        xtc_not g9(xcheck3, S);
        // SPECIFY BLOCK
        specify
                specparam tSUd = 0 ;
                specparam tHDd = 0 ;
                specparam tPWclk = 0 ;
                specparam CLK_10_LH_Q = 0, CLK_10_HL_Q = 0 ;
                (negedge CLK *> (Q : 1'b1)) = (CLK_10_LH_Q, CLK_10_HL_Q) ;
                $setup(posedge S &&& xcheck1, negedge CLK, tSUd, NOTIFIER);
                $setup(negedge S &&& xcheck1, negedge CLK, tSUd, NOTIFIER);
                $setup(posedge D1 &&& xcheck2, negedge CLK, tSUd, NOTIFIER);
                $setup(negedge D1 &&& xcheck2, negedge CLK, tSUd, NOTIFIER);
                $setup(posedge D0 &&& xcheck3, negedge CLK, tSUd, NOTIFIER);
                $setup(negedge D0 &&& xcheck3, negedge CLK, tSUd, NOTIFIER);
                $hold(negedge CLK, posedge S &&& xcheck1, tHDd, NOTIFIER);
                $hold(negedge CLK, negedge S &&& xcheck1, tHDd, NOTIFIER);
                $hold(negedge CLK, posedge D1 &&& xcheck2, tHDd, NOTIFIER);
                $hold(negedge CLK, negedge D1 &&& xcheck2, tHDd, NOTIFIER);
                $hold(negedge CLK, posedge D0 &&& xcheck3, tHDd, NOTIFIER);
                $hold(negedge CLK, negedge D0 &&& xcheck3, tHDd, NOTIFIER);
                $width(negedge CLK, tPWclk, 0, NOTIFIER);
                $width(posedge CLK, tPWclk, 0, NOTIFIER);
        endspecify
endmodule

module fdmf1c1(QN, D0, D1, S, CLK);
        output QN;
        input  D0, D1, S, CLK;
        supply0 PRESET, CLEAR;
        reg NOTIFIER;
        mux g1(DATA, S, D1, D0);
        not g2(QN, QOUT);
        ff g3(QOUT, DATA, CLK, PRESET, CLEAR, NOTIFIER);
        // EXTERNAL TIMING CHECK SIGNALS
        xtc_xor g4(xcheck1, D0, D1);
        xtc_buf g6(xcheck2, S);
        xtc_not g8(xcheck3, S);
        // SPECIFY BLOCK
        specify
                specparam tSUd = 0 ;
                specparam tHDd = 0 ;
                specparam tPWclk = 0 ;
                specparam CLK_01_LH_QN = 0, CLK_01_HL_QN = 0 ;
                (posedge CLK *> (QN : 1'b1)) = (CLK_01_LH_QN, CLK_01_HL_QN) ;
                $setup(posedge S &&& xcheck1, posedge CLK, tSUd, NOTIFIER);
                $setup(negedge S &&& xcheck1, posedge CLK, tSUd, NOTIFIER);
                $setup(posedge D1 &&& xcheck2, posedge CLK, tSUd, NOTIFIER);
                $setup(negedge D1 &&& xcheck2, posedge CLK, tSUd, NOTIFIER);
                $setup(posedge D0 &&& xcheck3, posedge CLK, tSUd, NOTIFIER);
                $setup(negedge D0 &&& xcheck3, posedge CLK, tSUd, NOTIFIER);
                $hold(posedge CLK, posedge S &&& xcheck1, tHDd, NOTIFIER);
                $hold(posedge CLK, negedge S &&& xcheck1, tHDd, NOTIFIER);
                $hold(posedge CLK, posedge D1 &&& xcheck2, tHDd, NOTIFIER);
                $hold(posedge CLK, negedge D1 &&& xcheck2, tHDd, NOTIFIER);
                $hold(posedge CLK, posedge D0 &&& xcheck3, tHDd, NOTIFIER);
                $hold(posedge CLK, negedge D0 &&& xcheck3, tHDd, NOTIFIER);
                $width(posedge CLK, tPWclk, 0, NOTIFIER);
                $width(negedge CLK, tPWclk, 0, NOTIFIER);
        endspecify
endmodule

module fdmf1c15(QN, D0, D1, S, CLK);
        output QN;
        input  D0, D1, S, CLK;
        supply0 PRESET, CLEAR;
        reg NOTIFIER;
        mux g1(DATA, S, D1, D0);
        not g2(QN, QOUT);
        ff g3(QOUT, DATA, CLK, PRESET, CLEAR, NOTIFIER);
        // EXTERNAL TIMING CHECK SIGNALS
        xtc_xor g4(xcheck1, D0, D1);
        xtc_buf g6(xcheck2, S);
        xtc_not g8(xcheck3, S);
        // SPECIFY BLOCK
        specify
                specparam tSUd = 0 ;
                specparam tHDd = 0 ;
                specparam tPWclk = 0 ;
                specparam CLK_01_LH_QN = 0, CLK_01_HL_QN = 0 ;
                (posedge CLK *> (QN : 1'b1)) = (CLK_01_LH_QN, CLK_01_HL_QN) ;
                $setup(posedge S &&& xcheck1, posedge CLK, tSUd, NOTIFIER);
                $setup(negedge S &&& xcheck1, posedge CLK, tSUd, NOTIFIER);
                $setup(posedge D1 &&& xcheck2, posedge CLK, tSUd, NOTIFIER);
                $setup(negedge D1 &&& xcheck2, posedge CLK, tSUd, NOTIFIER);
                $setup(posedge D0 &&& xcheck3, posedge CLK, tSUd, NOTIFIER);
                $setup(negedge D0 &&& xcheck3, posedge CLK, tSUd, NOTIFIER);
                $hold(posedge CLK, posedge S &&& xcheck1, tHDd, NOTIFIER);
                $hold(posedge CLK, negedge S &&& xcheck1, tHDd, NOTIFIER);
                $hold(posedge CLK, posedge D1 &&& xcheck2, tHDd, NOTIFIER);
                $hold(posedge CLK, negedge D1 &&& xcheck2, tHDd, NOTIFIER);
                $hold(posedge CLK, posedge D0 &&& xcheck3, tHDd, NOTIFIER);
                $hold(posedge CLK, negedge D0 &&& xcheck3, tHDd, NOTIFIER);
                $width(posedge CLK, tPWclk, 0, NOTIFIER);
                $width(negedge CLK, tPWclk, 0, NOTIFIER);
        endspecify
endmodule

module fdmf1c2(QN, D0, D1, S, CLK);
        output QN;
        input  D0, D1, S, CLK;
        supply0 PRESET, CLEAR;
        reg NOTIFIER;
        mux g1(DATA, S, D1, D0);
        not g2(QN, QOUT);
        ff g3(QOUT, DATA, CLK, PRESET, CLEAR, NOTIFIER);
        // EXTERNAL TIMING CHECK SIGNALS
        xtc_xor g4(xcheck1, D0, D1);
        xtc_buf g6(xcheck2, S);
        xtc_not g8(xcheck3, S);
        // SPECIFY BLOCK
        specify
                specparam tSUd = 0 ;
                specparam tHDd = 0 ;
                specparam tPWclk = 0 ;
                specparam CLK_01_LH_QN = 0, CLK_01_HL_QN = 0 ;
                (posedge CLK *> (QN : 1'b1)) = (CLK_01_LH_QN, CLK_01_HL_QN) ;
                $setup(posedge S &&& xcheck1, posedge CLK, tSUd, NOTIFIER);
                $setup(negedge S &&& xcheck1, posedge CLK, tSUd, NOTIFIER);
                $setup(posedge D1 &&& xcheck2, posedge CLK, tSUd, NOTIFIER);
                $setup(negedge D1 &&& xcheck2, posedge CLK, tSUd, NOTIFIER);
                $setup(posedge D0 &&& xcheck3, posedge CLK, tSUd, NOTIFIER);
                $setup(negedge D0 &&& xcheck3, posedge CLK, tSUd, NOTIFIER);
                $hold(posedge CLK, posedge S &&& xcheck1, tHDd, NOTIFIER);
                $hold(posedge CLK, negedge S &&& xcheck1, tHDd, NOTIFIER);
                $hold(posedge CLK, posedge D1 &&& xcheck2, tHDd, NOTIFIER);
                $hold(posedge CLK, negedge D1 &&& xcheck2, tHDd, NOTIFIER);
                $hold(posedge CLK, posedge D0 &&& xcheck3, tHDd, NOTIFIER);
                $hold(posedge CLK, negedge D0 &&& xcheck3, tHDd, NOTIFIER);
                $width(posedge CLK, tPWclk, 0, NOTIFIER);
                $width(negedge CLK, tPWclk, 0, NOTIFIER);
        endspecify
endmodule

module fdmf1c3(QN, D0, D1, S, CLK);
        output QN;
        input  D0, D1, S, CLK;
        supply0 PRESET, CLEAR;
        reg NOTIFIER;
        mux g1(DATA, S, D1, D0);
        not g2(QN, QOUT);
        ff g3(QOUT, DATA, CLK, PRESET, CLEAR, NOTIFIER);
        // EXTERNAL TIMING CHECK SIGNALS
        xtc_xor g4(xcheck1, D0, D1);
        xtc_buf g6(xcheck2, S);
        xtc_not g8(xcheck3, S);
        // SPECIFY BLOCK
        specify
                specparam tSUd = 0 ;
                specparam tHDd = 0 ;
                specparam tPWclk = 0 ;
                specparam CLK_01_LH_QN = 0, CLK_01_HL_QN = 0 ;
                (posedge CLK *> (QN : 1'b1)) = (CLK_01_LH_QN, CLK_01_HL_QN) ;
                $setup(posedge S &&& xcheck1, posedge CLK, tSUd, NOTIFIER);
                $setup(negedge S &&& xcheck1, posedge CLK, tSUd, NOTIFIER);
                $setup(posedge D1 &&& xcheck2, posedge CLK, tSUd, NOTIFIER);
                $setup(negedge D1 &&& xcheck2, posedge CLK, tSUd, NOTIFIER);
                $setup(posedge D0 &&& xcheck3, posedge CLK, tSUd, NOTIFIER);
                $setup(negedge D0 &&& xcheck3, posedge CLK, tSUd, NOTIFIER);
                $hold(posedge CLK, posedge S &&& xcheck1, tHDd, NOTIFIER);
                $hold(posedge CLK, negedge S &&& xcheck1, tHDd, NOTIFIER);
                $hold(posedge CLK, posedge D1 &&& xcheck2, tHDd, NOTIFIER);
                $hold(posedge CLK, negedge D1 &&& xcheck2, tHDd, NOTIFIER);
                $hold(posedge CLK, posedge D0 &&& xcheck3, tHDd, NOTIFIER);
                $hold(posedge CLK, negedge D0 &&& xcheck3, tHDd, NOTIFIER);
                $width(posedge CLK, tPWclk, 0, NOTIFIER);
                $width(negedge CLK, tPWclk, 0, NOTIFIER);
        endspecify
endmodule

module fdmf1c6(QN, D0, D1, S, CLK);
        output QN;
        input  D0, D1, S, CLK;
        supply0 PRESET, CLEAR;
        reg NOTIFIER;
        mux g1(DATA, S, D1, D0);
        not g2(QN, QOUT);
        ff g3(QOUT, DATA, CLK, PRESET, CLEAR, NOTIFIER);
        // EXTERNAL TIMING CHECK SIGNALS
        xtc_xor g4(xcheck1, D0, D1);
        xtc_buf g6(xcheck2, S);
        xtc_not g8(xcheck3, S);
        // SPECIFY BLOCK
        specify
                specparam tSUd = 0 ;
                specparam tHDd = 0 ;
                specparam tPWclk = 0 ;
                specparam CLK_01_LH_QN = 0, CLK_01_HL_QN = 0 ;
                (posedge CLK *> (QN : 1'b1)) = (CLK_01_LH_QN, CLK_01_HL_QN) ;
                $setup(posedge S &&& xcheck1, posedge CLK, tSUd, NOTIFIER);
                $setup(negedge S &&& xcheck1, posedge CLK, tSUd, NOTIFIER);
                $setup(posedge D1 &&& xcheck2, posedge CLK, tSUd, NOTIFIER);
                $setup(negedge D1 &&& xcheck2, posedge CLK, tSUd, NOTIFIER);
                $setup(posedge D0 &&& xcheck3, posedge CLK, tSUd, NOTIFIER);
                $setup(negedge D0 &&& xcheck3, posedge CLK, tSUd, NOTIFIER);
                $hold(posedge CLK, posedge S &&& xcheck1, tHDd, NOTIFIER);
                $hold(posedge CLK, negedge S &&& xcheck1, tHDd, NOTIFIER);
                $hold(posedge CLK, posedge D1 &&& xcheck2, tHDd, NOTIFIER);
                $hold(posedge CLK, negedge D1 &&& xcheck2, tHDd, NOTIFIER);
                $hold(posedge CLK, posedge D0 &&& xcheck3, tHDd, NOTIFIER);
                $hold(posedge CLK, negedge D0 &&& xcheck3, tHDd, NOTIFIER);
                $width(posedge CLK, tPWclk, 0, NOTIFIER);
                $width(negedge CLK, tPWclk, 0, NOTIFIER);
        endspecify
endmodule

module fdmf1c9(QN, D0, D1, S, CLK);
        output QN;
        input  D0, D1, S, CLK;
        supply0 PRESET, CLEAR;
        reg NOTIFIER;
        mux g1(DATA, S, D1, D0);
        not g2(QN, QOUT);
        ff g3(QOUT, DATA, CLK, PRESET, CLEAR, NOTIFIER);
        // EXTERNAL TIMING CHECK SIGNALS
        xtc_xor g4(xcheck1, D0, D1);
        xtc_buf g6(xcheck2, S);
        xtc_not g8(xcheck3, S);
        // SPECIFY BLOCK
        specify
                specparam tSUd = 0 ;
                specparam tHDd = 0 ;
                specparam tPWclk = 0 ;
                specparam CLK_01_LH_QN = 0, CLK_01_HL_QN = 0 ;
                (posedge CLK *> (QN : 1'b1)) = (CLK_01_LH_QN, CLK_01_HL_QN) ;
                $setup(posedge S &&& xcheck1, posedge CLK, tSUd, NOTIFIER);
                $setup(negedge S &&& xcheck1, posedge CLK, tSUd, NOTIFIER);
                $setup(posedge D1 &&& xcheck2, posedge CLK, tSUd, NOTIFIER);
                $setup(negedge D1 &&& xcheck2, posedge CLK, tSUd, NOTIFIER);
                $setup(posedge D0 &&& xcheck3, posedge CLK, tSUd, NOTIFIER);
                $setup(negedge D0 &&& xcheck3, posedge CLK, tSUd, NOTIFIER);
                $hold(posedge CLK, posedge S &&& xcheck1, tHDd, NOTIFIER);
                $hold(posedge CLK, negedge S &&& xcheck1, tHDd, NOTIFIER);
                $hold(posedge CLK, posedge D1 &&& xcheck2, tHDd, NOTIFIER);
                $hold(posedge CLK, negedge D1 &&& xcheck2, tHDd, NOTIFIER);
                $hold(posedge CLK, posedge D0 &&& xcheck3, tHDd, NOTIFIER);
                $hold(posedge CLK, negedge D0 &&& xcheck3, tHDd, NOTIFIER);
                $width(posedge CLK, tPWclk, 0, NOTIFIER);
                $width(negedge CLK, tPWclk, 0, NOTIFIER);
        endspecify
endmodule

module fdmf1d1(QN, D0, D1, S, CLK);
        output QN;
        input  D0, D1, S, CLK;
        supply0 PRESET, CLEAR;
        reg NOTIFIER;
        mux g1(DATA, S, D1, D0);
        not g2(CLOCK, CLK);
        not g3(QN, QOUT);
        ff g4(QOUT, DATA, CLOCK, PRESET, CLEAR, NOTIFIER);
        // EXTERNAL TIMING CHECK SIGNALS
        xtc_xor g5(xcheck1, D0, D1);
        xtc_buf g7(xcheck2, S);
        xtc_not g9(xcheck3, S);
        // SPECIFY BLOCK
        specify
                specparam tSUd = 0 ;
                specparam tHDd = 0 ;
                specparam tPWclk = 0 ;
                specparam CLK_10_LH_QN = 0, CLK_10_HL_QN = 0 ;
                (negedge CLK *> (QN : 1'b1)) = (CLK_10_LH_QN, CLK_10_HL_QN) ;
                $setup(posedge S &&& xcheck1, negedge CLK, tSUd, NOTIFIER);
                $setup(negedge S &&& xcheck1, negedge CLK, tSUd, NOTIFIER);
                $setup(posedge D1 &&& xcheck2, negedge CLK, tSUd, NOTIFIER);
                $setup(negedge D1 &&& xcheck2, negedge CLK, tSUd, NOTIFIER);
                $setup(posedge D0 &&& xcheck3, negedge CLK, tSUd, NOTIFIER);
                $setup(negedge D0 &&& xcheck3, negedge CLK, tSUd, NOTIFIER);
                $hold(negedge CLK, posedge S &&& xcheck1, tHDd, NOTIFIER);
                $hold(negedge CLK, negedge S &&& xcheck1, tHDd, NOTIFIER);
                $hold(negedge CLK, posedge D1 &&& xcheck2, tHDd, NOTIFIER);
                $hold(negedge CLK, negedge D1 &&& xcheck2, tHDd, NOTIFIER);
                $hold(negedge CLK, posedge D0 &&& xcheck3, tHDd, NOTIFIER);
                $hold(negedge CLK, negedge D0 &&& xcheck3, tHDd, NOTIFIER);
                $width(negedge CLK, tPWclk, 0, NOTIFIER);
                $width(posedge CLK, tPWclk, 0, NOTIFIER);
        endspecify
endmodule

module fdmf1d15(QN, D0, D1, S, CLK);
        output QN;
        input  D0, D1, S, CLK;
        supply0 PRESET, CLEAR;
        reg NOTIFIER;
        mux g1(DATA, S, D1, D0);
        not g2(CLOCK, CLK);
        not g3(QN, QOUT);
        ff g4(QOUT, DATA, CLOCK, PRESET, CLEAR, NOTIFIER);
        // EXTERNAL TIMING CHECK SIGNALS
        xtc_xor g5(xcheck1, D0, D1);
        xtc_buf g7(xcheck2, S);
        xtc_not g9(xcheck3, S);
        // SPECIFY BLOCK
        specify
                specparam tSUd = 0 ;
                specparam tHDd = 0 ;
                specparam tPWclk = 0 ;
                specparam CLK_10_LH_QN = 0, CLK_10_HL_QN = 0 ;
                (negedge CLK *> (QN : 1'b1)) = (CLK_10_LH_QN, CLK_10_HL_QN) ;
                $setup(posedge S &&& xcheck1, negedge CLK, tSUd, NOTIFIER);
                $setup(negedge S &&& xcheck1, negedge CLK, tSUd, NOTIFIER);
                $setup(posedge D1 &&& xcheck2, negedge CLK, tSUd, NOTIFIER);
                $setup(negedge D1 &&& xcheck2, negedge CLK, tSUd, NOTIFIER);
                $setup(posedge D0 &&& xcheck3, negedge CLK, tSUd, NOTIFIER);
                $setup(negedge D0 &&& xcheck3, negedge CLK, tSUd, NOTIFIER);
                $hold(negedge CLK, posedge S &&& xcheck1, tHDd, NOTIFIER);
                $hold(negedge CLK, negedge S &&& xcheck1, tHDd, NOTIFIER);
                $hold(negedge CLK, posedge D1 &&& xcheck2, tHDd, NOTIFIER);
                $hold(negedge CLK, negedge D1 &&& xcheck2, tHDd, NOTIFIER);
                $hold(negedge CLK, posedge D0 &&& xcheck3, tHDd, NOTIFIER);
                $hold(negedge CLK, negedge D0 &&& xcheck3, tHDd, NOTIFIER);
                $width(negedge CLK, tPWclk, 0, NOTIFIER);
                $width(posedge CLK, tPWclk, 0, NOTIFIER);
        endspecify
endmodule

module fdmf1d2(QN, D0, D1, S, CLK);
        output QN;
        input  D0, D1, S, CLK;
        supply0 PRESET, CLEAR;
        reg NOTIFIER;
        mux g1(DATA, S, D1, D0);
        not g2(CLOCK, CLK);
        not g3(QN, QOUT);
        ff g4(QOUT, DATA, CLOCK, PRESET, CLEAR, NOTIFIER);
        // EXTERNAL TIMING CHECK SIGNALS
        xtc_xor g5(xcheck1, D0, D1);
        xtc_buf g7(xcheck2, S);
        xtc_not g9(xcheck3, S);
        // SPECIFY BLOCK
        specify
                specparam tSUd = 0 ;
                specparam tHDd = 0 ;
                specparam tPWclk = 0 ;
                specparam CLK_10_LH_QN = 0, CLK_10_HL_QN = 0 ;
                (negedge CLK *> (QN : 1'b1)) = (CLK_10_LH_QN, CLK_10_HL_QN) ;
                $setup(posedge S &&& xcheck1, negedge CLK, tSUd, NOTIFIER);
                $setup(negedge S &&& xcheck1, negedge CLK, tSUd, NOTIFIER);
                $setup(posedge D1 &&& xcheck2, negedge CLK, tSUd, NOTIFIER);
                $setup(negedge D1 &&& xcheck2, negedge CLK, tSUd, NOTIFIER);
                $setup(posedge D0 &&& xcheck3, negedge CLK, tSUd, NOTIFIER);
                $setup(negedge D0 &&& xcheck3, negedge CLK, tSUd, NOTIFIER);
                $hold(negedge CLK, posedge S &&& xcheck1, tHDd, NOTIFIER);
                $hold(negedge CLK, negedge S &&& xcheck1, tHDd, NOTIFIER);
                $hold(negedge CLK, posedge D1 &&& xcheck2, tHDd, NOTIFIER);
                $hold(negedge CLK, negedge D1 &&& xcheck2, tHDd, NOTIFIER);
                $hold(negedge CLK, posedge D0 &&& xcheck3, tHDd, NOTIFIER);
                $hold(negedge CLK, negedge D0 &&& xcheck3, tHDd, NOTIFIER);
                $width(negedge CLK, tPWclk, 0, NOTIFIER);
                $width(posedge CLK, tPWclk, 0, NOTIFIER);
        endspecify
endmodule

module fdmf1d3(QN, D0, D1, S, CLK);
        output QN;
        input  D0, D1, S, CLK;
        supply0 PRESET, CLEAR;
        reg NOTIFIER;
        mux g1(DATA, S, D1, D0);
        not g2(CLOCK, CLK);
        not g3(QN, QOUT);
        ff g4(QOUT, DATA, CLOCK, PRESET, CLEAR, NOTIFIER);
        // EXTERNAL TIMING CHECK SIGNALS
        xtc_xor g5(xcheck1, D0, D1);
        xtc_buf g7(xcheck2, S);
        xtc_not g9(xcheck3, S);
        // SPECIFY BLOCK
        specify
                specparam tSUd = 0 ;
                specparam tHDd = 0 ;
                specparam tPWclk = 0 ;
                specparam CLK_10_LH_QN = 0, CLK_10_HL_QN = 0 ;
                (negedge CLK *> (QN : 1'b1)) = (CLK_10_LH_QN, CLK_10_HL_QN) ;
                $setup(posedge S &&& xcheck1, negedge CLK, tSUd, NOTIFIER);
                $setup(negedge S &&& xcheck1, negedge CLK, tSUd, NOTIFIER);
                $setup(posedge D1 &&& xcheck2, negedge CLK, tSUd, NOTIFIER);
                $setup(negedge D1 &&& xcheck2, negedge CLK, tSUd, NOTIFIER);
                $setup(posedge D0 &&& xcheck3, negedge CLK, tSUd, NOTIFIER);
                $setup(negedge D0 &&& xcheck3, negedge CLK, tSUd, NOTIFIER);
                $hold(negedge CLK, posedge S &&& xcheck1, tHDd, NOTIFIER);
                $hold(negedge CLK, negedge S &&& xcheck1, tHDd, NOTIFIER);
                $hold(negedge CLK, posedge D1 &&& xcheck2, tHDd, NOTIFIER);
                $hold(negedge CLK, negedge D1 &&& xcheck2, tHDd, NOTIFIER);
                $hold(negedge CLK, posedge D0 &&& xcheck3, tHDd, NOTIFIER);
                $hold(negedge CLK, negedge D0 &&& xcheck3, tHDd, NOTIFIER);
                $width(negedge CLK, tPWclk, 0, NOTIFIER);
                $width(posedge CLK, tPWclk, 0, NOTIFIER);
        endspecify
endmodule

module fdmf1d6(QN, D0, D1, S, CLK);
        output QN;
        input  D0, D1, S, CLK;
        supply0 PRESET, CLEAR;
        reg NOTIFIER;
        mux g1(DATA, S, D1, D0);
        not g2(CLOCK, CLK);
        not g3(QN, QOUT);
        ff g4(QOUT, DATA, CLOCK, PRESET, CLEAR, NOTIFIER);
        // EXTERNAL TIMING CHECK SIGNALS
        xtc_xor g5(xcheck1, D0, D1);
        xtc_buf g7(xcheck2, S);
        xtc_not g9(xcheck3, S);
        // SPECIFY BLOCK
        specify
                specparam tSUd = 0 ;
                specparam tHDd = 0 ;
                specparam tPWclk = 0 ;
                specparam CLK_10_LH_QN = 0, CLK_10_HL_QN = 0 ;
                (negedge CLK *> (QN : 1'b1)) = (CLK_10_LH_QN, CLK_10_HL_QN) ;
                $setup(posedge S &&& xcheck1, negedge CLK, tSUd, NOTIFIER);
                $setup(negedge S &&& xcheck1, negedge CLK, tSUd, NOTIFIER);
                $setup(posedge D1 &&& xcheck2, negedge CLK, tSUd, NOTIFIER);
                $setup(negedge D1 &&& xcheck2, negedge CLK, tSUd, NOTIFIER);
                $setup(posedge D0 &&& xcheck3, negedge CLK, tSUd, NOTIFIER);
                $setup(negedge D0 &&& xcheck3, negedge CLK, tSUd, NOTIFIER);
                $hold(negedge CLK, posedge S &&& xcheck1, tHDd, NOTIFIER);
                $hold(negedge CLK, negedge S &&& xcheck1, tHDd, NOTIFIER);
                $hold(negedge CLK, posedge D1 &&& xcheck2, tHDd, NOTIFIER);
                $hold(negedge CLK, negedge D1 &&& xcheck2, tHDd, NOTIFIER);
                $hold(negedge CLK, posedge D0 &&& xcheck3, tHDd, NOTIFIER);
                $hold(negedge CLK, negedge D0 &&& xcheck3, tHDd, NOTIFIER);
                $width(negedge CLK, tPWclk, 0, NOTIFIER);
                $width(posedge CLK, tPWclk, 0, NOTIFIER);
        endspecify
endmodule

module fdmf1d9(QN, D0, D1, S, CLK);
        output QN;
        input  D0, D1, S, CLK;
        supply0 PRESET, CLEAR;
        reg NOTIFIER;
        mux g1(DATA, S, D1, D0);
        not g2(CLOCK, CLK);
        not g3(QN, QOUT);
        ff g4(QOUT, DATA, CLOCK, PRESET, CLEAR, NOTIFIER);
        // EXTERNAL TIMING CHECK SIGNALS
        xtc_xor g5(xcheck1, D0, D1);
        xtc_buf g7(xcheck2, S);
        xtc_not g9(xcheck3, S);
        // SPECIFY BLOCK
        specify
                specparam tSUd = 0 ;
                specparam tHDd = 0 ;
                specparam tPWclk = 0 ;
                specparam CLK_10_LH_QN = 0, CLK_10_HL_QN = 0 ;
                (negedge CLK *> (QN : 1'b1)) = (CLK_10_LH_QN, CLK_10_HL_QN) ;
                $setup(posedge S &&& xcheck1, negedge CLK, tSUd, NOTIFIER);
                $setup(negedge S &&& xcheck1, negedge CLK, tSUd, NOTIFIER);
                $setup(posedge D1 &&& xcheck2, negedge CLK, tSUd, NOTIFIER);
                $setup(negedge D1 &&& xcheck2, negedge CLK, tSUd, NOTIFIER);
                $setup(posedge D0 &&& xcheck3, negedge CLK, tSUd, NOTIFIER);
                $setup(negedge D0 &&& xcheck3, negedge CLK, tSUd, NOTIFIER);
                $hold(negedge CLK, posedge S &&& xcheck1, tHDd, NOTIFIER);
                $hold(negedge CLK, negedge S &&& xcheck1, tHDd, NOTIFIER);
                $hold(negedge CLK, posedge D1 &&& xcheck2, tHDd, NOTIFIER);
                $hold(negedge CLK, negedge D1 &&& xcheck2, tHDd, NOTIFIER);
                $hold(negedge CLK, posedge D0 &&& xcheck3, tHDd, NOTIFIER);
                $hold(negedge CLK, negedge D0 &&& xcheck3, tHDd, NOTIFIER);
                $width(negedge CLK, tPWclk, 0, NOTIFIER);
                $width(posedge CLK, tPWclk, 0, NOTIFIER);
        endspecify
endmodule

module fdmf2a1(Q, D0, D1, S, CLK, CLR);
        output Q;
        input  D0, D1, S, CLK, CLR;
        supply0 PRESET;
        reg NOTIFIER;
        mux g1(DATA, S, D1, D0);
        not g2(CLEAR, CLR);
        buf g3(Q, QOUT);
        ff g4(QOUT, DATA, CLK, PRESET, CLEAR, NOTIFIER);
        // CONDITIONAL TIMING CHECK SIGNALS
        not g5(check1, CLEAR);
        buf g6(check2, DATA);
        // EXTERNAL TIMING CHECK SIGNALS
        xor     g7(sstz1, D0, D1);
        xtc_and g8(xcheck1, check1, sstz1);
        xtc_and g10(xcheck2, check1, S);
        not     g11(sstz3, S);
        xtc_and g12(xcheck3, check1, sstz3);
        // SPECIFY BLOCK
        specify
                specparam tSUd = 0 ;
                specparam tHDd = 0 ;
                specparam tRECclr = 0 ;
                specparam tPWclk = 0 ;
                specparam tHDclr = 0 ;
                specparam tPWclr = 0 ;
                specparam CLK_01_LH_Q = 0, CLK_01_HL_Q = 0 ;
                specparam CLR_10_LH_Q = 0, CLR_10_HL_Q = 0 ;
                (posedge CLK *> (Q : 1'b1)) = (CLK_01_LH_Q, CLK_01_HL_Q) ;
                (negedge CLR *> (Q : 1'b1)) = (CLR_10_LH_Q, CLR_10_HL_Q) ;
                $setup(posedge S &&& xcheck1, posedge CLK, tSUd, NOTIFIER);
                $setup(negedge S &&& xcheck1, posedge CLK, tSUd, NOTIFIER);
                $setup(posedge D1 &&& xcheck2, posedge CLK, tSUd, NOTIFIER);
                $setup(negedge D1 &&& xcheck2, posedge CLK, tSUd, NOTIFIER);
                $setup(posedge D0 &&& xcheck3, posedge CLK, tSUd, NOTIFIER);
                $setup(negedge D0 &&& xcheck3, posedge CLK, tSUd, NOTIFIER);
                $hold(posedge CLK, posedge S &&& xcheck1, tHDd, NOTIFIER);
                $hold(posedge CLK, negedge S &&& xcheck1, tHDd, NOTIFIER);
                $hold(posedge CLK, posedge D1 &&& xcheck2, tHDd, NOTIFIER);
                $hold(posedge CLK, negedge D1 &&& xcheck2, tHDd, NOTIFIER);
                $hold(posedge CLK, posedge D0 &&& xcheck3, tHDd, NOTIFIER);
                $hold(posedge CLK, negedge D0 &&& xcheck3, tHDd, NOTIFIER);
                $recovery(posedge CLR, posedge CLK &&& check2, tRECclr, NOTIFIER);
                $width(posedge CLK &&& check1, tPWclk, 0, NOTIFIER);
                $width(negedge CLK &&& check1, tPWclk, 0, NOTIFIER);
                $hold(posedge CLK, posedge CLR &&& check2, tHDclr, NOTIFIER);
                $hold(posedge CLK, negedge CLR &&& check2, tHDclr, NOTIFIER);
                $width(negedge CLR, tPWclr, 0, NOTIFIER);
        endspecify
endmodule

module fdmf2a15(Q, D0, D1, S, CLK, CLR);
        output Q;
        input  D0, D1, S, CLK, CLR;
        supply0 PRESET;
        reg NOTIFIER;
        mux g1(DATA, S, D1, D0);
        not g2(CLEAR, CLR);
        buf g3(Q, QOUT);
        ff g4(QOUT, DATA, CLK, PRESET, CLEAR, NOTIFIER);
        // CONDITIONAL TIMING CHECK SIGNALS
        not g5(check1, CLEAR);
        buf g6(check2, DATA);
        // EXTERNAL TIMING CHECK SIGNALS
        xor     g7(sstz1, D0, D1);
        xtc_and g8(xcheck1, check1, sstz1);
        xtc_and g10(xcheck2, check1, S);
        not     g11(sstz3, S);
        xtc_and g12(xcheck3, check1, sstz3);
        // SPECIFY BLOCK
        specify
                specparam tSUd = 0 ;
                specparam tHDd = 0 ;
                specparam tRECclr = 0 ;
                specparam tPWclk = 0 ;
                specparam tHDclr = 0 ;
                specparam tPWclr = 0 ;
                specparam CLK_01_LH_Q = 0, CLK_01_HL_Q = 0 ;
                specparam CLR_10_LH_Q = 0, CLR_10_HL_Q = 0 ;
                (posedge CLK *> (Q : 1'b1)) = (CLK_01_LH_Q, CLK_01_HL_Q) ;
                (negedge CLR *> (Q : 1'b1)) = (CLR_10_LH_Q, CLR_10_HL_Q) ;
                $setup(posedge S &&& xcheck1, posedge CLK, tSUd, NOTIFIER);
                $setup(negedge S &&& xcheck1, posedge CLK, tSUd, NOTIFIER);
                $setup(posedge D1 &&& xcheck2, posedge CLK, tSUd, NOTIFIER);
                $setup(negedge D1 &&& xcheck2, posedge CLK, tSUd, NOTIFIER);
                $setup(posedge D0 &&& xcheck3, posedge CLK, tSUd, NOTIFIER);
                $setup(negedge D0 &&& xcheck3, posedge CLK, tSUd, NOTIFIER);
                $hold(posedge CLK, posedge S &&& xcheck1, tHDd, NOTIFIER);
                $hold(posedge CLK, negedge S &&& xcheck1, tHDd, NOTIFIER);
                $hold(posedge CLK, posedge D1 &&& xcheck2, tHDd, NOTIFIER);
                $hold(posedge CLK, negedge D1 &&& xcheck2, tHDd, NOTIFIER);
                $hold(posedge CLK, posedge D0 &&& xcheck3, tHDd, NOTIFIER);
                $hold(posedge CLK, negedge D0 &&& xcheck3, tHDd, NOTIFIER);
                $recovery(posedge CLR, posedge CLK &&& check2, tRECclr, NOTIFIER);
                $width(posedge CLK &&& check1, tPWclk, 0, NOTIFIER);
                $width(negedge CLK &&& check1, tPWclk, 0, NOTIFIER);
                $hold(posedge CLK, posedge CLR &&& check2, tHDclr, NOTIFIER);
                $hold(posedge CLK, negedge CLR &&& check2, tHDclr, NOTIFIER);
                $width(negedge CLR, tPWclr, 0, NOTIFIER);
        endspecify
endmodule

module fdmf2a2(Q, D0, D1, S, CLK, CLR);
        output Q;
        input  D0, D1, S, CLK, CLR;
        supply0 PRESET;
        reg NOTIFIER;
        mux g1(DATA, S, D1, D0);
        not g2(CLEAR, CLR);
        buf g3(Q, QOUT);
        ff g4(QOUT, DATA, CLK, PRESET, CLEAR, NOTIFIER);
        // CONDITIONAL TIMING CHECK SIGNALS
        not g5(check1, CLEAR);
        buf g6(check2, DATA);
        // EXTERNAL TIMING CHECK SIGNALS
        xor     g7(sstz1, D0, D1);
        xtc_and g8(xcheck1, check1, sstz1);
        xtc_and g10(xcheck2, check1, S);
        not     g11(sstz3, S);
        xtc_and g12(xcheck3, check1, sstz3);
        // SPECIFY BLOCK
        specify
                specparam tSUd = 0 ;
                specparam tHDd = 0 ;
                specparam tRECclr = 0 ;
                specparam tPWclk = 0 ;
                specparam tHDclr = 0 ;
                specparam tPWclr = 0 ;
                specparam CLK_01_LH_Q = 0, CLK_01_HL_Q = 0 ;
                specparam CLR_10_LH_Q = 0, CLR_10_HL_Q = 0 ;
                (posedge CLK *> (Q : 1'b1)) = (CLK_01_LH_Q, CLK_01_HL_Q) ;
                (negedge CLR *> (Q : 1'b1)) = (CLR_10_LH_Q, CLR_10_HL_Q) ;
                $setup(posedge S &&& xcheck1, posedge CLK, tSUd, NOTIFIER);
                $setup(negedge S &&& xcheck1, posedge CLK, tSUd, NOTIFIER);
                $setup(posedge D1 &&& xcheck2, posedge CLK, tSUd, NOTIFIER);
                $setup(negedge D1 &&& xcheck2, posedge CLK, tSUd, NOTIFIER);
                $setup(posedge D0 &&& xcheck3, posedge CLK, tSUd, NOTIFIER);
                $setup(negedge D0 &&& xcheck3, posedge CLK, tSUd, NOTIFIER);
                $hold(posedge CLK, posedge S &&& xcheck1, tHDd, NOTIFIER);
                $hold(posedge CLK, negedge S &&& xcheck1, tHDd, NOTIFIER);
                $hold(posedge CLK, posedge D1 &&& xcheck2, tHDd, NOTIFIER);
                $hold(posedge CLK, negedge D1 &&& xcheck2, tHDd, NOTIFIER);
                $hold(posedge CLK, posedge D0 &&& xcheck3, tHDd, NOTIFIER);
                $hold(posedge CLK, negedge D0 &&& xcheck3, tHDd, NOTIFIER);
                $recovery(posedge CLR, posedge CLK &&& check2, tRECclr, NOTIFIER);
                $width(posedge CLK &&& check1, tPWclk, 0, NOTIFIER);
                $width(negedge CLK &&& check1, tPWclk, 0, NOTIFIER);
                $hold(posedge CLK, posedge CLR &&& check2, tHDclr, NOTIFIER);
                $hold(posedge CLK, negedge CLR &&& check2, tHDclr, NOTIFIER);
                $width(negedge CLR, tPWclr, 0, NOTIFIER);
        endspecify
endmodule

module fdmf2a3(Q, D0, D1, S, CLK, CLR);
        output Q;
        input  D0, D1, S, CLK, CLR;
        supply0 PRESET;
        reg NOTIFIER;
        mux g1(DATA, S, D1, D0);
        not g2(CLEAR, CLR);
        buf g3(Q, QOUT);
        ff g4(QOUT, DATA, CLK, PRESET, CLEAR, NOTIFIER);
        // CONDITIONAL TIMING CHECK SIGNALS
        not g5(check1, CLEAR);
        buf g6(check2, DATA);
        // EXTERNAL TIMING CHECK SIGNALS
        xor     g7(sstz1, D0, D1);
        xtc_and g8(xcheck1, check1, sstz1);
        xtc_and g10(xcheck2, check1, S);
        not     g11(sstz3, S);
        xtc_and g12(xcheck3, check1, sstz3);
        // SPECIFY BLOCK
        specify
                specparam tSUd = 0 ;
                specparam tHDd = 0 ;
                specparam tRECclr = 0 ;
                specparam tPWclk = 0 ;
                specparam tHDclr = 0 ;
                specparam tPWclr = 0 ;
                specparam CLK_01_LH_Q = 0, CLK_01_HL_Q = 0 ;
                specparam CLR_10_LH_Q = 0, CLR_10_HL_Q = 0 ;
                (posedge CLK *> (Q : 1'b1)) = (CLK_01_LH_Q, CLK_01_HL_Q) ;
                (negedge CLR *> (Q : 1'b1)) = (CLR_10_LH_Q, CLR_10_HL_Q) ;
                $setup(posedge S &&& xcheck1, posedge CLK, tSUd, NOTIFIER);
                $setup(negedge S &&& xcheck1, posedge CLK, tSUd, NOTIFIER);
                $setup(posedge D1 &&& xcheck2, posedge CLK, tSUd, NOTIFIER);
                $setup(negedge D1 &&& xcheck2, posedge CLK, tSUd, NOTIFIER);
                $setup(posedge D0 &&& xcheck3, posedge CLK, tSUd, NOTIFIER);
                $setup(negedge D0 &&& xcheck3, posedge CLK, tSUd, NOTIFIER);
                $hold(posedge CLK, posedge S &&& xcheck1, tHDd, NOTIFIER);
                $hold(posedge CLK, negedge S &&& xcheck1, tHDd, NOTIFIER);
                $hold(posedge CLK, posedge D1 &&& xcheck2, tHDd, NOTIFIER);
                $hold(posedge CLK, negedge D1 &&& xcheck2, tHDd, NOTIFIER);
                $hold(posedge CLK, posedge D0 &&& xcheck3, tHDd, NOTIFIER);
                $hold(posedge CLK, negedge D0 &&& xcheck3, tHDd, NOTIFIER);
                $recovery(posedge CLR, posedge CLK &&& check2, tRECclr, NOTIFIER);
                $width(posedge CLK &&& check1, tPWclk, 0, NOTIFIER);
                $width(negedge CLK &&& check1, tPWclk, 0, NOTIFIER);
                $hold(posedge CLK, posedge CLR &&& check2, tHDclr, NOTIFIER);
                $hold(posedge CLK, negedge CLR &&& check2, tHDclr, NOTIFIER);
                $width(negedge CLR, tPWclr, 0, NOTIFIER);
        endspecify
endmodule

module fdmf2a6(Q, D0, D1, S, CLK, CLR);
        output Q;
        input  D0, D1, S, CLK, CLR;
        supply0 PRESET;
        reg NOTIFIER;
        mux g1(DATA, S, D1, D0);
        not g2(CLEAR, CLR);
        buf g3(Q, QOUT);
        ff g4(QOUT, DATA, CLK, PRESET, CLEAR, NOTIFIER);
        // CONDITIONAL TIMING CHECK SIGNALS
        not g5(check1, CLEAR);
        buf g6(check2, DATA);
        // EXTERNAL TIMING CHECK SIGNALS
        xor     g7(sstz1, D0, D1);
        xtc_and g8(xcheck1, check1, sstz1);
        xtc_and g10(xcheck2, check1, S);
        not     g11(sstz3, S);
        xtc_and g12(xcheck3, check1, sstz3);
        // SPECIFY BLOCK
        specify
                specparam tSUd = 0 ;
                specparam tHDd = 0 ;
                specparam tRECclr = 0 ;
                specparam tPWclk = 0 ;
                specparam tHDclr = 0 ;
                specparam tPWclr = 0 ;
                specparam CLK_01_LH_Q = 0, CLK_01_HL_Q = 0 ;
                specparam CLR_10_LH_Q = 0, CLR_10_HL_Q = 0 ;
                (posedge CLK *> (Q : 1'b1)) = (CLK_01_LH_Q, CLK_01_HL_Q) ;
                (negedge CLR *> (Q : 1'b1)) = (CLR_10_LH_Q, CLR_10_HL_Q) ;
                $setup(posedge S &&& xcheck1, posedge CLK, tSUd, NOTIFIER);
                $setup(negedge S &&& xcheck1, posedge CLK, tSUd, NOTIFIER);
                $setup(posedge D1 &&& xcheck2, posedge CLK, tSUd, NOTIFIER);
                $setup(negedge D1 &&& xcheck2, posedge CLK, tSUd, NOTIFIER);
                $setup(posedge D0 &&& xcheck3, posedge CLK, tSUd, NOTIFIER);
                $setup(negedge D0 &&& xcheck3, posedge CLK, tSUd, NOTIFIER);
                $hold(posedge CLK, posedge S &&& xcheck1, tHDd, NOTIFIER);
                $hold(posedge CLK, negedge S &&& xcheck1, tHDd, NOTIFIER);
                $hold(posedge CLK, posedge D1 &&& xcheck2, tHDd, NOTIFIER);
                $hold(posedge CLK, negedge D1 &&& xcheck2, tHDd, NOTIFIER);
                $hold(posedge CLK, posedge D0 &&& xcheck3, tHDd, NOTIFIER);
                $hold(posedge CLK, negedge D0 &&& xcheck3, tHDd, NOTIFIER);
                $recovery(posedge CLR, posedge CLK &&& check2, tRECclr, NOTIFIER);
                $width(posedge CLK &&& check1, tPWclk, 0, NOTIFIER);
                $width(negedge CLK &&& check1, tPWclk, 0, NOTIFIER);
                $hold(posedge CLK, posedge CLR &&& check2, tHDclr, NOTIFIER);
                $hold(posedge CLK, negedge CLR &&& check2, tHDclr, NOTIFIER);
                $width(negedge CLR, tPWclr, 0, NOTIFIER);
        endspecify
endmodule

module fdmf2a9(Q, D0, D1, S, CLK, CLR);
        output Q;
        input  D0, D1, S, CLK, CLR;
        supply0 PRESET;
        reg NOTIFIER;
        mux g1(DATA, S, D1, D0);
        not g2(CLEAR, CLR);
        buf g3(Q, QOUT);
        ff g4(QOUT, DATA, CLK, PRESET, CLEAR, NOTIFIER);
        // CONDITIONAL TIMING CHECK SIGNALS
        not g5(check1, CLEAR);
        buf g6(check2, DATA);
        // EXTERNAL TIMING CHECK SIGNALS
        xor     g7(sstz1, D0, D1);
        xtc_and g8(xcheck1, check1, sstz1);
        xtc_and g10(xcheck2, check1, S);
        not     g11(sstz3, S);
        xtc_and g12(xcheck3, check1, sstz3);
        // SPECIFY BLOCK
        specify
                specparam tSUd = 0 ;
                specparam tHDd = 0 ;
                specparam tRECclr = 0 ;
                specparam tPWclk = 0 ;
                specparam tHDclr = 0 ;
                specparam tPWclr = 0 ;
                specparam CLK_01_LH_Q = 0, CLK_01_HL_Q = 0 ;
                specparam CLR_10_LH_Q = 0, CLR_10_HL_Q = 0 ;
                (posedge CLK *> (Q : 1'b1)) = (CLK_01_LH_Q, CLK_01_HL_Q) ;
                (negedge CLR *> (Q : 1'b1)) = (CLR_10_LH_Q, CLR_10_HL_Q) ;
                $setup(posedge S &&& xcheck1, posedge CLK, tSUd, NOTIFIER);
                $setup(negedge S &&& xcheck1, posedge CLK, tSUd, NOTIFIER);
                $setup(posedge D1 &&& xcheck2, posedge CLK, tSUd, NOTIFIER);
                $setup(negedge D1 &&& xcheck2, posedge CLK, tSUd, NOTIFIER);
                $setup(posedge D0 &&& xcheck3, posedge CLK, tSUd, NOTIFIER);
                $setup(negedge D0 &&& xcheck3, posedge CLK, tSUd, NOTIFIER);
                $hold(posedge CLK, posedge S &&& xcheck1, tHDd, NOTIFIER);
                $hold(posedge CLK, negedge S &&& xcheck1, tHDd, NOTIFIER);
                $hold(posedge CLK, posedge D1 &&& xcheck2, tHDd, NOTIFIER);
                $hold(posedge CLK, negedge D1 &&& xcheck2, tHDd, NOTIFIER);
                $hold(posedge CLK, posedge D0 &&& xcheck3, tHDd, NOTIFIER);
                $hold(posedge CLK, negedge D0 &&& xcheck3, tHDd, NOTIFIER);
                $recovery(posedge CLR, posedge CLK &&& check2, tRECclr, NOTIFIER);
                $width(posedge CLK &&& check1, tPWclk, 0, NOTIFIER);
                $width(negedge CLK &&& check1, tPWclk, 0, NOTIFIER);
                $hold(posedge CLK, posedge CLR &&& check2, tHDclr, NOTIFIER);
                $hold(posedge CLK, negedge CLR &&& check2, tHDclr, NOTIFIER);
                $width(negedge CLR, tPWclr, 0, NOTIFIER);
        endspecify
endmodule

module fdmf2b1(Q, D0, D1, S, CLK, CLR);
        output Q;
        input  D0, D1, S, CLK, CLR;
        supply0 PRESET;
        reg NOTIFIER;
        mux g1(DATA, S, D1, D0);
        not g2(CLOCK, CLK);
        not g3(CLEAR, CLR);
        buf g4(Q, QOUT);
        ff g5(QOUT, DATA, CLOCK, PRESET, CLEAR, NOTIFIER);
        // CONDITIONAL TIMING CHECK SIGNALS
        not g6(check1, CLEAR);
        buf g7(check2, DATA);
        // EXTERNAL TIMING CHECK SIGNALS
        xor     g8(sstz1, D0, D1);
        xtc_and g9(xcheck1, check1, sstz1);
        xtc_and g11(xcheck2, check1, S);
        not     g12(sstz3, S);
        xtc_and g13(xcheck3, check1, sstz3);
        // SPECIFY BLOCK
        specify
                specparam tSUd = 0 ;
                specparam tHDd = 0 ;
                specparam tRECclr = 0 ;
                specparam tPWclk = 0 ;
                specparam tHDclr = 0 ;
                specparam tPWclr = 0 ;
                specparam CLK_10_LH_Q = 0, CLK_10_HL_Q = 0 ;
                specparam CLR_10_LH_Q = 0, CLR_10_HL_Q = 0 ;
                (negedge CLK *> (Q : 1'b1)) = (CLK_10_LH_Q, CLK_10_HL_Q) ;
                (negedge CLR *> (Q : 1'b1)) = (CLR_10_LH_Q, CLR_10_HL_Q) ;
                $setup(posedge S &&& xcheck1, negedge CLK, tSUd, NOTIFIER);
                $setup(negedge S &&& xcheck1, negedge CLK, tSUd, NOTIFIER);
                $setup(posedge D1 &&& xcheck2, negedge CLK, tSUd, NOTIFIER);
                $setup(negedge D1 &&& xcheck2, negedge CLK, tSUd, NOTIFIER);
                $setup(posedge D0 &&& xcheck3, negedge CLK, tSUd, NOTIFIER);
                $setup(negedge D0 &&& xcheck3, negedge CLK, tSUd, NOTIFIER);
                $hold(negedge CLK, posedge S &&& xcheck1, tHDd, NOTIFIER);
                $hold(negedge CLK, negedge S &&& xcheck1, tHDd, NOTIFIER);
                $hold(negedge CLK, posedge D1 &&& xcheck2, tHDd, NOTIFIER);
                $hold(negedge CLK, negedge D1 &&& xcheck2, tHDd, NOTIFIER);
                $hold(negedge CLK, posedge D0 &&& xcheck3, tHDd, NOTIFIER);
                $hold(negedge CLK, negedge D0 &&& xcheck3, tHDd, NOTIFIER);
                $recovery(posedge CLR, negedge CLK &&& check2, tRECclr, NOTIFIER);
                $width(negedge CLK &&& check1, tPWclk, 0, NOTIFIER);
                $width(posedge CLK &&& check1, tPWclk, 0, NOTIFIER);
                $hold(negedge CLK, posedge CLR &&& check2, tHDclr, NOTIFIER);
                $hold(negedge CLK, negedge CLR &&& check2, tHDclr, NOTIFIER);
                $width(negedge CLR, tPWclr, 0, NOTIFIER);
        endspecify
endmodule

module fdmf2b15(Q, D0, D1, S, CLK, CLR);
        output Q;
        input  D0, D1, S, CLK, CLR;
        supply0 PRESET;
        reg NOTIFIER;
        mux g1(DATA, S, D1, D0);
        not g2(CLOCK, CLK);
        not g3(CLEAR, CLR);
        buf g4(Q, QOUT);
        ff g5(QOUT, DATA, CLOCK, PRESET, CLEAR, NOTIFIER);
        // CONDITIONAL TIMING CHECK SIGNALS
        not g6(check1, CLEAR);
        buf g7(check2, DATA);
        // EXTERNAL TIMING CHECK SIGNALS
        xor     g8(sstz1, D0, D1);
        xtc_and g9(xcheck1, check1, sstz1);
        xtc_and g11(xcheck2, check1, S);
        not     g12(sstz3, S);
        xtc_and g13(xcheck3, check1, sstz3);
        // SPECIFY BLOCK
        specify
                specparam tSUd = 0 ;
                specparam tHDd = 0 ;
                specparam tRECclr = 0 ;
                specparam tPWclk = 0 ;
                specparam tHDclr = 0 ;
                specparam tPWclr = 0 ;
                specparam CLK_10_LH_Q = 0, CLK_10_HL_Q = 0 ;
                specparam CLR_10_LH_Q = 0, CLR_10_HL_Q = 0 ;
                (negedge CLK *> (Q : 1'b1)) = (CLK_10_LH_Q, CLK_10_HL_Q) ;
                (negedge CLR *> (Q : 1'b1)) = (CLR_10_LH_Q, CLR_10_HL_Q) ;
                $setup(posedge S &&& xcheck1, negedge CLK, tSUd, NOTIFIER);
                $setup(negedge S &&& xcheck1, negedge CLK, tSUd, NOTIFIER);
                $setup(posedge D1 &&& xcheck2, negedge CLK, tSUd, NOTIFIER);
                $setup(negedge D1 &&& xcheck2, negedge CLK, tSUd, NOTIFIER);
                $setup(posedge D0 &&& xcheck3, negedge CLK, tSUd, NOTIFIER);
                $setup(negedge D0 &&& xcheck3, negedge CLK, tSUd, NOTIFIER);
                $hold(negedge CLK, posedge S &&& xcheck1, tHDd, NOTIFIER);
                $hold(negedge CLK, negedge S &&& xcheck1, tHDd, NOTIFIER);
                $hold(negedge CLK, posedge D1 &&& xcheck2, tHDd, NOTIFIER);
                $hold(negedge CLK, negedge D1 &&& xcheck2, tHDd, NOTIFIER);
                $hold(negedge CLK, posedge D0 &&& xcheck3, tHDd, NOTIFIER);
                $hold(negedge CLK, negedge D0 &&& xcheck3, tHDd, NOTIFIER);
                $recovery(posedge CLR, negedge CLK &&& check2, tRECclr, NOTIFIER);
                $width(negedge CLK &&& check1, tPWclk, 0, NOTIFIER);
                $width(posedge CLK &&& check1, tPWclk, 0, NOTIFIER);
                $hold(negedge CLK, posedge CLR &&& check2, tHDclr, NOTIFIER);
                $hold(negedge CLK, negedge CLR &&& check2, tHDclr, NOTIFIER);
                $width(negedge CLR, tPWclr, 0, NOTIFIER);
        endspecify
endmodule

module fdmf2b2(Q, D0, D1, S, CLK, CLR);
        output Q;
        input  D0, D1, S, CLK, CLR;
        supply0 PRESET;
        reg NOTIFIER;
        mux g1(DATA, S, D1, D0);
        not g2(CLOCK, CLK);
        not g3(CLEAR, CLR);
        buf g4(Q, QOUT);
        ff g5(QOUT, DATA, CLOCK, PRESET, CLEAR, NOTIFIER);
        // CONDITIONAL TIMING CHECK SIGNALS
        not g6(check1, CLEAR);
        buf g7(check2, DATA);
        // EXTERNAL TIMING CHECK SIGNALS
        xor     g8(sstz1, D0, D1);
        xtc_and g9(xcheck1, check1, sstz1);
        xtc_and g11(xcheck2, check1, S);
        not     g12(sstz3, S);
        xtc_and g13(xcheck3, check1, sstz3);
        // SPECIFY BLOCK
        specify
                specparam tSUd = 0 ;
                specparam tHDd = 0 ;
                specparam tRECclr = 0 ;
                specparam tPWclk = 0 ;
                specparam tHDclr = 0 ;
                specparam tPWclr = 0 ;
                specparam CLK_10_LH_Q = 0, CLK_10_HL_Q = 0 ;
                specparam CLR_10_LH_Q = 0, CLR_10_HL_Q = 0 ;
                (negedge CLK *> (Q : 1'b1)) = (CLK_10_LH_Q, CLK_10_HL_Q) ;
                (negedge CLR *> (Q : 1'b1)) = (CLR_10_LH_Q, CLR_10_HL_Q) ;
                $setup(posedge S &&& xcheck1, negedge CLK, tSUd, NOTIFIER);
                $setup(negedge S &&& xcheck1, negedge CLK, tSUd, NOTIFIER);
                $setup(posedge D1 &&& xcheck2, negedge CLK, tSUd, NOTIFIER);
                $setup(negedge D1 &&& xcheck2, negedge CLK, tSUd, NOTIFIER);
                $setup(posedge D0 &&& xcheck3, negedge CLK, tSUd, NOTIFIER);
                $setup(negedge D0 &&& xcheck3, negedge CLK, tSUd, NOTIFIER);
                $hold(negedge CLK, posedge S &&& xcheck1, tHDd, NOTIFIER);
                $hold(negedge CLK, negedge S &&& xcheck1, tHDd, NOTIFIER);
                $hold(negedge CLK, posedge D1 &&& xcheck2, tHDd, NOTIFIER);
                $hold(negedge CLK, negedge D1 &&& xcheck2, tHDd, NOTIFIER);
                $hold(negedge CLK, posedge D0 &&& xcheck3, tHDd, NOTIFIER);
                $hold(negedge CLK, negedge D0 &&& xcheck3, tHDd, NOTIFIER);
                $recovery(posedge CLR, negedge CLK &&& check2, tRECclr, NOTIFIER);
                $width(negedge CLK &&& check1, tPWclk, 0, NOTIFIER);
                $width(posedge CLK &&& check1, tPWclk, 0, NOTIFIER);
                $hold(negedge CLK, posedge CLR &&& check2, tHDclr, NOTIFIER);
                $hold(negedge CLK, negedge CLR &&& check2, tHDclr, NOTIFIER);
                $width(negedge CLR, tPWclr, 0, NOTIFIER);
        endspecify
endmodule

module fdmf2b3(Q, D0, D1, S, CLK, CLR);
        output Q;
        input  D0, D1, S, CLK, CLR;
        supply0 PRESET;
        reg NOTIFIER;
        mux g1(DATA, S, D1, D0);
        not g2(CLOCK, CLK);
        not g3(CLEAR, CLR);
        buf g4(Q, QOUT);
        ff g5(QOUT, DATA, CLOCK, PRESET, CLEAR, NOTIFIER);
        // CONDITIONAL TIMING CHECK SIGNALS
        not g6(check1, CLEAR);
        buf g7(check2, DATA);
        // EXTERNAL TIMING CHECK SIGNALS
        xor     g8(sstz1, D0, D1);
        xtc_and g9(xcheck1, check1, sstz1);
        xtc_and g11(xcheck2, check1, S);
        not     g12(sstz3, S);
        xtc_and g13(xcheck3, check1, sstz3);
        // SPECIFY BLOCK
        specify
                specparam tSUd = 0 ;
                specparam tHDd = 0 ;
                specparam tRECclr = 0 ;
                specparam tPWclk = 0 ;
                specparam tHDclr = 0 ;
                specparam tPWclr = 0 ;
                specparam CLK_10_LH_Q = 0, CLK_10_HL_Q = 0 ;
                specparam CLR_10_LH_Q = 0, CLR_10_HL_Q = 0 ;
                (negedge CLK *> (Q : 1'b1)) = (CLK_10_LH_Q, CLK_10_HL_Q) ;
                (negedge CLR *> (Q : 1'b1)) = (CLR_10_LH_Q, CLR_10_HL_Q) ;
                $setup(posedge S &&& xcheck1, negedge CLK, tSUd, NOTIFIER);
                $setup(negedge S &&& xcheck1, negedge CLK, tSUd, NOTIFIER);
                $setup(posedge D1 &&& xcheck2, negedge CLK, tSUd, NOTIFIER);
                $setup(negedge D1 &&& xcheck2, negedge CLK, tSUd, NOTIFIER);
                $setup(posedge D0 &&& xcheck3, negedge CLK, tSUd, NOTIFIER);
                $setup(negedge D0 &&& xcheck3, negedge CLK, tSUd, NOTIFIER);
                $hold(negedge CLK, posedge S &&& xcheck1, tHDd, NOTIFIER);
                $hold(negedge CLK, negedge S &&& xcheck1, tHDd, NOTIFIER);
                $hold(negedge CLK, posedge D1 &&& xcheck2, tHDd, NOTIFIER);
                $hold(negedge CLK, negedge D1 &&& xcheck2, tHDd, NOTIFIER);
                $hold(negedge CLK, posedge D0 &&& xcheck3, tHDd, NOTIFIER);
                $hold(negedge CLK, negedge D0 &&& xcheck3, tHDd, NOTIFIER);
                $recovery(posedge CLR, negedge CLK &&& check2, tRECclr, NOTIFIER);
                $width(negedge CLK &&& check1, tPWclk, 0, NOTIFIER);
                $width(posedge CLK &&& check1, tPWclk, 0, NOTIFIER);
                $hold(negedge CLK, posedge CLR &&& check2, tHDclr, NOTIFIER);
                $hold(negedge CLK, negedge CLR &&& check2, tHDclr, NOTIFIER);
                $width(negedge CLR, tPWclr, 0, NOTIFIER);
        endspecify
endmodule

module fdmf2b6(Q, D0, D1, S, CLK, CLR);
        output Q;
        input  D0, D1, S, CLK, CLR;
        supply0 PRESET;
        reg NOTIFIER;
        mux g1(DATA, S, D1, D0);
        not g2(CLOCK, CLK);
        not g3(CLEAR, CLR);
        buf g4(Q, QOUT);
        ff g5(QOUT, DATA, CLOCK, PRESET, CLEAR, NOTIFIER);
        // CONDITIONAL TIMING CHECK SIGNALS
        not g6(check1, CLEAR);
        buf g7(check2, DATA);
        // EXTERNAL TIMING CHECK SIGNALS
        xor     g8(sstz1, D0, D1);
        xtc_and g9(xcheck1, check1, sstz1);
        xtc_and g11(xcheck2, check1, S);
        not     g12(sstz3, S);
        xtc_and g13(xcheck3, check1, sstz3);
        // SPECIFY BLOCK
        specify
                specparam tSUd = 0 ;
                specparam tHDd = 0 ;
                specparam tRECclr = 0 ;
                specparam tPWclk = 0 ;
                specparam tHDclr = 0 ;
                specparam tPWclr = 0 ;
                specparam CLK_10_LH_Q = 0, CLK_10_HL_Q = 0 ;
                specparam CLR_10_LH_Q = 0, CLR_10_HL_Q = 0 ;
                (negedge CLK *> (Q : 1'b1)) = (CLK_10_LH_Q, CLK_10_HL_Q) ;
                (negedge CLR *> (Q : 1'b1)) = (CLR_10_LH_Q, CLR_10_HL_Q) ;
                $setup(posedge S &&& xcheck1, negedge CLK, tSUd, NOTIFIER);
                $setup(negedge S &&& xcheck1, negedge CLK, tSUd, NOTIFIER);
                $setup(posedge D1 &&& xcheck2, negedge CLK, tSUd, NOTIFIER);
                $setup(negedge D1 &&& xcheck2, negedge CLK, tSUd, NOTIFIER);
                $setup(posedge D0 &&& xcheck3, negedge CLK, tSUd, NOTIFIER);
                $setup(negedge D0 &&& xcheck3, negedge CLK, tSUd, NOTIFIER);
                $hold(negedge CLK, posedge S &&& xcheck1, tHDd, NOTIFIER);
                $hold(negedge CLK, negedge S &&& xcheck1, tHDd, NOTIFIER);
                $hold(negedge CLK, posedge D1 &&& xcheck2, tHDd, NOTIFIER);
                $hold(negedge CLK, negedge D1 &&& xcheck2, tHDd, NOTIFIER);
                $hold(negedge CLK, posedge D0 &&& xcheck3, tHDd, NOTIFIER);
                $hold(negedge CLK, negedge D0 &&& xcheck3, tHDd, NOTIFIER);
                $recovery(posedge CLR, negedge CLK &&& check2, tRECclr, NOTIFIER);
                $width(negedge CLK &&& check1, tPWclk, 0, NOTIFIER);
                $width(posedge CLK &&& check1, tPWclk, 0, NOTIFIER);
                $hold(negedge CLK, posedge CLR &&& check2, tHDclr, NOTIFIER);
                $hold(negedge CLK, negedge CLR &&& check2, tHDclr, NOTIFIER);
                $width(negedge CLR, tPWclr, 0, NOTIFIER);
        endspecify
endmodule

module fdmf2b9(Q, D0, D1, S, CLK, CLR);
        output Q;
        input  D0, D1, S, CLK, CLR;
        supply0 PRESET;
        reg NOTIFIER;
        mux g1(DATA, S, D1, D0);
        not g2(CLOCK, CLK);
        not g3(CLEAR, CLR);
        buf g4(Q, QOUT);
        ff g5(QOUT, DATA, CLOCK, PRESET, CLEAR, NOTIFIER);
        // CONDITIONAL TIMING CHECK SIGNALS
        not g6(check1, CLEAR);
        buf g7(check2, DATA);
        // EXTERNAL TIMING CHECK SIGNALS
        xor     g8(sstz1, D0, D1);
        xtc_and g9(xcheck1, check1, sstz1);
        xtc_and g11(xcheck2, check1, S);
        not     g12(sstz3, S);
        xtc_and g13(xcheck3, check1, sstz3);
        // SPECIFY BLOCK
        specify
                specparam tSUd = 0 ;
                specparam tHDd = 0 ;
                specparam tRECclr = 0 ;
                specparam tPWclk = 0 ;
                specparam tHDclr = 0 ;
                specparam tPWclr = 0 ;
                specparam CLK_10_LH_Q = 0, CLK_10_HL_Q = 0 ;
                specparam CLR_10_LH_Q = 0, CLR_10_HL_Q = 0 ;
                (negedge CLK *> (Q : 1'b1)) = (CLK_10_LH_Q, CLK_10_HL_Q) ;
                (negedge CLR *> (Q : 1'b1)) = (CLR_10_LH_Q, CLR_10_HL_Q) ;
                $setup(posedge S &&& xcheck1, negedge CLK, tSUd, NOTIFIER);
                $setup(negedge S &&& xcheck1, negedge CLK, tSUd, NOTIFIER);
                $setup(posedge D1 &&& xcheck2, negedge CLK, tSUd, NOTIFIER);
                $setup(negedge D1 &&& xcheck2, negedge CLK, tSUd, NOTIFIER);
                $setup(posedge D0 &&& xcheck3, negedge CLK, tSUd, NOTIFIER);
                $setup(negedge D0 &&& xcheck3, negedge CLK, tSUd, NOTIFIER);
                $hold(negedge CLK, posedge S &&& xcheck1, tHDd, NOTIFIER);
                $hold(negedge CLK, negedge S &&& xcheck1, tHDd, NOTIFIER);
                $hold(negedge CLK, posedge D1 &&& xcheck2, tHDd, NOTIFIER);
                $hold(negedge CLK, negedge D1 &&& xcheck2, tHDd, NOTIFIER);
                $hold(negedge CLK, posedge D0 &&& xcheck3, tHDd, NOTIFIER);
                $hold(negedge CLK, negedge D0 &&& xcheck3, tHDd, NOTIFIER);
                $recovery(posedge CLR, negedge CLK &&& check2, tRECclr, NOTIFIER);
                $width(negedge CLK &&& check1, tPWclk, 0, NOTIFIER);
                $width(posedge CLK &&& check1, tPWclk, 0, NOTIFIER);
                $hold(negedge CLK, posedge CLR &&& check2, tHDclr, NOTIFIER);
                $hold(negedge CLK, negedge CLR &&& check2, tHDclr, NOTIFIER);
                $width(negedge CLR, tPWclr, 0, NOTIFIER);
        endspecify
endmodule

module fdmf2c1(QN, D0, D1, S, CLK, CLR);
        output QN;
        input  D0, D1, S, CLK, CLR;
        supply0 PRESET;
        reg NOTIFIER;
        mux g1(DATA, S, D1, D0);
        not g2(CLEAR, CLR);
        not g3(QN, QOUT);
        ff g4(QOUT, DATA, CLK, PRESET, CLEAR, NOTIFIER);
        // CONDITIONAL TIMING CHECK SIGNALS
        not g5(check1, CLEAR);
        buf g6(check2, DATA);
        // EXTERNAL TIMING CHECK SIGNALS
        xor     g7(sstz1, D0, D1);
        xtc_and g8(xcheck1, check1, sstz1);
        xtc_and g10(xcheck2, check1, S);
        not     g11(sstz3, S);
        xtc_and g12(xcheck3, check1, sstz3);
        // SPECIFY BLOCK
        specify
                specparam tSUd = 0 ;
                specparam tHDd = 0 ;
                specparam tRECclr = 0 ;
                specparam tPWclk = 0 ;
                specparam tHDclr = 0 ;
                specparam tPWclr = 0 ;
                specparam CLK_01_LH_QN = 0, CLK_01_HL_QN = 0 ;
                specparam CLR_10_LH_QN = 0, CLR_10_HL_QN = 0 ;
                (posedge CLK *> (QN : 1'b1)) = (CLK_01_LH_QN, CLK_01_HL_QN) ;
                (negedge CLR *> (QN : 1'b1)) = (CLR_10_LH_QN, CLR_10_HL_QN) ;
                $setup(posedge S &&& xcheck1, posedge CLK, tSUd, NOTIFIER);
                $setup(negedge S &&& xcheck1, posedge CLK, tSUd, NOTIFIER);
                $setup(posedge D1 &&& xcheck2, posedge CLK, tSUd, NOTIFIER);
                $setup(negedge D1 &&& xcheck2, posedge CLK, tSUd, NOTIFIER);
                $setup(posedge D0 &&& xcheck3, posedge CLK, tSUd, NOTIFIER);
                $setup(negedge D0 &&& xcheck3, posedge CLK, tSUd, NOTIFIER);
                $hold(posedge CLK, posedge S &&& xcheck1, tHDd, NOTIFIER);
                $hold(posedge CLK, negedge S &&& xcheck1, tHDd, NOTIFIER);
                $hold(posedge CLK, posedge D1 &&& xcheck2, tHDd, NOTIFIER);
                $hold(posedge CLK, negedge D1 &&& xcheck2, tHDd, NOTIFIER);
                $hold(posedge CLK, posedge D0 &&& xcheck3, tHDd, NOTIFIER);
                $hold(posedge CLK, negedge D0 &&& xcheck3, tHDd, NOTIFIER);
                $recovery(posedge CLR, posedge CLK &&& check2, tRECclr, NOTIFIER);
                $width(posedge CLK &&& check1, tPWclk, 0, NOTIFIER);
                $width(negedge CLK &&& check1, tPWclk, 0, NOTIFIER);
                $hold(posedge CLK, posedge CLR &&& check2, tHDclr, NOTIFIER);
                $hold(posedge CLK, negedge CLR &&& check2, tHDclr, NOTIFIER);
                $width(negedge CLR, tPWclr, 0, NOTIFIER);
        endspecify
endmodule

module fdmf2c15(QN, D0, D1, S, CLK, CLR);
        output QN;
        input  D0, D1, S, CLK, CLR;
        supply0 PRESET;
        reg NOTIFIER;
        mux g1(DATA, S, D1, D0);
        not g2(CLEAR, CLR);
        not g3(QN, QOUT);
        ff g4(QOUT, DATA, CLK, PRESET, CLEAR, NOTIFIER);
        // CONDITIONAL TIMING CHECK SIGNALS
        not g5(check1, CLEAR);
        buf g6(check2, DATA);
        // EXTERNAL TIMING CHECK SIGNALS
        xor     g7(sstz1, D0, D1);
        xtc_and g8(xcheck1, check1, sstz1);
        xtc_and g10(xcheck2, check1, S);
        not     g11(sstz3, S);
        xtc_and g12(xcheck3, check1, sstz3);
        // SPECIFY BLOCK
        specify
                specparam tSUd = 0 ;
                specparam tHDd = 0 ;
                specparam tRECclr = 0 ;
                specparam tPWclk = 0 ;
                specparam tHDclr = 0 ;
                specparam tPWclr = 0 ;
                specparam CLK_01_LH_QN = 0, CLK_01_HL_QN = 0 ;
                specparam CLR_10_LH_QN = 0, CLR_10_HL_QN = 0 ;
                (posedge CLK *> (QN : 1'b1)) = (CLK_01_LH_QN, CLK_01_HL_QN) ;
                (negedge CLR *> (QN : 1'b1)) = (CLR_10_LH_QN, CLR_10_HL_QN) ;
                $setup(posedge S &&& xcheck1, posedge CLK, tSUd, NOTIFIER);
                $setup(negedge S &&& xcheck1, posedge CLK, tSUd, NOTIFIER);
                $setup(posedge D1 &&& xcheck2, posedge CLK, tSUd, NOTIFIER);
                $setup(negedge D1 &&& xcheck2, posedge CLK, tSUd, NOTIFIER);
                $setup(posedge D0 &&& xcheck3, posedge CLK, tSUd, NOTIFIER);
                $setup(negedge D0 &&& xcheck3, posedge CLK, tSUd, NOTIFIER);
                $hold(posedge CLK, posedge S &&& xcheck1, tHDd, NOTIFIER);
                $hold(posedge CLK, negedge S &&& xcheck1, tHDd, NOTIFIER);
                $hold(posedge CLK, posedge D1 &&& xcheck2, tHDd, NOTIFIER);
                $hold(posedge CLK, negedge D1 &&& xcheck2, tHDd, NOTIFIER);
                $hold(posedge CLK, posedge D0 &&& xcheck3, tHDd, NOTIFIER);
                $hold(posedge CLK, negedge D0 &&& xcheck3, tHDd, NOTIFIER);
                $recovery(posedge CLR, posedge CLK &&& check2, tRECclr, NOTIFIER);
                $width(posedge CLK &&& check1, tPWclk, 0, NOTIFIER);
                $width(negedge CLK &&& check1, tPWclk, 0, NOTIFIER);
                $hold(posedge CLK, posedge CLR &&& check2, tHDclr, NOTIFIER);
                $hold(posedge CLK, negedge CLR &&& check2, tHDclr, NOTIFIER);
                $width(negedge CLR, tPWclr, 0, NOTIFIER);
        endspecify
endmodule

module fdmf2c2(QN, D0, D1, S, CLK, CLR);
        output QN;
        input  D0, D1, S, CLK, CLR;
        supply0 PRESET;
        reg NOTIFIER;
        mux g1(DATA, S, D1, D0);
        not g2(CLEAR, CLR);
        not g3(QN, QOUT);
        ff g4(QOUT, DATA, CLK, PRESET, CLEAR, NOTIFIER);
        // CONDITIONAL TIMING CHECK SIGNALS
        not g5(check1, CLEAR);
        buf g6(check2, DATA);
        // EXTERNAL TIMING CHECK SIGNALS
        xor     g7(sstz1, D0, D1);
        xtc_and g8(xcheck1, check1, sstz1);
        xtc_and g10(xcheck2, check1, S);
        not     g11(sstz3, S);
        xtc_and g12(xcheck3, check1, sstz3);
        // SPECIFY BLOCK
        specify
                specparam tSUd = 0 ;
                specparam tHDd = 0 ;
                specparam tRECclr = 0 ;
                specparam tPWclk = 0 ;
                specparam tHDclr = 0 ;
                specparam tPWclr = 0 ;
                specparam CLK_01_LH_QN = 0, CLK_01_HL_QN = 0 ;
                specparam CLR_10_LH_QN = 0, CLR_10_HL_QN = 0 ;
                (posedge CLK *> (QN : 1'b1)) = (CLK_01_LH_QN, CLK_01_HL_QN) ;
                (negedge CLR *> (QN : 1'b1)) = (CLR_10_LH_QN, CLR_10_HL_QN) ;
                $setup(posedge S &&& xcheck1, posedge CLK, tSUd, NOTIFIER);
                $setup(negedge S &&& xcheck1, posedge CLK, tSUd, NOTIFIER);
                $setup(posedge D1 &&& xcheck2, posedge CLK, tSUd, NOTIFIER);
                $setup(negedge D1 &&& xcheck2, posedge CLK, tSUd, NOTIFIER);
                $setup(posedge D0 &&& xcheck3, posedge CLK, tSUd, NOTIFIER);
                $setup(negedge D0 &&& xcheck3, posedge CLK, tSUd, NOTIFIER);
                $hold(posedge CLK, posedge S &&& xcheck1, tHDd, NOTIFIER);
                $hold(posedge CLK, negedge S &&& xcheck1, tHDd, NOTIFIER);
                $hold(posedge CLK, posedge D1 &&& xcheck2, tHDd, NOTIFIER);
                $hold(posedge CLK, negedge D1 &&& xcheck2, tHDd, NOTIFIER);
                $hold(posedge CLK, posedge D0 &&& xcheck3, tHDd, NOTIFIER);
                $hold(posedge CLK, negedge D0 &&& xcheck3, tHDd, NOTIFIER);
                $recovery(posedge CLR, posedge CLK &&& check2, tRECclr, NOTIFIER);
                $width(posedge CLK &&& check1, tPWclk, 0, NOTIFIER);
                $width(negedge CLK &&& check1, tPWclk, 0, NOTIFIER);
                $hold(posedge CLK, posedge CLR &&& check2, tHDclr, NOTIFIER);
                $hold(posedge CLK, negedge CLR &&& check2, tHDclr, NOTIFIER);
                $width(negedge CLR, tPWclr, 0, NOTIFIER);
        endspecify
endmodule

module fdmf2c3(QN, D0, D1, S, CLK, CLR);
        output QN;
        input  D0, D1, S, CLK, CLR;
        supply0 PRESET;
        reg NOTIFIER;
        mux g1(DATA, S, D1, D0);
        not g2(CLEAR, CLR);
        not g3(QN, QOUT);
        ff g4(QOUT, DATA, CLK, PRESET, CLEAR, NOTIFIER);
        // CONDITIONAL TIMING CHECK SIGNALS
        not g5(check1, CLEAR);
        buf g6(check2, DATA);
        // EXTERNAL TIMING CHECK SIGNALS
        xor     g7(sstz1, D0, D1);
        xtc_and g8(xcheck1, check1, sstz1);
        xtc_and g10(xcheck2, check1, S);
        not     g11(sstz3, S);
        xtc_and g12(xcheck3, check1, sstz3);
        // SPECIFY BLOCK
        specify
                specparam tSUd = 0 ;
                specparam tHDd = 0 ;
                specparam tRECclr = 0 ;
                specparam tPWclk = 0 ;
                specparam tHDclr = 0 ;
                specparam tPWclr = 0 ;
                specparam CLK_01_LH_QN = 0, CLK_01_HL_QN = 0 ;
                specparam CLR_10_LH_QN = 0, CLR_10_HL_QN = 0 ;
                (posedge CLK *> (QN : 1'b1)) = (CLK_01_LH_QN, CLK_01_HL_QN) ;
                (negedge CLR *> (QN : 1'b1)) = (CLR_10_LH_QN, CLR_10_HL_QN) ;
                $setup(posedge S &&& xcheck1, posedge CLK, tSUd, NOTIFIER);
                $setup(negedge S &&& xcheck1, posedge CLK, tSUd, NOTIFIER);
                $setup(posedge D1 &&& xcheck2, posedge CLK, tSUd, NOTIFIER);
                $setup(negedge D1 &&& xcheck2, posedge CLK, tSUd, NOTIFIER);
                $setup(posedge D0 &&& xcheck3, posedge CLK, tSUd, NOTIFIER);
                $setup(negedge D0 &&& xcheck3, posedge CLK, tSUd, NOTIFIER);
                $hold(posedge CLK, posedge S &&& xcheck1, tHDd, NOTIFIER);
                $hold(posedge CLK, negedge S &&& xcheck1, tHDd, NOTIFIER);
                $hold(posedge CLK, posedge D1 &&& xcheck2, tHDd, NOTIFIER);
                $hold(posedge CLK, negedge D1 &&& xcheck2, tHDd, NOTIFIER);
                $hold(posedge CLK, posedge D0 &&& xcheck3, tHDd, NOTIFIER);
                $hold(posedge CLK, negedge D0 &&& xcheck3, tHDd, NOTIFIER);
                $recovery(posedge CLR, posedge CLK &&& check2, tRECclr, NOTIFIER);
                $width(posedge CLK &&& check1, tPWclk, 0, NOTIFIER);
                $width(negedge CLK &&& check1, tPWclk, 0, NOTIFIER);
                $hold(posedge CLK, posedge CLR &&& check2, tHDclr, NOTIFIER);
                $hold(posedge CLK, negedge CLR &&& check2, tHDclr, NOTIFIER);
                $width(negedge CLR, tPWclr, 0, NOTIFIER);
        endspecify
endmodule

module fdmf2c6(QN, D0, D1, S, CLK, CLR);
        output QN;
        input  D0, D1, S, CLK, CLR;
        supply0 PRESET;
        reg NOTIFIER;
        mux g1(DATA, S, D1, D0);
        not g2(CLEAR, CLR);
        not g3(QN, QOUT);
        ff g4(QOUT, DATA, CLK, PRESET, CLEAR, NOTIFIER);
        // CONDITIONAL TIMING CHECK SIGNALS
        not g5(check1, CLEAR);
        buf g6(check2, DATA);
        // EXTERNAL TIMING CHECK SIGNALS
        xor     g7(sstz1, D0, D1);
        xtc_and g8(xcheck1, check1, sstz1);
        xtc_and g10(xcheck2, check1, S);
        not     g11(sstz3, S);
        xtc_and g12(xcheck3, check1, sstz3);
        // SPECIFY BLOCK
        specify
                specparam tSUd = 0 ;
                specparam tHDd = 0 ;
                specparam tRECclr = 0 ;
                specparam tPWclk = 0 ;
                specparam tHDclr = 0 ;
                specparam tPWclr = 0 ;
                specparam CLK_01_LH_QN = 0, CLK_01_HL_QN = 0 ;
                specparam CLR_10_LH_QN = 0, CLR_10_HL_QN = 0 ;
                (posedge CLK *> (QN : 1'b1)) = (CLK_01_LH_QN, CLK_01_HL_QN) ;
                (negedge CLR *> (QN : 1'b1)) = (CLR_10_LH_QN, CLR_10_HL_QN) ;
                $setup(posedge S &&& xcheck1, posedge CLK, tSUd, NOTIFIER);
                $setup(negedge S &&& xcheck1, posedge CLK, tSUd, NOTIFIER);
                $setup(posedge D1 &&& xcheck2, posedge CLK, tSUd, NOTIFIER);
                $setup(negedge D1 &&& xcheck2, posedge CLK, tSUd, NOTIFIER);
                $setup(posedge D0 &&& xcheck3, posedge CLK, tSUd, NOTIFIER);
                $setup(negedge D0 &&& xcheck3, posedge CLK, tSUd, NOTIFIER);
                $hold(posedge CLK, posedge S &&& xcheck1, tHDd, NOTIFIER);
                $hold(posedge CLK, negedge S &&& xcheck1, tHDd, NOTIFIER);
                $hold(posedge CLK, posedge D1 &&& xcheck2, tHDd, NOTIFIER);
                $hold(posedge CLK, negedge D1 &&& xcheck2, tHDd, NOTIFIER);
                $hold(posedge CLK, posedge D0 &&& xcheck3, tHDd, NOTIFIER);
                $hold(posedge CLK, negedge D0 &&& xcheck3, tHDd, NOTIFIER);
                $recovery(posedge CLR, posedge CLK &&& check2, tRECclr, NOTIFIER);
                $width(posedge CLK &&& check1, tPWclk, 0, NOTIFIER);
                $width(negedge CLK &&& check1, tPWclk, 0, NOTIFIER);
                $hold(posedge CLK, posedge CLR &&& check2, tHDclr, NOTIFIER);
                $hold(posedge CLK, negedge CLR &&& check2, tHDclr, NOTIFIER);
                $width(negedge CLR, tPWclr, 0, NOTIFIER);
        endspecify
endmodule

module fdmf2c9(QN, D0, D1, S, CLK, CLR);
        output QN;
        input  D0, D1, S, CLK, CLR;
        supply0 PRESET;
        reg NOTIFIER;
        mux g1(DATA, S, D1, D0);
        not g2(CLEAR, CLR);
        not g3(QN, QOUT);
        ff g4(QOUT, DATA, CLK, PRESET, CLEAR, NOTIFIER);
        // CONDITIONAL TIMING CHECK SIGNALS
        not g5(check1, CLEAR);
        buf g6(check2, DATA);
        // EXTERNAL TIMING CHECK SIGNALS
        xor     g7(sstz1, D0, D1);
        xtc_and g8(xcheck1, check1, sstz1);
        xtc_and g10(xcheck2, check1, S);
        not     g11(sstz3, S);
        xtc_and g12(xcheck3, check1, sstz3);
        // SPECIFY BLOCK
        specify
                specparam tSUd = 0 ;
                specparam tHDd = 0 ;
                specparam tRECclr = 0 ;
                specparam tPWclk = 0 ;
                specparam tHDclr = 0 ;
                specparam tPWclr = 0 ;
                specparam CLK_01_LH_QN = 0, CLK_01_HL_QN = 0 ;
                specparam CLR_10_LH_QN = 0, CLR_10_HL_QN = 0 ;
                (posedge CLK *> (QN : 1'b1)) = (CLK_01_LH_QN, CLK_01_HL_QN) ;
                (negedge CLR *> (QN : 1'b1)) = (CLR_10_LH_QN, CLR_10_HL_QN) ;
                $setup(posedge S &&& xcheck1, posedge CLK, tSUd, NOTIFIER);
                $setup(negedge S &&& xcheck1, posedge CLK, tSUd, NOTIFIER);
                $setup(posedge D1 &&& xcheck2, posedge CLK, tSUd, NOTIFIER);
                $setup(negedge D1 &&& xcheck2, posedge CLK, tSUd, NOTIFIER);
                $setup(posedge D0 &&& xcheck3, posedge CLK, tSUd, NOTIFIER);
                $setup(negedge D0 &&& xcheck3, posedge CLK, tSUd, NOTIFIER);
                $hold(posedge CLK, posedge S &&& xcheck1, tHDd, NOTIFIER);
                $hold(posedge CLK, negedge S &&& xcheck1, tHDd, NOTIFIER);
                $hold(posedge CLK, posedge D1 &&& xcheck2, tHDd, NOTIFIER);
                $hold(posedge CLK, negedge D1 &&& xcheck2, tHDd, NOTIFIER);
                $hold(posedge CLK, posedge D0 &&& xcheck3, tHDd, NOTIFIER);
                $hold(posedge CLK, negedge D0 &&& xcheck3, tHDd, NOTIFIER);
                $recovery(posedge CLR, posedge CLK &&& check2, tRECclr, NOTIFIER);
                $width(posedge CLK &&& check1, tPWclk, 0, NOTIFIER);
                $width(negedge CLK &&& check1, tPWclk, 0, NOTIFIER);
                $hold(posedge CLK, posedge CLR &&& check2, tHDclr, NOTIFIER);
                $hold(posedge CLK, negedge CLR &&& check2, tHDclr, NOTIFIER);
                $width(negedge CLR, tPWclr, 0, NOTIFIER);
        endspecify
endmodule

module fdmf3a1(Q, D0, D1, S, CLK, PRE);
        output Q;
        input  D0, D1, S, CLK, PRE;
        supply0 CLEAR;
        reg NOTIFIER;
        mux g1(DATA, S, D1, D0);
        not g2(PRESET, PRE);
        buf g3(Q, QOUT);
        ff g4(QOUT, DATA, CLK, PRESET, CLEAR, NOTIFIER);
        // CONDITIONAL TIMING CHECK SIGNALS
        not g5(check1, PRESET);
        not g6(check2, DATA);
        // EXTERNAL TIMING CHECK SIGNALS
        xor     g7(sstz1, D0, D1);
        xtc_and g8(xcheck1, check1, sstz1);
        xtc_and g10(xcheck2, check1, S);
        not     g11(sstz3, S);
        xtc_and g12(xcheck3, check1, sstz3);
        // SPECIFY BLOCK
        specify
                specparam tSUd = 0 ;
                specparam tHDd = 0 ;
                specparam tRECpre = 0 ;
                specparam tPWclk = 0 ;
                specparam tHDpre = 0 ;
                specparam tPWpre = 0 ;
                specparam CLK_01_LH_Q = 0, CLK_01_HL_Q = 0 ;
                specparam PRE_10_LH_Q = 0, PRE_10_HL_Q = 0 ;
                (posedge CLK *> (Q : 1'b1)) = (CLK_01_LH_Q, CLK_01_HL_Q) ;
                (negedge PRE *> (Q : 1'b1)) = (PRE_10_LH_Q, PRE_10_HL_Q) ;
                $setup(posedge S &&& xcheck1, posedge CLK, tSUd, NOTIFIER);
                $setup(negedge S &&& xcheck1, posedge CLK, tSUd, NOTIFIER);
                $setup(posedge D1 &&& xcheck2, posedge CLK, tSUd, NOTIFIER);
                $setup(negedge D1 &&& xcheck2, posedge CLK, tSUd, NOTIFIER);
                $setup(posedge D0 &&& xcheck3, posedge CLK, tSUd, NOTIFIER);
                $setup(negedge D0 &&& xcheck3, posedge CLK, tSUd, NOTIFIER);
                $hold(posedge CLK, posedge S &&& xcheck1, tHDd, NOTIFIER);
                $hold(posedge CLK, negedge S &&& xcheck1, tHDd, NOTIFIER);
                $hold(posedge CLK, posedge D1 &&& xcheck2, tHDd, NOTIFIER);
                $hold(posedge CLK, negedge D1 &&& xcheck2, tHDd, NOTIFIER);
                $hold(posedge CLK, posedge D0 &&& xcheck3, tHDd, NOTIFIER);
                $hold(posedge CLK, negedge D0 &&& xcheck3, tHDd, NOTIFIER);
                $recovery(posedge PRE, posedge CLK &&& check2, tRECpre, NOTIFIER);
                $width(posedge CLK &&& check1, tPWclk, 0, NOTIFIER);
                $width(negedge CLK &&& check1, tPWclk, 0, NOTIFIER);
                $hold(posedge CLK, posedge PRE &&& check2, tHDpre, NOTIFIER);
                $hold(posedge CLK, negedge PRE &&& check2, tHDpre, NOTIFIER);
                $width(negedge PRE, tPWpre, 0, NOTIFIER);
        endspecify
endmodule

module fdmf3a15(Q, D0, D1, S, CLK, PRE);
        output Q;
        input  D0, D1, S, CLK, PRE;
        supply0 CLEAR;
        reg NOTIFIER;
        mux g1(DATA, S, D1, D0);
        not g2(PRESET, PRE);
        buf g3(Q, QOUT);
        ff g4(QOUT, DATA, CLK, PRESET, CLEAR, NOTIFIER);
        // CONDITIONAL TIMING CHECK SIGNALS
        not g5(check1, PRESET);
        not g6(check2, DATA);
        // EXTERNAL TIMING CHECK SIGNALS
        xor     g7(sstz1, D0, D1);
        xtc_and g8(xcheck1, check1, sstz1);
        xtc_and g10(xcheck2, check1, S);
        not     g11(sstz3, S);
        xtc_and g12(xcheck3, check1, sstz3);
        // SPECIFY BLOCK
        specify
                specparam tSUd = 0 ;
                specparam tHDd = 0 ;
                specparam tRECpre = 0 ;
                specparam tPWclk = 0 ;
                specparam tHDpre = 0 ;
                specparam tPWpre = 0 ;
                specparam CLK_01_LH_Q = 0, CLK_01_HL_Q = 0 ;
                specparam PRE_10_LH_Q = 0, PRE_10_HL_Q = 0 ;
                (posedge CLK *> (Q : 1'b1)) = (CLK_01_LH_Q, CLK_01_HL_Q) ;
                (negedge PRE *> (Q : 1'b1)) = (PRE_10_LH_Q, PRE_10_HL_Q) ;
                $setup(posedge S &&& xcheck1, posedge CLK, tSUd, NOTIFIER);
                $setup(negedge S &&& xcheck1, posedge CLK, tSUd, NOTIFIER);
                $setup(posedge D1 &&& xcheck2, posedge CLK, tSUd, NOTIFIER);
                $setup(negedge D1 &&& xcheck2, posedge CLK, tSUd, NOTIFIER);
                $setup(posedge D0 &&& xcheck3, posedge CLK, tSUd, NOTIFIER);
                $setup(negedge D0 &&& xcheck3, posedge CLK, tSUd, NOTIFIER);
                $hold(posedge CLK, posedge S &&& xcheck1, tHDd, NOTIFIER);
                $hold(posedge CLK, negedge S &&& xcheck1, tHDd, NOTIFIER);
                $hold(posedge CLK, posedge D1 &&& xcheck2, tHDd, NOTIFIER);
                $hold(posedge CLK, negedge D1 &&& xcheck2, tHDd, NOTIFIER);
                $hold(posedge CLK, posedge D0 &&& xcheck3, tHDd, NOTIFIER);
                $hold(posedge CLK, negedge D0 &&& xcheck3, tHDd, NOTIFIER);
                $recovery(posedge PRE, posedge CLK &&& check2, tRECpre, NOTIFIER);
                $width(posedge CLK &&& check1, tPWclk, 0, NOTIFIER);
                $width(negedge CLK &&& check1, tPWclk, 0, NOTIFIER);
                $hold(posedge CLK, posedge PRE &&& check2, tHDpre, NOTIFIER);
                $hold(posedge CLK, negedge PRE &&& check2, tHDpre, NOTIFIER);
                $width(negedge PRE, tPWpre, 0, NOTIFIER);
        endspecify
endmodule

module fdmf3a2(Q, D0, D1, S, CLK, PRE);
        output Q;
        input  D0, D1, S, CLK, PRE;
        supply0 CLEAR;
        reg NOTIFIER;
        mux g1(DATA, S, D1, D0);
        not g2(PRESET, PRE);
        buf g3(Q, QOUT);
        ff g4(QOUT, DATA, CLK, PRESET, CLEAR, NOTIFIER);
        // CONDITIONAL TIMING CHECK SIGNALS
        not g5(check1, PRESET);
        not g6(check2, DATA);
        // EXTERNAL TIMING CHECK SIGNALS
        xor     g7(sstz1, D0, D1);
        xtc_and g8(xcheck1, check1, sstz1);
        xtc_and g10(xcheck2, check1, S);
        not     g11(sstz3, S);
        xtc_and g12(xcheck3, check1, sstz3);
        // SPECIFY BLOCK
        specify
                specparam tSUd = 0 ;
                specparam tHDd = 0 ;
                specparam tRECpre = 0 ;
                specparam tPWclk = 0 ;
                specparam tHDpre = 0 ;
                specparam tPWpre = 0 ;
                specparam CLK_01_LH_Q = 0, CLK_01_HL_Q = 0 ;
                specparam PRE_10_LH_Q = 0, PRE_10_HL_Q = 0 ;
                (posedge CLK *> (Q : 1'b1)) = (CLK_01_LH_Q, CLK_01_HL_Q) ;
                (negedge PRE *> (Q : 1'b1)) = (PRE_10_LH_Q, PRE_10_HL_Q) ;
                $setup(posedge S &&& xcheck1, posedge CLK, tSUd, NOTIFIER);
                $setup(negedge S &&& xcheck1, posedge CLK, tSUd, NOTIFIER);
                $setup(posedge D1 &&& xcheck2, posedge CLK, tSUd, NOTIFIER);
                $setup(negedge D1 &&& xcheck2, posedge CLK, tSUd, NOTIFIER);
                $setup(posedge D0 &&& xcheck3, posedge CLK, tSUd, NOTIFIER);
                $setup(negedge D0 &&& xcheck3, posedge CLK, tSUd, NOTIFIER);
                $hold(posedge CLK, posedge S &&& xcheck1, tHDd, NOTIFIER);
                $hold(posedge CLK, negedge S &&& xcheck1, tHDd, NOTIFIER);
                $hold(posedge CLK, posedge D1 &&& xcheck2, tHDd, NOTIFIER);
                $hold(posedge CLK, negedge D1 &&& xcheck2, tHDd, NOTIFIER);
                $hold(posedge CLK, posedge D0 &&& xcheck3, tHDd, NOTIFIER);
                $hold(posedge CLK, negedge D0 &&& xcheck3, tHDd, NOTIFIER);
                $recovery(posedge PRE, posedge CLK &&& check2, tRECpre, NOTIFIER);
                $width(posedge CLK &&& check1, tPWclk, 0, NOTIFIER);
                $width(negedge CLK &&& check1, tPWclk, 0, NOTIFIER);
                $hold(posedge CLK, posedge PRE &&& check2, tHDpre, NOTIFIER);
                $hold(posedge CLK, negedge PRE &&& check2, tHDpre, NOTIFIER);
                $width(negedge PRE, tPWpre, 0, NOTIFIER);
        endspecify
endmodule

module fdmf3a3(Q, D0, D1, S, CLK, PRE);
        output Q;
        input  D0, D1, S, CLK, PRE;
        supply0 CLEAR;
        reg NOTIFIER;
        mux g1(DATA, S, D1, D0);
        not g2(PRESET, PRE);
        buf g3(Q, QOUT);
        ff g4(QOUT, DATA, CLK, PRESET, CLEAR, NOTIFIER);
        // CONDITIONAL TIMING CHECK SIGNALS
        not g5(check1, PRESET);
        not g6(check2, DATA);
        // EXTERNAL TIMING CHECK SIGNALS
        xor     g7(sstz1, D0, D1);
        xtc_and g8(xcheck1, check1, sstz1);
        xtc_and g10(xcheck2, check1, S);
        not     g11(sstz3, S);
        xtc_and g12(xcheck3, check1, sstz3);
        // SPECIFY BLOCK
        specify
                specparam tSUd = 0 ;
                specparam tHDd = 0 ;
                specparam tRECpre = 0 ;
                specparam tPWclk = 0 ;
                specparam tHDpre = 0 ;
                specparam tPWpre = 0 ;
                specparam CLK_01_LH_Q = 0, CLK_01_HL_Q = 0 ;
                specparam PRE_10_LH_Q = 0, PRE_10_HL_Q = 0 ;
                (posedge CLK *> (Q : 1'b1)) = (CLK_01_LH_Q, CLK_01_HL_Q) ;
                (negedge PRE *> (Q : 1'b1)) = (PRE_10_LH_Q, PRE_10_HL_Q) ;
                $setup(posedge S &&& xcheck1, posedge CLK, tSUd, NOTIFIER);
                $setup(negedge S &&& xcheck1, posedge CLK, tSUd, NOTIFIER);
                $setup(posedge D1 &&& xcheck2, posedge CLK, tSUd, NOTIFIER);
                $setup(negedge D1 &&& xcheck2, posedge CLK, tSUd, NOTIFIER);
                $setup(posedge D0 &&& xcheck3, posedge CLK, tSUd, NOTIFIER);
                $setup(negedge D0 &&& xcheck3, posedge CLK, tSUd, NOTIFIER);
                $hold(posedge CLK, posedge S &&& xcheck1, tHDd, NOTIFIER);
                $hold(posedge CLK, negedge S &&& xcheck1, tHDd, NOTIFIER);
                $hold(posedge CLK, posedge D1 &&& xcheck2, tHDd, NOTIFIER);
                $hold(posedge CLK, negedge D1 &&& xcheck2, tHDd, NOTIFIER);
                $hold(posedge CLK, posedge D0 &&& xcheck3, tHDd, NOTIFIER);
                $hold(posedge CLK, negedge D0 &&& xcheck3, tHDd, NOTIFIER);
                $recovery(posedge PRE, posedge CLK &&& check2, tRECpre, NOTIFIER);
                $width(posedge CLK &&& check1, tPWclk, 0, NOTIFIER);
                $width(negedge CLK &&& check1, tPWclk, 0, NOTIFIER);
                $hold(posedge CLK, posedge PRE &&& check2, tHDpre, NOTIFIER);
                $hold(posedge CLK, negedge PRE &&& check2, tHDpre, NOTIFIER);
                $width(negedge PRE, tPWpre, 0, NOTIFIER);
        endspecify
endmodule

module fdmf3a6(Q, D0, D1, S, CLK, PRE);
        output Q;
        input  D0, D1, S, CLK, PRE;
        supply0 CLEAR;
        reg NOTIFIER;
        mux g1(DATA, S, D1, D0);
        not g2(PRESET, PRE);
        buf g3(Q, QOUT);
        ff g4(QOUT, DATA, CLK, PRESET, CLEAR, NOTIFIER);
        // CONDITIONAL TIMING CHECK SIGNALS
        not g5(check1, PRESET);
        not g6(check2, DATA);
        // EXTERNAL TIMING CHECK SIGNALS
        xor     g7(sstz1, D0, D1);
        xtc_and g8(xcheck1, check1, sstz1);
        xtc_and g10(xcheck2, check1, S);
        not     g11(sstz3, S);
        xtc_and g12(xcheck3, check1, sstz3);
        // SPECIFY BLOCK
        specify
                specparam tSUd = 0 ;
                specparam tHDd = 0 ;
                specparam tRECpre = 0 ;
                specparam tPWclk = 0 ;
                specparam tHDpre = 0 ;
                specparam tPWpre = 0 ;
                specparam CLK_01_LH_Q = 0, CLK_01_HL_Q = 0 ;
                specparam PRE_10_LH_Q = 0, PRE_10_HL_Q = 0 ;
                (posedge CLK *> (Q : 1'b1)) = (CLK_01_LH_Q, CLK_01_HL_Q) ;
                (negedge PRE *> (Q : 1'b1)) = (PRE_10_LH_Q, PRE_10_HL_Q) ;
                $setup(posedge S &&& xcheck1, posedge CLK, tSUd, NOTIFIER);
                $setup(negedge S &&& xcheck1, posedge CLK, tSUd, NOTIFIER);
                $setup(posedge D1 &&& xcheck2, posedge CLK, tSUd, NOTIFIER);
                $setup(negedge D1 &&& xcheck2, posedge CLK, tSUd, NOTIFIER);
                $setup(posedge D0 &&& xcheck3, posedge CLK, tSUd, NOTIFIER);
                $setup(negedge D0 &&& xcheck3, posedge CLK, tSUd, NOTIFIER);
                $hold(posedge CLK, posedge S &&& xcheck1, tHDd, NOTIFIER);
                $hold(posedge CLK, negedge S &&& xcheck1, tHDd, NOTIFIER);
                $hold(posedge CLK, posedge D1 &&& xcheck2, tHDd, NOTIFIER);
                $hold(posedge CLK, negedge D1 &&& xcheck2, tHDd, NOTIFIER);
                $hold(posedge CLK, posedge D0 &&& xcheck3, tHDd, NOTIFIER);
                $hold(posedge CLK, negedge D0 &&& xcheck3, tHDd, NOTIFIER);
                $recovery(posedge PRE, posedge CLK &&& check2, tRECpre, NOTIFIER);
                $width(posedge CLK &&& check1, tPWclk, 0, NOTIFIER);
                $width(negedge CLK &&& check1, tPWclk, 0, NOTIFIER);
                $hold(posedge CLK, posedge PRE &&& check2, tHDpre, NOTIFIER);
                $hold(posedge CLK, negedge PRE &&& check2, tHDpre, NOTIFIER);
                $width(negedge PRE, tPWpre, 0, NOTIFIER);
        endspecify
endmodule

module fdmf3a9(Q, D0, D1, S, CLK, PRE);
        output Q;
        input  D0, D1, S, CLK, PRE;
        supply0 CLEAR;
        reg NOTIFIER;
        mux g1(DATA, S, D1, D0);
        not g2(PRESET, PRE);
        buf g3(Q, QOUT);
        ff g4(QOUT, DATA, CLK, PRESET, CLEAR, NOTIFIER);
        // CONDITIONAL TIMING CHECK SIGNALS
        not g5(check1, PRESET);
        not g6(check2, DATA);
        // EXTERNAL TIMING CHECK SIGNALS
        xor     g7(sstz1, D0, D1);
        xtc_and g8(xcheck1, check1, sstz1);
        xtc_and g10(xcheck2, check1, S);
        not     g11(sstz3, S);
        xtc_and g12(xcheck3, check1, sstz3);
        // SPECIFY BLOCK
        specify
                specparam tSUd = 0 ;
                specparam tHDd = 0 ;
                specparam tRECpre = 0 ;
                specparam tPWclk = 0 ;
                specparam tHDpre = 0 ;
                specparam tPWpre = 0 ;
                specparam CLK_01_LH_Q = 0, CLK_01_HL_Q = 0 ;
                specparam PRE_10_LH_Q = 0, PRE_10_HL_Q = 0 ;
                (posedge CLK *> (Q : 1'b1)) = (CLK_01_LH_Q, CLK_01_HL_Q) ;
                (negedge PRE *> (Q : 1'b1)) = (PRE_10_LH_Q, PRE_10_HL_Q) ;
                $setup(posedge S &&& xcheck1, posedge CLK, tSUd, NOTIFIER);
                $setup(negedge S &&& xcheck1, posedge CLK, tSUd, NOTIFIER);
                $setup(posedge D1 &&& xcheck2, posedge CLK, tSUd, NOTIFIER);
                $setup(negedge D1 &&& xcheck2, posedge CLK, tSUd, NOTIFIER);
                $setup(posedge D0 &&& xcheck3, posedge CLK, tSUd, NOTIFIER);
                $setup(negedge D0 &&& xcheck3, posedge CLK, tSUd, NOTIFIER);
                $hold(posedge CLK, posedge S &&& xcheck1, tHDd, NOTIFIER);
                $hold(posedge CLK, negedge S &&& xcheck1, tHDd, NOTIFIER);
                $hold(posedge CLK, posedge D1 &&& xcheck2, tHDd, NOTIFIER);
                $hold(posedge CLK, negedge D1 &&& xcheck2, tHDd, NOTIFIER);
                $hold(posedge CLK, posedge D0 &&& xcheck3, tHDd, NOTIFIER);
                $hold(posedge CLK, negedge D0 &&& xcheck3, tHDd, NOTIFIER);
                $recovery(posedge PRE, posedge CLK &&& check2, tRECpre, NOTIFIER);
                $width(posedge CLK &&& check1, tPWclk, 0, NOTIFIER);
                $width(negedge CLK &&& check1, tPWclk, 0, NOTIFIER);
                $hold(posedge CLK, posedge PRE &&& check2, tHDpre, NOTIFIER);
                $hold(posedge CLK, negedge PRE &&& check2, tHDpre, NOTIFIER);
                $width(negedge PRE, tPWpre, 0, NOTIFIER);
        endspecify
endmodule

module fdmf3b1(Q, D0, D1, S, CLK, PRE);
        output Q;
        input  D0, D1, S, CLK, PRE;
        supply0 CLEAR;
        reg NOTIFIER;
        mux g1(DATA, S, D1, D0);
        not g2(CLOCK, CLK);
        not g3(PRESET, PRE);
        buf g4(Q, QOUT);
        ff g5(QOUT, DATA, CLOCK, PRESET, CLEAR, NOTIFIER);
        // CONDITIONAL TIMING CHECK SIGNALS
        not g6(check1, PRESET);
        not g7(check2, DATA);
        // EXTERNAL TIMING CHECK SIGNALS
        xor     g8(sstz1, D0, D1);
        xtc_and g9(xcheck1, check1, sstz1);
        xtc_and g11(xcheck2, check1, S);
        not     g12(sstz3, S);
        xtc_and g13(xcheck3, check1, sstz3);
        // SPECIFY BLOCK
        specify
                specparam tSUd = 0 ;
                specparam tHDd = 0 ;
                specparam tRECpre = 0 ;
                specparam tPWclk = 0 ;
                specparam tHDpre = 0 ;
                specparam tPWpre = 0 ;
                specparam CLK_10_LH_Q = 0, CLK_10_HL_Q = 0 ;
                specparam PRE_10_LH_Q = 0, PRE_10_HL_Q = 0 ;
                (negedge CLK *> (Q : 1'b1)) = (CLK_10_LH_Q, CLK_10_HL_Q) ;
                (negedge PRE *> (Q : 1'b1)) = (PRE_10_LH_Q, PRE_10_HL_Q) ;
                $setup(posedge S &&& xcheck1, negedge CLK, tSUd, NOTIFIER);
                $setup(negedge S &&& xcheck1, negedge CLK, tSUd, NOTIFIER);
                $setup(posedge D1 &&& xcheck2, negedge CLK, tSUd, NOTIFIER);
                $setup(negedge D1 &&& xcheck2, negedge CLK, tSUd, NOTIFIER);
                $setup(posedge D0 &&& xcheck3, negedge CLK, tSUd, NOTIFIER);
                $setup(negedge D0 &&& xcheck3, negedge CLK, tSUd, NOTIFIER);
                $hold(negedge CLK, posedge S &&& xcheck1, tHDd, NOTIFIER);
                $hold(negedge CLK, negedge S &&& xcheck1, tHDd, NOTIFIER);
                $hold(negedge CLK, posedge D1 &&& xcheck2, tHDd, NOTIFIER);
                $hold(negedge CLK, negedge D1 &&& xcheck2, tHDd, NOTIFIER);
                $hold(negedge CLK, posedge D0 &&& xcheck3, tHDd, NOTIFIER);
                $hold(negedge CLK, negedge D0 &&& xcheck3, tHDd, NOTIFIER);
                $recovery(posedge PRE, negedge CLK &&& check2, tRECpre, NOTIFIER);
                $width(negedge CLK &&& check1, tPWclk, 0, NOTIFIER);
                $width(posedge CLK &&& check1, tPWclk, 0, NOTIFIER);
                $hold(negedge CLK, posedge PRE &&& check2, tHDpre, NOTIFIER);
                $hold(negedge CLK, negedge PRE &&& check2, tHDpre, NOTIFIER);
                $width(negedge PRE, tPWpre, 0, NOTIFIER);
        endspecify
endmodule

module fdmf3b15(Q, D0, D1, S, CLK, PRE);
        output Q;
        input  D0, D1, S, CLK, PRE;
        supply0 CLEAR;
        reg NOTIFIER;
        mux g1(DATA, S, D1, D0);
        not g2(CLOCK, CLK);
        not g3(PRESET, PRE);
        buf g4(Q, QOUT);
        ff g5(QOUT, DATA, CLOCK, PRESET, CLEAR, NOTIFIER);
        // CONDITIONAL TIMING CHECK SIGNALS
        not g6(check1, PRESET);
        not g7(check2, DATA);
        // EXTERNAL TIMING CHECK SIGNALS
        xor     g8(sstz1, D0, D1);
        xtc_and g9(xcheck1, check1, sstz1);
        xtc_and g11(xcheck2, check1, S);
        not     g12(sstz3, S);
        xtc_and g13(xcheck3, check1, sstz3);
        // SPECIFY BLOCK
        specify
                specparam tSUd = 0 ;
                specparam tHDd = 0 ;
                specparam tRECpre = 0 ;
                specparam tPWclk = 0 ;
                specparam tHDpre = 0 ;
                specparam tPWpre = 0 ;
                specparam CLK_10_LH_Q = 0, CLK_10_HL_Q = 0 ;
                specparam PRE_10_LH_Q = 0, PRE_10_HL_Q = 0 ;
                (negedge CLK *> (Q : 1'b1)) = (CLK_10_LH_Q, CLK_10_HL_Q) ;
                (negedge PRE *> (Q : 1'b1)) = (PRE_10_LH_Q, PRE_10_HL_Q) ;
                $setup(posedge S &&& xcheck1, negedge CLK, tSUd, NOTIFIER);
                $setup(negedge S &&& xcheck1, negedge CLK, tSUd, NOTIFIER);
                $setup(posedge D1 &&& xcheck2, negedge CLK, tSUd, NOTIFIER);
                $setup(negedge D1 &&& xcheck2, negedge CLK, tSUd, NOTIFIER);
                $setup(posedge D0 &&& xcheck3, negedge CLK, tSUd, NOTIFIER);
                $setup(negedge D0 &&& xcheck3, negedge CLK, tSUd, NOTIFIER);
                $hold(negedge CLK, posedge S &&& xcheck1, tHDd, NOTIFIER);
                $hold(negedge CLK, negedge S &&& xcheck1, tHDd, NOTIFIER);
                $hold(negedge CLK, posedge D1 &&& xcheck2, tHDd, NOTIFIER);
                $hold(negedge CLK, negedge D1 &&& xcheck2, tHDd, NOTIFIER);
                $hold(negedge CLK, posedge D0 &&& xcheck3, tHDd, NOTIFIER);
                $hold(negedge CLK, negedge D0 &&& xcheck3, tHDd, NOTIFIER);
                $recovery(posedge PRE, negedge CLK &&& check2, tRECpre, NOTIFIER);
                $width(negedge CLK &&& check1, tPWclk, 0, NOTIFIER);
                $width(posedge CLK &&& check1, tPWclk, 0, NOTIFIER);
                $hold(negedge CLK, posedge PRE &&& check2, tHDpre, NOTIFIER);
                $hold(negedge CLK, negedge PRE &&& check2, tHDpre, NOTIFIER);
                $width(negedge PRE, tPWpre, 0, NOTIFIER);
        endspecify
endmodule

module fdmf3b2(Q, D0, D1, S, CLK, PRE);
        output Q;
        input  D0, D1, S, CLK, PRE;
        supply0 CLEAR;
        reg NOTIFIER;
        mux g1(DATA, S, D1, D0);
        not g2(CLOCK, CLK);
        not g3(PRESET, PRE);
        buf g4(Q, QOUT);
        ff g5(QOUT, DATA, CLOCK, PRESET, CLEAR, NOTIFIER);
        // CONDITIONAL TIMING CHECK SIGNALS
        not g6(check1, PRESET);
        not g7(check2, DATA);
        // EXTERNAL TIMING CHECK SIGNALS
        xor     g8(sstz1, D0, D1);
        xtc_and g9(xcheck1, check1, sstz1);
        xtc_and g11(xcheck2, check1, S);
        not     g12(sstz3, S);
        xtc_and g13(xcheck3, check1, sstz3);
        // SPECIFY BLOCK
        specify
                specparam tSUd = 0 ;
                specparam tHDd = 0 ;
                specparam tRECpre = 0 ;
                specparam tPWclk = 0 ;
                specparam tHDpre = 0 ;
                specparam tPWpre = 0 ;
                specparam CLK_10_LH_Q = 0, CLK_10_HL_Q = 0 ;
                specparam PRE_10_LH_Q = 0, PRE_10_HL_Q = 0 ;
                (negedge CLK *> (Q : 1'b1)) = (CLK_10_LH_Q, CLK_10_HL_Q) ;
                (negedge PRE *> (Q : 1'b1)) = (PRE_10_LH_Q, PRE_10_HL_Q) ;
                $setup(posedge S &&& xcheck1, negedge CLK, tSUd, NOTIFIER);
                $setup(negedge S &&& xcheck1, negedge CLK, tSUd, NOTIFIER);
                $setup(posedge D1 &&& xcheck2, negedge CLK, tSUd, NOTIFIER);
                $setup(negedge D1 &&& xcheck2, negedge CLK, tSUd, NOTIFIER);
                $setup(posedge D0 &&& xcheck3, negedge CLK, tSUd, NOTIFIER);
                $setup(negedge D0 &&& xcheck3, negedge CLK, tSUd, NOTIFIER);
                $hold(negedge CLK, posedge S &&& xcheck1, tHDd, NOTIFIER);
                $hold(negedge CLK, negedge S &&& xcheck1, tHDd, NOTIFIER);
                $hold(negedge CLK, posedge D1 &&& xcheck2, tHDd, NOTIFIER);
                $hold(negedge CLK, negedge D1 &&& xcheck2, tHDd, NOTIFIER);
                $hold(negedge CLK, posedge D0 &&& xcheck3, tHDd, NOTIFIER);
                $hold(negedge CLK, negedge D0 &&& xcheck3, tHDd, NOTIFIER);
                $recovery(posedge PRE, negedge CLK &&& check2, tRECpre, NOTIFIER);
                $width(negedge CLK &&& check1, tPWclk, 0, NOTIFIER);
                $width(posedge CLK &&& check1, tPWclk, 0, NOTIFIER);
                $hold(negedge CLK, posedge PRE &&& check2, tHDpre, NOTIFIER);
                $hold(negedge CLK, negedge PRE &&& check2, tHDpre, NOTIFIER);
                $width(negedge PRE, tPWpre, 0, NOTIFIER);
        endspecify
endmodule

module fdmf3b3(Q, D0, D1, S, CLK, PRE);
        output Q;
        input  D0, D1, S, CLK, PRE;
        supply0 CLEAR;
        reg NOTIFIER;
        mux g1(DATA, S, D1, D0);
        not g2(CLOCK, CLK);
        not g3(PRESET, PRE);
        buf g4(Q, QOUT);
        ff g5(QOUT, DATA, CLOCK, PRESET, CLEAR, NOTIFIER);
        // CONDITIONAL TIMING CHECK SIGNALS
        not g6(check1, PRESET);
        not g7(check2, DATA);
        // EXTERNAL TIMING CHECK SIGNALS
        xor     g8(sstz1, D0, D1);
        xtc_and g9(xcheck1, check1, sstz1);
        xtc_and g11(xcheck2, check1, S);
        not     g12(sstz3, S);
        xtc_and g13(xcheck3, check1, sstz3);
        // SPECIFY BLOCK
        specify
                specparam tSUd = 0 ;
                specparam tHDd = 0 ;
                specparam tRECpre = 0 ;
                specparam tPWclk = 0 ;
                specparam tHDpre = 0 ;
                specparam tPWpre = 0 ;
                specparam CLK_10_LH_Q = 0, CLK_10_HL_Q = 0 ;
                specparam PRE_10_LH_Q = 0, PRE_10_HL_Q = 0 ;
                (negedge CLK *> (Q : 1'b1)) = (CLK_10_LH_Q, CLK_10_HL_Q) ;
                (negedge PRE *> (Q : 1'b1)) = (PRE_10_LH_Q, PRE_10_HL_Q) ;
                $setup(posedge S &&& xcheck1, negedge CLK, tSUd, NOTIFIER);
                $setup(negedge S &&& xcheck1, negedge CLK, tSUd, NOTIFIER);
                $setup(posedge D1 &&& xcheck2, negedge CLK, tSUd, NOTIFIER);
                $setup(negedge D1 &&& xcheck2, negedge CLK, tSUd, NOTIFIER);
                $setup(posedge D0 &&& xcheck3, negedge CLK, tSUd, NOTIFIER);
                $setup(negedge D0 &&& xcheck3, negedge CLK, tSUd, NOTIFIER);
                $hold(negedge CLK, posedge S &&& xcheck1, tHDd, NOTIFIER);
                $hold(negedge CLK, negedge S &&& xcheck1, tHDd, NOTIFIER);
                $hold(negedge CLK, posedge D1 &&& xcheck2, tHDd, NOTIFIER);
                $hold(negedge CLK, negedge D1 &&& xcheck2, tHDd, NOTIFIER);
                $hold(negedge CLK, posedge D0 &&& xcheck3, tHDd, NOTIFIER);
                $hold(negedge CLK, negedge D0 &&& xcheck3, tHDd, NOTIFIER);
                $recovery(posedge PRE, negedge CLK &&& check2, tRECpre, NOTIFIER);
                $width(negedge CLK &&& check1, tPWclk, 0, NOTIFIER);
                $width(posedge CLK &&& check1, tPWclk, 0, NOTIFIER);
                $hold(negedge CLK, posedge PRE &&& check2, tHDpre, NOTIFIER);
                $hold(negedge CLK, negedge PRE &&& check2, tHDpre, NOTIFIER);
                $width(negedge PRE, tPWpre, 0, NOTIFIER);
        endspecify
endmodule

module fdmf3b6(Q, D0, D1, S, CLK, PRE);
        output Q;
        input  D0, D1, S, CLK, PRE;
        supply0 CLEAR;
        reg NOTIFIER;
        mux g1(DATA, S, D1, D0);
        not g2(CLOCK, CLK);
        not g3(PRESET, PRE);
        buf g4(Q, QOUT);
        ff g5(QOUT, DATA, CLOCK, PRESET, CLEAR, NOTIFIER);
        // CONDITIONAL TIMING CHECK SIGNALS
        not g6(check1, PRESET);
        not g7(check2, DATA);
        // EXTERNAL TIMING CHECK SIGNALS
        xor     g8(sstz1, D0, D1);
        xtc_and g9(xcheck1, check1, sstz1);
        xtc_and g11(xcheck2, check1, S);
        not     g12(sstz3, S);
        xtc_and g13(xcheck3, check1, sstz3);
        // SPECIFY BLOCK
        specify
                specparam tSUd = 0 ;
                specparam tHDd = 0 ;
                specparam tRECpre = 0 ;
                specparam tPWclk = 0 ;
                specparam tHDpre = 0 ;
                specparam tPWpre = 0 ;
                specparam CLK_10_LH_Q = 0, CLK_10_HL_Q = 0 ;
                specparam PRE_10_LH_Q = 0, PRE_10_HL_Q = 0 ;
                (negedge CLK *> (Q : 1'b1)) = (CLK_10_LH_Q, CLK_10_HL_Q) ;
                (negedge PRE *> (Q : 1'b1)) = (PRE_10_LH_Q, PRE_10_HL_Q) ;
                $setup(posedge S &&& xcheck1, negedge CLK, tSUd, NOTIFIER);
                $setup(negedge S &&& xcheck1, negedge CLK, tSUd, NOTIFIER);
                $setup(posedge D1 &&& xcheck2, negedge CLK, tSUd, NOTIFIER);
                $setup(negedge D1 &&& xcheck2, negedge CLK, tSUd, NOTIFIER);
                $setup(posedge D0 &&& xcheck3, negedge CLK, tSUd, NOTIFIER);
                $setup(negedge D0 &&& xcheck3, negedge CLK, tSUd, NOTIFIER);
                $hold(negedge CLK, posedge S &&& xcheck1, tHDd, NOTIFIER);
                $hold(negedge CLK, negedge S &&& xcheck1, tHDd, NOTIFIER);
                $hold(negedge CLK, posedge D1 &&& xcheck2, tHDd, NOTIFIER);
                $hold(negedge CLK, negedge D1 &&& xcheck2, tHDd, NOTIFIER);
                $hold(negedge CLK, posedge D0 &&& xcheck3, tHDd, NOTIFIER);
                $hold(negedge CLK, negedge D0 &&& xcheck3, tHDd, NOTIFIER);
                $recovery(posedge PRE, negedge CLK &&& check2, tRECpre, NOTIFIER);
                $width(negedge CLK &&& check1, tPWclk, 0, NOTIFIER);
                $width(posedge CLK &&& check1, tPWclk, 0, NOTIFIER);
                $hold(negedge CLK, posedge PRE &&& check2, tHDpre, NOTIFIER);
                $hold(negedge CLK, negedge PRE &&& check2, tHDpre, NOTIFIER);
                $width(negedge PRE, tPWpre, 0, NOTIFIER);
        endspecify
endmodule

module fdmf3b9(Q, D0, D1, S, CLK, PRE);
        output Q;
        input  D0, D1, S, CLK, PRE;
        supply0 CLEAR;
        reg NOTIFIER;
        mux g1(DATA, S, D1, D0);
        not g2(CLOCK, CLK);
        not g3(PRESET, PRE);
        buf g4(Q, QOUT);
        ff g5(QOUT, DATA, CLOCK, PRESET, CLEAR, NOTIFIER);
        // CONDITIONAL TIMING CHECK SIGNALS
        not g6(check1, PRESET);
        not g7(check2, DATA);
        // EXTERNAL TIMING CHECK SIGNALS
        xor     g8(sstz1, D0, D1);
        xtc_and g9(xcheck1, check1, sstz1);
        xtc_and g11(xcheck2, check1, S);
        not     g12(sstz3, S);
        xtc_and g13(xcheck3, check1, sstz3);
        // SPECIFY BLOCK
        specify
                specparam tSUd = 0 ;
                specparam tHDd = 0 ;
                specparam tRECpre = 0 ;
                specparam tPWclk = 0 ;
                specparam tHDpre = 0 ;
                specparam tPWpre = 0 ;
                specparam CLK_10_LH_Q = 0, CLK_10_HL_Q = 0 ;
                specparam PRE_10_LH_Q = 0, PRE_10_HL_Q = 0 ;
                (negedge CLK *> (Q : 1'b1)) = (CLK_10_LH_Q, CLK_10_HL_Q) ;
                (negedge PRE *> (Q : 1'b1)) = (PRE_10_LH_Q, PRE_10_HL_Q) ;
                $setup(posedge S &&& xcheck1, negedge CLK, tSUd, NOTIFIER);
                $setup(negedge S &&& xcheck1, negedge CLK, tSUd, NOTIFIER);
                $setup(posedge D1 &&& xcheck2, negedge CLK, tSUd, NOTIFIER);
                $setup(negedge D1 &&& xcheck2, negedge CLK, tSUd, NOTIFIER);
                $setup(posedge D0 &&& xcheck3, negedge CLK, tSUd, NOTIFIER);
                $setup(negedge D0 &&& xcheck3, negedge CLK, tSUd, NOTIFIER);
                $hold(negedge CLK, posedge S &&& xcheck1, tHDd, NOTIFIER);
                $hold(negedge CLK, negedge S &&& xcheck1, tHDd, NOTIFIER);
                $hold(negedge CLK, posedge D1 &&& xcheck2, tHDd, NOTIFIER);
                $hold(negedge CLK, negedge D1 &&& xcheck2, tHDd, NOTIFIER);
                $hold(negedge CLK, posedge D0 &&& xcheck3, tHDd, NOTIFIER);
                $hold(negedge CLK, negedge D0 &&& xcheck3, tHDd, NOTIFIER);
                $recovery(posedge PRE, negedge CLK &&& check2, tRECpre, NOTIFIER);
                $width(negedge CLK &&& check1, tPWclk, 0, NOTIFIER);
                $width(posedge CLK &&& check1, tPWclk, 0, NOTIFIER);
                $hold(negedge CLK, posedge PRE &&& check2, tHDpre, NOTIFIER);
                $hold(negedge CLK, negedge PRE &&& check2, tHDpre, NOTIFIER);
                $width(negedge PRE, tPWpre, 0, NOTIFIER);
        endspecify
endmodule

module ha1a1(S, CO, A, B);
        output S, CO;
        input  A, B;
        xor g1(S, A, B);
        and g2(CO, A, B);
        // SPECIFY BLOCK
        specify
                specparam A_01_LH_S = 0, A_01_HL_S = 0 ;
                specparam A_10_LH_S = 0, A_10_HL_S = 0 ;
                specparam B_01_LH_S = 0, B_01_HL_S = 0 ;
                specparam B_10_LH_S = 0, B_10_HL_S = 0 ;
                specparam A_LH_CO = 0, A_HL_CO = 0 ;
                specparam B_LH_CO = 0, B_HL_CO = 0 ;
                (posedge A *> (S : 1'b1)) = (A_01_LH_S, A_01_HL_S) ;
                (negedge A *> (S : 1'b1)) = (A_10_LH_S, A_10_HL_S) ;
                (posedge B *> (S : 1'b1)) = (B_01_LH_S, B_01_HL_S) ;
                (negedge B *> (S : 1'b1)) = (B_10_LH_S, B_10_HL_S) ;
                (A *> CO) = (A_LH_CO, A_HL_CO) ;
                (B *> CO) = (B_LH_CO, B_HL_CO) ;
        endspecify
endmodule

module ha1a2(S, CO, A, B);
        output S, CO;
        input  A, B;
        xor g1(S, A, B);
        and g2(CO, A, B);
        // SPECIFY BLOCK
        specify
                specparam A_01_LH_S = 0, A_01_HL_S = 0 ;
                specparam A_10_LH_S = 0, A_10_HL_S = 0 ;
                specparam B_01_LH_S = 0, B_01_HL_S = 0 ;
                specparam B_10_LH_S = 0, B_10_HL_S = 0 ;
                specparam A_LH_CO = 0, A_HL_CO = 0 ;
                specparam B_LH_CO = 0, B_HL_CO = 0 ;
                (posedge A *> (S : 1'b1)) = (A_01_LH_S, A_01_HL_S) ;
                (negedge A *> (S : 1'b1)) = (A_10_LH_S, A_10_HL_S) ;
                (posedge B *> (S : 1'b1)) = (B_01_LH_S, B_01_HL_S) ;
                (negedge B *> (S : 1'b1)) = (B_10_LH_S, B_10_HL_S) ;
                (A *> CO) = (A_LH_CO, A_HL_CO) ;
                (B *> CO) = (B_LH_CO, B_HL_CO) ;
        endspecify
endmodule

module ha1a3(S, CO, A, B);
        output S, CO;
        input  A, B;
        xor g1(S, A, B);
        and g2(CO, A, B);
        // SPECIFY BLOCK
        specify
                specparam A_01_LH_S = 0, A_01_HL_S = 0 ;
                specparam A_10_LH_S = 0, A_10_HL_S = 0 ;
                specparam B_01_LH_S = 0, B_01_HL_S = 0 ;
                specparam B_10_LH_S = 0, B_10_HL_S = 0 ;
                specparam A_LH_CO = 0, A_HL_CO = 0 ;
                specparam B_LH_CO = 0, B_HL_CO = 0 ;
                (posedge A *> (S : 1'b1)) = (A_01_LH_S, A_01_HL_S) ;
                (negedge A *> (S : 1'b1)) = (A_10_LH_S, A_10_HL_S) ;
                (posedge B *> (S : 1'b1)) = (B_01_LH_S, B_01_HL_S) ;
                (negedge B *> (S : 1'b1)) = (B_10_LH_S, B_10_HL_S) ;
                (A *> CO) = (A_LH_CO, A_HL_CO) ;
                (B *> CO) = (B_LH_CO, B_HL_CO) ;
        endspecify
endmodule

module ha1b1(S, CO, A, B);
        output S, CO;
        input  A, B;
        not g1(N1, B);
        xor g2(S, A, N1);
        not g3(N3, B);
        and g4(CO, A, N3);
        // SPECIFY BLOCK
        specify
                specparam A_01_LH_S = 0, A_01_HL_S = 0 ;
                specparam A_10_LH_S = 0, A_10_HL_S = 0 ;
                specparam B_01_LH_S = 0, B_01_HL_S = 0 ;
                specparam B_10_LH_S = 0, B_10_HL_S = 0 ;
                specparam A_LH_CO = 0, A_HL_CO = 0 ;
                specparam B_LH_CO = 0, B_HL_CO = 0 ;
                (posedge A *> (S : 1'b1)) = (A_01_LH_S, A_01_HL_S) ;
                (negedge A *> (S : 1'b1)) = (A_10_LH_S, A_10_HL_S) ;
                (posedge B *> (S : 1'b1)) = (B_01_LH_S, B_01_HL_S) ;
                (negedge B *> (S : 1'b1)) = (B_10_LH_S, B_10_HL_S) ;
                (A *> CO) = (A_LH_CO, A_HL_CO) ;
                (B *> CO) = (B_LH_CO, B_HL_CO) ;
        endspecify
endmodule

module ha1b2(S, CO, A, B);
        output S, CO;
        input  A, B;
        not g1(N1, B);
        xor g2(S, A, N1);
        not g3(N3, B);
        and g4(CO, A, N3);
        // SPECIFY BLOCK
        specify
                specparam A_01_LH_S = 0, A_01_HL_S = 0 ;
                specparam A_10_LH_S = 0, A_10_HL_S = 0 ;
                specparam B_01_LH_S = 0, B_01_HL_S = 0 ;
                specparam B_10_LH_S = 0, B_10_HL_S = 0 ;
                specparam A_LH_CO = 0, A_HL_CO = 0 ;
                specparam B_LH_CO = 0, B_HL_CO = 0 ;
                (posedge A *> (S : 1'b1)) = (A_01_LH_S, A_01_HL_S) ;
                (negedge A *> (S : 1'b1)) = (A_10_LH_S, A_10_HL_S) ;
                (posedge B *> (S : 1'b1)) = (B_01_LH_S, B_01_HL_S) ;
                (negedge B *> (S : 1'b1)) = (B_10_LH_S, B_10_HL_S) ;
                (A *> CO) = (A_LH_CO, A_HL_CO) ;
                (B *> CO) = (B_LH_CO, B_HL_CO) ;
        endspecify
endmodule

module ha1b3(S, CO, A, B);
        output S, CO;
        input  A, B;
        not g1(N1, B);
        xor g2(S, A, N1);
        not g3(N3, B);
        and g4(CO, A, N3);
        // SPECIFY BLOCK
        specify
                specparam A_01_LH_S = 0, A_01_HL_S = 0 ;
                specparam A_10_LH_S = 0, A_10_HL_S = 0 ;
                specparam B_01_LH_S = 0, B_01_HL_S = 0 ;
                specparam B_10_LH_S = 0, B_10_HL_S = 0 ;
                specparam A_LH_CO = 0, A_HL_CO = 0 ;
                specparam B_LH_CO = 0, B_HL_CO = 0 ;
                (posedge A *> (S : 1'b1)) = (A_01_LH_S, A_01_HL_S) ;
                (negedge A *> (S : 1'b1)) = (A_10_LH_S, A_10_HL_S) ;
                (posedge B *> (S : 1'b1)) = (B_01_LH_S, B_01_HL_S) ;
                (negedge B *> (S : 1'b1)) = (B_10_LH_S, B_10_HL_S) ;
                (A *> CO) = (A_LH_CO, A_HL_CO) ;
                (B *> CO) = (B_LH_CO, B_HL_CO) ;
        endspecify
endmodule

module ha2a1(S, CO, A, B);
        output S, CO;
        input  A, B;
        xor g1(S, A, B);
        nand g2(CO, A, B);
        // SPECIFY BLOCK
        specify
                specparam A_01_LH_S = 0, A_01_HL_S = 0 ;
                specparam A_10_LH_S = 0, A_10_HL_S = 0 ;
                specparam B_01_LH_S = 0, B_01_HL_S = 0 ;
                specparam B_10_LH_S = 0, B_10_HL_S = 0 ;
                specparam A_LH_CO = 0, A_HL_CO = 0 ;
                specparam B_LH_CO = 0, B_HL_CO = 0 ;
                (posedge A *> (S : 1'b1)) = (A_01_LH_S, A_01_HL_S) ;
                (negedge A *> (S : 1'b1)) = (A_10_LH_S, A_10_HL_S) ;
                (posedge B *> (S : 1'b1)) = (B_01_LH_S, B_01_HL_S) ;
                (negedge B *> (S : 1'b1)) = (B_10_LH_S, B_10_HL_S) ;
                (A *> CO) = (A_LH_CO, A_HL_CO) ;
                (B *> CO) = (B_LH_CO, B_HL_CO) ;
        endspecify
endmodule

module ha2a2(S, CO, A, B);
        output S, CO;
        input  A, B;
        xor g1(S, A, B);
        nand g2(CO, A, B);
        // SPECIFY BLOCK
        specify
                specparam A_01_LH_S = 0, A_01_HL_S = 0 ;
                specparam A_10_LH_S = 0, A_10_HL_S = 0 ;
                specparam B_01_LH_S = 0, B_01_HL_S = 0 ;
                specparam B_10_LH_S = 0, B_10_HL_S = 0 ;
                specparam A_LH_CO = 0, A_HL_CO = 0 ;
                specparam B_LH_CO = 0, B_HL_CO = 0 ;
                (posedge A *> (S : 1'b1)) = (A_01_LH_S, A_01_HL_S) ;
                (negedge A *> (S : 1'b1)) = (A_10_LH_S, A_10_HL_S) ;
                (posedge B *> (S : 1'b1)) = (B_01_LH_S, B_01_HL_S) ;
                (negedge B *> (S : 1'b1)) = (B_10_LH_S, B_10_HL_S) ;
                (A *> CO) = (A_LH_CO, A_HL_CO) ;
                (B *> CO) = (B_LH_CO, B_HL_CO) ;
        endspecify
endmodule

module ha2a3(S, CO, A, B);
        output S, CO;
        input  A, B;
        xor g1(S, A, B);
        nand g2(CO, A, B);
        // SPECIFY BLOCK
        specify
                specparam A_01_LH_S = 0, A_01_HL_S = 0 ;
                specparam A_10_LH_S = 0, A_10_HL_S = 0 ;
                specparam B_01_LH_S = 0, B_01_HL_S = 0 ;
                specparam B_10_LH_S = 0, B_10_HL_S = 0 ;
                specparam A_LH_CO = 0, A_HL_CO = 0 ;
                specparam B_LH_CO = 0, B_HL_CO = 0 ;
                (posedge A *> (S : 1'b1)) = (A_01_LH_S, A_01_HL_S) ;
                (negedge A *> (S : 1'b1)) = (A_10_LH_S, A_10_HL_S) ;
                (posedge B *> (S : 1'b1)) = (B_01_LH_S, B_01_HL_S) ;
                (negedge B *> (S : 1'b1)) = (B_10_LH_S, B_10_HL_S) ;
                (A *> CO) = (A_LH_CO, A_HL_CO) ;
                (B *> CO) = (B_LH_CO, B_HL_CO) ;
        endspecify
endmodule

module hld1a0(A);
  inout A;
  reg hold_value;
  supply0 sply0;
  supply1 sply1;
 
  buf (weak0,weak1) g1(A, hold_value);
  buf b1 (A_int, A);
 
  initial begin
    hold_value = 1'bz;
  end
 
  always @(A_int) begin
    case (A_int)
      1'b0    : hold_value = sply0;
      1'b1    : hold_value = sply1;
      1'bx    : hold_value = 1'bx;
      default : ;
    endcase
  end
endmodule

module inv1a1(Y, A);
        output Y;
        input  A;
        not g1(Y, A);
        // SPECIFY BLOCK
        specify
                specparam A_LH_Y = 0, A_HL_Y = 0 ;
                (A *> Y) = (A_LH_Y, A_HL_Y) ;
        endspecify
endmodule

module inv1a15(Y, A);
        output Y;
        input  A;
        not g1(Y, A);
        // SPECIFY BLOCK
        specify
                specparam A_LH_Y = 0, A_HL_Y = 0 ;
                (A *> Y) = (A_LH_Y, A_HL_Y) ;
        endspecify
endmodule

module inv1a2(Y, A);
        output Y;
        input  A;
        not g1(Y, A);
        // SPECIFY BLOCK
        specify
                specparam A_LH_Y = 0, A_HL_Y = 0 ;
                (A *> Y) = (A_LH_Y, A_HL_Y) ;
        endspecify
endmodule

module inv1a27(Y, A);
        output Y;
        input  A;
        not g1(Y, A);
        // SPECIFY BLOCK
        specify
                specparam A_LH_Y = 0, A_HL_Y = 0 ;
                (A *> Y) = (A_LH_Y, A_HL_Y) ;
        endspecify
endmodule

module inv1a3(Y, A);
        output Y;
        input  A;
        not g1(Y, A);
        // SPECIFY BLOCK
        specify
                specparam A_LH_Y = 0, A_HL_Y = 0 ;
                (A *> Y) = (A_LH_Y, A_HL_Y) ;
        endspecify
endmodule

module inv1a6(Y, A);
        output Y;
        input  A;
        not g1(Y, A);
        // SPECIFY BLOCK
        specify
                specparam A_LH_Y = 0, A_HL_Y = 0 ;
                (A *> Y) = (A_LH_Y, A_HL_Y) ;
        endspecify
endmodule

module inv1a9(Y, A);
        output Y;
        input  A;
        not g1(Y, A);
        // SPECIFY BLOCK
        specify
                specparam A_LH_Y = 0, A_HL_Y = 0 ;
                (A *> Y) = (A_LH_Y, A_HL_Y) ;
        endspecify
endmodule

module ldf1a1(Q, D, G);
        output Q;
        input  D, G;
        supply0 PRESET, CLEAR;
        reg NOTIFIER;
        buf g1(Q, QOUT);
        dl g2(QOUT, D, G, PRESET, CLEAR, NOTIFIER);
        // EXTERNAL TIMING CHECK SIGNALS
        // SPECIFY BLOCK
        specify
                specparam tSUd = 0 ;
                specparam tHDd = 0 ;
                specparam tPWclk = 0 ;
                specparam G_01_LH_Q = 0, G_01_HL_Q = 0 ;
                specparam D_LH_Q = 0, D_HL_Q = 0 ;
                (posedge G *> (Q : 1'b1)) = (G_01_LH_Q, G_01_HL_Q) ;
                (D *> Q) = (D_LH_Q, D_HL_Q) ;
                $setup(posedge D, negedge G, tSUd, NOTIFIER);
                $setup(negedge D, negedge G, tSUd, NOTIFIER);
                $hold(negedge G, posedge D, tHDd, NOTIFIER);
                $hold(negedge G, negedge D, tHDd, NOTIFIER);
                $width(posedge G, tPWclk, 0, NOTIFIER);
                $width(negedge G, tPWclk, 0, NOTIFIER);
        endspecify
endmodule

module ldf1a15(Q, D, G);
        output Q;
        input  D, G;
        supply0 PRESET, CLEAR;
        reg NOTIFIER;
        buf g1(Q, QOUT);
        dl g2(QOUT, D, G, PRESET, CLEAR, NOTIFIER);
        // EXTERNAL TIMING CHECK SIGNALS
        // SPECIFY BLOCK
        specify
                specparam tSUd = 0 ;
                specparam tHDd = 0 ;
                specparam tPWclk = 0 ;
                specparam G_01_LH_Q = 0, G_01_HL_Q = 0 ;
                specparam D_LH_Q = 0, D_HL_Q = 0 ;
                (posedge G *> (Q : 1'b1)) = (G_01_LH_Q, G_01_HL_Q) ;
                (D *> Q) = (D_LH_Q, D_HL_Q) ;
                $setup(posedge D, negedge G, tSUd, NOTIFIER);
                $setup(negedge D, negedge G, tSUd, NOTIFIER);
                $hold(negedge G, posedge D, tHDd, NOTIFIER);
                $hold(negedge G, negedge D, tHDd, NOTIFIER);
                $width(posedge G, tPWclk, 0, NOTIFIER);
                $width(negedge G, tPWclk, 0, NOTIFIER);
        endspecify
endmodule

module ldf1a2(Q, D, G);
        output Q;
        input  D, G;
        supply0 PRESET, CLEAR;
        reg NOTIFIER;
        buf g1(Q, QOUT);
        dl g2(QOUT, D, G, PRESET, CLEAR, NOTIFIER);
        // EXTERNAL TIMING CHECK SIGNALS
        // SPECIFY BLOCK
        specify
                specparam tSUd = 0 ;
                specparam tHDd = 0 ;
                specparam tPWclk = 0 ;
                specparam G_01_LH_Q = 0, G_01_HL_Q = 0 ;
                specparam D_LH_Q = 0, D_HL_Q = 0 ;
                (posedge G *> (Q : 1'b1)) = (G_01_LH_Q, G_01_HL_Q) ;
                (D *> Q) = (D_LH_Q, D_HL_Q) ;
                $setup(posedge D, negedge G, tSUd, NOTIFIER);
                $setup(negedge D, negedge G, tSUd, NOTIFIER);
                $hold(negedge G, posedge D, tHDd, NOTIFIER);
                $hold(negedge G, negedge D, tHDd, NOTIFIER);
                $width(posedge G, tPWclk, 0, NOTIFIER);
                $width(negedge G, tPWclk, 0, NOTIFIER);
        endspecify
endmodule

module ldf1a3(Q, D, G);
        output Q;
        input  D, G;
        supply0 PRESET, CLEAR;
        reg NOTIFIER;
        buf g1(Q, QOUT);
        dl g2(QOUT, D, G, PRESET, CLEAR, NOTIFIER);
        // EXTERNAL TIMING CHECK SIGNALS
        // SPECIFY BLOCK
        specify
                specparam tSUd = 0 ;
                specparam tHDd = 0 ;
                specparam tPWclk = 0 ;
                specparam G_01_LH_Q = 0, G_01_HL_Q = 0 ;
                specparam D_LH_Q = 0, D_HL_Q = 0 ;
                (posedge G *> (Q : 1'b1)) = (G_01_LH_Q, G_01_HL_Q) ;
                (D *> Q) = (D_LH_Q, D_HL_Q) ;
                $setup(posedge D, negedge G, tSUd, NOTIFIER);
                $setup(negedge D, negedge G, tSUd, NOTIFIER);
                $hold(negedge G, posedge D, tHDd, NOTIFIER);
                $hold(negedge G, negedge D, tHDd, NOTIFIER);
                $width(posedge G, tPWclk, 0, NOTIFIER);
                $width(negedge G, tPWclk, 0, NOTIFIER);
        endspecify
endmodule

module ldf1a6(Q, D, G);
        output Q;
        input  D, G;
        supply0 PRESET, CLEAR;
        reg NOTIFIER;
        buf g1(Q, QOUT);
        dl g2(QOUT, D, G, PRESET, CLEAR, NOTIFIER);
        // EXTERNAL TIMING CHECK SIGNALS
        // SPECIFY BLOCK
        specify
                specparam tSUd = 0 ;
                specparam tHDd = 0 ;
                specparam tPWclk = 0 ;
                specparam G_01_LH_Q = 0, G_01_HL_Q = 0 ;
                specparam D_LH_Q = 0, D_HL_Q = 0 ;
                (posedge G *> (Q : 1'b1)) = (G_01_LH_Q, G_01_HL_Q) ;
                (D *> Q) = (D_LH_Q, D_HL_Q) ;
                $setup(posedge D, negedge G, tSUd, NOTIFIER);
                $setup(negedge D, negedge G, tSUd, NOTIFIER);
                $hold(negedge G, posedge D, tHDd, NOTIFIER);
                $hold(negedge G, negedge D, tHDd, NOTIFIER);
                $width(posedge G, tPWclk, 0, NOTIFIER);
                $width(negedge G, tPWclk, 0, NOTIFIER);
        endspecify
endmodule

module ldf1a9(Q, D, G);
        output Q;
        input  D, G;
        supply0 PRESET, CLEAR;
        reg NOTIFIER;
        buf g1(Q, QOUT);
        dl g2(QOUT, D, G, PRESET, CLEAR, NOTIFIER);
        // EXTERNAL TIMING CHECK SIGNALS
        // SPECIFY BLOCK
        specify
                specparam tSUd = 0 ;
                specparam tHDd = 0 ;
                specparam tPWclk = 0 ;
                specparam G_01_LH_Q = 0, G_01_HL_Q = 0 ;
                specparam D_LH_Q = 0, D_HL_Q = 0 ;
                (posedge G *> (Q : 1'b1)) = (G_01_LH_Q, G_01_HL_Q) ;
                (D *> Q) = (D_LH_Q, D_HL_Q) ;
                $setup(posedge D, negedge G, tSUd, NOTIFIER);
                $setup(negedge D, negedge G, tSUd, NOTIFIER);
                $hold(negedge G, posedge D, tHDd, NOTIFIER);
                $hold(negedge G, negedge D, tHDd, NOTIFIER);
                $width(posedge G, tPWclk, 0, NOTIFIER);
                $width(negedge G, tPWclk, 0, NOTIFIER);
        endspecify
endmodule

module ldf1b1(Q, D, G);
        output Q;
        input  D, G;
        supply0 PRESET, CLEAR;
        reg NOTIFIER;
        not g1(GATE, G);
        buf g2(Q, QOUT);
        dl g3(QOUT, D, GATE, PRESET, CLEAR, NOTIFIER);
        // EXTERNAL TIMING CHECK SIGNALS
        // SPECIFY BLOCK
        specify
                specparam tSUd = 0 ;
                specparam tHDd = 0 ;
                specparam tPWclk = 0 ;
                specparam G_10_LH_Q = 0, G_10_HL_Q = 0 ;
                specparam D_LH_Q = 0, D_HL_Q = 0 ;
                (negedge G *> (Q : 1'b1)) = (G_10_LH_Q, G_10_HL_Q) ;
                (D *> Q) = (D_LH_Q, D_HL_Q) ;
                $setup(posedge D, posedge G, tSUd, NOTIFIER);
                $setup(negedge D, posedge G, tSUd, NOTIFIER);
                $hold(posedge G, posedge D, tHDd, NOTIFIER);
                $hold(posedge G, negedge D, tHDd, NOTIFIER);
                $width(negedge G, tPWclk, 0, NOTIFIER);
                $width(posedge G, tPWclk, 0, NOTIFIER);
        endspecify
endmodule

module ldf1b15(Q, D, G);
        output Q;
        input  D, G;
        supply0 PRESET, CLEAR;
        reg NOTIFIER;
        not g1(GATE, G);
        buf g2(Q, QOUT);
        dl g3(QOUT, D, GATE, PRESET, CLEAR, NOTIFIER);
        // EXTERNAL TIMING CHECK SIGNALS
        // SPECIFY BLOCK
        specify
                specparam tSUd = 0 ;
                specparam tHDd = 0 ;
                specparam tPWclk = 0 ;
                specparam G_10_LH_Q = 0, G_10_HL_Q = 0 ;
                specparam D_LH_Q = 0, D_HL_Q = 0 ;
                (negedge G *> (Q : 1'b1)) = (G_10_LH_Q, G_10_HL_Q) ;
                (D *> Q) = (D_LH_Q, D_HL_Q) ;
                $setup(posedge D, posedge G, tSUd, NOTIFIER);
                $setup(negedge D, posedge G, tSUd, NOTIFIER);
                $hold(posedge G, posedge D, tHDd, NOTIFIER);
                $hold(posedge G, negedge D, tHDd, NOTIFIER);
                $width(negedge G, tPWclk, 0, NOTIFIER);
                $width(posedge G, tPWclk, 0, NOTIFIER);
        endspecify
endmodule

module ldf1b2(Q, D, G);
        output Q;
        input  D, G;
        supply0 PRESET, CLEAR;
        reg NOTIFIER;
        not g1(GATE, G);
        buf g2(Q, QOUT);
        dl g3(QOUT, D, GATE, PRESET, CLEAR, NOTIFIER);
        // EXTERNAL TIMING CHECK SIGNALS
        // SPECIFY BLOCK
        specify
                specparam tSUd = 0 ;
                specparam tHDd = 0 ;
                specparam tPWclk = 0 ;
                specparam G_10_LH_Q = 0, G_10_HL_Q = 0 ;
                specparam D_LH_Q = 0, D_HL_Q = 0 ;
                (negedge G *> (Q : 1'b1)) = (G_10_LH_Q, G_10_HL_Q) ;
                (D *> Q) = (D_LH_Q, D_HL_Q) ;
                $setup(posedge D, posedge G, tSUd, NOTIFIER);
                $setup(negedge D, posedge G, tSUd, NOTIFIER);
                $hold(posedge G, posedge D, tHDd, NOTIFIER);
                $hold(posedge G, negedge D, tHDd, NOTIFIER);
                $width(negedge G, tPWclk, 0, NOTIFIER);
                $width(posedge G, tPWclk, 0, NOTIFIER);
        endspecify
endmodule

module ldf1b3(Q, D, G);
        output Q;
        input  D, G;
        supply0 PRESET, CLEAR;
        reg NOTIFIER;
        not g1(GATE, G);
        buf g2(Q, QOUT);
        dl g3(QOUT, D, GATE, PRESET, CLEAR, NOTIFIER);
        // EXTERNAL TIMING CHECK SIGNALS
        // SPECIFY BLOCK
        specify
                specparam tSUd = 0 ;
                specparam tHDd = 0 ;
                specparam tPWclk = 0 ;
                specparam G_10_LH_Q = 0, G_10_HL_Q = 0 ;
                specparam D_LH_Q = 0, D_HL_Q = 0 ;
                (negedge G *> (Q : 1'b1)) = (G_10_LH_Q, G_10_HL_Q) ;
                (D *> Q) = (D_LH_Q, D_HL_Q) ;
                $setup(posedge D, posedge G, tSUd, NOTIFIER);
                $setup(negedge D, posedge G, tSUd, NOTIFIER);
                $hold(posedge G, posedge D, tHDd, NOTIFIER);
                $hold(posedge G, negedge D, tHDd, NOTIFIER);
                $width(negedge G, tPWclk, 0, NOTIFIER);
                $width(posedge G, tPWclk, 0, NOTIFIER);
        endspecify
endmodule

module ldf1b6(Q, D, G);
        output Q;
        input  D, G;
        supply0 PRESET, CLEAR;
        reg NOTIFIER;
        not g1(GATE, G);
        buf g2(Q, QOUT);
        dl g3(QOUT, D, GATE, PRESET, CLEAR, NOTIFIER);
        // EXTERNAL TIMING CHECK SIGNALS
        // SPECIFY BLOCK
        specify
                specparam tSUd = 0 ;
                specparam tHDd = 0 ;
                specparam tPWclk = 0 ;
                specparam G_10_LH_Q = 0, G_10_HL_Q = 0 ;
                specparam D_LH_Q = 0, D_HL_Q = 0 ;
                (negedge G *> (Q : 1'b1)) = (G_10_LH_Q, G_10_HL_Q) ;
                (D *> Q) = (D_LH_Q, D_HL_Q) ;
                $setup(posedge D, posedge G, tSUd, NOTIFIER);
                $setup(negedge D, posedge G, tSUd, NOTIFIER);
                $hold(posedge G, posedge D, tHDd, NOTIFIER);
                $hold(posedge G, negedge D, tHDd, NOTIFIER);
                $width(negedge G, tPWclk, 0, NOTIFIER);
                $width(posedge G, tPWclk, 0, NOTIFIER);
        endspecify
endmodule

module ldf1b9(Q, D, G);
        output Q;
        input  D, G;
        supply0 PRESET, CLEAR;
        reg NOTIFIER;
        not g1(GATE, G);
        buf g2(Q, QOUT);
        dl g3(QOUT, D, GATE, PRESET, CLEAR, NOTIFIER);
        // EXTERNAL TIMING CHECK SIGNALS
        // SPECIFY BLOCK
        specify
                specparam tSUd = 0 ;
                specparam tHDd = 0 ;
                specparam tPWclk = 0 ;
                specparam G_10_LH_Q = 0, G_10_HL_Q = 0 ;
                specparam D_LH_Q = 0, D_HL_Q = 0 ;
                (negedge G *> (Q : 1'b1)) = (G_10_LH_Q, G_10_HL_Q) ;
                (D *> Q) = (D_LH_Q, D_HL_Q) ;
                $setup(posedge D, posedge G, tSUd, NOTIFIER);
                $setup(negedge D, posedge G, tSUd, NOTIFIER);
                $hold(posedge G, posedge D, tHDd, NOTIFIER);
                $hold(posedge G, negedge D, tHDd, NOTIFIER);
                $width(negedge G, tPWclk, 0, NOTIFIER);
                $width(posedge G, tPWclk, 0, NOTIFIER);
        endspecify
endmodule

module ldf2a1(Q, D, G, CLR);
        output Q;
        input  D, G, CLR;
        supply0 PRESET;
        reg NOTIFIER;
        not g1(CLEAR, CLR);
        buf g2(Q, QOUT);
        dl g3(QOUT, D, G, PRESET, CLEAR, NOTIFIER);
        // CONDITIONAL TIMING CHECK SIGNALS
        not g4(check1, CLEAR);
        buf g5(check2, D);
        // EXTERNAL TIMING CHECK SIGNALS
        // SPECIFY BLOCK
        specify
                specparam tSUd = 0 ;
                specparam tHDd = 0 ;
                specparam tRECclr = 0 ;
                specparam tPWclk = 0 ;
                specparam tHDclr = 0 ;
                specparam tPWclr = 0 ;
                specparam G_01_LH_Q = 0, G_01_HL_Q = 0 ;
                specparam D_LH_Q = 0, D_HL_Q = 0 ;
                specparam CLR_10_LH_Q = 0, CLR_10_HL_Q = 0 ;
                (posedge G *> (Q : 1'b1)) = (G_01_LH_Q, G_01_HL_Q) ;
                (D *> Q) = (D_LH_Q, D_HL_Q) ;
                (negedge CLR *> (Q : 1'b1)) = (CLR_10_LH_Q, CLR_10_HL_Q) ;
                $setup(posedge D &&& check1, negedge G, tSUd, NOTIFIER);
                $setup(negedge D &&& check1, negedge G, tSUd, NOTIFIER);
                $hold(negedge G, posedge D &&& check1, tHDd, NOTIFIER);
                $hold(negedge G, negedge D &&& check1, tHDd, NOTIFIER);
                $recovery(posedge CLR, negedge G &&& check2, tRECclr, NOTIFIER);
                $width(posedge G &&& check1, tPWclk, 0, NOTIFIER);
                $width(negedge G &&& check1, tPWclk, 0, NOTIFIER);
                $hold(negedge G, posedge CLR &&& check2, tHDclr, NOTIFIER);
                $hold(negedge G, negedge CLR &&& check2, tHDclr, NOTIFIER);
                $width(negedge CLR, tPWclr, 0, NOTIFIER);
        endspecify
endmodule

module ldf2a15(Q, D, G, CLR);
        output Q;
        input  D, G, CLR;
        supply0 PRESET;
        reg NOTIFIER;
        not g1(CLEAR, CLR);
        buf g2(Q, QOUT);
        dl g3(QOUT, D, G, PRESET, CLEAR, NOTIFIER);
        // CONDITIONAL TIMING CHECK SIGNALS
        not g4(check1, CLEAR);
        buf g5(check2, D);
        // EXTERNAL TIMING CHECK SIGNALS
        // SPECIFY BLOCK
        specify
                specparam tSUd = 0 ;
                specparam tHDd = 0 ;
                specparam tRECclr = 0 ;
                specparam tPWclk = 0 ;
                specparam tHDclr = 0 ;
                specparam tPWclr = 0 ;
                specparam G_01_LH_Q = 0, G_01_HL_Q = 0 ;
                specparam D_LH_Q = 0, D_HL_Q = 0 ;
                specparam CLR_10_LH_Q = 0, CLR_10_HL_Q = 0 ;
                (posedge G *> (Q : 1'b1)) = (G_01_LH_Q, G_01_HL_Q) ;
                (D *> Q) = (D_LH_Q, D_HL_Q) ;
                (negedge CLR *> (Q : 1'b1)) = (CLR_10_LH_Q, CLR_10_HL_Q) ;
                $setup(posedge D &&& check1, negedge G, tSUd, NOTIFIER);
                $setup(negedge D &&& check1, negedge G, tSUd, NOTIFIER);
                $hold(negedge G, posedge D &&& check1, tHDd, NOTIFIER);
                $hold(negedge G, negedge D &&& check1, tHDd, NOTIFIER);
                $recovery(posedge CLR, negedge G &&& check2, tRECclr, NOTIFIER);
                $width(posedge G &&& check1, tPWclk, 0, NOTIFIER);
                $width(negedge G &&& check1, tPWclk, 0, NOTIFIER);
                $hold(negedge G, posedge CLR &&& check2, tHDclr, NOTIFIER);
                $hold(negedge G, negedge CLR &&& check2, tHDclr, NOTIFIER);
                $width(negedge CLR, tPWclr, 0, NOTIFIER);
        endspecify
endmodule

module ldf2a2(Q, D, G, CLR);
        output Q;
        input  D, G, CLR;
        supply0 PRESET;
        reg NOTIFIER;
        not g1(CLEAR, CLR);
        buf g2(Q, QOUT);
        dl g3(QOUT, D, G, PRESET, CLEAR, NOTIFIER);
        // CONDITIONAL TIMING CHECK SIGNALS
        not g4(check1, CLEAR);
        buf g5(check2, D);
        // EXTERNAL TIMING CHECK SIGNALS
        // SPECIFY BLOCK
        specify
                specparam tSUd = 0 ;
                specparam tHDd = 0 ;
                specparam tRECclr = 0 ;
                specparam tPWclk = 0 ;
                specparam tHDclr = 0 ;
                specparam tPWclr = 0 ;
                specparam G_01_LH_Q = 0, G_01_HL_Q = 0 ;
                specparam D_LH_Q = 0, D_HL_Q = 0 ;
                specparam CLR_10_LH_Q = 0, CLR_10_HL_Q = 0 ;
                (posedge G *> (Q : 1'b1)) = (G_01_LH_Q, G_01_HL_Q) ;
                (D *> Q) = (D_LH_Q, D_HL_Q) ;
                (negedge CLR *> (Q : 1'b1)) = (CLR_10_LH_Q, CLR_10_HL_Q) ;
                $setup(posedge D &&& check1, negedge G, tSUd, NOTIFIER);
                $setup(negedge D &&& check1, negedge G, tSUd, NOTIFIER);
                $hold(negedge G, posedge D &&& check1, tHDd, NOTIFIER);
                $hold(negedge G, negedge D &&& check1, tHDd, NOTIFIER);
                $recovery(posedge CLR, negedge G &&& check2, tRECclr, NOTIFIER);
                $width(posedge G &&& check1, tPWclk, 0, NOTIFIER);
                $width(negedge G &&& check1, tPWclk, 0, NOTIFIER);
                $hold(negedge G, posedge CLR &&& check2, tHDclr, NOTIFIER);
                $hold(negedge G, negedge CLR &&& check2, tHDclr, NOTIFIER);
                $width(negedge CLR, tPWclr, 0, NOTIFIER);
        endspecify
endmodule

module ldf2a3(Q, D, G, CLR);
        output Q;
        input  D, G, CLR;
        supply0 PRESET;
        reg NOTIFIER;
        not g1(CLEAR, CLR);
        buf g2(Q, QOUT);
        dl g3(QOUT, D, G, PRESET, CLEAR, NOTIFIER);
        // CONDITIONAL TIMING CHECK SIGNALS
        not g4(check1, CLEAR);
        buf g5(check2, D);
        // EXTERNAL TIMING CHECK SIGNALS
        // SPECIFY BLOCK
        specify
                specparam tSUd = 0 ;
                specparam tHDd = 0 ;
                specparam tRECclr = 0 ;
                specparam tPWclk = 0 ;
                specparam tHDclr = 0 ;
                specparam tPWclr = 0 ;
                specparam G_01_LH_Q = 0, G_01_HL_Q = 0 ;
                specparam D_LH_Q = 0, D_HL_Q = 0 ;
                specparam CLR_10_LH_Q = 0, CLR_10_HL_Q = 0 ;
                (posedge G *> (Q : 1'b1)) = (G_01_LH_Q, G_01_HL_Q) ;
                (D *> Q) = (D_LH_Q, D_HL_Q) ;
                (negedge CLR *> (Q : 1'b1)) = (CLR_10_LH_Q, CLR_10_HL_Q) ;
                $setup(posedge D &&& check1, negedge G, tSUd, NOTIFIER);
                $setup(negedge D &&& check1, negedge G, tSUd, NOTIFIER);
                $hold(negedge G, posedge D &&& check1, tHDd, NOTIFIER);
                $hold(negedge G, negedge D &&& check1, tHDd, NOTIFIER);
                $recovery(posedge CLR, negedge G &&& check2, tRECclr, NOTIFIER);
                $width(posedge G &&& check1, tPWclk, 0, NOTIFIER);
                $width(negedge G &&& check1, tPWclk, 0, NOTIFIER);
                $hold(negedge G, posedge CLR &&& check2, tHDclr, NOTIFIER);
                $hold(negedge G, negedge CLR &&& check2, tHDclr, NOTIFIER);
                $width(negedge CLR, tPWclr, 0, NOTIFIER);
        endspecify
endmodule

module ldf2a6(Q, D, G, CLR);
        output Q;
        input  D, G, CLR;
        supply0 PRESET;
        reg NOTIFIER;
        not g1(CLEAR, CLR);
        buf g2(Q, QOUT);
        dl g3(QOUT, D, G, PRESET, CLEAR, NOTIFIER);
        // CONDITIONAL TIMING CHECK SIGNALS
        not g4(check1, CLEAR);
        buf g5(check2, D);
        // EXTERNAL TIMING CHECK SIGNALS
        // SPECIFY BLOCK
        specify
                specparam tSUd = 0 ;
                specparam tHDd = 0 ;
                specparam tRECclr = 0 ;
                specparam tPWclk = 0 ;
                specparam tHDclr = 0 ;
                specparam tPWclr = 0 ;
                specparam G_01_LH_Q = 0, G_01_HL_Q = 0 ;
                specparam D_LH_Q = 0, D_HL_Q = 0 ;
                specparam CLR_10_LH_Q = 0, CLR_10_HL_Q = 0 ;
                (posedge G *> (Q : 1'b1)) = (G_01_LH_Q, G_01_HL_Q) ;
                (D *> Q) = (D_LH_Q, D_HL_Q) ;
                (negedge CLR *> (Q : 1'b1)) = (CLR_10_LH_Q, CLR_10_HL_Q) ;
                $setup(posedge D &&& check1, negedge G, tSUd, NOTIFIER);
                $setup(negedge D &&& check1, negedge G, tSUd, NOTIFIER);
                $hold(negedge G, posedge D &&& check1, tHDd, NOTIFIER);
                $hold(negedge G, negedge D &&& check1, tHDd, NOTIFIER);
                $recovery(posedge CLR, negedge G &&& check2, tRECclr, NOTIFIER);
                $width(posedge G &&& check1, tPWclk, 0, NOTIFIER);
                $width(negedge G &&& check1, tPWclk, 0, NOTIFIER);
                $hold(negedge G, posedge CLR &&& check2, tHDclr, NOTIFIER);
                $hold(negedge G, negedge CLR &&& check2, tHDclr, NOTIFIER);
                $width(negedge CLR, tPWclr, 0, NOTIFIER);
        endspecify
endmodule

module ldf2a9(Q, D, G, CLR);
        output Q;
        input  D, G, CLR;
        supply0 PRESET;
        reg NOTIFIER;
        not g1(CLEAR, CLR);
        buf g2(Q, QOUT);
        dl g3(QOUT, D, G, PRESET, CLEAR, NOTIFIER);
        // CONDITIONAL TIMING CHECK SIGNALS
        not g4(check1, CLEAR);
        buf g5(check2, D);
        // EXTERNAL TIMING CHECK SIGNALS
        // SPECIFY BLOCK
        specify
                specparam tSUd = 0 ;
                specparam tHDd = 0 ;
                specparam tRECclr = 0 ;
                specparam tPWclk = 0 ;
                specparam tHDclr = 0 ;
                specparam tPWclr = 0 ;
                specparam G_01_LH_Q = 0, G_01_HL_Q = 0 ;
                specparam D_LH_Q = 0, D_HL_Q = 0 ;
                specparam CLR_10_LH_Q = 0, CLR_10_HL_Q = 0 ;
                (posedge G *> (Q : 1'b1)) = (G_01_LH_Q, G_01_HL_Q) ;
                (D *> Q) = (D_LH_Q, D_HL_Q) ;
                (negedge CLR *> (Q : 1'b1)) = (CLR_10_LH_Q, CLR_10_HL_Q) ;
                $setup(posedge D &&& check1, negedge G, tSUd, NOTIFIER);
                $setup(negedge D &&& check1, negedge G, tSUd, NOTIFIER);
                $hold(negedge G, posedge D &&& check1, tHDd, NOTIFIER);
                $hold(negedge G, negedge D &&& check1, tHDd, NOTIFIER);
                $recovery(posedge CLR, negedge G &&& check2, tRECclr, NOTIFIER);
                $width(posedge G &&& check1, tPWclk, 0, NOTIFIER);
                $width(negedge G &&& check1, tPWclk, 0, NOTIFIER);
                $hold(negedge G, posedge CLR &&& check2, tHDclr, NOTIFIER);
                $hold(negedge G, negedge CLR &&& check2, tHDclr, NOTIFIER);
                $width(negedge CLR, tPWclr, 0, NOTIFIER);
        endspecify
endmodule

module ldmf1a1(Q, D0, D1, S, G);
        output Q;
        input  D0, D1, S, G;
        supply0 PRESET, CLEAR;
        reg NOTIFIER;
        mux g1(DATA, S, D1, D0);
        buf g2(Q, QOUT);
        dl g3(QOUT, DATA, G, PRESET, CLEAR, NOTIFIER);
        // EXTERNAL TIMING CHECK SIGNALS
        xtc_xor g4(xcheck1, D0, D1);
        xtc_buf g6(xcheck2, S);
        xtc_not g8(xcheck3, S);
        // SPECIFY BLOCK
        specify
                specparam tSUd = 0 ;
                specparam tHDd = 0 ;
                specparam tPWclk = 0 ;
                specparam G_01_LH_Q = 0, G_01_HL_Q = 0 ;
                specparam D0_LH_Q = 0, D0_HL_Q = 0 ;
                specparam D1_LH_Q = 0, D1_HL_Q = 0 ;
                specparam S_01_LH_Q = 0, S_01_HL_Q = 0 ;
                specparam S_10_LH_Q = 0, S_10_HL_Q = 0 ;
                (posedge G *> (Q : 1'b1)) = (G_01_LH_Q, G_01_HL_Q) ;
                (D0 *> Q) = (D0_LH_Q, D0_HL_Q) ;
                (D1 *> Q) = (D1_LH_Q, D1_HL_Q) ;
                (posedge S *> (Q : 1'b1)) = (S_01_LH_Q, S_01_HL_Q) ;
                (negedge S *> (Q : 1'b1)) = (S_10_LH_Q, S_10_HL_Q) ;
                $setup(posedge S &&& xcheck1, negedge G, tSUd, NOTIFIER);
                $setup(negedge S &&& xcheck1, negedge G, tSUd, NOTIFIER);
                $setup(posedge D1 &&& xcheck2, negedge G, tSUd, NOTIFIER);
                $setup(negedge D1 &&& xcheck2, negedge G, tSUd, NOTIFIER);
                $setup(posedge D0 &&& xcheck3, negedge G, tSUd, NOTIFIER);
                $setup(negedge D0 &&& xcheck3, negedge G, tSUd, NOTIFIER);
                $hold(negedge G, posedge S &&& xcheck1, tHDd, NOTIFIER);
                $hold(negedge G, negedge S &&& xcheck1, tHDd, NOTIFIER);
                $hold(negedge G, posedge D1 &&& xcheck2, tHDd, NOTIFIER);
                $hold(negedge G, negedge D1 &&& xcheck2, tHDd, NOTIFIER);
                $hold(negedge G, posedge D0 &&& xcheck3, tHDd, NOTIFIER);
                $hold(negedge G, negedge D0 &&& xcheck3, tHDd, NOTIFIER);
                $width(posedge G, tPWclk, 0, NOTIFIER);
                $width(negedge G, tPWclk, 0, NOTIFIER);
        endspecify
endmodule

module ldmf1a15(Q, D0, D1, S, G);
        output Q;
        input  D0, D1, S, G;
        supply0 PRESET, CLEAR;
        reg NOTIFIER;
        mux g1(DATA, S, D1, D0);
        buf g2(Q, QOUT);
        dl g3(QOUT, DATA, G, PRESET, CLEAR, NOTIFIER);
        // EXTERNAL TIMING CHECK SIGNALS
        xtc_xor g4(xcheck1, D0, D1);
        xtc_buf g6(xcheck2, S);
        xtc_not g8(xcheck3, S);
        // SPECIFY BLOCK
        specify
                specparam tSUd = 0 ;
                specparam tHDd = 0 ;
                specparam tPWclk = 0 ;
                specparam G_01_LH_Q = 0, G_01_HL_Q = 0 ;
                specparam D0_LH_Q = 0, D0_HL_Q = 0 ;
                specparam D1_LH_Q = 0, D1_HL_Q = 0 ;
                specparam S_01_LH_Q = 0, S_01_HL_Q = 0 ;
                specparam S_10_LH_Q = 0, S_10_HL_Q = 0 ;
                (posedge G *> (Q : 1'b1)) = (G_01_LH_Q, G_01_HL_Q) ;
                (D0 *> Q) = (D0_LH_Q, D0_HL_Q) ;
                (D1 *> Q) = (D1_LH_Q, D1_HL_Q) ;
                (posedge S *> (Q : 1'b1)) = (S_01_LH_Q, S_01_HL_Q) ;
                (negedge S *> (Q : 1'b1)) = (S_10_LH_Q, S_10_HL_Q) ;
                $setup(posedge S &&& xcheck1, negedge G, tSUd, NOTIFIER);
                $setup(negedge S &&& xcheck1, negedge G, tSUd, NOTIFIER);
                $setup(posedge D1 &&& xcheck2, negedge G, tSUd, NOTIFIER);
                $setup(negedge D1 &&& xcheck2, negedge G, tSUd, NOTIFIER);
                $setup(posedge D0 &&& xcheck3, negedge G, tSUd, NOTIFIER);
                $setup(negedge D0 &&& xcheck3, negedge G, tSUd, NOTIFIER);
                $hold(negedge G, posedge S &&& xcheck1, tHDd, NOTIFIER);
                $hold(negedge G, negedge S &&& xcheck1, tHDd, NOTIFIER);
                $hold(negedge G, posedge D1 &&& xcheck2, tHDd, NOTIFIER);
                $hold(negedge G, negedge D1 &&& xcheck2, tHDd, NOTIFIER);
                $hold(negedge G, posedge D0 &&& xcheck3, tHDd, NOTIFIER);
                $hold(negedge G, negedge D0 &&& xcheck3, tHDd, NOTIFIER);
                $width(posedge G, tPWclk, 0, NOTIFIER);
                $width(negedge G, tPWclk, 0, NOTIFIER);
        endspecify
endmodule

module ldmf1a2(Q, D0, D1, S, G);
        output Q;
        input  D0, D1, S, G;
        supply0 PRESET, CLEAR;
        reg NOTIFIER;
        mux g1(DATA, S, D1, D0);
        buf g2(Q, QOUT);
        dl g3(QOUT, DATA, G, PRESET, CLEAR, NOTIFIER);
        // EXTERNAL TIMING CHECK SIGNALS
        xtc_xor g4(xcheck1, D0, D1);
        xtc_buf g6(xcheck2, S);
        xtc_not g8(xcheck3, S);
        // SPECIFY BLOCK
        specify
                specparam tSUd = 0 ;
                specparam tHDd = 0 ;
                specparam tPWclk = 0 ;
                specparam G_01_LH_Q = 0, G_01_HL_Q = 0 ;
                specparam D0_LH_Q = 0, D0_HL_Q = 0 ;
                specparam D1_LH_Q = 0, D1_HL_Q = 0 ;
                specparam S_01_LH_Q = 0, S_01_HL_Q = 0 ;
                specparam S_10_LH_Q = 0, S_10_HL_Q = 0 ;
                (posedge G *> (Q : 1'b1)) = (G_01_LH_Q, G_01_HL_Q) ;
                (D0 *> Q) = (D0_LH_Q, D0_HL_Q) ;
                (D1 *> Q) = (D1_LH_Q, D1_HL_Q) ;
                (posedge S *> (Q : 1'b1)) = (S_01_LH_Q, S_01_HL_Q) ;
                (negedge S *> (Q : 1'b1)) = (S_10_LH_Q, S_10_HL_Q) ;
                $setup(posedge S &&& xcheck1, negedge G, tSUd, NOTIFIER);
                $setup(negedge S &&& xcheck1, negedge G, tSUd, NOTIFIER);
                $setup(posedge D1 &&& xcheck2, negedge G, tSUd, NOTIFIER);
                $setup(negedge D1 &&& xcheck2, negedge G, tSUd, NOTIFIER);
                $setup(posedge D0 &&& xcheck3, negedge G, tSUd, NOTIFIER);
                $setup(negedge D0 &&& xcheck3, negedge G, tSUd, NOTIFIER);
                $hold(negedge G, posedge S &&& xcheck1, tHDd, NOTIFIER);
                $hold(negedge G, negedge S &&& xcheck1, tHDd, NOTIFIER);
                $hold(negedge G, posedge D1 &&& xcheck2, tHDd, NOTIFIER);
                $hold(negedge G, negedge D1 &&& xcheck2, tHDd, NOTIFIER);
                $hold(negedge G, posedge D0 &&& xcheck3, tHDd, NOTIFIER);
                $hold(negedge G, negedge D0 &&& xcheck3, tHDd, NOTIFIER);
                $width(posedge G, tPWclk, 0, NOTIFIER);
                $width(negedge G, tPWclk, 0, NOTIFIER);
        endspecify
endmodule

module ldmf1a3(Q, D0, D1, S, G);
        output Q;
        input  D0, D1, S, G;
        supply0 PRESET, CLEAR;
        reg NOTIFIER;
        mux g1(DATA, S, D1, D0);
        buf g2(Q, QOUT);
        dl g3(QOUT, DATA, G, PRESET, CLEAR, NOTIFIER);
        // EXTERNAL TIMING CHECK SIGNALS
        xtc_xor g4(xcheck1, D0, D1);
        xtc_buf g6(xcheck2, S);
        xtc_not g8(xcheck3, S);
        // SPECIFY BLOCK
        specify
                specparam tSUd = 0 ;
                specparam tHDd = 0 ;
                specparam tPWclk = 0 ;
                specparam G_01_LH_Q = 0, G_01_HL_Q = 0 ;
                specparam D0_LH_Q = 0, D0_HL_Q = 0 ;
                specparam D1_LH_Q = 0, D1_HL_Q = 0 ;
                specparam S_01_LH_Q = 0, S_01_HL_Q = 0 ;
                specparam S_10_LH_Q = 0, S_10_HL_Q = 0 ;
                (posedge G *> (Q : 1'b1)) = (G_01_LH_Q, G_01_HL_Q) ;
                (D0 *> Q) = (D0_LH_Q, D0_HL_Q) ;
                (D1 *> Q) = (D1_LH_Q, D1_HL_Q) ;
                (posedge S *> (Q : 1'b1)) = (S_01_LH_Q, S_01_HL_Q) ;
                (negedge S *> (Q : 1'b1)) = (S_10_LH_Q, S_10_HL_Q) ;
                $setup(posedge S &&& xcheck1, negedge G, tSUd, NOTIFIER);
                $setup(negedge S &&& xcheck1, negedge G, tSUd, NOTIFIER);
                $setup(posedge D1 &&& xcheck2, negedge G, tSUd, NOTIFIER);
                $setup(negedge D1 &&& xcheck2, negedge G, tSUd, NOTIFIER);
                $setup(posedge D0 &&& xcheck3, negedge G, tSUd, NOTIFIER);
                $setup(negedge D0 &&& xcheck3, negedge G, tSUd, NOTIFIER);
                $hold(negedge G, posedge S &&& xcheck1, tHDd, NOTIFIER);
                $hold(negedge G, negedge S &&& xcheck1, tHDd, NOTIFIER);
                $hold(negedge G, posedge D1 &&& xcheck2, tHDd, NOTIFIER);
                $hold(negedge G, negedge D1 &&& xcheck2, tHDd, NOTIFIER);
                $hold(negedge G, posedge D0 &&& xcheck3, tHDd, NOTIFIER);
                $hold(negedge G, negedge D0 &&& xcheck3, tHDd, NOTIFIER);
                $width(posedge G, tPWclk, 0, NOTIFIER);
                $width(negedge G, tPWclk, 0, NOTIFIER);
        endspecify
endmodule

module ldmf1a6(Q, D0, D1, S, G);
        output Q;
        input  D0, D1, S, G;
        supply0 PRESET, CLEAR;
        reg NOTIFIER;
        mux g1(DATA, S, D1, D0);
        buf g2(Q, QOUT);
        dl g3(QOUT, DATA, G, PRESET, CLEAR, NOTIFIER);
        // EXTERNAL TIMING CHECK SIGNALS
        xtc_xor g4(xcheck1, D0, D1);
        xtc_buf g6(xcheck2, S);
        xtc_not g8(xcheck3, S);
        // SPECIFY BLOCK
        specify
                specparam tSUd = 0 ;
                specparam tHDd = 0 ;
                specparam tPWclk = 0 ;
                specparam G_01_LH_Q = 0, G_01_HL_Q = 0 ;
                specparam D0_LH_Q = 0, D0_HL_Q = 0 ;
                specparam D1_LH_Q = 0, D1_HL_Q = 0 ;
                specparam S_01_LH_Q = 0, S_01_HL_Q = 0 ;
                specparam S_10_LH_Q = 0, S_10_HL_Q = 0 ;
                (posedge G *> (Q : 1'b1)) = (G_01_LH_Q, G_01_HL_Q) ;
                (D0 *> Q) = (D0_LH_Q, D0_HL_Q) ;
                (D1 *> Q) = (D1_LH_Q, D1_HL_Q) ;
                (posedge S *> (Q : 1'b1)) = (S_01_LH_Q, S_01_HL_Q) ;
                (negedge S *> (Q : 1'b1)) = (S_10_LH_Q, S_10_HL_Q) ;
                $setup(posedge S &&& xcheck1, negedge G, tSUd, NOTIFIER);
                $setup(negedge S &&& xcheck1, negedge G, tSUd, NOTIFIER);
                $setup(posedge D1 &&& xcheck2, negedge G, tSUd, NOTIFIER);
                $setup(negedge D1 &&& xcheck2, negedge G, tSUd, NOTIFIER);
                $setup(posedge D0 &&& xcheck3, negedge G, tSUd, NOTIFIER);
                $setup(negedge D0 &&& xcheck3, negedge G, tSUd, NOTIFIER);
                $hold(negedge G, posedge S &&& xcheck1, tHDd, NOTIFIER);
                $hold(negedge G, negedge S &&& xcheck1, tHDd, NOTIFIER);
                $hold(negedge G, posedge D1 &&& xcheck2, tHDd, NOTIFIER);
                $hold(negedge G, negedge D1 &&& xcheck2, tHDd, NOTIFIER);
                $hold(negedge G, posedge D0 &&& xcheck3, tHDd, NOTIFIER);
                $hold(negedge G, negedge D0 &&& xcheck3, tHDd, NOTIFIER);
                $width(posedge G, tPWclk, 0, NOTIFIER);
                $width(negedge G, tPWclk, 0, NOTIFIER);
        endspecify
endmodule

module ldmf1a9(Q, D0, D1, S, G);
        output Q;
        input  D0, D1, S, G;
        supply0 PRESET, CLEAR;
        reg NOTIFIER;
        mux g1(DATA, S, D1, D0);
        buf g2(Q, QOUT);
        dl g3(QOUT, DATA, G, PRESET, CLEAR, NOTIFIER);
        // EXTERNAL TIMING CHECK SIGNALS
        xtc_xor g4(xcheck1, D0, D1);
        xtc_buf g6(xcheck2, S);
        xtc_not g8(xcheck3, S);
        // SPECIFY BLOCK
        specify
                specparam tSUd = 0 ;
                specparam tHDd = 0 ;
                specparam tPWclk = 0 ;
                specparam G_01_LH_Q = 0, G_01_HL_Q = 0 ;
                specparam D0_LH_Q = 0, D0_HL_Q = 0 ;
                specparam D1_LH_Q = 0, D1_HL_Q = 0 ;
                specparam S_01_LH_Q = 0, S_01_HL_Q = 0 ;
                specparam S_10_LH_Q = 0, S_10_HL_Q = 0 ;
                (posedge G *> (Q : 1'b1)) = (G_01_LH_Q, G_01_HL_Q) ;
                (D0 *> Q) = (D0_LH_Q, D0_HL_Q) ;
                (D1 *> Q) = (D1_LH_Q, D1_HL_Q) ;
                (posedge S *> (Q : 1'b1)) = (S_01_LH_Q, S_01_HL_Q) ;
                (negedge S *> (Q : 1'b1)) = (S_10_LH_Q, S_10_HL_Q) ;
                $setup(posedge S &&& xcheck1, negedge G, tSUd, NOTIFIER);
                $setup(negedge S &&& xcheck1, negedge G, tSUd, NOTIFIER);
                $setup(posedge D1 &&& xcheck2, negedge G, tSUd, NOTIFIER);
                $setup(negedge D1 &&& xcheck2, negedge G, tSUd, NOTIFIER);
                $setup(posedge D0 &&& xcheck3, negedge G, tSUd, NOTIFIER);
                $setup(negedge D0 &&& xcheck3, negedge G, tSUd, NOTIFIER);
                $hold(negedge G, posedge S &&& xcheck1, tHDd, NOTIFIER);
                $hold(negedge G, negedge S &&& xcheck1, tHDd, NOTIFIER);
                $hold(negedge G, posedge D1 &&& xcheck2, tHDd, NOTIFIER);
                $hold(negedge G, negedge D1 &&& xcheck2, tHDd, NOTIFIER);
                $hold(negedge G, posedge D0 &&& xcheck3, tHDd, NOTIFIER);
                $hold(negedge G, negedge D0 &&& xcheck3, tHDd, NOTIFIER);
                $width(posedge G, tPWclk, 0, NOTIFIER);
                $width(negedge G, tPWclk, 0, NOTIFIER);
        endspecify
endmodule

module ldmf1b1(Q, D0, D1, S, G);
        output Q;
        input  D0, D1, S, G;
        supply0 PRESET, CLEAR;
        reg NOTIFIER;
        mux g1(DATA, S, D1, D0);
        not g2(GATE, G);
        buf g3(Q, QOUT);
        dl g4(QOUT, DATA, GATE, PRESET, CLEAR, NOTIFIER);
        // EXTERNAL TIMING CHECK SIGNALS
        xtc_xor g5(xcheck1, D0, D1);
        xtc_buf g7(xcheck2, S);
        xtc_not g9(xcheck3, S);
        // SPECIFY BLOCK
        specify
                specparam tSUd = 0 ;
                specparam tHDd = 0 ;
                specparam tPWclk = 0 ;
                specparam G_10_LH_Q = 0, G_10_HL_Q = 0 ;
                specparam D0_LH_Q = 0, D0_HL_Q = 0 ;
                specparam D1_LH_Q = 0, D1_HL_Q = 0 ;
                specparam S_01_LH_Q = 0, S_01_HL_Q = 0 ;
                specparam S_10_LH_Q = 0, S_10_HL_Q = 0 ;
                (negedge G *> (Q : 1'b1)) = (G_10_LH_Q, G_10_HL_Q) ;
                (D0 *> Q) = (D0_LH_Q, D0_HL_Q) ;
                (D1 *> Q) = (D1_LH_Q, D1_HL_Q) ;
                (posedge S *> (Q : 1'b1)) = (S_01_LH_Q, S_01_HL_Q) ;
                (negedge S *> (Q : 1'b1)) = (S_10_LH_Q, S_10_HL_Q) ;
                $setup(posedge S &&& xcheck1, posedge G, tSUd, NOTIFIER);
                $setup(negedge S &&& xcheck1, posedge G, tSUd, NOTIFIER);
                $setup(posedge D1 &&& xcheck2, posedge G, tSUd, NOTIFIER);
                $setup(negedge D1 &&& xcheck2, posedge G, tSUd, NOTIFIER);
                $setup(posedge D0 &&& xcheck3, posedge G, tSUd, NOTIFIER);
                $setup(negedge D0 &&& xcheck3, posedge G, tSUd, NOTIFIER);
                $hold(posedge G, posedge S &&& xcheck1, tHDd, NOTIFIER);
                $hold(posedge G, negedge S &&& xcheck1, tHDd, NOTIFIER);
                $hold(posedge G, posedge D1 &&& xcheck2, tHDd, NOTIFIER);
                $hold(posedge G, negedge D1 &&& xcheck2, tHDd, NOTIFIER);
                $hold(posedge G, posedge D0 &&& xcheck3, tHDd, NOTIFIER);
                $hold(posedge G, negedge D0 &&& xcheck3, tHDd, NOTIFIER);
                $width(negedge G, tPWclk, 0, NOTIFIER);
                $width(posedge G, tPWclk, 0, NOTIFIER);
        endspecify
endmodule

module ldmf1b15(Q, D0, D1, S, G);
        output Q;
        input  D0, D1, S, G;
        supply0 PRESET, CLEAR;
        reg NOTIFIER;
        mux g1(DATA, S, D1, D0);
        not g2(GATE, G);
        buf g3(Q, QOUT);
        dl g4(QOUT, DATA, GATE, PRESET, CLEAR, NOTIFIER);
        // EXTERNAL TIMING CHECK SIGNALS
        xtc_xor g5(xcheck1, D0, D1);
        xtc_buf g7(xcheck2, S);
        xtc_not g9(xcheck3, S);
        // SPECIFY BLOCK
        specify
                specparam tSUd = 0 ;
                specparam tHDd = 0 ;
                specparam tPWclk = 0 ;
                specparam G_10_LH_Q = 0, G_10_HL_Q = 0 ;
                specparam D0_LH_Q = 0, D0_HL_Q = 0 ;
                specparam D1_LH_Q = 0, D1_HL_Q = 0 ;
                specparam S_01_LH_Q = 0, S_01_HL_Q = 0 ;
                specparam S_10_LH_Q = 0, S_10_HL_Q = 0 ;
                (negedge G *> (Q : 1'b1)) = (G_10_LH_Q, G_10_HL_Q) ;
                (D0 *> Q) = (D0_LH_Q, D0_HL_Q) ;
                (D1 *> Q) = (D1_LH_Q, D1_HL_Q) ;
                (posedge S *> (Q : 1'b1)) = (S_01_LH_Q, S_01_HL_Q) ;
                (negedge S *> (Q : 1'b1)) = (S_10_LH_Q, S_10_HL_Q) ;
                $setup(posedge S &&& xcheck1, posedge G, tSUd, NOTIFIER);
                $setup(negedge S &&& xcheck1, posedge G, tSUd, NOTIFIER);
                $setup(posedge D1 &&& xcheck2, posedge G, tSUd, NOTIFIER);
                $setup(negedge D1 &&& xcheck2, posedge G, tSUd, NOTIFIER);
                $setup(posedge D0 &&& xcheck3, posedge G, tSUd, NOTIFIER);
                $setup(negedge D0 &&& xcheck3, posedge G, tSUd, NOTIFIER);
                $hold(posedge G, posedge S &&& xcheck1, tHDd, NOTIFIER);
                $hold(posedge G, negedge S &&& xcheck1, tHDd, NOTIFIER);
                $hold(posedge G, posedge D1 &&& xcheck2, tHDd, NOTIFIER);
                $hold(posedge G, negedge D1 &&& xcheck2, tHDd, NOTIFIER);
                $hold(posedge G, posedge D0 &&& xcheck3, tHDd, NOTIFIER);
                $hold(posedge G, negedge D0 &&& xcheck3, tHDd, NOTIFIER);
                $width(negedge G, tPWclk, 0, NOTIFIER);
                $width(posedge G, tPWclk, 0, NOTIFIER);
        endspecify
endmodule

module ldmf1b2(Q, D0, D1, S, G);
        output Q;
        input  D0, D1, S, G;
        supply0 PRESET, CLEAR;
        reg NOTIFIER;
        mux g1(DATA, S, D1, D0);
        not g2(GATE, G);
        buf g3(Q, QOUT);
        dl g4(QOUT, DATA, GATE, PRESET, CLEAR, NOTIFIER);
        // EXTERNAL TIMING CHECK SIGNALS
        xtc_xor g5(xcheck1, D0, D1);
        xtc_buf g7(xcheck2, S);
        xtc_not g9(xcheck3, S);
        // SPECIFY BLOCK
        specify
                specparam tSUd = 0 ;
                specparam tHDd = 0 ;
                specparam tPWclk = 0 ;
                specparam G_10_LH_Q = 0, G_10_HL_Q = 0 ;
                specparam D0_LH_Q = 0, D0_HL_Q = 0 ;
                specparam D1_LH_Q = 0, D1_HL_Q = 0 ;
                specparam S_01_LH_Q = 0, S_01_HL_Q = 0 ;
                specparam S_10_LH_Q = 0, S_10_HL_Q = 0 ;
                (negedge G *> (Q : 1'b1)) = (G_10_LH_Q, G_10_HL_Q) ;
                (D0 *> Q) = (D0_LH_Q, D0_HL_Q) ;
                (D1 *> Q) = (D1_LH_Q, D1_HL_Q) ;
                (posedge S *> (Q : 1'b1)) = (S_01_LH_Q, S_01_HL_Q) ;
                (negedge S *> (Q : 1'b1)) = (S_10_LH_Q, S_10_HL_Q) ;
                $setup(posedge S &&& xcheck1, posedge G, tSUd, NOTIFIER);
                $setup(negedge S &&& xcheck1, posedge G, tSUd, NOTIFIER);
                $setup(posedge D1 &&& xcheck2, posedge G, tSUd, NOTIFIER);
                $setup(negedge D1 &&& xcheck2, posedge G, tSUd, NOTIFIER);
                $setup(posedge D0 &&& xcheck3, posedge G, tSUd, NOTIFIER);
                $setup(negedge D0 &&& xcheck3, posedge G, tSUd, NOTIFIER);
                $hold(posedge G, posedge S &&& xcheck1, tHDd, NOTIFIER);
                $hold(posedge G, negedge S &&& xcheck1, tHDd, NOTIFIER);
                $hold(posedge G, posedge D1 &&& xcheck2, tHDd, NOTIFIER);
                $hold(posedge G, negedge D1 &&& xcheck2, tHDd, NOTIFIER);
                $hold(posedge G, posedge D0 &&& xcheck3, tHDd, NOTIFIER);
                $hold(posedge G, negedge D0 &&& xcheck3, tHDd, NOTIFIER);
                $width(negedge G, tPWclk, 0, NOTIFIER);
                $width(posedge G, tPWclk, 0, NOTIFIER);
        endspecify
endmodule

module ldmf1b3(Q, D0, D1, S, G);
        output Q;
        input  D0, D1, S, G;
        supply0 PRESET, CLEAR;
        reg NOTIFIER;
        mux g1(DATA, S, D1, D0);
        not g2(GATE, G);
        buf g3(Q, QOUT);
        dl g4(QOUT, DATA, GATE, PRESET, CLEAR, NOTIFIER);
        // EXTERNAL TIMING CHECK SIGNALS
        xtc_xor g5(xcheck1, D0, D1);
        xtc_buf g7(xcheck2, S);
        xtc_not g9(xcheck3, S);
        // SPECIFY BLOCK
        specify
                specparam tSUd = 0 ;
                specparam tHDd = 0 ;
                specparam tPWclk = 0 ;
                specparam G_10_LH_Q = 0, G_10_HL_Q = 0 ;
                specparam D0_LH_Q = 0, D0_HL_Q = 0 ;
                specparam D1_LH_Q = 0, D1_HL_Q = 0 ;
                specparam S_01_LH_Q = 0, S_01_HL_Q = 0 ;
                specparam S_10_LH_Q = 0, S_10_HL_Q = 0 ;
                (negedge G *> (Q : 1'b1)) = (G_10_LH_Q, G_10_HL_Q) ;
                (D0 *> Q) = (D0_LH_Q, D0_HL_Q) ;
                (D1 *> Q) = (D1_LH_Q, D1_HL_Q) ;
                (posedge S *> (Q : 1'b1)) = (S_01_LH_Q, S_01_HL_Q) ;
                (negedge S *> (Q : 1'b1)) = (S_10_LH_Q, S_10_HL_Q) ;
                $setup(posedge S &&& xcheck1, posedge G, tSUd, NOTIFIER);
                $setup(negedge S &&& xcheck1, posedge G, tSUd, NOTIFIER);
                $setup(posedge D1 &&& xcheck2, posedge G, tSUd, NOTIFIER);
                $setup(negedge D1 &&& xcheck2, posedge G, tSUd, NOTIFIER);
                $setup(posedge D0 &&& xcheck3, posedge G, tSUd, NOTIFIER);
                $setup(negedge D0 &&& xcheck3, posedge G, tSUd, NOTIFIER);
                $hold(posedge G, posedge S &&& xcheck1, tHDd, NOTIFIER);
                $hold(posedge G, negedge S &&& xcheck1, tHDd, NOTIFIER);
                $hold(posedge G, posedge D1 &&& xcheck2, tHDd, NOTIFIER);
                $hold(posedge G, negedge D1 &&& xcheck2, tHDd, NOTIFIER);
                $hold(posedge G, posedge D0 &&& xcheck3, tHDd, NOTIFIER);
                $hold(posedge G, negedge D0 &&& xcheck3, tHDd, NOTIFIER);
                $width(negedge G, tPWclk, 0, NOTIFIER);
                $width(posedge G, tPWclk, 0, NOTIFIER);
        endspecify
endmodule

module ldmf1b6(Q, D0, D1, S, G);
        output Q;
        input  D0, D1, S, G;
        supply0 PRESET, CLEAR;
        reg NOTIFIER;
        mux g1(DATA, S, D1, D0);
        not g2(GATE, G);
        buf g3(Q, QOUT);
        dl g4(QOUT, DATA, GATE, PRESET, CLEAR, NOTIFIER);
        // EXTERNAL TIMING CHECK SIGNALS
        xtc_xor g5(xcheck1, D0, D1);
        xtc_buf g7(xcheck2, S);
        xtc_not g9(xcheck3, S);
        // SPECIFY BLOCK
        specify
                specparam tSUd = 0 ;
                specparam tHDd = 0 ;
                specparam tPWclk = 0 ;
                specparam G_10_LH_Q = 0, G_10_HL_Q = 0 ;
                specparam D0_LH_Q = 0, D0_HL_Q = 0 ;
                specparam D1_LH_Q = 0, D1_HL_Q = 0 ;
                specparam S_01_LH_Q = 0, S_01_HL_Q = 0 ;
                specparam S_10_LH_Q = 0, S_10_HL_Q = 0 ;
                (negedge G *> (Q : 1'b1)) = (G_10_LH_Q, G_10_HL_Q) ;
                (D0 *> Q) = (D0_LH_Q, D0_HL_Q) ;
                (D1 *> Q) = (D1_LH_Q, D1_HL_Q) ;
                (posedge S *> (Q : 1'b1)) = (S_01_LH_Q, S_01_HL_Q) ;
                (negedge S *> (Q : 1'b1)) = (S_10_LH_Q, S_10_HL_Q) ;
                $setup(posedge S &&& xcheck1, posedge G, tSUd, NOTIFIER);
                $setup(negedge S &&& xcheck1, posedge G, tSUd, NOTIFIER);
                $setup(posedge D1 &&& xcheck2, posedge G, tSUd, NOTIFIER);
                $setup(negedge D1 &&& xcheck2, posedge G, tSUd, NOTIFIER);
                $setup(posedge D0 &&& xcheck3, posedge G, tSUd, NOTIFIER);
                $setup(negedge D0 &&& xcheck3, posedge G, tSUd, NOTIFIER);
                $hold(posedge G, posedge S &&& xcheck1, tHDd, NOTIFIER);
                $hold(posedge G, negedge S &&& xcheck1, tHDd, NOTIFIER);
                $hold(posedge G, posedge D1 &&& xcheck2, tHDd, NOTIFIER);
                $hold(posedge G, negedge D1 &&& xcheck2, tHDd, NOTIFIER);
                $hold(posedge G, posedge D0 &&& xcheck3, tHDd, NOTIFIER);
                $hold(posedge G, negedge D0 &&& xcheck3, tHDd, NOTIFIER);
                $width(negedge G, tPWclk, 0, NOTIFIER);
                $width(posedge G, tPWclk, 0, NOTIFIER);
        endspecify
endmodule

module ldmf1b9(Q, D0, D1, S, G);
        output Q;
        input  D0, D1, S, G;
        supply0 PRESET, CLEAR;
        reg NOTIFIER;
        mux g1(DATA, S, D1, D0);
        not g2(GATE, G);
        buf g3(Q, QOUT);
        dl g4(QOUT, DATA, GATE, PRESET, CLEAR, NOTIFIER);
        // EXTERNAL TIMING CHECK SIGNALS
        xtc_xor g5(xcheck1, D0, D1);
        xtc_buf g7(xcheck2, S);
        xtc_not g9(xcheck3, S);
        // SPECIFY BLOCK
        specify
                specparam tSUd = 0 ;
                specparam tHDd = 0 ;
                specparam tPWclk = 0 ;
                specparam G_10_LH_Q = 0, G_10_HL_Q = 0 ;
                specparam D0_LH_Q = 0, D0_HL_Q = 0 ;
                specparam D1_LH_Q = 0, D1_HL_Q = 0 ;
                specparam S_01_LH_Q = 0, S_01_HL_Q = 0 ;
                specparam S_10_LH_Q = 0, S_10_HL_Q = 0 ;
                (negedge G *> (Q : 1'b1)) = (G_10_LH_Q, G_10_HL_Q) ;
                (D0 *> Q) = (D0_LH_Q, D0_HL_Q) ;
                (D1 *> Q) = (D1_LH_Q, D1_HL_Q) ;
                (posedge S *> (Q : 1'b1)) = (S_01_LH_Q, S_01_HL_Q) ;
                (negedge S *> (Q : 1'b1)) = (S_10_LH_Q, S_10_HL_Q) ;
                $setup(posedge S &&& xcheck1, posedge G, tSUd, NOTIFIER);
                $setup(negedge S &&& xcheck1, posedge G, tSUd, NOTIFIER);
                $setup(posedge D1 &&& xcheck2, posedge G, tSUd, NOTIFIER);
                $setup(negedge D1 &&& xcheck2, posedge G, tSUd, NOTIFIER);
                $setup(posedge D0 &&& xcheck3, posedge G, tSUd, NOTIFIER);
                $setup(negedge D0 &&& xcheck3, posedge G, tSUd, NOTIFIER);
                $hold(posedge G, posedge S &&& xcheck1, tHDd, NOTIFIER);
                $hold(posedge G, negedge S &&& xcheck1, tHDd, NOTIFIER);
                $hold(posedge G, posedge D1 &&& xcheck2, tHDd, NOTIFIER);
                $hold(posedge G, negedge D1 &&& xcheck2, tHDd, NOTIFIER);
                $hold(posedge G, posedge D0 &&& xcheck3, tHDd, NOTIFIER);
                $hold(posedge G, negedge D0 &&& xcheck3, tHDd, NOTIFIER);
                $width(negedge G, tPWclk, 0, NOTIFIER);
                $width(posedge G, tPWclk, 0, NOTIFIER);
        endspecify
endmodule

module ldmf2a1(Q, D0, D1, S, G, CLR);
        output Q;
        input  D0, D1, S, G, CLR;
        supply0 PRESET;
        reg NOTIFIER;
        not g1(CLEAR, CLR);
        mux g2(DATA, S, D1, D0);
        buf g3(Q, QOUT);
        dl g4(QOUT, DATA, G, PRESET, CLEAR, NOTIFIER);
        // CONDITIONAL TIMING CHECK SIGNALS
        not g5(check1, CLEAR);
        buf g6(check2, DATA);
        // EXTERNAL TIMING CHECK SIGNALS
        xor     g7(sstz1, D0, D1);
        xtc_and g8(xcheck1, check1, sstz1);
        xtc_and g10(xcheck2, check1, S);
        not     g11(sstz3, S);
        xtc_and g12(xcheck3, check1, sstz3);
        // SPECIFY BLOCK
        specify
                specparam tSUd = 0 ;
                specparam tHDd = 0 ;
                specparam tRECclr = 0 ;
                specparam tPWclk = 0 ;
                specparam tHDclr = 0 ;
                specparam tPWclr = 0 ;
                specparam G_01_LH_Q = 0, G_01_HL_Q = 0 ;
                specparam D0_LH_Q = 0, D0_HL_Q = 0 ;
                specparam D1_LH_Q = 0, D1_HL_Q = 0 ;
                specparam S_01_LH_Q = 0, S_01_HL_Q = 0 ;
                specparam S_10_LH_Q = 0, S_10_HL_Q = 0 ;
                specparam CLR_10_LH_Q = 0, CLR_10_HL_Q = 0 ;
                (posedge G *> (Q : 1'b1)) = (G_01_LH_Q, G_01_HL_Q) ;
                (D0 *> Q) = (D0_LH_Q, D0_HL_Q) ;
                (D1 *> Q) = (D1_LH_Q, D1_HL_Q) ;
                (posedge S *> (Q : 1'b1)) = (S_01_LH_Q, S_01_HL_Q) ;
                (negedge S *> (Q : 1'b1)) = (S_10_LH_Q, S_10_HL_Q) ;
                (negedge CLR *> (Q : 1'b1)) = (CLR_10_LH_Q, CLR_10_HL_Q) ;
                $setup(posedge S &&& xcheck1, negedge G, tSUd, NOTIFIER);
                $setup(negedge S &&& xcheck1, negedge G, tSUd, NOTIFIER);
                $setup(posedge D1 &&& xcheck2, negedge G, tSUd, NOTIFIER);
                $setup(negedge D1 &&& xcheck2, negedge G, tSUd, NOTIFIER);
                $setup(posedge D0 &&& xcheck3, negedge G, tSUd, NOTIFIER);
                $setup(negedge D0 &&& xcheck3, negedge G, tSUd, NOTIFIER);
                $hold(negedge G, posedge S &&& xcheck1, tHDd, NOTIFIER);
                $hold(negedge G, negedge S &&& xcheck1, tHDd, NOTIFIER);
                $hold(negedge G, posedge D1 &&& xcheck2, tHDd, NOTIFIER);
                $hold(negedge G, negedge D1 &&& xcheck2, tHDd, NOTIFIER);
                $hold(negedge G, posedge D0 &&& xcheck3, tHDd, NOTIFIER);
                $hold(negedge G, negedge D0 &&& xcheck3, tHDd, NOTIFIER);
                $recovery(posedge CLR, negedge G &&& check2, tRECclr, NOTIFIER);
                $width(posedge G &&& check1, tPWclk, 0, NOTIFIER);
                $width(negedge G &&& check1, tPWclk, 0, NOTIFIER);
                $hold(negedge G, posedge CLR &&& check2, tHDclr, NOTIFIER);
                $hold(negedge G, negedge CLR &&& check2, tHDclr, NOTIFIER);
                $width(negedge CLR, tPWclr, 0, NOTIFIER);
        endspecify
endmodule

module ldmf2a15(Q, D0, D1, S, G, CLR);
        output Q;
        input  D0, D1, S, G, CLR;
        supply0 PRESET;
        reg NOTIFIER;
        not g1(CLEAR, CLR);
        mux g2(DATA, S, D1, D0);
        buf g3(Q, QOUT);
        dl g4(QOUT, DATA, G, PRESET, CLEAR, NOTIFIER);
        // CONDITIONAL TIMING CHECK SIGNALS
        not g5(check1, CLEAR);
        buf g6(check2, DATA);
        // EXTERNAL TIMING CHECK SIGNALS
        xor     g7(sstz1, D0, D1);
        xtc_and g8(xcheck1, check1, sstz1);
        xtc_and g10(xcheck2, check1, S);
        not     g11(sstz3, S);
        xtc_and g12(xcheck3, check1, sstz3);
        // SPECIFY BLOCK
        specify
                specparam tSUd = 0 ;
                specparam tHDd = 0 ;
                specparam tRECclr = 0 ;
                specparam tPWclk = 0 ;
                specparam tHDclr = 0 ;
                specparam tPWclr = 0 ;
                specparam G_01_LH_Q = 0, G_01_HL_Q = 0 ;
                specparam D0_LH_Q = 0, D0_HL_Q = 0 ;
                specparam D1_LH_Q = 0, D1_HL_Q = 0 ;
                specparam S_01_LH_Q = 0, S_01_HL_Q = 0 ;
                specparam S_10_LH_Q = 0, S_10_HL_Q = 0 ;
                specparam CLR_10_LH_Q = 0, CLR_10_HL_Q = 0 ;
                (posedge G *> (Q : 1'b1)) = (G_01_LH_Q, G_01_HL_Q) ;
                (D0 *> Q) = (D0_LH_Q, D0_HL_Q) ;
                (D1 *> Q) = (D1_LH_Q, D1_HL_Q) ;
                (posedge S *> (Q : 1'b1)) = (S_01_LH_Q, S_01_HL_Q) ;
                (negedge S *> (Q : 1'b1)) = (S_10_LH_Q, S_10_HL_Q) ;
                (negedge CLR *> (Q : 1'b1)) = (CLR_10_LH_Q, CLR_10_HL_Q) ;
                $setup(posedge S &&& xcheck1, negedge G, tSUd, NOTIFIER);
                $setup(negedge S &&& xcheck1, negedge G, tSUd, NOTIFIER);
                $setup(posedge D1 &&& xcheck2, negedge G, tSUd, NOTIFIER);
                $setup(negedge D1 &&& xcheck2, negedge G, tSUd, NOTIFIER);
                $setup(posedge D0 &&& xcheck3, negedge G, tSUd, NOTIFIER);
                $setup(negedge D0 &&& xcheck3, negedge G, tSUd, NOTIFIER);
                $hold(negedge G, posedge S &&& xcheck1, tHDd, NOTIFIER);
                $hold(negedge G, negedge S &&& xcheck1, tHDd, NOTIFIER);
                $hold(negedge G, posedge D1 &&& xcheck2, tHDd, NOTIFIER);
                $hold(negedge G, negedge D1 &&& xcheck2, tHDd, NOTIFIER);
                $hold(negedge G, posedge D0 &&& xcheck3, tHDd, NOTIFIER);
                $hold(negedge G, negedge D0 &&& xcheck3, tHDd, NOTIFIER);
                $recovery(posedge CLR, negedge G &&& check2, tRECclr, NOTIFIER);
                $width(posedge G &&& check1, tPWclk, 0, NOTIFIER);
                $width(negedge G &&& check1, tPWclk, 0, NOTIFIER);
                $hold(negedge G, posedge CLR &&& check2, tHDclr, NOTIFIER);
                $hold(negedge G, negedge CLR &&& check2, tHDclr, NOTIFIER);
                $width(negedge CLR, tPWclr, 0, NOTIFIER);
        endspecify
endmodule

module ldmf2a2(Q, D0, D1, S, G, CLR);
        output Q;
        input  D0, D1, S, G, CLR;
        supply0 PRESET;
        reg NOTIFIER;
        not g1(CLEAR, CLR);
        mux g2(DATA, S, D1, D0);
        buf g3(Q, QOUT);
        dl g4(QOUT, DATA, G, PRESET, CLEAR, NOTIFIER);
        // CONDITIONAL TIMING CHECK SIGNALS
        not g5(check1, CLEAR);
        buf g6(check2, DATA);
        // EXTERNAL TIMING CHECK SIGNALS
        xor     g7(sstz1, D0, D1);
        xtc_and g8(xcheck1, check1, sstz1);
        xtc_and g10(xcheck2, check1, S);
        not     g11(sstz3, S);
        xtc_and g12(xcheck3, check1, sstz3);
        // SPECIFY BLOCK
        specify
                specparam tSUd = 0 ;
                specparam tHDd = 0 ;
                specparam tRECclr = 0 ;
                specparam tPWclk = 0 ;
                specparam tHDclr = 0 ;
                specparam tPWclr = 0 ;
                specparam G_01_LH_Q = 0, G_01_HL_Q = 0 ;
                specparam D0_LH_Q = 0, D0_HL_Q = 0 ;
                specparam D1_LH_Q = 0, D1_HL_Q = 0 ;
                specparam S_01_LH_Q = 0, S_01_HL_Q = 0 ;
                specparam S_10_LH_Q = 0, S_10_HL_Q = 0 ;
                specparam CLR_10_LH_Q = 0, CLR_10_HL_Q = 0 ;
                (posedge G *> (Q : 1'b1)) = (G_01_LH_Q, G_01_HL_Q) ;
                (D0 *> Q) = (D0_LH_Q, D0_HL_Q) ;
                (D1 *> Q) = (D1_LH_Q, D1_HL_Q) ;
                (posedge S *> (Q : 1'b1)) = (S_01_LH_Q, S_01_HL_Q) ;
                (negedge S *> (Q : 1'b1)) = (S_10_LH_Q, S_10_HL_Q) ;
                (negedge CLR *> (Q : 1'b1)) = (CLR_10_LH_Q, CLR_10_HL_Q) ;
                $setup(posedge S &&& xcheck1, negedge G, tSUd, NOTIFIER);
                $setup(negedge S &&& xcheck1, negedge G, tSUd, NOTIFIER);
                $setup(posedge D1 &&& xcheck2, negedge G, tSUd, NOTIFIER);
                $setup(negedge D1 &&& xcheck2, negedge G, tSUd, NOTIFIER);
                $setup(posedge D0 &&& xcheck3, negedge G, tSUd, NOTIFIER);
                $setup(negedge D0 &&& xcheck3, negedge G, tSUd, NOTIFIER);
                $hold(negedge G, posedge S &&& xcheck1, tHDd, NOTIFIER);
                $hold(negedge G, negedge S &&& xcheck1, tHDd, NOTIFIER);
                $hold(negedge G, posedge D1 &&& xcheck2, tHDd, NOTIFIER);
                $hold(negedge G, negedge D1 &&& xcheck2, tHDd, NOTIFIER);
                $hold(negedge G, posedge D0 &&& xcheck3, tHDd, NOTIFIER);
                $hold(negedge G, negedge D0 &&& xcheck3, tHDd, NOTIFIER);
                $recovery(posedge CLR, negedge G &&& check2, tRECclr, NOTIFIER);
                $width(posedge G &&& check1, tPWclk, 0, NOTIFIER);
                $width(negedge G &&& check1, tPWclk, 0, NOTIFIER);
                $hold(negedge G, posedge CLR &&& check2, tHDclr, NOTIFIER);
                $hold(negedge G, negedge CLR &&& check2, tHDclr, NOTIFIER);
                $width(negedge CLR, tPWclr, 0, NOTIFIER);
        endspecify
endmodule

module ldmf2a3(Q, D0, D1, S, G, CLR);
        output Q;
        input  D0, D1, S, G, CLR;
        supply0 PRESET;
        reg NOTIFIER;
        not g1(CLEAR, CLR);
        mux g2(DATA, S, D1, D0);
        buf g3(Q, QOUT);
        dl g4(QOUT, DATA, G, PRESET, CLEAR, NOTIFIER);
        // CONDITIONAL TIMING CHECK SIGNALS
        not g5(check1, CLEAR);
        buf g6(check2, DATA);
        // EXTERNAL TIMING CHECK SIGNALS
        xor     g7(sstz1, D0, D1);
        xtc_and g8(xcheck1, check1, sstz1);
        xtc_and g10(xcheck2, check1, S);
        not     g11(sstz3, S);
        xtc_and g12(xcheck3, check1, sstz3);
        // SPECIFY BLOCK
        specify
                specparam tSUd = 0 ;
                specparam tHDd = 0 ;
                specparam tRECclr = 0 ;
                specparam tPWclk = 0 ;
                specparam tHDclr = 0 ;
                specparam tPWclr = 0 ;
                specparam G_01_LH_Q = 0, G_01_HL_Q = 0 ;
                specparam D0_LH_Q = 0, D0_HL_Q = 0 ;
                specparam D1_LH_Q = 0, D1_HL_Q = 0 ;
                specparam S_01_LH_Q = 0, S_01_HL_Q = 0 ;
                specparam S_10_LH_Q = 0, S_10_HL_Q = 0 ;
                specparam CLR_10_LH_Q = 0, CLR_10_HL_Q = 0 ;
                (posedge G *> (Q : 1'b1)) = (G_01_LH_Q, G_01_HL_Q) ;
                (D0 *> Q) = (D0_LH_Q, D0_HL_Q) ;
                (D1 *> Q) = (D1_LH_Q, D1_HL_Q) ;
                (posedge S *> (Q : 1'b1)) = (S_01_LH_Q, S_01_HL_Q) ;
                (negedge S *> (Q : 1'b1)) = (S_10_LH_Q, S_10_HL_Q) ;
                (negedge CLR *> (Q : 1'b1)) = (CLR_10_LH_Q, CLR_10_HL_Q) ;
                $setup(posedge S &&& xcheck1, negedge G, tSUd, NOTIFIER);
                $setup(negedge S &&& xcheck1, negedge G, tSUd, NOTIFIER);
                $setup(posedge D1 &&& xcheck2, negedge G, tSUd, NOTIFIER);
                $setup(negedge D1 &&& xcheck2, negedge G, tSUd, NOTIFIER);
                $setup(posedge D0 &&& xcheck3, negedge G, tSUd, NOTIFIER);
                $setup(negedge D0 &&& xcheck3, negedge G, tSUd, NOTIFIER);
                $hold(negedge G, posedge S &&& xcheck1, tHDd, NOTIFIER);
                $hold(negedge G, negedge S &&& xcheck1, tHDd, NOTIFIER);
                $hold(negedge G, posedge D1 &&& xcheck2, tHDd, NOTIFIER);
                $hold(negedge G, negedge D1 &&& xcheck2, tHDd, NOTIFIER);
                $hold(negedge G, posedge D0 &&& xcheck3, tHDd, NOTIFIER);
                $hold(negedge G, negedge D0 &&& xcheck3, tHDd, NOTIFIER);
                $recovery(posedge CLR, negedge G &&& check2, tRECclr, NOTIFIER);
                $width(posedge G &&& check1, tPWclk, 0, NOTIFIER);
                $width(negedge G &&& check1, tPWclk, 0, NOTIFIER);
                $hold(negedge G, posedge CLR &&& check2, tHDclr, NOTIFIER);
                $hold(negedge G, negedge CLR &&& check2, tHDclr, NOTIFIER);
                $width(negedge CLR, tPWclr, 0, NOTIFIER);
        endspecify
endmodule

module ldmf2a6(Q, D0, D1, S, G, CLR);
        output Q;
        input  D0, D1, S, G, CLR;
        supply0 PRESET;
        reg NOTIFIER;
        not g1(CLEAR, CLR);
        mux g2(DATA, S, D1, D0);
        buf g3(Q, QOUT);
        dl g4(QOUT, DATA, G, PRESET, CLEAR, NOTIFIER);
        // CONDITIONAL TIMING CHECK SIGNALS
        not g5(check1, CLEAR);
        buf g6(check2, DATA);
        // EXTERNAL TIMING CHECK SIGNALS
        xor     g7(sstz1, D0, D1);
        xtc_and g8(xcheck1, check1, sstz1);
        xtc_and g10(xcheck2, check1, S);
        not     g11(sstz3, S);
        xtc_and g12(xcheck3, check1, sstz3);
        // SPECIFY BLOCK
        specify
                specparam tSUd = 0 ;
                specparam tHDd = 0 ;
                specparam tRECclr = 0 ;
                specparam tPWclk = 0 ;
                specparam tHDclr = 0 ;
                specparam tPWclr = 0 ;
                specparam G_01_LH_Q = 0, G_01_HL_Q = 0 ;
                specparam D0_LH_Q = 0, D0_HL_Q = 0 ;
                specparam D1_LH_Q = 0, D1_HL_Q = 0 ;
                specparam S_01_LH_Q = 0, S_01_HL_Q = 0 ;
                specparam S_10_LH_Q = 0, S_10_HL_Q = 0 ;
                specparam CLR_10_LH_Q = 0, CLR_10_HL_Q = 0 ;
                (posedge G *> (Q : 1'b1)) = (G_01_LH_Q, G_01_HL_Q) ;
                (D0 *> Q) = (D0_LH_Q, D0_HL_Q) ;
                (D1 *> Q) = (D1_LH_Q, D1_HL_Q) ;
                (posedge S *> (Q : 1'b1)) = (S_01_LH_Q, S_01_HL_Q) ;
                (negedge S *> (Q : 1'b1)) = (S_10_LH_Q, S_10_HL_Q) ;
                (negedge CLR *> (Q : 1'b1)) = (CLR_10_LH_Q, CLR_10_HL_Q) ;
                $setup(posedge S &&& xcheck1, negedge G, tSUd, NOTIFIER);
                $setup(negedge S &&& xcheck1, negedge G, tSUd, NOTIFIER);
                $setup(posedge D1 &&& xcheck2, negedge G, tSUd, NOTIFIER);
                $setup(negedge D1 &&& xcheck2, negedge G, tSUd, NOTIFIER);
                $setup(posedge D0 &&& xcheck3, negedge G, tSUd, NOTIFIER);
                $setup(negedge D0 &&& xcheck3, negedge G, tSUd, NOTIFIER);
                $hold(negedge G, posedge S &&& xcheck1, tHDd, NOTIFIER);
                $hold(negedge G, negedge S &&& xcheck1, tHDd, NOTIFIER);
                $hold(negedge G, posedge D1 &&& xcheck2, tHDd, NOTIFIER);
                $hold(negedge G, negedge D1 &&& xcheck2, tHDd, NOTIFIER);
                $hold(negedge G, posedge D0 &&& xcheck3, tHDd, NOTIFIER);
                $hold(negedge G, negedge D0 &&& xcheck3, tHDd, NOTIFIER);
                $recovery(posedge CLR, negedge G &&& check2, tRECclr, NOTIFIER);
                $width(posedge G &&& check1, tPWclk, 0, NOTIFIER);
                $width(negedge G &&& check1, tPWclk, 0, NOTIFIER);
                $hold(negedge G, posedge CLR &&& check2, tHDclr, NOTIFIER);
                $hold(negedge G, negedge CLR &&& check2, tHDclr, NOTIFIER);
                $width(negedge CLR, tPWclr, 0, NOTIFIER);
        endspecify
endmodule

module ldmf2a9(Q, D0, D1, S, G, CLR);
        output Q;
        input  D0, D1, S, G, CLR;
        supply0 PRESET;
        reg NOTIFIER;
        not g1(CLEAR, CLR);
        mux g2(DATA, S, D1, D0);
        buf g3(Q, QOUT);
        dl g4(QOUT, DATA, G, PRESET, CLEAR, NOTIFIER);
        // CONDITIONAL TIMING CHECK SIGNALS
        not g5(check1, CLEAR);
        buf g6(check2, DATA);
        // EXTERNAL TIMING CHECK SIGNALS
        xor     g7(sstz1, D0, D1);
        xtc_and g8(xcheck1, check1, sstz1);
        xtc_and g10(xcheck2, check1, S);
        not     g11(sstz3, S);
        xtc_and g12(xcheck3, check1, sstz3);
        // SPECIFY BLOCK
        specify
                specparam tSUd = 0 ;
                specparam tHDd = 0 ;
                specparam tRECclr = 0 ;
                specparam tPWclk = 0 ;
                specparam tHDclr = 0 ;
                specparam tPWclr = 0 ;
                specparam G_01_LH_Q = 0, G_01_HL_Q = 0 ;
                specparam D0_LH_Q = 0, D0_HL_Q = 0 ;
                specparam D1_LH_Q = 0, D1_HL_Q = 0 ;
                specparam S_01_LH_Q = 0, S_01_HL_Q = 0 ;
                specparam S_10_LH_Q = 0, S_10_HL_Q = 0 ;
                specparam CLR_10_LH_Q = 0, CLR_10_HL_Q = 0 ;
                (posedge G *> (Q : 1'b1)) = (G_01_LH_Q, G_01_HL_Q) ;
                (D0 *> Q) = (D0_LH_Q, D0_HL_Q) ;
                (D1 *> Q) = (D1_LH_Q, D1_HL_Q) ;
                (posedge S *> (Q : 1'b1)) = (S_01_LH_Q, S_01_HL_Q) ;
                (negedge S *> (Q : 1'b1)) = (S_10_LH_Q, S_10_HL_Q) ;
                (negedge CLR *> (Q : 1'b1)) = (CLR_10_LH_Q, CLR_10_HL_Q) ;
                $setup(posedge S &&& xcheck1, negedge G, tSUd, NOTIFIER);
                $setup(negedge S &&& xcheck1, negedge G, tSUd, NOTIFIER);
                $setup(posedge D1 &&& xcheck2, negedge G, tSUd, NOTIFIER);
                $setup(negedge D1 &&& xcheck2, negedge G, tSUd, NOTIFIER);
                $setup(posedge D0 &&& xcheck3, negedge G, tSUd, NOTIFIER);
                $setup(negedge D0 &&& xcheck3, negedge G, tSUd, NOTIFIER);
                $hold(negedge G, posedge S &&& xcheck1, tHDd, NOTIFIER);
                $hold(negedge G, negedge S &&& xcheck1, tHDd, NOTIFIER);
                $hold(negedge G, posedge D1 &&& xcheck2, tHDd, NOTIFIER);
                $hold(negedge G, negedge D1 &&& xcheck2, tHDd, NOTIFIER);
                $hold(negedge G, posedge D0 &&& xcheck3, tHDd, NOTIFIER);
                $hold(negedge G, negedge D0 &&& xcheck3, tHDd, NOTIFIER);
                $recovery(posedge CLR, negedge G &&& check2, tRECclr, NOTIFIER);
                $width(posedge G &&& check1, tPWclk, 0, NOTIFIER);
                $width(negedge G &&& check1, tPWclk, 0, NOTIFIER);
                $hold(negedge G, posedge CLR &&& check2, tHDclr, NOTIFIER);
                $hold(negedge G, negedge CLR &&& check2, tHDclr, NOTIFIER);
                $width(negedge CLR, tPWclr, 0, NOTIFIER);
        endspecify
endmodule

module mx2a1(Y, D0, D1, S);
        output Y;
        input  D0, D1, S;
        mux g1(Y, S, D1, D0);
        // SPECIFY BLOCK
        specify
                specparam S_01_LH_Y = 0, S_01_HL_Y = 0 ;
                specparam S_10_LH_Y = 0, S_10_HL_Y = 0 ;
                specparam D1_LH_Y = 0, D1_HL_Y = 0 ;
                specparam D0_LH_Y = 0, D0_HL_Y = 0 ;
                (posedge S *> (Y : 1'b1)) = (S_01_LH_Y, S_01_HL_Y) ;
                (negedge S *> (Y : 1'b1)) = (S_10_LH_Y, S_10_HL_Y) ;
                (D1 *> Y) = (D1_LH_Y, D1_HL_Y) ;
                (D0 *> Y) = (D0_LH_Y, D0_HL_Y) ;
        endspecify
endmodule

module mx2a15(Y, D0, D1, S);
        output Y;
        input  D0, D1, S;
        mux g1(Y, S, D1, D0);
        // SPECIFY BLOCK
        specify
                specparam S_01_LH_Y = 0, S_01_HL_Y = 0 ;
                specparam S_10_LH_Y = 0, S_10_HL_Y = 0 ;
                specparam D1_LH_Y = 0, D1_HL_Y = 0 ;
                specparam D0_LH_Y = 0, D0_HL_Y = 0 ;
                (posedge S *> (Y : 1'b1)) = (S_01_LH_Y, S_01_HL_Y) ;
                (negedge S *> (Y : 1'b1)) = (S_10_LH_Y, S_10_HL_Y) ;
                (D1 *> Y) = (D1_LH_Y, D1_HL_Y) ;
                (D0 *> Y) = (D0_LH_Y, D0_HL_Y) ;
        endspecify
endmodule

module mx2a2(Y, D0, D1, S);
        output Y;
        input  D0, D1, S;
        mux g1(Y, S, D1, D0);
        // SPECIFY BLOCK
        specify
                specparam S_01_LH_Y = 0, S_01_HL_Y = 0 ;
                specparam S_10_LH_Y = 0, S_10_HL_Y = 0 ;
                specparam D1_LH_Y = 0, D1_HL_Y = 0 ;
                specparam D0_LH_Y = 0, D0_HL_Y = 0 ;
                (posedge S *> (Y : 1'b1)) = (S_01_LH_Y, S_01_HL_Y) ;
                (negedge S *> (Y : 1'b1)) = (S_10_LH_Y, S_10_HL_Y) ;
                (D1 *> Y) = (D1_LH_Y, D1_HL_Y) ;
                (D0 *> Y) = (D0_LH_Y, D0_HL_Y) ;
        endspecify
endmodule

module mx2a3(Y, D0, D1, S);
        output Y;
        input  D0, D1, S;
        mux g1(Y, S, D1, D0);
        // SPECIFY BLOCK
        specify
                specparam S_01_LH_Y = 0, S_01_HL_Y = 0 ;
                specparam S_10_LH_Y = 0, S_10_HL_Y = 0 ;
                specparam D1_LH_Y = 0, D1_HL_Y = 0 ;
                specparam D0_LH_Y = 0, D0_HL_Y = 0 ;
                (posedge S *> (Y : 1'b1)) = (S_01_LH_Y, S_01_HL_Y) ;
                (negedge S *> (Y : 1'b1)) = (S_10_LH_Y, S_10_HL_Y) ;
                (D1 *> Y) = (D1_LH_Y, D1_HL_Y) ;
                (D0 *> Y) = (D0_LH_Y, D0_HL_Y) ;
        endspecify
endmodule

module mx2a6(Y, D0, D1, S);
        output Y;
        input  D0, D1, S;
        mux g1(Y, S, D1, D0);
        // SPECIFY BLOCK
        specify
                specparam S_01_LH_Y = 0, S_01_HL_Y = 0 ;
                specparam S_10_LH_Y = 0, S_10_HL_Y = 0 ;
                specparam D1_LH_Y = 0, D1_HL_Y = 0 ;
                specparam D0_LH_Y = 0, D0_HL_Y = 0 ;
                (posedge S *> (Y : 1'b1)) = (S_01_LH_Y, S_01_HL_Y) ;
                (negedge S *> (Y : 1'b1)) = (S_10_LH_Y, S_10_HL_Y) ;
                (D1 *> Y) = (D1_LH_Y, D1_HL_Y) ;
                (D0 *> Y) = (D0_LH_Y, D0_HL_Y) ;
        endspecify
endmodule

module mx2a9(Y, D0, D1, S);
        output Y;
        input  D0, D1, S;
        mux g1(Y, S, D1, D0);
        // SPECIFY BLOCK
        specify
                specparam S_01_LH_Y = 0, S_01_HL_Y = 0 ;
                specparam S_10_LH_Y = 0, S_10_HL_Y = 0 ;
                specparam D1_LH_Y = 0, D1_HL_Y = 0 ;
                specparam D0_LH_Y = 0, D0_HL_Y = 0 ;
                (posedge S *> (Y : 1'b1)) = (S_01_LH_Y, S_01_HL_Y) ;
                (negedge S *> (Y : 1'b1)) = (S_10_LH_Y, S_10_HL_Y) ;
                (D1 *> Y) = (D1_LH_Y, D1_HL_Y) ;
                (D0 *> Y) = (D0_LH_Y, D0_HL_Y) ;
        endspecify
endmodule

module mx2d1(Y, D0, D1, S);
        output Y;
        input  D0, D1, S;
        mux g1(N1, S, D1, D0);
        not g2(Y, N1);
        // SPECIFY BLOCK
        specify
                specparam S_01_LH_Y = 0, S_01_HL_Y = 0 ;
                specparam S_10_LH_Y = 0, S_10_HL_Y = 0 ;
                specparam D1_LH_Y = 0, D1_HL_Y = 0 ;
                specparam D0_LH_Y = 0, D0_HL_Y = 0 ;
                (posedge S *> (Y : 1'b1)) = (S_01_LH_Y, S_01_HL_Y) ;
                (negedge S *> (Y : 1'b1)) = (S_10_LH_Y, S_10_HL_Y) ;
                (D1 *> Y) = (D1_LH_Y, D1_HL_Y) ;
                (D0 *> Y) = (D0_LH_Y, D0_HL_Y) ;
        endspecify
endmodule

module mx2d15(Y, D0, D1, S);
        output Y;
        input  D0, D1, S;
        mux g1(N1, S, D1, D0);
        not g2(Y, N1);
        // SPECIFY BLOCK
        specify
                specparam S_01_LH_Y = 0, S_01_HL_Y = 0 ;
                specparam S_10_LH_Y = 0, S_10_HL_Y = 0 ;
                specparam D1_LH_Y = 0, D1_HL_Y = 0 ;
                specparam D0_LH_Y = 0, D0_HL_Y = 0 ;
                (posedge S *> (Y : 1'b1)) = (S_01_LH_Y, S_01_HL_Y) ;
                (negedge S *> (Y : 1'b1)) = (S_10_LH_Y, S_10_HL_Y) ;
                (D1 *> Y) = (D1_LH_Y, D1_HL_Y) ;
                (D0 *> Y) = (D0_LH_Y, D0_HL_Y) ;
        endspecify
endmodule

module mx2d2(Y, D0, D1, S);
        output Y;
        input  D0, D1, S;
        mux g1(N1, S, D1, D0);
        not g2(Y, N1);
        // SPECIFY BLOCK
        specify
                specparam S_01_LH_Y = 0, S_01_HL_Y = 0 ;
                specparam S_10_LH_Y = 0, S_10_HL_Y = 0 ;
                specparam D1_LH_Y = 0, D1_HL_Y = 0 ;
                specparam D0_LH_Y = 0, D0_HL_Y = 0 ;
                (posedge S *> (Y : 1'b1)) = (S_01_LH_Y, S_01_HL_Y) ;
                (negedge S *> (Y : 1'b1)) = (S_10_LH_Y, S_10_HL_Y) ;
                (D1 *> Y) = (D1_LH_Y, D1_HL_Y) ;
                (D0 *> Y) = (D0_LH_Y, D0_HL_Y) ;
        endspecify
endmodule

module mx2d3(Y, D0, D1, S);
        output Y;
        input  D0, D1, S;
        mux g1(N1, S, D1, D0);
        not g2(Y, N1);
        // SPECIFY BLOCK
        specify
                specparam S_01_LH_Y = 0, S_01_HL_Y = 0 ;
                specparam S_10_LH_Y = 0, S_10_HL_Y = 0 ;
                specparam D1_LH_Y = 0, D1_HL_Y = 0 ;
                specparam D0_LH_Y = 0, D0_HL_Y = 0 ;
                (posedge S *> (Y : 1'b1)) = (S_01_LH_Y, S_01_HL_Y) ;
                (negedge S *> (Y : 1'b1)) = (S_10_LH_Y, S_10_HL_Y) ;
                (D1 *> Y) = (D1_LH_Y, D1_HL_Y) ;
                (D0 *> Y) = (D0_LH_Y, D0_HL_Y) ;
        endspecify
endmodule

module mx2d6(Y, D0, D1, S);
        output Y;
        input  D0, D1, S;
        mux g1(N1, S, D1, D0);
        not g2(Y, N1);
        // SPECIFY BLOCK
        specify
                specparam S_01_LH_Y = 0, S_01_HL_Y = 0 ;
                specparam S_10_LH_Y = 0, S_10_HL_Y = 0 ;
                specparam D1_LH_Y = 0, D1_HL_Y = 0 ;
                specparam D0_LH_Y = 0, D0_HL_Y = 0 ;
                (posedge S *> (Y : 1'b1)) = (S_01_LH_Y, S_01_HL_Y) ;
                (negedge S *> (Y : 1'b1)) = (S_10_LH_Y, S_10_HL_Y) ;
                (D1 *> Y) = (D1_LH_Y, D1_HL_Y) ;
                (D0 *> Y) = (D0_LH_Y, D0_HL_Y) ;
        endspecify
endmodule

module mx2d9(Y, D0, D1, S);
        output Y;
        input  D0, D1, S;
        mux g1(N1, S, D1, D0);
        not g2(Y, N1);
        // SPECIFY BLOCK
        specify
                specparam S_01_LH_Y = 0, S_01_HL_Y = 0 ;
                specparam S_10_LH_Y = 0, S_10_HL_Y = 0 ;
                specparam D1_LH_Y = 0, D1_HL_Y = 0 ;
                specparam D0_LH_Y = 0, D0_HL_Y = 0 ;
                (posedge S *> (Y : 1'b1)) = (S_01_LH_Y, S_01_HL_Y) ;
                (negedge S *> (Y : 1'b1)) = (S_10_LH_Y, S_10_HL_Y) ;
                (D1 *> Y) = (D1_LH_Y, D1_HL_Y) ;
                (D0 *> Y) = (D0_LH_Y, D0_HL_Y) ;
        endspecify
endmodule

module mx3a1(Y, D0, D1, D2, S0, S1);
        output Y;
        input  D0, D1, D2, S0, S1;
        mux g1(N1, S0, D1, D0);
        mux g2(Y, S1, D2, N1);
        // SPECIFY BLOCK
        specify
                specparam S1_01_LH_Y = 0, S1_01_HL_Y = 0 ;
                specparam S1_10_LH_Y = 0, S1_10_HL_Y = 0 ;
                specparam D2_LH_Y = 0, D2_HL_Y = 0 ;
                specparam S0_01_LH_Y = 0, S0_01_HL_Y = 0 ;
                specparam S0_10_LH_Y = 0, S0_10_HL_Y = 0 ;
                specparam D1_LH_Y = 0, D1_HL_Y = 0 ;
                specparam D0_LH_Y = 0, D0_HL_Y = 0 ;
                (posedge S1 *> (Y : 1'b1)) = (S1_01_LH_Y, S1_01_HL_Y) ;
                (negedge S1 *> (Y : 1'b1)) = (S1_10_LH_Y, S1_10_HL_Y) ;
                (D2 *> Y) = (D2_LH_Y, D2_HL_Y) ;
                (posedge S0 *> (Y : 1'b1)) = (S0_01_LH_Y, S0_01_HL_Y) ;
                (negedge S0 *> (Y : 1'b1)) = (S0_10_LH_Y, S0_10_HL_Y) ;
                (D1 *> Y) = (D1_LH_Y, D1_HL_Y) ;
                (D0 *> Y) = (D0_LH_Y, D0_HL_Y) ;
        endspecify
endmodule

module mx3a15(Y, D0, D1, D2, S0, S1);
        output Y;
        input  D0, D1, D2, S0, S1;
        mux g1(N1, S0, D1, D0);
        mux g2(Y, S1, D2, N1);
        // SPECIFY BLOCK
        specify
                specparam S1_01_LH_Y = 0, S1_01_HL_Y = 0 ;
                specparam S1_10_LH_Y = 0, S1_10_HL_Y = 0 ;
                specparam D2_LH_Y = 0, D2_HL_Y = 0 ;
                specparam S0_01_LH_Y = 0, S0_01_HL_Y = 0 ;
                specparam S0_10_LH_Y = 0, S0_10_HL_Y = 0 ;
                specparam D1_LH_Y = 0, D1_HL_Y = 0 ;
                specparam D0_LH_Y = 0, D0_HL_Y = 0 ;
                (posedge S1 *> (Y : 1'b1)) = (S1_01_LH_Y, S1_01_HL_Y) ;
                (negedge S1 *> (Y : 1'b1)) = (S1_10_LH_Y, S1_10_HL_Y) ;
                (D2 *> Y) = (D2_LH_Y, D2_HL_Y) ;
                (posedge S0 *> (Y : 1'b1)) = (S0_01_LH_Y, S0_01_HL_Y) ;
                (negedge S0 *> (Y : 1'b1)) = (S0_10_LH_Y, S0_10_HL_Y) ;
                (D1 *> Y) = (D1_LH_Y, D1_HL_Y) ;
                (D0 *> Y) = (D0_LH_Y, D0_HL_Y) ;
        endspecify
endmodule

module mx3a2(Y, D0, D1, D2, S0, S1);
        output Y;
        input  D0, D1, D2, S0, S1;
        mux g1(N1, S0, D1, D0);
        mux g2(Y, S1, D2, N1);
        // SPECIFY BLOCK
        specify
                specparam S1_01_LH_Y = 0, S1_01_HL_Y = 0 ;
                specparam S1_10_LH_Y = 0, S1_10_HL_Y = 0 ;
                specparam D2_LH_Y = 0, D2_HL_Y = 0 ;
                specparam S0_01_LH_Y = 0, S0_01_HL_Y = 0 ;
                specparam S0_10_LH_Y = 0, S0_10_HL_Y = 0 ;
                specparam D1_LH_Y = 0, D1_HL_Y = 0 ;
                specparam D0_LH_Y = 0, D0_HL_Y = 0 ;
                (posedge S1 *> (Y : 1'b1)) = (S1_01_LH_Y, S1_01_HL_Y) ;
                (negedge S1 *> (Y : 1'b1)) = (S1_10_LH_Y, S1_10_HL_Y) ;
                (D2 *> Y) = (D2_LH_Y, D2_HL_Y) ;
                (posedge S0 *> (Y : 1'b1)) = (S0_01_LH_Y, S0_01_HL_Y) ;
                (negedge S0 *> (Y : 1'b1)) = (S0_10_LH_Y, S0_10_HL_Y) ;
                (D1 *> Y) = (D1_LH_Y, D1_HL_Y) ;
                (D0 *> Y) = (D0_LH_Y, D0_HL_Y) ;
        endspecify
endmodule

module mx3a3(Y, D0, D1, D2, S0, S1);
        output Y;
        input  D0, D1, D2, S0, S1;
        mux g1(N1, S0, D1, D0);
        mux g2(Y, S1, D2, N1);
        // SPECIFY BLOCK
        specify
                specparam S1_01_LH_Y = 0, S1_01_HL_Y = 0 ;
                specparam S1_10_LH_Y = 0, S1_10_HL_Y = 0 ;
                specparam D2_LH_Y = 0, D2_HL_Y = 0 ;
                specparam S0_01_LH_Y = 0, S0_01_HL_Y = 0 ;
                specparam S0_10_LH_Y = 0, S0_10_HL_Y = 0 ;
                specparam D1_LH_Y = 0, D1_HL_Y = 0 ;
                specparam D0_LH_Y = 0, D0_HL_Y = 0 ;
                (posedge S1 *> (Y : 1'b1)) = (S1_01_LH_Y, S1_01_HL_Y) ;
                (negedge S1 *> (Y : 1'b1)) = (S1_10_LH_Y, S1_10_HL_Y) ;
                (D2 *> Y) = (D2_LH_Y, D2_HL_Y) ;
                (posedge S0 *> (Y : 1'b1)) = (S0_01_LH_Y, S0_01_HL_Y) ;
                (negedge S0 *> (Y : 1'b1)) = (S0_10_LH_Y, S0_10_HL_Y) ;
                (D1 *> Y) = (D1_LH_Y, D1_HL_Y) ;
                (D0 *> Y) = (D0_LH_Y, D0_HL_Y) ;
        endspecify
endmodule

module mx3a6(Y, D0, D1, D2, S0, S1);
        output Y;
        input  D0, D1, D2, S0, S1;
        mux g1(N1, S0, D1, D0);
        mux g2(Y, S1, D2, N1);
        // SPECIFY BLOCK
        specify
                specparam S1_01_LH_Y = 0, S1_01_HL_Y = 0 ;
                specparam S1_10_LH_Y = 0, S1_10_HL_Y = 0 ;
                specparam D2_LH_Y = 0, D2_HL_Y = 0 ;
                specparam S0_01_LH_Y = 0, S0_01_HL_Y = 0 ;
                specparam S0_10_LH_Y = 0, S0_10_HL_Y = 0 ;
                specparam D1_LH_Y = 0, D1_HL_Y = 0 ;
                specparam D0_LH_Y = 0, D0_HL_Y = 0 ;
                (posedge S1 *> (Y : 1'b1)) = (S1_01_LH_Y, S1_01_HL_Y) ;
                (negedge S1 *> (Y : 1'b1)) = (S1_10_LH_Y, S1_10_HL_Y) ;
                (D2 *> Y) = (D2_LH_Y, D2_HL_Y) ;
                (posedge S0 *> (Y : 1'b1)) = (S0_01_LH_Y, S0_01_HL_Y) ;
                (negedge S0 *> (Y : 1'b1)) = (S0_10_LH_Y, S0_10_HL_Y) ;
                (D1 *> Y) = (D1_LH_Y, D1_HL_Y) ;
                (D0 *> Y) = (D0_LH_Y, D0_HL_Y) ;
        endspecify
endmodule

module mx3a9(Y, D0, D1, D2, S0, S1);
        output Y;
        input  D0, D1, D2, S0, S1;
        mux g1(N1, S0, D1, D0);
        mux g2(Y, S1, D2, N1);
        // SPECIFY BLOCK
        specify
                specparam S1_01_LH_Y = 0, S1_01_HL_Y = 0 ;
                specparam S1_10_LH_Y = 0, S1_10_HL_Y = 0 ;
                specparam D2_LH_Y = 0, D2_HL_Y = 0 ;
                specparam S0_01_LH_Y = 0, S0_01_HL_Y = 0 ;
                specparam S0_10_LH_Y = 0, S0_10_HL_Y = 0 ;
                specparam D1_LH_Y = 0, D1_HL_Y = 0 ;
                specparam D0_LH_Y = 0, D0_HL_Y = 0 ;
                (posedge S1 *> (Y : 1'b1)) = (S1_01_LH_Y, S1_01_HL_Y) ;
                (negedge S1 *> (Y : 1'b1)) = (S1_10_LH_Y, S1_10_HL_Y) ;
                (D2 *> Y) = (D2_LH_Y, D2_HL_Y) ;
                (posedge S0 *> (Y : 1'b1)) = (S0_01_LH_Y, S0_01_HL_Y) ;
                (negedge S0 *> (Y : 1'b1)) = (S0_10_LH_Y, S0_10_HL_Y) ;
                (D1 *> Y) = (D1_LH_Y, D1_HL_Y) ;
                (D0 *> Y) = (D0_LH_Y, D0_HL_Y) ;
        endspecify
endmodule

module mx3d1(Y, D0, D1, D2, S0, S1);
        output Y;
        input  D0, D1, D2, S0, S1;
        mux g1(N2, S0, D1, D0);
        mux g2(N1, S1, D2, N2);
        not g3(Y, N1);
        // SPECIFY BLOCK
        specify
                specparam S1_01_LH_Y = 0, S1_01_HL_Y = 0 ;
                specparam S1_10_LH_Y = 0, S1_10_HL_Y = 0 ;
                specparam D2_LH_Y = 0, D2_HL_Y = 0 ;
                specparam S0_01_LH_Y = 0, S0_01_HL_Y = 0 ;
                specparam S0_10_LH_Y = 0, S0_10_HL_Y = 0 ;
                specparam D1_LH_Y = 0, D1_HL_Y = 0 ;
                specparam D0_LH_Y = 0, D0_HL_Y = 0 ;
                (posedge S1 *> (Y : 1'b1)) = (S1_01_LH_Y, S1_01_HL_Y) ;
                (negedge S1 *> (Y : 1'b1)) = (S1_10_LH_Y, S1_10_HL_Y) ;
                (D2 *> Y) = (D2_LH_Y, D2_HL_Y) ;
                (posedge S0 *> (Y : 1'b1)) = (S0_01_LH_Y, S0_01_HL_Y) ;
                (negedge S0 *> (Y : 1'b1)) = (S0_10_LH_Y, S0_10_HL_Y) ;
                (D1 *> Y) = (D1_LH_Y, D1_HL_Y) ;
                (D0 *> Y) = (D0_LH_Y, D0_HL_Y) ;
        endspecify
endmodule

module mx3d15(Y, D0, D1, D2, S0, S1);
        output Y;
        input  D0, D1, D2, S0, S1;
        mux g1(N2, S0, D1, D0);
        mux g2(N1, S1, D2, N2);
        not g3(Y, N1);
        // SPECIFY BLOCK
        specify
                specparam S1_01_LH_Y = 0, S1_01_HL_Y = 0 ;
                specparam S1_10_LH_Y = 0, S1_10_HL_Y = 0 ;
                specparam D2_LH_Y = 0, D2_HL_Y = 0 ;
                specparam S0_01_LH_Y = 0, S0_01_HL_Y = 0 ;
                specparam S0_10_LH_Y = 0, S0_10_HL_Y = 0 ;
                specparam D1_LH_Y = 0, D1_HL_Y = 0 ;
                specparam D0_LH_Y = 0, D0_HL_Y = 0 ;
                (posedge S1 *> (Y : 1'b1)) = (S1_01_LH_Y, S1_01_HL_Y) ;
                (negedge S1 *> (Y : 1'b1)) = (S1_10_LH_Y, S1_10_HL_Y) ;
                (D2 *> Y) = (D2_LH_Y, D2_HL_Y) ;
                (posedge S0 *> (Y : 1'b1)) = (S0_01_LH_Y, S0_01_HL_Y) ;
                (negedge S0 *> (Y : 1'b1)) = (S0_10_LH_Y, S0_10_HL_Y) ;
                (D1 *> Y) = (D1_LH_Y, D1_HL_Y) ;
                (D0 *> Y) = (D0_LH_Y, D0_HL_Y) ;
        endspecify
endmodule

module mx3d2(Y, D0, D1, D2, S0, S1);
        output Y;
        input  D0, D1, D2, S0, S1;
        mux g1(N2, S0, D1, D0);
        mux g2(N1, S1, D2, N2);
        not g3(Y, N1);
        // SPECIFY BLOCK
        specify
                specparam S1_01_LH_Y = 0, S1_01_HL_Y = 0 ;
                specparam S1_10_LH_Y = 0, S1_10_HL_Y = 0 ;
                specparam D2_LH_Y = 0, D2_HL_Y = 0 ;
                specparam S0_01_LH_Y = 0, S0_01_HL_Y = 0 ;
                specparam S0_10_LH_Y = 0, S0_10_HL_Y = 0 ;
                specparam D1_LH_Y = 0, D1_HL_Y = 0 ;
                specparam D0_LH_Y = 0, D0_HL_Y = 0 ;
                (posedge S1 *> (Y : 1'b1)) = (S1_01_LH_Y, S1_01_HL_Y) ;
                (negedge S1 *> (Y : 1'b1)) = (S1_10_LH_Y, S1_10_HL_Y) ;
                (D2 *> Y) = (D2_LH_Y, D2_HL_Y) ;
                (posedge S0 *> (Y : 1'b1)) = (S0_01_LH_Y, S0_01_HL_Y) ;
                (negedge S0 *> (Y : 1'b1)) = (S0_10_LH_Y, S0_10_HL_Y) ;
                (D1 *> Y) = (D1_LH_Y, D1_HL_Y) ;
                (D0 *> Y) = (D0_LH_Y, D0_HL_Y) ;
        endspecify
endmodule

module mx3d3(Y, D0, D1, D2, S0, S1);
        output Y;
        input  D0, D1, D2, S0, S1;
        mux g1(N2, S0, D1, D0);
        mux g2(N1, S1, D2, N2);
        not g3(Y, N1);
        // SPECIFY BLOCK
        specify
                specparam S1_01_LH_Y = 0, S1_01_HL_Y = 0 ;
                specparam S1_10_LH_Y = 0, S1_10_HL_Y = 0 ;
                specparam D2_LH_Y = 0, D2_HL_Y = 0 ;
                specparam S0_01_LH_Y = 0, S0_01_HL_Y = 0 ;
                specparam S0_10_LH_Y = 0, S0_10_HL_Y = 0 ;
                specparam D1_LH_Y = 0, D1_HL_Y = 0 ;
                specparam D0_LH_Y = 0, D0_HL_Y = 0 ;
                (posedge S1 *> (Y : 1'b1)) = (S1_01_LH_Y, S1_01_HL_Y) ;
                (negedge S1 *> (Y : 1'b1)) = (S1_10_LH_Y, S1_10_HL_Y) ;
                (D2 *> Y) = (D2_LH_Y, D2_HL_Y) ;
                (posedge S0 *> (Y : 1'b1)) = (S0_01_LH_Y, S0_01_HL_Y) ;
                (negedge S0 *> (Y : 1'b1)) = (S0_10_LH_Y, S0_10_HL_Y) ;
                (D1 *> Y) = (D1_LH_Y, D1_HL_Y) ;
                (D0 *> Y) = (D0_LH_Y, D0_HL_Y) ;
        endspecify
endmodule

module mx3d6(Y, D0, D1, D2, S0, S1);
        output Y;
        input  D0, D1, D2, S0, S1;
        mux g1(N2, S0, D1, D0);
        mux g2(N1, S1, D2, N2);
        not g3(Y, N1);
        // SPECIFY BLOCK
        specify
                specparam S1_01_LH_Y = 0, S1_01_HL_Y = 0 ;
                specparam S1_10_LH_Y = 0, S1_10_HL_Y = 0 ;
                specparam D2_LH_Y = 0, D2_HL_Y = 0 ;
                specparam S0_01_LH_Y = 0, S0_01_HL_Y = 0 ;
                specparam S0_10_LH_Y = 0, S0_10_HL_Y = 0 ;
                specparam D1_LH_Y = 0, D1_HL_Y = 0 ;
                specparam D0_LH_Y = 0, D0_HL_Y = 0 ;
                (posedge S1 *> (Y : 1'b1)) = (S1_01_LH_Y, S1_01_HL_Y) ;
                (negedge S1 *> (Y : 1'b1)) = (S1_10_LH_Y, S1_10_HL_Y) ;
                (D2 *> Y) = (D2_LH_Y, D2_HL_Y) ;
                (posedge S0 *> (Y : 1'b1)) = (S0_01_LH_Y, S0_01_HL_Y) ;
                (negedge S0 *> (Y : 1'b1)) = (S0_10_LH_Y, S0_10_HL_Y) ;
                (D1 *> Y) = (D1_LH_Y, D1_HL_Y) ;
                (D0 *> Y) = (D0_LH_Y, D0_HL_Y) ;
        endspecify
endmodule

module mx3d9(Y, D0, D1, D2, S0, S1);
        output Y;
        input  D0, D1, D2, S0, S1;
        mux g1(N2, S0, D1, D0);
        mux g2(N1, S1, D2, N2);
        not g3(Y, N1);
        // SPECIFY BLOCK
        specify
                specparam S1_01_LH_Y = 0, S1_01_HL_Y = 0 ;
                specparam S1_10_LH_Y = 0, S1_10_HL_Y = 0 ;
                specparam D2_LH_Y = 0, D2_HL_Y = 0 ;
                specparam S0_01_LH_Y = 0, S0_01_HL_Y = 0 ;
                specparam S0_10_LH_Y = 0, S0_10_HL_Y = 0 ;
                specparam D1_LH_Y = 0, D1_HL_Y = 0 ;
                specparam D0_LH_Y = 0, D0_HL_Y = 0 ;
                (posedge S1 *> (Y : 1'b1)) = (S1_01_LH_Y, S1_01_HL_Y) ;
                (negedge S1 *> (Y : 1'b1)) = (S1_10_LH_Y, S1_10_HL_Y) ;
                (D2 *> Y) = (D2_LH_Y, D2_HL_Y) ;
                (posedge S0 *> (Y : 1'b1)) = (S0_01_LH_Y, S0_01_HL_Y) ;
                (negedge S0 *> (Y : 1'b1)) = (S0_10_LH_Y, S0_10_HL_Y) ;
                (D1 *> Y) = (D1_LH_Y, D1_HL_Y) ;
                (D0 *> Y) = (D0_LH_Y, D0_HL_Y) ;
        endspecify
endmodule

module mx4a1(Y, D0, D1, D2, D3, S0, S1);
        output Y;
        input  D0, D1, D2, D3, S0, S1;
        mux g1(N1, S0, D3, D2);
        mux g2(N2, S0, D1, D0);
        mux g3(Y, S1, N1, N2);
        // SPECIFY BLOCK
        specify
                specparam S1_01_LH_Y = 0, S1_01_HL_Y = 0 ;
                specparam S1_10_LH_Y = 0, S1_10_HL_Y = 0 ;
                specparam S0_01_LH_Y = 0, S0_01_HL_Y = 0 ;
                specparam S0_10_LH_Y = 0, S0_10_HL_Y = 0 ;
                specparam D3_LH_Y = 0, D3_HL_Y = 0 ;
                specparam D2_LH_Y = 0, D2_HL_Y = 0 ;
                specparam D1_LH_Y = 0, D1_HL_Y = 0 ;
                specparam D0_LH_Y = 0, D0_HL_Y = 0 ;
                (posedge S1 *> (Y : 1'b1)) = (S1_01_LH_Y, S1_01_HL_Y) ;
                (negedge S1 *> (Y : 1'b1)) = (S1_10_LH_Y, S1_10_HL_Y) ;
                (posedge S0 *> (Y : 1'b1)) = (S0_01_LH_Y, S0_01_HL_Y) ;
                (negedge S0 *> (Y : 1'b1)) = (S0_10_LH_Y, S0_10_HL_Y) ;
                (D3 *> Y) = (D3_LH_Y, D3_HL_Y) ;
                (D2 *> Y) = (D2_LH_Y, D2_HL_Y) ;
                (D1 *> Y) = (D1_LH_Y, D1_HL_Y) ;
                (D0 *> Y) = (D0_LH_Y, D0_HL_Y) ;
        endspecify
endmodule

module mx4a15(Y, D0, D1, D2, D3, S0, S1);
        output Y;
        input  D0, D1, D2, D3, S0, S1;
        mux g1(N1, S0, D3, D2);
        mux g2(N2, S0, D1, D0);
        mux g3(Y, S1, N1, N2);
        // SPECIFY BLOCK
        specify
                specparam S1_01_LH_Y = 0, S1_01_HL_Y = 0 ;
                specparam S1_10_LH_Y = 0, S1_10_HL_Y = 0 ;
                specparam S0_01_LH_Y = 0, S0_01_HL_Y = 0 ;
                specparam S0_10_LH_Y = 0, S0_10_HL_Y = 0 ;
                specparam D3_LH_Y = 0, D3_HL_Y = 0 ;
                specparam D2_LH_Y = 0, D2_HL_Y = 0 ;
                specparam D1_LH_Y = 0, D1_HL_Y = 0 ;
                specparam D0_LH_Y = 0, D0_HL_Y = 0 ;
                (posedge S1 *> (Y : 1'b1)) = (S1_01_LH_Y, S1_01_HL_Y) ;
                (negedge S1 *> (Y : 1'b1)) = (S1_10_LH_Y, S1_10_HL_Y) ;
                (posedge S0 *> (Y : 1'b1)) = (S0_01_LH_Y, S0_01_HL_Y) ;
                (negedge S0 *> (Y : 1'b1)) = (S0_10_LH_Y, S0_10_HL_Y) ;
                (D3 *> Y) = (D3_LH_Y, D3_HL_Y) ;
                (D2 *> Y) = (D2_LH_Y, D2_HL_Y) ;
                (D1 *> Y) = (D1_LH_Y, D1_HL_Y) ;
                (D0 *> Y) = (D0_LH_Y, D0_HL_Y) ;
        endspecify
endmodule

module mx4a2(Y, D0, D1, D2, D3, S0, S1);
        output Y;
        input  D0, D1, D2, D3, S0, S1;
        mux g1(N1, S0, D3, D2);
        mux g2(N2, S0, D1, D0);
        mux g3(Y, S1, N1, N2);
        // SPECIFY BLOCK
        specify
                specparam S1_01_LH_Y = 0, S1_01_HL_Y = 0 ;
                specparam S1_10_LH_Y = 0, S1_10_HL_Y = 0 ;
                specparam S0_01_LH_Y = 0, S0_01_HL_Y = 0 ;
                specparam S0_10_LH_Y = 0, S0_10_HL_Y = 0 ;
                specparam D3_LH_Y = 0, D3_HL_Y = 0 ;
                specparam D2_LH_Y = 0, D2_HL_Y = 0 ;
                specparam D1_LH_Y = 0, D1_HL_Y = 0 ;
                specparam D0_LH_Y = 0, D0_HL_Y = 0 ;
                (posedge S1 *> (Y : 1'b1)) = (S1_01_LH_Y, S1_01_HL_Y) ;
                (negedge S1 *> (Y : 1'b1)) = (S1_10_LH_Y, S1_10_HL_Y) ;
                (posedge S0 *> (Y : 1'b1)) = (S0_01_LH_Y, S0_01_HL_Y) ;
                (negedge S0 *> (Y : 1'b1)) = (S0_10_LH_Y, S0_10_HL_Y) ;
                (D3 *> Y) = (D3_LH_Y, D3_HL_Y) ;
                (D2 *> Y) = (D2_LH_Y, D2_HL_Y) ;
                (D1 *> Y) = (D1_LH_Y, D1_HL_Y) ;
                (D0 *> Y) = (D0_LH_Y, D0_HL_Y) ;
        endspecify
endmodule

module mx4a3(Y, D0, D1, D2, D3, S0, S1);
        output Y;
        input  D0, D1, D2, D3, S0, S1;
        mux g1(N1, S0, D3, D2);
        mux g2(N2, S0, D1, D0);
        mux g3(Y, S1, N1, N2);
        // SPECIFY BLOCK
        specify
                specparam S1_01_LH_Y = 0, S1_01_HL_Y = 0 ;
                specparam S1_10_LH_Y = 0, S1_10_HL_Y = 0 ;
                specparam S0_01_LH_Y = 0, S0_01_HL_Y = 0 ;
                specparam S0_10_LH_Y = 0, S0_10_HL_Y = 0 ;
                specparam D3_LH_Y = 0, D3_HL_Y = 0 ;
                specparam D2_LH_Y = 0, D2_HL_Y = 0 ;
                specparam D1_LH_Y = 0, D1_HL_Y = 0 ;
                specparam D0_LH_Y = 0, D0_HL_Y = 0 ;
                (posedge S1 *> (Y : 1'b1)) = (S1_01_LH_Y, S1_01_HL_Y) ;
                (negedge S1 *> (Y : 1'b1)) = (S1_10_LH_Y, S1_10_HL_Y) ;
                (posedge S0 *> (Y : 1'b1)) = (S0_01_LH_Y, S0_01_HL_Y) ;
                (negedge S0 *> (Y : 1'b1)) = (S0_10_LH_Y, S0_10_HL_Y) ;
                (D3 *> Y) = (D3_LH_Y, D3_HL_Y) ;
                (D2 *> Y) = (D2_LH_Y, D2_HL_Y) ;
                (D1 *> Y) = (D1_LH_Y, D1_HL_Y) ;
                (D0 *> Y) = (D0_LH_Y, D0_HL_Y) ;
        endspecify
endmodule

module mx4a6(Y, D0, D1, D2, D3, S0, S1);
        output Y;
        input  D0, D1, D2, D3, S0, S1;
        mux g1(N1, S0, D3, D2);
        mux g2(N2, S0, D1, D0);
        mux g3(Y, S1, N1, N2);
        // SPECIFY BLOCK
        specify
                specparam S1_01_LH_Y = 0, S1_01_HL_Y = 0 ;
                specparam S1_10_LH_Y = 0, S1_10_HL_Y = 0 ;
                specparam S0_01_LH_Y = 0, S0_01_HL_Y = 0 ;
                specparam S0_10_LH_Y = 0, S0_10_HL_Y = 0 ;
                specparam D3_LH_Y = 0, D3_HL_Y = 0 ;
                specparam D2_LH_Y = 0, D2_HL_Y = 0 ;
                specparam D1_LH_Y = 0, D1_HL_Y = 0 ;
                specparam D0_LH_Y = 0, D0_HL_Y = 0 ;
                (posedge S1 *> (Y : 1'b1)) = (S1_01_LH_Y, S1_01_HL_Y) ;
                (negedge S1 *> (Y : 1'b1)) = (S1_10_LH_Y, S1_10_HL_Y) ;
                (posedge S0 *> (Y : 1'b1)) = (S0_01_LH_Y, S0_01_HL_Y) ;
                (negedge S0 *> (Y : 1'b1)) = (S0_10_LH_Y, S0_10_HL_Y) ;
                (D3 *> Y) = (D3_LH_Y, D3_HL_Y) ;
                (D2 *> Y) = (D2_LH_Y, D2_HL_Y) ;
                (D1 *> Y) = (D1_LH_Y, D1_HL_Y) ;
                (D0 *> Y) = (D0_LH_Y, D0_HL_Y) ;
        endspecify
endmodule

module mx4a9(Y, D0, D1, D2, D3, S0, S1);
        output Y;
        input  D0, D1, D2, D3, S0, S1;
        mux g1(N1, S0, D3, D2);
        mux g2(N2, S0, D1, D0);
        mux g3(Y, S1, N1, N2);
        // SPECIFY BLOCK
        specify
                specparam S1_01_LH_Y = 0, S1_01_HL_Y = 0 ;
                specparam S1_10_LH_Y = 0, S1_10_HL_Y = 0 ;
                specparam S0_01_LH_Y = 0, S0_01_HL_Y = 0 ;
                specparam S0_10_LH_Y = 0, S0_10_HL_Y = 0 ;
                specparam D3_LH_Y = 0, D3_HL_Y = 0 ;
                specparam D2_LH_Y = 0, D2_HL_Y = 0 ;
                specparam D1_LH_Y = 0, D1_HL_Y = 0 ;
                specparam D0_LH_Y = 0, D0_HL_Y = 0 ;
                (posedge S1 *> (Y : 1'b1)) = (S1_01_LH_Y, S1_01_HL_Y) ;
                (negedge S1 *> (Y : 1'b1)) = (S1_10_LH_Y, S1_10_HL_Y) ;
                (posedge S0 *> (Y : 1'b1)) = (S0_01_LH_Y, S0_01_HL_Y) ;
                (negedge S0 *> (Y : 1'b1)) = (S0_10_LH_Y, S0_10_HL_Y) ;
                (D3 *> Y) = (D3_LH_Y, D3_HL_Y) ;
                (D2 *> Y) = (D2_LH_Y, D2_HL_Y) ;
                (D1 *> Y) = (D1_LH_Y, D1_HL_Y) ;
                (D0 *> Y) = (D0_LH_Y, D0_HL_Y) ;
        endspecify
endmodule

module mx4e1(Y, D0, D1, D2, D3, S0, S1);
        output Y;
        input  D0, D1, D2, D3, S0, S1;
        mux g1(N2, S0, D3, D2);
        mux g2(N3, S0, D1, D0);
        mux g3(N1, S1, N2, N3);
        not g4(Y, N1);
        // SPECIFY BLOCK
        specify
                specparam S1_01_LH_Y = 0, S1_01_HL_Y = 0 ;
                specparam S1_10_LH_Y = 0, S1_10_HL_Y = 0 ;
                specparam S0_01_LH_Y = 0, S0_01_HL_Y = 0 ;
                specparam S0_10_LH_Y = 0, S0_10_HL_Y = 0 ;
                specparam D3_LH_Y = 0, D3_HL_Y = 0 ;
                specparam D2_LH_Y = 0, D2_HL_Y = 0 ;
                specparam D1_LH_Y = 0, D1_HL_Y = 0 ;
                specparam D0_LH_Y = 0, D0_HL_Y = 0 ;
                (posedge S1 *> (Y : 1'b1)) = (S1_01_LH_Y, S1_01_HL_Y) ;
                (negedge S1 *> (Y : 1'b1)) = (S1_10_LH_Y, S1_10_HL_Y) ;
                (posedge S0 *> (Y : 1'b1)) = (S0_01_LH_Y, S0_01_HL_Y) ;
                (negedge S0 *> (Y : 1'b1)) = (S0_10_LH_Y, S0_10_HL_Y) ;
                (D3 *> Y) = (D3_LH_Y, D3_HL_Y) ;
                (D2 *> Y) = (D2_LH_Y, D2_HL_Y) ;
                (D1 *> Y) = (D1_LH_Y, D1_HL_Y) ;
                (D0 *> Y) = (D0_LH_Y, D0_HL_Y) ;
        endspecify
endmodule

module mx4e15(Y, D0, D1, D2, D3, S0, S1);
        output Y;
        input  D0, D1, D2, D3, S0, S1;
        mux g1(N2, S0, D3, D2);
        mux g2(N3, S0, D1, D0);
        mux g3(N1, S1, N2, N3);
        not g4(Y, N1);
        // SPECIFY BLOCK
        specify
                specparam S1_01_LH_Y = 0, S1_01_HL_Y = 0 ;
                specparam S1_10_LH_Y = 0, S1_10_HL_Y = 0 ;
                specparam S0_01_LH_Y = 0, S0_01_HL_Y = 0 ;
                specparam S0_10_LH_Y = 0, S0_10_HL_Y = 0 ;
                specparam D3_LH_Y = 0, D3_HL_Y = 0 ;
                specparam D2_LH_Y = 0, D2_HL_Y = 0 ;
                specparam D1_LH_Y = 0, D1_HL_Y = 0 ;
                specparam D0_LH_Y = 0, D0_HL_Y = 0 ;
                (posedge S1 *> (Y : 1'b1)) = (S1_01_LH_Y, S1_01_HL_Y) ;
                (negedge S1 *> (Y : 1'b1)) = (S1_10_LH_Y, S1_10_HL_Y) ;
                (posedge S0 *> (Y : 1'b1)) = (S0_01_LH_Y, S0_01_HL_Y) ;
                (negedge S0 *> (Y : 1'b1)) = (S0_10_LH_Y, S0_10_HL_Y) ;
                (D3 *> Y) = (D3_LH_Y, D3_HL_Y) ;
                (D2 *> Y) = (D2_LH_Y, D2_HL_Y) ;
                (D1 *> Y) = (D1_LH_Y, D1_HL_Y) ;
                (D0 *> Y) = (D0_LH_Y, D0_HL_Y) ;
        endspecify
endmodule

module mx4e2(Y, D0, D1, D2, D3, S0, S1);
        output Y;
        input  D0, D1, D2, D3, S0, S1;
        mux g1(N2, S0, D3, D2);
        mux g2(N3, S0, D1, D0);
        mux g3(N1, S1, N2, N3);
        not g4(Y, N1);
        // SPECIFY BLOCK
        specify
                specparam S1_01_LH_Y = 0, S1_01_HL_Y = 0 ;
                specparam S1_10_LH_Y = 0, S1_10_HL_Y = 0 ;
                specparam S0_01_LH_Y = 0, S0_01_HL_Y = 0 ;
                specparam S0_10_LH_Y = 0, S0_10_HL_Y = 0 ;
                specparam D3_LH_Y = 0, D3_HL_Y = 0 ;
                specparam D2_LH_Y = 0, D2_HL_Y = 0 ;
                specparam D1_LH_Y = 0, D1_HL_Y = 0 ;
                specparam D0_LH_Y = 0, D0_HL_Y = 0 ;
                (posedge S1 *> (Y : 1'b1)) = (S1_01_LH_Y, S1_01_HL_Y) ;
                (negedge S1 *> (Y : 1'b1)) = (S1_10_LH_Y, S1_10_HL_Y) ;
                (posedge S0 *> (Y : 1'b1)) = (S0_01_LH_Y, S0_01_HL_Y) ;
                (negedge S0 *> (Y : 1'b1)) = (S0_10_LH_Y, S0_10_HL_Y) ;
                (D3 *> Y) = (D3_LH_Y, D3_HL_Y) ;
                (D2 *> Y) = (D2_LH_Y, D2_HL_Y) ;
                (D1 *> Y) = (D1_LH_Y, D1_HL_Y) ;
                (D0 *> Y) = (D0_LH_Y, D0_HL_Y) ;
        endspecify
endmodule

module mx4e3(Y, D0, D1, D2, D3, S0, S1);
        output Y;
        input  D0, D1, D2, D3, S0, S1;
        mux g1(N2, S0, D3, D2);
        mux g2(N3, S0, D1, D0);
        mux g3(N1, S1, N2, N3);
        not g4(Y, N1);
        // SPECIFY BLOCK
        specify
                specparam S1_01_LH_Y = 0, S1_01_HL_Y = 0 ;
                specparam S1_10_LH_Y = 0, S1_10_HL_Y = 0 ;
                specparam S0_01_LH_Y = 0, S0_01_HL_Y = 0 ;
                specparam S0_10_LH_Y = 0, S0_10_HL_Y = 0 ;
                specparam D3_LH_Y = 0, D3_HL_Y = 0 ;
                specparam D2_LH_Y = 0, D2_HL_Y = 0 ;
                specparam D1_LH_Y = 0, D1_HL_Y = 0 ;
                specparam D0_LH_Y = 0, D0_HL_Y = 0 ;
                (posedge S1 *> (Y : 1'b1)) = (S1_01_LH_Y, S1_01_HL_Y) ;
                (negedge S1 *> (Y : 1'b1)) = (S1_10_LH_Y, S1_10_HL_Y) ;
                (posedge S0 *> (Y : 1'b1)) = (S0_01_LH_Y, S0_01_HL_Y) ;
                (negedge S0 *> (Y : 1'b1)) = (S0_10_LH_Y, S0_10_HL_Y) ;
                (D3 *> Y) = (D3_LH_Y, D3_HL_Y) ;
                (D2 *> Y) = (D2_LH_Y, D2_HL_Y) ;
                (D1 *> Y) = (D1_LH_Y, D1_HL_Y) ;
                (D0 *> Y) = (D0_LH_Y, D0_HL_Y) ;
        endspecify
endmodule

module mx4e6(Y, D0, D1, D2, D3, S0, S1);
        output Y;
        input  D0, D1, D2, D3, S0, S1;
        mux g1(N2, S0, D3, D2);
        mux g2(N3, S0, D1, D0);
        mux g3(N1, S1, N2, N3);
        not g4(Y, N1);
        // SPECIFY BLOCK
        specify
                specparam S1_01_LH_Y = 0, S1_01_HL_Y = 0 ;
                specparam S1_10_LH_Y = 0, S1_10_HL_Y = 0 ;
                specparam S0_01_LH_Y = 0, S0_01_HL_Y = 0 ;
                specparam S0_10_LH_Y = 0, S0_10_HL_Y = 0 ;
                specparam D3_LH_Y = 0, D3_HL_Y = 0 ;
                specparam D2_LH_Y = 0, D2_HL_Y = 0 ;
                specparam D1_LH_Y = 0, D1_HL_Y = 0 ;
                specparam D0_LH_Y = 0, D0_HL_Y = 0 ;
                (posedge S1 *> (Y : 1'b1)) = (S1_01_LH_Y, S1_01_HL_Y) ;
                (negedge S1 *> (Y : 1'b1)) = (S1_10_LH_Y, S1_10_HL_Y) ;
                (posedge S0 *> (Y : 1'b1)) = (S0_01_LH_Y, S0_01_HL_Y) ;
                (negedge S0 *> (Y : 1'b1)) = (S0_10_LH_Y, S0_10_HL_Y) ;
                (D3 *> Y) = (D3_LH_Y, D3_HL_Y) ;
                (D2 *> Y) = (D2_LH_Y, D2_HL_Y) ;
                (D1 *> Y) = (D1_LH_Y, D1_HL_Y) ;
                (D0 *> Y) = (D0_LH_Y, D0_HL_Y) ;
        endspecify
endmodule

module mx4e9(Y, D0, D1, D2, D3, S0, S1);
        output Y;
        input  D0, D1, D2, D3, S0, S1;
        mux g1(N2, S0, D3, D2);
        mux g2(N3, S0, D1, D0);
        mux g3(N1, S1, N2, N3);
        not g4(Y, N1);
        // SPECIFY BLOCK
        specify
                specparam S1_01_LH_Y = 0, S1_01_HL_Y = 0 ;
                specparam S1_10_LH_Y = 0, S1_10_HL_Y = 0 ;
                specparam S0_01_LH_Y = 0, S0_01_HL_Y = 0 ;
                specparam S0_10_LH_Y = 0, S0_10_HL_Y = 0 ;
                specparam D3_LH_Y = 0, D3_HL_Y = 0 ;
                specparam D2_LH_Y = 0, D2_HL_Y = 0 ;
                specparam D1_LH_Y = 0, D1_HL_Y = 0 ;
                specparam D0_LH_Y = 0, D0_HL_Y = 0 ;
                (posedge S1 *> (Y : 1'b1)) = (S1_01_LH_Y, S1_01_HL_Y) ;
                (negedge S1 *> (Y : 1'b1)) = (S1_10_LH_Y, S1_10_HL_Y) ;
                (posedge S0 *> (Y : 1'b1)) = (S0_01_LH_Y, S0_01_HL_Y) ;
                (negedge S0 *> (Y : 1'b1)) = (S0_10_LH_Y, S0_10_HL_Y) ;
                (D3 *> Y) = (D3_LH_Y, D3_HL_Y) ;
                (D2 *> Y) = (D2_LH_Y, D2_HL_Y) ;
                (D1 *> Y) = (D1_LH_Y, D1_HL_Y) ;
                (D0 *> Y) = (D0_LH_Y, D0_HL_Y) ;
        endspecify
endmodule

module oa1a1(Y, A, B, C);
        output Y;
        input  A, B, C;
        or g1(N1, A, B);
        and g2(Y, N1, C);
        // SPECIFY BLOCK
        specify
                specparam A_LH_Y = 0, A_HL_Y = 0 ;
                specparam B_LH_Y = 0, B_HL_Y = 0 ;
                specparam C_LH_Y = 0, C_HL_Y = 0 ;
                (A *> Y) = (A_LH_Y, A_HL_Y) ;
                (B *> Y) = (B_LH_Y, B_HL_Y) ;
                (C *> Y) = (C_LH_Y, C_HL_Y) ;
        endspecify
endmodule

module oa1a15(Y, A, B, C);
        output Y;
        input  A, B, C;
        or g1(N1, A, B);
        and g2(Y, N1, C);
        // SPECIFY BLOCK
        specify
                specparam A_LH_Y = 0, A_HL_Y = 0 ;
                specparam B_LH_Y = 0, B_HL_Y = 0 ;
                specparam C_LH_Y = 0, C_HL_Y = 0 ;
                (A *> Y) = (A_LH_Y, A_HL_Y) ;
                (B *> Y) = (B_LH_Y, B_HL_Y) ;
                (C *> Y) = (C_LH_Y, C_HL_Y) ;
        endspecify
endmodule

module oa1a2(Y, A, B, C);
        output Y;
        input  A, B, C;
        or g1(N1, A, B);
        and g2(Y, N1, C);
        // SPECIFY BLOCK
        specify
                specparam A_LH_Y = 0, A_HL_Y = 0 ;
                specparam B_LH_Y = 0, B_HL_Y = 0 ;
                specparam C_LH_Y = 0, C_HL_Y = 0 ;
                (A *> Y) = (A_LH_Y, A_HL_Y) ;
                (B *> Y) = (B_LH_Y, B_HL_Y) ;
                (C *> Y) = (C_LH_Y, C_HL_Y) ;
        endspecify
endmodule

module oa1a3(Y, A, B, C);
        output Y;
        input  A, B, C;
        or g1(N1, A, B);
        and g2(Y, N1, C);
        // SPECIFY BLOCK
        specify
                specparam A_LH_Y = 0, A_HL_Y = 0 ;
                specparam B_LH_Y = 0, B_HL_Y = 0 ;
                specparam C_LH_Y = 0, C_HL_Y = 0 ;
                (A *> Y) = (A_LH_Y, A_HL_Y) ;
                (B *> Y) = (B_LH_Y, B_HL_Y) ;
                (C *> Y) = (C_LH_Y, C_HL_Y) ;
        endspecify
endmodule

module oa1a6(Y, A, B, C);
        output Y;
        input  A, B, C;
        or g1(N1, A, B);
        and g2(Y, N1, C);
        // SPECIFY BLOCK
        specify
                specparam A_LH_Y = 0, A_HL_Y = 0 ;
                specparam B_LH_Y = 0, B_HL_Y = 0 ;
                specparam C_LH_Y = 0, C_HL_Y = 0 ;
                (A *> Y) = (A_LH_Y, A_HL_Y) ;
                (B *> Y) = (B_LH_Y, B_HL_Y) ;
                (C *> Y) = (C_LH_Y, C_HL_Y) ;
        endspecify
endmodule

module oa1a9(Y, A, B, C);
        output Y;
        input  A, B, C;
        or g1(N1, A, B);
        and g2(Y, N1, C);
        // SPECIFY BLOCK
        specify
                specparam A_LH_Y = 0, A_HL_Y = 0 ;
                specparam B_LH_Y = 0, B_HL_Y = 0 ;
                specparam C_LH_Y = 0, C_HL_Y = 0 ;
                (A *> Y) = (A_LH_Y, A_HL_Y) ;
                (B *> Y) = (B_LH_Y, B_HL_Y) ;
                (C *> Y) = (C_LH_Y, C_HL_Y) ;
        endspecify
endmodule

module oa1b1(Y, A, B, C);
        output Y;
        input  A, B, C;
        not g1(N2, A);
        or g2(N1, N2, B);
        and g3(Y, N1, C);
        // SPECIFY BLOCK
        specify
                specparam A_LH_Y = 0, A_HL_Y = 0 ;
                specparam B_LH_Y = 0, B_HL_Y = 0 ;
                specparam C_LH_Y = 0, C_HL_Y = 0 ;
                (A *> Y) = (A_LH_Y, A_HL_Y) ;
                (B *> Y) = (B_LH_Y, B_HL_Y) ;
                (C *> Y) = (C_LH_Y, C_HL_Y) ;
        endspecify
endmodule

module oa1b15(Y, A, B, C);
        output Y;
        input  A, B, C;
        not g1(N2, A);
        or g2(N1, N2, B);
        and g3(Y, N1, C);
        // SPECIFY BLOCK
        specify
                specparam A_LH_Y = 0, A_HL_Y = 0 ;
                specparam B_LH_Y = 0, B_HL_Y = 0 ;
                specparam C_LH_Y = 0, C_HL_Y = 0 ;
                (A *> Y) = (A_LH_Y, A_HL_Y) ;
                (B *> Y) = (B_LH_Y, B_HL_Y) ;
                (C *> Y) = (C_LH_Y, C_HL_Y) ;
        endspecify
endmodule

module oa1b2(Y, A, B, C);
        output Y;
        input  A, B, C;
        not g1(N2, A);
        or g2(N1, N2, B);
        and g3(Y, N1, C);
        // SPECIFY BLOCK
        specify
                specparam A_LH_Y = 0, A_HL_Y = 0 ;
                specparam B_LH_Y = 0, B_HL_Y = 0 ;
                specparam C_LH_Y = 0, C_HL_Y = 0 ;
                (A *> Y) = (A_LH_Y, A_HL_Y) ;
                (B *> Y) = (B_LH_Y, B_HL_Y) ;
                (C *> Y) = (C_LH_Y, C_HL_Y) ;
        endspecify
endmodule

module oa1b3(Y, A, B, C);
        output Y;
        input  A, B, C;
        not g1(N2, A);
        or g2(N1, N2, B);
        and g3(Y, N1, C);
        // SPECIFY BLOCK
        specify
                specparam A_LH_Y = 0, A_HL_Y = 0 ;
                specparam B_LH_Y = 0, B_HL_Y = 0 ;
                specparam C_LH_Y = 0, C_HL_Y = 0 ;
                (A *> Y) = (A_LH_Y, A_HL_Y) ;
                (B *> Y) = (B_LH_Y, B_HL_Y) ;
                (C *> Y) = (C_LH_Y, C_HL_Y) ;
        endspecify
endmodule

module oa1b6(Y, A, B, C);
        output Y;
        input  A, B, C;
        not g1(N2, A);
        or g2(N1, N2, B);
        and g3(Y, N1, C);
        // SPECIFY BLOCK
        specify
                specparam A_LH_Y = 0, A_HL_Y = 0 ;
                specparam B_LH_Y = 0, B_HL_Y = 0 ;
                specparam C_LH_Y = 0, C_HL_Y = 0 ;
                (A *> Y) = (A_LH_Y, A_HL_Y) ;
                (B *> Y) = (B_LH_Y, B_HL_Y) ;
                (C *> Y) = (C_LH_Y, C_HL_Y) ;
        endspecify
endmodule

module oa1b9(Y, A, B, C);
        output Y;
        input  A, B, C;
        not g1(N2, A);
        or g2(N1, N2, B);
        and g3(Y, N1, C);
        // SPECIFY BLOCK
        specify
                specparam A_LH_Y = 0, A_HL_Y = 0 ;
                specparam B_LH_Y = 0, B_HL_Y = 0 ;
                specparam C_LH_Y = 0, C_HL_Y = 0 ;
                (A *> Y) = (A_LH_Y, A_HL_Y) ;
                (B *> Y) = (B_LH_Y, B_HL_Y) ;
                (C *> Y) = (C_LH_Y, C_HL_Y) ;
        endspecify
endmodule

module oa1c1(Y, A, B, C);
        output Y;
        input  A, B, C;
        not g1(N2, A);
        not g2(N3, B);
        or g3(N1, N2, N3);
        and g4(Y, N1, C);
        // SPECIFY BLOCK
        specify
                specparam A_LH_Y = 0, A_HL_Y = 0 ;
                specparam B_LH_Y = 0, B_HL_Y = 0 ;
                specparam C_LH_Y = 0, C_HL_Y = 0 ;
                (A *> Y) = (A_LH_Y, A_HL_Y) ;
                (B *> Y) = (B_LH_Y, B_HL_Y) ;
                (C *> Y) = (C_LH_Y, C_HL_Y) ;
        endspecify
endmodule

module oa1c15(Y, A, B, C);
        output Y;
        input  A, B, C;
        not g1(N2, A);
        not g2(N3, B);
        or g3(N1, N2, N3);
        and g4(Y, N1, C);
        // SPECIFY BLOCK
        specify
                specparam A_LH_Y = 0, A_HL_Y = 0 ;
                specparam B_LH_Y = 0, B_HL_Y = 0 ;
                specparam C_LH_Y = 0, C_HL_Y = 0 ;
                (A *> Y) = (A_LH_Y, A_HL_Y) ;
                (B *> Y) = (B_LH_Y, B_HL_Y) ;
                (C *> Y) = (C_LH_Y, C_HL_Y) ;
        endspecify
endmodule

module oa1c2(Y, A, B, C);
        output Y;
        input  A, B, C;
        not g1(N2, A);
        not g2(N3, B);
        or g3(N1, N2, N3);
        and g4(Y, N1, C);
        // SPECIFY BLOCK
        specify
                specparam A_LH_Y = 0, A_HL_Y = 0 ;
                specparam B_LH_Y = 0, B_HL_Y = 0 ;
                specparam C_LH_Y = 0, C_HL_Y = 0 ;
                (A *> Y) = (A_LH_Y, A_HL_Y) ;
                (B *> Y) = (B_LH_Y, B_HL_Y) ;
                (C *> Y) = (C_LH_Y, C_HL_Y) ;
        endspecify
endmodule

module oa1c3(Y, A, B, C);
        output Y;
        input  A, B, C;
        not g1(N2, A);
        not g2(N3, B);
        or g3(N1, N2, N3);
        and g4(Y, N1, C);
        // SPECIFY BLOCK
        specify
                specparam A_LH_Y = 0, A_HL_Y = 0 ;
                specparam B_LH_Y = 0, B_HL_Y = 0 ;
                specparam C_LH_Y = 0, C_HL_Y = 0 ;
                (A *> Y) = (A_LH_Y, A_HL_Y) ;
                (B *> Y) = (B_LH_Y, B_HL_Y) ;
                (C *> Y) = (C_LH_Y, C_HL_Y) ;
        endspecify
endmodule

module oa1c6(Y, A, B, C);
        output Y;
        input  A, B, C;
        not g1(N2, A);
        not g2(N3, B);
        or g3(N1, N2, N3);
        and g4(Y, N1, C);
        // SPECIFY BLOCK
        specify
                specparam A_LH_Y = 0, A_HL_Y = 0 ;
                specparam B_LH_Y = 0, B_HL_Y = 0 ;
                specparam C_LH_Y = 0, C_HL_Y = 0 ;
                (A *> Y) = (A_LH_Y, A_HL_Y) ;
                (B *> Y) = (B_LH_Y, B_HL_Y) ;
                (C *> Y) = (C_LH_Y, C_HL_Y) ;
        endspecify
endmodule

module oa1c9(Y, A, B, C);
        output Y;
        input  A, B, C;
        not g1(N2, A);
        not g2(N3, B);
        or g3(N1, N2, N3);
        and g4(Y, N1, C);
        // SPECIFY BLOCK
        specify
                specparam A_LH_Y = 0, A_HL_Y = 0 ;
                specparam B_LH_Y = 0, B_HL_Y = 0 ;
                specparam C_LH_Y = 0, C_HL_Y = 0 ;
                (A *> Y) = (A_LH_Y, A_HL_Y) ;
                (B *> Y) = (B_LH_Y, B_HL_Y) ;
                (C *> Y) = (C_LH_Y, C_HL_Y) ;
        endspecify
endmodule

module oa1d1(Y, A, B, C);
        output Y;
        input  A, B, C;
        or g1(N1, A, B);
        not g2(N2, C);
        and g3(Y, N1, N2);
        // SPECIFY BLOCK
        specify
                specparam A_LH_Y = 0, A_HL_Y = 0 ;
                specparam B_LH_Y = 0, B_HL_Y = 0 ;
                specparam C_LH_Y = 0, C_HL_Y = 0 ;
                (A *> Y) = (A_LH_Y, A_HL_Y) ;
                (B *> Y) = (B_LH_Y, B_HL_Y) ;
                (C *> Y) = (C_LH_Y, C_HL_Y) ;
        endspecify
endmodule

module oa1d15(Y, A, B, C);
        output Y;
        input  A, B, C;
        or g1(N1, A, B);
        not g2(N2, C);
        and g3(Y, N1, N2);
        // SPECIFY BLOCK
        specify
                specparam A_LH_Y = 0, A_HL_Y = 0 ;
                specparam B_LH_Y = 0, B_HL_Y = 0 ;
                specparam C_LH_Y = 0, C_HL_Y = 0 ;
                (A *> Y) = (A_LH_Y, A_HL_Y) ;
                (B *> Y) = (B_LH_Y, B_HL_Y) ;
                (C *> Y) = (C_LH_Y, C_HL_Y) ;
        endspecify
endmodule

module oa1d2(Y, A, B, C);
        output Y;
        input  A, B, C;
        or g1(N1, A, B);
        not g2(N2, C);
        and g3(Y, N1, N2);
        // SPECIFY BLOCK
        specify
                specparam A_LH_Y = 0, A_HL_Y = 0 ;
                specparam B_LH_Y = 0, B_HL_Y = 0 ;
                specparam C_LH_Y = 0, C_HL_Y = 0 ;
                (A *> Y) = (A_LH_Y, A_HL_Y) ;
                (B *> Y) = (B_LH_Y, B_HL_Y) ;
                (C *> Y) = (C_LH_Y, C_HL_Y) ;
        endspecify
endmodule

module oa1d3(Y, A, B, C);
        output Y;
        input  A, B, C;
        or g1(N1, A, B);
        not g2(N2, C);
        and g3(Y, N1, N2);
        // SPECIFY BLOCK
        specify
                specparam A_LH_Y = 0, A_HL_Y = 0 ;
                specparam B_LH_Y = 0, B_HL_Y = 0 ;
                specparam C_LH_Y = 0, C_HL_Y = 0 ;
                (A *> Y) = (A_LH_Y, A_HL_Y) ;
                (B *> Y) = (B_LH_Y, B_HL_Y) ;
                (C *> Y) = (C_LH_Y, C_HL_Y) ;
        endspecify
endmodule

module oa1d6(Y, A, B, C);
        output Y;
        input  A, B, C;
        or g1(N1, A, B);
        not g2(N2, C);
        and g3(Y, N1, N2);
        // SPECIFY BLOCK
        specify
                specparam A_LH_Y = 0, A_HL_Y = 0 ;
                specparam B_LH_Y = 0, B_HL_Y = 0 ;
                specparam C_LH_Y = 0, C_HL_Y = 0 ;
                (A *> Y) = (A_LH_Y, A_HL_Y) ;
                (B *> Y) = (B_LH_Y, B_HL_Y) ;
                (C *> Y) = (C_LH_Y, C_HL_Y) ;
        endspecify
endmodule

module oa1d9(Y, A, B, C);
        output Y;
        input  A, B, C;
        or g1(N1, A, B);
        not g2(N2, C);
        and g3(Y, N1, N2);
        // SPECIFY BLOCK
        specify
                specparam A_LH_Y = 0, A_HL_Y = 0 ;
                specparam B_LH_Y = 0, B_HL_Y = 0 ;
                specparam C_LH_Y = 0, C_HL_Y = 0 ;
                (A *> Y) = (A_LH_Y, A_HL_Y) ;
                (B *> Y) = (B_LH_Y, B_HL_Y) ;
                (C *> Y) = (C_LH_Y, C_HL_Y) ;
        endspecify
endmodule

module oa1e1(Y, A, B, C);
        output Y;
        input  A, B, C;
        not g1(N2, A);
        or g2(N1, N2, B);
        not g3(N3, C);
        and g4(Y, N1, N3);
        // SPECIFY BLOCK
        specify
                specparam A_LH_Y = 0, A_HL_Y = 0 ;
                specparam B_LH_Y = 0, B_HL_Y = 0 ;
                specparam C_LH_Y = 0, C_HL_Y = 0 ;
                (A *> Y) = (A_LH_Y, A_HL_Y) ;
                (B *> Y) = (B_LH_Y, B_HL_Y) ;
                (C *> Y) = (C_LH_Y, C_HL_Y) ;
        endspecify
endmodule

module oa1e15(Y, A, B, C);
        output Y;
        input  A, B, C;
        not g1(N2, A);
        or g2(N1, N2, B);
        not g3(N3, C);
        and g4(Y, N1, N3);
        // SPECIFY BLOCK
        specify
                specparam A_LH_Y = 0, A_HL_Y = 0 ;
                specparam B_LH_Y = 0, B_HL_Y = 0 ;
                specparam C_LH_Y = 0, C_HL_Y = 0 ;
                (A *> Y) = (A_LH_Y, A_HL_Y) ;
                (B *> Y) = (B_LH_Y, B_HL_Y) ;
                (C *> Y) = (C_LH_Y, C_HL_Y) ;
        endspecify
endmodule

module oa1e2(Y, A, B, C);
        output Y;
        input  A, B, C;
        not g1(N2, A);
        or g2(N1, N2, B);
        not g3(N3, C);
        and g4(Y, N1, N3);
        // SPECIFY BLOCK
        specify
                specparam A_LH_Y = 0, A_HL_Y = 0 ;
                specparam B_LH_Y = 0, B_HL_Y = 0 ;
                specparam C_LH_Y = 0, C_HL_Y = 0 ;
                (A *> Y) = (A_LH_Y, A_HL_Y) ;
                (B *> Y) = (B_LH_Y, B_HL_Y) ;
                (C *> Y) = (C_LH_Y, C_HL_Y) ;
        endspecify
endmodule

module oa1e3(Y, A, B, C);
        output Y;
        input  A, B, C;
        not g1(N2, A);
        or g2(N1, N2, B);
        not g3(N3, C);
        and g4(Y, N1, N3);
        // SPECIFY BLOCK
        specify
                specparam A_LH_Y = 0, A_HL_Y = 0 ;
                specparam B_LH_Y = 0, B_HL_Y = 0 ;
                specparam C_LH_Y = 0, C_HL_Y = 0 ;
                (A *> Y) = (A_LH_Y, A_HL_Y) ;
                (B *> Y) = (B_LH_Y, B_HL_Y) ;
                (C *> Y) = (C_LH_Y, C_HL_Y) ;
        endspecify
endmodule

module oa1e6(Y, A, B, C);
        output Y;
        input  A, B, C;
        not g1(N2, A);
        or g2(N1, N2, B);
        not g3(N3, C);
        and g4(Y, N1, N3);
        // SPECIFY BLOCK
        specify
                specparam A_LH_Y = 0, A_HL_Y = 0 ;
                specparam B_LH_Y = 0, B_HL_Y = 0 ;
                specparam C_LH_Y = 0, C_HL_Y = 0 ;
                (A *> Y) = (A_LH_Y, A_HL_Y) ;
                (B *> Y) = (B_LH_Y, B_HL_Y) ;
                (C *> Y) = (C_LH_Y, C_HL_Y) ;
        endspecify
endmodule

module oa1e9(Y, A, B, C);
        output Y;
        input  A, B, C;
        not g1(N2, A);
        or g2(N1, N2, B);
        not g3(N3, C);
        and g4(Y, N1, N3);
        // SPECIFY BLOCK
        specify
                specparam A_LH_Y = 0, A_HL_Y = 0 ;
                specparam B_LH_Y = 0, B_HL_Y = 0 ;
                specparam C_LH_Y = 0, C_HL_Y = 0 ;
                (A *> Y) = (A_LH_Y, A_HL_Y) ;
                (B *> Y) = (B_LH_Y, B_HL_Y) ;
                (C *> Y) = (C_LH_Y, C_HL_Y) ;
        endspecify
endmodule

module oa1f1(Y, A, B, C);
        output Y;
        input  A, B, C;
        not g1(N2, A);
        not g2(N3, B);
        or g3(N1, N2, N3);
        not g4(N4, C);
        and g5(Y, N1, N4);
        // SPECIFY BLOCK
        specify
                specparam A_LH_Y = 0, A_HL_Y = 0 ;
                specparam B_LH_Y = 0, B_HL_Y = 0 ;
                specparam C_LH_Y = 0, C_HL_Y = 0 ;
                (A *> Y) = (A_LH_Y, A_HL_Y) ;
                (B *> Y) = (B_LH_Y, B_HL_Y) ;
                (C *> Y) = (C_LH_Y, C_HL_Y) ;
        endspecify
endmodule

module oa1f15(Y, A, B, C);
        output Y;
        input  A, B, C;
        not g1(N2, A);
        not g2(N3, B);
        or g3(N1, N2, N3);
        not g4(N4, C);
        and g5(Y, N1, N4);
        // SPECIFY BLOCK
        specify
                specparam A_LH_Y = 0, A_HL_Y = 0 ;
                specparam B_LH_Y = 0, B_HL_Y = 0 ;
                specparam C_LH_Y = 0, C_HL_Y = 0 ;
                (A *> Y) = (A_LH_Y, A_HL_Y) ;
                (B *> Y) = (B_LH_Y, B_HL_Y) ;
                (C *> Y) = (C_LH_Y, C_HL_Y) ;
        endspecify
endmodule

module oa1f2(Y, A, B, C);
        output Y;
        input  A, B, C;
        not g1(N2, A);
        not g2(N3, B);
        or g3(N1, N2, N3);
        not g4(N4, C);
        and g5(Y, N1, N4);
        // SPECIFY BLOCK
        specify
                specparam A_LH_Y = 0, A_HL_Y = 0 ;
                specparam B_LH_Y = 0, B_HL_Y = 0 ;
                specparam C_LH_Y = 0, C_HL_Y = 0 ;
                (A *> Y) = (A_LH_Y, A_HL_Y) ;
                (B *> Y) = (B_LH_Y, B_HL_Y) ;
                (C *> Y) = (C_LH_Y, C_HL_Y) ;
        endspecify
endmodule

module oa1f3(Y, A, B, C);
        output Y;
        input  A, B, C;
        not g1(N2, A);
        not g2(N3, B);
        or g3(N1, N2, N3);
        not g4(N4, C);
        and g5(Y, N1, N4);
        // SPECIFY BLOCK
        specify
                specparam A_LH_Y = 0, A_HL_Y = 0 ;
                specparam B_LH_Y = 0, B_HL_Y = 0 ;
                specparam C_LH_Y = 0, C_HL_Y = 0 ;
                (A *> Y) = (A_LH_Y, A_HL_Y) ;
                (B *> Y) = (B_LH_Y, B_HL_Y) ;
                (C *> Y) = (C_LH_Y, C_HL_Y) ;
        endspecify
endmodule

module oa1f6(Y, A, B, C);
        output Y;
        input  A, B, C;
        not g1(N2, A);
        not g2(N3, B);
        or g3(N1, N2, N3);
        not g4(N4, C);
        and g5(Y, N1, N4);
        // SPECIFY BLOCK
        specify
                specparam A_LH_Y = 0, A_HL_Y = 0 ;
                specparam B_LH_Y = 0, B_HL_Y = 0 ;
                specparam C_LH_Y = 0, C_HL_Y = 0 ;
                (A *> Y) = (A_LH_Y, A_HL_Y) ;
                (B *> Y) = (B_LH_Y, B_HL_Y) ;
                (C *> Y) = (C_LH_Y, C_HL_Y) ;
        endspecify
endmodule

module oa1f9(Y, A, B, C);
        output Y;
        input  A, B, C;
        not g1(N2, A);
        not g2(N3, B);
        or g3(N1, N2, N3);
        not g4(N4, C);
        and g5(Y, N1, N4);
        // SPECIFY BLOCK
        specify
                specparam A_LH_Y = 0, A_HL_Y = 0 ;
                specparam B_LH_Y = 0, B_HL_Y = 0 ;
                specparam C_LH_Y = 0, C_HL_Y = 0 ;
                (A *> Y) = (A_LH_Y, A_HL_Y) ;
                (B *> Y) = (B_LH_Y, B_HL_Y) ;
                (C *> Y) = (C_LH_Y, C_HL_Y) ;
        endspecify
endmodule

module oa2a1(Y, A, B, C, D);
        output Y;
        input  A, B, C, D;
        or g1(N1, A, B);
        and g2(Y, C, D, N1);
        // SPECIFY BLOCK
        specify
                specparam A_LH_Y = 0, A_HL_Y = 0 ;
                specparam B_LH_Y = 0, B_HL_Y = 0 ;
                specparam C_LH_Y = 0, C_HL_Y = 0 ;
                specparam D_LH_Y = 0, D_HL_Y = 0 ;
                (A *> Y) = (A_LH_Y, A_HL_Y) ;
                (B *> Y) = (B_LH_Y, B_HL_Y) ;
                (C *> Y) = (C_LH_Y, C_HL_Y) ;
                (D *> Y) = (D_LH_Y, D_HL_Y) ;
        endspecify
endmodule

module oa2a15(Y, A, B, C, D);
        output Y;
        input  A, B, C, D;
        or g1(N1, A, B);
        and g2(Y, C, D, N1);
        // SPECIFY BLOCK
        specify
                specparam A_LH_Y = 0, A_HL_Y = 0 ;
                specparam B_LH_Y = 0, B_HL_Y = 0 ;
                specparam C_LH_Y = 0, C_HL_Y = 0 ;
                specparam D_LH_Y = 0, D_HL_Y = 0 ;
                (A *> Y) = (A_LH_Y, A_HL_Y) ;
                (B *> Y) = (B_LH_Y, B_HL_Y) ;
                (C *> Y) = (C_LH_Y, C_HL_Y) ;
                (D *> Y) = (D_LH_Y, D_HL_Y) ;
        endspecify
endmodule

module oa2a2(Y, A, B, C, D);
        output Y;
        input  A, B, C, D;
        or g1(N1, A, B);
        and g2(Y, C, D, N1);
        // SPECIFY BLOCK
        specify
                specparam A_LH_Y = 0, A_HL_Y = 0 ;
                specparam B_LH_Y = 0, B_HL_Y = 0 ;
                specparam C_LH_Y = 0, C_HL_Y = 0 ;
                specparam D_LH_Y = 0, D_HL_Y = 0 ;
                (A *> Y) = (A_LH_Y, A_HL_Y) ;
                (B *> Y) = (B_LH_Y, B_HL_Y) ;
                (C *> Y) = (C_LH_Y, C_HL_Y) ;
                (D *> Y) = (D_LH_Y, D_HL_Y) ;
        endspecify
endmodule

module oa2a3(Y, A, B, C, D);
        output Y;
        input  A, B, C, D;
        or g1(N1, A, B);
        and g2(Y, C, D, N1);
        // SPECIFY BLOCK
        specify
                specparam A_LH_Y = 0, A_HL_Y = 0 ;
                specparam B_LH_Y = 0, B_HL_Y = 0 ;
                specparam C_LH_Y = 0, C_HL_Y = 0 ;
                specparam D_LH_Y = 0, D_HL_Y = 0 ;
                (A *> Y) = (A_LH_Y, A_HL_Y) ;
                (B *> Y) = (B_LH_Y, B_HL_Y) ;
                (C *> Y) = (C_LH_Y, C_HL_Y) ;
                (D *> Y) = (D_LH_Y, D_HL_Y) ;
        endspecify
endmodule

module oa2a6(Y, A, B, C, D);
        output Y;
        input  A, B, C, D;
        or g1(N1, A, B);
        and g2(Y, C, D, N1);
        // SPECIFY BLOCK
        specify
                specparam A_LH_Y = 0, A_HL_Y = 0 ;
                specparam B_LH_Y = 0, B_HL_Y = 0 ;
                specparam C_LH_Y = 0, C_HL_Y = 0 ;
                specparam D_LH_Y = 0, D_HL_Y = 0 ;
                (A *> Y) = (A_LH_Y, A_HL_Y) ;
                (B *> Y) = (B_LH_Y, B_HL_Y) ;
                (C *> Y) = (C_LH_Y, C_HL_Y) ;
                (D *> Y) = (D_LH_Y, D_HL_Y) ;
        endspecify
endmodule

module oa2a9(Y, A, B, C, D);
        output Y;
        input  A, B, C, D;
        or g1(N1, A, B);
        and g2(Y, C, D, N1);
        // SPECIFY BLOCK
        specify
                specparam A_LH_Y = 0, A_HL_Y = 0 ;
                specparam B_LH_Y = 0, B_HL_Y = 0 ;
                specparam C_LH_Y = 0, C_HL_Y = 0 ;
                specparam D_LH_Y = 0, D_HL_Y = 0 ;
                (A *> Y) = (A_LH_Y, A_HL_Y) ;
                (B *> Y) = (B_LH_Y, B_HL_Y) ;
                (C *> Y) = (C_LH_Y, C_HL_Y) ;
                (D *> Y) = (D_LH_Y, D_HL_Y) ;
        endspecify
endmodule

module oa2c1(Y, A, B, C, D);
        output Y;
        input  A, B, C, D;
        not g1(N2, A);
        not g2(N3, B);
        or g3(N1, N2, N3);
        and g4(Y, C, D, N1);
        // SPECIFY BLOCK
        specify
                specparam A_LH_Y = 0, A_HL_Y = 0 ;
                specparam B_LH_Y = 0, B_HL_Y = 0 ;
                specparam C_LH_Y = 0, C_HL_Y = 0 ;
                specparam D_LH_Y = 0, D_HL_Y = 0 ;
                (A *> Y) = (A_LH_Y, A_HL_Y) ;
                (B *> Y) = (B_LH_Y, B_HL_Y) ;
                (C *> Y) = (C_LH_Y, C_HL_Y) ;
                (D *> Y) = (D_LH_Y, D_HL_Y) ;
        endspecify
endmodule

module oa2c15(Y, A, B, C, D);
        output Y;
        input  A, B, C, D;
        not g1(N2, A);
        not g2(N3, B);
        or g3(N1, N2, N3);
        and g4(Y, C, D, N1);
        // SPECIFY BLOCK
        specify
                specparam A_LH_Y = 0, A_HL_Y = 0 ;
                specparam B_LH_Y = 0, B_HL_Y = 0 ;
                specparam C_LH_Y = 0, C_HL_Y = 0 ;
                specparam D_LH_Y = 0, D_HL_Y = 0 ;
                (A *> Y) = (A_LH_Y, A_HL_Y) ;
                (B *> Y) = (B_LH_Y, B_HL_Y) ;
                (C *> Y) = (C_LH_Y, C_HL_Y) ;
                (D *> Y) = (D_LH_Y, D_HL_Y) ;
        endspecify
endmodule

module oa2c2(Y, A, B, C, D);
        output Y;
        input  A, B, C, D;
        not g1(N2, A);
        not g2(N3, B);
        or g3(N1, N2, N3);
        and g4(Y, C, D, N1);
        // SPECIFY BLOCK
        specify
                specparam A_LH_Y = 0, A_HL_Y = 0 ;
                specparam B_LH_Y = 0, B_HL_Y = 0 ;
                specparam C_LH_Y = 0, C_HL_Y = 0 ;
                specparam D_LH_Y = 0, D_HL_Y = 0 ;
                (A *> Y) = (A_LH_Y, A_HL_Y) ;
                (B *> Y) = (B_LH_Y, B_HL_Y) ;
                (C *> Y) = (C_LH_Y, C_HL_Y) ;
                (D *> Y) = (D_LH_Y, D_HL_Y) ;
        endspecify
endmodule

module oa2c3(Y, A, B, C, D);
        output Y;
        input  A, B, C, D;
        not g1(N2, A);
        not g2(N3, B);
        or g3(N1, N2, N3);
        and g4(Y, C, D, N1);
        // SPECIFY BLOCK
        specify
                specparam A_LH_Y = 0, A_HL_Y = 0 ;
                specparam B_LH_Y = 0, B_HL_Y = 0 ;
                specparam C_LH_Y = 0, C_HL_Y = 0 ;
                specparam D_LH_Y = 0, D_HL_Y = 0 ;
                (A *> Y) = (A_LH_Y, A_HL_Y) ;
                (B *> Y) = (B_LH_Y, B_HL_Y) ;
                (C *> Y) = (C_LH_Y, C_HL_Y) ;
                (D *> Y) = (D_LH_Y, D_HL_Y) ;
        endspecify
endmodule

module oa2c6(Y, A, B, C, D);
        output Y;
        input  A, B, C, D;
        not g1(N2, A);
        not g2(N3, B);
        or g3(N1, N2, N3);
        and g4(Y, C, D, N1);
        // SPECIFY BLOCK
        specify
                specparam A_LH_Y = 0, A_HL_Y = 0 ;
                specparam B_LH_Y = 0, B_HL_Y = 0 ;
                specparam C_LH_Y = 0, C_HL_Y = 0 ;
                specparam D_LH_Y = 0, D_HL_Y = 0 ;
                (A *> Y) = (A_LH_Y, A_HL_Y) ;
                (B *> Y) = (B_LH_Y, B_HL_Y) ;
                (C *> Y) = (C_LH_Y, C_HL_Y) ;
                (D *> Y) = (D_LH_Y, D_HL_Y) ;
        endspecify
endmodule

module oa2c9(Y, A, B, C, D);
        output Y;
        input  A, B, C, D;
        not g1(N2, A);
        not g2(N3, B);
        or g3(N1, N2, N3);
        and g4(Y, C, D, N1);
        // SPECIFY BLOCK
        specify
                specparam A_LH_Y = 0, A_HL_Y = 0 ;
                specparam B_LH_Y = 0, B_HL_Y = 0 ;
                specparam C_LH_Y = 0, C_HL_Y = 0 ;
                specparam D_LH_Y = 0, D_HL_Y = 0 ;
                (A *> Y) = (A_LH_Y, A_HL_Y) ;
                (B *> Y) = (B_LH_Y, B_HL_Y) ;
                (C *> Y) = (C_LH_Y, C_HL_Y) ;
                (D *> Y) = (D_LH_Y, D_HL_Y) ;
        endspecify
endmodule

module oa2i1(Y, A, B, C, D);
        output Y;
        input  A, B, C, D;
        not g1(N1, C);
        not g2(N2, D);
        not g3(N4, A);
        not g4(N5, B);
        or g5(N3, N4, N5);
        and g6(Y, N1, N2, N3);
        // SPECIFY BLOCK
        specify
                specparam A_LH_Y = 0, A_HL_Y = 0 ;
                specparam B_LH_Y = 0, B_HL_Y = 0 ;
                specparam C_LH_Y = 0, C_HL_Y = 0 ;
                specparam D_LH_Y = 0, D_HL_Y = 0 ;
                (A *> Y) = (A_LH_Y, A_HL_Y) ;
                (B *> Y) = (B_LH_Y, B_HL_Y) ;
                (C *> Y) = (C_LH_Y, C_HL_Y) ;
                (D *> Y) = (D_LH_Y, D_HL_Y) ;
        endspecify
endmodule

module oa2i15(Y, A, B, C, D);
        output Y;
        input  A, B, C, D;
        not g1(N1, C);
        not g2(N2, D);
        not g3(N4, A);
        not g4(N5, B);
        or g5(N3, N4, N5);
        and g6(Y, N1, N2, N3);
        // SPECIFY BLOCK
        specify
                specparam A_LH_Y = 0, A_HL_Y = 0 ;
                specparam B_LH_Y = 0, B_HL_Y = 0 ;
                specparam C_LH_Y = 0, C_HL_Y = 0 ;
                specparam D_LH_Y = 0, D_HL_Y = 0 ;
                (A *> Y) = (A_LH_Y, A_HL_Y) ;
                (B *> Y) = (B_LH_Y, B_HL_Y) ;
                (C *> Y) = (C_LH_Y, C_HL_Y) ;
                (D *> Y) = (D_LH_Y, D_HL_Y) ;
        endspecify
endmodule

module oa2i2(Y, A, B, C, D);
        output Y;
        input  A, B, C, D;
        not g1(N1, C);
        not g2(N2, D);
        not g3(N4, A);
        not g4(N5, B);
        or g5(N3, N4, N5);
        and g6(Y, N1, N2, N3);
        // SPECIFY BLOCK
        specify
                specparam A_LH_Y = 0, A_HL_Y = 0 ;
                specparam B_LH_Y = 0, B_HL_Y = 0 ;
                specparam C_LH_Y = 0, C_HL_Y = 0 ;
                specparam D_LH_Y = 0, D_HL_Y = 0 ;
                (A *> Y) = (A_LH_Y, A_HL_Y) ;
                (B *> Y) = (B_LH_Y, B_HL_Y) ;
                (C *> Y) = (C_LH_Y, C_HL_Y) ;
                (D *> Y) = (D_LH_Y, D_HL_Y) ;
        endspecify
endmodule

module oa2i3(Y, A, B, C, D);
        output Y;
        input  A, B, C, D;
        not g1(N1, C);
        not g2(N2, D);
        not g3(N4, A);
        not g4(N5, B);
        or g5(N3, N4, N5);
        and g6(Y, N1, N2, N3);
        // SPECIFY BLOCK
        specify
                specparam A_LH_Y = 0, A_HL_Y = 0 ;
                specparam B_LH_Y = 0, B_HL_Y = 0 ;
                specparam C_LH_Y = 0, C_HL_Y = 0 ;
                specparam D_LH_Y = 0, D_HL_Y = 0 ;
                (A *> Y) = (A_LH_Y, A_HL_Y) ;
                (B *> Y) = (B_LH_Y, B_HL_Y) ;
                (C *> Y) = (C_LH_Y, C_HL_Y) ;
                (D *> Y) = (D_LH_Y, D_HL_Y) ;
        endspecify
endmodule

module oa2i6(Y, A, B, C, D);
        output Y;
        input  A, B, C, D;
        not g1(N1, C);
        not g2(N2, D);
        not g3(N4, A);
        not g4(N5, B);
        or g5(N3, N4, N5);
        and g6(Y, N1, N2, N3);
        // SPECIFY BLOCK
        specify
                specparam A_LH_Y = 0, A_HL_Y = 0 ;
                specparam B_LH_Y = 0, B_HL_Y = 0 ;
                specparam C_LH_Y = 0, C_HL_Y = 0 ;
                specparam D_LH_Y = 0, D_HL_Y = 0 ;
                (A *> Y) = (A_LH_Y, A_HL_Y) ;
                (B *> Y) = (B_LH_Y, B_HL_Y) ;
                (C *> Y) = (C_LH_Y, C_HL_Y) ;
                (D *> Y) = (D_LH_Y, D_HL_Y) ;
        endspecify
endmodule

module oa2i9(Y, A, B, C, D);
        output Y;
        input  A, B, C, D;
        not g1(N1, C);
        not g2(N2, D);
        not g3(N4, A);
        not g4(N5, B);
        or g5(N3, N4, N5);
        and g6(Y, N1, N2, N3);
        // SPECIFY BLOCK
        specify
                specparam A_LH_Y = 0, A_HL_Y = 0 ;
                specparam B_LH_Y = 0, B_HL_Y = 0 ;
                specparam C_LH_Y = 0, C_HL_Y = 0 ;
                specparam D_LH_Y = 0, D_HL_Y = 0 ;
                (A *> Y) = (A_LH_Y, A_HL_Y) ;
                (B *> Y) = (B_LH_Y, B_HL_Y) ;
                (C *> Y) = (C_LH_Y, C_HL_Y) ;
                (D *> Y) = (D_LH_Y, D_HL_Y) ;
        endspecify
endmodule

module oa4a1(Y, A, B, C, D);
        output Y;
        input  A, B, C, D;
        or g1(N1, A, B);
        or g2(N2, C, D);
        and g3(Y, N1, N2);
        // SPECIFY BLOCK
        specify
                specparam A_LH_Y = 0, A_HL_Y = 0 ;
                specparam B_LH_Y = 0, B_HL_Y = 0 ;
                specparam C_LH_Y = 0, C_HL_Y = 0 ;
                specparam D_LH_Y = 0, D_HL_Y = 0 ;
                (A *> Y) = (A_LH_Y, A_HL_Y) ;
                (B *> Y) = (B_LH_Y, B_HL_Y) ;
                (C *> Y) = (C_LH_Y, C_HL_Y) ;
                (D *> Y) = (D_LH_Y, D_HL_Y) ;
        endspecify
endmodule

module oa4a15(Y, A, B, C, D);
        output Y;
        input  A, B, C, D;
        or g1(N1, A, B);
        or g2(N2, C, D);
        and g3(Y, N1, N2);
        // SPECIFY BLOCK
        specify
                specparam A_LH_Y = 0, A_HL_Y = 0 ;
                specparam B_LH_Y = 0, B_HL_Y = 0 ;
                specparam C_LH_Y = 0, C_HL_Y = 0 ;
                specparam D_LH_Y = 0, D_HL_Y = 0 ;
                (A *> Y) = (A_LH_Y, A_HL_Y) ;
                (B *> Y) = (B_LH_Y, B_HL_Y) ;
                (C *> Y) = (C_LH_Y, C_HL_Y) ;
                (D *> Y) = (D_LH_Y, D_HL_Y) ;
        endspecify
endmodule

module oa4a2(Y, A, B, C, D);
        output Y;
        input  A, B, C, D;
        or g1(N1, A, B);
        or g2(N2, C, D);
        and g3(Y, N1, N2);
        // SPECIFY BLOCK
        specify
                specparam A_LH_Y = 0, A_HL_Y = 0 ;
                specparam B_LH_Y = 0, B_HL_Y = 0 ;
                specparam C_LH_Y = 0, C_HL_Y = 0 ;
                specparam D_LH_Y = 0, D_HL_Y = 0 ;
                (A *> Y) = (A_LH_Y, A_HL_Y) ;
                (B *> Y) = (B_LH_Y, B_HL_Y) ;
                (C *> Y) = (C_LH_Y, C_HL_Y) ;
                (D *> Y) = (D_LH_Y, D_HL_Y) ;
        endspecify
endmodule

module oa4a3(Y, A, B, C, D);
        output Y;
        input  A, B, C, D;
        or g1(N1, A, B);
        or g2(N2, C, D);
        and g3(Y, N1, N2);
        // SPECIFY BLOCK
        specify
                specparam A_LH_Y = 0, A_HL_Y = 0 ;
                specparam B_LH_Y = 0, B_HL_Y = 0 ;
                specparam C_LH_Y = 0, C_HL_Y = 0 ;
                specparam D_LH_Y = 0, D_HL_Y = 0 ;
                (A *> Y) = (A_LH_Y, A_HL_Y) ;
                (B *> Y) = (B_LH_Y, B_HL_Y) ;
                (C *> Y) = (C_LH_Y, C_HL_Y) ;
                (D *> Y) = (D_LH_Y, D_HL_Y) ;
        endspecify
endmodule

module oa4a6(Y, A, B, C, D);
        output Y;
        input  A, B, C, D;
        or g1(N1, A, B);
        or g2(N2, C, D);
        and g3(Y, N1, N2);
        // SPECIFY BLOCK
        specify
                specparam A_LH_Y = 0, A_HL_Y = 0 ;
                specparam B_LH_Y = 0, B_HL_Y = 0 ;
                specparam C_LH_Y = 0, C_HL_Y = 0 ;
                specparam D_LH_Y = 0, D_HL_Y = 0 ;
                (A *> Y) = (A_LH_Y, A_HL_Y) ;
                (B *> Y) = (B_LH_Y, B_HL_Y) ;
                (C *> Y) = (C_LH_Y, C_HL_Y) ;
                (D *> Y) = (D_LH_Y, D_HL_Y) ;
        endspecify
endmodule

module oa4a9(Y, A, B, C, D);
        output Y;
        input  A, B, C, D;
        or g1(N1, A, B);
        or g2(N2, C, D);
        and g3(Y, N1, N2);
        // SPECIFY BLOCK
        specify
                specparam A_LH_Y = 0, A_HL_Y = 0 ;
                specparam B_LH_Y = 0, B_HL_Y = 0 ;
                specparam C_LH_Y = 0, C_HL_Y = 0 ;
                specparam D_LH_Y = 0, D_HL_Y = 0 ;
                (A *> Y) = (A_LH_Y, A_HL_Y) ;
                (B *> Y) = (B_LH_Y, B_HL_Y) ;
                (C *> Y) = (C_LH_Y, C_HL_Y) ;
                (D *> Y) = (D_LH_Y, D_HL_Y) ;
        endspecify
endmodule

module oa4b1(Y, A, B, C, D);
        output Y;
        input  A, B, C, D;
        not g1(N2, A);
        or g2(N1, N2, B);
        or g3(N3, C, D);
        and g4(Y, N1, N3);
        // SPECIFY BLOCK
        specify
                specparam A_LH_Y = 0, A_HL_Y = 0 ;
                specparam B_LH_Y = 0, B_HL_Y = 0 ;
                specparam C_LH_Y = 0, C_HL_Y = 0 ;
                specparam D_LH_Y = 0, D_HL_Y = 0 ;
                (A *> Y) = (A_LH_Y, A_HL_Y) ;
                (B *> Y) = (B_LH_Y, B_HL_Y) ;
                (C *> Y) = (C_LH_Y, C_HL_Y) ;
                (D *> Y) = (D_LH_Y, D_HL_Y) ;
        endspecify
endmodule

module oa4b15(Y, A, B, C, D);
        output Y;
        input  A, B, C, D;
        not g1(N2, A);
        or g2(N1, N2, B);
        or g3(N3, C, D);
        and g4(Y, N1, N3);
        // SPECIFY BLOCK
        specify
                specparam A_LH_Y = 0, A_HL_Y = 0 ;
                specparam B_LH_Y = 0, B_HL_Y = 0 ;
                specparam C_LH_Y = 0, C_HL_Y = 0 ;
                specparam D_LH_Y = 0, D_HL_Y = 0 ;
                (A *> Y) = (A_LH_Y, A_HL_Y) ;
                (B *> Y) = (B_LH_Y, B_HL_Y) ;
                (C *> Y) = (C_LH_Y, C_HL_Y) ;
                (D *> Y) = (D_LH_Y, D_HL_Y) ;
        endspecify
endmodule

module oa4b2(Y, A, B, C, D);
        output Y;
        input  A, B, C, D;
        not g1(N2, A);
        or g2(N1, N2, B);
        or g3(N3, C, D);
        and g4(Y, N1, N3);
        // SPECIFY BLOCK
        specify
                specparam A_LH_Y = 0, A_HL_Y = 0 ;
                specparam B_LH_Y = 0, B_HL_Y = 0 ;
                specparam C_LH_Y = 0, C_HL_Y = 0 ;
                specparam D_LH_Y = 0, D_HL_Y = 0 ;
                (A *> Y) = (A_LH_Y, A_HL_Y) ;
                (B *> Y) = (B_LH_Y, B_HL_Y) ;
                (C *> Y) = (C_LH_Y, C_HL_Y) ;
                (D *> Y) = (D_LH_Y, D_HL_Y) ;
        endspecify
endmodule

module oa4b3(Y, A, B, C, D);
        output Y;
        input  A, B, C, D;
        not g1(N2, A);
        or g2(N1, N2, B);
        or g3(N3, C, D);
        and g4(Y, N1, N3);
        // SPECIFY BLOCK
        specify
                specparam A_LH_Y = 0, A_HL_Y = 0 ;
                specparam B_LH_Y = 0, B_HL_Y = 0 ;
                specparam C_LH_Y = 0, C_HL_Y = 0 ;
                specparam D_LH_Y = 0, D_HL_Y = 0 ;
                (A *> Y) = (A_LH_Y, A_HL_Y) ;
                (B *> Y) = (B_LH_Y, B_HL_Y) ;
                (C *> Y) = (C_LH_Y, C_HL_Y) ;
                (D *> Y) = (D_LH_Y, D_HL_Y) ;
        endspecify
endmodule

module oa4b6(Y, A, B, C, D);
        output Y;
        input  A, B, C, D;
        not g1(N2, A);
        or g2(N1, N2, B);
        or g3(N3, C, D);
        and g4(Y, N1, N3);
        // SPECIFY BLOCK
        specify
                specparam A_LH_Y = 0, A_HL_Y = 0 ;
                specparam B_LH_Y = 0, B_HL_Y = 0 ;
                specparam C_LH_Y = 0, C_HL_Y = 0 ;
                specparam D_LH_Y = 0, D_HL_Y = 0 ;
                (A *> Y) = (A_LH_Y, A_HL_Y) ;
                (B *> Y) = (B_LH_Y, B_HL_Y) ;
                (C *> Y) = (C_LH_Y, C_HL_Y) ;
                (D *> Y) = (D_LH_Y, D_HL_Y) ;
        endspecify
endmodule

module oa4b9(Y, A, B, C, D);
        output Y;
        input  A, B, C, D;
        not g1(N2, A);
        or g2(N1, N2, B);
        or g3(N3, C, D);
        and g4(Y, N1, N3);
        // SPECIFY BLOCK
        specify
                specparam A_LH_Y = 0, A_HL_Y = 0 ;
                specparam B_LH_Y = 0, B_HL_Y = 0 ;
                specparam C_LH_Y = 0, C_HL_Y = 0 ;
                specparam D_LH_Y = 0, D_HL_Y = 0 ;
                (A *> Y) = (A_LH_Y, A_HL_Y) ;
                (B *> Y) = (B_LH_Y, B_HL_Y) ;
                (C *> Y) = (C_LH_Y, C_HL_Y) ;
                (D *> Y) = (D_LH_Y, D_HL_Y) ;
        endspecify
endmodule

module oa4c1(Y, A, B, C, D);
        output Y;
        input  A, B, C, D;
        not g1(N2, A);
        not g2(N3, B);
        or g3(N1, N2, N3);
        or g4(N4, C, D);
        and g5(Y, N1, N4);
        // SPECIFY BLOCK
        specify
                specparam A_LH_Y = 0, A_HL_Y = 0 ;
                specparam B_LH_Y = 0, B_HL_Y = 0 ;
                specparam C_LH_Y = 0, C_HL_Y = 0 ;
                specparam D_LH_Y = 0, D_HL_Y = 0 ;
                (A *> Y) = (A_LH_Y, A_HL_Y) ;
                (B *> Y) = (B_LH_Y, B_HL_Y) ;
                (C *> Y) = (C_LH_Y, C_HL_Y) ;
                (D *> Y) = (D_LH_Y, D_HL_Y) ;
        endspecify
endmodule

module oa4c15(Y, A, B, C, D);
        output Y;
        input  A, B, C, D;
        not g1(N2, A);
        not g2(N3, B);
        or g3(N1, N2, N3);
        or g4(N4, C, D);
        and g5(Y, N1, N4);
        // SPECIFY BLOCK
        specify
                specparam A_LH_Y = 0, A_HL_Y = 0 ;
                specparam B_LH_Y = 0, B_HL_Y = 0 ;
                specparam C_LH_Y = 0, C_HL_Y = 0 ;
                specparam D_LH_Y = 0, D_HL_Y = 0 ;
                (A *> Y) = (A_LH_Y, A_HL_Y) ;
                (B *> Y) = (B_LH_Y, B_HL_Y) ;
                (C *> Y) = (C_LH_Y, C_HL_Y) ;
                (D *> Y) = (D_LH_Y, D_HL_Y) ;
        endspecify
endmodule

module oa4c2(Y, A, B, C, D);
        output Y;
        input  A, B, C, D;
        not g1(N2, A);
        not g2(N3, B);
        or g3(N1, N2, N3);
        or g4(N4, C, D);
        and g5(Y, N1, N4);
        // SPECIFY BLOCK
        specify
                specparam A_LH_Y = 0, A_HL_Y = 0 ;
                specparam B_LH_Y = 0, B_HL_Y = 0 ;
                specparam C_LH_Y = 0, C_HL_Y = 0 ;
                specparam D_LH_Y = 0, D_HL_Y = 0 ;
                (A *> Y) = (A_LH_Y, A_HL_Y) ;
                (B *> Y) = (B_LH_Y, B_HL_Y) ;
                (C *> Y) = (C_LH_Y, C_HL_Y) ;
                (D *> Y) = (D_LH_Y, D_HL_Y) ;
        endspecify
endmodule

module oa4c3(Y, A, B, C, D);
        output Y;
        input  A, B, C, D;
        not g1(N2, A);
        not g2(N3, B);
        or g3(N1, N2, N3);
        or g4(N4, C, D);
        and g5(Y, N1, N4);
        // SPECIFY BLOCK
        specify
                specparam A_LH_Y = 0, A_HL_Y = 0 ;
                specparam B_LH_Y = 0, B_HL_Y = 0 ;
                specparam C_LH_Y = 0, C_HL_Y = 0 ;
                specparam D_LH_Y = 0, D_HL_Y = 0 ;
                (A *> Y) = (A_LH_Y, A_HL_Y) ;
                (B *> Y) = (B_LH_Y, B_HL_Y) ;
                (C *> Y) = (C_LH_Y, C_HL_Y) ;
                (D *> Y) = (D_LH_Y, D_HL_Y) ;
        endspecify
endmodule

module oa4c6(Y, A, B, C, D);
        output Y;
        input  A, B, C, D;
        not g1(N2, A);
        not g2(N3, B);
        or g3(N1, N2, N3);
        or g4(N4, C, D);
        and g5(Y, N1, N4);
        // SPECIFY BLOCK
        specify
                specparam A_LH_Y = 0, A_HL_Y = 0 ;
                specparam B_LH_Y = 0, B_HL_Y = 0 ;
                specparam C_LH_Y = 0, C_HL_Y = 0 ;
                specparam D_LH_Y = 0, D_HL_Y = 0 ;
                (A *> Y) = (A_LH_Y, A_HL_Y) ;
                (B *> Y) = (B_LH_Y, B_HL_Y) ;
                (C *> Y) = (C_LH_Y, C_HL_Y) ;
                (D *> Y) = (D_LH_Y, D_HL_Y) ;
        endspecify
endmodule

module oa4c9(Y, A, B, C, D);
        output Y;
        input  A, B, C, D;
        not g1(N2, A);
        not g2(N3, B);
        or g3(N1, N2, N3);
        or g4(N4, C, D);
        and g5(Y, N1, N4);
        // SPECIFY BLOCK
        specify
                specparam A_LH_Y = 0, A_HL_Y = 0 ;
                specparam B_LH_Y = 0, B_HL_Y = 0 ;
                specparam C_LH_Y = 0, C_HL_Y = 0 ;
                specparam D_LH_Y = 0, D_HL_Y = 0 ;
                (A *> Y) = (A_LH_Y, A_HL_Y) ;
                (B *> Y) = (B_LH_Y, B_HL_Y) ;
                (C *> Y) = (C_LH_Y, C_HL_Y) ;
                (D *> Y) = (D_LH_Y, D_HL_Y) ;
        endspecify
endmodule

module oa4d1(Y, A, B, C, D);
        output Y;
        input  A, B, C, D;
        not g1(N2, A);
        or g2(N1, N2, B);
        not g3(N4, C);
        or g4(N3, N4, D);
        and g5(Y, N1, N3);
        // SPECIFY BLOCK
        specify
                specparam A_LH_Y = 0, A_HL_Y = 0 ;
                specparam B_LH_Y = 0, B_HL_Y = 0 ;
                specparam C_LH_Y = 0, C_HL_Y = 0 ;
                specparam D_LH_Y = 0, D_HL_Y = 0 ;
                (A *> Y) = (A_LH_Y, A_HL_Y) ;
                (B *> Y) = (B_LH_Y, B_HL_Y) ;
                (C *> Y) = (C_LH_Y, C_HL_Y) ;
                (D *> Y) = (D_LH_Y, D_HL_Y) ;
        endspecify
endmodule

module oa4d15(Y, A, B, C, D);
        output Y;
        input  A, B, C, D;
        not g1(N2, A);
        or g2(N1, N2, B);
        not g3(N4, C);
        or g4(N3, N4, D);
        and g5(Y, N1, N3);
        // SPECIFY BLOCK
        specify
                specparam A_LH_Y = 0, A_HL_Y = 0 ;
                specparam B_LH_Y = 0, B_HL_Y = 0 ;
                specparam C_LH_Y = 0, C_HL_Y = 0 ;
                specparam D_LH_Y = 0, D_HL_Y = 0 ;
                (A *> Y) = (A_LH_Y, A_HL_Y) ;
                (B *> Y) = (B_LH_Y, B_HL_Y) ;
                (C *> Y) = (C_LH_Y, C_HL_Y) ;
                (D *> Y) = (D_LH_Y, D_HL_Y) ;
        endspecify
endmodule

module oa4d2(Y, A, B, C, D);
        output Y;
        input  A, B, C, D;
        not g1(N2, A);
        or g2(N1, N2, B);
        not g3(N4, C);
        or g4(N3, N4, D);
        and g5(Y, N1, N3);
        // SPECIFY BLOCK
        specify
                specparam A_LH_Y = 0, A_HL_Y = 0 ;
                specparam B_LH_Y = 0, B_HL_Y = 0 ;
                specparam C_LH_Y = 0, C_HL_Y = 0 ;
                specparam D_LH_Y = 0, D_HL_Y = 0 ;
                (A *> Y) = (A_LH_Y, A_HL_Y) ;
                (B *> Y) = (B_LH_Y, B_HL_Y) ;
                (C *> Y) = (C_LH_Y, C_HL_Y) ;
                (D *> Y) = (D_LH_Y, D_HL_Y) ;
        endspecify
endmodule

module oa4d3(Y, A, B, C, D);
        output Y;
        input  A, B, C, D;
        not g1(N2, A);
        or g2(N1, N2, B);
        not g3(N4, C);
        or g4(N3, N4, D);
        and g5(Y, N1, N3);
        // SPECIFY BLOCK
        specify
                specparam A_LH_Y = 0, A_HL_Y = 0 ;
                specparam B_LH_Y = 0, B_HL_Y = 0 ;
                specparam C_LH_Y = 0, C_HL_Y = 0 ;
                specparam D_LH_Y = 0, D_HL_Y = 0 ;
                (A *> Y) = (A_LH_Y, A_HL_Y) ;
                (B *> Y) = (B_LH_Y, B_HL_Y) ;
                (C *> Y) = (C_LH_Y, C_HL_Y) ;
                (D *> Y) = (D_LH_Y, D_HL_Y) ;
        endspecify
endmodule

module oa4d6(Y, A, B, C, D);
        output Y;
        input  A, B, C, D;
        not g1(N2, A);
        or g2(N1, N2, B);
        not g3(N4, C);
        or g4(N3, N4, D);
        and g5(Y, N1, N3);
        // SPECIFY BLOCK
        specify
                specparam A_LH_Y = 0, A_HL_Y = 0 ;
                specparam B_LH_Y = 0, B_HL_Y = 0 ;
                specparam C_LH_Y = 0, C_HL_Y = 0 ;
                specparam D_LH_Y = 0, D_HL_Y = 0 ;
                (A *> Y) = (A_LH_Y, A_HL_Y) ;
                (B *> Y) = (B_LH_Y, B_HL_Y) ;
                (C *> Y) = (C_LH_Y, C_HL_Y) ;
                (D *> Y) = (D_LH_Y, D_HL_Y) ;
        endspecify
endmodule

module oa4d9(Y, A, B, C, D);
        output Y;
        input  A, B, C, D;
        not g1(N2, A);
        or g2(N1, N2, B);
        not g3(N4, C);
        or g4(N3, N4, D);
        and g5(Y, N1, N3);
        // SPECIFY BLOCK
        specify
                specparam A_LH_Y = 0, A_HL_Y = 0 ;
                specparam B_LH_Y = 0, B_HL_Y = 0 ;
                specparam C_LH_Y = 0, C_HL_Y = 0 ;
                specparam D_LH_Y = 0, D_HL_Y = 0 ;
                (A *> Y) = (A_LH_Y, A_HL_Y) ;
                (B *> Y) = (B_LH_Y, B_HL_Y) ;
                (C *> Y) = (C_LH_Y, C_HL_Y) ;
                (D *> Y) = (D_LH_Y, D_HL_Y) ;
        endspecify
endmodule

module oa4e1(Y, A, B, C, D);
        output Y;
        input  A, B, C, D;
        not g1(N2, A);
        or g2(N1, N2, B);
        not g3(N4, C);
        not g4(N5, D);
        or g5(N3, N4, N5);
        and g6(Y, N1, N3);
        // SPECIFY BLOCK
        specify
                specparam A_LH_Y = 0, A_HL_Y = 0 ;
                specparam B_LH_Y = 0, B_HL_Y = 0 ;
                specparam C_LH_Y = 0, C_HL_Y = 0 ;
                specparam D_LH_Y = 0, D_HL_Y = 0 ;
                (A *> Y) = (A_LH_Y, A_HL_Y) ;
                (B *> Y) = (B_LH_Y, B_HL_Y) ;
                (C *> Y) = (C_LH_Y, C_HL_Y) ;
                (D *> Y) = (D_LH_Y, D_HL_Y) ;
        endspecify
endmodule

module oa4e15(Y, A, B, C, D);
        output Y;
        input  A, B, C, D;
        not g1(N2, A);
        or g2(N1, N2, B);
        not g3(N4, C);
        not g4(N5, D);
        or g5(N3, N4, N5);
        and g6(Y, N1, N3);
        // SPECIFY BLOCK
        specify
                specparam A_LH_Y = 0, A_HL_Y = 0 ;
                specparam B_LH_Y = 0, B_HL_Y = 0 ;
                specparam C_LH_Y = 0, C_HL_Y = 0 ;
                specparam D_LH_Y = 0, D_HL_Y = 0 ;
                (A *> Y) = (A_LH_Y, A_HL_Y) ;
                (B *> Y) = (B_LH_Y, B_HL_Y) ;
                (C *> Y) = (C_LH_Y, C_HL_Y) ;
                (D *> Y) = (D_LH_Y, D_HL_Y) ;
        endspecify
endmodule

module oa4e2(Y, A, B, C, D);
        output Y;
        input  A, B, C, D;
        not g1(N2, A);
        or g2(N1, N2, B);
        not g3(N4, C);
        not g4(N5, D);
        or g5(N3, N4, N5);
        and g6(Y, N1, N3);
        // SPECIFY BLOCK
        specify
                specparam A_LH_Y = 0, A_HL_Y = 0 ;
                specparam B_LH_Y = 0, B_HL_Y = 0 ;
                specparam C_LH_Y = 0, C_HL_Y = 0 ;
                specparam D_LH_Y = 0, D_HL_Y = 0 ;
                (A *> Y) = (A_LH_Y, A_HL_Y) ;
                (B *> Y) = (B_LH_Y, B_HL_Y) ;
                (C *> Y) = (C_LH_Y, C_HL_Y) ;
                (D *> Y) = (D_LH_Y, D_HL_Y) ;
        endspecify
endmodule

module oa4e3(Y, A, B, C, D);
        output Y;
        input  A, B, C, D;
        not g1(N2, A);
        or g2(N1, N2, B);
        not g3(N4, C);
        not g4(N5, D);
        or g5(N3, N4, N5);
        and g6(Y, N1, N3);
        // SPECIFY BLOCK
        specify
                specparam A_LH_Y = 0, A_HL_Y = 0 ;
                specparam B_LH_Y = 0, B_HL_Y = 0 ;
                specparam C_LH_Y = 0, C_HL_Y = 0 ;
                specparam D_LH_Y = 0, D_HL_Y = 0 ;
                (A *> Y) = (A_LH_Y, A_HL_Y) ;
                (B *> Y) = (B_LH_Y, B_HL_Y) ;
                (C *> Y) = (C_LH_Y, C_HL_Y) ;
                (D *> Y) = (D_LH_Y, D_HL_Y) ;
        endspecify
endmodule

module oa4e6(Y, A, B, C, D);
        output Y;
        input  A, B, C, D;
        not g1(N2, A);
        or g2(N1, N2, B);
        not g3(N4, C);
        not g4(N5, D);
        or g5(N3, N4, N5);
        and g6(Y, N1, N3);
        // SPECIFY BLOCK
        specify
                specparam A_LH_Y = 0, A_HL_Y = 0 ;
                specparam B_LH_Y = 0, B_HL_Y = 0 ;
                specparam C_LH_Y = 0, C_HL_Y = 0 ;
                specparam D_LH_Y = 0, D_HL_Y = 0 ;
                (A *> Y) = (A_LH_Y, A_HL_Y) ;
                (B *> Y) = (B_LH_Y, B_HL_Y) ;
                (C *> Y) = (C_LH_Y, C_HL_Y) ;
                (D *> Y) = (D_LH_Y, D_HL_Y) ;
        endspecify
endmodule

module oa4e9(Y, A, B, C, D);
        output Y;
        input  A, B, C, D;
        not g1(N2, A);
        or g2(N1, N2, B);
        not g3(N4, C);
        not g4(N5, D);
        or g5(N3, N4, N5);
        and g6(Y, N1, N3);
        // SPECIFY BLOCK
        specify
                specparam A_LH_Y = 0, A_HL_Y = 0 ;
                specparam B_LH_Y = 0, B_HL_Y = 0 ;
                specparam C_LH_Y = 0, C_HL_Y = 0 ;
                specparam D_LH_Y = 0, D_HL_Y = 0 ;
                (A *> Y) = (A_LH_Y, A_HL_Y) ;
                (B *> Y) = (B_LH_Y, B_HL_Y) ;
                (C *> Y) = (C_LH_Y, C_HL_Y) ;
                (D *> Y) = (D_LH_Y, D_HL_Y) ;
        endspecify
endmodule

module oa4f1(Y, A, B, C, D);
        output Y;
        input  A, B, C, D;
        not g1(N2, A);
        not g2(N3, B);
        or g3(N1, N2, N3);
        not g4(N5, C);
        not g5(N6, D);
        or g6(N4, N5, N6);
        and g7(Y, N1, N4);
        // SPECIFY BLOCK
        specify
                specparam A_LH_Y = 0, A_HL_Y = 0 ;
                specparam B_LH_Y = 0, B_HL_Y = 0 ;
                specparam C_LH_Y = 0, C_HL_Y = 0 ;
                specparam D_LH_Y = 0, D_HL_Y = 0 ;
                (A *> Y) = (A_LH_Y, A_HL_Y) ;
                (B *> Y) = (B_LH_Y, B_HL_Y) ;
                (C *> Y) = (C_LH_Y, C_HL_Y) ;
                (D *> Y) = (D_LH_Y, D_HL_Y) ;
        endspecify
endmodule

module oa4f15(Y, A, B, C, D);
        output Y;
        input  A, B, C, D;
        not g1(N2, A);
        not g2(N3, B);
        or g3(N1, N2, N3);
        not g4(N5, C);
        not g5(N6, D);
        or g6(N4, N5, N6);
        and g7(Y, N1, N4);
        // SPECIFY BLOCK
        specify
                specparam A_LH_Y = 0, A_HL_Y = 0 ;
                specparam B_LH_Y = 0, B_HL_Y = 0 ;
                specparam C_LH_Y = 0, C_HL_Y = 0 ;
                specparam D_LH_Y = 0, D_HL_Y = 0 ;
                (A *> Y) = (A_LH_Y, A_HL_Y) ;
                (B *> Y) = (B_LH_Y, B_HL_Y) ;
                (C *> Y) = (C_LH_Y, C_HL_Y) ;
                (D *> Y) = (D_LH_Y, D_HL_Y) ;
        endspecify
endmodule

module oa4f2(Y, A, B, C, D);
        output Y;
        input  A, B, C, D;
        not g1(N2, A);
        not g2(N3, B);
        or g3(N1, N2, N3);
        not g4(N5, C);
        not g5(N6, D);
        or g6(N4, N5, N6);
        and g7(Y, N1, N4);
        // SPECIFY BLOCK
        specify
                specparam A_LH_Y = 0, A_HL_Y = 0 ;
                specparam B_LH_Y = 0, B_HL_Y = 0 ;
                specparam C_LH_Y = 0, C_HL_Y = 0 ;
                specparam D_LH_Y = 0, D_HL_Y = 0 ;
                (A *> Y) = (A_LH_Y, A_HL_Y) ;
                (B *> Y) = (B_LH_Y, B_HL_Y) ;
                (C *> Y) = (C_LH_Y, C_HL_Y) ;
                (D *> Y) = (D_LH_Y, D_HL_Y) ;
        endspecify
endmodule

module oa4f3(Y, A, B, C, D);
        output Y;
        input  A, B, C, D;
        not g1(N2, A);
        not g2(N3, B);
        or g3(N1, N2, N3);
        not g4(N5, C);
        not g5(N6, D);
        or g6(N4, N5, N6);
        and g7(Y, N1, N4);
        // SPECIFY BLOCK
        specify
                specparam A_LH_Y = 0, A_HL_Y = 0 ;
                specparam B_LH_Y = 0, B_HL_Y = 0 ;
                specparam C_LH_Y = 0, C_HL_Y = 0 ;
                specparam D_LH_Y = 0, D_HL_Y = 0 ;
                (A *> Y) = (A_LH_Y, A_HL_Y) ;
                (B *> Y) = (B_LH_Y, B_HL_Y) ;
                (C *> Y) = (C_LH_Y, C_HL_Y) ;
                (D *> Y) = (D_LH_Y, D_HL_Y) ;
        endspecify
endmodule

module oa4f6(Y, A, B, C, D);
        output Y;
        input  A, B, C, D;
        not g1(N2, A);
        not g2(N3, B);
        or g3(N1, N2, N3);
        not g4(N5, C);
        not g5(N6, D);
        or g6(N4, N5, N6);
        and g7(Y, N1, N4);
        // SPECIFY BLOCK
        specify
                specparam A_LH_Y = 0, A_HL_Y = 0 ;
                specparam B_LH_Y = 0, B_HL_Y = 0 ;
                specparam C_LH_Y = 0, C_HL_Y = 0 ;
                specparam D_LH_Y = 0, D_HL_Y = 0 ;
                (A *> Y) = (A_LH_Y, A_HL_Y) ;
                (B *> Y) = (B_LH_Y, B_HL_Y) ;
                (C *> Y) = (C_LH_Y, C_HL_Y) ;
                (D *> Y) = (D_LH_Y, D_HL_Y) ;
        endspecify
endmodule

module oa4f9(Y, A, B, C, D);
        output Y;
        input  A, B, C, D;
        not g1(N2, A);
        not g2(N3, B);
        or g3(N1, N2, N3);
        not g4(N5, C);
        not g5(N6, D);
        or g6(N4, N5, N6);
        and g7(Y, N1, N4);
        // SPECIFY BLOCK
        specify
                specparam A_LH_Y = 0, A_HL_Y = 0 ;
                specparam B_LH_Y = 0, B_HL_Y = 0 ;
                specparam C_LH_Y = 0, C_HL_Y = 0 ;
                specparam D_LH_Y = 0, D_HL_Y = 0 ;
                (A *> Y) = (A_LH_Y, A_HL_Y) ;
                (B *> Y) = (B_LH_Y, B_HL_Y) ;
                (C *> Y) = (C_LH_Y, C_HL_Y) ;
                (D *> Y) = (D_LH_Y, D_HL_Y) ;
        endspecify
endmodule

module or2a1(Y, A, B);
        output Y;
        input  A, B;
        or g1(Y, A, B);
        // SPECIFY BLOCK
        specify
                specparam A_LH_Y = 0, A_HL_Y = 0 ;
                specparam B_LH_Y = 0, B_HL_Y = 0 ;
                (A *> Y) = (A_LH_Y, A_HL_Y) ;
                (B *> Y) = (B_LH_Y, B_HL_Y) ;
        endspecify
endmodule

module or2a15(Y, A, B);
        output Y;
        input  A, B;
        or g1(Y, A, B);
        // SPECIFY BLOCK
        specify
                specparam A_LH_Y = 0, A_HL_Y = 0 ;
                specparam B_LH_Y = 0, B_HL_Y = 0 ;
                (A *> Y) = (A_LH_Y, A_HL_Y) ;
                (B *> Y) = (B_LH_Y, B_HL_Y) ;
        endspecify
endmodule

module or2a2(Y, A, B);
        output Y;
        input  A, B;
        or g1(Y, A, B);
        // SPECIFY BLOCK
        specify
                specparam A_LH_Y = 0, A_HL_Y = 0 ;
                specparam B_LH_Y = 0, B_HL_Y = 0 ;
                (A *> Y) = (A_LH_Y, A_HL_Y) ;
                (B *> Y) = (B_LH_Y, B_HL_Y) ;
        endspecify
endmodule

module or2a3(Y, A, B);
        output Y;
        input  A, B;
        or g1(Y, A, B);
        // SPECIFY BLOCK
        specify
                specparam A_LH_Y = 0, A_HL_Y = 0 ;
                specparam B_LH_Y = 0, B_HL_Y = 0 ;
                (A *> Y) = (A_LH_Y, A_HL_Y) ;
                (B *> Y) = (B_LH_Y, B_HL_Y) ;
        endspecify
endmodule

module or2a6(Y, A, B);
        output Y;
        input  A, B;
        or g1(Y, A, B);
        // SPECIFY BLOCK
        specify
                specparam A_LH_Y = 0, A_HL_Y = 0 ;
                specparam B_LH_Y = 0, B_HL_Y = 0 ;
                (A *> Y) = (A_LH_Y, A_HL_Y) ;
                (B *> Y) = (B_LH_Y, B_HL_Y) ;
        endspecify
endmodule

module or2a9(Y, A, B);
        output Y;
        input  A, B;
        or g1(Y, A, B);
        // SPECIFY BLOCK
        specify
                specparam A_LH_Y = 0, A_HL_Y = 0 ;
                specparam B_LH_Y = 0, B_HL_Y = 0 ;
                (A *> Y) = (A_LH_Y, A_HL_Y) ;
                (B *> Y) = (B_LH_Y, B_HL_Y) ;
        endspecify
endmodule

module or2b1(Y, A, B);
        output Y;
        input  A, B;
        not g1(N1, A);
        or g2(Y, N1, B);
        // SPECIFY BLOCK
        specify
                specparam A_LH_Y = 0, A_HL_Y = 0 ;
                specparam B_LH_Y = 0, B_HL_Y = 0 ;
                (A *> Y) = (A_LH_Y, A_HL_Y) ;
                (B *> Y) = (B_LH_Y, B_HL_Y) ;
        endspecify
endmodule

module or2b15(Y, A, B);
        output Y;
        input  A, B;
        not g1(N1, A);
        or g2(Y, N1, B);
        // SPECIFY BLOCK
        specify
                specparam A_LH_Y = 0, A_HL_Y = 0 ;
                specparam B_LH_Y = 0, B_HL_Y = 0 ;
                (A *> Y) = (A_LH_Y, A_HL_Y) ;
                (B *> Y) = (B_LH_Y, B_HL_Y) ;
        endspecify
endmodule

module or2b2(Y, A, B);
        output Y;
        input  A, B;
        not g1(N1, A);
        or g2(Y, N1, B);
        // SPECIFY BLOCK
        specify
                specparam A_LH_Y = 0, A_HL_Y = 0 ;
                specparam B_LH_Y = 0, B_HL_Y = 0 ;
                (A *> Y) = (A_LH_Y, A_HL_Y) ;
                (B *> Y) = (B_LH_Y, B_HL_Y) ;
        endspecify
endmodule

module or2b3(Y, A, B);
        output Y;
        input  A, B;
        not g1(N1, A);
        or g2(Y, N1, B);
        // SPECIFY BLOCK
        specify
                specparam A_LH_Y = 0, A_HL_Y = 0 ;
                specparam B_LH_Y = 0, B_HL_Y = 0 ;
                (A *> Y) = (A_LH_Y, A_HL_Y) ;
                (B *> Y) = (B_LH_Y, B_HL_Y) ;
        endspecify
endmodule

module or2b6(Y, A, B);
        output Y;
        input  A, B;
        not g1(N1, A);
        or g2(Y, N1, B);
        // SPECIFY BLOCK
        specify
                specparam A_LH_Y = 0, A_HL_Y = 0 ;
                specparam B_LH_Y = 0, B_HL_Y = 0 ;
                (A *> Y) = (A_LH_Y, A_HL_Y) ;
                (B *> Y) = (B_LH_Y, B_HL_Y) ;
        endspecify
endmodule

module or2b9(Y, A, B);
        output Y;
        input  A, B;
        not g1(N1, A);
        or g2(Y, N1, B);
        // SPECIFY BLOCK
        specify
                specparam A_LH_Y = 0, A_HL_Y = 0 ;
                specparam B_LH_Y = 0, B_HL_Y = 0 ;
                (A *> Y) = (A_LH_Y, A_HL_Y) ;
                (B *> Y) = (B_LH_Y, B_HL_Y) ;
        endspecify
endmodule

module or2c1(Y, A, B);
        output Y;
        input  A, B;
        not g1(N1, A);
        not g2(N2, B);
        or g3(Y, N1, N2);
        // SPECIFY BLOCK
        specify
                specparam A_LH_Y = 0, A_HL_Y = 0 ;
                specparam B_LH_Y = 0, B_HL_Y = 0 ;
                (A *> Y) = (A_LH_Y, A_HL_Y) ;
                (B *> Y) = (B_LH_Y, B_HL_Y) ;
        endspecify
endmodule

module or2c15(Y, A, B);
        output Y;
        input  A, B;
        not g1(N1, A);
        not g2(N2, B);
        or g3(Y, N1, N2);
        // SPECIFY BLOCK
        specify
                specparam A_LH_Y = 0, A_HL_Y = 0 ;
                specparam B_LH_Y = 0, B_HL_Y = 0 ;
                (A *> Y) = (A_LH_Y, A_HL_Y) ;
                (B *> Y) = (B_LH_Y, B_HL_Y) ;
        endspecify
endmodule

module or2c2(Y, A, B);
        output Y;
        input  A, B;
        not g1(N1, A);
        not g2(N2, B);
        or g3(Y, N1, N2);
        // SPECIFY BLOCK
        specify
                specparam A_LH_Y = 0, A_HL_Y = 0 ;
                specparam B_LH_Y = 0, B_HL_Y = 0 ;
                (A *> Y) = (A_LH_Y, A_HL_Y) ;
                (B *> Y) = (B_LH_Y, B_HL_Y) ;
        endspecify
endmodule

module or2c3(Y, A, B);
        output Y;
        input  A, B;
        not g1(N1, A);
        not g2(N2, B);
        or g3(Y, N1, N2);
        // SPECIFY BLOCK
        specify
                specparam A_LH_Y = 0, A_HL_Y = 0 ;
                specparam B_LH_Y = 0, B_HL_Y = 0 ;
                (A *> Y) = (A_LH_Y, A_HL_Y) ;
                (B *> Y) = (B_LH_Y, B_HL_Y) ;
        endspecify
endmodule

module or2c6(Y, A, B);
        output Y;
        input  A, B;
        not g1(N1, A);
        not g2(N2, B);
        or g3(Y, N1, N2);
        // SPECIFY BLOCK
        specify
                specparam A_LH_Y = 0, A_HL_Y = 0 ;
                specparam B_LH_Y = 0, B_HL_Y = 0 ;
                (A *> Y) = (A_LH_Y, A_HL_Y) ;
                (B *> Y) = (B_LH_Y, B_HL_Y) ;
        endspecify
endmodule

module or2c9(Y, A, B);
        output Y;
        input  A, B;
        not g1(N1, A);
        not g2(N2, B);
        or g3(Y, N1, N2);
        // SPECIFY BLOCK
        specify
                specparam A_LH_Y = 0, A_HL_Y = 0 ;
                specparam B_LH_Y = 0, B_HL_Y = 0 ;
                (A *> Y) = (A_LH_Y, A_HL_Y) ;
                (B *> Y) = (B_LH_Y, B_HL_Y) ;
        endspecify
endmodule

module or3a1(Y, A, B, C);
        output Y;
        input  A, B, C;
        or g1(Y, B, C, A);
        // SPECIFY BLOCK
        specify
                specparam A_LH_Y = 0, A_HL_Y = 0 ;
                specparam B_LH_Y = 0, B_HL_Y = 0 ;
                specparam C_LH_Y = 0, C_HL_Y = 0 ;
                (A *> Y) = (A_LH_Y, A_HL_Y) ;
                (B *> Y) = (B_LH_Y, B_HL_Y) ;
                (C *> Y) = (C_LH_Y, C_HL_Y) ;
        endspecify
endmodule

module or3a15(Y, A, B, C);
        output Y;
        input  A, B, C;
        or g1(Y, B, C, A);
        // SPECIFY BLOCK
        specify
                specparam A_LH_Y = 0, A_HL_Y = 0 ;
                specparam B_LH_Y = 0, B_HL_Y = 0 ;
                specparam C_LH_Y = 0, C_HL_Y = 0 ;
                (A *> Y) = (A_LH_Y, A_HL_Y) ;
                (B *> Y) = (B_LH_Y, B_HL_Y) ;
                (C *> Y) = (C_LH_Y, C_HL_Y) ;
        endspecify
endmodule

module or3a2(Y, A, B, C);
        output Y;
        input  A, B, C;
        or g1(Y, B, C, A);
        // SPECIFY BLOCK
        specify
                specparam A_LH_Y = 0, A_HL_Y = 0 ;
                specparam B_LH_Y = 0, B_HL_Y = 0 ;
                specparam C_LH_Y = 0, C_HL_Y = 0 ;
                (A *> Y) = (A_LH_Y, A_HL_Y) ;
                (B *> Y) = (B_LH_Y, B_HL_Y) ;
                (C *> Y) = (C_LH_Y, C_HL_Y) ;
        endspecify
endmodule

module or3a3(Y, A, B, C);
        output Y;
        input  A, B, C;
        or g1(Y, B, C, A);
        // SPECIFY BLOCK
        specify
                specparam A_LH_Y = 0, A_HL_Y = 0 ;
                specparam B_LH_Y = 0, B_HL_Y = 0 ;
                specparam C_LH_Y = 0, C_HL_Y = 0 ;
                (A *> Y) = (A_LH_Y, A_HL_Y) ;
                (B *> Y) = (B_LH_Y, B_HL_Y) ;
                (C *> Y) = (C_LH_Y, C_HL_Y) ;
        endspecify
endmodule

module or3a6(Y, A, B, C);
        output Y;
        input  A, B, C;
        or g1(Y, B, C, A);
        // SPECIFY BLOCK
        specify
                specparam A_LH_Y = 0, A_HL_Y = 0 ;
                specparam B_LH_Y = 0, B_HL_Y = 0 ;
                specparam C_LH_Y = 0, C_HL_Y = 0 ;
                (A *> Y) = (A_LH_Y, A_HL_Y) ;
                (B *> Y) = (B_LH_Y, B_HL_Y) ;
                (C *> Y) = (C_LH_Y, C_HL_Y) ;
        endspecify
endmodule

module or3a9(Y, A, B, C);
        output Y;
        input  A, B, C;
        or g1(Y, B, C, A);
        // SPECIFY BLOCK
        specify
                specparam A_LH_Y = 0, A_HL_Y = 0 ;
                specparam B_LH_Y = 0, B_HL_Y = 0 ;
                specparam C_LH_Y = 0, C_HL_Y = 0 ;
                (A *> Y) = (A_LH_Y, A_HL_Y) ;
                (B *> Y) = (B_LH_Y, B_HL_Y) ;
                (C *> Y) = (C_LH_Y, C_HL_Y) ;
        endspecify
endmodule

module or3c1(Y, A, B, C);
        output Y;
        input  A, B, C;
        not g1(N1, B);
        not g2(N2, A);
        or g3(Y, N1, C, N2);
        // SPECIFY BLOCK
        specify
                specparam A_LH_Y = 0, A_HL_Y = 0 ;
                specparam B_LH_Y = 0, B_HL_Y = 0 ;
                specparam C_LH_Y = 0, C_HL_Y = 0 ;
                (A *> Y) = (A_LH_Y, A_HL_Y) ;
                (B *> Y) = (B_LH_Y, B_HL_Y) ;
                (C *> Y) = (C_LH_Y, C_HL_Y) ;
        endspecify
endmodule

module or3c15(Y, A, B, C);
        output Y;
        input  A, B, C;
        not g1(N1, B);
        not g2(N2, A);
        or g3(Y, N1, C, N2);
        // SPECIFY BLOCK
        specify
                specparam A_LH_Y = 0, A_HL_Y = 0 ;
                specparam B_LH_Y = 0, B_HL_Y = 0 ;
                specparam C_LH_Y = 0, C_HL_Y = 0 ;
                (A *> Y) = (A_LH_Y, A_HL_Y) ;
                (B *> Y) = (B_LH_Y, B_HL_Y) ;
                (C *> Y) = (C_LH_Y, C_HL_Y) ;
        endspecify
endmodule

module or3c2(Y, A, B, C);
        output Y;
        input  A, B, C;
        not g1(N1, B);
        not g2(N2, A);
        or g3(Y, N1, C, N2);
        // SPECIFY BLOCK
        specify
                specparam A_LH_Y = 0, A_HL_Y = 0 ;
                specparam B_LH_Y = 0, B_HL_Y = 0 ;
                specparam C_LH_Y = 0, C_HL_Y = 0 ;
                (A *> Y) = (A_LH_Y, A_HL_Y) ;
                (B *> Y) = (B_LH_Y, B_HL_Y) ;
                (C *> Y) = (C_LH_Y, C_HL_Y) ;
        endspecify
endmodule

module or3c3(Y, A, B, C);
        output Y;
        input  A, B, C;
        not g1(N1, B);
        not g2(N2, A);
        or g3(Y, N1, C, N2);
        // SPECIFY BLOCK
        specify
                specparam A_LH_Y = 0, A_HL_Y = 0 ;
                specparam B_LH_Y = 0, B_HL_Y = 0 ;
                specparam C_LH_Y = 0, C_HL_Y = 0 ;
                (A *> Y) = (A_LH_Y, A_HL_Y) ;
                (B *> Y) = (B_LH_Y, B_HL_Y) ;
                (C *> Y) = (C_LH_Y, C_HL_Y) ;
        endspecify
endmodule

module or3c6(Y, A, B, C);
        output Y;
        input  A, B, C;
        not g1(N1, B);
        not g2(N2, A);
        or g3(Y, N1, C, N2);
        // SPECIFY BLOCK
        specify
                specparam A_LH_Y = 0, A_HL_Y = 0 ;
                specparam B_LH_Y = 0, B_HL_Y = 0 ;
                specparam C_LH_Y = 0, C_HL_Y = 0 ;
                (A *> Y) = (A_LH_Y, A_HL_Y) ;
                (B *> Y) = (B_LH_Y, B_HL_Y) ;
                (C *> Y) = (C_LH_Y, C_HL_Y) ;
        endspecify
endmodule

module or3c9(Y, A, B, C);
        output Y;
        input  A, B, C;
        not g1(N1, B);
        not g2(N2, A);
        or g3(Y, N1, C, N2);
        // SPECIFY BLOCK
        specify
                specparam A_LH_Y = 0, A_HL_Y = 0 ;
                specparam B_LH_Y = 0, B_HL_Y = 0 ;
                specparam C_LH_Y = 0, C_HL_Y = 0 ;
                (A *> Y) = (A_LH_Y, A_HL_Y) ;
                (B *> Y) = (B_LH_Y, B_HL_Y) ;
                (C *> Y) = (C_LH_Y, C_HL_Y) ;
        endspecify
endmodule

module or3d1(Y, A, B, C);
        output Y;
        input  A, B, C;
        not g1(N1, B);
        not g2(N2, C);
        not g3(N3, A);
        or g4(Y, N1, N2, N3);
        // SPECIFY BLOCK
        specify
                specparam A_LH_Y = 0, A_HL_Y = 0 ;
                specparam B_LH_Y = 0, B_HL_Y = 0 ;
                specparam C_LH_Y = 0, C_HL_Y = 0 ;
                (A *> Y) = (A_LH_Y, A_HL_Y) ;
                (B *> Y) = (B_LH_Y, B_HL_Y) ;
                (C *> Y) = (C_LH_Y, C_HL_Y) ;
        endspecify
endmodule

module or3d15(Y, A, B, C);
        output Y;
        input  A, B, C;
        not g1(N1, B);
        not g2(N2, C);
        not g3(N3, A);
        or g4(Y, N1, N2, N3);
        // SPECIFY BLOCK
        specify
                specparam A_LH_Y = 0, A_HL_Y = 0 ;
                specparam B_LH_Y = 0, B_HL_Y = 0 ;
                specparam C_LH_Y = 0, C_HL_Y = 0 ;
                (A *> Y) = (A_LH_Y, A_HL_Y) ;
                (B *> Y) = (B_LH_Y, B_HL_Y) ;
                (C *> Y) = (C_LH_Y, C_HL_Y) ;
        endspecify
endmodule

module or3d2(Y, A, B, C);
        output Y;
        input  A, B, C;
        not g1(N1, B);
        not g2(N2, C);
        not g3(N3, A);
        or g4(Y, N1, N2, N3);
        // SPECIFY BLOCK
        specify
                specparam A_LH_Y = 0, A_HL_Y = 0 ;
                specparam B_LH_Y = 0, B_HL_Y = 0 ;
                specparam C_LH_Y = 0, C_HL_Y = 0 ;
                (A *> Y) = (A_LH_Y, A_HL_Y) ;
                (B *> Y) = (B_LH_Y, B_HL_Y) ;
                (C *> Y) = (C_LH_Y, C_HL_Y) ;
        endspecify
endmodule

module or3d3(Y, A, B, C);
        output Y;
        input  A, B, C;
        not g1(N1, B);
        not g2(N2, C);
        not g3(N3, A);
        or g4(Y, N1, N2, N3);
        // SPECIFY BLOCK
        specify
                specparam A_LH_Y = 0, A_HL_Y = 0 ;
                specparam B_LH_Y = 0, B_HL_Y = 0 ;
                specparam C_LH_Y = 0, C_HL_Y = 0 ;
                (A *> Y) = (A_LH_Y, A_HL_Y) ;
                (B *> Y) = (B_LH_Y, B_HL_Y) ;
                (C *> Y) = (C_LH_Y, C_HL_Y) ;
        endspecify
endmodule

module or3d6(Y, A, B, C);
        output Y;
        input  A, B, C;
        not g1(N1, B);
        not g2(N2, C);
        not g3(N3, A);
        or g4(Y, N1, N2, N3);
        // SPECIFY BLOCK
        specify
                specparam A_LH_Y = 0, A_HL_Y = 0 ;
                specparam B_LH_Y = 0, B_HL_Y = 0 ;
                specparam C_LH_Y = 0, C_HL_Y = 0 ;
                (A *> Y) = (A_LH_Y, A_HL_Y) ;
                (B *> Y) = (B_LH_Y, B_HL_Y) ;
                (C *> Y) = (C_LH_Y, C_HL_Y) ;
        endspecify
endmodule

module or3d9(Y, A, B, C);
        output Y;
        input  A, B, C;
        not g1(N1, B);
        not g2(N2, C);
        not g3(N3, A);
        or g4(Y, N1, N2, N3);
        // SPECIFY BLOCK
        specify
                specparam A_LH_Y = 0, A_HL_Y = 0 ;
                specparam B_LH_Y = 0, B_HL_Y = 0 ;
                specparam C_LH_Y = 0, C_HL_Y = 0 ;
                (A *> Y) = (A_LH_Y, A_HL_Y) ;
                (B *> Y) = (B_LH_Y, B_HL_Y) ;
                (C *> Y) = (C_LH_Y, C_HL_Y) ;
        endspecify
endmodule

module or4a15(Y, A, B, C, D);
        output Y;
        input  A, B, C, D;
        or g1(Y, C, D, B, A);
        // SPECIFY BLOCK
        specify
                specparam A_LH_Y = 0, A_HL_Y = 0 ;
                specparam B_LH_Y = 0, B_HL_Y = 0 ;
                specparam C_LH_Y = 0, C_HL_Y = 0 ;
                specparam D_LH_Y = 0, D_HL_Y = 0 ;
                (A *> Y) = (A_LH_Y, A_HL_Y) ;
                (B *> Y) = (B_LH_Y, B_HL_Y) ;
                (C *> Y) = (C_LH_Y, C_HL_Y) ;
                (D *> Y) = (D_LH_Y, D_HL_Y) ;
        endspecify
endmodule

module or4a3(Y, A, B, C, D);
        output Y;
        input  A, B, C, D;
        or g1(Y, C, D, B, A);
        // SPECIFY BLOCK
        specify
                specparam A_LH_Y = 0, A_HL_Y = 0 ;
                specparam B_LH_Y = 0, B_HL_Y = 0 ;
                specparam C_LH_Y = 0, C_HL_Y = 0 ;
                specparam D_LH_Y = 0, D_HL_Y = 0 ;
                (A *> Y) = (A_LH_Y, A_HL_Y) ;
                (B *> Y) = (B_LH_Y, B_HL_Y) ;
                (C *> Y) = (C_LH_Y, C_HL_Y) ;
                (D *> Y) = (D_LH_Y, D_HL_Y) ;
        endspecify
endmodule

module or4a6(Y, A, B, C, D);
        output Y;
        input  A, B, C, D;
        or g1(Y, C, D, B, A);
        // SPECIFY BLOCK
        specify
                specparam A_LH_Y = 0, A_HL_Y = 0 ;
                specparam B_LH_Y = 0, B_HL_Y = 0 ;
                specparam C_LH_Y = 0, C_HL_Y = 0 ;
                specparam D_LH_Y = 0, D_HL_Y = 0 ;
                (A *> Y) = (A_LH_Y, A_HL_Y) ;
                (B *> Y) = (B_LH_Y, B_HL_Y) ;
                (C *> Y) = (C_LH_Y, C_HL_Y) ;
                (D *> Y) = (D_LH_Y, D_HL_Y) ;
        endspecify
endmodule

module or4a9(Y, A, B, C, D);
        output Y;
        input  A, B, C, D;
        or g1(Y, C, D, B, A);
        // SPECIFY BLOCK
        specify
                specparam A_LH_Y = 0, A_HL_Y = 0 ;
                specparam B_LH_Y = 0, B_HL_Y = 0 ;
                specparam C_LH_Y = 0, C_HL_Y = 0 ;
                specparam D_LH_Y = 0, D_HL_Y = 0 ;
                (A *> Y) = (A_LH_Y, A_HL_Y) ;
                (B *> Y) = (B_LH_Y, B_HL_Y) ;
                (C *> Y) = (C_LH_Y, C_HL_Y) ;
                (D *> Y) = (D_LH_Y, D_HL_Y) ;
        endspecify
endmodule

module or4e15(Y, A, B, C, D);
        output Y;
        input  A, B, C, D;
        not g1(N1, C);
        not g2(N2, D);
        not g3(N3, B);
        not g4(N4, A);
        or g5(Y, N1, N2, N3, N4);
        // SPECIFY BLOCK
        specify
                specparam A_LH_Y = 0, A_HL_Y = 0 ;
                specparam B_LH_Y = 0, B_HL_Y = 0 ;
                specparam C_LH_Y = 0, C_HL_Y = 0 ;
                specparam D_LH_Y = 0, D_HL_Y = 0 ;
                (A *> Y) = (A_LH_Y, A_HL_Y) ;
                (B *> Y) = (B_LH_Y, B_HL_Y) ;
                (C *> Y) = (C_LH_Y, C_HL_Y) ;
                (D *> Y) = (D_LH_Y, D_HL_Y) ;
        endspecify
endmodule

module or4e3(Y, A, B, C, D);
        output Y;
        input  A, B, C, D;
        not g1(N1, C);
        not g2(N2, D);
        not g3(N3, B);
        not g4(N4, A);
        or g5(Y, N1, N2, N3, N4);
        // SPECIFY BLOCK
        specify
                specparam A_LH_Y = 0, A_HL_Y = 0 ;
                specparam B_LH_Y = 0, B_HL_Y = 0 ;
                specparam C_LH_Y = 0, C_HL_Y = 0 ;
                specparam D_LH_Y = 0, D_HL_Y = 0 ;
                (A *> Y) = (A_LH_Y, A_HL_Y) ;
                (B *> Y) = (B_LH_Y, B_HL_Y) ;
                (C *> Y) = (C_LH_Y, C_HL_Y) ;
                (D *> Y) = (D_LH_Y, D_HL_Y) ;
        endspecify
endmodule

module or4e6(Y, A, B, C, D);
        output Y;
        input  A, B, C, D;
        not g1(N1, C);
        not g2(N2, D);
        not g3(N3, B);
        not g4(N4, A);
        or g5(Y, N1, N2, N3, N4);
        // SPECIFY BLOCK
        specify
                specparam A_LH_Y = 0, A_HL_Y = 0 ;
                specparam B_LH_Y = 0, B_HL_Y = 0 ;
                specparam C_LH_Y = 0, C_HL_Y = 0 ;
                specparam D_LH_Y = 0, D_HL_Y = 0 ;
                (A *> Y) = (A_LH_Y, A_HL_Y) ;
                (B *> Y) = (B_LH_Y, B_HL_Y) ;
                (C *> Y) = (C_LH_Y, C_HL_Y) ;
                (D *> Y) = (D_LH_Y, D_HL_Y) ;
        endspecify
endmodule

module or4e9(Y, A, B, C, D);
        output Y;
        input  A, B, C, D;
        not g1(N1, C);
        not g2(N2, D);
        not g3(N3, B);
        not g4(N4, A);
        or g5(Y, N1, N2, N3, N4);
        // SPECIFY BLOCK
        specify
                specparam A_LH_Y = 0, A_HL_Y = 0 ;
                specparam B_LH_Y = 0, B_HL_Y = 0 ;
                specparam C_LH_Y = 0, C_HL_Y = 0 ;
                specparam D_LH_Y = 0, D_HL_Y = 0 ;
                (A *> Y) = (A_LH_Y, A_HL_Y) ;
                (B *> Y) = (B_LH_Y, B_HL_Y) ;
                (C *> Y) = (C_LH_Y, C_HL_Y) ;
                (D *> Y) = (D_LH_Y, D_HL_Y) ;
        endspecify
endmodule

module or6a15(Y, A, B, C, D, E, F);
        output Y;
        input  A, B, C, D, E, F;
        or g1(Y, E, F, D, C, B, A);
        // SPECIFY BLOCK
        specify
                specparam A_LH_Y = 0, A_HL_Y = 0 ;
                specparam B_LH_Y = 0, B_HL_Y = 0 ;
                specparam C_LH_Y = 0, C_HL_Y = 0 ;
                specparam D_LH_Y = 0, D_HL_Y = 0 ;
                specparam E_LH_Y = 0, E_HL_Y = 0 ;
                specparam F_LH_Y = 0, F_HL_Y = 0 ;
                (A *> Y) = (A_LH_Y, A_HL_Y) ;
                (B *> Y) = (B_LH_Y, B_HL_Y) ;
                (C *> Y) = (C_LH_Y, C_HL_Y) ;
                (D *> Y) = (D_LH_Y, D_HL_Y) ;
                (E *> Y) = (E_LH_Y, E_HL_Y) ;
                (F *> Y) = (F_LH_Y, F_HL_Y) ;
        endspecify
endmodule

module or6a3(Y, A, B, C, D, E, F);
        output Y;
        input  A, B, C, D, E, F;
        or g1(Y, E, F, D, C, B, A);
        // SPECIFY BLOCK
        specify
                specparam A_LH_Y = 0, A_HL_Y = 0 ;
                specparam B_LH_Y = 0, B_HL_Y = 0 ;
                specparam C_LH_Y = 0, C_HL_Y = 0 ;
                specparam D_LH_Y = 0, D_HL_Y = 0 ;
                specparam E_LH_Y = 0, E_HL_Y = 0 ;
                specparam F_LH_Y = 0, F_HL_Y = 0 ;
                (A *> Y) = (A_LH_Y, A_HL_Y) ;
                (B *> Y) = (B_LH_Y, B_HL_Y) ;
                (C *> Y) = (C_LH_Y, C_HL_Y) ;
                (D *> Y) = (D_LH_Y, D_HL_Y) ;
                (E *> Y) = (E_LH_Y, E_HL_Y) ;
                (F *> Y) = (F_LH_Y, F_HL_Y) ;
        endspecify
endmodule

module or6a6(Y, A, B, C, D, E, F);
        output Y;
        input  A, B, C, D, E, F;
        or g1(Y, E, F, D, C, B, A);
        // SPECIFY BLOCK
        specify
                specparam A_LH_Y = 0, A_HL_Y = 0 ;
                specparam B_LH_Y = 0, B_HL_Y = 0 ;
                specparam C_LH_Y = 0, C_HL_Y = 0 ;
                specparam D_LH_Y = 0, D_HL_Y = 0 ;
                specparam E_LH_Y = 0, E_HL_Y = 0 ;
                specparam F_LH_Y = 0, F_HL_Y = 0 ;
                (A *> Y) = (A_LH_Y, A_HL_Y) ;
                (B *> Y) = (B_LH_Y, B_HL_Y) ;
                (C *> Y) = (C_LH_Y, C_HL_Y) ;
                (D *> Y) = (D_LH_Y, D_HL_Y) ;
                (E *> Y) = (E_LH_Y, E_HL_Y) ;
                (F *> Y) = (F_LH_Y, F_HL_Y) ;
        endspecify
endmodule

module or6a9(Y, A, B, C, D, E, F);
        output Y;
        input  A, B, C, D, E, F;
        or g1(Y, E, F, D, C, B, A);
        // SPECIFY BLOCK
        specify
                specparam A_LH_Y = 0, A_HL_Y = 0 ;
                specparam B_LH_Y = 0, B_HL_Y = 0 ;
                specparam C_LH_Y = 0, C_HL_Y = 0 ;
                specparam D_LH_Y = 0, D_HL_Y = 0 ;
                specparam E_LH_Y = 0, E_HL_Y = 0 ;
                specparam F_LH_Y = 0, F_HL_Y = 0 ;
                (A *> Y) = (A_LH_Y, A_HL_Y) ;
                (B *> Y) = (B_LH_Y, B_HL_Y) ;
                (C *> Y) = (C_LH_Y, C_HL_Y) ;
                (D *> Y) = (D_LH_Y, D_HL_Y) ;
                (E *> Y) = (E_LH_Y, E_HL_Y) ;
                (F *> Y) = (F_LH_Y, F_HL_Y) ;
        endspecify
endmodule

module tri1a1(Y, A, E);
        output Y;
        input  A, E;
        bufif1 g1(Y, A, E);
        // SPECIFY BLOCK
        specify
                specparam A_LH_Y = 0, A_HL_Y = 0 ;
                specparam E_LH_Y = 0, E_HL_Y = 0 ;
                specparam E_LZ_Y = 0, E_ZH_Y = 0 ;
                specparam E_HZ_Y = 0, E_ZL_Y = 0 ;
                (A *> Y) = (A_LH_Y, A_HL_Y) ;
                (E *> Y) = (E_LH_Y, E_HL_Y, E_LZ_Y, E_ZH_Y, E_HZ_Y, E_ZL_Y) ;
        endspecify
endmodule

module tri1a15(Y, A, E);
        output Y;
        input  A, E;
        bufif1 g1(Y, A, E);
        // SPECIFY BLOCK
        specify
                specparam A_LH_Y = 0, A_HL_Y = 0 ;
                specparam E_LH_Y = 0, E_HL_Y = 0 ;
                specparam E_LZ_Y = 0, E_ZH_Y = 0 ;
                specparam E_HZ_Y = 0, E_ZL_Y = 0 ;
                (A *> Y) = (A_LH_Y, A_HL_Y) ;
                (E *> Y) = (E_LH_Y, E_HL_Y, E_LZ_Y, E_ZH_Y, E_HZ_Y, E_ZL_Y) ;
        endspecify
endmodule

module tri1a2(Y, A, E);
        output Y;
        input  A, E;
        bufif1 g1(Y, A, E);
        // SPECIFY BLOCK
        specify
                specparam A_LH_Y = 0, A_HL_Y = 0 ;
                specparam E_LH_Y = 0, E_HL_Y = 0 ;
                specparam E_LZ_Y = 0, E_ZH_Y = 0 ;
                specparam E_HZ_Y = 0, E_ZL_Y = 0 ;
                (A *> Y) = (A_LH_Y, A_HL_Y) ;
                (E *> Y) = (E_LH_Y, E_HL_Y, E_LZ_Y, E_ZH_Y, E_HZ_Y, E_ZL_Y) ;
        endspecify
endmodule

module tri1a27(Y, A, E);
        output Y;
        input  A, E;
        bufif1 g1(Y, A, E);
        // SPECIFY BLOCK
        specify
                specparam A_LH_Y = 0, A_HL_Y = 0 ;
                specparam E_LH_Y = 0, E_HL_Y = 0 ;
                specparam E_LZ_Y = 0, E_ZH_Y = 0 ;
                specparam E_HZ_Y = 0, E_ZL_Y = 0 ;
                (A *> Y) = (A_LH_Y, A_HL_Y) ;
                (E *> Y) = (E_LH_Y, E_HL_Y, E_LZ_Y, E_ZH_Y, E_HZ_Y, E_ZL_Y) ;
        endspecify
endmodule

module tri1a3(Y, A, E);
        output Y;
        input  A, E;
        bufif1 g1(Y, A, E);
        // SPECIFY BLOCK
        specify
                specparam A_LH_Y = 0, A_HL_Y = 0 ;
                specparam E_LH_Y = 0, E_HL_Y = 0 ;
                specparam E_LZ_Y = 0, E_ZH_Y = 0 ;
                specparam E_HZ_Y = 0, E_ZL_Y = 0 ;
                (A *> Y) = (A_LH_Y, A_HL_Y) ;
                (E *> Y) = (E_LH_Y, E_HL_Y, E_LZ_Y, E_ZH_Y, E_HZ_Y, E_ZL_Y) ;
        endspecify
endmodule

module tri1a6(Y, A, E);
        output Y;
        input  A, E;
        bufif1 g1(Y, A, E);
        // SPECIFY BLOCK
        specify
                specparam A_LH_Y = 0, A_HL_Y = 0 ;
                specparam E_LH_Y = 0, E_HL_Y = 0 ;
                specparam E_LZ_Y = 0, E_ZH_Y = 0 ;
                specparam E_HZ_Y = 0, E_ZL_Y = 0 ;
                (A *> Y) = (A_LH_Y, A_HL_Y) ;
                (E *> Y) = (E_LH_Y, E_HL_Y, E_LZ_Y, E_ZH_Y, E_HZ_Y, E_ZL_Y) ;
        endspecify
endmodule

module tri1a9(Y, A, E);
        output Y;
        input  A, E;
        bufif1 g1(Y, A, E);
        // SPECIFY BLOCK
        specify
                specparam A_LH_Y = 0, A_HL_Y = 0 ;
                specparam E_LH_Y = 0, E_HL_Y = 0 ;
                specparam E_LZ_Y = 0, E_ZH_Y = 0 ;
                specparam E_HZ_Y = 0, E_ZL_Y = 0 ;
                (A *> Y) = (A_LH_Y, A_HL_Y) ;
                (E *> Y) = (E_LH_Y, E_HL_Y, E_LZ_Y, E_ZH_Y, E_HZ_Y, E_ZL_Y) ;
        endspecify
endmodule

module tri1b1(Y, A, E);
        output Y;
        input  A, E;
        not g1(N1, A);
        bufif1 g2(Y, N1, E);
        // SPECIFY BLOCK
        specify
                specparam A_LH_Y = 0, A_HL_Y = 0 ;
                specparam E_LH_Y = 0, E_HL_Y = 0 ;
                specparam E_LZ_Y = 0, E_ZH_Y = 0 ;
                specparam E_HZ_Y = 0, E_ZL_Y = 0 ;
                (A *> Y) = (A_LH_Y, A_HL_Y) ;
                (E *> Y) = (E_LH_Y, E_HL_Y, E_LZ_Y, E_ZH_Y, E_HZ_Y, E_ZL_Y) ;
        endspecify
endmodule

module tri1b15(Y, A, E);
        output Y;
        input  A, E;
        not g1(N1, A);
        bufif1 g2(Y, N1, E);
        // SPECIFY BLOCK
        specify
                specparam A_LH_Y = 0, A_HL_Y = 0 ;
                specparam E_LH_Y = 0, E_HL_Y = 0 ;
                specparam E_LZ_Y = 0, E_ZH_Y = 0 ;
                specparam E_HZ_Y = 0, E_ZL_Y = 0 ;
                (A *> Y) = (A_LH_Y, A_HL_Y) ;
                (E *> Y) = (E_LH_Y, E_HL_Y, E_LZ_Y, E_ZH_Y, E_HZ_Y, E_ZL_Y) ;
        endspecify
endmodule

module tri1b2(Y, A, E);
        output Y;
        input  A, E;
        not g1(N1, A);
        bufif1 g2(Y, N1, E);
        // SPECIFY BLOCK
        specify
                specparam A_LH_Y = 0, A_HL_Y = 0 ;
                specparam E_LH_Y = 0, E_HL_Y = 0 ;
                specparam E_LZ_Y = 0, E_ZH_Y = 0 ;
                specparam E_HZ_Y = 0, E_ZL_Y = 0 ;
                (A *> Y) = (A_LH_Y, A_HL_Y) ;
                (E *> Y) = (E_LH_Y, E_HL_Y, E_LZ_Y, E_ZH_Y, E_HZ_Y, E_ZL_Y) ;
        endspecify
endmodule

module tri1b27(Y, A, E);
        output Y;
        input  A, E;
        not g1(N1, A);
        bufif1 g2(Y, N1, E);
        // SPECIFY BLOCK
        specify
                specparam A_LH_Y = 0, A_HL_Y = 0 ;
                specparam E_LH_Y = 0, E_HL_Y = 0 ;
                specparam E_LZ_Y = 0, E_ZH_Y = 0 ;
                specparam E_HZ_Y = 0, E_ZL_Y = 0 ;
                (A *> Y) = (A_LH_Y, A_HL_Y) ;
                (E *> Y) = (E_LH_Y, E_HL_Y, E_LZ_Y, E_ZH_Y, E_HZ_Y, E_ZL_Y) ;
        endspecify
endmodule

module tri1b3(Y, A, E);
        output Y;
        input  A, E;
        not g1(N1, A);
        bufif1 g2(Y, N1, E);
        // SPECIFY BLOCK
        specify
                specparam A_LH_Y = 0, A_HL_Y = 0 ;
                specparam E_LH_Y = 0, E_HL_Y = 0 ;
                specparam E_LZ_Y = 0, E_ZH_Y = 0 ;
                specparam E_HZ_Y = 0, E_ZL_Y = 0 ;
                (A *> Y) = (A_LH_Y, A_HL_Y) ;
                (E *> Y) = (E_LH_Y, E_HL_Y, E_LZ_Y, E_ZH_Y, E_HZ_Y, E_ZL_Y) ;
        endspecify
endmodule

module tri1b6(Y, A, E);
        output Y;
        input  A, E;
        not g1(N1, A);
        bufif1 g2(Y, N1, E);
        // SPECIFY BLOCK
        specify
                specparam A_LH_Y = 0, A_HL_Y = 0 ;
                specparam E_LH_Y = 0, E_HL_Y = 0 ;
                specparam E_LZ_Y = 0, E_ZH_Y = 0 ;
                specparam E_HZ_Y = 0, E_ZL_Y = 0 ;
                (A *> Y) = (A_LH_Y, A_HL_Y) ;
                (E *> Y) = (E_LH_Y, E_HL_Y, E_LZ_Y, E_ZH_Y, E_HZ_Y, E_ZL_Y) ;
        endspecify
endmodule

module tri1b9(Y, A, E);
        output Y;
        input  A, E;
        not g1(N1, A);
        bufif1 g2(Y, N1, E);
        // SPECIFY BLOCK
        specify
                specparam A_LH_Y = 0, A_HL_Y = 0 ;
                specparam E_LH_Y = 0, E_HL_Y = 0 ;
                specparam E_LZ_Y = 0, E_ZH_Y = 0 ;
                specparam E_HZ_Y = 0, E_ZL_Y = 0 ;
                (A *> Y) = (A_LH_Y, A_HL_Y) ;
                (E *> Y) = (E_LH_Y, E_HL_Y, E_LZ_Y, E_ZH_Y, E_HZ_Y, E_ZL_Y) ;
        endspecify
endmodule

module xor2a1(Y, A, B);
        output Y;
        input  A, B;
        xor g1(Y, A, B);
        // SPECIFY BLOCK
        specify
                specparam A_01_LH_Y = 0, A_01_HL_Y = 0 ;
                specparam A_10_LH_Y = 0, A_10_HL_Y = 0 ;
                specparam B_01_LH_Y = 0, B_01_HL_Y = 0 ;
                specparam B_10_LH_Y = 0, B_10_HL_Y = 0 ;
                (posedge A *> (Y : 1'b1)) = (A_01_LH_Y, A_01_HL_Y) ;
                (negedge A *> (Y : 1'b1)) = (A_10_LH_Y, A_10_HL_Y) ;
                (posedge B *> (Y : 1'b1)) = (B_01_LH_Y, B_01_HL_Y) ;
                (negedge B *> (Y : 1'b1)) = (B_10_LH_Y, B_10_HL_Y) ;
        endspecify
endmodule

module xor2a15(Y, A, B);
        output Y;
        input  A, B;
        xor g1(Y, A, B);
        // SPECIFY BLOCK
        specify
                specparam A_01_LH_Y = 0, A_01_HL_Y = 0 ;
                specparam A_10_LH_Y = 0, A_10_HL_Y = 0 ;
                specparam B_01_LH_Y = 0, B_01_HL_Y = 0 ;
                specparam B_10_LH_Y = 0, B_10_HL_Y = 0 ;
                (posedge A *> (Y : 1'b1)) = (A_01_LH_Y, A_01_HL_Y) ;
                (negedge A *> (Y : 1'b1)) = (A_10_LH_Y, A_10_HL_Y) ;
                (posedge B *> (Y : 1'b1)) = (B_01_LH_Y, B_01_HL_Y) ;
                (negedge B *> (Y : 1'b1)) = (B_10_LH_Y, B_10_HL_Y) ;
        endspecify
endmodule

module xor2a2(Y, A, B);
        output Y;
        input  A, B;
        xor g1(Y, A, B);
        // SPECIFY BLOCK
        specify
                specparam A_01_LH_Y = 0, A_01_HL_Y = 0 ;
                specparam A_10_LH_Y = 0, A_10_HL_Y = 0 ;
                specparam B_01_LH_Y = 0, B_01_HL_Y = 0 ;
                specparam B_10_LH_Y = 0, B_10_HL_Y = 0 ;
                (posedge A *> (Y : 1'b1)) = (A_01_LH_Y, A_01_HL_Y) ;
                (negedge A *> (Y : 1'b1)) = (A_10_LH_Y, A_10_HL_Y) ;
                (posedge B *> (Y : 1'b1)) = (B_01_LH_Y, B_01_HL_Y) ;
                (negedge B *> (Y : 1'b1)) = (B_10_LH_Y, B_10_HL_Y) ;
        endspecify
endmodule

module xor2a3(Y, A, B);
        output Y;
        input  A, B;
        xor g1(Y, A, B);
        // SPECIFY BLOCK
        specify
                specparam A_01_LH_Y = 0, A_01_HL_Y = 0 ;
                specparam A_10_LH_Y = 0, A_10_HL_Y = 0 ;
                specparam B_01_LH_Y = 0, B_01_HL_Y = 0 ;
                specparam B_10_LH_Y = 0, B_10_HL_Y = 0 ;
                (posedge A *> (Y : 1'b1)) = (A_01_LH_Y, A_01_HL_Y) ;
                (negedge A *> (Y : 1'b1)) = (A_10_LH_Y, A_10_HL_Y) ;
                (posedge B *> (Y : 1'b1)) = (B_01_LH_Y, B_01_HL_Y) ;
                (negedge B *> (Y : 1'b1)) = (B_10_LH_Y, B_10_HL_Y) ;
        endspecify
endmodule

module xor2a6(Y, A, B);
        output Y;
        input  A, B;
        xor g1(Y, A, B);
        // SPECIFY BLOCK
        specify
                specparam A_01_LH_Y = 0, A_01_HL_Y = 0 ;
                specparam A_10_LH_Y = 0, A_10_HL_Y = 0 ;
                specparam B_01_LH_Y = 0, B_01_HL_Y = 0 ;
                specparam B_10_LH_Y = 0, B_10_HL_Y = 0 ;
                (posedge A *> (Y : 1'b1)) = (A_01_LH_Y, A_01_HL_Y) ;
                (negedge A *> (Y : 1'b1)) = (A_10_LH_Y, A_10_HL_Y) ;
                (posedge B *> (Y : 1'b1)) = (B_01_LH_Y, B_01_HL_Y) ;
                (negedge B *> (Y : 1'b1)) = (B_10_LH_Y, B_10_HL_Y) ;
        endspecify
endmodule

module xor2a9(Y, A, B);
        output Y;
        input  A, B;
        xor g1(Y, A, B);
        // SPECIFY BLOCK
        specify
                specparam A_01_LH_Y = 0, A_01_HL_Y = 0 ;
                specparam A_10_LH_Y = 0, A_10_HL_Y = 0 ;
                specparam B_01_LH_Y = 0, B_01_HL_Y = 0 ;
                specparam B_10_LH_Y = 0, B_10_HL_Y = 0 ;
                (posedge A *> (Y : 1'b1)) = (A_01_LH_Y, A_01_HL_Y) ;
                (negedge A *> (Y : 1'b1)) = (A_10_LH_Y, A_10_HL_Y) ;
                (posedge B *> (Y : 1'b1)) = (B_01_LH_Y, B_01_HL_Y) ;
                (negedge B *> (Y : 1'b1)) = (B_10_LH_Y, B_10_HL_Y) ;
        endspecify
endmodule

module xor2b1(Y, A, B);
        output Y;
        input  A, B;
        xnor g1(Y, A, B);
        // SPECIFY BLOCK
        specify
                specparam A_01_LH_Y = 0, A_01_HL_Y = 0 ;
                specparam A_10_LH_Y = 0, A_10_HL_Y = 0 ;
                specparam B_01_LH_Y = 0, B_01_HL_Y = 0 ;
                specparam B_10_LH_Y = 0, B_10_HL_Y = 0 ;
                (posedge A *> (Y : 1'b1)) = (A_01_LH_Y, A_01_HL_Y) ;
                (negedge A *> (Y : 1'b1)) = (A_10_LH_Y, A_10_HL_Y) ;
                (posedge B *> (Y : 1'b1)) = (B_01_LH_Y, B_01_HL_Y) ;
                (negedge B *> (Y : 1'b1)) = (B_10_LH_Y, B_10_HL_Y) ;
        endspecify
endmodule

module xor2b15(Y, A, B);
        output Y;
        input  A, B;
        xnor g1(Y, A, B);
        // SPECIFY BLOCK
        specify
                specparam A_01_LH_Y = 0, A_01_HL_Y = 0 ;
                specparam A_10_LH_Y = 0, A_10_HL_Y = 0 ;
                specparam B_01_LH_Y = 0, B_01_HL_Y = 0 ;
                specparam B_10_LH_Y = 0, B_10_HL_Y = 0 ;
                (posedge A *> (Y : 1'b1)) = (A_01_LH_Y, A_01_HL_Y) ;
                (negedge A *> (Y : 1'b1)) = (A_10_LH_Y, A_10_HL_Y) ;
                (posedge B *> (Y : 1'b1)) = (B_01_LH_Y, B_01_HL_Y) ;
                (negedge B *> (Y : 1'b1)) = (B_10_LH_Y, B_10_HL_Y) ;
        endspecify
endmodule

module xor2b2(Y, A, B);
        output Y;
        input  A, B;
        xnor g1(Y, A, B);
        // SPECIFY BLOCK
        specify
                specparam A_01_LH_Y = 0, A_01_HL_Y = 0 ;
                specparam A_10_LH_Y = 0, A_10_HL_Y = 0 ;
                specparam B_01_LH_Y = 0, B_01_HL_Y = 0 ;
                specparam B_10_LH_Y = 0, B_10_HL_Y = 0 ;
                (posedge A *> (Y : 1'b1)) = (A_01_LH_Y, A_01_HL_Y) ;
                (negedge A *> (Y : 1'b1)) = (A_10_LH_Y, A_10_HL_Y) ;
                (posedge B *> (Y : 1'b1)) = (B_01_LH_Y, B_01_HL_Y) ;
                (negedge B *> (Y : 1'b1)) = (B_10_LH_Y, B_10_HL_Y) ;
        endspecify
endmodule

module xor2b3(Y, A, B);
        output Y;
        input  A, B;
        xnor g1(Y, A, B);
        // SPECIFY BLOCK
        specify
                specparam A_01_LH_Y = 0, A_01_HL_Y = 0 ;
                specparam A_10_LH_Y = 0, A_10_HL_Y = 0 ;
                specparam B_01_LH_Y = 0, B_01_HL_Y = 0 ;
                specparam B_10_LH_Y = 0, B_10_HL_Y = 0 ;
                (posedge A *> (Y : 1'b1)) = (A_01_LH_Y, A_01_HL_Y) ;
                (negedge A *> (Y : 1'b1)) = (A_10_LH_Y, A_10_HL_Y) ;
                (posedge B *> (Y : 1'b1)) = (B_01_LH_Y, B_01_HL_Y) ;
                (negedge B *> (Y : 1'b1)) = (B_10_LH_Y, B_10_HL_Y) ;
        endspecify
endmodule

module xor2b6(Y, A, B);
        output Y;
        input  A, B;
        xnor g1(Y, A, B);
        // SPECIFY BLOCK
        specify
                specparam A_01_LH_Y = 0, A_01_HL_Y = 0 ;
                specparam A_10_LH_Y = 0, A_10_HL_Y = 0 ;
                specparam B_01_LH_Y = 0, B_01_HL_Y = 0 ;
                specparam B_10_LH_Y = 0, B_10_HL_Y = 0 ;
                (posedge A *> (Y : 1'b1)) = (A_01_LH_Y, A_01_HL_Y) ;
                (negedge A *> (Y : 1'b1)) = (A_10_LH_Y, A_10_HL_Y) ;
                (posedge B *> (Y : 1'b1)) = (B_01_LH_Y, B_01_HL_Y) ;
                (negedge B *> (Y : 1'b1)) = (B_10_LH_Y, B_10_HL_Y) ;
        endspecify
endmodule

module xor2b9(Y, A, B);
        output Y;
        input  A, B;
        xnor g1(Y, A, B);
        // SPECIFY BLOCK
        specify
                specparam A_01_LH_Y = 0, A_01_HL_Y = 0 ;
                specparam A_10_LH_Y = 0, A_10_HL_Y = 0 ;
                specparam B_01_LH_Y = 0, B_01_HL_Y = 0 ;
                specparam B_10_LH_Y = 0, B_10_HL_Y = 0 ;
                (posedge A *> (Y : 1'b1)) = (A_01_LH_Y, A_01_HL_Y) ;
                (negedge A *> (Y : 1'b1)) = (A_10_LH_Y, A_10_HL_Y) ;
                (posedge B *> (Y : 1'b1)) = (B_01_LH_Y, B_01_HL_Y) ;
                (negedge B *> (Y : 1'b1)) = (B_10_LH_Y, B_10_HL_Y) ;
        endspecify
endmodule

module xor3a1(Y, A, B, C);
        output Y;
        input  A, B, C;
        xor g1(Y, B, C, A);
        // SPECIFY BLOCK
        specify
                specparam A_01_LH_Y = 0, A_01_HL_Y = 0 ;
                specparam A_10_LH_Y = 0, A_10_HL_Y = 0 ;
                specparam B_01_LH_Y = 0, B_01_HL_Y = 0 ;
                specparam B_10_LH_Y = 0, B_10_HL_Y = 0 ;
                specparam C_01_LH_Y = 0, C_01_HL_Y = 0 ;
                specparam C_10_LH_Y = 0, C_10_HL_Y = 0 ;
                (posedge A *> (Y : 1'b1)) = (A_01_LH_Y, A_01_HL_Y) ;
                (negedge A *> (Y : 1'b1)) = (A_10_LH_Y, A_10_HL_Y) ;
                (posedge B *> (Y : 1'b1)) = (B_01_LH_Y, B_01_HL_Y) ;
                (negedge B *> (Y : 1'b1)) = (B_10_LH_Y, B_10_HL_Y) ;
                (posedge C *> (Y : 1'b1)) = (C_01_LH_Y, C_01_HL_Y) ;
                (negedge C *> (Y : 1'b1)) = (C_10_LH_Y, C_10_HL_Y) ;
        endspecify
endmodule

module xor3a15(Y, A, B, C);
        output Y;
        input  A, B, C;
        xor g1(Y, B, C, A);
        // SPECIFY BLOCK
        specify
                specparam A_01_LH_Y = 0, A_01_HL_Y = 0 ;
                specparam A_10_LH_Y = 0, A_10_HL_Y = 0 ;
                specparam B_01_LH_Y = 0, B_01_HL_Y = 0 ;
                specparam B_10_LH_Y = 0, B_10_HL_Y = 0 ;
                specparam C_01_LH_Y = 0, C_01_HL_Y = 0 ;
                specparam C_10_LH_Y = 0, C_10_HL_Y = 0 ;
                (posedge A *> (Y : 1'b1)) = (A_01_LH_Y, A_01_HL_Y) ;
                (negedge A *> (Y : 1'b1)) = (A_10_LH_Y, A_10_HL_Y) ;
                (posedge B *> (Y : 1'b1)) = (B_01_LH_Y, B_01_HL_Y) ;
                (negedge B *> (Y : 1'b1)) = (B_10_LH_Y, B_10_HL_Y) ;
                (posedge C *> (Y : 1'b1)) = (C_01_LH_Y, C_01_HL_Y) ;
                (negedge C *> (Y : 1'b1)) = (C_10_LH_Y, C_10_HL_Y) ;
        endspecify
endmodule

module xor3a2(Y, A, B, C);
        output Y;
        input  A, B, C;
        xor g1(Y, B, C, A);
        // SPECIFY BLOCK
        specify
                specparam A_01_LH_Y = 0, A_01_HL_Y = 0 ;
                specparam A_10_LH_Y = 0, A_10_HL_Y = 0 ;
                specparam B_01_LH_Y = 0, B_01_HL_Y = 0 ;
                specparam B_10_LH_Y = 0, B_10_HL_Y = 0 ;
                specparam C_01_LH_Y = 0, C_01_HL_Y = 0 ;
                specparam C_10_LH_Y = 0, C_10_HL_Y = 0 ;
                (posedge A *> (Y : 1'b1)) = (A_01_LH_Y, A_01_HL_Y) ;
                (negedge A *> (Y : 1'b1)) = (A_10_LH_Y, A_10_HL_Y) ;
                (posedge B *> (Y : 1'b1)) = (B_01_LH_Y, B_01_HL_Y) ;
                (negedge B *> (Y : 1'b1)) = (B_10_LH_Y, B_10_HL_Y) ;
                (posedge C *> (Y : 1'b1)) = (C_01_LH_Y, C_01_HL_Y) ;
                (negedge C *> (Y : 1'b1)) = (C_10_LH_Y, C_10_HL_Y) ;
        endspecify
endmodule

module xor3a3(Y, A, B, C);
        output Y;
        input  A, B, C;
        xor g1(Y, B, C, A);
        // SPECIFY BLOCK
        specify
                specparam A_01_LH_Y = 0, A_01_HL_Y = 0 ;
                specparam A_10_LH_Y = 0, A_10_HL_Y = 0 ;
                specparam B_01_LH_Y = 0, B_01_HL_Y = 0 ;
                specparam B_10_LH_Y = 0, B_10_HL_Y = 0 ;
                specparam C_01_LH_Y = 0, C_01_HL_Y = 0 ;
                specparam C_10_LH_Y = 0, C_10_HL_Y = 0 ;
                (posedge A *> (Y : 1'b1)) = (A_01_LH_Y, A_01_HL_Y) ;
                (negedge A *> (Y : 1'b1)) = (A_10_LH_Y, A_10_HL_Y) ;
                (posedge B *> (Y : 1'b1)) = (B_01_LH_Y, B_01_HL_Y) ;
                (negedge B *> (Y : 1'b1)) = (B_10_LH_Y, B_10_HL_Y) ;
                (posedge C *> (Y : 1'b1)) = (C_01_LH_Y, C_01_HL_Y) ;
                (negedge C *> (Y : 1'b1)) = (C_10_LH_Y, C_10_HL_Y) ;
        endspecify
endmodule

module xor3a6(Y, A, B, C);
        output Y;
        input  A, B, C;
        xor g1(Y, B, C, A);
        // SPECIFY BLOCK
        specify
                specparam A_01_LH_Y = 0, A_01_HL_Y = 0 ;
                specparam A_10_LH_Y = 0, A_10_HL_Y = 0 ;
                specparam B_01_LH_Y = 0, B_01_HL_Y = 0 ;
                specparam B_10_LH_Y = 0, B_10_HL_Y = 0 ;
                specparam C_01_LH_Y = 0, C_01_HL_Y = 0 ;
                specparam C_10_LH_Y = 0, C_10_HL_Y = 0 ;
                (posedge A *> (Y : 1'b1)) = (A_01_LH_Y, A_01_HL_Y) ;
                (negedge A *> (Y : 1'b1)) = (A_10_LH_Y, A_10_HL_Y) ;
                (posedge B *> (Y : 1'b1)) = (B_01_LH_Y, B_01_HL_Y) ;
                (negedge B *> (Y : 1'b1)) = (B_10_LH_Y, B_10_HL_Y) ;
                (posedge C *> (Y : 1'b1)) = (C_01_LH_Y, C_01_HL_Y) ;
                (negedge C *> (Y : 1'b1)) = (C_10_LH_Y, C_10_HL_Y) ;
        endspecify
endmodule

module xor3a9(Y, A, B, C);
        output Y;
        input  A, B, C;
        xor g1(Y, B, C, A);
        // SPECIFY BLOCK
        specify
                specparam A_01_LH_Y = 0, A_01_HL_Y = 0 ;
                specparam A_10_LH_Y = 0, A_10_HL_Y = 0 ;
                specparam B_01_LH_Y = 0, B_01_HL_Y = 0 ;
                specparam B_10_LH_Y = 0, B_10_HL_Y = 0 ;
                specparam C_01_LH_Y = 0, C_01_HL_Y = 0 ;
                specparam C_10_LH_Y = 0, C_10_HL_Y = 0 ;
                (posedge A *> (Y : 1'b1)) = (A_01_LH_Y, A_01_HL_Y) ;
                (negedge A *> (Y : 1'b1)) = (A_10_LH_Y, A_10_HL_Y) ;
                (posedge B *> (Y : 1'b1)) = (B_01_LH_Y, B_01_HL_Y) ;
                (negedge B *> (Y : 1'b1)) = (B_10_LH_Y, B_10_HL_Y) ;
                (posedge C *> (Y : 1'b1)) = (C_01_LH_Y, C_01_HL_Y) ;
                (negedge C *> (Y : 1'b1)) = (C_10_LH_Y, C_10_HL_Y) ;
        endspecify
endmodule

module xor3b1(Y, A, B, C);
        output Y;
        input  A, B, C;
        xnor g1(Y, B, C, A);
        // SPECIFY BLOCK
        specify
                specparam A_01_LH_Y = 0, A_01_HL_Y = 0 ;
                specparam A_10_LH_Y = 0, A_10_HL_Y = 0 ;
                specparam B_01_LH_Y = 0, B_01_HL_Y = 0 ;
                specparam B_10_LH_Y = 0, B_10_HL_Y = 0 ;
                specparam C_01_LH_Y = 0, C_01_HL_Y = 0 ;
                specparam C_10_LH_Y = 0, C_10_HL_Y = 0 ;
                (posedge A *> (Y : 1'b1)) = (A_01_LH_Y, A_01_HL_Y) ;
                (negedge A *> (Y : 1'b1)) = (A_10_LH_Y, A_10_HL_Y) ;
                (posedge B *> (Y : 1'b1)) = (B_01_LH_Y, B_01_HL_Y) ;
                (negedge B *> (Y : 1'b1)) = (B_10_LH_Y, B_10_HL_Y) ;
                (posedge C *> (Y : 1'b1)) = (C_01_LH_Y, C_01_HL_Y) ;
                (negedge C *> (Y : 1'b1)) = (C_10_LH_Y, C_10_HL_Y) ;
        endspecify
endmodule

module xor3b15(Y, A, B, C);
        output Y;
        input  A, B, C;
        xnor g1(Y, B, C, A);
        // SPECIFY BLOCK
        specify
                specparam A_01_LH_Y = 0, A_01_HL_Y = 0 ;
                specparam A_10_LH_Y = 0, A_10_HL_Y = 0 ;
                specparam B_01_LH_Y = 0, B_01_HL_Y = 0 ;
                specparam B_10_LH_Y = 0, B_10_HL_Y = 0 ;
                specparam C_01_LH_Y = 0, C_01_HL_Y = 0 ;
                specparam C_10_LH_Y = 0, C_10_HL_Y = 0 ;
                (posedge A *> (Y : 1'b1)) = (A_01_LH_Y, A_01_HL_Y) ;
                (negedge A *> (Y : 1'b1)) = (A_10_LH_Y, A_10_HL_Y) ;
                (posedge B *> (Y : 1'b1)) = (B_01_LH_Y, B_01_HL_Y) ;
                (negedge B *> (Y : 1'b1)) = (B_10_LH_Y, B_10_HL_Y) ;
                (posedge C *> (Y : 1'b1)) = (C_01_LH_Y, C_01_HL_Y) ;
                (negedge C *> (Y : 1'b1)) = (C_10_LH_Y, C_10_HL_Y) ;
        endspecify
endmodule

module xor3b2(Y, A, B, C);
        output Y;
        input  A, B, C;
        xnor g1(Y, B, C, A);
        // SPECIFY BLOCK
        specify
                specparam A_01_LH_Y = 0, A_01_HL_Y = 0 ;
                specparam A_10_LH_Y = 0, A_10_HL_Y = 0 ;
                specparam B_01_LH_Y = 0, B_01_HL_Y = 0 ;
                specparam B_10_LH_Y = 0, B_10_HL_Y = 0 ;
                specparam C_01_LH_Y = 0, C_01_HL_Y = 0 ;
                specparam C_10_LH_Y = 0, C_10_HL_Y = 0 ;
                (posedge A *> (Y : 1'b1)) = (A_01_LH_Y, A_01_HL_Y) ;
                (negedge A *> (Y : 1'b1)) = (A_10_LH_Y, A_10_HL_Y) ;
                (posedge B *> (Y : 1'b1)) = (B_01_LH_Y, B_01_HL_Y) ;
                (negedge B *> (Y : 1'b1)) = (B_10_LH_Y, B_10_HL_Y) ;
                (posedge C *> (Y : 1'b1)) = (C_01_LH_Y, C_01_HL_Y) ;
                (negedge C *> (Y : 1'b1)) = (C_10_LH_Y, C_10_HL_Y) ;
        endspecify
endmodule

module xor3b3(Y, A, B, C);
        output Y;
        input  A, B, C;
        xnor g1(Y, B, C, A);
        // SPECIFY BLOCK
        specify
                specparam A_01_LH_Y = 0, A_01_HL_Y = 0 ;
                specparam A_10_LH_Y = 0, A_10_HL_Y = 0 ;
                specparam B_01_LH_Y = 0, B_01_HL_Y = 0 ;
                specparam B_10_LH_Y = 0, B_10_HL_Y = 0 ;
                specparam C_01_LH_Y = 0, C_01_HL_Y = 0 ;
                specparam C_10_LH_Y = 0, C_10_HL_Y = 0 ;
                (posedge A *> (Y : 1'b1)) = (A_01_LH_Y, A_01_HL_Y) ;
                (negedge A *> (Y : 1'b1)) = (A_10_LH_Y, A_10_HL_Y) ;
                (posedge B *> (Y : 1'b1)) = (B_01_LH_Y, B_01_HL_Y) ;
                (negedge B *> (Y : 1'b1)) = (B_10_LH_Y, B_10_HL_Y) ;
                (posedge C *> (Y : 1'b1)) = (C_01_LH_Y, C_01_HL_Y) ;
                (negedge C *> (Y : 1'b1)) = (C_10_LH_Y, C_10_HL_Y) ;
        endspecify
endmodule

module xor3b6(Y, A, B, C);
        output Y;
        input  A, B, C;
        xnor g1(Y, B, C, A);
        // SPECIFY BLOCK
        specify
                specparam A_01_LH_Y = 0, A_01_HL_Y = 0 ;
                specparam A_10_LH_Y = 0, A_10_HL_Y = 0 ;
                specparam B_01_LH_Y = 0, B_01_HL_Y = 0 ;
                specparam B_10_LH_Y = 0, B_10_HL_Y = 0 ;
                specparam C_01_LH_Y = 0, C_01_HL_Y = 0 ;
                specparam C_10_LH_Y = 0, C_10_HL_Y = 0 ;
                (posedge A *> (Y : 1'b1)) = (A_01_LH_Y, A_01_HL_Y) ;
                (negedge A *> (Y : 1'b1)) = (A_10_LH_Y, A_10_HL_Y) ;
                (posedge B *> (Y : 1'b1)) = (B_01_LH_Y, B_01_HL_Y) ;
                (negedge B *> (Y : 1'b1)) = (B_10_LH_Y, B_10_HL_Y) ;
                (posedge C *> (Y : 1'b1)) = (C_01_LH_Y, C_01_HL_Y) ;
                (negedge C *> (Y : 1'b1)) = (C_10_LH_Y, C_10_HL_Y) ;
        endspecify
endmodule

module xor3b9(Y, A, B, C);
        output Y;
        input  A, B, C;
        xnor g1(Y, B, C, A);
        // SPECIFY BLOCK
        specify
                specparam A_01_LH_Y = 0, A_01_HL_Y = 0 ;
                specparam A_10_LH_Y = 0, A_10_HL_Y = 0 ;
                specparam B_01_LH_Y = 0, B_01_HL_Y = 0 ;
                specparam B_10_LH_Y = 0, B_10_HL_Y = 0 ;
                specparam C_01_LH_Y = 0, C_01_HL_Y = 0 ;
                specparam C_10_LH_Y = 0, C_10_HL_Y = 0 ;
                (posedge A *> (Y : 1'b1)) = (A_01_LH_Y, A_01_HL_Y) ;
                (negedge A *> (Y : 1'b1)) = (A_10_LH_Y, A_10_HL_Y) ;
                (posedge B *> (Y : 1'b1)) = (B_01_LH_Y, B_01_HL_Y) ;
                (negedge B *> (Y : 1'b1)) = (B_10_LH_Y, B_10_HL_Y) ;
                (posedge C *> (Y : 1'b1)) = (C_01_LH_Y, C_01_HL_Y) ;
                (negedge C *> (Y : 1'b1)) = (C_10_LH_Y, C_10_HL_Y) ;
        endspecify
endmodule

module fac1b1(CO, A, B, CI);
        output CO;
        input  A, B, CI;
        not g1(N2, CI);
        and g2(N1, A, N2);
        not g3(N4, CI);
        and g4(N3, B, N4);
        and g5(N5, A, B);
        or g6(CO, N1, N3, N5);
        // SPECIFY BLOCK
        specify
                specparam A_LH_CO = 0, A_HL_CO = 0 ;
                specparam B_LH_CO = 0, B_HL_CO = 0 ;
                specparam CI_LH_CO = 0, CI_HL_CO = 0 ;
                (A *> CO) = (A_LH_CO, A_HL_CO) ;
                (B *> CO) = (B_LH_CO, B_HL_CO) ;
                (CI *> CO) = (CI_LH_CO, CI_HL_CO) ;
        endspecify
endmodule

module fac1b2(CO, A, B, CI);
        output CO;
        input  A, B, CI;
        not g1(N2, CI);
        and g2(N1, A, N2);
        not g3(N4, CI);
        and g4(N3, B, N4);
        and g5(N5, A, B);
        or g6(CO, N1, N3, N5);
        // SPECIFY BLOCK
        specify
                specparam A_LH_CO = 0, A_HL_CO = 0 ;
                specparam B_LH_CO = 0, B_HL_CO = 0 ;
                specparam CI_LH_CO = 0, CI_HL_CO = 0 ;
                (A *> CO) = (A_LH_CO, A_HL_CO) ;
                (B *> CO) = (B_LH_CO, B_HL_CO) ;
                (CI *> CO) = (CI_LH_CO, CI_HL_CO) ;
        endspecify
endmodule

module fac1b3(CO, A, B, CI);
        output CO;
        input  A, B, CI;
        not g1(N2, CI);
        and g2(N1, A, N2);
        not g3(N4, CI);
        and g4(N3, B, N4);
        and g5(N5, A, B);
        or g6(CO, N1, N3, N5);
        // SPECIFY BLOCK
        specify
                specparam A_LH_CO = 0, A_HL_CO = 0 ;
                specparam B_LH_CO = 0, B_HL_CO = 0 ;
                specparam CI_LH_CO = 0, CI_HL_CO = 0 ;
                (A *> CO) = (A_LH_CO, A_HL_CO) ;
                (B *> CO) = (B_LH_CO, B_HL_CO) ;
                (CI *> CO) = (CI_LH_CO, CI_HL_CO) ;
        endspecify
endmodule

module fac2a1(CO, A, B, CI);
        output CO;
        input  A, B, CI;
        and g1(N1, A, CI);
        and g2(N2, B, CI);
        and g3(N3, A, B);
        nor g4(CO, N1, N2, N3);
        // SPECIFY BLOCK
        specify
                specparam A_LH_CO = 0, A_HL_CO = 0 ;
                specparam B_LH_CO = 0, B_HL_CO = 0 ;
                specparam CI_LH_CO = 0, CI_HL_CO = 0 ;
                (A *> CO) = (A_LH_CO, A_HL_CO) ;
                (B *> CO) = (B_LH_CO, B_HL_CO) ;
                (CI *> CO) = (CI_LH_CO, CI_HL_CO) ;
        endspecify
endmodule

module fac2a2(CO, A, B, CI);
        output CO;
        input  A, B, CI;
        and g1(N1, A, CI);
        and g2(N2, B, CI);
        and g3(N3, A, B);
        nor g4(CO, N1, N2, N3);
        // SPECIFY BLOCK
        specify
                specparam A_LH_CO = 0, A_HL_CO = 0 ;
                specparam B_LH_CO = 0, B_HL_CO = 0 ;
                specparam CI_LH_CO = 0, CI_HL_CO = 0 ;
                (A *> CO) = (A_LH_CO, A_HL_CO) ;
                (B *> CO) = (B_LH_CO, B_HL_CO) ;
                (CI *> CO) = (CI_LH_CO, CI_HL_CO) ;
        endspecify
endmodule

module fac2a3(CO, A, B, CI);
        output CO;
        input  A, B, CI;
        and g1(N1, A, CI);
        and g2(N2, B, CI);
        and g3(N3, A, B);
        nor g4(CO, N1, N2, N3);
        // SPECIFY BLOCK
        specify
                specparam A_LH_CO = 0, A_HL_CO = 0 ;
                specparam B_LH_CO = 0, B_HL_CO = 0 ;
                specparam CI_LH_CO = 0, CI_HL_CO = 0 ;
                (A *> CO) = (A_LH_CO, A_HL_CO) ;
                (B *> CO) = (B_LH_CO, B_HL_CO) ;
                (CI *> CO) = (CI_LH_CO, CI_HL_CO) ;
        endspecify
endmodule

module faccs1b1(CO0, CO1, A, B, CI0, CI1);
        output CO0, CO1;
        input  A, B, CI0, CI1;
        not g1(N2, CI1);
        and g2(N1, A, N2);
        not g3(N4, CI1);
        and g4(N3, B, N4);
        and g5(N5, A, B);
        or g6(CO1, N1, N3, N5);
        not g7(N8, CI0);
        and g8(N7, A, N8);
        not g9(N10, CI0);
        and g10(N9, B, N10);
        and g11(N11, A, B);
        or g12(CO0, N7, N9, N11);
        // SPECIFY BLOCK
        specify
                specparam A_LH_CO1 = 0, A_HL_CO1 = 0 ;
                specparam B_LH_CO1 = 0, B_HL_CO1 = 0 ;
                specparam CI1_LH_CO1 = 0, CI1_HL_CO1 = 0 ;
                specparam A_LH_CO0 = 0, A_HL_CO0 = 0 ;
                specparam B_LH_CO0 = 0, B_HL_CO0 = 0 ;
                specparam CI0_LH_CO0 = 0, CI0_HL_CO0 = 0 ;
                (A *> CO1) = (A_LH_CO1, A_HL_CO1) ;
                (B *> CO1) = (B_LH_CO1, B_HL_CO1) ;
                (CI1 *> CO1) = (CI1_LH_CO1, CI1_HL_CO1) ;
                (A *> CO0) = (A_LH_CO0, A_HL_CO0) ;
                (B *> CO0) = (B_LH_CO0, B_HL_CO0) ;
                (CI0 *> CO0) = (CI0_LH_CO0, CI0_HL_CO0) ;
        endspecify
endmodule

module faccs1b2(CO0, CO1, A, B, CI0, CI1);
        output CO0, CO1;
        input  A, B, CI0, CI1;
        not g1(N2, CI1);
        and g2(N1, A, N2);
        not g3(N4, CI1);
        and g4(N3, B, N4);
        and g5(N5, A, B);
        or g6(CO1, N1, N3, N5);
        not g7(N8, CI0);
        and g8(N7, A, N8);
        not g9(N10, CI0);
        and g10(N9, B, N10);
        and g11(N11, A, B);
        or g12(CO0, N7, N9, N11);
        // SPECIFY BLOCK
        specify
                specparam A_LH_CO1 = 0, A_HL_CO1 = 0 ;
                specparam B_LH_CO1 = 0, B_HL_CO1 = 0 ;
                specparam CI1_LH_CO1 = 0, CI1_HL_CO1 = 0 ;
                specparam A_LH_CO0 = 0, A_HL_CO0 = 0 ;
                specparam B_LH_CO0 = 0, B_HL_CO0 = 0 ;
                specparam CI0_LH_CO0 = 0, CI0_HL_CO0 = 0 ;
                (A *> CO1) = (A_LH_CO1, A_HL_CO1) ;
                (B *> CO1) = (B_LH_CO1, B_HL_CO1) ;
                (CI1 *> CO1) = (CI1_LH_CO1, CI1_HL_CO1) ;
                (A *> CO0) = (A_LH_CO0, A_HL_CO0) ;
                (B *> CO0) = (B_LH_CO0, B_HL_CO0) ;
                (CI0 *> CO0) = (CI0_LH_CO0, CI0_HL_CO0) ;
        endspecify
endmodule

module faccs1b3(CO0, CO1, A, B, CI0, CI1);
        output CO0, CO1;
        input  A, B, CI0, CI1;
        not g1(N2, CI1);
        and g2(N1, A, N2);
        not g3(N4, CI1);
        and g4(N3, B, N4);
        and g5(N5, A, B);
        or g6(CO1, N1, N3, N5);
        not g7(N8, CI0);
        and g8(N7, A, N8);
        not g9(N10, CI0);
        and g10(N9, B, N10);
        and g11(N11, A, B);
        or g12(CO0, N7, N9, N11);
        // SPECIFY BLOCK
        specify
                specparam A_LH_CO1 = 0, A_HL_CO1 = 0 ;
                specparam B_LH_CO1 = 0, B_HL_CO1 = 0 ;
                specparam CI1_LH_CO1 = 0, CI1_HL_CO1 = 0 ;
                specparam A_LH_CO0 = 0, A_HL_CO0 = 0 ;
                specparam B_LH_CO0 = 0, B_HL_CO0 = 0 ;
                specparam CI0_LH_CO0 = 0, CI0_HL_CO0 = 0 ;
                (A *> CO1) = (A_LH_CO1, A_HL_CO1) ;
                (B *> CO1) = (B_LH_CO1, B_HL_CO1) ;
                (CI1 *> CO1) = (CI1_LH_CO1, CI1_HL_CO1) ;
                (A *> CO0) = (A_LH_CO0, A_HL_CO0) ;
                (B *> CO0) = (B_LH_CO0, B_HL_CO0) ;
                (CI0 *> CO0) = (CI0_LH_CO0, CI0_HL_CO0) ;
        endspecify
endmodule

module faccs2a1(CO0, CO1, A, B, CI0, CI1);
        output CO0, CO1;
        input  A, B, CI0, CI1;
        and g1(N1, A, CI0);
        and g2(N2, B, CI0);
        and g3(N3, A, B);
        nor g4(CO0, N1, N2, N3);
        and g5(N5, A, CI1);
        and g6(N6, B, CI1);
        and g7(N7, A, B);
        nor g8(CO1, N5, N6, N7);
        // SPECIFY BLOCK
        specify
                specparam A_LH_CO0 = 0, A_HL_CO0 = 0 ;
                specparam B_LH_CO0 = 0, B_HL_CO0 = 0 ;
                specparam CI0_LH_CO0 = 0, CI0_HL_CO0 = 0 ;
                specparam A_LH_CO1 = 0, A_HL_CO1 = 0 ;
                specparam B_LH_CO1 = 0, B_HL_CO1 = 0 ;
                specparam CI1_LH_CO1 = 0, CI1_HL_CO1 = 0 ;
                (A *> CO0) = (A_LH_CO0, A_HL_CO0) ;
                (B *> CO0) = (B_LH_CO0, B_HL_CO0) ;
                (CI0 *> CO0) = (CI0_LH_CO0, CI0_HL_CO0) ;
                (A *> CO1) = (A_LH_CO1, A_HL_CO1) ;
                (B *> CO1) = (B_LH_CO1, B_HL_CO1) ;
                (CI1 *> CO1) = (CI1_LH_CO1, CI1_HL_CO1) ;
        endspecify
endmodule

module faccs2a2(CO0, CO1, A, B, CI0, CI1);
        output CO0, CO1;
        input  A, B, CI0, CI1;
        and g1(N1, A, CI0);
        and g2(N2, B, CI0);
        and g3(N3, A, B);
        nor g4(CO0, N1, N2, N3);
        and g5(N5, A, CI1);
        and g6(N6, B, CI1);
        and g7(N7, A, B);
        nor g8(CO1, N5, N6, N7);
        // SPECIFY BLOCK
        specify
                specparam A_LH_CO0 = 0, A_HL_CO0 = 0 ;
                specparam B_LH_CO0 = 0, B_HL_CO0 = 0 ;
                specparam CI0_LH_CO0 = 0, CI0_HL_CO0 = 0 ;
                specparam A_LH_CO1 = 0, A_HL_CO1 = 0 ;
                specparam B_LH_CO1 = 0, B_HL_CO1 = 0 ;
                specparam CI1_LH_CO1 = 0, CI1_HL_CO1 = 0 ;
                (A *> CO0) = (A_LH_CO0, A_HL_CO0) ;
                (B *> CO0) = (B_LH_CO0, B_HL_CO0) ;
                (CI0 *> CO0) = (CI0_LH_CO0, CI0_HL_CO0) ;
                (A *> CO1) = (A_LH_CO1, A_HL_CO1) ;
                (B *> CO1) = (B_LH_CO1, B_HL_CO1) ;
                (CI1 *> CO1) = (CI1_LH_CO1, CI1_HL_CO1) ;
        endspecify
endmodule

module faccs2a3(CO0, CO1, A, B, CI0, CI1);
        output CO0, CO1;
        input  A, B, CI0, CI1;
        and g1(N1, A, CI0);
        and g2(N2, B, CI0);
        and g3(N3, A, B);
        nor g4(CO0, N1, N2, N3);
        and g5(N5, A, CI1);
        and g6(N6, B, CI1);
        and g7(N7, A, B);
        nor g8(CO1, N5, N6, N7);
        // SPECIFY BLOCK
        specify
                specparam A_LH_CO0 = 0, A_HL_CO0 = 0 ;
                specparam B_LH_CO0 = 0, B_HL_CO0 = 0 ;
                specparam CI0_LH_CO0 = 0, CI0_HL_CO0 = 0 ;
                specparam A_LH_CO1 = 0, A_HL_CO1 = 0 ;
                specparam B_LH_CO1 = 0, B_HL_CO1 = 0 ;
                specparam CI1_LH_CO1 = 0, CI1_HL_CO1 = 0 ;
                (A *> CO0) = (A_LH_CO0, A_HL_CO0) ;
                (B *> CO0) = (B_LH_CO0, B_HL_CO0) ;
                (CI0 *> CO0) = (CI0_LH_CO0, CI0_HL_CO0) ;
                (A *> CO1) = (A_LH_CO1, A_HL_CO1) ;
                (B *> CO1) = (B_LH_CO1, B_HL_CO1) ;
                (CI1 *> CO1) = (CI1_LH_CO1, CI1_HL_CO1) ;
        endspecify
endmodule

module faccs3a1(CO0, CO1, A, B);
        output CO0, CO1;
        input  A, B;
        nand g1(CO0, A, B);
        nor g2(CO1, A, B);
        // SPECIFY BLOCK
        specify
                specparam A_LH_CO0 = 0, A_HL_CO0 = 0 ;
                specparam B_LH_CO0 = 0, B_HL_CO0 = 0 ;
                specparam A_LH_CO1 = 0, A_HL_CO1 = 0 ;
                specparam B_LH_CO1 = 0, B_HL_CO1 = 0 ;
                (A *> CO0) = (A_LH_CO0, A_HL_CO0) ;
                (B *> CO0) = (B_LH_CO0, B_HL_CO0) ;
                (A *> CO1) = (A_LH_CO1, A_HL_CO1) ;
                (B *> CO1) = (B_LH_CO1, B_HL_CO1) ;
        endspecify
endmodule

module faccs3a2(CO0, CO1, A, B);
        output CO0, CO1;
        input  A, B;
        nand g1(CO0, A, B);
        nor g2(CO1, A, B);
        // SPECIFY BLOCK
        specify
                specparam A_LH_CO0 = 0, A_HL_CO0 = 0 ;
                specparam B_LH_CO0 = 0, B_HL_CO0 = 0 ;
                specparam A_LH_CO1 = 0, A_HL_CO1 = 0 ;
                specparam B_LH_CO1 = 0, B_HL_CO1 = 0 ;
                (A *> CO0) = (A_LH_CO0, A_HL_CO0) ;
                (B *> CO0) = (B_LH_CO0, B_HL_CO0) ;
                (A *> CO1) = (A_LH_CO1, A_HL_CO1) ;
                (B *> CO1) = (B_LH_CO1, B_HL_CO1) ;
        endspecify
endmodule

module faccs3a3(CO0, CO1, A, B);
        output CO0, CO1;
        input  A, B;
        nand g1(CO0, A, B);
        nor g2(CO1, A, B);
        // SPECIFY BLOCK
        specify
                specparam A_LH_CO0 = 0, A_HL_CO0 = 0 ;
                specparam B_LH_CO0 = 0, B_HL_CO0 = 0 ;
                specparam A_LH_CO1 = 0, A_HL_CO1 = 0 ;
                specparam B_LH_CO1 = 0, B_HL_CO1 = 0 ;
                (A *> CO0) = (A_LH_CO0, A_HL_CO0) ;
                (B *> CO0) = (B_LH_CO0, B_HL_CO0) ;
                (A *> CO1) = (A_LH_CO1, A_HL_CO1) ;
                (B *> CO1) = (B_LH_CO1, B_HL_CO1) ;
        endspecify
endmodule

module facs1b1(S, CO0, CO1, A, B, CI0, CI1, CSIN);
        output S, CO0, CO1;
        input  A, B, CI0, CI1, CSIN;
        not g1(N2, CI1);
        xor g2(N1, B, N2, A);
        not g3(N4, CI0);
        xor g4(N3, B, N4, A);
        mux g5(S, CSIN, N1, N3);
        not g6(N7, CI1);
        and g7(N6, A, N7);
        not g8(N9, CI1);
        and g9(N8, B, N9);
        and g10(N10, A, B);
        or g11(CO1, N6, N8, N10);
        not g12(N13, CI0);
        and g13(N12, A, N13);
        not g14(N15, CI0);
        and g15(N14, B, N15);
        and g16(N16, A, B);
        or g17(CO0, N12, N14, N16);
        // SPECIFY BLOCK
        specify
                specparam CSIN_01_LH_S = 0, CSIN_01_HL_S = 0 ;
                specparam CSIN_10_LH_S = 0, CSIN_10_HL_S = 0 ;
                specparam A_01_LH_S = 0, A_01_HL_S = 0 ;
                specparam A_10_LH_S = 0, A_10_HL_S = 0 ;
                specparam B_01_LH_S = 0, B_01_HL_S = 0 ;
                specparam B_10_LH_S = 0, B_10_HL_S = 0 ;
                specparam CI1_01_LH_S = 0, CI1_01_HL_S = 0 ;
                specparam CI1_10_LH_S = 0, CI1_10_HL_S = 0 ;
                specparam CI0_01_LH_S = 0, CI0_01_HL_S = 0 ;
                specparam CI0_10_LH_S = 0, CI0_10_HL_S = 0 ;
                specparam A_LH_CO1 = 0, A_HL_CO1 = 0 ;
                specparam B_LH_CO1 = 0, B_HL_CO1 = 0 ;
                specparam CI1_LH_CO1 = 0, CI1_HL_CO1 = 0 ;
                specparam A_LH_CO0 = 0, A_HL_CO0 = 0 ;
                specparam B_LH_CO0 = 0, B_HL_CO0 = 0 ;
                specparam CI0_LH_CO0 = 0, CI0_HL_CO0 = 0 ;
                (posedge CSIN *> (S : 1'b1)) = (CSIN_01_LH_S, CSIN_01_HL_S) ;
                (negedge CSIN *> (S : 1'b1)) = (CSIN_10_LH_S, CSIN_10_HL_S) ;
                (posedge A *> (S : 1'b1)) = (A_01_LH_S, A_01_HL_S) ;
                (negedge A *> (S : 1'b1)) = (A_10_LH_S, A_10_HL_S) ;
                (posedge B *> (S : 1'b1)) = (B_01_LH_S, B_01_HL_S) ;
                (negedge B *> (S : 1'b1)) = (B_10_LH_S, B_10_HL_S) ;
                (posedge CI1 *> (S : 1'b1)) = (CI1_01_LH_S, CI1_01_HL_S) ;
                (negedge CI1 *> (S : 1'b1)) = (CI1_10_LH_S, CI1_10_HL_S) ;
                (posedge CI0 *> (S : 1'b1)) = (CI0_01_LH_S, CI0_01_HL_S) ;
                (negedge CI0 *> (S : 1'b1)) = (CI0_10_LH_S, CI0_10_HL_S) ;
                (A *> CO1) = (A_LH_CO1, A_HL_CO1) ;
                (B *> CO1) = (B_LH_CO1, B_HL_CO1) ;
                (CI1 *> CO1) = (CI1_LH_CO1, CI1_HL_CO1) ;
                (A *> CO0) = (A_LH_CO0, A_HL_CO0) ;
                (B *> CO0) = (B_LH_CO0, B_HL_CO0) ;
                (CI0 *> CO0) = (CI0_LH_CO0, CI0_HL_CO0) ;
        endspecify
endmodule

module facs1b2(S, CO0, CO1, A, B, CI0, CI1, CSIN);
        output S, CO0, CO1;
        input  A, B, CI0, CI1, CSIN;
        not g1(N2, CI1);
        xor g2(N1, B, N2, A);
        not g3(N4, CI0);
        xor g4(N3, B, N4, A);
        mux g5(S, CSIN, N1, N3);
        not g6(N7, CI1);
        and g7(N6, A, N7);
        not g8(N9, CI1);
        and g9(N8, B, N9);
        and g10(N10, A, B);
        or g11(CO1, N6, N8, N10);
        not g12(N13, CI0);
        and g13(N12, A, N13);
        not g14(N15, CI0);
        and g15(N14, B, N15);
        and g16(N16, A, B);
        or g17(CO0, N12, N14, N16);
        // SPECIFY BLOCK
        specify
                specparam CSIN_01_LH_S = 0, CSIN_01_HL_S = 0 ;
                specparam CSIN_10_LH_S = 0, CSIN_10_HL_S = 0 ;
                specparam A_01_LH_S = 0, A_01_HL_S = 0 ;
                specparam A_10_LH_S = 0, A_10_HL_S = 0 ;
                specparam B_01_LH_S = 0, B_01_HL_S = 0 ;
                specparam B_10_LH_S = 0, B_10_HL_S = 0 ;
                specparam CI1_01_LH_S = 0, CI1_01_HL_S = 0 ;
                specparam CI1_10_LH_S = 0, CI1_10_HL_S = 0 ;
                specparam CI0_01_LH_S = 0, CI0_01_HL_S = 0 ;
                specparam CI0_10_LH_S = 0, CI0_10_HL_S = 0 ;
                specparam A_LH_CO1 = 0, A_HL_CO1 = 0 ;
                specparam B_LH_CO1 = 0, B_HL_CO1 = 0 ;
                specparam CI1_LH_CO1 = 0, CI1_HL_CO1 = 0 ;
                specparam A_LH_CO0 = 0, A_HL_CO0 = 0 ;
                specparam B_LH_CO0 = 0, B_HL_CO0 = 0 ;
                specparam CI0_LH_CO0 = 0, CI0_HL_CO0 = 0 ;
                (posedge CSIN *> (S : 1'b1)) = (CSIN_01_LH_S, CSIN_01_HL_S) ;
                (negedge CSIN *> (S : 1'b1)) = (CSIN_10_LH_S, CSIN_10_HL_S) ;
                (posedge A *> (S : 1'b1)) = (A_01_LH_S, A_01_HL_S) ;
                (negedge A *> (S : 1'b1)) = (A_10_LH_S, A_10_HL_S) ;
                (posedge B *> (S : 1'b1)) = (B_01_LH_S, B_01_HL_S) ;
                (negedge B *> (S : 1'b1)) = (B_10_LH_S, B_10_HL_S) ;
                (posedge CI1 *> (S : 1'b1)) = (CI1_01_LH_S, CI1_01_HL_S) ;
                (negedge CI1 *> (S : 1'b1)) = (CI1_10_LH_S, CI1_10_HL_S) ;
                (posedge CI0 *> (S : 1'b1)) = (CI0_01_LH_S, CI0_01_HL_S) ;
                (negedge CI0 *> (S : 1'b1)) = (CI0_10_LH_S, CI0_10_HL_S) ;
                (A *> CO1) = (A_LH_CO1, A_HL_CO1) ;
                (B *> CO1) = (B_LH_CO1, B_HL_CO1) ;
                (CI1 *> CO1) = (CI1_LH_CO1, CI1_HL_CO1) ;
                (A *> CO0) = (A_LH_CO0, A_HL_CO0) ;
                (B *> CO0) = (B_LH_CO0, B_HL_CO0) ;
                (CI0 *> CO0) = (CI0_LH_CO0, CI0_HL_CO0) ;
        endspecify
endmodule

module facs1b3(S, CO0, CO1, A, B, CI0, CI1, CSIN);
        output S, CO0, CO1;
        input  A, B, CI0, CI1, CSIN;
        not g1(N2, CI1);
        xor g2(N1, B, N2, A);
        not g3(N4, CI0);
        xor g4(N3, B, N4, A);
        mux g5(S, CSIN, N1, N3);
        not g6(N7, CI1);
        and g7(N6, A, N7);
        not g8(N9, CI1);
        and g9(N8, B, N9);
        and g10(N10, A, B);
        or g11(CO1, N6, N8, N10);
        not g12(N13, CI0);
        and g13(N12, A, N13);
        not g14(N15, CI0);
        and g15(N14, B, N15);
        and g16(N16, A, B);
        or g17(CO0, N12, N14, N16);
        // SPECIFY BLOCK
        specify
                specparam CSIN_01_LH_S = 0, CSIN_01_HL_S = 0 ;
                specparam CSIN_10_LH_S = 0, CSIN_10_HL_S = 0 ;
                specparam A_01_LH_S = 0, A_01_HL_S = 0 ;
                specparam A_10_LH_S = 0, A_10_HL_S = 0 ;
                specparam B_01_LH_S = 0, B_01_HL_S = 0 ;
                specparam B_10_LH_S = 0, B_10_HL_S = 0 ;
                specparam CI1_01_LH_S = 0, CI1_01_HL_S = 0 ;
                specparam CI1_10_LH_S = 0, CI1_10_HL_S = 0 ;
                specparam CI0_01_LH_S = 0, CI0_01_HL_S = 0 ;
                specparam CI0_10_LH_S = 0, CI0_10_HL_S = 0 ;
                specparam A_LH_CO1 = 0, A_HL_CO1 = 0 ;
                specparam B_LH_CO1 = 0, B_HL_CO1 = 0 ;
                specparam CI1_LH_CO1 = 0, CI1_HL_CO1 = 0 ;
                specparam A_LH_CO0 = 0, A_HL_CO0 = 0 ;
                specparam B_LH_CO0 = 0, B_HL_CO0 = 0 ;
                specparam CI0_LH_CO0 = 0, CI0_HL_CO0 = 0 ;
                (posedge CSIN *> (S : 1'b1)) = (CSIN_01_LH_S, CSIN_01_HL_S) ;
                (negedge CSIN *> (S : 1'b1)) = (CSIN_10_LH_S, CSIN_10_HL_S) ;
                (posedge A *> (S : 1'b1)) = (A_01_LH_S, A_01_HL_S) ;
                (negedge A *> (S : 1'b1)) = (A_10_LH_S, A_10_HL_S) ;
                (posedge B *> (S : 1'b1)) = (B_01_LH_S, B_01_HL_S) ;
                (negedge B *> (S : 1'b1)) = (B_10_LH_S, B_10_HL_S) ;
                (posedge CI1 *> (S : 1'b1)) = (CI1_01_LH_S, CI1_01_HL_S) ;
                (negedge CI1 *> (S : 1'b1)) = (CI1_10_LH_S, CI1_10_HL_S) ;
                (posedge CI0 *> (S : 1'b1)) = (CI0_01_LH_S, CI0_01_HL_S) ;
                (negedge CI0 *> (S : 1'b1)) = (CI0_10_LH_S, CI0_10_HL_S) ;
                (A *> CO1) = (A_LH_CO1, A_HL_CO1) ;
                (B *> CO1) = (B_LH_CO1, B_HL_CO1) ;
                (CI1 *> CO1) = (CI1_LH_CO1, CI1_HL_CO1) ;
                (A *> CO0) = (A_LH_CO0, A_HL_CO0) ;
                (B *> CO0) = (B_LH_CO0, B_HL_CO0) ;
                (CI0 *> CO0) = (CI0_LH_CO0, CI0_HL_CO0) ;
        endspecify
endmodule

module facs2a1(S, CO0, CO1, A, B, CI0, CI1, CSIN);
        output S, CO0, CO1;
        input  A, B, CI0, CI1, CSIN;
        xor g1(N1, B, CI1, A);
        xor g2(N2, B, CI0, A);
        mux g3(S, CSIN, N1, N2);
        and g4(N4, A, CI0);
        and g5(N5, B, CI0);
        and g6(N6, A, B);
        nor g7(CO0, N4, N5, N6);
        and g8(N8, A, CI1);
        and g9(N9, B, CI1);
        and g10(N10, A, B);
        nor g11(CO1, N8, N9, N10);
        // SPECIFY BLOCK
        specify
                specparam CSIN_01_LH_S = 0, CSIN_01_HL_S = 0 ;
                specparam CSIN_10_LH_S = 0, CSIN_10_HL_S = 0 ;
                specparam A_01_LH_S = 0, A_01_HL_S = 0 ;
                specparam A_10_LH_S = 0, A_10_HL_S = 0 ;
                specparam B_01_LH_S = 0, B_01_HL_S = 0 ;
                specparam B_10_LH_S = 0, B_10_HL_S = 0 ;
                specparam CI1_01_LH_S = 0, CI1_01_HL_S = 0 ;
                specparam CI1_10_LH_S = 0, CI1_10_HL_S = 0 ;
                specparam CI0_01_LH_S = 0, CI0_01_HL_S = 0 ;
                specparam CI0_10_LH_S = 0, CI0_10_HL_S = 0 ;
                specparam A_LH_CO0 = 0, A_HL_CO0 = 0 ;
                specparam B_LH_CO0 = 0, B_HL_CO0 = 0 ;
                specparam CI0_LH_CO0 = 0, CI0_HL_CO0 = 0 ;
                specparam A_LH_CO1 = 0, A_HL_CO1 = 0 ;
                specparam B_LH_CO1 = 0, B_HL_CO1 = 0 ;
                specparam CI1_LH_CO1 = 0, CI1_HL_CO1 = 0 ;
                (posedge CSIN *> (S : 1'b1)) = (CSIN_01_LH_S, CSIN_01_HL_S) ;
                (negedge CSIN *> (S : 1'b1)) = (CSIN_10_LH_S, CSIN_10_HL_S) ;
                (posedge A *> (S : 1'b1)) = (A_01_LH_S, A_01_HL_S) ;
                (negedge A *> (S : 1'b1)) = (A_10_LH_S, A_10_HL_S) ;
                (posedge B *> (S : 1'b1)) = (B_01_LH_S, B_01_HL_S) ;
                (negedge B *> (S : 1'b1)) = (B_10_LH_S, B_10_HL_S) ;
                (posedge CI1 *> (S : 1'b1)) = (CI1_01_LH_S, CI1_01_HL_S) ;
                (negedge CI1 *> (S : 1'b1)) = (CI1_10_LH_S, CI1_10_HL_S) ;
                (posedge CI0 *> (S : 1'b1)) = (CI0_01_LH_S, CI0_01_HL_S) ;
                (negedge CI0 *> (S : 1'b1)) = (CI0_10_LH_S, CI0_10_HL_S) ;
                (A *> CO0) = (A_LH_CO0, A_HL_CO0) ;
                (B *> CO0) = (B_LH_CO0, B_HL_CO0) ;
                (CI0 *> CO0) = (CI0_LH_CO0, CI0_HL_CO0) ;
                (A *> CO1) = (A_LH_CO1, A_HL_CO1) ;
                (B *> CO1) = (B_LH_CO1, B_HL_CO1) ;
                (CI1 *> CO1) = (CI1_LH_CO1, CI1_HL_CO1) ;
        endspecify
endmodule

module facs2a2(S, CO0, CO1, A, B, CI0, CI1, CSIN);
        output S, CO0, CO1;
        input  A, B, CI0, CI1, CSIN;
        xor g1(N1, B, CI1, A);
        xor g2(N2, B, CI0, A);
        mux g3(S, CSIN, N1, N2);
        and g4(N4, A, CI0);
        and g5(N5, B, CI0);
        and g6(N6, A, B);
        nor g7(CO0, N4, N5, N6);
        and g8(N8, A, CI1);
        and g9(N9, B, CI1);
        and g10(N10, A, B);
        nor g11(CO1, N8, N9, N10);
        // SPECIFY BLOCK
        specify
                specparam CSIN_01_LH_S = 0, CSIN_01_HL_S = 0 ;
                specparam CSIN_10_LH_S = 0, CSIN_10_HL_S = 0 ;
                specparam A_01_LH_S = 0, A_01_HL_S = 0 ;
                specparam A_10_LH_S = 0, A_10_HL_S = 0 ;
                specparam B_01_LH_S = 0, B_01_HL_S = 0 ;
                specparam B_10_LH_S = 0, B_10_HL_S = 0 ;
                specparam CI1_01_LH_S = 0, CI1_01_HL_S = 0 ;
                specparam CI1_10_LH_S = 0, CI1_10_HL_S = 0 ;
                specparam CI0_01_LH_S = 0, CI0_01_HL_S = 0 ;
                specparam CI0_10_LH_S = 0, CI0_10_HL_S = 0 ;
                specparam A_LH_CO0 = 0, A_HL_CO0 = 0 ;
                specparam B_LH_CO0 = 0, B_HL_CO0 = 0 ;
                specparam CI0_LH_CO0 = 0, CI0_HL_CO0 = 0 ;
                specparam A_LH_CO1 = 0, A_HL_CO1 = 0 ;
                specparam B_LH_CO1 = 0, B_HL_CO1 = 0 ;
                specparam CI1_LH_CO1 = 0, CI1_HL_CO1 = 0 ;
                (posedge CSIN *> (S : 1'b1)) = (CSIN_01_LH_S, CSIN_01_HL_S) ;
                (negedge CSIN *> (S : 1'b1)) = (CSIN_10_LH_S, CSIN_10_HL_S) ;
                (posedge A *> (S : 1'b1)) = (A_01_LH_S, A_01_HL_S) ;
                (negedge A *> (S : 1'b1)) = (A_10_LH_S, A_10_HL_S) ;
                (posedge B *> (S : 1'b1)) = (B_01_LH_S, B_01_HL_S) ;
                (negedge B *> (S : 1'b1)) = (B_10_LH_S, B_10_HL_S) ;
                (posedge CI1 *> (S : 1'b1)) = (CI1_01_LH_S, CI1_01_HL_S) ;
                (negedge CI1 *> (S : 1'b1)) = (CI1_10_LH_S, CI1_10_HL_S) ;
                (posedge CI0 *> (S : 1'b1)) = (CI0_01_LH_S, CI0_01_HL_S) ;
                (negedge CI0 *> (S : 1'b1)) = (CI0_10_LH_S, CI0_10_HL_S) ;
                (A *> CO0) = (A_LH_CO0, A_HL_CO0) ;
                (B *> CO0) = (B_LH_CO0, B_HL_CO0) ;
                (CI0 *> CO0) = (CI0_LH_CO0, CI0_HL_CO0) ;
                (A *> CO1) = (A_LH_CO1, A_HL_CO1) ;
                (B *> CO1) = (B_LH_CO1, B_HL_CO1) ;
                (CI1 *> CO1) = (CI1_LH_CO1, CI1_HL_CO1) ;
        endspecify
endmodule

module facs2a3(S, CO0, CO1, A, B, CI0, CI1, CSIN);
        output S, CO0, CO1;
        input  A, B, CI0, CI1, CSIN;
        xor g1(N1, B, CI1, A);
        xor g2(N2, B, CI0, A);
        mux g3(S, CSIN, N1, N2);
        and g4(N4, A, CI0);
        and g5(N5, B, CI0);
        and g6(N6, A, B);
        nor g7(CO0, N4, N5, N6);
        and g8(N8, A, CI1);
        and g9(N9, B, CI1);
        and g10(N10, A, B);
        nor g11(CO1, N8, N9, N10);
        // SPECIFY BLOCK
        specify
                specparam CSIN_01_LH_S = 0, CSIN_01_HL_S = 0 ;
                specparam CSIN_10_LH_S = 0, CSIN_10_HL_S = 0 ;
                specparam A_01_LH_S = 0, A_01_HL_S = 0 ;
                specparam A_10_LH_S = 0, A_10_HL_S = 0 ;
                specparam B_01_LH_S = 0, B_01_HL_S = 0 ;
                specparam B_10_LH_S = 0, B_10_HL_S = 0 ;
                specparam CI1_01_LH_S = 0, CI1_01_HL_S = 0 ;
                specparam CI1_10_LH_S = 0, CI1_10_HL_S = 0 ;
                specparam CI0_01_LH_S = 0, CI0_01_HL_S = 0 ;
                specparam CI0_10_LH_S = 0, CI0_10_HL_S = 0 ;
                specparam A_LH_CO0 = 0, A_HL_CO0 = 0 ;
                specparam B_LH_CO0 = 0, B_HL_CO0 = 0 ;
                specparam CI0_LH_CO0 = 0, CI0_HL_CO0 = 0 ;
                specparam A_LH_CO1 = 0, A_HL_CO1 = 0 ;
                specparam B_LH_CO1 = 0, B_HL_CO1 = 0 ;
                specparam CI1_LH_CO1 = 0, CI1_HL_CO1 = 0 ;
                (posedge CSIN *> (S : 1'b1)) = (CSIN_01_LH_S, CSIN_01_HL_S) ;
                (negedge CSIN *> (S : 1'b1)) = (CSIN_10_LH_S, CSIN_10_HL_S) ;
                (posedge A *> (S : 1'b1)) = (A_01_LH_S, A_01_HL_S) ;
                (negedge A *> (S : 1'b1)) = (A_10_LH_S, A_10_HL_S) ;
                (posedge B *> (S : 1'b1)) = (B_01_LH_S, B_01_HL_S) ;
                (negedge B *> (S : 1'b1)) = (B_10_LH_S, B_10_HL_S) ;
                (posedge CI1 *> (S : 1'b1)) = (CI1_01_LH_S, CI1_01_HL_S) ;
                (negedge CI1 *> (S : 1'b1)) = (CI1_10_LH_S, CI1_10_HL_S) ;
                (posedge CI0 *> (S : 1'b1)) = (CI0_01_LH_S, CI0_01_HL_S) ;
                (negedge CI0 *> (S : 1'b1)) = (CI0_10_LH_S, CI0_10_HL_S) ;
                (A *> CO0) = (A_LH_CO0, A_HL_CO0) ;
                (B *> CO0) = (B_LH_CO0, B_HL_CO0) ;
                (CI0 *> CO0) = (CI0_LH_CO0, CI0_HL_CO0) ;
                (A *> CO1) = (A_LH_CO1, A_HL_CO1) ;
                (B *> CO1) = (B_LH_CO1, B_HL_CO1) ;
                (CI1 *> CO1) = (CI1_LH_CO1, CI1_HL_CO1) ;
        endspecify
endmodule

module facs3a1(S, CO0, CO1, A, B, CSIN);
        output S, CO0, CO1;
        input  A, B, CSIN;
        xor g1(S, A, B, CSIN);
        nand g2(CO0, A, B);
        nor g3(CO1, A, B);
        // SPECIFY BLOCK
        specify
                specparam CSIN_01_LH_S = 0, CSIN_01_HL_S = 0 ;
                specparam CSIN_10_LH_S = 0, CSIN_10_HL_S = 0 ;
                specparam A_01_LH_S = 0, A_01_HL_S = 0 ;
                specparam A_10_LH_S = 0, A_10_HL_S = 0 ;
                specparam B_01_LH_S = 0, B_01_HL_S = 0 ;
                specparam B_10_LH_S = 0, B_10_HL_S = 0 ;
                specparam A_LH_CO0 = 0, A_HL_CO0 = 0 ;
                specparam B_LH_CO0 = 0, B_HL_CO0 = 0 ;
                specparam A_LH_CO1 = 0, A_HL_CO1 = 0 ;
                specparam B_LH_CO1 = 0, B_HL_CO1 = 0 ;
                (posedge CSIN *> (S : 1'b1)) = (CSIN_01_LH_S, CSIN_01_HL_S) ;
                (negedge CSIN *> (S : 1'b1)) = (CSIN_10_LH_S, CSIN_10_HL_S) ;
                (posedge A *> (S : 1'b1)) = (A_01_LH_S, A_01_HL_S) ;
                (negedge A *> (S : 1'b1)) = (A_10_LH_S, A_10_HL_S) ;
                (posedge B *> (S : 1'b1)) = (B_01_LH_S, B_01_HL_S) ;
                (negedge B *> (S : 1'b1)) = (B_10_LH_S, B_10_HL_S) ;
                (A *> CO0) = (A_LH_CO0, A_HL_CO0) ;
                (B *> CO0) = (B_LH_CO0, B_HL_CO0) ;
                (A *> CO1) = (A_LH_CO1, A_HL_CO1) ;
                (B *> CO1) = (B_LH_CO1, B_HL_CO1) ;
        endspecify
endmodule

module facs3a2(S, CO0, CO1, A, B, CSIN);
        output S, CO0, CO1;
        input  A, B, CSIN;
        xor g1(S, A, B, CSIN);
        nand g2(CO0, A, B);
        nor g3(CO1, A, B);
        // SPECIFY BLOCK
        specify
                specparam CSIN_01_LH_S = 0, CSIN_01_HL_S = 0 ;
                specparam CSIN_10_LH_S = 0, CSIN_10_HL_S = 0 ;
                specparam A_01_LH_S = 0, A_01_HL_S = 0 ;
                specparam A_10_LH_S = 0, A_10_HL_S = 0 ;
                specparam B_01_LH_S = 0, B_01_HL_S = 0 ;
                specparam B_10_LH_S = 0, B_10_HL_S = 0 ;
                specparam A_LH_CO0 = 0, A_HL_CO0 = 0 ;
                specparam B_LH_CO0 = 0, B_HL_CO0 = 0 ;
                specparam A_LH_CO1 = 0, A_HL_CO1 = 0 ;
                specparam B_LH_CO1 = 0, B_HL_CO1 = 0 ;
                (posedge CSIN *> (S : 1'b1)) = (CSIN_01_LH_S, CSIN_01_HL_S) ;
                (negedge CSIN *> (S : 1'b1)) = (CSIN_10_LH_S, CSIN_10_HL_S) ;
                (posedge A *> (S : 1'b1)) = (A_01_LH_S, A_01_HL_S) ;
                (negedge A *> (S : 1'b1)) = (A_10_LH_S, A_10_HL_S) ;
                (posedge B *> (S : 1'b1)) = (B_01_LH_S, B_01_HL_S) ;
                (negedge B *> (S : 1'b1)) = (B_10_LH_S, B_10_HL_S) ;
                (A *> CO0) = (A_LH_CO0, A_HL_CO0) ;
                (B *> CO0) = (B_LH_CO0, B_HL_CO0) ;
                (A *> CO1) = (A_LH_CO1, A_HL_CO1) ;
                (B *> CO1) = (B_LH_CO1, B_HL_CO1) ;
        endspecify
endmodule

module facs3a3(S, CO0, CO1, A, B, CSIN);
        output S, CO0, CO1;
        input  A, B, CSIN;
        xor g1(S, A, B, CSIN);
        nand g2(CO0, A, B);
        nor g3(CO1, A, B);
        // SPECIFY BLOCK
        specify
                specparam CSIN_01_LH_S = 0, CSIN_01_HL_S = 0 ;
                specparam CSIN_10_LH_S = 0, CSIN_10_HL_S = 0 ;
                specparam A_01_LH_S = 0, A_01_HL_S = 0 ;
                specparam A_10_LH_S = 0, A_10_HL_S = 0 ;
                specparam B_01_LH_S = 0, B_01_HL_S = 0 ;
                specparam B_10_LH_S = 0, B_10_HL_S = 0 ;
                specparam A_LH_CO0 = 0, A_HL_CO0 = 0 ;
                specparam B_LH_CO0 = 0, B_HL_CO0 = 0 ;
                specparam A_LH_CO1 = 0, A_HL_CO1 = 0 ;
                specparam B_LH_CO1 = 0, B_HL_CO1 = 0 ;
                (posedge CSIN *> (S : 1'b1)) = (CSIN_01_LH_S, CSIN_01_HL_S) ;
                (negedge CSIN *> (S : 1'b1)) = (CSIN_10_LH_S, CSIN_10_HL_S) ;
                (posedge A *> (S : 1'b1)) = (A_01_LH_S, A_01_HL_S) ;
                (negedge A *> (S : 1'b1)) = (A_10_LH_S, A_10_HL_S) ;
                (posedge B *> (S : 1'b1)) = (B_01_LH_S, B_01_HL_S) ;
                (negedge B *> (S : 1'b1)) = (B_10_LH_S, B_10_HL_S) ;
                (A *> CO0) = (A_LH_CO0, A_HL_CO0) ;
                (B *> CO0) = (B_LH_CO0, B_HL_CO0) ;
                (A *> CO1) = (A_LH_CO1, A_HL_CO1) ;
                (B *> CO1) = (B_LH_CO1, B_HL_CO1) ;
        endspecify
endmodule

module facs4a1(S, CO0, CO1, A, B, CSIN);
        output S, CO0, CO1;
        input  A, B, CSIN;
        not g1(N1, CSIN);
        xor g2(S, A, B, N1);
        nand g3(CO0, A, B);
        nor g4(CO1, A, B);
        // SPECIFY BLOCK
        specify
                specparam CSIN_01_LH_S = 0, CSIN_01_HL_S = 0 ;
                specparam CSIN_10_LH_S = 0, CSIN_10_HL_S = 0 ;
                specparam A_01_LH_S = 0, A_01_HL_S = 0 ;
                specparam A_10_LH_S = 0, A_10_HL_S = 0 ;
                specparam B_01_LH_S = 0, B_01_HL_S = 0 ;
                specparam B_10_LH_S = 0, B_10_HL_S = 0 ;
                specparam A_LH_CO0 = 0, A_HL_CO0 = 0 ;
                specparam B_LH_CO0 = 0, B_HL_CO0 = 0 ;
                specparam A_LH_CO1 = 0, A_HL_CO1 = 0 ;
                specparam B_LH_CO1 = 0, B_HL_CO1 = 0 ;
                (posedge CSIN *> (S : 1'b1)) = (CSIN_01_LH_S, CSIN_01_HL_S) ;
                (negedge CSIN *> (S : 1'b1)) = (CSIN_10_LH_S, CSIN_10_HL_S) ;
                (posedge A *> (S : 1'b1)) = (A_01_LH_S, A_01_HL_S) ;
                (negedge A *> (S : 1'b1)) = (A_10_LH_S, A_10_HL_S) ;
                (posedge B *> (S : 1'b1)) = (B_01_LH_S, B_01_HL_S) ;
                (negedge B *> (S : 1'b1)) = (B_10_LH_S, B_10_HL_S) ;
                (A *> CO0) = (A_LH_CO0, A_HL_CO0) ;
                (B *> CO0) = (B_LH_CO0, B_HL_CO0) ;
                (A *> CO1) = (A_LH_CO1, A_HL_CO1) ;
                (B *> CO1) = (B_LH_CO1, B_HL_CO1) ;
        endspecify
endmodule

module facs4a2(S, CO0, CO1, A, B, CSIN);
        output S, CO0, CO1;
        input  A, B, CSIN;
        not g1(N1, CSIN);
        xor g2(S, A, B, N1);
        nand g3(CO0, A, B);
        nor g4(CO1, A, B);
        // SPECIFY BLOCK
        specify
                specparam CSIN_01_LH_S = 0, CSIN_01_HL_S = 0 ;
                specparam CSIN_10_LH_S = 0, CSIN_10_HL_S = 0 ;
                specparam A_01_LH_S = 0, A_01_HL_S = 0 ;
                specparam A_10_LH_S = 0, A_10_HL_S = 0 ;
                specparam B_01_LH_S = 0, B_01_HL_S = 0 ;
                specparam B_10_LH_S = 0, B_10_HL_S = 0 ;
                specparam A_LH_CO0 = 0, A_HL_CO0 = 0 ;
                specparam B_LH_CO0 = 0, B_HL_CO0 = 0 ;
                specparam A_LH_CO1 = 0, A_HL_CO1 = 0 ;
                specparam B_LH_CO1 = 0, B_HL_CO1 = 0 ;
                (posedge CSIN *> (S : 1'b1)) = (CSIN_01_LH_S, CSIN_01_HL_S) ;
                (negedge CSIN *> (S : 1'b1)) = (CSIN_10_LH_S, CSIN_10_HL_S) ;
                (posedge A *> (S : 1'b1)) = (A_01_LH_S, A_01_HL_S) ;
                (negedge A *> (S : 1'b1)) = (A_10_LH_S, A_10_HL_S) ;
                (posedge B *> (S : 1'b1)) = (B_01_LH_S, B_01_HL_S) ;
                (negedge B *> (S : 1'b1)) = (B_10_LH_S, B_10_HL_S) ;
                (A *> CO0) = (A_LH_CO0, A_HL_CO0) ;
                (B *> CO0) = (B_LH_CO0, B_HL_CO0) ;
                (A *> CO1) = (A_LH_CO1, A_HL_CO1) ;
                (B *> CO1) = (B_LH_CO1, B_HL_CO1) ;
        endspecify
endmodule

module facs4a3(S, CO0, CO1, A, B, CSIN);
        output S, CO0, CO1;
        input  A, B, CSIN;
        not g1(N1, CSIN);
        xor g2(S, A, B, N1);
        nand g3(CO0, A, B);
        nor g4(CO1, A, B);
        // SPECIFY BLOCK
        specify
                specparam CSIN_01_LH_S = 0, CSIN_01_HL_S = 0 ;
                specparam CSIN_10_LH_S = 0, CSIN_10_HL_S = 0 ;
                specparam A_01_LH_S = 0, A_01_HL_S = 0 ;
                specparam A_10_LH_S = 0, A_10_HL_S = 0 ;
                specparam B_01_LH_S = 0, B_01_HL_S = 0 ;
                specparam B_10_LH_S = 0, B_10_HL_S = 0 ;
                specparam A_LH_CO0 = 0, A_HL_CO0 = 0 ;
                specparam B_LH_CO0 = 0, B_HL_CO0 = 0 ;
                specparam A_LH_CO1 = 0, A_HL_CO1 = 0 ;
                specparam B_LH_CO1 = 0, B_HL_CO1 = 0 ;
                (posedge CSIN *> (S : 1'b1)) = (CSIN_01_LH_S, CSIN_01_HL_S) ;
                (negedge CSIN *> (S : 1'b1)) = (CSIN_10_LH_S, CSIN_10_HL_S) ;
                (posedge A *> (S : 1'b1)) = (A_01_LH_S, A_01_HL_S) ;
                (negedge A *> (S : 1'b1)) = (A_10_LH_S, A_10_HL_S) ;
                (posedge B *> (S : 1'b1)) = (B_01_LH_S, B_01_HL_S) ;
                (negedge B *> (S : 1'b1)) = (B_10_LH_S, B_10_HL_S) ;
                (A *> CO0) = (A_LH_CO0, A_HL_CO0) ;
                (B *> CO0) = (B_LH_CO0, B_HL_CO0) ;
                (A *> CO1) = (A_LH_CO1, A_HL_CO1) ;
                (B *> CO1) = (B_LH_CO1, B_HL_CO1) ;
        endspecify
endmodule

module facsf1b1(S, CO0, CO1, A, B, CI0, CI1, CSIN);
        output S, CO0, CO1;
        input  A, B, CI0, CI1, CSIN;
        not g1(N2, CI1);
        xor g2(N1, B, N2, A);
        not g3(N4, CI0);
        xor g4(N3, B, N4, A);
        mux g5(S, CSIN, N1, N3);
        not g6(N7, CI1);
        and g7(N6, A, N7);
        not g8(N9, CI1);
        and g9(N8, B, N9);
        and g10(N10, A, B);
        or g11(CO1, N6, N8, N10);
        not g12(N13, CI0);
        and g13(N12, A, N13);
        not g14(N15, CI0);
        and g15(N14, B, N15);
        and g16(N16, A, B);
        or g17(CO0, N12, N14, N16);
        // SPECIFY BLOCK
        specify
                specparam CSIN_01_LH_S = 0, CSIN_01_HL_S = 0 ;
                specparam CSIN_10_LH_S = 0, CSIN_10_HL_S = 0 ;
                specparam A_01_LH_S = 0, A_01_HL_S = 0 ;
                specparam A_10_LH_S = 0, A_10_HL_S = 0 ;
                specparam B_01_LH_S = 0, B_01_HL_S = 0 ;
                specparam B_10_LH_S = 0, B_10_HL_S = 0 ;
                specparam CI1_01_LH_S = 0, CI1_01_HL_S = 0 ;
                specparam CI1_10_LH_S = 0, CI1_10_HL_S = 0 ;
                specparam CI0_01_LH_S = 0, CI0_01_HL_S = 0 ;
                specparam CI0_10_LH_S = 0, CI0_10_HL_S = 0 ;
                specparam A_LH_CO1 = 0, A_HL_CO1 = 0 ;
                specparam B_LH_CO1 = 0, B_HL_CO1 = 0 ;
                specparam CI1_LH_CO1 = 0, CI1_HL_CO1 = 0 ;
                specparam A_LH_CO0 = 0, A_HL_CO0 = 0 ;
                specparam B_LH_CO0 = 0, B_HL_CO0 = 0 ;
                specparam CI0_LH_CO0 = 0, CI0_HL_CO0 = 0 ;
                (posedge CSIN *> (S : 1'b1)) = (CSIN_01_LH_S, CSIN_01_HL_S) ;
                (negedge CSIN *> (S : 1'b1)) = (CSIN_10_LH_S, CSIN_10_HL_S) ;
                (posedge A *> (S : 1'b1)) = (A_01_LH_S, A_01_HL_S) ;
                (negedge A *> (S : 1'b1)) = (A_10_LH_S, A_10_HL_S) ;
                (posedge B *> (S : 1'b1)) = (B_01_LH_S, B_01_HL_S) ;
                (negedge B *> (S : 1'b1)) = (B_10_LH_S, B_10_HL_S) ;
                (posedge CI1 *> (S : 1'b1)) = (CI1_01_LH_S, CI1_01_HL_S) ;
                (negedge CI1 *> (S : 1'b1)) = (CI1_10_LH_S, CI1_10_HL_S) ;
                (posedge CI0 *> (S : 1'b1)) = (CI0_01_LH_S, CI0_01_HL_S) ;
                (negedge CI0 *> (S : 1'b1)) = (CI0_10_LH_S, CI0_10_HL_S) ;
                (A *> CO1) = (A_LH_CO1, A_HL_CO1) ;
                (B *> CO1) = (B_LH_CO1, B_HL_CO1) ;
                (CI1 *> CO1) = (CI1_LH_CO1, CI1_HL_CO1) ;
                (A *> CO0) = (A_LH_CO0, A_HL_CO0) ;
                (B *> CO0) = (B_LH_CO0, B_HL_CO0) ;
                (CI0 *> CO0) = (CI0_LH_CO0, CI0_HL_CO0) ;
        endspecify
endmodule

module facsf1b2(S, CO0, CO1, A, B, CI0, CI1, CSIN);
        output S, CO0, CO1;
        input  A, B, CI0, CI1, CSIN;
        not g1(N2, CI1);
        xor g2(N1, B, N2, A);
        not g3(N4, CI0);
        xor g4(N3, B, N4, A);
        mux g5(S, CSIN, N1, N3);
        not g6(N7, CI1);
        and g7(N6, A, N7);
        not g8(N9, CI1);
        and g9(N8, B, N9);
        and g10(N10, A, B);
        or g11(CO1, N6, N8, N10);
        not g12(N13, CI0);
        and g13(N12, A, N13);
        not g14(N15, CI0);
        and g15(N14, B, N15);
        and g16(N16, A, B);
        or g17(CO0, N12, N14, N16);
        // SPECIFY BLOCK
        specify
                specparam CSIN_01_LH_S = 0, CSIN_01_HL_S = 0 ;
                specparam CSIN_10_LH_S = 0, CSIN_10_HL_S = 0 ;
                specparam A_01_LH_S = 0, A_01_HL_S = 0 ;
                specparam A_10_LH_S = 0, A_10_HL_S = 0 ;
                specparam B_01_LH_S = 0, B_01_HL_S = 0 ;
                specparam B_10_LH_S = 0, B_10_HL_S = 0 ;
                specparam CI1_01_LH_S = 0, CI1_01_HL_S = 0 ;
                specparam CI1_10_LH_S = 0, CI1_10_HL_S = 0 ;
                specparam CI0_01_LH_S = 0, CI0_01_HL_S = 0 ;
                specparam CI0_10_LH_S = 0, CI0_10_HL_S = 0 ;
                specparam A_LH_CO1 = 0, A_HL_CO1 = 0 ;
                specparam B_LH_CO1 = 0, B_HL_CO1 = 0 ;
                specparam CI1_LH_CO1 = 0, CI1_HL_CO1 = 0 ;
                specparam A_LH_CO0 = 0, A_HL_CO0 = 0 ;
                specparam B_LH_CO0 = 0, B_HL_CO0 = 0 ;
                specparam CI0_LH_CO0 = 0, CI0_HL_CO0 = 0 ;
                (posedge CSIN *> (S : 1'b1)) = (CSIN_01_LH_S, CSIN_01_HL_S) ;
                (negedge CSIN *> (S : 1'b1)) = (CSIN_10_LH_S, CSIN_10_HL_S) ;
                (posedge A *> (S : 1'b1)) = (A_01_LH_S, A_01_HL_S) ;
                (negedge A *> (S : 1'b1)) = (A_10_LH_S, A_10_HL_S) ;
                (posedge B *> (S : 1'b1)) = (B_01_LH_S, B_01_HL_S) ;
                (negedge B *> (S : 1'b1)) = (B_10_LH_S, B_10_HL_S) ;
                (posedge CI1 *> (S : 1'b1)) = (CI1_01_LH_S, CI1_01_HL_S) ;
                (negedge CI1 *> (S : 1'b1)) = (CI1_10_LH_S, CI1_10_HL_S) ;
                (posedge CI0 *> (S : 1'b1)) = (CI0_01_LH_S, CI0_01_HL_S) ;
                (negedge CI0 *> (S : 1'b1)) = (CI0_10_LH_S, CI0_10_HL_S) ;
                (A *> CO1) = (A_LH_CO1, A_HL_CO1) ;
                (B *> CO1) = (B_LH_CO1, B_HL_CO1) ;
                (CI1 *> CO1) = (CI1_LH_CO1, CI1_HL_CO1) ;
                (A *> CO0) = (A_LH_CO0, A_HL_CO0) ;
                (B *> CO0) = (B_LH_CO0, B_HL_CO0) ;
                (CI0 *> CO0) = (CI0_LH_CO0, CI0_HL_CO0) ;
        endspecify
endmodule

module facsf1b3(S, CO0, CO1, A, B, CI0, CI1, CSIN);
        output S, CO0, CO1;
        input  A, B, CI0, CI1, CSIN;
        not g1(N2, CI1);
        xor g2(N1, B, N2, A);
        not g3(N4, CI0);
        xor g4(N3, B, N4, A);
        mux g5(S, CSIN, N1, N3);
        not g6(N7, CI1);
        and g7(N6, A, N7);
        not g8(N9, CI1);
        and g9(N8, B, N9);
        and g10(N10, A, B);
        or g11(CO1, N6, N8, N10);
        not g12(N13, CI0);
        and g13(N12, A, N13);
        not g14(N15, CI0);
        and g15(N14, B, N15);
        and g16(N16, A, B);
        or g17(CO0, N12, N14, N16);
        // SPECIFY BLOCK
        specify
                specparam CSIN_01_LH_S = 0, CSIN_01_HL_S = 0 ;
                specparam CSIN_10_LH_S = 0, CSIN_10_HL_S = 0 ;
                specparam A_01_LH_S = 0, A_01_HL_S = 0 ;
                specparam A_10_LH_S = 0, A_10_HL_S = 0 ;
                specparam B_01_LH_S = 0, B_01_HL_S = 0 ;
                specparam B_10_LH_S = 0, B_10_HL_S = 0 ;
                specparam CI1_01_LH_S = 0, CI1_01_HL_S = 0 ;
                specparam CI1_10_LH_S = 0, CI1_10_HL_S = 0 ;
                specparam CI0_01_LH_S = 0, CI0_01_HL_S = 0 ;
                specparam CI0_10_LH_S = 0, CI0_10_HL_S = 0 ;
                specparam A_LH_CO1 = 0, A_HL_CO1 = 0 ;
                specparam B_LH_CO1 = 0, B_HL_CO1 = 0 ;
                specparam CI1_LH_CO1 = 0, CI1_HL_CO1 = 0 ;
                specparam A_LH_CO0 = 0, A_HL_CO0 = 0 ;
                specparam B_LH_CO0 = 0, B_HL_CO0 = 0 ;
                specparam CI0_LH_CO0 = 0, CI0_HL_CO0 = 0 ;
                (posedge CSIN *> (S : 1'b1)) = (CSIN_01_LH_S, CSIN_01_HL_S) ;
                (negedge CSIN *> (S : 1'b1)) = (CSIN_10_LH_S, CSIN_10_HL_S) ;
                (posedge A *> (S : 1'b1)) = (A_01_LH_S, A_01_HL_S) ;
                (negedge A *> (S : 1'b1)) = (A_10_LH_S, A_10_HL_S) ;
                (posedge B *> (S : 1'b1)) = (B_01_LH_S, B_01_HL_S) ;
                (negedge B *> (S : 1'b1)) = (B_10_LH_S, B_10_HL_S) ;
                (posedge CI1 *> (S : 1'b1)) = (CI1_01_LH_S, CI1_01_HL_S) ;
                (negedge CI1 *> (S : 1'b1)) = (CI1_10_LH_S, CI1_10_HL_S) ;
                (posedge CI0 *> (S : 1'b1)) = (CI0_01_LH_S, CI0_01_HL_S) ;
                (negedge CI0 *> (S : 1'b1)) = (CI0_10_LH_S, CI0_10_HL_S) ;
                (A *> CO1) = (A_LH_CO1, A_HL_CO1) ;
                (B *> CO1) = (B_LH_CO1, B_HL_CO1) ;
                (CI1 *> CO1) = (CI1_LH_CO1, CI1_HL_CO1) ;
                (A *> CO0) = (A_LH_CO0, A_HL_CO0) ;
                (B *> CO0) = (B_LH_CO0, B_HL_CO0) ;
                (CI0 *> CO0) = (CI0_LH_CO0, CI0_HL_CO0) ;
        endspecify
endmodule

module facsf2a1(S, CO0, CO1, A, B, CI0, CI1, CSIN);
        output S, CO0, CO1;
        input  A, B, CI0, CI1, CSIN;
        xor g1(N1, B, CI1, A);
        xor g2(N2, B, CI0, A);
        mux g3(S, CSIN, N1, N2);
        and g4(N4, A, CI0);
        and g5(N5, B, CI0);
        and g6(N6, A, B);
        nor g7(CO0, N4, N5, N6);
        and g8(N8, A, CI1);
        and g9(N9, B, CI1);
        and g10(N10, A, B);
        nor g11(CO1, N8, N9, N10);
        // SPECIFY BLOCK
        specify
                specparam CSIN_01_LH_S = 0, CSIN_01_HL_S = 0 ;
                specparam CSIN_10_LH_S = 0, CSIN_10_HL_S = 0 ;
                specparam A_01_LH_S = 0, A_01_HL_S = 0 ;
                specparam A_10_LH_S = 0, A_10_HL_S = 0 ;
                specparam B_01_LH_S = 0, B_01_HL_S = 0 ;
                specparam B_10_LH_S = 0, B_10_HL_S = 0 ;
                specparam CI1_01_LH_S = 0, CI1_01_HL_S = 0 ;
                specparam CI1_10_LH_S = 0, CI1_10_HL_S = 0 ;
                specparam CI0_01_LH_S = 0, CI0_01_HL_S = 0 ;
                specparam CI0_10_LH_S = 0, CI0_10_HL_S = 0 ;
                specparam A_LH_CO0 = 0, A_HL_CO0 = 0 ;
                specparam B_LH_CO0 = 0, B_HL_CO0 = 0 ;
                specparam CI0_LH_CO0 = 0, CI0_HL_CO0 = 0 ;
                specparam A_LH_CO1 = 0, A_HL_CO1 = 0 ;
                specparam B_LH_CO1 = 0, B_HL_CO1 = 0 ;
                specparam CI1_LH_CO1 = 0, CI1_HL_CO1 = 0 ;
                (posedge CSIN *> (S : 1'b1)) = (CSIN_01_LH_S, CSIN_01_HL_S) ;
                (negedge CSIN *> (S : 1'b1)) = (CSIN_10_LH_S, CSIN_10_HL_S) ;
                (posedge A *> (S : 1'b1)) = (A_01_LH_S, A_01_HL_S) ;
                (negedge A *> (S : 1'b1)) = (A_10_LH_S, A_10_HL_S) ;
                (posedge B *> (S : 1'b1)) = (B_01_LH_S, B_01_HL_S) ;
                (negedge B *> (S : 1'b1)) = (B_10_LH_S, B_10_HL_S) ;
                (posedge CI1 *> (S : 1'b1)) = (CI1_01_LH_S, CI1_01_HL_S) ;
                (negedge CI1 *> (S : 1'b1)) = (CI1_10_LH_S, CI1_10_HL_S) ;
                (posedge CI0 *> (S : 1'b1)) = (CI0_01_LH_S, CI0_01_HL_S) ;
                (negedge CI0 *> (S : 1'b1)) = (CI0_10_LH_S, CI0_10_HL_S) ;
                (A *> CO0) = (A_LH_CO0, A_HL_CO0) ;
                (B *> CO0) = (B_LH_CO0, B_HL_CO0) ;
                (CI0 *> CO0) = (CI0_LH_CO0, CI0_HL_CO0) ;
                (A *> CO1) = (A_LH_CO1, A_HL_CO1) ;
                (B *> CO1) = (B_LH_CO1, B_HL_CO1) ;
                (CI1 *> CO1) = (CI1_LH_CO1, CI1_HL_CO1) ;
        endspecify
endmodule

module facsf2a2(S, CO0, CO1, A, B, CI0, CI1, CSIN);
        output S, CO0, CO1;
        input  A, B, CI0, CI1, CSIN;
        xor g1(N1, B, CI1, A);
        xor g2(N2, B, CI0, A);
        mux g3(S, CSIN, N1, N2);
        and g4(N4, A, CI0);
        and g5(N5, B, CI0);
        and g6(N6, A, B);
        nor g7(CO0, N4, N5, N6);
        and g8(N8, A, CI1);
        and g9(N9, B, CI1);
        and g10(N10, A, B);
        nor g11(CO1, N8, N9, N10);
        // SPECIFY BLOCK
        specify
                specparam CSIN_01_LH_S = 0, CSIN_01_HL_S = 0 ;
                specparam CSIN_10_LH_S = 0, CSIN_10_HL_S = 0 ;
                specparam A_01_LH_S = 0, A_01_HL_S = 0 ;
                specparam A_10_LH_S = 0, A_10_HL_S = 0 ;
                specparam B_01_LH_S = 0, B_01_HL_S = 0 ;
                specparam B_10_LH_S = 0, B_10_HL_S = 0 ;
                specparam CI1_01_LH_S = 0, CI1_01_HL_S = 0 ;
                specparam CI1_10_LH_S = 0, CI1_10_HL_S = 0 ;
                specparam CI0_01_LH_S = 0, CI0_01_HL_S = 0 ;
                specparam CI0_10_LH_S = 0, CI0_10_HL_S = 0 ;
                specparam A_LH_CO0 = 0, A_HL_CO0 = 0 ;
                specparam B_LH_CO0 = 0, B_HL_CO0 = 0 ;
                specparam CI0_LH_CO0 = 0, CI0_HL_CO0 = 0 ;
                specparam A_LH_CO1 = 0, A_HL_CO1 = 0 ;
                specparam B_LH_CO1 = 0, B_HL_CO1 = 0 ;
                specparam CI1_LH_CO1 = 0, CI1_HL_CO1 = 0 ;
                (posedge CSIN *> (S : 1'b1)) = (CSIN_01_LH_S, CSIN_01_HL_S) ;
                (negedge CSIN *> (S : 1'b1)) = (CSIN_10_LH_S, CSIN_10_HL_S) ;
                (posedge A *> (S : 1'b1)) = (A_01_LH_S, A_01_HL_S) ;
                (negedge A *> (S : 1'b1)) = (A_10_LH_S, A_10_HL_S) ;
                (posedge B *> (S : 1'b1)) = (B_01_LH_S, B_01_HL_S) ;
                (negedge B *> (S : 1'b1)) = (B_10_LH_S, B_10_HL_S) ;
                (posedge CI1 *> (S : 1'b1)) = (CI1_01_LH_S, CI1_01_HL_S) ;
                (negedge CI1 *> (S : 1'b1)) = (CI1_10_LH_S, CI1_10_HL_S) ;
                (posedge CI0 *> (S : 1'b1)) = (CI0_01_LH_S, CI0_01_HL_S) ;
                (negedge CI0 *> (S : 1'b1)) = (CI0_10_LH_S, CI0_10_HL_S) ;
                (A *> CO0) = (A_LH_CO0, A_HL_CO0) ;
                (B *> CO0) = (B_LH_CO0, B_HL_CO0) ;
                (CI0 *> CO0) = (CI0_LH_CO0, CI0_HL_CO0) ;
                (A *> CO1) = (A_LH_CO1, A_HL_CO1) ;
                (B *> CO1) = (B_LH_CO1, B_HL_CO1) ;
                (CI1 *> CO1) = (CI1_LH_CO1, CI1_HL_CO1) ;
        endspecify
endmodule

module facsf2a3(S, CO0, CO1, A, B, CI0, CI1, CSIN);
        output S, CO0, CO1;
        input  A, B, CI0, CI1, CSIN;
        xor g1(N1, B, CI1, A);
        xor g2(N2, B, CI0, A);
        mux g3(S, CSIN, N1, N2);
        and g4(N4, A, CI0);
        and g5(N5, B, CI0);
        and g6(N6, A, B);
        nor g7(CO0, N4, N5, N6);
        and g8(N8, A, CI1);
        and g9(N9, B, CI1);
        and g10(N10, A, B);
        nor g11(CO1, N8, N9, N10);
        // SPECIFY BLOCK
        specify
                specparam CSIN_01_LH_S = 0, CSIN_01_HL_S = 0 ;
                specparam CSIN_10_LH_S = 0, CSIN_10_HL_S = 0 ;
                specparam A_01_LH_S = 0, A_01_HL_S = 0 ;
                specparam A_10_LH_S = 0, A_10_HL_S = 0 ;
                specparam B_01_LH_S = 0, B_01_HL_S = 0 ;
                specparam B_10_LH_S = 0, B_10_HL_S = 0 ;
                specparam CI1_01_LH_S = 0, CI1_01_HL_S = 0 ;
                specparam CI1_10_LH_S = 0, CI1_10_HL_S = 0 ;
                specparam CI0_01_LH_S = 0, CI0_01_HL_S = 0 ;
                specparam CI0_10_LH_S = 0, CI0_10_HL_S = 0 ;
                specparam A_LH_CO0 = 0, A_HL_CO0 = 0 ;
                specparam B_LH_CO0 = 0, B_HL_CO0 = 0 ;
                specparam CI0_LH_CO0 = 0, CI0_HL_CO0 = 0 ;
                specparam A_LH_CO1 = 0, A_HL_CO1 = 0 ;
                specparam B_LH_CO1 = 0, B_HL_CO1 = 0 ;
                specparam CI1_LH_CO1 = 0, CI1_HL_CO1 = 0 ;
                (posedge CSIN *> (S : 1'b1)) = (CSIN_01_LH_S, CSIN_01_HL_S) ;
                (negedge CSIN *> (S : 1'b1)) = (CSIN_10_LH_S, CSIN_10_HL_S) ;
                (posedge A *> (S : 1'b1)) = (A_01_LH_S, A_01_HL_S) ;
                (negedge A *> (S : 1'b1)) = (A_10_LH_S, A_10_HL_S) ;
                (posedge B *> (S : 1'b1)) = (B_01_LH_S, B_01_HL_S) ;
                (negedge B *> (S : 1'b1)) = (B_10_LH_S, B_10_HL_S) ;
                (posedge CI1 *> (S : 1'b1)) = (CI1_01_LH_S, CI1_01_HL_S) ;
                (negedge CI1 *> (S : 1'b1)) = (CI1_10_LH_S, CI1_10_HL_S) ;
                (posedge CI0 *> (S : 1'b1)) = (CI0_01_LH_S, CI0_01_HL_S) ;
                (negedge CI0 *> (S : 1'b1)) = (CI0_10_LH_S, CI0_10_HL_S) ;
                (A *> CO0) = (A_LH_CO0, A_HL_CO0) ;
                (B *> CO0) = (B_LH_CO0, B_HL_CO0) ;
                (CI0 *> CO0) = (CI0_LH_CO0, CI0_HL_CO0) ;
                (A *> CO1) = (A_LH_CO1, A_HL_CO1) ;
                (B *> CO1) = (B_LH_CO1, B_HL_CO1) ;
                (CI1 *> CO1) = (CI1_LH_CO1, CI1_HL_CO1) ;
        endspecify
endmodule

module hacs1b1(S, CO, A, B, CSIN);
        output S, CO;
        input  A, B, CSIN;
        not g1(N2, B);
        xor g2(N1, A, N2);
        mux g3(S, CSIN, N1, A);
        not g4(N4, B);
        and g5(CO, A, N4);
        // SPECIFY BLOCK
        specify
                specparam CSIN_01_LH_S = 0, CSIN_01_HL_S = 0 ;
                specparam CSIN_10_LH_S = 0, CSIN_10_HL_S = 0 ;
                specparam A_01_LH_S = 0, A_01_HL_S = 0 ;
                specparam A_10_LH_S = 0, A_10_HL_S = 0 ;
                specparam B_01_LH_S = 0, B_01_HL_S = 0 ;
                specparam B_10_LH_S = 0, B_10_HL_S = 0 ;
                specparam A_LH_CO = 0, A_HL_CO = 0 ;
                specparam B_LH_CO = 0, B_HL_CO = 0 ;
                (posedge CSIN *> (S : 1'b1)) = (CSIN_01_LH_S, CSIN_01_HL_S) ;
                (negedge CSIN *> (S : 1'b1)) = (CSIN_10_LH_S, CSIN_10_HL_S) ;
                (posedge A *> (S : 1'b1)) = (A_01_LH_S, A_01_HL_S) ;
                (negedge A *> (S : 1'b1)) = (A_10_LH_S, A_10_HL_S) ;
                (posedge B *> (S : 1'b1)) = (B_01_LH_S, B_01_HL_S) ;
                (negedge B *> (S : 1'b1)) = (B_10_LH_S, B_10_HL_S) ;
                (A *> CO) = (A_LH_CO, A_HL_CO) ;
                (B *> CO) = (B_LH_CO, B_HL_CO) ;
        endspecify
endmodule

module hacs1b2(S, CO, A, B, CSIN);
        output S, CO;
        input  A, B, CSIN;
        not g1(N2, B);
        xor g2(N1, A, N2);
        mux g3(S, CSIN, N1, A);
        not g4(N4, B);
        and g5(CO, A, N4);
        // SPECIFY BLOCK
        specify
                specparam CSIN_01_LH_S = 0, CSIN_01_HL_S = 0 ;
                specparam CSIN_10_LH_S = 0, CSIN_10_HL_S = 0 ;
                specparam A_01_LH_S = 0, A_01_HL_S = 0 ;
                specparam A_10_LH_S = 0, A_10_HL_S = 0 ;
                specparam B_01_LH_S = 0, B_01_HL_S = 0 ;
                specparam B_10_LH_S = 0, B_10_HL_S = 0 ;
                specparam A_LH_CO = 0, A_HL_CO = 0 ;
                specparam B_LH_CO = 0, B_HL_CO = 0 ;
                (posedge CSIN *> (S : 1'b1)) = (CSIN_01_LH_S, CSIN_01_HL_S) ;
                (negedge CSIN *> (S : 1'b1)) = (CSIN_10_LH_S, CSIN_10_HL_S) ;
                (posedge A *> (S : 1'b1)) = (A_01_LH_S, A_01_HL_S) ;
                (negedge A *> (S : 1'b1)) = (A_10_LH_S, A_10_HL_S) ;
                (posedge B *> (S : 1'b1)) = (B_01_LH_S, B_01_HL_S) ;
                (negedge B *> (S : 1'b1)) = (B_10_LH_S, B_10_HL_S) ;
                (A *> CO) = (A_LH_CO, A_HL_CO) ;
                (B *> CO) = (B_LH_CO, B_HL_CO) ;
        endspecify
endmodule

module hacs1b3(S, CO, A, B, CSIN);
        output S, CO;
        input  A, B, CSIN;
        not g1(N2, B);
        xor g2(N1, A, N2);
        mux g3(S, CSIN, N1, A);
        not g4(N4, B);
        and g5(CO, A, N4);
        // SPECIFY BLOCK
        specify
                specparam CSIN_01_LH_S = 0, CSIN_01_HL_S = 0 ;
                specparam CSIN_10_LH_S = 0, CSIN_10_HL_S = 0 ;
                specparam A_01_LH_S = 0, A_01_HL_S = 0 ;
                specparam A_10_LH_S = 0, A_10_HL_S = 0 ;
                specparam B_01_LH_S = 0, B_01_HL_S = 0 ;
                specparam B_10_LH_S = 0, B_10_HL_S = 0 ;
                specparam A_LH_CO = 0, A_HL_CO = 0 ;
                specparam B_LH_CO = 0, B_HL_CO = 0 ;
                (posedge CSIN *> (S : 1'b1)) = (CSIN_01_LH_S, CSIN_01_HL_S) ;
                (negedge CSIN *> (S : 1'b1)) = (CSIN_10_LH_S, CSIN_10_HL_S) ;
                (posedge A *> (S : 1'b1)) = (A_01_LH_S, A_01_HL_S) ;
                (negedge A *> (S : 1'b1)) = (A_10_LH_S, A_10_HL_S) ;
                (posedge B *> (S : 1'b1)) = (B_01_LH_S, B_01_HL_S) ;
                (negedge B *> (S : 1'b1)) = (B_10_LH_S, B_10_HL_S) ;
                (A *> CO) = (A_LH_CO, A_HL_CO) ;
                (B *> CO) = (B_LH_CO, B_HL_CO) ;
        endspecify
endmodule

module hacs2a1(S, CO, A, B, CSIN);
        output S, CO;
        input  A, B, CSIN;
        xor g1(N1, A, B);
        mux g2(S, CSIN, N1, A);
        nand g3(CO, A, B);
        // SPECIFY BLOCK
        specify
                specparam CSIN_01_LH_S = 0, CSIN_01_HL_S = 0 ;
                specparam CSIN_10_LH_S = 0, CSIN_10_HL_S = 0 ;
                specparam A_01_LH_S = 0, A_01_HL_S = 0 ;
                specparam A_10_LH_S = 0, A_10_HL_S = 0 ;
                specparam B_01_LH_S = 0, B_01_HL_S = 0 ;
                specparam B_10_LH_S = 0, B_10_HL_S = 0 ;
                specparam A_LH_CO = 0, A_HL_CO = 0 ;
                specparam B_LH_CO = 0, B_HL_CO = 0 ;
                (posedge CSIN *> (S : 1'b1)) = (CSIN_01_LH_S, CSIN_01_HL_S) ;
                (negedge CSIN *> (S : 1'b1)) = (CSIN_10_LH_S, CSIN_10_HL_S) ;
                (posedge A *> (S : 1'b1)) = (A_01_LH_S, A_01_HL_S) ;
                (negedge A *> (S : 1'b1)) = (A_10_LH_S, A_10_HL_S) ;
                (posedge B *> (S : 1'b1)) = (B_01_LH_S, B_01_HL_S) ;
                (negedge B *> (S : 1'b1)) = (B_10_LH_S, B_10_HL_S) ;
                (A *> CO) = (A_LH_CO, A_HL_CO) ;
                (B *> CO) = (B_LH_CO, B_HL_CO) ;
        endspecify
endmodule

module hacs2a2(S, CO, A, B, CSIN);
        output S, CO;
        input  A, B, CSIN;
        xor g1(N1, A, B);
        mux g2(S, CSIN, N1, A);
        nand g3(CO, A, B);
        // SPECIFY BLOCK
        specify
                specparam CSIN_01_LH_S = 0, CSIN_01_HL_S = 0 ;
                specparam CSIN_10_LH_S = 0, CSIN_10_HL_S = 0 ;
                specparam A_01_LH_S = 0, A_01_HL_S = 0 ;
                specparam A_10_LH_S = 0, A_10_HL_S = 0 ;
                specparam B_01_LH_S = 0, B_01_HL_S = 0 ;
                specparam B_10_LH_S = 0, B_10_HL_S = 0 ;
                specparam A_LH_CO = 0, A_HL_CO = 0 ;
                specparam B_LH_CO = 0, B_HL_CO = 0 ;
                (posedge CSIN *> (S : 1'b1)) = (CSIN_01_LH_S, CSIN_01_HL_S) ;
                (negedge CSIN *> (S : 1'b1)) = (CSIN_10_LH_S, CSIN_10_HL_S) ;
                (posedge A *> (S : 1'b1)) = (A_01_LH_S, A_01_HL_S) ;
                (negedge A *> (S : 1'b1)) = (A_10_LH_S, A_10_HL_S) ;
                (posedge B *> (S : 1'b1)) = (B_01_LH_S, B_01_HL_S) ;
                (negedge B *> (S : 1'b1)) = (B_10_LH_S, B_10_HL_S) ;
                (A *> CO) = (A_LH_CO, A_HL_CO) ;
                (B *> CO) = (B_LH_CO, B_HL_CO) ;
        endspecify
endmodule

module hacs2a3(S, CO, A, B, CSIN);
        output S, CO;
        input  A, B, CSIN;
        xor g1(N1, A, B);
        mux g2(S, CSIN, N1, A);
        nand g3(CO, A, B);
        // SPECIFY BLOCK
        specify
                specparam CSIN_01_LH_S = 0, CSIN_01_HL_S = 0 ;
                specparam CSIN_10_LH_S = 0, CSIN_10_HL_S = 0 ;
                specparam A_01_LH_S = 0, A_01_HL_S = 0 ;
                specparam A_10_LH_S = 0, A_10_HL_S = 0 ;
                specparam B_01_LH_S = 0, B_01_HL_S = 0 ;
                specparam B_10_LH_S = 0, B_10_HL_S = 0 ;
                specparam A_LH_CO = 0, A_HL_CO = 0 ;
                specparam B_LH_CO = 0, B_HL_CO = 0 ;
                (posedge CSIN *> (S : 1'b1)) = (CSIN_01_LH_S, CSIN_01_HL_S) ;
                (negedge CSIN *> (S : 1'b1)) = (CSIN_10_LH_S, CSIN_10_HL_S) ;
                (posedge A *> (S : 1'b1)) = (A_01_LH_S, A_01_HL_S) ;
                (negedge A *> (S : 1'b1)) = (A_10_LH_S, A_10_HL_S) ;
                (posedge B *> (S : 1'b1)) = (B_01_LH_S, B_01_HL_S) ;
                (negedge B *> (S : 1'b1)) = (B_10_LH_S, B_10_HL_S) ;
                (A *> CO) = (A_LH_CO, A_HL_CO) ;
                (B *> CO) = (B_LH_CO, B_HL_CO) ;
        endspecify
endmodule

module hacs3a1(S, CO, A, CSIN);
        output S, CO;
        input  A, CSIN;
        xor g1(S, CSIN, A);
        not g2(CO, A);
        // SPECIFY BLOCK
        specify
                specparam CSIN_01_LH_S = 0, CSIN_01_HL_S = 0 ;
                specparam CSIN_10_LH_S = 0, CSIN_10_HL_S = 0 ;
                specparam A_01_LH_S = 0, A_01_HL_S = 0 ;
                specparam A_10_LH_S = 0, A_10_HL_S = 0 ;
                specparam A_LH_CO = 0, A_HL_CO = 0 ;
                (posedge CSIN *> (S : 1'b1)) = (CSIN_01_LH_S, CSIN_01_HL_S) ;
                (negedge CSIN *> (S : 1'b1)) = (CSIN_10_LH_S, CSIN_10_HL_S) ;
                (posedge A *> (S : 1'b1)) = (A_01_LH_S, A_01_HL_S) ;
                (negedge A *> (S : 1'b1)) = (A_10_LH_S, A_10_HL_S) ;
                (A *> CO) = (A_LH_CO, A_HL_CO) ;
        endspecify
endmodule

module hacs3a2(S, CO, A, CSIN);
        output S, CO;
        input  A, CSIN;
        xor g1(S, CSIN, A);
        not g2(CO, A);
        // SPECIFY BLOCK
        specify
                specparam CSIN_01_LH_S = 0, CSIN_01_HL_S = 0 ;
                specparam CSIN_10_LH_S = 0, CSIN_10_HL_S = 0 ;
                specparam A_01_LH_S = 0, A_01_HL_S = 0 ;
                specparam A_10_LH_S = 0, A_10_HL_S = 0 ;
                specparam A_LH_CO = 0, A_HL_CO = 0 ;
                (posedge CSIN *> (S : 1'b1)) = (CSIN_01_LH_S, CSIN_01_HL_S) ;
                (negedge CSIN *> (S : 1'b1)) = (CSIN_10_LH_S, CSIN_10_HL_S) ;
                (posedge A *> (S : 1'b1)) = (A_01_LH_S, A_01_HL_S) ;
                (negedge A *> (S : 1'b1)) = (A_10_LH_S, A_10_HL_S) ;
                (A *> CO) = (A_LH_CO, A_HL_CO) ;
        endspecify
endmodule

module hacs3a3(S, CO, A, CSIN);
        output S, CO;
        input  A, CSIN;
        xor g1(S, CSIN, A);
        not g2(CO, A);
        // SPECIFY BLOCK
        specify
                specparam CSIN_01_LH_S = 0, CSIN_01_HL_S = 0 ;
                specparam CSIN_10_LH_S = 0, CSIN_10_HL_S = 0 ;
                specparam A_01_LH_S = 0, A_01_HL_S = 0 ;
                specparam A_10_LH_S = 0, A_10_HL_S = 0 ;
                specparam A_LH_CO = 0, A_HL_CO = 0 ;
                (posedge CSIN *> (S : 1'b1)) = (CSIN_01_LH_S, CSIN_01_HL_S) ;
                (negedge CSIN *> (S : 1'b1)) = (CSIN_10_LH_S, CSIN_10_HL_S) ;
                (posedge A *> (S : 1'b1)) = (A_01_LH_S, A_01_HL_S) ;
                (negedge A *> (S : 1'b1)) = (A_10_LH_S, A_10_HL_S) ;
                (A *> CO) = (A_LH_CO, A_HL_CO) ;
        endspecify
endmodule

module mule2a1(S, M, Z, A, B, C);
        output S, M, Z;
        input  A, B, C;
        xnor g1(S, A, B);
        not g2(N3, A);
        not g3(N4, B);
        and g4(N2, N3, N4);
        or g5(M, C, N2);
        not g6(N6, C);
        and g7(N7, A, B);
        or g8(Z, N6, N7);
        // SPECIFY BLOCK
        specify
                specparam A_01_LH_S = 0, A_01_HL_S = 0 ;
                specparam A_10_LH_S = 0, A_10_HL_S = 0 ;
                specparam B_01_LH_S = 0, B_01_HL_S = 0 ;
                specparam B_10_LH_S = 0, B_10_HL_S = 0 ;
                specparam C_LH_M = 0, C_HL_M = 0 ;
                specparam A_LH_M = 0, A_HL_M = 0 ;
                specparam B_LH_M = 0, B_HL_M = 0 ;
                specparam C_LH_Z = 0, C_HL_Z = 0 ;
                specparam A_LH_Z = 0, A_HL_Z = 0 ;
                specparam B_LH_Z = 0, B_HL_Z = 0 ;
                (posedge A *> (S : 1'b1)) = (A_01_LH_S, A_01_HL_S) ;
                (negedge A *> (S : 1'b1)) = (A_10_LH_S, A_10_HL_S) ;
                (posedge B *> (S : 1'b1)) = (B_01_LH_S, B_01_HL_S) ;
                (negedge B *> (S : 1'b1)) = (B_10_LH_S, B_10_HL_S) ;
                (C *> M) = (C_LH_M, C_HL_M) ;
                (A *> M) = (A_LH_M, A_HL_M) ;
                (B *> M) = (B_LH_M, B_HL_M) ;
                (C *> Z) = (C_LH_Z, C_HL_Z) ;
                (A *> Z) = (A_LH_Z, A_HL_Z) ;
                (B *> Z) = (B_LH_Z, B_HL_Z) ;
        endspecify
endmodule

module mule2a2(S, M, Z, A, B, C);
        output S, M, Z;
        input  A, B, C;
        xnor g1(S, A, B);
        not g2(N3, A);
        not g3(N4, B);
        and g4(N2, N3, N4);
        or g5(M, C, N2);
        not g6(N6, C);
        and g7(N7, A, B);
        or g8(Z, N6, N7);
        // SPECIFY BLOCK
        specify
                specparam A_01_LH_S = 0, A_01_HL_S = 0 ;
                specparam A_10_LH_S = 0, A_10_HL_S = 0 ;
                specparam B_01_LH_S = 0, B_01_HL_S = 0 ;
                specparam B_10_LH_S = 0, B_10_HL_S = 0 ;
                specparam C_LH_M = 0, C_HL_M = 0 ;
                specparam A_LH_M = 0, A_HL_M = 0 ;
                specparam B_LH_M = 0, B_HL_M = 0 ;
                specparam C_LH_Z = 0, C_HL_Z = 0 ;
                specparam A_LH_Z = 0, A_HL_Z = 0 ;
                specparam B_LH_Z = 0, B_HL_Z = 0 ;
                (posedge A *> (S : 1'b1)) = (A_01_LH_S, A_01_HL_S) ;
                (negedge A *> (S : 1'b1)) = (A_10_LH_S, A_10_HL_S) ;
                (posedge B *> (S : 1'b1)) = (B_01_LH_S, B_01_HL_S) ;
                (negedge B *> (S : 1'b1)) = (B_10_LH_S, B_10_HL_S) ;
                (C *> M) = (C_LH_M, C_HL_M) ;
                (A *> M) = (A_LH_M, A_HL_M) ;
                (B *> M) = (B_LH_M, B_HL_M) ;
                (C *> Z) = (C_LH_Z, C_HL_Z) ;
                (A *> Z) = (A_LH_Z, A_HL_Z) ;
                (B *> Z) = (B_LH_Z, B_HL_Z) ;
        endspecify
endmodule

module mule2a3(S, M, Z, A, B, C);
        output S, M, Z;
        input  A, B, C;
        xnor g1(S, A, B);
        not g2(N3, A);
        not g3(N4, B);
        and g4(N2, N3, N4);
        or g5(M, C, N2);
        not g6(N6, C);
        and g7(N7, A, B);
        or g8(Z, N6, N7);
        // SPECIFY BLOCK
        specify
                specparam A_01_LH_S = 0, A_01_HL_S = 0 ;
                specparam A_10_LH_S = 0, A_10_HL_S = 0 ;
                specparam B_01_LH_S = 0, B_01_HL_S = 0 ;
                specparam B_10_LH_S = 0, B_10_HL_S = 0 ;
                specparam C_LH_M = 0, C_HL_M = 0 ;
                specparam A_LH_M = 0, A_HL_M = 0 ;
                specparam B_LH_M = 0, B_HL_M = 0 ;
                specparam C_LH_Z = 0, C_HL_Z = 0 ;
                specparam A_LH_Z = 0, A_HL_Z = 0 ;
                specparam B_LH_Z = 0, B_HL_Z = 0 ;
                (posedge A *> (S : 1'b1)) = (A_01_LH_S, A_01_HL_S) ;
                (negedge A *> (S : 1'b1)) = (A_10_LH_S, A_10_HL_S) ;
                (posedge B *> (S : 1'b1)) = (B_01_LH_S, B_01_HL_S) ;
                (negedge B *> (S : 1'b1)) = (B_10_LH_S, B_10_HL_S) ;
                (C *> M) = (C_LH_M, C_HL_M) ;
                (A *> M) = (A_LH_M, A_HL_M) ;
                (B *> M) = (B_LH_M, B_HL_M) ;
                (C *> Z) = (C_LH_Z, C_HL_Z) ;
                (A *> Z) = (A_LH_Z, A_HL_Z) ;
                (B *> Z) = (B_LH_Z, B_HL_Z) ;
        endspecify
endmodule

module mulpa1b1(P, X0, X1, S, Z, M);
        output P;
        input  X0, X1, S, Z, M;
        mux g1(N2, S, X1, X0);
        not g2(N1, N2);
        not g3(N3, M);
        not g4(N4, Z);
        mux g5(P, N1, N3, N4);
        // SPECIFY BLOCK
        specify
                specparam S_01_LH_P = 0, S_01_HL_P = 0 ;
                specparam S_10_LH_P = 0, S_10_HL_P = 0 ;
                specparam X1_01_LH_P = 0, X1_01_HL_P = 0 ;
                specparam X1_10_LH_P = 0, X1_10_HL_P = 0 ;
                specparam X0_01_LH_P = 0, X0_01_HL_P = 0 ;
                specparam X0_10_LH_P = 0, X0_10_HL_P = 0 ;
                specparam M_LH_P = 0, M_HL_P = 0 ;
                specparam Z_LH_P = 0, Z_HL_P = 0 ;
                (posedge S *> (P : 1'b1)) = (S_01_LH_P, S_01_HL_P) ;
                (negedge S *> (P : 1'b1)) = (S_10_LH_P, S_10_HL_P) ;
                (posedge X1 *> (P : 1'b1)) = (X1_01_LH_P, X1_01_HL_P) ;
                (negedge X1 *> (P : 1'b1)) = (X1_10_LH_P, X1_10_HL_P) ;
                (posedge X0 *> (P : 1'b1)) = (X0_01_LH_P, X0_01_HL_P) ;
                (negedge X0 *> (P : 1'b1)) = (X0_10_LH_P, X0_10_HL_P) ;
                (M *> P) = (M_LH_P, M_HL_P) ;
                (Z *> P) = (Z_LH_P, Z_HL_P) ;
        endspecify
endmodule

module mulpa1b2(P, X0, X1, S, Z, M);
        output P;
        input  X0, X1, S, Z, M;
        mux g1(N2, S, X1, X0);
        not g2(N1, N2);
        not g3(N3, M);
        not g4(N4, Z);
        mux g5(P, N1, N3, N4);
        // SPECIFY BLOCK
        specify
                specparam S_01_LH_P = 0, S_01_HL_P = 0 ;
                specparam S_10_LH_P = 0, S_10_HL_P = 0 ;
                specparam X1_01_LH_P = 0, X1_01_HL_P = 0 ;
                specparam X1_10_LH_P = 0, X1_10_HL_P = 0 ;
                specparam X0_01_LH_P = 0, X0_01_HL_P = 0 ;
                specparam X0_10_LH_P = 0, X0_10_HL_P = 0 ;
                specparam M_LH_P = 0, M_HL_P = 0 ;
                specparam Z_LH_P = 0, Z_HL_P = 0 ;
                (posedge S *> (P : 1'b1)) = (S_01_LH_P, S_01_HL_P) ;
                (negedge S *> (P : 1'b1)) = (S_10_LH_P, S_10_HL_P) ;
                (posedge X1 *> (P : 1'b1)) = (X1_01_LH_P, X1_01_HL_P) ;
                (negedge X1 *> (P : 1'b1)) = (X1_10_LH_P, X1_10_HL_P) ;
                (posedge X0 *> (P : 1'b1)) = (X0_01_LH_P, X0_01_HL_P) ;
                (negedge X0 *> (P : 1'b1)) = (X0_10_LH_P, X0_10_HL_P) ;
                (M *> P) = (M_LH_P, M_HL_P) ;
                (Z *> P) = (Z_LH_P, Z_HL_P) ;
        endspecify
endmodule

module mulpa1b3(P, X0, X1, S, Z, M);
        output P;
        input  X0, X1, S, Z, M;
        mux g1(N2, S, X1, X0);
        not g2(N1, N2);
        not g3(N3, M);
        not g4(N4, Z);
        mux g5(P, N1, N3, N4);
        // SPECIFY BLOCK
        specify
                specparam S_01_LH_P = 0, S_01_HL_P = 0 ;
                specparam S_10_LH_P = 0, S_10_HL_P = 0 ;
                specparam X1_01_LH_P = 0, X1_01_HL_P = 0 ;
                specparam X1_10_LH_P = 0, X1_10_HL_P = 0 ;
                specparam X0_01_LH_P = 0, X0_01_HL_P = 0 ;
                specparam X0_10_LH_P = 0, X0_10_HL_P = 0 ;
                specparam M_LH_P = 0, M_HL_P = 0 ;
                specparam Z_LH_P = 0, Z_HL_P = 0 ;
                (posedge S *> (P : 1'b1)) = (S_01_LH_P, S_01_HL_P) ;
                (negedge S *> (P : 1'b1)) = (S_10_LH_P, S_10_HL_P) ;
                (posedge X1 *> (P : 1'b1)) = (X1_01_LH_P, X1_01_HL_P) ;
                (negedge X1 *> (P : 1'b1)) = (X1_10_LH_P, X1_10_HL_P) ;
                (posedge X0 *> (P : 1'b1)) = (X0_01_LH_P, X0_01_HL_P) ;
                (negedge X0 *> (P : 1'b1)) = (X0_10_LH_P, X0_10_HL_P) ;
                (M *> P) = (M_LH_P, M_HL_P) ;
                (Z *> P) = (Z_LH_P, Z_HL_P) ;
        endspecify
endmodule

module mulpa2b1(P, X0, X1, S, Z, M);
        output P;
        input  X0, X1, S, Z, M;
        mux g1(N3, S, X1, X0);
        not g2(N2, N3);
        not g3(N4, M);
        not g4(N5, Z);
        mux g5(N1, N2, N4, N5);
        not g6(P, N1);
        // SPECIFY BLOCK
        specify
                specparam S_01_LH_P = 0, S_01_HL_P = 0 ;
                specparam S_10_LH_P = 0, S_10_HL_P = 0 ;
                specparam X1_01_LH_P = 0, X1_01_HL_P = 0 ;
                specparam X1_10_LH_P = 0, X1_10_HL_P = 0 ;
                specparam X0_01_LH_P = 0, X0_01_HL_P = 0 ;
                specparam X0_10_LH_P = 0, X0_10_HL_P = 0 ;
                specparam M_LH_P = 0, M_HL_P = 0 ;
                specparam Z_LH_P = 0, Z_HL_P = 0 ;
                (posedge S *> (P : 1'b1)) = (S_01_LH_P, S_01_HL_P) ;
                (negedge S *> (P : 1'b1)) = (S_10_LH_P, S_10_HL_P) ;
                (posedge X1 *> (P : 1'b1)) = (X1_01_LH_P, X1_01_HL_P) ;
                (negedge X1 *> (P : 1'b1)) = (X1_10_LH_P, X1_10_HL_P) ;
                (posedge X0 *> (P : 1'b1)) = (X0_01_LH_P, X0_01_HL_P) ;
                (negedge X0 *> (P : 1'b1)) = (X0_10_LH_P, X0_10_HL_P) ;
                (M *> P) = (M_LH_P, M_HL_P) ;
                (Z *> P) = (Z_LH_P, Z_HL_P) ;
        endspecify
endmodule

module mulpa2b2(P, X0, X1, S, Z, M);
        output P;
        input  X0, X1, S, Z, M;
        mux g1(N3, S, X1, X0);
        not g2(N2, N3);
        not g3(N4, M);
        not g4(N5, Z);
        mux g5(N1, N2, N4, N5);
        not g6(P, N1);
        // SPECIFY BLOCK
        specify
                specparam S_01_LH_P = 0, S_01_HL_P = 0 ;
                specparam S_10_LH_P = 0, S_10_HL_P = 0 ;
                specparam X1_01_LH_P = 0, X1_01_HL_P = 0 ;
                specparam X1_10_LH_P = 0, X1_10_HL_P = 0 ;
                specparam X0_01_LH_P = 0, X0_01_HL_P = 0 ;
                specparam X0_10_LH_P = 0, X0_10_HL_P = 0 ;
                specparam M_LH_P = 0, M_HL_P = 0 ;
                specparam Z_LH_P = 0, Z_HL_P = 0 ;
                (posedge S *> (P : 1'b1)) = (S_01_LH_P, S_01_HL_P) ;
                (negedge S *> (P : 1'b1)) = (S_10_LH_P, S_10_HL_P) ;
                (posedge X1 *> (P : 1'b1)) = (X1_01_LH_P, X1_01_HL_P) ;
                (negedge X1 *> (P : 1'b1)) = (X1_10_LH_P, X1_10_HL_P) ;
                (posedge X0 *> (P : 1'b1)) = (X0_01_LH_P, X0_01_HL_P) ;
                (negedge X0 *> (P : 1'b1)) = (X0_10_LH_P, X0_10_HL_P) ;
                (M *> P) = (M_LH_P, M_HL_P) ;
                (Z *> P) = (Z_LH_P, Z_HL_P) ;
        endspecify
endmodule

module mulpa2b3(P, X0, X1, S, Z, M);
        output P;
        input  X0, X1, S, Z, M;
        mux g1(N3, S, X1, X0);
        not g2(N2, N3);
        not g3(N4, M);
        not g4(N5, Z);
        mux g5(N1, N2, N4, N5);
        not g6(P, N1);
        // SPECIFY BLOCK
        specify
                specparam S_01_LH_P = 0, S_01_HL_P = 0 ;
                specparam S_10_LH_P = 0, S_10_HL_P = 0 ;
                specparam X1_01_LH_P = 0, X1_01_HL_P = 0 ;
                specparam X1_10_LH_P = 0, X1_10_HL_P = 0 ;
                specparam X0_01_LH_P = 0, X0_01_HL_P = 0 ;
                specparam X0_10_LH_P = 0, X0_10_HL_P = 0 ;
                specparam M_LH_P = 0, M_HL_P = 0 ;
                specparam Z_LH_P = 0, Z_HL_P = 0 ;
                (posedge S *> (P : 1'b1)) = (S_01_LH_P, S_01_HL_P) ;
                (negedge S *> (P : 1'b1)) = (S_10_LH_P, S_10_HL_P) ;
                (posedge X1 *> (P : 1'b1)) = (X1_01_LH_P, X1_01_HL_P) ;
                (negedge X1 *> (P : 1'b1)) = (X1_10_LH_P, X1_10_HL_P) ;
                (posedge X0 *> (P : 1'b1)) = (X0_01_LH_P, X0_01_HL_P) ;
                (negedge X0 *> (P : 1'b1)) = (X0_10_LH_P, X0_10_HL_P) ;
                (M *> P) = (M_LH_P, M_HL_P) ;
                (Z *> P) = (Z_LH_P, Z_HL_P) ;
        endspecify
endmodule

module mulpa3b1(P, X0, X1, S, Z, M);
        output P;
        input  X0, X1, S, Z, M;
        mux g1(N2, S, X1, X0);
        not g2(N1, N2);
        not g3(N3, M);
        not g4(N4, Z);
        mux g5(P, N1, N3, N4);
        // SPECIFY BLOCK
        specify
                specparam S_01_LH_P = 0, S_01_HL_P = 0 ;
                specparam S_10_LH_P = 0, S_10_HL_P = 0 ;
                specparam X1_01_LH_P = 0, X1_01_HL_P = 0 ;
                specparam X1_10_LH_P = 0, X1_10_HL_P = 0 ;
                specparam X0_01_LH_P = 0, X0_01_HL_P = 0 ;
                specparam X0_10_LH_P = 0, X0_10_HL_P = 0 ;
                specparam M_LH_P = 0, M_HL_P = 0 ;
                specparam Z_LH_P = 0, Z_HL_P = 0 ;
                (posedge S *> (P : 1'b1)) = (S_01_LH_P, S_01_HL_P) ;
                (negedge S *> (P : 1'b1)) = (S_10_LH_P, S_10_HL_P) ;
                (posedge X1 *> (P : 1'b1)) = (X1_01_LH_P, X1_01_HL_P) ;
                (negedge X1 *> (P : 1'b1)) = (X1_10_LH_P, X1_10_HL_P) ;
                (posedge X0 *> (P : 1'b1)) = (X0_01_LH_P, X0_01_HL_P) ;
                (negedge X0 *> (P : 1'b1)) = (X0_10_LH_P, X0_10_HL_P) ;
                (M *> P) = (M_LH_P, M_HL_P) ;
                (Z *> P) = (Z_LH_P, Z_HL_P) ;
        endspecify
endmodule

module mulpa3b2(P, X0, X1, S, Z, M);
        output P;
        input  X0, X1, S, Z, M;
        mux g1(N2, S, X1, X0);
        not g2(N1, N2);
        not g3(N3, M);
        not g4(N4, Z);
        mux g5(P, N1, N3, N4);
        // SPECIFY BLOCK
        specify
                specparam S_01_LH_P = 0, S_01_HL_P = 0 ;
                specparam S_10_LH_P = 0, S_10_HL_P = 0 ;
                specparam X1_01_LH_P = 0, X1_01_HL_P = 0 ;
                specparam X1_10_LH_P = 0, X1_10_HL_P = 0 ;
                specparam X0_01_LH_P = 0, X0_01_HL_P = 0 ;
                specparam X0_10_LH_P = 0, X0_10_HL_P = 0 ;
                specparam M_LH_P = 0, M_HL_P = 0 ;
                specparam Z_LH_P = 0, Z_HL_P = 0 ;
                (posedge S *> (P : 1'b1)) = (S_01_LH_P, S_01_HL_P) ;
                (negedge S *> (P : 1'b1)) = (S_10_LH_P, S_10_HL_P) ;
                (posedge X1 *> (P : 1'b1)) = (X1_01_LH_P, X1_01_HL_P) ;
                (negedge X1 *> (P : 1'b1)) = (X1_10_LH_P, X1_10_HL_P) ;
                (posedge X0 *> (P : 1'b1)) = (X0_01_LH_P, X0_01_HL_P) ;
                (negedge X0 *> (P : 1'b1)) = (X0_10_LH_P, X0_10_HL_P) ;
                (M *> P) = (M_LH_P, M_HL_P) ;
                (Z *> P) = (Z_LH_P, Z_HL_P) ;
        endspecify
endmodule

module mulpa3b3(P, X0, X1, S, Z, M);
        output P;
        input  X0, X1, S, Z, M;
        mux g1(N2, S, X1, X0);
        not g2(N1, N2);
        not g3(N3, M);
        not g4(N4, Z);
        mux g5(P, N1, N3, N4);
        // SPECIFY BLOCK
        specify
                specparam S_01_LH_P = 0, S_01_HL_P = 0 ;
                specparam S_10_LH_P = 0, S_10_HL_P = 0 ;
                specparam X1_01_LH_P = 0, X1_01_HL_P = 0 ;
                specparam X1_10_LH_P = 0, X1_10_HL_P = 0 ;
                specparam X0_01_LH_P = 0, X0_01_HL_P = 0 ;
                specparam X0_10_LH_P = 0, X0_10_HL_P = 0 ;
                specparam M_LH_P = 0, M_HL_P = 0 ;
                specparam Z_LH_P = 0, Z_HL_P = 0 ;
                (posedge S *> (P : 1'b1)) = (S_01_LH_P, S_01_HL_P) ;
                (negedge S *> (P : 1'b1)) = (S_10_LH_P, S_10_HL_P) ;
                (posedge X1 *> (P : 1'b1)) = (X1_01_LH_P, X1_01_HL_P) ;
                (negedge X1 *> (P : 1'b1)) = (X1_10_LH_P, X1_10_HL_P) ;
                (posedge X0 *> (P : 1'b1)) = (X0_01_LH_P, X0_01_HL_P) ;
                (negedge X0 *> (P : 1'b1)) = (X0_10_LH_P, X0_10_HL_P) ;
                (M *> P) = (M_LH_P, M_HL_P) ;
                (Z *> P) = (Z_LH_P, Z_HL_P) ;
        endspecify
endmodule

module mulpa4b1(P, X0, X1, S, Z, M);
        output P;
        input  X0, X1, S, Z, M;
        mux g1(N3, S, X1, X0);
        not g2(N2, N3);
        not g3(N4, M);
        not g4(N5, Z);
        mux g5(N1, N2, N4, N5);
        not g6(P, N1);
        // SPECIFY BLOCK
        specify
                specparam S_01_LH_P = 0, S_01_HL_P = 0 ;
                specparam S_10_LH_P = 0, S_10_HL_P = 0 ;
                specparam X1_01_LH_P = 0, X1_01_HL_P = 0 ;
                specparam X1_10_LH_P = 0, X1_10_HL_P = 0 ;
                specparam X0_01_LH_P = 0, X0_01_HL_P = 0 ;
                specparam X0_10_LH_P = 0, X0_10_HL_P = 0 ;
                specparam M_LH_P = 0, M_HL_P = 0 ;
                specparam Z_LH_P = 0, Z_HL_P = 0 ;
                (posedge S *> (P : 1'b1)) = (S_01_LH_P, S_01_HL_P) ;
                (negedge S *> (P : 1'b1)) = (S_10_LH_P, S_10_HL_P) ;
                (posedge X1 *> (P : 1'b1)) = (X1_01_LH_P, X1_01_HL_P) ;
                (negedge X1 *> (P : 1'b1)) = (X1_10_LH_P, X1_10_HL_P) ;
                (posedge X0 *> (P : 1'b1)) = (X0_01_LH_P, X0_01_HL_P) ;
                (negedge X0 *> (P : 1'b1)) = (X0_10_LH_P, X0_10_HL_P) ;
                (M *> P) = (M_LH_P, M_HL_P) ;
                (Z *> P) = (Z_LH_P, Z_HL_P) ;
        endspecify
endmodule

module mulpa4b2(P, X0, X1, S, Z, M);
        output P;
        input  X0, X1, S, Z, M;
        mux g1(N3, S, X1, X0);
        not g2(N2, N3);
        not g3(N4, M);
        not g4(N5, Z);
        mux g5(N1, N2, N4, N5);
        not g6(P, N1);
        // SPECIFY BLOCK
        specify
                specparam S_01_LH_P = 0, S_01_HL_P = 0 ;
                specparam S_10_LH_P = 0, S_10_HL_P = 0 ;
                specparam X1_01_LH_P = 0, X1_01_HL_P = 0 ;
                specparam X1_10_LH_P = 0, X1_10_HL_P = 0 ;
                specparam X0_01_LH_P = 0, X0_01_HL_P = 0 ;
                specparam X0_10_LH_P = 0, X0_10_HL_P = 0 ;
                specparam M_LH_P = 0, M_HL_P = 0 ;
                specparam Z_LH_P = 0, Z_HL_P = 0 ;
                (posedge S *> (P : 1'b1)) = (S_01_LH_P, S_01_HL_P) ;
                (negedge S *> (P : 1'b1)) = (S_10_LH_P, S_10_HL_P) ;
                (posedge X1 *> (P : 1'b1)) = (X1_01_LH_P, X1_01_HL_P) ;
                (negedge X1 *> (P : 1'b1)) = (X1_10_LH_P, X1_10_HL_P) ;
                (posedge X0 *> (P : 1'b1)) = (X0_01_LH_P, X0_01_HL_P) ;
                (negedge X0 *> (P : 1'b1)) = (X0_10_LH_P, X0_10_HL_P) ;
                (M *> P) = (M_LH_P, M_HL_P) ;
                (Z *> P) = (Z_LH_P, Z_HL_P) ;
        endspecify
endmodule

module mulpa4b3(P, X0, X1, S, Z, M);
        output P;
        input  X0, X1, S, Z, M;
        mux g1(N3, S, X1, X0);
        not g2(N2, N3);
        not g3(N4, M);
        not g4(N5, Z);
        mux g5(N1, N2, N4, N5);
        not g6(P, N1);
        // SPECIFY BLOCK
        specify
                specparam S_01_LH_P = 0, S_01_HL_P = 0 ;
                specparam S_10_LH_P = 0, S_10_HL_P = 0 ;
                specparam X1_01_LH_P = 0, X1_01_HL_P = 0 ;
                specparam X1_10_LH_P = 0, X1_10_HL_P = 0 ;
                specparam X0_01_LH_P = 0, X0_01_HL_P = 0 ;
                specparam X0_10_LH_P = 0, X0_10_HL_P = 0 ;
                specparam M_LH_P = 0, M_HL_P = 0 ;
                specparam Z_LH_P = 0, Z_HL_P = 0 ;
                (posedge S *> (P : 1'b1)) = (S_01_LH_P, S_01_HL_P) ;
                (negedge S *> (P : 1'b1)) = (S_10_LH_P, S_10_HL_P) ;
                (posedge X1 *> (P : 1'b1)) = (X1_01_LH_P, X1_01_HL_P) ;
                (negedge X1 *> (P : 1'b1)) = (X1_10_LH_P, X1_10_HL_P) ;
                (posedge X0 *> (P : 1'b1)) = (X0_01_LH_P, X0_01_HL_P) ;
                (negedge X0 *> (P : 1'b1)) = (X0_10_LH_P, X0_10_HL_P) ;
                (M *> P) = (M_LH_P, M_HL_P) ;
                (Z *> P) = (Z_LH_P, Z_HL_P) ;
        endspecify
endmodule

module fill8 ();
endmodule

module fill4 ();
endmodule

module fill2 ();
endmodule

module fill1 ();
endmodule

`endcelldefine
