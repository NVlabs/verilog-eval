
Consider the following implementation of an 8-bit 2-to-1 mux:

  module TopModule (
      input        sel,
      input  [7:0] a,
      input  [7:0] b,
      output       out
  );

      assign out = (~sel & a) | (sel & b);

  endmodule

Unfortunately, this module has a bug. Implement a new version of this
module that fixes the bug.

