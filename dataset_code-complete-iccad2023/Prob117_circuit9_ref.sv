
module RefModule (
  input clk,
  input a,
  output reg [2:0] q
);

  always @(posedge clk)
    if (a)
      q <= 4;
    else if (q == 6)
      q <= 0;
    else
      q <= q + 1'b1;

endmodule

