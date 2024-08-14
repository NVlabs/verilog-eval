
I would like you to implement a module named TopModule with the following
interface. All input and output ports are one bit unless otherwise
specified.

 - input  clk
 - input  areset
 - input  x
 - output z

The module should implement the following Mealy finite-state machine
which is an implementation of the 2's complementer. Implement using a
one-hot encoding. Resets into state A and reset is asynchronous
active-high.

  A --x=0 (z=0)--> A
  A --x=1 (z=1)--> B
  B --x=0 (z=1)--> B
  B --x=1 (z=0)--> B

Assume all sequential logic is triggered on the positive edge of the
clock.

