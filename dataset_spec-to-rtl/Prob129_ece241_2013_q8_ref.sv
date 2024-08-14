
module RefModule (
  input clk,
  input aresetn,
  input x,
  output reg z
);

  parameter S=0, S1=1, S10=2;
  reg[1:0] state, next;

  always@(posedge clk, negedge aresetn)
    if (!aresetn)
      state <= S;
    else
      state <= next;

  always_comb begin
    case (state)
      S: next = x ? S1 : S;
      S1: next = x ? S1 : S10;
      S10: next = x ? S1 : S;
      default: next = 'x;
    endcase
  end

  always_comb begin
    case (state)
      S: z = 0;
      S1: z = 0;
      S10: z = x;
      default: z = 'x;
    endcase
  end

endmodule

