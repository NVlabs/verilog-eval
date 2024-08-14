
module RefModule (
  input clk,
  input in,
  input areset,
  output out
);

  parameter A=0, B=1, C=2, D=3;
  reg [1:0] state;
  reg [1:0] next;

  always_comb begin
  case (state)
    A: next = in ? B : A;
    B: next = in ? B : C;
    C: next = in ? D : A;
    D: next = in ? B : C;
  endcase
  end

  always @(posedge clk, posedge areset) begin
    if (areset) state <= A;
      else state <= next;
  end

  assign out = (state==D);

endmodule

