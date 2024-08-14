
I would like you to implement a module named TopModule with the following
interface. All input and output ports are one bit unless otherwise
specified.

 - input  clk
 - input  resetn
 - input  byteena ( 2 bits)
 - input  d       (16 bits)
 - output q       (16 bits)

The module should include 16 D flip-flops. It's sometimes useful to only
modify parts of a group of flip-flops. The byte-enable inputs control
whether each byte of the 16 registers should be written to on that cycle.
byteena[1] controls the upper byte d[15:8], while byteena[0] controls the
lower byte d[7:0]. resetn is a synchronous, active-low reset. All DFFs
should be triggered by the positive edge of clk.

