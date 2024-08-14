
module RefModule (
  input a,
  input b,
  input c,
  input d,
  output reg out
);

  always @(*) begin
    case({a,b,c,d})
      4'h0: out = 0;
      4'h1: out = 1;
      4'h3: out = 0;
      4'h2: out = 1;
      4'h4: out = 1;
      4'h5: out = 0;
      4'h7: out = 1;
      4'h6: out = 0;
      4'hc: out = 0;
      4'hd: out = 1;
      4'hf: out = 0;
      4'he: out = 1;
      4'h8: out = 1;
      4'h9: out = 0;
      4'hb: out = 1;
      4'ha: out = 0;
    endcase
  end

endmodule

