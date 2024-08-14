
I would like you to implement a module named TopModule with the following
interface. All input and output ports are one bit unless otherwise
specified.

 - input  in  (1024 bits)
 - input  sel (   8 bits)
 - output out (   4 bits)

The module should implement a 4-bit wide, 256-to-1 multiplexer. The 256
4-bit inputs are all packed into a single 1024-bit input vector. sel=0
should select bits in[3:0], sel=1 selects bits in[7:4], sel=2 selects
bits in[11:8], etc.

