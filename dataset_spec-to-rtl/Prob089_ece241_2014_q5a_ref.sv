
module RefModule (
  input clk,
  input areset,
  input x,
  output z
);

  parameter A=0,B=1,C=2;
  reg [1:0] state;
  always @(posedge clk, posedge areset) begin
    if (areset)
      state <= A;
    else begin
      case (state)
        A: state <= x ? C : A;
        B: state <= x ? B : C;
        C: state <= x ? B : C;
      endcase
    end
  end

  assign z = (state == C);

endmodule

