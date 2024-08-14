
I would like you to implement a module named TopModule with the following
interface. All input and output ports are one bit unless otherwise
specified.

 - input  in     (8 bits)
 - output parity

Parity checking is often used as a simple method of detecting errors when
transmitting data through an imperfect channel. The module should compute
a parity bit for an 8-bit byte (which will add a 9th bit to the byte). We
will use "even" parity, where the parity bit is just the XOR of all 8
data bits.

