
Consider the following adder-subtractor with a zero flag:

  synthesis verilog_input_version verilog_2001
  module TopModule (
      input do_sub,
      input [7:0] a,
      input [7:0] b,
      output reg [7:0] out,
      output reg result_is_zero
  );

      always @(*) begin
          case (do_sub)
            0: out = a+b;
            1: out = a-b;
          endcase

          if (~out)
              result_is_zero = 1;
      end

  endmodule

Unfortunately, this module has a bug. Implement a new version of this
module that fixes the bug.

