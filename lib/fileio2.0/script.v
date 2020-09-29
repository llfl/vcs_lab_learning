`define EOF 32'hFFFF_FFFF
`define NULL 0
module script;
  integer file, r;
  reg clock;
  reg [80*8:1] command;
  reg [31:0] addr, data;
  parameter cycle = 20;

  initial
     begin : file_block
        clock = 0;
       
       file = $fopenr("script.txt");
       if (file == `NULL)
	 disable file_block;
	 
       while (!$feof(file))
	 begin
	   r = $fscanf(file, " %s %h %h \n", command, addr, data);
	   case (command)
	     "read":
	        $display("READ mem[%h], expect = %h", addr, data);
	     "write":
	        $display("WRITE mem[%h] = %h", addr, data);
	     default:
	        $display("Unknown command '%0s'", command);
	   endcase
       	 end // while not EOF

        r = $fcloser(file);
     	$stop;
     end // initial

endmodule // script

