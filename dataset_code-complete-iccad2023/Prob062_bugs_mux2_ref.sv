
module RefModule (
  input sel,
  input [7:0] a,
  input [7:0] b,
  output reg [7:0] out
);

  // assign out = (~sel & a) | (sel & b);
  assign out = sel ? a : b;

endmodule

