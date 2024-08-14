
I would like you to implement a module named TopModule with the following
interface. All input and output ports are one bit unless otherwise
specified.

 - input  a
 - input  b
 - output out_and
 - output out_or
 - output out_xor
 - output out_nand
 - output out_nor
 - output out_xnor
 - output out_anotb

The module should implement a combinational circuit with two inputs, a
and b. There are 7 outputs, each with a logic gate driving it:

  (1) out_and: a and b
  (2) out_or: a or b
  (3) out_xor: a xor b
  (4) out_nand: a nand b
  (5) out_nor: a nor b
  (6) out_xnor: a xnor b
  (7) out_anotb: a and-not b

