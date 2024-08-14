
module RefModule (
  input clk,
  input reset,
  output reg [31:0] q
);

  logic [31:0] q_next;
  always@(q) begin
    q_next = q[31:1];
    q_next[31] = q[0];
    q_next[21] ^= q[0];
    q_next[1] ^= q[0];
    q_next[0] ^= q[0];
  end

  always @(posedge clk) begin
    if (reset)
      q <= 32'h1;
    else
      q <= q_next;
  end

endmodule

