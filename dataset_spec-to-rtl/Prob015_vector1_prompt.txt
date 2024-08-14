
I would like you to implement a module named TopModule with the following
interface. All input and output ports are one bit unless otherwise
specified.

 - input  in     (16 bits)
 - output out_hi ( 8 bits)
 - output out_lo ( 8 bits)

The module should implement a combinational circuit that splits an input
half-word (16 bits, [15:0] ) into lower [7:0] and upper [15:8] bytes.

