`default_nettype none

`timescale 1us/10ns

module Test;
  reg clk = 0;
  reg trigger = 0;
  reg [7:0] counter = 0;
  reg [3:0] A = 0;
  reg [3:0] B = 0;
  reg [4:0] C = 0;
  reg O = 0;
  wire out;


  always @(*) begin
  end



  always #1 begin
    clk = ~clk;
    if (clk == 1) begin
      counter = counter + 1;
    end
  end

  initial begin
    $display("Suite 6ecad997a7e93c1419f9f5fbfb");
    $display("--start header--");
    $display("Testing");
    $display("c53de124110ba60249ebd5343d:Add should make sense");
    $display("--end header--");
    $display("Begin c53de124110ba60249ebd5343d");
    A = 4'b0111;
    B = 4'b0001;
    C = A + B;
    O = ((A[3]) == B[3]) && ((C[3]) != B[3]);
    repeat(1) @(posedge clk);
    $display(C);
    if (~(C == 5'b11110)) begin
      $display("Failed c53de124110ba60249ebd5343d");
      $display("");
      $finish();
    end
    $display("End c53de124110ba60249ebd5343d");
    $display("End Suite 6ecad997a7e93c1419f9f5fbfb");
    $finish;
  end
  initial begin
    $dumpfile("test.vcd");
    $dumpvars(0);
  end
endmodule