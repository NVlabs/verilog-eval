
module RefModule (
  input [15:0] a,
  input [15:0] b,
  input [15:0] c,
  input [15:0] d,
  input [15:0] e,
  input [15:0] f,
  input [15:0] g,
  input [15:0] h,
  input [15:0] i,
  input [3:0] sel,
  output logic [15:0] out
);

  always @(*) begin
    out = '1;
    case (sel)
      4'h0: out = a;
      4'h1: out = b;
      4'h2: out = c;
      4'h3: out = d;
      4'h4: out = e;
      4'h5: out = f;
      4'h6: out = g;
      4'h7: out = h;
      4'h8: out = i;
    endcase
  end

endmodule

