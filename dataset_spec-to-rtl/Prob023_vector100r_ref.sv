
module RefModule (
  input [99:0] in,
  output reg [99:0] out
);

  always_comb
    for (int i=0;i<$bits(out);i++)
      out[i] = in[$bits(out)-i-1];

endmodule

