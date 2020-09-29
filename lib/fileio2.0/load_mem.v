`define NULL 0
`define MEM_SIZE 200_000
module load_mem;
  integer file, i;
  reg [7:0] mem[0:`MEM_SIZE];
  reg [80*8:1] file_name;

  initial
    begin
      file_name = "data.bin";
      file = $fopenr(file_name);
      i = $fread(file, mem[0]);
      $display("Loaded %0d entries \n", i);
      i = $fcloser(file);
      $stop;
    end

endmodule // load_mem
