
I would like you to implement a module named TopModule with the following
interface. All input and output ports are one bit unless otherwise
specified.

 - input  clk
 - input  aresetn
 - input  x
 - output z

The module should implement a Mealy-type finite state machine that
recognizes the sequence "101" on an input signal named x. Your FSM should
have an output signal, z, that is asserted to logic-1 when the "101"
sequence is detected. Your FSM should also have a negative edge triggered
asynchronous reset. You may only have 3 states in your state machine.
Your FSM should recognize overlapping sequences. Assume all sequential
logic is triggered on the positive edge of the clock.

