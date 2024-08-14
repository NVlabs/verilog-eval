
I would like you to implement a module named TopModule with the following
interface. All input and output ports are one bit unless otherwise
specified.

 - input  y (3 bits)
 - input  w
 - output Y1

The module should implement the state machine shown below:

  A (0) --0--> B
  A (0) --1--> A
  B (0) --0--> C
  B (0) --1--> D
  C (0) --0--> E
  C (0) --1--> D
  D (0) --0--> F
  D (0) --1--> A
  E (1) --0--> E
  E (1) --1--> D
  F (1) --0--> C
  F (1) --1--> D

The FSM should be implemented using three flip-flops and state codes
y = 000, 001, ..., 101 for states A, B, ..., F, respectively. Implement
just the next-state logic for y[1]. The output Y1 is y[1].

