
module RefModule (
  input clk,
  input resetn,
  input  [2:0] r,
  output [2:0] g
);

  parameter A=0, B=1, C=2, D=3;
  reg [1:0] state, next;

  always @(posedge clk) begin
    if (~resetn) state <= A;
    else state <= next;
  end

  always@(state,r) begin
    case (state)
      A: if (r[0]) next = B;
         else if (r[1]) next = C;
         else if (r[2]) next = D;
         else next = A;
      B: next = r[0] ? B : A;
      C: next = r[1] ? C : A;
      D: next = r[2] ? D : A;
      default: next = 'x;
    endcase
  end

  assign g[0] = (state == B);
  assign g[1] = (state == C);
  assign g[2] = (state == D);

endmodule

