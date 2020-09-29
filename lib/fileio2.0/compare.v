`define EOF 32'hFFFF_FFFF
`define NULL 0
`define MAX_LINE_LENGTH 1000
module compare;
  integer file, r;
  reg a, b, expect, clock;
  wire out;
  reg [8*`MAX_LINE_LENGTH-1:0] line;
  parameter cycle = 20;

  initial
     begin : file_block
        clock = 0;
       
       file = $fopenr("compare.pat");
       if (file == `NULL)
	 disable file_block;
       $display("      Time Stim  Expect Output");

       // Skip comments
       r = $fgets(line, `MAX_LINE_LENGTH, file);
       r = $fgets(line, `MAX_LINE_LENGTH, file);

       while (!$feof(file))
	 begin
	   // Wait until rising clock, read stimulus
	   @(posedge clock)
	     r = $fscanf(file, " %b %b %b\n", a, b, expect);

	   // Wait just before the end of cycle to compare
	   #(cycle - 1)
       	   $display("%d %b %b   %b      %b", $stime, a, b, expect, out);
	   $strobe_compare(expect, out);
       	 end // while not EOF

        r = $fcloser(file);
     	$stop;
     end // initial

  // Clock generator
  always #(cycle / 2) clock = !clock;
    
  // Circuit under test
  and #4 (out, a, b);

endmodule // compare

