
I would like you to implement a module named TopModule with the following
interface. All input and output ports are one bit unless otherwise
specified.

 - input  a
 - input  b
 - input  c
 - input  d
 - input  e
 - output out (25 bits)

Implement a module that given five 1-bit signals (a, b, c, d, and e),
compute all 25 pairwise one-bit comparisons in the 25-bit output vector.
The output should be 1 if the two bits being compared are equal. Example:
out[24] = ~a ^ a; out[23] = ~a ^ b; out[22] = ~a ^ c; ...
out[ 1] = ~e ^ d; out[ 0] = ~e ^ e.

