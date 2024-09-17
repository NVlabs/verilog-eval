
I would like you to implement a module named TopModule with the following
interface. All input and output ports are one bit unless otherwise
specified.

 - input  y (6 bits)
 - input  w
 - output Y1
 - output Y3

Consider the state machine shown below:

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

Resets into state A. For this part, assume that a one-hot code is used
with the state assignment y[5:0] = 000001, 000010, 000100, 001000,
010000, 100000 for states A, B,..., F, respectively.

The module shou module ment the next-state signals Y2 and Y4
corresponding to signal y[1] and y[3]. Derive the logic equations by
inspection assuming the one-hot encoding.
 implement the next-state signals  and corresponding to
signal y[1] and y[3]Derive the logic equations byinspection assuming the one-hot encoding.

