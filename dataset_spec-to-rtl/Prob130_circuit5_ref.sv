
module RefModule (
  input [3:0] a,
  input [3:0] b,
  input [3:0] c,
  input [3:0] d,
  input [3:0] e,
  output reg [3:0] q
);

  always @(*)
    case (c)
      0: q = b;
      1: q = e;
      2: q = a;
      3: q = d;
      default: q = 4'hf;
    endcase

endmodule

