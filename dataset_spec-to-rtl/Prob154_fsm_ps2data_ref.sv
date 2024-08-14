
module RefModule (
  input clk,
  input [7:0] in,
  input reset,
  output [23:0] out_bytes,
  output done
);

  parameter BYTE1=0, BYTE2=1, BYTE3=2, DONE=3;
  reg [1:0] state;
  reg [1:0] next;

  wire in3 = in[3];

  always_comb begin
    case (state)
      BYTE1: next = in3 ? BYTE2 : BYTE1;
      BYTE2: next = BYTE3;
      BYTE3: next = DONE;
      DONE: next = in3 ? BYTE2 : BYTE1;
    endcase
  end

  always @(posedge clk) begin
    if (reset) state <= BYTE1;
      else state <= next;
  end

  assign done = (state==DONE);

  reg [23:0] out_bytes_r;
  always @(posedge clk)
    out_bytes_r <= {out_bytes_r[15:0], in};

  // Implementations may vary: Allow user to do anything while the output
  // doesn't have to be valid.

  assign out_bytes = done ? out_bytes_r : 'x;

endmodule

