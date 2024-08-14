
module RefModule (
  input clk,
  input reset,
  output shift_ena
);

  parameter B0=0, B1=1, B2=2, B3=3, Done=4;

  reg [2:0] state, next;

  always_comb begin
    case (state)
      B0: next = B1;
      B1: next = B2;
      B2: next = B3;
      B3: next = Done;
      Done: next = Done;
    endcase
  end

  always @(posedge clk)
    if (reset) state <= B0;
    else state <= next;

  assign shift_ena = (state == B0 || state == B1 || state == B2 || state == B3);

endmodule

