
I would like you to implement a module named TopModule with the following
interface. All input and output ports are one bit unless otherwise
specified.

 - input  clk
 - input  j
 - input  k
 - output Q

The module should implement a JK flip-flop with the following truth
table. Note: Qold is the output of the flip-flop before the positive
clock edge.

  J | K | Q
  0 | 0 | Qold
  0 | 1 | 0
  1 | 0 | 1
  1 | 1 | ~Qold

