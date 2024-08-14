
module RefModule (
  input clk,
  input reset,
  input s,
  input w,
  output reg z
);

  parameter A=0, B=1, C=2, S10=3, S11=4, S20=5, S21=6, S22=7;
  reg [2:0] state, next;

  always @(posedge clk) begin
    if (reset) state <= A;
    else state <= next;
  end

  always_comb begin
    case (state)
      A: next = s ? B : A;
      B: next = w ? S11 : S10;
      C: next = w ? S11 : S10;
      S10: next = w ? S21 : S20;
      S11: next = w ? S22 : S21;
      S20: next = B;
      S21: next = w ? C : B;
      S22: next = w ? B : C;
      default: next = 'x;
    endcase
  end

  assign z = (state == C);

endmodule

