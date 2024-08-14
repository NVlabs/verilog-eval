
I would like you to implement a module named TopModule with the following
interface. All input and output ports are one bit unless otherwise
specified.

 - input  clk
 - input  reset
 - input  w
 - output z

The module should implement the state machine shown below:

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

Reset resets into state A and is synchronous active-high. Assume all
sequential logic is triggered on the positive edge of the clock.

Use separate always blocks for the state table and the state flip-flops.
Describe the FSM output, which is called _z_, using either continuous
assignment statement(s) or an always block (at your discretion). Assign
any state codes that you wish to use.

