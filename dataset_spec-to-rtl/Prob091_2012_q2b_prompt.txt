
I would like you to implement a module named TopModule with the following
interface. All input and output ports are one bit unless otherwise
specified.

 - input  y (6 bits)
 - input  w
 - output Y1
 - output Y3

Consider the following finite-state machine:

  A (0) --1--> B
  A (0) --0--> A
  B (0) --1--> C
  B (0) --0--> D
  C (0) --1--> E
  C (0) --0--> D
  D (0) --1--> F
  D (0) --0--> A
  E (1) --1--> E
  E (1) --0--> D
  F (1) --1--> C
  F (1) --0--> D

Assume that a one-hot code is used with the state assignment y[5:0] =
000001(A), 000010(B), 000100(C), 001000(D), 010000(E), 100000(F)

The module should implement the state output logic for this finite-state
machine. The output signal Y1 should be the input of state flip-flop
y[1]. The output signal Y3 should be the input of state flip-flop y[3].
Derive the implementation by inspection assuming the above one-hot
encoding.

