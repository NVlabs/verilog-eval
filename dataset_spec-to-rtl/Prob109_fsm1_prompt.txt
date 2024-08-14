
I would like you to implement a module named TopModule with the following
interface. All input and output ports are one bit unless otherwise
specified.

 - input  clk
 - input  areset
 - input  in
 - output out

The module should implement a Moore machine with the diagram described
below:

  B (1) --0--> A
  B (1) --1--> B
  A (0) --0--> B
  A (0) --1--> A

It should asynchronously reset into state B if reset if high.

