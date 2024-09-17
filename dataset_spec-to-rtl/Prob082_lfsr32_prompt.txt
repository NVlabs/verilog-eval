
I would like you to implement a module named TopModule with the following
interface. All input and output ports are one bit unless otherwise
specified.

 - input  clk
 - input  reset
 - output q (32 bits)

A linear feedback shift register is a shift register usually with a few
XOR gates to produce the next state of the shift register. A Galois LFSR
is one particular arrangement that shifts right, where a bit position with
a "tap" is XORed with the LSB output bit (q[0]) to produce its next value,
while bit positions without a tap shift right unchanged. 

The module should implement a 32-bit Galois LFSR with taps at bit
positions 32, 22, 2, and 1. Reset should be active high synchronous, and
should reset the output q to 32'h1. Assume all sequential logic is
triggered on the positive edge of the clock.

