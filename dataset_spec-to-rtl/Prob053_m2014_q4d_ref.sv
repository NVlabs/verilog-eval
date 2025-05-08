
module RefModule (
  input clk,
  input in,
  output logic out
);

  initial
    out = 1'hx;

  always@(posedge clk) begin
    out <= in ^ out;
  end

endmodule

