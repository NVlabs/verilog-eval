
I would like you to implement a module named TopModule with the following
interface. All input and output ports are one bit unless otherwise
specified.

 - input  a
 - input  b
 - input  c
 - output w
 - output x
 - output y
 - output z

The module should behave like wires that makes these connections:

  a -> w
  b -> x
  b -> y
  c -> z

