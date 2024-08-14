
module RefModule (
  input clk,
  input areset,
  input bump_left,
  input bump_right,
  output walk_left,
  output walk_right
);

  parameter WL=0, WR=1;
  reg state;
  reg next;

  always_comb begin
    case (state)
      WL: next = bump_left ? WR : WL;
      WR: next = bump_right ? WL: WR;
    endcase
  end

  always @(posedge clk, posedge areset) begin
    if (areset) state <= WL;
      else state <= next;
  end

  assign walk_left = (state==WL);
  assign walk_right = (state==WR);

endmodule

