
module RefModule (
  input clk,
  input resetn,
  input x,
  input y,
  output f,
  output g
);

  parameter A=0, B=1, S0=2, S1=3, S10=4, G1=5, G2=6, P0=7, P1=8;
  reg [3:0] state, next;

  always @(posedge clk) begin
    if (~resetn) state <= A;
    else state <= next;
  end

  always_comb begin
    case (state)
      A: next = B;
      B: next = S0;
      S0: next = x ? S1 : S0;
      S1: next = x ? S1 : S10;
      S10: next = x? G1 : S0;
      G1: next = y ? P1 : G2;
      G2: next = y ? P1 : P0;
      P0: next = P0;
      P1: next = P1;
      default: next = 'x;
    endcase
  end

  assign f = (state == B);
  assign g = (state == G1) || (state == G2) || (state == P1);

endmodule

