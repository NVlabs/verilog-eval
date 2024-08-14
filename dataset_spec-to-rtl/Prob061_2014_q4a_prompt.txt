
I would like you to implement a module named TopModule with the following
interface. All input and output ports are one bit unless otherwise
specified.

 - input  clk
 - input  w
 - input  R
 - input  E
 - input  L
 - output Q

The module will be one stage in a larger n-bit shift register circuit.
Input E is for enabling shift, R for value to load, L is asserted when it
should load, and w is the input from the prevous stage of the shift
register. Assume all sequential logic is triggered on the positive edge
of the clock.

