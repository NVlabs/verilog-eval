
I would like you to implement a module named TopModule with the following
interface. All input and output ports are one bit unless otherwise
specified.

 - input  a (8 bits)
 - input  b (8 bits)
 - output s (8 bits)
 - output overflow

Assume that you have two 8-bit 2's complement numbers, a[7:0] and b[7:0].
The module should add these numbers to produce s[7:0]. Also compute
whether a (signed) overflow has occurred.

