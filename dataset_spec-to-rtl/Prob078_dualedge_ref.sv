
module RefModule (
  input clk,
  input d,
  output reg q
);

  /*always @(posedge clk, negedge clk) begin
    q <= d;
  end*/

  reg qp, qn;
  always @(posedge clk)
    qp <= d;
  always @(negedge clk)
    qn <= d;

  // This causes q to change too early when clk changes. Need delay by
  // delta cycle
  // assign q = clk ? qp : qn;
  always @(*)
    q <= clk ? qp : qn;

endmodule

