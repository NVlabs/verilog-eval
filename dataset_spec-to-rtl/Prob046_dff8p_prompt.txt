
I would like you to implement a module named TopModule with the following
interface. All input and output ports are one bit unless otherwise
specified.

 - input  clk
 - input  reset
 - input  d (8 bits)
 - output q (8 bits)

Implement a module that includes 8 D flip-flops with active high
synchronous reset. The flip-flops must be reset to 0x34 rather than zero.
All DFFs should be triggered by the negative edge of clk.

