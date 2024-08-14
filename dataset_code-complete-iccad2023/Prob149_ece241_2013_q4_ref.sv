
module RefModule (
  input clk,
  input reset,
  input [3:1] s,
  output reg fr3,
  output reg fr2,
  output reg fr1,
  output reg dfr
);

  parameter A2=0, B1=1, B2=2, C1=3, C2=4, D1=5;
  reg [2:0] state, next;

  always @(posedge clk) begin
    if (reset) state <= A2;
    else state <= next;
  end

  always@(*) begin
    case (state)
      A2: next = s[1] ? B1 : A2;
      B1: next = s[2] ? C1 : (s[1] ? B1 : A2);
      B2: next = s[2] ? C1 : (s[1] ? B2 : A2);
      C1: next = s[3] ? D1 : (s[2] ? C1 : B2);
      C2: next = s[3] ? D1 : (s[2] ? C2 : B2);
      D1: next = s[3] ? D1 : C2;
      default: next = 'x;
    endcase
  end
  reg [3:0] fr;
  assign {fr3, fr2, fr1, dfr} = fr;
  always_comb begin
    case (state)
      A2: fr = 4'b1111;
      B1: fr = 4'b0110;
      B2: fr = 4'b0111;
      C1: fr = 4'b0010;
      C2: fr = 4'b0011;
      D1: fr = 4'b0000;
      default: fr = 'x;
    endcase
  end

endmodule

