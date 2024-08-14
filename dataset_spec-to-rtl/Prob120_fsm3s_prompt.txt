
I would like you to implement a module named TopModule with the following
interface. All input and output ports are one bit unless otherwise
specified.

 - input  clk
 - input  reset
 - input  in
 - output out

The module should implement a Moore state machine with the following
state transition table with one input, one output, and four states.
Include a synchronous active high reset that resets the FSM to state A.
Assume all sequential logic is triggered on the positive edge of the
clock.

  State | Next state in=0, Next state in=1 | Output
  A     | A, B                             | 0
  B     | C, B                             | 0
  C     | A, D                             | 0
  D     | C, B                             | 1

