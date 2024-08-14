
module RefModule (
  input [2:0] y,
  input w,
  output reg Y1
);

  always_comb begin
    case ({y, w})
      4'h0: Y1 = 1'b0;
      4'h1: Y1 = 1'b0;
      4'h2: Y1 = 1'b1;
      4'h3: Y1 = 1'b1;
      4'h4: Y1 = 1'b0;
      4'h5: Y1 = 1'b1;
      4'h6: Y1 = 1'b0;
      4'h7: Y1 = 1'b0;
      4'h8: Y1 = 1'b0;
      4'h9: Y1 = 1'b1;
      4'ha: Y1 = 1'b1;
      4'hb: Y1 = 1'b1;
      default: Y1 = 1'bx;
    endcase
  end

endmodule

