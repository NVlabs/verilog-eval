
I would like you to implement a module named TopModule with the following
interface. All input and output ports are one bit unless otherwise
specified.

 - input  a              (3 bits)
 - input  b              (3 bits)
 - output out_or_bitwise (3 bits)
 - output out_or_logical
 - output out_not        (6 bits)

Implement a module with two 3-bit inputs that computes the bitwise-OR of
the two vectors, the logical-OR of the two vectors, and the inverse (NOT)
of both vectors. Place the inverse of b in the upper half of out_not
(i.e., bits [5:3]), and the inverse of a in the lower half.

