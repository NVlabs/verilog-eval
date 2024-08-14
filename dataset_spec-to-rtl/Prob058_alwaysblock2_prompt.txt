
I would like you to implement a module named TopModule with the following
interface. All input and output ports are one bit unless otherwise
specified.

 - input  clk
 - input  a
 - input  b
 - output out_assign
 - output out_always_comb
 - output out_always_ff

The module should implement an XOR gate three ways, using an assign
statement (output out_assign), a combinational always block (output
out_always_comb), and a clocked always block (output out_always_ff). Note
that the clocked always block produces a different circuit from the other
two: There is a flip- flop so the output is delayed. Assume all
sequential logic is triggered on the positive edge of the clock.

