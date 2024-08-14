
I would like you to implement a module named TopModule with the following
interface. All input and output ports are one bit unless otherwise
specified.

 - input  clk
 - input  areset
 - input  in
 - output out

The module should implement a Moore state machine with the following
state transition table with one input, one output, and four states.
Implement this state machine. Include a positive edge triggered
asynchronous reset that resets the FSM to state A. Assume all sequential
logic is triggered on the positive edge of the clock.

  state | next state in=0, next state in=1 | output
  A     | A, B                             | 0
  B     | C, B                             | 0
  C     | A, D                             | 0
  D     | C, B                             | 1

