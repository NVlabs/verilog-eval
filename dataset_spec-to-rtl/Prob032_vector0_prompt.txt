
I would like you to implement a module named TopModule with the following
interface. All input and output ports are one bit unless otherwise
specified.

 - input  vec  (3 bits)
 - output outv (3 bits)
 - output o2
 - output o1
 - output o0

The module has one 3-bit input, then outputs the same vector, and also
splits it into three separate 1-bit outputs. Connect output o0 to the
input vector's position 0, o1 to position 1, etc.

