
I would like you to implement a module named TopModule with the following
interface. All input and output ports are one bit unless otherwise
specified.

 - input  clk
 - input  areset
 - input  j
 - input  k
 - output out

The module should implement a Moore state machine with two states, two
inputs, and one output according to diagram described below. Reset is an
active-high asynchronous reset to state OFF.

  OFF (out=0) --j=0--> OFF
  OFF (out=0) --j=1--> ON
  ON  (out=1) --k=0--> ON
  ON  (out=1) --k=1--> OFF

