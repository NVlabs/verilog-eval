
I would like you to implement a module named TopModule with the following
interface. All input and output ports are one bit unless otherwise
specified.

 - input  in  (8 bits)
 - output pos (3 bits)

The module should implement a priority encoder for an 8-bit input. Given
an 8-bit vector, the output should report the first (least significant)
bit in the vector that is 1. Report zero if the input vector has no bits
that are high. For example, the input 8'b10010000 should output 3'd4,
because bit[4] is first bit that is high.

