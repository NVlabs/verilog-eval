
module RefModule (
  input clk,
  input reset,
  input data,
  output start_shifting
);

  parameter S=0, S1=1, S11=2, S110=3, Done=4;

  reg [2:0] state, next;

  always_comb begin
    case (state)
      S: next = data ? S1: S;
      S1: next = data ? S11: S;
      S11: next = data ? S11 : S110;
      S110: next = data ? Done : S;
      Done: next = Done;
    endcase
  end

  always @(posedge clk)
    if (reset) state <= S;
    else state <= next;

  assign start_shifting = state == Done;

endmodule

