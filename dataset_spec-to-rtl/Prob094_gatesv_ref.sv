
module RefModule (
  input  [3:0] in,
  output [3:0] out_both,
  output [3:0] out_any,
  output [3:0] out_different
);

  assign out_both[2:0] = in[2:0] & in[3:1];
  assign out_any[3:1]  = in[2:0] | in[3:1];
  assign out_different = in^{in[0], in[3:1]};

  // we don't care about out_both[3] or out_any[0]
  assign out_both[3] = 1'bx;
  assign out_any[0]  = 1'bx;

endmodule

