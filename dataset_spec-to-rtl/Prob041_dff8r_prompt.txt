
I would like you to implement a module named TopModule with the following
interface. All input and output ports are one bit unless otherwise
specified.

 - input  clk
 - input  reset
 - input  d (8 bits)
 - output q (8 bits)

The module should include 8 D flip-flops with active high synchronous
reset setting the output to zero. All DFFs should be triggered by the
positive edge of clk.

