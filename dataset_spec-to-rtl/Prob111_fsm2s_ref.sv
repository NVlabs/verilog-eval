
module RefModule (
  input clk,
  input j,
  input k,
  input reset,
  output out
);

  parameter A=0, B=1;
  reg state;
  reg next;

    always_comb begin
    case (state)
      A: next = j ? B : A;
      B: next = k ? A : B;
    endcase
    end

    always @(posedge clk) begin
    if (reset) state <= A;
        else state <= next;
  end

  assign out = (state==B);

endmodule

