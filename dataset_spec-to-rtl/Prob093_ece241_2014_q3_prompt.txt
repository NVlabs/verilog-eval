
I would like you to implement a module named TopModule with the following
interface. All input and output ports are one bit unless otherwise
specified.

 - input  c
 - input  d
 - output mux_in (4 bits)

For the following Karnaugh map, give the circuit implementation using one
4-to-1 multiplexer and as many 2-to-1 multiplexers as required, but using
as few as possible. You are not allowed to use any other logic gate and
you must use _a_ and _b_ as the multiplexer selector inputs, as shown on
the 4-to-1 multiplexer below.

      ab
  cd  00  01  11  10
  00 | 0 | 0 | 0 | 1 |
  01 | 1 | 0 | 0 | 0 |
  11 | 1 | 0 | 1 | 1 |
  10 | 1 | 0 | 0 | 1 |

Consider a block diagram with inputs 'c' and 'd' going into a module
called "TopModule". This "TopModule" has four outputs, mux_in[3:0], that
connect to a four input mux. The mux takes as input {a,b} and ab = 00 is
connected to mux_in[0], ab=01 is connected to mux_in[1], and so in. You
are implementing in Verilog just the portion labelled "TopModule", such
that the entire circuit (including the 4-to-1 mux) implements the K-map.

