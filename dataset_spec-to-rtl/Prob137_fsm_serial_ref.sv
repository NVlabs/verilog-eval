
module RefModule (
  input clk,
  input in,
  input reset,
  output done
);

  parameter B0=0, B1=1, B2=2, B3=3, B4=4, B5=5, B6=6, B7=7, START=8, STOP=9, DONE=10, ERR=11;
  reg [3:0] state;
  reg [3:0] next;

  always_comb begin
    case (state)
      START: next = in ? START : B0;  // start bit is 0
      B0: next = B1;
      B1: next = B2;
      B2: next = B3;
      B3: next = B4;
      B4: next = B5;
      B5: next = B6;
      B6: next = B7;
      B7: next = STOP;
      STOP: next = in ? DONE : ERR;  // stop bit is 1. Idle state is 1.
      DONE: next = in ? START : B0;
      ERR: next = in ? START : ERR;
    endcase
  end

  always @(posedge clk) begin
    if (reset) state <= START;
      else state <= next;
  end

  assign done = (state==DONE);

endmodule

