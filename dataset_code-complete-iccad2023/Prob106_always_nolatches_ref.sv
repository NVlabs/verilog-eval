
module RefModule (
  input [15:0] scancode,
  output reg left,
  output reg down,
  output reg right,
  output reg up
);

  always @(*) begin
    {up, left, down, right} = 0;
    case (scancode)
      16'he06b: left = 1;
      16'he072: down = 1;
      16'he074: right = 1;
      16'he075: up = 1;
    endcase
  end

endmodule

