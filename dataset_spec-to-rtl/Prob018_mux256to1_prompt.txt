
I would like you to implement a module named TopModule with the following
interface. All input and output ports are one bit unless otherwise
specified.

 - input  in  (256 bits)
 - input  sel (  8 bits)
 - output out

The module should implement a 1-bit wide, 256-to-1 multiplexer. The 256
inputs are all packed into a single 256-bit input vector. sel=0 should
select in[0], sel=1 selects bits in[1], sel=2 selects bits in[2], etc.

