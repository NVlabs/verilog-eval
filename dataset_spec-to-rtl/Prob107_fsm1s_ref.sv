
module RefModule (
  input clk,
  input in,
  input reset,
  output out
);

  parameter A=0, B=1;
  reg state;
  reg next;

    always_comb begin
    case (state)
      A: next = in ? A : B;
      B: next = in ? B : A;
    endcase
    end

    always @(posedge clk) begin
    if (reset) state <= B;
        else state <= next;
  end

  assign out = (state==B);

endmodule

