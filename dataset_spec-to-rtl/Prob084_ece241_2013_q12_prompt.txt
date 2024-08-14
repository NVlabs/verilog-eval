
I would like you to implement a module named TopModule with the following
interface. All input and output ports are one bit unless otherwise
specified.

 - input  clk
 - input  enable
 - input  S
 - input  A
 - input  B
 - input  C
 - output Z

The module should implement a circuit for an 8x1 memory, where writing to
the memory is accomplished by shifting-in bits, and reading is "random
access", as in a typical RAM. You will then use the circuit to realize a
3-input logic function. First, create an 8-bit shift register with 8
D-type flip-flops. Label the flip-flop outputs from Q[0]...Q[7]. The
shift register input should be called S, which feeds the input of Q[0]
(MSB is shifted in first). The enable input is synchronous active high
and controls whether to shift. Extend the circuit to have 3 additional
inputs A,B,C and an output Z. The circuit's behaviour should be as
follows: when ABC is 000, Z=Q[0], when ABC is 001, Z=Q[1], and so on.
Your circuit should contain ONLY the 8-bit shift register, and
multiplexers. Assume all sequential logic is triggered on the positive
edge of the clock.

