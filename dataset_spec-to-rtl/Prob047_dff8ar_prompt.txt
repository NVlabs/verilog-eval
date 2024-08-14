
I would like you to implement a module named TopModule with the following
interface. All input and output ports are one bit unless otherwise
specified.

 - input  clk
 - input  areset
 - input  d      (8 bits)
 - output q      (8 bits)

The module should include 8 D flip-flops with active high asynchronous
reset. The output should be reset to 0. All DFFs should be triggered by
the positive edge of clk.

