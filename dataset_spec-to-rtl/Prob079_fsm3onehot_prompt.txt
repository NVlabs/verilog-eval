
I would like you to implement a module named TopModule with the following
interface. All input and output ports are one bit unless otherwise
specified.

 - input  in
 - input  state (4 bits)
 - output next_state (4 bits)
 - output out

The module should implement the state transition table for a Moore state
machine with one input, one output, and four states. Use the following
one-hot state encoding: A=4'b0001, B=4'b0010, C=4'b0100, D=4'b1000.
Derive state transition and output logic equations by inspection assuming
a one-hot encoding. Implement only the state transition logic and output
logic (the combinational logic portion) for this state machine.

  State | Next state in=0, Next state in=1 | Output
  A     | A, B                             | 0
  B     | C, B                             | 0
  C     | A, D                             | 0
  D     | C, B                             | 1

