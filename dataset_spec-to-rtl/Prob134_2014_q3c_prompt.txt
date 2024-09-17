
I would like you to implement a module named TopModule with the following
interface. All input and output ports are one bit unless otherwise
specified.

 - input  clk
 - input  x
 - input  y (3 bits)
 - output Y0
 - output z

The module should implement the output logic and next state logic for an
FSM using the table shown below. Note that the output Y0 is Y[0] of the
next state signal.

   Present state input y[2:0] | Next state Y[2:0] when x=0, Next state Y[2:0] when x=1 | Output z
   000 | 000, 001 | 0
   001 | 001, 100 | 0
   010 | 010, 001 | 0
   011 | 001, 010 | 1
   100 | 011, 100 | 1

