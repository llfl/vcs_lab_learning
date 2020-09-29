module addertb;
reg [7:0] a_test, b_test;
wire [7:0] sum_test;
reg cin_test;
wire cout_test;
reg [17:0] test;

add8 u1(a_test, b_test, cin_test, sum_test, cout_test);

initial
begin
  for (test = 0; test <= 18'h1ffff; test = test +1) begin
    cin_test = test[16];
    a_test = test[15:8];
    b_test = test[7:0];
    #50;
    if ({cout_test, sum_test} !== (a_test + b_test + cin_test)) begin
      $display("***ERROR at time = %0d ***", $time);
      $display("a = %h, b = %h, sum = %h;  cin = %h, cout = %h",
               a_test, b_test, sum_test, cin_test, cout_test);
      $finish;
    end
    #50;
  end
  $display("*** Testbench Successfully completed! ***");
  $finish;
end
endmodule
