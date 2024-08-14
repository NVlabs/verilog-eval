
I would like you to implement a module named TopModule with the following
interface. All input and output ports are one bit unless otherwise
specified.

  - input  a
  - input  b
  - input  c
  - input  d
  - output out_sop
  - output out_pos

The module should implement a digital system with four inputs (a,b,c,d)
that generates a logic-1 when 2, 7, or 15 appears on the inputs, and a
logic-0 when 0, 1, 4, 5, 6, 9, 10, 13, or 14 appears. The input
conditions for the numbers 3, 8, 11, and 12 never occur in this system.
For example, 7 corresponds to a,b,c,d being set to 0,1,1,1, respectively.
Determine the output out_sop in minimum sum-of-products form, and the
output out_pos in minimum product-of-sums form.

