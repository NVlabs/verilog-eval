
module RefModule (
  input clk,
  input reset,
  input x,
  output reg z
);

  parameter A=0, B=1, C=2, D=3, E=4;
  reg [2:0] state, next;

  always @(posedge clk) begin
    if (reset) state <= A;
    else state <= next;
  end

  always_comb begin
    case (state)
      A: next = x ? B : A;
      B: next = x ? E : B;
      C: next = x ? B : C;
      D: next = x ? C : B;
      E: next = x ? E : D;
      default: next = 'x;
    endcase
  end

  assign z = (state == D) || (state == E);

endmodule

