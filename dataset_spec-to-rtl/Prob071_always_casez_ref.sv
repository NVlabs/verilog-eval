
module RefModule (
  input [7:0] in,
  output reg [2:0] pos
);

  always @(*) begin
    casez (in)
      default : pos = 2'h0;
      8'bzzzzzzz1: pos = 3'h0;
      8'bzzzzzz1z: pos = 3'h1;
      8'bzzzzz1zz: pos = 3'h2;
      8'bzzzz1zzz: pos = 3'h3;
      8'bzzz1zzzz: pos = 3'h4;
      8'bzz1zzzzz: pos = 3'h5;
      8'bz1zzzzzz: pos = 3'h6;
      8'b1zzzzzzz: pos = 3'h7;
    endcase
  end

endmodule

