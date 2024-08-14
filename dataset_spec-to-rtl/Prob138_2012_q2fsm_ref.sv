
module RefModule (
  input clk,
  input reset,
  input w,
  output z
);

  parameter A=0,B=1,C=2,D=3,E=4,F=5;
  reg[2:0] state, next;

  always @(posedge clk)
    if (reset) state <= A;
    else state <= next;

  always_comb begin
    case (state)
      A: next = w ? B : A;
      B: next = w ? C : D;
      C: next = w ? E : D;
      D: next = w ? F : A;
      E: next = w ? E : D;
      F: next = w ? C : D;
      default: next = 'x;
    endcase
  end

  assign z = (state == E) || (state == F);

endmodule

