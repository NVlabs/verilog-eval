
I would like you to implement a module named TopModule with the following
interface. All input and output ports are one bit unless otherwise
specified.

 - input  clk
 - input  in    (8 bits)
 - output pedge (8 bits)

The module should examine each bit in an 8-bit vector and detect when the
input signal changes from 0 in one clock cycle to 1 the next (similar to
positive edge detection). The output bit should be set the cycle after a
0 to 1 transition occurs.

