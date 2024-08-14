
I would like you to implement a module named TopModule with the following
interface. All input and output ports are one bit unless otherwise
specified.

 - input  clk
 - input  in
 - output out

The module should implement the following circuit: A D flip-flop takes as
input the output of a two-input XOR. The flip-flop is positive edge
triggered by clk, but there is no reset. The XOR takes as input 'in'
along with the output 'out' of the flip-flop.

