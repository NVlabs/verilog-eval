
I would like you to implement a module named TopModule with the following
interface. All input and output ports are one bit unless otherwise
specified.

 - input clk
 - input in       (8 bits)
 - output anyedge (8 bits)

Implement a module that for each bit in an 8-bit input vector, detect
when the input signal changes from one clock cycle to the next (detect
any edge). The output bit of anyedge should be set to 1 the cycle 
after the input bit has 0 to 1 or 1 to 0 transition occurs. Assume all 
sequential logic is triggered on the positive edge of the clock.

