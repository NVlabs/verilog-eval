
module RefModule (
  input clk,
  input L,
  input q_in,
  input r_in,
  output reg Q
);

  initial Q=1'hx;
  always @(posedge clk)
    Q <= L ? r_in : q_in;

endmodule

