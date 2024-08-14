
module RefModule (
  input [7:0] in,
  output [7:0] out
);

  assign {out[0],out[1],out[2],out[3],out[4],out[5],out[6],out[7]} = in;

endmodule

