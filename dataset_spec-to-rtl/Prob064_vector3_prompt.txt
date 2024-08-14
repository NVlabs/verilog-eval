
I would like you to implement a module named TopModule with the following
interface. All input and output ports are one bit unless otherwise
specified.

 - input  a (5 bits)
 - input  b (5 bits)
 - input  c (5 bits)
 - input  d (5 bits)
 - input  e (5 bits)
 - input  f (5 bits)
 - output w (8 bits)
 - output x (8 bits)
 - output y (8 bits)
 - output z (8 bits)

The module should concatenate the input vectors together then split them
up into several output vectors. There are six 5-bit input vectors: a, b,
c, d, e, and f, for a total of 30 bits of input. There are four 8-bit
output vectors: w, x, y, and z, for 32 bits of output. The output should
be a concatenation of the input vectors followed by two 1 bits (the two 1
bits should be in the LSB positions).

