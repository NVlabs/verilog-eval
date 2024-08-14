
module RefModule (
  input clk,
  input reset,
  input w,
  output z
);

  parameter A=0, B=1, C=2, D=3, E=4, F=5;
  reg [2:0] state, next;

  always @(posedge clk)
    if (reset)
      state <= A;
    else
      state <= next;

  always_comb begin
    case(state)
      A: next = w ? A : B;
      B: next = w ? D : C;
      C: next = w ? D : E;
      D: next = w ? A : F;
      E: next = w ? D : E;
      F: next = w ? D : C;
      default: next = 'x;
    endcase
  end

  assign z = (state == E || state == F);

endmodule

