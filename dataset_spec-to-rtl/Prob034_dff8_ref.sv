
module RefModule (
  input clk,
  input [7:0] d,
  output reg [7:0] q
);

  initial
    q = 8'hx;

  always @(posedge clk)
    q <= d;

endmodule

