
module RefModule (
  input clk,
  input reset,
  output [3:1] ena,
  output reg [15:0] q
);

  wire [3:0] enable = { q[11:0]==12'h999, q[7:0]==8'h99, q[3:0] == 4'h9, 1'b1};
  assign ena = enable[3:1];
  always @(posedge clk)
    for (int i=0;i<4;i++) begin
      if (reset || (q[i*4 +:4] == 9 && enable[i]))
        q[i*4 +:4] <= 0;
      else if (enable[i])
        q[i*4 +:4] <= q[i*4 +:4]+1;
    end

endmodule

