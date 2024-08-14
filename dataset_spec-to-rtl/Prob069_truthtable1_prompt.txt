
I would like you to implement a module named TopModule with the following
interface. All input and output ports are one bit unless otherwise
specified.

 - input  x3
 - input  x2
 - input  x1
 - output f

The module should implement a combinational circuit for the following
truth table:

  x3 | x2 | x1 | f
  0  | 0  | 0  | 0
  0  | 0  | 1  | 0
  0  | 1  | 0  | 1
  0  | 1  | 1  | 1
  1  | 0  | 0  | 0
  1  | 0  | 1  | 1
  1  | 1  | 0  | 0
  1  | 1  | 1  | 1

