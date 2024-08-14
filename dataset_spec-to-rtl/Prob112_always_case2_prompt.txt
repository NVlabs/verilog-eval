
I would like you to implement a module named TopModule with the following
interface. All input and output ports are one bit unless otherwise
specified.

 - input  in  (4 bits)
 - output pos (2 bits)

The module should implement a priority encoder. A priority encoder is a
combinational circuit that, when given an input bit vector, outputs the
position of the first 1 bit in the vector. For example, a 8-bit priority
encoder given the input 8'b10010000 would output 3'd4, because bit[4] is
first bit that is high. Build a 4-bit priority encoder. For this problem,
if none of the input bits are high (i.e., input is zero), output zero.
Note that a 4-bit number has 16 possible combinations.

